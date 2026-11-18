"""E1 on well-monitored systems, where the result is not trivially 1.

Each system is built twice: with every monitor in one boundary (the claim's hypothesis) and
with every monitor in a boundary of its own (for contrast). f = 1, full result() exploration."""
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import model  # noqa: E402


def dense(rng, nmon, nwork, p):
    mons = ["m%d" % i for i in range(nmon)]
    works = ["w%d" % i for i in range(nwork)]
    others = lambda m: [r for r in mons if r != m and rng.random() < p]
    S = {"name": "dense", "f": 1, "monitors": mons, "works": works, "joiner": None, "substrate": {},
         "hb_readers": {m: others(m) for m in mons},
         "checkers": dict({m: others(m) for m in mons}, **{w: [m for m in mons if rng.random() < p] for w in works}),
         "fwd": {m: others(m) for m in mons},
         "halt_inputs": {w: [m for m in mons if rng.random() < p] for w in works},
         "switches": [], "coupling": rng.random() < 0.8, "window": rng.randint(0, 1) if rng.random() < 0.3 else 0,
         "gate": rng.random() < 0.8, "slow_reports": rng.random() < 0.3}
    return S


def main(n):
    rng = random.Random(11)
    same_hist, uniq_hist, bad = {}, {}, 0
    for _ in range(n):
        nmon = rng.randint(1, 4)
        S = dense(rng, nmon, rng.randint(0, 2), rng.choice([0.85, 1.0]))
        same = dict(S, boundary={m: "b" for m in S["monitors"]})
        uniq = dict(S, boundary={m: "b_" + m for m in S["monitors"]})
        r1 = model.result(same)["G1"]
        r2 = model.result(uniq)["G1"]
        same_hist[(nmon, r1)] = same_hist.get((nmon, r1), 0) + 1
        uniq_hist[(nmon, r2)] = uniq_hist.get((nmon, r2), 0) + 1
        if r1 not in (1, 2):
            bad += 1
            print("E1 FAIL", same, r1)
    print("E1 dense, f = 1: %d systems, failures %d" % (n, bad))
    print("  one shared boundary, (monitors, G1):", sorted(same_hist.items(), key=str))
    print("  own boundary each,   (monitors, G1):", sorted(uniq_hist.items(), key=str))


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 400)
