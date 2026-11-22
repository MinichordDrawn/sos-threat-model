# Independent check of the change: hand-back

All references are into the copy made for this check. `after/…` means under
`«WORK»\check-three\code\after\`.
Line numbers are those of `after/src/watch.rs` unless another file is named.

## Summary

Most of the eight claims hold, and I confirmed them by running. Three things do not hold as written:

1. **One counterexample inside the fault model** (confirmed by running). A change to `rounds` that lands inside a round, after the two holdings are compared (line 797) and before the observers' signals are set (line 396), is "put right" with the wrong number. If that number is one that adding 1 does not change (an infinity, 1e300), every later round has the same number. Then a silent observer thread causes no halt at all, and one late answer causes all eight threads to be dropped with no halt. This bears on 1b, 2a, 2b, 3a and 5.
2. **Claim 1d's bound is wrong as worded.** The round waited 72.8 ms, not 40 ms, with seven answers 4 ms apart and one observer silent.
3. **One new test does not test half of what it names.** `observers_on_threads_of_their_own_find_that_the_rounds_have_stopped` still passes with `tick()` removed from the stuck path, and with `Call::Look` no longer resetting the count.

`changes.diff` is the whole difference (I regenerated it and compared). No assertion in an existing test was changed.

## The counterexample (bears on 1b, 2a, 2b, 3a, 5)

**Situation:** a game running normally with each observer on its own thread, any of the three settings. I ran it under "after a pause".

**First fault:** `rounds` becomes `f64::INFINITY` (or `1e300`) inside a round, after line 797 has compared the two holdings and before `watch()` reads `self.rounds` at line 396.

- That round: every observer finds "its own signal changed" and sets its signal to the wrong number (line 407). Everything halts.
- Next round: the two holdings differ, and `holds(one)` at line 799 is true for the wrong number, because the signals were set from it. The wrong number is taken as right (lines 805 to 808).
- The halt is put right (halts 1, restarts 1) and the game goes on. In my run 300 further rounds were recorded with the number at `inf` in both holdings.

**Second fault, hundreds of recorded rounds later:** one observer thread answers nothing more.

- Line 422 sets its signal to `rounds - 1.0`, which equals `rounds`. So `respond()` (line 458) and `observers_off()` (line 493) see nothing.
- Result in my run: no halt, halts still 1, the game moves on, seven threads alive. That observer is never asked again.

**Variant of the second fault:** one observer answers 300 ms late.

- Result in my run: no halt, and 60 rounds later zero observer threads were alive.
- Mechanism, argued from the code: the round number never changes, so the check at line 1252 takes the late answer in a later round. That ends the wait one answer early, a real answer is left over, and its observer is dropped (lines 1262 to 1266). The leftover is taken in the next round, and so on, one observer per round.
- With no threads left, nothing watches whether rounds go on.

**Other values in the same window** (all run, with a throwaway hook at that point):

| Value written to `rounds` | What happens |
|---|---|
| NaN | Ends in the halt that cannot be put right ("the legs B observer is silent") under all three settings |
| +1000, −1, 1e300, infinity | Adopted under all three settings |
| 2^53 | Every observer finds its own signal changed in every round from then on. At once: 251 halts in 251 rounds. After a pause: the game never works again, and is not stuck either |

A second, narrower window exists under "at once" only: from line 396 to `born()` at line 665. Under the other two settings a change there is put right with the right number (run).

A change to `rounds_again` at either point is always put right (run).

`before/` adopted a wrong number at every moment, so this is not a regression in itself. What is new is what a frozen number does to the thread path. Three things combine: line 422 marks lateness by arithmetic on the number, line 1252 does not check that the observer was asked this round, and nothing checks that the number moved on by one.

## Claim 1. Apart and together find the same: **holds**

`watch()` differs between the two modes only in where `answers` comes from (lines 412 to 415). Both call the same `look_of` on the same snapshot.

- The shipped differential test passes.
- I ran a wider one: 26 backdoor lines and 16 direct faults, under all three settings. The direct faults included leg count, both holdings of the round number, the gate's record, requests, signals, a coordinator's copy and name, and two-fault cases followed by beginning again. Round for round I compared state, observers, `why`, halts, restarts, halted, stuck, games, both round numbers, the record, `fixed`, the requests and the whole of `shown()`. All were the same.

**1a: holds.**
- `look_of` (lines 1118 to 1151) is `before/src/watch.rs:366` `rule()` line for line, with `self.text(p)`, `self.ring`, `self.rounds` and `in_web(&self.world)` replaced by the snapshot's fields. `in_shape` (1113) is `shaped` unchanged.
- The snapshot (line 382) holds everything `rule` read.
- Timing is the same. In `before` the eight `rule(i)` calls ran after the signal loop with no write between them, and flags were set afterwards. The snapshot is taken at that same point (line 411).
- One difference, of no consequence: flags are now set only if `beat == rounds` (line 429). Run together, this differs from `before` only when `rounds` is NaN, and the outcome is the same halt.

**1b: fails in one sequence, holds otherwise.**
- Wrong observer: `i` is fixed in each thread at spawn (line 1226).
- Earlier set of threads: `again()` replaces the receiver (line 1220), so an old thread's send fails and it ends. The `start` check is a second guard.
- Wrong round: the bit comparison at line 1252.
- Run: an answer 300 ms late was not counted in any later round under any setting. With the round check removed in a throwaway copy, my test fails; the shipped tests do not (see claim 8).
- The failure is the counterexample above. The round check relies on the number changing every round, and line 1252 does not check that observer `i` was asked.

**1c: holds.** What the round's thread and the observers share:
- The eight `calls` channels. Unbounded, so the round's sends never block. Observers receive with a one-second wait.
- The `answers` channel. Unbounded, so observers' sends never block. The round receives with `recv_timeout(WAIT)`.
- The `Arc<Look>`, read only.
- The standard-error lock and process exit, in `rounds_stopped`.

The observers never touch `Mutex<Threads>` (only the round's thread, and `main` before the rounds start, lock it; no call nests). They never touch the game's mutex. No thread is joined.

**1d: fails as worded.**
- The number of waits that time out is at most `WAITS`. But every message received restarts a wait without using one (lines 1250 to 1257).
- Run, one silent observer: 44 to 46 ms, 8 waits.
- Run, seven answers 4 ms apart and one silent: **72.8 ms and 70.9 ms**, 8 waits. The true bound for the program's own threads is about (`WAITS` + answers received) × `WAIT`, near 75 ms.
- Run, an observer that keeps answering (a throwaway hook; the program's own thread cannot do this): the round was held 446 ms and 1.24 s, still "8 of 8 waits".
- Stops, ends, panics, answers nothing: bounded as above. A thread that had ended before the round is found at the send, with no wait (0.5 to 1.5 ms, run).

## Claim 2. One observer thread that does not answer

**2a: holds from a sound state; fails after the counterexample's first fault.**
- The late observer's signal is set back (line 422). `respond()` is true, `stop_all` runs, and the round returns before the work (lines 840 to 845), or under "at once" is put right first.
- Run for never answering, answering 300 ms late, panicking, and ending quietly between rounds: reason "the … observer did not answer in time", state unchanged through the halt.
- During the halt the late observer's signal stayed one behind and all others were current.

**2b: holds, with the same exception.**
- Run under all three settings for the four kinds above: halts 1, restarts 1, never stuck, eight threads alive afterwards (counted with a throwaway counter), no further halt in 300 rounds.
- Under "at once" the game was where an untouched twin was.
- The thread left behind cannot reach the game: it holds only its two channel ends.

**2c: holds, argued, with two small checks run.**
- Each `recv_timeout` call can return at most one `Timeout`, and each call sets a fresh deadline. So a standstill inside one wait uses that wait and no more.
- Run: `recv_timeout(Duration::ZERO)` returns a message already there, so answers sent before a standstill are still taken. A 5 ms wait lasted 5.0 to 6.0 ms on this machine.
- Not established: I did not read the standard library's source or documentation (outside the folder), and I could not make the machine stand still.

**2d: holds.**
- Run: 300 halts and restarts at once, 5 after a pause, 50 games begun again. At most eight threads alive at any sample, eight at the end.
- Live program on port 8190: 13 threads at the start, 14 after 64 halts and restarts.
- A dropped thread ends when its sender is dropped (lines 1242, 1265, 1222).

## Claim 3. The rounds stopping

**3a: holds.**
- Run in a throwaway copy of the program, with round 200 made never to return while holding the game: the program ended by itself with code 1, 5.1 to 5.2 s after the round began, and the message was said once.
- If no observer thread is left, nothing ends the program. That is reachable only through the counterexample, or if all eight are dropped at once during a halt.

**3b: holds.** What the thread hears on each path:

| Path through `round()` | What the observer's thread hears |
|---|---|
| Working round | `Look` (line 1238) |
| Halt waiting for its pause or a click | `Look`: `watch()` runs every round that is not stuck (line 817) |
| Stopped observer (`alive == false`) | `Tick` (line 1245) |
| Halt that cannot be put right | `Tick` (lines 789 to 791) |
| Round that begins again | New threads, then `Tick` |
| Round that becomes stuck through the round number (lines 810 to 811) | Nothing, for that one round only |
| Dropped observer | Its sender is dropped, so it ends on `Disconnected` (line 1321) and never calls `stopped` |

- Run with a threshold of 0.3 s and each stretch 1 s long: working, stopped observer waiting on a click, observer dropped for a late answer, observer dropped for no answer, stuck through the round number, begun again, put aside by `fail()`. Zero calls throughout. When the rounds stopped, exactly eight calls.
- Live program: 8 s in a click halt with an observer stopped, still running.

**3c: holds.**
- Run with standard error closed, and with everything closed: code 1.
- Run with standard error blocked (a write stuck on a full pipe, holding the lock; a marker file showed the write never returned): the program still ended with code 1 at the same time. Only the first caller writes (`main.rs:260`); the others go straight to `exit`.
- It would not end if standard error blocked and only one observer thread were left.

## Claim 4. The number of legs: **holds**

- Run: a ninth leg and a leg gone, in the state and in the gate's copy, under all three settings, with observers together and apart, from three starting games.
- In the state it is found by the legs A observer in the next round. In the gate's copy it is found by the gate.
- Eight legs are back in both, the state is put back exactly, halts 1, restarts 1, no further halt in 300 rounds.
- No panic, including from `shown()` in every halted round and backdoor reads of `spider.legs[7]` and `[8]` while the count was wrong.
- The same four faults landing after the round's work and at the two late instants were also put right without panic (run). The work and the rules do not index legs by a fixed number (`game.rs:1049`, `rules.rs:135`).
- With the count taken out of `snap`, the shipped test fails.

## Claim 5. The number of the round: **holds as worded (between rounds)**

- Run: 294 single changes. Twelve values (NaN, both infinities, one and two more, one less, 0, its negative, `f64::MAX`, the smallest positive, a half more, 2^53), on `rounds` and on `rounds_again`, under three settings, together and apart, from two games, plus −0.0 in a new game's first round.
- Every one halts with the gate's reason, puts the right number back in that round, is never stuck, restores the state exactly, and ends with both holdings and every signal at the expected count.
- For a change inside a round, see the counterexample.

**One observer's `beat`:** run for 288 single changes (eight observers, six values, three settings, together and apart). The observer finds its own signal changed, the halt is put right, the number stays right. The vote is not taken, because the two holdings agree.

**Whether anything put right before no longer is:** not for one fault. For two faults, a changed signal together with a changed number now ends stuck ("signals do not settle"), where `before` recovered with the wrong number. That is outside the model.

## Claim 6. Nothing written when stuck: **holds**

- Run on six stuck games: put aside by `fail()`; stuck through the round number with a `during` line kept beforehand; stuck through an unsettled record under each setting with a line kept; and work wrong twice running.
- 22 lines tried, including `push()` and `pop()` with spaces, several things on one line, `during` lines, `[*]` writes and copies.
- Nothing changed in the state, the observers, the record, the requests, the kept lines or the round numbers, also after three more rounds. Reads work.
- A line kept before the halt is always cleared on the way (`stop_all`, line 514) and was not written.
- Not a backdoor write, but it does write: while stuck, the pointer's place and a letting go are still taken into `asks` and `asks_again` (lines 935 to 952). They are thrown away when the game is begun again.

## Claim 7. Nothing put right before is lost: **holds**

- The only removed line in the test module is the helper `whole()` calling `in_shape` in place of `shaped`.
- I ran 27 of the 48 earlier tests in `after/`, the single-fault ones; all pass.
- I found no fault that `after/` handles worse for one fault. A wrong round number between rounds is handled better (`before`: NaN ended stuck, any other value was adopted).

## Claim 8. The new tests

| Test | Fails when the thing is broken? | Gaps |
|---|---|---|
| `a_leg_too_many…` | Yes (run) | "At once" only, observers together only |
| `the_number_of_the_round_is_held_twice` | Yes (run, check removed) | Three values, "at once" only |
| `nothing_is_written…` | Yes (run, each of the two checks removed) | Only the `fail()` way of being stuck |
| `…find_what_observers_run_together_find` | Yes, when a thread looks as its neighbour (run) | Passes with the round check or the start check at line 1252 removed (run) |
| `an_observer_that_does_not_answer…` | Yes, when `again()` is left out of `correct()` (run) | Passes with either check at line 1252 removed; never tries a late answer; uses the real 40 ms budget, so can fail under load |
| `…find_that_the_rounds_have_stopped` | Yes, when `stopped()` is not called (run) | **Passes with `tick()` removed from the stuck path, and with `Look` not resetting the count (both run).** Each stretch of rounds is shorter than the 450 ms threshold |
| `…keep_up_with_the_rounds` | A measurement | Here: longest wait 0.93 ms, 0 of 8 waits used. Can fail under load |

## Could not check

- The full suite, by instruction. In `after/` I ran the 7 new tests and 27 of the 48 earlier ones.
- The standard library's source and documentation, and a real standstill of the machine (2c).
- `test/limits.js`. I reproduced its one new check by hand: `eighty`, `65536`, an empty argument, `-1`, ` 8190` and `8190x` each end with code 2 and the message, also with standard error closed.
- Change 6 at run time. I could not make setting a wait fail. By reading, the three places (`main.rs:226`, `347`, `377`) do what is claimed.
- Behaviour off Windows, in particular several threads calling `process::exit` at once.

## Noticed outside the eight claims

- `"+8190"` and `"0"` parse as ports (`main.rs:169`). I did not run them.
- A dropped observer no longer watches the rounds until the halt is put right. Under "on a click" that is as long as a person likes. With one dropped, seven still watch.
- If a thread cannot be started (`.ok()` at line 1226), that observer is late in every round. Under "after a pause" the game then halts again as soon as it is put right, without being stuck.
- A panic inside an observer's look is now a halt that is put right. In `before` it went through `fail()` and the game had to be begun again. No single fault I found makes `look_of` panic.
- On a loaded machine an answer slower than the budget is a halt. That is listed, not evaluated.

## Where the throwaway material is

- Throwaway copy with named breaks and hooks: `«WORK»\check-three\code\try\`
- My tests: `«WORK»\check-three\code\try\zz_tests.rs` (each run alone, by name, with `--test-threads=1`).
- `after/` itself is unedited; only its `target/` folder was added by building.
- I ran the program only on ports 8190 and 8191. Each instance ended by itself or was stopped by its process id. Nothing was sent to port 8138.
