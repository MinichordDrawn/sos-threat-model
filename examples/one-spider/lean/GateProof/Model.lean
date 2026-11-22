/-
The model: the protocol of the gate, following `protocol-spec.md` item by item. Each
definition names the item of the specification it is taken from (N, S, V, D, L, E, R, H,
P, W, F, A, Y and a number).

Nothing outside the Lean core is imported. A set is a yes-or-no question, and what is
unknown (the game's work, its rules, time) is a field of `Params`.
-/

namespace Gate

/-! ### Section 1 of the specification: names and numbers -/

/-- N1. The seven parts, 0 to 6. -/
abbrev Part := Fin 7
/-- N2. The eight observers, 0 to 7. -/
abbrev Who := Fin 8
/-- S1. A state: a value for each part (A1: a part and its text are one value). -/
abbrev St (V : Type) := Part → V

/-- Two states, or two of anything else that has a value for each of finitely many
places, can be compared when the values can. -/
instance decEqFun {n : Nat} {α : Type} [DecidableEq α] : DecidableEq (Fin n → α) :=
  fun f g => decidable_of_iff (∀ i, f i = g i) ⟨funext, fun h _ => h ▸ rfl⟩

/-- N3. A ring: its observers and its parts, in the order they are gone through. -/
structure Ring where
  who : List Who
  parts : List Part

/-- N3. The spider's ring and the world's ring. -/
def rings : List Ring :=
  [⟨[0, 1, 2, 3], [0, 1, 2]⟩, ⟨[4, 5, 7, 3, 6], [3, 4, 5, 6]⟩]

/-- N4. The coordinators are observers 3 and 6. -/
def coord (i : Who) : Bool := i == 3 || i == 6

/-- N5. The moths observer. -/
def moths : Who := 5

/-- N6. Observer `i` sees part `p`. -/
def sees (i : Who) (p : Part) : Bool :=
  rings.any fun r => r.who.contains i && r.parts.contains p

/-- All the observers, and all the parts, in order. -/
def allWho : List Who := [0, 1, 2, 3, 4, 5, 6, 7]
def allParts : List Part := [0, 1, 2, 3, 4, 5, 6]

/-- N8. The three settings. -/
inductive How where
  | atOnce | afterAPause | onAClick
  deriving DecidableEq, Repr

/-! ### What is said (A10): kept only as which check spoke -/

/-- What an observer can find (section 5), or any other reason a fault writes. -/
inductive Finding where
  | ownSignal                      -- L2
  | partChanged (p : Part)         -- L3
  | copyDiffers (j : Who) (p : Part) -- L4
  | silent (j : Who)               -- L5
  | changed (j : Who)              -- L6
  | list                           -- L7
  | flagUp                         -- R12: a flag with no reason
  | other (n : Nat)                -- anything else
  deriving DecidableEq, Repr

/-- What the gate can find when it looks (R14 to R17). -/
inductive Off where
  | recordSelf (p : Part)          -- R14
  | partChanged (p : Part)         -- R15
  | observer (i : Who)             -- R16
  | recordChanged                  -- R16, where the record's two halves differ
  | asks                           -- R17
  deriving DecidableEq, Repr

/-- Why everything halted (H1), or why a halt stays (P6). -/
inductive Cause where
  | books                          -- R1, R3: one book differs
  | booksNoTwo                     -- R1, R3: no two the same
  | before                         -- R4
  | observer (f : Finding)         -- R18, from R12
  | late (i : Who)                 -- R18: an observer did not answer
  | silent                         -- R18
  | gate (o : Off)                 -- R18, from R14 to R17
  | unfit                          -- R26
  | copyRules                      -- R27
  | rules                          -- R28, R29
  | redone                         -- R31
  | during (o : Off)               -- R32
  | notSettled                     -- P2: `restore` failed
  | stillFound                     -- P2: something found after putting right
  | twice                          -- R38
  | other (n : Nat)
  deriving DecidableEq, Repr

/-! ### Section 2 of the specification: what is stored -/

/-- S2. An observer. -/
structure Observer (V : Type) where
  name : Nat
  alive : Bool
  beat : Nat
  copies : Part → V
  held : V
  flagged : Bool
  why : Option Finding
  deriving DecidableEq

/-- S6. A halt. -/
structure Halt (V Tm : Type) where
  why : Cause
  quiet : Tm
  last : Option (St V)
  asked : Bool
  stuck : Bool
  deriving DecidableEq

/-- S5. One place of the book. `rest` stands for the ten fields that are only said
(A9, A10). -/
structure Book (V Tm : Type) where
  halt : Option (Halt V Tm)
  how : How
  halts : Nat
  restarts : Nat
  spoiled : Nat
  stops : Nat
  clock : Tm
  time : Tm
  rounds : Nat
  rest : V
  deriving DecidableEq

/-- Everything that is stored. S1: `sp`, the state. S2: `ob`, the observers. S3: `rt`,
the record's texts. S4: `rc`, the record's copy. S5: `bk`, the book in three places.
S7: `bf`, the state kept from when a round's work last began, in three places. S8:
`asks`, what was asked, in three lists. -/
structure Game (V Q Tm : Type) where
  sp : St V
  ob : Who → Observer V
  rt : St V
  rc : St V
  bk : Fin 3 → Book V Tm
  bf : Fin 3 → Option (St V)
  asks : Fin 3 → Q

/-! ### Section 12 of the specification: what is unknown -/

/-- The unknowns. `V`: values (A1). `Q`: lists of what was asked, and `E`: one thing
asked (A4). `Tm`: times, and `Dt`: lengths (A5). -/
structure Params (V Q E Tm Dt : Type) where
  /-- The empty text. -/
  blank : V
  /-- D2. The fingerprint. -/
  fp : V → V
  /-- A2. Taking in, the world's work and the spider's work: first and second text. -/
  takeIn₁ : St V → Q → St V
  takeIn₂ : St V → Q → St V
  world₁ : St V → V → Dt → Tm → St V
  world₂ : St V → V → Dt → Tm → St V
  spider₁ : St V → Dt → Tm → St V
  spider₂ : St V → Dt → Tm → St V
  /-- D6. Which moths are in the web: first and second text. -/
  inWeb₁ : St V → V
  inWeb₂ : St V → V
  /-- A3, R26. Is every number in the state a real one? -/
  real : St V → Bool
  /-- A3. Is this a state the game can be in? First and second text of the rules. -/
  canBe₁ : St V → Bool
  canBe₂ : St V → Bool
  /-- A3. Is this a step the rules allow? Asked with: the record's copy, the halted
  moths, the state, the state as it was after taking in (from which what was asked is
  read), `dt` and `now`. First and second text. -/
  step₁ : St V → V → St V → St V → Dt → Tm → Bool
  step₂ : St V → V → St V → St V → Dt → Tm → Bool
  /-- A4, E1. How one list takes something down, given whether everything is halted. -/
  takeDown : Bool → E → Q → Q
  /-- A4, E1. Is it taken at all, given whether everything is halted and the voted list? -/
  taken : Bool → Q → E → Bool
  /-- R37. The empty list. -/
  noAsks : Q
  /-- P5. A list holding one letting go. -/
  letGo : Q
  /-- A5, R2. The length of a round, from the book's note of the clock and the clock. -/
  len : Tm → Tm → Dt
  /-- A5, R2. The game's time moved on by a length. -/
  adv : Tm → Dt → Tm
  /-- A5, R2. Could the clock be read? -/
  readable : Tm → Bool
  /-- A5, P1. Is the pause since `quiet` over at `now`? -/
  pauseOver : Tm → Tm → Bool
  /-- D13. The state of a new game. -/
  newState : Tm → St V

section
variable {V Q E Tm Dt : Type} [DecidableEq V] [DecidableEq Q] [DecidableEq Tm]
variable (P : Params V Q E Tm Dt)

/-! ### Section 3 of the specification: reading what is kept in three -/

/-- V1, V3, V4. Of three places, the one that is read. -/
def vote {α : Type} [DecidableEq α] (x : Fin 3 → α) : α :=
  if x 0 = x 1 ∨ x 0 = x 2 then x 0 else if x 1 = x 2 then x 1 else x 0

/-- V1. The book, voted. -/
def Game.book (g : Game V Q Tm) : Book V Tm := vote g.bk

/-- V2. A write to the book: the same change to each place. -/
def keep (f : Book V Tm → Book V Tm) (g : Game V Q Tm) : Game V Q Tm :=
  { g with bk := fun k => f (g.bk k) }

/-- "Halted": the voted book has a halt. -/
def Game.halted (g : Game V Q Tm) : Bool := g.book.halt.isSome

/-- H4. Halted in a way that cannot be put right. -/
def Game.stuck (g : Game V Q Tm) : Bool :=
  match g.book.halt with
  | some h => h.stuck
  | none => false

/-! ### Section 4 of the specification: small definitions -/

/-- D3. What observer `i` holds of a text. -/
def Params.holds (i : Who) (t : V) : V := if coord i then P.fp t else t

/-- D4. The mark of what observer `i` holds. -/
def Params.printOf (i : Who) (h : V) : V := if coord i then h else P.fp h

/-- D5. The copies observer `i` should have, from the texts of all the parts. -/
def copiesFor (i : Who) (texts : St V) : Part → V :=
  fun p => if sees i p then P.holds i (texts p) else P.blank

/-- D7. The list of halted moths observer `i` should have. -/
def heldOf (g : Game V Q Tm) (i : Who) : V :=
  if i = moths then P.inWeb₁ g.rc else P.blank

/-- D8. Observer `i` is sound. -/
def sound (g : Game V Q Tm) (i : Who) : Bool :=
  (g.ob i).alive && (g.ob i).beat == g.book.rounds

/-- D8. Observer `i` is sound and has its flag up. -/
def flagging (g : Game V Q Tm) (i : Who) : Bool := sound g i && (g.ob i).flagged

/-- D9. Every observer that sees `p` holds this text of it. -/
def allHold (g : Game V Q Tm) (p : Part) (t : V) : Bool :=
  allWho.all fun i => !sees i p || (g.ob i).copies p == P.holds i t

/-- D10. A new observer, with its copies from the record. -/
def born (g : Game V Q Tm) (i : Who) : Observer V :=
  { name := i.val, alive := true, beat := g.book.rounds, copies := copiesFor P i g.rt,
    held := heldOf P g i, flagged := false, why := none }

/-- D11. Everything halts. -/
def stopAll (why : Cause) (now : Tm) (g : Game V Q Tm) : Game V Q Tm :=
  keep (fun b => { b with
    halts := b.halts + 1,
    halt := some { why := why, quiet := now, last := none, asked := false, stuck := false } }) g

/-- D12. The halt cannot be put right. The condition is looked at in each place (V2). -/
def stick (why : Cause) (g : Game V Q Tm) : Game V Q Tm :=
  keep (fun b => { b with
    halt := b.halt.map fun h => { h with stuck := true, asked := false, why := why } }) g

/-- D13. A new book. -/
def newBook (now : Tm) : Book V Tm :=
  { halt := none, how := .afterAPause, halts := 0, restarts := 0, spoiled := 0, stops := 0,
    clock := now, time := now, rounds := 0, rest := P.blank }

/-- D13. A new game at time `now`. -/
def newGame (now : Tm) : Game V Q Tm :=
  let s := P.newState now
  let g : Game V Q Tm :=
    { sp := s, ob := fun _ => ⟨0, true, 0, fun _ => P.blank, P.blank, false, none⟩, rt := s, rc := s,
      bk := fun _ => newBook P now, bf := fun _ => none, asks := fun _ => P.noAsks }
  { g with ob := born P g }

/-! ### Section 5 of the specification: the observers' rule -/

/-- What an observer is given to look at. -/
structure Look (V : Type) where
  rounds : Nat
  last : Nat
  texts : St V
  ring : Who → Observer V
  world : St V

/-- L6. Is observer `j` in shape? -/
def shaped (j : Who) (o : Observer V) : Bool :=
  o.name == j.val && decide (∀ p : Part, sees j p = true ∨ o.copies p = P.blank)
    && (j == moths || o.held == P.blank) && (o.flagged || o.why.isNone)

/-- L3 to L7, for one ring that observer `i` sits in. -/
def lookRing (i : Who) (lk : Look V) (r : Ring) : Option Finding :=
  let me := lk.ring i
  let others := r.who.filter (· != i)
  (r.parts.findSome? fun p =>
      -- L3
      if P.holds i (lk.texts p) ≠ me.copies p then some (Finding.partChanged p)
      else
        -- L4
        others.findSome? fun j =>
          let theirs := (lk.ring j).copies p
          if (if coord i || coord j then P.printOf j theirs ≠ P.printOf i (me.copies p)
              else theirs ≠ me.copies p)
          then some (Finding.copyDiffers j p) else none)
  <|> (others.findSome? fun j =>
      -- L5
      if (lk.ring j).alive = false ∨ (lk.ring j).beat ≠ lk.last then some (Finding.silent j)
      -- L6
      else if shaped P j (lk.ring j) = false then some (Finding.changed j)
      else none)
  -- L7
  <|> (if r.who.contains moths = true ∧ (lk.ring moths).held ≠ P.inWeb₁ lk.world
       then some Finding.list else none)

/-- L2 to L7 (L1 is always so: A8). What observer `i` finds, or nothing. One rule for
the eight (A6). -/
def lookOf (i : Who) (lk : Look V) : Option Finding :=
  if (lk.ring i).beat ≠ lk.last then some Finding.ownSignal
  else (rings.filter fun r => r.who.contains i).findSome? (lookRing P i lk)

/-! ### Section 7.3 of the specification: the gate looks -/

/-- R14. The record against itself. -/
def selfCheck (g : Game V Q Tm) : Option Off :=
  allParts.findSome? fun p => if g.rt p ≠ g.rc p then some (Off.recordSelf p) else none

/-- R15. The state against the record. -/
def stateCheck (g : Game V Q Tm) : Option Off :=
  allParts.findSome? fun p => if g.rt p ≠ g.sp p then some (Off.partChanged p) else none

/-- R16, R32. `observers_off`: the first observer that is not as the record says. -/
def obsOff (g : Game V Q Tm) : Option Off :=
  allWho.findSome? fun i =>
    let o := g.ob i
    if o.name ≠ i.val then some (Off.observer i)
    else if o.alive = false then some (Off.observer i)
    else if o.beat ≠ g.book.rounds then some (Off.observer i)
    else if o.copies ≠ copiesFor P i g.rt then
      (if g.rt ≠ g.rc then some Off.recordChanged else some (Off.observer i))
    else if o.held ≠ heldOf P g i then some (Off.observer i)
    else if o.flagged = true ∨ o.why.isSome = true then some (Off.observer i)
    else none

/-- R17. The three lists against one another. -/
def asksCheck (g : Game V Q Tm) : Option Off :=
  if g.asks 0 ≠ g.asks 1 ∨ g.asks 0 ≠ g.asks 2 then some Off.asks else none

/-- R14 to R17 in one piece, as `correct` uses them (P2). -/
def differs (g : Game V Q Tm) : Option Off :=
  selfCheck g <|> stateCheck g <|> obsOff P g <|> asksCheck g

/-! ### Section 9 of the specification: putting right -/

/-- P4. One part put right. With the game comes whether the part could be settled. -/
def restorePart (began : Option (St V)) (p : Part) (g : Game V Q Tm) : Game V Q Tm × Bool :=
  let is := g.sp p
  let text := g.rt p
  let kept := g.rc p
  if text = kept then
    -- (a)
    if is ≠ text then ({ g with sp := fun q => if q = p then g.rc p else g.sp q }, true)
    else (g, true)
  else
    let beganText : Bool := decide (began.map (fun b => b p) = some text)
    let beganKept : Bool := decide (began.map (fun b => b p) = some kept)
    -- (b1)
    if is = text ∧ allHold P g p text = true then
      ({ g with rc := fun q => if q = p then g.sp p else g.rc q }, true)
    -- (b2)
    else if is = kept ∧ allHold P g p kept = true then
      ({ g with rt := fun q => if q = p then kept else g.rt q }, true)
    -- (b3)
    else if beganText = true ∧ allHold P g p text = true then
      ({ g with sp := fun q => if q = p then text else g.sp q,
                rc := fun q => if q = p then text else g.rc q }, true)
    -- (b4)
    else if beganKept = true ∧ allHold P g p kept = true then
      ({ g with rt := fun q => if q = p then kept else g.rt q,
                sp := fun q => if q = p then kept else g.sp q }, true)
    -- (b5)
    else (g, false)

/-- P3. The parts put right in order, stopping at the first that cannot be settled. -/
def restoreParts (began : Option (St V)) : List Part → Game V Q Tm → Game V Q Tm × Bool
  | [], g => (g, true)
  | p :: ps, g =>
    let r := restorePart P began p g
    if r.2 then restoreParts began ps r.1 else (r.1, false)

/-- P5. The three lists put right. -/
def restoreAsks (g : Game V Q Tm) : Game V Q Tm :=
  let ab := g.asks 0 = g.asks 1
  let ac := g.asks 0 = g.asks 2
  let bc := g.asks 1 = g.asks 2
  if ab ∧ ac then g
  else if ab ∨ ac ∨ bc then { g with asks := fun _ => vote g.asks }
  else { g with asks := fun _ => P.letGo }

/-- P3. `restore`. With the game comes whether every part could be settled. -/
def restore (g : Game V Q Tm) : Game V Q Tm × Bool :=
  let r := restoreParts P (vote g.bf) allParts g
  if r.2 then (restoreAsks P r.1, true) else (r.1, false)

/-- P2. `correct`. -/
def correct (g : Game V Q Tm) : Game V Q Tm :=
  let r := restore P g
  if r.2 = false then stick .notSettled r.1
  else
    let g := r.1
    let g := { g with ob := born P g }
    let lk : Look V := ⟨g.book.rounds, g.book.rounds, g.sp, g.ob, g.sp⟩
    let found := allWho.findSome? fun i => lookOf P i lk
    let g := keep (fun b => { b with restarts := b.restarts + 1 }) g
    if found.isSome = true ∨ (differs P g).isSome = true then stick .stillFound g
    else keep (fun b => { b with halt := none }) g

/-- P1. `mend`. -/
def mend (now : Tm) (g : Game V Q Tm) : Game V Q Tm :=
  match g.book.halt with
  | none => g
  | some h =>
    if h.stuck = true then g
    else if h.asked = true then correct P g
    else
      match g.book.how with
      | .atOnce => correct P g
      | .onAClick => g
      | .afterAPause =>
        let changed : Bool := decide (h.last ≠ some g.sp)
        let g' := if changed = true then
            keep (fun b => { b with
              halt := b.halt.map fun h => { h with last := some g.sp, quiet := now } }) g
          else g
        let quiet := if changed = true then now else h.quiet
        if P.pauseOver quiet now = true then correct P g' else g'

/-- P9. The game is begun again: a new game, but for the setting and the note of the
clock. -/
def beginAgain (now : Tm) (g : Game V Q Tm) : Game V Q Tm :=
  let how := g.book.how
  let clock := g.book.clock
  keep (fun b => { b with how := how, clock := clock }) (newGame P now)

/-! ### Section 6 of the specification: between two rounds -/

/-- E1 to E3: what can happen between two rounds. (E4 is a fault.) -/
inductive Ev (E : Type) where
  | ask (e : E)            -- E1
  | putRight               -- E2
  | setHow (h : How)       -- E3

/-- E1 to E3. -/
def event (e : Ev E) (g : Game V Q Tm) : Game V Q Tm :=
  match e with
  | .ask e =>
    if g.stuck = true then g
    else if P.taken g.halted (vote g.asks) e = true then
      { g with asks := fun k => P.takeDown g.halted e (g.asks k) }
    else g
  | .putRight =>
    keep (fun b => { b with halt := b.halt.map fun h => { h with asked := true } }) g
  | .setHow h => keep (fun b => { b with how := h }) g

/-- Several things between two rounds, one after another. -/
def events (es : List (Ev E)) (g : Game V Q Tm) : Game V Q Tm :=
  es.foldl (fun g e => event P e g) g

/-! ### Section 11 of the specification: the fault model -/

/-- F1 to F7. One cell changed, to any value. -/
inductive Cell (V Q Tm : Type) where
  | sp (p : Part) (v : V)                 -- F1
  | ob (i : Who) (o : Observer V)         -- F2
  | rt (p : Part) (v : V)                 -- F3
  | rc (p : Part) (v : V)                 -- F4
  | bk (k : Fin 3) (b : Book V Tm)        -- F5
  | bf (k : Fin 3) (x : Option (St V))    -- F6
  | asks (k : Fin 3) (q : Q)              -- F7

/-- The fault lands. -/
def Cell.hit (c : Cell V Q Tm) (g : Game V Q Tm) : Game V Q Tm :=
  match c with
  | .sp p v => { g with sp := fun q => if q = p then v else g.sp q }
  | .ob i o => { g with ob := fun j => if j = i then o else g.ob j }
  | .rt p v => { g with rt := fun q => if q = p then v else g.rt q }
  | .rc p v => { g with rc := fun q => if q = p then v else g.rc q }
  | .bk k b => { g with bk := fun j => if j = k then b else g.bk j }
  | .bf k x => { g with bf := fun j => if j = k then x else g.bf j }
  | .asks k q => { g with asks := fun j => if j = k then q else g.asks j }

/-! ### Section 7 of the specification: a round -/

/-- The steps of a round, R1 to R38, in order. -/
inductive Step where
  | settle1       -- R1
  | note          -- R2
  | settle2       -- R3
  | settleBefore  -- R4
  | setTime       -- R5
  | stuckCheck    -- R6
  | number        -- R7
  | running       -- R8
  | look          -- R9
  | answers       -- R10
  | signals       -- R11
  | spread        -- R12
  | respond       -- R13
  | selfCheck     -- R14
  | stateCheck    -- R15
  | obsCheck      -- R16
  | asksCheck     -- R17
  | decide        -- R18
  | mend          -- R19
  | readHeld      -- R20
  | keepBefore    -- R21
  | takeIn        -- R22
  | account       -- R23
  | world         -- R24
  | spider        -- R25
  | unfit         -- R26
  | copyRules     -- R27
  | rules1        -- R28
  | rules2        -- R29
  | redo          -- R30
  | compare       -- R31
  | obsAgain      -- R32
  | see           -- R33
  | takeCopies    -- R34
  | takeHeld      -- R35
  | writeRecord   -- R36
  | emptyAsks     -- R37
  | close         -- R38
  deriving DecidableEq, Repr

/-- Section 7: the order of the steps. -/
def steps : List Step :=
  [.settle1, .note, .settle2, .settleBefore, .setTime, .stuckCheck, .number,
   .running, .look, .answers, .signals, .spread, .respond,
   .selfCheck, .stateCheck, .obsCheck, .asksCheck, .decide,
   .mend,
   .readHeld, .keepBefore, .takeIn, .account, .world, .spider,
   .unfit, .copyRules, .rules1, .rules2, .redo, .compare, .obsAgain,
   .see, .takeCopies, .takeHeld, .writeRecord, .emptyAsks, .close]

/-- What a round is given: what the clock says, or, as the tests give it, its length
and its time (R1, R2). -/
inductive Inp (Tm Dt : Type) where
  | clock (c : Tm)
  | test (dt : Dt) (now : Tm)

/-- A round under way: what is stored, and what the round keeps of its own while it
runs (section 7). The last four fields are not the program's: they say afterwards what
the round did. -/
structure Run (V Q Tm Dt : Type) where
  g : Game V Q Tm
  /-- The round has ended early (R6, R19). -/
  over : Bool
  /-- R1: the time given to the first comparing of the books. -/
  t0 : Tm
  dt : Dt
  now : Tm
  beganHalted : Bool
  running : Who → Bool
  look : Look V
  answers : Who → Option (Option Finding)
  /-- R11: the first observer that did not answer. -/
  late : Option Who
  /-- R12: the reason the observers gave, if a flag is up. -/
  told : Option Finding
  stop : Bool
  /-- Whether the gate looks in this round: not halted before R14. -/
  gateLooks : Bool
  off : Option Off
  held : V
  asked : St V
  ruled1 : Bool
  refused : Option Cause
  made : St V
  seen : St V
  heldNow : V
  /-- What the round recorded (R36), or nothing. -/
  recorded : Option (St V)
  /-- The detection that halted everything in this round (H1, H2), or nothing. -/
  found : Option Cause
  /-- The round's work was begun (R21). -/
  worked : Bool
  /-- A halt was ended in this round (R19, P2). -/
  ended : Bool

/-- A look with nothing in it: what the round holds before R9 and after R18. -/
def noLook : Look V :=
  ⟨0, 0, fun _ => P.blank, fun _ => ⟨0, false, 0, fun _ => P.blank, P.blank, false, none⟩,
   fun _ => P.blank⟩

/-- H2. One detection halts everything, unless everything is already halted (R1, R3,
R4). -/
def Run.detect (why : Cause) (now : Tm) (r : Run V Q Tm Dt) : Run V Q Tm Dt :=
  if r.g.halted = true then r
  else { r with g := stopAll why now r.g, found := some why }

/-- R1, R3. `settle_books`. -/
def settleBooks (now : Tm) (r : Run V Q Tm Dt) : Run V Q Tm Dt :=
  let g := r.g
  let ab := g.bk 0 = g.bk 1
  let ac := g.bk 0 = g.bk 2
  let bc := g.bk 1 = g.bk 2
  if ab ∧ ac then r
  else if ab ∨ ac ∨ bc then
    Run.detect .books now { r with g := { g with bk := fun _ => vote g.bk } }
  else
    let r := Run.detect .booksNoTwo now { r with g := { g with bk := fun _ => g.bk 0 } }
    { r with g := stick .booksNoTwo r.g }

/-- R4. `settle_before`. -/
def settleBefore (now : Tm) (r : Run V Q Tm Dt) : Run V Q Tm Dt :=
  let g := r.g
  let ab := g.bf 0 = g.bf 1
  let ac := g.bf 0 = g.bf 2
  let bc := g.bf 1 = g.bf 2
  if ab ∧ ac then r
  else if ab ∨ ac ∨ bc then
    Run.detect .before now { r with g := { g with bf := fun _ => vote g.bf } }
  else
    Run.detect .before now { r with g := { g with bf := fun _ => none } }

/-- R12. A flag reaches every sound observer of a ring that has one flagging. -/
def spreadRing (why : Finding) (g : Game V Q Tm) (ring : Ring) : Game V Q Tm :=
  if ring.who.any (flagging g) = true then
    { g with ob := fun i =>
        if ring.who.contains i = true ∧ sound g i = true ∧ (g.ob i).flagged = false
        then { (g.ob i) with flagged := true, why := some why } else g.ob i }
  else g

/-- R36 with R30: what the second doing of the work makes. -/
def Params.redo (rc : St V) (q : Q) (dt : Dt) (now : Tm) : St V :=
  P.spider₂ (P.world₂ (P.takeIn₂ rc q) (P.inWeb₂ rc) dt now) dt now

/-- One step of a round. A step does nothing once the round has ended early. -/
def step (inp : Inp Tm Dt) (s : Step) (r : Run V Q Tm Dt) : Run V Q Tm Dt :=
  if r.over = true then r
  else
  let g := r.g
  match s with
  -- R1
  | .settle1 => settleBooks r.t0 r
  -- R2
  | .note =>
    match inp with
    | .clock c =>
      let dt := P.len g.book.clock c
      let g := if P.readable c = true then keep (fun b => { b with clock := c }) g else g
      { r with g := g, dt := dt, now := P.adv g.book.time dt }
    | .test dt now => { r with g := keep (fun b => { b with clock := now }) g, dt := dt, now := now }
  -- R3
  | .settle2 => settleBooks r.now r
  -- R4
  | .settleBefore => settleBefore r.now r
  -- R5
  | .setTime => { r with g := keep (fun b => { b with time := r.now }) g }
  -- R6
  | .stuckCheck =>
    match g.book.halt with
    | none => r
    | some h =>
      if h.stuck = true then
        { r with g := if h.asked = true then beginAgain P r.now g else g, over := true }
      else r
  -- R7
  | .number =>
    { r with beganHalted := g.halted, g := keep (fun b => { b with rounds := b.rounds + 1 }) g }
  -- R8
  | .running => { r with running := fun i => (g.ob i).alive }
  -- R9
  | .look => { r with look := ⟨g.book.rounds, g.book.rounds - 1, g.sp, g.ob, g.sp⟩ }
  -- R10
  | .answers =>
    { r with answers := fun i => if r.running i = true then some (lookOf P i r.look) else none }
  -- R11
  | .signals =>
    let rounds := g.book.rounds
    let ob' : Who → Observer V := fun i =>
      if r.running i = true then
        match r.answers i with
        | some w =>
          if w.isSome = true then { (g.ob i) with beat := rounds, flagged := true, why := w }
          else { (g.ob i) with beat := rounds }
        | none => g.ob i
      else g.ob i
    { r with
      g := { g with ob := ob' },
      late := allWho.find? fun i => r.running i && (r.answers i).isNone }
  -- R12
  | .spread =>
    match allWho.find? (flagging g) with
    | none => { r with told := none }
    | some f =>
      let why := ((g.ob f).why).getD Finding.flagUp
      let g := rings.foldl (spreadRing why) g
      let g := rings.foldl (spreadRing why) g
      { r with g := g, told := some why }
  -- R13
  | .respond =>
    { r with stop := allWho.any fun i =>
        ((g.ob i).flagged && sound g i) || (g.ob i).beat != g.book.rounds }
  -- R14
  | .selfCheck =>
    if g.halted = true then { r with gateLooks := false, off := none }
    else { r with gateLooks := true, off := selfCheck g }
  -- R15
  | .stateCheck =>
    if r.gateLooks = true ∧ r.off = none then { r with off := stateCheck g } else r
  -- R16
  | .obsCheck =>
    if r.gateLooks = true ∧ r.off = none then { r with off := obsOff P g } else r
  -- R17
  | .asksCheck =>
    if r.gateLooks = true ∧ r.off = none then { r with off := asksCheck g } else r
  -- R18. Whether everything was halted was looked at once, before R14 (`gateLooks`).
  -- What the round kept for R8 to R17 is let go here: nothing reads it again.
  | .decide =>
    let r' :=
      if r.gateLooks = true ∧ (r.stop = true ∨ r.off.isSome = true) then
        let why : Cause :=
          if r.stop = false then .gate (r.off.getD .asks)
          else match r.told, r.late with
            | some f, _ => .observer f
            | none, some i => .late i
            | none, none => .silent
        { r with g := stopAll why r.now r.g, found := some why }
      else r
    { r' with running := fun _ => false, look := noLook P,
              answers := fun _ => none, late := none, told := none, stop := false,
              gateLooks := false, off := none }
  -- R19
  | .mend =>
    if g.halted = true then
      let g' := mend P r.now g
      { r with g := g', ended := !g'.halted,
               over := g'.halted || decide (g'.book.how ≠ How.atOnce) }
    else r
  -- R20
  | .readHeld => { r with held := (g.ob moths).held }
  -- R21
  | .keepBefore => { r with g := { g with bf := fun _ => some g.sp }, worked := true }
  -- R22
  | .takeIn => { r with g := { g with sp := P.takeIn₁ g.sp (g.asks 0) } }
  -- R23
  | .account => { r with asked := g.sp }
  -- R24
  | .world => { r with g := { g with sp := P.world₁ g.sp r.held r.dt r.now } }
  -- R25
  | .spider => { r with g := { g with sp := P.spider₁ g.sp r.dt r.now } }
  -- R26
  | .unfit => if P.real g.sp = false then { r with refused := some .unfit } else r
  -- R27
  | .copyRules =>
    if r.refused = none ∧ (P.canBe₁ g.rc = false ∨ P.canBe₂ g.rc = false)
    then { r with refused := some .copyRules } else r
  -- R28
  | .rules1 =>
    if r.refused = none then
      { r with ruled1 := P.canBe₁ g.sp && P.step₁ g.rc (P.inWeb₁ g.rc) g.sp r.asked r.dt r.now }
    else r
  -- R29
  | .rules2 =>
    if r.refused = none ∧
        (r.ruled1 = false ∨
          (P.canBe₂ g.sp && P.step₂ g.rc (P.inWeb₂ g.rc) g.sp (P.takeIn₂ g.rc (g.asks 1)) r.dt r.now)
            = false)
    then { r with refused := some .rules } else r
  -- R30
  | .redo => if r.refused = none then { r with made := P.redo g.rc (g.asks 1) r.dt r.now } else r
  -- R31
  | .compare =>
    if r.refused = none ∧ r.made ≠ g.sp then { r with refused := some .redone } else r
  -- R32
  | .obsAgain =>
    if r.refused = none then
      match obsOff P g with
      | some o => { r with refused := some (.during o) }
      | none => r
    else r
  -- R33
  | .see => if r.refused = none then { r with seen := g.sp, heldNow := P.inWeb₁ g.sp } else r
  -- R34
  | .takeCopies =>
    if r.refused = none then
      let ob' : Who → Observer V := fun i =>
        if sound g i = true then { (g.ob i) with copies := copiesFor P i r.seen } else g.ob i
      { r with g := { g with ob := ob' } }
    else r
  -- R35
  | .takeHeld =>
    if r.refused = none ∧ sound g moths = true then
      let ob' : Who → Observer V := fun i =>
        if i = moths then { (g.ob i) with held := r.heldNow } else g.ob i
      { r with g := { g with ob := ob' } }
    else r
  -- R36
  | .writeRecord =>
    if r.refused = none then
      { r with g := { g with rt := r.made, rc := r.made }, recorded := some r.made }
    else r
  -- R37
  | .emptyAsks =>
    if r.refused = none then { r with g := { g with asks := fun _ => P.noAsks } } else r
  -- R38
  | .close =>
    match r.refused with
    | none =>
      { r with g := keep (fun b => { b with spoiled := 0,
                                            stops := if r.beganHalted = true then b.stops else 0 }) g }
    | some why =>
      let r := { r with g := stopAll why r.now g, found := some why }
      let g := keep (fun b => { b with spoiled := b.spoiled + 1 }) r.g
      if g.book.spoiled > 1 then { r with g := stick .twice (restore P g).1 }
      else { r with g := g }

/-- Section 11. A fault in a round: none; one cell changed immediately before a step
(F1 to F7); or one observer's answer replaced between R10 and R11 (F8). -/
inductive Sched (V Q Tm : Type) where
  | none
  | cell (s : Step) (c : Cell V Q Tm)
  | answer (i : Who) (a : Option (Option Finding))

/-- The fault, if this is its instant. -/
def inject (sch : Sched V Q Tm) (s : Step) (r : Run V Q Tm Dt) : Run V Q Tm Dt :=
  match sch with
  | .none => r
  | .cell s' c => if s' = s then { r with g := c.hit r.g } else r
  | .answer i a =>
    if s = Step.signals ∧ r.over = false then
      { r with answers := fun j => if j = i then a else r.answers j }
    else r

/-- Some steps, one after another, with the fault where it lands. -/
def run (inp : Inp Tm Dt) (sch : Sched V Q Tm) : List Step → Run V Q Tm Dt → Run V Q Tm Dt
  | [], r => r
  | s :: ss, r => run inp sch ss (step P inp s (inject sch s r))

/-- A round about to begin. What is not yet set holds nothing that is read. -/
def start (inp : Inp Tm Dt) (g : Game V Q Tm) : Run V Q Tm Dt :=
  let t0 := match inp with
    | .clock _ => g.book.time
    | .test _ now => now
  let dt := match inp with
    | .clock c => P.len g.book.clock c
    | .test dt _ => dt
  { g := g, over := false, t0 := t0, dt := dt, now := t0, beganHalted := false,
    running := fun _ => false, look := noLook P, answers := fun _ => none,
    late := none, told := none, stop := false, gateLooks := false, off := none,
    held := P.blank, asked := fun _ => P.blank, ruled1 := false, refused := none,
    made := fun _ => P.blank, seen := fun _ => P.blank, heldNow := P.blank, recorded := none,
    found := none, worked := false,
    ended := false }

/-- Section 7. One round. -/
def round (inp : Inp Tm Dt) (sch : Sched V Q Tm) (g : Game V Q Tm) : Run V Q Tm Dt :=
  run P inp sch steps (start P inp g)

/-- Section 11. Where one fault lands in one round and in what comes before it: after
the first `n` things that happen between the rounds (and before the rest); immediately
before a step of the round; or in one observer's answer. -/
inductive Fault (V Q Tm : Type) where
  | between (n : Nat) (c : Cell V Q Tm)
  | before (s : Step) (c : Cell V Q Tm)
  | answer (i : Who) (a : Option (Option Finding))

/-- What happens between two rounds, and then the round: with one fault, or none. -/
def tick (es : List (Ev E)) (inp : Inp Tm Dt) (f : Option (Fault V Q Tm))
    (g : Game V Q Tm) : Run V Q Tm Dt :=
  match f with
  | none => round P inp .none (events P es g)
  | some (.between n c) =>
    round P inp .none (events P (es.drop n) (c.hit (events P (es.take n) g)))
  | some (.before s c) => round P inp (.cell s c) (events P es g)
  | some (.answer i a) => round P inp (.answer i a) (events P es g)

end

end Gate
