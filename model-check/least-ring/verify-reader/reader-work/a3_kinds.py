"""Part A section 3: kind by kind, 36 edges."""
import sys, os, itertools, time
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys, bits
from ring import *

NODES = ["A", "B", "C", "D"]
PAIRS = [(x, y) for x in NODES for y in NODES if x != y]     # 12 ordered pairs
PI = {p: i for i, p in enumerate(PAIRS)}
# edge index: hb (x,y): y reads x's signal -> i ; chk (x,y): y checks x -> 12+i ; fwd (x,y): x reports to y -> 24+i
ALL = (1 << 36) - 1


def HB(x, y):
    return 1 << PI[(x, y)]


def CK(x, y):
    return 1 << (12 + PI[(x, y)])


def FW(x, y):
    return 1 << (24 + PI[(x, y)])


def sets_of(mask):
    hb = {PAIRS[i] for i in range(12) if mask >> i & 1}
    chk = {PAIRS[i] for i in range(12) if mask >> (12 + i) & 1}
    fwd = {PAIRS[i] for i in range(12) if mask >> (24 + i) & 1}
    return hb, chk, fwd


_cache = {}


def run(mask, work, f):
    k = (mask, work, f)
    if k not in _cache:
        hb, chk, fwd = sets_of(mask)
        s = Sys(make_system(NODES, hb, chk, fwd, work, f, "D", "A"))
        r = s.solve_plain(want_told_mask=1 << s.idx["D"])
        _cache[k] = (r["G1"], r["G2"], r["told"])
    return _cache[k]


def req(name, mask, work, f):
    if name == "R1":
        g = run(mask, work, f)
        return g[0] is None and g[1] is None
    if name == "R6":
        g = run(mask, work, f)
        return g[1] is None and g[2] is None
    hb, chk, fwd = sets_of(mask)
    if name == "R2":
        return R2(NODES, hb, chk)
    if name == "R3":
        return R3(NODES, hb, chk, "D")
    if name == "R5":
        return R5(NODES, fwd, "D")
    if name == "R4":
        return True
    if name == "R4wl":
        return R4wl(NODES, hb, chk)
    if name == "R2read":      # the other choice: an observer is a signal reader
        return all(sum(1 for r in NODES if (z, r) in hb) >= 2 for z in NODES)
    if name == "R3read":
        return R3(NODES, hb, hb, "D")
    if name == "R2split":     # two readers and two checkers, not necessarily the same two
        return all(sum(1 for r in NODES if (z, r) in hb) >= 2 and sum(1 for r in NODES if (z, r) in chk) >= 2
                   for z in NODES)
    raise ValueError(name)


def pc(x):
    return bin(x).count("1")


def min_hitting(clauses):
    if not clauses:
        return {0}
    k = 0
    while True:
        res = set()
        seen = set()

        def dfs(cur, depth):
            if cur in seen:
                return
            seen.add(cur)
            best = None
            bp = 99
            for c in clauses:
                if not (c & cur):
                    p = pc(c)
                    if p < bp:
                        best, bp = c, p
                        if p <= 1:
                            break
            if best is None:
                res.add(cur)
                return
            if depth == k:
                return
            for b in bits(best):
                dfs(cur | b, depth + 1)
        dfs(0, 0)
        if res:
            return res
        k += 1


def min_sets(pred, verbose=False):
    """All sets of the fewest edges that meet a monotone predicate.  RELIES ON MONOTONICITY
    (Lemma M for R1; its told variant for R6): a subset of a failing set is taken to fail."""
    clauses = []
    npred = 0
    while True:
        hs = min_hitting(clauses)
        fails = [h for h in hs if not pred(h)]
        npred += len(hs)
        if not fails:
            return sorted(hs), len(clauses)
        for h in fails:
            if any(not (h & c) for c in clauses):
                continue
            m = h
            for i in range(36):
                e = 1 << i
                if not (m & e) and not pred(m | e):
                    m |= e
            clauses.append(ALL & ~m)
        if verbose:
            print("   clauses:", len(clauses), "current least size:", pc(next(iter(hs))), flush=True)


def perm_mask(mask, p):
    m = 0
    for i in range(36):
        if mask >> i & 1:
            x, y = PAIRS[i % 12]
            m |= 1 << ((i // 12) * 12 + PI[(p.get(x, x), p.get(y, y))])
    return m


PERMS_ALL = [dict(zip("ABC", q)) for q in itertools.permutations("ABC")]
PERMS_TWO = [{}, {"B": "C", "C": "B"}]


def shapes(masks, work="all"):
    perms = PERMS_ALL if work == "all" else PERMS_TWO
    return len({min(perm_mask(m, p) for p in perms) for m in masks})


def describe(mask):
    hb, chk, fwd = sets_of(mask)
    return "reads %s | checks %s | reports %s" % (
        " ".join("%s<%s" % (p, r) for p, r in sorted(hb)), " ".join("%s<%s" % (x, m) for x, m in sorted(chk)),
        " ".join("%s>%s" % (m, r) for m, r in sorted(fwd)))


if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "all"
    WHOLE = ["R1", "R2", "R3", "R4", "R5", "R6"]

    if which in ("81", "all"):
        print("=== the 81 sets of exactly 19 edges that meet R2 and R5 (no Lemma M) ===")
        base = FW("A", "D") | FW("B", "D") | FW("C", "D")
        cands = []
        for choice in itertools.product(*[list(itertools.combinations([r for r in NODES if r != z], 2)) for z in NODES]):
            m = base
            for z, ws in zip(NODES, choice):
                for r in ws:
                    m |= HB(z, r) | CK(z, r)
            cands.append(m)
        assert len(set(cands)) == 81 and all(pc(m) == 19 for m in cands)
        for work, fs in (("all", (1, 2, 3)), ("two", (1, 2))):
            for f in fs:
                ok = [m for m in cands if all(req(r, m, work, f) for r in WHOLE)]
                why = {}
                for m in cands:
                    if m not in ok:
                        w = tuple(r for r in WHOLE if not req(r, m, work, f))
                        why[w] = why.get(w, 0) + 1
                print("W reads %s f=%d: %d of 81 meet the whole list (%d shapes); failures by requirement: %s" % (
                    work, f, len(ok), shapes(ok, work) if ok else 0, why))
                if work == "all" and f == 1:
                    ok1 = ok
        # any report edge other than the three to D in a least set?  By construction none.
        # which of the 81 lie on the candidate's arrows, per reading
        CAND = [("A", "B"), ("B", "C"), ("C", "A"), ("D", "A"), ("D", "B"), ("D", "C"), ("A", "D"), ("B", "D"), ("C", "D")]
        for rname, reading in READINGS.items():
            hb, chk, fwd = edges_of(CAND, reading)
            cm = 0
            for p in hb:
                cm |= HB(*p)
            for p in chk:
                cm |= CK(*p)
            for p in fwd:
                cm |= FW(*p)
            assert pc(cm) == 27
            for work in ("all", "two"):
                inside = [m for m in cands if (m & ~cm) == 0 and all(req(r, m, work, 1) for r in WHOLE)]
                must = cm
                for m in inside:
                    must &= m
                spare = cm
                for m in inside:
                    spare &= ~m
                print(" candidate arrows as %s, W reads %s: %d sets of 19 inside its 27 edges; in every such set: %d edges; in none: %d edges"
                      % (rname, work, len(inside), pc(must), pc(spare)))
                if work == "all":
                    print("    edges in none of them:", describe(spare))
                    union = 0
                    for m in inside:
                        union |= m
                    print("    edges in some but not all:", describe(union & ~must))
                    # removing any one of the 19
                    for m in inside:
                        for i in range(36):
                            if m >> i & 1:
                                fl = [r for r in WHOLE if not req(r, m & ~(1 << i), work, 1)]
                                assert fl and set(fl) <= {"R2", "R5"}, (describe(m), i, fl)
                    print("    removing any single one of the 19 fails R2 or R5 and nothing else: confirmed for f=1")
                # with R4wl
                best = None
                for extra in range(0, 9):
                    found = []
                    rest = [i for i in range(36) if (cm >> i & 1)]
                    # sets inside cm of size 19+extra meeting whole list + R4wl
                    if extra > 3:
                        break
                    for m in inside:
                        free = [i for i in rest if not (m >> i & 1)]
                        for add in itertools.combinations(free, extra):
                            mm = m
                            for i in add:
                                mm |= 1 << i
                            if req("R4wl", mm, work, 1):
                                found.append(mm)
                    if found:
                        print("    with R4wl, fewest edges on the candidate's arrows:", 19 + extra, "sets:", len(set(found)))
                        break

    if which in ("r1brute", "all"):
        print("=== R1 alone, W reads all, f=1: every set of at most six edges in which each monitor has a state checker ===")
        print("    (a monitor with no checker other than itself is mutated in round 1 and G1 is violated: from the")
        print("     specification directly, so no set left out can have no gap; Lemma M is not used)")
        t0 = time.time()
        chkbits = [12 + i for i in range(12)]
        others = [i for i in range(36) if i not in chkbits]
        count = {}
        good = {}
        for c in range(4, 7):
            for cs in itertools.combinations(chkbits, c):
                tg = {PAIRS[i - 12][0] for i in cs}
                if len(tg) < 4:
                    continue
                cm = sum(1 << i for i in cs)
                for o in range(0, 7 - c):
                    for os_ in itertools.combinations(others, o):
                        m = cm | sum(1 << i for i in os_)
                        count[c + o] = count.get(c + o, 0) + 1
                        if req("R1", m, "all", 1):
                            good.setdefault(c + o, []).append(m)
        print("    explored by size:", count, "no gap by size:", {k: len(v) for k, v in good.items()},
              "shapes of the six-edge ones:", shapes(good.get(6, [])), "time", round(time.time() - t0, 1))
        for m in sorted({min(perm_mask(m, p) for p in PERMS_ALL) for m in good.get(6, [])}):
            print("     ", describe(m))
        _cache.clear()

    if which in ("rows", "all"):
        print("=== table 3.2 by the monotone search (RELIES on Lemma M / its told variant) ===")
        rows = [("R1", ["R1"], (1, 2, 3)), ("R6", ["R6"], (1, 2, 3)), ("R1+R6", ["R1", "R6"], (1, 2, 3)),
                ("R3", ["R3"], (1,)), ("R2+R5", ["R2", "R5"], (1,)),
                ("all but R2", ["R1", "R3", "R4", "R5", "R6"], (1,)), ("whole list", WHOLE, (1, 2, 3)),
                ("R3 as signal reads", ["R3read"], (1,)),
                ("whole list, R3 as signal reads", ["R1", "R2", "R3read", "R5", "R6"], (1,)),
                ("whole list, an observer is a signal reader (R2, R3)", ["R1", "R2read", "R3read", "R5", "R6"], (1, 2, 3)),
                ("whole list, R2 as two readers and two checkers, any nodes", ["R1", "R2split", "R3", "R5", "R6"], (1,)),
                ]
        for work in ("all", "two"):
            for label, reqs, fs in rows:
                for f in fs:
                    if work == "two" and f > 1:
                        continue
                    t0 = time.time()
                    ms, ncl = min_sets(lambda m: all(req(r, m, work, f) for r in reqs))
                    print("W reads %s | %-55s f=%d: %d edges (%d sets, %d shapes)  [%d clauses, %.0fs]" % (
                        work, label, f, pc(ms[0]), len(ms), shapes(ms, work), ncl, time.time() - t0), flush=True)
                    if label == "R1" and f == 1 and work == "all":
                        for m in sorted({min(perm_mask(m, p) for p in PERMS_ALL) for m in ms}):
                            print("      ", describe(m))
                    if label.startswith("whole list, an observer") and f == 1 and work == "all":
                        print("       e.g.", describe(ms[0]))
                    _cache.clear()
