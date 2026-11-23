"""Readings in which the signal and the state check run opposite ways along an arrow, with R2
counted as 'two signal readers and two state checkers' (not necessarily the same two nodes)
and R3 counted along signal reads or along state checks."""
import sys, os, itertools
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys
from ring import *
from a1_compute import NODES, ARROWS, arrows_of

AIDX = {a: i for i, a in enumerate(ARROWS)}
CAND = [("A", "B"), ("B", "C"), ("C", "A"), ("D", "A"), ("D", "B"), ("D", "C"), ("A", "D"), ("B", "D"), ("C", "D")]
CMASK = sum(1 << AIDX[a] for a in CAND)


def r2split(hb, chk):
    return all(sum(1 for r in NODES if (z, r) in hb) >= 2 and sum(1 for r in NODES if (z, r) in chk) >= 2 for z in NODES)


for reading in (("f", "b", "f"), ("b", "f", "f"), ("f", "b", "b"), ("b", "f", "b"), ("f", "f", "f"), ("b", "b", "f")):
    for r3kind in ("watch", "read", "check"):
        def ok(mask, f=1, work="all"):
            hb, chk, fwd = edges_of(arrows_of(mask), reading)
            r3 = {"watch": R3(NODES, hb, chk, "D"), "read": R3(NODES, hb, hb, "D"), "check": R3(NODES, chk, chk, "D")}[r3kind]
            if not (r2split(hb, chk) and r3 and R5(NODES, fwd, "D")):
                return False
            s = Sys(make_system(NODES, hb, chk, fwd, work, f, "D", "A"))
            r = s.solve_plain(want_told_mask=1 << s.idx["D"])
            return r["G1"] is None and r["G2"] is None and r["told"] is None
        found = None
        for k in range(13):
            ls = [m for m in range(4096) if bin(m).count("1") == k and ok(m)]
            if ls:
                found = (k, ls)
                break
        c = [ok(CMASK, f) for f in (1, 2, 3)]
        print("read %s check %s report %s | R2 as two readers and two checkers | R3 along %-5s: least %s connections (%s wirings); "
              "candidate meets the list at f=1,2,3: %s; candidate least: %s" % (
                  reading + (r3kind, found[0] if found else None, len(found[1]) if found else 0, c,
                             bool(found) and CMASK in found[1])), flush=True)
