"""Sweep: section 12.1 counts 289 / 243 / 46, falsifier system 6.6, pass B's P4 systems,
18 of 27 single edges of R."""
import copy
import sys
import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


sys.path.insert(0, _mc())
import check_model as cm


def first(system):
    f, n = cm.explore(system)
    return {g: (len(p) if p else None) for g, p in f.items()}, n, f


print("== R single-edge removals (f=1)")
needed, spare = [], []
for label, s in cm.ablations(cm.reference()):
    r, n, _ = first(s)
    (needed if (r["G1"] or r["G2"]) else spare).append(label)
print("  edges", len(needed) + len(spare), "needed", len(needed), "spare", len(spare))
print("  needed:", needed)

print("\n== pass B's P4 systems without report edges")
r = cm.reference(without=("P4",))
for w in list(r.halt_inputs):
    r.halt_inputs[w] = list(r.monitors)
print("  R-P4, every work process reads all three:", first(r)[:2])
r = cm.reference(without=("P4",))
r.checkers["W1"].append("M3"); r.checkers["W2"].append("M3")
print("  R-P4, W1 and W2 also checked by M3:", first(r)[:2])
m = cm.mesh(3); m.fwd = {}
print("  mesh of 3 with no report edges:", first(m)[:2])

print("\n== falsifier system 6.6 (four monitors, Q4 alone fails)")
s = cm.System("F4x1-Q4-1", 1)
s.monitors = ["a", "b", "c", "d"]; s.works = ["w"]
s.boundary = {m_: i for i, m_ in enumerate(s.monitors)}
s.hb_readers = {"a": ["b"], "b": ["a"], "c": ["a"], "d": ["c"]}
s.checkers = {"a": ["b"], "b": ["d"], "c": ["b"], "d": ["b"], "w": ["b"]}
s.fwd = {}
s.halt_inputs = {"w": ["b", "d"]}
print("  result", first(s)[:2], "predicates", cm.predicates(s), "plain", cm.is_plain(s))
st = cm.initial(s)
st = cm.apply_env(s, st, ("stop", "c"))
st, info = cm.process_phase(s, st)
print("  after stop c: flagged", sorted(st.flagged), "out", info["out"], "worked", info["executed"], "halted", info["halted"], "responded", cm.responded(s, st))
print("  spare monitors:", [m_ for m_ in s.monitors if cm.gap_free(cm.without_monitor(s, m_))])

print("\n== census: Q4 failures not down to spare monitors; of those, gap-free with every report edge removed")
tot_stay = tot_nofwd = 0
q1_checks = {"Q1_fail": 0, "Q1_stay": 0, "Q1f_fail": 0, "Q1f_stay": 0, "Q4r_fail": 0, "Q4r_stay": 0, "Q3": 0, "Q8": 0, "Q4_fail": 0}
tot_free = tot_total = 0
all_stop = 0
for n, count in ((2, None), (3, 6000)):
    seen = set()
    total = free = 0
    stay = []
    for sy in cm.small_systems(n, count, 1):
        k = cm.key_of(sy)
        if k in seen:
            continue
        seen.add(k)
        total += 1
        if not cm.gap_free(sy):
            continue
        free += 1
        p = cm.predicates(sy)
        for name in cm.CENSUS_NAMES:
            if not p[name]:
                key = name + "_fail" if name not in ("Q3", "Q8") else name
                q1_checks[key] += 1
                if name in ("Q1", "Q1f", "Q4r") and not cm.explained_by_spares(sy, (name,)):
                    q1_checks[name + "_stay"] += 1
        if not p["Q4"] and not cm.explained_by_spares(sy, ("Q4",)):
            stay.append(sy)
    nofwd = 0
    partial_reach = 0
    for sy in stay:
        t = copy.deepcopy(sy)
        t.fwd = {m_: [] for m_ in t.monitors}
        if cm.gap_free(t):
            nofwd += 1
        else:
            # a flag does travel: some report edge exists, and not between every pair
            assert any(sy.fwd.get(m_) for m_ in sy.monitors)
            partial_reach += 1
    print(f"  n={n}: systems {total}, no gap {free}, Q4 fails and not down to spares {len(stay)}, "
          f"of those gap-free with no report edges {nofwd}, the rest {partial_reach}")
    tot_stay += len(stay); tot_nofwd += nofwd; tot_free += free; tot_total += total
print("  totals: systems", tot_total, "no gap", tot_free, "| Q4 stays", tot_stay, "| no report needed", tot_nofwd, "| other", tot_stay - tot_nofwd)
print("  other predicate counts:", q1_checks)
