/-
GENERATED FILE. Do not edit it: change tools/gen.py and run it again.

Written by tools/gen.py from check_model.py of the model check
(SHA-256 2c788a4a1d8d3c9d12cb08608cff4b8a3257634527e5bfee433ccef6b2fa294d).

`reference(without=('P4',))`: the 59 states that the Python's `explore()` reaches, in
the order it first reaches them. The statements:

- `withoutP4_covers`: the list holds the initial state; every round from a state of
  the list that is not responded ends in a state of the list; and none of those
  rounds violates G1. Lean computes every such round in the model.
- `withoutP4_reached`: every state of the list is reached, by the round given for
  it in `withoutP4_parents`: the position in the list of the state the round starts
  from, and the environment's step.
- `withoutP4_count`: the list has 59 states, no two the same, and the rounds from
  those that are not responded number 74: one with no step, and one for each
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

/-- The states `explore()` reaches in `reference(without=('P4',))`. -/
def withoutP4_states : List CState := [
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,T,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,T⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,F⟩, ⟨T,F,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,F⟩, ⟨F,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,T,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,T⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,F⟩, ⟨T,F,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,T,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,T⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,F⟩, ⟨F,T,F⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,F⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨T,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,T,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,T⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,F⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨T,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,T,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,T⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,F⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨F,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,F,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨T,F,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,T,F⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,T⟩,⟨F,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩,
  ⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,T⟩, ⟨F,F,F⟩, T⟩]

/-- For each state after the first: the round that first reaches it. -/
def withoutP4_parents : List (Nat × Option (EnvStep Mon Wk Bd Sub)) := [
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
  (9, some (.stop .M1)),
  (9, some (.stop .M2)),
  (9, some (.stop .M3)),
  (9, some (.failSubstrate .s1)),
  (9, some (.failSubstrate .s2)),
  (9, some (.mutate (.inl .M1))),
  (9, some (.mutate (.inl .M2))),
  (9, some (.mutate (.inl .M3))),
  (9, some (.mutate (.inr .W2))),
  (9, some .join),
  (10, some (.stop .M1)),
  (10, some (.stop .M2)),
  (10, some (.stop .M3)),
  (10, some (.failSubstrate .s1)),
  (10, some (.failSubstrate .s2)),
  (10, some (.mutate (.inl .M1))),
  (10, some (.mutate (.inl .M2))),
  (10, some (.mutate (.inl .M3))),
  (10, some .join),
  (11, some (.stop .M1)),
  (11, some (.stop .M2)),
  (11, some (.stop .M3)),
  (11, some (.failSubstrate .s1)),
  (11, some (.failSubstrate .s2)),
  (11, some (.mutate (.inl .M1))),
  (11, some (.mutate (.inl .M2))),
  (11, some (.mutate (.inl .M3))),
  (11, some (.mutate (.inr .J))),
  (21, some (.stop .M1)),
  (21, some (.stop .M2)),
  (21, some (.stop .M3)),
  (21, some (.failSubstrate .s1)),
  (21, some (.failSubstrate .s2)),
  (21, some (.mutate (.inl .M1))),
  (21, some (.mutate (.inl .M2))),
  (21, some (.mutate (.inl .M3))),
  (21, some (.mutate (.inr .W2))),
  (21, some (.mutate (.inr .J))),
  (30, some (.stop .M1)),
  (30, some (.stop .M2)),
  (30, some (.stop .M3)),
  (30, some (.failSubstrate .s1)),
  (30, some (.failSubstrate .s2)),
  (30, some (.mutate (.inl .M1))),
  (30, some (.mutate (.inl .M2))),
  (30, some (.mutate (.inl .M3))),
  (30, some (.mutate (.inr .J)))]

theorem withoutP4_covers :
    covers SelfObserving.withoutP4 withoutP4_states true false = true := by
  decide +kernel

theorem withoutP4_reached :
    reaches SelfObserving.withoutP4 withoutP4_states withoutP4_parents = true := by
  decide +kernel

theorem withoutP4_count :
    withoutP4_states.length = 59 ∧ distinct withoutP4_states = true ∧
      countRounds SelfObserving.withoutP4 withoutP4_states = 74 := by
  decide +kernel

end Py
end SelfObserving
