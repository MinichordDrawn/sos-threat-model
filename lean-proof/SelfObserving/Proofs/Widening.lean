/-
Proofs of the three statements of `Challenge.lean` about systems that are not plain:
`theorem_S_wide`, `plain_is_wide` and `reference_is_wide`. Nothing outside this project is
imported. The only computation is `decide` on equalities between named monitors,
substrates and boundaries of the reference system.

The proof of `theorem_S_wide` follows that of Theorem S in `Solution.lean`. Every state an
execution reaches is quiet or responded; a round from a quiet state takes no environment
step or one, violates neither goal, and ends quiet or responded. The wider class adds
three steps to the cases of the one environment step: `join`, which leaves the state
quiet, and `stopBoundary` and `failSubstrate`, each of which removes a whole set of
monitors, and is answered by the monitors outside the set.
-/
import SelfObserving.Wide
import SelfObserving.Reference

namespace SelfObserving
namespace Widening

variable {M W B S : Type}

/-- A state in which nothing has happened: every monitor is alive, and nothing is bad,
hidden, off, flagged, halted or pending. It says nothing of whether the joiner has
joined, nor of which non-monitor processes are alive. -/
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

theorem reachAvoiding_ne {sys : System M W B S} {z x y : M}
    (h : ReachAvoiding sys z x y) : y ≠ z := by
  cases h with
  | refl hx => exact hx
  | step _ _ hne => exact hne

theorem spread_of_reachAvoiding {sys : System M W B S} {s : State M W} {F : M → Prop}
    {z r y : M} (hact : ∀ m, m ≠ z → Active s m) (hr : F r)
    (h : ReachAvoiding sys z r y) : Spread sys s F y := by
  induction h with
  | refl _ => exact Spread.base hr
  | step hxy hfwd hne ih =>
    exact Spread.step ih (hact _ (reachAvoiding_ne hxy)) hfwd (hact _ hne)

theorem spread_of_reach {sys : System M W B S} {s : State M W} {F : M → Prop}
    {k y : M} (hact : ∀ m, Active s m) (hk : F k) (h : Reach sys k y) :
    Spread sys s F y := by
  induction h with
  | refl => exact Spread.base hk
  | step _ hfwd ih => exact Spread.step ih (hact _) hfwd (hact _)

theorem reachOutside_out {sys : System M W B S} {Z : M → Prop} {x y : M}
    (h : ReachOutside sys Z x y) : ¬ Z y := by
  cases h with
  | refl hx => exact hx
  | step _ _ hout => exact hout

theorem spread_of_reachOutside {sys : System M W B S} {s : State M W} {F : M → Prop}
    {Z : M → Prop} {r y : M} (hact : ∀ m, ¬ Z m → Active s m) (hr : F r)
    (h : ReachOutside sys Z r y) : Spread sys s F y := by
  induction h with
  | refl _ => exact Spread.base hr
  | step hxy hfwd hout ih =>
    exact Spread.step ih (hact _ (reachOutside_out hxy)) hfwd (hact _ hout)

/-- If, after the monitor phase, `out` is not empty and every non-monitor process sees a
reason to halt, the round violates neither goal and ends in a responded state. -/
theorem finish {sys : System M W B S} (ho : Ordinary sys) {s₁ : State M W}
    (hh : ∀ w, ¬ s₁.halted w)
    (hout : ∃ m, Out (monitorPhase sys s₁) m)
    (hsees : ∀ w, Sees sys (monitorPhase sys s₁) (Out (monitorPhase sys s₁)) w) :
    (¬ (afterEnv sys s₁).g1 ∧ ¬ (afterEnv sys s₁).g2) ∧
      Responded sys (afterEnv sys s₁).next := by
  rw [afterEnv_gate ho.gate_on]
  refine ⟨⟨fun h => h.2 hout, ?_⟩, ?_, ?_⟩
  · rintro ⟨_, w, hw⟩
    exact hw.2.2 ⟨hsees w, ho.no_window⟩
  · obtain ⟨m, hm⟩ := hout
    exact ⟨m, hm⟩
  · intro w hpres
    exact Or.inr ⟨⟨hpres, hh w⟩, Or.inr ⟨hsees w, ho.no_window⟩⟩

/-- The case of a single fault at a monitor `z`, stopped or mutated: every other monitor
is active, and every watcher of `z` detects. -/
theorem monitor_case {sys : System M W B S} (ho : Ordinary sys) (hs : Sufficient sys)
    {s₁ : State M W} (z : M) (hh : ∀ w, ¬ s₁.halted w)
    (hact : ∀ m, m ≠ z → Active s₁ m)
    (hdet : ∀ r, r ≠ z → Watches sys r z → Detects sys s₁ r) :
    (¬ (afterEnv sys s₁).g1 ∧ ¬ (afterEnv sys s₁).g2) ∧
      Responded sys (afterEnv sys s₁).next := by
  have hall : ∀ y, y ≠ z → Out (monitorPhase sys s₁) y := by
    intro y hy
    obtain ⟨r, hr, hw, hreach⟩ := hs.c z y hy
    have hflag : flaggedAfter sys s₁ y :=
      (flaggedAfter_fast ho.reports_fast s₁ y).2
        (spread_of_reachAvoiding hact (Or.inr (hdet r hr hw)) hreach)
    exact ⟨hflag, (hact y hy).1, (hact y hy).2.1⟩
  refine finish ho hh ?_ ?_
  · obtain ⟨r, hr, _⟩ := hs.a z
    exact ⟨r, hall r hr⟩
  · intro w
    obtain ⟨_, h₁, h₂, hne, hin₁, hin₂⟩ := hs.b w
    by_cases h : h₁ = z
    · exact Or.inl ⟨h₂, hin₂, hall h₂ (fun h' => hne (h.trans h'.symm))⟩
    · exact Or.inl ⟨h₁, hin₁, hall h₁ h⟩

/-- The case of a whole set `Z` of monitors lost in one step, when that loss is answered:
no monitor in `Z` is alive, and every monitor outside `Z` is active. Some process may be
bad. Every monitor outside `Z` ends in `out`; a non-monitor process sees a halt input
that is in `out`, or one that is not alive. -/
theorem loss_case {sys : System M W B S} (ho : Ordinary sys) (hs : Sufficient sys)
    {s₁ : State M W} (Z : M → Prop) (hla : LossAnswered sys Z)
    (hh : ∀ w, ¬ s₁.halted w)
    (hdead : ∀ m, Z m → ¬ s₁.alive (.inl m))
    (hact : ∀ m, ¬ Z m → Active s₁ m) :
    (¬ (afterEnv sys s₁).g1 ∧ ¬ (afterEnv sys s₁).g2) ∧
      Responded sys (afterEnv sys s₁).next := by
  have hall : ∀ y, ¬ Z y → Out (monitorPhase sys s₁) y := by
    intro y hy
    obtain ⟨r, p, hr, hp, hread, hreach⟩ := hla.2 y hy
    have hdet : Detects sys s₁ r := ⟨hact r hr, Or.inr ⟨p, hdead p hp, hread⟩⟩
    have hflag : flaggedAfter sys s₁ y :=
      (flaggedAfter_fast ho.reports_fast s₁ y).2
        (spread_of_reachOutside hact (Or.inr hdet) hreach)
    exact ⟨hflag, (hact y hy).1, (hact y hy).2.1⟩
  refine finish ho hh ?_ ?_
  · obtain ⟨y, hy⟩ := hla.1
    exact ⟨y, hall y hy⟩
  · intro w
    obtain ⟨_, h₁, _, _, hin₁, _⟩ := hs.b w
    by_cases hz : Z h₁
    · exact Or.inr ⟨ho.coupling_on, h₁, hin₁, hdead h₁ hz⟩
    · exact Or.inl ⟨h₁, hin₁, hall h₁ hz⟩

/-- The monitor and work phases from a quiet state: nothing is flagged, nothing halts,
neither goal is violated, and the state stays quiet. -/
theorem quiet_afterEnv {sys : System M W B S} (ho : Ordinary sys) {s₁ : State M W}
    (hq : Quiet s₁) :
    (¬ (afterEnv sys s₁).g1 ∧ ¬ (afterEnv sys s₁).g2) ∧ Quiet (afterEnv sys s₁).next := by
  have hnoflag : ∀ m, ¬ flaggedAfter sys s₁ m := by
    intro m hm
    rw [flaggedAfter_fast ho.reports_fast] at hm
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
  rw [afterEnv_gate ho.gate_on]
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

/-- One round from a quiet state violates neither goal, and ends quiet or responded. -/
theorem round_from_quiet {sys : System M W B S} (hf : sys.f = 1) (ho : Ordinary sys)
    (hs : SufficientWide sys) {s : State M W} (hq : Quiet s) {r : Outcome M W}
    (hr : Round sys s r) :
    (¬ r.g1 ∧ ¬ r.g2) ∧ (Quiet r.next ∨ Responded sys r.next) := by
  obtain ⟨steps, s₁, hlen, hrun, rfl⟩ := hr
  rw [hf] at hlen
  rcases envRun_le_one hrun hlen with rfl | ⟨e, he, rfl⟩
  · -- The environment takes no step: nothing changes.
    have := quiet_afterEnv ho hq
    exact ⟨this.1, Or.inl this.2⟩
  · -- The environment takes one step.
    cases e with
    | stop z =>
      have hact : ∀ m, m ≠ z → Active (effect sys s (.stop z)) m := fun m hm =>
        ⟨⟨hq.alive m, fun h => hm (Sum.inl.inj h)⟩, hq.bad _, hq.off m⟩
      have := monitor_case ho hs.single z (s₁ := effect sys s (.stop z)) hq.halted hact
        (fun r hr hw => ⟨hact r hr, Or.inr ⟨z, fun h => h.2 rfl, hw.2⟩⟩)
      exact ⟨this.1, Or.inr this.2⟩
    | stopBoundary b =>
      -- The monitors in `b` are lost together; those outside are untouched.
      obtain ⟨⟨m, m', hne, h₁, h₂⟩, _⟩ := he
      have hla : LossAnswered sys (InBoundary sys b) := hs.boundary b m m' hne h₁ h₂
      have hdead : ∀ m, InBoundary sys b m →
          ¬ (effect sys s (.stopBoundary b)).alive (.inl m) :=
        fun m hz h => h.2 m rfl hz
      have hact : ∀ m, ¬ InBoundary sys b m → Active (effect sys s (.stopBoundary b)) m :=
        fun m hz =>
          ⟨⟨hq.alive m, fun m' e => by cases e; exact hz⟩, hq.bad _, hq.off m⟩
      have := loss_case ho hs.single (s₁ := effect sys s (.stopBoundary b))
        (InBoundary sys b) hla hq.halted hdead hact
      exact ⟨this.1, Or.inr this.2⟩
    | failSubstrate c =>
      -- The monitors on `c` are lost together, and the present non-monitor processes on
      -- `c` become bad and hidden; the monitors off `c` are untouched.
      obtain ⟨p, _, hsub, _⟩ := he
      have hla : LossAnswered sys (OnSubstrate sys c) := hs.substrate c p hsub
      have hdead : ∀ m, OnSubstrate sys c m →
          ¬ (effect sys s (.failSubstrate c)).alive (.inl m) :=
        fun m hz h => h.2 m rfl hz
      have hact : ∀ m, ¬ OnSubstrate sys c m →
          Active (effect sys s (.failSubstrate c)) m := by
        intro m hz
        refine ⟨⟨hq.alive m, fun m' e => by cases e; exact hz⟩, ?_, hq.off m⟩
        rintro (h | ⟨w, hw, _⟩)
        · exact hq.bad _ h
        · cases hw
      have := loss_case ho hs.single (s₁ := effect sys s (.failSubstrate c))
        (OnSubstrate sys c) hla hq.halted hdead hact
      exact ⟨this.1, Or.inr this.2⟩
    | mutate p =>
      cases p with
      | inl z =>
        have hact : ∀ m, m ≠ z → Active (effect sys s (.mutate (.inl z))) m := by
          intro m hm
          refine ⟨hq.alive m, ?_, hq.off m⟩
          rintro (h | h)
          · exact hm (Sum.inl.inj h)
          · exact hq.bad _ h
        have := monitor_case ho hs.single z (s₁ := effect sys s (.mutate (.inl z)))
          hq.halted hact
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
        obtain ⟨k, hk, hreach⟩ := hs.single.d x
        have hdet : Detects sys (effect sys s (.mutate (.inr x))) k :=
          ⟨hact k, Or.inl ⟨.inr x, ⟨Or.inl rfl, hq.hidden _⟩, hk⟩⟩
        have hall : ∀ m, Out (monitorPhase sys (effect sys s (.mutate (.inr x)))) m := by
          intro m
          have hflag : flaggedAfter sys (effect sys s (.mutate (.inr x))) m :=
            (flaggedAfter_fast ho.reports_fast _ m).2
              (spread_of_reach hact (Or.inr hdet) (hreach m))
          exact ⟨hflag, (hact m).1, (hact m).2.1⟩
        have := finish ho (s₁ := effect sys s (.mutate (.inr x))) hq.halted ⟨k, hall k⟩
          (fun w => by
            obtain ⟨_, h₁, _, _, hin₁, _⟩ := hs.single.b w
            exact Or.inl ⟨h₁, hin₁, hall h₁⟩)
        exact ⟨this.1, Or.inr this.2⟩
    | disable m => exact absurd he.1 (ho.no_switch m)
    | join =>
      -- The joiner joins: the state is still quiet, and the round goes on as with no
      -- step.
      have hq' : Quiet (effect sys s .join) :=
        ⟨fun m => Or.inl (hq.alive m), hq.bad, hq.hidden, hq.off, hq.flagged, hq.halted,
          hq.pending⟩
      have := quiet_afterEnv ho hq'
      exact ⟨this.1, Or.inl this.2⟩

/-- Every state an execution reaches is quiet or responded. -/
theorem reachable_quiet_or_responded {sys : System M W B S} (hf : sys.f = 1)
    (ho : Ordinary sys) (hs : SufficientWide sys) {s : State M W} (h : Reachable sys s) :
    Quiet s ∨ Responded sys s := by
  induction h with
  | init => exact Or.inl (quiet_init sys)
  | round _ hnr hround ih =>
    rcases ih with hq | hresp
    · exact (round_from_quiet hf ho hs hq hround).2
    · exact absurd hresp hnr

/-- A system of the wider class that meets the conditions of `SufficientWide` has no gap
at one fault per round. -/
theorem theorem_S_wide (sys : System M W B S) (hf : sys.f = 1) (ho : Ordinary sys)
    (hs : SufficientWide sys) : NoGap sys := by
  intro s r hreach hnr hround
  rcases reachable_quiet_or_responded hf ho hs hreach with hq | hresp
  · exact (round_from_quiet hf ho hs hq hround).1
  · exact absurd hresp hnr

/-- Theorem S is a special case: a plain system that meets the four conditions is of the
wider class and meets its conditions. -/
theorem plain_is_wide (sys : System M W B S) (hp : Plain sys) (hs : Sufficient sys) :
    Ordinary sys ∧ SufficientWide sys := by
  refine ⟨⟨hp.no_switch, hp.coupling_on, hp.no_window, hp.gate_on, hp.reports_fast⟩,
    ⟨hs, ?_, ?_⟩⟩
  · intro c p hsub
    rw [hp.no_substrate p] at hsub
    cases hsub
  · intro b m m' hne h₁ h₂
    exact absurd ⟨h₁, h₂⟩ (hp.boundaries_distinct m m' b hne)

/-! ### The reference system -/

/-- In the reference system every monitor reads every other monitor's signal, so the loss
of a set of monitors is answered as soon as some monitor is in the set and some monitor
is outside it: each monitor outside reads the signal of the one inside. -/
theorem reference_lossAnswered (Z : Mon → Prop) (hin : ∃ p, Z p) (hout : ∃ y, ¬ Z y) :
    LossAnswered reference Z := by
  obtain ⟨p, hp⟩ := hin
  refine ⟨hout, fun y hy => ⟨y, p, hy, hp, ⟨rfl, fun e => hy (e ▸ hp)⟩,
    ReachOutside.refl hy⟩⟩

/-- In the reference system no two monitors share a boundary. -/
theorem reference_boundary_inj (m m' : Mon)
    (h : reference.boundary m = reference.boundary m') : m = m' := by
  cases m <;> cases m' <;> first | rfl | exact absurd h (by decide)

theorem reference_ordinary : Ordinary reference where
  no_switch := fun _ h => Bool.noConfusion h
  coupling_on := rfl
  no_window := rfl
  gate_on := rfl
  reports_fast := rfl

theorem reference_sufficient : Sufficient reference where
  a := fun z => by
    cases z
    · exact ⟨.M2, by decide, ⟨rfl, by decide⟩, ⟨rfl, by decide⟩⟩
    · exact ⟨.M1, by decide, ⟨rfl, by decide⟩, ⟨rfl, by decide⟩⟩
    · exact ⟨.M1, by decide, ⟨rfl, by decide⟩, ⟨rfl, by decide⟩⟩
  b := fun w => by
    cases w
    · exact ⟨⟨.M1, rfl, rfl⟩, .M1, .M3, by decide, Or.inl rfl, Or.inr ⟨rfl, rfl⟩⟩
    · exact ⟨⟨.M2, rfl, rfl⟩, .M2, .M3, by decide, Or.inl rfl, Or.inr ⟨rfl, rfl⟩⟩
    · exact ⟨⟨.M3, rfl, rfl, rfl⟩, .M3, .M1, by decide, ⟨rfl, Or.inl rfl⟩,
        ⟨rfl, Or.inr ⟨rfl, rfl⟩⟩⟩
  c := fun z y hy => ⟨y, hy, ⟨⟨rfl, hy⟩, ⟨rfl, hy⟩⟩, ReachAvoiding.refl hy⟩
  d := fun w => by
    have hreach : ∀ k m : Mon, Reach reference k m := by
      intro k m
      by_cases hm : m = k
      · rw [hm]
        exact Reach.refl k
      · exact Reach.step (Reach.refl k) ⟨rfl, hm⟩
    cases w
    · exact ⟨.M1, ⟨rfl, rfl⟩, hreach _⟩
    · exact ⟨.M2, ⟨rfl, rfl⟩, hreach _⟩
    · exact ⟨.M3, ⟨rfl, rfl, rfl⟩, hreach _⟩

/-- The reference system's result is a special case: the reference system is of the wider
class and meets its conditions. -/
theorem reference_is_wide : Ordinary reference ∧ SufficientWide reference := by
  refine ⟨reference_ordinary, ⟨reference_sufficient, ?_, ?_⟩⟩
  · intro c p hsub
    apply reference_lossAnswered
    · -- Some monitor runs on the substrate `c`.
      cases c
      · exact ⟨.M1, rfl⟩
      · exact ⟨.M2, rfl⟩
      · exact ⟨.M3, rfl⟩
      · rcases p with (_ | _ | _) | (_ | _ | _) <;> exact absurd hsub (by decide)
      · rcases p with (_ | _ | _) | (_ | _ | _) <;> exact absurd hsub (by decide)
    · -- Some monitor does not.
      cases c
      · exact ⟨.M2, fun (h : reference.substrate (.inl Mon.M2) = some Sub.s1) =>
          absurd h (by decide)⟩
      · exact ⟨.M1, fun (h : reference.substrate (.inl Mon.M1) = some Sub.s2) =>
          absurd h (by decide)⟩
      · exact ⟨.M1, fun (h : reference.substrate (.inl Mon.M1) = some Sub.s3) =>
          absurd h (by decide)⟩
      · exact ⟨.M1, fun (h : reference.substrate (.inl Mon.M1) = some Sub.s4) =>
          absurd h (by decide)⟩
      · exact ⟨.M1, fun (h : reference.substrate (.inl Mon.M1) = some Sub.s5) =>
          absurd h (by decide)⟩
  · intro b m m' hne h₁ h₂
    exact absurd (reference_boundary_inj m m' (h₁.trans h₂.symm)) hne

end Widening
end SelfObserving
