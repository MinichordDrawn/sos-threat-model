"""Run pass A's implementation, unchanged, on every system in results.json and compare."""
import json
import os
import sys
import time

import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, os.path.join(FM, "verification", "a-reimplementation"))
import impl_a  # noqa: E402

R = json.load(open(os.path.join(FM, "results.json"), encoding="utf-8"))
bad = []
t = time.time()
for c in R:
    g1, g2, stats = impl_a.explore(c["system"])
    if (g1, g2) != (c["G1"], c["G2"]):
        bad.append((c["id"], (g1, g2), (c["G1"], c["G2"])))
print("cases", len(R), "disagreements", len(bad), bad, "seconds", round(time.time() - t, 1))
for c in R:
    if c["id"].startswith("mesh3-unread"):
        print(c["id"], impl_a.explore(c["system"])[:2], (c["G1"], c["G2"]))
