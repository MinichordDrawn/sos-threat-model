# Hand-back: the gate's protocol, specified, modelled in Lean 4, and proved

Everything below is about a **model** of the protocol, written from a specification of the Rust code. "Proved in Lean" means stated in `lean\GateProof\Challenge.lean`, proved in `lean\GateProof\Solution.lean`, and accepted by Lean's kernel on the model in `lean\GateProof\Model.lean`. It is not a proof about the Rust source text.

## In short

- **Proved in Lean, for the model:** T1, T2 (in a form weaker than the wording asked for; see below), T3, T4, T5, and T6 as three pairs of faults on a small concrete game.
- **Not proved:** nothing that was attempted was left unproved. What was not attempted is listed under "Not established".
- **Found false:** no theorem is false of the model. I found no single fault that gets a changed value recorded as true or leaves a halt that cannot be put right. One sentence of what was asked is false as worded, in the model and in the program: T2's "everything stored, every place of three, is what it is in the run with no fault".

## The one thing found false: T2 as worded

After a halt, the three places of `before` agree with one another and can all hold the faulted state. The book's counts also differ from the run with no fault.

Counterexample (fault F1, one part of the state, landing after the gate has looked and before the state is kept at R21; halts set to end after a pause or on a click):

| Round | What happens | State | Record | `before`, all three | Halted |
| --- | --- | --- | --- | --- | --- |
| n | The fault lands. R21 keeps the faulted state in all three places. The work is done on it. R31 (second doing) disagrees, so the round is refused. | work of the faulted state | `T` | `T` with the fault | yes |
| n+1, asked | `restore` puts the state back to the record. Eight new observers. The halt ends and the round ends. | `T` | `T` | `T` with the fault | no |
| n+2 | R21 writes over `before`. The round is worked and recorded. | work of `T` | work of `T` | `T` | no |

- **In the Rust:** the test `faithful_before_keeps_the_fault`, which I added to the throwaway copy, asserts each cell of this table under both settings. It passes, so the program does what the model says.
- **Why it does no harm:** `restore` reads `before` only to choose between the two halves of the record (P4 b3, b4), where it must equal one half; and the next R21 writes over it. T2 to T5 are proved with it in place.

Two smaller things turned up by the readings, neither a fault of the kinds claimed:
- With one fault per halt, the "twice running" branch and the `stick` in `correct` are never reached (in the model this is T3).
- The program cannot say "no two books agree": `stick` overwrites that reason straight after `stop_all` (watch.rs 500-507). This concerns what is said, not what is stored.

## What each theorem says

Every theorem carries two hypotheses:
- **`Sound P`** (Y1 to Y4): the two texts of the work and of `in_web` compute the same function; work done with no fault passes the gate's checks; a new game is a state the game can be in. Without these a round with no fault would be refused. They are assumed for all inputs; in the program they are supported by samples.
- **`Clean P g`**: everything stored agrees, nothing is halted, `spoiled = 0`, `stops = 0`. `reach_clean` proves every state reachable with no fault is clean. `stops = 0` is there because one statement is false without it.

The theorems:
- **`nofault_round`**: a round with no fault from a clean state is recorded, records what the work makes of the record and the voted list, finds nothing, and leaves a clean state.
- **T1** (`T1`): for every fault and instant, the round is not recorded, or what it writes to the record at R36 is what the same round with no fault writes.
  - It is about the record only. Observers can take copies from a state changed after R31; the gate finds that at R15 of the next round.
- **T2** (`T2`, `T2_at_once`, `found_counts`): after one fault and any number of ticks with no new fault, whenever nothing is halted and a halt has begun since the fault:
  - the state is the record and the record's two halves are the same;
  - every observer is exactly as a new one made from the record;
  - the three books are the same and hold no halt;
  - the three places of `before` are the same, and the three lists are the same;
  - the record is `ledger`.
- **"Say exactly which"**: the record is that of the run with no fault at the last round the faulted run recorded, not at the same round.
  - It starts as what the same tick with no fault leaves if the round of the fault was recorded, and as the record from before it if not.
  - Each later recorded round makes of it what the work with no fault makes; rounds not recorded leave it alone and are lost.
  - The one case where nothing is lost is `T2_at_once`: if in the tick of the fault the fault is found, a halt ended and the work begun, then everything stored equals the same tick with no fault, place for place, but for the counts of halts and restarts in each book, which are one more.
  - `found_counts`: the voted count of halts goes up by one in the tick of the fault exactly when the fault is found in it.
- **T3** (`T3`, `T3_ends`): at the end of every tick after the fault there is no halt that cannot be put right. In any later tick that comes to its round halted, the halt ends if halts are set to end at once, or it has been asked, or the pause is over.
- **T4** (`T4`): a detection halts everything in the tick the fault lands in or the next; or after the second tick everything stored is exactly what it is with no fault, and both rounds recorded exactly what they record with no fault.
- **T5** (`T5`): for any run of ticks with faults that keeps the spacing, there is no stuck halt at its end; when no fault is outstanding the state is clean (so all theorems apply again); and the record is what the recorded rounds made of the starting record.
  - `Spaced` allows a fault only when the run is "ready": found, halt ended, a round recorded since; or two rounds ended with nothing halted since it landed.
  - The second clause is not in the sentence asked for, which has no word for a fault never found. T4 is what makes it sound.
  - `Spaced` is narrower in two ways: at most one fault per tick, and the next fault cannot land at R37 or R38 of the recorded round itself.
- **T6** (on the toy game of `Toy.lean`, which meets Y1 to Y4 by `Toy.sound`; halts set to end at once):

| Theorem | The two faults | What the model does |
| --- | --- | --- |
| `Toy.T6_wrong_recorded` | both halves of the record of one part changed to the same value | a wrong value is recorded, and nothing is halted |
| `Toy.T6_stuck` | the two halves changed to two different values | a halt that cannot be put right |
| `Toy.T6_spacing` | the record's copy changed during the work, two rounds running | stuck: the spacing cannot be weakened to "its halt has ended" |

## The model and its abstractions

- A round is 38 steps in a fixed order (R1 to R38).
- A fault is one cell changed to any value: one part of the state, one whole observer, one text or one copy of the record, one book, one place of `before`, or one list. It lands immediately before any step, or at any point among what happens between rounds. Or it is one observer's answer made absent or wrong.
- Left out, all listed in section 12 of `protocol-spec.md` (A1 to A13): the game itself, the rules, arithmetic on time, threads, sizes and counts, the backdoor's "during" lines, the words of reasons, and stops in the wrong place.

## Faithfulness

**By reading.** `results.md` has the table from each Lean definition to its specification item and code lines. Three fresh readers, each given artefacts only, with their reports kept word for word in `reviews\`:
- **Specification against code:** no step differs. Ten points at the edges, all taken into the specification.
- **First statements and model against specification:** found `T2_at_once` false as then written, that the toy game did not meet the assumptions, and comments saying more than statements. All were fixed before the proofs.
- **Final statements:** worked each by hand looking for a counterexample and found none.

**By running.** A fresh agent, not given the model, hooked a throwaway copy of the program and tabulated what it does. The model was evaluated on the same situations (through an evaluator proved equal to `round`).
- **How many:** 2,604 situations = 3 settings x (48 faults x 18 instants + 4 answer faults).
- **Instants:** before the round, and immediately before R7, R8, R11, R13, R14, R15, R16, R17, R20, R22, R26, R30, R32, R33, R36, R37, R38.
- **Compared after each of five rounds:** halted, stuck, counts of halts, restarts and refused rounds, rounds recorded and worked, which check made the halt, whether the state is the record, which record parts disagree with themselves, which observers are not as new, and whether the lists, books and `before` places agree.
- **Result on the final model:** 2,604 of 2,604 the same.
- **First comparison:** 104 differed, all in which observers or which check, none in halted, recorded or put right. All came from two choices in the toy game (fingerprint collisions; how its work read the halted list). The toy was changed; the model was not changed for it.
- **A limit:** the table cannot tell R7 from R8, nor R26 from R30.

**A test of the statements on the model** (`lean\test\SelfTest.lean`): 4,566 runs (1,522 faults at all 38 instants, between rounds and in answers, x 3 settings), checking T1 to T4 and that the run ends clean. No failures. This is a test, not a proof.

## Checks run

| Check | Result |
| --- | --- |
| `lake build` (Lean 4.37.0-rc1, core only, no dependencies) | succeeds, 35 steps, about two minutes |
| `sorry` | none outside `Challenge.lean`, where the 14 statements have proofs left out by design |
| Axioms of each of the 14 statements | `propext`, `Classical.choice`, `Quot.sound` only |
| `lake comparator --inadvisably-no-sandbox` (Windows) | "Your solution is okay!" for all 14 |
| `lake comparator --inadvisably-no-sandbox --paranoid` | accepted by Lean's kernel (default and paranoid), `lean4lean`, `nanoda`, `con-leche`, `con-ron` |

**Could not run:** the judge in its sandbox. It needs Linux and `bubblewrap`; WSL here has Lean but not `bubblewrap`, and I installed nothing. The paranoid run was made before the last comment-only edit to `Challenge.lean`; the plain run was repeated after it.

One thing to know: I tried to end a stuck Lean process of my own with a blanket kill of `lean.exe`. The permission system refused it, and nothing was killed. No other process was touched.

## Not established

- **Anything about the Rust source text.** Fidelity rests on the readings and on the 2,604 situations. Twenty instants were not run in the Rust: before R2 to R6, R9, R10, R12, R18, R19, R21, R23 to R25, R27 to R29, R31, R34, R35.
- **Instants part of the way through a step.** Argued in section 11 of the specification, not in Lean. R19 (`mend`, `correct`, `restore`) is not cut at all; a fault inside it is a second fault in one halt.
- **Y1 to Y4.** Assumed for all inputs; supported in the program by samples only. In particular, that a round worked long after a halt still passes the rules.
- **T2 as worded.** What the books and lists hold after a halt that did not end at once is not stated beyond their agreeing.
- **"At once and found before the work ends the halt in the same round"** is not a theorem for the round of the fault. It holds in all 587 at-once situations of the table where something is found, in both program and model.
- **Threads and the two things kept in three for them (S9).** The asked-for fault model covers "anything kept in three"; these are not in the model.
- **Stops in the wrong place**, and the edge the documents record there. The model has `stops` and nothing raises it. Whether a single fault can make the work stop the program was not examined.
- **Sizes and counts; that a pause ever ends; pairs of faults in general.** T6 is three pairs on a toy. The program's own tests for the same three were read, not run.
- **The judge's sandbox.**

## Files (all under `«PROOF»\`)

`code\` was not changed. Git was not used.

- `protocol-spec.md` — the specification
- `results.md` — the write-up: theorems in words and Lean, hypotheses, abstractions, faithfulness table, checks, what is not established
- `comparator-paranoid.log`
- `reviews\spec-review-1.md`, `reviews\statement-review-1.md`, `reviews\statement-review-2.md` — the three readers' reports, word for word
- `reviews\asked-for.md` — the fault model and T1 to T6 quoted from the brief, as given to the statement readers
- `faithfulness\rust-task.md`, `rust-hooks.md`, `rust-table.txt`, `lean-table.txt`, `compare.py`
- `rust-check\` — the throwaway copy of the program with test-only hooks and tests (its `target\` is 114 MB of build output)
- `lean\` — `lean-toolchain`, `lakefile.toml`, `lake-manifest.json`, `comparator.json`, `GateProof.lean`, `Axioms.lean`
- `lean\GateProof\Model.lean` (882 lines), `Claims.lean`, `Toy.lean`, `Challenge.lean`, `Solution.lean`, `Eval.lean`
- `lean\GateProof\Proofs\` — ten files, 3,509 lines: `Basic`, `FaultFree`, `Restore`, `Generic`, `Cells`, `Post`, `Own`, `Round`, `Ticks`, `Runs`
- `lean\test\Faithful.lean`, `lean\test\SelfTest.lean`

To read for trust: `protocol-spec.md` against the code, then `Model.lean`, `Claims.lean`, `Toy.lean` and `Challenge.lean` against the specification. These hold definitions and statements only.
