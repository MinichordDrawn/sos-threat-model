# Section 8: the least attachments of KB to ring A, as the write-up lists them, tested for
# completeness at f = 1 and f = 2 over all 24 edges (both rings meshes, ring B and WB in one step).
# A family of sets is the complete list of least attachments if every listed set has no gap
# and every maximal set that contains no listed set has a gap (gaps only close as edges are added).
import itertools, sys, time
from sosmodel import Model, with_f
from systems import *
from t04_sections_6_10 import two_rings

fs = [int(x) for x in sys.argv[1].split(",")] if len(sys.argv) > 1 else [1, 2]
ALL24 = [(k, x) for x in BASE for k in KINDS]
t0 = time.time()
for f in fs:
    second = []
    for x in BASE:
        second.append([("NcX", x), ("NrX", x), ("XpN", x)])
    for xs in itertools.combinations(BASE, f + 1):
        second.append([("XpN", x) for x in xs])
    ok = bad = 0
    sizes = {}
    for a in BASE:
        for b in BASE:
            for c in BASE:
                for sec in second:
                    es = [("XcN", a), ("XrN", b), ("NpX", c)] + sec
                    s = two_rings("mesh", None, "one", kb_edges=es, arrive_bad=True)
                    if Model(with_f(s, f)).gap():
                        bad += 1
                        print("   listed set WITH a gap:", es)
                    else:
                        ok += 1
                        sizes[len(es)] = sizes.get(len(es), 0) + 1
    print("f=%d: listed sets %d, no gap %d, gap %d; sizes (edges: count) %s  [%.0fs]" % (f, ok + bad, ok, bad, sizes, time.time() - t0))
    sys.stdout.flush()
    # maximal sets containing no listed set
    maxsets = []
    for k in ("XcN", "XrN", "NpX"):
        maxsets.append([e for e in ALL24 if e[0] != k])
    for keep in itertools.combinations(BASE, f):          # the at most f monitors of A that still report to KB
        for drop in itertools.product(("NcX", "NrX"), repeat=f):
            gone = set(("XpN", x) for x in BASE if x not in keep) | set((d, x) for d, x in zip(drop, keep))
            maxsets.append([e for e in ALL24 if e not in gone])
    for ab in (True, False):
        g = n = 0
        for es in maxsets:
            s = two_rings("mesh", None, "one", kb_edges=es, arrive_bad=ab)
            n += 1
            if Model(with_f(s, f)).gap():
                g += 1
            else:
                print("   maximal set WITHOUT a gap (arrive_bad=%s): missing %s" % (ab, [e for e in ALL24 if e not in es]))
        print("f=%d arrive_bad=%s: maximal sets holding no listed set %d, with a gap %d  [%.0fs]" % (f, ab, n, g, time.time() - t0))
        sys.stdout.flush()
