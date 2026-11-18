import os
"""Scratch: run the reference-system sections of check_model selectively, with traces."""
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import check_model as cm


def run(system):
    first, states = cm.explore(system)
    print(f"{system.name:<30} f={system.f} G1 {cm.verdict(first['G1']):<20} "
          f"G2 {cm.verdict(first['G2']):<20} ({states} states)")
    for g in ("G1", "G2"):
        if first[g]:
            print(f"   shortest execution breaking {g}:")
            cm.show(first[g], "      ")
    return first


print("== full R")
for f in (1, 2, 3):
    run(cm.reference(f=f))

print("\n== R minus one, f=1")
for p in cm.PROPS:
    run(cm.reference(without=(p,)))

print("\n== canonical replays")
for p, schedule in cm.CANONICAL:
    rounds = cm.replay(cm.reference(without=(p,)), schedule)
    full = cm.replay(cm.reference(), schedule)
    print(f"without {p}: breaks {cm.broken(rounds)}; full R: "
          + (f"breaks {cm.broken(full)}" if full else "step missing"))
    cm.show(rounds)
    if full:
        print("   in full R:")
        cm.show(full, "      ")

print("\n== unread extra")
run(cm.reference(unread_extra=True))
