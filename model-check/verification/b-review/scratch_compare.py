import os
"""Scratch: compare check_model.explore with the independent implementation.

Part 1: the systems the script itself builds (without the 5-minute edge-ablation sweep
unless --ablations is given). Part 2: random small systems.
"""
import random
import sys
import time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import check_model as cm
from scratch_indep import Spec


def both(system):
    first, states = cm.explore(system)
    a = {g: (len(first[g]) if first[g] else None) for g in ("G1", "G2")}
    b, bstates, layers = Spec(system.as_data()).result()
    return a, states, b, bstates, layers


def named():
    yield from ((f"R/f{f}", cm.reference(f=f)) for f in (1, 2, 3))
    yield from ((f"R-{p}/f1", cm.reference(without=(p,))) for p in cm.PROPS)
    yield from ((f"R-{p}/f2", cm.reference(without=(p,), f=2)) for p in cm.PROPS)
    yield "R+unread", cm.reference(unread_extra=True)
    for n in (1, 2, 3, 4):
        for f in (1, 2, 3):
            yield f"mesh{n}/f{f}", cm.mesh(n, f)
    for n, rep, gate, f in ((2, "other", 2, 1), (3, "other", 2, 1), (3, "same", 2, 1),
                            (3, "same", 3, 1), (3, "other", 1, 1), (3, "other", 2, 2),
                            (3, "other", 3, 2), (3, "other", 3, 3)):
        yield f"ring{n}-{rep}-gate{gate}/f{f}", cm.ring(n, rep, gate, f)
    for gate in (["K"], ["K", "M1"], ["K", "M1", "M2", "M3"]):
        yield f"3+K-{'+'.join(gate)}", cm.with_coordinator(gate)
    for size, upper3, f in ((3, True, 1), (1, False, 1), (1, False, 2)):
        yield f"nested{size}-upper{3 if upper3 else 2}/f{f}", cm.nested(size, upper3, f)
    if "--ablations" in sys.argv:
        for label, system in cm.ablations(cm.nested(3, True, 1)):
            yield f"nested3 minus {label}", system


def random_system(rng):
    s = cm.System("rnd", rng.choice((1, 1, 2, 2, 3)))
    nm = rng.choice((1, 2, 2, 3, 3))
    nw = rng.choice((1, 1, 2))
    s.monitors = [f"M{i}" for i in range(1, nm + 1)]
    s.works = [f"W{i}" for i in range(1, nw + 1)]
    s.joiner = rng.choice((None, "J"))
    nonmon = s.works + (["J"] if s.joiner else [])
    allp = s.monitors + nonmon

    def subset(xs, p):
        return [x for x in xs if rng.random() < p]

    s.boundary = {m: rng.choice((1, 2)) for m in s.monitors if rng.random() < 0.8}
    s.substrate = {p: rng.choice(("a", "b")) for p in allp if rng.random() < 0.6}
    dens = rng.choice((0.3, 0.6, 0.9))
    s.hb_readers = {m: subset([x for x in s.monitors if x != m], dens)
                    for m in s.monitors if rng.random() < 0.9}
    s.checkers = {p: subset([x for x in s.monitors if x != p], dens)
                  for p in allp if rng.random() < 0.9}
    s.fwd = {m: subset([x for x in s.monitors if x != m], dens)
             for m in s.monitors if rng.random() < 0.9}
    s.halt_inputs = {w: subset(s.monitors, max(dens, 0.5)) for w in nonmon if rng.random() < 0.9}
    s.switches = subset(s.monitors, rng.choice((0.0, 0.0, 0.5)))
    s.coupling = rng.random() < 0.6
    s.window = rng.choice((0, 0, 1))
    return s


def perturbed(rng):
    """A random neighbour of the reference system: properties dropped, edges cut and added."""
    k = rng.choice((0, 0, 1, 1, 2))
    s = cm.reference(without=tuple(rng.sample(cm.PROPS, k)), f=rng.choice((1, 1, 2)))
    for _ in range(rng.choice((0, 1, 2, 3))):
        rel = getattr(s, rng.choice(cm.RELATIONS))
        keys = [x for x in rel if rel[x]]
        if keys:
            key = rng.choice(keys)
            rel[key] = [x for x in rel[key] if x != rng.choice(rel[key])]
    for _ in range(rng.choice((0, 0, 1, 2))):
        name = rng.choice(cm.RELATIONS)
        rel = getattr(s, name)
        key = rng.choice(["W1", "W2", "J"] if name == "halt_inputs" else
                         s.monitors if name in ("hb_readers", "fwd") else
                         s.monitors + ["W1", "W2", "J"])
        cm.add(rel, key, rng.choice([m for m in s.monitors if m != key]))
    if rng.random() < 0.2:
        s.boundary[rng.choice(s.monitors)] = rng.choice((1, 2, 3))
    if rng.random() < 0.15:
        s.switches = list(set(s.switches) | {rng.choice(s.monitors)})
    if rng.random() < 0.2:
        s.substrate[rng.choice(["J", "M3", "W1"])] = rng.choice(("s1", "s2", "s3"))
    return s


def main():
    bad = 0
    t0 = time.time()
    if "--perturb" in sys.argv:
        n = int(sys.argv[sys.argv.index("--perturb") + 1])
        cap = int(sys.argv[sys.argv.index("--cap") + 1]) if "--cap" in sys.argv else 1500
        rng = random.Random(77)
        done = skipped = diffs = 0
        counts = {}
        while done < n:
            system = perturbed(rng)
            first, states = cm.explore(system)
            if states > cap:
                skipped += 1
                continue
            a = {g: (len(first[g]) if first[g] else None) for g in ("G1", "G2")}
            b, bstates, layers = Spec(system.as_data()).result()
            done += 1
            counts[(a["G1"], a["G2"])] = counts.get((a["G1"], a["G2"]), 0) + 1
            if a != b or states != bstates:
                diffs += 1
                print("DIFF on perturbed system", system.as_data(), a, states, b, bstates, flush=True)
            if done % 100 == 0:
                print(f"  ... {done} compared, {skipped} skipped, {diffs} differences, "
                      f"t={time.time() - t0:.0f}s", flush=True)
        print(f"{done} perturbed reference systems compared ({skipped} skipped as over {cap} "
              f"states): {diffs} differences")
        print("  (G1, G2) result counts:", dict(sorted(counts.items(), key=lambda kv: str(kv[0]))))
        return
    if "--named" in sys.argv:
        for label, system in named():
            a, states, b, bstates, layers = both(system)
            ok = a == b and states == bstates
            bad += not ok
            print(f"{'ok ' if ok else 'DIFF'} {label:<34} explore {a} ({states})  "
                  f"independent {b} ({bstates}, {layers} layers) t={time.time() - t0:.0f}s",
                  flush=True)
        print(f"named systems done in {time.time() - t0:.0f}s, {bad} differences", flush=True)

    n = int(sys.argv[sys.argv.index("--random") + 1]) if "--random" in sys.argv else 0
    cap = int(sys.argv[sys.argv.index("--cap") + 1]) if "--cap" in sys.argv else 1500
    rng = random.Random(20261117)
    diffs, counts, skipped, done = 0, {}, 0, 0
    feats = {"joiner": 0, "switches": 0, "coupling": 0, "window1": 0, "f1": 0, "f2": 0, "f3": 0,
             "stop-boundary enabled": 0, "has substrate": 0}
    t0 = time.time()
    for i in range(n):
        system = random_system(rng)
        first, states = cm.explore(system)
        if states > cap:            # keep the unpruned comparison affordable
            skipped += 1
            continue
        a = {g: (len(first[g]) if first[g] else None) for g in ("G1", "G2")}
        b, bstates, layers = Spec(system.as_data()).result()
        done += 1
        feats["joiner"] += system.joiner is not None
        feats["switches"] += bool(system.switches)
        feats["coupling"] += system.coupling
        feats["window1"] += system.window == 1
        feats[f"f{system.f}"] += 1
        feats["stop-boundary enabled"] += any(
            k == "stop-boundary" for k, _ in cm.env_steps(system, cm.initial(system)))
        feats["has substrate"] += bool(system.substrate)
        key = (a["G1"], a["G2"])
        counts[key] = counts.get(key, 0) + 1
        if a != b or states != bstates:
            diffs += 1
            print("DIFF on random system", i, system.as_data(), a, states, b, bstates, flush=True)
        if done % 250 == 0:
            print(f"  ... {done} compared, {skipped} skipped, {diffs} differences, "
                  f"t={time.time() - t0:.0f}s", flush=True)
    if n:
        print(f"{done} random systems compared ({skipped} skipped as over {cap} states) in "
              f"{time.time() - t0:.0f}s: {diffs} differences")
        print("  feature coverage:", feats)
        print("  (G1, G2) result counts:", dict(sorted(counts.items(), key=lambda kv: str(kv[0]))))


if __name__ == "__main__":
    main()
