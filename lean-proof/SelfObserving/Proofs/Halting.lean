/-
Proofs for the section "How fast a halt must travel" of `Challenge.lean`: the count of
`Growth.lean` (`results.md`, section 8.2). Core Lean only. Imports the definitions of the
count and nothing else.
-/
import SelfObserving.Growth

namespace SelfObserving.Halting

/-! ## Reading the definitions -/

theorem iter_zero {α : Type} (f : α → α) (a : α) : iter f 0 a = a := rfl

theorem iter_succ {α : Type} (f : α → α) (k : Nat) (a : α) :
    iter f (k + 1) a = f (iter f k a) := rfl

theorem iter_one {α : Type} (f : α → α) (a : α) : iter f 1 a = f a := rfl

theorem iter_two {α : Type} (f : α → α) (a : α) : iter f 2 a = f (f a) := rfl

/-- A property kept by `f` is kept by any number of applications of `f`. -/
theorem iter_inv {α : Type} (f : α → α) (P : α → Prop) (hP : ∀ a, P a → P (f a)) :
    ∀ (k : Nat) (a : α), P a → P (iter f k a) := by
  intro k a ha
  induction k with
  | zero => exact ha
  | succ k ih => exact hP _ ih

theorem cascade_zero (c h n : Nat) : cascade c h n 0 = Spreading.start n := rfl

theorem cascade_succ (c h n t : Nat) :
    cascade c h n (t + 1) = Spreading.tick c h (cascade c h n t) := rfl

theorem cascade_add (c h n t k : Nat) :
    cascade c h n (t + k) = iter (Spreading.tick c h) k (cascade c h n t) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    show Spreading.tick c h (cascade c h n (t + k)) =
      Spreading.tick c h (iter (Spreading.tick c h) k (cascade c h n t))
    rw [ih]

theorem tick_eq (c h : Nat) (s : Spreading) :
    Spreading.tick c h s = Spreading.spread (iter (Spreading.hop c) h s) := rfl

theorem start_good (n : Nat) : (Spreading.start n).good = n - 1 := rfl
theorem start_bad (n : Nat) : (Spreading.start n).bad = 1 := rfl
theorem start_haltedBad (n : Nat) : (Spreading.start n).haltedBad = 0 := rfl
theorem start_frontier (n : Nat) : (Spreading.start n).frontier = 1 := rfl

theorem spread_good (s : Spreading) : s.spread.good = s.good - min s.bad s.good := rfl
theorem spread_bad (s : Spreading) : s.spread.bad = s.bad + min s.bad s.good := rfl
theorem spread_haltedBad (s : Spreading) : s.spread.haltedBad = s.haltedBad := rfl
theorem spread_frontier (s : Spreading) : s.spread.frontier = s.frontier := rfl

theorem hop_frontier (c : Nat) (s : Spreading) :
    (Spreading.hop c s).frontier = min (s.frontier * c) (s.good + s.bad) := rfl

theorem hop_good (c : Nat) (s : Spreading) :
    (Spreading.hop c s).good = s.good - min (s.frontier * c) (s.good + s.bad) := by
  show s.good - min (min (s.frontier * c) (s.good + s.bad)) s.good = _
  omega

theorem hop_bad (c : Nat) (s : Spreading) :
    (Spreading.hop c s).bad = s.bad - (min (s.frontier * c) (s.good + s.bad) - s.good) := by
  show s.bad - (min (s.frontier * c) (s.good + s.bad) -
    min (min (s.frontier * c) (s.good + s.bad)) s.good) = _
  omega

theorem hop_haltedBad (c : Nat) (s : Spreading) :
    (Spreading.hop c s).haltedBad =
      s.haltedBad + (min (s.frontier * c) (s.good + s.bad) - s.good) := by
  show s.haltedBad + (min (s.frontier * c) (s.good + s.bad) -
    min (min (s.frontier * c) (s.good + s.bad)) s.good) = _
  omega

theorem pow_two_succ (t : Nat) : 2 ^ (t + 1) = 2 * 2 ^ t := by
  rw [Nat.pow_succ, Nat.mul_comm]

theorem pow_two_pos (t : Nat) : 1 ≤ 2 ^ t := Nat.two_pow_pos t

/-! ## What holds for every `c` and `h` -/

/-- One hop: the damage is unchanged, nothing grows, a bad process is halted only when no
good one is left, and while a good one is left nothing bad has been halted. -/
theorem hop_gen (c : Nat) (s : Spreading) :
    (Spreading.hop c s).damage = s.damage ∧
    (Spreading.hop c s).good ≤ s.good ∧
    (Spreading.hop c s).bad ≤ s.bad ∧
    ((s.haltedBad ≠ 0 → s.good = 0) →
      (Spreading.hop c s).haltedBad ≠ 0 → (Spreading.hop c s).good = 0) ∧
    ((Spreading.hop c s).good ≠ 0 → (Spreading.hop c s).haltedBad = s.haltedBad) := by
  simp only [Spreading.damage, hop_good, hop_bad, hop_haltedBad]
  omega

/-- Any number of hops: the same. -/
theorem hops_gen (c : Nat) (k : Nat) (s : Spreading) :
    (iter (Spreading.hop c) k s).damage = s.damage ∧
    (iter (Spreading.hop c) k s).good ≤ s.good ∧
    (iter (Spreading.hop c) k s).bad ≤ s.bad ∧
    ((s.haltedBad ≠ 0 → s.good = 0) →
      (iter (Spreading.hop c) k s).haltedBad ≠ 0 → (iter (Spreading.hop c) k s).good = 0) ∧
    ((iter (Spreading.hop c) k s).good ≠ 0 →
      (iter (Spreading.hop c) k s).haltedBad = s.haltedBad) := by
  induction k with
  | zero => exact ⟨rfl, Nat.le_refl _, Nat.le_refl _, fun h => h, fun _ => rfl⟩
  | succ k ih =>
    rw [iter_succ]
    have h1 := hop_gen c (iter (Spreading.hop c) k s)
    generalize iter (Spreading.hop c) k s = s1 at ih h1
    simp only [Spreading.damage] at ih h1 ⊢
    omega

/-- One tick. -/
theorem tick_gen (c h : Nat) (s : Spreading) :
    s.damage ≤ (Spreading.tick c h s).damage ∧
    (Spreading.tick c h s).good ≤ s.good ∧
    ((s.haltedBad ≠ 0 → s.good = 0) →
      (Spreading.tick c h s).haltedBad ≠ 0 → (Spreading.tick c h s).good = 0) ∧
    (s.good = 0 → (Spreading.tick c h s).damage = s.damage) := by
  have h1 := hops_gen c h s
  rw [tick_eq]
  generalize iter (Spreading.hop c) h s = s1 at h1
  simp only [Spreading.damage, spread_good, spread_bad, spread_haltedBad] at h1 ⊢
  omega

/-- In every state the count reaches: something is bad, and a bad process has been halted
only if no good one is left running. -/
theorem cascade_gen (c h n : Nat) (t : Nat) :
    1 ≤ (cascade c h n t).damage ∧
    ((cascade c h n t).haltedBad ≠ 0 → (cascade c h n t).good = 0) := by
  induction t with
  | zero =>
    rw [cascade_zero]
    simp only [Spreading.damage, start_bad, start_haltedBad]
    omega
  | succ t ih =>
    rw [cascade_succ]
    have h1 := tick_gen c h (cascade c h n t)
    omega

/-- Once no good process is left, none is left later and the damage stays as it is. -/
theorem good_zero_stays (c h n s : Nat) (hs : (cascade c h n s).good = 0) (k : Nat) :
    (cascade c h n (s + k)).good = 0 ∧
    (cascade c h n (s + k)).damage = (cascade c h n s).damage := by
  induction k with
  | zero => exact ⟨hs, rfl⟩
  | succ k ih =>
    have h1 := tick_gen c h (cascade c h n (s + k))
    have e : cascade c h n (s + (k + 1)) = Spreading.tick c h (cascade c h n (s + k)) := rfl
    rw [e]
    omega

/-- When no bad process is running, no good one is either. -/
theorem end_good_zero (c h n T : Nat) (hT : (cascade c h n T).bad = 0) :
    (cascade c h n T).good = 0 := by
  have h1 := cascade_gen c h n T
  simp only [Spreading.damage] at h1
  omega

/-- The damage can be read at any tick at which no good process is left. -/
theorem damage_eq (c h n d s : Nat) (hd : CascadeDamage c h n d)
    (hs : (cascade c h n s).good = 0) : d = (cascade c h n s).damage := by
  obtain ⟨T, hT, _, rfl⟩ := hd
  have hg := end_good_zero c h n T hT
  rcases Nat.le_total s T with hle | hle
  · have h1 := (good_zero_stays c h n s hs (T - s)).2
    have e : s + (T - s) = T := by omega
    rw [e] at h1
    exact h1
  · have h1 := (good_zero_stays c h n T hg (s - T)).2
    have e : T + (s - T) = s := by omega
    rw [e] at h1
    exact h1.symm

/-! ## The window -/

theorem window_state (n w : Nat) (hn : 1 ≤ n) :
    (iter Spreading.spread w (Spreading.start n)).haltedBad = 0 ∧
    (iter Spreading.spread w (Spreading.start n)).bad = min (2 ^ w) n ∧
    (iter Spreading.spread w (Spreading.start n)).good +
      (iter Spreading.spread w (Spreading.start n)).bad = n := by
  induction w with
  | zero =>
    refine ⟨rfl, ?_, ?_⟩
    · show 1 = min 1 n
      omega
    · show n - 1 + 1 = n
      omega
  | succ w ih =>
    rw [iter_succ]
    have hp := pow_two_succ w
    generalize iter Spreading.spread w (Spreading.start n) = s at ih
    simp only [spread_good, spread_bad, spread_haltedBad]
    generalize 2 ^ w = p at ih hp
    generalize 2 ^ (w + 1) = p' at hp ⊢
    omega

theorem window_damage (n w : Nat) (hn : 1 ≤ n) : windowDamage n w = min (2 ^ w) n := by
  have h := window_state n w hn
  show (iter Spreading.spread w (Spreading.start n)).haltedBad +
    (iter Spreading.spread w (Spreading.start n)).bad = _
  omega

/-! ## The count ends -/

/-- One hop of a halt passed to at least one: the number running does not grow; while
something is running the frontier stays at least 1 and the hop halts at least one. -/
theorem hop_run (c : Nat) (hc : 1 ≤ c) (s : Spreading) :
    (Spreading.hop c s).good + (Spreading.hop c s).bad ≤ s.good + s.bad ∧
    ((1 ≤ s.frontier ∨ s.good + s.bad = 0) →
      (1 ≤ (Spreading.hop c s).frontier ∨
        (Spreading.hop c s).good + (Spreading.hop c s).bad = 0) ∧
      ((Spreading.hop c s).good + (Spreading.hop c s).bad + 1 ≤ s.good + s.bad ∨
        (Spreading.hop c s).good + (Spreading.hop c s).bad = 0)) := by
  have h1 : s.frontier ≤ s.frontier * c := Nat.le_mul_of_pos_right _ hc
  simp only [hop_frontier, hop_good, hop_bad]
  omega

theorem hops_run (c : Nat) (hc : 1 ≤ c) (k : Nat) (s : Spreading)
    (hs : 1 ≤ s.frontier ∨ s.good + s.bad = 0) :
    (iter (Spreading.hop c) k s).good + (iter (Spreading.hop c) k s).bad ≤ s.good + s.bad ∧
    (1 ≤ (iter (Spreading.hop c) k s).frontier ∨
      (iter (Spreading.hop c) k s).good + (iter (Spreading.hop c) k s).bad = 0) := by
  induction k with
  | zero => simp only [iter_zero]; omega
  | succ k ih =>
    rw [iter_succ]
    have h1 := hop_run c hc (iter (Spreading.hop c) k s)
    omega

theorem tick_run (c h : Nat) (hc : 1 ≤ c) (hh : 1 ≤ h) (s : Spreading)
    (hs : 1 ≤ s.frontier ∨ s.good + s.bad = 0) :
    (1 ≤ (Spreading.tick c h s).frontier ∨
      (Spreading.tick c h s).good + (Spreading.tick c h s).bad = 0) ∧
    ((Spreading.tick c h s).good + (Spreading.tick c h s).bad + 1 ≤ s.good + s.bad ∨
      (Spreading.tick c h s).good + (Spreading.tick c h s).bad = 0) := by
  obtain ⟨j, rfl⟩ : ∃ j, h = j + 1 := ⟨h - 1, by omega⟩
  rw [tick_eq, iter_succ]
  have h1 := hops_run c hc j s hs
  have h2 := hop_run c hc (iter (Spreading.hop c) j s)
  generalize Spreading.hop c (iter (Spreading.hop c) j s) = s2 at h2
  simp only [spread_good, spread_bad, spread_frontier]
  omega

theorem cascade_run (c h n : Nat) (hc : 1 ≤ c) (hh : 1 ≤ h) (hn : 1 ≤ n) (t : Nat) :
    (1 ≤ (cascade c h n t).frontier ∨ (cascade c h n t).good + (cascade c h n t).bad = 0) ∧
    ((cascade c h n t).good + (cascade c h n t).bad + t ≤ n ∨
      (cascade c h n t).good + (cascade c h n t).bad = 0) := by
  induction t with
  | zero =>
    rw [cascade_zero]
    simp only [start_good, start_bad, start_frontier]
    omega
  | succ t ih =>
    rw [cascade_succ]
    have h1 := tick_run c h hc hh (cascade c h n t) ih.1
    omega

/-- If a property of numbers holds somewhere, it holds at a first place. -/
theorem exists_first (P : Nat → Prop) : ∀ N, P N → ∃ T, P T ∧ ∀ t, t < T → ¬ P t := by
  intro N
  induction N using Nat.strongRecOn with
  | _ N ih =>
    intro hN
    by_cases h : ∃ t, t < N ∧ P t
    · obtain ⟨t, ht, hP⟩ := h
      exact ih t ht hP
    · exact ⟨N, hN, fun t ht hP => h ⟨t, ht, hP⟩⟩

theorem cascade_ends (c h n : Nat) (hc : 1 ≤ c) (hh : 1 ≤ h) (hn : 1 ≤ n) :
    ∃ d, CascadeDamage c h n d ∧ ∀ d', CascadeDamage c h n d' → d' = d := by
  have hz : (cascade c h n n).bad = 0 := by
    have := cascade_run c h n hc hh hn n
    omega
  obtain ⟨T, hT, hfirst⟩ := exists_first (fun t => (cascade c h n t).bad = 0) n hz
  refine ⟨(cascade c h n T).damage, ⟨T, hT, hfirst, rfl⟩, ?_⟩
  rintro d' ⟨T', hT', hfirst', rfl⟩
  have e : T' = T := by
    rcases Nat.lt_trichotomy T' T with h1 | h1 | h1
    · exact absurd hT' (hfirst T' h1)
    · exact h1
    · exact absurd hT (hfirst' T h1)
  rw [e]

/-- The damage is the damage at any tick at which no good process is left: a way to show
`CascadeDamage` without finding the last tick. -/
theorem damage_of (c h n s d : Nat) (hc : 1 ≤ c) (hh : 1 ≤ h) (hn : 1 ≤ n)
    (hs : (cascade c h n s).good = 0) (hd : d = (cascade c h n s).damage) :
    CascadeDamage c h n d := by
  obtain ⟨d0, h0, _⟩ := cascade_ends c h n hc hh hn
  have e := damage_eq c h n d0 s h0 hs
  rw [hd, ← e]
  exact h0

/-! ## The reach of the cascade -/

theorem hop_reach (c N j : Nat) (s : Spreading)
    (hs : s.frontier ≤ c ^ j ∧ N + 1 ≤ s.good + s.bad + geom c j) :
    (Spreading.hop c s).frontier ≤ c ^ (j + 1) ∧
    N + 1 ≤ (Spreading.hop c s).good + (Spreading.hop c s).bad + geom c (j + 1) := by
  have h1 : s.frontier * c ≤ c ^ j * c := Nat.mul_le_mul_right c hs.1
  have h2 : c ^ (j + 1) = c ^ j * c := Nat.pow_succ c j
  have h3 : geom c (j + 1) = geom c j + c ^ (j + 1) := rfl
  simp only [hop_frontier, hop_good, hop_bad]
  omega

theorem hops_reach (c N j k : Nat) (s : Spreading)
    (hs : s.frontier ≤ c ^ j ∧ N + 1 ≤ s.good + s.bad + geom c j) :
    (iter (Spreading.hop c) k s).frontier ≤ c ^ (j + k) ∧
    N + 1 ≤ (iter (Spreading.hop c) k s).good + (iter (Spreading.hop c) k s).bad +
      geom c (j + k) := by
  induction k with
  | zero => exact hs
  | succ k ih => exact hop_reach c N (j + k) _ ih

theorem cascade_reach_frontier (c h n t : Nat) (hn : 1 ≤ n) :
    (cascade c h n t).frontier ≤ c ^ (h * t) ∧
    n + 1 ≤ (cascade c h n t).good + (cascade c h n t).bad + geom c (h * t) := by
  induction t with
  | zero =>
    rw [cascade_zero]
    have h1 : geom c (h * 0) = 1 := rfl
    have h2 : c ^ (h * 0) = 1 := rfl
    simp only [start_good, start_bad, start_frontier]
    omega
  | succ t ih =>
    rw [cascade_succ, tick_eq]
    have h1 := hops_reach c n (h * t) h (cascade c h n t) ih
    have e : h * (t + 1) = h * t + h := Nat.mul_succ h t
    rw [e]
    generalize iter (Spreading.hop c) h (cascade c h n t) = s1 at h1
    simp only [spread_good, spread_bad, spread_frontier]
    omega

theorem cascade_reach (c h n t : Nat) (hn : 1 ≤ n) :
    n + 1 ≤ (cascade c h n t).good + (cascade c h n t).bad + geom c (h * t) :=
  (cascade_reach_frontier c h n t hn).2

theorem geom_one (j : Nat) : geom 1 j = j + 1 := by
  induction j with
  | zero => rfl
  | succ j ih =>
    show geom 1 j + 1 ^ (j + 1) = j + 1 + 1
    rw [ih, Nat.one_pow]

theorem geom_two (j : Nat) : geom 2 j + 1 = 2 ^ (j + 1) := by
  induction j with
  | zero => rfl
  | succ j ih =>
    have h1 : geom 2 (j + 1) = geom 2 j + 2 ^ (j + 1) := rfl
    have h2 := pow_two_succ (j + 1)
    omega

/-! ## The chain: a lower bound on the damage -/

theorem chain_hop (s : Spreading) (hs : s.frontier ≤ 1) :
    (Spreading.hop 1 s).frontier ≤ 1 ∧ s.good ≤ (Spreading.hop 1 s).good + 1 := by
  simp only [hop_frontier, hop_good]
  omega

/-- A chain halts at most one process per hop. -/
theorem chain_hops (k : Nat) (s : Spreading) (hs : s.frontier ≤ 1) :
    (iter (Spreading.hop 1) k s).frontier ≤ 1 ∧
    s.good ≤ (iter (Spreading.hop 1) k s).good + k := by
  induction k with
  | zero => exact ⟨hs, Nat.le_refl _⟩
  | succ k ih =>
    rw [iter_succ]
    have h1 := chain_hop (iter (Spreading.hop 1) k s) ih.1
    omega

/-- While a good process is left at the start of tick `t`, at least `2 ^ t` bad ones are
running, so `t < L`; and at most `h` good processes are halted in a tick. So at most
`h * min t L` good processes have been halted by tick `t`. -/
theorem chain_inv (h n L : Nat) (hn : 1 ≤ n) (hL : n ≤ 2 ^ L) (t : Nat) :
    (cascade 1 h n t).frontier ≤ 1 ∧
    ((cascade 1 h n t).good ≠ 0 → 2 ^ t ≤ (cascade 1 h n t).bad) ∧
    (cascade 1 h n t).good + (cascade 1 h n t).bad + (cascade 1 h n t).haltedBad ≤ n ∧
    n ≤ (cascade 1 h n t).good + (cascade 1 h n t).bad + (cascade 1 h n t).haltedBad +
      h * min t L := by
  induction t with
  | zero =>
    rw [cascade_zero]
    have h0 : (2 : Nat) ^ 0 = 1 := rfl
    simp only [start_good, start_bad, start_haltedBad, start_frontier, h0]
    omega
  | succ t ih =>
    rw [cascade_succ, tick_eq]
    have h1 := hops_gen 1 h (cascade 1 h n t)
    have h2 := chain_hops h (cascade 1 h n t) ih.1
    have hp := pow_two_succ t
    generalize cascade 1 h n t = s at ih h1 h2
    generalize iter (Spreading.hop 1) h s = s1 at h1 h2
    simp only [Spreading.damage, spread_good, spread_bad, spread_haltedBad,
      spread_frontier] at h1 ⊢
    by_cases hg : s.good = 0
    · have hm : h * min t L ≤ h * min (t + 1) L := Nat.mul_le_mul_left h (by omega)
      omega
    · have htL : t < L := by
        apply Nat.lt_of_not_le
        intro hle
        have := Nat.pow_le_pow_right (by decide : 0 < 2) hle
        omega
      have e1 : min t L = t := by omega
      have e2 : min (t + 1) L = t + 1 := by omega
      have e3 : h * (t + 1) = h * t + h := Nat.mul_succ h t
      rw [e1] at ih
      rw [e2, e3]
      omega

theorem chain_bound (h n L d : Nat) (hn : 2 ≤ n) (hL : n ≤ 2 ^ L)
    (hd : CascadeDamage 1 h n d) : n ≤ d + h * L := by
  obtain ⟨T, hT, _, rfl⟩ := hd
  have hg := end_good_zero 1 h n T hT
  have h1 := chain_inv h n L (by omega) hL T
  have hm : h * min T L ≤ h * L := Nat.mul_le_mul_left h (Nat.min_le_right T L)
  simp only [Spreading.damage]
  omega

/-! ## The chain: the state after `t` ticks, in closed form -/

/-- Hops of a chain while good processes are left: one good process each. -/
theorem chain_hops_good (p hb : Nat) : ∀ (j G : Nat), j ≤ G →
    iter (Spreading.hop 1) j ⟨G, p, hb, 1⟩ = ⟨G - j, p, hb, 1⟩ := by
  intro j
  induction j with
  | zero => intro G _; rfl
  | succ j ih =>
    intro G hj
    rw [iter_succ, ih G (by omega)]
    simp only [Spreading.hop, Spreading.mk.injEq]
    omega

/-- Hops of a chain when no good process is left: one bad process each. -/
theorem chain_hops_bad : ∀ (j b hb : Nat), j ≤ b →
    iter (Spreading.hop 1) j ⟨0, b, hb, 1⟩ = ⟨0, b - j, hb + j, 1⟩ := by
  intro j
  induction j with
  | zero => intro b hb _; rfl
  | succ j ih =>
    intro b hb hj
    rw [iter_succ, ih b hb (by omega)]
    simp only [Spreading.hop, Spreading.mk.injEq]
    omega

/-- The first phase of a chain. While `2 ^ t + h * t ≤ n`, the state after `t` ticks is:
`2 ^ t` bad running, `h * t` good halted, nothing bad halted. -/
theorem chain_first (h n : Nat) : ∀ t, 2 ^ t + h * t ≤ n →
    cascade 1 h n t = ⟨n - 2 ^ t - h * t, 2 ^ t, 0, 1⟩ := by
  intro t
  induction t with
  | zero =>
    intro h0
    have e0 : (2 : Nat) ^ 0 = 1 := rfl
    rw [e0] at h0 ⊢
    show Spreading.start n = _
    simp only [Spreading.start, Spreading.mk.injEq, and_true]
    omega
  | succ t ih =>
    intro ht
    have hp := pow_two_succ t
    have hm : h * (t + 1) = h * t + h := Nat.mul_succ h t
    rw [cascade_succ, ih (by omega), tick_eq, chain_hops_good _ _ h _ (by omega)]
    simp only [Spreading.spread, Spreading.mk.injEq, and_true]
    omega

/-- The tick at which the good processes of a chain run out, in the spread. -/
theorem chain_last (h n t : Nat) (h1 : 2 ^ t + h * (t + 1) ≤ n)
    (h2 : n ≤ 2 ^ (t + 1) + h * (t + 1)) :
    cascade 1 h n (t + 1) = ⟨0, n - h * (t + 1), 0, 1⟩ := by
  have hp := pow_two_succ t
  have hm : h * (t + 1) = h * t + h := Nat.mul_succ h t
  rw [cascade_succ, chain_first h n t (by omega), tick_eq, chain_hops_good _ _ h _ (by omega)]
  simp only [Spreading.spread, Spreading.mk.injEq, and_true]
  omega

/-- The second phase of a chain: no good process left, `h` bad ones halted per tick. -/
theorem chain_ticks_bad (h : Nat) : ∀ (j b hb : Nat), h * j ≤ b →
    iter (Spreading.tick 1 h) j ⟨0, b, hb, 1⟩ = ⟨0, b - h * j, hb + h * j, 1⟩ := by
  intro j
  induction j with
  | zero => intro b hb _; rfl
  | succ j ih =>
    intro b hb hj
    have hm : h * (j + 1) = h * j + h := Nat.mul_succ h j
    rw [iter_succ, ih b hb (by omega), tick_eq, chain_hops_bad h _ _ (by omega)]
    simp only [Spreading.spread, Spreading.mk.injEq, and_true]
    omega

/-- The count of a chain, in closed form, when the good processes run out in the spread
of tick `t` and the bad ones left are a whole number `m` of ticks' work: the damage is
`n - h * (t + 1)` and the count ends at tick `t + 1 + m`. -/
theorem chain_closed (h n t m d : Nat) (hh : 1 ≤ h) (h1 : 2 ^ t + h * (t + 1) ≤ n)
    (h2 : n ≤ 2 ^ (t + 1) + h * (t + 1)) (hn : n = h * (t + 1) + d) (hd : d = h * m) :
    CascadeDamage 1 h n d := by
  have hlast := chain_last h n t h1 h2
  have hend : ∀ j, j ≤ m → cascade 1 h n (t + 1 + j) = ⟨0, d - h * j, h * j, 1⟩ := by
    intro j hj
    have hjm : h * j ≤ h * m := Nat.mul_le_mul_left h hj
    rw [cascade_add, hlast, chain_ticks_bad h j _ _ (by omega)]
    simp only [Spreading.mk.injEq, true_and, and_true]
    omega
  refine ⟨t + 1 + m, ?_, ?_, ?_⟩
  · rw [hend m (Nat.le_refl m)]
    show d - h * m = 0
    omega
  · intro s hs
    by_cases hst : s ≤ t
    · have hps : 2 ^ s ≤ 2 ^ t := Nat.pow_le_pow_right (by decide) hst
      have hms : h * s ≤ h * t := Nat.mul_le_mul_left h hst
      have hm' : h * (t + 1) = h * t + h := Nat.mul_succ h t
      rw [chain_first h n s (by omega)]
      show 2 ^ s ≠ 0
      have := pow_two_pos s
      omega
    · obtain ⟨j, rfl⟩ : ∃ j, s = t + 1 + j := ⟨s - (t + 1), by omega⟩
      have hj : j + 1 ≤ m := by omega
      have hjm : h * (j + 1) ≤ h * m := Nat.mul_le_mul_left h hj
      have hm' : h * (j + 1) = h * j + h := Nat.mul_succ h j
      rw [hend j (by omega)]
      show d - h * j ≠ 0
      omega
  · rw [hend m (Nat.le_refl m)]
    show d = h * m + (d - h * m)
    omega

/-! ## A halt that doubles, at two hops per tick -/

theorem sq_succ (d : Nat) : (d + 1) * (d + 1) = d * d + 2 * d + 1 := by
  rw [Nat.add_mul, Nat.mul_add]
  omega

theorem two_mul_sq (p : Nat) : 2 * p * (2 * p) = 4 * (p * p) := by
  rw [Nat.mul_mul_mul_comm]

/-- One tick from a state in which the fault has not been capped (`p` bad running,
frontier `p * p`, nothing bad halted): either the next state is of the same kind with
`2 * p`, or the good processes have run out and the damage is within the bound. -/
theorem two_step (n t p : Nat) (s : Spreading) (hp : 1 ≤ p) (ht : t < p) (hb : s.bad = p)
    (hf : s.frontier = p * p) (hg : s.good + p + 2 * (p * p) = n + 2)
    (hh : s.haltedBad = 0) (h2 : 2 ≤ s.good + s.bad) :
    (∃ p', 1 ≤ p' ∧ t + 1 < p' ∧ (Spreading.tick 2 2 s).bad = p' ∧
      (Spreading.tick 2 2 s).frontier = p' * p' ∧
      (Spreading.tick 2 2 s).good + p' + 2 * (p' * p') = n + 2 ∧
      (Spreading.tick 2 2 s).haltedBad = 0 ∧
      2 ≤ (Spreading.tick 2 2 s).good + (Spreading.tick 2 2 s).bad) ∨
    ((Spreading.tick 2 2 s).good = 0 ∧
      2 * ((Spreading.tick 2 2 s).damage * (Spreading.tick 2 2 s).damage) ≤ n) := by
  have e4 := two_mul_sq p
  generalize hq : p * p = q at hf hg e4
  by_cases hA : 6 * q + p ≤ s.good
  · left
    refine ⟨2 * p, by omega, by omega, ?_⟩
    rw [e4, tick_eq, iter_two]
    simp only [spread_good, spread_bad, spread_haltedBad, spread_frontier, hop_good, hop_bad,
      hop_haltedBad, hop_frontier]
    omega
  · right
    have key : (Spreading.tick 2 2 s).good = 0 ∧
        (((Spreading.tick 2 2 s).damage + 1 ≤ 2 * p ∧
            n + 2 = (Spreading.tick 2 2 s).damage + 8 * q) ∨
          ((Spreading.tick 2 2 s).damage = p ∧ 2 * q ≤ n)) := by
      rw [tick_eq, iter_two]
      simp only [Spreading.damage, spread_good, spread_bad, spread_haltedBad, hop_good,
        hop_bad, hop_haltedBad, hop_frontier]
      omega
    generalize (Spreading.tick 2 2 s).damage = d at key ⊢
    refine ⟨key.1, ?_⟩
    rcases key.2 with ⟨k1, k2⟩ | ⟨k1, k2⟩
    · have h5 : (d + 1) * (d + 1) ≤ 2 * p * (2 * p) := Nat.mul_le_mul k1 k1
      rw [sq_succ, e4] at h5
      omega
    · rw [k1, hq]
      omega

theorem two_main (n : Nat) (hn : 2 ≤ n) (t : Nat) :
    (∃ p, 1 ≤ p ∧ t < p ∧ (cascade 2 2 n t).bad = p ∧ (cascade 2 2 n t).frontier = p * p ∧
      (cascade 2 2 n t).good + p + 2 * (p * p) = n + 2 ∧ (cascade 2 2 n t).haltedBad = 0 ∧
      2 ≤ (cascade 2 2 n t).good + (cascade 2 2 n t).bad) ∨
    ((cascade 2 2 n t).good = 0 ∧
      2 * ((cascade 2 2 n t).damage * (cascade 2 2 n t).damage) ≤ n) := by
  induction t with
  | zero =>
    left
    refine ⟨1, Nat.le_refl 1, by decide, ?_⟩
    rw [cascade_zero]
    simp only [start_good, start_bad, start_haltedBad, start_frontier, true_and]
    omega
  | succ t ih =>
    rw [cascade_succ]
    rcases ih with ⟨p, hp, ht, hb, hf, hg, hh, h2⟩ | ⟨hg, hd⟩
    · exact two_step n t p _ hp ht hb hf hg hh h2
    · right
      have h1 := tick_gen 2 2 (cascade 2 2 n t)
      rw [h1.2.2.2 hg]
      exact ⟨by omega, hd⟩

theorem doubling_two_hops_bound (n d : Nat) (hn : 2 ≤ n) (hd : CascadeDamage 2 2 n d) :
    2 * (d * d) ≤ n := by
  rcases two_main n hn (n + 2) with ⟨p, hp, ht, hb, hf, hg, hh, h2⟩ | ⟨hg, hb⟩
  · omega
  · rw [damage_eq 2 2 n d (n + 2) hd hg]
    exact hb

/-! ## A halt that doubles, at one hop per tick -/

/-- While `3 * 2 ^ t ≤ n + 2`, the state after `t` ticks is: `2 ^ t` bad running, frontier
`2 ^ t`, `n + 2 - 3 * 2 ^ t` good running, nothing bad halted. For every `n` of 1 or
more. -/
theorem one_first (n : Nat) (hn : 1 ≤ n) : ∀ t, 3 * 2 ^ t ≤ n + 2 →
    (cascade 2 1 n t).bad = 2 ^ t ∧ (cascade 2 1 n t).frontier = 2 ^ t ∧
    (cascade 2 1 n t).good + 3 * 2 ^ t = n + 2 ∧ (cascade 2 1 n t).haltedBad = 0 := by
  intro t
  induction t with
  | zero =>
    intro _
    have e0 : (2 : Nat) ^ 0 = 1 := rfl
    rw [cascade_zero, e0]
    simp only [start_good, start_bad, start_haltedBad, start_frontier, true_and, and_true]
    omega
  | succ t ih =>
    intro ht
    have hp := pow_two_succ t
    have ih' := ih (by omega)
    rw [cascade_succ, tick_eq, iter_one]
    generalize cascade 2 1 n t = s at ih'
    simp only [spread_good, spread_bad, spread_haltedBad, spread_frontier, hop_good, hop_bad,
      hop_haltedBad, hop_frontier]
    omega

/-- The damage of a halt that doubles at one hop per tick, in closed form, for every `n`
of 1 or more. Let `p = 2 ^ t` be the power of two with `3 * p ≤ n + 2 < 6 * p`. Then the
damage is `n + 2 - 4 * p` if `5 * p ≤ n + 2`, and `p` otherwise. -/
theorem one_closed (n t d : Nat) (hn : 1 ≤ n) (h1 : 3 * 2 ^ t ≤ n + 2)
    (h2 : n + 2 < 6 * 2 ^ t) (hd : CascadeDamage 2 1 n d) :
    (5 * 2 ^ t ≤ n + 2 → d = n + 2 - 4 * 2 ^ t) ∧ (n + 2 < 5 * 2 ^ t → d = 2 ^ t) := by
  have hU := one_first n hn t h1
  have key : (cascade 2 1 n (t + 1)).good = 0 ∧
      (5 * 2 ^ t ≤ n + 2 → (cascade 2 1 n (t + 1)).damage = n + 2 - 4 * 2 ^ t) ∧
      (n + 2 < 5 * 2 ^ t → (cascade 2 1 n (t + 1)).damage = 2 ^ t) := by
    rw [cascade_succ, tick_eq, iter_one]
    generalize cascade 2 1 n t = s at hU
    simp only [Spreading.damage, spread_good, spread_bad, spread_haltedBad, hop_good, hop_bad,
      hop_haltedBad]
    omega
  have e := damage_eq 2 1 n d (t + 1) hd key.1
  rw [e]
  exact key.2

theorem doubling_one_hop_exact (k d : Nat) (hk : 3 ≤ k) (hd : CascadeDamage 2 1 (2 ^ k) d) :
    4 * d = 2 ^ k := by
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 3 := ⟨k - 3, by omega⟩
  have e1 : 2 ^ (j + 1) = 2 * 2 ^ j := pow_two_succ j
  have e2 : 2 ^ (j + 2) = 2 * 2 ^ (j + 1) := pow_two_succ (j + 1)
  have e3 : 2 ^ (j + 3) = 2 * 2 ^ (j + 2) := pow_two_succ (j + 2)
  have hp := pow_two_pos j
  have h := one_closed (2 ^ (j + 3)) (j + 1) d (by omega) (by omega) (by omega) hd
  omega

theorem lt_pow_two (t : Nat) : t < 2 ^ t := by
  induction t with
  | zero => exact Nat.zero_lt_one
  | succ t ih =>
    have hp := pow_two_succ t
    omega

/-- For every `n` of 1 or more there is a power of two `p = 2 ^ t` with
`3 * p ≤ n + 2 < 6 * p`: the first `t` with `n + 2 < 6 * 2 ^ t`. -/
theorem one_tick_exists (n : Nat) (hn : 1 ≤ n) :
    ∃ t, 3 * 2 ^ t ≤ n + 2 ∧ n + 2 < 6 * 2 ^ t := by
  have hN : n + 2 < 6 * 2 ^ (n + 2) := by
    have := lt_pow_two (n + 2)
    omega
  obtain ⟨T, hT, hfirst⟩ := exists_first (fun t => n + 2 < 6 * 2 ^ t) (n + 2) hN
  refine ⟨T, ?_, hT⟩
  cases T with
  | zero =>
    have e0 : (2 : Nat) ^ 0 = 1 := rfl
    rw [e0]
    omega
  | succ j =>
    have h1 : ¬ (n + 2 < 6 * 2 ^ j) := hfirst j (Nat.lt_succ_self j)
    have hp := pow_two_succ j
    omega

/-- A power of two is 1, 2, or at least 4. -/
theorem pow_two_small_or_big (t : Nat) : 2 ^ t ≤ 2 ∨ 4 ≤ 2 ^ t := by
  cases t with
  | zero => left; decide
  | succ t =>
    cases t with
    | zero => left; decide
    | succ j =>
      right
      have e1 : 2 ^ (j + 1) = 2 * 2 ^ j := pow_two_succ j
      have e2 : 2 ^ (j + 1 + 1) = 2 * 2 ^ (j + 1) := pow_two_succ (j + 1)
      have hp := pow_two_pos j
      omega

/-- A halt that doubles, at one hop per tick, loses between a fifth and two fifths of the
system for every `n` of 8 or more, with no limit above. -/
theorem doubling_one_hop_range_all (n d : Nat) (hlo : 8 ≤ n) (hd : CascadeDamage 2 1 n d) :
    n ≤ 5 * d ∧ 5 * d ≤ 2 * n := by
  obtain ⟨t, h1, h2⟩ := one_tick_exists n (by omega)
  have h := one_closed n t d (by omega) h1 h2 hd
  have hp := pow_two_small_or_big t
  generalize 2 ^ t = p at h1 h2 h hp
  omega

theorem doubling_one_hop_range (n d : Nat) (hlo : 8 ≤ n) (hhi : n ≤ 3000)
    (hd : CascadeDamage 2 1 n d) : n ≤ 5 * d ∧ 5 * d ≤ 2 * n := by
  -- `hhi` is not needed: the bound holds for every `n` of 8 or more.
  have _ := hhi
  exact doubling_one_hop_range_all n d hlo hd

/-! ## The table -/

theorem halt_table_together :
    windowDamage 1024 0 = 1 ∧ windowDamage 1048576 0 = 1 ∧
    windowDamage 1024 5 = 32 ∧ windowDamage 1048576 5 = 32 :=
  ⟨(window_damage 1024 0 (by decide)).trans (by decide),
   (window_damage 1048576 0 (by decide)).trans (by decide),
   (window_damage 1024 5 (by decide)).trans (by decide),
   (window_damage 1048576 5 (by decide)).trans (by decide)⟩

theorem halt_table_chain :
    CascadeDamage 1 1 1024 1014 ∧ CascadeDamage 1 1 1048576 1048556 ∧
    CascadeDamage 1 128 1024 128 ∧ CascadeDamage 1 128 1048576 1046016 :=
  ⟨chain_closed 1 1024 9 1014 1014 (by decide) (by decide) (by decide) (by decide)
     (by decide),
   chain_closed 1 1048576 19 1048556 1048556 (by decide) (by decide) (by decide) (by decide)
     (by decide),
   chain_closed 128 1024 6 1 128 (by decide) (by decide) (by decide) (by decide) (by decide),
   chain_closed 128 1048576 19 8172 1046016 (by decide) (by decide) (by decide) (by decide)
     (by decide)⟩

theorem halt_table_doubling :
    CascadeDamage 2 1 1024 256 ∧ CascadeDamage 2 1 1048576 262144 ∧
    CascadeDamage 2 2 1024 16 ∧ CascadeDamage 2 2 1048576 512 ∧
    CascadeDamage 2 4 1024 4 ∧ CascadeDamage 2 4 1048576 16 := by
  refine ⟨⟨10, ?_, ?_, ?_⟩, ⟨20, ?_, ?_, ?_⟩, ⟨5, ?_, ?_, ?_⟩, ⟨10, ?_, ?_, ?_⟩,
    ⟨3, ?_, ?_, ?_⟩, ⟨5, ?_, ?_, ?_⟩⟩ <;> decide

end SelfObserving.Halting
