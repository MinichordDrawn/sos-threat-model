/-
The full mesh at any fault rate (`results.md`, section 10.2): a mesh of `n` monitors has no
gap exactly when `f ≤ n - 1`.

The holding half is proved here by the invariant of Theorem S: every state an execution
reaches is quiet or responded. A round from a quiet state takes at most `f` environment
steps. In the mesh only `stop` and `mutate` are ever enabled, and each touches at most one
monitor, so with more than `f` monitors one is left untouched. If a step was taken, that
monitor detects it, flags, and halts every work process: the round ends responded. If no
step was taken, the state stays quiet.

The failing half is `Necessity.rate_bound`, which holds of every system.

`Solution.lean` imports this file, so its helper lemmas cannot be used here: the few that
are needed are proved again below.
-/
import SelfObserving.MeshAt
import SelfObserving.Proofs.Necessity

namespace SelfObserving
namespace MeshRate

variable {M W : Type}

/-! ### Helper lemmas that `Solution.lean` also has -/

/-- A state in which nothing has happened: every monitor is alive and every other
component is empty. -/
structure Quiet (s : State M W) : Prop where
  alive : ∀ m : M, s.alive (.inl m)
  bad : ∀ p, ¬ s.bad p
  hidden : ∀ p, ¬ s.hidden p
  off : ∀ m, ¬ s.off m
  flagged : ∀ m, ¬ s.flagged m
  halted : ∀ w, ¬ s.halted w
  pending : ∀ w, ¬ s.pending w

theorem quiet_init {B S : Type} (sys : System M W B S) : Quiet (init sys) where
  alive := fun _ => trivial
  bad := fun _ h => h
  hidden := fun _ h => h
  off := fun _ h => h
  flagged := fun _ h => h
  halted := fun _ h => h
  pending := fun _ h => h

/-- With the gate, a round runs the monitor phase and then the work phase. -/
theorem afterEnv_gate {B S : Type} {sys : System M W B S} (hg : sys.gate = true)
    (s₁ : State M W) :
    afterEnv sys s₁ =
      { next := workPhase sys (monitorPhase sys s₁) (Out (monitorPhase sys s₁))
        g1 := (∃ p, (monitorPhase sys s₁).bad p) ∧ ¬ ∃ m, Out (monitorPhase sys s₁) m
        g2 := (∃ p, (monitorPhase sys s₁).bad p) ∧
          ∃ w, Worked sys (monitorPhase sys s₁) (Out (monitorPhase sys s₁)) w } := by
  unfold afterEnv
  split
  · rfl
  · exact absurd hg ‹_›

/-- When reports arrive within the round, the flags after the monitor phase are those
that spread from the monitors flagged before or detecting. -/
theorem flaggedAfter_fast {B S : Type} {sys : System M W B S}
    (hfast : sys.slowReports = false) (s : State M W) (m : M) :
    flaggedAfter sys s m ↔ Spread sys s (FlaggedOrDetects sys s) m := by
  unfold flaggedAfter
  split
  · rename_i h
    rw [hfast] at h
    cases h
  · exact Iff.rfl

theorem spread_empty {B S : Type} {sys : System M W B S} {s : State M W} {F : M → Prop}
    (hF : ∀ m, ¬ F m) : ∀ m, ¬ Spread sys s F m := by
  intro m h
  induction h with
  | base hm => exact hF _ hm
  | step _ _ _ _ ih => exact ih

/-- If, after the monitor phase, `out` is not empty and holds a halt input of every work
process, the round violates neither goal and ends in a responded state. -/
theorem finish {B S : Type} {sys : System M W B S} (hp : Plain sys) {s₁ : State M W}
    (hh : ∀ w, ¬ s₁.halted w)
    (hout : ∃ m, Out (monitorPhase sys s₁) m)
    (hhalt : ∀ w, ∃ h, sys.haltInputs w h ∧ Out (monitorPhase sys s₁) h) :
    (¬ (afterEnv sys s₁).g1 ∧ ¬ (afterEnv sys s₁).g2) ∧
      Responded sys (afterEnv sys s₁).next := by
  rw [afterEnv_gate hp.gate_on]
  have hsees : ∀ w, Sees sys (monitorPhase sys s₁) (Out (monitorPhase sys s₁)) w := by
    intro w
    obtain ⟨h, hin, ho⟩ := hhalt w
    exact Or.inl ⟨h, hin, ho⟩
  refine ⟨⟨fun h => h.2 hout, ?_⟩, ?_, ?_⟩
  · rintro ⟨_, w, hw⟩
    exact hw.2.2 ⟨hsees w, hp.no_window⟩
  · obtain ⟨m, hm⟩ := hout
    exact ⟨m, hm⟩
  · intro w hpres
    exact Or.inr ⟨⟨hpres, hh w⟩, Or.inr ⟨hsees w, hp.no_window⟩⟩

/-- A round with no environment step from a quiet state violates neither goal and ends
quiet. -/
theorem quiet_stays {B S : Type} {sys : System M W B S} (hp : Plain sys) {s : State M W}
    (hq : Quiet s) :
    (¬ (afterEnv sys s).g1 ∧ ¬ (afterEnv sys s).g2) ∧ Quiet (afterEnv sys s).next := by
  have hnoflag : ∀ m, ¬ flaggedAfter sys s m := by
    intro m hm
    rw [flaggedAfter_fast hp.reports_fast] at hm
    refine spread_empty (fun m hm => ?_) m hm
    rcases hm with h | h
    · exact hq.flagged m h
    · obtain ⟨_, ⟨x, hx, _⟩ | ⟨p, hp', _⟩⟩ := h
      · exact hq.bad x hx.1
      · exact hp' (hq.alive p)
  have hnosee : ∀ w, ¬ Sees sys (monitorPhase sys s) (Out (monitorPhase sys s)) w := by
    rintro w (⟨m, _, hm⟩ | ⟨_, m, _, hm⟩)
    · exact hnoflag m hm.1
    · exact hm (hq.alive m)
  rw [afterEnv_gate hp.gate_on]
  refine ⟨⟨fun h => ?_, fun h => ?_⟩, ?_⟩
  · obtain ⟨p, hp'⟩ := h.1
    exact hq.bad p hp'
  · obtain ⟨p, hp'⟩ := h.1
    exact hq.bad p hp'
  · refine ⟨hq.alive, hq.bad, hq.hidden, hq.off, hnoflag, ?_, ?_⟩
    · rintro w (h | ⟨_, h | ⟨h, _⟩⟩)
      · exact hq.halted w h
      · exact hq.pending w h
      · exact hnosee w h
    · rintro w (⟨h, _⟩ | ⟨_, _, h, _⟩)
      · exact hq.pending w h
      · exact hnosee w h

/-! ### The mesh is plain -/

theorem meshAt_plain (f : Nat) : Plain (meshAt M W f) where
  no_joiner := rfl
  no_substrate := fun _ => rfl
  no_switch := fun _ h => h
  boundaries_distinct := fun _ _ _ hne h => hne (Option.some.inj (h.1.trans h.2.symm))
  coupling_on := rfl
  no_window := rfl
  gate_on := rfl
  reports_fast := rfl

/-! ### Counting: a list without repeats has a member outside any shorter list -/

/-- A list without repeats, all of whose members are in `ts`, is no longer than `ts`. -/
theorem length_le_of_subset :
    ∀ (ms ts : List M), ms.Nodup → (∀ m, m ∈ ms → m ∈ ts) → ms.length ≤ ts.length
  | [], _, _, _ => Nat.zero_le _
  | a :: ms, ts, hnd, hsub => by
    obtain ⟨l₁, l₂, rfl⟩ := List.append_of_mem (hsub a List.mem_cons_self)
    have hnd' := List.nodup_cons.1 hnd
    have ih := length_le_of_subset ms (l₁ ++ l₂) hnd'.2 (fun m hm => by
      have h := hsub m (List.mem_cons_of_mem _ hm)
      rw [List.mem_append, List.mem_cons] at h
      rw [List.mem_append]
      rcases h with h | h | h
      · exact Or.inl h
      · exact absurd (h ▸ hm) hnd'.1
      · exact Or.inr h)
    simp only [List.length_append, List.length_cons] at ih ⊢
    omega

/-- A list without repeats that is longer than `ts` has a member that is not in `ts`. -/
theorem exists_not_mem (ms ts : List M) (hnd : ms.Nodup) (hlen : ts.length < ms.length) :
    ∃ r, r ∈ ms ∧ r ∉ ts := by
  apply Classical.byContradiction
  intro hno
  have hsub : ∀ m, m ∈ ms → m ∈ ts := fun m hm =>
    Classical.byContradiction fun hnot => hno ⟨m, hm, hnot⟩
  have := length_le_of_subset ms ts hnd hsub
  omega

/-! ### The environment phase from a quiet state -/

/-- What holds during the environment phase of a round that starts quiet. `ts` holds every
monitor that a step has stopped or mutated: every other monitor is alive and not bad.
Nothing is hidden, off, flagged, halted or pending. -/
structure Env (s : State M W) (ts : List M) : Prop where
  good : ∀ m, m ∉ ts → s.alive (.inl m) ∧ ¬ s.bad (.inl m)
  hidden : ∀ p, ¬ s.hidden p
  off : ∀ m, ¬ s.off m
  flagged : ∀ m, ¬ s.flagged m
  halted : ∀ w, ¬ s.halted w
  pending : ∀ w, ¬ s.pending w

/-- A step has left its mark: some monitor is not alive, or some process is bad. -/
def Touched (s : State M W) : Prop :=
  (∃ m : M, ¬ s.alive (.inl m)) ∨ ∃ p, s.bad p

theorem env_of_quiet {s : State M W} (hq : Quiet s) : Env s [] where
  good := fun m _ => ⟨hq.alive m, hq.bad _⟩
  hidden := hq.hidden
  off := hq.off
  flagged := hq.flagged
  halted := hq.halted
  pending := hq.pending

/-- One enabled step of the mesh is `stop` or `mutate`. It touches at most one monitor, and
leaves its mark. -/
theorem env_step (f : Nat) {s : State M W} {e : EnvStep M W M Unit} {ts : List M}
    (he : Enabled (meshAt M W f) s e) (h : Env s ts) :
    ∃ ts', ts'.length ≤ ts.length + 1 ∧ Env (effect (meshAt M W f) s e) ts' ∧
      Touched (effect (meshAt M W f) s e) := by
  have hp := meshAt_plain (M := M) (W := W) f
  cases e with
  | stop z =>
    refine ⟨z :: ts, Nat.le_refl _, ⟨?_, h.hidden, h.off, h.flagged, h.halted, h.pending⟩,
      Or.inl ⟨z, fun h' => h'.2 rfl⟩⟩
    intro m hm
    have hmz : m ≠ z := fun e => hm (e ▸ List.mem_cons_self)
    have hmt : m ∉ ts := fun h' => hm (List.mem_cons_of_mem _ h')
    exact ⟨⟨(h.good m hmt).1, fun e => hmz (Sum.inl.inj e)⟩, (h.good m hmt).2⟩
  | stopBoundary b =>
    obtain ⟨⟨m, m', hne, h₁, h₂⟩, _⟩ := he
    exact absurd ⟨h₁, h₂⟩ (hp.boundaries_distinct m m' b hne)
  | failSubstrate c =>
    obtain ⟨p, _, hsub, _⟩ := he
    rw [hp.no_substrate p] at hsub
    cases hsub
  | mutate p =>
    cases p with
    | inl z =>
      refine ⟨z :: ts, Nat.le_refl _, ⟨?_, h.hidden, h.off, h.flagged, h.halted, h.pending⟩,
        Or.inr ⟨.inl z, Or.inl rfl⟩⟩
      intro m hm
      have hmz : m ≠ z := fun e => hm (e ▸ List.mem_cons_self)
      have hmt : m ∉ ts := fun h' => hm (List.mem_cons_of_mem _ h')
      refine ⟨(h.good m hmt).1, ?_⟩
      rintro (h' | h')
      · exact hmz (Sum.inl.inj h')
      · exact (h.good m hmt).2 h'
    | inr x =>
      refine ⟨ts, Nat.le_succ _, ⟨?_, h.hidden, h.off, h.flagged, h.halted, h.pending⟩,
        Or.inr ⟨.inr x, Or.inl rfl⟩⟩
      intro m hm
      refine ⟨(h.good m hm).1, ?_⟩
      rintro (h' | h')
      · cases h'
      · exact (h.good m hm).2 h'
  | disable m => exact absurd he.1 (hp.no_switch m)
  | join => exact absurd hp.no_joiner he.1

/-- A run of environment steps of the mesh touches at most as many monitors as it has
steps, and, if it has any step or a mark was there before, leaves a mark. -/
theorem env_run (f : Nat) {s s₁ : State M W} {es : List (EnvStep M W M Unit)}
    (hrun : EnvRun (meshAt M W f) s es s₁) :
    ∀ ts, Env s ts →
      ∃ ts', ts'.length ≤ ts.length + es.length ∧ Env s₁ ts' ∧
        (Touched s ∨ es ≠ [] → Touched s₁) := by
  induction hrun with
  | nil s =>
    intro ts h
    refine ⟨ts, Nat.le_refl _, h, ?_⟩
    rintro (h' | h')
    · exact h'
    · exact absurd rfl h'
  | cons he _ ih =>
    intro ts h
    obtain ⟨ts₁, hl₁, h₁, ht₁⟩ := env_step f he h
    obtain ⟨ts₂, hl₂, h₂, ht₂⟩ := ih ts₁ h₁
    refine ⟨ts₂, ?_, h₂, fun _ => ht₂ (Or.inl ht₁)⟩
    simp only [List.length_cons]
    omega

/-! ### One round, and the result -/

/-- One round of the mesh from a quiet state violates neither goal, and ends quiet or
responded. -/
theorem round_from_quiet (f : Nat) (ms : List M) (hnd : ms.Nodup) (hlen : f < ms.length)
    {s : State M W} (hq : Quiet s) {r : Outcome M W} (hr : Round (meshAt M W f) s r) :
    (¬ r.g1 ∧ ¬ r.g2) ∧ (Quiet r.next ∨ Responded (meshAt M W f) r.next) := by
  have hp := meshAt_plain (M := M) (W := W) f
  obtain ⟨steps, s₁, hl, hrun, rfl⟩ := hr
  have hl' : steps.length ≤ f := hl
  cases hrun with
  | nil =>
    -- The environment takes no step: nothing changes.
    have := quiet_stays hp hq
    exact ⟨this.1, Or.inl this.2⟩
  | @cons _ _ e es he hrest =>
    -- The environment takes at least one step, and at most `f`.
    obtain ⟨ts, hlts, henv, htouch⟩ :=
      env_run f (EnvRun.cons he hrest) [] (env_of_quiet hq)
    have htouched : Touched s₁ := htouch (Or.inr (List.cons_ne_nil e es))
    simp only [List.length_nil, Nat.zero_add] at hlts
    -- Some monitor `r` was touched by no step.
    obtain ⟨r, _, hr⟩ := exists_not_mem ms ts hnd (by omega)
    have hact : Active s₁ r := ⟨(henv.good r hr).1, (henv.good r hr).2, henv.off r⟩
    -- It detects whatever was done.
    have hdet : Detects (meshAt M W f) s₁ r := by
      refine ⟨hact, ?_⟩
      rcases htouched with ⟨p, hp'⟩ | ⟨x, hx⟩
      · exact Or.inr ⟨p, hp', fun e => hp' (e ▸ hact.1)⟩
      · refine Or.inl ⟨x, ⟨hx, henv.hidden x⟩, ?_⟩
        cases x with
        | inl m => exact fun e => hact.2.1 (e ▸ hx)
        | inr w => exact trivial
    have hout : Out (monitorPhase (meshAt M W f) s₁) r :=
      ⟨(flaggedAfter_fast hp.reports_fast s₁ r).2 (Spread.base (Or.inr hdet)),
        hact.1, hact.2.1⟩
    have := finish hp henv.halted ⟨r, hout⟩ (fun _ => ⟨r, trivial, hout⟩)
    exact ⟨this.1, Or.inr this.2⟩

/-- Every state an execution of the mesh reaches is quiet or responded. -/
theorem reachable_quiet_or_responded (f : Nat) (ms : List M) (hnd : ms.Nodup)
    (hlen : f < ms.length) {s : State M W} (h : Reachable (meshAt M W f) s) :
    Quiet s ∨ Responded (meshAt M W f) s := by
  induction h with
  | init => exact Or.inl (quiet_init _)
  | round _ hnr hround ih =>
    rcases ih with hq | hresp
    · exact (round_from_quiet f ms hnd hlen hq hround).2
    · exact absurd hresp hnr

/-- The holding half of the mesh result (section 10.2): a mesh of `n` monitors has no gap
when `f ≤ n - 1`. `ms` is a list of different monitors, more than `f` of them, so there
are at least `f + 1` monitors. The numbers of monitors and of work processes are
otherwise arbitrary. -/
theorem mesh_holds (f : Nat) (ms : List M) (hnd : ms.Nodup) (hlen : f < ms.length) :
    NoGap (meshAt M W f) := by
  intro s r hreach hnr hround
  rcases reachable_quiet_or_responded f ms hnd hlen hreach with hq | hresp
  · exact (round_from_quiet f ms hnd hlen hq hround).1
  · exact absurd hresp hnr

/-- The mesh result in both directions (section 10.2): a mesh of `n` monitors, `n` at
least 1, has no gap exactly when `f ≤ n - 1`. `ms` lists every monitor once, so
`ms.length` is `n`, and `f < ms.length` says `f ≤ n - 1`. -/
theorem mesh_exact (f : Nat) (ms : List M) (hne : ms ≠ []) (hnd : ms.Nodup)
    (hall : ∀ m, m ∈ ms) : NoGap (meshAt M W f) ↔ f < ms.length := by
  constructor
  · intro h
    rcases Nat.lt_or_ge f ms.length with hlt | hge
    · exact hlt
    · obtain ⟨s, r, hreach, hnr, hround, hg1⟩ :=
        Necessity.rate_bound (meshAt M W f) ms hne hnd hall hge
      exact absurd hg1 (h s r hreach hnr hround).1
  · exact mesh_holds f ms hnd

end MeshRate
end SelfObserving
