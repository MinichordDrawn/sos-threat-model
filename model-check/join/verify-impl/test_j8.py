"""The three examples of section J8 of model-spec-join.md, built from its prose."""
import sys
from model import solve_system


def base(f, n_edges, arrive_bad, slow):
    init = ["M1", "M2", "M3", "M4"]
    others = {m: [x for x in init if x != m] for m in init}
    s = {
        "name": "j8",
        "f": f,
        "monitors": init + ["N"],
        "works": ["W"],
        "joiner": None,
        "boundary": {m: i + 1 for i, m in enumerate(init + ["N"])},
        "substrate": {},
        "hb_readers": {m: list(others[m]) for m in init},
        "checkers": dict({m: list(others[m]) for m in init}, W=list(init)),
        "fwd": {m: list(others[m]) for m in init},
        "halt_inputs": {"W": list(init)},
        "switches": [],
        "coupling": True,
        "window": 0,
        "late": [{"name": "N", "members": ["N"]}],
        "arrive_bad": arrive_bad,
        "slow_edges": [],
    }
    if n_edges:
        s["checkers"]["N"] = ["M1"]
        if slow:
            s["slow_edges"] = [["checkers", "N", "M1"]]
    return s


cases = [
    ("1 f=1", base(1, True, True, False), (None, None)),
    ("1 f=2", base(2, True, True, False), (None, None)),
    ("1 f=3", base(3, True, True, False), (None, None)),
    ("2 arrive_bad=false f=1", base(1, False, False, False), (2, 2)),
    ("2 arrive_bad=true f=1", base(1, False, True, False), (1, 1)),
    ("3 arrive_bad=false f=1", base(1, True, False, True), (None, None)),
    ("3 arrive_bad=false f=2", base(2, True, False, True), (1, 1)),
    ("3 arrive_bad=true f=1", base(1, True, True, True), (1, 1)),
]
bad = 0
for label, s, want in cases:
    g1, g2, ns, ok = solve_system(s)
    good = (g1, g2) == want and ok
    bad += not good
    print("%-28s got G1=%s G2=%s  want G1=%s G2=%s  states=%d  %s" % (
        label, g1, g2, want[0], want[1], ns, "OK" if good else "MISMATCH"))
print("ALL REPRODUCED" if not bad else "%d MISMATCH" % bad)
sys.exit(1 if bad else 0)
