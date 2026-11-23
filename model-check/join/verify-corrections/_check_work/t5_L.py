"""A6: random systems of Theorem L's class as now stated; and the same with the added hypothesis broken."""
import random, sys, time
from build import *

random.seed(int(sys.argv[1]) if len(sys.argv) > 1 else 11)
N = int(sys.argv[2]) if len(sys.argv) > 2 else 400

def grow(break_hyp=None):
    base = random.choice(["mesh", "checking", "reading", "nested"])
    rate = 3 if base in ("mesh", "checking") else 2
    f = random.randint(1, rate)
    s = base_mesh(f) if base == "mesh" else base_cycle(f, base)
    B = list(s["monitors"])
    k = random.randint(1, 4)
    late = ["N%d" % i for i in range(5, 5 + k)]
    # groups: consecutive runs
    groups = []
    i = 0
    while i < k:
        j = min(k, i + random.choice([1, 1, 1, 2, 3]))
        groups.append(late[i:j])
        i = j
    gof = {}
    for gi, g in enumerate(groups):
        for m in g:
            gof[m] = gi
    after = [set() for _ in groups]
    key = []
    for idx, n in enumerate(late):
        s["monitors"].append(n)
        lower = B + late[:idx]
        c, r, t = random.choice(lower), random.choice(lower), random.choice(lower)
        add(s, "checkers", n, c); add(s, "hb_readers", n, r); add(s, "fwd", n, t)
        key += [["checkers", n, c], ["hb_readers", n, r], ["fwd", n, t]]
        for x in (c, r, t):
            if x in gof and gof[x] != gof[n]:
                after[gof[n]].add(x)      # present whenever n is
    for gi, g in enumerate(groups):
        # extra, harmless 'after' entries
        extra = set()
        if random.random() < 0.3:
            extra.add(random.choice(B + ["W"]))
        if random.random() < 0.3 and gi > 0:
            extra.add(random.choice(groups[gi - 1]))
        late_group(s, "g%d" % gi, g, after=sorted(after[gi] | extra))
    allm = B + late
    # any other edges at late monitors
    edges = list(key)
    for n in late:
        for x in allm:
            if x == n and random.random() < 0.7:
                continue
            for rel, kk, mm_ in (("checkers", n, x), ("hb_readers", n, x), ("fwd", n, x),
                                 ("checkers", x, n), ("hb_readers", x, n), ("fwd", x, n)):
                if random.random() < 0.25:
                    add(s, rel, kk, mm_)
                    if [rel, kk, mm_] not in edges:
                        edges.append([rel, kk, mm_])
        if random.random() < 0.3:
            add(s, "checkers", "W", n); edges.append(["checkers", "W", n])
        if random.random() < 0.3:
            add(s, "halt_inputs", "W", n); edges.append(["halt_inputs", "W", n])
    # slow edges: any edge that is not one of the three of each late monitor (base edges may be listed too)
    slow = []
    for e in edges:
        if e not in key and random.random() < 0.4:
            slow.append(e)
    for rel in ("checkers", "hb_readers", "fwd", "halt_inputs"):
        for kk, lst in s[rel].items():
            for m_ in lst:
                if [rel, kk, m_] not in edges and random.random() < 0.1:
                    slow.append([rel, kk, m_])
    # boundaries and substrates of late monitors: anything
    for n in late:
        z = random.random()
        if z < 0.3:
            s["boundary"][n] = "b_" + random.choice(B)        # shared with a base monitor
        elif z < 0.6:
            s["boundary"][n] = "shared_late"
        elif z < 0.8:
            s["boundary"][n] = "b_" + n
        if random.random() < 0.4:
            s["substrate"][n] = random.choice(["s1", "s2"])
    s["arrive_bad"] = random.random() < 0.6
    if break_hyp == "switch":
        s["switches"] = [random.choice(late)]
    elif break_hyp == "slowkey":
        slow.append(random.choice(key))
    elif break_hyp == "slowcheck":
        slow.append(random.choice([e for e in key if e[0] == "checkers"]))
    if slow:
        s["slow_edges"] = slow
    return s

t0 = time.time()
for hyp in (None, "switch", "slowkey", "slowcheck"):
    n = gaps = 0
    ex = None
    for i in range(N):
        s = grow(hyp)
        r = M(s).solve(anygap=True, limit=300000)
        assert r["complete"]
        if i % 10 == 0:
            g1, g2, ns, ok = indep.Model(s).solve(state_limit=300000)
            assert ok and ((g1 is None and g2 is None) == nogap(r)), ("DISAGREE", s)
        n += 1
        if not nogap(r):
            gaps += 1
            if ex is None:
                ex = s
    print("hypothesis %-10s: %d systems, %d with a gap  (%.0f s)" % ("as stated" if hyp is None else "broken: " + hyp, n, gaps, time.time() - t0))
    if hyp is None and ex is not None:
        print("  COUNTEREXAMPLE:", ex)
        r = M(ex).solve(trace=True)
        show_trace(r["t1"] or r["t2"])
    sys.stdout.flush()
