/-
The statements to be proved, with their proofs left out. This file, `Model.lean`,
`Conditions.lean`, `Systems.lean` and `Reference.lean` are what a reader has to check
against `model-spec.md` and `results.md`.

The statements after the first twenty-six also use the definitions of `Restart.lean`,
`Wide.lean`, `Growth.lean`, `Naming.lean`, `Reflex.lean`, `MeshAt.lean` and `Nested.lean`,
which a reader has to check in the same way. `Wide.lean` is not transcribed from a passage
of `results.md`, and its heading says what it is written from.
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
`unchecked_monitor_gap` and `few_halt_inputs_gap`. Two results of those sections that could
be stated in the round model are not here: that a mesh of `n` monitors has no gap when
`f ≤ n - 1` (section 10.2), and the count of work steps in section 8.1, of which
`slow_report_gap` is the case "at least one". A set of monitors is given as a list without
repeats. -/

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
monitor, `z`, is faulty (`results.md` says "at most one"; the case of none is not stated
here). Every other monitor names `z`, and `z` may name anyone. A rule reads the names and
says which monitor is faulty. -/

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

end SelfObserving
