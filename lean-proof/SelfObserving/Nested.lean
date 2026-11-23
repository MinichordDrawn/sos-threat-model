/-
The interleaved rings on two levels of `results.md`, sections 2.7 and 10.1: two base
rings, each three members and a coordinator, joined by an upper ring of the two
coordinators and a third member. The definition follows `nested(3, True, 1,
ring_boundaries)` in `check_model.py` edge for edge, at one fault per round. Everything in
this file is a definition.
-/
import SelfObserving.Model

namespace SelfObserving

/-- The nine monitors. A1, A2, A3 are the members of base ring A and KA its coordinator;
B1, B2, B3 and KB the same for base ring B; KA, KB and U3 make the upper ring. -/
inductive NMon where
  | A1
  | A2
  | A3
  | KA
  | B1
  | B2
  | B3
  | KB
  | U3
  deriving DecidableEq

/-- The two work processes, one for each base ring. -/
inductive NWk where
  | WA
  | WB
  deriving DecidableEq

/-- Boundary ids: one for each monitor by itself, and one for each base ring whole. -/
inductive NBd where
  | own (m : NMon)
  | ringA
  | ringB

/-- The interleaved rings on two levels, at one fault per round.

In a base ring each member checks the state of, and reads the signal of, the next member
(A1 the next of A3), and reports to the member it does not check and to the coordinator.
The coordinator reads every member's signal and reports to every member; the first member
checks its state and reads its signal. The work process of the ring is checked by the
first member and takes its halt from that member and the coordinator.

In the upper ring (KA, KB, U3) each member checks the state of, and reads the signal of,
the next (KA the next of U3), and reports to the one it does not check.

With `ringBoundaries`, each base ring sits whole in one boundary (its three members and
its coordinator), and U3 in one of its own. Without, every monitor is in a boundary of its
own. There are no substrates, no joiner and no switches; work halts on silence; there is
no window; the gate is in place; reports arrive within the round. -/
def nested (ringBoundaries : Bool) : System NMon NWk NBd Unit where
  f := 1
  joiner := none
  boundary := fun m =>
    if ringBoundaries = true then
      match m with
      | .A1 | .A2 | .A3 | .KA => some .ringA
      | .B1 | .B2 | .B3 | .KB => some .ringB
      | .U3 => some (.own .U3)
    else some (.own m)
  substrate := fun _ => none
  hbReaders := fun p r =>
    match p with
    | .A1 => r = .A3 ∨ r = .KA
    | .A2 => r = .A1 ∨ r = .KA
    | .A3 => r = .A2 ∨ r = .KA
    | .KA => r = .A1 ∨ r = .U3
    | .B1 => r = .B3 ∨ r = .KB
    | .B2 => r = .B1 ∨ r = .KB
    | .B3 => r = .B2 ∨ r = .KB
    | .KB => r = .B1 ∨ r = .KA
    | .U3 => r = .KB
  checkers := fun x r =>
    match x with
    | .inl .A1 => r = .A3
    | .inl .A2 => r = .A1
    | .inl .A3 => r = .A2
    | .inl .KA => r = .A1 ∨ r = .U3
    | .inl .B1 => r = .B3
    | .inl .B2 => r = .B1
    | .inl .B3 => r = .B2
    | .inl .KB => r = .B1 ∨ r = .KA
    | .inl .U3 => r = .KB
    | .inr .WA => r = .A1
    | .inr .WB => r = .B1
  fwd := fun m r =>
    match m with
    | .A1 => r = .A3 ∨ r = .KA
    | .A2 => r = .A1 ∨ r = .KA
    | .A3 => r = .A2 ∨ r = .KA
    | .KA => r = .A1 ∨ r = .A2 ∨ r = .A3 ∨ r = .U3
    | .B1 => r = .B3 ∨ r = .KB
    | .B2 => r = .B1 ∨ r = .KB
    | .B3 => r = .B2 ∨ r = .KB
    | .KB => r = .B1 ∨ r = .B2 ∨ r = .B3 ∨ r = .KA
    | .U3 => r = .KB
  haltInputs := fun w r =>
    match w with
    | .WA => r = .A1 ∨ r = .KA
    | .WB => r = .B1 ∨ r = .KB
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

end SelfObserving
