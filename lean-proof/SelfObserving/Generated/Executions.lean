/-
GENERATED FILE. Do not edit it: change tools/gen.py and run it again.

Written by tools/gen.py from check_model.py of the model check
(SHA-256 2c788a4a1d8d3c9d12cb08608cff4b8a3257634527e5bfee433ccef6b2fa294d).

For every goal that the Python's `explore()` finds violated in one of the eleven
systems: the shortest violating execution it reports. Each statement gives the
environment's step in each round, and what the Python computes after each round:
the state, whether G1 is violated in the round, and whether G2 is. Lean runs the
execution in the model (`Finite.ctrace`) and has to arrive at the same.

Lean checks that each is an execution with these outcomes. That none is shorter is
the Python's finding, and is not checked here.

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

/-- `reference(without=('P1',))`: G1 is violated in round 1 of this execution.
Round 1: fail-substrate s1. G1 is violated. G2 is violated. -/
theorem withoutP1_g1_trace :
    ctrace SelfObserving.withoutP1 (cinit SelfObserving.withoutP1)
      [some (.failSubstrate .s1)] = some [
  ⟨⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
    T, T⟩] := by
  decide +kernel

/-- `reference(without=('P1',))`: G2 is violated in round 1 of this execution.
Round 1: fail-substrate s1. G1 is violated. G2 is violated. -/
theorem withoutP1_g2_trace :
    ctrace SelfObserving.withoutP1 (cinit SelfObserving.withoutP1)
      [some (.failSubstrate .s1)] = some [
  ⟨⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
    T, T⟩] := by
  decide +kernel

/-- `reference(without=('P2',))`: G1 is violated in round 1 of this execution.
Round 1: fail-substrate s1. G1 is violated. G2 is violated. -/
theorem withoutP2_g1_trace :
    ctrace SelfObserving.withoutP2 (cinit SelfObserving.withoutP2)
      [some (.failSubstrate .s1)] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
    T, T⟩] := by
  decide +kernel

/-- `reference(without=('P2',))`: G2 is violated in round 1 of this execution.
Round 1: fail-substrate s1. G1 is violated. G2 is violated. -/
theorem withoutP2_g2_trace :
    ctrace SelfObserving.withoutP2 (cinit SelfObserving.withoutP2)
      [some (.failSubstrate .s1)] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
    T, T⟩] := by
  decide +kernel

/-- `reference(without=('P3',))`: G1 is violated in round 1 of this execution.
Round 1: mutate M1. G1 is violated. G2 is violated. -/
theorem withoutP3_g1_trace :
    ctrace SelfObserving.withoutP3 (cinit SelfObserving.withoutP3)
      [some (.mutate (.inl .M1))] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
    T, T⟩] := by
  decide +kernel

/-- `reference(without=('P3',))`: G2 is violated in round 1 of this execution.
Round 1: mutate M1. G1 is violated. G2 is violated. -/
theorem withoutP3_g2_trace :
    ctrace SelfObserving.withoutP3 (cinit SelfObserving.withoutP3)
      [some (.mutate (.inl .M1))] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
    T, T⟩] := by
  decide +kernel

/-- `reference(without=('P4',))`: G2 is violated in round 1 of this execution.
Round 1: mutate W1. G2 is violated. -/
theorem withoutP4_g2_trace :
    ctrace SelfObserving.withoutP4 (cinit SelfObserving.withoutP4)
      [some (.mutate (.inr .W1))] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨T,F,F⟩, ⟨T,F,F⟩, ⟨F,F,F⟩, F⟩,
    F, T⟩] := by
  decide +kernel

/-- `reference(without=('P5',))`: G1 is violated in round 2 of this execution.
Round 1: disable M1.
Round 2: mutate W1. G1 is violated. G2 is violated. -/
theorem withoutP5_g1_trace :
    ctrace SelfObserving.withoutP5 (cinit SelfObserving.withoutP5)
      [some (.disable .M1), some (.mutate (.inr .W1))] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨T,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
    F, F⟩,
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨T,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
    T, T⟩] := by
  decide +kernel

/-- `reference(without=('P5',))`: G2 is violated in round 2 of this execution.
Round 1: disable M1.
Round 2: mutate M3. G2 is violated. -/
theorem withoutP5_g2_trace :
    ctrace SelfObserving.withoutP5 (cinit SelfObserving.withoutP5)
      [some (.disable .M1), some (.mutate (.inl .M3))] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨T,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
    F, F⟩,
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,T⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨T,F,F⟩, ⟨F,T,F⟩, ⟨F,T,F⟩, ⟨F,F,F⟩, F⟩,
    F, T⟩] := by
  decide +kernel

/-- `reference(without=('P6',))`: G1 is violated in round 2 of this execution.
Round 1: stop-boundary 1.
Round 2: fail-substrate s1. G1 is violated. -/
theorem withoutP6_g1_trace :
    ctrace SelfObserving.withoutP6 (cinit SelfObserving.withoutP6)
      [some (.stopBoundary .b1), some (.failSubstrate .s1)] = some [
  ⟨⟨⟨⟨F,F,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
    F, F⟩,
  ⟨⟨⟨⟨F,F,F⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, F⟩,
    T, F⟩] := by
  decide +kernel

/-- `reference(without=('P7',))`: G1 is violated in round 2 of this execution.
Round 1: join J.
Round 2: mutate J. G1 is violated. G2 is violated. -/
theorem withoutP7_g1_trace :
    ctrace SelfObserving.withoutP7 (cinit SelfObserving.withoutP7)
      [some .join, some (.mutate (.inr .J))] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, T⟩,
    F, F⟩,
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, T⟩,
    T, T⟩] := by
  decide +kernel

/-- `reference(without=('P7',))`: G2 is violated in round 2 of this execution.
Round 1: join J.
Round 2: fail-substrate s1. G2 is violated. -/
theorem withoutP7_g2_trace :
    ctrace SelfObserving.withoutP7 (cinit SelfObserving.withoutP7)
      [some .join, some (.failSubstrate .s1)] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, T⟩,
    F, F⟩,
  ⟨⟨⟨⟨F,T,T⟩,⟨T,T,T⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,T,F⟩, ⟨F,F,F⟩, T⟩,
    F, T⟩] := by
  decide +kernel

/-- `reference(without=('P8',))`: G2 is violated in round 1 of this execution.
Round 1: fail-substrate s1. G2 is violated. -/
theorem withoutP8_g2_trace :
    ctrace SelfObserving.withoutP8 (cinit SelfObserving.withoutP8)
      [some (.failSubstrate .s1)] = some [
  ⟨⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨F,F,F⟩, ⟨T,T,F⟩, F⟩,
    F, T⟩] := by
  decide +kernel

/-- `reference(without=('P8b',))`: G1 is violated in round 3 of this execution.
Round 1: mutate M1. G2 is violated.
Round 2: stop M2. G2 is violated.
Round 3: stop M3. G1 is violated. G2 is violated. -/
theorem withoutP8b_g1_trace :
    ctrace SelfObserving.withoutP8b (cinit SelfObserving.withoutP8b)
      [some (.mutate (.inl .M1)), some (.stop .M2), some (.stop .M3)] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨F,T,F⟩, ⟨F,F,F⟩, F⟩,
    F, T⟩,
  ⟨⟨⟨⟨T,F,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨F,T,F⟩, ⟨F,F,F⟩, F⟩,
    F, T⟩,
  ⟨⟨⟨⟨T,F,F⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨F,T,F⟩, ⟨F,F,F⟩, F⟩,
    T, T⟩] := by
  decide +kernel

/-- `reference(without=('P8b',))`: G2 is violated in round 1 of this execution.
Round 1: mutate M1. G2 is violated. -/
theorem withoutP8b_g2_trace :
    ctrace SelfObserving.withoutP8b (cinit SelfObserving.withoutP8b)
      [some (.mutate (.inl .M1))] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨F,T,F⟩, ⟨F,F,F⟩, F⟩,
    F, T⟩] := by
  decide +kernel

/-- `reference(without=('gate',))`: G1 is violated in round 3 of this execution.
Round 1: mutate M1. G2 is violated.
Round 2: mutate M3. G2 is violated.
Round 3: stop M2. G1 is violated. G2 is violated. -/
theorem withoutGate_g1_trace :
    ctrace SelfObserving.withoutGate (cinit SelfObserving.withoutGate)
      [some (.mutate (.inl .M1)), some (.mutate (.inl .M3)), some (.stop .M2)] = some [
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,F⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨F,F,F⟩, ⟨F,F,F⟩, F⟩,
    F, T⟩,
  ⟨⟨⟨⟨T,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,T⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨F,T,F⟩, ⟨F,F,F⟩, F⟩,
    F, T⟩,
  ⟨⟨⟨⟨T,F,T⟩,⟨T,T,F⟩⟩, ⟨⟨T,F,T⟩,⟨F,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨F,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨F,T,F⟩, ⟨F,F,F⟩, F⟩,
    T, T⟩] := by
  decide +kernel

/-- `reference(without=('gate',))`: G2 is violated in round 1 of this execution.
Round 1: fail-substrate s1. G2 is violated. -/
theorem withoutGate_g2_trace :
    ctrace SelfObserving.withoutGate (cinit SelfObserving.withoutGate)
      [some (.failSubstrate .s1)] = some [
  ⟨⟨⟨⟨F,T,T⟩,⟨T,T,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨⟨F,F,F⟩,⟨T,F,F⟩⟩, ⟨F,F,F⟩, ⟨F,T,T⟩, ⟨T,F,F⟩, ⟨F,F,F⟩, F⟩,
    F, T⟩] := by
  decide +kernel

end Py
end SelfObserving
