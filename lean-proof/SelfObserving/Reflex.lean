/-
The execution of `results.md`, section 8.1, in the round model of `Model.lean`: the
environment's only step is to mutate one work process, in round 1. Everything in this
file is a definition.
-/
import SelfObserving.Model

namespace SelfObserving

variable {M W B S : Type}

/-- `Hops sys n k h`: `h` is reached from `k` in exactly `n` report hops. With no hop,
`h` is `k` itself. -/
inductive Hops (sys : System M W B S) : Nat → M → M → Prop where
  | zero (k : M) : Hops sys 0 k k
  | succ {n : Nat} {k y h : M} : Hops sys n k y → sys.fwd y h → Hops sys (n + 1) k h

/-- The execution in which the environment mutates the work process `w` in round 1 and
takes no step in any later round. `soloEnv sys w j` is the state reached by the
environment phase of round `j + 1`: for round 1, the initial state with `w` mutated; for
a later round, the state the round before it ended in, since the environment takes no
step. -/
def soloEnv (sys : System M W B S) (w : W) : Nat → State M W
  | 0 => effect sys (init sys) (.mutate (.inr w))
  | j + 1 => (afterEnv sys (soloEnv sys w j)).next

/-- The state that round `j + 1` of that execution starts from: the initial state for
round 1, and for a later round the state the round before it ended in. -/
def soloStart (sys : System M W B S) (w : W) : Nat → State M W
  | 0 => init sys
  | j + 1 => (afterEnv sys (soloEnv sys w j)).next

/-- In a system with the gate: in round `j + 1` of that execution, `w` takes a work step
while its state is bad. The monitor phase runs on the state the environment phase
reached, and the work phase uses its `out`. -/
def SoloWorks (sys : System M W B S) (w : W) (j : Nat) : Prop :=
  (monitorPhase sys (soloEnv sys w j)).bad (.inr w) ∧
    Worked sys (monitorPhase sys (soloEnv sys w j))
      (Out (monitorPhase sys (soloEnv sys w j))) w

end SelfObserving
