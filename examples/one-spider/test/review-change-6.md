# Independent check of `after/`: hand-back

## At the top

- **A single fault inside the model that is recorded as true, loses the game, or ends the program: none found.**
- **A sequence of faults, one per halt with a recorded round between, that does: none found.**
- **Two sequences lose the game when only one of those two conditions is met.** I ran both; they are A and B under claim 2. Each is outside the model as written, which needs both conditions, but the wording should be settled:
  - A has a recorded round between the faults, but both faults fall in one halt.
  - B has one fault per halt, but no recorded round between.
- **Three things the change says of its tests or of what is said are only partly so.** Details are under claims 5 and 6:
  - The test of both texts of the rules passes when the second text is handed the first's account of what was asked.
  - No named test holds the new guard in `flagging()`.
  - "A count put right is said" is true on two of the three paths that put a count right.

All line references are into `after/src/`.

## How I checked

- I read all of `watch.rs` outside the tests, `watch/looks.rs`, `game.rs`, `rules.rs`, `backdoor.rs` and `main.rs`. I read the heads of the two second texts, the whole of `changes.diff`, and the tests that were added or changed. I confirmed `changes.diff` is the whole difference in `src`.
- **Throwaway copy `w1/`.** It is `after/` with 26 numbered instants added to a round, test-only, from before the gate compares its own to after the record is written. One is between the two askings in `ruled()`, which I made `&mut self` in that copy only.
- **The probe.** It lands one seeded random fault at one instant, runs the round as `main.rs` does (under a catch), and compares with a twin.
  - Faults cover: any field of any part (including no-number, infinities, minus nought, huge and off-by-a-little values, texts); counts of legs, moths, observers, an observer's copies, and the record's texts; an observer's fields; either half of the record; the game's own part; one place of `books`, `before`, `apart`, `Run`; one entry or the length of one of the three lists; an observer's thread stopping answering.
  - The twin was never touched and works only the rounds the game records, at the same times.
  - It reports: a stop in the wrong place, a halt that cannot be put right, a game begun again, more halts than faults, restarts not equal to halts, any difference from the twin (state, both halves of the record, the three lists), an unsound ring, the three books differing, `stops` or `spoiled` left over, a later halt.
  - Starting states: seven (web with a halted moth, plain, spider carried, old spider lying, new game, five rounds old, moths to spend), with 0 to 3 things asked just before the fault.
- **The probe has teeth.** With the guard in `flagging()` broken it reports stops (3 of 400 count faults, 1 of 1,200 pairs).
- **Untouched copy `w2/`.** Used for breaking one thing at a time and running the named tests, and for building and running the program.

## Claim 1. No fault of the model stops the round's thread: **holds**

**Run.** No stop in the wrong place in any of these:

| Run | Count |
|---|---|
| Single faults, observers together | 4,500 (1,500 per setting) |
| Single faults, each observer on a thread | 1,500 |
| Single faults at instants between the gate's look and the record | 15,000 |
| Pairs of faults | 12,240 |
| Long games, observers together | 3 of 300,000 rounds, 99 faults each |
| Long game, threaded | 100,000 rounds, 31 faults |

**Read, place by place:**

- **Count of observers.**
  - `sound()` 625-628, `flagging()` 630-632, `halted_moths()` 634-636.
  - `watch()`: `answers` and `running` both have the length taken at 663; signals are written through `get_mut` at 679; names go through `named()` at 696 and 700; flag passing at 703-719 goes through `flagging`, `sound`, `get_mut`.
  - `respond()` 724 and `all_hold()` 619 index only below the length.
  - `observers_off()` counts first, at 756-758, before `NAMES[i]`.
  - `write_record()` 933-942; `shown()` 1474, 1499, 1527; `named()` 1551-1553.
  - `correct()` 976-979 and `restore()` 1041, 1055, 1072 index only after `right_counts()` at 1036.
- **Count of copies in an observer.** `looks.rs` reads copies through `get` at 53; `o.copies[p]` at 59 is behind the length test on the same line; 64 and 71 test the length. The gate compares whole lists at 770.
- **Count of texts in the record.** `differs()` tests the length at 731 and reads through `get` at 735 and 740. `copies_for()` 236-238 walks whatever is there. `redone()` builds its own seven at 915.
- **Legs.** `copy_part()` 197-204, `snap()` 217 and `unfit()` 834-835 use `get` or iterate. `panics()` in `game.rs` 1076 takes anything at or past the number of legs as the body before `legs[held]` at 1082. `over()` 1402 is guarded. `rules.rs` 139 tests for eight.
- **Moths.** `game.rs` 840-842 index below the length; `rules.rs` 149 slices below `k`.
- **Web.** `level()` in `game.rs` 667-669 gives the first size for anything that is not one of the seven. `web_point()` 678-685 and `holding()` 694-698 are bounded. `rules.rs` 74 is clamped. `price_of()` at `rules.rs` 69 loops at most 10,000 times, because 93-98 refuse first.
- **The pointer's hold.** Any number is safe, by `game.rs` 1076.
- **What is in a list of what was asked.** `take_in()` in `game.rs` 430-449 has no index. A place that is no number is clamped at 412, or leaves the part unfit to record. A name that is no upgrade is passed over at 815-818.
- **What an observer's thread sends back.** `Apart::look()` takes an answer only if the starting, the round (to the bit), the place (`i < got.len()`), "was asked" and "not yet answered" all hold, at 1777. I ran eight kinds of wrong answer under each setting, with no stop and at most one halt, put right:
  - as another observer;
  - as an observer there is none of;
  - as `usize::MAX`;
  - a false finding;
  - of another starting;
  - for a round that is no number;
  - three million characters long;
  - before it has looked.
- **Division, overflow, `RefCell`, locks.**
  - There is no whole-number division or remainder on stored values.
  - Counters saturate or wrap by name.
  - `RefCell` is only in the tests' marks.
  - Poisoned locks are taken anyway at `watch.rs` 1703-1705 and `main.rs` 73-75.
  - No lock is taken twice in one expression.

**Places that do stop, outside `watch.rs` and not from one fault of the model:**

- `backdoor.rs` 371, 384, 470, 477 and 514 index `game.ring[i]` and `copies[p]`. With a count wrong and not yet put right, a read at the backdoor (`spider.ring`, `world`, `world.ring[4].why`, `spider.ring[0].copies[5]`) stops there. I ran this at the level of `backdoor::run`. In the program it is caught at `main.rs` 587-590, the line is refused, and the game is not told.
- A line kept with `during` that names an observer, plus the number of observers going wrong after the gate's look in the round it is written in, stops the round's thread at `watch.rs` 1294, so `stopped()` is reached. I ran it.
  - Once, it is a halt.
  - With halts ending at once, a second such pair after exactly one recorded round puts the game aside whole (stops kept 1, then `fail`).
  - Under the other two settings the second is again just a halt.
  - This is two things in one round, so outside the model.
  - The earlier sequence is closed because no fault of the model stops any more, not because the counting at 1308-1310 changed.

## Claim 2. Two faults, one per halt, a recorded round between: **holds as the model is written**

**Run.** The second fault lands in the round after the first recorded round that follows the first one's being found, or one or two rounds later.

| Run | Count |
|---|---|
| Random pairs, any kinds, any instants | 6,300 (2,100 per setting) |
| Pairs by family, same fault twice and two different | 5,400 |
| Pairs with each observer on a thread | 540 |

The families were: how many observers; how many texts and what is in them; an observer's fields and copies; the state; the record's copy.

No more than two halts, restarts equal to halts, never stuck, never begun again, no stop, and the game where its twin is, every time.

**Two sequences that lose the game when one condition is dropped (both run):**

- **A. A recorded round between, but both faults in one halt.**
  - Inside round R, after the gate has compared its three places, one place of something kept three times changes (`books[0].passed += 1`). Round R is worked and recorded with no halt.
  - Before round R+1 a second place changes (`books[2].unwritten += 1`).
  - Round R+1: `settle_books()` 426-455 finds no two agree, giving "it could not be put right: no two of the three places where the gate keeps what is its own agree". The game has to be begun again. This happens under all three settings.
  - The same with `apart[0] = None` inside R, then another hold in `apart[1]` (1195-1213).
  - The same with the state changed late in R, after the observers took their copies (`spider.body.x += 5`), then `record.texts[2]` between the rounds: `restore()` 1075-1076 cannot settle it.
  - Cause: a fault that lands after the gate's comparisons of a round is not found until the next round begins. So "a round is recorded before the next fault" does not by itself give each fault its own halt.
- **B. One fault per halt, but no recorded round between. After a pause, or on a click.**
  - Fault 1 lands inside round R after the gate's look and leaves the round unrecorded; `spoiled` becomes 1 at 1321-1323.
  - The halt ends in round X with no work (1270-1271).
  - Fault 2 lands inside round X+1 after the gate's look. That round is unrecorded too, `spoiled` is 2, and 1324-1331 give "twice running, …", which cannot be put right.
  - In a survey of random pairs placed this way: 85 of 1,200 lost after a pause, 84 of 1,200 on a click, 0 of 1,200 at once (there a round is always recorded between).
  - Every loss was "twice running".
  - Your suggestion under claim 3, that the round right after a halt ends is inside the model, reads to me as true only for "at once". Under the other two settings that round is the first to be worked since the fault.

## Claim 3. One fault, landing at any instant: **holds**

No counterexample in the roughly 21,000 single faults above or in the long games.

**Where I spent the effort, and why:**

- **Instants inside a round.** The backdoor reaches only "between rounds" and one instant via `during`.
- **Stores the backdoor cannot reach.** Both halves of the record, the game's own part, `books`, `before`, `apart`, `Run`, the three lists, and every count.
- **Rounds with things asked just before the fault.**
- **Threaded runs.**
- **Long games.**

**What "where an untouched game is" means in what I ran.** Every recorded round of the faulted game is the round the twin makes from the same record, the same things asked, at the same time, and nothing asked is lost. A fault that lands after the gate's look costs the round it landed in: that round's work is not recorded and is done again after the halt.

**What found the faults that landed between the gate's look and the record**, in order of how often:

1. The second doing of the work.
2. The gate's look at the observers before recording (875).
3. The rules.
4. The gate's own copy not being a state the game can be in.
5. The next round, for what landed after the comparing.

**Read:** everything the game holds is compared at the start of every round.

- The state, both halves of the record, the observers and the three lists in `differs()` 729-781.
- `books` at 1171, `before` at 1172, `apart` at 1195-1214, `Run` at 1216-1233.
- The counts at 1189.

So nothing stays unfound for more than one round.

**A game put aside with the clock unreadable (change 3).** No test in `after/` names it. I ran it:

- After `fail(…, NaN)` the time and the note of the clock are 0.
- Rounds with an unreadable clock go by.
- The game is begun again when asked, and plays for two minutes with no halt.

## Claim 4. Nothing put right before is lost: **holds**

**Tests compared.** The only assertion removed is `stops > 0` in the count test, now `stops == 0` (change 1). The other changes are:

- The mark check in `word_for_word` (3787, 3806-3808).
- The counts 6/3/3/6 and the `ruled()` assertions in the rules test.
- Comments.

All are explained by your items 1, 2 and 5.

**Handled worse: none found.** `first.or(second)` at 866-867 refuses everything the old chain refused, because the first text is asked exactly as before.

**Your three questions:**

- **`sound()` says an observer that is not there is not sound.** What finds the missing observer depends on when it went:
  - Before the look: every remaining observer's first look (`looks.rs` 44-46) or, with none left, the gate's count at 756. This is in the same round, before any work.
  - After the gate's look: the same count at 875. The round is not recorded.
  - After that: `right_counts()` at 1189 at the start of the next round, before any work. The round just recorded was written from the second doing and is right.
- **`halted_moths()` gives none.** At 1274 this is reached only if the moths observer went after the gate's look. Then the first doing moves a halted moth and the second does not. The rules ("a moth halted in the web that moved"), the second doing, or the count at 875 find it in the same round, and it is not recorded. At 1404 and 1527 it is only what a screen is shown, for one round.
- **`shown()` leaves out an observer.** This is what a screen is sent, for one round. `right_counts()` finds it at the start of the next.

Count faults at all 26 instants were among the single faults and pairs above, with nothing passed over.

## Claim 5. The two texts of the rules

- **`ruled()` asks each for itself: holds.** 890-899: the first at 891-892, the second at 896-897.
- **The second is handed nothing of the first doing: holds.** Besides the result under judgment, it is given:
  - the record;
  - `again::in_web` of the record;
  - the record's `next_id`;
  - what `again::take_in` makes of the record's own part and `asks_again` (893-895).
- **With no fault the two are asked the same thing: holds.** I compared what each is asked with on 280,000 askings: seven starting states, 20,000 rounds each, things asked in two rounds of three. No difference and no halt.
- **A fault in the first list, the second list, or the state between the two askings is found and not recorded: holds.** These were among the 15,000 runs, including the instant between the two askings.
- **The test fails if either text is not asked, or if the second is handed something of the first's: fails in part.** I ran `a_round_is_held_to_both_texts_of_the_rules` against each of these:

| What was broken | Test |
|---|---|
| Second text not asked | fails |
| First text not asked | fails |
| Second handed the first's account, with the second taking-in removed | fails (by the count of marks) |
| Second handed the halted moths from the first text of the work | fails |
| Second handed the first's `Asked` whole, while `again::take_in` is still called and its result thrown away | **passes** |
| Second handed the first's buys, clicks, next moth and hold one by one | **passes** |
| Second taking in the first list (`asks`) and not `asks_again` | **passes** |
| Second taking in from the state and not the record | passes (three other tests fail) |

  - The six other tests I ran alongside also pass for the three bold rows.
  - Cause: the test counts how often the second text's marks are passed, not what the second text of the rules is handed. Its direct assertion at 4086-4092 uses a step with nothing asked.

## Claim 6. The tests test what they say

- **`a_count_that_goes_wrong_inside_a_round_is_put_right` and `two_counts_gone_wrong_with_one_round_between_are_two_halts`: yes, with one gap.**
  - Both fail when any one of these is broken: `sound()`, the gate's count in `observers_off()`, `halted_moths()`, `named()`, the `get` in `shown()`.
  - Both **pass** when `flagging()` indexes again.
  - Cause: their faults (one more, one fewer, one from the middle, none) never leave a ring's first member missing while a flag is up. A ring cut to four or fewer does.
- **`what_was_asked_is_emptied_where_the_round_is_recorded`: yes.** It fails when the three lists are not emptied in `write_record()`. It goes through the tests' `settle()` (921-925), not through a round.
- **`a_count_put_right_is_said`: yes for what it runs.** It fails when either line (553, 1037) is removed. But the thing it names is not true on the third path. When `right_counts()` at the start of a round (1189-1193) puts a count right, nothing is added to what is said. I ran it:
  - An observer too few inside a round, after a pause or on a click: the halt ends with "all eight observers started again" only.
  - An observer too few between two rounds: the same, under every setting.
  - A text too few, in those cases: "the gate's record of the pointer, requests and chance put right, …" with no word of the count.
  - `settle_books()` 439-443 shows how the other things kept by the gate say it.
- **`a_round_is_held_to_both_texts_of_the_rules`: in part.** See claim 5.
- **The two word-for-word tests: yes.** Each fails for a mark that is not the first line, a mark carrying another function's name, and a mark missing.
- **Not held by any test I ran:**
  - Change 4, the look at seven parts. Taking it out of one copy of the rule passes `the_eight_copies_of_the_rule_are_one_rule`. It cannot be reached in the program, since `look()` 651-653 always builds seven texts.
  - Change 3. See claim 3.

## Claim 7. The program as it runs: **holds for what can be reached**

- I built `after/` untouched and ran it on port 8190 (process id 33492), then stopped it by that id. It wrote nothing to its error output and never ended by itself.
- Four threads asked things throughout: the pointer, presses, letting go, upgrades. About 72,000 requests in the last run, none failed.
- 58 lines were written at the backdoor one at a time under each setting: fields of the body, the old spider, legs, edge, counts, shop, web and moths; a moth put in and taken out; every field of an observer and its copies; seven `during` lines.
- In the last two laps: 344 faults, 344 halts, 344 restarts, one game, never stuck, nothing let through.
- On a click the halt waited for the click. After a pause it ended by itself.
- Three earlier laps gave the same. Their only exceptions were writes of the value already there (`spider.body.state = "panic"` while the spider was being carried), which change nothing.
- **Reached this way:** the six open parts and the observers, between rounds, and one instant inside a round via `during`.
- **Not reached this way:**
  - Any count but the moths'.
  - The record, the game's own part, `books`, `before`, `apart`, `Run` and the three lists.
  - Any other instant inside a round.
  - Any fault of an observer's thread.

## What I could not check

- **The whole suite.** By your rule I did not run it. All 20 tests of `after/` that I ran as given pass:
  - `a_count_put_right_is_said`
  - `a_count_that_goes_wrong_inside_a_round_is_put_right`
  - `a_game_put_aside_whole_waits_to_be_begun_again`
  - `a_round_is_held_to_both_texts_of_the_rules`
  - `a_stop_in_the_wrong_place_is_once_a_halt_and_twice_running_the_end_of_the_game`
  - `a_stop_that_comes_back_every_round_puts_the_game_aside_at_the_second`
  - `a_wrong_step_is_undone_under_each_way_a_halt_can_end`
  - `a_wrong_step_of_the_work_is_found_by_the_rules_and_undone`
  - `a_wrong_step_that_breaks_no_rule_is_found_by_doing_the_work_twice`
  - `an_observer_that_does_not_answer_is_found_by_the_others_of_its_ring`
  - `an_observer_that_does_not_answer_is_silent_and_is_replaced`
  - `observers_on_threads_of_their_own_find_that_the_rounds_have_stopped`
  - `the_eight_copies_of_the_rule_are_one_rule`
  - `the_length_of_a_round_comes_from_the_gates_own_note_of_the_last`
  - `the_second_text_of_the_rules_is_the_first_word_for_word`
  - `the_second_text_of_the_work_is_the_first_word_for_word`
  - `two_counts_gone_wrong_with_one_round_between_are_two_halts`
  - `what_is_asked_is_taken_down_three_times_and_one_list_gone_wrong_loses_nothing`
  - `what_is_asked_of_the_game_is_taken_down_three_times`
  - `what_was_asked_is_emptied_where_the_round_is_recorded`
- **`before/`.** I did not build or run it.
- **Some thread faults.** An observer's thread that ends, answers late, or says by itself that the rounds have stopped: argued only (1757-1763, 1777-1782, `main.rs` 275-290). I ran a thread that stops answering, and the eight wrong answers.
- **A round that never returns.** Not run in the program, where it ends the program by design.
- **Instants.** My 26 are between statements of `turn()`, `watch()`, `record_now()`, `ruled()` and `write_record()`. I landed nothing part-way through `world_work` or `spider_work`, nor inside `restore()` or `correct()`, which you put outside the model.
- **A debug build**, where whole-number overflow stops, was not built.
- **A loaded machine.** I did not try the program's own short waits (eight of 5 thousandths) under load. My threaded runs waited longer so as not to take a slow answer for a silence.

## Outside the claims

- **The model's wording.** By A and B, "one fault per halt" and "a round recorded between" are each needed, and neither is enough alone. It may be worth saying outright that the next fault lands only after the first has been found, its halt has ended, and a round has been recorded since.
- **An observer's finding has no size.** It becomes the observer's reason and the halt's reason whole (681-684, 698-700, 788-790). `shown()` sends the halt's reason and the last reason whole (1504-1506, 1520), though it cuts an observer's own texts to 160. I ran a three-million-character finding:
  - One halt, put right.
  - Every screen was sent three million characters every round from then on, also after the halt had ended.
  - Rounds were several times slower meanwhile.
  - Whether a far longer one could keep the rounds from the observers for five seconds, and so end the program, I did not try.
- **A game put aside with a readable clock takes the clock's reading as its own time** (802-804), where the program's first game starts at 0. I see no harm in it; argued only.
- **My first driver ran this machine out of local ports** by opening a connection per request. That was the driver, not the program.

## Files

Everything is in `«WORK»\check-seven\code\`. `after/` and `before/` are as given. No process of mine is left, and nothing listens on 8190 to 8195.

- `tools\hooks.py`, `tools\edit2.py`, `tools\edit3.py`: add the instants and test-only hooks to a copy.
- `tools\probe.rs`: the faults, the twin, and every run above.
- `tools\mutate.py`: breaks one thing at a time and runs the named tests.
- `tools\drive.py`: writes faults at the running program's backdoor.
- `tools\out-pairs.txt`, `tools\out-threaded.txt`, `tools\out-long.txt`, `tools\out-last.txt`, `tools\out-mutate.txt`, `tools\out-drive.txt`: what the runs printed.
- `w1\`: the copy with the instants.
- `w2\`: an untouched copy, with the built program.
