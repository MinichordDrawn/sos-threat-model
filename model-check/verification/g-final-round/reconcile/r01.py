import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rc import *

cases = load_cases()
print("cases:", len(cases))
# --- Theorem S outside plain systems (F2/B46)
print("\n[S] conditions hold, not plain, f=1, a judgement broken:")
tally = {}
for c in cases:
    s = from_data(c["system"])
    if s.f != 1: continue
    suff, plain = cm.sufficient_f1(s), cm.is_plain(s)
    ok = c["G1"] is None and c["G2"] is None
    if plain:
        tally[(suff, ok)] = tally.get((suff, ok), 0) + 1
    if suff and not plain and not ok:
        print("  ", c["id"], c["G1"], c["G2"])
print("plain tally:", tally, "total", sum(tally.values()))

# --- recompute a few from scratch against results.json
byid = {c["id"]: c for c in cases}
for cid, sysm in (("R/f1", cm.reference()), ("R-P8b/f1", cm.reference(without=("P8b",))),
                  ("R-gate/f1", cm.reference(without=("gate",))), ("R-P4/f1", cm.reference(without=("P4",))),
                  ("R-P8/f1", cm.reference(without=("P8",))),
                  ("mesh4/f3", cm.mesh(4, 3)), ("mesh4-one-boundary/f1", cm.mesh(4, 1, one_boundary=True)),
                  ("reflex-relayed-instant/f1", cm.reflex(False, False)), ("reflex-relayed-slow/f1", cm.reflex(False, True)),
                  ("nested3-upper3/f1", cm.nested(3, True, 1))):
    first, states = cm.explore(sysm)
    print(f"  {cid:<28} G1={n(first['G1'])} G2={n(first['G2'])} states={states}  json=({byid[cid]['G1']},{byid[cid]['G2']})")

# --- P8b and gate G1 executions
for p in ("P8b", "gate"):
    first, _ = cm.explore(cm.reference(without=(p,)))
    print(f"\nR without {p}: shortest G1 execution")
    cm.show(first["G1"])
