/-
The reference system R of the model check and its ten removals. The definition follows
`reference(without=...)` in `check_model.py` line for line, and section 5 of `results.md`,
at one fault per round. The Python's `f` and its option for a fourth monitor are not
carried over. Everything in this file is a definition.
-/
import SelfObserving.Conditions

namespace SelfObserving

/-- The three monitors of R. -/
inductive Mon where
  | M1
  | M2
  | M3
  deriving DecidableEq

/-- The non-monitor processes of R: two work processes, and J, which may join later. -/
inductive Wk where
  | W1
  | W2
  | J
  deriving DecidableEq

/-- Boundary ids. -/
inductive Bd where
  | b1
  | b2
  | b3
  deriving DecidableEq

/-- Substrate ids. `s4` and `s5` are used only when P2 is removed. -/
inductive Sub where
  | s1
  | s2
  | s3
  | s4
  | s5
  deriving DecidableEq

/-- Which of the ten features a system keeps: the eight properties, the halt fan-out
clause of the eighth taken separately, and the gate. -/
structure Features where
  p1 : Bool
  p2 : Bool
  p3 : Bool
  p4 : Bool
  p5 : Bool
  p6 : Bool
  p7 : Bool
  p8 : Bool
  p8b : Bool
  gate : Bool

/-- Every feature kept. -/
def Features.all : Features :=
  { p1 := true, p2 := true, p3 := true, p4 := true, p5 := true, p6 := true, p7 := true,
    p8 := true, p8b := true, gate := true }

/-- The reference system with the features `on`, at one fault per round.

- P6: each monitor sits in its own boundary. Without it, all three share one.
- P2: M1 runs on W1's substrate and M2 on W2's. Without it, each has a substrate of its
  own.
- P1: every monitor's signal is read by the other two, and work halts on silence.
- P3: M1 is the only state checker of W1 and M2 of W2, and the monitors check each other.
- P4: every monitor reports to the other two.
- P8b: W1 halts on M1 or M3, and W2 on M2 or M3. Without it, each halts on its local
  monitor alone.
- P7: J, once joined, is checked by M3 and halts on M3 or M1.
- P5: no monitor has an off switch. Without it, every monitor has one.
- P8: no window. Without it, the window is 1.
- The gate: the monitors check before the work processes step. -/
def referenceWith (on : Features) : System Mon Wk Bd Sub where
  f := 1
  joiner := some .J
  boundary := fun m =>
    if on.p6 = true then
      match m with
      | .M1 => some .b1
      | .M2 => some .b2
      | .M3 => some .b3
    else some .b1
  substrate := fun p =>
    match p with
    | .inr .W1 => some .s1
    | .inr .W2 => some .s2
    | .inr .J => none
    | .inl .M3 => some .s3
    | .inl .M1 => if on.p2 = true then some .s1 else some .s4
    | .inl .M2 => if on.p2 = true then some .s2 else some .s5
  hbReaders := fun m r => on.p1 = true ∧ r ≠ m
  checkers := fun x r =>
    on.p3 = true ∧
      match x with
      | .inl m => r ≠ m
      | .inr .W1 => r = .M1
      | .inr .W2 => r = .M2
      | .inr .J => on.p7 = true ∧ r = .M3
  fwd := fun m r => on.p4 = true ∧ r ≠ m
  haltInputs := fun w r =>
    match w with
    | .W1 => r = .M1 ∨ (on.p8b = true ∧ r = .M3)
    | .W2 => r = .M2 ∨ (on.p8b = true ∧ r = .M3)
    | .J => on.p7 = true ∧ (r = .M3 ∨ (on.p8b = true ∧ r = .M1))
  switches := fun _ => on.p5 = false
  coupling := on.p1
  window := if on.p8 = true then 0 else 1
  gate := on.gate
  slowReports := false

/-- The reference system R: every feature kept. -/
def reference : System Mon Wk Bd Sub := referenceWith Features.all

/-- R without P1, the liveness signal. -/
def withoutP1 : System Mon Wk Bd Sub := referenceWith { Features.all with p1 := false }

/-- R without P2, shared substrate. -/
def withoutP2 : System Mon Wk Bd Sub := referenceWith { Features.all with p2 := false }

/-- R without P3, the state check. -/
def withoutP3 : System Mon Wk Bd Sub := referenceWith { Features.all with p3 := false }

/-- R without P4, propagation. -/
def withoutP4 : System Mon Wk Bd Sub := referenceWith { Features.all with p4 := false }

/-- R without P5, no single-step removal. -/
def withoutP5 : System Mon Wk Bd Sub := referenceWith { Features.all with p5 := false }

/-- R without P6, the out-of-boundary signal. -/
def withoutP6 : System Mon Wk Bd Sub := referenceWith { Features.all with p6 := false }

/-- R without P7, automatic enrolment. -/
def withoutP7 : System Mon Wk Bd Sub := referenceWith { Features.all with p7 := false }

/-- R without P8, immediate response. -/
def withoutP8 : System Mon Wk Bd Sub := referenceWith { Features.all with p8 := false }

/-- R without the halt fan-out. -/
def withoutP8b : System Mon Wk Bd Sub := referenceWith { Features.all with p8b := false }

/-- R without the gate. -/
def withoutGate : System Mon Wk Bd Sub := referenceWith { Features.all with gate := false }

end SelfObserving
