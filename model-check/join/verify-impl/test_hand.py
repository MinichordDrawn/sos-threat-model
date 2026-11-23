"""Small systems whose results were worked out by hand from model-spec.md, for
the parts of the model the catalogue never uses (window 1, no gate, switches,
substrates) and one for slow reports.  Two monitors M1, M2 that read each
other's signal, check each other and W, report to each other; W halts on both.
"""
import sys
from model import solve_system
from naive import Naive


def two(**kw):
    s = {
        "name": "hand", "f": 1, "monitors": ["M1", "M2"], "works": ["W"], "joiner": None,
        "boundary": {"M1": 1, "M2": 2}, "substrate": {},
        "hb_readers": {"M1": ["M2"], "M2": ["M1"]},
        "checkers": {"M1": ["M2"], "M2": ["M1"], "W": ["M1", "M2"]},
        "fwd": {"M1": ["M2"], "M2": ["M1"]},
        "halt_inputs": {"W": ["M1", "M2"]},
        "switches": [], "coupling": True, "window": 0,
    }
    s.update(kw)
    return s


def three(**kw):
    """A checks W; W halts on B and C; A reports to B and C; all three read
    each other's signal and check each other."""
    ms = ["A", "B", "C"]
    oth = {m: [x for x in ms if x != m] for m in ms}
    s = {
        "name": "hand3", "f": 1, "monitors": ms, "works": ["W"], "joiner": None,
        "boundary": {"A": 1, "B": 2, "C": 3}, "substrate": {},
        "hb_readers": dict(oth),
        "checkers": dict(oth, W=["A"]),
        "fwd": {"A": ["B", "C"]},
        "halt_inputs": {"W": ["B", "C"]},
        "switches": [], "coupling": True, "window": 0,
    }
    s.update(kw)
    return s


cases = [
    # f=1: stop Mi: the other flags (signal), W halts.  mutate Mi: the other
    # flags (check), W halts.  mutate W: both flag, W halts.  Every round 1 with
    # a fault ends responded, with a flag out and no work step.
    ("plain, f=1", two(), (None, None)),
    # f=2: stop M1 and mutate M2 in round 1: no monitor is left to flag.
    # G2 the same round by mutate M1, mutate M2 (nobody stopped, so no silence).
    ("plain, f=2", two(f=2), (1, 1)),
    # window 1.  G2: mutate M1: M2 flags, W sees it, goes pending and still
    # takes a work step while bad.  G1: no single fault leaves bad unflagged in
    # round 1; but stop M1 (M2 flags, W pending, state not responded because W
    # has not halted yet), then mutate M2 in round 2: bad, and no flag out.
    ("window 1", two(window=1), (2, 1)),
    # no gate.  G2: mutate M1: W steps before the monitors check.  G1: after
    # that round M2 is flagged and W has not halted, so the state is not
    # responded; stop M2 in round 2: bad, and no flag out.
    ("no gate", two(gate=False), (2, 1)),
    # switches.  One fault in round 1 is always flagged.  disable M1, then
    # mutate M2 in round 2: M1 is off, M2 is bad, nobody flags, W steps.
    ("switches, f=1", two(switches=["M1", "M2"]), (2, 2)),
    # W alone on a substrate: its failure is hidden from every check
    ("substrate under W", two(substrate={"W": "s"}), (1, 1)),
    # both monitors on one substrate: it fails, W halts on the silence, no flag,
    # so not responded; then mutate W: bad and no flag (G1 at 2).  W never steps
    # while bad: the first fault of any kind halts it (G2 null).
    ("substrate under M1, M2", two(substrate={"M1": "s", "M2": "s"}), (2, None)),
    # one shared boundary: the same by stop-boundary
    ("boundary of M1, M2", two(boundary={"M1": 1, "M2": 1}), (2, None)),
    # no coupling, shared boundary: stop both, then mutate W, which still works
    ("boundary, no coupling", two(boundary={"M1": 1, "M2": 1}, coupling=False), (2, 2)),
    # reports, fast: mutate W: A flags, B and C get the report in the same
    # round, W halts.  Any fault on a monitor is flagged by the other two, one
    # of which W halts on.  Nothing is ever violated.
    ("three, fast reports", three(), (None, None)),
    # reports, slow: mutate W: A flags, but B and C get the report only in
    # round 2, so W steps while bad in round 1 (G2 at 1).  A flag is out in
    # every round with a fault, since detection itself is not delayed (G1 null).
    ("three, slow reports", three(slow_reports=True), (None, 1)),
    # a joiner J nobody checks and nothing halts: join, then mutate J
    ("free joiner", two(joiner="J"), (2, 2)),
]
if __name__ == "__main__":
    bad = 0
    for label, s, want in cases:
        g1, g2, ns, ok = solve_system(s)
        n1, n2, _ = Naive(s).solve()
        good = (g1, g2) == want and (n1, n2) == want
        bad += not good
        print("%-26s model G1=%s G2=%s  plain G1=%s G2=%s  by hand G1=%s G2=%s  %s" % (
            label, g1, g2, n1, n2, want[0], want[1], "OK" if good else "MISMATCH"))
    print("ALL AS WORKED BY HAND" if not bad else "%d MISMATCH" % bad)
    sys.exit(1 if bad else 0)
