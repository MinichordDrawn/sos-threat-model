import os
"""Scratch: sensitivity experiments around reference(). Nothing here edits check_model.py."""
import copy
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import check_model as cm


def n(path):
    return len(path) if path else None


def run(label, system, traces=False):
    first, states = cm.explore(system)
    print(f"  {label:<62} G1 {str(n(first['G1'])):<5} G2 {str(n(first['G2'])):<5} ({states} states)")
    if traces:
        for g in ("G1", "G2"):
            if first[g]:
                print(f"     shortest {g}:")
                cm.show(first[g], "       ")
    return first


def all_shortest(system):
    """Every (start-of-round state depth, env sequence) that violates each goal at the
    least depth. Enumerates every enabled sequence, with no pruning by resulting state."""
    start = cm.initial(system)
    depth = {start: 0}
    parent = {start: None}
    order = [start]
    i = 0
    hits = {"G1": [], "G2": []}
    best = {"G1": None, "G2": None}

    def seqs(s):
        level = [((), s)]
        out = list(level)
        for _ in range(system.f):
            nxt = []
            for steps, st in level:
                for e in cm.env_steps(system, st):
                    nxt.append((steps + (e,), cm.apply_env(system, st, e)))
            out += nxt
            level = nxt
        return out

    def prefix(s):
        rounds = []
        while parent[s] is not None:
            s, steps = parent[s]
            rounds.append(steps)
        return rounds[::-1]

    while i < len(order):
        s = order[i]
        i += 1
        if cm.responded(system, s):
            continue
        for steps, a in seqs(s):
            t, info = cm.process_phase(system, a)
            for g in ("G1", "G2"):
                if info[g]:
                    d = depth[s] + 1
                    if best[g] is None or d < best[g]:
                        best[g], hits[g] = d, []
                    if d == best[g]:
                        hits[g].append((prefix(s), steps, info))
            if t not in depth:
                depth[t] = depth[s] + 1
                parent[t] = (s, steps)
                order.append(t)
    return best, hits


def fmt(steps):
    return ", ".join(f"{k} {a}" for k, a in steps) or "(none)"


print("A. P1 is two switches in the builder (hb_readers and coupling). Split them (f=1):")
r = cm.reference(); r.coupling = False
run("R, coupling off only (hb_readers kept)", r)
r = cm.reference(); r.hb_readers = {}
run("R, hb_readers emptied only (coupling kept)", r, traces=True)
r = cm.reference(without=("P1",)); r.substrate = {}
run("R without P1, and no substrates at all", r, traces=True)
r = cm.reference(without=("P1",)); r.substrate = {"M1": "s1", "M2": "s2", "M3": "s3"}
run("R without P1, work processes on no substrate", r)

print("\nB. P4 against the halt wiring (f=1):")
r = cm.reference(without=("P4",))
for w in list(r.halt_inputs):
    r.halt_inputs[w] = list(r.monitors)
run("R without P4, every work process reads all three monitors", r)
r = cm.reference()
for w in list(r.halt_inputs):
    r.halt_inputs[w] = list(r.monitors)
run("R, every work process reads all three monitors", r)

print("\nC. P7 is two edges in the builder (checker and halt inputs). Split them (f=1):")
r = cm.reference(); del r.checkers["J"]
run("R, J has halt inputs but no checker", r, traces=True)
r = cm.reference(); del r.halt_inputs["J"]
run("R, J has a checker but no halt inputs", r, traces=True)

print("\nD. P6: partial sharing of a boundary (f=1):")
r = cm.reference(); r.boundary = {"M1": 1, "M2": 1, "M3": 3}
run("R, M1 and M2 share a boundary, M3 apart", r, traces=True)
r = cm.reference(without=("P6",)); r.coupling = False
run("R without P6, coupling off", r)

print("\nE. The end rule. Same systems, three readings of 'responded' (monkeypatched in memory):")
orig = cm.responded
rules = {
    "spec (flagged live correct monitor AND all halted)": orig,
    "never ends": lambda system, s: False,
    "all present non-monitor processes halted": lambda system, s: all(
        w in s.halted for w in cm.present(system, s) if w not in system.monitors),
}
for name, rule in rules.items():
    cm.responded = rule
    print(f"  -- end rule: {name}")
    run("R", cm.reference())
    for p in ("P6", "P8b", "P4"):
        run(f"R without {p}", cm.reference(without=(p,)))
cm.responded = orig

print("\nF. Every shortest violating execution of R without one property (f=1):")
for p in cm.PROPS:
    system = cm.reference(without=(p,))
    best, hits = all_shortest(system)
    print(f"  R without {p}: G1 least {best['G1']}, G2 least {best['G2']}")
    for g in ("G1", "G2"):
        if best[g] is None:
            continue
        lines = sorted({" ; ".join(fmt(x) for x in pre + [steps]) for pre, steps, _ in hits[g]})
        print(f"     {g}: {len(lines)} distinct shortest step sequences (one prefix per start state)")
        for line in lines[:40]:
            print(f"        {line}")
        if len(lines) > 40:
            print(f"        ... and {len(lines) - 40} more")

print("\nG. Cross matrix: the canonical schedule of Pj (column) replayed in R without Pi (row).")
print("   Replay here stops at a responded state, as the spec requires.")


def strict_replay(system, schedule):
    s = cm.initial(system)
    broke = set()
    for steps in schedule:
        if cm.responded(system, s):
            return "ended"
        for e in steps:
            if e not in cm.env_steps(system, s):
                return "n/a"
            s = cm.apply_env(system, s, e)
        s, info = cm.process_phase(system, s)
        broke |= {g for g in ("G1", "G2") if info[g]}
    return "+".join(sorted(broke)) or "-"


print("   " + " " * 12 + "".join(f"{p:<8}" for p, _ in cm.CANONICAL))
for pi in ("none",) + cm.PROPS:
    system = cm.reference(without=() if pi == "none" else (pi,))
    print(f"   {'R-' + pi if pi != 'none' else 'R':<12}"
          + "".join(f"{strict_replay(system, sch):<8}" for _, sch in cm.CANONICAL))

print("\nH. Single-edge removals from full R (f=1):")
base = cm.reference()
for label, system in cm.ablations(base):
    first, _ = cm.explore(system)
    goals = " and ".join(g for g in ("G1", "G2") if first[g])
    print(f"   {'needed' if goals else 'spare ':<7} {label:<34} {('breaks ' + goals) if goals else ''}")

print("\nI. Two properties removed at once: does any pair hold? (f=1)")
for i, a in enumerate(cm.PROPS):
    for b in cm.PROPS[i + 1:]:
        first, _ = cm.explore(cm.reference(without=(a, b)))
        if not first["G1"] and not first["G2"]:
            print(f"   R without {a},{b} holds both goals")
print("   (pairs not listed break a goal)")

print("\nJ. Builder robustness:")
for combo in (("P3",), ("P4",)):
    try:
        cm.reference(without=combo, unread_extra=True)
        print(f"   reference(without={combo}, unread_extra=True) builds")
    except Exception as exc:
        print(f"   reference(without={combo}, unread_extra=True) raises {type(exc).__name__}: {exc}")
