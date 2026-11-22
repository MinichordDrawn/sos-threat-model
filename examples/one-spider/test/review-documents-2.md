# Check of the six documents against the program

Folder checked: `«WORK»\verify-docs-2\`. Line numbers are those of the files as I received them. "Ran" means I ran it; everything else is from reading.

**In short.** I found no claim in `README.md` that is wrong outright. Fifteen are true only in a narrower form, and two of those matter: what "one fault for each halt" leaves out (N1), and what "at once" does with a round the gate refuses (N2). In the companions, one sentence of `checks.md` is wrong, one count in it is wrong, and about twenty claims across the five files are narrowed. Every number, name, file, command and usage line I could check agrees with the program. `README.md` has 26,328 characters.

This check ran on Claude Fable 5.2, the model the README says the program was written with, so the README's "One model" caveat applies to it too.

---

## 1. README.md

### Wrong

None found.

### Narrowed

**N1. Lines 38-39; the same at 241 and 252-253.** "What is held is one fault for each halt. A second fault that lands before the first has been put right is outside it".
- The count of wrong rounds goes back to nothing only when a round is recorded (`watch.rs:833`). Putting right does not touch it (`watch.rs:642-668`), and at two the game cannot go on (`watch.rs:846-856`).
- So two faults, each alone in its round and each with a halt of its own, in two rounds worked running, stop the game, though the first was put right before the second landed.
- Ran, under "at once" and "on a click": first fault found and put right, second fault in the next round worked, then "twice running, the gate did the work of the round a second time ...", and the game could not go on. `review-change.md:49` ran the same.
- `observation.md` 264-267 and `checks.md` 270-272 say this. The README says it only as step 6 of "One round" (line 196), and its statement of what is held does not leave it out.
- Put: "What is held is one fault for each halt, with a round recorded before the next fault lands in the work. A second fault that lands before the first has been put right is outside it. So is one that lands in the first round worked after a round that went wrong: two wrong rounds running stop the game, whatever made each. And so is everything under "Scope and limits"." At 252-253: "And a second fault before the first has been put right, or in the first round worked after a round that went wrong."

**N2. Line 227 (the same words at `observation.md` 209).** "at once | The change is put right in the round it is found. Nothing pauses, and no round of the game is lost."
- True of what is found before the work (step 3; `watch.rs:801-807`).
- What the gate finds after the work (steps 5-6) leaves the game halted to the end of that round (`watch.rs:831-845`). It is put right at the start of the next round, and the round that went wrong is undone and lost.
- The test at `watch.rs:2161-2164` asserts the game is still halted after that round under all three settings.
- Ran live: `during world.tally.caught += 5` under "at once" gave one frame with halts 10 and restarts 9, and the next with restarts 10.
- Ran as a probe: one fault in one round's work under "at once" left the game one round behind an untouched game, and still one round behind ten seconds on (age 50.0167 against 50.0333).
- Put: "A change found before the work is put right in the round it is found: nothing pauses, and no round of the game is lost. A round the gate refuses is put right at the start of the next round, and that one round is lost."

**N3. Line 196.** "If that happens two rounds running, the game cannot go on."
- A round with a line kept at the backdoor in it is not counted (`watch.rs:846-848`, counted only `if inside.is_empty()`). It does not set the count back either.
- Ran: a fault of the work's own (count 1), then in the next round worked a kept line that breaks a rule: halted, count still 1, put right, game goes on.
- Put: "If that happens two rounds running, not counting a round that a line kept at the backdoor made wrong, the game cannot go on."

**N4. Lines 30-31.** "A fault between two rounds is found before any work is done."
- Not a fault in one of the two lists that the next asking writes over or cancels (`watch.rs:874-886`). Nothing is left of it and nothing is found.
- Ran: with four of the pointer's places waiting, the last changed in the second list, then one more place: the lists are the same again, no halt. A letting go nobody made in one list, then a real one: the same, no halt. `review-math-2.md:57-65` has three such patterns.
- Put: "A fault between two rounds is found before any work is done, unless what is asked next writes over it in its list, and then nothing is left of it."

**N5. Lines 41-42.** "Earlier versions were reviewed, each review found a case where it failed".
- True of the two reviews of the single-fault claims. `review-outside-2.md:5` found none ("No write or request I tried got a change into the game's recorded state without a halt. No write survived a halt either"). README line 377 has the narrower form.
- Put: "each review of the single-fault claims found a case where it failed".

**N6. Lines 347-348.** "Each test says what must be found, by whom, and where the game must be afterwards."
- The tests of the gate's record, the seventh part, the two lists and the wrong steps assert the reason, which names who found it (`watch.rs:2459, 1878, 1998`).
- The every-field tests, which are most of the cases, assert a halt in the next round and an exact putting back, and not who found it or why (`watch.rs:1120-1186`).
- Put: "Each test says where the game must be afterwards, and the tests of single faults also say what must be found and by whom."

**N7. Lines 297 and 366.** "checks.md: every test and check"; "lists every test and check".
- `checks.md` describes 46 of the 48 tests. `what_a_screen_is_sent` (`watch.rs:2367`) and `the_backdoor_reads_what_it_writes` (`watch.rs:2432`) are not in it.
- Put: add the two to `checks.md`, or say "the tests and checks".

**N8. Lines 263-264.** "In this program an observer is a name and a place in a list, and one rule serves them all".
- An observer is a number with a name in `NAMES` and a place in four more lists: a ring's `who`, `START`, and `SPIDER_RING` or `WORLD_RING` for the backdoor (`watch.rs:48, 56, 62, 64-65`).
- Two kinds are told apart by number: the coordinators, which keep fingerprints (`COORD`, `watch.rs:58, 205-210, 376`), and the `moths` observer, which keeps the list of halted moths (`MOTHS`, `watch.rs:60, 337, 355, 394, 627`).
- One function, `rule` (`watch.rs:366-399`), does serve all eight. "Eight" is also written into array lengths and one message (`watch.rs:48, 62, 659`).
- Put: "an observer is a name and a place in a few lists, and one rule serves them all, with the two coordinators and the `moths` observer told apart inside it".

**N9. Lines 17-18 and 48-49.** "Whatever is written there is found before the next round's work, everything halts, and it is put back."
- Not a line kept with `during` that changes nothing by the time it is written: that round is recorded and the line is said to have been let through (`watch.rs:793-800, 834`; `backdoor.md` 104-107). Nor one that cannot be written when its time comes (`watch.rs:826-830`).
- Put: "Whatever is written there that changes anything is found ...".

**N10. Lines 94-95.** "The gate's record is written only from the second doing, once the two agree."
- True when a round is recorded (`watch.rs:620-636`). When a halt ends, a half that has gone wrong is put right from the state or from the other half (`watch.rs:699, 701, 709, 719`), as lines 208-212 say.
- Put: "When a round is recorded, the gate's record is written only from the second doing, once the two agree."

**N11. Lines 102-103.** "around the whole of its state".
- The game's state, the observers, the gate's record and the two lists. Not the gate's own bookkeeping, which line 251 names as left unchecked, nor the state kept from when a round began, nor the web plans.
- Put: "around its game's state, its observers and its record".

**N12. Line 68 (table, third column).** "Stopping is what happens when nothing says go."
- True of the observers' signals: one whose signal is not this round's stops everything (`watch.rs:448-450`). The gate gives no go of its own: the work begins unless `differs()` returns something (`watch.rs:780-791`).
- Put: "Every observer has to signal in every round, and one that has not stops everything."

**N13. Line 71 (table, third column).** "It is put aside whole and begun again."
- Only when "Put it right" is clicked (`watch.rs:769-775, 954-961`). Until then the old game stays, partly put back (`observation.md` 230-232).
- Put: "It stays halted, and a click on "Put it right" puts it aside whole and begins it again."

**N14. Line 228.** "Everything stays halted until the state has been left alone for 0.6 seconds."
- Or until it is asked for: asking ends a halt under any setting (`watch.rs:736, 746`; test at `watch.rs:1579-1585`). The page shows the button only under "on a click" or in a halt that cannot be put right (`page.html:380-381`), so from the page it is as written.
- Put: add "or it is asked for".

**N15. Line 116.** "It eats the old one and is the quicker for it."
- Quicker by a hundredth for each moth the old one had eaten, so not at all if it had eaten none (`game.rs:1095`). Put: "and is the quicker for each moth that one had eaten".

### "One round": the order, and what is left out

The six steps are in the order of `Game::round()`: `watch.rs:769-776, 777-778, 780-791, 801-807, 810, 812-816, 825-830, 831` with `561-589`, then `620-636` or `845-856`.

Left out, of things that matter:

- **The one thing the work reads from an observer.** The work is given the `moths` observer's list of halted moths (`watch.rs:808, 815`). That observer writes it when the round is recorded (627-628), the others of the world's ring check it in step 1 (394), and the second doing works its own out from the record (602). The README never mentions the list. `observation.md` 77-80 does.
- **Two checks in step 5.** Every number a real one (562), and the gate's own copy of the round before held to the rules first (567). `observation.md` 157-161 has both.
- **Step 6.** N3; and on the second wrong round the state is put back at once and no observer is started again (851-855).
- **Steps 3 and 6 under "at once".** N2.
- **Line 198, "nothing else is done".** While a halt lasts the gate does not look (780), and a letting go and the pointer's last place are still taken down (870-889).
- **Step 1.** Each observer first checks its own last signal (408-410); `observation.md` 72-75.

### The particular questions, verdicts only

- **"The result".** Every sentence agrees with the code but for N1, N4 and N5. I found nothing else in `round`, `record_now`, `write_record` or `restore` against it, for the four kinds of fault at the instants the tests use. I placed no faults at other instants.
- **"How safe the spider is".** The three conditions hold. "There is no fourth condition" holds within the result as N1 narrows it: the case in N1 ends in the second condition. Third column: three confirmed, two narrowed (N12, N13).
- **Fourth column of the eight properties.** All eight confirmed.
- **"The observers and the parts", "The gate".** Confirmed. **"How a halt ends".** N2 and N14, the rest confirmed.
- **"Every part is held in full by three observers here, and twice more by the gate".** Confirmed (`watch.rs:56-58, 205-214, 221-226`). **"an observer is a name and a place in a list".** N8.
- **"Scope and limits", "Raising the scope".** Every sentence about what is in the program now is confirmed, but for N1 and N8.
- **"What is here".** Every entry exists and is as described, and every file in the folder is listed.
- **"Running it", the five lines.** Ran each on port 8186:

  | Line | What the program said | As the README says |
  | --- | --- | --- |
  | `spider.body.x += 150` | "the legs A observer found the body changed"; "the body put back, all eight observers started again" | yes |
  | `spider.ring[0].alive = false` | "the legs A observer is silent" | yes |
  | `world.tally.gained = 1000000` | "the whole observer found the moths, counts and shop changed"; put back; with `spider` asked for twice meanwhile, nothing bought | yes |
  | `during world.tally.caught += 5` | "the gate found a step of the work that the rules of the game do not allow: the moths caught not the moths the spider ate and the pointer picked"; count unchanged after | yes |
  | `during spider.body.until += 5` | "the gate did the work of the round a second time, from its own record, and it came out another way in the body"; value unchanged after | yes |

- **Counts.** 48 tests (`cargo test -- --list`, all in `watch.rs`). 52 checks in `test/limits.js`. Eleven plans in `test/drive.js`. "Some sixty wrong steps": 54 that break a rule and 11 that break none.

---

## 2. Where README.md and a companion differ

1. **README 383-384 against `observation.md` 288-289.** README: "two reviews also put faults into the bookkeeping". Companion: "The review of these claims put faults into several of them". The files support two (`review-math.md:182`, `review-math-2.md:31, 268`).
2. **README 38-39 and 252-253 against `observation.md` 264-267 and `checks.md` 270-272.** The companions say that two wrong rounds running, each by a fault of its own, stop the game. The README's statement of what is held does not (N1).
3. **README 41-42 against README 377 and `checks.md` 234-235, 251-252.** "each review found a case where it failed" against "It found no way to get a change recorded" (N5).
4. **README 345-346 against `checks.md` 109, 115 and `observation.md` 269-270.** README: "after a round's work and before the gate checks it". Companions: "while a round is being worked". The README is the exact one: the tests put the fault at that one instant (`watch.rs:817-820`).
5. **README 356-358 against `checks.md` 219-221, 262-263.** README says "Each reviewer was given the code, the README as it then was and the claims to check" after naming all six. `checks.md` says that of the four reviews, and says the check of the change was given the program before and after.
6. **README 297 and 366 against `checks.md`.** N7.
7. **README 155-157 against README 203-218 and `observation.md` 180-181.** In one the thing the program calls the gate "is its own record of the state". In the others the gate also takes down what is asked twice, holds the work to the rules and does it a second time.
8. **README 251-253 against `observation.md` 255-315.** "Inward" names three things and the second fault. "What is not observed" has more that are inward: the shape of the state (309-312), what a screen is sent (294-295), whether the work as written is the right game (296-301). A summary, not a contradiction.
9. **README 350 and `checks.md` 169 against `test/limits.js:3`.** "a few minutes" against the script's own "about two minutes".

Tables, numbers and wording that the README shares with a companion otherwise agree.

---

## 3. The companion files

### observation.md

Wrong: none found.

Narrowed:

- **170-171 and 220.** "the work goes wrong twice running". Not counting a round made wrong by a kept line (N3; ran).
- **196-200.** "one of those numbers that is changed has to be changed in both places, and until it is, the game halts."
  - True of numbers a rule holds exactly. Where a rule is only a bound, the work's number can be changed on the near side of it with no halt.
  - Ran, in a throwaway copy: the walk's 5.5 made 5.0, a fleeing moth's 3.4 made 3.0 and the taking down of a web 50 made 40, in `game.rs` alone (`game.rs:944, 780, 732`; held at `rules.rs:394, 211, 299`). `left_alone_for_half_an_hour_it_never_halts` passed.
  - Put: "So one of those numbers that a rule holds the work to exactly has to be changed in both places, and until it is, the game halts. Where a rule is only a bound, the work's number can be changed on the near side of it and nothing halts."
- **209.** The "at once" row: N2.
- **258-259.** "Set to end "at once", a halt lasts no longer than the round it is found in". A halt from the gate's checks on the work lasts to the start of the next round (N2; ran).
- **257-267.** The bullet is headed "More than one fault before the first has been put right" and opens "What is held is one fault for each halt". Its own last three sentences are cases where the first has been put right (N1).
- **288-289.** "The review of these claims": two reviews did.
- **283-287.** The list of the gate's bookkeeping leaves out what was put back, kept to be said (`watch.rs:252, 667`), since when it has been calm (255), and the pause's own timer (232-233). Minor.
- **297-299.** "Anything that happens during a round to what only one doing reads makes the two doings disagree". Unless it makes no difference: a value the work writes over, or a list already taken in. Minor.

### backdoor.md

Wrong: none found.

Narrowed:

- **101-102.** "When it is not, a rule names it: the web grown with no spider at work on it."
  - That is the rule named when a web is in the making and the spider is away from it or has let the thread go (`rules.rs:311-313`).
  - With the web finished, or with no web, the rule named is "a web that cannot be" (`rules.rs:157-161`). Ran with a finished web: "the gate found a step of the work that the rules of the game do not allow: a web that cannot be". With an old web it is "an old web that grew ..." (`rules.rs:295-296`).
  - Put: "When it is not, a rule names it: the web grown with no spider at work on it, or, where the web is finished or there is none, a web that cannot be."
- **15.** "or everything": `world` and `spider` each read one half. No line reads everything. Minor.

### outside.md

Wrong: none found. Fourteen requests ran as it says, on host, origin, site and headers.

Narrowed:

- **52-54.** "The one refusal that is not heard out is the one given while 256 are held." There is a second: the refusal given when no place can be made (`main.rs:311-316`) is read from once, for a twentieth of a second, before it is answered, and not heard out after. It is hardly reachable. Minor.
- **13-31.** The table has no rows for what is asked and waits (eight presses, eight upgrades, four of the pointer's places) or for the 24 characters of a copy. Those are in `observation.md` 64-65 and 120-123. Minor.

### checks.md

Wrong:

- **61-62.** "Where it says below that something is tried under each way a halt can end, the test asks for the halt to end under the two settings that wait. Only a few wait the pause out."
  - Five places below say "under each way". Three of them wait the pause out: the wrong step under each way (`watch.rs:2165`), the fault in what the gate wrote out (`watch.rs:2622-2623`, which is 168 of the cases), and an observer's reason with no flag (`watch.rs:2754-2757`).
  - Two ask under both: the gate's copy of the moths emptied (`watch.rs:2514`) and the fault in the gate's copy while a round is worked (`watch.rs:2551`).
  - Put: "Where it says below that something is tried under each way a halt can end, three of the tests wait the pause out. The two on the gate's copy of a part ask for the halt to end under both settings that wait."

Narrowed:

- **3.** "Every test and check there is": N7.
- **36-38.** "In each, in the round of the death there must be the old spider where it died". For the spider that starves the test asserts that the old one is there, not where (`watch.rs:1668-1669`). Its place is held only by the rules being on.
- **67-70.** "with the rule it breaks given as the reason". For seven of the lines the test pins one word, "moth" or "web" (`watch.rs:1901, 1902, 1905, 1906, 1914, 1915, 1918`).
- **109 and 115.** "while a round is being worked": one instant, after the work and before the gate checks it (`watch.rs:817-820`).
- **112-113.** "The same with an upgrade written into the second list". Under the starting setting only, and what is asserted is that nothing is bought and both lists are put aside (`watch.rs:2571-2577`).
- **172-174.** Only the stream is asked for from another port of this machine and with another origin alone. The page is asked for from another site and under another name, the plans from another site (`limits.js:73-86`).
- **176-178.** "an answer cut at 64,000 characters": bytes (`backdoor.rs:170`), as `backdoor.md` 32 and `outside.md` 25 say. "every text made as long as it may be": eight texts (`limits.js:109`), as line 132 says of the test.
- **200.** "The `lives` plan waits five minutes for a spider to grow old." It waits until the spider dies, at five minutes or sooner if it starves (`drive.js:350-352`). Minor.
- **196-197.** The plan's verdict also counts console warnings (`drive.js:28-29`). Minor.

### gameplay.md

Wrong: none found. The run in 102-104 is exact: ran, 459 caught, 128,894 hundredths gained, 57 bought, spider no. 7.

Narrowed:

- **96-100.** "One of those changed in one place and not the other halts the game." As `observation.md` 196-200 above. Put: "One of those that a rule holds exactly, changed in one place and not the other, halts the game."

---

## 4. What the documents say each review and check found

- **`review-math.md`.** Matches: four cases, each run; the four things it found sound; the three cases of a second fault; the ninth leg; faults put into the bookkeeping. One note: `observation.md` 261-262 says "the gate's text of that part". The review says only "one change to a record text" (line 178). By the code it has to be that part.
- **`review-outside.md`.** Matches, with one narrowing at `checks.md` 238-240. The review's "Three writes are not found" (line 9) are the write to a signal (finding 6) and the two writes of finding 7, an observer's copies and the `moths` observer's list written during the work. The kept line that outlived its halt (finding 8) was found when it was written: "It was caught, so nothing was kept" (line 130). Put: "It also found two kinds of write that were not found, neither of which kept a change: a write to an observer's signal, and a write to an observer during the work. And it found that a kept line outlived its halt."
- **`review-math-2.md`.** Matches: nine of ten, the one failure, some 50,000 single faults, twelve instants, 640,000 rounds, 2.70. Of the nine that held, one holds "inside the fault model" (line 15) and one "with two corrections to the claim as worded" (line 18). The documents give the substance of the first (`observation.md` 305-308) and not of the second.
- **`review-outside-2.md`.** Matches: no change recorded, ten findings, the ones named.
- **`review-change.md`.** Matches (fourteen of seventeen, 17,136, the error output, the number that is not one, the refusals, the one thing left), but for `checks.md` 268-269: "the new tests were weaker than they looked in four places. Those are closed".
  - The review lists seven weak spots (lines 153-159).
  - Four are closed by tests that are here: the observer condition of the new branch, text of many bytes, the pause not waited out, and the fourth test's one setting and four observers.
  - Three stand as the review found them. Under "at once" the first test compares the state with nothing (`watch.rs:2633-2638`). It pins a reason that names an observer for a fault in the gate's record (`watch.rs:2618`). The third test puts its line straight into what is waiting, not through the backdoor (`watch.rs:2716`).
  - Put: "in seven places. Four are closed, and the tests added. Three are as it found them."
- **`review-documents.md`.** "some 680 claims", "4 wrong and 35 true only in a narrower form" match (lines 3, 264-267). "each has been corrected" (`checks.md` 274): the four wrong ones are. Of the 35, four have something left in `checks.md`:
  - N25: the spider that starves, line 36-38 above.
  - N28: lines 61-62, which are now wrong the other way about, and the second list at 112-113.
  - N29 and N33: lines 176-178 above.
- **Not checkable from the files:** which model each ran on, "less capable", "word for word", which version each read.

---

## 5. Internal references

- Every section named in quotes exists where the sentence says. In the README: "Scope and limits", "What is established", "How a halt ends". In `observation.md`: "Checking the work", "How a halt ends". In `backdoor.md`: "Making the work go wrong". Named with their file: "How a halt ends", "Checking the work" and "What is not observed", all in `observation.md`.
- Every link between the documents points at a file that exists.
- Every file, plan, field, button, message and command named exists as named. The three transcripts in `backdoor.md` match the program's words; the third ran word for word.
- The usage lines match the scripts: `node test/limits.js <the program> <a port>` (`limits.js:2, 6`), the five arguments of `test/drive.js` in that order (`drive.js:3, 8`), `python test/wiring.py ../../model-check 1 2 3 4` (`wiring.py:1-2`).
- One mismatch, script against documents: `limits.js:3` says "about two minutes".

---

## 6. What does not belong

- **Another version of the game.** Nothing in the six documents, the sources, the page or the scripts compares this program with another version of the same game or names one.
- **"door" for the backdoor.** Only at `checks.md` 223, in the sentence you named.
- **An earlier state that is not here.**
  - `checks.md` 274-275: "The documents were laid out again after it, into this one and its companions."
  - `checks.md` 221, 242-243, 262-263; README 41, 357, 377: the versions the reviews read. These read as the history of the reviews.
  - `test/wiring.py:4`: "The game's wiring as it is now".
  - `observation.md` 270: "nothing that can be typed here", which reads as if the sentence sat at the backdoor.
- **Said twice in two ways.**
  - `checks.md` 139-140 and 146-147: the same test of an observer's reason with no flag.
  - README 41-42 and 377-378 (N5).
  - README 155-157 and 203-218: what the gate is (section 2, item 7).
  - README 120-123 and 241: "The scope is the program" and "The scope is one program on one machine, and one fault at a time".
  - README 133, 147 and 246-247: that only the person sees the program stop, three times.
  - README 41, 77-78 and 388: tested and not proved, three times.

---

## 7. Size

`README.md` has 26,328 characters: 26,328 bytes, all ASCII, 399 lines, line feeds only. It is under 40,000.

---

## Counts

My own units: a sentence or a table cell, split where it holds more than one claim. The totals are approximate.

| Document | Checked | Confirmed | Narrowed | Wrong | Not checkable |
| --- | --- | --- | --- | --- | --- |
| `README.md` | about 430 | about 318 | 19 places (15 findings) | 0 | about 93 |
| `observation.md` | about 300 | about 285 | 9 | 0 | about 6 |
| `backdoor.md` | about 95 | about 93 | 2 | 0 | 0 |
| `outside.md` | about 60 | about 54 | 2 | 0 | about 4 |
| `checks.md` | about 260 | about 220 | 12 | 2 | about 26 |
| `gameplay.md` | about 105 | about 104 | 1 | 0 | 0 |

The README's "not checkable": the first three columns of the eight properties; everything about the kit, the model, the model check, Theorem S and the Chernobyl example; what could be built in "Raising the scope"; the other systems; the models and provenance of the reviews; the timings; "all pass".

---

## Not checked, and why

- **The repository.** Not in the folder. `test/wiring.py` needs `../../model-check`, so I did not run it. I checked only that it writes down the eight observers, seven parts and two rings of `watch.rs:48-58`.
- **`test/limits.js` and `test/drive.js`.** Not run, as told. So not whether the 52 checks and the eleven plans pass, nor how long they take.
- **The full suite.** Not run, as told. I ran 13 of the 48 tests by name and all passed; the other 35 I did not run. "About four minutes" is not checked.
- **The page in a browser.** Read only.
- **The reviews' provenance.** The files do not say which model, "less capable", "word for word", or which version each read.
- **"Built with Rust 1.98".** It built with rustc 1.98.1. Nothing in the folder pins a version.
- **The universal claims.** "Never recorded" and "no single fault": read and probed, not proved. I placed faults only at the instants the tests' own hooks give.
- **The waits and the limits on sockets.** From the numbers in `main.rs`, not timed.
- **The other systems.** No web. From what I know, one is misstated: README 93-94, "A replicated state machine ... records a step only when enough replicas have computed the same step." The usual kind (Paxos, Raft) agrees on the order of the commands before they are worked, and does not compare what replicas computed. It is right of the Byzantine kind and of ledgers whose members work a block again before they accept it. I am about three parts in four sure. Put: "records a step only when enough replicas have agreed on it". The rest I believe right as far as they go: the two citations, the track circuit, the air brake, the control rods, the command and monitor channels, the security module, lockstep cores, coded processing, the checksumming file system, the supervision tree.

---

## What was run, and what is left in the folder

- **Built** with `cargo build --release --target-dir ./target`, and listed the tests.
- **Tests run by name, all passing:** `left_alone_for_half_an_hour_it_never_halts`, `a_halt_ends_as_it_is_set_to`, `what_can_be_said_to_be_written_during_the_work`, `a_wrong_step_is_undone_under_each_way_a_halt_can_end`, `work_that_goes_wrong_twice_running_cannot_go_on`, `a_signal_written_from_outside_is_found`, `a_flag_in_one_ring_reaches_the_other`, `what_the_observers_miss_the_gate_stops`, `a_change_to_the_state_as_the_round_is_recorded_is_not_recorded`, `what_is_asked_of_the_game_is_taken_down_twice`, `a_record_that_nothing_can_settle_stops_the_game_until_it_is_begun_again`, `the_next_spider_walks_in_as_the_old_one_starves`, `a_wrong_step_that_breaks_no_rule_is_found_by_doing_the_work_twice`.
- **The program on port 8186.** The five lines, the three settings, the transcripts, fourteen requests on host, origin and headers, and 300 hostile lines under the three settings with and without `during`. Those gave 252 halts, all put right, and never a halt that cannot be put right. I stopped it after confirming by its path that it was mine (PID 34640). Nothing was sent to 8138, which was still listening afterwards.
- **A throwaway copy inside the folder**, since deleted: three probe tests (N1, N2, N3, N4), and the half-hour test with three numbers changed in `game.rs`. The sources in the folder were not changed; their sizes are as received.
- **Left in the folder:** `target\` (the build), and `_probe\` with `p.js`, `hostile.js`, `probes.rs.txt` (the three probe tests) and `numbers.diff.txt` (the three numbers changed).
