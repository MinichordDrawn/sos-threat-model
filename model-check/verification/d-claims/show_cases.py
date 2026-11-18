"""Print the full exploration of the C8 witnesses and the C4 repeated-entry system."""
import os
import sys
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from model import norm, initial, env_phase, monitor_phase, work_phase, responded, result  # noqa: E402
from test_claims import C8_A, C8_B, C8_C  # noqa: E402


def fmt(st):
    alive, bad, hidden, off, flagged, halted, pending, joined = st
    return "alive=%s bad=%s flagged=%s halted=%s" % (sorted(alive), sorted(bad), sorted(flagged), sorted(halted))


def explore(d):
    S = norm(d)
    init = initial(S)
    seen = {init: 0}
    frontier = [init]
    n = 0
    print("== %s ==" % d["name"])
    print(json.dumps(d))
    while frontier:
        n += 1
        nxt = []
        for st in frontier:
            if responded(S, st):
                continue
            print(" round %d from [%s]" % (n, fmt(st)))
            for s_env, steps in env_phase(S, st).items():
                s_mon, out = monitor_phase(S, s_env)
                s_end, stepped = work_phase(S, s_mon, out)
                g1 = bool(s_mon[1]) and not out
                g2 = bool(s_mon[1]) and bool(stepped)
                print("   steps=%-22s out=%-16s bad=%-8s work steps=%-6s G1 violated=%s G2 violated=%s -> %s%s" % (
                    list(steps), sorted(out), sorted(s_mon[1]), stepped, g1, g2,
                    "RESPONDED" if responded(S, s_end) else "not responded",
                    "" if s_end in seen else " (new state)"))
                if s_end not in seen:
                    seen[s_end] = n
                    nxt.append(s_end)
        frontier = nxt
    print(" result:", result(d))


C4_DUP = {
    "name": "c4-repeated-entry", "f": 1, "monitors": ["A", "B"], "works": ["W"], "joiner": None,
    "boundary": {"A": "ba", "B": "bb"}, "substrate": {},
    "hb_readers": {"A": ["B"], "B": ["A"]},
    "checkers": {"A": ["B"], "B": ["A"], "W": ["A"]},
    "fwd": {"A": ["B"], "B": ["A"]},
    "halt_inputs": {"W": ["A", "A"]},
    "switches": [], "coupling": True, "window": 0,
}

if __name__ == "__main__":
    explore(C8_A)
    explore(C8_C)
    print("c8-with-work (coupling true):", result(C8_B))
    print("c4-repeated-entry:", result(C4_DUP, want_trace=True))
