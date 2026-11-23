/-
The full mesh at any fault rate. `Systems.lean` defines the full mesh at one fault per
round; `results.md`, section 10.2, speaks of a mesh of `n` monitors at `f` faults per
round, and the checker's `mesh(n, f)` takes `f` as an argument. Everything in this file is
a definition.
-/
import SelfObserving.Systems

namespace SelfObserving

/-- The full mesh of `Systems.lean` with `f` faults per round in place of one. Nothing
else is changed: every monitor reads the signal of, checks the state of, and reports to
every other monitor; every work process is checked by every monitor and takes its halt
from every monitor; each monitor is its own boundary. -/
def meshAt (M W : Type) (f : Nat) : System M W M Unit :=
  { mesh M W with f := f }

end SelfObserving
