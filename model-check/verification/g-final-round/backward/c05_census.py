"""Section 12.1, the author's census: recount it with the checker's own functions, then test
the sentences written about the systems in which propagation (Q4) still fails with spare
monitors set aside."""
import copy
import os
import sys
from collections import deque

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bw import cm  # noqa: E402


def detection_without_halt(system):
    """Is there a reachable round at whose end a live, correct monitor is flagged while a
    work process took a work step in that round? Returns one (path, info) or None."""
    start = cm.initial(system)
    parent = {start: None}
    q = deque([start])
    while q:
        s = q.popleft()
        if cm.responded(system, s):
            continue
        for steps, after in cm.env_choices(system, s):
            t, info = cm.process_phase(system, after)
            if info["out"] and info["executed"]:
                return steps, info
            if t not in parent:
                parent[t] = (s, steps)
                q.append(t)
    return None


tot = {}
for n, count in ((2, None), (3, 6000)):
    seen = set()
    total = free = 0
    fails = dict.fromkeys(cm.CENSUS_NAMES, 0)
    stays = dict.fromkeys(cm.CENSUS_NAMES, 0)
    q4_stay = []
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
    print(f"n={n}: total {total}, gap-free {free}, fails {fails}, stays {stays}", flush=True)
    tot[n] = (total, free, fails, stays)

    # the sentences about the systems where Q4 still fails
    need_report = []          # not gap-free once every report edge is removed
    all_unreaching_spare = [] # every monitor whose flag does not reach all others is spare
    no_direct = []            # some detection stops no work in its round
    reads_all = 0
    for s in q4_stay:
        t = copy.deepcopy(s)
        t.fwd = {m: [] for m in t.monitors}
        if not cm.gap_free(t):
            need_report.append(s)
        mons = set(s.monitors)
        unreaching = [a for a in mons if not mons <= cm.reach(s, [a], ())]
        if all(cm.gap_free(cm.without_monitor(s, a)) for a in unreaching):
            all_unreaching_spare.append(s)
        if detection_without_halt(s):
            no_direct.append(s)
        if set(s.halt_inputs["W"]) == mons:
            reads_all += 1
    print(f"   Q4 still fails in {len(q4_stay)}; of those:")
    print(f"     not gap-free once all report edges are removed (a flag does have to travel): {len(need_report)}")
    print(f"     work reads every monitor: {reads_all}")
    print(f"     every monitor whose flag does not reach all others is spare: {len(all_unreaching_spare)}")
    print(f"     some round ends with a live correct flag and a work step: {len(no_direct)}")
    for s in need_report[:2]:
        print("     example needing a report:", {r: getattr(s, r) for r in cm.RELATIONS})
    for s in all_unreaching_spare[:2]:
        print("     example, unreaching monitors all spare:", {r: getattr(s, r) for r in cm.RELATIONS})

a, b = tot[2], tot[3]
print("sums:", {k: (a[2][k] + b[2][k], a[3][k] + b[3][k]) for k in cm.CENSUS_NAMES},
      "gap-free", a[1] + b[1], "systems", a[0], b[0])
