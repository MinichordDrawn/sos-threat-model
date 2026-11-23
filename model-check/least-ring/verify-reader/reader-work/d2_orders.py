"""Orders outside the seven of results-minimal 5.1, to test how far 'the top coordinator joins
first, not last' is forced."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys
from tower import system
from grow import ring_groups, grow_system

R2 = ["D2", "A2", "B2", "C2", "W2"]
R3 = ["D3", "A3", "B3", "C3", "W3"]
extra = {
    "both rings whole in ONE step, then T": [{"name": "rings", "members": R2 + R3},
                                             {"name": "T", "members": ["T"], "after": ["W2"]}],
    "ring 2 whole; ring 3 whole and T together in one step": [{"name": "r2", "members": R2},
                                                              {"name": "r3T", "members": R3 + ["T"], "after": ["W2"]}],
    "T and D2 together in one step; then ring 2's members, W2; then ring 3": [
        {"name": "TD2", "members": ["T", "D2"]}] + ring_groups(2, [], False)[1:] + ring_groups(3, ["W2"], False),
    "ring 2 whole and T together in one step; then ring 3 whole": [{"name": "r2T", "members": R2 + ["T"]},
                                                                  {"name": "r3", "members": R3, "after": ["W2"]}],
    "everything in one step": [{"name": "all", "members": R2 + R3 + ["T"]}],
}
for label, groups in extra.items():
    for rn in ("flow", "actor"):
        cells = []
        for f in (1, 2, 3):
            d = system(2, rn, "all", f)
            d["late"] = groups
            d["arrive_bad"] = True
            r = Sys(d).solve_plain(stop_early=True, state_limit=300000)
            cells.append("f=%d G1 %s G2 %s%s" % (f, r["G1"], r["G2"], "" if r["complete"] else " (cut off)"))
        d = system(2, rn, "all", 1, scoped=True, freeze=True)
        d["late"] = groups
        d["arrive_bad"] = True
        r = Sys(d).solve_scoped(state_limit=2000000)
        print("%-70s %-5s one system: %s | scopes f=1: G1 %s G2 %s told %s spill %s%s" % (
            label, rn, " | ".join(cells), r["G1"], r["G2"], r["told"], r["spill"], "" if r["complete"] else " (cut off)"), flush=True)

print("the author's order when no monitor may arrive bad:")
for rn in ("flow", "actor"):
    for f in (1,):
        r = Sys(grow_system("author", rn, f, arrive_bad=False)).solve_plain(stop_early=True, state_limit=300000)
        print("  ", rn, "f=%d G1 %s G2 %s" % (f, r["G1"], r["G2"]))

print("three rings without T, everything present from the start, as one system:")
for rn in ("flow", "actor"):
    for f in (1, 2, 3):
        d = system(2, rn, "all", f)
        # remove T altogether
        d["monitors"].remove("T")
        for k in ("hb_readers", "checkers", "fwd"):
            d[k].pop("T", None)
            for kk in d[k]:
                d[k][kk] = [x for x in d[k][kk] if x != "T"]
        d["boundary"].pop("T")
        r = Sys(d).solve_plain(stop_early=True, state_limit=100000)
        print("  ", rn, "f=%d G1 %s G2 %s%s" % (f, r["G1"], r["G2"], "" if r["complete"] else " (cut off)"))
