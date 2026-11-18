"""Exhaustive falsifier search over plain systems with n monitors and k work processes,
every labelled system without self-loops visited one by one.

    python -I search_small.py 2 1
    python -I search_small.py 2 2
    python -I search_small.py 3 1

Self-loops (m in hb_readers[m] / checkers[m] / fwd[m]) are left out: they never change an
execution (a stopped or bad monitor is not active) nor a predicate (Q1, Q3 say "other than",
Q4 is about two different monitors).  crosscheck.py confirms this on all 2^16 systems with
two monitors and one work process.

For every gap-free system S:
  failing predicates, spare monitors, the terminal systems (what is left after deleting
  spare monitors one at a time for as long as any is spare, over every order), and the
  falsifier verdict:
     strict   S fails a predicate and EVERY terminal system fails a predicate
     partial  S fails a predicate and SOME but not all terminal systems fail one
     blamed   S fails a predicate and no terminal system does
Writes result_<n>x<k>.json.
"""
import json
import os
import sys
import time
from collections import Counter
from itertools import product

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plain

GF = {}


def gf(s):
    """Gap-freedom of any plain system, by plain reachability, memoised."""
    r = GF.get(s)
    if r is None:
        r = GF[s] = plain.gap_free_bfs(*s)
    return r


TERM = {}


def terminals(s):
    r = TERM.get(s)
    if r is None:
        spare = [m for m in range(s[0]) if gf(plain.delete(s, m))]
        if not spare:
            r = frozenset([s])
        else:
            r = frozenset().union(*[terminals(plain.delete(s, m)) for m in spare])
        TERM[s] = r
    return r


def main(n, k):
    t0 = time.time()
    rows = plain.all_rows_no_self(n)
    his = list(product(range(1 << n), repeat=k))
    triples = {}
    for hbr in rows:
        for fwd in rows:
            for hi in his:
                A = plain.allowed_sets(n, k, hbr, fwd, hi)
                if A is not None:
                    triples[(hbr, fwd, hi)] = A
    total = len(rows) ** 3 * (1 << (n * k)) * len(his)

    def is_gf(hbr, chk, fwd, hi):
        A = triples.get((hbr, fwd, hi))
        return A is not None and all(chk[x] in A[x] for x in range(n + k))

    def edge_minimal(hbr, chk, fwd, hi):
        for name, row in (("hbr", hbr), ("chk", chk), ("fwd", fwd), ("hi", hi)):
            for i, v in enumerate(row):
                b = 1
                while b <= v:
                    if v & b:
                        r2 = row[:i] + (v ^ b,) + row[i + 1:]
                        if is_gf(r2 if name == "hbr" else hbr, r2 if name == "chk" else chk,
                                 r2 if name == "fwd" else fwd, r2 if name == "hi" else hi):
                            return False
                    b <<= 1
        return True

    n_gf = 0
    fail_all = Counter()          # failing-set -> labelled count over all gap-free systems
    fail_irred = Counter()        # same over systems with no spare monitor
    n_irred = 0
    verdict = Counter()
    spare_hist = Counter()
    irred_fals = {}               # canonical -> (edges, failing)
    minimal = {}                  # canonical -> info
    strict_reducible = {}         # canonical -> info, reducible strict falsifiers
    upset_violations = 0
    for (hbr, fwd, hi), A in triples.items():
        lists = [sorted(a) for a in A]
        # each A[x] must be closed under adding checkers (monotonicity, checked not assumed)
        for x, a in enumerate(A):
            for c in a:
                for i in range(n):
                    if i != x and (c | 1 << i) not in a:
                        upset_violations += 1
        for chk in product(*lists):
            s = (n, k, hbr, chk, fwd, hi)
            n_gf += 1
            fl = tuple(plain.failing(s))
            fail_all[fl] += 1
            spare = [m for m in range(n) if gf(plain.delete(s, m))]
            spare_hist[len(spare)] += 1
            if not spare:
                n_irred += 1
                fail_irred[fl] += 1
            if fl:
                terms = terminals(s)
                tf = [bool(plain.failing(t)) for t in terms]
                v = "strict" if all(tf) else ("partial" if any(tf) else "blamed")
                verdict[v] += 1
                if not spare:
                    c = plain.canonical(s)
                    irred_fals[c] = (plain.edges(c), fl)
                elif v == "strict":
                    c = plain.canonical(s)
                    strict_reducible[c] = (plain.edges(c), fl)
            else:
                verdict["all predicates hold"] += 1
            if edge_minimal(hbr, chk, fwd, hi):
                c = plain.canonical(s)
                minimal[c] = {"edges": plain.edges(c), "failing": list(fl), "spare": len(spare)}

    # monotonicity across hbr / fwd / hi edges: adding an edge never loses gap-freedom
    mono_violations = 0
    for (hbr, fwd, hi), A in triples.items():
        for name, row in (("hbr", hbr), ("fwd", fwd), ("hi", hi)):
            for i, v in enumerate(row):
                for j in range(n):
                    if v >> j & 1 or (name != "hi" and j == i):
                        continue
                    r2 = row[:i] + (v | 1 << j,) + row[i + 1:]
                    key = (r2 if name == "hbr" else hbr, r2 if name == "fwd" else fwd,
                           r2 if name == "hi" else hi)
                    A2 = triples.get(key)
                    if A2 is None or any(not A[x] <= A2[x] for x in range(n + k)):
                        mono_violations += 1

    def fmt(counter):
        return {"+".join(kk) if kk else "none": vv for kk, vv in sorted(counter.items())}

    fals_sorted = sorted(irred_fals.items(), key=lambda kv: (kv[1][0], kv[1][1], kv[0]))
    by_family = {}
    for c, (e, fl) in fals_sorted:
        by_family.setdefault("+".join(fl), []).append(c)
    smallest = {}
    for fam, lst in by_family.items():
        emin = plain.edges(lst[0])
        smallest[fam] = {
            "classes": len(lst),
            "edge_histogram": dict(sorted(Counter(plain.edges(c) for c in lst).items())),
            "min_edges": emin,
            "smallest": [plain.to_json(c, f"{n}x{k} {fam} #{i}")
                         for i, c in enumerate([c for c in lst if plain.edges(c) == emin][:12])],
        }
    res = {
        "n": n, "k": k,
        "labelled_systems_total_no_self_loops": total,
        "feasible_triples(hb_readers,fwd,halt_inputs)": len(triples),
        "gap_free_labelled": n_gf,
        "gap_free_by_failing_predicates": fmt(fail_all),
        "gap_free_by_number_of_spare_monitors": dict(sorted(spare_hist.items())),
        "no_spare_labelled": n_irred,
        "no_spare_by_failing_predicates": fmt(fail_irred),
        "verdicts_labelled": dict(verdict),
        "no_spare_falsifier_classes_up_to_renaming": len(irred_fals),
        "strict_falsifier_classes_with_spare_monitors": len(strict_reducible),
        "families": smallest,
        "edge_minimal_gap_free_classes": len(minimal),
        "edge_minimal_by_failing": fmt(Counter(tuple(v["failing"]) for v in minimal.values())),
        "edge_minimal_with_spare": sum(1 for v in minimal.values() if v["spare"]),
        "edge_minimal_edge_histogram": dict(sorted(Counter(v["edges"] for v in minimal.values()).items())),
        "upset_violations_in_checkers": upset_violations,
        "monotonicity_violations_in_hb_fwd_halt": mono_violations,
        "seconds": round(time.time() - t0, 1),
    }
    res["edge_minimal_systems"] = [dict(plain.to_json(c, f"{n}x{k} minimal"), _failing=v["failing"],
                                        _spare=v["spare"], _edges=v["edges"])
                                   for c, v in sorted(minimal.items(), key=lambda kv: (kv[1]["edges"], kv[0]))][:400]
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), f"result_{n}x{k}.json")
    json.dump(res, open(out, "w", encoding="utf-8"), indent=1)
    for key, val in res.items():
        if key not in ("families", "edge_minimal_systems"):
            print(f"{key}: {val}")
    for fam, info in smallest.items():
        print(f"family fails {fam}: {info['classes']} classes, min edges {info['min_edges']}, "
              f"edge histogram {info['edge_histogram']}")
    return res


if __name__ == "__main__":
    main(int(sys.argv[1]), int(sys.argv[2]))
