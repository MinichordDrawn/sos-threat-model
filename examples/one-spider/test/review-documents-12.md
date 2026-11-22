# Check twelve of the documents against the code: hand-back

Folder checked: `«WORK»\check-twelve\docs\`

## Outcome

I found no statement that is plainly false of the code. I found six statements true only in a narrower form and two that cannot be told from the folder. Every line that `documents.diff` adds or alters was traced to code or to a test; the ones not listed below hold.

## Wrong

None found.

## Narrower than stated

**N1. A text of tens of millions of characters ending the program.**
- `observation.md:128-129`: "So did a text made tens of millions of characters long."
- `observation.md:131-132`: "a text thirty million characters longer is thirty million."
- `README.md:344-345`: "So does a round made too long by a list or a text that has grown by millions between two of the points where what is held is cut down."
- `checks.md:628-630` and `633-635`: "a text of 24 million control characters ... made a round take more than five seconds"; "A text made tens of millions of characters long that lands between two cuts stays outside what is held, as a list does."

Nothing bounds a text between two cuts, so the edge exists (`src/watch.rs:842-859`, cuts at `998`, `1035`, `1353`, `1417`, `1456`). But with `quote()` now writing a control character directly (`src/backdoor.rs:79-83`), the sizes the documents name no longer take a round past five seconds on this machine.

I measured this in a copy, with a test hook added just after each of the four cuts inside a round. Observers were on threads of their own with the program's waits, and halts were set to end after a pause and at once. Some cases were also run with the observers together.

| What landed just after a cut | Longest round |
| --- | --- |
| 24 million control characters in `spider.body.state` | 1.0 to 1.6 s |
| 64 million control characters, same field | 2.6 to 4.4 s |
| 80 million control characters, same field | 3.3 to 4.7 s |
| 96 million control characters, same field | 4.0 s at once, 5.6 s after a pause |
| 96 million ordinary characters, same field | 1.6 to 1.9 s |
| `world.web.torn`, 64 million characters of numbers | 0.8 to 1.1 s |
| `world.web.torn`, 30 million control characters | 0.7 to 1.5 s |
| 64 million control characters in an observer's reason, an observer's copy, or a text of the record | under 0.7 s |
| the list of halted moths made 32 million commas | under 0.7 s |
| 100,000 moths (for comparison) | 0.7 to 0.9 s |
| 2 million moths (for comparison) | about 17 s, and about 6 s just before the record is written |

- The statements about lists hold as written (`observation.md:126-127`).
- For a text, only one of about ninety million control characters or more passed five seconds; 24 and 30 million did not come near.
- I think the documents are the side that is behind: they carry the tenth check's measurement of the version before the fix.
- This is my measurement on a machine in use, in the test harness, at the fields and instants named. I cannot rule out a costlier field or instant.

**N2. `checks.md:632-633`: "the work is handed no more of the list of halted moths than a game could have."**
- `halted_moths()` hands the work the first 20,480 bytes (`src/watch.rs:694-702`), and the test asserts exactly 20,480 (`src/watch.rs:3282-3283`).
- By the documents' own account a game has 48 moths at the most (`observation.md:110-111`), so a game's list is a few hundred characters.
- A list a fault has made longer than that, up to 20,480 characters, is handed whole.
- `observation.md:118-120` gives the bound correctly; this sentence is the one too tight.

**N3. `backdoor.md:74-75`: "In a halt that cannot be put right nothing looks, and so nothing is written either."**
- In such a halt the gate still compares its three places and the three places of the state kept from the round before (`src/watch.rs:1332-1336`).
- A screen is still written the whole state every round (`src/main.rs:323-324`, `src/watch.rs:1654`).
- The backdoor still reads, as the same paragraph says (`src/backdoor.rs:273-278`).
- `README.md:231` was narrowed in this change to "no observer looks at it"; `backdoor.md` still has the wider wording, so the two documents now say the same thing two ways.

**N4. The `///` on `fit`, `src/watch.rs:829-830`: "in such a halt nothing else is looked at, and nothing else is touched."**
- The matching sentence in `observation.md:117-118` had "looked at" taken out in this change; the comment still has it.
- The code is as in N3.
- The plain comments at `src/watch.rs:1338` and `1344` say the same; they are outside the list you gave.

**N5. `observation.md:117-118`: "in such a halt nothing else is touched, by a round or by a line at the backdoor."**
- True of what is cut, and true of a line at the backdoor (`src/watch.rs:862-866`, `src/backdoor.rs:132`, `232`, `276`).
- Read as a statement about a round, it is too wide. A round in such a halt also writes the game's time to the three places (`src/watch.rs:1336`), puts a differing place right (`1334-1335`), tells the observers' threads the rounds go on (`1345-1347`), and begins the game again when asked (`1341-1343`).
- `README.md:232-234` says all of that; this sentence leaves it out.

**N6. `outside.md:36-37`: "The connection that has waited longest with nothing of its own being answered is put out for it."**
- False where every connection that is not a screen is being answered: then the one that has been answered longest is put out (`src/main.rs:117-118`).
- A screen is never put out for a connection (`src/main.rs:117`, the `!one.screen` filter).
- This is an old sentence that the change did not touch.

## Cannot be told from the folder

**C1. `checks.md:623-626`: "It ran 40,896 single faults and 9,000 pairs through this version and the one before."**
- The hand-back is not in my copy.
- The same entry says the program was changed after that check (the control character, the list of halted moths), and `README.md:537-538` says the program as it is here has not been read by a reviewer.
- So "this version" can only mean the version that check read, not the program in this folder.

**C2. `README.md:462` and `checks.md:319`: the tests take "about five minutes".**
- I did not run the suite. Your brief gives about seven minutes on this machine.

## The changed lines that I ran

The test of the cutting down (`what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at`) passes unmodified; its longest round was 151 ms. I then took each cut out in turn, in a copy, to check `checks.md:268-274`. All six behaved as the document says.

| Cut taken out | Line in `src/watch.rs` | Result |
| --- | --- | --- |
| first cut at the start, of what is kept from the round before | 1332 | fails by time: 2.75 s here |
| second cut at the start | 1353 | passes |
| before the observers are asked | 1417 | fails: "something of that size is still held" |
| before the work | 1456 | passes; longest round 314 ms |
| before the work is checked | 998 | fails: "something of that size is still held" |
| before the record is written | 1035 | fails: "something of that size is still held" |

Seven other named tests pass unmodified:
- `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long`
- `the_second_text_of_the_rules_takes_nothing_from_the_first`
- `the_second_text_of_the_work_is_the_first_word_for_word`
- `the_second_text_of_the_rules_is_the_first_word_for_word`
- `the_eight_copies_of_the_rule_are_one_rule`
- `the_copies_are_apart_in_the_program_as_built`
- `nothing_is_written_in_a_halt_that_cannot_be_put_right`

## Counts

All agree with every place the documents give them.

| What | Count | How counted |
| --- | --- | --- |
| Tests in `src/watch.rs` | 84 | `#[test]` attributes; no other source file has one |
| Checks in `test/limits.js` | 55 | 41 call sites of `check(`; four sit in loops (5, 5, 5 and 3 passes), so 41 - 4 + 18 |
| Plans in `test/drive.js` | 11 | keys of `plans`; the names match `checks.md:362-363` |
| `src/game/again.rs` | 41 functions, 29 numbers | top-level `fn` without the mark `second`, and top-level `const`; the test asserts (41, 29, 41) |
| `src/rules/again.rs` | 9 functions, 16 numbers | same way; the test asserts (9, 16, 9), and 9 and 16 for `rules.rs` |
| `src/watch/looks.rs` | 8 rules | plus `all_apart`; `LOOKS` lists the eight |
| Kinds of change in `OWN_FAULTS` | 25 | the array's declared length, and its entries |
| Faults in the test of the eight copies | 120, of which 101 different | 90 (nine backdoor names by ten kinds) + 21 lines + 9 direct. Different: 80, since `spider.ring[3]` and `world.ring[3]` are one observer, + 12 lines that repeat none of the 90, + 9 |
| Large things in the test of the cutting down | 22 | the array's declared length; 7 in the state, 1 in the gate's copy, 2 in the record's texts, 3 places of the kept state, 6 in an observer, 3 lists |
| Ways a halt cannot be put right | 5 | every call of `stick` and `fail` falls under one of the five in `observation.md:337-354` |
| Reviews and checks | 4 + 21 = 25 | 10 of changes and 11 of documents in the list in `checks.md`; the eleven single faults add up from its entries |

## By document

- `README.md`: N1 only.
- `observation.md`: N1 and N5.
- `checks.md`: N1, N2, C1, C2.
- `backdoor.md`: N3.
- `outside.md`: N6.
- `gameplay.md`: no findings.
- Source comments in your list: N4 only. The others hold: the `//!` heads, and the `///` on `Book`, `Game`'s fields, `stopped`, `fail`, `right_counts`, `fit_kept`, `cut_down`, `counts_off`, `correct`, `restore`, `round_at`, `ruled`, `shown`, `Apart`, `clock`, `Own`, `run`, the head of `one()`, and the head of the page's script.
- `page.html`: what `gameplay.md`, the README's "Running it" and `backdoor.md` say the page shows and does is true of the page and of what `shown()` sends it.
- Every reference from one section or document to another by name leads to a section of that name.

## What I read, and what I did not reach

Read in full: all six documents, `documents.diff`, `src/backdoor.rs`, `src/main.rs`, `src/watch.rs` from its head to the start of the tests (lines 1-2097), `test/wiring.py`, and `page.html` from line 96 on (the markup and the whole script).

Read in part:
- The tests in `src/watch.rs`: only those the changed lines turn on, the two word-for-word tests, the test of the eight copies, `OWN_FAULTS`, and the declared sizes of the other fault lists. The older descriptions under "The tests" in `checks.md` were checked by those counts, not test by test.
- `src/game.rs`: lines 1-930. The spider's own work (930-1206) was not read, so the boost, walking and holding numbers in `gameplay.md` were checked against the constants only.
- `src/watch/looks.rs`: the head and the first copy, and the first and last copies compared line for line. The six between were not compared by me; the test that holds the eight together passes.
- `src/game/again.rs`, `src/rules/again.rs`, `src/rules.rs`: heads, function and constant lists, and the rule messages quoted in `backdoor.md`. The table of rules in `observation.md:295-304` was not checked rule by rule.
- `test/limits.js` and `test/drive.js`: heads, the check call sites, the plan names and the `again` relay. The list of limits in `checks.md:334-356` was matched against the call sites' wording, not their logic.
- The style sheet of `page.html`: only the layout rules.

Not done: the full suite, `test/limits.js`, `test/drive.js`, `test/wiring.py` and the program itself were not run. The measurements in `README.md:187-190`, the run in `gameplay.md:109-111`, the two trials and the picture were not checked beyond the code being able to produce them.

## What I left in the folder

- `«WORK»\check-twelve\docs\mut\`: a copy of the source with four test-only hooks after the cuts in `src/watch.rs` and one added test, `zz_edge_measured`, which made the N1 measurements. As it stands it holds the last set of cases (the longer texts and the web's torn strands).
- `now\` is as I was given it. I removed the two `target` folders my builds made.
- Nothing was read or written outside the folder, no program was started, and no process was stopped.
