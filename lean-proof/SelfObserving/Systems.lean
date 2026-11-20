/-
Named systems used in the statements. Everything in this file is a definition.
-/
import SelfObserving.Conditions

namespace SelfObserving

/-- A full mesh over any type `M` of monitors and any type `W` of work processes, at one
fault per round. Every monitor reads the signal of, checks the state of, and reports to
every other monitor. Every work process is checked by every monitor and takes its halt
from every monitor. Each monitor is its own boundary. With four monitors and one work
process it is the checker's "mesh of 4". -/
def mesh (M W : Type) : System M W M Unit where
  f := 1
  joiner := none
  boundary := fun m => some m
  substrate := fun _ => none
  hbReaders := fun m r => r ≠ m
  checkers := fun x r =>
    match x with
    | .inl m => r ≠ m
    | .inr _ => True
  fwd := fun m r => r ≠ m
  haltInputs := fun _ _ => True
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

/-- One work process and no monitor, at one fault per round. -/
def unwatched : System Empty Unit Unit Unit where
  f := 1
  joiner := none
  boundary := fun _ => none
  substrate := fun _ => none
  hbReaders := fun _ _ => False
  checkers := fun _ _ => False
  fwd := fun _ _ => False
  haltInputs := fun _ _ => False
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

end SelfObserving
