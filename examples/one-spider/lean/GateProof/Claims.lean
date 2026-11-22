/-
What the theorems are stated with: what is assumed of the unknowns (section 13 of
`protocol-spec.md`), what it is for everything stored to agree, a run of several rounds,
and the spacing of faults. No proofs.
-/
import GateProof.Model

namespace Gate

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)

/-- The work of one round with no fault: the first text's taking in, world's work and
spider's work, with the moths that are in the web of the state it starts from as the
halted moths. -/
def Params.work (s : St V) (q : Q) (dt : Dt) (now : Tm) : St V :=
  P.spider₁ (P.world₁ (P.takeIn₁ s q) (P.inWeb₁ s) dt now) dt now

/-- Section 13: what is assumed of the unknowns. -/
structure Sound : Prop where
  /-- Y1. The two texts of the work compute the same function. -/
  work_same : ∀ (s : St V) (q : Q) (h : V) (dt : Dt) (now : Tm),
    P.spider₂ (P.world₂ (P.takeIn₂ s q) h dt now) dt now
      = P.spider₁ (P.world₁ (P.takeIn₁ s q) h dt now) dt now
  /-- Y2. The two texts of `in_web` compute the same function. -/
  inWeb_same : ∀ s : St V, P.inWeb₂ s = P.inWeb₁ s
  /-- Y3. The work done with no fault passes the gate: R26, R28, R29. -/
  work_passes : ∀ (s : St V) (q : Q) (dt : Dt) (now : Tm),
    P.canBe₁ s = true → P.canBe₂ s = true →
      P.real (P.work s q dt now) = true
      ∧ P.canBe₁ (P.work s q dt now) = true
      ∧ P.canBe₂ (P.work s q dt now) = true
      ∧ P.step₁ s (P.inWeb₁ s) (P.work s q dt now) (P.takeIn₁ s q) dt now = true
      ∧ P.step₂ s (P.inWeb₂ s) (P.work s q dt now) (P.takeIn₂ s q) dt now = true
  /-- Y4. A new game is a state the game can be in. -/
  new_canBe : ∀ now : Tm, P.canBe₁ (P.newState now) = true ∧ P.canBe₂ (P.newState now) = true

/-- Everything stored agrees, and nothing is halted: the state is the record, the
record's two halves are the same, every observer is as a new one made from the record
would be, the three books are the same and hold no halt, the three places of `before`
are the same, the three lists are the same, and the record is a state the game can be
in. -/
structure Settled (g : Game V Q Tm) : Prop where
  state : g.sp = g.rt
  record : g.rc = g.rt
  observers : ∀ i, g.ob i = born P g i
  books : g.bk 0 = g.bk 1 ∧ g.bk 0 = g.bk 2
  noHalt : (g.bk 0).halt = none
  before : g.bf 0 = g.bf 1 ∧ g.bf 0 = g.bf 2
  asked : g.asks 0 = g.asks 1 ∧ g.asks 0 = g.asks 2
  canBe : P.canBe₁ g.rt = true ∧ P.canBe₂ g.rt = true

/-- Settled, the last round worked was not refused, and the count of stops in the wrong
place is nought (nothing in the model raises it: A12). -/
def Clean (g : Game V Q Tm) : Prop :=
  Settled P g ∧ (g.bk 0).spoiled = 0 ∧ (g.bk 0).stops = 0

/-- A state the program can reach with no fault: a new game, and from there what
happens between rounds (E1 to E3) and rounds with no fault. -/
inductive Reach : Game V Q Tm → Prop where
  | new (now : Tm) : Reach (newGame P now)
  | event (e : Ev E) {g : Game V Q Tm} : Reach g → Reach (event P e g)
  | round (inp : Inp Tm Dt) {g : Game V Q Tm} : Reach g → Reach (round P inp .none g).g

/-- What happens between two rounds, and what the next round is given. -/
structure Tick (E Tm Dt : Type) where
  es : List (Ev E)
  inp : Inp Tm Dt

/-- Several rounds with no fault, each with what happens before it. -/
def play (ts : List (Tick E Tm Dt)) (g : Game V Q Tm) : Game V Q Tm :=
  ts.foldl (fun g t => (tick P t.es t.inp none g).g) g

/-- The record as the recorded rounds of a run with no new fault make it, starting from
`T`: each round that was recorded makes of it what the work with no fault makes
(`Params.work`), given the voted list of what was asked as it stood before the round,
and the round's own length and time. A round that was not recorded leaves it as it
was. -/
def ledger : List (Tick E Tm Dt) → St V → Game V Q Tm → St V
  | [], T, _ => T
  | t :: ts, T, g =>
    let r := tick P t.es t.inp none g
    ledger ts
      (if r.recorded.isSome then P.work T (vote (events P t.es g).asks) r.dt r.now else T) r.g

/-! ### Faults one after another (T5) -/

/-- A tick that may have one fault in it. -/
structure FTick (V Q E Tm Dt : Type) where
  es : List (Ev E)
  inp : Inp Tm Dt
  fault : Option (Fault V Q Tm)

/-- Where a run stands with respect to its last fault, told from what its rounds did.
`ready`: no fault is outstanding. `landed`: a fault landed in the last tick and nothing
has halted since. `halting`: a halt that began after the fault is not over. `ended`:
that halt is over, and no round has been recorded since. -/
inductive Phase where
  | ready | landed | halting | ended
  deriving DecidableEq, Repr

/-- The phase after a tick. A fault that has not halted anything by the end of the
round after the one it landed in is taken to be gone (T4 says it is). -/
def Phase.next (ph : Phase) (hasFault : Bool) (r : Run V Q Tm Dt) : Phase :=
  match ph, hasFault with
  | .ready, false => .ready
  | .ready, true =>
    if r.g.halted = true then .halting
    else if r.found.isSome = true then (if r.recorded.isSome = true then .ready else .ended)
    else .landed
  | .landed, _ =>
    if r.g.halted = true then .halting
    else if r.found.isSome = true then (if r.recorded.isSome = true then .ready else .ended)
    else .ready
  | .halting, _ =>
    if r.g.halted = true then .halting
    else if r.recorded.isSome = true then .ready else .ended
  | .ended, _ => if r.recorded.isSome = true then .ready else .ended

/-- A run of ticks, some with a fault. With the game comes the phase. -/
def playF : List (FTick V Q E Tm Dt) → Phase → Game V Q Tm → Phase × Game V Q Tm
  | [], ph, g => (ph, g)
  | t :: ts, ph, g =>
    let r := tick P t.es t.inp t.fault g
    playF ts (ph.next t.fault.isSome r) r.g

/-- The spacing of the fault model: a fault lands only when no fault is outstanding. -/
def Spaced : List (FTick V Q E Tm Dt) → Phase → Game V Q Tm → Prop
  | [], _, _ => True
  | t :: ts, ph, g =>
    (t.fault.isSome = true → ph = Phase.ready) ∧
    let r := tick P t.es t.inp t.fault g
    Spaced ts (ph.next t.fault.isSome r) r.g

/-- `ledger` for a run with faults: the same rule, with the list of what was asked voted
in the run with no fault in the tick (which is the list as it was taken down). -/
def ledgerF : List (FTick V Q E Tm Dt) → St V → Game V Q Tm → St V
  | [], T, _ => T
  | t :: ts, T, g =>
    let r := tick P t.es t.inp t.fault g
    ledgerF ts
      (if r.recorded.isSome then P.work T (vote (events P t.es g).asks) r.dt r.now else T) r.g

end

end Gate
