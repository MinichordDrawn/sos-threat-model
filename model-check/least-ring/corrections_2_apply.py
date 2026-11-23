#!/usr/bin/env python3
"""Applies corrections 2 to part-a.md and results-minimal.md and writes corrections-2.md
with every change as before and after text. It was run once and refuses to run again:
each "before" text must be found exactly once. The files as they were are
*.before-corrections-2.*. Line ends are kept as they were.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
A, RM = "part-a.md", "results-minimal.md"
CH = []


def ch(file, point, before, after):
    CH.append((file, point, before.strip("\n"), after.strip("\n")))


HEAD = r"""# Corrections 2

A second and last set of changes to `part-a.md`, `results-minimal.md` and the added
catalogue, after a fresh reader checked corrections 1
(`verify-corrections\handback.md`). That reader found the list of corrections 1
complete, every number as printed, and no result changed. `model-spec-scope.md` needed no
change and has none. The catalogue of 465 and its answers are unchanged.

The files as they were are beside this one: `part-a.before-corrections-2.md`,
`results-minimal.before-corrections-2.md`, `systems-minimal-added.before-corrections-2.json`
and `results-minimal-added.before-corrections-2.json`. Every change to the two write-ups
is given below as before and after text, and nothing else in them was changed.

## The six points, and what was done

I checked each against my own program first (`corrections_2.py`; outputs
`corrections-2-lemma.txt`, `corrections-2-order.txt`, `corrections-2-added.txt`). I found
the reader wrong on none.

| Point | Agreed | What was done |
|---|---|---|
| 1. Lemma M-scope fails as stated | yes. With my program: G1 of scope `r` is 4 rounds in `first` (none within 3) and 3 in `second`; with `freeze` false both give 4 | the class is narrowed to "no two monitors share a boundary and nothing runs on a substrate, or `freeze` is false"; the proof's first sentence is corrected; the counterexample is given as a table of rounds; one sentence says the two uses (sections 4.1 and 5.3) are in the narrower class, which I checked: thirteen monitors in thirteen boundaries and no substrate; five monitors in five boundaries, no substrate, no `freeze` (changes 3, 4, 5) |
| 2. `added/r2-readers/fifteen-edges` does not meet the whole list | yes: in it D observes nobody, so R3 fails | replaced, at `f` = 1, 2, 3, by the reader's set, which I verified meets the whole list at all three rates under either choice for R3; `added/r2-readers/fourteen-edges` is now that set without the state check of D (G1 and G2 in one round, as before). `verify-impl\model.py` run on the changed file agrees on every one of its 39 answers. No sentence of the write-ups presented the old system as a meeting set: the only example they print is the one in `corrections-1-r2.txt`, which does meet the list. The Files table's count is corrected (change 21) |
| 3. Looser than shown | yes, all four | change 26 of corrections 1: "six of the nine readings with the report both ways", and which (change 22). Change 12: told is judged in that round if the fault leaves something bad, and in no other; if the first fault is a stop, in no round (change 2). Change 14: needed by statement 1; used by the proof of statement 2; not shown of statement 2 itself (change 6). Change 19: Theorem J's "more than `f` initial monitors" is named and is met (change 13) |
| 4. Condition 2 under flow reads as a classification | yes. Recomputed the reader's second top-last order: no gap as one system under flow at `f` = 1, 2, 3, every reachable state | the verdict and section 5.1 say "at least two orders" and "sufficient cases and not a classification", and give the second order with its evidence. "With scopes, top-last leaves told violated" is said to be checked for one order, and the reader's argument for every top-last order is given and marked **Argued** (changes 11, 12) |
| 5. The verdict bullet's first half rests on own boundaries | yes | said in the bullet (change 1) |
| 6. Left behind | yes, all | the sentences on independent checking in both files now say what is true and what none of the three checks covered (changes 14, 15, 17, 24, 25); "under actor" has "with R5 read as the report edge" in sections 3 and 4.5 (changes 7, 9, 10); Lemma M and Lemma M-scope in section 6 (change 16); the wording on `freeze` in section 4.2 is the specification's (change 8); both "Not settled" lists name the choices in R2 and R5 (changes 18, 26); the sentence under the table of `part-a.md` section 4 says the further readings' rows were found the same at the other rates independently, not by me (change 23); the two table cells of section 4.3 (changes 19, 20) |

**The added catalogue.** `systems-minimal-added.json` now holds 39 systems: the 36 of
corrections 1 with the three `added/r2-readers/fifteen-edges/f1`, `f2`, `f3` and
`added/r2-readers/fourteen-edges/f1` replaced, and three new ones,
`added/grow/coordinators-together/flow/one/f1`, `f2`, `f3`, for the second top-last
order. Against the answers as they were, two answers changed (the fifteen-edge system at
`f` = 2 and 3 now has no gap, where the old one had G1 and G2 in one round) and three are
new. `verify-impl\model.py`, run by me on the 39, gives the same answer on each
(`results-minimal-added-by-verify-impl.json`, `corrections-2-added-verify-impl.txt`).
"""

# ------------------------------------------------------------------ results-minimal.md

ch(RM, "5 (the verdict's first half) and 4 (Condition 2 in the verdict)", r"""
  ring's work reads its four monitors, the same rate as one ring, at every number of
  levels (**proved**; **checked** at 13 and at 40 monitors). Judged scope by scope, a
""", r"""
  ring's work reads its four monitors, the same rate as one ring, at every number of
  levels when every monitor is in a boundary of its own (**proved**; **checked** at 13 and
  at 40 monitors). Judged scope by scope, a
""")
CH[-1] = (RM, "5 (the verdict's first half)", CH[-1][2], CH[-1][3])

ch(RM, "3 (change 12 of corrections 1: when told is judged)", r"""
  the hypotheses of section 4.3, told is judged in the round of the ring's first fault
  and in no other, because the ring's scope closes in that round.
""", r"""
  the hypotheses of section 4.3, told is judged in the round of the ring's first fault,
  if that fault leaves something bad, and in no other, because the ring's scope closes in
  that round. If the first fault is a stop with nothing bad, told is judged in no round.
""")

ch(RM, "1 (Lemma M-scope: the class)", r"""
**Lemma M-scope (more edges never hurt, scope by scope). Proved,** for any two systems of
`model-spec-scope.md` with no window that have the same processes, scopes, work, lists,
halt inputs and `freeze`, and differ only in that the second has more signal-read,
state-check or report edges.
""", r"""
**Lemma M-scope (more edges never hurt, scope by scope). Proved,** for any two systems of
`model-spec-scope.md` with no window, in which either no two monitors share a boundary
and nothing runs on a substrate, or `freeze` is false, that have the same processes,
scopes, work, lists, halt inputs and `freeze`, and differ only in that the second has
more signal-read, state-check or report edges.
""")

ch(RM, "1 (Lemma M-scope: the proof's first sentence)", r"""
*Proof.* Which processes are alive, bad or present after a sequence of environment steps
does not depend on those edges. Run one schedule in both systems.
""", r"""
*Proof.* In this class an environment step, where it is enabled, does the same in both
systems to which processes are alive, bad or present. With no shared boundary and no
substrate every step acts on one process or on one joining group, whatever is frozen; and
without `freeze` no step looks at what is closed. (With `freeze` and a shared boundary or
substrate this is false: `stop-boundary` and `fail-substrate` then pass over the frozen
processes, and which are frozen depends on the flags, which depend on the edges.) Run one
schedule in both systems.
""")

ch(RM, "1 (Lemma M-scope: the counterexample outside the class, and where the lemma is used)", r"""
catalogue differ by one halt input, and the second has a spill in one round where the
first has none. The searches of this note add no halt input.
""", r"""
catalogue differ by one halt input, and the second has a spill in one round where the
first has none. The searches of this note add no halt input.

Nor does it hold outside that class, where it was first stated here. **Checked** here
and independently; the reader of `verify-corrections\handback.md` found it. With `freeze`
true and four monitors in one boundary, one more signal read brings G1 of a scope from 4
rounds to 3. The system: `f` = 1; monitors x, m1, m2, m3, m4, z, zp, z2, y and work w; m1
to m4 share a boundary and every other monitor has its own; scopes p (x and m1), q (m2,
m3, m4), r (y), o (z, zp, z2) and one for w; z and zp read m1's signal, m2, m3 and m4
check y's state, and w takes its halt from m1. The second system has one edge more: z2
reads x's signal.

| Round | Environment | End of round in the second system | End of round in the first |
|---|---|---|---|
| 1 | stop x | z2 flagged for p; p has no work, so p closes; w working | nothing flagged; p open; w working |
| 2 | stop the boundary of m1 to m4 | m1 is frozen, so only m2, m3, m4 stop; nothing new flagged; w working | all four stop; z and zp flagged for p; w halted on m1's silence; the model ends |
| 3 | mutate y | y bad; its three checkers are stopped; nobody holds a flag for r | |

Breaks G1 of r in round 3 in the second system. In the first, no execution of at most 3
rounds breaks it (every one was explored), and the least is 4: stop m2; stop m3; stop m4;
mutate y. With `freeze` false both systems give 4.

The two places this note uses the lemma are in the narrower class. The towers of section
4.1 have thirteen monitors in thirteen boundaries and no substrate. The ring with a fifth
node of section 5.3 has five monitors in five boundaries, no substrate and no `freeze`.
""")

ch(RM, "3 (change 14 of corrections 1)", r"""
(up to 1 when it reads two). The boundary hypothesis is needed by statement 1, and by
statement 2 through it: with a base ring whole in one boundary statement 1 fails, by the
last table of this section.
""", r"""
(up to 1 when it reads two). The boundary hypothesis is needed by statement 1: with a
base ring whole in one boundary statement 1 fails, by the last table of this section. The
proof of statement 2 uses statement 1, and so uses the hypothesis; that statement 2
itself needs it is not shown.
""")

ch(RM, "6, item 2 (section 3)", r"""
So a wider ring under one coordinator is still least under actor, tied with more and more
""", r"""
So a wider ring under one coordinator is still least under actor with R5 read as the
report edge, tied with more and more
""")

ch(RM, "6, item 4 (section 4.2: the specification's wording for freeze)", r"""
  first complete response", scope by scope. With `freeze`, nothing more lands in or joins
  a closed scope; without it faults go on landing there, unjudged for that scope.
""", r"""
  first complete response", scope by scope. With `freeze`, no fault lands on a process of
  a closed scope and no step joins one; without it faults go on landing on its processes,
  unjudged for that scope.
""")

ch(RM, "6, item 2 (section 4.5)", r"""
*least* follows from Part A only in this sense and under actor: among structures built as
""", r"""
*least* follows from Part A only in this sense, and under actor with R5 read as the
report edge: among structures built as
""")
ch(RM, "6, item 2 (section 4.5, the flat ring)", r"""
- *Under actor with one coordinator nothing has fewer than 36.* **Counted:** twelve
  upward arrows, which are watches of T, and two arrows into each of the twelve others.
  So under actor the flat ring and the ring of rings tie at 3(`n` - 1), and what the ring
""", r"""
- *Under actor, with R5 read as the report edge, with one coordinator nothing has fewer
  than 36.* **Counted:** twelve
  upward arrows, which are watches of T, and two arrows into each of the twelve others.
  So under actor with that reading of R5 the flat ring and the ring of rings tie at
  3(`n` - 1), and what the ring
""")

ch(RM, "4 (Condition 2 in the verdict)", r"""
  untaken. Under flow it can be last, as one system, if rings 2 and 3 arrive whole in one
  step: no gap at one, two or three (**checked**). With scopes "told" is then violated
  in two rounds under either reading. And it need not be strictly first: in the same step
""", r"""
  untaken. Under flow it can be last, as one system: two top-last orders have no gap at
  one, two or three (**checked**), rings 2 and 3 arriving whole in one step, and their two
  coordinators arriving in one step before the members. Those are sufficient cases, not a
  classification of the orders. With scopes "told" is violated in two rounds under either
  reading in the first of them, the one top-last order checked with scopes; that it is
  violated in every top-last order is **argued** (section 5.1). And it need not be
  strictly first: in the same step
""")

ch(RM, "4 (section 5.1, under flow) and 4 (with scopes)", r"""
- *Under flow it can be last, as one system, if rings 2 and 3 arrive whole and together
  in one step.* Three rings without T have no gap at `f` = 1, 2 and 3 (**checked**), and
  order both-whole has none. Whole but one after the other it cannot be: that is order
  `whole` of the table above, which has G2 broken in one round while ring 3 is absent. Nor
  coordinator by coordinator: that is the goal's order, where D2 arrives with nobody to
  check it.
- *With scopes, top-last leaves told violated,* in two rounds under either reading in
  order both-whole (**checked**): the two rings join with D2 already bad, which closes
  ring 2; then A1 is mutated, D1 is flagged and reports to D2 and to nobody else, and D3
  is alive, correct and not told.
""", r"""
- *Under flow it can be last, as one system, in at least two orders.* Three rings without
  T have no gap at `f` = 1, 2 and 3 (**checked**), and order both-whole has none. Nor has
  a second top-last order, found by the reader of `verify-corrections\handback.md` and
  recomputed here: D2 and D3 in one step; then the six members one at a time in any
  order; then each work process once its three members are present; then T. It has no gap
  at `f` = 1, 2 and 3 in every reachable state (**checked**: `mr_model.py` and
  `verify-impl\model.py`, both run by me, finished it at all three rates, with 1,732,
  17,733 and 118,732 states; the reader reports the same from two programs at `f` = 1 and
  2 and from one at 3). These are sufficient cases and not a classification of the
  orders. Two top-last orders that do have a gap under flow: order `whole` of the table
  above, the rings whole but one after the other, with G2 broken in one round while ring
  3 is absent; and the goal's order, where D2 arrives with nobody to check it.
- *With scopes, top-last leaves told violated,* in two rounds under either reading in
  order both-whole (**checked**, for that one order): the two rings join with D2 already
  bad, which closes ring 2; then A1 is mutated, D1 is flagged and reports to D2 and to
  nobody else, and D3 is alive, correct and not told. For every order with T last it is
  **argued**, by the same reader, and not run: bring all three rings in, mutate D2, which
  closes ring 2, then mutate A1; D1 reports to D2 only, and D3 is not told.
""")

ch(RM, "3 (change 19 of corrections 1: Theorem J's third hypothesis)", r"""
  than `f` present halt inputs. Neither proof counts how many work processes are late or
  asks by which step one joined.
""", r"""
  than `f` present halt inputs. Theorem J asks besides for more than `f` initial
  monitors, which is met: ring 1's four are there from the start and `f` is at most 3.
  Neither proof counts how many work processes are late or asks by which step one joined.
""")

ch(RM, "6, item 1 (section 6: scopes, told and spill)", r"""
- **Scopes, told and spill by two implementations of one author.** `mr_model.py` and
""", r"""
- **Scopes, told and spill by two implementations of one author, and since by one of
  another party** (the item on independent checks, below). `mr_model.py` and
""")
ch(RM, "6, item 1 (section 6: the same item, its last sentences)", r"""
  under the orders that have many reachable states). That is a check on slips, not an
  independent opinion. The catalogue and the specification are there so that an
  independent one can be made.
""", r"""
  under the orders that have many reachable states). That is a check on slips, not an
  independent opinion. The independent one has since been made: the item on independent
  checks, below.
""")

ch(RM, "6, item 3 (section 6: Lemma M)", r"""
- **Lemma M** carries the kind by kind searches. Two of them were repeated without it:
""", r"""
- **Lemma M** carries the kind by kind searches, and Lemma M-scope of section 4.2 the
  halves of them made with scopes (sections 4.1 and 5.3). Two of them were repeated
  without either:
""")

ch(RM, "6 (section 6: 'No independent reader')", r"""
- **No independent reader.** The brief rules out starting other agents, so no part of
  this note has had the usual pass by a fresh verifier.
""", r"""
- **Independent checks, made after this note was first written.** An implementation
  written from the three specification files alone, by another party, gives the same
  answers on all 465 cases of the catalogue and on the added systems
  (`verify-impl\handback.md`; on the added systems it was run by me). An independent
  reader recomputed the tables and the counterexamples with a
  program of their own (`verify-reader\handback.md`). A second reader checked the
  corrections (`verify-corrections\handback.md`). What none of them checked, from their
  own lists:
  - thirteen monitors with scopes at `f` = 3 beyond two rounds, and without freeze beyond
    six rounds at `f` = 1, two at 2 and one at 3;
  - forty monitors with scopes beyond three rounds at `f` = 1 and one round at 2 and 3,
    except runs confined to one chain and random runs;
  - whether a wiring of thirteen has fewer than 33 or 26 connections;
  - the rows of `part-a-kinds.txt` beyond those printed in `part-a.md` section 3.2;
  - for the further readings of an arrow, the 63 combinations and the kind by kind
    labels, and readings in which different arrows carry different things;
  - Lemma M-scope in its narrower class beyond reading the proof and 3,800 random pairs;
  - `nested`, `sufficient_f1` and `restart_game` of `check_model.py` as programs, and the
    Lean proofs: the statements were read;
  - the parts of the model that no system of the catalogue uses (the joiner, substrates,
    switches, slow edges, the window, the order without the gate), beyond the examples of
    the specifications and 400 random systems on which the implementer's two programs
    agree;
  - the author's list and goal in their own words, which were not in the readers'
    folders.
""")

ch(RM, "6, item 5 (section 7, Not settled)", r"""
- **Which reading of an arrow the drawing means.** The verdict on the candidate turns on
  it. Nothing in the model decides it.
""", r"""
- **Which reading of an arrow the drawing means.** The verdict on the candidate turns on
  it. Nothing in the model decides it. The verdict also turns on one choice each in R2
  (what an observer is) and in R5 (the member's report edge, or D watching each member),
  and nothing in the model decides those either.
""")

ch(RM, "6 (section 4.3, the table at f = 4)", r"""
| 1 | mutate A1, B1, C1, D1 | those four bad; D2, D3, T flagged for ring 1; W1, W2, W3 all working |
""", r"""
| 1 | mutate A1, B1, C1, D1 | those four bad; every monitor of rings 2 and 3 and T flagged for ring 1; W1, W2, W3 all working |
""")
ch(RM, "6 (section 4.3, the table with ring boundaries)", r"""
| 2 | stop the boundary of ring 3, stop T | every monitor stopped; W3 halted on silence; nothing flagged |
""", r"""
| 2 | stop the boundary of ring 3, stop T | every monitor stopped; W3 halted on silence; no live monitor holds a flag (the stopped monitors of ring 3 and T still hold theirs) |
""")

ch(RM, "2 (Files table: the added catalogue) and the files of corrections 2", r"""
| `systems-minimal-added.json`, `results-minimal-added.json` | 36 systems those corrections rest on that the catalogue does not have, and their answers. The catalogue and its answers are unchanged |
""", r"""
| `systems-minimal-added.json`, `results-minimal-added.json` | 39 systems the corrections rest on that the catalogue does not have, and their answers: the 36 of corrections 1, with the fifteen-edge system replaced by corrections 2 by one that meets the whole list, and three more for the second top-last order of section 5.1. The catalogue and its answers are unchanged |
| `corrections-2.md`, `*.before-corrections-2.*`, `corrections_2.py`, `corrections-2-lemma.txt`, `corrections-2-order.txt`, `corrections-2-added.txt` | the second and last set of corrections, as before and after text; the files as they were; the recomputations behind them |
""")

# ------------------------------------------------------------------ part-a.md

ch(A, "3 (change 26 of corrections 1: the verdict's last bullet)", r"""
- *The further readings of an arrow* (section 2.6) give "one over" where a flag passes
  both ways along a connection, "least" where only one of the watching kinds is sent both
""", r"""
- *The further readings of an arrow* (section 2.6) give "one over" where the watching
  runs one way and a flag passes both ways along a connection (six of the nine readings
  with the report both ways), "least" where only one of the watching kinds is sent both
""")

ch(A, "6, item 6 (section 4, the sentence under the table)", r"""
This holds with the work reading all at `f` = 1, 2 and 3 and with the work reading two at
`f` = 1. With the work reading two at `f` = 2 or 3 nothing meets R1 or R6.
""", r"""
This holds with the work reading all at `f` = 1, 2 and 3 and with the work reading two at
`f` = 1. For the two rows marked `f` = 1, the further readings of section 2.6, that is
not from my runs, which were at `f` = 1 with the work reading all: the reader of
`verify-corrections\handback.md` ran them at `f` = 2 and 3 and with the work reading two
at `f` = 1 and found the least numbers and the verdicts on the candidate the same. With
the work reading two at `f` = 2 or 3 nothing meets R1 or R6.
""")

ch(A, "6, item 1 (section 6: told)", r"""
- **Told has one author so far.** It is a new judgement (`model-spec-scope.md`, written
  for a second implementation to be compared). A second, plain implementation by the same
  hand (`scope_naive.py`) agrees on the catalogue cases it was run on
  (`results-minimal.md` section 6). It enters
""", r"""
- **Told now has a second author.** It is a new judgement (`model-spec-scope.md`). An
  implementation written from the three specification files alone, by another party,
  gives the same answers, told among them, on all 465 cases of the catalogue and on the
  added systems (`results-minimal.md` section 6). It enters
""")

ch(A, "6 (section 6: 'No independent reader')", r"""
- **No independent reader has checked this part.** The brief rules out starting other
  agents, so the usual pass by a fresh verifier was not made.
""", r"""
- **Independent checks, made after this part was first written.** An independent reader
  recomputed the tables and the counterexamples of this part with a program of their own,
  and a second reader checked the corrections made after that. What none of them checked
  is listed in `results-minimal.md` section 6.
""")

ch(A, "6, item 5 (section 7, Not settled)", r"""
- Which reading of an arrow the drawing means. The verdict turns on it, and nothing in
  the model can decide it.
""", r"""
- Which reading of an arrow the drawing means. The verdict turns on it, and nothing in
  the model can decide it. It also turns on one choice each in R2 (section 3.5) and in R5
  (section 2.7), and nothing in the model decides those either.
""")


def main():
    raw = {f: open(os.path.join(HERE, f), "rb").read() for f in (A, RM)}
    crlf = {f: b"\r\n" in raw[f] for f in raw}
    texts = {f: raw[f].decode("utf-8").replace("\r\n", "\n") for f in raw}
    for i, (f, point, before, after) in enumerate(CH, 1):
        n = texts[f].count(before)
        if n != 1:
            sys.exit(f"change {i} ({f}: {point}): the before text occurs {n} times; nothing written")
        texts[f] = texts[f].replace(before, after)
    for f, t in texts.items():
        if crlf[f]:
            t = t.replace("\n", "\r\n")
        with open(os.path.join(HERE, f), "wb") as fh:
            fh.write(t.encode("utf-8"))
    out = [HEAD.strip("\n"), "", "## Every change, as before and after text", ""]
    for i, (f, point, before, after) in enumerate(CH, 1):
        out += [f"### Change {i}. `{f}`", "", f"For point {point}.", "", "Before:", "",
                "````text", before, "````", "", "After:", "", "````text", after, "````", ""]
    with open(os.path.join(HERE, "corrections-2.md"), "wb") as fh:
        fh.write("\n".join(out).encode("utf-8"))
    print(f"{len(CH)} changes applied; corrections-2.md written")
    for i, (f, point, _, _) in enumerate(CH, 1):
        print(i, f, "|", point)


if __name__ == "__main__":
    main()
