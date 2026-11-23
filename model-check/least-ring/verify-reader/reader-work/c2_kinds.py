"""results-minimal 4.1, kind by kind: every ring (upper ring included) with only its 19 edges,
and the fewest spare edges (on the tower's own arrows) that must be added.
The search RELIES on monotonicity: Lemma M as one system; for the scoped judgements a scoped
form of it that neither write-up states (see the hand-back)."""
import sys, os, time
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys, bits
from tower import system, tower

t = tower(2)


def build(rname):
    hb, chk, fwd = set(), set(), set()
    spare = []
    for (mem, d, kind) in t["rings"]:
        a, b, c = mem
        for (x, y) in ((a, b), (b, c), (c, a)):
            z, r = (x, y) if rname == "flow" else (y, x)     # r watches z
            hb.add((z, r)); chk.add((z, r))
            spare.append(("fwd", x, y))
        for x in mem:
            hb.add((x, d)); chk.add((x, d)); fwd.add((x, d))
            spare.append(("fwd", d, x))
        for x in (a, b):
            hb.add((d, x)); chk.add((d, x))
        spare.append(("hb", d, c)); spare.append(("chk", d, c))
    assert len(hb) + len(chk) + len(fwd) == 76 and len(spare) == 32
    return hb, chk, fwd, spare


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


def min_sets(pred, nbits):
    ALL = (1 << nbits) - 1
    clauses = []
    while True:
        hs = min_hitting(clauses)
        fails = [h for h in hs if not pred(h)]
        if not fails:
            return sorted(hs)
        for h in fails:
            if any(not (h & c) for c in clauses):
                continue
            m = h
            for i in range(nbits):
                e = 1 << i
                if not (m & e) and not pred(m | e):
                    m |= e
            clauses.append(ALL & ~m)


def name(spare, mask):
    out = []
    for i, e in enumerate(spare):
        if mask >> i & 1:
            k, x, y = e
            out.append({"fwd": "%s reports to %s", "hb": "%s's signal read by %s", "chk": "%s's state checked by %s"}[k] % (x, y))
    return "; ".join(out)


for rname in ("flow", "actor"):
    hb, chk, fwd, spare = build(rname)
    cache = {}

    def sysd(mask, f, scoped):
        h, c, w = set(hb), set(chk), set(fwd)
        for i, e in enumerate(spare):
            if mask >> i & 1:
                {"hb": h, "chk": c, "fwd": w}[e[0]].add((e[1], e[2]))
        return system(2, rname, "all", f, scoped=scoped, freeze=True, edges=(h, c, w))

    def ok_one(mask, f):
        k = ("one", mask, f)
        if k not in cache:
            r = Sys(sysd(mask, f, False)).solve_plain(stop_any=True)
            cache[k] = r["G1"] is None and r["G2"] is None
        return cache[k]

    def ok_sc(mask, f, told=True):
        k = ("sc", mask, f)
        if k not in cache:
            r = Sys(sysd(mask, f, True)).solve_scoped()
            cache[k] = (r["G1"], r["G2"], r["told"], r["spill"])
        g1, g2, tl, sp = cache[k]
        return g1 is None and g2 is None and sp is None and (tl is None or not told)

    print("=== %s: 76 edges, as one system ===" % rname)
    r = Sys(sysd(0, 1, False)).solve_plain(stop_early=True, state_limit=60000)
    print("  nothing added, f=1: G1 %s G2 %s" % (r["G1"], r["G2"]))
    prev = None
    for f in (1, 2):
        t0 = time.time()
        ms = min_sets(lambda m: ok_one(m, f), 32)
        print("  f=%d: fewest to add: %d edges, %d sets  [%.0fs]" % (f, pc(ms[0]), len(ms), time.time() - t0), flush=True)
        for m in ms:
            print("       ", name(spare, m))
        prev = ms
    good3 = [m for m in prev if ok_one(m, 3)]
    print("  f=3: of the %d least sets for f=2, %d have no gap at f=3 (so the fewest at f=3 is %s)" % (
        len(prev), len(good3), pc(prev[0]) if good3 else "more than %d" % pc(prev[0])), flush=True)
    for m in good3:
        print("       ", name(spare, m))
    print("=== %s: 76 edges, with scopes, f=1, freeze ===" % rname)
    r = Sys(sysd(0, 1, True)).solve_scoped()
    print("  nothing added: G1 %s G2 %s told %s spill %s" % (r["G1"], r["G2"], r["told"], r["spill"]))
    for told in (True, False):
        t0 = time.time()
        ms = min_sets(lambda m: ok_sc(m, 1, told), 32)
        print("  %s: fewest to add: %d edges, %d sets  [%.0fs]" % (
            "G1, G2, told, spill" if told else "G1, G2, spill (told not asked)", pc(ms[0]), len(ms), time.time() - t0), flush=True)
        for m in ms:
            print("       ", name(spare, m))
