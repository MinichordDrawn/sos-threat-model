#!/usr/bin/env python3
"""Part B: wider rings. k members in a cycle under one coordinator, k = 3, 4, 5, and the
meshes of four and five: rates, loads, and whether the cycle with a coordinator is still
least for the list.

Run:  python -B part_b.py
"""
import itertools
import os
import sys
import time

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import mr_ring as R  # noqa: E402
import mr_model as mm  # noqa: E402


def nodes_for(k):
    return [chr(ord("A") + i) for i in range(k)] + ["K"]


def evaluate(E, nodes, work, f):
    d = R.ring_system(E, nodes, "K", work, f)
    r = mm.explore(d)
    return r["G1"], r["G2"], r["told"]


def meets(E, nodes, work, f):
    if not (R.r2(E, nodes) and R.r3(E, nodes, "K") and R.r5(E, nodes, "K")):
        return False
    # a first pass that stops at the first gap; the full search only where there is none
    quick = mm.explore(R.ring_system(E, nodes, "K", work, f), stop="gap")
    if quick["G1"] is not None or quick["G2"] is not None:
        return False
    g1, g2, told = evaluate(E, nodes, work, f)
    return (g1 is None and g2 is None and told is None and R.r2(E, nodes)
            and R.r3(E, nodes, "K") and R.r5(E, nodes, "K"))


def rates():
    print("== Rates and loads")
    for label, k, shape in (("cycle of 3 + coordinator", 3, "cycle"),
                            ("cycle of 4 + coordinator", 4, "cycle"),
                            ("cycle of 5 + coordinator", 5, "cycle"),
                            ("mesh of 4", 3, "mesh"), ("mesh of 5", 4, "mesh"),
                            ("mesh of 6", 5, "mesh")):
        nodes = nodes_for(k)
        conns = R.cycle_ring(nodes[:-1], "K") if shape == "cycle" else R.mesh_ring(nodes)
        for reading in R.READINGS:
            E = R.edges_of(conns, reading)
            cells = []
            for work in ("all", "two"):
                res = []
                for f in range(1, len(nodes) + 1):
                    g1, g2, told = evaluate(E, nodes, work, f)
                    res.append((f, g1, g2, told))
                rate = 0
                for f, g1, g2, told in res:
                    if g1 is None and g2 is None:
                        rate = f
                    else:
                        break
                told_rate = 0
                for f, g1, g2, told in res:
                    if told is None and g2 is None:
                        told_rate = f
                    else:
                        break
                first_gap = next(((f, g1, g2) for f, g1, g2, told in res
                                  if g1 is not None or g2 is not None), None)
                cells.append(f"work reads {work}: rate {rate}, R6 to {told_rate}, "
                             f"first gap (f, G1, G2) {first_gap}")
            wt = R.watchers(E, nodes)
            load_m = sum(1 for z in nodes if nodes[0] in wt[z])
            load_k = sum(1 for z in nodes if "K" in wt[z])
            list_ok = [f for f in (1, 2, 3) if meets(E, nodes, "all", f)]
            print(f"{label}, {reading}: {len(conns)} connections, {len(E)} edges; a member "
                  f"watches {load_m} and is watched by {len(wt[nodes[0]])}; the coordinator "
                  f"watches {load_k} and is watched by {len(wt['K'])}; "
                  + "; ".join(cells) + f"; whole list met (work all) at f in {list_ok}",
                  flush=True)


def least(k, actor=True):
    """Every wiring with the fewest connections that R2 and R5 allow, tested against the
    whole list. The fewest is counted (see part-b in results-minimal.md): under flow
    2k + 2, under actor 3k."""
    nodes = nodes_for(k)
    members = nodes[:-1]
    up = [(m, "K") for m in members]
    cyc = R.canon_conns(R.cycle_ring(members, "K"), nodes, ("K",))
    print(f"\n== k = {k}: the least wirings for the whole list")
    # flow: each member one more arrow out (to a member), K two arrows out
    t0 = time.time()
    wir = []
    for extra in itertools.product(*[[y for y in members if y != x] for x in members]):
        for kout in itertools.combinations(members, 2):
            wir.append(up + [(x, y) for x, y in zip(members, extra)] + [("K", y) for y in kout])
    for work in ("all", "two"):
        for f in (1, 2, 3):
            good = [c for c in wir if meets(R.edges_of(c, "flow"), nodes, work, f)]
            fixed = ("K",) if work == "all" else (nodes[0], "K")
            shapes = {R.canon_conns(c, nodes, fixed) for c in good}
            print(f"flow, work reads {work}, f={f}: {len(wir)} wirings of {2 * k + 2} "
                  f"connections meet R2 and R5; {len(good)} meet the whole list "
                  f"({len(shapes)} shapes); the cycle with a coordinator has {3 * k}",
                  flush=True)
    # actor: each member two arrows in, from the other members or K
    if not actor:
        print(f"actor, k={k}: the {len(list(itertools.combinations(nodes[:-1], 2))) ** k} "
              f"wirings of {3 * k} connections are not listed here; see part_b2.py")
        return
    wir = []
    for ins in itertools.product(*[list(itertools.combinations(
            [y for y in nodes if y != x], 2)) for x in members]):
        wir.append(up + [(y, x) for x, pair in zip(members, ins) for y in pair])
    for work in ("all", "two"):
        for f in ((1, 2, 3) if k <= 4 else (1,)):
            good = [c for c in wir if meets(R.edges_of(c, "actor"), nodes, work, f)]
            fixed = ("K",) if work == "all" else (nodes[0], "K")
            shapes = {R.canon_conns(c, nodes, fixed) for c in good}
            print(f"actor, work reads {work}, f={f}: {len(wir)} wirings of {3 * k} "
                  f"connections meet R2 and R5; {len(good)} meet the whole list "
                  f"({len(shapes)} shapes); the cycle with a coordinator is one of them: "
                  f"{R.canon_conns(R.cycle_ring(members, 'K'), nodes, fixed) in shapes}",
                  flush=True)
    # kind by kind: R2's 4(k+1) watch edges and R5's k reports, on the cycle's arrows
    for reading in R.READINGS:
        E = set(("fwd", m, "K") for m in members)
        for i, m in enumerate(members):
            a, b = (m, members[(i + 1) % k])
            for kind in ("hb_readers", "checkers"):
                E.add((kind, a, b) if reading == "flow" else (kind, b, a))   # round the cycle
                E.add((kind, m, "K"))                                        # K watches m
        for m in members[:2]:
            for kind in ("hb_readers", "checkers"):
                E.add((kind, "K", m))                                        # two watch K
        E = frozenset(E)
        ok = {(work, f): meets(E, nodes, work, f) for work in ("all", "two") for f in (1, 2, 3)}
        print(f"kind by kind, {reading}: {len(E)} edges (5k + 4 = {5 * k + 4}) on the "
              f"cycle's arrows meet the whole list: {ok}")
    print(f"   [{time.time() - t0:.0f} s]")


if __name__ == "__main__":
    rates()
    least(3)
    least(4)
    least(5, actor=False)     # k = 5 under actor: part_b2.py (a sample; the full list is long)
