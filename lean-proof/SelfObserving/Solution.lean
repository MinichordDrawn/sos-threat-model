/-
Proofs of the statements in `Challenge.lean`. Nothing outside this project is imported.

The first three statements are proved here in full. The eleven about the reference system
and its removals are at the end of the file. Each of those is settled by a computation
that the kernel carries out (`Proofs/Finite.lean`, `Proofs/Explore.lean`), on data that
`tools/gen.py` takes from the model check's checker (`Generated/`): for a goal that can be
violated, a violating execution; for a goal that cannot, the reachable states.
-/
import SelfObserving.Systems
import SelfObserving.Generated.Executions
import SelfObserving.Generated.StatesReference
import SelfObserving.Generated.StatesWithoutP4
import SelfObserving.Generated.StatesWithoutP6
import SelfObserving.Generated.StatesWithoutP8

namespace SelfObserving

variable {M W B S : Type}

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

theorem quiet_init (sys : System M W B S) : Quiet (init sys) where
  alive := fun _ => trivial
  bad := fun _ h => h
  hidden := fun _ h => h
  off := fun _ h => h
  flagged := fun _ h => h
  halted := fun _ h => h
  pending := fun _ h => h

/-- With at most one environment step, the environment phase applies no step or one. -/
theorem envRun_le_one {sys : System M W B S} {s s₁ : State M W}
    {steps : List (EnvStep M W B S)} (h : EnvRun sys s steps s₁) (hl : steps.length ≤ 1) :
    s₁ = s ∨ ∃ e, Enabled sys s e ∧ s₁ = effect sys s e := by
  cases h with
  | nil => exact Or.inl rfl
  | cons he hrest =>
    cases hrest with
    | nil => exact Or.inr ⟨_, he, rfl⟩
    | cons _ _ =>
      simp only [List.length_cons] at hl
      omega

/-- With the gate, a round runs the monitor phase and then the work phase. -/
theorem afterEnv_gate {sys : System M W B S} (hg : sys.gate = true) (s₁ : State M W) :
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
theorem flaggedAfter_fast {sys : System M W B S} (hfast : sys.slowReports = false)
    (s : State M W) (m : M) :
    flaggedAfter sys s m ↔ Spread sys s (FlaggedOrDetects sys s) m := by
  unfold flaggedAfter
  split
  · rename_i h
    rw [hfast] at h
    cases h
  · exact Iff.rfl

theorem spread_empty {sys : System M W B S} {s : State M W} {F : M → Prop}
    (hF : ∀ m, ¬ F m) : ∀ m, ¬ Spread sys s F m := by
  intro m h
  induction h with
  | base hm => exact hF _ hm
  | step _ _ _ _ ih => exact ih

theorem ReachAvoiding.ne {sys : System M W B S} {z x y : M}
    (h : ReachAvoiding sys z x y) : y ≠ z := by
  cases h with
  | refl hx => exact hx
  | step _ _ hne => exact hne

theorem spread_of_reachAvoiding {sys : System M W B S} {s : State M W} {F : M → Prop}
    {z r y : M} (hact : ∀ m, m ≠ z → Active s m) (hr : F r)
    (h : ReachAvoiding sys z r y) : Spread sys s F y := by
  induction h with
  | refl _ => exact Spread.base hr
  | step hxy hfwd hne ih => exact Spread.step ih (hact _ hxy.ne) hfwd (hact _ hne)

theorem spread_of_reach {sys : System M W B S} {s : State M W} {F : M → Prop}
    {k y : M} (hact : ∀ m, Active s m) (hk : F k) (h : Reach sys k y) :
    Spread sys s F y := by
  induction h with
  | refl => exact Spread.base hk
  | step _ hfwd ih => exact Spread.step ih (hact _) hfwd (hact _)

/-- If, after the monitor phase, `out` is not empty and holds a halt input of every work
process, the round violates neither goal and ends in a responded state. -/
theorem finish {sys : System M W B S} (hp : Plain sys) {s₁ : State M W}
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

/-- The case of a single fault at a monitor `z`, stopped or mutated: every other monitor
is active, and every watcher of `z` detects. -/
theorem monitor_case {sys : System M W B S} (hp : Plain sys) (hs : Sufficient sys)
    {s₁ : State M W} (z : M) (hh : ∀ w, ¬ s₁.halted w)
    (hact : ∀ m, m ≠ z → Active s₁ m)
    (hdet : ∀ r, r ≠ z → Watches sys r z → Detects sys s₁ r) :
    (¬ (afterEnv sys s₁).g1 ∧ ¬ (afterEnv sys s₁).g2) ∧
      Responded sys (afterEnv sys s₁).next := by
  have hall : ∀ y, y ≠ z → Out (monitorPhase sys s₁) y := by
    intro y hy
    obtain ⟨r, hr, hw, hreach⟩ := hs.c z y hy
    have hflag : flaggedAfter sys s₁ y :=
      (flaggedAfter_fast hp.reports_fast s₁ y).2
        (spread_of_reachAvoiding hact (Or.inr (hdet r hr hw)) hreach)
    exact ⟨hflag, (hact y hy).1, (hact y hy).2.1⟩
  refine finish hp hh ?_ ?_
  · obtain ⟨r, hr, _⟩ := hs.a z
    exact ⟨r, hall r hr⟩
  · intro w
    obtain ⟨_, h₁, h₂, hne, hin₁, hin₂⟩ := hs.b w
    by_cases h : h₁ = z
    · exact ⟨h₂, hin₂, hall h₂ (fun h' => hne (h.trans h'.symm))⟩
    · exact ⟨h₁, hin₁, hall h₁ h⟩

/-- One round from a quiet state violates neither goal, and ends quiet or responded. -/
theorem round_from_quiet {sys : System M W B S} (hf : sys.f = 1) (hp : Plain sys)
    (hs : Sufficient sys) {s : State M W} (hq : Quiet s) {r : Outcome M W}
    (hr : Round sys s r) :
    (¬ r.g1 ∧ ¬ r.g2) ∧ (Quiet r.next ∨ Responded sys r.next) := by
  obtain ⟨steps, s₁, hlen, hrun, rfl⟩ := hr
  rw [hf] at hlen
  rcases envRun_le_one hrun hlen with rfl | ⟨e, he, rfl⟩
  · -- The environment takes no step: nothing changes.
    have hnoflag : ∀ m, ¬ flaggedAfter sys s₁ m := by
      intro m hm
      rw [flaggedAfter_fast hp.reports_fast] at hm
      refine spread_empty (fun m hm => ?_) m hm
      rcases hm with h | h
      · exact hq.flagged m h
      · obtain ⟨_, ⟨x, hx, _⟩ | ⟨p, hp', _⟩⟩ := h
        · exact hq.bad x hx.1
        · exact hp' (hq.alive p)
    have hnosee : ∀ w, ¬ Sees sys (monitorPhase sys s₁) (Out (monitorPhase sys s₁)) w := by
      rintro w (⟨m, _, hm⟩ | ⟨_, m, _, hm⟩)
      · exact hnoflag m hm.1
      · exact hm (hq.alive m)
    rw [afterEnv_gate hp.gate_on]
    refine ⟨⟨fun h => ?_, fun h => ?_⟩, Or.inl ?_⟩
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
  · -- The environment takes one step.
    cases e with
    | stop z =>
      have hact : ∀ m, m ≠ z → Active (effect sys s (.stop z)) m := fun m hm =>
        ⟨⟨hq.alive m, fun h => hm (Sum.inl.inj h)⟩, hq.bad _, hq.off m⟩
      have := monitor_case hp hs z (s₁ := effect sys s (.stop z)) hq.halted hact
        (fun r hr hw => ⟨hact r hr, Or.inr ⟨z, fun h => h.2 rfl, hw.2⟩⟩)
      exact ⟨this.1, Or.inr this.2⟩
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
        have hact : ∀ m, m ≠ z → Active (effect sys s (.mutate (.inl z))) m := by
          intro m hm
          refine ⟨hq.alive m, ?_, hq.off m⟩
          rintro (h | h)
          · exact hm (Sum.inl.inj h)
          · exact hq.bad _ h
        have := monitor_case hp hs z (s₁ := effect sys s (.mutate (.inl z))) hq.halted hact
          (fun r hr hw =>
            ⟨hact r hr, Or.inl ⟨.inl z, ⟨Or.inl rfl, hq.hidden _⟩, hw.1⟩⟩)
        exact ⟨this.1, Or.inr this.2⟩
      | inr x =>
        have hact : ∀ m, Active (effect sys s (.mutate (.inr x))) m := by
          intro m
          refine ⟨hq.alive m, ?_, hq.off m⟩
          rintro (h | h)
          · cases h
          · exact hq.bad _ h
        obtain ⟨k, hk, hreach⟩ := hs.d x
        have hdet : Detects sys (effect sys s (.mutate (.inr x))) k :=
          ⟨hact k, Or.inl ⟨.inr x, ⟨Or.inl rfl, hq.hidden _⟩, hk⟩⟩
        have hall : ∀ m, Out (monitorPhase sys (effect sys s (.mutate (.inr x)))) m := by
          intro m
          have hflag : flaggedAfter sys (effect sys s (.mutate (.inr x))) m :=
            (flaggedAfter_fast hp.reports_fast _ m).2
              (spread_of_reach hact (Or.inr hdet) (hreach m))
          exact ⟨hflag, (hact m).1, (hact m).2.1⟩
        have := finish hp (s₁ := effect sys s (.mutate (.inr x))) hq.halted ⟨k, hall k⟩
          (fun w => by
            obtain ⟨_, h₁, _, _, hin₁, _⟩ := hs.b w
            exact ⟨h₁, hin₁, hall h₁⟩)
        exact ⟨this.1, Or.inr this.2⟩
    | disable m => exact absurd he.1 (hp.no_switch m)
    | join => exact absurd hp.no_joiner he.1

/-- Every state an execution reaches is quiet or responded. -/
theorem reachable_quiet_or_responded {sys : System M W B S} (hf : sys.f = 1)
    (hp : Plain sys) (hs : Sufficient sys) {s : State M W} (h : Reachable sys s) :
    Quiet s ∨ Responded sys s := by
  induction h with
  | init => exact Or.inl (quiet_init sys)
  | round _ hnr hround ih =>
    rcases ih with hq | hresp
    · exact (round_from_quiet hf hp hs hq hround).2
    · exact absurd hresp hnr

/-- Theorem S. A plain system that meets the four conditions has no gap at one fault per
round: no execution of any length violates G1 or G2 in any round. The numbers of monitors
and of work processes are arbitrary, and need not be finite. -/
theorem theorem_S (sys : System M W B S) (hf : sys.f = 1) (hp : Plain sys)
    (hs : Sufficient sys) : NoGap sys := by
  intro s r hreach hnr hround
  rcases reachable_quiet_or_responded hf hp hs hreach with hq | hresp
  · exact (round_from_quiet hf hp hs hq hround).1
  · exact absurd hresp hnr

theorem mesh_plain : Plain (mesh M W) where
  no_joiner := rfl
  no_substrate := fun _ => rfl
  no_switch := fun _ h => h
  boundaries_distinct := fun _ _ _ hne h => hne (Option.some.inj (h.1.trans h.2.symm))
  coupling_on := rfl
  no_window := rfl
  gate_on := rfl
  reports_fast := rfl

theorem mesh_sufficient {m₀ m₁ : M} (h : m₀ ≠ m₁) : Sufficient (mesh M W) where
  a := fun z => by
    by_cases hz : z = m₀
    · rw [hz]
      exact ⟨m₁, h.symm, h.symm, h.symm⟩
    · exact ⟨m₀, fun e => hz e.symm, fun e => hz e.symm, fun e => hz e.symm⟩
  b := fun _ => ⟨⟨m₀, trivial⟩, m₀, m₁, h, trivial, trivial⟩
  c := fun _ y hy => ⟨y, hy, ⟨hy, hy⟩, ReachAvoiding.refl hy⟩
  d := fun _ => ⟨m₀, trivial, fun m => by
    by_cases hm : m = m₀
    · rw [hm]
      exact Reach.refl m₀
    · exact Reach.step (Reach.refl m₀) hm⟩

/-- The conditions of Theorem S can be met: a full mesh of at least two monitors, with any
work processes, has no gap. -/
theorem mesh_noGap {m₀ m₁ : M} (h : m₀ ≠ m₁) : NoGap (mesh M W) :=
  theorem_S (mesh M W) rfl mesh_plain (mesh_sufficient h)

/-- "No gap" can fail: a work process that nothing watches has a gap. -/
theorem unwatched_gap : ¬ NoGap unwatched := by
  intro h
  have hround : Round unwatched (init unwatched)
      (afterEnv unwatched (effect unwatched (init unwatched) (.mutate (.inr ())))) :=
    ⟨[.mutate (.inr ())], _, Nat.le_refl 1,
      EnvRun.cons ⟨fun hj => by simp [System.IsJoiner, unwatched] at hj, fun hb => hb⟩
        (EnvRun.nil _), rfl⟩
  have hnr : ¬ Responded unwatched (init unwatched) := fun hr => hr.1.elim fun m _ => m.elim
  apply (h _ _ Reachable.init hnr hround).1
  rw [afterEnv_gate rfl]
  exact ⟨⟨.inr (), Or.inl rfl⟩, fun hm => hm.elim fun m _ => m.elim⟩

/-! ### The reference system and the ten removals

A goal that can be violated: `Py.*_trace` in `Generated/Executions.lean` is an execution
whose last round violates it, and `violatesG1_of_trace` or `violatesG2_of_trace` concludes.
A goal that cannot be violated: `Py.*_covers` in `Generated/States*.lean` says that the
listed states hold every reachable state and that no round from any of them violates it,
and `Covers.noG1`, `Covers.noG2` or `Covers.noGap` concludes. In each, the first `rfl` is
the proof that the system allows one fault per round. After a trace, a second `rfl` is the
proof that the goal is violated in the last of its rounds. -/

open Finite

/-- The reference system, with every feature, has no gap. -/
theorem reference_noGap : NoGap reference :=
  (covers_spec reference Py.reference_covers).noGap rfl

/-- Without P1, the liveness signal, both goals can be violated. -/
theorem withoutP1_gap : ViolatesG1 withoutP1 ∧ ViolatesG2 withoutP1 :=
  ⟨violatesG1_of_trace rfl Py.withoutP1_g1_trace rfl,
    violatesG2_of_trace rfl Py.withoutP1_g2_trace rfl⟩

/-- Without P2, shared substrate, both goals can be violated. -/
theorem withoutP2_gap : ViolatesG1 withoutP2 ∧ ViolatesG2 withoutP2 :=
  ⟨violatesG1_of_trace rfl Py.withoutP2_g1_trace rfl,
    violatesG2_of_trace rfl Py.withoutP2_g2_trace rfl⟩

/-- Without P3, the state check, both goals can be violated. -/
theorem withoutP3_gap : ViolatesG1 withoutP3 ∧ ViolatesG2 withoutP3 :=
  ⟨violatesG1_of_trace rfl Py.withoutP3_g1_trace rfl,
    violatesG2_of_trace rfl Py.withoutP3_g2_trace rfl⟩

/-- Without P4, propagation, G2 can be violated and G1 cannot: the fault is flagged, and
work goes on. -/
theorem withoutP4_gap : ¬ ViolatesG1 withoutP4 ∧ ViolatesG2 withoutP4 :=
  ⟨(covers_spec withoutP4 Py.withoutP4_covers).noG1 rfl,
    violatesG2_of_trace rfl Py.withoutP4_g2_trace rfl⟩

/-- Without P5, no single-step removal, both goals can be violated. -/
theorem withoutP5_gap : ViolatesG1 withoutP5 ∧ ViolatesG2 withoutP5 :=
  ⟨violatesG1_of_trace rfl Py.withoutP5_g1_trace rfl,
    violatesG2_of_trace rfl Py.withoutP5_g2_trace rfl⟩

/-- Without P6, the out-of-boundary signal, G1 can be violated and G2 cannot: the work
stops, and nothing is left to know why. -/
theorem withoutP6_gap : ViolatesG1 withoutP6 ∧ ¬ ViolatesG2 withoutP6 :=
  ⟨violatesG1_of_trace rfl Py.withoutP6_g1_trace rfl,
    (covers_spec withoutP6 Py.withoutP6_covers).noG2 rfl⟩

/-- Without P7, automatic enrolment, both goals can be violated. -/
theorem withoutP7_gap : ViolatesG1 withoutP7 ∧ ViolatesG2 withoutP7 :=
  ⟨violatesG1_of_trace rfl Py.withoutP7_g1_trace rfl,
    violatesG2_of_trace rfl Py.withoutP7_g2_trace rfl⟩

/-- Without P8, immediate response, G2 can be violated and G1 cannot: every monitor has
flagged, and the work takes one more step. -/
theorem withoutP8_gap : ¬ ViolatesG1 withoutP8 ∧ ViolatesG2 withoutP8 :=
  ⟨(covers_spec withoutP8 Py.withoutP8_covers).noG1 rfl,
    violatesG2_of_trace rfl Py.withoutP8_g2_trace rfl⟩

/-- Without the halt fan-out, both goals can be violated. -/
theorem withoutP8b_gap : ViolatesG1 withoutP8b ∧ ViolatesG2 withoutP8b :=
  ⟨violatesG1_of_trace rfl Py.withoutP8b_g1_trace rfl,
    violatesG2_of_trace rfl Py.withoutP8b_g2_trace rfl⟩

/-- Without the gate, both goals can be violated. -/
theorem withoutGate_gap : ViolatesG1 withoutGate ∧ ViolatesG2 withoutGate :=
  ⟨violatesG1_of_trace rfl Py.withoutGate_g1_trace rfl,
    violatesG2_of_trace rfl Py.withoutGate_g2_trace rfl⟩

end SelfObserving
