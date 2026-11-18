"""E4 on (a) sparse forwarding graphs with 2..10 monitors, so that long paths occur, and
(b) arbitrary systems that keep only window 0, gate true, slow_reports true (the three
hypotheses the proof actually uses), with x drawn from `works`."""
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import model  # noqa: E402
from test_claims import fwd_distance, rand_system  # noqa: E402


def check(S, x, horizon):
    d = fwd_distance(S, x)
    log, st, resp = model.run_script(S, [[("mutate", x)]], horizon)
    stepped = [x in rec["stepped"] for rec in log]
    if d is None:
        ok = len(log) == horizon and all(stepped)
    else:
        ok = len(log) >= d + 1 and all(stepped[:d]) and not any(stepped[d:])
    return d, ok, stepped


def main(n):
    rng = random.Random(8)
    hist, fails = {}, 0
    for _ in range(n):
        k = rng.randint(2, 10)
        mons = ["m%d" % i for i in range(k)]
        S = {"name": "sparse", "f": rng.randint(1, 3), "monitors": mons, "works": ["x", "y"], "joiner": None,
             "boundary": {m: "b_" + m for m in mons}, "substrate": {},
             "hb_readers": {m: rng.sample(mons, 1) for m in mons},
             "checkers": {"x": rng.sample(mons, 1), "y": rng.sample(mons, 1), mons[0]: rng.sample(mons, 1)},
             "fwd": {m: rng.sample(mons, rng.randint(0, 2)) for m in mons},
             "halt_inputs": {"x": rng.sample(mons, rng.randint(1, 2)), "y": rng.sample(mons, 1)},
             "switches": [], "coupling": True, "window": 0, "gate": True, "slow_reports": True}
        d, ok, stepped = check(S, "x", k + 5)
        hist[d] = hist.get(d, 0) + 1
        if not ok:
            fails += 1
            print("FAIL", S, d, stepped)
    print("(a) slow-plain, sparse fwd, 2..10 monitors: %d systems, failures %d" % (n, fails))
    print("    d histogram:", sorted(hist.items(), key=lambda kv: (kv[0] is None, kv[0])))

    hist, fails = {}, 0
    for _ in range(n):
        S = rand_system(rng, nmon=rng.randint(0, 5), nwork=rng.randint(1, 3),
                        window=0, gate=True, slow_reports=True)
        x = rng.choice(S["works"])
        d, ok, stepped = check(S, x, len(S["monitors"]) + 5)
        hist[d] = hist.get(d, 0) + 1
        if not ok:
            fails += 1
            print("FAIL", S, d, stepped)
    print("(b) any system with window 0, gate true, slow_reports true: %d systems, failures %d" % (n, fails))
    print("    d histogram:", sorted(hist.items(), key=lambda kv: (kv[0] is None, kv[0])))


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 30000)
