"""Section 12.1, second table: my own recount of the rows for 2 monitors and 3 monitors with one
work process, and 2 monitors with two work processes. Own decider (bitmasks), written from
model-spec.md, validated against check_model.explore on random systems.

A plain system at f = 1: before any state is bad only stop and idle rounds happen, and they do
not read `checkers`. In the first round in which a process is bad either a judgement is
violated or the state is responded. So for a fixed wiring of signal reads, reports and halt
inputs, 'no gap' is one condition per process x on checkers[x] alone."""
import itertools
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bw import cm  # noqa: E402


def round_(n, k, hb, chk, fwd, halt, alive, flagged, halted, step):
    """One round. step: None, ('stop', i), ('mut', x) with x < n a monitor, x >= n a work.
    hb[p], chk[x], fwd[m] are bitmasks of monitors; halt[w] bitmask. Returns
    (alive, flagged, halted, bad?, out, viol1, viol2)."""
    bad_mon = 0
    bad = False
    badx = None
    if step is not None:
        if step[0] == "stop":
            alive &= ~(1 << step[1])
        else:
            bad = True
            badx = step[1]
            if badx < n:
                bad_mon = 1 << badx
    active = alive & ~bad_mon
    allm = (1 << n) - 1
    dead = allm & ~alive
    det = 0
    for m in range(n):
        if active >> m & 1:
            b = 1 << m
            if bad and chk[badx] & b:
                det |= b
            else:
                for p in range(n):
                    if dead >> p & 1 and hb[p] & b:
                        det |= b
                        break
    flagged |= det
    changed = True
    while changed:
        changed = False
        for m in range(n):
            if flagged >> m & 1 and active >> m & 1:
                add = fwd[m] & active & ~flagged
                if add:
                    flagged |= add
                    changed = True
    out = flagged & alive & ~bad_mon
    worked = False
    for w in range(k):
        if not halted >> w & 1:
            if (halt[w] & out) or (halt[w] & ~alive & allm):
                halted |= 1 << w
            else:
                worked = True
    return alive, flagged, halted, bad, out, (bad and not out), (bad and worked)


def allowed(n, k, hb, fwd, halt):
    """Per process x, the set of checkers[x] values with no violating execution; None if
    some set is empty."""
    allw = (1 << k) - 1
    nochk = [0] * (n + k)
    init = ((1 << n) - 1, 0, 0)
    seen = {init}
    todo = [init]
    while todo:
        alive, flagged, halted = todo.pop()
        steps = [None] + [("stop", i) for i in range(n) if alive >> i & 1]
        for st in steps:
            a2, f2, h2, _, out, _, _ = round_(n, k, hb, nochk, fwd, halt, alive, flagged, halted, st)
            if out and h2 == allw:
                continue                       # responded: no round starts here
            s2 = (a2, f2, h2)
            if s2 not in seen:
                seen.add(s2)
                todo.append(s2)
    res = []
    for x in range(n + k):
        ok = []
        cands = [c for c in range(1 << n) if x >= n or not c >> x & 1]
        for c in cands:
            chk = list(nochk)
            chk[x] = c
            good = True
            for alive, flagged, halted in seen:
                a2, f2, h2, _, out, v1, v2 = round_(n, k, hb, chk, fwd, halt, alive, flagged, halted, ("mut", x))
                if v1 or v2:
                    good = False
                    break
                assert out and h2 == allw      # then the state is responded
            if good:
                ok.append(c)
        if not ok:
            return None
        res.append(frozenset(ok))
    return res


def rows(n):
    """Every assignment of a list of other monitors to each monitor."""
    per = [[c for c in range(1 << n) if not c >> m & 1] for m in range(n)]
    return list(itertools.product(*per))


def drop(mask, m):
    low = mask & ((1 << m) - 1)
    return low | (mask >> (m + 1) << m)


def to_system(n, k, hb, chk, fwd, halt):
    s = cm.System("x", 1)
    s.monitors = [f"M{i}" for i in range(n)]
    s.works = [f"W{i}" for i in range(k)]
    s.boundary = {m: i for i, m in enumerate(s.monitors)}
    names = s.monitors + s.works

    def lst(mask):
        return [s.monitors[i] for i in range(n) if mask >> i & 1]
    for i in range(n):
        s.hb_readers[names[i]] = lst(hb[i])
        s.fwd[names[i]] = lst(fwd[i])
    for x in range(n + k):
        s.checkers[names[x]] = lst(chk[x])
    for w in range(k):
        s.halt_inputs[s.works[w]] = lst(halt[w])
    return s


def gap_free_direct(n, k, hb, chk, fwd, halt):
    A = allowed(n, k, hb, fwd, halt)
    return A is not None and all(chk[x] in A[x] for x in range(n + k))


def validate(trials=400):
    rng = random.Random(7)
    bad = 0
    for _ in range(trials):
        n = rng.choice((2, 3, 3, 4))
        k = rng.choice((1, 1, 2))
        dens = rng.choice((0.5, 0.7, 0.9))
        hb = tuple(sum(1 << i for i in range(n) if i != m and rng.random() < dens) for m in range(n))
        fwd = tuple(sum(1 << i for i in range(n) if i != m and rng.random() < dens) for m in range(n))
        chk = tuple(sum(1 << i for i in range(n) if i != x and rng.random() < dens) for x in range(n + k))
        halt = tuple(sum(1 << i for i in range(n) if rng.random() < dens) for _ in range(k))
        mine = gap_free_direct(n, k, hb, chk, fwd, halt)
        first, _ = cm.explore(to_system(n, k, hb, chk, fwd, halt))
        theirs = first["G1"] is None and first["G2"] is None
        bad += mine != theirs
    return trials, bad


def q1(n, hb):
    return all(hb[m] for m in range(n))


def q4(n, fwd):
    full = (1 << n) - 1
    for a in range(n):
        seen = 1 << a
        todo = [a]
        while todo:
            m = todo.pop()
            for r in range(n):
                if fwd[m] >> r & 1 and not seen >> r & 1:
                    seen |= 1 << r
                    todo.append(r)
        if seen != full:
            return False
    return True


MEMO = {}


def count(n, k):
    R = rows(n)
    halts = list(itertools.product(range(1 << n), repeat=k))
    total = len(R) ** 3 * (1 << n) ** k * len(halts)   # hb, fwd, chk-of-monitors rows; chk of works; halts
    gf = nospare = fals = q1fail = q4fail = q1or4 = q3or8 = 0
    readerless_not_halt = 0
    sub_allowed = {}
    for hb in R:
        f1 = not q1(n, hb)
        for fwd in R:
            f4 = not q4(n, fwd)
            for halt in halts:
                A = allowed(n, k, hb, fwd, halt)
                if A is None:
                    continue
                size = 1
                for a in A:
                    size *= len(a)
                gf += size
                q1fail += size * f1
                q4fail += size * f4
                q1or4 += size * (f1 or f4)
                # Q3 / Q8 (must never fail)
                if any(0 in a for a in A) or any(bin(h).count("1") < 2 for h in halt):
                    q3or8 += 1
                # spare monitors: S - m has no gap
                dels = []
                for m in range(n):
                    key = (n - 1, k, tuple(drop(hb[i], m) for i in range(n) if i != m),
                           tuple(drop(fwd[i], m) for i in range(n) if i != m), tuple(drop(h, m) for h in halt))
                    if key not in sub_allowed:
                        sub_allowed[key] = allowed(*key) if n > 1 else None
                    dels.append(sub_allowed[key])
                union_halt = 0
                for h in halt:
                    union_halt |= h
                for chk in itertools.product(*[sorted(a) for a in A]):
                    spare = False
                    for m in range(n):
                        B = dels[m]
                        if B is None:
                            continue
                        xs = [x for x in range(n + k) if x != m]
                        if all(drop(chk[x], m) in B[j] for j, x in enumerate(xs)):
                            spare = True
                            break
                    if not spare:
                        nospare += 1
                        if f1 or f4:
                            fals += 1
                        if any(not hb[m] and not union_halt >> m & 1 for m in range(n)):
                            readerless_not_halt += 1
    return dict(systems=total, gap_free=gf, no_spare=nospare, no_spare_failing_Q1_or_Q4=fals,
                gap_free_failing_Q1=q1fail, gap_free_failing_Q4=q4fail, gap_free_failing_Q1_or_Q4=q1or4,
                triples_allowing_a_Q3_or_Q8_failure=q3or8,
                no_spare_with_unread_monitor_outside_halt_inputs=readerless_not_halt)


if __name__ == "__main__":
    print("validation against check_model.explore (trials, disagreements):", validate(), flush=True)
    for n, k in ((2, 1), (2, 2), (3, 1)):
        print((n, k), count(n, k), flush=True)
