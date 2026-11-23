#!/usr/bin/env python3
"""Checks made for corrections-1.md. A helper script, standard library only.

It changes nothing: it builds systems with join_lib.py and join_runs.py, explores them with
fast_join.py, and prints. Run:  python -I recheck_corrections.py > recheck-corrections.txt
"""
import itertools
import os
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from join_lib import *            # noqa: E402,F401,F403
import join_runs as R             # noqa: E402


def ring(f, arr, edges):
    """Ring A and ring B, both meshes, ring B and WB joining in one step; KB's edges with
    ring A are `edges`, a list of (kind, monitor of A)."""
    d = R.ring_join("one-step", f, arr, on=())
    for k, x in sorted(edges, key=lambda e: (KINDS.index(e[0]), BASE.index(e[1]))):
        rel, key, m = triple("KB", k, x)
        edge(d, rel, key, m)
    return d


ALL = [(k, x) for k in KINDS for x in BASE]


def listed(f):
    """The least attachments of KB as the write-up states them for rate f."""
    out = []
    second = [[("out_chk", x), ("out_hb", x), ("in_fwd", x)] for x in BASE]
    second += [[("in_fwd", x) for x in xs] for xs in itertools.combinations(BASE, f + 1)]
    for a in BASE:
        for b in BASE:
            for c in BASE:
                for sec in second:
                    out.append(frozenset([("in_chk", a), ("in_hb", b), ("out_fwd", c)] + sec))
    return out


def greatest(f):
    """Every maximal set of edges that contains none of the listed sets: one of the three
    kinds toward ring A missing altogether, or at most f monitors of A reporting to KB and
    KB not watching any of those in full."""
    out = [frozenset(e for e in ALL if e[0] != k) for k in ("in_chk", "in_hb", "out_fwd")]
    for n in range(0, f + 1):
        for keep in itertools.combinations(BASE, n):
            for dropped in itertools.product(("out_chk", "out_hb"), repeat=n):
                gone = {("in_fwd", x) for x in BASE if x not in keep} | set(zip(dropped, keep))
                out.append(frozenset(e for e in ALL if e not in gone))
    return out


print("1. The least attachments of a joining ring over all 24 edges (two meshes, one step)")
for f in (1, 2, 3):
    ls, gs = listed(f), greatest(f)
    sizes = {}
    for s in ls:
        sizes[len(s)] = sizes.get(len(s), 0) + 1
    for arr in (True, False):
        with_gap = sum(not no_gap(check(ring(f, arr, s))) for s in ls)
        no = sum(no_gap(check(ring(f, arr, s))) for s in gs)
        # each greatest set is greatest: adding any one missing edge closes the gap
        not_greatest = sum(1 for s in gs for e in ALL
                           if e not in s and not no_gap(check(ring(f, arr, s | {e}))))
        print(f"   f={f}, a member may arrive bad: {arr}: listed sets {len(ls)} "
              f"(edges: count {dict(sorted(sizes.items()))}), with a gap {with_gap}; "
              f"greatest sets holding no listed set {len(gs)}, without a gap {no}, "
              f"single additions that leave a gap {not_greatest}")
    # every set that holds no listed set lies inside a greatest one: a sample
    import random
    rng = random.Random(f)
    outside = tried = 0
    for _ in range(4000):
        s = frozenset(e for e in ALL if rng.random() < rng.choice((0.5, 0.75, 0.9)))
        if any(t <= s for t in ls):
            continue
        tried += 1
        outside += not any(s <= g for g in gs)
    print(f"   f={f}: {tried} random sets holding no listed set; not inside a greatest set: {outside}")
    few = [g for g in gs if sum(1 for e in g if e[0] == "in_fwd") < f]
    print(f"   f={f}: of the greatest sets, those with fewer than {f} monitors reporting to KB: {len(few)}")

print("\n2. Five edges at f = 1: M1 checks KB, M1 reads KB's signal, KB reports to M1, M1 and M2 report to KB")
five = [("in_chk", "M1"), ("in_hb", "M1"), ("out_fwd", "M1"), ("in_fwd", "M1"), ("in_fwd", "M2")]
for arr in (False, True):
    print(f"   a member may arrive bad: {arr}: f=1 {fmt(check(ring(1, arr, five)))}; f=2 {fmt(check(ring(2, arr, five)))}")

print("\n3. Theorem L without its hypothesis: N5 on M1, N6 on N5 after N5, N5 has an off switch, f = 1")
d = grown("mesh", [("one", ("M1",)), ("one", ("N5",))], f=1, arrive_bad=False)
print(f"   without the switch: {fmt(check(d))}")
d["switches"] = ["N5"]
d["name"] += ", N5 has an off switch"
print(f"   with it: {fmt(check(d))}")
print(show_trace(trace(d, "G1")))
print(show_trace(run_schedule(d, [[("join", "N5")], [("join", "N6")], [("disable", "N5")],
                                  [("mutate", "N6")]])))

print("\n4. N in a mesh with all four, J halting on N and the four, f = 4")
es = [(k, x) for x in BASE for k in KINDS]
d = R.relied("mesh", 4, False, es, tuple(BASE))
print(f"   {fmt(check(d))}")
print(show_trace(run_schedule(d, [[("mutate", m) for m in BASE]])))

print("\n5. Mesh of three, no reports, W checked by M1 only and halting on all three, f = 2")
d = blank("mesh of three, no reports, W checked by M1")
for m in ("M1", "M2", "M3"):
    add_monitor(d, m)
for a, b in itertools.combinations(("M1", "M2", "M3"), 2):
    watch(d, a, b)
    watch(d, b, a)
d["works"] = ["W"]
d["checkers"]["W"] = ["M1"]
d["halt_inputs"]["W"] = ["M1", "M2", "M3"]
d["f"] = 2
print(f"   {fmt(check(d))}")
print(show_trace(run_schedule(d, [[("mutate", "W"), ("mutate", "M1")]])))

print("\n6. Shortest executions where a monitor may arrive bad")
chain = [("one", ("M1",)), ("one", ("N5",)), ("one", ("N6",))]
d = grown("mesh", chain, f=1, arrive_bad=True)
drop(d, "hb_readers", "N6", "N5")
print(f"   chain, nobody reads N6's signal, a monitor may arrive bad: {fmt(check(d))}")
print(show_trace(trace(d, "G1")))
steps = [("mesh", ("M1", "M2", "M3")), ("mesh", ("N5", "M1", "M2")),
         ("mesh", ("N5", "N6", "M1")), ("mesh", ("N5", "N6", "N7"))]
d = grown("mesh", steps, f=1, arrive_bad=True)
d["slow_reports"] = True
print(f"   grown to eight, slow reports, a monitor may arrive bad: {fmt(check(d))}")
print(show_trace(trace(d, "G2")))

print("\n7. The chain as built, f = 3 (a monitor that only a later monitor leans on has three edges)")
print(f"   {fmt(check(grown('mesh', chain, f=3, arrive_bad=True)))}")

print("\n8. The 62 systems of way one in any join order: gap at f = 1 against 'some monitor's three are all late'")
by = R.way_one(8)
agree = total = 0
for size in range(5, 9):
    for seq in by[size]:
        d = grown("mesh", [("mesh", t) for t in seq], guard=False, f=1)
        late3 = any(all(x not in BASE for x in t) for t in seq)
        total += 1
        agree += (not no_gap(check(d))) == late3
print(f"   {agree} of {total} agree")
