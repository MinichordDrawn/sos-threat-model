# Check eleven of the documents against the code: hand-back

Two statements are wrong and two are true only in a narrower form. All four are in lines the latest change added: three in `checks.md` and one in `backdoor.md`. `README.md`, `observation.md`, `outside.md` and `gameplay.md` have no findings, and neither do the source comments or what the documents say of `page.html`.

Line numbers are those of the files in `now/`.

## Wrong

**1. `checks.md` lines 266-268.**
- **Statement:** "Taking out the second cut at the start, the one before the work, or the one before the record is written, fails no test: the next point cuts the same thing down, or the round ends in time at the sizes the test uses."
- **Code:** The cut before the record is written is `self.fit()` at `src/watch.rs:1027`, in `record_now`. The test `what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at` puts a fault in just before that line (instant 4, `game.late = Some((1, fault))` at `watch.rs:4826`, run by the hook at `watch.rs:1022-1025`). It then requires `sized(&game)` as soon as that round is over (`watch.rs:4836`). No later point in that round cuts the state.
- **Trial:** With that one call left out, the test fails at `watch.rs:4836` with "the upgrades taken in, AfterAPause, at instant 4: something of that size is still held".
- **Which side is wrong:** The document, for the third of the three cuts it names.
- **The other two:** The same test passes with the second cut at the start left out (`watch.rs:1345`, longest round 148 ms) and with the one before the work left out (`watch.rs:1448`, longest round 767 ms). Whether no test of the 84 fails for those two cannot be told without the whole suite, which I did not run.

**2. `checks.md` lines 263-266.**
- **Statement:** "Taking out the first cut at the start of a round, of what is kept from the round before, fails it by time: writing a million moths out three times took a round more than two seconds on the machine it was run on."
- **Code:** With `fit_kept()` at `watch.rs:1324` left out, the first reading of the kept state is `settle_before` (`watch.rs:518-541`). It writes each of the three places out once (`state_text`, `watch.rs:361-366`). The test's fault makes the moths long in one place only (`before[1]`, `watch.rs:4801-4805`). The three places are then put right from place 0 (`watch.rs:527-532`) before anything else reads them. So the million moths are written out once in that round.
- **Trial:** With a counter on the write-out, the whole test made three such write-outs, one in each of the three rounds where the fault lands between two rounds (one for each way a halt ends). The slowest round took 1.87 s in one run and 2.03 s in another.
- **Which side is wrong:** "Fails it by time" holds, since the test allows one second. "Three times" is false of one round, so the document is wrong there. It may be counting the three settings.

## Narrower than stated

**3. `backdoor.md` lines 68-70.**
- **Statement:** "Before a line is read, anything in the game that a fault has made too large to read is cut down to a size, as a round does".
- **Code:** `cut_down` (`watch.rs:854-858`) does nothing in a halt that cannot be put right. It does not cut even what the gate keeps from the round before, which a round still cuts there (`watch.rs:1324`).
- **The case:** `backdoor.md` lines 73-76 say the backdoor still reads in such a halt, and `read` (`backdoor.rs:498-533`) writes a whole list out. `observation.md` lines 116-119 state the exception. `backdoor.md` does not.

**4. `checks.md` lines 256-257.**
- **Statement:** "and no round may take as long as one second."
- **Code:** The test times two rounds for each case: the round the fault lands in and the round after it (`watch.rs:4828-4842`, asserted at `watch.rs:4860`).
- **The case:** The three rounds after `put_right()` (`watch.rs:4848-4851`) are not timed. Under "after a pause" and "on a click" those are the rounds in which the halt is put right.

## Cannot be told from the folder

- **`README.md` line 462 and `checks.md` line 311**, "about five minutes" for the tests: the suite was not run. The brief gives about seven on this machine.
- **Measurements not taken here**, though the code could produce each:
  - `README.md` lines 186-190: the 1.09 and 23 thousandths.
  - `observation.md` lines 125-126: a hundred thousand moths under a second, two million more than five.
  - `checks.md` lines 314-318: the two trials. `observe` and `rounds_stopped` do what they describe: one observer alone returns and is found silent, and the second of the same starting stops the program.
- **`README.md` line 508**, "the eleven plans, the limits and the 84 tests all pass": eight of the 84 tests were run and passed (named below). `limits.js`, `drive.js` and `wiring.py` were not run. `wiring.py` needs a folder outside this one.
- **What the reviews found**: not checked, as the brief says. Where an entry also says what the program now does, I checked it and it holds:
  - the cuts before the record is written and at the backdoor;
  - the count said once (`watch.rs:1116-1122` and `watch.rs:1355`);
  - nothing cut in the state in a halt that cannot be put right (`watch.rs:1331-1345` and `watch.rs:854-858`);
  - the most of twenty-four, in all four texts.

## Each document

- `README.md`: no findings.
- `observation.md`: no findings.
- `checks.md`: findings 1, 2 and 4.
- `backdoor.md`: finding 3.
- `outside.md`: no findings.
- `gameplay.md`: no findings. Its last paragraph was confirmed by running `left_alone_for_half_an_hour_it_never_halts`: spider no. 7, 459 caught, 128,894 hundredths gained, and 10 + 9 + 18 + 20 = 57 bought.
- Source comments (`//!` heads of the eight source files, and the `///` and head comments the brief lists): no findings. `Game` has no `///` of its own, so I checked the comments on its fields.
- `page.html` against `gameplay.md`, the README's "Running it", `backdoor.md` and `shown()`: no findings. The page uses all 25 things `shown()` sends, and sends back only what the README lists.

## Counts

Every count agrees with every place the documents give it.

| What | Count | How counted | Where the documents give it |
| --- | --- | --- | --- |
| Tests in `watch.rs` | 84 | `#[test]` attributes, none ignored, none in other files; the runner reports the same | `README.md` 462, 508 |
| Checks in `limits.js` | 55 | 41 places where `check(` is called; four are in loops of 5, 5, 5 and 3 turns (lines 64, 79, 86, 224), counted once a turn: 41 + 4 + 4 + 4 + 2 | `README.md` 472 |
| Plans in `drive.js` | 11 | keys of `plans`; the names match | `README.md` 473, 508; `checks.md` 352-356 |
| `game/again.rs` | 41 functions, 29 constants | 42 `fn` less the mark `second`; 30 `const` less `N` inside `web_plan`, as the test counts them | `checks.md` 275 |
| `rules/again.rs` | 9 functions, 16 constants | 10 `fn` less `second`; `rules.rs` has 9 and 16 | `checks.md` 298-299 |
| `watch/looks.rs` | 8 rules | 9 `fn`: the 8 rules and `all_apart` | "eight functions" throughout |
| `OWN_FAULTS` | 25 | entries of the array | `checks.md` 201 |
| Faults in the test of the eight copies | 120, of which 101 different | 90 (nine backdoor names by ten kinds) + 21 lines + 9 direct; 10 of the 90 repeat because `spider.ring[3]` and `world.ring[3]` are one observer, and 9 of the 21 lines repeat one of the 90: 80 + 12 + 9. The 30 are each put into two games, counted once | `checks.md` 271; `observation.md` 68-69; `looks.rs` head |
| Faults in the test of the cutting down | 20, at 5 instants | array entries; one instant between rounds and four inside | `checks.md` 253 |
| Hand-backs | 23 | 4 reviews, 9 checks of changes, 10 of documents, by the list in `checks.md` | `README.md` 483-492; `checks.md` 379, 418-422 |

- The numbers of the game in `gameplay.md` and `checks.md` match `game.rs` and all four texts.
- The sizes and waits in `outside.md`, `backdoor.md`, `observation.md` and the README match the constants, and match one another.
- Every reference to a section by name resolves to a heading of that name.

## What I read and did not reach

- **Documents:** all six read in full, and `documents.diff` in full.
- **Code read in full:** `watch.rs` lines 1-2090 (everything but the tests), `game.rs`, `backdoor.rs`, `main.rs`, `page.html` from line 100 (markup and script) and its first lines, `limits.js`, `wiring.py`.
- **Tests read in full:**
  - the cutting down, the count said, the counts inside a round, two counts with a round between;
  - the shop's most, what a screen is sent, a finding cut;
  - the two word-for-word tests and their helper, both tests of the two texts of the rules;
  - the eight copies, `OWN_FAULTS` and its test, the half hour, steps that break no rule;
  - the threads tests at lines 4927-4971 and 5211-5302, and 5520-5567.
- **Read in part:**
  - `looks.rs`: the head and two of the eight copies.
  - `game/again.rs` and `rules/again.rs`: heads and outline only. That they are the first texts word for word rests on the two tests, which passed.
  - `rules.rs`: to line 175. I did not read `wrong_step`, so the table of rules in `observation.md` was not checked rule by rule.
  - `drive.js`: the plan names, the usage, the `lives` and `again` plans, and the verdict line.
- **Not reached:**
  - The other tests, about fifty. The paragraphs of "The tests" in `checks.md` that the latest change did not touch were checked against the code only where I name a test above.
  - I did not run the program, `limits.js`, `drive.js` or `wiring.py`.
  - I did not look at the picture.

## What I ran

- **In `now/`, with a name filter and `--test-threads=2`:** the tests of the cutting down, the two word-for-word tests, the eight copies, the count said, the shop's most, the second text of the rules taking nothing from the first, and the half hour. All passed. Rust here is 1.98.1.
- **For findings 1 and 2:** I made a copy of the program inside the folder in which each of the six cuts could be left out, with a counter on large write-outs, and ran only the cutting-down test on it. The remaining results:
  - without the cut before the observers are asked (`watch.rs:1409`), it fails by what is left held, as the document says;
  - without the cut before the work is checked (`watch.rs:990`), it fails the same way, as the document says.
- **The folder:** I removed that copy and the build folder under `now/` afterwards. The folder is as it was given.
