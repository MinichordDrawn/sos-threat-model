"""Reference implementation of model-spec.md (every field, both variants).

Written directly from the specification, favouring clarity over speed.
Standard library only.  Run as:  python -I model.py systems.json answers.json

result(system) -> {"G1": n or None, "G2": n or None, "witness": {...}}
"""
import json
import sys
from collections import namedtuple

State = namedtuple("State", "alive bad hidden off flagged halted pending joined")


class System:
    def __init__(self, d):
        self.name = d.get("name", "")
        self.f = d["f"]
        self.monitors = list(d.get("monitors") or [])
        self.joiner = d.get("joiner", None)
        # the joiner is kept apart from the work processes that are present at the start
        self.works = [w for w in (d.get("works") or []) if w != self.joiner]
        self.boundary = dict(d.get("boundary") or {})
        self.substrate = dict(d.get("substrate") or {})
        self.hb_readers = {k: frozenset(v) for k, v in (d.get("hb_readers") or {}).items()}
        self.checkers = {k: frozenset(v) for k, v in (d.get("checkers") or {}).items()}
        self.fwd = {k: frozenset(v) for k, v in (d.get("fwd") or {}).items()}
        self.halt_inputs = {k: frozenset(v) for k, v in (d.get("halt_inputs") or {}).items()}
        self.switches = list(d.get("switches") or [])
        self.coupling = bool(d["coupling"])
        self.window = d["window"]
        self.gate = d.get("gate", True)
        self.slow_reports = d.get("slow_reports", False)
        self.monset = frozenset(self.monitors)
        assert self.f >= 1 and self.window in (0, 1)

    def present(self, st):
        p = list(self.monitors) + list(self.works)
        if self.joiner is not None and st.joined:
            p.append(self.joiner)
        return p

    def present_nonmonitors(self, st):
        p = list(self.works)
        if self.joiner is not None and st.joined:
            p.append(self.joiner)
        return p


def initial_state(S):
    e = frozenset()
    return State(alive=frozenset(S.monitors) | frozenset(S.works), bad=e, hidden=e, off=e,
                 flagged=e, halted=e, pending=e, joined=False)


# ---------------------------------------------------------------- 3.1 environment phase
def env_successors(S, st):
    """Every single environment step enabled in st, as (label, new state)."""
    out = []
    present = S.present(st)
    # stop m
    for m in S.monitors:
        if m in st.alive:
            out.append((("stop", m), st._replace(alive=st.alive - {m})))
    # stop-boundary b
    seen = []
    for m in S.monitors:
        b = S.boundary.get(m, None)
        if b is None or b in seen:
            continue
        seen.append(b)
        members = [x for x in S.monitors if S.boundary.get(x, None) == b]
        if len(members) >= 2 and any(x in st.alive for x in members):
            out.append((("stop-boundary", b), st._replace(alive=st.alive - frozenset(members))))
    # fail-substrate s
    seen = []
    for p in present:
        s = S.substrate.get(p, None)
        if s is None or s in seen:
            continue
        seen.append(s)
        procs = [x for x in present if S.substrate.get(x, None) == s]
        enabled = any((x in S.monset and x in st.alive) or (x not in S.monset and x not in st.bad)
                      for x in procs)
        if enabled:
            mons = frozenset(x for x in procs if x in S.monset)
            non = frozenset(x for x in procs if x not in S.monset)
            out.append((("fail-substrate", s),
                        st._replace(alive=st.alive - mons, bad=st.bad | non, hidden=st.hidden | non)))
    # mutate p
    for p in present:
        if p not in st.bad:
            out.append((("mutate", p), st._replace(bad=st.bad | {p})))
    # disable m
    for m in S.switches:
        if m not in st.off:
            out.append((("disable", m), st._replace(off=st.off | {m})))
    # join
    if S.joiner is not None and not st.joined:
        out.append((("join",), st._replace(joined=True, alive=st.alive | {S.joiner})))
    return out


def env_phase(S, st):
    """All states reachable by a sequence of 0..f enabled steps: {state: steps}."""
    reached = {st: ()}
    frontier = [st]
    for _ in range(S.f):
        nxt = []
        for s in frontier:
            for label, s2 in env_successors(S, s):
                if s2 not in reached:
                    reached[s2] = reached[s] + (label,)
                    nxt.append(s2)
        frontier = nxt
    return reached


# ---------------------------------------------------------------- 3.2 monitor phase
def out_set(S, st):
    return frozenset(m for m in S.monitors if m in st.flagged and m in st.alive and m not in st.bad)


def monitor_phase(S, st, flagged_at_round_start):
    active = frozenset(m for m in S.monitors
                       if m in st.alive and m not in st.bad and m not in st.off)
    visible = st.bad - st.hidden
    flagged = set(st.flagged)
    # 1. detection
    for m in active:
        det = any(m in S.checkers.get(x, ()) for x in visible) or \
              any(m in S.hb_readers.get(p, ()) for p in S.monitors if p not in st.alive)
        if det:
            flagged.add(m)
    # 2. propagation
    if not S.slow_reports:
        changed = True
        while changed:
            changed = False
            for m in list(flagged):
                if m in active:
                    for r in S.fwd.get(m, ()):
                        if r in active and r not in flagged:
                            flagged.add(r)
                            changed = True
    else:
        add = set()
        for m in flagged_at_round_start:
            if m in active:
                for r in S.fwd.get(m, ()):
                    if r in active:
                        add.add(r)
        flagged |= add
    st2 = st._replace(flagged=frozenset(flagged))
    return st2, out_set(S, st2)


# ---------------------------------------------------------------- 3.3 work phase
def work_phase(S, st, out):
    halted = set(st.halted)
    pending = set(st.pending)
    worked = False
    for w in S.present_nonmonitors(st):
        if w in st.halted:
            continue
        if w in st.pending:
            pending.discard(w)
            halted.add(w)
            continue
        hi = S.halt_inputs.get(w, ())
        sees = any(m in out for m in hi) or (S.coupling and any(m not in st.alive for m in hi))
        if sees and S.window == 0:
            halted.add(w)
        else:
            if sees:
                pending.add(w)
            worked = True
    return st._replace(halted=frozenset(halted), pending=frozenset(pending)), worked


# ---------------------------------------------------------------- one round
def finish_round(S, st_env, flagged_at_round_start):
    """Monitor and work phases after the environment phase.  -> (state, g1, g2, out)."""
    if S.gate:
        st_m, out = monitor_phase(S, st_env, flagged_at_round_start)
        st_end, worked = work_phase(S, st_m, out)
    else:
        out_pre = out_set(S, st_env)
        st_w, worked = work_phase(S, st_env, out_pre)
        st_end, out = monitor_phase(S, st_w, flagged_at_round_start)
    g1 = bool(st_end.bad) and not out
    g2 = bool(st_end.bad) and worked
    return st_end, g1, g2, out


def responded(S, st):
    return bool(out_set(S, st)) and all(w in st.halted for w in S.present_nonmonitors(st))


# ---------------------------------------------------------------- 4 the result
def result(system, witness=True):
    S = System(system)
    init = initial_state(S)
    parent = {init: None}
    frontier = [init]
    res = {"G1": None, "G2": None}
    wit = {}
    n = 0
    while frontier and (res["G1"] is None or res["G2"] is None):
        n += 1
        nxt = []
        for st in frontier:
            if responded(S, st):
                continue
            for st_env, steps in env_phase(S, st).items():
                st_end, g1, g2, out = finish_round(S, st_env, st.flagged)
                for g, hit in (("G1", g1), ("G2", g2)):
                    if hit and res[g] is None:
                        res[g] = n
                        if witness:
                            wit[g] = _path(parent, st) + [steps]
                if st_end not in parent:
                    parent[st_end] = (st, steps)
                    nxt.append(st_end)
        frontier = nxt
    res["states"] = len(parent)
    if witness:
        res["witness"] = {g: [[" ".join(str(t) for t in s) for s in rnd] for rnd in w]
                          for g, w in wit.items()}
    return res


def _path(parent, st):
    rounds = []
    while parent[st] is not None:
        st, steps = parent[st]
        rounds.append(steps)
    rounds.reverse()
    return rounds


def gap_free(system, f=None):
    d = dict(system)
    if f is not None:
        d["f"] = f
    r = result(d, witness=False)
    return r["G1"] is None and r["G2"] is None


if __name__ == "__main__":
    cases = json.load(open(sys.argv[1], encoding="utf-8"))
    answers = []
    for c in cases:
        r = result(c["system"], witness=False)
        answers.append({"id": c["id"], "G1": r["G1"], "G2": r["G2"]})
    json.dump(answers, open(sys.argv[2], "w", encoding="utf-8"), indent=1)
    print("wrote", len(answers), "answers")
