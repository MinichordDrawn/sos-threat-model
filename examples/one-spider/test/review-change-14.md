# Hand-back: check of the added moth case and the documents brought into step

**I found nothing wrong in the two added test lines, and nothing false in the documents' counts or in the test's description.** I found three lesser things, none of which is a false statement about the code:

1. The new entry for `review-change-13.md` is true only in a narrower form than it is worded: the test already made 100,000 moths at another place, so "the two numbers of moths the test tried" and "now tries a larger number too" are true only of the part about what is under the pointer.
2. One behaviour-changing variation of the guard in `over()` still passes the test: guarding only the moth lookup, so that a leg or the body is still said with more than 1,024 moths.
3. Two other substitutions on the guard line pass the test: `MOST_SENT` for `MOST_HELD` (same value today, so no behaviour changes), and `capacity()` for `len()` (which I judge not a natural mistake).

All paths below are inside `«WORK»\check-fifteen\`. Line numbers are into `after/`.

---

## Claim 1. Nothing but that test is changed in `src`: **holds**

- A byte-exact `diff` of `before/src/watch.rs` and `after/src/watch.rs` gives only two added lines, `after/src/watch.rs:3317-3318`, inside `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long` (the test begins at line 3250 and ends at 3343).
- `diff -rq before after` names three files and no others: `README.md`, `checks.md`, `src/watch.rs`. Every other file in `src`, `test`, `Cargo.toml`, `Cargo.lock`, `page.html` and the other four documents is identical.
- Regenerating the `src` diff gives `changes.diff` exactly, and regenerating the two documents' diffs gives `documents.diff` exactly (file-name header lines aside).

## Claim 2. The added assertion tests what it says: **holds**, with three notes

**Run, as the code is.** In `after/`, with the command the brief gives: `1 passed; 0 failed; 83 filtered out`.

**Run, with `== MOST_HELD + 1` at `after/src/watch.rs:1597`**, in a throwaway copy with that one line changed: the test fails at `src\watch.rs:3318:9`, "with four times MOST_HELD moths, something is still said to be under the pointer". The three assertions before it (3312, 3314, 3316) pass under that break, so the new line is the one that catches it, and it is not passing for some other reason.

**Run, the same break against `before/`'s test** (the copy's `watch.rs` replaced with `before/src/watch.rs`, same one-line change): passes. So the gap the change closes was there.

**Other breaks of line 1597, each run as a one-line change in the throwaway copy.** "Fails at" is the line of the assertion that caught it.

| Line 1597 becomes | Result |
|---|---|
| `>= MOST_HELD` | fails at 3314 |
| `> MOST_HELD - 1` | fails at 3314 |
| `len() + 1 > MOST_HELD` | fails at 3314 |
| `== MOST_HELD` | fails at 3314 |
| `> crate::MOST_HELD` (the 256 of `main.rs:44`) | fails at 3314 |
| `> MOST_HELD + 1` | fails at 3316 |
| `len() - 1 > MOST_HELD` | fails at 3316 |
| `> MOST_HELD * 2`, `> MOST_HELD * 4`, `>= MOST_HELD * 4`, `== MOST_HELD * 4` | each fails at 3316 |
| `> MOST_HELD_TEXT` | fails at 3316 |
| `< MOST_HELD`, `<= MOST_HELD`, `!= MOST_HELD` | each fails at 3312 |
| `self.spider.legs.len()`, `self.ring.len()`, `self.own.gains.len()`, `self.halted_moths().len()` counted in place of the moths | each fails at 3316 |
| `if false` (guard never taken) | fails at 3316 |
| `>= MOST_HELD + 1` | passes; same meaning, not a break |
| `> MOST_SENT` | **passes** (note B) |
| `self.world.moths.capacity() > MOST_HELD` | **passes** (note C) |

Argued only, not run: any other list counted in place of the moths (`own.clicks`, `own.buys`, `record.texts`, the three lists of asks) fails too. Between lines 3312 and 3318 the test changes nothing but `game.world.moths`, so any other list has one length throughout, and the guard is then either always taken (fails at 3312) or never taken (fails at 3316).

**Note A. One variation that changes behaviour passes the test (run).** With lines 1597-1599 removed and the guard put on the moth arm only (`None if self.world.moths.len() > MOST_HELD => None,` before line 1603), the test passes. A leg or the body is then still said to be under the pointer with more than 1,024 moths. That goes against the comment at 1595-1596 and `after/checks.md:701-702` ("with more than 1,024 moths nothing is said to be under the pointer"). The test does not see it because its pointer is always on a moth the spider is not standing on (3307-3311).

- I confirmed the difference is real with a throwaway assertion (pointer on `legs[0]`, `MOST_HELD + 1` moths, `over()` must be none): it fails under this variation and passes on the code as it is. On the code as it is, the same pointer with `MOST_HELD` moths gives "leg".
- This is a move of the guard, not one of the four kinds of break the brief names. It is a plausible thing for someone to do, since only the moth lookup is slow. Whether it matters is the author's call.

**Note B. The wrong constant of the same value passes (run).** `MOST_SENT` (`watch.rs:99`) is 1,024, as `MOST_HELD` (`watch.rs:92`) is, so `> MOST_SENT` changes no behaviour today and no test of behaviour could tell them apart. It would become a break only if one of the two numbers were changed.

**Note C. `capacity()` in place of `len()` passes (run).** `vec![moth; n]` has room for exactly `n`, so the test's three lists cannot tell the two apart. A throwaway assertion with 1,024 moths in a list with room for 2,048 does tell them apart. I do not think this is a mistake someone would plausibly make; it is here because it is "the wrong thing counted" and it passed.

**Also run: the test follows the constant.** With `MOST_HELD` itself set to 1,000 or to 2,048 at `watch.rs:92`, this test passes, because it writes its numbers as `MOST_HELD`, `MOST_HELD + 1` and `MOST_HELD * 4`. The value 1,024 is compared at `watch.rs:4858`, inside the helper `sized` (begins 4839), which other tests use; I did not run those.

## Claim 3. Every line `documents.diff` adds or alters is true of the code and the test in `after/`: **holds** for the description and the counts; **not settled** for what the new entry says of the earlier check, with one wording there true only in a narrower form

**The test's description, `after/checks.md:251-252`**: "With 1,024 moths the one under the pointer must still be said, and with one more, or four times as many, nothing may be." Holds.
- `MOST_HELD` is 1,024 (`watch.rs:92`).
- 1,024 moths, and "moth" must be said: `watch.rs:3313-3314`.
- One more, and nothing: `3315-3316`.
- Four times as many (4,096), and nothing: `3317-3318`.
- It is true with the pointer on a moth, which is the case the sentence speaks of; see note A for what the test does not hold with the pointer elsewhere.

**The counts.** Hold, and agree in every place.
- The list of reviews in `after/checks.md` (entries at lines 402-714) has 36 entries that name a hand-back: 4 reviews (`review-math.md`, `review-outside.md`, `review-math-2.md`, `review-outside-2.md`), 13 checks of changes (`review-change.md` and `review-change-2.md` to `-13.md`), and 19 checks of the documents (`review-documents.md` and `-2.md` to `-19.md`). After them, one entry for the kit's ring map (719).
- 13 + 19 = 32, and 32 + 4 = 36.
- "thirteen checks of changes and nineteen checks of these documents": `README.md:484-485`.
- "thirty-six hand-backs": `README.md:491`.
- "thirty-two later checks": `README.md:493`.
- "thirty-two checks": `checks.md:397`, `checks.md:437`, `checks.md:732`.
- I searched the six documents, `page.html` and `test/` for an old count left behind (thirty-one, thirty-five, twelve checks, and the figures) and found none.
- The 84 tests of `README.md:463` and `README.md:509` are not altered and are still right: the run reports 1 passed and 83 filtered out.

**The clause on the order, `after/checks.md:445-446`**: "and `review-change-13.md` of the lines of tests that one led to." It agrees with the entry at 714 ("the lines of tests the twelfth led to") and with the entry for the twelfth at 712-713 ("the tests now hold each"). The new entry is the last of the checks in the list, as "the order they were made in" needs. Whether that was the order, and what the thirteenth was given, I cannot check. A small wording point, not a fault: "that one" could be read as the eleventh, the nearest check named before it; the entry at 714 says the twelfth.

**The new entry, `after/checks.md:714-717`.** Not settled as to what the earlier check did, ran or found: its hand-back is left out of this copy on purpose. Against the code:

- "One break it tried, right at the two numbers of moths the test tried and wrong beyond them, passed that test": consistent. `== MOST_HELD + 1` is such a break, and I ran it against `before/`'s test: it passes.
- "the test now tries a larger number too": consistent, `watch.rs:3317-3318`.
- **True only in a narrower form.** The same test makes 100,000 moths at `watch.rs:3261`, in `before/` as well, and also asks what is under the pointer at the game's own few moths (3312). So "the two numbers of moths the test tried" and "now tries a larger number too" are true of the part of the test about what is under the pointer, not of the whole test.
  - Why the 100,000 do not count there: in that part of the test the pointer is not inside (`game.rs:326` starts it outside, and the test first sets it inside at 3311), so `over()` returns at `watch.rs:1592` before the count is looked at.
  - The run of the break against `before/`'s test passing confirms that nothing at 3261 catches it.

## What I could not check, and why

- What `review-change-13.md` was given, ran or found, and that it "found nothing wrong": the hand-backs are not in this copy.
- That thirty-six hand-backs are in `test`, word for word: `after/test` here holds only `drive.js`, `limits.js` and `wiring.py`, by the brief's design.
- That the thirty-two checks ran on Claude Fable 5.2, and the order the checks were made in: nothing in the folder records either.
- The full suite, by the brief's rule. Only the one named test was run, so I did not run the tests that use `sized` (`watch.rs:4839`), and I did not see the other 83 tests pass on `after/`.
- The program itself was not run, by the brief's rule.

## What I left in the folder

- `throwaway/run.sh` and `throwaway/copy/`, a copy of `after/`'s source whose `watch.rs` is restored to match `after/`.
- I built in `after/` and in the copy and removed both `target` folders afterwards.
- `before/`, `after/`, `changes.diff` and `documents.diff` are as I found them: the `src` diff still regenerates `changes.diff` exactly.
