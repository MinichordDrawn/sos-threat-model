# Hand-back: independent implementation of the model and its join extension

## Outcome

- **Every case was answered.** `answers.json` holds 5,658 entries in catalogue order, and every `null` was decided by exploring every reachable state. No case was cut short or left unfinished.
- **The three J8 examples are reproduced**, all eight results, on the first run and with no change to the program.
- **I found no place where two defensible readings of the specification change a catalogue answer.** I therefore did not write `answers-other-reading.json`. The one place with a textual basis for a second reading (U1 below) was computed and changes 0 of 5,658 answers.
- I wrote the program from `model-spec.md` and `model-spec-join.md` only. I opened no folder other than `verify-impl`, and used no web, no git and no other agents.

## The answers

| G1, G2 | Cases |
|---|---|
| null, null | 3,251 |
| 1, 1 | 1,689 |
| 2, 2 | 227 |
| null, 2 | 163 |
| null, 1 | 113 |
| 2, 1 | 66 |
| null, 3 | 39 |
| 3, 2 | 30 |
| 3, 1 | 22 |
| 3, 3 | 13 |
| 4, 2 | 7 |
| 4, 1 | 6 |
| 7, 3 | 6 |
| 2, null | 5 |
| 5, 2 | 4 |
| 6, 2 | 3 |
| 5, 1 | 3 |
| 5, 3 | 3 |
| 1, null | 2 |
| 4, 4 / 4, 3 / 1, 6 / 2, 6 / 1, 3 / null, 4 | 1 each |

- G1 is `null` in 3,567 cases and G2 in 3,258.
- SHA-256 of `answers.json`: `300aeb2d619d91267e5fcd65f738d75d34be692ca8d75d129f3b1491a912bd14`.

## The program

- `model.py` is the implementation. A state is eight bit sets: alive, bad, hidden, off, flagged, halted, pending, present. `present` carries both `joined` and `arrived`.
- The search is breadth-first by round. From each non-responded state it takes every state reachable by 0 to f environment steps, then runs the monitor and work phases. `new` is the difference in `present` across the environment phase.
- The search stops when both goals have a least round, or when no unexplored non-responded state is left.
- `run.py` runs the catalogue and writes `answers.json`.
- The whole catalogue takes about 20 seconds with three workers. The largest case reaches 144,855 states, and the catalogue totals about 5.5 million. Memory stayed far below the two-gigabyte limit.

## Checks

- **J8:** `test_j8.py` builds the three examples from the prose of J8 and gets all eight results.
- **Second implementation:** `naive.py` is a deliberately plain second version I wrote (names and sets, each edge tested by an explicit in-force predicate). It agrees with `model.py` on all 5,658 cases, in both answers and number of states.
- **Random systems:** the two also agree on 2,000 random small systems that use every field of both files (window 1, no gate, switches, substrates, slow reports, joiner, groups with `after`, slow edges). On 1,283 of them the comparison covered the whole reachable space; on the other 717 it covered answers and state counts only.
- **Limit of these two checks:** both implementations are mine and share my readings. They guard against coding slips, not against a wrong reading.
- **Hand-worked systems:** `test_hand.py` has 12 small systems for the parts the catalogue never uses. Both implementations give the hand-worked result on all 12.
- **Extension fields removed:** the 196 cases with no late process and no slow edge give the same answers with the extension fields deleted, and with `arrive_bad` flipped.

One thing went wrong in the hand-worked test. My first version had 14 systems, and my hand values were wrong in 6 of them. In each, the program's witness execution was correct by the specification and my arithmetic was not; for example, I forgot that with `window` 1 the state after the first flag is not responded. I corrected the expected values and did not change the program. Only the two three-monitor reports cases were predicted before the program ran; the other corrected values were re-derived after seeing the witnesses.

## Places where the specification is unclear, silent or loose

None of these changes a catalogue answer.

**U1. `mutate` on a stopped monitor.**
- The table in section 3.1 says of `mutate p`: "(it may be a monitor or not, in alive or not, in off or not)". J4 replaces that table, and its `mutate` row has no such parenthesis.
- I implemented the words as they stand in J4: any present process not in `bad`, a stopped monitor included.
- Other reading: a stopped monitor cannot be mutated. I computed it with `other_readings.py R1`: 0 of 5,658 answers differ. Wherever a witness mutates a stopped monitor, mutating the halted work process does as well.

**U2. The joiner is called "a work process".**
- The field table calls the joiner "a work process that is absent at the start". Yet `works` is "the work processes", and `alive` initially holds "all work processes".
- I read "work processes" as the names in `works`, with the joiner separate and absent until it joins.
- No effect: no rule reads whether a non-monitor process is in `alive`, and no case lists the joiner in `works`. My program rejects a system that does, as duplicate names.

**U3. `halt_inputs` is typed "map work -> list of monitors".**
- All 1,842 cases that have a joiner give it a `halt_inputs` entry.
- Section 3.3 and J6 apply `halt_inputs[w]` to every present non-monitor process, so I use the joiner's entry. I see no defensible reading that ignores it.

**U4. "Missing for exactly one round" in J5.**
- For a slow edge whose two ends join in different rounds, that sentence is loose: the edge is also not in force before the second end joins, by condition 1.
- I implemented the two numbered conditions, which are unambiguous. The catalogue has 72 such edges.

**U5. Boundary and substrate ids.**
- The specification does not say how ids are compared. I compare them as JSON values, so 1 and "1" differ.
- No case mixes types: 5,646 cases use integers and 12 use strings.

**U6. `after`.**
- The specification is silent on an `after` that names an always-present process or one of the group's own members.
- I took it literally: the first is trivially satisfied, the second can never join. Every `after` entry in the catalogue names a late process of another group.

**U7. J8 prose.**
- It does not say what boundary `N` has. I gave it its own; it cannot matter.

## Rules that are explicit but easy to implement differently

I list these because they are where two implementations are most likely to part.

- **Responded states count only present processes** (3.5, J6). A state can be responded while groups or the joiner are still absent, and then nothing can ever join.
- **Halted is not responded.** A state where every work process has halted but no good flag is out continues, and G1 can be violated later by mutating anything. This gives the `e/boundaries` answers such as G1 2, G2 null: `stop-boundary "A"`, then `mutate K`.
- **Detection is by state, not by event.** A stopped monitor or a visibly bad process is detected in every round in which the edge is in force. A monitor that joins later detects old faults from its first round in force.
- **`new` covers every member of a group joined in the round**, including one stopped or mutated in that same round. A slow edge at such a member is out of force for that whole round, for detection, reports, halt on flag and halt on silence alike.
- **`after` is tested step by step.** With f of 2 or more, a group and a group that waits for it can join in one round.
- **`after` needs present, not alive.** A stopped monitor still satisfies it.
- **`join-bad g m` exists only for monitor members.** A joiner in a group never arrives bad, and takes a work step in the round it joins if nothing in force halts it.
- **Slow reports** use the flags held at the start of the round, tested against this round's `active` and this round's edges in force.
- **A bad monitor is never in `out`.** A work process whose only halt input is a bad but alive monitor sees neither flag nor silence.

## What the catalogue does not exercise

- Every case has `window` 0, `coupling` true, `gate` true, no switches and no substrates. So `hidden`, `off` and `pending` are always empty in it.
- 63 cases have slow reports, 324 have slow edges, and 12 share a boundary.
- The window, no-gate, switch and substrate rules are implemented, but checked only by `test_hand.py` and the random comparison.

## Other disclosures

- I started a sensitivity run for "responded only when nobody is absent". It was slow, so I stopped it unfinished and dropped it: 3.5 and J6 are explicit there, so it is not a reading.
- I stopped two over-large random comparison runs and replaced them with the bounded one reported above.
- I stopped only processes I had started. No tool restriction blocked anything.

## Files written

All are in `«WORK»\sos-join-model\verify-impl\`.

- `«WORK»\sos-join-model\verify-impl\answers.json` — the 5,658 answers.
- `«WORK»\sos-join-model\verify-impl\model.py` — the implementation.
- `«WORK»\sos-join-model\verify-impl\run.py` — the runner; `python run.py --workers 3`.
- `«WORK»\sos-join-model\verify-impl\cache-main.jsonl` — per-case result, state count and seconds; `run.py` resumes from it.
- `«WORK»\sos-join-model\verify-impl\test_j8.py` — the three J8 examples.
- `«WORK»\sos-join-model\verify-impl\test_hand.py` — the 12 hand-worked systems.
- `«WORK»\sos-join-model\verify-impl\naive.py` — the plain second implementation; `python naive.py systems-join.json <id>` prints a shortest witness for a case.
- `«WORK»\sos-join-model\verify-impl\crosscheck.py` — compares the two; `catalogue 3` or `random 2000 11`.
- `«WORK»\sos-join-model\verify-impl\other_readings.py` — reading U1; `python other_readings.py R1`. It writes `other-R1.json`, which I deleted because it equalled `answers.json`.

There is no `answers-other-reading.json`.

---

Comparison made afterwards by the coordinator (not part of the hand-back above): `answers.json` against `join\results-join.json`, case by case: 5,658 ids, the same ids in the same order, 0 cases differ.
