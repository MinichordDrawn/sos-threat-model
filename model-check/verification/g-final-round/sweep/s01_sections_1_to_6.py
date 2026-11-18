"""Sweep: sections 1, 2.7, 4, 5, 6 of results.md against check_model.py functions."""
import sys
import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


sys.path.insert(0, _mc())
import check_model as cm


def run(system, schedule):
    """Replay and return per-round info plus state trail."""
    s = cm.initial(system)
    out = []
    for steps in schedule:
        if cm.responded(system, s):
            out.append("ENDED-BEFORE")
            break
        for e in steps:
            assert e in cm.env_steps(system, s), ("not enabled", e)
            s = cm.apply_env(system, s, e)
        s, info = cm.process_phase(system, s)
        out.append((steps, info, s))
    return out, s


def pr(tag, system, schedule):
    print(f"--- {tag}: {system.name} f={system.f}")
    out, s = run(system, schedule)
    for i, o in enumerate(out, 1):
        if o == "ENDED-BEFORE":
            print(f"   round {i}: model already ended (responded)")
            continue
        steps, info, st = o
        print(f"   round {i}: env {steps} | bad {info['bad']} | out {info['out']} | flagged {sorted(st.flagged)} "
              f"| halted {info['halted']} | worked {info['executed']} | G1viol {info['G1']} G2viol {info['G2']} "
              f"| alive {sorted(st.alive)} | responded {cm.responded(system, st)}")


def first(system):
    f, n = cm.explore(system)
    return {g: (len(p) if p else None) for g, p in f.items()}, n, f


print("== section 5")
for f in (1, 2, 3):
    r, n, paths = first(cm.reference(f=f))
    print("R f", f, r, n)
    if f == 2:
        for g in ("G1", "G2"):
            print("  shortest", g)
            cm.show(paths[g], "     ")
pr("sec5 f=2 named execution", cm.reference(f=2), [[("mutate", "M1"), ("mutate", "M3")]])

print("\n== section 6: removals, search results")
for p in cm.PROPS:
    r, n, paths = first(cm.reference(without=(p,)))
    print(p, r, n)
    for g in ("G1", "G2"):
        if paths[g]:
            print("  shortest", g)
            cm.show(paths[g], "     ")

print("\n== section 6: tables replayed in reduced and in full R")
for p, sched in cm.CANONICAL:
    pr(f"without {p}", cm.reference(without=(p,)), sched)
    try:
        pr(f"full R same schedule ({p})", cm.reference(), sched)
    except AssertionError as ex:
        print("   full R:", ex)

print("\n== P8b: G1 in three rounds: mutate M1, stop M2, stop M3")
pr("P8b 3 rounds", cm.reference(without=("P8b",)), [[("mutate", "M1")], [("stop", "M2")], [("stop", "M3")]])
print("\n== gate: G1 in three: mutate M1, M3, stop M2, W1 working throughout")
pr("gate 3 rounds", cm.reference(without=("gate",)), [[("mutate", "M1")], [("mutate", "M3")], [("stop", "M2")]])

print("\n== gate: no step that makes a state bad in round 1 is answered completely in that round")
sysg = cm.reference(without=("gate",))
s0 = cm.initial(sysg)
for steps, after in cm.env_choices(sysg, s0):
    t, info = cm.process_phase(sysg, after)
    if after.bad:
        print("  ", steps, "bad", sorted(after.bad), "responded", cm.responded(sysg, t), "worked", info["executed"], "G2", info["G2"])
print("  all first-round steps without the gate:")
for steps, after in cm.env_choices(sysg, s0):
    t, info = cm.process_phase(sysg, after)
    print("    ", steps, "responded", cm.responded(sysg, t), "worked", info["executed"])

print("\n== section 1 item 1: without P4 / P8, G1 holds in every reachable state (search result None)")
for p in ("P4", "P8"):
    r, n, _ = first(cm.reference(without=(p,)))
    print(p, r)

print("\n== R f=1: every first fault answered in its own round (Limits: one-step result)")
R = cm.reference()
s0 = cm.initial(R)
for steps, after in cm.env_choices(R, s0):
    t, info = cm.process_phase(R, after)
    print("  ", steps, "| bad", sorted(after.bad), "| responded", cm.responded(R, t), "| worked", info["executed"], "| G1", info["G1"], "G2", info["G2"])
# which states are reachable and not responded besides join?
first_, n = cm.explore(R)
print("  R states", n)

print("\n== section 4")
for f in (1, 2):
    for unread in (None, "M3"):
        r, n, paths = first(cm.mesh(3, f, unread=unread))
        print("mesh3 f", f, "unread", unread, r, n)
        for g in ("G1", "G2"):
            if paths[g]:
                cm.show(paths[g], "     ")
pr("sec4 named execution", cm.mesh(3, 2, unread="M3"), [[("stop", "M3")], [("stop", "M1"), ("mutate", "M2")]])
r, n, _ = first(cm.reference(unread_extra=True))
print("R plus unread M4 f=1", r, n)
# is M4's signal read by nobody?
ru = cm.reference(unread_extra=True)
print("  hb_readers of M4:", ru.hb_readers.get("M4"))
# R: each work process a single state checker
print("  R checkers:", cm.reference().checkers)
# two monitors would do at one fault per round: mesh of 2 f=1
print("mesh2 f1", first(cm.mesh(2, 1))[:2])

print("\n== section 2.7")
nb = cm.nested(3, True, 1, ring_boundaries=True)
print("nested ring boundaries", first(nb)[:2])
pr("stop-boundary A", nb, [[("stop-boundary", "A")]])
pr("stop-boundary B", nb, [[("stop-boundary", "B")]])
m4 = cm.mesh(4, 1, one_boundary=True)
r, n, paths = first(m4)
print("mesh4 one boundary", r, n)
cm.show(paths["G1"], "     ")
pr("mesh4 one boundary", m4, [[("stop-boundary", 0)], [("mutate", "W")]])
# Theorem 0 part 1: f >= number of monitors -> G1 violated (mesh n, f=n)
for n_ in (1, 2, 3, 4):
    r, n, _ = first(cm.mesh(n_, n_))
    print("mesh", n_, "f", n_, r)
