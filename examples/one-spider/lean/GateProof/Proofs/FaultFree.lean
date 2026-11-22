/-
A round with no fault, from a game in which everything agrees, written out: what the
round holds immediately before each of its steps (`ffA` for R1 to R19, `wk` for R20 to
the end), and the proof that each step takes one to the next.
-/
import GateProof.Proofs.Basic

set_option linter.unusedSectionVars false
set_option linter.deprecated false
set_option linter.unusedSimpArgs false

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)

/-- R2. The length of the round. -/
def Inp.dt (inp : Inp Tm Dt) (b : Book V Tm) : Dt :=
  match inp with
  | .clock c => P.len b.clock c
  | .test dt _ => dt

/-- R1. The time given to the first comparing of the books. -/
def Inp.t0 (inp : Inp Tm Dt) (b : Book V Tm) : Tm :=
  match inp with
  | .clock _ => b.time
  | .test _ now => now

/-- R2. The book after the clock has been noted. -/
def Inp.book (inp : Inp Tm Dt) (b : Book V Tm) : Book V Tm :=
  match inp with
  | .clock c => if P.readable c = true then { b with clock := c } else b
  | .test _ now => { b with clock := now }

/-- R2. The time of the round. -/
def Inp.now (inp : Inp Tm Dt) (b : Book V Tm) : Tm :=
  match inp with
  | .clock c => P.adv b.time (P.len b.clock c)
  | .test _ now => now

/-- The book as a round with no fault has it immediately before step `n` (R1 to R19):
after R2 the clock is noted, after R5 the time is set, after R7 the round is numbered. -/
def bookAt (inp : Inp Tm Dt) (b : Book V Tm) (n : Nat) : Book V Tm :=
  if n ≤ 2 then b
  else if n ≤ 5 then Inp.book P inp b
  else if n ≤ 7 then { Inp.book P inp b with time := Inp.now P inp b }
  else { Inp.book P inp b with time := Inp.now P inp b, rounds := b.rounds + 1 }

/-- What the first half of a round with no fault holds immediately before step `n`, for
`n` from 1 to 20, from the clean game with record `T`, lists `A`, book `b`, `before` `β`. -/
def ffA (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V)) (n : Nat) :
    Run V Q Tm Dt :=
  let h₀ := P.inWeb₁ T
  let ob0 : Who → Observer V := fun i => freshOb P i T b.rounds h₀
  { g := { sp := T, ob := fun i => freshOb P i T (if n ≤ 11 then b.rounds else b.rounds + 1) h₀,
           rt := T, rc := T, bk := fun _ => bookAt P inp b n, bf := fun _ => β,
           asks := fun _ => A },
    over := false, t0 := Inp.t0 inp b, dt := Inp.dt P inp b,
    now := if n ≤ 2 then Inp.t0 inp b else Inp.now P inp b,
    beganHalted := false,
    running := fun _ => decide (9 ≤ n ∧ n ≤ 18),
    look := if 10 ≤ n ∧ n ≤ 18 then ⟨b.rounds + 1, b.rounds, T, ob0, T⟩ else noLook P,
    answers := fun _ => if 11 ≤ n ∧ n ≤ 18 then some none else none,
    late := none, told := none, stop := false,
    gateLooks := decide (15 ≤ n ∧ n ≤ 18), off := none,
    held := P.blank, asked := fun _ => P.blank, ruled1 := false, refused := none,
    made := fun _ => P.blank, seen := fun _ => P.blank, heldNow := P.blank, recorded := none,
    found := none, worked := false, ended := false }

/-- What the second half of a round holds immediately before step `n`, for `n` from 20 to
39 (39 is the end), when it comes to its work with everything agreeing: record `T`,
lists `A`, book `bb`, `before` `β`. `bh`, `fnd` and `ended` are what the first half left:
whether the round began halted, what it found, whether it ended a halt. -/
def wk (T : St V) (A : Q) (bb : Book V Tm) (β : Option (St V)) (t0 : Tm) (dt : Dt) (now : Tm)
    (bh : Bool) (fnd : Option Cause) (ended : Bool) (n : Nat) : Run V Q Tm Dt :=
  let h₀ := P.inWeb₁ T
  let tk := P.takeIn₁ T A
  let wd := P.world₁ tk h₀ dt now
  let S' := P.spider₁ wd dt now
  { g := { sp := if n ≤ 22 then T else if n ≤ 24 then tk else if n ≤ 25 then wd else S',
           ob := fun i => freshOb P i (if n ≤ 34 then T else S') bb.rounds
                            (if n ≤ 35 then h₀ else P.inWeb₁ S'),
           rt := if n ≤ 36 then T else S', rc := if n ≤ 36 then T else S',
           bk := fun _ => if n ≤ 38 then bb
                          else { bb with spoiled := 0, stops := if bh = true then bb.stops else 0 },
           bf := fun _ => if n ≤ 21 then β else some T,
           asks := fun _ => if n ≤ 37 then A else P.noAsks },
    over := false, t0 := t0, dt := dt, now := now, beganHalted := bh,
    running := fun _ => false, look := noLook P, answers := fun _ => none,
    late := none, told := none, stop := false, gateLooks := false, off := none,
    held := if n ≤ 20 then P.blank else h₀,
    asked := if n ≤ 23 then fun _ => P.blank else tk,
    ruled1 := decide (29 ≤ n), refused := none,
    made := if n ≤ 30 then fun _ => P.blank else S',
    seen := if n ≤ 33 then fun _ => P.blank else S',
    heldNow := if n ≤ 33 then P.blank else P.inWeb₁ S',
    recorded := if n ≤ 36 then none else some S',
    found := fnd, worked := decide (22 ≤ n), ended := ended }

/-- The number of a step: R1 is 1. -/
def Step.num : Step → Nat
  | .settle1 => 1 | .note => 2 | .settle2 => 3 | .settleBefore => 4 | .setTime => 5
  | .stuckCheck => 6 | .number => 7 | .running => 8 | .look => 9 | .answers => 10
  | .signals => 11 | .spread => 12 | .respond => 13 | .selfCheck => 14 | .stateCheck => 15
  | .obsCheck => 16 | .asksCheck => 17 | .decide => 18 | .mend => 19 | .readHeld => 20
  | .keepBefore => 21 | .takeIn => 22 | .account => 23 | .world => 24 | .spider => 25
  | .unfit => 26 | .copyRules => 27 | .rules1 => 28 | .rules2 => 29 | .redo => 30
  | .compare => 31 | .obsAgain => 32 | .see => 33 | .takeCopies => 34 | .takeHeld => 35
  | .writeRecord => 36 | .emptyAsks => 37 | .close => 38

set_option maxHeartbeats 2000000 in
theorem ffA_step (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V))
    (hb : b.halt = none) (s : Step) (hs : s.num ≤ 19) :
    step P inp s (ffA P inp T A b β s.num) = ffA P inp T A b β (s.num + 1) := by
  cases s <;> simp [Step.num] at hs <;> rcases inp with c | ⟨dt, now⟩ <;>
    first
    | (by_cases hr : P.readable c = true <;>
        simp [ffA, step, bookAt, Step.num, settleBooks, Gate.settleBefore, keep, Game.book, vote_const, hb,
          Game.halted, lookOf_clean', obsOff_clean', sound, flagging, freshOb, Inp.t0, Inp.dt, Inp.book, Inp.now, allWho, allParts,
          selfCheck, stateCheck, asksCheck, List.findSome?, List.find?, List.any, hr])
    | simp [ffA, step, bookAt, Step.num, settleBooks, Gate.settleBefore, keep, Game.book, vote_const, hb,
        Game.halted, lookOf_clean', obsOff_clean', sound, flagging, freshOb, Inp.t0, Inp.dt, Inp.book, Inp.now, allWho, allParts,
        selfCheck, stateCheck, asksCheck, List.findSome?, List.find?, List.any]
set_option maxHeartbeats 2000000 in
theorem wk_step (hP : Sound P) (inp : Inp Tm Dt) (T : St V) (A : Q) (bb : Book V Tm) (β : Option (St V))
    (t0 : Tm) (dt : Dt) (now : Tm) (bh : Bool) (fnd : Option Cause) (ended : Bool)
    (hb : bb.halt = none) (hc1 : P.canBe₁ T = true) (hc2 : P.canBe₂ T = true)
    (s : Step) (hs : 20 ≤ s.num) :
    step P inp s (wk P T A bb β t0 dt now bh fnd ended s.num)
      = wk P T A bb β t0 dt now bh fnd ended (s.num + 1) := by
  obtain ⟨h1, h2, h3, h4, h5⟩ := hP.work_passes T A dt now hc1 hc2
  have hw := hP.work_same
  have hi := hP.inWeb_same
  simp only [Params.work, hi] at h1 h2 h3 h4 h5
  cases s <;> simp [Step.num] at hs <;>
    simp [wk, step, Step.num, keep, Game.book, vote_const, hb, Game.halted, sound, freshOb,
      obsOff_clean', Params.redo, hw, hi, h1, h2, h3, h4, h5, hc1, hc2]
  funext i
  by_cases hi5 : i = moths <;> simp [hi5]


/-! ### The steps by number -/

/-- The step with a given number: `stepOf 1` is R1. -/
def stepOf : Nat → Step
  | 1 => .settle1 | 2 => .note | 3 => .settle2 | 4 => .settleBefore | 5 => .setTime
  | 6 => .stuckCheck | 7 => .number | 8 => .running | 9 => .look | 10 => .answers
  | 11 => .signals | 12 => .spread | 13 => .respond | 14 => .selfCheck | 15 => .stateCheck
  | 16 => .obsCheck | 17 => .asksCheck | 18 => .decide | 19 => .mend | 20 => .readHeld
  | 21 => .keepBefore | 22 => .takeIn | 23 => .account | 24 => .world | 25 => .spider
  | 26 => .unfit | 27 => .copyRules | 28 => .rules1 | 29 => .rules2 | 30 => .redo
  | 31 => .compare | 32 => .obsAgain | 33 => .see | 34 => .takeCopies | 35 => .takeHeld
  | 36 => .writeRecord | 37 => .emptyAsks | _ => .close

theorem stepOf_num (s : Step) : stepOf s.num = s := by cases s <;> rfl

theorem num_stepOf (n : Nat) (h1 : 1 ≤ n) (h2 : n ≤ 38) : (stepOf n).num = n := by
  have : ∀ m : Fin 39, 1 ≤ m.val → (stepOf m.val).num = m.val := by decide
  exact this ⟨n, by omega⟩ h1

theorem num_pos (s : Step) : 1 ≤ s.num ∧ s.num ≤ 38 := by cases s <;> simp [Step.num]

/-- The `k` steps from number `n` on. -/
def seg (n k : Nat) : List Step := (List.range' n k).map stepOf

theorem steps_seg : steps = seg 1 38 := by decide

theorem seg_zero (n : Nat) : seg n 0 = [] := rfl

theorem seg_succ (n k : Nat) : seg n (k + 1) = stepOf n :: seg (n + 1) k := by
  simp [seg, List.range'_succ]

theorem seg_add (n j k : Nat) : seg n (j + k) = seg n j ++ seg (n + j) k := by
  induction j generalizing n with
  | zero => simp [seg]
  | succ j ih =>
    rw [show j + 1 + k = (j + k) + 1 by omega, seg_succ, seg_succ, ih (n + 1)]
    simp [show n + 1 + j = n + (j + 1) by omega]

theorem run_append (inp : Inp Tm Dt) (sch : Sched V Q Tm) (l₁ l₂ : List Step) (r : Run V Q Tm Dt) :
    run P inp sch (l₁ ++ l₂) r = run P inp sch l₂ (run P inp sch l₁ r) := by
  induction l₁ generalizing r with
  | nil => rfl
  | cons s l ih => simp [run, ih]

/-- A stretch of the first half of a round with no fault. -/
theorem run_ffA (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V))
    (hb : b.halt = none) (k n : Nat) (h1 : 1 ≤ n) (h2 : n + k ≤ 20) :
    run P inp .none (seg n k) (ffA P inp T A b β n) = ffA P inp T A b β (n + k) := by
  induction k generalizing n with
  | zero => rfl
  | succ k ih =>
    rw [seg_succ]
    simp only [run, inject]
    have := ffA_step P inp T A b β hb (stepOf n) (by rw [num_stepOf n h1 (by omega)]; omega)
    rw [num_stepOf n h1 (by omega)] at this
    rw [this, ih (n + 1) (by omega) (by omega)]
    congr 1; omega

/-- A stretch of the second half of a round with no fault. -/
theorem run_wk (hP : Sound P) (inp : Inp Tm Dt) (T : St V) (A : Q) (bb : Book V Tm)
    (β : Option (St V)) (t0 : Tm) (dt : Dt) (now : Tm) (bh : Bool) (fnd : Option Cause)
    (ended : Bool) (hb : bb.halt = none) (hc1 : P.canBe₁ T = true) (hc2 : P.canBe₂ T = true)
    (k n : Nat) (h1 : 20 ≤ n) (h2 : n + k ≤ 39) :
    run P inp .none (seg n k) (wk P T A bb β t0 dt now bh fnd ended n)
      = wk P T A bb β t0 dt now bh fnd ended (n + k) := by
  induction k generalizing n with
  | zero => rfl
  | succ k ih =>
    rw [seg_succ]
    simp only [run, inject]
    have := wk_step P hP inp T A bb β t0 dt now bh fnd ended hb hc1 hc2 (stepOf n)
      (by rw [num_stepOf n (by omega) (by omega)]; omega)
    rw [num_stepOf n (by omega) (by omega)] at this
    rw [this, ih (n + 1) (by omega) (by omega)]
    congr 1; omega

/-- Where the first half hands over to the second. -/
theorem ffA_20 (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V)) :
    ffA P inp T A b β 20
      = wk P T A (bookAt P inp b 20) β (Inp.t0 inp b) (Inp.dt P inp b) (Inp.now P inp b)
          false none false 20 := by
  simp [ffA, wk, bookAt]

theorem start_clean (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V)) :
    start P inp (cleanG P T A b β) = ffA P inp T A b β 1 := by
  cases inp <;> simp [start, ffA, cleanG, bookAt, Inp.t0, Inp.dt, Game.book, vote_const]

/-- A whole round with no fault, from a game in which everything agrees. -/
theorem round_clean (hP : Sound P) (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm)
    (β : Option (St V)) (hb : b.halt = none) (hc1 : P.canBe₁ T = true) (hc2 : P.canBe₂ T = true) :
    round P inp .none (cleanG P T A b β)
      = wk P T A (bookAt P inp b 20) β (Inp.t0 inp b) (Inp.dt P inp b) (Inp.now P inp b)
          false none false 39 := by
  have hbb : (bookAt P inp b 20).halt = none := by
    cases inp <;> simp [bookAt, Inp.book, hb]
    split <;> simp [hb]
  rw [round, start_clean, steps_seg, show (38 : Nat) = 19 + 19 by rfl, seg_add, run_append,
    run_ffA P inp T A b β hb 19 1 (by omega) (by omega), ffA_20,
    run_wk P hP inp T A _ β _ _ _ false none false hbb hc1 hc2 19 20 (by omega) (by omega)]

end
end Gate
