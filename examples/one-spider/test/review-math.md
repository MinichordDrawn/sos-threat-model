# Independent review of the single-fault claims: One Spider, Rust copy

Folder reviewed: `«WORK»\review-math\`. File references below (`watch.rs:459` and so on) are to the files in its `src\` folder.

## Verdicts

| # | Claim | Verdict |
|---|---|---|
| 1 | Detection between rounds | **Fails** in one narrow case (the sign of a zero in one request list). Holds for every other target. |
| 2 | Recovery | **Fails** in the same case: it ends in `stuck`. Every other single-fault case goes the right way in `restore()`. |
| 3 | A fault inside a round | **Fails**: three more counterexamples (a wrong value recorded as true, a `stuck` game, and a panic). |
| 4 | No false halts | **Holds** for the start-of-round condition. "Never halts" is **not settled** as a proof for the rules; no counterexample in 150,000 rounds. |
| 5 | The written texts are exact | **Holds**. |
| 6 | The second doing is the same function | **Holds**, with one caveat argued only. |
| 7 | Fingerprints | **Holds**; confirmed with a real fingerprint collision. |
| 8 | The wiring | **Holds** against what `wiring.py` itself states. The checker it feeds was not available. |

All four counterexamples (A to D below) were run. Nothing in the program was changed; only tests were appended.

## How it was checked

- Reading `watch.rs`, `game.rs`, `rules.rs`, `door.rs`, `main.rs`, `wiring.py` and the README sections named.
- Throwaway tests appended to `watch.rs` from line 2460 to the end, every name beginning `review_`.
- For faults at a chosen instant inside a round I wrote "a round done by hand": the statements of `round`, `record_now` and `write_record` in their order, with one change let in between two of them. It was checked equal to `round()` (state, observers, record, lists, counts) over 6,000 rounds with random requests and three halts, one under each setting (`review_00`).
- I did not run the existing suite, as instructed.

## Claim 1: detection between rounds. Fails in one narrow case

**What holds.** After a recorded round, `write_record()` (watch.rs:546-557) leaves state, record text, record copy and every observer's copy saying the same thing, and both lists are emptied (731-732).

- A state or `Own` field: every part's text changes (claim 5). The three full-text holders of the ring find it (watch.rs:352) and so does the gate (433), before the work.
- An observer field: `name`, `alive`, a copy, `held` and `flagged` are found by peers (355-376) and by the gate (437-456). `why` alone is found only by the gate (454); run.
- A record text or a record copy field: found at 428, by the gate only.
- A list entry: found at 459, by the gate only.

Run: 1,492 single-field changes to the gate's copy (every field of body, old spider, a leg of each set, edge, counts, web, shop, every moth; values moved, NaN, 1e300, -1; three settings) and 580 to the state with those values. All were found before any work and put back exactly.

**Exactly when a change makes no difference:**

1. `beat` of a running observer: `watch()` rewrites it (385-389) before anything reads it.
2. `before`: rewritten at 709 before the next work. It is read only at 611, when a part of the record disagrees with itself.
3. The sign of a zero in a pointer place or a click's place in one list: the taking-in clamps the pointer with `max(0.0)` (game.rs:372), which gives +0 for either zero in this build, and a click's place is used only for distances. Run: no halt, nothing differs.

**Counterexample A (run, all three settings).**

- Situation: a game with no moths (seed 1). The first spider starves and the next is walking in over the top side, body at (406.25, -34.1). A press at (406.008, 0) lands on its front foot (leg 0). It is taken down twice as `Ask::Press(406.008, 0.0, now)`.
- The one change: in the second list, that entry's y becomes -0.0 (one bit).
- Next round: the gate compares the lists with `!=` (watch.rs:459), which is the derived `PartialEq` on `f64` (game.rs:388), and 0.0 == -0.0. Nothing is found and the work is done. The work takes hold with y = 0.0 (game.rs:411); the second doing gets -0.0. `Own::written` gives `0.0` against `-0.0`, so the round is refused: "came out another way in the pointer, requests and chance".
- So work was done on the change before any halt.

Reach: it needs a press whose x or y is exactly 0 landing on the spider, and a fault that changes only the sign. A request stamped at time exactly 0 would do the same through `pointer.moved`; that variant is argued only.

## Claim 2: recovery. Fails in case A; otherwise the decisions are right

**A, continued (run).** When the halt ends, `restore()` puts the state back, but line 632 uses the same `!=`, so the lists are not put aside. The next worked round is refused the same way, `spoiled` reaches 2 (743-751) and the game is `stuck`: "twice running, ...". That took 38 rounds after a pause, 1 at once, 2 on a click.

**The `restore()` enumeration.** S is the state, T the record text, K the record copy, O the observers' copies, B `before`. G is the right value, F the changed one, R what the round's work makes of G.

| One fault | S | T | K | O | B | Branch | Result |
|---|---|---|---|---|---|---|---|
| Between rounds: state part | F | G | G | G | not read | 604-609 | S from K. Right |
| Between rounds: record text | G | F | G | G | not read | 614 | T from K. Right |
| Between rounds: record copy | G | G | F | G | not read | 612 | K from S. Right |
| Between rounds: one observer's copy | G | G | G | one F | not read | 604, nothing to do; replaced at 571-575 | Right |
| Between rounds: `before` | G | G | G | G | F | 604 | No difference |
| Between rounds: list entry | | | | | | 632-636 | Both emptied. Right, but see A |
| Inside, round refused: state, `Own`, a list, the moths list | wrong | G | G | G | G | 604-609, every part | Back to the round's start. Right |
| Inside, refused: record copy, part not moved | G | G | F | G | G | 612 | Right |
| Inside, refused: record copy, part moved | R | G | F | G | G | 612 no; 614 no, since observers hold G even if F = R; 616 | S and K from B. Right |
| Inside: record text | | F | | | | overwritten at 556 | Right |
| As recorded, before 547 (B below) | F | F | F | F | | not reached | Adopted. Wrong |
| As recorded, between 547 and 556 (C below), part not moved | F | R | F | R | R | 616 | Right |
| The same, part moved | F | R | F | R | G | 628 | `stuck`. Wrong |

Inside `restore()` itself no single fault is ever adopted: each of 612, 614 and 616 needs every observer of the part to hold the value taken.

One nuance (run): if the changed entry is the last pointer place and the pointer moves again during the halt, both lists write it over (763-766). They are then the same and are not emptied. The changed value is gone either way.

## Claim 3: a fault inside a round. Fails

**What holds.** With the change let in after the gate has looked, after what was asked is taken in, after the world's work, or after the spider's work, every case was either recorded identical to a fault-free round or refused and undone exactly, and the game went on:

- 4,158 single-field changes to the state: 0 wrong.
- 2,138 changes to `Own`, the gate's copy of `Own`, each record text, `before`, every field of every observer, and entries of either list: 0 wrong.
- 1,882 single-field changes to the gate's copy: 1,870 right, 12 panics (D).

The reason it works: no stored value feeds both doings. The work reads the state, the first list and the moths observer's list; the second doing reads the record copy, the second list and its own `in_web` (532-536).

**Counterexample B: recorded as true (run).** `record_now` compares the second doing with the state (518, 537), and then `write_record()` reads the state again (547, 556).

- Situation: a game with a web being made and moths on the wing, nothing asked.
- The one change: after 518 returns and before 521, `world.tally.gained += 100000`.
- What happens: the round is recorded with it. Both halves of the record, all eight observers and the state agree. 1,200 rounds on there is no halt and `gained` is exactly 100,000 above a fault-free twin. Asked for "spider" and "web", it buys both; the twin, with 7 moths, buys neither.
- With `world.tally.caught += 5` instead: the next round is refused ("the spider's meals not the moths it caught"), undone to the record that holds the change, refused again, and `stuck` after 40 rounds.
- Over 332 single-field changes at that instant (at once): all 332 were recorded with the changed value. 169 ended `stuck`, 115 were never found and the game went another way, 48 washed out.

**Counterexample C: `stuck` (run, all three settings).**

- The one change: inside `write_record()`, after the texts are written (547) and before the copy is taken (556), `spider.body.x += 1`.
- What happens: text and observers hold the right value, state and copy the changed one. The next round finds it. 612 fails (state is not the text), 614 fails (observers hold the text), 616 fails because the body moved in that round so `before` is not the text. Line 628 returns an error: "it could not be put right".
- Over 332 changes: 260 `stuck`, 72 put right (parts the round had not moved, by 616).

**Counterexample D: the program panics (run through the real `round()` with the tests' own `fault`).**

- Situation: a game whose web is there.
- The one change: during a round's work, the gate's copy `record.world.web.level` becomes 7. Any value of 7 or more does it; 80 and 1e300 were seen.
- What happens: `record_now` calls `wrong_step` (513-514), which calls `web_of(web0.level)` (rules.rs:279), which indexes `SHARES[level as usize]` (rules.rs:69): "index out of bounds: the len is 7 but the index is 7". `wrong_in` checks the state's level first (rules.rs:151), but nothing checks the record's.
- In the real program the round runs under the game's lock (main.rs:54-58), so the game thread is gone and the lock is poisoned. That consequence is from reading; the panic was run.
- Between rounds the same change is found and put right (run, three settings).

**By target:**

| Target | Result |
|---|---|
| State part, `Own` | Right before the second doing's comparison; B and C after it |
| Record text | Right (overwritten) |
| Record copy | Right, except D |
| Each list | Right, except A |
| An observer | Right (overwritten at 550-554, or found next round) |
| `before` | No difference |

## Claim 4: no false halts. Holds for the condition; not settled in full

The start-of-round condition is everything `differs()` (426-463) and `rule()` (348-381) check. `write_record()` establishes it. Between rounds the only fault-free writer is `ask()` (760-771), which does the same to both lists, and `beat` is rewritten for all. After a halt, `correct()` rebuilds observers from the record and re-checks (571-583). That part is settled by reading.

"Never halts" also needs the rules never to refuse a right round. I read every rule in `rules.rs` against the work and found no mismatch, but that is not a proof.

Run:

- 150,000 rounds over three seeds with random requests: pointer anywhere including exactly 0, -0 (4,892 times), the far corner and outside; presses on the body, feet, moths and nowhere; releases; purchases up to 66 of an upgrade; rounds of 1/60, 0.05, 0.001 and 0 seconds; 27 to 35 spiders a run; the spider held for about 8,300 rounds. No halt.
- 112 single door changes amid such requests under random settings: exactly 112 halts, 112 put right, never `stuck`.

Two things it depends on: `main.rs:52` capping a round at 0.05 s (rules.rs:156 assumes it), and whole-number sums staying under 2^53.

## Claim 5: the texts are exact. Holds

- `Val::Num` uses `{}` (door.rs:51) and `Own::written` uses `{:?}` (game.rs:350-369). Both write the shortest text that reads back as the same number. Run: about 5 million numbers, each with its neighbour, read back bit for bit; -0 is written `-0` and `-0.0`.
- Non-finite numbers are written as distinct quoted words.
- `quote()` (door.rs:66-82) escapes the quote and the backslash, so a text field cannot close itself.
- Every field of every part is written, including all nine of `Own`. Lists are bracketed with self-delimiting items.
- Run: 400,000 random webs and 400,000 random `Own`s built from awkward values and letters; no two different ones written the same.

Two pairs do share a text, and neither is reachable by one field fault from a recorded state: two NaNs with different bits (`unfit()`, 482-502, never records one), and a ninth leg (see the last section).

## Claim 6: the second doing is the same function. Holds

`take_in`, `world_work` and `spider_work` read only their arguments. There is no clock, no map, and the only static is the web plans, built once (game.rs:617-620). `redone()` reads only the record, the second list and `in_web(record.world)`; the state appears only in the final comparison (537). The two `held` arguments come from different places but are equal in fault-free play (451).

Caveat, argued only: `f64::max` and `min` are documented as free to return either zero when given +0 and -0. That arises at game.rs:372 and in `clamp` (game.rs:447-449). In this build both orders give +0, and the 4,892 pointer places at -0 caused no halt.

## Claim 7: fingerprints. Holds

Parts 0 to 2 are held in full by observers 0, 1, 2 and parts 3 to 6 by 4, 5, 7 (watch.rs:56-58, 207-209). Each compares in full (352), and the gate compares full texts (433).

Run: I built a real collision, an eleven-digit value of `spider.old.meals` (17067401415) that gives the body part the same 32-bit fingerprint, and wrote it through the door. The coordinator found nothing. The three full holders each found "the body changed", and so did the gate. It halted and was put back exactly.

## Claim 8: the wiring. Holds against `wiring.py` as written

- Every member checks every part of its ring (351-354).
- Every member checks every other member's copies (355-362), signal (365), running (368) and shape (371), and the moths list (376).
- A flag on a sound observer reaches its ring and, through `whole`, the other (404-416). Run: a flag on each of the eight reaches all eight in that round with nothing moved.
- Any sound flag or any silence stops everything (420-422, 677-706).

Differences that do not break it: an observer's `why` is checked by no peer, and the halt is one decision in one place, not one per part.

## What I could not check

- `check_model.py` is not in the folder, so the meaning of `hb_readers`, `checkers`, `fwd` and `halt_inputs` is inferred from `wiring.py` alone.
- `page.html` was not read, so I do not know whether the page can send a press at exactly 0.
- `main.rs` and the HTTP path were not run.
- The rules against the work for every reachable state: read and sampled, not proved.
- A debug build: `MOTHS_MORE * more as usize` (game.rs:845) would overflow and panic on a huge `shop.spawn` arriving inside a round. In release it wraps. Argued only.
- The `max`/`min` tie on other toolchains.

## Outside the eight claims

- **One fault per round is not what is tolerated; it is one per halt.** All run:
  - After a pause: a state change, then three rounds later one change to a record text, ends `stuck`.
  - On a click: one record half changed, and rounds later the other half to the same value, is adopted.
  - Two rounds running, each with its own single change during the work, ends `stuck` as "twice running".
- **Any single fault that survives `restore()` and makes the two doings disagree is fatal on the second refusal.** A is one. A ninth leg is another (run): no part's text covers it, it is not seen before the work, and the game is `stuck` after 40 rounds. It is not a field, so it is outside your model.
- **The gate's bookkeeping.** In the cases run, none recorded a wrong round: `halt` lost after a refused round, `rounds` changed between and inside rounds, a halt from nowhere, `how` and `spoiled` changed, a line pushed into `inside`, and `stuck` cleared.
- **Two README sentences are contradicted.** "One fault in the record is found and put right ... while a round is being worked" (D), and "for a wrong round to be recorded, two faults in the same round would have to agree" (B).
- **A dropped letting-go.** When both lists are put aside, a release in them is lost, and the spider stays held until the next press and release. Argued only.

## Remedies the findings point to (not made)

- A: compare the two lists exactly, by bits or written text, at 459 and 632.
- B and C: write the record from what the second doing made, not from a second read of the state.
- D: make `web_of` refuse a level that is not one of the seven, or hold the record's side to `wrong_in` first.

## What is left in the folder

- The `review_` tests in `«WORK»\review-math\src\watch.rs`, lines 2460 to 3681. `review_31` fails by design: it asserts that no case went wrong, and the 12 panics of D are its failures.
- A `target` folder from the build, inside the review folder.
