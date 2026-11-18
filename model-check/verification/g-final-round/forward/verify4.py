"""Forward verifier, fourth batch: the author's census of section 12.1, system by system.
Run with python -I -B."""
import copy
import sys
import time

import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, FM)
import check_model as cm  # noqa: E402

t0 = time.time()
rows = {}
for n, count in ((2, None), (3, 6000)):
    seen = set()
    total = free = 0
    fails = dict.fromkeys(cm.CENSUS_NAMES, 0)
    stays = dict.fromkeys(cm.CENSUS_NAMES, 0)
    q4_stay = []
    q4r_stay = []
    for s in cm.small_systems(n, count, 1):
        k = cm.key_of(s)
        if k in seen:
            continue
        seen.add(k)
        total += 1
        if not cm.gap_free(s):
            continue
        free += 1
        p = cm.predicates(s)
        for name in cm.CENSUS_NAMES:
            if not p[name]:
                fails[name] += 1
                if not cm.explained_by_spares(s, (name,)):
                    stays[name] += 1
                    if name == "Q4":
                        q4_stay.append(s)
                    if name == "Q4r":
                        q4r_stay.append(s)
    rows[n] = (total, free, fails, stays, q4_stay, q4r_stay)
    print(n, "monitors:", total, "systems,", free, "with no gap; fails", fails, "stays", stays, flush=True)

tot_fail = {k: rows[2][2][k] + rows[3][2][k] for k in cm.CENSUS_NAMES}
tot_stay = {k: rows[2][3][k] + rows[3][3][k] for k in cm.CENSUS_NAMES}
print("totals: no gap", rows[2][1] + rows[3][1], "fails", tot_fail, "stays", tot_stay)

# In the systems where the propagation predicate stays failed: does any report edge matter?
need_report = 0
no_fwd_at_all = 0
examples = []
all_q4 = rows[2][4] + rows[3][4]
for s in all_q4:
    t = copy.deepcopy(s)
    t.fwd = {m: [] for m in t.monitors}
    if not any(s.fwd.get(m) for m in s.monitors):
        no_fwd_at_all += 1
    if not cm.gap_free(t):
        need_report += 1
        if len(examples) < 2:
            examples.append(s)
print("systems where Q4 stays failed:", len(all_q4))
print("  of which have no report edge at all:", no_fwd_at_all)
print("  of which have a gap once every report edge is removed (a flag does have to travel):", need_report)
for s in examples:
    print("   example:", {r: getattr(s, r) for r in cm.RELATIONS})
    t = copy.deepcopy(s)
    t.fwd = {m: [] for m in t.monitors}
    first, _ = cm.explore(t)
    for g in ("G1", "G2"):
        if first[g]:
            print("    without reports, shortest", g)
            cm.show(first[g], "      ")
print("systems where Q4r stays failed:", len(rows[2][5] + rows[3][5]))
print("seconds", round(time.time() - t0, 1))
