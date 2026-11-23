"""Part A: slow reports (section 5) and other readings of an arrow (section 1.2)."""
import sys, os, itertools
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys
from ring import *
from a1_compute import NODES, ARROWS, arrows_of

AIDX = {a: i for i, a in enumerate(ARROWS)}
CAND = [("A", "B"), ("B", "C"), ("C", "A"), ("D", "A"), ("D", "B"), ("D", "C"), ("A", "D"), ("B", "D"), ("C", "D")]
CMASK = sum(1 << AIDX[a] for a in CAND)

which = sys.argv[1] if len(sys.argv) > 1 else "all"

if which in ("slow", "all"):
    print("=== section 5: where a report takes a round ===")
    for label, mask in (("candidate", CMASK), ("mesh", 4095)):
        for rname, reading in READINGS.items():
            for work in ("all", "two"):
                out = []
                for f in (1, 2, 3):
                    hb, chk, fwd = edges_of(arrows_of(mask), reading)
                    s = Sys(make_system(NODES, hb, chk, fwd, work, f, "D", "A", slow=True))
                    r = s.solve_plain(want_told_mask=1 << s.idx["D"])
                    out.append("f=%d G1 %s G2 %s told %s" % (f, r["G1"], r["G2"], r["told"]))
                print("%-9s %-5s W reads %-3s: %s" % (label, rname, work, " | ".join(out)))

if which in ("readings", "all"):
    print("=== other readings of an arrow: each kind along the arrow (f), against it (b), or both (fb) ===")
    print("    read f: Y reads X's signal; check f: Y checks X's state; report f: X reports to Y   (for X -> Y)")
    for work, f in (("all", 1),):
        for reading in itertools.product(("f", "b", "fb"), repeat=3):
            cache = {}

            def ok(mask):
                hb, chk, fwd = edges_of(arrows_of(mask), reading)
                if not (R2(NODES, hb, chk) and R3(NODES, hb, chk, "D") and R5(NODES, fwd, "D")):
                    return False
                s = Sys(make_system(NODES, hb, chk, fwd, work, f, "D", "A"))
                r = s.solve_plain(want_told_mask=1 << s.idx["D"])
                return r["G1"] is None and r["G2"] is None and r["told"] is None
            bysize = {}
            for mask in range(4096):
                bysize.setdefault(bin(mask).count("1"), []).append(mask)
            found = None
            for k in range(13):
                ls = [m for m in bysize[k] if ok(m)]
                if ls:
                    found = (k, ls)
                    break
            cand_ok = ok(CMASK)
            name = {("f", "f", "f"): "  <- flow", ("b", "b", "f"): "  <- actor",
                    ("b", "b", "b"): "  <- mirror of flow", ("f", "f", "b"): "  <- mirror of actor"}.get(reading, "")
            if found is None:
                print("read %-2s check %-2s report %-2s: no wiring meets the list; candidate meets it: %s%s" % (
                    reading + (cand_ok, name)))
            else:
                print("read %-2s check %-2s report %-2s: least %2d connections (%3d wirings); candidate meets the list: %-5s; "
                      "candidate least: %s%s" % (reading + (found[0], len(found[1]), cand_ok, CMASK in found[1], name)))
