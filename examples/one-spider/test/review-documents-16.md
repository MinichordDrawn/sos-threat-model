No statement that the two diffs add or alter is wrong of the code, but the old phrase is still in the README's "How a halt ends" paragraph and in seven comments, and two of the corrected statements are now looser than the code.

Everything was settled by reading `now/`. I ran no test and did not run the program. Nothing stopped me from checking anything except what is listed under "Cannot be told from the folder".

## Wrong

None.

## Narrower than stated

**1. README.md:294-296, left behind (not in the diff).**
- Statement: "Nothing at all is then done to the game's state until "Put it right" is clicked, a stop in the wrong place apart, and that click begins the game again."
- This is the paragraph under the heading "### How a halt ends". The brief says the phrase is no longer said there. The README hunk of `documents.diff` changed a different paragraph: the last one under "### One round" (README.md:229-234).
- With its hedge the sentence is not false of the code: every stop is excepted, and the click does begin the game again (`put_right`, src/watch.rs:1644-1650; `turn`, src/watch.rs:1340-1344).
- It is the old wording, though, so the README now says this in two forms.
- It also makes checks.md:663-664 narrower than stated: "Each is corrected: the sentence is taken out, and the statement is now of what a round and what is asked of the game do in such a halt." That holds at README.md:230-232, observation.md:357-358 and the `///` on `stuck` (src/watch.rs:706-707), but not here or in the comments of finding 2.

**2. Seven comments still carry the old phrase, unhedged (none is in `comments.diff`).**
- What the code does in each case: a stop in a round or in a request other than a backdoor line, during such a halt, replaces the whole game. `stopped` goes to `fail` when `self.stuck()` (src/watch.rs:596-598); `fail` does `*self = game` with a new game (src/watch.rs:941-956). It is reached from src/main.rs:322-340 for a round and src/main.rs:98-107 for a request.
- The places:
  - src/watch.rs:1339, in `turn`: "Until then nothing at all is done to the game's state: it is not worked, and no observer looks at it."
  - src/watch.rs:1530, in `ask`: "In a halt that cannot be put right nothing at all is done to the game, and nothing is taken down."
  - src/backdoor.rs:230: "In a halt that cannot be put right nothing at all is done to the game: nothing is written to it."
  - src/watch.rs:861-862, `///` on `cut_down`: "Not in a halt that cannot be put right, where nothing is done to the game's state."
  - src/watch.rs:3147, test comment: "What stands in its place is a game not yet begun, halted, and nothing at all is done to it."
  - src/watch.rs:4921, test comment: "In a halt that cannot be put right nothing is done to the game's state, and the cutting down keeps to that".
  - src/watch.rs:5126, test comment: "In a halt that cannot be put right nothing at all is done to the game, and no observer looks."
- The two that say "to the game" (1530, backdoor.rs:230) and 5126 are wider still. In such a halt the gate's own is still compared and written (src/watch.rs:1333-1337), the game's time moves, and `set_how` and `put_right` write to the book (src/watch.rs:1640-1650).

**3. README.md:230-232 (altered). The correction took a true qualification away here.**
- Statement: "In a halt that cannot be put right, no observer looks at the game's state, nothing is written to it, and nothing asked of it is taken down."
- "No observer looks" and "nothing asked of it is taken down" hold without exception (see the list at the end).
- "Nothing is written to it" has two exceptions in the code, and the sentence now names neither:
  - once it is asked for, the round of such a halt begins the game again and replaces the whole state (src/watch.rs:1340-1344, `begin_again` 1619-1634);
  - a stop in a round or a non-backdoor request puts the game aside whole (references in finding 2).
- Before the correction the next sentence named the stop. It was the sentence taken out. observation.md:357-360 carries both exceptions; README.md:294-296 carries both in the old wording.
- This is the only place where a correction left a statement looser than it was.

**4. src/watch.rs:706-707, `///` on `stuck` (altered).**
- Statement: "Then no round and nothing asked of the game does anything to its state."
- The round of such a halt that finds `halt.asked` calls `begin_again` (src/watch.rs:1342-1344), which replaces the state whole.
- observation.md:357 has "until it is asked for"; this comment does not. The stop is covered by its reference to `stopped`.

**5. observation.md:347-351, same statement elsewhere (not in the diff).**
- Statement: "the program itself stops where it should not have while it has hold of the game (in Rust, a panic), twice with no round between … Once, and not in a halt that already cannot be put right, that is a halt like any other".
- The exception the corrected sentence at observation.md:358-360 now gives for such a halt, "a request other than a line at the backdoor", applies here in the same way, and is not said.
- A stop while a backdoor line is being done has hold of the game, is caught at src/main.rs:588-591, is never told to the game (`stopped` is not called, `stops` is not counted), and is neither a halt nor one of the two.
- outside.md:65-67 has this right.
- outside.md:67-70 says less than the corrected sentence, without contradicting it: it names a stop "while the game's own work is being done" only. The code treats a stop in any request but a backdoor line the same way (src/main.rs:98-107).

## Cannot be told from the folder

- What `review-documents-14.md` and `review-documents-15.md` found (checks.md:654-664), and which model any check ran on (README.md:493, checks.md:679). The hand-backs are left out of the copy on purpose.
- That twenty-nine hand-backs are in `test` (README.md:491). The copy's `test` has only `drive.js`, `limits.js` and `wiring.py`.

## Checked and found true of the code

**Counts.** They agree in every place they are given.
- README.md:484 (ten and fifteen), 491 (twenty-nine), 493 (twenty-five); checks.md:387, 427 and 679 (twenty-five).
- The list in checks.md has four reviews, ten `review-change*` entries and fifteen `review-documents*` entries: 25 checks, 29 hand-backs.
- checks.md:427-433 adds up: three, then nine pairs, then `review-documents-12` to `-15` is 25. The entries for 13, 14 and 15 each say "of the corrections the … led to, and of nothing else".
- No other document, comment or the page gives these counts.

**observation.md:357-358**, "until it is asked for, no round and nothing asked of the game does anything to the game's state".
- A round of such a halt returns at src/watch.rs:1340-1350. Before that it touches only what the gate keeps (`fit_kept`, `settle_books`, `settle_before`, the time: 1333-1337).
- `ask` returns at 1531-1533; `press` (1569), `buy` (1595) and `during` (1604) need no halt at all.

**observation.md:358-360**, "A stop in the wrong place during such a halt, in a round or in a request other than a line at the backdoor, puts the game aside whole".
- Round: src/main.rs:322-332 calls `stopped`, which calls `fail` (src/watch.rs:596-598).
- Request: the handlers at src/main.rs:574-626 hold the lock with no catch. A stop poisons it, and the next taking of the game calls `stopped` (src/main.rs:98-107).
- Backdoor line: caught at src/main.rs:588-591 with the lock unpoisoned. In such a halt a line writes nothing: `cut_down` skips (src/watch.rs:863-867), `during` is refused (src/backdoor.rs:132-134), writes are refused (232-234, 276-278), and `read` takes the game unchangeably (504). So the game is as it was, as checks.md:661-662 says.

**README.md:232-234.**
- The gate still compares: `settle_books` and `settle_before`, src/watch.rs:1335-1336.
- The game's time still moves: 1313 and 1337.
- The observers are told only that the rounds go on: `tick`, 1346-1348.

**backdoor.md:75-77**, "It still reads, unless one of those two counts is wrong as well: that lasts for as long as that game does".
- The count check comes before any read (src/backdoor.rs:225-227).
- In such a halt nothing reaches `right_counts` or replaces the observers: `turn` returns before src/watch.rs:1356, and `mend` returns at 1268-1270.
- Only a new game has the counts right: `begin_again`, or `fail` after a stop, both through `Game::new` (src/watch.rs:657) and `copies_for` (250-252).
- The old wording, "which nothing puts right in such a halt", was wrong for the stop. The new wording is right.
- One thing to know: after `fail` the count of games shown is unchanged (src/watch.rs:949), though the game is another.

**src/backdoor.rs:220-224.**
- A round puts the number of observers right at src/watch.rs:1356, after the return for such a halt at 1340-1350.
- Eight new observers come in `correct` (1137-1141; `START` at 78 has all eight), with copies from a record whose count `restore` has put right first (1197).
- A new game has both right.

**src/main.rs:109-113.** `admit` returns false only when no place is held by anything but a screen (114-128).

**test/limits.js:183.** `Shared::screen` puts out the first of the list, the one sent longest, and then takes the new one (src/main.rs:148-163).
