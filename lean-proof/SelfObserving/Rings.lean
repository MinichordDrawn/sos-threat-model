/-
The ring of `k` members in a cycle under one coordinator, the two readings of a
connection, and the two requirements R2 and R5, transcribed from `part-a.md`, sections
1.1 to 1.3, and `results-minimal.md`, sections 1 and 3. Everything in this file is a
definition.

A connection `X -> Y` is a directed pair of monitors. What it carries depends on the
reading (`part-a.md`, section 1.2):

    flow    Y reads X's signal, Y checks X's state, X reports to Y
    actor   X reads Y's signal, X checks Y's state, X reports to Y

The work is wired as `part-a.md`, section 1.1, calls "W reads all": one work process,
checked by every monitor and taking its halt from every monitor.
-/
import SelfObserving.Conditions

namespace SelfObserving

/-- The two readings of a connection that `part-a.md`, section 1.2, works through in
full. -/
inductive Reading where
  /-- `X -> Y`: `Y` watches `X`, and `X` reports to `Y` -/
  | flow
  /-- `X -> Y`: `X` watches `Y`, and `X` reports to `Y` -/
  | actor
  deriving DecidableEq

variable {M : Type}

/-- `rd.watches conn r z`: under the reading `rd`, the connections `conn` make `r` read
the signal of `z` and check the state of `z`. Under flow that is the connection
`z -> r`; under actor it is the connection `r -> z`. Here `conn x y` says that the
connection `x -> y` is there. -/
def Reading.watches (rd : Reading) (conn : M → M → Prop) (r z : M) : Prop :=
  match rd with
  | .flow => conn z r
  | .actor => conn r z

/-- The system that a set of connections stands for under a reading, with the work
reading all, at `f` faults per round.

`r` reads the signal of `p`, and checks the state of `p`, exactly when the reading makes
`r` watch `p`. `m` reports to `r` exactly when the connection `m -> r` is there, under
either reading. There is one work process, checked by every monitor and taking its halt
from every monitor. Each monitor is in a boundary of its own. There are no substrates, no
joiner and no switches; work halts on silence; there is no window; the gate is in place;
reports arrive within the round. -/
def wired (rd : Reading) (conn : M → M → Prop) (f : Nat) : System M Unit M Unit where
  f := f
  joiner := none
  boundary := fun m => some m
  substrate := fun _ => none
  hbReaders := fun p r => rd.watches conn r p
  checkers := fun x r =>
    match x with
    | .inl p => rd.watches conn r p
    | .inr _ => True
  fwd := fun m r => conn m r
  haltInputs := fun _ _ => True
  switches := fun _ => False
  coupling := true
  window := 0
  gate := true
  slowReports := false

/-- The same for a set of connections given as a list of pairs: `(x, y)` in the list is
the connection `x -> y`. -/
def wiredList (rd : Reading) (l : List (M × M)) (f : Nat) : System M Unit M Unit :=
  wired rd (fun x y => (x, y) ∈ l) f

/-! ### The ring -/

/-- The monitors of the ring with `k` members: the members, numbered from 0, and the
coordinator. With `k` = 3 the members 0, 1, 2 are A, B, C of `part-a.md` and the
coordinator is D. -/
inductive RingMon (k : Nat) where
  | member (i : Fin k)
  | coord
  deriving DecidableEq

/-- The connections of the ring with `k` members (`results-minimal.md`, section 3): the
members in a cycle, each member connected to the next and the last to the first; the
coordinator connected to every member; every member connected to the coordinator. There
are `3 * k` of them when `k` is 2 or more. With `k` = 3 they are the nine of the
candidate: `A -> B -> C -> A`, `D -> A, B, C` and `A, B, C -> D`.

No monitor is connected to itself: with `k` = 1 the cycle has no connection. With `k` = 2
the cycle is the two members connected both ways. -/
def ringConn (k : Nat) : RingMon k → RingMon k → Prop
  | .member i, .member j => i ≠ j ∧ j.val = (i.val + 1) % k
  | .coord, .member _ => True
  | .member _, .coord => True
  | .coord, .coord => False

/-- The ring of `k` members in a cycle and a coordinator connected to each both ways,
under the reading `rd`, with the work reading every monitor, at `f` faults per round.
`ring rd 3 f` is the candidate ring of `part-a.md`. -/
def ring (rd : Reading) (k f : Nat) : System (RingMon k) Unit (RingMon k) Unit :=
  wired rd (ringConn k) f

/-! ### The two requirements -/

variable {W B S : Type}

/-- R2 of `part-a.md`, section 1.3: every monitor has at least two other monitors that
both read its signal and check its state. -/
def R2 (sys : System M W B S) : Prop :=
  ∀ z, ∃ a b, a ≠ b ∧ a ≠ z ∧ b ≠ z ∧ Watches sys a z ∧ Watches sys b z

/-- R5 of `part-a.md`, section 1.3, with `d` the coordinator: every other monitor has a
report edge to `d`. -/
def R5 (sys : System M W B S) (d : M) : Prop :=
  ∀ m, m ≠ d → sys.fwd m d

/-! ### The candidate and one smaller wiring, as lists -/

/-- The nine connections of the candidate, in the order `A -> B -> C -> A`,
`D -> A, B, C`, `A, B, C -> D`. -/
def candidateArrows : List (RingMon 3 × RingMon 3) :=
  [(.member 0, .member 1), (.member 1, .member 2), (.member 2, .member 0),
   (.coord, .member 0), (.coord, .member 1), (.coord, .member 2),
   (.member 0, .coord), (.member 1, .coord), (.member 2, .coord)]

/-- Eight connections: the candidate without `D -> C`. It is shape 4 of `part-a.md`,
section 2.3, under flow. -/
def eightArrows : List (RingMon 3 × RingMon 3) :=
  [(.member 0, .member 1), (.member 1, .member 2), (.member 2, .member 0),
   (.coord, .member 0), (.coord, .member 1),
   (.member 0, .coord), (.member 1, .coord), (.member 2, .coord)]

end SelfObserving
