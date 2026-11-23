#!/usr/bin/env python3
"""The computations behind corrections-2.md, with mr_model.py.

Run:  python -B corrections_2.py SECTION ...   sections: lemma classes fifteen order added
"""
import json
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import mr_ring as R  # noqa: E402
import mr_model as mm  # noqa: E402
import mr_tower as T  # noqa: E402
import part_c as C  # noqa: E402
import corrections_1 as C1  # noqa: E402
from mr_show import rows_text  # noqa: E402

N4 = R.NODES4


def lemma():
    print("== The reader's counterexample to Lemma M-scope as first stated")
    cases = json.load(open(os.path.join(HERE, "verify-corrections",
                                        "lemma-m-scope-counterexample.json"), encoding="utf-8"))
    print("ids in the file:", [c["id"] for c in cases])
    pair = {"first": cases[0]["system"], "second": cases[1]["system"]}
    for name in ("first", "second"):
        d = pair[name]
        extra = {r: {k: sorted(set(v) - set(pair["first"].get(r, {}).get(k, [])))
                     for k, v in d.get(r, {}).items()} for r in mm.RELATIONS}
        extra = {r: {k: v for k, v in e.items() if v} for r, e in extra.items()}
        print(f"-- {name}: f={d['f']}, freeze={d.get('freeze')}, boundary={d['boundary']}, "
              f"edges not in first: { {r: e for r, e in extra.items() if e} }")
        for bound in (3, 4):
            d2 = dict(d, max_rounds=bound)
            r = mm.explore(d2, max_states=1500000)
            assert not r["state_bounded"]
            print(f"   every execution of at most {bound} rounds: G1 of r "
                  f"{r['scopes']['r']['G1']}; all: "
                  + "; ".join(f"{s}: {v['G1']}/{v['G2']}" for s, v in r["scopes"].items())
                  + f" ({r['states']} states)")
            if r["scopes"]["r"]["G1"] and bound == 4:
                print(rows_text(d, r["traces"][("G1", "r")]))
        for freeze in (False,):
            d2 = dict(d, max_rounds=4, freeze=freeze)
            r = mm.explore(d2, max_states=1500000)
            print(f"   with freeze false, at most 4 rounds: G1 of r {r['scopes']['r']['G1']}")
    sched = [[("stop", "x")], [("stop-boundary", "b")], [("mutate", "y")]]
    for name in ("second", "first"):
        print(f"-- the same three steps in {name}:")
        try:
            print(rows_text(pair[name], sched))
        except ValueError as e:
            print("   ", e)


def classes():
    print("== Are the systems of sections 4.1 and 5.3 in the lemma's narrower class?")
    rings, base = T.layout(2)
    for reading in R.READINGS:
        core = set()
        for lv, ms, c in rings:
            core |= C.least19(reading, ms, c)
        d = T.tower(2, reading, "all", 1, edges=core, scoped=True)
        ids = [json.dumps(d["boundary"][m]) for m in d["monitors"]]
        print(f"section 4.1, {reading}: {len(d['monitors'])} monitors, {len(set(ids))} different "
              f"boundaries, substrates {d['substrate']}; adding edges changes neither")
    E = R.edges_of(R.CANDIDATE, "flow")
    d = R.ring_system(E, N4 + ["N"], "D", "all", 1)
    ids = [json.dumps(d["boundary"][m]) for m in d["monitors"]]
    print(f"section 5.3: {len(d['monitors'])} monitors, {len(set(ids))} different boundaries, "
          f"substrates {d['substrate']}, freeze {d.get('freeze', False)}")


FIFTEEN = frozenset(
    [("fwd", m, "D") for m in "ABC"]
    + [("hb_readers", "A", "B"), ("hb_readers", "A", "C"), ("hb_readers", "B", "A"),
       ("hb_readers", "B", "C"), ("hb_readers", "C", "A"), ("hb_readers", "C", "D"),
       ("hb_readers", "D", "A"), ("hb_readers", "D", "B"),
       ("checkers", "A", "B"), ("checkers", "B", "C"), ("checkers", "C", "D"),
       ("checkers", "D", "A")])


def fifteen():
    print("== A set of fifteen edges that meets the whole list (the reader's)")
    E = FIFTEEN
    print("edges:", "; ".join(R.edge_text(e) for e in sorted(E)))
    print("two signal readers each:", C1.r2_readers(E, N4), "| R3, observes = reads the signal:",
          R.r3(E, N4, "D", "signal"), "| R3, observes = watches:", R.r3(E, N4, "D"),
          "| R5:", R.r5(E, N4, "D"))
    for f in (1, 2, 3):
        print(f"   f={f} (G1, G2, told):", R.run(R.ring_system(E, N4, "D", "all", f)))
    print("   without the state check of D, f=1:",
          R.run(R.ring_system(E - {("checkers", "D", "A")}, N4, "D", "all", 1)))


def order_groups():
    g = [{"name": "D2 and D3", "members": ["D2", "D3"], "after": []}]
    for i in (2, 3):
        for m in (f"A{i}", f"B{i}", f"C{i}"):
            g.append({"name": m, "members": [m], "after": [f"D{i}"]})
        g.append({"name": f"W{i}", "members": [f"W{i}"],
                  "after": [f"A{i}", f"B{i}", f"C{i}"]})
    g.append({"name": "T", "members": ["T"], "after": ["W2", "W3"]})
    return g


def growing(reading, f):
    d = T.tower(2, reading, "all", f)
    d["late"] = order_groups()
    d["arrive_bad"] = True
    d["name"] = f"growth, coordinators-together, {reading}"
    return d


def order():
    print("== A second top-last order: D2 and D3 in one step; the six members one at a time")
    print("== in any order; each work process once its three members are present; then T")
    for reading in ("flow",):
        for f in (1, 2, 3):
            d = growing(reading, f)
            r = mm.explore(d, stop="gap", max_states=2200000)
            print(f"{reading}, one system, f={f}: G1 {r['G1']}, G2 {r['G2']}, {r['states']} states, "
                  f"{'BOUNDED by states: not a result' if r['state_bounded'] else 'every reachable state'}",
                  flush=True)


def added():
    p = os.path.join(HERE, "systems-minimal-added.json")
    cases = json.load(open(p, encoding="utf-8"))
    import make_catalogue as MC
    new = {}
    for f in (1, 2, 3):
        new[f"added/r2-readers/fifteen-edges/f{f}"] = MC.tidy(R.ring_system(
            FIFTEEN, N4, "D", "all", f, name="15 edges that meet the whole list: two signal "
            "readers each, one state check each, three reports to D"))
    new["added/r2-readers/fourteen-edges/f1"] = MC.tidy(R.ring_system(
        FIFTEEN - {("checkers", "D", "A")}, N4, "D", "all", 1,
        name="those 15 edges without the state check of D"))
    out = []
    for c in cases:
        out.append({"id": c["id"], "system": new.pop(c["id"], c["system"])})
    assert not new
    extra = [f for f in sys.argv if f.startswith("--order-rates=")]
    rates = [int(x) for x in extra[0].split("=")[1].split(",")] if extra else []
    for f in rates:
        out.append({"id": f"added/grow/coordinators-together/flow/one/f{f}",
                    "system": MC.tidy(growing("flow", f))})
    answers = [{"id": c["id"], **mm.answer(c["system"], max_states=3000000)} for c in out]
    with open(p, "w", encoding="utf-8") as fh:
        fh.write("[\n" + ",\n".join(json.dumps(c) for c in out) + "\n]\n")
    with open(os.path.join(HERE, "results-minimal-added.json"), "w", encoding="utf-8") as fh:
        fh.write("[\n" + ",\n".join(json.dumps(a) for a in answers) + "\n]\n")
    print(f"wrote {len(out)} added cases and their answers")
    for a in answers:
        if "fifteen" in a["id"] or "fourteen" in a["id"] or "coordinators-together" in a["id"]:
            print("  ", json.dumps(a))


if __name__ == "__main__":
    for name in [a for a in sys.argv[1:] if not a.startswith("--")]:
        globals()[name]()
