"""Specification examples: J8 (join) and X13 (scope), run through the reader's model."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys


def mutual(d, x, y):
    for a, b in ((x, y), (y, x)):
        d["hb_readers"].setdefault(a, []).append(b)
        d["checkers"].setdefault(a, []).append(b)
        d["fwd"].setdefault(a, []).append(b)


def base():
    return {"hb_readers": {}, "checkers": {}, "fwd": {}, "halt_inputs": {}, "coupling": True, "window": 0}


def exA(f, scoped=True, extra_halt=False):
    d = base()
    d.update(f=f, monitors=["P1", "P2", "Q1", "Q2"], works=["WP", "WQ"])
    d["boundary"] = {m: m for m in d["monitors"]}
    mutual(d, "P1", "P2"); mutual(d, "Q1", "Q2"); mutual(d, "P1", "Q1")
    d["checkers"]["WP"] = ["P1", "P2"]; d["halt_inputs"]["WP"] = ["P1", "P2"]
    d["checkers"]["WQ"] = ["Q1", "Q2"]; d["halt_inputs"]["WQ"] = ["Q1", "Q2"] + (["P1"] if extra_halt else [])
    if scoped:
        d["scope"] = {"P1": "p", "P2": "p", "WP": "p", "Q1": "q", "Q2": "q", "WQ": "q"}
        d["told"] = {"p": ["Q1", "Q2"], "q": ["P1", "P2"]}
    return d


def exB(f, freeze=False, max_rounds=None):
    d = exA(f)
    d["monitors"].append("T")
    d["boundary"]["T"] = "T"
    mutual(d, "T", "P1"); mutual(d, "T", "Q1")
    d["scope"]["T"] = "top"
    d["scope_work"] = {"top": ["WP", "WQ"]}
    if freeze:
        d["freeze"] = True
    if max_rounds:
        d["max_rounds"] = max_rounds
    return d


def exC(reports):
    d = base()
    d.update(f=1, monitors=["A", "B", "C", "D"], works=["W"])
    d["boundary"] = {m: m for m in d["monitors"]}
    d["scope"] = {x: "ring" for x in ["A", "B", "C", "D", "W"]}
    d["told"] = {"ring": ["D"]}
    d["checkers"] = {"W": ["A", "B", "C", "D"], "A": ["B"], "B": ["A"], "C": ["A"], "D": ["A"]}
    d["hb_readers"] = {"A": ["B"], "B": ["A"]}
    d["halt_inputs"] = {"W": ["A", "B", "C", "D"]}
    if reports:
        d["fwd"] = {"A": ["D"], "B": ["D"]}
    return d


def show(tag, d, expect):
    r = Sys(d).solve()
    r.pop("states", None)
    print(tag, r, "   EXPECT:", expect)


show("X13.1", exA(1), "G1,G2 null both; told p 2, q 2; spill null")
show("X13.2", exA(2), "p: G1 2, G2 1, told 1; same q; spill null")
show("X13.3", exA(1, scoped=False), "G1 null G2 null")
show("X13.4", exA(1, extra_halt=True), "spill 1; others as 1")
show("X13.5", exB(1), "G1,G2 null all; told p 2 q 2 top null; spill null")
show("X13.6", exB(2, freeze=True), "p,q: G1 3, G2 1, told 1; top: G1 2, G2 2, told null; spill null")
show("X13.9", exB(2, freeze=True, max_rounds=1), "p,q: G1 null, G2 1, told 1; top all null; spill null")
show("X13.7", exC(False), "G1 null G2 null told 1 spill null")
show("X13.8", exC(True), "all null")

# J8
def j8(n_edges, arrive_bad, f):
    d = base()
    ms = ["M1", "M2", "M3", "M4"]
    d.update(f=f, monitors=ms + ["N"], works=["W"], arrive_bad=arrive_bad)
    d["boundary"] = {m: m for m in ms + ["N"]}
    for i in range(4):
        for j in range(i + 1, 4):
            mutual(d, ms[i], ms[j])
    d["checkers"]["W"] = list(ms); d["halt_inputs"]["W"] = list(ms)
    d["late"] = [{"name": "N", "members": ["N"]}]
    if n_edges:
        d["checkers"]["N"] = ["M1"]
    return d

for f in (1, 2, 3):
    show("J8.1 f=%d" % f, j8(True, True, f), "null null")
show("J8.2 good f=1", j8(False, False, 1), "2 2")
show("J8.2 bad f=1", j8(False, True, 1), "1 1")
