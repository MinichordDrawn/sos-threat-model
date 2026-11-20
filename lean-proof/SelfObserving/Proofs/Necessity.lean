/-
Proofs of the statements of `Challenge.lean` under "What any system needs" and "Naming the
faulty monitor". `Solution.lean` states them again and takes each proof from here.

Each statement about a gap is proved by giving an execution: one round from the initial
state, or two. The file has these parts:

- what the monitor phase and the rest of the round do when no monitor detects: no flag is
  raised, so a bad state violates G1;
- rounds: a round with no detection ends in a state that is reachable and not responded,
  and one that also ends bad shows that G1 can be violated;
- when a work process takes a work step, which violates G2 in a bad state;
- the environment phase that mutates a list of monitors;
- the twelve statements, under the names they have in `Challenge.lean`.

Nothing here is about a particular system, and only `Model.lean` is imported. `Solution.lean`
imports this file, so its helper lemmas cannot be used here: `spread_none` below says what
its `spread_empty` says.
-/
import SelfObserving.Model

namespace SelfObserving
namespace Necessity

variable {M W B S : Type}

/-! ### When no monitor detects -/

/-- A flag spreads only from a monitor that has one: from the empty set nothing spreads. -/
theorem spread_none {sys : System M W B S} {s : State M W} {F : M → Prop}
    (hF : ∀ m, ¬ F m) : ∀ m, ¬ Spread sys s F m := by
  intro m h
  induction h with
  | base hm => exact hF _ hm
  | step _ _ _ _ ih => exact ih

/-- Theorem 0, part 3. From a state with no flag, if no monitor detects, the monitor phase
raises no flag. This holds whether reports are slow or not. -/
theorem flag_needs_detection (sys : System M W B S) (s : State M W)
    (hflag : ∀ m, ¬ s.flagged m) (hdet : ∀ m, ¬ Detects sys s m) :
    ∀ m, ¬ flaggedAfter sys s m := by
  intro m hm
  unfold flaggedAfter at hm
  split at hm
  · rcases hm with (h | h) | ⟨m', h, _⟩
    · exact hflag m h
    · exact hdet m h
    · exact hflag m' h
  · refine spread_none (fun m' h => ?_) m hm
    rcases h with h | h
    · exact hflag m' h
    · exact hdet m' h

/-- The monitor phase and the work phase leave `alive` as it is. -/
theorem afterEnv_alive (sys : System M W B S) (s₁ : State M W) :
    (afterEnv sys s₁).next.alive = s₁.alive := by
  unfold afterEnv
  split <;> rfl

/-- The monitor phase and the work phase leave `bad` as it is. -/
theorem afterEnv_bad (sys : System M W B S) (s₁ : State M W) :
    (afterEnv sys s₁).next.bad = s₁.bad := by
  unfold afterEnv
  split <;> rfl

/-- The monitor phase and the work phase leave `joined` as it is. -/
theorem afterEnv_joined (sys : System M W B S) (s₁ : State M W) :
    (afterEnv sys s₁).next.joined = s₁.joined := by
  unfold afterEnv
  split <;> rfl

/-- If the environment phase ends with no flag and no monitor detects, the round ends with
no flag. Without the gate the monitor phase runs after the work phase, which changes
nothing that detection looks at. -/
theorem afterEnv_no_flag {sys : System M W B S} {s₁ : State M W}
    (hflag : ∀ m, ¬ s₁.flagged m) (hdet : ∀ m, ¬ Detects sys s₁ m) :
    ∀ m, ¬ (afterEnv sys s₁).next.flagged m := by
  unfold afterEnv
  split
  · exact flag_needs_detection sys s₁ hflag hdet
  · exact flag_needs_detection sys (workPhase sys s₁ (Out s₁)) hflag hdet

/-- If the environment phase ends with a bad process and no flag, and no monitor detects,
the round violates G1: `out` is empty. -/
theorem afterEnv_g1 {sys : System M W B S} {s₁ : State M W} (hbad : ∃ p, s₁.bad p)
    (hflag : ∀ m, ¬ s₁.flagged m) (hdet : ∀ m, ¬ Detects sys s₁ m) :
    (afterEnv sys s₁).g1 := by
  unfold afterEnv
  split
  · exact ⟨hbad, fun ⟨m, hm⟩ => flag_needs_detection sys s₁ hflag hdet m hm.1⟩
  · exact ⟨hbad, fun ⟨m, hm⟩ =>
      flag_needs_detection sys (workPhase sys s₁ (Out s₁)) hflag hdet m hm.1⟩

/-! ### Rounds -/

/-- No environment step changes `flagged`. -/
theorem effect_flagged (sys : System M W B S) (s : State M W) (e : EnvStep M W B S) :
    (effect sys s e).flagged = s.flagged := by
  cases e <;> rfl

/-- The environment phase changes no flag. -/
theorem envRun_flagged {sys : System M W B S} {s s₁ : State M W}
    {steps : List (EnvStep M W B S)} (h : EnvRun sys s steps s₁) :
    s₁.flagged = s.flagged := by
  induction h with
  | nil => rfl
  | cons _ _ ih => exact ih.trans (effect_flagged _ _ _)

/-- One enabled step is an environment phase. -/
theorem envRun_one {sys : System M W B S} {s : State M W} {e : EnvStep M W B S}
    (he : Enabled sys s e) : EnvRun sys s [e] (effect sys s e) :=
  EnvRun.cons he (EnvRun.nil _)

/-- A state with no flag is not responded. -/
theorem not_responded {sys : System M W B S} {s : State M W} (hflag : ∀ m, ¬ s.flagged m) :
    ¬ Responded sys s :=
  fun h => h.1.elim fun m hm => hflag m hm.1

/-- The initial state is not responded. -/
theorem init_not_responded (sys : System M W B S) : ¬ Responded sys (init sys) :=
  not_responded fun _ h => h

/-- A round in which no monitor detects, from a reachable state with no flag, ends in a
reachable state with no flag. -/
theorem quiet_round {sys : System M W B S} {s s₁ : State M W}
    {steps : List (EnvStep M W B S)} (hreach : Reachable sys s)
    (hflag : ∀ m, ¬ s.flagged m) (hrun : EnvRun sys s steps s₁)
    (hlen : steps.length ≤ sys.f) (hdet : ∀ m, ¬ Detects sys s₁ m) :
    Reachable sys (afterEnv sys s₁).next ∧ ∀ m, ¬ (afterEnv sys s₁).next.flagged m := by
  have hflag₁ : ∀ m, ¬ s₁.flagged m := fun m => by
    rw [envRun_flagged hrun]
    exact hflag m
  exact ⟨Reachable.round hreach (not_responded hflag) ⟨steps, s₁, hlen, hrun, rfl⟩,
    afterEnv_no_flag hflag₁ hdet⟩

/-- G1 can be violated if, from a reachable state with no flag, some environment phase
ends with a bad process and with no monitor detecting. -/
theorem violatesG1_of_run {sys : System M W B S} {s s₁ : State M W}
    {steps : List (EnvStep M W B S)} (hreach : Reachable sys s)
    (hflag : ∀ m, ¬ s.flagged m) (hrun : EnvRun sys s steps s₁)
    (hlen : steps.length ≤ sys.f) (hbad : ∃ p, s₁.bad p)
    (hdet : ∀ m, ¬ Detects sys s₁ m) : ViolatesG1 sys := by
  have hflag₁ : ∀ m, ¬ s₁.flagged m := fun m => by
    rw [envRun_flagged hrun]
    exact hflag m
  exact ⟨s, afterEnv sys s₁, hreach, not_responded hflag, ⟨steps, s₁, hlen, hrun, rfl⟩,
    afterEnv_g1 hbad hflag₁ hdet⟩

/-! ### When a work process takes a work step -/

/-- A work process sees no reason to halt when every monitor is alive and none of its halt
inputs is in `out`. -/
theorem not_sees {sys : System M W B S} {s : State M W} {o : M → Prop} {w : W}
    (halive : ∀ m, s.alive (.inl m)) (hout : ∀ m, sys.haltInputs w m → ¬ o m) :
    ¬ Sees sys s o w := by
  rintro (⟨m, hin, hm⟩ | ⟨_, m, _, hm⟩)
  · exact hout m hin hm
  · exact hm (halive m)

/-- If the environment phase ends with a bad process, the round violates G2 as soon as
some work process that is present, not halted and not pending does not halt at once. With
the gate, that is judged on the flags after the monitor phase. Without it, on the flags
the round began with. -/
theorem afterEnv_g2 {sys : System M W B S} {s₁ : State M W} {w : W}
    (hbad : ∃ p, s₁.bad p) (hpres : Present sys s₁ (.inr w)) (hhalted : ¬ s₁.halted w)
    (hpending : ¬ s₁.pending w)
    (hgate : sys.gate = true →
      ¬ (Sees sys (monitorPhase sys s₁) (Out (monitorPhase sys s₁)) w ∧ sys.window = 0))
    (hnogate : sys.gate = false → ¬ (Sees sys s₁ (Out s₁) w ∧ sys.window = 0)) :
    (afterEnv sys s₁).g2 := by
  unfold afterEnv
  split
  · rename_i hg
    exact ⟨hbad, w, ⟨hpres, hhalted⟩, hpending, hgate hg⟩
  · rename_i hg
    exact ⟨hbad, w, ⟨hpres, hhalted⟩, hpending, hnogate (Bool.eq_false_iff.2 hg)⟩

/-- A non-monitor process that is not the joiner can be mutated in the initial state. -/
theorem enabled_mutate_init {sys : System M W B S} {w : W} (hw : ¬ sys.IsJoiner w) :
    Enabled sys (init sys) (.mutate (.inr w)) :=
  ⟨fun h => absurd h hw, fun h => h⟩

/-- G2 can be violated if, in round 1, the environment mutates a work process `w` that is
present from the start and `w` does not halt at once. After that step every monitor is
alive, `w` is the only bad process, and there is no flag. -/
theorem violatesG2_of_mutate {sys : System M W B S} (hf : 1 ≤ sys.f) {w : W}
    (hw : ¬ sys.IsJoiner w)
    (hgate : sys.gate = true →
      ¬ (Sees sys (monitorPhase sys (effect sys (init sys) (.mutate (.inr w))))
          (Out (monitorPhase sys (effect sys (init sys) (.mutate (.inr w))))) w ∧
        sys.window = 0))
    (hnogate : sys.gate = false →
      ¬ (Sees sys (effect sys (init sys) (.mutate (.inr w)))
          (Out (effect sys (init sys) (.mutate (.inr w)))) w ∧ sys.window = 0)) :
    ViolatesG2 sys :=
  ⟨init sys, afterEnv sys (effect sys (init sys) (.mutate (.inr w))), Reachable.init,
    init_not_responded sys,
    ⟨[.mutate (.inr w)], _, hf, envRun_one (enabled_mutate_init hw), rfl⟩,
    afterEnv_g2 ⟨.inr w, Or.inl rfl⟩ (fun h => absurd h hw) (fun h => h) (fun h => h)
      hgate hnogate⟩

/-! ### Mutating a list of monitors in one environment phase -/

/-- The state after the environment mutates the monitors of `zs`, one after the other. -/
def mutateAll (sys : System M W B S) (s : State M W) : List M → State M W
  | [] => s
  | z :: zs => mutateAll sys (effect sys s (.mutate (.inl z))) zs

/-- Mutating monitors leaves `alive` as it is. -/
theorem mutateAll_alive (sys : System M W B S) (zs : List M) :
    ∀ s : State M W, (mutateAll sys s zs).alive = s.alive := by
  induction zs with
  | nil => exact fun _ => rfl
  | cons z zs ih => exact fun s => ih _

/-- Mutating monitors leaves `halted` as it is. -/
theorem mutateAll_halted (sys : System M W B S) (zs : List M) :
    ∀ s : State M W, (mutateAll sys s zs).halted = s.halted := by
  induction zs with
  | nil => exact fun _ => rfl
  | cons z zs ih => exact fun s => ih _

/-- Mutating monitors leaves `pending` as it is. -/
theorem mutateAll_pending (sys : System M W B S) (zs : List M) :
    ∀ s : State M W, (mutateAll sys s zs).pending = s.pending := by
  induction zs with
  | nil => exact fun _ => rfl
  | cons z zs ih => exact fun s => ih _

/-- After the monitors of `zs` are mutated, the bad processes are those monitors and the
processes that were bad before. -/
theorem mutateAll_bad (sys : System M W B S) (zs : List M) :
    ∀ (s : State M W) (p : Proc M W),
      (mutateAll sys s zs).bad p ↔ (∃ z, z ∈ zs ∧ p = .inl z) ∨ s.bad p := by
  induction zs with
  | nil =>
    intro s p
    exact ⟨Or.inr, fun h => h.elim (fun ⟨_, hz, _⟩ => nomatch hz) id⟩
  | cons z zs ih =>
    intro s p
    refine (ih (effect sys s (.mutate (.inl z))) p).trans ⟨?_, ?_⟩
    · rintro (⟨z', hz', rfl⟩ | h | h)
      · exact Or.inl ⟨z', List.mem_cons_of_mem _ hz', rfl⟩
      · exact Or.inl ⟨z, List.mem_cons_self, h⟩
      · exact Or.inr h
    · rintro (⟨z', hz', rfl⟩ | h)
      · rcases List.mem_cons.1 hz' with rfl | hz'
        · exact Or.inr (Or.inl rfl)
        · exact Or.inl ⟨z', hz', rfl⟩
      · exact Or.inr (Or.inr h)

/-- Monitors that are not bad, listed without repeats, can be mutated one after the other
in a single environment phase: each step is enabled when it is taken. -/
theorem envRun_mutateAll (sys : System M W B S) (zs : List M) (hnd : zs.Nodup) :
    ∀ s : State M W, (∀ z, z ∈ zs → ¬ s.bad (.inl z)) →
      EnvRun sys s (zs.map fun z => .mutate (.inl z)) (mutateAll sys s zs) := by
  induction zs with
  | nil => exact fun s _ => EnvRun.nil s
  | cons z zs ih =>
    intro s hgood
    have hnd' := List.nodup_cons.1 hnd
    refine EnvRun.cons ⟨trivial, hgood z List.mem_cons_self⟩ (ih hnd'.2 _ ?_)
    rintro z' hz' (h | h)
    · exact hnd'.1 (Sum.inl.inj h ▸ hz')
    · exact hgood z' (List.mem_cons_of_mem _ hz') h

/-! ### What any system needs -/

/-- The rate form of P5. The environment mutates every monitor of `zs` in round 1. Every
monitor is still alive, so no silence is detected. The only bad processes are the monitors
of `zs`, and whoever checks one of them is in `zs`, so is bad and detects nothing. -/
theorem unchecked_set_gap (sys : System M W B S) (zs : List M) (hne : zs ≠ [])
    (hnd : zs.Nodup) (hlen : zs.length ≤ sys.f)
    (hin : ∀ z, z ∈ zs → ∀ r, sys.checkers (.inl z) r → r ∈ zs) : ViolatesG1 sys := by
  have hrun := envRun_mutateAll sys zs hnd (init sys) (fun _ _ h => h)
  have hlen' : (zs.map fun z => (.mutate (.inl z) : EnvStep M W B S)).length ≤ sys.f := by
    rw [List.length_map]
    exact hlen
  refine violatesG1_of_run Reachable.init (fun _ h => h) hrun hlen' ?_ ?_
  · obtain ⟨z, hz⟩ := List.exists_mem_of_ne_nil zs hne
    exact ⟨.inl z, (mutateAll_bad sys zs _ _).2 (Or.inl ⟨z, hz, rfl⟩)⟩
  · rintro m ⟨hact, ⟨x, hx, hc⟩ | ⟨p, hp, _⟩⟩
    · rcases (mutateAll_bad sys zs _ _).1 hx.1 with ⟨z, hz, rfl⟩ | h
      · exact hact.2.1 ((mutateAll_bad sys zs _ _).2 (Or.inl ⟨m, hin z hz m hc, rfl⟩))
      · exact h
    · apply hp
      rw [mutateAll_alive]
      trivial

/-- Theorem 0, part 1. The set of all monitors is checked by no monitor outside it. -/
theorem rate_bound (sys : System M W B S) (ms : List M) (hne : ms ≠ []) (hnd : ms.Nodup)
    (hall : ∀ m, m ∈ ms) (hlen : ms.length ≤ sys.f) : ViolatesG1 sys :=
  unchecked_set_gap sys ms hne hnd hlen fun _ _ r _ => hall r

/-- P3 for monitors. A monitor that only itself checks is a set of one, checked by no
monitor outside it. -/
theorem unchecked_monitor_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (z : M)
    (hz : ∀ r, sys.checkers (.inl z) r → r = z) : ViolatesG1 sys := by
  refine unchecked_set_gap sys [z] (List.cons_ne_nil z [])
    (List.nodup_cons.2 ⟨List.not_mem_nil, List.nodup_nil⟩) hf ?_
  intro z' hz' r hr
  rw [List.mem_singleton] at hz' ⊢
  rw [hz'] at hr
  exact hz r hr

/-- P3 for work, and P7. If `w` is present from the start, the environment mutates it in
round 1. If `w` is the joiner, it joins in round 1, in which nothing is bad and nothing is
flagged, and the environment mutates it in round 2. Either way every monitor is alive and
`w` is the only bad process, and no monitor checks `w`. -/
theorem unchecked_work_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (w : W)
    (hw : ∀ m, ¬ sys.checkers (.inr w) m) : ViolatesG1 sys := by
  -- No monitor detects after `w` is mutated in a state where every monitor is alive and
  -- nothing was bad.
  have hdet : ∀ s : State M W, (∀ m, s.alive (.inl m)) → (∀ p, ¬ s.bad p) →
      ∀ m, ¬ Detects sys (effect sys s (.mutate (.inr w))) m := by
    rintro s halive hbad m ⟨_, ⟨x, hx, hc⟩ | ⟨p, hp, _⟩⟩
    · rcases hx.1 with rfl | h
      · exact hw m hc
      · exact hbad x h
    · exact hp (halive p)
  by_cases hj : sys.IsJoiner w
  · -- Round 1: the joiner joins.
    have hj' : sys.joiner = some w := hj
    have he : Enabled sys (init sys) .join := by
      refine ⟨fun h => ?_, fun h => h⟩
      rw [hj'] at h
      cases h
    have hdet₁ : ∀ m, ¬ Detects sys (effect sys (init sys) .join) m := by
      rintro m ⟨_, ⟨x, hx, _⟩ | ⟨p, hp, _⟩⟩
      · exact hx.1
      · exact hp (Or.inl trivial)
    obtain ⟨hreach, hflag⟩ :=
      quiet_round Reachable.init (fun _ h => h) (envRun_one he) hf hdet₁
    -- Round 2: the joiner is mutated.
    have halive : ∀ m, (afterEnv sys (effect sys (init sys) .join)).next.alive (.inl m) := by
      intro m
      rw [afterEnv_alive]
      exact Or.inl trivial
    have hbad : ∀ p, ¬ (afterEnv sys (effect sys (init sys) .join)).next.bad p := by
      intro p
      rw [afterEnv_bad]
      exact fun h => h
    have he₂ : Enabled sys (afterEnv sys (effect sys (init sys) .join)).next
        (.mutate (.inr w)) := by
      refine ⟨fun _ => ?_, hbad _⟩
      rw [afterEnv_joined]
      trivial
    exact violatesG1_of_run hreach hflag (envRun_one he₂) hf ⟨.inr w, Or.inl rfl⟩
      (hdet _ halive hbad)
  · -- `w` is present from the start.
    exact violatesG1_of_run Reachable.init (fun _ h => h)
      (envRun_one (enabled_mutate_init hj)) hf ⟨.inr w, Or.inl rfl⟩
      (hdet _ (fun _ => trivial) (fun _ h => h))

/-- Theorem 0, part 2, and P6 in general. Round 1: the boundary is stopped, and with it
every monitor. No monitor is alive, so none detects and none flags. Round 2: a monitor is
mutated (a stopped process can still be mutated). Again no monitor is alive to detect. -/
theorem one_boundary_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (b : B) {m₀ m₁ : M}
    (hne : m₀ ≠ m₁) (hb : ∀ m, sys.boundary m = some b) : ViolatesG1 sys := by
  have he : Enabled sys (init sys) (.stopBoundary b) :=
    ⟨⟨m₀, m₁, hne, hb m₀, hb m₁⟩, m₀, hb m₀, trivial⟩
  have hdead : ∀ m, ¬ (effect sys (init sys) (.stopBoundary b)).alive (.inl m) :=
    fun m h => h.2 m rfl (hb m)
  obtain ⟨hreach, hflag⟩ :=
    quiet_round Reachable.init (fun _ h => h) (envRun_one he) hf (fun m h => hdead m h.1.1)
  have he₂ : Enabled sys (afterEnv sys (effect sys (init sys) (.stopBoundary b))).next
      (.mutate (.inl m₀)) := by
    refine ⟨trivial, ?_⟩
    rw [afterEnv_bad]
    exact fun h => h
  refine violatesG1_of_run hreach hflag (envRun_one he₂) hf ⟨.inl m₀, Or.inl rfl⟩ ?_
  intro m h
  have halive : (afterEnv sys (effect sys (init sys) (.stopBoundary b))).next.alive
      (.inl m) := h.1.1
  rw [afterEnv_alive] at halive
  exact hdead m halive

/-- P8 in general. The environment mutates `w` in round 1. Whatever `w` sees, it does not
halt in this round, because the window is not 0. So it takes a work step. -/
theorem window_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (hwin : sys.window ≠ 0) (w : W)
    (hw : ¬ sys.IsJoiner w) : ViolatesG2 sys :=
  violatesG2_of_mutate hf hw (fun _ h => hwin h.2) (fun _ h => hwin h.2)

/-- P8b in general. If `w` has no halt input, the environment mutates `w`, and `w` sees no
reason to halt. Otherwise the environment mutates every halt input of `w` in round 1: all
of them are alive and bad, so none is in `out` and none is silent, and `w` sees no reason
to halt. -/
theorem few_halt_inputs_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (w : W)
    (hw : ¬ sys.IsJoiner w) (hs : List M) (hnd : hs.Nodup)
    (hall : ∀ m, sys.haltInputs w m → m ∈ hs) (hlen : hs.length ≤ sys.f) :
    ViolatesG2 sys := by
  by_cases hne : hs = []
  · -- `w` has no halt input.
    have hnone : ∀ m, ¬ sys.haltInputs w m := fun m h => by
      have hm := hall m h
      rw [hne] at hm
      exact nomatch hm
    exact violatesG2_of_mutate hf hw
      (fun _ h => not_sees (fun _ => trivial) (fun m hm _ => hnone m hm) h.1)
      (fun _ h => not_sees (fun _ => trivial) (fun m hm _ => hnone m hm) h.1)
  · -- Every halt input of `w` is mutated.
    have hrun := envRun_mutateAll sys hs hnd (init sys) (fun _ _ h => h)
    have hlen' : (hs.map fun z => (.mutate (.inl z) : EnvStep M W B S)).length ≤ sys.f := by
      rw [List.length_map]
      exact hlen
    have halive : ∀ m, (mutateAll sys (init sys) hs).alive (.inl m) := by
      intro m
      rw [mutateAll_alive]
      trivial
    have hbad : ∀ m, sys.haltInputs w m → (mutateAll sys (init sys) hs).bad (.inl m) :=
      fun m hm => (mutateAll_bad sys hs _ _).2 (Or.inl ⟨m, hall m hm, rfl⟩)
    obtain ⟨z, hz⟩ := List.exists_mem_of_ne_nil hs hne
    refine ⟨init sys, afterEnv sys (mutateAll sys (init sys) hs), Reachable.init,
      init_not_responded sys, ⟨_, _, hlen', hrun, rfl⟩,
      afterEnv_g2 (w := w) ⟨.inl z, (mutateAll_bad sys hs _ _).2 (Or.inl ⟨z, hz, rfl⟩)⟩
        (fun h => absurd h hw) ?_ ?_ ?_ ?_⟩
    · rw [mutateAll_halted]
      exact fun h => h
    · rw [mutateAll_pending]
      exact fun h => h
    · exact fun _ h => not_sees halive (fun m hm ho => ho.2.2 (hbad m hm)) h.1
    · exact fun _ h => not_sees halive (fun m hm ho => ho.2.2 (hbad m hm)) h.1

/-- The gate in general. The environment mutates `w` in round 1. Without the gate the work
phase runs on the flags the round began with, and there are none: `w` sees no reason to
halt. -/
theorem noGate_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (hgate : sys.gate = false)
    (w : W) (hw : ¬ sys.IsJoiner w) : ViolatesG2 sys :=
  violatesG2_of_mutate hf hw
    (fun hg => nomatch hgate.symm.trans hg)
    (fun _ h => not_sees (fun _ => trivial) (fun _ _ ho => ho.1) h.1)

/-- When reports take a round, a monitor that has a flag after a monitor phase that began
with none has itself detected. -/
theorem slow_flag_detects {sys : System M W B S} (hslow : sys.slowReports = true)
    {s : State M W} (hflag : ∀ m, ¬ s.flagged m) {m : M} (h : flaggedAfter sys s m) :
    Detects sys s m := by
  unfold flaggedAfter at h
  split at h
  · rcases h with (h | h) | ⟨m', h, _⟩
    · exact absurd h (hflag m)
    · exact h
    · exact absurd h (hflag m')
  · exact absurd hslow ‹_›

/-- The reflex. The environment mutates `w` in round 1. With the gate, the monitors that
flag in this round are those that detect, so they check `w`, and none of them is a halt
input of `w`. Without the gate there is no flag at all when `w` steps. Either way `w` sees
no reason to halt. -/
theorem slow_report_gap (sys : System M W B S) (hf : 1 ≤ sys.f)
    (hslow : sys.slowReports = true) (w : W) (hw : ¬ sys.IsJoiner w)
    (hsep : ∀ m, sys.haltInputs w m → ¬ sys.checkers (.inr w) m) : ViolatesG2 sys := by
  refine violatesG2_of_mutate hf hw
    (fun _ h => not_sees (fun _ => trivial) (fun m hm ho => ?_) h.1)
    (fun _ h => not_sees (fun _ => trivial) (fun _ _ ho => ho.1) h.1)
  obtain ⟨_, ⟨x, hx, hc⟩ | ⟨p, hp, _⟩⟩ := slow_flag_detects hslow (fun _ h => h) ho.1
  · rcases hx.1 with rfl | h
    · exact hsep m hm hc
    · exact h
  · exact hp trivial

/-! ### Naming the faulty monitor -/

/-- With two monitors, "each names the other" is what a rule reads both when the first is
faulty and when the second is, and the rule gives one answer. -/
theorem two_cannot_name :
    ¬ ∃ rule : (Bool → Bool) → Bool,
        ∀ (z : Bool) (names : Bool → Bool),
          (∀ m, m ≠ z → names m = z) → rule names = z := by
  rintro ⟨rule, h⟩
  have htrue : rule (fun m => !m) = true := by
    refine h true _ (fun m hm => ?_)
    cases m
    · rfl
    · exact absurd rfl hm
  have hfalse : rule (fun m => !m) = false := by
    refine h false _ (fun m hm => ?_)
    cases m
    · exact absurd rfl hm
    · rfl
  exact nomatch htrue.symm.trans hfalse

/-- With three monitors or more, the rule "the monitor that two different monitors name"
is always right. Two of the three monitors `a`, `b`, `c` are not the faulty one, and both
name it. And of any two different monitors that name the same one, at least one is not
faulty, so the one they name is the faulty one. -/
theorem three_can_name (a b c : M) (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    ∃ rule : (M → M) → M,
      ∀ (z : M) (names : M → M), (∀ m, m ≠ z → names m = z) → rule names = z := by
  classical
  refine ⟨fun names =>
    if h : ∃ x m m', m ≠ m' ∧ names m = x ∧ names m' = x then Classical.choose h
    else a, ?_⟩
  intro z names hz
  have hex : ∃ x m m', m ≠ m' ∧ names m = x ∧ names m' = x := by
    by_cases hza : a = z
    · exact ⟨z, b, c, hbc, hz b (fun h => hab (hza.trans h.symm)),
        hz c (fun h => hac (hza.trans h.symm))⟩
    · by_cases hzb : b = z
      · exact ⟨z, a, c, hac, hz a hza, hz c (fun h => hbc (hzb.trans h.symm))⟩
      · exact ⟨z, a, b, hab, hz a hza, hz b hzb⟩
  show (if h : ∃ x m m', m ≠ m' ∧ names m = x ∧ names m' = x then Classical.choose h
    else a) = z
  split
  · rename_i h
    obtain ⟨m, m', hne, hm, hm'⟩ := Classical.choose_spec h
    by_cases hmz : m = z
    · exact hm'.symm.trans (hz m' (fun h => hne (hmz.trans h.symm)))
    · exact hm.symm.trans (hz m hmz)
  · exact absurd hex ‹_›

end Necessity
end SelfObserving
