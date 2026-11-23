# Independent decider written from model-spec.md and model-spec-join.md only.
# A system is a dict as in the two specification files.

RELS = ("hb_readers", "checkers", "fwd", "halt_inputs")


class Model:
    def __init__(self, s):
        self.s = s
        self.f = s["f"]
        mons = list(s["monitors"])
        works = list(s.get("works", []))
        joiner = s.get("joiner")
        names = mons + works + ([joiner] if joiner is not None else [])
        assert len(set(names)) == len(names), names
        self.names = names
        self.idx = {n: i for i, n in enumerate(names)}
        idx = self.idx
        self.nm = len(mons)
        self.monmask = (1 << self.nm) - 1
        self.nonmon = [idx[w] for w in works] + ([idx[joiner]] if joiner is not None else [])
        self.joiner = idx[joiner] if joiner is not None else None
        self.coupling = bool(s.get("coupling", False))
        self.window = int(s.get("window", 0))
        self.gate = bool(s.get("gate", True))
        self.slow_reports = bool(s.get("slow_reports", False))
        self.arrive_bad = bool(s.get("arrive_bad", False))
        self.boundary = {idx[m]: b for m, b in s.get("boundary", {}).items()}
        self.substrate = {idx[p]: b for p, b in s.get("substrate", {}).items()}
        self.switches = [idx[m] for m in s.get("switches", [])]
        # groups
        self.groups = []
        member_of = {}
        for gi, g in enumerate(s.get("late", []) or []):
            mem = [idx[x] for x in g["members"]]
            aft = 0
            for x in g.get("after", []) or []:
                aft |= 1 << idx[x]
            mm = 0
            for x in mem:
                assert x not in member_of
                member_of[x] = gi
                mm |= 1 << x
            self.groups.append((mm, aft, mem))
        self.member_of = member_of
        self.joiner_in_group = self.joiner is not None and self.joiner in member_of
        init_present = 0
        for i in range(self.nm):
            if i not in member_of:
                init_present |= 1 << i
        for w in works:
            init_present |= 1 << idx[w]
        self.init_present = init_present
        # edges
        slow = set()
        for e in s.get("slow_edges", []) or []:
            rel, key, mon = e
            assert mon in s.get(rel, {}).get(key, []), e
            slow.add((rel, idx[key], idx[mon]))
        self.edges = []
        for rel in RELS:
            for key, lst in (s.get(rel, {}) or {}).items():
                for mon in lst:
                    k, m = idx[key], idx[mon]
                    self.edges.append((rel, k, m, (rel, k, m) in slow))
        self.has_slow = bool(slow)
        self._adj = {}
        self._present = {}
        # boundaries with their monitor masks
        self.bmask = {}
        for m, b in self.boundary.items():
            self.bmask[b] = self.bmask.get(b, 0) | (1 << m)
        self.smask = {}
        for p, sb in self.substrate.items():
            self.smask[sb] = self.smask.get(sb, 0) | (1 << p)

    # ---------------------------------------------------------------
    def present(self, joined, arrived):
        key = (joined, arrived)
        r = self._present.get(key)
        if r is None:
            r = self.init_present
            for gi, (mm, aft, mem) in enumerate(self.groups):
                if arrived >> gi & 1:
                    r |= mm
            if joined and self.joiner is not None:
                r |= 1 << self.joiner
            self._present[key] = r
        return r

    def adj(self, present, new):
        if not self.has_slow:
            new = 0
        key = (present, new)
        a = self._adj.get(key)
        if a is None:
            n = len(self.names)
            chk_by = [0] * n   # chk_by[m]: processes whose state m checks
            hbr_by = [0] * n   # hbr_by[m]: monitors whose signal m reads
            fwd = [0] * n      # fwd[m]: monitors m reports to
            halt = [0] * n     # halt[w]: monitors w takes its halt from
            for rel, k, m, sl in self.edges:
                if not (present >> k & 1 and present >> m & 1):
                    continue
                if sl and ((new >> k & 1) or (new >> m & 1)):
                    continue
                if rel == "checkers":
                    chk_by[m] |= 1 << k
                elif rel == "hb_readers":
                    hbr_by[m] |= 1 << k
                elif rel == "fwd":
                    fwd[k] |= 1 << m
                else:
                    halt[k] |= 1 << m
            a = (chk_by, hbr_by, fwd, halt)
            self._adj[key] = a
        return a

    def initial(self):
        alive = self.init_present
        # (alive, bad, hidden, off, flagged, halted, pending, joined, arrived)
        return (alive, 0, 0, 0, 0, 0, 0, False, 0)

    # ---------------------------------------------------------------
    def env_steps(self, st):
        """Yield (label, state, newly_present_mask) for every enabled step."""
        alive, bad, hidden, off, flagged, halted, pending, joined, arrived = st
        pres = self.present(joined, arrived)
        pm = pres & self.monmask
        names = self.names
        # stop
        x = pm & alive
        i = 0
        while x:
            if x & 1:
                yield ("stop " + names[i], (alive & ~(1 << i), bad, hidden, off, flagged, halted, pending, joined, arrived), 0)
            x >>= 1
            i += 1
        # stop-boundary
        for b, bm in self.bmask.items():
            pb = bm & pm
            if bin(pb).count("1") >= 2 and (pb & alive):
                yield ("stop-boundary " + str(b), (alive & ~pb, bad, hidden, off, flagged, halted, pending, joined, arrived), 0)
        # fail-substrate
        for sb, sm in self.smask.items():
            ps = sm & pres
            mon_part = ps & self.monmask
            non_part = ps & ~self.monmask
            if (mon_part & alive) or (non_part & ~bad):
                yield ("fail-substrate " + str(sb), (alive & ~mon_part, bad | non_part, hidden | non_part, off, flagged, halted, pending, joined, arrived), 0)
        # mutate
        x = pres & ~bad
        i = 0
        while x:
            if x & 1:
                yield ("mutate " + names[i], (alive, bad | (1 << i), hidden, off, flagged, halted, pending, joined, arrived), 0)
            x >>= 1
            i += 1
        # disable
        for m in self.switches:
            if (pres >> m & 1) and not (off >> m & 1):
                yield ("disable " + names[m], (alive, bad, hidden, off | (1 << m), flagged, halted, pending, joined, arrived), 0)
        # join (the joiner's own step)
        if self.joiner is not None and not self.joiner_in_group and not joined:
            jb = 1 << self.joiner
            yield ("join", (alive | jb, bad, hidden, off, flagged, halted, pending, True, arrived), jb)
        # join g, join-bad g m
        for gi, (mm, aft, mem) in enumerate(self.groups):
            if arrived >> gi & 1:
                continue
            if aft & ~pres:
                continue
            j2 = joined or (self.joiner is not None and (mm >> self.joiner & 1) != 0)
            gname = self.s["late"][gi]["name"]
            yield ("join " + gname, (alive | mm, bad, hidden, off, flagged, halted, pending, j2, arrived | (1 << gi)), mm)
            if self.arrive_bad:
                for m in mem:
                    if m < self.nm:
                        yield ("join-bad " + gname + " " + names[m], (alive | mm, bad | (1 << m), hidden, off, flagged, halted, pending, j2, arrived | (1 << gi)), mm)

    def env_closure(self, st, want_paths=False):
        """All (state, new) reachable by 0..f steps. Returns dict -> path (tuple of labels)."""
        seen = {(st, 0): ()}
        frontier = [(st, 0)]
        for _ in range(self.f):
            nxt = []
            for (s0, new0) in frontier:
                p0 = seen[(s0, new0)]
                for lab, s1, nw in self.env_steps(s0):
                    key = (s1, new0 | nw)
                    if key not in seen:
                        seen[key] = p0 + (lab,) if want_paths else True
                        nxt.append(key)
            frontier = nxt
            if not frontier:
                break
        return seen

    # ---------------------------------------------------------------
    def monitor_phase(self, alive, bad, hidden, off, flagged, pres, A):
        chk_by, hbr_by, fwd, halt = A
        pm = pres & self.monmask
        active = pm & alive & ~bad & ~off
        visible = bad & ~hidden
        silent = pm & ~alive
        start_flagged = flagged
        x = active
        i = 0
        while x:
            if x & 1:
                if (chk_by[i] & visible) or (hbr_by[i] & silent):
                    flagged |= 1 << i
            x >>= 1
            i += 1
        if self.slow_reports:
            src = start_flagged & active
            add = 0
            i = 0
            while src:
                if src & 1:
                    add |= fwd[i] & active
                src >>= 1
                i += 1
            flagged |= add
        else:
            changed = True
            while changed:
                changed = False
                src = flagged & active
                i = 0
                while src:
                    if src & 1:
                        t = fwd[i] & active & ~flagged
                        if t:
                            flagged |= t
                            changed = True
                    src >>= 1
                    i += 1
        out = flagged & alive & ~bad & self.monmask
        return flagged, out

    def work_phase(self, alive, out, halted, pending, pres, A):
        halt = A[3]
        worked = 0
        for w in self.nonmon:
            if not (pres >> w & 1) or (halted >> w & 1):
                continue
            if pending >> w & 1:
                pending &= ~(1 << w)
                halted |= 1 << w
                continue
            sees = bool(halt[w] & out) or (self.coupling and bool(halt[w] & ~alive))
            if sees and self.window == 0:
                halted |= 1 << w
            else:
                if sees:
                    pending |= 1 << w
                worked |= 1 << w
        return halted, pending, worked

    def finish_round(self, st, new):
        """st is the state after the environment phase. Returns (state, g1_violated, g2_violated, out, worked)."""
        alive, bad, hidden, off, flagged, halted, pending, joined, arrived = st
        pres = self.present(joined, arrived)
        A = self.adj(pres, new)
        if self.gate:
            flagged, out = self.monitor_phase(alive, bad, hidden, off, flagged, pres, A)
            halted, pending, worked = self.work_phase(alive, out, halted, pending, pres, A)
        else:
            out0 = flagged & alive & ~bad & self.monmask
            halted, pending, worked = self.work_phase(alive, out0, halted, pending, pres, A)
            flagged, out = self.monitor_phase(alive, bad, hidden, off, flagged, pres, A)
        g1 = bool(bad) and not out
        g2 = bool(bad) and bool(worked)
        return (alive, bad, hidden, off, flagged, halted, pending, joined, arrived), g1, g2, out, worked

    def responded(self, st):
        alive, bad, hidden, off, flagged, halted, pending, joined, arrived = st
        if not (flagged & alive & ~bad & self.monmask):
            return False
        pres = self.present(joined, arrived)
        for w in self.nonmon:
            if (pres >> w & 1) and not (halted >> w & 1):
                return False
        return True

    # ---------------------------------------------------------------
    def solve(self, trace=False, max_states=2_000_000):
        """Least number of rounds to violate G1, G2 (None if never). Also number of states at round ends."""
        init = self.initial()
        seen = {init: None}
        frontier = [init]
        G1 = G2 = None
        t1 = t2 = None
        n = 0
        while frontier:
            n += 1
            nxt = []
            for st in frontier:
                if self.responded(st):
                    continue
                for (s1, new), path in self.env_closure(st, want_paths=trace).items():
                    s2, g1, g2, out, worked = self.finish_round(s1, new)
                    if g1 and G1 is None:
                        G1 = n
                        t1 = (st, path)
                    if g2 and G2 is None:
                        G2 = n
                        t2 = (st, path)
                    if s2 not in seen:
                        seen[s2] = (st, path) if trace else None
                        nxt.append(s2)
                        if len(seen) > max_states:
                            raise RuntimeError("too many states")
            frontier = nxt
        self.nstates = len(seen)
        if trace:
            return G1, G2, self._trace(seen, t1), self._trace(seen, t2)
        return G1, G2

    def gap(self, max_states=2_000_000):
        """True as soon as some execution violates G1 or G2; False if none does."""
        init = self.initial()
        seen = {init}
        frontier = [init]
        while frontier:
            nxt = []
            for st in frontier:
                if self.responded(st):
                    continue
                for (s1, new) in self.env_closure(st):
                    s2, g1, g2, out, worked = self.finish_round(s1, new)
                    if g1 or g2:
                        return True
                    if s2 not in seen:
                        seen.add(s2)
                        nxt.append(s2)
                        if len(seen) > max_states:
                            raise RuntimeError("too many states")
            frontier = nxt
        self.nstates = len(seen)
        return False

    def _trace(self, seen, t):
        if t is None:
            return None
        st, path = t
        rounds = [path]
        while seen[st] is not None:
            st, path = seen[st]
            rounds.append(path)
        rounds.reverse()
        return rounds

    # ---------------------------------------------------------------
    def replay(self, rounds):
        """rounds: list of lists of step labels. Returns a list of per-round descriptions; raises if a step is not enabled."""
        st = self.initial()
        outp = []
        for rn, steps in enumerate(rounds, 1):
            if self.responded(st):
                raise RuntimeError("round %d starts from a responded state" % rn)
            if len(steps) > self.f:
                raise RuntimeError("round %d has more than f steps" % rn)
            new = 0
            for lab in steps:
                for l2, s1, nw in self.env_steps(st):
                    if l2 == lab:
                        st = s1
                        new |= nw
                        break
                else:
                    raise RuntimeError("round %d: step %r not enabled; enabled: %s" % (rn, lab, sorted(l for l, _, _ in self.env_steps(st))))
            st, g1, g2, out, worked = self.finish_round(st, new)
            outp.append(dict(round=rn, steps=list(steps), G1_violated=g1, G2_violated=g2,
                             bad=self.nm_names(st[1]), stopped=self.nm_names(self.present(st[7], st[8]) & self.monmask & ~st[0]),
                             flagged=self.nm_names(st[4]), out=self.nm_names(out),
                             halted=self.nm_names(st[5]), worked=self.nm_names(worked), responded=self.responded(st)))
        return outp

    def nm_names(self, mask):
        return [self.names[i] for i in range(len(self.names)) if mask >> i & 1]

    def complete_response_every_fault_round(self):
        """From the initial state: does every non-empty environment phase end in a responded state?
        (For a system with nothing joining.)"""
        init = self.initial()
        for (s1, new) in self.env_closure(init):
            if s1 == init:
                continue
            s2, g1, g2, out, worked = self.finish_round(s1, new)
            if g1 or g2 or not self.responded(s2):
                return False
        return True


def solve(s, **kw):
    return Model(s).solve(**kw)


def with_f(s, f):
    t = dict(s)
    t["f"] = f
    return t


def fmt(r):
    g1, g2 = r[0], r[1]
    if g1 is None and g2 is None:
        return "no gap"
    return "%s/%s" % ("-" if g1 is None else g1, "-" if g2 is None else g2)
