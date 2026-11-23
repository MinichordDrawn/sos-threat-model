#!/usr/bin/env python3
"""Part A, item 1: every wiring of four nodes as connections (4,096), under each reading
of a connection, each wiring of the work and each rate, against each requirement and each
combination. Also items 3 and 4 at the level of connections.

Run:  python -B part_a1.py            (writes part-a-connections.json, prints the tables)
"""
import itertools
import json
import os
import sys
import time

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import mr_ring as R  # noqa: E402

NODES = R.NODES4
PAIRS = R.all_pairs(NODES)
REQS = ["R1", "R2", "R3", "R4", "R5", "R6"]
WORKS = ("all", "two")
FS = (1, 2, 3)


def conns_of(mask):
    return [p for i, p in enumerate(PAIRS) if (mask >> i) & 1]


def mask_of(conns):
    return sum(1 << PAIRS.index(p) for p in conns)


def compute():
    table = {}
    for reading in R.READINGS:
        for work in WORKS:
            t0 = time.time()
            rows = []
            for mask in range(1 << len(PAIRS)):
                ev = R.evaluate(R.edges_of(conns_of(mask), reading), NODES, "D", work, FS)
                rows.append(ev)
            table[f"{reading}/{work}"] = rows
            print(f"# computed {reading}/{work} in {time.time() - t0:.0f} s", flush=True)
    return table


def holds(ev, req, f, r4="R4"):
    if req in ("R1", "R6"):
        return ev[f"{req}@{f}"]
    if req == "R4":
        return ev[r4]
    return ev[req]


def fixed_for(work):
    return ("D",) if work == "all" else ("A", "D")


def analyse(rows, work, f, subset, r4="R4"):
    good = [m for m, ev in enumerate(rows) if all(holds(ev, q, f, r4) for q in subset)]
    cand = mask_of(R.CANDIDATE)
    if not good:
        return {"least": None, "n": 0, "classes": [], "cand_meets": False, "cand_least": False}
    k = min(bin(m).count("1") for m in good)
    least = [m for m in good if bin(m).count("1") == k]
    fixed = fixed_for(work)
    classes = sorted({R.canon_conns(conns_of(m), NODES, fixed) for m in least})
    ccanon = R.canon_conns(R.CANDIDATE, NODES, fixed)
    return {"least": k, "n": len(least), "classes": classes, "n_good": len(good),
            "cand_meets": cand in good, "cand_least": ccanon in classes}


def show_class(c):
    return ", ".join(f"{x}->{y}" for x, y in c)


def main():
    cache = os.path.join(HERE, "part-a-connections.json")
    if os.path.exists(cache) and "--recompute" not in sys.argv:
        table = json.load(open(cache, encoding="utf-8"))
        print("# read", cache)
    else:
        table = compute()
        with open(cache, "w", encoding="utf-8") as fh:
            json.dump(table, fh)
    cand = mask_of(R.CANDIDATE)
    mesh = (1 << 12) - 1
    subsets = [s for n in range(1, 7) for s in itertools.combinations(REQS, n)]

    print("\n== The candidate and the mesh, requirement by requirement")
    for key, rows in table.items():
        for label, m in (("candidate", cand), ("mesh", mesh)):
            ev = rows[m]
            print(f"{key:11s} {label:9s} " + " ".join(
                f"{k}={'yes' if v else 'NO'}" for k, v in ev.items() if not k.startswith("raw"))
                + "  raw(G1,G2,told)@1,2,3=" + str([ev[f'raw@{f}'] for f in FS]))

    print("\n== Each combination: least number of connections, number of least wirings,")
    print("== classes up to renaming, whether the candidate meets it, whether it is least")
    summary = {}
    for key, rows in table.items():
        reading, work = key.split("/")
        for f in FS:
            print(f"\n-- reading {reading}, work reads {work}, f = {f}")
            print("combination              | least | wirings | classes | meets all (of 4096) | "
                  "candidate meets | candidate least")
            for s in subsets:
                a = analyse(rows, work, f, s)
                summary[f"{key}/f{f}/{'+'.join(s)}"] = {
                    "least": a["least"], "wirings": a["n"], "classes": len(a["classes"]),
                    "candidate_meets": a["cand_meets"], "candidate_least": a["cand_least"],
                    "least_classes": [show_class(c) for c in a["classes"]][:40]}
                print(f"{'+'.join(s):24s} | {str(a['least']):5s} | {a['n']:7d} | "
                      f"{len(a['classes']):7d} | {a.get('n_good', 0):6d} | "
                      f"{'yes' if a['cand_meets'] else 'NO':3s} | "
                      f"{'yes' if a['cand_least'] else 'NO'}")

    print("\n== The whole list: every least wiring up to renaming")
    for key, rows in table.items():
        reading, work = key.split("/")
        for f in FS:
            for r4 in ("R4", "R4w", "R4wl"):
                a = analyse(rows, work, f, REQS, r4)
                print(f"\n-- reading {reading}, work reads {work}, f = {f}, naming as {r4}: "
                      f"least {a['least']}, {a['n']} wirings, {len(a['classes'])} classes, "
                      f"candidate meets: {a['cand_meets']}, candidate least: {a['cand_least']}")
                if r4 == "R4" or a["classes"] != analyse(rows, work, f, REQS)["classes"]:
                    for c in a["classes"]:
                        print("   ", show_class(c))
                else:
                    print("    (the same wirings as with naming as a count)")

    print("\n== The whole list without R2, and R2 alone with R5: what the count rests on")
    for key, rows in table.items():
        reading, work = key.split("/")
        for s in (("R2", "R5"), ("R2", "R3", "R5"), ("R1", "R3", "R4", "R5", "R6"),
                  ("R1", "R2", "R3", "R4", "R6")):
            a = analyse(rows, work, 1, s)
            print(f"{key} f=1 {'+'.join(s)}: least {a['least']}, {a['n']} wirings, "
                  f"{len(a['classes'])} classes; candidate least: {a['cand_least']}")
            for c in a["classes"][:12]:
                print("   ", show_class(c))

    print("\n== Which requirement forces each of the candidate's nine connections")
    print("== (the requirements that hold for the candidate and fail when the connection is removed)")
    names = ["R1@1", "R1@2", "R1@3", "R2", "R3", "R4w", "R4wl", "R5", "R6@1", "R6@2", "R6@3"]
    forced = {}
    for key, rows in table.items():
        print(f"\n-- {key}")
        base = rows[cand]
        for p in R.CANDIDATE:
            ev = rows[cand & ~(1 << PAIRS.index(p))]
            lost = [n for n in names if base[n] and not ev[n]]
            forced[f"{key}/{p[0]}->{p[1]}"] = lost
            print(f"   without {p[0]}->{p[1]}: fails {', '.join(lost) if lost else 'nothing'}"
                  f"   raw@1,2,3={[ev[f'raw@{f}'] for f in FS]}")

    print("\n== Mesh against candidate: requirements on which they differ")
    for key, rows in table.items():
        diff = [k for k in rows[cand] if not k.startswith("raw") and rows[cand][k] != rows[mesh][k]]
        rawdiff = [f for f in FS if rows[cand][f"raw@{f}"] != rows[mesh][f"raw@{f}"]]
        print(f"{key}: differ on {diff or 'nothing'}; raw results differ at f in {rawdiff or 'none'}")

    print("\n== Work checked by every node that checks a state, against work checked by all four")
    for reading in R.READINGS:
        n = 0
        for mask in range(1 << 12):
            E = R.edges_of(conns_of(mask), reading)
            for f in FS:
                a = R.run(R.ring_system(E, NODES, "D", "all", f))
                b = R.run(R.ring_system(E, NODES, "D", "all-checking", f))
                if a != b:
                    n += 1
        rows = table[f"{reading}/all"]
        print(f"{reading}: {n} of {3 * 4096} (wiring, rate) pairs differ")
        for f in FS:
            good_alt = []
            for mask in range(1 << 12):
                ev = rows[mask]
                E = R.edges_of(conns_of(mask), reading)
                g1, g2, told = R.run(R.ring_system(E, NODES, "D", "all-checking", f))
                if (g1 is None and g2 is None and g2 is None and told is None
                        and ev["R2"] and ev["R3"] and ev["R5"]):
                    good_alt.append(mask)
            k = min(bin(m).count("1") for m in good_alt)
            least = [m for m in good_alt if bin(m).count("1") == k]
            a = analyse(rows, "all", f, REQS)
            same = sorted({R.canon_conns(conns_of(m), NODES, ("D",)) for m in least}) == a["classes"]
            print(f"   f={f}: whole list, least {k}, {len(least)} wirings; same as with all four: {same}")

    print("\n== restart_game (check_model.py) against 'the coordinator reaches every node'")
    import check_model as cm
    for reading in R.READINGS:
        bad = 0
        for mask in range(1 << 12):
            E = R.edges_of(conns_of(mask), reading)
            obs = {z: sorted(v) for z, v in R.watchers(E, NODES).items()}
            trace, _ = cm.restart_game(obs, self_starting=("D",))
            if (trace is None) != R.r3(E, NODES, "D"):
                bad += 1
        print(f"{reading}: 4096 wirings, {bad} disagreements")

    print("\n== Naming at the wiring: the search over cases against the rule")
    for reading in R.READINGS:
        bad = 0
        for mask in range(1 << 12):
            E = R.edges_of(conns_of(mask), reading)
            wt = R.watchers(E, NODES)
            if R.can_name(wt, NODES) != R.can_name_rule(wt, NODES):
                bad += 1
        print(f"{reading}: 4096 wirings, {bad} disagreements")

    print("\n== An undirected link (all six edges between two nodes): 64 wirings")
    und = [(x, y) for x, y in itertools.combinations(NODES, 2)]
    for work in WORKS:
        for f in FS:
            good = []
            for mask in range(64):
                links = [p for i, p in enumerate(und) if (mask >> i) & 1]
                E = R.edges_of(links, "both")
                ev = R.evaluate(E, NODES, "D", work, (f,))
                if all(holds(ev, q, f) for q in REQS):
                    good.append(links)
            k = min(len(g) for g in good) if good else None
            least = [g for g in good if len(g) == k]
            print(f"work {work}, f={f}: whole list, least {k} links, "
                  + "; ".join("-".join(x + y for x, y in g) for g in least))

    with open(os.path.join(HERE, "part-a-connections-summary.json"), "w", encoding="utf-8") as fh:
        json.dump({"combinations": summary, "forced": forced}, fh, indent=1)


if __name__ == "__main__":
    main()
