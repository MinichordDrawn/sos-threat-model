"""Sections 13, 11, 10, 8: B's fixes, single-edge removals from R, the ablation table, Theorem S
tally with my own reading of (a)-(d), the coordinator systems, the reflex, restart, growth."""
import json
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bw import cm, res, FM  # noqa: E402

print("=== B's four defects, as fixed")
r1 = cm.reference(without="P8b")
r2 = cm.reference(without=("P8b",))
print(" D3 string arg:", r1.name, "| window", r1.window, "| same halt_inputs as tuple form:",
      r1.halt_inputs == r2.halt_inputs, "| unknown name raises:", end=" ")
try:
    cm.reference(without="P9")
    print("NO")
except ValueError as e:
    print("yes,", e)
try:
    x = cm.reference(without=("P3",), unread_extra=True)
    print(" D4 no KeyError; checkers:", x.checkers)
except Exception as e:  # noqa
    print(" D4 still raises", repr(e))
# D1: a joiner named "" or 0
s = cm.System("d1")
s.monitors, s.works, s.joiner = ["M"], ["W"], 0
print(" D1 join offered for joiner named 0:", ("join", 0) in cm.env_steps(s, cm.initial(s)))
# D2: replay stops at a responded state
rounds, why = cm.replay(cm.reference(), [[("stop", "M1")], [("stop", "M2")], [("stop", "M3")], [("mutate", "W1")]])
print(" D2 replay in full R of stop M1; stop M2; stop M3; mutate W1 ->", len(rounds), "round(s),", why)

print("=== section 11: single-edge removals from R")
needed, spare = [], []
for label, t in cm.ablations(cm.reference()):
    g1, g2, _, _ = res(t)
    (needed if (g1 or g2) else spare).append(label)
print(" edges:", len(needed) + len(spare), "spare:", len(spare), "needed:", len(needed))
print(" needed:", needed)

print("=== section 10.1: ablations of nested3-upper3 from results.json")
cases = json.load(open(os.path.join(FM, "results.json"), encoding="utf-8"))
abl = [(c["id"].split("minus: ")[1], c["G1"], c["G2"]) for c in cases if "/minus: " in c["id"]]
kinds = {}
for label, g1, g2 in abl:
    kind = ("read" if "signal" in label else "check" if "checks" in label
            else "report" if "reports" in label else "halt")
    upper = sum(n in label for n in ("KA", "KB", "U3")) >= 2 or "U3" in label
    key = (kind, "upper" if upper else "base", "needed" if (g1 or g2) else "spare")
    kinds.setdefault(key, []).append((label, g1, g2))
for k in sorted(kinds):
    print(" ", k, len(kinds[k]), [x[0] for x in kinds[k]])
print(" coordinator edges:")
for label, g1, g2 in abl:
    if ("KA" in label or "KB" in label):
        print("    ", "needed" if (g1 or g2) else "spare ", "|", label, "| G1", g1, "G2", g2)
n = cm.nested(3, True, 1)
print(" checkers of KA:", n.checkers["KA"], "| readers of KA:", n.hb_readers["KA"],
      "| KA reports to:", n.fwd["KA"], "| who reports to KA:", [m for m in n.monitors if "KA" in n.fwd.get(m, [])])
print(" nested3-upper3 at f=2: see c04")

print("=== section 10.1: Theorem S tally, my own reading of (a)-(d)")


def my_conditions(d):
    mons = list(d["monitors"])
    chk, hb, fwd, halt = d["checkers"], d["hb_readers"], d["fwd"], d["halt_inputs"]

    def watchers(z):
        return [m for m in mons if m != z and m in chk.get(z, []) and m in hb.get(z, [])]

    def reach(starts, avoid=None):
        seen = set(s for s in starts if s != avoid)
        todo = list(seen)
        while todo:
            m = todo.pop()
            for r in fwd.get(m, []):
                if r != avoid and r not in seen:
                    seen.add(r)
                    todo.append(r)
        return seen

    a = all(watchers(z) for z in mons)
    b = all(len(chk.get(w, [])) >= 1 and len(set(halt.get(w, []))) >= 2 for w in d["works"])
    c = all(all(u in reach(watchers(z), z) for u in mons if u != z) for z in mons)
    dd = all(any(all(u in reach([k]) for u in mons) for k in chk.get(w, [])) for w in d["works"])
    return a and b and c and dd


def my_plain(d):
    b = [d["boundary"].get(m, ("none", m)) for m in d["monitors"]]
    return (d["joiner"] is None and not d["substrate"] and not d["switches"] and len(set(map(str, b))) == len(b)
            and d["coupling"] and d["window"] == 0 and d["gate"] and not d["slow_reports"])


tally = {}
nonplain_counter = []
for c in cases:
    d = c["system"]
    ok = c["G1"] is None and c["G2"] is None
    if d["f"] == 1 and my_plain(d):
        tally[(my_conditions(d), ok)] = tally.get((my_conditions(d), ok), 0) + 1
    elif d["f"] == 1 and my_conditions(d) and not ok:
        nonplain_counter.append((c["id"], c["G1"], c["G2"]))
print(" plain f=1 systems:", sum(tally.values()), tally)
print(" non-plain f=1 cases where (a)-(d) hold and a goal is broken:", nonplain_counter)

print("=== section 10.1: coordinator")
k1 = cm.with_coordinator(["K"])
g1, g2, st, first = res(k1)
print(" 3+K gate K:", g1, g2, st)
cm.show(first["G2"])
print(" K checks:", [x for x, cs in k1.checkers.items() if "K" in cs], "| K reads:",
      [x for x, cs in k1.hb_readers.items() if "K" in cs])
print(" 3+K gate K+M1:", res(cm.with_coordinator(["K", "M1"]))[:3])
for f in (1, 2, 3):
    print(" mesh4 f", f, res(cm.mesh(4, f))[:3])

print("=== section 8.1: reflex")
for direct in (True, False):
    for slow in (False, True):
        s = cm.reflex(direct, slow)
        g1, g2, st, first = res(s)
        print(" direct", direct, "slow", slow, "->", g1, g2, st, "| checkers W", s.checkers["W"], "halt", s.halt_inputs["W"])
        if first["G2"]:
            cm.show(first["G2"])
s = cm.reflex(False, True)
st_ = cm.initial(s)
for i, steps in enumerate([[("mutate", "W")], [], []], 1):
    if cm.responded(s, st_):
        print("   ended before round", i)
        break
    for e in steps:
        st_ = cm.apply_env(s, st_, e)
    st_, info = cm.process_phase(s, st_)
    print("   relayed+slow round", i, steps, "out", info["out"], "worked", info["executed"], "halted", info["halted"])

print("=== section 10.3: restart")
ring3 = {"X1": ["X3"], "X2": ["X1"], "X3": ["X2"]}
mesh3 = {"X1": ["X2", "X3"], "X2": ["X1", "X3"], "X3": ["X1", "X2"]}
with_k = {"X1": ["X3", "K"], "X2": ["X1", "K"], "X3": ["X2", "K"], "K": ["X1", "X2", "X3"]}
for name, obs, selfs in (("ring3", ring3, ()), ("mesh3", mesh3, ()), ("ring3+K self", with_k, ("K",)),
                         ("ring3+K not self", with_k, ())):
    print(" ", name, cm.restart_game(obs, selfs))
# a ring in which every member can start by itself
print("  ring3, all self-starting:", cm.restart_game(ring3, ("X1", "X2", "X3")))
# K self-starting but observing only one member
k_one = {"X1": ["X3", "K"], "X2": ["X1"], "X3": ["X2"], "K": ["X1", "X2", "X3"]}
print("  ring3 + self-starting K that observes only X1:", cm.restart_game(k_one, ("K",)))

print("=== section 8.2: growth")
for n in (1024, 1048576):
    print(" ", n, [cm.growth(n, "window", w) for w in (0, 1, 2, 5)],
          [cm.growth(n, "cascade", a, b) for a, b in ((1, 1), (1, 16), (1, 128), (2, 1), (2, 2), (2, 4))])
print("  window: 2^w beyond n:", cm.growth(8, "window", 5), cm.growth(1024, "window", 11))
viol1 = viol2 = 0
first2 = []
quarter = []
ratio = []
for n in range(1, 3001):
    for h in (1, 2, 3, 5, 16, 128):
        if cm.growth(n, "cascade", 1, h) < n - h * math.ceil(math.log2(n)) - 1e-9:
            viol1 += 1
    d2 = cm.growth(n, "cascade", 2, 2)
    if d2 > math.sqrt(n / 2) + 1e-9:
        viol2 += 1
        first2.append((n, d2))
    d1 = cm.growth(n, "cascade", 2, 1)
    ratio.append((d1 / n, n))
    if n & (n - 1) == 0:
        quarter.append((n, d1, d1 * 4 == n))
print("  chain bound violations, n=1..3000:", viol1)
print("  sqrt(n/2) bound violations at 2 hops/tick, n=1..3000:", viol2, first2[:5])
print("  powers of two, 1 hop/tick, damage == n/4:", quarter)
big = [(m, cm.growth(2 ** m, "cascade", 2, 1) * 4 == 2 ** m, cm.growth(2 ** m, "cascade", 2, 2) <= math.sqrt(2 ** m / 2),
        m > 20 or cm.growth(2 ** m, "cascade", 1, 1) >= 2 ** m - m) for m in range(12, 41)]
print("  powers of two 2^12..2^40 all three:", all(a and b and c for _, a, b, c in big))
r8 = [x for x in ratio if x[1] >= 8]
print("  1 hop/tick, c=2: damage/n over n=8..3000: min", min(r8), "max", max(r8))
print("  1 hop/tick, c=2: damage/n over n=1..7:", [(n, cm.growth(n, 'cascade', 2, 1)) for n in range(1, 8)])
# more hops per tick than two: is the sqrt bound still met?
worse = [(n, h, cm.growth(n, "cascade", 2, h)) for n in range(2, 3001) for h in (3, 4, 8)
         if cm.growth(n, "cascade", 2, h) > math.sqrt(n / 2) + 1e-9]
print("  c=2, h in 3,4,8: violations of sqrt(n/2):", len(worse), worse[:5])
