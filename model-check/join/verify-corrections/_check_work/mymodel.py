"""Checker's own implementation of model-spec.md + model-spec-join.md (written from the two files).
States are tuples of bit sets. Kept literal to the specification text.
Options alt_* implement alternative readings, used only to test whether a reading could matter."""


class M:
    def __init__(self, s, alt_mutate_alive_only=False, alt_after_alive=False):
        self.s = s
        self.f = s["f"]
        self.mons = list(s["monitors"])
        self.works = list(s["works"])
        self.joiner = s.get("joiner")
        self.names = self.mons + self.works + ([self.joiner] if self.joiner is not None else [])
        assert len(set(self.names)) == len(self.names), "names not distinct"
        self.ix = {n: i for i, n in enumerate(self.names)}
        self.nm = len(self.mons)
        self.MON = (1 << self.nm) - 1
        self.ALLP = (1 << len(self.names)) - 1
        self.coupling = bool(s["coupling"])
        self.window = s["window"]
        self.gate = bool(s.get("gate", True))
        self.slow_reports = bool(s.get("slow_reports", False))
        self.arrive_bad = bool(s.get("arrive_bad", False))
        self.alt_mut = alt_mutate_alive_only
        self.alt_after = alt_after_alive
        n = len(self.names)
        self.rel = {}
        self.slow = {}
        for r in ("hb_readers", "checkers", "fwd", "halt_inputs"):
            a = [0] * n
            for k, v in (s.get(r) or {}).items():
                for m in v:
                    assert m in self.mons, (r, k, m)
                    a[self.ix[k]] |= 1 << self.ix[m]
            self.rel[r] = a
            self.slow[r] = [0] * n
        for (r, k, m) in (s.get("slow_edges") or []):
            assert self.rel[r][self.ix[k]] >> self.ix[m] & 1, "slow edge not an edge"
            self.slow[r][self.ix[k]] |= 1 << self.ix[m]
        self.sw = 0
        for m in (s.get("switches") or []):
            self.sw |= 1 << self.ix[m]
        self.bound = {}
        for m, b in (s.get("boundary") or {}).items():
            if b is None or m not in self.mons:
                continue
            self.bound.setdefault(repr(b), 0)
            self.bound[repr(b)] |= 1 << self.ix[m]
        self.subs = {}
        for p, b in (s.get("substrate") or {}).items():
            if b is None:
                continue
            self.subs.setdefault(repr(b), 0)
            self.subs[repr(b)] |= 1 << self.ix[p]
        self.groups = []
        late = 0
        for g in (s.get("late") or []):
            mem = 0
            for x in g["members"]:
                mem |= 1 << self.ix[x]
            assert mem and not (mem & late)
            late |= mem
            aft = 0
            for x in (g.get("after") or []):
                aft |= 1 << self.ix[x]
            self.groups.append((g["name"], mem, aft))
        self.late = late
        self.jb = (1 << self.ix[self.joiner]) if self.joiner is not None else 0
        present0 = self.ALLP & ~late & ~self.jb
        # state: alive, bad, hidden, off, flagged, halted, pending, present
        self.init = (present0, 0, 0, 0, 0, 0, 0, present0)

    def nm_(self, mask):
        return [self.names[i] for i in range(len(self.names)) if mask >> i & 1]

    def steps(self, st):
        alive, bad, hidden, off, flagged, halted, pending, present = st
        MON = self.MON
        res = []
        for i in range(self.nm):
            b = 1 << i
            if present & b and alive & b:
                res.append(("stop " + self.names[i], (alive & ~b, bad, hidden, off, flagged, halted, pending, present)))
        for bid, mem in self.bound.items():
            pm = mem & present
            if bin(pm).count("1") >= 2 and pm & alive:
                res.append(("stop-boundary " + bid, (alive & ~pm, bad, hidden, off, flagged, halted, pending, present)))
        for sid, mem in self.subs.items():
            pp = mem & present
            if (pp & MON & alive) or (pp & ~MON & ~bad):
                nonm = pp & ~MON
                res.append(("fail-substrate " + sid, (alive & ~(pp & MON), bad | nonm, hidden | nonm, off, flagged, halted, pending, present)))
        for i in range(len(self.names)):
            b = 1 << i
            if present & b and not bad & b:
                if self.alt_mut and (b & MON) and not (alive & b):
                    continue
                res.append(("mutate " + self.names[i], (alive, bad | b, hidden, off, flagged, halted, pending, present)))
        for i in range(self.nm):
            b = 1 << i
            if present & b and self.sw & b and not off & b:
                res.append(("disable " + self.names[i], (alive, bad, hidden, off | b, flagged, halted, pending, present)))
        if self.jb and not (self.jb & self.late) and not (present & self.jb):
            res.append(("join", (alive | self.jb, bad, hidden, off, flagged, halted, pending, present | self.jb)))
        for name, mem, aft in self.groups:
            cond = (aft & present) == aft
            if self.alt_after:
                cond = cond and (aft & MON & ~alive) == 0
            if not (mem & present) and cond:
                st2 = (alive | mem, bad, hidden, off, flagged, halted, pending, present | mem)
                res.append(("join " + name, st2))
                if self.arrive_bad:
                    for i in range(self.nm):
                        b = 1 << i
                        if mem & b:
                            res.append(("join-bad %s %s" % (name, self.names[i]),
                                        (alive | mem, bad | b, hidden, off, flagged, halted, pending, present | mem)))
        return res

    def env(self, st):
        """dict post-env state -> list of step labels (one shortest witness)."""
        seen = {st: []}
        frontier = [st]
        for _ in range(self.f):
            nxt = []
            for a in frontier:
                for lab, b in self.steps(a):
                    if b not in seen:
                        seen[b] = seen[a] + [lab]
                        nxt.append(b)
            frontier = nxt
        return seen

    def inforce(self, r, k, present, new):
        """mask of monitors m such that edge [r, names[k], m] is in force."""
        if not (present >> k & 1):
            return 0
        e = self.rel[r][k] & present
        sl = self.slow[r][k]
        if sl:
            if new >> k & 1:
                e &= ~sl
            else:
                e &= ~(sl & new)
        return e

    def monitor_phase(self, st, new, flagged0):
        alive, bad, hidden, off, flagged, halted, pending, present = st
        MON = self.MON
        active = present & MON & alive & ~bad & ~off
        visible = bad & ~hidden
        for k in range(len(self.names)):
            if visible >> k & 1:
                flagged |= self.inforce("checkers", k, present, new) & active
        for k in range(self.nm):
            if (present >> k & 1) and not (alive >> k & 1):
                flagged |= self.inforce("hb_readers", k, present, new) & active
        if self.slow_reports:
            add = 0
            for k in range(self.nm):
                if (flagged0 & active) >> k & 1:
                    add |= self.inforce("fwd", k, present, new) & active
            flagged |= add
        else:
            changed = True
            while changed:
                changed = False
                for k in range(self.nm):
                    if (flagged & active) >> k & 1:
                        e = self.inforce("fwd", k, present, new) & active
                        if e & ~flagged:
                            flagged |= e
                            changed = True
        return flagged

    def work_phase(self, st, new, out):
        alive, bad, hidden, off, flagged, halted, pending, present = st
        stepped = False
        nh, npd = halted, pending
        for k in range(self.nm, len(self.names)):
            b = 1 << k
            if not (present & b) or (halted & b):
                continue
            if pending & b:
                npd &= ~b
                nh |= b
                continue
            e = self.inforce("halt_inputs", k, present, new)
            sees = bool(e & out) or (self.coupling and bool(e & ~alive))
            if sees and self.window == 0:
                nh |= b
            else:
                if sees:
                    npd |= b
                stepped = True
        return nh, npd, stepped

    def round(self, pre, post):
        """pre: state at start of round; post: state after env phase. -> (state, g1, g2)"""
        alive, bad, hidden, off, flagged, halted, pending, present = post
        new = present & ~pre[7]
        fl0 = pre[4]
        if self.gate:
            fl = self.monitor_phase(post, new, fl0)
            out = fl & alive & ~bad & self.MON
            h, p, stepped = self.work_phase((alive, bad, hidden, off, fl, halted, pending, present), new, out)
        else:
            out0 = flagged & alive & ~bad & self.MON
            h, p, stepped = self.work_phase(post, new, out0)
            fl = self.monitor_phase(post, new, fl0)
            out = fl & alive & ~bad & self.MON
        g1 = bool(bad) and not out
        g2 = bool(bad) and stepped
        return (alive, bad, hidden, off, fl, h, p, present), g1, g2

    def responded(self, st):
        alive, bad, hidden, off, flagged, halted, pending, present = st
        if not (flagged & alive & ~bad & self.MON):
            return False
        return (present & ~self.MON & ~halted) == 0

    def solve(self, anygap=False, limit=None, trace=False):
        """-> dict(G1, G2, states, complete[, t1, t2]). anygap: stop at first violation of either goal."""
        g1 = g2 = None
        t1 = t2 = None
        par = {self.init: None}
        frontier = [self.init]
        n = 0
        complete = True
        stop = False
        while frontier and (g1 is None or g2 is None) and not stop:
            n += 1
            nxt = []
            for a in frontier:
                for post, labs in self.env(a).items():
                    b, v1, v2 = self.round(a, post)
                    if v1 and g1 is None:
                        g1 = n
                        t1 = (a, labs, b)
                    if v2 and g2 is None:
                        g2 = n
                        t2 = (a, labs, b)
                    if b not in par:
                        par[b] = (a, labs)
                        if not self.responded(b):
                            nxt.append(b)
                if anygap and (g1 is not None or g2 is not None):
                    stop = True
                    break
                if limit is not None and len(par) > limit:
                    complete = False
                    stop = True
                    break
            frontier = nxt
        res = {"G1": g1, "G2": g2, "states": len(par), "complete": complete}
        if trace:
            res["t1"] = self.mk_trace(par, t1) if t1 else None
            res["t2"] = self.mk_trace(par, t2) if t2 else None
        return res

    def mk_trace(self, par, t):
        a, labs, b = t
        rounds = [(labs, b)]
        cur = a
        while par[cur] is not None:
            p, l = par[cur]
            rounds.append((l, cur))
            cur = p
        rounds.reverse()
        return [(l, self.describe(s)) for l, s in rounds]

    def describe(self, st):
        alive, bad, hidden, off, flagged, halted, pending, present = st
        d = []
        d.append(("bad=" + ",".join(self.nm_(bad))) if bad else "nothing bad")
        stopped = present & self.MON & ~alive
        if stopped:
            d.append("stopped=" + ",".join(self.nm_(stopped)))
        if off:
            d.append("off=" + ",".join(self.nm_(off)))
        d.append(("flagged=" + ",".join(self.nm_(flagged))) if flagged else "nothing flagged")
        if halted:
            d.append("halted=" + ",".join(self.nm_(halted)))
        working = present & ~self.MON & ~halted
        d.append(("working=" + ",".join(self.nm_(working))) if working else "no work process working")
        return "; ".join(d)

    def replay(self, rounds):
        """rounds: list of lists of step labels -> list of (labels, description, g1, g2, responded)."""
        st = self.init
        res = []
        for labs in rounds:
            assert not self.responded(st), "round would start from a responded state"
            cur = st
            assert len(labs) <= self.f
            for lab in labs:
                opts = dict(self.steps(cur))
                assert lab in opts, "step not enabled: " + lab
                cur = opts[lab]
            nst, v1, v2 = self.round(st, cur)
            res.append((labs, self.describe(nst), v1, v2, self.responded(nst)))
            st = nst
        return res


def fmt(r):
    def x(v):
        return "null" if v is None else str(v)
    return "%s/%s" % (x(r["G1"]), x(r["G2"]))


def show_trace(tr):
    for i, (labs, d) in enumerate(tr, 1):
        print("   | %d | %s | %s |" % (i, ", ".join(labs) if labs else "(no step)", d))
