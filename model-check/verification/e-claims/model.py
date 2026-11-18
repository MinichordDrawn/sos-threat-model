"""Independent implementation of model-spec.md (standard library only).

State = (alive, bad, hidden, off, flagged, halted, pending, joined)
with the first seven components frozensets of names.
"""
from collections import deque

MAPS = ("boundary", "substrate", "hb_readers", "checkers", "fwd", "halt_inputs")


def norm(system):
    S = dict(system)
    S.setdefault("joiner", None)
    for k in MAPS:
        S.setdefault(k, {})
    S.setdefault("switches", [])
    S.setdefault("gate", True)           # section 1: true if missing
    S.setdefault("slow_reports", False)  # section 1: false if missing
    return S


def initial(S):
    e = frozenset()
    return (frozenset(S["monitors"]) | frozenset(S["works"]), e, e, e, e, e, e, False)


def nonmonitors_present(S, joined):
    out = list(S["works"])
    if joined and S["joiner"] is not None:
        out.append(S["joiner"])
    return out


def env_steps(S, st):
    """All enabled environment steps in state st (section 3.1)."""
    alive, bad, hidden, off, flagged, halted, pending, joined = st
    mons = S["monitors"]
    monset = set(mons)
    pres = list(mons) + nonmonitors_present(S, joined)
    res = []
    for m in mons:                                    # stop m
        if m in alive:
            res.append((("stop", m), (alive - {m}, bad, hidden, off, flagged, halted, pending, joined)))
    groups = {}
    for m in mons:                                    # stop-boundary b
        if m in S["boundary"]:
            groups.setdefault(S["boundary"][m], []).append(m)
    for b, ms in groups.items():
        if len(ms) >= 2 and any(m in alive for m in ms):
            res.append((("stop-boundary", b), (alive - set(ms), bad, hidden, off, flagged, halted, pending, joined)))
    subs = {}
    for p in pres:                                    # fail-substrate s
        if p in S["substrate"]:
            subs.setdefault(S["substrate"][p], []).append(p)
    for s, ps in subs.items():
        if any((p in monset and p in alive) or (p not in monset and p not in bad) for p in ps):
            dead = {p for p in ps if p in monset}
            hit = {p for p in ps if p not in monset}
            res.append((("fail-substrate", s), (alive - dead, bad | hit, hidden | hit, off, flagged, halted, pending, joined)))
    for p in pres:                                    # mutate p
        if p not in bad:
            res.append((("mutate", p), (alive, bad | {p}, hidden, off, flagged, halted, pending, joined)))
    for m in S["switches"]:                           # disable m
        if m not in off:
            res.append((("disable", m), (alive, bad, hidden, off | {m}, flagged, halted, pending, joined)))
    if S["joiner"] is not None and not joined:        # join
        res.append((("join",), (alive | {S["joiner"]}, bad, hidden, off, flagged, halted, pending, True)))
    return res


def out_of(S, alive, bad, flagged):
    return {m for m in S["monitors"] if m in flagged and m in alive and m not in bad}


def monitor_phase(S, st, flagged_start):
    """Section 3.2 (and the slow-reports variant of 3.6). Returns (state, out)."""
    alive, bad, hidden, off, flagged, halted, pending, joined = st
    mons = S["monitors"]
    active = {m for m in mons if m in alive and m not in bad and m not in off}
    visible = bad - hidden
    fl = set(flagged)
    for m in active:
        det = any(m in S["checkers"].get(x, []) for x in visible) or \
              any((p not in alive) and m in S["hb_readers"].get(p, []) for p in mons)
        if det:
            fl.add(m)
    if S["slow_reports"]:
        add = set()
        for m in flagged_start:
            if m in active:
                for r in S["fwd"].get(m, []):
                    if r in active:
                        add.add(r)
        fl |= add
    else:
        changed = True
        while changed:
            changed = False
            for m in list(fl):
                if m in active:
                    for r in S["fwd"].get(m, []):
                        if r in active and r not in fl:
                            fl.add(r)
                            changed = True
    fl = frozenset(fl)
    return (alive, bad, hidden, off, fl, halted, pending, joined), out_of(S, alive, bad, fl)


def work_phase(S, st, out):
    """Section 3.3. Returns (state, set of processes that took a work step)."""
    alive, bad, hidden, off, flagged, halted, pending, joined = st
    monset = set(S["monitors"])
    nh, npend, stepped = set(halted), set(pending), set()
    for w in nonmonitors_present(S, joined):
        if w in halted:
            continue
        if w in pending:
            npend.discard(w)
            nh.add(w)
            continue
        hi = S["halt_inputs"].get(w, [])
        sees = any(m in out for m in hi) or \
            (S["coupling"] and any((m in monset and m not in alive) for m in hi))
        if sees and S["window"] == 0:
            nh.add(w)
        else:
            if sees:
                npend.add(w)
            stepped.add(w)
    return (alive, bad, hidden, off, flagged, frozenset(nh), frozenset(npend), joined), stepped


def finish_round(S, st):
    """Monitor and work phases (order per `gate`) from the state after the environment phase."""
    flagged_start = st[4]          # env and work phases never change `flagged`
    if S["gate"]:
        s1, out = monitor_phase(S, st, flagged_start)
        s2, stepped = work_phase(S, s1, out)
    else:
        out0 = out_of(S, st[0], st[1], st[4])
        s1, stepped = work_phase(S, st, out0)
        s2, out = monitor_phase(S, s1, flagged_start)
    bad = st[1]
    g1 = bool(bad) and not out
    g2 = bool(bad) and bool(stepped)
    return s2, g1, g2, stepped, out


def env_reachable(S, st):
    """States reachable by 0..f enabled environment steps, with one witness sequence each."""
    seen = {st: ()}
    frontier = [st]
    for _ in range(S["f"]):
        nxt = []
        for s in frontier:
            for step, s2 in env_steps(S, s):
                if s2 not in seen:
                    seen[s2] = seen[s] + (step,)
                    nxt.append(s2)
        frontier = nxt
    return seen


def responded(S, st):
    alive, bad, hidden, off, flagged, halted, pending, joined = st
    if not out_of(S, alive, bad, flagged):
        return False
    return all(w in halted for w in nonmonitors_present(S, joined))


def result(system, want_witness=False):
    """Section 4: least n with a violating execution, per goal; None if none."""
    S = norm(system)
    init = initial(S)
    depth = {init: 0}
    parent = {init: None}
    q = deque([init])
    res = {"G1": None, "G2": None}
    wit = {"G1": None, "G2": None}
    while q:
        st = q.popleft()
        d = depth[st]
        if responded(S, st):
            continue
        for s_env, steps in env_reachable(S, st).items():
            s2, g1, g2, stepped, out = finish_round(S, s_env)
            for g, v in (("G1", g1), ("G2", g2)):
                if v and (res[g] is None or d + 1 < res[g]):
                    res[g] = d + 1
                    wit[g] = (st, steps)
            if s2 not in depth:
                depth[s2] = d + 1
                parent[s2] = (st, steps)
                q.append(s2)
    if not want_witness:
        return res
    paths = {}
    for g in ("G1", "G2"):
        if wit[g] is None:
            paths[g] = None
            continue
        st, steps = wit[g]
        seq = [steps]
        while parent[st] is not None:
            st, steps = parent[st]
            seq.append(steps)
        paths[g] = list(reversed(seq))
    return res, paths


def run_script(system, script, max_rounds):
    """Run one fixed execution. script[i] = list of env steps for round i+1 (empty after the end).
    Returns per-round records; stops when a round would start from a responded state."""
    S = norm(system)
    st = initial(S)
    log = []
    for r in range(1, max_rounds + 1):
        if responded(S, st):
            break
        steps = script[r - 1] if r - 1 < len(script) else []
        assert len(steps) <= S["f"]
        for step in steps:
            en = dict(env_steps(S, st))
            assert tuple(step) in en, ("step not enabled", step, r)
            st = en[tuple(step)]
        st, g1, g2, stepped, out = finish_round(S, st)
        log.append({"round": r, "stepped": sorted(stepped), "out": sorted(out),
                    "flagged": sorted(st[4]), "halted": sorted(st[5]), "pending": sorted(st[6]),
                    "bad": sorted(st[1]), "alive": sorted(st[0]), "G1": g1, "G2": g2})
    return log, st, responded(S, st)
