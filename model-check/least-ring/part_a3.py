#!/usr/bin/env python3
"""Part A: second opinions and the comparisons that are outside the list.

1. G1 and G2 of every one of the 4,096 wirings, under both readings, both wirings of the
   work and the three rates, by two other implementations: fast_join.py (join\\) and
   model.py (verify-impl\\, written by another hand from the specification files).
2. The mesh against the candidate where reports take a round, and node loads.
3. The candidate's arrows labelled when naming after a loss is read at the wiring.
4. Round-by-round tables for the executions quoted in part-a.md.

Run:  python -B part_a3.py
"""
import importlib.util
import json
import os
import sys
import time

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(os.path.dirname(HERE), "join")
sys.path.insert(0, HERE)
sys.path.insert(0, ROOT)
import mr_ring as R  # noqa: E402
import mr_model as mm  # noqa: E402
import fast_join as fj  # noqa: E402

spec = importlib.util.spec_from_file_location("verify_model",
                                              os.path.join(ROOT, "verify-impl", "model.py"))
vm = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vm)

NODES = R.NODES4
PAIRS = R.all_pairs(NODES)


def conns_of(mask):
    return [p for i, p in enumerate(PAIRS) if (mask >> i) & 1]


def second_opinions():
    table = json.load(open(os.path.join(HERE, "part-a-connections.json"), encoding="utf-8"))
    print("== G1 and G2 by fast_join.py and by verify-impl model.py, against mr_model.py")
    for key, rows in table.items():
        reading, work = key.split("/")
        t0 = time.time()
        n = bad_f = bad_v = 0
        for mask in range(1 << 12):
            E = R.edges_of(conns_of(mask), reading)
            for f in (1, 2, 3):
                mine = tuple(rows[mask][f"raw@{f}"][:2])
                d = R.ring_system(E, NODES, "D", work, f, scoped=False)
                r = fj.explore(d, stop_early=True)
                g1, g2, _, complete = vm.Model(d).solve()
                assert complete
                n += 1
                bad_f += (r["G1"], r["G2"]) != mine
                bad_v += (g1, g2) != mine
        print(f"{key}: {n} systems; fast_join.py differs on {bad_f}; "
              f"verify-impl model.py differs on {bad_v}   [{time.time() - t0:.0f} s]", flush=True)


def slow_and_load():
    print("\n== Mesh against candidate where a report takes a round (outside the list)")
    for reading in R.READINGS:
        shapes = {"candidate": R.edges_of(R.CANDIDATE, reading),
                  "mesh": R.edges_of(R.mesh_ring(NODES), reading)}
        for work in ("all", "two"):
            for label, E in shapes.items():
                cells = []
                for f in (1, 2, 3):
                    d = R.ring_system(E, NODES, "D", work, f)
                    d["slow_reports"] = True
                    r = mm.explore(d)
                    cells.append(f"f={f}: G1 {r['G1']}, G2 {r['G2']}, told {r['told']}")
                print(f"{reading}, work reads {work}, {label}: " + "; ".join(cells))
    print("\n== Load: what each node does (edges at it, by kind)")
    for reading in R.READINGS:
        for label, conns in (("candidate", R.CANDIDATE), ("mesh", R.mesh_ring(NODES))):
            E = R.edges_of(conns, reading)
            for z in NODES:
                reads = sum(1 for k, a, b in E if k == "hb_readers" and b == z)
                checks = sum(1 for k, a, b in E if k == "checkers" and b == z)
                sends = sum(1 for k, a, b in E if k == "fwd" and a == z)
                hears = sum(1 for k, a, b in E if k == "fwd" and b == z)
                wt = len(R.watchers(E, NODES)[z])
                print(f"{reading} {label} {z}: reads {reads} signals, checks {checks} states, "
                      f"reports to {sends}, hears from {hears}; watched by {wt}")
            print(f"{reading} {label}: {len(conns)} connections, {len(E)} edges")


def label_after_loss():
    print("\n== The candidate's arrows when naming after a loss is read at the wiring (R4wl)")
    import part_a2 as P
    names = ["R1", "R2", "R3", "R4wl", "R5", "R6"]
    for rd in R.READINGS:
        Uc = R.edges_of(R.CANDIDATE, rd)
        for work in ("all", "two"):
            good = P.good_for(names, work, 1)
            k, sets, clauses, tests = R.least_cardinality(Uc, good, P.seeds_for(names, Uc))
            always = frozenset.intersection(*sets)
            print(f"arrows read as {rd}, work reads {work}, f=1: {k} of the 27 edges "
                  f"({len(sets)} ways); in every least set: {len(always)}")
            for x in sets[:2]:
                spare = sorted(R.edge_text(e) for e in Uc - x)
                print("     not needed: " + "; ".join(spare))
    for work in ("all", "two"):
        good = P.good_for(names, work, 1)
        k, sets, clauses, tests = R.least_cardinality(P.U, good, P.seeds_for(names, P.U))
        print(f"all 36 edges, work reads {work}, f=1, whole list with R4wl: {k} edges, "
              f"{len(sets)} sets")


def show(d, goal_key, title):
    r = mm.explore(d)
    sched = r["traces"].get(goal_key)
    print(f"\n-- {title}")
    if sched is None:
        print("   no such execution")
        return
    for i, row in enumerate(mm.replay(d, sched), 1):
        env = ", ".join(f"{k} {a}" for k, a in row["steps"]) or "(none)"
        broke = [g for g in ("G1", "G2", "told") if row[g]]
        print(f"   round {i}: env: {env} | bad: {' '.join(row['bad']) or '-'} | stopped: "
              f"{' '.join(row['stopped']) or '-'} | flagged: {' '.join(row['flagged_any']) or '-'}"
              f" | halted: {' '.join(row['halted']) or '-'} | worked: "
              f"{' '.join(row['worked']) or '-'}" + (f"  <-- breaks {', '.join(broke)}" if broke else ""))


def executions():
    print("\n== Executions quoted in part-a.md")
    for rd in R.READINGS:
        E = R.edges_of(R.CANDIDATE, rd)
        show(R.ring_system(E, NODES, "D", "two", 2), ("G2", "ring"),
             f"candidate, {rd}, work reads two, f=2: G2")
        show(R.ring_system(E, NODES, "D", "two", 2), ("G1", "ring"),
             f"candidate, {rd}, work reads two, f=2: G1")
    # R1 alone at the level of connections: four connections, one watcher each
    E = R.edges_of([("A", "B"), ("B", "A"), ("C", "A"), ("D", "A")], "actor")
    for f in (1, 2, 3):
        print("four connections A->B, B->A, C->A, D->A (actor), work all, f =", f,
              R.run(R.ring_system(E, NODES, "D", "all", f)))
    # the flow-reading least wiring at f = 3 that drops out
    E = R.edges_of([("A", "B"), ("A", "D"), ("B", "A"), ("B", "D"), ("C", "A"), ("C", "D"),
                    ("D", "A"), ("D", "B")], "flow")
    show(R.ring_system(E, NODES, "D", "all", 3), ("G1", "ring"),
         "flow, A->B A->D B->A B->D C->A C->D D->A D->B, work all, f=3: G1")
    show(R.ring_system(E, NODES, "D", "all", 3), ("G2", "ring"),
         "the same: G2")
    # told without R5: a wiring that meets R1 and not R6
    E = R.edges_of([("A", "B"), ("B", "A"), ("C", "A"), ("D", "A")], "actor")
    show(R.ring_system(E, NODES, "D", "all", 1), ("told", "ring"),
         "actor, A->B B->A C->A D->A, work all, f=1: the coordinator is not told")


if __name__ == "__main__":
    slow_and_load()
    label_after_loss()
    executions()
    second_opinions()
