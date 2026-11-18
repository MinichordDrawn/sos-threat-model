"""Last check, script 1: results.md sections 1, 2.7, 5, 6, 8.1, 8.2, 10.1, 10.2.

Run: python -I -B lc01_sections_1_to_8.py
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
FOLDER = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, FOLDER)
import check_model as cm  # noqa: E402


def line(first):
    return {g: (len(p) if p else None) for g, p in first.items()}


def show_trace(path):
    out = []
    for steps, info in path:
        out.append("[" + ", ".join(f"{k} {a}" for k, a in steps) + "]"
                   + f" bad={info['bad']} out={info['out']} halted={info['halted']}"
                   + f" worked={info['executed']} G1={info['G1']} G2={info['G2']}")
    return out


print("== A. Section 1: ring of three, each reports to the one it checks")
s = cm.ring(3, "same", 2, 1)
mons = s.monitors
print("  relations:", {r: getattr(s, r) for r in cm.RELATIONS}, "boundary", s.boundary)
P = {}
P["P1 signal read by another monitor"] = all(any(r != m for r in s.hb_readers.get(m, ())) for m in mons)
P["P1 work halts on silence (coupling)"] = s.coupling
P["P2 (no substrates: vacuous)"] = all(
    any(s.substrate.get(c) == s.substrate[w] for c in s.checkers.get(w, ()))
    for w in s.works if w in s.substrate)
P["P3 every process has a checker other than itself"] = all(
    any(c != x for c in s.checkers.get(x, ())) for x in s.monitors + s.works)
P["P4 every other monitor reached from every monitor along report edges"] = all(
    set(mons) <= cm.reach(s, [a], ()) for a in mons)
P["P5 no switch"] = not s.switches
P["P6 every signal has a reader in a different boundary"] = all(
    any(s.boundary.get(r) != s.boundary.get(m) for r in s.hb_readers.get(m, ())) for m in mons)
P["P7 (no joiner: vacuous)"] = s.joiner is None
P["P8 no window"] = s.window == 0
P["P8b two halt sources for every work process"] = all(
    len(set(s.halt_inputs.get(w, ()))) >= 2 for w in s.works)
P["gate"] = s.gate
for k, v in P.items():
    print(f"  {k}: {v}")
print("  all predicates hold:", all(P.values()))
print("  is_plain:", cm.is_plain(s), " Theorem S conditions:", cm.sufficient_f1(s))
first, states = cm.explore(s)
print("  result:", line(first), states, "states")
for g in ("G1", "G2"):
    if first[g]:
        print(f"  shortest {g}:")
        for t in show_trace(first[g]):
            print("     ", t)
other = cm.ring(3, "other", 2, 1)
print("  reports to other:", line(cm.explore(other)[0]))

print("\n== B. Section 1 item 1 and section 6/7: which judgement each removal breaks in R")
for p in cm.PROPS:
    first, states = cm.explore(cm.reference(without=(p,)))
    print(f"  without {p:<5}: {line(first)} ({states} states)")
needs_g2 = [p for p in cm.PROPS if cm.explore(cm.reference(without=(p,)))[0]["G2"]]
needs_g1 = [p for p in cm.PROPS if cm.explore(cm.reference(without=(p,)))[0]["G1"]]
print("  removals that break G2:", needs_g2)
print("  removals that break G1:", needs_g1)
print("  removals that do not break G2:", [p for p in cm.PROPS if p not in needs_g2])
print("  removals that do not break G1:", [p for p in cm.PROPS if p not in needs_g1])

print("\n== C. Section 2.7: mesh of four in one boundary")
m4 = cm.mesh(4, 1, one_boundary=True)
first, states = cm.explore(m4)
print("  result:", line(first), states)
for t in show_trace(first["G1"]):
    print("     ", t)
rounds, why = cm.replay(m4, [[("stop-boundary", 0)]])
print("  after stop-boundary alone:", why, show_trace(rounds))
nb = cm.nested(3, True, 1, ring_boundaries=True)
print("  nested with ring boundaries:", line(cm.explore(nb)[0]))
rounds, why = cm.replay(nb, [[("stop-boundary", "A")]])
print("  nested, stop-boundary A:", why, show_trace(rounds))

print("\n== D. Section 5: R at f = 1 and the execution at f = 2")
for f in (1, 2):
    first, states = cm.explore(cm.reference(f=f))
    print(f"  R f={f}: {line(first)} ({states} states)")
    for g in ("G1", "G2"):
        if first[g]:
            print(f"   shortest {g} found by the search:")
            for t in show_trace(first[g]):
                print("     ", t)
r2 = cm.reference(f=2)
rounds, why = cm.replay(r2, [[("mutate", "M1"), ("mutate", "M3")], [("stop", "M2")]])
print("  replay of the execution in the text:", why)
for t in show_trace(rounds):
    print("     ", t)
print("  W1 halt inputs:", r2.halt_inputs["W1"])

print("\n== E. Section 6: P8b")
r = cm.reference(without=("P8b",))
print("  halt inputs:", r.halt_inputs, "coupling", r.coupling)
first, states = cm.explore(r)
print("  result:", line(first))
for g in ("G1", "G2"):
    print(f"   shortest {g} found by the search:")
    for t in show_trace(first[g]):
        print("     ", t)
rounds, why = cm.replay(r, [[("mutate", "M1")], [("stop", "M1")]])
print("  mutate M1 then stop M1:", why)
for t in show_trace(rounds):
    print("     ", t)
rounds, why = cm.replay(r, [[("mutate", "M1")], [("fail-substrate", "s1")]])
print("  mutate M1 then fail-substrate s1:", why)
for t in show_trace(rounds):
    print("     ", t)
# exhaustive: in every reachable state after M1 is bad, W1 halted implies M1 not alive
start = cm.initial(r)
seen, stack, viol = {start}, [start], 0
while stack:
    st = stack.pop()
    if cm.responded(r, st):
        continue
    for steps, after in cm.env_choices(r, st):
        t, info = cm.process_phase(r, after)
        if "M1" in after.bad and "M1" in after.alive and "W1" not in st.halted and "W1" in t.halted:
            viol += 1
        if t not in seen:
            seen.add(t)
            stack.append(t)
print("  rounds in which W1 halts while M1 is bad and alive:", viol, "over", len(seen), "states")

print("\n== F. Section 6: every removal explored and every table execution replayed")
for p, schedule in cm.CANONICAL:
    rounds, why = cm.replay(cm.reference(without=(p,)), schedule)
    full, whyf = cm.replay(cm.reference(), schedule)
    print(f"  {p:<5} {schedule} -> {why}; breaks {cm.broken(rounds)}; in full R: {whyf}, {cm.broken(full)}")
    for t in show_trace(rounds):
        print("       ", t)

print("\n== G. Section 6, the gate: G1 in three rounds")
first, _ = cm.explore(cm.reference(without=("gate",)))
for t in show_trace(first["G1"]):
    print("     ", t)

print("\n== H. Section 8.1: the reflex table")
for direct in (True, False):
    for slow in (False, True):
        s = cm.reflex(direct, slow)
        first, states = cm.explore(s)
        print(f"  direct={direct} slow={slow}: {line(first)} halt_inputs={s.halt_inputs} checkers W={s.checkers['W']}")

print("\n== I. Section 8.2: the three bounds, recomputed with growth()")
bad1 = []
for n in range(2, 3001):
    for h in (1, 2, 3, 4, 8, 16, 64, 128):
        d = cm.growth(n, "cascade", 1, h)
        if d < n - h * math.ceil(math.log2(n)):
            bad1.append((n, h, d))
print("  first bound (chain, damage >= n - h*ceil(log2 n)), n=2..3000, h in 1,2,3,4,8,16,64,128: failures", len(bad1), bad1[:5])
bad2 = [(n, cm.growth(n, "cascade", 2, 2)) for n in range(2, 3001)
        if cm.growth(n, "cascade", 2, 2) ** 2 * 2 > n]
print("  second bound (2 per hop, 2 hops per tick, damage <= sqrt(n/2)), n=2..3000: failures", len(bad2), bad2[:5])
for n in (2, 3, 4, 5):
    print(f"    n={n}: damage {cm.growth(n, 'cascade', 2, 2)}, sqrt(n/2)={math.sqrt(n / 2):.4f}")
lo, hi, worst = 1.0, 0.0, []
for n in range(8, 3001):
    d = cm.growth(n, "cascade", 2, 1)
    lo, hi = min(lo, d / n), max(hi, d / n)
    if not (n / 5 <= d <= 2 * n / 5):
        worst.append((n, d))
print(f"  third (2 per hop, 1 hop per tick), n=8..3000: share between {lo:.4f} and {hi:.4f}; outside [1/5, 2/5]: {worst[:5]}")
for n in range(2, 8):
    d = cm.growth(n, "cascade", 2, 1)
    print(f"    n={n}: damage {d} share {d / n:.3f}")
pw = [(k, cm.growth(2 ** k, "cascade", 2, 1) * 4 == 2 ** k) for k in range(3, 25)]
print("  exact n/4 for powers of two 2^3..2^24:", all(ok for _, ok in pw))
pw1 = [k for k in range(1, 25) for h in (1, 2, 4, 16, 128)
       if cm.growth(2 ** k, "cascade", 1, h) < 2 ** k - h * k]
pw2 = [k for k in range(1, 25) if cm.growth(2 ** k, "cascade", 2, 2) ** 2 * 2 > 2 ** k]
print("  powers of two 2^1..2^24: first bound failures", pw1, "second bound failures", pw2)

print("\n== J. Section 10.1 table row 2 and section 10.2")
for gate in (["K"], ["K", "M1"], ["K", "M1", "M2", "M3"]):
    s = cm.with_coordinator(gate)
    print(f"  3+K gate {gate}: {line(cm.explore(s)[0])}")
s = cm.with_coordinator(["K", "M1"])
print("  K checks states:", [x for x, cs in s.checkers.items() if "K" in cs],
      "| K reads signals of:", [m for m, rs in s.hb_readers.items() if "K" in rs],
      "| reports to K from:", [m for m, rs in s.fwd.items() if "K" in rs])
for n in (3, 4):
    for f in (1, 2, 3):
        print(f"  mesh {n} f={f}: {line(cm.explore(cm.mesh(n, f))[0])}")
