# Random search for counterexamples to the statements marked Proved in section 3
# (Lemma M, Lemma N, Theorems L, J, F, Theorem S in every present set, a monitor nobody checks)
# and to the slow-reports statement of section 9.
import itertools, random, sys, time
from sosmodel import Model, solve, with_f, fmt
from systems import *

seed = int(sys.argv[1]) if (len(sys.argv) > 1 and __name__ == "__main__") else 1
budget = float(sys.argv[2]) if (len(sys.argv) > 2 and __name__ == "__main__") else 60.0
which = (sys.argv[3].split(",") if len(sys.argv) > 3 else None) if __name__ == "__main__" else []
random.seed(seed)
INF = 10 ** 9


def val(x):
    return INF if x is None else x


# ---------------------------------------------------------------- helpers on system dicts
def reach_present_sets(s):
    """Every set of present processes the joins can reach (frozensets of names)."""
    late = s.get("late", []) or []
    members = set(x for g in late for x in g["members"])
    init = frozenset([m for m in s["monitors"] if m not in members] + list(s["works"]))
    seen = {init}
    todo = [init]
    j = s.get("joiner")
    while todo:
        p = todo.pop()
        nxt = []
        if j is not None and j not in members and j not in p:
            nxt.append(p | {j})
        for g in late:
            if g["members"][0] in p:
                continue
            if all(a in p for a in g.get("after", [])):
                nxt.append(p | set(g["members"]))
        for q in nxt:
            q = frozenset(q)
            if q not in seen:
                seen.add(q)
                todo.append(q)
    return seen


def watches(s, a, b):
    return a in s["checkers"].get(b, []) and a in s["hb_readers"].get(b, [])


def reach_fwd(s, src, allowed):
    """Monitors reached from src along report edges through `allowed` (src included)."""
    seen = {src}
    todo = [src]
    while todo:
        x = todo.pop()
        for y in s["fwd"].get(x, []):
            if y in allowed and y not in seen:
                seen.add(y)
                todo.append(y)
    return seen


def rand_edges(s, mons, works, p):
    for a in mons:
        for b in mons:
            if a != b:
                if random.random() < p:
                    add(s, "checkers", b, a)
                if random.random() < p:
                    add(s, "hb_readers", b, a)
                if random.random() < p:
                    add(s, "fwd", a, b)
    for w in works:
        for a in mons:
            if random.random() < p:
                add(s, "checkers", w, a)
            if random.random() < max(p, 0.5):
                add(s, "halt_inputs", w, a)


# ---------------------------------------------------------------- Theorem L
def L_hyp_B(B, f):
    mons = B["monitors"]
    for w in B["works"]:
        hi = set(B["halt_inputs"].get(w, []))
        for m in mons:
            if not (reach_fwd(B, m, set(mons)) & hi):
                return False
    return Model(with_f(B, f)).complete_response_every_fault_round()


def gen_L(variant=None):
    f = random.choice((1, 1, 2, 2, 3))
    nb = random.choice((2, 3, 3, 4, 4))
    if nb <= f:
        nb = f + 1
    mons = ["M%d" % i for i in range(1, nb + 1)]
    works = ["W"] if random.random() < 0.7 else ["W", "V"]
    for _ in range(200):
        B = empty(mons, works, f=f)
        rand_edges(B, mons, works, random.choice((0.5, 0.7, 0.9, 1.0)))
        if L_hyp_B(B, f):
            break
    else:
        return None
    s = clone(B)
    nl = random.choice((1, 2, 2, 3)) if nb < 4 else random.choice((1, 2, 2))
    lates = ["N%d" % i for i in range(1, nl + 1)]
    need = {}
    for i, n in enumerate(lates):
        s["monitors"].append(n)
        s["boundary"][n] = "b_" + n
        lower = mons + lates[:i]
        c, r, t = (random.choice(lower) for _ in range(3))
        if random.random() < 0.4:
            r = t = c
        add(s, "checkers", n, c)
        add(s, "hb_readers", n, r)
        add(s, "fwd", n, t)
        need[n] = [x for x in (c, r, t) if x in lates]
        s.setdefault("_req", {})[n] = (c, r, t)
    # any other edges at the late monitors
    p = random.choice((0.0, 0.1, 0.3, 0.6))
    allm = mons + lates
    for n in lates:
        for x in allm:
            if x == n:
                continue
            for k in KINDS:
                if random.random() < p:
                    add(s, *edge(k, n, x))
        for w in works:
            if random.random() < p:
                add(s, "checkers", w, n)
            if random.random() < p:
                add(s, "halt_inputs", w, n)
    # groups: contiguous blocks in rank order
    groups = []
    i = 0
    while i < nl:
        k = random.choice((1, 1, 2))
        groups.append(lates[i:i + k])
        i += k
    s["late"] = []
    for gi, g in enumerate(groups):
        aft = set()
        for n in g:
            for x in need[n]:
                if x not in g:
                    aft.add(x)
        # extra, harmless: sometimes also wait for an earlier group
        s["late"].append(dict(name="g%d" % gi, members=list(g), after=sorted(aft)))
    s["arrive_bad"] = random.random() < 0.6
    req = s.pop("_req")
    if variant == "switch":
        s["switches"] = [random.choice(lates)]
    elif variant == "slow":
        n = random.choice(lates)
        c, r, t = req[n]
        e = random.choice((["checkers", n, c], ["hb_readers", n, r], ["fwd", n, t]))
        s["slow_edges"] = [e]
    elif variant == "slow_other":
        # a slow edge that is not one of the three required of any late monitor
        reqset = set()
        for n, (c, r, t) in req.items():
            reqset |= {("checkers", n, c), ("hb_readers", n, r), ("fwd", n, t)}
        cand = []
        for rel in ("checkers", "hb_readers", "fwd", "halt_inputs"):
            for k, lst in s[rel].items():
                for m in lst:
                    if (k in lates or m in lates) and (rel, k, m) not in reqset:
                        cand.append([rel, k, m])
        if not cand:
            return None
        s["slow_edges"] = random.sample(cand, min(len(cand), random.choice((1, 2, 3))))
    elif variant == "boundary":
        n = random.choice(lates)
        s["boundary"][n] = s["boundary"][random.choice([x for x in allm if x != n])]
    elif variant == "substrate":
        for n in lates:
            if random.random() < 0.7:
                s["substrate"][n] = "sx"
        if not s["substrate"]:
            s["substrate"][lates[0]] = "sx"
    return s


def test_L(variant=None):
    t0 = time.time()
    tried = fails = 0
    first = None
    while time.time() - t0 < budget:
        s = gen_L(variant)
        if s is None:
            continue
        tried += 1
        try:
            g = Model(s).gap(max_states=300000)
        except RuntimeError:
            tried -= 1
            continue
        if g:
            fails += 1
            if first is None:
                first = s
    print("Theorem L%s: systems meeting the stated hypotheses %d, with a gap %d" % (" [%s]" % variant if variant else "", tried, fails))
    if first is not None:
        show(first)
    return first


def show(s):
    m = Model(s)
    g1, g2, t1, t2 = m.solve(trace=True)
    print("   counterexample system:", {k: v for k, v in s.items() if k != "name"})
    print("   result G1 %s G2 %s; G1 trace %s; G2 trace %s" % (g1, g2, t1, t2))


# ---------------------------------------------------------------- Theorem J
def plain_join_system(dense=None, f=None, arrive=None):
    f = f or random.choice((1, 1, 2, 2, 3))
    n0 = random.choice((2, 3, 4))
    nl = random.choice((0, 1, 2, 2, 3))
    if n0 + nl > 6:
        nl = 6 - n0
    mons = ["M%d" % i for i in range(1, n0 + 1)]
    lates = ["N%d" % i for i in range(1, nl + 1)]
    works = ["W"] if random.random() < 0.7 else ["W", "V"]
    joiner = "J" if random.random() < 0.5 else None
    s = empty(mons + lates, works, f=f, joiner=joiner)
    return s, mons, lates, works, joiner


def J_hyp(s, f):
    members = set(x for g in s.get("late", []) for x in g["members"])
    init_m = [m for m in s["monitors"] if m not in members]
    if len(init_m) <= f:
        return False
    for P in reach_present_sets(s):
        pm = [m for m in s["monitors"] if m in P]
        # connected by pairs that watch each other and report to each other
        seen = {pm[0]}
        todo = [pm[0]]
        while todo:
            x = todo.pop()
            for y in pm:
                if y not in seen and watches(s, x, y) and watches(s, y, x) and y in s["fwd"].get(x, []) and x in s["fwd"].get(y, []):
                    seen.add(y)
                    todo.append(y)
        if len(seen) != len(pm):
            return False
        for w in list(s["works"]) + ([s["joiner"]] if s.get("joiner") else []):
            if w not in P:
                continue
            if not [c for c in s["checkers"].get(w, []) if c in P]:
                return False
            if len([h for h in s["halt_inputs"].get(w, []) if h in P]) <= f:
                return False
    return True


def gen_J():
    s, mons, lates, works, joiner = plain_join_system()
    f = s["f"]
    if len(mons) <= f:
        return None
    allm = mons + lates
    # a spanning tree of mutual links, each late monitor linked to an earlier one
    parent = {}
    for i, m in enumerate(allm):
        if i:
            p = random.choice(allm[:i])
            parent[m] = p
            mesh_pair(s, m, p)
    p = random.choice((0.0, 0.1, 0.3))
    for a in allm:
        for b in allm:
            if a != b:
                for k in KINDS:
                    if random.random() < p:
                        add(s, *edge(k, a, b))
    # groups
    s["late"] = []
    i = 0
    grp = {}
    while i < len(lates):
        k = random.choice((1, 1, 2))
        g = lates[i:i + k]
        for x in g:
            grp[x] = len(s["late"])
        s["late"].append(dict(name="g%d" % len(s["late"]), members=list(g), after=[]))
        i += k
    for g in s["late"]:
        aft = set()
        for n in g["members"]:
            if parent[n] in lates and parent[n] not in g["members"] and random.random() < 0.9:
                aft.add(parent[n])
        g["after"] = sorted(aft)
    # work
    for w in works + ([joiner] if joiner else []):
        pool = mons if (w != joiner or random.random() < 0.4) else allm
        for c in random.sample(pool, random.randint(1, len(pool))):
            add(s, "checkers", w, c)
        k = min(len(pool), f + random.choice((0, 1, 1, 2)))
        for h in random.sample(pool, k):
            add(s, "halt_inputs", w, h)
    if joiner:
        r = random.random()
        if r < 0.4 and s["late"]:
            random.choice(s["late"])["members"].append(joiner)
        elif r < 0.7 and s["late"]:
            # its own group, after everything it leans on
            need = sorted(set(x for x in s["checkers"].get(joiner, []) + s["halt_inputs"].get(joiner, []) if x in lates))
            s["late"].append(dict(name="gj", members=[joiner], after=need))
    s["arrive_bad"] = random.random() < 0.6
    return s


def test_generic(name, gen, hyp, conclusion_gap_expected=False):
    t0 = time.time()
    gen_n = tried = fails = 0
    first = None
    while time.time() - t0 < budget:
        s = gen()
        if s is None:
            continue
        gen_n += 1
        if not hyp(s):
            continue
        tried += 1
        try:
            g = Model(s).gap(max_states=300000)
        except RuntimeError:
            tried -= 1
            continue
        if g != conclusion_gap_expected:
            fails += 1
            if first is None:
                first = s
    print("%s: generated %d, meeting the hypotheses %d, conclusion fails in %d" % (name, gen_n, tried, fails))
    if first is not None:
        show(first)
    return first


# ---------------------------------------------------------------- Theorem F
def gen_F():
    f = random.choice((1, 2, 2, 3))
    n = random.choice((3, 4, 4, 5))
    if n <= f:
        n = f + 1
    mons = ["M%d" % i for i in range(1, n + 1)]
    works = ["W"] if random.random() < 0.6 else ["W", "V"]
    s = empty(mons, works, f=f)
    p = random.choice((0.5, 0.7, 0.85, 1.0))
    q = random.choice((0.0, 0.3, 0.6, 1.0))
    for a in mons:
        for b in mons:
            if a != b:
                if random.random() < p:
                    add(s, "checkers", b, a)
                if random.random() < p:
                    add(s, "hb_readers", b, a)
                if random.random() < q:
                    add(s, "fwd", a, b)
    for w in works:
        for a in random.sample(mons, random.randint(1, n)):
            add(s, "checkers", w, a)
        for a in random.sample(mons, random.randint(min(n, f + 1), n)):
            add(s, "halt_inputs", w, a)
    return s


def F_hyp(s):
    f = s["f"]
    mons = s["monitors"]
    for m in mons:
        if len([x for x in s["checkers"].get(m, []) if x != m]) < f:
            return False
        if len([x for x in s["hb_readers"].get(m, []) if x != m]) < f:
            return False
    for w in s["works"]:
        if not s["checkers"].get(w):
            return False
    for d in mons:
        others = [m for m in mons if m != d]
        for k in range(0, f + 1):
            for S in itertools.combinations(others, k):
                allowed = set(mons) - set(S)
                r = reach_fwd(s, d, allowed)
                for w in s["works"]:
                    if not (r & set(s["halt_inputs"].get(w, []))):
                        return False
    return True


# ---------------------------------------------------------------- Theorem S in every present set (f = 1)
def S_hyp_on(s, P):
    pm = [m for m in s["monitors"] if m in P]
    pw = [w for w in list(s["works"]) + ([s["joiner"]] if s.get("joiner") else []) if w in P]
    for z in pm:
        ws = [a for a in pm if a != z and watches(s, a, z)]
        if not ws:
            return False
        allowed = set(pm) - {z}
        reached = set()
        for a in ws:
            reached |= reach_fwd(s, a, allowed)
        for o in pm:
            if o != z and o not in ws and o not in reached:
                return False
    for w in pw:
        cs = [c for c in s["checkers"].get(w, []) if c in P]
        if not cs or len(set(h for h in s["halt_inputs"].get(w, []) if h in P)) < 2:
            return False
        if not any(reach_fwd(s, c, set(pm)) >= set(pm) for c in cs):
            return False
    return True


def S_hyp(s):
    return all(S_hyp_on(s, P) for P in reach_present_sets(s))


def gen_S():
    s, mons, lates, works, joiner = plain_join_system(f=1)
    s["f"] = 1
    allm = mons + lates
    p = random.choice((0.6, 0.8, 1.0))
    for a in allm:
        for b in allm:
            if a != b:
                if random.random() < p:
                    add(s, "checkers", b, a)
                    add(s, "hb_readers", b, a)
                elif random.random() < 0.3:
                    add(s, random.choice(("checkers", "hb_readers")), b, a)
                if random.random() < p:
                    add(s, "fwd", a, b)
    s["late"] = []
    i = 0
    while i < len(lates):
        k = random.choice((1, 1, 2))
        g = lates[i:i + k]
        aft = [x for x in lates[:i] if random.random() < 0.5]
        s["late"].append(dict(name="g%d" % len(s["late"]), members=list(g), after=aft))
        i += k
    for w in works + ([joiner] if joiner else []):
        pool = mons if (w != joiner or random.random() < 0.5) else allm
        for c in random.sample(pool, random.randint(1, len(pool))):
            add(s, "checkers", w, c)
        for h in random.sample(pool, random.randint(min(2, len(pool)), len(pool))):
            add(s, "halt_inputs", w, h)
    if joiner:
        r = random.random()
        if r < 0.4 and s["late"]:
            random.choice(s["late"])["members"].append(joiner)
        elif r < 0.7 and s["late"]:
            need = sorted(set(x for x in s["checkers"].get(joiner, []) + s["halt_inputs"].get(joiner, []) if x in lates))
            s["late"].append(dict(name="gj", members=[joiner], after=need))
    s["arrive_bad"] = random.random() < 0.6
    return s


# ---------------------------------------------------------------- A monitor nobody checks
def nobody_hyp(s):
    for P in reach_present_sets(s):
        for m in s["monitors"]:
            if m in P and not [c for c in s["checkers"].get(m, []) if c != m and c in P]:
                return True
    return False


def gen_nobody():
    s = gen_S()
    # thin out the checks so that the hypothesis is often met
    for k in list(s["checkers"].keys()):
        if k in s["monitors"] and random.random() < 0.5:
            s["checkers"][k] = [c for c in s["checkers"][k] if random.random() < 0.3]
    if random.random() < 0.3:
        m = random.choice(s["monitors"])
        add(s, "checkers", m, m)
    return s


def test_nobody():
    t0 = time.time()
    tried = fails = 0
    first = None
    while time.time() - t0 < budget:
        s = gen_nobody()
        if not nobody_hyp(s):
            continue
        tried += 1
        try:
            g = Model(s).gap(max_states=200000)
        except RuntimeError:
            tried -= 1
            continue
        if not g:
            fails += 1
            if first is None:
                first = s
    print("A monitor nobody checks (f = 1): systems meeting the hypothesis %d, with no gap %d" % (tried, fails))
    if first is not None:
        show(first)


# ---------------------------------------------------------------- Lemma M and Lemma N on arbitrary systems
def gen_any(window0=True):
    f = random.choice((1, 1, 2))
    n0 = random.choice((2, 3, 3, 4))
    nl = random.choice((0, 1, 1, 2))
    mons = ["M%d" % i for i in range(1, n0 + 1)]
    lates = ["N%d" % i for i in range(1, nl + 1)]
    works = ["W"] if random.random() < 0.6 else ["W", "V"]
    joiner = "J" if random.random() < 0.5 else None
    s = empty(mons + lates, works, f=f, joiner=joiner)
    allm = mons + lates
    p = random.choice((0.3, 0.5, 0.8))
    rand_edges(s, allm, works + ([joiner] if joiner else []), p)
    if random.random() < 0.3:
        m = random.choice(allm)
        add(s, random.choice(("checkers", "hb_readers", "fwd")), m, m)
    # boundaries, substrates, switches
    if random.random() < 0.3:
        a, b = random.sample(allm, 2)
        s["boundary"][a] = s["boundary"][b]
    if random.random() < 0.3:
        for x in random.sample(allm + works, 2):
            s["substrate"][x] = "s1"
    if random.random() < 0.2:
        s["switches"] = random.sample(allm, 1)
    s["coupling"] = random.random() < 0.8
    s["gate"] = random.random() < 0.8
    s["slow_reports"] = random.random() < 0.2
    s["window"] = 0 if window0 else random.choice((0, 1))
    s["late"] = []
    i = 0
    while i < len(lates):
        k = random.choice((1, 1, 2))
        g = lates[i:i + k]
        aft = [x for x in lates[:i] if random.random() < 0.5]
        s["late"].append(dict(name="g%d" % len(s["late"]), members=list(g), after=aft))
        i += k
    if joiner and s["late"] and random.random() < 0.5:
        random.choice(s["late"])["members"].append(joiner)
    s["arrive_bad"] = random.random() < 0.5
    # slow edges
    cand = []
    for rel in ("checkers", "hb_readers", "fwd", "halt_inputs"):
        for k, lst in s[rel].items():
            for m in lst:
                cand.append([rel, k, m])
    if cand and random.random() < 0.5:
        s["slow_edges"] = random.sample(cand, min(len(cand), random.randint(1, 4)))
    return s


def test_M():
    t0 = time.time()
    tried = fails = 0
    while time.time() - t0 < budget:
        s = gen_any()
        t = clone(s)
        allm = t["monitors"]
        nonm = t["works"] + ([t["joiner"]] if t["joiner"] else [])
        changed = False
        for _ in range(random.randint(1, 3)):
            r = random.random()
            if r < 0.25 and t.get("slow_edges"):
                t["slow_edges"].pop(random.randrange(len(t["slow_edges"])))
                changed = True
                continue
            rel = random.choice(("checkers", "hb_readers", "fwd", "halt_inputs"))
            if rel == "checkers":
                key = random.choice(allm + nonm)
            elif rel == "halt_inputs":
                key = random.choice(nonm)
            else:
                key = random.choice(allm)
            mon = random.choice(allm)
            if not has(t, rel, key, mon):
                add(t, rel, key, mon)
                changed = True
        if not changed:
            continue
        try:
            a = Model(s).solve(max_states=6000)
            b = Model(t).solve(max_states=6000)
        except RuntimeError:
            continue
        tried += 1
        if val(b[0]) < val(a[0]) or val(b[1]) < val(a[1]):
            fails += 1
            print("   LEMMA M FAILS", a, b, s, t)
    print("Lemma M: pairs tried %d, second worse than first in %d" % (tried, fails))


def test_N():
    t0 = time.time()
    tried = fails = 0
    while time.time() - t0 < budget:
        s = gen_any(window0=False)
        if not s.get("late"):
            continue
        gone = set(x for g in s["late"] for x in g["members"])
        t = clone(s)
        t["monitors"] = [m for m in t["monitors"] if m not in gone]
        if t["joiner"] in gone:
            t["joiner"] = None
        for rel in ("checkers", "hb_readers", "fwd", "halt_inputs"):
            t[rel] = {k: [m for m in lst if m not in gone] for k, lst in t[rel].items() if k not in gone}
        t["boundary"] = {k: v for k, v in t["boundary"].items() if k not in gone}
        t["substrate"] = {k: v for k, v in t["substrate"].items() if k not in gone}
        t["switches"] = [m for m in t["switches"] if m not in gone]
        t["late"] = []
        t["slow_edges"] = [e for e in t.get("slow_edges", []) if e[1] not in gone and e[2] not in gone]
        try:
            a = Model(s).solve(max_states=6000)
            b = Model(t).solve(max_states=6000)
        except RuntimeError:
            continue
        tried += 1
        if val(a[0]) > val(b[0]) or val(a[1]) > val(b[1]):
            fails += 1
            print("   LEMMA N FAILS", a, b, s, t)
    print("Lemma N: pairs tried %d, system with late processes better in %d" % (tried, fails))


# ---------------------------------------------------------------- section 9, slow reports, f = 1
def test_slow_reports():
    t0 = time.time()
    tried = fails = 0
    while time.time() - t0 < budget:
        f = 1
        n = random.choice((2, 3, 4, 5))
        mons = ["M%d" % i for i in range(1, n + 1)]
        works = ["W"] if random.random() < 0.6 else ["W", "V"]
        s = empty(mons, works, f=f)
        rand_edges(s, mons, works, random.choice((0.6, 0.8, 1.0)))
        if random.random() < 0.5:
            # make the necessary condition fail narrowly: drop the halt inputs that check one monitor
            z = random.choice(mons)
            w = random.choice(works)
            s["halt_inputs"][w] = [h for h in s["halt_inputs"].get(w, []) if h == z or h not in s["checkers"].get(z, [])]
        s["slow_reports"] = True
        cond = all(any(h != z and h in s["checkers"].get(z, []) for h in s["halt_inputs"].get(w, [])) for z in mons for w in works)
        if cond:
            continue
        tried += 1
        if not Model(s).gap(max_states=200000):
            fails += 1
            print("   SLOW-REPORTS STATEMENT FAILS", s)
    print("Section 9 slow reports (f = 1): plain systems that fail the stated necessary condition %d, with no gap %d" % (tried, fails))


tests = {
    "L": lambda: test_L(None),
    "Lswitch": lambda: test_L("switch"),
    "Lslow": lambda: test_L("slow"),
    "Lslowother": lambda: test_L("slow_other"),
    "Lboundary": lambda: test_L("boundary"),
    "Lsubstrate": lambda: test_L("substrate"),
    "J": lambda: test_generic("Theorem J", gen_J, lambda s: J_hyp(s, s["f"])),
    "F": lambda: test_generic("Theorem F", gen_F, F_hyp),
    "S": lambda: test_generic("Theorem S in every present set (f = 1)", gen_S, S_hyp),
    "nobody": test_nobody,
    "M": test_M,
    "N": test_N,
    "slowrep": test_slow_reports,
}
for k, fn in tests.items():
    if which is None or k in which:
        fn()
        sys.stdout.flush()
