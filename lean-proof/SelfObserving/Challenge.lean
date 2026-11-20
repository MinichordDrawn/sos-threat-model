/-
The statements to be proved, with their proofs left out. This file, `Model.lean`,
`Conditions.lean`, `Systems.lean` and `Reference.lean` are what a reader has to check
against `model-spec.md` and `results.md`.
-/
import SelfObserving.Systems
import SelfObserving.Reference

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

end SelfObserving
