#!/usr/bin/env python3
"""Explicit-state check of the eight-property model.

A helper script, standard library only. For each small system below it explores every
reachable state and reports the shortest execution, if any, that breaks a goal:

  G1  detection: at the end of a round, if some process's state is bad, then some live,
      correct monitor is flagged.
  G2  halt: no work process takes a work step while some process's state is bad.

One round is: the environment takes up to f steps, then every monitor steps once and flags
travel along report edges, then every work process steps once. The model ends at the first
complete response (some live, correct monitor flagged and every work process halted).
The semantics are specified in model-spec.md.

Run:  python -I check_model.py                  summary tables
      python -I check_model.py --traces         also print every execution
      python -I check_model.py --json OUT.json  also write every case and its result
      python -I check_model.py --systems S.json also write every case without its result
"""
import copy
import json
import sys
from collections import deque, namedtuple

State = namedtuple("State", "alive bad hidden off flagged halted pending joined")
PROPS = ("P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8", "P8b")
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

    def as_data(self):
        return {k: v for k, v in vars(self).items()}


def present(system, s):
    procs = system.monitors + system.works
    return procs + [system.joiner] if s.joined else procs


def initial(system):
    empty = frozenset()
    return State(frozenset(system.monitors + system.works), empty, empty, empty, empty,
                 empty, empty, False)


def env_steps(system, s):
    """Every environment step enabled in s."""
    steps = []
    procs = present(system, s)
    for m in system.monitors:
        if m in s.alive:
            steps.append(("stop", m))
    for b in sorted(set(system.boundary.values())):
        members = [m for m in system.monitors if system.boundary.get(m) == b]
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
        if m not in s.off:
            steps.append(("disable", m))
    if system.joiner and not s.joined:
        steps.append(("join", system.joiner))
    return steps


def apply_env(system, s, step):
    kind, arg = step
    alive, bad, hidden, off, joined = set(s.alive), set(s.bad), set(s.hidden), set(s.off), s.joined
    if kind == "stop":
        alive.discard(arg)
    elif kind == "stop-boundary":
        for m in system.monitors:
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
    elif kind == "join":
        joined = True
        alive.add(arg)
    return s._replace(alive=frozenset(alive), bad=frozenset(bad), hidden=frozenset(hidden),
                      off=frozenset(off), joined=joined)


def process_phase(system, s):
    """Monitor round, flag propagation, then work round. Returns (state, info)."""
    # A monitor acts only if it is live, correct (not mutated) and not switched off.
    active = {m for m in system.monitors if m in s.alive and m not in s.bad and m not in s.off}
    visible = s.bad - s.hidden
    flagged = set(s.flagged)
    for m in active:
        sees_state = any(m in system.checkers.get(x, ()) for x in visible)
        sees_silence = any(m in system.hb_readers.get(p, ())
                           for p in system.monitors if p not in s.alive)
        if sees_state or sees_silence:
            flagged.add(m)
    changed = True
    while changed:                      # a flag travels along report edges, through
        changed = False                 # active monitors only, within the round
        for m in list(flagged):
            if m in active:
                for r in system.fwd.get(m, ()):
                    if r in active and r not in flagged:
                        flagged.add(r)
                        changed = True
    # A stopped monitor emits nothing; a mutated one shows nominal whatever it latched.
    out = {m for m in flagged if m in s.alive and m not in s.bad}

    halted, pending, executed = set(s.halted), set(s.pending), []
    for w in present(system, s):
        if w in system.monitors or w in halted:
            continue
        if w in pending:                # the evaluation window has passed
            pending.discard(w)
            halted.add(w)
            continue
        inputs = system.halt_inputs.get(w, ())
        sees = any(m in out for m in inputs) or (
            system.coupling and any(m not in s.alive for m in inputs))
        if sees and system.window == 0:
            halted.add(w)
        else:
            if sees:
                pending.add(w)
            executed.append(w)
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


def explore(system):
    """Breadth-first over rounds. Returns ({goal: shortest violating path}, states seen)."""
    start = initial(system)
    parent = {start: None}
    queue = deque([start])
    first = {"G1": None, "G2": None}

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
        for steps, after_env in env_choices(system, s):
            t, info = process_phase(system, after_env)
            for goal in first:
                if info[goal] and first[goal] is None:
                    first[goal] = path_to(s) + [(steps, info)]
            if t not in parent:
                parent[t] = (s, steps, info)
                queue.append(t)
    return first, len(parent)


def replay(system, schedule):
    """Run a given environment schedule (a list of rounds, each a list of steps).
    Returns None if some step is not enabled in this system."""
    s = initial(system)
    rounds = []
    for steps in schedule:
        for e in steps:
            if e not in env_steps(system, s):
                return None
            s = apply_env(system, s, e)
        s, info = process_phase(system, s)
        rounds.append((tuple(steps), info))
    return rounds


def show(rounds, indent="    "):
    for i, (steps, info) in enumerate(rounds, 1):
        env = ", ".join(f"{k} {a}" for k, a in steps) or "(none)"
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

    if unread_extra:                    # a fourth monitor whose silence nobody reads
        r.name += " plus unread M4"
        r.monitors.append("M4")
        r.boundary["M4"] = 4
        r.checkers["W1"].append("M4")
        r.checkers["M4"] = ["M1", "M2"]
        r.fwd["M4"] = ["M1", "M2", "M3"]
    return r


def mesh(n, f=1):
    """n monitors that all check each other, and one work process they all check and halt."""
    s = System(f"mesh of {n}", f)
    s.monitors = [f"M{i}" for i in range(1, n + 1)]
    s.works = ["W"]
    s.boundary = {m: i for i, m in enumerate(s.monitors)}
    for m in s.monitors:
        rest = [x for x in s.monitors if x != m]
        s.hb_readers[m] = rest
        s.checkers[m] = rest
        s.fwd[m] = rest
    s.checkers["W"] = list(s.monitors)
    s.halt_inputs = {"W": list(s.monitors)}
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
    """Three mutually checking monitors plus a coordinator K with a surface view."""
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


def nested(size=3, upper3=True, f=1):
    """Two base rings A and B, each `size` members plus a coordinator, joined by an upper
    ring made of the two coordinators (and a third member U3 when upper3).

    In a base ring each member checks the next member and reports to the member it does
    not check and to the coordinator. The coordinator reads every member's signal, reports
    to every member, and is checked by the first member. Each work process is checked by
    the first member of its ring and takes its halt from that member and the coordinator.
    In the upper ring each member checks the next and reports to the one it does not check.
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


# --------------------------------------------------------- growth against response time

def growth(n, policy, a, b=1):
    """One latent bad process among n running ones. Each tick, every bad process still
    running makes one more running process bad. A halt starts at tick 0.

    policy "window":   every process halts together, `a` ticks after detection
    policy "cascade":  each process the halt reaches passes it to `a` more, and the halt
                       makes `b` hops per tick; it reaches good processes first (the
                       worst order)
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


# --------------------------------------------------- mirror of Heartbeat.tla (section 7)

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

CASES = []      # (case id, system, result) for --json


def verdict(path):
    return "holds" if path is None else f"broken in {len(path)} round{'s' * (len(path) > 1)}"


def report(case_id, system, traces, quiet=False):
    first, states = explore(system)
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
        rounds = replay(reference(without=(p,)), schedule)
        full = replay(reference(), schedule)
        print(f"  without {p:<3}: breaks {broken(rounds)}; the same schedule in full R "
              + (f"breaks {broken(full)}" if full else "has a step that does not exist there"))
        if traces:
            show(rounds)

    print("\n4. A property can fail with no violation")
    report("R+unread/f1", reference(unread_extra=True), traces)

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
