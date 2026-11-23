# Corrections 1 to `results-join.md` and `model-spec-join.md`

Made after two independent checks: an implementation written from the two
specification files alone (`verify-impl\handback.md`), and a reader with a decider of
their own (`verify-proofs\handback.md`). Every change is listed here with the text
before and the text after. Nothing else in either file was changed. The checker, the
catalogue and the answers were not changed.

The checks made for these corrections are in `recheck_corrections.py`, and their output
in `recheck-corrections.txt`. The two files as they were before the corrections are kept
beside this one, so that `diff` shows the same changes and no others:
`results-join.before-corrections-1.md` and `model-spec-join.before-corrections-1.md`.

Each of the reader's seven findings was checked against the search here before anything
was changed, and all seven were found right. One thing in the reader's own check was found
wrong and is not a finding against the write-up: see A13.

## A. `results-join.md`

### A1. Verdict, first bullet (the count)

Why: The reader could not reconcile 12,324. It is 62 + 12,240 + 22: the 22 are the family systems of section 6.1 (C3 of the run output). The number stands; the sentence now says what it counts.

Before:

````text
  (Theorem L and Lemma N, section 3), and **checked** on 12,324 grown systems of five to
  twenty monitors, each at `f` = 1, 2, 3 and 4.
````

After:

````text
  (Theorem L and Lemma N, section 3), and **checked** on 12,324 grown systems of five to
  twenty monitors, each at `f` = 1, 2, 3 and 4: the 62 systems of way one, the 12,240 of
  way two and the 22 of the three families, all of section 6.1.
````

### A2. Verdict, "Three" bullet (the ring with its own work)

Why: Finding 2. One two-way link is enough, not required: at `f` = 1 five edges with no such link have no gap.

Before:

````text
fourth at `f` = 3 when work takes its halt from it). A
  ring that brings its own work needs one two-way link with one monitor of the ring it
  joins. Three attachments
````

After:

````text
fourth at `f` = 3 when work takes its halt from it). For a
  ring that brings its own work, one two-way link with one monitor of the ring it joins is
  enough at every rate up to 3. It is not required: at `f` = 1 five edges that hold no such
  link are also enough (section 8). Three attachments
````

### A3. Verdict, "Three" bullet (the number attached)

Why: Finding 3. With four attached monitors the rate is 3, not 4, as the table of section 4.3 already says.

Before:

````text
a work process that
  takes its halt from the new ring alone has no gap up to `f` = the number of monitors the
  new one is attached to. Outside
````

After:

````text
a work process that
  takes its halt from the new ring alone has no gap up to `f` = the number of monitors the
  new one is attached to, where that number is one, two or three. With four it is still 3,
  the base ring's own rate. Outside
````

### A4. Verdict, "Two observers" bullet

Why: Finding 5, second part. Theorem F also asks that every work process has a state checker, and the sentence left it out.

Before:

````text
at two faults per round,
  when every work process takes its halt directly from every monitor, they are enough
  with no reports at all (Theorem F).
````

After:

````text
at two faults per round,
  when every work process has a state checker and takes its halt directly from every
  monitor, they are enough with no reports at all (Theorem F).
````

### A5. Section 1, end of the paragraph on the existing results (the independent comparison)

Why: The independent implementation has now been run. Its result and its note on what the catalogue does not exercise are added.

Before:

````text
`fast_join.py`, written separately from the two specification files, gives the same G1
and G2 on all 103.
````

After:

````text
`fast_join.py`, written separately from the two specification files, gives the same G1
and G2 on all 103.

**The independent comparison has been run. Checked.** An implementation written from the
two specification files alone, by another hand, answered the whole catalogue. Its answers
equal `results-join.json` on all 5,658 cases, and it found no reading of the specification
that changes an answer. It notes that every case of the catalogue has `window` 0,
`coupling` true, the gate in place, no switches and no substrates, so the rules for a
window, for the order without the gate, for switches and for substrates are not exercised
by that comparison.
````

### A6. Section 3, Theorem L (the statement)

Why: Finding 1. The theorem holds only if the three edges it relies on are in force from the join step and no late monitor has an off switch. The statement said "with any edges" and gave neither.

Before:

````text
late monitor of lower rank, and that are present whenever it is. The work processes are
B's. Then at rate `f` the grown system has no gap, whether or not monitors may arrive bad.
````

After:

````text
late monitor of lower rank, and that are present whenever it is. Those three edges of
each late monitor are not slow edges, and no late monitor has an off switch. The work
processes are B's. Then at rate `f` the grown system has no gap, whether or not monitors
may arrive bad.
````

### A7. Section 3, Theorem L (after the proof)

Why: Finding 1, continued: what happens without the hypothesis, with the reader's counterexample (b) as a table. The execution was replayed here and the system searched: G1 and G2 are each broken in 4 rounds at the least (`recheck-corrections.txt`, item 3).

Before:

````text
cases the round ends in a complete response, the model ends, and no round has violated
either judgement. ∎
````

After:

````text
cases the round ends in a complete response, the model ends, and no round has violated
either judgement. ∎

The proof uses the hypothesis on the three edges and on switches where it says that the
checker flags, that the reader flags and that the flag is passed on. Without it the
conclusion fails. If the state check of a late monitor is a slow edge, the executions are
those of section 5. If a late monitor that another leans on has an off switch (**checked**:
the mesh of four with W reading all; N5 watched by M1 and reporting to it; N6 watched by
N5 and reporting to it, joining once N5 is present; N5 has an off switch; monitors arrive
good; `f` = 1):

| Round | Environment | End of round |
|---|---|---|
| 1 | join N5 | nothing flagged; W working |
| 2 | join N6 | nothing flagged; W working |
| 3 | disable N5 | nothing bad; nothing flagged; W working |
| 4 | mutate N6 | N6 bad; nothing flagged; W working |

Breaks G1 and G2. No system of sections 4 and 6 to 10 has a slow edge or a switch.
````

### A8. Section 4.3, first paragraph

Why: Finding 6. Four edges at `f` = 3 are needed by a monitor that a work process takes its halt from. A monitor that only a later monitor depends on needs three at `f` = 3 too (the chain of section 6.2 as built has no gap at `f` = 3).

Before:

````text
The least is one edge for a monitor nothing depends on, three edges with one existing
monitor for a monitor that a work process or a later monitor depends on at `f` = 1 or 2,
and four edges at `f` = 3.
````

After:

````text
The least is one edge for a monitor nothing depends on, and three edges with one existing
monitor for a monitor that a work process or a later monitor depends on at `f` = 1 or 2.
At `f` = 3 it is four edges for a monitor that a work process takes its halt from (section
4.2), and still three for a monitor that only a later monitor depends on (the chain of
section 6.2, as built).
````

### A9. Section 4.3, after the table for `k` = 1, `f` = 2

Why: Finding 7. `results.md` proves P8b for systems with no substrates or switches, not for every system.

Before:

````text
Breaks G2. This is P8b of `results.md` section 6, which is proved there for every system:
a work process with at most `f` halt inputs keeps working when all of them are mutated.
````

After:

````text
Breaks G2. This is P8b of `results.md` section 6, which is proved there for every system
with no substrates or switches: a work process with at most `f` halt inputs keeps working
when all of them are mutated.
````

### A10. Section 6.2, "The order of joining"

Why: Finding 4. Section 3 proves only that such a monitor gives a gap. That nothing else gives one is checked for these 62 systems and is not true in general (three rows of the chain table have a gap with every monitor checked).

Before:

````text
the one in which a monitor's three are all late. In general a gap follows exactly when
some monitor can be present with no present state checker (**proved**, section 3).
````

After:

````text
the one in which a monitor's three are all late. A gap follows whenever some monitor can
be present with no present state checker (**proved**, section 3). Among these 62 systems
that is the only way a gap arises (**checked**). It is not the only way in general: three
rows of the chain table below have a gap although every monitor always has a present
state checker.
````

### A11. Section 6.2, under the five-round chain table

Why: The table is a real execution but not the shortest under the section's setting (a new monitor may arrive bad), where the result is 4/4 as the table of results above it says.

Before:

````text
Breaks G1 and G2 (`f` = 1; nobody reads N6's signal, and N6 is N7's only checker).
````

After:

````text
Breaks G1 and G2 (`f` = 1; nobody reads N6's signal, and N6 is N7's only checker). The
table has every monitor arriving good and is the shortest execution then. Where a monitor
may arrive bad, which is the setting of the 4/4 above, it is one round shorter: N7 arrives
already bad in round 4.
````

### A12. Section 8, "What KB must be attached by" (the least count)

Why: Finding 2. At `f` = 1 the least attachments of five edges are in the list just above the sentence; "the least is six" was wrong for `f` = 1.

Before:

````text
So the least is six edges, all of which may be with one monitor of A: KB and that monitor
watch each other and report to each other. Three attached monitors
````

After:

````text
So the fewest edges are five at `f` = 1 (the three of the first item and reports to KB
from two monitors of A) and six at `f` = 2 and 3. The six may all be with one monitor of
A: KB and that monitor watch each other and report to each other. Three attached monitors
````

### A13. Section 8, "What KB must be attached by" (`f` = 3 over all 24 edges)

Why: The open item is settled. The independent reader confirmed that every listed set has no gap at `f` = 1, 2 and 3 over all 24 edges. Its family of greatest sets was not the whole family (11, 27 and 35 sets, against 12, 36 and 68), so the completeness was recomputed here with every greatest set (`recheck_corrections.py`, item 1).

Before:

````text
Breaks G2 (`f` = 1; M1 watches KB and KB reports to M1, and nothing comes back to ring B).
````

After:

````text
Breaks G2 (`f` = 1; M1 watches KB and KB reports to M1, and nothing comes back to ring B).

**The list is complete over all 24 edges at `f` = 3 too. Checked,** for the two meshes
joining in one step. An independent reader built every attachment the list gives and
found no gap in any; that count and the sizes below are the reader's and were recomputed
here. The greatest sets and their count are computed here (`recheck_corrections.py`).

| `f` | Least attachments in the list, all with no gap | Of five, six, seven edges | Greatest sets that hold none of them, all with a gap |
|---|---|---|---|
| 1 | 640 | 384, 256, 0 | 12 |
| 2 | 512 | 0, 512, 0 | 36 |
| 3 | 320 | 0, 256, 64 | 68 |

A set of edges that holds none of the listed attachments either has no check of KB by A,
or no read of KB's signal by A, or no report from KB to A, or else has at most `f`
monitors of A reporting to KB and KB watching none of those in full. In each case it lies
inside one of the greatest sets counted in the table (**proved**, by that division into
cases), each of which has a gap (**checked**), and by Lemma M so has it.
````

### A14. Section 9, under the slow-reports table

Why: The table is a real execution but not the shortest under the setting of the 62 systems checked (a new monitor may arrive bad), where G2 breaks in 4.

Before:

````text
Breaks G2 (`f` = 1, reports take a round; W reads the base four). With W taking its halt
````

After:

````text
Breaks G2 (`f` = 1, reports take a round; W reads the base four). The table has every
monitor arriving good and is the shortest execution then. Where a monitor may arrive bad,
as in the 62 systems checked, G2 breaks in 4 rounds: N8 arrives already bad in round 4.
With W taking its halt
````

### A15. Section 10, "What two observers do give"

Why: Finding 5. "Detects every fault" is false for a bad work process whose only checker is faulted in the same round, and the sentence left out that every work process needs a state checker. Theorem F proves that some fault of the round is detected.

Before:

````text
**What two observers do give. Proved** (Theorem F). At two faults per round, if every
monitor has two watchers, each of which both checks its state and reads its signal, then
some live correct monitor detects every fault. The detection must still reach the work:
````

After:

````text
**What two observers do give. Proved** (Theorem F). At two faults per round, if every
monitor has two watchers, each of which both checks its state and reads its signal, and
every work process has a state checker, then in every round with a fault some live correct
monitor detects a fault of that round. It need not detect every fault: when a work process
and its only checker go bad together, the checker's fault is detected and the work
process's is not. The detection must still reach the work:
````

### A16. Section 12, the item on the joining ring at `f` = 3

Why: Settled (see the correction to section 8 above), so the item is removed.

Before:

````text
- The least attachments of a joining ring at `f` = 3 over all 24 edges. The search was
  completed over 15.
````

After:

````text
(nothing: the passage is removed)
````

### A17. Section 12, the item on the independent implementation

Why: It has been run (see the correction to section 1 above). What remains unsettled is what the comparison does not exercise.

Before:

````text
- The independent implementation has not been run. The two implementations compared here
  were written by the same hand.
````

After:

````text
- The rules for a window, for the order without the gate, for switches and for substrates,
  where monitors join. The independent comparison (section 1) covers the catalogue, and
  the catalogue uses none of them.
````

### A18. Files table

Why: Three files were added with these corrections.

Before:

````text
| `results-join.md` | this note |
````

After:

````text
| `results-join.md` | this note |
| `corrections-1.md` | every change made to this note and to `model-spec-join.md` after two independent checks, as before and after text |
| `recheck_corrections.py`, `recheck-corrections.txt` | the checks made for those corrections, and their output |
````

## B. `model-spec-join.md`

Each sentence is tightened without changing what the model does: both programs
already behaved as the new words say, and no answer changes.

### B1. J1, after the table of a group's keys (point U6)

Why: The specification was silent on an `after` that names a process that is always present, or a member of the group itself.

Before:

````text
No process is a member of two groups.
````

After:

````text
An entry of `after` may name any process of the system. One that names an initial monitor
or a work process is always satisfied. A group whose `after` names one of its own members
can never join.

No process is a member of two groups.
````

### B2. J3 (point U2)

Why: "The work processes" could be read to include the joiner.

Before:

````text
`alive` initially holds the initial monitors and the work processes, and no late monitor.
````

After:

````text
`alive` initially holds the initial monitors and the processes listed in `works`, and no
late monitor. As in `model-spec.md`, the joiner is a name of its own, is not listed in
`works`, and is not in `alive` until it joins.
````

### B3. J4, the row for `mutate` (point U1)

Why: J4 replaces the table of section 3.1, and its row for `mutate` had lost that table's parenthesis, so it could be read as excluding a stopped monitor.

Before:

````text
| `mutate p` | `p` is a present process not in `bad` | add `p` to `bad` |
````

After:

````text
| `mutate p` | `p` is a present process not in `bad` (it may be a monitor or not, in `alive` or not, in `off` or not) | add `p` to `bad` |
````

### B4. J5 (point U4)

Why: "Missing for exactly one round" is loose for a slow edge whose two ends join in different rounds: by condition 1 it is also out of force before the second end joins.

Before:

````text
So an edge listed in `slow_edges` is missing for exactly one round, the round in which the
process at one of its ends joined, and is in force from the next round on. An edge between
````

After:

````text
So for an edge with an end that joins by a step, being listed in `slow_edges` delays it
by exactly one round. Not listed, it is in force from the round in which the later of its
ends joins. Listed, it is in force from the round after that: before the later end has
joined it is out of force by condition 1, and in the round in which the later end joins
by condition 2. An edge between
````

### B5. J6, the work phase (point U3)

Why: `halt_inputs` is typed in `model-spec.md` as a map from work processes; the joiner's entry is used in the same way, and the sentence now says so.

Before:

````text
- Work phase. For a present non-monitor process `w`, `sees` is true if some monitor `m`
````

After:

````text
- Work phase. For a present non-monitor process `w` (a work process, or the joiner once it
  has joined, whose entry in `halt_inputs` is read like any other), `sees` is true if some
  monitor `m`
````

### B6. J8 (point U7)

Why: The examples did not say what boundary `N` is in.

Before:

````text
other's state and report to each other, each in its own boundary, with no substrates and no
````

After:

````text
other's state and report to each other, each in its own boundary (`N` too is in a boundary
of its own), with no substrates and no
````
