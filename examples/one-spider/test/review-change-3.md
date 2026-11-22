HAND-BACK: independent check of the change in `after/`

Folder: `«WORK»\check-four\code\`. All line numbers are into `after/src/` (`watch.rs` unless another file is named).

## Verdicts in one place

| Claim | Verdict |
|---|---|
| 1 Three places of `Book` | holds (1a, 1c); 1b holds except that a few changes are written over and never found, harmlessly |
| 2 Earlier counterexample | holds (closed) |
| 3 A silent observer | holds (a–d) |
| 4 Halt waits for the eight new observers | holds on the main points; what is said afterwards is incomplete, and "after a pause" waits a whole pause again |
| 5 Apart and together | holds; two reasons given have changed |
| 6 Eight copies, one rule | holds for the text; the test misses 3 of 10 changes tried |
| 7 Two texts, one work | **fails in part**: the second doing calls back into `game.rs` |
| 8 Counts | holds between rounds; **fails inside a round** (three counterexamples run), and the backdoor panics while a count is wrong |
| 9 `Run` and `before` | holds |
| 10 Length of a round | holds |
| 11 One observer alone | holds; the reason for stopping is sometimes not said |
| 12 The wait is bounded | holds (argued only) |
| 13 Nothing put right before is lost | **fails for one fault**: a text too many in the gate's record, inside a round, "at once" |
| 14 Three lists | holds; a third outcome exists beside the two the claim names, harmless |
| 15 Hold on the threads | holds |
| 16 Apart as built | holds for the build; the comment in `game/again.rs` is incomplete |
| 17 The program's own entry | holds |
| 18 The game's own time | holds for a jump; **fails** when the instant counted from moves into the future |
| 19 Nothing kept, nothing lost | holds |
| 20 Two texts of the rules | holds |
| 21 New tests | most test what they say; three do not, listed there |

## How I checked

- I read `after/` and `before/` in full where the claims touch them. Tests ran in throwaway copies inside the folder: `work/` (a copy of `after/` with test-only hooks and my tests in `work/src/watch/mine.rs`), `work-before/`, `mut/` (one change at a time, one named test each, driven by `work/mutate.py`) and `stopcopy/`. `after/src` is untouched; `after/target/` is build output of mine.
- Instants inside a round, by test-only hooks in `turn()` unless said:
  - A: start of `turn`, before 1026
  - B: after the count, hold and `Run` checks, before 1106
  - C: between 1106 and 1107
  - D: inside `watch()` after 580, before any observer is asked
  - E: after 1107
  - F: before 1140
  - G: before 1145
  - H: before 1148
  - I: after the work (the existing `fault` hook, 1151)
  - J: in `record_now` before 763
  - K, L: the existing `late` 1 and 2 (772, 820)
  - R1: in `round_at` between 1004 and 1005; R2: after 1006
- Toolchain: rustc 1.98.1, x86_64-pc-windows-msvc.
- The 26 tests of `after/` that match the new names pass here, as do `left_alone_for_half_an_hour_it_never_halts` and the two `observers_on_threads_of_their_own_find…` tests.
- I ran the program on port 8190 and a throwaway variant on 8191. Mine was stopped by its process id (20776) or ended by itself. I sent nothing to 8138 and stopped nothing by name.

## 1. Three places: never read, always found

**1a holds.** `books` is named only in `Deref` (392–404), `keep` (408–412), `settle_books` (416–445) and `Game::new` (508). Every other read goes through `Deref`, which returns a place that agrees with another. `fail()` (693) and `begin_again()` (1299) read through the vote too. No write reaches fewer than three places, and no written value is worked out from one place: closures passed to `keep` use values read through the vote beforehand, or the book they are given.

**1b holds, with one literal exception.** Run: 1,344 cases (24 kinds of field, places rotated, instants B–L, two starting games, "at once" in full and the other two settings at three instants).
- The round the fault lands in goes exactly as an untouched twin's, and `shown()` is the same.
- The next round halts for the three-places reason and puts it right. Under "at once" the game stays round for round with the twin. Never stuck.
- The exception: 30 combinations are never found, because the program's own next write makes the place agree again. These are `inside` before 1159, and `spoiled` and `pending` before 1170–1173.
- Argued only, same kind: `at` between 1004 and 1006 (run at R1: written over), `time` between 1026 and 1028, `how` by a `/how` request before the next round, and saturating or rounding sums that converge.
- This does not matter. The two agreeing places always hold what a fault-free run holds, the changed value was never read, and afterwards it is gone. But "found at the start of the next round" is not true of these.

**1c holds.** The two untouched places get the same deterministic write, so they always agree. The stuck arm (436–443) needs two faults.

`fail()` builds a new game with three equal books. `begin_again()` carries `how`, `games` and `at` from the vote. Both copy `apart` as its three places stand (695, 1308).

## 2. The earlier counterexample is closed: holds

- Run: 189 cases. NaN, +1000, −1, infinity, 1e300 and 2^53, in one place, at instants A, B, C, D, E, F, G, H and J, under all three settings, each observer on a thread.
- In every case the round goes on under the right number and equals the twin's; the place is found (same round at A, next round otherwise) and put right; a later stalled observer is found ("the body observer did not answer in time").
- Run: 9 cases with the program's own waits (8 × 5 ms). After the fault and its putting right, an observer answering 400 ms late is found. Through 40 further halted rounds its stray answer is not taken and no other observer is taken for silent.
- Other routes to the same end state, argued: signals are written only from the voted number (574, 591; `born` 544). Within one starting of the threads the numbers of successive looks rise by one. `correct()` looks in the same round only after `again()` has made a new starting and a new channel (852–854, 1569–1570). In a stuck halt the number stands still but nothing looks (1031–1041). I found no one-fault route.

## 3. A silent observer: holds (a–d)

- Run, each setting: a thread that stalls (the author's tests), answers late (mine), ends, or panics (mine, by test-only calls).
- It halts in that round with "the X observer did not answer in time" and nothing moved. Under "at once" it is put right in the round and equals the twin.
- From the next round the others of its ring flag "the X observer is silent". It is put right with eight new threads, never stuck.
- **3b** Nothing it sends later is taken: the new starting has a new channel (1569–1570), and the old thread's send fails (1695).
- **3d** An observer leaves at most one stray answer, because it is dropped (1644–1649) and never asked again. A stray never matches the round (1632). The loop tolerates as many strays as there are observers (1629). So leftover answers cannot cut the wait short. Run as in claim 2.

## 4. The halt does not end until the eight new observers have looked: holds, with two things to know

Run with `spider.body.x += 150` and one of the eight new threads silent:
- The halt stays, `restarts` stays 0, the state is already put back, it is not stuck, and under "at once" no work is done in between (two rounds of the game equal one of the twin).
- "At once" and "on a click" try again in the next round and succeed, with `restarts` 1.
- **What is said is incomplete.** After the second try `fixed` is "all eight observers started again". "The body put back" is lost, because `done` is local to the first call (832, 864–866) and the second `restore()` finds nothing to do. Only `halt.put` and `aside` survive.
- **Under "after a pause" the next round does not try again.** The first try changed the state, so `mend` sees it changed and starts the pause over (973–986). Measured: 38 more rounds, then it ends.
- `restarts` counts completed puttings right, not startings (867).
- Left when `correct()` returns early: parts, record and lists put right; eight new observers; eight new threads with the silent one dropped.

## 5. Apart and together find the same: holds

- Both paths give every observer the same `Look`, built before any signal is written (580), and `look_of` depends on nothing else (1458–1460).
- Run: 6,000 rounds with pointer, presses and buying, round for round the same; plus the author's test with ten faults.

What `before/` found, and `after/`:

| `before/` | `after/` |
|---|---|
| A running observer's own signal changed | Same, same round (`looks.rs` 43–45). The others of its ring now also say "the X observer is silent". The reason given for the halt is the lowest-numbered flag's, so it is now "…is silent" unless X is legs A. |
| Asked and no answer | Same, same reason |
| Part differs from own copy | Same |
| Another's copy differs | Same; a missing copy now counts as differing |
| Another stopped or its signal stale: "is silent" | Same |
| "is stopped" (stopped with a current signal, which takes two writes) | Now "is silent"; the reason "is stopped" no longer exists |
| Out of shape | Same; a wrong number of copies is now out of shape |
| Moths list | Same, each observer working it out from `look.world` |

## 6. Eight copies, one rule: text holds; the test is partial

- Compared by script: the eight bodies in `watch/looks.rs` are 46 lines each and identical once the mark's number is replaced. `LOOKS` (28) is in the order of `NAMES`.
- Against `before/`'s `look_of` the differences are: the mark, the own-signal check first, missing copies, the silent test, the count of copies in shape, and `in_web(&look.world)`.
- The test `the_eight_copies_of_the_rule_are_one_rule`, ten changes to one copy each, run:
  - **Fails for 7**: own-signal check removed; stopped no longer silent; moths list not compared; full copies not compared; reason without flag; `<` for `!=` in the silent test; `>` for `!=` in the own-signal test.
  - **Passes for 3**: the mark's branch (not reachable); letting an observer other than moths hold a list of halted moths; `>=` for `==` in the count of copies. The test has no fault of the last two kinds.

## 7. Two texts, one work: fails in part

- Holds: `game/again.rs` has 34 functions and 24 constants, each word for word in `game.rs`. Its only import from `game.rs` is types (19). In the built program the second-text functions call only second-text functions.
- **Fails:** `again::take_in` calls `own.point` and `own.click` (`again.rs` 124, 126, 129), and the second text also calls `own.gain`, `own.held()` and `chance.next()`. These are `game.rs`'s own (`game.rs` 326, 332, 373, 382). `Own::point` carries work logic and the constants `W`, `H` and `DRAGS`, which are not in `again.rs`; `Own::click` carries the limit of eight.
- Run: changing `Own::point` (`DRAGS * 2.0`) passes `the_second_text_of_the_work_is_the_first_word_for_word`.
- Run: a new helper added to `game.rs`, called by both texts and imported into `again.rs`, also passes; the import line is not checked.
- Run: a line changed in `flutter` in either text alone fails the test.
- No test fails when `redone()` is made to use the first text (run; both the word-for-word test and the apart test pass). That `redone` uses the second text rests on reading 790–792 and on the built program, where `turn` calls `again::take_in`, `world_work`, `spider_work` and `in_web`.
- Never halts when nothing is written from outside: the half-hour test passes here, and my 60,000-round and 20,000-round games had 0 halts.

## 8. Counts: holds between rounds, fails inside a round

Between rounds: the author's tests pass. Inside a round, after the count checks at 1046–1064, all run:

1. **One text too many in the gate's record, "at once", at B, C, D or E: stuck, and the game has to be begun again.**
   - `observers_off` sees eight copies wanted (665) and everything halts.
   - `correct()` makes the new observers from the too-long record (848, 544), so each has eight copies.
   - The new observers find each other out of shape, and 870–872 sticks: "it could not be put right: the legs B observer has been changed".
   - Also run through `round_at`. Under the other two settings the next round's 1046 trims it first and it is put right.
2. **One text too few at B–E: panic**, index out of bounds at 634 or in `restore` (900). In the program that is `fail()` (`main.rs` 305–316) and the game is lost.
3. **One observer too many or too few at any instant B–L: panic**, at `LOOKS[i]` (1459), `NAMES[i]` (606, 655, 1362), `look.ring[7]`, or `self.ring[i]` in `shown()` (1337). Same end.

Other results, run:
- At F–J a text count is caught as "the copies of the legs A observer changed while the round was being worked" and put right.
- A copy too many or too few inside a round is found and put right. At K the record or copies are simply rewritten.
- The backdoor between rounds while a count is wrong panics: for example `world.ring[2]`, `world`, or `world.ring[2].alive = false` with the last observer gone; `spider.ring[1].copies[6]`, read or written, with a copy too few (`backdoor.rs` 371, 470, 477). `main.rs` 565 catches it and refuses the line; the program goes on. So "no panic anywhere" fails; the program does not stop.

Other lists: `all_hold` indexes copies (540) but needs a second fault to be reached. Legs, moths, the three lists, `calls` and `Book`'s lists are walked or bounds-checked.

## 9. `Run` and `before`: holds

- Run: 154 cases, one place of each, with the hold from claim 15, at B–L under "at once" and "on a click". The round goes as the twin's; found the next round; put right; never stuck. A `before` fault landing before 1143 is written over.
- `Run` is read by vote (1525–1534, 1566, 1606, 1628). Running threads hold their own copies from their start (1571–1576).
- `before`: one fault in it could never have mattered in `before/`. It was read only in `restore` when the record disagreed with itself, which is already a fault, and it was rewritten each working round. Run in the baseline: 0 halts after changing it. `after/` now halts once for it.
- `restore()` is unchanged for one fault, apart from reading `began()` (898).

## 10. The length of a round: holds

- Run: 20,000 uneven rounds including no length, backwards and 180 ms, `round` against `round_at`, same state and time each round.
- Run: 600 rounds of no length from six starting games with a press, a letting go and a buy: no halt.
- Run: clocks back, ahead, infinite and NaN: every round between 0 and 50 ms, no halt. A NaN clock gives 50 ms, and so does the round after it, because `at` is then NaN (1005–1006).
- One place of `at` at R1, R2, A, B, F and J through `round_at`: outvoted, and the game's time equals the twin's.

## 11. One observer alone: holds

- Run: calls from startings 7, 8, 7, 9, 8 all return. Calls 3, 4, 3 return, and the next 3 ends the process with code 1.
- Run, throwaway variant where a round never returns:
  - The program ended with code 1 five seconds after the stop, within about a second of the first finding, also with stdout and stderr closed.
  - One lone call two seconds in did not end it.
- **The reason is sometimes not said.** In 3 of 6 runs stderr was empty. A third observer sees `SAID` already set and exits (`main.rs` 287–292) before the second has written. `before/` had the same race.
- With one observer thread left alive, a real stop is never acted on: its one call returns (281–283) and the thread ends (1708–1709). That needs seven silent observers.

## 12. The wait is bounded: holds, argued only

- The loop (1629–1642) continues only while fewer answers than asked, fewer than `most` timeouts, and at most n strays. That gives at most `most` + 15 receives, inside the claimed bound.
- It gives up on stray n+1, not stray n as the comment at 1625 says.
- An answer is taken only if it is of this starting, this round, an asked observer, and the first from it (1632).

## 13. Nothing put right before is lost: fails for one fault

- Every changed or removed assertion is explained: the signal test's reason (thing 5), the lists put right instead of put aside (14), `inside` written through `keep` (1), the held-twice test replaced (1, 2), `stopped` taking a starting (11).
- **Handled worse:** counterexample 1 of claim 8. Run in the baseline: one text too many under "at once" gives halts 1, restarts 1, not stuck, and ten seconds on the record has seven texts again. `after/` at the same instant is stuck.
- `before/` had no count of copies in shape; the new shape check meets observers made from the too-long record.

## 14. Three lists: holds

Run: 840 cases (7 kinds of fault, each list, instants A, B, E, F, G, H, I, J, K, L, with and without things waiting, two starting games, "at once"). Every case ended exactly where the untouched twin is, lists agreeing, `spoiled` 0, never stuck. Three outcomes:
- Found by the gate before the work and put right in the round (A, B, E).
- Round not recorded, halted, put right and worked in the next round. This is the first list at F and G, and the second list at F to I.
- **Round recorded as the twin's and the fault never found**, because the lists are cleared at 1175–1177. This is the third list always, the first after `take_in`, and any fault that made no difference to the result. The claim's "found before any work is done on it, or the round is not recorded" leaves this out. It is harmless: the second doing proved the result is what the right lists give.

Run: 42 cases of a fault in one list while halted for another reason and still being asked things: same end as without it, and the letting go kept.

Readers outside the work go through `asked()` (491–499): `waiting` (1237) and `restore` (943).

## 15. The hold on the threads: holds

- Run: one place emptied, or holding other threads, at B–L. The right threads are asked, the gate finds it the next round (1066–1085), never stuck. The author's test shows no observer takes the rounds to have stopped.
- Every read is `threads()`. The other uses copy all three (695, 1308), compare (1066–1070) or write (1316).

## 16. Apart as built: holds for the build

- The built program starts on 8190, so `copies_apart()` is true of it.
- In the assembly listing the eight rules are eight full bodies of 644 instructions, differing only in their own message. Every second-text function that exists as its own code differs from its first-text twin and stores the mark.
- `copies_apart()` could be true while two copies were one. It compares only 8 + 6 addresses (1425–1433). It cannot see the helpers those call, nor a merged function left as a jump to the other. Neither is so in this build.
- The marks change nothing reachable: the rules' mark answers only for an observer number past the last, which `LOOKS[i]` rejects first.
- The comment in `looks.rs` (17–19) says correctly what is shared.
- The comment in `game/again.rs` (11–13) does not: it leaves out `Own::point`, `click`, `gain` and `held`.

## 17. The program's own entry: holds

- Order in `round_at` (1002–1009): read `time` by vote, compare, read `at` by vote, write `at`, then `turn` compares again (1026) and writes `time` (1028).
- Run: 72 cases, one place of `at` or `time` at R1, R2, A, B, F and J through `round_at`: the round and the game's time equal the twin's.
- `begin_again` leaves `time` at the game's time and `at` at this round's clock (1305). `fail` is given the clock's time (`main.rs` 97, 313) and sets both to it. The new game is consistent with itself, and the first round after either is of ordinary length.
- Nothing else is given the clock: `shown(game.time())` (`main.rs` 307), and the pointer and press take `game.time()` (555, 574).
- Live on 8190: a backdoor write halted and was put right after the pause, and a changed signal was put right at once.

## 18. The game's own time: holds for a jump, fails one way

- A jump either way gives one round of 0 to 50 ms, nothing comes due, and nothing halts (run, claim 10).
- `before/` did not have this. It gave the game the clock's time and had no lower bound on the length.
- **Fails when the instant counted from (`Shared.start`, `main.rs` 64, 87–89) moves into the future.**
  - `elapsed()` is then zero (run: an instant an hour ahead has elapsed 0 ns).
  - The clock reads 0 every round, so every round is of no length.
  - The game stands still with no halt and nothing said, until the machine's clock passes the new instant.
  - Argued for the whole path; run for the parts.

## 19. Nothing kept, nothing lost: holds

- Run: the same game (60,000 rounds, pointer, presses, letting go, buying) in `before/` and `after/` gives identical fingerprints at all 30 samples.
- The two `web_point`s differ only in being handed `plan(web)` of the web they are given (`game.rs` 688, 738, 913).
- Kept for the life of the program: `FOUND` and `SAID` (`main.rs` 274, 286), and nothing else outside the tests.

## 20. Two texts of the rules: holds

- 9 functions and 14 constants in each; the second imports only `Asked`.
- `record_now` asks both for the gate's own copy (753), the state and the step (756–759). In the built program `turn` calls all four.
- Run: a number changed in the second text only fails the test, and a function added to the first only fails it.
- A change to the first text alone: argued, the same mechanism as the work's, which was run.

## 21. The new tests

Fail when the thing is broken (run):
- `…never_read_and_is_put_right` and `…number_of_the_round…never_taken_up` (reads always from the first place)
- `…threads_are_run_by…`
- `the_hold…`
- `a_halt_does_not_end…`
- `an_observer_that_does_not_answer_is_found_by_the_others…`
- `the_copies_are_apart…` (two rules made one)
- `what_is_asked…loses_nothing`
- both word-for-word tests

Do not test what they say (run):
- `a_round_is_held_to_both_texts_of_the_rules` passes when `record_now` asks only the first text. It never goes through `record_now`.
- `the_length_of_a_round_comes_from_the_gates_own_note_of_the_last` passes when the length is read from the first place alone.
- `the_state_kept…in_three_places` passes when `began()` reads the first place alone.
- In the last two the comparison has put the place right before the read, so only a fault inside a round shows the vote.

Partial: `the_eight_copies…` (claim 6). The two count tests cover between rounds only.

By reading only: `…while_everything_is_halted…`, `where_no_two_places…`, `what_is_asked_of_the_game_is_taken_down_three_times`, and the two count tests.

## What I could not check

- Claim 12 under a flood of stray answers: argued, not run.
- The window between 1026 and 1028 for `time`: argued (the same kind as R1, which was run).
- A fault in `Shared.start` in the running program: I did not change memory in a live process.
- Whether the linker would fold helpers in some other build: I looked at this build only.
- The author's 30,000-round thread test and the rest of the suite: not run, as the brief asked.

## Outside the claims

- **`correct()` makes observers from `record.texts` as it stands.** A putting right in the same round as a wrong length of that list is the root of the stuck case in claim 8.
- **`FOUND` is one place.** After any lone saying it holds (that starting, 1). One fault moving its first number to the current starting, then another lone saying, ends the program. That is three faults with recorded rounds between them, the middle one never found.
- **Under "on a click" a starting lasts as long as the halt.** Two lone sayings any time apart inside it end the program. This is out of the model as written, since no round is recorded between.
- Two other copies of the program and another test run were on the machine during the work. None was mine and I left them alone.
