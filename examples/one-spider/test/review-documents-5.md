# Hand-back: the documents of One Spider against the code (check five)

All paths are inside `«WORK»\check-five\docs\now\` unless a full path is given.

Three statements are wrong, eleven are narrower than stated, and six cannot be told from the folder. Every changed line in `documents.diff` not listed below was found true of the code.

## Wrong

**W1. `observation.md` 55-57** (changed line): "Anything else that arrives is waited through, fewer times than there are observers, so the longest one asking can be made to wait is 24 waits, 120 thousandths of a second."
- `src/watch.rs` 1687-1701: the loop runs `while waiting > 0 && waits < most && others < running.len()`, and each pass is one `recv_timeout` of 5 ms.
- It ends at the first of eight waits with no answer, eight answers, or eight other things. So the most passes are 7 + 7 + 7 + 1 = 22, which is 110 thousandths.
- The sentence's own sum also falls short of 24: with "fewer than there are observers" it is 8 + 8 + 7 = 23.
- `README.md` 185-186 ("120 thousandths at the very most for one asking") and `outside.md` 32 ("24 waits at the very most for one asking") hold as bounds that are never reached. Only the `observation.md` sentence states 24 as the longest. The error is on the safe side.

**W2. `src/main.rs` 92-93**, the `///` on `Shared::game` (not one of the comments the brief names): "If the program stopped where it should not have while it had hold of the game, what is there is not gone on with: see `watch::Game::fail`."
- `src/main.rs` 99 calls `game.stopped(...)`, not `fail`.
- `src/watch.rs` 537-548: once, that is a halt like any other and the game is gone on with. Only a second stop with no round recorded between reaches `fail`.
- The comment is left over from before the change.
- The plain comment at `src/main.rs` 199 ("each on the clock kept here") is also left over. `clock()` at 84-89 is "counted from nothing that is kept here".

**W3. `observation.md` 67-68** (changed line) and `src/watch/looks.rs` 6-7: "a test holds the eight to one another on some twenty kinds of fault". `checks.md` 213-214 (changed line) says of the same test: "games with each of some twenty-five faults in them".
- `src/watch.rs` 3939-3969: the test has 21 lines at the backdoor and 6 faults put in directly, 27 in all.
- Each is put into two games, and three games with no fault are looked at too.
- The two documents give different numbers for one thing. `checks.md` is the nearer; `observation.md` and the head of `looks.rs` are the side that is off.

## Narrower than stated

**N1. `observation.md` 172-173** (changed line): "That is in the next round where halts end at once or this one has been asked to end, and after the pause otherwise."
- `src/watch.rs` 1042-1056: the pause starts again only if the parts of the state differ from what the halt last saw.
- So this is true only where the first try put back a part of the state. Where it put back none (an observer stopped, a fault in the record, a list or a place), the second try is the very next round.
- I ran this with a temporary test, halts set to end after a pause and one new observer answering nothing:
  - `spider.ring[0].alive = false`: observers started again in rounds 38 and 39, halt over in round 39.
  - `spider.body.x += 150`: started again in rounds 38 and 76, halt over in round 76, with "the body put back" still said.
- The comment at `src/watch.rs` 918-920 ("the next round puts everything right again, with eight more") is narrower the other way.

**N2. `README.md` 479-481** (changed line): "they found nine single faults ... Each is closed and is a test." Also `README.md` 518-520 (changed line): "What the last two checks led to is tested ... That includes ... the clock", and `checks.md` 421.
- The ninth fault, a change to the instant the clock was counted from, is closed by there being no such instant: `src/main.rs` 87-89 asks `SystemTime` each time.
- No test reaches `clock()` or anything in `main.rs`; all 74 tests are in `src/watch.rs`.
- What is tested is what the game does with whatever clock it is given (`src/watch.rs` 4233-4290), and that test was there before.

**N3. `checks.md` 217-218** (changed line): "What a second text takes from outside itself must be kinds of thing, and no function or number."
- `src/watch.rs` 3667-3672: the test looks only at `use` lines and lets by any line that begins `use std::`.
- `src/game/again.rs` 20 takes two numbers, `PI` and `TAU`.
- `src/game/again.rs` 381 calls a function outside itself through a kind it takes: `Val::Num(moth.id).written()`, which is `src/backdoor.rs` 50.
- That call is the "how each is written out" that the head of `again.rs` says is shared. What the test holds is narrower than the sentence.

**N4. `gameplay.md` 98-103** (changed lines): "each of those is written twice: in `src/game.rs` and `src/game/again.rs`, and in `src/rules.rs` and `src/rules/again.rs` ... changed in fewer than all four places, halts the game. A number no rule uses is in the two texts of the work, and has to be changed in both." The same is in `observation.md` 265-273 (changed lines) and `src/rules.rs` 9-13.
- The edge's inset is held exactly by a rule (`src/rules.rs` 89) and is in three places, not four: `src/game.rs` 18, `src/rules.rs` 25, `src/rules/again.rs` 35.
- It is not in `src/game/again.rs`: its only use in `game.rs` is `World::new` at 570, which is not part of the work.
- The numbers of how a game begins are in `game.rs` only, and no test holds them to anything. They are in `Spider::new` (`src/game.rs` 547-565), `World::new` (568-576) and `Own::new` (310-322): the first rest of 500, the first moth due after 1,500, starting full.

**N5. `README.md` 265-266** (changed line): "A clock is read for two things besides".
- This is true of the machine's time of day (`src/main.rs` 88, 185).
- The machine's other clock, `Instant`, is read as well:
  - to pace the rounds (`src/main.rs` 309, 342);
  - for every wait with a time (`src/watch.rs` 1689, 1750, and the server's);
  - for the measure at `src/watch.rs` 1665 and 1712.
- None of these is taken into the game.

**N6. `README.md` 290-291**: "Nothing at all is then done with the game until "Put it right" is clicked". Also `observation.md` 309-310: "until it is asked for, nothing at all is done with the game".
- `README.md` 229-233 was corrected by this change to say "the game's state", and that the gate still compares its places and the game's time still moves.
- That is what the code does: `src/watch.rs` 1096-1098, with 1074-1076 and 1107-1109.
- These two older places, and the comments at `src/watch.rs` 609 and 1099-1100, still say the wider thing. The documents now say it two ways.

**N7. `src/main.rs` 84-86**, the `///` on `clock`: "the game takes from it only how long it has been since it last asked".
- After a second stop, the game that waits to be begun takes its time and its seed from it: `src/watch.rs` 753-755, reached from `src/main.rs` 99, 325 and 329.
- `README.md` 265-266 and `observation.md` 416-418 say this correctly.

**N8. `src/watch.rs` 749-752**, the `///` on `fail`: it reads as what any stop in the wrong place does. `fail` is reached only:
- on a second stop with no round recorded between;
- on a stop while the game is already in a halt that cannot be put right (`src/watch.rs` 538);
- when what a screen is sent cannot be written after a stop (`src/main.rs` 326-330).

The second case also narrows "Once, that is a halt like any other" in the `///` on `stopped` (530-536), `observation.md` 302-305 and `outside.md` 66-68. A first stop in such a halt puts the game aside whole and replaces what `observation.md` 310-312 says is "left as they were found". That takes two faults.

The test at `src/watch.rs` 2833-2835 still carries the old name and comment (`a_stop_in_the_wrong_place_is_a_halt_that_begins_the_game_again`); it calls `fail` directly.

**N9. `src/watch.rs` 1548-1550**, the `///` on `Apart`: "takes them to have stopped, and does what it was given to do then: in the program, that stops the program."
- `src/main.rs` 270-285: the first observer to find it is only counted; the second of the same starting stops the program.
- `README.md` 193-195 and `observation.md` 336-337 say this correctly.

**N10. `README.md` 269-270 and `observation.md` 215-218** (changed lines): the mark "makes it another function than the first's in the program as built".
- The program checks this at its start for six functions only: four of the work and two of the rules (`src/watch.rs` 1484-1491).
- `observation.md` 396-400 says so. For the other 36 functions of the work and 7 of the rules it rests on the mark alone; see C3.

**N11. `observation.md` 345-346**: "Set to end "at once", a halt lasts no longer than to the start of the next round".
- `observation.md` 169-170 itself says that a new observer that does not answer leaves the halt for another round.
- That is a second fault, so it is outside what is claimed, but the two sentences do not say the same thing.

## Cannot be told from the folder

- **C1. `checks.md` 395-396** (changed line): the third check "found the second doing of the work still calling five functions of the first text, which are now in both." The same diff takes the count from 34 functions to 40, which is six. The folder does not say which were added or whether five or six were shared.
- **C2. `README.md` 23 and 400:** `one-spider.png` is not in the folder.
- **C3. N10's remaining functions:** whether each is a function of its own in the built program can only be told from the binary.
- **C4. `README.md` 437**, "Built with Rust 1.98": nothing in the folder pins a version.
- **C5. The author's measurements and trials:** the code could produce each.
  - The 30,000-round test prints the longest wait and the most waits used (`src/watch.rs` 4467-4478).
  - The two trials fit `src/main.rs` 270-304.
  - Not taken or run: 1.09 and 11 thousandths, the half hour of play, the 640,000 rounds, and that everything passes.
- **C6. `observation.md` 422:** the last item, "Who is at the pointer.", is a heading with no sentence after it. It was the same before this change.

## Counts

| What | Counted | Documents | Agrees |
| --- | --- | --- | --- |
| Tests in `src/watch.rs` | 74 `#[test]`; cargo reports 74 | `README.md` 454, 499 | yes |
| Checks in `test/limits.js` | 41 written calls of `check(`; four sit in loops over 5, 5, 5 and 3 things (lines 63-64, 73-79, 80-86, 218-224), so 55 when run | `README.md` 464 | yes |
| Plans in `test/drive.js` | 11, with the names `checks.md` 275-276 gives | `README.md` 465, 499; `checks.md` 273 | yes |
| `src/game/again.rs` | 40 functions and the mark `second`; 27 constants at the top level, one more (`N`) inside `web_plan`, and a test-only static; 40 marks | `checks.md` 216; the test asserts (40, 27, 40) | yes |
| `src/rules/again.rs` | 9 functions and the mark; 14 constants; 9 marks | `checks.md` 219-220 | yes |
| `src/watch/looks.rs` | 9 functions: the eight copies and `all_apart` | "eight times" | yes |
| `OWN_FAULTS` | 25 kinds, covering all 19 fields of `Book` | `checks.md` 180 | yes |
| Faults in the eight-copies test | 27 | see W3 | no |
| Hand-backs | 4 reviews + 3 checks of changes + 4 checks of documents = 11; nine faults = 4 + 1 + 1 + 3 | `README.md` 475-483; `checks.md` 300, 339-342, 417 | yes |

## Per document

- **`README.md`:** read in full. W1 (as a bound only), N2, N5, N6, N10, C2, C4.
- **`observation.md`:** read in full. W1, W3, N1, N4, N6, N8, N11.
- **`checks.md`:** read in full. W3 (the nearer side), N2, N3, C1.
- **`gameplay.md`:** read in full. N4 only. What it says of the page holds against `page.html` and `shown()`.
- **`backdoor.md`:** read in full. No findings. Its three example exchanges, the five sizes, and what it says the page shows and does all match `src/backdoor.rs`, `src/rules.rs`, `src/watch.rs` and `page.html`.
- **`outside.md`:** read in full. No findings beyond the loose bound in W1. The changed lines 32 and 64-71 are true of `src/main.rs` 307-344 and 578-586.

All section references by name exist under those names: "Where it ends", "What is established", "The scope", "How a halt ends" (in both documents), "Checking the work", "What is not observed", "Making the work go wrong", "The numbers".

## Comments checked

- **Head comments (`//!`)** of all eight source files:
  - `watch.rs`, `game.rs`, `game/again.rs`, `rules/again.rs`, `backdoor.rs`, `main.rs`: no findings.
  - `rules.rs`: N4.
  - `watch/looks.rs`: W3.
- **The named `///` comments:**
  - `Book`, `right_counts`, `restore`, `round_at`: no findings.
  - `Game`: the struct has no `///` of its own; its fields' comments are true.
  - `stopped`, `fail`: N8.
  - `correct`: true; the comment inside it is in N1.
  - `Apart`: N9.
  - `clock`: N7.

## `page.html`

Read in full against `shown()` (`src/watch.rs` 1392-1468). All 25 things `shown()` sends are the ones the page reads. These hold:
- the four panels;
- "spider no. 1" with the dead counted beside it;
- the large number with its tenths;
- the ring and the pointer's look taken from `over` and `holding`;
- reduced motion read once, stilling the wings and the pulse;
- the three buttons under "Put a change right";
- "Put it right" shown on a click or when the halt cannot be put right;
- the server-is-silent line after a second without a frame;
- asking for the stream again a second later;
- "the server did not answer" for a button that is not taken;
- the state brought up to date every sixth frame and laid out again when a moth comes or goes;
- a click on a field beginning a line;
- hints above the line, with Tab taking the first;
- a button for each observer that types `alive = false`;
- "let through", "not written", "halted:" and "put right:" said at the backdoor.

## What I ran

All runs were from `now/` with `cargo test --release --target-dir ./target -- --test-threads=2 <name>`, one filter at a time. All nine tests passed:
- `a_stop_in_the_wrong_place` (two tests)
- `the_second_text_of` (two tests)
- `a_count_that_goes_wrong_inside_a_round`
- `the_eight_copies_of_the_rule`
- `the_copies_are_apart`
- `a_round_is_held_to_both_texts`
- `a_halt_does_not_end_until`

I also added two temporary tests of my own to `src/watch.rs`, ran each by name, and took them out again. The file is back to 4,701 lines and 278,343 bytes, as I found it.
- The first gave the numbers in N1.
- The second put a leg, a leg of the gate's copy, and an observer's copy too many or too few into a round, at four instants under each setting. Every case was put right, with no halt that cannot be put right and at most one stop. That supports `observation.md` 406-408.

The builds left a `now/target/` folder. I did not run the program itself, used no port, and sent nothing to the copy on 8138.

## What I did not reach

- **Older tests in `src/watch.rs`** (1992-3198 and 3388-3640): not read line by line. The older paragraphs of `checks.md` (its lines 12-59, 65-92, 121-146, 161-178) were not rechecked against them, beyond the tests I did read: 2833-2852, 3199-3386 and 3623-4701.
- **`src/game.rs` and `src/rules.rs`:** the bodies of the work and of the rules were not read through. The numbers in `gameplay.md` were checked against the constants only, and the table of rules in `observation.md` 254-263 was not rechecked rule by rule.
- **`test/drive.js` and `test/limits.js`:** the plans were checked for their names and count, and the limits checks for their count and what each is called. Their bodies were not read through.
- **`test/wiring.py`:** read, not run; the model check is outside the folder.
- **The `review-*.md` files and what they found:** not checked, as instructed.
- **The full suite:** not run.
- **The 22-wait figure in W1:** from reading the loop, not from a run.
