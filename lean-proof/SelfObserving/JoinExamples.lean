/-
Two systems with monitors that join, from `results-join.md`, sections 3 and 5: the two
that show the hypothesis of Theorem L on slow edges and on switches is needed. Both grow
the mesh of four monitors, with one work process that is checked by the four and takes
its halt from the four. Everything in this file is a definition.

The four monitors of the mesh are `.inl 0` to `.inl 3` (M1 to M4 of `results-join.md`);
the late monitors are the `.inr` ones.
-/
import SelfObserving.JoinConditions
import SelfObserving.MeshAt

namespace SelfObserving

/-- `results-join.md`, section 5, the row "the three checks of N late, the rest at once".
One late monitor N (`.inr ()`), in a group of its own that may join at any time, in a
mesh with M1, M2 and M3: each of the three and N read each other's signal, check each
other's state and report to each other. The three checks of N's state are slow edges; no
other edge is. M4 has no edge with N. The work process is checked by the four monitors of
the mesh and takes its halt from them. Each monitor is in a boundary of its own; no
substrates, switches or joiner; work halts on silence; no window; the gate in place;
reports within the round. -/
def slowCheckExample (arriveBad : Bool) (f : Nat) :
    JSystem (Fin 4 ⊕ Unit) Unit (Fin 4 ⊕ Unit) Unit Unit where
  base :=
    { f := f
      joiner := none
      boundary := fun m => some m
      substrate := fun _ => none
      hbReaders := fun p r =>
        match p, r with
        | .inl a, .inl b => b ≠ a
        | .inl a, .inr _ => a.val < 3
        | .inr _, .inl b => b.val < 3
        | .inr _, .inr _ => False
      checkers := fun x r =>
        match x, r with
        | .inl (.inl a), .inl b => b ≠ a
        | .inl (.inl a), .inr _ => a.val < 3
        | .inl (.inr _), .inl b => b.val < 3
        | .inl (.inr _), .inr _ => False
        | .inr _, .inl _ => True
        | .inr _, .inr _ => False
      fwd := fun m r =>
        match m, r with
        | .inl a, .inl b => b ≠ a
        | .inl a, .inr _ => a.val < 3
        | .inr _, .inl b => b.val < 3
        | .inr _, .inr _ => False
      haltInputs := fun _ r =>
        match r with
        | .inl _ => True
        | .inr _ => False
      switches := fun _ => False
      coupling := true
      window := 0
      gate := true
      slowReports := false }
  group := fun m =>
    match m with
    | .inl _ => none
    | .inr _ => some ()
  joinerGroup := none
  after := fun _ _ => False
  arriveBad := arriveBad
  slowHb := fun _ _ => False
  slowCheck := fun x m =>
    match x, m with
    | .inl (.inr _), .inl b => b.val < 3
    | _, _ => False
  slowFwd := fun _ _ => False
  slowHalt := fun _ _ => False

/-- `results-join.md`, section 3, the system after the proof of Theorem L. Two late
monitors, N5 (`.inr 0`) and N6 (`.inr 1`), each in a group of its own. N5 is watched by M1
(`.inl 0`) and reports to it. N6 is watched by N5 and reports to it, and may join only
when N5 is present. N5 has an off switch. Monitors arrive good, and no edge is slow. The
work process is checked by the four monitors of the mesh and takes its halt from them.
One fault per round. Each monitor is in a boundary of its own; no substrates or joiner;
work halts on silence; no window; the gate in place; reports within the round. -/
def switchExample : JSystem (Fin 4 ⊕ Fin 2) Unit (Fin 4 ⊕ Fin 2) Unit (Fin 2) where
  base :=
    { f := 1
      joiner := none
      boundary := fun m => some m
      substrate := fun _ => none
      hbReaders := fun p r =>
        match p, r with
        | .inl a, .inl b => b ≠ a
        | .inr i, .inl b => i = 0 ∧ b = 0
        | .inr i, .inr j => i = 1 ∧ j = 0
        | .inl _, .inr _ => False
      checkers := fun x r =>
        match x, r with
        | .inl (.inl a), .inl b => b ≠ a
        | .inl (.inr i), .inl b => i = 0 ∧ b = 0
        | .inl (.inr i), .inr j => i = 1 ∧ j = 0
        | .inl (.inl _), .inr _ => False
        | .inr _, .inl _ => True
        | .inr _, .inr _ => False
      fwd := fun m r =>
        match m, r with
        | .inl a, .inl b => b ≠ a
        | .inr i, .inl b => i = 0 ∧ b = 0
        | .inr i, .inr j => i = 1 ∧ j = 0
        | .inl _, .inr _ => False
      haltInputs := fun _ r =>
        match r with
        | .inl _ => True
        | .inr _ => False
      switches := fun m => m = .inr 0
      coupling := true
      window := 0
      gate := true
      slowReports := false }
  group := fun m =>
    match m with
    | .inl _ => none
    | .inr i => some i
  joinerGroup := none
  after := fun g p => g = 1 ∧ p = .inl (.inr 0)
  arriveBad := false
  slowHb := fun _ _ => False
  slowCheck := fun _ _ => False
  slowFwd := fun _ _ => False
  slowHalt := fun _ _ => False

/-- The ranking used for `switchExample`: N6 has rank 1, every other monitor rank 0. -/
def switchRank : Fin 4 ⊕ Fin 2 → Nat
  | .inr 1 => 1
  | _ => 0

/-- The monitor each late monitor of `switchExample` relies on, for its state check, its
signal and its report alike: N5 for N6, and M1 otherwise. -/
def switchRelies : Fin 4 ⊕ Fin 2 → Fin 4 ⊕ Fin 2
  | .inr 1 => .inr 0
  | _ => .inl 0

end SelfObserving
