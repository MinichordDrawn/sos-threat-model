"""Random and exhaustive tests of C1..C6 and C8 against model.py. Evidence, not proof."""
import os
import sys
import random
import itertools
import json

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from model import result  # noqa: E402

rng = random.Random(20261117)


def rsub(items, p):
    return [x for x in items if rng.random() < p]


def rand_plain(nm_max=4, nw_max=2, f=None, dense=None, allow_self=True, dups=False):
    nm = rng.randint(0, nm_max)
    nw = rng.randint(0, nw_max)
    mons = ["M%d" % (i + 1) for i in range(nm)]
    works = ["W%d" % (i + 1) for i in range(nw)]
    p = dense if dense is not None else rng.choice([0.2, 0.5, 0.8, 1.0])
    d = {
        "name": "rand",
        "f": f if f is not None else rng.randint(1, 3),
        "monitors": mons,
        "works": works,
        "joiner": None,
        "boundary": {m: "b_" + m for m in mons},
        "substrate": {},
        "hb_readers": {},
        "checkers": {},
        "fwd": {},
        "halt_inputs": {},
        "switches": [],
        "coupling": True,
        "window": 0,
    }

    def pick(excl):
        cand = [m for m in mons if allow_self or m != excl]
        lst = rsub(cand, p)
        if dups and lst and rng.random() < 0.5:
            lst = lst + [rng.choice(lst)]
        return lst

    for m in mons:
        for key in ("hb_readers", "checkers", "fwd"):
            lst = pick(m)
            if lst or rng.random() < 0.5:  # sometimes leave the key missing
                d[key][m] = lst
    for w in works:
        lst = pick(None)
        if lst or rng.random() < 0.5:
            d["checkers"][w] = lst
        lst = pick(None)
        if lst or rng.random() < 0.5:
            d["halt_inputs"][w] = lst
    return d


def rand_any():
    d = rand_plain(nm_max=3, nw_max=2)
    mons, works = d["monitors"], d["works"]
    if rng.random() < 0.5:
        d["joiner"] = "J"
        if rng.random() < 0.7:
            d["checkers"]["J"] = rsub(mons, 0.6)
        if rng.random() < 0.7:
            d["halt_inputs"]["J"] = rsub(mons, 0.6)
    d["boundary"] = {m: rng.choice(["b1", "b2", "b3"]) for m in mons if rng.random() < 0.8}
    procs = mons + works + (["J"] if d["joiner"] else [])
    d["substrate"] = {p: rng.choice(["s1", "s2"]) for p in procs if rng.random() < 0.5}
    d["switches"] = rsub(mons, 0.4)
    d["coupling"] = rng.random() < 0.5
    d["window"] = rng.choice([0, 1])
    return d


def watchers(d, z):
    return [m for m in d["monitors"] if m != z and m in d["checkers"].get(z, []) and m in d["hb_readers"].get(z, [])]


def reach(d, starts, avoid=None):
    seen = set(s for s in starts if s != avoid)
    stack = list(seen)
    while stack:
        m = stack.pop()
        for r in d["fwd"].get(m, []):
            if r != avoid and r not in seen:
                seen.add(r)
                stack.append(r)
    return seen


def cond_a(d):
    return all(watchers(d, z) for z in d["monitors"])


def cond_b(d, distinct=True):
    for w in d["works"]:
        ch = d["checkers"].get(w, [])
        hi = d["halt_inputs"].get(w, [])
        if len(ch) < 1:
            return False
        if (len(set(hi)) if distinct else len(hi)) < 2:
            return False
    return True


def cond_c(d):
    for z in d["monitors"]:
        r = reach(d, watchers(d, z), avoid=z)
        if any(u != z and u not in r for u in d["monitors"]):
            return False
    return True


def cond_d(d):
    for x in d["works"]:
        ok = False
        for dd in d["checkers"].get(x, []):
            r = reach(d, [dd])
            if all(u in r for u in d["monitors"]):
                ok = True
                break
        if not ok:
            return False
    return True


def test_c1(N=4000):
    cnt = 0
    for _ in range(N):
        d = rand_any()
        if not d["monitors"]:
            continue
        d["f"] = len(d["monitors"]) + rng.randint(0, 2)
        r = result(d)
        cnt += 1
        if r["G1"] != 1:
            print("C1 COUNTEREXAMPLE (or not round 1)", r, json.dumps(d))
            return False
    print("C1: %d random systems (not only plain), all G1 == 1" % cnt)
    return True


def test_c2(N=6000):
    cnt = 0
    for _ in range(N):
        d = rand_plain(dups=rng.random() < 0.3)
        zs = [z for z in d["monitors"] if set(d["checkers"].get(z, [])) <= {z}]
        if not zs:
            continue
        cnt += 1
        r = result(d)
        if r["G1"] != 1:
            print("C2 COUNTEREXAMPLE", r, json.dumps(d))
            return False
    print("C2: %d plain systems with a monitor checked by nobody else, all G1 == 1" % cnt)
    return True


def find_N(d):
    mons = d["monitors"]
    for k in range(1, min(d["f"], len(mons)) + 1):
        for N in itertools.combinations(mons, k):
            Ns = set(N)
            if all(c in Ns for z in N for c in d["checkers"].get(z, [])):
                return N
    return None


def test_c3(N=8000):
    cnt = 0
    full = 0
    for _ in range(N):
        d = rand_plain(dups=rng.random() < 0.3)
        Nset = find_N(d)
        if Nset is None:
            continue
        cnt += 1
        if len(Nset) == len(d["monitors"]):
            full += 1
        r = result(d)
        if r["G1"] != 1:
            print("C3 COUNTEREXAMPLE", r, Nset, json.dumps(d))
            return False
    print("C3: %d plain systems with such an N (%d where the least N is every monitor), all G1 == 1" % (cnt, full))
    return True


def test_c4(N=60000):
    cnt = 0
    nowork = 0
    zero = 0
    for _ in range(N):
        d = rand_plain(nm_max=5, nw_max=2, f=1, dense=rng.choice([0.5, 0.7, 0.9, 1.0]))
        if not (cond_a(d) and cond_b(d) and cond_c(d) and cond_d(d)):
            continue
        cnt += 1
        if not d["works"]:
            nowork += 1
        if not d["monitors"]:
            zero += 1
        r = result(d)
        if r["G1"] is not None or r["G2"] is not None:
            print("C4 COUNTEREXAMPLE", r, json.dumps(d))
            return False
    print("C4: %d plain f=1 systems satisfying (a)-(d) (%d with no work process, %d with no process at all), all null/null" % (cnt, nowork, zero))
    return True


def test_c4_dups(N=60000):
    """(b) read as list length, lists may repeat a name."""
    cnt = 0
    bad = None
    for _ in range(N):
        d = rand_plain(nm_max=4, nw_max=2, f=1, dense=rng.choice([0.5, 0.7, 0.9, 1.0]), dups=True)
        if not (cond_a(d) and cond_b(d, distinct=False) and cond_c(d) and cond_d(d)):
            continue
        cnt += 1
        r = result(d)
        if r["G1"] is not None or r["G2"] is not None:
            if bad is None or len(json.dumps(d)) < len(json.dumps(bad[1])):
                bad = (r, d)
    print("C4 with repeated list entries counted twice: %d systems; a failing one: %s" % (cnt, "none" if bad is None else (bad[0], json.dumps(bad[1]))))


def test_c5(N=8000):
    cnt = 0
    empty = 0
    for _ in range(N):
        d = rand_plain(dups=rng.random() < 0.3)
        ws = [w for w in d["works"] if len(d["halt_inputs"].get(w, [])) <= d["f"]]
        if not ws:
            continue
        cnt += 1
        if any(len(d["halt_inputs"].get(w, [])) == 0 for w in ws):
            empty += 1
        r = result(d)
        if r["G2"] != 1:
            print("C5 COUNTEREXAMPLE", r, json.dumps(d))
            return False
    print("C5: %d plain systems with a work process with at most f halt inputs (%d with an empty list), all G2 == 1" % (cnt, empty))
    return True


def mesh(n, f, self_entries=False):
    mons = ["M%d" % (i + 1) for i in range(n)]

    def others(m):
        return [x for x in mons if x != m or self_entries]

    return {
        "name": "mesh%d" % n,
        "f": f,
        "monitors": mons,
        "works": ["W"],
        "joiner": None,
        "boundary": {m: "b_" + m for m in mons},
        "substrate": {},
        "hb_readers": {m: others(m) for m in mons},
        "checkers": dict([(m, others(m)) for m in mons] + [("W", list(mons))]),
        "fwd": {m: [x for x in mons if x != m] for m in mons},
        "halt_inputs": {"W": list(mons)},
        "switches": [],
        "coupling": True,
        "window": 0,
    }


def test_c6():
    ok = True
    rows = []
    for n in range(1, 6):
        for f in range(1, 8):
            for se in (False, True):
                r = result(mesh(n, f, se))
                safe = r["G1"] is None and r["G2"] is None
                if safe != (f <= n - 1):
                    ok = False
                    print("C6 COUNTEREXAMPLE n=%d f=%d self=%s %s" % (n, f, se, r))
                if not se:
                    rows.append((n, f, r["G1"], r["G2"]))
    print("C6: mesh n=1..5, f=1..7:", "iff holds" if ok else "FAILS")
    for row in rows:
        print("   n=%d f=%d G1=%s G2=%s" % row)
    return ok


C8_A = {
    "name": "c8-no-work",
    "f": 1,
    "monitors": ["A", "B", "C"],
    "works": [],
    "joiner": None,
    "boundary": {"A": "ba", "B": "bb", "C": "bc"},
    "substrate": {},
    "hb_readers": {"A": [], "B": ["A", "C"], "C": ["A", "B"]},
    "checkers": {"A": ["B", "C"], "B": ["A", "C"], "C": ["A", "B"]},
    "fwd": {},
    "halt_inputs": {},
    "switches": [],
    "coupling": True,
    "window": 0,
}

C8_B = {
    "name": "c8-with-work",
    "f": 1,
    "monitors": ["A", "B", "C"],
    "works": ["W"],
    "joiner": None,
    "boundary": {"A": "ba", "B": "bb", "C": "bc"},
    "substrate": {},
    "hb_readers": {"A": [], "B": ["A", "C"], "C": ["A", "B"]},
    "checkers": {"A": ["B", "C"], "B": ["A", "C"], "C": ["A", "B"], "W": ["A", "B", "C"]},
    "fwd": {},
    "halt_inputs": {"W": ["A", "B", "C"]},
    "switches": [],
    "coupling": True,
    "window": 0,
}

C8_C = dict(C8_B, name="c8-with-work-no-coupling", coupling=False)


def test_c8():
    for d in (C8_A, C8_B, C8_C):
        print("C8 witness %s: hb_readers[A]=%s result=%s" % (d["name"], d["hb_readers"]["A"], result(d)))
    # two-monitor attempt, to show three are needed
    two = {
        "name": "two", "f": 1, "monitors": ["A", "B"], "works": [], "joiner": None,
        "boundary": {"A": "ba", "B": "bb"}, "substrate": {},
        "hb_readers": {"A": [], "B": ["A"]}, "checkers": {"A": ["B"], "B": ["A"]},
        "fwd": {}, "halt_inputs": {}, "switches": [], "coupling": True, "window": 0,
    }
    print("C8 aside, two monitors:", result(two, want_trace=True))


if __name__ == "__main__":
    test_c1()
    test_c2()
    test_c3()
    test_c4()
    test_c4_dups()
    test_c5()
    test_c6()
    test_c8()
