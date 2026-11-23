# Validate the decider against the worked examples of model-spec-join.md J8 and
# against results that results-original.md states for its reference system R.
from sosmodel import Model, solve, with_f, fmt
from systems import *

ok = True


def expect(label, got, want):
    global ok
    good = tuple(got[:2]) == tuple(want)
    ok &= good
    print(("ok   " if good else "FAIL ") + label, got[:2], "want", want)


def j8(kind, arrive_bad, f):
    s = empty(BASE, ["W"], f=f)
    for i in range(4):
        for j in range(i + 1, 4):
            mesh_pair(s, BASE[i], BASE[j])
    for m in BASE:
        add(s, "checkers", "W", m)
        add(s, "halt_inputs", "W", m)
    add_monitor(s, "N")
    s["arrive_bad"] = arrive_bad
    if kind in (1, 3):
        add(s, "checkers", "N", "M1")
    if kind == 3:
        s["slow_edges"] = [["checkers", "N", "M1"]]
    return s


for f in (1, 2, 3):
    expect("J8.1 f=%d" % f, solve(j8(1, True, f)), (None, None))
expect("J8.2 good f=1", solve(j8(2, False, 1)), (2, 2))
expect("J8.2 bad f=1", solve(j8(2, True, 1)), (1, 1))
expect("J8.3 good f=1", solve(j8(3, False, 1)), (None, None))
expect("J8.3 good f=2", solve(j8(3, False, 2)), (1, 1))
expect("J8.3 bad f=1", solve(j8(3, True, 1)), (1, 1))


# Reference system R of results-original.md section 5
def R(f=1):
    s = empty(["M1", "M2", "M3"], ["W1", "W2"], f=f, joiner="J")
    for a in ("M1", "M2", "M3"):
        for b in ("M1", "M2", "M3"):
            if a < b:
                mesh_pair(s, a, b)
    s["substrate"] = {"M1": "s1", "W1": "s1", "M2": "s2", "W2": "s2", "M3": "s3"}
    add(s, "checkers", "W1", "M1")
    add(s, "checkers", "W2", "M2")
    add(s, "checkers", "J", "M3")
    s["halt_inputs"] = {"W1": ["M1", "M3"], "W2": ["M2", "M3"], "J": ["M3", "M1"]}
    return s


m = Model(R(1))
r = m.solve()
expect("R f=1", r, (None, None))
print("   R states:", m.nstates, "(results-original says 23)")
expect("R f=2", solve(R(2)), (2, 1))

# removals of section 6
s = R(1); s["hb_readers"] = {}; s["coupling"] = False
expect("R minus P1 (shortest is P2's, one round)", solve(s), (1, 1))
s = R(1); s["substrate"] = {"M1": "sa", "W1": "s1", "M2": "sb", "W2": "s2", "M3": "s3"}
expect("R minus P2", solve(s), (1, 1))
s = R(1); s["checkers"] = {}
expect("R minus P3", solve(s), (1, 1))
s = R(1); s["fwd"] = {}
expect("R minus P4 (G1 holds, G2 in 1)", solve(s), (None, 1))
s = R(1); s["switches"] = ["M1", "M2", "M3"]
expect("R minus P5", solve(s), (2, 2))
s = R(1); s["boundary"] = {"M1": "b", "M2": "b", "M3": "b"}
expect("R minus P6 (G1 in 2, G2 holds)", solve(s), (2, None))
s = R(1); s["checkers"].pop("J"); s["halt_inputs"].pop("J")
expect("R minus P7", solve(s), (2, 2))
s = R(1); s["window"] = 1
expect("R minus P8 (G2 in 1)", solve(s)[1:2] + (None,), (1, None))
s = R(1); s["halt_inputs"] = {"W1": ["M1"], "W2": ["M2"], "J": ["M3"]}
expect("R minus P8b (G1 in 3, G2 in 1)", solve(s), (3, 1))
s = R(1); s["gate"] = False
expect("R minus gate (G1 in 3, G2 in 1)", solve(s), (3, 1))

# section 8.1 reflex
def reflex(halts, slow):
    s = empty(["M1", "M2", "M3"], ["W"], f=1)
    for a in ("M1", "M2", "M3"):
        for b in ("M1", "M2", "M3"):
            if a < b:
                mesh_pair(s, a, b)
    add(s, "checkers", "W", "M1")
    s["halt_inputs"] = {"W": halts}
    s["slow_reports"] = slow
    return s
expect("reflex M1,M2 prompt", solve(reflex(["M1", "M2"], False)), (None, None))
expect("reflex M1,M2 slow", solve(reflex(["M1", "M2"], True)), (None, None))
expect("reflex M2,M3 prompt", solve(reflex(["M2", "M3"], False)), (None, None))
expect("reflex M2,M3 slow", solve(reflex(["M2", "M3"], True)), (None, 1))

# mesh of four, f = 1..3 no gap, f = 4 gap
for f in (1, 2, 3, 4):
    print("mesh of four f=%d:" % f, fmt(solve(base_ring("mesh", "all", f))))
print("ALL OK" if ok else "SOME FAILED")
