/-
The ring one level up, at any number of levels (`Tower.lean`): `tower_is_connected`,
`tower_gap`, `tower_boundaries_is_wide`, `tower_boundaries_noGap` and
`tower_one_level_boundaries_gap`. Nothing outside this project is imported.

A monitor of the tower is a list of at most `n` entries: `[]` is the top coordinator and
`i :: p` is member `i` of the ring that `p` coordinates. So the monitors above `p` are its
proper suffixes, and the monitors beneath `z` are the lists that `z` is a proper suffix
of. The file has these parts:

- paths in general: they compose, and a path outside a set avoids each monitor of it;
- the connections of the tower, and what they carry under either reading: a coordinator
  and each of its members watch each other and report to each other;
- the four monitors of a ring as a list;
- paths in the tower: up from a monitor to one above it, down from a monitor to one
  beneath it, and round the cycle of a ring, each outside a set of names that no name on
  the way is in;
- the four conditions of Theorem S for the tower, with any boundaries;
- which monitors have which boundary when each base ring is whole in one;
- the five statements.
-/
import SelfObserving.AnyRate
import SelfObserving.Tower
import SelfObserving.Proofs.Necessity
import SelfObserving.Proofs.Widening

namespace SelfObserving
namespace TowerRings

/-! ### Paths and links in general -/

section General

variable {M W B S : Type}

/-- Paths outside `Z` compose. -/
theorem ro_trans {sys : System M W B S} {Z : M → Prop} {x y y' : M}
    (h₁ : ReachOutside sys Z x y) (h₂ : ReachOutside sys Z y y') :
    ReachOutside sys Z x y' := by
  induction h₂ with
  | refl _ => exact h₁
  | step _ hf hz ih => exact .step ih hf hz

/-- A path outside a set is a path outside any smaller set. -/
theorem ro_mono {sys : System M W B S} {Z Z' : M → Prop} {x y : M}
    (h : ReachOutside sys Z x y) (hz : ∀ m, Z' m → Z m) : ReachOutside sys Z' x y := by
  induction h with
  | refl hx => exact .refl (fun h' => hx (hz _ h'))
  | step _ hf hy ih => exact .step ih hf (fun h' => hy (hz _ h'))

/-- A path outside a set that holds `z` is a path that avoids `z`. -/
theorem ra_of_ro {sys : System M W B S} {Z : M → Prop} {z x y : M} (hz : Z z)
    (h : ReachOutside sys Z x y) : ReachAvoiding sys z x y := by
  induction h with
  | refl hx => exact .refl (fun e => hx (e ▸ hz))
  | step _ hf hy ih => exact .step ih hf (fun e => hy (e ▸ hz))

/-- A path outside any set is a path. -/
theorem reach_of_ro {sys : System M W B S} {Z : M → Prop} {x y : M}
    (h : ReachOutside sys Z x y) : Reach sys x y := by
  induction h with
  | refl _ => exact .refl _
  | step _ hf _ ih => exact .step ih hf

/-- `Paired` is symmetric. -/
theorem paired_symm {sys : System M W B S} {a b : M} (h : Paired sys a b) :
    Paired sys b a :=
  ⟨h.2.1, h.1, h.2.2.2, h.2.2.1⟩

/-- `Linked` is transitive. -/
theorem linked_trans {sys : System M W B S} {a b c : M} (h₁ : Linked sys a b)
    (h₂ : Linked sys b c) : Linked sys a c := by
  induction h₂ with
  | refl => exact h₁
  | step _ hp ih => exact .step ih hp

/-- `Linked` is symmetric. -/
theorem linked_symm {sys : System M W B S} {a b : M} (h : Linked sys a b) :
    Linked sys b a := by
  induction h with
  | refl => exact .refl _
  | step _ hp ih => exact linked_trans (.step (.refl _) (paired_symm hp)) ih

end General

/-! ### The connections of the tower -/

/-- The coordinator `p` is connected to its member `i`. -/
theorem conn_down (i : Fin 3) (p : List (Fin 3)) : towerConn p (i :: p) :=
  Or.inl ⟨i, rfl⟩

/-- The member `i` of `p` is connected to its coordinator `p`. -/
theorem conn_up (i : Fin 3) (p : List (Fin 3)) : towerConn (i :: p) p :=
  Or.inr (Or.inl ⟨i, rfl⟩)

/-- The member `i` of `p` is connected to the next member in the cycle. -/
theorem conn_next (i : Fin 3) (p : List (Fin 3)) : towerConn (i :: p) ((i + 1) :: p) :=
  Or.inr (Or.inr ⟨i, p, rfl, rfl⟩)

/-- The name without its first entry is no longer than the name. -/
theorem len_tail {i : Fin 3} {p : List (Fin 3)} {n : Nat} (h : (i :: p).length ≤ n) :
    p.length ≤ n :=
  Nat.le_of_succ_le h

/-- Every entry is 0, 1 or 2. -/
theorem fin3 (i : Fin 3) : i = 0 ∨ i = 1 ∨ i = 2 := by
  revert i
  decide

/-- Two monitors connected both ways: under either reading the first watches the
second. -/
theorem watches_of_conn (rd : Reading) (n : Nat) (b : Bool) (f : Nat) {x y : TowerMon n}
    (h₁ : towerConn x.val y.val) (h₂ : towerConn y.val x.val) :
    Watches (tower rd n b f) x y := by
  cases rd
  · exact ⟨h₂, h₂⟩
  · exact ⟨h₁, h₁⟩

/-- A coordinator and each of its members watch each other and report to each other,
under either reading. -/
theorem paired_member (rd : Reading) (n : Nat) (b : Bool) (f : Nat) (i : Fin 3)
    (p : List (Fin 3)) (h : (i :: p).length ≤ n) :
    Paired (tower rd n b f) ⟨p, len_tail h⟩ ⟨i :: p, h⟩ :=
  ⟨watches_of_conn rd n b f (conn_down i p) (conn_up i p),
   watches_of_conn rd n b f (conn_up i p) (conn_down i p), conn_down i p, conn_up i p⟩

/-- The top coordinator is linked to every monitor. -/
theorem linked_top (rd : Reading) (n : Nat) (b : Bool) (f : Nat) (p : List (Fin 3)) :
    ∀ hp : p.length ≤ n, Linked (tower rd n b f) ⟨[], Nat.zero_le n⟩ ⟨p, hp⟩ := by
  induction p with
  | nil => intro _; exact .refl _
  | cons i p ih => intro hp; exact .step (ih (len_tail hp)) (paired_member rd n b f i p hp)

/-- Any two monitors are linked. -/
theorem linked_all (rd : Reading) (n : Nat) (b : Bool) (f : Nat) (x y : TowerMon n) :
    Linked (tower rd n b f) x y :=
  linked_trans (linked_symm (linked_top rd n b f x.val x.property))
    (linked_top rd n b f y.val y.property)

/-! ### The four monitors of a ring -/

/-- The four monitors of the ring that `q` coordinates: `q` and its three members. -/
def ringList {n : Nat} (q : List (Fin 3)) (h : q.length + 1 ≤ n) : List (TowerMon n) :=
  [⟨q, Nat.le_of_succ_le h⟩, ⟨0 :: q, h⟩, ⟨1 :: q, h⟩, ⟨2 :: q, h⟩]

theorem ringList_length {n : Nat} (q : List (Fin 3)) (h : q.length + 1 ≤ n) :
    (ringList (n := n) q h).length = 4 := rfl

/-- The four are different. -/
theorem ringList_nodup {n : Nat} (q : List (Fin 3)) (h : q.length + 1 ≤ n) :
    (ringList (n := n) q h).Nodup := by
  have h0 : ∀ i : Fin 3, q ≠ i :: q := fun i e => List.cons_ne_self i q e.symm
  simp [ringList, Subtype.ext_iff, h0]

/-- Each of the four is in the ring. -/
theorem inRing_of_mem {n : Nat} {q : List (Fin 3)} {h : q.length + 1 ≤ n} {m : TowerMon n}
    (hm : m ∈ ringList q h) : InRing q m.val := by
  simp only [ringList, List.mem_cons, List.not_mem_nil, or_false] at hm
  rcases hm with rfl | rfl | rfl | rfl
  · exact Or.inl rfl
  · exact Or.inr ⟨0, rfl⟩
  · exact Or.inr ⟨1, rfl⟩
  · exact Or.inr ⟨2, rfl⟩

/-- Every monitor of the ring is one of the four. -/
theorem mem_of_inRing {n : Nat} {q : List (Fin 3)} (h : q.length + 1 ≤ n) {m : TowerMon n}
    (hm : InRing q m.val) : m ∈ ringList q h := by
  obtain ⟨v, hv⟩ := m
  rcases hm with e | ⟨i, e⟩
  · have e' : v = q := e
    subst e'
    simp [ringList]
  · have e' : v = i :: q := e
    subst e'
    rcases fin3 i with rfl | rfl | rfl <;> simp [ringList]

/-! ### Paths in the tower -/

section Paths

variable (rd : Reading) (n : Nat) (b : Bool) (f : Nat) (Z : List (Fin 3) → Prop)

/-- Down from `p` to a monitor `y` that is `p` or beneath it, when no name from `p` to `y`
is in `Z`. -/
theorem ro_down (p : List (Fin 3)) (hp : p.length ≤ n) (y : List (Fin 3)) :
    ∀ hy : y.length ≤ n, p <:+ y → (∀ s, p <:+ s → s <:+ y → ¬ Z s) →
      ReachOutside (tower rd n b f) (fun m => Z m.val) ⟨p, hp⟩ ⟨y, hy⟩ := by
  induction y with
  | nil =>
    intro hy hpy hc
    have e : p = [] := List.suffix_nil.mp hpy
    subst e
    exact .refl (hc [] (List.suffix_refl _) (List.suffix_refl _))
  | cons i y ih =>
    intro hy hpy hc
    rcases List.suffix_cons_iff.mp hpy with e | h
    · subst e
      exact .refl (hc _ (List.suffix_refl _) (List.suffix_refl _))
    · exact .step
        (ih (len_tail hy) h (fun s h₁ h₂ => hc s h₁ (h₂.trans (List.suffix_cons i y))))
        (conn_down i y) (hc _ (h.trans (List.suffix_cons i y)) (List.suffix_refl _))

/-- Up from a monitor `x` that is `p` or beneath it to `p`, when no name from `x` to `p`
is in `Z`. -/
theorem ro_up (p : List (Fin 3)) (hp : p.length ≤ n) (x : List (Fin 3)) :
    ∀ hx : x.length ≤ n, p <:+ x → (∀ s, p <:+ s → s <:+ x → ¬ Z s) →
      ReachOutside (tower rd n b f) (fun m => Z m.val) ⟨x, hx⟩ ⟨p, hp⟩ := by
  induction x with
  | nil =>
    intro hx hpx hc
    have e : p = [] := List.suffix_nil.mp hpx
    subst e
    exact .refl (hc [] (List.suffix_refl _) (List.suffix_refl _))
  | cons i x ih =>
    intro hx hpx hc
    rcases List.suffix_cons_iff.mp hpx with e | h
    · subst e
      exact .refl (hc _ (List.suffix_refl _) (List.suffix_refl _))
    · have h₁ : ReachOutside (tower rd n b f) (fun m => Z m.val) ⟨i :: x, hx⟩
          ⟨x, len_tail hx⟩ :=
        .step (.refl (hc _ (h.trans (List.suffix_cons i x)) (List.suffix_refl _)))
          (conn_up i x) (hc x h (List.suffix_cons i x))
      exact ro_trans h₁
        (ih (len_tail hx) h (fun s h₁ h₂ => hc s h₁ (h₂.trans (List.suffix_cons i x))))

/-- From `x` up to the top coordinator and down to `y`, when neither `x`, nor `y`, nor any
monitor above either is in `Z`. -/
theorem ro_via_top (x y : TowerMon n) (hx : ∀ s, s <:+ x.val → ¬ Z s)
    (hy : ∀ s, s <:+ y.val → ¬ Z s) :
    ReachOutside (tower rd n b f) (fun m => Z m.val) x y :=
  ro_trans
    (ro_up rd n b f Z [] (Nat.zero_le n) x.val x.property (List.nil_suffix)
      (fun s _ h => hx s h))
    (ro_down rd n b f Z [] (Nat.zero_le n) y.val y.property (List.nil_suffix)
      (fun s _ h => hy s h))

/-- Round the cycle of the ring that `p` coordinates, from member 0 to any member, when no
member is in `Z`. -/
theorem ro_cycle (p : List (Fin 3)) (h : p.length + 1 ≤ n) (hz : ∀ i : Fin 3, ¬ Z (i :: p))
    (j : Fin 3) :
    ReachOutside (tower rd n b f) (fun m => Z m.val) ⟨0 :: p, h⟩ ⟨j :: p, h⟩ := by
  have h₀ : ReachOutside (tower rd n b f) (fun m => Z m.val) ⟨0 :: p, h⟩ ⟨0 :: p, h⟩ :=
    .refl (hz 0)
  have h₁ : ReachOutside (tower rd n b f) (fun m => Z m.val) ⟨0 :: p, h⟩ ⟨1 :: p, h⟩ :=
    .step h₀ (conn_next 0 p) (hz 1)
  have h₂ : ReachOutside (tower rd n b f) (fun m => Z m.val) ⟨0 :: p, h⟩ ⟨2 :: p, h⟩ :=
    .step h₁ (conn_next 1 p) (hz 2)
  rcases fin3 j with rfl | rfl | rfl
  · exact h₀
  · exact h₁
  · exact h₂

end Paths

/-- A monitor beneath `z` is a member of `z` or beneath one. -/
theorem suffix_step {z : List (Fin 3)} (y : List (Fin 3)) :
    z <:+ y → y ≠ z → ∃ j, (j :: z) <:+ y := by
  induction y with
  | nil =>
    intro h hne
    exact absurd (List.suffix_nil.mp h).symm hne
  | cons i y ih =>
    intro h hne
    rcases List.suffix_cons_iff.mp h with e | h
    · exact absurd e.symm hne
    · by_cases e : y = z
      · subst e
        exact ⟨i, List.suffix_refl _⟩
      · obtain ⟨j, hj⟩ := ih h e
        exact ⟨j, hj.trans (List.suffix_cons i y)⟩

/-- A name is not a suffix of a shorter one. -/
theorem not_suffix_of_lt {s t : List (Fin 3)} (h : t.length < s.length) : ¬ s <:+ t :=
  fun hs => Nat.not_le_of_lt h hs.length_le

/-! ### The four conditions of Theorem S -/

/-- Condition (c). For a monitor `y` beneath `z`, the watcher is member 0 of `z`: round
the cycle to the member of `z` that `y` is or is beneath, and down. For any other `y`, the
watcher is the coordinator of `z`: up to the top coordinator and down. -/
theorem tower_c (rd : Reading) (n : Nat) (b : Bool) (f : Nat) (z y : TowerMon n)
    (hy : y ≠ z) :
    ∃ r, r ≠ z ∧ Watches (tower rd n b f) r z ∧ ReachAvoiding (tower rd n b f) z r y := by
  by_cases hs : z.val <:+ y.val
  · obtain ⟨j, hj⟩ := suffix_step y.val hs (fun e => hy (Subtype.ext e))
    have hlen : z.val.length + 1 ≤ n := Nat.le_trans hj.length_le y.property
    have hmem : ∀ i : Fin 3, ¬ (i :: z.val) = z.val := fun i => List.cons_ne_self i z.val
    refine ⟨⟨0 :: z.val, hlen⟩, fun e => hmem 0 (congrArg Subtype.val e),
      watches_of_conn rd n b f (conn_up 0 z.val) (conn_down 0 z.val),
      ra_of_ro (Z := fun m => m.val = z.val) rfl
        (ro_trans (ro_cycle rd n b f (fun s => s = z.val) z.val hlen hmem j)
          (ro_down rd n b f (fun s => s = z.val) (j :: z.val) hlen y.val y.property hj
            ?_))⟩
    intro s h₁ _ e
    subst e
    exact not_suffix_of_lt (Nat.lt_succ_self _) h₁
  · obtain ⟨zv, hz⟩ := z
    cases zv with
    | nil => exact absurd List.nil_suffix hs
    | cons i q =>
      refine ⟨⟨q, len_tail hz⟩, fun e => List.cons_ne_self i q (congrArg Subtype.val e).symm,
        watches_of_conn rd n b f (conn_down i q) (conn_up i q),
        ra_of_ro (Z := fun m => m.val = i :: q) rfl
          (ro_via_top rd n b f (fun s => s = i :: q) ⟨q, len_tail hz⟩ y ?_ ?_)⟩
      · intro s h e
        subst e
        exact not_suffix_of_lt (Nat.lt_succ_self _) h
      · intro s h e
        subst e
        exact hs h

/-- The tower of one or more levels meets the four conditions of Theorem S, under either
reading, with or without the ring boundaries. -/
theorem tower_sufficient (rd : Reading) (n : Nat) (b : Bool) (f : Nat) (hn : 1 ≤ n) :
    Sufficient (tower rd n b f) where
  a := by
    intro z
    obtain ⟨zv, hz⟩ := z
    cases zv with
    | nil =>
      exact ⟨⟨[0], hn⟩, fun e => List.cons_ne_self 0 [] (congrArg Subtype.val e),
        watches_of_conn rd n b f (conn_up 0 []) (conn_down 0 [])⟩
    | cons i q =>
      exact ⟨⟨q, len_tail hz⟩,
        fun e => List.cons_ne_self i q (congrArg Subtype.val e).symm,
        watches_of_conn rd n b f (conn_down i q) (conn_up i q)⟩
  b := by
    intro w
    have h : w.val.length + 1 ≤ n := Nat.le_of_eq w.property
    exact ⟨⟨⟨w.val, Nat.le_of_succ_le h⟩, Or.inl rfl⟩, ⟨w.val, Nat.le_of_succ_le h⟩,
      ⟨0 :: w.val, h⟩, fun e => List.cons_ne_self 0 w.val (congrArg Subtype.val e).symm,
      Or.inl rfl, Or.inr ⟨0, rfl⟩⟩
  c := tower_c rd n b f
  d := by
    intro w
    have h : w.val.length + 1 ≤ n := Nat.le_of_eq w.property
    exact ⟨⟨w.val, Nat.le_of_succ_le h⟩, Or.inl rfl, fun m => reach_of_ro
      (ro_via_top rd n b f (fun _ => False) _ m (fun _ _ h => h) (fun _ _ h => h))⟩

/-! ### The boundaries -/

/-- A monitor with a boundary of its own is the one the boundary is named by. -/
theorem bd_own {n : Nat} {k s : List (Fin 3)} (h : towerRingBoundary n s = .own k) :
    s = k := by
  unfold towerRingBoundary at h
  split at h
  · cases h
  · split at h
    · cases h
    · cases h
      rfl

/-- In a tower of two or more levels, a ring boundary is named by a base ring's
coordinator, and its monitors are that coordinator or beneath it. -/
theorem bd_ring {n : Nat} (hn : 2 ≤ n) {q s : List (Fin 3)}
    (h : towerRingBoundary n s = .ring q) : q.length + 1 = n ∧ q <:+ s := by
  unfold towerRingBoundary at h
  split at h
  · rename_i h₁
    cases h
    exact ⟨h₁, List.suffix_refl _⟩
  · split at h
    · rename_i h₁ h₂
      cases h
      cases s with
      | nil =>
        have : (0 : Nat) = n := h₂
        omega
      | cons i t => exact ⟨h₂, List.suffix_cons i t⟩
    · cases h

/-- A base ring's coordinator and the monitors beneath it have the boundary of that
ring. -/
theorem bd_ring_of {n : Nat} {q s : List (Fin 3)} (hq : q.length + 1 = n)
    (hs : s.length ≤ n) (h : q <:+ s) : towerRingBoundary n s = .ring q := by
  obtain ⟨l, rfl⟩ := h
  match l, hs with
  | [], _ => simp [towerRingBoundary, hq]
  | [i], _ =>
    have h₁ : ¬ (i :: q).length + 1 = n := by
      rw [List.length_cons]
      omega
    have h₂ : (i :: q).length = n := by
      rw [List.length_cons]
      exact hq
    show towerRingBoundary n (i :: q) = .ring q
    unfold towerRingBoundary
    split
    · exact absurd ‹_› h₁
    · rfl
  | i :: j :: l, hs =>
    simp only [List.length_append, List.length_cons] at hs
    omega

/-- The loss of a whole base ring is answered. The coordinator above the ring's own
coordinator is outside the ring and reads that coordinator's signal; from it every monitor
outside the ring is reached up to the top coordinator and down, outside the ring. -/
theorem ring_answered (rd : Reading) (n : Nat) (hn : 2 ≤ n) (q : List (Fin 3))
    (hq : q.length + 1 = n) :
    LossAnswered (tower rd n true 1) (InBoundary (tower rd n true 1) (.ring q)) := by
  have hZ : ∀ m : TowerMon n,
      InBoundary (tower rd n true 1) (.ring q) m ↔ q <:+ m.val := by
    intro m
    constructor
    · intro h
      have h' : some (towerRingBoundary n m.val) = some (.ring q) := h
      exact (bd_ring hn (Option.some.inj h')).2
    · intro h
      exact congrArg some (bd_ring_of hq m.property h)
  cases q with
  | nil =>
    have : (0 : Nat) + 1 = n := hq
    omega
  | cons i q' =>
    have hlen : (i :: q').length ≤ n := Nat.le_of_lt (Nat.lt_of_lt_of_eq (Nat.lt_succ_self _) hq)
    have hout : ∀ s, s <:+ q' → ¬ (i :: q') <:+ s := fun s h₁ h₂ =>
      not_suffix_of_lt (Nat.lt_succ_self _) (h₂.trans h₁)
    have hr : ¬ InBoundary (tower rd n true 1) (.ring (i :: q')) ⟨q', len_tail hlen⟩ :=
      fun h => hout q' (List.suffix_refl _) ((hZ _).mp h)
    refine ⟨⟨_, hr⟩, fun y hy => ⟨⟨q', len_tail hlen⟩, ⟨i :: q', hlen⟩, hr,
      (hZ _).mpr (List.suffix_refl _),
      (watches_of_conn rd n true 1 (x := ⟨q', len_tail hlen⟩) (y := ⟨i :: q', hlen⟩)
        (conn_down i q') (conn_up i q')).2, ?_⟩⟩
    exact ro_mono
      (ro_via_top rd n true 1 (fun s => (i :: q') <:+ s) ⟨q', len_tail hlen⟩ y hout
        (fun s h₁ h₂ => hy ((hZ y).mpr (h₂.trans h₁))))
      (fun m hm => (hZ m).mp hm)

/-! ### The five statements -/

/-- The tower is a case of Theorem J at up to three faults per round, at every number of
levels from one, when every monitor is in a boundary of its own: it is plain and meets
the conditions of Theorem J. A coordinator and each of its members watch each other and
report to each other, and the rings are joined through the coordinators they share. -/
theorem tower_is_connected (rd : Reading) (n f : Nat) (hn : 1 ≤ n) (hf : f ≤ 3) :
    Plain (tower rd n false f) ∧ SufficientJ (tower rd n false f) f := by
  refine ⟨⟨rfl, fun _ => rfl, fun _ h => h, ?_, rfl, rfl, rfl, rfl⟩, linked_all rd n false f,
    ?_, ?_⟩
  · intro m m' bd hne h
    have h₁ : some (TowerBd.own m.val) = some bd := h.1
    have h₂ : some (TowerBd.own m'.val) = some bd := h.2
    exact hne (Subtype.ext (TowerBd.own.inj (Option.some.inj (h₁.trans h₂.symm))))
  · intro w
    have h : w.val.length + 1 ≤ n := Nat.le_of_eq w.property
    exact ⟨⟨⟨w.val, Nat.le_of_succ_le h⟩, Or.inl rfl⟩, ringList w.val h,
      ringList_nodup w.val h, Nat.lt_succ_of_le hf, fun _ hm => inRing_of_mem hm⟩
  · exact ⟨ringList [] hn, ringList_nodup [] hn, Nat.lt_succ_of_le hf⟩

/-- At four or more faults per round the tower has a gap: the four halt inputs of a work
process are all mutated in one round, and the work process sees no reason to halt. -/
theorem tower_gap (rd : Reading) (n f : Nat) (hn : 1 ≤ n) (hf : 4 ≤ f) :
    ViolatesG2 (tower rd n false f) := by
  have hq : (List.replicate (n - 1) (0 : Fin 3)).length + 1 = n := by
    rw [List.length_replicate]
    omega
  exact Necessity.few_halt_inputs_gap (tower rd n false f) (Nat.le_trans (by decide) hf)
    ⟨List.replicate (n - 1) 0, hq⟩ (fun h => nomatch h)
    (ringList (List.replicate (n - 1) 0) (Nat.le_of_eq hq))
    (ringList_nodup _ _) (fun _ hm => mem_of_inRing _ hm) hf

/-- With each base ring whole in one boundary, the tower of two or more levels is a case
of `theorem_S_wide` at one fault per round: it is of the wider class and meets its
conditions. The loss of a whole base ring is read by the coordinator above it. -/
theorem tower_boundaries_is_wide (rd : Reading) (n : Nat) (hn : 2 ≤ n) :
    Ordinary (tower rd n true 1) ∧ SufficientWide (tower rd n true 1) := by
  refine ⟨⟨fun _ h => h, rfl, rfl, rfl, rfl⟩,
    tower_sufficient rd n true 1 (Nat.le_of_succ_le hn), ?_, ?_⟩
  · intro c p h
    exact nomatch h
  · intro bd m m' hne hm hm'
    have h₁ : some (towerRingBoundary n m.val) = some bd := hm
    have h₂ : some (towerRingBoundary n m'.val) = some bd := hm'
    cases bd with
    | own k =>
      exact absurd (Subtype.ext ((bd_own (Option.some.inj h₁)).trans
        (bd_own (Option.some.inj h₂)).symm)) hne
    | ring q => exact ring_answered rd n hn q (bd_ring hn (Option.some.inj h₁)).1

/-- With each base ring whole in one boundary, the tower of two or more levels has no gap
at one fault per round, under either reading (`results-minimal.md`, section 4.6). -/
theorem tower_boundaries_noGap (rd : Reading) (n : Nat) (hn : 2 ≤ n) :
    NoGap (tower rd n true 1) :=
  Widening.theorem_S_wide (tower rd n true 1) rfl (tower_boundaries_is_wide rd n hn).1
    (tower_boundaries_is_wide rd n hn).2

/-- Two levels are needed for that. A single ring whole in one boundary has a gap at one
fault per round: the boundary is stopped, and then a process is mutated with no monitor
left to flag it (`results-minimal.md`, section 4.6; Theorem 0, part 2). -/
theorem tower_one_level_boundaries_gap (rd : Reading) : ViolatesG1 (tower rd 1 true 1) := by
  refine Necessity.one_boundary_gap (tower rd 1 true 1) (Nat.le_refl 1) (.ring [])
    (m₀ := ⟨[], Nat.zero_le 1⟩) (m₁ := ⟨[0], Nat.le_refl 1⟩)
    (fun e => List.cons_ne_self 0 [] (congrArg Subtype.val e).symm) ?_
  intro m
  obtain ⟨v, hv⟩ := m
  match v, hv with
  | [], _ => rfl
  | [_], _ => rfl
  | _ :: _ :: _, hv => exact absurd hv (by simp)

end TowerRings
end SelfObserving
