# Independent check of `after/` and of the change from `before/`

## The answer first

- **A single fault inside the model that ends the program: yes.** The plainest is at one of your own instants: the moths become 2,000,000 or more after the second doing of the work has agreed and before the round is recorded (`late` with 1). Confirmed under each setting with each observer on a thread and the program's own waits, and confirmed end to end: a built copy ended itself with exit code 1. Two more ways are under claim 1.
- **A single fault that is recorded as true, or that loses the game: none found.** 33,534 single-fault cases on `after/` beside an untouched twin, all as claimed.
- **A sequence of faults inside the model that does any of the three: none found.** 15,876 pairs on each version, all as claimed.
- The change itself breaks nothing I could find. The fault that ends `after/` ends `before/` the same way.

Timings were taken on a 16-processor machine while other tests of mine used a few processors, so they run a little long. No fault was made larger than the four-gigabyte limit allowed.

Names for the instants, used below:

| | Instant | Where |
|---|---|---|
| A | between two rounds | before `round()` |
| B | before the observers are asked | `early`, `watch.rs:1355` |
| C | after the gate's look, before the work | `late` 0, `watch.rs:1397` |
| D | after the work | `fault`, `watch.rs:1413` |
| E | before the round is recorded | `late` 1, `watch.rs:987` |
| F | while it is recorded | `late` 2, `watch.rs:1053` |
| G | just after the cut at `watch.rs:1362` | added by me in a throwaway copy |
| H | just after the cut at `watch.rs:1401` | added by me |
| I | just after the cut at `watch.rs:954` | added by me |

---

## Claim 1. No single fault of any size ends the program: **fails**

### 1a. Counterexample at your own instant E (confirmed by running)

- **Situation:** a game with a web and moths, eight observers from `Apart::start`, any setting.
- **Fault:** `world.moths` becomes N copies of its first moth, landing at E.
- **Round N:** the cut in `record_now` (`watch.rs:954`) has already run. The fault lands at `watch.rs:987`. `write_record` then writes every moth out (`self.texts()`, `watch.rs:1041`), tests every moth against every strand (`in_web`, `watch.rs:1041`, `game.rs:736`), and gives each sound observer a copy or fingerprint of that text (`watch.rs:1044`). No observer is asked anything meanwhile.
- **Five seconds in:** each observer's fifth wait ends (`watch.rs:2019-2023`), and the second to say so ends the program (`main.rs:288-309`).

What I measured for the round in which it lands:

| Thing made large at E | Size | Round | Program would end |
|---|---|---|---|
| moths | 1,500,000 | 4.3–4.6 s | no |
| moths | 2,000,000 | 4.7–6.0 s | in 4 of 6 runs |
| moths | 2,500,000 | 6.4–6.8 s | under all three settings |
| moths | 3,000,000 | 6.4–8.6 s | under all three settings |
| catches (`own.gains`) | 8,000,000 | 5.0–5.1 s | under 2 of 3 settings |
| clicks (`own.clicks`) | 20,000,000 | 5.3–7.4 s | under all three |
| upgrades asked for (`own.buys`) | 30,000,000 | 5.4–5.5 s | under all three |

- "Would end" means all eight observers of one starting said the rounds had stopped, counted as `rounds_stopped` counts.
- **End to end:** a throwaway copy of `after/` with one added backdoor line that places exactly this fault (3,000,000 moths) ended by itself 5.1 s later. Exit code 1, and on its error output: "No round of the game has ended for some seconds, and so the program stops."
- **`before/` does the same:** 2,500,000 moths at E gave rounds of 7.1, 14.3 and 7.6 s and all eight said so. The change shortens the rounds after, not the one it lands in.
- `what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at` does not use E or F. With 1,000,000 moths at E the round took 2.1–2.2 s, over the test's own two-second bound.

### 1b. Counterexample just after a cut (confirmed in process, at an instant I added)

The four cuts protect only a fault that lands before one of them and is first used after it. Landing just after the cut at `watch.rs:1362`, the fault is written out whole by `look()` (`watch.rs:714`), by `differs()` (`watch.rs:787`), and by `mend()` or `restore()` (`watch.rs:1223`, `1150`).

| Thing made large at G | Size | Round | Program would end |
|---|---|---|---|
| moths | 2,000,000 | 10–16 s | under all three settings |
| moths | 1,000,000 | 4.2–7.1 s | no |
| moths in the gate's copy | 10,000,000 | 25–48 s | under all three |
| `body.state` in the gate's copy | 1 GB | 4.9–10.3 s | at once: both runs; on a click: 1 of 2 |
| catches | 5,000,000 | 8.9–12.8 s | under 2 of 3 |

- At H, 8,000,000 moths cost 2.1–2.2 s. More would not fit beside the three copies kept in `before`.
- At I nothing I could hold passed 1.3 s.

### 1c. Counterexample between two rounds, with a backdoor line before the next round (confirmed by running)

A fault at A is cut by the next round, but a line at the backdoor that arrives first reads it uncut while holding the game (`main.rs:588-591`). The round waits for the lock and no observer hears anything.

| After moths (or legs) become N | `world` | `world.moths` | `during world.tally.caught += 5` | `spider` (legs) |
|---|---|---|---|---|
| 1,000,000 | 2.4 s | 3.3 s | 5.6 s | 3.3 s |
| 2,000,000 | 5.0 s | 6.0 s | 11.1 s | 7.1 s |
| 3,000,000 | 8.7 s | 10.2 s | 16.9 s | 10.4 s |

- Reads go through `backdoor.rs:495-510`, which builds the whole answer before cutting it to 64,000 bytes.
- A `during` line copies the game and writes both copies out (`backdoor.rs:130`, `138`; `watch.rs:1555`).
- **End to end:** the throwaway copy, given 4,000,000 moths and then `world` in the same line, ended by itself after 5.07 s with exit code 1 and the same words.
- With no request in between, and with pointer, press, buy and letting-go requests, a fault at A costs nothing (argued from `watch.rs:1473-1545`; the lists are only counted).

### 1d. At the instants the cuts cover (A with nothing asked in between, B, C, D): **holds**, at the sizes I ran

720 cases, each observer on a thread, the program's waits, each setting. Each was one halt or none, never stuck, whole afterwards. Times at B, C and D include making the large thing.

| Thing | Cut by `fit()` | Largest run | Longest round at A–D | At E / F |
|---|---|---|---|---|
| moths (state) | yes | 10,000,000 | 0.17 s | see 1a / 0.02 s |
| legs | yes | 10,000,000 | 0.22 s | 0.10 / 0.09 s (5M) |
| catches | yes | 10,000,000 | 0.09 s | see 1a / 0.02 s |
| clicks | yes | 10,000,000 | 0.04 s | see 1a / 0.01 s |
| upgrades asked for | yes, the count only | 10,000,000 | 0.04 s | see 1a / 0.02 s |
| `body.state` | yes | 1 GB | 0.36 s; 0.96 s if control characters | 1.4 s (200 MB) / 0.10 s |
| `web.torn` | yes | 1 GB | 0.28 s; 0.86 s if control characters | 1.45 s (200 MB) / 0.10 s |
| gate's copy: moths, legs, catches, clicks, upgrades | yes | 10,000,000 each | 0.17 s | 0.19 s |
| gate's copy: `body.state`, `web.torn` | yes | 1 GB | 0.34 s | 0.35 s |
| record: number of texts | yes | 10,000,000 empty; 1,100 of 1 MB | 0.14 s; 0.32 s | 0.34 s |
| record: one text | yes | 1 GB | 0.27 s | 0.28 s |
| one place of `before`: moths, catches, `body.state` | yes | 10,000,000; 1 GB | 0.27 s | 0.23 s |
| number of observers | yes | 500,000 copies; 1,100 with a 1 MB name | 0.88 s; 0.68 s | 0.81 s |
| one observer's number of copies | yes | 10,000,000 empty; 1,100 of 1 MB | 0.14 s; 1.00 s | 0.79 s |
| one observer's copy, list, reason, name | yes | 1 GB each | 0.30 s | 0.27 s |
| each list of what was asked | yes | 10,000,000 | 0.09 s | 0.08 s |
| one place of `books`: `inside`, `pending`, `halt.put` | no | 10,000,000; 30,000,000 | 1.02 s; 3.4 s | 0.8 s |
| one place of `books`: `why`, `fixed`, `let_through`, `halt.last` | no | 1 GB | 0.23 s | 0.24 s |

- With 1,100 copies of 1 MB each in one observer, every later round of a halt that lasts takes 0.35–0.8 s, because `look()` copies them each round.
- With 1 MB of control characters in `body.state`, every round of a pause takes about 0.4 s. It is written out six times as long, and `halt.last` holds it three times.
- The 3.4 s for 30,000,000 texts in `inside` is mostly the making. Made before the round, it cost 1.2–1.3 s.

### 1e. `books`: a grown place costs nothing to find: **holds**

- `same()` (`watch.rs:362-396`) compares lengths before contents, so a grown place fails the comparison at once. `Deref` (`watch.rs:444-456`) then reads the other two at its usual cost.
- `settle_books()` (`watch.rs:468-486`) replaces the grown place at the start of the next round, halted or not. It does not live through "every round of a halt that lasts".
- What it costs is the freeing: 1.2–2.1 s for 30,000,000 short texts, 0.2 s for 1 GB of text.
- `keep()` on a grown place only clears, pushes or replaces. The one walk through it (`watch.rs:1308`) needs a count to be wrong as well.

One thing the claim leaves out: `books` is filled from the state by the program.
- `mend()` writes the whole state, written out, into `halt.last` in all three places (`watch.rs:1223-1232`).
- Every later read of any field of `books` compares two of them in full (`watch.rs:368`), about 100 times a round.
- With the state cut first this is small. With an uncut state it is what makes G and 1f slow under "after a pause".

### 1f. A text `fit()` does not cut and that is not in `books`: **not settled**

- The name of an upgrade asked for is a text held by reference (`game.rs:316`, `388`). `fit_state` cuts how many there are, not how long one is, and `own.written()` writes it whole (`game.rs:368`).
- Whether a name counts as "a text that may become any text" is yours to say.
- With one name of 300 MB in `own.buys` at A or B under "after a pause", every round of the pause took 3.2–4.9 s.
- In one run of three, three observers of one starting said the rounds had stopped. Larger did not fit in memory.
- At once and on a click: 1.0–1.5 s. In the gate's copy or in `before`: under 1 s. In a list of what was asked: nothing.

### 1g. What the threads hold (argued only)

- `Threads.calls` is not cut. `tick()` walks it once a round in a halt that cannot be put right, which is cheap, and it is not in your list of faults.
- An observer's answer of any length is cut where it is taken (`watch.rs:1929`).

---

## Claim 2. Nothing an ordinary game has is ever cut: **holds**

**The most of each thing, argued from the code.**

| Thing | Most in play | Why | Limit |
|---|---|---|---|
| legs | 8 | fixed | 1,024 |
| moths | 48 | one arrives only while there are fewer than 10 + 2 × 19 (`game.rs:918`); the rules refuse more (`rules.rs:153`) | 1,024 |
| clicks, upgrades taken in | 8 each | `game.rs:435`, `457` | 1,024 |
| catches kept | about 104 | 48 present plus at most 56 arrivals in a minute at 33 a minute | 1,024 |
| each list of what was asked | about 130 | 8 presses, 8 upgrades, 9 lettings go, runs of 4 places (`watch.rs:1473-1545`) | 1,024 |
| observers; copies; record texts | 8; 7; 7 | fixed | 1,024 |
| `body.state` | 10 bytes | four words | 1,048,576 |
| `web.torn` | about 400 bytes | 96 strands that hold, each at most once | 1,048,576 |
| a part written out, and any copy of it | under 10,000 bytes | 48 moths | 1,048,576 |

**The most seen by running:**
- Three one-hour games with every upgrade at its most: 28 moths, 59 catches, 124 bytes of `torn`, 119 bytes of halted list.
- In the same games: longest part 4,437 bytes, 9,667 bytes to a screen, 10 things waiting to be taken in.

**Can the shop sell more than the most: no.**
- The level is read again for each upgrade asked for (`game.rs:843-851`, `game/again.rs:508-515`), so eight in one round at 18 buy one.
- Run: from four starting levels, all 256 orders of eight asks over three rounds, with a spaced name and a third upgrade mixed in. The most ever sold was (19, 40), with no halt.
- Run: 60,000 rounds of unguarded buying with a full purse, no halt.
- More through a write is refused by both texts of the rules (`rules.rs:104`, `rules/again.rs:130`).

**What else the two limits bound:**
- 19 of "More moths" bounds moths on the wing (23), arrivals (33 a minute), the catches kept, the halted list, and the part with the moths in it, so also every copy of it and `halt.last`.
- 40 of "Spider appetite" bounds how many moths fill a spider (48), so how many it can catch in one round, and keeps one moth's share of the meter at 1/48 or more. It bounds no list.

**Round for round the same as `before/` with nothing wrong: holds.**
- Five games of 60,000 rounds each, played the same way in both versions, by `round()` and by `round_at()`.
- Each had pointer moves, clicks on halted moths, the spider picked up by body and by foot, and all four upgrades bought to just under the most.
- A running hash of the state, the record's texts and copy, every observer and what a screen is sent was identical in every sampled line of both versions.
- The three things under change 3 never showed.
- A sixth game with unguarded buying is identical until `before/` sells a 41st appetite. That is change 7.

---

## Claim 3. What is left of a cut thing is found, or written over, and never recorded as true: **holds**

**What I ran:**
- 414 single faults × 9 instants (A to I) × 3 settings × 3 games: 33,534 cases.
- The three games: a web with a moth in it; the same with a place, a press on a halted moth, two upgrades and a letting go waiting; the spider carried.
- Each ran beside a twin that works exactly the rounds the game recorded.
- About 60 of the faults are over the limits: 1,100 entries or 2 MB. They cover each list and text in the state, the gate's copy, the record's texts, each place of `before`, four observers and each list of what was asked.
- They include a right text repeated, a right list followed by more, and exactly 1,024 moths.

**What came of it:**
- Every case was one halt (27,879) or none (5,655), with restarts equal to halts.
- None was stuck or had a stop in the wrong place, and none halted later.
- State, record and gate's copy equalled the twin's after the halt and 40 rounds on.
- The harness does report a change recorded as true and a wrong put-back when I make one by hand.
- The 873 large cases with threads from claim 1 were also one halt or none and whole afterwards, the ones that would have ended the program included.

**The three things you asked me to look for (argued, and nothing in the runs against it):**
- A cut only shortens what is over the limits, and nothing ordinary comes near them, so a cut thing cannot equal a right one.
- Two cut things agree only when the program copied one from the other before the cut. At E the three full observers' copies of an oversize part agree with each other and with nothing else, and are flagged.
- No single fault gave two wrong rounds running or a halt that could not be put right.

---

## Claim 4. The reasons

**Counts the change names (observers, texts of the record, an observer's two counts): holds.** At D and at C, H and I the reason is "the gate found that the number of observers had changed…" or "…its own record no longer had one text for each part while the round was being worked". At B each observer says "there were no longer eight observers".

**A record changed after the work is said to be the record: holds** (28 faults at D, each setting).

**A count put right is said once: holds for `turn()`, as the claim says.** Put right once at the start of a round and once more in `restore()` (`watch.rs:1145-1147`), it is said twice. Run: "the gate's counts put right, the gate's counts put right, all eight observers started again" under each setting. That takes two faults in one halt, as your own test of this does.

**Where else the reason names something other than what went wrong** (all after the gate's look or after the work, beyond your four):
- A moth too many or too few in the state: "a step of the work that the rules of the game do not allow: a moth with no number of its own", "a moth coming before one was due", "moths counted as caught that were never there, or gone without being counted", or "more moths than there is room for".
- A click too many in what the game keeps, on a halted moth, at C: "…a moth picked out of the web with no click".
- An upgrade asked for too many there, when it can be paid for, at C: "…an upgrade bought that was not asked for".
- An upgrade asked for too many in the gate's copy, when it can be paid for: "…did the work of the round a second time… another way in the moths, counts and shop".
- One thing too few in the first or second list of what was asked: "…another way in the pointer, requests and chance" or "…in the moths, counts and shop". The list is never named.

Elsewhere the reason names the part, the observer, the record, the gate's copy or the three lists.

**A reason changed by this change that is now wrong where it was right: none.** The 391 single-fault cases whose reason differs from `before/` fall in these groups:
- "copies of the … observer changed" became "its own record had changed", for a text of the record changed at D.
- "…eight observers and seven parts" became "…eight observers".
- "an upgrade that was not paid for" became "more of an upgrade than the shop has", for a level written past the most.
- For oversize things at E, "the gate found … changed, and no observer had flagged it" became "the … observer found … changed". The next round's cut makes the state differ from the copies the observers took of it.

---

## Claim 5. The tests test what they say

Each break was made in a throwaway copy of `after/` and the named tests run. Unbroken, all the tests below pass.

**`a_round_is_held_to_both_texts_of_the_rules` and `the_second_text_of_the_rules_takes_nothing_from_the_first`, together: 43 breaks of `record_now()` and `ruled()`, 35 caught, 8 not.**

Not caught by the two:

| Break | Where | Caught elsewhere |
|---|---|---|
| second text asked of the state, not the gate's copy | `watch.rs:966` | yes, by the wording of a reason |
| first text asked of the state, not the gate's copy | `watch.rs:966` | yes, the same way |
| both asked of the state | `watch.rs:966` | yes, the same way |
| second text told no moth has had a number (`0.0` for `self.record.own.next_id`) | `watch.rs:1006` | no, in 22 wider tests |
| first text told the same | `watch.rs:1001` | no, in 22 |
| second text told a far later time (`now + 1e9`) | `watch.rs:1006` | no, in 22 |
| `record_now` hands `ruled` another account (right upgrades, 8 clicks, a moth always due) | `watch.rs:972` | no, in 22 |
| `redone()` never differs | `watch.rs:1026` | not what these two name; not run against the test that does |

- The three "caught elsewhere" fail `a_wrong_step_of_the_work_is_found_by_the_rules_and_undone` and the shop test.
- The 22 wider tests are those matching `rules`, `wrong_step`, `record`, `shop`, `taken_down`, `undone`, `work_twice` and `pointer`.
- The `sway` cases put the answers in after the texts were asked, so they cannot tell what each text was asked of.

Caught: either text unheeded on the copy or the step, heeded only when both refuse, or the copy's answers never heeded. Also the first text asked twice, the second handed the first's account whole or in any one of its four things, the wrong list of what was asked, the first text of the work for taking in or for the halted moths or for what the pointer holds, the state's own or spider in place of the record's, a step from the record to the record, either text's state being the record, either step never asked, and the first told a far later time.

**`what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at`: 30 breaks.**
- **Fails** with: no cut at all; no cut before the observers are asked; no cut in `record_now`; the state not cut; the moths, legs, clicks, catches or `body.state` not cut; the gate's copy not cut; the record's number of texts or a text not cut; `before` not cut, or only its first place; the number of observers, an observer's number of copies or a copy not cut; the first list of what was asked not cut.
- **Passes** with these not cut: the upgrades asked for; `web.torn`; an observer's name, list of halted moths or reason; the second or third list of what was asked.
- **Passes** with the list limit at 100,000 or the text limit at 32,000,000 bytes. `sized()` measures against the limits themselves.
- **Passes** when the fault at C never lands at all. It holds nothing about a fault being found.
- **Passes** with no cut before the work (known).
- **Fails with no cut at the start of a round**, twice, on the two-second bound: "a round with the moths in one place of the state kept from the round before, AtOnce, at instant 0 took 2.799994s". Unbroken it passed alongside.
- The reason for that last one: `settle_before()` writes each place of `before` out whole at `watch.rs:1283`, between the first cut and the second. So "the next point cuts the same thing down" is not so for `before`, and the first cut does work the others do not.

**`the_shop_has_no_more_of_an_upgrade_that_is_at_its_most`: 9 breaks, all caught.** One text of the work selling past the most, both, one text of the rules allowing more, both, all four, the most at 20 everywhere, appetite's most at 41 in the rules, and the shelf giving a price or saying it can be bought.

**The other changed tests:**
- `a_count_that_goes_wrong_inside_a_round_is_put_right`: caught the counts not looked at first, the record said to be an observer's copies, and C never landing.
- `a_count_put_right_is_said`: caught it being said every time.
- `the_eight_copies_of_the_rule_are_one_rule`: caught one copy with the old words. It passes with one copy looking at its two counts in the other order, which no single fault tells apart.
- `a_fault_in_what_the_gate_wrote_out_while_a_round_is_worked_is_put_right`: caught the old reason.
- `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long`: caught a text of a part sent whole, an observer sent without its copies, and the halted list sent whole.

**Two numbers of change 3 that no test holds:**
- The halted list cut at 1,024 as before passes all four screen tests.
- What the game says of itself sent whole passes them too, and passes `a_finding_of_any_length_is_cut_where_it_is_taken`.

---

## Claim 6. Nothing put right before is lost: **holds**, as far as I ran

**Test modules:**
- `changes.diff` is the whole difference.
- Three tests were added and none removed.
- Every changed or removed assertion is explained by change 2, 5, 6 or 7. That includes two your list of changed tests does not name: the reason in `a_fault_in_what_the_gate_wrote_out…` (change 2) and the counts in the two word-for-word tests (change 7).

**Single faults:**
- The same 414 faults at A, B, D, E and F, under each setting on three games: 18,630 cases on each version.
- `before/` was all as claimed.
- 18,239 were the same in outcome, reasons and what was put right.
- 391 differ in the reason only, in the groups under claim 4.

**Pairs:**
- 42 of the faults, each with each, at (A, A), (D, D) and (E, B), under each setting.
- The second lands after the first halt has ended and three rounds have been recorded.
- 15,876 cases on each version.
- Both were all as claimed: two halts in 12,270, one in 3,306, none in 300. Never stuck, game where the twin is.
- 1,224 differ in reasons only, the same groups.

**Not in these runs:** faults in the observers' threads, in `apart` and in `Run`. That code is unchanged, and the tests that cover it pass on `after/`.

---

## Claim 7. The program as it runs: **holds** for what can be written at its backdoor

- Built `after/` unchanged, on port 8190.
- One connection as a screen, one for the backdoor, four more sending the pointer, presses, lettings go and upgrades. All were kept open, with 36,817 requests in all.
- 18 lines under each of the three settings, 54 writes. They covered state fields, a moth put in, observers stopped, flagged, signals moved, copies and lists changed, 1,024-character texts, a number that is not one, a level past the most, and a `during` line.
- Every write was one halt, found in the next round, for a reason naming the part or observer.
- After a pause it ended in 0.63 s. At once it ended in 0.01–0.02 s. On a click it waited the full second and ended on `/right`.
- Each ended with restarts up by one and what was put back said. None was stuck and the game was never begun again.
- 54 halts and 54 restarts at the end. The screen was sent 2,495 rounds, the longest gap between two was 0.057 s, and the longest line was 7,094 bytes.
- The backdoor cannot make anything large (64 moths, 1,024 characters), so 1a and 1c needed the throwaway copy with the added line.

---

## What I could not check, and why

- **The full suite:** not run, as told. On unchanged `after/` I ran 26 named tests, which are every added or changed one and the observer-thread ones. All pass.
- **Larger faults:** the memory limit held uncut lists to 2 to 30 million entries and uncut texts to 200–300 MB. Hence 1f is not settled and H is short of five seconds.
- **1b needs an instant your hooks do not give.** I added three in a throwaway copy.
- **1a and 1c end to end needed one added backdoor line** in a throwaway copy. The unchanged program cannot be given those faults from outside.
- **`before/` at E** was run under "on a click" only, in the copy whose output I kept in the folder.
- **Idle-machine thresholds:** not measured.

---

## Noticed outside the claims

- **What a screen is sent after a fault and before any round** walks every moth when the pointer is over the game (`watch.rs:1532`, `game.rs:482-485`). I measured 0.14 s per million, so tens of millions at F would be needed. Not run to the end.
- **The comment at `watch.rs:806-807` and the documents' "known" reason** read as if any later cut makes an earlier one spare. See the `before` finding under claim 5.
- **A copy of this program on port 8138 changed its process id during my work**, from 21948 to 17756. I sent it nothing and stopped nothing by name.
- **My three processes** (ids 13440, 8840, 35936, on ports 8191, 8191, 8190) are all gone. Two ended themselves and one I stopped by its id.

`before/` and `after/` are as you gave them. Everything of mine is in `«WORK»\check-ten\code\work\` and can be deleted. The results worth opening first, all in that folder:
- `a\sweep.tsv`
- `a\sweep2.tsv`
- `a\quiet2.tsv`
- `a\door.log`
- `a2\twin_singles_a.tsv`
- `b\twin_singles_b.tsv`
- `a3\twin_pairs_a.tsv`
- `b\twin_pairs_b.tsv`
- `mutants.txt`
- `drive_claim7.txt`
- `drive_late1.txt`
- `drive_between.txt`
