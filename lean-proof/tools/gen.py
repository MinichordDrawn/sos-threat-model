#!/usr/bin/env python3
"""Writes the Lean files under SelfObserving/Generated/ from check_model.py.

Standard library only, Python 3.9 or later. Run from anywhere:

    python -I -B tools/gen.py [--model-check DIR] [--out DIR] [--check]

--model-check DIR   the folder that holds check_model.py
                    (default: ../model-check, beside the project folder in the kit)
--out DIR           where to write (default: SelfObserving/Generated in the Lean project)
--check             write nothing; fail if a file on disk differs from what would be written,
                    or if the folder holds a Lean file the generator does not write

What it writes, for the reference system `reference()` and its ten removals
`reference(without=(X,))`:

  Fields.lean       each system as the Python object has it, field by field, and the
                    statement that the project's definition in Reference.lean equals it
  Executions.lean   for every goal the Python's explore() finds violated, its shortest
                    violating execution: the steps, and the state and the two goals after
                    each round
  States*.lean      for the four systems in which explore() finds a goal never violated:
                    every state explore() reaches, in the order it reaches them, the round
                    that first reaches each, and the numbers of states and of rounds

Nothing here decides anything. Each file states what the Python computes, and Lean has to
prove it. One number is counted here and not by check_model.py: the rounds, as one with
no step and one for each step of env_steps(), over the states that are not responded
(explore() merges the steps of a state that end in the same state, so it runs fewer).
The output depends only on check_model.py: two runs write the same bytes.
"""
import argparse
import hashlib
import os
import sys
from collections import deque

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(HERE)

MONS = ["M1", "M2", "M3"]
WKS = ["W1", "W2", "J"]
BOUNDARIES = {1: "b1", 2: "b2", 3: "b3"}
SUBSTRATES = {"s1": "s1", "s2": "s2", "s3": "s3", "s4": "s4", "s5": "s5"}

# Lean name, the argument `without` of reference()
SYSTEMS = [
    ("reference", ()),
    ("withoutP1", ("P1",)),
    ("withoutP2", ("P2",)),
    ("withoutP3", ("P3",)),
    ("withoutP4", ("P4",)),
    ("withoutP5", ("P5",)),
    ("withoutP6", ("P6",)),
    ("withoutP7", ("P7",)),
    ("withoutP8", ("P8",)),
    ("withoutP8b", ("P8b",)),
    ("withoutGate", ("gate",)),
]


def py_call(without):
    return "reference()" if not without else f"reference(without={without!r})"


# ---------------------------------------------------------------- Lean terms

def mon(m):
    assert m in MONS, m
    return f".{m}"


def wk(w):
    assert w in WKS, w
    return f".{w}"


def proc(p):
    return f".inl {mon(p)}" if p in MONS else f".inr {wk(p)}"


def step(e):
    kind, arg = e
    if kind == "stop":
        return f".stop {mon(arg)}"
    if kind == "stop-boundary":
        return f".stopBoundary .{BOUNDARIES[arg]}"
    if kind == "fail-substrate":
        return f".failSubstrate .{SUBSTRATES[arg]}"
    if kind == "mutate":
        return f".mutate ({proc(arg)})"
    if kind == "disable":
        return f".disable {mon(arg)}"
    if kind == "join":
        assert arg == "J"
        return ".join"
    raise ValueError(e)


def round_term(steps):
    """The environment's part of one round: no step, or one."""
    assert len(steps) <= 1, "the proofs are for one fault per round"
    if not steps:
        return "none"
    t = step(steps[0])
    return f"some ({t})" if " " in t else f"some {t}"


def round_text(steps):
    return ", ".join(f"{k} {a}" for k, a in steps) or "no step"


def bit(x):
    return "T" if x else "F"


def state(st):
    """A CState: alive, bad, hidden (M1 M2 M3, W1 W2 J each), off, flagged (M1 M2 M3),
    halted, pending (W1 W2 J), joined."""
    for xs in (st.alive, st.bad, st.hidden):
        assert set(xs) <= set(MONS + WKS), xs
    for xs in (st.off, st.flagged):
        assert set(xs) <= set(MONS), xs
    for xs in (st.halted, st.pending):
        assert set(xs) <= set(WKS), xs

    def ms(xs):
        return "⟨" + ",".join(bit(m in xs) for m in MONS) + "⟩"

    def ws(xs):
        return "⟨" + ",".join(bit(w in xs) for w in WKS) + "⟩"

    def ps(xs):
        return "⟨" + ms(xs) + "," + ws(xs) + "⟩"
    return ("⟨" + ", ".join([ps(st.alive), ps(st.bad), ps(st.hidden), ms(st.off),
                             ms(st.flagged), ws(st.halted), ws(st.pending),
                             bit(st.joined)]) + "⟩")


def header(cm_hash, what):
    return [
        "/-",
        "GENERATED FILE. Do not edit it: change tools/gen.py and run it again.",
        "",
        "Written by tools/gen.py from check_model.py of the model check",
        f"(SHA-256 {cm_hash}).",
        "",
    ] + what + ["-/"]


# ---------------------------------------------------------------- Fields.lean

def explicit_system(name, s):
    """The Python object, written out as a Lean `System`."""
    assert s.f == 1 and not s.slow_reports
    assert s.monitors == MONS and s.works == WKS[:2] and s.joiner == WKS[2]
    assert set(s.boundary) <= set(MONS) and set(s.substrate) <= set(MONS + WKS)
    assert set(s.hb_readers) <= set(MONS) and set(s.fwd) <= set(MONS)
    assert set(s.checkers) <= set(MONS + WKS) and set(s.halt_inputs) <= set(WKS)
    assert set(s.switches) <= set(MONS) and s.window in (0, 1)

    def opt(table, key, ids):
        return f"some .{ids[table[key]]}" if key in table else "none"
    hb = [(m, r) for m in MONS for r in s.hb_readers.get(m, ())]
    ck = [(x, m) for x in MONS + WKS for m in s.checkers.get(x, ())]
    fw = [(m, r) for m in MONS for r in s.fwd.get(m, ())]
    hi = [(w, m) for w in WKS for m in s.halt_inputs.get(w, ())]
    sw = [m for m in MONS if m in s.switches]
    out = [f"def {name} : System Mon Wk Bd Sub where",
           f"  f := {s.f}",
           f"  joiner := some {wk(s.joiner)}",
           "  boundary := fun m =>",
           "    match m with"]
    out += [f"    | {mon(m)} => {opt(s.boundary, m, BOUNDARIES)}" for m in MONS]
    out += ["  substrate := fun p =>",
            "    match p with"]
    out += [f"    | {proc(p)} => {opt(s.substrate, p, SUBSTRATES)}" for p in MONS + WKS]

    def field(name, vars_, parts):
        """One field, the disjuncts packed into lines of at most 100 characters."""
        if not parts:
            return [f"  {name} := fun {' '.join('_' for _ in vars_)} => False"]
        head = f"  {name} := fun {' '.join(vars_)} =>"
        body = " ∨ ".join(parts)
        if len(head) + 1 + len(body) <= 100:
            return [f"{head} {body}"]
        lines, cur = [head], "   "
        for i, part in enumerate(parts):
            piece = part + (" ∨" if i < len(parts) - 1 else "")
            if len(cur) + 1 + len(piece) > 100:
                lines.append(cur)
                cur = "   "
            cur += " " + piece
        lines.append(cur)
        return lines

    def pairs(v1, v2, ps, t1):
        return [f"({v1} = {t1(a)} ∧ {v2} = {mon(b)})" for a, b in ps]
    out += field("hbReaders", "mr", pairs("m", "r", hb, mon))
    out += field("checkers", "xm", pairs("x", "m", ck, proc))
    out += field("fwd", "mr", pairs("m", "r", fw, mon))
    out += field("haltInputs", "wm", pairs("w", "m", hi, wk))
    out += field("switches", "m", [f"m = {mon(m)}" for m in sw])
    out += [f"  coupling := {'true' if s.coupling else 'false'}",
            f"  window := {int(s.window)}",
            f"  gate := {'true' if s.gate else 'false'}",
            f"  slowReports := {'true' if s.slow_reports else 'false'}"]
    return out


def fields_file(cm, cm_hash):
    out = header(cm_hash, [
        "Each of the eleven systems as the Python object has it, field by field, and the",
        "statement that the project's definition in `Reference.lean` is that system. The",
        "Python's boundary ids 1, 2, 3 are `Bd.b1`, `Bd.b2`, `Bd.b3`, and its substrate ids",
        "`s1` to `s5` are `Sub.s1` to `Sub.s5`.",
    ])
    out += ["import SelfObserving.Proofs.Removals", "",
            "namespace SelfObserving", "namespace Py", ""]
    unfold = "referenceWith, Features.all"
    for name, without in SYSTEMS:
        s = cm.reference(without=without)
        p = f"SelfObserving.{name}"
        out.append(f"/-! ### `{py_call(without)}` -/")
        out.append("")
        out.append(f"/-- `{py_call(without)}` of check_model.py, written out. -/")
        out += explicit_system(name, s)
        out.append("")
        simp = f"simp [{p}, {name}, {unfold}]"

        def by_cases(*vs):
            return ["  " + " <;> ".join(f"cases {v}" for v in vs) + " <;>", f"    {simp}"]
        out += [
            f"theorem {name}_f : {p}.f = {name}.f := rfl",
            f"theorem {name}_joiner : {p}.joiner = {name}.joiner := rfl",
            f"theorem {name}_boundary (m : Mon) :",
            f"    {p}.boundary m = {name}.boundary m := by",
            "  cases m <;> rfl",
            f"theorem {name}_substrate (p : Proc Mon Wk) :",
            f"    {p}.substrate p = {name}.substrate p := by",
            "  cases p with",
            "  | inl m => cases m <;> rfl",
            "  | inr w => cases w <;> rfl",
            f"theorem {name}_hbReaders (m r : Mon) :",
            f"    {p}.hbReaders m r ↔ {name}.hbReaders m r := by",
            *by_cases("m", "r"),
            f"theorem {name}_checkers (x : Proc Mon Wk) (m : Mon) :",
            f"    {p}.checkers x m ↔ {name}.checkers x m := by",
            "  cases x with",
            "  | inl a =>",
            *["  " + line for line in by_cases("a", "m")],
            "  | inr w =>",
            *["  " + line for line in by_cases("w", "m")],
            f"theorem {name}_fwd (m r : Mon) :",
            f"    {p}.fwd m r ↔ {name}.fwd m r := by",
            *by_cases("m", "r"),
            f"theorem {name}_haltInputs (w : Wk) (m : Mon) :",
            f"    {p}.haltInputs w m ↔ {name}.haltInputs w m := by",
            *by_cases("w", "m"),
            f"theorem {name}_switches (m : Mon) :",
            f"    {p}.switches m ↔ {name}.switches m := by",
            *by_cases("m"),
            f"theorem {name}_coupling : {p}.coupling = {name}.coupling := rfl",
            f"theorem {name}_window : {p}.window = {name}.window := rfl",
            f"theorem {name}_gate : {p}.gate = {name}.gate := rfl",
            f"theorem {name}_slowReports :",
            f"    {p}.slowReports = {name}.slowReports := rfl",
            "",
            f"/-- `{name}` of `Reference.lean` is `{py_call(without)}`. -/",
            f"theorem {name}_eq : {p} = {name} :=",
            f"  Finite.system_ext {name}_f {name}_joiner {name}_boundary {name}_substrate",
            f"    {name}_hbReaders {name}_checkers {name}_fwd {name}_haltInputs",
            f"    {name}_switches {name}_coupling {name}_window {name}_gate",
            f"    {name}_slowReports",
            "",
        ]
    out += ["end Py", "end SelfObserving"]
    return out


# ---------------------------------------------------------------- Executions.lean

def run(cm, s, schedule):
    """The Python's own run of a schedule: the state and the goals after each round."""
    st = cm.initial(s)
    rounds = []
    for steps in schedule:
        assert not cm.responded(s, st)
        for e in steps:
            assert e in cm.env_steps(s, st)
            st = cm.apply_env(s, st, e)
        st, info = cm.process_phase(s, st)
        rounds.append((steps, st, info))
    return rounds


def executions_file(cm, cm_hash, results):
    out = header(cm_hash, [
        "For every goal that the Python's `explore()` finds violated in one of the eleven",
        "systems: the shortest violating execution it reports. Each statement gives the",
        "environment's step in each round, and what the Python computes after each round:",
        "the state, whether G1 is violated in the round, and whether G2 is. Lean runs the",
        "execution in the model (`Finite.ctrace`) and has to arrive at the same.",
        "",
        "Lean checks that each is an execution with these outcomes. That none is shorter is",
        "the Python's finding, and is not checked here.",
        "",
        "A state is written as 31 truth values, `T` or `F`, in this order: `alive`, `bad`,",
        "`hidden` (each M1 M2 M3, then W1 W2 J), `off`, `flagged` (M1 M2 M3), `halted`,",
        "`pending` (W1 W2 J), `joined`.",
    ])
    out += ["import SelfObserving.Proofs.Removals", "",
            "namespace SelfObserving", "namespace Py", "",
            "open Finite", "",
            'local notation "T" => true',
            'local notation "F" => false',
            ""]
    for name, without in SYSTEMS:
        s = cm.reference(without=without)
        first, _ = results[name]
        for goal in ("G1", "G2"):
            path = first[goal]
            if path is None:
                continue
            schedule = [tuple(steps) for steps, _ in path]
            rounds = run(cm, s, schedule)
            assert [info for _, _, info in rounds] == [info for _, info in path]
            assert rounds[-1][2][goal]
            n = len(rounds)
            g = goal.lower()
            out.append(f"/-- `{py_call(without)}`: {goal} is violated in round {n} of this "
                       f"execution.")
            for i, (steps, _, info) in enumerate(rounds, 1):
                out.append(f"Round {i}: {round_text(steps)}." + "".join(
                    f" {x} is violated." for x in ("G1", "G2") if info[x]))
            out[-1] += " -/"
            out.append(f"theorem {name}_{g}_trace :")
            out.append(f"    ctrace SelfObserving.{name} (cinit SelfObserving.{name})")
            out.append("      [" + ", ".join(round_term(steps) for steps, _, _ in rounds)
                       + "] = some [")
            for i, (_, st, info) in enumerate(rounds):
                out.append(f"  ⟨{state(st)},")
                out.append(f"    {bit(info['G1'])}, {bit(info['G2'])}⟩"
                           + ("," if i < n - 1 else "] := by"))
            out.append("  decide +kernel")
            out.append("")
    out += ["end Py", "end SelfObserving"]
    return out


# ---------------------------------------------------------------- States*.lean

def reach(cm, s):
    """The same search as explore(), keeping what it does not return: the states in the
    order they are first reached, and the round that first reaches each."""
    start = cm.initial(s)
    order, index, parent = [start], {start: 0}, {start: None}
    queue = deque([start])
    rounds = 0
    never = {"G1": True, "G2": True}
    while queue:
        st = queue.popleft()
        if cm.responded(s, st):
            continue
        rounds += 1 + len(cm.env_steps(s, st))     # no step, or any one enabled step
        for steps, after_env in cm.env_choices(s, st):
            t, info = cm.process_phase(s, after_env)
            for goal in never:
                if info[goal]:
                    never[goal] = False
            if t not in index:
                index[t] = len(order)
                order.append(t)
                parent[t] = (index[st], steps)
                queue.append(t)
    return order, parent, rounds, never


def states_file(cm, cm_hash, name, without, results):
    s = cm.reference(without=without)
    first, seen = results[name]
    order, parent, rounds, never = reach(cm, s)
    assert len(order) == seen and len(set(order)) == seen
    assert never == {g: first[g] is None for g in first}
    assert any(never.values())
    n1, n2 = ("true" if never[g] else "false" for g in ("G1", "G2"))
    goals = " or ".join(g for g in ("G1", "G2") if never[g])
    out = header(cm_hash, [
        f"`{py_call(without)}`: the {seen} states that the Python's `explore()` reaches, in",
        "the order it first reaches them. The statements:",
        "",
        f"- `{name}_covers`: the list holds the initial state; every round from a state of",
        "  the list that is not responded ends in a state of the list; and none of those",
        f"  rounds violates {goals}. Lean computes every such round in the model.",
        f"- `{name}_reached`: every state of the list is reached, by the round given for",
        f"  it in `{name}_parents`: the position in the list of the state the round starts",
        "  from, and the environment's step.",
        f"- `{name}_count`: the list has {seen} states, no two the same, and the rounds from",
        f"  those that are not responded number {rounds}: one with no step, and one for each",
        "  enabled step. The generator counts the rounds this way from `env_steps()`;",
        "  `explore()` merges the steps of a state that end in the same state, and runs",
        "  fewer.",
        "",
        "Lean checks these three statements. Of the order of the list they need only this:",
        "the initial state is first, and each later state comes after the state its round",
        "starts from. Lean does not check that the order is the order of the Python's",
        "search, or that the round given for a state is the first that reaches it.",
        "",
        "A state is written as 31 truth values, `T` or `F`, in this order: `alive`, `bad`,",
        "`hidden` (each M1 M2 M3, then W1 W2 J), `off`, `flagged` (M1 M2 M3), `halted`,",
        "`pending` (W1 W2 J), `joined`.",
    ])
    out += ["import SelfObserving.Proofs.Removals", "",
            "namespace SelfObserving", "namespace Py", "",
            "open Finite", "",
            'local notation "T" => true',
            'local notation "F" => false',
            "",
            f"/-- The states `explore()` reaches in `{py_call(without)}`. -/",
            f"def {name}_states : List CState := ["]
    for i, st in enumerate(order):
        out.append(f"  {state(st)}" + ("," if i < seen - 1 else "]"))
    out += ["",
            f"/-- For each state after the first: the round that first reaches it. -/",
            f"def {name}_parents : List (Nat × Option (EnvStep Mon Wk Bd Sub)) := ["]
    for i, st in enumerate(order[1:], 1):
        j, steps = parent[st]
        assert j < i
        out.append(f"  ({j}, {round_term(steps)})" + ("," if i < seen - 1 else "]"))
    p = f"SelfObserving.{name}"
    out += ["",
            f"theorem {name}_covers :",
            f"    covers {p} {name}_states {n1} {n2} = true := by",
            "  decide +kernel",
            "",
            f"theorem {name}_reached :",
            f"    reaches {p} {name}_states {name}_parents = true := by",
            "  decide +kernel",
            "",
            f"theorem {name}_count :",
            f"    {name}_states.length = {seen} ∧ distinct {name}_states = true ∧",
            f"      countRounds {p} {name}_states = {rounds} := by",
            "  decide +kernel",
            "",
            "end Py", "end SelfObserving"]
    return out, seen, rounds


# ---------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--model-check",
                    default=os.path.join(os.path.dirname(PROJECT), "model-check"))
    ap.add_argument("--out", default=os.path.join(PROJECT, "SelfObserving", "Generated"))
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()

    cm_path = os.path.join(args.model_check, "check_model.py")
    if not os.path.isfile(cm_path):
        sys.exit(f"check_model.py not found in {args.model_check}; give --model-check DIR")
    with open(cm_path, "rb") as fh:
        cm_hash = hashlib.sha256(fh.read()).hexdigest()
    sys.path.insert(0, os.path.abspath(args.model_check))
    import check_model as cm

    results = {name: cm.explore(cm.reference(without=without)) for name, without in SYSTEMS}
    files = {"Fields.lean": fields_file(cm, cm_hash),
             "Executions.lean": executions_file(cm, cm_hash, results)}
    summary = []
    for name, without in SYSTEMS:
        first, seen = results[name]
        res = ", ".join(f"{g} " + ("never" if first[g] is None else f"in round {len(first[g])}")
                        for g in ("G1", "G2"))
        if first["G1"] is None or first["G2"] is None:
            fname = "States" + name[0].upper() + name[1:] + ".lean"
            files[fname], seen2, rounds = states_file(cm, cm_hash, name, without, results)
            summary.append(f"{name}: {res}; {seen2} states, {rounds} rounds ({fname})")
        else:
            summary.append(f"{name}: {res}; {seen} states (not listed)")

    changed = []
    for fname in sorted(files):
        text = "\n".join(files[fname]) + "\n"
        data = text.encode("utf-8")
        path = os.path.join(args.out, fname)
        old = None
        if os.path.isfile(path):
            with open(path, "rb") as fh:
                old = fh.read()
        if old != data:
            changed.append(fname)
            if not args.check:
                os.makedirs(args.out, exist_ok=True)
                with open(path, "wb") as fh:
                    fh.write(data)
        print(f"{fname}: {len(files[fname])} lines, {len(data)} bytes"
              + ("" if old == data else " (differs)" if args.check else " (written)"))
    for line in summary:
        print(line)
    extra = sorted(os.path.relpath(os.path.join(d, f), args.out).replace(os.sep, "/")
                   for d, _, fs in os.walk(args.out) for f in fs
                   if f.lower().endswith(".lean") and not (d == args.out and f in files))
    for fname in extra:
        print(f"{fname}: not written by the generator")
    if args.check and (changed or extra):
        sys.exit("differs from what the generator writes: " + ", ".join(changed + extra))


if __name__ == "__main__":
    main()
