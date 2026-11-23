"""The reader's model against independent_model_join.py on the 49,152 ring systems (G1, G2),
and X11: the scoped path with one scope against the unscoped path (G1, G2, told)."""
import json, sys, os, importlib.util
here = os.path.dirname(__file__)
sys.path.insert(0, here)
from rmodel import Sys
from ring import *
from a1_compute import NODES, arrows_of

spec = importlib.util.spec_from_file_location("imj", os.path.join(here, "..", "independent_model_join.py"))
imj = importlib.util.module_from_spec(spec)
spec.loader.exec_module(imj)

D = json.load(open(os.path.join(here, "a1.json")))
diff = 0
diff11 = 0
n = 0
n11 = 0
for rname, reading in READINGS.items():
    for work in ("all", "two"):
        for f in (1, 2, 3):
            key = "%s|%s|%d" % (rname, work, f)
            for mask in range(4096):
                hb, chk, fwd = edges_of(arrows_of(mask), reading)
                d = make_system(NODES, hb, chk, fwd, work, f, "D", "A")
                g1, g2, ns, ok = imj.solve_system(d)
                n += 1
                if [g1, g2] != D[key][mask][:2]:
                    diff += 1
                    if diff < 5:
                        print("DIFF", key, mask, (g1, g2), D[key][mask])
                if mask % 7 == 0:      # X11 on a seventh of them
                    ds = make_system(NODES, hb, chk, fwd, work, f, "D", "A", scoped=True)
                    for fr in (False, True):
                        ds["freeze"] = fr
                        r = Sys(ds).solve()
                        n11 += 1
                        if [r["G1"], r["G2"], r["told"]] != D[key][mask] or r["spill"] is not None:
                            diff11 += 1
                            if diff11 < 5:
                                print("X11 DIFF", key, mask, r, D[key][mask])
            print(key, "done", flush=True)
print("independent implementation: %d systems, %d differences" % (n, diff))
print("X11 (one scope, told [D], freeze on and off): %d runs, %d differences" % (n11, diff11))
