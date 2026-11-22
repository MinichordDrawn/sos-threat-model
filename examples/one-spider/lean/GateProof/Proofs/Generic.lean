/-
Facts about stretches of a round that hold whatever the round holds when it comes to
them: where a fault lands in a run of steps, what a round does from R19 on when it comes
there halted, and what the observers' looking can and cannot change.
-/
import GateProof.Proofs.FaultFree
import GateProof.Proofs.Restore

set_option linter.unusedSectionVars false
set_option linter.deprecated false
set_option linter.unusedSimpArgs false

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)

/-- A round under way, with a fault landed in what is stored. -/
def hitR (c : Cell V Q Tm) (r : Run V Q Tm Dt) : Run V Q Tm Dt := { r with g := c.hit r.g }

/-- A round under way that holds nothing of its own but what R1 to R7 set: as it is
before R8, and again after R18. -/
def idle (g : Game V Q Tm) (t0 : Tm) (dt : Dt) (now : Tm) (bh : Bool) (fnd : Option Cause)
    (ended : Bool) : Run V Q Tm Dt :=
  { g := g, over := false, t0 := t0, dt := dt, now := now, beganHalted := bh,
    running := fun _ => false, look := noLook P, answers := fun _ => none,
    late := none, told := none, stop := false, gateLooks := false, off := none,
    held := P.blank, asked := fun _ => P.blank, ruled1 := false, refused := none,
    made := fun _ => P.blank, seen := fun _ => P.blank, heldNow := P.blank, recorded := none,
    found := fnd, worked := false, ended := ended }

theorem wk_20 (T : St V) (A : Q) (bb : Book V Tm) (β : Option (St V)) (t0 : Tm) (dt : Dt)
    (now : Tm) (bh : Bool) (fnd : Option Cause) (ended : Bool) :
    wk P T A bb β t0 dt now bh fnd ended 20 = idle P (cleanG P T A bb β) t0 dt now bh fnd ended := by
  simp [wk, idle, cleanG]

theorem ffA_19 (inp : Inp Tm Dt) (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V)) :
    ffA P inp T A b β 19
      = idle P (cleanG P T A (bookAt P inp b 20) β) (Inp.t0 inp b) (Inp.dt P inp b)
          (Inp.now P inp b) false none false := by
  simp [ffA, idle, cleanG, bookAt]

/-! ### Where a fault lands in a run of steps -/

theorem stepOf_inj {m n : Nat} (hm1 : 1 ≤ m) (hm2 : m ≤ 38) (hn1 : 1 ≤ n) (hn2 : n ≤ 38)
    (h : stepOf m = stepOf n) : m = n := by
  have := congrArg Step.num h
  rwa [num_stepOf m hm1 hm2, num_stepOf n hn1 hn2] at this

/-- A run of steps that does not hold the instant of the fault is a run with no fault. -/
theorem run_cell_skip (inp : Inp Tm Dt) (c : Cell V Q Tm) (m : Nat) (hm1 : 1 ≤ m) (hm2 : m ≤ 38)
    (k n : Nat) (hn : 1 ≤ n) (hk : n + k ≤ 39) (h : m < n ∨ n + k ≤ m) (r : Run V Q Tm Dt) :
    run P inp (.cell (stepOf m) c) (seg n k) r = run P inp .none (seg n k) r := by
  induction k generalizing n r with
  | zero => rfl
  | succ k ih =>
    rw [seg_succ]
    simp only [run]
    have hne : stepOf m ≠ stepOf n := by
      intro e
      have := stepOf_inj hm1 hm2 hn (by omega) e
      omega
    have : inject (Sched.cell (stepOf m) c) (stepOf n) r = r := by simp [inject, hne]
    rw [this, ih (n + 1) (by omega) (by omega) (by omega)]
    rfl

/-- A run of steps that begins at the instant of the fault is that run, with no fault,
from the game with the fault landed. -/
theorem run_cell_at (inp : Inp Tm Dt) (c : Cell V Q Tm) (m : Nat) (hm1 : 1 ≤ m) (hm2 : m ≤ 38)
    (k : Nat) (hk : m + k + 1 ≤ 39) (r : Run V Q Tm Dt) :
    run P inp (.cell (stepOf m) c) (seg m (k + 1)) r
      = run P inp .none (seg m (k + 1)) (hitR c r) := by
  rw [seg_succ]
  simp only [run]
  have : inject (Sched.cell (stepOf m) c) (stepOf m) r = hitR c r := by simp [inject, hitR]
  rw [this, run_cell_skip P inp c m hm1 hm2 k (m + 1) (by omega) (by omega) (by omega)]
  rfl

/-- Once a round has ended early, its remaining steps do nothing. -/
theorem run_over (inp : Inp Tm Dt) (l : List Step) (r : Run V Q Tm Dt) (h : r.over = true) :
    run P inp .none l r = r := by
  induction l with
  | nil => rfl
  | cons s l ih => simp [run, inject, step, h, ih]

/-! ### From R19 on, halted -/

/-- A round that comes to R19 halted, with nothing of its own, in a game that can be put
right to `T`. One of three things: the halt ends and, set to end at once, the round goes
on and is recorded as a round with no fault is; the halt ends and the round ends there;
or everything is still halted and the round ends there. -/
theorem haltTail (hP : Sound P) (inp : Inp Tm Dt) {g : Game V Q Tm} {T : St V}
    {bH : Book V Tm} {β : Option (St V)} {h : Halt V Tm} (t0 : Tm) (dt : Dt) (now : Tm)
    (bh : Bool) (fnd : Option Cause)
    (hbk : g.bk = fun _ => bH) (hbf : g.bf = fun _ => β) (hh : bH.halt = some h)
    (hs : h.stuck = false) (hr : Rec P g T)
    (hc1 : P.canBe₁ T = true) (hc2 : P.canBe₂ T = true) :
    let r' := run P inp .none (seg 19 20) (idle P g t0 dt now bh fnd false)
    let bC : Book V Tm := { bH with restarts := bH.restarts + 1, halt := none }
    (bH.how = How.atOnce ∧ r' = wk P T (vote g.asks) bC β t0 dt now bh fnd true 39)
    ∨ (bH.how ≠ How.atOnce ∧
        r' = { idle P (cleanG P T (vote g.asks) bC β) t0 dt now bh fnd true with over := true })
    ∨ (∃ h', h'.stuck = false ∧ h'.asked = h.asked ∧
        mend P now g = { g with bk := fun _ => { bH with halt := some h' } } ∧
        r' = { idle P { g with bk := fun _ => { bH with halt := some h' } } t0 dt now bh fnd false
               with over := true }) := by
  intro r' bC
  have hbook : g.book = bH := by rw [Game.book, hbk]; exact vote_const _
  have e : r' = run P inp .none (seg 20 19)
      (step P inp .mend (idle P g t0 dt now bh fnd false)) := by
    show run P inp .none (seg 19 (19 + 1)) _ = _
    rw [seg_succ]; rfl
  rcases mend_ok P now hbk hbf hh hs hr with hm | ⟨h', hs', ha', hm⟩
  · by_cases hhow : bH.how = How.atOnce
    · left
      refine ⟨hhow, ?_⟩
      have e2 : step P inp .mend (idle P g t0 dt now bh fnd false)
          = wk P T (vote g.asks) bC β t0 dt now bh fnd true 20 := by
        rw [wk_20]
        simp [step, idle, Game.halted, hbook, hh, hm, cleanG_book, bC, hhow]
      rw [e, e2]
      exact run_wk P hP inp T _ bC β t0 dt now bh fnd true rfl hc1 hc2 19 20 (by omega) (by omega)
    · right; left
      refine ⟨hhow, ?_⟩
      have e2 : step P inp .mend (idle P g t0 dt now bh fnd false)
          = { idle P (cleanG P T (vote g.asks) bC β) t0 dt now bh fnd true with over := true } := by
        simp [step, idle, Game.halted, hbook, hh, hm, cleanG_book, bC, hhow]
      rw [e, e2]
      exact run_over P inp _ _ rfl
  · right; right
    refine ⟨h', hs', ha', hm, ?_⟩
    have e2 : step P inp .mend (idle P g t0 dt now bh fnd false)
        = { idle P { g with bk := fun _ => { bH with halt := some h' } } t0 dt now bh fnd false
            with over := true } := by
      simp [step, idle, Game.halted, Game.book, hbk, vote_const, hh, hm]
    rw [e, e2]
    exact run_over P inp _ _ rfl

/-! ### R8 to R18: the observers look, the gate looks -/

/-- A round that has not yet worked: it holds nothing that R20 to R38 set. -/
structure Plain (r : Run V Q Tm Dt) : Prop where
  over : r.over = false
  held : r.held = P.blank
  asked : r.asked = fun _ => P.blank
  ruled1 : r.ruled1 = false
  refused : r.refused = none
  made : r.made = fun _ => P.blank
  seen : r.seen = fun _ => P.blank
  heldNow : r.heldNow = P.blank
  recorded : r.recorded = none
  worked : r.worked = false
  ended : r.ended = false

/-- What R8 to R13 can change: of what is stored, an observer's signal, flag and reason
and nothing else; of what the round holds, what it keeps for the looking. -/
structure WF (r r' : Run V Q Tm Dt) : Prop where
  over : r'.over = r.over
  sp : r'.g.sp = r.g.sp
  rt : r'.g.rt = r.g.rt
  rc : r'.g.rc = r.g.rc
  bk : r'.g.bk = r.g.bk
  bf : r'.g.bf = r.g.bf
  asks : r'.g.asks = r.g.asks
  copies : ∀ i, (r'.g.ob i).copies = (r.g.ob i).copies
  t0 : r'.t0 = r.t0
  dt : r'.dt = r.dt
  now : r'.now = r.now
  beganHalted : r'.beganHalted = r.beganHalted
  held : r'.held = r.held
  asked : r'.asked = r.asked
  ruled1 : r'.ruled1 = r.ruled1
  refused : r'.refused = r.refused
  made : r'.made = r.made
  seen : r'.seen = r.seen
  heldNow : r'.heldNow = r.heldNow
  recorded : r'.recorded = r.recorded
  found : r'.found = r.found
  worked : r'.worked = r.worked
  ended : r'.ended = r.ended

theorem WF.refl (r : Run V Q Tm Dt) : WF r r := by constructor <;> intros <;> rfl

theorem WF.trans {r r' r'' : Run V Q Tm Dt} (h : WF r r') (h' : WF r' r'') : WF r r'' := by
  constructor
  · rw [h'.over, h.over]
  · rw [h'.sp, h.sp]
  · rw [h'.rt, h.rt]
  · rw [h'.rc, h.rc]
  · rw [h'.bk, h.bk]
  · rw [h'.bf, h.bf]
  · rw [h'.asks, h.asks]
  · intro i; rw [h'.copies, h.copies]
  · rw [h'.t0, h.t0]
  · rw [h'.dt, h.dt]
  · rw [h'.now, h.now]
  · rw [h'.beganHalted, h.beganHalted]
  · rw [h'.held, h.held]
  · rw [h'.asked, h.asked]
  · rw [h'.ruled1, h.ruled1]
  · rw [h'.refused, h.refused]
  · rw [h'.made, h.made]
  · rw [h'.seen, h.seen]
  · rw [h'.heldNow, h.heldNow]
  · rw [h'.recorded, h.recorded]
  · rw [h'.found, h.found]
  · rw [h'.worked, h.worked]
  · rw [h'.ended, h.ended]

theorem spreadRing_frame (why : Finding) (g : Game V Q Tm) (ring : Ring) :
    (spreadRing why g ring).sp = g.sp ∧ (spreadRing why g ring).rt = g.rt
    ∧ (spreadRing why g ring).rc = g.rc ∧ (spreadRing why g ring).bk = g.bk
    ∧ (spreadRing why g ring).bf = g.bf ∧ (spreadRing why g ring).asks = g.asks
    ∧ ∀ i, ((spreadRing why g ring).ob i).copies = (g.ob i).copies := by
  unfold spreadRing
  split
  · refine ⟨rfl, rfl, rfl, rfl, rfl, rfl, ?_⟩
    intro i; simp only; split <;> rfl
  · exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, fun _ => rfl⟩

/-- Each of R8 to R13 changes no more than `WF` allows. -/
theorem wf_step (inp : Inp Tm Dt) (n : Nat) (h1 : 8 ≤ n) (h2 : n ≤ 13) (r : Run V Q Tm Dt) :
    WF r (step P inp (stepOf n) r) := by
  by_cases ho : r.over = true
  · have : step P inp (stepOf n) r = r := by simp [step, ho]
    rw [this]; exact WF.refl r
  · have hn : n = 8 ∨ n = 9 ∨ n = 10 ∨ n = 11 ∨ n = 12 ∨ n = 13 := by omega
    rcases hn with h | h | h | h | h | h <;> subst h
    · constructor <;> simp [step, ho, stepOf]
    · constructor <;> simp [step, ho, stepOf]
    · constructor <;> simp [step, ho, stepOf]
    · constructor <;> simp [step, ho, stepOf]
      intro i; split
      · split
        · split <;> rfl
        · rfl
      · rfl
    · have key : ∀ (why : Finding) (g : Game V Q Tm),
          let g' := rings.foldl (spreadRing why) (rings.foldl (spreadRing why) g)
          g'.sp = g.sp ∧ g'.rt = g.rt ∧ g'.rc = g.rc ∧ g'.bk = g.bk ∧ g'.bf = g.bf
            ∧ g'.asks = g.asks ∧ ∀ i, (g'.ob i).copies = (g.ob i).copies := by
        intro why g
        simp only [rings, List.foldl]
        have a1 := spreadRing_frame why g ⟨[0, 1, 2, 3], [0, 1, 2]⟩
        have a2 := spreadRing_frame why (spreadRing why g ⟨[0, 1, 2, 3], [0, 1, 2]⟩)
          ⟨[4, 5, 7, 3, 6], [3, 4, 5, 6]⟩
        have a3 := spreadRing_frame why
          (spreadRing why (spreadRing why g ⟨[0, 1, 2, 3], [0, 1, 2]⟩) ⟨[4, 5, 7, 3, 6], [3, 4, 5, 6]⟩)
          ⟨[0, 1, 2, 3], [0, 1, 2]⟩
        have a4 := spreadRing_frame why
          (spreadRing why (spreadRing why (spreadRing why g ⟨[0, 1, 2, 3], [0, 1, 2]⟩)
            ⟨[4, 5, 7, 3, 6], [3, 4, 5, 6]⟩) ⟨[0, 1, 2, 3], [0, 1, 2]⟩)
          ⟨[4, 5, 7, 3, 6], [3, 4, 5, 6]⟩
        refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
        · rw [a4.1, a3.1, a2.1, a1.1]
        · rw [a4.2.1, a3.2.1, a2.2.1, a1.2.1]
        · rw [a4.2.2.1, a3.2.2.1, a2.2.2.1, a1.2.2.1]
        · rw [a4.2.2.2.1, a3.2.2.2.1, a2.2.2.2.1, a1.2.2.2.1]
        · rw [a4.2.2.2.2.1, a3.2.2.2.2.1, a2.2.2.2.2.1, a1.2.2.2.2.1]
        · rw [a4.2.2.2.2.2.1, a3.2.2.2.2.2.1, a2.2.2.2.2.2.1, a1.2.2.2.2.2.1]
        · intro i
          rw [a4.2.2.2.2.2.2 i, a3.2.2.2.2.2.2 i, a2.2.2.2.2.2.2 i, a1.2.2.2.2.2.2 i]
      show WF r (step P inp Step.spread r)
      unfold step
      rw [if_neg ho]
      dsimp only
      split
      · constructor <;> intros <;> rfl
      · next f _ =>
        have k := key (((r.g.ob f).why).getD Finding.flagUp) r.g
        exact ⟨rfl, k.1, k.2.1, k.2.2.1, k.2.2.2.1, k.2.2.2.2.1, k.2.2.2.2.2.1, k.2.2.2.2.2.2,
          rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
    · constructor <;> simp [step, ho, stepOf]

/-- R8 to R13, any stretch of them, change no more than `WF` allows. -/
theorem wf_run (inp : Inp Tm Dt) (k n : Nat) (h1 : 8 ≤ n) (h2 : n + k ≤ 14) (r : Run V Q Tm Dt) :
    WF r (run P inp .none (seg n k) r) := by
  induction k generalizing n r with
  | zero => exact WF.refl r
  | succ k ih =>
    rw [seg_succ]
    simp only [run, inject]
    exact (wf_step P inp n h1 (by omega) r).trans (ih (n + 1) (by omega) (by omega) _)

/-- What R18 lets go of. -/
def reset (r : Run V Q Tm Dt) : Run V Q Tm Dt :=
  { r with running := fun _ => false, look := noLook P, answers := fun _ => none, late := none,
           told := none, stop := false, gateLooks := false, off := none }

theorem differs_none (g : Game V Q Tm) :
    differs P g = none ↔
      selfCheck g = none ∧ stateCheck g = none ∧ obsOff P g = none ∧ asksCheck g = none := by
  simp [differs]

/-- R14 to R18, when the gate looks and nothing is found. -/
theorem gate_pass (inp : Inp Tm Dt) (r : Run V Q Tm Dt) (ho : r.over = false)
    (hh : r.g.halted = false) (hd : differs P r.g = none) (hs : r.stop = false) :
    run P inp .none (seg 14 5) r = reset P r := by
  obtain ⟨h1, h2, h3, h4⟩ := (differs_none P r.g).1 hd
  have : seg 14 5 = [.selfCheck, .stateCheck, .obsCheck, .asksCheck, .decide] := by decide
  rw [this]
  simp [run, inject, step, ho, hh, h1, h2, h3, h4, hs, reset]

/-- R14 to R18, when the gate looks and something is found, by it or by the observers. -/
theorem gate_halt (inp : Inp Tm Dt) (r : Run V Q Tm Dt) (ho : r.over = false)
    (hh : r.g.halted = false) (hd : differs P r.g ≠ none ∨ r.stop = true) :
    ∃ why, run P inp .none (seg 14 5) r
      = reset P { r with g := stopAll why r.now r.g, found := some why } := by
  have : seg 14 5 = [.selfCheck, .stateCheck, .obsCheck, .asksCheck, .decide] := by decide
  rw [this]
  have hd' : ¬ (selfCheck r.g = none ∧ stateCheck r.g = none ∧ obsOff P r.g = none
      ∧ asksCheck r.g = none) ∨ r.stop = true := by
    rcases hd with hd | hd
    · left; rwa [← differs_none]
    · right; exact hd
  cases h1 : selfCheck r.g with
  | some o1 => exact ⟨_, by simp [run, inject, step, ho, hh, h1, reset]; exact ⟨rfl, rfl⟩⟩
  | none =>
    cases h2 : stateCheck r.g with
    | some o2 => exact ⟨_, by simp [run, inject, step, ho, hh, h1, h2, reset]; exact ⟨rfl, rfl⟩⟩
    | none =>
      cases h3 : obsOff P r.g with
      | some o3 => exact ⟨_, by simp [run, inject, step, ho, hh, h1, h2, h3, reset]; exact ⟨rfl, rfl⟩⟩
      | none =>
        cases h4 : asksCheck r.g with
        | some o4 => exact ⟨_, by simp [run, inject, step, ho, hh, h1, h2, h3, h4, reset]; exact ⟨rfl, rfl⟩⟩
        | none =>
          have hs : r.stop = true := by
            rcases hd' with hd' | hd'
            · exact (hd' ⟨h1, h2, h3, h4⟩).elim
            · exact hd'
          exact ⟨_, by simp [run, inject, step, ho, hh, h1, h2, h3, h4, hs, reset]; exact ⟨rfl, rfl⟩⟩

theorem reset_idle {r r₁ : Run V Q Tm Dt} (hw : WF r r₁) (hp : Plain P r) (g' : Game V Q Tm)
    (f : Option Cause) :
    reset P { r₁ with g := g', found := f } = idle P g' r.t0 r.dt r.now r.beganHalted f false := by
  simp [reset, idle, hw.over, hp.over, hw.t0, hw.dt, hw.now, hw.beganHalted, hw.held, hp.held,
    hw.asked, hp.asked, hw.ruled1, hp.ruled1, hw.refused, hp.refused, hw.made, hp.made, hw.seen,
    hp.seen, hw.heldNow, hp.heldNow, hw.recorded, hp.recorded, hw.worked, hp.worked, hw.ended,
    hp.ended]

/-- R8 to R18, from any of R8 to R14 on, in a round that has not yet worked and is not
halted. What is stored is unchanged but for the observers' signals, flags and reasons.
Then either everything halts, or the gate found nothing (`differs`) and nothing halts. -/
theorem gateAny (inp : Inp Tm Dt) (j : Nat) (h1 : 8 ≤ j) (h2 : j ≤ 14) (r : Run V Q Tm Dt)
    (hp : Plain P r) {bb : Book V Tm} (hbk : r.g.bk = fun _ => bb) (hb : bb.halt = none) :
    ∃ g₁ : Game V Q Tm, g₁.sp = r.g.sp ∧ g₁.rt = r.g.rt ∧ g₁.rc = r.g.rc ∧ g₁.bk = r.g.bk
      ∧ g₁.bf = r.g.bf ∧ g₁.asks = r.g.asks ∧ (∀ i, (g₁.ob i).copies = (r.g.ob i).copies)
      ∧ ((∃ why, run P inp .none (seg j (19 - j)) r
              = idle P (stopAll why r.now g₁) r.t0 r.dt r.now r.beganHalted (some why) false)
          ∨ (differs P g₁ = none ∧ run P inp .none (seg j (19 - j)) r
              = idle P g₁ r.t0 r.dt r.now r.beganHalted r.found false)) := by
  have hw : WF r (run P inp .none (seg j (14 - j)) r) := wf_run P inp (14 - j) j h1 (by omega) r
  have hsplit : seg j (19 - j) = seg j (14 - j) ++ seg 14 5 := by
    rw [show 19 - j = (14 - j) + 5 by omega, seg_add, show j + (14 - j) = 14 by omega]
  rw [hsplit, run_append]
  generalize run P inp .none (seg j (14 - j)) r = r₁ at hw
  have ho : r₁.over = false := by rw [hw.over, hp.over]
  have hh : r₁.g.halted = false := by
    simp [Game.halted, Game.book, hw.bk, hbk, vote_const, hb]
  refine ⟨r₁.g, hw.sp, hw.rt, hw.rc, hw.bk, hw.bf, hw.asks, hw.copies, ?_⟩
  by_cases hd : differs P r₁.g = none ∧ r₁.stop = false
  · right
    refine ⟨hd.1, ?_⟩
    rw [gate_pass P inp r₁ ho hh hd.1 hd.2]
    have := reset_idle P hw hp r₁.g r₁.found
    exact this.trans (by rw [hw.found])
  · left
    have hd' : differs P r₁.g ≠ none ∨ r₁.stop = true := by
      by_cases h : differs P r₁.g = none
      · right
        cases hs : r₁.stop with
        | true => rfl
        | false => exact (hd ⟨h, hs⟩).elim
      · left; exact h
    obtain ⟨why, hwhy⟩ := gate_halt P inp r₁ ho hh hd'
    refine ⟨why, ?_⟩
    rw [hwhy, reset_idle P hw hp, hw.now]

/-! ### R26 to R38: the gate checks the work, and the round is recorded or refused -/

/-- R16, R32: if the gate finds nothing in the observers, each is as a new one would be. -/
theorem obsOff_none {g : Game V Q Tm} (h : obsOff P g = none) (i : Who) : g.ob i = born P g i := by
  have h' := List.findSome?_eq_none_iff.1 h i (mem_allWho i)
  generalize ho : g.ob i = o at h'
  cases o with
  | mk name alive beat copies held flagged why =>
    simp only [obsOff] at h'
    by_cases c1 : name = i.val
    · by_cases c2 : alive = true
      · by_cases c3 : beat = g.book.rounds
        · by_cases c4 : copies = copiesFor P i g.rt
          · by_cases c5 : held = heldOf P g i
            · by_cases c6 : flagged = true ∨ why.isSome = true
              · simp [c1, c2, c3, c4, c5, c6] at h'
              · have c7 : flagged = false := by
                  cases flagged <;> simp_all
                have c8 : why = none := by
                  cases why <;> simp_all
                simp [born, c1, c2, c3, c4, c5, c7, c8]
            · simp [c1, c2, c3, c4, c5] at h'
          · simp [c1, c2, c3, c4] at h'
            split at h' <;> simp at h'
        · simp [c1, c2, c3] at h'
      · simp [c1, c2] at h'
    · simp [c1] at h'

/-- What one of R26 to R32 does: it writes nothing that is stored, and it can only
refuse. `n` is the number of the step. -/
structure LCF (n : Nat) (r₀ r₁ : Run V Q Tm Dt) : Prop where
  g : r₁.g = r₀.g
  over : r₁.over = r₀.over
  dt : r₁.dt = r₀.dt
  now : r₁.now = r₀.now
  t0 : r₁.t0 = r₀.t0
  beganHalted : r₁.beganHalted = r₀.beganHalted
  found : r₁.found = r₀.found
  recorded : r₁.recorded = r₀.recorded
  worked : r₁.worked = r₀.worked
  ended : r₁.ended = r₀.ended
  ref : r₁.refused = none → r₀.refused = none
  made : r₁.refused = none →
    r₁.made = if n = 30 then P.redo r₀.g.rc (r₀.g.asks 1) r₀.dt r₀.now else r₀.made
  cmp : n = 31 → r₁.refused = none → r₀.made = r₀.g.sp
  obs : n = 32 → r₁.refused = none → obsOff P r₀.g = none

theorem lc_step (inp : Inp Tm Dt) (n : Nat) (h1 : 26 ≤ n) (h2 : n ≤ 32) (r : Run V Q Tm Dt)
    (ho : r.over = false) : LCF P n r (step P inp (stepOf n) r) := by
  have hn : n = 26 ∨ n = 27 ∨ n = 28 ∨ n = 29 ∨ n = 30 ∨ n = 31 ∨ n = 32 := by omega
  rcases hn with h | h | h | h | h | h | h <;> subst h
  · constructor <;> simp [step, ho, stepOf] <;> (try (split <;> simp_all))
  · constructor <;> simp [step, ho, stepOf] <;> (try (split <;> simp_all))
  · constructor <;> simp [step, ho, stepOf] <;> (try (split <;> simp_all))
  · constructor <;> simp [step, ho, stepOf] <;> (try (split <;> simp_all))
  · constructor <;> simp [step, ho, stepOf] <;> (try (split <;> simp_all))
  · constructor <;> simp [step, ho, stepOf] <;> (try (split <;> simp_all))
  · cases hob : obsOff P r.g <;> by_cases hr : r.refused = none <;>
      constructor <;> simp [step, ho, stepOf, hob, hr]

/-- What a stretch of R26 to R32 does, from step `n`, `k` steps long. -/
structure LCS (n k : Nat) (r₀ r₁ : Run V Q Tm Dt) : Prop where
  g : r₁.g = r₀.g
  over : r₁.over = r₀.over
  dt : r₁.dt = r₀.dt
  now : r₁.now = r₀.now
  t0 : r₁.t0 = r₀.t0
  beganHalted : r₁.beganHalted = r₀.beganHalted
  found : r₁.found = r₀.found
  recorded : r₁.recorded = r₀.recorded
  worked : r₁.worked = r₀.worked
  ended : r₁.ended = r₀.ended
  ref : r₁.refused = none → r₀.refused = none
  made : r₁.refused = none →
    r₁.made = if n ≤ 30 ∧ 30 < n + k then P.redo r₀.g.rc (r₀.g.asks 1) r₀.dt r₀.now else r₀.made
  cmp : n ≤ 31 → 31 < n + k → r₁.refused = none → r₁.made = r₀.g.sp
  obs : n ≤ 32 → 32 < n + k → r₁.refused = none → obsOff P r₀.g = none

theorem lc_run (inp : Inp Tm Dt) (k n : Nat) (h1 : 26 ≤ n) (h2 : n + k ≤ 33)
    (r : Run V Q Tm Dt) (ho : r.over = false) : LCS P n k r (run P inp .none (seg n k) r) := by
  induction k generalizing n r with
  | zero =>
    refine ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, id, ?_, ?_, ?_⟩
    · intro _; simp [seg, run]; omega
    · intro a b; omega
    · intro a b; omega
  | succ k ih =>
    rw [seg_succ]
    simp only [run, inject]
    have f := lc_step P inp n h1 (by omega) r ho
    have i := ih (n + 1) (by omega) (by omega) _ (by rw [f.over, ho])
    generalize step P inp (stepOf n) r = rm at f i
    generalize run P inp .none (seg (n + 1) k) rm = r1 at i
    refine ⟨by rw [i.g, f.g], by rw [i.over, f.over], by rw [i.dt, f.dt], by rw [i.now, f.now],
      by rw [i.t0, f.t0], by rw [i.beganHalted, f.beganHalted], by rw [i.found, f.found],
      by rw [i.recorded, f.recorded], by rw [i.worked, f.worked], by rw [i.ended, f.ended],
      fun h => f.ref (i.ref h), ?_, ?_, ?_⟩
    · intro h
      have hm := f.made (i.ref h)
      rw [i.made h, f.g, f.dt, f.now, hm]
      by_cases hn : n = 30
      · subst hn; simp
      · by_cases c : n ≤ 30 ∧ 30 < n + (k + 1)
        · have c' : n + 1 ≤ 30 ∧ 30 < n + 1 + k := by omega
          simp [c, c']
        · have c' : ¬ (n + 1 ≤ 30 ∧ 30 < n + 1 + k) := by omega
          rw [if_neg c', if_neg hn, if_neg c]
    · intro a b h
      by_cases hn : n = 31
      · subst hn
        rw [i.made h, f.made (i.ref h)]
        simpa using f.cmp rfl (i.ref h)
      · rw [i.cmp (by omega) (by omega) h, f.g]
    · intro a b h
      by_cases hn : n = 32
      · subst hn; exact f.obs rfl (i.ref h)
      · have := i.obs (by omega) (by omega) h
        rwa [f.g] at this

/-- R33 to R38, when the round was not refused and the observers are as new ones would
be: the round is recorded. -/
theorem lr_rec (inp : Inp Tm Dt) (r : Run V Q Tm Dt) {bb : Book V Tm} (ho : r.over = false)
    (hr : r.refused = none) (hbk : r.g.bk = fun _ => bb) (hob : ∀ i, r.g.ob i = born P r.g i) :
    let r' := run P inp .none (seg 33 6) r
    r'.g = { sp := r.g.sp,
             ob := fun i => freshOb P i r.g.sp bb.rounds (P.inWeb₁ r.g.sp),
             rt := r.made, rc := r.made,
             bk := fun _ => { bb with spoiled := 0,
                                      stops := if r.beganHalted = true then bb.stops else 0 },
             bf := r.g.bf, asks := fun _ => P.noAsks }
      ∧ r'.recorded = some r.made ∧ r'.found = r.found ∧ r'.over = false ∧ r'.dt = r.dt
      ∧ r'.now = r.now ∧ r'.worked = r.worked ∧ r'.ended = r.ended := by
  have : seg 33 6 = [.see, .takeCopies, .takeHeld, .writeRecord, .emptyAsks, .close] := by decide
  have hbook : r.g.book = bb := by rw [Game.book, hbk]; exact vote_const _
  have hob' : r.g.ob = born P r.g := funext hob
  rw [this]
  simp [run, inject, step, ho, hr, sound, Game.book, hbk, vote_const, keep, hob', born, freshOb]
  funext i
  by_cases hi : i = moths <;> simp [hi, heldOf]

/-- R33 to R38, when the round was refused: everything halts, and the count of refused
rounds goes up by one (from nought: so the halt is not one that stays). -/
theorem lr_ref (inp : Inp Tm Dt) (r : Run V Q Tm Dt) {bb : Book V Tm} {why : Cause}
    (ho : r.over = false) (hr : r.refused = some why) (hbk : r.g.bk = fun _ => bb)
    (hsp : bb.spoiled = 0) :
    run P inp .none (seg 33 6) r
      = { r with g := keep (fun b => { b with spoiled := b.spoiled + 1 }) (stopAll why r.now r.g),
                 found := some why } := by
  have : seg 33 6 = [.see, .takeCopies, .takeHeld, .writeRecord, .emptyAsks, .close] := by decide
  rw [this]
  simp [run, inject, step, ho, hr, Game.book, hbk, vote_const, keep, stopAll, hsp]

/-! ### What a round can leave, across rounds -/

/-- Halted, in a way that can be put right to the record `T`, with `N` halts counted. -/
def HR (g : Game V Q Tm) (T : St V) (N : Nat) : Prop :=
  ∃ (bH : Book V Tm) (h : Halt V Tm) (β' : Option (St V)),
    (g.bk = fun _ => bH) ∧ bH.halt = some h ∧ h.stuck = false ∧ bH.spoiled ≤ 1 ∧ bH.stops = 0
    ∧ bH.halts = N ∧ (g.bf = fun _ => β') ∧ Rec P g T
    ∧ P.canBe₁ T = true ∧ P.canBe₂ T = true

/-- Everything agrees, with the record `T` and `N` halts counted; a round may have been
refused since the last one recorded. -/
def Mended (g : Game V Q Tm) (T : St V) (N : Nat) : Prop :=
  Settled P g ∧ g.rt = T ∧ (g.bk 0).spoiled ≤ 1 ∧ (g.bk 0).stops = 0 ∧ (g.bk 0).halts = N

/-- A cell that is not one of the gate's own in three places. -/
def Cell.isOpen : Cell V Q Tm → Bool
  | .bk _ _ => false
  | .bf _ _ => false
  | _ => true

theorem selfCheck_none {g : Game V Q Tm} (h : selfCheck g = none) : g.rt = g.rc := by
  funext p
  have := List.findSome?_eq_none_iff.1 h p (mem_allParts p)
  by_cases hp : g.rt p = g.rc p
  · exact hp
  · simp [hp] at this

theorem stateCheck_none {g : Game V Q Tm} (h : stateCheck g = none) : g.rt = g.sp := by
  funext p
  have := List.findSome?_eq_none_iff.1 h p (mem_allParts p)
  by_cases hp : g.rt p = g.sp p
  · exact hp
  · simp [hp] at this

theorem asksCheck_none {g : Game V Q Tm} (h : asksCheck g = none) :
    g.asks 0 = g.asks 1 ∧ g.asks 0 = g.asks 2 := by
  simp only [asksCheck] at h
  by_cases h1 : g.asks 0 = g.asks 1
  · by_cases h2 : g.asks 0 = g.asks 2
    · exact ⟨h1, h2⟩
    · simp [h1] at h
      exact (h2 (h1.trans h)).elim
  · simp [h1] at h

/-- From any of R26 to R32 to the end of the round, with no fault on the way, in a round
that has not been refused so far. Either the gate refuses it: nothing is recorded,
everything halts, and nothing stored has changed but the book. Or it is recorded: what
is recorded, `M`, is what the second doing made (or had made, if R30 is past), it is the
state (if R31 was still to come), the observers were as new ones would be, and what is
stored afterwards is as written here. -/
theorem tail_from (inp : Inp Tm Dt) (m : Nat) (h1 : 26 ≤ m) (h2 : m ≤ 32) (r₀ : Run V Q Tm Dt)
    {bb : Book V Tm} (ho : r₀.over = false) (hr : r₀.refused = none)
    (hbk : r₀.g.bk = fun _ => bb) (hsp : bb.spoiled = 0) :
    let r' := run P inp .none (seg m (39 - m)) r₀
    (∃ why, r'.g = keep (fun b => { b with spoiled := b.spoiled + 1 }) (stopAll why r₀.now r₀.g)
        ∧ r'.found = some why ∧ r'.recorded = r₀.recorded ∧ r'.dt = r₀.dt ∧ r'.now = r₀.now
        ∧ r'.ended = r₀.ended ∧ r'.worked = r₀.worked)
    ∨ (∃ M, (m ≤ 30 → M = P.redo r₀.g.rc (r₀.g.asks 1) r₀.dt r₀.now) ∧ (30 < m → M = r₀.made)
        ∧ (m ≤ 31 → M = r₀.g.sp) ∧ obsOff P r₀.g = none
        ∧ r'.g = { sp := r₀.g.sp,
                   ob := fun i => freshOb P i r₀.g.sp bb.rounds (P.inWeb₁ r₀.g.sp),
                   rt := M, rc := M,
                   bk := fun _ => { bb with spoiled := 0,
                                            stops := if r₀.beganHalted = true then bb.stops else 0 },
                   bf := r₀.g.bf, asks := fun _ => P.noAsks }
        ∧ r'.recorded = some M ∧ r'.found = r₀.found ∧ r'.dt = r₀.dt ∧ r'.now = r₀.now
        ∧ r'.worked = r₀.worked ∧ r'.ended = r₀.ended) := by
  intro r'
  have e : r' = run P inp .none (seg 33 6) (run P inp .none (seg m (33 - m)) r₀) := by
    show run P inp .none (seg m (39 - m)) r₀ = _
    rw [show 39 - m = (33 - m) + 6 by omega, seg_add, run_append, show m + (33 - m) = 33 by omega]
  have L := lc_run P inp (33 - m) m h1 (by omega) r₀ ho
  generalize run P inp .none (seg m (33 - m)) r₀ = rA at e L
  have hoA : rA.over = false := by rw [L.over, ho]
  have hbkA : rA.g.bk = fun _ => bb := by rw [L.g, hbk]
  cases hA : rA.refused with
  | some why =>
    left
    refine ⟨why, ?_⟩
    rw [e, lr_ref P inp rA hoA hA hbkA hsp]
    exact ⟨by simp [L.g, L.now], rfl, L.recorded, L.dt, L.now, L.ended, L.worked⟩
  | none =>
    right
    have hob := L.obs (by omega) (by omega) hA
    have hmade := L.made hA
    have hl := lr_rec P inp rA hoA hA hbkA (fun i => by rw [L.g]; exact obsOff_none P hob i)
    simp only at hl
    obtain ⟨g1, g2, g3, _, g5, g6, g7, g8⟩ := hl
    refine ⟨rA.made, ?_, ?_, ?_, hob, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro hm; rw [hmade, if_pos ⟨hm, by omega⟩]
    · intro hm; rw [hmade, if_neg (by omega)]
    · intro hm; exact L.cmp hm (by omega) hA
    · rw [e, g1, L.g, L.beganHalted]
    · rw [e, g2]
    · rw [e, g3, L.found]
    · rw [e, g5, L.dt]
    · rw [e, g6, L.now]
    · rw [e, g7, L.worked]
    · rw [e, g8, L.ended]

end
end Gate
