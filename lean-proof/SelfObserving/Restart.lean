/-
The restart game, transcribed from `results.md`, section 10.3, and from `restart_game` in
`check_model.py`, which is the game as the model check runs it. It is a separate small
model: it has only running and stopped, and is not joined to the round model of
`Model.lean`. Everything in this file is a definition. Nothing is imported.

A set is written as a predicate, as in `Model.lean`.
-/

namespace SelfObserving

/-- A ring of members that observe each other. -/
structure Ring (X : Type) where
  /-- `observes o x`: the member `o` observes the member `x`. In the checker, `o` is in
  `observers[x]`. -/
  observes : X → X → Prop
  /-- `startsFirst x`: `x` can start first. The rule does not bind it: it may start, and
  stay running, while no member that observes it is running. In the checker, `x` is in
  `self_starting`. -/
  startsFirst : X → Prop

/-- A state of the game. -/
structure RingState (X : Type) where
  /-- the members that are running; the others are stopped -/
  running : X → Prop
  /-- the members the environment has stopped and not yet released -/
  blocked : X → Prop

variable {X : Type}

/-- The game starts with every member running and none blocked. -/
def ringInit : RingState X where
  running := fun _ => True
  blocked := fun _ => False

/-- The rule, repeated until nothing changes. `Falls g R x`: with the members `R` running,
the rule stops `x`, if `x` is one of them (`settle` below keeps only members of `R`). A
member that cannot start first falls when every member of `R` that observes it has fallen;
in particular when no member of `R` observes it. This is the loop of `settle` in the
checker. -/
inductive Falls (g : Ring X) (R : X → Prop) : X → Prop where
  | intro {x : X} : ¬ g.startsFirst x → (∀ o, g.observes o x → R o → Falls g R o) →
      Falls g R x

/-- What is left of `R` once the rule has stopped everything it stops. -/
def settle (g : Ring X) (R : X → Prop) : X → Prop := fun x => R x ∧ ¬ Falls g R x

/-- The moves of the game. The environment stops a member and later releases it. A member
starts. -/
inductive RingMove (X : Type) where
  | stop (m : X)
  | release (m : X)
  | start (m : X)

/-- When a move may be made.

- `stop m`: `m` is running.
- `release m`: `m` is not running and is blocked.
- `start m`: `m` is not running and not blocked, and it can start first or a member that
  observes it is running. -/
def RingMove.Enabled (g : Ring X) (s : RingState X) : RingMove X → Prop
  | .stop m => s.running m
  | .release m => ¬ s.running m ∧ s.blocked m
  | .start m =>
      ¬ s.running m ∧ ¬ s.blocked m ∧ (g.startsFirst m ∨ ∃ o, g.observes o m ∧ s.running o)

/-- What a move does.

- `stop m`: `m` leaves the running members, the rule is applied, and `m` is blocked.
- `release m`: `m` is no longer blocked.
- `start m`: `m` joins the running members, and the rule is applied. -/
def ringEffect (g : Ring X) (s : RingState X) : RingMove X → RingState X
  | .stop m =>
      { running := settle g (fun x => s.running x ∧ x ≠ m)
        blocked := fun x => s.blocked x ∨ x = m }
  | .release m => { s with blocked := fun x => s.blocked x ∧ x ≠ m }
  | .start m => { s with running := settle g (fun x => s.running x ∨ x = m) }

/-- A sequence of moves, each enabled in the state reached by the moves before it.
`RingRun g s moves s'`: making `moves` from `s` reaches `s'`. -/
inductive RingRun (g : Ring X) : RingState X → List (RingMove X) → RingState X → Prop where
  | nil (s : RingState X) : RingRun g s [] s
  | cons {s s' : RingState X} {mv : RingMove X} {mvs : List (RingMove X)} :
      mv.Enabled g s → RingRun g (ringEffect g s mv) mvs s' → RingRun g s (mv :: mvs) s'

/-- The move is a stop. -/
def RingMove.IsStop : RingMove X → Prop
  | .stop _ => True
  | .release _ => False
  | .start _ => False

/-- From `s`, with no further stop, the members can start one after another until all are
running: some sequence of moves, none of them a stop, leads from `s` to a state in which
every member is running. The moves may be starts and releases. -/
def Recovers (g : Ring X) (s : RingState X) : Prop :=
  ∃ (moves : List (RingMove X)) (s' : RingState X),
    (∀ mv, mv ∈ moves → ¬ mv.IsStop) ∧ RingRun g s moves s' ∧ ∀ x, s'.running x

/-- The ring can always restart: from every state the game can reach in which no member is
blocked (the environment has released every member it stopped), the ring recovers. -/
def CanAlwaysRestart (g : Ring X) : Prop :=
  ∀ (moves : List (RingMove X)) (s : RingState X),
    RingRun g ringInit moves s → (∀ x, ¬ s.blocked x) → Recovers g s

/-- `Reaches g k y`: a chain of observation leads from `k` to `y`. `k` observes a member,
which observes another, and so on to `y`. The chain has at least one link. -/
inductive Reaches (g : Ring X) : X → X → Prop where
  | base {k y : X} : g.observes k y → Reaches g k y
  | step {k y y' : X} : Reaches g k y → g.observes y y' → Reaches g k y'

/-! ### The four rings of the table in section 10.3 -/

/-- Three members. -/
inductive Three where
  | X1
  | X2
  | X3
  deriving DecidableEq

/-- Three members and a coordinator. -/
inductive Four where
  | X1
  | X2
  | X3
  | K
  deriving DecidableEq

/-- Three members, each observed by the one before it: X1 by X3, X2 by X1, X3 by X2. None
can start first. The checker's `ring3`. -/
def ring3 : Ring Three where
  observes := fun o x =>
    match x with
    | .X1 => o = .X3
    | .X2 => o = .X1
    | .X3 => o = .X2
  startsFirst := fun _ => False

/-- Three members, each observed by the other two. None can start first. The checker's
`mesh3`. -/
def mesh3 : Ring Three where
  observes := fun o x => o ≠ x
  startsFirst := fun _ => False

/-- The ring of three and a coordinator K. K observes all three, and all three observe K.
With `first`, K can start first. The checker's `with_k`. -/
def ringK (first : Bool) : Ring Four where
  observes := fun o x =>
    match x with
    | .X1 => o = .X3 ∨ o = .K
    | .X2 => o = .X1 ∨ o = .K
    | .X3 => o = .X2 ∨ o = .K
    | .K => o = .X1 ∨ o = .X2 ∨ o = .X3
  startsFirst := fun x => first = true ∧ x = .K

end SelfObserving
