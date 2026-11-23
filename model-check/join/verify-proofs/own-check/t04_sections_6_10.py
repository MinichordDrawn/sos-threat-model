# Sections 6 to 10 of the write-up: Checked tables and counterexample tables, recomputed.
import itertools, random, sys, time
from sosmodel import Model, solve, with_f, fmt
from systems import *

parts = sys.argv[1].split(",") if (len(sys.argv) > 1 and __name__ == "__main__") else ([] if __name__ != "__main__" else ["6a", "6b", "6c", "7", "8", "9", "10"])
random.seed(11)


def res(s, fs=(1, 2, 3)):
    return ", ".join(fmt(solve(with_f(s, f))) for f in fs)


def gap(s, f):
    return Model(with_f(s, f)).gap()


def rate(s, fmax=4):
    r = 0
    for f in range(1, fmax + 1):
        if gap(s, f):
            break
        r = f
    return r


def grow(base_shape, attachments, wreads="all", arrive_bad=True, ordered=True, late=True, whalts=None):
    """attachments: list of (name, shape, (a, b, c))."""
    s = base_ring(base_shape, wreads)
    latenames = [n for n, _, _ in attachments]
    for n, shp, abc in attachments:
        aft = [x for x in abc if x in latenames] if ordered else []
        add_monitor(s, n, group=None if late else False, after=aft)
        attach(s, n, shape_edges(shp, abc))
    s["arrive_bad"] = arrive_bad
    if whalts == "every":
        s["halt_inputs"]["W"] = list(s["monitors"])
    return s


def linked(links, a, b):
    return (a, b) in links or (b, a) in links


def way_one(n):
    """All labelled way-one systems with n monitors: list of tuples of triples."""
    out = []

    def rec(mons, links, triples):
        if len(mons) == n:
            out.append(tuple(triples))
            return
        new = "N%d" % (len(mons) + 1)
        for t in itertools.combinations(mons, 3):
            if all(linked(links, a, b) for a, b in itertools.combinations(t, 2)):
                rec(mons + [new], links | {(new, x) for x in t}, triples + [t])
    base_links = set(itertools.combinations(BASE, 2))
    rec(list(BASE), base_links, [])
    return out


def canon(triples):
    n = 4 + len(triples)
    late = ["N%d" % i for i in range(5, n + 1)]
    best = None
    for pb in itertools.permutations(BASE):
        for pl in itertools.permutations(late):
            mp = dict(zip(BASE, pb))
            mp.update(zip(late, pl))
            key = tuple(sorted((mp[nm], tuple(sorted(mp[x] for x in t))) for nm, t in zip(late, triples)))
            if best is None or key < best:
                best = key
    return best


def way_one_classes(n):
    seen = {}
    for t in way_one(n):
        c = canon(t)
        if c not in seen:
            seen[c] = t
    return list(seen.values())


def as_att(triples, shape="mesh"):
    return [("N%d" % (5 + i), shape, t) for i, t in enumerate(triples)]


if "6a" in parts:
    print("== Section 6.1: way one, mesh of four, mesh attachments, new monitors may arrive bad ==")
    t0 = time.time()
    classes = {}
    for n in (5, 6, 7, 8):
        classes[n] = way_one_classes(n)
        print("  n=%d: labelled %d, up to renaming %d" % (n, len(way_one(n)), len(classes[n])))
    sys.stdout.flush()
    for n in (5, 6, 7):
        rs = {}
        for t in classes[n]:
            r = rate(grow("mesh", as_att(t)))
            rs[r] = rs.get(r, 0) + 1
        print("  n=%d rates (rate: count): %s   [%.0fs]" % (n, rs, time.time() - t0))
        sys.stdout.flush()
    print("\n-- 6.2 any order (no after), n=5,6,7: rates, and which have a gap at f=1 --")
    for n in (5, 6, 7):
        rs = {}
        for t in classes[n]:
            r = rate(grow("mesh", as_att(t), ordered=False))
            rs[r] = rs.get(r, 0) + 1
        print("  n=%d rates: %s   [%.0fs]" % (n, rs, time.time() - t0))
        sys.stdout.flush()
    print("\n-- 6.3 every monitor present from the start, n=5,6,7 --")
    for n in (5, 6, 7):
        r4 = set()
        rall = set()
        for t in classes[n]:
            r4.add(rate(grow("mesh", as_att(t), late=False), fmax=n))
            rall.add(rate(grow("mesh", as_att(t), late=False, whalts="every"), fmax=n))
        print("  n=%d: W halts on base four: rates %s; on every monitor: rates %s   [%.0fs]" % (n, sorted(r4), sorted(rall), time.time() - t0))
        sys.stdout.flush()

if "6a8" in parts:
    t0 = time.time()
    cl = way_one_classes(8)
    rs = {}
    rs_any = {}
    slow = {}
    for i, t in enumerate(cl):
        r = rate(grow("mesh", as_att(t)))
        rs[r] = rs.get(r, 0) + 1
        ra = rate(grow("mesh", as_att(t), ordered=False))
        rs_any[ra] = rs_any.get(ra, 0) + 1
        if ra == 0:
            print("   any order, gap at f=1:", t)
        sys.stdout.flush()
    print("  n=8 (48 classes) ordered rates: %s; any order rates: %s  [%.0fs]" % (rs, rs_any, time.time() - t0))

if "6b" in parts:
    print("\n== Section 6.1: way two, five and six monitors, every shape, every base ring ==")
    t0 = time.time()
    shapes = ["mesh", "sigcoord", "cyc_checked", "cyc_read", "one"]
    for bs in SHAPES:
        want = rate(base_ring(bs, "all"))
        cnt = 0
        badc = 0
        for shp in shapes:
            trip = list(itertools.permutations(BASE, 3)) if shp.startswith("cyc") else (list(itertools.combinations(BASE, 3)) if shp != "one" else [(x,) for x in BASE])
            for abc in trip:
                s = grow(bs, [("N5", shp, abc)])
                r = rate(s)
                cnt += 1
                if r != want:
                    badc += 1
                    print("   DIFFERENT RATE", bs, shp, abc, r)
        print("  base %-13s five monitors: %d systems, base rate %d, with a different rate %d  [%.0fs]" % (bs, cnt, want, badc, time.time() - t0))
        sys.stdout.flush()
        # six monitors: a sample, mixed shapes
        cnt = badc = 0
        for _ in range(60):
            atts = []
            mons = list(BASE)
            for nm in ("N5", "N6"):
                shp = random.choice(shapes)
                abc = tuple(random.sample(mons, 1 if shp == "one" else 3))
                atts.append((nm, shp, abc))
                mons.append(nm)
            r = rate(grow(bs, atts))
            cnt += 1
            if r != want:
                badc += 1
                print("   DIFFERENT RATE", bs, atts, r)
        print("  base %-13s six monitors: %d sampled, with a different rate %d  [%.0fs]" % (bs, cnt, badc, time.time() - t0))
        sys.stdout.flush()
        cnt = badc = 0
        for _ in range(12):
            atts = []
            mons = list(BASE)
            for nm in ("N5", "N6", "N7"):
                shp = random.choice(shapes)
                abc = tuple(random.sample(mons, 1 if shp == "one" else 3))
                atts.append((nm, shp, abc))
                mons.append(nm)
            r = rate(grow(bs, atts))
            cnt += 1
            if r != want:
                badc += 1
                print("   DIFFERENT RATE", bs, atts, r)
        print("  base %-13s seven monitors: %d sampled, with a different rate %d  [%.0fs]" % (bs, cnt, badc, time.time() - t0))
        sys.stdout.flush()

if "6c" in parts:
    print("\n== Section 6.1 boundary counterexample, f=4, mesh of four grown to eight ==")
    att = [("N5", "mesh", ("M1", "M2", "M3")), ("N6", "mesh", ("N5", "M1", "M2")), ("N7", "mesh", ("N5", "N6", "M1")), ("N8", "mesh", ("N5", "N6", "N7"))]
    s = grow("mesh", att)
    print("  replay f=4:", Model(with_f(s, 4)).replay([["mutate M1", "mutate M2", "mutate M3", "mutate K"]]))
    print("  replay f=3:", Model(with_f(s, 3)).replay([["mutate M1", "mutate M2", "mutate M3"]]))
    s2 = grow("mesh", att, ordered=False)
    print("  any order, replay f=1:", Model(with_f(s2, 1)).replay([["join N8"], ["mutate N8"]]))
    print("  any order, results f=1..3:", res(s2))

    print("\n== Section 6.2: chain with one watcher each (N5 on M1, N6 on N5, N7 on N6), may arrive bad ==")
    att = [("N5", "one", ("M1",)), ("N6", "one", ("N5",)), ("N7", "one", ("N6",))]
    s = grow("mesh", att)
    print("  as built:", res(s))
    rows = [("N5 does not check N6's state", ("checkers", "N6", "N5")),
            ("N5 does not read N6's signal", ("hb_readers", "N6", "N5")),
            ("N6 does not report to N5", ("fwd", "N6", "N5")),
            ("N6 does not check N7's state", ("checkers", "N7", "N6")),
            ("N6 does not read N7's signal", ("hb_readers", "N7", "N6")),
            ("N7 does not report to N6", ("fwd", "N7", "N6"))]
    for label, e in rows:
        t = clone(s)
        assert rem(t, *e)
        t2 = clone(t)
        t2["arrive_bad"] = False
        print("  %-32s may arrive bad: %-22s | arrives good: %s" % (label, res(t), res(t2)))
    t = clone(s)
    rem(t, "hb_readers", "N6", "N5")
    for r in Model(with_f(t, 1)).replay([["join N5"], ["join N6"], ["stop N6"], ["join N7"], ["mutate N7"]]):
        print("   replay:", r)

if "7" in parts:
    print("\n== Section 7, table 1: mesh of four, N in a mesh with M1,M2,M3; f = 1..4; N may arrive bad ==")
    ring = ("M1", "M2", "M3")
    E = shape_edges("mesh", ring)

    def sysN():
        s = base_ring("mesh", "all")
        add_monitor(s, "N")
        attach(s, "N", E)
        s["arrive_bad"] = True
        return s
    fs = (1, 2, 3, 4)
    s = sysN(); print("  W as before:", res(s, fs))
    s = sysN(); add(s, "halt_inputs", "W", "N"); print("  N a fifth halt input of W:", res(s, fs))
    s = sysN(); add(s, "checkers", "W", "N"); print("  N a fifth checker of W:", res(s, fs))
    s = sysN(); add(s, "checkers", "W", "N"); add(s, "halt_inputs", "W", "N"); print("  both:", res(s, fs))
    s = sysN(); s["halt_inputs"]["W"] = ["M1", "M2", "N"]; print("  W halts on M1, M2 and N:", res(s, fs))
    s = sysN(); s["halt_inputs"]["W"] = ["M1", "N"]; print("  W halts on M1 and N:", res(s, fs))
    print("     replay:", Model(with_f(s, 1)).replay([["mutate M1"]]))
    s = sysN(); s["checkers"]["W"] = ["N"]; print("  W's only checker is N:", res(s, fs))

    def sysNJ(mode, chk=("N",), halts=("N", "M1", "M2", "M3")):
        s = base_ring("mesh", "all")
        s["monitors"].append("N"); s["boundary"]["N"] = "b_N"; s["joiner"] = "J"
        attach(s, "N", E)
        for c in chk:
            add(s, "checkers", "J", c)
        for h in halts:
            add(s, "halt_inputs", "J", h)
        if mode == "same":
            s["late"] = [dict(name="g", members=["N", "J"])]
        elif mode == "after":
            s["late"] = [dict(name="N", members=["N"]), dict(name="gj", members=["J"], after=["N"])]
        else:
            s["late"] = [dict(name="N", members=["N"])]   # J joins by its own step, at any time
        s["arrive_bad"] = True
        return s
    print("  J with N, same step:", res(sysNJ("same"), fs))
    print("  J by a step enabled once N is present:", res(sysNJ("after"), fs))
    s = sysNJ("any"); print("  J may join at any time:", res(s, fs))
    for r in Model(with_f(s, 1)).replay([["join"], ["mutate J"]]):
        print("     replay:", r)
    print("  J any time, checked by M1, halting on the base four:", res(sysNJ("any", ("M1",), BASE), fs))
    print("  the same with N a second checker and fifth halt input:", res(sysNJ("any", ("M1", "N"), BASE + ["N"]), fs))

if "7b" in parts:
    print("\n== Section 7, table 2: J on each new ring of the mesh of four grown to eight ==")
    t0 = time.time()
    fams = {"chain": [("M2", "M3", "K"), ("M3", "K", "N5"), ("K", "N5", "N6"), ("N5", "N6", "N7")],
            "hub": [("M1", "M2", "M3")] * 4}
    todo = sys.argv[2].split(",") if len(sys.argv) > 2 else ["mesh", "cyc_checked", "cyc_read", "sigcoord"]
    for fam, trips in fams.items():
        for shp in todo:
            rates = []
            for ringno in range(4):
                att = [("N%d" % (5 + i), shp, t) for i, t in enumerate(trips)]
                s = grow("mesh", att)
                nm = "N%d" % (5 + ringno)
                s["joiner"] = "J"
                for g in s["late"]:
                    if nm in g["members"]:
                        g["members"].append("J")
                add(s, "checkers", "J", nm)
                for h in (nm,) + tuple(trips[ringno]):
                    add(s, "halt_inputs", "J", h)
                rates.append(rate(s))
                print("   ", fam, shp, "ring", ringno + 1, "rate", rates[-1], "[%.0fs]" % (time.time() - t0))
                sys.stdout.flush()
            print("  %s %s: rates %s" % (fam, shp, rates))

# ---------------------------------------------------------------- 8
def two_rings(shape, kb_on, mode, kb_edges=None, arrive_bad=True, one_boundary=False, late=True):
    A = base_ring(shape, "all")
    s = clone(A)
    Bn = ["B1", "B2", "B3", "KB"]
    ren = dict(zip(BASE, Bn))
    ren["W"] = "WB"
    s["monitors"] += Bn
    for rel in ("checkers", "hb_readers", "fwd", "halt_inputs"):
        for k, lst in A[rel].items():
            s[rel][ren[k]] = [ren[m] for m in lst]
    for m in Bn:
        s["boundary"][m] = "b_" + m
    if one_boundary:
        for m in BASE:
            s["boundary"][m] = "bA"
        for m in Bn:
            s["boundary"][m] = "bB"
    if kb_edges is None:
        kb_edges = shape_edges("mesh", kb_on)
    attach(s, "KB", kb_edges)
    s["arrive_bad"] = arrive_bad
    if not late:
        s["works"].append("WB")
        return s
    s["joiner"] = "WB"
    mem = ["B1", "B2", "B3"]
    if mode == "one":
        s["late"] = [dict(name="gB", members=Bn + ["WB"])]
    elif mode == "four_then_wb":
        s["late"] = [dict(name="gB", members=list(Bn)), dict(name="gW", members=["WB"], after=list(Bn))]
    elif mode == "five_steps":
        s["late"] = [dict(name="KB", members=["KB"])] + [dict(name=m, members=[m], after=["KB"]) for m in mem] + [dict(name="gW", members=["WB"], after=list(Bn))]
    elif mode == "four_wb_any":
        s["late"] = [dict(name="gB", members=list(Bn))]          # WB joins by its own step at any time
    elif mode == "kb_then_any":
        s["late"] = [dict(name="KB", members=["KB"])] + [dict(name=m, members=[m], after=["KB"]) for m in mem] + [dict(name="gW", members=["WB"], after=["KB"])]
    elif mode == "all_any":
        s["late"] = [dict(name=m, members=[m]) for m in Bn]       # WB by its own step
    return s


if "8" in parts:
    print("\n== Section 8: ring B joins ring A ==")
    t0 = time.time()
    fs = (1, 2, 3, 4)
    for shape, kb_on in (("mesh", ("M1", "M2", "K")),):
        for mode in ("one", "four_then_wb", "five_steps", "four_wb_any", "kb_then_any", "all_any"):
            s = two_rings(shape, kb_on, mode)
            if mode in ("one", "four_then_wb", "five_steps"):
                out = "rate %d" % rate(s)
            else:
                out = "f=1: " + fmt(solve(with_f(s, 1)))
                if mode == "all_any":
                    t = clone(s); t["arrive_bad"] = False
                    out += "   (members arrive good: f=1: %s)" % fmt(solve(with_f(t, 1)))
            print("  %s KB on %s, %-13s %s  [%.0fs]" % (shape, kb_on, mode, out, time.time() - t0))
            sys.stdout.flush()
    s = two_rings("mesh", ("M1", "M2", "M3"), "all_any")
    for r in Model(with_f(s, 1)).replay([["join B1"], ["mutate B1"]]):
        print("   replay:", r)
    s = two_rings("mesh", ("M1", "M2", "M3"), "kb_then_any")
    for r in Model(with_f(s, 1)).replay([["join KB"], ["join gW"], ["mutate KB"]]):
        print("   replay:", r)
    s = two_rings("mesh", ("M1", "M2", "M3"), "one", kb_edges=[("XcN", "M1"), ("XrN", "M1"), ("NpX", "M1")])
    for r in Model(with_f(s, 1)).replay([["join gB"], ["mutate M1"]]):
        print("   replay:", r)

    print("\n-- 8: what KB must be attached by (ring B and WB join in one step; both rings meshes) --")
    three = [("XcN", "M1"), ("XrN", "M1"), ("NpX", "M1")]
    cases = [
        ("three edges with M1 only", three),
        ("six edges with M1 (mutual watch and reports)", [(k, "M1") for k in KINDS]),
        ("three + KB watches M1 + M1 reports to KB", three + [("NcX", "M1"), ("NrX", "M1"), ("XpN", "M1")]),
        ("three + KB watches M2 + M2 reports to KB", three + [("NcX", "M2"), ("NrX", "M2"), ("XpN", "M2")]),
        ("three + M1 reports to KB (4 edges)", three + [("XpN", "M1")]),
        ("three + M1, M2 report to KB (5 edges)", three + [("XpN", "M1"), ("XpN", "M2")]),
        ("three + M2, M3 report to KB (5 edges)", three + [("XpN", "M2"), ("XpN", "M3")]),
        ("three + M1, M2, M3 report to KB (6 edges)", three + [("XpN", "M1"), ("XpN", "M2"), ("XpN", "M3")]),
        ("three + all four of A report to KB (7 edges)", three + [("XpN", x) for x in BASE]),
        ("three + KB checks M1 + M1 reports to KB (5 edges)", three + [("NcX", "M1"), ("XpN", "M1")]),
        ("three + KB reads M1 + M1 reports to KB (5 edges)", three + [("NrX", "M1"), ("XpN", "M1")]),
    ]
    for label, es in cases:
        for ab in (True, False):
            s = two_rings("mesh", None, "one", kb_edges=es, arrive_bad=ab)
            print("  %-52s arrive_bad=%-5s f=1,2,3: %s  [%.0fs]" % (label, ab, res(s), time.time() - t0))
            sys.stdout.flush()

if "8b" in parts:
    print("\n-- 8: a whole ring lost in one step --")
    for shape in ("mesh",):
        s = two_rings(shape, ("M1", "M2", "M3"), None, one_boundary=True, late=False)
        print("  both present from the start, each ring in one boundary: f=1: %s, f=2: %s" % (fmt(solve(with_f(s, 1))), fmt(solve(with_f(s, 2)))))
        s = two_rings(shape, ("M1", "M2", "M3"), "one", one_boundary=True)
        print("  ring B joins in one step: f=1: %s" % fmt(solve(with_f(s, 1))))
        a = base_ring(shape, "all")
        for m in BASE:
            a["boundary"][m] = "bA"
        print("  ring A alone, whole in one boundary: f=1: %s" % fmt(solve(with_f(a, 1))))
    print("\n-- 8: other shapes for the first table --")
    t0 = time.time()
    for shape, kb_on in (("mesh", ("M1", "M2", "M3")), ("cycle_check", ("M1", "M2", "K")), ("cycle_check", ("M1", "M2", "M3"))):
        for mode in ("one", "four_then_wb", "five_steps", "four_wb_any", "kb_then_any", "all_any"):
            s = two_rings(shape, kb_on, mode)
            if mode in ("one", "four_then_wb", "five_steps"):
                out = "rate %d" % rate(s)
            else:
                out = "f=1: " + fmt(solve(with_f(s, 1)))
            print("  %s KB on %s, %-13s %s  [%.0fs]" % (shape, kb_on, mode, out, time.time() - t0))
            sys.stdout.flush()

if "9" in parts:
    print("\n== Section 9: slow reports, f = 1, way one ==")
    t0 = time.time()
    for n in (5, 6, 7, 8):
        cl = way_one_classes(n)
        g = 0
        which = []
        for t in cl:
            for ab in (True, False):
                s = grow("mesh", as_att(t), arrive_bad=ab)
                s["slow_reports"] = True
                if gap(s, 1):
                    g += 1
                    which.append((ab, t))
        print("  n=%d: %d classes; with a gap (counting each arrival mode): %d %s  [%.0fs]" % (n, len(cl), g, which, time.time() - t0))
        sys.stdout.flush()
    att = [("N5", "mesh", ("M1", "M2", "M3")), ("N6", "mesh", ("N5", "M1", "M2")), ("N7", "mesh", ("N5", "N6", "M1")), ("N8", "mesh", ("N5", "N6", "N7"))]
    s = grow("mesh", att)
    s["slow_reports"] = True
    print("  the one system, f=1:", fmt(solve(with_f(s, 1))))
    for r in Model(with_f(s, 1)).replay([["join N5"], ["join N6"], ["join N7"], ["join N8"], ["mutate N8"]]):
        print("   replay:", r)
    s2 = grow("mesh", att, whalts="every")
    s2["slow_reports"] = True
    print("  the same with W halting on all eight, f=1:", fmt(solve(with_f(s2, 1))))

if "10" in parts:
    print("\n== Section 10 ==")
    # ring of three, each watched by one other, reports to the one it does not check, W reads all three
    s = empty(["M1", "M2", "M3"], ["W"])
    watch(s, "M1", "M2"); watch(s, "M2", "M3"); watch(s, "M3", "M1")
    report(s, "M1", "M3"); report(s, "M2", "M1"); report(s, "M3", "M2")
    for wc in (["M1"], ["M1", "M2", "M3"]):
        t = clone(s)
        t["checkers"]["W"] = list(wc)
        t["halt_inputs"]["W"] = ["M1", "M2", "M3"]
        print("  ring of three, one watcher each, W checked by %s: f=1,2,3: %s" % (wc, res(t)))
    # row 1 and 2
    for halts in (["M1", "M2"], BASE):
        t = base_ring("cycle_check", "all")
        t["fwd"] = {}
        t["checkers"]["W"] = ["M1"]
        t["halt_inputs"]["W"] = list(halts)
        print("  cycle, checking coordinator, no reports, W checked by M1, halting on %s: %s" % (halts, res(t)))
        if len(halts) == 2:
            print("     replay:", Model(with_f(t, 1)).replay([["mutate M1"]]))
        else:
            t["slow_reports"] = True
            print("     the same with slow reports:", res(t))
            t2 = clone(t); t2["slow_reports"] = False; t2["checkers"]["W"] = list(BASE)
            print("     W checked by all four:", res(t2))
    # row 3
    for variant in ("M2 reads M1 too, members report to K and each other", "bare"):
        t = empty(["M1", "M2", "K"], ["W"])
        add(t, "checkers", "M1", "M2"); add(t, "checkers", "M2", "M1")
        add(t, "hb_readers", "M1", "K"); add(t, "hb_readers", "M2", "K")
        watch(t, "M1", "K"); watch(t, "M2", "K")
        if variant != "bare":
            add(t, "hb_readers", "M1", "M2"); add(t, "hb_readers", "M2", "M1")
            for a in ("M1", "M2", "K"):
                for b in ("M1", "M2", "K"):
                    if a != b:
                        report(t, a, b)
        for wc in (["M1", "M2"],):
            t["checkers"]["W"] = list(wc)
            t["halt_inputs"]["W"] = ["M1", "M2", "K"]
            print("  row 3 (%s): %s" % (variant, res(t)))
    print("     replay:", Model(with_f(t, 2)).replay([["mutate M1", "mutate M2"]]))
    # rows 4-6
    def two_meshes(pairs, halts):
        A = ["A1", "A2", "A3"]; B = ["B1", "B2", "B3"]
        t = empty(A + B, ["W"])
        for R in (A, B):
            for a, b in itertools.combinations(R, 2):
                mesh_pair(t, a, b)
        for i in pairs:
            report(t, "A%d" % i, "B%d" % i); report(t, "B%d" % i, "A%d" % i)
        t["checkers"]["W"] = list(A)
        t["halt_inputs"]["W"] = list(halts)
        return t
    A = ["A1", "A2", "A3"]; B = ["B1", "B2", "B3"]
    t = two_meshes((1, 2), A); print("  row 4:", res(t))
    print("     replay:", Model(with_f(t, 2)).replay([["stop B1", "mutate B2"]]))
    print("  row 5:", res(two_meshes((1, 2, 3), A)))
    print("  row 6:", res(two_meshes((1, 2), A + B)))
