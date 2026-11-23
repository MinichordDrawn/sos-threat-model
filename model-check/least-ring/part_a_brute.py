#!/usr/bin/env python3
"""A check of the kind-by-kind search that does not use Lemma M.

Every set of at most six of the 36 edges (2,391,496 sets) is explored at one fault per
round, the work checked by and halting on all four. The search of part_a2.py says: no
set of five or fewer has no gap, and exactly 24 sets of six have none.

For the whole list the count needs no search at all: R2 needs eight signal reads and eight
state checks, R5 three reports, and the 81 sets of exactly those 19 edges are listed and
tested here one by one.

Run:  python -B part_a_brute.py
"""
import itertools
import os
import sys
from multiprocessing import Pool

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import mr_ring as R  # noqa: E402
import mr_model as mm  # noqa: E402

NODES = R.NODES4
U = sorted(R.all_edges(NODES))


def no_gap(edges, work="all", f=1):
    r = mm.explore(R.ring_system(frozenset(edges), NODES, "D", work, f), stop="gap")
    return r["G1"] is None and r["G2"] is None


def chunk(first):
    """Sets whose least edge (in order) is U[first], of sizes 1..6."""
    counts = [0] * 7
    good = []
    rest = U[first + 1:]
    for k in range(0, 6):
        for extra in itertools.combinations(rest, k):
            s = (U[first],) + extra
            counts[len(s)] += 1
            if no_gap(s):
                good.append(s)
    return counts, good


def main():
    with Pool(3) as pool:
        parts = pool.map(chunk, range(len(U)), chunksize=1)
    counts = [sum(p[0][k] for p in parts) for k in range(7)]
    counts[0] = 1
    good = [s for p in parts for s in p[1]]
    print("sets explored by size 0..6:", counts, "total", sum(counts))
    print("the empty set has no gap:", no_gap(()))
    by = {}
    for s in good:
        by.setdefault(len(s), []).append(s)
    print("sets with no gap, by size:", {k: len(v) for k, v in sorted(by.items())})

    print("\nthe whole list, by listing: 81 sets of 19 edges")
    import part_a2 as P
    for work in ("all", "two"):
        for f in (1, 2, 3):
            n = 0
            for omit in itertools.product(range(3), repeat=4):
                x = set(("fwd", m, "D") for m in "ABC")
                for z, o in zip(NODES, omit):
                    others = [m for m in NODES if m != z]
                    for i, m in enumerate(others):
                        if i != o:
                            x.add(("hb_readers", z, m))
                            x.add(("checkers", z, m))
                x = frozenset(x)
                assert len(x) == 19
                if P.good_for(["R1", "R2", "R3", "R5", "R6"], work, f)(x):
                    n += 1
            print(f"work reads {work}, f={f}: {n} of the 81 meet the whole list")


if __name__ == "__main__":
    main()
