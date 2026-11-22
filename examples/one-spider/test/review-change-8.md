# Independent check of `after/` and of the change from `before/`

All file and line references are into `«WORK»\check-nine\code\after\` (`src\watch.rs` unless another file is named).

## The plain answer first

- **A single fault recorded as true:** none found.
- **A single fault that loses the game:** none found.
- **A single fault that ends the program:** one kind found, and only at a size six to ten times what the change's own tests use. The number of moths made 1,000,000 between two rounds, or 500,000 inside a round, makes each round take longer than five seconds. The observers still listening then say the rounds have stopped, and the second to say so ends the program. I confirmed this in tests, with the ending counted and not done. I could not confirm it in the built program, because the backdoor cannot make that fault. At 100,000 moths it does not happen. The model as written puts no limit on a count, so I report it as inside the model. Details are under claim 7.
- **A sequence of faults that does any of the three:** none found, in 6,500 pairs and 300 pairs with a thread fault.
- "A round that never returns" ends the program by design (`main.rs` 276–310). I have not counted that.

## How I checked

I worked in throwaway copies under `...\code\work\`: `a` and `d` from `after/`, `b` from `before/`, `m` for mutants. `after/` and `before/` are untouched.

- The copies have test-only hooks at ten instants of a round: before the observers are asked, after they answer, before the work, after the taking in, between the world's and the spider's work, after the work, after the rules, after the second doing, before the record is written, and while it is written.
- `d` also has hooks at four places inside `world_work` and four inside `spider_work`.
- The copies have three more test-only calls to an observer's thread: answer late, end, and say that the rounds have stopped.
- Every fault ran beside untouched twins. Under "at once" the game had to be, round for round, where a twin is, allowing for rounds lost to the halt. Under the other two settings it had to go back to the state before the fault, or to one the twin was in.
- A strict reader of my own read everything a screen was sent in every round.
- The campaigns use the tests' entry `round(dt, now)`. Only the built program used `round_at`.

Totals on the copy of `after/`: 21,280 cases. No stop in the wrong place, no game lost, nothing a screen was sent that could not be read. 29 cases were flagged by my own harness and are explained under claim 7.

## 1. What a screen is sent has a size — holds

**The size.** Whatever the state holds, `shown()` writes no more than 8,357,919 characters, counted from the fields. A state I built to be the worst sent 8,330,472. Of the counted bound:

| Part of what is sent | Characters at most |
|---|---|
| The legs | 3,086,338 |
| The moths | 2,390,018 |
| The nine rows of observers | 1,412,221 |
| The catches | 1,345,538 |
| The list of observers | 73,730 |
| The six pieces | 26,458 |
| Everything else | 23,616 |

**What bounds each thing `shown()` writes (1490–1569):**

- **A number** is not cut. Written out it is at most 327 characters (for example -5e-324, written in full with no exponent, `backdoor.rs` 52). I found this by scanning three million bit patterns and the smallest numbers. A number that is not one is a text of at most 11 characters.
- **A text in a part** (`body.state`, `web.torn`) is cut to 1,024 characters and three dots (`game.rs` 143). That is at most 6,149 bytes, since a control character is written as six.
- **The list of halted moths** is cut the same way (1550).
- **An observer's row** has name, list and reason at 160 characters each, and at most 1,024 copies of 24 characters (172–178, 1496). The rows are nine places by index, never more.
- **Legs, moths, the list of observers, catches** are at most 1,024 entries each (1501, 1507, 1514, 1555). An entry of the list of observers is fixed words.
- **`calm`, `reach`, `stomach`, `rate`, `over`, the shelf** are each one to three numbers and fixed words (`game.rs` 530–552, 683, 516; `watch.rs` 1416–1426).
- **`halts`, `restarts`, `games`, `passed`, `unwritten`** are whole numbers of at most 20 digits.
- **`let`, `not`** are cut to 200 characters where they are kept (1279, 1316).
- **`halt`, `why`, `fixed`, `did`** are not cut where they are sent. They are bounded where they are made (claim 3). In all my runs a reason was at most 219 characters, and what was done at most 599.

**One fault, with the halt left to last on a click (run):**

| Fault | Characters sent at most |
|---|---|
| A text made three million control characters | 13,278 |
| The observers made 100,000 | 65,583 |
| 100,000 legs or moths, each a copy of the first | 154,471 and 158,305 |
| The `whole` observer given 100,000 copies (it is in both rows) | 311,242 |
| 100,000 catches with the longest numbers | 1,351,770 |
| 100,000 moths with the longest numbers | 2,394,721 |
| 100,000 legs with the longest numbers | 3,090,279 |

The last three exceed the 400,000 the new test allows (3082–3086). They do so only if the entries a count fault adds hold numbers written 327 characters long. Whether that is one fault depends on what the model lets the new entries hold.

**For as long as the halt lasts.** Nine faults were each held for 3,000 rounds, with observers together and on threads. What was sent did not grow.

**The other side — holds as run.** Three games with nothing wrong were played with a pointer, a shop, clicks on moths in the web and the spider picked up, for 280,000 rounds in all. The fold of every round's text is the same in `before/` and `after/`, and the output files are identical. The most seen in those games: 124 characters of torn strands, 19 of halted moths, 16 moths, 5 catches.

Argued only: a game played for many hours with about eighty "More moths" bought and few appetites could hold more than 1,024 characters of halted moths. The page would then draw some halted moths with beating wings (`page.html` 198, 280). Nothing else in an ordinary game comes near 1,024.

## 2. Writing a part out is unchanged — holds

- **`written()` is the same.** For nine kinds of piece, every field was set to 30 hard numbers or 68 hard texts (quotes, backslashes, control characters, characters of two to four bytes, empty, lengths around 1,024) or both truths, on three games. With the seven parts, the gate's copies, every observer, and 20,000 rounds of several fields changed by chance, the two versions wrote two identical files of 3,577,345 bytes. By reading: `sent(usize::MAX)` takes the same arm as before (`game.rs` 142–146).
- **`sent(most)` cuts only texts, between characters, and stays readable.** I checked 33,576 writings, 4,926 of them cut, at six places to cut. Each cut text is exactly `short()` of the original. Numbers written as texts are not cut. Every result reads strictly. The cut is made before quoting, so it cannot fall inside an escape.
- **The suite does not pin this.** Moving the cut to after the quoting, or cutting by bytes with no dots, both pass `what_a_screen_is_sent_has_a_size...`, `a_text_is_cut_between...`, `a_number_that_is_not_one...` and `what_a_screen_is_sent` (run).

## 3. An answer is cut once, and nothing else reaches a reason uncut — holds

- **An answer** from a thread is taken only in `Apart::look` and cut there to 200 characters and dots (1817). Both askings go through it (678, 1007).
- **An observer's `why`** is that answer (691), the same rule's own words run together (at most about 95 characters), or the spread reason (721).
- **A halt's reason** comes from one of:
  - `watch()`, which cuts again to the same text (707);
  - fixed words with names of parts and observers (`differs` 737–760, `observers_off` 762–794, `record_now` 869–890, the rules' fixed texts, `redone` 930–931);
  - `stick()` with a `restore` error (978, 1090, 1348), with an answer already cut (1019–1022), or with "twice running" before a `record_now` reason (1347).
  
  The longest is about 255 characters of the program's own words, or 27 and 203 of an answer.
- **`fixed`** is a list of fixed phrases (1025).
- **`let_through`, `not_written`** are cut at 200.
- **Taking back the cut** at 1817, or cutting only at the first asking, fails `a_finding_of_any_length...` (run).
- **Together and on threads.** 1,200 faults were each run both ways under the three settings. Halts, reasons, what was done and the fold of everything sent were the same in all 1,200. The same holds in `before/`.

## 4. The gate's recording heeds each text of the rules

- **The code — holds.** `first.or(second)` at 880; the copy of the round before is asked of both at 876.
- **The test — fails in part.** I made 35 mutants of `record_now` and `ruled` and ran the test on each. It catches these:
  - the gate heeding only the first, only the second, neither, or only both together;
  - the second text handed the first's whole account or its upgrades;
  - the second taking the first or third list;
  - the second using the first text's `take_in`, `in_web`, `wrong_in` or `wrong_step`;
  - either text's look at the state or the step not asked or not heeded;
  - the two answers swapped.
- **Seven mutants pass it.** They also pass 14 further tests chosen by name (pointer, clicks, shop, wrong steps, what is asked):
  1. The second text handed the first's count of clicks.
  2. The second text handed the first's `next_moth`.
  3. The second text handed the first's `held`.
  4. The second's `held` worked out by the first text's `in_hand` (`own.held()`).
  5. The gate's own copy of the round before asked of the second text only.
  6. The second text's answer about that copy asked and dropped.
  7. The first text's answer about that copy asked and dropped.

So the test does not fail "if the second text is handed anything of the first's": it does for one of the four things in the account. And it does not fail "if either is not asked" about the gate's own copy.

## 5. The reason of a halt names what went wrong — holds for the three counts named, with exceptions

I ran 30 faults at 11 instants under the 3 settings. All were found once and put right, or written over.

**Holds:**
- **Texts of the record.** Named by the gate before its comparing and before the observers look. After the work the reason is now "its own record no longer had one text for each part while the round was being worked". After the gate's last look the fault is written over.
- **Number of observers.** Named by the gate, except as below.
- **An observer's copies.** The observer is named, in "has been changed", "copy of ... differs" or "the copies of ... changed".

**Where it still does not:**
- **Observers, before they look.** The reason is "the legs A observer found that there were no longer eight observers and seven parts". It does not say which of the two.
- **Observers, after the gate's look and before the work,** when the moths observer's place is lost or moved (one gone from the middle, none, three left). The reason is "a step of the work that the rules of the game do not allow: a moth halted in the web that moved". The work read the halted list from the wrong place (1294).
- **Legs, from after the gate's look to after the work.** The reason is "...a foot further from the body than a leg can reach", for the state and for the gate's copy. `rules.rs` 139–140 gives one message for both.
- **Moths in the gate's copy, one too few, after the gate's look.** The reason is "a step of the work...: a moth coming before one was due". After the second doing it is "the list of halted moths of the moths observer changed".
- **First list of what was asked, one too many, before the taking in.** The reason is "...an upgrade bought that was not asked for".
- **Not a count, but the neighbour of change 3.** A text of the record that changes or is emptied after the work is still said to be "the copies of the legs A observer changed" (783–785).

Each misnamed case that blames the work also counts toward "twice running" (1341–1351).

## 6. Nothing put right before is lost — holds

- **Tests.** 80 tests became 81. No assertion was changed or removed; four blocks were added. The diff I recomputed is the one given.
- **Taking back each piece.** I took back twelve pieces of the change one at a time. The three tests there for them caught ten. The two that passed are the cuts named under claim 2.
- **The same faults through both versions.** 9,500 single faults and 6,500 pairs (one fault per halt, one to three rounds worked between), over 25 kinds of fault, four games, three settings and eleven instants:

| Outcome, `after/` against `before/` | Cases |
|---|---|
| The same in every respect | 15,088 |
| The same but `after/` sent less (all counts or long texts) | 460 |
| The same but for the reason of change 3 | 452 |
| Anything else | 0 |

- **Bad outcomes:** none in either version.
- **Thread faults.** 360 run on both versions gave identical lines.

## 7. The whole claim, where it has been reached least

- **Threads.** 360 single thread faults and 300 pairs, all found, none bad. Counted across both: stops answering 81, answers three million characters 73, answers a finding that is not there 70, answers late 70, ends 81, says the rounds have stopped 69, one place of what the threads are run by 140, one place of the hold on them 136.
- **`rounds_stopped`.** I copied its counting into a test with the ending counted. One observer saying so alone does not end the program under any setting. A later one of the next eight does not either. A thread that ends, an answer a second and a half late, and a game put aside whole do not. When the rounds do stop, all eight say so.
- **Part-way through the work.** 2,880 cases at the eight places. In 266 the place was not reached, because a carried spider's work returns early. In 29 the fault fired 43 rounds later, was found in that round, and my harness stopped there without watching the putting right. The other 2,585 were all found or harmless.
- **Debug build.** 360 singles, 180 pairs and 30,000 rounds left alone: no stop. The thread tests and the faults inside the work were not run in debug.

**Counterexample, run in tests with `Apart::start` and the program's rule counted.**

- **Situation.** A game running, each observer on a thread, halts set to end after a pause (the default).
- **Fault.** Between two rounds the moths become 1,000,000, each a copy of the first.
- **The first round after it took 8.9 seconds.**
  - `look()` writes every moth out (659–661, 618–620, 218) and the eight are asked.
  - The five world observers must copy or fingerprint about 140 MB (235) and miss the 40 ms. The reason is "the whole observer did not answer in time", and they are not asked again.
  - `differs()` writes the moths out again (748), and `mend()` a third time (1128).
  - The three observers still listening hear nothing for five seconds and each says the rounds have stopped (1907–1912). The second is where `main.rs` 309 ends the program. Three said so, in that first round, 8.9 seconds after the fault.
- **On a click.** Six said so, in the second round after the fault, 8.2 seconds after it.
- **At once.** It did not happen at this size: the round took 7.0 seconds, and the eight were replaced just in time.
- **Landing inside a round, after the gate's look and before the work (my hook).** 500,000 is enough under "after a pause" and "on a click", and 700,000 under all three. Each later round also writes the kept state out three times (474).
- **Sizes where it did not happen.** At 100,000 to 400,000 between rounds it did not happen; rounds took 0.2 to 2.6 seconds. At 600,000 it happened in one run and not in another.
- **Other lists.** The catches kept are written out whole each round too, so I expect the same of them. That is argued only.

## 8. The program as it runs, and its page — holds as run

- **The built program.** Built from the untouched `after/`, on port 8190, driven for about a minute. Four connections kept open sent about 2,750 requests each; two screens read the stream.
  - 28 faults at the backdoor under each setting, 84 in all. They covered every part, observers' fields and copies, texts of 1,024 control characters, numbers that are not numbers, and two lines written during the work.
  - Each was found once and put right as the setting says: halts 84, restarts 84, no halt of its own making.
  - 3,403 messages per screen, all readable, the largest 13,380 bytes.
  - Six ill-made requests were answered 404, 403, 400 or closed.
- **The page.** By reading: the read, the draw and the show are each inside a catch (`page.html` 189, 400–404). Lists are indexed with guards. A cut `halted` or `torn` can only make a moth or strand be drawn as not halted or not torn.
- **The page's script, run.** I ran it under Node with stand-ins for its elements and canvas, not in a browser, on 110 cases: every cut text, 1,024 legs, moths, observers, copies and catches, no legs, no observers, numbers that are not numbers, a game put aside. It stopped nowhere. 1,024 legs make the state panel build about 23,000 elements, once.

## What I could not check, and why

- **The whole suite:** the brief forbids it. I ran named tests only.
- **A real browser.**
- **Long or many values in the built program:** the backdoor takes texts of 1,024 characters and 64 moths. Those sizes, and the counterexample, are from tests.
- **Faults inside the loops of the work:** only the eight places between its steps.
- **An answer that claims another observer's place or round:** no hook reaches a thread's own values. By reading, one such fault leaves its own place silent and halts.
- **Change 2 at the second asking beside twins:** it needs two faults in one halt. I relied on the changed test, and on its failing when the cut is taken back.

## Noticed outside the claims

- The brief lists "two older tests expect the words 'the gate's counts put right'". That is not in the difference. Both versions have the same ten such lines.
- `fixed` and `did` are sent whole, and a halt's list of things already put right has no limit. Outside the model, an observer removed in each of 2,000 rounds of one halt gave 2,001 entries and 121,667 characters sent afterwards.
- At 100,000 moths a halted round takes 0.2 to 0.9 seconds with the game held, so requests wait.
- `Observer` keeps the trait's own `sent()`, which leaves out the copies that its `written()` has. Nothing calls it.
- `page.html` makes the observers' buttons once (585–593). A first message with 1,024 or with no observers leaves that many until the page is loaded again.
- None of my processes is left. The three programs I started (process ids 18424, 15528, 31224) were stopped by id, and nothing listens on 8190 to 8195.
- Scripts and results are in `...\code\work\scripts\` and `...\code\work\out\`.
