# Independent check of `after/` against `before/`: hand-back

All paths are under `«WORK»\check-twelve\code\`. Line numbers are in `after\src\`.

## At the top

**Something needs a change: yes, in the code and in the tests.**

- **A single fault inside the model that is recorded as true:** none found.
- **A single fault that loses the game:** none found.
- **A single fault that ends the program: one found, confirmed by running.** The number of moths in the gate's own copy goes wrong between the rules and the second doing of the work (claim 3). It is in `before/` too; the change did not bring it.
- **A sequence of faults inside the model that does any of the three:** none found (9,000 pairs).
- **The change itself:** claims 1, 2, 5 and 6 hold. Claim 3 fails. Claim 4: the changed tests hold most of what they name, with the gaps listed there.
- **Also over two seconds, program not ended:** two cases, under claim 3.

## How I worked

- Throwaway copies of both versions with 32 numbered instants added inside a round (`turn`, `record_now`, `write_record`, `correct`). With "between two rounds" (P00) and "between the round and what a screen is sent" (P33) that makes 34.
- A fault goes in at one instant. The game runs beside a twin that is never touched and is given exactly the rounds the game recorded.
- "Sound" means: at most one halt, put right, not stuck, same game, state and record equal to the twin's, ring whole.
- The same probe text was built into both versions, and each scenario writes one line: counts, reasons, what was put back, and marks of the state and of everything sent to a screen. I compared the two versions' lines.
- The machine was busy with my own parallel runs for most timings. Where I re-measured after they had finished, I say "quiet".

## Claim 1. What `quote()` writes is unchanged: **holds**

- `backdoor.rs:67-89`. The old `quote()` was copied into a test and compared with the new one.
- Every one of the 1,112,064 characters there are, alone and between others: same bytes.
- The empty text, and 4,000 mixed texts from a fixed seed (controls, the five with a letter, quotes, backslashes, 2-, 3- and 4-byte characters, up to 200,000 characters): same bytes.
- Speed on 8,000,000 bytes, best of five, each version's own `quote()` in its own build:

| Kind of text | before | after |
|---|---|---|
| control characters | 0.83-0.87 s | 0.042-0.051 s |
| newlines | 13.5 ms | 14.1 ms |
| quotes | 13.8 ms | 13.5 ms |
| backslashes | 13.0 ms | 12.8 ms |
| plain letters | 17.2 ms | 13.7 ms |
| two-byte characters | 14.2 ms | 13.4 ms |
| four-byte characters | 8.2 ms | 8.2 ms |

Control characters are about twenty times faster. No other kind is slower beyond noise.

## Claim 2. The list of halted moths

**Nothing wrong: holds.**

- A game has at most 10 + 2 x 19 = 48 moths (`game.rs:62-70`, `917-918`; `rules.rs:153`). A number is at most 16 digits. So a true list is at most about 816 bytes, and `halted_moths()` (`watch.rs:694-702`) returns all of it.
- `shown()` (`watch.rs:1718`) cuts the same text at the same place as before.
- Run: three games of 150,000 rounds each, upgrades bought to 19, pointer moving, clicks on halted moths. Longest list 64 bytes. `halted_moths()` equalled the observer's list every round. The marks of state and screen were identical in both versions.

**List made wrong: holds for the outcome.**

- 55 wrong lists were tried at all 34 instants, under each setting, in two games: 11,118 scenarios per version. The lists included empty, reordered, numbers no moth has, 1 to 8,000,000 commas, junk with the true list placed before, across and after byte 20,480 and byte 1,048,576, and 2-, 3- and 4-byte characters across the cut.
- Every scenario was sound in both versions. Counts of halts and restarts, and the final state, observers and record, were the same in both.
- I found no list for which handing the work less changes what is recorded. The reason: the work can only be handed a wrong list if the fault lands after the gate's look. Such a round is never recorded in either version, because `record_now` still finds the observer's list differing from the record's (`watch.rs:1027`, `913`).

Two things do differ, and neither is an outcome:

- **The halt's reason**, at the three instants between the gate's look and the work (P10-P12), for lists whose true content lies past byte 20,480. `after/` says "a moth halted in the web that moved". `before/` said "the list of halted moths … changed while the round was being worked" or "came out another way". In the quiet game what is listed as put back differs with it.
- **One frame of what a screen is sent**, when the list goes wrong as the round is recorded (P26-P28, P33) and is not yet found. `over()` (`watch.rs:1587`) now reads the cut list, so "what the pointer is over" can be null where it was a moth.

## Claim 3. Inside the sizes, no single fault ends the program: **fails**

### The counterexample (run)

- **Situation:** any game with a moth halted in the web. The built program reached this 45-48 s after starting, in four runs.
- **The fault:** the count of moths in the gate's own copy (`record.world.moths`) goes wrong and makes the list N long. The new entries are moths with numbers no moth has had, lying where a halted moth lies.
- **When:** inside `record_now`, after `ruled()` has returned (`watch.rs:1016-1021`) and before `redone()` reads the record (`1022`).
- **What happens in that round:**
  - `redone()` (`1064-1073`) works out the halted moths from the gate's copy (`1068`), so all N are on the list.
  - `again::world_work` looks each moth up in that list by going through it (`game\again.rs:533`, used at `537`, `561`, `572`).
  - That is N²/2 comparisons for the moths, and as many again for each waiting click that hits nothing.
- **If the round ends**, the second doing differs, nothing is recorded, and there is one halt, put right. The harm is only the time.

Measured with each observer on a thread and the program's own waits (`Apart::start`):

| Game | N | Round took | Machine |
|---|---|---|---|
| nothing asked, one moth halted | 5,000 | 0.05 s | quiet |
| nothing asked, one moth halted | 10,000 | 0.17 s | quiet |
| nothing asked, one moth halted | 20,000 | 0.62 s | quiet |
| 30 moths, 20 halted, 8 clicks waiting | 3,000 | 0.08 s | quiet |
| 30 moths, 20 halted, 8 clicks waiting | 10,000 | 0.81 s | quiet |
| 30 moths, 20 halted, 8 clicks waiting | 30,000 | 6.8 s | quiet |
| 30 moths, 20 halted, 8 clicks waiting | 100,000 | 99-131 s | busy |

- At 30,000 in the second game all eight observer threads said the rounds had stopped.
- By these numbers five seconds is passed near N = 26,000 with clicks waiting, and near 57,000 with nothing asked.

In the running program (a throwaway build with one added line that puts this fault in at that instant):

| Version | Setting | N | Result |
|---|---|---|---|
| after | after a pause | 100,000 | ended by itself 5.0 s later, exit code 1 |
| after | at once | 100,000 | ended by itself 5.0 s later, exit code 1 |
| before | after a pause | 100,000 | ended by itself 5.1 s later, exit code 1 |
| after | on a click | 30,000 | one 2.4 s stretch, then halted as it should |

- Each run that ended said "No round of the game has ended for some seconds, and so the program stops."
- This path from 5 silent seconds to the end of the program is `observe()` (`watch.rs:2052-2086`) and `rounds_stopped` (`main.rs:276-310`).

Two limits on this finding:

- The brief's list of faults names "one entry of the gate's record, or how many texts it has". Claim 3 says "any list the game holds", and the suite's own test faults "the moths in the gate's copy". I took the gate's copy of the moths to be inside the model. If it is not, this is not a counterexample.
- Copies of a moth the list already had are cheap (0.41 s at 100,000). It takes new numbers on a strand. The same list at the instants before the gate's check of its copy is refused in about 1 ms.

### Over two seconds, program not ended

**The moths of the state made 100,000 as the round is recorded** (run in the test harness, not in the built program).

- The fault lands after the last cut in `record_now` (`watch.rs:1035`) and before `write_record` reads the state (`1087`).
- The values: 10,300 new moths numbered 7 on a strand, the rest numbered 8. The pointer is over the game, on nothing.
- `write_record` makes the moths observer's list from them (`1093-1097`). `shown()` then looks every moth up in the first 20,480 bytes of it (`over()`, `1587`; `game.rs:482-485`).
- Round with its screen: 2.36 s quiet (the screen 2.10 s), and 3.6-4.1 s on the busy machine. Other numbers gave 1.5-1.9 s quiet.
- One halt in the next round, put right.
- In `before/` that lookup read the whole list. I did not run it there.

**The torn strands made `"0,"` 4,000,000 times.**

- The game is the costliest one met in 900,000 rounds of play: 48 moths, 43 halted, a size-6 web with 96 close strands made, and clicks waiting on eight halted moths.
- In the state, after the cut before the work (P12-P15): 2.7-3.2 s.
- In the gate's copy, between the rules and the second doing (P21): 2.8-3.2 s.
- Both were measured on the busy machine and not re-measured quiet.
- The cost is one working-out of the strands per click that hits (`game.rs:709-721`, `875`). One working-out took 0.41-0.43 s for that web.

### Longest round seen for each kind

General run: every list to 100,000 and every text to 8,000,000 bytes, at all 34 instants, each setting, each observer on a thread, a line at the backdoor before the next round and in the halt. Busy machine.

| Kind of thing | Longest | Where |
|---|---|---|
| lists, other than the cases above | 1.7 s | state moths at P24 |
| state moths | 1.3 s | P08, after the cut before the observers are asked |
| observers | 0.68 s | P08 |
| clicks | 0.73 s | P14-P15 |
| the gate's copy of the clicks | 0.67 s | P20-P21 |
| text of control characters | 0.73 s | what the body is doing, P08 |
| text of numbers and commas | 0.79 s | the gate's copy of the torn strands, P21 |
| text of commas | 0.42 s | the gate's copy of the torn strands, P21 |
| text of quotes | 0.23 s | an observer's copy, P33 |
| text of letters | 0.23 s | a text of the gate's record, P26 |
| text of four-byte characters | 0.26 s | one place of the gate's own, P08 |
| a line at the backdoor | 0.056 s | in the halt |

- The list of halted moths made 8,000,000 commas: sound at every instant, and never the longest thing.
- In a separate pass with nothing else done to the game, 9,483 large faults each ended as one halt put right. The one exception is under "Noticed outside the claims".

### One fault left standing in a halt, thirty connections reading: **holds**

- Built program with an added way to put the fault in, halts set to end on a click, 30 connections reading without pause.
- Nine cases: an observer's name, copy or list of 1,048,576 control characters, the list of commas, the body's and the web's texts, 100,000 moths, 100,000 legs.
- The longest stretch between two rounds was 0.63 s. The program ran on and the halt was put right when asked.
- The `before/` build in the first of these ended itself, as the brief says it did.

## Claim 4. The tests test what they say

Each row broke one thing in a throwaway copy and ran the named test or tests.

| Test | Broken | Caught | Not caught |
|---|---|---|---|
| `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long` | 36 | 28 | 8 |
| the two rules tests together | 57 | 51 | 6 |
| `what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at` | 43 | 41 | 2 |

**The screen test** (`watch.rs:3234-3305`).

- It does hold: the 20,480 exactly for the work and the screen, the "..." mark, every control character's written form, and every other cut in `shown()`.
- The old `quote()` fails its one-second limit at 1.85 s on this machine. A machine twice as fast would let it pass.
- Not caught, and still not caught when I ran eight more tests with it (nine in all):
  - `halted_moths()` cutting inside a character. One form of this stops the round in the wrong place.
  - `halted_moths()` returning the last 20,480 bytes and not the first.
  - `halted_moths()` cutting at 20,480 characters and not bytes.
  - `quote()` not escaping a quote.
  - `quote()` not escaping a backslash.
  - `quote()` writing 0x7f as `\u007f`.
- Not caught by this test but caught by three others: `quote()` writing a space as `\u0020`.
- Not caught by this test and not tried against the others: `shown()` sending what the game says of itself whole. I had recorded this as caught; the saved result shows the test passed.
- The cause for `halted_moths()`: the only long list the test hands it is all commas (`3282-3283`).

**The two rules tests** (`4586-4689`, `4691-4790`).

- Twelve of the 51 are caught only because the broken gate halts every game and the fixtures cannot build one.
- The new assertions (`4760-4763`) do catch `record_now` handing on another time, another time for the next moth, other clicks or other upgrades.
- Not caught by the two, nor by 20 further tests run with them: `record_now` replacing what the pointer holds in the account it hands on. I tried two forms. The holding is only tested through `ruled()` (`4783-4784`).
- Not caught by the two but caught by other tests:
  - the gate's check of its copy asking about the state instead;
  - what the second doing found not being heeded;
  - the first text being handed the observer's list.
- Not caught by any of the 22: which text's reason is said first. It is harmless.

**The large-things test** (`4814-4941`).

- The two not caught are the two the brief already names: the second cut at the start of a round (`1353`) and the cut before the work (`1456`).
- The new assertions catch what they name:
  - each of the three places of `fit_kept`;
  - `cut_down` cutting nothing, or only the state;
  - `cut_down` cutting in a halt that cannot be put right;
  - a line at the backdoor not cutting first.

## Claim 5. Nothing put right before is lost: **holds**

- **Test modules:** 84 tests in both, same names. Five lines were removed in all: the old `quote` line, the old `halted_moths` body and its comment, the old `shown` line, and the array length 20. No assertion was removed or changed. `changes.diff` is the whole difference.
- **Single faults:** a catalogue of 2,154 to 2,362 faults per game, covering:
  - every field of the six parts and of the observers;
  - copies and counts;
  - what the game keeps for itself;
  - the record's texts and its copy;
  - each of the three places of the gate's own and of the state kept from the round before;
  - the three lists of what was asked.
- These ran in three games (quiet; busy with things asked; spider held), at 12 instants each and each setting: 121,836 scenarios per version.
- **Pairs:** 9,000 pairs, with the first halt ended and one to three rounds recorded between.
- **Result:** every scenario was sound in both versions, and every line is identical between them (outcome, reasons, what was put back, state and screen marks).

## Claim 6. The program as it runs: **holds**

- The unmodified `after/` build, with six other connections sending pointer moves, presses, purchases and backdoor reads throughout (54,218 requests).
- 18 single faults at the backdoor under each setting: 54 in all, two of them `during` lines.
- Every one gave one halt and one restart, never stuck, same game.
- At once: no more than one frame halted.
- After a pause: halted 588-612 ms. One case took 956 ms on the busy machine; six repeats gave 591-599 ms.
- On a click: stayed halted until asked, then put right.
- 4,747 frames, all well-formed. The program ran on. Fields I read before and after were back as they were.

## What I could not check

- **The whole suite.** As instructed, I did not run it. About 45 of the 84 tests ran by name on the unmodified `after/`, and all passed.
- **The documents.** They are not in the folder.
- **Instants inside the built program.** They cannot be reached from outside. The counterexample there uses one added line; everything else inside a round used the test hooks. Instants inside a function (inside `world_work`, inside `redone`) were not tried.
- **Observer-thread faults and the three places that hold the threads.** These were covered only by the suite's own tests, which I ran and which passed. They were not in my two-version comparison. A thread that says by itself that the rounds have stopped, and a round that never returns, were read and not run.
- **Worst values.** The general timing run uses values I chose. The two slow cases show that the values matter, so other costly values may exist.
- **Memory.** I did not measure it.
- **The second over-two-seconds case** was not run in the built program.

## Noticed outside the claims

- With the program's own waits on the busy machine, a halt had sometimes not ended three rounds after it was asked for: 2 of 120 tries in one run and 1 of 9,483 in another. None repeated in three more tries each. I take it to be new observer threads answering late under load, which the next round tries again. I did not prove that.
- Both slow paths have the same shape: a list read after the last cut, and each entry looked up in a list made from it. A cut of what `redone()` has just copied, and of the moths `over()` goes through, would bound both. I did not try either.

## Files are in folder `tools\`

- `patch.py` and `probe_*.rs`: the instants and the tests
- `mutate.py` and `mut-*.txt`: what was broken and what caught it
- `hammer.js`, `live.js`, `at21.js`: the runs of the program
- `c3-*.out`: timings

The scenario logs are in `wa\probe-out`, `wb\probe-out`, `wc2a\probe-out`, `wc2b\probe-out`, `wu\probe-out` and `wt\probe-out`. The throwaway copies and their build output are still in the folder. No process of mine is left, and nothing listens on ports 8190-8195.
