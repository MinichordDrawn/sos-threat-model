/-
Putting right (section 9 of the specification): when `restore` succeeds, and what
`correct` and `mend` then leave.
-/
import GateProof.Proofs.Basic

set_option linter.unusedSectionVars false
set_option linter.deprecated false
set_option linter.unusedSimpArgs false

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)

theorem mem_allWho (i : Who) : i ∈ allWho := by revert i; decide
theorem mem_allParts (p : Part) : p ∈ allParts := by revert p; decide

/-- Every observer that sees `p` holds the text `t` of it (D9, as a statement). -/
def HoldAll (g : Game V Q Tm) (p : Part) (t : V) : Prop :=
  ∀ i, sees i p = true → (g.ob i).copies p = P.holds i t

theorem allHold_iff (g : Game V Q Tm) (p : Part) (t : V) :
    allHold P g p t = true ↔ HoldAll P g p t := by
  simp only [allHold, List.all_eq_true, HoldAll]
  constructor
  · intro h i hs
    have := h i (mem_allWho i)
    simpa [hs] using this
  · intro h i _
    by_cases hs : sees i p = true
    · simp [hs, h i hs]
    · simp [hs]

/-- The observers of a part cannot all hold two different texts of it: one of them is no
coordinator, and holds the text itself. -/
theorem holdAll_unique {g : Game V Q Tm} {p : Part} {t t' : V}
    (h : HoldAll P g p t) (h' : HoldAll P g p t') : t = t' := by
  obtain ⟨i, hs, hc⟩ := seen_whole p
  have a := h i hs
  have b := h' i hs
  simp [Params.holds, hc] at a b
  rw [← a, ← b]

/-- One part can be put right to `T`: the record's two halves both say `T`, or one of
them does, every observer of the part holds `T`, and the state or `before` says `T`. -/
def PartOk (g : Game V Q Tm) (T : St V) (β : Option (St V)) (p : Part) : Prop :=
  (g.rt p = T p ∧ g.rc p = T p)
  ∨ ((g.rt p = T p ∨ g.rc p = T p) ∧ HoldAll P g p (T p)
      ∧ (g.sp p = T p ∨ β.map (fun s => s p) = some (T p)))

/-- A game that `restore` can put right, to the record `T`. -/
def Rec (g : Game V Q Tm) (T : St V) : Prop :=
  (∃ β, (g.bf = fun _ => β) ∧ ∀ p, PartOk P g T β p)
  ∧ (g.asks 0 = g.asks 1 ∨ g.asks 0 = g.asks 2 ∨ g.asks 1 = g.asks 2)

/-- `g` with part `p` of the state and of both halves of the record set to `t`. -/
def setPart (g : Game V Q Tm) (p : Part) (t : V) : Game V Q Tm :=
  { g with sp := fun q => if q = p then t else g.sp q,
           rt := fun q => if q = p then t else g.rt q,
           rc := fun q => if q = p then t else g.rc q }

theorem fun_upd_same {α : Type} (f : Part → α) (p : Part) (t : α) (h : f p = t) :
    (fun q => if q = p then t else f q) = f := by
  funext q; by_cases hq : q = p <;> simp [hq, h]

/-- P4: a part that can be put right is put right. -/
theorem restorePart_ok {g : Game V Q Tm} {T : St V} {β : Option (St V)} {p : Part}
    (h : PartOk P g T β p) : restorePart P β p g = (setPart g p (T p), true) := by
  have key : ∀ t, t ≠ T p → allHold P g p t = true → HoldAll P g p (T p) → False := by
    intro t ht h1 h2
    exact ht (holdAll_unique P ((allHold_iff P g p t).1 h1) h2)
  rcases h with ⟨h1, h2⟩ | ⟨h1, h2, h3⟩
  · -- both halves say `T`
    by_cases hs : g.sp p = T p
    · simp [restorePart, setPart, h1, h2, hs, fun_upd_same]
    · simp [restorePart, setPart, h1, h2, hs, fun_upd_same]
  · have hall : allHold P g p (T p) = true := (allHold_iff P g p (T p)).2 h2
    by_cases hk : g.rt p = g.rc p
    · -- the halves agree, so both say `T`
      have h1' : g.rt p = T p ∧ g.rc p = T p := by
        rcases h1 with h1 | h1
        · exact ⟨h1, hk ▸ h1⟩
        · exact ⟨hk.trans h1, h1⟩
      by_cases hs : g.sp p = T p
      · simp [restorePart, setPart, h1'.1, h1'.2, hs, fun_upd_same]
      · simp [restorePart, setPart, h1'.1, h1'.2, hs, fun_upd_same]
    · rcases h1 with h1 | h1
      · -- the text says `T`, the copy does not
        have hc : g.rc p ≠ T p := fun h => hk (h1.trans h.symm)
        have hno : allHold P g p (g.rc p) = false := by
          cases hh : allHold P g p (g.rc p) with
          | false => rfl
          | true => exact (key _ hc hh h2).elim
        by_cases hs : g.sp p = T p
        · simp [restorePart, setPart, h1, hs, hall, hk, fun_upd_same, Ne.symm hc]
        · have hb : β.map (fun s => s p) = some (T p) := by
            rcases h3 with h3 | h3
            · exact (hs h3).elim
            · exact h3
          simp [restorePart, setPart, h1, hs, hall, hk, fun_upd_same, Ne.symm hc, hno, hb]
      · -- the copy says `T`, the text does not
        have hc : g.rt p ≠ T p := fun h => hk (h.trans h1.symm)
        have hno : allHold P g p (g.rt p) = false := by
          cases hh : allHold P g p (g.rt p) with
          | false => rfl
          | true => exact (key _ hc hh h2).elim
        by_cases hs : g.sp p = T p
        · simp [restorePart, setPart, h1, hs, hall, hk, fun_upd_same, hc, hno]
        · have hb : β.map (fun s => s p) = some (T p) := by
            rcases h3 with h3 | h3
            · exact (hs h3).elim
            · exact h3
          simp [restorePart, setPart, h1, hs, hall, hk, fun_upd_same, hc, hno, hb]

theorem partOk_setPart {g : Game V Q Tm} {T : St V} {β : Option (St V)} (p q : Part)
    (h : PartOk P g T β q) : PartOk P (setPart g p (T p)) T β q := by
  by_cases hq : q = p
  · subst hq; left; simp [setPart]
  · rcases h with h | ⟨h1, h2, h3⟩
    · left; simpa [setPart, hq] using h
    · right
      refine ⟨by simpa [setPart, hq] using h1, ?_, by simpa [setPart, hq] using h3⟩
      intro i hs; simpa [setPart] using h2 i hs

/-- P3: the parts are put right one after another. -/
theorem restoreParts_ok {T : St V} {β : Option (St V)} (l : List Part) (g : Game V Q Tm)
    (h : ∀ p, PartOk P g T β p) :
    restoreParts P β l g =
      ({ g with sp := fun q => if q ∈ l then T q else g.sp q,
                rt := fun q => if q ∈ l then T q else g.rt q,
                rc := fun q => if q ∈ l then T q else g.rc q }, true) := by
  induction l generalizing g with
  | nil => simp [restoreParts]
  | cons p l ih =>
    simp only [restoreParts, restorePart_ok P (h p)]
    rw [ite_true, ih (setPart g p (T p)) (fun q => partOk_setPart P p q (h q))]
    congr 1
    simp only [setPart]
    congr 1 <;> funext q <;> by_cases hq : q = p <;> by_cases hl : q ∈ l <;> simp [hq, hl]

/-- P3, P5: a game that can be put right is put right: the state and both halves of the
record are `T`, and the three lists are the voted list. -/
theorem restore_ok {g : Game V Q Tm} {T : St V} (h : Rec P g T) :
    restore P g = ({ g with sp := T, rt := T, rc := T, asks := fun _ => vote g.asks }, true) := by
  obtain ⟨⟨β, hβ, hp⟩, ha⟩ := h
  have hv : vote g.bf = β := by rw [hβ]; exact vote_const β
  have hT : ∀ f : St V, (fun q => if q ∈ allParts then T q else f q) = T := by
    intro f; funext q; simp [mem_allParts]
  simp only [restore, hv, restoreParts_ok P allParts g hp, hT, restoreAsks]
  by_cases hall : g.asks 0 = g.asks 1 ∧ g.asks 0 = g.asks 2
  · have e : (fun _ : Fin 3 => vote g.asks) = g.asks := by
      funext k
      have hv : vote g.asks = g.asks 0 := by simp [vote, hall.1]
      rcases fin3 k with hk | hk | hk <;> subst hk <;> simp [hv, ← hall.1, ← hall.2]
    rw [e]
    simp [hall]
  · have h3 : g.asks 0 = g.asks 1 ∨ g.asks 0 = g.asks 2 ∨ g.asks 1 = g.asks 2 := ha
    simp [hall, h3]

/-- P2: `correct`, on a game that can be put right, leaves everything agreeing, with the
record `T`, the voted list in all three lists, and the halt over. -/
theorem correct_ok {g : Game V Q Tm} {T : St V} {bH : Book V Tm} {β : Option (St V)}
    (hbk : g.bk = fun _ => bH) (hbf : g.bf = fun _ => β) (h : Rec P g T) :
    correct P g
      = cleanG P T (vote g.asks) { bH with restarts := bH.restarts + 1, halt := none } β := by
  cases g with
  | mk sp ob rt rc bk bf asks =>
    simp only at hbk hbf
    subst hbk hbf
    have hborn : ∀ (ob' : Who → Observer V) (asks' : Fin 3 → Q),
        born P ({ sp := T, ob := ob', rt := T, rc := T, bk := fun _ => bH, bf := fun _ => β,
                  asks := asks' } : Game V Q Tm)
          = fun i => ⟨i.val, true, bH.rounds, copiesFor P i T,
              if i = moths then P.inWeb₁ T else P.blank, false, none⟩ := by
      intro ob' asks'; funext i; simp [born, heldOf, Game.book, vote_const]
    simp [correct, restore_ok P h, hborn, heldOf, Game.book, vote_const, keep, lookOf_clean',
      differs, selfCheck, stateCheck, asksCheck, obsOff_clean', cleanG, freshOb, allWho, allParts,
      List.findSome?]

/-- P1: `mend`, on a halted game that can be put right. Either the halt is over and
everything agrees, or everything is still halted: nothing has changed but what the halt
has seen (`last`, `quiet`). -/
theorem mend_ok {g : Game V Q Tm} {T : St V} {bH : Book V Tm} {β : Option (St V)}
    {h : Halt V Tm} (now : Tm)
    (hbk : g.bk = fun _ => bH) (hbf : g.bf = fun _ => β) (hh : bH.halt = some h)
    (hs : h.stuck = false) (hr : Rec P g T) :
    mend P now g
        = cleanG P T (vote g.asks) { bH with restarts := bH.restarts + 1, halt := none } β
      ∨ (∃ h', h'.stuck = false ∧ h'.asked = h.asked ∧
          mend P now g = { g with bk := fun _ => { bH with halt := some h' } }) := by
  have hbook : g.book = bH := by rw [Game.book, hbk]; exact vote_const _
  have hc := correct_ok P hbk hbf hr
  have heta : ({ bH with halt := some h } : Book V Tm) = bH := by cases bH; simp_all
  have hg : ({ g with bk := fun _ => { bH with halt := some h } } : Game V Q Tm) = g := by
    rw [heta, ← hbk]
  by_cases ha : h.asked = true
  · left; simp [mend, hbook, hh, hs, ha, hc]
  · have ha' : h.asked = false := by simpa using ha
    by_cases h1 : bH.how = How.atOnce
    · left; simp [mend, hbook, hh, hs, ha', hc, h1]
    · by_cases h2 : bH.how = How.onAClick
      · right
        refine ⟨h, hs, rfl, ?_⟩
        rw [hg]; simp [mend, hbook, hh, hs, ha', h2]
      · have h3 : bH.how = How.afterAPause := by
          cases hh' : bH.how <;> simp_all
        by_cases hch : h.last = some g.sp
        · by_cases hp : P.pauseOver h.quiet now = true
          · left; simp [mend, hbook, hh, hs, ha', h3, hch, hp, hc]
          · right
            refine ⟨h, hs, rfl, ?_⟩
            rw [hg]; simp [mend, hbook, hh, hs, ha', h3, hch, hp]
        · have hbk' : (keep (fun b : Book V Tm => { b with
              halt := b.halt.map fun h => { h with last := some g.sp, quiet := now } }) g).bk
              = fun _ => { bH with halt := some { h with last := some g.sp, quiet := now } } := by
            simp [keep, hbk, hh]
          by_cases hp : P.pauseOver now now = true
          · left
            have hr' : Rec P (keep (fun b : Book V Tm => { b with
                halt := b.halt.map fun h => { h with last := some g.sp, quiet := now } }) g) T := hr
            have hc' := correct_ok P hbk' (g := keep _ g) hbf hr'
            simp [mend, hbook, hh, hs, ha', h3, hch, hp, hc']
            rfl
          · right
            refine ⟨{ h with last := some g.sp, quiet := now }, hs, rfl, ?_⟩
            simp [mend, hbook, hh, hs, ha', h3, hch, hp]
            simp [keep, hbk, hh, ha', hs, h3]

/-- P1, W1 to W3: when `mend` does end the halt. Set to end at once; or asked; or, set to
end after a pause, the pause is over (counted from `quiet` if the state is as the halt
last saw it, and from now if not). -/
theorem mend_ends {g : Game V Q Tm} {T : St V} {bH : Book V Tm} {β : Option (St V)}
    {h : Halt V Tm} (now : Tm)
    (hbk : g.bk = fun _ => bH) (hbf : g.bf = fun _ => β) (hh : bH.halt = some h)
    (hs : h.stuck = false) (hr : Rec P g T)
    (hc : bH.how = How.atOnce ∨ h.asked = true
          ∨ (bH.how = How.afterAPause
              ∧ P.pauseOver (if h.last = some g.sp then h.quiet else now) now = true)) :
    mend P now g
      = cleanG P T (vote g.asks) { bH with restarts := bH.restarts + 1, halt := none } β := by
  have hbook : g.book = bH := by rw [Game.book, hbk]; exact vote_const _
  have hcor := correct_ok P hbk hbf hr
  by_cases ha : h.asked = true
  · simp [mend, hbook, hh, hs, ha, hcor]
  · have ha2 : h.asked = false := by simpa using ha
    rcases hc with h1 | h1 | ⟨h3, hp⟩
    · simp [mend, hbook, hh, hs, ha2, hcor, h1]
    · exact (ha h1).elim
    · by_cases hch : h.last = some g.sp
      · rw [if_pos hch] at hp
        simp [mend, hbook, hh, hs, ha2, h3, hch, hp, hcor]
      · rw [if_neg hch] at hp
        have hbk2 : (keep (fun b : Book V Tm => { b with
            halt := b.halt.map fun h => { h with last := some g.sp, quiet := now } }) g).bk
            = fun _ => { bH with halt := some { h with last := some g.sp, quiet := now } } := by
          simp [keep, hbk, hh]
        have hr2 : Rec P (keep (fun b : Book V Tm => { b with
            halt := b.halt.map fun h => { h with last := some g.sp, quiet := now } }) g) T := hr
        have hc2 := correct_ok P hbk2 (g := keep _ g) hbf hr2
        simp [mend, hbook, hh, hs, ha2, h3, hch, hp, hc2]
        rfl

end
end Gate
