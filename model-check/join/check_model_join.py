#!/usr/bin/env python3
"""Explicit-state check of the model of the eight properties and the ring.

A helper script, standard library only, Python 3.9 or later. For each small system below
it explores every reachable state and reports the shortest execution, if any, that breaks
a goal:

  G1  detection: at the end of a round, if some process's state is bad, then some live,
      correct monitor is flagged.
  G2  no impact: no work process takes a work step while some process's state is bad.

One round is: the environment takes up to f steps, then every monitor steps once and flags
travel along report edges, then every work process steps once. The model ends at the first
complete response (some live, correct monitor flagged and every work process halted).
The semantics are specified in model-spec.md.

This copy is extended to monitors that join a running system, as model-spec-join.md
specifies: the fields `late`, `arrive_bad` and `slow_edges`, the state component `arrived`,
and the steps `join g` and `join-bad g m`. A system with none of the three fields is
handled exactly as before, and a plain run prints what the original prints. The systems
with joining monitors are built and run by join_runs.py.

Run:  python -I check_model.py                  summary tables
      python -I check_model.py --traces         also print the ten executions of the
                                                write-up and the shortest execution that
                                                breaks each goal
      python -I check_model.py --json OUT.json  also write every case and its result
      python -I check_model.py --systems S.json also write every case without its result
"""
import copy
import json
import sys
from collections import deque, namedtuple

State = namedtuple("State", "alive bad hidden off flagged halted pending joined arrived")
PROPS = ("P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "P8b", "gate")
RELATIONS = ("hb_readers", "checkers", "fwd", "halt_inputs")


class System:
    def __init__(self, name, f=1):
        self.name = name
        self.f = f                # environment steps allowed per round
        self.monitors = []
        self.works = []
        self.joiner = None        # a work process that may join at runtime
        self.boundary = {}        # monitor -> trust boundary
        self.substrate = {}       # process -> substrate it runs on
        self.hb_readers = {}      # monitor -> monitors that flag when its signal is absent
        self.checkers = {}        # process -> monitors that compare its state with known-good
        self.fwd = {}             # monitor -> monitors it reports its flag to
        self.halt_inputs = {}     # work -> monitors whose flag, or silence, halts it
        self.switches = []        # monitors with a sanctioned off switch
        self.coupling = True      # a work process halts when a monitor it reads is silent
        self.window = 0           # rounds between a work process seeing a flag and halting
        self.gate = True          # monitors check before work steps in every round
        self.slow_reports = False  # a report takes one round to arrive
        self.late = []            # groups {"name", "members", "after"} that join at runtime
        self.arrive_bad = False   # a late monitor may arrive already bad
        self.slow_edges = []      # [relation, key, monitor] edges missing in the join round

    def as_data(self):
        data = {k: v for k, v in vars(self).items()}
        for key, default in (("late", []), ("arrive_bad", False), ("slow_edges", [])):
            if data[key] == default:    # a system without joining monitors is written
                del data[key]           # exactly as the original checker writes it
        return data


def late_names(system):
    """Every process that is a member of a group."""
    return {p for g in system.late for p in g["members"]}


def present(system, s):
    if not system.late:
        procs = system.monitors + system.works
        return procs + [system.joiner] if s.joined else procs
    absent = {p for g in system.late if g["name"] not in s.arrived for p in g["members"]}
    procs = [p for p in system.monitors + system.works if p not in absent]
    return procs + [system.joiner] if s.joined else procs


def initial(system):
    empty = frozenset()
    late = late_names(system)
    return State(frozenset(p for p in system.monitors + system.works if p not in late),
                 empty, empty, empty, empty, empty, empty, False, empty)


def arrivals(system, before, after):
    """The processes that became present between two states of one environment phase."""
    new = {p for g in system.late
           if g["name"] in after.arrived and g["name"] not in before.arrived
           for p in g["members"]}
    if after.joined and not before.joined:
        new.add(system.joiner)
    return frozenset(new)


def in_force(system, s, new, cache=None):
    """The four relations restricted to the edges in force in this round: both ends
    present, and not a slow edge with an end that joined in this round. None when the
    system has no joining monitor and no slow edge, which means every edge, as before."""
    if not system.late and not system.slow_edges:
        return None
    key = (s.arrived, s.joined, new)
    if cache is not None and key in cache:
        return cache[key]
    here = set(present(system, s))
    slow = {tuple(e) for e in system.slow_edges}
    force = {}
    for rel in RELATIONS:
        force[rel] = {k: [m for m in v if k in here and m in here
                          and not ((rel, k, m) in slow and (k in new or m in new))]
                      for k, v in getattr(system, rel).items()}
    if cache is not None:
        cache[key] = force
    return force


def env_steps(system, s):
    """Every environment step enabled in s."""
    steps = []
    procs = present(system, s)
    here = set(procs)
    for m in system.monitors:
        if m in s.alive:
            steps.append(("stop", m))
    for b in sorted(set(system.boundary.values())):
        members = [m for m in system.monitors if m in here and system.boundary.get(m) == b]
        if len(members) > 1 and any(m in s.alive for m in members):
            steps.append(("stop-boundary", b))
    for sub in sorted(set(system.substrate.values())):
        members = [p for p in procs if system.substrate.get(p) == sub]
        if any(p in s.alive if p in system.monitors else p not in s.bad for p in members):
            steps.append(("fail-substrate", sub))
    for p in procs:
        if p not in s.bad:
            steps.append(("mutate", p))
    for m in system.switches:
        if m in here and m not in s.off:
            steps.append(("disable", m))
    if system.joiner is not None and not s.joined and system.joiner not in late_names(system):
        steps.append(("join", system.joiner))
    for g in system.late:
        if g["name"] not in s.arrived and all(a in here for a in g.get("after", ())):
            steps.append(("join", g["name"]))
            if system.arrive_bad:
                for m in g["members"]:
                    if m in system.monitors:
                        steps.append(("join-bad", (g["name"], m)))
    return steps


def apply_env(system, s, step):
    kind, arg = step
    alive, bad, hidden, off, joined = set(s.alive), set(s.bad), set(s.hidden), set(s.off), s.joined
    arrived = s.arrived
    group = None
    if kind in ("join", "join-bad"):
        name = arg[0] if kind == "join-bad" else arg
        group = next((g for g in system.late if g["name"] == name), None)
    if kind == "stop":
        alive.discard(arg)
    elif kind == "stop-boundary":
        for m in system.monitors:           # an absent monitor is not in alive
            if system.boundary.get(m) == arg:
                alive.discard(m)
    elif kind == "fail-substrate":
        # A monitor on the substrate stops. A work process on it goes bad, and every
        # state check of it keeps returning the last good value (the read fails stale).
        for p in present(system, s):
            if system.substrate.get(p) == arg:
                if p in system.monitors:
                    alive.discard(p)
                else:
                    bad.add(p)
                    hidden.add(p)
    elif kind == "mutate":
        bad.add(arg)
    elif kind == "disable":
        off.add(arg)
    elif group is not None:                 # join g, or join-bad g m
        arrived = arrived | {group["name"]}
        alive.update(group["members"])
        if system.joiner in group["members"]:
            joined = True
        if kind == "join-bad":
            bad.add(arg[1])
    elif kind == "join":
        joined = True
        alive.add(arg)
    return s._replace(alive=frozenset(alive), bad=frozenset(bad), hidden=frozenset(hidden),
                      off=frozenset(off), joined=joined, arrived=arrived)


def monitor_phase(system, s, force=None):
    """Detection, then flag propagation. Returns the new flagged set. `force` holds the
    edges in force where the system has joining monitors (see in_force)."""
    hb_readers = system.hb_readers if force is None else force["hb_readers"]
    checkers = system.checkers if force is None else force["checkers"]
    fwd = system.fwd if force is None else force["fwd"]
    # A monitor acts only if it is live, correct (not mutated) and not switched off.
    active = {m for m in system.monitors if m in s.alive and m not in s.bad and m not in s.off}
    visible = s.bad - s.hidden
    flagged = set(s.flagged)
    for m in active:
        sees_state = any(m in checkers.get(x, ()) for x in visible)
        sees_silence = any(m in hb_readers.get(p, ())
                           for p in system.monitors if p not in s.alive)
        if sees_state or sees_silence:
            flagged.add(m)
    if system.slow_reports:             # only flags raised in earlier rounds are passed on,
        for m in s.flagged:             # and they make one hop
            if m in active:
                flagged.update(r for r in fwd.get(m, ()) if r in active)
        return flagged
    changed = True
    while changed:                      # a flag travels along report edges, through
        changed = False                 # active monitors only, within the round
        for m in list(flagged):
            if m in active:
                for r in fwd.get(m, ()):
                    if r in active and r not in flagged:
                        flagged.add(r)
                        changed = True
    return flagged


def live_flags(s, flagged):
    """A stopped monitor emits nothing; a mutated one shows nominal whatever it latched."""
    return {m for m in flagged if m in s.alive and m not in s.bad}


def work_phase(system, s, out, force=None):
    """Each work process halts or takes a work step. Returns (halted, pending, executed)."""
    halt_inputs = system.halt_inputs if force is None else force["halt_inputs"]
    halted, pending, executed = set(s.halted), set(s.pending), []
    for w in present(system, s):
        if w in system.monitors or w in halted:
            continue
        if w in pending:                # the evaluation window has passed
            pending.discard(w)
            halted.add(w)
            continue
        inputs = halt_inputs.get(w, ())
        sees = any(m in out for m in inputs) or (
            system.coupling and any(m not in s.alive for m in inputs))
        if sees and system.window == 0:
            halted.add(w)
        else:
            if sees:
                pending.add(w)
            executed.append(w)
    return halted, pending, executed


def process_phase(system, s, new=frozenset(), cache=None):
    """The monitor phase, then the work phase. Where the system has no gate, the work
    phase comes first and acts on the flags as they stood before this round's checks.
    `new` is the set of processes that joined in this round's environment phase.
    Returns (state, info)."""
    force = in_force(system, s, new, cache)
    if system.gate:
        flagged = monitor_phase(system, s, force)
        out = live_flags(s, flagged)
        halted, pending, executed = work_phase(system, s, out, force)
    else:
        halted, pending, executed = work_phase(system, s, live_flags(s, s.flagged), force)
        flagged = monitor_phase(system, s, force)
        out = live_flags(s, flagged)
    info = {
        "bad": sorted(s.bad), "out": sorted(out), "halted": sorted(halted),
        "executed": executed,
        "G1": bool(s.bad) and not out,
        "G2": bool(s.bad) and bool(executed),
    }
    t = s._replace(flagged=frozenset(flagged), halted=frozenset(halted),
                   pending=frozenset(pending))
    return t, info


def responded(system, s):
    out = {m for m in s.flagged if m in s.alive and m not in s.bad}
    works = [w for w in present(system, s) if w not in system.monitors]
    return bool(out) and all(w in s.halted for w in works)


def env_choices(system, s):
    """Every sequence of 0..f environment steps, one per distinct resulting state."""
    seen = {s: ()}
    frontier = [s]
    for _ in range(system.f):
        nxt = []
        for st in frontier:
            for e in env_steps(system, st):
                t = apply_env(system, st, e)
                if t not in seen:
                    seen[t] = seen[st] + (e,)
                    nxt.append(t)
        frontier = nxt
    return [(steps, t) for t, steps in seen.items()]


def explore(system, stop_early=False):
    """Breadth-first over rounds. Returns ({goal: shortest violating path}, states seen).
    With stop_early the search ends once a shortest violation of both goals is known; the
    two results are the same and the count of states is then a lower bound."""
    start = initial(system)
    parent = {start: None}
    queue = deque([start])
    first = {"G1": None, "G2": None}
    joins = bool(system.late or system.slow_edges)
    cache = {}

    def path_to(s):
        rounds = []
        while parent[s] is not None:
            s, steps, info = parent[s]
            rounds.append((steps, info))
        return rounds[::-1]

    while queue:
        s = queue.popleft()
        if responded(system, s):
            continue
        if stop_early and first["G1"] and first["G2"]:
            break
        for steps, after_env in env_choices(system, s):
            new = arrivals(system, s, after_env) if joins else frozenset()
            t, info = process_phase(system, after_env, new, cache)
            for goal in first:
                if info[goal] and first[goal] is None:
                    first[goal] = path_to(s) + [(steps, info)]
            if t not in parent:
                parent[t] = (s, steps, info)
                queue.append(t)
    return first, len(parent)


def replay(system, schedule):
    """Run a given environment schedule (a list of rounds, each a list of steps).
    Returns (rounds run, why it stopped): "done", "ended" when the model reached a complete
    response before the schedule was used up, or "no such step" when a step is not
    enabled in this system."""
    s = initial(system)
    rounds = []
    for steps in schedule:
        if responded(system, s):
            return rounds, "ended"
        before = s
        for e in steps:
            if e not in env_steps(system, s):
                return rounds, "no such step"
            s = apply_env(system, s, e)
        s, info = process_phase(system, s, arrivals(system, before, s))
        rounds.append((tuple(steps), info))
    return rounds, "done"


def show(rounds, indent="    "):
    for i, (steps, info) in enumerate(rounds, 1):
        env = ", ".join(f"{k} {' '.join(a) if isinstance(a, tuple) else a}"
                        for k, a in steps) or "(none)"
        broke = [g for g in ("G1", "G2") if info[g]]
        print(f"{indent}round {i}: env: {env}")
        print(f"{indent}         bad: {' '.join(info['bad']) or '-'}"
              f" | flagged: {' '.join(info['out']) or '-'}"
              f" | halted: {' '.join(info['halted']) or '-'}"
              f" | worked: {' '.join(info['executed']) or '-'}"
              + (f"   <-- breaks {' and '.join(broke)}" if broke else ""))


# --------------------------------------------------------------------------- systems

def add(table, key, *values):
    table.setdefault(key, [])
    for v in values:
        if v not in table[key]:
            table[key].append(v)


def reference(without=(), f=1, unread_extra=False):
    """The reference system R: two work processes with local monitors, three monitors."""
    if isinstance(without, str):
        without = (without,)
    unknown = [p for p in without if p not in PROPS]
    if unknown:
        raise ValueError(f"unknown property: {unknown}")
    on = {p: p not in without for p in PROPS}
    r = System("R" + (" without " + ", ".join(without) if without else ""), f)
    r.monitors = ["M1", "M2", "M3"]
    r.works = ["W1", "W2"]
    r.joiner = "J"

    def others(m):
        return [x for x in ("M1", "M2", "M3") if x != m]

    # P6: each monitor's signal is read from a different trust boundary.
    r.boundary = {"M1": 1, "M2": 2, "M3": 3} if on["P6"] else {"M1": 1, "M2": 1, "M3": 1}
    # P2: each work process's local monitor runs on the work process's substrate.
    r.substrate = {"W1": "s1", "W2": "s2", "M3": "s3"}
    r.substrate.update({"M1": "s1", "M2": "s2"} if on["P2"] else {"M1": "s4", "M2": "s5"})
    # P1: every monitor's missing signal flags the other two, and halts work that reads it.
    if on["P1"]:
        r.hb_readers = {m: others(m) for m in r.monitors}
    r.coupling = on["P1"]
    # P3: state checks. Each work process has one local checker; monitors check each other.
    if on["P3"]:
        r.checkers = {"W1": ["M1"], "W2": ["M2"]}
        r.checkers.update({m: others(m) for m in r.monitors})
    # P4: a flag reaches every other monitor (here in one hop).
    if on["P4"]:
        r.fwd = {m: others(m) for m in r.monitors}
    # P8b: every work process takes its halt from two monitors.
    r.halt_inputs = ({"W1": ["M1", "M3"], "W2": ["M2", "M3"]} if on["P8b"]
                     else {"W1": ["M1"], "W2": ["M2"]})
    # P7: the join step itself puts the joiner under a checker and a halt input.
    if on["P7"]:
        if on["P3"]:
            r.checkers["J"] = ["M3"]
        r.halt_inputs["J"] = ["M3", "M1"] if on["P8b"] else ["M3"]
    # P5: no monitor has a sanctioned off switch.
    if not on["P5"]:
        r.switches = list(r.monitors)
    # P8: a work process halts in the round it sees a flag.
    r.window = 0 if on["P8"] else 1
    # The gate: in every round the monitors check before any work process steps.
    r.gate = on["gate"]

    if unread_extra:                    # a fourth monitor whose silence nobody reads
        r.name += " plus unread M4"
        r.monitors.append("M4")
        r.boundary["M4"] = 4
        r.checkers.setdefault("W1", []).append("M4")
        r.checkers["M4"] = ["M1", "M2"]
        r.fwd["M4"] = ["M1", "M2", "M3"]
    return r


def mesh(n, f=1, one_boundary=False, unread=None):
    """n monitors that all check each other, and one work process they all check and halt.
    With one_boundary, every monitor sits in the same trust boundary (one host, say).
    With unread, that monitor's signal is read by no other monitor."""
    s = System(f"mesh of {n}" + (", all in one boundary" if one_boundary else "")
               + (f", nobody reads {unread}'s signal" if unread else ""), f)
    s.monitors = [f"M{i}" for i in range(1, n + 1)]
    s.works = ["W"]
    s.boundary = {m: 0 if one_boundary else i for i, m in enumerate(s.monitors)}
    for m in s.monitors:
        rest = [x for x in s.monitors if x != m]
        s.hb_readers[m] = rest
        s.checkers[m] = rest
        s.fwd[m] = rest
    s.checkers["W"] = list(s.monitors)
    s.halt_inputs = {"W": list(s.monitors)}
    if unread:
        s.hb_readers[unread] = []
    return s


def reflex(direct, slow, f=1):
    """Three monitors that all check each other and report to each other. Only M1 checks
    the work process. With `direct` the work process takes its halt from M1 and M2, so the
    monitor that sees its fault stops it; otherwise from M2 and M3, which must first hear
    from M1. With `slow` a report takes one round to arrive."""
    s = mesh(3, f)
    s.name = (f"work halted by {'its own checker' if direct else 'other monitors only'}, "
              f"reports {'take a round' if slow else 'arrive at once'}")
    s.checkers["W"] = ["M1"]
    s.halt_inputs = {"W": ["M1", "M2"] if direct else ["M2", "M3"]}
    s.slow_reports = slow
    return s


def ring(n, report="other", gate=2, f=1):
    """n monitors in a directed check cycle: each checks the next one, and reports either
    to the one it does not check ("other") or to the one it checks ("same"). One work
    process, checked by M1, taking its halt from the first `gate` monitors."""
    s = System(f"ring of {n}, reports to {report}, work reads {gate}", f)
    s.monitors = [f"M{i}" for i in range(1, n + 1)]
    s.works = ["W"]
    s.boundary = {m: i for i, m in enumerate(s.monitors)}
    for i, m in enumerate(s.monitors):
        nxt, prev = s.monitors[(i + 1) % n], s.monitors[i - 1]
        s.checkers[nxt] = [m]
        s.hb_readers[nxt] = [m]
        s.fwd[m] = [prev if report == "other" else nxt]
    s.checkers["W"] = ["M1"]
    s.halt_inputs = {"W": s.monitors[:gate]}
    return s


def with_coordinator(gate, f=1):
    """Three mutually checking monitors plus a coordinator K that reads their signals and
    flags and checks no state."""
    s = System(f"3+K, work reads {'+'.join(gate)}", f)
    ms = ["M1", "M2", "M3"]
    s.monitors = ms + ["K"]
    s.works = ["W"]
    s.boundary = {m: i for i, m in enumerate(s.monitors)}
    for m in ms:
        rest = [x for x in ms if x != m]
        s.hb_readers[m] = rest + ["K"]      # K reads every signal and every flag,
        s.checkers[m] = rest                # but checks no state itself
        s.fwd[m] = rest + ["K"]
    s.hb_readers["K"] = ms
    s.checkers["K"] = ms
    s.fwd["K"] = ms
    s.checkers["W"] = ms
    s.halt_inputs = {"W": list(gate)}
    return s


def nested(size=3, upper3=True, f=1, ring_boundaries=False):
    """Two base rings A and B, each `size` members plus a coordinator, joined by an upper
    ring made of the two coordinators (and a third member U3 when upper3). With
    ring_boundaries, each base ring sits whole in one trust boundary, so one environment
    step can stop the entire ring.

    In a base ring each member checks the next member and reports to the member it does
    not check and to the coordinator. The coordinator reads every member's signal, reports
    to every member, and is checked by the first member. Each work process is checked by
    the first member of its ring and takes its halt from that member and the coordinator.
    In the upper ring each member checks the next and reports to the one it does not check.
    These sentences describe base rings of three and an upper ring of three. A lone base
    member is checked by its coordinator and reports only to it, and in an upper ring of
    two each member reports to the other.
    """
    s = System(f"nested, base rings {size}+K, upper ring of {3 if upper3 else 2}", f)
    for tag in ("A", "B"):
        xs = [f"{tag}{i}" for i in range(1, size + 1)]
        k, w = f"K{tag}", f"W{tag}"
        s.monitors += xs + [k]
        s.works.append(w)
        for i, x in enumerate(xs):
            if size >= 2:
                nxt = xs[(i + 1) % size]
                add(s.checkers, nxt, x)
                add(s.hb_readers, nxt, x)
                if size >= 3:
                    add(s.fwd, x, xs[i - 1])
            add(s.hb_readers, x, k)
            add(s.fwd, x, k)
            add(s.fwd, k, x)
        if size == 1:
            add(s.checkers, xs[0], k)       # a lone member is checked by the coordinator
        add(s.checkers, k, xs[0])
        add(s.hb_readers, k, xs[0])
        add(s.checkers, w, xs[0])
        s.halt_inputs[w] = [xs[0], k]
    upper = ["KA", "KB"] + (["U3"] if upper3 else [])
    if upper3:
        s.monitors.append("U3")
    n = len(upper)
    for i, m in enumerate(upper):
        nxt = upper[(i + 1) % n]
        add(s.checkers, nxt, m)
        add(s.hb_readers, nxt, m)
        add(s.fwd, m, upper[i - 1] if n >= 3 else nxt)
    if ring_boundaries:
        s.name += ", each base ring in one boundary"
        # A1..A3 and KA share boundary "A", B1..B3 and KB share "B", U3 has its own
        s.boundary = {m: "A" if "A" in m else "B" if "B" in m else m for m in s.monitors}
    else:
        s.boundary = {m: i for i, m in enumerate(s.monitors)}
    return s


EDGE_WORDS = {
    "hb_readers": "{1} reads {0}'s signal",
    "checkers": "{1} checks {0}'s state",
    "fwd": "{0} reports to {1}",
    "halt_inputs": "{0} takes its halt from {1}",
}


def ablations(system):
    """Every system obtained by deleting one edge from one relation."""
    for rel in RELATIONS:
        table = getattr(system, rel)
        for key in table:
            for target in table[key]:
                t = copy.deepcopy(system)
                getattr(t, rel)[key] = [x for x in table[key] if x != target]
                label = EDGE_WORDS[rel].format(key, target)
                t.name = f"{system.name}, minus: {label}"
                yield label, t


# ------------------------------------ the sufficiency conditions of the write-up, f = 1

def is_plain(system):
    """No joiner, substrates or switches; no two monitors share a boundary; coupling on;
    no window; the gate in place; reports arrive within the round."""
    ids = [system.boundary.get(m, ("own", m)) for m in system.monitors]
    return (system.joiner is None and not system.substrate and not system.switches
            and len(set(ids)) == len(ids) and system.coupling and system.window == 0
            and system.gate and not system.slow_reports)


def reach(system, starts, avoid):
    """Monitors reachable from `starts` along report edges, never entering `avoid`."""
    seen = set(starts) - set(avoid)
    stack = list(seen)
    while stack:
        m = stack.pop()
        for r in system.fwd.get(m, ()):
            if r not in seen and r not in avoid:
                seen.add(r)
                stack.append(r)
    return seen


def sufficient_f1(system):
    """Conditions (a) to (d): every single fault is seen, and the flag reaches everyone."""
    mons = set(system.monitors)
    watchers = {z: [m for m in mons if m != z and m in system.checkers.get(z, ())
                    and m in system.hb_readers.get(z, ())] for z in mons}
    a = all(watchers[z] for z in mons)
    b = all(system.checkers.get(w) and len(set(system.halt_inputs.get(w, ()))) >= 2
            for w in system.works)
    c = all(mons - {z} <= reach(system, watchers[z], {z}) for z in mons)
    d = all(any(mons <= reach(system, [k], ()) for k in system.checkers.get(w, ()))
            for w in system.works)
    return a and b and c and d


# ------------------------------------------- census: every small system with no gap

def predicates(system):
    """The graph properties as predicates on a plain system."""
    mons = set(system.monitors)
    return {
        # every monitor's signal is read by another monitor
        "Q1": all(any(r != m for r in system.hb_readers.get(m, ())) for m in mons),
        # ... or by a work process that halts on its silence
        "Q1f": all(any(r != m for r in system.hb_readers.get(m, ()))
                   or (system.coupling and any(m in system.halt_inputs.get(w, ())
                                               for w in system.works))
                   for m in mons),
        # every process has a state checker other than itself
        "Q3": all(any(c != x for c in system.checkers.get(x, ()))
                  for x in system.monitors + system.works),
        # a flag reaches every other monitor
        "Q4": all(mons <= reach(system, [a], ()) for a in mons),
        # a flag reaches a halt source of every work process
        "Q4r": all(reach(system, [a], ()) & set(system.halt_inputs.get(w, ()))
                   for a in mons for w in system.works),
        # every work process has two different halt sources
        "Q8": all(len(set(system.halt_inputs.get(w, ()))) >= 2 for w in system.works),
    }


def without_monitor(system, m):
    t = copy.deepcopy(system)
    t.monitors = [x for x in t.monitors if x != m]
    t.boundary.pop(m, None)
    for rel in RELATIONS:
        table = getattr(t, rel)
        table.pop(m, None)
        for key in table:
            table[key] = [x for x in table[key] if x != m]
    return t


def key_of(system):
    return json.dumps({r: {k: sorted(v) for k, v in sorted(getattr(system, r).items()) if v}
                       for r in RELATIONS} | {"m": sorted(system.monitors)}, sort_keys=True)


GAP_FREE = {}


def gap_free(system):
    k = key_of(system)
    if k not in GAP_FREE:
        first, _ = explore(system)
        GAP_FREE[k] = first["G1"] is None and first["G2"] is None
    return GAP_FREE[k]


def explained_by_spares(system, names):
    """True if deleting spare monitors, one at a time, can reach a system in which every
    predicate in `names` holds. A monitor is spare if the system without it has no gap."""
    if all(predicates(system)[n] for n in names):
        return True
    return any(gap_free(t) and explained_by_spares(t, names)
               for t in (without_monitor(system, m) for m in system.monitors))


def small_systems(n, count, seed):
    """Plain systems with n monitors and one work process. All of them without self-edges
    when count is None; otherwise `count` drawn at random, half uniformly and half as a mesh with edges
    removed (so that enough of them have no gap)."""
    import itertools
    import random
    mons = [f"M{i}" for i in range(1, n + 1)]

    def build(bits):
        s = System("census", 1)
        s.monitors, s.works = list(mons), ["W"]
        s.boundary = {m: i for i, m in enumerate(mons)}
        it = iter(bits)
        for rel in ("hb_readers", "checkers", "fwd"):
            for m in mons:
                getattr(s, rel)[m] = [o for o in mons if o != m and next(it)]
        s.checkers["W"] = [m for m in mons if next(it)]
        s.halt_inputs["W"] = [m for m in mons if next(it)]
        return s

    width = 3 * n * (n - 1) + 2 * n
    if count is None:
        for bits in itertools.product((0, 1), repeat=width):
            yield build(bits)
        return
    rng = random.Random(seed)
    for i in range(count):
        if i % 2:
            yield build([rng.random() < 0.5 for _ in range(width)])
        else:
            drop = rng.randint(0, 6)
            bits = [1] * width
            for j in rng.sample(range(width), drop):
                bits[j] = 0
            yield build(bits)


CENSUS_NAMES = ("Q1", "Q1f", "Q3", "Q4", "Q4r", "Q8")


def census(n, count=None, seed=1):
    """Returns (systems looked at, how many have no gap, per predicate: how many gap-free
    systems fail it, per predicate: how many still fail it however spare monitors are
    deleted, one example of each of those)."""
    seen, total, free = set(), 0, 0
    fails = dict.fromkeys(CENSUS_NAMES, 0)
    stays = dict.fromkeys(CENSUS_NAMES, 0)
    example = {}
    for s in small_systems(n, count, seed):
        k = key_of(s)
        if k in seen:
            continue
        seen.add(k)
        total += 1
        if not gap_free(s):
            continue
        free += 1
        p = predicates(s)
        for name in CENSUS_NAMES:
            if not p[name]:
                fails[name] += 1
                if not explained_by_spares(s, (name,)):
                    stays[name] += 1
                    example.setdefault(name, s)
    return total, free, fails, stays, example


# --------------------------------------------------------- growth against response time

def growth(n, policy, a, b=1):
    """One latent bad process among n running ones. Each tick, every bad process still
    running makes one more running process bad. A halt starts at tick 0.

    policy "window":   every process halts together, `a` ticks after detection
    policy "cascade":  each process the halt reaches passes it to `a` more, and the halt
                       makes `b` hops per tick; it reaches good processes first (one
                       order among several, and not the worst)
    Returns how many processes are bad once nothing bad is running.
    """
    good, bad, halted_bad, tick, frontier = n - 1, 1, 0, 0, 1
    while bad:
        if policy == "window":
            if tick >= a:
                break
        else:
            for _ in range(b):
                newly = min(frontier * a, good + bad)
                g = min(newly, good)
                good -= g
                bad -= newly - g
                halted_bad += newly - g
                frontier = newly
        spread = min(bad, good)
        good -= spread
        bad += spread
        tick += 1
    return halted_bad + bad


# -------------------------------------------------------------- restarting a ring

def restart_game(observers, self_starting=()):
    """Members that run only while observed, and whether they can come back from a stop.

    `observers[i]` lists the members that observe member i. A member that is not
    self-starting runs only while at least one of its observers is running: when none is,
    it stops at once, and it can start only when one is. A self-starting member needs no
    running observer. The environment may stop any running member, which also blocks it
    from starting, and may later release it.

    Returns (shortest trace to a state with nobody blocked from which "all running" cannot
    be reached without further environment stops, or None; number of reachable states).
    """
    members = tuple(observers)

    def settle(running):
        """Coupling: anything left without a running observer stops."""
        running = set(running)
        changed = True
        while changed:
            changed = False
            for m in list(running):
                if m not in self_starting and not any(o in running for o in observers[m]):
                    running.discard(m)
                    changed = True
        return frozenset(running)

    def steps(state):
        running, blocked = state
        for m in members:
            if m in running:
                yield f"stop {m}", (settle(running - {m}), blocked | {m})
            elif m in blocked:
                yield f"release {m}", (running, blocked - {m})
            elif m in self_starting or any(o in running for o in observers[m]):
                yield f"start {m}", (settle(running | {m}), blocked)

    start = (frozenset(members), frozenset())
    parent = {start: None}
    queue = deque([start])
    while queue:
        st = queue.popleft()
        for label, nxt in steps(st):
            if nxt not in parent:
                parent[nxt] = (st, label)
                queue.append(nxt)

    def trace(st):
        out = []
        while parent[st] is not None:
            st, label = parent[st]
            out.append(label)
        return out[::-1]

    def can_restart(st):
        seen, stack = {st}, [st]
        while stack:
            cur = stack.pop()
            if cur[0] == frozenset(members):
                return True
            for label, nxt in steps(cur):
                if not label.startswith("stop") and nxt not in seen:
                    seen.add(nxt)
                    stack.append(nxt)
        return False

    stuck = [s for s in parent if not s[1] and not can_restart(s)]
    stuck.sort(key=lambda s: len(trace(s)))
    return (trace(stuck[0]) if stuck else None), len(parent)


# --------------------------------------------------- mirror of Heartbeat.tla (section 9)

def heartbeat_spec(monitors, hb):
    """The TLA+ module's transition system, state for state. Returns (trace or None, states)."""
    init = (frozenset(monitors), False, frozenset(), "env", False)   # alive bad flagged turn halted
    parent = {init: None}
    queue = deque([init])

    def successors(st):
        alive, bad, flagged, turn, halted = st
        if turn == "env" and not halted:
            for m in sorted(alive):
                yield f"Stop({m})", (alive - {m}, bad, flagged, "mon", halted)
            if not bad:
                yield "Corrupt", (alive, True, flagged, "mon", halted)
            yield "Skip", (alive, bad, flagged, "mon", halted)
        if turn == "mon":
            detects = {m for m in alive
                       if bad or (hb and any(p not in alive for p in monitors if p != m))}
            yield "MonRound", (alive, bad, flagged | detects, "env", bool(detects))

    def invariant(st):
        alive, bad, flagged, turn, _ = st
        return not (turn == "env" and bad) or any(m in flagged for m in alive)

    while queue:
        st = queue.popleft()
        if not invariant(st):
            trace = []
            while st is not None:
                trace.append((parent[st][1] if parent[st] else "Init", st))
                st = parent[st][0] if parent[st] else None
            return trace[::-1], len(parent)
        for label, nxt in successors(st):
            if nxt not in parent:
                parent[nxt] = (st, label)
                queue.append(nxt)
    return None, len(parent)


# ------------------------------------------------------------------------------ report

CASES = []      # every case with its result, for --json
SYSTEMS = {}    # case id -> System


def verdict(path):
    return "holds" if path is None else f"broken in {len(path)} round{'s' * (len(path) > 1)}"


def report(case_id, system, traces, quiet=False):
    first, states = explore(system)
    SYSTEMS[case_id] = system
    CASES.append({"id": case_id, "system": system.as_data(),
                  "G1": first["G1"] and len(first["G1"]), "G2": first["G2"] and len(first["G2"])})
    if not quiet:
        print(f"  {system.name:<46} f={system.f}  G1 {verdict(first['G1']):<19} "
              f"G2 {verdict(first['G2']):<19} ({states} states)")
        if traces:
            for goal in ("G1", "G2"):
                if first[goal]:
                    print(f"    shortest execution breaking {goal}:")
                    show(first[goal], "      ")
    return first


CANONICAL = [   # the executions written out in the write-up, replayed here
    ("P1", [[("stop", "M1")], [("mutate", "W1")]]),
    ("P2", [[("fail-substrate", "s1")]]),
    ("P3", [[("mutate", "W1")]]),
    ("P4", [[("mutate", "W1")]]),
    ("P5", [[("disable", "M1")], [("mutate", "W1")]]),
    ("P6", [[("stop-boundary", 1)], [("mutate", "W1")]]),
    ("P7", [[("join", "J")], [("mutate", "J")]]),
    ("P8", [[("mutate", "W1")]]),
    ("P8b", [[("mutate", "M1")]]),
    ("gate", [[("mutate", "W1")], []]),
]


def broken(rounds):
    goals = sorted({g for _, info in rounds for g in ("G1", "G2") if info[g]})
    return " and ".join(goals) or "nothing"


def main():
    traces = "--traces" in sys.argv

    print("1. Reference system R, every property present")
    for f in (1, 2, 3):
        report(f"R/f{f}", reference(f=f), traces)

    print("\n2. R with one property removed (f = 1)")
    for p in PROPS:
        report(f"R-{p}/f1", reference(without=(p,)), traces)

    print("\n3. The executions in the write-up, replayed (f = 1)")
    for p, schedule in CANONICAL:
        rounds, _ = replay(reference(without=(p,)), schedule)
        full, why = replay(reference(), schedule)
        in_full = {"done": f"breaks {broken(full)}",
                   "ended": f"breaks {broken(full)}: the model ends in a complete response "
                            f"after round {len(full)}",
                   "no such step": "has a step that does not exist there"}[why]
        print(f"  without {p:<4}: breaks {broken(rounds)}; the same schedule in full R {in_full}")
        if traces:
            show(rounds)

    print("\n4. The same missing edge at two tiers")
    report("R+unread/f1", reference(unread_extra=True), traces)
    for f in (1, 2):
        report(f"mesh3-unread-M3/f{f}", mesh(3, f, unread="M3"), traces)

    print("\n5. How many monitors: a mesh of n, one work process that reads all of them")
    for n in (1, 2, 3, 4):
        for f in (1, 2, 3):
            report(f"mesh{n}/f{f}", mesh(n, f), traces)

    print("\n6. Report chains inside one ring")
    for n, rep, gate, f in ((2, "other", 2, 1), (3, "other", 2, 1), (3, "same", 2, 1),
                            (3, "same", 3, 1), (3, "other", 1, 1), (3, "other", 2, 2),
                            (3, "other", 3, 2), (3, "other", 3, 3)):
        report(f"ring{n}-{rep}-gate{gate}/f{f}", ring(n, rep, gate, f), traces)

    print("\n7. Three monitors plus a coordinator K, one ring")
    for gate in (["K"], ["K", "M1"], ["K", "M1", "M2", "M3"]):
        report(f"3+K-gate{'+'.join(gate)}/f1", with_coordinator(gate), traces)

    print("\n8. Nested rings: two base rings joined by an upper ring through coordinators")
    for size, upper3, f in ((3, True, 1), (1, False, 1), (1, False, 2)):
        report(f"nested{size}-upper{3 if upper3 else 2}/f{f}", nested(size, upper3, f), traces)

    base = nested(3, True, 1)
    needed, spare = [], []
    for label, system in ablations(base):
        first = report(f"nested3-upper3/f1/minus: {label}", system, False, quiet=True)
        if first["G1"] or first["G2"]:
            needed.append((label, first))
        else:
            spare.append(label)
    print(f"  Removing one edge from 'nested, base rings 3+K, upper ring of 3' (f = 1): "
          f"{len(needed)} of {len(needed) + len(spare)} removals break a goal")
    for label, first in needed:
        goals = " and ".join(g for g in ("G1", "G2") if first[g])
        print(f"    needed: {label:<32} (its removal breaks {goals})")
    for label in spare:
        print(f"    spare:  {label}")

    print("\n8b. Scope: one environment step stops everything inside one boundary")
    report("mesh4-one-boundary/f1", mesh(4, 1, one_boundary=True), traces)
    report("nested3-upper3-ring-boundaries/f1", nested(3, True, 1, ring_boundaries=True), traces)

    print("\n8c. The reflex: where the halt comes from when reports take time")
    for direct in (True, False):
        for slow in (False, True):
            report(f"reflex-{'direct' if direct else 'relayed'}-{'slow' if slow else 'instant'}/f1",
                   reflex(direct, slow), traces)

    print("\n9. Growth against response time: one bad process, doubling every tick")
    for n in (1024, 1048576):
        print(f"  {n} processes")
        for w in (0, 1, 2, 5):
            print(f"    all halt together {w} ticks after detection: "
                  f"{growth(n, 'window', w)} bad")
        for fan, hops in ((1, 1), (1, 16), (1, 128), (2, 1), (2, 2), (2, 4)):
            d = growth(n, "cascade", fan, hops)
            print(f"    halt passed to {fan} per hop, {hops} hops per tick: "
                  f"{d} bad ({100 * d / n:.2f}%)")

    print("\n10. Heartbeat.tla, mirrored")
    for hb in (True, False):
        trace, states = heartbeat_spec(["m1", "m2"], hb)
        if trace is None:
            print(f"  HB = {hb}: invariant holds in all {states} reachable states")
        else:
            print(f"  HB = {hb}: invariant broken, shortest trace has {len(trace)} states")
            for i, (label, st) in enumerate(trace, 1):
                alive, bad, flagged, turn, halted = st
                print(f"    {i}. {label:<9} alive={{{','.join(sorted(alive))}}} bad={bad} "
                      f"flagged={{{','.join(sorted(flagged))}}} turn={turn} halted={halted}")

    print()
    print("10b. Restarting: members that run only while another member observes them")
    ring3 = {"X1": ["X3"], "X2": ["X1"], "X3": ["X2"]}
    mesh3 = {"X1": ["X2", "X3"], "X2": ["X1", "X3"], "X3": ["X1", "X2"]}
    with_k = {"X1": ["X3", "K"], "X2": ["X1", "K"], "X3": ["X2", "K"],
              "K": ["X1", "X2", "X3"]}
    for name, obs, selfs in (
            ("ring of 3, each observed by the one before it", ring3, ()),
            ("mesh of 3, each observed by the other two", mesh3, ()),
            ("ring of 3 plus K; K observes all and starts by itself", with_k, ("K",)),
            ("the same four, K not able to start by itself", with_k, ())):
        stuck, states = restart_game(obs, selfs)
        print(f"  {name} ({states} states): "
              + ("can always restart" if stuck is None
                 else "cannot restart after: " + ", ".join(stuck)))

    print("\n11. The sufficiency conditions (a) to (d) against the search, plain systems, f = 1")
    tally = {(True, True): 0, (True, False): 0, (False, True): 0, (False, False): 0}
    for case in CASES:
        system = SYSTEMS[case["id"]]
        if is_plain(system) and system.f == 1:
            tally[(sufficient_f1(system), case["G1"] is None and case["G2"] is None)] += 1
    print(f"  conditions hold, both goals hold:      {tally[(True, True)]}")
    print(f"  conditions hold, a goal is broken:     {tally[(True, False)]}   (must be 0)")
    print(f"  conditions fail, both goals hold:      {tally[(False, True)]}")
    print(f"  conditions fail, a goal is broken:     {tally[(False, False)]}")

    print()
    print("12. Census: plain systems with one work process, f = 1")
    words = {"Q1": "every monitor's signal is read by another monitor",
             "Q1f": "... or by a work process that halts on its silence",
             "Q3": "every process has a state checker other than itself",
             "Q4": "a flag reaches every other monitor",
             "Q4r": "a flag reaches a halt source of every work process",
             "Q8": "every work process has two different halt sources"}
    for n, count, label in ((2, None, "every system with 2 monitors"),
                            (3, 6000, "a sample of systems with 3 monitors")):
        total, free, fails, stays, example = census(n, count)
        print(f"  {label}: {total} systems, {free} with no gap")
        for name in CENSUS_NAMES:
            print(f"    {name:<4} {words[name]:<52} fails in {fails[name]:>4}, "
                  f"of which not down to spare monitors: {stays[name]}")
        for name, s in example.items():
            print(f"    example for {name}: " + "; ".join(
                f"{rel} {dict((k, v) for k, v in getattr(s, rel).items())}" for rel in RELATIONS))

    if "--json" in sys.argv:
        path = sys.argv[sys.argv.index("--json") + 1]
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(CASES, fh, indent=1)
        print(f"\nwrote {len(CASES)} cases to {path}")
    if "--systems" in sys.argv:
        path = sys.argv[sys.argv.index("--systems") + 1]
        with open(path, "w", encoding="utf-8") as fh:
            json.dump([{"id": c["id"], "system": c["system"]} for c in CASES], fh, indent=1)
        print(f"wrote {len(CASES)} systems to {path}")


if __name__ == "__main__":
    main()
