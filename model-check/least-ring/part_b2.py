#!/usr/bin/env python3
"""Part B, k = 5 under the actor reading, without listing every wiring of fifteen
connections (there are 100,000 that meet R2 and R5): the cycle with a coordinator has the
counted least number, and is tested against the whole list. A sample of 2,000 of the
100,000 is tested too. Also the kind by kind sets for k = 5.

Run:  python -B part_b2.py
"""
import itertools
import os
import random
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mr_ring as R  # noqa: E402
import part_b as B  # noqa: E402

k = 5
nodes = B.nodes_for(k)
members = nodes[:-1]
up = [(m, "K") for m in members]
for reading in R.READINGS:
    E = R.edges_of(R.cycle_ring(members, "K"), reading)
    print(f"k=5, {reading}: the cycle with a coordinator ({3 * k} connections) meets the whole "
          f"list: " + ", ".join(f"work {w} f={f}: {B.meets(E, nodes, w, f)}"
                                for w, f in (("all", 1), ("all", 2), ("all", 3), ("two", 1))))
choices = [list(itertools.combinations([y for y in nodes if y != x], 2)) for x in members]
random.seed(5)
good = 0
n = 2000
for _ in range(n):
    ins = [random.choice(c) for c in choices]
    conns = up + [(y, x) for x, pair in zip(members, ins) for y in pair]
    good += B.meets(R.edges_of(conns, "actor"), nodes, "all", 1)
print(f"k=5, actor, work reads all, f=1: of {n} wirings drawn at random from the 100,000 of "
      f"15 connections that meet R2 and R5, {good} meet the whole list")
for reading in R.READINGS:
    E = set(("fwd", m, "K") for m in members)
    for i, m in enumerate(members):
        a, b = (m, members[(i + 1) % k])
        for kind in ("hb_readers", "checkers"):
            E.add((kind, a, b) if reading == "flow" else (kind, b, a))
            E.add((kind, m, "K"))
    for m in members[:2]:
        for kind in ("hb_readers", "checkers"):
            E.add((kind, "K", m))
    E = frozenset(E)
    ok = {(work, f): B.meets(E, nodes, work, f) for work in ("all", "two") for f in (1, 2, 3)}
    print(f"k=5, kind by kind, {reading}: {len(E)} edges (5k + 4 = {5 * k + 4}) on the cycle's "
          f"arrows meet the whole list: {ok}")
