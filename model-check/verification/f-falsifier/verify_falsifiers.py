"""End-to-end check of the reported falsifiers, using ONLY the reference implementation
(model.py) and the definitions of task.md applied to the JSON form.  Nothing from plain.py or
census.py is used to judge a system here; those files only supplied the candidates.

For every candidate system S:
  1. S is plain (task.md).
  2. result(S) at f = 1 is G1 = null, G2 = null.
  3. Q1, Q3, Q4, Q8 evaluated on the JSON.
  4. For every monitor m: S - m built as task.md says; its result; m is spare iff both null.
     For a non-spare m the shortest violating execution of S - m is recorded.
  5. Every terminal system reachable by deleting spare monitors one at a time, in every
     order, and the predicates each one fails.
  6. The complete tree of executions of S (idle rounds are checked to change nothing and are
     left out), as the plain-words reason why no execution violates a goal.

Run:  python -I verify_falsifiers.py        -> falsifiers.json, falsifiers.txt
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import model


# ------------------------------------------------------------------ task.md on JSON
def is_plain(d):
    mons = d["monitors"]
    b = d.get("boundary") or {}
    return (d.get("joiner") is None and not (d.get("substrate") or {}) and not (d.get("switches") or [])
            and all(m in b and b[m] is not None for m in mons)
            and len(set(b[m] for m in mons)) == len(mons)
            and d["coupling"] is True and d["window"] == 0
            and d.get("gate", True) is True and d.get("slow_reports", False) is False)


def Q1(d):
    return all(any(r != m and r in d["monitors"] for r in (d.get("hb_readers") or {}).get(m, []))
               for m in d["monitors"])


def Q3(d):
    return all(any(c != x and c in d["monitors"] for c in (d.get("checkers") or {}).get(x, []))
               for x in d["monitors"] + d["works"])


def Q4(d):
    fwd = d.get("fwd") or {}
    for a in d["monitors"]:
        reach = {a}
        todo = [a]
        while todo:
            m = todo.pop()
            for r in fwd.get(m, []):
                if r in d["monitors"] and r not in reach:
                    reach.add(r)
                    todo.append(r)
        if reach != set(d["monitors"]):
            return False
    return True


def Q8(d):
    return all(len(set((d.get("halt_inputs") or {}).get(w, []))) >= 2 for w in d["works"])


def failing(d):
    return [n for n, q in (("Q1", Q1), ("Q3", Q3), ("Q4", Q4), ("Q8", Q8)) if not q(d)]


def delete(d, m):
    out = dict(d)
    out["monitors"] = [x for x in d["monitors"] if x != m]
    out["boundary"] = {k: v for k, v in d["boundary"].items() if k != m}
    for key in ("hb_readers", "checkers", "fwd", "halt_inputs"):
        out[key] = {k: [x for x in v if x != m] for k, v in d[key].items() if k != m}
    return out


def gap_free(d):
    r = model.result(dict(d, f=1), witness=False)
    return r["G1"] is None and r["G2"] is None


def terminals(d):
    spare = [m for m in d["monitors"] if gap_free(delete(d, m))]
    if not spare:
        return [d]
    out = []
    for m in spare:
        for t in terminals(delete(d, m)):
            if t not in out:
                out.append(t)
    return out


# ------------------------------------------------------------------ execution tree
def tree(S, st, indent, lines):
    for st_env, steps in model.env_phase(S, st).items():
        st_end, g1, g2, out = model.finish_round(S, st_env, st.flagged)
        if not steps:
            assert st_end == st and not g1 and not g2, "an idle round changed the state"
            continue
        label = " ".join(steps[0])
        text = (f"{indent}{label}: flagged={{{','.join(sorted(st_end.flagged))}}} "
                f"out={{{','.join(sorted(out))}}} halted={{{','.join(sorted(st_end.halted))}}}")
        if g1 or g2:
            lines.append(text + "  ** VIOLATION " + ("G1 " if g1 else "") + ("G2" if g2 else ""))
        elif model.responded(S, st_end):
            lines.append(text + "  -> responded, execution over")
        else:
            lines.append(text + "  -> not responded, next round:")
            tree(S, st_end, indent + "    ", lines)


def execution_tree(d):
    S = model.System(dict(d, f=1))
    lines = []
    tree(S, model.initial_state(S), "  ", lines)
    return lines


# ------------------------------------------------------------------ candidates
def strip(d):
    return {k: v for k, v in d.items() if not k.startswith("_")}


def candidates():
    out = []

    def take(fname, fam, howmany, tag):
        path = os.path.join(HERE, fname)
        if not os.path.exists(path):
            return
        res = json.load(open(path, encoding="utf-8"))
        info = res["families"].get(fam)
        if info:
            for i, s in enumerate(info["smallest"][:howmany]):
                out.append((f"{tag}-{i + 1}", strip(s)))

    take("result_2x1.json", "Q4", 1, "F2x1-Q4")
    take("result_3x1_par.json", "Q1+Q4", 3, "F3x1-Q1Q4")
    take("result_3x1_par.json", "Q1", 2, "F3x1-Q1")
    take("result_3x1_par.json", "Q4", 12, "F3x1-Q4")
    take("result_2x2.json", "Q4", 2, "F2x2-Q4")
    take("result_3x2_par.json", "Q1+Q4", 2, "F3x2-Q1Q4")
    take("result_3x2_par.json", "Q1", 2, "F3x2-Q1")
    take("result_3x2_par.json", "Q4", 2, "F3x2-Q4")
    take("census_4x1.json", "Q1+Q4", 2, "F4x1-Q1Q4")
    take("census_4x1.json", "Q1", 1, "F4x1-Q1")
    take("census_4x1.json", "Q4", 2, "F4x1-Q4")
    take("census_4x1_two_silent.json", "Q1+Q4", 2, "F4x1-two-silent-Q1Q4")
    take("census_4x1_two_silent.json", "Q1", 2, "F4x1-two-silent-Q1")
    # sampled larger systems (sample_large.py)
    path = os.path.join(HERE, "sample_large.json")
    if os.path.exists(path):
        for size, info in json.load(open(path, encoding="utf-8")).items():
            for fam, s in info["fewest_edge_examples"].items():
                out.append((f"S{size}-{fam.replace('+', '')}-sampled", strip(s)))
    # illustrations that are NOT expected to be no-spare falsifiers: systems with spare monitors
    path = os.path.join(HERE, "result_3x1_par.json")
    if os.path.exists(path):
        for v, s in json.load(open(path, encoding="utf-8")).get("fewest_edge_examples_with_spare_monitors", {}).items():
            out.append((f"I3x1-with-spare-{v}", strip(s)))
    return out


if __name__ == "__main__":
    report = []
    text = []
    n_fals = 0
    for cid, d in candidates():
        d = dict(d, f=1, name=cid)
        r = model.result(d)
        fails = failing(d)
        dels = {}
        for m in d["monitors"]:
            dm = delete(d, m)
            rm = model.result(dict(dm, f=1))
            spare = rm["G1"] is None and rm["G2"] is None
            dels[m] = {"spare": spare, "G1": rm["G1"], "G2": rm["G2"], "witness": rm.get("witness", {})}
        terms = terminals(d)
        term_fail = [failing(t) for t in terms]
        gapfree = r["G1"] is None and r["G2"] is None
        strict = is_plain(d) and gapfree and len(d["works"]) >= 1 and bool(fails) and all(term_fail)
        n_fals += strict
        edges = sum(len(v) for key in ("hb_readers", "checkers", "fwd", "halt_inputs") for v in d[key].values())
        tree_lines = execution_tree(d)
        report.append({
            "id": cid, "system": d, "plain": is_plain(d), "G1": r["G1"], "G2": r["G2"],
            "edges": edges, "failing": fails,
            "spare_monitors": [m for m in d["monitors"] if dels[m]["spare"]],
            "why_each_monitor_is_not_spare": {m: v for m, v in dels.items() if not v["spare"]},
            "terminal_systems_failing": term_fail,
            "falsifier": strict,
            "executions": tree_lines,
        })
        text.append(f"### {cid}  ({len(d['monitors'])} monitors, {len(d['works'])} work, {edges} edges)")
        text.append(json.dumps(d))
        text.append(f"plain={is_plain(d)}  G1={r['G1']} G2={r['G2']}  fails={'+'.join(fails) or 'none'}  "
                    f"spare={[m for m in d['monitors'] if dels[m]['spare']]}  falsifier={strict}")
        for m, v in dels.items():
            if not v["spare"]:
                g = "G1" if v["G1"] is not None and (v["G2"] is None or v["G1"] <= v["G2"]) else "G2"
                text.append(f"  without {m}: G1={v['G1']} G2={v['G2']}; shortest {g} violation: {v['witness'].get(g)}")
        text.append("  every execution (idle rounds change nothing and are omitted):")
        text.extend("  " + ln for ln in tree_lines)
        text.append("")
        print(f"{cid:28s} plain={is_plain(d)} G1={r['G1']} G2={r['G2']} edges={edges} fails={'+'.join(fails):6s} "
              f"spare={[m for m in d['monitors'] if dels[m]['spare']]} falsifier={strict}")
    json.dump(report, open(os.path.join(HERE, "falsifiers.json"), "w", encoding="utf-8"), indent=1)
    open(os.path.join(HERE, "falsifiers.txt"), "w", encoding="utf-8").write("\n".join(text))
    n_f = sum(1 for r in report if not r["id"].startswith("I"))
    n_f_ok = sum(1 for r in report if not r["id"].startswith("I") and r["falsifier"] and not r["spare_monitors"])
    print(f"{n_f_ok} of {n_f} no-spare falsifier candidates (ids F.., S..) confirmed by the reference implementation")
    print("illustrations with spare monitors (ids I..): " +
          ", ".join(f"{r['id']} falsifier={r['falsifier']}" for r in report if r["id"].startswith("I")))
