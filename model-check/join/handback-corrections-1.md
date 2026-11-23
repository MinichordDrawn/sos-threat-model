# Hand-back: corrections 1 to `join\results-join.md`

All seven of the reader's findings are right, and each statement is now corrected. I checked each against my own search before changing anything (`join\recheck_corrections.py`, output in `join\recheck-corrections.txt`). The checker, the catalogue and the answers are unchanged: 300 catalogue cases drawn at random were re-run by both of my programs after the edits and none differs. Every change is listed as before and after text in `join\corrections-1.md` (18 changes to the write-up, 6 to the specification).

## The seven findings

1. **Theorem L (section 3): agreed.**
   - The statement now adds: "Those three edges of each late monitor are not slow edges, and no late monitor has an off switch."
   - A paragraph after the proof says where the proof uses this and that the conclusion fails without it. With the state check slow, the executions are those of section 5.
   - The reader's counterexample (b) is now a table: mesh of four, N5 watched by M1, N6 watched by N5, N5 has an off switch, `f` = 1; join N5; join N6; disable N5; mutate N6; breaks G1 and G2. My search gives 4 rounds as the least for both goals, and the reader's schedule replays.
   - I did not add the reader's further observation (shared boundaries, substrates and other slow edges on late monitors do no harm); it would be a new claim.

2. **Section 8, "the least is six edges": agreed.**
   - It now reads: the fewest edges are five at `f` = 1 (the three of the first item and reports to KB from two monitors of A) and six at `f` = 2 and 3; the six may all be with one monitor.
   - The verdict now says one two-way link "is enough at every rate up to 3. It is not required: at `f` = 1 five edges that hold no such link are also enough."
   - The reader's five-edge attachment has no gap at `f` = 1 under either way of arriving, and has a gap at `f` = 2 (G1 in 3, G2 in 2).

3. **Verdict, "up to `f` = the number of monitors attached": agreed.**
   - It now adds "where that number is one, two or three. With four it is still 3, the base ring's own rate."
   - With four attached at `f` = 4, mutating M1, M2, M3 and K breaks G1 and G2 in round 1.

4. **Section 6.2, "exactly when": agreed.**
   - It now says a gap follows whenever some monitor can be present with no present state checker (**proved**).
   - Among the 62 systems that is the only way a gap arises (**checked**; 62 of 62 agree).
   - It is not the only way in general, as three rows of the chain table show.

5. **Section 10, "detects every fault": agreed.**
   - It now says: if every monitor has two watchers and every work process has a state checker, then in every round with a fault some live correct monitor detects a fault of that round; it need not detect every fault.
   - The verdict's "Two observers" bullet now carries "has a state checker" too.
   - The reader's system (mesh of three, no reports, W checked by M1 only; mutate W and M1 at `f` = 2) has no gap, with M2 and M3 flagged for M1 only.

6. **Section 4.3, "four edges at `f` = 3": agreed.** It now says four edges for a monitor that a work process takes its halt from, and still three for one that only a later monitor depends on. The chain as built has no gap at `f` = 3.

7. **P8b misquote: agreed.** It now reads "proved there for every system with no substrates or switches".

## The other points

- **The count 12,324 is correct and is now spelled out:** 62 systems of way one, 12,240 of way two and 22 of the three families of section 6.1. The 22 are the hub at 9, 10, 11 monitors and the chain and fan at 9, 12, 16, 20, each in two shapes.

- **The two tables that were not shortest:**
  - Section 6.2 chain: the table has monitors arriving good and is shortest then. With a bad arrival the result is 4/4, N7 arriving bad in round 4.
  - Section 9: likewise, G2 breaks in 4 with N8 arriving bad.
  - Both are recomputed and now stated under the tables.

- **The independent comparison** is recorded in section 1: its answers equal `results-join.json` on all 5,658 cases, and it found no reading that changes an answer. The write-up now carries its note that every catalogue case has `window` 0, `coupling` true, the gate in place, no switches and no substrates, so those rules are not exercised. The not-settled item is replaced by exactly that limit.

- **The open item (joining ring, `f` = 3, all 24 edges) is settled and removed from the not-settled list.** I recomputed it rather than record it as the reader's alone, for the reason in the next section. Section 8 now has this table:

  | `f` | Least attachments, all with no gap | Of five, six, seven edges | Greatest sets holding none of them, all with a gap |
  |---|---|---|---|
  | 1 | 640 | 384, 256, 0 | 12 |
  | 2 | 512 | 0, 512, 0 | 36 |
  | 3 | 320 | 0, 256, 64 | 68 |

  A short case division shows every set holding no listed attachment lies inside a greatest one (**proved**); Lemma M does the rest. Each greatest set was also confirmed greatest: every single added edge closes its gap.

## What I found wrong in the reader's work

One thing, and it is not a finding against the write-up. The reader's completeness check for the joining ring (`verify-proofs\own-check\t05_ring_least.py`) tests only the maximal sets in which exactly `f` monitors of A report to KB: 11, 27 and 35 sets. The whole family is 12, 36 and 68. The omitted 1, 9 and 33 sets have fewer than `f` reporters. They hold no listed set and lie inside none of the reader's.

The system that shows it at `f` = 1: KB with every one of the 24 edges except the four reports from A to KB. It has a gap (mutate W: ring A flags and halts W, KB is never told, WB works), and adding any one report closes it.

So the reader's conclusion that the list is complete is right, but their run did not establish it. Mine does, with all 68 at `f` = 3. The reader's least-set counts and sizes (640, 512, 320) agree with mine.

## Sentences of `model-spec-join.md` changed

None changes what the model does: both programs already behaved as the new words say.

- **J1 (U6):** added that an `after` entry naming an initial monitor or a work process is always satisfied, and that a group whose `after` names one of its own members can never join.
- **J3 (U2):** "the work processes" is now "the processes listed in `works`", with a sentence that the joiner is not listed in `works` and is not in `alive` until it joins.
- **J4, `mutate` row (U1):** restored the parenthesis "(it may be a monitor or not, in `alive` or not, in `off` or not)".
- **J5 (U4):** "missing for exactly one round" is replaced. For an edge with an end that joins by a step, being listed delays it by exactly one round; before the later end joins it is out of force by condition 1, and in that round by condition 2.
- **J6, work phase (U3):** now says the joiner's entry in `halt_inputs` is read like any other.
- **J8 (U7):** now says `N` is in a boundary of its own.
- **U5** (how boundary and substrate ids are compared) is left alone. It is a silence of `model-spec.md`, not a loose sentence of the extension, and no case mixes types.

## Files written or changed

All in `«WORK»\sos-join-model\join\`:

- `results-join.md` (18 corrections)
- `model-spec-join.md` (6 tightened sentences)
- `corrections-1.md` (every change, before and after)
- `recheck_corrections.py`
- `recheck-corrections.txt`
- `results-join.before-corrections-1.md` (copy before the edits, so `diff` shows these changes and no others)
- `model-spec-join.before-corrections-1.md` (likewise)

The write-up's Files table now lists `corrections-1.md` and the two recheck files; it does not list the two before-copies. I wrote and then deleted a one-shot script that applied the edits and generated `corrections-1.md` from the same texts. Nothing was read or written outside `sos-join-model\`; in `verify-proofs\own-check\` I read one script only.
