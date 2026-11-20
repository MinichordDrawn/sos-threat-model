/-
The model, transcribed from `model-spec.md` (sections 1 to 4).

Everything in this file is a definition. Nothing is proved here, and nothing is imported:
the file depends on the Lean core alone. Section numbers in the comments are those of
`model-spec.md`.

A set is written as a predicate. For a state `s`, `s.alive p` says that the process `p` is
in `alive`, and `¬ s.alive p` that it is not.
-/

namespace SelfObserving

/-- A process is a monitor (`Sum.inl m`) or a non-monitor process (`Sum.inr w`).
The non-monitor processes are the work processes and the joiner (section 1). -/
abbrev Proc (M W : Type) := M ⊕ W

/-- Section 1. A system. `M` is the type of monitors, `W` the type of non-monitor
processes, `B` the type of boundary ids and `S` the type of substrate ids.

The typing of the fields follows the specification's table. The field `name` is left out:
the model does not use it. -/
structure System (M W B S : Type) where
  /-- the most environment steps in one round; the specification requires f >= 1, which
  this type does not enforce (every statement in `Challenge.lean` fixes f = 1) -/
  f : Nat
  /-- a work process that is absent at the start and may join -/
  joiner : Option W
  /-- the trust boundary a monitor is in, if any -/
  boundary : M → Option B
  /-- the substrate a process runs on, if any -/
  substrate : Proc M W → Option S
  /-- `hbReaders m r`: `r` reads `m`'s liveness signal -/
  hbReaders : M → M → Prop
  /-- `checkers x m`: `m` compares `x`'s state with a known-good reference -/
  checkers : Proc M W → M → Prop
  /-- `fwd m r`: `m` reports its flag to `r` -/
  fwd : M → M → Prop
  /-- `haltInputs w m`: the flag of `m`, or its silence, halts `w` -/
  haltInputs : W → M → Prop
  /-- `switches m`: `m` has an off switch -/
  switches : M → Prop
  /-- whether a work process halts on the silence of a monitor in its halt inputs -/
  coupling : Bool
  /-- 0 or 1: rounds between a work process seeing a reason to halt and halting -/
  window : Fin 2
  /-- whether the monitors check before the work processes step in each round -/
  gate : Bool
  /-- whether a report takes one round to arrive -/
  slowReports : Bool

/-- Section 2. A state. Each component but `joined` is a set, written as a predicate. -/
structure State (M W : Type) where
  /-- processes that have not been stopped -/
  alive : Proc M W → Prop
  /-- processes whose state differs from the known-good reference -/
  bad : Proc M W → Prop
  /-- the part of `bad` that no state comparison can see -/
  hidden : Proc M W → Prop
  /-- monitors that have been switched off -/
  off : M → Prop
  /-- monitors that have raised a flag -/
  flagged : M → Prop
  /-- non-monitor processes that have halted -/
  halted : W → Prop
  /-- non-monitor processes that will halt in their next work phase -/
  pending : W → Prop
  /-- whether the joiner has joined -/
  joined : Prop

variable {M W B S : Type}

/-- `w` is the joiner. -/
def System.IsJoiner (sys : System M W B S) (w : W) : Prop := sys.joiner = some w

/-- Section 1. The present processes are the monitors, the work processes, and the joiner
once it has joined. -/
def Present (sys : System M W B S) (s : State M W) : Proc M W → Prop
  | .inl _ => True
  | .inr w => sys.IsJoiner w → s.joined

/-- Section 2. The initial state: all monitors and all work processes are alive, and
every other component is empty. -/
def init (sys : System M W B S) : State M W where
  alive := fun p =>
    match p with
    | .inl _ => True
    | .inr w => ¬ sys.IsJoiner w
  bad := fun _ => False
  hidden := fun _ => False
  off := fun _ => False
  flagged := fun _ => False
  halted := fun _ => False
  pending := fun _ => False
  joined := False

/-! ### Section 3.1. Environment phase -/

/-- The environment's steps. -/
inductive EnvStep (M W B S : Type) where
  | stop (m : M)
  | stopBoundary (b : B)
  | failSubstrate (c : S)
  | mutate (p : Proc M W)
  | disable (m : M)
  | join

/-- The column "Enabled when" of the table in section 3.1. -/
def Enabled (sys : System M W B S) (s : State M W) : EnvStep M W B S → Prop
  | .stop m => s.alive (.inl m)
  | .stopBoundary b =>
      (∃ m m', m ≠ m' ∧ sys.boundary m = some b ∧ sys.boundary m' = some b) ∧
      (∃ m, sys.boundary m = some b ∧ s.alive (.inl m))
  | .failSubstrate c =>
      ∃ p, Present sys s p ∧ sys.substrate p = some c ∧
        match p with
        | .inl m => s.alive (.inl m)
        | .inr w => ¬ s.bad (.inr w)
  | .mutate p => Present sys s p ∧ ¬ s.bad p
  | .disable m => sys.switches m ∧ ¬ s.off m
  | .join => sys.joiner ≠ none ∧ ¬ s.joined

/-- The processes that `failSubstrate c` makes bad and hidden: every present non-monitor
process with substrate `c`. -/
def Struck (sys : System M W B S) (s : State M W) (c : S) (p : Proc M W) : Prop :=
  ∃ w, p = .inr w ∧ Present sys s p ∧ sys.substrate p = some c

/-- The column "Effect" of the table in section 3.1. -/
def effect (sys : System M W B S) (s : State M W) : EnvStep M W B S → State M W
  | .stop m => { s with alive := fun p => s.alive p ∧ p ≠ .inl m }
  | .stopBoundary b =>
      { s with alive := fun p => s.alive p ∧ ∀ m, p = .inl m → sys.boundary m ≠ some b }
  | .failSubstrate c =>
      { s with
        alive := fun p => s.alive p ∧ ∀ m, p = .inl m → sys.substrate p ≠ some c
        bad := fun p => s.bad p ∨ Struck sys s c p
        hidden := fun p => s.hidden p ∨ Struck sys s c p }
  | .mutate p => { s with bad := fun q => q = p ∨ s.bad q }
  | .disable m => { s with off := fun r => r = m ∨ s.off r }
  | .join =>
      { s with
        joined := True
        alive := fun p => s.alive p ∨ ∃ w, p = .inr w ∧ sys.IsJoiner w }

/-- A sequence of environment steps, each enabled in the state reached by the steps
before it. `EnvRun sys s steps s'`: applying `steps` from `s` reaches `s'`. -/
inductive EnvRun (sys : System M W B S) :
    State M W → List (EnvStep M W B S) → State M W → Prop where
  | nil (s : State M W) : EnvRun sys s [] s
  | cons {s s' : State M W} {e : EnvStep M W B S} {es : List (EnvStep M W B S)} :
      Enabled sys s e → EnvRun sys (effect sys s e) es s' → EnvRun sys s (e :: es) s'

/-! ### Section 3.2. Monitor phase -/

/-- The monitors that are in `alive`, not in `bad`, and not in `off`. -/
def Active (s : State M W) (m : M) : Prop :=
  s.alive (.inl m) ∧ ¬ s.bad (.inl m) ∧ ¬ s.off m

/-- `bad` minus `hidden`. -/
def Visible (s : State M W) (p : Proc M W) : Prop := s.bad p ∧ ¬ s.hidden p

/-- Step 1. An active monitor detects if it checks a visibly bad process, or reads the
signal of a monitor that is not alive. -/
def Detects (sys : System M W B S) (s : State M W) (m : M) : Prop :=
  Active s m ∧
    ((∃ x, Visible s x ∧ sys.checkers x m) ∨
     (∃ p : M, ¬ s.alive (.inl p) ∧ sys.hbReaders p m))

/-- Step 2, repeated until nothing changes: the least set that contains `F` and, with
every active `m` in it, every active `r` that `m` reports to. -/
inductive Spread (sys : System M W B S) (s : State M W) (F : M → Prop) : M → Prop where
  | base {m : M} : F m → Spread sys s F m
  | step {m r : M} : Spread sys s F m → Active s m → sys.fwd m r → Active s r →
      Spread sys s F r

/-- The monitors flagged after step 1: those flagged before, and those that detect. -/
def FlaggedOrDetects (sys : System M W B S) (s : State M W) (m : M) : Prop :=
  s.flagged m ∨ Detects sys s m

/-- `flagged` at the end of the monitor phase. With `slowReports` (section 3.6), step 2 is
a single pass from the monitors that were flagged before this round's detection. -/
def flaggedAfter (sys : System M W B S) (s : State M W) : M → Prop :=
  if sys.slowReports = true then
    fun r => FlaggedOrDetects sys s r ∨
      ∃ m, s.flagged m ∧ Active s m ∧ sys.fwd m r ∧ Active s r
  else
    Spread sys s (FlaggedOrDetects sys s)

/-- The monitor phase changes `flagged` only. -/
def monitorPhase (sys : System M W B S) (s : State M W) : State M W :=
  { s with flagged := flaggedAfter sys s }

/-- Step 3. `out`: the monitors that are in `flagged`, in `alive`, and not in `bad`. -/
def Out (s : State M W) (m : M) : Prop :=
  s.flagged m ∧ s.alive (.inl m) ∧ ¬ s.bad (.inl m)

/-! ### Section 3.3. Work phase -/

/-- `w` sees a reason to halt: a halt input is in `o`, or coupling is on and a halt input
is not alive. -/
def Sees (sys : System M W B S) (s : State M W) (o : M → Prop) (w : W) : Prop :=
  (∃ m, sys.haltInputs w m ∧ o m) ∨
  (sys.coupling = true ∧ ∃ m, sys.haltInputs w m ∧ ¬ s.alive (.inl m))

/-- The work phase handles each present non-monitor process that is not in `halted`. -/
def Handled (sys : System M W B S) (s : State M W) (w : W) : Prop :=
  Present sys s (.inr w) ∧ ¬ s.halted w

/-- `w` takes a work step in this work phase. -/
def Worked (sys : System M W B S) (s : State M W) (o : M → Prop) (w : W) : Prop :=
  Handled sys s w ∧ ¬ s.pending w ∧ ¬ (Sees sys s o w ∧ sys.window = 0)

/-- The work phase, with `o` as the set `out`. A handled process in `pending` moves to
`halted`. Otherwise, if it sees a reason to halt, it halts when `window` is 0 and becomes
pending when it is not. -/
def workPhase (sys : System M W B S) (s : State M W) (o : M → Prop) : State M W :=
  { s with
    halted := fun w =>
      s.halted w ∨ (Handled sys s w ∧ (s.pending w ∨ (Sees sys s o w ∧ sys.window = 0)))
    pending := fun w =>
      (s.pending w ∧ ¬ Handled sys s w) ∨
      (Handled sys s w ∧ ¬ s.pending w ∧ Sees sys s o w ∧ sys.window ≠ 0) }

/-! ### Sections 3.4 and 3.6. One round and the two goals -/

/-- What a round produces: the next state, and whether each goal was violated in it. -/
structure Outcome (M W : Type) where
  next : State M W
  /-- G1 is violated in the round -/
  g1 : Prop
  /-- G2 is violated in the round -/
  g2 : Prop

/-- The monitor and work phases, from the state `s₁` reached by the environment phase.
With the gate (the default), the monitor phase runs first. Without it (section 3.6), the
work phase runs first, on the flags of earlier rounds.

G1 is violated if `bad` is not empty and `out` is empty. G2 is violated if `bad` is not
empty and some process took a work step. -/
def afterEnv (sys : System M W B S) (s₁ : State M W) : Outcome M W :=
  if sys.gate = true then
    let s₂ := monitorPhase sys s₁
    { next := workPhase sys s₂ (Out s₂)
      g1 := (∃ p, s₂.bad p) ∧ ¬ ∃ m, Out s₂ m
      g2 := (∃ p, s₂.bad p) ∧ ∃ w, Worked sys s₂ (Out s₂) w }
  else
    let s₂ := workPhase sys s₁ (Out s₁)
    let s₃ := monitorPhase sys s₂
    { next := s₃
      g1 := (∃ p, s₃.bad p) ∧ ¬ ∃ m, Out s₃ m
      g2 := (∃ p, s₁.bad p) ∧ ∃ w, Worked sys s₁ (Out s₁) w }

/-- Section 3. One round from `s`: at most `f` environment steps, then the other two
phases. -/
def Round (sys : System M W B S) (s : State M W) (r : Outcome M W) : Prop :=
  ∃ (steps : List (EnvStep M W B S)) (s₁ : State M W),
    steps.length ≤ sys.f ∧ EnvRun sys s steps s₁ ∧ r = afterEnv sys s₁

/-- Section 3.5. A responded state: some monitor is flagged, alive and not bad, and every
present non-monitor process is halted. -/
def Responded (sys : System M W B S) (s : State M W) : Prop :=
  (∃ m, s.flagged m ∧ s.alive (.inl m) ∧ ¬ s.bad (.inl m)) ∧
  ∀ w, Present sys s (.inr w) → s.halted w

/-! ### Section 4. Executions and the result -/

/-- The states reached by executions: sequences of rounds from the initial state in which
no round starts from a responded state. -/
inductive Reachable (sys : System M W B S) : State M W → Prop where
  | init : Reachable sys (init sys)
  | round {s : State M W} {r : Outcome M W} :
      Reachable sys s → ¬ Responded sys s → Round sys s r → Reachable sys r.next

/-- No gap: no execution of any length violates G1 or G2 in any of its rounds. In the
specification's terms, the result for both goals is `null`. -/
def NoGap (sys : System M W B S) : Prop :=
  ∀ (s : State M W) (r : Outcome M W),
    Reachable sys s → ¬ Responded sys s → Round sys s r → ¬ r.g1 ∧ ¬ r.g2

/-- Some execution violates G1 in one of its rounds. In the specification's terms, the
result for G1 is a number and not `null`. -/
def ViolatesG1 (sys : System M W B S) : Prop :=
  ∃ (s : State M W) (r : Outcome M W),
    Reachable sys s ∧ ¬ Responded sys s ∧ Round sys s r ∧ r.g1

/-- Some execution violates G2 in one of its rounds. -/
def ViolatesG2 (sys : System M W B S) : Prop :=
  ∃ (s : State M W) (r : Outcome M W),
    Reachable sys s ∧ ¬ Responded sys s ∧ Round sys s r ∧ r.g2

end SelfObserving
