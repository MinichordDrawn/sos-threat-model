"""E4: every slow-plain system with 0..3 monitors, exhaustively over checkers[x], halt_inputs[x]
and fwd (the fields the proof says matter); the other free fields are drawn at random."""
import itertools
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import model  # noqa: E402
from test_claims import fwd_distance, sub  # noqa: E402


def subsets(items):
    for r in range(len(items) + 1):
        for c in itertools.combinations(items, r):
            yield list(c)


def main():
    rng = random.Random(4)
    total = fails = 0
    hist = {}
    for nmon in range(0, 4):
        mons = ["m%d" % i for i in range(nmon)]
        all_sub = list(subsets(mons))
        for cx in all_sub:
            for hx in all_sub:
                for fw in itertools.product(all_sub, repeat=nmon):
                    S = {"name": "sp", "f": rng.randint(1, 3), "monitors": mons, "works": ["x", "y"],
                         "joiner": None, "boundary": {m: "b_" + m for m in mons}, "substrate": {},
                         "hb_readers": {m: sub(rng, mons) for m in mons},
                         "checkers": dict({m: sub(rng, mons) for m in mons}, x=cx, y=sub(rng, mons)),
                         "fwd": {m: list(fw[i]) for i, m in enumerate(mons)},
                         "halt_inputs": {"x": hx, "y": sub(rng, mons)},
                         "switches": [], "coupling": True, "window": 0, "gate": True, "slow_reports": True}
                    if rng.random() < 0.3:      # also exercise "a key missing from a map"
                        if not cx:
                            del S["checkers"]["x"]
                        if not hx:
                            del S["halt_inputs"]["x"]
                    d = fwd_distance(S, "x")
                    hist[d] = hist.get(d, 0) + 1
                    horizon = nmon + 5
                    log, st, resp = model.run_script(S, [[("mutate", "x")]], horizon)
                    stepped = ["x" in rec["stepped"] for rec in log]
                    if d is None:
                        ok = len(log) == horizon and all(stepped)
                    else:
                        ok = len(log) >= d + 1 and all(stepped[:d]) and not any(stepped[d:])
                    total += 1
                    if not ok:
                        fails += 1
                        print("FAIL", S, d, stepped)
    print("E4 exhaustive (0..3 monitors): %d systems, failures %d" % (total, fails))
    print("d histogram:", sorted(hist.items(), key=lambda kv: (kv[0] is None, kv[0])))


if __name__ == "__main__":
    main()
