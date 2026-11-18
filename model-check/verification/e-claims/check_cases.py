"""Concrete systems: witnesses for the proofs and the other-reading counterexamples."""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import model  # noqa: E402


def show(title, S, script=None, rounds=6):
    print("=" * 78)
    print(title)
    print(json.dumps(S))
    res, paths = model.result(S, want_witness=True)
    print("result:", res)
    for g in ("G1", "G2"):
        if paths[g] is not None:
            print("  least %s execution, env steps per round: %s" % (g, [list(map(list, r)) for r in paths[g]]))
    if script is not None:
        log, st, resp = model.run_script(S, script, rounds)
        for rec in log:
            print("  ", rec)
        print("   responded after last round shown:", resp)
    return res


# ---- E1 --------------------------------------------------------------------------------
full3 = ["m1", "m2", "m3"]
E1_three = {"name": "E1 three monitors, one boundary, full mesh", "f": 1, "monitors": full3, "works": ["w"],
            "joiner": None, "boundary": {m: "b" for m in full3}, "substrate": {},
            "hb_readers": {m: [r for r in full3 if r != m] for m in full3},
            "checkers": {"m1": ["m2", "m3"], "m2": ["m1", "m3"], "m3": ["m1", "m2"], "w": full3},
            "fwd": {m: [r for r in full3 if r != m] for m in full3},
            "halt_inputs": {"w": full3}, "switches": [], "coupling": True, "window": 0}
show("E1: three monitors in one boundary (expect G1 = 2)", E1_three,
     script=[[("stop-boundary", "b")], [("mutate", "m1")]])

E1_one = {"name": "E1 one monitor", "f": 1, "monitors": ["m"], "works": ["w"], "joiner": None,
          "boundary": {"m": "b"}, "substrate": {}, "hb_readers": {}, "checkers": {"w": ["m"]},
          "fwd": {}, "halt_inputs": {"w": ["m"]}, "switches": [], "coupling": True, "window": 0}
show("E1: one monitor (stop-boundary never enabled; expect G1 = 1 by mutate m)", E1_one,
     script=[[("mutate", "m")]])

E1_alt = {"name": "E1 other reading: no monitor has a boundary", "f": 1, "monitors": ["m1", "m2"],
          "works": [], "joiner": None, "boundary": {}, "substrate": {},
          "hb_readers": {"m1": ["m2"], "m2": ["m1"]}, "checkers": {"m1": ["m2"], "m2": ["m1"]},
          "fwd": {}, "halt_inputs": {}, "switches": [], "coupling": True, "window": 0}
show("E1 other reading: two monitors, neither has a boundary (expect G1 = null)", E1_alt)

# ---- E2 / E3 / E5 ----------------------------------------------------------------------
guard = {"hb_readers": {m: [r for r in full3 if r != m] for m in full3},
         "fwd": {m: [r for r in full3 if r != m] for m in full3}, "switches": [], "substrate": {},
         "boundary": {"m1": "b1", "m2": "b2", "m3": "b3"}}
E2_sys = dict(guard, name="E2 well-guarded, window 1", f=1, monitors=full3, works=["w"], joiner=None,
              checkers={"m1": ["m2", "m3"], "m2": ["m1", "m3"], "m3": ["m1", "m2"], "w": full3},
              halt_inputs={"w": full3}, coupling=True, window=1, gate=True)
show("E2: fully guarded system with window 1 (expect G2 = 1)", E2_sys, script=[[("mutate", "w")]])

E3_sys = dict(E2_sys, name="E3 well-guarded, gate false", window=0, gate=False)
show("E3: fully guarded system with gate false, window 0 (expect G2 = 1)", E3_sys, script=[[("mutate", "w")]])

base = dict(E2_sys, name="baseline: fully guarded, gate true, window 0", window=0, gate=True)
show("Baseline for comparison: same system, gate true, window 0, f = 1", base)

E5_sys = dict(base, name="E5 second work process without a checker", works=["w", "v"],
              halt_inputs={"w": full3, "v": full3})
show("E5: add v with halt_inputs but no checker (expect G2 = 1)", E5_sys, script=[[("mutate", "v")]])

# ---- other reading of 'work process': the joiner as the only work process ---------------
J2 = {"name": "joiner only, window 1, gate true", "f": 1, "monitors": [], "works": [], "joiner": "j",
      "coupling": False, "window": 1, "gate": True}
show("E2 other reading: the only work process is the joiner, f = 1 (expect G2 = 2)", J2,
     script=[[("join",)], [("mutate", "j")]])
J3 = dict(J2, name="joiner only, gate false", window=0, gate=False)
show("E3 other reading: the only work process is the joiner, f = 1 (expect G2 = 2)", J3,
     script=[[("join",)], [("mutate", "j")]])
J5 = {"name": "joiner without checker", "f": 1, "monitors": ["m"], "works": [], "joiner": "j",
      "halt_inputs": {"j": ["m"]}, "coupling": False, "window": 0, "gate": True, "slow_reports": False}
show("E5 other reading: w is the joiner, f = 1 (expect G2 = 2)", J5,
     script=[[("join",)], [("mutate", "j")]])
show("... the same three systems with f = 2 give G2 = 1", dict(J2, f=2))
show("", dict(J3, f=2))
show("", dict(J5, f=2))

# ---- E4 --------------------------------------------------------------------------------
chain = ["c", "p", "q", "h"]
E4_sys = {"name": "E4 chain, d = 3", "f": 1, "monitors": chain, "works": ["x", "y"], "joiner": None,
          "boundary": {m: "b_" + m for m in chain}, "substrate": {}, "hb_readers": {},
          "checkers": {"x": ["c"]}, "fwd": {"c": ["p"], "p": ["q"], "q": ["h"]},
          "halt_inputs": {"x": ["h"], "y": ["c"]}, "switches": [], "coupling": True, "window": 0,
          "gate": True, "slow_reports": True}
print("=" * 78)
print("E4 (i): chain c -> p -> q -> h, checkers[x] = [c], halt_inputs[x] = [h], d = 3")
print(json.dumps(E4_sys))
log, st, resp = model.run_script(E4_sys, [[("mutate", "x")]], 8)
for rec in log:
    print("  ", rec)
print("   responded:", resp)
E4_none = dict(E4_sys, name="E4 no path", fwd={"c": ["p"], "p": ["q"]})
print("E4 (ii): same without the edge q -> h, d undefined")
log, st, resp = model.run_script(E4_none, [[("mutate", "x")]], 8)
for rec in log:
    print("  ", rec)
print("   responded:", resp)
