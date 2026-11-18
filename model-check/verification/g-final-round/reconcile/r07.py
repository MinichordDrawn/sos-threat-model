import os, sys, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rc import *
sys.path.insert(0, os.path.join(MC, "verification", "a-reimplementation"))
import impl_a
for c in load_cases():
    if c["id"].startswith("mesh3-unread"):
        r = impl_a.explore(c["system"])
        print(c["id"], r[:2], "states:", r[2] if len(r) > 2 else None, "results.json:", (c["G1"], c["G2"]))
# the ten removals' judgement columns of section 7, from results.json
by = {c["id"]: c for c in load_cases()}
for p in cm.PROPS:
    c = by[f"R-{p}/f1"]; print(f"  R-{p:<5} G1={c['G1']} G2={c['G2']}")
# section 10.1 edge removals about the coordinator
for k, c in by.items():
    if "minus" in k and ("KA" in k):
        print("  ", k.split("minus: ")[1], "->", "needed" if (c["G1"] or c["G2"]) else "spare")
# R single-edge removals: 18 of 27 spare?
needed = spare = 0
for label, s in cm.ablations(cm.reference()):
    first, _ = cm.explore(s)
    if first["G1"] or first["G2"]: needed += 1
    else: spare += 1
print("R single edges: needed", needed, "spare", spare)
