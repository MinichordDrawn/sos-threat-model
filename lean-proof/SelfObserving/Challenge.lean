/-
The statements to be proved, with their proofs left out. This file, `Model.lean`,
`Conditions.lean`, `Systems.lean` and `Reference.lean` are what a reader has to check
against `model-spec.md` and `results.md`.

The statements after the first twenty-six also use the definitions of `Restart.lean`,
`Wide.lean`, `Growth.lean`, `Naming.lean`, `Reflex.lean`, `MeshAt.lean` and `Nested.lean`,
which a reader has to check in the same way. `Wide.lean` is not transcribed from a passage
of `results.md`, and its heading says what it is written from.

The statements after the first sixty-two also use the definitions of `AnyRate.lean`,
`Rings.lean` and `Tower.lean`, which a reader has to check against `results-join.md`,
`part-a.md` and `results-minimal.md`.

The statements about monitors that join use `Join.lean`, a second model beside
`Model.lean`, which a reader has to check against `model-spec-join.md`, and
`JoinConditions.lean` and `JoinExamples.lean`, to be checked against `results-join.md`.
The last two statements use `MoreEdges.lean`, to be checked against Lemma M there.
-/
import SelfObserving.Systems
import SelfObserving.Reference
import SelfObserving.Restart
import SelfObserving.Wide
import SelfObserving.Growth
import SelfObserving.Naming
import SelfObserving.Reflex
import SelfObserving.MeshAt
import SelfObserving.Nested
import SelfObserving.AnyRate
import SelfObserving.Rings
import SelfObserving.Tower
import SelfObserving.Join
import SelfObserving.JoinConditions
import SelfObserving.JoinExamples
import SelfObserving.MoreEdges

namespace SelfObserving

variable {M W B S : Type}

/-! ### The general result -/

/-- Theorem S. A plain system that meets the four conditions has no gap at one fault per
round: no execution of any length violates G1 or G2 in any round. The numbers of monitors
and of work processes are arbitrary, and need not be finite. -/
theorem theorem_S (sys : System M W B S) (hf : sys.f = 1) (hp : Plain sys)
    (hs : Sufficient sys) : NoGap sys := by
  sorry

/-- The conditions of Theorem S can be met: a full mesh of at least two monitors, with any
work processes, has no gap. -/
theorem mesh_noGap {m₀ m₁ : M} (h : m₀ ≠ m₁) : NoGap (mesh M W) := by
  sorry

/-- "No gap" can fail: a work process that nothing watches has a gap. -/
theorem unwatched_gap : ¬ NoGap unwatched := by
  sorry

/-! ### The reference system and the ten removals

Between them, the reference system and its removals use all six kinds of step. In the
reference system itself four can occur: with no off switch and no shared boundary, the
other two cannot. `reference_noGap` is the result of section 5 of `results.md`. Each
statement about a removal says which of the two goals some execution violates, and which
none does. That is the column "Judgement broken" of the table in section 7, as to which
goals, and not as to the round. -/

/-- The reference system, with every feature, has no gap. -/
theorem reference_noGap : NoGap reference := by
  sorry

/-- Without P1, the liveness signal, both goals can be violated. -/
theorem withoutP1_gap : ViolatesG1 withoutP1 ∧ ViolatesG2 withoutP1 := by
  sorry

/-- Without P2, shared substrate, both goals can be violated. -/
theorem withoutP2_gap : ViolatesG1 withoutP2 ∧ ViolatesG2 withoutP2 := by
  sorry

/-- Without P3, the state check, both goals can be violated. -/
theorem withoutP3_gap : ViolatesG1 withoutP3 ∧ ViolatesG2 withoutP3 := by
  sorry

/-- Without P4, propagation, G2 can be violated and G1 cannot: the fault is flagged, and
work goes on. -/
theorem withoutP4_gap : ¬ ViolatesG1 withoutP4 ∧ ViolatesG2 withoutP4 := by
  sorry

/-- Without P5, no single-step removal, both goals can be violated. -/
theorem withoutP5_gap : ViolatesG1 withoutP5 ∧ ViolatesG2 withoutP5 := by
  sorry

/-- Without P6, the out-of-boundary signal, G1 can be violated and G2 cannot: the work
stops, and nothing is left to know why. -/
theorem withoutP6_gap : ViolatesG1 withoutP6 ∧ ¬ ViolatesG2 withoutP6 := by
  sorry

/-- Without P7, automatic enrolment, both goals can be violated. -/
theorem withoutP7_gap : ViolatesG1 withoutP7 ∧ ViolatesG2 withoutP7 := by
  sorry

/-- Without P8, immediate response, G2 can be violated and G1 cannot: every monitor has
flagged, and the work takes one more step. -/
theorem withoutP8_gap : ¬ ViolatesG1 withoutP8 ∧ ViolatesG2 withoutP8 := by
  sorry

/-- Without the halt fan-out, both goals can be violated. -/
theorem withoutP8b_gap : ViolatesG1 withoutP8b ∧ ViolatesG2 withoutP8b := by
  sorry

/-- Without the gate, both goals can be violated. -/
theorem withoutGate_gap : ViolatesG1 withoutGate ∧ ViolatesG2 withoutGate := by
  sorry

/-! ### What any system needs

The removals above are about one system. The statements below are about every system: each
but the first says that a system which lacks something has a gap, whatever else it has.
They are results marked "proved" in sections 2.7, 6, 8.1 and 10.2 of `results.md`, and one
that section 12.1 cites as proved elsewhere and section 6 checks on R
(`unchecked_work_gap`). Three are stated more widely than in `results.md`, which restricts
them to systems with no substrates or switches: `unchecked_set_gap`,
`unchecked_monitor_gap` and `few_halt_inputs_gap`. Two further results of those sections
come later in this file: that a mesh of `n` monitors has no gap when `f ≤ n - 1`
(section 10.2; `mesh_holds`), and the count of work steps in section 8.1
(`slow_report_count`), of which `slow_report_gap` is the case "at least one". A set of
monitors is given as a list without repeats. -/

/-- Theorem 0, part 3. A flag starts only at a detection: from a state with no flag, if no
monitor detects, the monitor phase raises no flag. -/
theorem flag_needs_detection (sys : System M W B S) (s : State M W)
    (hflag : ∀ m, ¬ s.flagged m) (hdet : ∀ m, ¬ Detects sys s m) :
    ∀ m, ¬ flaggedAfter sys s m := by
  sorry

/-- The rate form of P5 (section 6). If some non-empty set of at most `f` monitors is
checked by no monitor outside the set, G1 can be violated: the environment mutates the whole
set in one round, and nothing flags. -/
theorem unchecked_set_gap (sys : System M W B S) (zs : List M) (hne : zs ≠ [])
    (hnd : zs.Nodup) (hlen : zs.length ≤ sys.f)
    (hin : ∀ z, z ∈ zs → ∀ r, sys.checkers (.inl z) r → r ∈ zs) : ViolatesG1 sys := by
  sorry

/-- Theorem 0, part 1. If there is at least one monitor and `f` is at least the number of
monitors, G1 can be violated. `ms` lists every monitor once. -/
theorem rate_bound (sys : System M W B S) (ms : List M) (hne : ms ≠ []) (hnd : ms.Nodup)
    (hall : ∀ m, m ∈ ms) (hlen : ms.length ≤ sys.f) : ViolatesG1 sys := by
  sorry

/-- P3 for monitors (section 6). A monitor with no state checker other than itself can be
mutated, leaving a bad state and no flag. -/
theorem unchecked_monitor_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (z : M)
    (hz : ∀ r, sys.checkers (.inl z) r → r = z) : ViolatesG1 sys := by
  sorry

/-- P3 for work, and the state-check half of P7. `results.md` checks both on R (section 6)
and cites a proof of the first elsewhere (section 12.1). A non-monitor process that no
monitor checks can be mutated once it is present, leaving a bad state and no flag. This
holds whether the process is present from the start or joins later. -/
theorem unchecked_work_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (w : W)
    (hw : ∀ m, ¬ sys.checkers (.inr w) m) : ViolatesG1 sys := by
  sorry

/-- Theorem 0, part 2, which is also the general form of the P6 removal (section 7). If
every monitor sits in one boundary, and there are at least two monitors, G1 can be
violated: the boundary is stopped, then in the next round a process is mutated. -/
theorem one_boundary_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (b : B) {m₀ m₁ : M}
    (hne : m₀ ≠ m₁) (hb : ∀ m, sys.boundary m = some b) : ViolatesG1 sys := by
  sorry

/-- P8 in general (section 6). In a system with a window and a work process present from
the start, G2 can be violated: the environment mutates a work process, and none may halt
before the window has passed. -/
theorem window_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (hwin : sys.window ≠ 0) (w : W)
    (hw : ¬ sys.IsJoiner w) : ViolatesG2 sys := by
  sorry

/-- P8b in general (section 6). A work process with at most `f` halt inputs keeps working
after the environment mutates all of them, so G2 can be violated. `hs` contains every halt
input of `w`, and may contain other monitors. -/
theorem few_halt_inputs_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (w : W)
    (hw : ¬ sys.IsJoiner w) (hs : List M) (hnd : hs.Nodup)
    (hall : ∀ m, sys.haltInputs w m → m ∈ hs) (hlen : hs.length ≤ sys.f) :
    ViolatesG2 sys := by
  sorry

/-- The gate in general (section 6). In a system without the gate and with a work process
present from the start, G2 can be violated: in round 1 no flag exists yet when the work
processes step. -/
theorem noGate_gap (sys : System M W B S) (hf : 1 ≤ sys.f) (hgate : sys.gate = false)
    (w : W) (hw : ¬ sys.IsJoiner w) : ViolatesG2 sys := by
  sorry

/-- The reflex (section 8.1). When reports take a round, a work process none of whose halt
inputs checks its state takes a work step while bad, so G2 can be violated. -/
theorem slow_report_gap (sys : System M W B S) (hf : 1 ≤ sys.f)
    (hslow : sys.slowReports = true) (w : W) (hw : ¬ sys.IsJoiner w)
    (hsep : ∀ m, sys.haltInputs w m → ¬ sys.checkers (.inr w) m) : ViolatesG2 sys := by
  sorry

/-! ### Naming the faulty monitor

Section 10.2 of `results.md`. Each monitor names one monitor as the faulty one. Exactly one
monitor, `z`, is faulty (`results.md` says "at most one"; the case of none is in the
statements under "Whether three monitors are forced", later in this file). Every other
monitor names `z`, and `z` may name anyone. A rule reads the names and says which monitor
is faulty. -/

/-- With two monitors, no rule is always right: "each names the other" arises both when the
first is faulty and when the second is. -/
theorem two_cannot_name :
    ¬ ∃ rule : (Bool → Bool) → Bool,
        ∀ (z : Bool) (names : Bool → Bool),
          (∀ m, m ≠ z → names m = z) → rule names = z := by
  sorry

/-- With three or more monitors, a rule exists that is always right: the faulty monitor is
the one named by two others. -/
theorem three_can_name (a b c : M) (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    ∃ rule : (M → M) → M,
      ∀ (z : M) (names : M → M), (∀ m, m ≠ z → names m = z) → rule names = z := by
  sorry

/-! ### Restarting

Section 10.3 of `results.md`: the restart game of `Restart.lean`. A ring is finite: `xs`
lists every member, and may list one more than once. -/

/-- Theorem R. If no member can start first, so that every member runs only while a
running member observes it, then once every member has stopped, none can ever start:
whatever moves follow, no member is running. -/
theorem theorem_R {X : Type} (g : Ring X) (hno : ∀ x, ¬ g.startsFirst x)
    (s s' : RingState X) (moves : List (RingMove X)) (hstop : ∀ x, ¬ s.running x)
    (hrun : RingRun g s moves s') : ∀ x, ¬ s'.running x := by
  sorry

/-- Recovery needs a member that can start first. A ring with at least one member, none of
which can start first, cannot always restart: a full stop is reachable, and by Theorem R
nothing starts after it. -/
theorem restart_needs_first {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs)
    (x₀ : X) (hno : ∀ x, ¬ g.startsFirst x) : ¬ CanAlwaysRestart g := by
  sorry

/-- Every other member must be reached from the member that can start first. Let `k` be
the one member that can start first. The ring can always restart exactly when `k` reaches
every other member. -/
theorem restart_iff_reaches {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs)
    (k : X) (hk : ∀ x, g.startsFirst x ↔ x = k) :
    CanAlwaysRestart g ↔ ∀ y, y ≠ k → Reaches g k y := by
  sorry

/-- The same for any number of members that can start first, none included. The ring can
always restart exactly when every member that cannot start first is reached from one that
can. `results.md` states this for one such member only. -/
theorem restart_iff_reached {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs) :
    CanAlwaysRestart g ↔ ∀ y, ¬ g.startsFirst y → ∃ k, g.startsFirst k ∧ Reaches g k y := by
  sorry

/-- The table of section 10.3, first row. Three members, each observed by the one before
it, cannot restart after one member is stopped and released: the stop passes round the
ring and all three are stopped. -/
theorem ring3_cannot_restart :
    ¬ CanAlwaysRestart ring3 ∧
    ∃ s, RingRun ring3 ringInit [.stop .X1, .release .X1] s ∧ (∀ x, ¬ s.running x) ∧
      (∀ x, ¬ s.blocked x) ∧ ¬ Recovers ring3 s := by
  sorry

/-- Second row. Three members, each observed by the other two, cannot restart after two
members are stopped and released. -/
theorem mesh3_cannot_restart :
    ¬ CanAlwaysRestart mesh3 ∧
    ∃ s, RingRun mesh3 ringInit [.stop .X1, .release .X1, .stop .X2, .release .X2] s ∧
      (∀ x, ¬ s.blocked x) ∧ ¬ Recovers mesh3 s := by
  sorry

/-- Third row. Three members and a coordinator that observes all three and can start
first can always restart. -/
theorem ringK_can_restart : CanAlwaysRestart (ringK true) := by
  sorry

/-- Fourth row. The same four, when the coordinator cannot start first, cannot restart
after one member and the coordinator are stopped and released. -/
theorem ringK_cannot_restart_without_first :
    ¬ CanAlwaysRestart (ringK false) ∧
    ∃ s, RingRun (ringK false) ringInit [.stop .X1, .release .X1, .stop .K, .release .K] s ∧
      (∀ x, ¬ s.blocked x) ∧ ¬ Recovers (ringK false) s := by
  sorry

/-! ### Systems that are not plain

`results.md` gives no general theorem of no gap for systems that are not plain: Theorem S
is for plain systems, and the reference system is settled by search. The statement below is for
the wider class of `Wide.lean`, and Theorem S and the reference system's result are
special cases of it. -/

/-- A system of the wider class that meets the conditions of `SufficientWide` has no gap
at one fault per round. -/
theorem theorem_S_wide (sys : System M W B S) (hf : sys.f = 1) (ho : Ordinary sys)
    (hs : SufficientWide sys) : NoGap sys := by
  sorry

/-- Theorem S is a special case: a plain system that meets the four conditions is of the
wider class and meets its conditions. -/
theorem plain_is_wide (sys : System M W B S) (hp : Plain sys) (hs : Sufficient sys) :
    Ordinary sys ∧ SufficientWide sys := by
  sorry

/-- The reference system's result is a special case: the reference system is of the wider
class and meets its conditions. -/
theorem reference_is_wide : Ordinary reference ∧ SufficientWide reference := by
  sorry

/-! ### How fast a halt must travel

Section 8.2 of `results.md`: the count of `Growth.lean`. Every statement is for the order
in which the halt reaches good processes first. -/

/-- The window. If everything halts `w` ticks after detection, the damage is `2 ^ w`, or
the whole system if that is smaller. -/
theorem window_damage (n w : Nat) (hn : 1 ≤ n) : windowDamage n w = min (2 ^ w) n := by
  sorry

/-- The count ends, and the damage is one number: for a halt passed to at least one per
hop at one or more hops per tick, some tick leaves no bad process running. -/
theorem cascade_ends (c h n : Nat) (hc : 1 ≤ c) (hh : 1 ≤ h) (hn : 1 ≤ n) :
    ∃ d, CascadeDamage c h n d ∧ ∀ d', CascadeDamage c h n d' → d' = d := by
  sorry

/-- The cascade. A halt passed to `c` per hop has reached at most `1 + c + ... + c ^ j`
processes after `j` hops, the place it starts from counted as the first. After `t` ticks
it has made `h * t` hops, and the processes it has reached are those no longer running. -/
theorem cascade_reach (c h n t : Nat) (hn : 1 ≤ n) :
    n + 1 ≤ (cascade c h n t).good + (cascade c h n t).bad + geom c (h * t) := by
  sorry

/-- With `c` = 1 the bound is `j + 1`: a chain grows by one per hop. -/
theorem geom_one (j : Nat) : geom 1 j = j + 1 := by
  sorry

/-- With `c` = 2 the bound is `2 ^ (j + 1) - 1`: it doubles. -/
theorem geom_two (j : Nat) : geom 2 j + 1 = 2 ^ (j + 1) := by
  sorry

/-- A chain loses to a doubling fault at any speed. With `h` hops per tick the damage is
at least `n - h * ceil(log2 n)`. `L` is any number with `n ≤ 2 ^ L`; the least such is
`ceil(log2 n)`. -/
theorem chain_bound (h n L d : Nat) (hn : 2 ≤ n) (hL : n ≤ 2 ^ L)
    (hd : CascadeDamage 1 h n d) : n ≤ d + h * L := by
  sorry

/-- A halt that doubles, at two hops per tick, keeps pace: the damage is at most
`sqrt(n / 2)`, for every `n` of 2 or more. -/
theorem doubling_two_hops_bound (n d : Nat) (hn : 2 ≤ n) (hd : CascadeDamage 2 2 n d) :
    2 * (d * d) ≤ n := by
  sorry

/-- A halt that doubles, at one hop per tick, loses exactly `n / 4` when `n` is a power
of two of 8 or more. -/
theorem doubling_one_hop_exact (k d : Nat) (hk : 3 ≤ k) (hd : CascadeDamage 2 1 (2 ^ k) d) :
    4 * d = 2 ^ k := by
  sorry

/-- The table of section 8.2, rows 1 and 2: everything halts together, in the same tick
and 5 ticks later. -/
theorem halt_table_together :
    windowDamage 1024 0 = 1 ∧ windowDamage 1048576 0 = 1 ∧
    windowDamage 1024 5 = 32 ∧ windowDamage 1048576 5 = 32 := by
  sorry

/-- The table of section 8.2, rows 3 and 4: passed to 1 per hop, at 1 hop and at 128 hops
per tick. -/
theorem halt_table_chain :
    CascadeDamage 1 1 1024 1014 ∧ CascadeDamage 1 1 1048576 1048556 ∧
    CascadeDamage 1 128 1024 128 ∧ CascadeDamage 1 128 1048576 1046016 := by
  sorry

/-- The table of section 8.2, rows 5 to 7: passed to 2 per hop, at 1, 2 and 4 hops per
tick. -/
theorem halt_table_doubling :
    CascadeDamage 2 1 1024 256 ∧ CascadeDamage 2 1 1048576 262144 ∧
    CascadeDamage 2 2 1024 16 ∧ CascadeDamage 2 2 1048576 512 ∧
    CascadeDamage 2 4 1024 4 ∧ CascadeDamage 2 4 1048576 16 := by
  sorry

/-! ### Whether three monitors are forced

Section 10.2 of `results.md`, where statements 25 and 26 leave it: naming with at most one
faulty monitor (`Naming.lean`), naming after the loss of a monitor, and the count behind
the cascade. -/

/-- With one monitor or two, no rule always names the faulty monitor, when at most one is
faulty. `a` and `b` are all the monitors, and may be the same one. -/
theorem one_or_two_cannot_name (a b : M) (hall : ∀ m, m = a ∨ m = b) : ¬ CanName M := by
  sorry

/-- With three or more monitors, a rule exists that always names the faulty monitor, and
says so when none is faulty. -/
theorem three_or_more_can_name (a b c : M) (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    CanName M := by
  sorry

/-- Still naming it after losing one takes at least four. With two monitors or three,
after any one of them is lost no rule always names the faulty monitor among those that
remain. `a`, `b` and `c` are all the monitors, and `c` may be `a` or `b`. The case of one
monitor is not stated: nothing remains after its loss. -/
theorem cannot_name_after_loss (a b c : M) (hab : a ≠ b) (hall : ∀ m, m = a ∨ m = b ∨ m = c)
    (lost : M) : ¬ CanName {m : M // m ≠ lost} := by
  sorry

/-- With four or more monitors, after any one of them is lost a rule still exists that
always names the faulty monitor among those that remain. -/
theorem can_name_after_loss (a b c d : M) (hab : a ≠ b) (hac : a ≠ c) (had : a ≠ d)
    (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) (lost : M) : CanName {m : M // m ≠ lost} := by
  sorry

/-- The cascade, as a count. If every member of a group passes a halt to at least two
other members, the group has at least three members. The group has a member, `x₀`. -/
theorem pass_to_two_needs_three {X : Type} (passes : X → X → Prop) (x₀ : X)
    (h : ∀ x, ∃ y y', y ≠ x ∧ y' ≠ x ∧ y ≠ y' ∧ passes x y ∧ passes x y') :
    ∃ a b c : X, a ≠ b ∧ a ≠ c ∧ b ≠ c := by
  sorry

/-! ### Further statements

One more about restarting (section 10.3), one more about the halt (section 8.2), the
count of work steps a slow report costs (section 8.1, `Reflex.lean`), and the mesh at any
fault rate (section 10.2, `MeshAt.lean`). -/

/-- A full stop is reachable (section 10.3). In every ring with finitely many members,
the game can reach a state in which no member is running and none is blocked: every
member has been stopped, by the environment or by the rule, and the environment has
released each one it stopped. -/
theorem full_stop_reachable {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs) :
    ∃ (moves : List (RingMove X)) (s : RingState X),
      RingRun g ringInit moves s ∧ (∀ x, ¬ s.running x) ∧ (∀ x, ¬ s.blocked x) := by
  sorry

/-- A halt that doubles, at one hop per tick, loses between a fifth and two fifths of the
system for every `n` from 8 to 3,000 (section 8.2), the ends of that range of shares
included. -/
theorem doubling_one_hop_range (n d : Nat) (hlo : 8 ≤ n) (hhi : n ≤ 3000)
    (hd : CascadeDamage 2 1 n d) : n ≤ 5 * d ∧ 5 * d ≤ 2 * n := by
  sorry

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
  sorry

/-- The rounds counted in `slow_report_count` are rounds of an execution. If `w` took a
work step in each of the first `j` rounds, then round `j + 1` is a round of the model
from a state that an execution reaches and that is not responded: the state it starts
from is `soloStart sys w j`, and its outcome is that of `soloEnv sys w j`. -/
theorem slow_report_execution (sys : System M W B S) (hf : 1 ≤ sys.f)
    (hslow : sys.slowReports = true) (hwin : sys.window = 0) (hgate : sys.gate = true)
    (w : W) (hw : ¬ sys.IsJoiner w) (j : Nat) (hj : ∀ i, i < j → SoloWorks sys w i) :
    Reachable sys (soloStart sys w j) ∧ ¬ Responded sys (soloStart sys w j) ∧
      Round sys (soloStart sys w j) (afterEnv sys (soloEnv sys w j)) := by
  sorry

/-- The holding half of the mesh result (section 10.2): a mesh of `n` monitors has no gap
when `f ≤ n - 1`. `ms` is a list of different monitors, more than `f` of them, so there
are at least `f + 1` monitors. The numbers of monitors and of work processes are
otherwise arbitrary. -/
theorem mesh_holds (f : Nat) (ms : List M) (hnd : ms.Nodup) (hlen : f < ms.length) :
    NoGap (meshAt M W f) := by
  sorry

/-- The mesh result in both directions (section 10.2): a mesh of `n` monitors, `n` at
least 1, has no gap exactly when `f ≤ n - 1`. `ms` lists every monitor once, so
`ms.length` is `n`, and `f < ms.length` says `f ≤ n - 1`. -/
theorem mesh_exact (f : Nat) (ms : List M) (hne : ms ≠ []) (hnd : ms.Nodup)
    (hall : ∀ m, m ∈ ms) : NoGap (meshAt M W f) ↔ f < ms.length := by
  sorry

/-! ### The interleaved rings on two levels

Sections 2.7 and 10.1 of `results.md`: the system of `Nested.lean`. The model check
settles it by search. Here it is a case of `theorem_S_wide`, and with each base ring in
one boundary it meets the boundary clause of `SufficientWide` with two boundaries of four
monitors each. -/

/-- The interleaved rings on two levels have no gap at one fault per round (section 10.1,
checked instances). -/
theorem nested_noGap : NoGap (nested false) := by
  sorry

/-- The same with each base ring whole in one boundary, so that one step can stop an
entire ring (sections 2.7 and 10.1): no gap at one fault per round. -/
theorem nested_boundaries_noGap : NoGap (nested true) := by
  sorry

/-- Both are cases of `theorem_S_wide`: with or without the ring boundaries, the system is
of the wider class and meets its conditions. -/
theorem nested_is_wide (ringBoundaries : Bool) :
    Ordinary (nested ringBoundaries) ∧ SufficientWide (nested ringBoundaries) := by
  sorry

/-! ### No gap at any number of faults per round

`results-join.md`, section 3: Theorem J and Theorem F, for systems with nothing joining
(`AnyRate.lean`). `results.md`, section 11, lists a sufficient condition at more than one
fault per round as missing. In the three theorems the number of faults per round is the
system's own `f`, and may be any number; in the other two statements it is the `f` that
the statement names. -/

/-- Theorem J, with nothing joining. A plain system has no gap at `f` faults per round if
its monitors are connected by pairs that watch each other and report to each other, every
work process has a state checker and more than `f` halt inputs, and there are more than
`f` monitors. -/
theorem theorem_J (sys : System M W B S) (hp : Plain sys) (hs : SufficientJ sys sys.f) :
    NoGap sys := by
  sorry

/-- Theorem J with its first condition in one direction only. `results-join.md` does not
state this form. A plain system has no gap at `f` faults per round if from every monitor
every monitor is reached by steps that each go from a monitor to one it watches and hears
from, every work process has a state checker and more than `f` halt inputs, and there are
more than `f` monitors. -/
theorem theorem_J_one_way (sys : System M W B S) (hp : Plain sys)
    (hs : SufficientOneWay sys sys.f) : NoGap sys := by
  sorry

/-- Theorem J is a special case of the one-way form: the conditions of Theorem J give
those of `SufficientOneWay`, in any system and at any `f`. -/
theorem paired_is_one_way (sys : System M W B S) (f : Nat) (hs : SufficientJ sys f) :
    SufficientOneWay sys f := by
  sorry

/-- The holding half of the mesh result (`mesh_holds`) is a special case of Theorem J: a
mesh of more than `f` monitors, at `f` faults per round, is plain and meets the
conditions of Theorem J. `ms` is a list of different monitors, more than `f` of them. -/
theorem mesh_is_connected (f : Nat) (ms : List M) (hnd : ms.Nodup) (hlen : f < ms.length) :
    Plain (meshAt M W f) ∧ SufficientJ (meshAt M W f) f := by
  sorry

/-- Theorem F. A plain system has no gap at `f` faults per round if every monitor has at
least `f` state checkers and at least `f` signal readers other than itself, every work
process has a state checker, and for every monitor `d`, every work process `w` and every
set of at most `f` monitors that does not contain `d`, some halt input of `w` outside the
set is reached from `d` along report edges that avoid the set. -/
theorem theorem_F (sys : System M W B S) (hp : Plain sys) (hs : SufficientF sys sys.f) :
    NoGap sys := by
  sorry

/-! ### The ring of `k` members and a coordinator

`results-minimal.md`, section 3, and `part-a.md`: the ring of `Rings.lean`, under each of
the two readings of a connection, with the work reading every monitor. -/

/-- The ring is a case of Theorem J when `f` is at most `k`: it is plain and meets the
conditions of Theorem J at `f` faults per round. The coordinator and each member watch
each other and report to each other, under either reading. -/
theorem ring_is_connected (rd : Reading) (k f : Nat) (h : f ≤ k) :
    Plain (ring rd k f) ∧ SufficientJ (ring rd k f) f := by
  sorry

/-- The ring of `k` members in a cycle and a coordinator, the work reading every monitor,
has no gap exactly when `f` is at most `k`, under either reading and for every `k`
(`results-minimal.md`, section 3). -/
theorem ring_exact (rd : Reading) (k f : Nat) : NoGap (ring rd k f) ↔ f ≤ k := by
  sorry

/-- The candidate ring, three members in a cycle and a coordinator, the work reading all
four: no gap at one, two and three faults per round, under either reading. -/
theorem candidate_noGap (rd : Reading) :
    NoGap (ring rd 3 1) ∧ NoGap (ring rd 3 2) ∧ NoGap (ring rd 3 3) := by
  sorry

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
    3 * k ≤ l.length := by
  sorry

/-- Under flow, every wiring of the `k` members and the coordinator in which every monitor
has two watchers (R2) has at least `2 * k + 2` connections. R5 is not needed for the
count: under flow R2 alone gives it. -/
theorem least_flow (k f : Nat) (l : List (RingMon k × RingMon k)) (hnd : l.Nodup)
    (h2 : R2 (wiredList .flow l f)) : 2 * k + 2 ≤ l.length := by
  sorry

/-- The list `candidateArrows` holds exactly the connections of the ring with three
members. -/
theorem candidate_is_ring (x y : RingMon 3) :
    (x, y) ∈ candidateArrows ↔ ringConn 3 x y := by
  sorry

/-- The least ring of four under actor. Among the wirings of four monitors as directed
connections, every one that meets R2 and R5 has at least nine connections, and the
candidate has nine and meets both: under actor the candidate is among the least. -/
theorem least_of_four_actor (f : Nat) :
    (∀ l : List (RingMon 3 × RingMon 3), l.Nodup → R2 (wiredList .actor l f) →
        R5 (wiredList .actor l f) .coord → 9 ≤ l.length) ∧
    candidateArrows.Nodup ∧ candidateArrows.length = 9 ∧
    R2 (wiredList .actor candidateArrows f) ∧
    R5 (wiredList .actor candidateArrows f) .coord := by
  sorry

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
      R5 (wiredList .flow candidateArrows f) .coord) := by
  sorry

/-! ### The same ring one level up

`results-minimal.md`, sections 4.1 and 4.6: the tower of `Tower.lean`, as one system,
under each of the two readings, each base ring's work reading its own four monitors. -/

/-- The tower is a case of Theorem J at up to three faults per round, at every number of
levels from one, when every monitor is in a boundary of its own: it is plain and meets
the conditions of Theorem J. A coordinator and each of its members watch each other and
report to each other, and the rings are joined through the coordinators they share. -/
theorem tower_is_connected (rd : Reading) (n f : Nat) (hn : 1 ≤ n) (hf : f ≤ 3) :
    Plain (tower rd n false f) ∧ SufficientJ (tower rd n false f) f := by
  sorry

/-- The tower of any number of levels from one, every monitor in a boundary of its own,
has no gap exactly when `f` is at most 3, the number of halt inputs of a work process
less one (`results-minimal.md`, section 4.6). -/
theorem tower_exact (rd : Reading) (n f : Nat) (hn : 1 ≤ n) :
    NoGap (tower rd n false f) ↔ f ≤ 3 := by
  sorry

/-- The tower of any number of levels from one, every monitor in a boundary of its own:
no gap at one, two and three faults per round, under either reading. -/
theorem tower_noGap (rd : Reading) (n : Nat) (hn : 1 ≤ n) :
    NoGap (tower rd n false 1) ∧ NoGap (tower rd n false 2) ∧
      NoGap (tower rd n false 3) := by
  sorry

/-- With each base ring whole in one boundary, the tower of two or more levels is a case
of `theorem_S_wide` at one fault per round: it is of the wider class and meets its
conditions. The loss of a whole base ring is read by the coordinator above it. -/
theorem tower_boundaries_is_wide (rd : Reading) (n : Nat) (hn : 2 ≤ n) :
    Ordinary (tower rd n true 1) ∧ SufficientWide (tower rd n true 1) := by
  sorry

/-- With each base ring whole in one boundary, the tower of two or more levels has no gap
at one fault per round, under either reading (`results-minimal.md`, section 4.6). -/
theorem tower_boundaries_noGap (rd : Reading) (n : Nat) (hn : 2 ≤ n) :
    NoGap (tower rd n true 1) := by
  sorry

/-- Two levels are needed for that. A single ring whole in one boundary has a gap at one
fault per round: the boundary is stopped, and then a process is mutated with no monitor
left to flag it (`results-minimal.md`, section 4.6; Theorem 0, part 2). -/
theorem tower_one_level_boundaries_gap (rd : Reading) : ViolatesG1 (tower rd 1 true 1) := by
  sorry

/-! ### Monitors that join

`model-spec-join.md` and `results-join.md`, section 3: the model of `Join.lean`, the
conditions of `JoinConditions.lean` and the two systems of `JoinExamples.lean`. The model
with joins is a second model beside that of `Model.lean`. The first two statements say
that a system with none of the new fields behaves in it as in `Model.lean`: executions
reach the same states, and the result for each goal is the same. As everywhere in this
project, a result is whether a goal can be violated, and not the round in which it first
is. -/

/-- A system with none of the three new fields reaches the same states in the model with
joins as in the model of `Model.lean`: a state of the model with joins is reached by an
execution exactly when its components are a state that an execution of `Model.lean`
reaches. (With no group, the set of groups that have joined is empty in every state.) -/
theorem plainJoin_reachable (sys : System M W B S) (s : JState M W Empty) :
    JReachable (plainJoin sys) s ↔ Reachable sys s.st := by
  sorry

/-- A system with none of the three new fields has the same result in both models: no gap
in the one exactly when no gap in the other, and each goal can be violated in the one
exactly when it can in the other. -/
theorem plainJoin_same (sys : System M W B S) :
    (JNoGap (plainJoin sys) ↔ NoGap sys) ∧
    (JViolatesG1 (plainJoin sys) ↔ ViolatesG1 sys) ∧
    (JViolatesG2 (plainJoin sys) ↔ ViolatesG2 sys) := by
  sorry

/-- A monitor nobody checks (`results-join.md`, section 3). If the joins can reach a set
of present processes in which some present monitor has no present state checker other
than itself, G1 can be violated at one fault per round or more: the joins are taken one a
round, and then that monitor is mutated. This holds for every system of the model with
joins, plain or not. -/
theorem unchecked_present_monitor_gap {G : Type} (sys : JSystem M W B S G)
    (hf : 1 ≤ sys.base.f) (s : JState M W G) (hs : JoinsReach sys s) (z : M)
    (hz : JPresent sys s (.inl z))
    (hc : ∀ r, sys.base.checkers (.inl z) r → JPresent sys s (.inl r) → r = z) :
    JViolatesG1 sys := by
  sorry

/-- Lemma N: late monitors never help. If `small` is `sys` with every late monitor and
its edges deleted, then each goal that can be violated in `small` can be violated in
`sys`: the environment may leave every group's step untaken. The lemma is stated for
systems whose joiner, if there is one, is in no group and has no slow edge
(`InitialPart`). `results-join.md` also says that the violation needs no more rounds in
`sys`; rounds are not counted here. -/
theorem lemma_N {G M₀ B₀ S₀ : Type} (sys : JSystem M W B S G) (small : System M₀ W B₀ S₀)
    (ι : M₀ → M) (β : B₀ → B) (σ : S₀ → S) (hi : InitialPart sys small ι β σ) :
    (ViolatesG1 small → JViolatesG1 sys) ∧ (ViolatesG2 small → JViolatesG2 sys) := by
  sorry

/-- Theorem J, with joins. A system that is plain with joins has no gap at `f` faults per
round if, in every set of present processes the joins can reach, the present monitors are
connected by pairs that watch each other and report to each other and every present work
process has a present state checker and more than `f` present halt inputs, and there are
more than `f` initial monitors. Monitors may or may not arrive bad. -/
theorem theorem_J_joins {G : Type} (sys : JSystem M W B S G) (hp : PlainJ sys)
    (hs : SufficientJoins sys sys.base.f) : JNoGap sys := by
  sorry

/-- In a plain system that meets the conditions of Theorem J, every round with a fault
ends in a complete response. -/
theorem connected_answers (sys : System M W B S) (hp : Plain sys)
    (hs : SufficientJ sys sys.f) : AnswersFaults sys := by
  sorry

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
    (hrk : Ranked sys rank chk rdr tgt) (hpr : Prompt sys chk rdr tgt) : JNoGap sys := by
  sorry

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
    JNoGap sys ↔ sys.base.f ≤ k := by
  sorry

/-- The same for the mesh. A mesh of `n` monitors, `n` at least 1, grown by any number of
late monitors under the hypotheses of Theorem L has no gap exactly when `f ≤ n - 1`. `ms`
lists every monitor of the mesh once. -/
theorem grown_mesh_exact {G M₀ W₀ : Type} (sys : JSystem M W₀ B S G) (ms : List M₀)
    (hne : ms ≠ []) (hnd : ms.Nodup) (hall : ∀ m, m ∈ ms) (ι : M₀ → M) (β : M₀ → B)
    (σ : Unit → S) (hi : InitialPart sys (meshAt M₀ W₀ sys.base.f) ι β σ)
    (hg : GrownClass sys) (hsw : ∀ m, ¬ sys.base.switches m) (rank : M → Nat)
    (chk rdr tgt : M → M) (hrk : Ranked sys rank chk rdr tgt)
    (hpr : Prompt sys chk rdr tgt) : JNoGap sys ↔ sys.base.f < ms.length := by
  sorry

/-- The hypothesis of Theorem L on slow edges is needed (`results-join.md`, sections 3
and 5). When the state checks of a late monitor are slow edges, both goals can be
violated: at two faults per round when monitors arrive good (the monitor joins and is
mutated in one round), and at one fault per round when a monitor may arrive bad. -/
theorem slow_check_example_gap :
    (JViolatesG1 (slowCheckExample false 2) ∧ JViolatesG2 (slowCheckExample false 2)) ∧
    (JViolatesG1 (slowCheckExample true 1) ∧ JViolatesG2 (slowCheckExample true 1)) := by
  sorry

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
      ¬ (slowCheckExample arriveBad f).slowFwd n (.inl 0)) := by
  sorry

/-- The hypothesis of Theorem L on switches is needed (`results-join.md`, section 3).
When a late monitor that another leans on has an off switch, both goals can be violated
at one fault per round, with monitors arriving good and no slow edge: N5 joins, N6 joins,
N5 is switched off, N6 is mutated. -/
theorem switch_example_gap : JViolatesG1 switchExample ∧ JViolatesG2 switchExample := by
  sorry

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
    (∀ m, switchExample.base.switches m ↔ m = .inr 0) := by
  sorry

/-! ### More edges never hurt

Lemma M of `results-join.md`, section 3, with the relations of `MoreEdges.lean`. As
everywhere in this project, a result is whether a goal can be violated; that the second
system needs at least as many rounds to violate it, which the lemma also says there, is
not stated. -/

/-- Lemma M, for the model of `Model.lean`. Let two systems with no window differ only in
that the second has more edges. Then each goal that can be violated in the second can be
violated in the first, and if the first has no gap, neither has the second. -/
theorem lemma_M (sys₁ sys₂ : System M W B S) (h : MoreEdges sys₁ sys₂)
    (hw : sys₁.window = 0) :
    (ViolatesG1 sys₂ → ViolatesG1 sys₁) ∧ (ViolatesG2 sys₂ → ViolatesG2 sys₁) ∧
      (NoGap sys₁ → NoGap sys₂) := by
  sorry

/-- Lemma M, for the model with joins. Let two systems with no window differ only in that
the second has more edges, or has an edge prompt that is slow in the first. Then each
goal that can be violated in the second can be violated in the first, and if the first
has no gap, neither has the second. -/
theorem lemma_M_joins {G : Type} (sys₁ sys₂ : JSystem M W B S G) (h : JMoreEdges sys₁ sys₂)
    (hw : sys₁.base.window = 0) :
    (JViolatesG1 sys₂ → JViolatesG1 sys₁) ∧ (JViolatesG2 sys₂ → JViolatesG2 sys₁) ∧
      (JNoGap sys₁ → JNoGap sys₂) := by
  sorry

end SelfObserving
