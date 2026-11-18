"""Last check, script 4: results.md section 4, "R gives each work process a single state
checker ... a higher tier would need more". Tries a single state checker at f = 2 and 3.

Run: python -I -B lc04_single_checker.py
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
FOLDER = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, FOLDER)
import check_model as cm  # noqa: E402


def res(s):
    first, states = cm.explore(s)
    return {g: (len(p) if p else None) for g, p in first.items()}, states


for n, f in ((3, 2), (4, 2), (4, 3)):
    s = cm.mesh(n, f)
    s.checkers["W"] = ["M1"]
    print(f"mesh of {n}, f={f}, the work process checked by M1 alone:", res(s))
    s = cm.mesh(n, f)
    print(f"mesh of {n}, f={f}, the work process checked by all:", res(s))

# R at f = 2 with every work process given all three monitors as halt sources, one checker each
r = cm.reference(f=2)
r.halt_inputs = {"W1": ["M1", "M2", "M3"], "W2": ["M1", "M2", "M3"], "J": ["M1", "M2", "M3"]}
print("R at f=2, three halt sources each, one state checker each:", res(r))
for g in ("G1", "G2"):
    first, _ = cm.explore(r)
    if first[g]:
        print("  shortest", g, [(steps, info["bad"], info["out"], info["executed"]) for steps, info in first[g]])
r = cm.reference(f=2)
print("R at f=2 as built:", res(r))
r = cm.reference(f=2)
r.checkers["W1"] = ["M1", "M2", "M3"]; r.checkers["W2"] = ["M1", "M2", "M3"]; r.checkers["J"] = ["M1", "M2", "M3"]
print("R at f=2, three state checkers each, two halt sources each:", res(r))
