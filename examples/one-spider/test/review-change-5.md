# Independent check of `after/`: hand-back

## At the top

- **Recorded as true:** I found no single fault that is recorded as true.
- **Loses the game:** I found one, by the letter of the fault model, and only with halts set to end at once. Two faults of the kind "how many observers there are", each landing inside a round, with exactly one recorded round between them, put the game aside whole. `before/` survives the same sequence. I ran it. It is counterexample A under claim 1.
- **Ends the program:** I found none beyond what the program does on purpose. A round that never returns ends the program by design (`after/src/main.rs:272-309`). I did not run that on the built program.

Everything else I threw at it held: 14,700 random single faults and several hundred placed ones were all found, put right, and left the game where an untouched game is.

All line references are into `after/src/`. I never ran the whole suite; every run had a name filter.

## What I chose to look at, and why

The earlier check held nine thousand faults in stored values, so I put the effort where a value-by-value sweep is least likely to reach:

- what is left behind by a halt that has already been put right (this is where A is);
- stops at every statement boundary of the recording;
- the observers' threads and what passes to and from them;
- random faults at random instants in random states (pointer, shop, deaths, torn webs), each compared with an untouched twin;
- the first rounds of a new game and of a game begun again;
- the built program under requests from several threads.

## Claim 1. The whole claim: fails in one case, holds everywhere else I looked

**Counterexample A (ran it, observers together and on threads).** Halts end at once.

1. Round R: after the gate has put its counts right (`watch.rs:1147`) and before the observers are asked, the ring goes from 8 to 7. Every observer answers "no longer eight observers". The loop that passes a flag round the rings then indexes the missing observer (`watch.rs:689`, `693`, stopping in `sound()` at `624`). The round's thread stops, and `stopped()` makes it a halt with `stops` = 1.
2. Round R+1: begins halted, is put right ("the gate's counts put right, all eight observers started again"), is worked and recorded. The game is exactly where the untouched one is. `stops` is still 1, because `began_halted` was true (`watch.rs:1196`, `1266-1268`).
3. Round R+2: the same fault again. `stopped()` sees `stops > 0` (`watch.rs:538`) and calls `fail()`. The game is put aside: generation 1, nothing caught, waiting to be begun again.

```rust
let (mut game, mut now) = webbed();
game.set_how(How::AtOnce);
play(&mut game, &mut now, 3);
game.early = Some(|game| drop(game.ring.pop()));
assert!(guarded(&mut game, &mut now));   // R: a stop, a halt, stops == 1
assert!(!guarded(&mut game, &mut now));  // R+1: put right, recorded, stops still 1
game.early = Some(|game| drop(game.ring.pop()));
assert!(guarded(&mut game, &mut now));   // R+2
assert!(game.stuck());                   // put aside whole
```

- The second fault also loses the game if it lands after R+1's record and before the screen text is written (ring short, `shown()` stops at `watch.rs:1430`).
- A stop is the only thing that reads `stops`, and the only single fault of the model I could find that stops the round's thread is the observer count changing inside a round. So A needs both faults to be of that kind.
- The model says "at least one round is recorded before the next one"; the program asks for a recorded round that began with nothing halted. Under at once these differ by one round. Whether that is a fault of the program or of the model's wording is yours to say.

**What held (all run):**

| Probe | Cases | Result |
|---|---|---|
| Random single faults between rounds, three settings | 4,500 | 0 failures |
| Random single faults inside rounds (four instants), three settings | 4,500 | 0 failures |
| Random single faults at any instant, other seeds | 2,100 | 0 failures |
| First 0 to 3 rounds of a new game and of a game begun again | 3,600 | 0 failures |
| Observer thread and answer faults (late, ended, says the rounds stopped, answers as another, wrong starting, wrong round, twice, thread stops) | 120 | all one halt at most, put right |
| Faults in what the observers are sent | 30 | all one halt at most, put right |

- The random faults covered: open fields, observer fields and copy counts, both halves of the record and its count, the ring count, book places, the three lists, the kept state, the game's own part, and leg and moth counts.
- "0 failures" means: at most one halt, at most one stop, never put aside or stuck, counts right, and every part equal to a twin that worked only the rounds this game recorded. About 1,350 spider deaths fell inside these runs.
- A thread saying by itself that the rounds had stopped did not end anything.

## Claim 2. What the earlier check found

**2a. Holds (ran it).** I placed a stop at 10 points: before, in and after the work; at the start of `write_record()`; inside and after the observers' copying; after the moths list; after the last emptying; before and after the `keep` in `turn()`. With a pointer place, a click, a letting go and two upgrades waiting, on two bases and three settings, each upgrade was bought exactly once and the game ended where the twin is. A stop placed by hand between `watch.rs:907` and `912` does take things in twice, which shows the probe can see it. No statement there can stop.

**2b. Holds for the places named, with two things to know (ran it).**

- Observers' look, gate's look, the work, start of `write_record()`, `shown()` when nothing is halted, start and middle of `correct()`: never more than two stops in one game. The game is put aside at the second stop. Under at once that is the next round. After a pause it is rounds 39 to 43, or one further pause for a stop in the middle of `correct()`. On a click it is the round of the asking or the one after.
- `shown()` only when something is halted: put aside at the second stop and the program ends at the third, all in one pass of `play()`, because the game put aside is itself halted (`main.rs:331-335`). Same under all three settings. `guarded()` has no third call, so no test sees this.
- A stop placed by hand after the last statement of a recorded round halts and goes on for ever under pause and click (750 stops in 1,500 rounds). No code is there today. More generally, any stop that stays away for one recorded round begun unhalted is forgotten.

How long one stop still counts (first stop in round R, second in R+k):

| Setting | Second stop still puts the game aside | Recorded rounds between |
|---|---|---|
| At once | k = 1 and 2 | 1 at k = 2 (and at k = 1 if after its record): this is A |
| After a pause, not asked | through k = 39 | 0 |
| On a click, not asked | for as long as nobody asks (tried to k = 45) | 0 |
| Either, asked at once | k = 1 and 2 | 0 |

So it is more than a few rounds only where no round has been recorded between.

**2c. Holds (ran it).**

- First round of the program: 3 thousandths for a clock 3 on.
- First after put aside: 16.67. The round that begins a game again and the one after: 16.67 each.
- No number for 1, 5 and 600 rounds: every round 16.667, then one round of 33.3, 50 and 50.
- Clock back 5 s: one round of 0. Ahead an hour: one of 50. Then ordinary.
- Outside the model: if the clock cannot be read at the start but can in the first round, that round is 50.

**2d. Part holds, part fails.**

- Holds: the eight copies are one text but for the mark (I compared them myself). No observer's thread stops on a ring too long or too short. Together and on threads gave the same reason and the same outcome in all 168 cases (7 count faults, 4 instants, 3 settings, 2 ways); all were put right.
- Fails as worded, "no thread stops in the wrong place": the round's own thread still stops.
  - Too short before the look: `watch.rs:624` via `689`/`693`. With no observers: `1232`.
  - Too short later: `899` or `1430`.
  - Too long after the look: `736` (`NAMES[i]`), or `1455` in `shown()`.
- Each is one stop and is put right; it is also what feeds A.

## Claim 3. Nothing put right before is lost: fails in three places

The test modules differ only as the seven items explain; no assertion was dropped without a stronger one in its place. Three things `after/` handles worse:

1. **A.** `before/` run on the same sequence: second fault is a halt, game goes on (ran it).
2. **Ring too short inside a round, on threads.** In `before/` (pop, truncate to 5) it was a plain halt in the same round ("the whole observer did not answer in time", `stops` 0). In `after/` it is a stop of the round's thread (`stops` 1). Ran both. Ring too long before the look went the other way: a stop before, a plain halt now.
3. **Clock unreadable in the round a game is put aside** (two things outside the model at once). `fail()` takes the clock as the new game's time (`watch.rs:777`; `main.rs:91`, `330`, `334`). With no number the game's time is no number for good: every game begun again sticks at once with "twice running, the work left the body in a state that cannot be recorded", 81 games in 320 rounds of asking (ran it). `before/` gave 0 there; I argue from its text that it was playable.

## Claim 4. The copies are copies: holds at the level of the texts

Both second texts are word for word the first (my own comparison: 67 and 23 items), and all 49 functions pass their own name. The word-for-word tests caught every sharing I tried. Not seen by the tests:

- Both texts of the rules are given one list of halted moths, worked out by the first text of the work, and one `Asked`, built from the first doing (`watch.rs:840`, `842`, `1239`).
- If the first text of the rules is no longer asked at all, the three tests I ran still pass. Only the second text is counted.
- A function passing its mark under another's name fails nothing; only six names are counted.
- The start-up check compares six pairs and the eight rules (`watch.rs:1517-1527`), not the helpers. I argue the marks keep them apart; I did not inspect the binary.

## Claim 5. The tests test what they say: mostly

I broke 46 things in throwaway copies, one at a time.

**Added or changed tests**

| Test | Fails when broken? |
|---|---|
| `a_stop_that_comes_back_every_round…` | Yes, with change 2 undone or a second stop made a halt. Tries two of the five places in 2b. |
| `the_length_of_a_round…` | Yes, for all three clock breaks. |
| `the_eight_copies…` | Yes, for 10 breaks of one copy. Two more changed no behaviour (the clauses `copies.len() <= p` are redundant). |
| `a_round_is_held_to_both_texts…` | Yes, for the second text unasked or the second doing using the first text. No, for the first rules text dropped. |
| Word-for-word tests | Yes, for a changed number, a rule changed in one text, a missing mark, a path into the first text, a method of a kind. |
| `the_copies_are_apart…` | Yes, for two observers on one copy. |
| `a_count_that_goes_wrong…` | Yes, with the counts not put right after a stop. |
| `a_game_put_aside_whole…` | Yes, when begun again unasked. |

**Nothing fails** (among the tests I ran) when change 1 is undone, when change 5 is undone (no test reads "the gate's counts put right"), or when `look_of()`'s guard is removed.

**Eleven older tests**, each failed when its thing was broken:

- `what_the_observers_miss_the_gate_stops`
- `a_wrong_step_that_breaks_no_rule_is_found_by_doing_the_work_twice`
- `a_change_to_the_state_as_the_round_is_recorded_is_not_recorded`
- `a_change_to_one_place_of_what_the_gate_keeps…`
- `what_is_asked…one_list_gone_wrong_loses_nothing`
- `a_fault_in_the_gates_record_while_a_round_is_worked_is_put_right`
- `a_stop_in_the_wrong_place_is_once_a_halt…`
- `an_observer_that_does_not_answer_is_silent_and_is_replaced`, and `…is_found_by_the_others_of_its_ring`
- `a_halt_does_not_end_until_the_eight_new_observers_have_looked`
- `the_state_kept_from_when_a_rounds_work_began_is_in_three_places`

## Claim 6. The program as it runs: holds

Built from `after/` and run on port 8190. Seven backdoor faults under each setting: a body field, an observer stopped, an observer's signal, moths to spend, a `during` line that breaks a rule, one that does not, an observer's copy.

- 21 of 21 were found for the reason the model gives and put right; 21 halts, 21 restarts, never stuck, one game.
- At once: put right within 0.01 to 0.04 s. After a pause: about 0.64 s. On a click: it waited, then ended on the asking.
- The `during` line that breaks no rule is found by the second doing; nothing was let through.

On port 8191, 30 s with five threads at once (4,420 pointer places, 95 press-drag-release, 565 upgrades, 64 backdoor lines, settings changed 15 times): 61 halts, 61 restarts, never stuck, one game, no request refused, rounds still going.

Processes 35032, 20288 and 36084 were stopped by id and are gone; nothing listens on 8190 to 8195. Another `one-spider.exe` (id 18944) was running throughout and I sent it nothing.

## Could not check

- The whole suite, by your rule. Claim 5 covers the added and changed tests and eleven older ones.
- A round that never returns, on the built program: argued from `main.rs:272-309` and your own test.
- Faults in private state and in observer threads on the built program: the backdoor does not reach them. Those ran in the test build, the thread and look faults through hooks I added to a throwaway copy.
- Whether helper functions of the two texts are apart in the release binary.
- The margin of the 8 waits of 5 ms on a loaded machine, beyond these two short runs.
- `page.html` and `test/limits.js`: not looked at.

## Noticed outside the claims

- `differs()` and `observers_off()` never look at how many observers there are (`watch.rs:709-757`). With no observers inside a round, neither the observers nor the gate find anything; only the index at `1232` stops the round.
- A `Look` one text short stops five observers' threads (`looks.rs:63` and its seven twins). They are found silent and replaced.
- `guarded()` gives `stopped()` and `fail()` the game's time; `play()` gives them the clock.
- A count put right by `turn()` itself (`watch.rs:1147`) is said only by the halt's reason, not in what was done.

## Where the throwaway things are

All under `«WORK»\check-six\code\`. The sources of `before\` and `after\` are untouched (they still differ exactly as `changes.diff` says); `after\target\` is build output.

- `work\src\probe_tests.rs` and `work\src\probe_random.rs`: the probes, in a copy of `after\` with test-only hooks in `work\src\watch.rs`. A is `probe_two_single_faults_one_recorded_round_between`.
- `work-before\src\probe_before.rs`: the same sequence on `before\`.
- `scratch\mutate.py` and `scratch\mutate_out.txt`: the breaks and what each test did.
- `scratch\run_program_out.txt` and `scratch\stress_out.txt`: the two runs of the program.
