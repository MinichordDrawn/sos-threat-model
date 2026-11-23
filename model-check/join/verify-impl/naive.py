"""A second, deliberately plain implementation of the same two specification
files, by the same author as model.py, used only to cross-check model.py
(names and Python sets instead of bit masks, edges tested one by one with an
explicit in-force predicate, groups tracked by name).  It can also print a
shortest witness execution.

It shares model.py's readings of the specification; it guards against coding
slips, not against a wrong reading.
"""
import json
import sys
from collections import namedtuple

S = namedtuple("S", "alive bad hidden off flagged halted pending joined arrived")
FZ = frozenset


class Naive:
    def __init__(self, s):
        self.s = s
        self.f = s["f"]
        self.monitors = list(s["monitors"])
        self.works = list(s["works"])
        self.joiner = s.get("joiner")
        self.boundary = {k: v for k, v in (s.get("boundary") or {}).items()}
        self.substrate = {k: v for k, v in (s.get("substrate") or {}).items()}
        self.rel = {r: {k: list(v) for k, v in (s.get(r) or {}).items()}
                    for r in ("hb_readers", "checkers", "fwd", "halt_inputs")}
        self.switches = list(s.get("switches") or [])
        self.coupling = s["coupling"]
        self.window = s["window"]
        self.gate = s.get("gate", True)
        self.slow_reports = s.get("slow_reports", False)
        self.groups = {g["name"]: g for g in (s.get("late") or [])}
        self.arrive_bad = s.get("arrive_bad", False)
        self.slow_edges = set(tuple(e) for e in (s.get("slow_edges") or []))
        self.group_of = {}
        for g in self.groups.values():
            for m in g["members"]:
                self.group_of[m] = g["name"]
        self.late_monitors = [m for m in self.monitors if m in self.group_of]
        self.initial_monitors = [m for m in self.monitors if m not in self.group_of]
        self.init = S(FZ(self.initial_monitors + self.works), FZ(), FZ(), FZ(), FZ(),
                      FZ(), FZ(), False, FZ())

    # J2
    def present(self, st):
        p = set(self.initial_monitors) | set(self.works)
        for g in st.arrived:
            p |= set(self.groups[g]["members"])
        if self.joiner is not None and st.joined:
            p.add(self.joiner)
        return p

    def is_monitor(self, p):
        return p in self.monitors

    # J4
    def steps(self, st):
        pres = self.present(st)
        res = []
        for m in self.monitors:
            if m in pres and m in st.alive:
                res.append((("stop", m), st._replace(alive=st.alive - {m})))
        for b in sorted(set(json.dumps(v) for v in self.boundary.values())):
            mem = [m for m in self.monitors if m in pres and m in self.boundary
                   and json.dumps(self.boundary[m]) == b]
            if len(mem) >= 2 and any(m in st.alive for m in mem):
                res.append((("stop-boundary", b), st._replace(alive=st.alive - set(mem))))
        for sub in sorted(set(json.dumps(v) for v in self.substrate.values())):
            mem = [p for p in pres if p in self.substrate and json.dumps(self.substrate[p]) == sub]
            if any((self.is_monitor(p) and p in st.alive) or
                   (not self.is_monitor(p) and p not in st.bad) for p in mem):
                mons = set(p for p in mem if self.is_monitor(p))
                non = set(p for p in mem if not self.is_monitor(p))
                res.append((("fail-substrate", sub), st._replace(
                    alive=st.alive - mons, bad=st.bad | non, hidden=st.hidden | non)))
        for p in sorted(pres):
            if p not in st.bad:
                res.append((("mutate", p), st._replace(bad=st.bad | {p})))
        for m in self.switches:
            if m in pres and m not in st.off:
                res.append((("disable", m), st._replace(off=st.off | {m})))
        if self.joiner is not None and self.joiner not in self.group_of and not st.joined:
            res.append((("join",), st._replace(joined=True, alive=st.alive | {self.joiner})))
        for name, g in self.groups.items():
            if name not in st.arrived and all(a in pres for a in g.get("after") or []):
                st2 = st._replace(arrived=st.arrived | {name},
                                  alive=st.alive | set(g["members"]),
                                  joined=st.joined or (self.joiner in g["members"]))
                res.append((("join", name), st2))
                if self.arrive_bad:
                    for m in g["members"]:
                        if self.is_monitor(m):
                            res.append((("join-bad", name, m), st2._replace(bad=st2.bad | {m})))
        return res

    def env(self, st):
        """dict: reachable state -> one shortest step sequence."""
        seen = {st: ()}
        frontier = [st]
        for _ in range(self.f):
            nxt = []
            for a in frontier:
                for name, b in self.steps(a):
                    if b not in seen:
                        seen[b] = seen[a] + (name,)
                        nxt.append(b)
            frontier = nxt
        return seen

    def round(self, before, st):
        pres_before = self.present(before)
        pres = self.present(st)
        new = pres - pres_before

        def in_force(r, k, m):
            if m not in self.rel[r].get(k, []):
                return False
            if k not in pres or m not in pres:
                return False
            if (r, k, m) in self.slow_edges and (k in new or m in new):
                return False
            return True

        def monitor_phase(flagged):
            active = set(m for m in self.monitors
                         if m in pres and m in st.alive and m not in st.bad and m not in st.off)
            visible = st.bad - st.hidden
            fl = set(flagged)
            for m in active:
                d = any(in_force("checkers", x, m) for x in visible)
                d = d or any(in_force("hb_readers", p, m) for p in self.monitors
                             if p in pres and p not in st.alive)
                if d:
                    fl.add(m)
            if self.slow_reports:
                add = set()
                for m in flagged:          # flagged at the start of the round
                    if m in active:
                        for r in self.monitors:
                            if r in active and in_force("fwd", m, r):
                                add.add(r)
                fl |= add
            else:
                changed = True
                while changed:
                    changed = False
                    for m in list(fl):
                        if m in active:
                            for r in self.monitors:
                                if r in active and r not in fl and in_force("fwd", m, r):
                                    fl.add(r)
                                    changed = True
            return fl

        def out_of(fl):
            return set(m for m in fl if m in st.alive and m not in st.bad)

        def work_phase(out):
            halted = set(st.halted)
            pending = set(st.pending)
            stepped = []
            nonmon = self.works + ([self.joiner] if self.joiner is not None else [])
            for w in nonmon:
                if w not in pres or w in st.halted:
                    continue
                if w in st.pending:
                    pending.discard(w)
                    halted.add(w)
                    continue
                sees = any(in_force("halt_inputs", w, m) and m in out for m in self.monitors)
                if self.coupling and any(in_force("halt_inputs", w, m) and m not in st.alive
                                         for m in self.monitors):
                    sees = True
                if sees and self.window == 0:
                    halted.add(w)
                else:
                    if sees:
                        pending.add(w)
                    stepped.append(w)
            return halted, pending, stepped

        if self.gate:
            fl = monitor_phase(st.flagged)
            out = out_of(fl)
            halted, pending, stepped = work_phase(out)
        else:
            halted, pending, stepped = work_phase(out_of(st.flagged))
            fl = monitor_phase(st.flagged)
            out = out_of(fl)
        g1 = bool(st.bad) and not out
        g2 = bool(st.bad) and bool(stepped)
        return st._replace(flagged=FZ(fl), halted=FZ(halted), pending=FZ(pending)), g1, g2

    def responded(self, st):
        pres = self.present(st)
        if not [m for m in st.flagged if m in st.alive and m not in st.bad]:
            return False
        nonmon = self.works + ([self.joiner] if self.joiner is not None else [])
        return all(w in st.halted for w in nonmon if w in pres)

    def solve(self, want_witness=False, explore_all=False):
        g = [None, None]
        cnt = [0, 0]
        wit = [None, None]
        parent = {self.init: None}
        frontier = [self.init]
        n = 0
        while frontier and (explore_all or g[0] is None or g[1] is None):
            n += 1
            nxt = []
            for a in frontier:
                for e, seq in self.env(a).items():
                    t, v1, v2 = self.round(a, e)
                    for i, v in ((0, v1), (1, v2)):
                        cnt[i] += v
                        if v and g[i] is None:
                            g[i] = n
                            wit[i] = (a, seq)
                    if t not in parent:
                        parent[t] = (a, seq)
                        if not self.responded(t):
                            nxt.append(t)
            frontier = nxt
        if explore_all:
            return g[0], g[1], len(parent), cnt[0], cnt[1], n
        if not want_witness:
            return g[0], g[1], len(parent)
        traces = []
        for i in (0, 1):
            if wit[i] is None:
                traces.append(None)
                continue
            a, seq = wit[i]
            rounds = [seq]
            while parent[a] is not None:
                a, seq = parent[a]
                rounds.append(seq)
            traces.append(list(reversed(rounds)))
        return g[0], g[1], len(parent), traces


def fmt(trace):
    if trace is None:
        return "none"
    return " | ".join("round %d: %s" % (i + 1, ", ".join(" ".join(map(str, st)) for st in r) or "(no step)")
                      for i, r in enumerate(trace))


if __name__ == "__main__":
    data = json.load(open(sys.argv[1]))
    want = set(sys.argv[2:])
    for c in data:
        if c["id"] in want:
            g1, g2, ns, tr = Naive(c["system"]).solve(want_witness=True)
            print(c["id"], "G1", g1, "G2", g2, "states", ns)
            print("  G1 witness:", fmt(tr[0]))
            print("  G2 witness:", fmt(tr[1]))
