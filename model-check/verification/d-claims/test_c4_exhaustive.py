"""Exhaustive check of C4 on small plain systems (f = 1). Evidence, not proof."""
import os
import sys
import itertools
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from model import result  # noqa: E402
from test_claims import cond_a, cond_b, cond_c, cond_d  # noqa: E402


def subsets(items):
    for r in range(len(items) + 1):
        for c in itertools.combinations(items, r):
            yield list(c)


def run(nm, nw, self_entries):
    mons = ["M%d" % (i + 1) for i in range(nm)]
    works = ["W%d" % (i + 1) for i in range(nw)]

    def cand(m):
        return [x for x in mons if self_entries or x != m]

    per_mon = [list(subsets(cand(m))) for m in mons]
    all_sub = list(subsets(mons))
    total = passed = 0
    base = {"name": "x", "f": 1, "monitors": mons, "works": works, "joiner": None,
            "boundary": {m: "b_" + m for m in mons}, "substrate": {}, "switches": [],
            "coupling": True, "window": 0}
    for hb in itertools.product(*per_mon):
        for ck in itertools.product(*per_mon):
            d = dict(base)
            d["hb_readers"] = dict(zip(mons, hb))
            d["checkers"] = dict(zip(mons, ck))
            d["fwd"] = {}
            d["halt_inputs"] = {}
            if not cond_a(d):
                continue
            for fw in itertools.product(*per_mon):
                d["fwd"] = dict(zip(mons, fw))
                if not cond_c(d):
                    continue
                for wck in itertools.product(all_sub, repeat=nw):
                    for whi in itertools.product(all_sub, repeat=nw):
                        d2 = dict(d)
                        d2["checkers"] = dict(d["checkers"], **dict(zip(works, wck)))
                        d2["halt_inputs"] = dict(zip(works, whi))
                        total += 1
                        if not (cond_b(d2) and cond_d(d2)):
                            continue
                        passed += 1
                        r = result(d2)
                        if r["G1"] is not None or r["G2"] is not None:
                            print("C4 COUNTEREXAMPLE", r, json.dumps(d2))
                            return False
    print("C4 exhaustive: %d monitors, %d work, self entries %s: %d systems satisfy (a) and (c), %d satisfy (a)-(d), all null/null"
          % (nm, nw, self_entries, total, passed))
    return True


if __name__ == "__main__":
    run(2, 0, True)
    run(2, 1, True)
    run(2, 2, False)
    run(3, 0, False)
    run(3, 1, False)
