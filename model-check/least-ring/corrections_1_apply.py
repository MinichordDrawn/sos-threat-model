#!/usr/bin/env python3
"""Applies corrections 1 to part-a.md, results-minimal.md and model-spec-scope.md, and
writes corrections-1.md with every change as before and after text.

It was run once. It refuses to run again: each "before" text must be found exactly once.
The before-copies of the three files are *.before-corrections-1.md.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
A, RM, SP = "part-a.md", "results-minimal.md", "model-spec-scope.md"
CH = []   # (file, finding, before, after)


def ch(file, finding, before, after):
    CH.append((file, finding, before.strip("\n"), after.strip("\n")))


# ------------------------------------------------------------------ shared new text

READINGS_TABLE = r"""
| Reading of X -> Y | How many of the 27 | Fewest for the whole list | The candidate |
|---|---|---|---|
| flow, its mirror, and the four that differ from them by sending one of the two watching kinds both ways | 6 | 8 (24 wirings) | meets the list; one over |
| actor, its mirror, and the four that differ from them in the same way | 6 | 9 (26 wirings) | least |
| watching one way as in any of those twelve, a flag passing both ways along a connection | 6 | 8 (54 wirings) | meets the list; one over |
| the signal read and the state check run opposite ways (for one of them: Y reads X's signal, X checks Y's state, X reports to Y), the report one way | 4 | 9 (3 wirings) | does not meet R2 as stated: each member has only D both reading and checking it |
| the same, a flag passing both ways | 2 | 9 (6 wirings) | does not meet R2 as stated |
| the signal and the state both ways, the report one way or both | 3 | 5 (12 wirings; 96 with the report both ways) | meets the list; four over |

Under the six readings in which the signal read and the state check run opposite ways,
if R2 is counted as two readers and two checkers by any nodes, nine are still the fewest
(11 wirings with the report one way, 38 with it both ways), and the candidate meets the
list at `f` = 1, 2 and 3 and is least. A reading in which an arrow is observation only
has no report edge at all, and no wiring then meets R5 as stated.
"""

R2_TABLE = r"""
| An observer is | Fewest edges for the whole list | Sets that meet it at `f` = 1, 2, 3 |
|---|---|---|
| one node that both reads the signal and checks the state (R2 as stated) | 19 | 78, 78, 69 |
| a reader or a checker: two readers and two checkers, any nodes | 19 | 5,004, 5,004, 2,469 |
| a signal reader, in R2 and in R3 | 15 | 6,318, 2,340, 96 |

The 15 are eight signal reads, three reports to D and one state check of each monitor.
R1 forces the four checks: a monitor nobody checks is a gap at `f` = 1 (with the check of
D left out of one such set, G1 and G2 are violated in one round). With R3 kept as
"watches" and only R2 read as signal readers the fewest is still 15, in 1,152, 576 and 96
sets. The second and third rows were done by listing all 6,561 sets of the fewest size
(the reads and checks, or the reads and one checker each, chosen freely, and the three
reports) and exploring each, without Lemma M. With the work reading two the second row
has 3,336 sets at `f` = 1.
"""

# ------------------------------------------------------------------ results-minimal.md

ch(RM, "reader, further readings; items 7 and 8 (verdict on the candidate)", r"""
**Verdict on the candidate: least under one reading of an arrow, one connection over
under the other.** If `X -> Y` means "X observes Y and reports to Y", nine connections
are the fewest that meet the whole list and the candidate is one of six shapes that have
nine. If `X -> Y` means "what X shows and says goes to Y", eight are enough, and the
candidate is the eight plus one of the coordinator's downward arrows, which nothing on the
list forces in a single ring. Kind by kind the list needs 19 edges, and the candidate's
arrows carry them with eight to spare. In both readings the count comes from R2 and R5
alone.
""", r"""
**Verdict on the candidate: it turns on what an arrow is taken to carry, and on one
choice each in R2 and R5. Of the 27 readings in which an arrow carries all three kinds of
edge, the candidate is least under six, one connection over under twelve, short of R2 as
stated under six, and four over under three.** Each kind can run along the arrow,
against it, or both ways. Two of the readings are worked through in full (every rate,
both wirings of the work, every combination of requirements); all 27 are run for the
whole list at one fault per round with the work reading all (section 2).

- *actor* (`X -> Y`: X observes Y and reports to Y), its mirror, and four close to them:
  nine connections are the fewest that meet the whole list, and the candidate is one of
  six shapes that have nine. This is with R5 read as the member's report edge to the
  coordinator. With R5 read as the coordinator watching each member, eight are enough
  under actor too, and the candidate is one over.
- *flow* (`X -> Y`: what X shows and says goes to Y), its mirror, and four close to them:
  eight are enough, and the candidate is the eight plus one of the coordinator's downward
  arrows, which nothing on the list forces in a single ring.
- *Watching one way, a flag passing both ways along a connection* (six readings): eight
  are enough; the candidate meets the list and is one over.
- *The signal read and the state check run opposite ways,* as when each of the three is
  something the tail of the arrow does: it emits its signal, it checks, it reports (six
  readings). The candidate does not meet R2 as stated, because each member then has only
  the coordinator both reading and checking it. If R2 is counted as two readers and two
  checkers by any nodes, the candidate meets the list and is least, at nine.
- *The signal and the state both ways* (three readings): five are enough.

Kind by kind the list needs 19 edges when an observer is one node that both reads the
signal and checks the state, which is how R2 is stated here, and the candidate's arrows
carry them with eight to spare. It needs 15 when an observer is a signal reader. Under
flow and under actor the count comes from R2 and R5 alone.
""")

ch(RM, "reader, item 1 (verdict, 'What holds')", r"""
  halted, every execution of six rounds when it may), and the halt half of it holds at up
  to three faults per round at every number of levels (**proved**).
""", r"""
  halted, every execution of six rounds when it may), and the halt half of it holds at up
  to three faults per round at every number of levels when every monitor is in a boundary
  of its own (**proved**).
""")

ch(RM, "reader, item 4 (verdict, Condition 2)", r"""
- *Condition 2: the top coordinator joins first, not last.* Grown in the order the goal
  gives (each new ring coordinator first, the top coordinator last), there is a gap at one
  fault per round under either reading: the second ring's coordinator arrives with nobody
  to check it, or with nobody to report to. Grown with the top coordinator first, which is
  "coordinator first" applied to the upper ring too, there is no gap at one, two or three
  faults per round as one system (**proved** and **checked**), and none scope by scope at
  one (**checked**).
""", r"""
- *Condition 2: the order the goal gives has a gap, and with the top coordinator first
  there is none.* Grown in the order the goal gives (each new ring coordinator first, the
  top coordinator last), there is a gap at one fault per round under either reading: the
  second ring's coordinator arrives with nobody to check it, or with nobody to report to.
  Grown with the top coordinator first, which is "coordinator first" applied to the upper
  ring too, there is no gap at one, two or three faults per round as one system (**proved**
  and **checked**), and none scope by scope at one (**checked**). That is what is
  established, among the ten orders tried (section 5.1). It is not that the top
  coordinator must be first. Under actor it cannot be last in any order, as one system:
  three rings without it have a gap at one fault per round, and its join can be left
  untaken. Under flow it can be last, as one system, if rings 2 and 3 arrive whole in one
  step: no gap at one, two or three (**checked**). With scopes "told" is then violated
  in two rounds under either reading. And it need not be strictly first: in the same step
  as the second ring's coordinator, or as the whole second ring, is enough (**checked**).
""")

ch(RM, "reader, item 8 (verdict, 'always minimal': names the reading and the choice)", r"""
  least among structures built as rings of rings in which each ring meets the list by
  itself, under the first reading of an arrow. It is not the least for thirteen nodes as
  one system: 33 connections meet R1 to R5 under either reading when R2 is counted over
  the whole system, and 26 do under the second reading with one coordinator.
""", r"""
  least among structures built as rings of rings in which each ring meets the list by
  itself, under actor with R5 read as the report edge. It is not the least for thirteen
  nodes as one system: 33 connections meet R1 to R5 under flow and under actor when R2 is
  counted over the whole system, and 26 do under flow with one coordinator.
""")

ch(RM, "reader, further readings (section 1)", r"""
flow the candidate is the "cycle, checking coordinator" of `results-join.md`, edge for
edge. In both readings D and each member watch each other and report to each other.
""", r"""
flow the candidate is the "cycle, checking coordinator" of `results-join.md`, edge for
edge. In both readings D and each member watch each other and report to each other.

These two are the readings worked through in full. They are not the only fair ones:
each of the three kinds can run along the arrow, against it, or both ways, which makes
27, and section 2 gives what each does to the verdict.
""")

ch(RM, "reader, items 7 and 8 (section 1, the requirements)", r"""
| R2 | every monitor is watched by at least two others |
""", r"""
| R2 | every monitor is watched by at least two others. A watcher is one node that both reads the signal and checks the state. That is a choice; the others are in section 2 |
""")

ch(RM, "reader, item 8 (section 1, the requirements)", r"""
| R5 | each member has a report edge to D |
""", r"""
| R5 | each member has a report edge to D. The other choice, D watches each member, is in section 2 |
""")

ch(RM, "reader, item 10", r"""
The numbers for the whole list are the same at `f` = 2 and 3 with the work reading all
(under flow six of the 24 fall out at `f` = 3), and at `f` = 1 with the work reading two.
With the work reading two nothing meets R1 or R6 at `f` = 2.
""", r"""
The least numbers for the whole list, 8 and 9, are the same at `f` = 2 and 3 with the
work reading all (under flow six of the 24 wirings fall out at `f` = 3), and at `f` = 1
with the work reading two. The counts beside them are not the same there: with the work
reading two it is 22 wirings in 11 shapes under flow and 26 in 14 under actor. With the
work reading two nothing meets R1 or R6 at `f` = 2.
""")

ch(RM, "reader, item 7 (section 2, kind by kind)", r"""
all 81 candidates without Lemma M. The whole list needs **19 edges**: eight signal reads
and eight state checks (two watchers each, R2) and three reports to D (R5). 78 sets of 19
""", r"""
all 81 candidates without Lemma M. The whole list needs **19 edges**: eight signal reads
and eight state checks (two watchers each, R2) and three reports to D (R5). That figure
is for R2 as stated, a watcher being one node that does both; the other choices are
below. 78 sets of 19
""")

ch(RM, "reader, further readings and items 7 and 8 (section 2: three new paragraphs, and the verdict)", r"""
**The verdict.** Under actor: least, tied with five other shapes of nine. Under flow:
not least; four shapes of eight, one of them the candidate without one downward arrow.
""", r"""
**Further readings of an arrow. Checked** here, and independently by the reader of
`verify-reader\handback.md`, who reported it first. Every wiring, `f` = 1, the work
reading all, R2, R3 and R5 as stated. An arrow carries all three kinds, and each kind
runs along the arrow (Y reads X's signal; Y checks X's state; X reports to Y), against
it, or both ways: 27 readings, with 7 different outcomes.
""" + READINGS_TABLE + r"""
**R2's other choices. Checked** here, and independently by the same reader, who reported
it first. R2 as stated takes an observer to be one node that both reads the signal and
checks the state. Between connections under flow or actor that choice cannot show,
because a connection carries both. Kind by kind it decides the figure.
""" + R2_TABLE + r"""
**R5's other choice. Checked** here, and independently by the same reader, who reported
it first. R5 is read here as the member's report edge to D. Under the other choice, "D
watches each member", the whole list needs 8 connections under flow and under actor
alike: 24 wirings in 4 shapes at `f` = 1 and 2 and 18 in 3 at `f` = 3 with the work
reading all, 22 in 11 shapes at `f` = 1 with the work reading two. The candidate meets
the list and is one over. So "least under actor" is for R5 as the report edge.

**The verdict.** Under actor, with R5 as the report edge: least, tied with five other
shapes of nine. Under flow: not least; four shapes of eight, one of them the candidate
without one downward arrow. Under the further readings and the other choices of R2 and
R5: as the three paragraphs above give it.
""")

ch(RM, "reader, item 2 (section 4.1)", r"""
**Kind by kind. Checked,** complete by Lemma M over the spare edges. Give every ring,
upper ring included, only its 19 edges (76 in all).
""", r"""
**Kind by kind. Checked,** complete over the spare edges: by Lemma M for the half "as
one system", and for the half "with scopes" by its scoped form, Lemma M-scope of section
4.2. Give every ring, upper ring included, only its 19 edges (76 in all).
""")

ch(RM, "reader, scope specification note 3 (section 4.2: when told is judged)", r"""
  scope. For ring `i` the list is the rest of the upper ring: the other two coordinators
  and T.
""", r"""
  scope. For ring `i` the list is the rest of the upper ring: the other two coordinators
  and T. The top scope has no list. Like G1 and G2 of a scope, told is judged only in a
  round at whose end something of the scope is bad and the scope is still open. So a stop
  alone is never a violation of any of the three, and for a base ring of the tower, under
  the hypotheses of section 4.3, told is judged in the round of the ring's first fault
  and in no other, because the ring's scope closes in that round.
""")

ch(RM, "reader, item 2 (section 4.2: the scoped lemma, stated and proved)", r"""
one process and nothing else changes with it, so the assumption is built in. Nothing here
proves it of any real system.
""", r"""
one process and nothing else changes with it, so the assumption is built in. Nothing here
proves it of any real system.

**Lemma M-scope (more edges never hurt, scope by scope). Proved,** for any two systems of
`model-spec-scope.md` with no window that have the same processes, scopes, work, lists,
halt inputs and `freeze`, and differ only in that the second has more signal-read,
state-check or report edges. For each scope and each of G1, G2 and told, and for spill,
the least number of rounds to violate it in the second is at least that in the first.
The argument is the reader's (`verify-reader\handback.md`, check 4). I went through it
and agree with it.

*Proof.* Which processes are alive, bad or present after a sequence of environment steps
does not depend on those edges. Run one schedule in both systems. By induction on rounds,
the second's flags for every scope, its halted set and its closed set contain the
first's: detection and propagation only gain from more edges, a work process that sees a
reason to halt in the first sees it in the second, and a scope that closes in the first
closes in the second. With `freeze`, a step enabled in the second is enabled in the
first, because the second has frozen at least as much. A state that is responded in the
first is responded in the second. So every schedule the second can run, the first can
run. If a round violates G1, G2 or told of a scope in the second, then in the first that
scope is open too, the same processes are bad, no more monitors hold its flag, and a work
process that steps in the second has not halted and steps: the same round violates it in
the first. For spill: a halt on a flag for a covering scope is never a spill, since such
a flag was raised on a fault in that scope and faults stay. So a spill in the second is a
halt on the silence of a halt input, and the same process, which has not halted in the
first, halts there on the same silence in the same round, with the same processes
faulty. ∎

It does not hold for added halt-input edges. `example/1` and `example/4` of the
catalogue differ by one halt input, and the second has a spill in one round where the
first has none. The searches of this note add no halt input.
""")

ch(RM, "reader, item 1 (section 4.3: the hypothesis the three statements need)", r"""
**Proved,** for a tower of any number of levels, either reading, with or without
`freeze`, a ring coordinator's own fault landing in its own ring's scope, at every `f` up
to 3 when each ring's work reads its four monitors (up to 1 when it reads two):
""", r"""
**Proved,** for a tower of any number of levels, either reading, every monitor in a
boundary of its own, with or without `freeze`, a ring coordinator's own fault landing in
its own ring's scope, at every `f` up to 3 when each ring's work reads its four monitors
(up to 1 when it reads two). The boundary hypothesis is needed by statement 1, and by
statement 2 through it: with a base ring whole in one boundary statement 1 fails, by the
last table of this section.
""")

ch(RM, "reader, item 6", r"""
Breaks G1 of ring 3 (`f` = 2, each base ring in one boundary). This is Theorem 0 of
`results.md`: a loss as wide as the system. Four steps remove thirteen monitors.
""", r"""
Breaks G1 of ring 3 (`f` = 2, each base ring in one boundary). Four steps over two
rounds stop all thirteen monitors, and nothing is left to flag the mutation. It is a
loss as wide as the system. Neither part of Theorem 0 of `results.md` applies to it as
stated: `f` is less than the number of monitors, and no one step stops them all.
""")

ch(RM, "reader, item 9", r"""
**Proved,** at `f` = 1, with each base ring whole in one boundary, any number of levels
from two: no gap. The four conditions of Theorem S hold (`theorem_S`, Lean), and the loss
of a whole base ring is read by the coordinator above it, from which report edges reach
every monitor outside the ring without passing through it, which is the boundary clause
of `theorem_S_wide` (Lean). The conditions were also evaluated by `sufficient_f1` of
`check_model.py` on towers of 1 to 4 levels (4, 13, 40 and 121 monitors): they hold.
""", r"""
**Proved,** at `f` = 1, with each base ring whole in one boundary, any number of levels
from two: no gap. The four conditions (a) to (d) of Theorem S hold, and the loss of a
whole base ring is read by the coordinator above it, from which report edges reach every
monitor outside the ring without passing through it, which is the boundary clause of
`theorem_S_wide` (Lean). The conclusion comes from `theorem_S_wide` alone: `theorem_S`
is for plain systems, and a system with a ring in one boundary is not plain.

What was evaluated by program is narrower than that. `sufficient_f1` of `check_model.py`
tests conditions (a) to (d) and nothing else; it does not look at boundaries. It was run
on towers of 1 to 4 levels (4, 13, 40 and 121 monitors), under each reading and each
wiring of the work: (a) to (d) hold in all sixteen. The boundary clause was not
evaluated by program. It is the argument of the paragraph above, and it is for two
levels or more: for one level, a single ring whole in one boundary, it cannot hold, and
there is a gap (Theorem 0 of `results.md`, part 2).
""")

ch(RM, "reader, item 1 (section 4.6)", r"""
**With scopes, every level.** The three statements of section 4.3 are proved for every
number of levels. What is not: told, and G1 of an upper scope.
""", r"""
**With scopes, every level.** The three statements of section 4.3 are proved for every
number of levels, with every monitor in a boundary of its own. What is not: told, and G1
of an upper scope.

The scopes at forty monitors are the tower's, as at thirteen: one for each base ring,
one for each middle coordinator, whose work is all the work beneath it, and one for T,
whose work is all the work. The list of a base ring is the other two coordinators of the
ring above it and that ring's coordinator (for ring 3: D1, D2 and E1). The list of a
middle coordinator's scope is the other two middle coordinators and T. The top scope has
no list. `model-spec-scope.md` does not fix any of this; `mr_tower.py` builds it.
""")

ch(RM, "reader, scope specification note 2 (section 5.1: a ring hit while it is being built)", r"""
**With the top coordinator first there is no gap.** T is the upper ring's coordinator,
and "a ring joins coordinator first" (`results-join.md`, the conditions of its verdict)
applied to the upper ring puts T before the upper ring's second member. Then every new
ring coordinator arrives with T watching it, watched by it and reporting both ways.
""", r"""
**With the top coordinator first there is no gap.** T is the upper ring's coordinator,
and "a ring joins coordinator first" (`results-join.md`, the conditions of its verdict)
applied to the upper ring puts T before the upper ring's second member. Then every new
ring coordinator arrives with T watching it, watched by it and reporting both ways.

**What the rows with scopes include.** A scope whose work has not yet joined closes as
soon as a live correct monitor holds its flag (`model-spec-scope.md`, X7). So a ring that
is hit while it is being built is closed at once. With `freeze`, which these rows have,
nothing more can then join that ring, and a ring that must wait for it never joins.
"Nothing violated" under the top-first orders includes those executions, in which growth
stops. It is not a statement that growth completes.

**What the table does and does not establish.** Among the seven orders, the goal's order
has a gap and the top-first orders have none. It does not follow that the top coordinator
must be first. Three more orders were run. The first was reported by the reader of
`verify-reader\handback.md` and is recomputed here; all three are **checked** here and
independently, as one system at `f` = 1, 2 and 3, and with scopes and freeze at `f` = 1
in every reachable state.

| Order | As one system, flow | As one system, actor | With scopes, `f` = 1, flow and actor |
|---|---|---|---|
| both-whole: rings 2 and 3 whole, together in one step; then T | no gap at `f` = 1, 2, 3 | G2 in 1 round at each rate | G1, G2 not violated; told in 2 rounds |
| top-with-D2: T and D2 in one step; then A2, B2, C2, then W2; then D3, its members, W3 | no gap at `f` = 1, 2, 3 | no gap at `f` = 1, 2, 3 | nothing violated |
| top-with-ring-2: T and the whole of ring 2 in one step; then ring 3 whole | no gap at `f` = 1, 2, 3 | no gap at `f` = 1, 2, 3 | nothing violated |

So the condition, as it now stands:

- *Under actor the top coordinator cannot be last in any order, as one system.* Three
  rings with their coordinators in a cycle and no T have G2 broken in one round at
  `f` = 1, 2 and 3 (**checked**):

  | Round | Environment | End of round |
  |---|---|---|
  | 1 | mutate D1 | D1 bad; A1, B1, C1 and ring 3's four flagged; W1, W3 halted; W2 working |

  Under actor D1 is the one coordinator that reports to D2. In any order that has T last,
  the joins can bring all three rings in with T's join left untaken, and a round of joins
  alone raises no flag. So either there is a gap before that, or this execution follows
  (**proved** from the check, for every order with T last).
- *Under flow it can be last, as one system, if the rings arrive whole.* Three rings
  without T have no gap at `f` = 1, 2 and 3 (**checked**), and order both-whole has none.
  Coordinator by coordinator it cannot be: that is the goal's order, where D2 arrives
  with nobody to check it.
- *With scopes, top-last leaves told violated,* in two rounds under either reading in
  order both-whole (**checked**): the two rings join with D2 already bad, which closes
  ring 2; then A1 is mutated, D1 is flagged and reports to D2 and to nobody else, and D3
  is alive, correct and not told.
- *It need not be strictly first.* In the same step as D2, or as the whole of ring 2, is
  enough.
""")

ch(RM, "reader, item 3 (section 5.2: Theorem J's class)", r"""
  four halt sources. At `f` = 1 Theorem S in every set of present processes covers it
  too. This is the first three rows of the table in `results-join.md` section 8 with a
  ring of rings in place of two rings.
""", r"""
  four halt sources. At `f` = 1 Theorem S in every set of present processes covers it
  too. This is the first three rows of the table in `results-join.md` section 8 with a
  ring of rings in place of two rings.

  The class is wider than the one those statements name. Theorem J and "Theorem S in
  every set of present processes" are stated in `results-join.md` for plain systems with
  joins, which have late monitors and the model's one joiner. The grown tower has two
  late work processes, which only X1 of `model-spec-scope.md` allows. Their proofs carry
  over as they stand. Each takes the first round with a fault and uses only the set of
  processes then present: that its monitors are connected by mutual pairs (or meet (a)
  to (d)), and that each work process then present has a present state checker and more
  than `f` present halt inputs. Neither proof counts how many work processes are late or
  asks by which step one joined. With that said the result is **proved**; it is also
  **checked**.
""")

ch(RM, "reader, the sentence false as written (section 5.2)", r"""
  Under actor D2 is checked and read by D1, but has no report target present, so Theorem
  L's hypothesis fails, and of the least attachment of a joining ring's coordinator
  (section 8 there: checked, read, reporting to one; and watching one that reports back)
  it has only half under either reading. That section's execution "nothing comes back to
  ring B" is the one above.
""", r"""
  Under actor D2 is checked and read by D1, but has no report target present, so Theorem
  L's hypothesis fails. Of the least attachment of a joining ring's coordinator (section
  8 there: checked, read and reporting to one; and watching one that reports back) D2 has
  exactly the second half under flow. Under actor it has neither half whole: it is
  checked and read but does not report, and it is reported to but does not watch. The
  execution above under actor (D2 joins; A2 joins bad; D2 is flagged; W1 goes on working)
  is the one `results-join.md` section 4.2 gives for a missing "N reports to X": the flag
  exists and goes nowhere. Section 8's own execution, "nothing comes back to ring B", is
  not this one. It is the mirror case: a fault in the old ring, which the new ring's work
  does not hear of.
""")

ch(RM, "reader, item 2 (section 5.3)", r"""
between N and the four, complete by Lemma M.
""", r"""
between N and the four, complete by Lemma M and, for told, by Lemma M-scope of section
4.2.
""")

ch(RM, "the files these corrections add (Files table)", r"""
| `part_a_recheck.py`, `part-a-recheck.txt` | Part A's table recomputed with `mr_model.py` as it stands at the end |
""", r"""
| `part_a_recheck.py`, `part-a-recheck.txt` | Part A's table recomputed with `mr_model.py` as it stands at the end |
| `corrections-1.md`, `*.before-corrections-1.md` | every change made after the two independent checks, as before and after text, and the three files as they were |
| `corrections_1.py`, `corrections-1-readings.txt`, `corrections-1-r2.txt`, `corrections-1-orders.txt`, `corrections-1-added.txt` | the recomputations behind those corrections: the 27 readings, R2's and R5's other choices, the three further join orders |
| `systems-minimal-added.json`, `results-minimal-added.json` | 36 systems those corrections rest on that the catalogue does not have, and their answers. The catalogue and its answers are unchanged |
""")

# ------------------------------------------------------------------ part-a.md

ch(A, "reader, further readings (verdict, first lines)", r"""
**Verdict on the candidate: it depends on what an arrow carries, and the answer is
different under the two readings an arrow allows.**
""", r"""
**Verdict on the candidate: it depends on what an arrow carries. Two readings are worked
through in full below and give different answers. They are not the only fair ones: of
the 27 readings in which an arrow carries all three kinds of edge, the candidate is least
under six, one connection over under twelve, short of R2 as stated under six, and four
over under three (section 2.6).**
""")

ch(A, "reader, item 8 (verdict, first lines)", r"""
- *If an arrow X -> Y means "X observes Y and reports to Y"* (called **actor** below): the
  candidate is **least, tied with five others**. Nine connections are the fewest that meet
""", r"""
- *If an arrow X -> Y means "X observes Y and reports to Y"* (called **actor** below): the
  candidate is **least, tied with five others**, with R5 read as the member's report edge.
  (With R5 read as "D watches each member", eight are enough under actor too: section
  2.7.) Nine connections are the fewest that meet
""")

ch(A, "reader, item 7 (verdict, first lines)", r"""
- *Kind by kind,* the fewest edges for the whole list are 19: eight signal reads and
  eight state checks (R2) and three reports to the coordinator (R5). The candidate's nine
""", r"""
- *Kind by kind,* the fewest edges for the whole list are 19: eight signal reads and
  eight state checks (R2) and three reports to the coordinator (R5). That is for an
  observer that is one node both reading the signal and checking the state, which is how
  R2 is stated here; with an observer read as a signal reader the fewest are 15 (section
  3.5). The candidate's nine
""")

ch(A, "reader, further readings (verdict, first lines: a new point)", r"""
  the candidate is one of three least shapes. This is noted and not relied on: section 1.3
  says why it is a reading and not the Lean statement.
""", r"""
  the candidate is one of three least shapes. This is noted and not relied on: section 1.3
  says why it is a reading and not the Lean statement.
- *The further readings of an arrow* (section 2.6) give "one over" where a flag passes
  both ways along a connection, "least" where only one of the watching kinds is sent both
  ways under actor, and "does not meet R2 as stated" where the signal read and the state
  check run opposite ways.
""")

ch(A, "reader, further readings (section 1.2)", r"""
reports its flag to `r`. "A connection X -> Y carries everything in that direction" can be
taken two ways, and both are done.
""", r"""
reports its flag to `r`. "A connection X -> Y carries everything in that direction" can be
taken in more than two ways. Two are done in full, here and in every section below. The
others are run for the whole list at `f` = 1 in section 2.6.
""")

ch(A, "reader, item 7 (section 1.3, R2)", r"""
| **R2** | Every one of the four nodes has at least two other nodes that both read its signal and check its state. | "Node" is a monitor. The work has no signal and is not counted. |
""", r"""
| **R2** | Every one of the four nodes has at least two other nodes that both read its signal and check its state. | "Node" is a monitor. The work has no signal and is not counted. An observer is taken to be one node that does both: reads the signal and checks the state. The other choices (a signal reader; two readers and two checkers by any nodes) change the kind by kind figure and are in section 3.5. |
""")

ch(A, "reader, item 8 (section 1.3, R5)", r"""
| **R5** | Each of A, B, C has a report edge to D. | "Connected directly so that its flag reaches the coordinator in one hop" is the report edge. D watching a member is not that: it carries the member's state to D, not the member's flag. |
""", r"""
| **R5** | Each of A, B, C has a report edge to D. | "Connected directly so that its flag reaches the coordinator in one hop" is the report edge. D watching a member is not that: it carries the member's state to D, not the member's flag. The numbers under that other choice are in section 2.7: with it the candidate is not least under actor either. |
""")

ch(A, "reader, further readings and item 8 (new sections 2.6 and 2.7)", r"""
## 3. Connections kind by kind
""", r"""
### 2.6 The further readings of an arrow

Flow and actor are the two readings in which the watching runs one way and the report
runs along the arrow. They are not the only fair ones. Each of the three kinds can run
along the arrow (Y reads X's signal; Y checks X's state; X reports to Y), against it, or
both ways: 27 readings. Flow is along, along, along. Actor is against, against, along.

**Checked** here (`corrections_1.py`, `corrections-1-readings.txt`), and independently by
the reader of `verify-reader\handback.md`, who reported it first: all 27, every one of the
4,096 wirings, `f` = 1, W reading all, R2, R3 and R5 as section 1.3 states them. There
are 7 different outcomes.
""" + READINGS_TABLE + r"""
So a third reading does change the verdict. If an arrow says who observes whom and a flag
passes either way along a connection, the candidate is one over even with actor's
direction of watching. If each of the three is something the tail of the arrow does
(it emits its signal, it checks, it reports), the candidate does not meet R2 as stated.
These readings were run for the whole list at `f` = 1 only, and for the candidate at
`f` = 2 and 3 where it meets the list; the 63 combinations, the other wiring of the work
and the kind by kind labels were not redone for them.

### 2.7 The other choice for R5

**Checked** here (`corrections-1-orders.txt`, its first lines), and independently by the
same reader, who reported it first. Read R5 as "D watches each of A, B, C" and ask for no
report. Then the whole list needs **8 connections under flow and under actor alike**: 24
wirings in 4 shapes at `f` = 1 and 2 and 18 in 3 shapes at `f` = 3 with W reading all, 22
in 11 shapes at `f` = 1 with W reading two. The candidate meets the list and is one over
under both. One of the eight under actor:

```
A -> B, C, D     B -> A, D     D -> A, B, C
```

So "least under actor" is a statement for R5 as the report edge.

## 3. Connections kind by kind
""")

ch(A, "reader, item 7 (section 3.2)", r"""
**The whole list is 19 edges: R2's sixteen and R5's three. Counted** as a lower bound,
""", r"""
**The whole list is 19 edges: R2's sixteen and R5's three, for R2 as stated (section 3.5
has its other choices). Counted** as a lower bound,
""")

ch(A, "reader, item 7 (new section 3.5); and the verdict table of section 4", r"""
## 4. The verdict on the candidate

| Reading of an arrow | Fewest connections for the whole list | The candidate (nine) | Others as small |
|---|---|---|---|
| flow | 8 | not least | four shapes of eight (section 2.3) |
| actor | 9 | least | tied with five other shapes (section 2.3) |
""", r"""
### 3.5 The other choices for R2

R2 as stated takes an observer to be one node that both reads the signal and checks the
state. That is a choice. Between connections under flow or actor it cannot show, because
a connection carries both kinds. Kind by kind it decides the figure.

**Checked** here (`corrections_1.py`, `corrections-1-r2.txt`), and independently by the
reader of `verify-reader\handback.md`, who reported it first. W reads all.
""" + R2_TABLE + r"""
So "19 edges" is the figure for an observer that both reads and checks, the same node
doing both. What the candidate's arrows must carry under the other two choices was not
worked out.

## 4. The verdict on the candidate

| Reading of an arrow | Fewest connections for the whole list | The candidate (nine) | Others as small |
|---|---|---|---|
| flow | 8 | not least | four shapes of eight (section 2.3) |
| actor, R5 as the report edge | 9 | least | tied with five other shapes (section 2.3) |
| actor, R5 as "D watches each member" | 8 | not least | four shapes of eight (section 2.7) |
| watching one way, a flag passing both ways (`f` = 1) | 8 | not least | 54 wirings of eight (section 2.6) |
| the signal read and the state check opposite ways (`f` = 1) | 9 | does not meet R2 as stated; least if R2 is two readers and two checkers by any nodes | section 2.6 |
""")

ch(A, "reader, item 7 (section 4, the verdict table)", r"""
| kind by kind | 19 edges | its arrows carry 27; 19 of them are enough | 78 sets of 19 (52 where the work reads two) |
""", r"""
| kind by kind, an observer both reading and checking | 19 edges | its arrows carry 27; 19 of them are enough | 78 sets of 19 (52 where the work reads two) |
| kind by kind, an observer a signal reader | 15 edges | not worked out on its arrows | 6,318 sets of 15 at `f` = 1 (section 3.5) |
""")

ch(A, "reader, item 5", r"""
level up needs it is Part C. (Added when Part C was done: it does. `results-minimal.md`
section 4.1: in the upper ring every member must watch the coordinator once scopes are
judged, and as one system the upper ring needs reports this ring does not.)
""", r"""
level up needs it is Part C. (Added when Part C was done, and since corrected: only in
part. `results-minimal.md` section 4.1: as one system the upper ring needs reports this
ring does not. Under actor those include the coordinator's reports to its members. Under
flow three reports along the upper cycle are enough, with none from the coordinator. With
scopes no downward report is needed at all; what is needed there is that every member of
the upper ring watches the coordinator.)
""")

ch(A, "the files these corrections add (Files table)", r"""
| `part_a_brute.py`, `part-a-brute.txt` | the two checks that do not use Lemma M |
""", r"""
| `part_a_brute.py`, `part-a-brute.txt` | the two checks that do not use Lemma M |
| `corrections_1.py`, `corrections-1-readings.txt`, `corrections-1-r2.txt`, `corrections-1-orders.txt` | sections 2.6, 2.7 and 3.5, added by `corrections-1.md` |
""")

# ------------------------------------------------------------------ model-spec-scope.md

ch(SP, "implementer, 3A, and reader, item 11 (X1 against J1, J2, J3)", r"""
## X1. A work process may join in a group (adds to J1 and J3)

A member of a group may also be a name listed in `works`. Such a work process is a *late
work process*: it is absent at the start, it becomes present when its group's `join g` or
`join-bad g m` step is taken, and from then on it is a work process like any other. It is
not in `alive` initially and is added to `alive` by its group's step, like every member.
An entry of `after` that names a late work process is satisfied once that process is
present. `join-bad g m` still requires `m` to be a late monitor.

Nothing else in `model-spec-join.md` changes. In particular J5 applies to the edges at a
""", r"""
## X1. A work process may join in a group (replaces sentences of J1, J2 and J3)

A member of a group may also be a name listed in `works`. Such a work process is a *late
work process*: it is absent at the start, it becomes present when its group's `join g` or
`join-bad g m` step is taken, and from then on it is a work process like any other. It is
not in `alive` initially and is added to `alive` by its group's step, like every member.
`join-bad g m` still requires `m` to be a late monitor. A late work process is not the
`joiner`: the `joiner` is still one name that is not listed in `works`.

This replaces four passages of `model-spec-join.md`. Each is to be read as given here and
not as printed there.

1. J1, the table of a group, the row `members`. Read: "each member is a name in
   `monitors`, a name in `works`, or the `joiner`".
2. J1, the two sentences "An entry of `after` may name any process of the system. One
   that names an initial monitor or a process listed in `works` is always satisfied, and
   one that names a late monitor is satisfied once that monitor has joined, whether or
   not it has since been stopped." Read: "An entry of `after` may name any process of the
   system, and is satisfied exactly when that process is present. So one that names an
   initial monitor, or a process listed in `works` that is a member of no group, is
   always satisfied; and one that names a late monitor or a late work process is
   satisfied once that process has joined, whatever has happened to it since." An entry
   of `after` that names a late work process is therefore **not** always satisfied: the
   group waits until that work process has joined.
3. J2, its first sentence. Read: "The *present* processes are: the initial monitors; the
   processes listed in `works` that are members of no group; every member of a group that
   has joined; and the joiner once it has joined, by its own step or by a group's."
4. J3, the sentence that begins "`alive` initially holds". Read: "`alive` initially holds
   the initial monitors and the processes listed in `works` that are members of no group,
   and no late process."

Nothing else in `model-spec-join.md` changes. In particular J5 applies to the edges at a
""")

ch(SP, "implementer, 3B.1 (X2 against X7 on what freezing covers)", r"""
| `freeze` | boolean, false if missing | whether a scope is left as it is once it has closed: no fault lands in it and nothing joins it (X7) |
""", r"""
| `freeze` | boolean, false if missing | whether the processes of a scope are left alone by the environment once it has closed: no fault lands on a process of that scope and no step joins one (X7) |
""")

ch(SP, "implementer, 3B.5 (X2 edge cases)", r"""
as a key of `scope_work` or of `told`. A system that is not scoped has no `scope_work`,
no `told` and no `freeze`.
""", r"""
as a key of `scope_work` or of `told`. A system that is not scoped has no `scope_work`,
no `told` and no `freeze`: one that carries any of them without `scope` is not a system
of this specification, and no result is defined for it. A scope that no process is of
(an id that occurs only as a key of `scope_work` or of `told`) is a scope like any other.
No process of it can be in `bad`, so none of its three judgements is ever violated and
each of its results is `null`.
""")

ch(SP, "implementer, 3B.4 (told and a switched-off monitor)", r"""
- **told[s]** is violated in the round if all three hold: some process of scope `s` is in
  `bad`; at least one monitor listed in `told[s]` is in `alive` and not in `bad`; no
  monitor listed in `told[s]` is in `out[s]`.
""", r"""
- **told[s]** is violated in the round if all three hold: some process of scope `s` is in
  `bad`; at least one monitor listed in `told[s]` is in `alive` and not in `bad`; no
  monitor listed in `told[s]` is in `out[s]`. For the second of these a listed monitor
  that is in `off` counts, if it is in `alive` and not in `bad`, although by X4 it can
  receive no flag; a listed monitor that has not joined is not in `alive` and does not
  count.
""")

ch(SP, "implementer, 3B.3 (spill for a process no scope covers); design choices under C", r"""
  process of a scope that covers `w` is *faulty*. A process is faulty if it is in `bad`,
  or if it is a present monitor that is not in `alive`.
""", r"""
  process of a scope that covers `w` is *faulty*. A process is faulty if it is in `bad`,
  or if it is a present monitor that is not in `alive`. Spill is judged whatever scopes
  are closed: a halt of work that a closed scope covers is judged, and a faulty process
  of a closed scope counts as faulty. If no scope covers `w`, then no process is of a
  scope that covers it, and every such halt of `w` is a spill.
""")

ch(SP, "reader, scope specification note 3 (when the three are judged)", r"""
G1 of the system is violated in a round if G1[s] is violated for some scope, and G2
likewise.
""", r"""
G1 of the system is violated in a round if G1[s] is violated for some scope, and G2
likewise.

None of G1[s], G2[s] and told[s] is violated in a round at whose end no process of scope
`s` is in `bad`, nor in a round that starts with `s` in `closed`. So a stop alone, with
nothing bad, violates none of them, and told[s] asks only that one listed monitor holds
the flag, in the rounds in which something of scope `s` is bad and `s` is still open.
""")

ch(SP, "reader, scope specification note 2; implementer, design choices under C (X7)", r"""
(A scope whose work is empty, or has no present process, closes as soon as `out[s]` is
not empty.) A closed scope is not judged in any later round (X6). Its processes are
otherwise as before: its monitors detect, hold flags and pass them on, and are counted by
every rule.
""", r"""
(A scope whose work is empty, or has no present process, closes as soon as `out[s]` is
not empty. In particular a scope whose work has not yet joined closes at the end of the
first round in which `out[s]` is not empty.) A scope that closes at the end of a round
was still judged in that round, and is judged in no later one (X6). Its processes are
otherwise as before: its monitors detect, and hold and pass on flags, for their own scope
and for every other, and are counted by every rule. A flag for a closed scope still halts
work that the scope covers (X5).
""")

ch(SP, "implementer, 3B.1 and 3B.2 (what is frozen)", r"""
**With `freeze` true,** no fault lands in a closed scope. In the environment phase
(section 3.1 as replaced by J4), a process whose scope is in `closed` is *frozen*, and:
""", r"""
**With `freeze` true,** no fault lands on a process of a closed scope and no step joins
one. In the environment phase (section 3.1 as replaced by J4), a process whose own entry
in `scope` is in `closed` is *frozen*, and:
""")

ch(SP, "implementer, 3B.1 and 3B.2; reader, scope specification note 2 (X7's closing sentences)", r"""
- `join` is not enabled if the joiner is frozen, and `join g` and `join-bad g m` are not
  enabled if some member of `g` is frozen. (An absent process can be frozen: what matters
  is its entry in `scope`.)

So with `freeze` true a closed scope is left exactly as it was when it closed, as the
earlier model leaves a system at its first complete response. With `freeze` false the
environment phase is unchanged: faults go on landing in a closed scope and processes go on
joining it, and none of that is judged for that scope.
""", r"""
- `join` is not enabled if the joiner is frozen, and `join g` and `join-bad g m` are not
  enabled if some member of `g` is frozen. (An absent process can be frozen: what matters
  is its entry in `scope`.) So a group with a member of a closed scope never joins, and
  neither does a group whose `after` names a process that can then never join.

Being frozen is decided by a process's own entry in `scope` and by nothing else. A
non-monitor process that a closed scope covers through `scope_work`, but whose own scope
is not closed, is not frozen: it can still be mutated, and it can still join. And
freezing stops environment steps only: a frozen monitor still detects, and still receives
and passes on flags for every scope. With `freeze` false the environment phase is
unchanged: faults go on landing on the processes of a closed scope and processes of it go
on joining, and none of that is judged for that scope.
""")

ch(SP, "implementer, 3B.6 (the order of keys)", r"""
  {"G1": ..., "G2": ..., "told": ...}, ...}, "spill": n or null}`, with one entry in
  `scopes` for every scope of the system.
""", r"""
  {"G1": ..., "G2": ..., "told": ...}, ...}, "spill": n or null}`, with one entry in
  `scopes` for every scope of the system. The order of the keys of `scopes` is not
  significant.
""")


def main():
    texts = {f: open(os.path.join(HERE, f), encoding="utf-8").read() for f in (A, RM, SP)}
    for i, (f, finding, before, after) in enumerate(CH, 1):
        n = texts[f].count(before)
        if n != 1:
            sys.exit(f"change {i} ({f}: {finding}): the before text occurs {n} times; nothing written")
        texts[f] = texts[f].replace(before, after)
    for f, t in texts.items():
        with open(os.path.join(HERE, f), "w", encoding="utf-8", newline="\n") as fh:
            fh.write(t)
    head = open(os.path.join(HERE, "corrections-1-head.md"), encoding="utf-8").read()
    out = [head.rstrip("\n"), "", "## Every change, as before and after text", ""]
    for i, (f, finding, before, after) in enumerate(CH, 1):
        out += [f"### Change {i}. `{f}`", "", f"For: {finding}.", "", "Before:", "",
                "````text", before, "````", "", "After:", "", "````text", after, "````", ""]
    with open(os.path.join(HERE, "corrections-1.md"), "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(out))
    print(f"{len(CH)} changes applied; corrections-1.md written")


if __name__ == "__main__":
    main()
