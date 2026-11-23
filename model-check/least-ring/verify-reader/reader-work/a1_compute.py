"""Part A, connections: all 4,096 wirings, both readings, both works, f = 1, 2, 3.
Writes a1.json: key 'reading|work|f' -> list over wiring mask of [G1, G2, told]."""
import json, sys, os, time
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys
from ring import *

NODES = ["A", "B", "C", "D"]
ARROWS = [(x, y) for x in NODES for y in NODES if x != y]   # 12


def arrows_of(mask):
    return [ARROWS[i] for i in range(12) if mask >> i & 1]


if __name__ == "__main__":
    out = {}
    t0 = time.time()
    for rname, reading in READINGS.items():
        for work in ("all", "two"):
            for f in (1, 2, 3):
                res = []
                for mask in range(4096):
                    hb, chk, fwd = edges_of(arrows_of(mask), reading)
                    s = Sys(make_system(NODES, hb, chk, fwd, work, f, "D", "A"))
                    r = s.solve_plain(want_told_mask=1 << s.idx["D"])
                    res.append([r["G1"], r["G2"], r["told"]])
                out["%s|%s|%d" % (rname, work, f)] = res
                print(rname, work, f, "done", round(time.time() - t0, 1), flush=True)
    json.dump(out, open(os.path.join(os.path.dirname(__file__), "a1.json"), "w"))
