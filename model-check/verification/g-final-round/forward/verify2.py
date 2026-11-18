"""Forward verifier: the growth bounds of section 8.2, the halting order, and naming."""
import itertools
import math
import sys
from functools import lru_cache

import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, FM)
import check_model as cm  # noqa: E402


def clog2(n):
    return (n - 1).bit_length()          # ceil(log2 n) for n >= 1


print("== table of section 8.2")
for n in (1024, 1048576):
    print(n, [cm.growth(n, "window", w) for w in (0, 5)],
          [cm.growth(n, "cascade", c, h) for c, h in ((1, 1), (1, 128), (2, 1), (2, 2), (2, 4))])

print("== window: damage == min(2^w, n)?")
bad = [(n, w) for n in range(1, 400) for w in range(0, 12) if cm.growth(n, "window", w) != min(2 ** w, n)]
print("  mismatches with min(2^w, n):", len(bad))
print("  cases where damage != 2^w (n < 2^w):", sum(1 for n in range(1, 400) for w in range(0, 12)
                                                    if cm.growth(n, "window", w) != 2 ** w))

print("== (i) chain: damage >= n - h*ceil(log2 n)")
viol = []
tight = 0
for n in range(1, 3001):
    for h in (1, 2, 3, 4, 8, 16, 128):
        d = cm.growth(n, "cascade", 1, h)
        if d < n - h * clog2(n):
            viol.append((n, h, d))
        if d == n - h * clog2(n):
            tight += 1
print("  violations n=1..3000:", viol[:10], "tight cases:", tight)
viol = [(m, h) for m in range(12, 21) for h in (16, 128)        # a chain takes n/h ticks
        if cm.growth(2 ** m, "cascade", 1, h) < 2 ** m - h * m]
print("  violations for powers of two 2^12..2^20 (h = 16, 128):", viol, flush=True)

print("== (ii) doubling halt, two hops per tick: damage <= sqrt(n/2)")
viol = [(n, cm.growth(n, "cascade", 2, 2)) for n in range(1, 3001)
        if cm.growth(n, "cascade", 2, 2) ** 2 * 2 > n]
print("  violations n=1..3000:", viol)
viol = [m for m in range(12, 61) if cm.growth(2 ** m, "cascade", 2, 2) ** 2 * 2 > 2 ** m]
print("  violations for powers of two 2^12..2^60:", viol)
print("  max damage/sqrt(n/2), n=2..3000:",
      max((cm.growth(n, "cascade", 2, 2) / math.sqrt(n / 2), n) for n in range(2, 3001)))

print("== (iii) doubling halt, one hop per tick: damage vs n/4")
for m in range(0, 8):
    n = 2 ** m
    print(f"  n={n}: damage {cm.growth(n, 'cascade', 2, 1)}  n/4={n / 4}")
print("  powers of two 2^3..2^60 with damage != n/4:",
      [m for m in range(3, 61) if cm.growth(2 ** m, "cascade", 2, 1) * 4 != 2 ** m])
ratios = [(cm.growth(n, "cascade", 2, 1) / n, n) for n in range(8, 3001)]
print("  share lost for every n in 8..3000: min", min(ratios), "max", max(ratios))
ratios = [(cm.growth(n, "cascade", 2, 1) / n, n) for n in range(1000, 3001)]
print("  share lost for every n in 1000..3000: min", min(ratios), "max", max(ratios))


# ---- the halting order: is "good processes first" the worst order for the damage?
def worst(n, c, h):
    """Largest damage over every choice of which running processes each hop halts."""
    sys.setrecursionlimit(100000)

    @lru_cache(maxsize=None)
    def v(g, b, fr, i):
        if b == 0:
            return 0
        if i == h:                                   # the spread
            s = min(b, g)
            return s + v(g - s, b + s, fr, 0)
        k = min(c * fr, g + b)
        best = 0
        for j in range(max(0, k - g), min(k, b) + 1):   # j bad ones halted in this hop
            best = max(best, v(g - (k - j), b - j, k, i + 1))
        return best

    return 1 + v(n - 1, 1, 1, 0)


print("== halting order: good-first against the true worst order")
for c, h in ((2, 1), (2, 2), (2, 4), (1, 1), (1, 4)):
    diffs = []
    for n in range(2, 201 if c == 2 else 41):
        gf = cm.growth(n, "cascade", c, h)
        w = worst(n, c, h)
        assert w >= gf
        if w > gf:
            diffs.append((n, gf, w))
    print(f"  c={c} h={h}: n in 2..200 where some other order does more damage: {len(diffs)}; first {diffs[:6]}")
    if diffs:
        print("     largest ratio worst/good-first:", max((w / gf, n, gf, w) for n, gf, w in diffs))
for n in (8, 16, 64, 256, 1024):
    print(f"  n={n}: c=2,h=1 good-first {cm.growth(n, 'cascade', 2, 1)} worst {worst(n, 2, 1)};"
          f" c=2,h=2 good-first {cm.growth(n, 'cascade', 2, 2)} worst {worst(n, 2, 2)}"
          f" sqrt(n/2)={math.sqrt(n / 2):.2f}")


# ---- naming the faulty monitors: does a correct rule exist for (k monitors, at most f faulty)?
def rule_exists(k, f, self_naming):
    mons = range(k)
    seen = {}
    for size in range(0, f + 1):
        for faulty in itertools.combinations(mons, size):
            fs = frozenset(faulty)
            choices = []
            for m in mons:
                if m in fs:
                    pool = [x for x in mons if self_naming or x != m]
                    choices.append([frozenset(s) for r in range(len(pool) + 1)
                                    for s in itertools.combinations(pool, r)])
                else:
                    choices.append([fs])
            for profile in itertools.product(*choices):
                if seen.setdefault(profile, fs) != fs:
                    return False
    return True


print("== naming: a correct rule exists?")
for k, f in ((2, 1), (3, 1), (4, 1), (4, 2), (5, 2)):
    print(f"  k={k} f={f}: others only {rule_exists(k, f, False)}; may name itself {rule_exists(k, f, True)}")
