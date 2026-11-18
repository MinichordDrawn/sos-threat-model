"""F22: is 'good processes first' the worst halting order? Exhaustive over how many good
and how many bad processes each hop halts (processes of one kind are interchangeable)."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rc import *
from functools import lru_cache
sys.setrecursionlimit(100000)
g = cm.growth

def worst(n, a, b):
    @lru_cache(maxsize=None)
    def f(good, bad, frontier, k):
        # returns the largest number of further processes turned bad
        if k == 0:
            spread = min(bad, good)
            good2, bad2 = good - spread, bad + spread
            if bad2 == 0:
                return 0
            return spread + f(good2, bad2, frontier, b)
        newly = min(frontier * a, good + bad)
        lo, hi = max(0, newly - bad), min(newly, good)
        return max(f(good - gh, bad - (newly - gh), newly, k - 1) for gh in range(lo, hi + 1))
    return 1 + f(n - 1, 1, 1, b)

def goodfirst(n, a, b):
    return g(n, "cascade", a, b)

# sanity: restricting to good-first reproduces growth()
def gf_check(n, a, b):
    good, bad, frontier, total = n - 1, 1, 1, 1
    while bad:
        for _ in range(b):
            newly = min(frontier * a, good + bad)
            gh = min(newly, good)
            good -= gh; bad -= newly - gh; frontier = newly
        spread = min(bad, good); good -= spread; bad += spread; total += spread
    return total
assert all(gf_check(n, a, b) == goodfirst(n, a, b) for n in range(1, 300) for a, b in ((2, 1), (2, 2), (1, 1), (1, 4)))

print("n=8, two per hop, one hop per tick: good-first", goodfirst(8, 2, 1), "worst", worst(8, 2, 1))
for a, b, top in ((2, 1, 200), (2, 2, 200), (2, 4, 200), (1, 1, 120), (1, 2, 120)):
    diffs = [(n, goodfirst(n, a, b), worst(n, a, b)) for n in range(2, top + 1)]
    more = [(n, x, y) for n, x, y in diffs if y > x]
    ratio = max((y / x, n, x, y) for n, x, y in diffs)
    print(f"c={a}, h={b}, n=2..{top}: sizes where another order does more damage: {len(more)}; largest ratio {ratio}; first few {more[:6]}")
print("powers of two, c=2 h=1:", [(n, goodfirst(n, 2, 1), worst(n, 2, 1)) for n in (8, 16, 32, 64, 128, 256, 512, 1024)])
print("c=2,h=2 worst vs sqrt(n/2), n=2..400: violations:", [n for n in range(2, 401) if worst(n, 2, 2) ** 2 * 2 > n][:10])
print("c=2,h=2 :", [(n, goodfirst(n, 2, 2), worst(n, 2, 2)) for n in (32, 128, 512, 1024)])
print("c=2,h=1 worst share n=8..300:", max((worst(n, 2, 1) / n, n) for n in range(8, 301)), min((worst(n, 2, 1) / n, n) for n in range(8, 301)))
print("c=1,h=1 worst>=n-ceil(log2 n) trivially; examples:", [(n, goodfirst(n, 1, 1), worst(n, 1, 1)) for n in (4, 8, 16, 64)])
