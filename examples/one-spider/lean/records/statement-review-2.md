# Statement review 2: what the Lean statements say, and whether that is what was asked

A reading by a fresh reader. Nothing was run. The only files read were
`protocol-spec.md`, `reviews\asked-for.md`, `lean\GateProof\Model.lean`,
`lean\GateProof\Claims.lean`, `lean\GateProof\Toy.lean` and `lean\GateProof\Challenge.lean`.
No proof was seen. Everything below that says a statement "holds" means: I worked the
model's definitions by hand over the cases listed and found no way to break it. It is
not a proof.

## Summary

1. **I found no statement that is false as written.** What I tried is in part B.
2. **T2 says less than the T2 that was asked for, and the T2 that was asked for is not
   literally true of the model.** The Lean `T2` concludes `Settled`, which for the three
   places of the book, of `before` and of the lists says only that the three places are
   the same as one another, not what they hold. There is a concrete run (part A, T2) in
   which, after the halt has ended, all three places of `before` hold a state with the
   faulted value in it, and the book's `spoiled` is 1. The Lean statement is true of that
   run; "every place of three is what it is in the run with no fault" is not.
3. **T2 does not compare with the run with no fault** except in `T2_at_once`. In general
   it says the record is what `ledger` computes: the work with no fault, applied once for
   each round the *faulted* run recorded, with the faulted run's own lists, lengths and
   times. That answers "say exactly which" as "the round the faulted run has reached",
   but only for the record (and through `Settled` the state, the record's copy and the
   observers).
4. **Nothing states that the book's own contents come through a book fault**, except
   `T2_at_once` (found, ended and worked in the fault's own tick). In the model they do
   (the two untouched places win the vote), but no statement says so for a halt that ends
   in a later tick.
5. **T5's spacing is not the asked spacing word for word.** It is wider in one way (a new
   fault may land two ticks after a fault that was never found) and narrower in another
   (at most one fault in a tick, so a fault after R36 of the very round that was recorded
   is not allowed).
6. **Every statement carries `Sound P` (Y1 to Y4) and is about the model**, with all of
   section 12's abstractions. The theorems as asked mention neither.
7. **T6 is shown on the toy game, and its first two pairs both land before one round**
   (not inside it). `T6_wrong_recorded` depends on the toy's rules being lax; it shows the
   general theorem cannot be widened to two faults, not that the real game records wrong
   for that pair.
8. **The model follows the specification closely** for the items checked. The differences
   are small and none changes an outcome for one fault (part D).
9. Some doc-comments say more than the Lean under them (part C), `T6_spacing`'s most of
   all.

The three kinds asked for are listed separately at the end: (1) false or other than
asked, (2) model against specification, (3) wording.

---

## A. Each statement: what it claims, its hypotheses, and how it sits beside what was asked

Throughout, every statement is for any types `V Q E Tm Dt` with decidable equality on
`V`, `Q` and `Tm`, and any unknowns `P : Params V Q E Tm Dt`. "Clean" unfolds to:

- `g.sp = g.rt`, `g.rc = g.rt`;
- every observer `g.ob i` equals `born P g i` (name `i`, alive, `beat` = the voted
  `rounds`, copies `copiesFor P i g.rt`, `held` = `inWeb₁ g.rc` for observer 5 and `blank`
  for the others, no flag, no reason);
- `g.bk 0 = g.bk 1`, `g.bk 0 = g.bk 2`, and `(g.bk 0).halt = none`;
- `g.bf 0 = g.bf 1`, `g.bf 0 = g.bf 2`; `g.asks 0 = g.asks 1`, `g.asks 0 = g.asks 2`;
- `canBe₁ g.rt` and `canBe₂ g.rt`;
- `(g.bk 0).spoiled = 0` and `(g.bk 0).stops = 0`.

`Settled` is the same without the last line. Neither constrains: what the three places
of `before` hold (any state, or nothing, so long as the three are the same); what the
three lists hold; the book's `how`, `halts`, `restarts`, `clock`, `time`, `rounds`,
`rest`.

`Sound P` is Y1 (`work_same`, the composition of the three second texts equals that of
the first, for every state, list, list of halted moths, `dt`, `now`), Y2 (`inWeb_same`),
Y3 (`work_passes`) and Y4 (`new_canBe`). I compared each with section 13 and they say
the same.

### `reach_clean`

**Hypotheses:** `Sound P`; `Reach P g`.

**Claims:** any game got from `newGame P now` (any `now`) by any finite number of: one
thing between rounds (`event`: ask, put right, set how), or one whole round with no
fault given any input (`round P inp .none`), is `Clean`.

**Against what was asked:** not one of T1 to T6. It is the bridge from T1's words "every
state the program can reach with no fault" to the hypothesis `Clean` that T1 to T5
carry. `Clean` is a larger set than `Reach` (it allows any `before`, any lists, any
counts), so stating T1 to T5 for `Clean` is stronger than asked. "A state the program
can reach" here means a state between rounds; a state part of the way through a round is
not in `Reach` (the fault's instant covers that).

**Against the specification:** D13 and section 7 support it. I traced a round with no
fault from a clean state step by step (R1 to R38) and every check passes with Y1 to Y3;
see `nofault_round`.

### `nofault_round`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, any `inp`.

**Claims:** let `r` be: the things in `es`, then one round with no fault. Then (i)
`r.recorded = some (P.work g.rt q r.dt r.now)` where `q` is the voted list after `es`;
(ii) `r.found = none`; (iii) `r.g` is `Clean`; (iv) `r.recorded = some r.g.rt`.

**Against what was asked:** not asked for by number. It is the sentence in section 13,
"With Y1 to Y3 no round with no fault is refused", made exact, and it fixes what "what
the same round with no fault records" means in T1.

**Check:** `P.work s q dt now = spider₁ (world₁ (takeIn₁ s q) (inWeb₁ s) dt now) dt now`.
In the model the round reads `held` from observer 5 (R20), which in a clean state is
`inWeb₁ g.rc = inWeb₁ g.rt`, takes in `g.asks 0` (R22), and R30 makes
`P.redo g.rc (g.asks 1)`, which Y1 (with `h := inWeb₂ rc`) and Y2 turn into the same
value. R28 uses `r.asked` = the state after R22 = `takeIn₁ rt q`, and Y3's fourth
conjunct is stated with exactly that; R29 uses `takeIn₂ g.rc (g.asks 1)` and Y3's fifth
is stated with that. So the statement is what the model does.

### `T1`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`; any `f : Fault V Q Tm`.

**Claims:** `(tick P es inp (some f) g).recorded = none`, or it equals
`(tick P es inp none g).recorded`. `recorded` is a field the model adds to the round
(`Run.recorded`, "not the program's"): it is set only at R36, to `some r.made`, the value
written to both halves of the record.

**Against T1 as asked:** this is T1. Stronger: clean states, not only reachable ones; a
whole cell changed, not one field; any book in one place; any list, not one entry.
Things to know:

- It is about what R36 writes, not about what the record holds at the end of the round.
  A fault to `rt` or `rc` immediately before R37 or R38 leaves a record that is not what
  was recorded. The doc-comment says "what it writes to the record (at R36)", which is
  exact.
- It is about the record only. With `Fault.before .see (Cell.sp p v)` (or before R32)
  the round is recorded with the right record, but R33 takes `seen := g.sp` with the
  faulted part in it, so at R34 and R35 every sound observer's copy of `p` and observer
  5's `held` take the faulted value. R15 finds it in the next round. T1 does not speak
  of that and was not asked to.
- It covers the fault's own tick only. That a later round records nothing wrong is
  carried by T4's third case and by the `ledger` clause of T2.
- Instants: before each of the 38 steps, after any number of the things between rounds,
  and one answer between R10 and R11. An instant inside a step is not in the model; the
  header of `Challenge.lean` says so and points to section 11's argument.

**Against the specification:** supported. `recorded` can only be `r.made`, made at R30
from `g.rc`, `g.asks 1`, `r.dt`, `r.now`; R31 holds it to `g.sp`, made from the state,
observer 5's `held` and `g.asks 0`. No one cell feeds both sides, and `dt` and `now` come
from the voted book, which one changed place cannot move.

### `T2`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`, `f`; any list `ts` of later
ticks with no fault. Then two more inside the statement: `gₙ.halted = false` and
`g.book.halts < gₙ.book.halts`, where `gₙ = play P ts r₀.g` and `r₀` is the tick with the
fault.

**Claims:** `Settled P gₙ`, and `gₙ.rt = ledger P ts T₀ r₀.g`, where `T₀` is the record
the same tick with no fault leaves if the faulted tick was recorded, and `g.rt` if not.
`ledger` walks `ts` from `r₀.g`: for each tick it runs the tick with no fault on the
faulted run's game, and if that round was recorded it replaces `T` by
`P.work T (vote (events P t.es g).asks) r.dt r.now`; otherwise `T` stays.

**Against T2 as asked** ("everything stored (the state, the record, every observer's
copy, every place of three) is what it is in the run with no fault at the same round, or
at the round the faulted run has reached if a round was not worked. Say exactly which."):

*Weaker, in four ways.*

1. **Places of three: sameness, not content.** `Settled.books` is
   `g.bk 0 = g.bk 1 ∧ g.bk 0 = g.bk 2` with `noHalt`; `Settled.before` is
   `g.bf 0 = g.bf 1 ∧ g.bf 0 = g.bf 2`; `Settled.asked` likewise. None says what is held.
   A protocol that set all three places to the *faulted* one would also meet `Settled`.
2. **`before` can hold the faulted state after the halt has ended.** Concrete run, on
   the toy game: start from `Toy.played 3` (reachable, so clean; setting after a pause;
   state, record and copy `[25,26,27,10,33,28,29]`; `before` = the state before round 3).
   Fault `Fault.before .keepBefore (Cell.sp 4 77)` in a tick with no events and
   `.clock 4`. R21 writes `some [25,26,27,10,77,28,29]` to all three places of `before`.
   The work makes `[26,27,28,10,80,29,30]`; R26 to R29 pass (the toy's rules ask only
   that part 3 is 10 and part 4 has not gone down); R30 makes `[26,27,28,10,36,29,30]`;
   R31 refuses; R38 halts everything, `spoiled` = 1. Next tick: events `[.putRight]`,
   `.clock 5`. R19: the halt has been asked, `correct` runs, `restore` puts every part of
   the state back by P4(a), the observers are new, the halt is over, and the round ends
   there (the setting is not at once). Now `gₙ.halted = false` and the voted `halts` is 1,
   more than 0: T2's hypotheses hold. `Settled` holds and `gₙ.rt` is the ledger's value.
   But all three places of `before` are `some [25,26,27,10,77,28,29]`: the 77 is the
   fault. In no run with no fault does `before` hold that. It stays until the next
   round's R21 writes over it. It is harmless under the spacing (it is read only by
   P4(b3) and (b4), which need the record's two halves to differ, and no fault may land
   before a round is recorded), but it is not "what it is in the run with no fault".
3. **The book's contents are not stated.** In the same run `spoiled` is 1, not 0, and
   `halts` and `restarts` are 1; those are by design. But `how`, `rest`, `rounds`, `time`
   and `clock` are not said to be right either. In the model they are (a fault to one
   place loses the vote and R1 or R3 writes the other two over it), yet only
   `T2_at_once` says anything about the book's fields.
4. **The lists' contents are not stated** when the halt does not end at once. In the
   model P5 puts the voted list in all three; T2 says only that the three are the same.
   The `ledger` cannot see a wrong list once all three agree on it, because it reads
   `vote (events P t.es g).asks` from the faulted run itself.

*Different.* The comparison is not with the run with no fault. `ledger` is computed from
the faulted run: which of its rounds were recorded, its voted lists, its `dt` and `now`.
So T2 says "the record is the record from before the fault (or after the fault's round,
if that round was recorded), with the work with no fault done once for each round this
run has recorded since". That is "at the round the faulted run has reached", counted in
recorded rounds. It cannot be the run with no fault at the same round: a halted round
does no work, time goes on, and E1 takes down differently while halted. The statement
itself does not say "which" in words; the doc-comment and `T2_at_once` do.

*Stronger.* It holds at the end of every later tick in which nothing is halted, not only
at the moment the halt ends. `Settled.observers` is the whole observer, not only its
copies. `Settled.canBe` (the record is a state the game can be in) is more than asked.

*The second hypothesis.* "A halt has begun since the fault" is written as the voted
count of halts being more than it was before the tick. `found_counts` is what ties that
count to a detection.

**Against the specification:** supported for what it does say. I checked every way a
halt can begin after one fault and, for each, that `restore` settles every part (the
table is in part B).

### `T2_at_once`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`, `f`. Inside: `r.found.isSome`,
`r.ended = true`, `r.worked = true`, all of the tick with the fault.

**Claims:** at the end of that tick, `sp`, `ob`, `rt`, `rc`, `bf`, `asks` are equal to
those of the same tick with no fault, and each place of the book equals the no-fault
place with `halts` and `restarts` each one more.

**Against T2 as asked:** this is the "same round" half of T2, and it is the only
statement that compares everything stored with the run with no fault. It applies only
when the three hypotheses hold, which forces: the fault was found before R19 in its own
round, the setting is at once (otherwise `over` is set at R19 and R21 is not reached),
and the halt ended. `found`, `ended` and `worked` are fields the model adds.

**The last conjunct.** I looked for a book field other than `halts` and `restarts` that
could differ. `stops` is the one that nearly does: at R38 the model writes
`stops := if r.beganHalted = true then b.stops else 0`, and when the fault is found at
R1, R3 or R4 the round has `beganHalted = true` (R7 comes after), where the round with
no fault has it false. The two agree only because `Clean` has `stops = 0` and nothing in
the model raises it (A12). `halt` is `none` in both; `time`, `clock`, `rounds` are
written from the voted book in both; `rest` and `how` are the two untouched places'.
`halts` goes up once (one `stopAll`; R1, R3 and R4 look first, R18 goes by `gateLooks`)
and `restarts` once (one `correct`).

### `found_counts`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`, `f`.

**Claims:** after the tick with the fault, the voted `halts` is the voted `halts` of `g`
(before the events) plus 1 if `r.found` is something, plus 0 if not.

**Against what was asked:** not asked by number. It supports T2's second hypothesis and
T4's word "found". It would fail if `stopAll` could run twice in the tick (found before
R19, halt ended at once, then the work refused at R38). With one fault that cannot
happen: after any successful `correct` the state is the clean one again and Y3 passes
the work.

### `T3`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`, `f`, `ts`.

**Claims:** after the tick with the fault and any number of later ticks with no fault,
`Game.stuck` is false: the voted book has no halt, or its halt has `stuck = false`.

**Against T3 as asked** ("No single fault leads to a halt that cannot be put right"):
this is T3 in the protocol's own sense: `stick` is never reached. It is said at the end
of each tick, which is enough: once set, `stuck` lasts to the end of its round. On its
own it would allow a halt that is not marked stuck but never ends; `T3_ends` closes that.

### `T3_ends`

**Hypotheses:** as T3, and one more tick `t`. Inside: for the halt `h` in the voted book
after `t`'s events (`g'`), one of: `g'.book.how = How.atOnce`; `h.asked = true`; or
`how = afterAPause` and `P.pauseOver (if h.last = some g'.sp then h.quiet else r.now) r.now`.

**Claims:** after `t`'s round nothing is halted.

**Against T3 as asked:** more than asked. The three conditions are exactly the three ways
`mend` reaches `correct` for a halt that is not stuck (P1), and the pause clause matches
`mend`'s `quiet` ("as just written, if it was"). I checked that nothing in R1 to R18 of a
halted round changes the halt, the state or the setting, so reading them from `g'` is
the same as reading them at R19. With the setting at once the round goes on to the work
after `correct`; the claim then also needs that work not to be refused, which holds.

Not covered: the fault's own tick (`t` comes after it). No statement says outright that
a halt begun before R19 in the fault's own round, with the setting at once, ends in that
round. It follows (not stuck after `correct` means the halt is over), but it is not
written. On a click and never asked, and after a pause that `pauseOver` never calls
over, nothing is claimed; A5 says as much.

### `T4`

**Hypotheses:** `Sound P`; `Clean P g`; any `es`, `inp`, `f`; one more tick `t`.

**Claims:** `r₀.found` is something; or `r₁.found` is something; or all three of:
the whole game after the second tick equals the whole game after the same two ticks with
no fault, the first round's `recorded` is the no-fault one's, and the second's is too.

**Against T4 as asked:** this is T4. Three things to know.

- "Found" is `found.isSome`: some `stopAll` ran in that round through R1, R3, R4, R18 or
  R38. It is not said to be a detection *of the fault*; with one fault from a clean state
  there is nothing else to detect.
- "Gone" is measured after the *second* tick, not the first. That is needed: with a
  fault to the state immediately before R21 (or R16 to R20) that the work writes over,
  the round is recorded rightly and nothing is found, but `before` holds the faulted
  state until the next round's R21.
- For a fault between rounds, "the round it lands in" is the round that follows.

### `T5`

**Hypotheses:** `Sound P`; `Clean P g`; any list `ts` of ticks each with at most one
fault; `Spaced P ts Phase.ready g`.

**Claims:** at the end of the run: not stuck; if the phase is `ready`, the game is
`Clean` and its record is `ledgerF P ts g.rt g`; if the phase is `ended`, the game is
`Settled` and its record is the same `ledgerF` value. Nothing but "not stuck" is claimed
in the phases `landed` and `halting`.

`Phase.next`, unfolded: from `ready` with a fault: `halting` if halted at the end;
otherwise, if something was found, `ready` if the round was recorded and `ended` if
not; otherwise `landed`. From `landed`: the same, but `ready` where it said `landed`.
From `halting`: `halting` while halted; then `ready` if that round was recorded, `ended`
if not. From `ended`: `ready` once a round is recorded. `Spaced` asks only that a tick
has a fault only when the phase before it is `ready`.

**Against T5 as asked** ("Any sequence of faults that meets the model's spacing leaves,
after each halt, what T2 says"):

- *Stronger:* `Clean`, not only `Settled`, once a round has been recorded; not stuck
  throughout; and the spacing lets a new fault land two ticks after a fault that was
  never found (`landed` then `ready`), which the asked spacing ("only after the first has
  been found, its halt has ended, and a round has been worked and recorded since") does
  not speak of. T4 is what makes that sound.
- *Weaker:* at most one fault in a tick. When a fault is found, its halt ends and the
  round is recorded all in one tick, the asked spacing would let the next fault land
  immediately before R37 or R38 of that same round; here it may land only from the next
  tick on. The same when a halt ends at R19 and the round is then recorded.
- *"After each halt"* is covered because any front part of a spaced run is spaced.
- What "what T2 says" amounts to is what the Lean T2 says: sameness of the three places,
  and the record by `ledgerF`. The four weaknesses listed under T2 carry over.
- `ledgerF` reads the list voted after the tick's events *without* the tick's fault
  (`vote (events P t.es g).asks`), and `r.dt`, `r.now` from the tick *with* its fault.
  Both are the no-fault values: one changed list loses the vote, and `dt` and `now` come
  from the voted book.

### `Toy.sound`

**Hypotheses:** none. **Claims:** the toy `P` meets Y1 to Y4. Checked by hand: the two
texts are written identically; the work never changes part 3, so `real` (`s 3 < 1000000`)
and `canBe` (`s 3 == 10`) hold of the work of any state with part 3 equal to 10; the
world's work only adds to part 4, so `step` holds; a new state has part 3 equal to 10.

### `Toy.T6_wrong_recorded`

**Hypotheses:** none. **Claims:** on `base` (the toy after three rounds, set to at once)
with `rt 4` and `rc 4` both changed to 99, one round with `.clock 4`: nothing is halted
at the end, the round is recorded, and what is recorded is not what the round from
`base` records.

By hand: `base` has state, record and copy `[25,26,27,10,33,28,29]`. The observers find
nothing (the state and their copies agree). R14 passes (the two halves agree). R15 finds
part 4 (99 against 33), R18 halts. R19: at once, `correct`; P4(a) sees the two halves
agree and writes the record's 99 *into the state*; the new observers and the gate find
nothing; the halt is over. The work makes `[26,27,28,10,102,29,30]`, the rules pass
(part 3 is 10, 99 ≤ 102), R30 makes the same, the round is recorded. From `base` the
round records `[26,27,28,10,36,29,30]`. True.

### `Toy.T6_stuck`

**Hypotheses:** none. **Claims:** with `rt 4 := 98` and `rc 4 := 99`, after one round the
halt is stuck. By hand: R14 finds it, R19 `correct`, P4 for part 4: text 98, kept 99,
state 33, `before` 31; none of (b1) to (b4); `restore` fails; `stick`. True.

### `Toy.T6_spacing`

**Hypotheses:** none. **Claims:** three things only: after round one (fault `rc 4 := 99`
immediately before R24) the halt is not stuck; in round two (the same fault again) a halt
was ended; after round two the halt is stuck. By hand: round one, R28 says no (99 ≤ 36
fails), refused, `spoiled` = 1. Round two: R19 `correct`, P4(b3) for part 4 (`before` is
33 and every observer still holds 33), halt over, work, the fault, refused, `spoiled` =
2, `restore`, `stick`. True.

**T6 against what was asked** ("Two faults in one round that the protocol does not
survive: a concrete pair, as a proved counterexample"): the first two are a concrete
pair each. Both faults of each pair land before R1 of one round (they are applied to
`base` before `round`), so "in one round" is "before one round, at one instant". The
third is two faults in two rounds, which is more than was asked and is about the
spacing. All three are on the toy's unknowns. `T6_stuck` depends on nothing in the toy's
rules. `T6_wrong_recorded` does: it needs R27 to R29 to pass a record with 99 in part 4.
It shows that T1 cannot be had for two faults for every sound `P`; whether the real game
records wrong for that pair depends on the real rules.

---

## B. Looking for a statement that is false

I found none. This is what I tried.

### One fault, by cell and instant

For each cell I followed the round from a clean state. "Found" means `stopAll` ran.

| Cell | Lands | What happens |
| --- | --- | --- |
| `sp p` | between rounds, or before R1 to R9 | observers that see `p` flag (L3) at R10 to R13; R18 halts |
| `sp p` | before R10 to R15 | the look was taken at R9; R15 finds it; R18 halts |
| `sp p` | before R16 to R21 | R21 writes the faulted state to `before`; the work starts from it; refused at R26 to R31, or the work writes over it and the round is recorded rightly with `before` wrong until the next R21 |
| `sp p` | before R22 to R25 | refused at R26 to R31, or written over by the work |
| `sp p` | before R26 to R31 | refused (R31 at the latest: `made ≠ sp`) |
| `sp p` | before R32 to R38 | recorded rightly; before R32 or R33 the observers' copies and observer 5's `held` take the faulted value at R34, R35; R15 finds it next round |
| `ob i` | before R1 to R16 | found at R13 or R16, unless only `beat` changed after the look (before R10 or R11), which R11 writes over |
| `ob i` | before R17 to R32 | R32 refuses (observer 5's `held` before R20 also spoils the work) |
| `ob i` | before R33 to R38 | copies written over at R34, observer 5's `held` at R35, if the observer is still sound and nothing else changed; otherwise found next round (its own L2, the others' L5 or L6, R13, R16) |
| `rt p` | before R1 to R16 | R14, R15 or R16 |
| `rt p` | before R17 to R32 | R32 refuses (an observer that is not a coordinator sees every part) |
| `rt p` | before R33 to R36 | written over at R36 |
| `rt p` | before R37, R38 | R14 next round |
| `rc p` | before R1 to R14 | R14 |
| `rc p` | before R15 to R32 | R16 or R32 if `inWeb₁` of the copy changed; R27 to R31 refuse; or everything passes with `made = sp`, and then what is recorded is the right value and R36 writes over the fault |
| `rc p` | before R33 to R36 | written over at R36 |
| `rc p` | before R37, R38 | R14 next round |
| `bk k` | between rounds, before R1 to R3 | R1 or R3 (before R2, a change to `clock` alone is written over if the clock can be read) |
| `bk k` | before R4 to R38 | not looked at again this round; the voted book is the other two; written over if only `time` (before R5) or `spoiled`, `stops` (before R38) changed; otherwise R1 next round |
| `bf k` | before R1 to R4 | R4 |
| `bf k` | before R5 to R21 | written over at R21 |
| `bf k` | before R22 to R38 | R4 next round |
| `asks k` | before R1 to R17 | R17, unless `takeDown` makes the three the same again |
| `asks k` | after R17 | list 0 before R22 or list 1 before R30: refused or masked; otherwise emptied at R37; before R38: R17 next round |
| answer | R10 to R11 | none: late, R13; a finding: flag, R12, R13; the same answer: nothing |

In every row the value recorded, if any, is the work with no fault; and whatever is not
found in the fault's round is either found in R1 to R18 of the next (every cell is
compared exactly there: books R1, `before` R4, state R15, record R14, observers R16
after the look, lists R17) or the two games are the same after the next round's R21.

### `restore`, in every halt one fault can cause

The record's two halves differ only after a fault to `rt p` or `rc p`. With `a` the
value before the fault, `v` the fault, `W` the state after the work:

| Fault | Halt from | P4 for `p` |
| --- | --- | --- |
| `rt p` | R14 to R16, same or next round | (b1) fails (state is `a`, text is `v`); (b2) holds |
| `rt p` | refused at R32 | (b1) fails (`allHold p v` fails: an observer that is not a coordinator holds `a`); (b2) if `W p = a`; (b3) fails; (b4) holds (`before` was written at R21 of this round, from the unfaulted state) |
| `rc p` | R14, R16 | (b1) holds |
| `rc p` | refused at R27 to R32 | (b1) if `W p = a`; (b2) fails on `allHold`; (b3) holds |

Every other halt has the two halves equal and P4(a) alone runs. After a `restore` that
succeeds, the new observers and the gate cannot find anything (each of (a) to (b4)
leaves state, text and copy of the part equal; new observers are made from that record),
so in the model `stick .stillFound` is never reached once `restore` succeeds. And after
one refused round the next work is from the clean record again and passes by Y3, so R38
never counts two.

### The places I was pointed at

- **Fields `Clean` and `Settled` leave free.** `before` may hold any state in a clean
  game. `restore` reads it only at (b3) and (b4), and those are reached only after a
  refused round, whose R21 has just written it. In the fault's own round (b1) or (b2)
  settles first. So an arbitrary `before` cannot be made to matter. `stops = 0` *is* in
  `Clean` and is needed (see `T2_at_once`). Lists, counts, times, `how`, `rest`: nothing
  depends on them.
- **`Cell.bk`.** One changed place can never be the voted one (`vote`: place 0 if it
  equals 1 or 2, else place 1 if 1 equals 2), and every write is the same change to each
  place, so the two untouched places stay equal. I tried a place with a halt in it, a
  stuck halt, a different `halts`, `rounds`, `spoiled`, `how`, and `E2` or `E3` landing
  after it: R1 writes the other two over it each time.
- **`Cell.bf`.** In the table. The one lasting effect is the `before` example under T2,
  which comes from a fault to the state, not to `before`.
- **`Fault.between n c` with `n` past the end.** `es.take n = es` and `es.drop n = []`:
  the fault lands after all the things. Every `n` from the list's length on is the same
  fault. It differs from `Fault.before .settle1 c` only in that `start` reads `t0` after
  the fault, and `t0` is voted. Nothing breaks.
- **`T2_at_once`, last conjunct.** Under T2_at_once above. `stops` is the near miss.
- **`found_counts`.** Needs two `stopAll` in one tick, or a detection that does not move
  the voted count. Neither with one fault.
- **`T3_ends`.** I tried: a halt from a refused round with the setting at once (the work
  after `correct` must pass: it does); a halt asked under on a click; the pause clause
  with `last` already the state and not; a halt begun at R1 with `quiet := t0`. In all,
  the three places of the book and of `before` are the same whenever the voted book has
  a halt (a book or `before` fault that is not yet settled leaves the game not halted).
- **`T4`, third case.** I looked for a difference that R1 to R17 of the next round do not
  compare and R21 does not write over. `before`, all three the same but wrong, is the
  only stored thing of that kind, and R21 writes it. So the equality after two ticks
  holds, and after one it would not.
- **`Phase.next`, `Spaced`, `ledgerF`.** Every way into `ready` is from a game I could
  show clean: found, ended and recorded in one tick (`T2_at_once`); `landed` then no
  detection (T4's equality); a halt ended and a round recorded (R38 writes `spoiled := 0`,
  and `stops` stays 0). `ready` with no fault stays `ready` without looking at whether
  anything is halted; that is safe only because a clean game never halts with no fault.
  The branches of `Phase.next` for a fault in `landed`, `halting` or `ended` are never
  used under `Spaced`.

### Unknowns I tried to turn against the statements

A fingerprint that is the same for every text (the coordinators then see nothing, but
every part is also seen by an observer that holds the text itself, and the gate compares
exactly); `pauseOver now now = true` (a halt found before R19 then ends in its own round
without work: `Settled`, covered by T2); `readable` false; a `takeDown` that forgets the
list (a changed list becomes the same again: gone); a work that writes over the faulted
part; rules that say yes to everything a fault makes. None gave a counterexample.

### What this does not rule out

A hand reading of 38 instants by 7 kinds of cell, with whole cells changed to anything,
can miss a case. The places I am least able to vouch for are observer faults with
several fields changed at once landing between R11 and R13, and anything that depends
on the exact order inside `lookRing`.

---

## C. Empty reasons, and doc-comments against the Lean

### Empty or nearly empty

- **`stops`.** `Clean` asks `stops = 0` and nothing in the model raises it (A12), so
  every claim about `stops` is true for that reason alone. `T2_at_once` leans on it.
- **`T3`** is trivially true of a game that is not halted; it has content only together
  with the fact that a stuck halt would show at the end of its own round.
- **`stick .stillFound`** cannot be reached in the model after a `restore` that succeeds
  (part B). So for one fault, "not stuck" is "`restore` does not fail" and "R38 does not
  count two".
- **`T3_ends`, pause clause.** `pauseOver` is unknown and may never be true (A5); the
  clause then never applies.
- **`ledger` and `ledgerF`** are not empty, but they are relative: they take the faulted
  run's own recorded rounds, lists, lengths and times as given. They assert what the
  record is, given those; they do not assert that those are right.
- No hypothesis is impossible: `Sound` is met by the toy, `Clean` by a new game, the
  three hypotheses of `T2_at_once` by any fault found before R19 with the setting at
  once, `Spaced` by any run with its faults far enough apart, and the phase `ended` is
  reached by a halt put right on asking under after a pause.

### Doc-comments that say more, or other, than the Lean

- **`Settled`** and **`T2`**: "Everything stored agrees". It agrees with itself. Read
  beside the asked T2 it is easy to take as "agrees with the run with no fault", which
  the Lean does not say.
- **`T2`**: "a halt has begun since the fault" is, in the Lean, a comparison of two
  voted counts. Its list of what `Settled` says leaves out the last field (`canBe`).
  "Each later round that was recorded made of it what the work with no fault makes" is
  the definition of `ledger`, not something asserted of each round; the theorem asserts
  only that the record at the end equals it.
- **`Clean`**: "the last round worked was not refused" is `spoiled = 0`.
- **`T3`**: "no halt that cannot be put right" is "the voted halt is not marked stuck".
- **`T2_at_once`**, **`T4`**, **`found_counts`**: "the fault is found" is "some detection
  halted everything in that round" (`found`, a field the model adds).
- **`Toy.sound`**: "so T1 to T5 hold of it" is not part of the statement.
- **`T6_wrong_recorded`**: "The round is recorded, nothing is halted after it". True,
  but the pair *is* found (R15) and a halt begins and ends inside the round; `correct`
  puts the state "right" to the wrong record. The comment reads as if nothing noticed.
- **`T6_spacing`**: the comment says the first round is refused and everything halts,
  and that the second is worked and refused again. The Lean says three things: not
  stuck after the first, a halt ended in the second, stuck after the second. The rest
  follows but is not stated. "So the spacing of T5 cannot be weakened" is a remark.
- **`T6` heading**: "Three pairs of faults"; the brief asked for a pair in one round.
  `Toy.lean`'s header says "the two faults of T6".
- **`ledgerF`**: "(which is the list as it was taken down)" is a gloss.
- **`Toy.P`**: "in the real game a number added to that list that no moth has changes
  nothing" is a claim about the game, which nothing here checks.
- **`Challenge.lean` header and `T1`**: "at any instant of the tick" means the instants
  the model has. The header says so; T1's own comment does not.

---

## D. The model against the specification

Checked item by item and found to say the same: N3, N4, N5, N6 (`rings`, `coord`,
`moths`, `sees`); V1 to V4 (`vote`, `keep`, and every per-place condition: `stick`,
`putRight`, the write in `mend`); D3, D4, D5, D7 to D13; L2 to L7 (`lookOf`, `lookRing`,
`shaped`), in the order section 5 gives; E1 to E3 (`event`); R1 to R38 (`step`), each
against its row; P1 (`mend`), P2 (`correct`), P3 (`restore`, `restoreParts`), P4
(`restorePart`, all of (a) to (b5)), P5 (`restoreAsks`), P9 (`beginAgain`); F1 to F8
(`Cell`, `Cell.hit`, `Sched`, `Fault`); the 38 instants (`steps` has each step once, in
order; `inject` runs before `step`); `tick` (the things, then the round; `between n`
splits the things at `n`).

Differences, all small. None changes an outcome for one fault.

| Item | Specification | Model |
| --- | --- | --- |
| R1 | "The time given to `stop_all` is the book's `time`", and V1: every reading is voted "at the instant it is made" | `start` reads `t0 := g.book.time` once, before the round, so before a fault that lands immediately before R1 and before R1 settles the books. One changed place does not move the vote, so the value is the same. |
| R18 | the reason is "what the observers found, or 'an observer is silent'" | a third label, `Cause.late i`, when an observer did not answer and no flag is up. A label only (A10). |
| R18 | says nothing of the round's own values | the model empties `running`, `look`, `answers`, `late`, `told`, `stop`, `gateLooks`, `off` after R18. Nothing reads them again. |
| R23, R29 | "what the rules need to know of what was asked" | the whole state after taking in (`asked := g.sp`; `takeIn₂ g.rc (g.asks 1)`). This is A3. |
| R26 | "If one of R26 to R32 refuses, the rest are skipped" | R26 is not guarded by `refused = none`. It is the first, so it need not be. |
| R28, R29 | "If R28 or R29 says no, refuse" | R28 only keeps `ruled1`; the refusing is at R29. Same outcome. |
| D5, D7, L6 | "the empty text", "the empty list" | one value, `blank`, for both. A1 puts them in one type; it does not say they are one value. |
| P2, N7 | new observers are made in the order 6, 3, 0, 1, 2, 4, 5, 7 | all eight at once, and they look in the order 0 to 7. Only whether any found something is used. |
| section 11 | a fault lands "immediately before any one of R1 to R38" | `inject` changes the cell even when the round has already ended (R6, R19); the fault then lands after the round. An answer is replaced only if the round has not ended. From a clean game the round never ends early before the fault. |
| section 11 | "between two rounds (before, between or after the things of section 6)" | `Fault.between n c` for every `n`; `n` past the end is the same as `n` at the end. |
| section 7 | the round keeps values of its own | `Run` also has `recorded`, `found`, `worked`, `ended`, which the program does not have. `found` holds the last detection if there were two. |
| S5, S6 | the book's `at`; the halt's `why` | named `clock`; `why` is a `Cause`. |

One thing that is between the brief and the specification, not between the
specification and the model: the brief's fault model has "one of the three places of
anything kept in three". S9 (the game's hold on its observers' threads, kept in three)
is not in the specification (A7), so a fault there is in no statement.

Section 11's argument that an instant inside a step adds nothing is, as the header of
`Challenge.lean` says, not in the model. For the first fault in a clean game the three
uncut steps (R19, the `restore` in R38, R6) do nothing, so no instant inside them is
lost; for R1 to R4, R11, R12, R14 to R16, R32 and R34 the statements rest on that
argument.

---

## The three kinds, listed apart

### (1) False, or other than what was asked

No statement found false.

Other than, or less than, what was asked:

1. `T2` concludes sameness of the three places of the book, `before` and the lists, not
   their contents. Concrete run in which `before` holds the faulted state after the halt
   has ended: part A, T2, point 2.
2. `T2` compares the record with `ledger`, built from the faulted run, not with the run
   with no fault. Only `T2_at_once` compares with the run with no fault.
3. No statement but `T2_at_once` says the book's `how`, `rest`, `rounds`, `time`, `clock`
   come through a fault to one place of the book, nor that the lists are the voted list
   after a halt that does not end at once.
4. `T5`: one fault a tick (narrower than the asked spacing at R37 and R38 of a recorded
   round); a new fault allowed two ticks after one never found (wider).
5. `T4`: "gone" is after the second tick; "found" is any detection.
6. `T1`: the value R36 writes, in the fault's own tick, and the record only. The
   observers' copies can take a faulted state at R34 in a round that is recorded.
7. `T3`: the mark `stuck`, at the ends of ticks. `T3_ends` starts from the tick after
   the fault.
8. `T6`: on the toy; the first two pairs land before one round; `T6_wrong_recorded`
   depends on the toy's rules; the third is two rounds.
9. Every statement is under `Sound P` (Y1 to Y4, which the specification supports by
   samples) and under section 12's abstractions.
10. The fault model: S9 is in no statement; an instant inside a step is argued, not
    modelled. In the other direction the model's faults are larger than asked (a whole
    cell, any book, any list, any observer).

### (2) Model against specification

The table in part D. The one a reader should know of first: `t0` is read in `start`,
not at R1.

### (3) Wording

The list in part C. First among them: "everything stored agrees" (`Settled`, `T2`)
means agrees with itself; and `T6_spacing`'s comment says more than its three
conjuncts.
