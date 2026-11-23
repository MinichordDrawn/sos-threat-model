/-
The ring one level up, at any number of levels: the tower of `results-minimal.md`,
sections 4 and 4.6. Everything in this file is a definition.

A tower of one level is one ring: three members in a cycle and a coordinator connected to
each both ways. A tower of `n + 1` levels is three towers of `n` levels and a top
coordinator, with the three top coordinators of the smaller towers as the members of the
upper ring: in a cycle, and the new top coordinator connected to each both ways. So every
monitor that is not at the bottom is the coordinator of a ring of four: itself and its
three members. A tower of `n` levels has 4, 13, 40, ... monitors for `n` = 1, 2, 3, ...

Each ring at the bottom (a *base ring*) has one work process, which is checked by the four
monitors of its ring and takes its halt from those four ("the work reads all").

`nested` of `Nested.lean` is a different system: two base rings and an upper ring made of
their two coordinators and a third member, with no coordinator above; its base
coordinators check the state of no member of their own ring, and its work reads two
monitors.
-/
import SelfObserving.Rings

namespace SelfObserving

/-- A monitor of the tower of `n` levels, named by the way from it up to the top
coordinator. `[]` is the top coordinator. `i :: p` is member `i` of the ring that `p`
coordinates. The names have length at most `n`; those of length `n` are the members of
the base rings. -/
abbrev TowerMon (n : Nat) : Type := {p : List (Fin 3) // p.length ≤ n}

/-- A work process of the tower of `n` levels, named by the coordinator of its base ring:
a name of length `n - 1`. A tower of no levels has no work process. -/
abbrev TowerWk (n : Nat) : Type := {q : List (Fin 3) // q.length + 1 = n}

/-- The connections of the tower, on names. `x -> y` is a connection when

- `y` is a member of the ring that `x` coordinates (`y = i :: x`), or
- `x` is a member of the ring that `y` coordinates (`x = i :: y`), or
- `x` and `y` are members of one ring and `y` is the next after `x` in its cycle
  (`x = i :: p` and `y = (i + 1) :: p`; in `Fin 3`, 2 + 1 is 0).

In the ring that `p` coordinates this is `0 -> 1 -> 2 -> 0`, the coordinator to each
member, and each member to the coordinator: the candidate ring of `Rings.lean`. -/
def towerConn (x y : List (Fin 3)) : Prop :=
  (∃ i, y = i :: x) ∨ (∃ i, x = i :: y) ∨ (∃ i p, x = i :: p ∧ y = (i + 1) :: p)

/-- `InRing q m`: the monitor named `m` is one of the four of the ring that `q`
coordinates: `q` itself or one of its three members. -/
def InRing (q m : List (Fin 3)) : Prop :=
  m = q ∨ ∃ i, m = i :: q

/-- Boundary ids of the tower: one for each monitor by itself, and one for each base ring
whole, named by the ring's coordinator. -/
inductive TowerBd where
  | own (p : List (Fin 3))
  | ring (q : List (Fin 3))

/-- The boundary of the monitor named `p` in the tower of `n` levels when each base ring
is whole in one boundary: a base ring's coordinator (a name of length `n - 1`) and its
members (names of length `n`, whose coordinator is the name without its first entry) are
in the boundary of that ring; every other monitor is in a boundary of its own. -/
def towerRingBoundary (n : Nat) (p : List (Fin 3)) : TowerBd :=
  if p.length + 1 = n then .ring p
  else if p.length = n then .ring p.tail
  else .own p

/-- The tower of `n` levels under the reading `rd`, at `f` faults per round.

`r` reads the signal of `p`, and checks the state of `p`, exactly when the reading makes
`r` watch `p` through the connections of `towerConn`; `m` reports to `r` exactly when the
connection `m -> r` is there. The work process of a base ring is checked by the four
monitors of that ring and takes its halt from those four.

With `ringBoundaries`, each base ring sits whole in one boundary (its coordinator and its
three members), and every other monitor in one of its own. Without, every monitor is in a
boundary of its own. There are no substrates, no joiner and no switches; work halts on
silence; there is no window; the gate is in place; reports arrive within the round. -/
def tower (rd : Reading) (n : Nat) (ringBoundaries : Bool) (f : Nat) :
    System (TowerMon n) (TowerWk n) TowerBd Unit where
  f := f
  joiner := none
  boundary := fun m =>
    if ringBoundaries = true then some (towerRingBoundary n m.val) else some (.own m.val)
  substrate := fun _ => none
  hbReaders := fun p r => rd.watches towerConn r.val p.val
  checkers := fun x r =>
    match x with
    | .inl p => rd.watches towerConn r.val p.val
    | .inr w => InRing w.val r.val
  fwd := fun m r => towerConn m.val r.val
  haltInputs := fun w r => InRing w.val r.val
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

end SelfObserving
