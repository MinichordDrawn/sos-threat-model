"""Section 9: the module as printed against Heartbeat.tla; my own explicit-state run of the
module's transition system (written from Heartbeat.tla, with out as a function, the Done step
and TypeOK). Also a few replays for sections 6, 1 and 12."""
import difflib
import itertools
import os
import sys
from collections import deque

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bw import cm, res, FM  # noqa: E402

doc = open(os.path.join(FM, "formal-results.md"), encoding="utf-8").read().split("\n")
a = doc.index("```tla") + 1
b = doc.index("```", a)
printed = doc[a:b]
tla = open(os.path.join(FM, "Heartbeat.tla"), encoding="utf-8").read().split("\n")
if tla and tla[-1] == "":
    tla = tla[:-1]
print("printed lines:", len(printed), "file lines:", len(tla))
only_file = [l for l in difflib.ndiff(printed, tla) if l.startswith("+ ")]
only_printed = [l for l in difflib.ndiff(printed, tla) if l.startswith("- ")]
print("lines only in the write-up's copy:", only_printed)
print("lines only in Heartbeat.tla:")
for l in only_file:
    print("   ", l)

# ---- the module, state for state, from Heartbeat.tla (not from check_model.py)
MON = ("m1", "m2")


def run(HB):
    init = (frozenset(MON), False, tuple("nominal" for _ in MON), "env", False)
    parent = {init: None}
    q = deque([init])
    bad_state = None
    typeok = True
    while q:
        st = q.popleft()
        alive, bad, out, turn, halted = st
        # TypeOK
        typeok &= alive <= set(MON) and isinstance(bad, bool) and all(o in ("nominal", "flagged") for o in out) \
            and turn in ("env", "mon") and isinstance(halted, bool)
        # NoUndetectedBad
        inv = (not (turn == "env" and bad)) or any(out[MON.index(m)] == "flagged" for m in alive)
        if not inv and bad_state is None:
            bad_state = st
        succ = []
        if turn == "env" and not halted:                      # Env
            for m in MON:
                if m in alive:
                    succ.append((f"Stop({m})", (alive - {m}, bad, out, "mon", halted)))
            if not bad:
                succ.append(("Corrupt", (alive, True, out, "mon", halted)))
            succ.append(("Skip", (alive, bad, out, "mon", halted)))
        if turn == "mon":                                     # MonRound

            def detects(m):
                return bad or (HB and any(p not in alive for p in MON if p != m))
            new_out = tuple("flagged" if (m in alive and detects(m)) else out[i] for i, m in enumerate(MON))
            succ.append(("MonRound", (alive, bad, new_out, "env", any(detects(m) for m in alive))))
        if halted:                                            # Done
            succ.append(("Done", st))
        for label, nx in succ:
            if nx not in parent:
                parent[nx] = (st, label)
                q.append(nx)
    trace = None
    if bad_state is not None:
        trace = []
        st = bad_state
        while st is not None:
            p = parent[st]
            trace.append((p[1] if p else "Init", st))
            st = p[0] if p else None
        trace = trace[::-1]
    return len(parent), typeok, trace


for HB in (True, False):
    n, typeok, trace = run(HB)
    print(f"HB={HB}: {n} reachable states, TypeOK {typeok}, invariant",
          "holds" if trace is None else f"broken, shortest trace {len(trace)} states")
    if trace:
        for i, (label, (alive, bad, out, turn, halted)) in enumerate(trace, 1):
            print(f"   {i} {label:<9} alive={sorted(alive)} bad={bad} out={out} turn={turn} halted={halted}")
print("checker's mirror:", [(hb, cm.heartbeat_spec(["m1", "m2"], hb)[1],
                            None if cm.heartbeat_spec(["m1", "m2"], hb)[0] is None else len(cm.heartbeat_spec(["m1", "m2"], hb)[0]))
                           for hb in (True, False)])


def play(system, schedule, label):
    print(f"--- {label}  [{system.name}]")
    s = cm.initial(system)
    for i, steps in enumerate(schedule, 1):
        if cm.responded(system, s):
            print(f"   round {i}: NOT RUN, responded")
            return
        for e in steps:
            assert e in cm.env_steps(system, s), e
            s = cm.apply_env(system, s, e)
        s, info = cm.process_phase(system, s)
        print(f"   round {i}: {steps} | bad {info['bad']} | out {info['out']} | halted {info['halted']} | worked {info['executed']}"
              f" | G1viol {info['G1']} G2viol {info['G2']} | responded {cm.responded(system, s)}")


print("=== section 6, the gate: is the round in which a fault lands never a complete response?")
rg = cm.reference(without="gate")
count = {"responded": [], "not": []}
s0 = cm.initial(rg)
for e in cm.env_steps(rg, s0):
    t, info = cm.process_phase(rg, cm.apply_env(rg, s0, e))
    count["responded" if cm.responded(rg, t) else "not"].append(e)
print("  first steps answered completely in their own round:", count["responded"])
print("  first steps not:", count["not"])
play(rg, [[("stop", "M1")], [("mutate", "W2")]], "R-gate: stop M1 then mutate W2")

print("=== section 1: nested3-upper3 at two faults per round (replay, no search)")
n2 = cm.nested(3, True, 2)
play(n2, [[("mutate", "A1"), ("mutate", "KA")]], "nested3-upper3 f=2: mutate A1 and KA")

print("=== F's 6.6 system: a detection of silence that stops nothing")
f66 = cm.System("F4x1-Q4-1", 1)
f66.monitors, f66.works = ["a", "b", "c", "d"], ["w"]
f66.boundary = {m: m for m in f66.monitors}
f66.hb_readers = {"a": ["b"], "b": ["a"], "c": ["a"], "d": ["c"]}
f66.checkers = {"a": ["b"], "b": ["d"], "c": ["b"], "d": ["b"], "w": ["b"]}
f66.fwd = {}
f66.halt_inputs = {"w": ["b", "d"]}
print("  gap-free:", res(f66)[:3], "| plain:", cm.is_plain(f66), "| predicates:", cm.predicates(f66))
print("  spare monitors:", [m for m in f66.monitors if cm.gap_free(cm.without_monitor(f66, m))])
play(f66, [[("stop", "c")], [("mutate", "w")]], "F4x1-Q4-1: stop c, then mutate w")

print("=== F's 6.2 system: a report that is needed although Q4 fails")
f62 = cm.System("F3x1-Q1Q4-1", 1)
f62.monitors, f62.works = ["a", "b", "c"], ["w"]
f62.boundary = {m: m for m in f62.monitors}
f62.hb_readers = {"a": [], "b": ["c"], "c": ["b"]}
f62.checkers = {"a": ["b"], "b": ["c"], "c": ["b"], "w": ["b"]}
f62.fwd = {"c": ["a"]}
f62.halt_inputs = {"w": ["a", "b"]}
print("  gap-free:", res(f62)[:3], "| predicates:", cm.predicates(f62))
print("  spare monitors:", [m for m in f62.monitors if cm.gap_free(cm.without_monitor(f62, m))])
nofwd = cm.copy.deepcopy(f62)
nofwd.fwd = {}
print("  with the one report edge removed:", res(nofwd)[:3])
play(f62, [[("mutate", "b")]], "F3x1-Q1Q4-1: mutate b")
