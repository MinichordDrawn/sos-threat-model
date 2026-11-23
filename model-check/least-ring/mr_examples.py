#!/usr/bin/env python3
"""The small examples of model-spec-scope.md, section X13. Standard library only."""
import copy


def blank(name, f):
    return {"name": name, "f": f, "monitors": [], "works": [], "joiner": None,
            "boundary": {}, "substrate": {}, "hb_readers": {}, "checkers": {}, "fwd": {},
            "halt_inputs": {}, "switches": [], "coupling": True, "window": 0, "gate": True,
            "slow_reports": False, "late": [], "arrive_bad": False, "slow_edges": []}


def edge(d, rel, key, m):
    lst = d[rel].setdefault(key, [])
    if m not in lst:
        lst.append(m)


def mutual(d, a, b):
    for x, y in ((a, b), (b, a)):
        edge(d, "hb_readers", x, y)
        edge(d, "checkers", x, y)
        edge(d, "fwd", x, y)


def system_a(f, scoped=True, cross=True):
    d = blank("X13 A: two pairs", f)
    d["monitors"] = ["P1", "P2", "Q1", "Q2"]
    d["works"] = ["WP", "WQ"]
    d["boundary"] = {m: i + 1 for i, m in enumerate(d["monitors"])}
    mutual(d, "P1", "P2")
    mutual(d, "Q1", "Q2")
    if cross:
        mutual(d, "P1", "Q1")
    d["checkers"]["WP"] = ["P1", "P2"]
    d["halt_inputs"]["WP"] = ["P1", "P2"]
    d["checkers"]["WQ"] = ["Q1", "Q2"]
    d["halt_inputs"]["WQ"] = ["Q1", "Q2"]
    if scoped:
        d["scope"] = {"P1": "p", "P2": "p", "WP": "p", "Q1": "q", "Q2": "q", "WQ": "q"}
        d["told"] = {"p": ["Q1", "Q2"], "q": ["P1", "P2"]}
    return d


def system_b(f, cross=True, freeze=False):
    d = system_a(f, True, cross)
    d["name"] = "X13 B: two pairs and a top monitor"
    d["monitors"].append("T")
    d["boundary"]["T"] = 5
    mutual(d, "T", "P1")
    mutual(d, "T", "Q1")
    d["scope"]["T"] = "top"
    d["scope_work"] = {"top": ["WP", "WQ"]}
    if freeze:
        d["freeze"] = True
    return d


def system_c(report):
    d = blank("X13 C: one ring, the coordinator to be told", 1)
    d["monitors"] = ["A", "B", "C", "D"]
    d["works"] = ["W"]
    d["boundary"] = {m: i + 1 for i, m in enumerate(d["monitors"])}
    for x, y in (("A", "B"), ("B", "A")):
        edge(d, "checkers", x, y)
        edge(d, "hb_readers", x, y)
    edge(d, "checkers", "C", "A")
    edge(d, "checkers", "D", "A")
    if report:
        edge(d, "fwd", "A", "D")
        edge(d, "fwd", "B", "D")
    d["checkers"]["W"] = ["A", "B", "C", "D"]
    d["halt_inputs"]["W"] = ["A", "B", "C", "D"]
    d["scope"] = {p: "ring" for p in ["A", "B", "C", "D", "W"]}
    d["told"] = {"ring": ["D"]}
    return d


def examples():
    out = []
    out.append(("example/1", system_a(1)))
    out.append(("example/2", system_a(2)))
    out.append(("example/3", system_a(1, scoped=False)))
    d = system_a(1)
    d["halt_inputs"]["WQ"] = ["Q1", "Q2", "P1"]
    d["name"] += ", WQ also halting on P1"
    out.append(("example/4", d))
    out.append(("example/5", system_b(1)))
    out.append(("example/6", system_b(2, freeze=True)))
    out.append(("example/7", system_c(False)))
    out.append(("example/8", system_c(True)))
    d = system_b(2, freeze=True)
    d["max_rounds"] = 1
    d["name"] += ", executions of one round only"
    out.append(("example/9", d))
    return [(i, copy.deepcopy(d)) for i, d in out]
