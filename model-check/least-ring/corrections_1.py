#!/usr/bin/env python3
"""The computations behind corrections-1.md. Each was first reported by an independent
reader (verify-reader/handback.md) and is recomputed here with mr_model.py.

Run:  python -B corrections_1.py SECTION ...   sections: readings r2 r5 orders added
"""
import itertools
import json
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import mr_ring as R  # noqa: E402
import mr_model as mm  # noqa: E402
import mr_tower as T  # noqa: E402
import part_d as D  # noqa: E402
from mr_show import brief, rows_text  # noqa: E402

N4 = R.NODES4
PAIRS = R.all_pairs(N4)
WAYS = ("along", "against", "both")


def conns_of(mask):
    return [p for i, p in enumerate(PAIRS) if (mask >> i) & 1]


def bundle27(x, y, way):
    """way = (signal, check, report), each along, against or both.
    along:   Y reads X's signal / Y checks X's state / X reports to Y
    against: X reads Y's signal / X checks Y's state / Y reports to X"""
    out = []
    for kind, w in zip(R.KINDS, way):
        if w in ("along", "both"):
            out.append((kind, x, y))
        if w in ("against", "both"):
            out.append((kind, y, x))
    return out


def edges27(conns, way):
    return frozenset(e for x, y in conns for e in bundle27(x, y, way))


def r2_any(E, nodes):
    """Two signal readers and two state checkers each, not necessarily the same nodes."""
    for z in nodes:
        if sum(1 for m in nodes if m != z and ("hb_readers", z, m) in E) < 2:
            return False
        if sum(1 for m in nodes if m != z and ("checkers", z, m) in E) < 2:
            return False
    return True


def r2_readers(E, nodes):
    return all(sum(1 for m in nodes if m != z and ("hb_readers", z, m) in E) >= 2 for z in nodes)


def model_ok(E, work, f):
    g1, g2, told = R.run(R.ring_system(E, N4, "D", work, f))
    return g1 is None and g2 is None and told is None


def readings():
    print("== The 27 ways an arrow can carry the three kinds; every wiring; f = 1; W reads all")
    print("== R3 and R5 as part-a.md states them; R2 as stated, and R2 as two readers and two")
    print("== checkers by any nodes")
    cand = R.CANDIDATE
    outcomes = {}
    for way in itertools.product(WAYS, repeat=3):
        res = []
        for r2fn, tag in ((R.r2, "R2 as stated"), (r2_any, "R2 any nodes")):
            good = []
            for mask in range(1 << 12):
                E = edges27(conns_of(mask), way)
                if r2fn(E, N4) and R.r3(E, N4, "D") and R.r5(E, N4, "D") and model_ok(E, "all", 1):
                    good.append(mask)
            R.RESULTS.clear()
            Ec = edges27(cand, way)
            c2 = r2fn(Ec, N4)
            cmeets = c2 and R.r3(Ec, N4, "D") and R.r5(Ec, N4, "D") and model_ok(Ec, "all", 1)
            c23 = [f for f in (2, 3) if model_ok(Ec, "all", f)] if cmeets else []
            if good:
                k = min(bin(m).count("1") for m in good)
                n = sum(1 for m in good if bin(m).count("1") == k)
            else:
                k, n = None, 0
            res.append((tag, k, n, cmeets, bool(cmeets and k == 9), c23, c2))
        outcomes.setdefault(tuple(r[:5] for r in res), []).append(way)
        print("signal %-7s check %-7s report %-7s | " % way + " | ".join(
            f"{t}: least {k} ({n} wirings), candidate meets {cm}, is least {cl}, also meets "
            f"at f {c23}, candidate's R2 {c2}" for t, k, n, cm, cl, c23, c2 in res), flush=True)
    print(f"\n{len(outcomes)} different outcomes among the 27:")
    for key, ways in outcomes.items():
        print("  ", key, "<-", len(ways), "readings:", ["/".join(w) for w in ways])


def r2():
    print("== R2's other choices, kind by kind, 36 edges, the whole list, W reads all")
    rep = [("fwd", m, "D") for m in "ABC"]
    pairs2 = {z: list(itertools.combinations([m for m in N4 if m != z], 2)) for z in N4}
    one = {z: [m for m in N4 if m != z] for z in N4}
    # (a) an observer is a signal reader: 8 reads, 3 reports, and one state check of each
    #     monitor (a monitor nobody checks is a gap at f = 1): 15 edges
    for r3name in ("signal", "watch"):
        counts = {1: 0, 2: 0, 3: 0}
        example = None
        for rd in itertools.product(*[pairs2[z] for z in N4]):
            for ck in itertools.product(*[one[z] for z in N4]):
                E = set(rep)
                for z, pr in zip(N4, rd):
                    E.update(("hb_readers", z, m) for m in pr)
                for z, c in zip(N4, ck):
                    E.add(("checkers", z, c))
                E = frozenset(E)
                if not R.r3(E, N4, "D", r3name):
                    continue
                for f in (1, 2, 3):
                    if model_ok(E, "all", f):
                        counts[f] += 1
                        example = example or E
            R.RESULTS.clear()
        print(f"(a) R2 as two signal readers, R3 with observes = {r3name}: of the 6,561 sets of 15 "
              f"edges (8 reads, 3 reports, one check of each monitor), the whole list is met by "
              f"{counts[1]} at f=1, {counts[2]} at f=2, {counts[3]} at f=3", flush=True)
        if example:
            print("     one of them: " + "; ".join(R.edge_text(e) for e in sorted(example)))
    # 14 edges cannot do: a set with 8 reads and 3 reports and three checks leaves a monitor
    # unchecked; the execution is one mutation
    E = set(rep)
    for z in N4:
        E.update(("hb_readers", z, m) for m in pairs2[z][0])
    for z in "ABC":
        E.add(("checkers", z, one[z][0]))
    print("     with D checked by nobody (14 edges), f=1 (G1, G2, told):",
          R.run(R.ring_system(frozenset(E), N4, "D", "all", 1)))
    # (b) two readers and two checkers, any nodes: 19 edges
    counts = {1: 0, 2: 0, 3: 0}
    two = 0
    for rd in itertools.product(*[pairs2[z] for z in N4]):
        for ck in itertools.product(*[pairs2[z] for z in N4]):
            E = set(rep)
            for z, pr in zip(N4, rd):
                E.update(("hb_readers", z, m) for m in pr)
            for z, pr in zip(N4, ck):
                E.update(("checkers", z, m) for m in pr)
            E = frozenset(E)
            if not R.r3(E, N4, "D"):
                continue
            for f in (1, 2, 3):
                if model_ok(E, "all", f):
                    counts[f] += 1
            two += model_ok(E, "two", 1)
        R.RESULTS.clear()
    print(f"(b) R2 as two readers and two checkers by any nodes, R3 as stated: of the 6,561 sets "
          f"of 19 edges, the whole list is met by {counts[1]} at f=1, {counts[2]} at f=2, "
          f"{counts[3]} at f=3; W reads two, f=1: {two}")


def r5():
    print("== R5's other choice: D watches each member (no report asked)")
    table = json.load(open(os.path.join(HERE, "part-a-connections.json"), encoding="utf-8"))
    cand = sum(1 << PAIRS.index(p) for p in R.CANDIDATE)
    for key, rows in table.items():
        reading, work = key.split("/")
        for f in (1, 2, 3):
            good = []
            for mask in range(1 << 12):
                ev = rows[mask]
                E = R.edges_of(conns_of(mask), reading)
                alt = all(("hb_readers", m, "D") in E and ("checkers", m, "D") in E for m in "ABC")
                if alt and ev["R2"] and ev["R3"] and ev[f"R1@{f}"] and ev[f"R6@{f}"]:
                    good.append(mask)
            if not good:
                print(f"{key}, f={f}: no wiring meets the list")
                continue
            k = min(bin(m).count("1") for m in good)
            least = [m for m in good if bin(m).count("1") == k]
            fixed = ("D",) if work == "all" else ("A", "D")
            shapes = sorted({R.canon_conns(conns_of(m), N4, fixed) for m in least})
            print(f"{key}, f={f}: least {k} ({len(least)} wirings, {len(shapes)} shapes); candidate "
                  f"meets {cand in good}, is least {cand in least}; e.g. "
                  + ", ".join(f"{x}->{y}" for x, y in shapes[0]))


def without_top(reading, work, f, scoped=False):
    d = T.tower(2, reading, work, f, scoped=scoped)
    d["monitors"].remove("T")
    d["boundary"].pop("T", None)
    for rel in mm.RELATIONS:
        d[rel].pop("T", None)
        d[rel] = {k: [m for m in v if m != "T"] for k, v in d[rel].items()}
    if scoped:
        d["scope"].pop("T")
        d["scope_work"].pop("top")
        d["told"] = {k: [m for m in v if m != "T"] for k, v in d["told"].items()}
    d["name"] = f"three rings, their coordinators in a cycle, no top coordinator, {reading}"
    return d


EXTRA_ORDERS = {
    "both-whole": "rings 2 and 3 whole, together in one step; then T",
    "top-with-D2": "T and D2 in one step; then ring 2's members and work; then ring 3",
    "top-with-ring-2": "T and the whole of ring 2 in one step; then ring 3 whole",
}


def extra_groups(order):
    r2 = ["A2", "B2", "C2", "D2", "W2"]
    r3 = ["A3", "B3", "C3", "D3", "W3"]
    if order == "both-whole":
        return [{"name": "rings 2 and 3", "members": r2 + r3, "after": []},
                {"name": "T", "members": ["T"], "after": ["W3"]}]
    if order == "top-with-D2":
        g = [{"name": "T and D2", "members": ["T", "D2"], "after": []}]
        for m in ("A2", "B2", "C2"):
            g.append({"name": m, "members": [m], "after": ["D2"]})
        g.append({"name": "W2", "members": ["W2"], "after": ["A2", "B2", "C2", "D2"]})
        g.append({"name": "D3", "members": ["D3"], "after": ["W2"]})
        for m in ("A3", "B3", "C3"):
            g.append({"name": m, "members": [m], "after": ["D3"]})
        g.append({"name": "W3", "members": ["W3"], "after": ["A3", "B3", "C3", "D3"]})
        return g
    if order == "top-with-ring-2":
        return [{"name": "T and ring 2", "members": ["T"] + r2, "after": []},
                {"name": "ring 3", "members": r3, "after": ["W2"]}]
    raise ValueError(order)


def growing(reading, order, f, scoped=False):
    d = T.tower(2, reading, "all", f, scoped=scoped)
    d["late"] = extra_groups(order)
    d["arrive_bad"] = True
    d["name"] = f"growth, {order}, {reading}"
    if scoped:
        d["freeze"] = True
    return d


def orders():
    print("== Three rings without the top coordinator, nothing joining, work reads all")
    for reading in R.READINGS:
        cells = []
        for f in (1, 2, 3):
            d = without_top(reading, "all", f)
            r = mm.explore(d, stop="gap")
            cells.append(f"f={f}: G1 {r['G1']}, G2 {r['G2']}")
            if f == 1 and r["G2"]:
                key = next(k for k in r["traces"] if k[0] == "G2")
                print(rows_text(d, r["traces"][key]))
        print(f"{reading}, as one system: " + "; ".join(cells), flush=True)
    print("\n== Orders outside the seven of part D (a newcomer may arrive bad)")
    for order, words in EXTRA_ORDERS.items():
        print(f"-- `{order}`: {words}")
        for reading in R.READINGS:
            cells = []
            for f in (1, 2, 3):
                d = growing(reading, order, f)
                r = mm.explore(d, stop="gap", max_states=2000000)
                assert not r["state_bounded"]
                if r["G1"] is None and r["G2"] is None:
                    cells.append(f"f={f}: no gap")
                else:
                    key = next(k for k in r["traces"] if k[0] in ("G1", "G2"))
                    rows = mm.replay(d, r["traces"][key])
                    which = [g for g in ("G1", "G2") if rows[-1][g]]
                    cells.append(f"f={f}: {' and '.join(which)} in {len(rows)} round(s), present "
                                 f"{D.stage_name(rows[-1]['present'])}")
                    if f == 1:
                        print(rows_text(d, r["traces"][key], indent="        "))
            print(f"{reading}, one system: " + "; ".join(cells), flush=True)
            d = growing(reading, order, 1, scoped=True)
            r = mm.explore(d, max_states=2500000)
            assert not r["bounded"]
            print(f"{reading}, scoped (freeze), f=1, every reachable state: {brief(r)}", flush=True)
            ks = sorted((k for k in r["traces"] if k[0] == "told"), key=lambda k: len(r["traces"][k]))
            if ks:
                print(f"        shortest execution breaking told of {ks[0][1]}:")
                print(rows_text(d, r["traces"][ks[0]], indent="        "))


def added():
    """systems-minimal-added.json and results-minimal-added.json: the systems these
    corrections rest on that the catalogue does not have."""
    import make_catalogue as MC
    cases = []

    def case(cid, d, max_rounds=None):
        d = MC.tidy(d)
        if max_rounds is not None:
            d["max_rounds"] = max_rounds
        cases.append({"id": cid, "system": d})

    split = ("along", "against", "along")       # the tail emits its signal, checks, reports
    case("added/reading/split/candidate/f1", R.ring_system(
        edges27(R.CANDIDATE, split), N4, "D", "all", 1,
        name="candidate; X->Y: Y reads X's signal, X checks Y's state, X reports to Y"))
    both_flag = ("against", "against", "both")  # actor's watching, a flag passes both ways
    eight = [("A", "B"), ("B", "A"), ("C", "A"), ("A", "D"), ("B", "D"), ("C", "D"),
             ("D", "B"), ("D", "C")]
    case("added/reading/watch-against-report-both/candidate/f1", R.ring_system(
        edges27(R.CANDIDATE, both_flag), N4, "D", "all", 1,
        name="candidate; X->Y: X watches Y, a flag passes both ways"))
    rep = [("fwd", m, "D") for m in "ABC"]
    fifteen = frozenset(rep + [("hb_readers", "A", "B"), ("hb_readers", "A", "C"),
                               ("hb_readers", "B", "A"), ("hb_readers", "B", "C"),
                               ("hb_readers", "C", "A"), ("hb_readers", "C", "B"),
                               ("hb_readers", "D", "A"), ("hb_readers", "D", "B"),
                               ("checkers", "A", "B"), ("checkers", "B", "A"),
                               ("checkers", "C", "A"), ("checkers", "D", "A")])
    for f in (1, 2, 3):
        case(f"added/r2-readers/fifteen-edges/f{f}", R.ring_system(
            fifteen, N4, "D", "all", f, name="15 edges: two signal readers each, one state "
            "check each, three reports to D"))
    case("added/r2-readers/fourteen-edges/f1", R.ring_system(
        fifteen - {("checkers", "D", "A")}, N4, "D", "all", 1,
        name="the 15 edges without the state check of D"))
    for reading in R.READINGS:
        for f in (1, 2, 3):
            case(f"added/no-top/{reading}/one/f{f}", without_top(reading, "all", f),
                 max_rounds=None if reading == "flow" else 1)
        for order in EXTRA_ORDERS:
            for f in (1, 2, 3):
                gap = order == "both-whole" and reading == "actor"
                case(f"added/grow/{order}/{reading}/one/f{f}", growing(reading, order, f),
                     max_rounds=2 if gap else None)
            case(f"added/grow/{order}/{reading}/scoped/f1", growing(reading, order, 1, True))
    answers = [{"id": c["id"], **mm.answer(c["system"], max_states=3000000)} for c in cases]
    with open(os.path.join(HERE, "systems-minimal-added.json"), "w", encoding="utf-8") as fh:
        fh.write("[\n" + ",\n".join(json.dumps(c) for c in cases) + "\n]\n")
    with open(os.path.join(HERE, "results-minimal-added.json"), "w", encoding="utf-8") as fh:
        fh.write("[\n" + ",\n".join(json.dumps(a) for a in answers) + "\n]\n")
    print(f"wrote {len(cases)} added cases and their answers")
    for a in answers:
        print("  ", json.dumps(a)[:230])


if __name__ == "__main__":
    for name in sys.argv[1:] or ["readings", "r2", "r5", "orders"]:
        globals()[name]()
