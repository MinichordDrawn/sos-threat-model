/-
GENERATED FILE. Do not edit it: change tools/gen.py and run it again.

Written by tools/gen.py from check_model.py of the model check
(SHA-256 2c788a4a1d8d3c9d12cb08608cff4b8a3257634527e5bfee433ccef6b2fa294d).

`reference()`: the 23 states that the Python's `explore()` reaches, in
the order it first reaches them. The statements:

- `reference_covers`: the list holds the initial state; every round from a state of
  the list that is not responded ends in a state of the list; and none of those
  rounds violates G1 or G2. Lean computes every such round in the model.
- `reference_reached`: every state of the list is reached, by the round given for
  it in `reference_parents`: the position in the list of the state the round starts
  from, and the environment's step.
- `reference_count`: the list has 23 states, no two the same, and the rounds from
  those that are not responded number 26: one with no step, and one for each
  enabled step. The generator counts the rounds this way from `env_steps()`;
  `explore()` merges the steps of a state that end in the same state, and runs
  fewer.

Lean checks these three statements. Of the order of the list they need only this:
the initial state is first, and each later state comes after the state its round
starts from. Lean does not check that the order is the order of the Python's
search, or that the round given for a state is the first that reaches it.

A state is written as 31 truth values, `T` or `F`, in this order: `alive`, `bad`,
`hidden` (each M1 M2 M3, then W1 W2 J), `off`, `flagged` (M1 M2 M3), `halted`,
`pending` (W1 W2 J), `joined`.
-/
import SelfObserving.Proofs.Removals

namespace SelfObserving
namespace Py

open Finite

local notation "T" => true
local notation "F" => false

/-- The states `explore()` reaches in `reference()`. -/
def reference_states : List CState := [
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,T,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,T⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,F⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨T,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,T,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,T⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩]

/-- For each state after the first: the round that first reaches it. -/
def reference_parents : List (Nat × Option (EnvStep Mon Wk Bd Sub)) := [
  (0, some (.stop .M1)),
  (0, some (.stop .M2)),
  (0, some (.stop .M3)),
  (0, some (.failSubstrate .s1)),
  (0, some (.failSubstrate .s2)),
  (0, some (.mutate (.inl .M1))),
  (0, some (.mutate (.inl .M2))),
  (0, some (.mutate (.inl .M3))),
  (0, some (.mutate (.inr .W1))),
  (0, some (.mutate (.inr .W2))),
  (0, some .join),
  (11, some (.stop .M1)),
  (11, some (.stop .M2)),
  (11, some (.stop .M3)),
  (11, some (.failSubstrate .s1)),
  (11, some (.failSubstrate .s2)),
  (11, some (.mutate (.inl .M1))),
  (11, some (.mutate (.inl .M2))),
  (11, some (.mutate (.inl .M3))),
  (11, some (.mutate (.inr .W1))),
  (11, some (.mutate (.inr .W2))),
  (11, some (.mutate (.inr .J)))]

theorem reference_covers :
    covers SelfObserving.reference reference_states true true = true := by
  decide +kernel

theorem reference_reached :
    reaches SelfObserving.reference reference_states reference_parents = true := by
  decide +kernel

theorem reference_count :
    reference_states.length = 23 ∧ distinct reference_states = true ∧
      countRounds SelfObserving.reference reference_states = 26 := by
  decide +kernel

end Py
end SelfObserving
