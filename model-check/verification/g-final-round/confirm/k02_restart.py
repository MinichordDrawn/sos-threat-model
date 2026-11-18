"""k02: section 10.3. The restart game on every observer graph of three and of four members,
one member able to start first; the definition of "can always restart"; each step of the proof.

Run: python -I -B k02_restart.py
"""
import itertools
import sys
from collections import deque

import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


sys.path.insert(0, _mc())
import check_model as cm  # noqa: E402


def reached_from(k, observers):
    """Members reached from k along observation edges (k observes a, a observes b, ...)."""
    seen, stack = set(), [k]
    while stack:
        x = stack.pop()
        for m, obs in observers.items():
            if x in obs and m not in seen:
                seen.add(m)
                stack.append(m)
    return seen


def graphs(n, self_loops):
    names = ["X%d" % i for i in range(n)]
    slots = [(m, o) for m in names for o in names if self_loops or o != m]
    for bits in itertools.product((0, 1), repeat=len(slots)):
        obs = {m: [] for m in names}
        for (m, o), b in zip(slots, bits):
            if b:
                obs[m].append(o)
        yield names, obs


# an independent decider of the definition in the text: reachable states of the game, then
# "from every state with nobody blocked, starts alone lead to all running"
def own_decider(names, obs, selfs):
    def settle(run):
        run = set(run)
        ch = True
        while ch:
            ch = False
            for m in list(run):
                if m not in selfs and not any(o in run for o in obs[m]):
                    run.discard(m)
                    ch = True
        return frozenset(run)

    def moves(st):
        run, blk = st
        for m in names:
            if m in run:
                yield "stop", (settle(run - {m}), blk | {m})
            elif m in blk:
                yield "release", (run, blk - {m})
            elif m in selfs or any(o in run for o in obs[m]):
                yield "start", (settle(run | {m}), blk)

    start = (frozenset(names), frozenset())
    seen = {start}
    q = deque([start])
    while q:
        st = q.popleft()
        for _, nx in moves(st):
            if nx not in seen:
                seen.add(nx)
                q.append(nx)
    allrun = frozenset(names)

    def can(st):
        s2, stack = {st}, [st]
        while stack:
            cur = stack.pop()
            if cur[0] == allrun:
                return True
            for kind, nx in moves(cur):
                if kind == "start" and nx not in s2:
                    s2.add(nx)
                    stack.append(nx)
        return False

    return all(can(st) for st in seen if not st[1]), seen, settle


def proof_steps(names, obs, k):
    """Follow the second half of the proof on one graph in which k does not reach every other
    member. Returns True if every step holds as written."""
    selfs = (k,)
    r = reached_from(k, obs) | {k}
    u = [m for m in names if m not in r]
    assert u
    # every observer of a member of U is in U
    if not all(o in u for m in u for o in obs[m]):
        return False
    _, seen, settle = own_decider(names, obs, selfs)
    run, blk = frozenset(names), frozenset()
    for m in u:                                  # the environment stops every running member of U
        if m in run:
            run, blk = settle(run - {m}), blk | {m}
            if not (set(r) <= run):              # K and the members it reaches keep running
                return False
    blk = frozenset()                            # and releases it
    st = (run, blk)
    if st not in seen:
        return False
    if run != frozenset(r):
        return False
    # no member of U has a running observer, so none can start
    return not any(any(o in run for o in obs[m]) for m in u)


for n, loops in ((3, False), (4, False), (3, True), (4, True)):
    total = agree_cm = agree_own = reach_all = exceptions = proof_ok = proof_cases = 0
    initial_unsettled = 0
    for names, obs in graphs(n, loops):
        ks = names if (n, loops) != (4, True) else names[:1]
        for k in ks:
            total += 1
            reach = set(names) - {k} <= reached_from(k, obs)
            stuck, _ = cm.restart_game(obs, (k,))
            own, seen, settle = own_decider(names, obs, (k,))
            agree_cm += (stuck is None) == reach
            agree_own += own == reach
            reach_all += reach
            exceptions += (stuck is None) != reach
            if settle(frozenset(names)) != frozenset(names):
                initial_unsettled += 1
            if not reach:
                proof_cases += 1
                proof_ok += proof_steps(names, obs, k)
    per_k = total // (len(names) if (n, loops) != (4, True) else 1)
    print(f"n={n} self-loops={loops}: graphs {per_k}, (graph, K) pairs {total}; K reaches every other in "
          f"{reach_all}; restart_game agrees with reachability in {agree_cm}; own decider agrees in "
          f"{agree_own}; exceptions {exceptions}; second half of the proof holds step by step in "
          f"{proof_ok} of {proof_cases}; pairs whose all-running start state is not settled: {initial_unsettled}")

print()
print("the four rings of the table (run-output 10b):")
ring3 = {"X1": ["X3"], "X2": ["X1"], "X3": ["X2"]}
mesh3 = {"X1": ["X2", "X3"], "X2": ["X1", "X3"], "X3": ["X1", "X2"]}
with_k = {"X1": ["X3", "K"], "X2": ["X1", "K"], "X3": ["X2", "K"], "K": ["X1", "X2", "X3"]}
for name, obs, selfs in (("ring3", ring3, ()), ("mesh3", mesh3, ()), ("3+K", with_k, ("K",)),
                         ("3+K, K bound", with_k, ())):
    print(" ", name, cm.restart_game(obs, selfs))

print()
print("weaker form: in the mesh of 3, one stop leaves the other two running:")
names = ["X1", "X2", "X3"]
_, seen, settle = own_decider(names, mesh3, ())
print("  settle(all - X1) =", sorted(settle(frozenset(names) - {"X1"})))
print("with no member able to start first, a full stop is reachable and final, on every graph of 3 and 4:")
for n in (3, 4):
    bad = 0
    cnt = 0
    for names, obs in graphs(n, False):
        cnt += 1
        stuck, _ = cm.restart_game(obs, ())
        if stuck is None:
            bad += 1
    print(f"  n={n}: graphs {cnt}, of which can always restart with no self-starting member: {bad}")
