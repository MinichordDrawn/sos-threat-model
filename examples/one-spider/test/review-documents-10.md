# Check ten of the documents against the code

Base folder for every path below: `«WORK»\check-ten\docs\`. Line numbers are those of the files in `now\`.

Two statements are wrong, six are true only in a narrower form, and six cannot be told from the folder. Every count the documents give agrees with the code.

## Wrong

**W1. `checks.md` 254-256**
- Statement: "Taking it out at the start of a round or before the work does not, since the next point cuts the same thing down: those two save the round the cost of what lies between."
- The half about the start of a round is false on this machine. With only `self.fit();` at `src/watch.rs:1280` deleted, `what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at` fails by its own last assertion (`src/watch.rs:4759`, no round as long as two seconds).
- Measured: 2.76 s and 2.69 s in two runs of the test exactly as written. Four more runs with the cut switched off instead of deleted gave 2.14 to 2.37 s.
- The case each time was "the moths in one place of the state kept from the round before", between two rounds. Every other assertion of the test held.
- Where the time goes: between the start of a round and the next cut (`src/watch.rs:1362`), `settle_before` (called at 1283, written at 507-530) writes out all three places of the kept state through `state_text` (350-355). One of them holds a million moths.
- The rest of the passage is true:
  - Without the cut before the work (1401) the test passed, longest round 466 ms.
  - Without the cut before the observers are asked (1362) it fails: "something of that size is still held".
  - Without the cut before the work is checked (954) it fails the same way.
- The verdict turns on timing, and the machine was in use. The unchanged test's longest round here was 138 to 206 ms.
- Side I think is wrong: the document. The code needs the first cut for time, which is what "save the round the cost of what lies between" already says.

**W2. `src/watch.rs` 94-98, the `///` on `MOST_SENT`** (not one of the comments the brief names)
- Statement: "Of anything else, no more than this is sent to a screen: characters of a text in a part or of the list of halted moths, and legs, moths, observers, copies of one observer or catches in number."
- The list of halted moths is sent in two places, and neither is cut at 1,024:
  - inside the `moths` observer, its first 160 characters (`MOST_SHOWN`, `src/watch.rs:1605` through 180-186);
  - as `halted`, its first 20,480 (`MOST_SENT * 20`, `src/watch.rs:1662`).
- The diff corrected `observation.md` 98-104 on this point and left the comment. The comment is wrong.

## Narrower than stated

**N1. `checks.md` 536** (unchanged line, made untrue by the change)
- Statement: "a screen is now sent no more than 1,024 of anything."
- False of two things: the list of halted moths, up to 20,480 characters (`src/watch.rs:1662`), and each thing the game says of itself, up to 4,096 (`MOST_SENT * 4`, `src/watch.rs:1637`).
- It disagrees with `observation.md` 102-105, which gives both numbers. `checks.md` is the wrong side.
- The comment inside `shown()` at `src/watch.rs:1601-1604` ("of everything else no more is sent than `MOST_SENT`") is narrow in the same way. The `///` on `shown` points to it with "see below".

**N2. `README.md` 229-232** (also `README.md` 294-295, `observation.md` 341-342, the `///` on `stuck` at `src/watch.rs:687`, and the comment at `src/watch.rs:1285-1286`)
- Statement: "In a halt that cannot be put right, nothing at all is done with the game's state: nothing looks at it, nothing is written to it, and nothing asked of it is taken down."
- `turn()` now calls `fit()` at `src/watch.rs:1280`, before it asks whether the halt can be put right (1287-1297). `fit()` (811-831) cuts the state, the gate's record, the observers and the three lists.
- I ran this in a copy. In a halt that cannot be put right, one round cut 3,000 moths to 1,024, a text of 3,000,000 bytes to 1,048,576, and one observer's 5,000 copies to 1,024.
- It stays true while nothing held is over the size. Getting something over it in such a halt takes a further fault, since the backdoor writes nothing then.
- Side I think is wrong: the documents. This is what the change made untrue.

**N3. `checks.md` 564-567**
- Statement: "Four it found are left as they are: a leg too many or too few, a moth too few in the gate's copy, and one thing too many in a list of what was asked, each landing after the gate's look, are refused as a step the rules do not allow".
- I ran each in a copy, between the gate's look and the work and after the work, on a game with moths to spend and on one where the spider is carried.
- True of the first three:
  - a leg too many or too few: "a foot further from the body than a leg can reach";
  - a moth too few in the gate's copy: "a moth coming before one was due", or "a moth with a number that has been used".
- For one thing too many in a list it depends on the thing and the list:
  - an upgrade in the first list before the work, with moths to pay for it: a rule ("an upgrade bought that was not asked for");
  - a letting go in the first or second list while the spider is carried: a rule ("the food meter not what eating and time make it");
  - a pointer's place or a press in the first list before the work, or in the second list at either instant: refused by the second doing ("came out another way in ..."), with no rule named;
  - an upgrade in the second list: refused by the second doing ("... in the moths, counts and shop");
  - anything in the third list, or in the first list after the work: no halt, and the recording empties it.
- Which case the review ran cannot be told from the folder.

**N4. `observation.md` 108-109** (also the `///` on `fit` at `src/watch.rs:800-802`, the comment on `MOST_HELD` at 89-91, and `checks.md` 558-559, "cut down to a size before anything looks at it")
- Statement: "Before anything the game holds is written out, copied or compared, it is cut down to a size that can be".
- All four cuts are inside a round (`src/watch.rs:954, 1280, 1362, 1401`). Between two rounds the game is used uncut:
  - a read at the backdoor writes out a whole list (`src/backdoor.rs:495-529`) before the answer is cut at 64,000 bytes (172-179);
  - a `during` line copies the whole game to try the line on (`src/backdoor.rs:130`);
  - a press or an upgrade is counted through `asked()`, which compares the three lists (`src/watch.rs:543-551, 1499-1501, 1513, 1539`).
- This is from reading; I did not run it.

**N5. `observation.md` 115-117** (and the `///` on `fit`, `src/watch.rs:809-810`)
- Statement: "What the gate keeps of its own in three places is not cut".
- True of `Book`. The state kept from when a round's work began is also held in three places (`src/watch.rs:419`) and is cut (`src/watch.rs:816-819`), as `checks.md` 248-249 itself says.
- This is a finding only if the sentence is read to cover that state. `observation.md` 161-162 calls it "held in three places the same way".

**N6. `src/watch.rs` 1674, a comment inside `shown()`** (not one of the named comments)
- Statement: "what was written during the work and let through, because no rule of the game forbids it".
- A line is let through only when the round is recorded, and that needs the second doing to give the same (`src/watch.rs:978-981`). A line no rule forbids that changes anything is refused there.
- It is a leftover of the kind `checks.md` 572-573 says were corrected. `page.html` 392-393 says it rightly.

## Cannot be told from the folder

- `checks.md` 560-561, "seven ways ... there are tests now for each". The tests are there (`src/watch.rs:4577-4592` and 4594-4668), but which seven the review named is in the review.
- `checks.md` 567-568, "some eight million characters". This is the review's count, and it does not say of which version. My own rough reading of `shown()` gives the same order of size.
- `README.md` 444, "Built with Rust 1.98". `Cargo.toml` names no version. It builds here with rustc 1.98.1.
- `backdoor.md` 91 and 104, the two "put right:" lines. Which parts are put back depends on the game at that instant. The form is what `src/watch.rs:1154` and 1094 produce.
- `README.md` 461 and `checks.md` 295, "about five minutes" for the tests. I did not run the suite.
- `README.md` 549-551, `LICENSE` at the top of the repository, which is outside the folder.

## Counts

All agree with every place the documents give them.

| What | Count | How counted |
| --- | --- | --- |
| Tests | 84 | 84 `#[test]` in `src/watch.rs`, none in any other file; cargo reports 84 (run plus filtered out) |
| Checks in `test/limits.js` | 55 | 41 calls of `check(`; four sit in loops of 5, 5, 5 and 3 turns (lines 64, 79, 86, 224), so 41 - 4 + 18 |
| Plans in `test/drive.js` | 11 | the keys of `plans`; same eleven names as `checks.md` 338-339 |
| `src/game/again.rs` | 41 functions, 29 numbers | 42 `fn` less the mark `second`; 30 `const` less the `const N` inside `web_plan`; the test asserts `(41, 29, 41)` |
| `src/rules/again.rs` | 9 functions, 16 numbers | 10 `fn` less `second`; `src/rules.rs` has the same 9 and 16 |
| `src/watch/looks.rs` | 9 functions | eight copies of the rule and `all_apart` |
| `OWN_FAULTS` | 25 | the array's declared length; the test asserts `2 * 25 * 3` |
| Faults in the test of the eight copies | 120, 101 different | see below |

- The eight copies of the rule are the same text but for the name and the mark; I compared them by script.
- The 120 faults are 90 (nine backdoor names by ten kinds of change), 21 lines and 9 placed directly.
- The 101 different are 80 of the 90 (`spider.ring[3]` and `world.ring[3]` are one observer), 12 of the 21 lines (nine repeat one of the 90) and the 9.

Also agreeing: 8 checks of changes, 9 of documents, 17 in all, 21 hand-backs, 11 single faults (4 + 1 + 1 + 3 + 1 + 1 by the entries of `checks.md`). The order of the list in `checks.md` matches lines 402-406.

## The changed lines found true

Apart from W1 and N3, every line `documents.diff` adds or alters was found true. Checked in particular:
- the shop's two mosts and every number in the `gameplay.md` table (19: 33, 23, 48; 40: 42, 48);
- "no more" on the page (`page.html` 361);
- the four instants, the reasons that name the count, and the record said to be the record;
- a count said once across five times in one halt;
- the thirteen large faults and their four instants;
- 20,480, 4,096, 1,024 entries and 1,048,576 bytes;
- the rule added to the table in `observation.md`, and "the number the last one was given";
- the paragraph on the two texts of the rules;
- the order of the review entries.

Every reference from one section or document to another by name leads to a section of that name.

## Documents and comments with no findings

- `gameplay.md`: no findings. The half-hour numbers at 109-111 are what the test prints: 459 caught, 128,894 hundredths gained, 10 + 9 + 18 + 20 = 57 bought, spider no. 7.
- `backdoor.md`: no findings.
- `outside.md`: no findings.
- `README.md`: N2 only.
- `observation.md`: N2, N4, N5.
- `checks.md`: W1, N1, N3.
- Head comments (`//!`) of all eight source files: no findings.
- The named `///` comments: N4 and N5 on `fit`; N1 touches `shown` through "see below"; N2 is on `stuck`. No findings on `Book`, the fields of `Game`, `fail`, `right_counts`, `counts_off`, `correct`, `restore`, `round_at`, `ruled`, `Apart`, `clock`, `Own` or `run`.
- The comment at the head of `one()` and the comments at the head of the script in `page.html`: no findings.
- `page.html` against `gameplay.md`, the README's "Running it", `backdoor.md` and `shown()`: no findings. Every name the page reads is one `shown()` sends.

## What I ran

All from `now\`, each with a name filter and `--test-threads=2`, in the foreground. All passed:
- `the_second_text_of` (three tests)
- `left_alone_for_half_an_hour_it_never_halts`
- `the_shop_has_no_more_of_an_upgrade_that_is_at_its_most`
- `a_count_that_goes_wrong_inside_a_round_is_put_right`
- `a_count_put_right_is_said`
- `two_counts_gone_wrong_with_one_round_between_are_two_halts`
- `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long`
- `the_eight_copies_of_the_rule_are_one_rule`
- `a_round_is_held_to_both_texts_of_the_rules`
- `what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at`
- `the_copies_are_apart_in_the_program_as_built`

I did not run the program itself, sent nothing to any running copy, and stopped no process.

For W1, N2 and N3 I made two copies of the sources inside the folder and ran named tests there:
- `check-plain\`: `now\src` with the one line at `src/watch.rs:1280` taken out.
- `check-work\`: a switch on each of the four cuts, an early form of the test's own two-second assertion, and two probe tests whose names begin `zz_probe`.

Their build output is deleted; the sources are left for you to look at or remove. `now\target` holds the build output of the command the brief gave.

## Read in full, and not reached

Read in full:
- all six documents and `documents.diff`;
- `src/watch.rs` lines 1 to 2301 (everything outside the tests, the test helpers and the first test);
- `src/game.rs`, `src/rules.rs`, `src/backdoor.rs`, `src/main.rs`, `page.html`, `test/wiring.py`.

Read in part:
- the tests in `src/watch.rs`: those the changed lines describe (2853-3267, 3803-3856, 4077-5087);
- `src/game/again.rs` and `src/rules/again.rs`: heads and lists of functions and numbers, with the bodies left to the word-for-word tests, which I ran;
- `test/limits.js`: its head and every `check(` call, with long lines read only at their start;
- `test/drive.js`: its head and the names of the plans.

Not reached:
- the unchanged descriptions in `checks.md` of tests I did not read (the pointer, the spider's lives, the three places, the observers on threads, the record's two halves) against those tests;
- what each plan of `test/drive.js` does, and the detail of each check in `test/limits.js` beyond its name and count;
- the two trials, the measurements of waits, and that the whole suite, the limits and the plans pass;
- N4 by running.
