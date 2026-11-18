"""Last check, script 2: results.md section 10.3, the restart game.

Checks the table of four rings against restart_game, and the statement "the ring can
always restart exactly when the member that can start first reaches every other member"
on every observer graph of 3 and 4 members, with and without self-observation, for every
choice of the starting member, and on a random sample of graphs of 5 and 6 members. Uses
the script's restart_game and, beside it, a separate implementation of the game written
here from the text of section 10.3. Also replays the two halves of the proof on every
graph, and tries the round model's "any one silent" rule in place of the game's rule.

Run: python -I -B lc02_restart.py
"""
import itertools
import os
import random
import sys
from collections import deque

HERE = os.path.dirname(os.path.abspath(__file__))
FOLDER = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, FOLDER)
import check_model as cm  # noqa: E402


# ---- an implementation of the game from the text of section 10.3, not from the script
def my_game(observers, first=(), rule="one"):
    """rule "one": a member runs only while at least one observer runs (section 10.3).
    rule "all": a member runs only while every observer runs (a member stops when any one
    observer is silent, as a work process does in the round model)."""
    members = sorted(observers)
    everyone = frozenset(members)

    def held(m, running):
        if m in first:
            return True
        obs = observers[m]
        if rule == "one":
            return any(o in running for o in obs)
        return bool(obs) and all(o in running for o in obs)

    def settle(running):
        running = set(running)
        while True:
            drop = [m for m in running if not held(m, running)]
            if not drop:
                return frozenset(running)
            running.difference_update(drop)

    def moves(state, env_stops=True):
        running, blocked = state
        for m in members:
            if m in running:
                if env_stops:
                    yield ("stop", m), (settle(running - {m}), blocked | {m})
            elif m in blocked:
                yield ("release", m), (running, blocked - {m})
            elif held(m, running):
                yield ("start", m), (settle(running | {m}), blocked)

    start = (everyone, frozenset())
    seen = {start: None}
    queue = deque([start])
    while queue:
        st = queue.popleft()
        for label, nxt in moves(st):
            if nxt not in seen:
                seen[nxt] = (st, label)
                queue.append(nxt)

    def can_restart(st):
        got, stack = {st}, [st]
        while stack:
            cur = stack.pop()
            if cur[0] == everyone:
                return True
            for label, nxt in moves(cur, env_stops=False):
                if nxt not in got:
                    got.add(nxt)
                    stack.append(nxt)
        return False

    stuck = [s for s in seen if not s[1] and not can_restart(s)]
    return (not stuck), len(seen), seen, can_restart


def reached_from(observers, k):
    """Members reached from k along chains of observation: k observes a, a observes b, ..."""
    got, stack = set(), [k]
    while stack:
        cur = stack.pop()
        for m, obs in observers.items():
            if cur in obs and m not in got:
                got.add(m)
                stack.append(m)
    return got            # k itself is in it only if a chain leads back to k


print("== A. The table of four rings")
ring3 = {"X1": ["X3"], "X2": ["X1"], "X3": ["X2"]}
mesh3 = {"X1": ["X2", "X3"], "X2": ["X1", "X3"], "X3": ["X1", "X2"]}
with_k = {"X1": ["X3", "K"], "X2": ["X1", "K"], "X3": ["X2", "K"], "K": ["X1", "X2", "X3"]}
for name, obs, selfs in (("ring of 3", ring3, ()), ("mesh of 3", mesh3, ()),
                         ("3 + K, K can start first", with_k, ("K",)),
                         ("3 + K, K cannot", with_k, ())):
    stuck, states = cm.restart_game(obs, selfs)
    mine, mystates, _, _ = my_game(obs, selfs)
    print(f"  {name}: script -> {stuck} ({states} states); own implementation: "
          f"always restarts = {mine} ({mystates} states)")
    assert (stuck is None) == mine and states == mystates

# after the stop in row 1, who is running?
running = frozenset(ring3)
_, _, seen, _ = my_game(ring3, ())
print("  ring of 3, states reached:", sorted((sorted(r), sorted(b)) for r, b in seen))


def all_graphs(members, self_loops):
    pairs = [(a, b) for a in members for b in members if self_loops or a != b]   # a observes b
    for bits in itertools.product((0, 1), repeat=len(pairs)):
        observers = {m: [] for m in members}
        for (a, b), bit in zip(pairs, bits):
            if bit:
                observers[b].append(a)
        yield observers


def check(observers, k):
    """Returns (script says always restarts, own says, k reaches every other member)."""
    stuck, _ = cm.restart_game(observers, (k,))
    mine, _, _, _ = my_game(observers, (k,))
    others = set(observers) - {k}
    return stuck is None, mine, others <= reached_from(observers, k)


print("\n== B. Every graph of 3 and of 4 members, the member that can start first fixed")
for size in (3, 4):
    members = ["K"] + [f"X{i}" for i in range(1, size)]
    n = agree = differ_impl = 0
    exceptions = []
    for observers in all_graphs(members, False):
        a, b, c = check(observers, "K")
        n += 1
        differ_impl += a != b
        if a == c:
            agree += 1
        elif len(exceptions) < 3:
            exceptions.append(observers)
    print(f"  size {size}, no self-observation: {n} graphs; statement holds on {agree}; "
          f"exceptions {len(exceptions)}; script and own implementation differ on {differ_impl}")

print("\n== C. The same with every choice of the starting member, and with self-observation")
for size, loops in ((3, False), (3, True), (4, False), (4, True)):
    members = [f"X{i}" for i in range(1, size + 1)]
    n = agree = differ_impl = 0
    ks = members if not (size == 4 and loops) else members[:1]   # 65,536 graphs: one k is enough by symmetry
    for observers in all_graphs(members, loops):
        for k in ks:
            a, b, c = check(observers, k)
            n += 1
            differ_impl += a != b
            agree += a == c
    print(f"  size {size}, self-observation {'allowed' if loops else 'excluded'}, "
          f"{len(ks)} choice(s) of starter: {n} cases; statement holds on {agree}; "
          f"script and own implementation differ on {differ_impl}")

print("\n== D. Random graphs of 5 and 6 members")
rng = random.Random(20261118)
for size, count in ((5, 4000), (6, 1500)):
    members = ["K"] + [f"X{i}" for i in range(1, size)]
    pairs = [(a, b) for a in members for b in members if a != b]
    n = agree = 0
    for _ in range(count):
        p = rng.choice((0.1, 0.2, 0.3, 0.5))
        observers = {m: [] for m in members}
        for a, b in pairs:
            if rng.random() < p:
                observers[b].append(a)
        a, b, c = check(observers, "K")
        n += 1
        agree += (a == c) and (a == b)
    print(f"  size {size}: {n} random graphs; statement holds and implementations agree on {agree}")

print("\n== E. The proof, step by step, on every graph of 3 and 4 members")
for size in (3, 4):
    members = ["K"] + [f"X{i}" for i in range(1, size)]
    everyone = frozenset(members)
    half1 = half2 = k_in_u = unsettled_start = fail1 = fail2 = closed_fail = 0
    for observers in all_graphs(members, False):
        always, _, seen, can_restart = my_game(observers, ("K",))
        reach = reached_from(observers, "K")
        others = set(members) - {"K"}
        if "K" not in reach:
            k_in_u += 1                      # read literally, U would contain K
        if any(not observers[m] for m in others):
            unsettled_start += 1             # a member with no observer is running at the start
        if others <= reach:
            # first half: from every state with nobody blocked, start K, then along chains
            half1 += 1
            for (running, blocked) in seen:
                if blocked:
                    continue
                run = set(running) | {"K"}
                grew = True
                while grew:
                    grew = False
                    for m in others - run:
                        if any(o in run for o in observers[m]):
                            run.add(m)
                            grew = True
                if run != set(everyone):
                    fail1 += 1
        else:
            # second half: U = other members K does not reach
            half2 += 1
            u = others - reach
            if any(o not in u for m in u for o in observers[m]):
                closed_fail += 1             # an observer of a member of U lies outside U
            # the environment stops every running member of U, one at a time, and releases it
            state = (everyone, frozenset())
            ok = state in seen
            for m in sorted(u):
                running, blocked = state
                if m in running:
                    nxt = None
                    for st, par in seen.items():
                        pass
                    # apply stop by hand, with the game's rule
                    run = set(running) - {m}
                    while True:
                        drop = [x for x in run if x != "K" and not any(o in run for o in observers[x])]
                        if not drop:
                            break
                        run.difference_update(drop)
                    state = (frozenset(run), blocked | {m})
                    ok = ok and state in seen
            state = (state[0], frozenset())  # release every blocked member
            ok = ok and state in seen
            # in that state: no member of U runs, every member outside U runs, and it is stuck
            if not (ok and not (state[0] & u) and state[0] == everyone - u and not can_restart(state)):
                fail2 += 1
    print(f"  size {size}: first half applies to {half1} graphs, fails on {fail1} states; "
          f"second half applies to {half2} graphs, fails on {fail2}; "
          f"'every observer of a member of U is in U' fails on {closed_fail}")
    print(f"           graphs where no chain leads from K back to K: {k_in_u}; "
          f"graphs where some other member has no observer: {unsettled_start}")

print("\n== F. If U is read literally as 'the members K does not reach', K included")
obs = {"K": ["X1"], "X1": ["K"], "X2": []}          # K reaches X1 and (through X1) itself; not X2
print("  example 1:", obs, "reached from K:", sorted(reached_from(obs, "K")))
obs = {"K": ["X1"], "X1": [], "X2": ["K"]}           # K observes X2 only; X1 observes K
r = reached_from(obs, "K")
u_literal = set(obs) - r
print("  example 2:", obs, "reached from K:", sorted(r), "U read literally:", sorted(u_literal))
print("    observers of members of U outside U:",
      sorted({o for m in u_literal for o in obs[m] if o not in u_literal}),
      "| K can start in every state:", True)

print("\n== G. The round model's rule (a member stops when any one observer is silent)")
for name, obs, selfs in (("3 + K, K can start first", with_k, ("K",)),
                         ("mesh of 3 plus K observing all, K can start first",
                          {"X1": ["X2", "X3", "K"], "X2": ["X1", "X3", "K"], "X3": ["X1", "X2", "K"],
                           "K": ["X1", "X2", "X3"]}, ("K",)),
                         ("star: K observes each, nobody else observes", {"X1": ["K"], "X2": ["K"], "X3": ["K"], "K": []}, ("K",))):
    one, _, _, _ = my_game(obs, selfs, rule="one")
    allr, _, _, _ = my_game(obs, selfs, rule="all")
    print(f"  {name}: game's rule (at least one observer running) -> always restarts {one}; "
          f"'every observer running' rule -> always restarts {allr}")

print("\n== H. No member can start first: 3 members")
cnt = sum(1 for o in all_graphs(["X1", "X2", "X3"], False) if cm.restart_game(o, ())[0] is None)
print("  graphs that can always restart:", cnt, "of 64")

print("\n== I. Two members that can start first (outside the statement, which assumes one)")
obs = {"A": [], "B": [], "X": ["A"], "Y": ["B"]}
print("  ", obs, "starters A and B -> stuck:", cm.restart_game(obs, ("A", "B"))[0],
      "| A reaches:", sorted(reached_from(obs, "A")))
