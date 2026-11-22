**One statement is now wrong, and it is one the diffs did not touch: adding the two entries to the list of reviews left "What the last two checks led to is tested, and no reviewer has read it" pointing at the wrong checks. Every statement the two diffs themselves add or alter is true of the code, with two that are narrower than stated; the old wide phrase is still in one comment, and perhaps a second.**

All paths are under `now/`.

## Wrong

**1. `README.md:538-540` and `checks.md:672` — made wrong by the two added entries.**
- README: "What the last two checks led to is tested, and no reviewer has read it: the last entries under "Reviews" in `checks.md` say what that is."
- checks.md: "What the last two checks led to is tested, and no reviewer has read it."
- Neither line is in the diff. Before it, the last two entries were `review-change-10.md` and `review-documents-11.md`. Now they are `review-documents-12.md` and `review-documents-13.md` (`checks.md:644-653`).
- By the list's own account, the thirteenth is "a check of the corrections the twelfth led to" (`checks.md:650`), so a reviewer has read what the twelfth led to.
- What those two led to is corrections to documents and comments, which "is tested" does not describe.
- If the sentence still means the tenth check of a change and the eleventh of the documents, they are no longer "the last two", and the twelfth is listed as made "after the tenth check's changes" (`checks.md:644`).
- This is the only statement I found that was right before the corrections and is not right after them.

## Narrower than stated

**2. `src/watch.rs:3146` — the old wide phrase, left behind.**
- "What stands in its place is a game not yet begun, halted, and nothing at all is done with it."
- This is the phrase corrected everywhere else. The test under it reads that game for a screen three times (`game.shown(now)`, `watch.rs:3151-3156`), and the server sends it to a screen every round (`main.rs:323-324`).
- `checks.md:158` already says "with nothing done to it" of the same test.
- It also touches the new entry at `checks.md:652-653`: "one phrase said too widely in several places ... each is corrected". One place was not.

**3. "Nothing at all is done to the game's state" — true on every path but one.**
- Places: `README.md:230-231`, `README.md:294-295`, `observation.md:357-358`, `src/watch.rs:706`, `861`, `1338`, `1529`, `4920`, `5125`, `src/backdoor.rs:230`.
- The exception: if the program stops where it should not (a panic) while it has hold of the game in such a halt, `stopped` sees `self.stuck()` and calls `fail` (`watch.rs:595-599`). `fail` builds a new game and replaces the whole state with it (`watch.rs:940-955`). It is reached from `main.rs:332` and `main.rs:103`.
- So the state is replaced before "Put it right" is clicked. `outside.md:67-69` says a stop "once in a halt that already cannot be put right" gives a halt that cannot be put right, but no document says the state is replaced there.
- This was equally so before the correction; the change from "with" to "to" neither made nor removed it.
- Every other path holds:
  - A round returns before any look, cut or work (`watch.rs:1339-1349`); it only compares the gate's own places, moves the time and ticks the observers' threads (`watch.rs:1332-1336`, `2010-2014`, `2067`).
  - `ask` returns at once (`watch.rs:1530`); `press`, `buy` and `during` refuse in any halt (`watch.rs:1568`, `1594`, `1603`).
  - The backdoor refuses every write (`backdoor.rs:232-234`, `276-278`), and `cut_down` does nothing (`watch.rs:862-866`).
  - Only `put_right` followed by `begin_again` ends it (`watch.rs:1341-1343`, `1643-1649`).

**4. `test/limits.js:140` — "the newest is always taken".**
- "connections: the newest is always taken, and one that is no screen gives up its place: the one that has waited longest with nothing of its own being answered, or else the one answered longest".
- Who gives up its place is exactly `admit` (`main.rs:114-128`): never a screen, first the longest waiting with nothing being answered, else the longest answered. It agrees with `outside.md:35-38`.
- "Always" holds only while fewer than 256 connections are held in all. At 256 the newest is refused with a 503 before `admit` is reached (`main.rs:242-245`). The same test says so at `limits.js:159`, and `outside.md:35` makes the statement without "always".
- The word was in the old comment too.

**5. `src/backdoor.rs:222-224` — possibly the same old wording; a judgement call.**
- "The gate does that for the number of observers at the start of the next round in which anything is looked at".
- This is the wording the diff took out of the test comment at `watch.rs:5578-5579`, where "in which nothing is looked at" became "in which no observer is asked to look".
- Inside the round itself the statement is accurate: the counts are put right only past the early return (`watch.rs:1355`, after `1339-1349`). It is loose only by the measure the correction applies elsewhere.

## Cannot be told from the folder

- **`checks.md:646-649`**: "24 million of them cost a round a second and a half at the most, 64 million four and a half, and 96 million more than five". No test measures a round at those sizes and I did not run the program. The 64 and 96 million figures agree with `observation.md:128-130` and `README.md:345`; the 24 million figure appears nowhere else.
- **What the twelfth and thirteenth checks found** (`checks.md:645-646`, `651-653`), and "that check found five things the tests did not hold: there are tests now for each" (`checks.md:638-639`).
- **"Two checks of the documents came after those while the next check of a change was still out"** (`checks.md:431-433`).
- **That twenty-seven hand-backs are in `test`**, and what is replaced in them by «WORK» and «HOME». The two documents that say it agree (`README.md:491-492`, `checks.md:388-390`); checks.md adds only that one hand-back names the second path.

## Checked and true

- **Counts.** The list has four reviews (`checks.md:392-418`), ten checks of a change and thirteen of the documents (`checks.md:435-650`). That gives twenty-three checks and twenty-seven hand-backs, as said at `README.md:484`, `491`, `493` and `checks.md:387`, `427`, `668`. No older count is left in any document, comment or test file.
- **Order and pairing** (`checks.md:427-433`) agree with the order of the entries and with what each entry says it followed.
- **"No observer looks" and "no observer is asked to look"** (`README.md:231`, `watch.rs:1338`, `5125`, `5579`; also `backdoor.md:74`): the round sends only a tick, and a thread that gets one resets its count and looks at nothing.
- **The cutting down in such a halt** (`watch.rs:861`, `4920-4922`; `checks.md:622-623`): nothing of the state is cut by a round or by a line at the backdoor, and what the gate keeps from the round before is still cut (`watch.rs:1332`, `870-875`).
- **"A control character ... is now written directly"** (`checks.md:634-635`, `647`): `backdoor.rs:79-83`.
- **"Handed no more of the list of halted moths than its first 20,480 characters"** (`checks.md:635-636`, and the test's message at `watch.rs:3283`): `halted_moths` cuts at 1,024 × 20 = 20,480 bytes, between two characters (`watch.rs:694-702`, `99`), and that is what the work is given (`watch.rs:1457`, `1465`). It is a bound in bytes, so never more than 20,480 characters. Same as `observation.md:119-120` and `checks.md:247-249`.
- **"A text made long enough to do the same after that stays outside what is held"** (`checks.md:636-638`): agrees with `observation.md:124-133` and the comment at `watch.rs:836-841`.
- **Old wording.** Apart from findings 2 and 5, no "done with the game", "nothing looks" or "nothing is looked at" is left in the documents, `src/`, `page.html` or `test/`.

## What I ran

Four named tests, from `now/`, in the foreground with `--test-threads=2`; all passed:
- `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long` (the one whose message changed)
- `nothing_is_written_in_a_halt_that_cannot_be_put_right`
- `observers_on_threads_of_their_own_find_that_the_rounds_have_stopped`
- `what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at`

The build left `now/target/` in the folder. I did not run the program, sent nothing to any running copy, and nothing stopped me from checking anything beyond what is listed as not tellable.
