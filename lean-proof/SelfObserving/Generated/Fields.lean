/-
GENERATED FILE. Do not edit it: change tools/gen.py and run it again.

Written by tools/gen.py from check_model.py of the model check
(SHA-256 2c788a4a1d8d3c9d12cb08608cff4b8a3257634527e5bfee433ccef6b2fa294d).

Each of the eleven systems as the Python object has it, field by field, and the
statement that the project's definition in `Reference.lean` is that system. The
Python's boundary ids 1, 2, 3 are `Bd.b1`, `Bd.b2`, `Bd.b3`, and its substrate ids
`s1` to `s5` are `Sub.s1` to `Sub.s5`.
-/
import SelfObserving.Proofs.Removals

namespace SelfObserving
namespace Py

/-! ### `reference()` -/

/-- `reference()` of check_model.py, written out. -/
def reference : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    match m with
    | .M1 => some .b1
    | .M2 => some .b2
    | .M3 => some .b3
  substrate := fun p =>
    match p with
    | .inl .M1 => some .s1
    | .inl .M2 => some .s2
    | .inl .M3 => some .s3
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
  hbReaders := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  checkers := fun x m =>
    (x = .inl .M1 ∧ m = .M2) ∨ (x = .inl .M1 ∧ m = .M3) ∨ (x = .inl .M2 ∧ m = .M1) ∨
    (x = .inl .M2 ∧ m = .M3) ∨ (x = .inl .M3 ∧ m = .M1) ∨ (x = .inl .M3 ∧ m = .M2) ∨
    (x = .inr .W1 ∧ m = .M1) ∨ (x = .inr .W2 ∧ m = .M2) ∨ (x = .inr .J ∧ m = .M3)
  fwd := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  haltInputs := fun w m =>
    (w = .W1 ∧ m = .M1) ∨ (w = .W1 ∧ m = .M3) ∨ (w = .W2 ∧ m = .M2) ∨ (w = .W2 ∧ m = .M3) ∨
    (w = .J ∧ m = .M3) ∨ (w = .J ∧ m = .M1)
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

theorem reference_f : SelfObserving.reference.f = reference.f := rfl
theorem reference_joiner : SelfObserving.reference.joiner = reference.joiner := rfl
theorem reference_boundary (m : Mon) :
    SelfObserving.reference.boundary m = reference.boundary m := by
  cases m <;> rfl
theorem reference_substrate (p : Proc Mon Wk) :
    SelfObserving.reference.substrate p = reference.substrate p := by
  cases p with
  | inl m => cases m <;> rfl
  | inr w => cases w <;> rfl
theorem reference_hbReaders (m r : Mon) :
    SelfObserving.reference.hbReaders m r ↔ reference.hbReaders m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.reference, reference, referenceWith, Features.all]
theorem reference_checkers (x : Proc Mon Wk) (m : Mon) :
    SelfObserving.reference.checkers x m ↔ reference.checkers x m := by
  cases x with
  | inl a =>
    cases a <;> cases m <;>
      simp [SelfObserving.reference, reference, referenceWith, Features.all]
  | inr w =>
    cases w <;> cases m <;>
      simp [SelfObserving.reference, reference, referenceWith, Features.all]
theorem reference_fwd (m r : Mon) :
    SelfObserving.reference.fwd m r ↔ reference.fwd m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.reference, reference, referenceWith, Features.all]
theorem reference_haltInputs (w : Wk) (m : Mon) :
    SelfObserving.reference.haltInputs w m ↔ reference.haltInputs w m := by
  cases w <;> cases m <;>
    simp [SelfObserving.reference, reference, referenceWith, Features.all]
theorem reference_switches (m : Mon) :
    SelfObserving.reference.switches m ↔ reference.switches m := by
  cases m <;>
    simp [SelfObserving.reference, reference, referenceWith, Features.all]
theorem reference_coupling : SelfObserving.reference.coupling = reference.coupling := rfl
theorem reference_window : SelfObserving.reference.window = reference.window := rfl
theorem reference_gate : SelfObserving.reference.gate = reference.gate := rfl
theorem reference_slowReports :
    SelfObserving.reference.slowReports = reference.slowReports := rfl

/-- `reference` of `Reference.lean` is `reference()`. -/
theorem reference_eq : SelfObserving.reference = reference :=
  Finite.system_ext reference_f reference_joiner reference_boundary reference_substrate
    reference_hbReaders reference_checkers reference_fwd reference_haltInputs
    reference_switches reference_coupling reference_window reference_gate
    reference_slowReports

/-! ### `reference(without=('P1',))` -/

/-- `reference(without=('P1',))` of check_model.py, written out. -/
def withoutP1 : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    match m with
    | .M1 => some .b1
    | .M2 => some .b2
    | .M3 => some .b3
  substrate := fun p =>
    match p with
    | .inl .M1 => some .s1
    | .inl .M2 => some .s2
    | .inl .M3 => some .s3
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
  hbReaders := fun _ _ => False
  checkers := fun x m =>
    (x = .inl .M1 ∧ m = .M2) ∨ (x = .inl .M1 ∧ m = .M3) ∨ (x = .inl .M2 ∧ m = .M1) ∨
    (x = .inl .M2 ∧ m = .M3) ∨ (x = .inl .M3 ∧ m = .M1) ∨ (x = .inl .M3 ∧ m = .M2) ∨
    (x = .inr .W1 ∧ m = .M1) ∨ (x = .inr .W2 ∧ m = .M2) ∨ (x = .inr .J ∧ m = .M3)
  fwd := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  haltInputs := fun w m =>
    (w = .W1 ∧ m = .M1) ∨ (w = .W1 ∧ m = .M3) ∨ (w = .W2 ∧ m = .M2) ∨ (w = .W2 ∧ m = .M3) ∨
    (w = .J ∧ m = .M3) ∨ (w = .J ∧ m = .M1)
  switches := fun _ => False
  coupling := false
  window := 0
  gate := true
  slowReports := false

theorem withoutP1_f : SelfObserving.withoutP1.f = withoutP1.f := rfl
theorem withoutP1_joiner : SelfObserving.withoutP1.joiner = withoutP1.joiner := rfl
theorem withoutP1_boundary (m : Mon) :
    SelfObserving.withoutP1.boundary m = withoutP1.boundary m := by
  cases m <;> rfl
theorem withoutP1_substrate (p : Proc Mon Wk) :
    SelfObserving.withoutP1.substrate p = withoutP1.substrate p := by
  cases p with
  | inl m => cases m <;> rfl
  | inr w => cases w <;> rfl
theorem withoutP1_hbReaders (m r : Mon) :
    SelfObserving.withoutP1.hbReaders m r ↔ withoutP1.hbReaders m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP1, withoutP1, referenceWith, Features.all]
theorem withoutP1_checkers (x : Proc Mon Wk) (m : Mon) :
    SelfObserving.withoutP1.checkers x m ↔ withoutP1.checkers x m := by
  cases x with
  | inl a =>
    cases a <;> cases m <;>
      simp [SelfObserving.withoutP1, withoutP1, referenceWith, Features.all]
  | inr w =>
    cases w <;> cases m <;>
      simp [SelfObserving.withoutP1, withoutP1, referenceWith, Features.all]
theorem withoutP1_fwd (m r : Mon) :
    SelfObserving.withoutP1.fwd m r ↔ withoutP1.fwd m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP1, withoutP1, referenceWith, Features.all]
theorem withoutP1_haltInputs (w : Wk) (m : Mon) :
    SelfObserving.withoutP1.haltInputs w m ↔ withoutP1.haltInputs w m := by
  cases w <;> cases m <;>
    simp [SelfObserving.withoutP1, withoutP1, referenceWith, Features.all]
theorem withoutP1_switches (m : Mon) :
    SelfObserving.withoutP1.switches m ↔ withoutP1.switches m := by
  cases m <;>
    simp [SelfObserving.withoutP1, withoutP1, referenceWith, Features.all]
theorem withoutP1_coupling : SelfObserving.withoutP1.coupling = withoutP1.coupling := rfl
theorem withoutP1_window : SelfObserving.withoutP1.window = withoutP1.window := rfl
theorem withoutP1_gate : SelfObserving.withoutP1.gate = withoutP1.gate := rfl
theorem withoutP1_slowReports :
    SelfObserving.withoutP1.slowReports = withoutP1.slowReports := rfl

/-- `withoutP1` of `Reference.lean` is `reference(without=('P1',))`. -/
theorem withoutP1_eq : SelfObserving.withoutP1 = withoutP1 :=
  Finite.system_ext withoutP1_f withoutP1_joiner withoutP1_boundary withoutP1_substrate
    withoutP1_hbReaders withoutP1_checkers withoutP1_fwd withoutP1_haltInputs
    withoutP1_switches withoutP1_coupling withoutP1_window withoutP1_gate
    withoutP1_slowReports

/-! ### `reference(without=('P2',))` -/

/-- `reference(without=('P2',))` of check_model.py, written out. -/
def withoutP2 : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    match m with
    | .M1 => some .b1
    | .M2 => some .b2
    | .M3 => some .b3
  substrate := fun p =>
    match p with
    | .inl .M1 => some .s4
    | .inl .M2 => some .s5
    | .inl .M3 => some .s3
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
  hbReaders := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  checkers := fun x m =>
    (x = .inl .M1 ∧ m = .M2) ∨ (x = .inl .M1 ∧ m = .M3) ∨ (x = .inl .M2 ∧ m = .M1) ∨
    (x = .inl .M2 ∧ m = .M3) ∨ (x = .inl .M3 ∧ m = .M1) ∨ (x = .inl .M3 ∧ m = .M2) ∨
    (x = .inr .W1 ∧ m = .M1) ∨ (x = .inr .W2 ∧ m = .M2) ∨ (x = .inr .J ∧ m = .M3)
  fwd := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  haltInputs := fun w m =>
    (w = .W1 ∧ m = .M1) ∨ (w = .W1 ∧ m = .M3) ∨ (w = .W2 ∧ m = .M2) ∨ (w = .W2 ∧ m = .M3) ∨
    (w = .J ∧ m = .M3) ∨ (w = .J ∧ m = .M1)
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

theorem withoutP2_f : SelfObserving.withoutP2.f = withoutP2.f := rfl
theorem withoutP2_joiner : SelfObserving.withoutP2.joiner = withoutP2.joiner := rfl
theorem withoutP2_boundary (m : Mon) :
    SelfObserving.withoutP2.boundary m = withoutP2.boundary m := by
  cases m <;> rfl
theorem withoutP2_substrate (p : Proc Mon Wk) :
    SelfObserving.withoutP2.substrate p = withoutP2.substrate p := by
  cases p with
  | inl m => cases m <;> rfl
  | inr w => cases w <;> rfl
theorem withoutP2_hbReaders (m r : Mon) :
    SelfObserving.withoutP2.hbReaders m r ↔ withoutP2.hbReaders m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP2, withoutP2, referenceWith, Features.all]
theorem withoutP2_checkers (x : Proc Mon Wk) (m : Mon) :
    SelfObserving.withoutP2.checkers x m ↔ withoutP2.checkers x m := by
  cases x with
  | inl a =>
    cases a <;> cases m <;>
      simp [SelfObserving.withoutP2, withoutP2, referenceWith, Features.all]
  | inr w =>
    cases w <;> cases m <;>
      simp [SelfObserving.withoutP2, withoutP2, referenceWith, Features.all]
theorem withoutP2_fwd (m r : Mon) :
    SelfObserving.withoutP2.fwd m r ↔ withoutP2.fwd m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP2, withoutP2, referenceWith, Features.all]
theorem withoutP2_haltInputs (w : Wk) (m : Mon) :
    SelfObserving.withoutP2.haltInputs w m ↔ withoutP2.haltInputs w m := by
  cases w <;> cases m <;>
    simp [SelfObserving.withoutP2, withoutP2, referenceWith, Features.all]
theorem withoutP2_switches (m : Mon) :
    SelfObserving.withoutP2.switches m ↔ withoutP2.switches m := by
  cases m <;>
    simp [SelfObserving.withoutP2, withoutP2, referenceWith, Features.all]
theorem withoutP2_coupling : SelfObserving.withoutP2.coupling = withoutP2.coupling := rfl
theorem withoutP2_window : SelfObserving.withoutP2.window = withoutP2.window := rfl
theorem withoutP2_gate : SelfObserving.withoutP2.gate = withoutP2.gate := rfl
theorem withoutP2_slowReports :
    SelfObserving.withoutP2.slowReports = withoutP2.slowReports := rfl

/-- `withoutP2` of `Reference.lean` is `reference(without=('P2',))`. -/
theorem withoutP2_eq : SelfObserving.withoutP2 = withoutP2 :=
  Finite.system_ext withoutP2_f withoutP2_joiner withoutP2_boundary withoutP2_substrate
    withoutP2_hbReaders withoutP2_checkers withoutP2_fwd withoutP2_haltInputs
    withoutP2_switches withoutP2_coupling withoutP2_window withoutP2_gate
    withoutP2_slowReports

/-! ### `reference(without=('P3',))` -/

/-- `reference(without=('P3',))` of check_model.py, written out. -/
def withoutP3 : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    match m with
    | .M1 => some .b1
    | .M2 => some .b2
    | .M3 => some .b3
  substrate := fun p =>
    match p with
    | .inl .M1 => some .s1
    | .inl .M2 => some .s2
    | .inl .M3 => some .s3
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
  hbReaders := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  checkers := fun _ _ => False
  fwd := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  haltInputs := fun w m =>
    (w = .W1 ∧ m = .M1) ∨ (w = .W1 ∧ m = .M3) ∨ (w = .W2 ∧ m = .M2) ∨ (w = .W2 ∧ m = .M3) ∨
    (w = .J ∧ m = .M3) ∨ (w = .J ∧ m = .M1)
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

theorem withoutP3_f : SelfObserving.withoutP3.f = withoutP3.f := rfl
theorem withoutP3_joiner : SelfObserving.withoutP3.joiner = withoutP3.joiner := rfl
theorem withoutP3_boundary (m : Mon) :
    SelfObserving.withoutP3.boundary m = withoutP3.boundary m := by
  cases m <;> rfl
theorem withoutP3_substrate (p : Proc Mon Wk) :
    SelfObserving.withoutP3.substrate p = withoutP3.substrate p := by
  cases p with
  | inl m => cases m <;> rfl
  | inr w => cases w <;> rfl
theorem withoutP3_hbReaders (m r : Mon) :
    SelfObserving.withoutP3.hbReaders m r ↔ withoutP3.hbReaders m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP3, withoutP3, referenceWith, Features.all]
theorem withoutP3_checkers (x : Proc Mon Wk) (m : Mon) :
    SelfObserving.withoutP3.checkers x m ↔ withoutP3.checkers x m := by
  cases x with
  | inl a =>
    cases a <;> cases m <;>
      simp [SelfObserving.withoutP3, withoutP3, referenceWith, Features.all]
  | inr w =>
    cases w <;> cases m <;>
      simp [SelfObserving.withoutP3, withoutP3, referenceWith, Features.all]
theorem withoutP3_fwd (m r : Mon) :
    SelfObserving.withoutP3.fwd m r ↔ withoutP3.fwd m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP3, withoutP3, referenceWith, Features.all]
theorem withoutP3_haltInputs (w : Wk) (m : Mon) :
    SelfObserving.withoutP3.haltInputs w m ↔ withoutP3.haltInputs w m := by
  cases w <;> cases m <;>
    simp [SelfObserving.withoutP3, withoutP3, referenceWith, Features.all]
theorem withoutP3_switches (m : Mon) :
    SelfObserving.withoutP3.switches m ↔ withoutP3.switches m := by
  cases m <;>
    simp [SelfObserving.withoutP3, withoutP3, referenceWith, Features.all]
theorem withoutP3_coupling : SelfObserving.withoutP3.coupling = withoutP3.coupling := rfl
theorem withoutP3_window : SelfObserving.withoutP3.window = withoutP3.window := rfl
theorem withoutP3_gate : SelfObserving.withoutP3.gate = withoutP3.gate := rfl
theorem withoutP3_slowReports :
    SelfObserving.withoutP3.slowReports = withoutP3.slowReports := rfl

/-- `withoutP3` of `Reference.lean` is `reference(without=('P3',))`. -/
theorem withoutP3_eq : SelfObserving.withoutP3 = withoutP3 :=
  Finite.system_ext withoutP3_f withoutP3_joiner withoutP3_boundary withoutP3_substrate
    withoutP3_hbReaders withoutP3_checkers withoutP3_fwd withoutP3_haltInputs
    withoutP3_switches withoutP3_coupling withoutP3_window withoutP3_gate
    withoutP3_slowReports

/-! ### `reference(without=('P4',))` -/

/-- `reference(without=('P4',))` of check_model.py, written out. -/
def withoutP4 : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    match m with
    | .M1 => some .b1
    | .M2 => some .b2
    | .M3 => some .b3
  substrate := fun p =>
    match p with
    | .inl .M1 => some .s1
    | .inl .M2 => some .s2
    | .inl .M3 => some .s3
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
  hbReaders := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  checkers := fun x m =>
    (x = .inl .M1 ∧ m = .M2) ∨ (x = .inl .M1 ∧ m = .M3) ∨ (x = .inl .M2 ∧ m = .M1) ∨
    (x = .inl .M2 ∧ m = .M3) ∨ (x = .inl .M3 ∧ m = .M1) ∨ (x = .inl .M3 ∧ m = .M2) ∨
    (x = .inr .W1 ∧ m = .M1) ∨ (x = .inr .W2 ∧ m = .M2) ∨ (x = .inr .J ∧ m = .M3)
  fwd := fun _ _ => False
  haltInputs := fun w m =>
    (w = .W1 ∧ m = .M1) ∨ (w = .W1 ∧ m = .M3) ∨ (w = .W2 ∧ m = .M2) ∨ (w = .W2 ∧ m = .M3) ∨
    (w = .J ∧ m = .M3) ∨ (w = .J ∧ m = .M1)
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

theorem withoutP4_f : SelfObserving.withoutP4.f = withoutP4.f := rfl
theorem withoutP4_joiner : SelfObserving.withoutP4.joiner = withoutP4.joiner := rfl
theorem withoutP4_boundary (m : Mon) :
    SelfObserving.withoutP4.boundary m = withoutP4.boundary m := by
  cases m <;> rfl
theorem withoutP4_substrate (p : Proc Mon Wk) :
    SelfObserving.withoutP4.substrate p = withoutP4.substrate p := by
  cases p with
  | inl m => cases m <;> rfl
  | inr w => cases w <;> rfl
theorem withoutP4_hbReaders (m r : Mon) :
    SelfObserving.withoutP4.hbReaders m r ↔ withoutP4.hbReaders m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP4, withoutP4, referenceWith, Features.all]
theorem withoutP4_checkers (x : Proc Mon Wk) (m : Mon) :
    SelfObserving.withoutP4.checkers x m ↔ withoutP4.checkers x m := by
  cases x with
  | inl a =>
    cases a <;> cases m <;>
      simp [SelfObserving.withoutP4, withoutP4, referenceWith, Features.all]
  | inr w =>
    cases w <;> cases m <;>
      simp [SelfObserving.withoutP4, withoutP4, referenceWith, Features.all]
theorem withoutP4_fwd (m r : Mon) :
    SelfObserving.withoutP4.fwd m r ↔ withoutP4.fwd m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP4, withoutP4, referenceWith, Features.all]
theorem withoutP4_haltInputs (w : Wk) (m : Mon) :
    SelfObserving.withoutP4.haltInputs w m ↔ withoutP4.haltInputs w m := by
  cases w <;> cases m <;>
    simp [SelfObserving.withoutP4, withoutP4, referenceWith, Features.all]
theorem withoutP4_switches (m : Mon) :
    SelfObserving.withoutP4.switches m ↔ withoutP4.switches m := by
  cases m <;>
    simp [SelfObserving.withoutP4, withoutP4, referenceWith, Features.all]
theorem withoutP4_coupling : SelfObserving.withoutP4.coupling = withoutP4.coupling := rfl
theorem withoutP4_window : SelfObserving.withoutP4.window = withoutP4.window := rfl
theorem withoutP4_gate : SelfObserving.withoutP4.gate = withoutP4.gate := rfl
theorem withoutP4_slowReports :
    SelfObserving.withoutP4.slowReports = withoutP4.slowReports := rfl

/-- `withoutP4` of `Reference.lean` is `reference(without=('P4',))`. -/
theorem withoutP4_eq : SelfObserving.withoutP4 = withoutP4 :=
  Finite.system_ext withoutP4_f withoutP4_joiner withoutP4_boundary withoutP4_substrate
    withoutP4_hbReaders withoutP4_checkers withoutP4_fwd withoutP4_haltInputs
    withoutP4_switches withoutP4_coupling withoutP4_window withoutP4_gate
    withoutP4_slowReports

/-! ### `reference(without=('P5',))` -/

/-- `reference(without=('P5',))` of check_model.py, written out. -/
def withoutP5 : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    match m with
    | .M1 => some .b1
    | .M2 => some .b2
    | .M3 => some .b3
  substrate := fun p =>
    match p with
    | .inl .M1 => some .s1
    | .inl .M2 => some .s2
    | .inl .M3 => some .s3
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
  hbReaders := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  checkers := fun x m =>
    (x = .inl .M1 ∧ m = .M2) ∨ (x = .inl .M1 ∧ m = .M3) ∨ (x = .inl .M2 ∧ m = .M1) ∨
    (x = .inl .M2 ∧ m = .M3) ∨ (x = .inl .M3 ∧ m = .M1) ∨ (x = .inl .M3 ∧ m = .M2) ∨
    (x = .inr .W1 ∧ m = .M1) ∨ (x = .inr .W2 ∧ m = .M2) ∨ (x = .inr .J ∧ m = .M3)
  fwd := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  haltInputs := fun w m =>
    (w = .W1 ∧ m = .M1) ∨ (w = .W1 ∧ m = .M3) ∨ (w = .W2 ∧ m = .M2) ∨ (w = .W2 ∧ m = .M3) ∨
    (w = .J ∧ m = .M3) ∨ (w = .J ∧ m = .M1)
  switches := fun m => m = .M1 ∨ m = .M2 ∨ m = .M3
  coupling := true
  window := 0
  gate := true
  slowReports := false

theorem withoutP5_f : SelfObserving.withoutP5.f = withoutP5.f := rfl
theorem withoutP5_joiner : SelfObserving.withoutP5.joiner = withoutP5.joiner := rfl
theorem withoutP5_boundary (m : Mon) :
    SelfObserving.withoutP5.boundary m = withoutP5.boundary m := by
  cases m <;> rfl
theorem withoutP5_substrate (p : Proc Mon Wk) :
    SelfObserving.withoutP5.substrate p = withoutP5.substrate p := by
  cases p with
  | inl m => cases m <;> rfl
  | inr w => cases w <;> rfl
theorem withoutP5_hbReaders (m r : Mon) :
    SelfObserving.withoutP5.hbReaders m r ↔ withoutP5.hbReaders m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP5, withoutP5, referenceWith, Features.all]
theorem withoutP5_checkers (x : Proc Mon Wk) (m : Mon) :
    SelfObserving.withoutP5.checkers x m ↔ withoutP5.checkers x m := by
  cases x with
  | inl a =>
    cases a <;> cases m <;>
      simp [SelfObserving.withoutP5, withoutP5, referenceWith, Features.all]
  | inr w =>
    cases w <;> cases m <;>
      simp [SelfObserving.withoutP5, withoutP5, referenceWith, Features.all]
theorem withoutP5_fwd (m r : Mon) :
    SelfObserving.withoutP5.fwd m r ↔ withoutP5.fwd m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP5, withoutP5, referenceWith, Features.all]
theorem withoutP5_haltInputs (w : Wk) (m : Mon) :
    SelfObserving.withoutP5.haltInputs w m ↔ withoutP5.haltInputs w m := by
  cases w <;> cases m <;>
    simp [SelfObserving.withoutP5, withoutP5, referenceWith, Features.all]
theorem withoutP5_switches (m : Mon) :
    SelfObserving.withoutP5.switches m ↔ withoutP5.switches m := by
  cases m <;>
    simp [SelfObserving.withoutP5, withoutP5, referenceWith, Features.all]
theorem withoutP5_coupling : SelfObserving.withoutP5.coupling = withoutP5.coupling := rfl
theorem withoutP5_window : SelfObserving.withoutP5.window = withoutP5.window := rfl
theorem withoutP5_gate : SelfObserving.withoutP5.gate = withoutP5.gate := rfl
theorem withoutP5_slowReports :
    SelfObserving.withoutP5.slowReports = withoutP5.slowReports := rfl

/-- `withoutP5` of `Reference.lean` is `reference(without=('P5',))`. -/
theorem withoutP5_eq : SelfObserving.withoutP5 = withoutP5 :=
  Finite.system_ext withoutP5_f withoutP5_joiner withoutP5_boundary withoutP5_substrate
    withoutP5_hbReaders withoutP5_checkers withoutP5_fwd withoutP5_haltInputs
    withoutP5_switches withoutP5_coupling withoutP5_window withoutP5_gate
    withoutP5_slowReports

/-! ### `reference(without=('P6',))` -/

/-- `reference(without=('P6',))` of check_model.py, written out. -/
def withoutP6 : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    match m with
    | .M1 => some .b1
    | .M2 => some .b1
    | .M3 => some .b1
  substrate := fun p =>
    match p with
    | .inl .M1 => some .s1
    | .inl .M2 => some .s2
    | .inl .M3 => some .s3
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
  hbReaders := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  checkers := fun x m =>
    (x = .inl .M1 ∧ m = .M2) ∨ (x = .inl .M1 ∧ m = .M3) ∨ (x = .inl .M2 ∧ m = .M1) ∨
    (x = .inl .M2 ∧ m = .M3) ∨ (x = .inl .M3 ∧ m = .M1) ∨ (x = .inl .M3 ∧ m = .M2) ∨
    (x = .inr .W1 ∧ m = .M1) ∨ (x = .inr .W2 ∧ m = .M2) ∨ (x = .inr .J ∧ m = .M3)
  fwd := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  haltInputs := fun w m =>
    (w = .W1 ∧ m = .M1) ∨ (w = .W1 ∧ m = .M3) ∨ (w = .W2 ∧ m = .M2) ∨ (w = .W2 ∧ m = .M3) ∨
    (w = .J ∧ m = .M3) ∨ (w = .J ∧ m = .M1)
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

theorem withoutP6_f : SelfObserving.withoutP6.f = withoutP6.f := rfl
theorem withoutP6_joiner : SelfObserving.withoutP6.joiner = withoutP6.joiner := rfl
theorem withoutP6_boundary (m : Mon) :
    SelfObserving.withoutP6.boundary m = withoutP6.boundary m := by
  cases m <;> rfl
theorem withoutP6_substrate (p : Proc Mon Wk) :
    SelfObserving.withoutP6.substrate p = withoutP6.substrate p := by
  cases p with
  | inl m => cases m <;> rfl
  | inr w => cases w <;> rfl
theorem withoutP6_hbReaders (m r : Mon) :
    SelfObserving.withoutP6.hbReaders m r ↔ withoutP6.hbReaders m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP6, withoutP6, referenceWith, Features.all]
theorem withoutP6_checkers (x : Proc Mon Wk) (m : Mon) :
    SelfObserving.withoutP6.checkers x m ↔ withoutP6.checkers x m := by
  cases x with
  | inl a =>
    cases a <;> cases m <;>
      simp [SelfObserving.withoutP6, withoutP6, referenceWith, Features.all]
  | inr w =>
    cases w <;> cases m <;>
      simp [SelfObserving.withoutP6, withoutP6, referenceWith, Features.all]
theorem withoutP6_fwd (m r : Mon) :
    SelfObserving.withoutP6.fwd m r ↔ withoutP6.fwd m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP6, withoutP6, referenceWith, Features.all]
theorem withoutP6_haltInputs (w : Wk) (m : Mon) :
    SelfObserving.withoutP6.haltInputs w m ↔ withoutP6.haltInputs w m := by
  cases w <;> cases m <;>
    simp [SelfObserving.withoutP6, withoutP6, referenceWith, Features.all]
theorem withoutP6_switches (m : Mon) :
    SelfObserving.withoutP6.switches m ↔ withoutP6.switches m := by
  cases m <;>
    simp [SelfObserving.withoutP6, withoutP6, referenceWith, Features.all]
theorem withoutP6_coupling : SelfObserving.withoutP6.coupling = withoutP6.coupling := rfl
theorem withoutP6_window : SelfObserving.withoutP6.window = withoutP6.window := rfl
theorem withoutP6_gate : SelfObserving.withoutP6.gate = withoutP6.gate := rfl
theorem withoutP6_slowReports :
    SelfObserving.withoutP6.slowReports = withoutP6.slowReports := rfl

/-- `withoutP6` of `Reference.lean` is `reference(without=('P6',))`. -/
theorem withoutP6_eq : SelfObserving.withoutP6 = withoutP6 :=
  Finite.system_ext withoutP6_f withoutP6_joiner withoutP6_boundary withoutP6_substrate
    withoutP6_hbReaders withoutP6_checkers withoutP6_fwd withoutP6_haltInputs
    withoutP6_switches withoutP6_coupling withoutP6_window withoutP6_gate
    withoutP6_slowReports

/-! ### `reference(without=('P7',))` -/

/-- `reference(without=('P7',))` of check_model.py, written out. -/
def withoutP7 : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    match m with
    | .M1 => some .b1
    | .M2 => some .b2
    | .M3 => some .b3
  substrate := fun p =>
    match p with
    | .inl .M1 => some .s1
    | .inl .M2 => some .s2
    | .inl .M3 => some .s3
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
  hbReaders := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  checkers := fun x m =>
    (x = .inl .M1 ∧ m = .M2) ∨ (x = .inl .M1 ∧ m = .M3) ∨ (x = .inl .M2 ∧ m = .M1) ∨
    (x = .inl .M2 ∧ m = .M3) ∨ (x = .inl .M3 ∧ m = .M1) ∨ (x = .inl .M3 ∧ m = .M2) ∨
    (x = .inr .W1 ∧ m = .M1) ∨ (x = .inr .W2 ∧ m = .M2)
  fwd := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  haltInputs := fun w m =>
    (w = .W1 ∧ m = .M1) ∨ (w = .W1 ∧ m = .M3) ∨ (w = .W2 ∧ m = .M2) ∨ (w = .W2 ∧ m = .M3)
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

theorem withoutP7_f : SelfObserving.withoutP7.f = withoutP7.f := rfl
theorem withoutP7_joiner : SelfObserving.withoutP7.joiner = withoutP7.joiner := rfl
theorem withoutP7_boundary (m : Mon) :
    SelfObserving.withoutP7.boundary m = withoutP7.boundary m := by
  cases m <;> rfl
theorem withoutP7_substrate (p : Proc Mon Wk) :
    SelfObserving.withoutP7.substrate p = withoutP7.substrate p := by
  cases p with
  | inl m => cases m <;> rfl
  | inr w => cases w <;> rfl
theorem withoutP7_hbReaders (m r : Mon) :
    SelfObserving.withoutP7.hbReaders m r ↔ withoutP7.hbReaders m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP7, withoutP7, referenceWith, Features.all]
theorem withoutP7_checkers (x : Proc Mon Wk) (m : Mon) :
    SelfObserving.withoutP7.checkers x m ↔ withoutP7.checkers x m := by
  cases x with
  | inl a =>
    cases a <;> cases m <;>
      simp [SelfObserving.withoutP7, withoutP7, referenceWith, Features.all]
  | inr w =>
    cases w <;> cases m <;>
      simp [SelfObserving.withoutP7, withoutP7, referenceWith, Features.all]
theorem withoutP7_fwd (m r : Mon) :
    SelfObserving.withoutP7.fwd m r ↔ withoutP7.fwd m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP7, withoutP7, referenceWith, Features.all]
theorem withoutP7_haltInputs (w : Wk) (m : Mon) :
    SelfObserving.withoutP7.haltInputs w m ↔ withoutP7.haltInputs w m := by
  cases w <;> cases m <;>
    simp [SelfObserving.withoutP7, withoutP7, referenceWith, Features.all]
theorem withoutP7_switches (m : Mon) :
    SelfObserving.withoutP7.switches m ↔ withoutP7.switches m := by
  cases m <;>
    simp [SelfObserving.withoutP7, withoutP7, referenceWith, Features.all]
theorem withoutP7_coupling : SelfObserving.withoutP7.coupling = withoutP7.coupling := rfl
theorem withoutP7_window : SelfObserving.withoutP7.window = withoutP7.window := rfl
theorem withoutP7_gate : SelfObserving.withoutP7.gate = withoutP7.gate := rfl
theorem withoutP7_slowReports :
    SelfObserving.withoutP7.slowReports = withoutP7.slowReports := rfl

/-- `withoutP7` of `Reference.lean` is `reference(without=('P7',))`. -/
theorem withoutP7_eq : SelfObserving.withoutP7 = withoutP7 :=
  Finite.system_ext withoutP7_f withoutP7_joiner withoutP7_boundary withoutP7_substrate
    withoutP7_hbReaders withoutP7_checkers withoutP7_fwd withoutP7_haltInputs
    withoutP7_switches withoutP7_coupling withoutP7_window withoutP7_gate
    withoutP7_slowReports

/-! ### `reference(without=('P8',))` -/

/-- `reference(without=('P8',))` of check_model.py, written out. -/
def withoutP8 : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    match m with
    | .M1 => some .b1
    | .M2 => some .b2
    | .M3 => some .b3
  substrate := fun p =>
    match p with
    | .inl .M1 => some .s1
    | .inl .M2 => some .s2
    | .inl .M3 => some .s3
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
  hbReaders := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  checkers := fun x m =>
    (x = .inl .M1 ∧ m = .M2) ∨ (x = .inl .M1 ∧ m = .M3) ∨ (x = .inl .M2 ∧ m = .M1) ∨
    (x = .inl .M2 ∧ m = .M3) ∨ (x = .inl .M3 ∧ m = .M1) ∨ (x = .inl .M3 ∧ m = .M2) ∨
    (x = .inr .W1 ∧ m = .M1) ∨ (x = .inr .W2 ∧ m = .M2) ∨ (x = .inr .J ∧ m = .M3)
  fwd := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  haltInputs := fun w m =>
    (w = .W1 ∧ m = .M1) ∨ (w = .W1 ∧ m = .M3) ∨ (w = .W2 ∧ m = .M2) ∨ (w = .W2 ∧ m = .M3) ∨
    (w = .J ∧ m = .M3) ∨ (w = .J ∧ m = .M1)
  switches := fun _ => False
  coupling := true
  window := 1
  gate := true
  slowReports := false

theorem withoutP8_f : SelfObserving.withoutP8.f = withoutP8.f := rfl
theorem withoutP8_joiner : SelfObserving.withoutP8.joiner = withoutP8.joiner := rfl
theorem withoutP8_boundary (m : Mon) :
    SelfObserving.withoutP8.boundary m = withoutP8.boundary m := by
  cases m <;> rfl
theorem withoutP8_substrate (p : Proc Mon Wk) :
    SelfObserving.withoutP8.substrate p = withoutP8.substrate p := by
  cases p with
  | inl m => cases m <;> rfl
  | inr w => cases w <;> rfl
theorem withoutP8_hbReaders (m r : Mon) :
    SelfObserving.withoutP8.hbReaders m r ↔ withoutP8.hbReaders m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP8, withoutP8, referenceWith, Features.all]
theorem withoutP8_checkers (x : Proc Mon Wk) (m : Mon) :
    SelfObserving.withoutP8.checkers x m ↔ withoutP8.checkers x m := by
  cases x with
  | inl a =>
    cases a <;> cases m <;>
      simp [SelfObserving.withoutP8, withoutP8, referenceWith, Features.all]
  | inr w =>
    cases w <;> cases m <;>
      simp [SelfObserving.withoutP8, withoutP8, referenceWith, Features.all]
theorem withoutP8_fwd (m r : Mon) :
    SelfObserving.withoutP8.fwd m r ↔ withoutP8.fwd m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP8, withoutP8, referenceWith, Features.all]
theorem withoutP8_haltInputs (w : Wk) (m : Mon) :
    SelfObserving.withoutP8.haltInputs w m ↔ withoutP8.haltInputs w m := by
  cases w <;> cases m <;>
    simp [SelfObserving.withoutP8, withoutP8, referenceWith, Features.all]
theorem withoutP8_switches (m : Mon) :
    SelfObserving.withoutP8.switches m ↔ withoutP8.switches m := by
  cases m <;>
    simp [SelfObserving.withoutP8, withoutP8, referenceWith, Features.all]
theorem withoutP8_coupling : SelfObserving.withoutP8.coupling = withoutP8.coupling := rfl
theorem withoutP8_window : SelfObserving.withoutP8.window = withoutP8.window := rfl
theorem withoutP8_gate : SelfObserving.withoutP8.gate = withoutP8.gate := rfl
theorem withoutP8_slowReports :
    SelfObserving.withoutP8.slowReports = withoutP8.slowReports := rfl

/-- `withoutP8` of `Reference.lean` is `reference(without=('P8',))`. -/
theorem withoutP8_eq : SelfObserving.withoutP8 = withoutP8 :=
  Finite.system_ext withoutP8_f withoutP8_joiner withoutP8_boundary withoutP8_substrate
    withoutP8_hbReaders withoutP8_checkers withoutP8_fwd withoutP8_haltInputs
    withoutP8_switches withoutP8_coupling withoutP8_window withoutP8_gate
    withoutP8_slowReports

/-! ### `reference(without=('P8b',))` -/

/-- `reference(without=('P8b',))` of check_model.py, written out. -/
def withoutP8b : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    match m with
    | .M1 => some .b1
    | .M2 => some .b2
    | .M3 => some .b3
  substrate := fun p =>
    match p with
    | .inl .M1 => some .s1
    | .inl .M2 => some .s2
    | .inl .M3 => some .s3
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
  hbReaders := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  checkers := fun x m =>
    (x = .inl .M1 ∧ m = .M2) ∨ (x = .inl .M1 ∧ m = .M3) ∨ (x = .inl .M2 ∧ m = .M1) ∨
    (x = .inl .M2 ∧ m = .M3) ∨ (x = .inl .M3 ∧ m = .M1) ∨ (x = .inl .M3 ∧ m = .M2) ∨
    (x = .inr .W1 ∧ m = .M1) ∨ (x = .inr .W2 ∧ m = .M2) ∨ (x = .inr .J ∧ m = .M3)
  fwd := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  haltInputs := fun w m => (w = .W1 ∧ m = .M1) ∨ (w = .W2 ∧ m = .M2) ∨ (w = .J ∧ m = .M3)
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

theorem withoutP8b_f : SelfObserving.withoutP8b.f = withoutP8b.f := rfl
theorem withoutP8b_joiner : SelfObserving.withoutP8b.joiner = withoutP8b.joiner := rfl
theorem withoutP8b_boundary (m : Mon) :
    SelfObserving.withoutP8b.boundary m = withoutP8b.boundary m := by
  cases m <;> rfl
theorem withoutP8b_substrate (p : Proc Mon Wk) :
    SelfObserving.withoutP8b.substrate p = withoutP8b.substrate p := by
  cases p with
  | inl m => cases m <;> rfl
  | inr w => cases w <;> rfl
theorem withoutP8b_hbReaders (m r : Mon) :
    SelfObserving.withoutP8b.hbReaders m r ↔ withoutP8b.hbReaders m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP8b, withoutP8b, referenceWith, Features.all]
theorem withoutP8b_checkers (x : Proc Mon Wk) (m : Mon) :
    SelfObserving.withoutP8b.checkers x m ↔ withoutP8b.checkers x m := by
  cases x with
  | inl a =>
    cases a <;> cases m <;>
      simp [SelfObserving.withoutP8b, withoutP8b, referenceWith, Features.all]
  | inr w =>
    cases w <;> cases m <;>
      simp [SelfObserving.withoutP8b, withoutP8b, referenceWith, Features.all]
theorem withoutP8b_fwd (m r : Mon) :
    SelfObserving.withoutP8b.fwd m r ↔ withoutP8b.fwd m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutP8b, withoutP8b, referenceWith, Features.all]
theorem withoutP8b_haltInputs (w : Wk) (m : Mon) :
    SelfObserving.withoutP8b.haltInputs w m ↔ withoutP8b.haltInputs w m := by
  cases w <;> cases m <;>
    simp [SelfObserving.withoutP8b, withoutP8b, referenceWith, Features.all]
theorem withoutP8b_switches (m : Mon) :
    SelfObserving.withoutP8b.switches m ↔ withoutP8b.switches m := by
  cases m <;>
    simp [SelfObserving.withoutP8b, withoutP8b, referenceWith, Features.all]
theorem withoutP8b_coupling : SelfObserving.withoutP8b.coupling = withoutP8b.coupling := rfl
theorem withoutP8b_window : SelfObserving.withoutP8b.window = withoutP8b.window := rfl
theorem withoutP8b_gate : SelfObserving.withoutP8b.gate = withoutP8b.gate := rfl
theorem withoutP8b_slowReports :
    SelfObserving.withoutP8b.slowReports = withoutP8b.slowReports := rfl

/-- `withoutP8b` of `Reference.lean` is `reference(without=('P8b',))`. -/
theorem withoutP8b_eq : SelfObserving.withoutP8b = withoutP8b :=
  Finite.system_ext withoutP8b_f withoutP8b_joiner withoutP8b_boundary withoutP8b_substrate
    withoutP8b_hbReaders withoutP8b_checkers withoutP8b_fwd withoutP8b_haltInputs
    withoutP8b_switches withoutP8b_coupling withoutP8b_window withoutP8b_gate
    withoutP8b_slowReports

/-! ### `reference(without=('gate',))` -/

/-- `reference(without=('gate',))` of check_model.py, written out. -/
def withoutGate : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    match m with
    | .M1 => some .b1
    | .M2 => some .b2
    | .M3 => some .b3
  substrate := fun p =>
    match p with
    | .inl .M1 => some .s1
    | .inl .M2 => some .s2
    | .inl .M3 => some .s3
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
  hbReaders := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  checkers := fun x m =>
    (x = .inl .M1 ∧ m = .M2) ∨ (x = .inl .M1 ∧ m = .M3) ∨ (x = .inl .M2 ∧ m = .M1) ∨
    (x = .inl .M2 ∧ m = .M3) ∨ (x = .inl .M3 ∧ m = .M1) ∨ (x = .inl .M3 ∧ m = .M2) ∨
    (x = .inr .W1 ∧ m = .M1) ∨ (x = .inr .W2 ∧ m = .M2) ∨ (x = .inr .J ∧ m = .M3)
  fwd := fun m r =>
    (m = .M1 ∧ r = .M2) ∨ (m = .M1 ∧ r = .M3) ∨ (m = .M2 ∧ r = .M1) ∨ (m = .M2 ∧ r = .M3) ∨
    (m = .M3 ∧ r = .M1) ∨ (m = .M3 ∧ r = .M2)
  haltInputs := fun w m =>
    (w = .W1 ∧ m = .M1) ∨ (w = .W1 ∧ m = .M3) ∨ (w = .W2 ∧ m = .M2) ∨ (w = .W2 ∧ m = .M3) ∨
    (w = .J ∧ m = .M3) ∨ (w = .J ∧ m = .M1)
  switches := fun _ => False
  coupling := true
  window := 0
  gate := false
  slowReports := false

theorem withoutGate_f : SelfObserving.withoutGate.f = withoutGate.f := rfl
theorem withoutGate_joiner : SelfObserving.withoutGate.joiner = withoutGate.joiner := rfl
theorem withoutGate_boundary (m : Mon) :
    SelfObserving.withoutGate.boundary m = withoutGate.boundary m := by
  cases m <;> rfl
theorem withoutGate_substrate (p : Proc Mon Wk) :
    SelfObserving.withoutGate.substrate p = withoutGate.substrate p := by
  cases p with
  | inl m => cases m <;> rfl
  | inr w => cases w <;> rfl
theorem withoutGate_hbReaders (m r : Mon) :
    SelfObserving.withoutGate.hbReaders m r ↔ withoutGate.hbReaders m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutGate, withoutGate, referenceWith, Features.all]
theorem withoutGate_checkers (x : Proc Mon Wk) (m : Mon) :
    SelfObserving.withoutGate.checkers x m ↔ withoutGate.checkers x m := by
  cases x with
  | inl a =>
    cases a <;> cases m <;>
      simp [SelfObserving.withoutGate, withoutGate, referenceWith, Features.all]
  | inr w =>
    cases w <;> cases m <;>
      simp [SelfObserving.withoutGate, withoutGate, referenceWith, Features.all]
theorem withoutGate_fwd (m r : Mon) :
    SelfObserving.withoutGate.fwd m r ↔ withoutGate.fwd m r := by
  cases m <;> cases r <;>
    simp [SelfObserving.withoutGate, withoutGate, referenceWith, Features.all]
theorem withoutGate_haltInputs (w : Wk) (m : Mon) :
    SelfObserving.withoutGate.haltInputs w m ↔ withoutGate.haltInputs w m := by
  cases w <;> cases m <;>
    simp [SelfObserving.withoutGate, withoutGate, referenceWith, Features.all]
theorem withoutGate_switches (m : Mon) :
    SelfObserving.withoutGate.switches m ↔ withoutGate.switches m := by
  cases m <;>
    simp [SelfObserving.withoutGate, withoutGate, referenceWith, Features.all]
theorem withoutGate_coupling : SelfObserving.withoutGate.coupling = withoutGate.coupling := rfl
theorem withoutGate_window : SelfObserving.withoutGate.window = withoutGate.window := rfl
theorem withoutGate_gate : SelfObserving.withoutGate.gate = withoutGate.gate := rfl
theorem withoutGate_slowReports :
    SelfObserving.withoutGate.slowReports = withoutGate.slowReports := rfl

/-- `withoutGate` of `Reference.lean` is `reference(without=('gate',))`. -/
theorem withoutGate_eq : SelfObserving.withoutGate = withoutGate :=
  Finite.system_ext withoutGate_f withoutGate_joiner withoutGate_boundary withoutGate_substrate
    withoutGate_hbReaders withoutGate_checkers withoutGate_fwd withoutGate_haltInputs
    withoutGate_switches withoutGate_coupling withoutGate_window withoutGate_gate
    withoutGate_slowReports

end Py
end SelfObserving
