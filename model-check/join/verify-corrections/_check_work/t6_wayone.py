"""Way one (section 6.1): each new monitor in a mesh with three that watch each other, from the mesh of four.
Count up to renaming; rate with ordered joins; 'any order' (A10); slow reports at f=1 (A14)."""
import itertools, sys, time
from build import *

BASE = ["M1", "M2", "M3", "K"]

def grow_all(k):
    """all attachment sequences for k new monitors: list of tuples of frozenset triples (indices 0..3 base, 4.. new)."""
    seqs = [()]
    for step in range(k):
        out = []
        for sq in seqs:
            n = 4 + len(sq)
            adj = {i: set(j for j in range(4) if j != i) for i in range(4)}
            for i, tri in enumerate(sq):
                v = 4 + i
                adj[v] = set(tri)
                for t in tri:
                    adj[t].add(v)
            for tri in itertools.combinations(range(n), 3):
                a, b, c = tri
                if b in adj[a] and c in adj[a] and c in adj[b]:
                    out.append(sq + (frozenset(tri),))
        seqs = out
    return seqs

def canon(sq):
    k = len(sq)
    edges = set()
    for i in range(4):
        for j in range(i + 1, 4):
            edges.add((i, j))
    for i, tri in enumerate(sq):
        for t in tri:
            edges.add((min(t, 4 + i), max(t, 4 + i)))
    best = None
    for pb in itertools.permutations(range(4)):
        for pl in itertools.permutations(range(4, 4 + k)):
            p = list(pb) + list(pl)
            e = tuple(sorted((min(p[a], p[b]), max(p[a], p[b])) for a, b in edges))
            if best is None or e < best:
                best = e
    return best

def build(sq, f, ab=True, order=True, slow_reports=False):
    s = base_mesh(f)
    names = BASE + ["N%d" % (5 + i) for i in range(len(sq))]
    for i, tri in enumerate(sq):
        n = names[4 + i]
        add_monitor(s, n)
        for t in sorted(tri):
            mesh_pair(s, n, names[t])
        late_group(s, n, [n], after=[names[t] for t in sorted(tri) if t >= 4] if order else [])
    s["arrive_bad"] = ab
    if slow_reports:
        s["slow_reports"] = True
    return s

t0 = time.time()
reps = []
for k in (1, 2, 3, 4):
    seen = {}
    for sq in grow_all(k):
        c = canon(sq)
        if c not in seen:
            seen[c] = sq
    print("monitors %d: %d attachment sequences, %d systems up to renaming (base four among themselves, new among themselves)" % (4 + k, len(grow_all(k)), len(seen)))
    reps += list(seen.values())
print("total", len(reps))
sys.stdout.flush()

# rate with ordered joins, a new monitor may arrive bad
rates = {}
for sq in reps:
    r = 0
    for f in (1, 2, 3, 4):
        x = M(build(sq, f)).solve(anygap=True)
        if nogap(x):
            r = f
        else:
            break
    rates[r] = rates.get(r, 0) + 1
print("ordered joins, may arrive bad: systems by rate:", rates, "(%.0f s)" % (time.time() - t0))
sys.stdout.flush()

# any order
res = {}
gapsys = []
for sq in reps:
    r = 0
    for f in (1, 2, 3):
        x = M(build(sq, f, order=False)).solve(anygap=True)
        if nogap(x):
            r = f
        else:
            break
    res[r] = res.get(r, 0) + 1
    alllate = any(all(t >= 4 for t in tri) for tri in sq)
    if r < 3:
        gapsys.append((sq, r))
    assert (r < 3) == alllate, ("criterion differs", sq, r)
print("any order, may arrive bad: systems by rate (up to 3):", res, "(%.0f s)" % (time.time() - t0))
for sq, r in gapsys:
    print("   gap system: attachments", [sorted(t) for t in sq], "rate", r, "f=1 result", fmt(both(build(sq, 1, order=False))))
print("   a gap exactly in the systems where some monitor's three are all late: True (asserted for all 62)")
sys.stdout.flush()

# slow reports, f=1, ordered joins, may arrive bad (the 62 systems checked) and arriving good
out = {}
for sq in reps:
    x = M(build(sq, 1, ab=True, slow_reports=True)).solve(limit=500000)
    y = M(build(sq, 1, ab=False, slow_reports=True)).solve(limit=500000)
    assert x["complete"] and y["complete"]
    nobase = any(all(t >= 4 for t in tri) for tri in sq)
    key = (fmt(x), fmt(y), nobase)
    out[key] = out.get(key, 0) + 1
print("slow reports f=1: (result may arrive bad, result arrive good, some monitor has no base monitor among its three): count")
for kx, v in sorted(out.items()):
    print("   ", kx, v)
print("(%.0f s)" % (time.time() - t0))
