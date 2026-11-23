/-
Proofs of three statements of `Challenge.lean` under "Monitors that join":
`plainJoin_reachable`, `plainJoin_same` and `unchecked_present_monitor_gap`.

The file has these parts:

- equal states and equal outcomes, component by component;
- two systems of `Model.lean` that agree on what a round looks at give the same round
  (`afterEnv_agree`): the same signal, report and phase-order fields, the same checkers of
  every bad process, the same halt inputs of every present process;
- in every reachable state of `Model.lean`, every bad process is present (`BadPresent`);
- a system with none of the new fields: its present processes, its steps, its environment
  phases and its rounds in the model with joins are those of `Model.lean`;
- the first two statements;
- rounds of the model with joins in which nothing happens (`Quiet`): the states the joins
  reach are reached by executions, one join a round;
- the third statement.
-/
import SelfObserving.Join
import SelfObserving.JoinConditions
import SelfObserving.Proofs.Necessity

namespace SelfObserving
namespace JoinPlain

variable {M W B S : Type}

/-! ### Equal states and equal outcomes -/

/-- Two states with the same components are equal. -/
theorem state_ext {a b : State M W}
    (halive : ∀ p, a.alive p ↔ b.alive p) (hbad : ∀ p, a.bad p ↔ b.bad p)
    (hhidden : ∀ p, a.hidden p ↔ b.hidden p) (hoff : ∀ m, a.off m ↔ b.off m)
    (hflagged : ∀ m, a.flagged m ↔ b.flagged m) (hhalted : ∀ w, a.halted w ↔ b.halted w)
    (hpending : ∀ w, a.pending w ↔ b.pending w) (hjoined : a.joined ↔ b.joined) :
    a = b := by
  cases a with
  | mk a1 a2 a3 a4 a5 a6 a7 a8 =>
    cases b with
    | mk b1 b2 b3 b4 b5 b6 b7 b8 =>
      have h1 : a1 = b1 := funext fun p => propext (halive p)
      have h2 : a2 = b2 := funext fun p => propext (hbad p)
      have h3 : a3 = b3 := funext fun p => propext (hhidden p)
      have h4 : a4 = b4 := funext fun p => propext (hoff p)
      have h5 : a5 = b5 := funext fun p => propext (hflagged p)
      have h6 : a6 = b6 := funext fun p => propext (hhalted p)
      have h7 : a7 = b7 := funext fun p => propext (hpending p)
      have h8 : a8 = b8 := propext hjoined
      rw [h1, h2, h3, h4, h5, h6, h7, h8]

/-- Two outcomes with the same next state and the same judgements are equal. -/
theorem outcome_ext {x y : Outcome M W} (hnext : x.next = y.next) (h1 : x.g1 ↔ y.g1)
    (h2 : x.g2 ↔ y.g2) : x = y := by
  cases x with
  | mk xn x1 x2 =>
    cases y with
    | mk yn y1 y2 =>
      have e0 : xn = yn := hnext
      have e1 : x1 = y1 := propext h1
      have e2 : x2 = y2 := propext h2
      rw [e0, e1, e2]

/-- With no group, the set of groups that have joined is the same in every state: two
states of the model with joins are equal as soon as their components of `Model.lean`
are. -/
theorem jstate_ext {s s' : JState M W Empty} (h : s.st = s'.st) : s = s' := by
  cases s with
  | mk t a =>
    cases s' with
    | mk t' a' =>
      have e0 : t = t' := h
      have e1 : a = a' := funext fun e => nomatch e
      rw [e0, e1]

/-! ### The two orders of the phases -/

/-- A round with the gate: the monitor phase, then the work phase. -/
theorem afterEnv_gate (sys : System M W B S) (t : State M W) (hg : sys.gate = true) :
    afterEnv sys t =
      { next := workPhase sys (monitorPhase sys t) (Out (monitorPhase sys t))
        g1 := (∃ p, (monitorPhase sys t).bad p) ∧ ¬ ∃ m, Out (monitorPhase sys t) m
        g2 := (∃ p, (monitorPhase sys t).bad p) ∧
          ∃ w, Worked sys (monitorPhase sys t) (Out (monitorPhase sys t)) w } := by
  unfold afterEnv
  rw [ite_eq_left hg]

/-- A round without the gate: the work phase, then the monitor phase. -/
theorem afterEnv_noGate (sys : System M W B S) (t : State M W) (hg : sys.gate = false) :
    afterEnv sys t =
      { next := monitorPhase sys (workPhase sys t (Out t))
        g1 := (∃ p, (monitorPhase sys (workPhase sys t (Out t))).bad p) ∧
          ¬ ∃ m, Out (monitorPhase sys (workPhase sys t (Out t))) m
        g2 := (∃ p, t.bad p) ∧ ∃ w, Worked sys t (Out t) w } := by
  unfold afterEnv
  rw [ite_eq_right (fun h => Bool.noConfusion (hg.symm.trans h))]

/-! ### Systems that agree on what a round looks at -/

/-- `Agree a b t`: the systems `a` and `b` differ only in edges that a round from the
state `t` does not look at. They have the same joiner, phase order, report speed, coupling
and window, the same signal readers and report edges, the same checkers of every process
that is bad in `t`, and the same halt inputs of every process that is present in `t`. -/
structure Agree (a b : System M W B S) (t : State M W) : Prop where
  joiner : a.joiner = b.joiner
  gate : a.gate = b.gate
  slowReports : a.slowReports = b.slowReports
  coupling : a.coupling = b.coupling
  window : a.window = b.window
  hb : ∀ p m, a.hbReaders p m ↔ b.hbReaders p m
  fwd : ∀ m r, a.fwd m r ↔ b.fwd m r
  check : ∀ x m, t.bad x → (a.checkers x m ↔ b.checkers x m)
  halt : ∀ w m, Present b t (.inr w) → (a.haltInputs w m ↔ b.haltInputs w m)

/-- The same monitors detect, in any state with no more bad processes than `t`. -/
theorem detects_agree {a b : System M W B S} {t : State M W} (h : Agree a b t)
    {u : State M W} (hbad : ∀ p, u.bad p → t.bad p) (m : M) :
    Detects a u m ↔ Detects b u m := by
  constructor
  · rintro ⟨hact, ⟨x, hx, hc⟩ | ⟨p, hp, hr⟩⟩
    · exact ⟨hact, Or.inl ⟨x, hx, (h.check x m (hbad x hx.1)).1 hc⟩⟩
    · exact ⟨hact, Or.inr ⟨p, hp, (h.hb p m).1 hr⟩⟩
  · rintro ⟨hact, ⟨x, hx, hc⟩ | ⟨p, hp, hr⟩⟩
    · exact ⟨hact, Or.inl ⟨x, hx, (h.check x m (hbad x hx.1)).2 hc⟩⟩
    · exact ⟨hact, Or.inr ⟨p, hp, (h.hb p m).2 hr⟩⟩

/-- Flags spread no further along fewer report edges from fewer monitors. -/
theorem spread_mono {a b : System M W B S} {u : State M W} {F F' : M → Prop}
    (hfwd : ∀ m r, a.fwd m r → b.fwd m r) (hF : ∀ m, F m → F' m) :
    ∀ m, Spread a u F m → Spread b u F' m := by
  intro m h
  induction h with
  | base hm => exact Spread.base (hF _ hm)
  | step _ ha hf hr ih => exact Spread.step ih ha (hfwd _ _ hf) hr

/-- The same monitors are flagged after the monitor phase. -/
theorem flaggedAfter_agree {a b : System M W B S} {t : State M W} (h : Agree a b t)
    {u : State M W} (hbad : ∀ p, u.bad p → t.bad p) (m : M) :
    flaggedAfter a u m ↔ flaggedAfter b u m := by
  have hfd : ∀ m, FlaggedOrDetects a u m ↔ FlaggedOrDetects b u m := fun m =>
    or_congr Iff.rfl (detects_agree h hbad m)
  cases hs : b.slowReports with
  | true =>
    have hs' : a.slowReports = true := h.slowReports.trans hs
    unfold flaggedAfter
    rw [ite_eq_left hs, ite_eq_left hs']
    constructor
    · rintro (hd | ⟨m', hf, ha, hfw, hr⟩)
      · exact Or.inl ((hfd m).1 hd)
      · exact Or.inr ⟨m', hf, ha, (h.fwd m' m).1 hfw, hr⟩
    · rintro (hd | ⟨m', hf, ha, hfw, hr⟩)
      · exact Or.inl ((hfd m).2 hd)
      · exact Or.inr ⟨m', hf, ha, (h.fwd m' m).2 hfw, hr⟩
  | false =>
    have hs' : a.slowReports = false := h.slowReports.trans hs
    unfold flaggedAfter
    rw [ite_eq_right (fun e => Bool.noConfusion (hs.symm.trans e)),
      ite_eq_right (fun e => Bool.noConfusion (hs'.symm.trans e))]
    exact ⟨spread_mono (fun m r => (h.fwd m r).1) (fun m => (hfd m).1) m,
      spread_mono (fun m r => (h.fwd m r).2) (fun m => (hfd m).2) m⟩

/-- The monitor phase is the same. -/
theorem monitorPhase_agree {a b : System M W B S} {t : State M W} (h : Agree a b t)
    {u : State M W} (hbad : ∀ p, u.bad p → t.bad p) :
    monitorPhase a u = monitorPhase b u := by
  have he : flaggedAfter a u = flaggedAfter b u :=
    funext fun m => propext (flaggedAfter_agree h hbad m)
  unfold monitorPhase
  rw [he]

/-- The same processes are handled by the work phase. -/
theorem handled_agree {a b : System M W B S} {t : State M W} (h : Agree a b t)
    (u : State M W) (w : W) : Handled a u w ↔ Handled b u w := by
  show ((a.joiner = some w → u.joined) ∧ ¬ u.halted w) ↔
    ((b.joiner = some w → u.joined) ∧ ¬ u.halted w)
  rw [h.joiner]

/-- A process handled in a state with the same `joined` as `t` is present in `t`. -/
theorem handled_present {b : System M W B S} {t u : State M W} (hj : u.joined → t.joined)
    {w : W} (hw : Handled b u w) : Present b t (.inr w) :=
  fun hjo => hj (hw.1 hjo)

/-- A process that is present in `t` sees the same reasons to halt. -/
theorem sees_agree {a b : System M W B S} {t : State M W} (h : Agree a b t)
    (u : State M W) (o : M → Prop) {w : W} (hw : Present b t (.inr w)) :
    Sees a u o w ↔ Sees b u o w := by
  constructor
  · rintro (⟨m, hin, hm⟩ | ⟨hc, m, hin, hm⟩)
    · exact Or.inl ⟨m, (h.halt w m hw).1 hin, hm⟩
    · exact Or.inr ⟨h.coupling.symm.trans hc, m, (h.halt w m hw).1 hin, hm⟩
  · rintro (⟨m, hin, hm⟩ | ⟨hc, m, hin, hm⟩)
    · exact Or.inl ⟨m, (h.halt w m hw).2 hin, hm⟩
    · exact Or.inr ⟨h.coupling.trans hc, m, (h.halt w m hw).2 hin, hm⟩

/-- The work phase is the same, from any state with the same `joined` as `t`. -/
theorem workPhase_agree {a b : System M W B S} {t : State M W} (h : Agree a b t)
    {u : State M W} (hj : u.joined → t.joined) (o : M → Prop) :
    workPhase a u o = workPhase b u o := by
  have hS : ∀ w, Handled b u w → (Sees a u o w ↔ Sees b u o w) := fun w hw =>
    sees_agree h u o (handled_present hj hw)
  refine state_ext (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl)
    (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun w => ?_) (fun w => ?_) Iff.rfl
  · show (u.halted w ∨ (Handled a u w ∧ (u.pending w ∨ (Sees a u o w ∧ a.window = 0)))) ↔
      (u.halted w ∨ (Handled b u w ∧ (u.pending w ∨ (Sees b u o w ∧ b.window = 0))))
    rw [h.window, handled_agree h u w]
    exact or_congr Iff.rfl
      (and_congr_right fun hb => or_congr Iff.rfl (and_congr (hS w hb) Iff.rfl))
  · show ((u.pending w ∧ ¬ Handled a u w) ∨
        (Handled a u w ∧ ¬ u.pending w ∧ Sees a u o w ∧ a.window ≠ 0)) ↔
      ((u.pending w ∧ ¬ Handled b u w) ∨
        (Handled b u w ∧ ¬ u.pending w ∧ Sees b u o w ∧ b.window ≠ 0))
    rw [h.window, handled_agree h u w]
    exact or_congr Iff.rfl
      (and_congr_right fun hb => and_congr Iff.rfl (and_congr (hS w hb) Iff.rfl))

/-- The same processes take a work step. -/
theorem worked_agree {a b : System M W B S} {t : State M W} (h : Agree a b t)
    {u : State M W} (hj : u.joined → t.joined) (o : M → Prop) (w : W) :
    Worked a u o w ↔ Worked b u o w := by
  show (Handled a u w ∧ ¬ u.pending w ∧ ¬ (Sees a u o w ∧ a.window = 0)) ↔
    (Handled b u w ∧ ¬ u.pending w ∧ ¬ (Sees b u o w ∧ b.window = 0))
  rw [h.window, handled_agree h u w]
  exact and_congr_right fun hb => and_congr Iff.rfl
    (not_congr (and_congr (sees_agree h u o (handled_present hj hb)) Iff.rfl))

/-- Two systems that agree on what a round from `t` looks at give the same round from
`t`: the same next state and the same judgement of each goal, in either order of the
phases. -/
theorem afterEnv_agree {a b : System M W B S} {t : State M W} (h : Agree a b t) :
    afterEnv a t = afterEnv b t := by
  cases hg : b.gate with
  | true =>
    rw [afterEnv_gate a t (h.gate.trans hg), afterEnv_gate b t hg]
    have hm : monitorPhase a t = monitorPhase b t := monitorPhase_agree h (fun _ hp => hp)
    rw [hm]
    refine outcome_ext ?_ Iff.rfl ?_
    · exact workPhase_agree h (u := monitorPhase b t) (fun hj => hj) _
    · exact and_congr Iff.rfl
        ⟨fun ⟨w, hw⟩ => ⟨w, (worked_agree h (u := monitorPhase b t) (fun hj => hj) _ w).1 hw⟩,
          fun ⟨w, hw⟩ => ⟨w, (worked_agree h (u := monitorPhase b t) (fun hj => hj) _ w).2 hw⟩⟩
  | false =>
    rw [afterEnv_noGate a t (h.gate.trans hg), afterEnv_noGate b t hg]
    have hw : workPhase a t (Out t) = workPhase b t (Out t) :=
      workPhase_agree h (fun hj => hj) _
    rw [hw]
    have hm : monitorPhase a (workPhase b t (Out t)) = monitorPhase b (workPhase b t (Out t)) :=
      monitorPhase_agree h (u := workPhase b t (Out t)) (fun _ hp => hp)
    rw [hm]
    refine outcome_ext rfl Iff.rfl ?_
    exact and_congr Iff.rfl
      ⟨fun ⟨w, hw⟩ => ⟨w, (worked_agree h (fun hj => hj) _ w).1 hw⟩,
        fun ⟨w, hw⟩ => ⟨w, (worked_agree h (fun hj => hj) _ w).2 hw⟩⟩

/-! ### Every bad process is present -/

/-- Every bad process is present. A process that is not present is the joiner before it
joins, and nothing mutates it or strikes it. -/
def BadPresent (sys : System M W B S) (t : State M W) : Prop :=
  ∀ p, t.bad p → Present sys t p

/-- A present process stays present as long as `joined` does not go back. -/
theorem present_of_joined {sys : System M W B S} {t u : State M W}
    (hj : t.joined → u.joined) (p : Proc M W) (hp : Present sys t p) : Present sys u p := by
  cases p with
  | inl m => exact trivial
  | inr w => exact fun hw => hj (hp hw)

/-- An enabled environment step keeps every bad process present. -/
theorem effect_badPresent {sys : System M W B S} {t : State M W} {e : EnvStep M W B S}
    (he : Enabled sys t e) (h : BadPresent sys t) : BadPresent sys (effect sys t e) := by
  cases e with
  | stop m => exact fun p hp => present_of_joined (fun hj => hj) p (h p hp)
  | stopBoundary b => exact fun p hp => present_of_joined (fun hj => hj) p (h p hp)
  | failSubstrate c =>
    rintro p (hp | ⟨w, _, hpres, _⟩)
    · exact present_of_joined (fun hj => hj) p (h p hp)
    · exact present_of_joined (fun hj => hj) p hpres
  | mutate q =>
    rintro p (hp | hp)
    · rw [hp]
      exact present_of_joined (fun hj => hj) q he.1
    · exact present_of_joined (fun hj => hj) p (h p hp)
  | disable m => exact fun p hp => present_of_joined (fun hj => hj) p (h p hp)
  | join => exact fun p hp => present_of_joined (fun _ => trivial) p (h p hp)

/-- The environment phase keeps every bad process present. -/
theorem envRun_badPresent {sys : System M W B S} {t t₁ : State M W}
    {steps : List (EnvStep M W B S)} (hrun : EnvRun sys t steps t₁) :
    BadPresent sys t → BadPresent sys t₁ := by
  induction hrun with
  | nil => exact fun h => h
  | cons he _ ih => exact fun h => ih (effect_badPresent he h)

/-- The monitor and work phases keep every bad process present. -/
theorem afterEnv_badPresent {sys : System M W B S} {t : State M W} (h : BadPresent sys t) :
    BadPresent sys (afterEnv sys t).next := by
  intro p hp
  rw [Necessity.afterEnv_bad] at hp
  refine present_of_joined (fun hj => ?_) p (h p hp)
  rw [Necessity.afterEnv_joined]
  exact hj

/-- In every reachable state, every bad process is present. -/
theorem reachable_badPresent {sys : System M W B S} {t : State M W}
    (h : Reachable sys t) : BadPresent sys t := by
  induction h with
  | init => exact fun _ hp => hp.elim
  | round _ _ hround ih =>
    obtain ⟨steps, t₁, _, hrun, rfl⟩ := hround
    exact afterEnv_badPresent (envRun_badPresent hrun ih)

/-! ### A system with none of the new fields -/

/-- With no group, every monitor is present. -/
theorem jpresent_monitor (sys : System M W B S) (s : JState M W Empty) (m : M) :
    JPresent (plainJoin sys) s (.inl m) :=
  fun g _ => nomatch g

/-- With no group, the present processes are those of `Model.lean`. -/
theorem jpresent_plain (sys : System M W B S) (s : JState M W Empty) (p : Proc M W) :
    JPresent (plainJoin sys) s p ↔ Present sys s.st p := by
  cases p with
  | inl m => exact ⟨fun _ => trivial, fun _ => jpresent_monitor sys s m⟩
  | inr w => exact Iff.rfl

/-- With no group, a step of the model with joins is a step of `Model.lean`. -/
def toEnv : JStep M W B S Empty → EnvStep M W B S
  | .stop m => .stop m
  | .stopBoundary b => .stopBoundary b
  | .failSubstrate c => .failSubstrate c
  | .mutate p => .mutate p
  | .disable m => .disable m
  | .join => .join
  | .joinGroup g => nomatch g
  | .joinBad g _ => nomatch g

/-- A step of `Model.lean` as a step of the model with joins. -/
def ofEnv : EnvStep M W B S → JStep M W B S Empty
  | .stop m => .stop m
  | .stopBoundary b => .stopBoundary b
  | .failSubstrate c => .failSubstrate c
  | .mutate p => .mutate p
  | .disable m => .disable m
  | .join => .join

theorem toEnv_ofEnv (e : EnvStep M W B S) : toEnv (ofEnv e) = e := by
  cases e <;> rfl

/-- A step is enabled in the model with joins exactly when it is in `Model.lean`. -/
theorem jenabled_plain (sys : System M W B S) (s : JState M W Empty)
    (e : JStep M W B S Empty) :
    JEnabled (plainJoin sys) s e ↔ Enabled sys s.st (toEnv e) := by
  cases e with
  | stop m => exact ⟨fun h => h.2, fun h => ⟨jpresent_monitor sys s m, h⟩⟩
  | stopBoundary b =>
    constructor
    · rintro ⟨⟨m, m', hne, hb, hb', _, _⟩, m₀, hb₀, _, ha⟩
      exact ⟨⟨m, m', hne, hb, hb'⟩, m₀, hb₀, ha⟩
    · rintro ⟨⟨m, m', hne, hb, hb'⟩, m₀, hb₀, ha⟩
      exact ⟨⟨m, m', hne, hb, hb', jpresent_monitor sys s m, jpresent_monitor sys s m'⟩,
        m₀, hb₀, jpresent_monitor sys s m₀, ha⟩
  | failSubstrate c =>
    constructor
    · rintro ⟨p, hp, hsub, hm⟩
      exact ⟨p, (jpresent_plain sys s p).1 hp, hsub, hm⟩
    · rintro ⟨p, hp, hsub, hm⟩
      exact ⟨p, (jpresent_plain sys s p).2 hp, hsub, hm⟩
  | mutate p => exact and_congr (jpresent_plain sys s p) Iff.rfl
  | disable m => exact ⟨fun h => h.2, fun h => ⟨jpresent_monitor sys s m, h⟩⟩
  | join => exact ⟨fun h => ⟨h.1, h.2.2⟩, fun h => ⟨h.1, rfl, h.2⟩⟩
  | joinGroup g => exact nomatch g
  | joinBad g m => exact nomatch g

/-- The processes struck by a failed substrate are those of `Model.lean`. -/
theorem jstruck_plain (sys : System M W B S) (s : JState M W Empty) (c : S) (p : Proc M W) :
    JStruck (plainJoin sys) s c p ↔ Struck sys s.st c p :=
  ⟨fun ⟨w, hw, hp, hs⟩ => ⟨w, hw, (jpresent_plain sys s p).1 hp, hs⟩,
    fun ⟨w, hw, hp, hs⟩ => ⟨w, hw, (jpresent_plain sys s p).2 hp, hs⟩⟩

/-- A step has the effect in the model with joins that it has in `Model.lean`. -/
theorem jeffect_plain (sys : System M W B S) (s : JState M W Empty)
    (e : JStep M W B S Empty) :
    (jeffect (plainJoin sys) s e).st = effect sys s.st (toEnv e) := by
  cases e with
  | stop m => rfl
  | stopBoundary b =>
    refine state_ext (fun p => ?_) (fun _ => Iff.rfl) (fun _ => Iff.rfl)
      (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) Iff.rfl
    exact ⟨fun h => ⟨h.1, fun m hm hb => h.2 m hm ⟨hb, jpresent_monitor sys s m⟩⟩,
      fun h => ⟨h.1, fun m hm hb => h.2 m hm hb.1⟩⟩
  | failSubstrate c =>
    refine state_ext (fun p => ?_) (fun p => ?_) (fun p => ?_)
      (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) Iff.rfl
    · refine ⟨fun h => ⟨h.1, fun m hm hb => h.2 m hm ⟨hb, ?_⟩⟩,
        fun h => ⟨h.1, fun m hm hb => h.2 m hm hb.1⟩⟩
      rw [hm]
      exact jpresent_monitor sys s m
    · exact or_congr Iff.rfl (jstruck_plain sys s c p)
    · exact or_congr Iff.rfl (jstruck_plain sys s c p)
  | mutate p => rfl
  | disable m => rfl
  | join => rfl
  | joinGroup g => exact nomatch g
  | joinBad g m => exact nomatch g

/-- An environment phase of the model with joins is one of `Model.lean`. -/
theorem jenvRun_to {sys : System M W B S} {s s₁ : JState M W Empty}
    {steps : List (JStep M W B S Empty)} (h : JEnvRun (plainJoin sys) s steps s₁) :
    EnvRun sys s.st (steps.map toEnv) s₁.st := by
  induction h with
  | nil s => exact EnvRun.nil _
  | cons he _ ih =>
    refine EnvRun.cons ((jenabled_plain sys _ _).1 he) ?_
    rw [← jeffect_plain]
    exact ih

/-- An environment phase of `Model.lean` is one of the model with joins. -/
theorem envRun_to {sys : System M W B S} {t t₁ : State M W}
    {steps : List (EnvStep M W B S)} (h : EnvRun sys t steps t₁) :
    ∀ s : JState M W Empty, s.st = t →
      ∃ s₁ : JState M W Empty, s₁.st = t₁ ∧
        JEnvRun (plainJoin sys) s (steps.map ofEnv) s₁ := by
  induction h with
  | nil t => exact fun s hs => ⟨s, hs, JEnvRun.nil s⟩
  | @cons t t' e es he _ ih =>
    intro s hs
    have he' : JEnabled (plainJoin sys) s (ofEnv e) := by
      refine (jenabled_plain sys s _).2 ?_
      rw [toEnv_ofEnv, hs]
      exact he
    have hst : (jeffect (plainJoin sys) s (ofEnv e)).st = effect sys t e := by
      rw [jeffect_plain, toEnv_ofEnv, hs]
    obtain ⟨s₁, h1, hrun⟩ := ih _ hst
    exact ⟨s₁, h1, JEnvRun.cons he' hrun⟩

/-- The system whose edges are the edges in force agrees with `sys` on what a round looks
at, when every bad process is present after the environment phase: the only edges that
are not in force are those at the joiner before it joins. -/
theorem agree_plain (sys : System M W B S) (s s₁ : JState M W Empty)
    (h : BadPresent sys s₁.st) : Agree (effective (plainJoin sys) s s₁) sys s₁.st where
  joiner := rfl
  gate := rfl
  slowReports := rfl
  coupling := rfl
  window := rfl
  hb := fun p m => ⟨fun hh => hh.1, fun hh =>
    ⟨hh, jpresent_monitor sys s₁ p, jpresent_monitor sys s₁ m, fun f => f.elim⟩⟩
  fwd := fun m r => ⟨fun hh => hh.1, fun hh =>
    ⟨hh, jpresent_monitor sys s₁ m, jpresent_monitor sys s₁ r, fun f => f.elim⟩⟩
  check := fun x m hx => ⟨fun hh => hh.1, fun hh =>
    ⟨hh, (jpresent_plain sys s₁ x).2 (h x hx), jpresent_monitor sys s₁ m, fun f => f.elim⟩⟩
  halt := fun _ m hw => ⟨fun hh => hh.1, fun hh =>
    ⟨hh, hw, jpresent_monitor sys s₁ m, fun f => f.elim⟩⟩

/-- The monitor and work phases of the model with joins are those of `Model.lean`, from a
state in which every bad process is present. -/
theorem afterEnv_plain (sys : System M W B S) (s s₁ : JState M W Empty)
    (h : BadPresent sys s₁.st) :
    afterEnv (effective (plainJoin sys) s s₁) s₁.st = afterEnv sys s₁.st :=
  afterEnv_agree (agree_plain sys s s₁ h)

/-- A round of the model with joins is a round of `Model.lean`, with the same next state
and the same judgements. -/
theorem jround_to (sys : System M W B S) {s : JState M W Empty} {r : JOutcome M W Empty}
    (hb : BadPresent sys s.st) (hr : JRound (plainJoin sys) s r) :
    ∃ r' : Outcome M W, Round sys s.st r' ∧ r.next.st = r'.next ∧ (r.g1 ↔ r'.g1) ∧
      (r.g2 ↔ r'.g2) := by
  obtain ⟨steps, s₁, hlen, hrun, rfl⟩ := hr
  have hrun' := jenvRun_to hrun
  have he := afterEnv_plain sys s s₁ (envRun_badPresent hrun' hb)
  refine ⟨afterEnv sys s₁.st, ⟨steps.map toEnv, s₁.st, ?_, hrun', rfl⟩, ?_, ?_, ?_⟩
  · rw [List.length_map]
    exact hlen
  · show (afterEnv (effective (plainJoin sys) s s₁) s₁.st).next = _
    rw [he]
  · show (afterEnv (effective (plainJoin sys) s s₁) s₁.st).g1 ↔ _
    rw [he]
  · show (afterEnv (effective (plainJoin sys) s s₁) s₁.st).g2 ↔ _
    rw [he]

/-- A round of `Model.lean` is a round of the model with joins, with the same next state
and the same judgements. -/
theorem round_to (sys : System M W B S) {s : JState M W Empty} {r : Outcome M W}
    (hb : BadPresent sys s.st) (hr : Round sys s.st r) :
    ∃ r' : JOutcome M W Empty, JRound (plainJoin sys) s r' ∧ r'.next.st = r.next ∧
      (r'.g1 ↔ r.g1) ∧ (r'.g2 ↔ r.g2) := by
  obtain ⟨steps, t₁, hlen, hrun, rfl⟩ := hr
  obtain ⟨s₁, rfl, hrun'⟩ := envRun_to hrun s rfl
  have he := afterEnv_plain sys s s₁ (envRun_badPresent hrun hb)
  refine ⟨jafterEnv (plainJoin sys) s s₁, ⟨steps.map ofEnv, s₁, ?_, hrun', rfl⟩, ?_, ?_, ?_⟩
  · rw [List.length_map]
    exact hlen
  · show (afterEnv (effective (plainJoin sys) s s₁) s₁.st).next = _
    rw [he]
  · show (afterEnv (effective (plainJoin sys) s s₁) s₁.st).g1 ↔ _
    rw [he]
  · show (afterEnv (effective (plainJoin sys) s s₁) s₁.st).g2 ↔ _
    rw [he]

/-! ### The first two statements -/

/-- The initial state of the model with joins has the components of the initial state of
`Model.lean`. -/
theorem jinit_plain (sys : System M W B S) : (jinit (plainJoin sys)).st = init sys := by
  refine state_ext (fun p => ?_) (fun _ => Iff.rfl) (fun _ => Iff.rfl)
    (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) Iff.rfl
  cases p with
  | inl m => exact ⟨fun _ => trivial, fun _ => rfl⟩
  | inr w => exact Iff.rfl

/-- A state reached in the model with joins has components reached in `Model.lean`. -/
theorem jreachable_to (sys : System M W B S) {s : JState M W Empty}
    (h : JReachable (plainJoin sys) s) : Reachable sys s.st := by
  induction h with
  | init =>
    rw [jinit_plain]
    exact Reachable.init
  | @round s r _ hresp hround ih =>
    obtain ⟨r', hr', hnext, _, _⟩ := jround_to sys (reachable_badPresent ih) hround
    rw [hnext]
    exact Reachable.round ih hresp hr'

/-- A state whose components are reached in `Model.lean` is reached in the model with
joins. -/
theorem reachable_to (sys : System M W B S) {t : State M W} (h : Reachable sys t) :
    ∀ s : JState M W Empty, s.st = t → JReachable (plainJoin sys) s := by
  induction h with
  | init =>
    intro s hs
    have he : s = jinit (plainJoin sys) := jstate_ext (hs.trans (jinit_plain sys).symm)
    rw [he]
    exact JReachable.init
  | @round t r hreach hresp hround ih =>
    intro s hs
    have h₀ : JReachable (plainJoin sys) ⟨t, fun e => nomatch e⟩ := ih _ rfl
    obtain ⟨r', hr', hnext, _, _⟩ :=
      round_to sys (s := ⟨t, fun e => nomatch e⟩) (reachable_badPresent hreach) hround
    have he : s = r'.next := jstate_ext (hs.trans hnext.symm)
    rw [he]
    exact JReachable.round h₀ hresp hr'

/-- A system with none of the three new fields reaches the same states in the model with
joins as in the model of `Model.lean`. -/
theorem plainJoin_reachable (sys : System M W B S) (s : JState M W Empty) :
    JReachable (plainJoin sys) s ↔ Reachable sys s.st :=
  ⟨jreachable_to sys, fun h => reachable_to sys h s rfl⟩

/-- A system with none of the three new fields has the same result in both models. -/
theorem plainJoin_same (sys : System M W B S) :
    (JNoGap (plainJoin sys) ↔ NoGap sys) ∧
    (JViolatesG1 (plainJoin sys) ↔ ViolatesG1 sys) ∧
    (JViolatesG2 (plainJoin sys) ↔ ViolatesG2 sys) := by
  refine ⟨⟨fun h t r hreach hresp hround => ?_, fun h s r hreach hresp hround => ?_⟩,
    ⟨fun ⟨s, r, hreach, hresp, hround, hg⟩ => ?_,
      fun ⟨t, r, hreach, hresp, hround, hg⟩ => ?_⟩,
    ⟨fun ⟨s, r, hreach, hresp, hround, hg⟩ => ?_,
      fun ⟨t, r, hreach, hresp, hround, hg⟩ => ?_⟩⟩
  · obtain ⟨r', hr', _, h1, h2⟩ :=
      round_to sys (s := ⟨t, fun e => nomatch e⟩) (reachable_badPresent hreach) hround
    have hno := h ⟨t, fun e => nomatch e⟩ r' (reachable_to sys hreach _ rfl) hresp hr'
    exact ⟨fun g => hno.1 (h1.2 g), fun g => hno.2 (h2.2 g)⟩
  · have hreach' := jreachable_to sys hreach
    obtain ⟨r', hr', _, h1, h2⟩ := jround_to sys (reachable_badPresent hreach') hround
    have hno := h s.st r' hreach' hresp hr'
    exact ⟨fun g => hno.1 (h1.1 g), fun g => hno.2 (h2.1 g)⟩
  · have hreach' := jreachable_to sys hreach
    obtain ⟨r', hr', _, h1, _⟩ := jround_to sys (reachable_badPresent hreach') hround
    exact ⟨s.st, r', hreach', hresp, hr', h1.1 hg⟩
  · obtain ⟨r', hr', _, h1, _⟩ :=
      round_to sys (s := ⟨t, fun e => nomatch e⟩) (reachable_badPresent hreach) hround
    exact ⟨⟨t, fun e => nomatch e⟩, r', reachable_to sys hreach _ rfl, hresp, hr', h1.2 hg⟩
  · have hreach' := jreachable_to sys hreach
    obtain ⟨r', hr', _, _, h2⟩ := jround_to sys (reachable_badPresent hreach') hround
    exact ⟨s.st, r', hreach', hresp, hr', h2.1 hg⟩
  · obtain ⟨r', hr', _, _, h2⟩ :=
      round_to sys (s := ⟨t, fun e => nomatch e⟩) (reachable_badPresent hreach) hround
    exact ⟨⟨t, fun e => nomatch e⟩, r', reachable_to sys hreach _ rfl, hresp, hr', h2.2 hg⟩

/-! ### Rounds in which nothing happens -/

section Quiet

variable {G : Type}

/-- A state of the model with joins in which every present monitor is alive, nothing is
bad, nothing is flagged and no process is about to halt. -/
structure Quiet (sys : JSystem M W B S G) (s : JState M W G) : Prop where
  alive : ∀ m, JPresent sys s (.inl m) → s.st.alive (.inl m)
  bad : ∀ p, ¬ s.st.bad p
  flagged : ∀ m, ¬ s.st.flagged m
  pending : ∀ w, ¬ s.st.pending w

/-- On the edges in force, no monitor detects in a state `u` in which every monitor
present after the environment phase is alive and every present checker of a bad process is
bad itself. A signal is read in force only if its sender is present, and a state is
checked in force only if the checker is present. -/
theorem no_detect (sys : JSystem M W B S G) (s s₁ : JState M W G) (u : State M W)
    (halive : ∀ m, JPresent sys s₁ (.inl m) → u.alive (.inl m))
    (hchk : ∀ x m, u.bad x → sys.base.checkers x m → JPresent sys s₁ (.inl m) →
      u.bad (.inl m)) :
    ∀ m, ¬ Detects (effective sys s s₁) u m := by
  rintro m ⟨hact, ⟨x, hx, hc, hin⟩ | ⟨p, hp, _, hin⟩⟩
  · exact hact.2.1 (hchk x m hx.1 hc hin.2.1)
  · exact hp (halive p hin.1)

/-- On the edges in force, no process sees a reason to halt when `out` is empty and every
monitor present after the environment phase is alive: a halt input is in force only if it
is present. -/
theorem no_sees (sys : JSystem M W B S G) (s s₁ : JState M W G) (u : State M W)
    (o : M → Prop) (ho : ∀ m, ¬ o m)
    (halive : ∀ m, JPresent sys s₁ (.inl m) → u.alive (.inl m)) :
    ∀ w, ¬ Sees (effective sys s s₁) u o w := by
  rintro w (⟨m, _, hm⟩ | ⟨_, m, hin, hm⟩)
  · exact ho m hm
  · exact hm (halive m hin.2.2.1)

/-- A monitor phase with no flag before it and no detection changes nothing. -/
theorem monitorPhase_quiet {sys : System M W B S} {u : State M W}
    (hflag : ∀ m, ¬ u.flagged m) (hdet : ∀ m, ¬ Detects sys u m) :
    monitorPhase sys u = u :=
  state_ext (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl)
    (fun m => ⟨fun h => absurd h (Necessity.flag_needs_detection sys u hflag hdet m),
      fun h => absurd h (hflag m)⟩)
    (fun _ => Iff.rfl) (fun _ => Iff.rfl) Iff.rfl

/-- A work phase in which no process is pending and none sees a reason to halt changes
nothing. -/
theorem workPhase_quiet {sys : System M W B S} {u : State M W} {o : M → Prop}
    (hpend : ∀ w, ¬ u.pending w) (hsees : ∀ w, ¬ Sees sys u o w) :
    workPhase sys u o = u :=
  state_ext (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl)
    (fun _ => Iff.rfl)
    (fun w => ⟨fun h => h.elim id fun h' => h'.2.elim (fun hp => absurd hp (hpend w))
      (fun hs => absurd hs.1 (hsees w)), Or.inl⟩)
    (fun w => ⟨fun h => h.elim (fun h' => h'.1) (fun h' => absurd h'.2.2.1 (hsees w)),
      fun h => absurd h (hpend w)⟩)
    Iff.rfl

/-- If the environment phase ends in a quiet state, the monitor and work phases change
nothing, in either order. -/
theorem afterEnv_quiet (sys : JSystem M W B S G) (s s₁ : JState M W G)
    (hq : Quiet sys s₁) : (afterEnv (effective sys s s₁) s₁.st).next = s₁.st := by
  have hm : monitorPhase (effective sys s s₁) s₁.st = s₁.st :=
    monitorPhase_quiet hq.flagged
      (no_detect sys s s₁ s₁.st hq.alive (fun x _ hx _ _ => absurd hx (hq.bad x)))
  have hw : workPhase (effective sys s s₁) s₁.st (Out s₁.st) = s₁.st :=
    workPhase_quiet hq.pending
      (no_sees sys s s₁ s₁.st (Out s₁.st) (fun m hm => hq.flagged m hm.1) hq.alive)
  cases hg : (effective sys s s₁).gate with
  | true =>
    rw [afterEnv_gate _ _ hg]
    show workPhase (effective sys s s₁) (monitorPhase (effective sys s s₁) s₁.st)
      (Out (monitorPhase (effective sys s s₁) s₁.st)) = s₁.st
    rw [hm, hw]
  | false =>
    rw [afterEnv_noGate _ _ hg]
    show monitorPhase (effective sys s s₁)
      (workPhase (effective sys s s₁) s₁.st (Out s₁.st)) = s₁.st
    rw [hw, hm]

/-- The initial state is quiet. -/
theorem quiet_init (sys : JSystem M W B S G) : Quiet sys (jinit sys) where
  alive := by
    intro m hm
    show sys.group m = none
    cases hg : sys.group m with
    | none => rfl
    | some g => exact (hm g hg).elim
  bad := fun _ h => h
  flagged := fun _ h => h
  pending := fun _ h => h

/-- The joiner's step keeps a quiet state quiet. -/
theorem quiet_join {sys : JSystem M W B S G} {s : JState M W G} (hq : Quiet sys s) :
    Quiet sys (jeffect sys s .join) where
  alive := fun m hm => Or.inl (hq.alive m hm)
  bad := hq.bad
  flagged := hq.flagged
  pending := hq.pending

/-- A group's step keeps a quiet state quiet: its members become present and alive
together. -/
theorem quiet_group {sys : JSystem M W B S G} {s : JState M W G} (hq : Quiet sys s)
    (g : G) : Quiet sys (jeffect sys s (.joinGroup g)) where
  alive := by
    intro m hm
    show s.st.alive (.inl m) ∨ sys.group m = some g
    by_cases hmem : sys.group m = some g
    · exact Or.inr hmem
    · refine Or.inl (hq.alive m fun h hh => (hm h hh).elim (fun e => ?_) id)
      rw [e] at hh
      exact absurd hh hmem
  bad := hq.bad
  flagged := hq.flagged
  pending := hq.pending

/-- From a reachable quiet state, a round of one enabled step that ends its environment
phase in a quiet state reaches exactly the state after that step. -/
theorem quiet_step {sys : JSystem M W B S G} (hf : 1 ≤ sys.base.f) {s : JState M W G}
    {e : JStep M W B S G} (hreach : JReachable sys s) (hq : Quiet sys s)
    (he : JEnabled sys s e) (hq' : Quiet sys (jeffect sys s e)) :
    JReachable sys (jeffect sys s e) := by
  have h : JReachable sys (jafterEnv sys s (jeffect sys s e)).next :=
    JReachable.round hreach (Necessity.not_responded hq.flagged)
      ⟨[e], jeffect sys s e, hf, JEnvRun.cons he (JEnvRun.nil _), rfl⟩
  have heq : (jafterEnv sys s (jeffect sys s e)).next = jeffect sys s e := by
    show ({ st := (afterEnv (effective sys s (jeffect sys s e)) (jeffect sys s e).st).next
            arrived := (jeffect sys s e).arrived } : JState M W G) = jeffect sys s e
    rw [afterEnv_quiet sys s _ hq']
  rw [heq] at h
  exact h

/-- Every state the joins reach is reached by an execution, one join a round, and is
quiet. -/
theorem joinsReach_quiet (sys : JSystem M W B S G) (hf : 1 ≤ sys.base.f)
    {s : JState M W G} (hs : JoinsReach sys s) : JReachable sys s ∧ Quiet sys s := by
  induction hs with
  | init => exact ⟨JReachable.init, quiet_init sys⟩
  | join _ he ih => exact ⟨quiet_step hf ih.1 ih.2 he (quiet_join ih.2), quiet_join ih.2⟩
  | group g _ he ih =>
    exact ⟨quiet_step hf ih.1 ih.2 he (quiet_group ih.2 g), quiet_group ih.2 g⟩

end Quiet

/-! ### The third statement -/

/-- A monitor nobody checks. The joins are taken one a round, and then the monitor `z` is
mutated. Every present monitor is alive, so no silence is read; `z` is the only bad
process, and a monitor that checks `z` on an edge in force is present, so it is `z`, which
is bad and detects nothing. -/
theorem unchecked_present_monitor_gap {G : Type} (sys : JSystem M W B S G)
    (hf : 1 ≤ sys.base.f) (s : JState M W G) (hs : JoinsReach sys s) (z : M)
    (hz : JPresent sys s (.inl z))
    (hc : ∀ r, sys.base.checkers (.inl z) r → JPresent sys s (.inl r) → r = z) :
    JViolatesG1 sys := by
  obtain ⟨hreach, hq⟩ := joinsReach_quiet sys hf hs
  have he : JEnabled sys s (.mutate (.inl z)) := ⟨hz, hq.bad _⟩
  refine ⟨s, jafterEnv sys s (jeffect sys s (.mutate (.inl z))), hreach,
    Necessity.not_responded hq.flagged,
    ⟨[.mutate (.inl z)], _, hf, JEnvRun.cons he (JEnvRun.nil _), rfl⟩, ?_⟩
  show (afterEnv (effective sys s (jeffect sys s (.mutate (.inl z))))
    (jeffect sys s (.mutate (.inl z))).st).g1
  refine Necessity.afterEnv_g1 ⟨.inl z, Or.inl rfl⟩ hq.flagged
    (no_detect sys s _ _ hq.alive ?_)
  intro x m hx hchk hpres
  rcases hx with hx | hx
  · rw [hx] at hchk
    exact Or.inl (congrArg Sum.inl (hc m hchk hpres))
  · exact absurd hx (hq.bad x)

end JoinPlain
end SelfObserving
