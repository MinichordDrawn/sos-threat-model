#!/usr/bin/env python3
"""Part D: from one ring to three rings and a coordinator by joins, and the least
attachment of a fifth node.

Run:  python -B part_d.py SECTION ...     sections: grow steps fifth
"""
import copy
import itertools
import os
import sys
import time

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(os.path.dirname(HERE), "join")
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import mr_ring as R  # noqa: E402
import mr_model as mm  # noqa: E402
import mr_tower as T  # noqa: E402
from mr_show import brief, rows_text  # noqa: E402

RING = {i: [f"A{i}", f"B{i}", f"C{i}", f"D{i}"] for i in (1, 2, 3)}

ORDERS = {
    "author": "ring 2 (coordinator, then members in any order, then work), then ring 3 "
              "the same, then T",
    "author-loose": "as author, but ring 3 may start before ring 2 is complete",
    "top-first": "T, then ring 2 (coordinator, members, work), then ring 3",
    "top-first-loose": "T, then the two rings in any interleaving",
    "top-after-ring-2": "ring 2 complete, then T, then ring 3",
    "whole": "ring 2 whole in one step, ring 3 whole in one step, then T",
    "whole-top-first": "T, then ring 2 whole in one step, then ring 3 whole in one step",
}


def late_groups(order):
    g = []

    def ring(i, after_coord, whole=False):
        ms = RING[i][:3]
        d, w = f"D{i}", f"W{i}"
        if whole:
            g.append({"name": f"ring {i}", "members": ms + [d, w], "after": list(after_coord)})
            return
        g.append({"name": d, "members": [d], "after": list(after_coord)})
        for m in ms:
            g.append({"name": m, "members": [m], "after": [d]})
        g.append({"name": w, "members": [w], "after": ms + [d]})

    if order == "author":
        ring(2, [])
        ring(3, ["W2"])
        g.append({"name": "T", "members": ["T"], "after": ["W3"]})
    elif order == "author-loose":
        ring(2, [])
        ring(3, [])
        g.append({"name": "T", "members": ["T"], "after": ["W2", "W3"]})
    elif order == "top-first":
        g.append({"name": "T", "members": ["T"], "after": []})
        ring(2, ["T"])
        ring(3, ["W2"])
    elif order == "top-first-loose":
        g.append({"name": "T", "members": ["T"], "after": []})
        ring(2, ["T"])
        ring(3, ["T"])
    elif order == "top-after-ring-2":
        ring(2, [])
        g.append({"name": "T", "members": ["T"], "after": ["W2"]})
        ring(3, ["T"])
    elif order == "whole":
        ring(2, [], True)
        ring(3, ["W2"], True)
        g.append({"name": "T", "members": ["T"], "after": ["W3"]})
    elif order == "whole-top-first":
        g.append({"name": "T", "members": ["T"], "after": []})
        ring(2, ["T"], True)
        ring(3, ["W2"], True)
    else:
        raise ValueError(order)
    return g


def growing(reading, order, f, work="all", scoped=False, arrive_bad=True, freeze=True):
    d = T.tower(2, reading, work, f, scoped=scoped)
    d["late"] = late_groups(order)
    d["arrive_bad"] = arrive_bad
    d["name"] = f"growth, {order}, {reading}, work reads {work}"
    if scoped:
        d["freeze"] = freeze
    return d


def join_states(d):
    c = mm.Compiled(d)
    seen = {c.start}
    stack = [c.start]
    order = [c.start]
    while stack:
        p = stack.pop()
        for _, members, after, _ in c.groups:
            if members & ~p and not after & ~p:
                q = p | members
                if q not in seen:
                    seen.add(q)
                    stack.append(q)
                    order.append(q)
    return c, sorted(order, key=lambda m: (bin(m).count("1"), m))


def stage_name(present):
    """A short name for a set of present processes."""
    parts = []
    for i in (1, 2, 3):
        here = [p for p in RING[i] + [f"W{i}"] if p in present]
        if len(here) == 5:
            parts.append(f"ring {i}")
        elif here:
            parts.append(f"ring {i}: " + " ".join(here))
    if "T" in present:
        parts.append("T")
    return "; ".join(parts)


def grow():
    print("== Part D: growth by joins. Joins and faults in every order, a newcomer may")
    print("== arrive bad. As one system: the first round that violates G1 or G2, and what")
    print("== was present. With scopes: least rounds per judgement.")
    for order, words in ORDERS.items():
        print(f"\n-- order `{order}`: {words}")
        for reading in R.READINGS:
            for f in (1, 2, 3):
                d = growing(reading, order, f)
                t0 = time.time()
                r = mm.explore(d, stop="gap", max_states=2000000)
                if r["G1"] is None and r["G2"] is None:
                    print(f"{reading}, one system, f={f}: no gap ({r['states']} states"
                          + (", BOUNDED" if r["bounded"] else "") + f", {time.time() - t0:.0f} s)",
                          flush=True)
                else:
                    key = next(k for k in r["traces"] if k[0] in ("G1", "G2"))
                    rows = mm.replay(d, r["traces"][key])
                    which = [g for g in ("G1", "G2") if rows[-1][g]]
                    print(f"{reading}, one system, f={f}: {' and '.join(which)} broken in "
                          f"{len(rows)} round(s), with present: {stage_name(rows[-1]['present'])}",
                          flush=True)
                    if f == 1:
                        print(rows_text(d, r["traces"][key], indent="        "))
            for f in (1, 2):
                d = growing(reading, order, f, scoped=True)
                t0 = time.time()
                r = mm.explore(d, max_states=2500000, max_rounds=None if f == 1 else 3)
                note = ""
                if r["state_bounded"]:
                    note = " (BOUNDED by states: a None is not a result)"
                elif r["round_bounded"]:
                    note = " (every execution of at most 3 rounds)"
                print(f"{reading}, scoped (freeze), f={f}: {brief(r)}{note}"
                      f" [{time.time() - t0:.0f} s]", flush=True)
                if f == 1:
                    for kind in ("G1", "G2", "told"):
                        ks = sorted((k for k in r["traces"] if k[0] == kind),
                                    key=lambda k: len(r["traces"][k]))
                        if ks:
                            print(f"        shortest execution breaking {kind} of {ks[0][1]}:")
                            print(rows_text(d, r["traces"][ks[0]], indent="        "))


def steps():
    print("\n== Part D: which statements of results-join.md cover each step")
    import check_model as cm
    for order in ORDERS:
        for reading in R.READINGS:
            d = growing(reading, order, 1)
            c, states = join_states(d)
            E = {(k, a, b) for k in R.KINDS for a, bs in d[k].items() for b in bs}
            lines = []
            for p in states:
                present = [c.names[i] for i in mm.bits(p)]
                mons = [m for m in present if m in d["monitors"]]
                works = [w for w in present if w in d["works"]]
                # Theorem J: mutual pairs connect the present monitors; each present work
                # has a present checker and more than f present halt inputs
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
                connected = len(seen) == len(mons)
                halts = min((len([m for m in d["halt_inputs"][w] if m in present])
                             for w in works), default=99)
                checked = all(any(m in present for m in d["checkers"][w]) for w in works)
                # a monitor nobody checks
                unchecked = [m for m in mons if not any(
                    ("checkers", m, x) in E for x in mons if x != m)]
                # Theorem S on the present set
                s = cm.System("x", 1)
                s.monitors, s.works = mons, works
                s.boundary = {m: i for i, m in enumerate(mons)}
                for rel in mm.RELATIONS:
                    setattr(s, rel, {k: [m for m in v if m in present]
                                     for k, v in d[rel].items() if k in present})
                suf = cm.sufficient_f1(s)
                lines.append((stage_name(present), connected, halts, checked, unchecked, suf))
            bad = [l for l in lines if not (l[1] and l[5])]
            print(f"\n{order}, {reading}: {len(states)} sets of present processes; Theorem J's "
                  f"condition holds in {sum(1 for l in lines if l[1] and l[3])}, Theorem S's "
                  f"in {sum(1 for l in lines if l[5])}; a monitor nobody checks in "
                  f"{sum(1 for l in lines if l[4])}; fewest present halt inputs of a present "
                  f"work process: {min(l[2] for l in lines)}")
            for l in bad[:6]:
                print(f"     [{l[0]}] mutual pairs connect: {l[1]}; Theorem S: {l[5]}; "
                      f"unchecked: {' '.join(l[4]) or '-'}")
            if len(bad) > 6:
                print(f"     ... and {len(bad) - 6} more")


def fifth():
    print("\n== Part D: the least attachment of a fifth node N to the candidate ring")
    nodes = R.NODES4 + ["N"]

    def system(reading, extra_edges, work, f, arrive_bad=True):
        E = R.edges_of(R.CANDIDATE, reading) | frozenset(extra_edges)
        d = R.ring_system(E, nodes, "D", "all", f)
        # the work is the base ring's: N is not there at the start
        if work == "all":
            d["checkers"]["W"] = list(R.NODES4)
            d["halt_inputs"]["W"] = list(R.NODES4)
        else:
            d["checkers"]["W"] = ["A"]
            d["halt_inputs"]["W"] = ["A", "D"]
        d["late"] = [{"name": "N", "members": ["N"], "after": []}]
        d["arrive_bad"] = arrive_bad
        return d

    def evaluate(reading, extra_edges, work, f):
        d = system(reading, extra_edges, work, f)
        r = mm.explore(d)
        E = R.edges_of(R.CANDIDATE, reading) | frozenset(extra_edges)
        return {"R1": r["G1"] is None and r["G2"] is None,
                "R6": r["G2"] is None and r["told"] is None,
                "R2": R.r2(E, nodes), "R3": R.r3(E, nodes, "D"),
                "R5": R.r5(E, nodes, "D"), "R4": True, "raw": (r["G1"], r["G2"], r["told"])}

    pairs = [("N", x) for x in R.NODES4] + [(x, "N") for x in R.NODES4]
    reqs = ["R1", "R2", "R3", "R4", "R5", "R6"]
    for reading in R.READINGS:
        for work in ("all", "two"):
            for f in (1, 2, 3):
                if work == "two" and f > 1:
                    continue
                table = {}
                for mask in range(256):
                    conns = [p for i, p in enumerate(pairs) if (mask >> i) & 1]
                    extra = R.edges_of(conns, reading)
                    table[mask] = (conns, evaluate(reading, extra, work, f))
                print(f"\n-- {reading}, work reads {work}, f={f}: 256 attachments as connections")
                for subset in ([("R1",), ("R2",), ("R3",), ("R5",), ("R6",), ("R1", "R6"),
                                ("R2", "R5"), tuple(reqs)] if f == 1 else [("R1",), ("R6",), tuple(reqs)]):
                    good = [m for m, (c, ev) in table.items() if all(ev[q] for q in subset)]
                    if not good:
                        print(f"   {'+'.join(subset)}: no attachment meets it")
                        continue
                    k = min(bin(m).count("1") for m in good)
                    least = [table[m][0] for m in good if bin(m).count("1") == k]
                    fixed = ("D", "N") if work == "all" else ("A", "D", "N")
                    shapes = sorted({R.canon_conns(c, nodes, fixed) for c in least})
                    text = "; ".join(", ".join(f"{x}->{y}" for x, y in s) or "(none)"
                                     for s in shapes)
                    print(f"   {'+'.join(subset)}: least {k} ({len(least)} attachments, "
                          f"{len(shapes)} shapes): {text}")
    # kind by kind: 24 edges between N and the four
    U = frozenset((k, a, b) for k in R.KINDS for a, b in pairs)
    for reading in R.READINGS:
        for work in ("all", "two"):
            for f in (1, 2, 3):
                if work == "two" and f > 1:
                    continue
                memo = {}

                def ev(x):
                    if x not in memo:
                        memo[x] = evaluate(reading, x, work, f)
                    return memo[x]

                print(f"\n-- {reading}, work reads {work}, f={f}: kind by kind, 24 edges")
                for subset in ([("R1",), ("R2",), ("R3",), ("R5",), ("R6",), tuple(reqs)]
                               if f == 1 else [("R1",), tuple(reqs)]):
                    good = lambda x, subset=subset: all(ev(x)[q] for q in subset)
                    k, sets, clauses, tests = R.least_cardinality(U, good)
                    if k is None:
                        print(f"   {'+'.join(subset)}: all 24 edges do not meet it")
                        continue
                    fixed = ("D", "N") if work == "all" else ("A", "D", "N")
                    shapes = sorted({R.canon_edges(x, nodes, fixed) for x in sets})
                    print(f"   {'+'.join(subset)}: fewest {k} ({len(sets)} sets, {len(shapes)} "
                          f"shapes, {tests} systems explored)")
                    for s in shapes[:4]:
                        print("        " + "; ".join(R.edge_text(e) for e in s))
    # arriving good, and the executions
    print("\n-- executions")
    for reading in R.READINGS:
        d = system(reading, frozenset(), "all", 1)
        r = mm.explore(d)
        print(f"{reading}: N with no connection at all, f=1: G1 {r['G1']}, G2 {r['G2']}, told {r['told']}")
        print(rows_text(d, r["traces"][("G1", "ring")]))


if __name__ == "__main__":
    todo = sys.argv[1:] or ["grow", "steps", "fifth"]
    for name in todo:
        globals()[name]()
