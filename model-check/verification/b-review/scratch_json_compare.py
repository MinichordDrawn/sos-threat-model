import os
"""Scratch: recompute every case the script wrote with --json, from the JSON system alone,
using the independent implementation, and compare with the script's G1/G2."""
import json
import sys
import time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from scratch_indep import Spec

cases = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "scratch_cases.json"),
                       encoding="utf-8"))
t0 = time.time()
diff = 0
for c in cases:
    res, states, layers = Spec(c["system"]).result()
    same = res["G1"] == c["G1"] and res["G2"] == c["G2"]
    diff += not same
    print(f"{'ok ' if same else 'DIFF'} {c['id']:<62} script G1={c['G1']} G2={c['G2']}  "
          f"independent G1={res['G1']} G2={res['G2']} ({states} states, {layers} layers)", flush=True)
print(f"{len(cases)} cases, {diff} differences, {time.time() - t0:.0f}s")
