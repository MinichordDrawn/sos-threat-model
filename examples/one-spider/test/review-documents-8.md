# Check of the documents against the code (eighth check of the documents)

Folder checked: `«WORK»\check-eight\docs\now\`. Line numbers are those of the files in that folder.

Result: one statement wrong, six true only in a narrower form (two of them shown by running the code), and two things that cannot be told from the folder. `gameplay.md` and `outside.md` have no findings.

## Wrong

**W1. `README.md` 532-535** (not in the diff; made untrue by the change).
> "**The program as it is here has not been reviewed.** What the last two checks led to is tested, and no reviewer has read it. That includes the gate's own count of the observers, and the second text of the rules being asked with what the second text of the work makes of what was asked."

- The two things named came of the fifth check of a change, by `checks.md` 456-459.
- The last two checks are now `review-change-6.md` and `review-documents-7.md`. `checks.md` 461-462 calls the sixth "a check of the whole claim, looked at fresh, and of what the fifth led to", and 467-470 and 483-485 show both checks reading exactly those two things.
- What the last two checks led to, and what no reviewer has read, is elsewhere in the code:
  - the backdoor's refusal while a count is wrong (`src/backdoor.rs` 213-215);
  - a finding cut to 200 characters (`src/watch.rs` 686, 702);
  - the count put right at the start of a round being said (`src/watch.rs` 1197-1202);
  - the new tests.
- The first two sentences are still true; the "That includes" sentence is stale. The hand-backs are not in my copy, so this rests on `checks.md`'s account of them.

## Narrower than stated

**N1. `observation.md` 54-56** (added by the diff); the same in **`checks.md` 473-474** ("a finding is now cut where it is taken").
> "An answer is taken from an observer that was asked in this round, once, and no more than the first 200 characters of what it found are kept."

- True of the first asking of a round: `src/watch.rs` 686 cuts what is kept in the observer, and 702 cuts what becomes the halt's reason.
- False of the second asking, which line 58 of the same paragraph brings under the same description. In `correct()`, `src/watch.rs` 995-1013, the answers come back whole from `Apart::look` (1791). The first finding that is not empty is put whole into the reason of a halt that cannot be put right (1009-1012, `stick` at 822-831). `shown()` sends that reason whole, twice (1515 and 1530).
- Run to confirm, with the tests' own `say` hook on a new observer's thread and a finding of 20,000 characters: the halt's reason was 20,027 characters, and what a screen is sent went from 5,433 to 45,481 characters.
- The documents are the side that is too wide. Whether the code should also cut there is the author's call.

**N2. `backdoor.md` 68-69** (added by the diff); the same in the comment at the head of `one()`, **`src/backdoor.rs` 210-212** ("until the next round has found it and put it right").
> "While the number of observers, or of an observer's copies, is not what it should be, the backdoor reads and writes nothing: it says so, and the next round puts the count right."

- True of the number of observers: `right_counts` (`src/watch.rs` 516-531) is called at the start of the next round (1193) under every setting.
- Not true of the number of an observer's copies. `right_counts` does not touch copies. The next round only finds it, through the observers' look. The count is put right when the halt ends and eight new observers are made (`correct`, 980-984), and `mend` (1106-1137) decides when that is.
  - Set to end at once, that is the next round.
  - After a pause, it is 0.6 seconds later.
  - On a click, it waits for the click.
- Run to confirm, with one copy popped from `legs B`: under "after a pause" and under "on a click" the observer still had 6 copies 30 rounds later, and a plain read (`spider.body.x`) was refused after every one of the 30.
- A second case, outside the single-fault claim: in a halt that cannot be put right, the round returns before `right_counts` (1180-1191). An observer too few then stays too few and the backdoor does not read, where `backdoor.md` 70-72 says it "still reads". Run: 7 observers after 30 rounds, and the read refused.

**N3. `observation.md` 430-431** (added by the diff); the same in **`checks.md` 486-487** ("The backdoor now reads and writes nothing while a count is wrong").
> "...and the backdoor reads and writes nothing while a count is wrong."

- The sentence stands in the paragraph on the four counts: legs, observers, copies, and the gate's texts.
- The backdoor asks only about two of them, the observers and their copies (`src/backdoor.rs` 213).
- Run: with a leg too few, and with a text of the gate's record too few, `spider.body.gen` was read and `spider.body.x += 1` was written.
- `backdoor.md` 68 says it exactly; these two places say it too widely.

**N4. `README.md` 522-524** (added by the diff), against `checks.md` 467-477.
> "The sixth ran some twenty-one thousand single faults and twelve thousand pairs and found none: what it found was in the tests."

- `checks.md` says "What it found was in the tests and at the edges", and lists three things in the program:
  - a count put right at the start of a round that was not said;
  - a finding with no size, sent whole to every screen;
  - the backdoor's leaning on eight observers.
- The code bears `checks.md` out: each of the three is a change to the program (`src/watch.rs` 1197-1202; 686 and 702; `src/backdoor.rs` 213-215).
- The README's own sentence for the fourth check (519-520) has both halves, "at the edges of it, and in the tests".

**N5. `checks.md` 364-367** (altered by the diff).
> "They are given here in the order of the files. ... the checks came in pairs ... `review-change-2.md` with `review-documents-3.md`, and so on to `review-change-6.md` with `review-documents-7.md`."

- The list that follows gives change-5 (447), change-6 (461), documents-6 (478), documents-7 (482).
- Every earlier pair is given change then documents. Change-6 now stands before documents-6, which lines 478 and 482 place on the version before it.
- No ordering of the file names gives this order either.

**N6. `src/watch.rs` 513-515**, the `///` on `right_counts` (not in the diff).
> "One that is missing is one that is stopped: its place is filled by a stopped one, and the rest find it."

- The code truncates, then pushes stopped observers at the end under the last names (519-523).
- With an observer gone from the middle, the last place is filled, under the name `web`, and the observers after the gap stand one place early. The missing one's own place is not filled.
- It still comes out right, because all eight are replaced when the halt ends.
- At the start of a round the gate itself halts for it (1193-1196) before the rest look.

## Cannot be told from the folder

**C1. `observation.md` 370** (added by the diff): "a check ran three such pairs, and the game could not go on". `checks.md` 474-476 says of what seems the same check: "It ran two sequences that are just outside what is held, one with both faults in one halt and one with no round recorded between". Three pairs and two sequences may both be true, but the two documents do not say it the same way, and the hand-back is not in my copy. The code can produce the outcome: two of the three places changed each another way are a halt that cannot be put right (`src/watch.rs` 446-453).

**C2.** These rest on the author:
- that the 80 tests, the limits and the plans all pass (`README.md` 507);
- the measurements (`README.md` 187-190, `gameplay.md` 107-109), which the code can produce: the tests print those figures at `src/watch.rs` 4956 and 2157;
- the two trials in `checks.md` 259-263, which the code can produce: `observe` at 1876-1881 and `rounds_stopped` in `src/main.rs` 276-310;
- "Built with Rust 1.98": nothing in the folder says so, though the cargo on this machine is 1.98.1;
- everything said of what the reviews found.

## The changed lines that I checked and found true

- **`README.md`**: 80 tests; six checks of changes, seven of documents, thirteen in all, seventeen hand-backs. These agree with the list in `checks.md`.
- **`checks.md` 154-165**: nine kinds of count gone wrong at three instants under three settings; the same twice with one and two recorded rounds between; seven lines at the backdoor; a kept line that names an observer; a count said on each of the three paths, and once.
- **`checks.md` 206-208**: a game put aside while the clock cannot be read.
- **`checks.md` 224-230**: as a description of what the test does (but see N1 for the code beyond the test).
- **`checks.md` 240-243**: the three cases of a round with an upgrade bought in it.
- **`observation.md` 237-239**: both texts of the rules are asked about the one result (`ruled`, `src/watch.rs` 894-903).
- **`observation.md` 441-443**: time and seed from the clock, or nought (`fail`, 803-818).

Also true, though not in the diff:
- 22 waits and 110 thousandths: the loop at `src/watch.rs` 1787 ends at the 8th timeout, the 8th answer or the 8th other arrival, so 7 + 7 + 7 + 1.
- Five ways a halt cannot be put right: the six calls of `stick` and `fail` fall into the five listed.

## Counts

| What | Count | How counted | Documents |
| --- | --- | --- | --- |
| Tests in `src/watch.rs` | 80 | `#[test]` attributes; none ignored | `README.md` 461, 507: agree |
| Checks in `test/limits.js` | 55 | 41 written calls of `check(`; four are in loops of 5, 5, 5 and 3 (lines 64, 79, 86, 224), so 37 + 18 | `README.md` 471: agrees |
| Plans in `test/drive.js` | 11 | keys of the `plans` object | `README.md` 472, 507 and the names in `checks.md` 299-300: agree |
| `src/game/again.rs` | 40 functions, 27 constants | top-level `fn` without the mark `second`; top-level `const`. One more `const N` is inside `web_plan`, and one test-only `static` | `checks.md` 231: agrees; the test asserts (40, 27, 40) |
| `src/rules/again.rs` | 9 functions, 14 constants | the same way | `checks.md` 243-244: agrees |
| `src/watch/looks.rs` | 9 functions | the eight rules and `all_apart`; the eight are the same text but for the mark (compared mechanically) | "eight functions": agrees |
| `OWN_FAULTS` | 25 | array length | `checks.md` 188: agrees |
| Faults in the test of the eight copies | 120, of them 101 different | 90 (nine backdoor names for an observer by ten kinds, on one game), 21 lines and 9 direct faults (each on two games). Different: less 10 because `spider.ring[3]` and `world.ring[3]` are one observer, less 9 of the 21 lines that repeat one of the ninety | `observation.md` 68-69, `checks.md` 227, `src/watch/looks.rs` 7: agree |

## The documents against each other

- Numbers and names agree everywhere I compared them: the waits, five seconds, 0.6 seconds, the 200, 160 and 1,024 characters, eleven plans, thirteen checks, the two "How a halt ends" tables.
- Every reference by section name resolves: "Where it ends", "What is established", "The scope", "How a halt ends" (in both documents), "Checking the work", "What is not observed", "Making the work go wrong", and "Put a change right" on the page.
- The disagreements are W1, N4, N5 and C1 above.

## `page.html`

No findings. Checked against `gameplay.md`, the README's "Running it" and `backdoor.md`, and against `shown()`:
- the four panels;
- the state list brought up to date every sixth frame and laid out again when the moths change;
- a click on a field beginning a line;
- hints above the line, and Tab taking the first;
- a button for each observer that types `alive = false`;
- "halted", "put right", "let through" and "not written" said at the backdoor;
- "Put it right" shown on a click or in a halt that cannot be put right;
- "The server is silent" after a second;
- the stream asked for again a second later;
- "spider no. 1" and the count of dead ones;
- the ring and the pointer's look taken from `over`;
- reduced motion read once.

All 25 things the page reads are sent by `shown()`.

## What I read, and what I did not reach

Read in full:
- all six documents and `documents.diff`;
- the non-test part of `src/watch.rs` (lines 1-1889), `src/backdoor.rs`, `src/main.rs`, `page.html`;
- the head comments of every source file, and the `///` comments the brief names;
- the tests that were new or changed, and about a third of the others.

Not reached:
- The bodies of `src/game.rs`, `src/game/again.rs`, `src/rules.rs` and `src/rules/again.rs`. I read their heads, constants and outlines, and `panics`.
- So the field table and the table of rules in `observation.md`, and the play described in `gameplay.md` beyond its numbers and the page, are not checked line by line.
- The descriptions in `checks.md` of tests the change did not touch were spot-checked by their counts only.
- `test/limits.js` beyond its counts and the looped checks, `test/drive.js` beyond the plan names, and `test/wiring.py` beyond a read.
- I did not open `one-spider.png`.

Not run: the program itself, the whole suite, `limits.js`, `drive.js`, `wiring.py`.

## What I ran, and what I left behind

- **A copy with two tests added.** To confirm N1 to N3 I copied `now/src`, `Cargo.toml`, `Cargo.lock` and `page.html` to `«WORK»\check-eight\docs\try\` and appended two tests to the end of `try\src\watch.rs` (`zz_try_a_count_wrong_and_the_backdoor`, `zz_try_a_finding_at_the_second_asking`). Nothing else differs from `now`. I ran them by name with `--test-threads=2`.
- **Ten of the program's tests, by name, in that same copy.** All passed: `a_count_put_right_is_said`, `a_finding_of_any_length_is_cut_where_it_is_taken`, `a_game_put_aside_while_the_clock_cannot_be_read_begins_at_nought`, `the_eight_copies_of_the_rule_are_one_rule`, `a_round_is_held_to_both_texts_of_the_rules`, `two_counts_gone_wrong_with_one_round_between_are_two_halts`, `a_count_that_goes_wrong_inside_a_round_is_put_right`, the two word-for-word tests, and `the_copies_are_apart_in_the_program_as_built`. They were run in `try`, not from `now` as the brief's command has it.
- **`now` is untouched.** `now\src\watch.rs` has the same SHA-256 as before, and no `target` folder was made there. I removed `try\target`; `try` itself is left for you to keep or delete.
- **One slip against the rules.** While comparing the eight copies of the rule I wrote eight small scratch files to `/tmp`, outside the folder, and removed them in the same command. I checked that they are gone. Nothing else was read or written outside the folder, nothing was sent to any running copy of the program, and no process was stopped.
