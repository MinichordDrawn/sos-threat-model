"""part-a 1.1: W 'checked by every monitor that checks any state' against W 'checked by all four'."""
import json, sys, os, itertools
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys
from ring import *
from a1_compute import NODES, ARROWS, arrows_of

D = json.load(open(os.path.join(os.path.dirname(__file__), "a1.json")))
AIDX = {a: i for i, a in enumerate(ARROWS)}
CAND = [("A", "B"), ("B", "C"), ("C", "A"), ("D", "A"), ("D", "B"), ("D", "C"), ("A", "D"), ("B", "D"), ("C", "D")]
CMASK = sum(1 << AIDX[a] for a in CAND)
ALL6 = ["R1", "R2", "R3", "R4", "R5", "R6"]
for rname, reading in READINGS.items():
    static = []
    for mask in range(4096):
        hb, chk, fwd = edges_of(arrows_of(mask), reading)
        static.append({"R2": R2(NODES, hb, chk), "R3": R3(NODES, hb, chk, "D"), "R4": True, "R5": R5(NODES, fwd, "D")})
    for f in (1, 2, 3):
        alt = []
        ndiff = 0
        ex = None
        for mask in range(4096):
            hb, chk, fwd = edges_of(arrows_of(mask), reading)
            d = make_system(NODES, hb, chk, fwd, "all", f, "D", "A")
            d["checkers"]["W"] = sorted({m for (x, m) in chk})
            s = Sys(d)
            r = s.solve_plain(want_told_mask=1 << s.idx["D"])
            alt.append([r["G1"], r["G2"], r["told"]])
            if alt[-1] != D["%s|all|%d" % (rname, f)][mask]:
                ndiff += 1
                if ex is None:
                    ex = (mask, alt[-1], D["%s|all|%d" % (rname, f)][mask])
        base = D["%s|all|%d" % (rname, f)]

        def meets(tab, mask, r):
            if r in static[mask]:
                return static[mask][r]
            g1, g2, told = tab[mask]
            return (g1 is None and g2 is None) if r == "R1" else (g2 is None and told is None)
        rowdiff = 0
        for n in range(1, 7):
            for combo in itertools.combinations(ALL6, n):
                out = []
                for tab in (base, alt):
                    ok = [m for m in range(4096) if all(meets(tab, m, r) for r in combo)]
                    k = min(bin(m).count("1") for m in ok) if ok else None
                    ls = [m for m in ok if bin(m).count("1") == k]
                    out.append((k, len(ls), CMASK in ls))
                if out[0] != out[1]:
                    rowdiff += 1
                    if rowdiff <= 3:
                        print("   row differs:", rname, f, combo, "all four check W:", out[0], "state-checkers check W:", out[1])
        print("%s f=%d: systems whose (G1, G2, told) differ: %d of 4096 (first: %s); table rows (least, count, candidate) that differ: %d of 63"
              % (rname, f, ndiff, ex, rowdiff), flush=True)
