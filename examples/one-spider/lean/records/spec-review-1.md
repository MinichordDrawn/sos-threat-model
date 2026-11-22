# Review 1 of `protocol-spec.md` against the program

Reader: fresh, given only `code\` and `protocol-spec.md`.
Date: 2026-11-22.

## 1. What was read, and what was not

Read in full: `protocol-spec.md`; `code\src\watch.rs` lines 1 to 2103 (everything outside
the tests); `code\src\watch\looks.rs` (copies 0 to 2 line by line, and the other five
compared with copy 0 by a text comparison: they are the same but for each copy's mark and
name); `code\src\main.rs`; `code\src\backdoor.rs`.

Read in part: `code\src\game.rs` (lines 120 to 465 and 705 to 750, and the list of its
functions); `code\src\game\again.rs` (lines 1 to 60 and the list of its functions);
`code\src\rules.rs` (lines 24 to 100 and 176 to 215, and the list of its functions);
`code\src\rules\again.rs` (the list of its functions only); the tests of `watch.rs` at
2104 to 2363, 3896 to 3935, 4225 to 4311, 5040 to 5194 and 5672 to 5741.

Not done, said plainly:

- No test was run, and the program was not run. Everything below is from reading.
- `brief.md` was not read (it is not one of the two things given). A8 says "the brief puts
  both outside the claim"; that sentence could not be checked.
- The inside of the work and of the rules was not read as a whole. They are unknowns in the
  specification, so only their signatures and what they are handed were checked.
- Y3 (the work done with no fault passes the gate) was not checked to be true. Only that
  the tests named exist and do what is said was checked.
- The helper `word_for_word` (the body of the test named in Y1 and Y2) was read from line
  4225 on, not from its start.
- The `.md` files in `code\` were not compared with the specification. One sentence was
  looked up (A12's "edge": `code\checks.md` line 534, which is there).
- Most of the tests between 2364 and 5740 were not read.

## 2. Verdict in short

The steps R1 to R38, the observers' rule L1 to L7, the definitions D1 to D13, the reading
rules V1 to V4, and the putting right P1 to P5 and P9 say what the code does. No step was
found whose order, condition, comparison or write differs from the code. Every line
reference but one is right, and that one is off by one line.

What was found is at the edges: one claim in section 11 that is not true of one step as it
is worded; one summary (H3) that contradicts the steps it summarises; one thing the model
needs that the specification lets a reader drop (the fields of the book that are "not
described" are still compared); some wording that could be modelled two ways; one
assumption (Y3) that says more than its support; and a few small things the code does that
are neither described nor listed in section 12.

## 3. The differences, most important first

### 3.1 Section 11: "no step both reads a cell and later reads or writes it again" is not true of R19

- **Item.** Section 11, the paragraph "Why an instant inside a step is not a different
  case", and the list of instants ("immediately before any one of R1 to R38, or between
  two rounds"). It bears on R19 with P1 to P5, and in the same way on R38 (its `restore`)
  and R6 (P9).
- **Code.** `mend` 1273-1304, `correct` 1126-1187, `restore` 1204-1270.
- **What the specification says.** "The steps are cut so that no step both reads a cell
  and later reads or writes it again with something between that the outcome depends on."
  Faults land only before a numbered step or between rounds.
- **What the code does.** R19 is one step, and inside it the same cells are read and
  written several times with outcomes hanging on what lies between:
  1. `mend` reads the whole state for `seen` (1285).
  2. `restore` reads `before` once (1210, kept as a local), then for each part reads the
     state, the record's text, the record's copy and the observers' copies of that part
     (1212, 1223-1237) and writes the state or the record (1215, 1224, 1226, 1233-1234,
     1243-1244); then reads and writes the three lists (1251-1267).
  3. `born` reads the record's texts and the record's world eight times (1147-1151).
  4. `look` reads the state and the observers again (1161).
  5. `differs` reads the record, the state, the observers and the lists again (1177).
  6. Only then is the halt ended or made to stay (1178-1186).

  A fault that lands between 2 and 4 has an outcome that no instant of the specification
  has. Example: a halt is being put right; `restore` has returned; then one part of the
  state is changed (F1) before line 1161. Every new observer that sees the part finds it
  changed (L3), `found` is something, and line 1179 makes the halt one that cannot be put
  right. The same fault landing immediately before R19 is put back by P4(a) and the halt
  ends. Landing immediately after R19 it is found in a later step or round as an ordinary
  detection and put right. Neither is a halt that stays. The same holds for a fault in the
  record's text of a part between 2 and 3 (the new observers are born holding the wrong
  text, and L3 or R14 then finds it), and for a fault in one of the three lists between 2
  and 5 (R17 inside `correct`).
- **How much it matters.** It depends on something the specification does not say. A fault
  inside R19 is always at least a second fault within one halt: R19 does nothing unless
  there is a halt, and a halt needs a first fault. If the model allows only one fault from
  a detection until its halt has ended, these instants are out of reach, and section 11's
  conclusion stands, but for that reason and not for the reason given. If the model allows
  a fault at any instant while a halt is being put right, the model lacks behaviour the
  code has (a halt that stays), which is **wrong behaviour by omission**. Either section
  11 should say that no fault lands inside R19, R38's `restore` or R6 and why, or P2 to P5
  should be cut into steps of their own (each part of `restore`, the lists, the eight new
  observers, the look, the gate's look, the ending).
- **For the other steps the paragraph names**, see section 5 of this report: the argument
  holds for each of them.

### 3.2 The book is compared in every field, and the specification lets most of them be dropped

- **Item.** V1, S5, A9, A10, F5; R1 and R3.
- **Code.** `Book::same` 373-407 compares all nineteen fields of a book and all seven of a
  halt, `why`, `fixed`, `calm_since`, `inside`, `pending`, `passed`, `games`,
  `let_through`, `unwritten`, `not_written`, and the halt's `aside` and `put` among them.
- **What the specification says.** V1: "Two places are the same when every field is."
  S5 lists nine fields "that the protocol reads" and says the others "are what is said to
  a screen (A10)". A9 and A10 say those are not described.
- **What the code does.** A place that differs from the other two in one of the fields
  that are not described is a detection at R1 or R3 like any other: the three are made the
  same and everything halts (480-509).
- **How much it matters.** A model whose book has only the nine fields cannot have a place
  that differs in something else, so F5 "any book" loses those cases, and with them a
  detection the code makes. The reaction is the same as for a difference in a described
  field, so nothing new is missing in kind, but the specification should say that the book
  carries one more value standing for everything not described, which takes part in the
  comparison and in nothing else. **Unstated omission**, small.
- **With it, a point of clarity on V2.** Several writes are conditional on the place
  itself and not on the voted book: `stick` (966: "if there is a halt" in that place),
  `put_right` (1661), the pause's write of `last` and `quiet` (1290). V2 says "the same
  change made to each of the three places separately", which is right, but D12, E2 and P1
  read as if the condition were the voted one. A place that has been changed to hold no
  halt takes none of these writes. **Wording.**

### 3.3 H3 contradicts R19, W1 and P2

- **Item.** H3.
- **Code.** `turn` 1455-1461; `correct` 1177.
- **What the specification says.** "While halted (and not stuck), a round does R1 to R13
  and R19, and nothing else: ... the gate does not look (R14 to R18), no work is done (R20
  to R25), nothing is recorded (R26 to R38)."
- **What the code does.** When the setting is at once and R19 ends the halt, the round
  goes on with the work and the recording (1458: it returns only if still halted, or the
  setting is not at once). R19 and W1 say this correctly. And inside R19 the gate does
  look: `correct` calls `differs` (1177), as P2 says.
- **How much it matters.** **Wording**, but in a summary a reader may build from. A model
  made from R19 is right; one made from H3 would never work a round in which a halt ends
  at once.

### 3.4 R29: "what the second text of the work makes" is the taking in only

- **Item.** R29.
- **Code.** `ruled` 1059-1061.
- **What the specification says.** The second text of the rules is asked "with what the
  second text of the work makes of the record's copy and the second list (`asks_again`) in
  place of `asked`."
- **What the code does.** Only the second text's taking in is done (`again::take_in`,
  1060), on the record's copy of part 6 and the second list, and `asked` is read from the
  result (1061) as R23 reads it from the state, by the second text's `in_hand`. The
  world's and the spider's work are not done here. In R30 the specification spells out
  "(taking in, the world, the spider)"; in R29 it does not, and "the work" can be read as
  all three.
- **How much it matters.** **Wording that can become wrong behaviour**: a model that
  applied the whole second work in R29 would hand the rules another `asked`.

### 3.5 What the rules are handed is narrower than "the state" and "the record's copy"

- **Item.** R27, R28, R29, A3, Y3.
- **Code.** `wrong_in(spider, world)` (`rules.rs` 92; called at 1014, 1057, 1062) and
  `wrong_step(was: (spider, world), held, top, is: (spider, world), asked, dt, now)`
  (`rules.rs` 185; called at 1058, 1063).
- **What the specification says.** "The record's copy is a state the game can be in";
  "the state is one the game can be in, and is a step the rules allow from the record's
  copy".
- **What the code does.** Neither question is handed part 6. "A state the game can be in"
  is asked of parts 0 to 5 only. The step is asked of parts 0 to 5 of both, with one
  number of the record's copy of part 6 (`next_id`, as `top`) and with `asked`, which was
  read from the state's part 6 at R23, before the world's and the spider's work. So part 6
  as the work leaves it is held to nothing by R27 to R29: only R31 (the second doing)
  looks at it.
- **How much it matters.** An unknown question of a whole state covers a question of six
  of its seven parts, so a model that treats the rules as unknown is not wrong. **Wording
  / precision.** It does bear on Y3: "every state that both texts of the rules call a
  state the game can be in" includes states with any part 6 at all (see 3.6).

### 3.6 Y3 says more than what is named in support of it

- **Item.** Y3, and with it Y1.
- **Code.** Tests `left_alone_for_half_an_hour_it_never_halts` (2319), helpers
  `after_a_pause` (2170), `on_a_click` (2194), `at_once` (2215); `length` 622-627;
  `rules.rs` 49 (`ROUND_MOST`); the test hooks `fault` (439-441, used at 1479) and `sway`
  (449-453, used at 1016 and 1022).
- **What the specification says.** For every state the rules call one the game can be in,
  every list, every `dt` and `now`, the work passes the gate.
- **What the code shows.** The tests named are runs from a new game: samples of states the
  work itself reaches, with `dt` always a sixtieth of a second. Three things follow.
  1. The quantifier is wider than the support. It covers states with any part 6 (3.5), and
     any `dt`, where the program never makes a `dt` outside 0 to a twentieth of a second
     (626) and the rules carry that bound as a number of their own (`rules.rs` 49). It was
     not checked whether the rules refuse a longer round.
  2. With Y1 to Y3, the fourth way of P6 (the gate refuses two rounds running, R38) cannot
     happen with one fault: after any one fault and its halt, `restore` leaves the state
     as the record has it and the lists agreeing, and Y3 then says the next worked round
     passes. That branch (1517-1525) is there for the work itself going wrong the same way
     every round, which the tests make with the hook `fault`. Y1 and Y3 assume that case
     away. Section 12 lists only the backdoor's way to it (A9) and the work stopping the
     program (A2, A12); that the work or a text of the rules may itself be wrong, which
     the code is tested against (`fault`, `sway`), is left out without being listed.
  3. `after_a_pause`, `on_a_click` and `at_once` are not tests. They are helpers, called
     by tests through `caught` (2232-2236), which is called at ten places between 2380
     and 2537. Y3 says "the tests that play a game on after a halt (...and those built on
     them)", which is nearly right.
- **How much it matters.** As an assumption on an unknown it is the model's to make, and
  it is marked as one. It should be said that it is stronger than the tests show, and that
  with it R38's "twice running" is out of reach of a single fault. **The specification
  says more than the code guarantees** (assumption), and one **unstated omission** (a wrong
  work or a wrong rule as a kind of fault).

### 3.7 Small things the code does that are neither described nor listed in section 12

Each is small. None changes a step.

1. **`clocked`** (630-634; `main.rs` 204). At the start of the program the book's `at` is
   set to the clock, between `Game::new` and the first round. D13 has `at` = `now`. Under
   A5 (time unknown) it changes nothing a model can see. **Unstated omission.**
2. **`halted_moths` reads no more than 20,480 bytes of the moths observer's list**
   (696-704). R20 says "`held` := that list". The cut is not `fit` or `fit_kept`, which
   are what A8 names. For a list a game can have it is the whole list. **Unstated
   omission**, covered in spirit by A8.
3. **`copies_apart`** (1773-1783; `main.rs` 187): the program does not start unless the
   eight copies of the rule, the two texts of the work and the two of the rules are
   different functions as built. Not protocol; not mentioned beside A6.
4. **The backdoor in a halt that cannot be put right writes nothing** (`backdoor.rs`
   232-234, 276-278), and writes nothing while a count is wrong (225-227). E4 does not say
   so. The fault model lets F1 and F2 land at any time, which is more than the backdoor
   can do, so nothing is lost. **Wording.**
5. **One line at the backdoor can change several cells at one instant** (`a; b; c`, and
   `[*]`: `backdoor.rs` 166-195, 279-295). E4 says such a line "is a fault (section 11)",
   and section 11's faults change one cell. A line that writes to two observers is two
   faults at one instant. **Wording.**
6. **A wrong answer from a new observer in P2.** F8 is "one observer's answer in R10". A7
   speaks of a new observer in P2 that gives no answer. A new observer in P2 that gives
   another answer than its rule's (the tests make one with `say_next`, 2047-2051) is not
   in F8 and not in A7; by P2 it makes the halt stay (1176-1180). It is a second fault
   like those of 3.1, and should be listed with them.

### 3.8 Locals and freshness: two places where the specification is not exact

Neither can change an outcome while two of the three books agree, since every reading of
the book is voted.

1. **`rounds` in `watch` is read once** (732) and kept: `last` in R9 is that local less
   one (737), and `beat := rounds` in R11 writes that local (750). The look's own `rounds`
   (722), `flagging` and `sound` in R12 and `respond` in R13 read the book afresh. The
   list of what a round keeps of its own (section 7, second paragraph) does not name this
   local. **Wording.**
2. **"Steps R14 to R18 are done only if not halted" is decided once**, at 1431, before
   R14. The `stop_all` of R18 (1441) is not asked again whether everything is halted.
   **Wording.**

### 3.9 Other wording

1. **N7.** "Each new observer is made from the gate's record alone": `born` (682-684) also
   reads the book's `rounds`, as D10 says.
2. **Section 10, last line.** "Asking ends a halt under every setting": asking leads to
   `correct`, which may make the halt stay (P2), and in a halt that already stays asking
   begins the game again (R6). P1 and R6 say this correctly.
3. **A1.** "Numbers that are not real ones are all written alike among themselves": they
   are written three ways, not one (`backdoor.rs` 53: `"NaN"`, `"Infinity"`,
   `"-Infinity"`; in part 6, by `{:?}`, `NaN`, `inf`, `-inf`: `game.rs` 356-375). Only two
   that are both not-a-number are written alike. Nothing in the model hangs on it.
4. **P2.** It is right, and it might say outright that in P2 nothing is written to the new
   observers after they look: no `beat`, no flag, no spreading (1162-1176), unlike R11 and
   R12. A reader may otherwise apply R11.

### 3.10 Line references

All were checked. One is off:

- **E4**: `backdoor.rs` 122-158. `run` is 122-157; 158 is the first comment line of the
  next function. **Line reference only.**

Two are a little wide and harmless: `game.rs` 128-150 (the trait runs to 160, and `sent`,
which does the writing out, to 155); `game.rs` 356-377 (`Own::written` ends at 375).

## 4. The cutting into R1 to R38 against the real order (point 5 of the task)

The order in the code, with what the specification leaves out in brackets:

- `round_at` 1315-1325: `time` read (1316), R1 (1317), R2 (1318-1323), then `turn`. In a
  test, `round` 1333-1337: R1 with `now`, `at := now`, then `turn`.
- `turn` 1340-1529: [`fit_kept` 1343], R3 (1345), R4 (1346), R5 (1347), R6 (1350-1361),
  [`fit` 1364, the counts 1366-1379, the hold on the threads 1381-1419], R7 (1424-1426),
  [`fit` 1428], `watch` R8 to R12 (1429), `respond` R13 (1430), R14 to R17 in `differs`
  (1432), R18 (1433-1442), [`pending` 1445-1454], R19 (1455-1461), [`fit` 1467], R20
  (1468), R21 (1470-1471), R22 (1473), R23 (1475), R24 (1476), R25 (1477), [the "during"
  lines 1486-1495], `record_now` (1496), R38 (1496-1528).
- `record_now` 1000-1049: [`fit`, the counts 1002-1007], R26 (1008-1010), R27
  (1014-1019), R28 and R29 in `ruled` (1020-1025), [`fit` 1032], R30 and R31 in `redone`
  (1033-1036), R32 (1038-1040), [`fit` 1046], `write_record` R33 to R37 (1047).

This is the order the specification gives. The locals are as it says: `dt`, `now` (R2);
`began_halted` (R7, read after R1 to R6, so a halt made by R1, R3 or R4 in this round
counts as "began halted"); `running`, the look, the answers (R8 to R10); `stop` (R13, used
at R18 with R14 to R17 between); `held` (R20, used at R24); `asked` (R23, used at R28);
`made` (R30, used at R31 and R36); `seen` and `held_now` (R33, used at R34 and R35). In
`restore`, `before` is read once, voted, and kept through all seven parts (1210), as P3
says. In `mend`, `stuck`, `asked` and `quiet` are read once at the top (1274-1277), and
P1's order gives the same. The two inexact places are in 3.8.

The five instants at which the tests put a fault inside a round are all instants of the
specification: `early` (1420-1423) is immediately before R7; `late` 0 (1462-1465) before
R20; `late` 3 (1026-1029) before R30; `late` 1 (1041-1044) before R33; `late` 2
(1109-1112) before R36.

## 5. Section 11, step by step (point 6 of the task)

Looked for: a step in which one stored value is read twice, or read and then written,
with something between that an outcome could depend on.

| Step | Finding |
| --- | --- |
| R1, R3 | The three books are read once for the comparison, then written whole. A fault in one book after the comparison has passed is the fault landing after the step. Holds. |
| R2 | `at` is read voted (626), then written to all three (1321), then `time` is read voted (1323). A fault in one book between does not change a voted reading. A fault to `at` alone in one place, landing after R1, is written over by 1321 (where the clock could be read) and never found: the model gives the same if it writes per place. Holds. |
| R4 | As R1. Holds. |
| R5, R7 | One voted reading at most, then a write. Holds. |
| R6 | Reads the halt once (1350). If asked, `begin_again` reads `how`, `games` and `at` (1635) and replaces everything. Holds for one fault; see 3.1 for the general statement. |
| R8, R9, R10 | Cut apart, as the specification says they must be: `alive` is read at R8 (734) and again inside the look at R9 (722), and the observers answer from the look, which is a local. Holds as cut. |
| R11 | Each observer is written once, in order, from locals. A fault in an observer not yet reached is written over as if it had landed before R11; in one already reached it stands as if after. Holds. |
| R12 | Reads `alive`, `beat`, `flagged` of the observers many times (763, 775, 779) and writes flags between. With one fault it holds: if no fault came earlier no observer is flagging when R12 begins, and a fault in observer `i` part of the way through the search at 763 is the fault before R12 if `i` was not yet reached and after R12 if it was. With an earlier fault already flagged it does not hold in general (a flag cleared, or an observer stopped, between the two passes changes who is flagged), but `stop` at R13 is true either way unless the second fault undoes the first. Section 11 does not name R12; it should say this rests on one fault. |
| R13 | One pass. Holds. |
| R14, R15 | One pass over the parts each; the record's text of a part is read in R14, in R15 and in R16, which is why they are cut apart. Holds as argued. |
| R16, R32 | As argued in section 11, and it also holds for the record's copy, which `observers_off` reads for the moths observer's list (917, through `held_of`) and for nothing else that decides. Holds. |
| R17 | One reading of the three lists. Holds. |
| R18 | Whether halted was read at 1431, before R14; the write is at 1441. Voted, so one fault in a book between changes nothing. Holds. |
| R19 | **Does not hold**: see 3.1. |
| R20, R21 | One reading each (the state is copied once at 1470 and that copy is put in all three places). Holds. |
| R22 to R25 | Each is the unknown work reading and writing the state. A fault part of the way through one of them is not argued in section 11. It leaves some state the model cannot name as "the work of a state one cell away", but what follows (R26 to R31) treats whatever is there as unknown, so the outcomes are the same kinds: refused, or by chance the same as the second doing. Not a different case in kind; not argued. |
| R26, R27, R31 | One pass each. Holds. |
| R28, R29 | Both are computed in `ruled` before either is heeded (1020-1023); the specification's "if R28 or R29 says no, refuse" is that. Within R29 the record's copy of part 6 is read twice (1059 and, for `next_id`, 1063). A fault between gives the second rules an `asked` from before and a `top` from after. The outcome is refused or not, and if not, R30 reads the changed copy: the same kinds as the fault landing before R30. Not argued; no different outcome found. |
| R30 | The record's world is read twice: copied at 1076 and read again for `in_web` at 1079. A fault between gives a second doing from the old world with the new list of halted moths. The outcome is the same kinds as the fault before R30 (refused at R31) or after it (refused at R32 through the moths observer's list, or nothing if `in_web` is unchanged). Not argued; no different outcome found. |
| R33 to R37 | Cut apart, as said. R34 is one pass over the observers. Holds. |
| R38 | The recorded branch is one write. The refused branch is `stop_all`, a write, a voted reading, and then `restore` if `spoiled` is more than 1. For a fault inside that `restore` the remark of 3.1 applies; it needs two refusals running, which one fault cannot bring about under Y3 (3.6). |
| E1 | The voted list is read for the count (1565-1567), then each list is written by itself (1545-1562). A fault in a list not yet written is the fault before E1; in one already written, after. Holds. |

So: the argument is right for every step it names (R8 to R13 as cut, R14 to R17, R33 to
R37, and the one-by-one steps R11, R14, R15, R16, R32, R34). Its opening sentence, which
speaks of every step, is not right for R19, and is not argued for R12, R22 to R25, R28 to
R30 and R38.

## 6. Section 12 and section 13 (point 7 of the task)

| Item | Finding |
| --- | --- |
| A1 | Leaves out what it says. Checked: every field of every piece is written (`game.rs` 133-155, the `part!` pieces 188-244; `snap` 223-233; `Own::written` 356-375), texts between quotes (`backdoor.rs` 67-89). `unfit` (974-994) refuses any number that is not a real one before a round is recorded, and covers part 6 (`game.rs` 343-354). The count of legs is in both sets' texts (231), and `copy_part` copies all the legs when the counts differ (211-213), which is the thing A1 puts outside. One wording point: 3.9, 3. |
| A2 | Leaves out what it says. The three functions are handed less than a whole state each (`take_in` writes part 6 only; the world's work writes the world and part 6; the spider's work the spider and part 6: `game.rs` 444, 839, 1145), which an unknown function of the whole state covers. That the work itself may be wrong is left out without being listed: 3.6, 2. |
| A3 | Leaves out what it says. See 3.5 for what the questions are handed. |
| A4 | Leaves out what it says. `ask` 1539-1563: each list by itself, from the list and `halted` only. Whether a thing is taken: `press` 1579, `buy` 1610-1615, `point` 1570. |
| A5 | Leaves out what it says, and `clocked` besides (3.7, 1). |
| A6 | The test exists (5090) and does what is said: each of the eight copies is called as each observer on a look at many faulted games, at `last` = `rounds` and `rounds` - 1, and all eight must answer the same (5156-5166); then on looks with a text or an observer missing (5168-5181). By a text comparison made for this review the eight copies are the same text but for mark and name. |
| A7 | Leaves out what it says, and with it the detections and the two halts that stay which the threads' three places bring (1381-1418), as P6 and the paragraph after R7 note. A wrong answer in P2 is not covered: 3.7, 6. After an answer does not come, the code does not ask that observer again until all eight are replaced (2011-2018), so in the code it is silent for the rest of the halt, and in the model (F8, one round) it answers again in the next round. Only `beat` and the flags differ, all eight are replaced when the halt ends, and neither `mend` nor `restore` reads them: no different outcome found. |
| A8 | Leaves out what it says. The counts are also looked at in `differs` (801), `observers_off` (896), `record_now` (1005) and `restore` (1207), and `fit` is called at 1002, 1032, 1046, 1364, 1428, 1467 and from the backdoor (866-870, `backdoor.rs` 125). The cut in `halted_moths` is not among what A8 names (3.7, 2). The sentence about the brief could not be checked. |
| A9 | Leaves out what it says: 1445-1454, 1486-1495, 1505, 1515, 1618-1624, and `aside` and `inside` in `stop_all` (928, 933). The one consequence it names (1515) is right. |
| A10 | Leaves out what it says. But the fields left out are still compared: 3.2. |
| A11 | Right: `beat` and `rounds` are `f64` (136, 353), compared by `==` in the observers and the gate, and by bits between books (405). |
| A12 | Leaves out what it says: `stopped` 597-615, `fail` 944-959. The edge it mentions is in `code\checks.md` at line 534. |
| A13 | Right: `state_text` joins seven texts with a character no text has (364) and gives the empty text for nothing (363); `seen` joins seven texts with nothing between (1285). A new halt's `last` is the empty text (934), which no `seen` is, so the first `mend` of a halt after a pause always writes `quiet := now`: the specification gives the same if "nothing" differs from every state, as S6 and D11 have it. |
| Y1 | The test exists (4273). It holds every function and number of `game\again.rs` to `game.rs` word for word, marks apart (4237-4270, read from 4225 on). `left_alone_for_half_an_hour_it_never_halts` exists (2319) and ends with no halt in 108,000 rounds (2360). Support as said. |
| Y2 | The same test. `in_web` is a function of `game\again.rs` (390). Support as said. |
| Y3 | The tests and helpers exist and do what is said: a game is played on for 300 rounds after the halt ends (2189, 2210, 2226-2227) and must not halt again. The assumption is wider than the support: 3.6. |
| Y4 | Every test read begins from `Game::new` (2125, 2258, 2320) or from a game grown from one. Support as said. |

## 7. Items checked and found to agree with the code

"Agrees" means: the order, the condition, what is read, what is compared and what is
written are what the code does at the lines given, and the lines are right.

- **Section 1.** N1 (65, 67), N2 (64), N3 (72), N4 (74), N5 (76), N6 (124-126), N7 (78,
  1147-1151; wording 3.9, 1), N8 (103-110, 369).
- **Section 2.** S1 (413-420), S2 (133-141, 415), S3 (260), S4 (261-263), S5 (324-357,
  419; see 3.2), S6 (301-311), S7 (430), S8 (424-426), S9 (434, 1853).
- **Section 3.** V1 (456-468, 373-407), V2 (472-476), V3 (511-515), V4 (555-563).
- **Section 4.** D1 (663-669), D2 (235-241), D3 (243-245), D4 (246-248), D5 (250-252), D6
  (`game.rs` 736-739, `game\again.rs` 390), D7 (674-676), D8 (685-692), D9 (678-680), D10
  (682-684), D11 (926-936), D12 (963-972), D13 (635-661, 368-370).
- **Section 5.** The preamble (1787-1793, 721-723, 1807-1810) and L1 to L7 (`looks.rs`
  37-92), with the order: L3 then L4 for each part; then L5 and L6 for each other
  observer; then L7; then the next ring for observer 3.
- **Section 6.** The lock (`main.rs` 60, 99-109; a round holds it at 320-343). E1
  (1539-1563, 1565, 1569, 1578, 1584, 1609), E2 (1659-1665), E3 (1655-1657), E4 (line
  reference 3.10; wording 3.7, 4 and 5).
- **Section 7.** R1 to R38, each at the lines given. In particular: R1's time is the
  book's `time` read before the comparison (1316); R6 returns before any observer looks;
  R11 clears no flag; R12 goes over the rings twice; R13 counts an observer whose `beat`
  is not `rounds` whether or not it is alive; R18's condition and its three reasons; R19's
  condition for the round to end (1458); R21 writes one copy of the state to all three
  places; R27 comes before R28 and R29 and refuses by itself; R32 is held to the record as
  it was before this round; R34 and R35 write only to sound observers; R36 writes the
  record from the second doing and not from the state; R37 comes only after R36; R38's
  `stop_all` is not guarded, its count, and `restore` followed by `stick` whether or not
  `restore` fails. Wording: 3.4 (R29), 3.8 (R9, R11, R18).
- **Section 8.** H1, H2 (491, 534, 1431, 1514), H4 (1350-1361), H5 (1047, 1508). H3: 3.3.
- **Section 9.** P1 (1273-1304), P2 (1126-1187), P3 (1204-1270), P4 (1211-1250, all five
  branches of (b) in order, and (a) without regard to the observers), P5 (1251-1268), P6
  (506, 1130, 1179, 1524; the only other places a halt is made to stay are 956, 1397 and
  1415, which are A12 and A7), P7, P8, P9 (1634-1649).
- **Section 10.** W1 (1283, 1458), W2 (1284-1299), W3 (1300). The last line: 3.9, 2.
- **Section 11.** F1 to F8 as kinds of fault. The paragraph on instants: 3.1 and section 5
  of this report.
- **Section 12 and 13.** Section 6 of this report.
