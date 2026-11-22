# Check nine of the documents against the code: hand-back

I found no statement that is false of the code outright. Six statements are narrower than stated, and one is contradicted by its own document but cannot be settled from the folder. Everything the latest change added or altered in the documents holds, apart from those listed below.

## Findings

### Wrong

None found.

### Narrower than stated

**1. `observation.md` lines 103-105** (unchanged text, made untrue by the latest change)

> "Two things are sent whole all the same: the `moths` observer's list, by which a screen knows which moths are halted, and the reason of a halt. What the backdoor wrote of either is no longer than 1,024 characters."

- **The list.** `shown()` now sends it as `quote(&short(&self.halted_moths(), MOST_SENT))` (`src/watch.rs:1550`), so it is cut at 1,024 characters. It is whole only up to that length, which covers everything the backdoor can write. A list a fault has made longer is cut, which is the case the new test puts first (`src/watch.rs:3071`).
- **Against its own paragraph.** The sentence the change added just above it (lines 98-99) says the opposite of the same list: "no more than 1,024: characters of a text in a part or of the list of halted moths".
- **The reason.** The halt's reason is sent whole as the gate keeps it (`src/watch.rs:1527-1528`). But an observer's reason written at the backdoor becomes the halt's reason only as its first 200 characters (`short(&o.why, MOST_TOLD)`, `src/watch.rs:707`). The 1,024 bound is true of what was written, not of what is sent.
- **Which side is wrong:** the document. The code and the new sentence agree.

**2. `checks.md` lines 233-234** (added line)

> "What a screen is sent, before it is found and in each round of the halt, must stay within a fixed size, and be as it was when the halt has ended."

- The test (`src/watch.rs:3089-3096`) looks at five rounds of the halt.
- After the halt it requires only that the length of what is sent is within 2,000 characters of the length before the fault (`game.shown(now).len() < usual + 2000`). It does not compare what is sent.
- "Within a fixed size" is `usual + 400_000` characters, which holds.

**3. `src/rules.rs` lines 15-16** (head comment)

> "These rules are bounds and counts. A wrong step that keeps within them is recorded as true: a moth a little to one side of where it should be, a spider a step ahead of itself."

- This is true only of a mistake that both texts of the work make.
- A step put in during a round that breaks no rule is not recorded. The second doing finds it (`redone()`, `src/watch.rs:883-886` and `923-932`), and the test at `src/watch.rs:2846-2880` requires that for eleven such lines.
- `observation.md` lines 257-261 and `backdoor.md` lines 96-113 say it the way the code has it.
- The `///` on `backdoor::run` (`src/backdoor.rs:113-114`, "it is for the rules of the game to find it") leans the same way. It is not on the brief's list.

**4. `observation.md` line 18**, and the `///` on `Own` (`src/game.rs:302-305`)

> "when the next moth is due and the number it will be given"

- What is kept is the number last given, not the next one. `next_id` starts at 0 (`src/game.rs:327`), and `arrive()` adds one before it uses it (`src/game.rs:778-779`).
- The `///` on `Record` (`src/watch.rs:247`) has it right: "the highest number any moth has yet had".
- This is off by one and small.

**5. The `///` on `Game::shown` (`src/watch.rs:1488-1489`) and the comment in `page.html` lines 182-183** (neither is on the brief's list of comments)

> "the whole of the open state, laid out by the names the backdoor knows it by"

- A screen is sent the beginning of an observer's texts (24 and 160 characters) and, since the latest change, no more than 1,024 of anything else (`src/watch.rs:1496-1507`).
- The comment inside the function (`src/watch.rs:1492-1495`) says so.

**6. `checks.md` lines 156-158** (added line; the statement is narrower than the test, not than the code)

> "Where it is a text of the record, gone after the work, the halt's reason must say that it was the record."

- The test requires the reason for a text too many as well as for one gone (`src/watch.rs:4101-4103`, every fault whose name begins "a text").
- The code gives it for either (`observers_off()`, `src/watch.rs:769-770`).
- Nothing here is false. It is listed so the sentence can be widened if wanted.

### Cannot be told from the folder

**7. `checks.md` lines 373-377** (altered line)

> "They are given here in the order they were made in. … After it the checks came in pairs, a check of a change and a check of the documents on the same version: `review-change-2.md` with `review-documents-3.md`, and so on to `review-change-7.md` with `review-documents-8.md`."

- The list runs `review-change-6.md` (line 475), `review-change-7.md` (line 493), `review-documents-7.md` (line 509), `review-documents-8.md` (line 515).
- By the document's own entries, `review-documents-7.md` was made on the version `review-change-6.md` read ("after the fifth check's changes"; "as the check of the documents on the same version did").
- `review-change-7.md` was made on a later version. It checked "the backdoor while a count is wrong", which is the change the sixth change check and the seventh documents check led to.
- So either the order of the list or the sentence about it is off for those two. Every other pair stands together in the list.
- The hand-backs are left out of my copy, so I cannot say which. I think it is the order of the list.

**8. Statements on the author's authority.** For each I checked only that the code could produce it.

- The waits measured in 30,000 rounds (README lines 187-190): the test prints both figures (`src/watch.rs:5055-5056`).
- The two trials (`checks.md` lines 269-273): both are consistent with `observe()`, `rounds_stopped()` and `Apart::look()`.
- "About five minutes" for the tests (README line 461, `checks.md` line 266).
- "Built with Rust 1.98" (README line 444).
- The picture.
- What each earlier review found.
- That `LICENSE` is at the top of the repository.
- The result of `test/wiring.py`, whose checker is outside the folder.

## By document

- **`README.md`:** no findings.
- **`observation.md`:** findings 1 and 4.
- **`checks.md`:** findings 2, 6 and 7.
- **`backdoor.md`:** no findings. Both the new paragraph on a wrong count and the comment at the head of `one()` hold: the refusal comes before any read or write, the gate puts the number of observers right at the start of a round, and a halt that cannot be put right returns before that.
- **`outside.md`:** no findings.
- **`gameplay.md`:** no findings. I ran the half-hour test: it prints 459 caught, 128,894 hundredths gained, 10+9+18+20 = 57 upgrades and spider no. 7, as the last paragraph says.
- **`page.html`:** no findings against what `gameplay.md`, README "Running it", `backdoor.md` and `outside.md` say of it, apart from the comment in finding 5. Every key the page reads is in what `shown()` sends.
- **Head comments and the listed `///` comments:** finding 3, and finding 4 for `Own`. The others hold: `Book`, the fields of `Game` (the struct itself has no `///`), `stopped`, `fail`, `right_counts`, `correct`, `restore`, `round_at`, `ruled`, `Apart`, `clock`, and the head of `one()`.

## Counts

Every one agrees with every place the documents give it.

| What | Count | How I counted | Where the documents give it |
| --- | --- | --- | --- |
| Tests in `src/watch.rs` | 81 | `#[test]` lines; the test runner also reports 81; no other file has any | README lines 461 and 507 |
| Checks in `test/limits.js` | 55 | 41 call sites of `check(`; four sit in loops of 5, 5, 5 and 3 turns, adding 4+4+4+2 | README line 471 |
| Plans in `test/drive.js` | 11 | keys of `plans`, the same eleven names as `checks.md` lines 309-310 | README lines 472 and 507, `checks.md` line 307 |
| `src/game/again.rs` | 40 functions, 27 constants | not counting the mark `second()`, the tests' `PASSED`, or `N` inside `web_plan` | `checks.md` line 239 |
| `src/rules/again.rs` | 9 functions, 14 constants | not counting `second()` and `PASSED` | `checks.md` lines 253-254 |
| `src/watch/looks.rs` | 8 copies of the rule | plus `all_apart()` and the list `LOOKS` | "eight" throughout |
| `OWN_FAULTS` | 25 | array length; the test asserts 2 × 25 × 3 | `checks.md` line 190 |
| Faults in the test of the eight copies | 120, of which 101 different | see below | `observation.md` lines 68-69, `checks.md` line 235, `looks.rs` line 7 |

The 120 are 90 + 21 + 9:
- **90:** nine backdoor names times ten kinds of change. `spider.ring[3]` and `world.ring[3]` are one observer, so 80 are different.
- **21:** the lines. Nine repeat one of the 90, so 12 are different.
- **9:** the faults put straight in, all different.

**Reviews:** seven checks of changes, eight of the documents, fifteen in all, and nineteen hand-backs with the four reviews. These agree between README lines 482-491 and `checks.md` lines 334, 373 and 536. The ten single faults of README line 486 add up from the entries in `checks.md` (4 + 1 + 1 + 3 + 1).

**References by name:** every section or document named from another exists under that name.

## Tests I ran

Each was run by name with `--test-threads=2`, and all five passed:
- `left_alone_for_half_an_hour_it_never_halts`
- `a_finding_of_any_length_is_cut_where_it_is_taken`
- `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long`
- `a_count_that_goes_wrong_inside_a_round_is_put_right`
- `a_round_is_held_to_both_texts_of_the_rules`

I did not run the program itself.

## What I read

**In full:**
- all six documents and `documents.diff`
- `src/watch.rs` lines 1-1920, which is everything but the tests
- `src/game.rs`, `src/backdoor.rs`, `src/main.rs`, `page.html`, `test/wiring.py`

**In part:**
- **The tests in `src/watch.rs`:** the ones the changed lines turn on, and those behind the clock, the wrong counts, the stops in the wrong place, the observers on threads, the backdoor's sizes, the wrong steps and the eight copies. I did not read the rest line by line.
- **`src/watch/looks.rs`:** the head and the first copy only. The other seven are held to it by a test I did not run.
- **`src/game/again.rs`:** the head, the constants and the list of functions.
- **`src/rules.rs` and `src/rules/again.rs`:** the heads, the constants, the small functions and the list of rule messages. I checked the table of rules in `observation.md` against the messages, not against the logic of each rule.
- **`test/limits.js`:** the check calls and the loops.
- **`test/drive.js`:** the head, the list of plans and the `again` plan.

## What I did not reach

- **The other 76 tests** were not run, nor were `test/limits.js`, `test/drive.js` or `test/wiring.py`. "All pass" stands on the author's word beyond the five above.
- **Descriptions in `checks.md` of tests the change did not touch** were sampled, not each held to its test. Those I did hold to the code: the wrong steps (54, eleven and six), the backdoor's sizes, the half hour, the clock, the wrong counts, the stops, the observers on threads, and the 25 kinds in three places.
- **Statements about what the earlier reviews found** were not checked, as the brief says, except where they say what the program now does. Those parts hold.

## Two things about how the work was done

- I started the first test run in the background, and the tool wrote its captured output into the system's temporary folder, outside the folder I was given. I did not open that file. I ran the test again in the foreground and used that output.
- The build wrote `now/target`, inside the folder, as the brief's command directs. Nothing else was written.
