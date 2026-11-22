/-
Small facts the proofs rest on: voting, the form of a clean game, and what the
observers and the gate find in one (nothing).
-/
import GateProof.Claims

set_option linter.unusedSectionVars false
set_option linter.deprecated false

namespace Gate

theorem fin3 (k : Fin 3) : k = 0 ∨ k = 1 ∨ k = 2 := by revert k; decide

theorem vote_const {α : Type} [DecidableEq α] (a : α) : vote (fun _ : Fin 3 => a) = a := by
  simp [vote]

/-- One place of three that agree is changed: what is read is unchanged. -/
theorem vote_hit {α : Type} [DecidableEq α] (a b : α) (k : Fin 3) :
    vote (fun j => if j = k then b else a) = a := by
  rcases fin3 k with h | h | h <;> subst h <;> by_cases hb : b = a <;> simp [vote, hb] <;>
    (intro h; exact absurd h.symm hb)

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)

/-- An observer as a new one is: with its copies from `T`, its signal `ρ`, and, for the
moths observer, the list `h`. -/
def freshOb (i : Who) (T : St V) (ρ : Nat) (h : V) : Observer V :=
  { name := i.val, alive := true, beat := ρ, copies := copiesFor P i T,
    held := if i = moths then h else P.blank, flagged := false, why := none }

/-- The form of a game in which everything agrees: record `T`, lists `A`, book `b`,
`before` `β`. -/
def cleanG (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V)) : Game V Q Tm :=
  { sp := T, ob := fun i => freshOb P i T b.rounds (P.inWeb₁ T), rt := T, rc := T,
    bk := fun _ => b, bf := fun _ => β, asks := fun _ => A }

@[simp] theorem cleanG_book (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V)) :
    (cleanG P T A b β).book = b := by
  simp [Game.book, cleanG, vote_const]

theorem born_cleanG (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V)) (i : Who) :
    born P (cleanG P T A b β) i = freshOb P i T b.rounds (P.inWeb₁ T) := by
  simp [born, freshOb, heldOf, cleanG, Game.book, vote_const]

theorem settled_form {g : Game V Q Tm} (h : Settled P g) :
    g = cleanG P g.rt (g.asks 0) (g.bk 0) (g.bf 0) := by
  have hb : g.bk = fun _ => g.bk 0 := by
    funext k; rcases fin3 k with h' | h' | h' <;> subst h' <;> simp [← h.books.1, ← h.books.2]
  have hf : g.bf = fun _ => g.bf 0 := by
    funext k; rcases fin3 k with h' | h' | h' <;> subst h' <;> simp [← h.before.1, ← h.before.2]
  have ha : g.asks = fun _ => g.asks 0 := by
    funext k; rcases fin3 k with h' | h' | h' <;> subst h' <;> simp [← h.asked.1, ← h.asked.2]
  have hbook : g.book = g.bk 0 := by
    rw [Game.book, hb]; exact vote_const _
  have ho : g.ob = fun i => freshOb P i g.rt (g.bk 0).rounds (P.inWeb₁ g.rt) := by
    funext i; rw [h.observers i]; simp [born, freshOb, heldOf, hbook, h.record]
  cases g with
  | mk sp ob rt rc bk bf asks =>
    simp only [cleanG] at *
    have h1 := h.state; have h2 := h.record
    simp only at h1 h2 hb hf ha ho
    subst h1 h2
    congr

theorem settled_cleanG (T : St V) (A : Q) (b : Book V Tm) (β : Option (St V))
    (hb : b.halt = none) (h1 : P.canBe₁ T = true) (h2 : P.canBe₂ T = true) :
    Settled P (cleanG P T A b β) := by
  refine ⟨rfl, rfl, ?_, ⟨rfl, rfl⟩, hb, ⟨rfl, rfl⟩, ⟨rfl, rfl⟩, ⟨h1, h2⟩⟩
  intro i; rw [born_cleanG]; rfl

theorem who8 (i : Who) : i = 0 ∨ i = 1 ∨ i = 2 ∨ i = 3 ∨ i = 4 ∨ i = 5 ∨ i = 6 ∨ i = 7 := by
  revert i; decide

theorem part7 (p : Part) : p = 0 ∨ p = 1 ∨ p = 2 ∨ p = 3 ∨ p = 4 ∨ p = 5 ∨ p = 6 := by
  revert p; decide

/-- Every part is seen by an observer that is not a coordinator. -/
theorem seen_whole (p : Part) : ∃ i : Who, sees i p = true ∧ coord i = false := by
  revert p; decide

theorem shaped_fresh (j : Who) (T : St V) (ρ : Nat) (h : V) :
    shaped P j (freshOb P j T ρ h) = true := by
  have : ∀ p : Part, sees j p = true ∨ copiesFor P j T p = P.blank := by
    intro p; by_cases hs : sees j p = true <;> simp [copiesFor, hs]
  by_cases hj : j = moths
  · subst hj; simp [shaped, freshOb, this]
  · simp [shaped, freshOb, this, hj]

/-- L2 to L7: in a look at a game in which everything agrees, no observer finds
anything. -/
theorem lookOf_clean (i : Who) (T : St V) (ρ ρ' : Nat) :
    lookOf P i ⟨ρ', ρ, T, fun j => freshOb P j T ρ (P.inWeb₁ T), T⟩ = none := by
  have hs := shaped_fresh P
  rcases who8 i with h | h | h | h | h | h | h | h <;> subst h <;>
    simp [lookOf, lookRing, rings, hs, List.filter, List.findSome?] <;>
    simp [freshOb, copiesFor, sees, rings, coord, Params.holds, Params.printOf, moths]

/-- `lookOf_clean`, with the observers written out. -/
theorem lookOf_clean' (i : Who) (T : St V) (ρ ρ' : Nat) :
    lookOf P i ⟨ρ', ρ, T, fun j => ⟨j.val, true, ρ, copiesFor P j T,
      if j = moths then P.inWeb₁ T else P.blank, false, none⟩, T⟩ = none :=
  lookOf_clean P i T ρ ρ'

/-- R16: the gate finds nothing in observers that are as new ones would be. -/
theorem obsOff_fresh (g : Game V Q Tm) (h : ∀ i, g.ob i = born P g i) : obsOff P g = none := by
  simp [obsOff, allWho, List.findSome?, h, born]

/-- `obsOff_fresh`, with the game written out. -/
theorem obsOff_clean' (sp T : St V) (ρ : Nat) (b : Book V Tm) (bf : Fin 3 → Option (St V))
    (asks : Fin 3 → Q) (h : b.rounds = ρ) :
    obsOff P ⟨sp, fun j => ⟨j.val, true, ρ, copiesFor P j T,
      if j = moths then P.inWeb₁ T else P.blank, false, none⟩, T, T, fun _ => b, bf, asks⟩ = none := by
  apply obsOff_fresh
  intro i
  simp [born, heldOf, Game.book, vote_const, h]

end
end Gate
