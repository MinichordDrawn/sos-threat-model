"""Forward verifier, third batch. Run with python -I -B."""
import itertools
import json
import math
import random
import sys
from functools import lru_cache

import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, FM)
import check_model as cm  # noqa: E402


def build(d):
    s = cm.System(d.get("name", "x"), d.get("f", 1))
    for k, v in d.items():
        setattr(s, k, v)
    return s


print("== two-level rings at f = 2 (section 1 says they 'hold too' after 'up to three faults')")
s = cm.nested(3, True, 2)
rounds, why = cm.replay(s, [[("mutate", "A1"), ("mutate", "KA")]])
cm.show(rounds, "    ")

print("== README Theorem S wording: conditions (a)-(d) on a non-plain system")
s = cm.mesh(4, 1, one_boundary=True)
print("  mesh of 4 in one boundary: (a)-(d) hold:", cm.sufficient_f1(s), "plain:", cm.is_plain(s),
      "result:", {g: (p and len(p)) for g, p in cm.explore(s)[0].items()})
s = cm.mesh(3, 1)
s.window = 1
print("  mesh of 3 with a window: (a)-(d) hold:", cm.sufficient_f1(s), "plain:", cm.is_plain(s),
      "result:", {g: (p and len(p)) for g, p in cm.explore(s)[0].items()})
s = cm.mesh(3, 2)
print("  mesh of 2.. (a)-(d) at f=2, mesh of 2:", cm.sufficient_f1(cm.mesh(2, 2)),
      {g: (p and len(p)) for g, p in cm.explore(cm.mesh(2, 2))[0].items()})

print("== Theorem S: random plain systems at f = 1 that satisfy (a)-(d)")
rng = random.Random(7)
tested = held = 0
for _ in range(60000):
    n = rng.randint(2, 4)
    k = rng.randint(0, 2)
    mons = [f"M{i}" for i in range(n)]
    works = [f"W{i}" for i in range(k)]
    s = cm.System("rand", 1)
    s.monitors, s.works = mons, works
    s.boundary = {m: i for i, m in enumerate(mons)}
    p = rng.choice((0.5, 0.7, 0.85))
    for rel in ("hb_readers", "checkers", "fwd"):
        for m in mons:
            getattr(s, rel)[m] = [o for o in mons if o != m and rng.random() < p]
    for w in works:
        s.checkers[w] = [m for m in mons if rng.random() < p]
        s.halt_inputs[w] = [m for m in mons if rng.random() < p]
    if not (cm.is_plain(s) and cm.sufficient_f1(s)):
        continue
    tested += 1
    first, _ = cm.explore(s)
    if first["G1"] is None and first["G2"] is None:
        held += 1
    else:
        print("  COUNTEREXAMPLE", json.dumps(s.as_data()))
        break
print(f"  systems satisfying (a)-(d): {tested}; neither judgement violated in {held}")

print("== falsifier report 6.6 (F4x1-Q4-1): a detection that does not stop the work")
d = {"name": "F4x1-Q4-1", "f": 1, "monitors": ["a", "b", "c", "d"], "works": ["w"], "joiner": None,
     "boundary": {"a": "b_a", "b": "b_b", "c": "b_c", "d": "b_d"}, "substrate": {},
     "hb_readers": {"a": ["b"], "b": ["a"], "c": ["a"], "d": ["c"]},
     "checkers": {"a": ["b"], "b": ["d"], "c": ["b"], "d": ["b"], "w": ["b"]},
     "fwd": {}, "halt_inputs": {"w": ["b", "d"]}, "switches": [], "coupling": True, "window": 0,
     "gate": True, "slow_reports": False}
s = build(d)
first, states = cm.explore(s)
print("  result:", {g: (p and len(p)) for g, p in first.items()}, states, "states")
rounds, why = cm.replay(s, [[("stop", "c")], []])
cm.show(rounds, "    ")
print("  spare monitors:", [m for m in s.monitors if cm.gap_free(cm.without_monitor(s, m))])
print("  predicates:", cm.predicates(s))

print("== the census example for Q4r (run-output line 200)")
d2 = dict(d, name="q4r", monitors=["M1", "M2", "M3"], works=["W"],
          boundary={"M1": 0, "M2": 1, "M3": 2},
          hb_readers={'M1': ['M3'], 'M2': ['M3'], 'M3': ['M1', 'M2']},
          checkers={'M1': ['M2', 'M3'], 'M2': ['M1', 'M3'], 'M3': ['M2'], 'W': ['M1', 'M2', 'M3']},
          fwd={'M1': ['M2'], 'M2': ['M3'], 'M3': []}, halt_inputs={'W': ['M1', 'M2']})
s = build(d2)
print("  result:", {g: (p and len(p)) for g, p in cm.explore(s)[0].items()},
      "spare:", [m for m in s.monitors if cm.gap_free(cm.without_monitor(s, m))], cm.predicates(s))

print("== fixes from B: D3 (string argument) and D4 (missing key)")
r = cm.reference(without="P8b")
print("  reference(without='P8b'):", r.name, "window", r.window, "halt_inputs", r.halt_inputs)
r = cm.reference(without=("P3",), unread_extra=True)
print("  reference(without=('P3',), unread_extra=True): ok,", r.name)

print("== P2 second face against the model's own fail-substrate step")
r = cm.reference()
rounds, why = cm.replay(r, [[("fail-substrate", "s1")]])
cm.show(rounds, "    full R: ")
r = cm.reference(without=("P8",))
rounds, why = cm.replay(r, [[("fail-substrate", "s1")]])
cm.show(rounds, "    R with a one-round window (shared substrate kept): ")
# one monitor M and one work W on the same substrate, W halts on M's silence after a window
s = cm.System("shared substrate, window 1", 1)
s.monitors, s.works = ["M"], ["W"]
s.substrate = {"M": "s", "W": "s"}
s.checkers = {"W": ["M"]}
s.halt_inputs = {"W": ["M"]}
s.window = 1
rounds, why = cm.replay(s, [[("fail-substrate", "s")]])
cm.show(rounds, "    M and W on one substrate, window 1: ")


# ---- worst halting order against the bounds
def worst(n, c, h):
    sys.setrecursionlimit(100000)

    @lru_cache(maxsize=None)
    def v(g, b, fr, i):
        if b == 0:
            return 0
        if i == h:
            sp = min(b, g)
            return sp + v(g - sp, b + sp, fr, 0)
        k = min(c * fr, g + b)
        return max(v(g - (k - j), b - j, k, i + 1) for j in range(max(0, k - g), min(k, b) + 1))

    return 1 + v(n - 1, 1, 1, 0)


print("== worst halting order against the stated bounds, n = 2..400")
over = [(n, worst(n, 2, 2)) for n in range(2, 401) if worst(n, 2, 2) ** 2 * 2 > n]
print("  c=2,h=2: sizes where the worst order exceeds sqrt(n/2):", over[:12], len(over))
print("  c=2,h=2: max worst/sqrt(n/2):", max((worst(n, 2, 2) / math.sqrt(n / 2), n) for n in range(2, 401)))
print("  c=2,h=1: max share lost under the worst order:", max((worst(n, 2, 1) / n, n) for n in range(8, 401)),
      "; at powers of two:", [(n, worst(n, 2, 1), n // 4) for n in (8, 16, 32, 64, 128, 256)])
cnt = sum(1 for n in range(2, 401) if worst(n, 2, 1) > cm.growth(n, "cascade", 2, 1))
print("  c=2,h=1: sizes in 2..400 where another order beats good-first:", cnt)
# the n = 8 example by hand
print("  n=8, c=2, h=1: good-first", cm.growth(8, "cascade", 2, 1), "worst", worst(8, 2, 1))
