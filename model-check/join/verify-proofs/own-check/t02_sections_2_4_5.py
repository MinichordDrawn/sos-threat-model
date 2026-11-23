# Sections 2, 4 and 5 of the write-up: the Checked tables, recomputed.
import itertools, random, sys
from sosmodel import Model, solve, with_f, fmt
from systems import *

random.seed(7)


def res(s, fs=(1, 2, 3)):
    return ", ".join(fmt(solve(with_f(s, f))) for f in fs)


def rate(s, fmax=5):
    r = 0
    for f in range(1, fmax + 1):
        g = solve(with_f(s, f))
        if g[0] is None and g[1] is None:
            r = f
        else:
            break
    return r


print("== Section 2: base rings ==")
for sh in SHAPES:
    for wr in ("all", "two"):
        s = base_ring(sh, wr)
        r = rate(s)
        cr = [Model(with_f(s, f)).complete_response_every_fault_round() for f in range(1, r + 1)]
        # fewest checkers, readers, watchers
        fc = min(len([x for x in s["checkers"].get(m, []) if x != m]) for m in BASE)
        fr = min(len([x for x in s["hb_readers"].get(m, []) if x != m]) for m in BASE)
        fw = min(len([x for x in s["checkers"].get(m, []) if x != m and x in s["hb_readers"].get(m, [])]) for m in BASE)
        print("%-13s W reads %-3s rate %d  complete response at each f<=rate: %s  fewest c,r,w = %d,%d,%d   f=1..4: %s" % (sh, wr, r, cr, fc, fr, fw, res(s, (1, 2, 3, 4))))
m = Model(with_f(base_ring("cycle_signal", "all"), 3))
print("replay sec 2 table:", m.replay([["mutate M1", "mutate M2", "mutate M3"]]))


def with_N(shape, wreads, edges, arrive_bad, slow=None, J=None):
    s = base_ring(shape, wreads)
    add_monitor(s, "N")
    attach(s, "N", edges)
    s["arrive_bad"] = arrive_bad
    if slow:
        s["slow_edges"] = [list(edge(k, "N", x)) for k, x in slow]
    return s


print("\n== Section 4.1: one late monitor N, nothing depends on it (mesh, W reads all) ==")
ALL24 = [(k, x) for x in BASE for k in KINDS]
for k in KINDS:
    outs = set()
    for x in BASE:
        outs.add((res(with_N("mesh", "all", [(k, x)], False)), res(with_N("mesh", "all", [(k, x)], True))))
    print("only edge %s: good: %s | may arrive bad: %s   (same for all four X: %s)" % (k, *sorted(outs)[0], len(outs) == 1))
print("no edge: good:", res(with_N("mesh", "all", [], False)), "| bad:", res(with_N("mesh", "all", [], True)))
e20 = [(k, x) for (k, x) in ALL24 if k != "XcN"]
print("all but the four checks of N: good:", res(with_N("mesh", "all", e20, False)), "| bad:", res(with_N("mesh", "all", e20, True)))
print("all 24: good:", res(with_N("mesh", "all", ALL24, False)), "| bad:", res(with_N("mesh", "all", ALL24, True)))

print("\n-- 4.1 second table: all base rings; single check of N by each X; and the 20-edge attachment --")
for sh in SHAPES:
    for wr in ("all", "two"):
        line = []
        for ab in (False, True):
            single = set(res(with_N(sh, wr, [("XcN", x)], ab)) for x in BASE)
            line.append("check of N alone %s: %s" % ("bad" if ab else "good", sorted(single)))
            line.append("20 edges, no check of N: %s" % res(with_N(sh, wr, e20, ab)))
        print(sh, wr, " | ".join(line))

print("\n-- 4.1 random attachments against the rule 'no gap iff it holds a check of N and base has no gap' --")
bad_rule = 0
tried = 0
for sh in SHAPES:
    for wr in ("all", "two"):
        base_gap = {f: solve(with_f(base_ring(sh, wr), f)) != (None, None) for f in (1, 2, 3)}
        for ab in (False, True):
            for _ in range(25):
                es = [e for e in ALL24 if random.random() < random.choice((0.15, 0.5, 0.85))]
                s = with_N(sh, wr, es, ab)
                for f in (1, 2, 3):
                    gap = solve(with_f(s, f)) != (None, None)
                    want = base_gap[f] or not any(k == "XcN" for k, x in es)
                    tried += 1
                    if gap != want:
                        bad_rule += 1
                        print("DISAGREE", sh, wr, ab, f, es)
print("tried", tried, "disagreements", bad_rule)

print("\n-- 4.1 claimed attachment edge by edge: N in mesh with M1,M2,M3 (18 edges) --")
E18 = [(k, x) for x in ("M1", "M2", "M3") for k in KINDS]
full = (res(with_N("mesh", "all", E18, False)), res(with_N("mesh", "all", E18, True)))
print("full:", full)
chg = 0
for e in E18:
    r = (res(with_N("mesh", "all", [x for x in E18 if x != e], False)), res(with_N("mesh", "all", [x for x in E18 if x != e], True)))
    if r != full:
        chg += 1
        print("  removing", e, "changes:", r)
print("single removals that change a result:", chg)
for k in KINDS:
    es = [x for x in E18 if x[0] != k]
    print("  minus every", k, ":", res(with_N("mesh", "all", es, False)), "|", res(with_N("mesh", "all", es, True)))


# ---------------------------------------------------------------- 4.2
def with_NJ(shape, edges, arrive_bad, ring, slow=None, slowJ=None, jhalts=None, sep_after=False):
    """N joins with work process J in one step. Only N checks J. J halts on N and the three monitors of N's ring."""
    s = base_ring(shape, "all")
    s["monitors"].append("N")
    s["boundary"]["N"] = "b_N"
    s["joiner"] = "J"
    s["late"] = [dict(name="g", members=["N", "J"])]
    attach(s, "N", edges)
    add(s, "checkers", "J", "N")
    for h in (jhalts if jhalts is not None else ["N"] + list(ring)):
        add(s, "halt_inputs", "J", h)
    s["arrive_bad"] = arrive_bad
    sl = []
    if slow:
        sl += [list(edge(k, "N", x)) for k, x in slow]
    if slowJ:
        sl += [list(e) for e in slowJ]
    if sl:
        s["slow_edges"] = sl
    return s


print("\n== Section 4.2: J joins with N ==")
for sh, ring in (("mesh", ("M1", "M2", "M3")), ("cycle_check", ("M1", "M2", "K")), ("cycle_signal", ("M1", "M2", "K"))):
    print("base", sh, "N on", ring)
    E = [(k, x) for x in ring for k in KINDS]
    for ab in (False, True):
        print("  arrive_bad", ab)
        print("    mesh with its three:", res(with_NJ(sh, E, ab, ring)))
        rs = set(res(with_NJ(sh, [x for x in E if x != e], ab, ring)) for e in E)
        print("    minus any one edge:", sorted(rs))
        for k in KINDS:
            print("    minus every %s: %s" % (k, res(with_NJ(sh, [x for x in E if x[0] != k], ab, ring))))
        for shp in ("cyc_checked", "cyc_read"):
            rs = set(res(with_NJ(sh, shape_edges(shp, p), ab, ring)) for p in itertools.permutations(ring))
            print("    %s, six orders: %s" % (shp, sorted(rs)))
        print("    signal-reading coordinator:", res(with_NJ(sh, shape_edges("sigcoord", ring), ab, ring)))
        print("    one watcher (first of ring):", res(with_NJ(sh, shape_edges("one", ring), ab, ring)))

print("\n-- 4.2 replays (mesh, N on M1,M2,M3) --")
ring = ("M1", "M2", "M3")
E = [(k, x) for x in ring for k in KINDS]
s = with_f(with_NJ("mesh", [x for x in E if x[0] != "XrN"], False, ring), 1)
for r in Model(s).replay([["join g"], ["stop N"], ["mutate J"]]):
    print("  minus XrN:", r)
s = with_f(with_NJ("mesh", [x for x in E if x[0] != "NpX"], False, ring), 1)
for r in Model(s).replay([["join g"], ["mutate J"]]):
    print("  minus NpX:", r)
s = with_f(with_NJ("mesh", shape_edges("sigcoord", ring), False, ring), 3)
for r in Model(s).replay([["join g"], ["mutate M1", "mutate M2", "mutate M3"]]):
    print("  N checks no state, f=3:", r)

print("\n-- 4.2 least attachments over all 24 edges (mesh, N's ring M1,M2,M3) --")
for ab in (False, True):
    for f in (1, 2, 3):
        # the three-edge sets: one check of N, one read of N, one report from N
        bad3 = 0
        ok3 = 0
        for a in BASE:
            for b in BASE:
                for c in BASE:
                    es = [("XcN", a), ("XrN", b), ("NpX", c)]
                    g = solve(with_f(with_NJ("mesh", es, ab, ring), f))
                    if g == (None, None):
                        ok3 += 1
                    else:
                        bad3 += 1
        # maximal sets missing a whole kind
        mx = {}
        for k in ("XcN", "XrN", "NpX"):
            mx[k] = fmt(solve(with_f(with_NJ("mesh", [x for x in ALL24 if x[0] != k], ab, ring), f)))
        print("arrive_bad=%s f=%d: three-edge sets with no gap %d, with gap %d; 20-edge sets missing one kind: %s" % (ab, f, ok3, bad3, mx))
        if f == 3:
            ok4 = bad4 = 0
            for a in BASE:
                for b in BASE:
                    for c in BASE:
                        for extra in [("NcX", "M1"), ("NcX", "M2"), ("NcX", "M3"), ("XpN", "K")]:
                            es = [("XcN", a), ("XrN", b), ("NpX", c), extra]
                            g = solve(with_f(with_NJ("mesh", es, ab, ring), f))
                            if g == (None, None):
                                ok4 += 1
                            else:
                                bad4 += 1
            mx4 = [x for x in ALL24 if x not in (("NcX", "M1"), ("NcX", "M2"), ("NcX", "M3"), ("XpN", "K"))]
            print("   f=3 four-edge sets: no gap %d, gap %d; the 20-edge set missing N's checks of M1,M2,M3 and K's report to N: %s" % (ok4, bad4, fmt(solve(with_f(with_NJ("mesh", mx4, ab, ring), f)))))

print("\n== Section 4.3: N in a mesh with k monitors, J halts on N and those k ==")
for k in (1, 2, 3, 4):
    ringk = BASE[:k]
    Ek = [(kk, x) for x in ringk for kk in KINDS]
    for ab in (False, True):
        s = with_NJ("mesh", Ek, ab, ringk)
        print("k=%d arrive_bad=%s rate %d   f=1..4: %s" % (k, ab, rate(s), res(s, (1, 2, 3, 4))))
s = with_f(with_NJ("mesh", [(kk, "M1") for kk in KINDS], False, ["M1"]), 2)
for r in Model(s).replay([["join g"], ["mutate M1", "mutate N"]]):
    print("  k=1 f=2:", r)

# ---------------------------------------------------------------- 5
print("\n== Section 5: late edges; N in a mesh with M1,M2,M3; nothing depends on N ==")
for sh, ring in (("mesh", ("M1", "M2", "M3")), ("cycle_check", ("M1", "M2", "M3")), ("cycle_check", ("M1", "M2", "K"))):
    E = [(k, x) for x in ring for k in KINDS]
    print("base", sh, "ring", ring)
    rows = [
        ("all at once", E, []),
        ("all a round late", E, E),
        ("the three checks of N late", E, [x for x in E if x[0] == "XcN"]),
        ("one check of N at once, every other late", E, [x for x in E if x != ("XcN", ring[0])]),
        ("checks of N never", [x for x in E if x[0] != "XcN"], []),
    ]
    for k in KINDS:
        if k != "XcN":
            rows.append(("kind %s late alone" % k, E, [x for x in E if x[0] == k]))
    for label, es, slow in rows:
        print("  %-42s good: %-24s | may arrive bad: %s" % (label, res(with_N(sh, "all", es, False, slow)), res(with_N(sh, "all", es, True, slow))))

s = with_N("mesh", "all", E18, True, E18)
print("replay join-bad, all late, f=1:", Model(with_f(s, 1)).replay([["join-bad N N"]]))
s = with_N("mesh", "all", E18, False, E18)
print("replay join+mutate, all late, f=2:", Model(with_f(s, 2)).replay([["join N", "mutate N"]]))

print("\n-- Section 5, J joins with N (mesh base, N on M1,M2,M3) --")
ring = ("M1", "M2", "M3")
E = [(k, x) for x in ring for k in KINDS]
jh = [["halt_inputs", "J", h] for h in ["N"] + list(ring)]
rows = [
    ("the checks of N", [x for x in E if x[0] == "XcN"], None),
    ("the reads of N's signal", [x for x in E if x[0] == "XrN"], None),
    ("N's reports", [x for x in E if x[0] == "NpX"], None),
    ("N's check of J", [], [["checkers", "J", "N"]]),
    ("J's halt inputs", [], jh),
    ("N's checks of others", [x for x in E if x[0] == "NcX"], None),
    ("N's reads", [x for x in E if x[0] == "NrX"], None),
    ("reports to N", [x for x in E if x[0] == "XpN"], None),
]
for label, slow, slowJ in rows:
    print("  %-26s good: %-26s | may arrive bad: %s" % (label, res(with_NJ("mesh", E, False, ring, slow, slowJ)), res(with_NJ("mesh", E, True, ring, slow, slowJ))))
