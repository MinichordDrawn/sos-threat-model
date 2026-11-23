#!/usr/bin/env python3
"""Printing executions round by round. Standard library only."""
import os
import sys

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mr_model as mm  # noqa: E402


def step_text(step):
    k, a = step
    if isinstance(a, (list, tuple)):
        a = " ".join(str(x) for x in a)
    return f"{k} {a}"


def rows_text(d, schedule, indent="   "):
    out = []
    scoped = bool(d.get("scope"))
    for i, row in enumerate(mm.replay(d, schedule), 1):
        if row.get("ended"):
            out.append(f"{indent}(the model had ended)")
            break
        env = ", ".join(step_text(s) for s in row["steps"]) or "(none)"
        if scoped:
            fl = "; ".join(f"for {s}: {' '.join(v)}" for s, v in row["flagged"].items()) or "-"
        else:
            fl = " ".join(row["flagged_any"]) or "-"
        broke = []
        for g in ("G1", "G2", "told"):
            if row[g]:
                broke.append(g + ("" if not scoped else " of " + ", ".join(str(x) for x in row[g])))
        if row["spill"]:
            broke.append("spill " + " ".join(row["spill"]))
        line = (f"{indent}round {i}: env: {env} | bad: {' '.join(row['bad']) or '-'} | stopped: "
                f"{' '.join(row['stopped']) or '-'} | flagged: {fl} | halted: "
                f"{' '.join(row['halted']) or '-'} | worked: {' '.join(row['worked']) or '-'}")
        if scoped:
            line += f" | closed: {', '.join(str(x) for x in row['closed']) or '-'}"
        if broke:
            line += "   <-- breaks " + "; ".join(broke)
        out.append(line)
    return "\n".join(out)


def show(d, key, title, r=None, **kw):
    """Print the shortest execution for a judgement. key is (kind, scope id), with scope
    None for a system without scopes and for spill."""
    if r is None:
        r = mm.explore(d, **kw)
    sched = r["traces"].get(key)
    print(f"\n-- {title}")
    if sched is None:
        print("   no such execution" + (" within the bound" if r["bounded"] else ""))
    else:
        print(rows_text(d, sched))
    return r


def brief(r):
    """One line for a result."""
    def n(v):
        return "-" if v is None else str(v)
    s = f"G1 {n(r['G1'])}, G2 {n(r['G2'])}"
    if any(k is not None for k in r["scopes"]):
        s += f", told {n(r['told'])}, spill {n(r['spill'])}"
        s += " [" + "; ".join(f"{k}: {n(v['G1'])}/{n(v['G2'])}/{n(v['told'])}"
                              for k, v in r["scopes"].items()) + "]"
    s += f" ({r['states']} states" + (f", bounded at {r['rounds']} rounds" if r["bounded"] else "") + ")"
    return s
