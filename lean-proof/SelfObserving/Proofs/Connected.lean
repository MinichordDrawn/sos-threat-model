/-
No gap at any number of faults per round (`results-join.md`, section 3): Theorem J, its
one-way form, and Theorem F, for plain systems with nothing joining (`AnyRate.lean`).

All three are proved by the invariant of Theorem S and of `MeshRate.lean`: every state an
execution reaches is quiet or responded. A round from a quiet state takes at most `f`
environment steps. In a plain system only `stop` and `mutate` are ever enabled, and each
touches at most one monitor. So after the environment phase there is a list `ts` of
monitors, no longer than the number of steps, outside which every monitor is alive and not
bad; nothing is hidden, off, flagged, halted or pending; and, if a step was taken, some
monitor is not alive or some process is bad. What is left to each theorem is to show that
its conditions answer such a state: after the monitor phase `out` is not empty and holds a
halt input of every work process. `MeshRate.finish` then gives a round that violates
neither goal and ends responded.

`MeshRate.lean` proves the environment phase for the mesh only. It is proved again here
for every plain system, on the same structure `MeshRate.Env`.
-/
import SelfObserving.AnyRate
import SelfObserving.Proofs.MeshRate

namespace SelfObserving
namespace Connected

variable {M W B S : Type}

/-! ### The environment phase of a plain system from a quiet state -/

/-- One enabled step of a plain system is `stop` or `mutate`. It touches at most one
monitor, and leaves its mark. -/
theorem plain_env_step {sys : System M W B S} (hp : Plain sys) {s : State M W}
    {e : EnvStep M W B S} {ts : List M} (he : Enabled sys s e) (h : MeshRate.Env s ts) :
    ∃ ts', ts'.length ≤ ts.length + 1 ∧ MeshRate.Env (effect sys s e) ts' ∧
      MeshRate.Touched (effect sys s e) := by
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

/-- A run of environment steps of a plain system touches at most as many monitors as it
has steps, and, if it has any step or a mark was there before, leaves a mark. -/
theorem plain_env_run {sys : System M W B S} (hp : Plain sys) {s s₁ : State M W}
    {es : List (EnvStep M W B S)} (hrun : EnvRun sys s es s₁) :
    ∀ ts, MeshRate.Env s ts →
      ∃ ts', ts'.length ≤ ts.length + es.length ∧ MeshRate.Env s₁ ts' ∧
        (MeshRate.Touched s ∨ es ≠ [] → MeshRate.Touched s₁) := by
  induction hrun with
  | nil s =>
    intro ts h
    refine ⟨ts, Nat.le_refl _, h, ?_⟩
    rintro (h' | h')
    · exact h'
    · exact absurd rfl h'
  | cons he _ ih =>
    intro ts h
    obtain ⟨ts₁, hl₁, h₁, ht₁⟩ := plain_env_step hp he h
    obtain ⟨ts₂, hl₂, h₂, ht₂⟩ := ih ts₁ h₁
    refine ⟨ts₂, ?_, h₂, fun _ => ht₂ (Or.inl ht₁)⟩
    simp only [List.length_cons]
    omega

/-! ### The invariant, for any plain system whose wiring answers the environment -/

/-- The wiring answers the environment: from every state that the environment phase of a
round from a quiet state can reach by at least one step (at most `sys.f` monitors touched,
a mark left), after the monitor phase `out` is not empty and holds a halt input of every
work process. -/
def Answered (sys : System M W B S) : Prop :=
  ∀ (s₁ : State M W) (ts : List M), ts.length ≤ sys.f → MeshRate.Env s₁ ts →
    MeshRate.Touched s₁ →
    (∃ m, Out (monitorPhase sys s₁) m) ∧
      ∀ w, ∃ h, sys.haltInputs w h ∧ Out (monitorPhase sys s₁) h

/-- One round of an answered plain system from a quiet state violates neither goal, and
ends quiet or responded. -/
theorem round_from_quiet {sys : System M W B S} (hp : Plain sys) (hans : Answered sys)
    {s : State M W} (hq : MeshRate.Quiet s) {r : Outcome M W} (hr : Round sys s r) :
    (¬ r.g1 ∧ ¬ r.g2) ∧ (MeshRate.Quiet r.next ∨ Responded sys r.next) := by
  obtain ⟨steps, s₁, hl, hrun, rfl⟩ := hr
  cases hrun with
  | nil =>
    -- The environment takes no step: nothing changes.
    have := MeshRate.quiet_stays hp hq
    exact ⟨this.1, Or.inl this.2⟩
  | @cons _ _ e es he hrest =>
    -- The environment takes at least one step, and at most `sys.f`.
    obtain ⟨ts, hlts, henv, htouch⟩ :=
      plain_env_run hp (EnvRun.cons he hrest) [] (MeshRate.env_of_quiet hq)
    have htouched : MeshRate.Touched s₁ := htouch (Or.inr (List.cons_ne_nil e es))
    simp only [List.length_nil, Nat.zero_add] at hlts
    obtain ⟨hout, hhalt⟩ := hans s₁ ts (Nat.le_trans hlts hl) henv htouched
    have := MeshRate.finish hp henv.halted hout hhalt
    exact ⟨this.1, Or.inr this.2⟩

/-- Every state an execution of an answered plain system reaches is quiet or responded. -/
theorem reachable_quiet_or_responded {sys : System M W B S} (hp : Plain sys)
    (hans : Answered sys) {s : State M W} (h : Reachable sys s) :
    MeshRate.Quiet s ∨ Responded sys s := by
  induction h with
  | init => exact Or.inl (MeshRate.quiet_init _)
  | round _ hnr hround ih =>
    rcases ih with hq | hresp
    · exact (round_from_quiet hp hans hq hround).2
    · exact absurd hresp hnr

/-- An answered plain system has no gap. -/
theorem noGap_of_answered {sys : System M W B S} (hp : Plain sys) (hans : Answered sys) :
    NoGap sys := by
  intro s r hreach hnr hround
  rcases reachable_quiet_or_responded hp hans hreach with hq | hresp
  · exact (round_from_quiet hp hans hq hround).1
  · exact absurd hresp hnr

/-- A monitor that the spread reaches, alive and not bad, is in `out` after the monitor
phase. -/
theorem out_of_spread {sys : System M W B S} (hp : Plain sys) {s₁ : State M W} {m : M}
    (hf : Spread sys s₁ (FlaggedOrDetects sys s₁) m) (ha : s₁.alive (.inl m))
    (hb : ¬ s₁.bad (.inl m)) : Out (monitorPhase sys s₁) m :=
  ⟨(MeshRate.flaggedAfter_fast hp.reports_fast s₁ m).2 hf, ha, hb⟩

/-! ### Theorem J in one direction -/

/-- Let `a` be alive, not bad and not flagged after the monitor phase. Then so is every
monitor reached from `a` by steps of `LeansOn`. If `b` is such a monitor and it watches
`c`, then `c` is alive and not bad, or `b` would detect; and if `c` reports to `b`, then
`c` is not flagged, or its flag would reach `b`. -/
theorem leans_clean {sys : System M W B S} {s₁ : State M W} {ts : List M}
    (henv : MeshRate.Env s₁ ts) {a b : M} (h : LeansThrough sys a b) :
    (s₁.alive (.inl a) ∧ ¬ s₁.bad (.inl a) ∧
        ¬ Spread sys s₁ (FlaggedOrDetects sys s₁) a) →
      (s₁.alive (.inl b) ∧ ¬ s₁.bad (.inl b) ∧
        ¬ Spread sys s₁ (FlaggedOrDetects sys s₁) b) := by
  induction h with
  | refl => exact id
  | @step b c _ hbc ih =>
    intro ha
    obtain ⟨hba, hbb, hbf⟩ := ih ha
    have hactb : Active s₁ b := ⟨hba, hbb, henv.off b⟩
    have hca : s₁.alive (.inl c) := Classical.byContradiction fun hna =>
      hbf (Spread.base (Or.inr ⟨hactb, Or.inr ⟨c, hna, hbc.1.2⟩⟩))
    have hcb : ¬ s₁.bad (.inl c) := fun hbad =>
      hbf (Spread.base (Or.inr ⟨hactb, Or.inl ⟨.inl c, ⟨hbad, henv.hidden _⟩, hbc.1.1⟩⟩))
    exact ⟨hca, hcb, fun hcf => hbf (Spread.step hcf ⟨hca, hcb, henv.off c⟩ hbc.2 hactb)⟩

/-- The conditions of the one-way form answer the environment. -/
theorem answered_one_way {sys : System M W B S} (hp : Plain sys)
    (hs : SufficientOneWay sys sys.f) : Answered sys := by
  intro s₁ ts hl henv htouched
  -- Every monitor that no step touched is flagged after the monitor phase.
  have hall : ∀ m, m ∉ ts → Spread sys s₁ (FlaggedOrDetects sys s₁) m := by
    intro m hm
    apply Classical.byContradiction
    intro hnf
    -- If not, every monitor is alive, not bad and not flagged.
    have clean : ∀ b, s₁.alive (.inl b) ∧ ¬ s₁.bad (.inl b) ∧
        ¬ Spread sys s₁ (FlaggedOrDetects sys s₁) b := fun b =>
      leans_clean henv (hs.leans m b) ⟨(henv.good m hm).1, (henv.good m hm).2, hnf⟩
    rcases htouched with ⟨p, hp'⟩ | ⟨x, hx⟩
    · exact hp' (clean p).1
    · cases x with
      | inl z => exact (clean z).2.1 hx
      | inr w =>
        -- A work process is bad: its state checker is active and detects.
        obtain ⟨k, hk⟩ := (hs.work w).1
        exact (clean k).2.2 (Spread.base (Or.inr
          ⟨⟨(clean k).1, (clean k).2.1, henv.off k⟩,
            Or.inl ⟨.inr w, ⟨hx, henv.hidden _⟩, hk⟩⟩))
  have hout : ∀ m, m ∉ ts → Out (monitorPhase sys s₁) m := fun m hm =>
    out_of_spread hp (hall m hm) (henv.good m hm).1 (henv.good m hm).2
  refine ⟨?_, fun w => ?_⟩
  · -- More than `f` monitors: one was touched by no step.
    obtain ⟨ms, hnd, hlen⟩ := hs.monitors
    obtain ⟨r, _, hr⟩ := MeshRate.exists_not_mem ms ts hnd (Nat.lt_of_le_of_lt hl hlen)
    exact ⟨r, hout r hr⟩
  · -- More than `f` halt inputs: one was touched by no step.
    obtain ⟨_, hs', hnd, hlen, hin⟩ := hs.work w
    obtain ⟨h, hh, hht⟩ := MeshRate.exists_not_mem hs' ts hnd (Nat.lt_of_le_of_lt hl hlen)
    exact ⟨h, hin h hh, hout h hht⟩

/-- Theorem J with its first condition in one direction only. `results-join.md` does not
state this form. A plain system has no gap at `f` faults per round if from every monitor
every monitor is reached by steps that each go from a monitor to one it watches and hears
from, every work process has a state checker and more than `f` halt inputs, and there are
more than `f` monitors. -/
theorem theorem_J_one_way (sys : System M W B S) (hp : Plain sys)
    (hs : SufficientOneWay sys sys.f) : NoGap sys :=
  noGap_of_answered hp (answered_one_way hp hs)

/-! ### Theorem J -/

/-- A pair that watch each other and report to each other gives a step of `LeansOn`. -/
theorem leansThrough_of_linked {sys : System M W B S} {a b : M} (h : Linked sys a b) :
    LeansThrough sys a b := by
  induction h with
  | refl => exact LeansThrough.refl _
  | step _ hbc ih => exact LeansThrough.step ih ⟨hbc.1, hbc.2.2.2⟩

/-- Theorem J is a special case of the one-way form: the conditions of Theorem J give
those of `SufficientOneWay`, in any system and at any `f`. -/
theorem paired_is_one_way (sys : System M W B S) (f : Nat) (hs : SufficientJ sys f) :
    SufficientOneWay sys f where
  leans := fun a b => leansThrough_of_linked (hs.linked a b)
  work := hs.work
  monitors := hs.monitors

/-- Theorem J, with nothing joining. A plain system has no gap at `f` faults per round if
its monitors are connected by pairs that watch each other and report to each other, every
work process has a state checker and more than `f` halt inputs, and there are more than
`f` monitors. -/
theorem theorem_J (sys : System M W B S) (hp : Plain sys) (hs : SufficientJ sys sys.f) :
    NoGap sys :=
  theorem_J_one_way sys hp (paired_is_one_way sys sys.f hs)

/-- The holding half of the mesh result (`mesh_holds`) is a special case of Theorem J: a
mesh of more than `f` monitors, at `f` faults per round, is plain and meets the
conditions of Theorem J. `ms` is a list of different monitors, more than `f` of them. -/
theorem mesh_is_connected (f : Nat) (ms : List M) (hnd : ms.Nodup) (hlen : f < ms.length) :
    Plain (meshAt M W f) ∧ SufficientJ (meshAt M W f) f := by
  refine ⟨MeshRate.meshAt_plain f, ?_, ?_, ⟨ms, hnd, hlen⟩⟩
  · -- Any two different monitors of the mesh are a pair.
    intro a b
    rcases Classical.em (a = b) with rfl | hne
    · exact Linked.refl a
    · have hab : a ≠ b := hne
      have hba : b ≠ a := fun e => hne e.symm
      exact Linked.step (Linked.refl a) ⟨⟨hab, hab⟩, ⟨hba, hba⟩, hba, hab⟩
  · -- Every monitor checks every work process, and every monitor is a halt input.
    intro w
    refine ⟨?_, ms, hnd, hlen, fun _ _ => trivial⟩
    cases ms with
    | nil => exact absurd hlen (Nat.not_lt_zero f)
    | cons k _ => exact ⟨k, trivial⟩

/-! ### Theorem F -/

/-- A monitor reached outside `Z` is outside `Z`. -/
theorem reachOutside_end {sys : System M W B S} {Z : M → Prop} {x y : M}
    (h : ReachOutside sys Z x y) : ¬ Z y := by
  cases h with
  | refl hx => exact hx
  | step _ _ hy => exact hy

/-- If every monitor outside `Z` is active, a flag spreads along report edges that avoid
`Z`. -/
theorem spread_reachOutside {sys : System M W B S} {s₁ : State M W} {Z : M → Prop}
    (hact : ∀ m, ¬ Z m → Active s₁ m) {d h : M} (hr : ReachOutside sys Z d h) :
    Spread sys s₁ (FlaggedOrDetects sys s₁) d →
      Spread sys s₁ (FlaggedOrDetects sys s₁) h := by
  induction hr with
  | refl _ => exact id
  | step hxy hfwd hnz ih =>
    intro hd
    exact Spread.step (ih hd) (hact _ (reachOutside_end hxy)) hfwd (hact _ hnz)

/-- The conditions of Theorem F answer the environment. -/
theorem answered_F {sys : System M W B S} (hp : Plain sys) (hs : SufficientF sys sys.f) :
    Answered sys := by
  intro s₁ ts hl henv htouched
  -- It is enough to find a detecting monitor `d` and a list `zs` of at most `f` monitors,
  -- without `d`, outside which every monitor is alive and not bad.
  have key : ∀ (zs : List M) (d : M), zs.length ≤ sys.f → d ∉ zs →
      (∀ m, m ∉ zs → s₁.alive (.inl m) ∧ ¬ s₁.bad (.inl m)) → Detects sys s₁ d →
      (∃ m, Out (monitorPhase sys s₁) m) ∧
        ∀ w, ∃ h, sys.haltInputs w h ∧ Out (monitorPhase sys s₁) h := by
    intro zs d hzl hdz hgood hdet
    have hact : ∀ m, ¬ (fun m => m ∈ zs) m → Active s₁ m := fun m hm =>
      ⟨(hgood m hm).1, (hgood m hm).2, henv.off m⟩
    have hfd : Spread sys s₁ (FlaggedOrDetects sys s₁) d := Spread.base (Or.inr hdet)
    refine ⟨⟨d, out_of_spread hp hfd (hgood d hdz).1 (hgood d hdz).2⟩, fun w => ?_⟩
    obtain ⟨h, hin, hreach⟩ := hs.halt d w zs hzl hdz
    have hhz : h ∉ zs := reachOutside_end hreach
    exact ⟨h, hin, out_of_spread hp (spread_reachOutside hact hreach hfd)
      (hgood h hhz).1 (hgood h hhz).2⟩
  -- A monitor outside `ts` is active.
  have hactive : ∀ m, m ∉ ts → Active s₁ m := fun m hm =>
    ⟨(henv.good m hm).1, (henv.good m hm).2, henv.off m⟩
  -- Counting: of `f` different monitors other than a member `z` of `ts`, one is not in
  -- `ts`.
  have count : ∀ (z : M) (cs : List M), z ∈ ts → cs.Nodup → sys.f ≤ cs.length →
      (∀ c, c ∈ cs → c ≠ z) → ∃ d, d ∈ cs ∧ d ∉ ts := by
    intro z cs hz hnd hlen hne
    have hnd' : (z :: cs).Nodup := List.nodup_cons.2 ⟨fun hzc => hne z hzc rfl, hnd⟩
    have hlen' : ts.length < (z :: cs).length := by
      simp only [List.length_cons]
      omega
    obtain ⟨d, hd, hdt⟩ := MeshRate.exists_not_mem (z :: cs) ts hnd' hlen'
    rcases List.mem_cons.1 hd with rfl | hd'
    · exact absurd hz hdt
    · exact ⟨d, hd', hdt⟩
  rcases Classical.em (∃ z : M, ¬ s₁.alive (.inl z) ∨ s₁.bad (.inl z)) with ⟨z, hz⟩ | hnone
  · -- A monitor `z` is not alive or is bad. It is in `ts`.
    have hzt : z ∈ ts := Classical.byContradiction fun hnot => by
      rcases hz with hz | hz
      · exact hz (henv.good z hnot).1
      · exact (henv.good z hnot).2 hz
    rcases hz with hna | hbad
    · -- Not alive: one of its `f` signal readers is outside `ts`, and detects.
      obtain ⟨rs, hnd, hlen, hr⟩ := hs.read z
      obtain ⟨d, hd, hdt⟩ := count z rs hzt hnd hlen (fun c hc => (hr c hc).1)
      exact key ts d hl hdt henv.good ⟨hactive d hdt, Or.inr ⟨z, hna, (hr d hd).2⟩⟩
    · -- Bad: one of its `f` state checkers is outside `ts`, and detects.
      obtain ⟨cs, hnd, hlen, hc⟩ := hs.checked z
      obtain ⟨d, hd, hdt⟩ := count z cs hzt hnd hlen (fun c hc' => (hc c hc').1)
      exact key ts d hl hdt henv.good
        ⟨hactive d hdt, Or.inl ⟨.inl z, ⟨hbad, henv.hidden _⟩, (hc d hd).2⟩⟩
  · -- Every monitor is alive and not bad, so the mark is a bad work process. Its state
    -- checker detects, and no monitor has to be avoided.
    have hgood : ∀ m, m ∉ ([] : List M) → s₁.alive (.inl m) ∧ ¬ s₁.bad (.inl m) :=
      fun m _ =>
        ⟨Classical.byContradiction fun hna => hnone ⟨m, Or.inl hna⟩,
          fun hbad => hnone ⟨m, Or.inr hbad⟩⟩
    rcases htouched with ⟨p, hp'⟩ | ⟨x, hx⟩
    · exact absurd (hgood p List.not_mem_nil).1 hp'
    · cases x with
      | inl z => exact absurd hx (hgood z List.not_mem_nil).2
      | inr w =>
        obtain ⟨k, hk⟩ := hs.work w
        exact key [] k (Nat.zero_le _) List.not_mem_nil hgood
          ⟨⟨(hgood k List.not_mem_nil).1, (hgood k List.not_mem_nil).2, henv.off k⟩,
            Or.inl ⟨.inr w, ⟨hx, henv.hidden _⟩, hk⟩⟩

/-- Theorem F. A plain system has no gap at `f` faults per round if every monitor has at
least `f` state checkers and at least `f` signal readers other than itself, every work
process has a state checker, and for every monitor `d`, every work process `w` and every
set of at most `f` monitors that does not contain `d`, some halt input of `w` outside the
set is reached from `d` along report edges that avoid the set. -/
theorem theorem_F (sys : System M W B S) (hp : Plain sys) (hs : SufficientF sys sys.f) :
    NoGap sys :=
  noGap_of_answered hp (answered_F hp hs)

end Connected
end SelfObserving
