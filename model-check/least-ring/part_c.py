#!/usr/bin/env python3
"""Part C: the candidate ring repeated one level up (13 monitors), and once more (40).

Run:  python -B part_c.py SECTION ...     sections: one nested forced scoped scoped_rest
                                           reaches kinds flat forty conditions
"""
import copy
import importlib.util
import itertools
import os
import sys
import time

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(os.path.dirname(HERE), "join")
sys.path.insert(0, HERE)
sys.path.insert(0, ROOT)
sys.path.insert(0, os.path.dirname(HERE))
import mr_ring as R  # noqa: E402
import mr_model as mm  # noqa: E402
import mr_tower as T  # noqa: E402
from mr_show import show, brief, rows_text  # noqa: E402

READINGS = R.READINGS


def verify_model():
    spec = importlib.util.spec_from_file_location(
        "verify_model", os.path.join(ROOT, "verify-impl", "model.py"))
    vm = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(vm)
    return vm


def one():
    """C.1: the tower as one system."""
    import fast_join as fj
    vm = verify_model()
    print("== C.1 Thirteen monitors as one system (any detection halts everything)")
    for rb in (False, True):
        for reading in READINGS:
            for work in ("all", "two"):
                cells = []
                for f in (1, 2, 3, 4):
                    d = T.tower(2, reading, work, f, rb)
                    if f == 4 or (work == "two" and f >= 2):
                        # a gap: the search stops at the first round that violates either
                        # judgement, so only that round's violations are reported
                        r = mm.explore(d, stop="gap")
                        cells.append(f"f={f}: first violation in round "
                                     f"{min(x for x in (r['G1'], r['G2']) if x)}"
                                     f" (G1 {r['G1']}, G2 {r['G2']} in that round)")
                        continue
                    r = mm.explore(d, stop="both")
                    a = fj.explore(d, stop_early=True)
                    g1, g2, _, complete = vm.Model(d).solve()
                    agree = (a["G1"], a["G2"]) == (r["G1"], r["G2"]) == (g1, g2) and complete
                    cells.append(f"f={f}: G1 {r['G1']}, G2 {r['G2']}"
                                 + (" (3 agree)" if agree else "  DISAGREE"))
                print(f"{reading}, work reads {work}, "
                      f"{'each base ring in one boundary' if rb else 'own boundaries'}: "
                      + "; ".join(cells), flush=True)
    for reading in READINGS:
        d = T.tower(2, reading, "all", 4)
        show(d, ("G2", None), f"{reading}, work reads all, f=4: G2", stop="gap")
        d = T.tower(2, reading, "all", 4, True)
        show(d, ("G1", None), f"{reading}, work reads all, each base ring in one boundary, f=4: G1",
             stop="gap")
        d = T.tower(2, reading, "two", 2)
        show(d, ("G2", None), f"{reading}, work reads two, f=2: G2", stop="gap")
    d = T.tower(2, "flow", "all", 1, True)
    print("\n-- flow, each base ring in one boundary, f=1: the loss of ring 1, then a fault")
    print(rows_text(d, [[("stop-boundary", "ring 1")]]))


def nested():
    print("\n== C.1 `nested` of check_model.py (two base rings, an upper ring of three)")
    import check_model as cm
    for rb in (False, True):
        cells = []
        for f in (1, 2):
            s = cm.nested(3, True, f, rb)
            first, states = cm.explore(s)
            d = {k: copy.deepcopy(getattr(s, k)) for k in
                 ("name", "f", "monitors", "works", "joiner", "boundary", "substrate",
                  "hb_readers", "checkers", "fwd", "halt_inputs", "switches", "coupling",
                  "window", "gate", "slow_reports")}
            r = mm.explore(d, stop="both")
            g = lambda x: len(x) if x else None
            ok = (g(first["G1"]), g(first["G2"])) == (r["G1"], r["G2"])
            cells.append(f"f={f}: G1 {r['G1']}, G2 {r['G2']}" + ("" if ok else " DISAGREE"))
        print(f"nested, {'each base ring in one boundary' if rb else 'own boundaries'}: "
              + "; ".join(cells) + "   (check_model.py's own search agrees)")


def forced():
    print("\n== C.1/C.2 Which connections of the tower anything depends on")
    print("== one connection removed; as one system at f = 1, 2, 3 (the first violating round:")
    print("== G1/G2 in that round), and with scopes")
    print("== at f = 1 (least rounds for G1, G2, told over the scopes; frozen)")
    conns = T.connections(2)
    kinds = [("a base ring's cycle arrow", ("A1", "B1")),
             ("a base member's upward arrow", ("A1", "D1")),
             ("a base coordinator's downward arrow", ("D1", "A1")),
             ("the upper ring's cycle arrow", ("D1", "D2")),
             ("a ring coordinator's upward arrow to T", ("D1", "T")),
             ("T's downward arrow to a ring coordinator", ("T", "D1"))]
    for reading in READINGS:
        for label, drop in kinds:
            c2 = [c for c in conns if c != drop]
            E = R.edges_of(c2, reading)
            cells = []
            for f in (1, 2, 3):
                r = mm.explore(T.tower(2, reading, "all", f, edges=E), stop="gap")
                cells.append(f"f={f}: {r['G1']}/{r['G2']}")
            d = T.tower(2, reading, "all", 1, edges=E, scoped=True)
            d["freeze"] = True
            r = mm.explore(d)
            print(f"{reading}, without {drop[0]}->{drop[1]} ({label}): one system "
                  + ", ".join(cells) + f"; scoped f=1: G1 {r['G1']}, G2 {r['G2']}, "
                  f"told {r['told']}, spill {r['spill']}", flush=True)
            if r["G2"] is not None:
                key = next(k for k in r["traces"] if k[0] == "G2")
                print(rows_text(d, r["traces"][key]))
        # all three upper cycle arrows removed: the upper ring a star
        c2 = [c for c in conns if not (c[0] in ("D1", "D2", "D3") and c[1] in ("D1", "D2", "D3"))]
        E = R.edges_of(c2, reading)
        cells = []
        for f in (1, 2, 3):
            r = mm.explore(T.tower(2, reading, "all", f, edges=E), stop="gap")
            cells.append(f"f={f}: {r['G1']}/{r['G2']}")
        d = T.tower(2, reading, "all", 1, edges=E, scoped=True)
        d["freeze"] = True
        r = mm.explore(d)
        print(f"{reading}, without the upper ring's three cycle arrows ({len(c2)} connections): "
              f"one system " + ", ".join(cells) + f"; scoped f=1: G1 {r['G1']}, G2 {r['G2']}, "
              f"told {r['told']}, spill {r['spill']}")
        d = T.tower(2, reading, "all", 2, edges=E, scoped=True)
        d["freeze"] = True
        canon, _ = T.canon_for(d, 2, "all")
        r = mm.explore(d, canon=canon)
        print(f"     scoped f=2: {brief(r)}")


def scoped():
    print("\n== C.2 Thirteen monitors with a scope per ring")
    for reading in READINGS:
        for work in ("all", "two"):
            for label, freeze, plan in (
                    ("faults in a closed scope left out (freeze)", True,
                     {1: None, 2: None, 3: 2}),
                    ("faults in a closed scope allowed", False, {1: 6, 2: 2, 3: 1})):
                for f in (1, 2, 3):
                    if work == "two" and f > 2:
                        continue
                    d = T.tower(2, reading, work, f, scoped=True)
                    d["freeze"] = freeze
                    canon, size = T.canon_for(d, 2, work)
                    t0 = time.time()
                    rounds = plan[f]
                    if work == "two":       # fewer symmetries, and a gap at f = 2
                        rounds = {1: None if freeze else 4, 2: 2}[f]
                    r = mm.explore(d, canon=canon, max_rounds=rounds)
                    bound = (f"every execution of at most {rounds} rounds" if r["bounded"]
                             else "every reachable state")
                    print(f"{reading}, work reads {work}, {label}, f={f}: {brief(r)}; {bound}"
                          f"   [{time.time() - t0:.0f} s]", flush=True)


def scoped_rest():
    # the executions are found without the symmetry reduction, so that they can be replayed
    print("\n-- the shortest executions (work reads all, freeze)")
    for reading in READINGS:
        for f, rounds in ((2, 2), (3, 1)):
            d = T.tower(2, reading, "all", f, scoped=True)
            d["freeze"] = True
            r = mm.explore(d, max_rounds=rounds)
            for kind in ("G1", "told"):
                ks = sorted((k for k in r["traces"] if k[0] == kind), key=lambda k: str(k[1]))
                if ks:
                    show(d, ks[0], f"{reading}, f={f}: {kind} of {ks[0][1]}", r=r)
    d = T.tower(2, "flow", "two", 2, scoped=True)
    d["freeze"] = True
    r = mm.explore(d, max_rounds=1)
    show(d, ("G2", "ring 1"), "work reads two, f=2: G2 of ring 1", r=r)
    d = T.tower(2, "flow", "all", 4, scoped=True)
    d["freeze"] = True
    r = mm.explore(d, max_rounds=1)
    show(d, ("G2", "ring 1"), "work reads all, f=4: G2 of ring 1", r=r)

    print("\n== C.2 The other choice: a ring coordinator's own fault lands in the scope above")
    for reading in READINGS:
        for f in (1, 2):
            d = T.tower(2, reading, "all", f, scoped=True, coordinator_scope="upper")
            d["freeze"] = True
            canon, _ = T.canon_for(d, 2, "all")
            r = mm.explore(d, canon=canon)
            print(f"{reading}, work reads all, freeze, f={f}: {brief(r)}", flush=True)

    print("\n== C.2 With each base ring whole in one boundary (scoped, freeze)")
    for reading in READINGS:
        for f in (1, 2):
            d = T.tower(2, reading, "all", f, True, scoped=True)
            d["freeze"] = True
            canon, _ = T.canon_for(d, 2, "all")
            r = mm.explore(d, canon=canon, max_rounds=None if f == 1 else 3)
            print(f"{reading}, work reads all, f={f}: {brief(r)}", flush=True)


def reaches():
    print("\n== C.2 What reaches the upper ring")
    for reading in READINGS:
        d = T.tower(2, reading, "all", 1, scoped=True)
        print(f"\n-- {reading}: a member of ring 1 goes bad")
        print(rows_text(d, [[("mutate", "A1")]]))
        print(f"-- {reading}: the work of ring 1 goes bad")
        print(rows_text(d, [[("mutate", "W1")]]))
        print(f"-- {reading}: the coordinator of ring 1 goes bad")
        print(rows_text(d, [[("mutate", "D1")]]))
        print(f"-- {reading}: the coordinator of ring 1 stops")
        print(rows_text(d, [[("stop", "D1")]]))
        print(f"-- {reading}: the top coordinator goes bad")
        print(rows_text(d, [[("mutate", "T")]]))
        print(f"-- {reading}: a fault in ring 1, then one in ring 2")
        print(rows_text(d, [[("mutate", "A1")], [("mutate", "B2")]]))
        print(f"-- {reading}, as one system: a member of ring 1 goes bad")
        print(rows_text(T.tower(2, reading, "all", 1), [[("mutate", "A1")]]))


def least19(reading, members, coord):
    """The 19 edges of part-a section 3.3 on one ring's arrows: the cycle's watching, the
    coordinator watching every member, every member reporting to it, and the first two
    members watching it."""
    E = set()
    k = len(members)
    for i, m in enumerate(members):
        a, b = m, members[(i + 1) % k]
        for kind in ("hb_readers", "checkers"):
            E.add((kind, a, b) if reading == "flow" else (kind, b, a))
            E.add((kind, m, coord))
        E.add(("fwd", m, coord))
    for m in members[:2]:
        for kind in ("hb_readers", "checkers"):
            E.add((kind, coord, m))
    return E


def kinds():
    print("\n== C.2/C.3 Kind by kind in the tower: which of the edges that one ring does")
    print("== not need are needed one level up")
    rings, base = T.layout(2)
    for reading in READINGS:
        full = R.edges_of(T.connections(2), reading)
        core = set()
        for lv, ms, c in rings:
            core |= least19(reading, ms, c)
        core = frozenset(core)
        spare = full - core
        print(f"\n-- {reading}: each ring carrying its 19 edges ({len(core)} in all); "
              f"{len(spare)} spare edges on the arrows")

        def one_system(x, f=1):
            r = mm.explore(T.tower(2, reading, "all", f, edges=core | x), stop="gap")
            return r["G1"] is None and r["G2"] is None

        def scoped_ok(x, f=1, told=True):
            d = T.tower(2, reading, "all", f, edges=core | x, scoped=True)
            d["freeze"] = True
            r = mm.explore(d, stop="any" if told else "gap")
            return (r["G1"] is None and r["G2"] is None
                    and (not told or (r["told"] is None and r["spill"] is None)))

        for label, good in (("as one system, f=1", lambda x: one_system(x, 1)),
                            ("as one system, f=2", lambda x: one_system(x, 2)),
                            ("as one system, f=3", lambda x: one_system(x, 3)),
                            ("with scopes, f=1: G1, G2, told, no spill", lambda x: scoped_ok(x)),
                            ("with scopes, f=1: G1 and G2 only",
                             lambda x: scoped_ok(x, told=False))):
            t0 = time.time()
            k, sets, clauses, tests = R.least_cardinality(spare, good)
            print(f"{label}: the 19 per ring alone are enough: {good(frozenset())}; fewest "
                  f"spare edges to add: {k} ({len(sets)} ways, {tests} systems explored, "
                  f"{time.time() - t0:.0f} s)", flush=True)
            if k:
                always = frozenset.intersection(*sets)
                print("     in every such set: " + ("; ".join(sorted(R.edge_text(e) for e in always)) or "-"))
                for x in sets[:4]:
                    print("     e.g. " + "; ".join(sorted(R.edge_text(e) for e in x)))
        if not one_system(frozenset()):
            d = T.tower(2, reading, "all", 1, edges=core)
            show(d, ("G2", None), f"{reading}: the 19 per ring alone, as one system, f=1: G2",
                 stop="gap")


def flat():
    print("\n== C.3 Flat wirings of thirteen")
    rings, base = T.layout(2)
    mons = T.tower(2)["monitors"]
    others = [m for m in mons if m != "T"]

    def report(label, conns, reading):
        E = R.edges_of(conns, reading)
        wt = R.watchers(E, mons)
        r2 = all(len(wt[z]) >= 2 for z in mons)
        r3 = R.reached(wt, "T", mons) == set(mons)
        r5flat = all(("fwd", m, "T") in E for m in others)
        up = {}
        for lv, ms, c in rings:
            for m in ms:
                up[m] = c
        r5ring = all(("fwd", m, up[m]) in E for m in up)
        cells = []
        for work in ("all", "two"):
            for f in (1, 2, 3):
                r = mm.explore(T.tower(2, reading, work, f, edges=E), stop="gap")
                cells.append(f"{work} f={f}: {r['G1']}/{r['G2']}")
        print(f"{label} [{reading}]: {len(conns)} connections; R2 {r2}; R3 {r3}; R5 with one "
              f"coordinator {r5flat}; R5 ring by ring {r5ring}; R4 as a count True; R1 "
              f"(G1/G2): " + ", ".join(cells), flush=True)

    tower_conns = T.connections(2)
    cyc12 = [(others[i], others[(i + 1) % 12]) for i in range(12)]
    up12 = [(m, "T") for m in others]
    report("the tower", tower_conns, "flow")
    report("the tower", tower_conns, "actor")
    report("F1: twelve in a cycle, each -> T, T -> A1, B1", cyc12 + up12 + [("T", "A1"), ("T", "B1")], "flow")
    report("F1 read as actor", cyc12 + up12 + [("T", "A1"), ("T", "B1")], "actor")
    report("F2: twelve in a cycle under T both ways (the wide ring, k = 12)",
           cyc12 + up12 + [("T", m) for m in others], "actor")
    star = [c for c in tower_conns if not (c[0][0] == "D" and c[1][0] == "D")]
    report("F3: the tower without the upper ring's cycle", star, "actor")
    report("F3: the tower without the upper ring's cycle", star, "flow")
    # the tower with each ring at its least under flow (8 per ring: drop one downward arrow)
    lean = [c for c in tower_conns if c not in (("D1", "C1"), ("D2", "C2"), ("D3", "C3"), ("T", "D3"))]
    report("F4: the tower with each ring at eight (one downward arrow dropped per ring)", lean, "flow")
    d = T.tower(2, "flow", "all", 1, edges=R.edges_of(lean, "flow"), scoped=True)
    d["freeze"] = True
    print("   F4 with scopes, f=1 (freeze):", brief(mm.explore(d)))
    for label, conns, reading in (("F1", cyc12 + up12 + [("T", "A1"), ("T", "B1")], "flow"),):
        E = R.edges_of(conns, reading)
        for f in (2, 3):
            d = T.tower(2, reading, "all", f, edges=E)
            r = mm.explore(d, stop="gap")
            if r["G2"]:
                show(d, ("G2", None), f"{label}, work reads all, f={f}: G2", r=r)
                break


def forty():
    print("\n== C.4 One more level: forty monitors")
    for reading in READINGS:
        for work in ("all", "two"):
            cells = []
            for f in (1, 2, 3):
                if work == "two" and f > 2:
                    continue
                t0 = time.time()
                r = mm.explore(T.tower(3, reading, work, f), stop="gap", max_states=3000000)
                cells.append(f"f={f}: G1 {r['G1']}, G2 {r['G2']} ({r['states']} states"
                             + (", BOUNDED" if r["bounded"] else "") + f", {time.time() - t0:.0f} s)")
            print(f"as one system, {reading}, work reads {work}: " + "; ".join(cells), flush=True)
    for reading in READINGS:
        d = T.tower(3, reading, "all", 4)
        print(f"-- {reading}, forty monitors, f=4: the four monitors of one base ring")
        print(rows_text(d, [[("mutate", "A1"), ("mutate", "B1"), ("mutate", "C1"), ("mutate", "D1")]]))
    for reading in READINGS:
        r = mm.explore(T.tower(3, reading, "all", 1, True), stop="gap")
        print(f"as one system, {reading}, each base ring in one boundary, f=1: "
              f"G1 {r['G1']}, G2 {r['G2']}")
    for reading in READINGS:
        d = T.tower(3, reading, "all", 1, scoped=True)
        d["freeze"] = True
        t0 = time.time()
        r = mm.explore(d, max_rounds=3)
        print(f"with scopes, {reading}, work reads all, freeze, f=1, every execution of at "
              f"most 3 rounds: G1 {r['G1']}, G2 {r['G2']}, told {r['told']}, spill {r['spill']}"
              f" ({r['states']} states, {time.time() - t0:.0f} s)", flush=True)
        key = next((k for k in r["traces"] if k[0] == "told"), None)
        if key:
            show(d, key, f"{reading}, forty monitors, f=1: told of {key[1]}", r=r)
        d = T.tower(3, reading, "all", 2, scoped=True)
        d["freeze"] = True
        t0 = time.time()
        r = mm.explore(d, max_rounds=1)
        print(f"with scopes, {reading}, f=2, every execution of 1 round: G1 {r['G1']}, "
              f"G2 {r['G2']}, told {r['told']}, spill {r['spill']} ({time.time() - t0:.0f} s)",
              flush=True)


def conditions():
    print("\n== C.4 The conditions of Theorem S and of Theorem J on towers of 1 to 4 levels")
    import check_model as cm
    for levels in (1, 2, 3, 4):
        for reading in READINGS:
            for work in ("all", "two"):
                d = T.tower(levels, reading, work, 1)
                s = cm.System(d["name"], 1)
                for k, v in d.items():
                    setattr(s, k, v)
                suf = cm.sufficient_f1(s)
                # Theorem J: the monitors connected by pairs that watch and report to each other
                E = {(k, a, b) for k in R.KINDS for a, bs in d[k].items() for b in bs}
                mons = d["monitors"]
                mutual = {m: set() for m in mons}
                for a, b in itertools.combinations(mons, 2):
                    if all((k, x, y) in E for k in R.KINDS for x, y in ((a, b), (b, a))):
                        mutual[a].add(b)
                        mutual[b].add(a)
                seen, stack = {mons[0]}, [mons[0]]
                while stack:
                    for y in mutual[stack.pop()]:
                        if y not in seen:
                            seen.add(y)
                            stack.append(y)
                halts = min(len(d["halt_inputs"][w]) for w in d["works"])
                print(f"levels {levels} ({len(mons)} monitors), {reading}, work reads {work}: "
                      f"Theorem S (a)-(d): {suf}; connected by mutual pairs: "
                      f"{len(seen) == len(mons)}; fewest halt inputs {halts}")


if __name__ == "__main__":
    todo = sys.argv[1:] or ["one", "nested", "forced", "scoped", "scoped_rest", "reaches",
                            "kinds", "flat", "forty", "conditions"]
    for name in todo:
        globals()[name]()
