/-
What is proved about the model check's checker, `check_model.py`, beside the statements
of `Challenge.lean`. No statement here is needed for those.

- `definitions_agree`: each of the eleven systems of `Reference.lean` is the system that
  `reference(without=...)` builds, as `tools/gen.py` writes it out in
  `Generated/Fields.lean`.
- `reference_reachable` and the three after it: for the four systems in which a goal is
  never violated, the reachable states of the Lean model are the states that `explore()`
  reaches. `reference_reachable_count` and the three after it give their number.

This is agreement on these systems, and no more. For the other seven systems the Lean
model and the checker are compared on the violating executions of
`Generated/Executions.lean` only. And the eleven systems do not use every clause of the
model. Independent checks of this file found the cases below. The list may not be
complete. In all eleven systems:

- `f` is 1 and `slowReports` is false, so nothing here tests several steps in one round,
  or slow reports;
- `hbReaders`, `fwd` and the checks of one monitor by another are symmetric, so nothing
  here tests the direction of those relations;
- the report edges join every two monitors or none, so a flag never has to travel two
  edges, and nothing here tests the repetition in the spreading of a flag;
- there is a joiner and every monitor has a boundary, so nothing here tests a system
  without either;
- the joiner has no substrate, so nothing here tests that `failSubstrate` leaves alone a
  process that is not present;
- a boundary holds one monitor or all three, so nothing here tests which monitors
  `stopBoundary` stops.
-/
import SelfObserving.Generated.Fields
import SelfObserving.Generated.StatesReference
import SelfObserving.Generated.StatesWithoutP4
import SelfObserving.Generated.StatesWithoutP6
import SelfObserving.Generated.StatesWithoutP8

namespace SelfObserving

open Finite

/-- The reference system and its ten removals, as `Reference.lean` defines them, are the
systems that `reference(without=...)` of `check_model.py` builds. -/
theorem definitions_agree :
    reference = Py.reference ∧ withoutP1 = Py.withoutP1 ∧ withoutP2 = Py.withoutP2 ∧
    withoutP3 = Py.withoutP3 ∧ withoutP4 = Py.withoutP4 ∧ withoutP5 = Py.withoutP5 ∧
    withoutP6 = Py.withoutP6 ∧ withoutP7 = Py.withoutP7 ∧ withoutP8 = Py.withoutP8 ∧
    withoutP8b = Py.withoutP8b ∧ withoutGate = Py.withoutGate :=
  ⟨Py.reference_eq, Py.withoutP1_eq, Py.withoutP2_eq, Py.withoutP3_eq, Py.withoutP4_eq,
    Py.withoutP5_eq, Py.withoutP6_eq, Py.withoutP7_eq, Py.withoutP8_eq, Py.withoutP8b_eq,
    Py.withoutGate_eq⟩

/-! ### The reachable states are the states `explore()` reaches -/

theorem reference_reachable (s : State Mon Wk) :
    Reachable reference s ↔ ∃ c ∈ Py.reference_states, s = c.toState :=
  reachable_iff reference rfl Py.reference_covers Py.reference_reached s

theorem withoutP4_reachable (s : State Mon Wk) :
    Reachable withoutP4 s ↔ ∃ c ∈ Py.withoutP4_states, s = c.toState :=
  reachable_iff withoutP4 rfl Py.withoutP4_covers Py.withoutP4_reached s

theorem withoutP6_reachable (s : State Mon Wk) :
    Reachable withoutP6 s ↔ ∃ c ∈ Py.withoutP6_states, s = c.toState :=
  reachable_iff withoutP6 rfl Py.withoutP6_covers Py.withoutP6_reached s

theorem withoutP8_reachable (s : State Mon Wk) :
    Reachable withoutP8 s ↔ ∃ c ∈ Py.withoutP8_states, s = c.toState :=
  reachable_iff withoutP8 rfl Py.withoutP8_covers Py.withoutP8_reached s

/-! ### Their number is the number `explore()` returns -/

theorem reference_reachable_count : ReachableCount reference 23 :=
  Py.reference_count.1 ▸
    reachable_count rfl Py.reference_covers Py.reference_reached Py.reference_count.2.1

theorem withoutP4_reachable_count : ReachableCount withoutP4 59 :=
  Py.withoutP4_count.1 ▸
    reachable_count rfl Py.withoutP4_covers Py.withoutP4_reached Py.withoutP4_count.2.1

theorem withoutP6_reachable_count : ReachableCount withoutP6 239 :=
  Py.withoutP6_count.1 ▸
    reachable_count rfl Py.withoutP6_covers Py.withoutP6_reached Py.withoutP6_count.2.1

theorem withoutP8_reachable_count : ReachableCount withoutP8 228 :=
  Py.withoutP8_count.1 ▸
    reachable_count rfl Py.withoutP8_covers Py.withoutP8_reached Py.withoutP8_count.2.1

end SelfObserving
