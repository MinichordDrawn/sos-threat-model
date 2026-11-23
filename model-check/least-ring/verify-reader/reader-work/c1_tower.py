"""Part C: the thirteen-monitor tower (and forty)."""
import sys, os, time
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys
from tower import system, tower
from ring import READINGS, edges_of


def one(d):
    r = Sys(d).solve_plain(stop_early=True, state_limit=60000)
    return "G1 %s G2 %s (%d states%s)" % (r["G1"], r["G2"], r["states"],
                                          "" if r["complete"] else ", search cut off in round %d: a missing number is not a null" % r["rounds_explored"])


def sc(d, limit=None):
    t0 = time.time()
    r = Sys(d).solve_scoped(state_limit=limit)
    top = [k for k in r["scopes"] if k == "sT"]
    base = [k for k in r["scopes"] if k.startswith("sD")]
    mid = [k for k in r["scopes"] if k.startswith("sE")]

    def least(keys, j):
        vs = [r["scopes"][k][j] for k in keys if r["scopes"][k][j] is not None]
        return min(vs) if vs else None
    return ("G2 all %s | G1 base %s | G1 mid %s | G1 top %s | G2 base %s | G2 mid %s | G2 top %s | told %s | spill %s | "
            "states %d complete %s rounds %d  [%.0fs]" % (
                r["G2"], least(base, "G1"), least(mid, "G1"), least(top, "G1"), least(base, "G2"), least(mid, "G2"),
                least(top, "G2"), r["told"], r["spill"], r["states"], r["complete"], r["rounds_explored"],
                time.time() - t0))


which = sys.argv[1] if len(sys.argv) > 1 else "all"

if which in ("one", "all"):
    print("=== 4.1 as one system ===")
    for rn in ("flow", "actor"):
        for f in (1, 2, 3, 4):
            print(rn, "reads all f=%d:" % f, one(system(2, rn, "all", f)), "| ring boundaries:",
                  one(system(2, rn, "all", f, ring_boundaries=True)), "| reads two:", one(system(2, rn, "two", f)))
    print("=== 4.1 one connection removed, as one system ===")
    t = tower(2)
    for rn in ("flow", "actor"):
        res = {}
        for a in t["arrows"]:
            kind = "upper cycle" if a in [("D1", "D2"), ("D2", "D3"), ("D3", "D1")] else (
                "T-D" if "T" in a else "base ring")
            for f in (1, 2, 3):
                r = Sys(system(2, rn, "all", f, remove=[a])).solve_plain(stop_early=True, state_limit=60000)
                if not r["complete"]:
                    r["G1"] = "%s?" % r["G1"]
                res.setdefault((kind if kind != "T-D" else ("%s->%s" % (a[0][0], a[1][0])), f), set()).add((r["G1"], r["G2"]))
        print(rn, {k: v for k, v in sorted(res.items())})
        for f in (1, 2, 3):
            print(rn, "all three upper-cycle arrows removed (33), f=%d:" % f,
                  one(system(2, rn, "all", f, remove=[("D1", "D2"), ("D2", "D3"), ("D3", "D1")])))

if which in ("scoped", "all"):
    print("=== 4.3 with a scope per ring, reads all ===")
    for rn in ("flow", "actor"):
        print(rn, "f=1 freeze, all states:", sc(system(2, rn, "all", 1, scoped=True, freeze=True)), flush=True)
        print(rn, "f=2 freeze, all states:", sc(system(2, rn, "all", 2, scoped=True, freeze=True), limit=3000000), flush=True)
        print(rn, "f=4 freeze, 1 round:", sc(system(2, rn, "all", 4, scoped=True, freeze=True, max_rounds=1)), flush=True)
        print(rn, "reads two f=1 freeze:", sc(system(2, rn, "two", 1, scoped=True, freeze=True)), flush=True)
        print(rn, "reads two f=2 freeze, 2 rounds:", sc(system(2, rn, "two", 2, scoped=True, freeze=True, max_rounds=2)), flush=True)
        print(rn, "other choice (coordinator's fault lands above), f=1 freeze:",
              sc(system(2, rn, "all", 1, scoped=True, freeze=True, coord_up=True)), flush=True)
        print(rn, "other choice, f=2 freeze:",
              sc(system(2, rn, "all", 2, scoped=True, freeze=True, coord_up=True), limit=3000000), flush=True)
        print(rn, "ring boundaries f=1 freeze:",
              sc(system(2, rn, "all", 1, scoped=True, freeze=True, ring_boundaries=True)), flush=True)
        print(rn, "ring boundaries f=2 freeze, 3 rounds:",
              sc(system(2, rn, "all", 2, scoped=True, freeze=True, ring_boundaries=True, max_rounds=3), limit=3000000), flush=True)

if which in ("scoped3", "all"):
    for rn in ("flow", "actor"):
        print(rn, "f=3 freeze, 2 rounds:", sc(system(2, rn, "all", 3, scoped=True, freeze=True, max_rounds=2), limit=4000000), flush=True)

if which in ("nofreeze", "all"):
    for rn in ("flow", "actor"):
        for mr in ((4, 6) if rn == "flow" else (6,)):
            print(rn, "f=1 no freeze, %d rounds:" % mr,
                  sc(system(2, rn, "all", 1, scoped=True, freeze=False, max_rounds=mr), limit=4000000), flush=True)
        print(rn, "f=2 no freeze, 2 rounds:", sc(system(2, rn, "all", 2, scoped=True, freeze=False, max_rounds=2), limit=4000000), flush=True)
        print(rn, "f=3 no freeze, 1 round:", sc(system(2, rn, "all", 3, scoped=True, freeze=False, max_rounds=1), limit=4000000), flush=True)

if which in ("removed", "all"):
    print("=== 4.1 one connection removed, with scopes, f=1, freeze ===")
    t = tower(2)
    for rn in ("flow", "actor"):
        res = {}
        for a in t["arrows"]:
            kind = "upper cycle" if a in [("D1", "D2"), ("D2", "D3"), ("D3", "D1")] else (
                ("%s->%s" % (a[0][0], a[1][0])) if "T" in a else "base ring")
            r = Sys(system(2, rn, "all", 1, scoped=True, freeze=True, remove=[a])).solve_scoped()
            res.setdefault(kind, set()).add((r["G1"], r["G2"], r["told"], r["spill"]))
        print(rn, "(G1, G2, told, spill):", res)
        print(rn, "all three upper-cycle arrows removed:",
              sc(system(2, rn, "all", 1, scoped=True, freeze=True, remove=[("D1", "D2"), ("D2", "D3"), ("D3", "D1")])))

if which in ("least", "all"):
    print("=== 4.5 wirings of thirteen, as one system, reads all ===")
    t = tower(2)
    mem = [x for (m, c, k) in t["rings"] if k == "base" for x in list(m) + [c]]   # the twelve
    cyc = [(mem[i], mem[(i + 1) % 12]) for i in range(12)]
    flat26 = cyc + [(x, "T") for x in mem] + [("T", mem[0]), ("T", mem[1])]
    flat36 = cyc + [(x, "T") for x in mem] + [("T", x) for x in mem]
    # a second order of the twelve in the cycle: interleave the rings
    mem2 = [mem[(i % 3) * 4 + i // 3] for i in range(12)]
    cyc2 = [(mem2[i], mem2[(i + 1) % 12]) for i in range(12)]
    flat26b = cyc2 + [(x, "T") for x in mem2] + [("T", mem2[0]), ("T", mem2[5])]
    eight = []
    for (m, c, k) in t["rings"]:
        a, b, c3 = m
        eight += [(a, b), (b, c3), (c3, a), (c, a), (c, b), (a, c), (b, c), (c3, c)]   # drop coord -> third
    for f in (1, 2, 3, 4):
        for rn in ("flow", "actor"):
            print("f=%d %s: 33 (no upper cycle): %s | 26: %s | 26 (other order): %s | flat 36: %s | 32 (eight a ring): %s" % (
                f, rn, one(system(2, rn, "all", f, remove=[("D1", "D2"), ("D2", "D3"), ("D3", "D1")])),
                one(system(2, rn, "all", f, arrows=flat26)), one(system(2, rn, "all", f, arrows=flat26b)),
                one(system(2, rn, "all", f, arrows=flat36)), one(system(2, rn, "all", f, arrows=eight))))
    for rn in ("flow", "actor"):
        print(rn, "32 (eight a ring) with scopes f=1 freeze:", sc(system(2, rn, "all", 1, scoped=True, freeze=True, arrows=eight)))

if which in ("forty", "all"):
    print("=== 4.6 forty monitors ===")
    for rn in ("flow", "actor"):
        for f in (1, 2, 3):
            print(rn, "one system reads all f=%d:" % f, one(system(3, rn, "all", f)), flush=True)
        print(rn, "reads two f=1:", one(system(3, rn, "two", 1)), "f=2:", one(system(3, rn, "two", 2)), flush=True)
        print(rn, "ring boundaries f=1:", one(system(3, rn, "all", 1, ring_boundaries=True)), flush=True)

if which in ("forty-scoped", "all"):
    for rn in ("flow", "actor"):
        for mr in (1, 2, 3):
            print(rn, "forty, scopes, freeze, f=1, %d rounds:" % mr,
                  sc(system(3, rn, "all", 1, scoped=True, freeze=True, max_rounds=mr), limit=3000000), flush=True)
