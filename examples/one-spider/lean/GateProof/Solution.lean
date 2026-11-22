/-
Proofs of the statements in `Challenge.lean`. Nothing outside this project is imported.

The work is in `Proofs/`: `FaultFree.lean` writes a round with no fault out step by step;
`Restore.lean` is about putting right; `Generic.lean` has what holds of a stretch of a
round whatever the round holds; `Cells.lean`, `Post.lean`, `Own.lean` and `Round.lean`
follow one fault through one round, for each kind of cell and each instant; `Ticks.lean`
and `Runs.lean` follow the rounds after it. Here the statements are put together.
-/
import GateProof.Proofs.Runs
import GateProof.Toy

set_option linter.unusedSectionVars false
set_option linter.deprecated false
set_option linter.unusedSimpArgs false
set_option linter.unusedVariables false

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)

/-! ### What the theorems start from -/

theorem newGame_clean (hP : Sound P) (now : Tm) : Clean P (newGame P now) := by
  have e : newGame P now = cleanG P (P.newState now) P.noAsks (newBook P now) none := by
    simp only [newGame, cleanG]
    congr 1
    funext i
    simp [born, freshOb, heldOf, Game.book, vote_const, newBook]
  rw [e]
  exact clean_cleanG P _ _ _ _ rfl (hP.new_canBe now).1 (hP.new_canBe now).2 rfl rfl

theorem event_keeps_clean (e : Ev E) {g : Game V Q Tm} (h : Clean P g) : Clean P (event P e g) := by
  obtain ⟨f, hb, hsp, hst, c1, c2⟩ := clean_form P h
  obtain ⟨A', b', e1, s, _, _⟩ := event_clean P e g.rt (g.asks 0) (g.bk 0) (g.bf 0) hb
  rw [f, e1]
  exact clean_cleanG P _ _ _ _ (by rw [s.halt, hb]) c1 c2 (by rw [s.spoiled, hsp])
    (by rw [s.stops, hst])

theorem reach_clean (hP : Sound P) {g : Game V Q Tm} (h : Reach P g) : Clean P g := by
  induction h with
  | new now => exact newGame_clean P hP now
  | event e _ ih => exact event_keeps_clean P e ih
  | round inp _ ih =>
    have := settled_tick P hP ih.1 [] inp
    exact this.2.2.1

theorem nofault_round (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) :
    let r := tick P es inp none g
    r.recorded = some (P.work g.rt (vote (events P es g).asks) r.dt r.now)
      ∧ r.found = none ∧ Clean P r.g ∧ r.recorded = some r.g.rt := by
  obtain ⟨a1, a2, a3, a4, _, _⟩ := settled_tick P hP hg.1 es inp
  exact ⟨a1, a2, a3, by rw [a1, a4]⟩

/-! ### T1. Nothing wrong is recorded -/

theorem T1 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) :
    (tick P es inp (some f) g).recorded = none
      ∨ (tick P es inp (some f) g).recorded = (tick P es inp none g).recorded := by
  obtain ⟨e, hb, hsp, hst, c1, c2⟩ := clean_form P hg
  obtain ⟨A', b', _, s, htw, hout⟩ :=
    tick_fault_out P hP es inp g.rt (g.asks 0) (g.bk 0) (g.bf 0) hb c1 c2 hsp hst f
  rw [← e] at htw hout
  rw [htw]
  cases hout with
  | near h1 h2 h3 h4 h5 h6 h7 => exact Or.inr h2
  | found hf =>
    cases hf with
    | once why f1 f2 f3 f4 f5 f6 f7 => exact Or.inr f2
    | halt why f1 f2 f3 f4 f5 f7 => exact Or.inl f2
    | mend why f1 f2 f3 f4 f5 f6 f7 => exact Or.inl f2

/-! ### T2. Put right -/

theorem T2 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) (ts : List (Tick E Tm Dt)) :
    let r₀ := tick P es inp (some f) g
    let T₀ := if r₀.recorded.isSome then (tick P es inp none g).g.rt else g.rt
    let gₙ := play P ts r₀.g
    gₙ.halted = false → g.book.halts < gₙ.book.halts →
      Settled P gₙ ∧ gₙ.rt = ledger P ts T₀ r₀.g := by
  intro r₀ T₀ gₙ h1 h2
  exact inv_settled P (inv_play P hP ts (inv_first P hP hg es inp f)) h1 h2

theorem T2_at_once (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) :
    let r := tick P es inp (some f) g
    let r' := tick P es inp none g
    r.found.isSome = true → r.ended = true → r.worked = true →
      r.g.sp = r'.g.sp ∧ r.g.ob = r'.g.ob ∧ r.g.rt = r'.g.rt ∧ r.g.rc = r'.g.rc
        ∧ r.g.bf = r'.g.bf ∧ r.g.asks = r'.g.asks
        ∧ ∀ k, r.g.bk k = { r'.g.bk k with halts := (r'.g.bk k).halts + 1,
                                           restarts := (r'.g.bk k).restarts + 1 } := by
  intro r r' h1 h2 h3
  obtain ⟨e, hb, hsp, hst, c1, c2⟩ := clean_form P hg
  obtain ⟨A', b', _, s, htw, hout⟩ :=
    tick_fault_out P hP es inp g.rt (g.asks 0) (g.bk 0) (g.bf 0) hb c1 c2 hsp hst f
  rw [← e] at htw hout
  cases hout with
  | near a1 a2 a3 a4 a5 a6 a7 =>
    have : r.found = none := a1
    rw [this] at h1; cases h1
  | found hf =>
    cases hf with
    | once why f1 f2 f3 f4 f5 f6 f7 =>
      have e5 : r.g = bump r'.g := by
        show (tick P es inp (some f) g).g = bump (tick P es inp none g).g
        rw [f5, htw]
      rw [e5]
      exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, fun _ => rfl⟩
    | halt why f1 f2 f3 f4 f5 f7 =>
      have : r.ended = false := f7
      rw [this] at h2; cases h2
    | mend why f1 f2 f3 f4 f5 f6 f7 =>
      have : r.worked = false := f6
      rw [this] at h3; cases h3

/-- The count of halts goes up by one in the tick of the fault exactly when the fault is
found in it. -/
theorem found_counts (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) :
    let r := tick P es inp (some f) g
    r.g.book.halts = g.book.halts + (if r.found.isSome then 1 else 0) := by
  intro r
  obtain ⟨e, hb, hsp, hst, c1, c2⟩ := clean_form P hg
  have hbook : g.book = g.bk 0 := settled_book P hg.1
  obtain ⟨A', b', _, s, htw, hout⟩ :=
    tick_fault_out P hP es inp g.rt (g.asks 0) (g.bk 0) (g.bf 0) hb c1 c2 hsp hst f
  rw [← e] at htw hout
  have hb' : b'.halt = none := by rw [s.halt, hb]
  rw [hbook]
  cases hout with
  | near a1 a2 a3 a4 a5 a6 a7 =>
    have hn : NearG r.g (ffW P inp g.rt A' b' (g.bf 0) 39).g := a5
    rw [ffW, wk_39_g] at hn
    have hf : r.found = none := a1
    rw [nearG_book P hn, hf]
    simp [bookAt_20, s.halts]
  | found hf =>
    cases hf with
    | once why f1 f2 f3 f4 f5 f6 f7 =>
      obtain ⟨k1, _, k3⟩ := once_clean P hP inp g.rt A' b' (g.bf 0) hb' c1 c2 f5
      have hf : r.found = some why := f1
      rw [settled_book P k1.1, k3, hf, s.halts]; rfl
    | halt why f1 f2 f3 f4 f5 f7 =>
      obtain ⟨bH, hh, β', hbk, _, _, _, _, h5, _⟩ := f5
      have hf : r.found = some why := f1
      have : r.g.book = bH := by rw [Game.book, hbk]; exact vote_const _
      rw [this, h5, hf, s.halts]; rfl
    | mend why f1 f2 f3 f4 f5 f6 f7 =>
      have hf : r.found = some why := f1
      rw [(mended_book P f5).2.2, hf, s.halts]; rfl

/-! ### T3. Never stuck -/

theorem T3 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) (ts : List (Tick E Tm Dt)) :
    (play P ts (tick P es inp (some f) g).g).stuck = false :=
  inv_not_stuck P (inv_play P hP ts (inv_first P hP hg es inp f))

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
  intro g' r h hh hcond
  have hinv := inv_play P hP ts (inv_first P hP hg es inp f)
  cases hinv with
  | near G hG hT hN hn =>
    -- nothing is halted: there is no halt to end
    obtain ⟨e, hb, _⟩ := clean_form P hG
    rw [e] at hn
    obtain ⟨A', b', e1, s, d, c⟩ := events_clean P t.es G.rt (G.asks 0) (G.bk 0) (G.bf 0) hb
    have hbk : g'.book = b' := by
      rcases hn with ⟨c0, hc0⟩ | ⟨Z, obx, x, hx⟩
      · obtain ⟨c', hc'⟩ := c c0
        show (events P t.es (play P ts (tick P es inp (some f) g).g)).book = b'
        rw [hc0, hc']
        exact nearG_book P (Or.inl ⟨c', rfl⟩)
      · show (events P t.es (play P ts (tick P es inp (some f) g).g)).book = b'
        rw [hx]
        have := d Z obx x
        simp only [dirtyG] at this
        show (events P t.es ⟨Z, obx, G.rt, G.rt, fun _ => G.bk 0, fun _ => x, fun _ => G.asks 0⟩).book = b'
        rw [this]; simp [Game.book, vote_const]
    rw [hbk, s.halt, hb] at hh
    cases hh
  | halt hr => exact (halted_round P hP t.inp (events_HR P t.es hr)).2 h hh hcond
  | mend hm =>
    obtain ⟨e1, hb⟩ := (⟨settled_form P hm.1, hm.1.noHalt⟩ :
      _ ∧ ((play P ts (tick P es inp (some f) g).g).bk 0).halt = none)
    obtain ⟨A', b', e2, s, _, _⟩ := events_clean P t.es _ _ _ _ hb
    have hbk : g'.book = b' := by
      show (events P t.es (play P ts (tick P es inp (some f) g).g)).book = b'
      rw [e1, e2]; simp [cleanG_book]
    rw [hbk, s.halt, hb] at hh
    cases hh

/-! ### T4. Found, or gone -/

theorem T4 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) (t : Tick E Tm Dt) :
    let r₀ := tick P es inp (some f) g
    let r₁ := tick P t.es t.inp none r₀.g
    let r₀' := tick P es inp none g
    let r₁' := tick P t.es t.inp none r₀'.g
    r₀.found.isSome = true ∨ r₁.found.isSome = true
      ∨ (r₁.g = r₁'.g ∧ r₀.recorded = r₀'.recorded ∧ r₁.recorded = r₁'.recorded) := by
  intro r₀ r₁ r₀' r₁'
  obtain ⟨e, hb, hsp, hst, c1, c2⟩ := clean_form P hg
  obtain ⟨A', b', _, s, htw, hout⟩ :=
    tick_fault_out P hP es inp g.rt (g.asks 0) (g.bk 0) (g.bf 0) hb c1 c2 hsp hst f
  rw [← e] at htw hout
  have hb' : b'.halt = none := by rw [s.halt, hb]
  cases hout with
  | found hf =>
    left
    cases hf with
    | once why f1 f2 f3 f4 f5 f6 f7 => show (tick P es inp (some f) g).found.isSome = true; rw [f1]; rfl
    | halt why f1 f2 f3 f4 f5 f7 => show (tick P es inp (some f) g).found.isSome = true; rw [f1]; rfl
    | mend why f1 f2 f3 f4 f5 f6 f7 => show (tick P es inp (some f) g).found.isSome = true; rw [f1]; rfl
  | near a1 a2 a3 a4 a5 a6 a7 =>
    right
    obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes g.rt A' (Inp.dt P inp b') (Inp.now P inp b') c1 c2
    have hn : NearG r₀.g (ffW P inp g.rt A' b' (g.bf 0) 39).g := a5
    have hG : (ffW P inp g.rt A' b' (g.bf 0) 39).g = cleanG P
        (P.work g.rt A' (Inp.dt P inp b') (Inp.now P inp b')) P.noAsks
        { bookAt P inp b' 20 with spoiled := 0, stops := 0 } (some g.rt) := by
      rw [ffW, wk_39_g]; simp
    rw [hG] at hn
    obtain ⟨A'', b'', _, _, htw1, _, hcase⟩ := near_tick P hP t.es t.inp
      (P.work g.rt A' (Inp.dt P inp b') (Inp.now P inp b')) P.noAsks
      { bookAt P inp b' 20 with spoiled := 0, stops := 0 } (some g.rt)
      (by simp [bookAt_20, hb']) w2 w3 rfl rfl hn
    have e1 : r₁' = ffW P t.inp (P.work g.rt A' (Inp.dt P inp b') (Inp.now P inp b')) A'' b''
        (some g.rt) 39 := by
      show tick P t.es t.inp none (tick P es inp none g).g = _
      rw [htw, hG]; exact htw1
    rcases hcase with ex | fnd
    · right
      have e2 : r₁ = r₁' := by rw [e1]; exact ex
      refine ⟨by rw [e2], ?_, by rw [e2]⟩
      show (tick P es inp (some f) g).recorded = (tick P es inp none g).recorded
      rw [a2, htw]
    · left
      cases fnd with
      | once why f1 f2 f3 f4 f5 f6 f7 => show (tick P t.es t.inp none r₀.g).found.isSome = true; rw [f1]; rfl
      | halt why f1 f2 f3 f4 f5 f7 => show (tick P t.es t.inp none r₀.g).found.isSome = true; rw [f1]; rfl
      | mend why f1 f2 f3 f4 f5 f6 f7 => show (tick P t.es t.inp none r₀.g).found.isSome = true; rw [f1]; rfl

end

/-! ### T5. One after another -/

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)

/-- What holds of the game in each phase of a run with spaced faults, with `T` the record
as the recorded rounds have made it. -/
def J (ph : Phase) (g : Game V Q Tm) (T : St V) : Prop :=
  match ph with
  | .ready => Clean P g ∧ g.rt = T
  | .landed => ∃ G, Clean P G ∧ G.rt = T ∧ NearG g G
  | .halting => ∃ N, HR P g T N
  | .ended => ∃ N, Mended P g T N

theorem clean_halted {g : Game V Q Tm} (h : Clean P g) : g.halted = false ∧ g.stuck = false := by
  have := mended_book P (clean_mended P h)
  exact ⟨this.1, this.2.1⟩

theorem near_halted {g G : Game V Q Tm} (hG : Clean P G) (h : NearG g G) :
    g.halted = false ∧ g.stuck = false := by
  obtain ⟨e, hb, _⟩ := clean_form P hG
  rw [e] at h
  simp [Game.halted, Game.stuck, nearG_book P h, hb]

theorem j_stuck {ph : Phase} {g : Game V Q Tm} {T : St V} (h : J P ph g T) : g.stuck = false := by
  cases ph with
  | ready => exact (clean_halted P h.1).2
  | landed => obtain ⟨G, hG, _, hn⟩ := h; exact (near_halted P hG hn).2
  | halting => obtain ⟨N, hr⟩ := h; exact (HR.book P hr).2
  | ended => obtain ⟨N, hm⟩ := h; exact (mended_book P hm).2.1

/-- What a tick with no fault does, by phase. -/
theorem j_step_none (hP : Sound P) {ph : Phase} {g : Game V Q Tm} {T : St V} (h : J P ph g T)
    (hph : ph ≠ Phase.ready ∨ True) (es : List (Ev E)) (inp : Inp Tm Dt) (fl : Bool)
    (hfl : fl = true → ph ≠ Phase.ready → False) (hfl2 : fl = false) :
    J P (ph.next fl (tick P es inp none g)) (tick P es inp none g).g
      (if (tick P es inp none g).recorded.isSome
        then P.work T (vote (events P es g).asks) (tick P es inp none g).dt
          (tick P es inp none g).now
        else T) := by
  subst hfl2
  cases ph with
  | ready =>
    obtain ⟨a1, a2, a3, a4, a5, a6⟩ := settled_tick P hP h.1.1 es inp
    rw [h.2] at a1 a4
    simp only [a1, Option.isSome_some, if_true, Phase.next]
    exact ⟨a3, a4⟩
  | landed =>
    obtain ⟨G, hG, hT, hn⟩ := h
    obtain ⟨e, hb, hsp, hst, c1, c2⟩ := clean_form P hG
    rw [hT] at e c1 c2
    rw [e] at hn
    obtain ⟨A', b', _, s, _, hv, hcase⟩ :=
      near_tick P hP es inp T (G.asks 0) (G.bk 0) (G.bf 0) hb c1 c2 hsp hst hn
    have hb' : b'.halt = none := by rw [s.halt, hb]
    rcases hcase with ex | f
    · obtain ⟨r1, r2, r3, r4, r5, _, _, r8⟩ := ffW_39_clean P hP inp T A' b' (G.bf 0) hb' c1 c2
      rw [ex, hv]
      simp only [r1, r2, r8, Option.isSome_some, Option.isSome_none, if_true, Phase.next]
      exact ⟨r3, r4⟩
    · cases f with
      | once why f1 f2 f3 f4 f5 f6 f7 =>
        obtain ⟨k1, k2, k3⟩ := once_clean P hP inp T A' b' (G.bf 0) hb' c1 c2 f5
        have hrec : (tick P es inp none g).recorded
            = some (P.work T A' (Inp.dt P inp b') (Inp.now P inp b')) := by
          rw [f2]; simp [ffW, wk, Params.work]
        rw [hv, f3, f4]
        simp only [hrec, f1, (clean_halted P k1).1, Option.isSome_some, if_true, Phase.next]
        exact ⟨k1, k2⟩
      | halt why f1 f2 f3 f4 f5 f7 =>
        simp only [f2, f1, (HR.book P f5).1, Option.isSome_none, if_true, Phase.next]
        exact ⟨_, f5⟩
      | mend why f1 f2 f3 f4 f5 f6 f7 =>
        simp only [f2, f1, (mended_book P f5).1, Option.isSome_none, Option.isSome_some, if_true,
          Phase.next]
        exact ⟨_, f5⟩
  | halting =>
    obtain ⟨N, hr⟩ := h
    have h' := events_HR P es hr
    obtain ⟨hcase, _⟩ := halted_round P hP inp h'
    simp only [tick]
    rcases hcase with ⟨a1, a2, a3⟩ | ⟨a1, a2, a3⟩ | ⟨a1, a2, a3, a4, a5⟩
    · simp only [a1, (HR.book P a3).1, Option.isSome_none, if_true, Phase.next]
      exact ⟨_, a3⟩
    · simp only [a1, (mended_book P a3).1, Option.isSome_none, Phase.next]
      exact ⟨_, a3⟩
    · simp only [a1, (clean_halted P a3).1, Option.isSome_some, if_true, Phase.next]
      exact ⟨a3, a4⟩
  | ended =>
    obtain ⟨N, hm⟩ := h
    obtain ⟨a1, a2, a3, a4, a5, a6⟩ := settled_tick P hP hm.1 es inp
    rw [hm.2.1] at a1 a4
    simp only [a1, Option.isSome_some, if_true, Phase.next]
    exact ⟨a3, a4⟩

/-- What the tick of a fault does, from a clean game. -/
theorem j_step_fault (hP : Sound P) {g : Game V Q Tm} {T : St V} (h : J P Phase.ready g T)
    (es : List (Ev E)) (inp : Inp Tm Dt) (f : Fault V Q Tm) :
    J P (Phase.ready.next true (tick P es inp (some f) g)) (tick P es inp (some f) g).g
      (if (tick P es inp (some f) g).recorded.isSome
        then P.work T (vote (events P es g).asks) (tick P es inp (some f) g).dt
          (tick P es inp (some f) g).now
        else T) := by
  obtain ⟨hg, hT⟩ := h
  obtain ⟨e, hb, hsp, hst, c1, c2⟩ := clean_form P hg
  rw [hT] at e c1 c2
  obtain ⟨A', b', eev, s, htw, hout⟩ :=
    tick_fault_out P hP es inp T (g.asks 0) (g.bk 0) (g.bf 0) hb c1 c2 hsp hst f
  rw [← e] at htw hout eev
  have hv : vote (events P es g).asks = A' := by rw [eev]; simp [cleanG, vote_const]
  have hb' : b'.halt = none := by rw [s.halt, hb]
  obtain ⟨r1, r2, r3, r4, r5, _, _, r8⟩ := ffW_39_clean P hP inp T A' b' (g.bf 0) hb' c1 c2
  have hdt : (ffW P inp T A' b' (g.bf 0) 39).dt = Inp.dt P inp b' := by simp [ffW, wk]
  have hnow : (ffW P inp T A' b' (g.bf 0) 39).now = Inp.now P inp b' := by simp [ffW, wk]
  rw [hdt, hnow] at r1 r4
  rw [hv]
  cases hout with
  | near h1 h2 h3 h4 h5 h6 h7 =>
    have hrec : (tick P es inp (some f) g).recorded
        = some (P.work T A' (Inp.dt P inp b') (Inp.now P inp b')) := by rw [h2, r1]
    rw [h3, h4]
    simp only [hrec, h1, (near_halted P r3 h5).1, Option.isSome_some, Option.isSome_none, if_true,
      Phase.next]
    exact ⟨_, r3, r4, h5⟩
  | found hf =>
    cases hf with
    | once why f1 f2 f3 f4 f5 f6 f7 =>
      obtain ⟨k1, k2, k3⟩ := once_clean P hP inp T A' b' (g.bf 0) hb' c1 c2 f5
      have hrec : (tick P es inp (some f) g).recorded
          = some (P.work T A' (Inp.dt P inp b') (Inp.now P inp b')) := by rw [f2, r1]
      rw [f3, f4]
      simp only [hrec, f1, (clean_halted P k1).1, Option.isSome_some, if_true, Phase.next]
      exact ⟨k1, k2⟩
    | halt why f1 f2 f3 f4 f5 f7 =>
      simp only [f2, f1, (HR.book P f5).1, Option.isSome_none, if_true, Phase.next]
      exact ⟨_, f5⟩
    | mend why f1 f2 f3 f4 f5 f6 f7 =>
      simp only [f2, f1, (mended_book P f5).1, Option.isSome_none, Option.isSome_some, if_true,
        Phase.next]
      exact ⟨_, f5⟩

theorem t5_aux (hP : Sound P) (ts : List (FTick V Q E Tm Dt)) (ph : Phase) (g : Game V Q Tm)
    (T : St V) (hj : J P ph g T) (hs : Spaced P ts ph g) :
    (playF P ts ph g).2.stuck = false
      ∧ ((playF P ts ph g).1 = Phase.ready →
          Clean P (playF P ts ph g).2 ∧ (playF P ts ph g).2.rt = ledgerF P ts T g)
      ∧ ((playF P ts ph g).1 = Phase.ended →
          Settled P (playF P ts ph g).2 ∧ (playF P ts ph g).2.rt = ledgerF P ts T g) := by
  induction ts generalizing ph g T with
  | nil =>
    refine ⟨j_stuck P hj, ?_, ?_⟩
    · intro h
      simp only [playF] at h
      subst h
      exact hj
    · intro h
      simp only [playF] at h
      subst h
      obtain ⟨N, hm⟩ := hj
      exact ⟨hm.1, hm.2.1⟩
  | cons t ts ih =>
    obtain ⟨hsp, hrest⟩ := hs
    simp only [playF, ledgerF]
    cases hf : t.fault with
    | none =>
      rw [hf] at hrest
      have := j_step_none P hP hj (Or.inr trivial) t.es t.inp false (by intro h; cases h) rfl
      simp only [hf, Option.isSome_none] at hrest ⊢
      exact ih _ _ _ this hrest
    | some f =>
      have hph : ph = Phase.ready := hsp (by rw [hf]; rfl)
      subst hph
      rw [hf] at hrest
      have := j_step_fault P hP hj t.es t.inp f
      simp only [hf, Option.isSome_some] at hrest ⊢
      exact ih _ _ _ this hrest

theorem T5 (hP : Sound P) {g : Game V Q Tm} (hg : Clean P g)
    (ts : List (FTick V Q E Tm Dt)) (hs : Spaced P ts Phase.ready g) :
    let end_ := playF P ts Phase.ready g
    end_.2.stuck = false
      ∧ (end_.1 = Phase.ready → Clean P end_.2 ∧ end_.2.rt = ledgerF P ts g.rt g)
      ∧ (end_.1 = Phase.ended → Settled P end_.2 ∧ end_.2.rt = ledgerF P ts g.rt g) :=
  t5_aux P hP ts Phase.ready g g.rt ⟨hg, rfl⟩ hs

end

/-! ### T6. The edge is where it is said to be -/

namespace Toy

/-- The toy game meets what is assumed of the unknowns (Y1 to Y4). -/
theorem sound : Sound P := by
  refine ⟨fun _ _ _ _ _ => rfl, fun _ => rfl, ?_, ?_⟩
  · intro s q dt now h1 h2
    have e3 : ((3 : Part) : Nat) = 3 := rfl
    have e4 : ((4 : Part) : Nat) = 4 := rfl
    simp [P, Params.work, e3, e4] at h1 ⊢
    refine ⟨by rw [h1]; decide, h1, ?_⟩
    exact Nat.le_trans (Nat.le_add_right _ 1) (Nat.le_add_right _ _)
  · intro now
    simp [P]

set_option maxRecDepth 100000 in
theorem T6_wrong_recorded :
    let twoFaults := (Cell.rc 4 99).hit ((Cell.rt 4 99).hit base)
    let r := round P (.clock 4) .none twoFaults
    let r' := round P (.clock 4) .none base
    r.g.halted = false ∧ r.recorded.isSome = true ∧ r.recorded ≠ r'.recorded := by
  decide +kernel

set_option maxRecDepth 100000 in
theorem T6_stuck :
    let twoFaults := (Cell.rc 4 99).hit ((Cell.rt 4 98).hit base)
    (round P (.clock 4) .none twoFaults).g.stuck = true := by
  decide +kernel

set_option maxRecDepth 100000 in
theorem T6_spacing :
    let r₁ := round P (.clock 4) (.cell .world (.rc 4 99)) base
    let r₂ := round P (.clock 5) (.cell .world (.rc 4 99)) r₁.g
    r₁.g.stuck = false ∧ r₂.ended = true ∧ r₂.g.stuck = true := by
  decide +kernel

end Toy

end Gate
