#!/usr/bin/env python3
"""The model of model-spec.md and model-spec-join.md, with the extension of
model-spec-scope.md, on bit masks.

A helper script, standard library only. It is built on fast_join.py (the second
implementation of the join model check), with these additions:

  - a process listed in `works` may be a member of a late group (model-spec-scope.md, X1);
  - scopes: a flag carries the scope it was raised for, the two judgements are made per
    scope, and two further observations are made, `told` and `spill` (X2 to X8).

A system with no `scope` field is a system of the two earlier files and gives the same G1
and G2 as fast_join.py and as verify-impl\\model.py (mr_crosscheck.py compares them).

    from mr_model import explore
    r = explore(system_dict)
    r["G1"], r["G2"]            least number of rounds over the scopes, or None
    r["scopes"][s]["G1" | "G2" | "told"]   per scope, least number of rounds or None
    r["spill"]                  least number of rounds, or None
    r["traces"][(kind, scope)]  the shortest schedule for each

Run:  python -B mr_model.py SYSTEMS.json OUT.json     answers for a catalogue
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
        if len(set(self.names)) != len(self.names):
            raise ValueError("process names are not distinct")
        ix = {n: i for i, n in enumerate(self.names)}
        self.ix = ix
        self.nm = len(mons)
        self.n = len(self.names)
        self.monmask = (1 << self.nm) - 1
        self.joiner = ix[joiner] if joiner is not None else None
        self.groups = []
        late = 0
        for g in d.get("late") or []:
            members = sum(1 << ix[p] for p in g["members"])
            if members & late:
                raise ValueError("a process is in two groups")
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
        n = self.n
        self.edges = {}
        for rel in RELATIONS:
            table = [0] * n
            for k, v in (d.get(rel) or {}).items():
                if k in ix:
                    for m in v:
                        if ix[m] >= self.nm:
                            raise ValueError(f"{m} is not a monitor")
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
        self.freeze = d.get("freeze", False)
        self.max_rounds = d.get("max_rounds")
        self.force_cache = {}

        # ---- scopes (model-spec-scope.md)
        scope = d.get("scope") or {}
        self.scoped = bool(scope)
        nonmon = ((1 << n) - 1) & ~self.monmask
        if not self.scoped:
            if d.get("scope_work") or d.get("told"):
                raise ValueError("scope_work or told without scope")
            self.scope_ids = [None]
            self.scope_of = [0] * n
            self.scope_mask = [(1 << n) - 1]
            self.work_mask = [nonmon]
            self.told_mask = [0]
        else:
            missing = [p for p in self.names if p not in scope]
            if missing:
                raise ValueError(f"no scope for {missing}")
            ids = {json.dumps(v): v for v in scope.values()}
            for k in list((d.get("scope_work") or {})) + list((d.get("told") or {})):
                ids.setdefault(json.dumps(k), k)
            order = sorted(ids)
            self.scope_ids = [ids[k] for k in order]
            sx = {k: i for i, k in enumerate(order)}
            self.scope_of = [sx[json.dumps(scope[p])] for p in self.names]
            self.scope_mask = [0] * len(order)
            for i, s in enumerate(self.scope_of):
                self.scope_mask[s] |= 1 << i
            self.work_mask = [m & nonmon for m in self.scope_mask]
            for k, v in (d.get("scope_work") or {}).items():
                mask = 0
                for w in v:
                    if ix[w] < self.nm:
                        raise ValueError(f"{w} in scope_work is a monitor")
                    mask |= 1 << ix[w]
                self.work_mask[sx[json.dumps(k)]] = mask
            self.told_mask = [0] * len(order)
            for k, v in (d.get("told") or {}).items():
                mask = 0
                for m in v:
                    if ix[m] >= self.nm:
                        raise ValueError(f"{m} in told is not a monitor")
                    mask |= 1 << ix[m]
                self.told_mask[sx[json.dumps(k)]] = mask
        self.ns = len(self.scope_ids)
        # covers[w]: the scopes whose work w is
        self.covers = [[s for s in range(self.ns) if (self.work_mask[s] >> p) & 1]
                       for p in range(n)]
        # cover_procs[w]: the processes whose scope covers w
        self.cover_procs = [sum(self.scope_mask[s] for s in self.covers[p]) for p in range(n)]

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


# A state is (alive, bad, hidden, off, flagged, halted, pending, present, closed).
# flagged packs one mask of monitors per scope: scope s sits at bit s * nm.

def initial(c):
    return (c.start, 0, 0, 0, 0, 0, 0, c.start, 0)


def env_steps(c, s):
    """Every enabled environment step as (label, state)."""
    alive, bad, hidden, off, flagged, halted, pending, present, closed = s
    out = []
    # free: the processes a fault may land on. With `freeze`, not those of a closed scope.
    free = (1 << c.n) - 1
    if c.freeze and closed:
        for sc in bits(closed):
            free &= ~c.scope_mask[sc]
    for m in bits(alive & c.monmask & free):
        out.append((("stop", c.names[m]),
                    (alive & ~(1 << m), bad, hidden, off, flagged, halted, pending, present,
                     closed)))
    for b, mask in c.boundaries:
        here = mask & present
        if here & (here - 1) and here & alive & free:
            out.append((("stop-boundary", b),
                        (alive & ~(here & free), bad, hidden, off, flagged, halted, pending,
                         present, closed)))
    for sub, mask in c.substrates:
        here = mask & present
        mons, rest = here & c.monmask & free, here & ~c.monmask & free
        if mons & alive or rest & ~bad:
            out.append((("fail-substrate", sub),
                        (alive & ~mons, bad | rest, hidden | rest, off, flagged, halted,
                         pending, present, closed)))
    for p in bits(present & ~bad & free):
        out.append((("mutate", c.names[p]),
                    (alive, bad | 1 << p, hidden, off, flagged, halted, pending, present,
                     closed)))
    for m in bits(c.switches & present & ~off & free):
        out.append((("disable", c.names[m]),
                    (alive, bad, hidden, off | 1 << m, flagged, halted, pending, present,
                     closed)))
    # with `freeze`, nothing joins a closed scope either
    if c.lone_joiner and not (present >> c.joiner) & 1 and (free >> c.joiner) & 1:
        j = 1 << c.joiner
        out.append((("join", c.names[c.joiner]),
                    (alive | j, bad, hidden, off, flagged, halted, pending, present | j,
                     closed)))
    for name, members, after, monitor_members in c.groups:
        if members & ~present and not after & ~present and not members & ~free:
            joined = (alive | members, bad, hidden, off, flagged, halted, pending,
                      present | members, closed)
            out.append((("join", name), joined))
            if c.arrive_bad:
                for m in monitor_members:
                    out.append((("join-bad", (name, c.names[m])),
                                (joined[0], bad | 1 << m) + joined[2:]))
    return out


def round_end(c, before_present, s):
    """The monitor and work phases on the state after the environment phase.

    Returns (state, g1, g2, told, spill, outs, worked): g1, g2 and told are masks of
    scopes whose judgement the round violated, spill is the mask of work processes that
    spilled, outs is the list of out[s], worked the mask of processes that took a work
    step."""
    alive, bad, hidden, off, flagged, halted, pending, present, closed = s
    hb, chk, fwd, halt = c.in_force(present, present & ~before_present)
    mm, nm, ns = c.monmask, c.nm, c.ns
    active = alive & ~bad & ~off & mm
    halted0, pending0 = halted, pending

    def work(outs):
        nonlocal halted, pending
        worked = 0
        for w in bits(present & ~mm & ~halted):
            bit = 1 << w
            if pending & bit:
                pending &= ~bit
                halted |= bit
                continue
            o = 0
            for sc in c.covers[w]:
                o |= outs[sc]
            sees = bool(halt[w] & o) or (c.coupling and bool(halt[w] & ~alive))
            if sees and c.window == 0:
                halted |= bit
            else:
                if sees:
                    pending |= bit
                worked |= bit
        return worked

    fl = [(flagged >> (sc * nm)) & mm for sc in range(ns)]
    if not c.gate:
        worked = work([x & alive & ~bad for x in fl])
    visible = bad & ~hidden
    silent = present & mm & ~alive
    outs = []
    packed = 0
    for sc in range(ns):
        here = c.scope_mask[sc]
        detect = 0
        for x in bits(visible & here):
            detect |= chk[x]
        for p in bits(silent & here):
            detect |= hb[p]
        detect &= active
        f_s = fl[sc]
        if c.slow_reports:
            passed = 0
            for m in bits(f_s & active):
                passed |= fwd[m]
            f_s |= detect | (passed & active)
        else:
            f_s |= detect
            todo = f_s & active
            while todo:
                m = todo.bit_length() - 1
                todo &= ~(1 << m)
                fresh = fwd[m] & active & ~f_s
                f_s |= fresh
                todo |= fresh
        packed |= f_s << (sc * nm)
        outs.append(f_s & alive & ~bad)
    if c.gate:
        worked = work(outs)
    g1 = g2 = told = 0
    newly_closed = 0
    for sc in range(ns):
        bit = 1 << sc
        if not closed & bit:
            if bad & c.scope_mask[sc]:
                if not outs[sc]:
                    g1 |= bit
                if worked & c.work_mask[sc]:
                    g2 |= bit
                listed = c.told_mask[sc]
                if listed & alive & ~bad and not listed & outs[sc]:
                    told |= bit
            if outs[sc] and not c.work_mask[sc] & present & ~halted:
                newly_closed |= bit
    spill = 0
    faulty = bad | silent
    for w in bits((halted | pending) & ~(halted0 | pending0)):
        if not faulty & c.cover_procs[w]:
            spill |= 1 << w
    t = (alive, bad, hidden, off, packed, halted, pending, present, closed | newly_closed)
    return t, g1, g2, told, spill, outs, worked


def responded(c, s):
    alive, bad, _, _, flagged, halted, _, present, _ = s
    some = 0
    for sc in range(c.ns):
        some |= (flagged >> (sc * c.nm)) & c.monmask
    return bool(some & alive & ~bad) and not present & ~c.monmask & ~halted


def env_choices(c, s):
    """One (state -> steps) entry for each distinct state reachable in 0..f steps."""
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


def explore(system, stop="never", max_states=None, max_rounds=None, canon=None):
    """Breadth-first over rounds.

    stop: "never" explores every reachable state; "gap" stops at the first round that
    violates G1 or G2 of any scope; "any" stops at the first violation of any kind; "both"
    stops once G1 and G2 each have a violation (the least numbers of rounds are then
    exact for G1 and G2, as in fast_join.py).
    max_states and max_rounds bound the search; `bounded` is then true and a None is not a
    result. canon, if given, maps a state to the representative of its class under a
    symmetry of the system.
    """
    c = system if isinstance(system, Compiled) else Compiled(system)
    if max_rounds is None:
        max_rounds = c.max_rounds
    start = initial(c)
    if canon:
        start = canon(start)
    parent = {start: None}
    depth = {start: 0}
    queue = deque([start])
    first = {}
    bounded = False
    round_bounded = False
    state_bounded = False
    deepest = 0

    def path_to(s):
        rounds = []
        while parent[s] is not None:
            s, steps = parent[s]
            rounds.append(steps)
        return rounds[::-1]

    def note(kind, mask, s, steps):
        for sc in bits(mask):
            key = (kind, sc)
            if key not in first:
                first[key] = path_to(s) + [steps]

    done = False
    while queue and not done:
        if max_states is not None and len(parent) > max_states:
            bounded = True
            state_bounded = True
            break
        s = queue.popleft()
        if responded(c, s):
            continue
        d = depth[s]
        if max_rounds is not None and d >= max_rounds:
            bounded = True
            round_bounded = True
            continue
        deepest = max(deepest, d + 1)
        for after_env, steps in env_choices(c, s).items():
            t, g1, g2, told, spill, _, _ = round_end(c, s[7], after_env)
            if g1:
                note("G1", g1, s, steps)
            if g2:
                note("G2", g2, s, steps)
            if told:
                note("told", told, s, steps)
            if spill and ("spill", 0) not in first:
                first[("spill", 0)] = path_to(s) + [steps]
            if (stop == "gap" and (g1 or g2)) or (stop == "any" and (g1 or g2 or told or spill)):
                done = True
                break
            if stop == "both" and any(k == "G1" for k, _ in first)                     and any(k == "G2" for k, _ in first):
                done = True
                break
            if canon:
                t = canon(t)
            if t not in parent:
                parent[t] = (s, steps)
                depth[t] = d + 1
                queue.append(t)

    def least(kind):
        ns = [len(v) for (k, _), v in first.items() if k == kind]
        return min(ns) if ns else None

    scopes = {}
    for sc, sid in enumerate(c.scope_ids):
        scopes[sid] = {k: (len(first[(k, sc)]) if (k, sc) in first else None)
                       for k in ("G1", "G2", "told")}
    traces = {}
    for (kind, sc), v in first.items():
        traces[(kind, c.scope_ids[sc] if kind != "spill" else None)] = v
    return {"G1": least("G1"), "G2": least("G2"), "told": least("told"),
            "spill": least("spill"), "scopes": scopes, "traces": traces,
            "states": len(parent), "bounded": bounded, "rounds": deepest,
            "state_bounded": state_bounded, "round_bounded": round_bounded,
            "stopped_early": done}


def replay(system, schedule):
    """Run a schedule (a list of rounds, each a list of step labels as explore returns
    them). Returns one dict per round run."""
    c = Compiled(system)
    s = initial(c)
    rows = []

    def names(mask):
        return [c.names[i] for i in bits(mask)]

    for steps in schedule:
        if responded(c, s):
            rows.append({"ended": True})
            break
        before = s[7]
        for label in steps:
            label = tuple(label)
            options = {lab: t for lab, t in env_steps(c, s)}
            key = (label[0], tuple(label[1]) if isinstance(label[1], list) else label[1])
            if key not in options:
                raise ValueError(f"step {key} is not enabled")
            s = options[key]
        closed0 = s[8]
        s, g1, g2, told, spill, outs, worked = round_end(c, before, s)
        rows.append({
            "steps": [list(x) for x in steps], "bad": names(s[1]),
            "stopped": names(s[7] & c.monmask & ~s[0]),
            "flagged": {str(c.scope_ids[sc]): names(outs[sc]) for sc in range(c.ns)
                        if outs[sc]},
            "flagged_any": names(_union(outs)),
            "halted": names(s[5]), "worked": names(worked),
            "G1": [c.scope_ids[sc] for sc in bits(g1)],
            "G2": [c.scope_ids[sc] for sc in bits(g2)],
            "told": [c.scope_ids[sc] for sc in bits(told)],
            "spill": names(spill),
            "closed": [c.scope_ids[sc] for sc in bits(s[8])],
            "closed_before": [c.scope_ids[sc] for sc in bits(closed0)],
            "present": names(s[7]), "responded": responded(c, s)})
    return rows


def _union(masks):
    u = 0
    for m in masks:
        u |= m
    return u


def answer(system, **kw):
    """The entry for results-minimal.json: G1 and G2 as in model-spec.md; for a system
    with scopes also the per-scope results and spill (model-spec-scope.md, X9)."""
    r = explore(system, **kw)
    if r["state_bounded"] or (r["round_bounded"] and system.get("max_rounds") is None):
        raise RuntimeError("search bounded")
    out = {"G1": r["G1"], "G2": r["G2"]}
    if system.get("scope"):
        out["scopes"] = {str(k): v for k, v in r["scopes"].items()}
        out["spill"] = r["spill"]
    return out


def main():
    systems = json.load(open(sys.argv[1], encoding="utf-8"))
    answers = []
    for case in systems:
        a = answer(case["system"])
        a = {"id": case["id"], **a}
        answers.append(a)
    with open(sys.argv[2], "w", encoding="utf-8") as fh:
        json.dump(answers, fh, indent=1)
    print(f"wrote {len(answers)} answers to {sys.argv[2]}")


if __name__ == "__main__":
    main()
