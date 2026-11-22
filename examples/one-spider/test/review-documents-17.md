**Nothing the two diffs add or alter is false of the code on its intended reading, but there are things to correct: one inserted sentence now makes the sentence after it read wrongly, three corrected statements are true only in a narrower form, and the corrected statement survives uncorrected in three other places.**

All paths are under `now/`. I read the code, not the comments, for each finding. I ran four named tests with `--test-threads=2` and all passed (84 tests in the binary, 80 filtered out): `a_game_put_aside_whole_waits_to_be_begun_again`, `nothing_is_written_in_a_halt_that_cannot_be_put_right`, `what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at`, `a_stop_in_the_wrong_place_is_once_a_halt_and_twice_running_the_end_of_the_game`. I did not run the program.

## Findings

### Wrong as it now reads (made by the correction)

**1. `observation.md` 349-351.** "A stop while a line is being done at the backdoor is not one of these: it is caught there, and the line is refused. Once, and not in a halt that already cannot be put right, that is a halt like any other: the counts are put right, …"

- The inserted sentence is true. The trouble is the sentence after it: "that" now has the backdoor stop as its nearest antecedent, and for a backdoor stop it is false.
- A backdoor stop is caught in `src/main.rs` 588-591 and answered "that line could not be done: the backdoor stopped where it should not have". The lock is not poisoned and `Game::stopped` is not called, so no halt begins, no count is put right and `stops` is not counted.
- A stop becomes a halt only in `Game::stopped` (`src/watch.rs` 595-613), which is called only from `src/main.rs` 103 and 332.
- Before the correction, "Once … that is a halt like any other" followed the program's stop directly and was right. Read with "that" as the stop of the bullet's first sentence, it still is.
- **Wrong** on the nearest reading; this is the one place where a correction made a right statement read wrongly.

### Narrower than stated

**2. `README.md` 231-233.** "It is left as it is until the whole game is replaced: by the click that begins it again, or by a stop in the wrong place." Also 295-297: "…left as it is until "Put it right" is clicked, a stop in the wrong place apart…"

- The state is indeed left as it is. What is too wide is "a stop in the wrong place" as something that replaces the game.
- A stop while a line is being done at the backdoor in such a halt is caught (`src/main.rs` 588-591) and replaces nothing. The game is put aside only through `stopped` then `fail` (`src/watch.rs` 596-597, 942-957), reached from `src/main.rs` 103, 332 and 336.
- `observation.md` 359-361 has the exact form: "in a round or in a request other than a line at the backdoor". The two README places do not say the same as it.
- This is the same over-wide exception the entry for `review-documents-15.md` (`checks.md` 659-662) reports as corrected.
- **Narrower than stated.**

**3. `src/watch.rs` 5127-5128 (test comment).** "…the backdoor writes nothing: it refuses every write, and still reads."

- "Writes nothing" and "refuses every write" hold (see the list at the end).
- "Still reads" holds only while the two counts are right. `src/backdoor.rs` 225-227 refuses every read and write while the number of observers, or of an observer's copies, is wrong.
- In such a halt no round puts the number of observers right: `turn` returns at `src/watch.rs` 1350, before `right_counts` at 1357.
- `backdoor.md` 75-77 carries the qualification ("unless one of those two counts is wrong as well"); the comment does not.
- **Narrower than stated.**

**4. `observation.md` 349-350.** "A stop while a line is being done at the backdoor is not one of these: it is caught there…"

- True of a line as it arrives (`src/main.rs` 588-591).
- A line kept with `during` is written later by the backdoor's own code, inside the round (`src/watch.rs` 1479 calling `write_now`, `src/backdoor.rs` 159-161). A stop there would be caught by the round's catch and counted (`src/main.rs` 322-332).
- I found no path by which that write can stop, so this is only about what "at the backdoor" covers. `outside.md` 65-67 draws the same line.
- **Narrower than stated**, minor.

### The same statement elsewhere, left behind

**5. `checks.md` 629-630 (entry for `review-change-10.md`).** "It found that in a halt that cannot be put right nothing is done to the state…"

- This is the withdrawn phrase, in the present tense, given as a finding. The entry above it (622) was moved to "said"; this one was not.
- Of the code it is true of a round (`src/watch.rs` 1341-1351), of what is asked (1532) and of a line at the backdoor (`src/backdoor.rs` 232, 276; `src/watch.rs` 865). It is not true of a stop in the wrong place (`fail`, 942-957) or of the click (`begin_again`, 1343-1345 and 1620-1635).
- What that review found: **cannot be told from the folder**. As a statement about the program: **narrower than stated**.

**6. `README.md` 70-71.** "It is put right, or at the worst the game is begun again. Nothing is done in between."

- This is the widest form of the corrected statement, and it covers the halt that cannot be put right as well.
- README 229-235 itself lists what is done in a halt. In a halt that cannot be put right, a stop in the wrong place also replaces the game before it is begun again (`src/watch.rs` 596-597).
- It is a summary line, so it is yours to judge. **Narrower than stated.**

**7. Two comments give the rule for a stop without the backdoor exception that `observation.md` now has.**

- `src/main.rs` 96-97: "If the program stopped where it should not have while it had hold of the game, the game is told".
- `src/watch.rs` 587-589, on `stopped`: "a round, or something done with the game between two rounds, did not come to its end".
- A stop during a backdoor line happens with hold of the game, between two rounds, and the game is not told (`src/main.rs` 588-591).
- **Narrower than stated.**

### Cannot be told from the folder

**8. `checks.md` 665-668 (entry for `review-documents-16.md`).** "No statement they added or altered was wrong. The old phrase was still in one paragraph of the README and in seven comments, and two corrected statements had lost a qualification they needed"

- What that review found cannot be checked; the hand-back is not in the copy.
- The numbers do agree with the diffs: the old phrase goes from one README paragraph (295-297) and from seven comments (`src/backdoor.rs` 230; `src/watch.rs` 862-863, 1339-1340, 1531, 3147-3148, 4922-4924, 5127-5128).
- The same holds for what every other entry says a review found.

## Checked and found true

**The halt that cannot be put right**
- No observer looks: `turn` returns at `src/watch.rs` 1350 before `watch` at 1420; only `tick` is sent (1347-1349, 2012-2016).
- Nothing asked is taken down: `ask` returns at 1532; `press` and `buy` refuse in any halt (1570, 1596).
- The state is left as it is by everything that can reach the game there:
  - a round does only `fit_kept`, `settle_books`, `settle_before` and the time (1334-1338), none of which touch the spider, the world, what the game keeps, the observers or the record;
  - `set_how` and `put_right` write only to the gate's own three places (1641-1651);
  - the backdoor refuses `push`/`pop` (`src/backdoor.rs` 232) and every field or copy write (276) before anything is written, refuses `during` in any halt (132), and `cut_down` does nothing (`src/watch.rs` 865).
- The whole game is replaced by the click (`put_right`, then `begin_again` in the next round, 1343-1345) and by a counted stop (`stopped` then `fail`, 596-597). The page posts `/right` only from the button (`page.html` 450).
- The gate still compares its places (1336-1337), the time still moves (1338), and the halt ends only on asking (`mend` returns at 1269-1270; `stick` and `fail` clear `asked`).

**The comments in `comments.diff`**
- `src/backdoor.rs` 230, and `src/watch.rs` 706-708 (with "until it is asked for"), 862-863, 1339-1340, 1531, 3147-3148 and 4922-4924 are each true of the code; the tests behind the last two pass.
- 5127-5128 is true but for finding 3.

**`checks.md` 157-158.** "which the rounds leave as it is until it is asked for" is true.
- It is asserted over 600 rounds on a game put aside by calling `fail` directly (`src/watch.rs` 3152-3162).
- The test with two stops asserts only the halt, the counts and the beginning again (4579-4584).
- The two meet at `stopped` calling `fail` (596-597).

**`checks.md` 622-623.** "said" fits: neither a round nor a line now cuts the state in such a halt (`src/watch.rs` 1341-1355, 865).

**The counts agree in every place.**
- The list in `checks.md` has four reviews, ten `review-change` entries (unnumbered, then 2 to 10) and sixteen `review-documents` entries (unnumbered, then 2 to 16).
- That gives twenty-six checks and thirty hand-backs, the kit's ring map not being kept.
- These match `README.md` 485, 492 and 494 and `checks.md` 387, 427 and 683. No other document gives these counts.
- The pairing in `checks.md` 428-433 fits the entry for the sixteenth.

## Not checked
- What any review found: the `test/review-*.md` files are left out of the copy by design.
- Anything by running the program or the page; I read `page.html` only for the button.
- That a stop at the backdoor is caught is from reading `src/main.rs` 588-591; no test covers it.
