"""Cross-checks between the three deciders.

  A. model.py (reference, set-based, whole spec)
  B. plain.gap_free_bfs (bitmask reachability)
  C. plain.allowed_sets (per-process organisation of the same exploration)

1. Every plain system with 2 monitors and 1 work process, INCLUDING self-loops
   (m in hb_readers[m], checkers[m], fwd[m]): 2^16 systems, A vs B vs C, and
   A(system) == A(system with self-loops removed).
2. Random plain systems with 3 and 4 monitors, 1 and 2 work processes, self-loops allowed:
   A vs B vs C.

Run:  python -I crosscheck.py
"""
import os
import random
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import model
import plain


def decide_A(s):
    return model.gap_free(plain.to_json(s), f=1)


def decide_B(s):
    return plain.gap_free_bfs(*s)


def decide_C(s):
    n, k, hbr, chk, fwd, hi = plain.strip_self(s)
    A = plain.allowed_sets(n, k, hbr, fwd, hi)
    return A is not None and all(chk[x] in A[x] for x in range(n + k))


def all_2x1_with_self_loops():
    n, k = 2, 1
    for bits in range(1 << 16):
        hbr = (bits & 3, bits >> 2 & 3)
        chk = (bits >> 4 & 3, bits >> 6 & 3, bits >> 8 & 3)
        fwd = (bits >> 10 & 3, bits >> 12 & 3)
        hi = (bits >> 14 & 3,)
        yield (n, k, hbr, chk, fwd, hi)


def random_system(rng, n, k, p):
    def m():
        return sum(1 << i for i in range(n) if rng.random() < p)
    return (n, k, tuple(m() for _ in range(n)), tuple(m() for _ in range(n + k)),
            tuple(m() for _ in range(n)), tuple(m() for _ in range(k)))


if __name__ == "__main__":
    t0 = time.time()
    total = gf = mism = selfmism = 0
    for s in all_2x1_with_self_loops():
        a, b, c = decide_A(s), decide_B(s), decide_C(s)
        total += 1
        gf += a
        mism += not (a == b == c)
        selfmism += a != decide_A(plain.strip_self(s))
    print(f"2 monitors, 1 work, self-loops allowed: {total} systems, {gf} gap-free, "
          f"A/B/C disagreements {mism}, self-loop sensitivity {selfmism}  [{time.time()-t0:.0f}s]")

    rng = random.Random(20261117)
    for n, k, count in ((3, 1, 6000), (3, 2, 4000), (4, 1, 3000), (4, 2, 2000), (5, 2, 500)):
        t0 = time.time()
        gf = mism = 0
        for _ in range(count):
            s = random_system(rng, n, k, rng.choice((0.35, 0.5, 0.65, 0.8)))
            a, b, c = decide_A(s), decide_B(s), decide_C(s)
            gf += a
            mism += not (a == b == c)
        print(f"random {n} monitors, {k} work, self-loops allowed: {count} systems, {gf} gap-free, "
              f"A/B/C disagreements {mism}  [{time.time()-t0:.0f}s]")
