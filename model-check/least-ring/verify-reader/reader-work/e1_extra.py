"""Extra checks: forty monitors with scopes at f=2 and 3 for one round; the fifth node kind by kind."""
import sys, os, time, itertools
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys
from ring import *
from tower import system

which = sys.argv[1] if len(sys.argv) > 1 else "all"

if which in ("fifthkinds", "all"):
    NODES = ["A", "B", "C", "D"]
    CAND = [("A", "B"), ("B", "C"), ("C", "A"), ("D", "A"), ("D", "B"), ("D", "C"), ("A", "D"), ("B", "D"), ("C", "D")]
    five = NODES + ["N"]
    for rn in ("flow", "actor"):
        hb0, chk0, fwd0 = edges_of(CAND, READINGS[rn])
        E = []
        for x in NODES:
            E += [("hb", "N", x), ("chk", "N", x), ("fwd", "N", x), ("hb", x, "N"), ("chk", x, "N"), ("fwd", x, "N")]

        def run(sel, work, f):
            hb, chk, fwd = set(hb0), set(chk0), set(fwd0)
            for (k, a, b) in sel:
                {"hb": hb, "chk": chk, "fwd": fwd}[k].add((a, b))
            d = make_system(five, hb, chk, fwd, work, f, "D", "A")
            if work == "all":
                d["checkers"]["W"] = list(NODES); d["halt_inputs"]["W"] = list(NODES)
            d["late"] = [{"name": "N", "members": ["N"]}]
            d["arrive_bad"] = True
            s = Sys(d)
            r = s.solve_plain(want_told_mask=1 << s.idx["D"])
            W = watchers(five, hb, chk)
            st = len(W["N"]) >= 2 and R3(five, hb, chk, "D") and ("N", "D") in fwd
            return r["G1"] is None and r["G2"] is None, st and r["G1"] is None and r["G2"] is None and r["told"] is None
        for work, fs in (("all", (1, 2, 3)), ("two", (1,))):
            for f in fs:
                one = [e for e in E if run([e], work, f)[0]]
                none0 = run([], work, f)[0]
                five_sets = []
                for size in range(0, 6):
                    for sel in itertools.combinations(E, size):
                        if run(sel, work, f)[1]:
                            five_sets.append(sel)
                    if five_sets:
                        break
                print("%s W reads %s f=%d: no edge: no gap %s; single edges that leave no gap: %s; whole list: fewest %d edges, %d sets, all of the form "
                      "'two watch N and N reports to D': %s" % (
                          rn, work, f, none0, ["%s %s<%s" % e for e in one], len(five_sets[0]), len(five_sets),
                          all(sum(1 for e in s_ if e[0] == "fwd") == 1 and ("fwd", "N", "D") in s_ for s_ in five_sets)), flush=True)

if which in ("forty23", "all"):
    def sc(d):
        t0 = time.time()
        r = Sys(d).solve_scoped()
        base = [k for k in r["scopes"] if k.startswith("sD")]
        up = [k for k in r["scopes"] if not k.startswith("sD")]

        def least(keys, j):
            vs = [r["scopes"][k][j] for k in keys if r["scopes"][k][j] is not None]
            return min(vs) if vs else None
        return "G1 base %s | G2 base %s | G1 upper %s | G2 upper %s | told %s | spill %s  [%.0fs]" % (
            least(base, "G1"), least(base, "G2"), least(up, "G1"), least(up, "G2"), r["told"], r["spill"], time.time() - t0)
    for rn in ("flow", "actor"):
        for f in (2, 3):
            print("forty, scopes, %s, freeze, f=%d, 1 round:" % (rn, f),
                  sc(system(3, rn, "all", f, scoped=True, freeze=True, max_rounds=1)), flush=True)
        print("forty, scopes, %s, freeze, reads two, f=1, 2 rounds:" % rn,
              sc(system(3, rn, "two", 1, scoped=True, freeze=True, max_rounds=2)), flush=True)
