# Statement review 1: the Lean statements read against the specification and what was asked

Read for this review, and nothing else: `protocol-spec.md`, `reviews\asked-for.md`,
`lean\GateProof\Model.lean`, `Claims.lean`, `Toy.lean`, `Challenge.lean`.

Nothing was run. Everything below is from reading. Where I evaluated the toy game, I did it
by hand, and say so. What I would have run if I could is listed at the end of section 0.

The findings are in three kinds, kept apart throughout and listed together in section 5:

- **(1)** a statement says something other than what was asked (or cannot be true as written);
- **(2)** the model differs from the specification;
- **(3)** wording.

## 0. The findings in short, most important first

1. **(1) `T2_at_once` is false as written.** `Clean` says nothing of the book's `stops`. If
   `stops` is not 0 in a clean state, halts end at once, and the fault is found at R1, R3 or
   R4 (before R7 reads `began_halted`), R38 leaves `stops` as it was in the faulted run and
   sets it to 0 in the run with no fault. The conclusion's last conjunct then fails. Section
   1.5 gives the counterexample. It needs a hypothesis that `stops` is 0 (or `stops = 0` in
   `Clean`, or `Reach` in place of `Clean`).
2. **(1) The toy game of T6 does not meet `Sound`.** `Toy.P.real` is "every part is less
   than 1000000", so Y3 (`work_passes`, stated for every state the rules allow) fails for a
   state with a part just under that. T1 to T5 are therefore not statements about the toy
   game, and T6 does not show that their scope is tight under their own assumptions. The
   sentence "Each fault of each pair is one that T1 to T4 cover alone" has nothing behind it
   until the toy is `Sound`. Section 1.10.
3. **(1) `T2` claims less than "everything stored is what it is in the run with no fault".**
   It pins the state, both halves of the record and every observer. Of the three books, the
   three places of `before` and the three lists it says only that the three places agree
   with one another (and that no book holds a halt). And the stronger claim would be false:
   after the halt has ended, all three places of `before` can hold a state with the fault's
   value in it (section 1.4). The statement also never compares with a run with no fault;
   "say exactly which" is answered only through `ledger`.
4. **(1) `T1` is about one value, the one written at R36.** `recorded` is a reporting field
   set to `some r.made` at R36. T1 does not speak of the observers' copies and list taken in
   R34 and R35 of the same round (which a fault to the state before R32 or R33 makes wrong
   while `recorded` is right), nor of the record as it stands at the end of the tick.
5. **(1) What is kept in three for the threads (S9) is outside every statement.** The fault
   model asked for covers "one of the three places of anything kept in three"; F1 to F7 and
   `Cell` have no case for `Game.apart` or `Threads.run` (A7 leaves them out).
6. **(1) Nothing states that a halt found before R19 ends in the same round when halts end
   at once** (the first half of W1). `T2_at_once` assumes it (`r.ended = true`,
   `r.worked = true`); `T3_ends` covers only a round that *begins* halted. Nor is `found`
   linked to the count of halts that `T2` uses, so T4 and T2 do not join without a lemma
   that is not among the statements.
7. **(1) `Spaced` is not word for word the spacing sentence.** It lets the next fault land
   after a fault that was never found (two ticks with no halt), which the sentence has no
   clause for; and its earliest next fault is the tick after the recorded round, not the
   rest of that round after R36.
8. **(1) T4's "found" is the reporting field `found`**: a detection that halted everything
   in that round. That is H1 with H2, and it is the same as "a detection" only for a round
   that began not halted (which is so in T4).
9. **(2) The model follows the specification closely.** I found no difference that changes
   an outcome with one fault. Eighteen small differences and unsettled readings are in
   section 3.3; the ones worth settling against the code are the per-place `+ 1` writes
   (R7, D11, P2, R38), the unconditional `stop_all` in R38 against H2, and where R1's time
   and R14's "halted" are read.
10. **(2) The two modelling devices cannot change what is stored.** No step reads, after
    R18, any of the values R18 resets; no step reads `recorded`, `found`, `worked` or
    `ended` at all. Section 3.4.
11. **(3)** Names used for two or three things (`asked`, `before`, `none`, `held`), and
    several doc-comments that say a little more than the statement. Section 4.

What I would have run, and could not:

- that the four files compile as given (in particular the instance behind
  `decide (∀ p : Part, ...)` in `shaped`, and the implicit arguments in the `Toy` theorems);
- `example : ¬ Sound Toy.P`, with the state of section 1.10;
- the three T6 statements by `decide` or `#eval`, against my hand evaluation;
- the counterexample to `T2_at_once` by evaluation on a `Sound` copy of the toy.

## 1. Part A: each statement in plain words

Every statement in the first group carries the instance hypotheses
`[DecidableEq V] [DecidableEq Q] [DecidableEq Tm]` and is for every `P : Params V Q E Tm Dt`.
I do not repeat these.

`Clean P g` unfolds to: `g.sp = g.rt`; `g.rc = g.rt`; every observer `i` is exactly
`born P g i` (its own number as name, alive, `beat` the voted book's `rounds`, copies
`copiesFor P i g.rt`, `held` = `inWeb₁ g.rc` for observer 5 and `blank` for the rest, no
flag, no reason); books 0, 1 and 2 are equal and book 0 has no halt; the three places of
`before` are equal; the three lists are equal; both texts of the rules call `g.rt` a state
the game can be in; and book 0's `spoiled` is 0.

What `Clean` leaves free: the round number, the setting, `halts`, `restarts`, **`stops`**,
`clock`, `time`, `rest`, what the three places of `before` hold (nothing, or any state), and
what the three lists hold. So "clean states, which are these and more" is right, and "more"
is a good deal more than what can be reached. That makes the theorems stronger where they
are true. In one place it makes a statement false (1.5).

### 1.1 `reach_clean`

**Hypotheses:** `Sound P`; `Reach P g`.

**Says:** any game got from a new game (`newGame P now`, any `now`) by any number of things
between rounds (E1 to E3, `event`) and rounds with no fault (`round P inp .none`, any `inp`)
is `Clean`.

**Against what was asked:** not one of T1 to T6. It is the bridge from "every state the
program can reach with no fault" (T1's words) to `Clean`. With it, T1 to T5 for `Clean`
give T1 to T5 for reachable states. `Reach` matches the words: D13, E1 to E3, a round with
no fault. E4 is a fault and is rightly not in `Reach`.

**Empty reasons:** none. `Reach` is inhabited (`Reach.new`), `Sound` can hold.

**Wording (3):** the doc-comment says "no round has been refused". `Clean` says book 0's
`spoiled` is 0, which is "the gate has not refused the last round it worked". True of
reachable states, but more than the definition says.

### 1.2 `nofault_round`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, any `inp`.

**Says:** let `r` be: the things `es` done to `g`, then one round with no fault. Then
(a) `r.recorded` is `some` of `P.work g.rt q r.dt r.now`, where `q` is the voted list after
`es` and `P.work` is the first text's taking in, world and spider with `inWeb₁ g.rt` as the
halted moths; (b) `r.found = none`; (c) `r.g` is `Clean`; (d) `r.recorded = some r.g.rt`.

**Against what was asked:** a supporting statement. It is what makes T1's "what the same
round with no fault records" a definite value. It agrees with Y1 to Y3 and section 7.

**Empty reasons:** none.

### 1.3 `T1`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`; any `f : Fault V Q Tm`.

**Says:** do `es` and one round from `g` with the one fault `f`. Then the reporting field
`recorded` of that round is `none`, or it equals the `recorded` of the same `es` and round
from `g` with no fault.

**Is it what was asked?** In shape, yes: "the round is either not recorded, or what is
recorded is what the same round with no fault records".

**Stronger than asked:**

- every `Clean` state, not only the reachable ones;
- a fault is a whole cell changed (a whole part, a whole observer, a whole book, a whole
  place of `before`, a whole list), not one field or one entry.

**Kinds of fault covered:** F1 to F7 as `Cell.sp`, `.ob`, `.rt`, `.rc`, `.bk`, `.bf`,
`.asks`, each "to any value" as section 11 says; F8 as `Fault.answer i a` with
`a : Option (Option Finding)` (no answer; found nothing; found anything). All eight are
there. Not there: S9 (finding 5).

**Instants covered:**

- between rounds: `Fault.between n c` lands after the first `n` things of `es` and before
  the rest, so before, between and after the things of section 6 (`n` at or past the length
  of `es` is "after them all");
- in the round: `Fault.before s c` for each of the 38 constructors of `Step`. `steps` lists
  all 38 once, in the order R1 to R38, and `run` calls `inject` before each. `inject` lands
  a cell fault even when the round has ended early (`if s' = s then { r with g := c.hit r.g }`
  has no test of `r.over`), so a fault "before" a skipped step is not lost;
- F8: `inject` replaces the answer when `s = Step.signals`, which is between R10 and R11.

**Instants not covered, and whether that is a gap:**

- after R38 of this round: that is `Fault.between 0` of the next tick. Not a gap.
- inside R19, the `restore` in R38, and R6: section 11 says no instant inside them is
  described. With one fault from a clean state none of the three does anything before the
  fault has landed, so this is not a gap for T1.
- part of the way through a step that goes through parts or observers (R11, R14, R15, R16,
  R32, R34): section 11 argues each is the same as before or after, and says "This is
  argued here and is not part of the model". So T1's "every instant" rests on that
  argument. (Section 11 also says R12 "each read or write a cell once", but R12 as written
  reads the observers' flags several times: "twice over", and `.spread` evaluates
  `flagging g` for the first flagging observer and again for each ring in each of two
  passes. An instant inside R12 is not argued.)

**What the conclusion leaves out (finding 4):**

- `recorded` is set in one place, `step .writeRecord`:
  `{ r with g := { g with rt := r.made, rc := r.made }, recorded := some r.made }`. It is
  the value written to the record at R36. It is not the record at the end of the tick: a
  fault before R37 or R38 to `rt` or `rc` leaves `recorded` right and the stored record
  wrong. (That is the fault itself, found at R14 of the next round; T1 is still true.)
- Section 7.7 is headed "The round is recorded" and covers R33 to R37: the observers take
  their copies (R34) and the moths observer its list (R35) from `seen` and `held_now`, read
  from the state at R33. A fault to one part of the state landing before R32 or R33 (after
  R31 compared) makes `seen` wrong. The observers then take wrong copies, the record takes
  the right `made`, and T1's second disjunct holds. If "what is recorded" is read as all of
  7.7, T1 does not say it. Under H5 ("recorded when it reaches R36") it does. The statement
  should say which it means; I think the doc-comment should say "what is written to the
  record at R36".

**Empty reasons:** none. `recorded = none` is trivially true of any round that does not
record, as the asked wording allows.

### 1.4 `T2`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`, `f`; any list `ts` of later ticks
with no fault; and two in the statement itself: `gₙ.halted = false`, and
`g.book.halts < gₙ.book.halts` (the voted count of halts is greater after than it was in
`g`, before the tick of the fault).

**Says:** let `r₀` be the tick with the fault and `gₙ` the game after `ts` more ticks with
no fault. Let `T₀` be the record the same first tick leaves with no fault if `r₀` recorded,
and `g`'s record if not. If `gₙ` is not halted and the count of halts has gone up, then:

- `Settled P gₙ`: the state is the record's texts; the record's copy is the record's texts;
  every observer is `born` from that record at the book's round; the three books are equal
  and hold no halt; the three places of `before` are equal; the three lists are equal; the
  record is a state the game can be in;
- `gₙ.rt = ledger P ts T₀ r₀.g`: starting from `T₀`, for each tick of `ts` in which the
  faulted run recorded, apply the work with no fault (`P.work`) to the list the faulted run
  held (voted, after that tick's things) with that round's own `dt` and `now`; for a tick
  in which it did not record, leave it.

**Is it what was asked?** Partly. What was asked: "everything stored (the state, the
record, every observer's copy, every place of three) is what it is in the run with no fault
at the same round, or at the round the faulted run has reached if a round was not worked.
Say exactly which."

**What it does cover:** the state, both halves of the record, and every observer whole (not
only its copies: its name, `alive`, `beat`, `held`, flag and reason too), all pinned to one
value, `ledger`.

**Where it is weaker than asked:**

- **The three books.** `Settled.books` and `Settled.noHalt` say the three are equal and
  hold no halt. Nothing is said of what they hold: `rounds`, `time`, `clock`, the setting,
  `halts`, `restarts`, `spoiled`, `stops`, `rest`. (Some cannot be "what it is in the run
  with no fault": `halts` and `restarts` are more, and `spoiled` is 1 after a refused round
  until the next recorded one, which is why the conclusion is `Settled` and not `Clean`.
  The rest could be claimed and are not.)
- **The three places of `before`.** `Settled.before` says they are equal. Not what they
  hold. And the asked claim is false of them. Take halts set to end after a pause, and the
  fault `Fault.before .obsCheck (Cell.sp p v)`: one part of the state changed after R15 has
  looked at the state. R16 and R17 do not read the state. R21
  (`{ g with bf := fun _ => some g.sp }`) keeps the faulted state in all three places. The
  work goes on from it; say R31 refuses (`r.made ≠ g.sp`), and R38 halts. When the pause is
  over, `correct` puts the state back from the record by P4 (a), and `restore` never writes
  `before`. The round ends at R19. Now the halt has ended, `Settled` holds, and all three
  places of `before` hold a state with `v` in part `p`, which no run without the fault
  kept. It is written over at the next R21. (This is harmless under the spacing, since the
  next fault may land only after a recorded round. But it is not "what it is in the run
  with no fault", and the doc-comment does not say so.)
- **The three lists.** `Settled.asked` says they are equal. Not what they hold. (They
  cannot equal the no-fault run's lists: E1 takes less while halted. What could be said is
  that they are the voted list.)
- **No run with no fault appears in the conclusion** except through `T₀`. "What it is in
  the run with no fault at the same round" is replaced by `ledger`, which is fed the
  faulted run's own lists, lengths and times. That is a different sentence. It is the right
  one (a run with no fault given the same ticks would take in things the halted run
  refused), but it is not the one asked for.
- **"Say exactly which"** is not answered in words anywhere. The answer the statement
  gives is: the record is what the work with no fault makes over *the rounds the faulted
  run recorded*, so it is "the round the faulted run has reached", counting recorded
  rounds. It is the no-fault run's record at the same round only when the faulted run
  recorded every round, which is `T2_at_once`'s case. The book's `rounds` goes on counting
  through a halt, so "the same round" by number is never what is meant.
- **S9** is not there (finding 5).
- It speaks of the ends of ticks only, not of the instant inside R19 at which the halt
  ends. That is the natural reading of "when it has ended".

**Where it is stronger than asked:** it holds at every later end of tick at which nothing
is halted, not only when the halt has just ended; for every `Clean` start; for whole-cell
faults; and for every observer whole.

**Empty reasons:** the two hypotheses can both hold (any fault that is found). For a fault
that is never found the second is false and T2 says nothing; T4's third disjunct is meant
to cover that. But no statement says that a tick with `found.isSome` has the voted `halts`
one more, so the two do not join as written (finding 6). `g.book.halts < gₙ.book.halts`
compares with `g` before the tick's things and its fault; that is sound, since nothing
halts in that tick before the fault.

**Wording (3):** the doc-comment's "the record as it stood after the tick of the fault" is
not `T₀`. `T₀` is the record as it *should* stand after that tick (the faulted tick's own
record may hold the fault). The next sentence puts it right.

### 1.5 `T2_at_once`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`, `f`; and three on reporting fields
of the faulted tick `r`: `r.found.isSome = true`, `r.ended = true`, `r.worked = true`.

**Says:** if in the tick of the fault a detection halted everything, a halt was ended at
R19, and the work was begun at R21, then at the end of that tick the state, the eight
observers, the record's texts, the record's copy, the three places of `before` and the
three lists are equal to those of the same tick with no fault, and each of the three books
is the no-fault tick's book with `halts` and `restarts` one more.

**Is it what was asked?** For the at-once case it is the first form of T2 ("what it is in
the run with no fault at the same round"), and it is the only statement that compares
everything stored with the run with no fault. Good. But:

**It is false as written (finding 1).** R38, recorded: "`spoiled` := 0, and if not
`began_halted`, `stops` := 0". The Lean:

```
{ r with g := keep (fun b => { b with spoiled := 0,
                               stops := if r.beganHalted = true then b.stops else 0 }) g }
```

`beganHalted` is read at R7. A detection at R1, R3 or R4 comes before R7, so in the faulted
run `beganHalted = true` and `stops` is left as it was; in the run with no fault
`beganHalted = false` and `stops` becomes 0. `Clean` does not say `stops` is 0.

Counterexample, for any `Sound P` and any `now`: let
`g := keep (fun b => { b with stops := 1, how := How.atOnce }) (newGame P now)`. It is
`Clean` (`born` reads only the book's `rounds`, `rt` and `rc`; Y4 gives `canBe`). Take
`es := []` and `f := Fault.between 0 (Cell.bf 0 (some (P.newState now)))`, so place 0 of
`before` is something and the other two are nothing. R4 finds it (`Run.detect .before`),
R7 sets `beganHalted := true`, R14 to R18 are skipped, R19 `mend` goes to `correct`, which
finds nothing to put right and ends the halt, the round goes on (at once), and the work is
recorded as with no fault. So `found`, `ended` and `worked` all hold. At R38 the faulted
run's books have `stops = 1`; the no-fault run's have `stops = 0`. The last conjunct,
`r.g.bk k = { r'.g.bk k with halts := ..., restarts := ... }`, is false.

For reachable states `stops` is always 0 (A12: "nothing here raises it"), so the statement
is true of them; but it is stated for `Clean`, and its proof needs `stops = 0` from
somewhere. Any of these mends it: add `(g.bk 0).stops = 0` as a hypothesis; add it to
`Clean` (it is kept by every step and put right by R1 after a fault to one book); or state
this one for `Reach`.

**Where it is weaker than asked:** the three hypotheses are on reporting fields, not on the
setting. Nothing says they hold when halts end at once and the fault is found before the
work, which is what the doc-comment's "(which is so when ...)" asserts in words only
(finding 6). From a clean state they can hold only at once (`worked` needs the round not to
end at R19, which needs `how = atOnce`), so under the other two settings the statement is
true for an empty reason, by design.

**Empty reasons:** none beyond that.

### 1.6 `T3`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`, `f`, `ts`.

**Says:** after the tick with the fault and any number of later ticks with no fault, the
voted book does not hold a halt marked `stuck`.

**Is it what was asked?** Yes: "No single fault leads to a halt that cannot be put right."
It is stated at the ends of ticks. That is enough: a halt made stuck inside a round is
still stuck at the round's end (`stick` clears `asked`, so R6 of the same round cannot
begin the game again), and `ts` ranges over every length.

**Stronger:** every `Clean` start, whole-cell faults, every setting and every mix of things
between rounds (changing the setting and asking included).

**Weaker:** S9; and, as everywhere, no instant inside R19.

**Empty reasons:** none.

### 1.7 `T3_ends`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`, `f`, `ts`, and one more tick `t`;
in the statement: the voted book of `g'` (the game after `ts` and after `t`'s things) holds
a halt `h`; and one of: the voted setting is at once; `h.asked`; or the setting is after a
pause and `P.pauseOver (if h.last = some g'.sp then h.quiet else r.now) r.now`.

**Says:** then the round of tick `t`, with no fault, ends with nothing halted.

**Is it what was asked?** It is more than T3 asks: it says the halt does end, under each of
W1 to W3's conditions. The pause condition is exactly `mend`'s (P1): `quiet` as kept if the
state is as the halt last saw it, `now` if not. It does not say a pause ever is over, as A5
warns.

**What it leaves out (finding 6):** it is about a round that *begins* halted. The round in
which the fault is found at R1 to R18 begins not halted, so nothing here says that halt
ends in the same round when the setting is at once (W1: "the round the detection is made in
for R1 to R18"). `T2_at_once` assumes it.

**Empty reasons:** none. It needs no "not stuck" hypothesis only because T3 gives it; if T3
failed this would fail with it.

### 1.8 `T4`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`, `f`; one more tick `t`.

**Says:** let `r₀` be the tick with the fault and `r₁` the next tick with no fault; `r₀'`
and `r₁'` the same two ticks with no fault at all. Then one of: `r₀.found` is something;
`r₁.found` is something; or `r₁.g = r₁'.g` (everything stored, all seven fields of `Game`)
and `r₀.recorded = r₀'.recorded` and `r₁.recorded = r₁'.recorded`.

**Is it what was asked?** Yes, and the third case is stronger than asked: not only "written
over with nothing wrong recorded" but everything stored equal to the run with no fault
after the second tick, and both rounds' records equal. (Equality is claimed after the
second tick, not the first, and that is needed: a fault to the state after R15 that the
work washes out leaves all three places of `before` different until the next R21.)

**Does "found" mean a detection (finding 8)?** `found` is set in two places:
`Run.detect` (`if r.g.halted = true then r else { r with g := stopAll why now r.g, found := some why }`),
called from R1, R3, R4 and R18; and R38 when the round is refused. So `found.isSome` is "a
detection halted everything in this round": H1 together with H2. A detection made while
already halted (books settled at R1 in a halt, or observers flagging at R13 when R14 to R18
are skipped) is not `found`. In T4 both rounds begin not halted unless the first was
`found`, so here `found` is exactly H1's list: R1, R3; R4; R13 and R14 to R17 through R18;
R26 to R32 through R38. And `nofault_round` says `found = none` with no fault, so the first
two disjuncts are not true for an empty reason.

**Weaker:** it does not say *which* detection, nor that what was found is the fault (with
one fault from a clean state it can be nothing else). S9.

**Empty reasons:** none.

### 1.9 `T5`

**Hypotheses:** `Sound P`; `Clean P g`; any list `ts` of ticks each with at most one fault;
`Spaced P ts Phase.ready g`.

**Says:** let `end_` be the phase and game after `ts`. Then (a) the game is not stuck;
(b) if the phase is `ready`, the game is `Clean` and its record is `ledgerF P ts g.rt g`;
(c) if the phase is `ended`, the game is `Settled` and its record is the same `ledgerF`.
In phases `landed` and `halting` it says only (a).

Since a prefix of a spaced run is spaced, this holds at every end of tick along the run.

**Is it what was asked?** In shape, yes: "Any sequence of faults that meets the model's
spacing leaves, after each halt, what T2 says". It carries T2's weaknesses with it (the
books, `before`, the lists: agreement only; no S9), and adds `Clean` whenever a fault may
land again.

**Does `Spaced` say what the spacing sentence says (finding 7)?** The sentence: "The next
fault lands only after the first has been found, its halt has ended, and a round has been
worked and recorded since." `Spaced` says: a tick may carry a fault only in phase `ready`.
Reading `Phase.next`:

- `ready`, with a fault: `halting` if halted at the tick's end; else, if `found`, `ready`
  if the tick recorded and `ended` if not; else `landed`.
- `landed`: `halting` if halted; else, if `found`, `ready` or `ended` as above; else
  `ready`.
- `halting`: stays while halted; then `ready` if that tick recorded, else `ended`.
- `ended`: `ready` once a tick records.

So `ready` is reached again by "found, halt ended, a round recorded since" in each way that
can come about, the round recorded being allowed to be the round in which the halt ended
(at once: R19, then R20 to R38, which is "since"). That is the sentence. The differences:

- **More than the sentence allows:** `landed` goes to `ready` when the tick after the fault
  ends not halted and not `found` ("taken to be gone (T4 says it is)"). The sentence has no
  clause for a fault that is never found: read to the letter, no fault may ever follow one.
  The Lean reading covers more runs and is the sensible one; the fault model's sentence
  should be made to say it.
- **Less than the sentence allows:** a tick has one fault at most, so the next fault's
  earliest instant is `Fault.between 0` of the tick after the recorded round. By H5 a round
  is recorded when it reaches R36; a second fault before R37 or R38 of that same round is,
  to the letter, after "a round has been worked and recorded", and `T5` does not cover it.
- The phase is told from `r.g.halted`, `r.found` and `r.recorded` at ends of ticks. In
  `ready` with no fault and in `ended`, `Phase.next` does not look at whether the tick
  halted; that is right only because T5's own conclusion (`Clean`, `Settled`) rules it out.
  It is not a flaw, but the definition leans on the theorem it is used in.
- In `landed` the `hasFault` flag is ignored (`| .landed, _ =>`); `Spaced` forbids a fault
  there, so nothing is lost.

**Empty reasons:** none. `Spaced` holds of every run with no faults and of many with.

**Wording (3):** the doc-comment's "Whenever nothing is halted and no fault is waiting to
be found, everything stored agrees" is clause (c), which is for phase `ended` only: the
halt is over and no round has been recorded since. "No fault is waiting to be found" is
looser than that.

### 1.10 `T6_wrong_recorded`, `T6_stuck`, `T6_spacing`

These carry no hypotheses. They are about one game: `Toy.P`, after `played 3`, with the
setting written to at once in all three books (`base`).

**`T6_wrong_recorded` says:** change the record's text of part 4 to 99 and the record's
copy of part 4 to 99 (`Cell.hit` twice, before the round), then do one round at clock 4
with no further fault. That round ends not halted, has recorded something, and what it
recorded is not what the same round from `base` records.

By hand: `base` has state, record and copy (25, 26, 27, 10, 33, 28, 29). R14 passes (the
two halves agree at 99). R15 finds part 4 (99 against 33) and halts. R19: at once,
`correct`; P4 (a) (`text = kept`, `is` differs) writes the state's part 4 := 99; new
observers and the gate find nothing; the halt ends. The work makes part 4 = 99 + 1 + 2 =
102; the toy's rules allow it; it is recorded. With no fault part 4 is 36. I believe the
statement true.

**`T6_stuck` says:** change the text of part 4 to 98 and the copy to 99; after one round
the game is stuck. By hand: R14 finds it; in `restore`, part 4 has `text` 98, `kept` 99,
`is` 33, and `before`'s part 31: none of (b1) to (b4) holds, (b5), `stick`. I believe it
true.

**`T6_spacing` says:** a round at clock 4 with the copy of part 4 changed to 99 immediately
before R24; then a round at clock 5 with the same change immediately before R24. After the
first the game is not stuck; in the second a halt was ended; after the second the game is
stuck. By hand: the first is refused at R28 (the toy's step rule wants `was 4 ≤ is 4`: 99
against 36), `spoiled` 1. The second begins halted; `correct` puts part 4 right by (b3)
and the rest by (a), the halt ends, the work is refused again at R28, `spoiled` 2, R38
`restore` and `stick`. I believe it true.

**Is it what was asked?** "Two faults in one round that the protocol does not survive: a
concrete pair, as a proved counterexample, so that the scope is shown to be tight". Three
pairs are given. The first two are two faults before one round (not "in" it: both are
applied to the stored game before the round starts, which is an instant the fault model
allows). The third is one fault in each of two rounds, and is about the spacing; it is
extra, and useful: it shows the third clause of the spacing sentence is needed.

**The gap (finding 2):** `Sound Toy.P` is false. Y3 in Lean:

```
work_passes : ∀ (s : St V) (q : Q) (dt : Dt) (now : Tm),
  P.canBe₁ s = true → P.canBe₂ s = true →
    P.real (P.work s q dt now) = true ∧ ...
```

and in the toy `real := fun s => allParts.all fun p => s p < 1000000`,
`canBe₁ := fun s => s 3 == 10`. Take `s` with `s 3 = 10` and `s 0 = 999999`: the rules call
it a state the game can be in, the spider's work adds at least 1 to part 0, and `real` of
the result is false. (A long list of large numbers asked does the same through part 6.)
So T1 to T5, which all assume `Sound P`, say nothing of the toy game. The T6 statements are
still true facts about the toy. But "tight" needs the single-fault theorems to hold of the
same game: as it stands a reader can answer that the toy is outside the theorems anyway.
The mend is small: make the toy `Sound` (for instance `real := fun _ => true`; none of the
three T6 runs comes near R26 refusing) and put `theorem toy_sound : Sound Toy.P` among the
statements. If `Faithful.lean` needs a toy whose R26 can refuse, that wants a second toy.

**Smaller points:**

- `T6_wrong_recorded` does not say a halt came and went; `r.found.isSome` and `r.ended`
  could be added so the statement shows the protocol *looked* and still recorded wrong.
- `T6_spacing`'s doc-comment says "with no round recorded between them"; the statement does
  not (`r₁.recorded = none` is not among the conjuncts). It follows from the construction.
- The header says "Each fault of each pair is one that T1 to T4 cover alone." As kinds and
  instants, yes (`Cell.rt`, `Cell.rc` before a round or before R24). As a claim about this
  game, no, until the toy is `Sound`.

## 2. Part B: the definitions the statements rest on

**`Sound` against Y1 to Y4.** Same.

- Y1 `work_same`: for every state, list, list of halted moths, `dt`, `now`, the second
  text's three pieces one after another equal the first text's. As Y1 ("one after another,
  give what the first text's give"): the composite, not each piece.
- Y2 `inWeb_same`: same.
- Y3 `work_passes`: for every state both texts allow, every list, `dt`, `now`: the work
  (with `inWeb₁ s` as the halted moths) has real numbers, is allowed by both texts as a
  state, and is an allowed step by both, the first asked with `inWeb₁ s` and
  `takeIn₁ s q`, the second with `inWeb₂ s` and `takeIn₂ s q`. That is "each asked as
  section 7.6 says" for a round with no fault (state = record's copy, the lists equal).
- Y4 `new_canBe`: same, for every `now`.

**`Params.work`.** Says what its comment says.

**`Settled`.** Says what its comment says. Against section 2: S1 (`state`), S3 with S4
(`record`), S2 (`observers`, whole), S5 (`books`, `noHalt`), S7 (`before`), S8 (`asked`):
all there. S6 is inside S5. S9 is not modelled. `canBe` is not about what is stored
agreeing; it is the invariant Y3 needs, and the comment says so. What `Settled` does not
say is in 1.4: the content of the books, of `before`, of the lists.

**`Clean`.** `Settled` and book 0's `spoiled = 0`. The comment ("the last round worked was
not refused") is fair. It does not say `stops = 0` (finding 1).

**`Reach`.** Says what its comment says.

**`Tick`, `play`.** `play` folds `tick P t.es t.inp none`. Says what its comment says.

**`ledger`.** Says what its comment says. Two things a reader should know: the list is
`vote (events P t.es g).asks` with `g` the faulted run's game, so it is the faulted run's
own history; and whether a round counts is the reporting field `recorded`. `ledger` is
`ledgerF` with no faults; one definition would do for both.

**`Cell`, `Cell.hit` against F1 to F7.** Same, one constructor each. Each replaces one
part, one observer, one text, one copy, one book, one place of `before`, one list, with any
value of its type. A "fault" that writes the value already there is allowed (harmless: it
is gone at once).

**`Sched`, `inject`.** `Sched.cell s c` lands immediately before step `s`, whether or not
the step is skipped. `Sched.answer i a` replaces `r.answers i` before R11, only if the
round has not ended early. Same as section 11. `a` may be the answer the observer gave, and
`i` may be an observer that is not running (R11 then writes nothing for it): both harmless.

**`Fault`, `tick`.** Same as section 11's instants; see 1.3.

**`FTick`, `Phase`, `Phase.next`, `playF`, `Spaced`.** See 1.9. `playF` and `Spaced` use
the same `tick` and the same `Phase.next`, so they cannot drift apart.

**`ledgerF`.** Says what its comment says: the list is voted after the tick's things *with
no fault* (`events P t.es g`, not the faulted events), and `r.dt`, `r.now` are the faulted
tick's. With one fault the voted book and the voted list are what they are with no fault,
so this is consistent with T2's `T₀`.

## 3. Part C: the model against the specification

### 3.1 Items that the Lean does as the specification says

I checked each of these against its item and found no difference.

- **N1, N2, N3, N4, N5, N6, N8**: `Part`, `Who`, `rings` (members and parts in the order
  given), `coord`, `moths`, `sees`, `How`. **N7** is not modelled as an order: `born` is a
  function of the game that does not read the observers, and all eight are replaced at
  once, which is what N7 says the order comes to.
- **S1 to S8**: `Game` and its fields, `Observer`, `Book`, `Halt` (see M13 for the count of
  fields). **S9** is left out, as A7 says.
- **V1, V3, V4**: `vote` is the rule word for word. **V2**: `keep`; the conditions in
  `stick`, `event .putRight` and `mend` are `b.halt.map`, looked at in each place.
- **D1** (A1: a part is its text), **D2** (`fp`), **D3** `holds`, **D4** `printOf`, **D5**
  `copiesFor`, **D7** `heldOf`, **D8** `sound`, `flagging`, **D9** `allHold`, **D10**
  `born`, **D11** `stopAll`, **D12** `stick`, **D13** `newBook`, `newGame`.
- **L2 to L7**: `lookOf`, `lookRing`, `shaped`. The order is the specification's: own
  signal; then for each ring the observer sits in, in order: for each part, L3 then L4 over
  the other observers in the ring's order; then for each other observer, L5 then L6; then
  L7 if observer 5 is in the ring. L4's rule for coordinators is as written. L1 is left out
  (A8).
- **E1 to E3**: `event`. E1: nothing in a stuck halt; then `taken` asked of whether halted,
  the voted list and the thing; then `takeDown` on each list by itself. E2 and E3 as
  written.
- **R1 to R38**: see 3.2 for the conditions and what is read where, and 3.3 for the small
  differences.
- **P1** `mend`: the cases in the specification's order (stuck; asked; at once; on a click;
  after a pause with `last`, `quiet` and the pause counted from `quiet` as just written).
- **P2** `correct`: `restore`; on failure `stick` and nothing more; else all eight `born`;
  the look with `last = rounds`; `restarts` one more; then `differs` (R14 to R17 in one);
  `stick` if anything was found, else the halt removed. The new observers' findings are
  not written to them.
- **P3** `restore`, `restoreParts`: `before` read once, voted, first; the parts in order;
  stop at the first that cannot be settled with the earlier parts already put right; then
  P5.
- **P4** `restorePart`: (a), (b1) to (b5) in order, with the same conditions and writes.
  (b3) writes `text` where the specification says "`before`'s part": under (b3)'s condition
  they are the same value. (b4) writes `kept` where the specification says "the record's
  copy of it": the same value.
- **P5** `restoreAsks`. **P9** `beginAgain` (see M9).
- **F1 to F8**: 2 above.

### 3.2 A round: order, conditions, what is read fresh and what is kept

**Order.** `steps` is R1 to R38 in order, each once; the comments on `Step`'s constructors
match.

**When a step does something.**

| Steps | Lean condition | Specification |
| --- | --- | --- |
| every step | nothing if `r.over` | "A step that is skipped is skipped whole"; R6 and R19 end the round |
| R6 | sets `over` if the voted halt is stuck; begins again first if asked | same |
| R14 | sets `gateLooks := !g.halted` | "done only if not halted", "read once, before R14" (M3) |
| R15 to R17 | `gateLooks` and `off = none` | same |
| R18 | `gateLooks` and (`stop` or `off` is something) | same (M4) |
| R19 | `g.halted`; then `over := g'.halted ∨ how ≠ atOnce` | same |
| R20 to R25 | always (if not over) | same |
| R26 | refuses if not real | same (no `refused = none` guard is needed: nothing has refused yet) |
| R27 to R37 | only while `refused = none` | "the rest of R26 to R37 are skipped" |
| R38 | by `refused` | same (M5) |

**What is read fresh, and what is taken from what the round kept.**

- R10 uses the look made at R9 and `running` from R8; a fault to an observer or the state
  between R9 and R10 is not seen by the observers, as the specification's cut implies.
- R11 writes onto the observers as they are at R11, with `rounds` read at R11 ("Here it is
  read where it is used").
- R12, R13 read the observers and `rounds` fresh.
- R15 to R17 read the game fresh and `gateLooks`, `off` from the round.
- R18 reads `stop`, `off`, `told`, `late` from the round (and "halted" fresh: M4).
- R24 uses `held` from R20, `dt` and `now` from R2. R25 `dt`, `now`.
- R28 reads the state and the record's copy fresh, `asked` from R23.
- R29 reads the state, the record's copy and the second list fresh, R28's answer from the
  round. R30 reads the copy and the second list fresh again.
- R31 reads the state fresh against `made`. R32 fresh.
- R34 uses `seen` from R33 and `sound` fresh. R35 `heldNow` from R33, `sound` fresh.
- R36 writes `made` from R30. R38 uses `beganHalted` from R7 and reads `spoiled` (voted)
  after writing it.

All as the specification's "What it reads" column. The values `start` gives before they
are set (`asked := g.sp`, `made := g.sp`, `seen := g.sp`, `held := P.blank`, and so on) are
never read before the step that sets them: each reader has the same `refused = none` guard
as its writer, and `refused` only ever goes from nothing to something.

### 3.3 Differences and unsettled readings (2)

None of these changes an outcome with one fault from a clean state, as far as I can see.
Each is given with the item and the definition.

- **M1. R1's time is read before the instant "immediately before R1".** R1: "The time given
  to `stop_all` is the book's `time`", and R1 reads "the three books". In Lean it is `t0`,
  read in `start` (`| .clock _ => g.book.time`), before `inject` lands a fault scheduled
  before `.settle1`. With one book changed and the other two equal the vote is the same
  either way.
- **M2. R2 reads `time` after writing `at`.** R2: `dt` and `now` are worked out, then "`at`
  := the clock". `step .note` writes `clock` and then computes
  `now := P.adv g.book.time dt` from the written game. The vote can differ only when all
  three books differed before the write, which R1 has just made impossible. Also:
  `readable` is an unknown that A5 does not list, and the specification does not say what
  `dt` is when the clock could not be read (Lean: still `P.len`).
- **M3. R14's "halted" is read at R14.** Section 7: "whether it is halted, as R14 to R18
  take it (read once, before R14)". `step .selfCheck` reads `g.halted` after a fault
  scheduled before R14 has landed. One book cannot change the vote.
- **M4. R18 looks at "halted" again.** R18: "`stop_all`", under "done only if not halted"
  as read before R14. `step .decide` calls `Run.detect`, which does nothing if
  `r.g.halted`. Same remark.
- **M5. R38 against H2.** R38: "`stop_all` with what was found", no condition. H2: "unless
  everything is already halted", citing the same line 1514. `step .close` calls `stopAll`
  with no condition. The two items of the specification disagree with each other; the Lean
  follows R38. With one fault the round is never halted at R38. With two it could matter
  (a second `halts + 1` and a fresh halt over an old one). Worth settling against the code.
- **M6. R16 has a reason the specification does not.** `obsOff` answers
  `Off.recordChanged` instead of `Off.observer i` when an observer's copies are off and
  `g.rt ≠ g.rc`. Whether something is found is unchanged; only the reason kept in the
  halt's `why` (A10).
- **M7. R4's time.** `settleBefore r.now`. R4 does not say which time `stop_all` is given.
- **M8. "One more" is done in each place by itself.** R7 (`rounds`), D11 (`halts`), P2
  (`restarts`), R38 (`spoiled`): `keep (fun b => { b with rounds := b.rounds + 1 })` adds
  one to each place's own number. V2 says "the same change made to each of the three places
  separately", which fits; but R7 lists "the book (voted)" as what it reads, and a reader
  could take `rounds := rounds + 1` as the voted number plus one, written to all three.
  The two differ for a fault that changed only that one number in one book after R3: by
  the Lean the place stays different and R1 of the next round finds it; by the other
  reading it is written over. Both are outcomes T4 allows. Worth one sentence in V2.
- **M9. P9 keeps the voted setting and `at`.** `beginAgain` writes the voted `how` and
  `clock` to all three new books. P9 says "which are kept": each place's own, or the voted
  one, is not said. Reached only from a stuck halt.
- **M10. `in_web`, the look's world, and `asked` are of whole states.** D6: "worked out
  from the state (from its world)"; section 5: "the state's world"; R23: "what the rules
  need to know of what was asked". Lean: `inWeb₁ : St V → V`, the look's `world := g.sp`,
  `asked := g.sp` (the whole state after taking in, handed to `step₁`). Each is more
  general than the item (an unknown function of the whole state includes every function of
  a part of it), so nothing is lost.
- **M11. One `blank` for three things**: the empty text (D5), the empty list of halted
  moths (D7, L6), and a new book's `rest`. The specification does not say the empty text
  and the empty list are one value. They are never compared with each other, so it is
  harmless.
- **M12. `newState : Tm → St V`.** D13: "a new state". The Lean lets it depend on `now`;
  more general. `rest` of a new book is `blank`; the specification does not say.
- **M13. The halt has five fields in Lean; V1 says seven.** A10 puts the halt's `aside`
  and `put` into `rest`, which is a field of the book, present with or without a halt.
  S5 says `rest` stands for ten fields and A10 lists twelve. A10's own remark covers the
  consequence. The count wants making the same in S5, S6, V1 and A10.
- **M14. R9's `last`** is `g.book.rounds - 1` on whole numbers from 0, which is 0 at 0.
  After R7 the voted number is at least 1, so it is never reached.
- **M15. The look's `rounds`** is in `Look` and nothing reads it; the same is true of L1
  to L7, so the model matches the specification here.
- **M16. Reasons are finer than the specification's** (`Cause.late`, `.silent`,
  `.observer f`). A10: kept only as which check made it.
- **M17. What the round keeps.** Section 7's list of the round's own values leaves out
  some that its own steps name (`seen`, `held_now`, the late observer, the reason taken at
  R12, R28's answer, whether refused). `Run` has them all, and `t0`. A wording matter in
  the specification.
- **M18. Section 11 on R12.** "The steps R12, R22 to R25, R28 to R30 and R38 each read or
  write a cell once" does not fit R12 as written or as modelled (see 1.3). The model has no
  instant inside R12, as the specification says; it is the specification's reason that is
  thin.

### 3.4 The two modelling devices

**The reset at R18.** `step .decide` ends with

```
{ r' with running := fun _ => false, look := ⟨0, 0, r'.g.sp, r'.g.ob, r'.g.sp⟩,
          answers := fun _ => none, late := none, told := none, stop := false,
          gateLooks := false, off := none }
```

It writes no field of `r'.g`. After R18 the steps read, of the round's own values, only:
`over`, `now`, `dt`, `held`, `asked`, `ruled1`, `refused`, `made`, `seen`, `heldNow`,
`beganHalted`. None of the eight reset values is among them. `inject` writes `answers` only
at `Step.signals`, which is before R18. So the reset cannot change what is stored, in that
round or any later one (`start` makes a fresh `Run` from the game alone). Its comment
("nothing reads it again") is true. Its purpose is not said; I take it to be so that two
runs that differ only in what the observers were shown end as equal `Run`s.

**The four reporting fields.** `recorded` is written at R36 only; `found` in `Run.detect`
and at R38; `worked` at R21; `ended` at R19. No branch of `step`, `inject`, `run` or `start`
reads any of them. So they cannot change what is stored. What they report:

- `recorded`: the value written to the record at R36. See 1.3.
- `found`: the last detection that halted everything in this round (if a round is found at
  R18, mended at R19 and refused at R38, the R38 cause is kept). See 1.8.
- `worked`: R21 was done.
- `ended`: R19 was done while halted and the voted book had no halt after `mend`.

They say what their comments say, with the two notes above.

## 4. Part D: what else I would want fixed before the proofs are trusted

**Things to add to the statements.**

- `stops = 0`, for `T2_at_once` (finding 1).
- `Sound Toy.P`, after making it true (finding 2).
- A statement that, from a clean state with halts set to end at once, a tick whose fault is
  found before R19 has `ended` and `worked` (so `T2_at_once`'s hypotheses are shown to
  hold, and W1's first half is claimed).
- A statement that a tick with `found.isSome` leaves the voted `halts` one more, so T4's
  "found" gives T2's `g.book.halts < gₙ.book.halts`.
- In T2's doc-comment, in words: which of the two forms it is ("the round the faulted run
  has reached, counting the rounds it recorded"), and what is *not* claimed of the books,
  `before` and the lists, with the `before` case of 1.4.
- In the fault model or in section 12: that S9's three places are outside (asked-for says
  "anything kept in three").
- In the spacing sentence: the case of a fault that is never found.

**Names (3).**

- `asked` is three things: `Run.asked` (the state after taking in), `Halt.asked` (the halt
  has been asked to end), `Settled.asked` (the three lists agree). And `Game.asks` is the
  lists.
- `before` is three things: `Fault.before` (immediately before a step), `Cause.before`
  and `Settled.before` and `settleBefore` (the kept state S7).
- `none` is two things side by side: `tick P es inp none g` (no fault, `Option.none`) and
  `round P inp .none g` (`Sched.none`).
- `held` is `Observer.held` and `Run.held`.
- `Step.decide` sits beside the `decide` used in `step .mend`; `Step.unfit` beside
  `Cause.unfit`; `Step.mend` beside `mend`; `Step.look`, `Step.running` beside the fields.
- `sp` for the whole state reads as "spider" (parts 0 to 2). `rt`, `rc`, `bk`, `bf` want
  one line each where they are first used in `Challenge.lean`, since a reader of the
  statements meets `r.g.rt` before `Game`'s comment.
- `Book.clock` is the specification's `at`.
- `Tick` and `FTick`, `ledger` and `ledgerF`, `play` and `playF`: each pair is one thing
  with and without faults.

**Comments that say more than the definition or statement (3).**

- `reach_clean`: "no round has been refused" (1.1).
- `T2`: "the record as it stood after the tick of the fault" (1.4).
- `T2_at_once`: "(which is so when halts end at once and the fault is found before the
  work)" is a claim no statement makes (1.5).
- `T5`: "Whenever nothing is halted and no fault is waiting to be found" (1.9).
- `T6_spacing`: "with no round recorded between them" (1.10).
- `T6` header: "Each fault of each pair is one that T1 to T4 cover alone" (1.10).
- `Challenge.lean` header: "at any instant of the tick" should be "at any instant the
  specification describes" (no instant inside R6, R19, or the `restore` of R38; none part
  of the way through a step).
- `Run.found`: "The detection that halted everything in this round": the last such, and
  none if the round was already halted.
- `Book`: "`rest` stands for the ten fields that are only said (A9, A10)": A10 lists
  twelve.
- `Params.redo`: "R36 with R30" is R30; R36 only writes it.
- `Toy.lean` header: "the two faults of T6 (`Solution.lean`)": there are three pairs; and
  it names two files a reader of the statements is not given. "A fingerprint is the value
  modulo 5": it is that plus 1000.

## 5. The three lists

### (1) A statement says something other than what was asked

| # | Statement | What |
| --- | --- | --- |
| 1 | `T2_at_once` | False for a clean state with `stops ≠ 0` and a fault found at R1, R3 or R4. Needs `stops = 0`. |
| 2 | `T6_*` | The toy game does not meet `Sound` (`real`), so T6 does not show the scope of T1 to T5 tight. |
| 3 | `T2`, `T5` | Books, `before`, lists: agreement only. `before` can hold the fault's value after the halt has ended. No comparison with a run with no fault. "Exactly which" not said in words. |
| 4 | `T1` | `recorded` is the value written at R36: not the observers' copies of R34 and R35, not the record at the end of the tick. |
| 5 | all | S9 (kept in three for the threads) is not a cell. |
| 6 | `T2_at_once`, `T3_ends`, `T4` with `T2` | Nothing says an at-once halt found before R19 ends in the same round; `found` is not linked to `halts`. |
| 7 | `T5` (`Spaced`) | Allows a fault after one never found; earliest next fault is the next tick, not the rest of the recorded round. |
| 8 | `T4` | "Found" is `found`: a detection that halted everything. Same as H1 here, since both rounds begin not halted. |
| 9 | `T1` to `T5` | "Every instant" is the 38 instants before a step, those between the things of section 6, and F8's; instants part of the way through a step rest on section 11's argument, which is not in the model. |

Stronger than asked, throughout: every `Clean` state and not only reachable ones; whole
cells and not single fields; every setting, every mix of things between rounds, both kinds
of round input; T2 at every later end of tick; T4's third case is equality of everything
stored; `T3_ends` and `T6_spacing` are extra.

### (2) The model differs from the specification

M1 to M18 in section 3.3. The ones I would settle against the code: M5 (R38 against H2),
M8 (per-place `+ 1`), M1 and M3 (where R1's time and R14's "halted" are read), M9 (P9's
"kept"). The rest are generalisations, reasons only, or wording in the specification.

### (3) Wording

Section 4: the names used for two or three things, and the eleven comments listed.
