/-
One fault in one round, put together: for every cell, every instant, and for a changed
answer, what the round leaves.
-/
import GateProof.Proofs.Own

set_option linter.unusedSectionVars false
set_option linter.deprecated false
set_option linter.unusedSimpArgs false
set_option linter.unusedVariables false

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)
variable (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V))

/-- Any cell, immediately before any step: the round's outcome is one of those `Out`
allows. -/
theorem cell_out (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (c : Cell V Q Tm)
    (m : Nat) (h1 : 1 ≤ m) (h2 : m ≤ 38) :
    Out P inp T A b β (run P inp .none (seg m (39 - m)) (hitR c (ffX P inp T A b β m))) := by
  have open_case : c.isOpen = true →
      (∀ n, 20 ≤ n → n ≤ 38 →
        Out P inp T A b β (run P inp .none (seg n (39 - n)) (hitR c (ffX P inp T A b β n)))) →
      Out P inp T A b β (run P inp .none (seg m (39 - m)) (hitR c (ffX P inp T A b β m))) := by
    intro hc h20
    by_cases hm : m ≤ 14
    · rcases pre_open P inp T A b β hP hb hc1 hc2 hsp hst c hc m h1 hm with e | f
      · exact out_same P inp T A b β _ e
      · exact Out.found f
    · exact post_open P inp T A b β hP hb hc1 hc2 hsp hst c hc h20 m (by omega) h2
  cases c with
  | sp p v => exact open_case rfl (sp_from20 P inp T A b β hP hb hc1 hc2 hsp hst p v)
  | ob i o => exact open_case rfl (ob_from20 P inp T A b β hP hb hc1 hc2 hsp hst i o)
  | rt p v => exact open_case rfl (rt_from20 P inp T A b β hP hb hc1 hc2 hsp hst p v)
  | rc p v => exact open_case rfl (rc_from20 P inp T A b β hP hb hc1 hc2 hsp hst p v)
  | bk k x => exact bk_out P inp T A b β hP hb hc1 hc2 hsp hst k x m h1 h2
  | bf k x => exact bf_out P inp T A b β hP hb hc1 hc2 hsp hst k x m h1 h2
  | asks k q => exact open_case rfl (asks_from20 P inp T A b β hP hb hc1 hc2 hsp hst k q)

/-- Any cell, before the round begins: nothing has changed at all, or the fault is
found in this round. -/
theorem cell_first (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (c : Cell V Q Tm) :
    run P inp .none (seg 1 38) (hitR c (ffX P inp T A b β 1)) = ffW P inp T A b β 39
    ∨ Found P inp T A b β (run P inp .none (seg 1 38) (hitR c (ffX P inp T A b β 1))) := by
  cases c with
  | sp p v => exact pre_open P inp T A b β hP hb hc1 hc2 hsp hst _ rfl 1 (by omega) (by omega)
  | ob i o => exact pre_open P inp T A b β hP hb hc1 hc2 hsp hst _ rfl 1 (by omega) (by omega)
  | rt p v => exact pre_open P inp T A b β hP hb hc1 hc2 hsp hst _ rfl 1 (by omega) (by omega)
  | rc p v => exact pre_open P inp T A b β hP hb hc1 hc2 hsp hst _ rfl 1 (by omega) (by omega)
  | bk k x => exact bk_early P inp T A b β hP hb hc1 hc2 hsp hst k x 1 (by omega) (by omega)
  | bf k x => exact bf_early P inp T A b β hP hb hc1 hc2 hsp hst k x 1 (by omega) (by omega)
  | asks k q => exact pre_open P inp T A b β hP hb hc1 hc2 hsp hst _ rfl 1 (by omega) (by omega)

/-- The round with no fault, whole. -/
theorem round_none (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) :
    round P inp .none (cleanG P T A b β) = ffW P inp T A b β 39 :=
  round_clean P hP inp T A b β hb hc1 hc2

/-- F1 to F7 in a round: the outcome. -/
theorem round_cell_out (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (s : Step)
    (c : Cell V Q Tm) :
    Out P inp T A b β (round P inp (.cell s c) (cleanG P T A b β)) := by
  have := round_cell P inp T A b β hP hb hc1 hc2 c s.num (num_pos s).1 (num_pos s).2
  rw [stepOf_num] at this
  rw [this]
  exact cell_out P inp T A b β hP hb hc1 hc2 hsp hst c s.num (num_pos s).1 (num_pos s).2

/-- A round that begins with one cell changed is the round with that cell changed
immediately before R1. -/
theorem round_hit (c : Cell V Q Tm) :
    round P inp .none (c.hit (cleanG P T A b β))
      = run P inp .none (seg 1 38) (hitR c (ffX P inp T A b β 1)) := by
  rw [round, steps_seg]
  congr 1
  cases c <;> cases inp <;>
    simp [start, hitR, ffX, ffA, cleanG, Cell.hit, Game.book, vote_const, vote_hit, bookAt, Inp.t0,
      Inp.dt]

/-- A cell changed between two rounds: nothing has changed at all, or the fault is found
in the next round. -/
theorem round_hit_out (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (c : Cell V Q Tm) :
    round P inp .none (c.hit (cleanG P T A b β)) = ffW P inp T A b β 39
    ∨ Found P inp T A b β (round P inp .none (c.hit (cleanG P T A b β))) := by
  rw [round_hit]
  exact cell_first P inp T A b β hP hb hc1 hc2 hsp hst c

/-! ### One observer's answer replaced (F8) -/

theorem run_answer_skip (i : Who) (a : Option (Option Finding)) (k n : Nat) (hn : 1 ≤ n)
    (hk : n + k ≤ 39) (h : 11 < n ∨ n + k ≤ 11) (r : Run V Q Tm Dt) :
    run P inp (.answer i a) (seg n k) r = run P inp .none (seg n k) r := by
  induction k generalizing n r with
  | zero => rfl
  | succ k ih =>
    rw [seg_succ]
    simp only [run]
    have hne : stepOf n ≠ Step.signals := by
      intro e
      have := congrArg Step.num e
      rw [num_stepOf n hn (by omega)] at this
      simp [Step.num] at this
      omega
    have : inject (Sched.answer i a) (stepOf n) r = r := by simp [inject, hne]
    rw [this, ih (n + 1) (by omega) (by omega) (by omega)]
    rfl

/-- F8: nothing has changed at all, or the fault is found in this round. -/
theorem round_answer_out (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (i : Who)
    (a : Option (Option Finding)) :
    round P inp (.answer i a) (cleanG P T A b β) = ffW P inp T A b β 39
    ∨ Found P inp T A b β (round P inp (.answer i a) (cleanG P T A b β)) := by
  have e0 : ffA P inp T A b β 1 = ffX P inp T A b β 1 := by simp [ffX]
  -- up to R10 there is no fault; at R11 the answer is replaced
  have e : round P inp (.answer i a) (cleanG P T A b β)
      = run P inp .none (seg 19 20) (run P inp .none (seg 11 8)
          { ffX P inp T A b β 11 with
            answers := fun j => if j = i then a else (ffX P inp T A b β 11).answers j }) := by
    rw [round, start_clean, steps_seg, show (38 : Nat) = 10 + (8 + 20) by rfl, seg_add, run_append,
      run_answer_skip P inp i a 10 1 (by omega) (by omega) (by omega), e0,
      run_ffX P inp T A b β hP hb hc1 hc2 10 1 (by omega) (by omega), seg_add, run_append,
      run_answer_skip P inp i a 20 19 (by omega) (by omega) (by omega)]
    congr 1
  rw [e]
  obtain ⟨r11, hr11⟩ : ∃ r : Run V Q Tm Dt, r = { ffX P inp T A b β 11 with
      answers := fun j => if j = i then a else (ffX P inp T A b β 11).answers j } := ⟨_, rfl⟩
  rw [← hr11]
  have hpl : Plain P r11 := by
    rw [hr11]; constructor <;> simp [ffX, ffA]
  have hbk : r11.g.bk = fun _ => bookAt P inp b 20 := by
    rw [hr11]; simp [ffX, ffA, bookAt_ge8]
  obtain ⟨g₁, f1, f2, f3, f4, f5, f6, f7, hcase⟩ :=
    gateAny P inp 11 (by omega) (by omega) _ hpl hbk (bookAt_halt P inp b hb 20)
  have s1 : g₁.sp = T := by rw [f1, hr11]; simp [ffX, ffA]
  have s2 : g₁.rt = T := by rw [f2, hr11]; simp [ffX, ffA]
  have s3 : g₁.rc = T := by rw [f3, hr11]; simp [ffX, ffA]
  have s5 : g₁.bf = fun _ => β := by rw [f5, hr11]; simp [ffX, ffA]
  have s6 : g₁.asks = fun _ => A := by rw [f6, hr11]; simp [ffX, ffA]
  simp only [show (19 : Nat) - 11 = 8 by rfl] at hcase
  have l1 : r11.t0 = Inp.t0 inp b := by rw [hr11]; simp [ffX, ffA]
  have l2 : r11.dt = Inp.dt P inp b := by rw [hr11]; simp [ffX, ffA]
  have l3 : r11.now = Inp.now P inp b := by rw [hr11]; simp [ffX, ffA]
  have l4 : r11.beganHalted = false := by rw [hr11]; simp [ffX, ffA]
  have l5 : r11.found = none := by rw [hr11]; simp [ffX, ffA]
  rw [l1, l2, l3, l4, l5] at hcase
  rcases hcase with ⟨why, hw⟩ | ⟨hd, hw⟩
  · right
    rw [hw]
    exact found_of_halted P inp T A b β hP hb hc1 hc2 hsp hst
      (stopAll_ff P inp b why _ g₁ (f4.trans hbk)) s5
      (rec_clean P T s2 s3
        (by show g₁.bf 0 = g₁.bf 1 ∧ g₁.bf 0 = g₁.bf 2
            rw [s5]; exact ⟨rfl, rfl⟩)
        (by show g₁.asks 0 = g₁.asks 1 ∨ g₁.asks 0 = g₁.asks 2 ∨ g₁.asks 1 = g₁.asks 2
            rw [s6]; exact Or.inl rfl))
      (by show vote g₁.asks = A
          rw [s6]; exact vote_const A)
  · left
    obtain ⟨d1, d2, d3, d4⟩ := (differs_none P g₁).1 hd
    rw [hw, eq_cleanG P T A β s1 s2 s3 (f4.trans hbk) s5 s6 (obsOff_none P d3),
      ← ffX_19 P inp T A b β hb]
    have := run_ffX P inp T A b β hP hb hc1 hc2 20 19 (by omega) (by omega)
    rw [this]; simp [ffX]

end
end Gate
