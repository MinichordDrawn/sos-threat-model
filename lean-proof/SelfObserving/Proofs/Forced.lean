/-
Proofs of the statements of `Challenge.lean` under "Whether three monitors are forced".
`Solution.lean` states them again and takes each proof from here.

The file has these parts:

- naming with at most one faulty monitor: no rule with one monitor or two, a rule with
  three or more;
- naming after the loss of a monitor: the monitors that remain are a type of their own,
  and the two statements above are applied to it;
- the count behind the cascade.

Only `Naming.lean` is imported.
-/
import SelfObserving.Naming

namespace SelfObserving
namespace Forced

variable {M : Type}

/-! ### Naming with at most one faulty monitor -/

/-- With one monitor, "it names nobody" is what a rule reads both when no monitor is faulty
and when that monitor is. With two, "each names the other" is what a rule reads both when
the first is faulty and when the second is. Either way the rule gives one answer. -/
theorem one_or_two_cannot_name (a b : M) (hall : ∀ m, m = a ∨ m = b) : ¬ CanName M := by
  rintro ⟨rule, h⟩
  by_cases hab : a = b
  · -- One monitor.
    have hone : ∀ m, m = a := fun m => (hall m).elim id (fun hm => hm.trans hab.symm)
    have hnone : rule (fun _ => none) = none := h none _ (fun _ _ => rfl)
    have hsome : rule (fun _ => none) = some a :=
      h (some a) _ (fun m hm => absurd (congrArg some (hone m)) hm)
    exact nomatch hnone.symm.trans hsome
  · -- Two monitors.
    classical
    have ha : rule (fun m => if m = a then some b else some a) = some a := by
      refine h (some a) _ (fun m hm => ?_)
      have hma : m ≠ a := fun e => hm (congrArg some e)
      exact ite_eq_right hma
    have hb : rule (fun m => if m = a then some b else some a) = some b := by
      refine h (some b) _ (fun m hm => ?_)
      have hmb : m ≠ b := fun e => hm (congrArg some e)
      have hma : m = a := (hall m).elim id (fun e => absurd e hmb)
      exact ite_eq_left hma
    exact hab (Option.some.inj (ha.symm.trans hb))

/-- The rule reads what three different monitors `a`, `b`, `c` give: what `a` gives if `b`
gives the same, and otherwise what `c` gives. At most one of the three is faulty. If `a`
and `b` agree, one of them is correct, so what they give is right. If they differ, one of
them is faulty, so `c` is correct. -/
theorem three_or_more_can_name (a b c : M) (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    CanName M := by
  classical
  refine ⟨fun names => if names a = names b then names a else names c, ?_⟩
  intro z names hz
  show (if names a = names b then names a else names c) = z
  split
  · rename_i hsame
    by_cases ha : some a = z
    · have hb : some b ≠ z := fun e => hab (Option.some.inj (ha.trans e.symm))
      exact hsame.trans (hz b hb)
    · exact hz a ha
  · rename_i hdiff
    by_cases hc : some c = z
    · have ha : some a ≠ z := fun e => hac (Option.some.inj (e.trans hc.symm))
      have hb : some b ≠ z := fun e => hbc (Option.some.inj (e.trans hc.symm))
      exact absurd ((hz a ha).trans (hz b hb).symm) hdiff
    · exact hz c hc

/-! ### Naming after the loss of a monitor -/

/-- If `x` and `y` are all the monitors that remain after `lost` is lost, no rule names the
faulty monitor among those that remain. `x` and `y` may be the same one. -/
theorem cannot_name_of_two_left (lost x y : M) (hx : x ≠ lost) (hy : y ≠ lost)
    (hall : ∀ m, m ≠ lost → m = x ∨ m = y) : ¬ CanName {m : M // m ≠ lost} :=
  one_or_two_cannot_name ⟨x, hx⟩ ⟨y, hy⟩
    (fun m => (hall m.1 m.2).imp Subtype.ext Subtype.ext)

/-- If three different monitors remain after `lost` is lost, a rule names the faulty
monitor among those that remain. -/
theorem can_name_of_three_left (lost x y z : M) (hx : x ≠ lost) (hy : y ≠ lost)
    (hz : z ≠ lost) (hxy : x ≠ y) (hxz : x ≠ z) (hyz : y ≠ z) :
    CanName {m : M // m ≠ lost} :=
  three_or_more_can_name ⟨x, hx⟩ ⟨y, hy⟩ ⟨z, hz⟩
    (fun e => hxy (congrArg Subtype.val e)) (fun e => hxz (congrArg Subtype.val e))
    (fun e => hyz (congrArg Subtype.val e))

/-- The lost monitor is `a`, `b` or `c`. If it is `a`, then `b` remains, and `c` too unless
`c` is `a`. If it is `b`, then `a` remains, and `c` too unless `c` is `b`. If it is
neither, it is `c`, and `a` and `b` remain. In each case one monitor or two remain. -/
theorem cannot_name_after_loss (a b c : M) (hab : a ≠ b) (hall : ∀ m, m = a ∨ m = b ∨ m = c)
    (lost : M) : ¬ CanName {m : M // m ≠ lost} := by
  by_cases hla : lost = a
  · have hb : b ≠ lost := fun e => hab (hla.symm.trans e.symm)
    by_cases hc : c = lost
    · refine cannot_name_of_two_left lost b b hb hb (fun m hm => ?_)
      rcases hall m with h | h | h
      · exact absurd (h.trans hla.symm) hm
      · exact Or.inl h
      · exact absurd (h.trans hc) hm
    · refine cannot_name_of_two_left lost b c hb hc (fun m hm => ?_)
      rcases hall m with h | h | h
      · exact absurd (h.trans hla.symm) hm
      · exact Or.inl h
      · exact Or.inr h
  · have ha : a ≠ lost := fun e => hla e.symm
    by_cases hlb : lost = b
    · by_cases hc : c = lost
      · refine cannot_name_of_two_left lost a a ha ha (fun m hm => ?_)
        rcases hall m with h | h | h
        · exact Or.inl h
        · exact absurd (h.trans hlb.symm) hm
        · exact absurd (h.trans hc) hm
      · refine cannot_name_of_two_left lost a c ha hc (fun m hm => ?_)
        rcases hall m with h | h | h
        · exact Or.inl h
        · exact absurd (h.trans hlb.symm) hm
        · exact Or.inr h
    · have hb : b ≠ lost := fun e => hlb e.symm
      have hlc : lost = c := by
        rcases hall lost with h | h | h
        · exact absurd h hla
        · exact absurd h hlb
        · exact h
      refine cannot_name_of_two_left lost a b ha hb (fun m hm => ?_)
      rcases hall m with h | h | h
      · exact Or.inl h
      · exact Or.inr h
      · exact absurd (h.trans hlc.symm) hm

/-- The lost monitor is at most one of `a`, `b`, `c`, `d`, so three of them remain. -/
theorem can_name_after_loss (a b c d : M) (hab : a ≠ b) (hac : a ≠ c) (had : a ≠ d)
    (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) (lost : M) : CanName {m : M // m ≠ lost} := by
  by_cases hla : lost = a
  · have hb : b ≠ lost := fun e => hab (hla.symm.trans e.symm)
    have hc : c ≠ lost := fun e => hac (hla.symm.trans e.symm)
    have hd : d ≠ lost := fun e => had (hla.symm.trans e.symm)
    exact can_name_of_three_left lost b c d hb hc hd hbc hbd hcd
  · have ha : a ≠ lost := fun e => hla e.symm
    by_cases hlb : lost = b
    · have hc : c ≠ lost := fun e => hbc (hlb.symm.trans e.symm)
      have hd : d ≠ lost := fun e => hbd (hlb.symm.trans e.symm)
      exact can_name_of_three_left lost a c d ha hc hd hac had hcd
    · have hb : b ≠ lost := fun e => hlb e.symm
      by_cases hlc : lost = c
      · have hd : d ≠ lost := fun e => hcd (hlc.symm.trans e.symm)
        exact can_name_of_three_left lost a b d ha hb hd hab had hbd
      · have hc : c ≠ lost := fun e => hlc e.symm
        exact can_name_of_three_left lost a b c ha hb hc hab hac hbc

/-! ### The count behind the cascade -/

/-- The member `x₀` and the two members it passes a halt to are three different members. -/
theorem pass_to_two_needs_three {X : Type} (passes : X → X → Prop) (x₀ : X)
    (h : ∀ x, ∃ y y', y ≠ x ∧ y' ≠ x ∧ y ≠ y' ∧ passes x y ∧ passes x y') :
    ∃ a b c : X, a ≠ b ∧ a ≠ c ∧ b ≠ c := by
  obtain ⟨y, y', hy, hy', hyy, _, _⟩ := h x₀
  exact ⟨x₀, y, y', Ne.symm hy, Ne.symm hy', hyy⟩

end Forced
end SelfObserving
