"""Cross-check model.py against naive.py.

usage: python crosscheck.py catalogue [workers]   every case of systems-join.json
       python crosscheck.py random N [seed]       N random small systems using
                                                  every field of both spec files
"""
import json
import os
import random
import sys
from multiprocessing import Pool

from model import Model
from naive import Naive

HERE = os.path.dirname(os.path.abspath(__file__))
FULL_LIMIT = 4000    # largest reachable space the plain implementation is asked to walk


def both(system, full=True):
    """Answers with the early stop and, if `full`, a fingerprint of the whole
    reachable space without it; each from both implementations."""
    a = Model(system).solve()
    b = Naive(system).solve()
    if not full:
        return (a[0], a[1], a[2]), (b[0], b[1], b[2])
    fa = Model(system).solve(explore_all=True, state_limit=FULL_LIMIT)
    if len(fa) == 4:        # too large for the plain implementation: answers only
        return (a[0], a[1], a[2], "big"), (b[0], b[1], b[2], "big")
    fb = Naive(system).solve(explore_all=True)
    assert (fa[0], fa[1]) == (a[0], a[1]), "early stop changed the answer"
    return (a[0], a[1], a[2]) + tuple(fa), (b[0], b[1], b[2]) + tuple(fb)


def job(arg):
    cid, system = arg
    a, b = both(system, full=False)
    return cid, a, b


def random_system(rng):
    nm = rng.randint(1, 5)
    monitors = ["M%d" % i for i in range(nm)]
    works = ["W%d" % i for i in range(rng.randint(1, 2))]
    joiner = "J" if rng.random() < 0.5 else None
    procs = monitors + works + ([joiner] if joiner else [])
    nonmon = works + ([joiner] if joiner else [])

    def sub(lst, p):
        return [x for x in lst if rng.random() < p]

    dense = rng.random()          # how many of the possible edges exist
    s = {
        "name": "random",
        "f": rng.choice([1, 1, 1, 2, 2, 3]),
        "monitors": monitors,
        "works": works,
        "joiner": joiner,
        "boundary": {m: rng.randint(1, 3) for m in monitors if rng.random() < 0.8},
        "substrate": {p: rng.randint(1, 2) for p in procs if rng.random() < rng.choice([0, 0.3])},
        "hb_readers": {m: sub(monitors, dense) for m in monitors if rng.random() < 0.9},
        "checkers": {p: sub(monitors, dense) for p in procs if rng.random() < 0.9},
        "fwd": {m: sub(monitors, dense) for m in monitors if rng.random() < 0.9},
        "halt_inputs": {w: sub(monitors, dense) for w in nonmon if rng.random() < 0.9},
        "switches": sub(monitors, 0.15),
        "coupling": rng.random() < 0.6,
        "window": rng.randint(0, 1),
    }
    if rng.random() < 0.7:
        s["gate"] = rng.random() < 0.6
    if rng.random() < 0.7:
        s["slow_reports"] = rng.random() < 0.4
    if rng.random() < 0.8:
        cand = monitors[:] + ([joiner] if joiner and rng.random() < 0.6 else [])
        rng.shuffle(cand)
        cand = cand[:rng.randint(0, len(cand))]
        groups = []
        while cand:
            k = rng.randint(1, min(3, len(cand)))
            mem, cand = cand[:k], cand[k:]
            g = {"name": "g%d" % len(groups), "members": mem}
            if rng.random() < 0.6:
                g["after"] = sub([p for p in procs if p not in mem], 0.2)
            groups.append(g)
        s["late"] = groups
        s["arrive_bad"] = rng.random() < 0.5
        edges = [[r, k, m] for r in ("hb_readers", "checkers", "fwd", "halt_inputs")
                 for k, v in s[r].items() for m in v]
        s["slow_edges"] = sub(edges, 0.3)
    return s


def main():
    mode = sys.argv[1]
    if mode == "catalogue":
        workers = int(sys.argv[2]) if len(sys.argv) > 2 else 1
        data = json.load(open(os.path.join(HERE, "systems-join.json")))
        jobs = [(c["id"], c["system"]) for c in data]
        diff = []
        n = 0
        with Pool(workers) as pool:
            for cid, a, b in pool.imap_unordered(job, jobs, chunksize=8):
                n += 1
                if a != b:
                    diff.append((cid, a, b))
                if n % 1000 == 0:
                    print("checked", n, "differences", len(diff), flush=True)
        print("catalogue: %d cases compared, %d differences" % (n, len(diff)))
        for d in diff[:20]:
            print("  ", d)
    else:
        n = int(sys.argv[2])
        seed = int(sys.argv[3]) if len(sys.argv) > 3 else 0
        rng = random.Random(seed)
        diff = 0
        answers = {}
        feats = {}
        big = 0
        for i in range(n):
            s = random_system(rng)
            a, b = both(s)
            big += a[-1] == "big"
            for k in ("late", "slow_edges", "substrate", "switches", "joiner"):
                if s.get(k):
                    feats[(k, "non-empty")] = feats.get((k, "non-empty"), 0) + 1
            feats[("window", s["window"])] = feats.get(("window", s["window"]), 0) + 1
            answers[(a[0], a[1])] = answers.get((a[0], a[1]), 0) + 1
            for k in ("gate", "slow_reports", "coupling", "arrive_bad"):
                if s.get(k) is not None:
                    feats[(k, s[k])] = feats.get((k, s[k]), 0) + 1
            if a != b:
                diff += 1
                if diff <= 5:
                    print("DIFF", a, b, json.dumps(s), flush=True)
            if (i + 1) % 250 == 0:
                print("compared", i + 1, "differences", diff, flush=True)
        print("random: %d systems compared, %d differences "
              "(%d of them on answers only, the space being over %d states)" % (n, diff, big, FULL_LIMIT))
        print("answer spread:", sorted(answers.items(), key=lambda kv: -kv[1])[:12])
        print("features:", sorted(feats.items(), key=str))


if __name__ == "__main__":
    main()
