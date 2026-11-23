#!/usr/bin/env python3
"""Part A's table recomputed with mr_model.py as it stands at the end of the work.

part-a-connections.json was computed before the later additions to mr_model.py (freeze,
a bound on rounds, late work processes). None of them touches a single ring with nothing
joining. This recomputes G1, G2 and told for all 49,152 systems and compares.

Run:  python -B part_a_recheck.py
"""
import json
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import mr_ring as R  # noqa: E402
import mr_model as mm  # noqa: E402

PAIRS = R.all_pairs(R.NODES4)
table = json.load(open(os.path.join(HERE, "part-a-connections.json"), encoding="utf-8"))
n = bad = 0
for key, rows in table.items():
    reading, work = key.split("/")
    for mask in range(1 << 12):
        conns = [p for i, p in enumerate(PAIRS) if (mask >> i) & 1]
        E = R.edges_of(conns, reading)
        for f in (1, 2, 3):
            r = mm.explore(R.ring_system(E, R.NODES4, "D", work, f))
            n += 1
            if [r["G1"], r["G2"], r["told"]] != list(rows[mask][f"raw@{f}"]):
                bad += 1
print(f"{n} systems recomputed, {bad} different from part-a-connections.json")
