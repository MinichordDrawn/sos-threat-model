#!/usr/bin/env python3
"""Builders and helpers for the systems with joining monitors. Standard library only.

A system here is the JSON object of model-spec.md with the fields of model-spec-join.md.
The base rings, the six kinds of edge between a joining monitor and an existing one, the
shapes a joining monitor is attached in, and the search for least attachments live here.
join_runs.py uses them.
"""
import copy
import itertools
import json
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fast_join as fj            # noqa: E402
import check_model_join as ref    # noqa: E402

BASE = ["M1", "M2", "M3", "K"]
RELATIONS = fj.RELATIONS


# ------------------------------------------------------------------ building systems

def blank(name, f=1):
    return {"name": name, "f": f, "monitors": [], "works": [], "joiner": None,
            "boundary": {}, "substrate": {}, "hb_readers": {}, "checkers": {}, "fwd": {},
            "halt_inputs": {}, "switches": [], "coupling": True, "window": 0, "gate": True,
            "slow_reports": False, "late": [], "arrive_bad": False, "slow_edges": []}


def edge(d, rel, key, m):
    lst = d[rel].setdefault(key, [])
    if m not in lst:
        lst.append(m)


def drop(d, rel, key, m):
    d[rel][key] = [x for x in d[rel].get(key, []) if x != m]


def add_monitor(d, m):
    d["monitors"].append(m)
    d["boundary"][m] = len(d["monitors"])      # every monitor in a boundary of its own


def watch(d, who, whom):
    """`who` reads `whom`'s signal and checks its state."""
    edge(d, "hb_readers", whom, who)
    edge(d, "checkers", whom, who)


def mutual(d, a, b):
    """Each watches the other and reports to the other."""
    watch(d, a, b)
    watch(d, b, a)
    edge(d, "fwd", a, b)
    edge(d, "fwd", b, a)


BASE_WORDS = {
    "mesh": "mesh of four (M1, M2, M3, K: every one watches and reports to every other)",
    "cyc-check": "cycle of three with a coordinator that checks state "
                 "(K watches every member, every member watches K)",
    "cyc-signal": "cycle of three with a coordinator that reads signals and flags only "
                  "(K checks no state; every member watches K)",
    "cyc-first": "cycle of three with a coordinator as the checker's nested rings build it "
                 "(K reads signals and flags only; only M1 watches K)",
}


def base(kind, wiring="all", f=1):
    """One of the four base rings, with one work process W.

    In the three cycle shapes M1 watches M2, M2 watches M3, M3 watches M1; each member
    reports to the member it does not check and to K; K reads every member's signal and
    reports to every member. They differ in what K checks and in who watches K.

    wiring "all": W is checked by every monitor that checks any state, and takes its halt
    from all four. wiring "two": W is checked by M1 and takes its halt from M1 and K.
    """
    d = blank(f"{kind}, work reads {wiring}", f)
    for m in BASE:
        add_monitor(d, m)
    if kind == "mesh":
        for a, b in itertools.combinations(BASE, 2):
            mutual(d, a, b)
        state_checkers = list(BASE)
    else:
        ms = BASE[:3]
        for i, m in enumerate(ms):
            watch(d, m, ms[(i + 1) % 3])
            edge(d, "fwd", m, ms[i - 1])
            edge(d, "fwd", m, "K")
            edge(d, "fwd", "K", m)
            edge(d, "hb_readers", m, "K")
        if kind == "cyc-check":
            for m in ms:
                edge(d, "checkers", m, "K")
                watch(d, m, "K")
            state_checkers = list(BASE)
        elif kind == "cyc-signal":
            for m in ms:
                watch(d, m, "K")
            state_checkers = ms
        elif kind == "cyc-first":
            watch(d, "M1", "K")
            state_checkers = ms
        else:
            raise ValueError(kind)
    d["works"] = ["W"]
    if wiring == "all":
        d["checkers"]["W"] = list(state_checkers)
        d["halt_inputs"]["W"] = list(BASE)
    elif wiring == "two":
        d["checkers"]["W"] = ["M1"]
        d["halt_inputs"]["W"] = ["M1", "K"]
    else:
        raise ValueError(wiring)
    return d


# The six kinds of edge between a joining monitor N and an existing monitor X.
KINDS = ("in_chk", "in_hb", "out_fwd", "out_chk", "out_hb", "in_fwd")
KIND_WORDS = {
    "in_chk": "{x} checks {n}'s state",
    "in_hb": "{x} reads {n}'s signal",
    "out_fwd": "{n} reports to {x}",
    "out_chk": "{n} checks {x}'s state",
    "out_hb": "{n} reads {x}'s signal",
    "in_fwd": "{x} reports to {n}",
}


def triple(n, kind, x):
    """The edge as [relation, key, monitor] (model-spec-join.md, J1)."""
    return {"in_chk": ["checkers", n, x], "in_hb": ["hb_readers", n, x],
            "out_fwd": ["fwd", n, x], "out_chk": ["checkers", x, n],
            "out_hb": ["hb_readers", x, n], "in_fwd": ["fwd", x, n]}[kind]


def words(n, kind, x):
    return KIND_WORDS[kind].format(n=n, x=x)


def shape_edges(shape, a, b=None, c=None):
    """The edges (kind, existing monitor) of a monitor that joins in a given shape.

    mesh          it and each of a, b, c watch each other and report to each other
    coord-signal  it is a coordinator that reads signals and flags only: it reads the
                  signals of a, b, c and reports to them; they watch it and report to it
    member-check  it is a member of a cycle it -> a -> b -> it, with c as coordinator:
                  it watches a; b watches it; it reports to b and to c; a and c report to
                  it; c reads its signal and checks its state
    member-signal the same, c reading its signal only
    one           one existing monitor a watches it, and it reports to a
    """
    if shape == "mesh":
        return [(k, x) for x in (a, b, c) for k in KINDS]
    if shape == "coord-signal":
        return [(k, x) for x in (a, b, c) for k in KINDS if k != "out_chk"]
    if shape in ("member-check", "member-signal"):
        es = [("out_hb", a), ("out_chk", a), ("in_fwd", a),
              ("in_hb", b), ("in_chk", b), ("out_fwd", b),
              ("in_hb", c), ("in_fwd", c), ("out_fwd", c)]
        if shape == "member-check":
            es.append(("in_chk", c))
        return es
    if shape == "one":
        return [("in_chk", a), ("in_hb", a), ("out_fwd", a)]
    raise ValueError(shape)


def add_late(d, n, edges, after=(), group=None):
    """Add late monitor n with the given (kind, existing monitor) edges. With `group`, n
    is added to that existing group; otherwise it gets a group of its own named n."""
    add_monitor(d, n)
    for kind, x in edges:
        rel, key, m = triple(n, kind, x)
        edge(d, rel, key, m)
    if group is None:
        d["late"].append({"name": n, "members": [n], "after": list(after)})
    else:
        g = next(g for g in d["late"] if g["name"] == group)
        g["members"].append(n)
    return d


def grown(base_kind, steps, guard=True, wiring="all", f=1, arrive_bad=True, name=None):
    """A base ring grown by `steps`: a list of (shape, attachment monitors). The new
    monitors are named N5, N6, ... in order. With guard, a monitor may join only once
    every late monitor it is attached to is present."""
    d = base(base_kind, wiring, f)
    for i, (shape, att) in enumerate(steps):
        n = f"N{5 + i}"
        late = [x for x in att if x not in BASE]
        add_late(d, n, shape_edges(shape, *att), after=late if guard else ())
    d["arrive_bad"] = arrive_bad
    d["name"] = name or (f"{base_kind} grown by " + "; ".join(
        f"{s}({','.join(att)})" for s, att in steps) + ("" if guard else ", any join order"))
    return d


def static(d):
    """The same system with every late process present from the start."""
    t = copy.deepcopy(d)
    t["late"], t["arrive_bad"], t["slow_edges"] = [], False, []
    t["name"] += ", all present from the start"
    return t


# ------------------------------------------------------------------ running

RESULTS = {}      # canonical JSON of a system -> (G1, G2, states)
CATALOGUE = []    # {"id", "system"} in the order the cases were added
ANSWERS = {}      # id -> {"G1", "G2"}
MAX_STATES = 400000


def check(d, max_states=None):
    """(G1, G2) for a system, by the second implementation. Raises if the search had to
    be bounded before it was complete."""
    key = json.dumps(d, sort_keys=True)
    if key not in RESULTS:
        r = fj.explore(d, stop_early=True, max_states=max_states or MAX_STATES)
        if r["bounded"]:
            raise RuntimeError(f"search bounded for {d['name']} at f={d['f']}")
        RESULTS[key] = (r["G1"], r["G2"], r["states"])
    return RESULTS[key][:2]


def case(case_id, d):
    """Check a system and record it in the catalogue under an id."""
    g1, g2 = check(d)
    if case_id in ANSWERS:
        raise ValueError(f"duplicate id {case_id}")
    CATALOGUE.append({"id": case_id, "system": tidy(d)})
    ANSWERS[case_id] = {"G1": g1, "G2": g2}
    return g1, g2


def tidy(d):
    """A copy for the catalogue: empty lists dropped from the maps."""
    t = copy.deepcopy(d)
    for rel in RELATIONS:
        t[rel] = {k: v for k, v in t[rel].items() if v}
    return t


def no_gap(result):
    return result[0] is None and result[1] is None


def fmt(result):
    g1, g2 = result
    if g1 is None and g2 is None:
        return "no gap"
    return ("G1 " + ("holds" if g1 is None else f"in {g1}") + ", G2 "
            + ("holds" if g2 is None else f"in {g2}"))


def short(result):
    g1, g2 = result
    if g1 is None and g2 is None:
        return "-"
    return f"{'.' if g1 is None else g1}/{'.' if g2 is None else g2}"


def with_f(d, f, arrive_bad=None):
    t = copy.deepcopy(d)
    t["f"] = f
    if arrive_bad is not None:
        t["arrive_bad"] = arrive_bad
    return t


def to_ref(d):
    """The same system as an object of the extended original checker."""
    s = ref.System(d["name"], d["f"])
    for k, v in copy.deepcopy(d).items():
        setattr(s, k, v)
    return s


def ref_check(d):
    first, _ = ref.explore(to_ref(d), stop_early=True)
    return (first["G1"] and len(first["G1"]), first["G2"] and len(first["G2"]))


def trace(d, goal="G1"):
    """The shortest execution breaking a goal, as rows for a table."""
    r = fj.explore(d, stop_early=True)
    sched = r["trace_" + goal]
    return None if sched is None else fj.replay(d, sched)


def show_trace(rows, indent="      "):
    out = []
    for i, row in enumerate(rows, 1):
        if row.get("ended"):
            out.append(f"{indent}(the model ended in a complete response)")
            break
        env = ", ".join(f"{k} {' '.join(a) if isinstance(a, (list, tuple)) else a}"
                        for k, a in row["steps"]) or "(none)"
        broke = [g for g in ("G1", "G2") if row[g]]
        out.append(f"{indent}round {i}: env: {env}")
        out.append(f"{indent}         bad: {' '.join(row['bad']) or '-'}"
                   f" | flagged: {' '.join(row['flagged']) or '-'}"
                   f" | halted: {' '.join(row['halted']) or '-'}"
                   f" | worked: {' '.join(row['worked']) or '-'}"
                   + (f"   <-- breaks {' and '.join(broke)}" if broke else ""))
    return "\n".join(out)


def run_schedule(d, schedule):
    return fj.replay(d, schedule)


# ------------------------------------------------------------------ properties of a system

def responds_at_once(d):
    """True if every round in which the environment takes a step other than a join ends
    in a complete response with neither goal violated. (Then every state the search
    reaches is either complete or has seen nothing but joins.)"""
    c = fj.Compiled(d)
    start = fj.initial(c)
    seen = {start}
    stack = [start]
    while stack:
        s = stack.pop()
        for after_env, steps in fj.env_choices(c, s).items():
            t, g1, g2, _, _ = fj.round_end(c, s[7], after_env)
            if g1 or g2:
                return False
            only_joins = all(k == "join" for k, _ in steps)
            if not only_joins and not fj.responded(c, t):
                return False
            if only_joins and t not in seen:
                seen.add(t)
                stack.append(t)
    return True


def join_states(d):
    """Every set of present processes the joins alone can reach, as lists of names."""
    c = fj.Compiled(d)
    start = c.start
    seen = {start}
    stack = [start]
    while stack:
        p = stack.pop()
        nxt = []
        if c.lone_joiner and not (p >> c.joiner) & 1:
            nxt.append(p | 1 << c.joiner)
        for _, members, after, _ in c.groups:
            if members & ~p and not after & ~p:
                nxt.append(p | members)
        for q in nxt:
            if q not in seen:
                seen.add(q)
                stack.append(q)
    return [[c.names[i] for i in fj.bits(p)] for p in sorted(seen)]


def restricted(d, present):
    """The system as it is with only `present` processes, as one with nothing late."""
    here = set(present)
    t = blank(d["name"], d["f"])
    t["monitors"] = [m for m in d["monitors"] if m in here]
    t["works"] = [w for w in d["works"] if w in here]
    if d.get("joiner") in here:
        t["works"].append(d["joiner"])
    t["boundary"] = {m: b for m, b in d["boundary"].items() if m in here}
    for rel in RELATIONS:
        t[rel] = {k: [m for m in v if m in here] for k, v in d[rel].items() if k in here}
    for k in ("coupling", "window", "gate", "slow_reports"):
        t[k] = d[k]
    return t


def observers(d):
    """Per monitor: who checks its state, who reads its signal, who does both."""
    out = {}
    for m in d["monitors"]:
        chk = {x for x in d["checkers"].get(m, []) if x != m}
        hb = {x for x in d["hb_readers"].get(m, []) if x != m}
        out[m] = {"checkers": chk, "readers": hb, "watchers": chk & hb, "either": chk | hb}
    return out


def least_observers(d, what="watchers"):
    return min(len(v[what]) for v in observers(d).values())


def theorem_s(d):
    """Conditions (a) to (d) of Theorem S on a system with nothing late."""
    return ref.sufficient_f1(to_ref(d))


def theorem_s_every_join_state(d):
    return all(theorem_s(restricted(d, p)) for p in join_states(d))


# ------------------------------------------------------------------ least attachments

def minimal_transversals(sets):
    """Every minimal set that meets each of `sets` (Berge's algorithm)."""
    result = [frozenset()]
    for s in sets:
        nxt = set()
        for t in result:
            if t & s:
                nxt.add(t)
            else:
                for e in s:
                    nxt.add(t | {e})
        nxt = sorted(nxt, key=lambda t: (len(t), sorted(t)))
        keep = []
        for t in nxt:
            if not any(k <= t for k in keep):
                keep.append(t)
        result = keep
    return result


def least_sets(universe, good, max_evals=4000):
    """For a monotone test `good` on subsets of `universe` (adding an element never turns
    good into not good): every minimal good set and every maximal set that is not good.
    Complete, by the duality of the two families: the search ends when every minimal set
    that escapes all the maximal not-good sets contains a known minimal good set.
    Returns (minimal good sets, maximal not-good sets, number of tests)."""
    universe = frozenset(universe)
    memo = {}

    def g(x):
        if x not in memo:
            if len(memo) >= max_evals:
                raise RuntimeError("too many tests")
            memo[x] = good(x)
        return memo[x]

    def shrink(x):
        for e in sorted(x):
            if g(x - {e}):
                x = x - {e}
        return x

    def grow(x):
        for e in sorted(universe - x):
            if not g(x | {e}):
                x = x | {e}
        return x

    if not g(universe):
        return [], [universe], len(memo)
    least, most = [shrink(universe)], []
    candidates, at = [frozenset()], 0
    while True:
        # the candidates are the minimal sets that escape every maximal not-good set; one
        # that contains a known minimal good set stays covered, so the index only advances
        while at < len(candidates) and any(t <= candidates[at] for t in least):
            at += 1
        if at == len(candidates):
            return least, most, len(memo)
        found = candidates[at]
        if g(found):
            least.append(shrink(found))
        else:
            most.append(grow(found))
            candidates, at = minimal_transversals([universe - m for m in most]), 0
