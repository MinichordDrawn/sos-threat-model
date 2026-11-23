/-
Proofs of the two statements of `Challenge.lean` under "More edges never hurt":
`lemma_M` and `lemma_M_joins`.

Both systems are run on the same schedule. A state of the first system and a state of the
second are related (`Rel`, and `JRel` for the model with joins) when they have the same
`alive`, `bad`, `hidden`, `off` and `joined` (and the same groups arrived), every monitor
flagged in the first is flagged in the second, every process halted in the first is halted
in the second, and `pending` is empty in both.

The file has these parts:

- the monitor and work phases of two systems of `Model.lean` in `MoreEdges` with no
  window, from related states (`afterEnv_sim`): the next states are related, and each goal
  violated in the second is violated in the first, in either order of the phases;
- the environment phase of the model with joins: a step enabled in the second system is
  enabled in the first (`jenabled_sim`), and its effects are related (`jeffect_rel`);
- the systems whose edges are the edges in force stand in `MoreEdges`
  (`effective_more`);
- a round of the second system is matched by a round of the first (`jround_sim`), and
  every reachable state of the second is related to a reachable state of the first
  (`jreachable_sim`);
- `lemma_M_joins`, and `lemma_M` from it by `JoinPlain.plainJoin_same`: two systems of
  `Model.lean` in `MoreEdges` are, with none of the new fields, two systems of the model
  with joins in `JMoreEdges`.
-/
import SelfObserving.MoreEdges
import SelfObserving.Proofs.JoinPlain

namespace SelfObserving
namespace MoreEdgesProofs

variable {M W B S : Type}

/-! ### Related states -/

/-- `Rel t₁ t₂`: a state of the first system and a state of the second on the same
schedule. They differ only in that the second may have more flags and more halted
processes; neither has a pending process. -/
structure Rel (t₁ t₂ : State M W) : Prop where
  alive : ∀ p, t₁.alive p ↔ t₂.alive p
  bad : ∀ p, t₁.bad p ↔ t₂.bad p
  hidden : ∀ p, t₁.hidden p ↔ t₂.hidden p
  off : ∀ m, t₁.off m ↔ t₂.off m
  joined : t₁.joined ↔ t₂.joined
  flagged : ∀ m, t₁.flagged m → t₂.flagged m
  halted : ∀ w, t₁.halted w → t₂.halted w
  pending₁ : ∀ w, ¬ t₁.pending w
  pending₂ : ∀ w, ¬ t₂.pending w

/-! ### The monitor phase -/

/-- The same monitors are active. -/
theorem active_iff {t₁ t₂ : State M W} (r : Rel t₁ t₂) (m : M) :
    Active t₁ m ↔ Active t₂ m :=
  and_congr (r.alive _) (and_congr (not_congr (r.bad _)) (not_congr (r.off _)))

/-- A monitor that detects in the first system detects in the second. -/
theorem detects_mono {a b : System M W B S} (h : MoreEdges a b) {t₁ t₂ : State M W}
    (r : Rel t₁ t₂) (m : M) : Detects a t₁ m → Detects b t₂ m := by
  rintro ⟨hact, ⟨x, hx, hc⟩ | ⟨p, hp, hr⟩⟩
  · exact ⟨(active_iff r m).1 hact,
      Or.inl ⟨x, ⟨(r.bad x).1 hx.1, fun hh => hx.2 ((r.hidden x).2 hh)⟩, h.check x m hc⟩⟩
  · exact ⟨(active_iff r m).1 hact,
      Or.inr ⟨p, fun ha => hp ((r.alive _).2 ha), h.hb p m hr⟩⟩

/-- A monitor flagged after step 1 in the first system is flagged after it in the
second. -/
theorem flaggedOrDetects_mono {a b : System M W B S} (h : MoreEdges a b)
    {t₁ t₂ : State M W} (r : Rel t₁ t₂) (m : M) :
    FlaggedOrDetects a t₁ m → FlaggedOrDetects b t₂ m := by
  rintro (hf | hd)
  · exact Or.inl (r.flagged m hf)
  · exact Or.inr (detects_mono h r m hd)

/-- Flags spread at least as far in the second system. -/
theorem spread_mono {a b : System M W B S} (h : MoreEdges a b) {t₁ t₂ : State M W}
    (r : Rel t₁ t₂) {F F' : M → Prop} (hF : ∀ m, F m → F' m) :
    ∀ m, Spread a t₁ F m → Spread b t₂ F' m := by
  intro m hm
  induction hm with
  | base hm => exact Spread.base (hF _ hm)
  | step _ ha hf hr ih =>
    exact Spread.step ih ((active_iff r _).1 ha) (h.fwd _ _ hf) ((active_iff r _).1 hr)

/-- A monitor flagged after the monitor phase in the first system is flagged after it in
the second, with prompt reports and with slow ones. -/
theorem flaggedAfter_mono {a b : System M W B S} (h : MoreEdges a b) {t₁ t₂ : State M W}
    (r : Rel t₁ t₂) (m : M) : flaggedAfter a t₁ m → flaggedAfter b t₂ m := by
  cases hs : b.slowReports with
  | true =>
    have hs' : a.slowReports = true := h.slowReports.trans hs
    unfold flaggedAfter
    rw [ite_eq_left hs, ite_eq_left hs']
    rintro (hd | ⟨m', hf, ha, hfw, hr⟩)
    · exact Or.inl (flaggedOrDetects_mono h r m hd)
    · exact Or.inr ⟨m', r.flagged m' hf, (active_iff r m').1 ha, h.fwd m' m hfw,
        (active_iff r m).1 hr⟩
  | false =>
    have hs' : a.slowReports = false := h.slowReports.trans hs
    unfold flaggedAfter
    rw [ite_eq_right (fun e => Bool.noConfusion (hs.symm.trans e)),
      ite_eq_right (fun e => Bool.noConfusion (hs'.symm.trans e))]
    exact spread_mono h r (flaggedOrDetects_mono h r) m

/-- The monitor phase keeps the states related. -/
theorem monitorPhase_rel {a b : System M W B S} (h : MoreEdges a b) {t₁ t₂ : State M W}
    (r : Rel t₁ t₂) : Rel (monitorPhase a t₁) (monitorPhase b t₂) where
  alive := r.alive
  bad := r.bad
  hidden := r.hidden
  off := r.off
  joined := r.joined
  flagged := flaggedAfter_mono h r
  halted := r.halted
  pending₁ := r.pending₁
  pending₂ := r.pending₂

/-- `out` of the first system is contained in `out` of the second. -/
theorem out_mono {t₁ t₂ : State M W} (r : Rel t₁ t₂) (m : M) : Out t₁ m → Out t₂ m :=
  fun hm => ⟨r.flagged m hm.1, (r.alive _).1 hm.2.1, fun hb => hm.2.2 ((r.bad _).2 hb)⟩

/-! ### The work phase -/

/-- The same non-monitor processes are present. -/
theorem present_iff {a b : System M W B S} (h : MoreEdges a b) {t₁ t₂ : State M W}
    (r : Rel t₁ t₂) (w : W) : Present a t₁ (.inr w) ↔ Present b t₂ (.inr w) :=
  ⟨fun f hj => r.joined.1 (f (h.joiner.trans hj)),
    fun f hj => r.joined.2 (f (h.joiner.symm.trans hj))⟩

/-- A process that sees a reason to halt in the first system sees one in the second. -/
theorem sees_mono {a b : System M W B S} (h : MoreEdges a b) {t₁ t₂ : State M W}
    (r : Rel t₁ t₂) {o₁ o₂ : M → Prop} (ho : ∀ m, o₁ m → o₂ m) (w : W) :
    Sees a t₁ o₁ w → Sees b t₂ o₂ w := by
  rintro (⟨m, hin, hm⟩ | ⟨hc, m, hin, hm⟩)
  · exact Or.inl ⟨m, h.halt w m hin, ho m hm⟩
  · exact Or.inr ⟨h.coupling.symm.trans hc, m, h.halt w m hin,
      fun ha => hm ((r.alive _).2 ha)⟩

/-- The work phase keeps the states related. With no window nothing becomes pending, and a
process that halts in the first system is halted already in the second, or is handled
there and sees a reason to halt. -/
theorem workPhase_rel {a b : System M W B S} (h : MoreEdges a b) (hw : a.window = 0)
    {t₁ t₂ : State M W} (r : Rel t₁ t₂) {o₁ o₂ : M → Prop} (ho : ∀ m, o₁ m → o₂ m) :
    Rel (workPhase a t₁ o₁) (workPhase b t₂ o₂) where
  alive := r.alive
  bad := r.bad
  hidden := r.hidden
  off := r.off
  joined := r.joined
  flagged := r.flagged
  halted := by
    intro w hh
    show t₂.halted w ∨ (Handled b t₂ w ∧ (t₂.pending w ∨ (Sees b t₂ o₂ w ∧ b.window = 0)))
    have hh' : t₁.halted w ∨
        (Handled a t₁ w ∧ (t₁.pending w ∨ (Sees a t₁ o₁ w ∧ a.window = 0))) := hh
    rcases hh' with hh' | ⟨hH, hp | ⟨hs, _⟩⟩
    · exact Or.inl (r.halted w hh')
    · exact absurd hp (r.pending₁ w)
    · by_cases h2 : t₂.halted w
      · exact Or.inl h2
      · exact Or.inr ⟨⟨(present_iff h r w).1 hH.1, h2⟩,
          Or.inr ⟨sees_mono h r ho w hs, h.window.symm.trans hw⟩⟩
  pending₁ := by
    intro w hp
    have hp' : (t₁.pending w ∧ ¬ Handled a t₁ w) ∨
        (Handled a t₁ w ∧ ¬ t₁.pending w ∧ Sees a t₁ o₁ w ∧ a.window ≠ 0) := hp
    rcases hp' with ⟨hp', _⟩ | ⟨_, _, _, hne⟩
    · exact r.pending₁ w hp'
    · exact hne hw
  pending₂ := by
    intro w hp
    have hp' : (t₂.pending w ∧ ¬ Handled b t₂ w) ∨
        (Handled b t₂ w ∧ ¬ t₂.pending w ∧ Sees b t₂ o₂ w ∧ b.window ≠ 0) := hp
    rcases hp' with ⟨hp', _⟩ | ⟨_, _, _, hne⟩
    · exact r.pending₂ w hp'
    · exact hne (h.window.symm.trans hw)

/-- A process that takes a work step in the second system takes one in the first: it is
not halted there, not pending, and sees no reason to halt. -/
theorem worked_anti {a b : System M W B S} (h : MoreEdges a b) {t₁ t₂ : State M W}
    (r : Rel t₁ t₂) {o₁ o₂ : M → Prop} (ho : ∀ m, o₁ m → o₂ m) (w : W) :
    Worked b t₂ o₂ w → Worked a t₁ o₁ w := by
  rintro ⟨hH, _, hns⟩
  exact ⟨⟨(present_iff h r w).2 hH.1, fun hh => hH.2 (r.halted w hh)⟩, r.pending₁ w,
    fun hs => hns ⟨sees_mono h r ho w hs.1, h.window.symm.trans hs.2⟩⟩

/-! ### The two phases after the environment phase -/

/-- The monitor and work phases of two systems in `MoreEdges` with no window, from related
states, in either order of the phases: the next states are related, and each goal violated
in the second system is violated in the first. -/
theorem afterEnv_sim {a b : System M W B S} (h : MoreEdges a b) (hw : a.window = 0)
    {t₁ t₂ : State M W} (r : Rel t₁ t₂) :
    Rel (afterEnv a t₁).next (afterEnv b t₂).next ∧
      ((afterEnv b t₂).g1 → (afterEnv a t₁).g1) ∧
      ((afterEnv b t₂).g2 → (afterEnv a t₁).g2) := by
  cases hg : b.gate with
  | true =>
    rw [JoinPlain.afterEnv_gate a t₁ (h.gate.trans hg), JoinPlain.afterEnv_gate b t₂ hg]
    have rm : Rel (monitorPhase a t₁) (monitorPhase b t₂) := monitorPhase_rel h r
    refine ⟨workPhase_rel h hw rm (out_mono rm), ?_, ?_⟩
    · rintro ⟨⟨p, hp⟩, hno⟩
      exact ⟨⟨p, (rm.bad p).2 hp⟩, fun ⟨m, hm⟩ => hno ⟨m, out_mono rm m hm⟩⟩
    · rintro ⟨⟨p, hp⟩, w, hwk⟩
      exact ⟨⟨p, (rm.bad p).2 hp⟩, w, worked_anti h rm (out_mono rm) w hwk⟩
  | false =>
    rw [JoinPlain.afterEnv_noGate a t₁ (h.gate.trans hg),
      JoinPlain.afterEnv_noGate b t₂ hg]
    have rk : Rel (workPhase a t₁ (Out t₁)) (workPhase b t₂ (Out t₂)) :=
      workPhase_rel h hw r (out_mono r)
    have rm : Rel (monitorPhase a (workPhase a t₁ (Out t₁)))
        (monitorPhase b (workPhase b t₂ (Out t₂))) := monitorPhase_rel h rk
    refine ⟨rm, ?_, ?_⟩
    · rintro ⟨⟨p, hp⟩, hno⟩
      exact ⟨⟨p, (rm.bad p).2 hp⟩, fun ⟨m, hm⟩ => hno ⟨m, out_mono rm m hm⟩⟩
    · rintro ⟨⟨p, hp⟩, w, hwk⟩
      exact ⟨⟨p, (r.bad p).2 hp⟩, w, worked_anti h r (out_mono r) w hwk⟩

/-! ### The model with joins: related states and the environment phase -/

section Joins

variable {G : Type}

/-- Related states of the model with joins: related components of `Model.lean`, and the
same groups arrived. -/
structure JRel (s₁ s₂ : JState M W G) : Prop where
  st : Rel s₁.st s₂.st
  arrived : ∀ g, s₁.arrived g ↔ s₂.arrived g

/-- The same processes are present. -/
theorem jpresent_iff {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    {s₁ s₂ : JState M W G} (r : JRel s₁ s₂) (p : Proc M W) :
    JPresent sys₁ s₁ p ↔ JPresent sys₂ s₂ p := by
  cases p with
  | inl m =>
    exact ⟨fun f g hg => (r.arrived g).1 (f g ((h.group m).trans hg)),
      fun f g hg => (r.arrived g).2 (f g ((h.group m).symm.trans hg))⟩
  | inr w =>
    exact ⟨fun f hj => r.st.joined.1 (f (h.base.joiner.trans hj)),
      fun f hj => r.st.joined.2 (f (h.base.joiner.symm.trans hj))⟩

/-- The groups have the same members. -/
theorem jmember_iff {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂) (g : G)
    (p : Proc M W) : JMember sys₁ g p ↔ JMember sys₂ g p := by
  cases p with
  | inl m =>
    exact ⟨fun hm => (h.group m).symm.trans hm, fun hm => (h.group m).trans hm⟩
  | inr w =>
    exact ⟨fun hm => ⟨h.base.joiner.symm.trans hm.1, h.joinerGroup.symm.trans hm.2⟩,
      fun hm => ⟨h.base.joiner.trans hm.1, h.joinerGroup.trans hm.2⟩⟩

/-- A group may join in the one system exactly when it may in the other. -/
theorem joinEnabled_iff {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    {s₁ s₂ : JState M W G} (r : JRel s₁ s₂) (g : G) :
    JoinEnabled sys₁ s₁ g ↔ JoinEnabled sys₂ s₂ g :=
  and_congr (not_congr (r.arrived g))
    ⟨fun f p hp => (jpresent_iff h r p).1 (f p ((h.after g p).2 hp)),
      fun f p hp => (jpresent_iff h r p).2 (f p ((h.after g p).1 hp))⟩

/-- An environment step enabled in the second system is enabled in the first: whether a
step is enabled reads no edge, no flag and no halted process. -/
theorem jenabled_sim {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    {s₁ s₂ : JState M W G} (r : JRel s₁ s₂) (e : JStep M W B S G) :
    JEnabled sys₂ s₂ e → JEnabled sys₁ s₁ e := by
  cases e with
  | stop m =>
    exact fun ⟨hp, ha⟩ => ⟨(jpresent_iff h r _).2 hp, (r.st.alive _).2 ha⟩
  | stopBoundary b =>
    rintro ⟨⟨m, m', hne, hb, hb', hp, hp'⟩, m₀, hb₀, hp₀, ha⟩
    exact ⟨⟨m, m', hne, (h.base.boundary m).trans hb, (h.base.boundary m').trans hb',
        (jpresent_iff h r _).2 hp, (jpresent_iff h r _).2 hp'⟩,
      m₀, (h.base.boundary m₀).trans hb₀, (jpresent_iff h r _).2 hp₀, (r.st.alive _).2 ha⟩
  | failSubstrate c =>
    rintro ⟨p, hp, hsub, hm⟩
    refine ⟨p, (jpresent_iff h r p).2 hp, (h.base.substrate p).trans hsub, ?_⟩
    cases p with
    | inl m => exact (r.st.alive _).2 hm
    | inr w => exact fun hb => hm ((r.st.bad _).1 hb)
  | mutate p =>
    exact fun ⟨hp, hb⟩ => ⟨(jpresent_iff h r p).2 hp, fun hb' => hb ((r.st.bad p).1 hb')⟩
  | disable m =>
    exact fun ⟨hp, hsw, hoff⟩ => ⟨(jpresent_iff h r _).2 hp, (h.base.switches m).2 hsw,
      fun ho => hoff ((r.st.off m).1 ho)⟩
  | join =>
    exact fun ⟨hj, hjg, hnj⟩ => ⟨fun e => hj (h.base.joiner.symm.trans e),
      h.joinerGroup.trans hjg, fun hj' => hnj (r.st.joined.1 hj')⟩
  | joinGroup g => exact (joinEnabled_iff h r g).2
  | joinBad g m =>
    exact fun ⟨hab, hje, hg⟩ => ⟨h.arriveBad.trans hab, (joinEnabled_iff h r g).2 hje,
      (h.group m).trans hg⟩

/-- The same processes are struck by a failed substrate. -/
theorem jstruck_iff {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    {s₁ s₂ : JState M W G} (r : JRel s₁ s₂) (c : S) (p : Proc M W) :
    JStruck sys₁ s₁ c p ↔ JStruck sys₂ s₂ c p :=
  ⟨fun ⟨w, hw, hp, hs⟩ =>
      ⟨w, hw, (jpresent_iff h r p).1 hp, (h.base.substrate p).symm.trans hs⟩,
    fun ⟨w, hw, hp, hs⟩ =>
      ⟨w, hw, (jpresent_iff h r p).2 hp, (h.base.substrate p).trans hs⟩⟩

/-- The effect of a group's step keeps the states related. -/
theorem joinEffect_rel {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    {s₁ s₂ : JState M W G} (r : JRel s₁ s₂) (g : G) :
    JRel (joinEffect sys₁ s₁ g) (joinEffect sys₂ s₂ g) where
  st :=
    { alive := fun p => or_congr (r.st.alive p) (jmember_iff h g p)
      bad := r.st.bad
      hidden := r.st.hidden
      off := r.st.off
      joined := or_congr r.st.joined
        ⟨fun ⟨w, hw⟩ => ⟨w, (jmember_iff h g _).1 hw⟩,
          fun ⟨w, hw⟩ => ⟨w, (jmember_iff h g _).2 hw⟩⟩
      flagged := r.st.flagged
      halted := r.st.halted
      pending₁ := r.st.pending₁
      pending₂ := r.st.pending₂ }
  arrived := fun g' => or_congr Iff.rfl (r.arrived g')

/-- The effect of an environment step keeps the states related: it reads and writes only
`alive`, `bad`, `hidden`, `off`, `joined` and the groups arrived, through fields that are
the same in both systems. -/
theorem jeffect_rel {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    {s₁ s₂ : JState M W G} (r : JRel s₁ s₂) (e : JStep M W B S G) :
    JRel (jeffect sys₁ s₁ e) (jeffect sys₂ s₂ e) := by
  cases e with
  | stop m =>
    exact
      { st :=
          { alive := fun p => and_congr (r.st.alive p) Iff.rfl
            bad := r.st.bad
            hidden := r.st.hidden
            off := r.st.off
            joined := r.st.joined
            flagged := r.st.flagged
            halted := r.st.halted
            pending₁ := r.st.pending₁
            pending₂ := r.st.pending₂ }
        arrived := r.arrived }
  | stopBoundary b =>
    exact
      { st :=
          { alive := fun p => and_congr (r.st.alive p)
              ⟨fun f m hm hb => f m hm
                  ⟨(h.base.boundary m).trans hb.1, (jpresent_iff h r _).2 hb.2⟩,
                fun f m hm hb => f m hm
                  ⟨(h.base.boundary m).symm.trans hb.1, (jpresent_iff h r _).1 hb.2⟩⟩
            bad := r.st.bad
            hidden := r.st.hidden
            off := r.st.off
            joined := r.st.joined
            flagged := r.st.flagged
            halted := r.st.halted
            pending₁ := r.st.pending₁
            pending₂ := r.st.pending₂ }
        arrived := r.arrived }
  | failSubstrate c =>
    exact
      { st :=
          { alive := fun p => and_congr (r.st.alive p)
              ⟨fun f m hm hb => f m hm
                  ⟨(h.base.substrate p).trans hb.1, (jpresent_iff h r p).2 hb.2⟩,
                fun f m hm hb => f m hm
                  ⟨(h.base.substrate p).symm.trans hb.1, (jpresent_iff h r p).1 hb.2⟩⟩
            bad := fun p => or_congr (r.st.bad p) (jstruck_iff h r c p)
            hidden := fun p => or_congr (r.st.hidden p) (jstruck_iff h r c p)
            off := r.st.off
            joined := r.st.joined
            flagged := r.st.flagged
            halted := r.st.halted
            pending₁ := r.st.pending₁
            pending₂ := r.st.pending₂ }
        arrived := r.arrived }
  | mutate p =>
    exact
      { st :=
          { alive := r.st.alive
            bad := fun q => or_congr Iff.rfl (r.st.bad q)
            hidden := r.st.hidden
            off := r.st.off
            joined := r.st.joined
            flagged := r.st.flagged
            halted := r.st.halted
            pending₁ := r.st.pending₁
            pending₂ := r.st.pending₂ }
        arrived := r.arrived }
  | disable m =>
    exact
      { st :=
          { alive := r.st.alive
            bad := r.st.bad
            hidden := r.st.hidden
            off := fun x => or_congr Iff.rfl (r.st.off x)
            joined := r.st.joined
            flagged := r.st.flagged
            halted := r.st.halted
            pending₁ := r.st.pending₁
            pending₂ := r.st.pending₂ }
        arrived := r.arrived }
  | join =>
    exact
      { st :=
          { alive := fun p => or_congr (r.st.alive p)
              ⟨fun ⟨w, hw, hj⟩ => ⟨w, hw, h.base.joiner.symm.trans hj⟩,
                fun ⟨w, hw, hj⟩ => ⟨w, hw, h.base.joiner.trans hj⟩⟩
            bad := r.st.bad
            hidden := r.st.hidden
            off := r.st.off
            joined := Iff.rfl
            flagged := r.st.flagged
            halted := r.st.halted
            pending₁ := r.st.pending₁
            pending₂ := r.st.pending₂ }
        arrived := r.arrived }
  | joinGroup g => exact joinEffect_rel h r g
  | joinBad g m =>
    have jr : JRel (joinEffect sys₁ s₁ g) (joinEffect sys₂ s₂ g) := joinEffect_rel h r g
    exact
      { st :=
          { alive := jr.st.alive
            bad := fun q => or_congr Iff.rfl (jr.st.bad q)
            hidden := jr.st.hidden
            off := jr.st.off
            joined := jr.st.joined
            flagged := jr.st.flagged
            halted := jr.st.halted
            pending₁ := jr.st.pending₁
            pending₂ := jr.st.pending₂ }
        arrived := jr.arrived }

/-- An environment phase of the second system is one of the first, on the same steps, from
related states to related states. -/
theorem jenvRun_sim {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    {s₂ t₂ : JState M W G} {steps : List (JStep M W B S G)}
    (hrun : JEnvRun sys₂ s₂ steps t₂) :
    ∀ s₁ : JState M W G, JRel s₁ s₂ →
      ∃ t₁ : JState M W G, JEnvRun sys₁ s₁ steps t₁ ∧ JRel t₁ t₂ := by
  induction hrun with
  | nil s => exact fun s₁ r => ⟨s₁, JEnvRun.nil s₁, r⟩
  | @cons s s' e es he _ ih =>
    intro s₁ r
    obtain ⟨t₁, hrun₁, rt⟩ := ih _ (jeffect_rel h r e)
    exact ⟨t₁, JEnvRun.cons (jenabled_sim h r e he) hrun₁, rt⟩

/-! ### The edges in force -/

/-- The same processes became present in the environment phase. -/
theorem jnew_iff {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    {s₁ s₂ t₁ t₂ : JState M W G} (r : JRel s₁ s₂) (rt : JRel t₁ t₂) (p : Proc M W) :
    JNew sys₁ s₁ t₁ p ↔ JNew sys₂ s₂ t₂ p :=
  and_congr (jpresent_iff h rt p) (not_congr (jpresent_iff h r p))

/-- An edge in force in the first system is in force in the second, when it is slow in the
first if it is slow in the second: both ends are present in both, and neither end is
new. -/
theorem inForce_mono {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    {s₁ s₂ t₁ t₂ : JState M W G} (r : JRel s₁ s₂) (rt : JRel t₁ t₂) (p q : Proc M W)
    {slow₁ slow₂ : Prop} (hslow : slow₂ → slow₁) :
    InForce sys₁ s₁ t₁ p q slow₁ → InForce sys₂ s₂ t₂ p q slow₂ :=
  fun hin => ⟨(jpresent_iff h rt p).1 hin.1, (jpresent_iff h rt q).1 hin.2.1,
    fun hs => ⟨fun hn => (hin.2.2 (hslow hs)).1 ((jnew_iff h r rt p).2 hn),
      fun hn => (hin.2.2 (hslow hs)).2 ((jnew_iff h r rt q).2 hn)⟩⟩

/-- The systems whose edges are the edges in force stand in `MoreEdges`, for rounds that
start in related states and whose environment phases end in related states. -/
theorem effective_more {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    {s₁ s₂ t₁ t₂ : JState M W G} (r : JRel s₁ s₂) (rt : JRel t₁ t₂) :
    MoreEdges (effective sys₁ s₁ t₁) (effective sys₂ s₂ t₂) where
  f := h.base.f
  joiner := h.base.joiner
  boundary := h.base.boundary
  substrate := h.base.substrate
  switches := h.base.switches
  coupling := h.base.coupling
  window := h.base.window
  gate := h.base.gate
  slowReports := h.base.slowReports
  hb := fun p m he =>
    ⟨h.base.hb p m he.1, inForce_mono h r rt _ _ (h.slow_hb p m he.1) he.2⟩
  check := fun x m he =>
    ⟨h.base.check x m he.1, inForce_mono h r rt _ _ (h.slow_check x m he.1) he.2⟩
  fwd := fun m m' he =>
    ⟨h.base.fwd m m' he.1, inForce_mono h r rt _ _ (h.slow_fwd m m' he.1) he.2⟩
  halt := fun w m he =>
    ⟨h.base.halt w m he.1, inForce_mono h r rt _ _ (h.slow_halt w m he.1) he.2⟩

/-! ### Rounds and reachable states -/

/-- A round of the second system from `s₂` is matched by a round of the first from a
related state: the next states are related, and each goal violated in the round of the
second is violated in the round of the first. -/
theorem jround_sim {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    (hw : sys₁.base.window = 0) {s₁ s₂ : JState M W G} (r : JRel s₁ s₂)
    {o₂ : JOutcome M W G} (hround : JRound sys₂ s₂ o₂) :
    ∃ o₁ : JOutcome M W G, JRound sys₁ s₁ o₁ ∧ JRel o₁.next o₂.next ∧
      (o₂.g1 → o₁.g1) ∧ (o₂.g2 → o₁.g2) := by
  obtain ⟨steps, t₂, hlen, hrun, rfl⟩ := hround
  obtain ⟨t₁, hrun₁, rt⟩ := jenvRun_sim h hrun s₁ r
  have hw' : (effective sys₁ s₁ t₁).window = 0 := hw
  have core := afterEnv_sim (effective_more h r rt) hw' rt.st
  exact ⟨jafterEnv sys₁ s₁ t₁,
    ⟨steps, t₁, Nat.le_trans hlen (Nat.le_of_eq h.base.f.symm), hrun₁, rfl⟩,
    ⟨core.1, rt.arrived⟩, core.2.1, core.2.2⟩

/-- A state responded in the first system is responded in the second. -/
theorem jresponded_mono {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    {s₁ s₂ : JState M W G} (r : JRel s₁ s₂) :
    JResponded sys₁ s₁ → JResponded sys₂ s₂ := by
  rintro ⟨⟨m, hf, ha, hb⟩, hall⟩
  exact ⟨⟨m, r.st.flagged m hf, (r.st.alive _).1 ha, fun hb' => hb ((r.st.bad _).2 hb')⟩,
    fun w hp => r.st.halted w (hall w (fun hj =>
      r.st.joined.2 (hp (h.base.joiner.symm.trans hj))))⟩

/-- The initial states are related. -/
theorem jinit_rel {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂) :
    JRel (jinit sys₁) (jinit sys₂) where
  st :=
    { alive := by
        intro p
        cases p with
        | inl m =>
          exact ⟨fun hm => (h.group m).symm.trans hm, fun hm => (h.group m).trans hm⟩
        | inr w =>
          exact ⟨fun hn hj => hn (h.base.joiner.trans hj),
            fun hn hj => hn (h.base.joiner.symm.trans hj)⟩
      bad := fun _ => Iff.rfl
      hidden := fun _ => Iff.rfl
      off := fun _ => Iff.rfl
      joined := Iff.rfl
      flagged := fun _ hf => hf
      halted := fun _ hh => hh
      pending₁ := fun _ hp => hp
      pending₂ := fun _ hp => hp }
  arrived := fun _ => Iff.rfl

/-- Every reachable state of the second system is related to a reachable state of the
first. -/
theorem jreachable_sim {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    (hw : sys₁.base.window = 0) {s₂ : JState M W G} (hreach : JReachable sys₂ s₂) :
    ∃ s₁ : JState M W G, JReachable sys₁ s₁ ∧ JRel s₁ s₂ := by
  induction hreach with
  | init => exact ⟨jinit sys₁, JReachable.init, jinit_rel h⟩
  | round _ hresp hround ih =>
    obtain ⟨s₁, hreach₁, r⟩ := ih
    obtain ⟨o₁, hround₁, rn, _, _⟩ := jround_sim h hw r hround
    exact ⟨o₁.next,
      JReachable.round hreach₁ (fun hr => hresp (jresponded_mono h r hr)) hround₁, rn⟩

/-- A round of an execution of the second system is matched by a round of an execution of
the first in which every goal violated in the round of the second is violated. -/
theorem jviolation_sim {sys₁ sys₂ : JSystem M W B S G} (h : JMoreEdges sys₁ sys₂)
    (hw : sys₁.base.window = 0) {s₂ : JState M W G} {o₂ : JOutcome M W G}
    (hreach : JReachable sys₂ s₂) (hresp : ¬ JResponded sys₂ s₂)
    (hround : JRound sys₂ s₂ o₂) :
    ∃ (s₁ : JState M W G) (o₁ : JOutcome M W G), JReachable sys₁ s₁ ∧
      ¬ JResponded sys₁ s₁ ∧ JRound sys₁ s₁ o₁ ∧ (o₂.g1 → o₁.g1) ∧ (o₂.g2 → o₁.g2) := by
  obtain ⟨s₁, hreach₁, r⟩ := jreachable_sim h hw hreach
  obtain ⟨o₁, hround₁, _, h1, h2⟩ := jround_sim h hw r hround
  exact ⟨s₁, o₁, hreach₁, fun hr => hresp (jresponded_mono h r hr), hround₁, h1, h2⟩

end Joins

/-! ### The two statements -/

/-- Lemma M, for the model with joins. Let two systems with no window differ only in that
the second has more edges, or has an edge prompt that is slow in the first. Then each
goal that can be violated in the second can be violated in the first, and if the first
has no gap, neither has the second. -/
theorem lemma_M_joins {G : Type} (sys₁ sys₂ : JSystem M W B S G) (h : JMoreEdges sys₁ sys₂)
    (hw : sys₁.base.window = 0) :
    (JViolatesG1 sys₂ → JViolatesG1 sys₁) ∧ (JViolatesG2 sys₂ → JViolatesG2 sys₁) ∧
      (JNoGap sys₁ → JNoGap sys₂) := by
  refine ⟨?_, ?_, ?_⟩
  · rintro ⟨s₂, o₂, hreach, hresp, hround, hg⟩
    obtain ⟨s₁, o₁, hreach₁, hresp₁, hround₁, h1, _⟩ :=
      jviolation_sim h hw hreach hresp hround
    exact ⟨s₁, o₁, hreach₁, hresp₁, hround₁, h1 hg⟩
  · rintro ⟨s₂, o₂, hreach, hresp, hround, hg⟩
    obtain ⟨s₁, o₁, hreach₁, hresp₁, hround₁, _, h2⟩ :=
      jviolation_sim h hw hreach hresp hround
    exact ⟨s₁, o₁, hreach₁, hresp₁, hround₁, h2 hg⟩
  · intro hno s₂ o₂ hreach hresp hround
    obtain ⟨s₁, o₁, hreach₁, hresp₁, hround₁, h1, h2⟩ :=
      jviolation_sim h hw hreach hresp hround
    have hn := hno s₁ o₁ hreach₁ hresp₁ hround₁
    exact ⟨fun hg => hn.1 (h1 hg), fun hg => hn.2 (h2 hg)⟩

/-- Two systems of `Model.lean` in `MoreEdges` are, with none of the new fields, two
systems of the model with joins in `JMoreEdges`. -/
theorem plainJoin_more {sys₁ sys₂ : System M W B S} (h : MoreEdges sys₁ sys₂) :
    JMoreEdges (plainJoin sys₁) (plainJoin sys₂) where
  base := h
  group := fun _ => rfl
  joinerGroup := rfl
  after := fun _ _ => Iff.rfl
  arriveBad := rfl
  slow_hb := fun _ _ _ hs => hs
  slow_check := fun _ _ _ hs => hs
  slow_fwd := fun _ _ _ hs => hs
  slow_halt := fun _ _ _ hs => hs

/-- Lemma M, for the model of `Model.lean`. Let two systems with no window differ only in
that the second has more edges. Then each goal that can be violated in the second can be
violated in the first, and if the first has no gap, neither has the second. -/
theorem lemma_M (sys₁ sys₂ : System M W B S) (h : MoreEdges sys₁ sys₂)
    (hw : sys₁.window = 0) :
    (ViolatesG1 sys₂ → ViolatesG1 sys₁) ∧ (ViolatesG2 sys₂ → ViolatesG2 sys₁) ∧
      (NoGap sys₁ → NoGap sys₂) := by
  obtain ⟨m1, m2, m3⟩ :=
    lemma_M_joins (plainJoin sys₁) (plainJoin sys₂) (plainJoin_more h) hw
  have p1 := JoinPlain.plainJoin_same sys₁
  have p2 := JoinPlain.plainJoin_same sys₂
  exact ⟨fun v => p1.2.1.1 (m1 (p2.2.1.2 v)), fun v => p1.2.2.1 (m2 (p2.2.2.2 v)),
    fun n => p2.1.1 (m3 (p1.1.2 n))⟩

end MoreEdgesProofs
end SelfObserving
