"""Bitmask implementation of model-spec.md restricted to PLAIN systems at f = 1.

A plain system (task.md): no joiner, no substrate, no switches, every monitor alone in its
boundary (so stop-boundary is never enabled), coupling true, window 0, gate true, fast
reports.  The only environment steps left are `stop m` and `mutate p`, at most one a round.

Mask form of a system:  (n, k, hbr, chk, fwd, hi)
  n monitors are bits 0..n-1, k work processes are bits n..n+k-1 of the `bad` mask
  hbr[m]  mask of monitors r with r in hb_readers[m]          (m a monitor)
  chk[x]  mask of monitors c with c in checkers[x]            (x any process, 0..n+k-1)
  fwd[m]  mask of monitors r with r in fwd[m]                 (m a monitor)
  hi[w]   mask of monitors in halt_inputs[work w]             (w = 0..k-1)

Two independent deciders of gap-freedom:
  gap_free_bfs      plain reachability over (alive, bad, flagged, halted), nothing assumed
  allowed_sets      the same exploration organised per mutated process (see its docstring)
"""
from itertools import permutations, product

MON_NAMES = "abcdefgh"
WORK_NAMES = ["w", "v", "u"]


# ------------------------------------------------------------------ one round, f = 1
def do_round(n, k, hbr, chk, fwd, hi, flagged, halted, a2, b2):
    """Monitor phase then work phase from the state after the environment phase.

    a2 = alive monitors, b2 = bad processes (after the environment step).
    Returns (flagged', halted', out, g1, g2).
    """
    allm = (1 << n) - 1
    active = a2 & ~b2 & allm
    det = 0
    x = b2
    p = 0
    while x:                      # visible = bad (nothing is hidden in a plain system)
        if x & 1:
            det |= chk[p]
        x >>= 1
        p += 1
    x = allm & ~a2
    p = 0
    while x:                      # monitors not alive
        if x & 1:
            det |= hbr[p]
        x >>= 1
        p += 1
    fl = flagged | (det & active)
    while True:                   # propagation to a fixed point
        new = fl
        x = fl & active
        p = 0
        while x:
            if x & 1:
                new |= fwd[p] & active
            x >>= 1
            p += 1
        if new == fl:
            break
        fl = new
    out = fl & a2 & ~b2 & allm
    dead = allm & ~a2
    h2 = halted
    stepped = False
    for w in range(k):
        if not (halted >> w) & 1:
            if hi[w] & (out | dead):    # flag of a halt input, or (coupling) its silence
                h2 |= 1 << w
            else:
                stepped = True
    g1 = bool(b2) and not out
    g2 = bool(b2) and stepped
    return fl, h2, out, g1, g2


def env_choices(n, k, alive, bad):
    """States after an environment phase of 0 or 1 steps: (alive, bad, label)."""
    ch = [(alive, bad, None)]
    for i in range(n):
        if alive >> i & 1:
            ch.append((alive ^ (1 << i), bad, ("stop", i)))
    for p in range(n + k):
        if not bad >> p & 1:
            ch.append((alive, bad | (1 << p), ("mutate", p)))
    return ch


def gap_free_bfs(n, k, hbr, chk, fwd, hi, trace=False):
    """True iff no execution violates G1 or G2.  With trace=True returns (bool, witness)."""
    allm = (1 << n) - 1
    allw = (1 << k) - 1
    init = (allm, 0, 0, 0)
    parent = {init: None}
    frontier = [init]
    while frontier:
        nxt = []
        for st in frontier:
            alive, bad, flagged, halted = st
            for a2, b2, label in env_choices(n, k, alive, bad):
                fl, h2, out, g1, g2 = do_round(n, k, hbr, chk, fwd, hi, flagged, halted, a2, b2)
                if g1 or g2:
                    if not trace:
                        return False
                    steps = [label]
                    s = st
                    while parent[s] is not None:
                        s, lab = parent[s]
                        steps.append(lab)
                    steps.reverse()
                    return False, {"goal": "G1" if g1 else "G2", "steps": steps}
                if out and h2 == allw:
                    continue                      # responded: no round starts here
                s2 = (a2, b2, fl, h2)
                if s2 not in parent:
                    parent[s2] = (st, label)
                    nxt.append(s2)
        frontier = nxt
    return (True, None) if trace else True


def allowed_sets(n, k, hbr, fwd, hi, candidates=None):
    """For fixed hbr, fwd, hi: the set A[x] of values of chk[x] under which no execution that
    mutates x violates a goal, for every process x.  The system is gap-free iff chk[x] is in
    A[x] for every x.

    Why this is the same exploration as gap_free_bfs: while `bad` is empty no goal can be
    violated, and those rounds (idle or stop) do not read chk at all.  The first mutate
    round reads chk[x] of the one mutated process only.  After it, either a goal is violated
    or (out non-empty and nobody took a work step, window 0) the state is responded and the
    execution is over.  The last fact is asserted below every time it is used.
    Returns a list of sets, or None as soon as some A[x] is empty.
    """
    allm = (1 << n) - 1
    allw = (1 << k) - 1
    nochk = [0] * (n + k)
    init = (allm, 0, 0)
    seen = {init}
    stack = [init]
    while stack:                                   # reachable non-responded states, bad empty
        alive, flagged, halted = stack.pop()
        for i in range(n):
            if alive >> i & 1:
                fl, h2, out, g1, g2 = do_round(n, k, hbr, nochk, fwd, hi, flagged, halted,
                                               alive ^ (1 << i), 0)
                if out and h2 == allw:
                    continue
                s2 = (alive ^ (1 << i), fl, h2)
                if s2 not in seen:
                    seen.add(s2)
                    stack.append(s2)
        # the idle round, explored like any other (it is not assumed to be a no-op)
        fl, h2, out, g1, g2 = do_round(n, k, hbr, nochk, fwd, hi, flagged, halted, alive, 0)
        if not (out and h2 == allw):
            s2 = (alive, fl, h2)
            if s2 not in seen:
                seen.add(s2)
                stack.append(s2)
    res = []
    for x in range(n + k):
        if candidates is not None:
            cands = candidates[x]
        elif x < n:
            cands = [c for c in range(1 << n) if not c >> x & 1]    # self-check is inert
        else:
            cands = range(1 << n)
        ok = set()
        for c in cands:
            chk = list(nochk)
            chk[x] = c
            good = True
            for alive, flagged, halted in seen:
                fl, h2, out, g1, g2 = do_round(n, k, hbr, chk, fwd, hi, flagged, halted,
                                               alive, 1 << x)
                if g1 or g2:
                    good = False
                    break
                assert out and h2 == allw, "mutate round neither violated nor responded"
            if good:
                ok.add(c)
        if not ok:
            return None
        res.append(ok)
    return res


# ------------------------------------------------------------------ predicates of task.md
def q1(n, k, hbr, chk, fwd, hi):
    return all(hbr[m] & ~(1 << m) for m in range(n))


def q3(n, k, hbr, chk, fwd, hi):
    return all(chk[x] & ~(1 << x) for x in range(n)) and all(chk[n + w] for w in range(k))


def q4(n, k, hbr, chk, fwd, hi):
    for a in range(n):
        reach = 1 << a
        while True:
            new = reach
            for m in range(n):
                if reach >> m & 1:
                    new |= fwd[m]
            if new == reach:
                break
            reach = new
        if reach != (1 << n) - 1:
            return False
    return True


def q8(n, k, hbr, chk, fwd, hi):
    return all(bin(hi[w]).count("1") >= 2 for w in range(k))


def predicates(s):
    return (q1(*s), q3(*s), q4(*s), q8(*s))


def failing(s):
    return [name for name, ok in zip(("Q1", "Q3", "Q4", "Q8"), predicates(s)) if not ok]


# ------------------------------------------------------------------ deleting a monitor
def _drop(mask, m):
    return (mask & ((1 << m) - 1)) | ((mask >> (m + 1)) << m)


def delete(s, m):
    """S - m of task.md."""
    n, k, hbr, chk, fwd, hi = s
    hbr2 = tuple(_drop(hbr[i], m) for i in range(n) if i != m)
    chk2 = tuple(_drop(chk[x], m) for x in range(n + k) if x != m)
    fwd2 = tuple(_drop(fwd[i], m) for i in range(n) if i != m)
    hi2 = tuple(_drop(h, m) for h in hi)
    return (n - 1, k, hbr2, chk2, fwd2, hi2)


def strip_self(s):
    n, k, hbr, chk, fwd, hi = s
    return (n, k, tuple(hbr[i] & ~(1 << i) for i in range(n)),
            tuple(chk[x] & ~(1 << x) if x < n else chk[x] for x in range(n + k)),
            tuple(fwd[i] & ~(1 << i) for i in range(n)), tuple(hi))


# ------------------------------------------------------------------ symmetry
def _pm(mask, perm):
    r = 0
    i = 0
    while mask:
        if mask & 1:
            r |= 1 << perm[i]
        mask >>= 1
        i += 1
    return r


def permute(s, perm, wperm):
    n, k, hbr, chk, fwd, hi = s
    hbr2 = [0] * n
    fwd2 = [0] * n
    chk2 = [0] * (n + k)
    hi2 = [0] * k
    for i in range(n):
        hbr2[perm[i]] = _pm(hbr[i], perm)
        fwd2[perm[i]] = _pm(fwd[i], perm)
        chk2[perm[i]] = _pm(chk[i], perm)
    for w in range(k):
        chk2[n + wperm[w]] = _pm(chk[n + w], perm)
        hi2[wperm[w]] = _pm(hi[w], perm)
    return (n, k, tuple(hbr2), tuple(chk2), tuple(fwd2), tuple(hi2))


def canonical(s):
    n, k = s[0], s[1]
    return min(permute(s, p, wp) for p in permutations(range(n)) for wp in permutations(range(k)))


def edges(s):
    n, k, hbr, chk, fwd, hi = s
    return sum(bin(v).count("1") for row in (hbr, chk, fwd, hi) for v in row)


# ------------------------------------------------------------------ JSON
def to_json(s, name=""):
    n, k, hbr, chk, fwd, hi = s
    mons = [MON_NAMES[i] for i in range(n)]
    works = [WORK_NAMES[w] for w in range(k)]
    procs = mons + works

    def lst(mask):
        return [mons[i] for i in range(n) if mask >> i & 1]

    return {
        "name": name, "f": 1, "monitors": mons, "works": works, "joiner": None,
        "boundary": {m: "b_" + m for m in mons}, "substrate": {},
        "hb_readers": {mons[i]: lst(hbr[i]) for i in range(n)},
        "checkers": {procs[x]: lst(chk[x]) for x in range(n + k)},
        "fwd": {mons[i]: lst(fwd[i]) for i in range(n)},
        "halt_inputs": {works[w]: lst(hi[w]) for w in range(k)},
        "switches": [], "coupling": True, "window": 0, "gate": True, "slow_reports": False,
    }


def from_json(d):
    mons = list(d["monitors"])
    works = list(d["works"])
    idx = {m: i for i, m in enumerate(mons)}

    def mask(lst):
        r = 0
        for m in lst or []:
            r |= 1 << idx[m]
        return r

    n, k = len(mons), len(works)
    return (n, k,
            tuple(mask(d.get("hb_readers", {}).get(m)) for m in mons),
            tuple(mask(d.get("checkers", {}).get(x)) for x in mons + works),
            tuple(mask(d.get("fwd", {}).get(m)) for m in mons),
            tuple(mask(d.get("halt_inputs", {}).get(w)) for w in works))


# ------------------------------------------------------------------ enumeration helpers
def others_masks(n, i):
    """All masks over the n monitors that do not contain i."""
    return [c for c in range(1 << n) if not c >> i & 1]


def all_rows_no_self(n):
    """All tuples (row_0..row_{n-1}) with row_i a mask not containing i."""
    return list(product(*[others_masks(n, i) for i in range(n)]))
