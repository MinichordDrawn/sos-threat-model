/-
What the generated files need about the reference system and its ten removals: their
relations can be decided, and two systems are equal when their fields agree.
-/
import SelfObserving.Proofs.Explore

namespace SelfObserving
namespace Finite

/-- Two systems are equal when their fields agree. -/
theorem system_ext {M W B S : Type} {a b : System M W B S}
    (hf : a.f = b.f) (hjoiner : a.joiner = b.joiner)
    (hboundary : ∀ m, a.boundary m = b.boundary m)
    (hsubstrate : ∀ p, a.substrate p = b.substrate p)
    (hhbReaders : ∀ m r, a.hbReaders m r ↔ b.hbReaders m r)
    (hcheckers : ∀ x m, a.checkers x m ↔ b.checkers x m)
    (hfwd : ∀ m r, a.fwd m r ↔ b.fwd m r)
    (hhaltInputs : ∀ w m, a.haltInputs w m ↔ b.haltInputs w m)
    (hswitches : ∀ m, a.switches m ↔ b.switches m)
    (hcoupling : a.coupling = b.coupling) (hwindow : a.window = b.window)
    (hgate : a.gate = b.gate) (hslowReports : a.slowReports = b.slowReports) : a = b := by
  cases a
  cases b
  simp only [System.mk.injEq]
  exact ⟨hf, hjoiner, funext hboundary, funext hsubstrate,
    funext fun m => funext fun r => propext (hhbReaders m r),
    funext fun x => funext fun m => propext (hcheckers x m),
    funext fun m => funext fun r => propext (hfwd m r),
    funext fun w => funext fun m => propext (hhaltInputs w m),
    funext fun m => propext (hswitches m), hcoupling, hwindow, hgate, hslowReports⟩

/-- The relations of the reference system, with any features, can be decided. -/
instance decReferenceWith (on : Features) : DecSys (referenceWith on) where
  hbReaders := fun m r => inferInstanceAs (Decidable (on.p1 = true ∧ r ≠ m))
  checkers := fun x r =>
    match x with
    | .inl m => inferInstanceAs (Decidable (on.p3 = true ∧ r ≠ m))
    | .inr .W1 => inferInstanceAs (Decidable (on.p3 = true ∧ r = .M1))
    | .inr .W2 => inferInstanceAs (Decidable (on.p3 = true ∧ r = .M2))
    | .inr .J => inferInstanceAs (Decidable (on.p3 = true ∧ on.p7 = true ∧ r = .M3))
  fwd := fun m r => inferInstanceAs (Decidable (on.p4 = true ∧ r ≠ m))
  haltInputs := fun w r =>
    match w with
    | .W1 => inferInstanceAs (Decidable (r = .M1 ∨ (on.p8b = true ∧ r = .M3)))
    | .W2 => inferInstanceAs (Decidable (r = .M2 ∨ (on.p8b = true ∧ r = .M3)))
    | .J => inferInstanceAs (Decidable (on.p7 = true ∧ (r = .M3 ∨ (on.p8b = true ∧ r = .M1))))
  switches := fun _ => inferInstanceAs (Decidable (on.p5 = false))

instance : DecSys reference := decReferenceWith _
instance : DecSys withoutP1 := decReferenceWith _
instance : DecSys withoutP2 := decReferenceWith _
instance : DecSys withoutP3 := decReferenceWith _
instance : DecSys withoutP4 := decReferenceWith _
instance : DecSys withoutP5 := decReferenceWith _
instance : DecSys withoutP6 := decReferenceWith _
instance : DecSys withoutP7 := decReferenceWith _
instance : DecSys withoutP8 := decReferenceWith _
instance : DecSys withoutP8b := decReferenceWith _
instance : DecSys withoutGate := decReferenceWith _

end Finite
end SelfObserving
