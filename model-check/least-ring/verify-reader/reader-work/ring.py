"""Rings of k members and a coordinator: wirings as connections, readings, requirements."""
import itertools
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys

READINGS = {
    # (signal read, state check, report): 'f' = along the arrow (X's goes to Y / Y acts on X),
    # 'b' = against it.  For X -> Y:
    #   read  'f': Y reads X's signal     'b': X reads Y's signal
    #   check 'f': Y checks X's state     'b': X checks Y's state
    #   rep   'f': X reports to Y         'b': Y reports to X
    "flow": ("f", "f", "f"),
    "actor": ("b", "b", "f"),
}


def edges_of(arrows, reading):
    """arrows: iterable of (X, Y).  Returns sets hb, chk, fwd of pairs.
    hb: (p, r) r reads p's signal.  chk: (x, m) m checks x.  fwd: (m, r) m reports to r."""
    rd, ck, rp = reading
    hb, chk, fwd = set(), set(), set()
    for x, y in arrows:
        if "f" in rd:
            hb.add((x, y))
        if "b" in rd:
            hb.add((y, x))
        if "f" in ck:
            chk.add((x, y))
        if "b" in ck:
            chk.add((y, x))
        if "f" in rp:
            fwd.add((x, y))
        if "b" in rp:
            fwd.add((y, x))
    return hb, chk, fwd


def make_system(nodes, hb, chk, fwd, work, f, coord, first, told=True, slow=False, scoped=False):
    """work: 'all' or 'two'.  first: the member that is W's checker when the work reads two."""
    d = {"f": f, "monitors": list(nodes), "works": ["W"], "coupling": True, "window": 0,
         "boundary": {m: m for m in nodes}, "hb_readers": {}, "checkers": {}, "fwd": {},
         "halt_inputs": {}}
    for p, r in hb:
        d["hb_readers"].setdefault(p, []).append(r)
    for x, m in chk:
        d["checkers"].setdefault(x, []).append(m)
    for m, r in fwd:
        d["fwd"].setdefault(m, []).append(r)
    if work == "all":
        d["checkers"]["W"] = list(nodes)
        d["halt_inputs"]["W"] = list(nodes)
    else:
        d["checkers"]["W"] = [first]
        d["halt_inputs"]["W"] = [first, coord]
    if slow:
        d["slow_reports"] = True
    if scoped:
        d["scope"] = {x: "ring" for x in list(nodes) + ["W"]}
        d["told"] = {"ring": [coord]}
    return d


def watchers(nodes, hb, chk):
    return {z: {r for r in nodes if r != z and (z, r) in hb and (z, r) in chk} for z in nodes}


def R2(nodes, hb, chk):
    w = watchers(nodes, hb, chk)
    return all(len(w[z]) >= 2 for z in nodes)


def R3(nodes, hb, chk, coord):
    w = watchers(nodes, hb, chk)
    obs = {r: {z for z in nodes if r in w[z]} for r in nodes}   # r watches z
    seen = set()
    todo = [coord]
    while todo:
        x = todo.pop()
        for z in obs[x]:
            if z not in seen:
                seen.add(z)
                todo.append(z)
    return all(z in seen for z in nodes if z != coord)


def R5(nodes, fwd, coord):
    return all((x, coord) in fwd for x in nodes if x != coord)


def R4w_on(nodes, w):
    """w: watchers restricted to nodes."""
    if any(not w[z] for z in nodes):
        return False
    for x, y in itertools.combinations(nodes, 2):
        if w[x] <= {y} and w[y] <= {x}:
            return False
    return True


def R4w(nodes, hb, chk):
    return R4w_on(nodes, watchers(nodes, hb, chk))


def R4wl(nodes, hb, chk):
    w = watchers(nodes, hb, chk)
    for lost in nodes:
        rest = [z for z in nodes if z != lost]
        w2 = {z: w[z] - {lost} for z in rest}
        if not R4w_on(rest, w2):
            return False
    return True


def naming_search(nodes, w):
    """Brute force of the naming question under the supposition 'a correct node names the
    faulty node only if it watches it, and otherwise names nobody': does a rule exist?
    Cases: z = None or a node.  A rule exists iff no vector of names arises under two
    different z."""
    nodes = list(nodes)
    seen = {}
    for z in [None] + nodes:
        if z is None:
            vecs = [tuple(None for _ in nodes)]
        else:
            fixed = [(z if (m in w[z]) else None) if m != z else "*" for m in nodes]
            vecs = []
            for lie in [None] + nodes:
                vecs.append(tuple(lie if v == "*" else v for v in fixed))
        for v in vecs:
            if v in seen and seen[v] != z:
                return False
            seen[v] = z
    return True
