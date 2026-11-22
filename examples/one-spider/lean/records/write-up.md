# The gate's protocol in Lean: results

Everything here is about a model of the protocol, written from `protocol-spec.md`. It is
not about the Rust source text. "Proved in Lean" means: stated in `lean\GateProof\Challenge.lean`,
proved in `lean\GateProof\Solution.lean`, and accepted by Lean's kernel on the model in
`lean\GateProof\Model.lean`.

## In short

**Proved in Lean, for the model:** T1, T2 (in the form given below, which is weaker than
the wording asked for), T3, T4, T5, and T6 as three pairs of faults on a small concrete
game. With them: that a round with no fault is recorded and leaves everything agreeing;
that every state reachable with no fault is a state the theorems start from; that a
found fault is counted as a halt; and that a halt does end when its setting says so.

**Not proved:** nothing that was attempted was left unproved. What was not attempted is
listed under "What is not established".

**Found false:** no theorem was found false of the model, and nothing that would let a
changed value be recorded as true or leave a halt that cannot be put right. One sentence
of what was asked is false as worded, in the model and in the program:

- **T2 as worded** ("everything stored ... every place of three ... is what it is in the
  run with no fault"). It is not so for the state kept from when a round's work last
  began (`before`), nor for the book's counts. After a halt, the three places of `before`
  agree with one another, and can all three hold the faulted state. It does no harm:
  `restore` uses `before` only to choose between the two halves of the record, never as a
  value by itself, and the next round's work writes over it. The counterexample, and the
  Rust test that shows the program doing the same, are under T2.

Two smaller things that the reading turned up, neither a fault of the kinds claimed:

- With one fault per halt, the "twice running" branch of R38 and the `stick` at
  `correct` are never reached. In the model that is a theorem (T3). In the program they
  are there for a mistake in the work or the rules, which the fault model puts outside.
- The program cannot say that no two books agree: `settle_books` calls `stick` straight
  after `stop_all`, and `stick` writes its own reason over that one (500-507). This is
  about what is said, not about what is stored.

## What was done, in order

1. `protocol-spec.md` was written from the code, then read against the code by a fresh
   reader given only `code\` and the specification (`reviews\spec-review-1.md`). It found
   no step whose order, condition, comparison or write differed from the code. Its ten
   points were about the edges; all were taken into the specification.
2. The model was written from the specification (`Model.lean`).
3. The statements were written (`Challenge.lean`, with `Claims.lean`), and read by a fresh
   reader given the specification, the asked-for text and the Lean statements, no proofs
   (`reviews\statement-review-1.md`). It found one statement false as then written
   (`T2_at_once`, through a count the start state did not pin), that the toy game did not
   meet the assumptions, and several places where a statement said less than its
   comment. All were corrected before the proofs.
4. The model was run against the program (below).
5. The proofs were written.
6. The final statements were read by a second fresh reader (`reviews\statement-review-2.md`),
   which worked each statement by hand looking for a counterexample and found none.

## The model in one paragraph

Everything stored is one value of type `Game`: the state (seven parts), eight observers,
the record's texts and the record's copy (seven parts each), three books, three places
of `before`, three lists. A round is 38 steps in a fixed order (`steps`), each a function
on what is stored and what the round holds of its own (`step`). A fault is one cell
changed to any value immediately before any one step (`Sched.cell`), or between the
rounds at any point among what happens there (`Fault.between`), or one observer's answer
replaced (`Sched.answer`). The game's work, its rules, what is asked and time are unknown
functions (`Params`), of which four things are assumed (`Sound`).

## The theorems

`P` is the unknowns. `g` is everything stored. `tick P es inp f g` is: what happens
between two rounds (`es`: things asked, "Put it right", a change of setting), then one
round given `inp`, with the fault `f` if there is one. Every theorem carries `Sound P`
and starts from `Clean P g`.

**The two hypotheses every theorem carries.**

- `Sound P`: the four assumptions Y1 to Y4 of section 13 of the specification. Y1 and
  Y2 (the two texts of the work, and of `in_web`, compute the same) are there because
  without them a round with no fault is refused at R31. Y3 (the work with no fault passes
  the gate) is there because without it a round with no fault is refused at R26 to R29.
  Y4 (a new game is a state the game can be in) is there for the first round. They are
  assumed for every state, list and time; what supports them in the program is samples.
- `Clean P g`: everything stored agrees (`Settled`), the count of rounds refused running
  (`spoiled`) is 0, and the count of stops (`stops`) is 0. It stands for "a state the
  program can reach with no fault": `reach_clean` proves that every such state is clean.
  It is wider than that, on purpose, so that T5 can use the theorems again after a
  fault. `stops = 0` is there because nothing in the model raises `stops` (A12) and one
  statement (`T2_at_once`) is false without it.

### Before T1: what the theorems start from

```lean
theorem reach_clean (hP : Sound P) {g : Game V Q Tm} (h : Reach P g) : Clean P g

theorem nofault_round (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) :
    let r := tick P es inp none g
    r.recorded = some (P.work g.rt (vote (events P es g).asks) r.dt r.now)
      ∧ r.found = none ∧ Clean P r.g ∧ r.recorded = some r.g.rt
```

A tick with no fault from a clean state: the round is recorded; what it records is what
the first text of the work makes of the record and the voted list; nothing halts; and
the state left is clean, with what was recorded as its record.

### T1. Nothing wrong is recorded: proved in Lean

```lean
theorem T1 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) :
    (tick P es inp (some f) g).recorded = none
      ∨ (tick P es inp (some f) g).recorded = (tick P es inp none g).recorded
```

From a clean state, for every fault and every instant of the tick: the round is not
recorded, or what it writes to the record at R36 is what the same round with no fault
writes.

What it does not say. It is about the record. In a round that is recorded, the
observers can take their copies (R34, R35) from a state that a fault changed after R31:
then the record is right, the observers and the state are wrong together, and the gate
finds it at R15 of the next round (T4, T2). And it is about the round the fault lands
in; the rounds after it are T2 and T5.

### T2. Put right: proved in Lean, in this form

```lean
theorem T2 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) (ts : List (Tick E Tm Dt)) :
    let r₀ := tick P es inp (some f) g
    let T₀ := if r₀.recorded.isSome then (tick P es inp none g).g.rt else g.rt
    let gₙ := play P ts r₀.g
    gₙ.halted = false → g.book.halts < gₙ.book.halts →
      Settled P gₙ ∧ gₙ.rt = ledger P ts T₀ r₀.g
```

One fault in one tick, then any number of ticks with no new fault. Whenever nothing is
halted and a halt has begun since the fault: everything stored agrees, and the record is
`ledger`. Which is exactly this:

| Stored | What T2 says of it after the halt |
| --- | --- |
| the state | it is the record |
| the record's two halves | the same, and what `ledger` says (below) |
| every observer | exactly as a new observer made from the record: its name, running, its signal the book's `rounds`, its copies from the record, its list from the record, no flag, no reason |
| the three books | the same as one another, and holding no halt |
| the three places of `before` | the same as one another |
| the three lists | the same as one another |

`ledger` is the answer to "say exactly which". The record after the halt is the record
of the run with no fault **at the last round the faulted run recorded**, not at the same
round:

- If the round of the fault was recorded, the record starts as what the same tick with
  no fault leaves. If not, as the record from before it. The round of the fault is lost
  when the gate refuses it, or when the fault is found before the work and halts do not
  end at once.
- Each later round that the faulted run recorded makes of it what the work with no
  fault makes (`Params.work`), from the voted list as it stood before that round and that
  round's own length and time. Each round that was not recorded (every round of the
  halt) leaves it alone. Those rounds are lost: the game's time moves on in them and the
  state does not.

The hypotheses: `gₙ.halted = false` and `g.book.halts < gₙ.book.halts` say "after the
halt that follows, when it has ended". `found_counts` (below) ties the second to the
fault being found.

**The one case in which nothing is lost** is its own theorem:

```lean
theorem T2_at_once (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) :
    let r := tick P es inp (some f) g
    let r' := tick P es inp none g
    r.found.isSome = true → r.ended = true → r.worked = true →
      r.g.sp = r'.g.sp ∧ r.g.ob = r'.g.ob ∧ r.g.rt = r'.g.rt ∧ r.g.rc = r'.g.rc
        ∧ r.g.bf = r'.g.bf ∧ r.g.asks = r'.g.asks
        ∧ ∀ k, r.g.bk k = { r'.g.bk k with halts := (r'.g.bk k).halts + 1,
                                           restarts := (r'.g.bk k).restarts + 1 }
```

If, in the tick of the fault, the fault is found, a halt is ended and the round's work is
begun (which is what happens when halts end at once and the fault is found before the
work), then at the end of that tick everything stored is what it is in the same tick
with no fault, place for place, but for the counts of halts and of restarts in each
book, which are one more. The three hypotheses are there because they are what
distinguishes this case; that "at once and found before the work" implies them is not
stated as a theorem (see "What is not established").

```lean
theorem found_counts (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) :
    let r := tick P es inp (some f) g
    r.g.book.halts = g.book.halts + (if r.found.isSome then 1 else 0)
```

**Where T2 as worded fails: the counterexample.** The fault is F1, to one part of the
state, landing after the gate has looked (R15) and before the state is kept (R21), with
halts set to end after a pause or on a click.

| Round | What happens | The state | The record | `before`, all three places | Halted |
| --- | --- | --- | --- | --- | --- |
| before | clean | `T` | `T` | what it was | no |
| n | The fault changes part 4 of the state. R21 keeps the state, fault and all, in the three places of `before`. The work is done on it. R31: the second doing, from the record, gives something else. The round is refused. | work of the faulted state | `T` | `T` with part 4 changed | yes |
| n+1, asked | R19: `restore` puts every part of the state back to the record. Eight new observers. The halt ends and the round ends. | `T` | `T` | `T` with part 4 changed | no |
| n+2 | R21 keeps the state. The round is worked and recorded. | work of `T` | work of `T` | `T` | no |

After round n+1 the halt has ended, everything else agrees, and the three places of
`before` hold a state that was never the game's. In the run with no fault they hold the
state from the start of the last round worked.

In the Rust: the test `faithful_before_keeps_the_fault` in the throwaway copy
(`rust-check\src\watch.rs`) does exactly this with `world.tally.caught += 5.0`, under
"after a pause" and "on a click", and asserts each cell of the table. It passes: the
program does what the model says.

Why it does no harm, in the model: `restore` reads `before` only in P4 (b3) and (b4),
where it must equal one half of the record and what is written is that half's value;
and R21 of the next round worked writes over it before anything can read it again. T2 to
T5 hold with it.

### T3. Never stuck: proved in Lean

```lean
theorem T3 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) (ts : List (Tick E Tm Dt)) :
    (play P ts (tick P es inp (some f) g).g).stuck = false

theorem T3_ends (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) (ts : List (Tick E Tm Dt))
    (t : Tick E Tm Dt) :
    let g' := events P t.es (play P ts (tick P es inp (some f) g).g)
    let r := round P t.inp .none g'
    ∀ h, g'.book.halt = some h →
      (g'.book.how = How.atOnce ∨ h.asked = true
        ∨ (g'.book.how = How.afterAPause
            ∧ P.pauseOver (if h.last = some g'.sp then h.quiet else r.now) r.now = true)) →
      r.g.halted = false
```

After one fault and any number of ticks with no new fault, at the end of every tick
there is no halt that cannot be put right. And the halt does end: in any later tick
that comes to its round halted, if halts are set to end at once, or the halt has been
asked to end, or the pause is over, nothing is halted after it. The three conditions of
`T3_ends` are the three settings (W1 to W3). Time is unknown in the model (A5), so
nothing says that a pause ever is over: only what happens in the round where it is.

### T4. Found, or gone: proved in Lean

```lean
theorem T4 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) (t : Tick E Tm Dt) :
    let r₀ := tick P es inp (some f) g
    let r₁ := tick P t.es t.inp none r₀.g
    let r₀' := tick P es inp none g
    let r₁' := tick P t.es t.inp none r₀'.g
    r₀.found.isSome = true ∨ r₁.found.isSome = true
      ∨ (r₁.g = r₁'.g ∧ r₀.recorded = r₀'.recorded ∧ r₁.recorded = r₁'.recorded)
```

A detection halts everything in the tick the fault lands in, or in the next. Or the
fault is gone: after the second tick everything stored is exactly what it is in the run
with no fault, and both rounds wrote to the record exactly what they write with no
fault. "Gone" is measured after the second tick and has to be: a fault to the state
between R15 and R21 whose round comes out the same leaves `before` changed until the
next R21.

### T5. One after another: proved in Lean

```lean
theorem T5 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (ts : List (FTick V Q E Tm Dt)) (hs : Spaced P ts Phase.ready g) :
    let end_ := playF P ts Phase.ready g
    end_.2.stuck = false
      ∧ (end_.1 = Phase.ready → Clean P end_.2 ∧ end_.2.rt = ledgerF P ts g.rt g)
      ∧ (end_.1 = Phase.ended → Settled P end_.2 ∧ end_.2.rt = ledgerF P ts g.rt g)
```

Any run of ticks, each with at most one fault, that keeps the spacing. At its end there
is no halt that cannot be put right. If no fault is outstanding, the state is clean, and
so every theorem above holds again from there. If a halt has ended and no round has
been recorded since, everything stored agrees. In both cases the record is what the
recorded rounds made of the record the run began with, each by the work with no fault.

The hypothesis `Spaced` is the spacing of the fault model, told from what the rounds
did (`Phase.next` in `Claims.lean`). A fault may land only in the phase `ready`. After a
fault the run is `ready` again:

- when the fault has been found, its halt has ended, and a round has been recorded
  since (the round in which the halt ended, if that round went on to be recorded: halts
  set to end at once); or
- when two rounds have ended since it landed with nothing halted. This clause is not in
  the sentence asked for, which has no word for a fault that is never found. T4 is what
  makes it sound: by then the fault is gone.

Two ways in which `Spaced` is narrower than the sentence: a tick has at most one fault,
and the earliest a next fault can land is the tick after the recorded round, not the
instants R37 and R38 of that round itself.

### T6. The edge is where it is said to be: proved in Lean, on a toy game

Three pairs of faults on the game of `Toy.lean`, which meets Y1 to Y4 (`Toy.sound`,
proved), after three rounds with no fault, set to end halts at once. Each is proved by
the kernel working the model out (`decide +kernel`).

| Theorem | The two faults | What the model does |
| --- | --- | --- |
| `Toy.T6_wrong_recorded` | both halves of the record of one part changed to the same value, before one round | the round is recorded, nothing is halted after it, and what is recorded is not what the round with no fault records: a changed value recorded as true |
| `Toy.T6_stuck` | the two halves of the record of one part changed to two different values, before one round | a halt that cannot be put right |
| `Toy.T6_spacing` | the record's copy of one part changed during the work, in two rounds running | after the first round nothing is stuck; in the second the halt is ended (at once) and the round is refused again: a halt that cannot be put right |

The third shows that the spacing cannot be weakened to "its halt has ended": a round
has to be recorded before the next fault lands in the work. That is the edge the
documents record ("two wrong rounds running"), carried in T5 by the phase `ended`.

These are about the toy game. The program's own tests for the same three things are
`a_record_changed_in_both_halves_to_agree_outranks_the_state`,
`a_record_that_nothing_can_settle_stops_the_game_until_it_is_begun_again` and
`work_that_goes_wrong_twice_running_cannot_go_on`; they were read, not run.

## The abstractions, and what they leave out

Section 12 of `protocol-spec.md` has all thirteen (A1 to A13), each with what it leaves
out, and section 13 the four assumptions (Y1 to Y4) with the tests that support each.
In one line each:

| | The model has | It leaves out |
| --- | --- | --- |
| A1 | values of one unknown type, compared for being the same; a part and its text are one value | that writing a part out loses nothing; a change to the number of legs |
| A2 | the work as unknown functions, in two texts | the game; that the work could stop the program |
| A3 | the rules as unknown yes-or-no questions, in two texts | what the rules are |
| A4 | what is asked, and how a list takes it down, as unknowns | the pointer and the shop |
| A5 | times as unknown values | arithmetic on time: nothing says a pause ever ends |
| A6 | one rule for the eight observers | that the eight copies say the same |
| A7 | observers answered in the round's thread | the threads; the two things kept in three for them (S9) |
| A8 | sizes a game can have, counts fixed | the cutting down; the putting right of counts |
| A9 | nothing waiting to be written during the work | the backdoor's "during" lines |
| A10 | reasons kept only as which check spoke; ten fields of the book as one value | the words |
| A11 | round numbers as whole numbers that never run out | a `beat` that is not a number |
| A12 | the program never stops in the wrong place | `stopped`, `fail`, and the edge the documents record there |
| A13 | states compared whole | that joining seven texts loses nothing |

Three devices of the model that are not in the program, none of which is stored or read
by any step: what the round holds for R8 to R17 is let go at R18; before R9 the round's
own values hold fixed placeholders; and four fields of `Run` say afterwards what the
round did (`recorded`, `found`, `worked`, `ended`). The statements are written with
those four.

## Faithfulness

### By reading: each definition, its item, its code

Lines are those of `code\src\watch.rs` unless another file is named.

| Lean (`Model.lean`) | Specification | Code |
| --- | --- | --- |
| `Part`, `Who`, `rings`, `coord`, `moths`, `sees`, `How` | N1 to N6, N8 | 64-76, 103-110, 124-126 |
| `Observer`, `Halt`, `Book`, `Game` | S1 to S8 | 133-141, 301-311, 324-357, 411-430 |
| `vote`, `Game.book`, `keep` | V1 to V4 | 456-476, 511-515, 555-563 |
| `Params.holds`, `Params.printOf`, `copiesFor`, `heldOf` | D3, D4, D5, D7 | 243-252, 674-676 |
| `sound`, `flagging`, `allHold`, `born` | D8, D9, D10 | 678-692 |
| `stopAll`, `stick`, `newBook`, `newGame` | D11, D12, D13 | 926-936, 963-972, 368-370, 635-661 |
| `Look`, `shaped`, `lookRing`, `lookOf` | L2 to L7 | `watch\looks.rs` 37-92; 1787-1793 |
| `selfCheck`, `stateCheck`, `obsOff`, `asksCheck`, `differs` | R14 to R17 | 799-822, 892-925 |
| `restorePart`, `restoreParts`, `restoreAsks`, `restore` | P3, P4, P5 | 1204-1270 |
| `correct`, `mend`, `beginAgain` | P2, P1, P9 | 1126-1187, 1273-1304, 1634-1649 |
| `Ev`, `event`, `events` | E1 to E3 | 1539-1616, 1655-1665 |
| `Cell`, `Cell.hit`, `Sched`, `inject`, `Fault` | F1 to F8 | (the fault model) |
| `Step`, `steps` | R1 to R38, in order | `round_at` 1315-1325, `turn` 1340-1529 |
| `settleBooks`, `settleBefore`, `Run.detect` | R1, R3, R4, H2 | 480-509, 519-542 |
| `step`: `.settle1` to `.number` | R1 to R7 | 1316-1361, 1424-1426 |
| `step`: `.running` to `.respond`, `spreadRing` | R8 to R13 | `watch` 731-791, `respond` 793-795 |
| `step`: `.selfCheck` to `.decide` | R14 to R18 | 1431-1443 |
| `step`: `.mend` | R19 | 1455-1461 |
| `step`: `.readHeld` to `.spider` | R20 to R25 | 1468-1477 |
| `step`: `.unfit` to `.obsAgain`, `Params.redo` | R26 to R32 | `record_now` 1000-1049, `ruled` 1056-1065, `redone` 1075-1084 |
| `step`: `.see` to `.emptyAsks` | R33 to R37 | `write_record` 1097-1120 |
| `step`: `.close` | R38 | 1496-1528 |
| `Inp`, `start`, `run`, `round`, `tick` | section 7, section 11 | `round_at` 1315, `round` 1333; `main.rs` 314-352 |
| `Params` | A1 to A5 | `game.rs`, `game\again.rs`, `rules.rs`, `rules\again.rs` |
| `Sound` (`Claims.lean`) | Y1 to Y4 | the tests named in section 13 |

Two fresh readers checked the two halves of this by reading: the specification against
the code (`reviews\spec-review-1.md`: no step differs), and the model against the
specification (`reviews\statement-review-1.md`, part C, and `statement-review-2.md`, part
D: no difference that changes an outcome with one fault; the small ones are listed
there).

### By running: the same situations in the Rust and in the model

A fresh agent, given the program and a task sheet (`faithfulness\rust-task.md`) and not
the model, made a throwaway copy of the program (`rust-check\`), added test-only hooks
at 17 numbered points of a round and a way to replace one observer's answer, and wrote
down what the program does in each situation (`faithfulness\rust-table.txt`; its notes
are `faithfulness\rust-hooks.md`). The model was evaluated on the same situations, with
the toy game in place of the real one (`lean\test\Faithful.lean`, through `roundE`, which
is proved equal to `round`), giving `faithfulness\lean-table.txt`.
`faithfulness\compare.py` compares them.

- **How many:** 2,604 situations: 3 settings x (48 faults x 18 instants + 4 answer
  faults).
- **Of what kinds:** the faults are 4 to parts of the state, 2 to the record's texts, 2
  to the record's copy, 3 to a book, 2 to a place of `before`, 4 to the lists, and 31 to
  observers (stopped, signal, a copy it holds, a copy it should not hold, its list, its
  flag, its reason, its name; for observers 0, 3, 5, 6). The instants are before the
  round, and immediately before R7, R8, R11, R13, R14, R15, R16, R17, R20, R22, R26,
  R30, R32, R33, R36, R37, R38. The answer faults are: no answer, and a wrong answer.
- **What is compared**, after each of five rounds (the round of the fault, one more,
  "Put it right", three more): halted; stuck; the counts of halts, of restarts and of
  rounds refused; how many rounds have been recorded and how many worked; which check
  made the halt (and for an observer's finding or the gate's, which one, of which part
  or observer); whether the state is the record; which parts of the record disagree with
  themselves; which observers are not as new ones would be; whether the three lists
  agree, the three books, the three places of `before`.
- **Whether any differed:** on the final model, none: 2,604 of 2,604 the same.

Two things about that number. First, the first comparison had 104 situations that
differed, all in which observers or which check, none in halted, recorded or put right.
All came from two choices in the toy game, not from the model: its fingerprint let two
of the test values share a mark (so coordinators missed changes the program's
coordinators see), and its work read the list of halted moths in a way the real game's
does not for a number no moth has. The toy game was changed (`Toy.lean`); `Model.lean`
was not changed for it. Second, the table cannot tell the model's R7 from its R8, nor
R26 from R30: the rows are the same in both, in the program and in the model.

The model is a different game from the program's. What is compared is what the
protocol does, not what the game does.

### A test of the statements themselves on the model

`lean\test\SelfTest.lean` evaluates the model on a toy game in which two values can share
a fingerprint and a pause can end: one fault at every one of the 38 instants, between
the rounds and in an answer (1,522 faults), under each setting (4,566 runs), then five
more ticks, and checks T1, T2, T2 at once, T3 and T4 and that the run ends clean. No run
fails. This is a test, and adds nothing to the proofs; it was written before them, to
find a false statement cheaply.

## The checks

| Check | How | Result |
| --- | --- | --- |
| It compiles | `lake build`, Lean 4.37.0-rc1, core only, no dependencies | yes; 35 build steps, about two minutes |
| No `sorry` | search of `Model.lean`, `Claims.lean`, `Toy.lean`, `Eval.lean`, `Solution.lean`, `Proofs\` | none (the 14 in `Challenge.lean` are the statements with their proofs left out) |
| Axioms | `#print axioms` on each of the 14 (`lean\Axioms.lean`) | each depends on `propext`, `Classical.choice`, `Quot.sound` and nothing else |
| The judge | `lake comparator --inadvisably-no-sandbox`, on Windows | "Your solution is okay!": the 14 statements of `Solution.lean` are those of `Challenge.lean`, with the permitted axioms only |
| Independent checkers | `lake comparator --inadvisably-no-sandbox --paranoid` (`comparator-paranoid.log`) | accepted by Lean's kernel in its default and paranoid forms and by `lean4lean`, `nanoda`, `con-leche` and `con-ron` |

**What could not be run:** the judge in its sandbox. It needs Linux and `bubblewrap`;
WSL here has Lean and not `bubblewrap`, and nothing was installed. So both judge runs
were without the sandbox, on Windows. The paranoid run was made before the last change
to the comments of `Challenge.lean`; the plain run was repeated after it.

The 14 names are in `lean\comparator.json`: `reach_clean`, `nofault_round`, `T1`, `T2`,
`T2_at_once`, `found_counts`, `T3`, `T3_ends`, `T4`, `T5`, `Toy.sound`,
`Toy.T6_wrong_recorded`, `Toy.T6_stuck`, `Toy.T6_spacing`.

## What is not established

- **Anything about the Rust source text.** The theorems are about the model. That the
  program is the model rests on two readings and on 2,604 situations at 18 instants:
  before the round, and immediately before 17 of its 38 steps. Twenty instants were not
  run in the Rust: immediately before R2 to R6, R9, R10, R12, R18, R19, R21, R23, R24,
  R25, R27, R28, R29, R31, R34 and R35.
- **An instant part of the way through a step.** The model's instants are between
  steps. Section 11 of the specification argues that an instant inside a step is the
  same as one before or after it; that argument is not in Lean. R19 (`mend`, `correct`,
  `restore`) is not cut at all: a fault landing inside it is a second fault in one halt.
- **The four assumptions.** Y1 to Y4 are assumed for every state, list and time. In the
  program they are supported by samples. In particular Y3 says a round worked long after
  the one before it still passes the rules, for any length of halt.
- **T2 in the words asked for.** False for `before` and for the book's counts (above).
  What the three books and the three lists hold after a halt that did not end at once
  is not stated beyond their agreeing with one another (and, for the books, holding no
  halt). In the model the books are those of the run with no fault but for the counts
  of halts, restarts and refused rounds, and the lists are the voted list; neither is a
  theorem here.
- **That "at once and found before the work" ends the halt in the same round.**
  `T2_at_once` assumes that the halt ended and the round worked; `T3_ends` covers a
  round that begins halted. The first half of W1 for the round of the fault itself is
  not a theorem. In the table it is so in every one of the 587 at-once situations in
  which something is found in the round of the fault, in the program and in the model:
  either the halt has ended and the round was worked and recorded, or the round was
  worked and refused.
- **Threads.** The observers on threads of their own, the waits, a late answer, and the
  two things kept in three for the threads (S9). The asked-for fault model covers
  "anything kept in three"; S9 is not in the model.
- **Sizes and counts.** Lists and texts made large, an observer or a text too many or
  too few, a ninth leg: outside, as the brief says.
- **Stops in the wrong place.** `stopped`, `fail`, and the edge the documents record
  (after a stop with halts set to end at once, one recorded round before a second stop
  is not enough). The model has `stops` in the book and nothing raises it. Whether a
  single fault of the kinds claimed can make the work stop the program is not examined:
  in the model the work always returns.
- **Liveness.** That a halt set to end after a pause ever ends, and that a round ends.
- **Two faults in general.** T6 is three pairs on a toy game. Nothing is proved about
  which pairs are survived.
- **A second fault at R37 or R38 of the round that has just been recorded** after a
  halt that ended at once. The asked-for spacing allows it; `Spaced` does not.
- **What is said.** Reasons, what a screen is sent, the backdoor.
- **The judge's sandbox.**

## The files

```
protocol-spec.md                      the specification
results.md                            this
comparator-paranoid.log               the judge's output, with every checker
reviews\spec-review-1.md              a fresh reader: the specification against the code
reviews\statement-review-1.md         a fresh reader: the first statements and the model
reviews\statement-review-2.md         a fresh reader: the final statements, looking for a counterexample
reviews\asked-for.md                  the fault model and T1 to T6, word for word from the brief
faithfulness\rust-task.md             what the Rust side was asked to do
faithfulness\rust-hooks.md            what it changed in the copy, and its notes
faithfulness\rust-table.txt           2,604 situations in the program
faithfulness\lean-table.txt           the same 2,604 in the model
faithfulness\compare.py               compares the two tables
rust-check\                           the throwaway copy of the program, with the hooks and tests
lean\lean-toolchain, lakefile.toml, lake-manifest.json, comparator.json
lean\GateProof.lean                   the root of the library
lean\GateProof\Model.lean             the model (882 lines)
lean\GateProof\Claims.lean            what the statements use: Sound, Settled, Clean, Reach, ledger, Spaced
lean\GateProof\Toy.lean               the toy game
lean\GateProof\Challenge.lean         the 14 statements, proofs left out
lean\GateProof\Solution.lean          the 14 statements, proved
lean\GateProof\Eval.lean              a quick way to evaluate the model, proved equal to it
lean\GateProof\Proofs\                ten files: the proofs (3,509 lines)
lean\Axioms.lean                      prints the axioms of each statement
lean\test\Faithful.lean               writes faithfulness\lean-table.txt
lean\test\SelfTest.lean               the test of the statements on the model
```

To read for trust: `protocol-spec.md` against the code; `Model.lean`, `Claims.lean`,
`Toy.lean` and `Challenge.lean` against the specification. They hold definitions and
statements and no proofs. The kernel checks the rest.

```
cd lean
lake build                                     compile the model and the proofs
lake env lean Axioms.lean                      print the axioms
lake comparator --inadvisably-no-sandbox       judge the proofs against the statements
lake env lean test/Faithful.lean > ../faithfulness/lean-table.txt
python -I ../faithfulness/compare.py ../faithfulness/rust-table.txt ../faithfulness/lean-table.txt
```
