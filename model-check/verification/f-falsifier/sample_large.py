"""Random samples of larger plain systems (not exhaustive), each decided by plain reachability.

    python -I sample_large.py            sizes (4,2) (5,1) (5,2) (6,2)

For every sampled gap-free system: the failing predicates, the spare monitors (by deciding
every S - m), and then a greedy thinning: edges are removed in random order for as long as
the system stays gap-free, giving an edge-minimal gap-free system, which is judged the same
way.  Thinned systems are where falsifiers with few edges live.  Self-loops are not sampled.
Writes sample_large.json.
"""
import json
import os
import random
import sys
import time
from collections import Counter
from multiprocessing import Pool

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plain


def rand_system(rng, n, k):
    p_h, p_c, p_f, p_i = (rng.choice((0.25, 0.4, 0.6, 0.8)), rng.choice((0.3, 0.5, 0.7)),
                          rng.choice((0.0, 0.1, 0.3, 0.6)), rng.choice((0.4, 0.6, 0.9)))

    def rows(p):
        return tuple(sum(1 << j for j in range(n) if j != i and rng.random() < p) for i in range(n))

    def full(p):
        return sum(1 << j for j in range(n) if rng.random() < p)

    return (n, k, rows(p_h), rows(p_c) + tuple(full(p_c) for _ in range(k)), rows(p_f),
            tuple(full(p_i) for _ in range(k)))


def thin(rng, s):
    n, k, hbr, chk, fwd, hi = s
    rowsets = [list(hbr), list(chk), list(fwd), list(hi)]
    edges = [(a, i, j) for a in range(4) for i in range(len(rowsets[a])) for j in range(n)
             if rowsets[a][i] >> j & 1]
    rng.shuffle(edges)
    for a, i, j in edges:
        rowsets[a][i] ^= 1 << j
        if not plain.gap_free_bfs(n, k, rowsets[0], rowsets[1], rowsets[2], rowsets[3]):
            rowsets[a][i] ^= 1 << j
    return (n, k, tuple(rowsets[0]), tuple(rowsets[1]), tuple(rowsets[2]), tuple(rowsets[3]))


def judge(s, memo):
    fl = "+".join(plain.failing(s)) or "none"
    spare = 0
    for m in range(s[0]):
        t = plain.delete(s, m)
        r = memo.get(t)
        if r is None:
            r = memo[t] = plain.gap_free_bfs(*t)
        spare += r
    return fl, spare


def worker(args):
    n, k, seed, seconds = args
    rng = random.Random(seed)
    memo = {}
    c = Counter()
    best = {}
    t0 = time.time()
    while time.time() - t0 < seconds:
        s = rand_system(rng, n, k)
        c["sampled"] += 1
        if not plain.gap_free_bfs(*s):
            continue
        c["gap_free"] += 1
        fl, spare = judge(s, memo)
        c["gap_free fails " + fl] += 1
        if not spare:
            c["no_spare"] += 1
            c["no_spare fails " + fl] += 1
        t = thin(rng, s)
        fl, spare = judge(t, memo)
        c["thinned"] += 1
        c["thinned fails " + fl] += 1
        readerless = sum(1 for m in range(n) if not t[2][m])
        if not spare:
            c["thinned no_spare"] += 1
            c["thinned no_spare fails " + fl] += 1
            c[f"thinned no_spare with {readerless} reader-less monitors"] += 1
            if any(not any(h >> m & 1 for h in t[5]) for m in range(n) if not t[2][m]):
                c["thinned no_spare, reader-less monitor outside every halt_inputs"] += 1
            if fl != "none":
                e = plain.edges(t)
                if fl not in best or e < best[fl][0]:
                    best[fl] = (e, t)
    return c, best


if __name__ == "__main__":
    out = {}
    for n, k, seconds in ((4, 2, 60), (5, 1, 60), (5, 2, 60), (6, 2, 60)):
        with Pool(12) as pool:
            parts = pool.map(worker, [(n, k, 1000 * n + 10 * k + i, seconds) for i in range(12)])
        c = Counter()
        best = {}
        for pc, pb in parts:
            c.update(pc)
            for fl, (e, t) in pb.items():
                if fl not in best or e < best[fl][0]:
                    best[fl] = (e, t)
        print(f"== {n} monitors, {k} work")
        for key in sorted(c):
            print(f"   {key}: {c[key]}")
        for fl, (e, t) in sorted(best.items()):
            print(f"   fewest-edge thinned no-spare system failing {fl}: {e} edges")
        out[f"{n}x{k}"] = {"counts": dict(sorted(c.items())),
                           "fewest_edge_examples": {fl: plain.to_json(t, f"{n}x{k} sampled, fails {fl}, {e} edges")
                                                    for fl, (e, t) in sorted(best.items())}}
    json.dump(out, open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "sample_large.json"), "w",
                        encoding="utf-8"), indent=1)
