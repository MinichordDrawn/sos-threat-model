"""Part D: getting there by joins."""
import sys, os, time, itertools
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys
from ring import *
from tower import system, tower
from grow import *

which = sys.argv[1] if len(sys.argv) > 1 else "all"

if which in ("one", "all"):
    print("=== 5.1 as one system: least rounds (G1, G2); reads all, a monitor may arrive bad ===")
    for order in ORDERS:
        for rn in ("flow", "actor"):
            cells = []
            for f in (1, 2, 3):
                r = Sys(grow_system(order, rn, f)).solve_plain(stop_early=True, state_limit=400000)
                cells.append("f=%d G1 %s G2 %s%s" % (f, r["G1"], r["G2"], "" if r["complete"] else " (cut off at %d states)" % r["states"]))
            print("%-17s %-5s %s" % (order, rn, " | ".join(cells)), flush=True)

if which in ("scoped", "all"):
    print("=== 5.1 with scopes, freeze, f=1, every reachable state: least rounds over all scopes ===")
    for order in ORDERS:
        for rn in ("flow", "actor"):
            t0 = time.time()
            r = Sys(grow_system(order, rn, 1, scoped=True)).solve_scoped(state_limit=3000000)
            print("%-17s %-5s G1 %s G2 %s told %s spill %s | per scope %s | states %d complete %s rounds %d [%.0fs]" % (
                order, rn, r["G1"], r["G2"], r["told"], r["spill"],
                {k: (v["G1"], v["G2"], v["told"]) for k, v in r["scopes"].items()},
                r["states"], r["complete"], r["rounds_explored"], time.time() - t0), flush=True)

if which in ("scoped2", "all"):
    print("=== 5.2 with scopes, freeze, f=2, at most 3 rounds ===")
    for order in ORDERS:
        for rn in ("flow", "actor"):
            t0 = time.time()
            r = Sys(grow_system(order, rn, 2, scoped=True, max_rounds=3)).solve_scoped(state_limit=2500000)
            print("%-17s %-5s G1 %s G2 %s told %s spill %s | per scope %s | states %d complete %s rounds %d [%.0fs]" % (
                order, rn, r["G1"], r["G2"], r["told"], r["spill"],
                {k: (v["G1"], v["G2"], v["told"]) for k, v in r["scopes"].items()},
                r["states"], r["complete"], r["rounds_explored"], time.time() - t0), flush=True)

if which in ("steps", "all"):
    print("=== 5.2 the conditions of Theorem J and Theorem S on every set of present processes ===")
    t = tower(2)
    for order in ORDERS:
        sets = present_sets(order)
        for rn in ("flow", "actor"):
            hb, chk, fwd = edges_of(t["arrows"], READINGS[rn])
            nJ = nS = 0
            nochk = set()
            Jsets = []
            for late in sets:
                P = {"A1", "B1", "C1", "D1", "W1"} | set(late)
                mons = [m for m in P if not m.startswith("W")]
                works = [w for w in P if w.startswith("W")]
                hbp = {(a, b) for (a, b) in hb if a in P and b in P}
                chp = {(a, b) for (a, b) in chk if a in P and b in P}
                fwp = {(a, b) for (a, b) in fwd if a in P and b in P}
                W = watchers(mons, hbp, chp)
                # Theorem J: connected by mutual pairs; works have a checker and > f halt inputs (4 > 3)
                adj = {m: {r for r in mons if r != m and r in W[m] and m in W[r] and (m, r) in fwp and (r, m) in fwp}
                       for m in mons}
                seen = {mons[0]}
                todo = [mons[0]]
                while todo:
                    x = todo.pop()
                    for y in adj[x]:
                        if y not in seen:
                            seen.add(y)
                            todo.append(y)
                wk_ok = all(all(x in P for x in t["works"][w]) for w in works)   # reads all: four present halt inputs
                J = len(seen) == len(mons) and wk_ok
                nJ += J
                if J:
                    Jsets.append(len(P))
                # Theorem S (a)-(d) on present processes
                def reach(src, avoid=None):
                    s_ = {src}
                    td = [src]
                    while td:
                        x = td.pop()
                        for (a, b) in fwp:
                            if a == x and b not in s_ and b != avoid:
                                s_.add(b)
                                td.append(b)
                    return s_
                a_ = all(W[m] for m in mons)
                b_ = all(sum(1 for x in t["works"][w] if x in P) >= 2 and any(x in P for x in t["works"][w]) for w in works)
                c_ = True
                for z in mons:
                    got = set()
                    for r in W[z]:
                        got |= reach(r, avoid=z)
                    if any(y not in got for y in mons if y != z):
                        c_ = False
                d_ = all(any(len(reach(k)) == len(mons) for k in t["works"][w] if k in P) for w in works)
                S = a_ and b_ and c_ and d_
                nS += S
                for m in mons:
                    if not any((m, r) in chp for r in mons if r != m):
                        nochk.add((m, tuple(sorted(late))))
            who = {}
            for m, late in nochk:
                who.setdefault(m, []).append(late)
            print("%-17s %-5s sets %3d | Theorem J's condition holds in %3d (sizes %s) | Theorem S's in %3d | "
                  "monitors with no state checker in some set: %s" % (
                      order, rn, len(sets), nJ, sorted(Jsets) if nJ <= 3 else "...", nS,
                      {m: len(v) for m, v in sorted(who.items())} or "none"))

if which in ("fifth", "all"):
    print("=== 5.3 the least attachment of a fifth node ===")
    NODES = ["A", "B", "C", "D"]
    CAND = [("A", "B"), ("B", "C"), ("C", "A"), ("D", "A"), ("D", "B"), ("D", "C"), ("A", "D"), ("B", "D"), ("C", "D")]
    NA = [("N", x) for x in NODES] + [(x, "N") for x in NODES]
    five = NODES + ["N"]
    for rn in ("flow", "actor"):
        for work, fs in (("all", (1, 2, 3)), ("two", (1,))):
            for f in fs:
                r1 = {}
                whole = {}
                for mask in range(256):
                    att = [NA[i] for i in range(8) if mask >> i & 1]
                    hb, chk, fwd = edges_of(CAND + att, READINGS[rn])
                    d = make_system(five, hb, chk, fwd, work, f, "D", "A")
                    if work == "all":
                        d["checkers"]["W"] = list(NODES)
                        d["halt_inputs"]["W"] = list(NODES)
                    d["late"] = [{"name": "N", "members": ["N"]}]
                    d["arrive_bad"] = True
                    s = Sys(d)
                    r = s.solve_plain(want_told_mask=1 << s.idx["D"])
                    k = bin(mask).count("1")
                    if r["G1"] is None and r["G2"] is None:
                        r1.setdefault(k, []).append(att)
                    W = watchers(five, hb, chk)
                    st = len(W["N"]) >= 2 and R3(five, hb, chk, "D") and ("N", "D") in fwd
                    if st and r["G1"] is None and r["G2"] is None and r["told"] is None:
                        whole.setdefault(k, []).append(att)
                k1 = min(r1)
                kw = min(whole)
                print("%s W reads %s f=%d: R1 alone: %d connection(s): %s | whole list: %d: %s" % (
                    rn, work, f, k1, [" ".join("%s->%s" % a for a in x) for x in r1[k1]],
                    kw, [" ".join("%s->%s" % a for a in x) for x in whole[kw]]))
