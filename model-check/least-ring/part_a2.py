#!/usr/bin/env python3
"""Part A, item 2: the three kinds of edge separate (36 possible edges among four nodes).

For each requirement and each combination: the fewest edges, and every set of that many
edges that meets it. The search is complete by Lemma M (mr_ring.least_cardinality says
how). Then the candidate's nine arrows are labelled: which kinds each must carry.

Run:  python -B part_a2.py [--quick]
"""
import itertools
import json
import os
import sys
import time

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import mr_ring as R  # noqa: E402

NODES = R.NODES4
U = frozenset(R.all_edges(NODES))
REQS = ["R1", "R2", "R3", "R4", "R5", "R6"]
MODEL = {}
TESTS = [0]


IDX = {e: i for i, e in enumerate(sorted(U))}


def model(x, work, f):
    key = (sum(1 << IDX[e] for e in x), work, f)
    if key not in MODEL:
        TESTS[0] += 1
        MODEL[key] = R.run(R.ring_system(x, NODES, "D", work, f))
        R.RESULTS.clear()
    return MODEL[key]


def req(name, work, f):
    if name == "R1":
        return lambda x: model(x, work, f)[0] is None and model(x, work, f)[1] is None
    if name == "R6":
        return lambda x: model(x, work, f)[1] is None and model(x, work, f)[2] is None
    if name == "R2":
        return lambda x: R.r2(x, NODES)
    if name == "R3":
        return lambda x: R.r3(x, NODES, "D")
    if name == "R3s":
        return lambda x: R.r3(x, NODES, "D", "signal")
    if name == "R4":
        return lambda x: True
    if name == "R4w":
        return lambda x: R.r4w(x, NODES)
    if name == "R4wl":
        return lambda x: R.r4w_after_loss(x, NODES)
    if name == "R5":
        return lambda x: R.r5(x, NODES, "D")
    raise ValueError(name)


def seeds_for(names, universe):
    """Clauses known beforehand (each is exact for its requirement; the search would find
    them anyway)."""
    out = []
    if "R2" in names:
        for z in NODES:
            others = [m for m in NODES if m != z]
            for u, v in itertools.combinations(others, 2):
                for ku in ("hb_readers", "checkers"):
                    for kv in ("hb_readers", "checkers"):
                        out.append(frozenset({(ku, z, u), (kv, z, v)}) & universe)
    if "R5" in names:
        for m in NODES:
            if m != "D":
                out.append(frozenset({("fwd", m, "D")}) & universe)
    return out


def good_for(names, work, f):
    # cheap tests first
    order = sorted(names, key=lambda n: n in ("R1", "R6"))
    fns = [req(n, work, f) for n in order]
    return lambda x: all(fn(x) for fn in fns)


def search(names, work, f, universe=U):
    good = good_for(names, work, f)
    return R.least_cardinality(universe, good, seeds_for(names, universe))


def fixed_for(work):
    return ("D",) if work == "all" else ("A", "D")


def describe(edges):
    """An edge set drawn pair by pair."""
    parts = []
    for z in NODES:
        hb = sorted(m for k, a, m in edges if k == "hb_readers" and a == z)
        ck = sorted(m for k, a, m in edges if k == "checkers" and a == z)
        fw = sorted(m for k, a, m in edges if k == "fwd" and a == z)
        both = [m for m in hb if m in ck]
        only_hb = [m for m in hb if m not in ck]
        only_ck = [m for m in ck if m not in hb]
        s = f"{z}: watched by {','.join(both) or '-'}"
        if only_hb:
            s += f"; signal read by {','.join(only_hb)}"
        if only_ck:
            s += f"; state checked by {','.join(only_ck)}"
        s += f"; reports to {','.join(fw) or '-'}"
        parts.append(s)
    return " | ".join(parts)


def main():
    quick = "--quick" in sys.argv
    out = {}
    subsets = [s for n in range(1, 7) for s in itertools.combinations(REQS, n)]
    cand = {rd: R.edges_of(R.CANDIDATE, rd) for rd in R.READINGS}

    print("== Kind by kind, 36 possible edges: fewest edges for each combination")
    for work in ("all", "two"):
        for f in (1, 2, 3):
            todo = subsets if f == 1 else [("R1",), ("R6",), ("R1", "R6"), tuple(REQS)]
            if quick:
                todo = [("R1",), ("R6",), tuple(REQS)]
            print(f"\n-- work reads {work}, f = {f}")
            print("combination              | fewest | sets | classes | the candidate's "
                  "edges (flow, actor) meet it | hold a least set (flow, actor)")
            seen = {}
            for s in todo:
                # R4 is a count and always holds for four nodes; R6 as defined holds G2
                eff = tuple(n for n in s if n != "R4")
                if not eff:
                    print(f"{'+'.join(s):24s} | 0      | 1    | 1       | yes, yes | yes, yes")
                    continue
                if eff not in seen:
                    t0 = time.time()
                    k, sets, clauses, tests = search(eff, work, f)
                    good = good_for(eff, work, f)
                    classes = sorted({R.canon_edges(x, NODES, fixed_for(work)) for x in sets})
                    seen[eff] = (k, sets, classes, len(clauses), tests,
                                 [good(cand[rd]) for rd in R.READINGS],
                                 [any(x <= cand[rd] for x in sets) for rd in R.READINGS],
                                 time.time() - t0)
                k, sets, classes, ncl, tests, meets, holds, dt = seen[eff]
                yn = lambda b: "yes" if b else "NO"
                if k is None:
                    print(f"{'+'.join(s):24s} | none: all 36 edges together do not meet it")
                    out[f"{work}/f{f}/{'+'.join(s)}"] = {"fewest": None}
                    continue
                print(f"{'+'.join(s):24s} | {k:6d} | {len(sets):4d} | {len(classes):7d} | "
                      f"{yn(meets[0])}, {yn(meets[1])} | {yn(holds[0])}, {yn(holds[1])}"
                      f"   [{ncl} clauses, {tests} tests, {dt:.0f} s]", flush=True)
                out[f"{work}/f{f}/{'+'.join(s)}"] = {
                    "fewest": k, "sets": len(sets), "classes": len(classes),
                    "candidate_meets": dict(zip(R.READINGS, meets)),
                    "candidate_holds_a_least_set": dict(zip(R.READINGS, holds)),
                    "examples": [describe(frozenset(c)) for c in classes[:6]]}
            k, sets, classes = seen[tuple(n for n in REQS if n != "R4")][:3]
            if k is None:
                continue
            print(f"   the whole list: {k} edges, {len(sets)} sets, {len(classes)} classes; "
                  f"the first classes:")
            for c in classes[:8]:
                print("     ", describe(frozenset(c)))

    print("\n== The whole list with the other choices")
    for work in ("all", "two"):
        for label, names in (("R3 with 'observes' = reads the signal",
                              ("R1", "R2", "R3s", "R5", "R6")),
                             ("naming read at the wiring (R4w)",
                              ("R1", "R2", "R3", "R4w", "R5", "R6")),
                             ("naming after a loss read at the wiring (R4wl)",
                              ("R1", "R2", "R3", "R4wl", "R5", "R6")),
                             ("R3 alone, observes = watches", ("R3",)),
                             ("R3 alone, observes = reads the signal", ("R3s",)),
                             ("R4w alone", ("R4w",)), ("R4wl alone", ("R4wl",))):
            k, sets, clauses, tests = search(names, work, 1)
            classes = sorted({R.canon_edges(x, NODES, fixed_for(work)) for x in sets})
            print(f"work {work}, f=1, {label}: {k} edges, {len(sets)} sets, {len(classes)} classes")
            out[f"{work}/f1/other/{label}"] = {"fewest": k, "sets": len(sets),
                                              "classes": len(classes)}
            for c in classes[:3]:
                print("     ", describe(frozenset(c)))

    print("\n== The candidate's nine arrows, labelled")
    names = ["R1", "R2", "R3", "R5", "R6"]
    for rd in R.READINGS:
        Uc = cand[rd]
        for work in ("all", "two"):
            for f in (1, 2, 3):
                good = good_for(names, work, f)
                if not good(Uc):
                    print(f"\n-- arrows read as {rd}, work reads {work}, f = {f}: the 27 "
                          f"edges do not meet the whole list")
                    continue
                k, sets, clauses, tests = R.least_cardinality(Uc, good, seeds_for(names, Uc))
                print(f"\n-- arrows read as {rd}, work reads {work}, f = {f}: of the 27 edges "
                      f"the arrows can carry, {k} are enough for the whole list "
                      f"({len(sets)} ways)")
                always = frozenset.intersection(*sets)
                ever = frozenset.union(*sets)
                single = {}
                for e in sorted(Uc):
                    x = Uc - {e}
                    lost = [n for n in names if not req(n, work, f)(x)]
                    single[e] = lost
                for a, b in R.CANDIDATE:
                    es = R.bundle(a, b, rd)
                    cells = []
                    for e in es:
                        if e in always:
                            tag = "in every least set"
                        elif e in ever:
                            tag = "in some least sets"
                        else:
                            tag = "in no least set"
                        if single[e]:
                            tag += f"; alone its removal fails {','.join(single[e])}"
                        cells.append(f"{R.edge_text(e)} [{tag}]")
                    print(f"   {a}->{b}: " + "; ".join(cells))
                # which requirement each edge of the least sets serves: remove it from a
                # least set and see what fails
                serves = {}
                for x in sets:
                    for e in x:
                        lost = tuple(n for n in names if not req(n, work, f)(x - {e}))
                        serves.setdefault(e, set()).add(lost)
                print("   in a least set, removing the edge fails:")
                for e in sorted(ever):
                    print(f"      {R.edge_text(e)}: "
                          + " or ".join("+".join(l) or "nothing" for l in sorted(serves[e])))
                out[f"label/{rd}/{work}/f{f}"] = {
                    "fewest": k, "ways": len(sets),
                    "in_every_least_set": sorted(R.edge_text(e) for e in always),
                    "in_some": sorted(R.edge_text(e) for e in ever - always),
                    "in_none": sorted(R.edge_text(e) for e in Uc - ever),
                    "serves": {R.edge_text(e): sorted("+".join(l) for l in v)
                               for e, v in serves.items()}}

    print(f"\n{TESTS[0]} systems explored")
    with open(os.path.join(HERE, "part-a-kinds-summary.json"), "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=1)


if __name__ == "__main__":
    main()
