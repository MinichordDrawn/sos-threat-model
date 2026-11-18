"""Run pass A's implementation, unchanged, on all 103 systems of systems-all.json and
compare with results.json. Also run its --variants readings on all 103."""
import json
import sys
import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


MC = _mc()
sys.path.insert(0, MC + r"\verification\a-reimplementation")
import impl_a

systems = json.load(open(MC + r"\systems-all.json", encoding="utf-8"))
results = {c["id"]: (c["G1"], c["G2"]) for c in json.load(open(MC + r"\results.json", encoding="utf-8"))}
bad = 0
base = {}
for c in systems:
    g1, g2, stats = impl_a.explore(c["system"])
    base[c["id"]] = (g1, g2)
    if (g1, g2) != results[c["id"]]:
        bad += 1
        print("MISMATCH", c["id"], (g1, g2), results[c["id"]])
print("cases", len(systems), "mismatches against results.json:", bad)
for label, o in impl_a.VARIANTS:
    diffs = []
    for c in systems:
        g1, g2, _ = impl_a.explore(c["system"], o)
        if (g1, g2) != base[c["id"]]:
            diffs.append((c["id"], base[c["id"]], (g1, g2)))
    print("variant %-45s changed: %d %s" % (label, len(diffs), diffs))
