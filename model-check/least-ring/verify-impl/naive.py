"""A second, slow, literal transcription of the three specification files, with sets of
names instead of bit masks and separate code for a system that is not scoped (sections
3.2 to 3.5 with J6) and for a scoped one (X4 to X8). It exists only to cross-check
model.py: both are mine, written from the specification.

Usage: python naive.py systems-minimal.json out.json [--workers N] [--max-seconds S]
"""
import json
import sys
import time
from collections import namedtuple

St = namedtuple('St', 'alive bad hidden off flagged halted pending joined arrived closed')
F = frozenset


class Sys:
    def __init__(self, d):
        self.monitors = list(d['monitors'])
        self.monset = set(self.monitors)
        self.works = list(d['works'])
        self.joiner = d.get('joiner')
        self.nonmon = self.works + ([self.joiner] if self.joiner is not None else [])
        self.procs = self.monitors + self.nonmon
        self.f = d['f']
        self.boundary = {m: b for m, b in (d.get('boundary') or {}).items() if b is not None}
        self.substrate = {p: s for p, s in (d.get('substrate') or {}).items() if s is not None}
        self.rel = {k: {x: list(v) for x, v in (d.get(k) or {}).items()}
                    for k in ('hb_readers', 'checkers', 'fwd', 'halt_inputs')}
        self.switches = list(d.get('switches') or [])
        self.coupling = d.get('coupling', False)
        self.window = d.get('window', 0)
        self.gate = d.get('gate', True)
        self.slow_reports = d.get('slow_reports', False)
        self.groups = {g['name']: g for g in (d.get('late') or [])}
        self.late = set()
        for g in self.groups.values():
            self.late |= set(g['members'])
        self.arrive_bad = d.get('arrive_bad', False)
        self.slow_edges = set(tuple(e) for e in (d.get('slow_edges') or []))
        self.scope = d.get('scope') or {}
        self.scoped = bool(self.scope)
        self.max_rounds = d.get('max_rounds')
        if self.scoped:
            sw = d.get('scope_work') or {}
            told = d.get('told') or {}
            ids = []
            for s in list(self.scope.values()) + list(sw) + list(told):
                if s not in ids:
                    ids.append(s)
            self.scopes = ids
            self.work = {s: (list(sw[s]) if s in sw else
                             [w for w in self.nonmon if self.scope[w] == s]) for s in ids}
            self.told = {s: list(told.get(s, [])) for s in ids}
            self.freeze = d.get('freeze', False)
        else:
            self.freeze = False

    # J2
    def present(self, st):
        p = set(x for x in self.monitors + self.works if x not in self.late)
        for g in st.arrived:
            p |= set(self.groups[g]['members'])
        if st.joined:
            p.add(self.joiner)
        return p

    def initial(self):
        alive = F(x for x in self.monitors + self.works if x not in self.late)
        return St(alive, F(), F(), F(), F(), F(), F(), False, F(), F())

    # 3.1 / J4 / X7
    def steps(self, st):
        pres = self.present(st)
        frozen = set()
        if self.freeze:
            frozen = set(p for p in self.procs if self.scope[p] in st.closed)
        res = []
        for m in self.monitors:
            if m in pres and m in st.alive and m not in frozen:
                res.append(st._replace(alive=st.alive - {m}))
        for b in set(self.boundary.values()):
            mons = [m for m in self.monitors if m in pres and self.boundary.get(m) == b]
            if len(mons) >= 2 and any(m in st.alive and m not in frozen for m in mons):
                res.append(st._replace(alive=st.alive - set(m for m in mons if m not in frozen)))
        for s in set(self.substrate.values()):
            ps = [p for p in self.procs if p in pres and self.substrate.get(p) == s and p not in frozen]
            if any((p in self.monset and p in st.alive) or (p not in self.monset and p not in st.bad)
                   for p in ps):
                mon = set(p for p in ps if p in self.monset)
                non = set(p for p in ps if p not in self.monset)
                res.append(st._replace(alive=st.alive - mon, bad=st.bad | non, hidden=st.hidden | non))
        for p in self.procs:
            if p in pres and p not in st.bad and p not in frozen:
                res.append(st._replace(bad=st.bad | {p}))
        for m in self.switches:
            if m in pres and m not in st.off and m not in frozen:
                res.append(st._replace(off=st.off | {m}))
        if (self.joiner is not None and self.joiner not in self.late and not st.joined
                and self.joiner not in frozen):
            res.append(st._replace(joined=True, alive=st.alive | {self.joiner}))
        for name, g in self.groups.items():
            if name in st.arrived:
                continue
            if not all(a in pres for a in (g.get('after') or [])):
                continue
            if any(m in frozen for m in g['members']):
                continue
            st2 = st._replace(arrived=st.arrived | {name}, alive=st.alive | set(g['members']),
                              joined=st.joined or (self.joiner in g['members']))
            res.append(st2)
            if self.arrive_bad:
                for m in g['members']:
                    if m in self.monset:
                        res.append(st2._replace(bad=st2.bad | {m}))
        return res

    def env(self, st):
        seen = {st}
        level = [st]
        for _ in range(self.f):
            nxt = []
            for e in level:
                for t in self.steps(e):
                    if t not in seen:
                        seen.add(t)
                        nxt.append(t)
            level = nxt
        return seen

    # one round
    def round(self, st0, st):
        """st0: the state at the start of the round; st: after the environment phase.
        Returns (next state, set of violated judgements)."""
        pres = self.present(st)
        new = pres - self.present(st0)

        def inforce(relname, key, mon):
            if mon not in self.rel[relname].get(key, []):
                return False
            if key not in pres or mon not in pres:
                return False
            if (relname, key, mon) in self.slow_edges and (key in new or mon in new):
                return False
            return True

        active = set(m for m in self.monitors
                     if m in pres and m in st.alive and m not in st.bad and m not in st.off)
        visible = st.bad - st.hidden
        dead = [p for p in self.monitors if p in pres and p not in st.alive]
        viol = set()

        if not self.scoped:
            def out_of(flagged):
                return set(m for m in flagged if m in st.alive and m not in st.bad)

            def monitor_phase(flagged):
                flagged = set(flagged)
                start = set(flagged)
                for m in active:
                    if any(inforce('checkers', x, m) for x in visible) or \
                            any(inforce('hb_readers', p, m) for p in dead):
                        flagged.add(m)
                if self.slow_reports:
                    for m in start:
                        if m in active:
                            for r in self.rel['fwd'].get(m, []):
                                if r in active and inforce('fwd', m, r):
                                    flagged.add(r)
                else:
                    changed = True
                    while changed:
                        changed = False
                        for m in list(flagged):
                            if m in active:
                                for r in self.rel['fwd'].get(m, []):
                                    if r in active and inforce('fwd', m, r) and r not in flagged:
                                        flagged.add(r)
                                        changed = True
                return flagged

            def work_phase(out):
                halted = set(st.halted)
                pending = set(st.pending)
                stepped = set()
                for w in self.nonmon:
                    if w not in pres or w in st.halted:
                        continue
                    if w in st.pending:
                        pending.discard(w)
                        halted.add(w)
                        continue
                    ins = [m for m in self.rel['halt_inputs'].get(w, []) if inforce('halt_inputs', w, m)]
                    sees = any(m in out for m in ins) or \
                        (self.coupling and any(m not in st.alive for m in ins))
                    if sees and self.window == 0:
                        halted.add(w)
                        continue
                    if sees:
                        pending.add(w)
                    stepped.add(w)
                return halted, pending, stepped

            if self.gate:
                flagged = monitor_phase(st.flagged)
                out = out_of(flagged)
                halted, pending, stepped = work_phase(out)
            else:
                halted, pending, stepped = work_phase(out_of(st.flagged))
                flagged = monitor_phase(st.flagged)
                out = out_of(flagged)
            if st.bad and not out:
                viol.add('G1')
            if st.bad and stepped:
                viol.add('G2')
            return st._replace(flagged=F(flagged), halted=F(halted), pending=F(pending)), viol

        # ---- scoped: X4 to X7
        scope = self.scope

        def out_of(flagged):
            return {s: set(m for (m, t) in flagged if t == s and m in st.alive and m not in st.bad)
                    for s in self.scopes}

        def monitor_phase(flagged):
            flagged = set(flagged)
            start = set(flagged)
            for m in active:
                for x in visible:
                    if inforce('checkers', x, m):
                        flagged.add((m, scope[x]))
                for p in dead:
                    if inforce('hb_readers', p, m):
                        flagged.add((m, scope[p]))
            if self.slow_reports:
                for (m, s) in start:
                    if m in active:
                        for r in self.rel['fwd'].get(m, []):
                            if r in active and inforce('fwd', m, r):
                                flagged.add((r, s))
            else:
                changed = True
                while changed:
                    changed = False
                    for (m, s) in list(flagged):
                        if m in active:
                            for r in self.rel['fwd'].get(m, []):
                                if r in active and inforce('fwd', m, r) and (r, s) not in flagged:
                                    flagged.add((r, s))
                                    changed = True
            return flagged

        def work_phase(out):
            halted = set(st.halted)
            pending = set(st.pending)
            stepped = set()
            for w in self.nonmon:
                if w not in pres or w in st.halted:
                    continue
                if w in st.pending:
                    pending.discard(w)
                    halted.add(w)
                    continue
                ins = [m for m in self.rel['halt_inputs'].get(w, []) if inforce('halt_inputs', w, m)]
                sees = any(m in out[s] for m in ins for s in self.scopes if w in self.work[s]) or \
                    (self.coupling and any(m not in st.alive for m in ins))
                if sees and self.window == 0:
                    halted.add(w)
                    continue
                if sees:
                    pending.add(w)
                stepped.add(w)
            return halted, pending, stepped

        if self.gate:
            flagged = monitor_phase(st.flagged)
            out = out_of(flagged)
            halted, pending, stepped = work_phase(out)
        else:
            halted, pending, stepped = work_phase(out_of(st.flagged))
            flagged = monitor_phase(st.flagged)
            out = out_of(flagged)
        for s in self.scopes:
            if s in st.closed:
                continue
            anybad = any(scope[p] == s for p in st.bad)
            if anybad and not out[s]:
                viol.add(('G1', s))
            if anybad and any(w in stepped for w in self.work[s]):
                viol.add(('G2', s))
            if anybad and any(m in st.alive and m not in st.bad for m in self.told[s]) and \
                    not any(m in out[s] for m in self.told[s]):
                viol.add(('told', s))
        faulty = set(st.bad) | set(dead)
        for w in self.nonmon:
            before = w in st.halted or w in st.pending
            after = w in halted or w in pending
            if not before and after:
                covering = [s for s in self.scopes if w in self.work[s]]
                if not any(scope[p] in covering for p in faulty):
                    viol.add('spill')
        closed = set(st.closed)
        for s in self.scopes:
            if s not in closed and out[s] and all(w in halted for w in self.work[s] if w in pres):
                closed.add(s)
        return st._replace(flagged=F(flagged), halted=F(halted), pending=F(pending),
                           closed=F(closed)), viol

    def responded(self, st):
        pres = self.present(st)
        if self.scoped:
            holder = any(m in st.alive and m not in st.bad for (m, s) in st.flagged)
        else:
            holder = any(m in st.alive and m not in st.bad for m in st.flagged)
        return holder and all(w in st.halted for w in self.nonmon if w in pres)

    # A state is kept in the visited set and in the frontier as one integer (the sets
    # written as bit fields), only to save memory. The rounds work on the sets of names.
    def _tables(self):
        self._pi = {p: i for i, p in enumerate(self.procs)}
        self._gn = list(self.groups)
        self._sn = list(self.scopes) if self.scoped else []
        if self.scoped:
            self._fl = [(m, s) for s in self.scopes for m in self.monitors]
        else:
            self._fl = list(self.monitors)
        self._fi = {x: i for i, x in enumerate(self._fl)}

    def encode(self, st):
        P = len(self.procs)
        k = 0
        for part in (st.alive, st.bad, st.hidden, st.off, st.halted, st.pending):
            v = 0
            for p in part:
                v |= 1 << self._pi[p]
            k = (k << P) | v
        v = 0
        for x in st.flagged:
            v |= 1 << self._fi[x]
        k = (k << len(self._fl)) | v
        v = 0
        for g in st.arrived:
            v |= 1 << self._gn.index(g)
        k = (k << len(self._gn)) | v
        v = 0
        for s in st.closed:
            v |= 1 << self._sn.index(s)
        k = (k << len(self._sn)) | v
        return (k << 1) | (1 if st.joined else 0)

    def decode(self, k):
        P = len(self.procs)
        joined = bool(k & 1)
        k >>= 1

        def take(names):
            nonlocal k
            n = len(names)
            v = k & ((1 << n) - 1)
            k >>= n
            return F(names[i] for i in range(n) if v >> i & 1)
        closed = take(self._sn)
        arrived = take(self._gn)
        flagged = take(self._fl)
        pending = take(self.procs)
        halted = take(self.procs)
        off = take(self.procs)
        hidden = take(self.procs)
        bad = take(self.procs)
        alive = take(self.procs)
        return St(alive, bad, hidden, off, flagged, halted, pending, joined, arrived, closed)

    def result(self, max_seconds=None):
        self._tables()
        first = {}
        init = self.initial()
        assert self.decode(self.encode(init)) == init
        visited = {self.encode(init)}
        frontier = [self.encode(init)]
        n = 0
        t0 = time.time()
        while frontier:
            n += 1
            if self.max_rounds is not None and n > self.max_rounds:
                break
            nxt = []
            for k0 in frontier:
                s0 = self.decode(k0)
                if self.responded(s0):
                    continue
                for e in self.env(s0):
                    s2, viol = self.round(s0, e)
                    for v in viol:
                        if v not in first:
                            first[v] = n
                    k2 = self.encode(s2)
                    if k2 not in visited:
                        visited.add(k2)
                        nxt.append(k2)
                if max_seconds is not None and time.time() - t0 > max_seconds:
                    return None
            frontier = nxt
        if not self.scoped:
            return {'G1': first.get('G1'), 'G2': first.get('G2')}

        def least(k):
            v = [first[(k, s)] for s in self.scopes if (k, s) in first]
            return min(v) if v else None
        return {'G1': least('G1'), 'G2': least('G2'),
                'scopes': {s: {'G1': first.get(('G1', s)), 'G2': first.get(('G2', s)),
                               'told': first.get(('told', s))} for s in self.scopes},
                'spill': first.get('spill')}


def _job(a):
    cid, d, max_seconds = a
    t0 = time.time()
    r = Sys(d).result(max_seconds)
    return cid, r, time.time() - t0


def main(argv):
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('systems')
    ap.add_argument('out')
    ap.add_argument('--workers', type=int, default=4)
    ap.add_argument('--max-seconds', type=int, default=None)
    ap.add_argument('--only', default=None)
    ap.add_argument('--ids', default=None, help='a JSON file with the list of ids to run')
    a = ap.parse_args(argv)
    cases = json.load(open(a.systems, encoding='utf-8'))
    if a.only:
        cases = [c for c in cases if a.only in c['id']]
    if a.ids:
        keep = set(json.load(open(a.ids, encoding='utf-8')))
        cases = [c for c in cases if c['id'] in keep]
    jobs = [(c['id'], c['system'], a.max_seconds) for c in cases]
    res = {}
    import multiprocessing as mp
    t0 = time.time()
    with mp.Pool(a.workers) as pool:
        for cid, r, dt in pool.imap_unordered(_job, jobs, chunksize=1):
            res[cid] = r
            print('%7.1fs %6.1fs %s %s' % (time.time() - t0, dt, cid, 'UNFINISHED' if r is None else ''),
                  flush=True)
    out = []
    for c in cases:
        e = {'id': c['id']}
        if res[c['id']] is None:
            e['unfinished'] = True
        else:
            e.update(res[c['id']])
        out.append(e)
    with open(a.out, 'w', encoding='utf-8') as fh:
        fh.write('[\n' + ',\n'.join(json.dumps(e) for e in out) + '\n]\n')


if __name__ == '__main__':
    main(sys.argv[1:])
