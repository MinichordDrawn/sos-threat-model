"""Sweep: remaining section 6 points, 8.1, 8.2, 9, 10.1, 10.2, 10.3 of results.md."""
import itertools
import math
import random
import sys
import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


sys.path.insert(0, _mc())
import check_model as cm


def run(system, schedule, quiet=False):
    s = cm.initial(system)
    infos = []
    for i, steps in enumerate(schedule, 1):
        if cm.responded(system, s):
            if not quiet:
                print(f"   round {i}: model already ended")
            break
        for e in steps:
            assert e in cm.env_steps(system, s), ("not enabled", e)
            s = cm.apply_env(system, s, e)
        s, info = cm.process_phase(system, s)
        infos.append(info)
        if not quiet:
            print(f"   round {i}: env {steps} | bad {info['bad']} | out {info['out']} | flagged {sorted(s.flagged)} | halted {info['halted']} "
                  f"| worked {info['executed']} | G1 {info['G1']} G2 {info['G2']} | responded {cm.responded(system, s)}")
    return infos, s


def first(system):
    f, n = cm.explore(system)
    return {g: (len(p) if p else None) for g, p in f.items()}, n, f


print("== P8b: does W1 ever halt after mutate M1? (stop M1 next)")
run(cm.reference(without=("P8b",)), [[("mutate", "M1")], [("stop", "M1")]])
run(cm.reference(without=("P8b",)), [[("mutate", "M1")], [("fail-substrate", "s1")]])

print("\n== P2 second face: fail-substrate on a shared substrate with a threshold (window=1, R without P8)")
run(cm.reference(without=("P8",)), [[("fail-substrate", "s1")], []])

print("\n== P4: rings of three")
r_same = cm.ring(3, "same", 2)
print(" same: checkers", r_same.checkers, "fwd", r_same.fwd, "halt", r_same.halt_inputs)
run(r_same, [[("mutate", "M1")]])
print(first(r_same)[:2])
r_other = cm.ring(3, "other", 2)
print(" other: checkers", r_other.checkers, "fwd", r_other.fwd, "halt", r_other.halt_inputs)
run(r_other, [[("mutate", "M1")]])
print(first(r_other)[:2])

print("\n== 8.1 reflex table")
for direct in (True, False):
    for slow in (False, True):
        sy = cm.reflex(direct, slow)
        r, n, paths = first(sy)
        print(sy.name, "|", r, n, "| checkers W", sy.checkers["W"], "halt", sy.halt_inputs)
        for g in ("G1", "G2"):
            if paths[g]:
                cm.show(paths[g], "      ")
print(" failing case replayed:")
run(cm.reflex(False, True), [[("mutate", "W")], [], []])

print("\n== 8.1 hop count d, random systems (slow reports, no window, gate, only step = mutate of a work process)")


def hop_dist(system, w):
    """least number of report hops from a state checker of w to a halt input of w; None if no path."""
    starts = [c for c in system.checkers.get(w, ()) if c in system.monitors]
    targets = set(system.halt_inputs.get(w, ()))
    dist = {c: 0 for c in starts}
    frontier = list(starts)
    while frontier:
        nxt = []
        for m in frontier:
            for r in system.fwd.get(m, ()):
                if r not in dist:
                    dist[r] = dist[m] + 1
                    nxt.append(r)
        frontier = nxt
    ds = [d for m, d in dist.items() if m in targets]
    return min(ds) if ds else None


def rand_system(rng, n, nworks, coupling=True):
    s = cm.System("rand", 1)
    s.monitors = [f"M{i}" for i in range(1, n + 1)]
    s.works = [f"W{i}" for i in range(1, nworks + 1)]
    s.boundary = {m: i for i, m in enumerate(s.monitors)}
    p = rng.choice([0.2, 0.4, 0.6])
    for m in s.monitors:
        rest = [x for x in s.monitors if x != m]
        s.hb_readers[m] = [x for x in rest if rng.random() < p]
        s.checkers[m] = [x for x in rest if rng.random() < p]
        s.fwd[m] = [x for x in rest if rng.random() < p]
    for w in s.works:
        s.checkers[w] = [x for x in s.monitors if rng.random() < p]
        s.halt_inputs[w] = [x for x in s.monitors if rng.random() < p]
    s.slow_reports = True
    s.coupling = coupling
    return s


rng = random.Random(7)
bad_cases = 0
total = 0
hist = {}
for trial in range(20000):
    n = rng.randint(1, 6)
    sy = rand_system(rng, n, rng.randint(1, 2), coupling=rng.random() < 0.8)
    w = rng.choice(sy.works)
    d = hop_dist(sy, w)
    # run 12 rounds with the mutation the only env step; count work steps of w while bad
    s = cm.initial(sy)
    s = cm.apply_env(sy, s, ("mutate", w))
    steps_bad = 0
    rounds = 0
    for rnd in range(12):
        if cm.responded(sy, s):
            break
        s, info = cm.process_phase(sy, s)
        rounds += 1
        if w in info["executed"]:
            steps_bad += 1
    total += 1
    if d is None:
        ok = (steps_bad == rounds)          # works in every round that ran
        key = "nopath"
    else:
        ok = (steps_bad == d)
        key = d
    hist[key] = hist.get(key, 0) + 1
    if not ok:
        bad_cases += 1
        if bad_cases <= 5:
            print("  MISMATCH", d, steps_bad, rounds, sy.as_data())
print("  trials", total, "mismatches", bad_cases, "distribution of d", dict(sorted(hist.items(), key=str)))

# does it also hold when a state checker of w is 'w' has no checkers -> no path
# further faults can lower or raise the count:
print("  lower: relayed-slow, round 2 stop M2 (a halt input)")
run(cm.reflex(False, True), [[("mutate", "W")], [("stop", "M2")]])
print("  raise: chain M1 -> M2 -> M3, W checked by M1 halts on M3; relay M2 stopped in round 2")
ch = cm.System("chain", 1)
ch.monitors = ["M1", "M2", "M3"]; ch.works = ["W"]
ch.boundary = {"M1": 1, "M2": 2, "M3": 3}
ch.fwd = {"M1": ["M2"], "M2": ["M3"]}
ch.checkers = {"W": ["M1"]}
ch.halt_inputs = {"W": ["M3"]}
ch.slow_reports = True
print("   no further fault (d=2):")
run(ch, [[("mutate", "W")], [], [], []])
print("   relay stopped in round 2:")
run(ch, [[("mutate", "W")], [("stop", "M2")], [], [], []])
print("   relay mutated in round 2:")
run(ch, [[("mutate", "W")], [("mutate", "M2")], [], [], []])

print("\n== 8.2 table")
for n in (1024, 1048576):
    print(n, "window0", cm.growth(n, "window", 0), "window5", cm.growth(n, "window", 5),
          "c1h1", cm.growth(n, "cascade", 1, 1), "c1h128", cm.growth(n, "cascade", 1, 128),
          "c2h1", cm.growth(n, "cascade", 2, 1), "c2h2", cm.growth(n, "cascade", 2, 2), "c2h4", cm.growth(n, "cascade", 2, 4))
    for label, v in (("c1h1", cm.growth(n, "cascade", 1, 1)), ("c1h128", cm.growth(n, "cascade", 1, 128)),
                     ("c2h1", cm.growth(n, "cascade", 2, 1)), ("c2h2", cm.growth(n, "cascade", 2, 2)),
                     ("c2h4", cm.growth(n, "cascade", 2, 4))):
        print("    ", label, v, f"{100 * v / n:.4f}%")

print("\n== 8.2 window: damage = min(2^w, n)")
bad = 0
for n in list(range(1, 300)) + [1024, 3000, 1048576]:
    for w in range(0, 25):
        if cm.growth(n, "window", w) != min(2 ** w, n):
            bad += 1
            if bad < 5:
                print("  window mismatch", n, w, cm.growth(n, "window", w))
print("  window mismatches", bad)

print("\n== 8.2 bounds")
# first bound: chain (c=1), h hops per tick: damage >= n - h*ceil(log2 n), n >= 2
viol1 = []
for n in range(2, 3001):
    for h in (1, 2, 16, 128, 1000):
        d = cm.growth(n, "cascade", 1, h)
        if d < n - h * math.ceil(math.log2(n)):
            viol1.append((n, h, d))
print("  bound 1 violations n in 2..3000:", len(viol1), viol1[:5])
print("  bound 1 at n=1:", [(h, cm.growth(1, "cascade", 1, h)) for h in (1, 2)])
# second bound: c=2, 2 hops per tick: damage <= sqrt(n/2)
viol2 = []
for n in range(1, 3001):
    d = cm.growth(n, "cascade", 2, 2)
    if d * d * 2 > n:
        viol2.append((n, d))
print("  bound 2 violations n in 1..3000:", viol2[:10], len(viol2))
print("  bound 2, n=2,3,4:", [(n, cm.growth(n, "cascade", 2, 2), math.sqrt(n / 2)) for n in (1, 2, 3, 4, 5)])
# third: c=2, 1 hop per tick: share between 1/5 and 2/5 for n in 8..3000; exactly n/4 for powers of two >= 8
lo = hi = None
out_of_range = []
for n in range(2, 3001):
    d = cm.growth(n, "cascade", 2, 1)
    share = d / n
    if n >= 8:
        if lo is None or share < lo[0]:
            lo = (share, n, d)
        if hi is None or share > hi[0]:
            hi = (share, n, d)
        if not (5 * d >= n and 5 * d <= 2 * n):
            out_of_range.append((n, d, share))
print("  c=2,h=1 share over n=8..3000: min", lo, "max", hi, "outside [1/5,2/5]:", out_of_range[:10], len(out_of_range))
print("  c=2,h=1 for n=2..7:", [(n, cm.growth(n, "cascade", 2, 1), round(cm.growth(n, "cascade", 2, 1) / n, 3)) for n in range(2, 8)])
print("  beyond 3000 (sample):", [(n, round(cm.growth(n, "cascade", 2, 1) / n, 4)) for n in (3001, 5000, 6000, 10000, 12287, 12288, 100000, 786431, 1572863)])
pw = []
for k in range(1, 41):
    n = 2 ** k
    d = cm.growth(n, "cascade", 2, 1)
    pw.append((k, d * 4 == n))
print("  n/4 exactly for 2^k:", pw)
pw2 = [(k, cm.growth(2 ** k, "cascade", 2, 2) ** 2 * 2 <= 2 ** k, cm.growth(2 ** k, "cascade", 2, 2)) for k in range(1, 41)]
print("  bound 2 for powers of two:", all(x[1] for x in pw2), pw2[:12])
pw1 = [(k, h, cm.growth(2 ** k, "cascade", 1, h) >= 2 ** k - h * k) for k in range(1, 21) for h in (1, 16, 128)]
print("  bound 1 for powers of two up to 2^20:", all(x[2] for x in pw1))

print("\n== 8.2 n=8 example, another halting order")


def cascade_order(n, order):
    """c=2, one hop per tick. order(tick, newly, good, bad) -> number of bad to halt this hop."""
    good, bad, halted_bad, tick, frontier = n - 1, 1, 0, 0, 1
    log = []
    while bad:
        newly = min(frontier * 2, good + bad)
        hb = order(tick, newly, good, bad)
        hg = newly - hb
        assert 0 <= hb <= bad and 0 <= hg <= good
        good -= hg; bad -= hb; halted_bad += hb
        frontier = newly
        spread = min(bad, good)
        good -= spread; bad += spread
        log.append((tick, "halted good", hg, "halted bad", hb, "after spread: good", good, "bad running", bad))
        tick += 1
    return halted_bad + bad, log


def good_first(tick, newly, good, bad):
    return newly - min(newly, good)


def example(tick, newly, good, bad):
    if tick == 1:
        return 1
    return newly - min(newly, good)


for name, o in (("good first", good_first), ("example", example)):
    d, log = cascade_order(8, o)
    print(" ", name, "damage", d)
    for l in log:
        print("     ", l)
print("  growth(8, cascade, 2, 1) =", cm.growth(8, "cascade", 2, 1))

# exhaustive worst order for n=8, c=2, 1 hop/tick
best = {}


def worst(good, bad, halted_bad, frontier):
    if bad == 0:
        return halted_bad
    key = (good, bad, halted_bad, frontier)
    if key in best:
        return best[key]
    newly = min(frontier * 2, good + bad)
    res = 0
    for hb in range(max(0, newly - good), min(bad, newly) + 1):
        hg = newly - hb
        g, b = good - hg, bad - hb
        sp = min(b, g)
        res = max(res, worst(g - sp, b + sp, halted_bad + hb, newly))
    best[key] = res
    return res


print("  worst-order damage for n=8:", worst(7, 1, 0, 1), " n=16:", worst(15, 1, 0, 1), " n=64:", worst(63, 1, 0, 1), "vs good-first", cm.growth(64, "cascade", 2, 1))

print("\n== 9 heartbeat mirror")
for hb in (True, False):
    tr, st = cm.heartbeat_spec(["m1", "m2"], hb)
    print(" HB", hb, "states", st, "trace len", len(tr) if tr else None)
    if tr:
        for label, s_ in tr:
            print("    ", label, sorted(s_[0]), s_[1], sorted(s_[2]), s_[3], s_[4])
# count reachable states and those violating for HB False; three monitors too
for mons in (["m1"], ["m1", "m2"], ["m1", "m2", "m3"]):
    for hb in (True, False):
        tr, st = cm.heartbeat_spec(mons, hb)
        print("  ", mons, hb, "holds" if tr is None else f"broken, {len(tr)} states", st)

print("\n== 10.1 instances")
for name, sy in (("mesh4 f1", cm.mesh(4, 1)), ("mesh4 f2", cm.mesh(4, 2)), ("mesh4 f3", cm.mesh(4, 3)),
                 ("3+K K,M1", cm.with_coordinator(["K", "M1"])), ("3+K K", cm.with_coordinator(["K"])),
                 ("3+K all", cm.with_coordinator(["K", "M1", "M2", "M3"])),
                 ("nested3", cm.nested(3, True, 1)), ("nested3 rb", cm.nested(3, True, 1, ring_boundaries=True)),
                 ("nested1 f1", cm.nested(1, False, 1)), ("nested1 f2", cm.nested(1, False, 2)),
                 ("nested3 f2", cm.nested(3, True, 2))):
    r, n, paths = first(sy)
    print(" ", name, r, n)
print("  3+K: K checkers of others?", {k: v for k, v in cm.with_coordinator(["K", "M1"]).checkers.items()})
print("  3+K gate K, mutate K:")
run(cm.with_coordinator(["K"]), [[("mutate", "K")]])
r, n, paths = first(cm.with_coordinator(["K"]))
cm.show(paths["G2"], "     ")
cm.show(paths["G1"], "     ")
m4 = cm.mesh(4, 1)
print("  mesh4: W checkers", m4.checkers["W"], "halt", m4.halt_inputs)

print("\n== 10.1 catalogue: plain systems f=1 vs conditions (from results.json)")
import json
cases = json.load(open(_mc("results.json"), encoding="utf-8"))
print("  cases", len(cases))
tally = {}
plain_ids = []
for c in cases:
    sy = cm.System(c["system"]["name"], c["system"]["f"])
    for k, v in c["system"].items():
        setattr(sy, k, v)
    if cm.is_plain(sy) and sy.f == 1:
        key = (cm.sufficient_f1(sy), c["G1"] is None and c["G2"] is None)
        tally[key] = tally.get(key, 0) + 1
        plain_ids.append(c["id"])
print("  plain f=1:", len(plain_ids), tally)
print("  of which one-edge removals:", sum("minus" in i for i in plain_ids))
print("  the others:", [i for i in plain_ids if "minus" not in i])

print("\n== 10.2 meshes n 1..4, f 1..3")
for n in (1, 2, 3, 4):
    print("  ", n, [(f, first(cm.mesh(n, f))[0]) for f in (1, 2, 3)])

print("\n== 10.3 restart game")
ring3 = {"X1": ["X3"], "X2": ["X1"], "X3": ["X2"]}
mesh3 = {"X1": ["X2", "X3"], "X2": ["X1", "X3"], "X3": ["X1", "X2"]}
with_k = {"X1": ["X3", "K"], "X2": ["X1", "K"], "X3": ["X2", "K"], "K": ["X1", "X2", "X3"]}
for name, obs, selfs in (("ring3", ring3, ()), ("mesh3", mesh3, ()), ("withK self", with_k, ("K",)), ("withK noself", with_k, ())):
    print("  ", name, cm.restart_game(obs, selfs))

# every other member must be reached from the member that can start first:
# all observer graphs on 3 and 4 members (no self-observation), one fixed self-starter "K"


def reachable_from(observers, k):
    # edge k -> m when k observes m, i.e. k in observers[m]
    seen = {k}
    stack = [k]
    while stack:
        cur = stack.pop()
        for m, obs in observers.items():
            if cur in obs and m not in seen:
                seen.add(m)
                stack.append(m)
    return seen


for size in (3, 4):
    members = ["K"] + [f"X{i}" for i in range(1, size)]
    pairs = [(a, b) for a in members for b in members if a != b]   # a observes b
    agree = disagree = 0
    examples = []
    count = 0
    for bits in itertools.product((0, 1), repeat=len(pairs)):
        observers = {m: [] for m in members}
        for (a, b), bit in zip(pairs, bits):
            if bit:
                observers[b].append(a)
        stuck, _ = cm.restart_game(observers, ("K",))
        can = stuck is None
        reach_all = reachable_from(observers, "K") == set(members)
        count += 1
        if can == reach_all:
            agree += 1
        else:
            disagree += 1
            if len(examples) < 3:
                examples.append((observers, can, reach_all, stuck))
    print(f"  size {size}: graphs {count}, 'always restarts' == 'all reached from K': agree {agree}, disagree {disagree}", examples)

# no self-starter at all: any graph on 3 members can always restart?
members = ["X1", "X2", "X3"]
pairs = [(a, b) for a in members for b in members if a != b]
can_count = 0
for bits in itertools.product((0, 1), repeat=len(pairs)):
    observers = {m: [] for m in members}
    for (a, b), bit in zip(pairs, bits):
        if bit:
            observers[b].append(a)
    stuck, _ = cm.restart_game(observers, ())
    if stuck is None:
        can_count += 1
print("  3 members, no member can start first: graphs that can always restart:", can_count, "of", 2 ** len(pairs))
