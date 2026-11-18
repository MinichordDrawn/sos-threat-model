"""All 2^24 plain systems with 3 monitors and 1 work process (no self-loops), each decided by
plain reachability (plain.gap_free_bfs), with no pruning and no symmetry reduction.  The set
of gap-free systems is then compared, element by element, with the set produced by the
per-process organisation (plain.allowed_sets) that search_small.py and the larger searches
use.

Run:  python -I honest_3x1.py        (about 2 minutes on 12 processes)
"""
import os
import sys
import time
from itertools import product
from multiprocessing import Pool

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plain

N, K = 3, 1
ROWS = plain.all_rows_no_self(N)            # 64 row-tuples
ROW_INDEX = {r: i for i, r in enumerate(ROWS)}


def code(fi, hi, ci, cw, hbi):
    return (((fi * 8 + hi) * 64 + ci) * 8 + cw) * 64 + hbi


def work(fi):
    fwd = ROWS[fi]
    found = []
    calls = 0
    for hi in range(8):
        for ci, chkm in enumerate(ROWS):
            for cw in range(8):
                chk = chkm + (cw,)
                for hbi, hbr in enumerate(ROWS):
                    calls += 1
                    if plain.gap_free_bfs(N, K, hbr, chk, fwd, (hi,)):
                        found.append(code(fi, hi, ci, cw, hbi))
    return calls, found


def by_allowed_sets():
    found = set()
    for fi, fwd in enumerate(ROWS):
        for hi in range(8):
            for hbi, hbr in enumerate(ROWS):
                A = plain.allowed_sets(N, K, hbr, fwd, (hi,))
                if A is None:
                    continue
                for c0, c1, c2, cw in product(*A):
                    found.add(code(fi, hi, ROW_INDEX[(c0, c1, c2)], cw, hbi))
    return found


if __name__ == "__main__":
    t0 = time.time()
    with Pool(12) as pool:
        parts = pool.map(work, range(len(ROWS)), chunksize=1)
    calls = sum(p[0] for p in parts)
    bfs = set()
    for p in parts:
        bfs.update(p[1])
    t1 = time.time()
    dec = by_allowed_sets()
    print(f"systems decided by reachability: {calls}  gap-free: {len(bfs)}  [{t1-t0:.0f}s]")
    print(f"gap-free by allowed_sets: {len(dec)}  [{time.time()-t1:.0f}s]")
    print("sets identical:", bfs == dec, " only-bfs:", len(bfs - dec), " only-allowed_sets:", len(dec - bfs))
