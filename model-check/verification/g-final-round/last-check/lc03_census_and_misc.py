"""Last check, script 3: results.md section 12.1 (how the census was drawn), Theorem S
without its rate, pass A's results against results.json, and the plain-system predicates.

Run: python -I -B lc03_census_and_misc.py
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
FOLDER = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, FOLDER)
import check_model as cm  # noqa: E402

print("== A. Census, two monitors")
two = list(cm.small_systems(2, None, 1))
print("  systems generated:", len(two), "distinct:", len({cm.key_of(s) for s in two}))
print("  all plain:", all(cm.is_plain(s) for s in two), "| f values:", {s.f for s in two},
      "| work processes:", {tuple(s.works) for s in two})
print("  any monitor in its own hb_readers/checkers/fwd list:",
      any(m in getattr(s, rel).get(m, ()) for s in two for rel in ("hb_readers", "checkers", "fwd")
          for m in s.monitors))

print("\n== B. Census, three monitors: the 6,000 draws")
three = list(cm.small_systems(3, 6000, 1))
keys = [cm.key_of(s) for s in three]
print("  draws:", len(three), "distinct:", len(set(keys)))
print("  all plain:", all(cm.is_plain(s) for s in three), "| f values:", {s.f for s in three})


def edges(s):
    return sum(len(v) for rel in cm.RELATIONS for v in getattr(s, rel).values())


full = 3 * 3 * 2 + 2 * 3
odd = [s for i, s in enumerate(three) if i % 2]          # uniform draws
even = [s for i, s in enumerate(three) if not i % 2]     # mesh with edges removed
print("  uniform draws:", len(odd), "| mesh draws:", len(even), "| edges in the full mesh:", full)
removed = sorted({full - edges(s) for s in even})
print("  edges removed from the mesh, values seen:", removed)
print("  mean edges in a uniform draw: %.2f" % (sum(edges(s) for s in odd) / len(odd)))
print("  distinct among uniform draws:", len({cm.key_of(s) for s in odd}),
      "| distinct among mesh draws:", len({cm.key_of(s) for s in even}))
# does a removed "edge" include the work process's checker and halt-input entries?
w_cut = sum(1 for s in even if len(s.checkers["W"]) < 3 or len(s.halt_inputs["W"]) < 3)
print("  mesh draws in which an entry of the work process's checkers or halt inputs was removed:", w_cut)

print("\n== C. Which section 3.2 predicates can fail in a plain system")
# P6 as section 3.2 writes it: every monitor's signal has a reader in a different boundary
def p6(s):
    return all(any(s.boundary.get(r, ("own", r)) != s.boundary.get(m, ("own", m))
                   for r in s.hb_readers.get(m, ())) for m in s.monitors)


same = sum(1 for s in two + three if p6(s) == cm.predicates(s)["Q1"])
print("  systems where the P6 predicate equals 'every signal is read by another monitor':",
      same, "of", len(two) + len(three))
print("  systems where the P6 predicate fails:", sum(1 for s in two + three if not p6(s)))

print("\n== D. Theorem S without 'one fault per round'")
for n in (2, 3):
    for f in (1, 2, 3):
        s = cm.mesh(n, f)
        first, _ = cm.explore(s)
        print(f"  mesh of {n}, f={f}: plain {cm.is_plain(s)}, conditions (a)-(d) {cm.sufficient_f1(s)}, "
              f"G1 {first['G1'] and len(first['G1'])}, G2 {first['G2'] and len(first['G2'])}")

print("\n== E. Pass A's results against results.json")
with open(os.path.join(FOLDER, "results.json"), encoding="utf-8") as fh:
    mine = {c["id"]: (c["G1"], c["G2"]) for c in json.load(fh)}
va = os.path.join(FOLDER, "verification", "a-reimplementation")
theirs = {}
for name in ("results-a.json", "results-a-extra.json"):
    with open(os.path.join(va, name), encoding="utf-8") as fh:
        for c in json.load(fh):
            theirs[c["id"]] = (c["G1"], c["G2"])
print("  cases in results.json:", len(mine), "| cases in pass A's two files:", len(theirs))
print("  ids in both:", len(set(mine) & set(theirs)), "| differing results:",
      [i for i in theirs if i in mine and mine[i] != theirs[i]])
print("  ids only in results.json:", sorted(set(mine) - set(theirs)))
with open(os.path.join(FOLDER, "systems-all.json"), encoding="utf-8") as fh:
    sysall = json.load(fh)
print("  systems-all.json entries:", len(sysall), "| keys of an entry:", sorted(sysall[0]),
      "| same ids and order as results.json:", [c["id"] for c in sysall] == list(mine))

print("\n== F. Counts quoted from run-output.txt")
plain_f1 = 0
with open(os.path.join(FOLDER, "results.json"), encoding="utf-8") as fh:
    cases = json.load(fh)
ablation = [c for c in cases if "/minus: " in c["id"]]
print("  one-edge removals:", len(ablation), "| of which break a judgement:",
      sum(1 for c in ablation if c["G1"] or c["G2"]))
