"""Towers of candidate rings: three rings under a coordinator, recursively."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from ring import READINGS, edges_of


def ring_arrows(a, b, c, d):
    return [(a, b), (b, c), (c, a), (d, a), (d, b), (d, c), (a, d), (b, d), (c, d)]


def tower(levels):
    """Returns dict: arrows (list), rings (list of (members3, coord, kind)), works: map
    work -> its base ring's four monitors, beneath: coord -> works beneath it,
    base coordinators D1.., middle E1.., top T.  levels=1: one ring A1 B1 C1 D1."""
    arrows = []
    rings = []
    works = {}
    beneath = {}
    nb = 3 ** (levels - 1)
    for i in range(1, nb + 1):
        a, b, c, d = "A%d" % i, "B%d" % i, "C%d" % i, "D%d" % i
        arrows += ring_arrows(a, b, c, d)
        rings.append(((a, b, c), d, "base"))
        works["W%d" % i] = [a, b, c, d]
        beneath[d] = ["W%d" % i]
    cur = ["D%d" % i for i in range(1, nb + 1)]
    lvl = 2
    letters = {2: "E", 3: "F", 4: "G"}
    while len(cur) > 1:
        nxt = []
        for j in range(len(cur) // 3):
            trio = cur[3 * j:3 * j + 3]
            if len(cur) == 3:
                name = "T"
            else:
                name = "%s%d" % (letters[lvl], j + 1)
            arrows += ring_arrows(trio[0], trio[1], trio[2], name)
            rings.append((tuple(trio), name, "upper"))
            beneath[name] = sum((beneath[x] for x in trio), [])
            nxt.append(name)
        cur = nxt
        lvl += 1
    return {"arrows": arrows, "rings": rings, "works": works, "beneath": beneath}


def system(levels, reading, work, f, scoped=False, freeze=False, ring_boundaries=False,
           coord_up=False, remove=(), max_rounds=None, arrows=None, edges=None):
    """reading: name in READINGS or a triple.  remove: arrows to drop.
    coord_up: a base ring coordinator's own fault lands in the scope above it.
    edges: (hb, chk, fwd) to use instead of arrows read by `reading`."""
    t = tower(levels)
    ar = list(t["arrows"]) if arrows is None else list(arrows)
    for r in remove:
        ar.remove(r)
    if edges is None:
        rd = READINGS[reading] if isinstance(reading, str) else reading
        hb, chk, fwd = edges_of(ar, rd)
    else:
        hb, chk, fwd = edges
    mons = []
    for (mem, coord, kind) in t["rings"]:
        for x in list(mem) + [coord]:
            if x not in mons:
                mons.append(x)
    d = {"f": f, "monitors": mons, "works": list(t["works"]), "coupling": True, "window": 0,
         "hb_readers": {}, "checkers": {}, "fwd": {}, "halt_inputs": {}}
    for p, r in hb:
        d["hb_readers"].setdefault(p, []).append(r)
    for x, m in chk:
        d["checkers"].setdefault(x, []).append(m)
    for m, r in fwd:
        d["fwd"].setdefault(m, []).append(r)
    for w, four in t["works"].items():
        if work == "all":
            d["checkers"][w] = list(four)
            d["halt_inputs"][w] = list(four)
        else:
            d["checkers"][w] = [four[0]]
            d["halt_inputs"][w] = [four[0], four[3]]
    d["boundary"] = {m: m for m in mons}
    if ring_boundaries:
        for (mem, coord, kind) in t["rings"]:
            if kind == "base":
                for x in list(mem) + [coord]:
                    d["boundary"][x] = "ring-" + coord
    if scoped:
        sc = {}
        told = {}
        sw = {}
        upper_of = {}   # coordinator -> the ring above it (members, coord)
        for (mem, coord, kind) in t["rings"]:
            if kind == "upper":
                for x in mem:
                    upper_of[x] = (mem, coord)
        for (mem, coord, kind) in t["rings"]:
            sid = "s" + coord
            if kind == "base":
                for x in mem:
                    sc[x] = sid
                w = t["beneath"][coord][0]
                sc[w] = sid
                sc[coord] = sid
            else:
                sc[coord] = sid
                sw[sid] = list(t["beneath"][coord])
            if coord in upper_of:
                um, uc = upper_of[coord]
                told[sid] = [x for x in um if x != coord] + [uc]
        if coord_up:
            for (mem, coord, kind) in t["rings"]:
                if kind == "base" and coord in upper_of:
                    sc[coord] = "s" + upper_of[coord][1]
        d["scope"] = sc
        d["scope_work"] = sw
        d["told"] = told
        if freeze:
            d["freeze"] = True
    if max_rounds:
        d["max_rounds"] = max_rounds
    return d
