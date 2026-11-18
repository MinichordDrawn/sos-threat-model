import os, sys, copy, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rc import *

# ---------- the falsifier's system 6.6
def plain(mons, works, hb, ck, fwd, hi):
    s = cm.System("x", 1)
    s.monitors, s.works = list(mons), list(works)
    s.boundary = {m: "b_" + m for m in mons}
    s.hb_readers, s.checkers, s.fwd, s.halt_inputs = hb, ck, fwd, hi
    return s
s66 = plain("abcd", ["w"], {"a": ["b"], "b": ["a"], "c": ["a"], "d": ["c"]},
            {"a": ["b"], "b": ["d"], "c": ["b"], "d": ["b"], "w": ["b"]}, {}, {"w": ["b", "d"]})
first, states = cm.explore(s66)
print("6.6: plain", cm.is_plain(s66), "G1", n(first["G1"]), "G2", n(first["G2"]), "states", states)
print("  spare monitors:", [m for m in s66.monitors if cm.gap_free(cm.without_monitor(s66, m))])
rounds, why = cm.replay(s66, [[("stop", "c")], []])
cm.show(rounds); print("  ", why)
print("  predicates:", cm.predicates(s66))

def detection_without_halt(system):
    """Is there a reachable round that ends with a live correct flag and a work step?"""
    start = cm.initial(system); seen = {start}; stack = [start]
    while stack:
        s = stack.pop()
        if cm.responded(system, s): continue
        for steps, a in cm.env_choices(system, s):
            t, info = cm.process_phase(system, a)
            if info["out"] and info["executed"]:
                return True
            if t not in seen:
                seen.add(t); stack.append(t)
    return False
print("  6.6 detection without halt:", detection_without_halt(s66))

# ---------- the author's census, recounted
tot = {}
keep = {}
allfree = []
for nmon, count in ((2, None), (3, 6000)):
    seen = set(); total = free = 0
    fails = dict.fromkeys(cm.CENSUS_NAMES, 0); stays = dict.fromkeys(cm.CENSUS_NAMES, 0)
    q4stay = []
    for s in cm.small_systems(nmon, count, 1):
        k = cm.key_of(s)
        if k in seen: continue
        seen.add(k); total += 1
        if not cm.gap_free(s): continue
        free += 1; allfree.append(s)
        p = cm.predicates(s)
        for name in cm.CENSUS_NAMES:
            if not p[name]:
                fails[name] += 1
                if not cm.explained_by_spares(s, (name,)):
                    stays[name] += 1
                    if name == "Q4": q4stay.append(s)
    print(nmon, "monitors:", total, "systems,", free, "no gap; fails", fails, "stays", stays)
    keep[nmon] = q4stay
q = keep[2] + keep[3]
print("Q4 still failing with spares set aside:", len(keep[2]), "+", len(keep[3]), "=", len(q))
def nofwd(s):
    t = copy.deepcopy(s); t.fwd = {m: [] for m in t.monitors}; return t
gf_nofwd = sum(1 for s in q if cm.gap_free(nofwd(s)))
print("  of those, still no gap with every report edge removed:", gf_nofwd, "| not:", len(q) - gf_nofwd)
print("  of those, with no report edge at all:", sum(1 for s in q if not any(s.fwd.get(m) for m in s.monitors)))
print("  of those, work reads every monitor:", sum(1 for s in q if set(s.halt_inputs["W"]) == set(s.monitors)))
print("  of those, a reachable round with a live correct flag and a work step:", sum(1 for s in q if detection_without_halt(s)))
print("all", len(allfree), "census systems with no gap: with a live flag and a work step in some round:",
      sum(1 for s in allfree if detection_without_halt(s)))
# in the 289, is the failing monitor (whose flag does not reach all) non-spare in the system as given?
def failing_monitors(s):
    mons = set(s.monitors)
    return [a for a in mons if not mons <= cm.reach(s, [a], ())]
cnt_all_spare = 0
for s in q:
    fm = failing_monitors(s)
    if all(cm.gap_free(cm.without_monitor(s, m)) for m in fm):
        cnt_all_spare += 1
print("  of the", len(q), ": every monitor whose flag fails to reach the others is spare in the system as given:", cnt_all_spare)
# an example of the 46
for s in q:
    if not cm.gap_free(nofwd(s)):
        print("  example needing a report:", {r: getattr(s, r) for r in cm.RELATIONS})
        first, _ = cm.explore(nofwd(s))
        for gl in ("G1", "G2"):
            if first[gl]: print("   without reports,", gl, ":"); cm.show(first[gl])
        break
