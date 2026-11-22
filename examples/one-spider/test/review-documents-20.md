**Nothing these four sets add or alter is wrong, and no count disagrees. Two statements are narrower than stated: the new P6 sentence in the README, and one sentence in `outside.md` that the first set's correction left behind. One sentence of `checks.md` lost its verb to a correction.**

Everything was read in `«WORK»\check-seventeen\docs\`. File references below are relative to its `now/`. Lines are as they stand there.

## Wrong

None.

## Narrower than stated

**1. `README.md` line 148, the row for P6 (set 3).**
"Here a boundary is a single observer: one fault can take one observer and no more."

- **Where it holds.** It holds for every kind of fault the README names under "The result" (lines 39 to 42). I went through each kind:
  - A field of an observer (`alive`, `beat`) takes that observer and no other.
  - One observer's thread that stops takes that one: `observe` (`src/watch.rs` 2068 to 2102) shares no lock with the other seven and holds only its own receiver. One thread that says the rounds have stopped is not believed alone (`src/main.rs` 277 to 292).
  - A field of the state, a half of the record, or an entry in a list of what was asked takes none.
  - One of the three places takes none, because what is read is what two agree on: `Deref` at `src/watch.rs` 456 to 468, `threads()` at 544 to 553, `Threads::run` at 1883 to 1892.
- **Where it does not hold.** It is not true of every single value the code keeps.
  - The observers are one list, `ring: Vec<Observer>` (`src/watch.rs` 415), and its length is one value. Changed, it takes as many observers as it likes at once.
  - The program's own tests do this. `game.ring.clear()` ("no observers"), `game.ring.truncate(3)` and `game.ring.truncate(4)` are at `src/watch.rs` 4375 to 4378, and `ring.clear()` again at 5401, in the test named `an_observer_or_a_copy_too_many_or_too_few_is_a_change_like_any_other`.
  - The program is built for it: `right_counts` (572 to 581) makes up any number that are missing.
  - The documents treat this as a single fault that is held. `checks.md` 162 to 163 has "all but three or four of the observers gone". README 521 to 523 counts "the number of observers gone wrong inside a round" among the single faults the reviews found.
  - `observation.md` 462 to 467 claims only "one too many or too few" for that count, which is the form in which the sentence is true.
- **A second such value, outside what is claimed.** All eight answers come back on one receiver, `Threads.answers` (`src/watch.rs` 1851, made at 1929 to 1930, read at 1996). If it goes wrong, all eight have not answered (`Disconnected` at 2008, then every running observer is taken for silent at 2012 to 2017). `observation.md` 434 to 435 speaks only of the channels to the threads, which are one each.
- **P6 itself is not broken by either.** The gate counts the observers and sees the loss. What is narrower is the clause about what one fault can take.
- **Other places.** README 357 to 359 says "a fault in the program itself takes them together", using "fault" for something that takes all eight. `observation.md` 387 to 388 ("one that stops or sticks is lost alone") says the same as the P6 sentence of a thread, and is true of a thread.

**2. `outside.md` lines 65 to 67 (not in the diffs; left behind by set 1).**
"If the program stops where it should not have (a panic) while the backdoor is doing a line, the line is refused, and whatever it had written by then is found in the next round like any other write."

- This is the statement set 1 narrowed in the two comments, and `observation.md` 359 to 361 already has it narrowed ("a line that has just arrived at the backdoor").
- It is so of a line that has just arrived: `src/main.rs` 586 to 594 catches the stop round `backdoor::run` and answers that the line could not be done.
- It is not so of a line kept with `during`. That line is done by `backdoor::write_now` inside the round (`src/watch.rs` 1486 to 1488). A stop there is not caught at the backdoor and the line is not refused: it goes up to `play` (`src/main.rs` 323 to 333), the game is told (`stopped`), and it is a halt.
- The next sentence of `outside.md` ("If it stops while the game's own work is being done") covers that case, so the two sentences overlap for a kept line and the first is too wide.
- I found no other place left. The old wording is in no comment. The comment at `src/main.rs` 587 stands on the arm that only an arriving line reaches. `checks.md` 677 to 678 speaks of a halt that cannot be put right, where no line is kept (`during` at `src/watch.rs` 1618 to 1621, `stop_all` at 933).

## Not one of the three kinds: a sentence left without its verb

**`checks.md` lines 644 to 646, the entry for `review-change-10.md` (set 1).**
"In halts that cannot be put right it ran rounds, the pointer, presses, upgrades, the setting and lines at the backdoor, and the state was byte for byte the same throughout, and that nothing an ordinary game has is cut or changed."

- The last clause hung from "It found that", which the correction took out. As it stands it has no verb, and reads as if it were about such halts only.
- Nothing in it is contradicted by the code. In such a halt:
  - a round returns before any observer is asked or any work is done (`src/watch.rs` 1348 to 1361);
  - nothing asked is taken down (1539 to 1543), and a press and an upgrade are not kept (1579, 1610);
  - the setting is written to the gate's own three places and not to the state (1655 to 1657);
  - the backdoor refuses every write (`src/backdoor.rs` 230 to 234, 276 to 278) and cuts nothing (`src/watch.rs` 866 to 870).

## Checked and found true of the code

**Set 1**
- **Comments at `src/main.rs` 96 to 98 and `src/watch.rs` 595 to 596.** A line that has just arrived and stops is caught at `src/main.rs` 591. The hold on the game is let go outside the catch, so the lock is not broken and `stopped` is not called. A `during` line is tried on a copy inside the same catch (`src/backdoor.rs` 139 to 149).
- **`checks.md` 198 to 199**, "Five kinds of write … which the backdoor must refuse, and one read, which it must still answer." The test at `src/watch.rs` 5193 to 5204 gives five lines (a `+=`, a push, a pop, a `[*]` write to observers, two writes in one line), requires the refusal for each and the state and observers unchanged, and then one read, `spider.body.gen`, answered "1". `backdoor.md` 74 to 77 says the same. I ran this test: it passes.

**Set 2**
- **`MOST_HELD` is 1,024** (`src/watch.rs` 92). `over()` returns nothing where there are more moths than that, before a leg, the body or a moth is looked for (1597 to 1604).
- **Comment at 1595 to 1596.**
  - "a fault": the work allows 48 moths at the most (`src/game.rs` 63 to 69, 918), and the backdoor puts none in at 64 (`src/backdoor.rs` 106, 236).
  - "not yet found": the line is reached only with nothing halted (1592).
  - "looked up among the halted ones": `moth_at` at `src/game.rs` 482 to 485.
- **Comment at 3305 and the message at 3316** are true of the lines they stand on.
- **`checks.md` 251 to 253, in its present words.** The test asks at 1,024 moths (a moth said), 1,025 and 4,096 (nothing said), and with the pointer on a leg at 1,024 (said) and 1,025 (not): `src/watch.rs` 3305 to 3325. I ran this test: it passes.
- **Comment at 4875 to 4876, `checks.md` 700 to 705 and `observation.md` 129 to 132.**
  - The look-up is among the halted ones. The second doing is handed `again::in_web` of the gate's copy (`src/watch.rs` 1079) and looks each moth up in that list (`src/game/again.rs` 532 to 533, 537, 561, 572).
  - Each qualifier is needed for the cost. Moths lying where a halted moth lies are all in that list (`again.rs` 390 to 394). Numbers no moth has had are found late in it and not at its head. Each click that hits nothing goes through every moth again (537). Eight is the most that can wait (`src/watch.rs` 1577 to 1581).
  - So the code could give several seconds for thirty thousand: some four thousand million comparisons of short texts, about a ninth of that with no click waiting.
  - "There is now a cut at that place": `src/watch.rs` 1030 to 1032, between the rules and `redone`.
  - "more than five seconds … the program ended": an observer waits five waits of one second (1821, 1899, 2091 to 2096).
  - The test's own case is sixty thousand such moths (4877 to 4887), as `checks.md` 262 to 263 says.
- **Left behind:** "can hold" and "among all of them" are in no document or comment now.

**Set 3**
- **README 125**, "The scope of what is claimed comes after": "The scope" is the section after the Overview (line 297).

**Set 4**
- **Counts.** The list in `checks.md` has 38 entries with a file name: 4 reviews (lines 403 to 429), 15 `review-change` (`review-change.md` and 2 to 15) and 19 `review-documents` (`review-documents.md` and 2 to 19).
  - That agrees with every place a count is given: `checks.md` 398, 438 and 744 (thirty-four checks); README 483 (fifteen and nineteen), 490 (thirty-eight hand-backs) and 492 (thirty-four).
  - No other document or comment gives a count.
- **Order sentence, `checks.md` 438 to 448.** It agrees with the order of the list and with what each entry says it checked.
- **Entries for `review-change-13.md` and `review-change-14.md`.** What they say the test now asks is in the test: a larger number (3317 to 3318), and the pointer on a leg (3319 to 3325).
- **README 540 to 541, "The clock".** `clock()` is in `src/main.rs` 90 to 93, and that file has no test. All 84 tests are in `src/watch.rs`, and they give `round_at` clocks that stand still, go back, jump and cannot be read. `test/limits.js` does not ask about the clock.
- **Left behind:** "has not been reviewed" and "no reviewer has read that code" are nowhere now.

## Cannot be told from the folder

- **What the reviews ran and found.** This covers the entries for `review-change-10.md`, `-11.md`, `-13.md`, `-14.md` and `-15.md`, and for `review-documents-17.md` ("four places"), `-18.md` and `-19.md`. It includes the measurement "nearly seven seconds" and "the costliest place found".
  - In the entry for `review-change-15.md`, "no natural change … that the test lets by" is the reviewer's judgement. The test's cases are a moth and a leg; it does not put the pointer on the body.
- **"The last check of a change led to no change in the program or its tests"** (`checks.md` 748, README 537 to 538). There is no earlier version in the folder. The fourth set has no diff of `src/`, which agrees with it.
- **"Not every correction … has been checked"** (`checks.md` 748 to 749, README 537), and which corrections were checked by whom.
- **The order the checks were made in, that the hand-backs are in `test`, and which model ran them.** The `review-*.md` files are left out of this copy, as the brief says.

## Whether a correction made a right statement wrong

- None made one wrong.
- Set 3 put a claim into the P6 row that the earlier words ("At this scale a boundary is one observer") did not make, and that claim is true only in the narrower form given in 1 above.
- Set 1 left the sentence at `checks.md` 644 to 646 without its verb.

## What was run

- Two named tests, from `now/`, with the command in the brief: `nothing_is_written_in_a_halt_that_cannot_be_put_right` and `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long`. Both passed, each with 83 filtered out. The build made `now/target`, which I left in place.
- Nothing else was run, nothing was written elsewhere, and nothing stopped me from checking anything.
