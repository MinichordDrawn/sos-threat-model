/-
The interleaved rings on two levels (`Nested.lean`): `nested_is_wide`, `nested_noGap` and
`nested_boundaries_noGap`. Nothing outside this project is imported.

The system has nine monitors. The conditions of `SufficientWide` are shown by naming, for
each monitor or boundary that may be lost, a watcher and a path of report edges. The paths
are not listed one by one: five lemmas say what is reached from a coordinator, or from a
monitor that reports to one, outside any set `Z` of monitors, and the cases use them.

The only computation is of two kinds, both small. `decide` settles inequalities between
two named monitors. And where a field of `nested` is applied to named monitors (a report
edge, a signal reader, a checker, a halt input, a boundary), Lean unfolds the definition
to check the witness given: `rfl`, `Or.inl rfl` and the like for a wire that is there, and
`nomatch` for a boundary that is not the one asked for.
-/
import SelfObserving.Nested
import SelfObserving.Proofs.Widening

namespace SelfObserving
namespace NestedRings

/-! ### Paths in general -/

section General

variable {M W B S : Type}

/-- Paths outside `Z` compose. -/
theorem ro_trans {sys : System M W B S} {Z : M → Prop} {x y y' : M}
    (h₁ : ReachOutside sys Z x y) (h₂ : ReachOutside sys Z y y') :
    ReachOutside sys Z x y' := by
  induction h₂ with
  | refl _ => exact h₁
  | step _ hf hz ih => exact .step ih hf hz

/-- A path outside the set that holds `z` alone is a path that avoids `z`. -/
theorem ra_of_ro {sys : System M W B S} {z x y : M}
    (h : ReachOutside sys (fun m => m = z) x y) : ReachAvoiding sys z x y := by
  induction h with
  | refl hx => exact .refl hx
  | step _ hf hz ih => exact .step ih hf hz

/-- A path outside any set is a path. -/
theorem reach_of_ro {sys : System M W B S} {Z : M → Prop} {x y : M}
    (h : ReachOutside sys Z x y) : Reach sys x y := by
  induction h with
  | refl _ => exact .refl _
  | step _ hf _ ih => exact .step ih hf

end General

/-! ### The report edges that the paths use -/

section Edges

variable (b : Bool)

theorem e_A1_A3 : (nested b).fwd .A1 .A3 := Or.inl rfl
theorem e_A1_KA : (nested b).fwd .A1 .KA := Or.inr rfl
theorem e_A2_KA : (nested b).fwd .A2 .KA := Or.inr rfl
theorem e_A3_A2 : (nested b).fwd .A3 .A2 := Or.inl rfl
theorem e_A3_KA : (nested b).fwd .A3 .KA := Or.inr rfl
theorem e_KA_A1 : (nested b).fwd .KA .A1 := Or.inl rfl
theorem e_KA_A2 : (nested b).fwd .KA .A2 := Or.inr (Or.inl rfl)
theorem e_KA_A3 : (nested b).fwd .KA .A3 := Or.inr (Or.inr (Or.inl rfl))
theorem e_KA_U3 : (nested b).fwd .KA .U3 := Or.inr (Or.inr (Or.inr rfl))
theorem e_B1_B3 : (nested b).fwd .B1 .B3 := Or.inl rfl
theorem e_B1_KB : (nested b).fwd .B1 .KB := Or.inr rfl
theorem e_B2_KB : (nested b).fwd .B2 .KB := Or.inr rfl
theorem e_B3_B2 : (nested b).fwd .B3 .B2 := Or.inl rfl
theorem e_B3_KB : (nested b).fwd .B3 .KB := Or.inr rfl
theorem e_KB_B1 : (nested b).fwd .KB .B1 := Or.inl rfl
theorem e_KB_B2 : (nested b).fwd .KB .B2 := Or.inr (Or.inl rfl)
theorem e_KB_B3 : (nested b).fwd .KB .B3 := Or.inr (Or.inr (Or.inl rfl))
theorem e_KB_KA : (nested b).fwd .KB .KA := Or.inr (Or.inr (Or.inr rfl))
theorem e_U3_KB : (nested b).fwd .U3 .KB := rfl

end Edges

/-! ### What the coordinators reach -/

section Stars

variable {b : Bool} {Z : NMon → Prop}

/-- One report edge outside `Z`. -/
theorem ro_edge {x y : NMon} (hx : ¬ Z x) (he : (nested b).fwd x y) (hy : ¬ Z y) :
    ReachOutside (nested b) Z x y :=
  .step (.refl hx) he hy

/-- From KA, outside `Z`: KA, the members of ring A, and U3. -/
theorem from_KA_near (hKA : ¬ Z .KA) (y : NMon) (hy : ¬ Z y)
    (h : y = .A1 ∨ y = .A2 ∨ y = .A3 ∨ y = .KA ∨ y = .U3) :
    ReachOutside (nested b) Z .KA y := by
  rcases h with rfl | rfl | rfl | rfl | rfl
  · exact ro_edge hKA (e_KA_A1 b) hy
  · exact ro_edge hKA (e_KA_A2 b) hy
  · exact ro_edge hKA (e_KA_A3 b) hy
  · exact .refl hKA
  · exact ro_edge hKA (e_KA_U3 b) hy

/-- From KB, outside `Z`: KB, the members of ring B, and KA. -/
theorem from_KB_near (hKB : ¬ Z .KB) (y : NMon) (hy : ¬ Z y)
    (h : y = .B1 ∨ y = .B2 ∨ y = .B3 ∨ y = .KB ∨ y = .KA) :
    ReachOutside (nested b) Z .KB y := by
  rcases h with rfl | rfl | rfl | rfl | rfl
  · exact ro_edge hKB (e_KB_B1 b) hy
  · exact ro_edge hKB (e_KB_B2 b) hy
  · exact ro_edge hKB (e_KB_B3 b) hy
  · exact .refl hKB
  · exact ro_edge hKB (e_KB_KA b) hy

/-- When the three members of the upper ring are outside `Z`, KA reaches every monitor
outside `Z`: its own ring and U3 at once, KB through U3, and ring B through KB. -/
theorem from_KA_all (hKA : ¬ Z .KA) (hU3 : ¬ Z .U3) (hKB : ¬ Z .KB) (y : NMon)
    (hy : ¬ Z y) : ReachOutside (nested b) Z .KA y := by
  have hk : ReachOutside (nested b) Z .KA .KB :=
    .step (ro_edge hKA (e_KA_U3 b) hU3) (e_U3_KB b) hKB
  cases y with
  | A1 => exact from_KA_near hKA _ hy (Or.inl rfl)
  | A2 => exact from_KA_near hKA _ hy (Or.inr (Or.inl rfl))
  | A3 => exact from_KA_near hKA _ hy (Or.inr (Or.inr (Or.inl rfl)))
  | KA => exact .refl hKA
  | U3 => exact ro_edge hKA (e_KA_U3 b) hy
  | KB => exact hk
  | B1 => exact ro_trans hk (from_KB_near hKB _ hy (Or.inl rfl))
  | B2 => exact ro_trans hk (from_KB_near hKB _ hy (Or.inr (Or.inl rfl)))
  | B3 => exact ro_trans hk (from_KB_near hKB _ hy (Or.inr (Or.inr (Or.inl rfl))))

/-- The same from any monitor outside `Z` that reports to KA. -/
theorem via_KA_all {r : NMon} (hr : ¬ Z r) (he : (nested b).fwd r .KA) (hKA : ¬ Z .KA)
    (hU3 : ¬ Z .U3) (hKB : ¬ Z .KB) (y : NMon) (hy : ¬ Z y) :
    ReachOutside (nested b) Z r y :=
  ro_trans (ro_edge hr he hKA) (from_KA_all hKA hU3 hKB y hy)

/-- The same from any monitor outside `Z` that reports to KB, which reports to KA. -/
theorem via_KB_all {r : NMon} (hr : ¬ Z r) (he : (nested b).fwd r .KB) (hKA : ¬ Z .KA)
    (hU3 : ¬ Z .U3) (hKB : ¬ Z .KB) (y : NMon) (hy : ¬ Z y) :
    ReachOutside (nested b) Z r y :=
  ro_trans (.step (ro_edge hr he hKB) (e_KB_KA b) hKA) (from_KA_all hKA hU3 hKB y hy)

end Stars

/-! ### The four conditions of Theorem S -/

/-- Condition (c) for a monitor `z` that is not in the upper ring: one watcher `r` of `z`
that reports to KA reaches every other monitor. -/
theorem c_via_KA {b : Bool} {z r : NMon} (hr : r ≠ z) (hw : Watches (nested b) r z)
    (he : (nested b).fwd r .KA) (hKA : NMon.KA ≠ z) (hU3 : NMon.U3 ≠ z)
    (hKB : NMon.KB ≠ z) (y : NMon) (hy : y ≠ z) :
    ∃ r, r ≠ z ∧ Watches (nested b) r z ∧ ReachAvoiding (nested b) z r y :=
  ⟨r, hr, hw, ra_of_ro (via_KA_all (Z := fun m => m = z) hr he hKA hU3 hKB y hy)⟩

/-- The same for a watcher that reports to KB. -/
theorem c_via_KB {b : Bool} {z r : NMon} (hr : r ≠ z) (hw : Watches (nested b) r z)
    (he : (nested b).fwd r .KB) (hKA : NMon.KA ≠ z) (hU3 : NMon.U3 ≠ z)
    (hKB : NMon.KB ≠ z) (y : NMon) (hy : y ≠ z) :
    ∃ r, r ≠ z ∧ Watches (nested b) r z ∧ ReachAvoiding (nested b) z r y :=
  ⟨r, hr, hw, ra_of_ro (via_KB_all (Z := fun m => m = z) hr he hKA hU3 hKB y hy)⟩

theorem nested_sufficient (b : Bool) : Sufficient (nested b) where
  a := by
    intro z
    cases z with
    | A1 => exact ⟨.A3, by decide, rfl, Or.inl rfl⟩
    | A2 => exact ⟨.A1, by decide, rfl, Or.inl rfl⟩
    | A3 => exact ⟨.A2, by decide, rfl, Or.inl rfl⟩
    | KA => exact ⟨.A1, by decide, Or.inl rfl, Or.inl rfl⟩
    | B1 => exact ⟨.B3, by decide, rfl, Or.inl rfl⟩
    | B2 => exact ⟨.B1, by decide, rfl, Or.inl rfl⟩
    | B3 => exact ⟨.B2, by decide, rfl, Or.inl rfl⟩
    | KB => exact ⟨.B1, by decide, Or.inl rfl, Or.inl rfl⟩
    | U3 => exact ⟨.KB, by decide, rfl, rfl⟩
  b := by
    intro w
    cases w with
    | WA => exact ⟨⟨.A1, rfl⟩, .A1, .KA, by decide, Or.inl rfl, Or.inr rfl⟩
    | WB => exact ⟨⟨.B1, rfl⟩, .B1, .KB, by decide, Or.inl rfl, Or.inr rfl⟩
  c := by
    intro z y hy
    cases z with
    | A1 =>
      exact c_via_KA (b := b) (z := .A1) (r := .A3) (by decide) ⟨rfl, Or.inl rfl⟩ (e_A3_KA b)
        (by decide) (by decide) (by decide) y hy
    | A2 =>
      exact c_via_KA (b := b) (z := .A2) (r := .A1) (by decide) ⟨rfl, Or.inl rfl⟩ (e_A1_KA b)
        (by decide) (by decide) (by decide) y hy
    | A3 =>
      exact c_via_KA (b := b) (z := .A3) (r := .A2) (by decide) ⟨rfl, Or.inl rfl⟩ (e_A2_KA b)
        (by decide) (by decide) (by decide) y hy
    | B1 =>
      exact c_via_KB (b := b) (z := .B1) (r := .B3) (by decide) ⟨rfl, Or.inl rfl⟩ (e_B3_KB b)
        (by decide) (by decide) (by decide) y hy
    | B2 =>
      exact c_via_KB (b := b) (z := .B2) (r := .B1) (by decide) ⟨rfl, Or.inl rfl⟩ (e_B1_KB b)
        (by decide) (by decide) (by decide) y hy
    | B3 =>
      exact c_via_KB (b := b) (z := .B3) (r := .B2) (by decide) ⟨rfl, Or.inl rfl⟩ (e_B2_KB b)
        (by decide) (by decide) (by decide) y hy
    | U3 =>
      -- The watcher is KB. It reports to ring B and to KA, and KA to ring A.
      have hKB : ¬ (fun m => m = NMon.U3) NMon.KB := by decide
      have hKA : ¬ (fun m => m = NMon.U3) NMon.KA := by decide
      refine ⟨.KB, by decide, ⟨rfl, rfl⟩, ra_of_ro ?_⟩
      have hk : ReachOutside (nested b) (fun m => m = NMon.U3) .KB .KA :=
        ro_edge hKB (e_KB_KA b) hKA
      cases y with
      | A1 => exact ro_trans hk (from_KA_near hKA _ hy (Or.inl rfl))
      | A2 => exact ro_trans hk (from_KA_near hKA _ hy (Or.inr (Or.inl rfl)))
      | A3 => exact ro_trans hk (from_KA_near hKA _ hy (Or.inr (Or.inr (Or.inl rfl))))
      | KA => exact hk
      | B1 => exact from_KB_near hKB _ hy (Or.inl rfl)
      | B2 => exact from_KB_near hKB _ hy (Or.inr (Or.inl rfl))
      | B3 => exact from_KB_near hKB _ hy (Or.inr (Or.inr (Or.inl rfl)))
      | KB => exact .refl hKB
      | U3 => exact absurd rfl hy
    | KA =>
      -- Two watchers. A1 reaches ring A without KA: A1 reports to A3, and A3 to A2.
      -- U3 reaches the rest: U3 reports to KB, and KB to ring B.
      have hA1 : ¬ (fun m => m = NMon.KA) NMon.A1 := by decide
      have hA3 : ¬ (fun m => m = NMon.KA) NMon.A3 := by decide
      have hU3 : ¬ (fun m => m = NMon.KA) NMon.U3 := by decide
      have hKB : ¬ (fun m => m = NMon.KA) NMon.KB := by decide
      have hk : ReachOutside (nested b) (fun m => m = NMon.KA) .U3 .KB :=
        ro_edge hU3 (e_U3_KB b) hKB
      have wA : NMon.A1 ≠ NMon.KA ∧ Watches (nested b) .A1 .KA :=
        ⟨by decide, Or.inl rfl, Or.inl rfl⟩
      have wU : NMon.U3 ≠ NMon.KA ∧ Watches (nested b) .U3 .KA :=
        ⟨by decide, Or.inr rfl, Or.inr rfl⟩
      cases y with
      | A1 => exact ⟨.A1, wA.1, wA.2, ra_of_ro (.refl hA1)⟩
      | A2 =>
        exact ⟨.A1, wA.1, wA.2,
          ra_of_ro (.step (ro_edge hA1 (e_A1_A3 b) hA3) (e_A3_A2 b) hy)⟩
      | A3 => exact ⟨.A1, wA.1, wA.2, ra_of_ro (ro_edge hA1 (e_A1_A3 b) hy)⟩
      | KA => exact absurd rfl hy
      | B1 =>
        exact ⟨.U3, wU.1, wU.2,
          ra_of_ro (ro_trans hk (from_KB_near hKB _ hy (Or.inl rfl)))⟩
      | B2 =>
        exact ⟨.U3, wU.1, wU.2,
          ra_of_ro (ro_trans hk (from_KB_near hKB _ hy (Or.inr (Or.inl rfl))))⟩
      | B3 =>
        exact ⟨.U3, wU.1, wU.2,
          ra_of_ro (ro_trans hk (from_KB_near hKB _ hy (Or.inr (Or.inr (Or.inl rfl)))))⟩
      | KB => exact ⟨.U3, wU.1, wU.2, ra_of_ro hk⟩
      | U3 => exact ⟨.U3, wU.1, wU.2, ra_of_ro (.refl hU3)⟩
    | KB =>
      -- Two watchers. B1 reaches ring B without KB: B1 reports to B3, and B3 to B2.
      -- KA reaches the rest: it reports to ring A and to U3.
      have hB1 : ¬ (fun m => m = NMon.KB) NMon.B1 := by decide
      have hB3 : ¬ (fun m => m = NMon.KB) NMon.B3 := by decide
      have hKA : ¬ (fun m => m = NMon.KB) NMon.KA := by decide
      have wB : NMon.B1 ≠ NMon.KB ∧ Watches (nested b) .B1 .KB :=
        ⟨by decide, Or.inl rfl, Or.inl rfl⟩
      have wK : NMon.KA ≠ NMon.KB ∧ Watches (nested b) .KA .KB :=
        ⟨by decide, Or.inr rfl, Or.inr rfl⟩
      cases y with
      | A1 => exact ⟨.KA, wK.1, wK.2, ra_of_ro (from_KA_near hKA _ hy (Or.inl rfl))⟩
      | A2 =>
        exact ⟨.KA, wK.1, wK.2,
          ra_of_ro (from_KA_near hKA _ hy (Or.inr (Or.inl rfl)))⟩
      | A3 =>
        exact ⟨.KA, wK.1, wK.2,
          ra_of_ro (from_KA_near hKA _ hy (Or.inr (Or.inr (Or.inl rfl))))⟩
      | KA => exact ⟨.KA, wK.1, wK.2, ra_of_ro (.refl hKA)⟩
      | B1 => exact ⟨.B1, wB.1, wB.2, ra_of_ro (.refl hB1)⟩
      | B2 =>
        exact ⟨.B1, wB.1, wB.2,
          ra_of_ro (.step (ro_edge hB1 (e_B1_B3 b) hB3) (e_B3_B2 b) hy)⟩
      | B3 => exact ⟨.B1, wB.1, wB.2, ra_of_ro (ro_edge hB1 (e_B1_B3 b) hy)⟩
      | KB => exact absurd rfl hy
      | U3 =>
        exact ⟨.KA, wK.1, wK.2,
          ra_of_ro (from_KA_near hKA _ hy (Or.inr (Or.inr (Or.inr (Or.inr rfl)))))⟩
  d := by
    intro w
    cases w with
    | WA =>
      exact ⟨.A1, rfl, fun m => reach_of_ro
        (via_KA_all (Z := fun _ => False) id (e_A1_KA b) id id id m id)⟩
    | WB =>
      exact ⟨.B1, rfl, fun m => reach_of_ro
        (via_KB_all (Z := fun _ => False) id (e_B1_KB b) id id id m id)⟩

/-! ### The boundaries -/

/-- With them, ring A is lost whole. U3 is outside and reads KA's signal; it reports to
KB, and KB to ring B. -/
theorem ringA_answered : LossAnswered (nested true) (InBoundary (nested true) .ringA) := by
  have hU3 : ¬ InBoundary (nested true) .ringA .U3 := fun h => nomatch h
  have hKB : ¬ InBoundary (nested true) .ringA .KB := fun h => nomatch h
  refine ⟨⟨.U3, hU3⟩, fun y hy => ⟨.U3, .KA, hU3, rfl, Or.inr rfl, ?_⟩⟩
  have hk : ReachOutside (nested true) (InBoundary (nested true) .ringA) .U3 .KB :=
    ro_edge hU3 (e_U3_KB true) hKB
  cases y with
  | A1 => exact absurd rfl hy
  | A2 => exact absurd rfl hy
  | A3 => exact absurd rfl hy
  | KA => exact absurd rfl hy
  | B1 => exact ro_trans hk (from_KB_near hKB _ hy (Or.inl rfl))
  | B2 => exact ro_trans hk (from_KB_near hKB _ hy (Or.inr (Or.inl rfl)))
  | B3 => exact ro_trans hk (from_KB_near hKB _ hy (Or.inr (Or.inr (Or.inl rfl))))
  | KB => exact hk
  | U3 => exact .refl hU3

/-- Ring B is lost whole. KA is outside and reads KB's signal; it reports to ring A and
to U3. -/
theorem ringB_answered : LossAnswered (nested true) (InBoundary (nested true) .ringB) := by
  have hKA : ¬ InBoundary (nested true) .ringB .KA := fun h => nomatch h
  refine ⟨⟨.KA, hKA⟩, fun y hy => ⟨.KA, .KB, hKA, rfl, Or.inr rfl, ?_⟩⟩
  cases y with
  | A1 => exact from_KA_near hKA _ hy (Or.inl rfl)
  | A2 => exact from_KA_near hKA _ hy (Or.inr (Or.inl rfl))
  | A3 => exact from_KA_near hKA _ hy (Or.inr (Or.inr (Or.inl rfl)))
  | KA => exact .refl hKA
  | B1 => exact absurd rfl hy
  | B2 => exact absurd rfl hy
  | B3 => exact absurd rfl hy
  | KB => exact absurd rfl hy
  | U3 => exact from_KA_near hKA _ hy (Or.inr (Or.inr (Or.inr (Or.inr rfl))))

/-- With the ring boundaries, the boundary of U3 holds U3 alone. -/
theorem own_is_U3 {k m : NMon} (h : (nested true).boundary m = some (.own k)) :
    m = .U3 := by
  cases m with
  | U3 => rfl
  | A1 => exact nomatch h
  | A2 => exact nomatch h
  | A3 => exact nomatch h
  | KA => exact nomatch h
  | B1 => exact nomatch h
  | B2 => exact nomatch h
  | B3 => exact nomatch h
  | KB => exact nomatch h

/-! ### The three statements -/

/-- Both are cases of `theorem_S_wide`: with or without the ring boundaries, the system is
of the wider class and meets its conditions. -/
theorem nested_is_wide (ringBoundaries : Bool) :
    Ordinary (nested ringBoundaries) ∧ SufficientWide (nested ringBoundaries) := by
  refine ⟨⟨fun _ h => h, rfl, rfl, rfl, rfl⟩, nested_sufficient ringBoundaries, ?_, ?_⟩
  · intro c p h
    exact nomatch h
  · intro bd m m' hne hm hm'
    cases ringBoundaries with
    | false =>
      have h₁ : some (NBd.own m) = some bd := hm
      have h₂ : some (NBd.own m') = some bd := hm'
      cases h₁
      cases h₂
      exact absurd rfl hne
    | true =>
      cases bd with
      | own k => exact absurd ((own_is_U3 hm).trans (own_is_U3 hm').symm) hne
      | ringA => exact ringA_answered
      | ringB => exact ringB_answered

/-- The interleaved rings on two levels have no gap at one fault per round (section 10.1,
checked instances). -/
theorem nested_noGap : NoGap (nested false) :=
  Widening.theorem_S_wide (nested false) rfl (nested_is_wide false).1 (nested_is_wide false).2

/-- The same with each base ring whole in one boundary, so that one step can stop an
entire ring (sections 2.7 and 10.1): no gap at one fault per round. -/
theorem nested_boundaries_noGap : NoGap (nested true) :=
  Widening.theorem_S_wide (nested true) rfl (nested_is_wide true).1 (nested_is_wide true).2

end NestedRings
end SelfObserving
