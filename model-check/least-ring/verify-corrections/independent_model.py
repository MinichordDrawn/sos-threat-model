"""Independent implementation of the model of model-spec.md, model-spec-join.md and
model-spec-scope.md, written from those three files only.

Usage:
    python model.py systems-minimal.json answers.json [--workers N] [--reading NAME ...]

A state is the tuple
    (alive, bad, hidden, off, present, halted, pending, closed, flags)
where every component but the last is a bit mask over the processes (monitors first, then
the work processes, then the joiner), `closed` is a bit mask over the scopes, and `flags`
is a tuple with one monitor mask per scope: bit m of flags[s] is the pair (m, s) of X3.
`alive` holds monitor bits only (nothing in the model reads whether a non-monitor process
is in `alive`). `arrived` and `joined` are not stored: a group has arrived exactly when
its members are present, and the joiner has joined exactly when it is present.

--reading selects another reading of a place where the files can be read two ways (the
default is the reading the answers in answers.json were computed with):
    after-work-always   an entry of `after` that names a process listed in `works` is
                        always satisfied (the sentence of J1), even for a late work
                        process; the default follows X1 (satisfied once it is present)
    freeze-by-cover     with `freeze`, a non-monitor process in the work of a closed
                        scope is frozen too; the default follows X7 (a process is frozen
                        when its own entry in `scope` is a closed scope)

A system that is not scoped is run by the same code with one internal scope that every
process belongs to and that covers every non-monitor process, with no `told`, no spill, no
closing and no freeze. Section 3.2 to 3.5 and J6 are then what X4 to X8 say word for word.
"""
import json
import sys
import time


class Unfinished(Exception):
    pass


def bits(x):
    while x:
        b = x & -x
        yield b.bit_length() - 1
        x ^= b


class Model:
    def __init__(self, sysd, readings=()):
        self.readings = set(readings)
        g = sysd.get
        monitors = list(sysd['monitors'])
        works = list(sysd['works'])
        joiner = g('joiner')
        nonmon = works + ([joiner] if joiner is not None else [])
        procs = monitors + nonmon
        if len(set(procs)) != len(procs):
            raise ValueError('process names are not distinct')
        idx = {p: i for i, p in enumerate(procs)}
        self.procs = procs
        self.M = M = len(monitors)
        self.P = P = len(procs)
        self.MON = MON = (1 << M) - 1
        self.NONMON = ((1 << P) - 1) ^ MON
        self.f = int(sysd['f'])
        self.coupling = bool(g('coupling', False))
        self.window = int(g('window', 0))
        self.gate = bool(g('gate', True))
        self.slow_reports = bool(g('slow_reports', False))
        self.arrive_bad = bool(g('arrive_bad', False))
        self.max_rounds = g('max_rounds')

        def mmask(names):
            r = 0
            for n in names:
                i = idx[n]
                if i >= M:
                    raise ValueError('%r is not a monitor' % (n,))
                r |= 1 << i
            return r

        def rel(name):
            arr = [0] * P
            for k, lst in (g(name) or {}).items():
                arr[idx[k]] = mmask(lst)
            return arr

        self.hb = rel('hb_readers')
        self.chk = rel('checkers')
        self.fwd = rel('fwd')
        self.halt = rel('halt_inputs')
        self.rels = {'hb_readers': self.hb, 'checkers': self.chk, 'fwd': self.fwd,
                     'halt_inputs': self.halt}
        self.switches = mmask(g('switches') or [])

        # boundaries: only those holding at least two monitors can ever be stopped
        bmap = {}
        for m, b in (g('boundary') or {}).items():
            if b is None:
                continue
            bmap.setdefault(b, 0)
            bmap[b] |= mmask([m])
        self.boundaries = [v for v in bmap.values() if bin(v).count('1') >= 2]
        self.boundary_ids = [k for k, v in bmap.items() if bin(v).count('1') >= 2]
        smap = {}
        for p, s in (g('substrate') or {}).items():
            if s is None:
                continue
            smap.setdefault(s, 0)
            smap[s] |= 1 << idx[p]
        self.substrates = list(smap.values())
        self.substrate_ids = list(smap.keys())

        # late groups
        self.groups = []
        self.group_names = [grp['name'] for grp in (g('late') or [])]
        late = 0
        for grp in (g('late') or []):
            mem = 0
            for n in grp['members']:
                mem |= 1 << idx[n]
            if mem & late:
                raise ValueError('a process is in two groups')
            late |= mem
            aft = 0
            for n in (grp.get('after') or []):
                if 'after-work-always' in self.readings and n in works:
                    # other reading: the sentence of J1 ("one that names ... a process
                    # listed in works is always satisfied") kept for a late work
                    # process too, against X1
                    continue
                aft |= 1 << idx[n]
            self.groups.append((mem, aft, [1 << i for i in bits(mem & MON)]))
        self.joiner_bit = 0
        if joiner is not None:
            self.joiner_bit = 1 << idx[joiner]
        self.joiner_own_step = bool(self.joiner_bit) and not (self.joiner_bit & late)
        self.present0 = ((1 << P) - 1) & ~late & ~self.joiner_bit
        self.alive0 = self.present0 & MON

        # slow edges
        self.slow = {k: [0] * P for k in self.rels}
        self.has_slow = False
        for r, k, m in (g('slow_edges') or []):
            mb = mmask([m])
            if not (self.rels[r][idx[k]] & mb):
                raise ValueError('slow edge %r is not an edge' % ([r, k, m],))
            self.slow[r][idx[k]] |= mb
            self.has_slow = True

        # scopes
        scope = g('scope') or {}
        self.scoped = bool(scope)
        if self.scoped:
            ids = []
            for p in procs:
                if p not in scope:
                    raise ValueError('%r has no scope' % (p,))
                if scope[p] not in ids:
                    ids.append(scope[p])
            sw = g('scope_work') or {}
            told = g('told') or {}
            for s in list(sw) + list(told):
                if s not in ids:
                    ids.append(s)
            self.scope_ids = ids
            sidx = {s: i for i, s in enumerate(ids)}
            self.nS = nS = len(ids)
            self.sc = [sidx[scope[p]] for p in procs]
            self.scopemask = [0] * nS
            for i, p in enumerate(procs):
                self.scopemask[self.sc[i]] |= 1 << i
            self.workmask = [0] * nS
            for s in ids:
                if s in sw:
                    for w in sw[s]:
                        if idx[w] < M:
                            raise ValueError('scope_work names a monitor')
                        self.workmask[sidx[s]] |= 1 << idx[w]
                else:
                    self.workmask[sidx[s]] = self.scopemask[sidx[s]] & self.NONMON
            self.toldmask = [mmask(told.get(s, [])) for s in ids]
            self.freeze = bool(g('freeze', False))
        else:
            self.scope_ids = [None]
            self.nS = nS = 1
            self.sc = [0] * P
            self.scopemask = [(1 << P) - 1]
            self.workmask = [self.NONMON]
            self.toldmask = [0]
            self.freeze = False
        self.cover = [[s for s in range(nS) if self.workmask[s] >> i & 1] for i in range(P)]
        self.covermask = [0] * P
        for i in range(P):
            for s in self.cover[i]:
                self.covermask[i] |= self.scopemask[s]
        self.NJ = 3 * nS + 1
        self.closure_cache = {}

    # ------------------------------------------------------------------ environment
    def env(self, S):
        """All states reachable from S by 0..f environment steps, as tuples
        (alive, bad, hidden, off, present)."""
        MON = self.MON
        frozen = 0
        if self.freeze and S[7]:
            for s in bits(S[7]):
                frozen |= self.scopemask[s]
                if 'freeze-by-cover' in self.readings:
                    # other reading of X2 "nothing joins it": a non-monitor process in
                    # the work of a closed scope is frozen too, whatever its own scope
                    frozen |= self.workmask[s]
        nfrozen = ~frozen
        start = S[:5]
        seen = {start}
        level = [start]
        boundaries = self.boundaries
        substrates = self.substrates
        switches = self.switches
        groups = self.groups
        arrive_bad = self.arrive_bad
        jb = self.joiner_bit if self.joiner_own_step else 0
        for _ in range(self.f):
            nxt = []
            for e in level:
                alive, bad, hidden, off, present = e
                # stop m
                x = alive & nfrozen
                while x:
                    b = x & -x
                    x ^= b
                    t = (alive ^ b, bad, hidden, off, present)
                    if t not in seen:
                        seen.add(t)
                        nxt.append(t)
                # stop-boundary b
                for bm in boundaries:
                    pm = bm & present
                    if pm & (pm - 1) and pm & alive & nfrozen:
                        t = (alive & ~(pm & nfrozen), bad, hidden, off, present)
                        if t not in seen:
                            seen.add(t)
                            nxt.append(t)
                # fail-substrate s
                for sm in substrates:
                    pm = sm & present & nfrozen
                    if (pm & MON & alive) or (pm & ~MON & ~bad):
                        nm = pm & ~MON
                        t = (alive & ~pm, bad | nm, hidden | nm, off, present)
                        if t not in seen:
                            seen.add(t)
                            nxt.append(t)
                # mutate p
                x = present & ~bad & nfrozen
                while x:
                    b = x & -x
                    x ^= b
                    t = (alive, bad | b, hidden, off, present)
                    if t not in seen:
                        seen.add(t)
                        nxt.append(t)
                # disable m
                x = switches & present & ~off & nfrozen
                while x:
                    b = x & -x
                    x ^= b
                    t = (alive, bad, hidden, off | b, present)
                    if t not in seen:
                        seen.add(t)
                        nxt.append(t)
                # join
                if jb and not (present & jb) and not (jb & frozen):
                    t = (alive, bad, hidden, off, present | jb)
                    if t not in seen:
                        seen.add(t)
                        nxt.append(t)
                # join g, join-bad g m
                for mem, aft, mons in groups:
                    if mem & present or (aft & present) != aft or mem & frozen:
                        continue
                    a2 = alive | (mem & MON)
                    p2 = present | mem
                    t = (a2, bad, hidden, off, p2)
                    if t not in seen:
                        seen.add(t)
                        nxt.append(t)
                    if arrive_bad:
                        for b in mons:
                            t = (a2, bad | b, hidden, off, p2)
                            if t not in seen:
                                seen.add(t)
                                nxt.append(t)
            level = nxt
            if not level:
                break
        return seen

    # ------------------------------------------------------------------ one round
    def inforce(self, relname, key, present, new):
        """Monitors m such that the edge [relname, key, m] is in force (J5). The caller
        makes sure `key` is present."""
        m = self.rels[relname][key] & present
        if self.has_slow:
            sl = self.slow[relname][key]
            if sl:
                if new >> key & 1:
                    m &= ~sl
                else:
                    m &= ~(sl & new)
        return m

    def closure(self, seed, active, present, new):
        """Monitors reached from `seed` (a subset of active) along fwd edges in force,
        through active monitors only; includes seed."""
        key = (seed, active, present, new) if self.has_slow else (seed, active)
        r = self.closure_cache.get(key)
        if r is not None:
            return r
        fwd = self.fwd
        cur = seed
        front = seed
        has_slow = self.has_slow
        while front:
            nx = 0
            x = front
            while x:
                b = x & -x
                x ^= b
                i = b.bit_length() - 1
                nx |= self.inforce('fwd', i, present, new) if has_slow else fwd[i]
            nx &= active & ~cur
            cur |= nx
            front = nx
        if len(self.closure_cache) > 400000:
            self.closure_cache.clear()
        self.closure_cache[key] = cur
        return cur

    def round(self, S, E):
        """One round from state S with environment outcome E. Returns
        (next state, violation mask, whether the next state is responded)."""
        fl0 = S[8]
        closed = S[7]
        halted = S[5]
        pending = S[6]
        alive, bad, hidden, off, present = E
        new = present & ~S[4]
        MON = self.MON
        nS = self.nS
        has_slow = self.has_slow
        active = alive & ~bad & ~off
        vis = bad & ~hidden
        dead = present & MON & ~alive
        sc = self.sc

        # ---- monitor phase (it reads nothing the work phase writes, so it is computed
        # first whether or not the gate is in place)
        det = [0] * nS
        x = vis
        chk = self.chk
        while x:
            b = x & -x
            x ^= b
            i = b.bit_length() - 1
            det[sc[i]] |= self.inforce('checkers', i, present, new) if has_slow else chk[i]
        x = dead
        hb = self.hb
        while x:
            b = x & -x
            x ^= b
            i = b.bit_length() - 1
            det[sc[i]] |= self.inforce('hb_readers', i, present, new) if has_slow else hb[i]
        fl = [0] * nS
        out = [0] * nS
        good = alive & ~bad
        anyout = 0
        slow_reports = self.slow_reports
        for s in range(nS):
            base = fl0[s]
            cur = base | (det[s] & active)
            if slow_reports:
                x = base & active
                if x:
                    add = 0
                    while x:
                        b = x & -x
                        x ^= b
                        i = b.bit_length() - 1
                        add |= self.inforce('fwd', i, present, new) if has_slow else self.fwd[i]
                    cur |= add & active
            else:
                seed = cur & active
                if seed:
                    cur |= self.closure(seed, active, present, new)
            fl[s] = cur
            o = cur & good
            out[s] = o
            anyout |= o

        # ---- work phase
        if self.gate:
            outw = out
        else:
            outw = [fl0[s] & good for s in range(nS)]
        worked = 0
        newhalt = 0
        halted2 = halted
        pending2 = pending
        x = present & self.NONMON & ~halted
        halt = self.halt
        cover = self.cover
        coupling = self.coupling
        window0 = self.window == 0
        while x:
            b = x & -x
            x ^= b
            if pending & b:
                pending2 ^= b
                halted2 |= b
                continue
            i = b.bit_length() - 1
            hi = self.inforce('halt_inputs', i, present, new) if has_slow else halt[i] & present
            sees = False
            if hi:
                if coupling and hi & ~alive:
                    sees = True
                else:
                    for s in cover[i]:
                        if hi & outw[s]:
                            sees = True
                            break
            if sees:
                newhalt |= b
                if window0:
                    halted2 |= b
                    continue
                pending2 |= b
            worked |= b

        # ---- judgements
        v = 0
        if bad:
            scopemask = self.scopemask
            workmask = self.workmask
            toldmask = self.toldmask
            for s in range(nS):
                if closed >> s & 1:
                    continue
                if bad & scopemask[s]:
                    o = out[s]
                    if not o:
                        v |= 1 << (3 * s)
                    if worked & workmask[s]:
                        v |= 2 << (3 * s)
                    tm = toldmask[s]
                    if tm and tm & good and not tm & o:
                        v |= 4 << (3 * s)
        closed2 = closed
        if self.scoped:
            if newhalt:
                faulty = bad | dead
                covermask = self.covermask
                x = newhalt
                while x:
                    b = x & -x
                    x ^= b
                    if not covermask[b.bit_length() - 1] & faulty:
                        v |= 1 << (3 * nS)
                        break
            if anyout:
                rest = present & ~halted2
                workmask = self.workmask
                for s in range(nS):
                    if out[s] and not closed >> s & 1 and not workmask[s] & rest:
                        closed2 |= 1 << s
        responded = bool(anyout) and not (present & self.NONMON & ~halted2)
        S2 = (alive, bad, hidden, off, present, halted2, pending2, closed2, tuple(fl))
        return S2, v, responded

    # ------------------------------------------------------------------ the result
    def explore(self, max_states=None, max_seconds=None, stats=None):
        nS = self.nS
        NJ = self.NJ
        first = [None] * NJ
        # judgements that can be violated at all (the others are null whatever happens)
        want = 0
        for s in range(nS):
            if self.scopemask[s]:
                want |= 3 << (3 * s)
                if self.toldmask[s]:
                    want |= 4 << (3 * s)
        if self.scoped:
            want |= 1 << (3 * nS)
        found = 0
        init = (self.alive0, 0, 0, 0, self.present0, 0, 0, 0, (0,) * nS)
        visited = {init}
        frontier = [init]
        n = 0
        t0 = time.time()
        rounds_done = 0
        N = self.max_rounds
        done = False
        while frontier and not done:
            n += 1
            if N is not None and n > N:
                break
            nxt = []
            for S in frontier:
                for E in self.env(S):
                    S2, v, responded = self.round(S, E)
                    rounds_done += 1
                    if v & ~found:
                        nv = v & ~found
                        for j in bits(nv):
                            first[j] = n
                        found |= nv
                        if found & want == want:
                            done = True
                            break
                    if S2 not in visited:
                        visited.add(S2)
                        if not responded:
                            nxt.append(S2)
                if done:
                    break
                if max_states is not None and len(visited) > max_states:
                    raise Unfinished('more than %d states (stopped in round %d)' % (max_states, n))
                if max_seconds is not None and time.time() - t0 > max_seconds:
                    raise Unfinished('more than %d seconds (stopped in round %d, %d states)'
                                     % (max_seconds, n, len(visited)))
            frontier = nxt
        if stats is not None:
            stats['states'] = len(visited)
            stats['rounds_evaluated'] = rounds_done
            stats['depth'] = n
            stats['seconds'] = round(time.time() - t0, 2)
        return first

    def answer(self, first):
        nS = self.nS
        if not self.scoped:
            return {'G1': first[0], 'G2': first[1]}

        def least(vals):
            vals = [x for x in vals if x is not None]
            return min(vals) if vals else None
        scopes = {}
        for s, sid in enumerate(self.scope_ids):
            scopes[sid] = {'G1': first[3 * s], 'G2': first[3 * s + 1], 'told': first[3 * s + 2]}
        return {'G1': least(first[3 * s] for s in range(nS)),
                'G2': least(first[3 * s + 1] for s in range(nS)),
                'scopes': scopes, 'spill': first[3 * nS]}


def solve(sysd, readings=(), max_states=None, max_seconds=None, stats=None):
    m = Model(sysd, readings)
    return m.answer(m.explore(max_states, max_seconds, stats))


def _job(args):
    cid, sysd, readings, max_states, max_seconds = args
    stats = {}
    try:
        ans = solve(sysd, readings, max_states, max_seconds, stats)
        return cid, ans, stats, None
    except Unfinished as e:
        return cid, None, stats, str(e)


def main(argv):
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('systems')
    ap.add_argument('answers')
    ap.add_argument('--workers', type=int, default=4)
    ap.add_argument('--reading', action='append', default=[])
    ap.add_argument('--max-states', type=int, default=1500000)
    ap.add_argument('--max-seconds', type=int, default=None)
    ap.add_argument('--only', default=None, help='substring of the ids to run')
    ap.add_argument('--log', default=None)
    a = ap.parse_args(argv)
    cases = json.load(open(a.systems, encoding='utf-8'))
    if a.only:
        cases = [c for c in cases if a.only in c['id']]
    jobs = [(c['id'], c['system'], tuple(a.reading), a.max_states, a.max_seconds) for c in cases]
    results = {}
    log = []
    t0 = time.time()
    if a.workers > 1:
        import multiprocessing as mp
        with mp.Pool(a.workers) as pool:
            it = pool.imap_unordered(_job, jobs, chunksize=1)
            for cid, ans, stats, err in it:
                results[cid] = (ans, err)
                log.append({'id': cid, 'stats': stats, 'error': err})
                print('%7.1fs %s %s %s' % (time.time() - t0, cid, stats, err or ''), flush=True)
    else:
        for j in jobs:
            cid, ans, stats, err = _job(j)
            results[cid] = (ans, err)
            log.append({'id': cid, 'stats': stats, 'error': err})
            print('%7.1fs %s %s %s' % (time.time() - t0, cid, stats, err or ''), flush=True)
    out = []
    unfinished = []
    for c in cases:
        ans, err = results[c['id']]
        if ans is None:
            unfinished.append((c['id'], err))
            continue
        entry = {'id': c['id']}
        entry.update(ans)
        out.append(entry)
    with open(a.answers, 'w', encoding='utf-8') as fh:
        fh.write('[\n' + ',\n'.join(json.dumps(e) for e in out) + '\n]\n')
    if a.log:
        json.dump(log, open(a.log, 'w', encoding='utf-8'), indent=0)
    print('answered %d of %d' % (len(out), len(cases)))
    for cid, err in unfinished:
        print('UNFINISHED', cid, err)


if __name__ == '__main__':
    main(sys.argv[1:])
