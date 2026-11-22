/-
Evaluating the model. A game holds functions, and a function built step upon step is
slow to evaluate. `tab` writes a function out as a table, which is the same function
(`tab_eq`), and `roundE` is `round` with every function written out after each step. The
two are proved equal (`roundE_eq`), so what is evaluated is the model itself.
-/
import GateProof.Model

namespace Gate

/-- A table read as a function. Where the table has no entry, `d` is asked. -/
@[noinline] def tabWith {n : Nat} {α : Type} (a : Array α) (d : Fin n → α) (i : Fin n) : α :=
  if h : i.val < a.size then a[i.val] else d i

/-- A function on finitely many places, written out as a table. The table is made when
this is applied to the function, and not again each time a place is read. -/
def tab {n : Nat} {α : Type} (f : Fin n → α) : Fin n → α :=
  let a := Array.ofFn f
  tabWith a f

theorem tab_eq {n : Nat} {α : Type} (f : Fin n → α) : tab f = f := by
  funext i
  simp [tab, tabWith]

section
variable {V Q E Tm Dt : Type}

def Observer.tab (o : Observer V) : Observer V :=
  let c := Array.ofFn o.copies
  { o with copies := tabWith c o.copies }

/-- A state that may not be there, written out. -/
def tabState (x : Option (St V)) : Option (St V) :=
  match x with
  | none => none
  | some s =>
    let a := Array.ofFn s
    some (tabWith a s)

def Halt.tab (h : Halt V Tm) : Halt V Tm :=
  let l := tabState h.last
  { h with last := l }

def Book.tab (b : Book V Tm) : Book V Tm :=
  match b.halt with
  | none => b
  | some h =>
    let h' := h.tab
    { b with halt := some h' }

def Game.tab (g : Game V Q Tm) : Game V Q Tm :=
  let sp := Array.ofFn g.sp
  let ob := Array.ofFn fun i => (g.ob i).tab
  let rt := Array.ofFn g.rt
  let rc := Array.ofFn g.rc
  let bk := Array.ofFn fun k => (g.bk k).tab
  let bf := Array.ofFn fun k => tabState (g.bf k)
  let asks := Array.ofFn g.asks
  { sp := tabWith sp g.sp, ob := tabWith ob g.ob, rt := tabWith rt g.rt, rc := tabWith rc g.rc,
    bk := tabWith bk g.bk, bf := tabWith bf g.bf, asks := tabWith asks g.asks }

def Run.tab (r : Run V Q Tm Dt) : Run V Q Tm Dt :=
  let g := r.g.tab
  let running := Array.ofFn r.running
  let texts := Array.ofFn r.look.texts
  let ring := Array.ofFn fun i => (r.look.ring i).tab
  let world := Array.ofFn r.look.world
  let answers := Array.ofFn r.answers
  let asked := Array.ofFn r.asked
  let made := Array.ofFn r.made
  let seen := Array.ofFn r.seen
  let recorded := tabState r.recorded
  { r with g := g, running := tabWith running r.running,
           look := { r.look with texts := tabWith texts r.look.texts,
                                 ring := tabWith ring r.look.ring,
                                 world := tabWith world r.look.world },
           answers := tabWith answers r.answers, asked := tabWith asked r.asked,
           made := tabWith made r.made, seen := tabWith seen r.seen, recorded := recorded }

theorem tabWith_ofFn {n : Nat} {α : Type} (f : Fin n → α) : tabWith (Array.ofFn f) f = f := by
  funext i
  simp [tabWith]

theorem tabWith_ofFn' {n : Nat} {α : Type} (f f' : Fin n → α) (h : f' = f) :
    tabWith (Array.ofFn f') f = f := by
  funext i
  simp [tabWith, h]

theorem tabState_eq (x : Option (St V)) : tabState x = x := by
  cases x <;> simp [tabState, tabWith_ofFn]

theorem Observer.tab_eq (o : Observer V) : o.tab = o := by
  simp [Observer.tab, tabWith_ofFn]

theorem Book.tab_eq (b : Book V Tm) : b.tab = b := by
  cases b with
  | mk halt how halts restarts spoiled stops clock time rounds rest =>
    cases halt with
    | none => rfl
    | some h => simp [Book.tab, Halt.tab, tabState_eq]

theorem Game.tab_eq (g : Game V Q Tm) : g.tab = g := by
  simp [Game.tab, tabWith_ofFn, tabWith_ofFn', Observer.tab_eq, Book.tab_eq, tabState_eq]

theorem Run.tab_eq (r : Run V Q Tm Dt) : r.tab = r := by
  simp [Run.tab, tabWith_ofFn, tabWith_ofFn', Observer.tab_eq, Game.tab_eq, tabState_eq]

variable [DecidableEq V] [DecidableEq Q] [DecidableEq Tm] (P : Params V Q E Tm Dt)

/-- `run`, with everything written out after each step. -/
def runE (inp : Inp Tm Dt) (sch : Sched V Q Tm) : List Step → Run V Q Tm Dt → Run V Q Tm Dt
  | [], r => r
  | s :: ss, r => runE inp sch ss (step P inp s (inject sch s r)).tab

theorem runE_eq (inp : Inp Tm Dt) (sch : Sched V Q Tm) (l : List Step) (r : Run V Q Tm Dt) :
    runE P inp sch l r = run P inp sch l r := by
  induction l generalizing r with
  | nil => rfl
  | cons s ss ih => simp [runE, run, Run.tab_eq, ih]

/-- `round`, evaluated quickly. -/
def roundE (inp : Inp Tm Dt) (sch : Sched V Q Tm) (g : Game V Q Tm) : Run V Q Tm Dt :=
  runE P inp sch steps (start P inp g.tab)

theorem roundE_eq (inp : Inp Tm Dt) (sch : Sched V Q Tm) (g : Game V Q Tm) :
    roundE P inp sch g = round P inp sch g := by
  simp [roundE, round, runE_eq, Game.tab_eq]

/-- `tick`, evaluated quickly. -/
def tickE (es : List (Ev E)) (inp : Inp Tm Dt) (f : Option (Fault V Q Tm))
    (g : Game V Q Tm) : Run V Q Tm Dt :=
  match f with
  | none => roundE P inp .none (events P es g).tab
  | some (.between n c) =>
    roundE P inp .none (events P (es.drop n) (c.hit (events P (es.take n) g).tab)).tab
  | some (.before s c) => roundE P inp (.cell s c) (events P es g).tab
  | some (.answer i a) => roundE P inp (.answer i a) (events P es g).tab

theorem tickE_eq (es : List (Ev E)) (inp : Inp Tm Dt) (f : Option (Fault V Q Tm))
    (g : Game V Q Tm) : tickE P es inp f g = tick P es inp f g := by
  cases f with
  | none => simp [tickE, tick, roundE_eq, Game.tab_eq]
  | some f => cases f <;> simp [tickE, tick, roundE_eq, Game.tab_eq]

end

end Gate
