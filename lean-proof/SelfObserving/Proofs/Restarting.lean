/-
Proofs of the statements about the restart game of `Restart.lean` (section 10.3 of
`results.md`): Theorem R, the two equivalences between "can always restart" and
reachability from a member that can start first, the four rows of the table, and the
reachability of a full stop.

The plan. A set of members is *supported* (`Supp`) when each of its members can start
first or has an observer in the set. Nothing in a supported set falls (`not_falls_of_supp`),
and what `settle` leaves is supported (`settle_supp`). A set of members that cannot start
first and that contains every observer of each of its members stays stopped once it is
stopped (`closed_stays_stopped`); Theorem R is the case of the full set. In a finite ring
the environment can stop every member of any set and release every member it stopped
(`stop_release`).
-/
import SelfObserving.Restart

namespace SelfObserving
namespace Restarting

variable {X : Type}

/-! ### Supported sets and the rule -/

/-- A set of members is supported: each member of it can start first or has an observer in
the set. -/
def Supp (g : Ring X) (T : X → Prop) : Prop :=
  ∀ x, T x → g.startsFirst x ∨ ∃ o, g.observes o x ∧ T o

/-- No member of a supported set falls, in any set of running members that contains it. -/
theorem not_falls_of_supp (g : Ring X) {T R : X → Prop} (hT : Supp g T)
    (hsub : ∀ x, T x → R x) : ∀ x, Falls g R x → ¬ T x := by
  intro x hF
  induction hF with
  | intro hnf _ ih =>
    intro hTx
    cases hT _ hTx with
    | inl h => exact hnf h
    | inr h =>
      obtain ⟨o, ho, hTo⟩ := h
      exact ih o ho (hsub o hTo) hTo

/-- What the rule leaves is supported. -/
theorem settle_supp (g : Ring X) (R : X → Prop) : Supp g (settle g R) := by
  intro x hx
  apply Classical.byContradiction
  intro hn
  apply hx.2
  refine Falls.intro (fun hf => hn (Or.inl hf)) ?_
  intro o ho hRo
  apply Classical.byContradiction
  intro hnf
  exact hn (Or.inr ⟨o, ho, hRo, hnf⟩)

/-- The rule stops nothing in a supported set. -/
theorem settle_of_supp (g : Ring X) {T : X → Prop} (hT : Supp g T) (x : X) :
    settle g T x ↔ T x :=
  ⟨fun h => h.1, fun h => ⟨h, fun hF => not_falls_of_supp g hT (fun _ h => h) x hF h⟩⟩

/-! ### Runs -/

/-- One run after another is a run. -/
theorem run_append (g : Ring X) {s s₁ s₂ : RingState X} {m₁ m₂ : List (RingMove X)}
    (h₁ : RingRun g s m₁ s₁) (h₂ : RingRun g s₁ m₂ s₂) : RingRun g s (m₁ ++ m₂) s₂ := by
  induction h₁ with
  | nil s => exact h₂
  | cons hen _ ih => exact RingRun.cons hen (ih h₂)

/-- Let `P` be a set of members none of which can start first, and which contains every
observer of each of its members. If no member of `P` is running, then none is running
after any moves. -/
theorem closed_stays_stopped (g : Ring X) (P : X → Prop)
    (hnf : ∀ x, P x → ¬ g.startsFirst x) (hcl : ∀ o x, g.observes o x → P x → P o)
    {s s' : RingState X} {moves : List (RingMove X)} (hrun : RingRun g s moves s')
    (hs : ∀ x, P x → ¬ s.running x) : ∀ x, P x → ¬ s'.running x := by
  induction hrun with
  | nil s => exact hs
  | @cons s s' mv mvs hen _ ih =>
    apply ih
    cases mv with
    | stop m =>
      intro x hP h
      have h' : settle g (fun x => s.running x ∧ x ≠ m) x := h
      exact hs x hP h'.1.1
    | release m =>
      intro x hP h
      exact hs x hP h
    | start m =>
      intro x hP h
      have h' : settle g (fun x => s.running x ∨ x = m) x := h
      have hen' : ¬ s.running m ∧ ¬ s.blocked m ∧
          (g.startsFirst m ∨ ∃ o, g.observes o m ∧ s.running o) := hen
      cases h'.1 with
      | inl hr => exact hs x hP hr
      | inr hxm =>
        subst hxm
        cases hen'.2.2 with
        | inl hf => exact hnf x hP hf
        | inr ho =>
          obtain ⟨o, ho, hro⟩ := ho
          exact hs o (hcl o x ho hP) hro

/-- The running set stays supported along a run. -/
theorem supp_run (g : Ring X) {s s' : RingState X} {moves : List (RingMove X)}
    (hrun : RingRun g s moves s') (hs : Supp g s.running) : Supp g s'.running := by
  induction hrun with
  | nil s => exact hs
  | @cons s s' mv mvs hen _ ih =>
    apply ih
    cases mv with
    | stop m => exact settle_supp g (fun x => s.running x ∧ x ≠ m)
    | release m => exact hs
    | start m => exact settle_supp g (fun x => s.running x ∨ x = m)

/-! ### Theorem R -/

/-- Theorem R. If no member can start first, so that every member runs only while a
running member observes it, then once every member has stopped, none can ever start:
whatever moves follow, no member is running. -/
theorem theorem_R {X : Type} (g : Ring X) (hno : ∀ x, ¬ g.startsFirst x)
    (s s' : RingState X) (moves : List (RingMove X)) (hstop : ∀ x, ¬ s.running x)
    (hrun : RingRun g s moves s') : ∀ x, ¬ s'.running x :=
  fun x => closed_stays_stopped g (fun _ => True) (fun x _ => hno x)
    (fun _ _ _ _ => trivial) hrun (fun x _ => hstop x) x trivial

/-! ### Stopping and releasing -/

/-- Going through the list `l`, the environment stops each member of `P` that is running
when its turn comes. Afterwards no member of `P` in `l` is running. -/
theorem stop_all (g : Ring X) (P : X → Prop) : ∀ (l : List X) (s : RingState X),
    (∀ x, s.blocked x → ¬ s.running x) →
    ∃ (moves : List (RingMove X)) (s' : RingState X), RingRun g s moves s' ∧
      (∀ x, s'.running x → s.running x) ∧ (∀ x, x ∈ l → P x → ¬ s'.running x) ∧
      (∀ x, s'.blocked x → ¬ s'.running x) := by
  intro l
  induction l with
  | nil =>
    intro s hb
    exact ⟨[], s, RingRun.nil s, fun _ h => h, (fun _ h => nomatch h), hb⟩
  | cons a l ih =>
    intro s hb
    cases Classical.em (P a ∧ s.running a) with
    | inl h =>
      have hsub1 : ∀ x, (ringEffect g s (.stop a)).running x → s.running x ∧ x ≠ a := by
        intro x hrx
        have hrx' : settle g (fun x => s.running x ∧ x ≠ a) x := hrx
        exact hrx'.1
      have hb1 : ∀ x, (ringEffect g s (.stop a)).blocked x →
          ¬ (ringEffect g s (.stop a)).running x := by
        intro x hbx hrx
        have hbx' : s.blocked x ∨ x = a := hbx
        cases hbx' with
        | inl hbx => exact hb x hbx (hsub1 x hrx).1
        | inr hbx => exact (hsub1 x hrx).2 hbx
      obtain ⟨moves, s', hrun, hsub, hl, hb'⟩ := ih (ringEffect g s (.stop a)) hb1
      have hen : RingMove.Enabled g s (.stop a) := h.2
      refine ⟨.stop a :: moves, s', RingRun.cons hen hrun,
        fun x hx => (hsub1 x (hsub x hx)).1, ?_, hb'⟩
      intro x hx hP hr
      cases List.mem_cons.mp hx with
      | inl hxa => exact (hsub1 x (hsub x hr)).2 hxa
      | inr hxl => exact hl x hxl hP hr
    | inr h =>
      obtain ⟨moves, s', hrun, hsub, hl, hb'⟩ := ih s hb
      refine ⟨moves, s', hrun, hsub, ?_, hb'⟩
      intro x hx hP hr
      cases List.mem_cons.mp hx with
      | inl hxa => exact h ⟨hxa ▸ hP, hxa ▸ hsub x hr⟩
      | inr hxl => exact hl x hxl hP hr

/-- Going through the list `l`, the environment releases each member that is blocked when
its turn comes. Afterwards no member in `l` is blocked, and the running members are as
before. -/
theorem release_all (g : Ring X) : ∀ (l : List X) (s : RingState X),
    (∀ x, s.blocked x → ¬ s.running x) →
    ∃ (moves : List (RingMove X)) (s' : RingState X), RingRun g s moves s' ∧
      s'.running = s.running ∧ (∀ x, s'.blocked x → s.blocked x) ∧
      (∀ x, x ∈ l → ¬ s'.blocked x) := by
  intro l
  induction l with
  | nil =>
    intro s _
    exact ⟨[], s, RingRun.nil s, rfl, fun _ h => h, fun _ h => nomatch h⟩
  | cons a l ih =>
    intro s hb
    cases Classical.em (s.blocked a) with
    | inl h =>
      have hsub1 : ∀ x, (ringEffect g s (.release a)).blocked x → s.blocked x ∧ x ≠ a :=
        fun _ hbx => hbx
      have hb1 : ∀ x, (ringEffect g s (.release a)).blocked x →
          ¬ (ringEffect g s (.release a)).running x :=
        fun x hbx => hb x (hsub1 x hbx).1
      obtain ⟨moves, s', hrun, hr, hbs, hl⟩ := ih (ringEffect g s (.release a)) hb1
      have hen : RingMove.Enabled g s (.release a) := ⟨hb a h, h⟩
      refine ⟨.release a :: moves, s', RingRun.cons hen hrun, hr,
        fun x hx => (hsub1 x (hbs x hx)).1, ?_⟩
      intro x hx hbx
      cases List.mem_cons.mp hx with
      | inl hxa => exact (hsub1 x (hbs x hbx)).2 hxa
      | inr hxl => exact hl x hxl hbx
    | inr h =>
      obtain ⟨moves, s', hrun, hr, hbs, hl⟩ := ih s hb
      refine ⟨moves, s', hrun, hr, hbs, ?_⟩
      intro x hx hbx
      cases List.mem_cons.mp hx with
      | inl hxa => exact h (hxa ▸ hbs x hbx)
      | inr hxl => exact hl x hxl hbx

/-- In a finite ring, for any set `P` of members, the game can reach a state in which no
member of `P` is running and no member is blocked: the environment stops the members of
`P` and then releases every member it stopped. -/
theorem stop_release (g : Ring X) (P : X → Prop) (xs : List X) (hall : ∀ x, x ∈ xs) :
    ∃ (moves : List (RingMove X)) (s : RingState X), RingRun g ringInit moves s ∧
      (∀ x, P x → ¬ s.running x) ∧ (∀ x, ¬ s.blocked x) := by
  obtain ⟨m₁, s₁, hrun₁, _, hl₁, hb₁⟩ :=
    stop_all g P xs ringInit (fun _ h => False.elim h)
  obtain ⟨m₂, s₂, hrun₂, hr₂, _, hl₂⟩ := release_all g xs s₁ hb₁
  refine ⟨m₁ ++ m₂, s₂, run_append g hrun₁ hrun₂, ?_, fun x => hl₂ x (hall x)⟩
  intro x hP hr
  rw [hr₂] at hr
  exact hl₁ x (hall x) hP hr

/-- A full stop is reachable (section 10.3). In every ring with finitely many members,
the game can reach a state in which no member is running and none is blocked: every
member has been stopped, by the environment or by the rule, and the environment has
released each one it stopped. -/
theorem full_stop_reachable {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs) :
    ∃ (moves : List (RingMove X)) (s : RingState X),
      RingRun g ringInit moves s ∧ (∀ x, ¬ s.running x) ∧ (∀ x, ¬ s.blocked x) := by
  obtain ⟨moves, s, hrun, hstop, hb⟩ := stop_release g (fun _ => True) xs hall
  exact ⟨moves, s, hrun, fun x => hstop x trivial, hb⟩

/-! ### Starting again -/

/-- The last link of a chain: a member that is reached has an observer. -/
theorem reaches_observer (g : Ring X) {k y : X} (h : Reaches g k y) :
    ∃ o, g.observes o y := by
  cases h with
  | base hobs => exact ⟨_, hobs⟩
  | step _ hobs => exact ⟨_, hobs⟩

/-- Along a chain from a member of `R` to a member outside `R`, some member outside `R`
has an observer in `R`. -/
theorem exists_startable_of_reaches (g : Ring X) (R : X → Prop) {k y : X}
    (h : Reaches g k y) : R k → ¬ R y → ∃ m, ¬ R m ∧ ∃ o, g.observes o m ∧ R o := by
  induction h with
  | base hobs =>
    intro hk hy
    exact ⟨_, hy, _, hobs, hk⟩
  | @step y y' _ hobs ih =>
    intro hk hy'
    cases Classical.em (R y) with
    | inl hy => exact ⟨y', hy', y, hobs, hy⟩
    | inr hy => exact ih hk hy

/-- When the running set is supported, a start that is enabled adds the member that
starts and stops nothing. -/
theorem start_running (g : Ring X) {s : RingState X} {m : X} (hs : Supp g s.running)
    (hm : g.startsFirst m ∨ ∃ o, g.observes o m ∧ s.running o) (x : X) :
    (ringEffect g s (.start m)).running x ↔ (s.running x ∨ x = m) := by
  have hT : Supp g (fun x => s.running x ∨ x = m) := by
    intro y hy
    cases hy with
    | inl hy =>
      cases hs y hy with
      | inl h => exact Or.inl h
      | inr h =>
        obtain ⟨o, ho, hro⟩ := h
        exact Or.inr ⟨o, ho, Or.inl hro⟩
    | inr hy =>
      subst hy
      cases hm with
      | inl h => exact Or.inl h
      | inr h =>
        obtain ⟨o, ho, hro⟩ := h
        exact Or.inr ⟨o, ho, Or.inl hro⟩
  exact settle_of_supp g hT x

open Classical in
/-- The number of entries of the list that are not in `R`. -/
noncomputable def stoppedCount (R : X → Prop) : List X → Nat
  | [] => 0
  | x :: l => (if R x then 0 else 1) + stoppedCount R l

theorem stoppedCount_le (R R' : X → Prop) (h : ∀ x, R x → R' x) :
    ∀ l, stoppedCount R' l ≤ stoppedCount R l := by
  intro l
  induction l with
  | nil => exact Nat.le_refl _
  | cons a l ih =>
    by_cases ha : R a
    · have ha' := h a ha
      simp only [stoppedCount, ha, ha', ↓reduceIte]
      omega
    · by_cases ha' : R' a
      · simp only [stoppedCount, ha, ha', ↓reduceIte]
        omega
      · simp only [stoppedCount, ha, ha', ↓reduceIte]
        omega

theorem stoppedCount_lt (R R' : X → Prop) (h : ∀ x, R x → R' x) (m : X) (hm : ¬ R m)
    (hm' : R' m) : ∀ l, m ∈ l → stoppedCount R' l < stoppedCount R l := by
  intro l
  induction l with
  | nil => intro hml; cases hml
  | cons a l ih =>
    intro hml
    have hle := stoppedCount_le R R' h l
    cases List.mem_cons.mp hml with
    | inl hma =>
      subst hma
      simp only [stoppedCount, hm, hm', ↓reduceIte]
      omega
    | inr hml =>
      have ih' := ih hml
      by_cases ha : R a
      · have ha' := h a ha
        simp only [stoppedCount, ha, ha', ↓reduceIte]
        omega
      · by_cases ha' : R' a
        · simp only [stoppedCount, ha, ha', ↓reduceIte]
          omega
        · simp only [stoppedCount, ha, ha', ↓reduceIte]
          omega

/-- In a finite ring in which every member that cannot start first is reached from one
that can: a state whose running set is supported, with no member blocked, recovers. The
number `n` bounds the members that are not running. -/
theorem recovers_of_supp (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs)
    (hreach : ∀ y, ¬ g.startsFirst y → ∃ k, g.startsFirst k ∧ Reaches g k y) :
    ∀ (n : Nat) (s : RingState X), stoppedCount s.running xs < n → Supp g s.running →
      (∀ x, ¬ s.blocked x) → Recovers g s := by
  intro n
  induction n with
  | zero =>
    intro s h
    exact absurd h (Nat.not_lt_zero _)
  | succ n ih =>
    intro s hn hs hb
    cases Classical.em (∀ x, s.running x) with
    | inl hrunning => exact ⟨[], s, (fun _ h => nomatch h), RingRun.nil s, hrunning⟩
    | inr hnot =>
      obtain ⟨y, hy⟩ := Classical.not_forall.mp hnot
      have hex : ∃ m, ¬ s.running m ∧
          (g.startsFirst m ∨ ∃ o, g.observes o m ∧ s.running o) := by
        cases Classical.em (g.startsFirst y) with
        | inl hf => exact ⟨y, hy, Or.inl hf⟩
        | inr hf =>
          obtain ⟨k, hk, hky⟩ := hreach y hf
          cases Classical.em (s.running k) with
          | inl hrk =>
            obtain ⟨m, hm, ho⟩ := exists_startable_of_reaches g s.running hky hrk hy
            exact ⟨m, hm, Or.inr ho⟩
          | inr hrk => exact ⟨k, hrk, Or.inl hk⟩
      obtain ⟨m, hm, hst⟩ := hex
      have hiff := start_running g hs hst
      have hen : RingMove.Enabled g s (.start m) := ⟨hm, hb m, hst⟩
      have hlt : stoppedCount (ringEffect g s (.start m)).running xs <
          stoppedCount s.running xs :=
        stoppedCount_lt _ _ (fun x hx => (hiff x).mpr (Or.inl hx)) m hm
          ((hiff m).mpr (Or.inr rfl)) xs (hall m)
      have hs' : Supp g (ringEffect g s (.start m)).running :=
        settle_supp g (fun x => s.running x ∨ x = m)
      have hb' : ∀ x, ¬ (ringEffect g s (.start m)).blocked x := fun x => hb x
      obtain ⟨moves, s', hns, hrun, hrunning⟩ :=
        ih (ringEffect g s (.start m)) (by omega) hs' hb'
      refine ⟨.start m :: moves, s', ?_, RingRun.cons hen hrun, hrunning⟩
      intro mv hmv
      cases List.mem_cons.mp hmv with
      | inl h =>
        subst h
        exact fun h => h
      | inr h => exact hns mv h

/-- One half of the equivalence. In a finite ring in which every member that cannot start
first is reached from one that can, the ring can always restart. -/
theorem can_restart_of_reached (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs)
    (hreach : ∀ y, ¬ g.startsFirst y → ∃ k, g.startsFirst k ∧ Reaches g k y) :
    CanAlwaysRestart g := by
  intro moves s hrun hb
  have h0 : Supp g (ringInit (X := X)).running := by
    intro x _
    cases Classical.em (g.startsFirst x) with
    | inl h => exact Or.inl h
    | inr h =>
      obtain ⟨k, _, hk⟩ := hreach x h
      obtain ⟨o, ho⟩ := reaches_observer g hk
      exact Or.inr ⟨o, ho, trivial⟩
  exact recovers_of_supp g xs hall hreach _ s (Nat.lt_succ_self _) (supp_run g hrun h0) hb

/-- The other half. In a finite ring that can always restart, every member that cannot
start first is reached from one that can. -/
theorem reached_of_can_restart (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs)
    (hc : CanAlwaysRestart g) :
    ∀ y, ¬ g.startsFirst y → ∃ k, g.startsFirst k ∧ Reaches g k y := by
  intro y hy
  apply Classical.byContradiction
  intro hne
  have hcl : ∀ o x, g.observes o x →
      (¬ g.startsFirst x ∧ ¬ ∃ k, g.startsFirst k ∧ Reaches g k x) →
      (¬ g.startsFirst o ∧ ¬ ∃ k, g.startsFirst k ∧ Reaches g k o) := by
    intro o x ho hU
    refine ⟨fun hf => hU.2 ⟨o, hf, Reaches.base ho⟩, fun hex => ?_⟩
    obtain ⟨k, hk, hko⟩ := hex
    exact hU.2 ⟨k, hk, Reaches.step hko ho⟩
  obtain ⟨moves, s, hrun, hU, hb⟩ := stop_release g
    (fun x => ¬ g.startsFirst x ∧ ¬ ∃ k, g.startsFirst k ∧ Reaches g k x) xs hall
  obtain ⟨moves', s', _, hrun', hrunning⟩ := hc moves s hrun hb
  exact closed_stays_stopped g _ (fun _ h => h.1) hcl hrun' hU y ⟨hy, hne⟩ (hrunning y)

/-! ### The general statements -/

/-- The same for any number of members that can start first, none included. The ring can
always restart exactly when every member that cannot start first is reached from one that
can. `results.md` states this for one such member only. -/
theorem restart_iff_reached {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs) :
    CanAlwaysRestart g ↔ ∀ y, ¬ g.startsFirst y → ∃ k, g.startsFirst k ∧ Reaches g k y :=
  ⟨reached_of_can_restart g xs hall, can_restart_of_reached g xs hall⟩

/-- Recovery needs a member that can start first. A ring with at least one member, none of
which can start first, cannot always restart: a full stop is reachable, and by Theorem R
nothing starts after it. -/
theorem restart_needs_first {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs)
    (x₀ : X) (hno : ∀ x, ¬ g.startsFirst x) : ¬ CanAlwaysRestart g := by
  intro hc
  obtain ⟨moves, s, hrun, hstop, hb⟩ := full_stop_reachable g xs hall
  obtain ⟨moves', s', _, hrun', hrunning⟩ := hc moves s hrun hb
  exact theorem_R g hno s s' moves' hstop hrun' x₀ (hrunning x₀)

/-- Every other member must be reached from the member that can start first. Let `k` be
the one member that can start first. The ring can always restart exactly when `k` reaches
every other member. -/
theorem restart_iff_reaches {X : Type} (g : Ring X) (xs : List X) (hall : ∀ x, x ∈ xs)
    (k : X) (hk : ∀ x, g.startsFirst x ↔ x = k) :
    CanAlwaysRestart g ↔ ∀ y, y ≠ k → Reaches g k y := by
  constructor
  · intro hc y hy
    obtain ⟨k', hk', hr⟩ :=
      reached_of_can_restart g xs hall hc y (fun hf => hy ((hk y).mp hf))
    have hkk : k' = k := (hk k').mp hk'
    exact hkk ▸ hr
  · intro h
    apply can_restart_of_reached g xs hall
    intro y hy
    exact ⟨k, (hk k).mpr rfl, h y (fun e => hy ((hk y).mpr e))⟩

/-! ### The table of section 10.3 -/

/-- A state that is reachable with no member blocked and does not recover shows that the
ring cannot always restart. -/
theorem not_restart_of_run (g : Ring X) {moves : List (RingMove X)} {s : RingState X}
    (hrun : RingRun g ringInit moves s) (hb : ∀ x, ¬ s.blocked x) (hnr : ¬ Recovers g s) :
    ¬ CanAlwaysRestart g :=
  fun hc => hnr (hc moves s hrun hb)

/-- With no member that can start first, and at least one member, a full stop does not
recover. -/
theorem not_recovers_of_stopped (g : Ring X) (hno : ∀ x, ¬ g.startsFirst x)
    (s : RingState X) (hstop : ∀ x, ¬ s.running x) (x₀ : X) : ¬ Recovers g s := by
  intro hrec
  obtain ⟨moves, s', _, hrun, hrunning⟩ := hrec
  exact theorem_R g hno s s' moves hstop hrun x₀ (hrunning x₀)

/-- The table of section 10.3, first row. Three members, each observed by the one before
it, cannot restart after one member is stopped and released: the stop passes round the
ring and all three are stopped. -/
theorem ring3_cannot_restart :
    ¬ CanAlwaysRestart ring3 ∧
    ∃ s, RingRun ring3 ringInit [.stop .X1, .release .X1] s ∧ (∀ x, ¬ s.running x) ∧
      (∀ x, ¬ s.blocked x) ∧ ¬ Recovers ring3 s := by
  -- the members left when X1 is stopped, before the rule is applied
  let R : Three → Prop := fun x => (ringInit (X := Three)).running x ∧ x ≠ .X1
  have hF2 : Falls ring3 R .X2 :=
    Falls.intro (fun h => h) (fun o (ho : o = .X1) hR => absurd ho hR.2)
  have hF3 : Falls ring3 R .X3 :=
    Falls.intro (fun h => h) (fun o (ho : o = .X2) _ => ho ▸ hF2)
  have hstop1 : ∀ x, ¬ (ringEffect ring3 ringInit (.stop .X1)).running x := by
    intro x h
    have h' : settle ring3 R x := h
    cases x with
    | X1 => exact h'.1.2 rfl
    | X2 => exact h'.2 hF2
    | X3 => exact h'.2 hF3
  have hrun : RingRun ring3 ringInit [.stop .X1, .release .X1]
      (ringEffect ring3 (ringEffect ring3 ringInit (.stop .X1)) (.release .X1)) :=
    RingRun.cons (show (ringInit (X := Three)).running .X1 from trivial)
      (RingRun.cons
        (show ¬ (ringEffect ring3 ringInit (.stop .X1)).running .X1 ∧
            (ringEffect ring3 ringInit (.stop .X1)).blocked .X1 from
          ⟨hstop1 .X1, Or.inr rfl⟩)
        (RingRun.nil _))
  have hstop : ∀ x,
      ¬ (ringEffect ring3 (ringEffect ring3 ringInit (.stop .X1)) (.release .X1)).running x :=
    hstop1
  have hb : ∀ x,
      ¬ (ringEffect ring3 (ringEffect ring3 ringInit (.stop .X1)) (.release .X1)).blocked x := by
    intro x h
    have h' : (False ∨ x = .X1) ∧ x ≠ .X1 := h
    cases h'.1 with
    | inl hf => exact hf
    | inr hx => exact h'.2 hx
  have hnr := not_recovers_of_stopped ring3 (fun _ h => h) _ hstop .X1
  exact ⟨not_restart_of_run ring3 hrun hb hnr, _, hrun, hstop, hb, hnr⟩

/-- Second row. Three members, each observed by the other two, cannot restart after two
members are stopped and released. -/
theorem mesh3_cannot_restart :
    ¬ CanAlwaysRestart mesh3 ∧
    ∃ s, RingRun mesh3 ringInit [.stop .X1, .release .X1, .stop .X2, .release .X2] s ∧
      (∀ x, ¬ s.blocked x) ∧ ¬ Recovers mesh3 s := by
  -- the states after the first, second, third and fourth move
  let s₁ : RingState Three := ringEffect mesh3 ringInit (.stop .X1)
  let s₂ : RingState Three := ringEffect mesh3 s₁ (.release .X1)
  let s₃ : RingState Three := ringEffect mesh3 s₂ (.stop .X2)
  let s₄ : RingState Three := ringEffect mesh3 s₃ (.release .X2)
  -- after the first stop X2 and X3 keep each other running
  have hsupp : Supp mesh3 (fun x => x = .X2 ∨ x = .X3) := by
    intro x hx
    cases hx with
    | inl hx => exact Or.inr ⟨.X3, show Three.X3 ≠ x from hx ▸ (by decide), Or.inr rfl⟩
    | inr hx => exact Or.inr ⟨.X2, show Three.X2 ≠ x from hx ▸ (by decide), Or.inl rfl⟩
  have hn1 : ¬ s₁.running .X1 := by
    intro h
    have h' : settle mesh3 (fun x => (ringInit (X := Three)).running x ∧ x ≠ .X1) .X1 := h
    exact h'.1.2 rfl
  have hr2 : s₁.running .X2 := by
    show settle mesh3 (fun x => (ringInit (X := Three)).running x ∧ x ≠ .X1) .X2
    refine ⟨⟨trivial, by decide⟩, fun hF => ?_⟩
    refine not_falls_of_supp mesh3 hsupp ?_ .X2 hF (Or.inl rfl)
    intro x hx
    cases hx with
    | inl hx => exact ⟨trivial, hx ▸ (by decide)⟩
    | inr hx => exact ⟨trivial, hx ▸ (by decide)⟩
  -- the second stop leaves X3 with no observer
  have hF3 : Falls mesh3 (fun x => s₂.running x ∧ x ≠ .X2) .X3 := by
    refine Falls.intro (fun h => h) ?_
    intro o ho hR
    have ho' : o ≠ .X3 := ho
    cases o with
    | X1 => exact absurd hR.1 hn1
    | X2 => exact absurd rfl hR.2
    | X3 => exact absurd rfl ho'
  have hstop3 : ∀ x, ¬ s₃.running x := by
    intro x h
    have h' : settle mesh3 (fun x => s₂.running x ∧ x ≠ .X2) x := h
    cases x with
    | X1 => exact hn1 h'.1.1
    | X2 => exact h'.1.2 rfl
    | X3 => exact h'.2 hF3
  have hrun : RingRun mesh3 ringInit [.stop .X1, .release .X1, .stop .X2, .release .X2] s₄ :=
    RingRun.cons (show (ringInit (X := Three)).running .X1 from trivial)
      (RingRun.cons (show ¬ s₁.running .X1 ∧ s₁.blocked .X1 from ⟨hn1, Or.inr rfl⟩)
        (RingRun.cons (show s₂.running .X2 from hr2)
          (RingRun.cons (show ¬ s₃.running .X2 ∧ s₃.blocked .X2 from ⟨hstop3 .X2, Or.inr rfl⟩)
            (RingRun.nil _))))
  have hstop : ∀ x, ¬ s₄.running x := hstop3
  have hb : ∀ x, ¬ s₄.blocked x := by
    intro x h
    have h' : (((False ∨ x = .X1) ∧ x ≠ .X1) ∨ x = .X2) ∧ x ≠ .X2 := h
    cases h'.1 with
    | inl h1 =>
      cases h1.1 with
      | inl hf => exact hf
      | inr hx => exact h1.2 hx
    | inr hx => exact h'.2 hx
  have hnr := not_recovers_of_stopped mesh3 (fun _ h => h) s₄ hstop .X1
  exact ⟨not_restart_of_run mesh3 hrun hb hnr, s₄, hrun, hb, hnr⟩

/-- Third row. Three members and a coordinator that observes all three and can start
first can always restart. -/
theorem ringK_can_restart : CanAlwaysRestart (ringK true) := by
  refine (restart_iff_reaches (ringK true) [.X1, .X2, .X3, .K] ?_ .K ?_).mpr ?_
  · intro x
    cases x <;> simp
  · intro x
    constructor
    · intro h
      exact h.2
    · intro h
      exact ⟨rfl, h⟩
  · intro y hy
    cases y with
    | X1 => exact Reaches.base (show Four.K = .X3 ∨ Four.K = .K from Or.inr rfl)
    | X2 => exact Reaches.base (show Four.K = .X1 ∨ Four.K = .K from Or.inr rfl)
    | X3 => exact Reaches.base (show Four.K = .X2 ∨ Four.K = .K from Or.inr rfl)
    | K => exact absurd rfl hy

/-- Fourth row. The same four, when the coordinator cannot start first, cannot restart
after one member and the coordinator are stopped and released. -/
theorem ringK_cannot_restart_without_first :
    ¬ CanAlwaysRestart (ringK false) ∧
    ∃ s, RingRun (ringK false) ringInit [.stop .X1, .release .X1, .stop .K, .release .K] s ∧
      (∀ x, ¬ s.blocked x) ∧ ¬ Recovers (ringK false) s := by
  have hno : ∀ x, ¬ (ringK false).startsFirst x := fun _ h => Bool.noConfusion h.1
  -- the states after the first, second, third and fourth move
  let s₁ : RingState Four := ringEffect (ringK false) ringInit (.stop .X1)
  let s₂ : RingState Four := ringEffect (ringK false) s₁ (.release .X1)
  let s₃ : RingState Four := ringEffect (ringK false) s₂ (.stop .K)
  let s₄ : RingState Four := ringEffect (ringK false) s₃ (.release .K)
  -- after the first stop X2, X3 and K keep each other running
  have hsupp : Supp (ringK false) (fun x => x = .X2 ∨ x = .X3 ∨ x = .K) := by
    intro x hx
    cases x with
    | X1 => exact absurd hx (by decide)
    | X2 => exact Or.inr ⟨.K, show Four.K = .X1 ∨ Four.K = .K from Or.inr rfl, Or.inr (Or.inr rfl)⟩
    | X3 => exact Or.inr ⟨.K, show Four.K = .X2 ∨ Four.K = .K from Or.inr rfl, Or.inr (Or.inr rfl)⟩
    | K =>
      exact Or.inr ⟨.X2, show Four.X2 = .X1 ∨ Four.X2 = .X2 ∨ Four.X2 = .X3 from
        Or.inr (Or.inl rfl), Or.inl rfl⟩
  have hn1 : ¬ s₁.running .X1 := by
    intro h
    have h' : settle (ringK false) (fun x => (ringInit (X := Four)).running x ∧ x ≠ .X1) .X1 := h
    exact h'.1.2 rfl
  have hrK : s₁.running .K := by
    show settle (ringK false) (fun x => (ringInit (X := Four)).running x ∧ x ≠ .X1) .K
    refine ⟨⟨trivial, by decide⟩, fun hF => ?_⟩
    refine not_falls_of_supp (ringK false) hsupp ?_ .K hF (Or.inr (Or.inr rfl))
    intro x hx
    refine ⟨trivial, fun hx1 => ?_⟩
    subst hx1
    exact absurd hx (by decide)
  -- the stop of K leaves X2 with no observer, and then X3
  have hF2 : Falls (ringK false) (fun x => s₂.running x ∧ x ≠ .K) .X2 := by
    refine Falls.intro (hno _) ?_
    intro o ho hR
    have ho' : o = .X1 ∨ o = .K := ho
    cases ho' with
    | inl ho' => subst ho'; exact absurd hR.1 hn1
    | inr ho' => exact absurd ho' hR.2
  have hF3 : Falls (ringK false) (fun x => s₂.running x ∧ x ≠ .K) .X3 := by
    refine Falls.intro (hno _) ?_
    intro o ho hR
    have ho' : o = .X2 ∨ o = .K := ho
    cases ho' with
    | inl ho' => subst ho'; exact hF2
    | inr ho' => exact absurd ho' hR.2
  have hstop3 : ∀ x, ¬ s₃.running x := by
    intro x h
    have h' : settle (ringK false) (fun x => s₂.running x ∧ x ≠ .K) x := h
    cases x with
    | X1 => exact hn1 h'.1.1
    | X2 => exact h'.2 hF2
    | X3 => exact h'.2 hF3
    | K => exact h'.1.2 rfl
  have hrun : RingRun (ringK false) ringInit
      [.stop .X1, .release .X1, .stop .K, .release .K] s₄ :=
    RingRun.cons (show (ringInit (X := Four)).running .X1 from trivial)
      (RingRun.cons (show ¬ s₁.running .X1 ∧ s₁.blocked .X1 from ⟨hn1, Or.inr rfl⟩)
        (RingRun.cons (show s₂.running .K from hrK)
          (RingRun.cons (show ¬ s₃.running .K ∧ s₃.blocked .K from ⟨hstop3 .K, Or.inr rfl⟩)
            (RingRun.nil _))))
  have hstop : ∀ x, ¬ s₄.running x := hstop3
  have hb : ∀ x, ¬ s₄.blocked x := by
    intro x h
    have h' : (((False ∨ x = .X1) ∧ x ≠ .X1) ∨ x = .K) ∧ x ≠ .K := h
    cases h'.1 with
    | inl h1 =>
      cases h1.1 with
      | inl hf => exact hf
      | inr hx => exact h1.2 hx
    | inr hx => exact h'.2 hx
  have hnr := not_recovers_of_stopped (ringK false) hno s₄ hstop .X1
  exact ⟨not_restart_of_run (ringK false) hrun hb hnr, s₄, hrun, hb, hnr⟩

end Restarting
end SelfObserving
