/-
A small game to run the model on: values are numbers, the work adds to them. It is used
to evaluate the model (`Faithful.lean`) and for the two faults of T6 (`Solution.lean`).
Nothing is proved about it here.
-/
import GateProof.Model

namespace Gate.Toy

abbrev V := Nat
abbrev Q := List Nat
abbrev E := Nat
abbrev Tm := Nat
abbrev Dt := Nat

/-- A toy game. The edge (part 3) is fixed at 10 and the rules say so. Taking in adds
what was asked to part 6. The world adds to parts 4 and 5 and to part 6, the spider to
parts 0, 1 and 2. The world's work reads the list of halted moths only modulo 9 (in the
real game a number added to that list that no moth has changes nothing). Something asked
is a number; 0 is a letting go, taken down even while halted. No two values share a
fingerprint here. -/
def P : Params V Q E Tm Dt where
  blank := 0
  fp := fun v => 2 * v + 1000001
  takeIn₁ := fun s q => fun p => if p = 6 then s 6 + q.sum else s p
  takeIn₂ := fun s q => fun p => if p = 6 then s 6 + q.sum else s p
  world₁ := fun s h dt _ => fun p =>
    if p = 4 then s 4 + 1 + h % 9 else if p = 5 then s 5 + dt else if p = 6 then s 6 + 1 else s p
  world₂ := fun s h dt _ => fun p =>
    if p = 4 then s 4 + 1 + h % 9 else if p = 5 then s 5 + dt else if p = 6 then s 6 + 1 else s p
  spider₁ := fun s _ _ => fun p => if p.val < 3 then s p + 1 + s 6 % 2 else s p
  spider₂ := fun s _ _ => fun p => if p.val < 3 then s p + 1 + s 6 % 2 else s p
  inWeb₁ := fun s => s 5 % 3 + 1
  inWeb₂ := fun s => s 5 % 3 + 1
  real := fun s => decide (s 3 < 1000000)
  canBe₁ := fun s => s 3 == 10
  canBe₂ := fun s => s 3 == 10
  step₁ := fun was _ is _ _ _ => is 3 == was 3 && decide (was 4 ≤ is 4)
  step₂ := fun was _ is _ _ _ => is 3 == was 3 && decide (was 4 ≤ is 4)
  takeDown := fun _ e q => q ++ [e]
  taken := fun halted _ e => !halted || e == 0
  noAsks := []
  letGo := [0]
  len := fun clock c => c - clock
  adv := fun t d => t + d
  readable := fun _ => true
  pauseOver := fun quiet now => decide (quiet + 36 ≤ now)
  newState := fun _ => fun p => if p = 3 then 10 else p.val + 20

/-- A game that has run for `n` rounds with no fault, each a tick of the clock long. -/
def played : Nat → Game V Q Tm
  | 0 => newGame P 0
  | n + 1 => (round P (.clock (n + 1)) .none (played n)).g

/-- The toy game after three rounds with no fault, set to end halts at once. -/
def base : Game V Q Tm := keep (fun b => { b with how := How.atOnce }) (played 3)

end Gate.Toy
