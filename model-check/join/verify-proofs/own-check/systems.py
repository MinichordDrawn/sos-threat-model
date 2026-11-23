# Builders for the systems named in the write-up, made from its text.
import copy


def empty(monitors, works, f=1, joiner=None):
    s = dict(name="", f=f, monitors=list(monitors), works=list(works), joiner=joiner,
             boundary={m: "b_" + m for m in monitors}, substrate={},
             hb_readers={}, checkers={}, fwd={}, halt_inputs={}, switches=[],
             coupling=True, window=0)
    return s


def add(s, rel, key, mon):
    lst = s[rel].setdefault(key, [])
    if mon not in lst:
        lst.append(mon)


def rem(s, rel, key, mon):
    lst = s[rel].get(key, [])
    if mon in lst:
        lst.remove(mon)
        return True
    return False


def has(s, rel, key, mon):
    return mon in s[rel].get(key, [])


def watch(s, a, b):
    """a watches b: a checks b's state and reads b's signal."""
    add(s, "checkers", b, a)
    add(s, "hb_readers", b, a)


def report(s, a, b):
    add(s, "fwd", a, b)


def mesh_pair(s, a, b):
    watch(s, a, b)
    watch(s, b, a)
    report(s, a, b)
    report(s, b, a)


BASE = ["M1", "M2", "M3", "K"]


def base_ring(shape, wreads="all", f=1):
    s = empty(BASE, ["W"], f=f)
    if shape == "mesh":
        for i in range(4):
            for j in range(i + 1, 4):
                mesh_pair(s, BASE[i], BASE[j])
    else:
        # M1 watches M2, M2 watches M3, M3 watches M1
        watch(s, "M1", "M2")
        watch(s, "M2", "M3")
        watch(s, "M3", "M1")
        # each member reports to the member it does not check and to K
        report(s, "M1", "M3")
        report(s, "M2", "M1")
        report(s, "M3", "M2")
        for m in ("M1", "M2", "M3"):
            report(s, m, "K")
            report(s, "K", m)
            # K watches every member (or reads signals only)
            add(s, "hb_readers", m, "K")
            if shape == "cycle_check":
                add(s, "checkers", m, "K")
        watchers_of_k = ("M1", "M2", "M3") if shape in ("cycle_check", "cycle_signal") else ("M1",)
        for m in watchers_of_k:
            watch(s, m, "K")
    checking = [m for m in BASE if any(m in v for v in s["checkers"].values())]
    if wreads == "all":
        for m in checking:
            add(s, "checkers", "W", m)
        for m in BASE:
            add(s, "halt_inputs", "W", m)
    else:
        add(s, "checkers", "W", "M1")
        add(s, "halt_inputs", "W", "M1")
        add(s, "halt_inputs", "W", "K")
    return s


SHAPES = ["mesh", "cycle_check", "cycle_signal", "cycle_nested"]

# the six kinds of edge between a joining monitor N and an existing monitor X
KINDS = ["XcN", "XrN", "XpN", "NcX", "NrX", "NpX"]


def edge(kind, N, X):
    """Returns (relation, key, monitor) for one of the six kinds."""
    if kind == "XcN":
        return ("checkers", N, X)
    if kind == "XrN":
        return ("hb_readers", N, X)
    if kind == "XpN":
        return ("fwd", X, N)
    if kind == "NcX":
        return ("checkers", X, N)
    if kind == "NrX":
        return ("hb_readers", X, N)
    if kind == "NpX":
        return ("fwd", N, X)
    raise ValueError(kind)


def add_monitor(s, N, group=None, after=None):
    s["monitors"].append(N)
    s["boundary"][N] = "b_" + N
    if group is not False:
        s.setdefault("late", []).append(dict(name=group or N, members=[N], after=list(after or [])))


def attach(s, N, edges):
    """edges: iterable of (kind, X)."""
    for kind, X in edges:
        add(s, *edge(kind, N, X))


def shape_edges(shape, abc):
    """The attachment shapes of section 2 as lists of (kind, X)."""
    if shape == "mesh":
        return [(k, x) for x in abc for k in KINDS]
    if shape == "sigcoord":
        # N reads the signals of a, b, c and reports to them; they watch N and report to it.
        return [(k, x) for x in abc for k in ("NrX", "NpX", "XcN", "XrN", "XpN")]
    if shape in ("cyc_checked", "cyc_read"):
        a, b, c = abc
        e = [("NcX", a), ("NrX", a), ("XcN", b), ("XrN", b), ("NpX", b), ("NpX", c),
             ("XpN", a), ("XpN", c), ("XrN", c)]
        if shape == "cyc_checked":
            e.append(("XcN", c))
        return e
    if shape == "one":
        a = abc[0]
        return [("XcN", a), ("XrN", a), ("NpX", a)]
    raise ValueError(shape)


def clone(s):
    return copy.deepcopy(s)
