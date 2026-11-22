# The protocol of One Spider's gate: a specification

This is a description of the protocol in `code\src\`, written so that a model can be made
from it without the code. It is about what is stored, what a round does with it, what a
detection and a halt are, and how things are put right. It is not about the game: what the
spider and the moths do is left as an unknown function (section 12).

Every item has a number, and beside it the function and lines it is taken from. Lines are
those of `code\src\watch.rs` unless another file is named. Section 12 lists what this
description leaves out, and section 13 what it assumes.

Words used throughout: a *part* is one of the seven parts of the state. A *text* is a part
written out. A *place* is one of several copies of the same thing. *Voted* means read from
two places that agree (section 3).

## 1. Names and numbers

| Item | What | Code |
| --- | --- | --- |
| N1 | Seven parts, numbered 0 to 6: first set of legs, second set of legs, body, edge, moths with counts and shop, web, and the game's own (pointer, requests and chance). | `PARTS` 65, `OWN` 67 |
| N2 | Eight observers, numbered 0 to 7: legs A, legs B, body, whole, edge, moths, page, web. | `NAMES` 64 |
| N3 | Two rings. The spider's ring: observers 0, 1, 2, 3 and parts 0, 1, 2. The world's ring: observers 4, 5, 7, 3, 6 (in that order) and parts 3, 4, 5, 6. The rings are gone through in that order, and their members and parts in the order given. | `RINGS` 72 |
| N4 | The coordinators are observers 3 and 6. Observer 3 is in both rings. | `COORD` 74 |
| N5 | The moths observer is observer 5. | `MOTHS` 76 |
| N6 | Observer `i` *sees* part `p` when some ring has `i` among its observers and `p` among its parts. So 0, 1, 2 see parts 0 to 2; 4, 5, 6, 7 see parts 3 to 6; 3 sees all seven. | `sees` 124-126 |
| N7 | The order in which new observers are made: 6, 3, 0, 1, 2, 4, 5, 7. Each new observer is made from the gate's record and the book's `rounds` alone, so the order changes nothing that is stored. | `START` 78, `correct` 1147-1151 |
| N8 | The three settings for how a halt ends: at once, after a pause, on a click. A new game is set to after a pause. | `How` 103-110, `Book::new` 369 |

## 2. What is stored

| Item | What | Copies | Code |
| --- | --- | --- | --- |
| S1 | **The state.** Seven parts. The work reads and writes it. | 1 | `Game.spider`, `.world`, `.own` 413-420 |
| S2 | **The observers.** Eight. Each has: `name`; `alive` (running or stopped); `beat`, the number of the round it last signalled in; `copies`, a place for each of the seven parts; `held`, a list of halted moths; `flagged` and `why`, its flag and its reason. | 1 of each observer; through the observers' copies, each part is held once by each observer that sees it | `Observer` 133-141, `Game.ring` 415 |
| S3 | **The gate's record, written out.** One text for each part. | 1 | `Record.texts` 260 |
| S4 | **The gate's record, as a copy.** A copy of each part. With S3 this makes the record two halves. | 1 | `Record.spider`, `.world`, `.own` 261-263 |
| S5 | **The book.** What the gate keeps of its own besides the record. The fields that the protocol reads: `halt` (nothing, or a halt, S6); `how` (the setting, N8); `spoiled` (how many rounds running the gate has refused); `stops` (section 12, A12); `rounds` (the number of the round); `at` (what the clock last said) and `time` (the game's own time); the counts `halts` and `restarts`. The other ten fields are what is said to a screen and what waits to be written during the work (A9, A10): here they are one value, `rest`, which no step reads or writes. | 3 | `Book` 324-357, `Game.books` 419 |
| S6 | **A halt**, inside the book: `why`; `quiet`, a time; `last`, the state as it was last seen during the halt, or nothing; `asked`, whether the halt has been asked to end; `stuck`, whether it cannot be put right. | with the book | `Halt` 301-311 |
| S7 | **The state kept from when a round's work last began** (`before`): nothing, or a whole state. | 3 | `Game.before` 430 |
| S8 | **What was asked of the game** and not yet taken in: a list. | 3 (`asks`, `asks_again`, `asks_third`) | 424-426 |
| S9 | The game's hold on its observers' threads, and what those threads are run by. Not in this description: see A7. | 3 each | `Game.apart` 434, `Threads.run` 1853 |

## 3. Reading what is kept in three

| Item | What | Code |
| --- | --- | --- |
| V1 | **The book, voted.** If place 0 is the same as place 1, or as place 2, place 0 is read. Otherwise, if place 1 is the same as place 2, place 1 is read. Otherwise place 0. Every reading of a field of the book in sections 4 to 9 is voted, at the instant it is made. Two places are the same when every one of the book's nineteen fields is, and every one of the halt's seven (numbers by their bits): so also when `rest` is. | `Deref for Game` 456-468, `Book::same` 373-407 |
| V2 | **The book, written.** Every write the gate makes to the book is the same change made to each of the three places separately. A place that differed before the write may still differ after it. "One more" (`rounds` in R7, `halts` in D11, `restarts` in P2, `spoiled` in R38) is one more in each place than that place had. Where a write has a condition on the book (D12, E2, and the write in P1: "if there is a halt"), the condition is looked at in each place for itself, not voted. | `keep` 472-476 |
| V3 | **`before`, voted.** The same rule as V1 over the three places of S7, compared whole (written out). | `began` 511-515 |
| V4 | **What was asked, voted.** The same rule as V1 over the three lists. | `asked` 555-563 |

## 4. Small definitions

| Item | What | Code |
| --- | --- | --- |
| D1 | `text(p)`: part `p` of the state, written out. `kept(p)`: part `p` of the record's copy (S4), written out. | 663-669 |
| D2 | `fingerprint(t)`: a short mark of a text (a 32-bit number, written in digits). Two texts may have the same mark. | 235-241 |
| D3 | `holds(i, t)`: what observer `i` holds of a text `t`. A coordinator holds `fingerprint(t)`. Any other observer holds `t`. | 243-245 |
| D4 | `print_of(i, h)`: the mark of what observer `i` holds. For a coordinator, `h` itself. For any other, `fingerprint(h)`. | 246-248 |
| D5 | `copies_for(i, texts)`: the copies observer `i` should have. In place `p`: `holds(i, texts[p])` if `i` sees `p`, and the empty text if not. | 250-252 |
| D6 | `in_web(state)`: the list of the moths that are in the web, worked out from the state (from its world). There are two texts of this function, a first and a second (A3). | `game.rs` 736-739, `game\again.rs` 390 |
| D7 | `held_of(i)`: the list observer `i` should have. For the moths observer, `in_web` (first text) of the record's copy. For any other, the empty list. | 674-676 |
| D8 | `sound(i)`: observer `i` is `alive` and its `beat` is the book's `rounds`. `flagging(i)`: `sound(i)` and `flagged`. | 685-692 |
| D9 | `all_hold(p, t)`: every observer `i` that sees `p` has `holds(i, t)` in place `p` of its copies. | 678-680 |
| D10 | `born(i)`: a new observer: its own name, alive, `beat` the book's `rounds`, copies `copies_for(i, the record's texts)`, held `held_of(i)`, no flag, no reason. | 682-684 |
| D11 | `stop_all(why, now)`: everything halts. Written to the book: `halts` one more; `halt` becomes a new halt with this `why`, `quiet` = `now`, `last` nothing, not asked, not stuck. | 926-936 |
| D12 | `stick(why)`: written to the book: if there is a halt, it becomes stuck, not asked, with this `why`. | 963-972 |
| D13 | A new game at time `now`: a new state; the record's texts and copy both made from it; eight observers `born` from that record; the three books new (no halt, after a pause, all counts nought, `rounds` 0, `at` and `time` = `now`); the three lists empty; the three places of `before` nothing. | `Game::new` 635-661, `Book::new` 368-370 |

## 5. The observers' rule

Each observer has its own copy of one rule (`code\src\watch\looks.rs`; A6). An observer is
given a *look*: `rounds`; `last`, the number its own last signal and every other's should
carry; the seven texts of the state as they are; the eight observers as they are; and the
state's world (for `in_web`). It answers with the first thing it finds, or with nothing.
(`Look` 1787-1793, `look` 721-723, `look_of` 1807-1810.)

Observer `i` looks in this order (`looks.rs` 37-92, the same in all eight copies):

| Item | What it checks | What it answers if not |
| --- | --- | --- |
| L1 | It has been given eight observers and seven texts. (Always so here: A8.) | so |
| L2 | Its own `beat` is `last`. | its own signal changed |
| L3 | For each ring it sits in (in the order of N3), for each part `p` of that ring in order: `holds(i, text p)` is its own copy of `p`. | the part changed |
| L4 | Then, for that same `p`, for each other observer `j` of the ring in order: `j`'s copy of `p` agrees with its own. If `i` or `j` is a coordinator, they agree when `print_of(j, j's copy)` = `print_of(i, own copy)`. Otherwise when the two copies are the same. | `j`'s copy differs |
| L5 | After all the parts of the ring: for each other observer `j` of the ring in order: `j` is alive and `j`'s `beat` is `last`. | `j` is silent |
| L6 | And, for that same `j`: `j` is in shape. In shape means: it has its own name; a place for each part, empty for every part it does not see; an empty `held` unless it is the moths observer; and no reason without a flag. | `j` has been changed |
| L7 | After the observers of the ring, if the moths observer is in the ring: the moths observer's `held` is `in_web` (first text) of the look's world. | the list of halted moths has been changed |

## 6. Between two rounds

The game is behind one lock (`main.rs` 60, 99-109). A round holds it from start to end.
Everything below happens between two rounds, one thing at a time.

| Item | What | Code |
| --- | --- | --- |
| E1 | **Something is asked** (the pointer moved, a press, a letting go, an upgrade). In a halt that cannot be put right, nothing is taken down. Otherwise it is first decided whether it is taken at all: a press or an upgrade is not taken while everything is halted, nor when eight of its kind already wait in the voted list (V4). If it is taken, it is taken down in each of the three lists separately, by one rule that looks only at that list and at whether everything is halted. | `point` 1569, `press` 1578, `release` 1584, `buy` 1609, `ask` 1539-1563, `waiting` 1565 |
| E2 | **The halt is asked to end** ("Put it right"). Written to the book: if there is a halt, it is asked. | `put_right` 1659-1665 |
| E3 | **The setting is changed.** Written to the book: `how`. | `set_how` 1655-1657 |
| E4 | A line at the backdoor that writes to the state or to an observer. In this description that is a fault (section 11); a line that writes to several cells at once is several faults. A line kept to be written during the work is not described (A9). | `backdoor.rs` 122-157 |

## 7. A round

A round is given what the machine's clock says. (The tests give a round its length and its
time directly: R1 and R2 say what differs.) The steps are in the order the program does
them. A step that is skipped is skipped whole. "Halted" means the voted book has a halt.

The round keeps some things of its own while it runs, which are not stored anywhere else:
`dt` and `now`; `began_halted`; `running`, the look and the answers; `stop` and `off`;
whether it is halted, as R14 to R18 take it (read once, before R14);
which observer was late and what the observers told (R11, R12); `held`; `asked`; what the
first text of the rules said (R28); whether the round is refused; `made`; `seen` and
`held_now`. They are named where they are set.

### 7.1 The gate's own

| Step | What it reads | What it does | Code |
| --- | --- | --- | --- |
| R1 | the three books | **The books are compared** (`settle_books`). If all three are the same, nothing. If one differs from two that are the same: all three become what the two are; then, if not halted, `stop_all` (D11). If no two are the same: all three become place 0; then, if not halted, `stop_all`; then `stick` (D12). The time given to `stop_all` is the book's `time` (in a test, the round's `now`). | `round_at` 1316-1317, `round` 1334, `settle_books` 480-509 |
| R2 | the book (voted) | **The round's length and time.** `dt` is worked out from the book's `at` and the clock, and `now` from the book's `time` and `dt`. If the clock could be read, `at` := the clock, written to the book. (In a test, `dt` and `now` are given, and `at` := `now`.) | `round_at` 1318-1323, `length` 622-627, `round` 1335 |
| R3 | the three books | The books are compared again, exactly as in R1, with `now`. | `turn` 1345 |
| R4 | the three places of `before` | **`before` is compared** (`settle_before`). If all three are nothing, nothing. If all three are the same, nothing. If one differs from two that are the same: all three become what the two are. If no two are the same: all three become nothing. In both of the last two cases, if not halted, `stop_all`, with `now`. | `settle_before` 519-542 |
| R5 | | `time` := `now`, written to the book. | 1347 |
| R6 | the book (voted) | **A halt that cannot be put right.** If halted and stuck: if it has been asked, the game is begun again (P9). The round ends here. | 1350-1361 |
| R7 | the book (voted) | `began_halted` := halted. Then `rounds` := `rounds` + 1, written to the book. | 1424-1426 |

Between R6 and R7 the program also cuts down what is too large, puts its counts right, and
compares its hold on the observers' threads. None of that is described: A7, A8.

### 7.2 The observers look (`watch`, 731-791)

| Step | What it reads | What it does | Code |
| --- | --- | --- | --- |
| R8 | every observer's `alive` | `running[i]` := observer `i` is alive. | 734 |
| R9 | the state, the observers, the book's `rounds` | The look is put together: `rounds`, `last` = `rounds` - 1, the seven texts, the eight observers, the world. (The program reads `rounds` once at the start of `watch`, 732, for `last` and for R11, and once more in `look`. Both are voted, and are the same number while two books agree. Here it is read where it is used.) | 732, 737, `look` 721-723 |
| R10 | the look | Each running observer answers by its rule (section 5). One that is not running gives no answer. | 738-741 |
| R11 | the answers, `running` | **The signals are written.** For each observer in order: if it is running and answered, its `beat` := `rounds`; and if it found something, its `flagged` := true and its `why` := what it found. If it is running and did not answer, nothing is written, and it is noted as late (the first such). | 742-762 |
| R12 | the observers, the book's `rounds` | **A flag spreads.** Find the first observer that is `flagging` (D8). If there is none, nothing more. If there is one, its reason is taken (or "has a flag up" if it has none). Then twice over: for each ring in order, if any observer of the ring is flagging, every sound observer of the ring that has no flag gets one, with that reason. | 763-790 |
| R13 | the observers, the book's `rounds` | `stop` := some observer is flagged and sound, or some observer's `beat` is not `rounds`. | `respond` 793-795, 1430 |

### 7.3 The gate looks (`differs`, 799-822)

Steps R14 to R18 are done only if not halted. `off` starts as nothing, and each of R14 to
R17 is done only while `off` is still nothing.

| Step | What it reads | What it does | Code |
| --- | --- | --- | --- |
| R14 | the record's texts and copy | For each part in order: the record's text of it is `kept(p)`. If not, `off` := the record does not agree with itself. | 804-808 |
| R15 | the record's texts, the state | For each part in order: the record's text of it is `text(p)`. If not, `off` := the part changed. | 809-813 |
| R16 | the observers, the record's texts and copy, the book's `rounds` | **`observers_off`.** For each observer `i` in order: its name is its own; it is alive; its `beat` is `rounds`; its copies are `copies_for(i, the record's texts)`; its `held` is `held_of(i)`; it has no flag and no reason. If any of these is not so, `off` := that (where it is the copies, and the record's two halves differ in some part, what is said is that the record changed: the outcome is the same). | `observers_off` 892-925 |
| R17 | the three lists | The three lists of what was asked are the same. If not, `off` := that. | 818-820 |
| R18 | `stop`, `off` | If `stop`, or `off` is something: `stop_all`, with the reason: what the gate found if `stop` is false; otherwise what the observers found, or "an observer is silent". | 1431-1443 |

### 7.4 A halt in this round

| Step | What it reads | What it does | Code |
| --- | --- | --- | --- |
| R19 | the book (voted) | If halted: `mend` (P1). Then, if still halted, or the setting is not at once, the round ends here. | 1455-1461 |

### 7.5 The work

| Step | What it reads | What it does | Code |
| --- | --- | --- | --- |
| R20 | the moths observer's `held` | `held` := that list. | 1468, `halted_moths` 696-704 |
| R21 | the state | **The state is kept**: all three places of `before` := the state as it is. | 1470-1471 |
| R22 | the state, the first list | **Taking in**: the state := what the first text of the work makes of the state and the first list (`asks`). | 1473, `game.rs` `take_in` 444-463 |
| R23 | the state | `asked` := what the rules need to know of what was asked, read from the state as it is now. | 1475 |
| R24 | the state, `held` | **The world's work** (first text), with `held`, `dt` and `now`. | 1476, `game.rs` 839 |
| R25 | the state | **The spider's work** (first text), with `dt` and `now`. | 1477, `game.rs` 1145 |

### 7.6 The gate checks the work (`record_now`, 1000-1049)

If one of R26 to R32 refuses, the rest of R26 to R37 are skipped, and R38 deals with it.

| Step | What it reads | What it does | Code |
| --- | --- | --- | --- |
| R26 | the state | Every number in the state is a real one. If not, refuse. | 1008-1010, `unfit` 974-994 |
| R27 | the record's copy | The record's copy is a state the game can be in, by the first text of the rules and by the second. If either says no, refuse. | 1014-1019 |
| R28 | the state, the record's copy, `asked` | **The first text of the rules**: the state is one the game can be in, and is a step the rules allow from the record's copy, given `in_web` (first text) of the record's copy, `asked`, `dt` and `now`. | `ruled` 1057-1058 |
| R29 | the state, the record's copy, the second list | **The second text of the rules**: the same two questions, asked with `in_web` (second text) of the record's copy, and, in place of `asked`, with what the rules need to know of what was asked as read from what the second text's *taking in* alone (not its world's or spider's work) makes of the record's copy and the second list (`asks_again`). If R28 or R29 says no, refuse. | `ruled` 1059-1064, 1020-1025 |
| R30 | the record's copy, the second list | **The work is done a second time**: `made` := what the second text of the work (taking in, the world, the spider) makes of the record's copy and the second list, with `in_web` (second text) of the record's copy, `dt` and `now`. | `redone` 1075-1081 |
| R31 | `made`, the state | Every part of `made`, written out, is `text(p)`. If not, refuse. | `redone` 1082-1083 |
| R32 | as R16 | `observers_off` once more, exactly as R16. If it finds anything, refuse. | 1038-1040 |

### 7.7 The round is recorded (`write_record`, 1097-1120)

| Step | What it reads | What it does | Code |
| --- | --- | --- | --- |
| R33 | the state | `seen` := the seven texts of the state. `held_now` := `in_web` (first text) of the state. | 1098 |
| R34 | the observers, the book's `rounds`, `seen` | Each observer that is `sound` takes its copies: `copies_for(i, seen)`. | 1099-1103 |
| R35 | the moths observer, the book's `rounds` | If the moths observer is `sound`, its `held` := `held_now`. | 1104-1108 |
| R36 | `made` | **The record is written**: its texts and its copy both become `made`. | 1113-1114 |
| R37 | | The three lists of what was asked are emptied. | 1117-1119 |
| R38 | `began_halted`, the book (voted) | **If the round was recorded**: `spoiled` := 0, and if not `began_halted`, `stops` := 0, written to the book. **If it was refused**: `stop_all` with what was found; `spoiled` := `spoiled` + 1, written to the book; and if `spoiled` is now more than 1: `restore` (P3) is done, and then `stick`. | 1496-1528 |

## 8. A detection and a halt

| Item | What | Code |
| --- | --- | --- |
| H1 | A **detection** is any of: two books not the same (R1, R3); two places of `before` not the same (R4); an observer flagging or silent after the observers have looked (R13); the gate finding something (R14 to R17); the gate refusing the round (R26 to R32). | as above |
| H2 | One detection **halts everything**: `stop_all` (D11). At R1, R3 and R4 the program looks first whether everything is halted already, and if it is, does not call `stop_all`. For R18 it looked once, before R14, and R14 to R18 are skipped if it was. R38 does not look: a round reaches R38 only if nothing was halted at R19. | 491, 534, 1431, 1514 |
| H3 | **A round that begins halted** (and not stuck) does R1 to R13 and R19: the observers still look and signal, and R14 to R18 are skipped. If the halt is still there after R19, or the setting is not at once, the round ends at R19: no work is done (R20 to R25) and nothing is recorded (R26 to R38). If R19 ends the halt and the setting is at once, the round goes on with R20 to R38 (W1). Inside R19, `correct` has the gate look once (P2). | `turn` 1431, 1455-1461 |
| H4 | **While halted and stuck**, a round does R1 to R6 and nothing else. | 1350-1361 |
| H5 | A round is **recorded** when it reaches R36. It is **refused** when one of R26 to R32 refuses. | 1047, 1508 |

## 9. Putting right

| Item | What | Code |
| --- | --- | --- |
| P1 | **`mend`**: when a halt ends. If the halt is stuck: nothing. If the halt has been asked to end: `correct` (P2). Otherwise by the setting. *At once*: `correct`. *On a click*: nothing. *After a pause*: let `seen` be the state as it is. If the halt's `last` is not `seen`, then `last` := `seen` and `quiet` := `now`, written to the book. Then, if the pause since `quiet` (as just written, if it was) is not yet over at `now`: nothing. Otherwise `correct`. | `mend` 1273-1304 |
| P2 | **`correct`**: `restore` (P3). If it fails: `stick`, and nothing more. Otherwise all eight observers are replaced by `born` ones (D10). Then every new observer looks (section 5) at a look made as in R9 but with `last` = `rounds`. `restarts` is one more, written to the book. Then the gate looks as in R14 to R17. If any new observer found something, or the gate did: `stick`. Otherwise the halt is over: `halt` := nothing, written to the book. Nothing is written to the new observers after they have looked: their `beat` is the `rounds` they were born with. | `correct` 1126-1187 |
| P3 | **`restore`**: first `before` is read, voted (V3). Then each part `p` in order, 0 to 6, by P4. If a part cannot be settled, `restore` fails there: the parts before it have been put right, and nothing more is done. If no part fails, the three lists are put right by P5. | `restore` 1204-1270 |
| P4 | **One part.** Let `is` = `text(p)`, `text` = the record's text of `p`, `kept` = `kept(p)`, and `began` = part `p` of `before` (if `before` is something). (a) If `text` = `kept`: if `is` differs from them, the state's part := the record's copy of it. (b) Otherwise, the first of these that holds: (b1) `is` = `text` and `all_hold(p, text)`: the record's copy of the part := the state's part. (b2) `is` = `kept` and `all_hold(p, kept)`: the record's text := `kept`. (b3) `began` = `text` and `all_hold(p, text)`: the state's part and the record's copy of it := `before`'s part. (b4) `began` = `kept` and `all_hold(p, kept)`: the record's text := `kept`, and the state's part := the record's copy of it. (b5) None: this part cannot be settled. | 1211-1250 |
| P5 | **The three lists.** If all three are the same: nothing. If two are the same: all three := the voted list (V4). If no two are: all three := a list holding one letting go. | 1251-1268 |
| P6 | **A halt that stays** (`stick`, D12) comes about in these ways, and no other: no two books the same (R1, R3); `restore` fails (P2); a new observer or the gate still finds something after everything was put right (P2); the gate refuses two rounds running (R38). (Two more are not described: A7, A12.) | 506, 1130, 1179, 1524 |
| P7 | While halted, the three lists still take what E1 lets through. A halt that is not stuck ends only through P1. | |
| P8 | What is not put right by `correct`, and is put right where it is found: the three books (R1, R3) and the three places of `before` (R4). | |
| P9 | **The game is begun again**: everything stored becomes a new game at `now` (D13), but for the setting and `at`, which are kept. | `begin_again` 1634-1649 |

## 10. The three settings

| Item | Setting | When a halt ends | Code |
| --- | --- | --- | --- |
| W1 | at once | In the first round in which R19 is reached while halted: the round the detection is made in for R1 to R18, and the round after for a refused round (R38). After `correct`, if the halt is over, the same round goes on with R20. | 1283, 1458 |
| W2 | after a pause | When a round reaches R19 with the pause over (P1), or when it has been asked (E2). The round ends there, and work begins again in the next. | 1284-1299 |
| W3 | on a click | When it has been asked (E2), in the next round that reaches R19. The round ends there. | 1300 |

Asking brings `correct` about under every setting, for a halt that is not stuck; the halt is then over unless `correct` ends in `stick`. The setting can be changed at any time (E3).

## 11. The fault model

A fault is one of the following, by something other than the steps above.

| Item | What changes | To what |
| --- | --- | --- |
| F1 | one part of the state (S1) | any value |
| F2 | one observer (S2): any of its fields, a copy among them | any observer |
| F3 | the record's text of one part (S3) | any text |
| F4 | the record's copy of one part (S4) | any value |
| F5 | one of the three books (S5) | any book |
| F6 | one of the three places of `before` (S7) | nothing, or any state |
| F7 | one of the three lists of what was asked (S8) | any list |
| F8 | one observer's answer in R10 of one round | no answer, or any other answer |

F1 to F7 each change one *cell*, and may land at any *instant*: immediately before any one
of R1 to R38, or between two rounds (before, between or after the things of section 6).
F8 lands between R10 and R11. One field changed is a case of F1 to F5; F1 to F7 allow more
than one field of the one cell to change, which is more than the fault model asks.

**Why an instant inside a step is not a different case.** The steps are cut so that no
step both reads a cell and later reads or writes it again with something between that the
outcome depends on. R8 to R13, R14 to R17 and R33 to R37 are cut apart for that reason.
Where a step goes through the parts or the observers one by one (R11, R14, R15, R16, R32,
R34), a fault that lands part of the way through is the same as that fault landing before
the step if its cell had not yet been reached, and after the step if it had: for R16 and
R32, which read the record's texts once for each observer, a fault in a text part of the
way through is found by a later observer that sees the part, or by none, and that is the
outcome of the fault landing before or after. This is argued here and is not part of the
model.

Three steps are not cut, and read and write the same cells many times: R19 (`mend`,
`correct`, `restore`), the `restore` inside R38, and R6. No instant inside them is
described. R19 is done only while halted, and the `restore` in R38 only when a second
round running has been refused: a fault landing there is a second fault in one halt, which
the fault model puts outside (a fault to the state after `restore` and before the new
observers look, for one, makes the halt stay). R6 does something only in a halt that
cannot be put right. The steps R22 to R25, R28 to R30 and R38 each read or write a cell
once. R12 reads every observer once to find the first that is flagging, and writes
nothing unless there is one; if there is one, the one fault has landed already.

## 12. What this description leaves out

| Item | Abstraction | What it leaves out |
| --- | --- | --- |
| A1 | **Values.** A part, a text, a fingerprint and a list of halted moths are values of one unknown type, which can be compared for being the same and for nothing else. A part and its text are one value: `text(p)` is the part. | That writing a part out loses nothing. In the code every field of every part is written out (`game.rs` 128-150, 356-377; `snap` 223-233), finite numbers so that two different ones differ, and texts between quotes. Numbers that are not real ones are written in three ways only (not a number, and the two infinities), so two of them may be written alike; none is in a state that was recorded. The number of legs is written into both sets of legs, and a leg past the eighth is in no text: a change to how many legs there are is outside this description. |
| A2 | **The work is an unknown function**: taking in, of a state and a list; the world's work, of a state, a list of halted moths, `dt` and `now`; the spider's work, of a state, `dt` and `now`. Each has a first and a second text. | Everything about the game. And that the work could stop the program in the wrong place: here it always gives a state. |
| A3 | **The rules are unknown yes-or-no questions**, a first and a second text of each: is this a state the game can be in; is this a step the rules allow. `in_web` is an unknown function with two texts. That every number is a real one is an unknown question. Each is a question of whole states here. | What the rules are. And that the code hands the rules parts 0 to 5 only, with one number (`next_id`) from the record's part 6 (`rules.rs` 92, 185): part 6 as the work left it is held to nothing but R31. |
| A4 | **What is asked** is a value of an unknown type, a list of it another, and the rule by which a list takes something down (E1) an unknown function of the list, the thing asked, and whether everything is halted. Whether it is taken at all is an unknown question of the same and the voted list. | The pointer, presses and upgrades themselves, and the bounds on how many wait. |
| A5 | **Time.** Times and lengths are values of unknown types. `dt` is an unknown function of `at` and the clock, and `now` of `time` and `dt`. Whether the pause is over is an unknown question of `quiet` and `now`. | Arithmetic on time. So nothing here says a halt after a pause ever ends: only what happens in the round where the pause is over. |
| A6 | **One rule for the eight observers.** | That the eight copies in `looks.rs` say the same. The test `the_eight_copies_of_the_rule_are_one_rule` holds them to one another. |
| A7 | **The observers answer in the round's thread.** Every running observer answers in R10, and every new observer in P2. | The threads, the waits, an answer that comes late, and the two things kept in three for them (S9). A thread that does not answer is F8. In P2 a new observer that does not answer, or answers wrongly, is a second fault in one halt: neither is in F8, and the branch of `correct` for one that does not answer (1166-1174) is not described. The check at the program's start that the copies of the rule, of the work and of the rules are apart (`copies_apart` 1773-1783) is not described either. |
| A8 | **Sizes are those a game can have, and the counts are fixed**: seven parts, seven texts, seven copies in each observer, eight observers. | The cutting down of what is too large (`fit`, `fit_kept`, 846-879), and the putting right of the counts (`right_counts` 572-587, `counts_off` 882-890). The brief puts both outside the claim. With them goes the cut in `halted_moths` (696-704), which hands the work no more than the first 20,480 bytes of the moths observer's list. |
| A9 | **Nothing is waiting to be written during the work.** | The backdoor's "during" lines (`during` 1618-1624, 1486-1495), and with them `pending`, `passed` and what is said of them. One consequence is in the model: a refused round always counts towards `spoiled` (1515). That the backdoor writes nothing in a halt that cannot be put right (`backdoor.rs` 232, 276) is not described: here a fault can land in any halt, and the theorems never use one that does. |
| A10 | **What is said is left out**: the reason of a halt is kept only as which check made it. The book's ten fields `why`, `fixed`, `calm_since`, `games`, `inside`, `pending`, `passed`, `let_through`, `unwritten` and `not_written` are the one value `rest` (S5), which is compared with the rest of the book (V1) and which no step writes. (The halt's `aside` and `put` are not in the model at all: a place that differs only there is, for the protocol, a place that differs only in `rest`.) | The words. And this: in the code the gate's own next write to one of those fields can make a changed place agree again, and then it is never found; here a place whose `rest` was changed stays changed until R1 finds it. Both are outcomes the theorems allow. |
| A11 | **Numbers of rounds are whole numbers that never run out.** An observer's `beat` is a whole number. | A `beat` changed to something that is not a number equals nothing, the same as a whole number no round ever has. |
| A12 | **The program does not stop in the wrong place.** `stops` is in the book and is set to 0 by R38, and nothing here raises it. | `stopped` (597-615) and `fail` (944-959), which are for a mistake in the program; `clocked` (630-634), which sets `at` once when the program starts. The documents record an edge there (two stops with one recorded round between, set to end at once), which this description cannot show. |
| A13 | **`state_text` and the pause's `seen` compare states whole.** | That joining seven texts loses nothing (361-366, 1285). |

## 13. What is assumed of the unknowns

| Item | Assumption | Where it is used | What supports it in the program |
| --- | --- | --- | --- |
| Y1 | **The two texts of the work compute the same function**: for every state, list, list of halted moths, `dt` and `now`, the second text's taking in, world's work and spider's work, one after another, give what the first text's give. | R31 passing in a round with no fault | The test `the_second_text_of_the_work_is_the_first_word_for_word`; every test in which a game runs without halting, `left_alone_for_half_an_hour_it_never_halts` first among them. |
| Y2 | **The two texts of `in_web` compute the same function.** | R30 against R24; R16 and R32 | The same word-for-word test (it covers `game\again.rs` whole). |
| Y3 | **The work done with no fault passes the gate.** For every state that both texts of the rules call a state the game can be in, every list, `dt` and `now`: what the first text of the work makes of it, with `in_web` of it as the halted moths, has only real numbers (R26), is a state the game can be in by both texts (R28, R29), and is an allowed step by both texts (R28, R29), each asked as section 7.6 says. | R26 to R29 passing in a round with no fault | `left_alone_for_half_an_hour_it_never_halts`; the tests that play a game on after a halt (`after_a_pause`, `on_a_click`, `at_once` and those built on them), which is where a round is worked long after the one before it. |
| | Y1 to Y3 are stated for every state, list, `dt` and `now`. What supports them is samples: games played from a new game, most with `dt` a sixtieth of a second. `after_a_pause`, `on_a_click` and `at_once` are helpers that many tests call, not tests. With Y1 to Y3 no round with no fault is refused, so the "twice running" branch of R38 is reached only with faults. In the code it is also for a work or a rule that is written wrong (the test hooks `fault` 439-441 and `sway` 449-453): that is a fault in the program's code, which the fault model puts outside, and it is not described. | | |
| Y4 | **A new game is a state the game can be in**, by both texts of the rules. | The first round | The same tests: every one begins from a new game. |

Nothing is assumed of: the fingerprint (two texts may share one); what the rules say of
states or steps that a fault has made; what the work makes of them.
