"""Independent recount of the falsifier's rows (2,1) and (3,1) of section 12.1.

Own decider for plain systems at f = 1 with n monitors and one work process, no self-edges.
It uses one structural fact, proved inline in the comments and validated below against
check_model.explore: while nothing is bad no judgement can be violated, and the first round
in which a process is bad either violates a judgement or ends in a complete response.
So a system has no gap exactly when, from every reachable not-yet-responded state made of
stops only, every single mutation is flagged by a live correct monitor and leaves the work
halted. Which stop-only states are reachable does not depend on the state checks."""
import itertools
import random
import sys
import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


sys.path.insert(0, _mc())
import check_model as cm


def subsets_excluding(n, i):
    return [s for s in range(1 << n) if not s >> i & 1]


def stop_states(n, hbr, fwd, hi):
    """Reachable non-responded states (alive, flagged, halted) using stop steps only."""
    full = (1 << n) - 1

    def monitor_phase(alive, flagged, bad_mon, chk_x_detectors):
        active = alive & ~bad_mon
        det = chk_x_detectors & active
        for p in range(n):
            if not alive >> p & 1:
                det |= hbr[p] & active
        fl = flagged | det
        changed = True
        while changed:
            changed = False
            for m in range(n):
                if fl >> m & 1 and active >> m & 1:
                    add = fwd[m] & active & ~fl
                    if add:
                        fl |= add
                        changed = True
        return fl

    start = (full, 0, False)
    seen = {start}
    stack = [start]
    live = []
    while stack:
        alive, flagged, halted = st = stack.pop()
        out = flagged & alive
        if out and halted:
            continue                      # responded: no round starts here
        live.append(st)
        for m in range(n):
            if alive >> m & 1:
                a2 = alive & ~(1 << m)
                fl = monitor_phase(a2, flagged, 0, 0)
                out2 = fl & a2
                h2 = halted or bool(hi & out2) or bool(hi & ~a2 & full)
                nxt = (a2, fl, h2)
                if nxt not in seen:
                    seen.add(nxt)
                    stack.append(nxt)
    return live, monitor_phase


def allowed(n, hbr, fwd, hi):
    """Per process x (monitors 0..n-1, then the work process): the checker sets under which
    every mutation of x, from every reachable stop-only state, is answered. None if some
    process has no allowed set."""
    full = (1 << n) - 1
    live, monitor_phase = stop_states(n, hbr, fwd, hi)
    res = []
    for x in range(n + 1):
        options = subsets_excluding(n, x) if x < n else list(range(1 << n))
        ok = []
        for c in options:
            good = True
            for alive, flagged, halted in live:
                bad_mon = (1 << x) if x < n else 0
                fl = monitor_phase(alive, flagged, bad_mon, c)
                out = fl & alive & ~bad_mon
                if not out:
                    good = False          # G1
                    break
                if not halted and not (hi & out) and not (hi & ~alive & full):
                    good = False          # G2: the work process takes a step
                    break
            if good:
                ok.append(c)
        if not ok:
            return None
        res.append(ok)
    return res


def gap_free_fast(n, hbr, chk, fwd, hi):
    a = allowed(n, hbr, fwd, hi)
    return a is not None and all(chk[x] in a[x] for x in range(n + 1))


def to_system(n, hbr, chk, fwd, hi):
    s = cm.System("x", 1)
    s.monitors = [f"M{i + 1}" for i in range(n)]
    s.works = ["W"]
    s.boundary = {m: i for i, m in enumerate(s.monitors)}
    def names(mask):
        return [s.monitors[i] for i in range(n) if mask >> i & 1]
    for i, m in enumerate(s.monitors):
        s.hb_readers[m] = names(hbr[i])
        s.checkers[m] = names(chk[i])
        s.fwd[m] = names(fwd[i])
    s.checkers["W"] = names(chk[n])
    s.halt_inputs["W"] = names(hi)
    return s


def rows(n):
    return list(itertools.product(*[subsets_excluding(n, i) for i in range(n)]))


# ---- validation against the checker
print("validation against check_model.explore")
bad = tot = 0
for hbr in rows(2):
    for fwd in rows(2):
        for hi in range(4):
            for chk in itertools.product(subsets_excluding(2, 0), subsets_excluding(2, 1), range(4)):
                tot += 1
                f, _ = cm.explore(to_system(2, hbr, chk, fwd, hi))
                ref = f["G1"] is None and f["G2"] is None
                if ref != gap_free_fast(2, hbr, chk, fwd, hi):
                    bad += 1
print("  all 2x1 systems:", tot, "disagreements:", bad)
rng = random.Random(11)
R3 = rows(3)
bad = 0
free = 0
N = 4000
for _ in range(N):
    hbr, fwd = rng.choice(R3), rng.choice(R3)
    if rng.random() < 0.5:                 # bias half the sample toward dense systems so many have no gap
        hbr = tuple(h | rng.choice(subsets_excluding(3, i)) for i, h in enumerate(hbr))
        chk = tuple(rng.choice(subsets_excluding(3, i)) | rng.choice(subsets_excluding(3, i)) for i in range(3)) + (rng.randrange(8) | rng.randrange(8),)
        hi = rng.randrange(8) | rng.randrange(8)
    else:
        chk = tuple(rng.choice(subsets_excluding(3, i)) for i in range(3)) + (rng.randrange(8),)
        hi = rng.randrange(8)
    f, _ = cm.explore(to_system(3, hbr, chk, fwd, hi))
    ref = f["G1"] is None and f["G2"] is None
    free += ref
    if ref != gap_free_fast(3, hbr, chk, fwd, hi):
        bad += 1
print("  random 3x1 systems:", N, "of which no gap:", free, "disagreements:", bad)


# ---- exact counts
def q1_fails(n, hbr):
    return any(hbr[m] == 0 for m in range(n))


def q4_fails(n, fwd):
    full = (1 << n) - 1
    for a in range(n):
        seen = 1 << a
        stack = [a]
        while stack:
            m = stack.pop()
            new = fwd[m] & ~seen
            for r in range(n):
                if new >> r & 1:
                    seen |= 1 << r
                    stack.append(r)
        if seen != full:
            return True
    return False


def count(n, spare_table=None):
    total = free = q1 = q4 = q3 = q8 = 0
    nospare = nospare_fals = nospare_q1 = nospare_q4 = 0
    free_set = set()
    R = rows(n)
    for hbr in R:
        f1 = q1_fails(n, hbr)
        for fwd in R:
            f4 = q4_fails(n, fwd)
            for hi in range(1 << n):
                total += 4 ** n * (1 << n) if n == 3 else (2 ** n) * (1 << n) if n == 2 else 0
                a = allowed(n, hbr, fwd, hi)
                if a is None:
                    continue
                k = 1
                for lst in a:
                    k *= len(lst)
                free += k
                if f1:
                    q1 += k
                if f4:
                    q4 += k
                if bin(hi).count("1") < 2:
                    q8 += k
                if any(0 in a[x] for x in range(n + 1)):
                    q3 += sum(1 for chk in itertools.product(*a) if 0 in chk)
                if spare_table is None:
                    for chk in itertools.product(*a):
                        free_set.add((hbr, chk, fwd, hi))
                    continue
                for chk in itertools.product(*a):
                    spare = False
                    for m in range(n):
                        if delete(n, hbr, chk, fwd, hi, m) in spare_table:
                            spare = True
                            break
                    if not spare:
                        nospare += 1
                        if f1 or f4:
                            nospare_fals += 1
                        if f1:
                            nospare_q1 += 1
                        if f4:
                            nospare_q4 += 1
    return dict(systems=total, no_gap=free, q1_fail=q1, q4_fail=q4, q3_fail=q3, q8_fail=q8, no_spare=nospare,
                no_spare_failing=nospare_fals, no_spare_q1=nospare_q1, no_spare_q4=nospare_q4), free_set


def squeeze(mask, m):
    """Drop bit m from a mask and close the gap."""
    low = mask & ((1 << m) - 1)
    high = mask >> (m + 1)
    return low | (high << m)


def delete(n, hbr, chk, fwd, hi, m):
    keep = [i for i in range(n) if i != m]
    return (tuple(squeeze(hbr[i], m) for i in keep),
            tuple(squeeze(chk[i], m) for i in keep) + (squeeze(chk[n], m),),
            tuple(squeeze(fwd[i], m) for i in keep),
            squeeze(hi, m))


c2, free2 = count(2)
print("2 monitors, 1 work:", c2)
# with two monitors a monitor is never spare (one monitor alone always has a gap)
print("   no gap with Q4 failing:", c2["q4_fail"], "| all 2x1 systems with no gap have no spare monitor")
c3, _ = count(3, spare_table=free2)
print("3 monitors, 1 work:", c3)
