"""Forward verifier, seventh batch: the general 'proved' statements on random systems of every
kind (joiner, substrates, shared boundaries, switches, window, no gate, slow reports), decided
with pass A's independent implementation. Run with python -I -B."""
import itertools
import os
import random
import sys
import time

import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, os.path.join(FM, "verification", "a-reimplementation"))
import impl_a  # noqa: E402

rng = random.Random(20261118)


def rand_system():
    n = rng.randint(1, 3)
    k = rng.randint(0, 2)
    mons = [f"M{i}" for i in range(n)]
    works = [f"W{i}" for i in range(k)]
    joiner = "J" if rng.random() < 0.25 else None
    nonmon = works + ([joiner] if joiner else [])
    d = {"name": "r", "f": rng.randint(1, 3), "monitors": mons, "works": works, "joiner": joiner}
    one = rng.random() < 0.3
    d["boundary"] = {m: ("b" if one else rng.choice(["b0", "b1", "b2", m])) for m in mons}
    d["substrate"] = {p: rng.choice(["s0", "s1"]) for p in mons + nonmon if rng.random() < 0.3}
    p = rng.choice((0.3, 0.6, 0.9))
    d["hb_readers"] = {m: [o for o in mons if rng.random() < p] for m in mons}
    d["checkers"] = {x: [o for o in mons if rng.random() < p] for x in mons + nonmon}
    d["fwd"] = {m: [o for o in mons if rng.random() < p] for m in mons}
    d["halt_inputs"] = {w: [o for o in mons if rng.random() < p] for w in nonmon}
    d["switches"] = [m for m in mons if rng.random() < 0.15]
    d["coupling"] = rng.random() < 0.7
    d["window"] = 1 if rng.random() < 0.2 else 0
    d["gate"] = rng.random() < 0.8
    d["slow_reports"] = rng.random() < 0.2
    return d, one


stats = {k: [0, 0] for k in ("C1 rate bound", "C3 unchecked set", "C5 halt inputs", "E1 one boundary",
                             "E2 window", "E3 no gate", "Q3 unchecked process")}
t0 = time.time()
n_sys = 0
while time.time() - t0 < 100 and n_sys < 4000:
    d, one = rand_system()
    g1, g2, st = impl_a.explore(d)
    n_sys += 1
    mons, works, f = d["monitors"], d["works"], d["f"]

    def check(name, ok):
        stats[name][0] += 1
        if not ok:
            stats[name][1] += 1
            if stats[name][1] <= 2:
                print("FAIL", name, d, g1, g2)

    if f >= len(mons):
        check("C1 rate bound", g1 is not None)
    found = False
    for size in range(1, min(f, len(mons)) + 1):
        for N in itertools.combinations(mons, size):
            if all(c in N for z in N for c in d["checkers"].get(z, [])):
                found = True
    if found:
        check("C3 unchecked set", g1 == 1)
    if any(len(set(d["halt_inputs"].get(w, []))) <= f for w in works):
        check("C5 halt inputs", g2 == 1)
    if one:
        check("E1 one boundary", g1 is not None and g1 <= 2)
    if works and d["window"] == 1 and d["gate"]:
        check("E2 window", g2 == 1)
    if works and not d["gate"]:
        check("E3 no gate", g2 == 1)
    if any(not [c for c in d["checkers"].get(x, []) if c != x] for x in mons + works):
        check("Q3 unchecked process", g1 == 1)
print("systems:", n_sys, "seconds:", round(time.time() - t0, 1))
for k, (n, bad) in stats.items():
    print(f"  {k:<22} applicable {n:>5}  failures {bad}")
