# Independent check of the gate proof: hand-back

**In the first lines.**

- **The sandboxed judge accepts all fourteen in my own run.** `lake comparator` and `lake comparator --paranoid`, under WSL with bubblewrap, on clean copies, both ended "Your solution is okay!" with exit code 0. A third run with `--json` reports `"sandboxed": true, "judgement": "accepted"`.
- **No statement says something other than what `claims.md` says of it.** Against `asked-for.md`, T2 is weaker than the wording asked (as declared), `T2_at_once` covers one case only, and T5's spacing is narrower in two ways and wider in one (as declared). Two things a reader could miss: T1 is about the one write at R36 and not about what the record holds at the end of the round, and T2 does not say what the books and the lists hold.
- **One thing in check 1 could not be confirmed as asked:** there are 60 `set_option` lines in the proof files. They are linter switches, heartbeat limits and a recursion depth; none is in a definition or statement file.
- **I found no place where the model and the program differ in a way that would make a theorem true of the model and false of the program.** In 11,757 situations run in both, 11,616 were the same. The 141 that differed fall in three groups, each explained below, and in each the program's outcome is one the theorems allow.

All line numbers are those of `«CHECK»\code\src\watch.rs` unless another file is named.

---

## Check 1. It compiles, on the three axioms

**What I ran.** `lake build` in `«CHECK»\lean\` from clean (no `.lake` before), Lean 4.37.0-rc1, on Windows. Then `lake env lean Axioms.lean`, a word-bounded search of every `.lean` file, and the project's own `test\SelfTest.lean`.

**What I found.**

- The build completed: 35 jobs. Warnings only: two unused simp arguments in `Eval.lean`, one unused variable in `Proofs\Generic.lean`.
- `sorry`: 14, all in `Challenge.lean`, one per statement. None elsewhere.
- `axiom`, `native_decide`, `unsafe`, `implemented_by`, `extern`, `opaque`: none in any file.
- **`set_option`: 60 occurrences, so this part is not confirmed.** They are in the ten files of `Proofs\` and in `Solution.lean`; none is in `Model.lean`, `Claims.lean`, `Toy.lean`, `Challenge.lean` or `Eval.lean`.

  | Kind | Count |
  | --- | --- |
  | linter switches (`linter.unusedSectionVars`, `linter.deprecated`, `linter.unusedSimpArgs`, `linter.unusedVariables`) | 39 |
  | `maxHeartbeats` (2,000,000 twice, 4,000,000 three times, 40,000,000 thirteen times) | 18 |
  | `maxRecDepth 100000`, on the three T6 proofs | 3 |

  These set how long the elaborator may work and which lints print. They do not change what a kernel accepts, and the judge re-checks every proof with kernels.
- Dependencies: none. `lake-manifest.json` has no packages and every import is a module of the project.
- Also present, none changing a meaning: one instance in `Model.lean` (`decEqFun`, equality of functions on finitely many places), derived `DecidableEq` and `Repr`, two tactic macros in the proofs, one `@[simp]` lemma, one `@[noinline]` in `Eval.lean`, and `decide +kernel` in the three T6 proofs. No notation, syntax or coercion is defined anywhere.
- Axioms: each of the fourteen prints `[propext, Classical.choice, Quot.sound]` and nothing else.
- `test\SelfTest.lean`: 1,522 faults, result `[]` (no violation).

## Check 2. The judge accepts it, in its sandbox

**Where.** WSL, user `«USER»` (uid 1000), Lake 5.0.0, bubblewrap 0.6.1 at `«WSL»/bwrap-local/usr/bin/bwrap`. My folder is `«WSL»/sos-gate-verify-run/`. It holds four copies of `lean\`, each taken before anything was built (I listed each and there was no `.lake`): `lean`, `lean-paranoid`, `lean-json`, `lean-nobwrap`. The copies' files are byte-identical to the project's.

**What I ran, with `COMPARATOR_BWRAP=$HOME/bwrap-local/usr/bin/bwrap`.**

| Run | Folder | Result |
| --- | --- | --- |
| `lake comparator` | `lean` | exit 0. "Build completed successfully (10 jobs)" for the challenge, "(30 jobs)" for the solution, "Lean default kernel accepts the solution", "Your solution is okay!" |
| `lake comparator --paranoid` | `lean-paranoid` | exit 0. "Lean paranoid kernel accepts the solution"; "checked 3416 declarations", "lean4lean kernel accepts the solution"; "nanoda kernel accepts the solution"; "con-leche: accepted 3419 declarations (--verified)", "con-leche kernel accepts the solution"; "con-ron: accepted 3419 declarations (--verified)", "con-ron kernel accepts the solution"; "Lean default kernel accepts the solution"; "Your solution is okay!" |
| `lake comparator --json` | `lean-json` | exit 0. `"sandboxed": true`, `"judgement": "accepted"`; every step `success`: resolve_dependencies, build_challenge, export_challenge, build_solution, export_solution, compare_statements, check_axioms, kernel "Lean default" |
| `lake comparator` with the variable unset | `lean-nobwrap` | exit 2: it refuses to start and asks for `bwrap`. So the accepted runs did use it |

The logs are copied to `«CHECK»\work\judge\` (`comparator-plain.log`, `comparator-paranoid.log`, `comparator-plain.json`).

The author's statement that the sandboxed run could not be made is out of date: it can be, with the bubblewrap already unpacked in WSL. My paranoid run is on the final files.

## Check 3. Each statement: what it says, against `claims.md` and against what was asked

I read `Challenge.lean`, `Model.lean`, `Claims.lean` and `Toy.lean` and wrote my reading of each statement before opening `claims.md`.

| # | Name | My reading | Against `claims.md` | Against `asked-for.md` |
| --- | --- | --- | --- | --- |
| 1 | `reach_clean` | Given Y1 to Y4, every game got from a new game by things asked, "Put it right", changes of setting and rounds with no fault is clean | same | not asked for; it is what lets "every state the program can reach with no fault" be read as `Clean` |
| 2 | `nofault_round` | From a clean game, a tick with no fault is recorded, records the first text's work on the record and the voted list, finds nothing, and leaves a clean game whose record is what was recorded | same | not asked for; supports T1 and T2 |
| 3 | `T1` | From a clean game, for any one fault: the value the round writes at R36 is absent, or equal to the value the same tick with no fault writes at R36 | same | same as worded, with hypotheses Y1 to Y4. It is about the write, not about the record at the round's end |
| 4 | `T2` | One fault, then any number of ticks with none. At any point where nothing is halted and the voted count of halts has gone up: state = record, the record's halves agree, every observer is as a new one, books agree and hold no halt, `before` agrees, lists agree, and the record is the fold of fault-free work over the rounds the faulted run recorded | same | **narrower** (weaker), as declared |
| 5 | `T2_at_once` | If in the fault's tick something was found, a halt ended and work began, everything stored equals the same tick with no fault, but each book has one more halt and one more restart | same | **narrower**: one case, under three hypotheses about what the round did; exact in that case |
| 6 | `found_counts` | In the fault's tick the voted count of halts goes up by one exactly when something was found | same | not asked for; ties T2's hypothesis to "found" |
| 7 | `T3` | One fault, then any number of ticks with none: at the end of every tick the voted book holds no stuck halt | same | same |
| 8 | `T3_ends` | In any later tick that reaches its round halted: if the setting is at once, or the halt was asked to end, or the setting is after a pause and the pause is over, nothing is halted after that round | same | not asked for; adds that the halt does end |
| 9 | `T4` | One fault and one more tick: a detection halted everything in the first tick or the second, or else after the second tick the whole game equals the run with no fault and both rounds wrote what they write with no fault | same | same; "gone" is stated more strongly than asked |
| 10 | `T5` | Any run of ticks with faults that keeps `Spaced`: never stuck at the end; if no fault is outstanding the game is clean; if a halt has ended with no round recorded since, everything agrees; in both the record is the fold of fault-free work over the recorded rounds | same | **narrower and, in one clause, wider** in its spacing, as declared |
| 11 | `Toy.sound` | The toy game meets Y1 to Y4 | same | not asked for; shows the assumptions can be met |
| 12 | `Toy.T6_wrong_recorded` | On the toy, both halves of the record of part 4 changed to 99 before one round: not halted after, recorded, and not what the round with no fault records | same | same |
| 13 | `Toy.T6_stuck` | The two halves changed to 98 and 99: stuck after the round | same | same |
| 14 | `Toy.T6_spacing` | The same fault (record's copy of part 4, before R24) in two rounds running: not stuck after the first; in the second a halt ends and the game is then stuck | same | same; a pair across two rounds |

### Every one that is not "the same"

**T2, against what was asked.**

- *Is the asked wording false of the model?* Yes. In the toy model, with part 4 of the state changed immediately before R21 and halts ending on a click:

  | After | State and record | All three places of `before` |
  | --- | --- | --- |
  | before the fault | `[25,26,27,10,33,28,29]` (call it T) | the state the round before began with |
  | round n+1, asked, halt ended (1 halt, 1 restart, refused count 1) | T | `[25,26,27,10,38,28,29]`: T with part 4 changed, a state that was never the game's |
  | the run with no fault, same round | two rounds further on | the state its last round began with |

  So it fails for `before`, for the counts of halts and restarts (trivially), and for the state and record "at the same round", because the refused round is lost.
- *Is it false of the program?* Yes: see the counterexample under check 4.
- *Is the weaker form the most that is true?* No. More is true in everything I ran and is not stated. At every round-end with the halt over (34,325 in the program, 34,655 in the model) each of the three books equalled the fault-free twin's in halt, setting, stops, note of the clock, time and number of the round. `claims.md` says this of the books and the lists and says neither is a theorem. Nothing can be pinned for `before`.
- *Does it still mean "put right"?* For the state, the record and the observers, yes in a sense I would accept: nothing a fault wrote survives in them, and the record is what fault-free work makes, round by recorded round, of the last good record. A reader should know five things it does not say:
  - Rounds are lost: the round of the fault if it was refused, and every round of the halt. The game's time moves on meanwhile.
  - The reference for later rounds is the faulted run's own voted list, length and time, not the fault-free run's.
  - `Settled` is not `Clean`: the count of refused rounds can still be 1 until a round is recorded. That residue is what `T6_spacing` uses.
  - It says nothing while halted, and nothing if no halt ever begins (T4 covers that).
  - It does not say the halt ends. `T3_ends` does, under its conditions.

**`T2_at_once`.** Its three hypotheses (`found`, `ended`, `worked`) are fields the model adds to say what a round did. That "set to at once and found before the work" implies them is not a theorem; `claims.md` says so. In my table every such situation in the program (1,355) ended equal to the twin.

**T5 and `Spaced`.** `Spaced` allows a fault only in phase `ready`. Against the sentence asked:
- Narrower: at most one fault per tick, and the next fault no earlier than the tick after the recorded round (not at R37 or R38 of that round).
- Wider: a fault that halted nothing for two ticks is taken as gone, and a next fault may land. T4 justifies this, and since T5 is proved with this definition the clause is sound.
- The spacing is a real condition, not an empty one: `T6_spacing` shows a run that breaks it and gets stuck.

### The points to look hardest at

- **`Sound P`.** It has a real instance (`Toy.sound`, proved; the toy is small but not degenerate). Its four fields are Y1 to Y4 and nothing else is carried in. Y3 is strong: for every state both texts of the rules accept, every list, length and time, the fault-free work passes the gate. For the program this is an assumption supported by samples.
- **`Clean P g`.** Not less than reachable: `reach_clean` proves every reachable game is clean, and a new game is clean. It is wider: any agreeing books, lists and `before`, any counts of halts.
- **Quantifiers.** Every `Fault` is covered: any cell F1 to F7 to any value (a whole observer or a whole book, which is more than one field), immediately before any of the 38 steps or at any position among what happens between rounds, and any observer's answer absent or replaced. Fewer than a reader of the asked text might assume: no instant inside a step; nothing for the threads kept in three (S9); an answer only at R10, not inside `correct`.
- **T1.** `recorded` is set only at R36, to the same value written to both halves of the record, so it is about what is written. Unsaid:
  - A fault to the record after R36 (before R37 or R38). In the model and in the program the round is then "recorded as with no fault" and the record is wrong at the round's end. It is found at R14 of the next round and put right. This was 18 situations in each table.
  - The observers' copies and the state, changed after R31 (`claims.md` says this).
  - The writes `restore` makes to the record (P4 b1 to b4). T2's ledger covers their result once the halt has ended.
- **T3 and T4.** They do exclude a stuck halt and an unfound, lasting fault for every fault of the model, at the model's instants. "Found" means a detection halted everything in that round, not that the reason names the fault.
- **T6.** The three pairs do show what is said. The game they start from meets the assumptions: I checked in Lean that `Reach P base` holds (three fault-free rounds from a new game, then a change of setting). They are about the toy. The program's own three tests for the same edges pass; I ran them by name in my copy.
- **`Solution.lean` against `Challenge.lean`.** The fourteen statement texts are identical, under identical `variable` lines. No name of the model is redefined in the proof files, which add only new names, and no notation, instance or coercion is added there. The judge's `compare_statements` step, which compares the elaborated statements, succeeded.

**Two small inaccuracies in `claims.md`, neither about a theorem.**
- It says the program "cannot say that no two books agree". The reason `stick` writes at line 506 does say it.
- "Every theorem carries `Sound P` and starts from `Clean P g`" is not so for `reach_clean`, `Toy.sound` and the three T6 statements.

## Check 4. The model against the program

### By reading

**The specification against the code.** I read `protocol-spec.md` against `watch.rs` 1 to 2102, `watch\looks.rs` 37 to 92, and the parts of `main.rs`, `game.rs` and `backdoor.rs` it leans on. I found no step whose order, condition, comparison or write differs from the code. What the code has and the specification leaves out, each named in its section 12:

| What the code has | Where | Specification |
| --- | --- | --- |
| Detections by counts | `right_counts` 572-587, called at 602, 1207, 1366; `counts_off` 882-890, used at 896 and 1005; `differs` 801-803 | A8; H1 does not list them |
| The hold on the threads and what they are run by, each in three places, compared between R6 and R7; two more ways to a stuck halt (1397, 1415) | 1381-1419 | A7, S9, P6 |
| A stop in the wrong place | `stopped` 597-615, `fail` 944-959, `main.rs` 314-352 | A12 |
| The branch of `correct` for a new observer that does not answer: the halt stays, not stuck | 1166-1174 | A7 |
| Lines kept to be written during the work; a refused round counts only if none was waiting | 1445-1454, 1486-1495, 1515 | A9 |
| Cutting down at six points, and of the halted-moths list | `fit` 846-879; 696-704 | A8 |
| The number of the round read once for R9 to R11 | 732 | noted at R9 |

**The model against the specification.** `Model.lean` follows it item by item. The differences I found, none of which changes an outcome with one fault:
- The round's time for R1 is read in `start`, not in the step. It is the same voted value.
- R12 writes the spread flags at once, not one by one. The result is the same.
- R23 keeps the whole state after taking in where the code keeps four things from part 6 (1475). The model's rules are any function of that, which is more general.
- Numbers of rounds are whole numbers (A11).
- A cell fault still lands if the round has ended early.

### The list of abstractions against the fault model asked for

- **Left out and inside the asked fault model: S9**, the hold on the observers' threads and what the threads are run by, each kept in three (434, 1853). By reading: one place changed is out-voted wherever it is read (`threads` 544-553, `Threads::run` 1883-1892), found at 1381-1419 of the next round, put right from the other two, and brings an ordinary halt. The stuck branches need no two to agree. The program's two tests for it pass (run by name in my copy). It is not in the model and no theorem speaks of it.
- **A10, ten fields of the book as one value.** A single fault can act through this only by making the three places differ, which the model has. The program can write over the changed field and so never find it; I show this happening below. Reads are voted, so the changed place is never used.
- **A12 and A2, a stop in the wrong place.** A single changed value could act here: if it made the round or the screen's text stop the program twice, the game would be put aside whole, a stuck halt the model cannot show. I tried this directly (below) and found none.
- **A8, sizes and counts.** A list made larger is outside by the brief. A list one shorter is a count the model fixes. I tried nine such faults (below); the program handled all.
- **A7, answers inside `correct`.** These are a second fault in one halt, since a halt begins only with a fault.
- **A1, a part and its text are one value.** By reading it holds: finite numbers are written so that different ones differ (`backdoor.rs` 52; `-0` is written apart from `0`), texts are escaped one-to-one (`backdoor.rs` 67-87), and every field is written.
- **A5, A11, A13:** no single fault of the asked kind acts through them that I could find.
- **Not in the asked list and not in the model:** what a round holds only while it runs (`made`, `seen`, the look, `dt`, `now`). `made` is what gets recorded. By reading, a change to it lands in one half of the record and is found at R14 next round like a record fault.
- **Instants inside a step** are argued in section 11 of the specification, not modelled. I read the compound steps (R11, R12, R14 to R16, R21, R33 to R35, R38 and the three-place writes) and agree with the argument. For a fault in the middle of the work, T1's conclusion rests on R31 comparing the result with the second doing from the record, whatever the work made of it.

### By running: my own comparison

**How.** In a throwaway copy of the program (`«CHECK»\work\rust-copy\`) I added test-only hooks immediately before every one of the 38 steps and a way to replace one answer. `differs`, `ruled` and `redone` were split word for word to make room for the hooks; eight of the program's own tests, run by name, still pass in the copy. A test writes what the program does in each situation. The model was evaluated on the same situations with the toy game, through `roundE` (proved equal to `round`) in a copy of the Lean project (`work\lean-eval\Compare.lean`).

**How many: 11,757 situations.**

| Table | Situations | Made of |
| --- | --- | --- |
| Main | 10,902 | 3 settings x (95 faults x 38 instants + 24 answer faults) |
| Between rounds | 855 | 3 settings x 95 faults x 3 placings among an upgrade asked and "Put it right" |

**Of what kinds** (main table):

| Kind | Faults | Situations |
| --- | --- | --- |
| A part of the state (parts 0 to 6) | 7 | 798 |
| The record's text (parts 2, 4, 6) | 3 | 342 |
| The record's copy (parts 2 to 6) | 5 | 570 |
| A book (round number, a halt, refused count, setting, time, count of halts, a said field, stops, `inside`) | 9 | 1,026 |
| A place of `before` | 3 | 342 |
| A list | 5 | 570 |
| An observer, all eight (stopped, signal, a copy it holds, a copy it should not hold, its list, flag, reason, name) | 63 | 7,182 |
| An answer, all eight observers (none, another, "found nothing") | 24 | 72 |

5,700 of the situations are at the twenty instants `claims.md` says were not run: before R2 to R6, R9, R10, R12, R18, R19, R21, R23, R24, R25, R27, R28, R29, R31, R34, R35. Observers 1, 2, 4 and 7, parts 0, 1 and 5 of the state, and the between-rounds placings were not in its table either.

**What is compared**, after each of five rounds (the fault's, one more, "Put it right" and a third, two more): halted; stuck; counts of halts, restarts and refused rounds; rounds recorded and worked; which check made the halt, and of which part or observer; state = record; which parts of the record disagree with themselves; which observers are not as new; whether lists, books and `before` agree. I added three: the record equals a fault-free twin's; everything stored equals the twin's; the books equal the twin's but for the three counts.

**Whether any differed.** Main table: 10,761 the same, 141 different. Between rounds: 855 of 855 the same. The 141, in three groups:

1. **69: a book's `inside` field, changed in one place, before R4 to R26.**
   - The program clears `inside` in all three places during the work (1486-1487), so the place agrees again and is never found.
   - The model keeps that field in `rest`, which no step writes, and finds it at R1 of the next round.
   - This is the difference A10 declares. The program's outcome is "gone", which T4 allows.
2. **42: which part is named in an observer's finding** (round 2, observers 0 to 3 stopped or with a changed signal before R33 or R34). The program says "copy of part 1 differs", the model "part 0". In the program the first set of legs did not move in that round (I checked: the work moved parts 1, 2, 4, 6); the toy moves every part every round. Halted, recorded and put right are the same.
3. **30: a foot's place in the state, changed before R16 to R25.** In the program the work writes over it: the round is recorded and equal to the twin. The toy's work adds to the part, so the model refuses the round. Before R16 to R21 the program keeps the changed state in `before` for one round, exactly as `claims.md` says under T4. The outcome is "gone", which T4 allows.

**In the program by itself, over the 10,902:**
- No halt was stuck at any round's end.
- Every fault was found in its round (7,833) or the next (2,058), or was gone after the second round (1,011, all equal to the twin).
- Of 4,424 rounds recorded in the round of the fault, the record was the twin's in all but the 18 where the fault changed the record after it was written.
- No situation had a second halt.
- At all 34,325 round-ends with the halt over, everything agreed.

**Three further runs in the program only, with the game run as `main.rs` runs it** (a stop in the wrong place caught and told to the game):

| Run | Situations | Result |
| --- | --- | --- |
| One value of the state or of the gate's copy changed to an extreme one (not a number, the infinities, 1e308, 1e18, negatives, zero, minus zero, a denormal, 2^53, small numbers; texts emptied or replaced; flags turned). Three starting games, three settings, seven instants | 183,330 | 155,592 with exactly one halt, 27,738 with none. No stop in the wrong place, no stuck halt, none with more than one halt, none still halted at the end |
| Nine lists made one shorter (an observer gone, a text of the record gone, a copy gone, a leg gone, a moth gone), all 38 instants, three settings | 1,026 | 972 with one halt; nothing odd |
| A halt left standing 1 to 100,000 rounds on a click, then asked to end, then 2,000 rounds played; four starting games | 60 | all ended at once and none halted again. This is where Y3 is leaned on hardest |

### The counterexample to T2 as worded, in the program

My test `checker_t2_counterexample` changes `world.tally.caught` by 5 immediately before R19, R20 and R21, with halts ending after a pause and on a click (six cases). It asserts each cell of the table and passes:

| Round | Halted | State | Record | `before`, all three places |
| --- | --- | --- | --- | --- |
| n | yes, not stuck; one halt, refused count 1, nothing recorded | moved on | T, both halves | T with part 4 changed |
| n+1, asked | no; one restart | T | T | T with part 4 changed; never so in the fault-free twin |
| n+2 | no; worked and recorded | new, = record | new | T |

In round n+1 every observer is as a new one and the books and lists agree. The program does what the table in `claims.md` says.

---

## In plain words: what has been shown, and what has not

**Shown, by proofs a machine has checked (in a sandbox, by six checkers), about a written-out model of the protocol.** It assumes the game's two texts of the work agree and that work done without a fault passes the gate's checks. Starting from any state where everything agrees, one changed value of any kind the model has, at any of 38 points of a round or between rounds, or one observer's answer missing or wrong:
- It never makes the round write a wrong value into the record.
- It never leads to a halt that cannot be put right.
- It is found within two rounds, or has vanished completely by then.
- Once the halt has ended, the state, the record and all eight observers agree and hold what correct work makes of the last good record.
- A halt does end in the round where its setting says it should.
- The same holds for any number of faults one after another, if each waits until a round has been recorded after the last.
- Three examples on a toy game show that two faults close together can do what one cannot: a wrong value recorded, or a stuck halt.

**Shown about the program, by running it.**
- In 11,757 single-fault situations covering every one of the 38 points, the program and the model did the same in all but 141. Those are explained by one field the model does not follow and by the toy game not being the real game.
- In those runs and in 183,330 more with extreme values, the program never recorded a wrong value, never reached a halt that cannot be put right, never stopped in the wrong place, and always ended with everything agreeing.
- The one sentence of the request that is false is false in the program too, harmlessly: after a halt, the saved "state from when the last round began" can be a changed state until the next round overwrites it.

**Not shown.**
- That the program's source text is the model. This rests on two readings (the author's and mine) and on sampled runs. No machine checks it.
- The four assumptions about the real game. They are supported by tests, not proved. If the real game's own work could fail its own rules after some state or some length of halt, a single fault could end in a stuck halt and the proofs would not see it.
- A fault landing part of the way through a step, or during the putting right. That is argued, not proved.
- Anything about the observers' threads, the two things kept in three for them, lists made too large or too short, the program stopping in the wrong place, or a halt after a pause ever ending. My runs found no trouble with the short lists and the extreme values, but a run is not a proof.
- What two faults do in general.
- What the three books and the three lists hold after a halt, beyond agreeing. In my runs they held what they should.

## What I could not check, and why

- **The author's 2,604-situation comparison and the three reviews.** They are in the folder I was told not to read. My comparison is my own and larger.
- **Y1 to Y4 for the real game.** They are statements about every state. I ran samples only (the long-halt run, and the program's own word-for-word tests exist but I did not run those two).
- **Instants inside a step.** My hooks are at the 38 step boundaries, as the model's are. The inside of R19, R6, and of the work itself was read, not run.
- **The observers on real threads, and S9, beyond three of the program's own tests.** All my situations ran the observers together, as the tests do. Timing faults are outside the brief.
- **The whole test suite.** By the rules I ran only named tests: my own seven, and fifteen of the program's.
- **Exhaustiveness of the extreme-value run.** It covers the body, the old body, two legs, the edge, the counts, the web, the shop, two moths and the game's own part, in the state and in the gate's copy, at seven instants. It does not cover every leg, every instant, or values in an observer or a book.
- **Lean's kernel and the checkers themselves** are trusted, as the judge's own notes say.

## Where my files are

- `«CHECK»\work\judge\`: the judge's logs.
- `«CHECK»\work\tables\`: `rust-table.txt` and `lean-table.txt` (10,902 rows each), `rust-between.txt` and `lean-between.txt` (855 each).
- `«CHECK»\work\scripts\`: `patch_rust.py` (the hooks), `tests_all.rs` (my tests), `compare_tables.py`, `table_props.py`.
- `«CHECK»\work\rust-copy\`: the throwaway copy of the program; its build output is in `work\target\`.
- `«CHECK»\work\lean-eval\`: a copy of the Lean project with `Compare.lean` and `Probe.lean`.
- `«WSL»/sos-gate-verify-run/` in WSL: the four judged copies and logs.

`code\` is unchanged. `lean\` is unchanged but for the build output in `lean\.lake`. Nothing of mine is still running.
