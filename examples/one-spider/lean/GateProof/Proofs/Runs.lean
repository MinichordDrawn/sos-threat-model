/-
Runs of several ticks: what holds after the tick of the fault and after every tick that
follows it.
-/
import GateProof.Proofs.Ticks

set_option linter.unusedSectionVars false
set_option linter.deprecated false
set_option linter.unusedSimpArgs false
set_option linter.unusedVariables false

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)

/-! ### Small facts about the forms -/

theorem nearG_book {g : Game V Q Tm} {T : St V} {A : Q} {b : Book V Tm} {β : Option (St V)}
    (h : NearG g (cleanG P T A b β)) : g.book = b := by
  rcases h with ⟨c, rfl⟩ | ⟨Z, obx, x, rfl⟩
  · cases c <;> simp [Game.book, Cell.hit, cleanG, vote_const, vote_hit]
  · simp [Game.book, cleanG, vote_const]

theorem nearG_self (g : Game V Q Tm) : NearG g g :=
  Or.inl ⟨.sp 0 (g.sp 0), by cases g; simp [Cell.hit, fun_upd_same]⟩

theorem bump_cleanG (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V)) :
    bump (cleanG P T A b β)
      = cleanG P T A { b with halts := b.halts + 1, restarts := b.restarts + 1 } β := by
  simp [bump, cleanG]

theorem settled_book {g : Game V Q Tm} (h : Settled P g) : g.book = g.bk 0 := by
  rw [settled_form P h]; simp [Game.book, cleanG, vote_const]

theorem mended_book {g : Game V Q Tm} {T : St V} {N : Nat} (h : Mended P g T N) :
    g.halted = false ∧ g.stuck = false ∧ g.book.halts = N := by
  have hb := settled_book P h.1
  refine ⟨?_, ?_, ?_⟩
  · simp [Game.halted, hb, h.1.noHalt]
  · simp [Game.stuck, hb, h.1.noHalt]
  · rw [hb]; exact h.2.2.2.2

theorem clean_mended {g : Game V Q Tm} (h : Clean P g) :
    Mended P g g.rt (g.bk 0).halts :=
  ⟨h.1, rfl, by rw [h.2.1]; omega, h.2.2, rfl⟩

/-- The outcome `Found.once`, as a statement about the game: it is clean, with the record
the round with no fault makes, and one more halt counted. -/
theorem once_clean (hP : Sound P) (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm)
    (β : Option (St V)) (hb : b.halt = none) (hc1 : P.canBe₁ T = true) (hc2 : P.canBe₂ T = true)
    {g : Game V Q Tm} (h : g = bump (ffW P inp T A b β 39).g) :
    Clean P g ∧ g.rt = P.work T A (Inp.dt P inp b) (Inp.now P inp b)
      ∧ (g.bk 0).halts = b.halts + 1 := by
  obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes T A (Inp.dt P inp b) (Inp.now P inp b) hc1 hc2
  rw [h, ffW, wk_39_g, bump_cleanG]
  refine ⟨clean_cleanG P _ _ _ _ (by simp [bookAt_20, hb]) w2 w3 rfl rfl, rfl, ?_⟩
  simp [cleanG, bookAt_20]

/-! ### After the tick of the fault (T2, T3, T4) -/

/-- Where a run stands after one fault and any number of ticks with no new fault. `N₀`
is the count of halts from before the fault and `T` the record as the recorded rounds
have made it. Not found yet: the game is a clean one (`G`) with something of the fault
left in it. Or halted, and it can be put right to `T`. Or the halt is over and everything
agrees on `T`. -/
inductive Inv (N₀ : Nat) (g : Game V Q Tm) (T : St V) : Prop where
  | near (G : Game V Q Tm) (hG : Clean P G) (hT : G.rt = T) (hN : (G.bk 0).halts = N₀)
      (h : NearG g G)
  | halt (h : HR P g T (N₀ + 1))
  | mend (h : Mended P g T (N₀ + 1))

theorem inv_not_stuck {N₀ : Nat} {g : Game V Q Tm} {T : St V} (h : Inv P N₀ g T) :
    g.stuck = false := by
  cases h with
  | near G hG hT hN h =>
    obtain ⟨e, hb, _⟩ := clean_form P hG
    rw [e] at h
    simp [Game.stuck, nearG_book P h, hb]
  | halt h => exact (HR.book P h).2
  | mend h => exact (mended_book P h).2.1

theorem inv_settled {N₀ : Nat} {g : Game V Q Tm} {T : St V} (h : Inv P N₀ g T)
    (h1 : g.halted = false) (h2 : N₀ < g.book.halts) : Settled P g ∧ g.rt = T := by
  cases h with
  | near G hG hT hN h =>
    obtain ⟨e, _⟩ := clean_form P hG
    rw [e] at h
    rw [nearG_book P h, hN] at h2
    omega
  | halt h => rw [(HR.book P h).1] at h1; cases h1
  | mend h => exact ⟨h.1, h.2.1⟩

/-- One more tick with no new fault keeps `Inv`, with the record moved on if the round
was recorded. -/
theorem inv_step (hP : Sound P) {N₀ : Nat} {g : Game V Q Tm} {T : St V} (h : Inv P N₀ g T)
    (es : List (Ev E)) (inp : Inp Tm Dt) :
    Inv P N₀ (tick P es inp none g).g
      (if (tick P es inp none g).recorded.isSome
        then P.work T (vote (events P es g).asks) (tick P es inp none g).dt (tick P es inp none g).now
        else T) := by
  cases h with
  | near G hG hT hN h =>
    obtain ⟨e, hb, hsp, hst, c1, c2⟩ := clean_form P hG
    rw [hT] at e c1 c2
    rw [e] at h
    obtain ⟨A', b', _, s, _, hv, hcase⟩ :=
      near_tick P hP es inp T (G.asks 0) (G.bk 0) (G.bf 0) hb c1 c2 hsp hst h
    have hb' : b'.halt = none := by rw [s.halt, hb]
    rcases hcase with ex | f
    · obtain ⟨r1, r2, r3, r4, r5, _, _, _⟩ := ffW_39_clean P hP inp T A' b' (G.bf 0) hb' c1 c2
      rw [ex, hv]
      simp only [r1, Option.isSome_some, if_true]
      exact Inv.near _ r3 r4 (by rw [r5, s.halts, hN]) (nearG_self _)
    · cases f with
      | once why f1 f2 f3 f4 f5 f6 f7 =>
        obtain ⟨k1, k2, k3⟩ := once_clean P hP inp T A' b' (G.bf 0) hb' c1 c2 f5
        have hrec : (tick P es inp none g).recorded
            = some (P.work T A' (Inp.dt P inp b') (Inp.now P inp b')) := by
          rw [f2]; simp [ffW, wk, Params.work]
        rw [hv, f3, f4]
        simp only [hrec, Option.isSome_some, if_true]
        refine Inv.mend ⟨k1.1, k2, by rw [k1.2.1]; omega, k1.2.2, ?_⟩
        rw [k3, s.halts, hN]
      | halt why f1 f2 f3 f4 f5 f7 =>
        simp only [f2, Option.isSome_none]
        refine Inv.halt ?_
        rw [s.halts, hN] at f5
        simpa using f5
      | mend why f1 f2 f3 f4 f5 f6 f7 =>
        simp only [f2, Option.isSome_none]
        refine Inv.mend ?_
        rw [s.halts, hN] at f5
        simpa using f5
  | halt h =>
    have h' := events_HR P es h
    obtain ⟨hcase, _⟩ := halted_round P hP inp h'
    simp only [tick]
    rcases hcase with ⟨a1, a2, a3⟩ | ⟨a1, a2, a3⟩ | ⟨a1, a2, a3, a4, a5⟩
    · simp only [a1, Option.isSome_none]; exact Inv.halt (by simpa using a3)
    · simp only [a1, Option.isSome_none]; exact Inv.mend (by simpa using a3)
    · simp only [a1, Option.isSome_some, if_true]
      exact Inv.mend ⟨a3.1, a4, by rw [a3.2.1]; omega, a3.2.2, a5⟩
  | mend h =>
    obtain ⟨a1, a2, a3, a4, a5, a6⟩ := settled_tick P hP h.1 es inp
    rw [h.2.1] at a1 a4
    simp only [a1, Option.isSome_some, if_true]
    exact Inv.mend ⟨a3.1, a4, by rw [a3.2.1]; omega, a3.2.2, by rw [a5]; exact h.2.2.2.2⟩

/-- Any number of ticks with no new fault keep `Inv`, with the record as `ledger` says. -/
theorem inv_play (hP : Sound P) {N₀ : Nat} (ts : List (Tick E Tm Dt)) {g : Game V Q Tm}
    {T : St V} (h : Inv P N₀ g T) : Inv P N₀ (play P ts g) (ledger P ts T g) := by
  induction ts generalizing g T with
  | nil => exact h
  | cons t ts ih =>
    have := ih (inv_step P hP h t.es t.inp)
    simpa [play, ledger] using this

/-- The tick of the fault leaves `Inv`. -/
theorem inv_first (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g) (es : List (Ev E))
    (inp : Inp Tm Dt) (f : Fault V Q Tm) :
    Inv P g.book.halts (tick P es inp (some f) g).g
      (if (tick P es inp (some f) g).recorded.isSome then (tick P es inp none g).g.rt else g.rt) := by
  obtain ⟨e, hb, hsp, hst, c1, c2⟩ := clean_form P hg
  have hbook : g.book = g.bk 0 := settled_book P hg.1
  obtain ⟨A', b', _, s, htw, hout⟩ :=
    tick_fault_out P hP es inp g.rt (g.asks 0) (g.bk 0) (g.bf 0) hb c1 c2 hsp hst f
  rw [← e] at htw hout
  have hb' : b'.halt = none := by rw [s.halt, hb]
  obtain ⟨r1, r2, r3, r4, r5, _, _, _⟩ := ffW_39_clean P hP inp g.rt A' b' (g.bf 0) hb' c1 c2
  rw [htw, hbook]
  cases hout with
  | near h1 h2 h3 h4 h5 h6 h7 =>
    have : (tick P es inp (some f) g).recorded.isSome = true := by rw [h2, r1]; rfl
    simp only [this, if_true]
    exact Inv.near _ r3 rfl (by rw [r5, s.halts]) h5
  | found hf =>
    cases hf with
    | once why f1 f2 f3 f4 f5 f6 f7 =>
      obtain ⟨k1, k2, k3⟩ := once_clean P hP inp g.rt A' b' (g.bf 0) hb' c1 c2 f5
      have : (tick P es inp (some f) g).recorded.isSome = true := by rw [f2, r1]; rfl
      simp only [this, if_true]
      refine Inv.mend ⟨k1.1, ?_, by rw [k1.2.1]; omega, k1.2.2, by rw [k3, s.halts]⟩
      rw [k2, r4]; simp [ffW, wk]
    | halt why f1 f2 f3 f4 f5 f7 =>
      simp only [f2, Option.isSome_none]
      refine Inv.halt ?_
      rw [s.halts] at f5
      simpa using f5
    | mend why f1 f2 f3 f4 f5 f6 f7 =>
      simp only [f2, Option.isSome_none]
      refine Inv.mend ?_
      rw [s.halts] at f5
      simpa using f5

end
end Gate
