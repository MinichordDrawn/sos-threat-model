# Independent check of the change (`after/` against `before/`)

## Verdict

Fourteen of the seventeen claims hold. Three need attention:

- **Claim 13 fails in one case.** If the program cannot write to stderr, the end of the game's thread does not end the process.
- **Claim 1 holds with one exception.** A fault in `record.texts` in the first round worked after another work-time halt still ends `stuck`, by the older "twice running" rule.
- **Claim 17 has four sentences in the README that are not exact.**

I found nothing that the change breaks that held before. A sweep of 17,136 single faults run in both trees differs only where the claims say it should.

## What I ran

- **Fault sweep, both trees.** 476 single faults × 3 games × 3 settings × 4 instants. The faults: 91 fields of the state, the same 91 in the record's copy and in `before`, 28 on `record.texts`, 168 on observers, 7 on the request lists. The instants: between rounds; after the work (the `fault` hook); `late` 1; `late` 2.
- **Early-instant sweep, on a copy.** The same faults at four instants between the gate's first look and the end of the work. This needed a test-only hook, which I added to a separate copy, not to `after/`.
- **Tests in `after/`.** 21 of the 45 by name, all passing. I did not run the full suite, as instructed.
- **Broken copies.** The new tests run against a copy of `after/` broken in 12 ways.
- **`limits.js`.** 0 wrong of 52.
- **My own script on port 8183.** 30 checks, 0 wrong.
- **Injected stops.** A copy of `after/` with panics put in at four places.

My throwaway tests went into both test modules through `include!` lines, which I have removed. `before/src` and `after/src` again differ exactly as `changes.diff` says. Nothing is listening on 8183.

## The seventeen claims

### 1. The new branch of `restore()`: holds, with one exception

**What can disagree after one fault** (`watch.rs` 684–734):

| Fault lands in | When | Found by | Branch taken | Result |
| --- | --- | --- | --- | --- |
| state | between rounds | observers (`watch`) | halves agree, 688–693 | state put back |
| record text | between rounds | gate, 456 | second, 700 | text from copy |
| record copy | between rounds | gate, 456 | first, 698 | copy from state |
| an observer's copy | between rounds | observers | halves agree | nothing to put back; observers started again |
| state | inside a round | rules or second doing, 570–578 | halves agree | round undone |
| record text | inside a round, part moved | gate's second look at the observers, 580 | **new, 713** | text from copy, state back to copy |
| record text | inside a round, part not moved | 580 | second, 700 | text from copy |
| record copy | inside a round | second doing or rules | third, 702 (first if not moved) | state and copy from `before` |
| an observer's copy | inside a round | 580 | halves agree | round undone |
| text or copy | after 580, before 635 | not found | none | overwritten by the new record |
| `before` | any time | never looked at | none | overwritten at 810 next round |

- **It cannot take a faulty value.** The new branch takes the record's copy, and only when the copy, the part as the round began, and every observer of the part say the same. Observers take their copies from the state (621–625), not from the record, so one fault cannot make them agree with a wrong copy. `before` is only a witness there, never a source.
- **It changes no earlier outcome.** It sits after the three older branches and before the refusal, so it is reached only where `restore()` refused before.
- **Confirmed by running.** In `before/`, 99 sweep cases (33 per setting) end `stuck`; all are a text fault during the work on a part the work moved. In `after/` all 99 are put right. Under "after a pause" (waiting out the pause, not asking) and "on a click", the state is exactly as the round began. Under "at once" it equals a game in which that round was never worked. Every other case is identical in the two trees, to the final state. No case in `after/` ends `stuck`, halts twice, or is left inconsistent, in either sweep.

**The exception, confirmed by running under all three settings.** One fault lands while a round is worked (any kind; I used `world.tally.caught += 5` and a text fault). It is put right. In the first round worked after that, `record.texts[2]` is faulted. The game ends `stuck`: "twice running, the gate found the copies of the legs A observer changed while the round was being worked". The second fault lands after the first was put right, so your fault model allows it. The cause is `spoiled` (846–856), which counts a fault in the gate's own record as the work going wrong. That rule is older than the change. With one recorded round between the two faults, both are put right.

### 2. `shaped()` and a reason with no flag: holds

- **Found by the ring.** `rule()` calls `shaped(j)` for every other member (389), so they report "the X observer has been changed".
- **No false halts.** The program sets `why` only together with `flagged` (422–423, 439–440), and `born()` clears both. So flag down with a reason can only come from outside.
- **During a halt and after `correct()`.** `rule()` runs before the round's flags are written (415–425), and new observers are clean (660).
- **Confirmed.** In the sweep, the 216 cases of a `why` fault differ between the trees only in the reason said. All 1,512 observer faults per setting end with one halt and one restart in both trees. The half-hour fault-free test passes.

### 3. Lines kept with `during`: holds

Kept lines never begin with `during` (`door.rs` 118), so `write_now` does what `run` did for them. `record_now` reads none of the new fields. Confirmed: 153 cases (17 sets of lines × 3 games × 3 settings) give the same state, record, halts and reasons in both trees. Only `passed` differs, for lines that could not be written whole.

### 4. Saturating counters and `begin_again()`: holds

The diff shows nothing else in these functions. The seed of a game begun again now comes from `games`, not `rounds`, which is the stated change.

### 5. `Observer::shown`: holds

- `written()` is byte-identical in the two trees for observers with awkward texts (207,812 bytes, same fingerprint).
- With quotes, backslashes, newlines, NUL, U+2028, and 2-, 3- and 4-byte characters in every text, and the cut at every offset in a run of 4-byte characters, every frame parsed as JSON. Name, list and reason were at most 163 characters, copies at most 27. I checked this in a test and over the live stream.

### 6. The door's sizes: holds

- `short()` cuts at a `char_indices` boundary (`door.rs` 85–90). The cut in `parts_of` steps back to a boundary (170–177).
- I ran cuts landing inside 2-, 3- and 4-byte characters; none panicked.
- The 1,024 check comes before anything is written (243–247, 124–126).
- A small change of behaviour: at exactly 64,000 bytes said, the next part is now not done (162, `>=`); before it was.

### 7. Places: holds

- Only `admit` adds to `open` and only `screen` adds to `screens`, each under its lock and after making room.
- Only the accept thread raises `held`, after checking it (207, 215).
- `Place` gives the place back on drop (77–83). The spawn-failure path does it by hand, with no `Place` made (222–225).
- Confirmed: `limits.js` saw at most 261 threads and a return to the starting count. On my copy, 300 panics inside `serve` lost no place.
- Argued only: the failed-spawn path.

### 8. Who is put out: holds, with one narrow race argued only

- **Confirmed.** With 32 open, the 33rd was served. The one put out was the one that had waited longest, not the first to connect; then the next longest. With all 32 being answered and not reading, a 33rd was served in 11 ms. A ninth screen puts out the first. 56 non-reading screens never cost the door a place.
- **The race.** `screen()` sets the flag (142–145) before it evicts. If 24 connections ask for the stream in the same instant on top of 8 screens, every place is briefly a screen's and `admit` refuses one connection (116). The window is microseconds. I did not reproduce it.

### 9. Acted on only if still in `open`: holds

Every action follows `answering(id, true)` at 443, and `/stream` checks again in `screen()`. Confirmed: a `POST /how` whose last byte arrived after 40 new connections had put it out changed nothing; the same request with no crowd was done. The check and the action are not one step, which the claim's wording allows.

### 10. Locks: holds, argued only for poisoning

- The only nesting is `screens` then `open` (146–151); nothing takes them the other way.
- The game lock is never held with another, nor across a write (466–470, 237–257, 521–528).
- Under `open` and `screens` only `shutdown` is called.
- Every use goes through `kept()` or handles poison (74, 92–100, 524). I did not poison one to see.

### 11. Waiting: holds

Measured:

| Peer | Result |
| --- | --- |
| one byte every 250 ms | 408 at 10.3 s |
| body dripped, never complete | 408 at 10.0 s |
| first line only, or one byte only | 408 at 10.0 s |
| nothing asked | closed at 15.0 s |
| endless header lines, or one endless line | refused at once |
| a whole request every 12 s | kept |

After a timed-out read, all three call sites return without reading again (383, 325–328, 282–285). The bound on writes is per write: a peer that keeps asking and reads slowly keeps its thread, by design.

### 12. Where a request says it is from: holds

2,079 requests (3 method/path pairs × 7 `Host` × 11 `Origin` × 9 `Sec-Fetch-Site` values) were all taken or refused as claimed. Non-POST methods on `/how` got 404 and changed nothing. One note: when a header is sent twice, the last one counts (409–416). `Origin: elsewhere` followed by the program's own origin is taken. No browser sends that.

### 13. The game's thread ending: fails in one case; the second sentence holds

- **Counterexample.** `eprintln!` (181) runs before `process::exit` (182), and `eprintln!` panics when stderr cannot be written.
- **Confirmed on a copy of `after/`** with a panic placed in `play()` after a round. With stderr read, the process ended with code 1 at 2.0 s. With the reading end of stderr closed, it was still running ten seconds later: the page answered 200, the stream sent one stale frame and no more, and the door answered with `spider.body.age` unchanged.
- **Fix.** Exit first, or ignore the failed write.
- **Second sentence.** A panic inside a round gave a `stuck` halt and a running program, and "Put it right" began game 2. Confirmed on the copy.

### 14. Keep-alive: holds

Five requests in turn on one connection each got 200 and no `Connection: close`. A 404 came with `Connection: close` and the connection was closed. Of four sent at once with the third answered 400, three were answered and the fourth was not.

### 15. The page: holds, by reading only

My own diff of the two pages shows only the three stated changes. Server text reaches the page through `textContent` (313, 362–363, 437, 457, 536, 560–563, 579), `className` and `title`. There is no `innerHTML` or the like. I did not run it in a browser.

### 16. The four new tests: each fails when its subject is broken; weak spots below

Run against a copy broken on purpose:

| Broken | Test result |
| --- | --- |
| new branch never taken | first test fails |
| `shaped()` ignoring `why` | fourth fails |
| unwritten lines put in `pending` | third fails |
| `write_now` always true | third fails |
| `let_through` not cut | second fails |
| 1,024 text check removed | second fails |
| 1,024 kept-line check removed | second fails |
| observer texts sent whole | second fails |

Weaker than they look:

- **The new branch's observer condition is untested.** With `&& self.all_hold(p, &kept)` removed from 713, all five tests that make the record disagree with itself still pass.
- **Multi-byte text is untested.** With the boundary loop in `parts_of` removed, or `short()` cutting by bytes, the tests that reach them pass. The only multi-byte text in the test module is an en dash in the shelf; `limits.js` has none.
- **First test, "after a pause".** It calls `put_right()`, so the pause itself is never waited out.
- **First test, "at once".** It checks only what was said and that the game goes on, not the state against anything.
- **First test, the reason.** It pins "the gate found the copies of the … observer changed", which blames an observer for a fault in the gate's own record.
- **Third test.** It pushes into `inside` directly, not through the door.
- **Fourth test.** It runs under one setting and four of the eight observers.

### 17. The README: four sentences are not exact; the rest I checked is true

- **Line 173–174**, "the state is left as it was found". Parts before the unsettled one are put back in the attempt. Run: with the body's record unsettled, the legs were put back and the body, moths and seventh part were left.
- **Line 297–299 and the table at 517**, a screen is sent only the first 160 characters of an observer's list. The moths observer's whole list also goes out as `halted` (`watch.rs` 1032); I saw 5,000 characters sent.
- **Line 208 and 513**, "no more than 64,000 characters". The count is bytes, and the notes come on top: `limits.js` got 64,141 back.
- **Line 540–542**, "the whole program stops". See claim 13.

## Other things wrong or risky

- **Refusals often do not reach the sender.** The connection is closed with unread data, which resets it. A 413 for a full 70,000-byte body was lost 3 times of 6. A 403 for a 60,000-byte body from another origin was lost 5 of 6. The 503 at 256 held arrived as nothing in `limits.js`. `refuse()` drains first; the other paths do not.
- **Older than the change: a number that is not one makes the stream invalid.** One fault setting a kept catch's `worth` to NaN makes every frame during the halt `"rate":NaN`, which is not JSON (`watch.rs` 1035, 1037). I ran this. From the page's source, the page then shows nothing new and, under "on a click", never enables the button; I did not run that part in a browser.
- **A link from another site gets 403.** Opening the page from a link on another site, or on another local port, is refused. The README says so; it may surprise.
- **`unwritten` counts rounds, not lines.**

## What I could not check

- The full test suite, and the stated run times: by instruction.
- The page in a browser.
- Poisoned locks, the failed-spawn path, and the all-screens race: argued only.
- Any system but this Windows machine. The waits depend on socket timeout behaviour.
- Faults landing inside `restore()` or `correct()`, or in values outside your list (`rounds`, `halt`, `spoiled`, `pending`, `inside`).

Everything of mine is in `«WORK»\verify-two\mine\`:

- `sweep.inc.rs`, `early.inc.rs`, `during.inc.rs`, `extra.inc.rs`: the throwaway tests
- `out-before\`, `out-after\`, `out-early\`: their results
- `live.js`, `live-1.txt`, `live-2.txt`: my live checks
- `limits-out.txt`: the `limits.js` run
- `mutcopy\mutate.sh`, `mutate-out.txt`: the broken copies
- `exitcopy\`, `exitcheck\`: the injected stops
- `earlycopy\`: the copy with the early hook
