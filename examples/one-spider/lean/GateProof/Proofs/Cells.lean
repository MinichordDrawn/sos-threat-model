/-
One fault in one round, from a game in which everything agrees: what the round leaves,
for each kind of cell and each instant.
-/
import GateProof.Proofs.Generic

set_option linter.unusedSectionVars false
set_option linter.deprecated false
set_option linter.unusedSimpArgs false
set_option linter.unusedVariables false

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)
variable (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V))

/-- The second half of the round with no fault, from the clean game `T`, `A`, `b`, `β`. -/
def ffW (n : Nat) : Run V Q Tm Dt :=
  wk P T A (bookAt P inp b 20) β (Inp.t0 inp b) (Inp.dt P inp b) (Inp.now P inp b) false none
    false n

/-- The round with no fault, immediately before step `n` (1 to 38), and at its end (39). -/
def ffX (n : Nat) : Run V Q Tm Dt :=
  if n ≤ 19 then ffA P inp T A b β n else ffW P inp T A b β n

theorem book_halt : (Inp.book P inp b).halt = b.halt := by
  rcases inp with c | ⟨dt, now⟩
  · by_cases hr : P.readable c = true <;> simp [Inp.book, hr]
  · simp [Inp.book]

theorem bookAt_halt (hb : b.halt = none) (n : Nat) : (bookAt P inp b n).halt = none := by
  unfold bookAt
  (repeat' split) <;> simp [book_halt, hb]

/-- A stretch of the round with no fault. -/
theorem run_ffX (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (k n : Nat) (h1 : 1 ≤ n) (h2 : n + k ≤ 39) :
    run P inp .none (seg n k) (ffX P inp T A b β n) = ffX P inp T A b β (n + k) := by
  have hbb := bookAt_halt P inp b hb 20
  by_cases hn : 20 ≤ n
  · have e1 : ffX P inp T A b β n = ffW P inp T A b β n := by simp [ffX]; omega
    have e2 : ffX P inp T A b β (n + k) = ffW P inp T A b β (n + k) := by simp [ffX]; omega
    rw [e1, e2]
    exact run_wk P hP inp T A _ β _ _ _ false none false hbb hc1 hc2 k n hn h2
  · by_cases hk : n + k ≤ 19
    · have e1 : ffX P inp T A b β n = ffA P inp T A b β n := by simp [ffX]; omega
      have e2 : ffX P inp T A b β (n + k) = ffA P inp T A b β (n + k) := by simp [ffX]; omega
      rw [e1, e2]
      exact run_ffA P inp T A b β hb k n h1 (by omega)
    · have e1 : ffX P inp T A b β n = ffA P inp T A b β n := by simp [ffX]; omega
      have e2 : ffX P inp T A b β (n + k) = ffW P inp T A b β (n + k) := by simp [ffX]; omega
      rw [e1, e2, show k = (20 - n) + (n + k - 20) by omega, seg_add, run_append,
        run_ffA P inp T A b β hb (20 - n) n h1 (by omega), show n + (20 - n) = 20 by omega, ffA_20]
      have := run_wk P hP inp T A _ β (Inp.t0 inp b) (Inp.dt P inp b) (Inp.now P inp b) false none
        false hbb hc1 hc2 (n + k - 20) 20 (by omega) (by omega)
      rw [this, ffW]
      congr 1; omega

/-- A round with one cell changed immediately before step `m`: the round with no fault up
to there, the fault, and the rest of the steps. -/
theorem round_cell (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (c : Cell V Q Tm) (m : Nat) (h1 : 1 ≤ m) (h2 : m ≤ 38) :
    round P inp (.cell (stepOf m) c) (cleanG P T A b β)
      = run P inp .none (seg m (39 - m)) (hitR c (ffX P inp T A b β m)) := by
  have e0 : ffA P inp T A b β 1 = ffX P inp T A b β 1 := by simp [ffX]
  rw [round, start_clean, steps_seg, show (38 : Nat) = (m - 1) + (39 - m) by omega, seg_add,
    run_append, run_cell_skip P inp c m h1 h2 (m - 1) 1 (by omega) (by omega) (by omega), e0,
    run_ffX P inp T A b β hP hb hc1 hc2 (m - 1) 1 (by omega) (by omega),
    show 1 + (m - 1) = m by omega, show 39 - m = (38 - m) + 1 by omega,
    run_cell_at P inp c m h1 h2 (38 - m) (by omega)]

/-! ### What the round of the fault can leave -/

/-- R2: the book's note of the clock after R2. -/
def Inp.ck (inp : Inp Tm Dt) (b : Book V Tm) : Tm := (Inp.book P inp b).clock

theorem book_eq : Inp.book P inp b = { b with clock := Inp.ck P inp b } := by
  rcases inp with c | ⟨dt, now⟩
  · by_cases hr : P.readable c = true <;> simp [Inp.book, Inp.ck, hr]
  · simp [Inp.book, Inp.ck]

theorem bookAt_20 : bookAt P inp b 20
    = { b with clock := Inp.ck P inp b, time := Inp.now P inp b, rounds := b.rounds + 1 } := by
  simp [bookAt, book_eq]

/-- The game with the counts of halts and of restarts one more in each book. -/
def bump (g : Game V Q Tm) : Game V Q Tm :=
  { g with bk := fun k => { g.bk k with halts := (g.bk k).halts + 1,
                                        restarts := (g.bk k).restarts + 1 } }

/-- The fault was found in the round it landed in. Either the halt ended at once and the
round was worked and recorded as the round with no fault is; or everything is halted and
can be put right to the record from before the round; or the halt ended and the round
ended there, with everything agreeing on the record from before the round. -/
inductive Found (r : Run V Q Tm Dt) : Prop where
  | once (why : Cause) (h1 : r.found = some why)
      (h2 : r.recorded = (ffW P inp T A b β 39).recorded)
      (h3 : r.dt = Inp.dt P inp b) (h4 : r.now = Inp.now P inp b)
      (h5 : r.g = bump (ffW P inp T A b β 39).g) (h6 : r.worked = true) (h7 : r.ended = true)
  | halt (why : Cause) (h1 : r.found = some why) (h2 : r.recorded = none)
      (h3 : r.dt = Inp.dt P inp b) (h4 : r.now = Inp.now P inp b)
      (h5 : HR P r.g T (b.halts + 1)) (h7 : r.ended = false)
  | mend (why : Cause) (h1 : r.found = some why) (h2 : r.recorded = none)
      (h3 : r.dt = Inp.dt P inp b) (h4 : r.now = Inp.now P inp b)
      (h5 : Mended P r.g T (b.halts + 1)) (h6 : r.worked = false) (h7 : r.ended = true)

/-- The book after R7 of the round with no fault, with a halt begun in this round. -/
def haltBook (why : Cause) (q : Tm) : Book V Tm :=
  { halt := some ⟨why, q, none, false, false⟩, how := b.how, halts := b.halts + 1,
    restarts := b.restarts, spoiled := b.spoiled, stops := b.stops, clock := Inp.ck P inp b,
    time := Inp.now P inp b, rounds := b.rounds + 1, rest := b.rest }

theorem stopAll_ff (why : Cause) (q : Tm) (g : Game V Q Tm)
    (h : g.bk = fun _ => bookAt P inp b 20) :
    (stopAll why q g).bk = fun _ => haltBook P inp b why q := by
  simp [stopAll, keep, h, bookAt_20, haltBook]

/-- A round that comes to R19 halted by this round's detection, before any work, in a
game that can be put right to `T`: the fault is found. -/
theorem found_of_halted (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0)
    {g : Game V Q Tm} {why why' : Cause} {q : Tm} {bh : Bool} {β' : Option (St V)}
    (hbk : g.bk = fun _ => haltBook P inp b why' q)
    (hbf : g.bf = fun _ => β') (hr : Rec P g T) (hv : vote g.asks = A) :
    Found P inp T A b β (run P inp .none (seg 19 20)
      (idle P g (Inp.t0 inp b) (Inp.dt P inp b) (Inp.now P inp b) bh (some why) false)) := by
  have ht := haltTail P hP inp (Inp.t0 inp b) (Inp.dt P inp b) (Inp.now P inp b) bh (some why)
    hbk hbf rfl rfl hr hc1 hc2
  rw [hv] at ht
  simp only [haltBook] at ht
  rcases ht with ⟨_, e⟩ | ⟨_, e⟩ | ⟨h', hs', _, _, e⟩
  · rw [e]
    refine Found.once why (by simp [wk]) (by simp [wk, ffW]) (by simp [wk]) (by simp [wk]) ?_
      (by simp [wk]) (by simp [wk])
    cases bh <;> simp [wk, ffW, bump, bookAt_20, hst, haltBook, hb]
  · rw [e]
    refine Found.mend why rfl rfl rfl rfl ?_ rfl rfl
    refine ⟨settled_cleanG P T A _ β' rfl hc1 hc2, rfl, ?_, ?_, ?_⟩
    · simp [idle, cleanG, hsp]
    · simp [idle, cleanG, hst]
    · simp [idle, cleanG]
  · rw [e]
    refine Found.halt why rfl rfl rfl rfl ?_ rfl
    refine ⟨_, h', β', rfl, rfl, hs', ?_, ?_, ?_, hbf, hr, hc1, hc2⟩
    · simp [idle, hsp]
    · simp [idle, hst]
    · simp [idle]

/-! ### Sliding a fault along steps that do not touch its cell -/

/-- If the steps from `m` up to `a` leave the fault where it is, the fault landing before
step `m` is the fault landing before step `a`. -/
theorem slide_run (c : Cell V Q Tm) (a : Nat) (ha : a ≤ 39) (d m : Nat) (hm : 1 ≤ m)
    (hd : m + d = a)
    (hs : ∀ n, m ≤ n → n < a →
      step P inp (stepOf n) (hitR c (ffX P inp T A b β n)) = hitR c (ffX P inp T A b β (n + 1))) :
    run P inp .none (seg m (39 - m)) (hitR c (ffX P inp T A b β m))
      = run P inp .none (seg a (39 - a)) (hitR c (ffX P inp T A b β a)) := by
  induction d generalizing m with
  | zero => have : m = a := by omega
            subst this; rfl
  | succ d ih =>
    rw [show 39 - m = (38 - m) + 1 by omega, seg_succ]
    simp only [run, inject]
    rw [hs m (by omega) (by omega), show 38 - m = 39 - (m + 1) by omega]
    exact ih (m + 1) (by omega) (by omega) (fun n h1 h2 => hs n (by omega) h2)

set_option maxHeartbeats 4000000 in
/-- R1 to R7 touch nothing but the books and `before`. -/
theorem slide_open (hb : b.halt = none) (c : Cell V Q Tm) (hc : c.isOpen = true) (n : Nat)
    (h1 : 1 ≤ n) (h2 : n ≤ 7) :
    step P inp (stepOf n) (hitR c (ffX P inp T A b β n)) = hitR c (ffX P inp T A b β (n + 1)) := by
  have hn : n = 1 ∨ n = 2 ∨ n = 3 ∨ n = 4 ∨ n = 5 ∨ n = 6 ∨ n = 7 := by omega
  cases c <;> simp [Cell.isOpen] at hc <;>
  rcases hn with h | h | h | h | h | h | h <;> subst h <;> rcases inp with c | ⟨dt, now⟩ <;>
    first
    | (by_cases hr : P.readable c = true <;>
        simp [ffX, ffA, hitR, Cell.hit, step, stepOf, bookAt, settleBooks, Gate.settleBefore, keep,
          Game.book, vote_const, hb, Game.halted, Inp.t0, Inp.dt, Inp.book, Inp.now, hr])
    | simp [ffX, ffA, hitR, Cell.hit, step, stepOf, bookAt, settleBooks, Gate.settleBefore, keep,
        Game.book, vote_const, hb, Game.halted, Inp.t0, Inp.dt, Inp.book, Inp.now]

/-! ### A fault that lands before the gate has looked -/

theorem eq_cleanG {g : Game V Q Tm} {bb : Book V Tm} (h1 : g.sp = T) (h2 : g.rt = T)
    (h3 : g.rc = T) (h4 : g.bk = fun _ => bb) (h5 : g.bf = fun _ => β) (h6 : g.asks = fun _ => A)
    (h7 : ∀ i, g.ob i = born P g i) : g = cleanG P T A bb β := by
  have hbook : g.book = bb := by rw [Game.book, h4]; exact vote_const _
  have ho : g.ob = fun i => freshOb P i T bb.rounds (P.inWeb₁ T) := by
    funext i; rw [h7 i]; simp [born, freshOb, heldOf, hbook, h2, h3]
  cases g
  simp only [cleanG] at *
  subst h1 h2 h3 h4 h5 h6 ho
  rfl

/-- A game that is the clean one with one open cell changed, whatever the observers'
signals, flags and reasons: it can be put right to `T`, and the voted list is `A`. -/
theorem rec_of_hit (c : Cell V Q Tm) (hc : c.isOpen = true) (G g₁ : Game V Q Tm)
    (hG1 : ∀ p, G.sp p = T p ∨ β.map (fun s => s p) = some (T p))
    (hG2 : G.rt = T) (hG3 : G.rc = T) (hG4 : G.bf = fun _ => β)
    (hG5 : G.asks = fun _ => A) (hG6 : ∀ i, (G.ob i).copies = copiesFor P i T)
    (f1 : g₁.sp = (c.hit G).sp) (f2 : g₁.rt = (c.hit G).rt) (f3 : g₁.rc = (c.hit G).rc)
    (f5 : g₁.bf = (c.hit G).bf) (f6 : g₁.asks = (c.hit G).asks)
    (f7 : ∀ i, (g₁.ob i).copies = ((c.hit G).ob i).copies) :
    Rec P g₁ T ∧ vote g₁.asks = A ∧ (g₁.bf = fun _ => β) := by
  cases c with
  | sp p v =>
    simp only [Cell.hit] at f1 f2 f3 f5 f6 f7
    refine ⟨⟨⟨β, by rw [f5, hG4], fun q => Or.inl ⟨by rw [f2, hG2], by rw [f3, hG3]⟩⟩, ?_⟩, ?_,
      by rw [f5, hG4]⟩
    · left; rw [f6, hG5]
    · rw [f6, hG5]; exact vote_const A
  | ob i o =>
    simp only [Cell.hit] at f1 f2 f3 f5 f6 f7
    refine ⟨⟨⟨β, by rw [f5, hG4], fun q => Or.inl ⟨by rw [f2, hG2], by rw [f3, hG3]⟩⟩, ?_⟩, ?_,
      by rw [f5, hG4]⟩
    · left; rw [f6, hG5]
    · rw [f6, hG5]; exact vote_const A
  | rt p v =>
    simp only [Cell.hit] at f1 f2 f3 f5 f6 f7
    refine ⟨⟨⟨β, by rw [f5, hG4], fun q => ?_⟩, ?_⟩, ?_, by rw [f5, hG4]⟩
    · by_cases hq : q = p
      · right
        refine ⟨Or.inr (by rw [f3, hG3]), ?_, by rw [f1]; exact hG1 q⟩
        intro i hs
        rw [f7 i, hG6 i]; simp [copiesFor, hs]
      · left; exact ⟨by rw [f2]; simp [hq, hG2], by rw [f3, hG3]⟩
    · left; rw [f6, hG5]
    · rw [f6, hG5]; exact vote_const A
  | rc p v =>
    simp only [Cell.hit] at f1 f2 f3 f5 f6 f7
    refine ⟨⟨⟨β, by rw [f5, hG4], fun q => ?_⟩, ?_⟩, ?_, by rw [f5, hG4]⟩
    · by_cases hq : q = p
      · right
        refine ⟨Or.inl (by rw [f2, hG2]), ?_, by rw [f1]; exact hG1 q⟩
        intro i hs
        rw [f7 i, hG6 i]; simp [copiesFor, hs]
      · left; exact ⟨by rw [f2, hG2], by rw [f3]; simp [hq, hG3]⟩
    · left; rw [f6, hG5]
    · rw [f6, hG5]; exact vote_const A
  | bk k x => simp [Cell.isOpen] at hc
  | bf k x => simp [Cell.isOpen] at hc
  | asks k q =>
    simp only [Cell.hit] at f1 f2 f3 f5 f6 f7
    refine ⟨⟨⟨β, by rw [f5, hG4], fun q => Or.inl ⟨by rw [f2, hG2], by rw [f3, hG3]⟩⟩, ?_⟩, ?_,
      by rw [f5, hG4]⟩
    · rw [f6, hG5]
      rcases fin3 k with h | h | h <;> subst h <;> simp
    · rw [f6, hG5]; exact vote_hit A q k

/-- If, in such a game, the gate finds nothing, the game is the clean one. -/
theorem clean_of_hit (c : Cell V Q Tm) (hc : c.isOpen = true) (G g₁ : Game V Q Tm)
    {bb : Book V Tm}
    (hG1 : G.sp = T) (hG2 : G.rt = T) (hG3 : G.rc = T) (hG4 : G.bf = fun _ => β)
    (hG5 : G.asks = fun _ => A)
    (f1 : g₁.sp = (c.hit G).sp) (f2 : g₁.rt = (c.hit G).rt) (f3 : g₁.rc = (c.hit G).rc)
    (f4 : g₁.bk = fun _ => bb) (f5 : g₁.bf = (c.hit G).bf) (f6 : g₁.asks = (c.hit G).asks)
    (hd : differs P g₁ = none) : g₁ = cleanG P T A bb β := by
  obtain ⟨d1, d2, d3, d4⟩ := (differs_none P g₁).1 hd
  have e1 := selfCheck_none d1
  have e2 := stateCheck_none d2
  have e4 := asksCheck_none d4
  have ho := obsOff_none P d3
  cases c with
  | sp p v =>
    simp only [Cell.hit] at f1 f2 f3 f5 f6
    exact eq_cleanG P T A β (by rw [← e2, f2, hG2]) (by rw [f2, hG2]) (by rw [f3, hG3]) f4
      (by rw [f5, hG4]) (by rw [f6, hG5]) ho
  | ob i o =>
    simp only [Cell.hit] at f1 f2 f3 f5 f6
    exact eq_cleanG P T A β (by rw [f1, hG1]) (by rw [f2, hG2]) (by rw [f3, hG3]) f4
      (by rw [f5, hG4]) (by rw [f6, hG5]) ho
  | rt p v =>
    simp only [Cell.hit] at f1 f2 f3 f5 f6
    exact eq_cleanG P T A β (by rw [f1, hG1]) (by rw [e1, f3, hG3]) (by rw [f3, hG3]) f4
      (by rw [f5, hG4]) (by rw [f6, hG5]) ho
  | rc p v =>
    simp only [Cell.hit] at f1 f2 f3 f5 f6
    exact eq_cleanG P T A β (by rw [f1, hG1]) (by rw [f2, hG2]) (by rw [← e1, f2, hG2]) f4
      (by rw [f5, hG4]) (by rw [f6, hG5]) ho
  | bk k x => simp [Cell.isOpen] at hc
  | bf k x => simp [Cell.isOpen] at hc
  | asks k q =>
    simp only [Cell.hit] at f1 f2 f3 f5 f6
    have ha : g₁.asks = fun _ => A := by
      have h0 := congrFun f6 0
      have h1 := congrFun f6 1
      have h2 := congrFun f6 2
      rw [hG5] at h0 h1 h2
      funext j
      rcases fin3 k with h | h | h <;> subst h <;> rcases fin3 j with h' | h' | h' <;> subst h' <;>
        simp_all
    exact eq_cleanG P T A β (by rw [f1, hG1]) (by rw [f2, hG2]) (by rw [f3, hG3]) f4
      (by rw [f5, hG4]) ha ho

theorem bookAt_ge8 (n : Nat) (h : 8 ≤ n) : bookAt P inp b n = bookAt P inp b 20 := by
  unfold bookAt
  rw [if_neg (by omega), if_neg (by omega), if_neg (by omega)]
  simp

theorem bookAt_late (n : Nat) (h : 8 ≤ n) : bookAt P inp b n
    = { b with clock := Inp.ck P inp b, time := Inp.now P inp b, rounds := b.rounds + 1 } := by
  rw [bookAt_ge8 P inp b n h, bookAt_20]

theorem plain_ffX (c : Cell V Q Tm) (n : Nat) (h : n ≤ 19) :
    Plain P (hitR c (ffX P inp T A b β n)) := by
  constructor <;> simp [ffX, h, ffA, hitR]

theorem ffX_19 (hb : b.halt = none) :
    ffX P inp T A b β 19 = idle P (cleanG P T A (bookAt P inp b 20) β) (Inp.t0 inp b)
      (Inp.dt P inp b) (Inp.now P inp b) false none false := by
  simp [ffX, ffA_19]

/-- An open cell changed before R15: either nothing has changed at all, or the fault is
found. -/
theorem pre_open (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0)
    (c : Cell V Q Tm) (hc : c.isOpen = true) (m : Nat) (h1 : 1 ≤ m) (h2 : m ≤ 14) :
    run P inp .none (seg m (39 - m)) (hitR c (ffX P inp T A b β m)) = ffW P inp T A b β 39
    ∨ Found P inp T A b β (run P inp .none (seg m (39 - m)) (hitR c (ffX P inp T A b β m))) := by
  -- the fault slides to R8 if it landed before
  have hj : ∃ j, 8 ≤ j ∧ j ≤ 14 ∧
      run P inp .none (seg m (39 - m)) (hitR c (ffX P inp T A b β m))
        = run P inp .none (seg j (39 - j)) (hitR c (ffX P inp T A b β j)) := by
    by_cases hm : 8 ≤ m
    · exact ⟨m, hm, h2, rfl⟩
    · refine ⟨8, by omega, by omega, ?_⟩
      exact slide_run P inp T A b β c 8 (by omega) (8 - m) m h1 (by omega)
        (fun n a1 a2 => slide_open P inp T A b β hb c hc n (by omega) (by omega))
  obtain ⟨j, j1, j2, e⟩ := hj
  rw [e, show 39 - j = (19 - j) + 20 by omega, seg_add, run_append, show j + (19 - j) = 19 by omega]
  have hpl := plain_ffX P inp T A b β c j (by omega)
  have hbk : (hitR c (ffX P inp T A b β j)).g.bk = fun _ => bookAt P inp b 20 := by
    have : (ffX P inp T A b β j).g.bk = fun _ => bookAt P inp b 20 := by
      simp [ffX, show j ≤ 19 by omega, ffA, bookAt_ge8 P inp b j j1]
    cases c <;> simp [Cell.isOpen] at hc <;> simp [hitR, Cell.hit, this]
  obtain ⟨g₁, f1, f2, f3, f4, f5, f6, f7, hcase⟩ :=
    gateAny P inp j j1 j2 _ hpl hbk (bookAt_halt P inp b hb 20)
  have hG1 : (ffX P inp T A b β j).g.sp = T := by simp [ffX, show j ≤ 19 by omega, ffA]
  have hG2 : (ffX P inp T A b β j).g.rt = T := by simp [ffX, show j ≤ 19 by omega, ffA]
  have hG3 : (ffX P inp T A b β j).g.rc = T := by simp [ffX, show j ≤ 19 by omega, ffA]
  have hG4 : (ffX P inp T A b β j).g.bf = fun _ => β := by simp [ffX, show j ≤ 19 by omega, ffA]
  have hG5 : (ffX P inp T A b β j).g.asks = fun _ => A := by
    simp [ffX, show j ≤ 19 by omega, ffA]
  have hG6 : ∀ i, ((ffX P inp T A b β j).g.ob i).copies = copiesFor P i T := by
    intro i; simp [ffX, show j ≤ 19 by omega, ffA, freshOb]
  have hloc : (hitR c (ffX P inp T A b β j)).t0 = Inp.t0 inp b
      ∧ (hitR c (ffX P inp T A b β j)).dt = Inp.dt P inp b
      ∧ (hitR c (ffX P inp T A b β j)).now = Inp.now P inp b
      ∧ (hitR c (ffX P inp T A b β j)).beganHalted = false
      ∧ (hitR c (ffX P inp T A b β j)).found = none := by
    simp [ffX, show j ≤ 19 by omega, ffA, hitR]; omega
  obtain ⟨l1, l2, l3, l4, l5⟩ := hloc
  rw [l1, l2, l3, l4, l5] at hcase
  rcases hcase with ⟨why, hw⟩ | ⟨hd, hw⟩
  · right
    rw [hw]
    obtain ⟨hr, hv, hbf⟩ := rec_of_hit P T A β c hc _ g₁ (fun p => Or.inl (congrFun hG1 p))
      hG2 hG3 hG4 hG5 hG6 f1 f2 f3 f5 f6 f7
    have hbk' := stopAll_ff P inp b why (Inp.now P inp b) g₁ (f4.trans hbk)
    exact found_of_halted P inp T A b β hP hb hc1 hc2 hsp hst hbk' hbf hr hv
  · left
    rw [hw, clean_of_hit P T A β c hc _ g₁ hG1 hG2 hG3 hG4 hG5 f1 f2 f3 (f4.trans hbk) f5 f6 hd,
      ← ffX_19 P inp T A b β hb]
    have := run_ffX P inp T A b β hP hb hc1 hc2 20 19 (by omega) (by omega)
    rw [this]; simp [ffX]

/-! ### A fault that lands after the gate has looked -/

theorem const_of_agree {α : Type} {f : Fin 3 → α} (h : f 0 = f 1 ∧ f 0 = f 2) :
    f = fun _ => f 0 := by
  funext k; rcases fin3 k with h' | h' | h' <;> subst h' <;> simp [← h.1, ← h.2]


/-- What the round with no fault leaves, with something of the fault left in it: one
cell changed; or the record, the books and the lists exactly as with no fault, the three
places of `before` agreeing, and the state and the observers anything. -/
def Near (g : Game V Q Tm) : Prop :=
  (∃ c : Cell V Q Tm, g = c.hit (ffW P inp T A b β 39).g)
  ∨ (∃ (Z : St V) (obx : Who → Observer V) (x : Option (St V)),
      g = { (ffW P inp T A b β 39).g with sp := Z, ob := obx, bf := fun _ => x })

theorem near_dirty {g : Game V Q Tm} (h1 : g.rt = (ffW P inp T A b β 39).g.rt)
    (h2 : g.rc = (ffW P inp T A b β 39).g.rc) (h3 : g.bk = (ffW P inp T A b β 39).g.bk)
    (h4 : g.asks = (ffW P inp T A b β 39).g.asks) (h5 : g.bf 0 = g.bf 1 ∧ g.bf 0 = g.bf 2) :
    Near P inp T A b β g := by
  right
  obtain ⟨x, hx⟩ : ∃ x, g.bf = fun _ => x := ⟨_, const_of_agree h5⟩
  refine ⟨g.sp, g.ob, x, ?_⟩
  cases g
  simp only at h1 h2 h3 h4 hx
  subst h1 h2 h3 h4 hx
  rfl

/-- Evaluating steps on the written-out round. -/
macro "ffs" : tactic => `(tactic|
  simp [seg, List.range', run, inject, step, stepOf, ffX, ffW, ffA, wk, hitR, Cell.hit, bookAt_late,
    keep, Game.book, vote_const, vote_hit, Game.halted, sound, freshOb, obsOff_clean', Params.redo,
    Params.work, asksCheck, selfCheck, stateCheck, allParts, List.findSome?, *])

/-- What the round of the fault can leave. Not found: the round was worked and recorded
exactly as with no fault, and what is stored is `Near` to what the round with no fault
leaves. Or found (`Found`). -/
inductive Out (r : Run V Q Tm Dt) : Prop where
  | near (h1 : r.found = none) (h2 : r.recorded = (ffW P inp T A b β 39).recorded)
      (h3 : r.dt = Inp.dt P inp b) (h4 : r.now = Inp.now P inp b)
      (h5 : Near P inp T A b β r.g) (h6 : r.worked = true) (h7 : r.ended = false)
  | found (h : Found P inp T A b β r)

theorem out_same (r : Run V Q Tm Dt) (h : r = ffW P inp T A b β 39) : Out P inp T A b β r := by
  subst h
  refine Out.near (by simp [ffW, wk]) rfl (by simp [ffW, wk]) (by simp [ffW, wk]) ?_
    (by simp [ffW, wk]) (by simp [ffW, wk])
  left
  exact ⟨.sp 0 ((ffW P inp T A b β 39).g.sp 0), by simp [Cell.hit, fun_upd_same]⟩

/-- The gate refused the round: the fault is found, everything is halted, and it can be
put right to the record from before the round. -/
theorem found_of_refused (hc1 : P.canBe₁ T = true) (hc2 : P.canBe₂ T = true)
    (hsp : b.spoiled = 0) (hst : b.stops = 0) {r' : Run V Q Tm Dt} {g0 : Game V Q Tm}
    {why : Cause} {β' : Option (St V)}
    (hg : r'.g = keep (fun b => { b with spoiled := b.spoiled + 1 })
            (stopAll why (Inp.now P inp b) g0))
    (hf : r'.found = some why) (hrec : r'.recorded = none) (hdt : r'.dt = Inp.dt P inp b)
    (hnow : r'.now = Inp.now P inp b) (hend : r'.ended = false)
    (hbk : g0.bk = fun _ => bookAt P inp b 20) (hbf : g0.bf = fun _ => β') (hr : Rec P g0 T) :
    Found P inp T A b β r' := by
  refine Found.halt why hf hrec hdt hnow ?_ hend
  rw [hg]
  refine ⟨{ haltBook P inp b why (Inp.now P inp b) with spoiled := b.spoiled + 1 },
    ⟨why, Inp.now P inp b, none, false, false⟩, β', ?_, rfl, rfl, ?_, ?_, ?_, hbf, hr, hc1, hc2⟩
  · simp [keep, stopAll, hbk, bookAt_20, haltBook]
  · simp [haltBook, hsp]
  · simp [haltBook, hst]
  · simp [haltBook]

/-- The record's two halves both say `T`: it can be put right, whatever the state and the
observers hold. -/
theorem rec_clean {g : Game V Q Tm} (h1 : g.rt = T) (h2 : g.rc = T)
    (h3 : g.bf 0 = g.bf 1 ∧ g.bf 0 = g.bf 2)
    (h4 : g.asks 0 = g.asks 1 ∨ g.asks 0 = g.asks 2 ∨ g.asks 1 = g.asks 2) : Rec P g T :=
  ⟨⟨g.bf 0, const_of_agree h3, fun q => Or.inl ⟨by rw [h1], by rw [h2]⟩⟩, h4⟩

/-- From any of R26 to R32 to the end, for a round that came there with the fault landed
and nothing halted: the round's outcome is one of those `Out` allows, provided what is
stored can be put right to `T` (for when the gate refuses), and provided that what would
be recorded is right (for when it does not): the second doing started from the right
record and list, or the state is right, or the second doing was done before the fault. -/
theorem out_tail (hP : Sound P) (hb : b.halt = none) (hc1 : P.canBe₁ T = true)
    (hc2 : P.canBe₂ T = true) (hsp : b.spoiled = 0) (hst : b.stops = 0)
    (m : Nat) (h1 : 26 ≤ m) (h2 : m ≤ 32) (r₀ : Run V Q Tm Dt)
    (ho : r₀.over = false) (hr : r₀.refused = none)
    (hbk : r₀.g.bk = fun _ => bookAt P inp b 20)
    (hdt : r₀.dt = Inp.dt P inp b) (hnow : r₀.now = Inp.now P inp b)
    (hrec : r₀.recorded = none) (hfound : r₀.found = none) (hend : r₀.ended = false)
    (hwk : r₀.worked = true) (hbh : r₀.beganHalted = false)
    (hbf : r₀.g.bf 0 = r₀.g.bf 1 ∧ r₀.g.bf 0 = r₀.g.bf 2)
    (hR : Rec P r₀.g T)
    (hM : (m ≤ 30 ∧ r₀.g.rc = T ∧ r₀.g.asks 1 = A)
          ∨ (m ≤ 31 ∧ r₀.g.sp = P.work T A (Inp.dt P inp b) (Inp.now P inp b))
          ∨ (30 < m ∧ r₀.made = P.work T A (Inp.dt P inp b) (Inp.now P inp b))) :
    Out P inp T A b β (run P inp .none (seg m (39 - m)) r₀) := by
  have hbb : (bookAt P inp b 20).spoiled = 0 := by simp [bookAt_20, hsp]
  have ht := tail_from P inp m h1 h2 r₀ ho hr hbk hbb
  simp only at ht
  rcases ht with ⟨why, g1, g2, g3, g4, g5, g6, g7⟩ | ⟨M, m1, m2, m3, m4, g1, g2, g3, g4, g5, g6, g7⟩
  · apply Out.found
    rw [hnow] at g1
    exact found_of_refused P inp T A b β hc1 hc2 hsp hst g1 g2 (g3.trans hrec) (g4.trans hdt)
      (g5.trans hnow) (g6.trans hend) hbk (const_of_agree hbf) hR
  · have hMS : M = P.work T A (Inp.dt P inp b) (Inp.now P inp b) := by
      rcases hM with ⟨a, e1, e2⟩ | ⟨a, e⟩ | ⟨a, e⟩
      · rw [m1 a, e1, e2, hdt, hnow]
        simp [Params.redo, Params.work, hP.work_same, hP.inWeb_same]
      · rw [m3 a, e]
      · rw [m2 a, e]
    refine Out.near (g3.trans hfound) ?_ (g4.trans hdt) (g5.trans hnow) ?_ (g6.trans hwk)
      (g7.trans hend)
    · rw [g2, hMS]; simp [ffW, wk, Params.work]
    · apply near_dirty
      · rw [g1, hMS]; simp [ffW, wk, Params.work]
      · rw [g1, hMS]; simp [ffW, wk, Params.work]
      · rw [g1, hbh]; simp [ffW, wk, bookAt_20]
      · rw [g1]; simp [ffW, wk]
      · rw [g1]; exact hbf

end
end Gate
