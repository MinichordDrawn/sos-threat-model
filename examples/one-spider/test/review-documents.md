# Check of `README.md` and `gameplay.md` against the program

Four claims are wrong and 35 are true only in a narrower form; nothing in `gameplay.md` is wrong. The three transcripts, every quoted message and every number but two match the program.

## How it was checked

- **Read whole:** both documents, the five source files, `page.html`, `test/limits.js`, `test/wiring.py`, the four review reports. Of `test/drive.js` I read the header, the plan table, and the `lives` and `again` plans.
- **Built and listed:** `cargo build --release` with rustc 1.98.1; `cargo test -- --list` gives 45 tests.
- **One existing test run:** `left_alone_for_half_an_hour_it_never_halts` passed.
- **Program run on port 8185:** I sent door lines and a few GETs, then stopped it after confirming by its path that it was mine. Nothing went to 8138.
- **Throwaway probe tests:** added to a scratch copy inside the folder (`_probe/`), run, and the copy deleted. "Ran" below means one of these or the running program.
- **One slip:** a probe was sized too large and I stopped it after three minutes, then reran it smaller.
- **Left behind:** `target/` only.

## Wrong

**W1. README 622-623.** "The tests and the reviews found no single fault that is recorded or that stops the game for good."
- The reviews did find such faults, on the versions they read.
  - `test/review-math.md:9-11, 44-109`: four (A and C end in a halt that cannot be put right, B is recorded as true, D stops the program).
  - `test/review-math-2.md:5`: one more that loses the game.
- README 637-642 and 652-655 say so themselves.
- Put: "The reviews found five single faults that were recorded, or that stopped the game or the program. Each is closed and is a test, and the tests find no other. No review has been made of the version that is here. That is not a proof that there is none."

**W2. README 613-614 and 633-634.** "given the code and none of the reasoning behind it"; "was given only the code".
- All four reports say they read the README of their version.
  - `review-math.md:22` ("the README sections named"), and 183 ("Two README sentences are contradicted").
  - `review-outside.md:169`.
  - `review-math-2.md:129, 131, 158` (quotes README lines).
  - `review-outside-2.md:3` ("I read ... `page.html` and `README.md`").
- The two reviews of the single-fault claims were also handed the claims to check (their verdict tables are by claim).
- Put: "each by a reviewer given the code, the README as it then was and the claims to check, and none of the working behind them".

**W3. README 750-751.** "half a minute of play after it with no halt".
- `watch.rs:2212` plays 3,600 rounds at a sixtieth of a second (`watch.rs:1061`): one minute. `watch.rs:2121` is the same.
- Put: "a minute of play".

**W4. README 737.** "Then a dozen lines that break no rule".
- There are eleven (`watch.rs:1981-1993`).
- Put: "Then eleven lines".

## Narrowed

README unless marked.

**N1. Lines 16-17 and 601-602.** "open write access to every field of the state"; "Every field of the state ... is changed through the door".
- The door reaches six of the seven parts (`door.rs:409-414`), as lines 129-130 say.
- Put: "every field of the spider, of the world and of the observers" (the words of line 409).

**N2. Lines 23-24.** "One fault at a time, in anything the game keeps, is found before any work is done on it".
- "Anything the game keeps" is the four kinds the next paragraph names. It is not the gate's bookkeeping: with the number of the round made not-a-number the game ended in "it could not be put right: the legs B observer is silent" (ran).
- "Before any work is done on it" holds for a fault between rounds. For a fault inside a round, work may be done on it and is not recorded.
- Put: "One fault at a time, in the state, an observer, the gate's record or what was asked of the game, is found before any work done on it is recorded, and is put right, and the game goes on."

**N3. Line 38.** "This is tested and reviewed."
- Each review of these claims found them false of the version it read (`review-math.md:9-11`, `review-math-2.md:11`). The fixes are tested and unreviewed (line 674).
- Put: "This is tested. Earlier versions were reviewed, each review found a case where it failed, and those cases are closed and are tests."

**N4. Line 39.** "That this program is that wiring is argued and tested."
- Line 616 files it under "Argued" only, and 611-612 say the model check says nothing of it. No test holds the program to `wiring.py`.
- Put: "is argued".

**N5. Lines 73-76 and 483-485.** What the page sends back; "changes what its owner sees and nothing else".
- The page also sends the setting (`POST /how`, `main.rs:492`) and the asking to put right (`POST /right`, `main.rs:500`; `page.html:449-450`).
- A changed page can send any of these without the person, which lines 560-563 say is not checked.
- Put: "... what was typed at the door, which way a halt is set to end, and a click on "Put it right". Changing the page changes what its owner sees and what is sent in the owner's name, and nothing that is observed."

**N6. Lines 90 and 109-110.** "Every observer keeps a copy of every part of its ring".
- The two coordinators keep a fingerprint (`watch.rs:205-207`), as lines 173-174 say.
- Put: "a copy, or for the two coordinators a fingerprint".

**N7. Line 93 (P6).** "Through `whole`, a loss in one ring halts the other."
- The halt is one flag for the whole program, set on any silence or any sound flag (`watch.rs:448-450, 780-791`), whether or not `whole` carries anything.
- What goes through `whole` is the flag onto the other ring's observers (`watch.rs:432-444`). Both reviews of the wiring note this (`review-math.md:164`, `review-math-2.md:233`).
- Put: "A loss in either ring halts everything, and through `whole` the flag reaches the observers of the other ring."

**N8. Lines 115-116 (One round, step 3).** "everything halts and no work is done".
- Set to end "at once", the state is put right and that same round goes on to its work (`watch.rs:801-807`; ran).
- Put: "everything halts, and no work is done on what was found."

**N9. Lines 186-188 and 512.** "A screen is sent only the beginning of an observer's texts".
- The `moths` observer's list is also sent whole, as `halted` (`watch.rs:1032`).
- A reason written at the door together with a flag becomes the halt's reason (`watch.rs:430`). It is sent whole as `halt` and `why`, and `why` stays in every frame after the putting right (`watch.rs:1010, 1025`).
- Both ran with 1,024 characters. So what is "said at the door" as found (lines 380-381) can be a text that was typed there.
- Put: add "The `moths` observer's list, and the reason of a halt, are also sent whole, and neither is longer than 1,024 characters."

**N10. Line 240.** "A letting go is never left out."
- One that follows another with no press between is not taken down (`watch.rs:881-886`; ran).
- Put: add "but for one that follows another with no press between".

**N11. Lines 253-254.** "of the pointer's places only the last".
- A place that comes during a halt writes over the one before it. Places already waiting when the halt came stay (`watch.rs:875-879`; ran: four kept).
- Put: "of the pointer's places that come during the halt only the last".

**N12. Lines 254-255 and 285-286.** "What was asked of a round that went wrong is still in both lists ... and the round after it takes it in."
- Not where the two lists no longer agree: then both are put aside (`watch.rs:727-732`; test at `watch.rs:2569-2577`).
- Put: add "unless the two lists no longer agree".

**N13. Lines 313-317; gameplay 95-98.** "The numbers of the game are stated there a second time"; "A number changed in one place and not the other halts the game."
- Only the numbers a rule uses are in `rules.rs`.
- Stated once, in `game.rs`:
  - 14 moths a minute (60);
  - 4 on the wing (61);
  - hungry at a third (32);
  - 0.7 seconds to get over being held (37);
  - four units to take hold (38);
  - how near a strand holds and a click takes (84-85).
- Changing one of these halts nothing, since both doings read the same.
- Put: "The numbers the rules use are stated there a second time"; in gameplay, "Those the rules hold the work to are stated twice".

**N14. Lines 338-346.** `during world.web.made += 1` as a line that breaks no rule.
- True only while the spider is at work on its web with the thread in hand.
- Otherwise the rule at `rules.rs:311-313` names it. With the spider hungry the program said: "the gate found a step of the work that the rules of the game do not allow: the web grown with no spider at work on it" (ran both).
- Put: use `during spider.body.until += 5` ("... came out another way in the body"), or add "while the spider is at work on its web".

**N15. Lines 397-398.** "the state is left as it was found".
- The parts before the unsettled one, in the order of the parts, have already been put back (`watch.rs:686-693`). Only that part and those after it are left.
- Ran: legs, body and moths put back; pointer, requests and chance still showing the unrecorded round. `review-math-2.md:131` says the same.
- Put: "the parts before it have been put back, and that part and those after it are left as they were found".

**N16. Lines 541-544.** "so that is one fault a round".
- A fault that lands late in a round, after the two doings were compared, is not found until the next round looks. A second before that look is two together (`review-math-2.md:150-158`).
- Put: "so that is one fault from one look to the next".

**N17. Lines 558-559.** "or one half, and the state too. Nothing settles which is right. Nothing is changed".
- True where the last round's work had moved the part, as it always has the body.
- Where it had not, the state as that round began settles it (`watch.rs:696-721`). For the edge, either half with the state changed too was put right under all three settings (ran).
- Put: "or one half, and the state too, in a part the last round's work had moved".

**N18. Lines 564-567.** The list of the gate's bookkeeping.
- It leaves out:
  - the number of the round, which every signal is held to (`watch.rs:248, 348`);
  - the state kept from when the round's work began (263);
  - what was let through and what could not be written, with their counts (267-276);
  - the count of games (270).
- Put: add them.

**N19. Lines 576-579.** "Anything that happens to the work during a round makes the two doings disagree".
- True of what one doing reads and the other does not.
- Both doings read the round's length and time (`watch.rs:602-603, 815-816`; `review-math-2.md:220`) and the web's steps (lines 587-588).
- Put: "Anything that happens during a round to what only one doing reads".

**N20. Lines 591-592.** "The two doings then disagreed twice running".
- That is the review's account (`review-math.md:181`).
- In the code that is here the rules refuse the round first (`rules.rs:135`, the count of legs). Ran: "twice running, the gate found a step of the work that the rules of the game do not allow: a foot further from the body than a leg can reach".
- Put: "The round was refused twice running".

**N21. Lines 604-605, 775, 782.** Faults "while a round is being worked".
- The tests put a fault at one instant of the work: after it is done and before the gate checks it (`watch.rs:817-820`). There are two more instants in the recording (583-586, 630-633).
- No test puts one before or between the taking in, the world's work and the spider's. The reviews did.
- Put: "after a round's work and before the gate checks it".

**N22. Lines 628 and 847.** "The page is checked in a headless browser by the eleven plans".
- The plans print what the page showed, for a person to read. The only verdict they give is "no exceptions, no console errors" (`drive.js:1-2, 588`).
- Put: "What the page shows is printed by the eleven plans ... and read".

**N23. Lines 646-651.** What `review-outside.md` found.
- Its findings 6 to 8 are left out. Three writes were not found, though none kept a change (`review-outside.md:9, 107-131`):
  - a write to an observer's signal;
  - a `during` write to an observer, which the page said was let through;
  - a kept line that outlived its halt.
- All three are closed and tested now.
- Put: add a sentence saying so.

**N24. Lines 691-692 and 757-758.** "round for round".
- The two games are compared after the first round and once more 300 or 600 rounds on (`watch.rs:1174-1178, 2462-2467`).

**N25. Lines 708-711.** "In each ...".
- All of it is asserted only for the death of old age (`watch.rs:1633-1640`).
- For starving: no check of the foot (1668-1669).
- For the meter emptied: only the old spider's place and the new one outside (1718).

**N26. Lines 728-729.** "The every-field tests are run again".
- Only the spider's are (`watch.rs:1327`). The world's run on two games (1353), the observers' on one (1376).

**N27. Line 764.** "The same under the other two ways".
- One fault, the gate's copy of the moths emptied, on one game (`watch.rs:2507-2520`).

**N28. Lines 775-776, 779-780, 783-784.** "under each way a halt can end".
- Under the two settings that wait, the tests ask for the halt to end (`watch.rs:2551, 2622`). The pause is not waited out.
- The fault in the second list is tried under the starting setting only.

**N29. Lines 799-800.** "Every text there is".
- Eight fields (`watch.rs:2675`). The observers' copies are not among them.

**N30. Lines 805-806.** "a stop of the program in the wrong place".
- The test calls `fail` itself (`watch.rs:2110`). Nothing makes the program stop, so the catches in `main.rs:91-100, 240-251, 468` and the exit at 180-182 are from reading (`review-math-2.md:191`).

**N31. Lines 808-812.** "each must ... change nothing in the attempt, and be gone from the game begun after it".
- All three are asserted only for both halves changed each another way (`watch.rs:2938-2945`).
- With a value the rules forbid, the state is changed: it is put back to the wrong record (2258-2259).
- For one half with the state, only that the game cannot go on is asserted (2950-2954).

**N32. Line 814; gameplay 100.** "left alone"; "left to itself".
- The pointer moves over the game for half of every 400 rounds (`watch.rs:1274-1276`).

**N33. Lines 432-434, 498-500, 508.** Sizes in "characters".
- A line of a request, what it carries and the door's answer are counted in bytes (`main.rs:341-351, 434`; `door.rs:170`).
- The 1,024, 200, 160 and 24 are characters.

**N34. Lines 545-546.** "the gate's text of that part".
- The review says only "one change to a record text" (`review-math.md:178`). By the code it has to be that part.

**N35. Line 459.** "ten times a second".
- Every sixth frame the browser draws (`page.html:385`): ten a second on a 60 Hz screen.

## The four hand-written parts

**"The result".**
- Three sentences are narrowed: N2, N3, N4.
- For the rest I found nothing in `round`, `record_now`, `write_record` or `restore` that contradicts them, for the four kinds of fault at the instants the tests and reviews used.

**Fourth column of the table.**
- P1, P2, P4, P5, P7 and P8 are true of the program.
- P3 is loose (N6). P6 is overstated in its second sentence (N7).

**"One round".**
- The order is the order of `Game::round()`. Step 3 is N8.
- Left out:
  - in a halt that cannot be put right the round ends before step 1 (`watch.rs:769-776`);
  - while a halt lasts, step 1 is still done and step 2 is not (780);
  - the state is kept as it is before step 4 (810);
  - lines kept with `during` are written between steps 4 and 5 (825-830);
  - a second failed round running (846-856).

**"What is established".**
- Tested: N1 and N21.
- Reviewed: W2.
- Not established: W1 and N22.
- Model checked: not checkable.
- Argued: the bookkeeping was also run by both reviews of the single-fault claims, not only read.

## What the README says each review found

- Apart from W1, W2, N20, N23 and N34 it matches the four files, numbers included (four cases, nine of ten, some 50,000, twelve instants, 640,000 and 2.70, ten things).
- "Nine of ten held": two of the nine hold with qualifiers the README does not give, one outside the fault model and one "with two corrections to the claim as worded" (`review-math-2.md:15, 18`).

## Internal references

- Every section named in quotes exists under that name.
- Every file named exists.
- The eleven plan names, the fields, the commands and the three usage lines match.
- `Cargo.lock` is in the folder and not in "What is here".
- Line 125, "The sections that follow take these in turn": they run steps 1-2, 4, 5-6, then 3.
- The limits table has no row for lines kept with `during`: eight at once (`watch.rs:941`). The door then says "there is too much waiting to be written already".

## Does not belong, or contradicts

- **Line 778-779:** "which used to stop the program" points at an earlier state.
- **Lines 610 and 862:** "judgements" in one and "goals" in the other for the same two things.
- **Line 39 against 616:** see N4.
- **Lines 622-623 against 637-655:** see W1.
- **Between the two documents:** no contradiction.
- **Outside the two documents:**
  - The review files are headed "Rust copy" and "Rust server".
  - `drive.js:60-77` names its pictures `rust_*`.
  - `drive.js:81` says the state is shown on the left.
  - The review files give absolute paths under a Windows user folder and name probe folders that are not here.
  - `limits.js:116` reads `world.moths.length`, which the door does not have. That check passes on the refusal message alone.

## Counts

These are my own counts of sentences and table cells; the confirmed figures are approximate.

| Document | Claims | Confirmed | Narrowed | Wrong | Not checkable |
| --- | --- | --- | --- | --- | --- |
| `README.md` | about 575 | about 490 | 47 (35 findings) | 5 (4 findings) | about 31 |
| `gameplay.md` | about 104 | about 100 | 3 (in N13, N32) | 0 | 1 |

The run in gameplay 100-101 is exact: 459 caught, 128,894 hundredths gained, 57 bought, spider no. 7.

## Not checked, and why

- **The repository.** Everything about the kit, the model, the model check and `../../model-check`, the first three columns of the table, and whether the wiring meets Theorem S at one to four faults: the checker is not in the folder.
- **`test/limits.js` and `test/drive.js`.** Not run, as told. I checked only that they hold the checks the README lists, not that they pass, nor "about two minutes".
- **The full suite.** Not run, as told: whether all 45 pass, and "about four minutes".
- **The reviews' provenance.** Which models they ran on, "less capable", "word for word", and which version each read: the files do not say.
- **"Built with Rust 1.98".** It built with 1.98.1; nothing in the folder pins a version.
- **The page in a browser, and connection timings.** From reading `page.html` and `main.rs` only.
- **The universal claims.** "Never recorded" and "no single fault": read and probed, not proved.
