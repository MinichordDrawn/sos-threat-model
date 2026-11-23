/-
Classes of systems with monitors that join, and conditions on them, transcribed from
`results-join.md`, section 3: "plain with joins", the sets of present processes the joins
can reach, the conditions of Theorem J with joins, the smaller system of Lemma N, and the
hypotheses of Theorem L. Everything in this file is a definition.
-/
import SelfObserving.Join
import SelfObserving.AnyRate

namespace SelfObserving

variable {M W B S G : Type}

/-- The states that joins alone reach from the initial state: any number of steps `join`
and `join g`, each enabled when it is taken. The sets of present processes in these states
are "the sets of present processes the joins can reach" of `results-join.md`. (A step
`join-bad g m` makes the same processes present as `join g`.) -/
inductive JoinsReach (sys : JSystem M W B S G) : JState M W G → Prop where
  | init : JoinsReach sys (jinit sys)
  | join {s : JState M W G} : JoinsReach sys s → JEnabled sys s .join →
      JoinsReach sys (jeffect sys s .join)
  | group {s : JState M W G} (g : G) : JoinsReach sys s → JEnabled sys s (.joinGroup g) →
      JoinsReach sys (jeffect sys s (.joinGroup g))

/-- No edge is a slow edge. -/
def NoSlowEdges (sys : JSystem M W B S G) : Prop :=
  (∀ p m, ¬ sys.slowHb p m) ∧ (∀ x m, ¬ sys.slowCheck x m) ∧ (∀ m r, ¬ sys.slowFwd m r) ∧
    ∀ w m, ¬ sys.slowHalt w m

/-- Plain with joins (`results-join.md`, section 3): plain in the sense of `results.md`,
section 10.1, except that the system may have late groups and a joiner. No substrates or
switches; no two monitors in one boundary; work halts on silence; no window; the gate in
place; reports within the round; no slow edges. Monitors may or may not arrive bad. -/
structure PlainJ (sys : JSystem M W B S G) : Prop where
  no_substrate : ∀ p, sys.base.substrate p = none
  no_switch : ∀ m, ¬ sys.base.switches m
  boundaries_distinct : ∀ m m' b, m ≠ m' →
    ¬ (sys.base.boundary m = some b ∧ sys.base.boundary m' = some b)
  coupling_on : sys.base.coupling = true
  no_window : sys.base.window = 0
  gate_on : sys.base.gate = true
  reports_fast : sys.base.slowReports = false
  no_slow : NoSlowEdges sys

/-- `LinkedIn sys P a b`: `b` is reached from `a` through pairs that watch each other and
report to each other (`Paired`, `AnyRate.lean`), every monitor stepped to being in the set
`P`. Every monitor is linked to itself. -/
inductive LinkedIn (sys : System M W B S) (P : M → Prop) : M → M → Prop where
  | refl (a : M) : LinkedIn sys P a a
  | step {a b c : M} : LinkedIn sys P a b → P c → Paired sys b c → LinkedIn sys P a c

/-- The conditions of Theorem J for a system with joins, at `f` faults per round. The
first two are asked in every set of present processes the joins can reach.

- `linked`: the present monitors are connected by pairs of present monitors that watch
  each other and report to each other.
- `work`: every present work process (the joiner, once it has joined, among them) has a
  present state checker and more than `f` present halt inputs: `hs` is a list of different
  monitors, more than `f` of them, each present and a halt input of `w`.
- `monitors`: there are more than `f` initial monitors. -/
structure SufficientJoins (sys : JSystem M W B S G) (f : Nat) : Prop where
  linked : ∀ s, JoinsReach sys s → ∀ a b, JPresent sys s (.inl a) → JPresent sys s (.inl b) →
      LinkedIn sys.base (fun m => JPresent sys s (.inl m)) a b
  work : ∀ s, JoinsReach sys s → ∀ w, JPresent sys s (.inr w) →
      (∃ k, JPresent sys s (.inl k) ∧ sys.base.checkers (.inr w) k) ∧
      ∃ hs : List M, hs.Nodup ∧ f < hs.length ∧
        ∀ h, h ∈ hs → sys.base.haltInputs w h ∧ JPresent sys s (.inl h)
  monitors : ∃ ms : List M, ms.Nodup ∧ f < ms.length ∧ ∀ m, m ∈ ms → sys.group m = none

/-! ### The system without its late monitors -/

variable {M₀ B₀ S₀ : Type}

/-- `InitialPart sys small ι β σ`: `small`, a system of `model-spec.md`, is `sys` with
every late monitor and its edges deleted (Lemma N of `results-join.md`). `ι` names each
monitor of `small` as a monitor of `sys`, `β` each boundary and `σ` each substrate.

- The monitors of `small` are exactly the initial monitors of `sys` (`inj`, `initial`).
- The non-monitor processes are the same, with the same joiner, and the joiner is a
  member of no group (`joiner`, `joiner_free`): this definition does not cover a system
  whose joiner is late.
- Boundaries and substrates are the same up to the renaming (`boundary`, `substrate_mon`,
  `substrate_work`, with `β` and `σ` one to one).
- Every edge between processes of `small` is an edge of `sys` and conversely (`hb`,
  `check_mon`, `check_work`, `fwd`, `halt`); the switches are the same (`switches`).
- `f`, `coupling`, `window`, `gate` and `slowReports` are the same.
- No edge at the joiner is a slow edge (`joiner_prompt`). An edge with a late monitor at
  one end may be slow or not: it is deleted with the monitor. -/
structure InitialPart (sys : JSystem M W B S G) (small : System M₀ W B₀ S₀) (ι : M₀ → M)
    (β : B₀ → B) (σ : S₀ → S) : Prop where
  inj : ∀ a b, ι a = ι b → a = b
  initial : ∀ m, sys.group m = none ↔ ∃ a, ι a = m
  β_inj : ∀ b b', β b = β b' → b = b'
  σ_inj : ∀ c c', σ c = σ c' → c = c'
  f : sys.base.f = small.f
  joiner : sys.base.joiner = small.joiner
  joiner_free : sys.joinerGroup = none
  boundary : ∀ a, sys.base.boundary (ι a) = (small.boundary a).map β
  substrate_mon : ∀ a, sys.base.substrate (.inl (ι a)) = (small.substrate (.inl a)).map σ
  substrate_work : ∀ w, sys.base.substrate (.inr w) = (small.substrate (.inr w)).map σ
  hb : ∀ a b, sys.base.hbReaders (ι a) (ι b) ↔ small.hbReaders a b
  check_mon : ∀ a b, sys.base.checkers (.inl (ι a)) (ι b) ↔ small.checkers (.inl a) b
  check_work : ∀ w b, sys.base.checkers (.inr w) (ι b) ↔ small.checkers (.inr w) b
  fwd : ∀ a b, sys.base.fwd (ι a) (ι b) ↔ small.fwd a b
  halt : ∀ w b, sys.base.haltInputs w (ι b) ↔ small.haltInputs w b
  switches : ∀ a, sys.base.switches (ι a) ↔ small.switches a
  coupling : sys.base.coupling = small.coupling
  window : sys.base.window = small.window
  gate : sys.base.gate = small.gate
  slowReports : sys.base.slowReports = small.slowReports
  joiner_prompt : ∀ w m, sys.base.IsJoiner w → ¬ sys.slowCheck (.inr w) m ∧ ¬ sys.slowHalt w m

/-! ### Theorem L -/

/-- The class of the grown system in Theorem L: plain with joins, with no joiner, except
that edges may be slow and that switches are left to a hypothesis of their own. No
substrates; no two monitors in one boundary; work halts on silence; no window; the gate
in place; reports within the round. The first two are asked of the late monitors as well
as of the initial ones, which is more than `results-join.md` asks in Theorem L. -/
structure GrownClass (sys : JSystem M W B S G) : Prop where
  no_joiner : sys.base.joiner = none
  no_substrate : ∀ p, sys.base.substrate p = none
  boundaries_distinct : ∀ m m' b, m ≠ m' →
    ¬ (sys.base.boundary m = some b ∧ sys.base.boundary m' = some b)
  coupling_on : sys.base.coupling = true
  no_window : sys.base.window = 0
  gate_on : sys.base.gate = true
  reports_fast : sys.base.slowReports = false

/-- In `sys`, a system of `model-spec.md`, every round with a fault ends in a complete
response, at the system's own `f`: from the initial state, every environment phase of at
least one step and at most `f` is followed by a responded state. -/
def AnswersFaults (sys : System M W B S) : Prop :=
  ∀ (steps : List (EnvStep M W B S)) (s₁ : State M W), steps ≠ [] → steps.length ≤ sys.f →
    EnvRun sys (init sys) steps s₁ → Responded sys (afterEnv sys s₁).next

/-- A flag at any monitor reaches a halt input of every work process along report edges
(`Reach`, `Conditions.lean`; a monitor reaches itself). -/
def FlagReachesWork (sys : System M W B S) : Prop :=
  ∀ m w, ∃ h, sys.haltInputs w h ∧ Reach sys m h

/-- The ranking of the late monitors in Theorem L. `rank` ranks them; `chk n`, `rdr n` and
`tgt n` are the state checker, the signal reader and the report target that the late
monitor `n` relies on (they need not be different).

- `check`, `read`, `report`: they are a state checker of `n`, a signal reader of `n` and a
  monitor `n` reports to.
- `lower`: each is an initial monitor or a late monitor of lower rank than `n`.
- `present`: each is present whenever `n` is, in every set of present processes the joins
  can reach. -/
structure Ranked (sys : JSystem M W B S G) (rank : M → Nat) (chk rdr tgt : M → M) : Prop where
  check : ∀ n, sys.Late n → sys.base.checkers (.inl n) (chk n)
  read : ∀ n, sys.Late n → sys.base.hbReaders n (rdr n)
  report : ∀ n, sys.Late n → sys.base.fwd n (tgt n)
  lower : ∀ n, sys.Late n → ∀ c, c = chk n ∨ c = rdr n ∨ c = tgt n →
      ¬ sys.Late c ∨ rank c < rank n
  present : ∀ s, JoinsReach sys s → ∀ n, sys.Late n → JPresent sys s (.inl n) →
      ∀ c, c = chk n ∨ c = rdr n ∨ c = tgt n → JPresent sys s (.inl c)

/-- The three relied-on edges of each late monitor are not slow edges. -/
def Prompt (sys : JSystem M W B S G) (chk rdr tgt : M → M) : Prop :=
  ∀ n, sys.Late n →
    ¬ sys.slowCheck (.inl n) (chk n) ∧ ¬ sys.slowHb n (rdr n) ∧ ¬ sys.slowFwd n (tgt n)

end SelfObserving
