import os
"""Scratch: is G1 ever satisfied only by a flag raised for an earlier event?

G1 in the spec asks for a live, correct monitor in `flagged`, and nothing ever leaves
`flagged`. This counts, over every reachable round of a system, the rounds in which
G1 holds but no live correct monitor detects (or is told of) anything in that round.
"""
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import check_model as cm


def fresh_out(system, s):
    active = {m for m in system.monitors if m in s.alive and m not in s.bad and m not in s.off}
    visible = s.bad - s.hidden
    told = set()
    for m in active:
        if any(m in system.checkers.get(x, ()) for x in visible) or any(
                m in system.hb_readers.get(p, ()) for p in system.monitors if p not in s.alive):
            told.add(m)
    changed = True
    while changed:
        changed = False
        for m in list(told):
            for r in system.fwd.get(m, ()):
                if r in active and r not in told:
                    told.add(r)
                    changed = True
    return told


def scan(system):
    start = cm.initial(system)
    depth = {start: 0}
    order = [start]
    i = 0
    stale_rounds, least = 0, None
    while i < len(order):
        s = order[i]
        i += 1
        if cm.responded(system, s):
            continue
        for steps, a in cm.env_choices(system, s):
            t, info = cm.process_phase(system, a)
            if a.bad and info["out"] and not fresh_out(system, a):
                stale_rounds += 1
                if least is None or depth[s] + 1 < least:
                    least = depth[s] + 1
            if t not in depth:
                depth[t] = depth[s] + 1
                order.append(t)
    return stale_rounds, least


for label, system in [("R", cm.reference())] + [
        (f"R without {p}", cm.reference(without=(p,))) for p in cm.PROPS]:
    k, least = scan(system)
    first, _ = cm.explore(system)
    print(f"  {label:<16} G1 per spec: {cm.verdict(first['G1']):<20} "
          f"rounds where G1 holds on a stale flag only: {k}"
          + (f" (earliest in round {least})" if k else ""))
