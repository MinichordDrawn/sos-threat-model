#!/usr/bin/env python3
"""The systems with joining monitors: builds them, checks them, prints the tables.

A helper script, standard library only, Python 3.9 or later. The model is model-spec.md
with model-spec-join.md. Every result is computed by fast_join.py; the cases written to the
catalogue are computed a second time by check_model_join.py (the original checker,
extended) and the two must agree.

Run:  python -I join_runs.py                      every section
      python -I join_runs.py A B                  only the named sections
      python -I join_runs.py --write              also write systems-join.json and
                                                  results-join.json (every section runs)
Sections: A0 bases, A1 one joining monitor, A2 a joining monitor that work depends on,
B from the step that adds it, C growing, D the work processes, E a ring that joins,
F cost, T the theorems against the search, X the executions of the write-up.
"""
import copy
import itertools
import json
import os
import random
import sys
import time

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from join_lib import *            # noqa: E402,F401,F403
import join_lib as L              # noqa: E402

RATES = (1, 2, 3)
ARR = {False: "good", True: "bad"}
TALLY = []        # (system, result) of every plain system checked, for section T


def chk(d):
    r = check(d)
    TALLY.append((d, r))
    return r


def cas(case_id, d):
    r = case(case_id, d)
    TALLY.append((d, r))
    return r


def row3(build, rates=RATES):
    """Results at each rate, as short strings."""
    return "  ".join(f"{short(chk(build(f))):>5}" for f in rates)


# ----------------------------------------------------------------------------- A0

def section_a0():
    print("A0. The base rings (nothing joins)")
    print("    '-' no gap; 'a/b' G1 broken in a rounds and G2 in b ('.' holds); '*' every round with a")
    print("    fault ends in a complete response.   f = 1, 2, 3, 4")
    for kind in BASE_WORDS:
        print(f"  {kind}: {BASE_WORDS[kind]}")
        for wiring in ("all", "two"):
            cells = []
            for f in (1, 2, 3, 4):
                d = base(kind, wiring, f)
                r = cas(f"base/{kind}/{wiring}/f{f}", d)
                cells.append(f"{short(r)}{'*' if responds_at_once(d) else ''}")
            d = base(kind, wiring)
            print(f"    work reads {wiring:<3}: {'  '.join(f'{c:>5}' for c in cells)}"
                  f"   Theorem S (a)-(d): {'hold' if theorem_s(d) else 'fail'};"
                  f" fewest state checkers of a monitor {least_observers(d, 'checkers')},"
                  f" signal readers {least_observers(d, 'readers')},"
                  f" watchers {least_observers(d)}")


# ----------------------------------------------------------------------------- A1

UNIVERSE = [(k, x) for k in KINDS for x in BASE]


def one(kind, wiring, f, arr, edges, slow=()):
    """A base ring and one late monitor N with the given edges; nothing depends on N."""
    d = base(kind, wiring, f)
    add_late(d, "N", sorted(edges, key=lambda e: (KINDS.index(e[0]), BASE.index(e[1]))))
    d["arrive_bad"] = arr
    d["slow_edges"] = [triple("N", k, x) for k, x in slow]
    d["name"] = f"{kind}/{wiring} + N"
    return d


def label(edges):
    return "+".join(f"{k}:{x}" for k, x in sorted(
        edges, key=lambda e: (KINDS.index(e[0]), BASE.index(e[1])))) or "none"


def describe(sets):
    """Minimal sets, grouped by the kinds of edge they use."""
    groups = {}
    for s in sets:
        key = tuple(sorted((k for k, _ in s), key=KINDS.index))
        groups.setdefault(key, []).append(s)
    lines = []
    for key in sorted(groups, key=lambda k: (len(k), [KINDS.index(x) for x in k])):
        members = groups[key]
        per_kind = {}
        for s in members:
            for k, x in s:
                per_kind.setdefault(k, set()).add(x)
        where = "; ".join(f"{k} at {'/'.join(sorted(per_kind[k], key=BASE.index))}"
                          for k in dict.fromkeys(key))
        lines.append(f"{len(members):>4} of {len(key)} edge{'s' * (len(key) > 1)}: "
                     f"{' + '.join(key)}   ({where})")
    return lines


def section_a1():
    print("\nA1. One joining monitor N that nothing depends on")
    print("    Six kinds of edge between N and an existing monitor X:")
    for k in KINDS:
        print(f"      {k:<8} {KIND_WORDS[k].format(n='N', x='X')}")
    triples = {"mesh": ("M1", "M2", "M3"), "cyc-check": ("M1", "M2", "K"),
               "cyc-signal": ("M1", "M2", "K"), "cyc-first": ("M1", "M2", "K")}
    for kind in BASE_WORDS:
        for wiring in ("all", "two"):
            rates = RATES if wiring == "all" else (1,)
            print(f"\n  base {kind}, work reads {wiring}"
                  f"   (columns: f = {', '.join(map(str, rates))}; N arrives good | N may arrive bad)")

            def both(tag, edges, rates=rates, kind=kind, wiring=wiring):
                cells = []
                for arr in (False, True):
                    cells.append("  ".join(
                        f"{short(cas(f'a1/{kind}/{wiring}/{tag}/{ARR[arr]}/f{f}', one(kind, wiring, f, arr, edges))):>5}"
                        for f in rates))
                return " | ".join(cells)

            print(f"    no edge at all                      {both('none', [])}")
            print("    one edge only:")
            for k in KINDS:
                for x in BASE:
                    print(f"      {words('N', k, x):<34} {both('only-' + k + '-' + x, [(k, x)])}")
            rest = [e for e in UNIVERSE if e[0] != "in_chk"]
            print(f"    every edge but the checks of N (20)  {both('all-but-in_chk', rest)}")
            print(f"    every edge (24)                     {both('all', UNIVERSE)}")
            t = triples[kind]
            for shape, att in (("mesh", t), ("coord-signal", t), ("member-check", t),
                               ("member-signal", t), ("one", t[:1])):
                es = shape_edges(shape, *att)
                print(f"    shape {shape:<13} on {','.join(att):<9}      {both(shape, es)}")
            if wiring == "all":
                full = shape_edges("mesh", *t)
                spare = needed = 0
                for e in full:
                    res = [cas(f"a1/{kind}/{wiring}/mesh-minus-{e[0]}-{e[1]}/bad/f{f}",
                               one(kind, wiring, f, True, [x for x in full if x != e]))
                           for f in rates]
                    base_res = [check(one(kind, wiring, f, True, full)) for f in rates]
                    if res == base_res:
                        spare += 1
                    else:
                        needed += 1
                        print(f"      needed: {words('N', *e)}: {[short(r) for r in res]}")
                print(f"    mesh on {','.join(t)}, one edge removed (N may arrive bad): "
                      f"{spare} of 18 removals change nothing, {needed} change a result")
                for k in KINDS:
                    es = [e for e in full if e[0] != k]
                    print(f"      minus every '{KIND_WORDS[k].format(n='N', x='X')}': "
                          f"{both('mesh-minus-kind-' + k, es)}")
            # the least attachments, complete by the monotone search
            for arr in (False, True):
                for f in rates:
                    def good(s, f=f, arr=arr):
                        return no_gap(check(one(kind, wiring, f, arr, s)))
                    least, most, tests = least_sets(UNIVERSE, good)
                    print(f"    least attachments with no gap, f={f}, N arrives {ARR[arr]}"
                          f" ({tests} systems checked; {len(least)} least, {len(most)} greatest with a gap)")
                    for line in describe(least):
                        print(f"        {line}")
                    for i, s in enumerate(most):
                        missing = sorted(set(UNIVERSE) - s, key=lambda e: (KINDS.index(e[0]), BASE.index(e[1])))
                        print(f"        greatest with a gap #{i + 1}: all 24 but {label(missing)}")
                        cas(f"a1/{kind}/{wiring}/greatest-gap-{i + 1}/{ARR[arr]}/f{f}",
                            one(kind, wiring, f, arr, s))
                    for i, s in enumerate(least[:6]):
                        cas(f"a1/{kind}/{wiring}/least-{i + 1}/{ARR[arr]}/f{f}",
                            one(kind, wiring, f, arr, s))
                    # a random sample against the rule the search produced
                    rng = random.Random(1000 * f + arr)
                    wrong = 0
                    n_sample = 1000
                    for _ in range(n_sample):
                        s = frozenset(e for e in UNIVERSE if rng.random() < rng.choice((0.15, 0.5, 0.85)))
                        predicted = any(t <= s for t in least)
                        if predicted != no_gap(check(one(kind, wiring, f, arr, s))):
                            wrong += 1
                    print(f"        {n_sample} random attachments against that list: {wrong} disagree")


# ----------------------------------------------------------------------------- A2

def relied(kind, f, arr, edges, t, j_mode="with", j_checkers=("N",), j_halts=None,
           slow=(), slow_j=()):
    """A base ring, a late monitor N, and a joining work process J whose state only N
    checks and which takes its halt from N and the three monitors of N's ring.
    j_mode: "with" J joins in N's step; "after" J joins by a step of its own, enabled once
    N is present; "free" J is the model's own joiner and may join at any time."""
    d = base(kind, "all", f)
    add_late(d, "N", sorted(edges, key=lambda e: (KINDS.index(e[0]), BASE.index(e[1]))))
    d["joiner"] = "J"
    d["checkers"]["J"] = list(j_checkers)
    d["halt_inputs"]["J"] = list(j_halts if j_halts is not None else ("N",) + tuple(t))
    if j_mode == "with":
        d["late"][0]["members"].append("J")
    elif j_mode == "after":
        d["late"].append({"name": "J", "members": ["J"], "after": ["N"]})
    d["arrive_bad"] = arr
    d["slow_edges"] = [triple("N", k, x) for k, x in slow] + [list(e) for e in slow_j]
    d["name"] = f"{kind}/all + N + J ({j_mode})"
    return d


def section_a2():
    print("\nA2. A joining monitor N that work depends on")
    print("    A work process J joins in the same step as N. Only N checks J's state. J takes its halt")
    print("    from N and from the three existing monitors of N's ring. W is as before.")
    for kind, t in (("mesh", ("M1", "M2", "M3")), ("cyc-check", ("M1", "M2", "K")),
                    ("cyc-signal", ("M1", "M2", "K"))):
        rates = RATES
        print(f"\n  base {kind}, N's ring is N with {', '.join(t)}"
              f"   (columns: f = 1, 2, 3; N arrives good | N may arrive bad)")

        def both(tag, edges, kind=kind, t=t, **kw):
            cells = []
            for arr in (False, True):
                cells.append("  ".join(
                    f"{short(cas(f'a2/{kind}/{tag}/{ARR[arr]}/f{f}', relied(kind, f, arr, edges, t, **kw))):>5}"
                    for f in rates))
            return " | ".join(cells)

        full = shape_edges("mesh", *t)
        print(f"    N in a mesh with its three (18 edges)   {both('mesh', full)}")
        for shape in ("coord-signal", "member-check", "member-signal"):
            print(f"    N as {shape:<14} of its three        {both(shape, shape_edges(shape, *t))}")
        print(f"    N watched by {t[0]} and reporting to it    {both('one', shape_edges('one', t[0]))}")
        print("    N as a member of a cycle N -> a -> b -> N with coordinator c, for each choice of a, b, c:")
        for shape in ("member-check", "member-signal"):
            for a, b, c in itertools.permutations(t):
                print(f"      {shape:<14} a={a:<2} b={b:<2} c={c:<2}        "
                      f"{both(shape + '-' + a + b + c, shape_edges(shape, a, b, c))}")
        print("    the mesh, one edge removed:")
        for e in full:
            print(f"      minus {words('N', *e):<28} {both('mesh-minus-' + e[0] + '-' + e[1], [x for x in full if x != e])}")
        print("    the mesh, one kind of edge removed from all three:")
        for k in KINDS:
            print(f"      minus every {KIND_WORDS[k].format(n='N', x='X'):<22} {both('mesh-minus-kind-' + k, [e for e in full if e[0] != k])}")
        print("    the mesh, J's own edges:")
        print(f"      J takes its halt from N only        {both('mesh-J-halt-N', full, j_halts=('N',))}")
        print(f"      J takes its halt from N and {t[0]}      {both('mesh-J-halt-N+1', full, j_halts=('N', t[0]))}")
        print(f"      J takes its halt from N, {t[0]}, {t[1]}    {both('mesh-J-halt-N+2', full, j_halts=('N', t[0], t[1]))}")
        print(f"      J takes its halt from the three only {both('mesh-J-halt-three', full, j_halts=t)}")
        for arr in (False, True):
            for f in rates:
                def good(s, f=f, arr=arr):
                    return no_gap(check(relied(kind, f, arr, s, t)))
                least, most, tests = least_sets(UNIVERSE, good)
                print(f"    least attachments of N with no gap, f={f}, N arrives {ARR[arr]}"
                      f" ({tests} systems checked; {len(least)} least, {len(most)} greatest with a gap)")
                for line in describe(least):
                    print(f"        {line}")
                for i, s in enumerate(most):
                    missing = sorted(set(UNIVERSE) - s, key=lambda e: (KINDS.index(e[0]), BASE.index(e[1])))
                    print(f"        greatest with a gap #{i + 1}: all 24 but {label(missing)}")
                    cas(f"a2/{kind}/greatest-gap-{i + 1}/{ARR[arr]}/f{f}", relied(kind, f, arr, s, t))
                for i, s in enumerate(sorted(least, key=lambda s: (len(s), label(s)))[:6]):
                    cas(f"a2/{kind}/least-{i + 1}/{ARR[arr]}/f{f}", relied(kind, f, arr, s, t))


# ----------------------------------------------------------------------------- B

def section_b():
    print("\nB. From the step that adds it: attachments that arrive a round late, or never")
    print("   N joins in a mesh with three existing monitors. 'late' edges are missing in the round N joins.")
    for kind, t in (("mesh", ("M1", "M2", "M3")), ("cyc-check", ("M1", "M2", "K")),
                    ("cyc-signal", ("M1", "M2", "K"))):
        full = shape_edges("mesh", *t)
        inchk = [e for e in full if e[0] == "in_chk"]
        rest = [e for e in full if e[0] != "in_chk"]
        print(f"\n  base {kind}, N with {', '.join(t)}; nothing depends on N"
              f"   (f = 1, 2, 3; N arrives good | N may arrive bad)")

        def both(tag, edges, slow, kind=kind):
            cells = []
            for arr in (False, True):
                cells.append("  ".join(
                    f"{short(cas(f'b/{kind}/{tag}/{ARR[arr]}/f{f}', one(kind, 'all', f, arr, edges, slow))):>5}"
                    for f in RATES))
            return " | ".join(cells)

        print(f"    every edge from the join step               {both('at-once', full, [])}")
        print(f"    every edge a round late                     {both('all-late', full, full)}")
        print(f"    the three checks of N late, the rest at once {both('in_chk-late', full, inchk)}")
        print(f"    one check of N at once, every other edge late {both('one-in_chk-at-once', full, [e for e in full if e != inchk[0]])}")
        print(f"    the checks of N at once, the rest late       {both('rest-late', full, rest)}")
        print(f"    the checks of N never, the rest at once      {both('in_chk-never', rest, [])}")
        print(f"    no edge ever                                {both('none', [], [])}")
        for k in KINDS:
            if k != "in_chk":
                print(f"    only '{KIND_WORDS[k].format(n='N', x='X')}' late:{'':<12} {both(k + '-late', full, [e for e in full if e[0] == k])}")

        print(f"  base {kind}, N with {', '.join(t)}; J joins with N, checked by N, halting on N and the three")

        def bothj(tag, slow, slow_j=(), kind=kind, t=t):
            cells = []
            for arr in (False, True):
                cells.append("  ".join(
                    f"{short(cas(f'b/{kind}/J-{tag}/{ARR[arr]}/f{f}', relied(kind, f, arr, full, t, slow=slow, slow_j=slow_j))):>5}"
                    for f in RATES))
            return " | ".join(cells)

        jchk = [["checkers", "J", "N"]]
        jhalt = [["halt_inputs", "J", m] for m in ("N",) + t]
        print(f"    every edge from the join step               {bothj('at-once', [])}")
        print(f"    every edge of N and of J a round late       {bothj('all-late', full, jchk + jhalt)}")
        for k in KINDS:
            print(f"    only '{KIND_WORDS[k].format(n='N', x='X')}' late:{'':<12} {bothj(k + '-late', [e for e in full if e[0] == k])}")
        print(f"    only N's check of J late                    {bothj('J-check-late', [], jchk)}")
        print(f"    only J's halt inputs late                   {bothj('J-halts-late', [], jhalt)}")
        # which edges must be on time: the least on-time sets, f = 1 (bad arrival) and f = 2, 3
        uni = [("N",) + e for e in full] + [("J", "chk", "N")] + [("J", "halt", m) for m in ("N",) + t]
        for arr, f in ((True, 1), (False, 2), (True, 2), (True, 3)):
            def good(on_time, f=f, arr=arr):
                slow = [e[1:] for e in uni if e[0] == "N" and e not in on_time]
                sj = [["checkers", "J", "N"]] * (("J", "chk", "N") not in on_time)
                sj += [["halt_inputs", "J", e[2]] for e in uni
                       if e[:2] == ("J", "halt") and e not in on_time]
                return no_gap(check(relied(kind, f, arr, full, t, slow=slow, slow_j=sj)))
            least, most, tests = least_sets(uni, good)
            print(f"    least sets of edges that must be in force in the join round, f={f}, "
                  f"N arrives {ARR[arr]} ({tests} systems checked): {len(least)}")
            groups = {}
            for s in least:
                key = tuple(sorted(("J's check" if e[:2] == ("J", "chk") else
                                    "J's halt input" if e[0] == "J" else e[1]) for e in s))
                groups[key] = groups.get(key, 0) + 1
            for key, n in sorted(groups.items(), key=lambda kv: (len(kv[0]), kv[0])):
                print(f"        {n:>4} of {len(key)}: {' + '.join(key)}")


# ----------------------------------------------------------------------------- C

def triangles(adj, nodes):
    return [t for t in itertools.combinations(nodes, 3)
            if all(b in adj[a] for a, b in itertools.combinations(t, 2))]


def way_one(max_size):
    """Every 3-tree grown from the mesh of four, up to relabelling, by size."""
    by_size = {4: [()]}
    for size in range(5, max_size + 1):
        seen, out = set(), []
        for seq in by_size[size - 1]:
            nodes = BASE + [f"N{5 + i}" for i in range(len(seq))]
            adj = {m: set(BASE) - {m} for m in BASE}
            for i, t in enumerate(seq):
                n = f"N{5 + i}"
                adj[n] = set(t)
                for x in t:
                    adj[x].add(n)
            for t in triangles(adj, nodes):
                new = seq + (t,)
                key = canonical(new)
                if key not in seen:
                    seen.add(key)
                    out.append(new)
        by_size[size] = out
    return by_size


def canonical(seq):
    """A key that is the same for two growth sequences exactly when one is the other with
    the base monitors and the new monitors renamed."""
    k = len(seq)
    late = [f"N{5 + i}" for i in range(k)]
    best = None
    for pb in itertools.permutations(BASE):
        mb = dict(zip(BASE, pb))
        for pl in itertools.permutations(late):
            m = dict(mb)
            m.update(zip(late, pl))
            key = tuple(sorted((m[late[i]], tuple(sorted(m[x] for x in seq[i]))) for i in range(k)))
            if best is None or key < best:
                best = key
    return best


def rate_of(build):
    """The greatest f in 1..4 with no gap at every f up to it (0 if a gap at f = 1), and
    the results."""
    res = [chk(build(f)) for f in (1, 2, 3, 4)]
    top = 0
    for r in res:
        if not no_gap(r):
            break
        top += 1
    return top, res


def section_c():
    print("\nC. Growing without end")
    print("   Every system below starts as a base ring with one work process W that the base monitors check")
    print("   and that takes its halt from the four base monitors. Joins and faults in every order; a new")
    print("   monitor may arrive bad. 'rate' is the greatest f with no gap (4 was the highest tried).")

    print("\n  C1. Way one: each new monitor in a mesh with three that watch each other (base: mesh of four)")
    by_size = way_one(8)
    for size in range(5, 9):
        rates, free_rates, unguarded_gap = {}, {}, 0
        for i, seq in enumerate(by_size[size]):
            steps = [("mesh", t) for t in seq]
            top, res = rate_of(lambda f: grown("mesh", steps, f=f))
            rates[top] = rates.get(top, 0) + 1
            for f, r in zip((1, 2, 3, 4), res):
                case(f"c1/n{size}/{i + 1}/f{f}", grown("mesh", steps, f=f))
            top2, res2 = rate_of(lambda f: grown("mesh", steps, guard=False, f=f))
            free_rates[top2] = free_rates.get(top2, 0) + 1
            all_late = any(all(x not in BASE for x in t) for t in seq)
            if (top2 == 0) != all_late:
                unguarded_gap += 1
            for f, r in zip((1, 2, 3, 4), res2):
                case(f"c1/n{size}/{i + 1}/any-order/f{f}", grown("mesh", steps, guard=False, f=f))
        print(f"    {size} monitors: {len(by_size[size])} systems up to renaming. "
              f"Joining after its three: rate {dict(sorted(rates.items()))}. "
              f"Joining in any order: rate {dict(sorted(free_rates.items()))} "
              f"(gap at f=1 exactly where a monitor's three are all late: {'yes' if not unguarded_gap else 'NO'})")

    print("\n  C2. Way two: each new monitor attached to any three (they need not watch each other)")
    print("      shapes: mesh = it watches and is watched by all three (it is a coordinator that checks state);")
    print("      coord-signal = a coordinator that reads signals and flags only; member-check / member-signal =")
    print("      a member of a cycle with two of them, the third as coordinator; one = one existing watcher.")
    rng = random.Random(7)
    shapes = ("mesh", "coord-signal", "member-check", "member-signal", "one")
    kept = 0
    grand = 0
    for kind in BASE_WORDS:
        base_rate = max([0] + [f for f in (1, 2, 3, 4)
                               if all(no_gap(check(base(kind, "all", g))) for g in range(1, f + 1))])
        print(f"    base {kind} (its own rate: {base_rate})")
        for shape in shapes + ("mixed",):
            counts = {}
            total = 0
            for size in (5, 6, 7, 8):
                k = size - 4
                seqs = []
                arity = 1 if shape == "one" else 3
                ordered = shape.startswith("member") or shape == "mixed"

                def choices(nodes, shape=shape, arity=arity, ordered=ordered):
                    pick = itertools.permutations if ordered else itertools.combinations
                    return list(pick(nodes, arity))
                if size <= 6 and shape != "mixed":
                    def rec(prefix):
                        if len(prefix) == k:
                            seqs.append(tuple(prefix))
                            return
                        nodes = BASE + [f"N{5 + i}" for i in range(len(prefix))]
                        for att in choices(nodes):
                            rec(prefix + [(shape, att)])
                    rec([])
                    if len(seqs) > 400:
                        seqs = rng.sample(seqs, 400)
                else:
                    for _ in range(150):
                        prefix = []
                        for i in range(k):
                            nodes = BASE + [f"N{5 + j}" for j in range(i)]
                            sh = rng.choice(shapes) if shape == "mixed" else shape
                            ar = 1 if sh == "one" else 3
                            att = tuple(rng.sample(nodes, ar))
                            prefix.append((sh, att))
                        seqs.append(tuple(prefix))
                for i, steps in enumerate(seqs):
                    top, res = rate_of(lambda f: grown(kind, list(steps), f=f))
                    counts[top] = counts.get(top, 0) + 1
                    total += 1
                    if i < 3:
                        kept += 1
                        for f, r in zip((1, 2, 3, 4), res):
                            case(f"c2/{kind}/{shape}/n{size}/{i + 1}/f{f}", grown(kind, list(steps), f=f))
            grand += total
            verdict = "all at the base's rate" if set(counts) == {base_rate} else "NOT all at the base's rate"
            print(f"      {shape:<13} {total:>5} systems of 5 to 8 monitors: rate {dict(sorted(counts.items()))}  {verdict}")

    print(f"    {grand} systems in C2, each at f = 1, 2, 3 and 4")

    print("\n  C3. Families, as far as stays cheap (base: mesh of four; joining after its three; rate, and G1/G2 at f=4)")
    fams = {
        "hub: every new monitor on M1, M2, M3": lambda n, sh: [(sh, ("M1", "M2", "M3"))] * (n - 4),
        "chain: every new monitor on the newest three": lambda n, sh: [
            (sh, tuple((BASE + [f"N{5 + j}" for j in range(i)])[-3:])) for i in range(n - 4)],
        "fan: every new monitor on K and the newest two": lambda n, sh: [
            (sh, ("K",) + tuple((BASE[:3] + [f"N{5 + j}" for j in range(i)])[-2:])) for i in range(n - 4)],
    }
    for fname, fam in fams.items():
        for shape in ("mesh", "member-signal"):
            sizes = (9, 10, 11) if fname.startswith("hub") else (9, 12, 16, 20)
            cells = []
            for n in sizes:
                steps = fam(n, shape)
                top, res = rate_of(lambda f: grown("mesh", steps, f=f))
                for f, r in zip((1, 2, 3, 4), res):
                    case(f"c3/{fname.split(':')[0]}/{shape}/n{n}/f{f}", grown("mesh", steps, f=f))
                cells.append(f"n={n}: rate {top}, f=4 {short(res[3])}")
            print(f"    {fname}, shape {shape}: " + "; ".join(cells))

    print("\n  C4. The same grown systems with every monitor present from the start (way one, 5 to 7 monitors)")
    print("      rate by what W takes its halt from; f tried up to the number of monitors")
    for size in (5, 6, 7):
        out = {"base four": {}, "every monitor": {}}
        for i, seq in enumerate(by_size[size]):
            for wname in out:
                def build(f, seq=seq, wname=wname):
                    d = static(grown("mesh", [("mesh", t) for t in seq], f=f))
                    if wname == "every monitor":
                        d["halt_inputs"]["W"] = list(d["monitors"])
                    return d
                top = 0
                for f in range(1, size + 1):
                    r = chk(build(f))
                    if f <= 4 or f >= size - 1:
                        case(f"c4/n{size}/{i + 1}/{wname.replace(' ', '-')}/f{f}", build(f))
                    if not no_gap(r):
                        break
                    top = f
                out[wname][top] = out[wname].get(top, 0) + 1
        print(f"    {size} monitors: W reads the base four: rate {out['base four']}; "
              f"W reads every monitor: rate {out['every monitor']}")

    print("\n  C6. A chain of monitors with one watcher each: N5 on M1, N6 on N5, N7 on N6 (f = 1, 2, 3)")
    chain = [("one", ("M1",)), ("one", ("N5",)), ("one", ("N6",))]

    def chain_minus(f, kind=None, at="N6", arr=True):
        d = grown("mesh", chain, f=f, arrive_bad=arr)
        if kind:
            x = {"N5": "M1", "N6": "N5", "N7": "N6"}[at]
            rel, key, m = triple(at, kind, x)
            drop(d, rel, key, m)
            d["name"] += f", minus: {words(at, kind, x)}"
        return d
    print(f"    as built                                  {'  '.join(short(cas(f'c6/chain/f{f}', chain_minus(f))) for f in RATES)}")
    for at in ("N6", "N7"):
        for kind in ("in_chk", "in_hb", "out_fwd"):
            x = {"N5": "M1", "N6": "N5", "N7": "N6"}[at]
            print(f"    minus: {words(at, kind, x):<34} "
                  f"{'  '.join(short(cas(f'c6/chain-minus-{at}-{kind}/f{f}', chain_minus(f, kind, at))) for f in RATES)}")

    print("\n  C5. Is 'every monitor has two observers' the condition? (all with nothing joining)")
    for name, d, note in two_observer_cases():
        res = []
        for f in (1, 2, 3):
            t = with_f(d, f)
            res.append(short(cas(f"c5/{name}/f{f}", t)))
        print(f"    {name}: {note}")
        print(f"        fewest state checkers {least_observers(d, 'checkers')}, signal readers "
              f"{least_observers(d, 'readers')}, watchers {least_observers(d)}; Theorem S (a)-(d) "
              f"{'hold' if theorem_s(d) else 'fail'}; f=1,2,3: {'  '.join(res)}")


def two_observer_cases():
    out = []
    # X1: two watchers each, no reports, work reads two members
    d = base("cyc-check", "all")
    d["fwd"] = {}
    d["checkers"]["W"] = ["M1"]
    d["halt_inputs"]["W"] = ["M1", "M2"]
    d["name"] = "cyc-check, no reports, W reads M1 and M2"
    out.append(("two-watchers-no-reports", d,
                "cycle of three with a checking coordinator, every report removed, W checked by M1 and halting on M1 and M2"))
    # the same with W reading all four: the reflex
    d = base("cyc-check", "all")
    d["fwd"] = {}
    d["name"] = "cyc-check, no reports, W reads all four"
    out.append(("two-watchers-no-reports-W-reads-all", d,
                "the same, W halting on all four: no report is needed when the work reads every monitor"))
    # one watcher each
    d = blank("ring of three, one watcher each, W reads all three")
    for m in ("M1", "M2", "M3"):
        add_monitor(d, m)
    for a, b, c in (("M1", "M2", "M3"), ("M2", "M3", "M1"), ("M3", "M1", "M2")):
        watch(d, a, b)
        edge(d, "fwd", a, c)
    d["works"] = ["W"]
    d["checkers"]["W"] = ["M1"]
    d["halt_inputs"]["W"] = ["M1", "M2", "M3"]
    out.append(("one-watcher-each-ring-of-three", d,
                "three monitors in a cycle, each watched by one, reporting to the one it does not check, W halting on all three"))
    # two "observers", one of them a signal reader only
    d = blank("two members that check each other and a coordinator that reads signals only")
    for m in ("M1", "M2", "K"):
        add_monitor(d, m)
    mutual(d, "M1", "M2")
    for m in ("M1", "M2"):
        edge(d, "hb_readers", m, "K")
        edge(d, "fwd", m, "K")
        edge(d, "fwd", "K", m)
        watch(d, m, "K")
    d["works"] = ["W"]
    d["checkers"]["W"] = ["M1", "M2"]
    d["halt_inputs"]["W"] = ["M1", "M2", "K"]
    out.append(("two-observers-one-reads-signals-only", d,
                "M1 and M2 check each other, K reads both signals and checks no state, both watch K, W halts on all three"))
    # two rings of three joined by two reports
    d = blank("two meshes of three; A1 and B1 report to each other, A2 and B2 too; W reads ring A")
    for m in ("A1", "A2", "A3", "B1", "B2", "B3"):
        add_monitor(d, m)
    for ring in (("A1", "A2", "A3"), ("B1", "B2", "B3")):
        for a, b in itertools.combinations(ring, 2):
            mutual(d, a, b)
    for a, b in (("A1", "B1"), ("A2", "B2")):
        edge(d, "fwd", a, b)
        edge(d, "fwd", b, a)
    d["works"] = ["W"]
    d["checkers"]["W"] = ["A1", "A2", "A3"]
    d["halt_inputs"]["W"] = ["A1", "A2", "A3"]
    out.append(("two-rings-two-reports", d,
                "two meshes of three; the rings report to each other through A1-B1 and through A2-B2; W checked by and halting on ring A"))
    t = copy.deepcopy(d)
    edge(t, "fwd", "B3", "A3")
    edge(t, "fwd", "A3", "B3")
    t["name"] = "two meshes of three; each Ai and Bi report to each other; W reads ring A"
    out.append(("two-rings-three-reports", t, "the same with a third pair of reports, A3-B3"))
    t = copy.deepcopy(d)
    t["halt_inputs"]["W"] = ["A1", "A2", "A3", "B1", "B2", "B3"]
    t["name"] = "two meshes of three; two pairs of reports; W reads all six"
    out.append(("two-rings-two-reports-W-reads-all", t, "the same two pairs of reports, W halting on all six monitors"))
    return out


# ----------------------------------------------------------------------------- D

def section_d():
    print("\nD. The work processes (base: mesh of four; N in a mesh with M1, M2, M3; f = 1, 2, 3, 4;")
    print("   N arrives good | N may arrive bad)")
    t = ("M1", "M2", "M3")
    full = shape_edges("mesh", *t)

    def both(tag, build):
        cells = []
        for arr in (False, True):
            cells.append("  ".join(f"{short(cas(f'd/{tag}/{ARR[arr]}/f{f}', build(f, arr))):>5}"
                                   for f in (1, 2, 3, 4)))
        return " | ".join(cells)

    def w_plus(f, arr, halts=(), checks=(), only_halts=None, only_checks=None):
        d = one("mesh", "all", f, arr, full)
        d["halt_inputs"]["W"] = list(only_halts) if only_halts else BASE + list(halts)
        d["checkers"]["W"] = list(only_checks) if only_checks else BASE + list(checks)
        return d

    print("  the existing work process W")
    print(f"    W as before (N is nothing to it)             {both('W-plain', lambda f, a: w_plus(f, a))}")
    print(f"    N becomes a fifth halt input of W            {both('W-halt+N', lambda f, a: w_plus(f, a, halts=['N']))}")
    print(f"    N becomes a fifth checker of W               {both('W-check+N', lambda f, a: w_plus(f, a, checks=['N']))}")
    print(f"    both                                         {both('W-both+N', lambda f, a: w_plus(f, a, halts=['N'], checks=['N']))}")
    print(f"    W halts on M1, M2 and N (N is one of three)  {both('W-halt-M1M2N', lambda f, a: w_plus(f, a, only_halts=['M1', 'M2', 'N']))}")
    print(f"    W halts on M1 and N (N is one of two)        {both('W-halt-M1N', lambda f, a: w_plus(f, a, only_halts=['M1', 'N']))}")
    print(f"    W's only checker is N                        {both('W-check-N-only', lambda f, a: w_plus(f, a, only_checks=['N']))}")

    print("  a joining work process J, checked by N only, halting on N, M1, M2, M3")
    for mode, text in (("with", "J joins in N's step"), ("after", "J joins once N is present"),
                       ("free", "J may join at any time")):
        print(f"    {text:<44} {both('J-' + mode, lambda f, a, mode=mode: relied('mesh', f, a, full, t, j_mode=mode))}")
    print("  a joining work process J that may join at any time, wired to existing monitors only")
    print(f"    checked by M1, halting on M1, M2, M3, K      {both('J-free-base', lambda f, a: relied('mesh', f, a, full, t, j_mode='free', j_checkers=('M1',), j_halts=BASE))}")
    print(f"    checked by M1 and N, halting on all five     {both('J-free-base+N', lambda f, a: relied('mesh', f, a, full, t, j_mode='free', j_checkers=('M1', 'N'), j_halts=BASE + ['N']))}")

    print("  J on the i-th new ring of a system grown to eight (J joins with that ring's new monitor, is checked")
    print("  by it, and halts on it and its three); columns f = 1, 2, 3, 4, a new monitor may arrive bad")
    grow = {"chain": lambda sh: [(sh, tuple((BASE + [f"N{5 + j}" for j in range(i)])[-3:])) for i in range(4)],
            "hub": lambda sh: [(sh, ("M1", "M2", "M3"))] * 4}
    for gname, steps_of in grow.items():
        for shape in ("mesh", "member-check", "member-signal", "coord-signal"):
            cells = []
            for i in range(4):
                def build(f, i=i, shape=shape, steps_of=steps_of):
                    steps = steps_of(shape)
                    d = grown("mesh", steps, f=f)
                    n = f"N{5 + i}"
                    d["joiner"] = "J"
                    d["checkers"]["J"] = [n]
                    d["halt_inputs"]["J"] = [n] + list(steps[i][1])
                    next(g for g in d["late"] if g["name"] == n)["members"].append("J")
                    d["name"] += f", J on {n}"
                    return d
                cells.append(" ".join(short(cas(f"d/J-deep/{gname}/{shape}/ring{i + 1}/f{f}", build(f)))
                                      for f in (1, 2, 3, 4)))
            print(f"    {gname:<5} {shape:<13} " + " | ".join(f"ring {i + 1}: {c}" for i, c in enumerate(cells)))
    print("  how many monitors N is attached to, when J reads only N's ring (J joins with N, checked by N)")
    for k in (1, 2, 3, 4):
        att = tuple(BASE[:k])
        es = [(kk, x) for x in att for kk in KINDS]
        print(f"    N in a mesh with {k}: J halts on N and those {k}      "
              f"{both(f'J-ring-of-{k + 1}', lambda f, a, es=es, att=att: relied('mesh', f, a, es, att))}")


# ----------------------------------------------------------------------------- E

def ring_join(mode, f, arr, b_shape="mesh", on=("M1", "M2", "K"), boundaries=False,
              a_kind="mesh"):
    """Base ring A (M1, M2, M3, K with work W) and a second ring B (B1, B2, B3, KB with
    work WB) that joins by its coordinator KB being put in a mesh with three monitors of A.

    mode: "one-step"       the four monitors and WB join in one step
          "ring-then-work" the four monitors in one step; WB by a later step of its own
          "work-free"      the four monitors in one step; WB may join at any time
          "five-steps"     KB first, then each member once KB is present, then WB once all
                           four are present
          "members-first"  each of the five by its own step, in any order
          "work-early"     as five-steps, but WB may join as soon as KB is present
    """
    d = base(a_kind, "all", f)
    ring = ["B1", "B2", "B3", "KB"]
    for m in ring:
        add_monitor(d, m)
    if b_shape == "mesh":
        for a, b in itertools.combinations(ring, 2):
            mutual(d, a, b)
    else:                                   # cycle of three with a checking coordinator
        ms = ring[:3]
        for i, m in enumerate(ms):
            watch(d, m, ms[(i + 1) % 3])
            edge(d, "fwd", m, ms[i - 1])
            mutual(d, m, "KB")
    for x in on:
        mutual(d, "KB", x)
    d["joiner"] = "WB"
    d["checkers"]["WB"] = list(ring)
    d["halt_inputs"]["WB"] = list(ring)
    if mode == "one-step":
        d["late"] = [{"name": "B", "members": ring + ["WB"], "after": []}]
    elif mode == "ring-then-work":
        d["late"] = [{"name": "B", "members": list(ring), "after": []},
                     {"name": "WB", "members": ["WB"], "after": list(ring)}]
    elif mode == "work-free":
        d["late"] = [{"name": "B", "members": list(ring), "after": []}]
    elif mode in ("five-steps", "work-early"):
        d["late"] = [{"name": "KB", "members": ["KB"], "after": []}]
        d["late"] += [{"name": m, "members": [m], "after": ["KB"]} for m in ring[:3]]
        d["late"].append({"name": "WB", "members": ["WB"],
                          "after": list(ring) if mode == "five-steps" else ["KB"]})
    elif mode == "members-first":
        d["late"] = [{"name": m, "members": [m], "after": []} for m in ring + ["WB"]]
    else:
        raise ValueError(mode)
    if boundaries:
        d["boundary"] = {m: ("B" if m in ring else "A") for m in d["monitors"]}
    d["arrive_bad"] = arr
    d["name"] = (f"ring A ({a_kind}) and joining ring B ({b_shape}), KB on {','.join(on)}, {mode}"
                 + (", each ring in one boundary" if boundaries else ""))
    return d


def section_e():
    print("\nE. A joiner that is itself a ring")
    print("   Ring A: M1, M2, M3, K and work W. Ring B: B1, B2, B3, KB and work WB, which only ring B checks")
    print("   and halts. KB is put in a mesh with three monitors of A.   f = 1, 2, 3, 4;")
    print("   members arrive good | one member may arrive bad")

    def both(tag, build, rates=(1, 2, 3, 4)):
        cells = []
        for arr in (False, True):
            cells.append("  ".join(f"{short(cas(f'e/{tag}/{ARR[arr]}/f{f}', build(f, arr))):>5}"
                                   for f in rates))
        return " | ".join(cells)

    texts = {"one-step": "all of ring B and WB in one step",
             "ring-then-work": "the four monitors in one step, then WB",
             "work-free": "the four monitors in one step; WB at any time",
             "five-steps": "KB, then each member, then WB (five steps)",
             "work-early": "KB, then members and WB in any order",
             "members-first": "all five in any order"}
    for a_kind, b_shape, on in (("mesh", "mesh", ("M1", "M2", "K")), ("mesh", "mesh", ("M1", "M2", "M3")),
                                ("cyc-check", "cyc-check", ("M1", "M2", "K"))):
        print(f"  ring A {a_kind}, ring B {b_shape}, KB with {', '.join(on)}")
        for mode, text in texts.items():
            tag = f"{a_kind}-{b_shape}-{''.join(on)}/{mode}"
            print(f"    {text:<46} {both(tag, lambda f, a, mode=mode: ring_join(mode, f, a, b_shape, on, a_kind=a_kind))}")
    print("  each ring whole in one boundary (one step stops a whole ring); ring A mesh, ring B mesh, KB with M1, M2, K")
    for mode in ("one-step", "five-steps"):
        print(f"    {texts[mode]:<46} {both('boundaries/' + mode, lambda f, a, mode=mode: ring_join(mode, f, a, boundaries=True), rates=(1, 2))}   (f = 1, 2)")
    print("  the same two rings, each whole in one boundary, both present from the start")
    for a_kind, b_shape in (("mesh", "mesh"), ("cyc-check", "cyc-check")):
        def build(f, a, a_kind=a_kind, b_shape=b_shape):
            d = static(ring_join("one-step", f, False, b_shape, boundaries=True, a_kind=a_kind))
            d["works"].append("WB")
            d["joiner"] = None
            return d
        print(f"    ring A {a_kind}, ring B {b_shape}: f = 1, 2: "
              f"{'  '.join(short(cas(f'e/static-boundaries/{a_kind}/f{f}', build(f, False))) for f in (1, 2))}")
    print("  KB attached by fewer edges (one step, ring A mesh, ring B mesh)")

    def with_edges(f, a, edges, b_shape="mesh", a_kind="mesh"):
        d = ring_join("one-step", f, a, b_shape, on=(), a_kind=a_kind)
        for k, x in sorted(edges, key=lambda e: (KINDS.index(e[0]), BASE.index(e[1]))):
            rel, key, m = triple("KB", k, x)
            edge(d, rel, key, m)
        d["name"] = f"ring A ({a_kind}) and joining ring B ({b_shape}), one step, KB: {label(edges)}"
        return d
    one_mesh = [(k, "M1") for k in KINDS]
    print(f"    {'KB in a mesh with M1 only (six edges)':<46} {both('mesh-with-one', lambda f, a: with_edges(f, a, one_mesh))}")
    for label_, kinds in (("KB watched by M1 and reporting to M1 only", None),):
        def build(f, a):
            d = ring_join("one-step", f, a, on=())
            for k, x in shape_edges("one", "M1"):
                rel, key, m = triple("KB", k, x)
                edge(d, rel, key, m)
            d["name"] += ", KB watched by M1 and reporting to M1 only"
            return d
        print(f"    {label_:<46} {both('one-edge', build)}")

    def build_none(f, a):
        d = ring_join("one-step", f, a, on=())
        d["name"] += ", not attached at all"
        return d
    print(f"    {'ring B not attached to ring A at all':<46} {both('unattached', build_none)}")
    print("  the least attachments of KB with no gap (one step; WB is ring B's own work)")
    print("  'all 24': every edge between KB and the four monitors of A may be used. 'on M1': A's check of KB,")
    print("  A's read of KB's signal and KB's report to A are taken on M1 only (15 edges), which keeps the search small.")
    on_m1 = [e for e in UNIVERSE if e[0] in ("out_chk", "out_hb", "in_fwd") or e[1] == "M1"]
    plan = [("mesh", "mesh", 1, False, UNIVERSE), ("mesh", "mesh", 1, True, UNIVERSE),
            ("mesh", "mesh", 2, True, UNIVERSE), ("mesh", "mesh", 2, True, on_m1),
            ("mesh", "mesh", 3, True, on_m1),
            ("cyc-check", "cyc-check", 1, True, on_m1), ("cyc-check", "cyc-check", 2, True, on_m1),
            ("cyc-check", "cyc-check", 3, True, on_m1)]
    for a_kind, b_shape, f, arr, uni in plan:
        def good(s, f=f, arr=arr, a_kind=a_kind, b_shape=b_shape):
            return no_gap(chk(with_edges(f, arr, s, b_shape, a_kind)))
        least, most, tests = least_sets(uni, good)
        scope = "all 24" if len(uni) == 24 else "on M1"
        print(f"    ring A {a_kind}, ring B {b_shape}, f={f}, members arrive {ARR[arr]}, {scope} "
              f"({tests} systems checked; {len(least)} least, {len(most)} greatest with a gap)")
        for line in describe(least):
            print(f"        {line}")
        tag = f"{a_kind}/{scope.replace(' ', '-')}/{ARR[arr]}/f{f}"
        for i, s in enumerate(most):
            cas(f"e/least/{tag}/greatest-gap-{i + 1}", with_edges(f, arr, s, b_shape, a_kind))
        for i, s in enumerate(sorted(least, key=lambda s: (len(s), label(s)))[:6]):
            cas(f"e/least/{tag}/least-{i + 1}", with_edges(f, arr, s, b_shape, a_kind))


# ----------------------------------------------------------------------------- F

def measures(d):
    """Counts on the whole graph of a system (every late monitor counted)."""
    mons = d["monitors"]
    deg = {m: 0 for m in mons}
    for rel in ("hb_readers", "checkers", "fwd"):
        for k, v in d[rel].items():
            if k in deg:
                for m in v:
                    if m != k:
                        deg[k] += 1
                        deg[m] += 1
    und = {m: set() for m in mons}
    for rel in ("hb_readers", "checkers", "fwd"):
        for k, v in d[rel].items():
            if k in und:
                for m in v:
                    und[k].add(m)
                    und[m].add(k)
    # report hops from each monitor to the nearest halt input of W
    halts = set(d["halt_inputs"]["W"])
    hops = {}
    for m in mons:
        seen, frontier, n = {m}, [m], 0
        while frontier and not seen & halts:
            n += 1
            frontier = [r for x in frontier for r in d["fwd"].get(x, []) if r not in seen]
            seen.update(frontier)
        hops[m] = n if seen & halts else None
    # hops from a watcher of each monitor
    far = 0
    for z in mons:
        ws = [m for m in d["checkers"].get(z, []) if m != z]
        best = min((hops[w] for w in ws if hops[w] is not None), default=None)
        far = max(far, best if best is not None else 99)
    return {"edges": sum(deg.values()) // 2, "max_deg": max(deg.values()),
            "mean_deg": sum(deg.values()) / len(mons),
            "max_neighbours": max(len(v) for v in und.values()),
            "w_reads": len(halts), "far": far}


def section_f():
    print("\nF. Cost: what stays bounded as a system grows, and what grows")
    print("   edges = signal reads + state checks + reports, each counted once; 'edges at a monitor' counts")
    print("   every edge it is an end of; 'hops' = the most report hops from a checker of any monitor to a halt")
    print("   input of W (0: W reads a checker of every monitor directly). W always reads the base four.")
    fams = {
        "hub (always M1, M2, M3)": lambda n, sh: [(sh, ("M1", "M2", "M3"))] * (n - 4),
        "chain (the newest three)": lambda n, sh: [
            (sh, tuple((BASE + [f"N{5 + j}" for j in range(i)])[-3:])) for i in range(n - 4)],
        "fan (K and the newest two)": lambda n, sh: [
            (sh, ("K",) + tuple((BASE[:3] + [f"N{5 + j}" for j in range(i)])[-2:])) for i in range(n - 4)],
    }
    for shape in ("mesh", "coord-signal", "member-check", "member-signal", "one"):
        print(f"  shape {shape}")
        for fname, fam in fams.items():
            cells = []
            for n in (8, 16, 32, 64):
                steps = fam(n, shape)
                if shape == "one":
                    steps = [(s, att[-1:]) for s, att in steps]
                m = measures(grown("mesh", steps))
                cells.append(f"n={n}: edges {m['edges']}, most at one monitor {m['max_deg']}, "
                             f"mean {m['mean_deg']:.1f}, hops {m['far']}")
            print(f"    {fname:<27} " + " | ".join(cells))

    print("\n  When a report takes a round (slow reports), f = 1, way one, every system of 5 to 8 monitors:")
    by_size = way_one(8)
    for size in range(5, 9):
        gap = agree = 0
        for i, seq in enumerate(by_size[size]):
            d = grown("mesh", [("mesh", t) for t in seq], f=1)
            d["slow_reports"] = True
            d["name"] += ", slow reports"
            r = cas(f"f/slow/n{size}/{i + 1}/f1", d)
            far = any(all(x not in BASE for x in t) for t in seq)
            gap += not no_gap(r)
            agree += (not no_gap(r)) == far
        print(f"    {size} monitors: {gap} of {len(by_size[size])} have a gap; a gap exactly where some "
              f"monitor has no base monitor among its three: {agree} of {len(by_size[size])} agree")
    d = grown("mesh", [("mesh", ("M1", "M2", "M3")), ("mesh", ("N5", "M1", "M2")),
                       ("mesh", ("N5", "N6", "M1")), ("mesh", ("N5", "N6", "N7"))], f=1)
    d["slow_reports"] = True
    d["halt_inputs"]["W"] = list(d["monitors"])
    d["name"] += ", slow reports, W reads every monitor"
    print(f"    the chain of 8 with W taking its halt from all eight: {fmt(cas('f/slow/chain8-W-reads-all/f1', d))}")

    print("\n  Restarting (the game of results.md section 10.3; K can start first; a monitor is observed")
    print("  by whoever checks its state or reads its signal)")
    for name, steps in (
            ("mesh of four", []),
            ("way one, 8 monitors, chain", [("mesh", ("M1", "M2", "M3")), ("mesh", ("N5", "M1", "M2")),
                                            ("mesh", ("N5", "N6", "M1")), ("mesh", ("N5", "N6", "N7"))]),
            ("member-signal, 7 monitors, chain", [("member-signal", ("M1", "M2", "M3")),
                                                  ("member-signal", ("N5", "M1", "M2")),
                                                  ("member-signal", ("N6", "N5", "M1"))]),
            ("one watcher each, 7 monitors, chain", [("one", ("M1",)), ("one", ("N5",)), ("one", ("N6",))]),
            ("N5 with no edge at all", [("none", ())])):
        if steps and steps[0][0] == "none":
            d = base("mesh")
            add_late(d, "N5", [])
        else:
            d = grown("mesh", steps)
        obs = {m: sorted(v["either"]) for m, v in observers(d).items()}
        stuck, states = ref.restart_game(obs, ("K",))
        print(f"    {name:<38} ({states} states): "
              + ("can always restart" if stuck is None else "cannot restart after: " + ", ".join(stuck)))


# ----------------------------------------------------------------------------- T

def mutual_graph(d):
    """Pairs of monitors that watch each other and report to each other."""
    pairs = set()
    for a, b in itertools.combinations(d["monitors"], 2):
        if (a in d["hb_readers"].get(b, []) and a in d["checkers"].get(b, [])
                and b in d["hb_readers"].get(a, []) and b in d["checkers"].get(a, [])
                and b in d["fwd"].get(a, []) and a in d["fwd"].get(b, [])):
            pairs.add((a, b))
    return pairs


def is_plain_join(d):
    """Plain in the sense of Theorem S, except that processes may be late; no slow edge."""
    ids = [json.dumps(d["boundary"].get(m, ["own", m])) for m in d["monitors"]]
    return (not d["substrate"] and not d["switches"] and len(set(ids)) == len(ids)
            and d["coupling"] and d["window"] == 0 and d.get("gate", True)
            and not d.get("slow_reports", False) and not d.get("slow_edges"))


def theorem_j(d):
    """Theorem J's conditions at the system's f."""
    if not is_plain_join(d):
        return False
    pairs = mutual_graph(d)
    late = {p for g in d.get("late", []) for p in g["members"]}
    if len([m for m in d["monitors"] if m not in late]) <= d["f"]:
        return False
    for present in join_states(d):
        here = set(present)
        mons = [m for m in d["monitors"] if m in here]
        seen, stack = {mons[0]}, [mons[0]]
        while stack:
            x = stack.pop()
            for a, b in pairs:
                for u, v in ((a, b), (b, a)):
                    if u == x and v in here and v not in seen:
                        seen.add(v)
                        stack.append(v)
        if len(seen) != len(mons):
            return False
        for w in present:
            if w in d["monitors"]:
                continue
            if not [m for m in d["checkers"].get(w, []) if m in here]:
                return False
            if len({m for m in d["halt_inputs"].get(w, []) if m in here}) <= d["f"]:
                return False
    return True


BASE_MEMO = {}


def theorem_l(d):
    """Theorem L's conditions at the system's f."""
    if not is_plain_join(d) or d.get("joiner") is not None:
        return False
    late = {p for g in d.get("late", []) for p in g["members"]}
    initial = [m for m in d["monitors"] if m not in late]
    b = restricted(d, initial + d["works"])
    b["f"] = d["f"]
    key = json.dumps(b, sort_keys=True)
    if key not in BASE_MEMO:
        ok = responds_at_once(b)
        for m in initial:                   # a flag at any base monitor halts every work
            seen, stack = {m}, [m]
            while stack:
                x = stack.pop()
                for r in b["fwd"].get(x, []):
                    if r not in seen:
                        seen.add(r)
                        stack.append(r)
            if any(not seen & set(b["halt_inputs"].get(w, [])) for w in d["works"]):
                ok = False
        BASE_MEMO[key] = ok
    if not BASE_MEMO[key]:
        return False
    # Every late monitor needs a checker, a signal reader and a report target that are
    # each ranked before it and present whenever it is.
    group_of = {p: g for g in d["late"] for p in g["members"]}

    def surely_present(g):
        """The late groups that have joined whenever g may join."""
        out, stack = [], [group_of[x]["name"] for x in g.get("after", []) if x in group_of]
        names = {h["name"]: h for h in d["late"]}
        while stack:
            n = stack.pop()
            if n not in out:
                out.append(n)
                stack.extend(group_of[x]["name"] for x in names[n].get("after", [])
                             if x in group_of)
        return out

    ranked = set(initial)
    done = set()
    progress = True
    while progress:
        progress = False
        for g in d["late"]:
            if g["name"] in done:
                continue
            before = surely_present(g)
            if any(n not in done for n in before):
                continue
            avail = set(initial) | {p for h in d["late"] if h["name"] in before
                                    for p in h["members"]}
            placed = set()
            changed = True
            while changed:
                changed = False
                for m in g["members"]:
                    if m not in placed and (set(d["checkers"].get(m, [])) & (avail | placed)
                                            and set(d["hb_readers"].get(m, [])) & (avail | placed)
                                            and set(d["fwd"].get(m, [])) & (avail | placed)):
                        placed.add(m)
                        changed = True
            if len(placed) == len(g["members"]):
                ranked |= placed
                done.add(g["name"])
                progress = True
    return len(done) == len(d["late"])


def theorem_f(d):
    """Theorem F's conditions at the system's f, for a system with nothing late."""
    if not is_plain_join(d) or d.get("late") or d.get("joiner") is not None:
        return False
    f, mons = d["f"], d["monitors"]
    obs = observers(d)
    if any(len(v["checkers"]) < f or len(v["readers"]) < f for v in obs.values()):
        return False
    if any(not d["checkers"].get(w) for w in d["works"]):
        return False
    for k in range(0, f + 1):
        for faulty in itertools.combinations(mons, k):
            fs = set(faulty)
            for start in mons:
                if start in fs:
                    continue
                seen, stack = {start}, [start]
                while stack:
                    x = stack.pop()
                    for r in d["fwd"].get(x, []):
                        if r not in seen and r not in fs:
                            seen.add(r)
                            stack.append(r)
                for w in d["works"]:
                    if not (seen & set(d["halt_inputs"].get(w, []))) - fs:
                        return False
    return True


def section_t():
    print("\nT. The theorems against the search")
    seen = set()
    systems = []
    for d, r in TALLY:
        key = json.dumps(d, sort_keys=True)
        if key not in seen:
            seen.add(key)
            systems.append((d, r))
    print(f"   {len(systems)} different systems were checked in the sections above.")
    for name, test in (("Theorem J (a connected mutual graph)", theorem_j),
                       ("Theorem L (layered growth)", theorem_l),
                       ("Theorem F (f watchers and f + 1 report paths; nothing joining)", theorem_f)):
        tally = {(True, True): 0, (True, False): 0, (False, True): 0, (False, False): 0}
        for d, r in systems:
            tally[(bool(test(d)), no_gap(r))] += 1
        print(f"   {name}")
        print(f"     conditions hold, no gap:   {tally[(True, True)]}")
        print(f"     conditions hold, a gap:    {tally[(True, False)]}   (must be 0)")
        print(f"     conditions fail, no gap:   {tally[(False, True)]}")
        print(f"     conditions fail, a gap:    {tally[(False, False)]}")

    # Theorem S in every join state, f = 1
    tally = {(True, True): 0, (True, False): 0, (False, True): 0, (False, False): 0}
    for d, r in systems:
        if d["f"] == 1 and is_plain_join(d):
            tally[(theorem_s_every_join_state(d), no_gap(r))] += 1
    print("   Theorem S's conditions (a)-(d) in every set of present processes the joins can reach, f = 1")
    print(f"     conditions hold, no gap:   {tally[(True, True)]}")
    print(f"     conditions hold, a gap:    {tally[(True, False)]}   (must be 0)")
    print(f"     conditions fail, no gap:   {tally[(False, True)]}")
    print(f"     conditions fail, a gap:    {tally[(False, False)]}")

    # Lemma M: adding an edge never opens a gap and never shortens a violation
    rng = random.Random(11)
    worse = pairs = 0
    pool = [d for d, _ in systems if d.get("window", 0) == 0]
    for _ in range(6000):
        d = copy.deepcopy(rng.choice(pool))
        rel = rng.choice(RELATIONS)
        key = rng.choice(d["monitors"] + (d["works"] if rel in ("checkers", "halt_inputs") else []))
        if rel == "halt_inputs" and key in d["monitors"]:
            continue
        m = rng.choice(d["monitors"])
        if m == key or m in d[rel].get(key, []):
            continue
        before = check(d)
        edge(d, rel, key, m)
        after = check(d)
        pairs += 1
        for b, a in zip(before, after):
            if (a is not None) and (b is None or a < b):
                worse += 1
    print(f"   Lemma M: {pairs} systems with one random edge added: a result got worse in {worse}   (must be 0)")

    # never joining: the grown system is no better than its base
    worse = n = 0
    for d, r in systems:
        if d.get("late"):
            late = {p for g in d["late"] for p in g["members"]}
            b = restricted(d, [p for p in d["monitors"] + d["works"] if p not in late])
            b["f"] = d["f"]
            rb = check(b)
            n += 1
            for x, y in zip(r, rb):
                if y is not None and (x is None or x > y):
                    worse += 1
    print(f"   Lemma N: {n} systems with late processes against the same system with the late processes "
          f"deleted: the larger one did better in {worse}   (must be 0)")


# ----------------------------------------------------------------------------- X

def section_x():
    print("\nX. The executions of the write-up")

    def show(title, d, goal="G1", schedule=None):
        print(f"  {title}")
        print(f"    system: {d['name']}, f={d['f']}; result: {fmt(check(d))}")
        rows = run_schedule(d, schedule) if schedule else trace(d, goal)
        if rows is None:
            print("      (no execution breaks it)")
        else:
            print(show_trace(rows))

    t = ("M1", "M2", "M3")
    full = shape_edges("mesh", *t)
    rest = [e for e in full if e[0] != "in_chk"]
    show("X1. A monitor joins and nothing checks its state (the analogue of P7), f = 1",
         one("mesh", "all", 1, False, rest))
    show("     the same schedule with the checks in place", one("mesh", "all", 1, False, full),
         schedule=[[("join", "N")], [("mutate", "N")]])
    show("X2. It arrives already bad and nothing checks its state, f = 1",
         one("mesh", "all", 1, True, rest))
    show("     the same schedule with the checks in place", one("mesh", "all", 1, True, full),
         schedule=[[("join-bad", ("N", "N"))]])
    show("X3. Its attachments arrive a round late; it arrives good, f = 2",
         one("mesh", "all", 2, False, full, full))
    show("     the same schedule with the attachments in force at once", one("mesh", "all", 2, False, full),
         schedule=[[("join", "N"), ("mutate", "N")]])
    show("X4. Its attachments arrive a round late; it arrives bad, f = 1",
         one("mesh", "all", 1, True, full, full))
    steps = [("mesh", ("M1", "M2", "M3")), ("mesh", ("N5", "M1", "M2")),
             ("mesh", ("N5", "N6", "M1")), ("mesh", ("N5", "N6", "N7"))]
    show("X5. Grown to eight; the eighth may join before the three it is attached to, f = 1",
         grown("mesh", steps, guard=False, f=1, arrive_bad=False))
    show("X6. Grown to eight, joining in order: the boundary, f = 4",
         grown("mesh", steps, f=4),
         schedule=[[("mutate", "M1"), ("mutate", "M2"), ("mutate", "M3"), ("mutate", "K")]])
    show("     f = 3, the same four faults spread over two rounds",
         grown("mesh", steps, f=3),
         schedule=[[("mutate", "M1"), ("mutate", "M2"), ("mutate", "M3")], [("mutate", "K")]])
    show("X7. A joining work process that may join before the monitor that checks it, f = 1",
         relied("mesh", 1, False, full, t, j_mode="free"))
    show("X8. J reads only N's ring and N is attached to one monitor: f = 2 (G2)",
         relied("mesh", 2, False, [(k, "M1") for k in KINDS], ("M1",)), "G2")
    show("     N attached to two: f = 3 (G2)",
         relied("mesh", 3, False, [(k, x) for x in ("M1", "M2") for k in KINDS], ("M1", "M2")), "G2")
    show("X9. N is J's only checker and reports to nobody, f = 1 (G2)",
         relied("mesh", 1, False, [e for e in full if e[0] != "out_fwd"], t), "G2")
    show("X10. N is J's only checker and nobody reads N's signal, f = 1",
         relied("mesh", 1, False, [e for e in full if e[0] != "in_hb"], t))
    show("X11. J halts on N, M1, M2, M3; N is a coordinator that checks no state, f = 3 (G2)",
         relied("mesh", 3, False, shape_edges("coord-signal", *t), t), "G2")
    d = one("mesh", "all", 1, False, full)
    d["halt_inputs"]["W"] = ["M1", "N"]
    d["name"] += ", W halts on M1 and N"
    show("X11b. W takes its halt from M1 and from N, which has not joined yet, f = 1 (G2)", d, "G2")
    chain = [("one", ("M1",)), ("one", ("N5",)), ("one", ("N6",))]
    for kind, goal, text in (("in_hb", "G1", "nobody reads N6's signal"),
                             ("out_fwd", "G2", "N6 reports to nobody")):
        d = grown("mesh", chain, f=1, arrive_bad=False)
        rel, key, m = triple("N6", kind, "N5")
        drop(d, rel, key, m)
        d["name"] += f", minus: {words('N6', kind, 'N5')}"
        show(f"X11c. A chain N5 on M1, N6 on N5, N7 on N6, one watcher each; {text}, f = 1 ({goal})", d, goal)
    show("X12. A ring joins member by member, in any order, f = 1",
         ring_join("members-first", 1, False))
    show("X13. A ring joins coordinator first, and its work joins before its members, f = 1 (G2)",
         ring_join("work-early", 1, False), "G2")
    show("     and G1", ring_join("work-early", 1, False), "G1")
    d = static(ring_join("one-step", 2, False, boundaries=True))
    d["works"].append("WB")
    d["joiner"] = None
    show("X14. Two rings, each whole in one boundary, both present from the start, f = 2", d)
    show("     the same at f = 1: one ring lost in one step", with_f(d, 1),
         schedule=[[("stop-boundary", "B")]])
    d = ring_join("one-step", 1, False, on=())
    for k, x in shape_edges("one", "M1"):
        rel, key, m = triple("KB", k, x)
        edge(d, rel, key, m)
    d["name"] = "ring A (mesh) and joining ring B (mesh), one step, KB watched by M1 and reporting to M1 only"
    show("X14b. A ring with its own work joins; ring A watches KB and KB reports, and nothing "
         "comes back, f = 1 (G2)", d, "G2")
    cases = {n: d for n, d, _ in two_observer_cases()}
    show("X15. Every monitor has two watchers, no reports, W reads two members, f = 1 (G2)",
         with_f(cases["two-watchers-no-reports"], 1), "G2")
    show("X16. Two rings of three joined by two reports, f = 2 (G2)",
         with_f(cases["two-rings-two-reports"], 2), "G2")
    show("X17. Two observers, one of which reads signals only, f = 2",
         with_f(cases["two-observers-one-reads-signals-only"], 2))
    d = grown("mesh", steps, f=1, arrive_bad=False)
    d["slow_reports"] = True
    d["name"] += ", slow reports"
    show("X18. Reports take a round; grown to eight, f = 1 (G2)", d, "G2")
    show("X19. Cycle of three with a coordinator that reads signals only, f = 3",
         base("cyc-signal", "all", 3))


# ----------------------------------------------------------------------------- main

SECTIONS = [("A0", section_a0), ("A1", section_a1), ("A2", section_a2), ("B", section_b),
            ("C", section_c), ("D", section_d), ("E", section_e), ("F", section_f),
            ("T", section_t), ("X", section_x)]


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    write = "--write" in sys.argv
    start = time.time()
    for name, fn in SECTIONS:
        if write or not args or name in args:
            fn()
            sys.stdout.flush()
    print(f"\n{len(L.CATALOGUE)} cases in the catalogue; {len(L.RESULTS)} different systems checked; "
          f"{time.time() - start:.0f} s")
    if write:
        bad = 0
        t0 = time.time()
        for c in L.CATALOGUE:
            r = ref_check(c["system"])
            a = L.ANSWERS[c["id"]]
            if r != (a["G1"], a["G2"]):
                bad += 1
                print(f"  DISAGREE {c['id']}: fast_join {a}, check_model_join {r}")
        print(f"check_model_join.py on all {len(L.CATALOGUE)} catalogue cases: {bad} disagree with "
              f"fast_join.py   ({time.time() - t0:.0f} s)")
        here = os.path.dirname(os.path.abspath(__file__))
        with open(os.path.join(here, "systems-join.json"), "w", encoding="utf-8") as fh:
            fh.write("[\n" + ",\n".join(json.dumps(c) for c in L.CATALOGUE) + "\n]\n")
        with open(os.path.join(here, "results-join.json"), "w", encoding="utf-8") as fh:
            fh.write("[\n" + ",\n".join(json.dumps({"id": c["id"], **L.ANSWERS[c["id"]]})
                                        for c in L.CATALOGUE) + "\n]\n")
        print(f"wrote systems-join.json and results-join.json ({len(L.CATALOGUE)} cases)")


if __name__ == "__main__":
    main()
