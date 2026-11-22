# Independent check of `after/` and of the change from `before/`

## The plain answer first

- **A single fault inside the model that is recorded as true:** none found.
- **A single fault inside the model that loses the game:** none found.
- **A single fault inside the model that ends the program:** yes, found. Claim 1 fails in the steps after a cut, by two mechanisms, both run and confirmed.
  - A text of control characters well inside 64,000,000 bytes, in a part of the state, in the gate's copy of a part, or in the state kept from the round before. 24,000,000 is enough.
  - The moths observer's list made 32,000,000 commas, in a game with many moths and eight clicks waiting.
- **A sequence inside the model that is recorded as true or loses the game:** none found.
- **A sequence that ends the program:** one found. It is one fault inside the model followed by ordinary reads at the backdoor from about thirty connections. It ended in one run of three, and came within a second of it in the other two.

"Ended" here means the following. In tests with each observer on a thread started by `Apart::start` (the program's own waits), the function the observers were given counted as `rounds_stopped` counts (`main.rs:281-291`) and did not exit. It reached the second observer of one starting. None of this could be shown in the built program, because the backdoor cannot write anything large.

All references are into `after/src/`.

## Claim 1. No single fault inside the sizes ends the program: **fails**

**Between two rounds, with one line or one request before the next round: holds.**
- The cut at the start of the round (`watch.rs:1324`, `1345`) and `cut_down()` (`backdoor.rs:119`) stand before every reading.
- Longest round seen at the full 64,000,000 bytes or 100,000 entries: 0.19 s.
- Longest single line at the backdoor after a fault: 0.15 s (`world`, with one observer's text left at 1,048,576 control characters).
- `point`, `press`, `release` and `buy` read at most a list of 100,000: under a millisecond.

**At the five instants of the program's own test (its hooks stand before the cuts): holds.** 64,000,000 control characters in the state, the gate's copy and the kept state, under each setting: longest round 0.19 s. The test itself passes.

**In the steps after a cut: fails.**

*Mechanism A: control characters.* `quote()` writes each control character with its own `format!` (`backdoor.rs:77`). Measured with the program's own allocator:

| Control characters | One writing out |
|---|---|
| 1,048,576 | 0.12 s |
| 8,000,000 | 1.0 s |
| 16,000,000 | 2.8 s |
| 64,000,000 (by proportion, not run) | 7 s or more |

A plain text of 64,000,000 takes 0.2 s. A cut bounds this only if it stands between the fault and every writing out. The places where it does not:

- (a) after `fit_kept()` at `watch.rs:1324`, before `settle_before()` at `1327` writes the three kept states out (`522`);
- (b) after the cut at `1409`, before `watch()` builds what the observers look at (`725`, `710`);
- (c) after the observers are asked, before the gate's look (`1413`, `793`, `798`);
- (d) the putting right after it (`1266`, `1191`, `1193`);
- (e) after the cut at `1027`, before `write_record()` writes every part out and hands a copy to each observer (`1079`, `1082`);
- (f) after `cut_down()` at `backdoor.rs:119`, before the line reads or copies (`133`, `141`, `498`).

Counterexample, run:
- **Situation:** the tests' `webbed()` game, observers on threads by `Apart::start`.
- **Fault:** `spider.body.state` becomes 32,000,000 characters U+0001, landing after the cut at `1409` and before `watch()`.
- **Round N−1:** ordinary.
- **Round N:** the cut finds nothing. The fault lands. `look()` writes the body out, then `differs()` does, then the putting right does. The round took 11.3 s (at once), 18.0 s (after a pause), 13.0 s (on a click). No observer heard of a round for five seconds, each said so (`watch.rs:2069-2070`), and the second to say so is where `rounds_stopped` ends the program.
- **Had it gone on:** one halt, put right, not stuck, nothing recorded. Only the time fails.

Other runs of mechanism A:

| Where the text is | Size | Landing | Longest round | Ended |
|---|---|---|---|---|
| State (`body.state`) | 24,000,000 | between the observers' look and the gate's | 5.7 s at once, 6.3 s after a pause, 3.0 s on a click | first two |
| State (`web.torn`) | 32,000,000 | after the cut at `1409` | 18.8 / 14.4 / 7.7 s | first two |
| Gate's copy (`record.spider.body.state`) | 24,000,000 and 32,000,000 | same two places | 6.1 to 7.8 s at once, 3.2 to 3.8 s otherwise | at once only |
| State | 48,000,000 | after the cut at `1027` | 6.0 s | yes |
| Kept state, place 1 | 48,000,000 | after `fit_kept()` at `1324` | 5.8 s | yes |
| State, then a line (`world` or `spider`) | 32,000,000 | after `cut_down()` | line 3.8 to 4.7 s | no |
| State, then `during …` | 32,000,000 | after `cut_down()` | line 7.2 to 7.5 s | yes |

*Mechanism B: the moths observer's list.* `world_work` splits the list at its commas into a list of pieces and searches the whole of it for every moth, and for every click times every moth (`game.rs:868-883`, `908`).
- **Fault:** `ring[5].held` becomes 32,000,000 commas, landing after the cut at `watch.rs:1448` and before the work.
- **Situation:** nineteen of the upgrade for more moths, twenty moths, eight clicks waiting.
- **Result, run:** the round took 6.3 to 6.7 s and ended under each of the three settings. At 16,000,000 it took 3.2 to 3.5 s.
- With two or three moths and no click it is 0.5 s at 32,000,000.
- The same list read by `moth_at` in what a screen is sent (`watch.rs:1717`, `game.rs:482-485`): 0.59 s at 64,000,000.

**Longest round seen for each kind of thing** (64,000,000 bytes or 100,000 entries unless said):

| Kind | Longest | Where |
|---|---|---|
| Control text in a part of the state | 18.8 s at 32,000,000 | after the cut at `1409` |
| Control text in the gate's copy of a part | 7.8 s at 32,000,000 | same |
| Control text in the kept state | 5.8 s at 48,000,000 | after `fit_kept()` |
| Plain text in a part | 0.81 s | after the cut at `1409` |
| Text of quotes in a part | 1.2 s | same |
| A text of the gate's record | 0.03 s | — |
| An observer's name, reason, copy | 0.09 s | — |
| Moths observer's list as `7,7,…` | 0.59 s | what a screen is sent |
| Moths observer's list as commas, 20 moths, 8 clicks | 6.7 s at 32,000,000 | before the work |
| A text in one of the three books | 0.02 s | — |
| 100,000 moths, numbers at their longest, in the state | 2.4 s after a pause, 2.0 s at once | after the cut at `1409` |
| Same in the gate's copy | 1.3 s | same |
| Same in the kept state | 0.66 s | after `fit_kept()` |
| 100,000 moths as copies | 0.61 s | after the cut at `1409` |
| 100,000 observers | 0.35 s | same |
| Every other list (legs, catches, clicks, upgrades, record texts, an observer's copies, the three lists asked, book lists) | 0.2 s or less | — |

**Over two seconds without ending:**
- 100,000 moths with long numbers: 2.4 s.
- A control text of 8,000,000 in the state: 3.0 s.
- The connections case below.

**One fault, then lines from many connections.** Run with one lock and the same order of work as `main.rs:98-108`, `313-351`, `585-593`, in a test, not in the built program.
- **Fault:** one observer's name becomes 64,000,000 control characters. The first line or round cuts it to 1,048,576, and it stays there until the halt is put right.
- Every `spider` read then holds the game for 0.14 to 0.23 s.
- Longest wait between two rounds, with connections reading without pause:

| Connections | Setting | Longest wait |
|---|---|---|
| 1 | on a click | 0.14 s |
| 4 | on a click | 0.9 s |
| 12 | on a click | 2.4 s |
| 30 | on a click | 6.2 s, ended |
| 30 | at once | 4.0 s |
| 30 | after a pause | 4.2 s |

With nothing wrong, 30 connections change nothing: the longest wait was 26 ms.

## Claim 2. In a halt that cannot be put right nothing is done with the state: **holds**

**Argument.**
- `turn()` cuts and settles only the kept state and the books, then returns (`watch.rs:1324-1341`).
- `ask()`, `press`, `buy` and `during` refuse (`1522`, `1560`, `1586`, `1595`).
- `cut_down()` does nothing (`855`).
- The backdoor refuses every write (`backdoor.rs:226`, `270`).

**Run.** Three ways into such a halt (put aside whole; no two books agreeing; a putting right that failed), each with seven kinds of content, lists and texts over every cut and broken counts among them. Each had 40 rounds by both entries and 120 askings: pointer, presses, upgrades, settings, forty kinds of write and forty-four kinds of read at the backdoor, `during`, `cut_down()`. The state, both halves of the record, the observers and the three lists were byte for byte the same throughout. No read stopped where it should not.

**What does change:**
- the game's time, the note of the clock, the setting, the asking;
- the state kept from the round before. It is cut and settled every round: one place made 5,000 legs long went `[8, 5000, 8]` to `[8, 8, 8]`. That is three copies of an earlier state held by the gate, not the state.

**One remark.** "Nothing is looked at" is not literally so. `shown()` reads the state every round, uncut and bounded, and a backdoor read writes out whatever is there. Neither changes anything.

## Claim 3. Nothing ordinary is cut or changed: **holds**

**Round for round against `before/`.**
- 144,000 rounds of six games with pointer, presses, upgrades, settings and 8,639 lines at the backdoor. The state, record, observers, three lists, kept state, what a screen is sent and every answer were identical.
- 80,000 rounds of games with moths for anything: nineteen of one upgrade, up to twenty-two of the other, 32 moths. Identical.
- With the upgrade for appetite asked freely, the two first differ exactly in the round it reaches twenty-four, in all four games.

**A read changes nothing.** 377,168 lines that write nothing, each compared before and after: none changed anything.

**Nothing is near a cut.** The most seen: 8 legs, 24 moths, 36 catches, 43 entries in a list of what was asked (129 at most by `ask()`, `1520-1544`), a text in a part of 83 bytes, and a text of the record or of an observer of 3,634 bytes.

**The shop.** 48,000 rounds of storms of up to twenty asks between two rounds: the most was (19, 24), with no halt. The level is read again for each ask (`game.rs:844-851`), and both texts of the rules refuse more (`rules.rs:104`).

## Claim 4. What is left of a cut thing is found or written over, never recorded: **holds**

**Run.** 47,700 large faults beside a twin.
- Lists of 1,023, 1,024, 1,025, 3,000 and 100,000 entries.
- Texts of 131,070 to 3,000,000 bytes of seven kinds of character, multi-byte ones at the cut among them.
- In the state, the gate's copy, the kept state, the record's texts and count, the observers and the three lists.
- At fourteen instants (the test's five, a sixth while the record is being written, and eight added, one after each cut), under each setting.
- Result: 37,962 one halt, 9,738 none, none between two rounds unfound. The record matched the twin's at every recorded round and the whole game matched at the end.
- 4,000 pairs mixing large and ordinary faults: the same.

**The two cuts.**
- After the cut, the body written out is at most 794,520 bytes and the web 788,146, so no true copy of either is ever cut at 1,048,576.
- A cut text keeps at least 131,069 bytes, and a cut list 1,024 entries. The truth is far shorter, so a cut thing cannot come to agree with it.
- Where a long text lands after the last compare, the observers' copies are cut at 1,048,576 and the state's at 131,072. They then differ, and it is found by the observers where it would have been found by the gate. It is found either way.

**One remark.** The moths part with 1,024 moths written at their longest is 2,389,129 bytes. "Still within the most" holds for the two parts that have a text, not for that one. I found no wrong agreement from it.

## Claim 5. The tests test what they say: **mostly; five gaps**

I broke 108 things, one at a time, and ran the named tests on each. 97 were caught. Of the 11 not caught, two are your known ones.

**`what_a_fault_makes_very_large…`** catches each list and text left uncut, each cut point taken out, the eighth, the two sizes, the backdoor cut, and the state touched in a halt that cannot be put right. It does not catch:
- `fit_kept()` leaving out the first or the last of the three places. The test's fault is in place 1 only, and its halt part passes because settling repairs the uncut place.
- `cut_down()` cutting in a halt that cannot be put right. No line is run there.
- `cut_down()` cutting only the state. Its lines follow only long moths and legs.

Twelve other tests about the backdoor and such halts do not catch these three either.

Your known list is out of date on one point: taking out the cut before the record is written does fail this test, at its fifth instant.

**The two tests of the rules together** catch 44 of 47 breakages of `ruled()` and `record_now()`. Not caught:
- the gate asking the rules about the state where it should ask about its own copy (other tests catch this one);
- the gate handing on an account in which a moth is always due;
- the gate handing on a time at which a moth is always due.

The last two survive some twenty further tests as well. The account the gate hands on is held for clicks, upgrades and what is held. The time is held in `ruled()`, not where the gate hands it on.

**The other three.**
- **`what_a_screen_is_sent_has_a_size…`** holds the 4,096. It does not hold the 20,480: sending the list at 20,481 or at 10,240 passes.
- **`a_count_put_right_is_said`** catches both breakages tried.
- **`the_shop_has_no_more…`** catches all four tried.

## Claim 6. Nothing put right before is lost: **holds**

- **Test modules.** Fourteen lines were changed and none removed. Each is the appetite number, the eighth, or the widened large test, and each changed assertion is stricter.
- **Single faults.** 40,896 (four games, six instants, three settings) through both versions beside a twin. In each version none was lost, recorded, stopped or left halted. Halts, reasons and what was put right were identical line for line.
- **Pairs.** 9,000 pairs with the first halt ended and one to three rounds recorded between: the same, and identical.
- **Backdoor writes.** 48,000 rounds with random writes and 733 halts: identical.
- The count said once does not show in any of these. It needs a second count fault inside one halt.

## Claim 7. The program as it runs: **holds, for what can be written from outside**

Built from a clean copy and run on port 8190 as process 19300.
- Twenty faults at the backdoor under each setting, texts of 1,024 control characters among them, with four connections sending pointer, presses and upgrades.
- All sixty were found within 0.023 s, with one halt and one restart each.
- They ended in the same round (at once), after 0.62 s (after a pause), or only when asked (on a click).
- Then 27 connections for 12 s: 72,483 lines answered, 30 faults and 30 halts, longest gap between frames 0.078 s.
- Never stuck, one game, the program still running. Stopped by its id; nothing of mine is left running and nothing listens on 8190 to 8195.

## Not checked

- **64,000,000 control characters in a part, the gate's copy or the kept state, in the steps after a cut.** The program holds about thirty times the text there: 1.0 GB at 32,000,000 and 1.4 GB at 48,000,000. That is over my two gigabytes at the full size.
- **The moths observer's list as 64,000,000 commas.** Same reason; run at 16,000,000 and 32,000,000.
- **The whole suite.** Not run, as told. The two known cut removals were run against the large test only.
- **Observer-thread faults and a round that never returns.** Read, not run.

## Noticed outside the claims

- One fault inside the model can make the program hold close to two gigabytes for a round: the control text above, or 100,000 moths with long numbers at 1.15 GB.
- My throwaway copies, tests and outputs are in `work/` inside the folder; the outputs are in `work/out/`.
