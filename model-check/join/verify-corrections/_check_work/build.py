"""System builders used by the checks (written by the checker from the write-up's descriptions)."""
import os
import sys
import importlib.util

HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("independent_model", os.path.join(HERE, "..", "independent_model.py"))
indep = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(indep)

from mymodel import M, fmt, show_trace


def empty(f, monitors, works, joiner=None):
    return {"name": "", "f": f, "monitors": list(monitors), "works": list(works), "joiner": joiner,
            "boundary": {m: "b_" + m for m in monitors}, "substrate": {},
            "hb_readers": {}, "checkers": {}, "fwd": {}, "halt_inputs": {}, "switches": [],
            "coupling": True, "window": 0}


def add(s, rel, key, m):
    l = s[rel].setdefault(key, [])
    if m not in l:
        l.append(m)


def rem(s, rel, key, m):
    s[rel][key].remove(m)


def watch(s, x, n):
    """x watches n: x checks n's state and reads n's signal."""
    add(s, "checkers", n, x)
    add(s, "hb_readers", n, x)


def report(s, a, b):
    add(s, "fwd", a, b)


def mesh_pair(s, a, b):
    watch(s, a, b)
    watch(s, b, a)
    report(s, a, b)
    report(s, b, a)


def add_monitor(s, n):
    s["monitors"].append(n)
    s["boundary"][n] = "b_" + n


def base_mesh(f, names=("M1", "M2", "M3", "K"), w="W"):
    s = empty(f, names, [w])
    for i, a in enumerate(names):
        for b in names[i + 1:]:
            mesh_pair(s, a, b)
    for m in names:
        add(s, "checkers", w, m)
        add(s, "halt_inputs", w, m)
    return s


def base_cycle(f, coord="checking"):
    """cycle M1,M2,M3 with coordinator K. coord: 'checking' | 'reading' | 'nested'. W reads all."""
    s = empty(f, ["M1", "M2", "M3", "K"], ["W"])
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
        if coord == "checking":
            watch(s, "K", m)
        else:
            add(s, "hb_readers", m, "K")
        if coord in ("checking", "reading"):
            watch(s, m, "K")
    if coord == "nested":
        watch(s, "M1", "K")
    for m in ("M1", "M2", "M3", "K"):
        if coord == "checking" or m != "K":
            add(s, "checkers", "W", m)
        add(s, "halt_inputs", "W", m)
    return s


def late_group(s, name, members, after=()):
    s.setdefault("late", []).append({"name": name, "members": list(members), "after": list(after)})


def both(s, anygap=False):
    """Solve with my implementation and with independent_model.py; assert agreement; return my result."""
    r = M(s).solve(anygap=anygap)
    if not anygap:
        g1, g2, ns, ok = indep.Model(s).solve()
        assert ok
        assert (g1, g2) == (r["G1"], r["G2"]), ("DISAGREE", s.get("name"), (g1, g2), r)
    return r


def nogap(r):
    return r["G1"] is None and r["G2"] is None
