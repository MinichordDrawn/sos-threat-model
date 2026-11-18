"""Randomised tests of claims E1..E5 against model.py. Evidence only, not proof."""
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import model  # noqa: E402


def sub(rng, items, p=0.5):
    return [x for x in items if rng.random() < p]


def rand_system(rng, nmon=None, nwork=None, joiner=None, boundary="random", **fixed):
    nmon = rng.randint(0, 3) if nmon is None else nmon
    nwork = rng.randint(0, 2) if nwork is None else nwork
    mons = ["m%d" % i for i in range(nmon)]
    works = ["w%d" % i for i in range(nwork)]
    if joiner is None:
        joiner = rng.random() < 0.3
    j = "j" if joiner else None
    procs = mons + works + ([j] if j else [])
    nonmon = works + ([j] if j else [])
    S = {"name": "rand", "f": rng.randint(1, 3), "monitors": mons, "works": works, "joiner": j}
    if boundary == "random":
        S["boundary"] = {m: rng.choice(["a", "b"]) for m in mons if rng.random() < 0.6}
    elif boundary == "same":
        S["boundary"] = {m: "b" for m in mons}
    elif boundary == "unique":
        S["boundary"] = {m: "b_" + m for m in mons}
    elif boundary == "none":
        S["boundary"] = {}
    S["substrate"] = {p: rng.choice(["s", "t"]) for p in procs if rng.random() < 0.4}
    S["hb_readers"] = {m: sub(rng, mons) for m in mons if rng.random() < 0.8}
    S["checkers"] = {p: sub(rng, mons) for p in procs if rng.random() < 0.8}
    S["fwd"] = {m: sub(rng, mons) for m in mons if rng.random() < 0.8}
    S["halt_inputs"] = {w: sub(rng, mons, 0.6) for w in nonmon if rng.random() < 0.85}
    S["switches"] = sub(rng, mons, 0.3)
    S["coupling"] = rng.random() < 0.5
    S["window"] = rng.randint(0, 1)
    if rng.random() < 0.7:
        S["gate"] = rng.random() < 0.5
    if rng.random() < 0.7:
        S["slow_reports"] = rng.random() < 0.5
    S.update(fixed)
    return S


def e1(rng, n):
    bad = 0
    hist = {}
    for _ in range(n):
        S = rand_system(rng, nmon=rng.randint(1, 3), boundary="same")
        r = model.result(S)["G1"]
        hist[(len(S["monitors"]), r)] = hist.get((len(S["monitors"]), r), 0) + 1
        if r not in (1, 2):
            bad += 1
            print("E1 FAIL", S, r)
    print("E1: %d systems, failures %d, (monitors, G1) histogram %s" % (n, bad, sorted(hist.items())))


def e1_alt(rng, n):
    """Other reading: 'the same boundary' also satisfied when no monitor has one."""
    for _ in range(n):
        S = rand_system(rng, nmon=rng.randint(2, 3), boundary="none")
        r = model.result(S)["G1"]
        if r not in (1, 2):
            return S, r
    return None


def e2(rng, n):
    bad = 0
    for _ in range(n):
        S = rand_system(rng, nwork=rng.randint(1, 2), window=1, gate=True)
        r = model.result(S)["G2"]
        if r != 1:
            bad += 1
            print("E2 FAIL", S, r)
    print("E2: %d systems, failures %d" % (n, bad))


def e3(rng, n):
    bad = 0
    for _ in range(n):
        S = rand_system(rng, nwork=rng.randint(1, 2), gate=False)
        r = model.result(S)["G2"]
        if r != 1:
            bad += 1
            print("E3 FAIL", S, r)
    print("E3: %d systems, failures %d" % (n, bad))


def fwd_distance(S, x):
    """d of claim E4: least number of fwd edges from checkers[x] to halt_inputs[x]; None if no path."""
    mons = set(S["monitors"])
    src = [m for m in S.get("checkers", {}).get(x, []) if m in mons]
    dst = set(m for m in S.get("halt_inputs", {}).get(x, []) if m in mons)
    dist = {m: 0 for m in src}
    frontier = list(dist)
    while frontier:
        nxt = []
        for m in frontier:
            for r in S.get("fwd", {}).get(m, []):
                if r in mons and r not in dist:
                    dist[r] = dist[m] + 1
                    nxt.append(r)
        frontier = nxt
    ds = [dist[m] for m in dst if m in dist]
    return min(ds) if ds else None


def rand_slow_plain(rng):
    nmon = rng.randint(0, 6)
    nwork = rng.randint(1, 3)
    mons = ["m%d" % i for i in range(nmon)]
    works = ["w%d" % i for i in range(nwork)]
    dens = rng.choice([0.15, 0.3, 0.5])
    S = {"name": "slow-plain", "f": rng.randint(1, 3), "monitors": mons, "works": works,
         "joiner": None, "boundary": {m: "b_" + m for m in mons}, "substrate": {},
         "hb_readers": {m: sub(rng, mons) for m in mons if rng.random() < 0.8},
         "checkers": {p: sub(rng, mons, dens) for p in mons + works if rng.random() < 0.9},
         "fwd": {m: sub(rng, mons, dens) for m in mons if rng.random() < 0.9},
         "halt_inputs": {w: sub(rng, mons, dens) for w in works if rng.random() < 0.9},
         "switches": [], "coupling": True, "window": 0, "gate": True, "slow_reports": True}
    return S


def e4(rng, n):
    bad = 0
    hist = {}
    for _ in range(n):
        S = rand_slow_plain(rng)
        x = rng.choice(S["works"])
        d = fwd_distance(S, x)
        hist[d] = hist.get(d, 0) + 1
        horizon = len(S["monitors"]) + 6
        log, st, resp = model.run_script(S, [[("mutate", x)]], horizon)
        stepped = [x in rec["stepped"] for rec in log]
        if d is None:
            ok = len(log) == horizon and all(stepped)
        else:
            ok = len(log) >= d + 1 and all(stepped[:d]) and not any(stepped[d:])
        if not ok:
            bad += 1
            print("E4 FAIL", S, x, d, stepped)
    print("E4: %d systems, failures %d, d histogram %s" % (n, bad, sorted(hist.items(), key=lambda kv: (kv[0] is None, kv[0]))))


def e5(rng, n, general=False):
    bad = 0
    done = 0
    while done < n:
        if general:
            S = rand_system(rng, nwork=rng.randint(1, 2))
        else:
            S = rand_system(rng, nwork=rng.randint(1, 2), gate=True, window=0, slow_reports=False)
        mons = set(S["monitors"])
        ws = [w for w in S["works"]
              if (general or S["halt_inputs"].get(w)) and not (set(S["checkers"].get(w, [])) & mons)]
        if not ws:
            continue
        done += 1
        r = model.result(S)["G2"]
        if r != 1:
            bad += 1
            print("E5 FAIL", S, r)
    print("E5%s: %d systems, failures %d" % (" (no restriction on gate/window/slow_reports/halt_inputs)" if general else "", n, bad))


if __name__ == "__main__":
    rng = random.Random(20261117)
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
    e1(rng, n)
    print("E1 other reading (no monitor has a boundary), first failure:", e1_alt(rng, 2000))
    e2(rng, n)
    e3(rng, n)
    e4(rng, 4 * n)
    e5(rng, n)
    e5(rng, n, general=True)
