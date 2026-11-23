/-
Theorem J for systems with monitors that join (`results-join.md`, section 3), and the
remark that a plain system meeting the conditions of Theorem J answers every round with a
fault by a complete response.

`theorem_J_joins` is the argument of `Connected.theorem_J` in the model of `Join.lean`. The
invariant is that every state an execution reaches is quiet or responded, where a quiet
state is one in which every present monitor is alive, nothing is bad, hidden, off, flagged,
halted or pending, and the groups that have joined and the joiner's joining are those of
some state that joins alone reach (`JoinsReach`).

A round from a quiet state takes at most `f` environment steps. In a system that is plain
with joins only `stop`, `mutate`, `join`, `join g` and `join-bad g m` are ever enabled.
Along them a state that joins alone reach is kept beside the current state, with the same
groups joined and the same joining of the joiner, so with the same present processes: a
`join-bad g m` is matched by `join g`. There is a list `ts` of monitors, no longer than the
number of steps, outside which every monitor is not bad and, if present, alive; every bad
process is present; nothing is hidden, off, flagged, halted or pending.

After the environment phase, either every present monitor is alive and nothing is bad, and
then the two other phases change nothing; or some present monitor is not alive or some
present process is bad. In that case, there being no slow edge, an edge is in force exactly
when it is an edge between two present processes, and the conditions, taken at the state
kept beside, give that every present monitor outside `ts` is flagged after the monitor
phase. More than `f` initial monitors put one of them in `out`, and each present work
process has a halt input in `out` and halts without a work step.

`MeshRate.finish` is stated for a `Plain` system, which has no joiner. `finish_present`
below is the same lemma asking only the gate and no window, for the present work
processes.
-/
import SelfObserving.JoinConditions
import SelfObserving.Proofs.Connected

namespace SelfObserving
namespace JoinConnected

variable {M W B S : Type}

/-! ### A plain system that meets the conditions of Theorem J answers every fault -/

/-- In a plain system that meets the conditions of Theorem J, every round with a fault
ends in a complete response. -/
theorem connected_answers (sys : System M W B S) (hp : Plain sys)
    (hs : SufficientJ sys sys.f) : AnswersFaults sys := by
  intro steps s₁ hne hl hrun
  obtain ⟨ts, hlts, henv, htouch⟩ :=
    Connected.plain_env_run hp hrun [] (MeshRate.env_of_quiet (MeshRate.quiet_init sys))
  have htouched : MeshRate.Touched s₁ := htouch (Or.inr hne)
  simp only [List.length_nil, Nat.zero_add] at hlts
  obtain ⟨hout, hhalt⟩ :=
    Connected.answered_one_way hp (Connected.paired_is_one_way sys sys.f hs) s₁ ts
      (Nat.le_trans hlts hl) henv htouched
  exact (MeshRate.finish hp henv.halted hout hhalt).2

/-! ### Theorem J with joins -/

section Joins

variable {G : Type}

/-! #### Who is present -/

/-- Who is present depends only on the groups that have joined and on whether the joiner
has. -/
theorem present_congr (sys : JSystem M W B S G) {s s' : JState M W G}
    (hA : s'.arrived = s.arrived) (hJ : s'.st.joined = s.st.joined) (p : Proc M W) :
    JPresent sys s' p ↔ JPresent sys s p := by
  cases p with
  | inl m =>
    show (∀ g, sys.group m = some g → s'.arrived g) ↔
      (∀ g, sys.group m = some g → s.arrived g)
    rw [hA]
  | inr w =>
    show (sys.base.IsJoiner w → s'.st.joined) ↔ (sys.base.IsJoiner w → s.st.joined)
    rw [hJ]

/-- A process present in `s` is present in a state with the same groups joined and the
same joining of the joiner. -/
theorem present_same {sys : JSystem M W B S G} {s t : JState M W G}
    (hA : t.arrived = s.arrived) (hJ : t.st.joined = s.st.joined) {p : Proc M W}
    (h : JPresent sys s p) : JPresent sys t p :=
  (present_congr sys hA hJ p).2 h

/-- The joiner's step removes no process. -/
theorem present_join {sys : JSystem M W B S G} {s : JState M W G} {p : Proc M W}
    (h : JPresent sys s p) : JPresent sys (jeffect sys s .join) p := by
  cases p with
  | inl m => exact h
  | inr w => exact fun _ => trivial

/-- A group's step removes no process. -/
theorem present_joinEffect {sys : JSystem M W B S G} {s : JState M W G} (g : G)
    {p : Proc M W} (h : JPresent sys s p) : JPresent sys (joinEffect sys s g) p := by
  cases p with
  | inl m => exact fun k hk => Or.inr (h k hk)
  | inr w => exact fun hj => Or.inl (h hj)

/-- If a monitor was alive whenever present, it still is after a group's step: a monitor
that the step makes present is a member of the group, and the step makes it alive. -/
theorem alive_joinEffect {sys : JSystem M W B S G} {s : JState M W G} (g : G) {m : M}
    (hgood : JPresent sys s (.inl m) → s.st.alive (.inl m))
    (hpr : JPresent sys (joinEffect sys s g) (.inl m)) :
    (joinEffect sys s g).st.alive (.inl m) := by
  cases hgm : sys.group m with
  | none =>
    refine Or.inl (hgood ?_)
    intro k hk
    rw [hgm] at hk
    cases hk
  | some k =>
    have hk : k = g ∨ s.arrived k := hpr k hgm
    rcases hk with hkg | harr
    · exact Or.inr (hkg ▸ hgm)
    · refine Or.inl (hgood ?_)
      intro k' hk'
      rw [hgm] at hk'
      cases hk'
      exact harr

/-! #### The environment phase from a quiet state -/

/-- What holds during the environment phase of a round that starts quiet.

- `shadow`: some state that joins alone reach has the same groups joined and the same
  joining of the joiner, so the same present processes.
- `good`: `ts` holds every monitor that a step has stopped, mutated or brought in bad:
  every other monitor is not bad and, if present, alive.
- `badp`: every bad process is present.
- Nothing is hidden, off, flagged, halted or pending. -/
structure JEnv (sys : JSystem M W B S G) (s : JState M W G) (ts : List M) : Prop where
  shadow : ∃ s', JoinsReach sys s' ∧ s'.arrived = s.arrived ∧ s'.st.joined = s.st.joined
  good : ∀ m, m ∉ ts →
    ¬ s.st.bad (.inl m) ∧ (JPresent sys s (.inl m) → s.st.alive (.inl m))
  badp : ∀ p, s.st.bad p → JPresent sys s p
  hidden : ∀ p, ¬ s.st.hidden p
  off : ∀ m, ¬ s.st.off m
  flagged : ∀ m, ¬ s.st.flagged m
  halted : ∀ w, ¬ s.st.halted w
  pending : ∀ w, ¬ s.st.pending w

/-- A group's step, enabled in a state, is enabled in the state kept beside it, and the
two states after it again have the same groups joined and the same joining of the
joiner. -/
theorem shadow_group {sys : JSystem M W B S G} {s s' : JState M W G} (g : G)
    (hs' : JoinsReach sys s') (hA : s'.arrived = s.arrived)
    (hJ : s'.st.joined = s.st.joined) (he : JoinEnabled sys s g) :
    ∃ t, JoinsReach sys t ∧ t.arrived = (joinEffect sys s g).arrived ∧
      t.st.joined = (joinEffect sys s g).st.joined := by
  have he' : JEnabled sys s' (.joinGroup g) := by
    show ¬ s'.arrived g ∧ ∀ p, sys.after g p → JPresent sys s' p
    refine ⟨?_, fun p hp => present_same hA hJ (he.2 p hp)⟩
    rw [hA]
    exact he.1
  refine ⟨jeffect sys s' (.joinGroup g), JoinsReach.group g hs' he', ?_, ?_⟩
  · show (fun h => h = g ∨ s'.arrived h) = (fun h => h = g ∨ s.arrived h)
    rw [hA]
  · show (s'.st.joined ∨ ∃ w, JMember sys g (.inr w)) =
      (s.st.joined ∨ ∃ w, JMember sys g (.inr w))
    rw [hJ]

/-- One enabled step of a system that is plain with joins is `stop`, `mutate`, `join`,
`join g` or `join-bad g m`. It touches at most one monitor. -/
theorem jenv_step {sys : JSystem M W B S G} (hp : PlainJ sys) {s : JState M W G}
    {e : JStep M W B S G} {ts : List M} (he : JEnabled sys s e) (h : JEnv sys s ts) :
    ∃ ts', ts'.length ≤ ts.length + 1 ∧ JEnv sys (jeffect sys s e) ts' := by
  obtain ⟨s', hs', hA, hJ⟩ := h.shadow
  cases e with
  | stop z =>
    refine ⟨z :: ts, Nat.le_refl _,
      ⟨⟨s', hs', hA, hJ⟩, ?_, fun p hb => present_same rfl rfl (h.badp p hb),
        h.hidden, h.off, h.flagged, h.halted, h.pending⟩⟩
    intro m hm
    have hmz : m ≠ z := fun e => hm (e ▸ List.mem_cons_self)
    have hmt : m ∉ ts := fun h' => hm (List.mem_cons_of_mem _ h')
    exact ⟨(h.good m hmt).1,
      fun hpr => ⟨(h.good m hmt).2 hpr, fun e => hmz (Sum.inl.inj e)⟩⟩
  | stopBoundary b =>
    obtain ⟨⟨m, m', hne, h₁, h₂, _⟩, _⟩ := he
    exact absurd ⟨h₁, h₂⟩ (hp.boundaries_distinct m m' b hne)
  | failSubstrate c =>
    obtain ⟨p, _, hsub, _⟩ := he
    rw [hp.no_substrate p] at hsub
    cases hsub
  | mutate p =>
    have hbadp : ∀ q, (q = p ∨ s.st.bad q) → JPresent sys (jeffect sys s (.mutate p)) q := by
      intro q hq
      rcases hq with hq | hq
      · exact present_same rfl rfl (hq ▸ he.1)
      · exact present_same rfl rfl (h.badp q hq)
    cases p with
    | inl z =>
      refine ⟨z :: ts, Nat.le_refl _,
        ⟨⟨s', hs', hA, hJ⟩, ?_, hbadp, h.hidden, h.off, h.flagged, h.halted, h.pending⟩⟩
      intro m hm
      have hmz : m ≠ z := fun e => hm (e ▸ List.mem_cons_self)
      have hmt : m ∉ ts := fun h' => hm (List.mem_cons_of_mem _ h')
      refine ⟨?_, (h.good m hmt).2⟩
      rintro (h' | h')
      · exact hmz (Sum.inl.inj h')
      · exact (h.good m hmt).1 h'
    | inr x =>
      refine ⟨ts, Nat.le_succ _,
        ⟨⟨s', hs', hA, hJ⟩, ?_, hbadp, h.hidden, h.off, h.flagged, h.halted, h.pending⟩⟩
      intro m hm
      refine ⟨?_, (h.good m hm).2⟩
      rintro (h' | h')
      · cases h'
      · exact (h.good m hm).1 h'
  | disable m => exact absurd he.2.1 (hp.no_switch m)
  | join =>
    have he' : JEnabled sys s' .join := by
      refine ⟨he.1, he.2.1, ?_⟩
      rw [hJ]
      exact he.2.2
    refine ⟨ts, Nat.le_succ _,
      ⟨⟨jeffect sys s' .join, JoinsReach.join hs' he', hA, rfl⟩, ?_,
        fun p hb => present_join (h.badp p hb),
        h.hidden, h.off, h.flagged, h.halted, h.pending⟩⟩
    intro m hm
    exact ⟨(h.good m hm).1, fun hpr => Or.inl ((h.good m hm).2 hpr)⟩
  | joinGroup g =>
    refine ⟨ts, Nat.le_succ _,
      ⟨shadow_group g hs' hA hJ he, ?_,
        fun p hb => present_joinEffect g (h.badp p hb),
        h.hidden, h.off, h.flagged, h.halted, h.pending⟩⟩
    intro m hm
    exact ⟨(h.good m hm).1, alive_joinEffect g (h.good m hm).2⟩
  | joinBad g z =>
    refine ⟨z :: ts, Nat.le_refl _,
      ⟨shadow_group g hs' hA hJ he.2.1, ?_, ?_,
        h.hidden, h.off, h.flagged, h.halted, h.pending⟩⟩
    · intro m hm
      have hmz : m ≠ z := fun e => hm (e ▸ List.mem_cons_self)
      have hmt : m ∉ ts := fun h' => hm (List.mem_cons_of_mem _ h')
      refine ⟨?_, alive_joinEffect g (h.good m hmt).2⟩
      rintro (h' | h')
      · exact hmz (Sum.inl.inj h')
      · exact (h.good m hmt).1 h'
    · intro q hq
      have hq' : q = .inl z ∨ s.st.bad q := hq
      refine present_same (s := joinEffect sys s g) rfl rfl ?_
      rcases hq' with hq' | hq'
      · rw [hq']
        intro k hk
        have hgz : sys.group z = some g := he.2.2
        rw [hgz] at hk
        cases hk
        exact Or.inl rfl
      · exact present_joinEffect g (h.badp q hq')

/-- A run of environment steps of a system that is plain with joins touches at most as
many monitors as it has steps. -/
theorem jenv_run {sys : JSystem M W B S G} (hp : PlainJ sys) {s s₁ : JState M W G}
    {es : List (JStep M W B S G)} (hrun : JEnvRun sys s es s₁) :
    ∀ ts, JEnv sys s ts → ∃ ts', ts'.length ≤ ts.length + es.length ∧ JEnv sys s₁ ts' := by
  induction hrun with
  | nil s =>
    intro ts h
    exact ⟨ts, Nat.le_refl _, h⟩
  | cons he _ ih =>
    intro ts h
    obtain ⟨ts₁, hl₁, h₁⟩ := jenv_step hp he h
    obtain ⟨ts₂, hl₂, h₂⟩ := ih ts₁ h₁
    refine ⟨ts₂, ?_, h₂⟩
    simp only [List.length_cons]
    omega

/-! #### Quiet states -/

/-- A state in which nothing has happened but joins: the groups that have joined and the
joining of the joiner are those of a state that joins alone reach, every present monitor
is alive, and nothing is bad, hidden, off, flagged, halted or pending. -/
structure QuietJ (sys : JSystem M W B S G) (s : JState M W G) : Prop where
  shadow : ∃ s', JoinsReach sys s' ∧ s'.arrived = s.arrived ∧ s'.st.joined = s.st.joined
  alive : ∀ m, JPresent sys s (.inl m) → s.st.alive (.inl m)
  bad : ∀ p, ¬ s.st.bad p
  hidden : ∀ p, ¬ s.st.hidden p
  off : ∀ m, ¬ s.st.off m
  flagged : ∀ m, ¬ s.st.flagged m
  halted : ∀ w, ¬ s.st.halted w
  pending : ∀ w, ¬ s.st.pending w

theorem quietJ_init (sys : JSystem M W B S G) : QuietJ sys (jinit sys) where
  shadow := ⟨jinit sys, JoinsReach.init, rfl, rfl⟩
  alive := by
    intro m hpr
    show sys.group m = none
    cases hgm : sys.group m with
    | none => rfl
    | some g => exact False.elim (hpr g hgm)
  bad := fun _ h => h
  hidden := fun _ h => h
  off := fun _ h => h
  flagged := fun _ h => h
  halted := fun _ h => h
  pending := fun _ h => h

theorem jenv_of_quiet {sys : JSystem M W B S G} {s : JState M W G} (hq : QuietJ sys s) :
    JEnv sys s [] where
  shadow := hq.shadow
  good := fun m _ => ⟨hq.bad _, hq.alive m⟩
  badp := fun p hb => absurd hb (hq.bad p)
  hidden := hq.hidden
  off := hq.off
  flagged := hq.flagged
  halted := hq.halted
  pending := hq.pending

/-! #### The other two phases -/

/-- An edge that is not slow is in force when both its ends are present. -/
theorem inForce {sys : JSystem M W B S G} (s s₁ : JState M W G) {p q : Proc M W}
    {slow : Prop} (hns : ¬ slow) (hp : JPresent sys s₁ p) (hq : JPresent sys s₁ q) :
    InForce sys s s₁ p q slow :=
  ⟨hp, hq, fun h => absurd h hns⟩

/-- `MeshRate.finish` for the gate order with no window, in any system: if, after the
monitor phase, `out` is not empty and holds a halt input of every present work process,
the round violates neither goal and ends in a responded state. -/
theorem finish_present {sys : System M W B S} (hg : sys.gate = true) (hw : sys.window = 0)
    {s₁ : State M W} (hh : ∀ w, ¬ s₁.halted w)
    (hout : ∃ m, Out (monitorPhase sys s₁) m)
    (hhalt : ∀ w, Present sys s₁ (.inr w) →
      ∃ h, sys.haltInputs w h ∧ Out (monitorPhase sys s₁) h) :
    (¬ (afterEnv sys s₁).g1 ∧ ¬ (afterEnv sys s₁).g2) ∧
      Responded sys (afterEnv sys s₁).next := by
  rw [MeshRate.afterEnv_gate hg]
  have hsees : ∀ w, Present sys s₁ (.inr w) →
      Sees sys (monitorPhase sys s₁) (Out (monitorPhase sys s₁)) w := by
    intro w hpres
    obtain ⟨h, hin, ho⟩ := hhalt w hpres
    exact Or.inl ⟨h, hin, ho⟩
  refine ⟨⟨fun h => h.2 hout, ?_⟩, ?_, ?_⟩
  · rintro ⟨_, w, hwk⟩
    exact hwk.2.2 ⟨hsees w hwk.1.1, hw⟩
  · obtain ⟨m, hm⟩ := hout
    exact ⟨m, hm⟩
  · intro w hpres
    exact Or.inr ⟨⟨hpres, hh w⟩, Or.inr ⟨hsees w hpres, hw⟩⟩

/-- If, after the environment phase, every present monitor is alive and nothing is bad,
the other two phases change nothing: the round violates neither goal and ends quiet. -/
theorem clean_stays {sys : JSystem M W B S G} (hp : PlainJ sys) (s : JState M W G)
    {s₁ : JState M W G} {ts : List M} (henv : JEnv sys s₁ ts)
    (halive : ∀ m, JPresent sys s₁ (.inl m) → s₁.st.alive (.inl m))
    (hbad : ∀ p, ¬ s₁.st.bad p) :
    (¬ (jafterEnv sys s s₁).g1 ∧ ¬ (jafterEnv sys s s₁).g2) ∧
      QuietJ sys (jafterEnv sys s s₁).next := by
  have hnoflag : ∀ m, ¬ flaggedAfter (effective sys s s₁) s₁.st m := by
    intro m hm
    rw [MeshRate.flaggedAfter_fast (sys := effective sys s s₁) hp.reports_fast] at hm
    refine MeshRate.spread_empty (fun m hm => ?_) m hm
    rcases hm with h | h
    · exact henv.flagged m h
    · obtain ⟨_, ⟨x, hx, _⟩ | ⟨p, hp', _, hin⟩⟩ := h
      · exact hbad x hx.1
      · exact hp' (halive p hin.1)
  have hnosee : ∀ w, ¬ Sees (effective sys s s₁) (monitorPhase (effective sys s s₁) s₁.st)
      (Out (monitorPhase (effective sys s s₁) s₁.st)) w := by
    rintro w (⟨m, _, hm⟩ | ⟨_, m, ⟨_, hin⟩, hm⟩)
    · exact hnoflag m hm.1
    · exact hm (halive m hin.2.1)
  show (¬ (afterEnv (effective sys s s₁) s₁.st).g1 ∧
      ¬ (afterEnv (effective sys s s₁) s₁.st).g2) ∧
    QuietJ sys ⟨(afterEnv (effective sys s s₁) s₁.st).next, s₁.arrived⟩
  rw [MeshRate.afterEnv_gate (sys := effective sys s s₁) hp.gate_on]
  refine ⟨⟨fun h => ?_, fun h => ?_⟩, ?_⟩
  · obtain ⟨p, hp'⟩ := h.1
    exact hbad p hp'
  · obtain ⟨p, hp'⟩ := h.1
    exact hbad p hp'
  · refine ⟨henv.shadow, halive, hbad, henv.hidden, henv.off, hnoflag, ?_, ?_⟩
    · rintro w (h | ⟨_, h | ⟨h, _⟩⟩)
      · exact henv.halted w h
      · exact henv.pending w h
      · exact hnosee w h
    · rintro w (⟨h, _⟩ | ⟨_, _, h, _⟩)
      · exact henv.pending w h
      · exact hnosee w h

/-- Let `a` be present, alive, not bad and not flagged after the monitor phase. Then so is
every monitor reached from `a` through pairs of present monitors. If `b` is such a monitor
and `c` is present and paired with it, then `c` is alive and not bad, or `b` would detect;
and `c` is not flagged, or its flag would reach `b`. Every edge used is between two
present monitors and is not slow, so it is in force. -/
theorem linked_clean {sys : JSystem M W B S G} (hp : PlainJ sys) (s : JState M W G)
    {s₁ : JState M W G} {ts : List M} (henv : JEnv sys s₁ ts) {P : M → Prop}
    (hP : ∀ m, P m → JPresent sys s₁ (.inl m)) {a b : M}
    (h : LinkedIn sys.base P a b) :
    (JPresent sys s₁ (.inl a) ∧ s₁.st.alive (.inl a) ∧ ¬ s₁.st.bad (.inl a) ∧
        ¬ Spread (effective sys s s₁) s₁.st
          (FlaggedOrDetects (effective sys s s₁) s₁.st) a) →
      (JPresent sys s₁ (.inl b) ∧ s₁.st.alive (.inl b) ∧ ¬ s₁.st.bad (.inl b) ∧
        ¬ Spread (effective sys s s₁) s₁.st
          (FlaggedOrDetects (effective sys s s₁) s₁.st) b) := by
  induction h with
  | refl => exact id
  | @step b c _ hPc hbc ih =>
    intro ha
    obtain ⟨hbp, hba, hbb, hbf⟩ := ih ha
    have hcp : JPresent sys s₁ (.inl c) := hP c hPc
    have hactb : Active s₁.st b := ⟨hba, hbb, henv.off b⟩
    have hca : s₁.st.alive (.inl c) := Classical.byContradiction fun hna =>
      hbf (Spread.base (Or.inr ⟨hactb,
        Or.inr ⟨c, hna, hbc.1.2, inForce s s₁ (hp.no_slow.1 c b) hcp hbp⟩⟩))
    have hcb : ¬ s₁.st.bad (.inl c) := fun hbad =>
      hbf (Spread.base (Or.inr ⟨hactb,
        Or.inl ⟨.inl c, ⟨hbad, henv.hidden _⟩, hbc.1.1,
          inForce s s₁ (hp.no_slow.2.1 (.inl c) b) hcp hbp⟩⟩))
    exact ⟨hcp, hca, hcb, fun hcf =>
      hbf (Spread.step hcf ⟨hca, hcb, henv.off c⟩
        ⟨hbc.2.2.2, inForce s s₁ (hp.no_slow.2.2.1 c b) hcp hbp⟩ hactb)⟩

/-- The conditions answer the environment: if, after the environment phase of a round from
a quiet state, some present monitor is not alive or some present process is bad, then
after the monitor phase `out` is not empty and holds a halt input, in force, of every
present work process. -/
theorem answered {sys : JSystem M W B S G} (hp : PlainJ sys)
    (hs : SufficientJoins sys sys.base.f) (s : JState M W G) {s₁ : JState M W G}
    {ts : List M} (hl : ts.length ≤ sys.base.f) (henv : JEnv sys s₁ ts)
    (htouched : (∃ m, JPresent sys s₁ (.inl m) ∧ ¬ s₁.st.alive (.inl m)) ∨
      ∃ p, JPresent sys s₁ p ∧ s₁.st.bad p) :
    (∃ m, Out (monitorPhase (effective sys s s₁) s₁.st) m) ∧
      ∀ w, JPresent sys s₁ (.inr w) →
        ∃ h, (effective sys s s₁).haltInputs w h ∧
          Out (monitorPhase (effective sys s s₁) s₁.st) h := by
  obtain ⟨s', hs', hA, hJ⟩ := henv.shadow
  -- The state kept beside has the same present processes.
  have pres : ∀ p, JPresent sys s' p → JPresent sys s₁ p := fun p =>
    (present_congr sys hA hJ p).1
  have pres' : ∀ p, JPresent sys s₁ p → JPresent sys s' p := fun p =>
    (present_congr sys hA hJ p).2
  -- Every present monitor that no step touched is flagged after the monitor phase.
  have hall : ∀ m, m ∉ ts → JPresent sys s₁ (.inl m) →
      Spread (effective sys s s₁) s₁.st (FlaggedOrDetects (effective sys s s₁) s₁.st) m := by
    intro m hm hmp
    apply Classical.byContradiction
    intro hnf
    -- If not, every present monitor is alive, not bad and not flagged.
    have clean : ∀ b, JPresent sys s₁ (.inl b) →
        s₁.st.alive (.inl b) ∧ ¬ s₁.st.bad (.inl b) ∧
          ¬ Spread (effective sys s s₁) s₁.st
            (FlaggedOrDetects (effective sys s s₁) s₁.st) b := fun b hb =>
      (linked_clean hp s henv (fun c hc => pres (.inl c) hc)
        (hs.linked s' hs' m b (pres' _ hmp) (pres' _ hb))
        ⟨hmp, (henv.good m hm).2 hmp, (henv.good m hm).1, hnf⟩).2
    rcases htouched with ⟨z, hz, hna⟩ | ⟨x, hxp, hx⟩
    · exact hna (clean z hz).1
    · cases x with
      | inl z => exact (clean z hxp).2.1 hx
      | inr w =>
        -- A present work process is bad: its present state checker is active and detects.
        obtain ⟨k, hkp, hk⟩ := (hs.work s' hs' w (pres' _ hxp)).1
        have hkp₁ : JPresent sys s₁ (.inl k) := pres _ hkp
        exact (clean k hkp₁).2.2 (Spread.base (Or.inr
          ⟨⟨(clean k hkp₁).1, (clean k hkp₁).2.1, henv.off k⟩,
            Or.inl ⟨.inr w, ⟨hx, henv.hidden _⟩, hk,
              inForce s s₁ (hp.no_slow.2.1 (.inr w) k) hxp hkp₁⟩⟩))
  have hout : ∀ m, m ∉ ts → JPresent sys s₁ (.inl m) →
      Out (monitorPhase (effective sys s s₁) s₁.st) m := fun m hm hmp =>
    ⟨(MeshRate.flaggedAfter_fast (sys := effective sys s s₁) hp.reports_fast s₁.st m).2
        (hall m hm hmp),
      (henv.good m hm).2 hmp, (henv.good m hm).1⟩
  refine ⟨?_, fun w hw => ?_⟩
  · -- More than `f` initial monitors: one was touched by no step, and it is present.
    obtain ⟨ms, hnd, hlen, hinit⟩ := hs.monitors
    obtain ⟨r, hr, hrt⟩ := MeshRate.exists_not_mem ms ts hnd (Nat.lt_of_le_of_lt hl hlen)
    refine ⟨r, hout r hrt ?_⟩
    intro g hg
    rw [hinit r hr] at hg
    cases hg
  · -- More than `f` present halt inputs: one was touched by no step.
    obtain ⟨_, hs'', hnd, hlen, hin⟩ := hs.work s' hs' w (pres' _ hw)
    obtain ⟨h, hh, hht⟩ := MeshRate.exists_not_mem hs'' ts hnd (Nat.lt_of_le_of_lt hl hlen)
    have hhp : JPresent sys s₁ (.inl h) := pres _ (hin h hh).2
    exact ⟨h, ⟨(hin h hh).1, inForce s s₁ (hp.no_slow.2.2.2 w h) hw hhp⟩, hout h hht hhp⟩

/-! #### The invariant -/

/-- One round from a quiet state violates neither goal, and ends quiet or responded. -/
theorem round_from_quiet {sys : JSystem M W B S G} (hp : PlainJ sys)
    (hs : SufficientJoins sys sys.base.f) {s : JState M W G} (hq : QuietJ sys s)
    {r : JOutcome M W G} (hr : JRound sys s r) :
    (¬ r.g1 ∧ ¬ r.g2) ∧ (QuietJ sys r.next ∨ JResponded sys r.next) := by
  obtain ⟨steps, s₁, hl, hrun, rfl⟩ := hr
  obtain ⟨ts, hlts, henv⟩ := jenv_run hp hrun [] (jenv_of_quiet hq)
  simp only [List.length_nil, Nat.zero_add] at hlts
  rcases Classical.em ((∀ m, JPresent sys s₁ (.inl m) → s₁.st.alive (.inl m)) ∧
      ∀ p, ¬ s₁.st.bad p) with ⟨halive, hbad⟩ | hnot
  · -- No step left a mark: nothing changes.
    have := clean_stays hp s henv halive hbad
    exact ⟨this.1, Or.inl this.2⟩
  · -- Some present monitor is not alive, or some process, which is present, is bad.
    have htouched : (∃ m, JPresent sys s₁ (.inl m) ∧ ¬ s₁.st.alive (.inl m)) ∨
        ∃ p, JPresent sys s₁ p ∧ s₁.st.bad p := by
      apply Classical.byContradiction
      intro hno
      exact hnot ⟨fun m hm => Classical.byContradiction fun hna => hno (Or.inl ⟨m, hm, hna⟩),
        fun p hb => hno (Or.inr ⟨p, henv.badp p hb, hb⟩)⟩
    obtain ⟨hout, hhalt⟩ := answered hp hs s (Nat.le_trans hlts hl) henv htouched
    have := finish_present (sys := effective sys s s₁) hp.gate_on hp.no_window
      henv.halted hout hhalt
    exact ⟨this.1, Or.inr this.2⟩

/-- Every state an execution reaches is quiet or responded. -/
theorem reachable_quiet_or_responded {sys : JSystem M W B S G} (hp : PlainJ sys)
    (hs : SufficientJoins sys sys.base.f) {s : JState M W G} (h : JReachable sys s) :
    QuietJ sys s ∨ JResponded sys s := by
  induction h with
  | init => exact Or.inl (quietJ_init sys)
  | round _ hnr hround ih =>
    rcases ih with hq | hresp
    · exact (round_from_quiet hp hs hq hround).2
    · exact absurd hresp hnr

end Joins

/-- Theorem J, with joins. A system that is plain with joins has no gap at `f` faults per
round if, in every set of present processes the joins can reach, the present monitors are
connected by pairs that watch each other and report to each other and every present work
process has a present state checker and more than `f` present halt inputs, and there are
more than `f` initial monitors. Monitors may or may not arrive bad. -/
theorem theorem_J_joins {G : Type} (sys : JSystem M W B S G) (hp : PlainJ sys)
    (hs : SufficientJoins sys sys.base.f) : JNoGap sys := by
  intro s r hreach hnr hround
  rcases reachable_quiet_or_responded hp hs hreach with hq | hresp
  · exact (round_from_quiet hp hs hq hround).1
  · exact absurd hresp hnr

end JoinConnected
end SelfObserving
