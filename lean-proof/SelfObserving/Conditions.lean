/-
The class of systems and the four conditions of Theorem S, transcribed from `results.md`,
section 10.1. Everything in this file is a definition.
-/
import SelfObserving.Model

namespace SelfObserving

variable {M W B S : Type}

/-- A plain system: no joiner, substrates or switches; no two monitors share a boundary;
work halts on silence; there is no window; the gate is in place; reports arrive within
the round. -/
structure Plain (sys : System M W B S) : Prop where
  no_joiner : sys.joiner = none
  no_substrate : ∀ p, sys.substrate p = none
  no_switch : ∀ m, ¬ sys.switches m
  boundaries_distinct : ∀ m m' b, m ≠ m' → ¬ (sys.boundary m = some b ∧ sys.boundary m' = some b)
  coupling_on : sys.coupling = true
  no_window : sys.window = 0
  gate_on : sys.gate = true
  reports_fast : sys.slowReports = false

/-- `Watches sys r z`: the monitor `r` watches the monitor `z`. It both checks `z`'s state
and reads `z`'s signal. -/
def Watches (sys : System M W B S) (r z : M) : Prop :=
  sys.checkers (.inl z) r ∧ sys.hbReaders z r

/-- `Reach sys x y`: `y` is reached from `x` along report edges. Every monitor reaches
itself. -/
inductive Reach (sys : System M W B S) : M → M → Prop where
  | refl (x : M) : Reach sys x x
  | step {x y y' : M} : Reach sys x y → sys.fwd y y' → Reach sys x y'

/-- `ReachAvoiding sys z x y`: `y` is reached from `x` along report edges, and no monitor
on the way, `x` and `y` included, is `z`. -/
inductive ReachAvoiding (sys : System M W B S) (z : M) : M → M → Prop where
  | refl {x : M} : x ≠ z → ReachAvoiding sys z x x
  | step {x y y' : M} : ReachAvoiding sys z x y → sys.fwd y y' → y' ≠ z →
      ReachAvoiding sys z x y'

/-- The four conditions of Theorem S.

(a) Every monitor is watched by some other monitor.
(b) Every work process has a state checker and at least two different halt inputs.
(c) For every monitor `z`, every other monitor either watches `z` or is reached from a
    watcher of `z` along report edges that do not pass through `z`. A watcher reaches
    itself, so one clause covers both.
(d) Every work process has a state checker from which every monitor is reached along
    report edges.

In (b) and (d), `w` ranges over every non-monitor process, the joiner included; a plain
system has none. -/
structure Sufficient (sys : System M W B S) : Prop where
  a : ∀ z, ∃ r, r ≠ z ∧ Watches sys r z
  b : ∀ w, (∃ m, sys.checkers (.inr w) m) ∧
        ∃ h₁ h₂, h₁ ≠ h₂ ∧ sys.haltInputs w h₁ ∧ sys.haltInputs w h₂
  c : ∀ z y, y ≠ z → ∃ r, r ≠ z ∧ Watches sys r z ∧ ReachAvoiding sys z r y
  d : ∀ w, ∃ k, sys.checkers (.inr w) k ∧ ∀ m, Reach sys k m

end SelfObserving
