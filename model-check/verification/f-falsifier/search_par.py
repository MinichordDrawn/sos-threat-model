"""Exhaustive falsifier search, every labelled plain system without self-loops, in parallel.

    python -I search_par.py 3 1 classes     (reproduces search_small.py 3 1)
    python -I search_par.py 3 2

Same verdicts as search_small.py (strict / partial / blamed, see there).  The work is split
by the `fwd` relation.  Extra tallies:
  * no-spare systems in which a monitor without a reader is in no halt_inputs list
  * gap-free / no-spare systems whose fwd is completely empty
  * number of reader-less monitors in no-spare systems
With the word `classes` every no-spare falsifier is reduced to a canonical form under
renaming, so classes can be counted (memory heavy; off for 3 monitors + 2 work processes,
where only the classes of the fewest-edge falsifiers and of the edge-minimal systems are kept).
Writes result_<n>x<k>_par.json.
"""
import json
import os
import sys
import time
from collections import Counter
from itertools import product
from multiprocessing import Pool

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plain

GF = {}
TERMFAIL = {}
AS = {}


def gf(s):
    r = GF.get(s)
    if r is None:
        r = GF[s] = plain.gap_free_bfs(*s)
    return r


def terminals(s):
    spare = [m for m in range(s[0]) if gf(plain.delete(s, m))]
    if not spare:
        return frozenset([s])
    return frozenset().union(*[terminals(plain.delete(s, m)) for m in spare])


def term_fail_flags(s):
    """For a gap-free system s: the set of failing-predicate tuples over its terminals."""
    r = TERMFAIL.get(s)
    if r is None:
        r = TERMFAIL[s] = frozenset(tuple(plain.failing(t)) for t in terminals(s))
    return r


def get_A(n, k, hbr, fwd, hi):
    key = (n, hbr, fwd, hi)
    if key not in AS:
        AS[key] = plain.allowed_sets(n, k, hbr, fwd, hi)
    return AS[key]


def worker(args):
    n, k, fwd, want_classes = args
    rows = plain.all_rows_no_self(n)
    his = list(product(range(1 << n), repeat=k))
    allm = (1 << n) - 1
    R = {
        "triples": 0, "gf": 0, "irred": 0,
        "fail_all": Counter(), "fail_irred": Counter(), "verdict": Counter(),
        "spare_hist": Counter(), "readerless_hist": Counter(), "per_pred": Counter(),
        "readerless_not_halt_input": 0, "gf_empty_fwd": 0, "irred_empty_fwd": 0,
        "q3_or_q8_fail": 0, "irred_fals": {}, "minimal": {}, "best": {}, "reducible_examples": {},
    }
    q4f = not plain.q4(n, k, None, None, fwd, None)
    empty_fwd = not any(fwd)
    for hi in his:
        hi_union = 0
        for h in hi:
            hi_union |= h
        for hbr in rows:
            A = get_A(n, k, hbr, fwd, hi)
            if A is None:
                continue
            R["triples"] += 1
            q1f = not plain.q1(n, k, hbr, None, None, None)
            q8f = not plain.q8(n, k, None, None, None, hi)
            readerless = [m for m in range(n) if not hbr[m] & ~(1 << m)]
            # deletion data: for every monitor m the allowed sets of the triple without m
            dels = []
            for m in range(n):
                hbr_m = tuple(plain._drop(hbr[i], m) for i in range(n) if i != m)
                fwd_m = tuple(plain._drop(fwd[i], m) for i in range(n) if i != m)
                hi_m = tuple(plain._drop(h, m) for h in hi)
                A_m = get_A(n - 1, k, hbr_m, fwd_m, hi_m) if n > 1 else None
                if A_m is None:
                    dels.append(None)
                    continue
                B = {}
                xs = [x for x in range(n + k) if x != m]
                for x2, x in enumerate(xs):
                    B[x] = frozenset(c for c in A[x] if plain._drop(c, m) in A_m[x2])
                dels.append(B)
            lists = [sorted(a) for a in A]
            for chk in product(*lists):
                R["gf"] += 1
                q3f = any(not (chk[x] & ~(1 << x)) for x in range(n)) or any(not chk[n + w] for w in range(k))
                if q3f or q8f:
                    R["q3_or_q8_fail"] += 1
                fl = tuple(nm for nm, f in (("Q1", q1f), ("Q3", q3f), ("Q4", q4f), ("Q8", q8f)) if f)
                R["fail_all"][fl] += 1
                spare = [m for m in range(n) if dels[m] is not None
                         and all(chk[x] in dels[m][x] for x in dels[m])]
                R["spare_hist"][len(spare)] += 1
                R["gf_empty_fwd"] += empty_fwd
                s = None
                if not spare:
                    R["irred"] += 1
                    R["fail_irred"][fl] += 1
                    R["irred_empty_fwd"] += empty_fwd
                    R["readerless_hist"][len(readerless)] += 1
                    if any(not hi_union >> m & 1 for m in readerless):
                        R["readerless_not_halt_input"] += 1
                if fl:
                    if not spare:
                        v = "strict"
                        s = (n, k, hbr, chk, fwd, hi)
                        e = plain.edges(s)
                        fam = "+".join(fl)
                        if want_classes:
                            R["irred_fals"][plain.canonical(s)] = (e, fam)
                        b = R["best"].setdefault(fam, [e, set()])
                        if e < b[0]:
                            b[0] = e
                            b[1] = set()
                        if e == b[0]:
                            b[1].add(plain.canonical(s))
                        for q in fl:
                            R["per_pred"][q + " fails, no spare monitor"] += 1
                    else:
                        tf = set()
                        for m in spare:
                            tf |= term_fail_flags(plain.delete((n, k, hbr, chk, fwd, hi), m))
                        anyf = set(bool(t) for t in tf)
                        v = "strict" if anyf == {True} else ("blamed" if anyf == {False} else "partial")
                        s = (n, k, hbr, chk, fwd, hi)
                        e = plain.edges(s)
                        if v not in R["reducible_examples"] or (e, s) < R["reducible_examples"][v]:
                            R["reducible_examples"][v] = (e, s)
                        for q in fl:
                            qs = set(q in t for t in tf)
                            R["per_pred"][q + (" fails, spare monitors, still fails after every deletion order"
                                               if qs == {True} else
                                               " fails, spare monitors, holds after every deletion order"
                                               if qs == {False} else
                                               " fails, spare monitors, depends on the deletion order")] += 1
                    R["verdict"][v] += 1
                else:
                    R["verdict"]["all predicates hold"] += 1
                # edge-minimal?  first the checkers (cheap), then every other edge
                if any((chk[x] ^ (1 << i)) in A[x] for x in range(n + k) for i in range(n) if chk[x] >> i & 1):
                    continue
                minimal = True
                for name, row in (("hbr", hbr), ("fwd", fwd), ("hi", hi)):
                    for i, val in enumerate(row):
                        for j in range(n):
                            if not val >> j & 1:
                                continue
                            r2 = row[:i] + (val ^ (1 << j),) + row[i + 1:]
                            A2 = get_A(n, k, r2 if name == "hbr" else hbr, r2 if name == "fwd" else fwd,
                                       r2 if name == "hi" else hi)
                            if A2 is not None and all(chk[x] in A2[x] for x in range(n + k)):
                                minimal = False
                                break
                        if not minimal:
                            break
                    if not minimal:
                        break
                if minimal:
                    s = (n, k, hbr, chk, fwd, hi)
                    c = plain.canonical(s)
                    R["minimal"][c] = {"edges": plain.edges(c), "failing": list(fl), "spare": len(spare)}
    return R


def main(n, k, want_classes):
    t0 = time.time()
    rows = plain.all_rows_no_self(n)
    with Pool(12) as pool:
        parts = pool.map(worker, [(n, k, fwd, want_classes) for fwd in rows], chunksize=1)
    tot = {key: 0 for key in ("triples", "gf", "irred", "readerless_not_halt_input", "gf_empty_fwd",
                              "irred_empty_fwd", "q3_or_q8_fail")}
    cnt = {key: Counter() for key in ("fail_all", "fail_irred", "verdict", "spare_hist", "readerless_hist",
                                      "per_pred")}
    irred_fals, minimal, best = {}, {}, {}
    red_ex = {}
    for p in parts:
        for v, es in p["reducible_examples"].items():
            if v not in red_ex or es < red_ex[v]:
                red_ex[v] = es
        for key in tot:
            tot[key] += p[key]
        for key in cnt:
            cnt[key].update(p[key])
        irred_fals.update(p["irred_fals"])
        minimal.update(p["minimal"])
        for fam, (e, cl) in p["best"].items():
            b = best.setdefault(fam, [e, set()])
            if e < b[0]:
                b[0], b[1] = e, set()
            if e == b[0]:
                b[1] |= cl

    def fmt(counter):
        return {"+".join(kk) if kk else "none": vv for kk, vv in sorted(counter.items())}

    families = {}
    for fam, (e, cl) in sorted(best.items()):
        families[fam] = {"min_edges": e, "classes_at_min_edges": len(cl),
                         "smallest": [plain.to_json(c, f"{n}x{k} fails {fam} #{i}")
                                      for i, c in enumerate(sorted(cl)[:12])]}
        if want_classes:
            fl = [v for v in irred_fals.values() if v[1] == fam]
            families[fam]["classes"] = len(fl)
            families[fam]["edge_histogram"] = dict(sorted(Counter(v[0] for v in fl).items()))
    res = {
        "n": n, "k": k,
        "labelled_systems_total_no_self_loops": 1 << (3 * n * (n - 1) + 2 * n * k),
        "feasible_triples(hb_readers,fwd,halt_inputs)": tot["triples"],
        "gap_free_labelled": tot["gf"],
        "gap_free_failing_Q3_or_Q8": tot["q3_or_q8_fail"],
        "gap_free_by_failing_predicates": fmt(cnt["fail_all"]),
        "gap_free_by_number_of_spare_monitors": dict(sorted(cnt["spare_hist"].items())),
        "gap_free_with_empty_fwd": tot["gf_empty_fwd"],
        "no_spare_labelled": tot["irred"],
        "no_spare_by_failing_predicates": fmt(cnt["fail_irred"]),
        "no_spare_with_empty_fwd": tot["irred_empty_fwd"],
        "no_spare_by_number_of_readerless_monitors": dict(sorted(cnt["readerless_hist"].items())),
        "no_spare_with_readerless_monitor_outside_all_halt_inputs": tot["readerless_not_halt_input"],
        "verdicts_labelled": dict(cnt["verdict"]),
        "per_predicate": dict(sorted(cnt["per_pred"].items())),
        "no_spare_falsifier_classes_up_to_renaming": len(irred_fals) if want_classes else "not counted",
        "families": families,
        "fewest_edge_examples_with_spare_monitors": {
            v: plain.to_json(s, f"{n}x{k} with spare monitors, verdict {v}, {e} edges")
            for v, (e, s) in sorted(red_ex.items())},
        "edge_minimal_gap_free_classes": len(minimal),
        "edge_minimal_by_failing": fmt(Counter(tuple(v["failing"]) for v in minimal.values())),
        "edge_minimal_with_spare": sum(1 for v in minimal.values() if v["spare"]),
        "edge_minimal_edge_histogram": dict(sorted(Counter(v["edges"] for v in minimal.values()).items())),
        "seconds": round(time.time() - t0, 1),
    }
    res["edge_minimal_systems"] = [dict(plain.to_json(c, f"{n}x{k} minimal"), _failing=v["failing"],
                                        _spare=v["spare"], _edges=v["edges"])
                                   for c, v in sorted(minimal.items(), key=lambda kv: (kv[1]["edges"], kv[0]))][:600]
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), f"result_{n}x{k}_par.json")
    json.dump(res, open(out, "w", encoding="utf-8"), indent=1)
    for key, val in res.items():
        if key not in ("families", "edge_minimal_systems", "fewest_edge_examples_with_spare_monitors"):
            print(f"{key}: {val}")
    for fam, info in families.items():
        print(f"family fails {fam}: min edges {info['min_edges']}, {info['classes_at_min_edges']} classes at that size"
              + (f", {info['classes']} classes in all" if want_classes else ""))


if __name__ == "__main__":
    main(int(sys.argv[1]), int(sys.argv[2]), "classes" in sys.argv[3:])
