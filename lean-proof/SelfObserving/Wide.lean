/-
A class of systems wider than the plain ones of `Conditions.lean`, and conditions on the
wiring for it. A system of this class may have a joiner, substrates, and monitors that
share a boundary. Everything in this file is a definition.

`results.md` states Theorem S (section 10.1) for plain systems only, and gives no general
theorem of no gap for systems that are not plain. The class and the two further conditions
below are therefore not transcribed from a passage of `results.md`. They are written from
the steps of `model-spec.md`, section 3.1, that a plain system excludes and this class
admits (`join`, `fail-substrate`, `stop-boundary`), and from the reference system of
`results.md`, section 5.
-/
import SelfObserving.Conditions

namespace SelfObserving

variable {M W B S : Type}

/-- The wider class. What is kept of `Plain`: no monitor has an off switch; work halts on
silence; there is no window; the gate is in place; reports arrive within the round. What
is dropped: the system may have a joiner and substrates, and monitors may share a
boundary. -/
structure Ordinary (sys : System M W B S) : Prop where
  no_switch : ∀ m, ¬ sys.switches m
  coupling_on : sys.coupling = true
  no_window : sys.window = 0
  gate_on : sys.gate = true
  reports_fast : sys.slowReports = false

/-- `ReachOutside sys Z x y`: `y` is reached from `x` along report edges, and no monitor
on the way, `x` and `y` included, is in the set `Z`. -/
inductive ReachOutside (sys : System M W B S) (Z : M → Prop) : M → M → Prop where
  | refl {x : M} : ¬ Z x → ReachOutside sys Z x x
  | step {x y y' : M} : ReachOutside sys Z x y → sys.fwd y y' → ¬ Z y' →
      ReachOutside sys Z x y'

/-- The loss of the whole set `Z` of monitors in one step is answered: some monitor is
outside `Z`, and every monitor outside `Z` either reads the signal of a member of `Z` or
is reached from a monitor outside `Z` that does, along report edges that do not pass
through `Z`. A reader reaches itself, so one clause covers both. -/
def LossAnswered (sys : System M W B S) (Z : M → Prop) : Prop :=
  (∃ y, ¬ Z y) ∧
  ∀ y, ¬ Z y → ∃ r p, ¬ Z r ∧ Z p ∧ sys.hbReaders p r ∧ ReachOutside sys Z r y

/-- The monitors that run on the substrate `c`. -/
def OnSubstrate (sys : System M W B S) (c : S) (m : M) : Prop :=
  sys.substrate (.inl m) = some c

/-- The monitors in the boundary `b`. -/
def InBoundary (sys : System M W B S) (b : B) (m : M) : Prop :=
  sys.boundary m = some b

/-- The conditions for the wider class.

- `single`: the four conditions of Theorem S. In (b) and (d) they range over every
  non-monitor process, the joiner included.
- `substrate`: for every substrate that some process runs on, monitor or not, the loss of
  all the monitors on it is answered. In particular some monitor runs on it.
- `boundary`: for every boundary that two different monitors share, the loss of all the
  monitors in it is answered. -/
structure SufficientWide (sys : System M W B S) : Prop where
  single : Sufficient sys
  substrate : ∀ c p, sys.substrate p = some c → LossAnswered sys (OnSubstrate sys c)
  boundary : ∀ b m m', m ≠ m' → sys.boundary m = some b → sys.boundary m' = some b →
      LossAnswered sys (InBoundary sys b)

end SelfObserving
