# Hand-back: check of the seven added test lines and the altered document lines

**I found nothing wrong.** All three claims hold. Two small wordings in `checks.md` about what earlier checks dealt with are not settled, because the versions they speak of are not in my copy; they are given under claim 3.

Folder of the work: `«WORK»\check-sixteen\`. All line numbers below are in `after/`.

## Claim 1. Nothing but that test is changed in `src`: holds

- Compared byte for byte, three files differ between `before/` and `after/`: `README.md`, `checks.md` and `src/watch.rs`. Every other file is identical, including the rest of `src`, `Cargo.toml`, `Cargo.lock`, `page.html` and the three files in `test`.
- A fresh `diff -ru before/src after/src`, without ignoring line ends, gives seven added lines and no removed or altered line. Its hunk is the same as `changes.diff`.
- The seven lines are `after/src/watch.rs:3319-3325`. The test `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long` runs from line 3250 to the next `#[test]` at 3351, so all seven are inside it.
- A fresh diff of the two documents is the same as `documents.diff`.

## Claim 2. The added lines test what they say: holds

All runs used the command in the brief, with the test's name as the filter.

**As the code is: passes (run).** From `after/`: `1 passed; 0 failed; 83 filtered out`.

**With the change the brief describes: fails (run).** In a throwaway copy, I took out the check at `after/src/watch.rs:1595-1599` and put `None if self.world.moths.len() > MOST_HELD => None,` before the moth's arm (1603). The test fails at the last added assertion (3325): "with more than MOST_HELD moths, a leg is still said to be under the pointer".

**The same change against the test in `before/`: passes (run).** So the gap was there, and the added lines close it.

**The added case is not empty.**
- The pointer is put on `legs[0]` (3320-3321). `pick` gives leg 0 there (run, printed as `Some(0)`).
- Line 3323 holds that a leg is said with 1,024 moths. Line 3325 holds that nothing is said with 1,025.
- Nothing else changes between the two assertions. The game is not halted, the pointer has hold of nothing, and the pointer is inside (set at 3311).
- The comment at 3319, "no moth would be looked up for it", is true of the code: the leg's arm (1601) and `pick` (`after/src/game.rs:466-480`) read no moth.

**Variations tried, each run in a throwaway copy.** Lines are mapped to `after/` by the assertion's message.

| Variation of `over()` | Result | Fails at |
|---|---|---|
| The change the brief describes | fails | 3325 |
| The same, written as a condition before the `match` (count heeded only when `pick` finds nothing) | fails | 3325 |
| Count as a guard on the leg's arm and on the moth's arm, so a leg falls through to the body's arm and "body" is said | fails | 3325 |
| No check at all | fails | 3316 |
| `>=` in place of `>` | fails | 3314 |
| `> MOST_HELD + 1` | fails | 3316 |
| `== MOST_HELD + 1` (right at 1,024 and 1,025, wrong beyond) | fails | 3318 |
| The legs counted in place of the moths | fails | 3316 |
| The entries of the list of halted moths counted in place of the moths | fails | 3316 |
| No refusal, only the first 1,024 moths looked at | fails | 3316 |
| The check made after the lookup, on its result | passes, and is right: it says the same in every case |
| Count heeded inside the leg's arm and the moth's arm, the body left out | passes: this is the known case of the body, not reported |

**Argued only, not run.**
- `MOST_HELD_TEXT` in place of `MOST_HELD` would fail at 3316.
- `len() / MOST_HELD > 0` would fail at 3314.
- The check moved above the first `return None` at 1592 says the same in every case.

**Does any natural variation still pass?** I found none beyond those the brief lists as known. With the pointer on a leg and on a moth both tried at 1,024 and 1,025, and the moth also at four times as many, each plausible mistake I tried about where or how the number is heeded fails.

## Claim 3. Every line `documents.diff` adds or alters is true: holds, with two small wordings not settled

**The test's description, `after/checks.md:252-253`.** "The same with the pointer on a leg: said with 1,024 moths, and not with one more." True.
- Pointer put on a leg: 3320-3321.
- 1,024 moths, and a leg said: 3322-3323.
- One more, and nothing said: 3324-3325.
- `MOST_HELD` is 1,024: `after/src/watch.rs:92`.
- The sentence rightly does not claim "four times as many" for the leg: the test does not try it.

**The counts.** The list in `after/checks.md` has these entries, counted:
- 4 reviews: lines 403, 412, 420, 429.
- 14 checks of changes: `review-change.md` and `-2` to `-14`, at lines 450, 469, 490, 509, 528, 546, 570, 593, 617, 641, 694, 709, 716, 721.
- 19 checks of the documents: `review-documents.md` and `-2` to `-19`, at lines 462, 465, 481, 505, 523, 542, 564, 586, 612, 635, 656, 660, 666, 670, 675, 681, 685, 690, 706.
- One entry for the kit's ring map (727), which says it is not kept.

That makes 14 + 19 = 33 checks, and 33 + 4 = 37 hand-backs. Every place the documents give a count agrees:
- `after/README.md:483`: "fourteen checks of changes and nineteen checks of these documents".
- `after/README.md:490`: "thirty-seven hand-backs".
- `after/README.md:492`: "thirty-three later checks".
- `after/checks.md:398`: "thirty-three checks that followed".
- `after/checks.md:438`: "Thirty-three checks and one pass of the kit".
- `after/checks.md:740`: "thirty-three checks".

A search of the six documents and `page.html` for the old counts (thirteen checks, thirty-two checks, thirty-six hand-backs) finds none left. The other four documents give no such count.

**The sentence on the order, `after/checks.md:446-448`.** It agrees with the entries at 709, 716 and 721 and with their order in the list. The new entry comes last of the checks, after `review-change-13.md`.

**The entry for `review-change-14.md`, `after/checks.md:721-725`.**
- "One change it tried passed the test, the number of moths heeded only where a moth is looked for, so that a leg would still be said": agrees with what I ran. That change passes the test in `before/` and a leg is still said.
- "the test now puts the pointer on a leg too": true, 3320-3321.
- "The entry above said a little more than is so: it is corrected": the entry above is reworded in `documents.diff`.
- What that check found or ran I cannot check.

**The entry for `review-change-13.md`, `after/checks.md:716-720`.**
- "the test now asks at a larger number too": true, 3317-3318 (four times `MOST_HELD`).
- A change right at 1,024 and 1,025 and wrong beyond (`== MOST_HELD + 1`) now fails at 3318 (run).
- What that check found or ran I cannot check.

**Not settled, both small.** Both turn on versions I do not have, and neither is contradicted by the code.

1. **"the line the thirteenth led to"** (`after/checks.md:448`) and **"the line of a test the thirteenth led to"** (721). In `after/`, and in `before/`, the larger number is tried on two lines of the test: 3317 sets the moths and 3318 asserts. If the thirteenth check led to both, "line" is one short. I cannot see that change.

2. **"the two numbers of moths at which the test asked what is under the pointer"** (718-719). In the test as it is, `over()` is also asked at line 3312 with the game's own moths (3 in my run), before 1,024 and 1,025. If line 3312 was in the version the thirteenth check read, the test asked at three numbers, and a break of that kind is right at all three. I cannot see that version.
   - Argued only: the test also sends a screen with 100,000 moths (3261, 3271, 3275), and `shown` calls `over()` (1741). The pointer is outside there (run: `inside=false`), so `over()` returns at 1592-1593 before the number of moths is looked at.

## What I could not check, and why

- **What `review-change-13.md` and `review-change-14.md` found, tried or ran, and whether "It found nothing wrong" is so.** The hand-backs are left out of the copy on purpose.
- **That thirty-seven hand-back files are in `test`.** The copy's `test` folder holds only `drive.js`, `limits.js` and `wiring.py`. I checked the count against the list in `checks.md` only.
- **Which model the checks ran on** (`after/README.md:492`, `after/checks.md:740`). Only the number in those lines was checked.
- **The full suite.** Not run, as the brief says. Only the one test was run, and the program itself was not run.

Noticed in passing, outside the brief and not checked: `after/checks.md:744`, "What the last check of a change led to is tested, and no reviewer has read that code", is an unaltered line. The last check of a change is now one that led to lines of a test.

## Left in the folder

All throwaway, none of it in `before/` or in the sources of `after/`:
- `try/`: the copy the variants were run in, its `src/watch.rs` put back to match `after/`.
- `variants/`: the twelve variant files.
- `run-variant.sh`, `fix-variants.py`, `mydiff-src.txt`, `mydiff-docs.txt`.
- `after/target/` and `try/target/`: build output.
