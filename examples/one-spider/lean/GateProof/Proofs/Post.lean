/-
One fault in one round, continued: a fault that lands at R15 or later.
-/
import GateProof.Proofs.Cells

set_option linter.unusedSectionVars false
set_option linter.deprecated false
set_option linter.unusedSimpArgs false
set_option linter.unusedVariables false

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)
variable (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V))

/-! ### R15 to R18, for a round in which the gate looks -/

/-- From R15: the checks still to come find nothing. -/
theorem gate15_pass (r : Run V Q Tm Dt) (ho : r.over = false) (hgl : r.gateLooks = true)
    (hoff : r.off = none) (hstop : r.stop = false) (c1 : stateCheck r.g = none)
    (c2 : obsOff P r.g = none) (c3 : asksCheck r.g = none) :
    run P inp .none (seg 15 4) r = reset P r := by
  simp [seg, List.range', run, inject, step, stepOf, ho, hgl, hoff, hstop, c1, c2, c3, reset]

theorem gate16_pass (r : Run V Q Tm Dt) (ho : r.over = false) (hgl : r.gateLooks = true)
    (hoff : r.off = none) (hstop : r.stop = false)
    (c2 : obsOff P r.g = none) (c3 : asksCheck r.g = none) :
    run P inp .none (seg 16 3) r = reset P r := by
  simp [seg, List.range', run, inject, step, stepOf, ho, hgl, hoff, hstop, c2, c3, reset]

theorem gate17_pass (r : Run V Q Tm Dt) (ho : r.over = false) (hgl : r.gateLooks = true)
    (hoff : r.off = none) (hstop : r.stop = false) (c3 : asksCheck r.g = none) :
    run P inp .none (seg 17 2) r = reset P r := by
  simp [seg, List.range', run, inject, step, stepOf, ho, hgl, hoff, hstop, c3, reset]

/-- From R15, R16 or R17: one of the checks still to come finds something. -/
theorem gate_sub_halt (j : Nat) (hj : j = 15 ∨ j = 16 ∨ j = 17) (r : Run V Q Tm Dt)
    (ho : r.over = false) (hgl : r.gateLooks = true) (hoff : r.off = none)
    (hd : (j = 15 ∧ stateCheck r.g ≠ none) ∨ (j ≤ 16 ∧ obsOff P r.g ≠ none)
          ∨ asksCheck r.g ≠ none) :
    ∃ why, run P inp .none (seg j (19 - j)) r
      = reset P { r with g := stopAll why r.now r.g, found := some why } := by
  rcases hj with h | h | h <;> subst h
  · cases c1 : stateCheck r.g with
    | some o => exact ⟨_, by simp [seg, List.range', run, inject, step, stepOf, ho, hgl, hoff, c1, reset]; exact ⟨rfl, rfl⟩⟩
    | none =>
      cases c2 : obsOff P r.g with
      | some o => exact ⟨_, by simp [seg, List.range', run, inject, step, stepOf, ho, hgl, hoff, c1, c2, reset]; exact ⟨rfl, rfl⟩⟩
      | none =>
        cases c3 : asksCheck r.g with
        | some o => exact ⟨_, by simp [seg, List.range', run, inject, step, stepOf, ho, hgl, hoff, c1, c2, c3, reset]; exact ⟨rfl, rfl⟩⟩
        | none => simp [c1, c2, c3] at hd
  · cases c2 : obsOff P r.g with
    | some o => exact ⟨_, by simp [seg, List.range', run, inject, step, stepOf, ho, hgl, hoff, c2, reset]; exact ⟨rfl, rfl⟩⟩
    | none =>
      cases c3 : asksCheck r.g with
      | some o => exact ⟨_, by simp [seg, List.range', run, inject, step, stepOf, ho, hgl, hoff, c2, c3, reset]; exact ⟨rfl, rfl⟩⟩
      | none => simp [c2, c3] at hd
  · cases c3 : asksCheck r.g with
    | some o => exact ⟨_, by simp [seg, List.range', run, inject, step, stepOf, ho, hgl, hoff, c3, reset]; exact ⟨rfl, rfl⟩⟩
    | none => simp [c3] at hd

/-- An open cell changed between the gate's checks (R15, R16, R17): the fault is found,
or the checks still to come pass and the round comes to R19 with the fault still in it. -/
theorem mid_open (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0)
    (c : Cell V Q Tm) (hc : c.isOpen = true) (j : Nat) (hj : j = 15 ∨ j = 16 ∨ j = 17) :
    Found P inp T A b β (run P inp .none (seg j (39 - j)) (hitR c (ffX P inp T A b β j)))
    ∨ run P inp .none (seg j (39 - j)) (hitR c (ffX P inp T A b β j))
        = run P inp .none (seg 19 20) (hitR c (ffX P inp T A b β 19)) := by
  have j19 : j ≤ 19 := by omega
  have ho : (hitR c (ffX P inp T A b β j)).over = false := by simp [ffX, j19, ffA, hitR]
  have hgl : (hitR c (ffX P inp T A b β j)).gateLooks = true := by
    simp [ffX, j19, ffA, hitR]; omega
  have hoff : (hitR c (ffX P inp T A b β j)).off = none := by simp [ffX, j19, ffA, hitR]
  have hstop : (hitR c (ffX P inp T A b β j)).stop = false := by simp [ffX, j19, ffA, hitR]
  have hnow : (hitR c (ffX P inp T A b β j)).now = Inp.now P inp b := by
    simp [ffX, j19, ffA, hitR]; omega
  have hbk : (c.hit (ffX P inp T A b β j).g).bk = fun _ => bookAt P inp b 20 := by
    have : (ffX P inp T A b β j).g.bk = fun _ => bookAt P inp b 20 := by
      simp [ffX, j19, ffA, bookAt_ge8 P inp b j (by omega)]
    cases c <;> simp [Cell.isOpen] at hc <;> simp [Cell.hit, this]
  rw [show 39 - j = (19 - j) + 20 by omega, seg_add, run_append, show j + (19 - j) = 19 by omega]
  by_cases hd : (j = 15 ∧ stateCheck (hitR c (ffX P inp T A b β j)).g ≠ none)
      ∨ (j ≤ 16 ∧ obsOff P (hitR c (ffX P inp T A b β j)).g ≠ none)
      ∨ asksCheck (hitR c (ffX P inp T A b β j)).g ≠ none
  · left
    obtain ⟨why, e⟩ := gate_sub_halt P inp j hj _ ho hgl hoff hd
    rw [e]
    have e2 : reset P { hitR c (ffX P inp T A b β j) with
          g := stopAll why (hitR c (ffX P inp T A b β j)).now (hitR c (ffX P inp T A b β j)).g,
          found := some why }
        = idle P (stopAll why (Inp.now P inp b) (c.hit (ffX P inp T A b β j).g)) (Inp.t0 inp b)
            (Inp.dt P inp b) (Inp.now P inp b) false (some why) false := by
      rcases hj with h | h | h <;> subst h <;> simp [reset, idle, ffX, ffA, hitR]
    rw [e2]
    obtain ⟨hr, hv, hbf⟩ := rec_of_hit P T A β c hc (ffX P inp T A b β j).g
      (c.hit (ffX P inp T A b β j).g)
      (fun p => Or.inl (by simp [ffX, j19, ffA])) (by simp [ffX, j19, ffA])
      (by simp [ffX, j19, ffA]) (by simp [ffX, j19, ffA]) (by simp [ffX, j19, ffA])
      (fun i => by simp [ffX, j19, ffA, freshOb]) rfl rfl rfl rfl rfl (fun _ => rfl)
    exact found_of_halted P inp T A b β hP hb hc1 hc2 hsp hst
      (stopAll_ff P inp b why _ _ hbk) hbf hr hv
  · right
    have c3 : asksCheck (hitR c (ffX P inp T A b β j)).g = none := by
      cases h : asksCheck (hitR c (ffX P inp T A b β j)).g with
      | none => rfl
      | some o => exact (hd (Or.inr (Or.inr (by simp [h])))).elim
    have c2 : j ≤ 16 → obsOff P (hitR c (ffX P inp T A b β j)).g = none := by
      intro hj'
      cases h : obsOff P (hitR c (ffX P inp T A b β j)).g with
      | none => rfl
      | some o => exact (hd (Or.inr (Or.inl ⟨hj', by simp [h]⟩))).elim
    have c1 : j = 15 → stateCheck (hitR c (ffX P inp T A b β j)).g = none := by
      intro hj'
      cases h : stateCheck (hitR c (ffX P inp T A b β j)).g with
      | none => rfl
      | some o => exact (hd (Or.inl ⟨hj', by simp [h]⟩)).elim
    have e : run P inp .none (seg j (19 - j)) (hitR c (ffX P inp T A b β j))
        = reset P (hitR c (ffX P inp T A b β j)) := by
      rcases hj with h | h | h <;> subst h
      · exact gate15_pass P inp _ ho hgl hoff hstop (c1 rfl) (c2 (by omega)) c3
      · exact gate16_pass P inp _ ho hgl hoff hstop (c2 (by omega)) c3
      · exact gate17_pass P inp _ ho hgl hoff hstop c3
    rw [e]
    congr 1
    rcases hj with h | h | h <;> subst h <;> simp [reset, ffX, ffA, hitR, bookAt_ge8, noLook]

/-! ### Sliding a fault from R16 on -/

/-- Does step `n` (16 to 38) of a round with no fault read or write the cell? -/
def touches (c : Cell V Q Tm) (n : Nat) : Bool :=
  match c with
  | .sp _ _ => decide (n ∈ [21, 22, 23, 24, 25, 26, 28, 29, 31, 33])
  | .rt _ _ => decide (n ∈ [16, 32, 36])
  | .rc _ _ => decide (n ∈ [16, 27, 28, 29, 30, 32, 36])
  | .ob _ _ => decide (n ∈ [16, 20, 32, 34, 35])
  | .asks k _ =>
    decide (n = 17 ∨ n = 37 ∨ (k = 0 ∧ n = 22) ∨ (k = 1 ∧ (n = 29 ∨ n = 30)))
  | .bf _ _ => decide (n = 21)
  | .bk _ _ => true

set_option maxHeartbeats 40000000 in
/-- A step that does not touch the cell leaves the fault where it is. -/
theorem slide_post (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (c : Cell V Q Tm) (n : Nat) (h1 : 16 ≤ n) (h2 : n ≤ 38)
    (h : touches c n = false) :
    step P inp (stepOf n) (hitR c (ffX P inp T A b β n)) = hitR c (ffX P inp T A b β (n + 1)) := by
  obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes T A (Inp.dt P inp b) (Inp.now P inp b) hc1 hc2
  have hw := hP.work_same
  have hi := hP.inWeb_same
  simp only [Params.work, hi] at w1 w2 w3 w4 w5
  have hn : n = 16 ∨ n = 17 ∨ n = 18 ∨ n = 19 ∨ n = 20 ∨ n = 21 ∨ n = 22 ∨ n = 23 ∨ n = 24
      ∨ n = 25 ∨ n = 26 ∨ n = 27 ∨ n = 28 ∨ n = 29 ∨ n = 30 ∨ n = 31 ∨ n = 32 ∨ n = 33 ∨ n = 34
      ∨ n = 35 ∨ n = 36 ∨ n = 37 ∨ n = 38 := by omega
  cases c with
  | sp p v =>
    rcases hn with e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e <;> subst e <;>
      simp [touches] at h <;> ffs <;>
      (try (funext i; by_cases hi5 : i = moths <;> simp [hi5]))
  | rt p v =>
    rcases hn with e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e <;> subst e <;>
      simp [touches] at h <;> ffs <;>
      (try (funext i; by_cases hi5 : i = moths <;> simp [hi5]))
  | rc p v =>
    rcases hn with e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e <;> subst e <;>
      simp [touches] at h <;> ffs <;>
      (try (funext i; by_cases hi5 : i = moths <;> simp [hi5]))
  | ob i o =>
    rcases hn with e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e <;> subst e <;>
      simp [touches] at h <;> ffs <;>
      (try (funext i; by_cases hi5 : i = moths <;> simp [hi5]))
  | asks k q =>
    rcases fin3 k with e' | e' | e' <;> subst e' <;>
    rcases hn with e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e <;> subst e <;>
      simp [touches] at h <;> ffs <;>
      (try (funext i; by_cases hi5 : i = moths <;> simp [hi5]))
  | bf k x =>
    rcases hn with e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e|e <;> subst e <;>
      simp [touches] at h <;> ffs <;>
      (try (funext i; by_cases hi5 : i = moths <;> simp [hi5]))
  | bk k x => simp [touches] at h

/-- A fault that is still there at the end of the round, in one cell. -/
theorem out_latent (c : Cell V Q Tm) :
    Out P inp T A b β (hitR c (ffX P inp T A b β 39)) := by
  refine Out.near (by simp [ffX, ffW, wk, hitR]) (by simp [ffX, ffW, wk, hitR])
    (by simp [ffX, ffW, wk, hitR]) (by simp [ffX, ffW, wk, hitR]) ?_ (by simp [ffX, ffW, wk, hitR])
    (by simp [ffX, ffW, wk, hitR])
  left
  exact ⟨c, by simp [ffX, hitR]⟩

/-- The steps from `m` to the end do not touch the cell: the fault is still there at the
end. -/
theorem out_slide_end (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (c : Cell V Q Tm) (m : Nat) (h1 : 16 ≤ m) (h2 : m ≤ 39)
    (ht : ∀ n, m ≤ n → n ≤ 38 → touches c n = false) :
    Out P inp T A b β (run P inp .none (seg m (39 - m)) (hitR c (ffX P inp T A b β m))) := by
  rw [slide_run P inp T A b β c 39 (by omega) (39 - m) m (by omega) (by omega)
    (fun n a1 a2 => slide_post P inp T A b β hP hb hc1 hc2 c n (by omega) (by omega)
      (ht n a1 (by omega)))]
  exact out_latent P inp T A b β c

/-- The steps from `m` up to `a` do not touch the cell: what holds of the fault landing
before step `a` holds of it landing before step `m`. -/
theorem out_slide (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (c : Cell V Q Tm) (m a : Nat) (h1 : 16 ≤ m) (h2 : m ≤ a)
    (h3 : a ≤ 39) (ht : ∀ n, m ≤ n → n < a → touches c n = false)
    (h : Out P inp T A b β (run P inp .none (seg a (39 - a)) (hitR c (ffX P inp T A b β a)))) :
    Out P inp T A b β (run P inp .none (seg m (39 - m)) (hitR c (ffX P inp T A b β m))) := by
  rw [slide_run P inp T A b β c a h3 (a - m) m (by omega) (by omega)
    (fun n a1 a2 => slide_post P inp T A b β hP hb hc1 hc2 c n (by omega) (by omega)
      (ht n a1 a2))]
  exact h

/-! ### A part of the state changed, at R15 or later -/

set_option maxHeartbeats 40000000 in
theorem sp_from20 (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (p : Part) (v : V)
    (n : Nat) (h1 : 20 ≤ n) (h2 : n ≤ 38) :
    Out P inp T A b β (run P inp .none (seg n (39 - n)) (hitR (.sp p v) (ffX P inp T A b β n))) := by
  obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes T A (Inp.dt P inp b) (Inp.now P inp b) hc1 hc2
  have hw := hP.work_same
  have hi := hP.inWeb_same
  simp only [Params.work, hi] at w1 w2 w3 w4 w5
  by_cases c1 : n ≤ 26
  · -- before the gate checks the work: the state is not what the second doing will make
    rw [show 39 - n = (26 - n) + 13 by omega, seg_add, run_append, show n + (26 - n) = 26 by omega]
    have hn : n = 20 ∨ n = 21 ∨ n = 22 ∨ n = 23 ∨ n = 24 ∨ n = 25 ∨ n = 26 := by omega
    rcases hn with h | h | h | h | h | h | h <;> subst h <;>
    refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst 26 (by omega) (by omega) _ ?_ ?_ ?_ ?_ ?_ ?_
      ?_ ?_ ?_ ?_ ?_ (rec_clean P T ?_ ?_ ?_ ?_) (Or.inl ⟨by omega, ?_, ?_⟩) <;> ffs
  · by_cases c2 : n ≤ 30
    · have hn : n = 27 ∨ n = 28 ∨ n = 29 ∨ n = 30 := by omega
      rcases hn with h | h | h | h <;> subst h <;>
      refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst _ (by omega) (by omega) _ ?_ ?_ ?_ ?_ ?_
        ?_ ?_ ?_ ?_ ?_ ?_ (rec_clean P T ?_ ?_ ?_ ?_) (Or.inl ⟨by omega, ?_, ?_⟩) <;> ffs
    · have k32 : Out P inp T A b β (run P inp .none (seg 32 (39 - 32))
          (hitR (.sp p v) (ffX P inp T A b β 32))) := by
        refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst _ (by omega) (by omega) _ ?_ ?_ ?_ ?_
          ?_ ?_ ?_ ?_ ?_ ?_ ?_ (rec_clean P T ?_ ?_ ?_ ?_) (Or.inr (Or.inr ⟨by omega, ?_⟩)) <;> ffs
      by_cases c3 : n = 31
      · subst c3
        refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst _ (by omega) (by omega) _ ?_ ?_ ?_ ?_
          ?_ ?_ ?_ ?_ ?_ ?_ ?_ (rec_clean P T ?_ ?_ ?_ ?_) (Or.inr (Or.inr ⟨by omega, ?_⟩)) <;> ffs
      · by_cases c4 : n = 32
        · subst c4; exact k32
        · by_cases c5 : n = 33
          · subst c5
            have e := slide_post P inp T A b β hP hb hc1 hc2 (.sp p v) 32 (by omega) (by omega)
              (by simp [touches])
            rw [show 39 - 32 = 6 + 1 by rfl, seg_succ] at k32
            simp only [run, inject] at k32
            rw [e] at k32
            exact k32
          · exact out_slide_end P inp T A b β hP hb hc1 hc2 _ n (by omega) (by omega)
              (fun k a1 a2 => by simp [touches]; omega)

theorem ffX_ge20 (n : Nat) (h : 20 ≤ n) : ffX P inp T A b β n = ffW P inp T A b β n := by
  simp [ffX]; omega

/-- From R15 on, an open cell: it is enough to say what the fault does from R19 on. -/
theorem post_open (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0)
    (c : Cell V Q Tm) (hc : c.isOpen = true)
    (h20 : ∀ n, 20 ≤ n → n ≤ 38 →
      Out P inp T A b β (run P inp .none (seg n (39 - n)) (hitR c (ffX P inp T A b β n))))
    (m : Nat) (h1 : 15 ≤ m) (h2 : m ≤ 38) :
    Out P inp T A b β (run P inp .none (seg m (39 - m)) (hitR c (ffX P inp T A b β m))) := by
  have k19 : Out P inp T A b β (run P inp .none (seg 19 (39 - 19))
      (hitR c (ffX P inp T A b β 19))) := by
    refine out_slide P inp T A b β hP hb hc1 hc2 c 19 20 (by omega) (by omega) (by omega) ?_
      (h20 20 (by omega) (by omega))
    intro n a1 a2
    have : n = 19 := by omega
    subst this
    cases c <;> simp [Cell.isOpen] at hc <;> simp [touches]
  have k18 : Out P inp T A b β (run P inp .none (seg 18 (39 - 18))
      (hitR c (ffX P inp T A b β 18))) := by
    refine out_slide P inp T A b β hP hb hc1 hc2 c 18 19 (by omega) (by omega) (by omega) ?_ k19
    intro n a1 a2
    have : n = 18 := by omega
    subst this
    cases c <;> simp [Cell.isOpen] at hc <;> simp [touches]
  by_cases c1 : 20 ≤ m
  · exact h20 m c1 h2
  · by_cases c2 : m = 19
    · subst c2; exact k19
    · by_cases c3 : m = 18
      · subst c3; exact k18
      · have hj : m = 15 ∨ m = 16 ∨ m = 17 := by omega
        rcases mid_open P inp T A b β hP hb hc1 hc2 hsp hst c hc m hj with f | e
        · exact Out.found f
        · rw [e]; exact k19

theorem post_sp (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (p : Part) (v : V)
    (m : Nat) (h1 : 15 ≤ m) (h2 : m ≤ 38) :
    Out P inp T A b β (run P inp .none (seg m (39 - m)) (hitR (.sp p v) (ffX P inp T A b β m))) :=
  post_open P inp T A b β hP hb hc1 hc2 hsp hst _ rfl
    (fun n a1 a2 => sp_from20 P inp T A b β hP hb hc1 hc2 hsp hst p v n a1 a2) m h1 h2

/-- The fault is written over by step `a`: from there the round is the round with no
fault. -/
theorem out_over (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (c : Cell V Q Tm) (a : Nat) (h1 : 1 ≤ a) (h2 : a ≤ 38)
    (h : step P inp (stepOf a) (hitR c (ffX P inp T A b β a)) = ffX P inp T A b β (a + 1)) :
    Out P inp T A b β (run P inp .none (seg a (39 - a)) (hitR c (ffX P inp T A b β a))) := by
  rw [show 39 - a = (38 - a) + 1 by omega, seg_succ]
  simp only [run, inject]
  rw [h, run_ffX P inp T A b β hP hb hc1 hc2 (38 - a) (a + 1) (by omega) (by omega),
    show a + 1 + (38 - a) = 39 by omega]
  exact out_same P inp T A b β _ (ffX_ge20 P inp T A b β 39 (by omega))

/-! ### The record's text of a part changed, at R15 or later -/

set_option maxHeartbeats 40000000 in
theorem rt_from20 (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (p : Part) (v : V)
    (n : Nat) (h1 : 20 ≤ n) (h2 : n ≤ 38) :
    Out P inp T A b β (run P inp .none (seg n (39 - n)) (hitR (.rt p v) (ffX P inp T A b β n))) := by
  obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes T A (Inp.dt P inp b) (Inp.now P inp b) hc1 hc2
  have hw := hP.work_same
  have hi := hP.inWeb_same
  simp only [Params.work, hi] at w1 w2 w3 w4 w5
  have k32 : Out P inp T A b β (run P inp .none (seg 32 (39 - 32))
      (hitR (.rt p v) (ffX P inp T A b β 32))) := by
    refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst _ (by omega) (by omega) _ ?_ ?_ ?_ ?_
      ?_ ?_ ?_ ?_ ?_ ?_ ?_
      (rec_of_hit P T A (some T) (.rt p v) rfl (ffX P inp T A b β 32).g _ (fun q => Or.inr rfl)
        ?_ ?_ ?_ ?_ ?_ rfl rfl rfl rfl rfl (fun _ => rfl)).1
      (Or.inr (Or.inr ⟨by omega, ?_⟩)) <;> ffs
  have k36 : Out P inp T A b β (run P inp .none (seg 36 (39 - 36))
      (hitR (.rt p v) (ffX P inp T A b β 36))) :=
    out_over P inp T A b β hP hb hc1 hc2 _ 36 (by omega) (by omega) (by ffs)
  by_cases c1 : n ≤ 32
  · exact out_slide P inp T A b β hP hb hc1 hc2 _ n 32 (by omega) c1 (by omega)
      (fun k a1 a2 => by simp [touches]; omega) k32
  · by_cases c2 : n ≤ 36
    · exact out_slide P inp T A b β hP hb hc1 hc2 _ n 36 (by omega) c2 (by omega)
        (fun k a1 a2 => by simp [touches]; omega) k36
    · exact out_slide_end P inp T A b β hP hb hc1 hc2 _ n (by omega) (by omega)
        (fun k a1 a2 => by simp [touches]; omega)

/-! ### The record's copy of a part changed, at R15 or later -/

set_option maxHeartbeats 40000000 in
theorem rc_from20 (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (p : Part) (v : V)
    (n : Nat) (h1 : 20 ≤ n) (h2 : n ≤ 38) :
    Out P inp T A b β (run P inp .none (seg n (39 - n)) (hitR (.rc p v) (ffX P inp T A b β n))) := by
  obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes T A (Inp.dt P inp b) (Inp.now P inp b) hc1 hc2
  have hw := hP.work_same
  have hi := hP.inWeb_same
  simp only [Params.work, hi] at w1 w2 w3 w4 w5
  have kt : ∀ k, 26 ≤ k → k ≤ 32 → Out P inp T A b β (run P inp .none (seg k (39 - k))
      (hitR (.rc p v) (ffX P inp T A b β k))) := by
    intro k a1 a2
    have hk : k = 26 ∨ k = 27 ∨ k = 28 ∨ k = 29 ∨ k = 30 ∨ k = 31 ∨ k = 32 := by omega
    rcases hk with h | h | h | h | h | h | h <;> subst h
    all_goals first
      | (refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst _ (by omega) (by omega) _ ?_ ?_ ?_ ?_
          ?_ ?_ ?_ ?_ ?_ ?_ ?_
          (rec_of_hit P T A (some T) (.rc p v) rfl (ffX P inp T A b β _).g _ (fun q => Or.inr rfl)
            ?_ ?_ ?_ ?_ ?_ rfl rfl rfl rfl rfl (fun _ => rfl)).1
          (Or.inr (Or.inl ⟨by omega, ?_⟩)) <;> ffs; done)
      | (refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst _ (by omega) (by omega) _ ?_ ?_ ?_ ?_
          ?_ ?_ ?_ ?_ ?_ ?_ ?_
          (rec_of_hit P T A (some T) (.rc p v) rfl (ffX P inp T A b β _).g _ (fun q => Or.inr rfl)
            ?_ ?_ ?_ ?_ ?_ rfl rfl rfl rfl rfl (fun _ => rfl)).1
          (Or.inr (Or.inr ⟨by omega, ?_⟩)) <;> ffs; done)
  have k36 : Out P inp T A b β (run P inp .none (seg 36 (39 - 36))
      (hitR (.rc p v) (ffX P inp T A b β 36))) :=
    out_over P inp T A b β hP hb hc1 hc2 _ 36 (by omega) (by omega) (by ffs)
  by_cases c0 : n ≤ 26
  · exact out_slide P inp T A b β hP hb hc1 hc2 _ n 26 (by omega) c0 (by omega)
      (fun k a1 a2 => by simp [touches]; omega) (kt 26 (by omega) (by omega))
  · by_cases c1 : n ≤ 32
    · exact kt n (by omega) c1
    · by_cases c2 : n ≤ 36
      · exact out_slide P inp T A b β hP hb hc1 hc2 _ n 36 (by omega) c2 (by omega)
          (fun k a1 a2 => by simp [touches]; omega) k36
      · exact out_slide_end P inp T A b β hP hb hc1 hc2 _ n (by omega) (by omega)
          (fun k a1 a2 => by simp [touches]; omega)

/-! ### One of the three lists changed, at R15 or later -/

set_option maxHeartbeats 40000000 in
theorem asks_from20 (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (k : Fin 3) (q : Q)
    (n : Nat) (h1 : 20 ≤ n) (h2 : n ≤ 38) :
    Out P inp T A b β (run P inp .none (seg n (39 - n)) (hitR (.asks k q) (ffX P inp T A b β n))) := by
  obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes T A (Inp.dt P inp b) (Inp.now P inp b) hc1 hc2
  have hw := hP.work_same
  have hi := hP.inWeb_same
  simp only [Params.work, hi] at w1 w2 w3 w4 w5
  have k37 : Out P inp T A b β (run P inp .none (seg 37 (39 - 37))
      (hitR (.asks k q) (ffX P inp T A b β 37))) :=
    out_over P inp T A b β hP hb hc1 hc2 _ 37 (by omega) (by omega) (by ffs)
  by_cases c38 : n = 38
  · subst c38
    exact out_slide_end P inp T A b β hP hb hc1 hc2 _ 38 (by omega) (by omega)
      (fun j a1 a2 => by simp [touches]; omega)
  rcases fin3 k with e | e | e <;> subst e
  · -- the first list: the round's work takes it in at R22
    have k22 : Out P inp T A b β (run P inp .none (seg 22 (39 - 22))
        (hitR (.asks 0 q) (ffX P inp T A b β 22))) := by
      rw [show 39 - 22 = 4 + 13 by rfl, seg_add, run_append]
      refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst 26 (by omega) (by omega) _ ?_ ?_ ?_ ?_ ?_
        ?_ ?_ ?_ ?_ ?_ ?_ (rec_clean P T ?_ ?_ ?_ (Or.inr (Or.inr ?_)))
        (Or.inl ⟨by omega, ?_, ?_⟩) <;> ffs
    by_cases c1 : n ≤ 22
    · exact out_slide P inp T A b β hP hb hc1 hc2 _ n 22 (by omega) c1 (by omega)
        (fun j a1 a2 => by simp [touches]; omega) k22
    · exact out_slide P inp T A b β hP hb hc1 hc2 _ n 37 (by omega) (by omega) (by omega)
        (fun j a1 a2 => by simp [touches]; omega) k37
  · -- the second list: the second text of the rules and the second doing read it
    have kt : ∀ j, 26 ≤ j → j ≤ 30 → Out P inp T A b β (run P inp .none (seg j (39 - j))
        (hitR (.asks 1 q) (ffX P inp T A b β j))) := by
      intro j a1 a2
      have hj : j = 26 ∨ j = 27 ∨ j = 28 ∨ j = 29 ∨ j = 30 := by omega
      rcases hj with h | h | h | h | h <;> subst h <;>
      refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst _ (by omega) (by omega) _ ?_ ?_ ?_ ?_ ?_
        ?_ ?_ ?_ ?_ ?_ ?_ (rec_clean P T ?_ ?_ ?_ (Or.inr (Or.inl ?_)))
        (Or.inr (Or.inl ⟨by omega, ?_⟩)) <;> ffs
    by_cases c1 : n ≤ 26
    · exact out_slide P inp T A b β hP hb hc1 hc2 _ n 26 (by omega) c1 (by omega)
        (fun j a1 a2 => by simp [touches]; omega) (kt 26 (by omega) (by omega))
    · by_cases c2 : n ≤ 30
      · exact kt n (by omega) c2
      · exact out_slide P inp T A b β hP hb hc1 hc2 _ n 37 (by omega) (by omega) (by omega)
          (fun j a1 a2 => by simp [touches]; omega) k37
  · -- the third list: nothing reads it after R17
    exact out_slide P inp T A b β hP hb hc1 hc2 _ n 37 (by omega) (by omega) (by omega)
      (fun j a1 a2 => by simp [touches]; omega) k37

/-! ### An observer changed, at R15 or later -/

set_option maxHeartbeats 40000000 in
theorem ob_from20 (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (i : Who) (o : Observer V)
    (n : Nat) (h1 : 20 ≤ n) (h2 : n ≤ 38) :
    Out P inp T A b β (run P inp .none (seg n (39 - n)) (hitR (.ob i o) (ffX P inp T A b β n))) := by
  obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes T A (Inp.dt P inp b) (Inp.now P inp b) hc1 hc2
  have hw := hP.work_same
  have hi := hP.inWeb_same
  simp only [Params.work, hi] at w1 w2 w3 w4 w5
  by_cases c1 : n ≤ 26
  · rw [show 39 - n = (26 - n) + 13 by omega, seg_add, run_append, show n + (26 - n) = 26 by omega]
    have hn : n = 20 ∨ n = 21 ∨ n = 22 ∨ n = 23 ∨ n = 24 ∨ n = 25 ∨ n = 26 := by omega
    rcases hn with h | h | h | h | h | h | h <;> subst h <;>
    refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst 26 (by omega) (by omega) _ ?_ ?_ ?_ ?_ ?_ ?_
      ?_ ?_ ?_ ?_ ?_ (rec_clean P T ?_ ?_ ?_ (Or.inl ?_)) (Or.inl ⟨by omega, ?_, ?_⟩) <;> ffs
  · by_cases c2 : n ≤ 30
    · have hn : n = 27 ∨ n = 28 ∨ n = 29 ∨ n = 30 := by omega
      rcases hn with h | h | h | h <;> subst h <;>
      refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst _ (by omega) (by omega) _ ?_ ?_ ?_ ?_ ?_
        ?_ ?_ ?_ ?_ ?_ ?_ (rec_clean P T ?_ ?_ ?_ (Or.inl ?_)) (Or.inl ⟨by omega, ?_, ?_⟩) <;> ffs
    · by_cases c3 : n ≤ 32
      · have hn : n = 31 ∨ n = 32 := by omega
        rcases hn with h | h <;> subst h <;>
        refine out_tail P inp T A b β hP hb hc1 hc2 hsp hst _ (by omega) (by omega) _ ?_ ?_ ?_ ?_
          ?_ ?_ ?_ ?_ ?_ ?_ ?_ (rec_clean P T ?_ ?_ ?_ (Or.inl ?_))
          (Or.inr (Or.inr ⟨by omega, ?_⟩)) <;> ffs
      · -- from R33 on: the round is recorded, and the observer is as the fault and the
        -- steps still to come leave it
        have kl : ∀ j, 34 ≤ j → j ≤ 38 → Out P inp T A b β (run P inp .none (seg j (39 - j))
            (hitR (.ob i o) (ffX P inp T A b β j))) := by
          intro j a1 a2
          have hj : j = 34 ∨ j = 35 ∨ j = 36 ∨ j = 37 ∨ j = 38 := by omega
          rcases hj with h | h | h | h | h <;> subst h <;>
          by_cases hm : moths = i <;> by_cases ha : o.alive = true <;>
          by_cases hbt : o.beat = b.rounds + 1 <;>
          refine Out.near ?_ ?_ ?_ ?_ (near_dirty P inp T A b β ?_ ?_ ?_ ?_ ?_) ?_ ?_ <;> ffs
        by_cases c4 : n = 33
        · subst c4
          exact out_slide P inp T A b β hP hb hc1 hc2 _ 33 34 (by omega) (by omega) (by omega)
            (fun j a1 a2 => by simp [touches]; omega) (kl 34 (by omega) (by omega))
        · exact kl n (by omega) h2

end
end Gate
