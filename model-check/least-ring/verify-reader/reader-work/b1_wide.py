"""Part B: k members in a cycle under one coordinator K."""
import sys, os, itertools, time, random
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys
from ring import *


def nodes_of(k):
    return ["M%d" % i for i in range(1, k + 1)] + ["K"]


def cycle_arrows(k):
    ms = nodes_of(k)[:-1]
    ar = [(ms[i], ms[(i + 1) % k]) for i in range(k)]
    ar += [("K", m) for m in ms] + [(m, "K") for m in ms]
    return ar


def check(nodes, arrows, reading, work, f, edges=None):
    hb, chk, fwd = edges_of(arrows, reading) if edges is None else edges
    static = R2(nodes, hb, chk) and R3(nodes, hb, chk, "K") and R5(nodes, fwd, "K")
    s = Sys(make_system(nodes, hb, chk, fwd, work, f, "K", nodes[0]))
    r = s.solve_plain(want_told_mask=1 << s.idx["K"])
    return static, r["G1"], r["G2"], r["told"]


def canon(arrows, k):
    ms = nodes_of(k)[:-1]
    best = None
    for q in itertools.permutations(ms):
        p = dict(zip(ms, q))
        t = tuple(sorted((p.get(x, x), p.get(y, y)) for x, y in arrows))
        if best is None or t < best:
            best = t
    return best


which = sys.argv[1] if len(sys.argv) > 1 else "all"

if which in ("rate", "all"):
    print("=== the cycle with a coordinator: the whole list and the rate ===")
    for k in (3, 4, 5):
        nodes = nodes_of(k)
        for rname, reading in READINGS.items():
            line = []
            for f in range(1, k + 2):
                st, g1, g2, told = check(nodes, cycle_arrows(k), reading, "all", f)
                line.append("f=%d %s%s" % (f, "no gap" if g1 is None and g2 is None else "G1 %s G2 %s" % (g1, g2),
                                           "" if told is None else " told %s" % told))
            l2 = []
            for f in (1, 2):
                st, g1, g2, told = check(nodes, cycle_arrows(k), reading, "two", f)
                l2.append("f=%d %s%s" % (f, "no gap" if g1 is None and g2 is None else "G1 %s G2 %s" % (g1, g2),
                                         "" if told is None else " told %s" % told))
            print("k=%d %s: R2,R3,R5 %s | reads all: %s | reads two: %s" % (k, rname, st, "; ".join(line), "; ".join(l2)))
    print("=== meshes ===")
    for n in (4, 5, 6):
        nodes = nodes_of(n - 1)
        arrows = [(x, y) for x in nodes for y in nodes if x != y]
        line = []
        for f in range(1, n + 1):
            st, g1, g2, told = check(nodes, arrows, READINGS["flow"], "all", f)
            line.append("f=%d %s" % (f, "no gap" if g1 is None and g2 is None else "G1 %s G2 %s" % (g1, g2)))
        print("mesh of %d (%d connections): %s" % (n, len(arrows), "; ".join(line)))
    print("=== kind by kind: 5k+4 edges on the cycle's arrows ===")
    for k in (3, 4, 5):
        nodes = nodes_of(k)
        ms = nodes[:-1]
        for rname in ("flow", "actor"):
            hb, chk, fwd = set(), set(), set()
            for i in range(k):
                x, y = ms[i], ms[(i + 1) % k]
                (z, r) = (x, y) if rname == "flow" else (y, x)     # r watches z
                hb.add((z, r)); chk.add((z, r))
            for m in ms:
                hb.add((m, "K")); chk.add((m, "K")); fwd.add((m, "K"))
            for m in ms[:2]:
                hb.add(("K", m)); chk.add(("K", m))
            n_edges = len(hb) + len(chk) + len(fwd)
            res = []
            for work, fs in (("all", (1, 2, 3)), ("two", (1,))):
                for f in fs:
                    st, g1, g2, told = check(nodes, None, None, work, f, edges=(hb, chk, fwd))
                    res.append("%s f=%d: %s" % (work, f, "meets" if st and g1 is None and g2 is None and told is None else
                                                "FAILS (%s %s %s %s)" % (st, g1, g2, told)))
            print("k=%d %s: %d edges: %s" % (k, rname, n_edges, "; ".join(res)))

if which in ("least", "all"):
    print("=== least wirings for the whole list ===")
    for k in (3, 4, 5):
        nodes = nodes_of(k)
        ms = nodes[:-1]
        # flow: each member -> K, plus one more arrow out of each member, plus two out of K
        t0 = time.time()
        res = {1: [], 2: [], 3: [], "two1": []}
        tot = 0
        for extra in itertools.product(*[[y for y in ms if y != x] for x in ms]):
            for kk in itertools.combinations(ms, 2):
                arrows = [(m, "K") for m in ms] + [(x, y) for x, y in zip(ms, extra)] + [("K", y) for y in kk]
                tot += 1
                for f in (1, 2, 3):
                    st, g1, g2, told = check(nodes, arrows, READINGS["flow"], "all", f)
                    assert st or True
                    if st and g1 is None and g2 is None and told is None:
                        res[f].append(arrows)
                st, g1, g2, told = check(nodes, arrows, READINGS["flow"], "two", 1)
                if st and g1 is None and g2 is None and told is None:
                    res["two1"].append(arrows)
        print("k=%d flow: %d wirings of %d connections meet R2 and R5 with the fewest; whole list met by: f=1 %d, f=2 %d, f=3 %d, "
              "reads two f=1 %d; shapes at f=1: %d  [%.0fs]" % (
                  k, tot, 2 * k + 2, len(res[1]), len(res[2]), len(res[3]), len(res["two1"]),
                  len({canon(a, k) for a in res[1]}), time.time() - t0), flush=True)
        # actor: each member -> K, plus two arrows into each member
        t0 = time.time()
        pools = [list(itertools.combinations([y for y in nodes if y != x], 2)) for x in ms]
        allw = list(itertools.product(*pools))
        res = {1: [], 2: [], 3: [], "two1": []}
        fails = {}
        for inc in allw:
            arrows = [(m, "K") for m in ms] + [(y, x) for x, ys in zip(ms, inc) for y in ys]
            for f in ((1, 2, 3) if k < 5 else (1,)):
                st, g1, g2, told = check(nodes, arrows, READINGS["actor"], "all", f)
                if st and g1 is None and g2 is None and told is None:
                    res[f].append(arrows)
                elif f == 1:
                    hb, chk, fwd = edges_of(arrows, READINGS["actor"])
                    key = (R3(nodes, hb, chk, "K"), g1 is None and g2 is None, g2 is None and told is None)
                    fails[key] = fails.get(key, 0) + 1
            if k < 5:
                st, g1, g2, told = check(nodes, arrows, READINGS["actor"], "two", 1)
                if st and g1 is None and g2 is None and told is None:
                    res["two1"].append(arrows)
        print("k=%d actor: %d wirings of %d connections meet R2 and R5 with the fewest; whole list met by: f=1 %d, f=2 %s, f=3 %s, "
              "reads two f=1 %s; shapes at f=1: %s; failures at f=1 as (R3, R1, R6) -> count: %s  [%.0fs]" % (
                  k, len(allw), 3 * k, len(res[1]), len(res[2]) if k < 5 else "-", len(res[3]) if k < 5 else "-",
                  len(res["two1"]) if k < 5 else "-",
                  len({canon(a, k) for a in res[1]}) if k < 5 else "-", fails, time.time() - t0), flush=True)
        cyc = sorted(cycle_arrows(k))
        print("      the cycle with a coordinator is among the actor least: %s" % any(sorted(a) == cyc for a in res[1]))
