#!/usr/bin/env python3
"""Builders, requirements and searches for the least ring. Standard library only.

A node is a monitor. A *connection* X -> Y is one of the directed arrows of the drawing.
An *edge* is one of the model's three kinds, written as the triple of model-spec-join.md:

    ("hb_readers", p, m)   m reads p's signal
    ("checkers",   x, m)   m checks x's state
    ("fwd",        m, r)   m reports its flag to r

Two readings of a connection X -> Y (see part-a.md, section 1):

    flow    everything that flows from X to Y: Y reads X's signal, Y checks X's state,
            X reports to Y
    actor   everything X does toward Y: X reads Y's signal, X checks Y's state,
            X reports to Y
"""
import itertools
import json
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import mr_model as mm  # noqa: E402

KINDS = ("hb_readers", "checkers", "fwd")
READINGS = ("flow", "actor")


def bundle(x, y, reading):
    """The edges a connection x -> y carries under a reading."""
    if reading == "flow":
        return [("hb_readers", x, y), ("checkers", x, y), ("fwd", x, y)]
    if reading == "actor":
        return [("hb_readers", y, x), ("checkers", y, x), ("fwd", x, y)]
    if reading == "both":           # an undirected link: all six edges between x and y
        return [(k, a, b) for k in KINDS for a, b in ((x, y), (y, x))]
    raise ValueError(reading)


def edges_of(conns, reading):
    out = set()
    for x, y in conns:
        out.update(bundle(x, y, reading))
    return frozenset(out)


def all_pairs(nodes):
    return [(x, y) for x in nodes for y in nodes if x != y]


def all_edges(nodes):
    return [(k, x, y) for k in KINDS for x, y in all_pairs(nodes)]


def cycle_ring(members, coord):
    """The candidate's shape: the members in a cycle, the coordinator connected to each
    both ways. For members A, B, C and coordinator D this is the drawing."""
    k = len(members)
    conns = [(members[i], members[(i + 1) % k]) for i in range(k)]
    conns += [(coord, m) for m in members] + [(m, coord) for m in members]
    return conns


def mesh_ring(nodes):
    return all_pairs(nodes)


NODES4 = ["A", "B", "C", "D"]
CANDIDATE = cycle_ring(["A", "B", "C"], "D")


def conn_text(conns):
    return ", ".join(f"{x}->{y}" for x, y in sorted(conns))


def edge_text(e):
    k, a, b = e
    return {"hb_readers": f"{b} reads {a}'s signal", "checkers": f"{b} checks {a}'s state",
            "fwd": f"{a} reports to {b}"}[k]


# ------------------------------------------------------------------ systems

def ring_system(edges, nodes=NODES4, coord="D", work="all", f=1, name="ring", scoped=True):
    """A ring of the given nodes with the given edges and one work process W.

    work "all": W is checked by every node and takes its halt from every node.
    work "all-checking": W is checked by every node that checks some node's state (the
          wording of results-join.md, section 2) and takes its halt from every node.
    work "two": W is checked by the first node and takes its halt from the first node and
          the coordinator.
    With scoped, everything is in one scope "ring" and the coordinator is the monitor that
    is to be told (model-spec-scope.md); this changes neither G1 nor G2.
    """
    d = {"name": name, "f": f, "monitors": list(nodes), "works": ["W"], "joiner": None,
         "boundary": {m: i + 1 for i, m in enumerate(nodes)}, "substrate": {},
         "hb_readers": {}, "checkers": {}, "fwd": {}, "halt_inputs": {}, "switches": [],
         "coupling": True, "window": 0, "gate": True, "slow_reports": False,
         "late": [], "arrive_bad": False, "slow_edges": []}
    for k, a, b in sorted(edges):
        d[k].setdefault(a, []).append(b)
    if work == "all":
        d["checkers"]["W"] = list(nodes)
        d["halt_inputs"]["W"] = list(nodes)
    elif work == "all-checking":
        checking = {b for k, a, b in edges if k == "checkers"}
        d["checkers"]["W"] = [m for m in nodes if m in checking]
        d["halt_inputs"]["W"] = list(nodes)
    elif work == "two":
        d["checkers"]["W"] = [nodes[0]]
        d["halt_inputs"]["W"] = [nodes[0], coord]
    else:
        raise ValueError(work)
    if scoped:
        d["scope"] = {p: "ring" for p in list(nodes) + ["W"]}
        d["told"] = {"ring": [coord]}
    return d


RESULTS = {}


def run(d):
    """(G1, G2, told) for a system: least number of rounds or None."""
    key = json.dumps(d, sort_keys=True)
    if key not in RESULTS:
        r = mm.explore(d)
        if r["bounded"]:
            raise RuntimeError("bounded")
        RESULTS[key] = (r["G1"], r["G2"], r["told"])
    return RESULTS[key]


# ------------------------------------------------------------------ requirements

def watchers(edges, nodes):
    """node -> the set of nodes that both read its signal and check its state."""
    return {z: {m for m in nodes if m != z and ("hb_readers", z, m) in edges
                and ("checkers", z, m) in edges} for z in nodes}


def readers(edges, nodes):
    return {z: {m for m in nodes if m != z and ("hb_readers", z, m) in edges} for z in nodes}


def r2(edges, nodes):
    """Every node is watched by at least two others."""
    w = watchers(edges, nodes)
    return all(len(w[z]) >= 2 for z in nodes)


def reached(observers, start, nodes):
    """Nodes reached from `start` along observation: start observes a node, which
    observes another, and so on. observers[x] is the set of nodes that observe x."""
    seen, stack = {start}, [start]
    while stack:
        o = stack.pop()
        for x in nodes:
            if x not in seen and o in observers[x]:
                seen.add(x)
                stack.append(x)
    return seen


def r3(edges, nodes, coord, observe="watch"):
    """The ring can always restart with the coordinator the member that can start first:
    by restart_iff_reached (Lean) and results.md 10.3, exactly when the coordinator
    reaches every other node along observation. observe "watch": o observes x when it
    reads x's signal and checks x's state. observe "signal": when it reads x's signal."""
    obs = watchers(edges, nodes) if observe == "watch" else readers(edges, nodes)
    return reached(obs, coord, nodes) == set(nodes)


def r5(edges, nodes, coord):
    """Every member reports directly to the coordinator."""
    return all(("fwd", m, coord) in edges for m in nodes if m != coord)


def can_name(wt, nodes):
    """Naming read at the wiring. At most one node is faulty. A correct node names the
    faulty node if it watches it, and names nobody otherwise. A faulty node may name
    anyone or nobody. True if some rule always returns the faulty node (or nobody when
    none is faulty): no two cases with different answers can give the same names."""
    nodes = list(nodes)
    options = [None] + nodes
    seen = {}
    for z in options:
        free = [z] if z is not None else []
        for lie in (options if z is not None else [None]):
            names = tuple((lie if m == z else (z if z is not None and m in wt[z] else None))
                          for m in nodes)
            if seen.setdefault(names, z) != z:
                return False
    return True


def can_name_rule(wt, nodes):
    """The same, by the rule proved in part-a.md: every node has a watcher, and no two
    nodes are each watched by nobody but the other."""
    if any(not wt[z] for z in nodes):
        return False
    return not any(wt[x] <= {y} and wt[y] <= {x} for x, y in itertools.combinations(nodes, 2))


def r4w(edges, nodes):
    return can_name(watchers(edges, nodes), nodes)


def r4w_after_loss(edges, nodes):
    """Still naming after the loss of any one node: the rule above on the three left."""
    for lost in nodes:
        rest = [m for m in nodes if m != lost]
        sub = frozenset(e for e in edges if lost not in e[1:])
        if not can_name(watchers(sub, rest), rest):
            return False
    return True


def evaluate(edges, nodes=NODES4, coord="D", work="all", fs=(1, 2, 3)):
    """Every requirement for one wiring. R1 and R6 are given per rate."""
    out = {"R2": r2(edges, nodes), "R3": r3(edges, nodes, coord),
           "R3s": r3(edges, nodes, coord, "signal"), "R4": len(nodes) >= 3,
           "R4w": r4w(edges, nodes), "R4wl": r4w_after_loss(edges, nodes),
           "R5": r5(edges, nodes, coord)}
    for f in fs:
        g1, g2, told = run(ring_system(edges, nodes, coord, work, f))
        out[f"R1@{f}"] = g1 is None and g2 is None
        out[f"R6@{f}"] = g2 is None and told is None
        out[f"raw@{f}"] = (g1, g2, told)
    return out


# ------------------------------------------------------------------ renaming

def renamings(nodes, fixed):
    """Every renaming of the nodes that keeps each node in `fixed`."""
    free = [m for m in nodes if m not in fixed]
    for perm in itertools.permutations(free):
        yield dict(zip(free, perm), **{m: m for m in fixed})


def canon_conns(conns, nodes, fixed):
    return min(tuple(sorted((p[x], p[y]) for x, y in conns)) for p in renamings(nodes, fixed))


def canon_edges(edges, nodes, fixed):
    return min(tuple(sorted((k, p[a], p[b]) for k, a, b in edges))
               for p in renamings(nodes, fixed))


# ------------------------------------------------------------------ least sets, complete

def least_cardinality(universe, good, seeds=(), log=None, max_tests=2000000, batch=40):
    """Every good set of the fewest elements, for a monotone `good` (adding an element
    never turns good into not good; Lemma M gives this for the judgements).

    Method (implicit hitting sets). A *clause* is the complement of a set known not to be
    good; by monotonicity every good set meets every clause. The smallest sets that meet
    every clause are listed; each is tested; one that is not good is grown to a greatest
    set that is not good, whose complement is a new clause. When every smallest set that
    meets all the clauses is good, those are all the good sets of the fewest elements: a
    good set with fewer, or another with as many, would meet every clause and so would
    have been listed.

    Returns (k, list of sets, clauses, number of tests) or (None, [], clauses, tests) when
    the universe itself is not good.
    """
    universe = frozenset(universe)
    order = sorted(universe)
    memo = {}

    def g(x):
        if x not in memo:
            if len(memo) >= max_tests:
                raise RuntimeError("too many tests")
            memo[x] = bool(good(x))
        return memo[x]

    if not g(universe):
        return None, [], [], len(memo)
    clauses = [frozenset(c) for c in seeds]

    def grow(x):
        for e in order:
            if e not in x and not g(x | {e}):
                x = x | {e}
        return x

    def hitting(k):
        """Every set of exactly k elements that meets every clause (each once)."""
        cl = sorted(clauses, key=len)

        def rec(chosen, banned, left):
            unhit = [c for c in cl if not c & chosen]
            if not unhit:
                # pad with any elements, in order, to reach k
                rest = [e for e in order if e not in chosen and e not in banned]
                for extra in itertools.combinations(rest, left):
                    yield chosen | frozenset(extra)
                return
            if left == 0:
                return
            # a lower bound: disjoint unhit clauses, greedily
            used, count = set(), 0
            for c in unhit:
                c2 = c - banned
                if not c2:
                    return
                if not c2 & used:
                    used |= c2
                    count += 1
            if count > left:
                return
            pick = min(unhit, key=lambda c: len(c - banned)) - banned
            b = set(banned)
            for e in sorted(pick):
                yield from rec(chosen | {e}, frozenset(b), left - 1)
                b.add(e)

        seen = set()
        for h in rec(frozenset(), frozenset(), k):
            if h not in seen:
                seen.add(h)
                yield h

    k = 0
    while True:
        fresh = []          # clauses found in this pass; the listing does not use them yet
        found = []
        for h in hitting(k):
            if any(not c & h for c in fresh):
                continue    # known not good: it misses a clause found in this pass
            if g(h):
                found.append(h)
            else:
                fresh.append(universe - grow(h))
                if len(fresh) >= batch:
                    break
        if fresh:
            clauses.extend(fresh)
            if log:
                log(f"  {len(clauses)} clauses, k={k}, tests={len(memo)}")
            continue        # list again with the new clauses
        if not found:
            k += 1
            continue
        return k, found, clauses, len(memo)
