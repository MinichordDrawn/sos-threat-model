#!/usr/bin/env python3
"""A plain implementation of model-spec.md, model-spec-join.md and model-spec-scope.md.

Written from the three specification files, with Python sets and no bit masks, and with
no code taken from mr_model.py, fast_join.py or any other checker. It exists to be
compared with mr_model.py on the catalogue. It is slow and is meant for small systems and
for bounded searches. It was written by the same hand as mr_model.py, so agreement
between the two is a check on slips, not an independent opinion.

Run:  python -B scope_naive.py SYSTEMS.json ANSWERS.json [--max-states N]
      compares its answers with ANSWERS.json, case by case
"""
import json
import sys


class Sys:
    def __init__(self, d):
        self.d = d
        self.f = d["f"]
        self.monitors = list(d["monitors"])
        self.works = list(d["works"])
        self.joiner = d.get("joiner")
        self.mon = set(self.monitors)
        self.nonmon = list(self.works) + ([self.joiner] if self.joiner is not None else [])
        self.all = self.monitors + self.nonmon
        self.boundary = d.get("boundary") or {}
        self.substrate = d.get("substrate") or {}
        self.rel = {r: {k: list(v) for k, v in (d.get(r) or {}).items()}
                    for r in ("hb_readers", "checkers", "fwd", "halt_inputs")}
        self.switches = set(d.get("switches") or [])
        self.coupling = d["coupling"]
        self.window = d["window"]
        self.gate = d.get("gate", True)
        self.slow_reports = d.get("slow_reports", False)
        self.groups = d.get("late") or []
        self.arrive_bad = d.get("arrive_bad", False)
        self.slow_edges = {tuple(e) for e in (d.get("slow_edges") or [])}
        self.late = {p for g in self.groups for p in g["members"]}
        self.scope = d.get("scope") or {}
        self.scoped = bool(self.scope)
        if self.scoped:
            ids = set(self.scope.values()) | set(d.get("scope_work") or {}) | set(d.get("told") or {})
            self.scopes = sorted(ids)
            self.work = {}
            for s in self.scopes:
                if s in (d.get("scope_work") or {}):
                    self.work[s] = set(d["scope_work"][s])
                else:
                    self.work[s] = {w for w in self.nonmon if self.scope[w] == s}
            self.told = {s: set((d.get("told") or {}).get(s, [])) for s in self.scopes}
        else:
            # one scope holding everything is the earlier model (X11)
            self.scopes = ["-"]
            self.scope = {p: "-" for p in self.all}
            self.work = {"-": set(self.nonmon)}
            self.told = {"-": set()}
        self.freeze = d.get("freeze", False)
        self.max_rounds = d.get("max_rounds")

    def edges(self, relation, key):
        return self.rel[relation].get(key, [])


def fz(x):
    return frozenset(x)


def initial(S):
    present = fz(p for p in S.monitors + S.works if p not in S.late)
    return {"alive": present, "bad": fz(()), "hidden": fz(()), "off": fz(()),
            "flagged": fz(()), "halted": fz(()), "pending": fz(()), "present": present,
            "closed": fz(())}


def key(st):
    return tuple(st[k] for k in ("alive", "bad", "hidden", "off", "flagged", "halted",
                                 "pending", "present", "closed"))


def env_steps(S, st):
    out = []
    frozen = set()
    if S.freeze:
        frozen = {p for p in S.all if S.scope[p] in st["closed"]}
    present = st["present"]
    for m in S.monitors:
        if m in present and m in st["alive"] and m not in frozen:
            out.append(dict(st, alive=st["alive"] - {m}))
    for b in sorted({json.dumps(v) for v in S.boundary.values()}):
        here = [m for m in S.monitors if m in present and m in S.boundary
                and json.dumps(S.boundary[m]) == b]
        if len(here) >= 2 and any(m in st["alive"] and m not in frozen for m in here):
            out.append(dict(st, alive=st["alive"] - {m for m in here if m not in frozen}))
    for sub in sorted({json.dumps(v) for v in S.substrate.values()}):
        here = [p for p in S.all if p in present and p in S.substrate
                and json.dumps(S.substrate[p]) == sub and p not in frozen]
        if any((p in S.mon and p in st["alive"]) or (p not in S.mon and p not in st["bad"])
               for p in here):
            mons = {p for p in here if p in S.mon}
            rest = {p for p in here if p not in S.mon}
            out.append(dict(st, alive=st["alive"] - mons, bad=st["bad"] | rest,
                            hidden=st["hidden"] | rest))
    for p in S.all:
        if p in present and p not in st["bad"] and p not in frozen:
            out.append(dict(st, bad=st["bad"] | {p}))
    for m in S.monitors:
        if m in present and m in S.switches and m not in st["off"] and m not in frozen:
            out.append(dict(st, off=st["off"] | {m}))
    if S.joiner is not None and S.joiner not in S.late and S.joiner not in present             and S.joiner not in frozen:
        out.append(dict(st, alive=st["alive"] | {S.joiner}, present=present | {S.joiner}))
    for g in S.groups:
        members = set(g["members"])
        if not members & present and all(a in present for a in g.get("after") or [])                 and not members & frozen:
            joined = dict(st, alive=st["alive"] | members, present=present | members)
            out.append(joined)
            if S.arrive_bad:
                for m in g["members"]:
                    if m in S.mon:
                        out.append(dict(joined, bad=joined["bad"] | {m}))
    return out


def env_outcomes(S, st):
    seen = {key(st): st}
    frontier = [st]
    for _ in range(S.f):
        nxt = []
        for s in frontier:
            for t in env_steps(S, s):
                if key(t) not in seen:
                    seen[key(t)] = t
                    nxt.append(t)
        frontier = nxt
    return list(seen.values())


def one_round(S, before, st):
    """The monitor and work phases. `before` is the set present before the environment
    phase. Returns (state, violations) where violations is a set of (kind, scope)."""
    present = st["present"]
    new = present - before

    def in_force(relation, k, m):
        if k not in present or m not in present:
            return False
        if (relation, k, m) in S.slow_edges and (k in new or m in new):
            return False
        return True

    alive, bad = st["alive"], st["bad"]
    active = {m for m in S.monitors if m in present and m in alive and m not in bad
              and m not in st["off"]}
    visible = bad - st["hidden"]
    flagged = set(st["flagged"])
    halted, pending = set(st["halted"]), set(st["pending"])
    worked = set()
    entered = set()

    def outs(fl):
        return {s: {m for (m, t) in fl if t == s and m in alive and m not in bad}
                for s in S.scopes}

    def work_phase(out):
        for w in S.nonmon:
            if w not in present or w in halted:
                continue
            if w in pending:
                pending.discard(w)
                halted.add(w)
                continue
            inputs = [m for m in S.edges("halt_inputs", w) if in_force("halt_inputs", w, m)]
            sees = any(m in out[s] for m in inputs for s in S.scopes if w in S.work[s])
            if S.coupling and any(m not in alive for m in inputs):
                sees = True
            if sees and S.window == 0:
                halted.add(w)
                entered.add(w)
            else:
                if sees:
                    pending.add(w)
                    entered.add(w)
                worked.add(w)

    if not S.gate:
        work_phase(outs(flagged))
    start_flags = set(flagged)
    for m in active:
        for x in visible:
            if in_force("checkers", x, m) and m in S.edges("checkers", x):
                flagged.add((m, S.scope[x]))
        for p in S.monitors:
            if p in present and p not in alive and m in S.edges("hb_readers", p) \
                    and in_force("hb_readers", p, m):
                flagged.add((m, S.scope[p]))
    if S.slow_reports:
        for (m, s) in start_flags:
            if m in active:
                for r in S.edges("fwd", m):
                    if r in active and in_force("fwd", m, r):
                        flagged.add((r, s))
    else:
        changed = True
        while changed:
            changed = False
            for (m, s) in list(flagged):
                if m in active:
                    for r in S.edges("fwd", m):
                        if r in active and in_force("fwd", m, r) and (r, s) not in flagged:
                            flagged.add((r, s))
                            changed = True
    out = outs(flagged)
    if S.gate:
        work_phase(out)
    viol = set()
    for s in S.scopes:
        if s in st["closed"]:
            continue
        if any(S.scope[p] == s for p in bad):
            if not out[s]:
                viol.add(("G1", s))
            if worked & S.work[s]:
                viol.add(("G2", s))
            listed = S.told[s]
            if any(m in alive and m not in bad for m in listed) and not listed & out[s]:
                viol.add(("told", s))
    faulty = set(bad) | {m for m in S.monitors if m in present and m not in alive}
    for w in entered:
        cover = {s for s in S.scopes if w in S.work[s]}
        if not any(S.scope[p] in cover for p in faulty):
            viol.add(("spill", None))
    closed = set(st["closed"])
    for s in S.scopes:
        if s not in closed and out[s] and all(w in halted for w in S.work[s] if w in present):
            closed.add(s)
    t = dict(st, flagged=fz(flagged), halted=fz(halted), pending=fz(pending), closed=fz(closed))
    return t, viol


def responded(S, st):
    some = any(m in st["alive"] and m not in st["bad"] for (m, _) in st["flagged"])
    return some and all(w in st["halted"] for w in S.nonmon if w in st["present"])


def solve(d, max_states=None):
    S = Sys(d)
    start = initial(S)
    seen = {key(start)}
    frontier = [start]
    first = {}
    n = 0
    complete = True
    while frontier:
        if S.max_rounds is not None and n >= S.max_rounds:
            break
        n += 1
        nxt = []
        for st in frontier:
            if responded(S, st):
                continue
            for e in env_outcomes(S, st):
                t, viol = one_round(S, st["present"], e)
                for v in viol:
                    first.setdefault(v, n)
                if key(t) not in seen:
                    seen.add(key(t))
                    nxt.append(t)
            if max_states is not None and len(seen) > max_states:
                complete = False
                nxt = []
                break
        frontier = nxt
    ans = {}
    g = {k: [v for (kind, s), v in first.items() if kind == k] for k in ("G1", "G2")}
    ans["G1"] = min(g["G1"]) if g["G1"] else None
    ans["G2"] = min(g["G2"]) if g["G2"] else None
    if S.scoped:
        ans["scopes"] = {s: {k: first.get((k, s)) for k in ("G1", "G2", "told")}
                         for s in S.scopes}
        ans["spill"] = first.get(("spill", None))
    return ans, len(seen), complete


def main():
    systems = json.load(open(sys.argv[1], encoding="utf-8"))
    answers = {a["id"]: a for a in json.load(open(sys.argv[2], encoding="utf-8"))}
    limit = None
    if "--max-states" in sys.argv:
        limit = int(sys.argv[sys.argv.index("--max-states") + 1])
    only = None
    if "--only" in sys.argv:
        only = sys.argv[sys.argv.index("--only") + 1]
    same = different = skipped = 0
    for case in systems:
        if only and not case["id"].startswith(only):
            continue
        ans, states, complete = solve(case["system"], limit)
        if not complete:
            skipped += 1
            print("too large, skipped:", case["id"], flush=True)
            continue
        want = {k: v for k, v in answers[case["id"]].items() if k != "id"}
        if ans == want:
            same += 1
        else:
            different += 1
            print("DIFFERENT", case["id"], ans, want, flush=True)
    print(f"{same} the same, {different} different, {skipped} skipped as too large")


if __name__ == "__main__":
    main()
