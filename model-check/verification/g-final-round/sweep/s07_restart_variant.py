"""Section 10.3: in check_model.restart_game, is the member that can start first exempt from
the run-only-while-observed rule only at its start, or throughout?"""
import sys
from collections import deque
import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


sys.path.insert(0, _mc())
import check_model as cm

with_k = {"X1": ["X3", "K"], "X2": ["X1", "K"], "X3": ["X2", "K"], "K": ["X1", "X2", "X3"]}

# 1. In the checker's game: stop X1, X2, X3 and see whether K keeps running with no running observer.
observers, self_starting = with_k, ("K",)


def settle(running, exempt):
    running = set(running)
    changed = True
    while changed:
        changed = False
        for m in list(running):
            if m not in exempt and not any(o in running for o in observers[m]):
                running.discard(m)
                changed = True
    return frozenset(running)


r = frozenset(observers)
for m in ("X1", "X2", "X3"):
    r = settle(r - {m}, self_starting)
print("checker's rule (self-starting member exempt from the stop rule): after stopping X1, X2, X3 running =", sorted(r),
      "| observers of K running:", [o for o in observers["K"] if o in r])


# 2. Variant: K may START with no running observer, but is otherwise bound by the rule
#    (it stops at once when no member that observes it is running).
def restart_variant(observers, start_first):
    members = tuple(observers)

    def settle2(running):
        return settle(running, ())

    def steps(state):
        running, blocked = state
        for m in members:
            if m in running:
                yield f"stop {m}", (settle2(running - {m}), blocked | {m})
            elif m in blocked:
                yield f"release {m}", (running, blocked - {m})
            elif m in start_first or any(o in running for o in observers[m]):
                yield f"start {m}", (settle2(running | {m}), blocked)

    start = (frozenset(members), frozenset())
    parent = {start: None}
    q = deque([start])
    while q:
        st = q.popleft()
        for label, nxt in steps(st):
            if nxt not in parent:
                parent[nxt] = (st, label)
                q.append(nxt)

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

    def trace(st):
        out = []
        while parent[st] is not None:
            st, label = parent[st]
            out.append(label)
        return out[::-1]

    stuck = [s for s in parent if not s[1] and not can_restart(s)]
    stuck.sort(key=lambda s: len(trace(s)))
    return (trace(stuck[0]) if stuck else None), len(parent)


print("variant (K may start first but stops when no running member observes it):", restart_variant(with_k, ("K",)))
print("checker:", cm.restart_game(with_k, ("K",)))
