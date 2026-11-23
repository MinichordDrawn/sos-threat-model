#!/usr/bin/env python3
"""The catalogue of systems the results rest on, and its answers.

Writes systems-minimal.json (a list of {"id", "system"}) and results-minimal.json (the
answers of mr_model.py), in the formats of model-spec.md section 5 and
model-spec-scope.md section X12. Every system is in the specification's own fields, so an
implementation written from the three specification files can answer the catalogue.

Where exploring every reachable state is too large, the system carries `max_rounds`
(model-spec-scope.md, X10), and the answer is for executions of at most that many rounds.

Run:  python -B make_catalogue.py
"""
import copy
import itertools
import json
import os
import sys
import time

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import mr_ring as R  # noqa: E402
import mr_model as mm  # noqa: E402
import mr_tower as T  # noqa: E402
import mr_examples as X  # noqa: E402
import part_c as C  # noqa: E402
import part_d as D  # noqa: E402

CASES = []


def tidy(d):
    t = copy.deepcopy(d)
    for rel in mm.RELATIONS:
        t[rel] = {k: v for k, v in t[rel].items() if v}
    return t


def case(cid, d, max_rounds=None, name=None):
    d = tidy(d)
    if max_rounds is not None:
        d["max_rounds"] = max_rounds
    if name:
        d["name"] = name
    assert cid not in {c["id"] for c in CASES}, cid
    CASES.append({"id": cid, "system": d})


def conn_id(conns):
    return "_".join(f"{x}{y}" for x, y in sorted(conns))


def build():
    for cid, d in X.examples():
        case(cid, d)

    N4 = R.NODES4
    # ---- Part A
    for reading in R.READINGS:
        E = R.edges_of(R.CANDIDATE, reading)
        for work in ("all", "two"):
            for f in (1, 2, 3):
                case(f"a/candidate/{reading}/{work}/f{f}", R.ring_system(
                    E, N4, "D", work, f, name=f"candidate, {reading}, work reads {work}"))
        # one connection removed
        for p in R.CANDIDATE:
            Em = R.edges_of([c for c in R.CANDIDATE if c != p], reading)
            for f in (1, 2, 3):
                case(f"a/minus/{reading}/{p[0]}{p[1]}/f{f}", R.ring_system(
                    Em, N4, "D", "all", f,
                    name=f"candidate without {p[0]}->{p[1]}, {reading}, work reads all"))
        # the 19 edges on the candidate's arrows
        E19 = frozenset(C.least19(reading, ["A", "B", "C"], "D"))
        for work, fs in (("all", (1, 2, 3)), ("two", (1,))):
            for f in fs:
                case(f"a/nineteen/{reading}/{work}/f{f}", R.ring_system(
                    E19, N4, "D", work, f,
                    name=f"19 edges on the candidate's arrows, {reading}, work reads {work}"))
        # one of the 19 removed (each fails R2 or R5; none opens a gap at f = 1)
        for e in sorted(E19):
            case(f"a/nineteen-minus/{reading}/{e[0]}-{e[1]}-{e[2]}", R.ring_system(
                E19 - {e}, N4, "D", "all", 1,
                name=f"the 19 edges without {R.edge_text(e)}, {reading}, work reads all"))
    Em = R.edges_of(R.mesh_ring(N4), "flow")
    for work in ("all", "two"):
        for f in (1, 2, 3):
            case(f"a/mesh/{work}/f{f}", R.ring_system(Em, N4, "D", work, f,
                                                      name=f"mesh of four, work reads {work}"))
    least = {
        "flow": ["AB AD BA BD CA CD DA DB", "AB AD BA BD CA CD DA DC",
                 "AB AD BA BD CA CD DB DC", "AB AD BC BD CA CD DA DB"],
        "actor": ["AB AC AD BA BC BD CA CD DB", "AB AC AD BA BC BD CD DA DB",
                  "AB AC AD BA BD CA CD DB DC", "AB AC AD BA BD CB CD DA DC",
                  "AB AC AD BA BD CD DA DB DC"],
    }
    for reading, shapes in least.items():
        for i, text in enumerate(shapes, 1):
            conns = [(t[0], t[1]) for t in text.split()]
            for f in (1, 2, 3):
                case(f"a/least/{reading}/{i}/f{f}", R.ring_system(
                    R.edges_of(conns, reading), N4, "D", "all", f,
                    name=f"least wiring {i} ({R.conn_text(conns)}), {reading}, work reads all"))
            case(f"a/least/{reading}/{i}/two/f1", R.ring_system(
                R.edges_of(conns, reading), N4, "D", "two", 1,
                name=f"least wiring {i} ({R.conn_text(conns)}), {reading}, work reads two"))
    # R1 alone: the four-cycle, and the six edges kind by kind
    cyc4 = [("A", "B"), ("B", "C"), ("C", "D"), ("D", "A")]
    for reading in R.READINGS:
        for f in (1, 2, 3):
            case(f"a/r1/cycle-of-four/{reading}/f{f}", R.ring_system(
                R.edges_of(cyc4, reading), N4, "D", "all", f,
                name=f"A->B->C->D->A, {reading}, work reads all"))
    six = frozenset([("checkers", "A", "B"), ("checkers", "B", "A"), ("hb_readers", "A", "B"),
                     ("hb_readers", "B", "A"), ("checkers", "C", "A"), ("checkers", "D", "A")])
    case("a/r1/six-edges/f1", R.ring_system(six, N4, "D", "all", 1,
                                            name="R1 alone, six edges, work reads all"))
    for e in sorted(six):
        case(f"a/r1/six-edges-minus/{e[0]}-{e[1]}-{e[2]}", R.ring_system(
            six - {e}, N4, "D", "all", 1, name=f"the six edges without {R.edge_text(e)}"))
    for reading in R.READINGS:
        for label, conns in (("candidate", R.CANDIDATE), ("mesh", R.mesh_ring(N4))):
            for work in ("all", "two"):
                d = R.ring_system(R.edges_of(conns, reading), N4, "D", work, 1,
                                  name=f"{label}, {reading}, work reads {work}, reports take a round")
                d["slow_reports"] = True
                case(f"a/slow/{label}/{reading}/{work}/f1", d)

    # ---- Part B
    for k in (4, 5):
        nodes = [chr(ord("A") + i) for i in range(k)] + ["K"]
        for reading in R.READINGS:
            E = R.edges_of(R.cycle_ring(nodes[:-1], "K"), reading)
            for f in range(1, k + 2):
                case(f"b/cycle{k}/{reading}/all/f{f}", R.ring_system(
                    E, nodes, "K", "all", f,
                    name=f"cycle of {k} with a coordinator, {reading}, work reads all"))
            for f in (1, 2):
                case(f"b/cycle{k}/{reading}/two/f{f}", R.ring_system(
                    E, nodes, "K", "two", f,
                    name=f"cycle of {k} with a coordinator, {reading}, work reads two"))
    nodes = ["A", "B", "C", "D", "K"]
    E = R.edges_of(R.mesh_ring(nodes), "flow")
    for f in range(1, 6):
        case(f"b/mesh5/all/f{f}", R.ring_system(E, nodes, "K", "all", f,
                                                name="mesh of five, work reads all"))
    for f in (1, 2):
        case(f"b/mesh5/two/f{f}", R.ring_system(E, nodes, "K", "two", f,
                                                name="mesh of five, work reads two"))

    # ---- Part C: thirteen monitors as one system
    for reading in R.READINGS:
        for rb in (False, True):
            tag = "ring-boundaries" if rb else "own-boundaries"
            for f in (1, 2, 3):
                case(f"c/one/{reading}/all/{tag}/f{f}", T.tower(2, reading, "all", f, rb))
            case(f"c/one/{reading}/all/{tag}/f4", T.tower(2, reading, "all", 4, rb), max_rounds=1)
            case(f"c/one/{reading}/two/{tag}/f1", T.tower(2, reading, "two", 1, rb))
            case(f"c/one/{reading}/two/{tag}/f2", T.tower(2, reading, "two", 2, rb), max_rounds=1)
    # one connection removed, as one system and with scopes
    conns = T.connections(2)
    kinds = [("A1", "B1"), ("A1", "D1"), ("D1", "A1"), ("D1", "D2"), ("D1", "T"), ("T", "D1")]
    star = [c for c in conns if not (c[0][0] == "D" and c[1][0] == "D")]
    for reading in R.READINGS:
        for drop in kinds + ["star"]:
            c2 = star if drop == "star" else [c for c in conns if c != drop]
            tag = "no-upper-cycle" if drop == "star" else f"{drop[0]}{drop[1]}"
            E = R.edges_of(c2, reading)
            for f in (1, 2, 3):
                case(f"c/minus/{reading}/{tag}/one/f{f}", T.tower(
                    2, reading, "all", f, edges=E,
                    name=f"tower without {tag}, {reading}, as one system"), max_rounds=2)
            d = T.tower(2, reading, "all", 1, edges=E, scoped=True,
                        name=f"tower without {tag}, {reading}, scoped")
            d["freeze"] = True
            case(f"c/minus/{reading}/{tag}/scoped/f1", d)
    # with scopes
    for reading in R.READINGS:
        for work in ("all", "two"):
            for freeze in (True, False):
                tag = "freeze" if freeze else "no-freeze"
                plan = {1: None if freeze else 4, 2: 2, 3: 1}
                for f in (1, 2, 3):
                    if work == "two" and f == 3:
                        continue
                    d = T.tower(2, reading, work, f, scoped=True)
                    d["freeze"] = freeze
                    case(f"c/scoped/{reading}/{work}/{tag}/f{f}", d, max_rounds=plan[f])
        d = T.tower(2, reading, "all", 4, scoped=True)
        d["freeze"] = True
        case(f"c/scoped/{reading}/all/freeze/f4", d, max_rounds=1)
        d = T.tower(2, reading, "all", 1, scoped=True, coordinator_scope="upper")
        d["freeze"] = True
        case(f"c/scoped-coordinator-upper/{reading}/f1", d)
        d = T.tower(2, reading, "all", 1, True, scoped=True)
        d["freeze"] = True
        case(f"c/scoped-ring-boundaries/{reading}/f1", d)
    # kind by kind: 19 edges per ring
    rings, base = T.layout(2)
    for reading in R.READINGS:
        core = set()
        for lv, ms, c in rings:
            core |= C.least19(reading, ms, c)
        case(f"c/nineteen/{reading}/one/f1", T.tower(
            2, reading, "all", 1, edges=core,
            name=f"tower, 19 edges per ring, {reading}, as one system"), max_rounds=2)
        d = T.tower(2, reading, "all", 1, edges=core, scoped=True,
                    name=f"tower, 19 edges per ring, {reading}, scoped")
        d["freeze"] = True
        case(f"c/nineteen/{reading}/scoped/f1", d)
    # flat wirings
    mons = T.tower(2)["monitors"]
    others = [m for m in mons if m != "T"]
    cyc12 = [(others[i], others[(i + 1) % 12]) for i in range(12)]
    up12 = [(m, "T") for m in others]
    flats = {"f1-flow": (cyc12 + up12 + [("T", "A1"), ("T", "B1")], "flow"),
             "f2-actor": (cyc12 + up12 + [("T", m) for m in others], "actor"),
             "f4-flow": ([c for c in conns if c not in (("D1", "C1"), ("D2", "C2"),
                                                        ("D3", "C3"), ("T", "D3"))], "flow")}
    for tag, (cc, reading) in flats.items():
        for f in (1, 2, 3):
            case(f"c/flat/{tag}/f{f}", T.tower(2, reading, "all", f, edges=R.edges_of(cc, reading),
                                               name=f"flat wiring {tag}"), max_rounds=2)
    # forty monitors
    for reading in R.READINGS:
        for f in (1, 2, 3):
            case(f"c/forty/{reading}/all/one/f{f}", T.tower(3, reading, "all", f))
        case(f"c/forty/{reading}/two/one/f1", T.tower(3, reading, "two", 1))
        d = T.tower(3, reading, "all", 1, scoped=True)
        d["freeze"] = True
        case(f"c/forty/{reading}/all/scoped/f1", d, max_rounds=3)

    # ---- Part D: growth
    full = {"top-first", "top-first-loose", "whole-top-first"}
    for order in D.ORDERS:
        for reading in R.READINGS:
            for f in (1, 2, 3):
                case(f"d/grow/{order}/{reading}/one/f{f}", D.growing(reading, order, f),
                     max_rounds=None if order in full else 2)
            d = D.growing(reading, order, 1, scoped=True)
            case(f"d/grow/{order}/{reading}/scoped/f1", d)
            case(f"d/grow/{order}/{reading}/scoped/f2", D.growing(reading, order, 2, scoped=True),
                 max_rounds=2)
    # the fifth node
    nodes5 = N4 + ["N"]
    att = {"flow": {"none": [], "NA": [("N", "A")], "ND": [("N", "D")],
                    "NA_ND": [("N", "A"), ("N", "D")], "NA_NB": [("N", "A"), ("N", "B")]},
           "actor": {"none": [], "AN": [("A", "N")], "ND": [("N", "D")],
                     "AN_BN_ND": [("A", "N"), ("B", "N"), ("N", "D")],
                     "AN_DN_ND": [("A", "N"), ("D", "N"), ("N", "D")],
                     "AN_ND": [("A", "N"), ("N", "D")]}}
    for reading, table in att.items():
        for tag, cc in table.items():
            for f in (1, 2, 3):
                E = R.edges_of(R.CANDIDATE, reading) | R.edges_of(cc, reading)
                d = R.ring_system(E, nodes5, "D", "all", f,
                                  name=f"candidate and a fifth node N ({R.conn_text(cc) or 'no connection'}), {reading}")
                d["checkers"]["W"] = list(N4)
                d["halt_inputs"]["W"] = list(N4)
                d["late"] = [{"name": "N", "members": ["N"], "after": []}]
                d["arrive_bad"] = True
                case(f"d/fifth/{reading}/{tag}/f{f}", d)
        five = [("checkers", "N", "A"), ("checkers", "N", "D"), ("hb_readers", "N", "A"),
                ("hb_readers", "N", "D"), ("fwd", "N", "D")]
        for drop in [None] + five:
            E = R.edges_of(R.CANDIDATE, reading) | frozenset(e for e in five if e != drop)
            d = R.ring_system(E, nodes5, "D", "all", 1,
                              name=f"candidate and N by five edges"
                                   + (f" without {R.edge_text(drop)}" if drop else "") + f", {reading}")
            d["checkers"]["W"] = list(N4)
            d["halt_inputs"]["W"] = list(N4)
            d["late"] = [{"name": "N", "members": ["N"], "after": []}]
            d["arrive_bad"] = True
            case(f"d/fifth/{reading}/five-edges" + (f"-minus-{drop[0]}-{drop[1]}-{drop[2]}" if drop else ""), d)


def main():
    build()
    print(len(CASES), "cases")
    answers = []
    failed = []
    t0 = time.time()
    for i, c in enumerate(CASES):
        t1 = time.time()
        try:
            a = mm.answer(c["system"], max_states=1200000)
        except RuntimeError:
            print(f"TOO LARGE without a bound on rounds: {c['id']}", flush=True)
            failed.append(c["id"])
            continue
        answers.append({"id": c["id"], **a})
        if time.time() - t1 > 20:
            print(f"   {c['id']}: {time.time() - t1:.0f} s", flush=True)
    if failed:
        print(f"{len(failed)} cases too large; nothing written")
        return
    with open(os.path.join(HERE, "systems-minimal.json"), "w", encoding="utf-8") as fh:
        fh.write("[\n" + ",\n".join(json.dumps(c) for c in CASES) + "\n]\n")
    with open(os.path.join(HERE, "results-minimal.json"), "w", encoding="utf-8") as fh:
        fh.write("[\n" + ",\n".join(json.dumps(a) for a in answers) + "\n]\n")
    print(f"wrote {len(CASES)} cases and answers in {time.time() - t0:.0f} s")


if __name__ == "__main__":
    main()
