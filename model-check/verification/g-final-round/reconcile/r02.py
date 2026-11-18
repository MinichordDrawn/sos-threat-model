import os, sys, copy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rc import *

def chain(d_hops, window=0, slow=True):
    """checker c, relays, halt input h; W checked by c only, halted by h only (+ a 2nd distinct halt input far away? no)."""
    s = cm.System("chain", 1)
    names = ["c"] + [f"p{i}" for i in range(1, d_hops)] + ["h"] if d_hops >= 1 else ["c"]
    s.monitors = names
    s.works = ["W"]
    s.boundary = {m: i for i, m in enumerate(names)}
    for a, b in zip(names, names[1:]):
        s.fwd[a] = [b]
    s.checkers["W"] = ["c"]
    s.halt_inputs["W"] = [names[-1]]
    s.slow_reports = slow
    s.window = window
    return s

def run(s, schedule):
    rounds, why = cm.replay(s, schedule)
    worked = [i for i, (st, info) in enumerate(rounds, 1) if "W" in info["executed"]]
    bad_work = [i for i, (st, info) in enumerate(rounds, 1) if "W" in info["executed"] and info["bad"]]
    return worked, bad_work, why, len(rounds)

print("[reflex d] chain c->p1->p2->h, d=3, slow reports")
s = chain(3)
print(" mutation only          :", run(s, [[("mutate", "W")]] + [[]]*6))
print(" + stop h in round 2    :", run(s, [[("mutate", "W")], [("stop", "h")]] + [[]]*5))
print(" + mutate p1 in round 2 :", run(s, [[("mutate", "W")], [("mutate", "p1")]] + [[]]*5))
print(" + stop p1 in round 2   :", run(s, [[("mutate", "W")], [("stop", "p1")]] + [[]]*5))
s = chain(2)
print(" d=2 mutation only      :", run(s, [[("mutate", "W")]] + [[]]*6))
s = chain(2, window=1)
print(" d=2 window 1           :", run(s, [[("mutate", "W")]] + [[]]*6))
s = chain(2); s.gate = False
print(" d=2 no gate            :", run(s, [[("mutate", "W")]] + [[]]*6))
# no path
s = chain(2); s.fwd = {}
print(" no path                :", run(s, [[("mutate", "W")]] + [[]]*6))
# W bad by a different route: fail-substrate? not plain. mutate c first then W? (state checker itself faulty)
s = chain(2)
print(" mutate c r1, mutate W r2:", run(s, [[("mutate", "c")], [("mutate", "W")]] + [[]]*5))

print("\n[two levels at f=2]")
s = cm.nested(3, True, 2)
rounds, why = cm.replay(s, [[("mutate", "A1"), ("mutate", "KA")]])
cm.show(rounds)
s = cm.nested(3, True, 2, ring_boundaries=True)
rounds, why = cm.replay(s, [[("mutate", "A1"), ("mutate", "KA")]])
cm.show(rounds)

print("\n[gate removed: is the fault round ever a complete response?]")
g = cm.reference(without=("gate",))
for sched in ([[("stop", "M3")]], [[("fail-substrate", "s3")]], [[("stop", "M1")], [("mutate", "W2")]],
              [[("stop","M1")]], [[("stop","M2")]], [[("fail-substrate","s1")]]):
    s0 = cm.initial(g); st = s0
    out = []
    for steps in sched:
        if cm.responded(g, st): out.append("ENDED-before"); break
        for e in steps:
            assert e in cm.env_steps(g, st), e
            st = cm.apply_env(g, st, e)
        st, info = cm.process_phase(g, st)
        out.append((steps, "responded" if cm.responded(g, st) else "not responded", "worked:"+",".join(info["executed"]), "bad:"+",".join(info["bad"]), "G1" if info["G1"] else "", "G2" if info["G2"] else ""))
    print("  ", out)
# first-round single steps that make a state bad
s0 = cm.initial(g)
print("  first-round steps:")
for e in cm.env_steps(g, s0):
    a = cm.apply_env(g, s0, e)
    t, info = cm.process_phase(g, a)
    print(f"    {e!s:<28} bad={info['bad']} responded={cm.responded(g, t)} worked={info['executed']}")
# over all reachable rounds: rounds in which bad grows (new bad state) and that end responded
start = cm.initial(g); seen = {start}; queue = [start]
tot_newbad = resp_newbad = tot_firstbad = resp_firstbad = 0
while queue:
    s = queue.pop()
    if cm.responded(g, s): continue
    for steps, a in cm.env_choices(g, s):
        t, info = cm.process_phase(g, a)
        if a.bad - s.bad:
            tot_newbad += 1
            if cm.responded(g, t): resp_newbad += 1
            if not s.bad:
                tot_firstbad += 1
                if cm.responded(g, t): resp_firstbad += 1
        if t not in seen:
            seen.add(t); queue.append(t)
print(f"  rounds in which a state goes bad: {tot_newbad}, ending responded: {resp_newbad}")
print(f"  rounds in which the FIRST bad state appears: {tot_firstbad}, ending responded: {resp_firstbad}")

print("\n[restart]")
ring3 = {"X1": ["X3"], "X2": ["X1"], "X3": ["X2"]}
print("  ring of 3, X1 self-starting:", cm.restart_game(ring3, ("X1",)))
k_one = {"X1": ["X3", "K"], "X2": ["X1"], "X3": ["X2"], "K": ["X1", "X2", "X3"]}
print("  ring3 + K, K self-starting, K observes X1 only:", cm.restart_game(k_one, ("K",)))
k_one_b = {"X1": ["K"], "X2": ["X1"], "X3": ["X2"], "K": ["X1", "X2", "X3"]}
print("  chain K->X1->X2->X3 (X1 obs by K only), K self-starting:", cm.restart_game(k_one_b, ("K",)))
with_k = {"X1": ["X3", "K"], "X2": ["X1", "K"], "X3": ["X2", "K"], "K": ["X1", "X2", "X3"]}
print("  with_k, K self:", cm.restart_game(with_k, ("K",)))
print("  all self-starting ring3:", cm.restart_game(ring3, ("X1","X2","X3")))
# self-starting member that observes nobody: K observed by members, K observes none
k_none = {"X1": ["X3"], "X2": ["X1"], "X3": ["X2"], "K": ["X1", "X2", "X3"]}
print("  ring3 + K self-starting, K observes nobody:", cm.restart_game(k_none, ("K",)))
mesh3 = {"X1": ["X2", "X3"], "X2": ["X1", "X3"], "X3": ["X1", "X2"]}
print("  mesh3:", cm.restart_game(mesh3, ()))
print("  ring3:", cm.restart_game(ring3, ()))
