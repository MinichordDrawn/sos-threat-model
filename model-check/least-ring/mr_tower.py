#!/usr/bin/env python3
"""Rings of rings: the candidate ring repeated one level up, and again. Standard library.

levels 1: one ring, A1 B1 C1 with coordinator D1, and work W1 (4 monitors).
levels 2: three rings and a top coordinator T (13 monitors): the three ring coordinators
          D1, D2, D3 are the members of the upper ring, T its coordinator.
levels 3: nine rings, three middle coordinators E1, E2, E3 and T (40 monitors).

Every ring has the candidate's nine connections: its members in a cycle, its coordinator
connected to each member both ways. A connection carries edges under a reading
(mr_ring.bundle).
"""
import itertools
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import mr_ring as R  # noqa: E402


def layout(levels):
    """(rings, base) for a tower. rings: list of (level, members, coordinator), base rings
    first. base: list of (ring number, members, coordinator, work)."""
    rings = []
    count = [0]
    upper = {2: "D", 3: "E", 4: "F", 5: "G"}

    def build(level, top):
        if level == 1:
            count[0] += 1
            i = count[0]
            ms, d = [f"A{i}", f"B{i}", f"C{i}"], f"D{i}"
            rings.append((1, ms, d))
            return d
        subs = [build(level - 1, False) for _ in range(3)]
        if top:
            c = "T"
        else:
            n = sum(1 for lv, _, _ in rings if lv == level) + 1
            c = f"{upper[level + 1]}{n}"
        rings.append((level, subs, c))
        return c

    if levels == 1:
        build(1, True)
    else:
        build(levels, True)
    base = [(int(d[1:]), ms, d, f"W{d[1:]}") for lv, ms, d in rings if lv == 1]
    rings.sort(key=lambda r: r[0])
    return rings, base


def connections(levels):
    rings, _ = layout(levels)
    conns = []
    for _, ms, c in rings:
        conns += R.cycle_ring(ms, c)
    return conns


def tower(levels, reading="flow", work="all", f=1, ring_boundaries=False, scoped=False,
          coordinator_scope="own", edges=None, name=None):
    """The tower as a system of the specification.

    work "all": each base ring's work is checked by its four monitors and takes its halt
    from the four. work "two": checked by the ring's first member, halting on it and on the
    ring's coordinator.
    ring_boundaries: each base ring whole in one boundary.
    scoped: a scope per base ring (its four monitors and its work) and a scope per upper
    coordinator (that coordinator; its work is all the work beneath it). For each scope
    the monitors to be told are the other monitors of the ring above its coordinator.
    coordinator_scope "upper": a ring coordinator's own fault lands in the scope of the
    ring above it instead (the other choice of part C).
    edges: replaces the edges the connections carry (for kind by kind wirings).
    """
    rings, base = layout(levels)
    conns = connections(levels)
    E = R.edges_of(conns, reading) if edges is None else frozenset(edges)
    mons = []
    for _, ms, d, _ in base:
        mons += ms + [d]
    for lv, ms, c in rings:
        if lv > 1:
            mons.append(c)
    d = {"name": name or f"tower of {levels} level(s), {reading}, work reads {work}",
         "f": f, "monitors": mons, "works": [w for _, _, _, w in base], "joiner": None,
         "boundary": {}, "substrate": {}, "hb_readers": {}, "checkers": {}, "fwd": {},
         "halt_inputs": {}, "switches": [], "coupling": True, "window": 0, "gate": True,
         "slow_reports": False, "late": [], "arrive_bad": False, "slow_edges": []}
    for k, a, b in sorted(E):
        d[k].setdefault(a, []).append(b)
    for i, ms, c, w in base:
        if work == "all":
            d["checkers"][w] = ms + [c]
            d["halt_inputs"][w] = ms + [c]
        elif work == "two":
            d["checkers"][w] = [ms[0]]
            d["halt_inputs"][w] = [ms[0], c]
        else:
            raise ValueError(work)
    n = 0
    for i, ms, c, w in base:
        for m in ms + [c]:
            n += 1
            d["boundary"][m] = f"ring {i}" if ring_boundaries else n
    for m in mons:
        if m not in d["boundary"]:
            n += 1
            d["boundary"][m] = n
    if scoped:
        add_scopes(d, levels, coordinator_scope)
    return d


def add_scopes(d, levels, coordinator_scope="own"):
    rings, base = layout(levels)
    ring_of = {}          # coordinator -> (level, members)
    above = {}            # a monitor that is a member of a ring -> that ring's coordinator
    for lv, ms, c in rings:
        ring_of[c] = (lv, ms)
        for m in ms:
            above[m] = c
    scope, scope_work, told = {}, {}, {}

    def works_under(c):
        lv, ms = ring_of[c]
        if lv == 1:
            return [f"W{c[1:]}"]
        return [w for m in ms for w in works_under(m)]

    def sid(c):
        return f"ring {c[1:]}" if ring_of[c][0] == 1 else ("top" if c == "T" else f"upper {c}")

    for lv, ms, c in rings:
        s = sid(c)
        if lv == 1:
            for m in ms:
                scope[m] = s
            scope[f"W{c[1:]}"] = s
        scope_work[s] = works_under(c)
        home = s
        if coordinator_scope == "upper" and c in above:
            home = sid(above[c])
        scope[c] = home
        if c in above:
            up = above[c]
            told[s] = [m for m in ring_of[up][1] if m != c] + [up]
    d["scope"], d["scope_work"], d["told"] = scope, scope_work, told
    return d


def symmetries(levels, work):
    """Renamings of the processes that leave the tower as it is: turning the three
    sub-towers of a ring round its cycle, and (when the work reads all four) turning the
    members of a base ring. Each is a dict name -> name over monitors and work."""
    rings, base = layout(levels)
    names = []
    for _, ms, c, w in base:
        names += ms + [c, w]
    for lv, ms, c in rings:
        if lv > 1:
            names.append(c)
    ring_of = {c: (lv, ms) for lv, ms, c in rings}

    def under(c):
        lv, ms = ring_of[c]
        out = [c]
        if lv == 1:
            return out + ms + [f"W{c[1:]}"]
        for m in ms:
            out += under(m)
        return out

    gens = []
    for lv, ms, c in rings:
        if lv == 1:
            if work == "all":
                g = {n: n for n in names}
                g[ms[0]], g[ms[1]], g[ms[2]] = ms[1], ms[2], ms[0]
                gens.append(g)
        else:
            g = {n: n for n in names}
            subs = [under(m) for m in ms]
            for i in range(3):
                for a, b in zip(subs[i], subs[(i + 1) % 3]):
                    g[a] = b
            gens.append(g)
    return names, gens


def canon_for(d, levels, work):
    """A function that maps a state of mr_model to the least state of its class under the
    tower's symmetries (the group generated by `symmetries`). Exploring one state of each
    class is enough: a renaming that leaves the system as it is carries executions to
    executions and violations to violations."""
    import mr_model as mm
    c = mm.Compiled(d)
    names, gens = symmetries(levels, work)
    idx = c.ix
    n, nm, ns = c.n, c.nm, c.ns
    ident = tuple(range(n))
    perms = {ident}
    frontier = [ident]
    gen_perms = [tuple(idx[g[c.names[i]]] for i in range(n)) for g in gens]
    while frontier:
        nxt = []
        for p in frontier:
            for g in gen_perms:
                q = tuple(g[p[i]] for i in range(n))
                if q not in perms:
                    perms.add(q)
                    nxt.append(q)
        frontier = nxt
    perms.discard(ident)
    tables = []
    for p in perms:
        # every symmetry must leave the system as it is
        for rel in mm.RELATIONS:
            for k in range(n):
                img = 0
                for m in mm.bits(c.edges[rel][k]):
                    img |= 1 << p[m]
                assert c.edges[rel][p[k]] == img, "not a symmetry"
        lo = [0] * 256
        hi = [0] * 256
        for v in range(256):
            a = b = 0
            for i in range(8):
                if (v >> i) & 1:
                    if i < n:
                        a |= 1 << p[i]
                    if i + 8 < n:
                        b |= 1 << p[i + 8]
            lo[v], hi[v] = a, b
        smap = [None] * ns
        for i in range(n):
            s, t = c.scope_of[i], c.scope_of[p[i]]
            assert smap[s] in (None, t), "scopes not carried to scopes"
            smap[s] = t
        cl = [0] * (1 << ns)
        for v in range(1 << ns):
            for s in range(ns):
                if (v >> s) & 1:
                    cl[v] |= 1 << smap[s]
        tables.append((lo, hi, [smap[s] * nm for s in range(ns)], cl))
    mmask = c.monmask
    assert n <= 16

    def canon(st):
        best = st
        alive, bad, hidden, off, flagged, halted, pending, present, closed = st
        for lo, hi, sshift, cl in tables:
            fl = 0
            for s in range(ns):
                sub = (flagged >> (s * nm)) & mmask
                if sub:
                    fl |= (lo[sub & 255] | hi[sub >> 8]) << sshift[s]
            t = (lo[alive & 255] | hi[alive >> 8], lo[bad & 255] | hi[bad >> 8],
                 lo[hidden & 255] | hi[hidden >> 8], lo[off & 255] | hi[off >> 8], fl,
                 lo[halted & 255] | hi[halted >> 8], lo[pending & 255] | hi[pending >> 8],
                 lo[present & 255] | hi[present >> 8], cl[closed])
            if t < best:
                best = t
        return best

    return canon, len(perms) + 1
