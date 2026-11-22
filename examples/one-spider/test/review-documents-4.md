# Hand-back: the documents of One Spider against the code in `check-four/docs/now`

Three statements are wrong, nine are narrower than stated, and three cannot be told from the folder. Everything else the diff adds or alters I traced to code and found true. All six documents and every `//!` head comment were read in full; `page.html` and the bodies of the `drive.js` plans were not.

## Wrong

**W1. `src/watch.rs` lines 40-42 (head comment)**
- Statement: "What is asked of the game from outside, by the pointer or at the shop, is taken down twice as it arrives. The gate compares the two. The round's work takes in one of them, and the second doing of the work takes in the other."
- Code: it is taken down three times, in `asks`, `asks_again` and `asks_third` (`watch.rs:371-373`, written at `1216`). The gate compares the three (`watch.rs:647`), and one that differs is put right from the other two (`watch.rs:939-947`).
- The comment is the side that is wrong. Lines 44-45 of the same comment name only `rules.rs`, though a round is held to both texts (`watch.rs:753-759`).

**W2. `gameplay.md` lines 98-102; also `observation.md` lines 258-264 and `src/rules.rs` lines 9-12 (head comment)**
- Statement (`gameplay.md`): "Those the rules hold the work to are stated twice in the program: once in the work, in `src/game.rs`, and once in the rules, in `src/rules.rs` ... One of those that a rule holds exactly, changed in one place and not the other, halts the game."
- Statement (`observation.md`): "So one of those numbers that a rule holds the work to exactly has to be changed in both places, and until it is, the game halts."
- Statement (`rules.rs`): "So a number of the game that is changed has to be changed in both places".
- Code: such a number is now stated four times. `LIFE`, for one, is at `game.rs:46`, `game/again.rs:57`, `rules.rs:30` and `rules/again.rs:38`.
- Changed in "both places" only (`game.rs` and `rules.rs`), the game still halts: the second doing (`watch.rs:790-792`) and the second text of the rules (`watch.rs:758-759`) still hold the old number.
- These were true before the change and are no longer. The documents are the side that is wrong.

**W3. `checks.md` lines 61-63**
- Statement: "Where it says below that something is tried under each way a halt can end, three of the tests wait the pause out."
- Code: four of the tests so described wait the pause out.
  - the wrong step (`watch.rs:2825`, `AfterAPause => play 40`)
  - what the gate wrote out (`watch.rs:3291-3293`, asks only on a click)
  - the reason with no flag (`watch.rs:3424-3426`)
  - the new one, the observer that stops answering (`checks.md:197`; `watch.rs:4231-4233`, asks only on a click)
- The passage at `checks.md:175-176` ("the other two settings", `watch.rs:3896-3901`) waits it out as well.
- The second sentence of the passage, about the two tests on the gate's copy, is still true (`watch.rs:3184`, `3221`).

## Narrower than stated

**N1. The round's wait for answers: `observation.md` lines 53-57, `README.md` lines 184-186, `outside.md` line 32**
- Statement (`observation.md`): "Anything else that arrives is waited through, no more often than there are observers, so the longest the round can be made to wait is 24 waits, 120 thousandths of a second."
- Statement (`README.md`): "eight waits ... with no answer at the most, and one more for each thing that arrives, 120 thousandths at the very most".
- Statement (`outside.md`): "the wait for the observers' answers, each round | 8 waits ...; 24 waits at the very most".
- The bound is for one asking, not for one round. A round in which a halt is put right asks twice: once in `watch` (`watch.rs:583`) and again in `correct`, for the eight new observers (`watch.rs:862`). Such a round can wait twice as long: 16 waits with nothing arriving.
- Inside one asking, the loop is `while waiting > 0 && waits < most && others <= running.len()` (`watch.rs:1629`).
  - "Anything else" is waited through up to nine times, one more than there are observers.
  - The most receives in one asking is 23, not 24 (7 + 7 + 8, and one more of any kind ends it).
- As an upper bound for one asking, 24 holds.
- The 5 thousandths is what `recv_timeout` is asked for (`watch.rs:1630`); how long one such wait really lasts is the operating system's, and cannot be told from the folder.

**N2. `observation.md` lines 167-168**
- Statement: "If a new observer does not answer, it has not looked: the halt is not ended, and the next round starts eight more."
- This is true set to end at once, or once the halt has been asked to end.
- Set to end after a pause, it is false when putting right changed the state. `correct` has put the part back, so in the next round `mend` finds the state changed since it last looked and starts the 0.6 seconds again (`watch.rs:973-986`).
- I ran this with a temporary test: a pause, `spider.body.x += 150`, and `stall_next(5)`. The halt came in round 0, eight new observers were started in round 37 with one silent, and the next eight were started in round 75.
- The existing test covers "at once" only (`watch.rs:4154`).

**N3. `observation.md` lines 206-208; `src/game/again.rs` lines 4-5 and 11-13 (head comment)**
- Statement: "every function of the work and every number it uses is written out a second time in `src/game/again.rs`".
- Statement (`again.rs`): "What the two still share: what the parts are, how each is written out, and how a number is drawn from chance."
- Code: both doings call the same methods of `Own`, which exist once, in `game.rs`.
  - `Own::point` (`game.rs:373-380`), called at `again.rs:124` and `126`. It uses `W` and `H` (`game.rs:16-17`) and `DRAGS` (`game.rs:40`), none of which is in `again.rs`.
  - `Own::click` (`game.rs:382-386`, with its limit of eight), called at `again.rs:129`.
  - `Own::gain` (`game.rs:326-329`), called at `again.rs:463` and `476`.
  - `Own::held` (`game.rs:332-337`), called at `again.rs:745` and `757`.
- A change to any of these is made in both doings at once and is not found by their disagreeing.
- The other direction is true: all 34 functions and 24 numbers of `again.rs` are in `game.rs` word for word. I checked this with a script of my own as well as reading the test.

**N4. `README.md` line 261; `observation.md` lines 400-401**
- Statement: "So the machine's clock decides how long one round is, and nothing else." / "That is all it decides."
- Two other things are taken from a clock.
  - Chance is seeded from the system's time at the start (`main.rs:183`).
  - After a stop in the wrong place, `Game::fail` is given the clock's reading (`main.rs:97`, `313`). That reading becomes the new game's own time and its seed (`watch.rs:694`, `Book::new` at `317`).
- In play from round to round the statement holds: `round_at` (`watch.rs:1002-1009`) and the pointer and press times (`main.rs:555`, `574`) use the game's own time.

**N5. `README.md` lines 229-231**
- Statement: "In a halt that cannot be put right, nothing at all is done with the game: nothing looks at it, nothing is written to it ..."
- Code: before the round returns for such a halt (`watch.rs:1031-1041`), the gate still compares and puts right its three places and the kept state, and still moves the game's own time on (`watch.rs:1026-1028`; `at` is written at `1006`).
- The state, the observers and the record are not touched, and nothing is taken down (`watch.rs:1212`); that part is true.

**N6. `observation.md` lines 66-67; `src/watch/looks.rs` lines 6-7 (head comment)**
- Statement: "a test holds the eight to one another on every kind of fault the tests know".
- Code: the test uses 19 lines at the backdoor and 4 direct faults (`watch.rs:3765-3786`), on two games, with three more games untouched.
- `checks.md:206` says it as it is: "some twenty faults".
- "a test here" in `looks.rs`: the test is in `watch.rs`.

**N7. `checks.md` lines 110-111**
- Statement: "Two lists changed each another way: all three must be put aside, the pointer made to let go, and nothing bought."
- Code: neither test of this asserts that nothing is bought (`watch.rs:3705-3711`, `4416-4422`). They assert what is said to have been done, that the pointer let go, and that the lists are empty afterwards.
- The program does put all three aside (`watch.rs:951-953`); the gap is in the test, not in the program.

**N8. `checks.md` lines 368-370**
- Statement: "For each of the four the program was changed to do what the documents said".
- One of the four is "that an observer wrote and checked its own signal". In the code an observer checks its own last signal (`looks.rs:43`), but does not write it: the round's thread writes `beat` when the answer comes (`watch.rs:590-591`).
- `observation.md:100-102` says it as the code does.
- What the earlier documents said is not in the folder, so I can tell no more than this.

**N9. `observation.md` lines 208-210; `README.md` line 265**
- Statement: "Every function of the second text begins with that text's mark, so that the program as built holds two of each and not one".
- The marks are there: 34 of 34 in the work, 9 of 9 in the rules.
- What the program checks at its start is the eight rules, four pairs of the work and two pairs of the rules (`watch.rs:1424-1434`), as `observation.md:384-388` says.
- Whether the built program holds two of every other function cannot be told from the folder.

## Cannot be told from the folder

**C1. `README.md` lines 189-190**
- Statement: "the longest was 11 thousandths and one round used one wait".
- Code: it measures the most waits any one round used and the longest wait (`watch.rs:1651-1653`, printed at `4286`). It does not measure how many rounds used a wait.
- "The most any round used was one" is what the code can produce.
- "no round used one of its waits" (line 188) and the two longest waits are of a kind the code prints.

**C2. That the 72 tests, the 55 limits checks and the eleven plans all pass (`README.md` line 488)**
- I ran two named tests only, and neither the limits nor the plans.

**C3. Other things on the author's authority**
- "Built with Rust 1.98".
- The order of the review files (`checks.md:329-331`).
- The picture itself.

## Checked and found true

**The picture (`README.md` lines 25-31)**
- `spider.body.size *= 2` changes only the body's part.
- The first flagged observer by number is `legs A`, which looks at the body third and says "the legs A observer found the body changed" (`looks.rs:60`; `watch.rs:603`).
- What is said to have been done would read "the body put back, all eight observers started again" (`watch.rs:904`, `855`).
- Only the close spiral holds a moth, and it is laid from the outside inward (`game.rs:626-628`, `676-690`); `strand_of` takes the first such strand (`game.rs:692-699`).
- So the three sentences could be true.

**Counts**

| What | Found | Documents |
| --- | --- | --- |
| Tests in `watch.rs` | 72 `#[test]` | 72 (`README.md` twice) |
| Checks in `limits.js` | 55 run: 41 places where `check(` is called, four of them in loops that run 5, 5, 5 and 3 times (lines 63, 73, 80, 218) | 55 |
| Plans in `drive.js` | 11, with the same names as `checks.md:265-266` | eleven |
| `game/again.rs` | 34 functions and the mark `second`; 24 constants, and one `const N` inside `web_plan` | 34 and 24 |
| `rules/again.rs` | 9 functions and `second`; 14 constants; `rules.rs` has the same 9 and 14 | 9 and 14 |
| `watch/looks.rs` | 8 copies of the rule and `all_apart` | eight |
| `OWN_FAULTS` | 24, touching every field of `Book` | 24 |

- The eight copies of the rule are the same text but for name and mark (script).

**Named tests run**
- `left_alone_for_half_an_hour_it_never_halts` prints 459 caught, 128,894 hundredths gained, 10 + 9 + 18 + 20 = 57 upgrades and spider no. 7. This is what `gameplay.md:104-106` says.

**Other changed lines**
- The five ways a halt cannot be put right match the five places `stick` or `fail` is reached.
- The port must be digits, not 0, with nothing after it (`main.rs:168-177`).
- The second observer of the same starting stops the program (`main.rs:269-293`).
- The start check is as said (`main.rs:180`).
- The clock test, the six values of the round's number, the three stretches, the ten lines and the five kinds of write are as said.
- Both trials in `checks.md:225-229` are things the code could do.

**The README's move of the scope**
- The three old passages are in "The scope" with nothing lost and nothing said twice by the move.
- Every reference by name leads to a section that exists: "Where it ends", "How a halt ends", "What is established", "What is not observed", "Checking the work", "Making the work go wrong", and `#the-scope`.

**The documents against each other**
- The numbers agree: 72, 55, eleven, five seconds, 0.6 seconds, 8 and 24 waits and 120 thousandths, nine hand-backs, five checks, 17,136, 2.70.

**Documents with nothing against them**
- `backdoor.md`: no findings.
- `outside.md`: line 32 only (N1).
- Head comments of `main.rs`, `game.rs`, `backdoor.rs` and `rules/again.rs`: no findings.

## What I read, and what I did not reach

**Read in full**
- All six documents and `documents.diff`.
- `src/main.rs`, `src/game.rs`, `src/backdoor.rs`, `src/watch/looks.rs`.
- `src/watch.rs` lines 1-1987 and 3502-4504, and the tests at 2135-2195, 2825-2849, 3122-3192, 3209-3249 and 3278-3455.
- `test/wiring.py`.

**Read in part**
- `src/game/again.rs` and `src/rules/again.rs`: heads, lists of functions and constants, `take_in`; compared with the first texts by script.
- `src/rules.rs`: head and constants only.
- `test/limits.js`: every `check(` and every loop.
- `test/drive.js`: the plan names only.

**Not reached**
- `page.html`. Statements about what the page shows or does are unchecked this time.
- The bodies of the `drive.js` plans.
- The tests in `watch.rs` lines 1989-3500 outside the ranges above. For the older passages of `checks.md` (the pointer, the lives, the shop, the counts "some fifty", "nine changes", "33 things") I checked only that 11 + 6 lines are in the second-doing test.
- Statements about what the reviews found, as the brief says.
- The older, unchanged lines of the documents were read through once for what the change could have made untrue (that gave W2 and W3), not re-traced line by line.

**What I did in the folder**
- I added one temporary test to `now/src/watch.rs` to settle N2, then put the file back; its SHA-256 is the same as before, and it has 72 tests.
- `cargo` left its build in `now/target/`.
- I did not start the program, and sent nothing to port 8138.

**Outside the brief's item 5, in one line:** three `///` comments inside `watch.rs` are stale the same way as W1: line 264 ("besides its record and the number of the round", though `rounds` is in `Book`), lines 1203-1205 ("compares the two", "Neither list"), and the test comment at 4456.
