/-
The statements to be proved, with their proofs left out. This file, `Model.lean`,
`Conditions.lean`, `Systems.lean` and `Reference.lean` are what a reader has to check
against `model-spec.md` and `results.md`.
-/
import SelfObserving.Systems
import SelfObserving.Reference

namespace SelfObserving

variable {M W B S : Type}

/-! ### The general result -/

/-- Theorem S. A plain system that meets the four conditions has no gap at one fault per
round: no execution of any length violates G1 or G2 in any round. The numbers of monitors
and of work processes are arbitrary, and need not be finite. -/
theorem theorem_S (sys : System M W B S) (hf : sys.f = 1) (hp : Plain sys)
    (hs : Sufficient sys) : NoGap sys := by
  sorry

/-- The conditions of Theorem S can be met: a full mesh of at least two monitors, with any
work processes, has no gap. -/
theorem mesh_noGap {m₀ m₁ : M} (h : m₀ ≠ m₁) : NoGap (mesh M W) := by
  sorry

/-- "No gap" can fail: a work process that nothing watches has a gap. -/
theorem unwatched_gap : ¬ NoGap unwatched := by
  sorry

/-! ### The reference system and the ten removals

Between them, the reference system and its removals use all six kinds of step. In the
reference system itself four can occur: with no off switch and no shared boundary, the
other two cannot. `reference_noGap` is the result of section 5 of `results.md`. Each
statement about a removal says which of the two goals some execution violates, and which
none does. That is the column "Judgement broken" of the table in section 7, as to which
goals, and not as to the round. -/

/-- The reference system, with every feature, has no gap. -/
theorem reference_noGap : NoGap reference := by
  sorry

/-- Without P1, the liveness signal, both goals can be violated. -/
theorem withoutP1_gap : ViolatesG1 withoutP1 ∧ ViolatesG2 withoutP1 := by
  sorry

/-- Without P2, shared substrate, both goals can be violated. -/
theorem withoutP2_gap : ViolatesG1 withoutP2 ∧ ViolatesG2 withoutP2 := by
  sorry

/-- Without P3, the state check, both goals can be violated. -/
theorem withoutP3_gap : ViolatesG1 withoutP3 ∧ ViolatesG2 withoutP3 := by
  sorry

/-- Without P4, propagation, G2 can be violated and G1 cannot: the fault is flagged, and
work goes on. -/
theorem withoutP4_gap : ¬ ViolatesG1 withoutP4 ∧ ViolatesG2 withoutP4 := by
  sorry

/-- Without P5, no single-step removal, both goals can be violated. -/
theorem withoutP5_gap : ViolatesG1 withoutP5 ∧ ViolatesG2 withoutP5 := by
  sorry

/-- Without P6, the out-of-boundary signal, G1 can be violated and G2 cannot: the work
stops, and nothing is left to know why. -/
theorem withoutP6_gap : ViolatesG1 withoutP6 ∧ ¬ ViolatesG2 withoutP6 := by
  sorry

/-- Without P7, automatic enrolment, both goals can be violated. -/
theorem withoutP7_gap : ViolatesG1 withoutP7 ∧ ViolatesG2 withoutP7 := by
  sorry

/-- Without P8, immediate response, G2 can be violated and G1 cannot: every monitor has
flagged, and the work takes one more step. -/
theorem withoutP8_gap : ¬ ViolatesG1 withoutP8 ∧ ViolatesG2 withoutP8 := by
  sorry

/-- Without the halt fan-out, both goals can be violated. -/
theorem withoutP8b_gap : ViolatesG1 withoutP8b ∧ ViolatesG2 withoutP8b := by
  sorry

/-- Without the gate, both goals can be violated. -/
theorem withoutGate_gap : ViolatesG1 withoutGate ∧ ViolatesG2 withoutGate := by
  sorry

end SelfObserving
