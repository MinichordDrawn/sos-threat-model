**There are things to correct: one statement is wrong, four say more than is supported, and two cannot be told from the folder. Everything else I checked says the same as, or less than, the Lean statements and the records.**

All paths are under `«WORK»\check-eighteen\now\`. Nothing was built or run; everything is from reading.

## Wrong

**W1. `proof.md` 98-99.** "A fault that lands part of the way through a step, or while things are being put right. Section 11 of the specification argues it. It is not proved."

- The first half is as the specification has it (`lean/protocol-spec.md` 250-259, 267-269).
- The second half is not. Section 11 does not argue that a fault during the putting right does no harm.
  - `lean/protocol-spec.md` 261-266: no instant inside R19, the `restore` in R38 or R6 is described; "a fault landing there is a second fault in one halt, which the fault model puts outside (a fault to the state after `restore` and before the new observers look, for one, makes the halt stay)".
  - `lean/records/spec-review-1.md` 50-86 works that case: the halt becomes one that cannot be put right.
  - `lean/records/hand-back.md` 105, `write-up.md` 467-468 and `check.md` 150 all say "a second fault in one halt".
- The wording comes from the summary line `check.md` 241 ("or during the putting right. That is argued, not proved"), which is looser than the check's own line 150.
- What the records support: such a fault is outside what is claimed, as README 52 already says, and the specification names a case where it leaves a halt that cannot be put right.

## Says more than is supported

**S1. `proof.md` 34-35.** "and a halt ends in the round where its setting says it should (`T3_ends`)."

- `lean/GateProof/Challenge.lean` 107-122: `T3_ends` is about "any later tick that comes to its round halted". The tick `t` comes after the fault's tick and after `ts`.
- It does not cover the fault's own round. That is the case README 285 claims for "at once": "A change found before the work is put right in the round it is found".
  - `hand-back.md` 108: this "is not a theorem for the round of the fault".
  - `write-up.md` 478-484 and `statement-review-2.md` 282-286, 626-627 say the same. The review adds that it follows from `T3` and the definitions "but it is not written".
- The pause clause holds only in a round where `pauseOver` is true. Nothing says a pause is ever over (`protocol-spec.md` 279; `write-up.md` 246-247, 495; `check.md` 242).
- The sentence is `check.md` 229 word for word; the Lean statement is narrower.

**S2. `proof.md` 46-47.** "a wrong value recorded with nothing halted" (`T6`, first pair).

- `Challenge.lean` 175-180 states `r.g.halted = false`: nothing is halted when the round ends.
- Its own comment (172-174) says the gate finds the pair in between and the halt ends at once.
- `statement-review-2.md` 358-364 and 546-548: "the pair *is* found (R15) and a halt begins and ends inside the round ... The comment reads as if nothing noticed."
- Supported wording: a wrong value recorded, and nothing halted when the round ends.

**S3. `README.md` 525.** "The same holds for faults one after another."

- The bullet gives no spacing, so a reader applies the README's own (51-52): "one fault for each halt, with a round recorded before the next fault lands in the work".
- `T5` is proved for `Spaced` (`lean/GateProof/Claims.lean` 105-134), which is narrower in one corner: one fault to a tick, and the next no sooner than the tick after the recorded round.
- So a second fault at R37 or R38 of the round just recorded is allowed by the README's spacing and not covered (`write-up.md` 297-299, 498-499; `check.md` 99-101; `statement-review-2.md` 332-335).
- `proof.md` 42-45 states the spacing correctly. The README bullet sends the reader there only for "what the model is and what it leaves out".

**S4. `proof.md` 100-104.** "What the model leaves out, all listed in section 12 of the specification: the observers' threads ... and the words of a halt's reason."

The list reads as the whole of section 12 and is six of its thirteen items. Not named (`protocol-spec.md` 275-287):
- A1: that writing a part out loses nothing; a change to the number of legs.
- A3: the rules are handed parts 0 to 5 only.
- A4: the bounds on how many things asked may wait.
- A6: that the eight copies of the observers' rule say the same, which rests on one test.
- A7: the branch of `correct` for a new observer that does not answer, and `copies_apart`.
- A10: ten fields of the book as one value. The program can write over a changed one so that it is never found; this is 69 of the 141 that differed (`check.md` 186-189).
- A11 and A13.

## Cannot be told from the folder

**C1. `proof.md` 144-145.** "The proof was written and checked by Claude Fable 5.2, the model the program was written with." No file in `lean/records` names a model. Only the second half is in the folder (README 497-498).

**C2. `proof.md` 131-132 and 139.** "word for word", and "by the check".
- The originals are not here, so "word for word" cannot be compared.
- `check.md` speaks of `claims.md` (6, 56, 89, 117) and `hand-back.md` of `results.md` (73, 119). Nothing in the folder says these are `records/write-up.md`.
- I took them as the same because the two sentences `check.md` 118-119 quotes are at `write-up.md` 36 and 73-74, and its other citations fit (`write-up.md` 265-267, 462-464).

## Point 1: the other statements of `proof.md` against the Lean

Each of these says the same as the statement, or less.

- **Fourteen** (51): `Challenge.lean` has fourteen, the same names as `lean/comparator.json`.
- **The fault** (24-28): `Cell` at `Model.lean` 472-479, `Fault` at 865-868, `inject` at 828-835. A whole observer, a whole book or a whole list may change.
- **"From any state the game reaches with no fault"** (30): `reach_clean` (`Challenge.lean` 29) with `Reach` (`Claims.lean` 61-64).
- **The four assumptions** (16-20): `Sound` at `Claims.lean` 21-37. Y3 is assumed only of states both texts of the rules accept, so the sentence states the assumption a little wider than it is, which errs to the safe side. "In the program they rest on tests" is `protocol-spec.md` 293-297.
- **`T1`** (32-33): `Challenge.lean` 47-51, the same.
- **`T3`** (34): 102-105, the same, at the end of every tick.
- **`T4`** (36-37): 131-139, the same. "Found" is any detection that halted everything in that round.
- **`T2`** (38-41): 65-72 with `Settled` (`Claims.lean` 44-52) and `ledger` (80-85), the same.
- **`T5`** (42-45): "one to a round at the most" is `FTick.fault : Option` (`Claims.lean` 90-93), one to a tick. The spacing sentence is `Phase.next` and `Spaced` (105-134) read correctly, including "no sooner than the round after that one" and "or when the one before is gone". "The same" holds because every `ready` state is `Clean`, so the single-fault statements apply again (`write-up.md` 281-282).
- **`T6`, second and third pairs** (47-49): `Challenge.lean` 184-197, the same.
- **"No proofs" in the four files** (51-53): so, but for one instance in `Model.lean` 23-24 that carries a two-term proof (`check.md` 33 notes it).

The specification's line references match `src/watch.rs` in this folder wherever I looked: `settle_books` 480, `stop_all` 926, `stick` 963, `record_now` 1000, `write_record` 1097, `correct` 1126, `restore` 1204, `mend` 1273, `round_at` 1315, `turn` 1340, `begin_again` 1634.

## Point 2: numbers and "how it was checked"

All are as the record has them.

| Claim in `proof.md` | Where in the records |
| --- | --- |
| Builds, no dependencies | `check.md` 20, 32 |
| Nothing unproved outside `Challenge.lean` | `check.md` 21 |
| The three axioms and no other | `check.md` 34 |
| The judge in its sandbox accepts all fourteen | `check.md` 5, 45, 47-48 |
| Paranoid form: Lean's kernel twice and four others | `check.md` 46, six acceptances (the brief's "five" is not the record's count) |
| A second party, on a clean copy | `check.md` 16, 39, 56, 248; it did hold the author's `claims.md` |
| Two readers found no step that differs | `spec-review-1.md` 36-37 and `check.md` 125 |
| 11,757 at all 38 steps and between rounds | `check.md` 160-165 (10,902 + 855) |
| A copy with a hook before each step | `check.md` 158 |
| 11,616 the same | `check.md` 184 (10,761 + 855) |
| 141 of three kinds, each one the theorems allow | `check.md` 8, 186-191 (69 + 42 + 30) |
| 183,330 with extreme values | `check.md` 204 |
| No stuck halt, no stop in the wrong place, in those runs | `check.md` 194, 204, 235; for the 11,757, "no stop in the wrong place" is only in the summary line 235 |
| Hooked copies and tables not in the folder | so |

## Point 3: "What is said less strongly" and "What is not shown"

Each item under "What is said less strongly" is so:
- A round is lost: `ledger`, and `write-up.md` 155-163.
- `before` after a halt, and "everything stored" false of both: `asked-for.md` 13, `check.md` 79-88 and 208-218, `write-up.md` 198-221.
- `T1` and a fault to the record after it is written: `check.md` 109-110 (found at R14 of the next round, 18 situations).

Each item under "What is not shown" is so, except W1 and S4 above.

Missing, where a reader would otherwise take it as shown:
- **What the three books and the three lists hold after a halt, beyond agreeing.** `check.md` 6 and 244, `write-up.md` 473-477, `statement-review-2.md` 26-29 and 613-620. `proof.md` 38-40 says "agree" correctly, but 60-64 names `before` as the only thing not as it would have been.
- **That a halt set to end after a pause ever ends, and that the halt of an at-once round ends in the fault's own round** (S1).
- **The comparison ran the model with the toy game, not the real one.** `check.md` 158, 234; `write-up.md` 427-428. `proof.md` 83-87 says "in the program and in the model", and two of the three kinds of difference come from the toy (`check.md` 190-191).
- **A fault during the putting right belongs with "two faults"**, not with what is argued (W1).

## Point 4: the three sentences of `write-up.md`

Each is not so.

1. **`write-up.md` 73-74 and 76, "Every theorem carries `Sound P` and starts from `Clean P g`."** Nine carry both. `reach_clean` carries `Sound` only (`Challenge.lean` 29). `Toy.sound` and the three `T6` statements carry neither (167, 175, 184, 193). Five is right (`check.md` 119).
2. **`write-up.md` 36-38, "The program cannot say that no two books agree."** Settled from `src/watch.rs`:
   - 504 halts with one reason; 506 then calls `stick("it could not be put right: no two of the three places where the gate keeps what is its own agree")`.
   - `stick` (963-972) writes that to the book's `why` and the halt's `why`.
   - The test at 5321-5328 asserts the reason starts with those words; I read it and did not run it.
   - So what is overwritten is the first reason, and the one that stands says it. "It can, and does" is right.
3. **`write-up.md` 449-452 and 501, the judge could not be run in its sandbox.** The check ran it there (`check.md` 5, 37-52).

The same three sentences also stand in `records/hand-back.md` (28, 32, 98), which `proof.md` does not name.

## Point 5: the README's changed lines

- **57-59:** supported by `T1` and `T3`, in the sense `proof.md` 65-66 gives.
- **94-95:** supported.
- **418 and 439-440:** say what the files are.
- **438:** the only change is two more spaces of indentation, which puts `review-*.md` one level below the other entries of `test/`. It looks unintended.
- **506:** not about the proof; nothing in the Lean bears on it.
- **519-521, replacing the removed passage:** true as README 492-494 and `checks.md` have it, with one limit. `checks.md` records findings left as found and put outside what is held (459-462, 583-586, 627-629), so "each closed" holds of the cases inside what is claimed. "`checks.md` says what each ran and found" is so (451-730).
- **522-527:** supported, except S3. "Fourteen statements, accepted by Lean's kernel and four other checkers and checked independently" is as the record has it.
- **533-536:** supported. The "two readings" are `spec-review-1.md` and the check.

Nothing else in `README.md` or the companion files contradicts them. The remaining lines with "prove", "proved" or "proof" are consistent: README 370 (the model check) and 545 (one rule seen kept, not proved), `checks.md` 428 and 755 (that the rules never refuse a right round, which is assumption Y3). `backdoor.md`, `gameplay.md`, `observation.md` and `outside.md` have none.

## Point 6: "What is in `lean`"

Each line says what the file or folder is. Two notes:
- **`test/`:** `test/Faithful.lean` is the model's side of the author's earlier comparison of 2,604 situations (`Faithful.lean` 1-7, `write-up.md` 396-399). It is not the model's side of the 11,757, whose file was the check's own and is not here (`check.md` 158, 262). `proof.md` does not mention the earlier comparison, so the line can be read as the 11,757.
- **`records/`:** the line leaves out `asked-for.md`, which is there.

## What I did not check

- Whether the records are word for word.
- Which model wrote the proof and made the check.
- Whether the test at `watch.rs` 5321 passes.
- `test/review-*.md`, which are not in this copy.
