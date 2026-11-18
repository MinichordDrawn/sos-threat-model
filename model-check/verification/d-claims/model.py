"""Own implementation of model-spec.md (sections 1 to 4). Standard library only."""

MISSING = object()


def norm(d):
    S = {}
    S["f"] = d["f"]
    S["monitors"] = list(d.get("monitors", []))
    S["works"] = list(d.get("works", []))
    S["joiner"] = d.get("joiner")
    S["boundary"] = dict(d.get("boundary", {}))
    S["substrate"] = dict(d.get("substrate", {}))
    for k in ("hb_readers", "checkers", "fwd", "halt_inputs"):
        S[k] = {a: list(b) for a, b in d.get(k, {}).items()}
    S["switches"] = list(d.get("switches", []))
    S["coupling"] = bool(d.get("coupling", False))
    S["window"] = d.get("window", 0)
    S["monset"] = frozenset(S["monitors"])
    return S


# state = (alive, bad, hidden, off, flagged, halted, pending, joined)

def initial(S):
    e = frozenset()
    return (frozenset(S["monitors"]) | frozenset(S["works"]), e, e, e, e, e, e, False)


def present(S, st):
    p = list(S["monitors"]) + list(S["works"])
    if S["joiner"] is not None and st[7]:
        p.append(S["joiner"])
    return p


def nonmon_present(S, st):
    p = list(S["works"])
    if S["joiner"] is not None and st[7]:
        p.append(S["joiner"])
    return p


def env_successors(S, st):
    """All (label, state) reachable by ONE enabled environment step (section 3.1)."""
    alive, bad, hidden, off, flagged, halted, pending, joined = st
    mons = S["monitors"]
    monset = S["monset"]
    pres = present(S, st)
    out = []
    # stop m
    for m in mons:
        if m in alive:
            out.append((("stop", m), (alive - {m}, bad, hidden, off, flagged, halted, pending, joined)))
    # stop-boundary b
    bids = []
    for m in mons:
        b = S["boundary"].get(m, MISSING)
        if b is not MISSING and b not in bids:
            bids.append(b)
    for b in bids:
        members = [m for m in mons if S["boundary"].get(m, MISSING) == b]
        if len(members) >= 2 and any(m in alive for m in members):
            out.append((("stop-boundary", b), (alive - frozenset(members), bad, hidden, off, flagged, halted, pending, joined)))
    # fail-substrate s
    sids = []
    for p in pres:
        s = S["substrate"].get(p, MISSING)
        if s is not MISSING and s not in sids:
            sids.append(s)
    for s in sids:
        ps = [p for p in pres if S["substrate"].get(p, MISSING) == s]
        if any((p in monset and p in alive) or (p not in monset and p not in bad) for p in ps):
            a2, b2, h2 = set(alive), set(bad), set(hidden)
            for p in ps:
                if p in monset:
                    a2.discard(p)
                else:
                    b2.add(p)
                    h2.add(p)
            out.append((("fail-substrate", s), (frozenset(a2), frozenset(b2), frozenset(h2), off, flagged, halted, pending, joined)))
    # mutate p
    for p in pres:
        if p not in bad:
            out.append((("mutate", p), (alive, bad | {p}, hidden, off, flagged, halted, pending, joined)))
    # disable m
    for m in S["switches"]:
        if m not in off:
            out.append((("disable", m), (alive, bad, hidden, off | {m}, flagged, halted, pending, joined)))
    # join
    if S["joiner"] is not None and not joined:
        out.append((("join",), (alive | {S["joiner"]}, bad, hidden, off, flagged, halted, pending, True)))
    return out


def env_phase(S, st):
    """All states reachable by 0..f steps, each with one witnessing step sequence."""
    seen = {st: ()}
    frontier = [st]
    for _ in range(S["f"]):
        nxt = []
        for s in frontier:
            for lab, s2 in env_successors(S, s):
                if s2 not in seen:
                    seen[s2] = seen[s] + (lab,)
                    nxt.append(s2)
        frontier = nxt
        if not frontier:
            break
    return seen


def monitor_phase(S, st):
    alive, bad, hidden, off, flagged, halted, pending, joined = st
    mons = S["monitors"]
    active = frozenset(m for m in mons if m in alive and m not in bad and m not in off)
    visible = bad - hidden
    fl = set(flagged)
    for m in active:
        det = any(m in S["checkers"].get(x, []) for x in visible) or any(
            (p not in alive) and m in S["hb_readers"].get(p, []) for p in mons
        )
        if det:
            fl.add(m)
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
    out = frozenset(m for m in fl if m in alive and m not in bad)
    return (alive, bad, hidden, off, fl, halted, pending, joined), out


def work_phase(S, st, out):
    alive, bad, hidden, off, flagged, halted, pending, joined = st
    h2, p2 = set(halted), set(pending)
    stepped = []
    for w in nonmon_present(S, st):
        if w in halted:
            continue
        if w in pending:
            p2.discard(w)
            h2.add(w)
            continue
        hi = S["halt_inputs"].get(w, [])
        sees = any(m in out for m in hi) or (S["coupling"] and any(m not in alive for m in hi))
        if sees and S["window"] == 0:
            h2.add(w)
        else:
            if sees:
                p2.add(w)
            stepped.append(w)
    return (alive, bad, hidden, off, flagged, frozenset(h2), frozenset(p2), joined), stepped


def responded(S, st):
    alive, bad, hidden, off, flagged, halted, pending, joined = st
    if not any(m in alive and m not in bad for m in flagged):
        return False
    return all(w in halted for w in nonmon_present(S, st))


def result(d, want_trace=False):
    """Section 4: least n for each goal, or None. Optionally a witnessing trace."""
    S = norm(d)
    init = initial(S)
    depth = {init: 0}
    parent = {init: None}
    frontier = [init]
    res = {"G1": None, "G2": None}
    wit = {"G1": None, "G2": None}
    n = 0
    while frontier and (res["G1"] is None or res["G2"] is None):
        n += 1
        nxt = []
        for st in frontier:
            if responded(S, st):
                continue
            for s_env, steps in env_phase(S, st).items():
                s_mon, out = monitor_phase(S, s_env)
                s_end, stepped = work_phase(S, s_mon, out)
                bad = s_mon[1]
                if bad and not out and res["G1"] is None:
                    res["G1"] = n
                    wit["G1"] = (st, steps)
                if bad and stepped and res["G2"] is None:
                    res["G2"] = n
                    wit["G2"] = (st, steps)
                if s_end not in depth:
                    depth[s_end] = n
                    parent[s_end] = (st, steps)
                    nxt.append(s_end)
        frontier = nxt
    if not want_trace:
        return res
    traces = {}
    for g in ("G1", "G2"):
        if wit[g] is None:
            traces[g] = None
            continue
        st, steps = wit[g]
        seq = [steps]
        while parent[st] is not None:
            st, steps0 = parent[st]
            seq.append(steps0)
        traces[g] = list(reversed(seq))
    return res, traces
