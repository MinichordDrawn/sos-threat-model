"""results.json against run-output.txt, against pass A's results, and pass A's code on the
last two cases."""
import importlib.util
import json
import os
import re
import sys

sys.dont_write_bytecode = True
import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
res = json.load(open(os.path.join(FM, "results.json"), encoding="utf-8"))
print("cases in results.json:", len(res), "distinct ids:", len({c["id"] for c in res}))
by = {c["id"]: c for c in res}

A = os.path.join(FM, "verification", "a-reimplementation")
ra = json.load(open(os.path.join(A, "results-a.json")))
rx = json.load(open(os.path.join(A, "results-a-extra.json")))
sa = json.load(open(os.path.join(A, "systems.json")))
sx = json.load(open(os.path.join(A, "systems-extra.json")))
a = {c["id"]: c for c in ra + rx}
print("pass A results:", len(ra), "+", len(rx), "=", len(a))
diff = [(i, (by[i]["G1"], by[i]["G2"]), (a[i]["G1"], a[i]["G2"])) for i in a
        if i not in by or (by[i]["G1"], by[i]["G2"]) != (a[i]["G1"], a[i]["G2"])]
print("differences on A's ids:", diff)
missing = [i for i in by if i not in a]
print("ids in results.json with no pass-A result file entry:", missing)

# are the systems A was given the same systems as in results.json?
asys = {c["id"]: c["system"] for c in sa + sx}
changed = []
for i, s in asys.items():
    cur = by[i]["system"]
    keys = set(s) | set(cur)
    d = [k for k in keys if s.get(k) != cur.get(k) and k != "name"]
    # a field missing from A's copy that has the default value now is not a difference
    d = [k for k in d if not (k == "gate" and k not in s and cur[k] is True)
         and not (k == "slow_reports" and k not in s and cur[k] is False)]
    if d:
        changed.append((i, d))
print("systems differing between A's input and results.json (fields other than name):",
      changed)

# pass A's code, unchanged, on the cases it has no result file for
spec = importlib.util.spec_from_file_location("impl_a", os.path.join(A, "impl_a.py"))
impl = importlib.util.module_from_spec(spec)
spec.loader.exec_module(impl)
for i in missing:
    g1, g2, info = impl.explore(by[i]["system"])
    print("impl_a on", i, "->", g1, g2, "| results.json:", by[i]["G1"], by[i]["G2"],
          "| agree:", (g1, g2) == (by[i]["G1"], by[i]["G2"]))

# run-output.txt rows against results.json
out = open(os.path.join(FM, "run-output.txt"), encoding="utf-8").read()
rows = re.findall(r"^  (.+?)\s+f=(\d)  G1 (holds|broken in (\d) rounds?)\s+G2 (holds|broken in (\d) rounds?)\s+\((\d+) states\)$",
                  out, re.M)
print("table rows in run-output.txt:", len(rows))
names = {}
for c in res:
    names.setdefault((c["system"]["name"], c["system"]["f"]), []).append(c)
bad = 0
for name, f, _, g1, _, g2, states in rows:
    cs = names.get((name.strip(), int(f)))
    if not cs:
        print("  no case for row", name, f)
        bad += 1
        continue
    c = cs[0]
    if (c["G1"], c["G2"]) != (int(g1) if g1 else None, int(g2) if g2 else None):
        print("  mismatch", name, f, c["G1"], c["G2"], g1, g2)
        bad += 1
print("row mismatches:", bad)
abl = [c for c in res if "/minus: " in c["id"]]
print("ablation cases:", len(abl), "breaking:", sum(1 for c in abl if c["G1"] or c["G2"]))
print("non-ablation cases:", len(res) - len(abl))
