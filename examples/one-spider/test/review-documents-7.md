# Hand-back: the documents of One Spider against the code

Folder checked: `«WORK»\check-seven\docs\`. Document references are to the files in `now\`, source references to `now\src\`, as `file:line`.

Two statements are wrong and six are true only in a narrower form. The one that matters is N1: the backdoor still leans on there being eight observers without asking, and a wrong count can still stop the program in the wrong place through it. I confirmed that by running it.

## Wrong

**W1. `checks.md:160-161`**
> "That a stop is caught is from reading the program, from two of these tests, which catch it as the program does"

- Three tests run the round under the catch that `play` in `main.rs` uses (`guarded`, `watch.rs:3843`):
  - `a_stop_that_comes_back_every_round_puts_the_game_aside_at_the_second` (`watch.rs:3877`)
  - `a_count_that_goes_wrong_inside_a_round_is_put_right` (`watch.rs:3933-3942`)
  - `two_counts_gone_wrong_with_one_round_between_are_two_halts` (`watch.rs:3967-3996`)
- Only the first has a stop to catch. The other two now assert that nothing stops (`watch.rs:3952`, `3967`).
- So the number is one (tests in which a stop is caught) or three (tests that go through the catch). It is not two.

**W2. `watch.rs:534-535`, the `///` on `stopped`**
> "The counts are put right first, since a count gone wrong inside a round is what brings such a stop about"

- This is left over from before the change. In the round's own code a wrong count is now a plain halt: `watch.rs:3952` asserts no stop in 63 cases, and it passes.
- `observation.md:321-322` and `424-426` say the opposite of the comment. The comment is the side I think is wrong.
- The comment of the test at `watch.rs:3905-3908` ("a halt or a stop in the wrong place") has the same leftover.
- The one path by which a count can still bring a stop about is N1 below, and that is not what this comment describes.

## Narrower than stated

**N1. `observation.md:424-426` and `checks.md:446-447`**
> "One too many or too few of any is found and put right, between two rounds or inside one, and nothing stops in the wrong place for it: the observers and the gate each count what they are given before they lean on it."

> "Every place that leaned on there being eight observers now asks first"

True of `watch.rs` and `watch/looks.rs`. Not true of `backdoor.rs`:
- It lists the observers by the fixed lengths of the two rings (`backdoor.rs:423`) and indexes `game.ring[i]` without asking (`backdoor.rs:371`, `384`).
- It indexes `copies[p]` for `p` up to seven without asking (`backdoor.rs:457`, `470`, `477`).

Two cases, both run in a copy of the program (see "What I ran"):
- **(a) A line at the backdoor while a count is wrong, before the next round puts it right.**
  - With the last observer gone, `world.ring`, `world.ring[2].alive`, `world.ring[2].alive = false` and `world` each stop at `backdoor.rs:371` (index out of bounds).
  - With one observer a copy short, `spider.ring[1].copies[6]` stops too.
  - In the program this is caught at `main.rs:589` and the line is refused, as `outside.md:64-66` says. The game is not touched.
- **(b) A line kept with `during` that names an observer, in a round whose work loses an observer.**
  - The line is written on the round's own thread (`watch.rs:1294`).
  - With `during world.ring[2].alive = false` kept and the last observer gone after the gate's look, the round stopped at `backdoor.rs:371` under all three settings.
  - `stopped` was called, `stops` was 1, and the halt's reason was "the game's own work stopped where it should not have".
  - This takes a kept line and a count fault in the same round, so I do not say the single-fault result fails. I say only that "nothing stops in the wrong place for it" and "every place" are false there.

The test at `watch.rs:3988-3996` tries a screen, the pointer, a press and an upgrade with the count wrong. It does not try a backdoor line.

**N2. `checks.md:156-158`**
> "It must be a halt like any other, with nothing stopping in the wrong place, it must be put right, and the game must go on."

- The test requires at most one halt, not one (`watch.rs:3936`, `3945`: `game.halts <= 1`).
- For the three faults in the gate's texts at the third instant there is none: the record is written anew whole (`watch.rs:879-882`, `948`) and nothing is left to find.
- That is 9 of the 63 cases.

**N3. `checks.md:158`**
> "The same twice, with one round recorded between: two halts, and the game not put aside."

- The test puts three rounds between the two faults (`watch.rs:3970`).
- Set to end at once, that is three recorded rounds between. Under the other two settings it is two, because the round that puts right does no work.
- It is never one, so the sequence named in `checks.md:445-448` and `README.md:520-522` is not the one the test runs.
- The test would still fail if the stop came back: it asserts that no round stops and that `stops == 0` (`watch.rs:3967-3968`).

**N4. `checks.md:159`**
> "A count put right must be said."

- It is said when the count is put right in `stopped` (`watch.rs:552-554`) or in `restore` (`watch.rs:1036-1038`).
- It is not said when the gate puts it right at the start of a round (`watch.rs:1189-1193`). The reason of the halt names it, and the list of what was put right does not.
- The tests at `watch.rs:4480-4483` and `4595` require that list to be exactly "all eight observers started again".

**N5. `observation.md:236-237`, and the `///` on `ruled` at `watch.rs:887`**
> "The second text is handed nothing the first text of the work made."

- It is handed the result itself: the state as the first doing left it (`&self.spider, &self.world`, `watch.rs:896-897`), which is what it is asked about.
- What was asked and the halted moths are its own, as stated (`watch.rs:893-895`, `897`).

**N6. `observation.md:436-438`, `README.md:267-268`, and the `///` on `clock` at `main.rs:87-88`**
> "after a stop in the wrong place the game that waits to be begun takes its time and its seed from the clock"

- Not when the clock cannot be read. The game then begins at nought, with a seed that is always the same (`watch.rs:801-804`).
- No document says so.

## Cannot be told from the folder

- **Files not in the copy:** the picture and what `README.md:23-28` says of it; `LICENSE` (`README.md:548`); the model check and the Chernobyl example; `test/review-*.md`.
- **What the reviews found:** not checked. Where such a sentence also says what the program now does, I checked that part and found it true, except `checks.md:446-447` (N1).
- **`checks.md:449-450`:** "three changes that no test failed for, each of which now has one". Nothing in the folder says which.
- **Measurements and trials:** the code could produce each of them.
  - `README.md:187-190`: the test at `watch.rs:4763-4774` prints the longest wait and the most waits used. 23 thousandths with one wait used is possible, since each answer may take just under one wait.
  - `gameplay.md:107-109`: the test at `watch.rs:2131` prints the tally, the shop and the spider's number.
  - `checks.md:249-253`: an observer that says the rounds have stopped ends its thread (`watch.rs:1852-1854`), so it is not asked again and is found silent. One alone does not stop the program (`main.rs:287-289`).
- **"All pass" (`README.md:506-507`):** nine of the 78 tests passed here. The rest, `limits.js`, `drive.js` and `wiring.py` were not run.

## Counts

All agree with the documents.

| What | Count | How counted | Where the documents give it |
| --- | --- | --- | --- |
| Tests in `watch.rs` | 78 | `#[test]` lines; the test run also reported 9 passed and 69 filtered out. No other source file has any. | `README.md:461`, `507` |
| Checks in `limits.js` | 55 | 41 calls of `check(`; four are in loops over 5, 5, 5 and 3 cases (lines 64, 79, 86, 224). | `README.md:471` |
| Plans in `drive.js` | 11 | The keys of `plans` (line 43 on); the names match. | `README.md:472`, `507`; `checks.md:287-290` |
| `game/again.rs` | 40 functions, 27 constants | 41 top-level `fn` less the mark `second`; a 28th constant, `N`, is inside `web_plan`. | `checks.md:224`; the test asserts (40, 27, 40) |
| `rules/again.rs` | 9 functions, 14 constants | 10 top-level `fn` less `second`. `rules.rs` has 9 and 14. | `checks.md:233-234` |
| `watch/looks.rs` | 9 functions, 1 constant | The eight rules and `all_apart`; the constant is `LOOKS`. | The documents say only "eight functions" of the rules |
| `OWN_FAULTS` | 25 | Entries of the array (`watch.rs:4290`). All nineteen fields of `Book` are among them. | `checks.md:185` |
| Faults in the test of the eight copies | 120, of which 101 different | 9 names by 10 kinds of change (90), 21 lines, and 9 direct faults. Ten are the same observer under its second name, and nine lines are also among the 90. | `observation.md:67-68`; `checks.md:221`; `looks.rs:7` |

The 21 lines and 9 direct faults are each put into two games, so there are 150 faulted games and 3 clean ones. Each is looked at twice, by each copy as each observer.

## The documents, one by one

- **`README.md`:** nothing wrong; N6 at 267-268. The other lines the diff changed are true: 205-206, 461, 482-494, 507, 520-522 (with N3 for "one round"), 530-534.
- **`observation.md`:** N1, N5, N6. The other changed lines are true:
  - 67-68, 77-78, 105-106
  - 173-175: the pause is waited out again only where the first try moved the state (`watch.rs:1114-1126`)
  - 321-323, 331-333
  - The five ways at 303-323 are all the ways the code makes a halt that cannot be put right.
- **`checks.md`:** W1, N1, N2, N3, N4. The other changed lines are true: 189, 221, 225, 229-233, 314, 353-357.
- **`backdoor.md`:** no findings.
- **`outside.md`:** no findings; the changed lines 66-68 are true.
- **`gameplay.md`:** no findings; the changed lines 100-102 are true. `INSET` is in `game.rs:18`, `rules.rs:25` and `rules/again.rs:36` and not in `game/again.rs`, and no round's work uses it.
- **The documents against each other:** numbers and names agree wherever two say the same thing. Every reference to a section by name finds that section.
- **Comments at the head of the source files, and the `///` named in the brief:** W2 on `stopped`; N5 mirrored on `ruled`; N6 mirrored on `clock`. No findings on the others: `Book`, the fields of `Game`, `fail`, `right_counts`, `correct`, `restore`, `round_at`, `Apart`.
- **`page.html`:** what the documents say the page shows and does is true of the page and of what `shown()` sends (`watch.rs:1470-1546`). Checked by reading only.

## What I read

- **In full:** the six documents; `documents.diff`; `watch.rs`, `watch/looks.rs`, `game.rs`, `rules.rs`, `main.rs`, `backdoor.rs`; `page.html`; `wiring.py`; `Cargo.toml`.
- **In part:**
  - `game/again.rs`: lines 1-215, and the rest by its list of functions and constants. The word-for-word test, which I ran, holds it to `game.rs`.
  - `rules/again.rs`: lines 1-70, and the rest the same way.
  - `limits.js`: all of it, with long lines cut at a few hundred characters.
  - `drive.js`: its head, the list of plans, and the `lives` and `again` plans. The other nine plans only by what they print.

## What I did not reach

- The whole suite: 69 of the 78 tests were not run.
- The program itself was not started, so nothing was sent to any port.
- The page in a browser.
- `limits.js`, `drive.js` and `wiring.py` were not run. `wiring.py` needs the model check, which is not in the folder.
- The table of rules in `observation.md:264-273` I compared with `rules.rs` cell by cell and found true. The game's numbers in `gameplay.md` I compared with the constants in `game.rs`, not with a run.

## What I ran, and what I left in the folder

- **From `now\`:** `cargo test --release --target-dir ./target -- --test-threads=2` with nine name filters. All nine passed:
  - `two_counts_gone_wrong_with_one_round_between_are_two_halts`
  - `a_count_that_goes_wrong_inside_a_round_is_put_right`
  - `a_count_put_right_is_said`
  - `what_was_asked_is_emptied_where_the_round_is_recorded`
  - `a_round_is_held_to_both_texts_of_the_rules`
  - `the_eight_copies_of_the_rule_are_one_rule`
  - both word-for-word tests
  - `the_copies_are_apart_in_the_program_as_built`
- **For N1:** I copied the program to `...\check-seven\docs\probe\` and added two tests at the end of `probe\src\watch.rs` (names beginning `probe_`). I ran only those two. Nothing in `now\` was changed.
- **Left behind:** the build output in `now\target\`, and the whole of `probe\` with its own `target\`.
- **Toolchain:** rustc 1.98.1, which agrees with "Built with Rust 1.98" (`README.md:444`).
