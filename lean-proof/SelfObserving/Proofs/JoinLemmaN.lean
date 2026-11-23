/-
Lemma N of `results-join.md`, section 3 (`lemma_N` of `Challenge.lean`): late monitors
never help. If `small` is `sys` with every late monitor and its edges deleted
(`InitialPart`), each goal that can be violated in `small` can be violated in `sys`.

The proof simulates every execution of `small` by an execution of `sys` in which no group
ever joins. A state `t` of `small` is mapped to the state `lift ι t` of `sys`: no group has
arrived, no late monitor is alive, bad, hidden, off or flagged, and every other component
is that of `t` (read through `ι` at the monitors).

- Environment phase: each step of `small` maps to a step of `sys` (`smap`); it is enabled
  (`enabled_map`) and its effect is the lift of the effect (`effect_map`).
- The other two phases: the system `effective sys (lift ι t) (lift ι t₁)`, whose edges are
  the edges in force, corresponds to `small` (`Corr`, `corr_effective`): its edges between
  initial monitors are those of `small`, and it has no edge with a late monitor at an end.
  Its edges at a non-monitor process are those of `small` when that process is present.
  One lemma for each definition of `Model.lean` then gives `afterEnv_lift`.
- A non-monitor process that is not present is never bad in a reachable state of `small`
  (`Inv`). This is needed because an edge at a process that is not present is not in
  force in `sys`, while `small` keeps it.
-/
import SelfObserving.JoinConditions

namespace SelfObserving
namespace JoinLemmaN

variable {M W B S : Type}

section

variable {G M₀ B₀ S₀ : Type}

/-! ### Equality of states -/

theorem state_ext {s s' : State M W}
    (h1 : ∀ p, s.alive p ↔ s'.alive p) (h2 : ∀ p, s.bad p ↔ s'.bad p)
    (h3 : ∀ p, s.hidden p ↔ s'.hidden p) (h4 : ∀ m, s.off m ↔ s'.off m)
    (h5 : ∀ m, s.flagged m ↔ s'.flagged m) (h6 : ∀ w, s.halted w ↔ s'.halted w)
    (h7 : ∀ w, s.pending w ↔ s'.pending w) (h8 : s.joined ↔ s'.joined) : s = s' := by
  cases s
  cases s'
  simp only [State.mk.injEq]
  exact ⟨funext fun p => propext (h1 p), funext fun p => propext (h2 p),
    funext fun p => propext (h3 p), funext fun m => propext (h4 m),
    funext fun m => propext (h5 m), funext fun w => propext (h6 w),
    funext fun w => propext (h7 w), propext h8⟩

theorem jstate_eq : ∀ {s s' : JState M W G}, s.st = s'.st → s.arrived = s'.arrived → s = s'
  | ⟨_, _⟩, ⟨_, _⟩, rfl, rfl => rfl

/-! ### The lift of a state of `small` -/

/-- A set of processes of `small` as a set of processes of `sys`: no late monitor is in
it. -/
def liftP (ι : M₀ → M) (P : Proc M₀ W → Prop) : Proc M W → Prop
  | .inl m => ∃ a, ι a = m ∧ P (.inl a)
  | .inr w => P (.inr w)

/-- A set of monitors of `small` as a set of monitors of `sys`: no late monitor is in
it. -/
def liftM (ι : M₀ → M) (P : M₀ → Prop) : M → Prop := fun m => ∃ a, ι a = m ∧ P a

/-- The components of `model-spec.md` of the lifted state. -/
def liftSt (ι : M₀ → M) (t : State M₀ W) : State M W where
  alive := liftP ι t.alive
  bad := liftP ι t.bad
  hidden := liftP ι t.hidden
  off := liftM ι t.off
  flagged := liftM ι t.flagged
  halted := t.halted
  pending := t.pending
  joined := t.joined

/-- The lifted state: no group has joined. -/
def lift (ι : M₀ → M) (t : State M₀ W) : JState M W G := ⟨liftSt ι t, fun _ => False⟩

/-- A process of `small` as a process of `sys`. -/
def pmap (ι : M₀ → M) : Proc M₀ W → Proc M W
  | .inl a => .inl (ι a)
  | .inr w => .inr w

/-- A step of `small` as a step of `sys`. -/
def smap (ι : M₀ → M) (β : B₀ → B) (σ : S₀ → S) : EnvStep M₀ W B₀ S₀ → JStep M W B S G
  | .stop a => .stop (ι a)
  | .stopBoundary b => .stopBoundary (β b)
  | .failSubstrate c => .failSubstrate (σ c)
  | .mutate p => .mutate (pmap ι p)
  | .disable a => .disable (ι a)
  | .join => .join

theorem ex_iff {ι : M₀ → M} (hinj : ∀ a b, ι a = ι b → a = b) (P : M₀ → Prop) (a : M₀) :
    (∃ a', ι a' = ι a ∧ P a') ↔ P a := by
  constructor
  · rintro ⟨a', e, h⟩
    have e' := hinj _ _ e
    subst e'
    exact h
  · intro h
    exact ⟨a, rfl, h⟩

theorem liftP_inl {ι : M₀ → M} (hinj : ∀ a b, ι a = ι b → a = b) (P : Proc M₀ W → Prop)
    (a : M₀) : liftP ι P (.inl (ι a)) ↔ P (.inl a) :=
  ex_iff hinj (fun a => P (.inl a)) a

theorem liftM_map {ι : M₀ → M} (hinj : ∀ a b, ι a = ι b → a = b) (P : M₀ → Prop) (a : M₀) :
    liftM ι P (ι a) ↔ P a :=
  ex_iff hinj P a

theorem map_eq_some {A A' : Type} {f : A → A'} (hf : ∀ x y, f x = f y → x = y)
    (o : Option A) (x : A) : o.map f = some (f x) ↔ o = some x := by
  cases o with
  | none =>
    constructor
    · intro h
      have h' : (none : Option A') = some (f x) := h
      cases h'
    · intro h
      cases h
  | some y =>
    constructor
    · intro h
      have h' : some (f y) = some (f x) := h
      rw [hf _ _ (Option.some.inj h')]
    · intro h
      cases h
      rfl

variable {sys : JSystem M W B S G} {small : System M₀ W B₀ S₀} {ι : M₀ → M} {β : B₀ → B}
  {σ : S₀ → S}

theorem isJoiner_iff (hi : InitialPart sys small ι β σ) (w : W) :
    sys.base.IsJoiner w ↔ small.IsJoiner w := by
  show sys.base.joiner = some w ↔ small.joiner = some w
  rw [hi.joiner]

/-- In a lifted state the present monitors are the initial monitors. -/
theorem jpresent_inl (hi : InitialPart sys small ι β σ) (t : State M₀ W) (m : M) :
    JPresent sys (lift ι t) (.inl m) ↔ ∃ a, ι a = m := by
  refine Iff.trans ?_ (hi.initial m)
  show (∀ g, sys.group m = some g → False) ↔ sys.group m = none
  constructor
  · intro h
    cases hg : sys.group m with
    | none => rfl
    | some g => exact (h g hg).elim
  · intro h g hg
    rw [h] at hg
    cases hg

theorem pres (hi : InitialPart sys small ι β σ) (t : State M₀ W) (a : M₀) :
    JPresent sys (lift ι t) (.inl (ι a)) :=
  (jpresent_inl hi t _).2 ⟨a, rfl⟩

/-- In a lifted state the present non-monitor processes are those of `small`. -/
theorem jpresent_inr (hi : InitialPart sys small ι β σ) (t : State M₀ W) (w : W) :
    JPresent sys (lift ι t) (.inr w) ↔ Present small t (.inr w) := by
  show (sys.base.IsJoiner w → t.joined) ↔ (small.IsJoiner w → t.joined)
  rw [isJoiner_iff hi]

/-- The lift of the initial state is the initial state. -/
theorem init_lift (hi : InitialPart sys small ι β σ) : lift ι (init small) = jinit sys := by
  refine jstate_eq (state_ext ?_ ?_ ?_ ?_ ?_ (fun _ => Iff.rfl) (fun _ => Iff.rfl) Iff.rfl) rfl
  · intro p
    cases p with
    | inl m =>
      show (∃ a, ι a = m ∧ True) ↔ sys.group m = none
      rw [hi.initial]
      exact ⟨fun ⟨a, h, _⟩ => ⟨a, h⟩, fun ⟨a, h⟩ => ⟨a, h, trivial⟩⟩
    | inr w =>
      show ¬ small.IsJoiner w ↔ ¬ sys.base.IsJoiner w
      rw [isJoiner_iff hi]
  · intro p
    cases p with
    | inl m => exact ⟨fun ⟨_, _, h⟩ => h, fun h => h.elim⟩
    | inr w => exact Iff.rfl
  · intro p
    cases p with
    | inl m => exact ⟨fun ⟨_, _, h⟩ => h, fun h => h.elim⟩
    | inr w => exact Iff.rfl
  · intro m
    exact ⟨fun ⟨_, _, h⟩ => h, fun h => h.elim⟩
  · intro m
    exact ⟨fun ⟨_, _, h⟩ => h, fun h => h.elim⟩

/-! ### The environment phase -/

theorem enabled_map (hi : InitialPart sys small ι β σ) (t : State M₀ W)
    (e : EnvStep M₀ W B₀ S₀) (he : Enabled small t e) :
    JEnabled sys (lift ι t) (smap ι β σ e) := by
  cases e with
  | stop a => exact ⟨pres hi t a, a, rfl, he⟩
  | stopBoundary b =>
    obtain ⟨⟨m, m', hne, hb, hb'⟩, m'', hb'', hal⟩ := he
    have bd : ∀ a, small.boundary a = some b → sys.base.boundary (ι a) = some (β b) :=
      fun a h => (hi.boundary a).trans ((map_eq_some hi.β_inj _ _).2 h)
    exact ⟨⟨ι m, ι m', fun e => hne (hi.inj _ _ e), bd m hb, bd m' hb', pres hi t m,
      pres hi t m'⟩, ι m'', bd m'' hb'', pres hi t m'', m'', rfl, hal⟩
  | failSubstrate c =>
    obtain ⟨p, hp, hs, hm⟩ := he
    cases p with
    | inl a =>
      exact ⟨.inl (ι a), pres hi t a,
        (hi.substrate_mon a).trans ((map_eq_some hi.σ_inj _ _).2 hs), a, rfl, hm⟩
    | inr w =>
      exact ⟨.inr w, (jpresent_inr hi t w).2 hp,
        (hi.substrate_work w).trans ((map_eq_some hi.σ_inj _ _).2 hs), hm⟩
  | mutate p =>
    obtain ⟨hp, hb⟩ := he
    cases p with
    | inl a => exact ⟨pres hi t a, fun h => hb ((liftP_inl hi.inj t.bad a).1 h)⟩
    | inr w => exact ⟨(jpresent_inr hi t w).2 hp, hb⟩
  | disable a =>
    obtain ⟨hs, ho⟩ := he
    exact ⟨pres hi t a, (hi.switches a).2 hs, fun h => ho ((liftM_map hi.inj t.off a).1 h)⟩
  | join =>
    obtain ⟨hj, hnj⟩ := he
    exact ⟨fun h => hj (hi.joiner ▸ h), hi.joiner_free, hnj⟩

theorem struck_lift (hi : InitialPart sys small ι β σ) (t : State M₀ W) (c : S₀)
    (P : Proc M₀ W → Prop) (p : Proc M W) :
    (liftP ι P p ∨ JStruck sys (lift ι t) (σ c) p) ↔
      liftP ι (fun q => P q ∨ Struck small t c q) p := by
  cases p with
  | inl m =>
    show ((∃ a, ι a = m ∧ P (.inl a)) ∨ JStruck sys (lift ι t) (σ c) (.inl m)) ↔
      ∃ a, ι a = m ∧ (P (.inl a) ∨ Struck small t c (.inl a))
    constructor
    · rintro (⟨a, rfl, h⟩ | ⟨w, e, _⟩)
      · exact ⟨a, rfl, .inl h⟩
      · cases e
    · rintro ⟨a, rfl, h | ⟨w, e, _⟩⟩
      · exact .inl ⟨a, rfl, h⟩
      · cases e
  | inr w =>
    show (P (.inr w) ∨ JStruck sys (lift ι t) (σ c) (.inr w)) ↔
      (P (.inr w) ∨ Struck small t c (.inr w))
    constructor
    · rintro (h | ⟨w', e, hp, hs⟩)
      · exact .inl h
      · exact .inr ⟨w, rfl, (jpresent_inr hi t w).1 hp,
          (map_eq_some hi.σ_inj _ _).1 ((hi.substrate_work w).symm.trans hs)⟩
    · rintro (h | ⟨w', e, hp, hs⟩)
      · exact .inl h
      · exact .inr ⟨w, rfl, (jpresent_inr hi t w).2 hp,
          (hi.substrate_work w).trans ((map_eq_some hi.σ_inj _ _).2 hs)⟩

theorem liftP_insert (P : Proc M₀ W → Prop)
    (p : Proc M₀ W) (q : Proc M W) :
    (q = pmap ι p ∨ liftP ι P q) ↔ liftP ι (fun q' => q' = p ∨ P q') q := by
  cases q with
  | inl m =>
    show ((Sum.inl m : Proc M W) = pmap ι p ∨ ∃ a, ι a = m ∧ P (.inl a)) ↔
      ∃ a, ι a = m ∧ ((Sum.inl a : Proc M₀ W) = p ∨ P (.inl a))
    constructor
    · rintro (h | ⟨a, rfl, h⟩)
      · cases p with
        | inl a =>
          have h' : (Sum.inl m : Proc M W) = .inl (ι a) := h
          exact ⟨a, (Sum.inl.inj h').symm, .inl rfl⟩
        | inr w =>
          have h' : (Sum.inl m : Proc M W) = .inr w := h
          cases h'
      · exact ⟨a, rfl, .inr h⟩
    · rintro ⟨a, rfl, h | h⟩
      · subst h
        exact .inl rfl
      · exact .inr ⟨a, rfl, h⟩
  | inr w =>
    show ((Sum.inr w : Proc M W) = pmap ι p ∨ P (.inr w)) ↔
      ((Sum.inr w : Proc M₀ W) = p ∨ P (.inr w))
    cases p with
    | inl a =>
      constructor
      · rintro (h | h)
        · have h' : (Sum.inr w : Proc M W) = .inl (ι a) := h
          cases h'
        · exact .inr h
      · rintro (h | h)
        · cases h
        · exact .inr h
    | inr w' =>
      constructor
      · rintro (h | h)
        · have h' : (Sum.inr w : Proc M W) = .inr w' := h
          cases h'
          exact .inl rfl
        · exact .inr h
      · rintro (h | h)
        · cases h
          exact .inl rfl
        · exact .inr h

/-- The effect of a mapped step on a lifted state is the lift of the effect. -/
theorem effect_map (hi : InitialPart sys small ι β σ) (t : State M₀ W)
    (e : EnvStep M₀ W B₀ S₀) :
    jeffect sys (lift ι t) (smap ι β σ e) = lift ι (effect small t e) := by
  cases e with
  | stop a =>
    refine jstate_eq (state_ext ?_ (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl)
      (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) Iff.rfl) rfl
    intro p
    cases p with
    | inl m =>
      show ((∃ a', ι a' = m ∧ t.alive (.inl a')) ∧ (Sum.inl m : Proc M W) ≠ .inl (ι a)) ↔
        ∃ a', ι a' = m ∧ (t.alive (.inl a') ∧ (Sum.inl a' : Proc M₀ W) ≠ .inl a)
      constructor
      · rintro ⟨⟨a', rfl, h⟩, hne⟩
        exact ⟨a', rfl, h, fun e => hne (by cases e; rfl)⟩
      · rintro ⟨a', rfl, h, hne⟩
        exact ⟨⟨a', rfl, h⟩, fun e => hne (by rw [hi.inj _ _ (Sum.inl.inj e)])⟩
    | inr w =>
      show (t.alive (.inr w) ∧ (Sum.inr w : Proc M W) ≠ .inl (ι a)) ↔
        (t.alive (.inr w) ∧ (Sum.inr w : Proc M₀ W) ≠ .inl a)
      exact ⟨fun ⟨h, _⟩ => ⟨h, fun e => nomatch e⟩, fun ⟨h, _⟩ => ⟨h, fun e => nomatch e⟩⟩
  | stopBoundary b =>
    refine jstate_eq (state_ext ?_ (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl)
      (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) Iff.rfl) rfl
    intro p
    cases p with
    | inl m =>
      show ((∃ a', ι a' = m ∧ t.alive (.inl a')) ∧ ∀ m', (Sum.inl m : Proc M W) = .inl m' →
          ¬ (sys.base.boundary m' = some (β b) ∧ JPresent sys (lift ι t) (.inl m'))) ↔
        ∃ a', ι a' = m ∧ (t.alive (.inl a') ∧
          ∀ a'', (Sum.inl a' : Proc M₀ W) = .inl a'' → small.boundary a'' ≠ some b)
      constructor
      · rintro ⟨⟨a', rfl, h⟩, hn⟩
        refine ⟨a', rfl, h, fun a'' e hb => ?_⟩
        cases e
        exact hn (ι a') rfl
          ⟨(hi.boundary a').trans ((map_eq_some hi.β_inj _ _).2 hb), pres hi t a'⟩
      · rintro ⟨a', rfl, h, hn⟩
        refine ⟨⟨a', rfl, h⟩, fun m' e hb => ?_⟩
        cases e
        exact hn a' rfl ((map_eq_some hi.β_inj _ _).1 ((hi.boundary a').symm.trans hb.1))
    | inr w =>
      show (t.alive (.inr w) ∧ ∀ m', (Sum.inr w : Proc M W) = .inl m' →
          ¬ (sys.base.boundary m' = some (β b) ∧ JPresent sys (lift ι t) (.inl m'))) ↔
        (t.alive (.inr w) ∧
          ∀ a'', (Sum.inr w : Proc M₀ W) = .inl a'' → small.boundary a'' ≠ some b)
      exact ⟨fun ⟨h, _⟩ => ⟨h, fun _ e => nomatch e⟩, fun ⟨h, _⟩ => ⟨h, fun _ e => nomatch e⟩⟩
  | failSubstrate c =>
    refine jstate_eq (state_ext ?_ (fun p => struck_lift hi t c t.bad p)
      (fun p => struck_lift hi t c t.hidden p) (fun _ => Iff.rfl)
      (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) Iff.rfl) rfl
    intro p
    cases p with
    | inl m =>
      show ((∃ a', ι a' = m ∧ t.alive (.inl a')) ∧ ∀ m', (Sum.inl m : Proc M W) = .inl m' →
          ¬ (sys.base.substrate (.inl m) = some (σ c) ∧
            JPresent sys (lift ι t) (.inl m))) ↔
        ∃ a', ι a' = m ∧ (t.alive (.inl a') ∧
          ∀ a'', (Sum.inl a' : Proc M₀ W) = .inl a'' → small.substrate (.inl a') ≠ some c)
      constructor
      · rintro ⟨⟨a', rfl, h⟩, hn⟩
        exact ⟨a', rfl, h, fun a'' _ hs => hn (ι a') rfl
          ⟨(hi.substrate_mon a').trans ((map_eq_some hi.σ_inj _ _).2 hs), pres hi t a'⟩⟩
      · rintro ⟨a', rfl, h, hn⟩
        exact ⟨⟨a', rfl, h⟩, fun m' _ hs => hn a' rfl
          ((map_eq_some hi.σ_inj _ _).1 ((hi.substrate_mon a').symm.trans hs.1))⟩
    | inr w =>
      show (t.alive (.inr w) ∧ ∀ m', (Sum.inr w : Proc M W) = .inl m' →
          ¬ (sys.base.substrate (.inr w) = some (σ c) ∧
            JPresent sys (lift ι t) (.inr w))) ↔
        (t.alive (.inr w) ∧
          ∀ a'', (Sum.inr w : Proc M₀ W) = .inl a'' → small.substrate (.inr w) ≠ some c)
      exact ⟨fun ⟨h, _⟩ => ⟨h, fun _ e => nomatch e⟩, fun ⟨h, _⟩ => ⟨h, fun _ e => nomatch e⟩⟩
  | mutate p =>
    exact jstate_eq (state_ext (fun _ => Iff.rfl) (fun q => liftP_insert t.bad p q)
      (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl)
      (fun _ => Iff.rfl) Iff.rfl) rfl
  | disable a =>
    refine jstate_eq (state_ext (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) ?_
      (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) Iff.rfl) rfl
    intro r
    show (r = ι a ∨ ∃ a', ι a' = r ∧ t.off a') ↔ ∃ a', ι a' = r ∧ (a' = a ∨ t.off a')
    constructor
    · rintro (h | ⟨a', rfl, h⟩)
      · exact ⟨a, h.symm, .inl rfl⟩
      · exact ⟨a', rfl, .inr h⟩
    · rintro ⟨a', rfl, h | h⟩
      · exact .inl (by rw [h])
      · exact .inr ⟨a', rfl, h⟩
  | join =>
    refine jstate_eq (state_ext ?_ (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl)
      (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) Iff.rfl) rfl
    intro p
    cases p with
    | inl m =>
      show ((∃ a, ι a = m ∧ t.alive (.inl a)) ∨
          ∃ w, (Sum.inl m : Proc M W) = .inr w ∧ sys.base.IsJoiner w) ↔
        ∃ a, ι a = m ∧ (t.alive (.inl a) ∨
          ∃ w, (Sum.inl a : Proc M₀ W) = .inr w ∧ small.IsJoiner w)
      constructor
      · rintro (⟨a, rfl, h⟩ | ⟨w, e, _⟩)
        · exact ⟨a, rfl, .inl h⟩
        · cases e
      · rintro ⟨a, rfl, h | ⟨w, e, _⟩⟩
        · exact .inl ⟨a, rfl, h⟩
        · cases e
    | inr w =>
      show (t.alive (.inr w) ∨
          ∃ w', (Sum.inr w : Proc M W) = .inr w' ∧ sys.base.IsJoiner w') ↔
        (t.alive (.inr w) ∨ ∃ w', (Sum.inr w : Proc M₀ W) = .inr w' ∧ small.IsJoiner w')
      constructor
      · rintro (h | ⟨w', e, hj⟩)
        · exact .inl h
        · cases e
          exact .inr ⟨w, rfl, (isJoiner_iff hi w).1 hj⟩
      · rintro (h | ⟨w', e, hj⟩)
        · exact .inl h
        · cases e
          exact .inr ⟨w, rfl, (isJoiner_iff hi w).2 hj⟩

/-- An environment phase of `small` maps to one of `sys`, step by step. -/
theorem envRun_map (hi : InitialPart sys small ι β σ) {t t₁ : State M₀ W}
    {steps : List (EnvStep M₀ W B₀ S₀)} (hr : EnvRun small t steps t₁) :
    JEnvRun sys (lift ι t) (steps.map (smap ι β σ)) (lift ι t₁) := by
  induction hr with
  | nil s => exact JEnvRun.nil _
  | cons he _ ih =>
    refine JEnvRun.cons (enabled_map hi _ _ he) ?_
    rw [effect_map hi]
    exact ih

/-! ### A process that is not present is not bad -/

/-- A non-monitor process that is bad is present. -/
def Inv (small : System M₀ W B₀ S₀) (t : State M₀ W) : Prop :=
  ∀ w, t.bad (.inr w) → small.IsJoiner w → t.joined

theorem inv_effect {t : State M₀ W} {e : EnvStep M₀ W B₀ S₀} (he : Enabled small t e)
    (h : Inv small t) : Inv small (effect small t e) := by
  cases e with
  | stop a => exact h
  | stopBoundary b => exact h
  | failSubstrate c =>
    intro w hb
    rcases hb with hb | ⟨w', _, hp, _⟩
    · exact h w hb
    · exact hp
  | mutate p =>
    obtain ⟨hp, _⟩ := he
    intro w hb
    rcases hb with hb | hb
    · subst hb
      exact hp
    · exact h w hb
  | disable a => exact h
  | join => exact fun _ _ _ => trivial

theorem inv_run {t t₁ : State M₀ W} {steps : List (EnvStep M₀ W B₀ S₀)}
    (hr : EnvRun small t steps t₁) (h : Inv small t) : Inv small t₁ := by
  induction hr with
  | nil s => exact h
  | cons he _ ih => exact ih (inv_effect he h)

theorem inv_afterEnv {t : State M₀ W} (h : Inv small t) :
    Inv small (afterEnv small t).next := by
  unfold afterEnv
  split
  · exact h
  · exact h

theorem inv_round {t : State M₀ W} {r : Outcome M₀ W} (h : Inv small t)
    (hr : Round small t r) : Inv small r.next := by
  obtain ⟨steps, t₁, _, hrun, rfl⟩ := hr
  exact inv_afterEnv (inv_run hrun h)

/-! ### The monitor and work phases

`E` stands for the system `effective sys (lift ι t) (lift ι t₁)`, and `jd` for whether the
joiner has joined after the environment phase. -/

/-- `E`, a system on the monitors of `sys`, has the edges of `small` and no other: none
with a monitor outside the image of `ι` at an end, and those at a non-monitor process only
if it is present. -/
structure Corr (E : System M W B S) (small : System M₀ W B₀ S₀) (ι : M₀ → M) (jd : Prop) :
    Prop where
  inj : ∀ a b, ι a = ι b → a = b
  hb : ∀ p m, E.hbReaders p m ↔ ∃ a b, ι a = p ∧ ι b = m ∧ small.hbReaders a b
  checkM : ∀ p m, E.checkers (.inl p) m ↔
    ∃ a b, ι a = p ∧ ι b = m ∧ small.checkers (.inl a) b
  checkW : ∀ w m, E.checkers (.inr w) m ↔
    ∃ b, ι b = m ∧ small.checkers (.inr w) b ∧ (small.IsJoiner w → jd)
  fwd : ∀ m r, E.fwd m r ↔ ∃ a b, ι a = m ∧ ι b = r ∧ small.fwd a b
  halt : ∀ w m, E.haltInputs w m ↔
    ∃ b, ι b = m ∧ small.haltInputs w b ∧ (small.IsJoiner w → jd)
  joiner : E.joiner = small.joiner
  coupling : E.coupling = small.coupling
  window : E.window = small.window
  gate : E.gate = small.gate
  slowReports : E.slowReports = small.slowReports

theorem not_new_inl (t t₁ : State M₀ W) (m : M) :
    ¬ JNew sys (lift ι t) (lift ι t₁) (.inl m) :=
  fun ⟨h1, h2⟩ => h2 h1

theorem new_inr {t t₁ : State M₀ W} {w : W}
    (h : JNew sys (lift ι t) (lift ι t₁) (.inr w)) : sys.base.IsJoiner w :=
  Classical.byContradiction fun hn => h.2 fun hj => (hn hj).elim

/-- The edges in force in a round between lifted states are the edges of `small`. -/
theorem corr_effective (hi : InitialPart sys small ι β σ) (t t₁ : State M₀ W) :
    Corr (effective sys (lift ι t) (lift ι t₁)) small ι t₁.joined where
  inj := hi.inj
  hb := by
    intro p m
    constructor
    · rintro ⟨h, hp, hm, _⟩
      obtain ⟨a, rfl⟩ := (jpresent_inl hi t₁ p).1 hp
      obtain ⟨b, rfl⟩ := (jpresent_inl hi t₁ m).1 hm
      exact ⟨a, b, rfl, rfl, (hi.hb a b).1 h⟩
    · rintro ⟨a, b, rfl, rfl, h⟩
      exact ⟨(hi.hb a b).2 h, pres hi t₁ a, pres hi t₁ b,
        fun _ => ⟨not_new_inl t t₁ _, not_new_inl t t₁ _⟩⟩
  checkM := by
    intro p m
    constructor
    · rintro ⟨h, hp, hm, _⟩
      obtain ⟨a, rfl⟩ := (jpresent_inl hi t₁ p).1 hp
      obtain ⟨b, rfl⟩ := (jpresent_inl hi t₁ m).1 hm
      exact ⟨a, b, rfl, rfl, (hi.check_mon a b).1 h⟩
    · rintro ⟨a, b, rfl, rfl, h⟩
      exact ⟨(hi.check_mon a b).2 h, pres hi t₁ a, pres hi t₁ b,
        fun _ => ⟨not_new_inl t t₁ _, not_new_inl t t₁ _⟩⟩
  checkW := by
    intro w m
    constructor
    · rintro ⟨h, hp, hm, _⟩
      obtain ⟨b, rfl⟩ := (jpresent_inl hi t₁ m).1 hm
      exact ⟨b, rfl, (hi.check_work w b).1 h, (jpresent_inr hi t₁ w).1 hp⟩
    · rintro ⟨b, rfl, h, hp⟩
      exact ⟨(hi.check_work w b).2 h, (jpresent_inr hi t₁ w).2 hp, pres hi t₁ b,
        fun hslow => ⟨fun hn => (hi.joiner_prompt w (ι b) (new_inr hn)).1 hslow,
          not_new_inl t t₁ _⟩⟩
  fwd := by
    intro p m
    constructor
    · rintro ⟨h, hp, hm, _⟩
      obtain ⟨a, rfl⟩ := (jpresent_inl hi t₁ p).1 hp
      obtain ⟨b, rfl⟩ := (jpresent_inl hi t₁ m).1 hm
      exact ⟨a, b, rfl, rfl, (hi.fwd a b).1 h⟩
    · rintro ⟨a, b, rfl, rfl, h⟩
      exact ⟨(hi.fwd a b).2 h, pres hi t₁ a, pres hi t₁ b,
        fun _ => ⟨not_new_inl t t₁ _, not_new_inl t t₁ _⟩⟩
  halt := by
    intro w m
    constructor
    · rintro ⟨h, hp, hm, _⟩
      obtain ⟨b, rfl⟩ := (jpresent_inl hi t₁ m).1 hm
      exact ⟨b, rfl, (hi.halt w b).1 h, (jpresent_inr hi t₁ w).1 hp⟩
    · rintro ⟨b, rfl, h, hp⟩
      exact ⟨(hi.halt w b).2 h, (jpresent_inr hi t₁ w).2 hp, pres hi t₁ b,
        fun hslow => ⟨fun hn => (hi.joiner_prompt w (ι b) (new_inr hn)).2 hslow,
          not_new_inl t t₁ _⟩⟩
  joiner := hi.joiner
  coupling := hi.coupling
  window := hi.window
  gate := hi.gate
  slowReports := hi.slowReports

variable {E : System M W B S} {jd : Prop}

theorem active_iff (hinj : ∀ a b, ι a = ι b → a = b) (u : State M₀ W) (m : M) :
    Active (liftSt ι u) m ↔ ∃ a, ι a = m ∧ Active u a := by
  constructor
  · rintro ⟨⟨a, rfl, ha⟩, hb, ho⟩
    exact ⟨a, rfl, ha, fun h => hb ⟨a, rfl, h⟩, fun h => ho ⟨a, rfl, h⟩⟩
  · rintro ⟨a, rfl, ha, hb, ho⟩
    exact ⟨⟨a, rfl, ha⟩, fun h => hb ((liftP_inl hinj u.bad a).1 h),
      fun h => ho ((liftM_map hinj u.off a).1 h)⟩

theorem active_map (hinj : ∀ a b, ι a = ι b → a = b) (u : State M₀ W) (a : M₀) :
    Active (liftSt ι u) (ι a) ↔ Active u a :=
  (active_iff hinj u (ι a)).trans (ex_iff hinj (fun a => Active u a) a)

theorem visible_inl (hinj : ∀ a b, ι a = ι b → a = b) (u : State M₀ W) (m : M) :
    Visible (liftSt ι u) (.inl m) ↔ ∃ a, ι a = m ∧ Visible u (.inl a) := by
  constructor
  · rintro ⟨⟨a, rfl, hb⟩, hh⟩
    exact ⟨a, rfl, hb, fun h => hh ⟨a, rfl, h⟩⟩
  · rintro ⟨a, rfl, hb, hh⟩
    exact ⟨⟨a, rfl, hb⟩, fun h => hh ((liftP_inl hinj u.hidden a).1 h)⟩

theorem visible_map (hinj : ∀ a b, ι a = ι b → a = b) (u : State M₀ W) (a : M₀) :
    Visible (liftSt ι u) (.inl (ι a)) ↔ Visible u (.inl a) :=
  (visible_inl hinj u (ι a)).trans (ex_iff hinj (fun a => Visible u (.inl a)) a)

theorem detects_iff (hc : Corr E small ι jd) (u : State M₀ W)
    (hinv : ∀ w, u.bad (.inr w) → small.IsJoiner w → jd) (m : M) :
    Detects E (liftSt ι u) m ↔ ∃ a, ι a = m ∧ Detects small u a := by
  constructor
  · rintro ⟨hact, hd⟩
    obtain ⟨a, rfl, ha⟩ := (active_iff hc.inj u m).1 hact
    refine ⟨a, rfl, ha, ?_⟩
    rcases hd with ⟨x, hv, hx⟩ | ⟨p, hp, hr⟩
    · left
      cases x with
      | inl p =>
        obtain ⟨a', b, rfl, hb, hch⟩ := (hc.checkM p _).1 hx
        have e := hc.inj _ _ hb
        subst e
        exact ⟨.inl a', (visible_map hc.inj u a').1 hv, hch⟩
      | inr w =>
        obtain ⟨b, hb, hch, _⟩ := (hc.checkW w _).1 hx
        have e := hc.inj _ _ hb
        subst e
        exact ⟨.inr w, hv, hch⟩
    · right
      obtain ⟨a', b, rfl, hb, hh⟩ := (hc.hb p _).1 hr
      have e := hc.inj _ _ hb
      subst e
      exact ⟨a', fun h => hp ⟨a', rfl, h⟩, hh⟩
  · rintro ⟨a, rfl, hact, hd⟩
    refine ⟨(active_map hc.inj u a).2 hact, ?_⟩
    rcases hd with ⟨x, hv, hx⟩ | ⟨p, hp, hr⟩
    · left
      cases x with
      | inl p =>
        exact ⟨.inl (ι p), (visible_map hc.inj u p).2 hv, (hc.checkM _ _).2 ⟨p, a, rfl, rfl, hx⟩⟩
      | inr w =>
        exact ⟨.inr w, hv, (hc.checkW _ _).2 ⟨a, rfl, hx, hinv w hv.1⟩⟩
    · right
      exact ⟨ι p, fun h => hp ((liftP_inl hc.inj u.alive p).1 h),
        (hc.hb _ _).2 ⟨p, a, rfl, rfl, hr⟩⟩

theorem fod_iff (hc : Corr E small ι jd) (u : State M₀ W)
    (hinv : ∀ w, u.bad (.inr w) → small.IsJoiner w → jd) (m : M) :
    FlaggedOrDetects E (liftSt ι u) m ↔ ∃ a, ι a = m ∧ FlaggedOrDetects small u a := by
  constructor
  · rintro (⟨a, rfl, h⟩ | h)
    · exact ⟨a, rfl, .inl h⟩
    · obtain ⟨a, rfl, h'⟩ := (detects_iff hc u hinv m).1 h
      exact ⟨a, rfl, .inr h'⟩
  · rintro ⟨a, rfl, h | h⟩
    · exact .inl ⟨a, rfl, h⟩
    · exact .inr ((detects_iff hc u hinv _).2 ⟨a, rfl, h⟩)

theorem spread_iff (hc : Corr E small ι jd) (u : State M₀ W) (F : M₀ → Prop) (F' : M → Prop)
    (hF : ∀ m, F' m ↔ ∃ a, ι a = m ∧ F a) (m : M) :
    Spread E (liftSt ι u) F' m ↔ ∃ a, ι a = m ∧ Spread small u F a := by
  constructor
  · intro h
    induction h with
    | base hf =>
      obtain ⟨a, rfl, ha⟩ := (hF _).1 hf
      exact ⟨a, rfl, .base ha⟩
    | step _ hm hfw hr ih =>
      obtain ⟨a, rfl, hsa⟩ := ih
      obtain ⟨a', b, e, rfl, hf⟩ := (hc.fwd _ _).1 hfw
      have e' := hc.inj _ _ e
      subst e'
      exact ⟨b, rfl, .step hsa ((active_map hc.inj u _).1 hm) hf
        ((active_map hc.inj u _).1 hr)⟩
  · rintro ⟨a, rfl, h⟩
    induction h with
    | base hf => exact .base ((hF _).2 ⟨_, rfl, hf⟩)
    | step _ hm hfw hr ih =>
      exact .step ih ((active_map hc.inj u _).2 hm) ((hc.fwd _ _).2 ⟨_, _, rfl, rfl, hfw⟩)
        ((active_map hc.inj u _).2 hr)

theorem flaggedAfter_slow {M W B S : Type} (sys : System M W B S) (s : State M W)
    (h : sys.slowReports = true) :
    flaggedAfter sys s = fun r => FlaggedOrDetects sys s r ∨
      ∃ m, s.flagged m ∧ Active s m ∧ sys.fwd m r ∧ Active s r := by
  unfold flaggedAfter
  exact ite_eq_left h

theorem flaggedAfter_fast {M W B S : Type} (sys : System M W B S) (s : State M W)
    (h : ¬ sys.slowReports = true) :
    flaggedAfter sys s = Spread sys s (FlaggedOrDetects sys s) := by
  unfold flaggedAfter
  exact ite_eq_right h

theorem flaggedAfter_iff (hc : Corr E small ι jd) (u : State M₀ W)
    (hinv : ∀ w, u.bad (.inr w) → small.IsJoiner w → jd) (m : M) :
    flaggedAfter E (liftSt ι u) m ↔ ∃ a, ι a = m ∧ flaggedAfter small u a := by
  by_cases hs : small.slowReports = true
  · rw [flaggedAfter_slow E _ (hc.slowReports.trans hs), flaggedAfter_slow small _ hs]
    constructor
    · rintro (h | ⟨m', hf, hm', hfw, hm⟩)
      · obtain ⟨a, rfl, h'⟩ := (fod_iff hc u hinv m).1 h
        exact ⟨a, rfl, .inl h'⟩
      · obtain ⟨a', b, rfl, rfl, hfw'⟩ := (hc.fwd _ _).1 hfw
        exact ⟨b, rfl, .inr ⟨a', (liftM_map hc.inj u.flagged a').1 hf,
          (active_map hc.inj u a').1 hm', hfw', (active_map hc.inj u b).1 hm⟩⟩
    · rintro ⟨a, rfl, h | ⟨a', hf, hm', hfw, hm⟩⟩
      · exact .inl ((fod_iff hc u hinv _).2 ⟨a, rfl, h⟩)
      · exact .inr ⟨ι a', ⟨a', rfl, hf⟩, (active_map hc.inj u a').2 hm',
          (hc.fwd _ _).2 ⟨a', a, rfl, rfl, hfw⟩, (active_map hc.inj u a).2 hm⟩
  · rw [flaggedAfter_fast E _ (fun h => hs (hc.slowReports.symm.trans h)),
      flaggedAfter_fast small _ hs]
    exact spread_iff hc u _ _ (fod_iff hc u hinv) m

theorem monitorPhase_lift (hc : Corr E small ι jd) (u : State M₀ W)
    (hinv : ∀ w, u.bad (.inr w) → small.IsJoiner w → jd) :
    monitorPhase E (liftSt ι u) = liftSt ι (monitorPhase small u) :=
  state_ext (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl)
    (fun m => flaggedAfter_iff hc u hinv m) (fun _ => Iff.rfl) (fun _ => Iff.rfl) Iff.rfl

theorem out_iff (hinj : ∀ a b, ι a = ι b → a = b) (u : State M₀ W) (m : M) :
    Out (liftSt ι u) m ↔ ∃ a, ι a = m ∧ Out u a := by
  constructor
  · rintro ⟨⟨a, rfl, hf⟩, ha, hb⟩
    exact ⟨a, rfl, hf, (liftP_inl hinj u.alive a).1 ha, fun h => hb ⟨a, rfl, h⟩⟩
  · rintro ⟨a, rfl, hf, ha, hb⟩
    exact ⟨⟨a, rfl, hf⟩, ⟨a, rfl, ha⟩, fun h => hb ((liftP_inl hinj u.bad a).1 h)⟩

theorem out_ex_iff (hinj : ∀ a b, ι a = ι b → a = b) (u : State M₀ W) :
    (∃ m, Out (liftSt ι u) m) ↔ ∃ a, Out u a := by
  constructor
  · rintro ⟨m, h⟩
    obtain ⟨a, _, h⟩ := (out_iff hinj u m).1 h
    exact ⟨a, h⟩
  · rintro ⟨a, h⟩
    exact ⟨ι a, (out_iff hinj u _).2 ⟨a, rfl, h⟩⟩

theorem bad_ex_iff (ι : M₀ → M) (u : State M₀ W) :
    (∃ p, (liftSt ι u).bad p) ↔ ∃ p, u.bad p := by
  constructor
  · rintro ⟨p, h⟩
    cases p with
    | inl m =>
      obtain ⟨a, _, h⟩ := h
      exact ⟨.inl a, h⟩
    | inr w => exact ⟨.inr w, h⟩
  · rintro ⟨p, h⟩
    cases p with
    | inl a => exact ⟨.inl (ι a), a, rfl, h⟩
    | inr w => exact ⟨.inr w, h⟩

theorem sees_iff (hc : Corr E small ι jd) (u : State M₀ W) (o : M₀ → Prop) (o' : M → Prop)
    (ho : ∀ m, o' m ↔ ∃ a, ι a = m ∧ o a) (w : W) (hw : small.IsJoiner w → jd) :
    Sees E (liftSt ι u) o' w ↔ Sees small u o w := by
  constructor
  · rintro (⟨m, hh, hom⟩ | ⟨hcp, m, hh, hna⟩)
    · obtain ⟨b, rfl, hh', _⟩ := (hc.halt w m).1 hh
      exact .inl ⟨b, hh', (ex_iff hc.inj o b).1 ((ho _).1 hom)⟩
    · obtain ⟨b, rfl, hh', _⟩ := (hc.halt w m).1 hh
      exact .inr ⟨hc.coupling.symm.trans hcp, b, hh', fun h => hna ⟨b, rfl, h⟩⟩
  · rintro (⟨b, hh, hob⟩ | ⟨hcp, b, hh, hna⟩)
    · exact .inl ⟨ι b, (hc.halt w _).2 ⟨b, rfl, hh, hw⟩, (ho _).2 ⟨b, rfl, hob⟩⟩
    · exact .inr ⟨hc.coupling.trans hcp, ι b, (hc.halt w _).2 ⟨b, rfl, hh, hw⟩,
        fun h => hna ((liftP_inl hc.inj u.alive b).1 h)⟩

theorem handled_iff (hc : Corr E small ι jd) (u : State M₀ W) (w : W) :
    Handled E (liftSt ι u) w ↔ Handled small u w := by
  show ((E.joiner = some w → u.joined) ∧ ¬ u.halted w) ↔
    ((small.joiner = some w → u.joined) ∧ ¬ u.halted w)
  rw [hc.joiner]

theorem sees_handled (hc : Corr E small ι jd) (u : State M₀ W) (hj : u.joined ↔ jd)
    (o : M₀ → Prop) (o' : M → Prop) (ho : ∀ m, o' m ↔ ∃ a, ι a = m ∧ o a) (w : W)
    (hh : Handled small u w) : Sees E (liftSt ι u) o' w ↔ Sees small u o w :=
  sees_iff hc u o o' ho w fun hjn => hj.1 (hh.1 hjn)

theorem worked_iff (hc : Corr E small ι jd) (u : State M₀ W) (hj : u.joined ↔ jd)
    (o : M₀ → Prop) (o' : M → Prop) (ho : ∀ m, o' m ↔ ∃ a, ι a = m ∧ o a) (w : W) :
    Worked E (liftSt ι u) o' w ↔ Worked small u o w := by
  constructor
  · rintro ⟨hh, hp, hn⟩
    have hh' := (handled_iff hc u w).1 hh
    exact ⟨hh', hp, fun ⟨hs, hw⟩ =>
      hn ⟨(sees_handled hc u hj o o' ho w hh').2 hs, hc.window.trans hw⟩⟩
  · rintro ⟨hh, hp, hn⟩
    exact ⟨(handled_iff hc u w).2 hh, hp, fun ⟨hs, hw⟩ =>
      hn ⟨(sees_handled hc u hj o o' ho w hh).1 hs, hc.window.symm.trans hw⟩⟩

theorem workPhase_lift (hc : Corr E small ι jd) (u : State M₀ W) (hj : u.joined ↔ jd)
    (o : M₀ → Prop) (o' : M → Prop) (ho : ∀ m, o' m ↔ ∃ a, ι a = m ∧ o a) :
    workPhase E (liftSt ι u) o' = liftSt ι (workPhase small u o) := by
  refine state_ext (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl) (fun _ => Iff.rfl)
    (fun _ => Iff.rfl) ?_ ?_ Iff.rfl
  · intro w
    show (u.halted w ∨ (Handled E (liftSt ι u) w ∧
        (u.pending w ∨ (Sees E (liftSt ι u) o' w ∧ E.window = 0)))) ↔
      (u.halted w ∨ (Handled small u w ∧ (u.pending w ∨ (Sees small u o w ∧ small.window = 0))))
    constructor
    · rintro (h | ⟨hh, hp | ⟨hs, hw⟩⟩)
      · exact .inl h
      · exact .inr ⟨(handled_iff hc u w).1 hh, .inl hp⟩
      · have hh' := (handled_iff hc u w).1 hh
        exact .inr ⟨hh', .inr ⟨(sees_handled hc u hj o o' ho w hh').1 hs,
          hc.window.symm.trans hw⟩⟩
    · rintro (h | ⟨hh, hp | ⟨hs, hw⟩⟩)
      · exact .inl h
      · exact .inr ⟨(handled_iff hc u w).2 hh, .inl hp⟩
      · exact .inr ⟨(handled_iff hc u w).2 hh, .inr ⟨(sees_handled hc u hj o o' ho w hh).2 hs,
          hc.window.trans hw⟩⟩
  · intro w
    show ((u.pending w ∧ ¬ Handled E (liftSt ι u) w) ∨
        (Handled E (liftSt ι u) w ∧ ¬ u.pending w ∧ Sees E (liftSt ι u) o' w ∧
          E.window ≠ 0)) ↔
      ((u.pending w ∧ ¬ Handled small u w) ∨
        (Handled small u w ∧ ¬ u.pending w ∧ Sees small u o w ∧ small.window ≠ 0))
    constructor
    · rintro (⟨hp, hn⟩ | ⟨hh, hp, hs, hw⟩)
      · exact .inl ⟨hp, fun h => hn ((handled_iff hc u w).2 h)⟩
      · have hh' := (handled_iff hc u w).1 hh
        exact .inr ⟨hh', hp, (sees_handled hc u hj o o' ho w hh').1 hs,
          fun h => hw (hc.window.trans h)⟩
    · rintro (⟨hp, hn⟩ | ⟨hh, hp, hs, hw⟩)
      · exact .inl ⟨hp, fun h => hn ((handled_iff hc u w).1 h)⟩
      · exact .inr ⟨(handled_iff hc u w).2 hh, hp, (sees_handled hc u hj o o' ho w hh).2 hs,
          fun h => hw (hc.window.symm.trans h)⟩

theorem afterEnv_gate {M W B S : Type} (sys : System M W B S) (s : State M W)
    (hg : sys.gate = true) :
    afterEnv sys s =
      { next := workPhase sys (monitorPhase sys s) (Out (monitorPhase sys s))
        g1 := (∃ p, (monitorPhase sys s).bad p) ∧ ¬ ∃ m, Out (monitorPhase sys s) m
        g2 := (∃ p, (monitorPhase sys s).bad p) ∧
          ∃ w, Worked sys (monitorPhase sys s) (Out (monitorPhase sys s)) w } := by
  unfold afterEnv
  exact ite_eq_left hg

theorem afterEnv_nogate {M W B S : Type} (sys : System M W B S) (s : State M W)
    (hg : ¬ sys.gate = true) :
    afterEnv sys s =
      { next := monitorPhase sys (workPhase sys s (Out s))
        g1 := (∃ p, (monitorPhase sys (workPhase sys s (Out s))).bad p) ∧
          ¬ ∃ m, Out (monitorPhase sys (workPhase sys s (Out s))) m
        g2 := (∃ p, s.bad p) ∧ ∃ w, Worked sys s (Out s) w } := by
  unfold afterEnv
  exact ite_eq_right hg

/-- The monitor and work phases of `E` on a lifted state are those of `small`, in both
orders of the phases. -/
theorem afterEnv_lift (hc : Corr E small ι jd) (u : State M₀ W) (hj : u.joined ↔ jd)
    (hinv : ∀ w, u.bad (.inr w) → small.IsJoiner w → jd) :
    (afterEnv E (liftSt ι u)).next = liftSt ι (afterEnv small u).next ∧
    ((afterEnv E (liftSt ι u)).g1 ↔ (afterEnv small u).g1) ∧
    ((afterEnv E (liftSt ι u)).g2 ↔ (afterEnv small u).g2) := by
  by_cases hg : small.gate = true
  · rw [afterEnv_gate E _ (hc.gate.trans hg), afterEnv_gate small _ hg]
    have hm := monitorPhase_lift hc u hinv
    have hj' : (monitorPhase small u).joined ↔ jd := hj
    refine ⟨?_, ?_, ?_⟩
    · show workPhase E (monitorPhase E (liftSt ι u)) (Out (monitorPhase E (liftSt ι u))) =
        liftSt ι (workPhase small (monitorPhase small u) (Out (monitorPhase small u)))
      rw [hm]
      exact workPhase_lift hc _ hj' _ _ (out_iff hc.inj _)
    · show ((∃ p, (monitorPhase E (liftSt ι u)).bad p) ∧
          ¬ ∃ m, Out (monitorPhase E (liftSt ι u)) m) ↔
        ((∃ p, (monitorPhase small u).bad p) ∧ ¬ ∃ m, Out (monitorPhase small u) m)
      rw [hm, bad_ex_iff, out_ex_iff hc.inj]
    · show ((∃ p, (monitorPhase E (liftSt ι u)).bad p) ∧
          ∃ w, Worked E (monitorPhase E (liftSt ι u)) (Out (monitorPhase E (liftSt ι u))) w) ↔
        ((∃ p, (monitorPhase small u).bad p) ∧
          ∃ w, Worked small (monitorPhase small u) (Out (monitorPhase small u)) w)
      rw [hm]
      exact and_congr (bad_ex_iff ι _)
        (exists_congr fun w => worked_iff hc _ hj' _ _ (out_iff hc.inj _) w)
  · rw [afterEnv_nogate E _ (fun h => hg (hc.gate.symm.trans h)), afterEnv_nogate small _ hg]
    have hw := workPhase_lift hc u hj (Out u) (Out (liftSt ι u)) (out_iff hc.inj u)
    have hinv' : ∀ w, (workPhase small u (Out u)).bad (.inr w) → small.IsJoiner w → jd := hinv
    have hm := monitorPhase_lift hc (workPhase small u (Out u)) hinv'
    refine ⟨?_, ?_, ?_⟩
    · show monitorPhase E (workPhase E (liftSt ι u) (Out (liftSt ι u))) =
        liftSt ι (monitorPhase small (workPhase small u (Out u)))
      rw [hw, hm]
    · show ((∃ p, (monitorPhase E (workPhase E (liftSt ι u) (Out (liftSt ι u)))).bad p) ∧
          ¬ ∃ m, Out (monitorPhase E (workPhase E (liftSt ι u) (Out (liftSt ι u)))) m) ↔
        ((∃ p, (monitorPhase small (workPhase small u (Out u))).bad p) ∧
          ¬ ∃ m, Out (monitorPhase small (workPhase small u (Out u))) m)
      rw [hw, hm, bad_ex_iff, out_ex_iff hc.inj]
    · show ((∃ p, (liftSt ι u).bad p) ∧ ∃ w, Worked E (liftSt ι u) (Out (liftSt ι u)) w) ↔
        ((∃ p, u.bad p) ∧ ∃ w, Worked small u (Out u) w)
      exact and_congr (bad_ex_iff ι u)
        (exists_congr fun w => worked_iff hc u hj _ _ (out_iff hc.inj u) w)

/-! ### Rounds and executions -/

/-- A round of `small` maps to a round of `sys` between lifted states, with the same
violations. -/
theorem round_map (hi : InitialPart sys small ι β σ) (t : State M₀ W) (hinv : Inv small t)
    (r : Outcome M₀ W) (hr : Round small t r) :
    ∃ r' : JOutcome M W G, JRound sys (lift ι t) r' ∧ r'.next = lift ι r.next ∧
      (r'.g1 ↔ r.g1) ∧ (r'.g2 ↔ r.g2) := by
  obtain ⟨steps, t₁, hlen, hrun, rfl⟩ := hr
  have hinv₁ : Inv small t₁ := inv_run hrun hinv
  have hc := corr_effective hi t t₁
  obtain ⟨hn, h1, h2⟩ := afterEnv_lift hc t₁ Iff.rfl hinv₁
  refine ⟨jafterEnv sys (lift ι t) (lift ι t₁),
    ⟨steps.map (smap ι β σ), lift ι t₁, ?_, envRun_map hi hrun, rfl⟩, ?_, h1, h2⟩
  · rw [List.length_map, hi.f]
    exact hlen
  · exact jstate_eq hn rfl

theorem responded_iff (hi : InitialPart sys small ι β σ) (t : State M₀ W) :
    JResponded sys (lift ι t) ↔ Responded small t := by
  constructor
  · rintro ⟨⟨m, ⟨a, rfl, hf⟩, ha, hb⟩, hw⟩
    exact ⟨⟨a, hf, (liftP_inl hi.inj t.alive a).1 ha, fun h => hb ⟨a, rfl, h⟩⟩,
      fun w hp => hw w ((jpresent_inr hi t w).2 hp)⟩
  · rintro ⟨⟨a, hf, ha, hb⟩, hw⟩
    exact ⟨⟨ι a, ⟨a, rfl, hf⟩, ⟨a, rfl, ha⟩, fun h => hb ((liftP_inl hi.inj t.bad a).1 h)⟩,
      fun w hp => hw w ((jpresent_inr hi t w).1 hp)⟩

/-- The lift of a reachable state of `small` is a reachable state of `sys`. -/
theorem reachable_lift (hi : InitialPart sys small ι β σ) {t : State M₀ W}
    (h : Reachable small t) : JReachable sys (lift ι t) ∧ Inv small t := by
  induction h with
  | init =>
    refine ⟨?_, fun _ h => h.elim⟩
    rw [init_lift hi]
    exact JReachable.init
  | round _ hnr hr ih =>
    obtain ⟨r', hr', hn, _, _⟩ := round_map hi _ ih.2 _ hr
    refine ⟨?_, inv_round ih.2 hr⟩
    rw [← hn]
    exact JReachable.round ih.1 (fun h => hnr ((responded_iff hi _).1 h)) hr'

end

/-- Lemma N: late monitors never help. -/
theorem lemma_N {G M₀ B₀ S₀ : Type} (sys : JSystem M W B S G) (small : System M₀ W B₀ S₀)
    (ι : M₀ → M) (β : B₀ → B) (σ : S₀ → S) (hi : InitialPart sys small ι β σ) :
    (ViolatesG1 small → JViolatesG1 sys) ∧ (ViolatesG2 small → JViolatesG2 sys) := by
  constructor
  · rintro ⟨t, r, hre, hnr, hr, hg⟩
    obtain ⟨hjr, hinv⟩ := reachable_lift hi hre
    obtain ⟨r', hr', _, h1, _⟩ := round_map hi t hinv r hr
    exact ⟨lift ι t, r', hjr, fun h => hnr ((responded_iff hi t).1 h), hr', h1.2 hg⟩
  · rintro ⟨t, r, hre, hnr, hr, hg⟩
    obtain ⟨hjr, hinv⟩ := reachable_lift hi hre
    obtain ⟨r', hr', _, _, h2⟩ := round_map hi t hinv r hr
    exact ⟨lift ι t, r', hjr, fun h => hnr ((responded_iff hi t).1 h), hr', h2.2 hg⟩

end JoinLemmaN
end SelfObserving
