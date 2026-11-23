"""Sanity: J8 examples (under three readings of N's boundary) and the base rings of section 2."""
from build import *

print("== J8 examples; N boundary: own / none / shared with M1")
def j8(f, edge, slow, arrive_bad, nb):
    s = base_mesh(f, names=("M1", "M2", "M3", "M4"))
    s["monitors"].append("N")
    if nb == "own":
        s["boundary"]["N"] = "b_N"
    elif nb == "shared":
        s["boundary"]["N"] = "b_M1"
    late_group(s, "N", ["N"])
    s["arrive_bad"] = arrive_bad
    if edge:
        add(s, "checkers", "N", "M1")
        if slow:
            s["slow_edges"] = [["checkers", "N", "M1"]]
    return s

expect = [
    ("ex1 f=1 ab", (1, True, False, True), "null/null"),
    ("ex1 f=2 ab", (2, True, False, True), "null/null"),
    ("ex1 f=3 ab", (3, True, False, True), "null/null"),
    ("ex2 f=1 good", (1, False, False, False), "2/2"),
    ("ex2 f=1 ab", (1, False, False, True), "1/1"),
    ("ex3 f=1 good", (1, True, True, False), "null/null"),
    ("ex3 f=2 good", (2, True, True, False), "1/1"),
    ("ex3 f=1 ab", (1, True, True, True), "1/1"),
]
for name, args, exp in expect:
    row = []
    for nb in ("own", "none", "shared"):
        r = both(j8(*args, nb))
        row.append(fmt(r))
    print("  %-14s spec says %-9s computed own/none/shared: %s" % (name, exp, row))

print("== base rings, W reads all: rate (section 2 says 3, 3, 2, 2)")
def rate_of(mk, fs=(1, 2, 3, 4)):
    out = []
    for f in fs:
        r = both(mk(f))
        out.append(fmt(r))
    return out
print("  mesh", rate_of(lambda f: base_mesh(f)))
for c in ("checking", "reading", "nested"):
    print("  cycle", c, rate_of(lambda f: base_cycle(f, c)))
