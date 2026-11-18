"""Forward verifier: replay the executions and re-run the named systems of the write-up."""
import json
import os
import sys

import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, FM)
import check_model as cm  # noqa: E402


def run(system, label=None):
    first, states = cm.explore(system)
    print(f"  {label or system.name:<60} f={system.f} G1 {cm.verdict(first['G1'])}; "
          f"G2 {cm.verdict(first['G2'])}; {states} states")
    return first, states


def trace(system, goal):
    first, _ = cm.explore(system)
    if first[goal]:
        cm.show(first[goal], "      ")


print("== section 5: R")
for f in (1, 2, 3):
    run(cm.reference(f=f))
print("  R f=2 shortest G2 / G1:")
trace(cm.reference(f=2), "G2")
trace(cm.reference(f=2), "G1")
r = cm.reference()
print("  R data:", json.dumps(r.as_data()))

print("== section 6: schedules replayed in R-minus-one and in full R")
for p, schedule in cm.CANONICAL:
    print(f" -- without {p}: {schedule}")
    rounds, why = cm.replay(cm.reference(without=(p,)), schedule)
    cm.show(rounds, "    removed: ")
    full, why2 = cm.replay(cm.reference(), schedule)
    print(f"    full R -> {why2}")
    cm.show(full, "    full R:  ")

print("== section 6: shortest executions found by the search")
for p in cm.PROPS:
    s = cm.reference(without=(p,))
    first, states = run(s)
    for g in ("G1", "G2"):
        if first[g]:
            print(f"    shortest {g}:")
            cm.show(first[g], "      ")

print("== section 4")
run(cm.reference(unread_extra=True))
for f in (1, 2):
    s = cm.mesh(3, f, unread="M3")
    run(s)
    trace(s, "G1")
print("  mesh3 full signals:")
for f in (1, 2):
    run(cm.mesh(3, f))

print("== section 6 P4: ring chains")
for args in ((3, "same", 2, 1), (3, "other", 2, 1)):
    s = cm.ring(*args)
    run(s)
    print("   ", json.dumps(s.as_data()))
    trace(s, "G2")
    rounds, why = cm.replay(s, [[("mutate", "M1")]])
    cm.show(rounds, "    mutate M1: ")

print("== section 8.1 reflex")
for direct in (True, False):
    for slow in (False, True):
        s = cm.reflex(direct, slow)
        run(s)
        trace(s, "G2")

print("== section 10.1")
for f in (1, 2, 3):
    run(cm.mesh(4, f))
for gate in (["K"], ["K", "M1"], ["K", "M1", "M2", "M3"]):
    s = cm.with_coordinator(gate)
    run(s)
    trace(s, "G2")
    trace(s, "G1")
run(cm.nested(3, True, 1))
s = cm.nested(3, True, 1, ring_boundaries=True)
run(s)
rounds, why = cm.replay(s, [[("stop-boundary", "A")]])
cm.show(rounds, "    stop-boundary A: ")
print("    ", why, "responded-after:", )
print("   nested data:", json.dumps(cm.nested(3, True, 1).as_data()))
s = cm.mesh(4, 1, one_boundary=True)
run(s)
trace(s, "G1")
run(cm.nested(1, False, 1))
run(cm.nested(1, False, 2))
run(cm.mesh(2, 1)); run(cm.mesh(2, 2)); run(cm.mesh(3, 2))

print("== section 11: single-edge removals from full R")
needed, spare = [], []
for label, system in cm.ablations(cm.reference()):
    first, _ = cm.explore(system)
    (needed if first["G1"] or first["G2"] else spare).append(label)
print("  needed", len(needed), "spare", len(spare), "of", len(needed) + len(spare))
print("  needed:", needed)

print("== section 10.1 catalogue tally (recomputed from results.json systems)")
R = json.load(open(os.path.join(FM, "results.json"), encoding="utf-8"))
tally = {}
plain_f1 = 0
for c in R:
    s = cm.System(c["system"]["name"], c["system"]["f"])
    for k, v in c["system"].items():
        setattr(s, k, v)
    if cm.is_plain(s) and s.f == 1:
        plain_f1 += 1
        key = (cm.sufficient_f1(s), c["G1"] is None and c["G2"] is None)
        tally[key] = tally.get(key, 0) + 1
print("  plain f=1 systems:", plain_f1, tally)
print("  cases:", len(R), "edge removals:", sum("minus:" in c["id"] for c in R))

print("== 10.3 restart")
ring3 = {"X1": ["X3"], "X2": ["X1"], "X3": ["X2"]}
mesh3 = {"X1": ["X2", "X3"], "X2": ["X1", "X3"], "X3": ["X1", "X2"]}
with_k = {"X1": ["X3", "K"], "X2": ["X1", "K"], "X3": ["X2", "K"], "K": ["X1", "X2", "X3"]}
for name, obs, selfs in (("ring3", ring3, ()), ("mesh3", mesh3, ()), ("3+K self", with_k, ("K",)),
                         ("3+K not self", with_k, ()), ("all self", with_k, ("X1", "X2", "X3", "K")),
                         ("3 self, K not", with_k, ("X1",))):
    print("  ", name, cm.restart_game(obs, selfs))

print("== section 9 mirror")
for hb in (True, False):
    tr, n = cm.heartbeat_spec(["m1", "m2"], hb)
    print("  HB", hb, "states", n, "trace", None if tr is None else [(l, sorted(st[0]), st[1], sorted(st[2]), st[3], st[4]) for l, st in tr])
