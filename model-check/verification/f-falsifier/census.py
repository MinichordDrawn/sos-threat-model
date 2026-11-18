"""Complete census of plain systems with n monitors and ONE work process, without visiting the
systems one by one.

    python -I census.py 3      (must reproduce search_par.py 3 1 exactly)
    python -I census.py 4      (2^44 labelled systems; about 2.5 minutes on 12 processes)
    python -I census.py 4 two_silent   (only hb_readers with two or more reader-less monitors;
                                        finds the fewest-edge systems of that kind)

How the 2^44 systems are covered
--------------------------------
* A system is (hb_readers, fwd, halt_inputs) + checkers.  For a fixed triple the gap-free
  systems are exactly the products A[a] x A[b] x ... x A[w] of per-process sets of checker
  lists (plain.allowed_sets explains why; honest_3x1.py confirmed it against plain
  reachability on all 2^24 three-monitor systems).  So the census enumerates every triple
  (2^28 for n = 4) and counts products instead of systems.
* The one symmetry reduction: monitors are renamed so that the halt inputs come first.
  halt_inputs is then one of {}, {a}, {a,b}, {a,b,c}, {a,b,c,d}, and each count is multiplied
  by the number of halt-input sets of that size (1, 4, 6, 4, 1).  hb_readers and fwd are NOT
  reduced: all 4096 x 4096 pairs are visited for each shape.
* Spare monitors: m is spare in S iff S - m is gap-free iff the triple without m is feasible
  and every remaining checker list, with m struck out, lies in that smaller triple's set.
  The smaller sets come from plain.allowed_sets (the independent implementation).  The number
  of systems with no spare monitor is then an inclusion-exclusion over sets U of monitors:
      sum over U of (-1)^|U| * #{systems of the triple in which every m in U is spare}
  and each term is again a product over processes.
* Smallest falsifiers: for every feasible triple failing Q1 or Q4, the inclusion-minimal
  checker lists are tried and the no-spare systems with the fewest edges are kept (deleting a
  checker never creates a spare monitor, so the fewest-edge ones are found this way).

This file re-implements the round for speed (closure tables); the validation run
(validate_census.py) compares it with plain.py and model.py on random triples and systems.
"""
import json
import os
import sys
import time
from collections import Counter
from itertools import product
from math import comb
from multiprocessing import Pool

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plain

FAM = ["none", "Q1", "Q4", "Q1+Q4"]
G = {}


def closure_table(n, fwd):
    size = 1 << n
    cl = [None] * size
    for A in range(size):
        row = [0] * size
        for seed in range(size):
            if seed & ~A:
                continue
            f = seed
            while True:
                new = f
                x = f
                p = 0
                while x:
                    if x & 1:
                        new |= fwd[p] & A
                    x >>= 1
                    p += 1
                if new == f:
                    break
                f = new
            row[seed] = f
        cl[A] = row
    return cl


def allow_at(n, cl, hi, cands, state):
    """Bitmaps (bit c set <=> checker list c of process x survives `mutate x` in this state)."""
    A, F, H = state
    res = []
    for x in range(n):
        act = A & ~(1 << x)
        row = cl[act]
        bm = 0
        for c in cands[x]:
            out = row[(F | c) & act]
            if out and (H or hi & out):
                bm |= 1 << c
        res.append(bm)
    row = cl[A]
    bm = 0
    for c in range(1 << n):
        out = row[(F | c) & A]
        if out and (H or hi & out):
            bm |= 1 << c
    res.append(bm)
    return res


def triple_bitmaps(n, cl, hi, cands, hbr, allow, init, init_allow):
    """Allowed-checker bitmaps of the triple, or None if some process has none."""
    acc = list(init_allow)
    seen = {init}
    stack = [init]
    np1 = n + 1
    while stack:
        A, F, H = stack.pop()
        x = A
        s = 0
        while x:
            if x & 1:
                A2 = A & ~(1 << s)
                F2 = cl[A2][(F | hbr[s]) & A2]
                H2 = 1 if (H or hi >> s & 1 or hi & F2) else 0
                if not (F2 and H2):                       # not responded
                    st = (A2, F2, H2)
                    if st not in seen:
                        seen.add(st)
                        al = allow.get(st)
                        if al is None:
                            al = allow[st] = allow_at(n, cl, hi, cands, st)
                        for i in range(np1):
                            acc[i] &= al[i]
                            if not acc[i]:
                                return None
                        stack.append(st)
            x >>= 1
            s += 1
    return acc


def init_worker(n, two_silent=False):
    """Tables shared by all tasks of a worker process."""
    rows = plain.all_rows_no_self(n)
    G["n"] = n
    G["two_silent"] = two_silent
    G["rows"] = rows
    G["cands"] = [plain.others_masks(n, x) for x in range(n)]
    # triples of the (n-1)-monitor systems, by the independent implementation
    small = {}
    if n > 1:
        rows_s = plain.all_rows_no_self(n - 1)
        for hbr in rows_s:
            for fwd in rows_s:
                for hi in range(1 << (n - 1)):
                    A = plain.allowed_sets(n - 1, 1, hbr, fwd, (hi,))
                    if A is not None:
                        small[(hbr, fwd, hi)] = [sum(1 << c for c in a) for a in A]
    G["small"] = small
    # pull[m][bitmap over (n-1)-monitor lists] -> bitmap over n-monitor lists c with drop(c, m) inside
    pull = []
    for m in range(n):
        dropped = [plain._drop(c, m) for c in range(1 << n)]
        memo = {}
        pull.append((dropped, memo))
    G["pull"] = pull
    G["mins"] = {}


def pull_back(m, bm_small):
    dropped, memo = G["pull"][m]
    r = memo.get(bm_small)
    if r is None:
        r = 0
        for c, d in enumerate(dropped):
            if bm_small >> d & 1:
                r |= 1 << c
        memo[bm_small] = r
    return r


def minimal_elements(bm):
    r = G["mins"].get(bm)
    if r is None:
        elems = [c for c in range(bm.bit_length()) if bm >> c & 1]
        r = [c for c in elems if not any(d != c and d & c == d for d in elems)]
        G["mins"][bm] = r
    return r


def pulled_tables(n, hbr_del, fwd_del, hi_del):
    """For every monitor m: None if the triple without m is infeasible, else for every other
    process x the bitmap of checker lists c of x (in the big system) whose restriction to the
    system without m is allowed there."""
    small = G["small"]
    pulled = []
    for m in range(n):
        sub = small.get((hbr_del[m], fwd_del[m], hi_del[m]))
        if sub is None:
            pulled.append(None)
        else:
            pm = [0] * (n + 1)
            xs = [x for x in range(n + 1) if x != m]
            for x2, x in enumerate(xs):
                pm[x] = pull_back(m, sub[x2])
            pulled.append(pm)
    return pulled


def count_nospare(n, acc, pulled):
    """Number of systems of the triple (checker lists inside acc) with no spare monitor."""
    nns = 0
    for U in range(1 << n):
        masks = list(acc)
        ok = True
        for m in range(n):
            if U >> m & 1:
                pm = pulled[m]
                if pm is None:
                    ok = False
                    break
                for x in range(n + 1):
                    if x != m:
                        masks[x] &= pm[x]
        if not ok:
            continue
        term = 1
        for b in masks:
            term *= b.bit_count()
        nns += -term if U.bit_count() & 1 else term
    return nns


def is_spare(n, pulled, chk, m):
    pm = pulled[m]
    return pm is not None and all(pm[x] >> chk[x] & 1 for x in range(n + 1) if x != m)


def task(args):
    hi, fwd_lo, fwd_hi = args
    n = G["n"]
    two_silent = G["two_silent"]
    rows = G["rows"]
    cands = G["cands"]
    small = G["small"]
    allm = (1 << n) - 1
    init = (allm, 0, 0)
    e_hi = hi.bit_count()
    R = {
        "hi": hi, "pairs": 0, "feasible": 0, "gf": [0] * 4, "nospare": [0] * 4,
        "q3_violations": 0, "gf_empty_fwd": 0, "nospare_empty_fwd": 0,
        "readerless_hist": Counter(), "readerless_not_hi": 0, "allspare_none": 0,
        "best": {},
    }
    hbr_del = [[tuple(plain._drop(hbr[i], m) for i in range(n) if i != m) for m in range(n)] for hbr in rows]
    hbr_edges = [sum(v.bit_count() for v in hbr) for hbr in rows]
    hbr_readerless = [[m for m in range(n) if not hbr[m]] for hbr in rows]
    hi_del = [plain._drop(hi, m) for m in range(n)]
    for fi in range(fwd_lo, fwd_hi):
        fwd = rows[fi]
        cl = closure_table(n, fwd)
        allow = {}
        init_allow = allow_at(n, cl, hi, cands, init)
        R["pairs"] += len(rows)
        if not all(init_allow):
            continue
        q4f = not plain.q4(n, 1, None, None, fwd, None)
        e_fwd = sum(v.bit_count() for v in fwd)
        fwd_del = [tuple(plain._drop(fwd[i], m) for i in range(n) if i != m) for m in range(n)]
        for hbi, hbr in enumerate(rows):
            if two_silent and len(hbr_readerless[hbi]) < 2:
                continue
            acc = triple_bitmaps(n, cl, hi, cands, hbr, allow, init, init_allow)
            if acc is None:
                continue
            R["feasible"] += 1
            readerless = hbr_readerless[hbi]
            fam = (1 if readerless else 0) + (2 if q4f else 0)
            ngf = 1
            for b in acc:
                ngf *= b.bit_count()
            if any(b & 1 for b in acc):
                R["q3_violations"] += 1          # an empty checker list would be allowed
            # the triples without each monitor
            pulled = pulled_tables(n, hbr_del[hbi], fwd_del, hi_del)
            if all(p is None for p in pulled):
                nns = ngf
                R["allspare_none"] += 1
            else:
                nns = count_nospare(n, acc, pulled)
            R["gf"][fam] += ngf
            R["nospare"][fam] += nns
            if not e_fwd:
                R["gf_empty_fwd"] += ngf
                R["nospare_empty_fwd"] += nns
            R["readerless_hist"][len(readerless)] += nns
            if any(not hi >> m & 1 for m in readerless):
                R["readerless_not_hi"] += nns
            # fewest-edge no-spare falsifiers of this triple
            if fam and nns:
                e_tr = hbr_edges[hbi] + e_fwd + e_hi
                mins = [minimal_elements(b) for b in acc]
                lb = e_tr + sum(min(c.bit_count() for c in ml) for ml in mins)
                best = R["best"].setdefault(fam, [99, set()])
                if lb <= best[0]:
                    for chk in product(*mins):
                        e = e_tr + sum(c.bit_count() for c in chk)
                        if e > best[0]:
                            continue
                        if not any(is_spare(n, pulled, chk, m) for m in range(n)):
                            if e < best[0]:
                                best[0] = e
                                best[1] = set()
                            best[1].add(plain.canonical((n, 1, hbr, chk, fwd, (hi,))))
    return R


def main(n, two_silent=False):
    t0 = time.time()
    rows = plain.all_rows_no_self(n)
    shapes = [(1 << j) - 1 for j in range(n + 1)]
    chunk = max(1, len(rows) // 64)
    tasks = [(hi, lo, min(lo + chunk, len(rows))) for hi in shapes for lo in range(0, len(rows), chunk)]
    with Pool(12, initializer=init_worker, initargs=(n, two_silent)) as pool:
        parts = pool.map(task, tasks, chunksize=1)
    tot = Counter()
    gfc = [0] * 4
    nsc = [0] * 4
    rl = Counter()
    best = {}
    per_shape = {}
    for p in parts:
        w = comb(n, p["hi"].bit_count())
        ps = per_shape.setdefault(p["hi"].bit_count(), Counter())
        ps["feasible_triples"] += p["feasible"]
        ps["gap_free"] += sum(p["gf"])
        ps["no_spare"] += sum(p["nospare"])
        tot["pairs"] += p["pairs"]
        tot["triples_labelled"] += w * p["pairs"]
        tot["feasible_triples_labelled"] += w * p["feasible"]
        tot["q3_violations"] += p["q3_violations"]
        tot["q8_violations"] += p["feasible"] if p["hi"].bit_count() < 2 else 0
        tot["gf_empty_fwd"] += w * p["gf_empty_fwd"]
        tot["nospare_empty_fwd"] += w * p["nospare_empty_fwd"]
        tot["readerless_not_hi"] += w * p["readerless_not_hi"]
        for i in range(4):
            gfc[i] += w * p["gf"][i]
            nsc[i] += w * p["nospare"][i]
        for key, val in p["readerless_hist"].items():
            rl[key] += w * val
        for fam, (e, cl) in p["best"].items():
            b = best.setdefault(fam, [e, set()])
            if e < b[0]:
                b[0], b[1] = e, set()
            if e == b[0]:
                b[1] |= cl
    families = {}
    for fam, (e, cl) in sorted(best.items()):
        families[FAM[fam]] = {"min_edges": e, "classes_at_min_edges": len(cl),
                              "smallest": [plain.to_json(c, f"{n}x1 fails {FAM[fam]} #{i}")
                                           for i, c in enumerate(sorted(cl)[:40])]}
    res = {
        "n": n, "k": 1,
        "labelled_systems_total_no_self_loops": 1 << (3 * n * (n - 1) + 2 * n),
        "(hb_readers,fwd) pairs visited over the halt-input shapes": tot["pairs"],
        "labelled_triples_covered": tot["triples_labelled"],
        "feasible_triples_labelled": tot["feasible_triples_labelled"],
        "per_halt_input_size(unweighted)": {str(k): dict(v) for k, v in sorted(per_shape.items())},
        "gap_free_labelled": sum(gfc),
        "gap_free_by_failing_predicates": dict(zip(FAM, gfc)),
        "triples_where_an_empty_checker_list_is_allowed(Q3)": tot["q3_violations"],
        "feasible_triples_with_fewer_than_two_halt_inputs(Q8)": tot["q8_violations"],
        "gap_free_with_empty_fwd": tot["gf_empty_fwd"],
        "no_spare_labelled": sum(nsc),
        "no_spare_by_failing_predicates": dict(zip(FAM, nsc)),
        "no_spare_with_empty_fwd": tot["nospare_empty_fwd"],
        "no_spare_by_number_of_readerless_monitors": dict(sorted(rl.items())),
        "no_spare_with_readerless_monitor_outside_halt_inputs": tot["readerless_not_hi"],
        "families": families,
        "seconds": round(time.time() - t0, 1),
    }
    if two_silent:
        res["restricted_to"] = "hb_readers relations in which at least two monitors have no reader"
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                       f"census_{n}x1{'_two_silent' if two_silent else ''}.json")
    json.dump(res, open(out, "w", encoding="utf-8"), indent=1)
    for key, val in res.items():
        if key != "families":
            print(f"{key}: {val}")
    for fam, info in families.items():
        print(f"no-spare falsifiers failing {fam}: min edges {info['min_edges']}, "
              f"{info['classes_at_min_edges']} classes at that size")


if __name__ == "__main__":
    main(int(sys.argv[1]), "two_silent" in sys.argv[2:])
