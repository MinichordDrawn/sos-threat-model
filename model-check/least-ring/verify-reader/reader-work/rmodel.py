"""Reader's own implementation of model-spec.md + model-spec-join.md + model-spec-scope.md.

Written from the three specification files.  Restricted to what the write-ups use:
no substrates, no switches, window 0, gate in place, no `joiner` field, no slow edges.
(`slow_reports` is supported.)  A system that breaks a restriction raises.

A system dict uses the specification's field names.  An unscoped system is run through the
unscoped path (model-spec.md 3.2-3.5 as amended by J); a scoped one through X4-X10.
The two paths share nothing but the environment phase, so that X11 can be tested.
"""
import itertools


def bits(x):
    while x:
        b = x & -x
        yield b
        x ^= b


class Sys:
    def __init__(self, s):
        for k in ("substrate", "switches", "slow_edges"):
            if s.get(k):
                raise ValueError("unsupported field " + k)
        if s.get("joiner") is not None:
            raise ValueError("joiner unsupported")
        if s.get("window", 0) != 0 or not s.get("gate", True) or not s.get("coupling", True):
            raise ValueError("unsupported variant")
        self.f = s["f"]
        self.mons = list(s["monitors"])
        self.works = list(s["works"])
        self.names = self.mons + self.works
        self.idx = {n: i for i, n in enumerate(self.names)}
        assert len(self.idx) == len(self.names)
        self.nm = len(self.mons)
        self.n = len(self.names)
        self.MON = (1 << self.nm) - 1
        self.ALL = (1 << self.n) - 1
        self.slow_reports = bool(s.get("slow_reports", False))
        self.arrive_bad = bool(s.get("arrive_bad", False))
        self.max_rounds = s.get("max_rounds")

        def rel(name):
            arr = [0] * self.n
            for k, v in (s.get(name) or {}).items():
                m = 0
                for x in v:
                    i = self.idx[x]
                    assert i < self.nm, "not a monitor"
                    m |= 1 << i
                arr[self.idx[k]] = m
            return arr

        self.hb = rel("hb_readers")      # hb[p] = monitors that read p's signal
        self.chk = rel("checkers")       # chk[x] = monitors that check x
        self.fwd = rel("fwd")            # fwd[m] = monitors m reports to
        self.halt = rel("halt_inputs")   # halt[w] = halt inputs of w

        bm = {}
        for k, v in (s.get("boundary") or {}).items():
            if v is None:
                continue
            bm.setdefault(v, 0)
            bm[v] |= 1 << self.idx[k]
        self.boundaries = [m for m in bm.values() if bin(m).count("1") >= 2]

        self.groups = []
        late = 0
        for g in s.get("late") or []:
            mm = 0
            for x in g["members"]:
                mm |= 1 << self.idx[x]
            assert mm and not (mm & late)
            late |= mm
            am = 0
            for x in g.get("after") or []:
                am |= 1 << self.idx[x]
            self.groups.append((mm, am))
        self.late = late
        self.present0 = self.ALL & ~late

        sc = s.get("scope") or {}
        self.scoped = bool(sc)
        if self.scoped:
            ids = []
            for n in self.names:
                if sc[n] not in ids:
                    ids.append(sc[n])
            for k in list((s.get("scope_work") or {}).keys()) + list((s.get("told") or {}).keys()):
                if k not in ids:
                    ids.append(k)
            self.scopes = ids
            self.ns = len(ids)
            sidx = {k: i for i, k in enumerate(ids)}
            self.scope_of = [sidx[sc[n]] for n in self.names]
            self.members = [0] * self.ns          # processes of scope s
            for i, si in enumerate(self.scope_of):
                self.members[si] |= 1 << i
            sw = s.get("scope_work") or {}
            self.work = []
            for k in ids:
                if k in sw:
                    m = 0
                    for x in sw[k]:
                        assert self.idx[x] >= self.nm
                        m |= 1 << self.idx[x]
                else:
                    m = self.members[sidx[k]] & ~self.MON
                self.work.append(m)
            td = s.get("told") or {}
            self.told = []
            for k in ids:
                m = 0
                for x in td.get(k, []):
                    m |= 1 << self.idx[x]
                self.told.append(m)
            self.freeze = bool(s.get("freeze", False))
            # covers[w index] = mask of scope indices covering w
            self.covers = [0] * self.n
            for si in range(self.ns):
                for wb in bits(self.work[si]):
                    self.covers[wb.bit_length() - 1] |= 1 << si
        else:
            for k in ("scope_work", "told", "freeze"):
                assert not s.get(k)

    # ---------------- environment ----------------
    # env state: (alive, bad, present); `frozen` = mask of processes that are frozen
    def env_steps(self, e, frozen):
        alive, bad, present = e
        out = []
        for b in bits(alive & ~frozen):
            out.append((alive ^ b, bad, present))
        for bm in self.boundaries:
            mem = bm & present
            if mem & (mem - 1) and (mem & alive & ~frozen):
                out.append((alive & ~(mem & ~frozen), bad, present))
        for b in bits(present & ~bad & ~frozen):
            out.append((alive, bad | b, present))
        for mm, am in self.groups:
            if not (mm & present) and (am & present) == am and not (mm & frozen):
                np_ = present | mm
                na = alive | (mm & self.MON)
                out.append((na, bad, np_))
                if self.arrive_bad:
                    for b in bits(mm & self.MON):
                        out.append((na, bad | b, np_))
        return out

    def env_outcomes(self, e, frozen):
        seen = {e}
        fr = [e]
        for _ in range(self.f):
            nx = []
            for x in fr:
                for t in self.env_steps(x, frozen):
                    if t not in seen:
                        seen.add(t)
                        nx.append(t)
            fr = nx
            if not fr:
                break
        return seen

    # ---------------- unscoped ----------------
    def solve_plain(self, want_told_mask=0, stop_early=False, state_limit=None, stop_any=False):
        """Returns dict G1, G2 (and 'told' if want_told_mask: told judged as part-a states
        it: something bad, a listed monitor alive and not bad, none of the listed in out).
        stop_early: stop once both G1 and G2 have a least round.  state_limit: give up when
        more than that many states have been seen (res['complete'] is then False)."""
        MON = self.MON
        res = {"G1": None, "G2": None, "told": None, "complete": True}
        init = (self.present0 & MON, 0, self.present0, 0, 0)   # alive,bad,present,flagged,halted
        visited = {init}
        frontier = [init]
        n = 0
        while frontier:
            n += 1
            if self.max_rounds is not None and n > self.max_rounds:
                break
            last = self.max_rounds is not None and n == self.max_rounds
            if stop_early and res["G1"] is not None and res["G2"] is not None:
                break
            if state_limit is not None and len(visited) > state_limit:
                res["complete"] = False
                break
            nxt = []
            for st in frontier:
                if state_limit is not None and len(visited) > state_limit:
                    res["complete"] = False
                    break
                if stop_early and res["G1"] is not None and res["G2"] is not None:
                    break
                if stop_any and (res["G1"] is not None or res["G2"] is not None or res["told"] is not None):
                    res["states"] = len(visited)
                    res["rounds_explored"] = n
                    return res
                alive, bad, present, flagged0, halted0 = st
                for (a, b, p) in self.env_outcomes((alive, bad, present), 0):
                    pm = p & MON
                    active = a & ~b & MON
                    det = 0
                    for xb in bits(b):
                        det |= self.chk[xb.bit_length() - 1]
                    for pb in bits(pm & ~a):
                        det |= self.hb[pb.bit_length() - 1]
                    fl = flagged0 | (det & active)
                    if self.slow_reports:
                        add = 0
                        for mb in bits(flagged0 & active):
                            add |= self.fwd[mb.bit_length() - 1]
                        fl |= add & active
                    else:
                        todo = fl & active
                        done = 0
                        while todo:
                            mb = todo & -todo
                            todo ^= mb
                            done |= mb
                            e_ = self.fwd[mb.bit_length() - 1] & active
                            fl |= e_
                            todo |= e_ & ~done
                    out = fl & a & ~b
                    halted = halted0
                    stepped = False
                    for wb in bits(p & ~MON & ~halted0):
                        hi = self.halt[wb.bit_length() - 1] & pm
                        if (hi & out) or (hi & ~a):
                            halted |= wb
                        else:
                            stepped = True
                    if b:
                        if not out and res["G1"] is None:
                            res["G1"] = n
                        if stepped and res["G2"] is None:
                            res["G2"] = n
                        if want_told_mask and res["told"] is None:
                            if (want_told_mask & a & ~b) and not (want_told_mask & out):
                                res["told"] = n
                    if last:
                        continue
                    t = (a, b, p, fl, halted)
                    if t not in visited:
                        visited.add(t)
                        responded = bool(fl & a & ~b) and not ((p & ~MON) & ~halted)
                        if not responded:
                            nxt.append(t)
            if not res["complete"]:
                break
            frontier = nxt
        res["states"] = len(visited)
        res["rounds_explored"] = n
        return res

    # ---------------- scoped ----------------
    def solve_scoped(self, state_limit=None, stop_any=False):
        MON = self.MON
        ns = self.ns
        keys = ["G1", "G2", "told"]
        res = {k: [None] * ns for k in keys}
        res["spill"] = None
        init = (self.present0 & MON, 0, self.present0, (0,) * ns, 0, 0)
        # alive, bad, present, flagged per scope, halted, closed (mask of scope indices)
        visited = {init}
        frontier = [init]
        n = 0
        complete = True
        while frontier:
            n += 1
            if self.max_rounds is not None and n > self.max_rounds:
                break
            last = self.max_rounds is not None and n == self.max_rounds
            nxt = []
            for st in frontier:
                if stop_any and (res["spill"] is not None or any(v is not None for k in keys for v in res[k])):
                    frontier = []
                    nxt = []
                    break
                alive, bad, present, flagged0, halted0, closed0 = st
                frozen = 0
                if self.freeze and closed0:
                    for si in range(ns):
                        if closed0 >> si & 1:
                            frozen |= self.members[si]
                for (a, b, p) in self.env_outcomes((alive, bad, present), frozen):
                    pm = p & MON
                    active = a & ~b & MON
                    fl = list(flagged0)
                    # detection, per scope of the thing detected
                    for xb in bits(b):
                        x = xb.bit_length() - 1
                        fl[self.scope_of[x]] |= self.chk[x] & active
                    for pb in bits(pm & ~a):
                        q = pb.bit_length() - 1
                        fl[self.scope_of[q]] |= self.hb[q] & active
                    out = [0] * ns
                    for si in range(ns):
                        if self.slow_reports:
                            add = 0
                            for mb in bits(flagged0[si] & active):
                                add |= self.fwd[mb.bit_length() - 1]
                            fl[si] |= add & active
                        else:
                            cur = fl[si]
                            todo = cur & active
                            done = 0
                            while todo:
                                mb = todo & -todo
                                todo ^= mb
                                done |= mb
                                e_ = self.fwd[mb.bit_length() - 1] & active
                                cur |= e_
                                todo |= e_ & ~done
                            fl[si] = cur
                        out[si] = fl[si] & a & ~b
                    halted = halted0
                    stepped = 0
                    faulty = b | (pm & ~a)
                    spill = False
                    for wb in bits(p & ~MON & ~halted0):
                        w = wb.bit_length() - 1
                        hi = self.halt[w] & pm
                        sees = bool(hi & ~a)
                        cov = self.covers[w]
                        if not sees:
                            for si in range(ns):
                                if (cov >> si & 1) and (hi & out[si]):
                                    sees = True
                                    break
                        if sees:
                            halted |= wb
                            anyf = False
                            for si in range(ns):
                                if (cov >> si & 1) and (self.members[si] & faulty):
                                    anyf = True
                                    break
                            if not anyf:
                                spill = True
                        else:
                            stepped |= wb
                    if spill and res["spill"] is None:
                        res["spill"] = n
                    closed = closed0
                    for si in range(ns):
                        if closed0 >> si & 1:
                            continue
                        if self.members[si] & b:
                            if not out[si] and res["G1"][si] is None:
                                res["G1"][si] = n
                            if (self.work[si] & stepped) and res["G2"][si] is None:
                                res["G2"][si] = n
                            if res["told"][si] is None and (self.told[si] & a & ~b) \
                                    and not (self.told[si] & out[si]):
                                res["told"][si] = n
                        if out[si] and not (self.work[si] & p & ~halted):
                            closed |= 1 << si
                    if last:
                        continue
                    t = (a, b, p, tuple(fl), halted, closed)
                    if t not in visited:
                        visited.add(t)
                        anyflag = False
                        for si in range(ns):
                            if fl[si] & a & ~b:
                                anyflag = True
                                break
                        responded = anyflag and not ((p & ~MON) & ~halted)
                        if not responded:
                            nxt.append(t)
                if state_limit is not None and len(visited) > state_limit:
                    complete = False
                    break
            if not complete:
                break
            frontier = nxt
        out_ = {"scopes": {self.scopes[si]: {k: res[k][si] for k in keys} for si in range(ns)},
                "spill": res["spill"], "states": len(visited), "complete": complete,
                "rounds_explored": n}

        def least(vals):
            vs = [v for v in vals if v is not None]
            return min(vs) if vs else None
        out_["G1"] = least(res["G1"])
        out_["G2"] = least(res["G2"])
        out_["told"] = least(res["told"])
        return out_

    def solve(self, **kw):
        if self.scoped:
            return self.solve_scoped(**kw)
        return self.solve_plain(**kw)

    # ---------------- replay of one execution, for counterexample tables ----------------
    def replay(self, rounds, verbose=True):
        """rounds: list of lists of steps; a step is ('stop',m) ('mutate',p) ('stopb',[names])
        ('join',[members]) ('joinbad',[members],m).  Checks enabledness, the count of steps
        and that no round starts from a responded state; prints the end of each round.
        Returns list of per-round dicts of violations."""
        MON = self.MON
        scoped = self.scoped
        ns = self.ns if scoped else 1
        alive, bad, present = self.present0 & MON, 0, self.present0
        fl = [0] * ns
        halted = 0
        closed = 0
        log = []
        nm = lambda mask: ",".join(self.names[b.bit_length() - 1] for b in bits(mask)) or "-"
        for rn, steps in enumerate(rounds, 1):
            anyflag = any(fl[si] & alive & ~bad for si in range(ns))
            assert not (anyflag and not ((present & ~MON) & ~halted)), "round %d starts from a responded state" % rn
            assert len(steps) <= self.f, "round %d: more than f steps" % rn
            frozen = 0
            if scoped and self.freeze:
                for si in range(ns):
                    if closed >> si & 1:
                        frozen |= self.members[si]
            for stp in steps:
                kind = stp[0]
                if kind == "stop":
                    b_ = 1 << self.idx[stp[1]]
                    assert b_ & MON & alive & present & ~frozen, "stop %s not enabled (round %d)" % (stp[1], rn)
                    alive &= ~b_
                elif kind == "mutate":
                    b_ = 1 << self.idx[stp[1]]
                    assert b_ & present & ~bad & ~frozen, "mutate %s not enabled (round %d)" % (stp[1], rn)
                    bad |= b_
                elif kind == "stopb":
                    mem = 0
                    for x in stp[1]:
                        mem |= 1 << self.idx[x]
                    assert mem in self.boundaries, "not a boundary"
                    mem &= present
                    assert mem & (mem - 1) and (mem & alive & ~frozen), "stop-boundary not enabled (round %d)" % rn
                    alive &= ~(mem & ~frozen)
                elif kind in ("join", "joinbad"):
                    mm = 0
                    for x in stp[1]:
                        mm |= 1 << self.idx[x]
                    g = [g for g in self.groups if g[0] == mm]
                    assert g, "no such group %r" % (stp[1],)
                    am = g[0][1]
                    assert not (mm & present) and (am & present) == am and not (mm & frozen), \
                        "join %r not enabled (round %d)" % (stp[1], rn)
                    present |= mm
                    alive |= mm & MON
                    if kind == "joinbad":
                        assert self.arrive_bad
                        b_ = 1 << self.idx[stp[2]]
                        assert b_ & mm & MON
                        bad |= b_
                else:
                    raise ValueError(kind)
            pm = present & MON
            active = alive & ~bad & MON
            fl0 = list(fl)
            for xb in bits(bad):
                x = xb.bit_length() - 1
                fl[self.scope_of[x] if scoped else 0] |= self.chk[x] & active
            for pb in bits(pm & ~alive):
                q = pb.bit_length() - 1
                fl[self.scope_of[q] if scoped else 0] |= self.hb[q] & active
            out = [0] * ns
            for si in range(ns):
                if self.slow_reports:
                    add = 0
                    for mb in bits(fl0[si] & active):
                        add |= self.fwd[mb.bit_length() - 1]
                    fl[si] |= add & active
                else:
                    ch = True
                    while ch:
                        ch = False
                        for mb in bits(fl[si] & active):
                            e_ = self.fwd[mb.bit_length() - 1] & active
                            if e_ & ~fl[si]:
                                fl[si] |= e_
                                ch = True
                out[si] = fl[si] & alive & ~bad
            stepped = 0
            newly = 0
            faulty = bad | (pm & ~alive)
            spill = []
            for wb in bits(present & ~MON & ~halted):
                w = wb.bit_length() - 1
                hi = self.halt[w] & pm
                sees = bool(hi & ~alive)
                if scoped:
                    for si in range(ns):
                        if (self.covers[w] >> si & 1) and (hi & out[si]):
                            sees = True
                else:
                    sees = sees or bool(hi & out[0])
                if sees:
                    newly |= wb
                    if scoped and not any((self.covers[w] >> si & 1) and (self.members[si] & faulty)
                                          for si in range(ns)):
                        spill.append(self.names[w])
                else:
                    stepped |= wb
            halted |= newly
            viol = []
            if scoped:
                newclosed = closed
                for si in range(ns):
                    if closed >> si & 1:
                        continue
                    sname = self.scopes[si]
                    if self.members[si] & bad:
                        if not out[si]:
                            viol.append("G1[%s]" % sname)
                        if self.work[si] & stepped:
                            viol.append("G2[%s]" % sname)
                        if (self.told[si] & alive & ~bad) and not (self.told[si] & out[si]):
                            viol.append("told[%s]" % sname)
                    if out[si] and not (self.work[si] & present & ~halted):
                        newclosed |= 1 << si
                if spill:
                    viol.append("spill(%s)" % ",".join(spill))
                closed = newclosed
            else:
                if bad and not out[0]:
                    viol.append("G1")
                if bad and stepped:
                    viol.append("G2")
            log.append(viol)
            if verbose:
                print("  round %d: %s" % (rn, "; ".join(" ".join(map(str, s_)) for s_ in steps)))
                print("    stopped: %s | bad: %s" % (nm(pm & ~alive), nm(bad)))
                if scoped:
                    for si in range(ns):
                        if fl[si]:
                            print("    flag for %-7s held by %s   (out: %s)" % (self.scopes[si], nm(fl[si]), nm(out[si])))
                    print("    closed: %s" % (",".join(self.scopes[si] for si in range(ns) if closed >> si & 1) or "-"))
                else:
                    print("    flagged: %s (out: %s)" % (nm(fl[0]), nm(out[0])))
                print("    halted: %s | newly halted: %s | took a work step: %s" % (nm(halted), nm(newly), nm(stepped)))
                print("    VIOLATED: %s" % (", ".join(viol) or "nothing"))
        return log
