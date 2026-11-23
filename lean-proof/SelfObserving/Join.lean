/-
The model with monitors that join, transcribed from `model-spec-join.md` (sections J1 to
J6), which extends `model-spec.md`. It is a model of its own, beside the one in
`Model.lean` and not in place of it: nothing in `Model.lean` is changed, and the phases of
a round are those of `Model.lean`, run on the edges that are in force.

Everything in this file is a definition. Section numbers in the comments are those of
`model-spec-join.md`.
-/
import SelfObserving.Model

namespace SelfObserving

/-- Section J1. A system with the three new fields. `G` is the type of groups.

`base` holds the fields of `model-spec.md`. The late processes are given by the group each
is a member of, so no process is a member of two groups: `group m` for a monitor, and
`joinerGroup` for the joiner. A monitor with a group is a *late monitor*; a monitor with
none is an *initial monitor*. `joinerGroup` matters to the model only when the system has
a joiner.

The slow edges are given by relation, one predicate for each of the four relations. The
specification requires every slow edge to be an edge of the system, and every group to
have a member. This type enforces neither: a slow edge that is not an edge has no effect,
and a group with no member can join and brings nothing. -/
structure JSystem (M W B S G : Type) where
  /-- the fields of `model-spec.md` -/
  base : System M W B S
  /-- the group a monitor is a member of, if it is a late monitor -/
  group : M → Option G
  /-- the group the joiner is a member of, if any -/
  joinerGroup : Option G
  /-- `after g p`: the group `g` may join only when the process `p` is present -/
  after : G → Proc M W → Prop
  /-- whether a late monitor may arrive already bad -/
  arriveBad : Bool
  /-- `slowHb p m`: the edge "`m` reads `p`'s signal" is a slow edge -/
  slowHb : M → M → Prop
  /-- `slowCheck x m`: the edge "`m` checks `x`'s state" is a slow edge -/
  slowCheck : Proc M W → M → Prop
  /-- `slowFwd m r`: the edge "`m` reports to `r`" is a slow edge -/
  slowFwd : M → M → Prop
  /-- `slowHalt w m`: the edge "`w` takes its halt from `m`" is a slow edge -/
  slowHalt : W → M → Prop

/-- Section J3. A state: the components of `model-spec.md`, and the set of groups that
have joined. -/
structure JState (M W G : Type) where
  /-- the components of `model-spec.md`, section 2 -/
  st : State M W
  /-- the groups that have joined -/
  arrived : G → Prop

variable {M W B S G : Type}

/-- A late monitor: a monitor that is a member of a group. -/
def JSystem.Late (sys : JSystem M W B S G) (m : M) : Prop := sys.group m ≠ none

/-- Section J1. The members of the group `g`: the monitors whose group it is, and the
joiner if its group is `g`. -/
def JMember (sys : JSystem M W B S G) (g : G) : Proc M W → Prop
  | .inl m => sys.group m = some g
  | .inr w => sys.base.IsJoiner w ∧ sys.joinerGroup = some g

/-- Section J2. The present processes: the initial monitors; a late monitor once its group
has joined; the work processes; and the joiner once it has joined, by its own step or by a
group's. -/
def JPresent (sys : JSystem M W B S G) (s : JState M W G) : Proc M W → Prop
  | .inl m => ∀ g, sys.group m = some g → s.arrived g
  | .inr w => sys.base.IsJoiner w → s.st.joined

/-- Section J3. The initial state: the initial monitors and the work processes are alive,
no late monitor is, the joiner is not, no group has joined, and every other component is
empty. -/
def jinit (sys : JSystem M W B S G) : JState M W G where
  st :=
    { alive := fun p =>
        match p with
        | .inl m => sys.group m = none
        | .inr w => ¬ sys.base.IsJoiner w
      bad := fun _ => False
      hidden := fun _ => False
      off := fun _ => False
      flagged := fun _ => False
      halted := fun _ => False
      pending := fun _ => False
      joined := False }
  arrived := fun _ => False

/-! ### Section J4. Environment phase -/

/-- The environment's steps: those of `model-spec.md`, and the two that join a group. -/
inductive JStep (M W B S G : Type) where
  | stop (m : M)
  | stopBoundary (b : B)
  | failSubstrate (c : S)
  | mutate (p : Proc M W)
  | disable (m : M)
  | join
  | joinGroup (g : G)
  | joinBad (g : G) (m : M)

/-- `join g` is enabled: `g` has not joined, and every process in its `after` is
present. -/
def JoinEnabled (sys : JSystem M W B S G) (s : JState M W G) (g : G) : Prop :=
  ¬ s.arrived g ∧ ∀ p, sys.after g p → JPresent sys s p

/-- The column "Enabled when" of the table in section J4. -/
def JEnabled (sys : JSystem M W B S G) (s : JState M W G) : JStep M W B S G → Prop
  | .stop m => JPresent sys s (.inl m) ∧ s.st.alive (.inl m)
  | .stopBoundary b =>
      (∃ m m', m ≠ m' ∧ sys.base.boundary m = some b ∧ sys.base.boundary m' = some b ∧
        JPresent sys s (.inl m) ∧ JPresent sys s (.inl m')) ∧
      (∃ m, sys.base.boundary m = some b ∧ JPresent sys s (.inl m) ∧ s.st.alive (.inl m))
  | .failSubstrate c =>
      ∃ p, JPresent sys s p ∧ sys.base.substrate p = some c ∧
        match p with
        | .inl m => s.st.alive (.inl m)
        | .inr w => ¬ s.st.bad (.inr w)
  | .mutate p => JPresent sys s p ∧ ¬ s.st.bad p
  | .disable m => JPresent sys s (.inl m) ∧ sys.base.switches m ∧ ¬ s.st.off m
  | .join => sys.base.joiner ≠ none ∧ sys.joinerGroup = none ∧ ¬ s.st.joined
  | .joinGroup g => JoinEnabled sys s g
  | .joinBad g m => sys.arriveBad = true ∧ JoinEnabled sys s g ∧ sys.group m = some g

/-- The processes that `fail-substrate c` makes bad and hidden: every present non-monitor
process with substrate `c`. -/
def JStruck (sys : JSystem M W B S G) (s : JState M W G) (c : S) (p : Proc M W) : Prop :=
  ∃ w, p = .inr w ∧ JPresent sys s p ∧ sys.base.substrate p = some c

/-- The effect of `join g`: `g` is added to `arrived`, every member of `g` to `alive`, and
`joined` is set if the joiner is a member. -/
def joinEffect (sys : JSystem M W B S G) (s : JState M W G) (g : G) : JState M W G where
  st :=
    { s.st with
      alive := fun p => s.st.alive p ∨ JMember sys g p
      joined := s.st.joined ∨ ∃ w, JMember sys g (.inr w) }
  arrived := fun h => h = g ∨ s.arrived h

/-- The column "Effect" of the table in section J4. -/
def jeffect (sys : JSystem M W B S G) (s : JState M W G) : JStep M W B S G → JState M W G
  | .stop m => { s with st := { s.st with alive := fun p => s.st.alive p ∧ p ≠ .inl m } }
  | .stopBoundary b =>
      { s with st := { s.st with
          alive := fun p => s.st.alive p ∧
            ∀ m, p = .inl m → ¬ (sys.base.boundary m = some b ∧ JPresent sys s (.inl m)) } }
  | .failSubstrate c =>
      { s with st := { s.st with
          alive := fun p => s.st.alive p ∧
            ∀ m, p = .inl m → ¬ (sys.base.substrate p = some c ∧ JPresent sys s p)
          bad := fun p => s.st.bad p ∨ JStruck sys s c p
          hidden := fun p => s.st.hidden p ∨ JStruck sys s c p } }
  | .mutate p => { s with st := { s.st with bad := fun q => q = p ∨ s.st.bad q } }
  | .disable m => { s with st := { s.st with off := fun r => r = m ∨ s.st.off r } }
  | .join =>
      { s with st := { s.st with
          joined := True
          alive := fun p => s.st.alive p ∨ ∃ w, p = .inr w ∧ sys.base.IsJoiner w } }
  | .joinGroup g => joinEffect sys s g
  | .joinBad g m =>
      let s' := joinEffect sys s g
      { s' with st := { s'.st with bad := fun q => q = .inl m ∨ s'.st.bad q } }

/-- A sequence of environment steps, each enabled in the state reached by the steps
before it. -/
inductive JEnvRun (sys : JSystem M W B S G) :
    JState M W G → List (JStep M W B S G) → JState M W G → Prop where
  | nil (s : JState M W G) : JEnvRun sys s [] s
  | cons {s s' : JState M W G} {e : JStep M W B S G} {es : List (JStep M W B S G)} :
      JEnabled sys s e → JEnvRun sys (jeffect sys s e) es s' → JEnvRun sys s (e :: es) s'

/-! ### Section J5. Edges in force -/

/-- `new` for a round that starts in `s` and whose environment phase ends in `s₁`: the
processes that became present in that environment phase. The specification lists them as
the members of every group whose step was taken in the phase, and the joiner if its step
was; those are the processes present after the phase and not before it. -/
def JNew (sys : JSystem M W B S G) (s s₁ : JState M W G) (p : Proc M W) : Prop :=
  JPresent sys s₁ p ∧ ¬ JPresent sys s p

/-- An edge with ends `p` and `q` is in force in the round: both ends are present after
the round's environment phase, and it is not a slow edge or neither end is in `new`.
`slow` says whether the edge is listed as slow. -/
def InForce (sys : JSystem M W B S G) (s s₁ : JState M W G) (p q : Proc M W)
    (slow : Prop) : Prop :=
  JPresent sys s₁ p ∧ JPresent sys s₁ q ∧
    (slow → ¬ JNew sys s s₁ p ∧ ¬ JNew sys s s₁ q)

/-- The system of `model-spec.md` whose edges are exactly the edges in force in the round
that starts in `s` and whose environment phase ends in `s₁`. Every other field is that of
`base`. -/
def effective (sys : JSystem M W B S G) (s s₁ : JState M W G) : System M W B S :=
  { sys.base with
    hbReaders := fun p m =>
      sys.base.hbReaders p m ∧ InForce sys s s₁ (.inl p) (.inl m) (sys.slowHb p m)
    checkers := fun x m =>
      sys.base.checkers x m ∧ InForce sys s s₁ x (.inl m) (sys.slowCheck x m)
    fwd := fun m r =>
      sys.base.fwd m r ∧ InForce sys s s₁ (.inl m) (.inl r) (sys.slowFwd m r)
    haltInputs := fun w m =>
      sys.base.haltInputs w m ∧ InForce sys s s₁ (.inr w) (.inl m) (sys.slowHalt w m) }

/-! ### Section J6. One round, executions and the result -/

/-- What a round produces: the next state, and whether each goal was violated in it. -/
structure JOutcome (M W G : Type) where
  next : JState M W G
  /-- G1 is violated in the round -/
  g1 : Prop
  /-- G2 is violated in the round -/
  g2 : Prop

/-- The monitor and work phases of the round that starts in `s`, from the state `s₁`
reached by its environment phase: those of `Model.lean` (`afterEnv`), in either order of
the phases, on the edges in force. They do not change which groups have joined. -/
def jafterEnv (sys : JSystem M W B S G) (s s₁ : JState M W G) : JOutcome M W G :=
  { next := { st := (afterEnv (effective sys s s₁) s₁.st).next, arrived := s₁.arrived }
    g1 := (afterEnv (effective sys s s₁) s₁.st).g1
    g2 := (afterEnv (effective sys s s₁) s₁.st).g2 }

/-- One round from `s`: at most `f` environment steps, the two joining steps counted like
any other, then the other two phases. -/
def JRound (sys : JSystem M W B S G) (s : JState M W G) (r : JOutcome M W G) : Prop :=
  ∃ (steps : List (JStep M W B S G)) (s₁ : JState M W G),
    steps.length ≤ sys.base.f ∧ JEnvRun sys s steps s₁ ∧ r = jafterEnv sys s s₁

/-- A responded state, as in `model-spec.md`, section 3.5: some monitor is flagged, alive
and not bad, and every present non-monitor process is halted. -/
def JResponded (sys : JSystem M W B S G) (s : JState M W G) : Prop :=
  Responded sys.base s.st

/-- The states reached by executions: sequences of rounds from the initial state in which
no round starts from a responded state. -/
inductive JReachable (sys : JSystem M W B S G) : JState M W G → Prop where
  | init : JReachable sys (jinit sys)
  | round {s : JState M W G} {r : JOutcome M W G} :
      JReachable sys s → ¬ JResponded sys s → JRound sys s r → JReachable sys r.next

/-- No gap: no execution of any length violates G1 or G2 in any of its rounds. -/
def JNoGap (sys : JSystem M W B S G) : Prop :=
  ∀ (s : JState M W G) (r : JOutcome M W G),
    JReachable sys s → ¬ JResponded sys s → JRound sys s r → ¬ r.g1 ∧ ¬ r.g2

/-- Some execution violates G1 in one of its rounds. -/
def JViolatesG1 (sys : JSystem M W B S G) : Prop :=
  ∃ (s : JState M W G) (r : JOutcome M W G),
    JReachable sys s ∧ ¬ JResponded sys s ∧ JRound sys s r ∧ r.g1

/-- Some execution violates G2 in one of its rounds. -/
def JViolatesG2 (sys : JSystem M W B S G) : Prop :=
  ∃ (s : JState M W G) (r : JOutcome M W G),
    JReachable sys s ∧ ¬ JResponded sys s ∧ JRound sys s r ∧ r.g2

/-! ### A system with none of the new fields -/

/-- A system of `model-spec.md` as a system of this model with none of the three new
fields: no group, no monitor arriving bad, no slow edge. -/
def plainJoin (sys : System M W B S) : JSystem M W B S Empty where
  base := sys
  group := fun _ => none
  joinerGroup := none
  after := fun _ _ => False
  arriveBad := false
  slowHb := fun _ _ => False
  slowCheck := fun _ _ => False
  slowFwd := fun _ _ => False
  slowHalt := fun _ _ => False

end SelfObserving
