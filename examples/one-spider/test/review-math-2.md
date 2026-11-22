# Review of the single-fault claims: hand-back

## Verdicts

One claim fails, in one place. Claim 3 does not hold for the gate's written record: one entry of `record.texts` changed while a round is being worked ends in `stuck`, under all three settings, whenever the round's work had moved that part. The body moves every round, so for the body it always does. No wrong value is recorded, but the game is lost. I ran it.

| Claim | Verdict |
| --- | --- |
| 1. Detection between rounds | **holds** |
| 2. Recovery | **holds** |
| 3. A fault inside a round | **fails** for the record's text; holds for every other target |
| 4. No single fault stops the program | **holds** (reading and runs; not a proof) |
| 5. No false halts | **holds**, with one part **not settled**: the foot rule is observed, not proved |
| 6. Texts and list comparison exact | **holds** |
| 7. The second doing is the same function | **holds** inside the fault model; one stored value outside it feeds both doings |
| 8. Fingerprints | **holds** |
| 9. The wiring | **holds** by reading; the model check itself not run |
| 10. A halt that cannot be put right | **holds**, with two corrections to the claim as worded |

Line numbers are those of the files as I received them. My copy of `watch.rs` now has test-only lines added after line 560, so its numbering has shifted (see "What I changed").

## What was run

All runs are throwaway tests named `zz_review_*` at the end of the test module of `src/watch.rs`, each run with a name filter. They start from the author's helpers `fresh()`, `webbed()`, `carried()`, `handing()` and `with_moths()`. Outputs are in `review-out/` inside the review folder.

| Test | What it does | Result |
| --- | --- | --- |
| A | `record.texts[p]` changed at the author's own `fault` hook; 4 games × 7 parts × 3 settings = 84 cases | 45 stuck: exactly the cases where the work had moved the part |
| B | 86 faults × 12 instants × 3 settings × 2 games = 6,192 cases; each compared with an untouched twin | 189 stuck, all record-text faults at the seven instants before `observers_off()`; 0 wrong records, 0 panics, 0 rounds not undone, 0 later halts |
| C | a late fault followed by a second before the next round | see claim 3, second finding |
| D | 25 changes to the gate's bookkeeping × 12 instants × 3 settings = 900 cases, each round checked against a recomputed right round | 0 wrong records, 0 panics |
| E | fault-free random play, 20 runs, 640,000 rounds, round lengths from 0 to the 0.05 s cap, boost up to 1.11 | 0 halts |
| F | list faults taken away by a later asking; `before`; 1,499,247 random finite numbers written and read back | as argued; 0 numbers read back differently |
| G | B in short (2,064 cases) built with overflow checks on | 0 panics |
| H | every field of the six open parts, on the state's side and on the record copy's side, set to 12 hostile values, plus 27 changes to `Own` on both sides; 3 games, 42,792 cases, overflow checks on, `shown()` called on the faulted state | 0 panics, 0 stuck |
| J | 1,125 single faults one after another under constant pointer and shop traffic, also during halts | never stuck; halts never exceed faults |

The twelve instants are: before the moths observer's list is read; after `before` is kept; after `take_in`; between the world's work and the spider's; after the work; after the rules; after the second doing; after `observers_off()`; in `write_record()` before and after the observers take their copies; after the round is recorded; and at the very end of the round. Faults inside `take_in`, `world_work`, `spider_work` or `redone` were not placed.

## Claim 1. Detection between rounds: holds

Argument, by target:

- **A state part, including `Own`.** Each non-coordinator of the ring compares the part's full text with its own copy (`watch.rs:363`). The gate compares it with the record (`watch.rs:454`). The text is exact (claim 6). The halt is set at `watch.rs:761-773`, before the work at 789-797.
- **An observer field.**
  - `beat`: the observer itself finds it (`watch.rs:401`).
  - `alive`: its signal goes stale and `respond()` stops everything (`watch.rs:441-443`); the others' rule finds it too (376-381).
  - `copies[p]`: the observer itself (363), its ring (366-373), and for a part outside its rings `shaped()` (347-349).
  - `held`: 387 for the moths observer, `shaped()` for the rest.
  - `name`: `shaped()`.
  - `flagged`: 419.
  - `why` alone: only the gate (486).
  - The gate checks every one of these fields again at 468-491.
- **Record text or record copy.** `watch.rs:449`, before anything is computed from the record.
- **A request list.** `watch.rs:462`, compared bit for bit.

A change makes no difference and is gone in exactly two cases:

1. **`before`.** It is read only at `watch.rs:687` and 697, and only when the record of a part disagrees with itself, which a single fault in `before` cannot cause. It is written over when the next round's work begins (`watch.rs:791`). It is never found, only replaced, within one round. Ran (F, B).
2. **A list entry that a later asking takes away before the next round.** There are three patterns, all ran (F):
   - a changed last pointer place when four are waiting, written over by the next place (`watch.rs:852-856`);
   - a lost trailing letting go, sent again;
   - a letting go nobody made, followed by a real one (`watch.rs:859-862`).

   In each the two lists come out equal to the unfaulted list. The argument that convergence is always benign: both lists pass through the same function of the same arrivals, and one of them is unfaulted. A difference that survives to the next round's look is found there.

No value in the model can stay changed and unseen for more than one round. The sweep's two end-of-round instants, under all three settings, found every state, `Own`, record-text, record-copy, observer and list fault in the next round, before work.

## Claim 2. Recovery: holds

`restore()` (`watch.rs:676-715`), for one part. S is the state's text, T the written record, K the text of the record's copy, O the observers' copies, B the text of `before`.

Between rounds, fault-free, S = T = K = O, and B differs from S for any part the last round moved.

| Faulted | What `restore()` does | Right? |
| --- | --- | --- |
| S | T = K, so the state is put back from the copy (680-683) | yes |
| T | S = T fails; S = K and all observers hold K (690), so T is rewritten from K | yes |
| K | S = T and all observers hold T (688), so the copy is taken from the state | yes |
| one observer's copy | no part disagrees; all eight observers are replaced (646-650) | yes |
| B | never consulted | yes |

Further points:

- A faulty value is never adopted. A half of the record is overwritten only from a value whose text equals the other half and is held by every observer in full. `all_hold` (335-337) requires the three full-text holders, not only the fingerprints.
- Branch order cannot misfire: with T faulted the first branch is false, and with K faulted the first branch is the right one.
- `before` enters only by text equality with T, so even a faulted `before` cannot bring in a wrong value.
- After `restore()`, the new observers and the gate look again (653-658). For one fault they find nothing: the state equals the record, the observers are made from the record (340), and the lists are equal.
- Lists: both become `[Release]` (708-712). The next work lets go.

Under the other two settings a halt lasts many rounds. Requests arriving meanwhile go into both lists alike (`ask()` 847-867), and the state does not change, so the pause ends. Ran: B at the two end-of-round instants under all three settings, J under traffic. None stuck.

## Claim 3. A fault inside a round: fails

### What fails

**Situation.** Any game in play, any setting. Ran on `fresh()`, `webbed()`, `carried()` and `handing()`.

**The one value.** One entry of `record.texts`. I appended one character to `record.texts[2]`, the body's.

**When.** At any instant after the gate's look at the start of the round and before `observers_off()` in `record_now()` (`watch.rs:573`): during the work, the rules or the second doing.

**Round N.**
- The work is done. The rules pass. `redone()` agrees, since it does not read `record.texts`.
- `observers_off()` compares each observer's copies with `copies_for(i, &self.record.texts)` (`watch.rs:480`) and returns "the gate found the copies of the legs A observer changed while the round was being worked".
- The round is not recorded and everything halts.

**When the halt ends** (the next round under "at once", after the pause, or on the click). `correct()` calls `restore()`. For that part:
- text ≠ kept (679-680);
- 688 fails: the state is not the faulted text;
- 690 fails: the state is not the copy either, because the unrecorded round moved it;
- 692 fails: `began` (687) asks whether `before` equals the written half, and the written half is the faulted one;
- so 703-704 returns the error, and `correct()` calls `stick` (639).

**Outcome.** `stuck`, with "it could not be put right: the gate's record of the body does not agree with itself, and the state and the observers do not settle which of the two is right". It stays until "Put it right" is clicked, and then the game is begun again. Nothing wrong is recorded.

**Which parts.** Any part the round's work changed:
- the body in every round, since `body.age += dt` (`game.rs:1097`);
- `Own` whenever chance is drawn;
- the moths part while a moth is on the wing;
- a leg set while it steps.

For a part the work did not touch (the edge always), branch 690 puts it right.

**Evidence.** Test A used only the author's `fault` hook and none of mine: 45 of 84 stuck, exactly the 45 where the work had moved the part. Sweep B gave the same at all seven instants before `observers_off()`. After that instant the record is replaced whole (`watch.rs:627-628`) and the fault is gone.

**What is missing.** The mirror of the third branch. If `before`'s text of the part equals the copy's and every observer holds that, the written half is the one that went wrong: rewrite it from the copy and put the state back. I did not try a fix.

**In the README.** `README.md:511-513` says one fault in the record is put right "in either half of any part, between rounds or while a round is being worked". That is false for the written half. The author's test `a_fault_in_the_gates_record_while_a_round_is_worked_is_put_right` changes only the copy half.

When it sticks, the parts before the failing one have already been put back and the rest still hold the unrecorded round. "Nothing of a wrong round is kept" (`README.md:172`) is therefore not true of the state in this case.

### What holds

Every other target, at all twelve instants (B, ran):

| Target | Outcome |
| --- | --- |
| A state part or `Own`, before or during the work | The two doings disagree and the round is undone exactly, or the work wrote over the value and the record is the untouched twin's |
| A state part or `Own`, after the comparison | Recorded right (the record is `made`, `watch.rs:627-628`); found in the next round and put back |
| Record copy, before the second doing | Round not recorded; put right by branch 688 or 692 |
| Record copy, after the second doing | Replaced whole, or caught through `held_of` at 483 and put right |
| Either request list | Not recorded with both lists put aside, or the same result and the lists cleared |
| An observer field, up to `observers_off()` | Round not recorded (573), state back to the record |
| An observer field, after it | Written over, or found in the next round |
| `before` | Nothing |

The argument that a changed value is never recorded: the record is only ever what `redone()` made from the record copy, the second list and `in_web(record.world)`. The live doing reads the state, the first list and the moths observer's list. One fault reaches one side only, so the two disagree unless the fault was immaterial.

### A second finding, which depends on how "at a time" is read

The task defines it as: no other fault lands until "a round has been recorded with no halt". A fault landing late in round N, after the two doings were compared, is still present when round N is recorded with no halt. By the letter, a second fault may then land before round N+1 looks. Ran (C):

- First fault: `body.x` changed after `observers_off()`. Round N is recorded right.
- Second fault in either half of the record of the body: `stuck` under all three settings.
- Second fault that makes `record.texts[2]` say what the faulted state says: the wrong value is adopted. The record's `body.x` came out one unit off the untouched game's, with one halt and "the gate's record of the body put right".

The README's own wording, "more than one fault before the first has been put right" (`README.md:502`), excludes these. The task's definition does not. One of the two needs to change.

## Claim 4. No single fault stops the program: holds

**By reading.** Every index, cast and loop bound that takes a stored value:

| Where | Guard |
| --- | --- |
| `game.rs:469` | cast clamped by `.min(3)` |
| `game.rs:655` | `level()` is range- and integer-checked before the cast |
| `game.rs:668` | `k` checked against the plan's length |
| `game.rs:682-686` | `made` clamped to the plan's length; the range starts at 1 |
| `game.rs:714` | `.min(6)` |
| `game.rs:859` | saturating add and multiply |
| `game.rs:1049` | `held >= legs.len()` before `legs[held]` |
| `rules.rs:65` | the only loop bounded by a stored value; reached only after `wrong_in` has refused non-whole levels and levels above 10,000 (88-94), so at most 40,000 steps |
| `rules.rs:70` | `.min(6)` |
| `rules.rs:145` | slice bounded by the enumerating index |
| `watch.rs:900` | `k < legs.len()` |

- Float-to-integer casts saturate.
- There is no integer division and no `unwrap` on a stored value.
- The integer arithmetic on state values is wrapping or shifts (`Chance`, the fingerprint).
- Between rounds, nothing is computed from a faulted record before it is detected.

**No unbounded growth.**
- Lists: `ask()` bounds pointer runs and repeated lettings go, and presses and upgrades are capped at eight and refused during a halt.
- `torn`: a strand is added at most once, because `holding()` excludes torn strands.
- `gains`: kept for sixty seconds.
- `inside`: at most eight.

**Ran.** H: 42,792 cases with overflow checks on, 0 panics. B and G: 0 panics. D: 0 panics.

**Argued only.** The path in `main.rs:99-112`, where a panic is caught and `fail()` replaces the game. I did not start the program.

## Claim 5. No false halts: holds, one part not settled

**The start-of-round condition.** `write_record()` sets the record to `made`, whose two halves come from the same values. `redone()` has just found `made`'s texts equal to the state's (`watch.rs:597-599`). The observers copy the state (614-619). The moths list is `in_web` of a world equal to the record's. Signals: each is `rounds` after `watch()` and `rounds - 1` at the next (401-404). New observers are made with `beat = rounds` (340), in `Game::new`, `correct()` and so after `begin_again()`. Nothing but a round changes any of it; requests touch only the two lists, alike.

**The rules against the work.** I read every rule in `rules.rs` against `game.rs`. Each exact rule restates the work's own expression in the same order: age, meals, boost, room, gains, prices, the old spider's place, the moth's edge place, the web's steps and ageing. Each toleranced rule has slack many orders above rounding.

**Not settled.** "A foot further from the body than a leg can reach" (`rules.rs:135`, four body lengths) is a bound on what `step_legs` can produce, and I did not prove it. Observed: at most 2.70 body lengths in 640,000 rounds (E), including boost 1.11 and rounds of 0.05 s.

**Ran.** E: 0 halts. J and B: no extra halt after a halt ends, with requests arriving during halts.

**Not run.** The rounds after `begin_again()`; argued from `Game::new`.

## Claim 6. Texts and list comparison exact: holds

- **Numbers.** `Val::written` uses `{}` (`door.rs:51`) and `Own::written` uses `{:?}` (`game.rs:350-369`). Both give the shortest text that reads back to the same bits. Ran: 1,499,247 random finite values, none read back differently. 0 and -0 are written `0` and `-0`.
- **Not-a-number.** Every NaN is written the same, whatever its bits. That cannot hide a fault: a recorded state holds no NaN (`unfit()`, `watch.rs:528-548`), and nothing in the work reads a NaN's bits.
- **Texts.** `quote()` (`door.rs:66-82`) is unambiguous. Ran on twelve texts with quotes, backslashes and separators.
- **Parts.** Fixed field names in fixed order; lists are bracketed and comma-joined over elements with no free commas (`watch.rs:189-197`, `game.rs:126-139`).
- **One loose end.** `buys` in `Own::written` is written without escaping (`game.rs:362`). Only the four upgrade names can be there, so it is harmless as things stand.
- **Requests.** `Ask`'s equality is bit for bit on numbers and by content on names (`game.rs:401-412`), so equal requests are identical inputs to `take_in`.

## Claim 7. The second doing is the same function: holds

- `redone()` (`watch.rs:592-600`) reads only the record's copy, `asks_again` and `in_web(&self.record.world)`. The live state is read only for the comparison.
- The work has no clock, no changing static, and no unordered iteration.
- Within the fault model no stored value feeds both doings: state against record copy, `asks` against `asks_again`, the moths observer's list against `in_web` of the record.

Outside the model, one stored value does feed both: the web plans, worked out once and kept in one copy (`plans()`, `game.rs:631-634`). A changed step there would send both doings the same wrong way. No rule checks a step's place, so it would be recorded as true for good. This is argued only. Safe Rust cannot write there, the compiler refused the cast I tried, and I did not go round it. The round's `dt` and `now` are likewise one value each for both doings.

## Claim 8. Fingerprints: holds

- Every part is held in full by three observers (`RINGS`, `COORD`, `watch.rs:56-58`). Each compares the full text with the state at 363, and with the other full holders at 369.
- The gate compares full texts (449, 454).
- `all_hold` (335-337) needs the full holders.
- In `observers_off()` a coordinator is reached first for the world's parts, but the loop goes on to `edge`, which compares in full. A fingerprint collision passes nothing.

## Claim 9. The wiring: holds by reading

- **Full mesh.** `rule()` (359-392): every member checks every part of its ring, every other member's copies, signal, running and shape. In the world's ring every member also checks the moths list.
- **Flags.** One flag on a sound observer reaches both rings in two passes through `whole` (425-437).
- **Stopping.** Any flag on a sound observer and any stale signal stop everything (441-443, 761-773). The halt is one flag for the whole game.

This matches `wiring.py:18-34`.

Two notes:
- `why` alone is checked by the gate only.
- All eight signals are compared with the one counter `rounds`. That is a shared value outside the wiring; in run D a NaN there ended in `stuck`.

The model check was not run: the checker is not in the folder.

## Claim 10. A halt that cannot be put right: holds, with corrections

- `round()` returns before anything when `stuck` (`watch.rs:750-757`).
- `stick()` clears `asked` (519-526), and `fail()` makes its halt with `asked` false (513). Only `put_right()` (943-947) sets it.

Corrections to the claim as worded:

1. `begin_again()` (931-937) keeps only the setting and the count of games. The counts of halts and restarts start again at nothing. It is `fail()` (505-515) that carries halts, restarts and games across.
2. The new game's chance is seeded from the old game's `rounds` (932). That is one number of the old game.

Argued from the code; not run.

## What I could not check, and why

- **The model check of the wiring.** The checker is not in the folder.
- **A fault in the web plans.** The compiler refused the write, and I did not go round it.
- **The program running.** Not started. `main.rs` was read only.
- **A debug build.** Only release was built, with and without overflow checks.
- **The author's own tests.** Not run. Mine rely on the author's helpers being sound.
- **Faults landing inside `take_in`, `world_work`, `spider_work` or `redone`.** Not placed; only between statements, as asked.
- **A changed or lost entry in a non-empty list during a round.** Only additions were run; the rest is argued.
- **`page.html`.** Not read.

## Outside the ten claims

- **Bookkeeping.** In 900 cases (D), none recorded a wrong round, including lines pushed into `inside`.
- **The counts in a debug build.** With `halts` at its maximum, the next halt would panic, and `fail()` would then overflow again at `watch.rs:510`, outside any catch (`main.rs:107-110`), ending the game thread. That needs a bookkeeping fault and a debug build. Argued only.
- **Locals in a round** (`held`, `asked`, `made`, `seen`) are not in the fault model. By the same argument as claim 3 none can record a wrong value: `made` has two halves, `seen` reaches only the observers, and `held` reaches only the live doing. Argued only.

## What I changed in the copy

- **`src/watch.rs`, outside the test module.** Ten test-only hooks, each `#[cfg(test)]` and marked `REVIEW HOOK`. They reuse the existing `late` field with new instant numbers (10 to 18, and 20), in `round()`, `record_now()` and `write_record()`. No other program text was changed.
- **`src/watch.rs`, test module.** The `zz_review_*` tests and their helpers, at the end.
- **`review-out/`.** The runs' outputs.
- **Build flags.** Two runs (G, H) were built with `RUSTFLAGS="-C overflow-checks=on"` into `./target`. The last build was the plain command.
- **Machine time.** Run E took five minutes of processor time, longer than I meant.
- **One command outside the folder.** It tried to put a backup of `watch.rs` one level above the review folder. It was refused before anything was written, and I did not retry.
- Nothing was sent to port 8138, and no process was stopped.
