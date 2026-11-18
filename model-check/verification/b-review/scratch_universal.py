import os
"""Scratch: for each property, is the violation guaranteed in ANY system that lacks it (in the
builder's sense), whatever the rest of the wiring? Random systems, removal forced, checked
with check_model.explore."""
import random
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import check_model as cm
from scratch_compare import random_system

N = 400


def n(path):
    return len(path) if path else None


def least(system, limit):
    """Least round (<= limit) in which each goal is broken; same search as cm.explore but
    cut off at depth `limit`, so that large state spaces stay cheap."""
    start = cm.initial(system)
    depth = {start: 0}
    order = [start]
    i = 0
    res = {"G1": None, "G2": None}
    while i < len(order):
        s = order[i]
        i += 1
        if depth[s] >= limit or cm.responded(system, s):
            continue
        for _steps, a in cm.env_choices(system, s):
            t, info = cm.process_phase(system, a)
            for g in res:
                if info[g] and res[g] is None:
                    res[g] = depth[s] + 1
            if t not in depth:
                depth[t] = depth[s] + 1
                order.append(t)
    return res["G1"], res["G2"]


SEED = [0]


def trial(name, force, claim, need=lambda s: True):
    SEED[0] += 1
    rng = random.Random(1000 + SEED[0])
    ok = bad = 0
    example = None
    while ok + bad < N:
        s = random_system(rng)
        s.f = rng.choice((1, 1, 2))
        if not need(s):
            continue
        force(s, rng)
        g1, g2 = least(s, len(s.monitors) + 1)
        if claim(s, g1, g2):
            ok += 1
        else:
            bad += 1
            example = example or (s.as_data(), g1, g2)
    print(f"  {name:<74} {ok}/{N} systems" + (f"  COUNTEREXAMPLE {example}" if bad else ""))


def f_p1(s, rng):
    s.hb_readers = {}
    s.coupling = False


def f_p2(s, rng):
    s.substrate[s.works[0]] = "z"          # a substrate no monitor is on


def f_p3(s, rng):
    s.checkers = {}


def f_p4(s, rng):
    s.fwd = {}


def f_p5(s, rng):
    s.switches = list(s.monitors)


def f_p6(s, rng):
    s.boundary = {m: 1 for m in s.monitors}


def f_p7(s, rng):
    s.joiner = "J"
    s.checkers.pop("J", None)


def f_p8(s, rng):
    s.window = 1


def f_p8b(s, rng):
    s.halt_inputs[s.works[0]] = [rng.choice(s.monitors)]


print("Claim holds in every random system with the removal forced:")
trial("no hb_readers, no coupling        => G1 broken within |monitors|+1 rounds", f_p1,
      lambda s, g1, g2: g1 is not None and g1 <= len(s.monitors) + 1)
trial("a work process on a monitor-free substrate => G1 broken in round 1", f_p2,
      lambda s, g1, g2: g1 == 1)
trial("no checkers                       => G1 broken in round 1", f_p3,
      lambda s, g1, g2: g1 == 1)
trial("every monitor has a switch        => G1 broken within |monitors|+1 rounds", f_p5,
      lambda s, g1, g2: g1 is not None and g1 <= len(s.monitors) + 1)
trial("all monitors (>= 2) in one boundary => G1 broken within 2 rounds", f_p6,
      lambda s, g1, g2: g1 is not None and g1 <= 2, need=lambda s: len(s.monitors) >= 2)
trial("joiner with no checker            => G1 broken within 2 rounds", f_p7,
      lambda s, g1, g2: g1 is not None and g1 <= 2)
trial("window = 1                        => G2 broken in round 1", f_p8,
      lambda s, g1, g2: g2 == 1)
trial("a work process with one halt input => G2 broken in round 1", f_p8b,
      lambda s, g1, g2: g2 == 1)

print("\nP4 is the exception. Systems with fwd = {} that hold both goals at f=1:")
r = cm.reference(without=("P4",))
for w in list(r.halt_inputs):
    r.halt_inputs[w] = list(r.monitors)
first, states = cm.explore(r)
print(f"  R without P4, every work process reads all three monitors: G1 {cm.verdict(first['G1'])}, "
      f"G2 {cm.verdict(first['G2'])} ({states} states)")
m = cm.mesh(3)
m.fwd = {}
first, states = cm.explore(m)
print(f"  mesh of 3 with no report edges: G1 {cm.verdict(first['G1'])}, "
      f"G2 {cm.verdict(first['G2'])} ({states} states)")
