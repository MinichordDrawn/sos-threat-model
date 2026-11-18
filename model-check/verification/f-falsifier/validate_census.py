"""Validation of census.py at 4 monitors against the other implementations, on random samples.

1. Random triples (hb_readers, fwd, halt_inputs), halt_inputs ANY of the 16 sets:
   census bitmaps == plain.allowed_sets.
2. Random complete systems: census membership == model.py (reference) verdict.
3. Random gap-free systems: for each monitor m, census "m is spare" == reference verdict on
   the JSON system with m deleted exactly as task.md says.
4. Random feasible triples with a small product: the inclusion-exclusion count of systems
   with no spare monitor == a one-by-one count using plain reachability on every S - m.

Run:  python -I validate_census.py
"""
import os
import random
import sys
import time
from itertools import product

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import census
import model
import plain

N = 4


def json_delete(d, m):
    """S - m, on the JSON form, word for word from task.md."""
    out = dict(d)
    out["monitors"] = [x for x in d["monitors"] if x != m]
    out["boundary"] = {k: v for k, v in d["boundary"].items() if k != m}
    for key in ("hb_readers", "checkers", "fwd", "halt_inputs"):
        out[key] = {k: [x for x in v if x != m] for k, v in d[key].items() if k != m}
    return out


def bitmaps(hi, fwd, hbr):
    cands = census.G["cands"]
    cl = census.closure_table(N, fwd)
    init = ((1 << N) - 1, 0, 0)
    init_allow = census.allow_at(N, cl, hi, cands, init)
    if not all(init_allow):
        return None
    return census.triple_bitmaps(N, cl, hi, cands, hbr, {}, init, init_allow)


def pulled_of(hi, fwd, hbr):
    hbr_del = [tuple(plain._drop(hbr[i], m) for i in range(N) if i != m) for m in range(N)]
    fwd_del = [tuple(plain._drop(fwd[i], m) for i in range(N) if i != m) for m in range(N)]
    hi_del = [plain._drop(hi, m) for m in range(N)]
    return census.pulled_tables(N, hbr_del, fwd_del, hi_del)


def rand_rows(rng, p):
    return tuple(sum(1 << j for j in range(N) if j != i and rng.random() < p) for i in range(N))


if __name__ == "__main__":
    rng = random.Random(4041)
    census.init_worker(N)

    t0 = time.time()
    bad = feas = 0
    for _ in range(20000):
        p = rng.choice((0.3, 0.5, 0.7, 0.9))
        hbr, fwd, hi = rand_rows(rng, p), rand_rows(rng, rng.choice((0.1, 0.4, 0.7))), rng.randrange(16)
        acc = bitmaps(hi, fwd, hbr)
        A = plain.allowed_sets(N, 1, hbr, fwd, (hi,))
        if (acc is None) != (A is None):
            bad += 1
        elif acc is not None:
            feas += 1
            if [sum(1 << c for c in a) for a in A] != list(acc):
                bad += 1
    print(f"1. triples: 20000 random, {feas} feasible, disagreements {bad}  [{time.time()-t0:.0f}s]")

    t0 = time.time()
    bad = gfn = spare_checks = spare_bad = spare_yes = 0
    for _ in range(6000):
        p = rng.choice((0.4, 0.6, 0.8))
        hbr, fwd, hi = rand_rows(rng, p), rand_rows(rng, rng.choice((0.1, 0.4, 0.7))), rng.randrange(16)
        chk = rand_rows(rng, p) + (sum(1 << j for j in range(N) if rng.random() < p),)
        s = (N, 1, hbr, chk, fwd, (hi,))
        d = plain.to_json(s)
        ref = model.gap_free(d, f=1)
        acc = bitmaps(hi, fwd, hbr)
        mine = acc is not None and all(acc[x] >> chk[x] & 1 for x in range(N + 1))
        bad += ref != mine
        if ref:
            gfn += 1
            pulled = pulled_of(hi, fwd, hbr)
            for m in range(N):
                spare_checks += 1
                r = model.gap_free(json_delete(d, plain.MON_NAMES[m]), f=1)
                spare_yes += r
                spare_bad += r != census.is_spare(N, pulled, chk, m)
    print(f"2. systems: 6000 random, {gfn} gap-free by the reference, disagreements {bad}")
    print(f"3. spare monitors: {spare_checks} deletions checked by the reference, {spare_yes} spare, "
          f"disagreements {spare_bad}  [{time.time()-t0:.0f}s]")

    t0 = time.time()
    done = bad = 0
    total_systems = 0
    gf_small = {}
    while done < 60:
        p = rng.choice((0.3, 0.45, 0.6))
        hbr, fwd, hi = rand_rows(rng, p), rand_rows(rng, rng.choice((0.1, 0.3, 0.6))), rng.randrange(16)
        acc = bitmaps(hi, fwd, hbr)
        if acc is None:
            continue
        lists = [[c for c in range(16) if b >> c & 1] for b in acc]
        size = 1
        for l in lists:
            size *= len(l)
        if size > 4000:
            continue
        pulled = pulled_of(hi, fwd, hbr)
        counted = census.count_nospare(N, acc, pulled)
        explicit = 0
        for chk in product(*lists):
            s = (N, 1, hbr, chk, fwd, (hi,))
            spare = False
            for m in range(N):
                t = plain.delete(s, m)
                r = gf_small.get(t)
                if r is None:
                    r = gf_small[t] = plain.gap_free_bfs(*t)
                if r:
                    spare = True
                    break
            explicit += not spare
        total_systems += size
        bad += counted != explicit
        done += 1
    print(f"4. no-spare counts: 60 feasible triples ({total_systems} systems one by one), "
          f"disagreements {bad}  [{time.time()-t0:.0f}s]")
