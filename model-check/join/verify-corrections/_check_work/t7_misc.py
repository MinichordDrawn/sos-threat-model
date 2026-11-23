"""A8 (section 4.2 least attachments at f=3), base hypotheses of Theorem L, and alternative readings for part B."""
import itertools, random, sys, time
from build import *

A = ["M1", "M2", "M3", "K"]
print("=== A8: N with J (J checked by N, halting on N, M1, M2, M3); attachments of N among the 24 edges")
def s42(f, edges, ab):
    s = base_mesh(f)
    add_monitor(s, "N")
    s["joiner"] = "J"
    add(s, "checkers", "J", "N")
    for x in ["N", "M1", "M2", "M3"]:
        add(s, "halt_inputs", "J", x)
    for k, x in edges:
        if k == "cN": add(s, "checkers", "N", x)
        elif k == "rN": add(s, "hb_readers", "N", x)
        elif k == "fromN": add(s, "fwd", "N", x)
        elif k == "nc": add(s, "checkers", x, "N")
        elif k == "nr": add(s, "hb_readers", x, "N")
        elif k == "toN": add(s, "fwd", x, "N")
    late_group(s, "NJ", ["N", "J"])
    s["arrive_bad"] = ab
    return s
three = [[("cN", c), ("rN", r), ("fromN", t)] for c in A for r in A for t in A]
for f in (1, 2, 3):
    ng = sum(1 for e in three if nogap(M(s42(f, e, True)).solve(anygap=True)))
    ngg = sum(1 for e in three if nogap(M(s42(f, e, False)).solve(anygap=True)))
    print("  f=%d: three-edge attachments (check of N, read of N, report from N): %d; no gap: %d (may arrive bad), %d (arrive good)" % (f, len(three), ng, ngg))
four = []
for e in three:
    for x in ("M1", "M2", "M3"):
        four.append(e + [("nc", x)])
    four.append(e + [("toN", "K")])
ng = sum(1 for e in four if nogap(M(s42(3, e, True)).solve(anygap=True)))
print("  f=3: the 256 four-edge attachments of section 4.2: %d built, %d with no gap (may arrive bad)" % (len(four), ng))
# no two-edge attachment has no gap at f=1 (so three is the fewest): all pairs of the 24 edges
E = [(k, x) for x in A for k in ("cN", "rN", "fromN", "nc", "nr", "toN")]
ng = sum(1 for e in itertools.combinations(E, 2) if nogap(M(s42(1, list(e), False)).solve(anygap=True)))
print("  f=1: two-edge attachments with no gap (arrive good): %d of %d" % (ng, len(list(itertools.combinations(E, 2)))))

print("=== base rings: every one-round outcome with a fault is a complete response, at each f up to the rate")
for name, mk, rate in (("mesh", lambda f: base_mesh(f), 3), ("cycle checking", lambda f: base_cycle(f, "checking"), 3),
                       ("cycle reading", lambda f: base_cycle(f, "reading"), 2), ("cycle nested", lambda f: base_cycle(f, "nested"), 2)):
    for f in range(1, rate + 1):
        mm = M(mk(f))
        tot = bad = 0
        for post, labs in mm.env(mm.init).items():
            if post == mm.init:
                continue
            st, v1, v2 = mm.round(mm.init, post)
            tot += 1
            if not mm.responded(st) or v1 or v2:
                bad += 1
        print("  %-15s f=%d: %d outcomes with a fault, %d not a complete response" % (name, f, tot, bad))

print("=== part B: alternative readings on random small systems (all features of both specification files)")
random.seed(5)
def rnd():
    nm = random.randint(2, 4)
    mons = ["M%d" % i for i in range(1, nm + 1)]
    works = ["W%d" % i for i in range(1, random.randint(1, 2) + 1)]
    joiner = "J" if random.random() < 0.5 else None
    s = empty(random.randint(1, 2), mons, works, joiner)
    s["boundary"] = {m: random.choice(["a", "b", "c"]) for m in mons if random.random() < 0.8}
    procs = mons + works + ([joiner] if joiner else [])
    s["substrate"] = {p: random.choice(["s", "t"]) for p in procs if random.random() < 0.25}
    for p in procs:
        for m in mons:
            if p in mons:
                if random.random() < 0.45: add(s, "hb_readers", p, m)
                if random.random() < 0.3: add(s, "fwd", p, m)
            else:
                if random.random() < 0.5: add(s, "halt_inputs", p, m)
            if random.random() < 0.45: add(s, "checkers", p, m)
    s["switches"] = [m for m in mons if random.random() < 0.2]
    s["coupling"] = random.random() < 0.7
    s["window"] = 1 if random.random() < 0.2 else 0
    s["gate"] = random.random() < 0.8
    s["slow_reports"] = random.random() < 0.2
    s["arrive_bad"] = random.random() < 0.5
    # late groups
    cand = [m for m in mons[1:] if random.random() < 0.5] + ([joiner] if joiner and random.random() < 0.5 else [])
    random.shuffle(cand)
    gi = 0
    while cand:
        k = random.randint(1, min(2, len(cand)))
        mem, cand = cand[:k], cand[k:]
        aft = [p for p in procs if random.random() < 0.2]
        late_group(s, "g%d" % gi, mem, aft)
        gi += 1
    slow = []
    for rel in ("hb_readers", "checkers", "fwd", "halt_inputs"):
        for k, lst in s[rel].items():
            for m in lst:
                if random.random() < 0.2:
                    slow.append([rel, k, m])
    if slow:
        s["slow_edges"] = slow
    return s
t0 = time.time()
n = d_mut = d_aft = agree = 0
ex_mut = ex_aft = None
for i in range(6000):
    s = rnd()
    r = M(s).solve(limit=200000)
    if not r["complete"]:
        continue
    n += 1
    g1, g2, ns, ok = indep.Model(s).solve()
    assert (g1, g2) == (r["G1"], r["G2"]), ("DISAGREE with independent_model.py", s, (g1, g2), r)
    agree += 1
    r2 = M(s, alt_mutate_alive_only=True).solve(limit=200000)
    if fmt(r2) != fmt(r):
        d_mut += 1
        if ex_mut is None or len(str(s)) < len(str(ex_mut[0])):
            ex_mut = (s, fmt(r), fmt(r2))
    r3 = M(s, alt_after_alive=True).solve(limit=200000)
    if fmt(r3) != fmt(r):
        d_aft += 1
        if ex_aft is None or len(str(s)) < len(str(ex_aft[0])):
            ex_aft = (s, fmt(r), fmt(r3))
print("  %d random systems; my implementation and independent_model.py agree on all %d" % (n, agree))
print("  reading 'mutate applies only to a monitor still in alive': result differs on %d" % d_mut)
if ex_mut: print("     example:", ex_mut)
print("  reading 'an after entry is satisfied only while the named monitor is alive': result differs on %d" % d_aft)
if ex_aft: print("     example:", ex_aft)
print("  (%.0f s)" % (time.time() - t0))

print("=== B5: if the joiner's entry in halt_inputs were not read")
def s43(f, drop):
    s = base_mesh(f)
    add_monitor(s, "N")
    for x in ("M1", "M2", "M3"):
        mesh_pair(s, "N", x)
    s["joiner"] = "J"
    add(s, "checkers", "J", "N")
    if not drop:
        for x in ["N", "M1", "M2", "M3"]:
            add(s, "halt_inputs", "J", x)
    late_group(s, "NJ", ["N", "J"])
    return s
print("  N in a mesh with M1,M2,M3, J joining with N, f=1: read:", fmt(both(s43(1, False))), " not read:", fmt(both(s43(1, True))))
