"""Part B: spread of results on random systems, and a denser search for a system on which the
'mutate needs an alive monitor' reading gives a different result."""
import random, time
from build import *
src = open("t7_misc.py").read()
start = src.index("def rnd():")
end = src.index("t0 = time.time()", start)
exec(src[start:end])
random.seed(31)
t0 = time.time()
dist = {}
n = dm = da = 0
exm = None
for i in range(30000):
    s = rnd()
    # denser: add checkers and readers so that results go deeper
    for p in s["monitors"] + s["works"]:
        for m in s["monitors"]:
            if m != p and random.random() < 0.4:
                add(s, "checkers", p, m)
    r = M(s).solve(limit=100000)
    if not r["complete"]:
        continue
    n += 1
    dist[fmt(r)] = dist.get(fmt(r), 0) + 1
    r2 = M(s, alt_mutate_alive_only=True).solve(limit=100000)
    if fmt(r2) != fmt(r):
        dm += 1
        if exm is None or len(str(s)) < len(str(exm[0])):
            exm = (s, fmt(r), fmt(r2))
    if i % 20 == 0:
        g1, g2, ns, ok = indep.Model(s).solve()
        assert (g1, g2) == (r["G1"], r["G2"])
top = sorted(dist.items(), key=lambda kv: -kv[1])[:12]
print("%d systems; commonest results: %s; distinct results: %d" % (n, top, len(dist)))
print("reading 'mutate needs a monitor still alive': differs on %d" % dm)
if exm:
    print(exm)
print("(%.0f s)" % (time.time() - t0))
