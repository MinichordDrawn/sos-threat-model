"""Independent implementation of model-spec.md + model-spec-join.md.

Written from the two specification files only.

A state is a tuple of eight integers used as bit sets over process indices:

    (alive, bad, hidden, off, flagged, halted, pending, present)

Process indices: monitors first (in the order of `monitors`), then the work
processes, then the joiner (if any).  `alive` holds monitor bits only: a
non-monitor process is never removed from `alive`, so for non-monitors
"in alive" is the same as "present".  `present` carries both `joined` and
`arrived` (a group has at least one member, and its members become present
together, so the set of arrived groups can be read back from `present`).

usage: python model.py systems.json      prints id, G1, G2, states per case
(run.py is the runner that writes answers.json)
"""

import json
import sys


def bits(x):
    while x:
        b = x & -x
        yield b
        x ^= b


class Model:
    def __init__(self, s):
        self.f = s["f"]
        monitors = list(s["monitors"])
        works = list(s["works"])
        joiner = s.get("joiner")
        names = monitors + works + ([joiner] if joiner is not None else [])
        if len(set(names)) != len(names):
            raise ValueError("process names are not distinct")
        self.names = names
        idx = {n: i for i, n in enumerate(names)}
        self.idx = idx
        nm = len(monitors)
        self.nm = nm
        self.n = len(names)
        self.MON = (1 << nm) - 1
        self.ALL = (1 << self.n) - 1
        self.NONMON = self.ALL & ~self.MON
        self.jbit = (1 << idx[joiner]) if joiner is not None else 0

        self.coupling = bool(s["coupling"])
        self.window = s["window"]
        self.gate = bool(s.get("gate", True))
        self.slow_reports = bool(s.get("slow_reports", False))
        self.arrive_bad = bool(s.get("arrive_bad", False))

        def mon_mask(lst):
            m = 0
            for x in lst:
                if x not in idx or idx[x] >= nm:
                    raise ValueError("not a monitor: %r" % (x,))
                m |= 1 << idx[x]
            return m

        # relations: per key index, mask of monitors
        def rel(name):
            arr = [0] * self.n
            for k, v in (s.get(name) or {}).items():
                arr[idx[k]] = mon_mask(v)
            return arr

        self.hb = rel("hb_readers")
        self.chk = rel("checkers")
        self.fwd = rel("fwd")
        self.halt = rel("halt_inputs")
        slow = {"hb_readers": [0] * self.n, "checkers": [0] * self.n,
                "fwd": [0] * self.n, "halt_inputs": [0] * self.n}
        full = {"hb_readers": self.hb, "checkers": self.chk,
                "fwd": self.fwd, "halt_inputs": self.halt}
        for e in s.get("slow_edges") or []:
            r, k, m = e
            b = 1 << idx[m]
            if not (full[r][idx[k]] & b):
                raise ValueError("slow edge is not an edge: %r" % (e,))
            slow[r][idx[k]] |= b
        self.shb = slow["hb_readers"]
        self.schk = slow["checkers"]
        self.sfwd = slow["fwd"]
        self.shalt = slow["halt_inputs"]
        self.any_slow = bool(s.get("slow_edges"))

        self.switches = mon_mask(s.get("switches") or [])

        # boundaries: list of masks of monitors sharing a boundary id
        bm = {}
        for k, v in (s.get("boundary") or {}).items():
            if v is None:
                continue
            i = idx[k]
            if i >= nm:
                continue
            bm.setdefault(json.dumps(v), 0)
            bm[json.dumps(v)] |= 1 << i
        self.boundaries = [m for m in bm.values() if bin(m).count("1") >= 2]

        sm = {}
        for k, v in (s.get("substrate") or {}).items():
            if v is None:
                continue
            sm.setdefault(json.dumps(v), 0)
            sm[json.dumps(v)] |= 1 << idx[k]
        self.substrates = list(sm.values())

        # groups
        self.groups = []  # (members mask, after mask)
        late = 0
        for g in s.get("late") or []:
            mm = 0
            for x in g["members"]:
                mm |= 1 << idx[x]
            if not mm:
                raise ValueError("empty group")
            if mm & late:
                raise ValueError("process in two groups")
            late |= mm
            am = 0
            for x in g.get("after") or []:
                am |= 1 << idx[x]
            self.groups.append((mm, am))
        self.late = late
        self.joiner_in_group = bool(self.jbit & late)

        present0 = self.ALL & ~late & ~self.jbit
        self.init = (present0 & self.MON, 0, 0, 0, 0, 0, 0, present0)

    # ---- environment phase -------------------------------------------------
    def env_steps(self, st):
        alive, bad, hidden, off, flagged, halted, pending, present = st
        MON = self.MON
        out = []
        # stop m
        for b in bits(alive):
            out.append((alive ^ b, bad, hidden, off, flagged, halted, pending, present))
        # stop-boundary b
        for bm in self.boundaries:
            mem = bm & present
            if mem & (mem - 1) and mem & alive:
                out.append((alive & ~mem, bad, hidden, off, flagged, halted, pending, present))
        # fail-substrate s
        for sm in self.substrates:
            procs = sm & present
            if (procs & MON & alive) or (procs & ~MON & ~bad):
                nmn = procs & ~MON
                out.append((alive & ~procs, bad | nmn, hidden | nmn, off, flagged,
                            halted, pending, present))
        # mutate p
        for b in bits(present & ~bad):
            out.append((alive, bad | b, hidden, off, flagged, halted, pending, present))
        # disable m
        for b in bits(self.switches & present & ~off):
            out.append((alive, bad, hidden, off | b, flagged, halted, pending, present))
        # join (the joiner's own step)
        jb = self.jbit
        if jb and not self.joiner_in_group and not (present & jb):
            out.append((alive, bad, hidden, off, flagged, halted, pending, present | jb))
        # join g / join-bad g m
        for mm, am in self.groups:
            if not (mm & present) and (am & present) == am:
                np_ = present | mm
                na = alive | (mm & MON)
                out.append((na, bad, hidden, off, flagged, halted, pending, np_))
                if self.arrive_bad:
                    for b in bits(mm & MON):
                        out.append((na, bad | b, hidden, off, flagged, halted, pending, np_))
        return out

    def env_outcomes(self, st):
        """All states reachable by 0..f environment steps."""
        seen = {st}
        frontier = [st]
        for _ in range(self.f):
            nxt = []
            for s in frontier:
                for t in self.env_steps(s):
                    if t not in seen:
                        seen.add(t)
                        nxt.append(t)
            if not nxt:
                break
            frontier = nxt
        return seen

    # ---- one round after the environment phase ------------------------------
    def _monitor_phase(self, st, new, flagged_start):
        alive, bad, hidden, off, flagged, halted, pending, present = st
        MON = self.MON
        active = alive & ~bad & ~off & MON
        visible = bad & ~hidden
        pm = present & MON
        newm = new & MON
        det = 0
        for xb in bits(visible):
            x = xb.bit_length() - 1
            e = self.chk[x] & pm
            if e:
                sl = self.schk[x]
                if sl:
                    e &= ~(sl if (xb & new) else (sl & newm))
                det |= e
        for pb in bits(pm & ~alive):
            p = pb.bit_length() - 1
            e = self.hb[p] & pm
            if e:
                sl = self.shb[p]
                if sl:
                    e &= ~(sl if (pb & new) else (sl & newm))
                det |= e
        flagged |= det & active
        if self.slow_reports:
            add = 0
            for mb in bits(flagged_start & active):
                m = mb.bit_length() - 1
                e = self.fwd[m] & pm
                sl = self.sfwd[m]
                if sl:
                    e &= ~(sl if (mb & new) else (sl & newm))
                add |= e
            flagged |= add & active
        else:
            todo = flagged & active
            done = 0
            while todo:
                mb = todo & -todo
                todo ^= mb
                done |= mb
                m = mb.bit_length() - 1
                e = self.fwd[m] & pm
                sl = self.sfwd[m]
                if sl:
                    e &= ~(sl if (mb & new) else (sl & newm))
                e &= active
                fresh = e & ~flagged
                flagged |= e
                todo |= fresh & ~done
        return flagged

    def _work_phase(self, st, new, out):
        """Returns (halted, pending, stepped)."""
        alive, bad, hidden, off, flagged, halted, pending, present = st
        MON = self.MON
        pm = present & MON
        newm = new & MON
        stepped = False
        nh, npd = halted, pending
        for wb in bits(present & ~MON & ~halted):
            if pending & wb:
                npd &= ~wb
                nh |= wb
                continue
            w = wb.bit_length() - 1
            e = self.halt[w] & pm
            sl = self.shalt[w]
            if sl:
                e &= ~(sl if (wb & new) else (sl & newm))
            sees = bool(e & out) or (self.coupling and bool(e & ~alive))
            if sees and self.window == 0:
                nh |= wb
            else:
                if sees:
                    npd |= wb
                stepped = True
        return nh, npd, stepped

    def round_after_env(self, pre_present, flagged_start, st):
        """st: state after the environment phase.  Returns (state, g1, g2)."""
        alive, bad, hidden, off, flagged, halted, pending, present = st
        new = present & ~pre_present
        if self.gate:
            flagged = self._monitor_phase(st, new, flagged_start)
            out = flagged & alive & ~bad
            st2 = (alive, bad, hidden, off, flagged, halted, pending, present)
            halted, pending, stepped = self._work_phase(st2, new, out)
        else:
            out0 = flagged & alive & ~bad
            halted, pending, stepped = self._work_phase(st, new, out0)
            flagged = self._monitor_phase(st, new, flagged_start)
            out = flagged & alive & ~bad
        g1 = bool(bad) and not out
        g2 = bool(bad) and stepped
        return (alive, bad, hidden, off, flagged, halted, pending, present), g1, g2

    def responded(self, st):
        alive, bad, hidden, off, flagged, halted, pending, present = st
        if not (flagged & alive & ~bad):
            return False
        if (present & ~self.MON) & ~halted:
            return False
        return True

    # ---- the result ---------------------------------------------------------
    def solve(self, state_limit=None, explore_all=False):
        """Returns (G1, G2, number of distinct end-of-round states seen,
        complete).  `complete` is False if the state limit was hit.

        The search stops as soon as both goals have a least round, or when
        every reachable state has been explored.  With explore_all=True it
        never stops early, and the result is instead a fingerprint
        (G1, G2, states, violating (state, outcome) pairs of G1, of G2, depth)
        used only to compare two implementations."""
        g1 = g2 = None
        c1 = c2 = 0
        init = self.init
        visited = {init}
        frontier = [init]
        n = 0
        # the initial state has no flag, so it is never a responded state
        while frontier and (explore_all or g1 is None or g2 is None):
            n += 1
            nxt = []
            for s in frontier:
                pre_present = s[7]
                fl0 = s[4]
                for e in self.env_outcomes(s):
                    t, v1, v2 = self.round_after_env(pre_present, fl0, e)
                    c1 += v1
                    c2 += v2
                    if v1 and g1 is None:
                        g1 = n
                    if v2 and g2 is None:
                        g2 = n
                    if t not in visited:
                        visited.add(t)
                        if not self.responded(t):
                            nxt.append(t)
                if state_limit is not None and len(visited) > state_limit:
                    return g1, g2, len(visited), False
            frontier = nxt
        if explore_all:
            return g1, g2, len(visited), c1, c2, n
        return g1, g2, len(visited), True


def solve_system(s):
    return Model(s).solve()


if __name__ == "__main__":
    data = json.load(open(sys.argv[1]))
    for c in data:
        g1, g2, ns, ok = solve_system(c["system"])
        print(c["id"], g1, g2, ns)
