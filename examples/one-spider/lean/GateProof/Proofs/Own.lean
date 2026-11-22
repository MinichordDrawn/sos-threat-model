/-
One fault in one round, continued: a fault in one of the three books, or in one of the
three places of `before`.
-/
import GateProof.Proofs.Post

set_option linter.unusedSectionVars false
set_option linter.deprecated false
set_option linter.unusedSimpArgs false
set_option linter.unusedVariables false

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)
variable (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V))

/-- Evaluating R1 to R19 on the written-out round, where the gate's own comparing halts
everything. -/
macro "ffd" : tactic => `(tactic|
  simp [seg, List.range', run, inject, step, stepOf, ffX, ffA, hitR, Cell.hit, bookAt, settleBooks,
    Gate.settleBefore, Run.detect, stopAll, keep, Game.book, vote_const, vote_hit, Game.halted,
    lookOf_clean', obsOff_clean', sound, flagging, freshOb, Inp.t0, Inp.dt, Inp.book, Inp.now,
    Inp.ck, allWho, allParts, selfCheck, stateCheck, asksCheck, List.findSome?, List.find?,
    List.any, idle, cleanG, haltBook, *])

set_option maxHeartbeats 40000000 in
/-- F5 before R1: a book that differs is found by R1. -/
theorem bk_detect1 (hb : b.halt = none) (k : Fin 3) (x : Book V Tm) (hx : x ≠ b) :
    run P inp .none (seg 1 18) (hitR (.bk k x) (ffX P inp T A b β 1))
      = idle P (cleanG P T A (haltBook P inp b .books (Inp.t0 inp b)) β) (Inp.t0 inp b)
          (Inp.dt P inp b) (Inp.now P inp b) true (some .books) false := by
  have hx' : ¬ b = x := fun h => hx h.symm
  rcases fin3 k with e | e | e <;> subst e <;> rcases inp with c | ⟨dt, now⟩ <;>
    first
    | (by_cases hr : P.readable c = true <;> ffd)
    | ffd

set_option maxHeartbeats 40000000 in
/-- F5 before R3: a book that differs is found by R3. -/
theorem bk_detect3 (hb : b.halt = none) (k : Fin 3) (x : Book V Tm)
    (hx : x ≠ Inp.book P inp b) :
    run P inp .none (seg 3 16) (hitR (.bk k x) (ffX P inp T A b β 3))
      = idle P (cleanG P T A (haltBook P inp b .books (Inp.now P inp b)) β) (Inp.t0 inp b)
          (Inp.dt P inp b) (Inp.now P inp b) true (some .books) false := by
  have hx' : ¬ Inp.book P inp b = x := fun h => hx h.symm
  rcases fin3 k with e | e | e <;> subst e <;> rcases inp with c | ⟨dt, now⟩ <;>
    first
    | (by_cases hr : P.readable c = true <;> simp [Inp.book, hr, hb] at hx hx' <;> ffd)
    | (simp [Inp.book, hb] at hx hx' <;> ffd)

theorem keep_const (f : Book V Tm → Book V Tm) (sp : St V) (ob : Who → Observer V) (rt rc : St V)
    (B : Book V Tm) (bf : Fin 3 → Option (St V)) (asks : Fin 3 → Q) :
    keep f ⟨sp, ob, rt, rc, fun _ => B, bf, asks⟩ = ⟨sp, ob, rt, rc, fun _ => f B, bf, asks⟩ := rfl

theorem keep_hit (f : Book V Tm → Book V Tm) (sp : St V) (ob : Who → Observer V) (rt rc : St V)
    (k : Fin 3) (x B : Book V Tm) (bf : Fin 3 → Option (St V)) (asks : Fin 3 → Q) :
    keep f ⟨sp, ob, rt, rc, fun j => if j = k then x else B, bf, asks⟩
      = ⟨sp, ob, rt, rc, fun j => if j = k then f x else f B, bf, asks⟩ := by
  simp only [keep]
  congr 1
  funext j; split <;> rfl

set_option maxHeartbeats 40000000 in
/-- F5 before R2: the clock is noted in the changed place as in the others. -/
theorem bk_note (hb : b.halt = none) (k : Fin 3) (x : Book V Tm) :
    step P inp (stepOf 2) (hitR (.bk k x) (ffX P inp T A b β 2))
      = hitR (.bk k (Inp.book P inp x)) (ffX P inp T A b β 3) := by
  rcases inp with c | ⟨dt, now⟩
  · by_cases hr : P.readable c = true <;>
      simp [step, stepOf, ffX, ffA, hitR, Cell.hit, bookAt, keep_hit, Game.book, vote_const,
        vote_hit, Inp.t0, Inp.dt, Inp.book, Inp.now, hr]
  · simp [step, stepOf, ffX, ffA, hitR, Cell.hit, bookAt, keep_hit, Game.book, vote_const,
      vote_hit, Inp.t0, Inp.dt, Inp.book, Inp.now]

/-- `obsOff_clean'`, with one book changed. -/
theorem obsOff_hit' (sp T : St V) (ρ : Nat) (k : Fin 3) (x B : Book V Tm)
    (bf : Fin 3 → Option (St V)) (asks : Fin 3 → Q) (h : B.rounds = ρ) :
    obsOff P ⟨sp, fun j => ⟨j.val, true, ρ, copiesFor P j T,
      if j = moths then P.inWeb₁ T else P.blank, false, none⟩, T, T,
      fun j => if j = k then x else B, bf, asks⟩ = none := by
  apply obsOff_fresh
  intro i
  simp [born, heldOf, Game.book, vote_hit, h]

/-- How a round with no fault changes one place of the book at step `n` (4 to 38). -/
def bkStep (n : Nat) (x : Book V Tm) : Book V Tm :=
  if n = 5 then { x with time := Inp.now P inp b }
  else if n = 7 then { x with rounds := x.rounds + 1 }
  else if n = 38 then { x with spoiled := 0, stops := 0 }
  else x

set_option maxHeartbeats 40000000 in
/-- F5 from R4 on: nothing compares the books again in this round. What is read is what
two places agree on, and each write is made to the changed place as to the others. -/
theorem bk_slide (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (k : Fin 3) (x : Book V Tm) (n : Nat) (h1 : 4 ≤ n) (h2 : n ≤ 38) :
    step P inp (stepOf n) (hitR (.bk k x) (ffX P inp T A b β n))
      = hitR (.bk k (bkStep P inp b n x)) (ffX P inp T A b β (n + 1)) := by
  obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes T A (Inp.dt P inp b) (Inp.now P inp b) hc1 hc2
  have hw := hP.work_same
  have hi := hP.inWeb_same
  simp only [Params.work, hi] at w1 w2 w3 w4 w5
  have hbh : (Inp.book P inp b).halt = none := by rw [book_halt, hb]
  have hn : n = 4 ∨ n = 5 ∨ n = 6 ∨ n = 7 ∨ n = 8 ∨ n = 9 ∨ n = 10 ∨ n = 11 ∨ n = 12 ∨ n = 13
      ∨ n = 14 ∨ n = 15 ∨ n = 16 ∨ n = 17 ∨ n = 18 ∨ n = 19 ∨ n = 20 ∨ n = 21 ∨ n = 22 ∨ n = 23
      ∨ n = 24 ∨ n = 25 ∨ n = 26 ∨ n = 27 ∨ n = 28 ∨ n = 29 ∨ n = 30 ∨ n = 31 ∨ n = 32 ∨ n = 33
      ∨ n = 34 ∨ n = 35 ∨ n = 36 ∨ n = 37 ∨ n = 38 := by omega
  rcases hn with e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e <;>
    subst e <;>
    simp [bkStep, seg, List.range', run, inject, step, stepOf, ffX, ffW, ffA, wk, hitR, Cell.hit,
      bookAt_late, bookAt, book_eq, Gate.settleBefore, keep, Game.book, vote_const, vote_hit,
      Game.halted,
      lookOf_clean', obsOff_clean', obsOff_hit', sound, flagging, freshOb, allWho, allParts,
      selfCheck, stateCheck, asksCheck, List.findSome?, List.find?, List.any, Params.redo,
      Params.work, *] <;>
    (try (funext j; by_cases hj : j = k <;> simp [hj])) <;>
    (try (funext i; by_cases hi5 : i = moths <;> simp [hi5]))

/-- F5 from R4 on: the round ends as the round with no fault does, with one book
changed. -/
theorem bk_latent (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (k : Fin 3) (d m : Nat) (h1 : 4 ≤ m) (h2 : m + d = 39)
    (x : Book V Tm) :
    ∃ y, run P inp .none (seg m (39 - m)) (hitR (.bk k x) (ffX P inp T A b β m))
      = hitR (.bk k y) (ffX P inp T A b β 39) := by
  induction d generalizing m x with
  | zero =>
    have : m = 39 := by omega
    subst this
    exact ⟨x, rfl⟩
  | succ d ih =>
    rw [show 39 - m = (38 - m) + 1 by omega, seg_succ]
    simp only [run, inject]
    rw [bk_slide P inp T A b β hP hb hc1 hc2 k x m h1 (by omega),
      show 38 - m = 39 - (m + 1) by omega]
    exact ih (m + 1) (by omega) (by omega) _

/-- A fault that changes nothing is no fault. -/
theorem out_trivial (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (c : Cell V Q Tm) (m : Nat) (h1 : 1 ≤ m) (h2 : m ≤ 38)
    (h : c.hit (ffX P inp T A b β m).g = (ffX P inp T A b β m).g) :
    run P inp .none (seg m (39 - m)) (hitR c (ffX P inp T A b β m)) = ffW P inp T A b β 39 := by
  have : hitR c (ffX P inp T A b β m) = ffX P inp T A b β m := by
    simp only [hitR, h]
  rw [this, run_ffX P inp T A b β hP hb hc1 hc2 (39 - m) m h1 (by omega),
    show m + (39 - m) = 39 by omega]
  exact ffX_ge20 P inp T A b β 39 (by omega)

theorem hit_bk_same (g : Game V Q Tm) (k : Fin 3) (x : Book V Tm) (h : g.bk k = x) :
    (Cell.bk k x).hit g = g := by
  cases g
  simp only [Cell.hit]
  congr 1
  funext j; by_cases hj : j = k <;> simp [hj]
  subst hj; exact h.symm

theorem hit_bf_same (g : Game V Q Tm) (k : Fin 3) (x : Option (St V)) (h : g.bf k = x) :
    (Cell.bf k x).hit g = g := by
  cases g
  simp only [Cell.hit]
  congr 1
  funext j; by_cases hj : j = k <;> simp [hj]
  subst hj; exact h.symm

/-- F5 at R1, R2 or R3: nothing has changed at all, or the fault is found. -/
theorem bk_early (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (k : Fin 3) (x : Book V Tm)
    (m : Nat) (h1 : 1 ≤ m) (h2 : m ≤ 3) :
    run P inp .none (seg m (39 - m)) (hitR (.bk k x) (ffX P inp T A b β m)) = ffW P inp T A b β 39
    ∨ Found P inp T A b β
        (run P inp .none (seg m (39 - m)) (hitR (.bk k x) (ffX P inp T A b β m))) := by
  have k3 : ∀ x : Book V Tm,
      run P inp .none (seg 3 (39 - 3)) (hitR (.bk k x) (ffX P inp T A b β 3))
          = ffW P inp T A b β 39
      ∨ Found P inp T A b β
          (run P inp .none (seg 3 (39 - 3)) (hitR (.bk k x) (ffX P inp T A b β 3))) := by
    intro x
    by_cases hx : x = Inp.book P inp b
    · left
      exact out_trivial P inp T A b β hP hb hc1 hc2 _ 3 (by omega) (by omega)
        (hit_bk_same _ k x (by simp [ffX, ffA, bookAt, hx]))
    · right
      rw [show 39 - 3 = 16 + 20 by rfl, seg_add, run_append, bk_detect3 P inp T A b β hb k x hx]
      exact found_of_halted P inp T A b β hP hb hc1 hc2 hsp hst rfl rfl
        (rec_clean P T rfl rfl ⟨rfl, rfl⟩ (Or.inl rfl)) (vote_const A)
  have hm : m = 1 ∨ m = 2 ∨ m = 3 := by omega
  rcases hm with h | h | h <;> subst h
  · by_cases hx : x = b
    · left
      exact out_trivial P inp T A b β hP hb hc1 hc2 _ 1 (by omega) (by omega)
        (hit_bk_same _ k x (by simp [ffX, ffA, bookAt, hx]))
    · right
      rw [show 39 - 1 = 18 + 20 by rfl, seg_add, run_append, bk_detect1 P inp T A b β hb k x hx]
      exact found_of_halted P inp T A b β hP hb hc1 hc2 hsp hst rfl rfl
        (rec_clean P T rfl rfl ⟨rfl, rfl⟩ (Or.inl rfl)) (vote_const A)
  · have e : run P inp .none (seg 2 (39 - 2)) (hitR (.bk k x) (ffX P inp T A b β 2))
        = run P inp .none (seg 3 (39 - 3)) (hitR (.bk k (Inp.book P inp x)) (ffX P inp T A b β 3)) := by
      rw [show 39 - 2 = 36 + 1 by rfl, seg_succ]
      simp only [run, inject]
      rw [bk_note P inp T A b β hb k x]
    rw [e]
    exact k3 _
  · exact k3 x

theorem bk_out (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (k : Fin 3) (x : Book V Tm)
    (m : Nat) (h1 : 1 ≤ m) (h2 : m ≤ 38) :
    Out P inp T A b β (run P inp .none (seg m (39 - m)) (hitR (.bk k x) (ffX P inp T A b β m))) := by
  by_cases c1 : m ≤ 3
  · rcases bk_early P inp T A b β hP hb hc1 hc2 hsp hst k x m h1 c1 with e | f
    · exact out_same P inp T A b β _ e
    · exact Out.found f
  · obtain ⟨y, e⟩ := bk_latent P inp T A b β hP hb hc1 hc2 k (39 - m) m (by omega) (by omega) x
    rw [e]
    exact out_latent P inp T A b β _

/-! ### One of the three places of `before` -/

set_option maxHeartbeats 40000000 in
/-- F6 before R4: R1 to R3 do not touch `before`. -/
theorem bf_slide_early (hb : b.halt = none) (k : Fin 3) (x : Option (St V)) (n : Nat)
    (h1 : 1 ≤ n) (h2 : n ≤ 3) :
    step P inp (stepOf n) (hitR (.bf k x) (ffX P inp T A b β n))
      = hitR (.bf k x) (ffX P inp T A b β (n + 1)) := by
  have hn : n = 1 ∨ n = 2 ∨ n = 3 := by omega
  rcases hn with h | h | h <;> subst h <;> rcases inp with c | ⟨dt, now⟩ <;>
    first
    | (by_cases hr : P.readable c = true <;> ffd)
    | ffd

set_option maxHeartbeats 40000000 in
/-- F6 before R4: a place that differs is found by R4. -/
theorem bf_detect4 (hb : b.halt = none) (k : Fin 3) (x : Option (St V)) (hx : x ≠ β) :
    run P inp .none (seg 4 15) (hitR (.bf k x) (ffX P inp T A b β 4))
      = idle P (cleanG P T A (haltBook P inp b .before (Inp.now P inp b)) β) (Inp.t0 inp b)
          (Inp.dt P inp b) (Inp.now P inp b) true (some .before) false := by
  have hx2 : ¬ β = x := fun h => hx h.symm
  rcases fin3 k with e | e | e <;> subst e <;> rcases inp with c | ⟨dt, now⟩ <;>
    first
    | (by_cases hr : P.readable c = true <;> ffd)
    | ffd

set_option maxHeartbeats 40000000 in
/-- F6 from R5 to R15: nothing reads `before`. -/
theorem bf_slide_mid (hb : b.halt = none) (k : Fin 3) (x : Option (St V)) (n : Nat)
    (h1 : 5 ≤ n) (h2 : n ≤ 15) :
    step P inp (stepOf n) (hitR (.bf k x) (ffX P inp T A b β n))
      = hitR (.bf k x) (ffX P inp T A b β (n + 1)) := by
  have hbh : (Inp.book P inp b).halt = none := by rw [book_halt, hb]
  have hn : n = 5 ∨ n = 6 ∨ n = 7 ∨ n = 8 ∨ n = 9 ∨ n = 10 ∨ n = 11 ∨ n = 12 ∨ n = 13 ∨ n = 14
      ∨ n = 15 := by omega
  rcases hn with e|e|e|e|e|e|e|e|e|e|e <;> subst e <;>
    simp [seg, List.range', run, inject, step, stepOf, ffX, ffA, hitR, Cell.hit, bookAt_late,
      bookAt, book_eq, keep, Game.book, vote_const, Game.halted, lookOf_clean', obsOff_clean',
      sound, flagging, freshOb, allWho, allParts, selfCheck, stateCheck, asksCheck,
      List.findSome?, List.find?, List.any, *]

theorem bf_early (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (k : Fin 3)
    (x : Option (St V)) (m : Nat) (h1 : 1 ≤ m) (h2 : m ≤ 4) :
    run P inp .none (seg m (39 - m)) (hitR (.bf k x) (ffX P inp T A b β m)) = ffW P inp T A b β 39
    ∨ Found P inp T A b β
        (run P inp .none (seg m (39 - m)) (hitR (.bf k x) (ffX P inp T A b β m))) := by
  rw [slide_run P inp T A b β (.bf k x) 4 (by omega) (4 - m) m h1 (by omega)
    (fun n a1 a2 => bf_slide_early P inp T A b β hb k x n (by omega) (by omega))]
  by_cases hx : x = β
  · left
    exact out_trivial P inp T A b β hP hb hc1 hc2 _ 4 (by omega) (by omega)
      (hit_bf_same _ k x (by simp [ffX, ffA, hx]))
  · right
    rw [show 39 - 4 = 15 + 20 by rfl, seg_add, run_append, bf_detect4 P inp T A b β hb k x hx]
    exact found_of_halted P inp T A b β hP hb hc1 hc2 hsp hst rfl rfl
      (rec_clean P T rfl rfl ⟨rfl, rfl⟩ (Or.inl rfl)) (vote_const A)

theorem bf_out (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (k : Fin 3)
    (x : Option (St V)) (m : Nat) (h1 : 1 ≤ m) (h2 : m ≤ 38) :
    Out P inp T A b β (run P inp .none (seg m (39 - m)) (hitR (.bf k x) (ffX P inp T A b β m))) := by
  obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes T A (Inp.dt P inp b) (Inp.now P inp b) hc1 hc2
  have hw := hP.work_same
  have hi := hP.inWeb_same
  simp only [Params.work, hi] at w1 w2 w3 w4 w5
  by_cases c1 : m ≤ 4
  · rcases bf_early P inp T A b β hP hb hc1 hc2 hsp hst k x m h1 c1 with e | f
    · exact out_same P inp T A b β _ e
    · exact Out.found f
  · by_cases c2 : m ≤ 21
    · -- R21 writes over all three places
      rw [slide_run P inp T A b β (.bf k x) 21 (by omega) (21 - m) m h1 (by omega)
        (fun n a1 a2 => by
          by_cases hn : n ≤ 15
          · exact bf_slide_mid P inp T A b β hb k x n (by omega) hn
          · exact slide_post P inp T A b β hP hb hc1 hc2 _ n (by omega) (by omega)
              (by simp [touches]; omega))]
      exact out_over P inp T A b β hP hb hc1 hc2 _ 21 (by omega) (by omega) (by ffs)
    · exact out_slide_end P inp T A b β hP hb hc1 hc2 _ m (by omega) (by omega)
        (fun n a1 a2 => by simp [touches]; omega)

end
end Gate
