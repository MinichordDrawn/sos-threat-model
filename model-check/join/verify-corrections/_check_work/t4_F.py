"""A4 / A15: Theorem F statements about two watchers."""
import random
from build import *

print("=== A15: 'in every round with a fault some live correct monitor detects a fault of that round'")
# five monitors, each watched by the next two; no reports; W checked by M1, halting on M1 only; f=2; plain
mons = ["M1", "M2", "M3", "M4", "M5"]
s = empty(2, mons, ["W"])
for i, m in enumerate(mons):
    watch(s, mons[(i + 1) % 5], m)
    watch(s, mons[(i + 2) % 5], m)
add(s, "checkers", "W", "M1")
add(s, "halt_inputs", "W", "M1")
for m in mons:
    print("  watchers of", m, ":", sorted(set(s["checkers"][m]) & set(s["hb_readers"][m])))
print("  result:", fmt(both(s)))
mm = M(s)
st = mm.init
for labs in (["stop M2", "stop M3"], ["mutate M1"]):
    cur = st
    for lab in labs:
        cur = dict(mm.steps(cur))[lab]
    nst, v1, v2 = mm.round(st, cur)
    alive, bad = cur[0], cur[1]
    active = alive & ~bad & mm.MON
    # which live correct monitors detect which process this round (model-spec 3.2 step 1)
    det = []
    for k in range(len(mm.names)):
        if bad >> k & 1:
            for m in mm.nm_(mm.rel["checkers"][k] & active):
                det.append("%s sees bad state of %s" % (m, mm.names[k]))
        if k < mm.nm and not alive >> k & 1:
            for m in mm.nm_(mm.rel["hb_readers"][k] & active):
                det.append("%s sees silence of %s" % (m, mm.names[k]))
    print("  |", ", ".join(labs), "|", mm.describe(nst), "| G1:", v1, "G2:", v2, "| detections:", det)
    st = nst

print("=== A4 / A15 first round: random plain systems, every monitor two watchers, work with a checker")
random.seed(7)
def rnd(direct):
    n = random.randint(3, 6)
    mons = ["M%d" % i for i in range(1, n + 1)]
    nw = random.randint(1, 2)
    works = ["W%d" % i for i in range(1, nw + 1)]
    s = empty(2, mons, works)
    for m in mons:
        others = [x for x in mons if x != m]
        for x in random.sample(others, random.randint(2, len(others))):
            watch(s, x, m)
        # extra one-sided edges
        for x in others:
            if random.random() < 0.2: add(s, "checkers", m, x)
            if random.random() < 0.2: add(s, "hb_readers", m, x)
    for w in works:
        for x in random.sample(mons, random.randint(1, n)):
            add(s, "checkers", w, x)
        if direct:
            for x in mons:
                add(s, "halt_inputs", w, x)
        else:
            for x in random.sample(mons, random.randint(1, n)):
                add(s, "halt_inputs", w, x)
            for m in mons:
                for x in mons:
                    if x != m and random.random() < 0.15:
                        report(s, m, x)
    return s
cnt = gaps = 0
for i in range(1500):
    s = rnd(True)
    r = both(s)
    cnt += 1
    if not nogap(r):
        gaps += 1
        print("  GAP", s, r)
print("  halting directly on every monitor, no reports, f=2: %d systems, %d with a gap" % (cnt, gaps))
# first-round detection, without the halt condition: every one-round outcome with a fault has a detection of a fault of the round
cnt = fail = 0
for i in range(600):
    s = rnd(False)
    mm = M(s)
    for post, labs in mm.env(mm.init).items():
        if post == mm.init:
            continue
        alive, bad = post[0], post[1]
        active = alive & ~bad & mm.MON
        ok = False
        for k in range(len(mm.names)):
            if bad >> k & 1 and mm.rel["checkers"][k] & active: ok = True
            if k < mm.nm and not alive >> k & 1 and mm.rel["hb_readers"][k] & active: ok = True
        cnt += 1
        if not ok:
            fail += 1
print("  first round with a fault, f=2: %d outcomes over 600 random systems, %d with no detection of a fault of the round" % (cnt, fail))
