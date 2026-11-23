# Hand-back: corrections 1 to `part-a.md`, `results-minimal.md` and `model-spec-scope.md`

All 45 corrections are applied. I found neither check wrong on any finding. The catalogue, its answers and the model are unchanged.

## State found after the interruption

Nothing of the corrections had been started: no before-copies, no `corrections-1.md`, no added files. The three write-ups were exactly as at my first hand-back. So nothing was done twice or left half done.

## What I did

- Read both hand-backs in full, then checked each finding against my own search before changing anything.
- Recomputed every result the reader reported first, with `mr_model.py` (`corrections_1.py`).
- Made 45 changes: 22 in `results-minimal.md`, 13 in `part-a.md`, 10 in `model-spec-scope.md`. Each is in `corrections-1.md` as before and after text.
- Kept before-copies as `*.before-corrections-1.md`. A plain `diff` against them shows only the corrections.
- Put the 36 systems the corrections rest on, which the catalogue lacks, in `systems-minimal-added.json`, with answers in `results-minimal-added.json`.
- Ran `verify-impl\model.py` on those 36 as a second opinion: it gives the same answers on all of them. `scope_naive.py` agrees on the 31 it finished.

## The false sentence

**`results-minimal.md` section 5.2. Agreed, on both parts.**

- The text now says the execution above it (D2 joins; A2 joins bad; D2 flagged; W1 working) is the one `results-join.md` section 4.2 gives for a missing "N reports to X".
- Section 8's "nothing comes back to ring B" is named as the mirror case and "not this one".
- "Only half under either reading" now reads: exactly the second half under flow; under actor neither half whole.

## The eleven

| # | Finding | Agreed | What the text says now |
|---|---|---|---|
| 1 | Section 4.3's three proved statements need "every monitor in a boundary of its own" | Yes | The hypothesis is in the statement with its reason, and in the verdict and section 4.6 |
| 2 | Lemma M cited for a scoped search | Yes; I agree with the reader's argument | Stated as **Lemma M-scope** in section 4.2 with that proof, marked **Proved**, cited in sections 4.1 and 5.3. Said not to hold for added halt-input edges (`example/1` against `example/4`) |
| 3 | Theorem J used on systems with late work processes | Yes | Section 5.2 says the class is wider than the statement's and gives the sentences showing the proof carries over |
| 4 | Condition 2, "first, not last" | Yes | New heading and restated condition: see the verdict on the goal below |
| 5 | `part-a.md` section 4, "it does" | Yes | "Only in part": under actor as one system yes; under flow three reports along the upper cycle are enough; with scopes no downward report is needed |
| 6 | "This is Theorem 0" | Yes | Says what the execution does, and that neither part of Theorem 0 applies as stated |
| 7 | "19 edges" rests on an unreported choice in R2 | Yes | The choice is stated in both requirement tables and both verdicts; figures below |
| 8 | "Least under actor" rests on R5 as the report edge | Yes | Both verdicts say so; figures below |
| 9 | What `sufficient_f1` was evaluated on | Yes | Conditions (a) to (d) only, own boundaries, towers of 1 to 4 levels, each reading and work wiring. The boundary clause is by argument, for two levels or more; `theorem_S_wide` alone carries the conclusion |
| 10 | "The numbers are the same" with the work reading two | Yes | The least numbers are; the counts are given (22 wirings in 11 shapes, 26 in 14) |
| 11 | X1 against J1 | Yes | See the specification below |

### Results recomputed and now carried

Each is marked as checked here and independently.

- **Further readings of an arrow.** Each kind can run along the arrow, against it, or both ways: 27 readings, 7 outcomes (every wiring, f = 1, work reading all).

  | Readings | How many | Fewest | The candidate |
  |---|---|---|---|
  | flow's family | 6 | 8 (24 wirings) | one over |
  | actor's family | 6 | 9 (26) | least |
  | watching one way, a flag both ways | 6 | 8 (54) | one over |
  | signal read and state check opposite ways | 6 | 9 (3 wirings, or 6 with a flag both ways) | does not meet R2 as stated |
  | signal and state both ways | 3 | 5 | four over |

  With R2 as two readers and two checkers by any nodes, the fourth row is 9 (11 or 38 wirings) and the candidate is least, also at f = 2 and 3. My table splits one of the reader's rows in two; otherwise it is the reader's.
- **R2's other choices, kind by kind.** Done by listing all 6,561 sets of the fewest size, without Lemma M.
  - Observer a signal reader: 15 edges, in 6,318, 2,340 and 96 sets at f = 1, 2, 3.
  - Two readers and two checkers by any nodes: 19, in 5,004 sets.
  - As stated: 19, in 78.
- **R5's other choice** (D watches each member): 8 connections under flow and under actor; the candidate is one over.
- **Join orders.**
  - Rings 2 and 3 whole in one step, then T: no gap as one system under flow at f = 1, 2, 3; G2 in one round under actor; told in 2 rounds with scopes under either.
  - T in one step with D2, or with the whole of ring 2: no gap, nothing violated.
  - Three rings and no T: no gap under flow; G2 in one round under actor (mutate D1; W2 keeps working).

### The reader's notes on the scope specification

- **Note 2** (a ring hit while being built closes at once): now a rule in X7. Section 5.1 says "nothing violated" under top-first includes those executions and is not a statement that growth completes.
- **Note 3** (when the three are judged): now a rule in X6, and said of the tower in section 4.2.
- **Note 4** (lists at forty monitors): section 4.6 gives the scopes and lists; section 4.2 says the top scope has no list.
- **Note 5**: the write-up already said it; no change.

## The verdict on the candidate, as it now reads

It turns on what an arrow is taken to carry, and on one choice each in R2 and R5. Of the 27 readings in which an arrow carries all three kinds of edge, the candidate is least under six, one connection over under twelve, short of R2 as stated under six, and four over under three.

- Under actor it is least, tied with five other shapes of nine, with R5 as the report edge. With R5 as "D watches each member", eight are enough under actor too.
- Under flow eight are enough, and the candidate is the eight plus one downward arrow that nothing forces in one ring.
- Kind by kind: 19 edges when an observer is one node that both reads and checks; 15 when an observer is a signal reader.

## The verdict on the goal, as it now reads

Unchanged in substance except Condition 2 and one hypothesis.

- **What holds:** as before, with "every monitor in a boundary of its own" added to the proved halt half.
- **Condition 2: the order the goal gives has a gap, and with the top coordinator first there is none.** That is what is established, among the ten orders tried. It is not that the top coordinator must be first.
  - Under actor it cannot be last in any order, as one system (proved from the check on three rings without T).
  - Under flow it can be last, as one system, if rings 2 and 3 arrive whole and together in one step. Whole but one after the other, or coordinator by coordinator, it cannot.
  - With scopes, top-last leaves told violated in two rounds.
  - It need not be strictly first: in the same step as D2, or as the whole of ring 2, is enough.
- **"Always minimal":** now names "actor with R5 read as the report edge" where it said "the first reading".
- **Conditions 1, 3, 4:** unchanged.

## What I found wrong in either check

Nothing. Three things I left alone, on purpose:

- **Two true remarks of the reader's on table cells** in `results-minimal.md` section 4.3 (the f = 4 table understates who holds the flag; "nothing flagged" means no live monitor). They are not among the twelve, so I did not touch them.
- **The implementer's 3B.6 (boundary ids) and 3B.7 (`fail-substrate`)** concern `model-spec.md`, which I may not edit. On a `null` boundary id the two programs differ (mine takes it as an id). No system here has one or a substrate.
- **Two sentences are now out of date:** "No independent reader has checked this part" in `part-a.md` section 6, and "No independent reader" in `results-minimal.md` section 6. They are not in the list of corrections, so they stand. They should go in a later round.

## Sentences of the specification changed

No rule of the model changed.

- **X1.** Heading is now "replaces sentences of J1, J2 and J3". It lists the four passages of `model-spec-join.md` it replaces, each with the text to read instead:
  1. J1's `members` row: a member may be a name in `works`.
  2. J1's two sentences on `after`: an entry is satisfied exactly when the named process is present, so one naming a late work process is not always satisfied.
  3. J2's first sentence: only work processes in no group are present from the start.
  4. J3's sentence on `alive`: likewise.
- **X2.**
  - The `freeze` row speaks of the processes of the scope.
  - A system with `scope_work`, `told` or `freeze` and no `scope` is not a system of the specification.
  - A scope no process is of has all results `null`.
- **X6.**
  - told: a listed monitor in `off` counts as able to hear; one not yet joined does not.
  - spill: judged whatever is closed; every halt of a process no scope covers is a spill.
  - New paragraph: none of the three is violated when nothing of the scope is bad or the scope is closed; a stop alone violates nothing.
- **X7.**
  - A scope whose work has not joined closes in the first round its flag is held.
  - A scope is still judged in the round it closes.
  - A flag for a closed scope still halts covered work.
  - Frozen is decided by a process's own entry in `scope`.
  - A group with a frozen member never joins.
  - "Left exactly as it was" is removed.
- **X12.** The order of keys in `scopes` is not significant.

## Files written

All in `«WORK»\sos-minimal-ring\`.

- `corrections-1.md`
- `part-a.before-corrections-1.md`
- `results-minimal.before-corrections-1.md`
- `model-spec-scope.before-corrections-1.md`
- `systems-minimal-added.json`
- `results-minimal-added.json`
- `results-minimal-added-by-verify-impl.json`
- `corrections_1.py`
- `corrections_1_apply.py`
- `corrections-1-readings.txt`
- `corrections-1-r2.txt`
- `corrections-1-orders.txt`
- `corrections-1-added.txt`
- `corrections-1-added-verify-impl.txt`
- `naive-added.txt`

Changed: `part-a.md`, `results-minimal.md`, `model-spec-scope.md`.
