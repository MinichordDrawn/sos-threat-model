/-
Proofs of the statements in `Challenge.lean`. Nothing outside this project is imported.

The first three statements are proved here in full. The eleven about the reference system
and its removals come after them. Each of those is settled by a computation
that the kernel carries out (`Proofs/Finite.lean`, `Proofs/Explore.lean`), on data that
`tools/gen.py` takes from the model check's checker (`Generated/`): for a goal that can be
violated, a violating execution; for a goal that cannot, the reachable states.

The next twelve, about what any system needs and about naming the faulty monitor, follow
them. They are proved in `Proofs/Necessity.lean`, with no computation, and stated again
here.

The statements added after those twenty-six follow them: restarting, systems that are not
plain, how fast a halt must travel, whether three monitors are forced, the count of work
steps a slow report costs, the mesh at any fault rate, and the interleaved rings on two
levels. Each is proved in a file of `Proofs/` named in its heading, and stated again here.
The proofs are by argument. The count of section 8.2 is run in one place only: for six
figures of its table (`halt_table_doubling`). Elsewhere `decide` and `rfl` settle only
small closed facts: about literal numbers, and about the named rings and systems, whose
wiring conditions are checked case by case.

The statements added after those sixty-two follow them: no gap at any number of faults per
round (`Proofs/Connected.lean`), the ring of `k` members and the least ring
(`Proofs/RingOfK.lean`), and the same ring one level up (`Proofs/TowerRings.lean`). Each
is proved in the file named and stated again here; `ring_exact`, `candidate_noGap`,
`tower_exact` and `tower_noGap` are put together here from results of those files.

The statements about monitors that join come last, with the files that prove them named in
their heading. Lemma M follows them.
-/
import SelfObserving.Systems
import SelfObserving.Proofs.Necessity
import SelfObserving.Generated.Executions
import SelfObserving.Generated.StatesReference
import SelfObserving.Generated.StatesWithoutP4
import SelfObserving.Generated.StatesWithoutP6
import SelfObserving.Generated.StatesWithoutP8
import SelfObserving.Proofs.Restarting
import SelfObserving.Proofs.Widening
import SelfObserving.Proofs.Halting
import SelfObserving.Proofs.Forced
import SelfObserving.Proofs.ReflexCount
import SelfObserving.Proofs.MeshRate
import SelfObserving.Proofs.NestedRings
import SelfObserving.Proofs.Connected
import SelfObserving.Proofs.RingOfK
import SelfObserving.Proofs.TowerRings
import SelfObserving.Proofs.JoinPlain
import SelfObserving.Proofs.JoinLemmaN
import SelfObserving.Proofs.JoinConnected
import SelfObserving.Proofs.JoinLayered
import SelfObserving.Proofs.JoinExampleProofs
import SelfObserving.Proofs.MoreEdgesProofs

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

/-! ### What any system needs

Each statement below is about every system, and is proved in `Proofs/Necessity.lean` under
the same name. A statement about a gap is proved there by giving an execution: one round
from the initial state, or two. -/

/-- Theorem 0, part 3. A flag starts only at a detection: from a state with no flag, if no
monitor detects, the monitor phase raises no flag. -/
theorem flag_needs_detection (sys : System M W B S) (s : State M W)
    (hflag : ∀ m, ¬ s.flagged m) (hdet : ∀ m, ¬ Detects sys s m) :
    ∀ m, ¬ flaggedAfter sys s m :=
  Necessity.flag_needs_detection sys s hflag hdet

/-- The rate form of P5 (section 6). If some non-empty set of at most `f` monitors is
checked by no monitor outside the set, G1 can be violated: the environment mutates the whole
set in one round, and nothing flags. -/
theorem unchecked_set_gap (sys : System M W B S) (zs : List M) (hne : zs ≠ [])
    (hnd : zs.Nodup) (hlen : zs.length ≤ sys.f)
    (hin : ∀ z, z ∈ zs → ∀ r, sys.checkers (.inl z) r → r ∈ zs) : ViolatesG1 sys :=
  Necessity.unchecked_set_gap sys zs hne hnd hlen hin

/-- Theorem 0, part 1. If there is at least one monitor and `f` is at least the number of
monitors, G1 can be violated. `ms` lists every monitor once. -/
theorem rate_bound (sys : System M W B S) (ms : List M) (hne : ms ≠ []) (hnd : ms.Nodup)
    (hall : ∀ m, m ∈ ms) (hlen : ms.length ≤ sys.f) : ViolatesG1 sys :=
  Necessity.rate_bound sys ms hne hnd hall hlen

/-- P3 for monitors (section 6). A monitor with no state checker other than itself can be
mutated, leaving a bad state and no flag. -/
theorem unchecked_monitor_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (z : M)
    (hz : ∀ r, sys.checkers (.inl z) r → r = z) : ViolatesG1 sys :=
  Necessity.unchecked_monitor_gap sys hf z hz

/-- P3 for work, and the state-check half of P7. `results.md` checks both on R (section 6)
and cites a proof of the first elsewhere (section 12.1). A non-monitor process that no
monitor checks can be mutated once it is present, leaving a bad state and no flag. This
holds whether the process is present from the start or joins later. -/
theorem unchecked_work_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (w : W)
    (hw : ∀ m, ¬ sys.checkers (.inr w) m) : ViolatesG1 sys :=
  Necessity.unchecked_work_gap sys hf w hw

/-- Theorem 0, part 2, which is also the general form of the P6 removal (section 7). If
every monitor sits in one boundary, and there are at least two monitors, G1 can be
violated: the boundary is stopped, then in the next round a process is mutated. -/
theorem one_boundary_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (b : B) {m₀ m₁ : M}
    (hne : m₀ ≠ m₁) (hb : ∀ m, sys.boundary m = some b) : ViolatesG1 sys :=
  Necessity.one_boundary_gap sys hf b hne hb

/-- P8 in general (section 6). In a system with a window and a work process present from
the start, G2 can be violated: the environment mutates a work process, and none may halt
before the window has passed. -/
theorem window_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (hwin : sys.window ≠ 0) (w : W)
    (hw : ¬ sys.IsJoiner w) : ViolatesG2 sys :=
  Necessity.window_gap sys hf hwin w hw

/-- P8b in general (section 6). A work process with at most `f` halt inputs keeps working
after the environment mutates all of them, so G2 can be violated. `hs` contains every halt
input of `w`, and may contain other monitors. -/
theorem few_halt_inputs_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (w : W)
    (hw : ¬ sys.IsJoiner w) (hs : List M) (hnd : hs.Nodup)
    (hall : ∀ m, sys.haltInputs w m → m ∈ hs) (hlen : hs.length ≤ sys.f) :
    ViolatesG2 sys :=
  Necessity.few_halt_inputs_gap sys hf w hw hs hnd hall hlen

/-- The gate in general (section 6). In a system without the gate and with a work process
present from the start, G2 can be violated: in round 1 no flag exists yet when the work
processes step. -/
theorem noGate_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (hgate : sys.gate = false)
    (w : W) (hw : ¬ sys.IsJoiner w) : ViolatesG2 sys :=
  Necessity.noGate_gap sys hf hgate w hw

/-- The reflex (section 8.1). When reports take a round, a work process none of whose halt
inputs checks its state takes a work step while bad, so G2 can be violated. -/
theorem slow_report_gap (sys : System M W B S) (hf : 1 ≤ sys.f)
    (hslow : sys.slowReports = true) (w : W) (hw : ¬ sys.IsJoiner w)
    (hsep : ∀ m, sys.haltInputs w m → ¬ sys.checkers (.inr w) m) : ViolatesG2 sys :=
  Necessity.slow_report_gap sys hf hslow w hw hsep

/-! ### Naming the faulty monitor

Proved in `Proofs/Necessity.lean` under the same names. -/

/-- With two monitors, no rule is always right: "each names the other" arises both when the
first is faulty and when the second is. -/
theorem two_cannot_name :
    ¬ ∃ rule : (Bool → Bool) → Bool,
        ∀ (z : Bool) (names : Bool → Bool),
          (∀ m, m ≠ z → names m = z) → rule names = z :=
  Necessity.two_cannot_name

/-- With three or more monitors, a rule exists that is always right: the faulty monitor is
the one named by two others. -/
theorem three_can_name (a b c : M) (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    ∃ rule : (M → M) → M,
      ∀ (z : M) (names : M → M), (∀ m, m ≠ z → names m = z) → rule names = z :=
  Necessity.three_can_name a b c hab hac hbc

/-! ### Restarting

Section 10.3 of `results.md`: the restart game of `Restart.lean`. Each statement below is
proved in `Proofs/Restarting.lean` under the same name, by argument. -/

/-- Theorem R. If no member can start first, so that every member runs only while a
running member observes it, then once every member has stopped, none can ever start:
whatever moves follow, no member is running. -/
theorem theorem_R {X : Type} (g : Ring X) (hno : ∀ x, ¬ g.startsFirst x)
    (s s' : RingState X) (moves : List (RingMove X)) (hstop : ∀ x, ¬ s.running x)
    (hrun : RingRun g s moves s') : ∀ x, ¬ s'.running x :=
  Restarting.theorem_R g hno s s' moves hstop hrun

/-- Recovery needs a member that can start first. A ring with at least one member, none of
which can start first, cannot always restart: a full stop is reachable, and by Theorem R
nothing starts after it. -/
theorem restart_needs_first {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs)
    (x₀ : X) (hno : ∀ x, ¬ g.startsFirst x) : ¬ CanAlwaysRestart g :=
  Restarting.restart_needs_first g xs hall x₀ hno

/-- Every other member must be reached from the member that can start first. Let `k` be
the one member that can start first. The ring can always restart exactly when `k` reaches
every other member. -/
theorem restart_iff_reaches {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs)
    (k : X) (hk : ∀ x, g.startsFirst x ↔ x = k) :
    CanAlwaysRestart g ↔ ∀ y, y ≠ k → Reaches g k y :=
  Restarting.restart_iff_reaches g xs hall k hk

/-- The same for any number of members that can start first, none included. The ring can
always restart exactly when every member that cannot start first is reached from one that
can. `results.md` states this for one such member only. -/
theorem restart_iff_reached {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs) :
    CanAlwaysRestart g ↔ ∀ y, ¬ g.startsFirst y → ∃ k, g.startsFirst k ∧ Reaches g k y :=
  Restarting.restart_iff_reached g xs hall

/-- The table of section 10.3, first row. Three members, each observed by the one before
it, cannot restart after one member is stopped and released: the stop passes round the
ring and all three are stopped. -/
theorem ring3_cannot_restart :
    ¬ CanAlwaysRestart ring3 ∧
    ∃ s, RingRun ring3 ringInit [.stop .X1, .release .X1] s ∧ (∀ x, ¬ s.running x) ∧
      (∀ x, ¬ s.blocked x) ∧ ¬ Recovers ring3 s :=
  Restarting.ring3_cannot_restart

/-- Second row. Three members, each observed by the other two, cannot restart after two
members are stopped and released. -/
theorem mesh3_cannot_restart :
    ¬ CanAlwaysRestart mesh3 ∧
    ∃ s, RingRun mesh3 ringInit [.stop .X1, .release .X1, .stop .X2, .release .X2] s ∧
      (∀ x, ¬ s.blocked x) ∧ ¬ Recovers mesh3 s :=
  Restarting.mesh3_cannot_restart

/-- Third row. Three members and a coordinator that observes all three and can start
first can always restart. -/
theorem ringK_can_restart : CanAlwaysRestart (ringK true) :=
  Restarting.ringK_can_restart

/-- Fourth row. The same four, when the coordinator cannot start first, cannot restart
after one member and the coordinator are stopped and released. -/
theorem ringK_cannot_restart_without_first :
    ¬ CanAlwaysRestart (ringK false) ∧
    ∃ s, RingRun (ringK false) ringInit [.stop .X1, .release .X1, .stop .K, .release .K] s ∧
      (∀ x, ¬ s.blocked x) ∧ ¬ Recovers (ringK false) s :=
  Restarting.ringK_cannot_restart_without_first

/-! ### Systems that are not plain

Proved in `Proofs/Widening.lean` under the same names. The proof of `theorem_S_wide`
follows that of `theorem_S` above, with three more kinds of step. -/

/-- A system of the wider class that meets the conditions of `SufficientWide` has no gap
at one fault per round. -/
theorem theorem_S_wide (sys : System M W B S) (hf : sys.f = 1) (ho : Ordinary sys)
    (hs : SufficientWide sys) : NoGap sys :=
  Widening.theorem_S_wide sys hf ho hs

/-- Theorem S is a special case: a plain system that meets the four conditions is of the
wider class and meets its conditions. -/
theorem plain_is_wide (sys : System M W B S) (hp : Plain sys) (hs : Sufficient sys) :
    Ordinary sys ∧ SufficientWide sys :=
  Widening.plain_is_wide sys hp hs

/-- The reference system's result is a special case: the reference system is of the wider
class and meets its conditions. -/
theorem reference_is_wide : Ordinary reference ∧ SufficientWide reference :=
  Widening.reference_is_wide

/-! ### How fast a halt must travel

Section 8.2 of `results.md`: the count of `Growth.lean`. Proved in `Proofs/Halting.lean`
under the same names. The figures of the table for a halt passed to one per hop come from
a closed form, not from running the count. -/

/-- The window. If everything halts `w` ticks after detection, the damage is `2 ^ w`, or
the whole system if that is smaller. -/
theorem window_damage (n w : Nat) (hn : 1 ≤ n) : windowDamage n w = min (2 ^ w) n :=
  Halting.window_damage n w hn

/-- The count ends, and the damage is one number: for a halt passed to at least one per
hop at one or more hops per tick, some tick leaves no bad process running. -/
theorem cascade_ends (c h n : Nat) (hc : 1 ≤ c) (hh : 1 ≤ h) (hn : 1 ≤ n) :
    ∃ d, CascadeDamage c h n d ∧ ∀ d', CascadeDamage c h n d' → d' = d :=
  Halting.cascade_ends c h n hc hh hn

/-- The cascade. A halt passed to `c` per hop has reached at most `1 + c + ... + c ^ j`
processes after `j` hops, the place it starts from counted as the first. After `t` ticks
it has made `h * t` hops, and the processes it has reached are those no longer running. -/
theorem cascade_reach (c h n t : Nat) (hn : 1 ≤ n) :
    n + 1 ≤ (cascade c h n t).good + (cascade c h n t).bad + geom c (h * t) :=
  Halting.cascade_reach c h n t hn

/-- With `c` = 1 the bound is `j + 1`: a chain grows by one per hop. -/
theorem geom_one (j : Nat) : geom 1 j = j + 1 :=
  Halting.geom_one j

/-- With `c` = 2 the bound is `2 ^ (j + 1) - 1`: it doubles. -/
theorem geom_two (j : Nat) : geom 2 j + 1 = 2 ^ (j + 1) :=
  Halting.geom_two j

/-- A chain loses to a doubling fault at any speed. With `h` hops per tick the damage is
at least `n - h * ceil(log2 n)`. `L` is any number with `n ≤ 2 ^ L`; the least such is
`ceil(log2 n)`. -/
theorem chain_bound (h n L d : Nat) (hn : 2 ≤ n) (hL : n ≤ 2 ^ L)
    (hd : CascadeDamage 1 h n d) : n ≤ d + h * L :=
  Halting.chain_bound h n L d hn hL hd

/-- A halt that doubles, at two hops per tick, keeps pace: the damage is at most
`sqrt(n / 2)`, for every `n` of 2 or more. -/
theorem doubling_two_hops_bound (n d : Nat) (hn : 2 ≤ n) (hd : CascadeDamage 2 2 n d) :
    2 * (d * d) ≤ n :=
  Halting.doubling_two_hops_bound n d hn hd

/-- A halt that doubles, at one hop per tick, loses exactly `n / 4` when `n` is a power
of two of 8 or more. -/
theorem doubling_one_hop_exact (k d : Nat) (hk : 3 ≤ k) (hd : CascadeDamage 2 1 (2 ^ k) d) :
    4 * d = 2 ^ k :=
  Halting.doubling_one_hop_exact k d hk hd

/-- The table of section 8.2, rows 1 and 2: everything halts together, in the same tick
and 5 ticks later. -/
theorem halt_table_together :
    windowDamage 1024 0 = 1 ∧ windowDamage 1048576 0 = 1 ∧
    windowDamage 1024 5 = 32 ∧ windowDamage 1048576 5 = 32 :=
  Halting.halt_table_together

/-- The table of section 8.2, rows 3 and 4: passed to 1 per hop, at 1 hop and at 128 hops
per tick. -/
theorem halt_table_chain :
    CascadeDamage 1 1 1024 1014 ∧ CascadeDamage 1 1 1048576 1048556 ∧
    CascadeDamage 1 128 1024 128 ∧ CascadeDamage 1 128 1048576 1046016 :=
  Halting.halt_table_chain

/-- The table of section 8.2, rows 5 to 7: passed to 2 per hop, at 1, 2 and 4 hops per
tick. -/
theorem halt_table_doubling :
    CascadeDamage 2 1 1024 256 ∧ CascadeDamage 2 1 1048576 262144 ∧
    CascadeDamage 2 2 1024 16 ∧ CascadeDamage 2 2 1048576 512 ∧
    CascadeDamage 2 4 1024 4 ∧ CascadeDamage 2 4 1048576 16 :=
  Halting.halt_table_doubling

/-! ### Whether three monitors are forced

Section 10.2 of `results.md`. Proved in `Proofs/Forced.lean` under the same names. -/

/-- With one monitor or two, no rule always names the faulty monitor, when at most one is
faulty. `a` and `b` are all the monitors, and may be the same one. -/
theorem one_or_two_cannot_name (a b : M) (hall : ∀ m, m = a ∨ m = b) : ¬ CanName M :=
  Forced.one_or_two_cannot_name a b hall

/-- With three or more monitors, a rule exists that always names the faulty monitor, and
says so when none is faulty. -/
theorem three_or_more_can_name (a b c : M) (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    CanName M :=
  Forced.three_or_more_can_name a b c hab hac hbc

/-- Still naming it after losing one takes at least four. With two monitors or three,
after any one of them is lost no rule always names the faulty monitor among those that
remain. `a`, `b` and `c` are all the monitors, and `c` may be `a` or `b`. The case of one
monitor is not stated: nothing remains after its loss. -/
theorem cannot_name_after_loss (a b c : M) (hab : a ≠ b) (hall : ∀ m, m = a ∨ m = b ∨ m = c)
    (lost : M) : ¬ CanName {m : M // m ≠ lost} :=
  Forced.cannot_name_after_loss a b c hab hall lost

/-- With four or more monitors, after any one of them is lost a rule still exists that
always names the faulty monitor among those that remain. -/
theorem can_name_after_loss (a b c d : M) (hab : a ≠ b) (hac : a ≠ c) (had : a ≠ d)
    (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) (lost : M) : CanName {m : M // m ≠ lost} :=
  Forced.can_name_after_loss a b c d hab hac had hbc hbd hcd lost

/-- The cascade, as a count. If every member of a group passes a halt to at least two
other members, the group has at least three members. The group has a member, `x₀`. -/
theorem pass_to_two_needs_three {X : Type} (passes : X → X → Prop) (x₀ : X)
    (h : ∀ x, ∃ y y', y ≠ x ∧ y' ≠ x ∧ y ≠ y' ∧ passes x y ∧ passes x y') :
    ∃ a b c : X, a ≠ b ∧ a ≠ c ∧ b ≠ c :=
  Forced.pass_to_two_needs_three passes x₀ h

/-! ### Further statements

Proved under the same names in `Proofs/Restarting.lean`, `Proofs/Halting.lean`,
`Proofs/ReflexCount.lean` and `Proofs/MeshRate.lean`. -/

/-- A full stop is reachable (section 10.3). In every ring with finitely many members,
the game can reach a state in which no member is running and none is blocked: every
member has been stopped, by the environment or by the rule, and the environment has
released each one it stopped. -/
theorem full_stop_reachable {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs) :
    ∃ (moves : List (RingMove X)) (s : RingState X),
      RingRun g ringInit moves s ∧ (∀ x, ¬ s.running x) ∧ (∀ x, ¬ s.blocked x) :=
  Restarting.full_stop_reachable g xs hall

/-- A halt that doubles, at one hop per tick, loses between a fifth and two fifths of the
system for every `n` from 8 to 3,000 (section 8.2), the ends of that range of shares
included. -/
theorem doubling_one_hop_range (n d : Nat) (hlo : 8 ≤ n) (hhi : n ≤ 3000)
    (hd : CascadeDamage 2 1 n d) : n ≤ 5 * d ∧ 5 * d ≤ 2 * n :=
  Halting.doubling_one_hop_range n d hlo hhi hd

/-- The count of the reflex (section 8.1). When reports take a round, with no window and
the gate in place, take the execution in which the mutation of the work process `w` is
the environment's only step. `w` takes a work step while bad in round `j + 1` exactly
when no state checker of `w` reaches a halt input of `w` in `j` report hops or fewer. So
`w` takes `d` work steps while bad, in rounds 1 to `d`, where `d` is the least number of
report hops from one of its state checkers to one of its halt inputs; `d` is 0 exactly
when a checker is itself a halt input; and with no such path `w` works in every round. -/
theorem slow_report_count (sys : System M W B S) (hslow : sys.slowReports = true)
    (hwin : sys.window = 0) (hgate : sys.gate = true) (w : W) (hw : ¬ sys.IsJoiner w)
    (j : Nat) :
    SoloWorks sys w j ↔
      ∀ n k h, n ≤ j → sys.checkers (.inr w) k → sys.haltInputs w h → ¬ Hops sys n k h :=
  ReflexCount.slow_report_count sys hslow hwin hgate w hw j

/-- The rounds counted in `slow_report_count` are rounds of an execution. If `w` took a
work step in each of the first `j` rounds, then round `j + 1` is a round of the model
from a state that an execution reaches and that is not responded: the state it starts
from is `soloStart sys w j`, and its outcome is that of `soloEnv sys w j`. -/
theorem slow_report_execution (sys : System M W B S) (hf : 1 ≤ sys.f)
    (hslow : sys.slowReports = true) (hwin : sys.window = 0) (hgate : sys.gate = true)
    (w : W) (hw : ¬ sys.IsJoiner w) (j : Nat) (hj : ∀ i, i < j → SoloWorks sys w i) :
    Reachable sys (soloStart sys w j) ∧ ¬ Responded sys (soloStart sys w j) ∧
      Round sys (soloStart sys w j) (afterEnv sys (soloEnv sys w j)) :=
  ReflexCount.slow_report_execution sys hf hslow hwin hgate w hw j hj

/-- The holding half of the mesh result (section 10.2): a mesh of `n` monitors has no gap
when `f ≤ n - 1`. `ms` is a list of different monitors, more than `f` of them, so there
are at least `f + 1` monitors. The numbers of monitors and of work processes are
otherwise arbitrary. -/
theorem mesh_holds (f : Nat) (ms : List M) (hnd : ms.Nodup) (hlen : f < ms.length) :
    NoGap (meshAt M W f) :=
  MeshRate.mesh_holds f ms hnd hlen

/-- The mesh result in both directions (section 10.2): a mesh of `n` monitors, `n` at
least 1, has no gap exactly when `f ≤ n - 1`. `ms` lists every monitor once, so
`ms.length` is `n`, and `f < ms.length` says `f ≤ n - 1`. -/
theorem mesh_exact (f : Nat) (ms : List M) (hne : ms ≠ []) (hnd : ms.Nodup)
    (hall : ∀ m, m ∈ ms) : NoGap (meshAt M W f) ↔ f < ms.length :=
  MeshRate.mesh_exact f ms hne hnd hall

/-! ### The interleaved rings on two levels

Proved in `Proofs/NestedRings.lean` under the same names: the wiring conditions are
checked case by case, and `theorem_S_wide` concludes. -/

/-- The interleaved rings on two levels have no gap at one fault per round (section 10.1,
checked instances). -/
theorem nested_noGap : NoGap (nested false) :=
  NestedRings.nested_noGap

/-- The same with each base ring whole in one boundary, so that one step can stop an
entire ring (sections 2.7 and 10.1): no gap at one fault per round. -/
theorem nested_boundaries_noGap : NoGap (nested true) :=
  NestedRings.nested_boundaries_noGap

/-- Both are cases of `theorem_S_wide`: with or without the ring boundaries, the system is
of the wider class and meets its conditions. -/
theorem nested_is_wide (ringBoundaries : Bool) :
    Ordinary (nested ringBoundaries) ∧ SufficientWide (nested ringBoundaries) :=
  NestedRings.nested_is_wide ringBoundaries

/-! ### No gap at any number of faults per round

`results-join.md`, section 3: Theorem J and Theorem F, for systems with nothing joining
(`AnyRate.lean`). `results.md`, section 11, lists a sufficient condition at more than one
fault per round as missing. In the three theorems the number of faults per round is the
system's own `f`, and may be any number; in the other two statements it is the `f` that
the statement names.

Proved in `Proofs/Connected.lean` under the same names. -/

/-- Theorem J, with nothing joining. A plain system has no gap at `f` faults per round if
its monitors are connected by pairs that watch each other and report to each other, every
work process has a state checker and more than `f` halt inputs, and there are more than
`f` monitors. -/
theorem theorem_J (sys : System M W B S) (hp : Plain sys) (hs : SufficientJ sys sys.f) :
    NoGap sys :=
  Connected.theorem_J sys hp hs

/-- Theorem J with its first condition in one direction only. `results-join.md` does not
state this form. A plain system has no gap at `f` faults per round if from every monitor
every monitor is reached by steps that each go from a monitor to one it watches and hears
from, every work process has a state checker and more than `f` halt inputs, and there are
more than `f` monitors. -/
theorem theorem_J_one_way (sys : System M W B S) (hp : Plain sys)
    (hs : SufficientOneWay sys sys.f) : NoGap sys :=
  Connected.theorem_J_one_way sys hp hs

/-- Theorem J is a special case of the one-way form: the conditions of Theorem J give
those of `SufficientOneWay`, in any system and at any `f`. -/
theorem paired_is_one_way (sys : System M W B S) (f : Nat) (hs : SufficientJ sys f) :
    SufficientOneWay sys f :=
  Connected.paired_is_one_way sys f hs

/-- The holding half of the mesh result (`mesh_holds`) is a special case of Theorem J: a
mesh of more than `f` monitors, at `f` faults per round, is plain and meets the
conditions of Theorem J. `ms` is a list of different monitors, more than `f` of them. -/
theorem mesh_is_connected (f : Nat) (ms : List M) (hnd : ms.Nodup) (hlen : f < ms.length) :
    Plain (meshAt M W f) ∧ SufficientJ (meshAt M W f) f :=
  Connected.mesh_is_connected f ms hnd hlen

/-- Theorem F. A plain system has no gap at `f` faults per round if every monitor has at
least `f` state checkers and at least `f` signal readers other than itself, every work
process has a state checker, and for every monitor `d`, every work process `w` and every
set of at most `f` monitors that does not contain `d`, some halt input of `w` outside the
set is reached from `d` along report edges that avoid the set. -/
theorem theorem_F (sys : System M W B S) (hp : Plain sys) (hs : SufficientF sys sys.f) :
    NoGap sys :=
  Connected.theorem_F sys hp hs

/-! ### The ring of `k` members and a coordinator

`results-minimal.md`, section 3, and `part-a.md`: the ring of `Rings.lean`, under each of
the two readings of a connection, with the work reading every monitor. -/

/-- The ring is a case of Theorem J when `f` is at most `k`: it is plain and meets the
conditions of Theorem J at `f` faults per round. The coordinator and each member watch
each other and report to each other, under either reading. -/
theorem ring_is_connected (rd : Reading) (k f : Nat) (h : f ≤ k) :
    Plain (ring rd k f) ∧ SufficientJ (ring rd k f) f :=
  RingOfK.ring_is_connected rd k f h

/-- The ring of `k` members in a cycle and a coordinator, the work reading every monitor,
has no gap exactly when `f` is at most `k`, under either reading and for every `k`
(`results-minimal.md`, section 3). -/
theorem ring_exact (rd : Reading) (k f : Nat) : NoGap (ring rd k f) ↔ f ≤ k :=
  ⟨fun h => by
    rcases Nat.lt_or_ge k f with hlt | hge
    · obtain ⟨s, r, hreach, hnr, hround, hg1⟩ := RingOfK.ring_gap rd k f hlt
      exact absurd hg1 (h s r hreach hnr hround).1
    · exact hge,
   fun h => Connected.theorem_J (ring rd k f) (RingOfK.ring_is_connected rd k f h).1
    (RingOfK.ring_is_connected rd k f h).2⟩

/-- The candidate ring, three members in a cycle and a coordinator, the work reading all
four: no gap at one, two and three faults per round, under either reading. -/
theorem candidate_noGap (rd : Reading) :
    NoGap (ring rd 3 1) ∧ NoGap (ring rd 3 2) ∧ NoGap (ring rd 3 3) :=
  ⟨(ring_exact rd 3 1).2 (by decide), (ring_exact rd 3 2).2 (by decide),
    (ring_exact rd 3 3).2 (by decide)⟩

/-! ### The least ring

`part-a.md`, section 2.2, and `results-minimal.md`, sections 2 and 3: the count of
connections that R2 and R5 force. A wiring is a list of different connections between the
monitors of the ring with `k` members, and its length is the number of connections. The
lists ranged over may also hold a connection from a monitor to itself, which `part-a.md`
does not count among its twelve; the bounds hold with or without such connections.
"Least" in these statements is among such wirings, for the two requirements R2 and R5 of
`Rings.lean`, under the reading named. It is not a statement about any other requirement,
any other reading of a connection, or a count of edges kind by kind. R2 and R5 do not
depend on `f`. -/

/-- Under actor, every wiring of the `k` members and the coordinator in which every
monitor has two watchers (R2) and every member reports to the coordinator (R5) has at
least `3 * k` connections. -/
theorem least_actor (k f : Nat) (l : List (RingMon k × RingMon k)) (hnd : l.Nodup)
    (h2 : R2 (wiredList .actor l f)) (h5 : R5 (wiredList .actor l f) .coord) :
    3 * k ≤ l.length :=
  RingOfK.least_actor k f l hnd h2 h5

/-- Under flow, every wiring of the `k` members and the coordinator in which every monitor
has two watchers (R2) has at least `2 * k + 2` connections. R5 is not needed for the
count: under flow R2 alone gives it. -/
theorem least_flow (k f : Nat) (l : List (RingMon k × RingMon k)) (hnd : l.Nodup)
    (h2 : R2 (wiredList .flow l f)) : 2 * k + 2 ≤ l.length :=
  RingOfK.least_flow k f l hnd h2

/-- The list `candidateArrows` holds exactly the connections of the ring with three
members. -/
theorem candidate_is_ring (x y : RingMon 3) :
    (x, y) ∈ candidateArrows ↔ ringConn 3 x y :=
  RingOfK.candidate_is_ring x y

/-- The least ring of four under actor. Among the wirings of four monitors as directed
connections, every one that meets R2 and R5 has at least nine connections, and the
candidate has nine and meets both: under actor the candidate is among the least. -/
theorem least_of_four_actor (f : Nat) :
    (∀ l : List (RingMon 3 × RingMon 3), l.Nodup → R2 (wiredList .actor l f) →
        R5 (wiredList .actor l f) .coord → 9 ≤ l.length) ∧
    candidateArrows.Nodup ∧ candidateArrows.length = 9 ∧
    R2 (wiredList .actor candidateArrows f) ∧
    R5 (wiredList .actor candidateArrows f) .coord :=
  RingOfK.least_of_four_actor f

/-- The least ring of four under flow. Among the wirings of four monitors as directed
connections, every one that meets R2 and R5 has at least eight connections; the candidate
without `D -> C` has eight and meets both; and the candidate, with nine, meets both: under
flow the candidate is one over the least. -/
theorem least_of_four_flow (f : Nat) :
    (∀ l : List (RingMon 3 × RingMon 3), l.Nodup → R2 (wiredList .flow l f) →
        R5 (wiredList .flow l f) .coord → 8 ≤ l.length) ∧
    (eightArrows.Nodup ∧ eightArrows.length = 8 ∧
      R2 (wiredList .flow eightArrows f) ∧ R5 (wiredList .flow eightArrows f) .coord) ∧
    (candidateArrows.Nodup ∧ candidateArrows.length = 9 ∧
      R2 (wiredList .flow candidateArrows f) ∧
      R5 (wiredList .flow candidateArrows f) .coord) :=
  RingOfK.least_of_four_flow f

/-! ### The same ring one level up

`results-minimal.md`, sections 4.1 and 4.6: the tower of `Tower.lean`, as one system,
under each of the two readings, each base ring's work reading its own four monitors. -/

/-- The tower is a case of Theorem J at up to three faults per round, at every number of
levels from one, when every monitor is in a boundary of its own: it is plain and meets
the conditions of Theorem J. A coordinator and each of its members watch each other and
report to each other, and the rings are joined through the coordinators they share. -/
theorem tower_is_connected (rd : Reading) (n f : Nat) (hn : 1 ≤ n) (hf : f ≤ 3) :
    Plain (tower rd n false f) ∧ SufficientJ (tower rd n false f) f :=
  TowerRings.tower_is_connected rd n f hn hf

/-- The tower of any number of levels from one, every monitor in a boundary of its own,
has no gap exactly when `f` is at most 3, the number of halt inputs of a work process
less one (`results-minimal.md`, section 4.6). -/
theorem tower_exact (rd : Reading) (n f : Nat) (hn : 1 ≤ n) :
    NoGap (tower rd n false f) ↔ f ≤ 3 :=
  ⟨fun h => by
    rcases Nat.lt_or_ge 3 f with hlt | hge
    · obtain ⟨s, r, hreach, hnr, hround, hg2⟩ := TowerRings.tower_gap rd n f hn hlt
      exact absurd hg2 (h s r hreach hnr hround).2
    · exact hge,
   fun h => Connected.theorem_J (tower rd n false f)
    (TowerRings.tower_is_connected rd n f hn h).1
    (TowerRings.tower_is_connected rd n f hn h).2⟩

/-- The tower of any number of levels from one, every monitor in a boundary of its own:
no gap at one, two and three faults per round, under either reading. -/
theorem tower_noGap (rd : Reading) (n : Nat) (hn : 1 ≤ n) :
    NoGap (tower rd n false 1) ∧ NoGap (tower rd n false 2) ∧
      NoGap (tower rd n false 3) :=
  ⟨(tower_exact rd n 1 hn).2 (by decide), (tower_exact rd n 2 hn).2 (by decide),
    (tower_exact rd n 3 hn).2 (by decide)⟩

/-- With each base ring whole in one boundary, the tower of two or more levels is a case
of `theorem_S_wide` at one fault per round: it is of the wider class and meets its
conditions. The loss of a whole base ring is read by the coordinator above it. -/
theorem tower_boundaries_is_wide (rd : Reading) (n : Nat) (hn : 2 ≤ n) :
    Ordinary (tower rd n true 1) ∧ SufficientWide (tower rd n true 1) :=
  TowerRings.tower_boundaries_is_wide rd n hn

/-- With each base ring whole in one boundary, the tower of two or more levels has no gap
at one fault per round, under either reading (`results-minimal.md`, section 4.6). -/
theorem tower_boundaries_noGap (rd : Reading) (n : Nat) (hn : 2 ≤ n) :
    NoGap (tower rd n true 1) :=
  TowerRings.tower_boundaries_noGap rd n hn

/-- Two levels are needed for that. A single ring whole in one boundary has a gap at one
fault per round: the boundary is stopped, and then a process is mutated with no monitor
left to flag it (`results-minimal.md`, section 4.6; Theorem 0, part 2). -/
theorem tower_one_level_boundaries_gap (rd : Reading) : ViolatesG1 (tower rd 1 true 1) :=
  TowerRings.tower_one_level_boundaries_gap rd

/-! ### Monitors that join

`model-spec-join.md` and `results-join.md`, section 3: the model of `Join.lean`, the
conditions of `JoinConditions.lean` and the two systems of `JoinExamples.lean`. The model
with joins is a second model beside that of `Model.lean`. The first two statements say
that a system with none of the new fields behaves in it as in `Model.lean`: executions
reach the same states, and the result for each goal is the same. As everywhere in this
project, a result is whether a goal can be violated, and not the round in which it first
is.

Proved in `Proofs/JoinPlain.lean`, `Proofs/JoinLemmaN.lean`, `Proofs/JoinConnected.lean`,
`Proofs/JoinLayered.lean` and `Proofs/JoinExampleProofs.lean` under the same names;
`grown_ring_exact` and `grown_mesh_exact` are put together here, and the two statements
that end in `_rest` are given here the proof that the mesh answers faults. -/

/-- A system with none of the three new fields reaches the same states in the model with
joins as in the model of `Model.lean`: a state of the model with joins is reached by an
execution exactly when its components are a state that an execution of `Model.lean`
reaches. (With no group, the set of groups that have joined is empty in every state.) -/
theorem plainJoin_reachable (sys : System M W B S) (s : JState M W Empty) :
    JReachable (plainJoin sys) s ↔ Reachable sys s.st :=
  JoinPlain.plainJoin_reachable sys s

/-- A system with none of the three new fields has the same result in both models: no gap
in the one exactly when no gap in the other, and each goal can be violated in the one
exactly when it can in the other. -/
theorem plainJoin_same (sys : System M W B S) :
    (JNoGap (plainJoin sys) ↔ NoGap sys) ∧
    (JViolatesG1 (plainJoin sys) ↔ ViolatesG1 sys) ∧
    (JViolatesG2 (plainJoin sys) ↔ ViolatesG2 sys) :=
  JoinPlain.plainJoin_same sys

/-- A monitor nobody checks (`results-join.md`, section 3). If the joins can reach a set
of present processes in which some present monitor has no present state checker other
than itself, G1 can be violated at one fault per round or more: the joins are taken one a
round, and then that monitor is mutated. This holds for every system of the model with
joins, plain or not. -/
theorem unchecked_present_monitor_gap {G : Type} (sys : JSystem M W B S G)
    (hf : 1 ≤ sys.base.f) (s : JState M W G) (hs : JoinsReach sys s) (z : M)
    (hz : JPresent sys s (.inl z))
    (hc : ∀ r, sys.base.checkers (.inl z) r → JPresent sys s (.inl r) → r = z) :
    JViolatesG1 sys :=
  JoinPlain.unchecked_present_monitor_gap sys hf s hs z hz hc

/-- Lemma N: late monitors never help. If `small` is `sys` with every late monitor and
its edges deleted, then each goal that can be violated in `small` can be violated in
`sys`: the environment may leave every group's step untaken. The lemma is stated for
systems whose joiner, if there is one, is in no group and has no slow edge
(`InitialPart`). `results-join.md` also says that the violation needs no more rounds in
`sys`; rounds are not counted here. -/
theorem lemma_N {G M₀ B₀ S₀ : Type} (sys : JSystem M W B S G) (small : System M₀ W B₀ S₀)
    (ι : M₀ → M) (β : B₀ → B) (σ : S₀ → S) (hi : InitialPart sys small ι β σ) :
    (ViolatesG1 small → JViolatesG1 sys) ∧ (ViolatesG2 small → JViolatesG2 sys) :=
  JoinLemmaN.lemma_N sys small ι β σ hi

/-- Theorem J, with joins. A system that is plain with joins has no gap at `f` faults per
round if, in every set of present processes the joins can reach, the present monitors are
connected by pairs that watch each other and report to each other and every present work
process has a present state checker and more than `f` present halt inputs, and there are
more than `f` initial monitors. Monitors may or may not arrive bad. -/
theorem theorem_J_joins {G : Type} (sys : JSystem M W B S G) (hp : PlainJ sys)
    (hs : SufficientJoins sys sys.base.f) : JNoGap sys :=
  JoinConnected.theorem_J_joins sys hp hs

/-- In a plain system that meets the conditions of Theorem J, every round with a fault
ends in a complete response. -/
theorem connected_answers (sys : System M W B S) (hp : Plain sys)
    (hs : SufficientJ sys sys.f) : AnswersFaults sys :=
  JoinConnected.connected_answers sys hp hs

/-- Theorem L, layered growth, with the hypothesis it was found to need. Let `small` be
`sys` without its late monitors, and suppose that in `small` every round with a fault
ends in a complete response and a flag at any monitor reaches a halt input of every work
process along report edges. Let `sys` be of the class `GrownClass` (plain with joins and
with no joiner, but for slow edges), with no switch on any monitor, and let its late
monitors be ranked so that each has a state checker, a signal reader and a report target
that are each an initial monitor or a late monitor of lower rank and are present whenever
it is, those three edges not being slow edges. Then `sys` has no gap, whether or not
monitors may arrive bad. `GrownClass` asks of the late monitors, too, that none runs on a
substrate and no two monitors share a boundary; `results-join.md` asks that of the base
system only, so this statement is for a narrower class than the theorem as worded
there. -/
theorem theorem_L {G M₀ B₀ S₀ : Type} (sys : JSystem M W B S G) (small : System M₀ W B₀ S₀)
    (ι : M₀ → M) (β : B₀ → B) (σ : S₀ → S) (hi : InitialPart sys small ι β σ)
    (hg : GrownClass sys) (hsw : ∀ m, ¬ sys.base.switches m) (ha : AnswersFaults small)
    (hr : FlagReachesWork small) (rank : M → Nat) (chk rdr tgt : M → M)
    (hrk : Ranked sys rank chk rdr tgt) (hpr : Prompt sys chk rdr tgt) : JNoGap sys :=
  JoinLayered.theorem_L sys small ι β σ hi hg hsw ha hr rank chk rdr tgt hrk hpr

/-- Growth keeps the rate of the ring (`results-join.md`, section 6.1). Take the ring of
`k` members and a coordinator of `Rings.lean`, under either reading, the work reading
every monitor, and grow it by any number of late monitors under the hypotheses of Theorem
L: each late monitor with a state checker, a signal reader and a report target of lower
rank that are present whenever it is, those edges not slow, no switches. The grown system
has no gap exactly when `f` is at most `k`. Of the four base rings of `results-join.md`,
section 2, this covers the cycle with a checking coordinator (`k` = 3 under flow), and
`grown_mesh_exact` covers the mesh; the two whose coordinator checks no state are not
covered. The five shapes of that section each meet the hypotheses on a late monitor, and
are not defined one by one here. -/
theorem grown_ring_exact {G : Type} (rd : Reading) (k : Nat)
    (sys : JSystem M Unit B S G) (ι : RingMon k → M) (β : RingMon k → B) (σ : Unit → S)
    (hi : InitialPart sys (ring rd k sys.base.f) ι β σ) (hg : GrownClass sys)
    (hsw : ∀ m, ¬ sys.base.switches m) (rank : M → Nat) (chk rdr tgt : M → M)
    (hrk : Ranked sys rank chk rdr tgt) (hpr : Prompt sys chk rdr tgt) :
    JNoGap sys ↔ sys.base.f ≤ k :=
  ⟨fun h => by
    rcases Nat.lt_or_ge k sys.base.f with hlt | hge
    · obtain ⟨s, r, hreach, hnr, hround, hg1⟩ :=
        (JoinLemmaN.lemma_N sys _ ι β σ hi).1 (RingOfK.ring_gap rd k sys.base.f hlt)
      exact absurd hg1 (h s r hreach hnr hround).1
    · exact hge,
   fun h => JoinLayered.theorem_L sys _ ι β σ hi hg hsw
    (JoinConnected.connected_answers _ (RingOfK.ring_is_connected rd k sys.base.f h).1
      (RingOfK.ring_is_connected rd k sys.base.f h).2)
    (fun m _ => ⟨m, trivial, Reach.refl m⟩) rank chk rdr tgt hrk hpr⟩

/-- The same for the mesh. A mesh of `n` monitors, `n` at least 1, grown by any number of
late monitors under the hypotheses of Theorem L has no gap exactly when `f ≤ n - 1`. `ms`
lists every monitor of the mesh once. -/
theorem grown_mesh_exact {G M₀ W₀ : Type} (sys : JSystem M W₀ B S G) (ms : List M₀)
    (hne : ms ≠ []) (hnd : ms.Nodup) (hall : ∀ m, m ∈ ms) (ι : M₀ → M) (β : M₀ → B)
    (σ : Unit → S) (hi : InitialPart sys (meshAt M₀ W₀ sys.base.f) ι β σ)
    (hg : GrownClass sys) (hsw : ∀ m, ¬ sys.base.switches m) (rank : M → Nat)
    (chk rdr tgt : M → M) (hrk : Ranked sys rank chk rdr tgt)
    (hpr : Prompt sys chk rdr tgt) : JNoGap sys ↔ sys.base.f < ms.length :=
  ⟨fun h => by
    rcases Nat.lt_or_ge sys.base.f ms.length with hlt | hge
    · exact hlt
    · obtain ⟨s, r, hreach, hnr, hround, hg1⟩ :=
        (JoinLemmaN.lemma_N sys _ ι β σ hi).1
          (Necessity.rate_bound (meshAt M₀ W₀ sys.base.f) ms hne hnd hall hge)
      exact absurd hg1 (h s r hreach hnr hround).1,
   fun h => JoinLayered.theorem_L sys _ ι β σ hi hg hsw
    (JoinConnected.connected_answers _ (Connected.mesh_is_connected sys.base.f ms hnd h).1
      (Connected.mesh_is_connected sys.base.f ms hnd h).2)
    (fun m _ => ⟨m, trivial, Reach.refl m⟩) rank chk rdr tgt hrk hpr⟩

/-- The hypothesis of Theorem L on slow edges is needed (`results-join.md`, sections 3
and 5). When the state checks of a late monitor are slow edges, both goals can be
violated: at two faults per round when monitors arrive good (the monitor joins and is
mutated in one round), and at one fault per round when a monitor may arrive bad. -/
theorem slow_check_example_gap :
    (JViolatesG1 (slowCheckExample false 2) ∧ JViolatesG2 (slowCheckExample false 2)) ∧
    (JViolatesG1 (slowCheckExample true 1) ∧ JViolatesG2 (slowCheckExample true 1)) :=
  JoinExampleProofs.slow_check_example_gap

/-- That system meets every other hypothesis of Theorem L, at up to three faults per
round and whether or not monitors may arrive bad. It is the mesh of four with one late
monitor; it is of the class `GrownClass` and has no switch; in the mesh every round with
a fault ends in a complete response and a flag reaches the work; the late monitor relies
on M1 for its state check, its signal and its report, under the ranking that gives every
monitor rank 0; and the signal read and the report are not slow. Only the state check is
slow. -/
theorem slow_check_example_rest (arriveBad : Bool) (f : Nat) (hf : f ≤ 3) :
    InitialPart (slowCheckExample arriveBad f) (meshAt (Fin 4) Unit f) Sum.inl Sum.inl id ∧
    GrownClass (slowCheckExample arriveBad f) ∧
    (∀ m, ¬ (slowCheckExample arriveBad f).base.switches m) ∧
    AnswersFaults (meshAt (Fin 4) Unit f) ∧ FlagReachesWork (meshAt (Fin 4) Unit f) ∧
    Ranked (slowCheckExample arriveBad f) (fun _ => 0) (fun _ => .inl 0) (fun _ => .inl 0)
      (fun _ => .inl 0) ∧
    (∀ n, (slowCheckExample arriveBad f).Late n →
      (slowCheckExample arriveBad f).slowCheck (.inl n) (.inl 0) ∧
      ¬ (slowCheckExample arriveBad f).slowHb n (.inl 0) ∧
      ¬ (slowCheckExample arriveBad f).slowFwd n (.inl 0)) :=
  JoinExampleProofs.slow_check_example_rest_of arriveBad f
    (JoinConnected.connected_answers _
      (Connected.mesh_is_connected (M := Fin 4) (W := Unit) f [0, 1, 2, 3] (by decide) (Nat.lt_succ_of_le hf)).1
      (Connected.mesh_is_connected (M := Fin 4) (W := Unit) f [0, 1, 2, 3] (by decide) (Nat.lt_succ_of_le hf)).2)

/-- The hypothesis of Theorem L on switches is needed (`results-join.md`, section 3).
When a late monitor that another leans on has an off switch, both goals can be violated
at one fault per round, with monitors arriving good and no slow edge: N5 joins, N6 joins,
N5 is switched off, N6 is mutated. -/
theorem switch_example_gap : JViolatesG1 switchExample ∧ JViolatesG2 switchExample :=
  JoinExampleProofs.switch_example_gap

/-- That system meets every other hypothesis of Theorem L. It is the mesh of four with
two late monitors; it is of the class `GrownClass`; in the mesh every round with a fault
ends in a complete response and a flag reaches the work; N5 relies on M1 and N6 on N5,
ranked accordingly; and no relied-on edge is slow. Only the switch of N5 is against the
hypotheses. -/
theorem switch_example_rest :
    InitialPart switchExample (meshAt (Fin 4) Unit 1) Sum.inl Sum.inl id ∧
    GrownClass switchExample ∧
    AnswersFaults (meshAt (Fin 4) Unit 1) ∧ FlagReachesWork (meshAt (Fin 4) Unit 1) ∧
    Ranked switchExample switchRank switchRelies switchRelies switchRelies ∧
    Prompt switchExample switchRelies switchRelies switchRelies ∧
    (∀ m, switchExample.base.switches m ↔ m = .inr 0) :=
  JoinExampleProofs.switch_example_rest_of
    (JoinConnected.connected_answers _
      (Connected.mesh_is_connected (M := Fin 4) (W := Unit) 1 [0, 1, 2, 3] (by decide) (by decide)).1
      (Connected.mesh_is_connected (M := Fin 4) (W := Unit) 1 [0, 1, 2, 3] (by decide) (by decide)).2)

/-! ### More edges never hurt

Lemma M of `results-join.md`, section 3, with the relations of `MoreEdges.lean`. As
everywhere in this project, a result is whether a goal can be violated; that the second
system needs at least as many rounds to violate it, which the lemma also says there, is
not stated.

Proved in `Proofs/MoreEdgesProofs.lean` under the same names. -/

/-- Lemma M, for the model of `Model.lean`. Let two systems with no window differ only in
that the second has more edges. Then each goal that can be violated in the second can be
violated in the first, and if the first has no gap, neither has the second. -/
theorem lemma_M (sys₁ sys₂ : System M W B S) (h : MoreEdges sys₁ sys₂)
    (hw : sys₁.window = 0) :
    (ViolatesG1 sys₂ → ViolatesG1 sys₁) ∧ (ViolatesG2 sys₂ → ViolatesG2 sys₁) ∧
      (NoGap sys₁ → NoGap sys₂) :=
  MoreEdgesProofs.lemma_M sys₁ sys₂ h hw

/-- Lemma M, for the model with joins. Let two systems with no window differ only in that
the second has more edges, or has an edge prompt that is slow in the first. Then each
goal that can be violated in the second can be violated in the first, and if the first
has no gap, neither has the second. -/
theorem lemma_M_joins {G : Type} (sys₁ sys₂ : JSystem M W B S G) (h : JMoreEdges sys₁ sys₂)
    (hw : sys₁.base.window = 0) :
    (JViolatesG1 sys₂ → JViolatesG1 sys₁) ∧ (JViolatesG2 sys₂ → JViolatesG2 sys₁) ∧
      (JNoGap sys₁ → JNoGap sys₂) :=
  MoreEdgesProofs.lemma_M_joins sys₁ sys₂ h hw

end SelfObserving
