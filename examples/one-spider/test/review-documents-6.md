# Hand-back: the six documents and the source comments against the code in `check-six\docs\now`

Two statements are wrong, both small and both left by the latest change; nine more are narrower than stated. Everything else I checked on the changed lines holds, including every count.

One thing to know first: an early shell command of mine tried to write scratch files to `/tmp`, outside the folder. The permission system refused it and nothing was written. I did that comparison again without files.

## Wrong

**1. An observer no longer looks at its own signal first.**
- `README.md:205`: "Each checks first that its own last signal is the round before's."
- `observation.md:104-105`: "Before it looks at anything else, an observer checks that its own last signal is the round before's."
- `src/watch.rs:22-23` (`//!`): "It looks at its own last signal first."
- Code: every copy of the rule checks `look.ring.len() != NAMES.len()` before `me.beat != look.last` (`src/watch/looks.rs:43-49`, and the same lines in the other seven copies).
- The documents disagree with each other here: `src/watch/looks.rs:10-11` says "looks first at whether it has been given eight observers to look at, and then at its own last signal", which is what the code does.
- The documents are the side that is wrong. The plain comment at `src/watch.rs:655-656` ("each looks at its own first") is left over the same way.

**2. A sentence about the program now reads as part of the design note.**
- `observation.md:177-179`: "That is in the next round, but for one case: where halts end after a pause, this one has not been asked to end, and the first try put a part of the state back, the pause is waited out again first."
- The diff put the new note (`observation.md:174-176`, "A finer one is possible, and is not built here…") between this sentence and what it referred to at `observation.md:170-172`, and ran the two together in one paragraph.
- As it stands, "That" is the finer repair that is not built.
- The sentence itself is true of the retry with eight more observers (`src/watch.rs:945-962`, `1072-1086`). Only its place is wrong.

## Narrower than stated

**3. "Twice with no round recorded between" is no longer the whole condition.**
- `outside.md:66-68`: "that is once a halt like any other, and twice with no round recorded between, or once in a halt that already cannot be put right, a halt that cannot be put right".
- `src/watch.rs:306` (`///` on `Book.stops`): "since a round was last recorded".
- `src/watch.rs:534-535` (`///` on `stopped`): "If it happens again before a round has been recorded".
- `src/watch.rs:769-770` (`///` on `fail`): "a second time with no round recorded between".
- Code: `stops` is cleared only by a recorded round that began with nothing halted (`src/watch.rs:1196`, `1264-1268`).
- The case: halts set to end at once, a stop, the next round puts it right and is worked and recorded, then a second stop. A round was recorded between, and the game is still put aside. The test at `src/watch.rs:3831-3846` does exactly this, and passes.
- `observation.md:312-314` and `checks.md:150-151` state it correctly, so the documents also disagree with each other.
- Plain comments left over the same way: `src/main.rs:327-328`, `src/watch.rs:3905-3906`, `3927`.

**4. "120 faults" counts list entries, not distinct faults.**
- `observation.md:67-68`, `checks.md:218-221`, `src/watch/looks.rs:6-7`.
- The test (`src/watch.rs:4064-4124`) has 9 backdoor names × 10 kinds = 90, plus 21 lines, plus 9 direct faults: 120 entries.
- `spider.ring[3]` and `world.ring[3]` are the same observer, so 10 of the 90 repeat another 10. Nine of the 21 lines repeat one of the 90 exactly.
- Distinct faults: 80 + 12 + 9 = 101.
- "Every kind of thing that can go wrong in an observer, in each of the eight" holds: 10 kinds covering all seven fields, in all eight observers.

**5. The test counts the marks; it does not check where they are.**
- `checks.md:221-223`: "each function of the second must begin with its mark".
- The test counts lines of the form `    second("…");` and requires as many as there are functions (`src/watch.rs:3738-3739`, `3775`, `3783`). It checks neither that the mark is a function's first line nor that it carries that function's name.
- The name is tested only for the six entry functions (`src/watch.rs:3944-3955`).
- The code itself is as described: I checked all 40 and all 9 by script, and each begins with `second("<its own name>")`.

**6. The inset of the edge is not in `game/again.rs`.**
- `gameplay.md:98-101`: "Those the rules hold the work to are stated in the work and again in the rules, and each of those is written twice: in `src/game.rs` and `src/game/again.rs`".
- `INSET` is at `src/game.rs:18` and nowhere in `src/game/again.rs` (its 27 constants are at lines 36-127).
- `observation.md:277-278` already says "three for the inset of the edge".

**7. More than two things carry over when the game is begun again.**
- `observation.md:325-326` and `src/watch.rs:1388-1390` (`///` on `begin_again`): "Nothing of the old game is kept but the setting above and the count of how many games there have been."
- `begin_again` also carries the gate's note of what the clock last said (`src/watch.rs:1392`, `1398`) and the hold on the observers' threads (`1401`). The new game's own time goes on from the old (`1394`, with `320`).

**8. `round_at`'s comment leaves out the unreadable clock.**
- `src/watch.rs:1094-1096`: "How long the round is, is how long it has been since the last one".
- A clock that cannot be read gives `ROUND_LENGTH` (`src/watch.rs:562-566`). The comment on `length` says so; this one does not.

**9. Two tests now catch a stop as the program does.**
- `checks.md:158-159`: "from one of these tests, which catches it as the program does".
- `guarded` (`src/watch.rs:3790-3808`) is used at `3824` and at `3880-3889`.

**10. "The same under the other two settings" is one place on one game.**
- `checks.md:186-187`, after "in each of the three places".
- Under the other two settings the fault goes into `books[1]` only, on one game (`src/watch.rs:4212-4217`). This text predates the change.

**11. The head of `rules.rs` reads as if it were the second text (low confidence).**
- `src/rules.rs:1` (`//!`): "The rules of the game, written a second time."
- `rules.rs` is the first of the two texts; `src/rules/again.rs:1` is "The rules of the game, a second time." The line can be read as "the game stated again as rules", which is true.

## Cannot be told from the folder

- **`README.md:443`, "Built with Rust 1.98".** Nothing in the folder fixes a version. The toolchain here is `rustc 1.98.1`, and it builds.
- **`README.md:23-28`, the picture.** `one-spider.png` is not in the copy. What the note under it says followed is what the code gives for `spider.body.size *= 2`: `legs A` is the first to find the body changed, and what is said is "the body put back, all eight observers started again" (`src/watch/looks.rs:60-65`, `src/watch.rs:680-685`, `1004`, `944`).
- **`README.md:187-190`, the wait measurements (1.09 and 11 thousandths).** The code can produce them: `src/watch.rs:4626-4636` prints both figures.
- **"About five minutes"** (`README.md:460`, `checks.md:242`): not run.
- **Tests said to "now fail"** for the mutations reviews found (`checks.md:406-408`, `424-426`): not tried, since that means changing the code.
- **Outside the folder:** the model check's README (`README.md:119-120`), `../../LICENSE` (`README.md:545`), and `../../model-check`, which `test/wiring.py` needs (`checks.md:300`).
- **Not run:** `test/limits.js`, `test/drive.js`, `test/wiring.py`, the two trials in `checks.md:245-249`. The code is consistent with both trials (`src/main.rs:275-309`, `src/watch.rs:1801-1806`, `1708-1714`).

## Counts

| What | Counted | Documents | How counted |
| --- | --- | --- | --- |
| Tests in `src/watch.rs` | 75 | 75 (`README.md:460`, `506`) | `#[test]` attributes; the runs also report 75 in all |
| Checks in `test/limits.js` | 55 | 55 (`README.md:470`) | 41 call sites of `check(`; four sit in loops of 5, 5, 5 and 3 turns (lines 64, 79, 86, 224), adding 4+4+4+2 |
| Plans in `test/drive.js` | 11 | eleven, same names and order (`checks.md:285-286`) | keys of `plans`, lines 45-507 |
| `src/game/again.rs` | 40 functions, 27 constants | 40 and 27 (`checks.md:222`) | the mark `second` not counted; `N` inside `web_plan` not counted; test asserts `(40, 27, 40)` |
| `src/rules/again.rs` | 9 functions, 14 constants | 9 and 14 (`checks.md:229-230`) | `src/rules.rs` has the same 9 and 14 |
| `src/watch/looks.rs` | 9 functions | "eight times", "eight functions" | 8 copies of the rule and `all_apart`; the 8 bodies are identical with the mark number masked |
| `OWN_FAULTS` | 25 | 25 (`checks.md:183`) | `src/watch.rs:4153`; covers all 19 fields of `Book` |
| Faults in the eight-copies test | 120 entries, 101 distinct | 120 | see finding 4; 150 faulted games and 3 unfaulted, each looked at two ways by 8 copies as 8 observers |

Other numbers checked and right: 54 rule-breaking lines ("some fifty"), 11 that break no rule, 6 observer changes during the work, 9 changes at each of 2 instants, 5 refused writes, 6 values of the round number, 10 backdoor lines, 3 stretches, 30,000 rounds, 7 count faults × 3 instants × 3 settings, five ways a halt cannot be put right, 4+4+5 = 13 hand-backs and 9 checks.

## Changed lines checked and found true

- **22 waits, 110 thousandths** (`README.md:185`, `observation.md:56`, `outside.md:32`). The loop at `src/watch.rs:1724-1738` runs while `waiting > 0 && waits < 8 && others < 8`, and each turn moves exactly one of the three. That is 7+7+7 turns with the loop still live and one more to end it: 22 turns of at most 5 ms. The three documents agree.
- **The clock** (`README.md:259-268`, `observation.md:425-431`, `checks.md:198-204`). An unreadable clock gives 1/60 s and leaves the note alone (`src/watch.rs:562-566`, `1106-1109`). The game is told the clock at start (`src/main.rs:202`, `src/watch.rs:570-574`). The time of day gives the length, the seed and the time of a game put aside; `Instant` paces rounds and times waits (`src/main.rs:89-92`, `188`, `314`, `347`).
- **Lists emptied where the round is recorded** (`observation.md:200-201`; `src/watch.rs:907-912`).
- **Each observer's look at eight observers** (`observation.md:76-77`).
- **The marks and the start-up check** (`README.md:271-272`, `observation.md:222-225`, `408-410`, `outside.md:50-52`; `src/watch.rs:1517-1527`, `src/main.rs:185-187`).
- **Three places, or four** (`observation.md:276-283`).
- **"At once" unless a new observer does not answer** (`observation.md:355-357`; `src/watch.rs:954-962`).
- **"The game's state"** in a halt that cannot be put right (`README.md:229-233`, `294`; `observation.md:321`; `src/watch.rs:1134-1145`, `1305`).
- **The test descriptions** at `checks.md:147-158` and `221-232`, apart from findings 4, 5 and 9.
- **The design notes** (`README.md:290-291`, `392-395`; `observation.md:174-176`) claim nothing of the program, apart from finding 2.
- **`gameplay.md:106-108`**, reproduced exactly by the named test: 459 caught, 128,894 hundredths gained (1,289), 10+9+18+20 = 57 upgrades, spider no. 7.

Every reference from one section or document to another names a section that exists.

`page.html`: what `gameplay.md`, `backdoor.md`, `outside.md` and the README's "Running it" say the page shows and does is true of the page and of `shown()` (`src/watch.rs:1426-1502`). No findings.

`backdoor.md` has no findings.

## Two notes on the brief, not on the documents

- Change 5, "a count put right is said when a halt ends", holds after a stop and in putting right (`src/watch.rs:550-552`, `995-997`). A count found wrong by the gate's own look at the start of a round is put right there and only the reason is said (`src/watch.rs:1147-1151`; the test at `4340-4346` expects just "all eight observers started again"). No document claims more.
- The diff shows no change under the picture in the README. The design notes it adds are the three listed above.

## What I read, ran, and did not reach

- **Read in full:** all six documents and `documents.diff`; `src/watch.rs:1-1814`; `src/main.rs`; `src/game.rs`; `src/rules.rs`; `src/backdoor.rs`; `page.html`; `test/wiring.py`; `Cargo.toml`; the head and first copy of `src/watch/looks.rs`.
- **Read in part:** `src/game/again.rs` and `src/rules/again.rs` (heads, item lists and marks; for the bodies I rely on the two word-for-word tests, which I ran). The tests in `src/watch.rs`: every name, and in full lines 1815-2083, 2640-2988, 3598-4680. `test/limits.js` (every `check(` site and the loop tables). `test/drive.js` (head and plan names only).
- **Not reached:** the test bodies at `src/watch.rs:2084-2639`, `2989-3597` and `4680-4860`, so the older test descriptions in `checks.md:12-146` and `164-181` are checked only where listed above. The table of rules at `observation.md:261-270` was spot-checked against `src/rules.rs`, not rule by rule.
- **Ran:** ten named tests, all passing: the half hour, the stop that comes back, both word-for-word tests, the eight copies, both texts of the rules, the copies apart, the length of a round, the count inside a round, and the stop once and twice.
- **Did not run:** the program. Nothing was sent to any port and no process was stopped. The build is left in `now\target`.
