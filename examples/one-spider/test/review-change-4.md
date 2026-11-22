# Independent check of the change (`after/`): hand-back

All line references are into `after/src/`. "Ran" means I ran it. "Argued" means I reasoned from the code and did not run it.

## Verdicts in one place

| Claim | Verdict |
|---|---|
| 1. A count gone wrong, at any instant | **Holds** for one fault (3,312 cases run, none off). The instants inside `correct()` and `restore()` cannot be reached by one fault. |
| 2a. One stop, nothing of the round kept | **Holds** at every place the code can stop. **Fails** in one window where it cannot stop by itself (after the record is written, before the three lists are cleared). |
| 2b. Twice the end, never halting for ever | **Fails** for one place: a stop in `shown()` that comes only while nothing is halted, with halts set to end at once. Holds elsewhere. |
| 2c. A stop in `stopped()` or in `shown()` after it | **Holds** (ran through the real `play()` loop). |
| 2d. Anything trusted that should not be | **Nothing found** that a reachable stop leaves wrong and unfound. The one case is the window of 2a. |
| 2e. A stop on a request's thread | **Holds** (ran all seven). |
| 3. The clock | **Partly fails**: the first round of the program is a twentieth of a second, three times ordinary. One unreadable reading gives two odd rounds, and a clock that stays unreadable stands the game still with nothing said. The rest holds. |
| 4. Two texts, one work | **Holds** for what the second text reaches and for the same game as `before/`. The word-for-word test **does not fail** for three ways of sharing something. |
| 5. Nothing put right before is lost | **Holds** as far as I could check (25 named tests, test modules compared, nothing found that is handled worse). |
| 6. What is said | **Holds** (15 cases run). |
| 7. The program ends when the rounds stop | **Holds** (16 runs). A write that truly blocks was simulated, not made. |
| 8. The tests test what they say | **Mixed**: four gaps shown by breaking the thing and seeing the test pass. |

## How I checked

- **Probes.** In a throwaway copy (`work/`) I put numbered test-only points into `watch.rs`, at the lines listed under claim 1, and fired one fault at one point.
- **Driver.** Rounds were driven exactly as `play()` drives them (main.rs:316–333): `round_at` and `shown` under one catch, then `stopped`, then `shown` again, then `fail`. The helper `guarded()` (watch.rs:3724) leaves `shown` out, and that matters below.
- **Breaks.** In a second throwaway copy (`mut/`) I broke one thing at a time and ran the tests that name it.
- **Program runs.** Two more copies of `main.rs` (`hang/`, `trip/`) were run as programs on ports 8190 to 8195. The unchanged `after/` program was run once on 8195: no halt in 7 seconds.
- `before/src` and `after/src` are byte for byte as given. I checked at the end that their difference is still `changes.diff`.

## Claim 1: a count gone wrong, at any instant. Holds.

**What I ran.** 23 count faults, at 24 instants, under 3 settings, with the observers together and each on a thread: 1,656 cases each way, 3,312 in all.

- Texts of the record: one too many at the end, in the middle, at the front; one too few at the end, in the middle, at the front.
- Observers: one too many at the end, in the middle, at the front; one too few at the end, in the middle, at the front, the moths observer; none at all.
- Copies in one observer: one too many or too few, at the end, middle or front, in a leg observer, both coordinators, moths, edge, web.

**The instants.**
- Between rounds.
- In `turn`: at its start (1096), after `right_counts` (1118), after the round is numbered (1164), after `watch` returns (1165), after the gate's look (1181).
- In `watch`: after the look is put together (637), after the answers are in (641), before the first flag is sought (660).
- In the work: before `held` is read (1198), after `before` is set (1201), after `take_in` (1203), after `world_work` (1206), after `spider_work` (1207), before `record_now` (1226).
- In `record_now`: at its start (808), before `redone` (824), after it (829), before `write_record` (836).
- In `write_record`: after the observers take their copies (884), after the record is assigned (885).
- After the round: after stops is reset (1232), at the end of `turn` (1259), between `round_at` and `shown` (main.rs:317–318).

**Result.** Every case: never the halt that cannot be put right, never a second stop, never `fail`, the program never ended, at most one halt, the game went on, and the counts were right with `differs()` empty at the end.

- A wrong count of observers or texts was never in place at the end of two rounds running.
- A wrong count of copies in one observer stays for as long as the halt lasts. Under at once that is at most one round. After a pause or on a click it stays until the halt ends, because copies are replaced only at 909–911 and 874. It is found, and everything is halted meanwhile.

**Where the stops come from in `after/`.**
- Only from a wrong count of observers: `LOOKS[i]` (1518), `look.ring[j]` in the looks (looks.rs:48, 53, 66, 72, 79 in each copy), `NAMES[i]` (663, 716, 1421), `self.ring[i]` (669, 1396), `ring[MOTHS]` (1198, 1449).
- Never from a text count or a copy count.
- I also ran 2,736 cases of other single faults inside a round: counts of legs and moths, a hold on leg 99, a web of level 99, each in the state, in the gate's copy, and in one place of `before`. None stopped a round and none was off.

**Real time.** With each observer on a thread and rounds paced in real time, no observer thread took the rounds to have stopped after a count fault (207 cases).

**Inside `correct()` and `restore()`.** These instants are reached only while a halt is on, so a count fault there is a second fault in one halt, which the fault model excludes. I ran it anyway, with a body moved at the backdoor as the first fault: 897 cases each way.
- 276 of the 897 end in the halt that cannot be put right or with the game put aside.
- A text too many after `restore()`'s `right_counts()` (967) is the old failure again: `born()` (600) makes observers with eight copies, they find each other out of shape, and `stick` (939).
- A copy count or observer count that goes wrong in a new observer between 912 and 925 sticks the same way, as any fault in a new observer before its first look does.
- None of these ended the program.

## Claim 2: once a halt, twice the end

### 2a. Holds where the code can stop. Fails in one window.

**What I ran.** A stop at each of 23 instants of a round, plain and with something half done, under 3 settings, together and on threads: 864 cases.
- Half-done things: `keep()` written in one or two places (round number, time, halt count), `before` written in one or two places, an asking in one or two lists, the lists half cleared, the state moved by hand.
- Each game had an upgrade and a pointer place waiting.
- Beside each game ran one never touched, worked once for every round the game recorded, at the same length and time.
- Also: a first fault and then one stop at each of 13 places inside `mend`, `correct` and `restore`: 234 cases.

**Result.** At every instant up to and including 884 (the observers hold new copies and the record is still the old one), at 1259, and in `shown`: the game ends exactly where the untouched one is.
- Every part, the gate's record, the three lists, a whole ring and the three places all agree with it, and still do 300 rounds on, with one halt.
- A `keep` in one place is outvoted. In two places it is taken.
- An asking in one list is outvoted. In two lists it is taken as asked.
- The 234 stops while a halt is put right all end the same way. The only ones my harness flagged were stops after the halt had already ended (946) under on a click, where the new halt wanted a second click my harness did not give.

**The window: counterexample, ran, by injection.**
- Situation: an upgrade ("spawn") asked, with moths enough to pay.
- The stop lands after the record is assigned (885) and before the lists are cleared (1234–1236).
- Round N: the work takes the asking in and buys (level 1). The record is written. Then the stop. All three lists still hold the asking and agree. `stopped()` halts.
- When the halt ends: `restore()` finds state and record alike and the lists alike (1009), so it does nothing.
- Next worked round: the asking is taken in again. Level 2, against 1 in the untouched game.
- Same under all three settings, together and on threads. A stop with one list cleared and two not does the same. With two cleared it does not.
- Nothing between 885 and 1236 can stop in the code as written, and `shown` runs after the clears. So this matters only if "at any point" is meant to the letter.

**Argued only.** A starting of the observers half made (`again()`, 1622–1644): the next round's old threads cannot answer on the new channel, all are late, and `correct()` starts eight more.

### 2b. Fails for one place.

`stops` is set to nothing only at 1230, and in a new `Book`. I checked every use.

**What holds (ran).** A stop in the work, before the record, or while it is recorded, the same in every round, is put aside at the second stop under all three settings.

**Counterexample (ran, 600 rounds).** A stop in `shown()` that comes only while nothing is halted, with halts set to end at once. I injected it at the top of `shown`. In the code, `over()` (1320–1330) and the `fixed` branch (1431) run only then.
- Round N: the round is recorded and stops is set to 0. `shown` stops. `stopped()` halts and sets stops to 1. `shown` again is now halted, so no stop.
- Round N+1: the halt is put right, the work is done and recorded, and stops is 0 again. `shown` stops. A halt like any other.
- And so on, for ever.
- After 600 rounds: 600 stops, 600 halts, 599 restarts, never stuck, games 1, every round recorded.
- After a pause and on a click it is put aside at the second stop, as claimed: the round that ends the halt does no work (1194), so nothing is recorded between.

### 2c. Holds.

Ran through the real `play()` loop, in a copy with stops placed at the call sites.

| Stops placed | What happened |
|---|---|
| Two rounds running | Stuck, halts 2, program goes on |
| At `stopped()` | Program ends, exit 1, "The game cannot be gone on with, and so the program stops." |
| In `shown` after `stopped` | `fail`, stuck, program goes on |
| That, and in `shown` after `fail` | Program ends, exit 1, same words |
| Once in `shown` after the round | One halt, put right |

- Also ran, in the test driver: a count of observers going wrong inside `stopped()` after its `right_counts` makes `shown` stop, and the game is put aside (24 cases). That takes two faults.
- `stopped()` itself cannot be stopped by a count: `right_counts` indexes nothing but `NAMES[i]` with `i` below 8.
- Argued only: a stop inside `stopped()` when it is reached through `Shared::game()` (main.rs:97–101). The lock stays poisoned, the next taker calls `stopped()` again, and if that is the play thread the program ends.

### 2d. Nothing found.

After one stop the game trusts the record wherever its two halves agree, the votes of the three places, and that the stop left those whole.
- The record is written in one assignment (885).
- `restore` is safe to run twice.
- Everything else is voted or replaced.
- The only thing I found left wrong and unfound is the window of 2a.

### 2e. Holds.

Ran, with a stop placed on the request's thread while it held the game.

- `/pointer`, `/down`, `/up`, `/buy`, `/how`, `/right`: the request gets no answer. Within two tenths of a second the game is halted with "the program stopped where it should not have while it had hold of the game". It is put right after the pause (halts 1, restarts 1) and the program goes on.
- The backdoor: answered 200, the line refused. What it had written (I wrote the body's place before stopping) is found in the next round by an observer.
- From one fault only the backdoor can stop: on a short ring or a short list of copies, at backdoor.rs:371, 384, 470, 477. The six other handlers index nothing.

## Claim 3: the clock. Partly fails.

Ran in a test that feeds `round_at` what `clock()` would give.

**Holds.**
- `clock()` (main.rs:87–89) keeps nothing.
- Stepped back an hour: rounds of 0, 16.667, 16.667.
- Stepped ahead an hour: 50, 16.667, 16.667.
- First round after `fail`: 16.667.
- The round that begins the game again and the one after it: 16.667 each.
- Requests and `shown` are given `game.time()`.

**Fails.**
- **The first round of the program is 50 thousandths, three times ordinary.** main.rs:187 makes the game with `Game::new(0.0, seed)`, so `at` is 0 (320). `length()` (553) gives the cap. The spider ages 0.05 in it.
- **One unreadable reading gives two rounds, not one**: 0, then 50 when the clock reads again, because `unwrap_or(0.0)` puts `at` to 0.
- **A clock that stays unreadable** gives a round of no length every time. The game stands still with rounds going by and nothing said: six readings ran as six rounds of 0.

I did not change the machine's clock.

**Note.** `fail(why, clock)` (755, 763) starts the new game's own time at the clock's number (1795302250275 in my run, where the first game starts at 0). I found no effect: 30,000 rounds of such a game on an uneven clock, 100 moths caught, no halt.

## Claim 4: two texts, one work

**Holds: what `redone()` reaches.**
- `again.rs` has 40 functions and 27 constants.
- I listed every call, path and constant name in it. Each resolves to something written in `again.rs` or to the standard library.
- Line 19 takes in 19 names, all kinds of thing.
- The one thing it calls that is written once is `Val::written` (backdoor.rs:50), from `number()` (again.rs:381). That is how a number is written out, but the work also uses it to decide: `is_halted` (again.rs:514, 518, 542, 553) tells by it whether a moth is on the halted list.
- Around the second text, `redone()` (848–857) uses derived clones and `text_of`, `snap`, `Own::written`, `Part::written`: how parts are written out.

**Holds: the same game.** Four seeds, 40,000 rounds each, with pressing, dragging, clicking and buying, in `before/` and `after/`: the same mark every 500 rounds and the same tallies, no halts.

**Word for word, where it fails as claimed (ran).**
- A number or a function changed in either text alone.
- A mark removed.
- A new function in the first text only.
- `in_hand` moved back into `Own::held` (counts 39, 27, 39).
- A function taken in on a one-line `use`.

**Word for word, where it does not fail (ran).**
- The same new function taken in on a `use` broken over several lines. The check at 3667–3672 reads only lines that begin with `use `.
- Both texts calling the one `draw` as `crate::game::draw(...)`.
- A new method on `Own` called by both texts.

Each of these needs both texts changed together.

## Claim 5: nothing put right before is lost. Holds as far as checked.

- Ran 25 of `after/`'s tests by name, all pass: the silent observer (3), the number of the round, the three places (4), the three lists (2), the hold on the threads, the state kept in three places, the halt not ending until the eight have looked, the count tests, the texts, the copies, the length of a round.
- Test modules compared. Two tests added, none removed.
- Lines changed in old tests: the counts (34, 24, 34) to (40, 27, 40), the `direct` list from 4 to 6, `OWN_FAULTS` from 24 to 25 with its total, and two lines re-indented. All explained by items 2, 4 and 8.
- `others < running.len()` (1688): no more than seven strays can arrive while an answer is waited for, since a late observer is never asked again and `again()` makes a new channel.
- Handled otherwise, not worse: the stand-in for a missing observer now holds empty copies (519), so its ring says "copy differs" where it said "silent". A system clock stepped back now costs one round of no length.

## Claim 6: what is said. Holds.

Ran: a new observer silent at the first try, five kinds of fault, three settings.
- Each time the halt ended at the second try.
- It was said once: "the body put back, all eight observers started again", and likewise for the record, the lists and the three places.
- `restarts` was 1.

## Claim 7: the program ends when the rounds stop. Holds.

Ran a copy with a round made never to return, a line printed to stdout when an observer finds it, and a sleep that can stand in for the write.

| Stderr | Runs | First finding to the process gone | Said |
|---|---|---|---|
| To a file | 8 | 36 to 87 ms | The line, once, in every run |
| Closed | 3 | 54 to 71 ms | n/a |
| A pipe whose reader had gone | 2 | About 130 ms | n/a |
| Write blocking for ever (simulated) | 3 | 345 to 378 ms | n/a |

- Every run ended with exit code 1.
- The first observer found it 4.99 s after the rounds stopped.

## Claim 8: the tests

**`a_count_that_goes_wrong_inside_a_round_is_put_right`**
- It does reach stops, in 7 of its 21 cases under each setting:
  - an observer too many, at its first two instants;
  - an observer too few, and one gone from the middle, at the first instant;
  - no observers, at all three.
- It never reaches one from a text.
- It fails with `right_counts` taken out of `restore`, and with every stop made the end.
- **It passes with `right_counts` taken out of `stopped()`.** `guarded()` does not call `shown` as `play()` does, and the next round's own look hides it. In the program that break loses the game.

**`a_stop_in_the_wrong_place_is_once_a_halt_and_twice_running_the_end_of_the_game`**
- It fails with stops never reset, with every stop the end, and with no stop the end.
- **It passes with stops also reset when a halt ends** (`book.stops = 0` added at 944). With that, the same stop every round would never be put aside, after a pause or on a click.
- No test in the module repeats a stop through a round: `stopped(` and `guarded(` appear only in these two tests.

**`a_round_is_held_to_both_texts_of_the_rules`, the two counts**
- It fails with all of `redone` on the first text, and with all three rule calls on the first text.
- **It passes with `redone` calling the first text's `world_work`.**
- **It passes with `record_now` asking the first text's `wrong_step` twice.**
- The counts show that something of each second text ran, not that each entry did. `the_copies_are_apart` passes with both breaks too.

**`the_eight_copies_of_the_rule_are_one_rule`**
- I was not given the changes the earlier check found.
- Caught: letting by a list of halted moths on an observer that is not the moths observer, a copy too many, a copy outside an observer's rings, a stopped observer, a reason with no flag, the moths list.
- Not caught, and the same rule in effect: dropping `me.copies.len() <= p` and dropping `|| look.ring[j].copies.len() <= p`.
- **Not caught:** changes that concern one particular other observer. Each kind of observer fault is tried on one or two observers only. I ran three: "do not mind the page observer's signal", "do not mind the page observer being stopped", "do not mind the whole observer's name".

**The two tests on a vote.** Both now fail with the vote taken out: `began()` reading the first place, and `length()` reading `books[0].at`. So do `threads()` and `asked()` on their tests.

**The check of what a second text takes from outside itself.** Fails for a one-line `use`. Passes for a several-line `use`, a full path, and a new method (claim 4).

## What I could not check

- A write to stderr that truly blocks. I put a sleep in its place.
- A system clock truly unreadable or stepped. I fed the values in.
- A stop inside `again()`, and inside `stopped()` by way of the poisoned lock. Both argued only.
- The whole suite, by your rule. Where I say a break passes, I mean the tests named.
- The text of the rules themselves, beyond running its word-for-word test, which passes.
- `page.html` and `test/limits.js`.

## Noticed outside the claims

- With each observer on a thread, a ring too short stops observer threads in the wrong place (the looks index `look.ring[j]` unguarded). They print the default panic lines to stderr, are found silent and are replaced. It ends well, but nothing counts those stops.
- A stop that comes while a halt is already on is not said on a screen: `stopped()` leaves `why` alone (544–546). `right_counts`' answer is dropped in `restore` and `stopped`, so what is said afterwards never names a count put right.
- After one stop, on a click, `stops` stays 1 for the whole wait. Any second stop before the click and one recorded round puts the game aside.
- If a stop repeats before `round_at` in every round, no observer is told of the rounds, and after five seconds the program ends as if the rounds had stopped.
- If only two observers of a starting are left when the rounds stop and the write blocks, nothing ends the program. This is as in `before/`.
- The comment at main.rs:92–93 still points to `fail`. The test `a_stop_in_the_wrong_place_is_a_halt_that_begins_the_game_again` (2833) is now true of `fail()` only.

## One thing to know about my runs

One of my runs of `after/` on port 8195 outlived my script, because the id I stopped was the shell's. I found it by its port and path (`...\check-five\code\after\target\release\one-spider.exe`, process 31840) and stopped it by that id. To be sure none of mine was left I listed `one-spider` processes by name, read-only. The one remaining is yours (process 18944, `...\spider\one-spider-target-k\release\one-spider.exe`). I sent it nothing and did not touch it.

## Left in the folder

Everything is in `«WORK»\check-five\code\`:
- `tools\`: the scripts and the throwaway tests.
- `out\`: the outputs.
- `work\`, `mut\`, `hang\`, `trip\`, `before-work\`: the throwaway copies.
- `after\target\`: from building `after/` as given.
