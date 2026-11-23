/-
Proofs of statements of `Challenge.lean` under "The ring of `k` members and a coordinator"
and "The least ring".

The file has these parts:

- the monitors of the ring with `k` members as a list without repeats: the coordinator and
  the `k` members, `k + 1` in all;
- the ring is plain and meets the conditions of Theorem J when `f ≤ k`
  (`ring_is_connected`), and has a gap when `k < f` (`ring_gap`, from
  `Necessity.rate_bound`). `ring_gap` is the half of `ring_exact` that does not need
  Theorem J;
- counting: if every member of a list without repeats `xs` is the key of two different
  members of `l`, then `l` holds a list without repeats of twice the length of `xs`;
- the counts of connections that R2 and R5 force (`least_actor`, `least_flow`);
- the two concrete wirings of four monitors (`candidate_is_ring`, `least_of_four_actor`,
  `least_of_four_flow`).

`ring_exact` and `candidate_noGap` are not proved here: they need Theorem J.
-/
import SelfObserving.AnyRate
import SelfObserving.Rings
import SelfObserving.Proofs.Necessity
import SelfObserving.Proofs.MeshRate

namespace SelfObserving
namespace RingOfK

/-! ### The monitors of the ring, as a list -/

/-- The `k` members of the ring. -/
def members (k : Nat) : List (RingMon k) := (List.finRange k).map RingMon.member

/-- Every monitor of the ring: the coordinator, then the `k` members. -/
def monitors (k : Nat) : List (RingMon k) := RingMon.coord :: members k

theorem members_nodup (k : Nat) : (members k).Nodup :=
  List.Pairwise.map RingMon.member (fun _ _ h e => h (RingMon.member.inj e))
    (List.nodup_finRange k)

theorem members_length (k : Nat) : (members k).length = k := by
  unfold members
  rw [List.length_map, List.length_finRange]

theorem member_mem_members {k : Nat} (i : Fin k) : RingMon.member i ∈ members k :=
  List.mem_map_of_mem (List.mem_finRange i)

theorem coord_not_mem_members (k : Nat) : RingMon.coord ∉ members k := by
  intro h
  obtain ⟨i, _, hi⟩ := List.mem_map.1 h
  cases hi

theorem ne_coord_of_mem_members {k : Nat} {m : RingMon k} (h : m ∈ members k) :
    m ≠ RingMon.coord :=
  fun e => coord_not_mem_members k (e ▸ h)

theorem monitors_nodup (k : Nat) : (monitors k).Nodup :=
  List.nodup_cons.2 ⟨coord_not_mem_members k, members_nodup k⟩

theorem monitors_length (k : Nat) : (monitors k).length = k + 1 := by
  unfold monitors
  rw [List.length_cons, members_length]

theorem mem_monitors {k : Nat} (m : RingMon k) : m ∈ monitors k := by
  cases m with
  | member i => exact List.mem_cons_of_mem _ (member_mem_members i)
  | coord => exact List.mem_cons_self

/-! ### The ring is plain and connected -/

theorem ring_plain (rd : Reading) (k f : Nat) : Plain (ring rd k f) where
  no_joiner := rfl
  no_substrate := fun _ => rfl
  no_switch := fun _ h => h
  boundaries_distinct := fun _ _ _ hne h => hne (Option.some.inj (h.1.trans h.2.symm))
  coupling_on := rfl
  no_window := rfl
  gate_on := rfl
  reports_fast := rfl

/-- The coordinator and each member watch each other and report to each other, under
either reading. -/
theorem paired_coord_member (rd : Reading) (k f : Nat) (i : Fin k) :
    Paired (ring rd k f) RingMon.coord (RingMon.member i) := by
  cases rd <;> exact ⟨⟨trivial, trivial⟩, ⟨trivial, trivial⟩, trivial, trivial⟩

theorem paired_member_coord (rd : Reading) (k f : Nat) (i : Fin k) :
    Paired (ring rd k f) (RingMon.member i) RingMon.coord := by
  cases rd <;> exact ⟨⟨trivial, trivial⟩, ⟨trivial, trivial⟩, trivial, trivial⟩

/-- Every monitor is linked to every monitor, through the coordinator. -/
theorem ring_linked (rd : Reading) (k f : Nat) (a b : RingMon k) :
    Linked (ring rd k f) a b := by
  have hc : Linked (ring rd k f) a RingMon.coord := by
    cases a with
    | member i => exact Linked.step (Linked.refl _) (paired_member_coord rd k f i)
    | coord => exact Linked.refl _
  cases b with
  | member j => exact Linked.step hc (paired_coord_member rd k f j)
  | coord => exact hc

/-- The ring is a case of Theorem J when `f` is at most `k`: it is plain and meets the
conditions of Theorem J at `f` faults per round. The coordinator and each member watch
each other and report to each other, under either reading. -/
theorem ring_is_connected (rd : Reading) (k f : Nat) (h : f ≤ k) :
    Plain (ring rd k f) ∧ SufficientJ (ring rd k f) f := by
  have hlen : f < (monitors k).length := by
    rw [monitors_length]
    omega
  refine ⟨ring_plain rd k f, ?_, ?_, ?_⟩
  · exact ring_linked rd k f
  · intro _
    exact ⟨⟨RingMon.coord, trivial⟩, monitors k, monitors_nodup k, hlen, fun _ _ => trivial⟩
  · exact ⟨monitors k, monitors_nodup k, hlen⟩

/-- The ring has a gap when `f` is more than `k`: its `k + 1` monitors are all of its
monitors, and `f` faults reach every one of them. This is the half of `ring_exact` that
does not need Theorem J. -/
theorem ring_gap (rd : Reading) (k f : Nat) (h : k < f) : ViolatesG1 (ring rd k f) := by
  refine Necessity.rate_bound (ring rd k f) (monitors k) (List.cons_ne_nil _ _)
    (monitors_nodup k) mem_monitors ?_
  show (monitors k).length ≤ f
  rw [monitors_length]
  omega

/-! ### What a wiring given as a list makes of watching and reporting -/

variable {M : Type}

/-- Under actor, `a` watches `z` exactly when the connection `a -> z` is there. -/
theorem watches_actor (l : List (M × M)) (f : Nat) (a z : M) :
    Watches (wiredList Reading.actor l f) a z ↔ (a, z) ∈ l :=
  ⟨fun h => h.1, fun h => ⟨h, h⟩⟩

/-- Under flow, `a` watches `z` exactly when the connection `z -> a` is there. -/
theorem watches_flow (l : List (M × M)) (f : Nat) (a z : M) :
    Watches (wiredList Reading.flow l f) a z ↔ (z, a) ∈ l :=
  ⟨fun h => h.1, fun h => ⟨h, h⟩⟩

/-- Under either reading, `a` reports to `b` exactly when the connection `a -> b` is
there. -/
theorem fwd_wiredList (rd : Reading) (l : List (M × M)) (f : Nat) (a b : M) :
    (wiredList rd l f).fwd a b ↔ (a, b) ∈ l :=
  Iff.rfl

/-! ### Counting -/

/-- If every member of a list without repeats `xs` is the key of two different members of
`l`, then `l` holds a list without repeats of twice the length of `xs`, each of whose
members has its key in `xs`. -/
theorem two_each {α β : Type} (key : α → β) (l : List α) :
    ∀ xs : List β, xs.Nodup →
      (∀ x, x ∈ xs → ∃ p q, p ≠ q ∧ p ∈ l ∧ q ∈ l ∧ key p = x ∧ key q = x) →
      ∃ ps : List α, ps.Nodup ∧ ps.length = 2 * xs.length ∧
        ∀ p, p ∈ ps → p ∈ l ∧ key p ∈ xs
  | [], _, _ => ⟨[], List.nodup_nil, rfl, fun _ h => absurd h List.not_mem_nil⟩
  | x :: xs, hnd, h => by
    have hnd' := List.nodup_cons.1 hnd
    obtain ⟨ps, hps, hlen, hin⟩ :=
      two_each key l xs hnd'.2 (fun y hy => h y (List.mem_cons_of_mem _ hy))
    obtain ⟨p, q, hpq, hp, hq, kp, kq⟩ := h x List.mem_cons_self
    have hp' : p ∉ ps := fun hm => hnd'.1 (kp ▸ (hin p hm).2)
    have hq' : q ∉ ps := fun hm => hnd'.1 (kq ▸ (hin q hm).2)
    refine ⟨p :: q :: ps, ?_, ?_, ?_⟩
    · refine List.nodup_cons.2 ⟨?_, List.nodup_cons.2 ⟨hq', hps⟩⟩
      intro hm
      rcases List.mem_cons.1 hm with e | hm
      · exact hpq e
      · exact hp' hm
    · simp only [List.length_cons, hlen]
      omega
    · intro r hr
      rcases List.mem_cons.1 hr with e | hr
      · rw [e]
        exact ⟨hp, kp ▸ List.mem_cons_self⟩
      · rcases List.mem_cons.1 hr with e | hr
        · rw [e]
          exact ⟨hq, kq ▸ List.mem_cons_self⟩
        · exact ⟨(hin r hr).1, List.mem_cons_of_mem _ (hin r hr).2⟩

/-! ### The least ring -/

/-- Under actor, every wiring of the `k` members and the coordinator in which every
monitor has two watchers (R2) and every member reports to the coordinator (R5) has at
least `3 * k` connections. The hypothesis `_hnd` is not needed for the bound. -/
theorem least_actor (k f : Nat) (l : List (RingMon k × RingMon k)) (_hnd : l.Nodup)
    (h2 : R2 (wiredList .actor l f)) (h5 : R5 (wiredList .actor l f) .coord) :
    3 * k ≤ l.length := by
  -- Two connections into each member, from R2.
  obtain ⟨ps, hps, hpl, hpin⟩ := two_each Prod.snd l (members k) (members_nodup k) (by
    intro z _
    obtain ⟨a, b, hab, _, _, ha, hb⟩ := h2 z
    exact ⟨(a, z), (b, z), fun e => hab (congrArg Prod.fst e),
      (watches_actor l f a z).1 ha, (watches_actor l f b z).1 hb, rfl, rfl⟩)
  -- One connection from each member to the coordinator, from R5.
  let ss : List (RingMon k × RingMon k) := (members k).map (fun m => (m, RingMon.coord))
  have hss : ss.Nodup :=
    List.Pairwise.map (fun m => (m, RingMon.coord)) (fun _ _ h e => h (congrArg Prod.fst e))
      (members_nodup k)
  have hsl : ss.length = k := by
    show ((members k).map _).length = k
    rw [List.length_map, members_length]
  have hsin : ∀ p, p ∈ ss → p ∈ l ∧ p.2 = RingMon.coord := by
    intro p hp
    obtain ⟨m, hm, rfl⟩ := List.mem_map.1 hp
    exact ⟨h5 m (ne_coord_of_mem_members hm), rfl⟩
  -- The two lists share nothing: one ends at the coordinator, the other at a member.
  have hall : (ss ++ ps).Nodup := by
    refine List.nodup_append.2 ⟨hss, hps, ?_⟩
    intro a ha b hb e
    have h₁ := (hsin a ha).2
    have h₂ := (hpin b hb).2
    rw [← e, h₁] at h₂
    exact coord_not_mem_members k h₂
  have hle := MeshRate.length_le_of_subset (ss ++ ps) l hall (by
    intro p hp
    rcases List.mem_append.1 hp with hp | hp
    · exact (hsin p hp).1
    · exact (hpin p hp).1)
  rw [List.length_append, hsl, hpl, members_length] at hle
  omega

/-- Under flow, every wiring of the `k` members and the coordinator in which every monitor
has two watchers (R2) has at least `2 * k + 2` connections. R5 is not needed for the
count: under flow R2 alone gives it. The hypothesis `_hnd` is not needed for the bound. -/
theorem least_flow (k f : Nat) (l : List (RingMon k × RingMon k)) (_hnd : l.Nodup)
    (h2 : R2 (wiredList .flow l f)) : 2 * k + 2 ≤ l.length := by
  -- Two connections out of each monitor, from R2.
  obtain ⟨ps, hps, hpl, hpin⟩ := two_each Prod.fst l (monitors k) (monitors_nodup k) (by
    intro z _
    obtain ⟨a, b, hab, _, _, ha, hb⟩ := h2 z
    exact ⟨(z, a), (z, b), fun e => hab (congrArg Prod.snd e),
      (watches_flow l f a z).1 ha, (watches_flow l f b z).1 hb, rfl, rfl⟩)
  have hle := MeshRate.length_le_of_subset ps l hps (fun p hp => (hpin p hp).1)
  rw [hpl, monitors_length] at hle
  omega

/-! ### Four monitors -/

/-- A statement holds of every monitor of the ring with three members if it holds of each
of the four. -/
theorem forall_ringMon3 {P : RingMon 3 → Prop} (h0 : P (.member 0)) (h1 : P (.member 1))
    (h2 : P (.member 2)) (hc : P .coord) : ∀ x, P x
  | .coord => hc
  | .member ⟨0, _⟩ => h0
  | .member ⟨1, _⟩ => h1
  | .member ⟨2, _⟩ => h2

/-- Whether a connection of the ring is there can be computed. -/
local instance ringConnDecidable (k : Nat) : ∀ x y : RingMon k, Decidable (ringConn k x y)
  | .member i, .member j => inferInstanceAs (Decidable (i ≠ j ∧ j.val = (i.val + 1) % k))
  | .coord, .member _ => isTrue trivial
  | .member _, .coord => isTrue trivial
  | .coord, .coord => isFalse (fun h => h)

/-- The list `candidateArrows` holds exactly the connections of the ring with three
members. -/
theorem candidate_is_ring (x y : RingMon 3) :
    (x, y) ∈ candidateArrows ↔ ringConn 3 x y := by
  revert y
  revert x
  apply forall_ringMon3 <;> apply forall_ringMon3 <;> decide

theorem candidate_nodup : candidateArrows.Nodup := by decide

theorem eight_nodup : eightArrows.Nodup := by decide

theorem candidate_R2_actor (f : Nat) : R2 (wiredList .actor candidateArrows f) := by
  unfold R2
  apply forall_ringMon3
  · exact ⟨.member 2, .coord, by decide, by decide, by decide,
      (watches_actor _ _ _ _).2 (by decide), (watches_actor _ _ _ _).2 (by decide)⟩
  · exact ⟨.member 0, .coord, by decide, by decide, by decide,
      (watches_actor _ _ _ _).2 (by decide), (watches_actor _ _ _ _).2 (by decide)⟩
  · exact ⟨.member 1, .coord, by decide, by decide, by decide,
      (watches_actor _ _ _ _).2 (by decide), (watches_actor _ _ _ _).2 (by decide)⟩
  · exact ⟨.member 0, .member 1, by decide, by decide, by decide,
      (watches_actor _ _ _ _).2 (by decide), (watches_actor _ _ _ _).2 (by decide)⟩

theorem candidate_R2_flow (f : Nat) : R2 (wiredList .flow candidateArrows f) := by
  unfold R2
  apply forall_ringMon3
  · exact ⟨.member 1, .coord, by decide, by decide, by decide,
      (watches_flow _ _ _ _).2 (by decide), (watches_flow _ _ _ _).2 (by decide)⟩
  · exact ⟨.member 2, .coord, by decide, by decide, by decide,
      (watches_flow _ _ _ _).2 (by decide), (watches_flow _ _ _ _).2 (by decide)⟩
  · exact ⟨.member 0, .coord, by decide, by decide, by decide,
      (watches_flow _ _ _ _).2 (by decide), (watches_flow _ _ _ _).2 (by decide)⟩
  · exact ⟨.member 0, .member 1, by decide, by decide, by decide,
      (watches_flow _ _ _ _).2 (by decide), (watches_flow _ _ _ _).2 (by decide)⟩

theorem eight_R2_flow (f : Nat) : R2 (wiredList .flow eightArrows f) := by
  unfold R2
  apply forall_ringMon3
  · exact ⟨.member 1, .coord, by decide, by decide, by decide,
      (watches_flow _ _ _ _).2 (by decide), (watches_flow _ _ _ _).2 (by decide)⟩
  · exact ⟨.member 2, .coord, by decide, by decide, by decide,
      (watches_flow _ _ _ _).2 (by decide), (watches_flow _ _ _ _).2 (by decide)⟩
  · exact ⟨.member 0, .coord, by decide, by decide, by decide,
      (watches_flow _ _ _ _).2 (by decide), (watches_flow _ _ _ _).2 (by decide)⟩
  · exact ⟨.member 0, .member 1, by decide, by decide, by decide,
      (watches_flow _ _ _ _).2 (by decide), (watches_flow _ _ _ _).2 (by decide)⟩

/-- In the candidate every member reports to the coordinator, under either reading. -/
theorem candidate_R5 (rd : Reading) (f : Nat) :
    R5 (wiredList rd candidateArrows f) .coord := by
  unfold R5
  apply forall_ringMon3
  · exact fun _ => (fwd_wiredList _ _ _ _ _).2 (by decide)
  · exact fun _ => (fwd_wiredList _ _ _ _ _).2 (by decide)
  · exact fun _ => (fwd_wiredList _ _ _ _ _).2 (by decide)
  · exact fun h => absurd rfl h

/-- In the candidate without `D -> C` every member reports to the coordinator, under
either reading. -/
theorem eight_R5 (rd : Reading) (f : Nat) : R5 (wiredList rd eightArrows f) .coord := by
  unfold R5
  apply forall_ringMon3
  · exact fun _ => (fwd_wiredList _ _ _ _ _).2 (by decide)
  · exact fun _ => (fwd_wiredList _ _ _ _ _).2 (by decide)
  · exact fun _ => (fwd_wiredList _ _ _ _ _).2 (by decide)
  · exact fun h => absurd rfl h

/-- The least ring of four under actor. Among the wirings of four monitors as directed
connections, every one that meets R2 and R5 has at least nine connections, and the
candidate has nine and meets both: under actor the candidate is among the least. -/
theorem least_of_four_actor (f : Nat) :
    (∀ l : List (RingMon 3 × RingMon 3), l.Nodup → R2 (wiredList .actor l f) →
        R5 (wiredList .actor l f) .coord → 9 ≤ l.length) ∧
    candidateArrows.Nodup ∧ candidateArrows.length = 9 ∧
    R2 (wiredList .actor candidateArrows f) ∧
    R5 (wiredList .actor candidateArrows f) .coord :=
  ⟨fun l hnd h2 h5 => least_actor 3 f l hnd h2 h5, candidate_nodup, rfl,
    candidate_R2_actor f, candidate_R5 .actor f⟩

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
      R5 (wiredList .flow candidateArrows f) .coord) :=
  ⟨fun l hnd h2 _ => least_flow 3 f l hnd h2,
    ⟨eight_nodup, rfl, eight_R2_flow f, eight_R5 .flow f⟩,
    ⟨candidate_nodup, rfl, candidate_R2_flow f, candidate_R5 .flow f⟩⟩

end RingOfK
end SelfObserving
