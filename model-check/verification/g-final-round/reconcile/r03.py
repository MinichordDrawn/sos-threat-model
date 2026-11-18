import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rc import *
g = cm.growth
bad = [(n, w) for n in range(1, 400) for w in range(0, 12) if g(n, "window", w) != min(2**w, n)]
print("window = min(2^w, n) failures:", len(bad), "| g(8,window,5) =", g(8, "window", 5))
def clog2(n):
    return (n - 1).bit_length()
f1 = [(n, h) for n in range(1, 3001) for h in (1, 2, 16, 128) if g(n, "cascade", 1, h) < n - h * clog2(n)]
print("bound 1 failures n=1..3000, h in 1,2,16,128:", f1[:5], len(f1))
f2 = [n for n in range(1, 3001) if g(n, "cascade", 2, 2) ** 2 * 2 > n]
print("bound 2 failures n=1..3000:", f2[:10], len(f2))
for h in (3, 4, 8):
    fh = [n for n in range(2, 3001) if g(n, "cascade", 2, h) ** 2 * 2 > n]
    print(f"  c=2,h={h}: sqrt(n/2) failures n=2..3000:", fh[:5], len(fh))
print("c=2,h=1 small n:", [(n, g(n, "cascade", 2, 1)) for n in (1, 2, 3, 4, 5, 6, 7, 8, 16, 32)])
print("exactly n/4 fails at m =", [m for m in range(0, 61) if g(2**m, "cascade", 2, 1) * 4 != 2**m])
shares = [(g(n, "cascade", 2, 1) / n, n) for n in range(8, 3001)]
print("share range n=8..3000:", min(shares), max(shares))
shares2 = [(g(n, "cascade", 2, 1) / n, n) for n in range(5, 3001)]
print("share range n=5..3000:", min(shares2), max(shares2))
print("bound 2 at powers of two 2^12..2^60:", all(g(2**m, "cascade", 2, 2) ** 2 * 2 <= 2**m for m in range(12, 61)))
print("bound 1 at powers of two 2^12..2^20, h=1,128:", all(g(2**m, "cascade", 1, h) >= 2**m - h * m for m in range(12, 21) for h in (1, 128)))
for n in (1024, 1048576):
    print(n, [g(n, "window", 0), g(n, "window", 5), g(n, "cascade", 1, 1), g(n, "cascade", 1, 128),
              g(n, "cascade", 2, 1), g(n, "cascade", 2, 2), g(n, "cascade", 2, 4)])
