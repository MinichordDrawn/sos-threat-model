## In short

**Nothing I found needs a change to the code.** In `after/` I found no single fault inside the claim that is recorded as true, that loses the game, or that ends the program, and no sequence that does.

**Two small things in the changed tests are worth a few lines each.** Neither points at a defect in the code; both are places where a changed test passes with something it names broken. I tried the fix for each.

1. The third test passes when the second text of the rules is told "any number of clicks" instead of counting them for itself. None of the roughly 25 other tests I ran against that break caught it either.
2. The second test does not pin the edge of "more than 1,024 moths": `>=` in place of `>` in `over()` passes.

Verdicts: claim 1 **holds**, claim 2 **holds**, claim 3 **holds**, claim 4 **holds for the first test and holds with one gap each for the second and third**, claim 5 **holds**.

All line references are into `after/src/`. Everything marked "run" I ran; anything else is marked as argued only.

---

## Claim 1. Nothing an ordinary game does is changed: holds

**Argument (argued only).**
- `fit()` (`watch.rs:846-863`, with `fit_state` at `291-299` and `fit_kept` at `874-879`) only truncates. It does nothing to a list of 1,024 entries or fewer, or to a text within its limit.
- An ordinary game cannot get near those sizes:
  - eight legs and seven record texts;
  - moths: 48 by the work, 64 by the backdoor (`backdoor.rs:106`, `236-238`);
  - a text written at the backdoor is at most 1,024 characters (`backdoor.rs:107`, `267-271`);
  - what is asked is bounded by `ask()`, `press()` and `buy()` (`watch.rs:1539-1563`, `1578-1582`, `1609-1616`) to roughly 130 entries between two recorded rounds.
- So the new cut at `watch.rs:1032` is a no-op, and `over()` (`watch.rs:1590-1605`, new check at `1597-1599`) answers as before.

**Run.** I put the same harness in a copy of `before/` and of `after/` and played three games of 60,000, 30,000 and 30,000 rounds (seeds 7, 11, 12345).
- What was asked: pointer moves onto halted moths, the body, feet and anywhere; bursts of up to ten presses; releases; all four upgrades, bought until the two that have a most reached it (spawn 19, appetite 24; the other two reached 140 to 161); and nine kinds of reading lines at the backdoor.
- What was compared, every round: the state, both halves of the record, every observer, the three places of the kept state, the lengths of the three lists of what was asked, the halt count, what a screen is sent, and the backdoor's answers, all folded into one running mark.
- Result: the marks are the same in both versions at all 60 checkpoints. No game halted.
- In `after/`, a counter around the new cut found something to cut **0 times in 120,000 rounds**.
- Largest sizes seen at round ends: 24 moths, 33 catches, 127 bytes of torn strands, 3,733 bytes for the longest record or observer text.
- A screen was told "leg" in 10,645 rounds, "body" in 12,740, "moth" in 1,053 and nothing in 95,562, identically in both versions.

**Limits of the run.**
- My games never had more than 24 moths (the spider was held often, so webs were few). The 48 and 64 bounds are argued, not reached.
- The lists of what was asked are empty at round ends, so their bound is argued too.
- Backdoor writes are faults and are in claims 2 and 5, not in this trace.

---

## Claim 2. With something wrong, the outcome is what it was: holds

**Argument (argued only).** Every fault inside the claim leaves every list and text far below the cut sizes, so the new cut does nothing and `over()` is unchanged: the two versions run the same steps. The instant between the rules and the second doing is new only to the tests. A fault landing there:
- **In the gate's copy:** `redone()` (`watch.rs:1075-1084`) works from the changed copy. Either the result differs from the state and the round is not recorded, or it is the same text as the state, and then what is recorded is the state the rules have just allowed.
- **In the state:** `redone()` differs from it, and the round is not recorded.
- **In the second list of what was asked:** `redone()` takes it in. Either it differs, or the list is cleared with the round's record (`watch.rs:1117-1119`).
- **In an observer:** `observers_off()` (`watch.rs:892-925`, called at `1038`) refuses the round.

In each not-recorded case `restore()` (`watch.rs:1204-1270`) has a branch that settles it, from the kept state where the record's two halves disagree.

**Run: single faults.** 88,095 scenarios in each version (6,027 more were left out because the fault changed nothing).
- **Three games:** (a) a moth halted in the web, moths to spend, and a pointer move, a click on the halted moth and an upgrade waiting; (b) the spider carried by the pointer; (c) an old spider lying and the next walking in.
- **Faults**, about 1,330 to 1,580 per game:
  - every field of the body, the old spider, each leg, the edge, counts, shop, web and each moth, in the state and in the gate's copy, each to up to four other values (a little more, a millionth more, another sign, not a number; texts to other valid and invalid values);
  - the same fields in one place of the kept state;
  - 20 changes to what the game keeps for itself (pointer, grab, clicks, upgrades, chance, next moth, next number, catches), in the state, the gate's copy and the kept state;
  - each record text changed, emptied or swapped, and one too many or too few;
  - each observer's name, running, signal up and down, each of its seven copies changed or emptied, a copy too many or too few, list, flag and reason;
  - 22 changes to each of the three places of what the gate keeps of its own;
  - a place of the kept state emptied;
  - nine changes to an entry of each list of what was asked;
  - a moth or a leg too many or too few, in each place.
- **Seven instants:** between two rounds; before the observers are asked; after the work; between the gate's look and the work; after the second doing agrees; while the record is written; and between the rules and the second doing (the hook added to the copy of `before/` for this).
- **Three settings.**
- **The twin** is a copy that is never touched and works exactly the rounds the faulted game records. Checked every round: at most one halt, never a halt that cannot be put right, one game, any recorded round's record equal to the twin's. From the round after the fault, whenever not halted: state, both halves of the record, every observer, the lists of what was asked equal to the twin's, the three places of the kept state and of the gate's own agreeing. At the end: not halted, as many restarts as halts.

Results:

| | Scenarios | One halt | No halt | Wrong |
|---|---|---|---|---|
| All instants | 88,095 | 68,802 | 19,293 | 0 |
| Between the rules and the second doing | 12,549 | 11,139 | 1,410 | 0 |

- No round stopped in the wrong place.
- The two versions' logs (halts, reason, what was put right, a mark of the final state, for every scenario) are **byte for byte the same**.
- Slowest round: 63 ms, with the machine busy. No fault that leaves every list and text at a size a game can have came near a second.

**Run: pairs.** 4,344 pairs (656 left out), random over two of the games, the three settings and the instants, weighted to the new instant. The second fault lands only after two rounds that began unhalted and were recorded. 0 wrong, and the two versions' logs are the same.

**Run: observers' threads** (`after/` only). 48 scenarios: each of the eight observers on a thread of its own either stops answering or answers something else, under each setting, beside a twin run together. All gave one halt, one restart, and the game where the twin is.

**Check of the harness.** With `redone()` made to accept anything, the same harness reported 168 of 2,589 scenarios as recorded as true. So it does see that outcome when it happens.

---

## Claim 3. What is left of a thing cut at the new point is found: holds

**Run.** 13,929 scenarios in `after/`: 340 large things, seven instants, three settings, two games, with the same twin.
- **What was made large:**
  - legs, moths, clicks, upgrades, catches, what the body is doing and the torn strands, in the state, the gate's copy and each place of the kept state. Each was either replaced or had the right content with more added. Sizes: 1,025, 5,000 and 200,000 entries; 131,073, 400,000 and 3,000,000 bytes.
  - moths with numbers no moth has had, where a halted moth lies and where one on the wing is: 1,025, 5,000 and 60,000;
  - the record's texts in number, and one of them in length;
  - the observers in number, and for three observers the copies, one copy, name, list and reason;
  - each list of what was asked, filled with releases, clicks on the halted moth, clicks elsewhere, upgrades or pointer moves.

At the new point, 1,986 scenarios:

| Outcome | Scenarios |
|---|---|
| Round not recorded, one halt in that round | 825 |
| Round recorded with the twin's record, found in the next round (all places of the kept state) | 837 |
| Round recorded with the twin's record, and by the next round nothing left | 324 |
| Wrong | 0 |

- At every other instant: 0 wrong.
- Nothing larger than is looked at was left held.
- Slowest round: 359 ms, most of it making 200,000 observers.

One thing I changed in my own check: in a first run it also flagged 1,236 scenarios at the instant "while the record is written", for something large still held at the end of that same round. That instant is after the round's last cut, and the thing is cut at the start of the next round, as the code says. With the check moved one round later, there are none. That is the "known and decided" case, not a finding.

**The round the change is about (run).** Moths no game has had, in the gate's copy, where a halted moth lies, between the rules and the second doing, with eight clicks waiting far from every moth:
- copy of `before/`, 30,000 moths: **12.9 s** (1.4 s with the clicks on the halted moth); the machine was busy.
- copy of `after/`: **15 ms** with 30,000 and **24 ms** with 1,000,000. The gate's copy is left with 1,024, and the round is refused with "the gate did the work of the round a second time, from its own record, and it came out another way in the moths, counts and shop".

---

## Claim 4. The tests test what they say

I made 100 breaks, each in a throwaway copy, and ran each against the test that names the thing. 83 fail the named test.

| Test | Breaks | Caught by the named test |
|---|---|---|
| Very large things (`watch.rs:4852-4994`) | 44 | 41 |
| What a screen is sent (`watch.rs:3250-3339`) | 33 | 29 |
| Second text of the rules (`watch.rs:4725-4828`) | 23 | 14 |

### The test of very large things: holds

**The new cut.** All nine breaks fail:
- taken out;
- moved to just after the second doing (this one is caught by time alone: 5.29 s against the limit of 1 s);
- moved to before the new instant;
- cutting only the gate's copy, only the moths of the gate's copy, only the state, or everything but the gate's copy;
- the first cut of `record_now()` taken out;
- the last one taken out.

**`fit()`, `fit_state()`, `fit_kept()`.** All 25 breaks fail: each of the 20 single truncations taken out; a text in a part cut at the whole limit; and `fit_kept()` cutting only the first place, only the first two, all but the first, or only the moths.

**`cut_down()` and the backdoor.** All 5 fail: cuts nothing; cuts in a halt that cannot be put right too; cuts the state only; the backdoor not calling it; calling it after the line.

**The round.** Not cutting the kept state first fails, and so does cutting everything in a halt that cannot be put right. Taking out the second cut at the start of a round does not fail, which you list as known.

**Two breaks that do not fail it, and are not a gap:**
- `redone()` accepting anything;
- the look at the observers after the second doing taken out.

Each fails another test (`a_wrong_step_that_breaks_no_rule_is_found_by_doing_the_work_twice`; `what_the_gate_wrote_out_is_not_settled_against_an_observer_that_differs`). For the test's new fault, either check alone still refuses the round: with `redone()` accepting anything, the moths observer's list no longer matches the gate's copy (`watch.rs:917`). I confirmed this by adding an assertion that no moth made by the fault survives: it still passed with `redone()` broken.

### The test of what a screen is sent: holds, with one edge not pinned

**Caught (29):**
- `halted_moths()` (6): the whole list, the last 20,480 bytes, 20,480 characters and not bytes, 20,479, 20,481, cutting after the character the cut falls in.
- `over()` (3): without the new check, only past 1,025 moths, counting the gate's copy's moths.
- `shown()` (13): the halted list at 20,481 or whole; every moth, leg, catch, observer; every copy; a copy whole; an observer's texts whole; the body whole; the web whole; what the game says of itself whole or at 4,097.
- `quote()` (7): a quote or a backslash left as it is, U+007F written as a control character, non-ASCII left out, a new line as a control character, capital digits, two backslashes before a quote.

**Not caught (4):**
- **`>=` in place of `>` in `over()`** (`watch.rs:1597`). This is the gap: the test tries only 1,025 moths. These two lines before `watch.rs:3313` close it. Tried: they pass as the code is and fail with `>=`.
  ```rust
  game.world.moths = vec![moth.clone(); MOST_HELD];
  assert!(game.over().map_or(false, |over| over.3 == "moth"), "with MOST_HELD moths and no more, nothing is said to be under the pointer");
  ```
- The check made only where a moth is looked for, and nothing said past 64 moths. Neither can be told apart by a game or by what the test says.
- `shown()` never saying what is under the pointer. That is not this test's subject, and `a_screen_is_told_what_the_pointer_is_over` fails on it.

### The test of the second text of the rules: holds for what was added, with one gap

**Caught (14).**
- `record_now()` handing the rules another account: its own account of what is held, nothing held, any number of clicks, a moth always due, a later time. The new lines at `watch.rs:4819-4822` are what catch the first of these.
- `ruled()`: the second text handed the first's account whole, or its held, clicks or next moth; held taken from the first text of the work; either text told no moth has had a number; the second told nothing is held, or that a moth is always due.

**Not caught by this test, caught by `a_round_is_held_to_both_texts_of_the_rules` (8):**
- the upgrades handed on wrongly by `record_now()`;
- the second text handed the first's upgrades, or told every upgrade was asked for;
- the second text taking in the first list of what was asked;
- the second text using the first text of the work to take in, the first text's halted moths, the first text of the step, or the first text of the state.

**Not caught by anything I ran (1): the second text told any number of clicks** (`clicks: usize::MAX` in place of `own.clicks.len()` at `watch.rs:1061`).
- It passes this test, `a_round_is_held_to_both_texts_of_the_rules`, and every test whose name contains `rules`, `wrong_step`, `click`, `asked`, `second`, `moth`, `three` or `gate`: about 25 tests.
- Why: the test shows the second text allows a round when the first is handed a wrong count. It never shows the second refusing on its own count.
- No fault gets through because of it: the first text and the second doing still stand.
- These three lines after `watch.rs:4766` close it. Tried: they pass as the code is and fail with the break.
  ```rust
  let mut unclicked = round.clone();
  unclicked.asks_again.retain(|ask| !matches!(ask, Ask::Press(..)));
  assert_eq!(unclicked.ruled(&account(&game), dt, now), (None, Some("a moth picked out of the web with no click")), "with the click taken out of the second list alone");
  ```

---

## Claim 5. The program as it runs: holds

**Run.** I built `after/` unchanged and ran it on port 8190 (process 35668).
- **Faults:** 16 lines at the backdoor under each of the three settings, 48 in all.
  - Thirteen direct writes: body, edge, counts, a moth put in, all four observers of the spider's ring stopped, the moths observer's list, a leg, the shop, the body's state, an observer's copy, an observer's signal, a number that is not one, two web fields at once.
  - Three `during` lines.
- **Meanwhile:** three connections kept open sent 7,239 pointer moves, 1,316 presses, 1,316 releases and 1,046 upgrade requests. The backdoor was on a fourth and the setting on a fifth. Two screens were streaming (5,850 frames read). Every answer was 200.

Results:
- Every fault gave exactly one halt and one restart: 48 and 48 at the end, one game, never a halt that cannot be put right.
- The reasons named the observer or the gate as expected. Each of the three `during` lines was found by the gate, by the rules in eight of the nine runs and by the second doing in one.
- **After a pause:** the halt ended 616 to 766 ms after the write.
- **At once:** it ended in the round it was found, 4 to 24 ms after the write. The `during` lines took 35 to 40 ms, with two halted frames seen: they are found after the work and put right in the next round, as the code says.
- **On a click:** it stayed halted, with no restart, for the 1.2 s I waited, and ended within about 75 ms of being asked.
- Fields the work does not change read the same before and after.
- The program was still running at the end and had written nothing to its error output.
- I stopped it by its process id and checked it was gone. Nothing of mine is left on ports 8190 to 8195.

**Limit.** The backdoor does not reach the gate's copy and cannot make anything larger than 64 moths or 1,024 characters. So the situation the change is about cannot be made in the running program; it is checked in the tests and my harness only.

---

## What I could not check, and why

- **The whole suite.** I was told not to run it. On `after/` unchanged I ran the three changed tests (all pass: about 12 s, 2 s and 1 s). Other tests ran only against particular breaks.
- **The "any number of clicks" break against the whole suite**, for the same reason. It is uncaught by the roughly 25 tests listed above; I cannot say it is uncaught by all 84.
- **Some observer-thread faults:** one that answers late, one that ends, and one that says by itself that the rounds have stopped. Also faults in the three places of the hold on the threads and of what they are run by. My harness covers only a thread that stops answering or answers something else.
- **The five-second watch ending the program** (`main.rs:277-311`) in the running program: nothing the backdoor can write makes a round slow enough.
- **Instants other than the seven above.**
- **The 48- and 64-moth bounds in play.** My ordinary games peaked at 24.
- **Timings.** All were taken while other work ran on the machine. They are safe as orders of magnitude (15 ms against 12.9 s), not as exact figures.

`before/` and `after/` are as given: their difference is still `changes.diff`. All my throwaway copies, the harness (`zz.rs`, `zz2.rs`), the break runner (`mut.py`, results in `mut.log` and `mut2.log`), the driver for the running program (`drive5.js`, output in `drive5.out`) and the logs are in:

`«WORK»\check-thirteen\code\w\`

That folder can be deleted whole.
