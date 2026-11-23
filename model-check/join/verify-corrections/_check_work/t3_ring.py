"""A12 / A13 / A2: ring B (B1,B2,B3,KB + WB) joining ring A (M1,M2,M3,K + W), both meshes, one step.
24 edges between KB and A."""
import itertools, random, sys, time
from build import *

A = ["M1", "M2", "M3", "K"]
B = ["B1", "B2", "B3", "KB"]
KINDS = ["cK", "rK", "fromK", "kc", "kr", "toK"]
# cK_X: X checks KB; rK_X: X reads KB's signal; fromK_X: KB reports to X;
# kc_X: KB checks X; kr_X: KB reads X's signal; toK_X: X reports to KB
EDGES = [(k, x) for x in A for k in KINDS]
EIX = {e: i for i, e in enumerate(EDGES)}

def ringsys(f, edges, ab, shape="mesh"):
    if shape == "mesh":
        s = base_mesh(f)
    else:
        s = base_cycle(f, "checking")
    for b in B:
        add_monitor(s, b)
    s["joiner"] = "WB"
    if shape == "mesh":
        for i, a in enumerate(B):
            for b in B[i + 1:]:
                mesh_pair(s, a, b)
    else:
        watch(s, "B1", "B2"); watch(s, "B2", "B3"); watch(s, "B3", "B1")
        report(s, "B1", "B3"); report(s, "B2", "B1"); report(s, "B3", "B2")
        for m in ("B1", "B2", "B3"):
            report(s, m, "KB"); report(s, "KB", m); watch(s, "KB", m); watch(s, m, "KB")
    for b in B:
        add(s, "checkers", "WB", b)
        add(s, "halt_inputs", "WB", b)
    for k, x in edges:
        if k == "cK": add(s, "checkers", "KB", x)
        elif k == "rK": add(s, "hb_readers", "KB", x)
        elif k == "fromK": add(s, "fwd", "KB", x)
        elif k == "kc": add(s, "checkers", x, "KB")
        elif k == "kr": add(s, "hb_readers", x, "KB")
        elif k == "toK": add(s, "fwd", x, "KB")
    late_group(s, "B", B + ["WB"])
    s["arrive_bad"] = ab
    return s

def mask(edges):
    m = 0
    for e in edges:
        m |= 1 << EIX[e]
    return m

def unmask(m):
    return [EDGES[i] for i in range(24) if m >> i & 1]

def listed(f):
    """the least attachments the write-up lists at rate f, as masks."""
    out = set()
    for c in A:
        for r in A:
            for t in A:
                first = [("cK", c), ("rK", r), ("fromK", t)]
                for x in A:
                    out.add(mask(first + [("kc", x), ("kr", x), ("toK", x)]))
                if f + 1 <= 4:
                    for xs in itertools.combinations(A, f + 1):
                        out.add(mask(first + [("toK", x) for x in xs]))
    return out

def min_transversals(sets):
    """Berge: minimal hitting sets of a family of bit masks."""
    T = {0}
    for E in sets:
        new = set()
        keep = set()
        for t in T:
            if t & E:
                keep.add(t)
            else:
                for i in range(24):
                    if E >> i & 1:
                        new.add(t | (1 << i))
        cand = keep | new
        # minimise
        res = []
        for c in sorted(cand, key=lambda z: bin(z).count("1")):
            if not any((r & c) == r for r in res):
                res.append(c)
        T = set(res)
    return T

FULL = (1 << 24) - 1
random.seed(20261122)
t0 = time.time()
cache = {}
def gap(f, m, ab):
    key = (f, m, ab)
    if key not in cache:
        cache[key] = not nogap(M(ringsys(f, unmask(m), ab)).solve(anygap=True))
    return cache[key]

print("=== listed least attachments, greatest sets, and checks (two meshes, one step)")
for f in (1, 2, 3):
    L = listed(f)
    sizes = {}
    for m in L:
        sizes[bin(m).count("1")] = sizes.get(bin(m).count("1"), 0) + 1
    # antichain?
    Ls = sorted(L)
    anti = not any(a != b and (a & b) == a for a in Ls for b in Ls)
    # greatest sets holding none = complements of minimal transversals
    MT = min_transversals(Ls)
    G = [FULL & ~t for t in MT]
    # sanity of G: holds none; adding any edge holds one
    def holds(s):
        return any((s & m) == m for m in Ls)
    okG = all(not holds(g) and all(holds(g | (1 << i)) for i in range(24) if not g >> i & 1) for g in G)
    gs = {}
    for g in G:
        gs[bin(g).count("1")] = gs.get(bin(g).count("1"), 0) + 1
    # the write-up's four cases, counted
    fam = 3 + sum(len(list(itertools.combinations(A, t))) * 2 ** t for t in range(0, f + 1))
    print("f=%d: listed %d (by size %s), antichain %s; greatest sets holding none: %d (by size %s, verified maximal %s); 3 + sum_{t<=f} C(4,t)2^t = %d"
          % (f, len(L), dict(sorted(sizes.items())), anti, len(G), gs, okG, fam))
    # every listed attachment: no gap at f, a member may arrive bad (also arriving good follows)
    bad = [m for m in Ls if gap(f, m, True)]
    print("   listed attachments with a gap at f=%d (may arrive bad): %d of %d" % (f, len(bad), len(Ls)))
    # cross-check a sample of them in full with independent_model.py
    for m in random.sample(Ls, 12):
        both(ringsys(f, unmask(m), True))
    # every greatest set: a gap at f, every member arriving good (so also when one may arrive bad)
    ng = [g for g in G if not gap(f, g, False)]
    print("   greatest sets with NO gap at f=%d (arrive good): %d of %d" % (f, len(ng), len(G)))
    for g in random.sample(G, min(8, len(G))):
        both(ringsys(f, unmask(g), False))
    # each listed attachment is least: removing any one edge gives a gap
    notmin = 0
    for m in Ls:
        for i in range(24):
            if m >> i & 1 and not gap(f, m & ~(1 << i), True):
                notmin += 1
    print("   listed attachments from which some single edge can be removed with no gap (may arrive bad): %d" % notmin)
    # random subsets against the rule 'no gap iff it holds a listed attachment'
    dis = 0
    n = 0
    for trial in range(150):
        mode = trial % 3
        if mode == 0:
            s = random.getrandbits(24)
        elif mode == 1:
            s = random.choice(G) & ~random.getrandbits(24) | (random.getrandbits(24) & random.getrandbits(24) & random.getrandbits(24))
        else:
            s = random.choice(Ls) | (random.getrandbits(24) & random.getrandbits(24))
        ab = bool(trial & 1)
        n += 1
        if gap(f, s, ab) == holds(s):
            dis += 1
            print("   DISAGREE", f, unmask(s), ab)
    print("   random subsets against the rule: %d tried, %d disagree" % (n, dis))
    print("   (%.0f s)" % (time.time() - t0))
    sys.stdout.flush()

print("=== the 20-edge set: every edge except the four reports from ring A to KB")
m20 = mask([e for e in EDGES if e[0] != "toK"])
for f in (1, 2, 3):
    r = M(ringsys(f, unmask(m20), False)).solve(trace=True)
    r2 = both(ringsys(f, unmask(m20), False)); r3 = both(ringsys(f, unmask(m20), True))
    print("  f=%d arrive good %s, may arrive bad %s" % (f, fmt(r2), fmt(r3)))
    if f == 1:
        show_trace(r["t2"])
for x in A:
    m21 = m20 | mask([("toK", x)])
    print("  plus the report from %s to KB: f=1,2,3 may arrive bad:" % x, [fmt(both(ringsys(f, unmask(m21), True))) for f in (1, 2, 3)])
L1 = listed(1)
print("  is the 20-edge set inside a set of the smaller family (3 + C(4,f)2^f with exactly f reporters)?")
for f in (1, 2, 3):
    small = [FULL & ~mask([("cK", x) for x in A]), FULL & ~mask([("rK", x) for x in A]), FULL & ~mask([("fromK", x) for x in A])]
    for T in itertools.combinations(A, f):
        for choice in itertools.product(("kc", "kr"), repeat=f):
            drop = [("toK", x) for x in A if x not in T] + [(c, x) for c, x in zip(choice, T)]
            small.append(FULL & ~mask(drop))
    print("   f=%d: smaller family has %d sets; 20-edge set inside one of them: %s" % (f, len(small), any((m20 & g) == m20 for g in small)))

print("=== A2 / A12: named attachments")
six = [("cK", "M1"), ("rK", "M1"), ("fromK", "M1"), ("kc", "M1"), ("kr", "M1"), ("toK", "M1")]
print("  one two-way link with M1 (six edges), meshes, f=1..4 may arrive bad:", [fmt(both(ringsys(f, six, True))) for f in (1, 2, 3, 4)])
five = [("cK", "M1"), ("rK", "M1"), ("fromK", "M1"), ("toK", "M2"), ("toK", "M3")]
print("  five edges (M1 watches KB, KB reports to M1, M2 and M3 report to KB), f=1,2,3 may arrive bad:", [fmt(both(ringsys(f, five, True))) for f in (1, 2, 3)])
five2 = [("cK", "M1"), ("rK", "M2"), ("fromK", "M3"), ("toK", "M1"), ("toK", "K")]
print("  five edges spread over monitors, f=1,2,3:", [fmt(both(ringsys(f, five2, True))) for f in (1, 2, 3)])
three = [("cK", "M1"), ("rK", "M1"), ("fromK", "M1")]
r = M(ringsys(1, three, False)).solve(trace=True)
print("  M1 watches KB and KB reports to M1 only: f=1", fmt(r)); show_trace(r["t2"])
for x in ("M1", "K"):
    sixc = [(k, x) for k in KINDS]
    print("  cycles with checking coordinators, one two-way link between KB and %s, f=1..4 may arrive bad:" % x,
          [fmt(both(ringsys(f, sixc, True, shape="cycle"))) for f in (1, 2, 3, 4)])
# fewest edges: every set of at most four edges has a gap at f=1 follows from the list; spot check all sets of 4 edges that contain cK,rK,fromK on M1
cnt = 0; ng = 0
for e in EDGES:
    if e in three: continue
    cnt += 1
    if not gap(1, mask(three + [e]), True):
        ng += 1
print("  four-edge sets {M1 checks KB, M1 reads KB, KB reports to M1, one more}: %d tried, %d with no gap at f=1" % (cnt, ng))
print("  total %.0f s; distinct systems solved: %d" % (time.time() - t0, len(cache)))
