/-
Theorem L, layered growth (`results-join.md`, section 3), for the model with monitors that
join (`Join.lean`).

It is proved by the invariant of Theorem S and of `MeshRate.lean`: every state an execution
reaches is clean or responded. A state is clean (`Mid` and `Clean` below) if it has the
arrived groups of a state that joins alone reach, every present monitor is alive and every
alive monitor is present, and nothing is bad, hidden, off, flagged, halted or pending.

A round from a clean state `s` takes at most `f` environment steps. In a system of
`GrownClass` with no switch, only `stop`, `mutate`, `join g` and `join-bad g m` are ever
enabled. Along the environment phase `Mid` is kept. If the phase ends clean, the other two
phases change nothing. If it does not, then either

1. some process of `small` (an initial monitor or a work process) is faulty. The steps of
   the phase on processes of `small` are an environment phase of `small` from its initial
   state (`Agree`, `agree_run`), not empty and no longer than `f`, so `small` answers it
   with a complete response (`AnswersFaults`). Every edge of `small` is in force in `sys`,
   so every flag and every reason to halt of `small` is one of `sys` (`answer_small`); or
2. no process of `small` is faulty, and some present late monitor is. The one of least
   rank is detected by its state checker or its signal reader, which are of lower rank or
   initial, and so active. The flag climbs down the ranks along report targets to an
   initial monitor, and from there, all initial monitors being active, to a halt input of
   every work process (`FlagReachesWork`, `answer_late`).

In both cases `out` is not empty and every work process sees a reason to halt: the round
violates neither goal and ends responded.
-/
import SelfObserving.JoinConditions
import SelfObserving.Proofs.MeshRate

namespace SelfObserving
namespace JoinLayered

variable {M W B S : Type}

section

variable {G M₀ B₀ S₀ : Type} {sys : JSystem M W B S G} {small : System M₀ W B₀ S₀}
  {ι : M₀ → M} {β : B₀ → B} {σ : S₀ → S} {rank : M → Nat} {chk rdr tgt : M → M}

/-! ### Presence -/

/-- With no joiner, every non-monitor process is present in every state. -/
theorem present_work (hg : GrownClass sys) (s : JState M W G) (w : W) :
    JPresent sys s (.inr w) := by
  intro h
  have h' : sys.base.joiner = some w := h
  rw [hg.no_joiner] at h'
  cases h'

/-- An initial monitor is present in every state. -/
theorem present_initial (hi : InitialPart sys small ι β σ) (s : JState M W G) (a : M₀) :
    JPresent sys s (.inl (ι a)) := by
  intro g h
  rw [(hi.initial (ι a)).2 ⟨a, rfl⟩] at h
  cases h

/-- A monitor that is not late is a monitor of `small`. -/
theorem initial_of_not_late (hi : InitialPart sys small ι β σ) {m : M} (h : ¬ sys.Late m) :
    ∃ a, ι a = m :=
  (hi.initial m).1 (Classical.byContradiction h)

/-- A late monitor is not a monitor of `small`. -/
theorem late_ne_initial (hi : InitialPart sys small ι β σ) {m : M} (h : sys.Late m) (a : M₀) :
    ι a ≠ m :=
  fun e => h ((hi.initial m).2 ⟨a, e⟩)

/-- Which monitors are present depends on the arrived groups only. -/
theorem present_of_arrived {q c : JState M W G} (h : q.arrived = c.arrived) (m : M) :
    JPresent sys q (.inl m) ↔ JPresent sys c (.inl m) := by
  show (∀ g, sys.group m = some g → q.arrived g) ↔ (∀ g, sys.group m = some g → c.arrived g)
  rw [h]

/-- An edge between two initial monitors is in force in every round, slow or not: neither
end is new. -/
theorem inForce_mon (hi : InitialPart sys small ι β σ) (s c : JState M W G) (a b : M₀)
    (slow : Prop) : InForce sys s c (.inl (ι a)) (.inl (ι b)) slow :=
  ⟨present_initial hi c a, present_initial hi c b,
    fun _ => ⟨fun h => h.2 (present_initial hi s a), fun h => h.2 (present_initial hi s b)⟩⟩

/-- An edge between a work process and an initial monitor is in force in every round. -/
theorem inForce_work (hi : InitialPart sys small ι β σ) (hg : GrownClass sys)
    (s c : JState M W G) (w : W) (b : M₀) (slow : Prop) :
    InForce sys s c (.inr w) (.inl (ι b)) slow :=
  ⟨present_work hg c w, present_initial hi c b,
    fun _ => ⟨fun h => h.2 (present_work hg s w), fun h => h.2 (present_initial hi s b)⟩⟩

/-! ### The environment phase -/

/-- In a system of `GrownClass` with no switch, an enabled step is `stop`, `mutate`,
`join g` or `join-bad g m`. -/
theorem step_kind (hg : GrownClass sys) (hsw : ∀ m, ¬ sys.base.switches m)
    {c : JState M W G} {e : JStep M W B S G} (he : JEnabled sys c e) :
    (∃ m, e = .stop m) ∨ (∃ p, e = .mutate p) ∨ (∃ g, e = .joinGroup g) ∨
      ∃ g m, e = .joinBad g m := by
  cases e with
  | stop m => exact Or.inl ⟨m, rfl⟩
  | stopBoundary b =>
    obtain ⟨⟨m, m', hne, h₁, h₂, _⟩, _⟩ := he
    exact absurd ⟨h₁, h₂⟩ (hg.boundaries_distinct m m' b hne)
  | failSubstrate c' =>
    obtain ⟨p, _, hsub, _⟩ := he
    rw [hg.no_substrate p] at hsub
    cases hsub
  | mutate p => exact Or.inr (Or.inl ⟨p, rfl⟩)
  | disable m => exact absurd he.2.1 (hsw m)
  | join => exact absurd hg.no_joiner he.1
  | joinGroup g => exact Or.inr (Or.inr (Or.inl ⟨g, rfl⟩))
  | joinBad g m => exact Or.inr (Or.inr (Or.inr ⟨g, m, rfl⟩))

/-- What holds during the environment phase of a round that starts clean, and in every
clean state. The arrived groups are those of a state that joins alone reach. Every alive
monitor and every bad monitor is present. Nothing is hidden, off, flagged, halted or
pending. -/
structure Mid (sys : JSystem M W B S G) (c : JState M W G) : Prop where
  reach : ∃ q, JoinsReach sys q ∧ q.arrived = c.arrived
  alive_present : ∀ m, c.st.alive (.inl m) → JPresent sys c (.inl m)
  bad_present : ∀ m, c.st.bad (.inl m) → JPresent sys c (.inl m)
  hidden : ∀ p, ¬ c.st.hidden p
  off : ∀ m, ¬ c.st.off m
  flagged : ∀ m, ¬ c.st.flagged m
  halted : ∀ w, ¬ c.st.halted w
  pending : ∀ w, ¬ c.st.pending w

/-- No fault: every present monitor is alive, and nothing is bad. -/
def Clean (sys : JSystem M W B S G) (c : JState M W G) : Prop :=
  (∀ m, JPresent sys c (.inl m) → c.st.alive (.inl m)) ∧ ∀ p, ¬ c.st.bad p

theorem mid_init (sys : JSystem M W B S G) : Mid sys (jinit sys) where
  reach := ⟨jinit sys, JoinsReach.init, rfl⟩
  alive_present := by
    intro m h g hg
    have h' : sys.group m = none := h
    rw [h'] at hg
    cases hg
  bad_present := fun _ h => h.elim
  hidden := fun _ h => h
  off := fun _ h => h
  flagged := fun _ h => h
  halted := fun _ h => h
  pending := fun _ h => h

theorem clean_init (sys : JSystem M W B S G) : Clean sys (jinit sys) := by
  refine ⟨?_, fun _ h => h⟩
  intro m h
  show sys.group m = none
  cases hgm : sys.group m with
  | none => rfl
  | some g => exact (h g hgm).elim

/-- A group's step keeps the arrived groups those of a state that joins alone reach. -/
theorem reach_join (hg : GrownClass sys) {c : JState M W G} {g : G}
    (hr : ∃ q, JoinsReach sys q ∧ q.arrived = c.arrived) (he : JoinEnabled sys c g) :
    ∃ q, JoinsReach sys q ∧ q.arrived = (joinEffect sys c g).arrived := by
  obtain ⟨q, hq, harr⟩ := hr
  have hen : JoinEnabled sys q g := by
    refine ⟨?_, ?_⟩
    · rw [harr]
      exact he.1
    · intro p hp
      cases p with
      | inl m => exact (present_of_arrived harr m).2 (he.2 _ hp)
      | inr w => exact present_work hg q w
  refine ⟨jeffect sys q (.joinGroup g), JoinsReach.group g hq hen, ?_⟩
  show (fun h => h = g ∨ q.arrived h) = (fun h => h = g ∨ c.arrived h)
  rw [harr]

/-- A present monitor stays present when a group joins. -/
theorem present_mono (c : JState M W G) (g : G) (m : M) (h : JPresent sys c (.inl m)) :
    JPresent sys (joinEffect sys c g) (.inl m) :=
  fun g' hg' => Or.inr (h g' hg')

/-- A member of a group is present once the group has joined. -/
theorem present_member (c : JState M W G) (g : G) (m : M) (h : sys.group m = some g) :
    JPresent sys (joinEffect sys c g) (.inl m) := by
  intro g' hg'
  rw [h] at hg'
  exact Or.inl (Option.some.inj hg').symm

/-- One enabled step keeps `Mid`. -/
theorem mid_step (hg : GrownClass sys) (hsw : ∀ m, ¬ sys.base.switches m)
    {c : JState M W G} {e : JStep M W B S G} (h : Mid sys c) (he : JEnabled sys c e) :
    Mid sys (jeffect sys c e) := by
  rcases step_kind hg hsw he with ⟨m, rfl⟩ | ⟨p, rfl⟩ | ⟨g, rfl⟩ | ⟨g, m, rfl⟩
  · exact ⟨h.reach, fun m' hm' => h.alive_present m' hm'.1, h.bad_present, h.hidden, h.off,
      h.flagged, h.halted, h.pending⟩
  · refine ⟨h.reach, h.alive_present, ?_, h.hidden, h.off, h.flagged, h.halted, h.pending⟩
    intro m' hm'
    rcases hm' with hm' | hm'
    · rw [← hm'] at he
      exact he.1
    · exact h.bad_present m' hm'
  · refine ⟨reach_join hg h.reach he, ?_,
      fun m' hm' => present_mono c g m' (h.bad_present m' hm'), h.hidden, h.off, h.flagged,
      h.halted, h.pending⟩
    intro m' hm'
    rcases hm' with hm' | hm'
    · exact present_mono c g m' (h.alive_present m' hm')
    · exact present_member c g m' hm'
  · refine ⟨reach_join hg h.reach he.2.1, ?_, ?_, h.hidden, h.off, h.flagged, h.halted,
      h.pending⟩
    · intro m' hm'
      rcases hm' with hm' | hm'
      · exact present_mono c g m' (h.alive_present m' hm')
      · exact present_member c g m' hm'
    · intro m' hm'
      rcases hm' with hm' | hm'
      · rw [Sum.inl.inj hm']
        exact present_member c g m he.2.2
      · exact present_mono c g m' (h.bad_present m' hm')

/-- A run of environment steps keeps `Mid`. -/
theorem mid_run (hg : GrownClass sys) (hsw : ∀ m, ¬ sys.base.switches m)
    {c c₁ : JState M W G} {es : List (JStep M W B S G)} (hrun : JEnvRun sys c es c₁) :
    Mid sys c → Mid sys c₁ := by
  induction hrun with
  | nil _ => exact id
  | cons he _ ih => exact fun h => ih (mid_step hg hsw h he)

/-! ### The other two phases -/

/-- The flags after the monitor phase of the round that starts in `s` and whose environment
phase ends in `c`, when reports arrive within the round. -/
abbrev Flag (sys : JSystem M W B S G) (s c : JState M W G) (m : M) : Prop :=
  Spread (effective sys s c) c.st (FlaggedOrDetects (effective sys s c) c.st) m

/-- A monitor that the spread reaches, alive and not bad, is in `out` after the monitor
phase. -/
theorem out_of_flag (hg : GrownClass sys) (s : JState M W G) {c : JState M W G} {m : M}
    (hf : Flag sys s c m) (ha : c.st.alive (.inl m)) (hb : ¬ c.st.bad (.inl m)) :
    Out (monitorPhase (effective sys s c) c.st) m :=
  ⟨(MeshRate.flaggedAfter_fast (sys := effective sys s c) hg.reports_fast c.st m).2 hf, ha, hb⟩

/-- `MeshRate.finish`, for any system with the gate and no window, and with the reasons to
halt as `Sees` gives them: if, after the monitor phase, `out` is not empty and every work
process sees a reason to halt, the round violates neither goal and ends responded. -/
theorem finish {sys : System M W B S} (hgate : sys.gate = true) (hwin : sys.window = 0)
    {s₁ : State M W} (hh : ∀ w, ¬ s₁.halted w)
    (hout : ∃ m, Out (monitorPhase sys s₁) m)
    (hsees : ∀ w, Sees sys (monitorPhase sys s₁) (Out (monitorPhase sys s₁)) w) :
    (¬ (afterEnv sys s₁).g1 ∧ ¬ (afterEnv sys s₁).g2) ∧
      Responded sys (afterEnv sys s₁).next := by
  rw [MeshRate.afterEnv_gate hgate]
  refine ⟨⟨fun h => h.2 hout, ?_⟩, ?_, ?_⟩
  · rintro ⟨_, w, hw⟩
    exact hw.2.2 ⟨hsees w, hwin⟩
  · obtain ⟨m, hm⟩ := hout
    exact ⟨m, hm⟩
  · intro w hpres
    exact Or.inr ⟨⟨hpres, hh w⟩, Or.inr ⟨hsees w, hwin⟩⟩

/-- A round whose environment phase ends in `c` with `out` not empty and every work process
seeing a reason to halt violates neither goal and ends responded. -/
theorem answered_round (hg : GrownClass sys) (s : JState M W G) {c : JState M W G}
    (hm : Mid sys c)
    (hout : ∃ m, Out (monitorPhase (effective sys s c) c.st) m)
    (hsees : ∀ w, Sees (effective sys s c) (monitorPhase (effective sys s c) c.st)
      (Out (monitorPhase (effective sys s c) c.st)) w) :
    (¬ (jafterEnv sys s c).g1 ∧ ¬ (jafterEnv sys s c).g2) ∧
      JResponded sys (jafterEnv sys s c).next :=
  finish (sys := effective sys s c) hg.gate_on hg.no_window hm.halted hout hsees

/-- A round whose environment phase ends clean violates neither goal and ends clean. -/
theorem clean_stays (hg : GrownClass sys) (s : JState M W G) {c : JState M W G}
    (hm : Mid sys c) (hc : Clean sys c) :
    (¬ (jafterEnv sys s c).g1 ∧ ¬ (jafterEnv sys s c).g2) ∧
      Mid sys (jafterEnv sys s c).next ∧ Clean sys (jafterEnv sys s c).next := by
  have hfast : (effective sys s c).slowReports = false := hg.reports_fast
  have hgate : (effective sys s c).gate = true := hg.gate_on
  -- No monitor detects: nothing is bad, and a monitor whose signal is read in force is
  -- present, so alive.
  have hnoflag : ∀ m, ¬ flaggedAfter (effective sys s c) c.st m := by
    intro m hm'
    rw [MeshRate.flaggedAfter_fast hfast] at hm'
    refine MeshRate.spread_empty (fun m hm' => ?_) m hm'
    rcases hm' with h | h
    · exact hm.flagged m h
    · obtain ⟨_, ⟨x, hx, _⟩ | ⟨p, hp', hrd⟩⟩ := h
      · exact hc.2 x hx.1
      · exact hp' (hc.1 p hrd.2.1)
  have hnosee : ∀ w, ¬ Sees (effective sys s c) (monitorPhase (effective sys s c) c.st)
      (Out (monitorPhase (effective sys s c) c.st)) w := by
    rintro w (⟨m, _, hm'⟩ | ⟨_, m, hin, hm'⟩)
    · exact hnoflag m hm'.1
    · exact hm' (hc.1 m hin.2.2.1)
  show (¬ (afterEnv (effective sys s c) c.st).g1 ∧ ¬ (afterEnv (effective sys s c) c.st).g2) ∧
    Mid sys ⟨(afterEnv (effective sys s c) c.st).next, c.arrived⟩ ∧
    Clean sys ⟨(afterEnv (effective sys s c) c.st).next, c.arrived⟩
  rw [MeshRate.afterEnv_gate hgate]
  refine ⟨⟨fun h => ?_, fun h => ?_⟩, ?_, ?_⟩
  · obtain ⟨p, hp'⟩ := h.1
    exact hc.2 p hp'
  · obtain ⟨p, hp'⟩ := h.1
    exact hc.2 p hp'
  · refine ⟨hm.reach, hm.alive_present, hm.bad_present, hm.hidden, hm.off, hnoflag, ?_, ?_⟩
    · rintro w (h | ⟨_, h | ⟨h, _⟩⟩)
      · exact hm.halted w h
      · exact hm.pending w h
      · exact hnosee w h
    · rintro w (⟨h, _⟩ | ⟨_, _, h, _⟩)
      · exact hm.pending w h
      · exact hnosee w h
  · exact ⟨hc.1, hc.2⟩

/-! ### Case 1: a process of `small` is faulty -/

/-- The state `c` of `sys` and the state `t` of `small` agree on the processes of `small`:
the same initial monitors are alive, the same initial monitors and work processes are bad.
In `t` nothing is hidden, off, flagged, halted or pending. -/
structure Agree (ι : M₀ → M) (c : JState M W G) (t : State M₀ W) : Prop where
  alive : ∀ a, c.st.alive (.inl (ι a)) ↔ t.alive (.inl a)
  bad_mon : ∀ a, c.st.bad (.inl (ι a)) ↔ t.bad (.inl a)
  bad_work : ∀ w, c.st.bad (.inr w) ↔ t.bad (.inr w)
  hidden : ∀ p, ¬ t.hidden p
  off : ∀ a, ¬ t.off a
  flagged : ∀ a, ¬ t.flagged a
  halted : ∀ w, ¬ t.halted w
  pending : ∀ w, ¬ t.pending w

/-- One enabled step of `sys` either leaves the processes of `small` as they were, or is a
step on a process of `small`, enabled in `small`, with the same effect on them. -/
theorem agree_step (hi : InitialPart sys small ι β σ) (hg : GrownClass sys)
    (hsw : ∀ m, ¬ sys.base.switches m) {c : JState M W G} {t : State M₀ W}
    {e : JStep M W B S G} (h : Agree ι c t) (he : JEnabled sys c e) :
    Agree ι (jeffect sys c e) t ∨
      ∃ e', Enabled small t e' ∧ Agree ι (jeffect sys c e) (effect small t e') := by
  rcases step_kind hg hsw he with ⟨m, rfl⟩ | ⟨p, rfl⟩ | ⟨g, rfl⟩ | ⟨g, m, rfl⟩
  · -- `stop m`
    rcases Classical.em (sys.Late m) with hl | hnl
    · refine Or.inl ⟨fun a => ?_, h.bad_mon, h.bad_work, h.hidden, h.off, h.flagged,
        h.halted, h.pending⟩
      constructor
      · rintro ⟨h₁, _⟩
        exact (h.alive a).1 h₁
      · intro h₁
        exact ⟨(h.alive a).2 h₁, fun e => late_ne_initial hi hl a (Sum.inl.inj e)⟩
    · obtain ⟨a, rfl⟩ := initial_of_not_late hi hnl
      refine Or.inr ⟨.stop a, (h.alive a).1 he.2, fun a' => ?_, h.bad_mon, h.bad_work,
        h.hidden, h.off, h.flagged, h.halted, h.pending⟩
      constructor
      · rintro ⟨h₁, h₂⟩
        exact ⟨(h.alive a').1 h₁, fun e => h₂ (by rw [Sum.inl.inj e])⟩
      · rintro ⟨h₁, h₂⟩
        exact ⟨(h.alive a').2 h₁,
          fun e => h₂ (congrArg Sum.inl (hi.inj _ _ (Sum.inl.inj e)))⟩
  · -- `mutate p`
    cases p with
    | inl m =>
      rcases Classical.em (sys.Late m) with hl | hnl
      · refine Or.inl ⟨h.alive, fun a => ?_, fun w => ?_, h.hidden, h.off, h.flagged,
          h.halted, h.pending⟩
        · constructor
          · rintro (h' | h')
            · exact absurd (Sum.inl.inj h') (late_ne_initial hi hl a)
            · exact (h.bad_mon a).1 h'
          · exact fun h' => Or.inr ((h.bad_mon a).2 h')
        · constructor
          · rintro (h' | h')
            · cases h'
            · exact (h.bad_work w).1 h'
          · exact fun h' => Or.inr ((h.bad_work w).2 h')
      · obtain ⟨a, rfl⟩ := initial_of_not_late hi hnl
        refine Or.inr ⟨.mutate (.inl a), ⟨trivial, fun hb => he.2 ((h.bad_mon a).2 hb)⟩,
          h.alive, fun a' => ?_, fun w => ?_, h.hidden, h.off, h.flagged, h.halted,
          h.pending⟩
        · constructor
          · rintro (h' | h')
            · exact Or.inl (congrArg Sum.inl (hi.inj _ _ (Sum.inl.inj h')))
            · exact Or.inr ((h.bad_mon a').1 h')
          · rintro (h' | h')
            · exact Or.inl (by rw [Sum.inl.inj h'])
            · exact Or.inr ((h.bad_mon a').2 h')
        · constructor
          · rintro (h' | h')
            · cases h'
            · exact Or.inr ((h.bad_work w).1 h')
          · rintro (h' | h')
            · cases h'
            · exact Or.inr ((h.bad_work w).2 h')
    | inr x =>
      have hpres : Present small t (.inr x) := by
        intro hj
        have hj' : small.joiner = some x := hj
        rw [← hi.joiner, hg.no_joiner] at hj'
        cases hj'
      refine Or.inr ⟨.mutate (.inr x), ⟨hpres, fun hb => he.2 ((h.bad_work x).2 hb)⟩,
        h.alive, fun a => ?_, fun w => ?_, h.hidden, h.off, h.flagged, h.halted, h.pending⟩
      · constructor
        · rintro (h' | h')
          · cases h'
          · exact Or.inr ((h.bad_mon a).1 h')
        · rintro (h' | h')
          · cases h'
          · exact Or.inr ((h.bad_mon a).2 h')
      · constructor
        · rintro (h' | h')
          · exact Or.inl (by rw [Sum.inr.inj h'])
          · exact Or.inr ((h.bad_work w).1 h')
        · rintro (h' | h')
          · exact Or.inl (by rw [Sum.inr.inj h'])
          · exact Or.inr ((h.bad_work w).2 h')
  · -- `join g`: no member of `g` is a monitor of `small`
    refine Or.inl ⟨fun a => ?_, h.bad_mon, h.bad_work, h.hidden, h.off, h.flagged, h.halted,
      h.pending⟩
    constructor
    · rintro (h' | h')
      · exact (h.alive a).1 h'
      · have h'' : sys.group (ι a) = some g := h'
        rw [(hi.initial (ι a)).2 ⟨a, rfl⟩] at h''
        cases h''
    · exact fun h' => Or.inl ((h.alive a).2 h')
  · -- `join-bad g m`: `m` is late
    have hl : sys.Late m := by
      intro hn
      have h' := he.2.2
      rw [hn] at h'
      cases h'
    refine Or.inl ⟨fun a => ?_, fun a => ?_, fun w => ?_, h.hidden, h.off, h.flagged,
      h.halted, h.pending⟩
    · constructor
      · rintro (h' | h')
        · exact (h.alive a).1 h'
        · have h'' : sys.group (ι a) = some g := h'
          rw [(hi.initial (ι a)).2 ⟨a, rfl⟩] at h''
          cases h''
      · exact fun h' => Or.inl ((h.alive a).2 h')
    · constructor
      · rintro (h' | h')
        · exact absurd (Sum.inl.inj h') (late_ne_initial hi hl a)
        · exact (h.bad_mon a).1 h'
      · exact fun h' => Or.inr ((h.bad_mon a).2 h')
    · constructor
      · rintro (h' | h')
        · cases h'
        · exact (h.bad_work w).1 h'
      · exact fun h' => Or.inr ((h.bad_work w).2 h')

/-- The steps of an environment run of `sys` that act on processes of `small` are, in
order, an environment run of `small`, no longer, that ends in agreement. -/
theorem agree_run (hi : InitialPart sys small ι β σ) (hg : GrownClass sys)
    (hsw : ∀ m, ¬ sys.base.switches m) {c c₁ : JState M W G} {es : List (JStep M W B S G)}
    (hrun : JEnvRun sys c es c₁) :
    ∀ t, Agree ι c t →
      ∃ es' t₁, EnvRun small t es' t₁ ∧ es'.length ≤ es.length ∧ Agree ι c₁ t₁ := by
  induction hrun with
  | nil c => exact fun t h => ⟨[], t, EnvRun.nil t, Nat.le_refl _, h⟩
  | cons he _ ih =>
    intro t h
    rcases agree_step hi hg hsw h he with h' | ⟨e', he', h'⟩
    · obtain ⟨es', t₁, hrun', hl, ha⟩ := ih t h'
      exact ⟨es', t₁, hrun', Nat.le_succ_of_le hl, ha⟩
    · obtain ⟨es', t₁, hrun', hl, ha⟩ := ih _ h'
      exact ⟨e' :: es', t₁, EnvRun.cons he' hrun', Nat.succ_le_succ hl, ha⟩

/-- If `small` ends its round responded from a state `t` that agrees with `c`, then in
`sys`, after the monitor phase of the round whose environment phase ends in `c`, `out` is
not empty and every work process sees a reason to halt: every edge of `small` is in force,
so every detection, every report and every reason to halt of `small` is one of `sys`. -/
theorem answer_small (hi : InitialPart sys small ι β σ) (hg : GrownClass sys)
    (s : JState M W G) {c : JState M W G} (hm : Mid sys c) {t : State M₀ W}
    (hag : Agree ι c t) (hresp : Responded small (afterEnv small t).next) :
    (∃ m, Out (monitorPhase (effective sys s c) c.st) m) ∧
      ∀ w, Sees (effective sys s c) (monitorPhase (effective sys s c) c.st)
        (Out (monitorPhase (effective sys s c) c.st)) w := by
  have hgate : small.gate = true := by
    rw [← hi.gate]
    exact hg.gate_on
  have hfast : small.slowReports = false := by
    rw [← hi.slowReports]
    exact hg.reports_fast
  rw [MeshRate.afterEnv_gate hgate] at hresp
  obtain ⟨⟨a₀, hfa, haa, hba⟩, hhalt⟩ := hresp
  have hact : ∀ a, Active t a → Active c.st (ι a) := fun a h =>
    ⟨(hag.alive a).2 h.1, fun hb => h.2.1 ((hag.bad_mon a).1 hb), hm.off _⟩
  -- Every flag of `small` is a flag of `sys`.
  have mono : ∀ a, Spread small t (FlaggedOrDetects small t) a → Flag sys s c (ι a) := by
    intro a h
    induction h with
    | base hF =>
      rcases hF with hF | ⟨hA, hD⟩
      · exact absurd hF (hag.flagged _)
      · refine Spread.base (Or.inr ⟨hact _ hA, ?_⟩)
        rcases hD with ⟨x, hx, hchk⟩ | ⟨p, hp, hrd⟩
        · cases x with
          | inl b =>
            exact Or.inl ⟨.inl (ι b), ⟨(hag.bad_mon b).2 hx.1, hm.hidden _⟩,
              (hi.check_mon b _).2 hchk, inForce_mon hi s c b _ _⟩
          | inr w =>
            exact Or.inl ⟨.inr w, ⟨(hag.bad_work w).2 hx.1, hm.hidden _⟩,
              (hi.check_work w _).2 hchk, inForce_work hi hg s c w _ _⟩
        · exact Or.inr ⟨ι p, fun h => hp ((hag.alive p).1 h), (hi.hb p _).2 hrd,
            inForce_mon hi s c p _ _⟩
    | step _ hA hfwd hA' ih =>
      exact Spread.step ih (hact _ hA) ⟨(hi.fwd _ _).2 hfwd, inForce_mon hi s c _ _ _⟩
        (hact _ hA')
  have hout : ∀ a, Out (monitorPhase small t) a →
      Out (monitorPhase (effective sys s c) c.st) (ι a) := fun a h =>
    out_of_flag hg s (mono a ((MeshRate.flaggedAfter_fast hfast t a).1 h.1))
      ((hag.alive a).2 h.2.1) (fun hb => h.2.2 ((hag.bad_mon a).1 hb))
  refine ⟨⟨ι a₀, hout a₀ ⟨hfa, haa, hba⟩⟩, fun w => ?_⟩
  have hpres : Present small
      (workPhase small (monitorPhase small t) (Out (monitorPhase small t))) (.inr w) := by
    intro hj
    have hj' : small.joiner = some w := hj
    rw [← hi.joiner, hg.no_joiner] at hj'
    cases hj'
  rcases hhalt w hpres with h | ⟨_, h | ⟨hsee, _⟩⟩
  · exact absurd h (hag.halted w)
  · exact absurd h (hag.pending w)
  · rcases hsee with ⟨a, hin, ho⟩ | ⟨_, a, hin, hna⟩
    · exact Or.inl ⟨ι a, ⟨(hi.halt w a).2 hin, inForce_work hi hg s c w a _⟩, hout a ho⟩
    · exact Or.inr ⟨hg.coupling_on, ι a,
        ⟨(hi.halt w a).2 hin, inForce_work hi hg s c w a _⟩,
        fun h => hna ((hag.alive a).1 h)⟩

/-! ### Case 2: only late monitors are faulty -/

/-- A non-empty set of monitors has a member of least rank. -/
theorem exists_min (rank : M → Nat) (P : M → Prop) :
    ∀ n, (∃ z, P z ∧ rank z ≤ n) → ∃ z, P z ∧ ∀ y, P y → rank z ≤ rank y := by
  intro n
  induction n with
  | zero =>
    rintro ⟨z, hz, hle⟩
    exact ⟨z, hz, fun y _ => Nat.le_trans hle (Nat.zero_le _)⟩
  | succ n ih =>
    rintro ⟨z, hz, hle⟩
    rcases Classical.em (∃ z, P z ∧ rank z ≤ n) with h | h
    · exact ih h
    · refine ⟨z, hz, fun y hy => ?_⟩
      have : ¬ rank y ≤ n := fun hyn => h ⟨y, hy, hyn⟩
      omega

/-- If every initial monitor is alive and not bad and some present late monitor is not
alive or is bad, then, after the monitor phase, `out` is not empty and holds a halt input
of every work process. -/
theorem answer_late (hi : InitialPart sys small ι β σ) (hg : GrownClass sys)
    (hr : FlagReachesWork small) (hrk : Ranked sys rank chk rdr tgt)
    (hpr : Prompt sys chk rdr tgt) (s : JState M W G) {c : JState M W G} (hm : Mid sys c)
    (hinit : ∀ a, c.st.alive (.inl (ι a)) ∧ ¬ c.st.bad (.inl (ι a)))
    (hfault : ∃ z, sys.Late z ∧ JPresent sys c (.inl z) ∧
      (¬ c.st.alive (.inl z) ∨ c.st.bad (.inl z))) :
    (∃ m, Out (monitorPhase (effective sys s c) c.st) m) ∧
      ∀ w, Sees (effective sys s c) (monitorPhase (effective sys s c) c.st)
        (Out (monitorPhase (effective sys s c) c.st)) w := by
  -- The faulty present late monitor of least rank.
  obtain ⟨z₀, hz₀⟩ := hfault
  obtain ⟨z, ⟨hzl, hzp, hz⟩, hmin⟩ :=
    exists_min rank (fun z => sys.Late z ∧ JPresent sys c (.inl z) ∧
      (¬ c.st.alive (.inl z) ∨ c.st.bad (.inl z))) (rank z₀) ⟨z₀, hz₀, Nat.le_refl _⟩
  -- The three monitors a present late monitor relies on are present.
  have relied : ∀ n, sys.Late n → JPresent sys c (.inl n) →
      ∀ x, x = chk n ∨ x = rdr n ∨ x = tgt n → JPresent sys c (.inl x) := by
    intro n hl hp x hx
    obtain ⟨q, hq, harr⟩ := hm.reach
    exact (present_of_arrived harr x).1
      (hrk.present q hq n hl ((present_of_arrived harr n).2 hp) x hx)
  -- A present monitor that is initial or of lower rank than `z` is active.
  have good : ∀ d, JPresent sys c (.inl d) → (¬ sys.Late d ∨ rank d < rank z) →
      Active c.st d := by
    intro d hpd hgd
    have key : ¬ (¬ c.st.alive (.inl d) ∨ c.st.bad (.inl d)) := by
      intro hf
      rcases Classical.em (sys.Late d) with hl | hnl
      · rcases hgd with h | h
        · exact h hl
        · exact Nat.lt_irrefl _ (Nat.lt_of_lt_of_le h (hmin d ⟨hl, hpd, hf⟩))
      · obtain ⟨a, rfl⟩ := initial_of_not_late hi hnl
        rcases hf with h | h
        · exact h (hinit a).1
        · exact (hinit a).2 h
    exact ⟨Classical.byContradiction fun h => key (Or.inl h), fun h => key (Or.inr h),
      hm.off d⟩
  have iact : ∀ a, Active c.st (ι a) := fun a => ⟨(hinit a).1, (hinit a).2, hm.off _⟩
  -- `z` is detected by its state checker or by its signal reader.
  have hdet : ∃ d, JPresent sys c (.inl d) ∧ (¬ sys.Late d ∨ rank d < rank z) ∧
      Flag sys s c d := by
    rcases hz with hna | hbad
    · have hpd := relied z hzl hzp (rdr z) (Or.inr (Or.inl rfl))
      have hgd := hrk.lower z hzl (rdr z) (Or.inr (Or.inl rfl))
      exact ⟨rdr z, hpd, hgd, Spread.base (Or.inr ⟨good _ hpd hgd,
        Or.inr ⟨z, hna, hrk.read z hzl, hzp, hpd, fun hs => absurd hs (hpr z hzl).2.1⟩⟩)⟩
    · have hpd := relied z hzl hzp (chk z) (Or.inl rfl)
      have hgd := hrk.lower z hzl (chk z) (Or.inl rfl)
      exact ⟨chk z, hpd, hgd, Spread.base (Or.inr ⟨good _ hpd hgd,
        Or.inl ⟨.inl z, ⟨hbad, hm.hidden _⟩, hrk.check z hzl, hzp, hpd,
          fun hs => absurd hs (hpr z hzl).1⟩⟩)⟩
  -- A flag at such a monitor climbs down the ranks to an initial monitor.
  have climb : ∀ n d, rank d < n → JPresent sys c (.inl d) →
      (¬ sys.Late d ∨ rank d < rank z) → Flag sys s c d → ∃ a, Flag sys s c (ι a) := by
    intro n
    induction n with
    | zero =>
      intro d h
      exact absurd h (Nat.not_lt_zero _)
    | succ n ih =>
      intro d hd hpd hgd hfd
      rcases Classical.em (sys.Late d) with hl | hnl
      · have hdz : rank d < rank z := by
          rcases hgd with h | h
          · exact absurd hl h
          · exact h
        have hpt : JPresent sys c (.inl (tgt d)) := relied d hl hpd _ (Or.inr (Or.inr rfl))
        have hlow := hrk.lower d hl (tgt d) (Or.inr (Or.inr rfl))
        have hgt : ¬ sys.Late (tgt d) ∨ rank (tgt d) < rank z := by
          rcases hlow with h | h
          · exact Or.inl h
          · exact Or.inr (Nat.lt_trans h hdz)
        have hft : Flag sys s c (tgt d) :=
          Spread.step hfd (good d hpd hgd)
            ⟨hrk.report d hl, hpd, hpt, fun hs => absurd hs (hpr d hl).2.2⟩ (good _ hpt hgt)
        rcases hlow with h | h
        · obtain ⟨a, ha⟩ := initial_of_not_late hi h
          exact ⟨a, by rw [ha]; exact hft⟩
        · exact ih (tgt d) (by omega) hpt hgt hft
      · obtain ⟨a, ha⟩ := initial_of_not_late hi hnl
        exact ⟨a, by rw [ha]; exact hfd⟩
  -- Among the initial monitors, all active, a flag follows the report edges of `small`.
  have along : ∀ a h, Reach small a h → Flag sys s c (ι a) → Flag sys s c (ι h) := by
    intro a h hreach
    induction hreach with
    | refl => exact id
    | step _ hfwd ih =>
      exact fun hf => Spread.step (ih hf) (iact _)
        ⟨(hi.fwd _ _).2 hfwd, inForce_mon hi s c _ _ _⟩ (iact _)
  obtain ⟨d, hpd, hgd, hfd⟩ := hdet
  obtain ⟨a₀, hfa⟩ := climb (rank d + 1) d (Nat.lt_succ_self _) hpd hgd hfd
  refine ⟨⟨ι a₀, out_of_flag hg s hfa (hinit a₀).1 (hinit a₀).2⟩, fun w => ?_⟩
  obtain ⟨h, hin, hreach⟩ := hr a₀ w
  exact Or.inl ⟨ι h, ⟨(hi.halt w h).2 hin, inForce_work hi hg s c w h _⟩,
    out_of_flag hg s (along a₀ h hreach hfa) (hinit h).1 (hinit h).2⟩

/-! ### The invariant -/

/-- One round from a clean state violates neither goal, and ends clean or responded. -/
theorem round_from_clean (hi : InitialPart sys small ι β σ) (hg : GrownClass sys)
    (hsw : ∀ m, ¬ sys.base.switches m) (ha : AnswersFaults small)
    (hr : FlagReachesWork small) (hrk : Ranked sys rank chk rdr tgt)
    (hpr : Prompt sys chk rdr tgt) {s : JState M W G} (hm : Mid sys s) (hc : Clean sys s)
    {r : JOutcome M W G} (hround : JRound sys s r) :
    (¬ r.g1 ∧ ¬ r.g2) ∧ ((Mid sys r.next ∧ Clean sys r.next) ∨ JResponded sys r.next) := by
  obtain ⟨steps, c, hl, hrun, rfl⟩ := hround
  have hmc : Mid sys c := mid_run hg hsw hrun hm
  rcases Classical.em (Clean sys c) with hcc | hnc
  · -- No fault: nothing changes.
    have := clean_stays hg s hmc hcc
    exact ⟨this.1, Or.inl this.2⟩
  · have hans : (∃ m, Out (monitorPhase (effective sys s c) c.st) m) ∧
        ∀ w, Sees (effective sys s c) (monitorPhase (effective sys s c) c.st)
          (Out (monitorPhase (effective sys s c) c.st)) w := by
      rcases Classical.em ((∃ a, ¬ c.st.alive (.inl (ι a)) ∨ c.st.bad (.inl (ι a))) ∨
          ∃ w, c.st.bad (.inr w)) with hsf | hnsf
      · -- Case 1: a process of `small` is faulty.
        have hag0 : Agree ι s (init small) :=
          ⟨fun a => ⟨fun _ => trivial, fun _ => hc.1 _ (present_initial hi s a)⟩,
            fun a => ⟨fun h => (hc.2 _ h).elim, fun h => h.elim⟩,
            fun w => ⟨fun h => (hc.2 _ h).elim, fun h => h.elim⟩,
            fun _ h => h, fun _ h => h, fun _ h => h, fun _ h => h, fun _ h => h⟩
        obtain ⟨es', t₁, hrun', hlen, hag⟩ := agree_run hi hg hsw hrun (init small) hag0
        have hne : es' ≠ [] := by
          rintro rfl
          cases hrun'
          rcases hsf with ⟨a, h | h⟩ | ⟨w, h⟩
          · exact h ((hag.alive a).2 trivial)
          · exact (hag.bad_mon a).1 h
          · exact (hag.bad_work w).1 h
        have hlen' : es'.length ≤ small.f := by
          rw [← hi.f]
          exact Nat.le_trans hlen hl
        exact answer_small hi hg s hmc hag (ha es' t₁ hne hlen' hrun')
      · -- Case 2: every initial monitor is alive and not bad, no work process is bad.
        have hinit : ∀ a, c.st.alive (.inl (ι a)) ∧ ¬ c.st.bad (.inl (ι a)) := fun a =>
          ⟨Classical.byContradiction fun h => hnsf (Or.inl ⟨a, Or.inl h⟩),
            fun h => hnsf (Or.inl ⟨a, Or.inr h⟩)⟩
        have hfault : ∃ z, sys.Late z ∧ JPresent sys c (.inl z) ∧
            (¬ c.st.alive (.inl z) ∨ c.st.bad (.inl z)) := by
          apply Classical.byContradiction
          intro hno
          have hok : ∀ m, JPresent sys c (.inl m) →
              c.st.alive (.inl m) ∧ ¬ c.st.bad (.inl m) := by
            intro m hp
            rcases Classical.em (sys.Late m) with hlm | hnl
            · exact ⟨Classical.byContradiction fun h => hno ⟨m, hlm, hp, Or.inl h⟩,
                fun h => hno ⟨m, hlm, hp, Or.inr h⟩⟩
            · obtain ⟨a, rfl⟩ := initial_of_not_late hi hnl
              exact hinit a
          refine hnc ⟨fun m hp => (hok m hp).1, fun p hb => ?_⟩
          cases p with
          | inl m => exact (hok m (hmc.bad_present m hb)).2 hb
          | inr w => exact hnsf (Or.inr ⟨w, hb⟩)
        exact answer_late hi hg hr hrk hpr s hmc hinit hfault
    have := answered_round hg s hmc hans.1 hans.2
    exact ⟨this.1, Or.inr this.2⟩

/-- Every state an execution reaches is clean or responded. -/
theorem reachable_clean_or_responded (hi : InitialPart sys small ι β σ) (hg : GrownClass sys)
    (hsw : ∀ m, ¬ sys.base.switches m) (ha : AnswersFaults small)
    (hr : FlagReachesWork small) (hrk : Ranked sys rank chk rdr tgt)
    (hpr : Prompt sys chk rdr tgt) {s : JState M W G} (h : JReachable sys s) :
    (Mid sys s ∧ Clean sys s) ∨ JResponded sys s := by
  induction h with
  | init => exact Or.inl ⟨mid_init sys, clean_init sys⟩
  | round _ hnr hround ih =>
    rcases ih with ⟨hm, hc⟩ | hresp
    · exact (round_from_clean hi hg hsw ha hr hrk hpr hm hc hround).2
    · exact absurd hresp hnr

end

/-- Theorem L, layered growth, with the hypothesis it was found to need. Let `small` be
`sys` without its late monitors, and suppose that in `small` every round with a fault
ends in a complete response and a flag at any monitor reaches a halt input of every work
process along report edges. Let `sys` be of the class `GrownClass`, with no switch on any
monitor, and let its late monitors be ranked so that each has a state checker, a signal
reader and a report target that are each an initial monitor or a late monitor of lower
rank and are present whenever it is, those three edges not being slow edges. Then `sys`
has no gap, whether or not monitors may arrive bad. -/
theorem theorem_L {G M₀ B₀ S₀ : Type} (sys : JSystem M W B S G) (small : System M₀ W B₀ S₀)
    (ι : M₀ → M) (β : B₀ → B) (σ : S₀ → S) (hi : InitialPart sys small ι β σ)
    (hg : GrownClass sys) (hsw : ∀ m, ¬ sys.base.switches m) (ha : AnswersFaults small)
    (hr : FlagReachesWork small) (rank : M → Nat) (chk rdr tgt : M → M)
    (hrk : Ranked sys rank chk rdr tgt) (hpr : Prompt sys chk rdr tgt) : JNoGap sys := by
  intro s r hreach hnr hround
  rcases reachable_clean_or_responded hi hg hsw ha hr hrk hpr hreach with ⟨hm, hc⟩ | hresp
  · exact (round_from_clean hi hg hsw ha hr hrk hpr hm hc hround).1
  · exact absurd hresp hnr

end JoinLayered
end SelfObserving
