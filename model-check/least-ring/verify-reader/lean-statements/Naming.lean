/-
Naming the faulty monitor, as `results.md`, section 10.2, supposes it: at most one monitor
is faulty. Statements 25 and 26 of `Challenge.lean` are for exactly one faulty monitor.
Everything in this file is a definition. Nothing is imported.
-/

namespace SelfObserving

/-- `CanName M`: among the monitors `M`, some rule always names the faulty monitor.

At most one monitor is faulty: `z` is `some` of the faulty monitor, or `none` when no
monitor is faulty. Each monitor gives a name, `some` of a monitor or `none` for nobody.
Each correct monitor names the faulty one exactly: what it gives is `z`. A faulty monitor
may give anything. A rule reads what the monitors give, and is right when it returns
`z`. -/
def CanName (M : Type) : Prop :=
  ∃ rule : (M → Option M) → Option M,
    ∀ (z : Option M) (names : M → Option M),
      (∀ m, some m ≠ z → names m = z) → rule names = z

end SelfObserving
