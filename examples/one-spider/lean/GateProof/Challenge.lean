/-
The statements to be proved, with their proofs left out. This file, `Model.lean`,
`Claims.lean` and `Toy.lean` are what a reader has to check against `protocol-spec.md`
and the fault model.

Throughout: `P` is the unknowns, and `Sound P` is what is assumed of them (Y1 to Y4).
`g` is everything stored. `tick P es inp f g` is: what happens between two rounds (`es`),
then one round given `inp`, with the one fault `f` if there is one. A fault `f` is one
cell changed to any value, or one observer's answer replaced (section 11 of the
specification). Its instant is one of: immediately before any one of the 38 steps of the
round; before, between or after the things that happen between the rounds; or, for an
answer, between R10 and R11. An instant part of the way through a step is not in the
model: section 11 of the specification argues that it adds nothing.
-/
import GateProof.Claims
import GateProof.Toy

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)

/-! ### What the theorems start from -/

/-- Every state the program can reach with no fault is clean: everything stored agrees,
nothing is halted, the count of rounds refused running is nought, and the count of stops
is nought. The theorems below are stated for clean states, which are these and more. -/
theorem reach_clean (hP : Sound P) {g : Game V Q Tm} (h : Reach P g) : Clean P g := by
  sorry

/-- A round with no fault, from a clean state, is recorded; what it records is what the
work with no fault makes of the record and the voted list of what was asked; nothing is
found; and the state it leaves is clean, with what was recorded as its record. -/
theorem nofault_round (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) :
    let r := tick P es inp none g
    r.recorded = some (P.work g.rt (vote (events P es g).asks) r.dt r.now)
      ∧ r.found = none ∧ Clean P r.g ∧ r.recorded = some r.g.rt := by
  sorry

/-! ### T1. Nothing wrong is recorded -/

/-- T1. From a clean state, with any one fault at any instant of the tick: the round is
either not recorded, or what it writes to the record (at R36) is what the same round
with no fault writes. -/
theorem T1 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) :
    (tick P es inp (some f) g).recorded = none
      ∨ (tick P es inp (some f) g).recorded = (tick P es inp none g).recorded := by
  sorry

/-! ### T2. Put right -/

/-- T2. From a clean state, one fault in one tick, and then any number of ticks with no
new fault. Whenever, after that, nothing is halted and a halt has begun since the fault
(the voted count of halts is more than it was): everything stored agrees (`Settled`: the
state is the record, the record's two halves are the same, every observer is as a new
one made from the record would be, the three books are the same and hold no halt, the
three places of `before` are the same, the three lists are the same). And the record is
what `ledger` says: starting from the record the same tick with no fault leaves (if the
tick of the fault was recorded) or the record from before it (if not), each later round
that was recorded made of it what the work with no fault makes, and each round that was
not recorded left it alone. -/
theorem T2 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) (ts : List (Tick E Tm Dt)) :
    let r₀ := tick P es inp (some f) g
    let T₀ := if r₀.recorded.isSome then (tick P es inp none g).g.rt else g.rt
    let gₙ := play P ts r₀.g
    gₙ.halted = false → g.book.halts < gₙ.book.halts →
      Settled P gₙ ∧ gₙ.rt = ledger P ts T₀ r₀.g := by
  sorry

/-- T2, at once. If, in the tick of the fault, the fault is found, a halt is ended and
the round's work is begun, then at the end of that tick the state, the observers, both
halves of the record, the three places of `before` and the three lists are what they are
in the same tick with no fault, and each of the three books is what it is there but for
the counts of halts and of restarts, which are one more. -/
theorem T2_at_once (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) :
    let r := tick P es inp (some f) g
    let r' := tick P es inp none g
    r.found.isSome = true → r.ended = true → r.worked = true →
      r.g.sp = r'.g.sp ∧ r.g.ob = r'.g.ob ∧ r.g.rt = r'.g.rt ∧ r.g.rc = r'.g.rc
        ∧ r.g.bf = r'.g.bf ∧ r.g.asks = r'.g.asks
        ∧ ∀ k, r.g.bk k = { r'.g.bk k with halts := (r'.g.bk k).halts + 1,
                                           restarts := (r'.g.bk k).restarts + 1 } := by
  sorry

/-- The voted count of halts goes up by one in the tick of the fault exactly when the
fault is found in it (`found`: a detection halted everything in that round). -/
theorem found_counts (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) :
    let r := tick P es inp (some f) g
    r.g.book.halts = g.book.halts + (if r.found.isSome then 1 else 0) := by
  sorry

/-! ### T3. Never stuck -/

/-- T3. From a clean state, one fault in one tick, and then any number of ticks with no
new fault: at the end of every tick, there is no halt that cannot be put right. -/
theorem T3 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) (ts : List (Tick E Tm Dt)) :
    (play P ts (tick P es inp (some f) g).g).stuck = false := by
  sorry

/-- T3, and the halt does end. In such a run, take any later tick that comes to its
round halted. If halts are set to end at once, or the halt has been asked to end, or
halts end after a pause and the pause is over in that round (counted from `quiet` if
the state is as the halt last saw it, and from now if not), then after that tick nothing
is halted. -/
theorem T3_ends (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) (ts : List (Tick E Tm Dt))
    (t : Tick E Tm Dt) :
    let g' := events P t.es (play P ts (tick P es inp (some f) g).g)
    let r := round P t.inp .none g'
    ∀ h, g'.book.halt = some h →
      (g'.book.how = How.atOnce ∨ h.asked = true
        ∨ (g'.book.how = How.afterAPause
            ∧ P.pauseOver (if h.last = some g'.sp then h.quiet else r.now) r.now = true)) →
      r.g.halted = false := by
  sorry

/-! ### T4. Found, or gone -/

/-- T4. From a clean state, one fault in one tick, and one more tick with no new fault.
Either a detection halts everything in the tick the fault lands in or in the next. Or
the fault is gone: after the second tick everything stored is exactly what it is in the
run with no fault, and both rounds wrote to the record exactly what they write with no
fault. -/
theorem T4 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) (t : Tick E Tm Dt) :
    let r₀ := tick P es inp (some f) g
    let r₁ := tick P t.es t.inp none r₀.g
    let r₀' := tick P es inp none g
    let r₁' := tick P t.es t.inp none r₀'.g
    r₀.found.isSome = true ∨ r₁.found.isSome = true
      ∨ (r₁.g = r₁'.g ∧ r₀.recorded = r₀'.recorded ∧ r₁.recorded = r₁'.recorded) := by
  sorry

/-! ### T5. One after another -/

/-- T5. From a clean state, any run of ticks with faults that keeps the spacing (a fault
lands only when none is outstanding: `Spaced`, `Phase`). At its end there is no halt that
cannot be put right. If no fault is outstanding at its end (`ready`), the state is clean.
If a halt has ended and no round has been recorded since (`ended`), everything stored
agrees. In both cases the record is what the recorded rounds make, by the work with no
fault, of the record the run began with (`ledgerF`). -/
theorem T5 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (ts : List (FTick V Q E Tm Dt)) (hs : Spaced P ts Phase.ready g) :
    let end_ := playF P ts Phase.ready g
    end_.2.stuck = false
      ∧ (end_.1 = Phase.ready → Clean P end_.2 ∧ end_.2.rt = ledgerF P ts g.rt g)
      ∧ (end_.1 = Phase.ended → Settled P end_.2 ∧ end_.2.rt = ledgerF P ts g.rt g) := by
  sorry

end

/-! ### T6. The edge is where it is said to be

Three pairs of faults on the toy game of `Toy.lean` (which meets Y1 to Y4: `Toy.sound`),
set to end halts at once, after three rounds with no fault. -/

namespace Toy

/-- The toy game meets what is assumed of the unknowns (Y1 to Y4). -/
theorem sound : Sound P := by
  sorry

/-- T6, first pair: both halves of the record of one part changed to the same value,
before one round (both before R1). At the end of the round nothing is halted, the round
was recorded, and what was recorded is not what the round with no fault records. (In
between, the gate finds that the state is not the record, and the halt ends at once with
the state put back to the changed record: the statement does not say this.) -/
theorem T6_wrong_recorded :
    let twoFaults := (Cell.rc 4 99).hit ((Cell.rt 4 99).hit base)
    let r := round P (.clock 4) .none twoFaults
    let r' := round P (.clock 4) .none base
    r.g.halted = false ∧ r.recorded.isSome = true ∧ r.recorded ≠ r'.recorded := by
  sorry

/-- T6, second pair: the two halves of the record of one part changed to two different
values, before one round. The halt that follows cannot be put right. -/
theorem T6_stuck :
    let twoFaults := (Cell.rc 4 99).hit ((Cell.rt 4 98).hit base)
    (round P (.clock 4) .none twoFaults).g.stuck = true := by
  sorry

/-- T6, third pair: the same fault (the record's copy of one part, immediately before
R24) in two rounds running. After the first round there is no halt that cannot be put
right. In the second a halt is ended, and after it there is a halt that cannot be put
right. So the spacing of T5 cannot be weakened to "the halt has ended". -/
theorem T6_spacing :
    let r₁ := round P (.clock 4) (.cell .world (.rc 4 99)) base
    let r₂ := round P (.clock 5) (.cell .world (.rc 4 99)) r₁.g
    r₁.g.stuck = false ∧ r₂.ended = true ∧ r₂.g.stuck = true := by
  sorry

end Toy

end Gate
