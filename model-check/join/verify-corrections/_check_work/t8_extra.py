"""Extras: the 'after' reading on the chain of A11; random result spread; Theorem L with other bases."""
import random, sys
from build import *

def chain(f, ab=True, drop=None):
    s = base_mesh(f)
    prev = "M1"
    for n in ("N5", "N6", "N7"):
        add_monitor(s, n)
        watch(s, prev, n); report(s, n, prev)
        late_group(s, n, [n], after=[] if prev == "M1" else [prev])
        prev = n
    if drop:
        rem(s, *drop)
    s["arrive_bad"] = ab
    return s
s = chain(1, True, ("hb_readers", "N6", "N5"))
print("chain, N5 does not read N6's signal, f=1, may arrive bad: as specified", fmt(M(s).solve()),
      "| if 'after' needed the named monitor alive:", fmt(M(s, alt_after_alive=True).solve()))
s = chain(1, False, ("hb_readers", "N6", "N5"))
print("same, arrive good: as specified", fmt(M(s).solve()), "| alt:", fmt(M(s, alt_after_alive=True).solve()))

# Theorem L with a base whose rate is 1: mesh, W checked by M1 and halting on M1 and K ("W reads two")
def base_two(f, kind):
    s = base_mesh(f) if kind == "mesh" else base_cycle(f, kind)
    s["checkers"]["W"] = ["M1"]
    s["halt_inputs"]["W"] = ["M1", "K"]
    return s
for kind in ("mesh", "checking", "reading", "nested"):
    mm = M(base_two(1, kind))
    bad = 0
    for post, labs in mm.env(mm.init).items():
        if post != mm.init:
            st, v1, v2 = mm.round(mm.init, post)
            if not mm.responded(st) or v1 or v2:
                bad += 1
    print("base", kind, "W reads two: f=1,2:", [fmt(both(base_two(f, kind))) for f in (1, 2)], "| one-round outcomes with a fault that are not a complete response at f=1:", bad)

random.seed(99)
def grow(kind):
    s = base_two(1, kind)
    B = list(s["monitors"])
    k = random.randint(1, 4)
    late = ["N%d" % i for i in range(5, 5 + k)]
    for idx, n in enumerate(late):
        s["monitors"].append(n)
        lower = B + late[:idx]
        c, r, t = random.choice(lower), random.choice(lower), random.choice(lower)
        add(s, "checkers", n, c); add(s, "hb_readers", n, r); add(s, "fwd", n, t)
        late_group(s, n, [n], after=sorted(set(x for x in (c, r, t) if x in late)))
        for x in B + late:
            for rel, kk, m_ in (("checkers", n, x), ("hb_readers", n, x), ("fwd", n, x), ("checkers", x, n), ("hb_readers", x, n), ("fwd", x, n)):
                if x != n and random.random() < 0.2:
                    add(s, rel, kk, m_)
        if random.random() < 0.3: add(s, "halt_inputs", "W", n)
        if random.random() < 0.3: add(s, "checkers", "W", n)
        if random.random() < 0.3: s["boundary"][n] = "b_" + random.choice(B)
    s["arrive_bad"] = random.random() < 0.6
    return s
n = gaps = 0
for i in range(3000):
    s = grow(random.choice(["mesh", "checking", "reading", "nested"]))
    r = M(s).solve(anygap=True)
    n += 1
    if not nogap(r):
        gaps += 1
        if gaps == 1:
            print("COUNTEREXAMPLE", s)
print("Theorem L class on bases with W reading two (rate 1), f=1: %d systems, %d with a gap" % (n, gaps))
