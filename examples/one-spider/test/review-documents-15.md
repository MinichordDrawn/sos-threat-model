One added sentence is wrong as worded, four statements are narrower than stated (two of them places left behind), and two cannot be told from the folder. Nothing the corrections say about what `stopped()` and `fail()` do is false of the code, and every count agrees wherever it is given.

All paths are under `«WORK»\check-twelve-d\docs\now\`.

## Wrong

**1. `README.md` lines 232-233: "Only a stop in the wrong place there puts the game aside whole."** — wrong as the README itself uses the words.
- `README.md` line 86 says of the same halt: "a click on "Put it right" puts it aside whole and begins it again."
- The code has two ways a game is replaced whole in a halt that cannot be put right:
  - a stop: `stopped()` calls `fail()` (`src/watch.rs` 595-598, 941-956);
  - the click: `put_right()` sets `asked`, and the next round calls `begin_again()` (`src/watch.rs` 1340-1344, 1619-1634).
- If "put aside whole" means `fail()` only, the sentence is true of the code and line 86 is the line that is off. `README.md` 269 and `observation.md` 352 and 359 use it for `fail()` only.
- If it means what line 86 uses it for, "Only" is false.
- This is the one place where a correction made the documents disagree with themselves. `README.md` 295-297 names both the click and the stop, and is right.

## Narrower than stated

**2. `observation.md` lines 358-360: "if the program stops where it should not during such a halt, the game is put aside whole"; the same in the `///` on `stuck`, `src/watch.rs` 706-707.**
- True for a stop in a round or in what a screen is sent: `src/main.rs` 322-339 calls `stopped()`, and `src/watch.rs` 596 (`if self.stops > 0 || self.stuck()`) calls `fail()`.
- True for a stop on a connection's thread that had the game: `src/main.rs` 98-107 calls `stopped()` at the next taking of the game.
- Not true for a stop while the backdoor is doing a line. That stop is caught at `src/main.rs` 588-591 with the game still held, the lock is not poisoned, `stopped()` is never called, and the line is refused. In such a halt the game is then left exactly as it was.
- `outside.md` 65-67 says this of the backdoor in general. The two new sentences do not carry it.

**3. `observation.md` lines 359-360: "as it is after any second stop."**
- A second stop puts the game aside only while `stops > 0` (`src/watch.rs` 596).
- `stops` goes back to 0 when a round that began with nothing halted is recorded (`src/watch.rs` 1490-1494).
- A second stop after such a round is a halt like any other. The same document says so at lines 348 and 354-355, and `checks.md` 169-170 has it as "two halts, and the game not put aside".

**4. Left behind: `backdoor.md` lines 76-77, "unless one of those two counts is wrong as well, which nothing puts right in such a halt"; and the corrected comment at `src/backdoor.rs` 222-224, "The gate does that for the number of observers at the start of the next round that is not in a halt that cannot be put right".**
- The gate's part is right: `right_counts()` runs in a round only after the return for such a halt (`src/watch.rs` 1340-1356), and `stopped()` reaches it only when the halt is not such a one (596-600).
- But the exception these corrections add applies here too. A stop in the wrong place in such a halt replaces the game through `fail()`, whose `Game::new` has eight new observers with all their copies (`src/watch.rs` 945, 657). The count is then right and the backdoor reads again, with the halt still one that cannot be put right and no round of the other kind having begun.
- The click does the same through `begin_again()`, inside the round that began in such a halt (`src/watch.rs` 1342-1343). That is one round sooner than the comment says, and not by the gate.

**5. Left behind: `test/limits.js` line 183, "screens: the newest is always sent the game"; and `src/main.rs` lines 112-113, "So the newest is always taken, unless every place is a screen's."**
- The word taken out of `test/limits.js` 140 is still in both.
- While 256 connections are held, a new one is refused before `admit()` is reached (`src/main.rs` 242-245). `test/limits.js` 159-165 checks exactly that.
- A connection that asks to be a screen is not made one if it was put out in the meantime (`src/main.rs` 157-160).
- The `main.rs` sentence is true of `admit()` taken by itself. `outside.md` 35-46 has no "always" and gives the 256.

## Cannot be told from the folder

**6. `README.md` lines 539-541 and `checks.md` line 678: "What the last check of a change led to is tested, and no reviewer has read that code".**
- What can be told holds:
  - The last `review-change-…` entry is `review-change-10.md` (`checks.md` 627-640).
  - What its entry says it led to is in the code: a control character written directly (`src/backdoor.rs` 77-83), and the work handed the first 20,480 characters of the list of halted moths (`src/watch.rs` 694-701, `MOST_SENT` 1024 at line 99).
  - It is tested at `src/watch.rs` 3281-3298, in `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long`, which I ran: it passes.
  - The README and `checks.md` say the same thing, and "last two" is left nowhere.
- "No reviewer has read that code" cannot be told. Two things bear on it:
  - The entry for `review-documents-12.md` (`checks.md` 645-650) says that check was made "after the tenth check's changes" and "measured what is left of the edge for a text, now that a control character is written directly". `README.md` 487-489 says a check of the documents is given the program.
  - To check this sentence I read those two pieces of code myself and ran their test. I did not review them for faults.
- Nor can it be told whether what `review-documents-11.md` led to ("about the test of the cutting down or about the backdoor", `checks.md` 641-644) changed any code or test. The old "last two checks" may have covered that, and the new wording does not.

**7. `checks.md` lines 655-659, the entry for `review-documents-14.md`.**
- What it found cannot be checked: the hand-back is not in the folder, as the brief says.
- "Each is corrected" holds for the three things it names:
  - "last two checks" is gone from both places;
  - `src/watch.rs` 3147 now reads "done to it";
  - the exception is in `README.md` 232 and 296, `observation.md` 358-360 and the `///` on `stuck`.
- As written, two of its sentences do not sit together. "Every statement they added or altered was true of the program" is followed by "the phrase put in its place has one exception", and that phrase was put in by those same corrections.
- The entry names three findings. The corrected comment in `src/backdoor.rs` and the word in `test/limits.js` are not among them, and I cannot tell whether that check found them.
- Also not checkable: that the next check of a change "was still out" (`checks.md` 431-432, 646), and that the twenty-eight hand-backs are in `test` (left out of this copy on purpose).

## Checked and found true

- **The exception itself.** In a halt that cannot be put right:
  - a round returns before any observer is asked, before the cutting down, before the counts and before any work (`src/watch.rs` 1340-1350);
  - nothing asked is taken down (1529-1533, 1569, 1595);
  - the backdoor refuses every write and cuts nothing (`src/backdoor.rs` 230-234, 276-278; `src/watch.rs` 863-867);
  - a line kept for the work is refused (`src/backdoor.rs` 132; `src/watch.rs` 1604).
  
  What still runs there writes only to what is the gate's: its three places, the state kept from the round before, the game's time, and the tick to the observers' threads. A stop there goes to `fail()`. I found no other thing done to the state besides the click.
- **`README.md` 295-297.** True, the click and the stop both named.
- **Test comment at `src/watch.rs` 3146-3147.** The test holds the state, the number of the round and every observer unchanged over 600 rounds, then begins the game on being asked. It agrees with `checks.md` 157-158. I ran it: it passes.
- **Counts.** The list in `checks.md` has ten `review-change` entries and fourteen `review-documents` entries: twenty-four, and twenty-eight with the four reviews.
  - Three, then nine pairs (`review-change-2`/`review-documents-3` to `review-change-10`/`review-documents-11`), then three checks of the documents: twenty-four.
  - These agree at `README.md` 485, 492, 494 and `checks.md` 387, 427, 431-434, 674.
  - No "twenty-three", "twenty-seven" or "thirteen checks" is left in any document, comment, the page or the test scripts.
- **`test/limits.js` 140.** True without "always": `admit()` puts out the non-screen that has waited longest unanswered, or else the one answered longest (`src/main.rs` 116-126).
- **The old phrase.** "Done with it" or "done with the game" is left in no place that speaks of such a halt.

## Whether a correction made a right statement wrong

Only finding 1. The other corrections left nothing wrong that was right before; the comment in `src/backdoor.rs` says of the gate what its old wording said.

## What I ran, and what I did not

- I ran four tests from `now/`, each by name, in the foreground with `--test-threads=2`: `a_game_put_aside_whole_waits_to_be_begun_again`, `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long`, `a_stop_in_the_wrong_place_is_once_a_halt_and_twice_running_the_end_of_the_game` and `a_stop_that_comes_back_every_round_puts_the_game_aside_at_the_second`. All four pass. The build is in `now/target`.
- I did not run the program, `test/limits.js` or `test/drive.js`.
- No test in the folder puts a stop into a halt that already cannot be put right with no stop counted (the `|| self.stuck()` half of `src/watch.rs` 596 on its own). That finding rests on reading the code. I did not add a test to the copy.
- One search returned more than was shown and offered a results file outside the folder. I did not open it and narrowed the search instead.
