#!/usr/bin/env python3
"""A second implementation of model-spec.md with model-spec-join.md, on bit masks.

A helper script, standard library only. It was written from the two specification files,
not from check_model_join.py, and shares no code with it. It is used for the larger sweeps
because it is quicker, and every catalogue result is computed by both (join_runs.py compares
them). It takes a system as the JSON object of the specification.

    from fast_join import explore
    result = explore(system_dict)            # {"G1": n or None, "G2": n or None, ...}

Run:  python -I fast_join.py SYSTEMS.json OUT.json    answers for a catalogue
"""
import json
import sys
from collections import deque

RELATIONS = ("hb_readers", "checkers", "fwd", "halt_inputs")


def bits(mask):
    i = 0
    while mask:
        if mask & 1:
            yield i
        mask >>= 1
        i += 1


class Compiled:
    """A system turned into masks. Process i is bit 1 << i; monitors come first."""

    def __init__(self, d):
        self.f = d["f"]
        mons, works, joiner = list(d["monitors"]), list(d["works"]), d.get("joiner")
        self.names = mons + works + ([joiner] if joiner is not None else [])
        ix = {n: i for i, n in enumerate(self.names)}
        self.ix = ix
        self.nm = len(mons)
        self.monmask = (1 << self.nm) - 1
        self.joiner = ix[joiner] if joiner is not None else None
        self.groups = []
        late = 0
        for g in d.get("late") or []:
            members = sum(1 << ix[p] for p in g["members"])
            after = sum(1 << ix[p] for p in g.get("after") or [])
            self.groups.append((g["name"], members, after,
                                [ix[p] for p in g["members"] if ix[p] < self.nm]))
            late |= members
        self.late = late
        self.lone_joiner = self.joiner is not None and not (late >> self.joiner) & 1
        self.start = (self.monmask | sum(1 << ix[w] for w in works)) & ~late
        by_b = {}
        for m, b in (d.get("boundary") or {}).items():
            by_b.setdefault(json.dumps(b), [b, 0])[1] |= 1 << ix[m]
        self.boundaries = sorted(by_b.values(), key=lambda v: json.dumps(v[0]))
        by_s = {}
        for p, s in (d.get("substrate") or {}).items():
            if p in ix:
                by_s.setdefault(json.dumps(s), [s, 0])[1] |= 1 << ix[p]
        self.substrates = sorted(by_s.values(), key=lambda v: json.dumps(v[0]))
        self.switches = sum(1 << ix[m] for m in d.get("switches") or [])
        n = len(self.names)
        self.edges = {}
        for rel in RELATIONS:
            table = [0] * n
            for k, v in (d.get(rel) or {}).items():
                if k in ix:
                    for m in v:
                        table[ix[k]] |= 1 << ix[m]
            self.edges[rel] = table
        self.slow = {rel: [0] * n for rel in RELATIONS}
        self.any_slow = False
        for rel, k, m in d.get("slow_edges") or []:
            if not (self.edges[rel][ix[k]] >> ix[m]) & 1:
                raise ValueError(f"slow edge {rel, k, m} is not an edge of the system")
            self.slow[rel][ix[k]] |= 1 << ix[m]
            self.any_slow = True
        self.coupling = d["coupling"]
        self.window = d["window"]
        self.gate = d.get("gate", True)
        self.slow_reports = d.get("slow_reports", False)
        self.arrive_bad = d.get("arrive_bad", False)
        self.force_cache = {}

    def in_force(self, present, new):
        key = (present, new)
        hit = self.force_cache.get(key)
        if hit is None:
            hit = []
            for rel in RELATIONS:
                table = []
                for k, mask in enumerate(self.edges[rel]):
                    if not (present >> k) & 1:
                        table.append(0)
                        continue
                    mask &= present
                    if (new >> k) & 1:
                        mask &= ~self.slow[rel][k]
                    else:
                        mask &= ~(self.slow[rel][k] & new)
                    table.append(mask)
                hit.append(table)
            self.force_cache[key] = hit
        return hit


# A state is (alive, bad, hidden, off, flagged, halted, pending, present).

def initial(c):
    return (c.start, 0, 0, 0, 0, 0, 0, c.start)


def env_steps(c, s):
    """Every enabled environment step as (label, state)."""
    alive, bad, hidden, off, flagged, halted, pending, present = s
    out = []
    for m in bits(alive & c.monmask):
        out.append((("stop", c.names[m]),
                    (alive & ~(1 << m), bad, hidden, off, flagged, halted, pending, present)))
    for b, mask in c.boundaries:
        here = mask & present
        if here & (here - 1) and here & alive:
            out.append((("stop-boundary", b),
                        (alive & ~here, bad, hidden, off, flagged, halted, pending, present)))
    for sub, mask in c.substrates:
        here = mask & present
        mons, rest = here & c.monmask, here & ~c.monmask
        if mons & alive or rest & ~bad:
            out.append((("fail-substrate", sub),
                        (alive & ~mons, bad | rest, hidden | rest, off, flagged, halted,
                         pending, present)))
    for p in bits(present & ~bad):
        out.append((("mutate", c.names[p]),
                    (alive, bad | 1 << p, hidden, off, flagged, halted, pending, present)))
    for m in bits(c.switches & present & ~off):
        out.append((("disable", c.names[m]),
                    (alive, bad, hidden, off | 1 << m, flagged, halted, pending, present)))
    if c.lone_joiner and not (present >> c.joiner) & 1:
        j = 1 << c.joiner
        out.append((("join", c.names[c.joiner]),
                    (alive | j, bad, hidden, off, flagged, halted, pending, present | j)))
    for name, members, after, monitor_members in c.groups:
        if members & ~present and not after & ~present:
            joined = (alive | members, bad, hidden, off, flagged, halted, pending,
                      present | members)
            out.append((("join", name), joined))
            if c.arrive_bad:
                for m in monitor_members:
                    out.append((("join-bad", (name, c.names[m])),
                                (joined[0], bad | 1 << m) + joined[2:]))
    return out


def round_end(c, before_present, s):
    """The monitor and work phases on the state after the environment phase.
    Returns (state, G1 violated, G2 violated, out, worked)."""
    alive, bad, hidden, off, flagged, halted, pending, present = s
    hb, chk, fwd, halt = c.in_force(present, present & ~before_present)
    active = alive & ~bad & ~off & c.monmask

    def work(out):
        nonlocal halted, pending
        worked = 0
        for w in bits(present & ~c.monmask & ~halted):
            bit = 1 << w
            if pending & bit:
                pending &= ~bit
                halted |= bit
                continue
            sees = bool(halt[w] & out) or (c.coupling and bool(halt[w] & ~alive))
            if sees and c.window == 0:
                halted |= bit
            else:
                if sees:
                    pending |= bit
                worked |= bit
        return worked

    if not c.gate:
        worked = work(flagged & alive & ~bad)
    detect = 0
    for x in bits(bad & ~hidden):
        detect |= chk[x]
    for p in bits(present & c.monmask & ~alive):
        detect |= hb[p]
    detect &= active
    if c.slow_reports:
        passed = 0
        for m in bits(flagged & active):
            passed |= fwd[m]
        flagged |= detect | (passed & active)
    else:
        flagged |= detect
        todo = flagged & active
        while todo:
            m = todo.bit_length() - 1
            todo &= ~(1 << m)
            fresh = fwd[m] & active & ~flagged
            flagged |= fresh
            todo |= fresh
    out = flagged & alive & ~bad
    if c.gate:
        worked = work(out)
    t = (alive, bad, hidden, off, flagged, halted, pending, present)
    return t, bool(bad) and not out, bool(bad) and bool(worked), out, worked


def responded(c, s):
    alive, bad, _, _, flagged, halted, _, present = s
    return bool(flagged & alive & ~bad) and not present & ~c.monmask & ~halted


def env_choices(c, s):
    """One (steps, state) for each distinct state reachable in 0..f environment steps."""
    seen = {s: ()}
    frontier = [s]
    for _ in range(c.f):
        nxt = []
        for st in frontier:
            for label, t in env_steps(c, st):
                if t not in seen:
                    seen[t] = seen[st] + (label,)
                    nxt.append(t)
        frontier = nxt
    return seen


def explore(system, stop_early=True, max_states=None):
    """Breadth-first over rounds. Returns a dict with G1 and G2 (least number of rounds, or
    None), the shortest violating schedules, the number of states seen, and `bounded`, true
    when max_states stopped the search before it was complete (a None is then not a
    result). With stop_early the search ends once both goals have a shortest violation."""
    c = system if isinstance(system, Compiled) else Compiled(system)
    start = initial(c)
    parent = {start: None}
    depth = {start: 0}
    queue = deque([start])
    first = {"G1": None, "G2": None}
    bounded = False

    def path_to(s):
        rounds = []
        while parent[s] is not None:
            s, steps = parent[s]
            rounds.append(steps)
        return rounds[::-1]

    while queue:
        if stop_early and first["G1"] and first["G2"]:
            break
        if max_states is not None and len(parent) > max_states:
            bounded = True
            break
        s = queue.popleft()
        if responded(c, s):
            continue
        for after_env, steps in env_choices(c, s).items():
            t, g1, g2, _, _ = round_end(c, s[7], after_env)
            if g1 and first["G1"] is None:
                first["G1"] = path_to(s) + [steps]
            if g2 and first["G2"] is None:
                first["G2"] = path_to(s) + [steps]
            if t not in parent:
                parent[t] = (s, steps)
                queue.append(t)
    return {"G1": first["G1"] and len(first["G1"]), "G2": first["G2"] and len(first["G2"]),
            "trace_G1": first["G1"], "trace_G2": first["G2"], "states": len(parent),
            "bounded": bounded}


def replay(system, schedule):
    """Run a schedule (a list of rounds, each a list of step labels as explore returns
    them). Returns one dict per round run: the steps, and at the end of the round the names
    in bad, flagged (out), halted and worked, and which goals the round violated."""
    c = Compiled(system)
    s = initial(c)
    rows = []
    for steps in schedule:
        if responded(c, s):
            rows.append({"ended": True})
            break
        before = s[7]
        for label in steps:
            label = tuple(label) if not isinstance(label, tuple) else label
            options = {lab: t for lab, t in env_steps(c, s)}
            key = (label[0], tuple(label[1]) if isinstance(label[1], list) else label[1])
            if key not in options:
                raise ValueError(f"step {key} is not enabled")
            s = options[key]
        s, g1, g2, out, worked = round_end(c, before, s)

        def names(mask):
            return [c.names[i] for i in bits(mask)]
        rows.append({"steps": [list(x) for x in steps], "bad": names(s[1]),
                     "stopped": names(s[7] & c.monmask & ~s[0]), "flagged": names(out),
                     "halted": names(s[5]), "worked": names(worked), "G1": g1, "G2": g2,
                     "present": names(s[7]), "responded": responded(c, s)})
    return rows


def main():
    systems = json.load(open(sys.argv[1], encoding="utf-8"))
    answers = []
    for case in systems:
        r = explore(case["system"])
        answers.append({"id": case["id"], "G1": r["G1"], "G2": r["G2"]})
    with open(sys.argv[2], "w", encoding="utf-8") as fh:
        json.dump(answers, fh, indent=1)
    print(f"wrote {len(answers)} answers to {sys.argv[2]}")


if __name__ == "__main__":
    main()
