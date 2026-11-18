"""k01: recompute the claims of the changed passages with the checker's own functions.

Run: python -I -B k01_recompute.py
"""
import copy
import itertools
import sys

import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


sys.path.insert(0, _mc())
import check_model as cm  # noqa: E402


def res(system):
    first, states = cm.explore(system)
    return (first["G1"] and len(first["G1"]), first["G2"] and len(first["G2"]), states)


print("== section 1 / README result: R and the removals")
for f in (1, 2, 3):
    print("  R f=%d" % f, res(cm.reference(f=f)))
for p in cm.PROPS:
    print("  R without", p, res(cm.reference(without=(p,))))

print("\n== section 1: ring of three, reports to the one it checks, work reads 2")
s = cm.ring(3, "same", 2)
mons = set(s.monitors)
pred = {
    "P1 signal read by another monitor": all(any(r != m for r in s.hb_readers.get(m, ())) for m in mons),
    "P1 work halts on silence (coupling)": s.coupling,
    "P2 (no substrates: vacuous)": not s.substrate,
    "P3 checker other than itself": all(any(c != x for c in s.checkers.get(x, ())) for x in s.monitors + s.works),
    "P4 every other monitor reached": all(mons <= cm.reach(s, [a], ()) for a in mons),
    "P5 no switch": not s.switches,
    "P6 reader in a different boundary": all(any(s.boundary[r] != s.boundary[m] for r in s.hb_readers.get(m, ())) for m in mons),
    "P7 (no joiner: vacuous)": s.joiner is None,
    "P8 no window": s.window == 0,
    "P8b two halt inputs": all(len(set(s.halt_inputs.get(w, ()))) >= 2 for w in s.works),
    "gate": s.gate,
}
for k, v in pred.items():
    print("  ", k, v)
print("  all predicates hold:", all(pred.values()), " result:", res(s), " plain:", cm.is_plain(s),
      " sufficient_f1:", cm.sufficient_f1(s))
first, _ = cm.explore(s)
cm.show(first["G2"], "    ")
print("  ring3 reports to other, reads 2:", res(cm.ring(3, "other", 2)))

print("\n== section 2.7: mesh of 4 in one boundary, and nested with ring boundaries")
m4 = cm.mesh(4, 1, one_boundary=True)
print("  mesh4 one boundary:", res(m4))
first, _ = cm.explore(m4)
cm.show(first["G1"], "    ")
rounds, why = cm.replay(m4, [[("stop-boundary", 0)]])
print("  replay stop-boundary only:", why)
cm.show(rounds, "    ")
rounds, why = cm.replay(m4, [[("stop-boundary", 0)], []])
print("  replay stop-boundary, then an empty round:", why, [(i["G1"], i["G2"]) for _, i in rounds])
rounds, why = cm.replay(m4, [[("stop-boundary", 0)], [("mutate", "W")]])
print("  replay stop-boundary, then mutate W:", why, [(i["G1"], i["G2"], i["halted"]) for _, i in rounds])
print("  nested ring boundaries f=1:", res(cm.nested(3, True, 1, ring_boundaries=True)))

print("\n== section 4: unread fourth monitor, single checker, and f = 2")
print("  R plus unread M4 f=1:", res(cm.reference(unread_extra=True)))
r = cm.reference()
print("  checkers of R:", {k: v for k, v in r.checkers.items()})
print("  halt inputs of R:", r.halt_inputs)


def variant(f, halt3=False, check2=False, check3=False):
    r = cm.reference(f=f)
    if halt3:
        for w in list(r.halt_inputs):
            r.halt_inputs[w] = ["M1", "M2", "M3"]
    if check2:
        r.checkers["W1"] = ["M1", "M3"]
        r.checkers["W2"] = ["M2", "M3"]
        r.checkers["J"] = ["M3", "M1"]
    if check3:
        for w in ("W1", "W2", "J"):
            r.checkers[w] = ["M1", "M2", "M3"]
    return r


for f in (1, 2):
    print("  f=%d R as is:" % f, res(variant(f)))
    print("  f=%d single checker, three halt sources each:" % f, res(variant(f, halt3=True)))
    print("  f=%d two checkers each, two halt sources:" % f, res(variant(f, check2=True)))
    print("  f=%d three checkers each, two halt sources:" % f, res(variant(f, check3=True)))
    print("  f=%d three checkers and three halt sources:" % f, res(variant(f, halt3=True, check3=True)))

# the same with no joiner and no substrates, to see whether the single checker ever matters at f = 2
for f in (2,):
    v = variant(f, halt3=True)
    v.joiner = None
    v.checkers.pop("J", None)
    v.halt_inputs.pop("J", None)
    print("  f=%d single checker, three halt sources, no joiner:" % f, res(v))

print("\n== section 5: the two rounds at f = 2")
r2 = cm.reference(f=2)
first, _ = cm.explore(r2)
print("  shortest G2:")
cm.show(first["G2"], "    ")
print("  shortest G1:")
cm.show(first["G1"], "    ")
rounds, why = cm.replay(r2, [[("mutate", "M1"), ("mutate", "M3")], [("stop", "M2")]])
print("  replay mutate M1, mutate M3; stop M2:", why)
cm.show(rounds, "    ")

print("\n== section 7: P6 (Theorem 0, part 2) on random one-boundary systems")
import random
rng = random.Random(7)
bad = 0
tried = 0
for _ in range(400):
    n = rng.randint(1, 4)
    s = cm.System("t0", 1)
    s.monitors = ["M%d" % i for i in range(1, n + 1)]
    s.works = ["W%d" % i for i in range(1, rng.randint(1, 2) + 1)]
    s.boundary = {m: 0 for m in s.monitors}
    for m in s.monitors:
        s.hb_readers[m] = [o for o in s.monitors if rng.random() < 0.6]
        s.checkers[m] = [o for o in s.monitors if rng.random() < 0.6]
        s.fwd[m] = [o for o in s.monitors if rng.random() < 0.6]
    for w in s.works:
        s.checkers[w] = [o for o in s.monitors if rng.random() < 0.6]
        s.halt_inputs[w] = [o for o in s.monitors if rng.random() < 0.6]
    s.coupling = rng.random() < 0.5
    s.window = rng.choice((0, 1))
    s.gate = rng.random() < 0.5
    first, _ = cm.explore(s)
    tried += 1
    if first["G1"] is None or len(first["G1"]) > 2:
        bad += 1
print("  one-boundary systems tried:", tried, " G1 not broken within two rounds:", bad)

print("\n== section 10.1: plain systems f = 1 in the catalogue (needs results.json of the folder)")
import json
cases = json.load(open(_mc("results.json"), encoding="utf-8"))
print("  cases:", len(cases))
tally = {}
for c in cases:
    d = c["system"]
    s = cm.System(d["name"], d["f"])
    for k, v in d.items():
        setattr(s, k, v)
    if cm.is_plain(s) and s.f == 1:
        key = (cm.sufficient_f1(s), c["G1"] is None and c["G2"] is None)
        tally[key] = tally.get(key, 0) + 1
print("  ", tally, " total plain f=1:", sum(tally.values()))
