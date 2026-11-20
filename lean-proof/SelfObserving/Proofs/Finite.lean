/-
The model, made decidable on the types of the reference system.

`Model.lean` writes every set as a predicate, so that it covers systems of any size. On
the reference system's types (three monitors, three non-monitor processes) every one of
those predicates can be decided. This file says how:

- an instance of `Decidable` for each of `System.IsJoiner`, `Present`, `Enabled`,
  `Struck`, `Active`, `Visible`, `Detects`, `FlaggedOrDetects`, `Out`, `Sees`, `Handled`,
  `Worked` and `Responded`, on a system whose relations are decidable (`DecSys`) and a
  state whose components are decidable (`DecState`), and the same for the states that
  `init`, `effect` and `workPhase` give. `Sees`, `Worked` and `workPhase` take the set
  `out` as a predicate, which has to be decidable too;
- `CState`, a state written out as 31 truth values, with `CState.toState` into the
  model's states and `reify` back;
- `spread_iff`, proved by induction: among three monitors a flag that spreads at all
  spreads along at most two report edges (`Edge`, which also gets an instance). `Spread`
  is an inductive predicate and gets no instance; `cflag` computes `flaggedAfter` by this
  fact;
- `cafter`, which computes the phases after the environment phase on a `CState`: the next
  state, and whether the round violates G1 and G2. `cafter_spec` says it is `afterEnv`.

No instance is given for `Spread`, `flaggedAfter`, `EnvRun`, `Round`, `Reachable`,
`NoGap`, `ViolatesG1` or `ViolatesG2`. `Proofs/Explore.lean` deals with `EnvRun`, `Round`,
`Reachable` and the last three.

Nothing here mentions a particular system. The file imports `Reference.lean` for the four
types only.
-/
import SelfObserving.Reference

namespace SelfObserving
namespace Finite

/-! ### Quantifiers over the finite types -/

theorem exists_mon (q : Mon → Prop) : (∃ x, q x) ↔ q .M1 ∨ q .M2 ∨ q .M3 := by
  constructor
  · rintro ⟨x, h⟩
    cases x
    · exact .inl h
    · exact .inr (.inl h)
    · exact .inr (.inr h)
  · rintro (h | h | h) <;> exact ⟨_, h⟩

theorem forall_mon (q : Mon → Prop) : (∀ x, q x) ↔ q .M1 ∧ q .M2 ∧ q .M3 := by
  constructor
  · intro h
    exact ⟨h _, h _, h _⟩
  · rintro ⟨h1, h2, h3⟩ x
    cases x <;> assumption

theorem exists_wk (q : Wk → Prop) : (∃ x, q x) ↔ q .W1 ∨ q .W2 ∨ q .J := by
  constructor
  · rintro ⟨x, h⟩
    cases x
    · exact .inl h
    · exact .inr (.inl h)
    · exact .inr (.inr h)
  · rintro (h | h | h) <;> exact ⟨_, h⟩

theorem forall_wk (q : Wk → Prop) : (∀ x, q x) ↔ q .W1 ∧ q .W2 ∧ q .J := by
  constructor
  · intro h
    exact ⟨h _, h _, h _⟩
  · rintro ⟨h1, h2, h3⟩ x
    cases x <;> assumption

theorem exists_proc (q : Proc Mon Wk → Prop) :
    (∃ p, q p) ↔ (∃ m, q (.inl m)) ∨ ∃ w, q (.inr w) := by
  constructor
  · rintro ⟨p, h⟩
    cases p with
    | inl m => exact .inl ⟨m, h⟩
    | inr w => exact .inr ⟨w, h⟩
  · rintro (⟨m, h⟩ | ⟨w, h⟩) <;> exact ⟨_, h⟩

instance decExistsMon (q : Mon → Prop) [DecidablePred q] : Decidable (∃ x, q x) :=
  decidable_of_iff _ (exists_mon q).symm

instance decForallMon (q : Mon → Prop) [DecidablePred q] : Decidable (∀ x, q x) :=
  decidable_of_iff _ (forall_mon q).symm

instance decExistsWk (q : Wk → Prop) [DecidablePred q] : Decidable (∃ x, q x) :=
  decidable_of_iff _ (exists_wk q).symm

instance decForallWk (q : Wk → Prop) [DecidablePred q] : Decidable (∀ x, q x) :=
  decidable_of_iff _ (forall_wk q).symm

instance decExistsProc (q : Proc Mon Wk → Prop) [DecidablePred q] : Decidable (∃ p, q p) :=
  decidable_of_iff _ (exists_proc q).symm

/-! ### Decidable systems and states -/

/-- The relations of `sys` can be decided. -/
class DecSys (sys : System Mon Wk Bd Sub) where
  hbReaders : ∀ m r, Decidable (sys.hbReaders m r)
  checkers : ∀ x m, Decidable (sys.checkers x m)
  fwd : ∀ m r, Decidable (sys.fwd m r)
  haltInputs : ∀ w m, Decidable (sys.haltInputs w m)
  switches : ∀ m, Decidable (sys.switches m)

attribute [instance_reducible, instance] DecSys.hbReaders DecSys.checkers DecSys.fwd
  DecSys.haltInputs DecSys.switches

/-- The components of `s` can be decided. -/
class DecState (s : State Mon Wk) where
  alive : ∀ p, Decidable (s.alive p)
  bad : ∀ p, Decidable (s.bad p)
  hidden : ∀ p, Decidable (s.hidden p)
  off : ∀ m, Decidable (s.off m)
  flagged : ∀ m, Decidable (s.flagged m)
  halted : ∀ w, Decidable (s.halted w)
  pending : ∀ w, Decidable (s.pending w)
  joined : Decidable s.joined

attribute [instance_reducible, instance] DecState.alive DecState.bad DecState.hidden
  DecState.off DecState.flagged DecState.halted DecState.pending DecState.joined

theorem enabled_failSubstrate (sys : System Mon Wk Bd Sub) (s : State Mon Wk) (c : Sub) :
    Enabled sys s (.failSubstrate c) ↔
      (∃ m, sys.substrate (.inl m) = some c ∧ s.alive (.inl m)) ∨
      ∃ w, Present sys s (.inr w) ∧ sys.substrate (.inr w) = some c ∧ ¬ s.bad (.inr w) := by
  constructor
  · rintro ⟨p, hp, hsub, h⟩
    cases p with
    | inl m => exact .inl ⟨m, hsub, h⟩
    | inr w => exact .inr ⟨w, hp, hsub, h⟩
  · rintro (⟨m, hsub, h⟩ | ⟨w, hp, hsub, h⟩)
    · exact ⟨.inl m, trivial, hsub, h⟩
    · exact ⟨.inr w, hp, hsub, h⟩

section Instances

variable (sys : System Mon Wk Bd Sub) [DecSys sys] (s : State Mon Wk) [DecState s]

instance decIsJoiner (w : Wk) : Decidable (sys.IsJoiner w) :=
  inferInstanceAs (Decidable (sys.joiner = some w))

instance decPresent : ∀ p, Decidable (Present sys s p)
  | .inl _ => isTrue trivial
  | .inr w => inferInstanceAs (Decidable (sys.IsJoiner w → s.joined))

instance decInit : DecState (init sys) where
  alive := fun p =>
    match p with
    | .inl _ => isTrue trivial
    | .inr w => inferInstanceAs (Decidable (¬ sys.IsJoiner w))
  bad := fun _ => isFalse id
  hidden := fun _ => isFalse id
  off := fun _ => isFalse id
  flagged := fun _ => isFalse id
  halted := fun _ => isFalse id
  pending := fun _ => isFalse id
  joined := isFalse id

instance decEnabled : ∀ e, Decidable (Enabled sys s e)
  | .stop m => inferInstanceAs (Decidable (s.alive (.inl m)))
  | .stopBoundary b =>
      inferInstanceAs (Decidable (
        (∃ m m', m ≠ m' ∧ sys.boundary m = some b ∧ sys.boundary m' = some b) ∧
        (∃ m, sys.boundary m = some b ∧ s.alive (.inl m))))
  | .failSubstrate c => decidable_of_iff _ (enabled_failSubstrate sys s c).symm
  | .mutate p => inferInstanceAs (Decidable (Present sys s p ∧ ¬ s.bad p))
  | .disable m => inferInstanceAs (Decidable (sys.switches m ∧ ¬ s.off m))
  | .join => inferInstanceAs (Decidable (sys.joiner ≠ none ∧ ¬ s.joined))

instance decStruck (c : Sub) (p : Proc Mon Wk) : Decidable (Struck sys s c p) :=
  inferInstanceAs (Decidable (∃ w, p = .inr w ∧ Present sys s p ∧ sys.substrate p = some c))

instance decEffect : ∀ e, DecState (effect sys s e)
  | .stop m =>
      { ‹DecState s› with
        alive := fun p => inferInstanceAs (Decidable (s.alive p ∧ p ≠ .inl m)) }
  | .stopBoundary b =>
      { ‹DecState s› with
        alive := fun p =>
          inferInstanceAs (Decidable (s.alive p ∧ ∀ m, p = .inl m → sys.boundary m ≠ some b)) }
  | .failSubstrate c =>
      { ‹DecState s› with
        alive := fun p =>
          inferInstanceAs
            (Decidable (s.alive p ∧ ∀ m, p = .inl m → sys.substrate p ≠ some c))
        bad := fun p => inferInstanceAs (Decidable (s.bad p ∨ Struck sys s c p))
        hidden := fun p => inferInstanceAs (Decidable (s.hidden p ∨ Struck sys s c p)) }
  | .mutate p =>
      { ‹DecState s› with bad := fun q => inferInstanceAs (Decidable (q = p ∨ s.bad q)) }
  | .disable m =>
      { ‹DecState s› with off := fun r => inferInstanceAs (Decidable (r = m ∨ s.off r)) }
  | .join =>
      { ‹DecState s› with
        joined := isTrue trivial
        alive := fun p =>
          inferInstanceAs (Decidable (s.alive p ∨ ∃ w, p = .inr w ∧ sys.IsJoiner w)) }

instance decActive (m : Mon) : Decidable (Active s m) :=
  inferInstanceAs (Decidable (s.alive (.inl m) ∧ ¬ s.bad (.inl m) ∧ ¬ s.off m))

instance decVisible (p : Proc Mon Wk) : Decidable (Visible s p) :=
  inferInstanceAs (Decidable (s.bad p ∧ ¬ s.hidden p))

instance decDetects (m : Mon) : Decidable (Detects sys s m) :=
  inferInstanceAs (Decidable (Active s m ∧
    ((∃ x, Visible s x ∧ sys.checkers x m) ∨
     (∃ p : Mon, ¬ s.alive (.inl p) ∧ sys.hbReaders p m))))

instance decFlaggedOrDetects (m : Mon) : Decidable (FlaggedOrDetects sys s m) :=
  inferInstanceAs (Decidable (s.flagged m ∨ Detects sys s m))

instance decOut (m : Mon) : Decidable (Out s m) :=
  inferInstanceAs (Decidable (s.flagged m ∧ s.alive (.inl m) ∧ ¬ s.bad (.inl m)))

variable (o : Mon → Prop) [DecidablePred o]

instance decSees (w : Wk) : Decidable (Sees sys s o w) :=
  inferInstanceAs (Decidable (
    (∃ m, sys.haltInputs w m ∧ o m) ∨
    (sys.coupling = true ∧ ∃ m, sys.haltInputs w m ∧ ¬ s.alive (.inl m))))

instance decHandled (w : Wk) : Decidable (Handled sys s w) :=
  inferInstanceAs (Decidable (Present sys s (.inr w) ∧ ¬ s.halted w))

instance decWorked (w : Wk) : Decidable (Worked sys s o w) :=
  inferInstanceAs (Decidable (
    Handled sys s w ∧ ¬ s.pending w ∧ ¬ (Sees sys s o w ∧ sys.window = 0)))

instance decWorkPhase : DecState (workPhase sys s o) :=
  { ‹DecState s› with
    halted := fun w =>
      inferInstanceAs (Decidable (
        s.halted w ∨ (Handled sys s w ∧ (s.pending w ∨ (Sees sys s o w ∧ sys.window = 0)))))
    pending := fun w =>
      inferInstanceAs (Decidable (
        (s.pending w ∧ ¬ Handled sys s w) ∨
        (Handled sys s w ∧ ¬ s.pending w ∧ Sees sys s o w ∧ sys.window ≠ 0))) }

instance decResponded : Decidable (Responded sys s) :=
  inferInstanceAs (Decidable (
    (∃ m, s.flagged m ∧ s.alive (.inl m) ∧ ¬ s.bad (.inl m)) ∧
    ∀ w, Present sys s (.inr w) → s.halted w))

end Instances

/-! ### States written out -/

/-- A set of monitors, one truth value for each. -/
structure MSet where
  m1 : Bool
  m2 : Bool
  m3 : Bool
  deriving DecidableEq

/-- A set of non-monitor processes. -/
structure WSet where
  w1 : Bool
  w2 : Bool
  j : Bool
  deriving DecidableEq

/-- A set of processes. -/
structure PSet where
  m : MSet
  w : WSet
  deriving DecidableEq

def MSet.has (a : MSet) : Mon → Bool
  | .M1 => a.m1
  | .M2 => a.m2
  | .M3 => a.m3

def WSet.has (a : WSet) : Wk → Bool
  | .W1 => a.w1
  | .W2 => a.w2
  | .J => a.j

def PSet.has (a : PSet) : Proc Mon Wk → Bool
  | .inl m => a.m.has m
  | .inr w => a.w.has w

def MSet.of (q : Mon → Bool) : MSet := ⟨q .M1, q .M2, q .M3⟩

def WSet.of (q : Wk → Bool) : WSet := ⟨q .W1, q .W2, q .J⟩

def PSet.of (q : Proc Mon Wk → Bool) : PSet :=
  ⟨MSet.of fun m => q (.inl m), WSet.of fun w => q (.inr w)⟩

@[simp] theorem MSet.has_of (q : Mon → Bool) (m : Mon) : (MSet.of q).has m = q m := by
  cases m <;> rfl

@[simp] theorem WSet.has_of (q : Wk → Bool) (w : Wk) : (WSet.of q).has w = q w := by
  cases w <;> rfl

@[simp] theorem PSet.has_of (q : Proc Mon Wk → Bool) (p : Proc Mon Wk) :
    (PSet.of q).has p = q p := by
  cases p with
  | inl m => exact MSet.has_of _ m
  | inr w => exact WSet.has_of _ w

/-- A state of the model, written out: 31 truth values. -/
structure CState where
  alive : PSet
  bad : PSet
  hidden : PSet
  off : MSet
  flagged : MSet
  halted : WSet
  pending : WSet
  joined : Bool
  deriving DecidableEq

/-- The state of the model that a `CState` stands for. -/
def CState.toState (c : CState) : State Mon Wk where
  alive := fun p => c.alive.has p = true
  bad := fun p => c.bad.has p = true
  hidden := fun p => c.hidden.has p = true
  off := fun m => c.off.has m = true
  flagged := fun m => c.flagged.has m = true
  halted := fun w => c.halted.has w = true
  pending := fun w => c.pending.has w = true
  joined := c.joined = true

instance decToState (c : CState) : DecState c.toState where
  alive := fun p => inferInstanceAs (Decidable (c.alive.has p = true))
  bad := fun p => inferInstanceAs (Decidable (c.bad.has p = true))
  hidden := fun p => inferInstanceAs (Decidable (c.hidden.has p = true))
  off := fun m => inferInstanceAs (Decidable (c.off.has m = true))
  flagged := fun m => inferInstanceAs (Decidable (c.flagged.has m = true))
  halted := fun w => inferInstanceAs (Decidable (c.halted.has w = true))
  pending := fun w => inferInstanceAs (Decidable (c.pending.has w = true))
  joined := inferInstanceAs (Decidable (c.joined = true))

/-- A decidable state, written out. -/
def reify (s : State Mon Wk) [DecState s] : CState where
  alive := PSet.of fun p => decide (s.alive p)
  bad := PSet.of fun p => decide (s.bad p)
  hidden := PSet.of fun p => decide (s.hidden p)
  off := MSet.of fun m => decide (s.off m)
  flagged := MSet.of fun m => decide (s.flagged m)
  halted := WSet.of fun w => decide (s.halted w)
  pending := WSet.of fun w => decide (s.pending w)
  joined := decide s.joined

@[simp] theorem toState_reify (s : State Mon Wk) [DecState s] : (reify s).toState = s := by
  cases s
  simp [CState.toState, reify]

theorem MSet.ext_has {a b : MSet} (h : ∀ m, a.has m = b.has m) : a = b := by
  obtain ⟨a1, a2, a3⟩ := a
  obtain ⟨b1, b2, b3⟩ := b
  have h1 : a1 = b1 := h .M1
  have h2 : a2 = b2 := h .M2
  have h3 : a3 = b3 := h .M3
  rw [h1, h2, h3]

theorem WSet.ext_has {a b : WSet} (h : ∀ w, a.has w = b.has w) : a = b := by
  obtain ⟨a1, a2, a3⟩ := a
  obtain ⟨b1, b2, b3⟩ := b
  have h1 : a1 = b1 := h .W1
  have h2 : a2 = b2 := h .W2
  have h3 : a3 = b3 := h .J
  rw [h1, h2, h3]

theorem PSet.ext_has {a b : PSet} (h : ∀ p, a.has p = b.has p) : a = b := by
  obtain ⟨am, aw⟩ := a
  obtain ⟨bm, bw⟩ := b
  have h1 : am = bm := MSet.ext_has fun m => h (.inl m)
  have h2 : aw = bw := WSet.ext_has fun w => h (.inr w)
  rw [h1, h2]

/-- Two written-out states that stand for the same state are the same. -/
theorem CState.toState_injective {c c' : CState} (h : c.toState = c'.toState) : c = c' := by
  have eqB : ∀ {x y : Bool}, (x = true) = (y = true) → x = y :=
    fun e => Bool.eq_iff_iff.2 (Iff.of_eq e)
  obtain ⟨a, b, hd, o, f, ha, p, j⟩ := c
  obtain ⟨a', b', hd', o', f', ha', p', j'⟩ := c'
  have h1 : a = a' := PSet.ext_has fun x => eqB (congrArg (fun s => s.alive x) h)
  have h2 : b = b' := PSet.ext_has fun x => eqB (congrArg (fun s => s.bad x) h)
  have h3 : hd = hd' := PSet.ext_has fun x => eqB (congrArg (fun s => s.hidden x) h)
  have h4 : o = o' := MSet.ext_has fun x => eqB (congrArg (fun s => s.off x) h)
  have h5 : f = f' := MSet.ext_has fun x => eqB (congrArg (fun s => s.flagged x) h)
  have h6 : ha = ha' := WSet.ext_has fun x => eqB (congrArg (fun s => s.halted x) h)
  have h7 : p = p' := WSet.ext_has fun x => eqB (congrArg (fun s => s.pending x) h)
  have h8 : j = j' := eqB (congrArg (fun s => s.joined) h)
  rw [h1, h2, h3, h4, h5, h6, h7, h8]

/-! ### Evaluation order

The kernel evaluates a term only where its value is needed, and again at each place it
is needed. `force` evaluates a value once, completely, and hands on the result. Each
`force` is the identity (`force_eq`), so none of them matters to what is proved. They
matter to how long the kernel takes. -/

def seqB {α : Type} (b : Bool) (k : Bool → α) : α :=
  match b with
  | true => k true
  | false => k false

@[simp] theorem seqB_eq {α : Type} (b : Bool) (k : Bool → α) : seqB b k = k b := by
  cases b <;> rfl

def MSet.force {α : Type} (a : MSet) (k : MSet → α) : α :=
  seqB a.m1 fun x => seqB a.m2 fun y => seqB a.m3 fun z => k ⟨x, y, z⟩

def WSet.force {α : Type} (a : WSet) (k : WSet → α) : α :=
  seqB a.w1 fun x => seqB a.w2 fun y => seqB a.j fun z => k ⟨x, y, z⟩

def PSet.force {α : Type} (a : PSet) (k : PSet → α) : α :=
  a.m.force fun x => a.w.force fun y => k ⟨x, y⟩

def CState.force {α : Type} (c : CState) (k : CState → α) : α :=
  c.alive.force fun a => c.bad.force fun b => c.hidden.force fun h =>
  c.off.force fun o => c.flagged.force fun f => c.halted.force fun ha =>
  c.pending.force fun p => seqB c.joined fun j => k ⟨a, b, h, o, f, ha, p, j⟩

@[simp] theorem MSet.force_eq {α : Type} (a : MSet) (k : MSet → α) : a.force k = k a := by
  simp [MSet.force]

@[simp] theorem WSet.force_eq {α : Type} (a : WSet) (k : WSet → α) : a.force k = k a := by
  simp [WSet.force]

@[simp] theorem PSet.force_eq {α : Type} (a : PSet) (k : PSet → α) : a.force k = k a := by
  simp [PSet.force]

@[simp] theorem CState.force_eq {α : Type} (c : CState) (k : CState → α) :
    c.force k = k c := by
  simp [CState.force]

/-! ### The monitor phase

Among three monitors, a flag that reaches a monitor reaches it along at most two report
edges. -/

/-- A report edge that carries a flag: both ends are active. -/
def Edge (sys : System Mon Wk Bd Sub) (s : State Mon Wk) (m r : Mon) : Prop :=
  Active s m ∧ sys.fwd m r ∧ Active s r

instance decEdge (sys : System Mon Wk Bd Sub) [DecSys sys] (s : State Mon Wk) [DecState s]
    (m r : Mon) : Decidable (Edge sys s m r) :=
  inferInstanceAs (Decidable (Active s m ∧ sys.fwd m r ∧ Active s r))

/-- Of four monitors, two are the same. -/
theorem two_of_four (a b c d : Mon) : a = b ∨ a = c ∨ a = d ∨ b = c ∨ b = d ∨ c = d := by
  cases a <;> cases b <;> cases c <;> cases d <;> simp

theorem spread_iff (sys : System Mon Wk Bd Sub) (s : State Mon Wk) (F : Mon → Prop)
    (r : Mon) :
    Spread sys s F r ↔
      F r ∨ (∃ m, F m ∧ Edge sys s m r) ∨
        ∃ m, F m ∧ ∃ m', Edge sys s m m' ∧ Edge sys s m' r := by
  constructor
  · intro h
    induction h with
    | base h => exact .inl h
    | @step m r _ ha hf hr ih =>
      have e : Edge sys s m r := ⟨ha, hf, hr⟩
      rcases ih with h | ⟨a, hFa, eam⟩ | ⟨a, hFa, b, eab, ebm⟩
      · exact .inr (.inl ⟨m, h, e⟩)
      · exact .inr (.inr ⟨a, hFa, m, eam, e⟩)
      · rcases two_of_four a b m r with h | h | h | h | h | h
        · subst h
          exact .inr (.inr ⟨a, hFa, m, ebm, e⟩)
        · subst h
          exact .inr (.inl ⟨a, hFa, e⟩)
        · subst h
          exact .inl hFa
        · subst h
          exact .inr (.inr ⟨a, hFa, b, eab, e⟩)
        · subst h
          exact .inr (.inl ⟨a, hFa, eab⟩)
        · subst h
          exact .inr (.inr ⟨a, hFa, b, eab, ebm⟩)
  · rintro (h | ⟨m, hFm, ha, hf, hr⟩ | ⟨a, hFa, b, ⟨ha, hf, hb⟩, ⟨hb', hf', hr⟩⟩)
    · exact .base h
    · exact .step (.base hFm) ha hf hr
    · exact .step (.step (.base hFa) ha hf hb) hb' hf' hr

/-- `flagged` at the end of the monitor phase. -/
def cflag (sys : System Mon Wk Bd Sub) [DecSys sys] (c : CState) : MSet :=
  if sys.slowReports = true then
    MSet.of fun r => decide (FlaggedOrDetects sys c.toState r ∨
      ∃ m, c.toState.flagged m ∧ Active c.toState m ∧ sys.fwd m r ∧ Active c.toState r)
  else
    (MSet.of fun m => decide (FlaggedOrDetects sys c.toState m)).force fun F =>
      MSet.of fun r => decide (F.has r = true ∨ (∃ m, F.has m = true ∧ Edge sys c.toState m r) ∨
        ∃ m, F.has m = true ∧ ∃ m', Edge sys c.toState m m' ∧ Edge sys c.toState m' r)

theorem cflag_spec (sys : System Mon Wk Bd Sub) [DecSys sys] (c : CState) (m : Mon) :
    flaggedAfter sys c.toState m ↔ (cflag sys c).has m = true := by
  unfold flaggedAfter cflag
  by_cases h : sys.slowReports = true
  · simp [h]
  · simp [h, spread_iff]

theorem monitorPhase_toState (sys : System Mon Wk Bd Sub) [DecSys sys] (c : CState) :
    monitorPhase sys c.toState = ({ c with flagged := cflag sys c } : CState).toState := by
  have h : flaggedAfter sys c.toState = fun m => (cflag sys c).has m = true :=
    funext fun m => propext (cflag_spec sys c m)
  unfold monitorPhase
  rw [h]
  rfl

theorem monitorPhase_reify (sys : System Mon Wk Bd Sub) [DecSys sys] (s : State Mon Wk)
    [DecState s] :
    monitorPhase sys s = ({ reify s with flagged := cflag sys (reify s) } : CState).toState := by
  have h := monitorPhase_toState sys (reify s)
  rwa [toState_reify] at h

/-! ### The phases after the environment phase -/

/-- What a round produces, written out. -/
structure COut where
  next : CState
  g1 : Bool
  g2 : Bool
  deriving DecidableEq

def COut.toOutcome (o : COut) : Outcome Mon Wk where
  next := o.next.toState
  g1 := o.g1 = true
  g2 := o.g2 = true

/-- `afterEnv`, computed. -/
def cafter (sys : System Mon Wk Bd Sub) [DecSys sys] (c₁ : CState) : COut :=
  if sys.gate = true then
    (cflag sys c₁).force fun fl =>
      let c₂ : CState := { c₁ with flagged := fl }
      { next := reify (workPhase sys c₂.toState (Out c₂.toState))
        g1 := decide ((∃ p, c₂.toState.bad p) ∧ ¬ ∃ m, Out c₂.toState m)
        g2 := decide ((∃ p, c₂.toState.bad p) ∧
          ∃ w, Worked sys c₂.toState (Out c₂.toState) w) }
  else
    (reify (workPhase sys c₁.toState (Out c₁.toState))).force fun c₂ =>
      (cflag sys c₂).force fun fl =>
        let c₃ : CState := { c₂ with flagged := fl }
        { next := c₃
          g1 := decide ((∃ p, c₃.toState.bad p) ∧ ¬ ∃ m, Out c₃.toState m)
          g2 := decide ((∃ p, c₁.toState.bad p) ∧
            ∃ w, Worked sys c₁.toState (Out c₁.toState) w) }

theorem cafter_spec (sys : System Mon Wk Bd Sub) [DecSys sys] (c₁ : CState) :
    afterEnv sys c₁.toState = (cafter sys c₁).toOutcome := by
  unfold afterEnv cafter
  by_cases h : sys.gate = true
  · simp [h, COut.toOutcome, monitorPhase_toState]
  · simp [h, COut.toOutcome, monitorPhase_reify]

end Finite
end SelfObserving
