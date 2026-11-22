/-
What happens between two rounds (E1 to E3) and then a round: on a game in which
everything agrees, on one with one cell changed, on one that is halted and can be put
right.
-/
import GateProof.Proofs.Round

set_option linter.unusedSectionVars false
set_option linter.deprecated false
set_option linter.unusedSimpArgs false
set_option linter.unusedVariables false

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)

/-! ### Between two rounds -/

/-- The clean game with the state, the observers and `before` replaced. -/
def dirtyG (T : St V) (A : Q) (b : Book V Tm) (Z : St V) (obx : Who → Observer V)
    (x : Option (St V)) : Game V Q Tm :=
  { sp := Z, ob := obx, rt := T, rc := T, bk := fun _ => b, bf := fun _ => x, asks := fun _ => A }

/-- What one thing between two rounds does to a book that holds no halt: nothing but,
perhaps, change the setting. -/
structure SameBook (b b' : Book V Tm) : Prop where
  halt : b'.halt = b.halt
  halts : b'.halts = b.halts
  restarts : b'.restarts = b.restarts
  spoiled : b'.spoiled = b.spoiled
  stops : b'.stops = b.stops
  clock : b'.clock = b.clock
  time : b'.time = b.time
  rounds : b'.rounds = b.rounds
  rest : b'.rest = b.rest

theorem SameBook.refl (b : Book V Tm) : SameBook b b := ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem SameBook.trans {b b' b'' : Book V Tm} (h : SameBook b b') (h' : SameBook b' b'') :
    SameBook b b'' :=
  ⟨h'.halt.trans h.halt, h'.halts.trans h.halts, h'.restarts.trans h.restarts,
   h'.spoiled.trans h.spoiled, h'.stops.trans h.stops, h'.clock.trans h.clock,
   h'.time.trans h.time, h'.rounds.trans h.rounds, h'.rest.trans h.rest⟩

/-- E1 to E3 on a game in which everything agrees: everything still agrees. The same
happens to the lists and the books when one cell is changed (`c`), or when the state, the
observers and `before` are anything (`dirtyG`). -/
theorem event_clean (e : Ev E) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V))
    (hb : b.halt = none) :
    ∃ A' b', event P e (cleanG P T A b β) = cleanG P T A' b' β ∧ SameBook b b'
      ∧ (∀ Z obx x, event P e (dirtyG T A b Z obx x) = dirtyG T A' b' Z obx x)
      ∧ (∀ c : Cell V Q Tm, ∃ c' : Cell V Q Tm,
          event P e (c.hit (cleanG P T A b β)) = c'.hit (cleanG P T A' b' β)) := by
  cases e with
  | ask e =>
    by_cases ht : P.taken false A e = true
    · refine ⟨P.takeDown false e A, b, ?_, SameBook.refl b, ?_, ?_⟩
      · simp [event, Game.stuck, Game.halted, Game.book, cleanG, vote_const, hb, ht]
      · intro Z obx x
        simp [event, Game.stuck, Game.halted, Game.book, dirtyG, vote_const, hb, ht]
      · intro c
        cases c with
        | asks k q =>
          refine ⟨.asks k (P.takeDown false e q), ?_⟩
          simp [event, Game.stuck, Game.halted, Game.book, cleanG, Cell.hit, vote_const, vote_hit,
            hb, ht]
          funext j; by_cases hj : j = k <;> simp [hj]
        | sp p v =>
          exact ⟨.sp p v, by simp [event, Game.stuck, Game.halted, Game.book, cleanG, Cell.hit,
            vote_const, hb, ht]⟩
        | ob i o =>
          exact ⟨.ob i o, by simp [event, Game.stuck, Game.halted, Game.book, cleanG, Cell.hit,
            vote_const, hb, ht]⟩
        | rt p v =>
          exact ⟨.rt p v, by simp [event, Game.stuck, Game.halted, Game.book, cleanG, Cell.hit,
            vote_const, hb, ht]⟩
        | rc p v =>
          exact ⟨.rc p v, by simp [event, Game.stuck, Game.halted, Game.book, cleanG, Cell.hit,
            vote_const, hb, ht]⟩
        | bk k x =>
          exact ⟨.bk k x, by simp [event, Game.stuck, Game.halted, Game.book, cleanG, Cell.hit,
            vote_const, vote_hit, hb, ht]⟩
        | bf k x =>
          exact ⟨.bf k x, by simp [event, Game.stuck, Game.halted, Game.book, cleanG, Cell.hit,
            vote_const, hb, ht]⟩
    · refine ⟨A, b, ?_, SameBook.refl b, ?_, ?_⟩
      · simp [event, Game.stuck, Game.halted, Game.book, cleanG, vote_const, hb, ht]
      · intro Z obx x
        simp [event, Game.stuck, Game.halted, Game.book, dirtyG, vote_const, hb, ht]
      · intro c
        refine ⟨c, ?_⟩
        cases c <;>
          simp [event, Game.stuck, Game.halted, Game.book, cleanG, Cell.hit, vote_const, vote_hit,
            hb, ht]
  | putRight =>
    have hbb : ({ b with halt := b.halt.map fun h => { h with asked := true } } : Book V Tm) = b := by
      cases b; simp_all
    refine ⟨A, b, ?_, SameBook.refl b, ?_, ?_⟩
    · simp [event, keep, cleanG, hbb]
    · intro Z obx x; simp [event, keep, dirtyG, hbb]
    · intro c
      cases c with
      | bk k x =>
        refine ⟨.bk k { x with halt := x.halt.map fun h => { h with asked := true } }, ?_⟩
        simp [event, keep, cleanG, Cell.hit]
        funext j; by_cases hj : j = k <;> simp [hj, hbb]
      | sp p v => exact ⟨.sp p v, by simp [event, keep, cleanG, Cell.hit, hbb]⟩
      | ob i o => exact ⟨.ob i o, by simp [event, keep, cleanG, Cell.hit, hbb]⟩
      | rt p v => exact ⟨.rt p v, by simp [event, keep, cleanG, Cell.hit, hbb]⟩
      | rc p v => exact ⟨.rc p v, by simp [event, keep, cleanG, Cell.hit, hbb]⟩
      | bf k x => exact ⟨.bf k x, by simp [event, keep, cleanG, Cell.hit, hbb]⟩
      | asks k q => exact ⟨.asks k q, by simp [event, keep, cleanG, Cell.hit, hbb]⟩
  | setHow h =>
    refine ⟨A, { b with how := h }, ?_, ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩, ?_, ?_⟩
    · simp [event, keep, cleanG]
    · intro Z obx x; simp [event, keep, dirtyG]
    · intro c
      cases c with
      | bk k x =>
        refine ⟨.bk k { x with how := h }, ?_⟩
        simp [event, keep, cleanG, Cell.hit]
        funext j; by_cases hj : j = k <;> simp [hj]
      | sp p v => exact ⟨.sp p v, by simp [event, keep, cleanG, Cell.hit]⟩
      | ob i o => exact ⟨.ob i o, by simp [event, keep, cleanG, Cell.hit]⟩
      | rt p v => exact ⟨.rt p v, by simp [event, keep, cleanG, Cell.hit]⟩
      | rc p v => exact ⟨.rc p v, by simp [event, keep, cleanG, Cell.hit]⟩
      | bf k x => exact ⟨.bf k x, by simp [event, keep, cleanG, Cell.hit]⟩
      | asks k q => exact ⟨.asks k q, by simp [event, keep, cleanG, Cell.hit]⟩

/-- Several things between two rounds, on a game in which everything agrees. -/
theorem events_clean (es : List (Ev E)) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V))
    (hb : b.halt = none) :
    ∃ A' b', events P es (cleanG P T A b β) = cleanG P T A' b' β ∧ SameBook b b'
      ∧ (∀ Z obx x, events P es (dirtyG T A b Z obx x) = dirtyG T A' b' Z obx x)
      ∧ (∀ c : Cell V Q Tm, ∃ c' : Cell V Q Tm,
          events P es (c.hit (cleanG P T A b β)) = c'.hit (cleanG P T A' b' β)) := by
  induction es generalizing A b with
  | nil => exact ⟨A, b, rfl, SameBook.refl b, fun _ _ _ => rfl, fun c => ⟨c, rfl⟩⟩
  | cons e es ih =>
    obtain ⟨A₁, b₁, e1, s1, d1, c1⟩ := event_clean P e T A b β hb
    obtain ⟨A₂, b₂, e2, s2, d2, c2⟩ := ih A₁ b₁ (by rw [s1.halt, hb])
    refine ⟨A₂, b₂, ?_, s1.trans s2, ?_, ?_⟩
    · simp only [events, List.foldl] at e2 ⊢
      rw [e1]; exact e2
    · intro Z obx x
      have := d2 Z obx x
      simp only [events, List.foldl] at this ⊢
      rw [d1]; exact this
    · intro c
      obtain ⟨c', hc'⟩ := c1 c
      obtain ⟨c'', hc''⟩ := c2 c'
      refine ⟨c'', ?_⟩
      simp only [events, List.foldl] at hc'' ⊢
      rw [hc']; exact hc''

theorem events_append (es₁ es₂ : List (Ev E)) (g : Game V Q Tm) :
    events P (es₁ ++ es₂) g = events P es₂ (events P es₁ g) := by
  simp [events, List.foldl_append]

theorem vote_asks_hit (c : Cell V Q Tm) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V)) :
    vote (c.hit (cleanG P T A b β)).asks = A := by
  cases c <;> simp [Cell.hit, cleanG, vote_const, vote_hit]

/-! ### The forms of a game -/

theorem clean_form {g : Game V Q Tm} (h : Clean P g) :
    g = cleanG P g.rt (g.asks 0) (g.bk 0) (g.bf 0) ∧ (g.bk 0).halt = none
      ∧ (g.bk 0).spoiled = 0 ∧ (g.bk 0).stops = 0
      ∧ P.canBe₁ g.rt = true ∧ P.canBe₂ g.rt = true :=
  ⟨settled_form P h.1, h.1.noHalt, h.2.1, h.2.2, h.1.canBe.1, h.1.canBe.2⟩

theorem clean_cleanG (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V))
    (hb : b.halt = none) (h1 : P.canBe₁ T = true) (h2 : P.canBe₂ T = true)
    (hsp : b.spoiled = 0) (hst : b.stops = 0) : Clean P (cleanG P T A b β) :=
  ⟨settled_cleanG P T A b β hb h1 h2, hsp, hst⟩

theorem wk_39_g (T : St V) (A : Q) (bb : Book V Tm) (β : Option (St V)) (t0 : Tm) (dt : Dt)
    (now : Tm) (bh : Bool) (fnd : Option Cause) (ended : Bool) :
    (wk P T A bb β t0 dt now bh fnd ended 39).g
      = cleanG P (P.work T A dt now) P.noAsks
          { bb with spoiled := 0, stops := if bh = true then bb.stops else 0 } (some T) := by
  simp [wk, cleanG, Params.work]

theorem ffW_39_beta (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (β x : Option (St V)) :
    ffW P inp T A b x 39 = ffW P inp T A b β 39 := by
  simp [ffW, wk]

/-- What the round with no fault leaves, from a game in which everything agrees. -/
theorem ffW_39_clean (hP : Sound P) (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm)
    (β : Option (St V)) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) :
    let r := ffW P inp T A b β 39
    r.recorded = some (P.work T A r.dt r.now) ∧ r.found = none ∧ Clean P r.g
      ∧ r.g.rt = P.work T A r.dt r.now ∧ (r.g.bk 0).halts = b.halts ∧ r.ended = false
      ∧ r.worked = true ∧ r.g.halted = false := by
  obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes T A (Inp.dt P inp b) (Inp.now P inp b) hc1 hc2
  refine ⟨by simp [ffW, wk, Params.work], by simp [ffW, wk], ?_, by simp [ffW, wk, Params.work],
    by simp [ffW, wk, bookAt_20], by simp [ffW, wk], by simp [ffW, wk], ?_⟩
  · rw [ffW, wk_39_g]
    exact clean_cleanG P _ _ _ _ (by simp [bookAt_20, hb]) w2 w3 rfl (by simp)
  · rw [ffW, wk_39_g]
    simp [Game.halted, cleanG_book, bookAt_20, hb]

/-! ### A tick with no fault, from a game in which everything agrees -/

/-- What happens between two rounds and a round with no fault, from the clean game. -/
theorem tick_none_clean (hP : Sound P) (es : List (Ev E)) (inp : Inp Tm Dt) (T : St V) (A : Q)
    (b : Book V Tm) (β : Option (St V)) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) :
    ∃ A' b', events P es (cleanG P T A b β) = cleanG P T A' b' β ∧ SameBook b b'
      ∧ tick P es inp none (cleanG P T A b β) = ffW P inp T A' b' β 39 := by
  obtain ⟨A', b', e, s, _, _⟩ := events_clean P es T A b β hb
  refine ⟨A', b', e, s, ?_⟩
  simp only [tick]
  rw [e]
  exact round_none P inp T A' b' β hP (by rw [s.halt, hb]) hc1 hc2

/-- A tick with no fault, from a game in which everything agrees (a round may have been
refused since the last one recorded): the round is recorded, what is recorded is what the
work with no fault makes of the record and the voted list, and the game it leaves is
clean. -/
theorem settled_tick (hP : Sound P) {g : Game V Q Tm} (hg : Settled P g)
    (es : List (Ev E)) (inp : Inp Tm Dt) :
    let r := tick P es inp none g
    r.recorded = some (P.work g.rt (vote (events P es g).asks) r.dt r.now) ∧ r.found = none
      ∧ Clean P r.g ∧ r.g.rt = P.work g.rt (vote (events P es g).asks) r.dt r.now
      ∧ (r.g.bk 0).halts = (g.bk 0).halts ∧ r.g.halted = false := by
  have hf := settled_form P hg
  obtain ⟨A', b', e, s, ht⟩ := tick_none_clean P hP es inp g.rt (g.asks 0) (g.bk 0) (g.bf 0)
    hg.noHalt hg.canBe.1 hg.canBe.2
  rw [← hf] at e ht
  have hv : vote (events P es g).asks = A' := by rw [e]; simp [cleanG, vote_const]
  obtain ⟨c1, c2, c3, c4, c5, _, _, c8⟩ := ffW_39_clean P hP inp g.rt A' b' (g.bf 0)
    (by rw [s.halt]; exact hg.noHalt) hg.canBe.1 hg.canBe.2
  simp only
  rw [ht, hv]
  exact ⟨c1, c2, c3, c4, by rw [c5, s.halts], c8⟩

/-! ### The tick of the fault -/

/-- The tick of the fault, from the clean game: its outcome is one of those `Out`
allows, measured against the same tick with no fault (`ffW ... 39`). For a fault between
the rounds, or in an answer: nothing has changed at all, or the fault is found. -/
theorem tick_fault_out (hP : Sound P) (es : List (Ev E)) (inp : Inp Tm Dt) (T : St V) (A : Q)
    (b : Book V Tm) (β : Option (St V)) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) (f : Fault V Q Tm) :
    ∃ A' b', events P es (cleanG P T A b β) = cleanG P T A' b' β ∧ SameBook b b'
      ∧ tick P es inp none (cleanG P T A b β) = ffW P inp T A' b' β 39
      ∧ Out P inp T A' b' β (tick P es inp (some f) (cleanG P T A b β)) := by
  obtain ⟨A', b', e, s, ht⟩ := tick_none_clean P hP es inp T A b β hb hc1 hc2
  have hb' : b'.halt = none := by rw [s.halt, hb]
  have hsp' : b'.spoiled = 0 := by rw [s.spoiled, hsp]
  have hst' : b'.stops = 0 := by rw [s.stops, hst]
  refine ⟨A', b', e, s, ht, ?_⟩
  cases f with
  | between n c =>
    simp only [tick]
    obtain ⟨A₁, b₁, e1, s1, _, _⟩ := events_clean P (es.take n) T A b β hb
    obtain ⟨A₂, b₂, e2, s2, _, c2⟩ := events_clean P (es.drop n) T A₁ b₁ β (by rw [s1.halt, hb])
    obtain ⟨c', hc'⟩ := c2 c
    have e3 : cleanG P T A₂ b₂ β = cleanG P T A' b' β := by
      rw [← e2, ← e1, ← events_append, List.take_append_drop, e]
    rw [e1, hc', e3]
    rcases round_hit_out P inp T A' b' β hP hb' hc1 hc2 hsp' hst' c' with h | h
    · exact out_same P inp T A' b' β _ h
    · exact Out.found h
  | before st c =>
    simp only [tick]
    rw [e]
    exact round_cell_out P inp T A' b' β hP hb' hc1 hc2 hsp' hst' st c
  | answer i a =>
    simp only [tick]
    rw [e]
    rcases round_answer_out P inp T A' b' β hP hb' hc1 hc2 hsp' hst' i a with h | h
    · exact out_same P inp T A' b' β _ h
    · exact Out.found h

/-! ### The tick after, for a fault that was not found -/

set_option maxHeartbeats 4000000 in
/-- R1 to R7 on a game whose record, books and lists are clean, whatever its state, its
observers and (in all three places) its `before`. -/
theorem runA_dirty (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (hb : b.halt = none)
    (Z : St V) (obx : Who → Observer V) (x : Option (St V)) :
    run P inp .none (seg 1 7) (start P inp (dirtyG T A b Z obx x))
      = idle P (dirtyG T A (bookAt P inp b 20) Z obx x) (Inp.t0 inp b) (Inp.dt P inp b)
          (Inp.now P inp b) false none false := by
  rcases inp with c | ⟨dt, now⟩
  · by_cases hr : P.readable c = true <;>
      simp [seg, List.range', run, inject, step, stepOf, start, idle, dirtyG, bookAt, settleBooks,
        Gate.settleBefore, keep, Game.book, vote_const, hb, Game.halted, Inp.t0, Inp.dt, Inp.book,
        Inp.now, hr]
  · simp [seg, List.range', run, inject, step, stepOf, start, idle, dirtyG, bookAt, settleBooks,
      Gate.settleBefore, keep, Game.book, vote_const, hb, Game.halted, Inp.t0, Inp.dt, Inp.book,
      Inp.now]

theorem plain_idle (g : Game V Q Tm) (t0 : Tm) (dt : Dt) (now : Tm) (bh : Bool)
    (fnd : Option Cause) : Plain P (idle P g t0 dt now bh fnd false) := by
  constructor <;> rfl

/-- A round with no fault on such a game: it is the round with no fault on the clean
game, or the fault is found. -/
theorem round_dirty_out (hP : Sound P) (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm)
    (β : Option (St V)) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0)
    (Z : St V) (obx : Who → Observer V) (x : Option (St V)) :
    round P inp .none (dirtyG T A b Z obx x) = ffW P inp T A b β 39
    ∨ Found P inp T A b β (round P inp .none (dirtyG T A b Z obx x)) := by
  have e : round P inp .none (dirtyG T A b Z obx x)
      = run P inp .none (seg 19 20) (run P inp .none (seg 8 11)
          (idle P (dirtyG T A (bookAt P inp b 20) Z obx x) (Inp.t0 inp b) (Inp.dt P inp b)
            (Inp.now P inp b) false none false)) := by
    rw [round, steps_seg, show (38 : Nat) = 7 + (11 + 20) by rfl, seg_add, run_append,
      runA_dirty P inp T A b hb, seg_add, run_append]
  rw [e]
  obtain ⟨g₁, f1, f2, f3, f4, f5, f6, f7, hcase⟩ :=
    gateAny P inp 8 (by omega) (by omega) _ (plain_idle P _ _ _ _ _ _)
      (show (idle P (dirtyG T A (bookAt P inp b 20) Z obx x) (Inp.t0 inp b) (Inp.dt P inp b)
        (Inp.now P inp b) false none false).g.bk = fun _ => bookAt P inp b 20 from rfl)
      (bookAt_halt P inp b hb 20)
  have s2 : g₁.rt = T := f2
  have s3 : g₁.rc = T := f3
  have s5 : g₁.bf = fun _ => x := f5
  have s6 : g₁.asks = fun _ => A := f6
  rcases hcase with ⟨why, hw⟩ | ⟨hd, hw⟩
  · right
    rw [hw]
    exact found_of_halted P inp T A b β hP hb hc1 hc2 hsp hst
      (stopAll_ff P inp b why _ g₁ f4) s5
      (rec_clean P T s2 s3
        (by show g₁.bf 0 = g₁.bf 1 ∧ g₁.bf 0 = g₁.bf 2
            rw [s5]; exact ⟨rfl, rfl⟩)
        (by show g₁.asks 0 = g₁.asks 1 ∨ g₁.asks 0 = g₁.asks 2 ∨ g₁.asks 1 = g₁.asks 2
            rw [s6]; exact Or.inl rfl))
      (by show vote g₁.asks = A
          rw [s6]; exact vote_const A)
  · left
    obtain ⟨d1, d2, d3, d4⟩ := (differs_none P g₁).1 hd
    have s1 : g₁.sp = T := by rw [← stateCheck_none d2, s2]
    have hw' : run P inp .none (seg 8 11)
        (idle P (dirtyG T A (bookAt P inp b 20) Z obx x) (Inp.t0 inp b) (Inp.dt P inp b)
          (Inp.now P inp b) false none false)
        = ffX P inp T A b x 19 := by
      rw [ffX_19 P inp T A b x hb, hw]
      have := eq_cleanG P T A x s1 s2 s3 f4 s5 s6 (obsOff_none P d3)
      rw [this]
      rfl
    rw [hw']
    have := run_ffX P inp T A b x hP hb hc1 hc2 20 19 (by omega) (by omega)
    rw [this, ffX_ge20 P inp T A b x 39 (by omega)]
    exact ffW_39_beta P inp T A b β x

/-- The game is the clean one with something of a fault left in it: one cell changed, or
the state, the observers and `before` anything. -/
def NearG (g G : Game V Q Tm) : Prop :=
  (∃ c : Cell V Q Tm, g = c.hit G)
  ∨ (∃ (Z : St V) (obx : Who → Observer V) (x : Option (St V)),
      g = { G with sp := Z, ob := obx, bf := fun _ => x })

/-- The tick after a fault that was not found, with no new fault: either it is exactly
the tick with no fault from the clean game, or the fault is found. And the voted list
before the round is the clean game's. -/
theorem near_tick (hP : Sound P) (es : List (Ev E)) (inp : Inp Tm Dt) (T : St V) (A : Q)
    (b : Book V Tm) (β : Option (St V)) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0) {g : Game V Q Tm}
    (hn : NearG g (cleanG P T A b β)) :
    ∃ A' b', events P es (cleanG P T A b β) = cleanG P T A' b' β ∧ SameBook b b'
      ∧ tick P es inp none (cleanG P T A b β) = ffW P inp T A' b' β 39
      ∧ vote (events P es g).asks = A'
      ∧ (tick P es inp none g = ffW P inp T A' b' β 39
          ∨ Found P inp T A' b' β (tick P es inp none g)) := by
  obtain ⟨A', b', e, s, d, c⟩ := events_clean P es T A b β hb
  have hb' : b'.halt = none := by rw [s.halt, hb]
  have hsp' : b'.spoiled = 0 := by rw [s.spoiled, hsp]
  have hst' : b'.stops = 0 := by rw [s.stops, hst]
  have htw : tick P es inp none (cleanG P T A b β) = ffW P inp T A' b' β 39 := by
    simp only [tick]; rw [e]; exact round_none P inp T A' b' β hP hb' hc1 hc2
  refine ⟨A', b', e, s, htw, ?_⟩
  rcases hn with ⟨c0, rfl⟩ | ⟨Z, obx, x, rfl⟩
  · obtain ⟨c', hc'⟩ := c c0
    refine ⟨by rw [hc']; exact vote_asks_hit P c' T A' b' β, ?_⟩
    simp only [tick]
    rw [hc']
    exact round_hit_out P inp T A' b' β hP hb' hc1 hc2 hsp' hst' c'
  · have hd := d Z obx x
    have e0 : ({ cleanG P T A b β with sp := Z, ob := obx, bf := fun _ => x } : Game V Q Tm)
        = dirtyG T A b Z obx x := rfl
    refine ⟨by rw [e0, hd]; simp [dirtyG, vote_const], ?_⟩
    simp only [tick]
    rw [e0, hd]
    exact round_dirty_out P hP inp T A' b' β hb' hc1 hc2 hsp' hst' Z obx x

/-! ### A tick that begins halted -/

theorem HR.book {g : Game V Q Tm} {T : St V} {N : Nat} (h : HR P g T N) :
    g.halted = true ∧ g.stuck = false := by
  obtain ⟨bH, hh, β', hbk, h1, h2, _⟩ := h
  have : g.book = bH := by rw [Game.book, hbk]; exact vote_const _
  simp [Game.halted, Game.stuck, this, h1, h2]

/-- What can be put right stays so when only the books, the lists (two still agreeing)
and the observers' signals, flags and reasons change. -/
theorem rec_frame {g g₁ : Game V Q Tm} {T : St V} (h : Rec P g T) (f1 : g₁.sp = g.sp)
    (f2 : g₁.rt = g.rt) (f3 : g₁.rc = g.rc) (f5 : g₁.bf = g.bf)
    (f6 : g₁.asks 0 = g₁.asks 1 ∨ g₁.asks 0 = g₁.asks 2 ∨ g₁.asks 1 = g₁.asks 2)
    (f7 : ∀ i, (g₁.ob i).copies = (g.ob i).copies) : Rec P g₁ T := by
  obtain ⟨⟨β, hβ, hp⟩, _⟩ := h
  refine ⟨⟨β, by rw [f5, hβ], fun p => ?_⟩, f6⟩
  rcases hp p with ⟨a, b⟩ | ⟨a, b, c⟩
  · left; exact ⟨by rw [f2, a], by rw [f3, b]⟩
  · right
    refine ⟨by rw [f2, f3]; exact a, ?_, by rw [f1]; exact c⟩
    intro i hs; rw [f7 i]; exact b i hs

/-- E1 to E3 on a halted game that can be put right: it is still one. -/
theorem event_HR (e : Ev E) {g : Game V Q Tm} {T : St V} {N : Nat} (h : HR P g T N) :
    HR P (event P e g) T N := by
  obtain ⟨bH, hh, β', hbk, h1, h2, h3, h4, h5, hbf, hr, c1, c2⟩ := h
  have hbook : g.book = bH := by rw [Game.book, hbk]; exact vote_const _
  cases e with
  | ask e =>
    by_cases ht : P.taken true (vote g.asks) e = true
    · have e1 : event P (Ev.ask e) g
          = { g with asks := fun k => P.takeDown true e (g.asks k) } := by
        simp [event, Game.stuck, Game.halted, hbook, h1, h2, ht]
      rw [e1]
      refine ⟨bH, hh, β', hbk, h1, h2, h3, h4, h5, hbf, ?_, c1, c2⟩
      refine rec_frame P hr rfl rfl rfl rfl ?_ (fun _ => rfl)
      rcases hr.2 with a | a | a
      · left; show P.takeDown true e (g.asks 0) = P.takeDown true e (g.asks 1); rw [a]
      · right; left; show P.takeDown true e (g.asks 0) = P.takeDown true e (g.asks 2); rw [a]
      · right; right; show P.takeDown true e (g.asks 1) = P.takeDown true e (g.asks 2); rw [a]
    · have e1 : event P (Ev.ask e) g = g := by
        simp [event, Game.stuck, Game.halted, hbook, h1, h2, ht]
      rw [e1]
      exact ⟨bH, hh, β', hbk, h1, h2, h3, h4, h5, hbf, hr, c1, c2⟩
  | putRight =>
    refine ⟨{ bH with halt := some { hh with asked := true } }, { hh with asked := true }, β', ?_,
      rfl, h2, h3, h4, h5, hbf, hr, c1, c2⟩
    simp [event, keep, hbk, h1]
  | setHow hw =>
    refine ⟨{ bH with how := hw }, hh, β', ?_, h1, h2, h3, h4, h5, hbf, hr, c1, c2⟩
    simp [event, keep, hbk]

theorem events_HR (es : List (Ev E)) {g : Game V Q Tm} {T : St V} {N : Nat} (h : HR P g T N) :
    HR P (events P es g) T N := by
  induction es generalizing g with
  | nil => exact h
  | cons e es ih => exact ih (event_HR P e h)

set_option maxHeartbeats 4000000 in
/-- R1 to R7 on a halted game whose three books agree and whose three places of `before`
agree. -/
theorem runA_halted (inp : Inp Tm Dt) (sp : St V) (ob : Who → Observer V) (rt rc : St V)
    (bH : Book V Tm) (β' : Option (St V)) (asks : Fin 3 → Q) (hh : Halt V Tm)
    (h1 : bH.halt = some hh) (h2 : hh.stuck = false) :
    run P inp .none (seg 1 7) (start P inp ⟨sp, ob, rt, rc, fun _ => bH, fun _ => β', asks⟩)
      = idle P ⟨sp, ob, rt, rc,
          fun _ => { bH with clock := Inp.ck P inp bH, time := Inp.now P inp bH,
                             rounds := bH.rounds + 1 },
          fun _ => β', asks⟩ (Inp.t0 inp bH) (Inp.dt P inp bH) (Inp.now P inp bH) true none
          false := by
  rcases inp with c | ⟨dt, now⟩
  · by_cases hr : P.readable c = true <;>
      simp [seg, List.range', run, inject, step, stepOf, start, idle, settleBooks,
        Gate.settleBefore, keep, Game.book, vote_const, h1, h2, Game.halted, Inp.t0, Inp.dt,
        Inp.book, Inp.now, Inp.ck, hr]
  · simp [seg, List.range', run, inject, step, stepOf, start, idle, settleBooks,
      Gate.settleBefore, keep, Game.book, vote_const, h1, h2, Game.halted, Inp.t0, Inp.dt, Inp.book,
      Inp.now, Inp.ck]

/-- R14 to R18 in a round that is halted: the gate does not look. -/
theorem gate_skip (inp : Inp Tm Dt) (r : Run V Q Tm Dt) (ho : r.over = false)
    (hh : r.g.halted = true) : run P inp .none (seg 14 5) r = reset P r := by
  simp [seg, List.range', run, inject, step, stepOf, ho, hh, reset]

/-- R8 to R18 in a round that is halted and has not worked: what is stored is unchanged
but for the observers' signals, flags and reasons. -/
theorem watch_halted (inp : Inp Tm Dt) (r : Run V Q Tm Dt) (hp : Plain P r) {bH : Book V Tm}
    (hbk : r.g.bk = fun _ => bH) (hb : bH.halt.isSome = true) :
    ∃ g₁ : Game V Q Tm, g₁.sp = r.g.sp ∧ g₁.rt = r.g.rt ∧ g₁.rc = r.g.rc ∧ g₁.bk = r.g.bk
      ∧ g₁.bf = r.g.bf ∧ g₁.asks = r.g.asks ∧ (∀ i, (g₁.ob i).copies = (r.g.ob i).copies)
      ∧ run P inp .none (seg 8 11) r = idle P g₁ r.t0 r.dt r.now r.beganHalted r.found false := by
  have hw : WF r (run P inp .none (seg 8 6) r) := wf_run P inp 6 8 (by omega) (by omega) r
  rw [show (11 : Nat) = 6 + 5 by rfl, seg_add, run_append]
  generalize run P inp .none (seg 8 6) r = r₁ at hw
  have ho : r₁.over = false := by rw [hw.over, hp.over]
  have hh : r₁.g.halted = true := by
    simp [Game.halted, Game.book, hw.bk, hbk, vote_const, hb]
  refine ⟨r₁.g, hw.sp, hw.rt, hw.rc, hw.bk, hw.bf, hw.asks, hw.copies, ?_⟩
  rw [gate_skip P inp r₁ ho hh]
  have := reset_idle P hw hp r₁.g r₁.found
  exact this.trans (by rw [hw.found])

/-- A round with no fault that begins halted, in a game that can be put right to `T`.
Everything is still halted and can still be put right; or the halt is over, the round
ended there, and everything agrees on `T`; or the halt is over and the round was worked
and recorded as the work with no fault makes it from `T` and the voted list. And the halt
does end when it is set to end at once, or has been asked to, or the pause is over. -/
theorem halted_round (hP : Sound P) (inp : Inp Tm Dt) {g : Game V Q Tm} {T : St V} {N : Nat}
    (h : HR P g T N) :
    let r := round P inp .none g
    ((r.recorded = none ∧ r.found = none ∧ HR P r.g T N)
      ∨ (r.recorded = none ∧ r.found = none ∧ Mended P r.g T N)
      ∨ (r.recorded = some (P.work T (vote g.asks) r.dt r.now) ∧ r.found = none ∧ Clean P r.g
          ∧ r.g.rt = P.work T (vote g.asks) r.dt r.now ∧ (r.g.bk 0).halts = N))
    ∧ (∀ h', g.book.halt = some h' →
        (g.book.how = How.atOnce ∨ h'.asked = true
          ∨ (g.book.how = How.afterAPause
              ∧ P.pauseOver (if h'.last = some g.sp then h'.quiet else r.now) r.now = true)) →
        r.g.halted = false) := by
  obtain ⟨bH, hh, β', hbk, h1, h2, h3, h4, h5, hbf, hr, c1, c2⟩ := h
  have hbook : g.book = bH := by rw [Game.book, hbk]; exact vote_const _
  cases g with
  | mk sp ob rt rc bk bf asks =>
  simp only at hbk hbf
  subst hbk hbf
  -- R1 to R7, then R8 to R18
  have e : round P inp .none ⟨sp, ob, rt, rc, fun _ => bH, fun _ => β', asks⟩
      = run P inp .none (seg 19 20) (run P inp .none (seg 8 11)
          (idle P ⟨sp, ob, rt, rc,
            fun _ => { bH with clock := Inp.ck P inp bH, time := Inp.now P inp bH,
                               rounds := bH.rounds + 1 },
            fun _ => β', asks⟩ (Inp.t0 inp bH) (Inp.dt P inp bH) (Inp.now P inp bH) true none
            false)) := by
    rw [round, steps_seg, show (38 : Nat) = 7 + (11 + 20) by rfl, seg_add, run_append,
      runA_halted P inp sp ob rt rc bH β' asks hh h1 h2, seg_add, run_append]
  obtain ⟨g₁, f1, f2, f3, f4, f5, f6, f7, hw⟩ := watch_halted P inp
    (idle P ⟨sp, ob, rt, rc,
            fun _ => { bH with clock := Inp.ck P inp bH, time := Inp.now P inp bH,
                               rounds := bH.rounds + 1 },
            fun _ => β', asks⟩ (Inp.t0 inp bH) (Inp.dt P inp bH) (Inp.now P inp bH) true none
            false) (plain_idle P _ _ _ _ _ _)
    (bH := { bH with clock := Inp.ck P inp bH, time := Inp.now P inp bH, rounds := bH.rounds + 1 })
    rfl (by simp [h1])
  simp only [idle] at f1 f2 f3 f4 f5 f6 f7
  have hr₁ : Rec P g₁ T := rec_frame P hr f1 f2 f3 f5 (by rw [f6]; exact hr.2) f7
  have ht := haltTail P hP inp (Inp.t0 inp bH) (Inp.dt P inp bH) (Inp.now P inp bH) true none
    f4 f5 (h := hh) h1 h2 hr₁ c1 c2
  simp only at ht
  have e' : round P inp .none ⟨sp, ob, rt, rc, fun _ => bH, fun _ => β', asks⟩
      = run P inp .none (seg 19 20)
          (idle P g₁ (Inp.t0 inp bH) (Inp.dt P inp bH) (Inp.now P inp bH) true none false) := by
    rw [e, hw]; rfl
  simp only
  rw [e']
  have hva : vote g₁.asks = vote asks := by rw [f6]
  obtain ⟨w1, w2, w3, w4, w5⟩ := hP.work_passes T (vote asks) (Inp.dt P inp bH)
    (Inp.now P inp bH) c1 c2
  rcases ht with ⟨hhow, e3⟩ | ⟨hhow, e3⟩ | ⟨hx, hsx, hax, hmend, e3⟩
  · rw [e3, hva]
    refine ⟨Or.inr (Or.inr ⟨by simp [wk, Params.work], by simp [wk], ?_,
      by simp [wk, Params.work], by simp [wk]; exact h5⟩), ?_⟩
    · rw [wk_39_g]
      exact clean_cleanG P _ _ _ _ rfl w2 w3 rfl (by simp [h4])
    · intro _ _ _
      rw [wk_39_g]; simp [Game.halted, cleanG_book]
  · rw [e3, hva]
    refine ⟨Or.inr (Or.inl ⟨rfl, rfl, ?_⟩), ?_⟩
    · refine ⟨settled_cleanG P T _ _ β' rfl c1 c2, rfl, ?_, ?_, ?_⟩
      · simp [idle, cleanG]; exact h3
      · simp [idle, cleanG]; exact h4
      · simp [idle, cleanG]; exact h5
    · intro _ _ _
      simp [idle, Game.halted, cleanG_book]
  · rw [e3]
    refine ⟨Or.inl ⟨rfl, rfl, ?_⟩, ?_⟩
    · refine ⟨_, hx, β', rfl, rfl, hsx, ?_, ?_, ?_, f5, ?_, c1, c2⟩
      · simp [idle]; exact h3
      · simp [idle]; exact h4
      · simp [idle]; exact h5
      · exact rec_frame P hr₁ rfl rfl rfl rfl hr₁.2 (fun _ => rfl)
    · intro hq hhq hcond
      -- under these conditions `mend` ends the halt, so this case does not arise
      have hbq : (⟨sp, ob, rt, rc, fun _ => bH, fun _ => β', asks⟩ : Game V Q Tm).book = bH :=
        hbook
      rw [hbq, h1] at hhq
      have hqe : hq = hh := by injection hhq with hhq; exact hhq.symm
      subst hqe
      rw [hbq] at hcond
      have hends := mend_ends P (Inp.now P inp bH) f4 f5 (h := hq) h1 h2 hr₁
        (by
          rcases hcond with a | a | ⟨a, b⟩
          · exact Or.inl a
          · exact Or.inr (Or.inl a)
          · refine Or.inr (Or.inr ⟨a, ?_⟩)
            rw [f1]
            simpa [idle] using b)
      rw [hends] at hmend
      have := congrArg (fun g : Game V Q Tm => (g.bk 0).halt) hmend
      simp [cleanG] at this

end
end Gate
