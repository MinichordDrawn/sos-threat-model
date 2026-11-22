# Check of the six documents against the code in `now/`

Four statements are wrong, fifteen are narrower than stated, and five cannot be told from the folder. The counts (55 tests, 53 checks, eleven plans) all hold. The wrong ones are about what an observer on its own thread does and does not do; in each I think the documents are the wrong side, not the code.

## How I worked

- I read the code first, then each document, then `documents.diff` line by line.
- From `now/` I ran two named tests with the given command: `an_observer_that_does_not_answer_is_silent_and_is_replaced` and `observers_on_threads_of_their_own_keep_up_with_the_rounds` (the second with `--nocapture` to see its print). Both passed.
- To settle four statements I made a temporary copy of `now/` in a `scratch` subfolder inside the folder you gave me, added six probe tests to the copy, ran them and deleted the copy. `now/` is as you gave it, plus `now/target` from the builds. The probes are called X1 to X6 below.
- I did not run the program, `limits.js`, `drive.js`, `wiring.py` or the whole suite.

Line references to `watch.rs`, `main.rs` and `backdoor.rs` are to `now/src/`.

## Wrong

**W1. An observer that does not answer is not found by the others of its ring.**
- README.md:154 (P1): "One that is stopped, or that has not answered when the round's waits are used up, is found by the others of its ring and by the gate".
- README.md:159 (P6): "An observer's loss is seen by every other observer of its ring, and by the gate".
- observation.md:263-264: "one that stops or sticks is lost alone and found by the rest."
- Code: the round's thread writes `beat = rounds` for every running observer before it builds what they are sent (watch.rs:402-411). The others read that `beat` from what they are sent (watch.rs:1134-1136), so each sees the one that will not answer as having signalled. Only after the wait does the round's thread take the signal back (watch.rs:416-426) and give the reason "did not answer in time" (watch.rs:437). `respond()` (watch.rs:457-459) and the gate's `observers_off` (watch.rs:493) then see the silence.
- Probe X1: with the `body` thread stalled, on a click, no observer had a flag up in any of four rounds; the reason stayed "the body observer did not answer in time".
- The statements are true for an observer stopped by `alive = false`, whose `beat` is not written.

**W2. The others of the world's ring do not work the list of halted moths out for themselves.**
- README.md:200-202 and observation.md:89-90: "The others of its ring work the list out for themselves in every round and compare."
- Code: the list is worked out once, by the round's thread, in `look()` (watch.rs:382), and sent to all eight as `Look.in_web` (watch.rs:1104-1109). Each observer only compares the `moths` observer's `held` with it (watch.rs:1146).
- observation.md:48-50 itself lists "the moths that are in the web" among what the observers are sent, so the two passages disagree with each other.
- The comments at watch.rs:20-22 and watch.rs:1145 say the same as the documents and are wrong the same way.

**W3. A change to how many copies an observer holds does not stop the program in the wrong place, and the game does not have to be begun again.**
- observation.md:330-333: "How many observers there are, how many copies each holds, … A change to one of them stops the program in the wrong place, and the game has to be begun again."
- A copy too many: the gate compares the whole list (watch.rs:496). Probe X2, run together and on threads: halted with "the gate found the copies of the legs A observer changed, and no observer had flagged it", put right, seven copies again, and the game went on with one halt and no panic.
- A copy too few, as the program runs them: `in_shape` (watch.rs:1114) panics on the threads of the three other observers of that ring, and not on the round's thread. Probe X3: halted with "the legs B observer did not answer in time", put right with eight new observers, and the game went on.
- A copy too few, run together as in the tests: the round's own thread panics, which is what the statement describes.
- The statement holds for how many observers there are. Probe X4: with nine the round's thread panics (watch.rs:437 or 1119). With seven, on threads, there is first an ordinary halt ("the whole observer did not answer in time") and the panic comes at the putting right (watch.rs:665).
- Related, checks.md:142-145: "what is done when the program stops in the wrong place … it must leave a game not yet begun, halted". A panic on an observer's own thread ends that thread only and comes out as a silence. observation.md:240 and outside.md:62-66 carry the qualifier ("while it has hold of the game"); checks.md does not.

**W4. An observer does not write or check its own signal; the round's thread does both.**
- observation.md:82-85: "It writes it again in every round, and before it does, it checks that what is there is the round before's. So a signal changed from outside is found by the observer itself".
- checks.md:22-23: "written from outside, it must be found by the observer itself."
- Code: both are done in one loop in `watch()`, in the round's thread, for every running observer, before any is asked (watch.rs:402-409). An observer's thread is never shown its own last signal: what it is sent carries the ring after the overwrite, and `look_of` reads only the others' beats (watch.rs:1134).
- This also contradicts observation.md:50-51, "Each looks at that and at nothing else". It was a way of speaking while everything was one thread, and the change made it false.
- The documents disagree with each other on the same point. README.md:154 says an observer's "answer is its signal, `beat`". README.md:206-207 says "it signals. Then all eight are asked to look". The code writes the signal before asking (watch.rs:407) and withdraws it if no answer comes (watch.rs:422).

## Narrower than stated

**N1. Set to end at once, the round's work is done without the eight threads having looked at what it is done on.**
- README.md:155 (P2): "the round asks all eight to look and waits for them before the gate checks and the work is done". README.md:12-13 and observation.md:125-126 ("every new observer look once more") say the same.
- After a putting right, the look "once more" is `self.rule(i)`, made in the round's thread (watch.rs:674), also when the observers are on threads. The eight new threads (watch.rs:669-671) are first asked in the next round, and at once the work follows in the same round (watch.rs:843).
- Probe X5: at once, with `body` stalled, the round halted, was put right, did its work and was recorded.

**N2. Four tests run the observers on threads, not one.**
- observation.md:53-56: "In the tests the observers are run together … One test runs both ways side by side".
- 51 of the 55 run them together. The four on threads are at watch.rs:3158 (both ways), 3190, 3218 and 3243. checks.md:169-177 describes all four correctly.

**N3. Not all eight are asked in every round.**
- README.md:189 and observation.md:48: "Every round all eight are sent what there is to look at". README.md:154: "Every observer is asked to look in every round". README.md:206-207: "all eight are asked to look".
- A stopped observer is sent only a tick (watch.rs:1244-1246). One that has not answered is not asked again, as observation.md:53 says. In a halt that cannot be put right nobody is asked (watch.rs:783-793).

**N4. The record's two halves are no longer the first thing the gate checks.**
- README.md:240-241: "the gate checks the two against each other before it looks at anything else". observation.md:102-103: "In every round, before it looks at anything else, the gate checks that the two halves say the same thing."
- observation.md:306-307 says the same of the number of the round: "before anything else". Both cannot be first.
- Code: the two numbers of the round are compared first (watch.rs:797), then the observers look (watch.rs:817), then the halves are compared (watch.rs:463-468), and that only while no halt is in force (watch.rs:819).

**N5. The number of the round is settled by the running observers only.**
- observation.md:307-308: "the one that every observer's signal agrees with is the right one".
- Code: stopped observers are not counted (`!o.alive ||`, watch.rs:799).

**N6. Some arguments that are not a usable port are taken.**
- outside.md:49-50: "The one argument the program takes is its port. An argument that is not a port is refused, and the program does not start."
- Code: `args().nth(1)` is parsed as a `u16` (main.rs:167-179). So `0` is taken, and the program starts on whatever port the system gives it while answering only to `localhost:0`. Anything after the first argument is ignored without a word.
- This is from reading; I did not run it, since that would break your rule on ports.

**N7. The test does not try every kind of write.**
- checks.md:166: "Every kind of write in a halt that cannot be put right, which the backdoor must refuse".
- The test tries five lines (watch.rs:3146): `+=`, `push()`, `pop()`, `[*] =` and two writes in one line. It has no `during` line, no write to a `copies[..]` and no `-=`, `*=` or `/=`.
- The statement in backdoor.md:68-70 is true of the code all the same. Probe X6: each of those is refused, `during` with the older message "everything is halted: there is no work for this to be written during" (backdoor.rs:122-124), and reads still answer.

**N8. "Nothing moved" is not required at once, and is not so.**
- checks.md:171-174: "An observer that stops answering, under each way a halt can end: it must be silent, everything must halt with nothing moved".
- The test requires it under two of the three settings (watch.rs:3205-3207). At once, the round's work goes on (probe X5). "Silent" is required only through the reason given.

**N9. The program does stop asking an observer.**
- README.md:158 (P5): "Nothing in the program turns an observer, the gate or a check off." observation.md:266: "Nothing can be switched off."
- Code: one that was late once is not asked again (watch.rs:1262-1267) until the halt is put right. On a click that is until the click. It counts as silent all that time, so everything stays halted.

**N10. In a halt that cannot be put right, one thing is still done.**
- README.md:230-231: "nothing at all is done: the round ends before it begins."
- Code: each observer's thread is still told that a round has gone by (watch.rs:789-791, 1276-1280). checks.md:174-176 says as much.

**N11. Two wrong rounds running do not stop the game "whatever made each".**
- README.md:40-41: "two wrong rounds running stop the game, whatever made each."
- README.md:226-227 and observation.md:234-235 except a round for which a line was kept at the backdoor, and so does the code (watch.rs:885-888). This sentence is not in the diff.

**N12. "The check of the last change" no longer names the last change.**
- README.md:397, README.md:423 and checks.md:144 use the phrase for `review-change.md`.
- The last change to the code is now the one the ring map led to, which README.md:434-435 says no reviewer has read.

**N13. An observer is more than a name and a place in a few lists.**
- README.md:299-301: "an observer is a name and a place in a few lists".
- It is now also a thread with a channel of its own (watch.rs:1222-1228). "A larger ring is little more than longer lists" still holds, since the threads are started from the list of names.

**N14. Something does run for P2 now.** This one is a judgment.
- README.md:163-164: "P2, P5 and P7 are met by how the program is built. Nothing runs for them, and there is nothing to test".
- P2's own cell now describes asking and waiting in every round, and four tests exercise it.

**N15. The list of the gate's bookkeeping leaves out what the change added.**
- README.md:328-330 says observation.md has "everything that is not observed"; the list is at observation.md:301-305.
- Not on it: what the program holds once for the threads, namely the number of waits and their length, the count of quiet seconds, which starting of the observers this is, and the channels (watch.rs:1185-1198).
- This is close to "things the documents could add". I report it only because of the word "everything".

## Cannot be told from the folder

- **The measurement** (README.md:192-194): "0.85 thousandths of a second, and no round used one of its waits". The thing measured exists (watch.rs:1269-1272) and the test prints it (watch.rs:3251-3252). My one run, on a machine in use, printed 2.94 ms as the longest and 0 of 8 waits.
- **The trial** (checks.md:186-188): the mechanism exists. Each observer counts five waits of one second with nothing heard (watch.rs:1160, 1203, 1313-1318) and then calls `rounds_stopped`, which ends the program (main.rs:257-266). Not run.
- **A machine that stands still** (README.md:191-192): "uses up one of them and no more". The code does count timeouts and not time (watch.rs:1249-1257). Whether a stall costs exactly one depends on the standard library's `recv_timeout`.
- **Timings and "all pass"** (README.md:377, README.md:415, checks.md:183): the two tests I ran pass. The rest of the suite, the limits and the plans I did not run.
- **The rest of the shape** (observation.md:330-333): what a change to "where a list keeps its length" or "what kind of thing a field holds" does cannot be made in the program's own terms.

Left out as you asked: what the ring map and the earlier reviews found (checks.md:310-321, README.md:392-396, the "six places"), and the missing `test/review-*.md`.

## Counts

| What | Documents | Code | How counted |
| --- | --- | --- | --- |
| Tests | 55 (README.md:377, 415) | 55 | `#[test]` attributes in `watch.rs`; `cargo test` also reported 55 |
| Limits checks | 53 (README.md:386) | 53 | 41 places where `check(` is called; three are in loops of five (limits.js:63-64, 73-79, 80-86), so 38 + 15 calls in a run |
| Plans | eleven (README.md:387, 415; checks.md:222) | 11 | the keys of `plans` in `drive.js`; the names and their order match checks.md:224-225 and drive.js:4 |

## The documents against each other

- The numbers agree everywhere they are given, and with the code: eight waits of 5 ms (README.md:190-191, observation.md:51-52, outside.md:32; watch.rs:1158-1159), five seconds (README.md:197, observation.md:339, outside.md:33, checks.md:187; watch.rs:1160), 30,000 rounds (README.md:193, checks.md:176; watch.rs:3250), ten lines (checks.md:170; watch.rs:3165-3176).
- The disagreements are those under W2, W4, N4, N9, N11 and N12.

## Changed lines I found true

- **Threads and waits.** Each observer on a thread of its own in the program (main.rs:193). What they are sent (watch.rs:1104-1109). "Not asked again", and eight new threads at a putting right and at a game begun again (watch.rs:669-671, 1001-1003). An old thread ending when nothing can call it, and a stuck one left behind (watch.rs:1216-1229, 1321).
- **Legs.** The count is written out with each set (watch.rs:204) and put back with the set (watch.rs:183-186); the test is at watch.rs:3104.
- **Number of the round.** Held twice and settled from the signals (watch.rs:797-814); the test is at watch.rs:3122.
- **Two wrong rounds.** "Not counting a round for which a line was kept" (watch.rs:885).
- **Backdoor.** Writes refused in a halt that cannot be put right, with reads still answered (backdoor.rs:213-216, 258-260).
- **Outside.** A write wait that cannot be set means the connection is not served (main.rs:226-228), and a read wait likewise (main.rs:377-379). A request that changes anything needs an `Origin` header that names the page (main.rs:496-502). The limits check with a non-port argument is at limits.js:217-222 and expects exit code 2 (main.rs:176).
- **Scope.** "Three sides, the third in two ways" matches the four points under it.

## The six documents

I read all six in full.

- **README.md**: findings above.
- **observation.md**: findings above.
- **checks.md**: findings above.
- **outside.md**: one finding (N6).
- **backdoor.md**: no findings.
- **gameplay.md**: no findings. Nothing in it touches the change.

## What I did not reach

- `game.rs` and `rules.rs`: not read through. I only looked up `SETS` and the use of `in_web`.
- `page.html`: only searched.
- `drive.js`: only its head and its list of plans.
- The tests in `watch.rs` between about lines 1540 and 3095: read only where a changed statement turned on them.
- Statements the change does not touch were not checked again: the game's numbers in gameplay.md, the table of rules in observation.md, the older rows of the table in outside.md (their constants in `main.rs` and `backdoor.rs` do match where I saw them), the older descriptions of tests in checks.md, and what the page does.
- N6 and the second half of W3's "stops the program in the wrong place" as the program itself would handle it (`fail()` after a caught panic) are from reading. The probes ran the game inside tests, not the server.
