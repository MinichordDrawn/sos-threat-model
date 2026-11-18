import os
"""Scratch: small targeted checks."""
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import check_model as cm

print("1. reference(without=...) given a string instead of a tuple")
for arg in ("P8b", ("P8b",), "P8", ("P8",)):
    r = cm.reference(without=arg)
    print(f"   without={arg!r:<10} name={r.name!r:<22} window={r.window} "
          f"halt_inputs[W1]={r.halt_inputs['W1']}")

print("\n2. Full R, f=1: every reachable state and every single step from the live ones")
r = cm.reference()
start = cm.initial(r)
seen, order = {start}, [start]
i = 0
while i < len(order):
    s = order[i]
    i += 1
    if cm.responded(r, s):
        continue
    label = "initial" if s == start else "after join"
    print(f"   live state ({label}), joined={s.joined}")
    for e in [None] + cm.env_steps(r, s):
        a = cm.apply_env(r, s, e) if e else s
        t, info = cm.process_phase(r, a)
        new = set(t.flagged) - set(s.flagged)
        print(f"      {(e[0] + ' ' + str(e[1])) if e else '(no step)':<18} bad={','.join(info['bad']) or '-':<3} "
              f"out={','.join(info['out']) or '-':<9} halted={','.join(info['halted']) or '-':<8} "
              f"worked={','.join(info['executed']) or '-':<8} G1={info['G1']!s:<5} G2={info['G2']!s:<5} "
              f"responded={cm.responded(r, t)}")
        if t not in seen:
            seen.add(t)
            order.append(t)
live = [s for s in order if not cm.responded(r, s)]
print(f"   {len(order)} states, {len(live)} live, {len(order) - len(live)} responded")

print("\n3. The P1 schedule replayed in full R: is round 2 a legal round?")
s = cm.initial(r)
for n, steps in enumerate([[("stop", "M1")], [("mutate", "W1")]], 1):
    print(f"   before round {n}: responded = {cm.responded(r, s)}")
    for e in steps:
        s = cm.apply_env(r, s, e)
    s, info = cm.process_phase(r, s)

print("\n4. replay() can report a violation the spec does not allow (round after a response)")
sched = [[("stop", "M1")], [("stop", "M2")], [("stop", "M3")], [("mutate", "W1")]]
rounds = cm.replay(r, sched)
print(f"   full R, schedule stop M1; stop M2; stop M3; mutate W1 -> replay says breaks {cm.broken(rounds)}"
      f" ; explore says G1 {cm.verdict(cm.explore(r)[0]['G1'])}")

print("\n5. Structural reading of each property on full R")
others = lambda m: [x for x in r.monitors if x != m]
print("   P1  every monitor's signal has a reader:",
      all(r.hb_readers.get(m) for m in r.monitors))
print("   P2  per non-monitor process: substrate, checkers, checkers' substrates")
for w in r.works + [r.joiner]:
    print(f"        {w}: substrate={r.substrate.get(w)} checkers="
          f"{[(m, r.substrate.get(m)) for m in r.checkers.get(w, [])]}")
print("   P2  per monitor: substrate, checkers' substrates")
for m in r.monitors:
    print(f"        {m}: substrate={r.substrate.get(m)} checkers="
          f"{[(c, r.substrate.get(c)) for c in r.checkers.get(m, [])]}")
print("   P3  every process has a checker:",
      all(r.checkers.get(p) for p in r.monitors + r.works + [r.joiner]))
print("   P6  every monitor has a reader in another boundary:",
      all(any(r.boundary[x] != r.boundary[m] for x in r.hb_readers[m]) for m in r.monitors))
print("   P8b halt inputs:", r.halt_inputs)
print("   P8b monitors that can halt each work process directly:",
      {w: v for w, v in r.halt_inputs.items()},
      "-> M2 cannot halt W1 or J directly, M1 cannot halt W2 directly")

print("\n6. In each R-minus-one, is some process still working in the round that breaks G1?")
for p in cm.PROPS:
    first, _ = cm.explore(cm.reference(without=(p,)))
    if first["G1"]:
        steps, info = first["G1"][-1]
        print(f"   R without {p:<3}: G1 broken in round {len(first['G1'])}; worked: "
              f"{' '.join(info['executed']) or '(nobody: every work process already halted)'}")
    else:
        print(f"   R without {p:<3}: G1 holds")

print("\n7. R without P8: can the environment use the window to stop a halt?")
sysm = cm.reference(without=("P8",))
start = cm.initial(sysm)
seen, order = {start}, [start]
i = 0
escaped = 0
while i < len(order):
    s = order[i]
    i += 1
    if cm.responded(sysm, s):
        continue
    for steps, a in cm.env_choices(sysm, s):
        t, info = cm.process_phase(sysm, a)
        if any(w in s.pending and w not in t.halted for w in s.pending):
            escaped += 1
        if t not in seen:
            seen.add(t)
            order.append(t)
print(f"   transitions in which a pending process failed to halt in the next round: {escaped}")
