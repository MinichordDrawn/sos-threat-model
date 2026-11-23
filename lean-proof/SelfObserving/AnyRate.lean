/-
Conditions on the wiring of a plain system for no gap at any number of faults per round,
transcribed from `results-join.md`, section 3: Theorem J and Theorem F, for systems with
nothing joining. Everything in this file is a definition.

`results.md`, section 11, lists such a condition as missing: Theorem S is for one fault per
round. In the conditions below `f` is the number of faults per round the condition is for;
the three theorems in `Challenge.lean` take it to be the system's own `f`.
-/
import SelfObserving.Wide

namespace SelfObserving

variable {M W B S : Type}

/-- `Paired sys a b`: the monitors `a` and `b` watch each other and report to each other.
Each checks the other's state, reads the other's signal, and reports its flag to the
other. -/
def Paired (sys : System M W B S) (a b : M) : Prop :=
  Watches sys a b ∧ Watches sys b a ∧ sys.fwd a b ∧ sys.fwd b a

/-- `Linked sys a b`: `b` is reached from `a` through pairs that watch each other and
report to each other. Every monitor is linked to itself. -/
inductive Linked (sys : System M W B S) : M → M → Prop where
  | refl (a : M) : Linked sys a a
  | step {a b c : M} : Linked sys a b → Paired sys b c → Linked sys a c

/-- The conditions of Theorem J, for a system with nothing joining, at `f` faults per
round.

- `linked`: the monitors are connected by pairs that watch each other and report to each
  other.
- `work`: every work process has a state checker, and more than `f` halt inputs: `hs` is
  a list of different monitors, more than `f` of them, each a halt input of `w`.
- `monitors`: there are more than `f` monitors: `ms` is a list of different monitors, more
  than `f` of them.

In `work`, `w` ranges over every non-monitor process, the joiner included; a plain system
has none. -/
structure SufficientJ (sys : System M W B S) (f : Nat) : Prop where
  linked : ∀ a b, Linked sys a b
  work : ∀ w, (∃ k, sys.checkers (.inr w) k) ∧
      ∃ hs : List M, hs.Nodup ∧ f < hs.length ∧ ∀ h, h ∈ hs → sys.haltInputs w h
  monitors : ∃ ms : List M, ms.Nodup ∧ f < ms.length

/-- `LeansOn sys a b`: `a` watches `b`, and `b` reports to `a`. This is one half of
`Paired`: `Paired sys a b` holds exactly when `LeansOn sys a b` and `LeansOn sys b a`
both do. -/
def LeansOn (sys : System M W B S) (a b : M) : Prop :=
  Watches sys a b ∧ sys.fwd b a

/-- `LeansThrough sys a b`: `b` is reached from `a` by steps of `LeansOn`, each from a
monitor to one it watches and hears from. Every monitor reaches itself. -/
inductive LeansThrough (sys : System M W B S) : M → M → Prop where
  | refl (a : M) : LeansThrough sys a a
  | step {a b c : M} : LeansThrough sys a b → LeansOn sys b c → LeansThrough sys a c

/-- The conditions of Theorem J with its first condition weakened to one direction. This
form is not in `results-join.md`. It asks only for what the proof of Theorem J there uses
of a pair: that the one monitor watches the other and the other reports to it.

- `leans`: from every monitor, every monitor is reached by steps that each go from a
  monitor to one it watches and hears from.
- `work` and `monitors`: as in `SufficientJ`. -/
structure SufficientOneWay (sys : System M W B S) (f : Nat) : Prop where
  leans : ∀ a b, LeansThrough sys a b
  work : ∀ w, (∃ k, sys.checkers (.inr w) k) ∧
      ∃ hs : List M, hs.Nodup ∧ f < hs.length ∧ ∀ h, h ∈ hs → sys.haltInputs w h
  monitors : ∃ ms : List M, ms.Nodup ∧ f < ms.length

/-- The conditions of Theorem F, at `f` faults per round.

- `checked`: every monitor has at least `f` state checkers other than itself: `cs` is a
  list of different monitors, at least `f` of them, each other than `z` and checking `z`'s
  state.
- `read`: every monitor has at least `f` signal readers other than itself, in the same
  form.
- `work`: every work process has a state checker.
- `halt`: for every monitor `d`, every work process `w` and every set `zs` of at most `f`
  monitors that does not contain `d`, some halt input of `w` outside the set is reached
  from `d` along report edges that avoid the set. `ReachOutside` (`Wide.lean`) counts `d`
  as reached from itself, so the clause holds at once when `w` takes its halt from `d`. A
  set is given as a list, which may repeat a monitor.

In `work` and `halt`, `w` ranges over every non-monitor process, the joiner included; a
plain system has none. -/
structure SufficientF (sys : System M W B S) (f : Nat) : Prop where
  checked : ∀ z, ∃ cs : List M, cs.Nodup ∧ f ≤ cs.length ∧
      ∀ c, c ∈ cs → c ≠ z ∧ sys.checkers (.inl z) c
  read : ∀ z, ∃ rs : List M, rs.Nodup ∧ f ≤ rs.length ∧
      ∀ r, r ∈ rs → r ≠ z ∧ sys.hbReaders z r
  work : ∀ w, ∃ k, sys.checkers (.inr w) k
  halt : ∀ (d : M) (w : W) (zs : List M), zs.length ≤ f → d ∉ zs →
      ∃ h, sys.haltInputs w h ∧ ReachOutside sys (fun m => m ∈ zs) d h

end SelfObserving
