/-
Proofs of the four statements of `Challenge.lean` about the two systems of
`JoinExamples.lean`: `slow_check_example_gap`, `slow_check_example_rest`,
`switch_example_gap` and `switch_example_rest`.

The two statements about a gap are proved by giving an execution. The file has these parts:

- what a round of the model with joins does when no monitor detects: a round whose
  environment phase ends with nothing bad and every present monitor alive ends in the state
  its environment phase reached, and a round whose environment phase ends with a bad
  process, no flag and no detection violates both goals;
- `slowCheckExample`: one round from the initial state, in which the late monitor joins
  and is bad;
- `switchExample`: three rounds that change nothing but what their one step changes, and a
  fourth in which N6 is bad and its only state checker is off;
- the other hypotheses of Theorem L for the two systems. That the mesh of four answers
  faults (`AnswersFaults`) is taken as a hypothesis here, in `slow_check_example_rest_of`
  and `switch_example_rest_of`: it is proved elsewhere.
-/
import SelfObserving.JoinExamples
import SelfObserving.Proofs.Necessity

namespace SelfObserving
namespace JoinExampleProofs

variable {M W B S G : Type}

/-! ### Rounds of the model with joins in which no monitor detects -/

/-- Two states with the same components are the same state. -/
theorem state_ext {a b : State M W} (h₁ : a.alive = b.alive) (h₂ : a.bad = b.bad)
    (h₃ : a.hidden = b.hidden) (h₄ : a.off = b.off) (h₅ : a.flagged = b.flagged)
    (h₆ : a.halted = b.halted) (h₇ : a.pending = b.pending) (h₈ : a.joined = b.joined) :
    a = b := by
  cases a
  cases b
  cases h₁
  cases h₂
  cases h₃
  cases h₄
  cases h₅
  cases h₆
  cases h₇
  cases h₈
  rfl

/-- No environment step of the model with joins changes `flagged`. -/
theorem jeffect_flagged (sys : JSystem M W B S G) (s : JState M W G) (e : JStep M W B S G) :
    (jeffect sys s e).st.flagged = s.st.flagged := by
  cases e <;> rfl

/-- With the gate, the round ends in the state the work phase leaves. -/
theorem afterEnv_gate_next (sys : System M W B S) (s₁ : State M W) (hg : sys.gate = true) :
    (afterEnv sys s₁).next =
      workPhase sys (monitorPhase sys s₁) (Out (monitorPhase sys s₁)) := by
  unfold afterEnv
  simp only [hg, ite_true]

/-- If nothing is bad after the environment phase and every present monitor is alive, no
monitor detects on the edges in force: a monitor that is not alive is not present, so no
edge with it is in force. -/
theorem no_detect_good (sys : JSystem M W B S G) (s s₁ : JState M W G)
    (hbad : ∀ p, ¬ s₁.st.bad p)
    (halive : ∀ m, JPresent sys s₁ (.inl m) → s₁.st.alive (.inl m)) :
    ∀ m, ¬ Detects (effective sys s s₁) s₁.st m := by
  rintro m ⟨_, ⟨x, hx, _⟩ | ⟨p, hp, hr⟩⟩
  · exact hbad x hx.1
  · obtain ⟨_, hpres, _⟩ := hr
    exact hp (halive p hpres)

/-- If the environment phase ends with no flag, no monitor detecting and every present
monitor alive, then after the monitor phase no work process sees a reason to halt. -/
theorem not_sees_quiet (sys : JSystem M W B S G) (s s₁ : JState M W G)
    (hflag : ∀ m, ¬ s₁.st.flagged m)
    (hdet : ∀ m, ¬ Detects (effective sys s s₁) s₁.st m)
    (halive : ∀ m, JPresent sys s₁ (.inl m) → s₁.st.alive (.inl m)) (w : W) :
    ¬ Sees (effective sys s s₁) (monitorPhase (effective sys s s₁) s₁.st)
        (Out (monitorPhase (effective sys s s₁) s₁.st)) w := by
  rintro (⟨m, _, hm⟩ | ⟨_, m, hin, hm⟩)
  · exact Necessity.flag_needs_detection (effective sys s s₁) s₁.st hflag hdet m hm.1
  · obtain ⟨_, _, hpres, _⟩ := hin
    exact hm (halive m hpres)

/-- A round in which no monitor detects changes nothing after its environment phase: with
the gate, if the environment phase ends with no flag, no pending process, no monitor
detecting and every present monitor alive, the round ends in the state the environment
phase reached. -/
theorem jafterEnv_quiet (sys : JSystem M W B S G) (s s₁ : JState M W G)
    (hgate : sys.base.gate = true) (hflag : ∀ m, ¬ s₁.st.flagged m)
    (hpend : ∀ w, ¬ s₁.st.pending w)
    (hdet : ∀ m, ¬ Detects (effective sys s s₁) s₁.st m)
    (halive : ∀ m, JPresent sys s₁ (.inl m) → s₁.st.alive (.inl m)) :
    (jafterEnv sys s s₁).next = s₁ := by
  have hfa := Necessity.flag_needs_detection (effective sys s s₁) s₁.st hflag hdet
  have hsees := not_sees_quiet sys s s₁ hflag hdet halive
  have hst : (afterEnv (effective sys s s₁) s₁.st).next = s₁.st := by
    rw [afterEnv_gate_next _ _ (show (effective sys s s₁).gate = true from hgate)]
    refine state_ext rfl rfl rfl rfl ?_ ?_ ?_ rfl
    · exact funext fun m => propext ⟨fun h => absurd h (hfa m), fun h => absurd h (hflag m)⟩
    · refine funext fun w => propext ⟨fun h => ?_, Or.inl⟩
      rcases h with h | ⟨_, h | h⟩
      · exact h
      · exact absurd h (hpend w)
      · exact absurd h.1 (hsees w)
    · refine funext fun w => propext ⟨fun h => ?_, fun h => absurd h (hpend w)⟩
      rcases h with h | ⟨_, _, h, _⟩
      · exact h.1
      · exact absurd h (hsees w)
  show ({ st := (afterEnv (effective sys s s₁) s₁.st).next, arrived := s₁.arrived } :
    JState M W G) = s₁
  rw [hst]

/-- A round of one enabled step after which nothing is bad and every present monitor is
alive, from a reachable state with no flag: the state after the step is reachable. -/
theorem quiet_step {sys : JSystem M W B S G} {s : JState M W G} (e : JStep M W B S G)
    (hreach : JReachable sys s) (hflag : ∀ m, ¬ s.st.flagged m) (hf : 1 ≤ sys.base.f)
    (hgate : sys.base.gate = true) (hen : JEnabled sys s e)
    (hpend : ∀ w, ¬ (jeffect sys s e).st.pending w)
    (hbad : ∀ p, ¬ (jeffect sys s e).st.bad p)
    (halive : ∀ m, JPresent sys (jeffect sys s e) (.inl m) →
      (jeffect sys s e).st.alive (.inl m)) :
    JReachable sys (jeffect sys s e) := by
  have hflag' : ∀ m, ¬ (jeffect sys s e).st.flagged m := by
    rw [jeffect_flagged]
    exact hflag
  have hq := jafterEnv_quiet sys s (jeffect sys s e) hgate hflag' hpend
    (no_detect_good sys s _ hbad halive) halive
  have hr : JReachable sys (jafterEnv sys s (jeffect sys s e)).next :=
    JReachable.round (r := jafterEnv sys s (jeffect sys s e)) hreach
      (Necessity.not_responded hflag)
      ⟨[e], jeffect sys s e, hf, JEnvRun.cons hen (JEnvRun.nil _), rfl⟩
  rw [hq] at hr
  exact hr

/-- A round violates both goals if, with the gate and no joiner, its environment phase
ends with a bad process, no flag, no monitor detecting on the edges in force, every
present monitor alive, and a work process that is neither halted nor pending: `out` is
empty, and that process sees no reason to halt and takes a work step. -/
theorem jafterEnv_gap (sys : JSystem M W B S G) (s s₁ : JState M W G)
    (hgate : sys.base.gate = true) (hj : sys.base.joiner = none)
    (hflag : ∀ m, ¬ s₁.st.flagged m) (hbad : ∃ p, s₁.st.bad p)
    (hdet : ∀ m, ¬ Detects (effective sys s s₁) s₁.st m)
    (halive : ∀ m, JPresent sys s₁ (.inl m) → s₁.st.alive (.inl m))
    (w : W) (hh : ¬ s₁.st.halted w) (hp : ¬ s₁.st.pending w) :
    (jafterEnv sys s s₁).g1 ∧ (jafterEnv sys s s₁).g2 := by
  refine ⟨Necessity.afterEnv_g1 hbad hflag hdet, ?_⟩
  refine Necessity.afterEnv_g2 (sys := effective sys s s₁) hbad (fun h => ?_) hh hp
    (fun _ h => not_sees_quiet sys s s₁ hflag hdet halive w h.1) (fun h => ?_)
  · have h' : sys.base.joiner = some w := h
    rw [hj] at h'
    cases h'
  · have h' : sys.base.gate = false := h
    rw [hgate] at h'
    cases h'

/-- Both goals can be violated if some round from a reachable state with no flag violates
both. -/
theorem violates_of_round {sys : JSystem M W B S G} {s s₁ : JState M W G}
    {steps : List (JStep M W B S G)} (hreach : JReachable sys s)
    (hflag : ∀ m, ¬ s.st.flagged m) (hlen : steps.length ≤ sys.base.f)
    (hrun : JEnvRun sys s steps s₁)
    (hgap : (jafterEnv sys s s₁).g1 ∧ (jafterEnv sys s s₁).g2) :
    JViolatesG1 sys ∧ JViolatesG2 sys :=
  ⟨⟨s, jafterEnv sys s s₁, hreach, Necessity.not_responded hflag,
      ⟨steps, s₁, hlen, hrun, rfl⟩, hgap.1⟩,
    ⟨s, jafterEnv sys s s₁, hreach, Necessity.not_responded hflag,
      ⟨steps, s₁, hlen, hrun, rfl⟩, hgap.2⟩⟩

/-! ### The slow state checks of a late monitor -/

/-- In `slowCheckExample`, a first round violates both goals if its environment phase
ends with the late monitor N joined and bad, nothing else bad, every monitor alive, and
the work process neither halted nor pending. N is new in the round, so its three state
checks, which are slow, are not in force. -/
theorem slow_round_gap (ab : Bool) (f : Nat)
    (steps : List (JStep (Fin 4 ⊕ Unit) Unit (Fin 4 ⊕ Unit) Unit Unit))
    (s₁ : JState (Fin 4 ⊕ Unit) Unit Unit) (hlen : steps.length ≤ f)
    (hrun : JEnvRun (slowCheckExample ab f) (jinit (slowCheckExample ab f)) steps s₁)
    (harr : s₁.arrived ()) (hbad : s₁.st.bad (.inl (.inr ())))
    (honly : ∀ x, s₁.st.bad x → x = .inl (.inr ()))
    (halive : ∀ m, s₁.st.alive (.inl m)) (hflag : ∀ m, ¬ s₁.st.flagged m)
    (hh : ¬ s₁.st.halted ()) (hp : ¬ s₁.st.pending ()) :
    JViolatesG1 (slowCheckExample ab f) ∧ JViolatesG2 (slowCheckExample ab f) := by
  refine violates_of_round JReachable.init (fun _ h => h) hlen hrun ?_
  refine jafterEnv_gap _ _ s₁ rfl rfl hflag ⟨_, hbad⟩ ?_ (fun m _ => halive m) () hh hp
  rintro m ⟨_, ⟨x, hx, hc⟩ | ⟨p, hp', _⟩⟩
  · obtain ⟨hb, _⟩ := hx
    cases honly x hb
    obtain ⟨hc₁, _, _, hslow⟩ := hc
    cases m with
    | inl b =>
      have hnew : JNew (slowCheckExample ab f) (jinit (slowCheckExample ab f)) s₁
          (.inl (.inr ())) := ⟨fun _ _ => harr, fun h => h () rfl⟩
      exact (hslow hc₁).1 hnew
    | inr u => exact hc₁
  · exact hp' (halive p)

/-- `slowCheckExample false 2` after the environment phase of the round: N has joined and
has been mutated. -/
def sc2 : JState (Fin 4 ⊕ Unit) Unit Unit :=
  jeffect (slowCheckExample false 2)
    (jeffect (slowCheckExample false 2) (jinit (slowCheckExample false 2)) (.joinGroup ()))
    (.mutate (.inl (.inr ())))

/-- `slowCheckExample true 1` after the environment phase of the round: N has joined
bad. -/
def sc1 : JState (Fin 4 ⊕ Unit) Unit Unit :=
  jeffect (slowCheckExample true 1) (jinit (slowCheckExample true 1)) (.joinBad () (.inr ()))

/-- The hypothesis of Theorem L on slow edges is needed. When monitors arrive good, at
two faults per round: N joins and is mutated in one round. When a monitor may arrive bad,
at one fault per round: N joins bad. -/
theorem slow_check_example_gap :
    (JViolatesG1 (slowCheckExample false 2) ∧ JViolatesG2 (slowCheckExample false 2)) ∧
    (JViolatesG1 (slowCheckExample true 1) ∧ JViolatesG2 (slowCheckExample true 1)) := by
  constructor
  · refine slow_round_gap false 2 [.joinGroup (), .mutate (.inl (.inr ()))] sc2
      (Nat.le_refl 2) ?_ (Or.inl rfl) (Or.inl rfl) ?_ ?_ (fun _ h => h) (fun h => h)
      (fun h => h)
    · refine JEnvRun.cons ⟨fun h => h, fun _ h => h.elim⟩ (JEnvRun.cons ?_ (JEnvRun.nil _))
      exact ⟨fun _ _ => Or.inl rfl, fun h => h⟩
    · intro x hx
      rcases hx with hx | hx
      · exact hx
      · exact hx.elim
    · intro m
      cases m with
      | inl a => exact Or.inl rfl
      | inr u => exact Or.inr rfl
  · refine slow_round_gap true 1 [.joinBad () (.inr ())] sc1
      (Nat.le_refl 1) ?_ (Or.inl rfl) (Or.inl rfl) ?_ ?_ (fun _ h => h) (fun h => h)
      (fun h => h)
    · exact JEnvRun.cons ⟨rfl, ⟨fun h => h, fun _ h => h.elim⟩, rfl⟩ (JEnvRun.nil _)
    · intro x hx
      rcases hx with hx | hx
      · exact hx
      · exact hx.elim
    · intro m
      cases m with
      | inl a => exact Or.inl rfl
      | inr u => exact Or.inr rfl

/-! ### The off switch of a late monitor that another leans on -/

/-- The two elements of `Fin 2`. -/
theorem fin2 : ∀ i : Fin 2, i = 0 ∨ i = 1 := by decide

/-- `switchExample` after round 1: N5 has joined. -/
def sw1 : JState (Fin 4 ⊕ Fin 2) Unit (Fin 2) :=
  jeffect switchExample (jinit switchExample) (.joinGroup 0)

/-- `switchExample` after round 2: N6 has joined as well. -/
def sw2 : JState (Fin 4 ⊕ Fin 2) Unit (Fin 2) := jeffect switchExample sw1 (.joinGroup 1)

/-- `switchExample` after round 3: N5 is switched off. -/
def sw3 : JState (Fin 4 ⊕ Fin 2) Unit (Fin 2) :=
  jeffect switchExample sw2 (.disable (.inr 0))

/-- `switchExample` after the environment phase of round 4: N6 is bad. -/
def sw4 : JState (Fin 4 ⊕ Fin 2) Unit (Fin 2) :=
  jeffect switchExample sw3 (.mutate (.inl (.inr 1)))

/-- After round 1 every present monitor is alive: N6 is neither. -/
theorem sw1_alive (m : Fin 4 ⊕ Fin 2) (hm : JPresent switchExample sw1 (.inl m)) :
    sw1.st.alive (.inl m) := by
  cases m with
  | inl a => exact Or.inl rfl
  | inr i =>
    rcases hm i rfl with h | h
    · cases h
      exact Or.inr rfl
    · exact h.elim

/-- After round 2 every monitor is alive. -/
theorem sw2_alive (m : Fin 4 ⊕ Fin 2) : sw2.st.alive (.inl m) := by
  cases m with
  | inl a => exact Or.inl (Or.inl rfl)
  | inr i =>
    rcases fin2 i with h | h
    · cases h
      exact Or.inl (Or.inr rfl)
    · cases h
      exact Or.inr rfl

/-- Round 1: N5 joins. Nothing is bad and no present monitor is not alive, so the round
ends in the state after its one step. -/
theorem sw1_reachable : JReachable switchExample sw1 := by
  refine quiet_step (.joinGroup 0) JReachable.init (fun _ h => h) (Nat.le_refl 1) rfl ?_
    (fun _ h => h) (fun _ h => h) sw1_alive
  refine ⟨fun h => h, fun p hp => ?_⟩
  obtain ⟨h, _⟩ := hp
  exact absurd h (by decide)

/-- Round 2: N6 joins, which it may because N5 is present. -/
theorem sw2_reachable : JReachable switchExample sw2 := by
  refine quiet_step (.joinGroup 1) sw1_reachable (fun _ h => h) (Nat.le_refl 1) rfl ?_
    (fun _ h => h) (fun _ h => h) (fun m _ => sw2_alive m)
  refine ⟨fun h => ?_, fun p hp => ?_⟩
  · rcases h with h | h
    · exact absurd h (by decide)
    · exact h
  · obtain ⟨_, hp⟩ := hp
    cases hp
    intro g hg
    cases hg
    exact Or.inl rfl

/-- Round 3: N5 is switched off. Being off is not a fault any monitor sees. -/
theorem sw3_reachable : JReachable switchExample sw3 := by
  refine quiet_step (.disable (.inr 0)) sw2_reachable (fun _ h => h) (Nat.le_refl 1) rfl ?_
    (fun _ h => h) (fun _ h => h) (fun m _ => sw2_alive m)
  refine ⟨fun g hg => ?_, rfl, fun h => h⟩
  cases hg
  exact Or.inr (Or.inl rfl)

/-- The hypothesis of Theorem L on switches is needed: N5 joins, N6 joins, N5 is switched
off, N6 is mutated. In the fourth round N6 is bad, and its only state checker, N5, is off
and so not active. -/
theorem switch_example_gap : JViolatesG1 switchExample ∧ JViolatesG2 switchExample := by
  have hen : JEnabled switchExample sw3 (.mutate (.inl (.inr 1))) := by
    refine ⟨fun g hg => ?_, fun h => h⟩
    cases hg
    exact Or.inl rfl
  refine violates_of_round (steps := [.mutate (.inl (.inr 1))]) (s₁ := sw4) sw3_reachable (fun _ h => h) (Nat.le_refl 1)
    (JEnvRun.cons hen (JEnvRun.nil _)) ?_
  refine jafterEnv_gap _ _ sw4 rfl rfl (fun _ h => h) ⟨.inl (.inr 1), Or.inl rfl⟩ ?_
    (fun m _ => sw2_alive m) () (fun h => h) (fun h => h)
  rintro m ⟨hact, ⟨x, hx, hc⟩ | ⟨p, hp, _⟩⟩
  · obtain ⟨hb, _⟩ := hx
    rcases hb with hb | hb
    · cases hb
      obtain ⟨hc₁, _⟩ := hc
      cases m with
      | inl b =>
        obtain ⟨h, _⟩ := hc₁
        exact absurd h (by decide)
      | inr j =>
        obtain ⟨_, h⟩ := hc₁
        cases h
        obtain ⟨_, _, hoff⟩ := hact
        exact hoff (Or.inl rfl)
    · exact hb
  · exact hp (sw2_alive p)

/-! ### The other hypotheses of Theorem L -/

/-- A flag at any monitor of the mesh reaches a halt input of every work process: every
monitor is a halt input. -/
theorem mesh_flag_reaches (f : Nat) : FlagReachesWork (meshAt (Fin 4) Unit f) :=
  fun m _ => ⟨m, trivial, Reach.refl m⟩

/-- `slowCheckExample` without its late monitor is the mesh of four. -/
theorem slow_initialPart (ab : Bool) (f : Nat) :
    InitialPart (slowCheckExample ab f) (meshAt (Fin 4) Unit f) Sum.inl Sum.inl id where
  inj := fun _ _ h => Sum.inl.inj h
  initial := fun m => by
    cases m with
    | inl a => exact ⟨fun _ => ⟨a, rfl⟩, fun _ => rfl⟩
    | inr u => exact ⟨fun h => (by cases h), fun ⟨_, h⟩ => (by cases h)⟩
  β_inj := fun _ _ h => Sum.inl.inj h
  σ_inj := fun _ _ h => h
  f := rfl
  joiner := rfl
  joiner_free := rfl
  boundary := fun _ => rfl
  substrate_mon := fun _ => rfl
  substrate_work := fun _ => rfl
  hb := fun _ _ => Iff.rfl
  check_mon := fun _ _ => Iff.rfl
  check_work := fun _ _ => Iff.rfl
  fwd := fun _ _ => Iff.rfl
  halt := fun _ _ => Iff.rfl
  switches := fun _ => Iff.rfl
  coupling := rfl
  window := rfl
  gate := rfl
  slowReports := rfl
  joiner_prompt := fun _ _ h => by cases h

/-- `slowCheckExample` is of the class of Theorem L. -/
theorem slow_grown (ab : Bool) (f : Nat) : GrownClass (slowCheckExample ab f) where
  no_joiner := rfl
  no_substrate := fun _ => rfl
  boundaries_distinct := fun _ _ _ hne h => hne (Option.some.inj (h.1.trans h.2.symm))
  coupling_on := rfl
  no_window := rfl
  gate_on := rfl
  reports_fast := rfl

/-- The late monitor of `slowCheckExample` relies on M1, under the ranking that gives
every monitor rank 0. -/
theorem slow_ranked (ab : Bool) (f : Nat) :
    Ranked (slowCheckExample ab f) (fun _ => 0) (fun _ => .inl 0) (fun _ => .inl 0)
      (fun _ => .inl 0) where
  check := fun n hn => by
    cases n with
    | inl a => exact (hn rfl).elim
    | inr u => exact (by decide : (0 : Fin 4).val < 3)
  read := fun n hn => by
    cases n with
    | inl a => exact (hn rfl).elim
    | inr u => exact (by decide : (0 : Fin 4).val < 3)
  report := fun n hn => by
    cases n with
    | inl a => exact (hn rfl).elim
    | inr u => exact (by decide : (0 : Fin 4).val < 3)
  lower := fun _ _ c hc => by
    have hc' : c = .inl 0 := by
      rcases hc with h | h | h <;> exact h
    cases hc'
    exact Or.inl fun h => h rfl
  present := fun _ _ _ _ _ c hc => by
    have hc' : c = .inl 0 := by
      rcases hc with h | h | h <;> exact h
    cases hc'
    intro g hg
    cases hg

/-- `slow_check_example_rest` of `Challenge.lean`, with its hypothesis `f ≤ 3` replaced by
what it is used for: that the mesh of four answers faults at `f` faults per round. -/
theorem slow_check_example_rest_of (arriveBad : Bool) (f : Nat)
    (ha : AnswersFaults (meshAt (Fin 4) Unit f)) :
    InitialPart (slowCheckExample arriveBad f) (meshAt (Fin 4) Unit f) Sum.inl Sum.inl id ∧
    GrownClass (slowCheckExample arriveBad f) ∧
    (∀ m, ¬ (slowCheckExample arriveBad f).base.switches m) ∧
    AnswersFaults (meshAt (Fin 4) Unit f) ∧ FlagReachesWork (meshAt (Fin 4) Unit f) ∧
    Ranked (slowCheckExample arriveBad f) (fun _ => 0) (fun _ => .inl 0) (fun _ => .inl 0)
      (fun _ => .inl 0) ∧
    (∀ n, (slowCheckExample arriveBad f).Late n →
      (slowCheckExample arriveBad f).slowCheck (.inl n) (.inl 0) ∧
      ¬ (slowCheckExample arriveBad f).slowHb n (.inl 0) ∧
      ¬ (slowCheckExample arriveBad f).slowFwd n (.inl 0)) := by
  refine ⟨slow_initialPart arriveBad f, slow_grown arriveBad f, fun _ h => h, ha,
    mesh_flag_reaches f, slow_ranked arriveBad f, fun n hn => ?_⟩
  cases n with
  | inl a => exact (hn rfl).elim
  | inr u => exact ⟨(by decide : (0 : Fin 4).val < 3), fun h => h, fun h => h⟩

/-- `switchExample` without its late monitors is the mesh of four. -/
theorem switch_initialPart :
    InitialPart switchExample (meshAt (Fin 4) Unit 1) Sum.inl Sum.inl id where
  inj := fun _ _ h => Sum.inl.inj h
  initial := fun m => by
    cases m with
    | inl a => exact ⟨fun _ => ⟨a, rfl⟩, fun _ => rfl⟩
    | inr i => exact ⟨fun h => (by cases h), fun ⟨_, h⟩ => (by cases h)⟩
  β_inj := fun _ _ h => Sum.inl.inj h
  σ_inj := fun _ _ h => h
  f := rfl
  joiner := rfl
  joiner_free := rfl
  boundary := fun _ => rfl
  substrate_mon := fun _ => rfl
  substrate_work := fun _ => rfl
  hb := fun _ _ => Iff.rfl
  check_mon := fun _ _ => Iff.rfl
  check_work := fun _ _ => Iff.rfl
  fwd := fun _ _ => Iff.rfl
  halt := fun _ _ => Iff.rfl
  switches := fun _ => ⟨fun h => (by cases h), fun h => h.elim⟩
  coupling := rfl
  window := rfl
  gate := rfl
  slowReports := rfl
  joiner_prompt := fun _ _ h => by cases h

/-- `switchExample` is of the class of Theorem L. -/
theorem switch_grown : GrownClass switchExample where
  no_joiner := rfl
  no_substrate := fun _ => rfl
  boundaries_distinct := fun _ _ _ hne h => hne (Option.some.inj (h.1.trans h.2.symm))
  coupling_on := rfl
  no_window := rfl
  gate_on := rfl
  reports_fast := rfl

/-- In every state the joins of `switchExample` reach, N6 has joined only if N5 has: the
group of N6 may join only when N5 is present. -/
theorem switch_arrived {s : JState (Fin 4 ⊕ Fin 2) Unit (Fin 2)}
    (h : JoinsReach switchExample s) : s.arrived 1 → s.arrived 0 := by
  induction h with
  | init => exact fun h => h
  | join _ hen _ =>
    obtain ⟨hj, _⟩ := hen
    exact (hj rfl).elim
  | group g _ hen ih =>
    obtain ⟨_, hafter⟩ := hen
    intro h
    rcases h with h | h
    · exact Or.inr (hafter (.inl (.inr 0)) ⟨h.symm, rfl⟩ 0 rfl)
    · exact Or.inr (ih h)

/-- N5 relies on M1 and N6 on N5, ranked accordingly. -/
theorem switch_ranked :
    Ranked switchExample switchRank switchRelies switchRelies switchRelies where
  check := fun n hn => by
    cases n with
    | inl a => exact (hn rfl).elim
    | inr i =>
      rcases fin2 i with h | h
      · cases h
        exact ⟨rfl, rfl⟩
      · cases h
        exact ⟨rfl, rfl⟩
  read := fun n hn => by
    cases n with
    | inl a => exact (hn rfl).elim
    | inr i =>
      rcases fin2 i with h | h
      · cases h
        exact ⟨rfl, rfl⟩
      · cases h
        exact ⟨rfl, rfl⟩
  report := fun n hn => by
    cases n with
    | inl a => exact (hn rfl).elim
    | inr i =>
      rcases fin2 i with h | h
      · cases h
        exact ⟨rfl, rfl⟩
      · cases h
        exact ⟨rfl, rfl⟩
  lower := fun n hn c hc => by
    have hc' : c = switchRelies n := by
      rcases hc with h | h | h <;> exact h
    cases hc'
    cases n with
    | inl a => exact (hn rfl).elim
    | inr i =>
      rcases fin2 i with h | h
      · cases h
        exact Or.inl fun h => h rfl
      · cases h
        exact Or.inr (by decide : switchRank (.inr 0) < switchRank (.inr 1))
  present := fun s hs n hn hp c hc => by
    have hc' : c = switchRelies n := by
      rcases hc with h | h | h <;> exact h
    cases hc'
    cases n with
    | inl a => exact (hn rfl).elim
    | inr i =>
      rcases fin2 i with h | h
      · cases h
        intro g hg
        cases hg
      · cases h
        have h0 : s.arrived 0 := switch_arrived hs (hp 1 rfl)
        intro g hg
        cases hg
        exact h0

/-- `switch_example_rest` of `Challenge.lean`, with the statement that the mesh of four
answers faults at one fault per round taken as a hypothesis. -/
theorem switch_example_rest_of (ha : AnswersFaults (meshAt (Fin 4) Unit 1)) :
    InitialPart switchExample (meshAt (Fin 4) Unit 1) Sum.inl Sum.inl id ∧
    GrownClass switchExample ∧
    AnswersFaults (meshAt (Fin 4) Unit 1) ∧ FlagReachesWork (meshAt (Fin 4) Unit 1) ∧
    Ranked switchExample switchRank switchRelies switchRelies switchRelies ∧
    Prompt switchExample switchRelies switchRelies switchRelies ∧
    (∀ m, switchExample.base.switches m ↔ m = .inr 0) :=
  ⟨switch_initialPart, switch_grown, ha, mesh_flag_reaches 1, switch_ranked,
    fun _ _ => ⟨fun h => h, fun h => h, fun h => h⟩, fun _ => Iff.rfl⟩

end JoinExampleProofs
end SelfObserving
