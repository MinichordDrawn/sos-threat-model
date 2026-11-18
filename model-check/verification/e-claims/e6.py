"""Exhaustive exploration of the E6 setting (lifting a halt) under rules A, B, C.

State = (fault_present, member1_lost, halts) where halts is a tuple of booleans for
members 1, 2, 3 and, under rule C, K as a fourth entry.
"""
import sys
from collections import deque

NAMES = ["1", "2", "3", "K"]


def clean(i, fault):
    # member 1 (index 0) and K (index 3) are clean exactly when the fault is gone; 2 and 3 always
    return (not fault) if i in (0, 3) else True


def counts(i, lost, halts):
    return halts[i] and not (i == 0 and lost)


def runs(state, k_counts=True):
    fault, lost, halts = state
    idx = range(len(halts)) if k_counts else range(3)
    return not any(counts(i, lost, halts) for i in idx)


def steps(rule, state):
    fault, lost, halts = state
    res = []
    if fault:
        res.append(("repair", (False, lost, halts)))
    if not lost:
        res.append(("lose member 1", (fault, True, halts)))

    def setv(i, v):
        h = list(halts)
        h[i] = v
        return (fault, lost, tuple(h))

    for i in range(3):
        if i == 0 and lost:
            continue                      # a lost member takes no more steps
        others = [j for j in range(3) if j != i]
        if rule == "A":
            if halts[i] and clean(i, fault):
                res.append(("member %s lifts" % NAMES[i], setv(i, False)))
        elif rule == "B":
            other_counts = any(counts(j, lost, halts) for j in others)
            if halts[i] and clean(i, fault) and not other_counts:
                res.append(("member %s lifts" % NAMES[i], setv(i, False)))
            if (not halts[i]) and other_counts:
                res.append(("member %s raises" % NAMES[i], setv(i, True)))
        elif rule == "C":
            if halts[i] and clean(i, fault) and not halts[3]:
                res.append(("member %s lifts" % NAMES[i], setv(i, False)))
            if (not halts[i]) and halts[3]:
                res.append(("member %s raises" % NAMES[i], setv(i, True)))
    if rule == "C" and halts[3] and clean(3, fault):
        res.append(("K lifts", setv(3, False)))
    return res


def reach(rule, start):
    parent = {start: None}
    q = deque([start])
    while q:
        s = q.popleft()
        for lab, t in steps(rule, s):
            if t not in parent:
                parent[t] = (s, lab)
                q.append(t)
    return parent


def trace(parent, s):
    out = []
    while parent[s] is not None:
        s, lab = parent[s]
        out.append(lab)
    return list(reversed(out))


def show(state):
    fault, lost, halts = state
    return "fault=%s lost1=%s halts={%s}" % (
        "present" if fault else "gone", lost,
        ", ".join("%s:%s" % (NAMES[i], "H" if h else "-") for i, h in enumerate(halts)))


def analyse(rule, k_start=True, k_counts=True, verbose=True):
    halts = (True, True, True) + ((k_start,) if rule == "C" else ())
    start = (True, False, halts)
    parent = reach(rule, start)
    unsafe = [s for s in parent if s[0] and runs(s, k_counts)]
    stuck = []
    for s in parent:
        if not s[0]:
            if not any(runs(t, k_counts) for t in reach(rule, s)):
                stuck.append(s)
    safety = not unsafe
    recovery = not stuck
    if verbose:
        tag = "rule %s" % rule
        if rule == "C":
            tag += " (K starts %s a halt; K's halt %s)" % (
                "holding" if k_start else "without", "counts" if k_counts else "does not count")
        print("%s: %d reachable states, %d transitions" % (
            tag, len(parent), sum(len(steps(rule, s)) for s in parent)))
        print("  safety   %s" % ("HOLDS" if safety else "FAILS"))
        if unsafe:
            u = min(unsafe, key=lambda s: len(trace(parent, s)))
            print("    shortest unsafe trace: %s -> %s" % (" ; ".join(trace(parent, u)), show(u)))
        print("  recovery %s" % ("HOLDS" if recovery else "FAILS"))
        if stuck:
            u = min(stuck, key=lambda s: len(trace(parent, s)))
            print("    %d fault-gone reachable states cannot reach a running state; nearest: %s -> %s" % (
                len(stuck), " ; ".join(trace(parent, u)), show(u)))
        if "--states" in sys.argv:
            for s in sorted(parent):
                print("    ", show(s), "| runs" if runs(s, k_counts) else "",
                      "| steps:", ", ".join(l for l, _ in steps(rule, s)) or "(none)")
    return safety, recovery


if __name__ == "__main__":
    a = analyse("A")
    b = analyse("B")
    c = analyse("C")
    print()
    print("Claim: A safety fails           ->", not a[0])
    print("Claim: B safety holds           ->", b[0])
    print("Claim: B recovery fails         ->", not b[1])
    print("Claim: C safety and recovery    ->", c[0] and c[1])
    print("E6 as read (K is a member, holds a halt at the start, its halt counts):",
          (not a[0]) and b[0] and (not b[1]) and c[0] and c[1])
    print()
    print("Other readings of rule C:")
    analyse("C", k_start=True, k_counts=False)
    analyse("C", k_start=False, k_counts=True)
    analyse("C", k_start=False, k_counts=False)
