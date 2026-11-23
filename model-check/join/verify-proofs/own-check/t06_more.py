# Further checks: section 5 least prompt sets, families of section 6.1, the counted table of section 9,
# Theorem S's conditions on the base rings, Theorem L's unstated hypotheses as round tables.
import itertools, sys, time
from sosmodel import Model, solve, with_f, fmt
from systems import *
from t04_sections_6_10 import grow, two_rings
from t03_theorems import S_hyp_on

parts = sys.argv[1].split(",") if len(sys.argv) > 1 else ["5", "fam", "count", "S", "L"]
t0 = time.time()

if "5" in parts:
    print("== Section 5: least sets of edges that must be in force in the join round (mesh base, N on M1,M2,M3, J with N) ==")
    ring = ("M1", "M2", "M3")
    E = [(k, x) for x in ring for k in KINDS]
    Nedges = [list(edge(k, "N", x)) for k, x in E]
    cJ = ["checkers", "J", "N"]
    hJ = {h: ["halt_inputs", "J", h] for h in ["N"] + list(ring)}
    ALLE = Nedges + [cJ] + list(hJ.values())

    def sysP(prompt, ab):
        s = base_ring("mesh", "all")
        s["monitors"].append("N"); s["boundary"]["N"] = "b_N"; s["joiner"] = "J"
        s["late"] = [dict(name="g", members=["N", "J"])]
        attach(s, "N", E)
        add(s, "checkers", "J", "N")
        for h in hJ:
            add(s, "halt_inputs", "J", h)
        s["arrive_bad"] = ab
        s["slow_edges"] = [e for e in ALLE if e not in prompt]
        return s

    def e_(k, x):
        return list(edge(k, "N", x))

    def fam(f):
        out = []
        if f == 1:
            for a in ring:
                for x in ring:
                    out.append([e_("XcN", a), hJ[x]])
        elif f == 2:
            for a in ring:
                for c in ring:
                    for x, y in itertools.combinations(ring, 2):
                        out.append([e_("XcN", a), cJ, e_("NpX", c), hJ[x], hJ[y]])
        else:
            for a in ring:
                for b in ring:
                    for c in ring:
                        out.append([e_("XcN", a), e_("XrN", b), cJ, e_("NpX", c)] + [hJ[x] for x in ring])
        return out

    def maxsets(f):
        out = []
        kinds = ["XcN"] if f == 1 else (["XcN", "NpX"] if f == 2 else ["XcN", "NpX", "XrN"])
        for k in kinds:
            gone = [e_(k, x) for x in ring]
            out.append(("no %s prompt" % k, [e for e in ALLE if e not in gone]))
        if f >= 2:
            out.append(("N's check of J slow", [e for e in ALLE if e != cJ]))
        keep_n = f - 1
        for keep in itertools.combinations(ring, keep_n):
            gone = [hJ[x] for x in ring if x not in keep]
            out.append(("only %s of J's halt inputs M1..M3 prompt (and N)" % (list(keep),), [e for e in ALLE if e not in gone]))
        return out
    for f in (1, 2, 3):
        fm = fam(f)
        ng = sum(1 for p in fm if not Model(with_f(sysP(p, True), f)).gap())
        print("  f=%d, N may arrive bad: listed least sets %d (each of %d edges), with no gap %d" % (f, len(fm), len(fm[0]), ng))
        for label, p in maxsets(f):
            print("     maximal set without a listed one: %-55s gap: %s" % (label, Model(with_f(sysP(p, True), f)).gap()))
        # N arriving good
        ng2 = sum(1 for p in fm if not Model(with_f(sysP(p, False), f)).gap())
        print("     (N arrives good: listed sets with no gap %d; nothing prompt at all: %s)" % (ng2, fmt(solve(with_f(sysP([], False), f)))))
        sys.stdout.flush()

if "fam" in parts:
    print("\n== Section 6.1 families (mesh of four; new monitors may arrive bad) ==")
    def family(kind, n, shape):
        mons = list(BASE)
        att = []
        for i in range(5, n + 1):
            nm = "N%d" % i
            if kind == "hub":
                abc = ("M1", "M2", "M3")
            elif kind == "chain":
                abc = tuple(mons[-3:])
            else:
                abc = ("K",) + tuple([m for m in mons if m != "K"][-2:])
            att.append((nm, shape, abc))
            mons.append(nm)
        return grow("mesh", att)
    for kind, n in (("hub", 8), ("hub", 11), ("chain", 8), ("chain", 12), ("chain", 16), ("fan", 8), ("fan", 12), ("fan", 16)):
        for shape in ("mesh", "cyc_checked", "cyc_read", "one"):
            s = family(kind, n, shape)
            r = [Model(with_f(s, f)).gap() for f in (1, 2, 3, 4)]
            print("  %-5s n=%-2d %-11s gap at f=1..4: %s  [%.0fs]" % (kind, n, shape, r, time.time() - t0))
            sys.stdout.flush()

if "fam20" in parts:
    def family(kind, n, shape):
        mons = list(BASE)
        att = []
        for i in range(5, n + 1):
            nm = "N%d" % i
            abc = tuple(mons[-3:]) if kind == "chain" else (("K",) + tuple([m for m in mons if m != "K"][-2:]))
            att.append((nm, shape, abc))
            mons.append(nm)
        return grow("mesh", att)
    for kind in ("chain", "fan"):
        for shape in ("mesh", "cyc_read"):
            s = family(kind, 20, shape)
            r = [Model(with_f(s, f)).gap() for f in (1, 2, 3, 4)]
            print("  %-5s n=20 %-11s gap at f=1..4: %s  [%.0fs]" % (kind, shape, r, time.time() - t0))
            sys.stdout.flush()

if "count" in parts:
    print("\n== Section 9 counted table ==")
    def count(kind, n, shape, first=0):
        s = base_ring("mesh", "all")
        mons = list(BASE)
        for i in range(5, n + 1):
            nm = "N%d" % i
            if kind == "hub":
                abc = ("M1", "M2", "M3")
            elif kind == "chain":
                abc = tuple(reversed(mons[-3:]))
            else:
                nk = [m for m in mons if m != "K"]
                abc = (nk[-1], nk[-2], "K")
            if shape == "one":
                abc = (abc[first],)
            s["monitors"].append(nm)
            attach(s, nm, shape_edges(shape, abc))
            mons.append(nm)
        deg = {m: 0 for m in mons}
        total = 0
        for rel in ("checkers", "hb_readers", "fwd"):
            for k, lst in s[rel].items():
                if k not in deg:
                    continue
                for m in lst:
                    deg[k] += 1
                    deg[m] += 1
                    total += 1
        return total, max(deg.values()), s, mons
    for shape in ("mesh", "cyc_read", "cyc_checked", "one", "sigcoord"):
        for kind in ("hub", "chain", "fan"):
            row = []
            for n in (8, 16, 32, 64):
                total, mx, s, mons = count(kind, n, shape)
                row.append((total, mx))
            print("  %-11s %-5s (edges in all, most at one monitor) for n=8,16,32,64: %s" % (shape, kind, row))
    # report hops from a checker of a monitor to a halt input of W, mesh shape
    for kind in ("hub", "chain", "fan"):
        row = []
        for n in (8, 16, 32, 64):
            total, mx, s, mons = count(kind, n, "mesh")
            # distance along report edges to the base four
            dist = {m: 0 for m in BASE}
            frontier = list(BASE)
            rev = {}
            for a, lst in s["fwd"].items():
                for b in lst:
                    rev.setdefault(b, []).append(a)
            while frontier:
                nx = []
                for b in frontier:
                    for a in rev.get(b, []):
                        if a not in dist:
                            dist[a] = dist[b] + 1
                            nx.append(a)
                frontier = nx
            worst = max(min(dist[c] for c in s["checkers"][m] if c != m) for m in mons)
            row.append(worst)
        print("  most report hops from the nearest checker of a monitor to a halt input of W, mesh shape, %-5s: %s" % (kind, row))

if "S" in parts:
    print("\n== Theorem S's conditions (a) to (d) on the eight base systems of section 2 ==")
    for sh in SHAPES:
        for wr in ("all", "two"):
            s = base_ring(sh, wr)
            print("  %-13s W reads %-3s: %s" % (sh, wr, S_hyp_on(s, set(s["monitors"]) | {"W"})))

if "L" in parts:
    print("\n== Theorem L with hypotheses the statement does not give ==")
    # (a) a required edge that is slow
    s = base_ring("mesh", "all")
    add_monitor(s, "N")
    attach(s, "N", shape_edges("one", ("M1",)))
    s["arrive_bad"] = True
    s["slow_edges"] = [["checkers", "N", "M1"]]
    print("  (a) N: M1 checks N (slow), M1 reads N, N reports to M1; f=1:", fmt(solve(with_f(s, 1))))
    for r in Model(with_f(s, 1)).replay([["join-bad N N"]]):
        print("     ", r)
    s["arrive_bad"] = False
    print("      the same, N arrives good: f=1: %s, f=2: %s" % (fmt(solve(with_f(s, 1))), fmt(solve(with_f(s, 2)))))
    for r in Model(with_f(s, 2)).replay([["join N", "mutate N"]]):
        print("     ", r)
    # (b) a late monitor with an off switch
    s = grow("mesh", [("N5", "one", ("M1",)), ("N6", "one", ("N5",))], arrive_bad=False)
    s["switches"] = ["N5"]
    print("  (b) N5 one watcher M1, N6 one watcher N5, N5 has an off switch; f=1:", fmt(solve(with_f(s, 1))))
    for r in Model(with_f(s, 1)).replay([["join N5"], ["join N6"], ["disable N5"], ["mutate N6"]]):
        print("     ", r)
