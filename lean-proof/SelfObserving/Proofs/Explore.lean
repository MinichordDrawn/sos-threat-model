/-
Three computations on a system over the reference system's types, at one fault per round,
and what each one establishes. The kernel carries them out.

- A goal can be violated: give an execution, as a list of rounds, each with the
  environment's step or none. `ctrace` runs it and gives the outcome of each round, and
  `violatesG1_of_trace` and `violatesG2_of_trace` conclude from the last one.
- A goal cannot be violated: give a list `L` of states. `covers` checks that `L` holds the
  initial state, and that every round from every state of `L` that is not responded ends
  in a state of `L` and does not violate the goal. `Covers.noG1`, `Covers.noG2` and
  `Covers.noGap` conclude, because every reachable state is in `L` (`Covers.reachable`).
- The states of `L` are reached: give, for each state after the first, a round that ends
  in it and starts from a state before it. `reaches` checks them. With `covers`, the
  states of `L` are then the reachable states, no more and no fewer (`reachable_iff`).
  `distinct` and `countRounds` count the states and the rounds that were checked, and
  `reachable_count` gives the number of reachable states (`ReachableCount`).

Nothing here mentions a particular system.
-/
import SelfObserving.Proofs.Finite

namespace SelfObserving
namespace Finite

/-- `sys` has exactly `n` reachable states: they can be listed, each once, in a list of
length `n`. -/
def ReachableCount {M W B S : Type} (sys : System M W B S) (n : Nat) : Prop :=
  ∃ l : List (State M W), l.length = n ∧ l.Nodup ∧ ∀ s, Reachable sys s ↔ s ∈ l

/-! ### One round, at one fault per round -/

/-- At one fault per round, a round is the phases after the environment phase, from the
state itself or from the state after one enabled step. -/
theorem round_iff {M W B S : Type} (sys : System M W B S) (hf : sys.f = 1) (s : State M W)
    (r : Outcome M W) :
    Round sys s r ↔
      r = afterEnv sys s ∨ ∃ e, Enabled sys s e ∧ r = afterEnv sys (effect sys s e) := by
  constructor
  · rintro ⟨steps, s₁, hlen, hrun, rfl⟩
    rw [hf] at hlen
    cases hrun with
    | nil => exact .inl rfl
    | cons he hrest =>
      cases hrest with
      | nil => exact .inr ⟨_, he, rfl⟩
      | cons _ _ =>
        simp only [List.length_cons] at hlen
        omega
  · rintro (rfl | ⟨e, he, rfl⟩)
    · exact ⟨[], s, Nat.zero_le _, .nil s, rfl⟩
    · exact ⟨[e], _, by simp [hf], .cons he (.nil _), rfl⟩

/-- Every environment step. -/
def allSteps : List (EnvStep Mon Wk Bd Sub) :=
  [.stop .M1, .stop .M2, .stop .M3,
   .stopBoundary .b1, .stopBoundary .b2, .stopBoundary .b3,
   .failSubstrate .s1, .failSubstrate .s2, .failSubstrate .s3, .failSubstrate .s4,
   .failSubstrate .s5,
   .mutate (.inl .M1), .mutate (.inl .M2), .mutate (.inl .M3),
   .mutate (.inr .W1), .mutate (.inr .W2), .mutate (.inr .J),
   .disable .M1, .disable .M2, .disable .M3,
   .join]

theorem mem_allSteps (e : EnvStep Mon Wk Bd Sub) : e ∈ allSteps := by
  cases e with
  | stop m => cases m <;> simp [allSteps]
  | stopBoundary b => cases b <;> simp [allSteps]
  | failSubstrate c => cases c <;> simp [allSteps]
  | mutate p =>
    cases p with
    | inl m => cases m <;> simp [allSteps]
    | inr w => cases w <;> simp [allSteps]
  | disable m => cases m <;> simp [allSteps]
  | join => simp [allSteps]

/-- The state after an environment step, written out. -/
def ceffect (sys : System Mon Wk Bd Sub) (c : CState) (e : EnvStep Mon Wk Bd Sub) : CState :=
  reify (effect sys c.toState e)

theorem ceffect_spec (sys : System Mon Wk Bd Sub) (c : CState) (e : EnvStep Mon Wk Bd Sub) :
    effect sys c.toState e = (ceffect sys c e).toState :=
  (toState_reify _).symm

/-- The initial state, written out. -/
def cinit (sys : System Mon Wk Bd Sub) : CState := reify (init sys)

theorem cinit_spec (sys : System Mon Wk Bd Sub) : init sys = (cinit sys).toState :=
  (toState_reify _).symm

section

variable (sys : System Mon Wk Bd Sub) [DecSys sys]

/-- Whether the outcome of every round from `c` passes the test `ok`. -/
def allRounds (c : CState) (ok : COut → Bool) : Bool :=
  ok (cafter sys c) &&
    allSteps.all fun e =>
      !decide (Enabled sys c.toState e) ||
        (ceffect sys c e).force fun c₁ => ok (cafter sys c₁)

theorem allRounds_spec (hf : sys.f = 1) {c : CState} {ok : COut → Bool}
    (h : allRounds sys c ok = true) {r : Outcome Mon Wk} (hr : Round sys c.toState r) :
    ∃ o, ok o = true ∧ r = o.toOutcome := by
  simp only [allRounds, Bool.and_eq_true, List.all_eq_true, Bool.or_eq_true,
    Bool.not_eq_true', decide_eq_false_iff_not, CState.force_eq] at h
  rcases (round_iff sys hf _ _).1 hr with rfl | ⟨e, he, rfl⟩
  · exact ⟨_, h.1, cafter_spec sys c⟩
  · rcases h.2 e (mem_allSteps e) with h' | h'
    · exact absurd he h'
    · exact ⟨_, h', by rw [ceffect_spec, cafter_spec]⟩

/-! ### A goal that cannot be violated -/

/-- The test of one outcome: the next state is in `L`, G1 is not violated if `n1` asks
for that, and G2 is not violated if `n2` does. -/
def okOut (L : List CState) (n1 n2 : Bool) (o : COut) : Bool :=
  match o with
  | ⟨next, g1, g2⟩ => !(n1 && g1) && !(n2 && g2) && next.force fun n => L.contains n

/-- The test of one state: it is responded, or every round from it passes `okOut`. -/
def closed (L : List CState) (n1 n2 : Bool) (c : CState) : Bool :=
  decide (Responded sys c.toState) || allRounds sys c (okOut L n1 n2)

theorem closed_spec (hf : sys.f = 1) {L : List CState} {n1 n2 : Bool} {c : CState}
    (h : closed sys L n1 n2 c = true) (hnr : ¬ Responded sys c.toState)
    {r : Outcome Mon Wk} (hr : Round sys c.toState r) :
    (∃ c' ∈ L, r.next = c'.toState) ∧ (n1 = true → ¬ r.g1) ∧ (n2 = true → ¬ r.g2) := by
  simp only [closed, Bool.or_eq_true, decide_eq_true_eq] at h
  rcases h with h | h
  · exact absurd h hnr
  · obtain ⟨⟨next, g1, g2⟩, hok, rfl⟩ := allRounds_spec sys hf h hr
    simp only [okOut, Bool.and_eq_true, Bool.not_eq_true', Bool.and_eq_false_iff,
      CState.force_eq, List.contains_iff_mem] at hok
    obtain ⟨⟨h1, h2⟩, hmem⟩ := hok
    refine ⟨⟨next, hmem, rfl⟩, fun hn hg => ?_, fun hn hg => ?_⟩
    · rcases h1 with h1 | h1
      · rw [hn] at h1
        cases h1
      · exact Bool.false_ne_true (h1.symm.trans hg)
    · rcases h2 with h2 | h2
      · rw [hn] at h2
        cases h2
      · exact Bool.false_ne_true (h2.symm.trans hg)

/-- `L` holds the initial state, and every state of `L` passes `closed`. -/
def covers (L : List CState) (n1 n2 : Bool) : Bool :=
  L.contains (cinit sys) && L.all (closed sys L n1 n2)

/-- What `covers` establishes. -/
structure Covers (L : List CState) (n1 n2 : Bool) : Prop where
  init : cinit sys ∈ L
  closed : ∀ c ∈ L, closed sys L n1 n2 c = true

theorem covers_spec {L : List CState} {n1 n2 : Bool} (h : covers sys L n1 n2 = true) :
    Covers sys L n1 n2 := by
  simp only [covers, Bool.and_eq_true, List.contains_iff_mem, List.all_eq_true] at h
  exact ⟨h.1, h.2⟩

variable {sys}

/-- Every reachable state is in `L`. -/
theorem Covers.reachable {L : List CState} {n1 n2 : Bool} (h : Covers sys L n1 n2)
    (hf : sys.f = 1) {s : State Mon Wk} (hs : Reachable sys s) :
    ∃ c ∈ L, s = c.toState := by
  induction hs with
  | init => exact ⟨_, h.init, cinit_spec sys⟩
  | round _ hnr hround ih =>
    obtain ⟨c, hc, rfl⟩ := ih
    exact (closed_spec sys hf (h.closed c hc) hnr hround).1

theorem Covers.noG1 {L : List CState} {n2 : Bool} (h : Covers sys L true n2)
    (hf : sys.f = 1) : ¬ ViolatesG1 sys := by
  rintro ⟨s, r, hs, hnr, hround, hg⟩
  obtain ⟨c, hc, rfl⟩ := h.reachable hf hs
  exact (closed_spec sys hf (h.closed c hc) hnr hround).2.1 rfl hg

theorem Covers.noG2 {L : List CState} {n1 : Bool} (h : Covers sys L n1 true)
    (hf : sys.f = 1) : ¬ ViolatesG2 sys := by
  rintro ⟨s, r, hs, hnr, hround, hg⟩
  obtain ⟨c, hc, rfl⟩ := h.reachable hf hs
  exact (closed_spec sys hf (h.closed c hc) hnr hround).2.2 rfl hg

theorem Covers.noGap {L : List CState} (h : Covers sys L true true) (hf : sys.f = 1) :
    NoGap sys := by
  intro s r hs hnr hround
  obtain ⟨c, hc, rfl⟩ := h.reachable hf hs
  have h' := closed_spec sys hf (h.closed c hc) hnr hround
  exact ⟨h'.2.1 rfl, h'.2.2 rfl⟩

variable (sys)

/-! ### A goal that can be violated -/

/-- One round from `c`, in which the environment takes the step `e`, or no step. The
result is `none` if this is not a round of an execution: `c` is responded, or `e` is not
enabled. -/
def cround (c : CState) (e : Option (EnvStep Mon Wk Bd Sub)) : Option COut :=
  if Responded sys c.toState then none
  else
    match e with
    | none => some (cafter sys c)
    | some e =>
      if Enabled sys c.toState e then (ceffect sys c e).force fun c₁ => some (cafter sys c₁)
      else none

theorem cround_spec (hf : sys.f = 1) {c : CState} {e : Option (EnvStep Mon Wk Bd Sub)}
    {o : COut} (h : cround sys c e = some o) :
    ¬ Responded sys c.toState ∧ Round sys c.toState o.toOutcome := by
  unfold cround at h
  by_cases hr : Responded sys c.toState
  · simp [hr] at h
  · refine ⟨hr, (round_iff sys hf _ _).2 ?_⟩
    cases e with
    | none =>
      simp only [hr, ite_false, Option.some.injEq] at h
      exact .inl (by rw [← h, cafter_spec])
    | some e =>
      by_cases he : Enabled sys c.toState e
      · simp only [hr, he, ite_false, ite_true, CState.force_eq, Option.some.injEq] at h
        exact .inr ⟨e, he, by rw [← h, ceffect_spec, cafter_spec]⟩
      · simp [hr, he] at h

/-- The rounds of the schedule `sched` from `c`: the environment's step in each round, or
none. The result is the outcome of each round, or `none` if `sched` is not an execution
from `c`. -/
def ctrace : CState → List (Option (EnvStep Mon Wk Bd Sub)) → Option (List COut)
  | _, [] => some []
  | c, e :: rest =>
    match cround sys c e with
    | none => none
    | some o => o.next.force fun n => (ctrace n rest).map (o :: ·)

theorem ctrace_spec (hf : sys.f = 1) (sched : List (Option (EnvStep Mon Wk Bd Sub))) :
    ∀ (c : CState) (os : List COut),
      Reachable sys c.toState → ctrace sys c sched = some os →
      ∀ o ∈ os, ∃ s, Reachable sys s ∧ ¬ Responded sys s ∧ Round sys s o.toOutcome := by
  induction sched with
  | nil =>
    intro c os _ h o ho
    simp only [ctrace, Option.some.injEq] at h
    rw [← h] at ho
    cases ho
  | cons e rest ih =>
    intro c os hc h o ho
    unfold ctrace at h
    cases hq : cround sys c e with
    | none => simp [hq] at h
    | some o' =>
      simp only [hq, CState.force_eq, Option.map_eq_some_iff] at h
      obtain ⟨os', h', rfl⟩ := h
      obtain ⟨hnr, hround⟩ := cround_spec sys hf hq
      cases ho with
      | head => exact ⟨_, hc, hnr, hround⟩
      | tail _ ho' => exact ih o'.next os' (Reachable.round hc hnr hround) h' o ho'

/-- Whether G1 is violated in the last of the rounds. -/
def lastG1 : List COut → Bool
  | [] => false
  | [o] => o.g1
  | _ :: o :: os => lastG1 (o :: os)

/-- Whether G2 is violated in the last of the rounds. -/
def lastG2 : List COut → Bool
  | [] => false
  | [o] => o.g2
  | _ :: o :: os => lastG2 (o :: os)

theorem lastG1_spec : ∀ {os : List COut}, lastG1 os = true → ∃ o ∈ os, o.g1 = true
  | [], h => by simp [lastG1] at h
  | [o], h => ⟨o, List.mem_cons_self, h⟩
  | _ :: o :: os, h =>
    have ⟨o', ho', hg⟩ := lastG1_spec (os := o :: os) h
    ⟨o', List.mem_cons_of_mem _ ho', hg⟩

theorem lastG2_spec : ∀ {os : List COut}, lastG2 os = true → ∃ o ∈ os, o.g2 = true
  | [], h => by simp [lastG2] at h
  | [o], h => ⟨o, List.mem_cons_self, h⟩
  | _ :: o :: os, h =>
    have ⟨o', ho', hg⟩ := lastG2_spec (os := o :: os) h
    ⟨o', List.mem_cons_of_mem _ ho', hg⟩

variable {sys}

/-- An execution from the initial state whose last round violates G1. -/
theorem violatesG1_of_trace (hf : sys.f = 1) {sched : List (Option (EnvStep Mon Wk Bd Sub))}
    {os : List COut} (h : ctrace sys (cinit sys) sched = some os) (hg : lastG1 os = true) :
    ViolatesG1 sys := by
  obtain ⟨o, ho, hg⟩ := lastG1_spec hg
  have hinit : Reachable sys (cinit sys).toState := by
    rw [← cinit_spec]
    exact Reachable.init
  obtain ⟨s, hs, hnr, hround⟩ := ctrace_spec sys hf sched _ os hinit h o ho
  exact ⟨s, _, hs, hnr, hround, hg⟩

/-- An execution from the initial state whose last round violates G2. -/
theorem violatesG2_of_trace (hf : sys.f = 1) {sched : List (Option (EnvStep Mon Wk Bd Sub))}
    {os : List COut} (h : ctrace sys (cinit sys) sched = some os) (hg : lastG2 os = true) :
    ViolatesG2 sys := by
  obtain ⟨o, ho, hg⟩ := lastG2_spec hg
  have hinit : Reachable sys (cinit sys).toState := by
    rw [← cinit_spec]
    exact Reachable.init
  obtain ⟨s, hs, hnr, hround⟩ := ctrace_spec sys hf sched _ os hinit h o ho
  exact ⟨s, _, hs, hnr, hround, hg⟩

variable (sys)

/-! ### The states of a list are reached, and how many they are -/

/-- Each state of the second list, in turn, is the next state of a round that starts from
a state before it. The third list gives that round for each: the position of the state it
starts from, counted from 0 at the head of the whole list, and the environment's step.
`done` holds the states before, the latest first. -/
def grows (done : List CState) :
    List CState → List (Nat × Option (EnvStep Mon Wk Bd Sub)) → Bool
  | [], [] => true
  | c :: cs, (i, e) :: ps =>
    (decide (i < done.length) &&
      match done[done.length - 1 - i]? with
      | none => false
      | some p =>
        match cround sys p e with
        | none => false
        | some o => o.next.force fun n => n == c) && grows (c :: done) cs ps
  | _, _ => false

theorem grows_spec (hf : sys.f = 1) :
    ∀ (cs : List CState) (ps : List (Nat × Option (EnvStep Mon Wk Bd Sub)))
      (done : List CState),
      (∀ c ∈ done, Reachable sys c.toState) → grows sys done cs ps = true →
      ∀ c ∈ cs, Reachable sys c.toState := by
  intro cs
  induction cs with
  | nil =>
    intro _ _ _ _ c hc
    cases hc
  | cons c cs ih =>
    intro ps done hdone h
    cases ps with
    | nil => simp [grows] at h
    | cons ie ps =>
      obtain ⟨i, e⟩ := ie
      simp only [grows, Bool.and_eq_true] at h
      obtain ⟨⟨_, h1⟩, h2⟩ := h
      have hc : Reachable sys c.toState := by
        cases hd : done[done.length - 1 - i]? with
        | none => simp [hd] at h1
        | some p =>
          cases hq : cround sys p e with
          | none => simp [hd, hq] at h1
          | some o =>
            simp only [hd, hq, CState.force_eq, beq_iff_eq] at h1
            obtain ⟨hnr, hround⟩ := cround_spec sys hf hq
            rw [← h1]
            exact Reachable.round (hdone p (List.mem_of_getElem? hd)) hnr hround
      have hdone' : ∀ c' ∈ c :: done, Reachable sys c'.toState := by
        intro c' hc'
        cases hc' with
        | head => exact hc
        | tail _ h' => exact hdone c' h'
      intro c' hc'
      cases hc' with
      | head => exact hc
      | tail _ h' => exact ih ps (c :: done) hdone' h2 c' h'

/-- The first state of `L` is the initial state, and each later one is the next state of
the round given for it in `ps`, which starts from a state before it. -/
def reaches (L : List CState) (ps : List (Nat × Option (EnvStep Mon Wk Bd Sub))) : Bool :=
  match L with
  | [] => false
  | c :: cs => c == cinit sys && grows sys [c] cs ps

/-- Every state of `L` is reachable. -/
theorem reaches_spec (hf : sys.f = 1) {L : List CState}
    {ps : List (Nat × Option (EnvStep Mon Wk Bd Sub))} (h : reaches sys L ps = true) :
    ∀ c ∈ L, Reachable sys c.toState := by
  cases L with
  | nil => simp [reaches] at h
  | cons c cs =>
    simp only [reaches, Bool.and_eq_true, beq_iff_eq] at h
    obtain ⟨h0, h1⟩ := h
    have hc : Reachable sys c.toState := by
      rw [h0, ← cinit_spec]
      exact Reachable.init
    have hdone : ∀ c' ∈ [c], Reachable sys c'.toState := by
      intro c' hc'
      cases hc' with
      | head => exact hc
      | tail _ h' => cases h'
    intro c' hc'
    cases hc' with
    | head => exact hc
    | tail _ h' => exact grows_spec sys hf cs ps [c] hdone h1 c' h'

/-- The reachable states are the states of `L`, when `L` passes `covers` and `reaches`. -/
theorem reachable_iff (hf : sys.f = 1) {L : List CState} {n1 n2 : Bool}
    {ps : List (Nat × Option (EnvStep Mon Wk Bd Sub))} (hc : covers sys L n1 n2 = true)
    (hr : reaches sys L ps = true) (s : State Mon Wk) :
    Reachable sys s ↔ ∃ c ∈ L, s = c.toState := by
  constructor
  · exact (covers_spec sys hc).reachable hf
  · rintro ⟨c, hc', rfl⟩
    exact reaches_spec sys hf hr c hc'

/-- The rounds from the states of `L` that are not responded: for each such state, one
round with no step and one for each enabled step. -/
def countRounds (L : List CState) : Nat :=
  L.foldl
    (fun n c =>
      if Responded sys c.toState then n
      else n + 1 + (allSteps.filter fun e => decide (Enabled sys c.toState e)).length)
    0

end

/-- No two states of the list are the same. -/
def distinct : List CState → Bool
  | [] => true
  | c :: cs => !cs.contains c && distinct cs

theorem distinct_spec : ∀ {L : List CState}, distinct L = true → L.Nodup
  | [], _ => List.nodup_nil
  | c :: cs, h => by
    simp only [distinct, Bool.and_eq_true, Bool.not_eq_true'] at h
    refine List.nodup_cons.2 ⟨fun hmem => ?_, distinct_spec h.2⟩
    rw [List.contains_iff_mem.2 hmem] at h
    exact Bool.false_ne_true h.1.symm

/-- The number of reachable states, when `L` passes `covers`, `reaches` and `distinct`. -/
theorem reachable_count {sys : System Mon Wk Bd Sub} [DecSys sys] (hf : sys.f = 1)
    {L : List CState} {n1 n2 : Bool} {ps : List (Nat × Option (EnvStep Mon Wk Bd Sub))}
    (hc : covers sys L n1 n2 = true) (hr : reaches sys L ps = true)
    (hd : distinct L = true) : ReachableCount sys L.length := by
  refine ⟨L.map CState.toState, List.length_map _, ?_, fun s => ?_⟩
  · exact List.pairwise_map.2
      ((distinct_spec hd).imp fun hne e => hne (CState.toState_injective e))
  · rw [reachable_iff sys hf hc hr s, List.mem_map]
    constructor
    · rintro ⟨c, hc', rfl⟩
      exact ⟨c, hc', rfl⟩
    · rintro ⟨c, hc', rfl⟩
      exact ⟨c, hc', rfl⟩

end Finite
end SelfObserving
