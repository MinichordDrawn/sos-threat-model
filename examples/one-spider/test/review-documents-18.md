**Nothing the two diffs add or alter is wrong of the code. Three statements are narrower than stated, one of them a place left behind; the counts agree everywhere; no correction made a right statement wrong.**

All paths below are under `«WORK»\check-twelve-g\docs\now\`.

## Wrong

None.

## Narrower than stated

**1. `checks.md:198-199` — left behind (not in the diff; the same statement as the corrected test comment).**
- Statement: "Five kinds of write in a halt that cannot be put right, which the backdoor must refuse, while it still reads."
- The test comment it describes (`src/watch.rs:5128-5129`) now says "still reads while its two counts are right", and `backdoor.md:75-76` says "It still reads, unless one of those two counts is wrong as well". This line still has no condition.
- Code: `src/backdoor.rs:225-227` refuses every read and write (all but `help` and `?`, lines 217-219) while the number of observers, or of any observer's copies, is wrong. In such a halt a round returns at `src/watch.rs:1342-1352`, before `right_counts` at 1358, so nothing puts the count right until the game is begun again.
- As an account of what the test asks it is true of the test, which has both counts right (`src/watch.rs:5130-5137`: five lines refused, one read answered).

**2. `src/main.rs:97-98` and `src/watch.rs:594-595` — added by `comments.diff`.**
- Statements: "A line at the backdoor that stops as it is run is caught where it is run, and the game is not told of that." and "A line at the backdoor that stops as it is run is caught there, and this is not told of it."
- True of a line run on arrival: `src/main.rs:589-592` holds the game and runs `backdoor::run` inside `catch_unwind`. The stop is caught with the lock still held, so the lock is not poisoned and `Shared::game` (`src/main.rs:99-108`) never calls `stopped` for it.
- Not true of a line kept with `during` when it is written in the next round's work: `src/watch.rs:1480` calls `backdoor::write_now` inside the round. A stop there is caught by `play` at `src/main.rs:323`, and `game.stopped(...)` is called at `src/main.rs:333`.
- `observation.md:355-357` carries the qualification ("a line that has just arrived at the backdoor"); the two comments do not. They are exact only if "run" is read as the function `backdoor::run`.

**3. `checks.md:629-630` — altered by `documents.diff`.**
- Statement: "It found that in a halt that cannot be put right no round, no request and no line at the backdoor changes the state".
- "no line at the backdoor" holds without exception:
  - nothing is cut there (`src/watch.rs:865-869`);
  - every write is refused (`src/backdoor.rs:232-234`, `276-278`);
  - a `during` line is refused in any halt (`src/backdoor.rs:132-134`);
  - a stop is caught (`src/main.rs:591`).
- "no round, no request" holds only with two qualifications that the same statement carries elsewhere (`observation.md:359-362`, `src/watch.rs:707-709`, `checks.md:158`):
  - Until it is asked for: the `/right` request sets `asked` (`src/main.rs:624-625`, `src/watch.rs:1646-1651`), and the next round begins the game again (`src/watch.rs:1344-1345`, `1621-1636`).
  - A stop in the wrong place in a round, or in a request other than a backdoor line, puts the game aside whole (`src/watch.rs:597-598`, `943-957`, reached from `src/main.rs:104` and `333`).
- The line it replaced ("nothing is done to the state") was unqualified in the same way, so the correction did not make it worse. Whether the review found this is in the next section.

## Cannot be told from the folder

- **`checks.md:629-630`** — that `review-change-10.md` found what the entry says. The hand-back is not in the folder.
- **`checks.md:669-673`** — what `review-documents-17.md` found ("Nothing they said was false of the program as it was meant", "three places had been left"). The diffs do correct one sentence moved in `observation.md`, the README's two passages on a stop, and then one list entry, one test comment and two comments (`stopped` and `game()`), which is three places only if the two comments are counted as one.

## Checked and true of the code

- **`README.md:71`, "No work is done in between."** While halted, a round returns before the work (`src/watch.rs:1447-1452`; in a halt that cannot be put right at 1342-1352). The work at 1465-1469 is reached only with no halt, or in the round where a halt set to end at once has just been put right. Lines kept for the work are dropped when a halt begins (`src/watch.rs:932`).
- **`README.md:231-232`, "A round leaves it as it is until the game is begun again."** In such a halt a round does only this:
  - cuts and compares what the gate keeps (`src/watch.rs:1335-1338`);
  - moves the game's time (1339);
  - begins the game again if asked (1344-1345);
  - tells the observers the rounds go on (1348-1350).
  
  It does not touch the spider, the world, what the game keeps for itself, or the observers.
- **`README.md:294-296`, "A round then leaves the game's state as it is until "Put it right" is clicked, and that click begins the game again."**
  - `mend` returns at once in such a halt (`src/watch.rs:1270-1272`), so none of the three settings ends it.
  - The button is shown whenever the halt is of this kind and posts `/right` (`page.html:380-381`, `450`).
  - A click made before the halt came to this is dropped (`src/watch.rs:967`; `asked: false` at 955).
- **Both README sentences are true as statements of what a round does.** A round that itself stops in such a halt is dealt with by `stopped`, then `fail`, which the README no longer speaks of and `observation.md:360-362` does. Taking the stop out of the README made nothing wrong.
- **`observation.md:349-357`.** The moved sentence is true: a stop in a line that has just arrived is caught at `src/main.rs:591`, the answer is "that line could not be done: the backdoor stopped where it should not have", and no halt, count of stops or putting aside follows. The build has no `panic = "abort"` (`Cargo.toml`). With the sentence moved, "Once, and not in a halt that already cannot be put right" again reads of the program's stop, which is what `src/watch.rs:596-614` does. `outside.md:65-67` says the same of the backdoor and agrees.
- **`src/watch.rs:5128-5129` (test comment).** True: every write is refused in such a halt, and a read is answered unless one of the two counts is wrong (`src/backdoor.rs:225-227`). The named test passes on this copy.
- **Counts.** They agree in every place they are given:
  - seventeen checks of the documents (`README.md:484`): `checks.md` lists `review-documents.md` and `-2` to `-17`;
  - ten checks of changes (`README.md:484`): `review-change.md` and `-2` to `-10`;
  - twenty-seven checks (`README.md:493`, `checks.md:387`, `427`, `688`);
  - thirty-one hand-backs (`README.md:491`): four reviews and twenty-seven checks.
  
  No other document, comment, the page or the test scripts gives these counts. The old numbers (sixteen, twenty-six, thirty) are nowhere left as counts of reviews.
- **Other places.** No other place in the six documents or the comments still says that a stop replaces the game in the README's sense, or says "Nothing is done in between".

## What was run, and what was not checked

- Run, from the copy, in the foreground: `cargo test --release --target-dir <now>/target -- --test-threads=2 nothing_is_written_in_a_halt_that_cannot_be_put_right`. Result: 1 passed, 83 filtered out. The build left a `target` folder inside `now/`.
- The program itself was not run, and nothing was sent to any running copy.
- No test in the folder exercises the catch at `src/main.rs:591` (`main.rs` has no tests), so that a backdoor stop is caught and does not poison the lock rests on reading the code.
- One search returned more than the tool showed and offered a results file outside the folder. I did not open it; I narrowed the search instead.
