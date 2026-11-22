Nothing the updates add or alter is wrong of the code. Two statements are true only in a narrower form than they are worded, and a handful rest on measurements or on the review itself and cannot be told from the folder. No update made a right statement wrong, and no place was left behind on the number of points.

## Wrong

None.

## Narrower than stated

**1. `checks.md` lines 251-252, and again lines 696-698**
- Quoted: "With more moths than a game can hold, nothing may be said to be under the pointer." and "with more moths than a game can hold nothing is said to be under the pointer."
- Code: `over()` returns nothing only when `self.world.moths.len() > MOST_HELD` (`src/watch.rs:1597`), and `MOST_HELD` is 1,024 (`src/watch.rs:92`). The test tries 1,025 moths and no other number (`src/watch.rs:3313-3314`).
- `observation.md:110-111` gives 48 as the most moths a game can have. From 49 to 1,024 moths, `over()` goes on to `pick` and `moth_at` as before (`src/watch.rs:1600-1604`).
- The statement is exact if "a game can hold" means the 1,024 that held lists are cut to, and narrower if it means the 48. The documents use both senses a few lines apart.
- The same wording is in the comments at `src/watch.rs:1595-1596` and `3305`, and the assertion message at `3314`.
- "Nothing" itself is right: the return comes before the legs and the body are tried, so no leg, body or moth is said.
- Settled by reading, not by a run.

**2. `checks.md` lines 694-696, and `observation.md` lines 129-131**
- Quoted: "Thirty thousand moths with numbers no moth has had, in the gate's copy between the rules and the second doing of the work, cost a round nearly seven seconds, because the second doing looks each moth up among all of them" and "Thirty thousand moths with numbers no moth has had did the same in the costliest place found, the gate's copy just before the work is done a second time".
- Code: the second doing looks each moth up among the halted ones, not among all of them (`src/game/again.rs:532-533`). The list it is given is `again::in_web(&self.record.world)` (`src/watch.rs:1079`), the moths of the gate's copy that lie in the web (`src/game/again.rs:390-394`).
- So the cost is there only when the added moths lie where a halted moth lies. Neither sentence says that.
- `checks.md:261-262` does say it ("where a halted moth lies"), and so do the comments at `src/watch.rs:1030-1031` and `4859-4860`.
- Measured on this machine, one round, with the cut at `src/watch.rs:1032` taken out of a copy of the program (release test build):

| What was put into the gate's copy | One round |
|---|---|
| 30,000 moths with new numbers, where a halted moth lies | 1.3 to 1.4 s |
| 30,000 moths with new numbers, where a moth on the wing is | 0.07 s |
| 30,000 copies of one halted moth, all with its number | 0.07 s |

## Cannot be told from the folder

**3. `checks.md` line 695 "nearly seven seconds", and `observation.md` lines 129-131 "did the same"**
- The code could give it, but not from the moths alone on this machine. With the cut at 1032 out:

| Moths with new numbers, where a halted moth lies | Clicks waiting | One round |
|---|---|---|
| 30,000 | none | 1.3 s |
| 30,000 | four | 6.2 s |
| 30,000 | eight | 11.2 s |
| 60,000 | none | 5.4 s |

- Each click that hits nothing goes through every moth and looks each one up (`src/game/again.rs:536-537`), so each waiting click adds about as much as the moths' own pass.
- The figure needs clicks waiting, or a slower or busier machine. Which the review had, the folder does not say.
- That a round of more than five seconds ends the program is in the code: five waits of one second each (`src/watch.rs:1821`, `1899`, `2091-2095`), and the second observer to say so stops the program (`src/main.rs:277-291`).

**4. `observation.md` line 128**
- Quoted: "Two million copies of a moth landing there cost a round more than five seconds".
- The cost is linear in the copies. Two million copies of a moth in the gate's copy before the second doing, with that cut out, cost a round 4.7 to 4.8 s on this machine.
- More than five in another of the "few steps", or on the machine it was measured on, is within what the code could give. The measurement itself cannot be checked.

**5. `checks.md` lines 688-698, what the review ran and found**
- "121,836 single faults and 9,000 pairs", "twenty times faster", "in every game it played the work was handed the whole of the list of halted moths", "a check of what the tenth led to": all of the review, which is not in the copy.
- "it found seven things the tests did not hold: there are tests now for each": the test descriptions in the diff name six things newly held, each of which is in the tests (list below). Which seventh is meant cannot be told. They are assertions added to three tests, not new tests: the program still has 84.

**6. `checks.md` lines 435-442, and `README.md` line 491**
- "They are given here in the order they were made in", "`review-change-11.md` is that check of a change", and that all thirty-three hand-backs are in `test`: the `test/review-*.md` files are left out of the copy, as the brief says.

## What was checked and holds

**Six points (`observation.md` 113-115).** The round cuts down at:
- its start: `fit_kept()` at `src/watch.rs:1343`, then `fit()` at `1364`
- before the observers are asked: `1428`
- before the work: `1467`
- before the gate checks the work: `1002`
- before the work is done a second time: `1032`, directly before `self.redone(dt, now)` at `1033`
- before the record is written: `1046`

The backdoor's cut is `cut_down` at `866-870`. The place named in `observation.md:130-131` and `checks.md:696-697` has its cut.

**The three test descriptions in `checks.md`.**
- Lines 249-251, one letter and 10,000 three-byte characters handed to the work as the letter and 6,826: `src/watch.rs:3303-3304`, with `halted_moths()` at `696-703`. The arithmetic holds: 1 + 3 × 6,826 = 20,479, and 20,480 falls inside a character.
- Lines 252-253, a quote and a backslash: `src/watch.rs:3316`, `src/backdoor.rs:72-73`.
- Lines 261-264, twenty-three faults: the array is typed `; 23]` at `src/watch.rs:4858`, and its entries match the sentence's kinds (7 in the state, 2 in the gate's copy, 2 in the record's texts, 3 places kept from the round before, 5 in one observer, the observers, 3 lists of what was asked).
- Same lines, sixty thousand moths numbered from 1e9, copied from a moth in the web, into the gate's copy: `4861-4871`.
- Same lines, five instants inside a round, the last two before the record is written and between the rules and the second doing: `4914-4925`, with the hooks at `1041-1044` and `1026-1029`. Three ways a halt can end: `4909`.
- Lines 313-314, an account in which the pointer holds nothing is not recorded: `src/watch.rs:4820-4821`.

**`checks.md` lines 274-276, taking a cut out.** Run on a copy, one cut out at a time. Each fails the test at `src/watch.rs:4934`, "something of that size is still held":

| Cut taken out | Line | First case to fail |
|---|---|---|
| before the observers are asked | 1428 | the 60,000 moths, instant 1 |
| before the work is checked | 1002 | the 60,000 moths, instant 2 |
| before the work is done a second time | 1032 | the 60,000 moths, instant 5 |
| before the record is written | 1046 | moths in the first place kept from the round before, instant 4 |

The unchanged lines 277-281 still hold after the test's changes. With the first cut at the start out (1343) the test fails by time alone, 1.9 s. With the second at the start (1364) or the one before the work (1467) out, it passes.

**The three tests as they are.** All three pass in `now/`: 3 passed, 81 filtered out, which is the README's 84. The longest round in the cutting-down test was 259 ms.

**Counts.** They agree in every place:
- eleven and eighteen: `README.md:484`
- thirty-three: `README.md:491`
- twenty-nine: `README.md:493`, `checks.md:395`, `435`, `713`
- the list in `checks.md` has 11 `review-change*` entries, 18 `review-documents*` entries and the 4 reviews: 29 and 33.

## Step 2: the same statement elsewhere

- **Number of points.** The only other place is the comment at `src/watch.rs:829-831`, which says six and names the same six. `checks.md:615`, "The four points", is the ninth check's entry and speaks of the version it read.
- **The replaced sentence.** No "hundred thousand moths" or "two and a half seconds" remains in any document or comment.
- **Millions of entries.** `README.md:344-346` and `529-530`, `checks.md:281-282` and the comment at `src/watch.rs:841-845` still speak of millions between two points. None is contradicted by the new sentences. The rules do not reach the same slow look-up for moths added to the gate's copy: they refuse at the count first (`src/rules.rs:203-208`).
- **Bytes and characters.** The updated `checks.md:250-251` gives what the work is handed as "its first 20,480 bytes". `observation.md:120-121` and `checks.md:646` still say "no more of it than its first 20,480 characters". Both are true: the limit is in bytes (`src/watch.rs:698`), and that is never more than as many characters. They no longer use the same unit.

## Step 3: a right statement made wrong

None found. "A text has to be far longer to do the same" (`observation.md:131`) still follows a sentence about a round of more than five seconds. `gameplay.md:75-77` on the ring under the pointer is not made wrong by `over()` now saying nothing above 1,024 moths.

## How this was done, and what was left

- Only the changed lines and their other occurrences were read in the documents.
- Tests were run by name, in the foreground, with `--test-threads=2`. The program was not run and nothing was sent to any running copy.
- The cuts were taken out, and three timing tests added, in a copy of the program made inside the folder (`mutant/`). It is deleted. `now/src` was compared with it before deletion and is unchanged. `now/target` is left from building.
- One search returned more than the tool showed. The tool saved the full result to a file outside the folder by itself; I did not open it and narrowed the search.
- Not checked: `test/limits.js`, `test/drive.js` and the page in a browser, which none of the changed lines turn on.
