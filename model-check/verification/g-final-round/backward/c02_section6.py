"""Section 6, 5, 4, 2.7: replay each printed execution and look at the state round by round."""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bw import cm, res  # noqa: E402


def run(system, schedule, label):
    print(f"--- {label}  [{system.name}]")
    s = cm.initial(system)
    for i, steps in enumerate(schedule, 1):
        if cm.responded(system, s):
            print(f"   round {i}: NOT RUN, state is responded (model ended)")
            return
        for e in steps:
            if e not in cm.env_steps(system, s):
                print(f"   round {i}: step {e} NOT ENABLED")
                return
            s = cm.apply_env(system, s, e)
        s, info = cm.process_phase(system, s)
        allflag = sorted(s.flagged)
        print(f"   round {i}: env {steps} | bad {info['bad']} | out {info['out']} | all flagged {allflag}"
              f" | alive-mons {sorted(m for m in system.monitors if m in s.alive)}"
              f" | halted {info['halted']} | worked {info['executed']} | G1viol {info['G1']} G2viol {info['G2']}"
              f" | responded-after {cm.responded(system, s)}")


R = cm.reference
print("=== P1")
run(R(without="P1"), [[("stop", "M1")], [("mutate", "W1")]], "R-P1 canonical")
run(R(), [[("stop", "M1")], [("mutate", "W1")]], "full R")
g1, g2, st, first = res(R(without="P1"))
print("   search R-P1:", g1, g2, st)
cm.show(first["G1"]); cm.show(first["G2"])

print("=== P2")
run(R(without="P2"), [[("fail-substrate", "s1")]], "R-P2 canonical")
run(R(), [[("fail-substrate", "s1")]], "full R")

print("=== P3")
run(R(without="P3"), [[("mutate", "W1")]], "R-P3 canonical")
run(R(), [[("mutate", "W1")]], "full R")

print("=== P4")
run(R(without="P4"), [[("mutate", "W1")]], "R-P4 canonical")
print("   search R-P4:", res(R(without="P4"))[:3])
rs = cm.ring(3, "same", 2)
run(rs, [[("mutate", "M1")]], "ring3 same gate2: mutate M1")
print("   ring3-same fwd:", rs.fwd, "checkers:", rs.checkers, "halt:", rs.halt_inputs)
print("   search ring3 same:", res(rs)[:3], " ring3 other:", res(cm.ring(3, "other", 2))[:3])
ro = cm.ring(3, "other", 2)
run(ro, [[("mutate", "M1")]], "ring3 other gate2: mutate M1")
print("   ring3-other fwd:", ro.fwd)

print("=== P5")
run(R(without="P5"), [[("disable", "M1")], [("mutate", "W1")]], "R-P5 canonical")
run(R(), [[("disable", "M1")], [("mutate", "W1")]], "full R")

print("=== P6")
run(R(without="P6"), [[("stop-boundary", 1)], [("mutate", "W1")]], "R-P6 canonical")
print("   search R-P6:", res(R(without="P6"))[:3])

print("=== P7")
run(R(without="P7"), [[("join", "J")], [("mutate", "J")]], "R-P7 canonical")
run(R(), [[("join", "J")], [("mutate", "J")]], "full R")

print("=== P8")
run(R(without="P8"), [[("mutate", "W1")]], "R-P8 canonical")
print("   search R-P8:", res(R(without="P8"))[:3])

print("=== P8b")
run(R(without="P8b"), [[("mutate", "M1")]], "R-P8b canonical")
g1, g2, st, first = res(R(without="P8b"))
print("   search R-P8b:", g1, g2, st)
cm.show(first["G1"])

print("=== gate")
run(R(without="gate"), [[("mutate", "W1")], []], "R-gate canonical")
run(R(), [[("mutate", "W1")], []], "full R")
g1, g2, st, first = res(R(without="gate"))
print("   search R-gate:", g1, g2, st)
cm.show(first["G1"])
run(R(without="gate"), [[("mutate", "M1")], [("mutate", "M3")], [("stop", "M2")]], "R-gate: mutate M1, M3, stop M2")
run(R(without="gate"), [[("stop", "M3")]], "R-gate: stop M3 (is the landing round a complete response?)")
run(R(without="gate"), [[("stop", "M1")]], "R-gate: stop M1")
run(R(without="gate"), [[("fail-substrate", "s3")]], "R-gate: fail-substrate s3")

print("=== section 5")
print("   R f1:", res(R())[:3], "R f2:", res(R(f=2))[:3], "R f3:", res(R(f=3))[:3])
run(R(f=2), [[("mutate", "M1"), ("mutate", "M3")]], "R f2: mutate M1, M3")
g1, g2, st, first = res(R(f=2))
cm.show(first["G1"]); cm.show(first["G2"])
r = R()
for k in ("monitors", "works", "joiner", "boundary", "substrate", "hb_readers", "checkers", "fwd",
          "halt_inputs", "switches", "coupling", "window", "gate", "slow_reports"):
    print("   ", k, getattr(r, k))

print("=== section 4")
for f in (1, 2):
    print("   mesh3 f", f, res(cm.mesh(3, f))[:3], "| unread M3:", res(cm.mesh(3, f, unread="M3"))[:3])
m = cm.mesh(3, 2, unread="M3")
g1, g2, st, first = res(m)
cm.show(first["G1"])
run(m, [[("stop", "M3")], [("stop", "M1"), ("mutate", "M2")]], "mesh3 unread f2: stop M3; stop M1 + mutate M2")
ru = R(unread_extra=True)
print("   R+unread:", res(ru)[:3], "hb_readers of M4:", ru.hb_readers.get("M4"), "checkers W1:", ru.checkers["W1"])

print("=== section 2.7")
nb = cm.nested(3, True, 1, ring_boundaries=True)
print("   boundaries:", nb.boundary)
print("   nested ring-boundaries:", res(nb)[:3])
run(nb, [[("stop-boundary", "A")]], "nested ring boundaries: stop-boundary A")
run(nb, [[("stop-boundary", "B")]], "nested ring boundaries: stop-boundary B")
m4 = cm.mesh(4, 1, one_boundary=True)
g1, g2, st, first = res(m4)
print("   mesh4 one boundary:", g1, g2, st)
cm.show(first["G1"])
run(m4, [[("stop-boundary", 0)], [("mutate", "W")]], "mesh4 one boundary")
