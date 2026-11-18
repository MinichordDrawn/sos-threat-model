"""Every plain system with 2 monitors and 2 work processes (no self-loops), each decided on its
own by check_model.explore. Count those with no gap, and those with no spare monitor."""
import itertools
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bw import cm  # noqa: E402

mons = ["M1", "M2"]
works = ["W1", "W2"]
total = free = nospare = 0
for bits in itertools.product((0, 1), repeat=14):
    it = iter(bits)
    s = cm.System("x", 1)
    s.monitors, s.works = list(mons), list(works)
    s.boundary = {m: i for i, m in enumerate(mons)}
    for rel in ("hb_readers", "checkers", "fwd"):
        for m in mons:
            getattr(s, rel)[m] = [o for o in mons if o != m and next(it)]
    for w in works:
        s.checkers[w] = [m for m in mons if next(it)]
    for w in works:
        s.halt_inputs[w] = [m for m in mons if next(it)]
    total += 1
    first, _ = cm.explore(s)
    if first["G1"] is None and first["G2"] is None:
        free += 1
        spare = False
        for m in mons:
            f2, _ = cm.explore(cm.without_monitor(s, m))
            spare |= f2["G1"] is None and f2["G2"] is None
        nospare += not spare
print("systems", total, "no gap", free, "no spare monitor", nospare)
