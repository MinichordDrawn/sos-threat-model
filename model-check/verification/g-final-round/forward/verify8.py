"""Forward verifier, eighth batch: the falsifier's counts, re-decided with check_model.
(2,1) and (2,2) exhaustively; (3,1) on a uniform random sample. Run with python -I -B."""
import itertools
import random
import sys
import time

import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, FM)
import check_model as cm


def build(n, k, bits):
    mons = [f"M{i}" for i in range(1, n + 1)]
    works = [f"W{i}" for i in range(1, k + 1)]
    s = cm.System("x", 1)
    s.monitors, s.works = mons, works
    s.boundary = {m: i for i, m in enumerate(mons)}
    it = iter(bits)
    for rel in ("hb_readers", "checkers", "fwd"):
        for m in mons:
            getattr(s, rel)[m] = [o for o in mons if o != m and next(it)]
    for w in works:
        s.checkers[w] = [m for m in mons if next(it)]
        s.halt_inputs[w] = [m for m in mons if next(it)]
    return s


def gapfree(s):
    first, _ = cm.explore(s)
    return first["G1"] is None and first["G2"] is None


def spare_free(s):
    return not any(gapfree(cm.without_monitor(s, m)) for m in s.monitors)


def q1(s):
    return all(any(r != m for r in s.hb_readers.get(m, ())) for m in s.monitors)


def q4(s):
    mons = set(s.monitors)
    return all(mons <= cm.reach(s, [a], ()) for a in mons)


for n, k in ((2, 1), (2, 2)):
    width = 3 * n * (n - 1) + 2 * n * k
    tot = free = nospare = 0
    for bits in itertools.product((0, 1), repeat=width):
        s = build(n, k, bits)
        tot += 1
        if gapfree(s):
            free += 1
            nospare += spare_free(s)
    print(f"({n},{k}): systems {tot}, no gap {free}, no spare monitor {nospare}")

rng = random.Random(99)
N = 40000
t0 = time.time()
free = nospare = fq1 = fq4 = ns_fals = 0
for _ in range(N):
    s = build(3, 1, [rng.getrandbits(1) for _ in range(24)])
    if gapfree(s):
        free += 1
        a, b = q1(s), q4(s)
        fq1 += not a
        fq4 += not b
        if spare_free(s):
            nospare += 1
            ns_fals += not (a and b)
print(f"(3,1) uniform sample of {N}: no gap {free} ({free / N:.4f}; exhaustive count gives "
      f"{1169616 / 16777216:.4f})")
print(f"   of those: no spare {nospare / free:.3f} (exhaustive {742352 / 1169616:.3f}); "
      f"signal predicate fails {fq1 / free:.3f} (exhaustive {178176 / 1169616:.3f}); "
      f"propagation predicate fails {fq4 / free:.3f} (exhaustive {798222 / 1169616:.3f}); "
      f"no-spare failing either {ns_fals / max(nospare, 1):.3f} (exhaustive {515030 / 742352:.3f})")
print("seconds", round(time.time() - t0, 1))
