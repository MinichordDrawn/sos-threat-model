# Independent check of `after/`: hand-back

## The two questions first

- **No single fault inside the model was found that is recorded as true, loses the game, or ends the program.**
- **No sequence of faults inside the model was found that does.**

Two things below fail, and neither touches the one-fault-per-halt guarantee:

- Claim 3: one text is still sent whole to every screen for as long as a halt lasts, and one answer is still taken uncut. The second needs two faults in one halt.
- Claim 6: one test still passes with the thing it names broken.

All line references are into `after/src/`. "Ran" means I ran it; "argued only" means I did not.

## Claim 1. The backdoor with a count wrong

**1a. Nothing stops, nothing is read or written, the line is answered or counted as not written: holds (ran).**

The guard at `backdoor.rs:213-215` is the first thing `one()` does after `help`/`?` (207-209), which touch nothing. Every index into the ring or a copy sits behind it:

- `piece`/`piece_mut` (377, 390)
- `get` (476)
- `set` (483)
- `read` (520)

`run()` and `write_now()` reach the game only through `parts_of` → `one` (130, 142, 150). A line of more than 32 parts is refused whole before that (158).

What I ran:

- **At the console:** 16 wrong counts × 116 lines × with and without `during` × halted or not, 7,424 cases, each also through `write_now`.
  - The wrong counts were: observers none, 1, 3, 4, 5, 7 (last gone, one gone from the middle), 9, 16; one observer's copies none, 1, 6 (last gone, first gone), 8, 107.
  - No stop and no change to state, observers, kept lines or counters.
  - Every answer was the refusal, the help, "there are 33 things", or one of the `during` refusals.
- **At random:** 60,000 generated lines, each with a count wrong. No stop, nothing written.
- **On the round's thread:** 14 kept `during` lines × the 16 wrong counts × 3 settings, landing after the work and before `write_now` (`watch.rs:1304`).
  - No stop, `unwritten == 1`.
  - State and observers were identical to a game with the same fault and no kept line.
  - One halt, put right, and afterwards equal to that twin.
- **Same matrix with the count going wrong before the observers look:** the halt comes first and the kept line is put aside (`stop_all`, `watch.rs:787-792`). It is said as "what was waiting to be written during the work put aside", not counted as not written.

Argued only: a fault landing between the guard and an index inside the same call to `one()` would still stop. At the console that is caught (`main.rs:590`); on the round's thread it is one stop, so a halt.

**1b. No line that should be taken is refused when every count is right: holds (ran).**

- The guard is a pure test of the two counts.
- 201 lines × 3 starting games × with and without `during` gave the same answers, state and next three rounds in `before/` and `after/` (1,206 cases, identical fingerprints).

One thing to know: an observer's number of copies stays wrong until the halt is put right, so under "on a click" the backdoor refuses everything, reads included, for the whole halt. In a halt that cannot be put right it refuses until the game is begun again. `before/` answered reads there.

**1c. Nothing else is leaned on without asking: holds (ran).**

- Legs and moths are counted each time a path is resolved (`backdoor.rs:429`).
- A given index goes through `each()` (414-420).
- `at[0]` and `at[used]` (441, 463) exist whenever the shape has the matching `[]`.
- `pieces[0]` (456, 469, 497) is reached only with a non-empty list.
- Every slice is cut at a character boundary (173-176, 252, 293, 330-336).
- Ran: legs 7, 0, 1, 9, 28 and moths 0, one fewer, 100 more, against 11,136 console lines and at five instants in a round under each setting. No stop, all put right.

## Claim 2. Nothing stops where a request reaches: holds

**`main.rs`**

| Place | Finding |
|---|---|
| Locks | `kept()` (73-75) and the stream's wait (647) take a poisoned lock. `game()` (98-108) turns a poisoned game lock into `stopped()`. |
| Round's thread | `round_at` and `shown` are under one catch (322-325). `stopped()` and `fail()` index nothing (`watch.rs:540-558`, `803-818`). The last `shown` (337) is uncaught by design and is of a freshly made game. |
| Request threads | `point`, `press`, `release`, `buy`, `set_how`, `put_right`, `time` (574-626) index nothing (`watch.rs:1355-1476`). The backdoor is caught (588-591). |
| Parsing | `MOST_LINE - line.len()` (461) cannot underflow, because 471-474 returns first. `&got[..take]` (466) is bounded. `Content-Length` that does not parse becomes `usize::MAX` and is refused (531, 554). `with_capacity` is at most 65,536 (479). |
| Stream | Takes only the `shown` lock (645-650). |

**`shown()` (`watch.rs:1480-1556`)**

- Observers by `get` (1484).
- `named(i)` and `unwrap_or(0)` (1507, 1509).
- A leg only if `k < len` (1412).
- `web_reach` through the guarded `level()` (`game.rs:668`).
- No other index.

**What I ran**

- 51,684 extreme writes: every field of every piece and observers' copies, 21 numbers, 7 operators, 18 texts, at the console and with `during`, 3 starting games × 3 settings. No stop, none stuck, all ended sound; the slowest whole case took 57 ms.
- 60,000 random lines with every count right: no stop.
- Every request entry, `shown`, `stopped` twice, `fail(NaN)` and `round_at(NaN)` with each of the 16 wrong counts: no stop.

## Claim 3. A finding has a size

**3a. The two cuts: holds (ran).**

- `watch.rs:686` cuts where the answer is taken; 702 cuts where a reason becomes the halt's.
- A 3,000,000-character answer from observers 0, 3, 5 and 6 under each setting gave one halt, at most 203 characters kept, and a screen within 2,000 bytes of usual.

**3b. Nothing else of that kind is left: fails, in two limited ways.**

*(i) Sent whole in every round while the halt lasts (ran).*

- Fault: the moths observer's `held` becomes 3,000,000 characters, between two rounds, set to "on a click".
- Every round from the next sends 3,006,244 bytes against 5,419 usual, until it is asked for.
- Cause: `shown()` writes `halted_moths()` uncut (1537), though the same field in the observer's own row is cut (1484).
- The same holds for:
  - 100,000 extra copies in one observer: 3,005,819 bytes, because each copy is cut but their number is not (168, 1484).
  - The open parts' own texts, `spider.body.state` and `world.web.torn`: about 3,005,890 bytes (1487, 1493).
- With "after a pause", `halt.last` also keeps the whole state text in all three books for the halt (1118-1127).
- All of it is gone when the halt ends: screens were back to about 5,700 bytes in every case.
- Through the backdoor none of these can exceed 1,024 characters.

*(ii) An answer taken in the putting right is not cut (ran, with one test hook added in a throwaway copy).*

- `correct()` takes the new observers' answers and hands the first non-empty one to `stick()` whole (1009-1012).
- Situation: a backdoor change halts the game; in the putting right one new observer answers 3,000,000 characters.
- Result: a halt that cannot be put right, a reason of 3,000,027 characters, and 6,005,487 bytes a round until the game is begun again.
- This is two faults in one halt, so outside the model.

*Bounds of the other texts*

| Text | Bounded by |
|---|---|
| `why` | Fixed words, part and observer names, or a finding cut at 686/702. The one exception is (ii). |
| `fixed` | Fixed phrases, at most about 20. |
| `let_through`, `not_written` | Cut to 200 (1269, 1306). |
| `inside` | 8 lines of 1,024. |
| What is asked | Bounded by `ask()` (1355-1379). |
| Observer `name`, `held`, `why`, each copy | Any size while a fault stands; sent cut to 160 and 24. |
| Record texts | Never sent. |
| A long text in one place of the books | Outvoted and put right in the next round (ran: six such). |

**3c. Cutting changes nothing that is compared: holds (ran).**

- Nothing compares the content of `why`: `observers_off` (779) and the rule's `shaped` (`looks.rs:59`) only test for empty.
- The rule's own findings are under 100 characters, so together and on threads give the same reasons.
- Cutting twice gives the same text.
- 288 thread cases (a short answer, a 3,000,000-character one, a stalled thread, then a second fault with a recorded round between): the expected number of halts every time, all sound, and under "at once" equal to an untouched twin.

## Claim 4. A count put right is said once, on every path: holds (ran)

- Three paths: `stopped()` (545-557), `restore()` (1040-1042), `turn()` (1193-1203).
- `right_counts()` returns something only when a count is wrong, and leaves both right, so a second saying needs a second fault.
- 468 cases: 9 count faults and 4 that are not counts × 6 instants × 3 settings × observers together and on threads. The instants were between rounds, before the observers look, after the work, the two late instants, and with a stop before the next round.
  - Said exactly once wherever a count fault brought a halt.
  - Never twice within the halt.
  - Never for the four that are not counts.
  - Not said, and no halt, where the round's own recording wrote over a text count (late instants).

## Claim 5. Nothing put right before is lost: holds (ran)

- `changes.diff` is the whole difference; I checked it against the two folders.
- Code changes are only the guard, the push in `turn()`, the two cuts, the test hooks and comments.
- Test modules: none removed, two added. Every changed assertion is one of your six items: the `mended` wording at 4661-4666 and 4778-4782, and the restructured `two_counts` test, which asserts more than before.
- The same probe in copies of both versions: 18 faults × 5 instants × 3 settings singly beside a twin, and 7,290 pairs with the first halt ended and one recorded round between. The kinds were counts of observers, texts and copies, and an observer's `why` and `flagged`.
  - 7,560 cases, all sound in both: no stop, not stuck, one game, record and observers whole.
  - Outcomes and reasons were identical line for line.
- The 11 added or changed tests I ran by name pass in the untouched `after/`.

## Claim 6. The tests test what they say

| Test | Verdict | What I broke (ran) |
|---|---|---|
| `a_round_is_held_to_both_texts_of_the_rules` (4204) | **fails in part** | See below. |
| The two count tests, for the guard in `flagging()` (3984, 4038) | holds | Indexing the ring unasked fails both. |
| `a_count_put_right_is_said` (4130) | holds | Fails with the saying removed from `turn()`, `stopped()` or `restore()`, and with it said twice. |
| `a_finding_of_any_length_is_cut_where_it_is_taken` (2987) | holds | Fails with either cut removed. |
| `a_game_put_aside_while_the_clock_cannot_be_read_begins_at_nought` (2966) | holds | Fails with the nought removed from `fail()`. It tests behaviour `before/` already had. |
| `two_counts…`, backdoor part (4073-4094) | holds | Fails with the guard removed, or with either half of it removed. |
| `the_eight_copies_of_the_rule_are_one_rule`, new part (4443) | holds | Fails with one copy not counting texts, not counting observers, or counting nothing. |

The rules test in detail:

- It does fail when the second text is handed the first's account, and when it is asked with the first list.
- It still passes when `record_now` heeds only the first text's verdict, and when it heeds only the second's (`first.or(second)` at 870).
- Nine other tests about the rules and the work, run by name, pass too under each of those breaks.
- With neither verdict heeded, three other tests fail.
- So no test I ran holds the gate's recording to both texts; it only holds `ruled()` to them.

## Claim 7. The program as it runs: holds for what the backdoor reaches (ran)

- Built program on port 8190, process id 812, stopped by that id. Nothing of mine is left running or listening on 8190-8195.
- 28 backdoor faults under each setting, 84 in all: state fields, observers' fields and copies, all observers stopped, a 1,024-character `held`, five `during` lines.
- Meanwhile five other connections sent 30,448 pointer, press, release, buy and backdoor-read requests; none failed.
- Every fault: one halt, one restart, one game, never stuck.
  - Found within 24 ms.
  - "At once": put right within 39 ms.
  - "After a pause": 613-651 ms.
  - "On a click": stayed halted until asked.
- 3,930 stream events, all valid; the longest was 7,505 bytes.
- Not reachable this way: any count, the record, the books, the kept state, the lists of what was asked, the threads, a stop, an unreadable clock, any text over 1,024 characters.

## What I could not check

- The full suite, as instructed; only tests named by filter.
- Instants other than the five the hooks give. A fault inside `one()` or inside `correct()` is argued only.
- A thread that answers late, ends, or says by itself that the rounds have stopped: I ran "stops answering" and "answers something else". `rounds_stopped()` (`main.rs:276-310`) was read, not run.
- A round that never returns: not run.
- 3b(ii) needed a hook that `after/` does not have.

## Outside the claims

- **Stops and the model's spacing differ under "at once" (ran).**
  - A stop, then the next round ends the halt, works and is recorded, then a second stop: the game is put aside.
  - Cause: `stops` is cleared only by a round that began unhalted (1318-1320).
  - Under the other two settings the same sequence is two halts.
  - I found no fault of the model that causes a stop, so this loses nothing today. If one existed, "at once" would need two rounds between, not one.
- **A misleading reason.** A text count that goes wrong after the work halts with "the gate found the copies of the legs A observer changed while the round was being worked" (`observers_off` at 773 against the short record). What is said at the end is right.
- **The guard's message** promises "until that has been put right"; in a halt that cannot be put right that means until the game is begun again.

## Files

Everything is in `«WORK»\check-eight\code\probe\`: the probe sources (`probe_*.rs`), `mutate.py`, `drive.py`, their outputs, and four throwaway copies (`a`, `b`, `c`, `m`) with their build outputs removed. `after\target` holds the builds made by your own command. `before\` and `after\` sources are untouched.
