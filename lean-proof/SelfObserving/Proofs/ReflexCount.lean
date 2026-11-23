/-
The count of the reflex (`results.md`, section 8.1): proofs of `slow_report_count` and
`slow_report_execution` of `Challenge.lean`.

The execution is the one of `Reflex.lean`: the environment mutates the work process `w`
in round 1 and takes no step afterwards. With the gate, slow reports and no window, the
state `soloEnv sys w j` is described exactly by the invariant `Inv` below, by induction on
`j`.
-/
import SelfObserving.Reflex

namespace SelfObserving.ReflexCount

variable {M W B S : Type}

/-! ### The two switches of the round -/

/-- With the gate, the state a round ends in is the work phase of the monitor phase. -/
theorem afterEnv_next_gate {sys : System M W B S} (hg : sys.gate = true) (s₁ : State M W) :
    (afterEnv sys s₁).next =
      workPhase sys (monitorPhase sys s₁) (Out (monitorPhase sys s₁)) := by
  unfold afterEnv
  split
  · rfl
  · exact absurd hg ‹_›

/-- With slow reports, the monitor phase adds the detectors and one hop from the monitors
that were flagged before. -/
theorem flaggedAfter_slow {sys : System M W B S} (hslow : sys.slowReports = true)
    (s : State M W) (r : M) :
    flaggedAfter sys s r ↔
      (FlaggedOrDetects sys s r ∨
        ∃ m, s.flagged m ∧ Active s m ∧ sys.fwd m r ∧ Active s r) := by
  unfold flaggedAfter
  split
  · exact Iff.rfl
  · exact absurd hslow ‹_›

/-! ### Report hops -/

theorem hops_zero {sys : System M W B S} {k h : M} (hh : Hops sys 0 k h) : k = h := by
  cases hh
  rfl

theorem hops_succ {sys : System M W B S} {n : Nat} {k h : M} (hh : Hops sys (n + 1) k h) :
    ∃ y, Hops sys n k y ∧ sys.fwd y h := by
  cases hh with
  | succ h₁ h₂ => exact ⟨_, h₁, h₂⟩

/-! ### The state reached by the environment phase of round `j + 1` -/

/-- What `soloEnv sys w j` looks like. Every monitor is alive, `w` is the only bad
process, nothing is hidden, switched off or pending. The flagged monitors are those that a
state checker of `w` reaches in at most `j - 1` report hops (none when `j = 0`), and `w` is
halted exactly when one of those is a halt input of `w`. Nothing is said about the other
non-monitor processes. -/
structure Inv (sys : System M W B S) (w : W) (j : Nat) (s : State M W) : Prop where
  alive : ∀ m : M, s.alive (.inl m)
  bad : ∀ q, s.bad q ↔ q = .inr w
  hidden : ∀ q, ¬ s.hidden q
  off : ∀ m, ¬ s.off m
  pending : ∀ x, ¬ s.pending x
  flagged : ∀ m, s.flagged m ↔
    ∃ n k, n + 1 ≤ j ∧ sys.checkers (.inr w) k ∧ Hops sys n k m
  halted : s.halted w ↔
    ∃ n k h, n + 1 ≤ j ∧ sys.checkers (.inr w) k ∧ sys.haltInputs w h ∧ Hops sys n k h

/-- Every monitor is active. -/
theorem Inv.active {sys : System M W B S} {w : W} {j : Nat} {s : State M W}
    (hi : Inv sys w j s) (m : M) : Active s m :=
  ⟨hi.alive m, fun hb => (by cases (hi.bad (.inl m)).1 hb), hi.off m⟩

/-- A monitor detects exactly when it checks `w`. -/
theorem Inv.detects {sys : System M W B S} {w : W} {j : Nat} {s : State M W}
    (hi : Inv sys w j s) (m : M) : Detects sys s m ↔ sys.checkers (.inr w) m := by
  constructor
  · rintro ⟨_, ⟨x, hx, hc⟩ | ⟨p, hp, _⟩⟩
    · have hxw := (hi.bad x).1 hx.1
      subst hxw
      exact hc
    · exact absurd (hi.alive p) hp
  · intro hc
    exact ⟨hi.active m, Or.inl ⟨.inr w, ⟨(hi.bad _).2 rfl, hi.hidden _⟩, hc⟩⟩

/-- After the monitor phase of round `j + 1`, the flagged monitors are those within `j`
report hops of a state checker of `w`. -/
theorem Inv.flaggedAfter {sys : System M W B S} (hslow : sys.slowReports = true) {w : W}
    {j : Nat} {s : State M W} (hi : Inv sys w j s) (m : M) :
    flaggedAfter sys s m ↔ ∃ n k, n ≤ j ∧ sys.checkers (.inr w) k ∧ Hops sys n k m := by
  rw [flaggedAfter_slow hslow]
  constructor
  · rintro ((hf | hd) | ⟨m', hf, _, hfw, _⟩)
    · obtain ⟨n, k, hn, hk, hh⟩ := (hi.flagged m).1 hf
      exact ⟨n, k, Nat.le_of_succ_le hn, hk, hh⟩
    · exact ⟨0, m, Nat.zero_le _, (hi.detects m).1 hd, Hops.zero m⟩
    · obtain ⟨n, k, hn, hk, hh⟩ := (hi.flagged m').1 hf
      exact ⟨n + 1, k, hn, hk, Hops.succ hh hfw⟩
  · rintro ⟨n, k, hn, hk, hh⟩
    cases n with
    | zero =>
      have hkm := hops_zero hh
      subst hkm
      exact Or.inl (Or.inr ((hi.detects k).2 hk))
    | succ n =>
      obtain ⟨y, hy, hfw⟩ := hops_succ hh
      exact Or.inr ⟨y, (hi.flagged y).2 ⟨n, k, hn, hk, hy⟩, hi.active y, hfw, hi.active m⟩

/-- In round `j + 1`, `w` sees a reason to halt exactly when one of its halt inputs is
within `j` report hops of one of its state checkers. -/
theorem Inv.sees {sys : System M W B S} (hslow : sys.slowReports = true) {w : W}
    {j : Nat} {s : State M W} (hi : Inv sys w j s) :
    Sees sys (monitorPhase sys s) (Out (monitorPhase sys s)) w ↔
      ∃ n k h, n ≤ j ∧ sys.checkers (.inr w) k ∧ sys.haltInputs w h ∧ Hops sys n k h := by
  constructor
  · rintro (⟨h, hh, ho⟩ | ⟨_, h, _, hna⟩)
    · obtain ⟨n, k, hn, hk, hp⟩ := (hi.flaggedAfter hslow h).1 ho.1
      exact ⟨n, k, h, hn, hk, hh, hp⟩
    · exact absurd (hi.alive h) hna
  · rintro ⟨n, k, h, hn, hk, hh, hp⟩
    exact Or.inl ⟨h, hh, (hi.flaggedAfter hslow h).2 ⟨n, k, hn, hk, hp⟩, hi.alive h,
      (hi.active h).2.1⟩

/-- In round `j + 1`, `w` takes a work step exactly when no halt input of `w` is within
`j` report hops of a state checker of `w`. -/
theorem Inv.worked {sys : System M W B S} (hslow : sys.slowReports = true)
    (hwin : sys.window = 0) {w : W} (hw : ¬ sys.IsJoiner w) {j : Nat} {s : State M W}
    (hi : Inv sys w j s) :
    Worked sys (monitorPhase sys s) (Out (monitorPhase sys s)) w ↔
      ∀ n k h, n ≤ j → sys.checkers (.inr w) k → sys.haltInputs w h → ¬ Hops sys n k h := by
  constructor
  · rintro ⟨_, _, hns⟩ n k h hn hk hh hp
    exact hns ⟨(hi.sees hslow).2 ⟨n, k, h, hn, hk, hh, hp⟩, hwin⟩
  · intro hall
    refine ⟨⟨fun hjn => absurd hjn hw, fun hh => ?_⟩, hi.pending w, fun hs => ?_⟩
    · obtain ⟨n, k, h, hn, hk, hh', hp⟩ := hi.halted.1 hh
      exact hall n k h (Nat.le_of_succ_le hn) hk hh' hp
    · obtain ⟨n, k, h, hn, hk, hh', hp⟩ := (hi.sees hslow).1 hs.1
      exact hall n k h hn hk hh' hp

/-- The invariant passes from the environment phase of one round to that of the next,
the environment taking no step in between. -/
theorem Inv.step {sys : System M W B S} (hslow : sys.slowReports = true)
    (hwin : sys.window = 0) {w : W} (hw : ¬ sys.IsJoiner w) {j : Nat} {s : State M W}
    (hi : Inv sys w j s) :
    Inv sys w (j + 1) (workPhase sys (monitorPhase sys s) (Out (monitorPhase sys s))) where
  alive := hi.alive
  bad := hi.bad
  hidden := hi.hidden
  off := hi.off
  pending := by
    rintro x (⟨hp, _⟩ | ⟨_, _, _, hne⟩)
    · exact hi.pending x hp
    · exact hne hwin
  flagged := by
    intro m
    constructor
    · intro hf
      obtain ⟨n, k, hn, hk, hh⟩ := (hi.flaggedAfter hslow m).1 hf
      exact ⟨n, k, Nat.succ_le_succ hn, hk, hh⟩
    · rintro ⟨n, k, hn, hk, hh⟩
      exact (hi.flaggedAfter hslow m).2 ⟨n, k, Nat.le_of_succ_le_succ hn, hk, hh⟩
  halted := by
    constructor
    · rintro (hh | ⟨_, hp | ⟨hs, _⟩⟩)
      · obtain ⟨n, k, h, hn, hk, hh', hp⟩ := hi.halted.1 hh
        exact ⟨n, k, h, Nat.le_succ_of_le hn, hk, hh', hp⟩
      · exact absurd hp (hi.pending w)
      · obtain ⟨n, k, h, hn, hk, hh', hp⟩ := (hi.sees hslow).1 hs
        exact ⟨n, k, h, Nat.succ_le_succ hn, hk, hh', hp⟩
    · rintro ⟨n, k, h, hn, hk, hh', hp⟩
      by_cases hh : s.halted w
      · exact Or.inl hh
      · exact Or.inr ⟨⟨fun hjn => absurd hjn hw, hh⟩, Or.inr
          ⟨(hi.sees hslow).2 ⟨n, k, h, Nat.le_of_succ_le_succ hn, hk, hh', hp⟩, hwin⟩⟩

/-- The invariant holds after the one environment step of round 1. -/
theorem inv_zero (sys : System M W B S) (w : W) :
    Inv sys w 0 (effect sys (init sys) (.mutate (.inr w))) where
  alive := fun _ => trivial
  bad := fun _ => ⟨fun h => h.elim id False.elim, Or.inl⟩
  hidden := fun _ h => h
  off := fun _ h => h
  pending := fun _ h => h
  flagged := fun _ => ⟨False.elim, fun ⟨n, _, hn, _⟩ => absurd hn (Nat.not_succ_le_zero n)⟩
  halted := ⟨False.elim, fun ⟨n, _, _, hn, _⟩ => absurd hn (Nat.not_succ_le_zero n)⟩

/-- The invariant holds in every round of the execution. -/
theorem inv_solo {sys : System M W B S} (hslow : sys.slowReports = true)
    (hwin : sys.window = 0) (hgate : sys.gate = true) {w : W} (hw : ¬ sys.IsJoiner w) :
    ∀ j, Inv sys w j (soloEnv sys w j)
  | 0 => inv_zero sys w
  | j + 1 => by
    show Inv sys w (j + 1) (afterEnv sys (soloEnv sys w j)).next
    rw [afterEnv_next_gate hgate]
    exact (inv_solo hslow hwin hgate hw j).step hslow hwin hw

/-! ### The two statements -/

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
      ∀ n k h, n ≤ j → sys.checkers (.inr w) k → sys.haltInputs w h → ¬ Hops sys n k h := by
  have hi := inv_solo hslow hwin hgate hw j
  constructor
  · intro h
    exact (hi.worked hslow hwin hw).1 h.2
  · intro h
    exact ⟨(hi.bad _).2 rfl, (hi.worked hslow hwin hw).2 h⟩

/-- A remark that joins the two statements (not in `Challenge.lean`): if `w` takes a work
step while bad in round `j + 1`, it does so in every earlier round too. So the hypothesis
`hj` of `slow_report_execution` holds up to any round that `slow_report_count` counts. -/
theorem soloWorks_of_le (sys : System M W B S) (hslow : sys.slowReports = true)
    (hwin : sys.window = 0) (hgate : sys.gate = true) (w : W) (hw : ¬ sys.IsJoiner w)
    {i j : Nat} (hij : i ≤ j) (h : SoloWorks sys w j) : SoloWorks sys w i :=
  (slow_report_count sys hslow hwin hgate w hw i).2 (fun n k x hn =>
    (slow_report_count sys hslow hwin hgate w hw j).1 h n k x (Nat.le_trans hn hij))

/-- `slow_report_execution` without its hypotheses on the report speed and the window,
which its proof does not need (not in `Challenge.lean`). A process that took a work step
in a round is not halted after it, whatever the window and the report speed, so the state
after that round is not responded. -/
theorem solo_execution (sys : System M W B S) (hf : 1 ≤ sys.f) (hgate : sys.gate = true)
    (w : W) (hw : ¬ sys.IsJoiner w) (j : Nat) (hj : ∀ i, i < j → SoloWorks sys w i) :
    Reachable sys (soloStart sys w j) ∧ ¬ Responded sys (soloStart sys w j) ∧
      Round sys (soloStart sys w j) (afterEnv sys (soloEnv sys w j)) := by
  induction j with
  | zero =>
    refine ⟨Reachable.init, ?_, ?_⟩
    · rintro ⟨⟨m, hm, _⟩, _⟩
      exact hm
    · exact ⟨[.mutate (.inr w)], _, hf,
        EnvRun.cons ⟨fun hjn => absurd hjn hw, fun h => h⟩ (EnvRun.nil _), rfl⟩
  | succ j ih =>
    obtain ⟨hr, hnr, hround⟩ := ih (fun i hi => hj i (Nat.lt_succ_of_lt hi))
    refine ⟨Reachable.round hr hnr hround, ?_, ⟨[], _, Nat.zero_le _, EnvRun.nil _, rfl⟩⟩
    intro hresp
    have hworks := (hj j (Nat.lt_succ_self j)).2
    have hhalt : (afterEnv sys (soloEnv sys w j)).next.halted w :=
      hresp.2 w (fun hjn => absurd hjn hw)
    rw [afterEnv_next_gate hgate] at hhalt
    rcases hhalt with hh | ⟨_, hp | hs⟩
    · exact hworks.1.2 hh
    · exact hworks.2.1 hp
    · exact hworks.2.2 hs

/-- The rounds counted in `slow_report_count` are rounds of an execution. If `w` took a
work step in each of the first `j` rounds, then round `j + 1` is a round of the model
from a state that an execution reaches and that is not responded: the state it starts
from is `soloStart sys w j`, and its outcome is that of `soloEnv sys w j`. -/
theorem slow_report_execution (sys : System M W B S) (hf : 1 ≤ sys.f)
    (hslow : sys.slowReports = true) (hwin : sys.window = 0) (hgate : sys.gate = true)
    (w : W) (hw : ¬ sys.IsJoiner w) (j : Nat) (hj : ∀ i, i < j → SoloWorks sys w i) :
    Reachable sys (soloStart sys w j) ∧ ¬ Responded sys (soloStart sys w j) ∧
      Round sys (soloStart sys w j) (afterEnv sys (soloEnv sys w j)) := by
  have _ := hslow
  have _ := hwin
  exact solo_execution sys hf hgate w hw j hj

end SelfObserving.ReflexCount
