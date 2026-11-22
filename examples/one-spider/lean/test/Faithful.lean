/-
The Lean side of the faithfulness check. It evaluates the model (through `roundE`, which
is proved equal to `round`) on the situations of `faithfulness\rust-task.md`, with the
toy game in place of the real one, and prints the same table.

Run from the `lean` folder:  lake env lean test/Faithful.lean > ../faithfulness/lean-table.txt
-/
import GateProof.Toy
import GateProof.Eval

open Gate Gate.Toy

/-- The base: the toy game after five rounds, given as the tests give them. -/
def baseAt : Nat → Game V Q Tm
  | 0 => newGame P 0
  | n + 1 => (roundE P (.test 1 (n + 1)) .none (baseAt n)).g

def nums (l : List Nat) : String :=
  if l.isEmpty then "-" else ",".intercalate (l.map toString)

def finding : Finding → String
  | .ownSignal => "obs:ownSignal"
  | .partChanged p => s!"obs:partChanged:{p}"
  | .copyDiffers j p => s!"obs:copyDiffers:{j}:{p}"
  | .silent j => s!"obs:silent:{j}"
  | .changed j => s!"obs:changed:{j}"
  | .list => "obs:list"
  | .flagUp => "obs:flagUp"
  | .other _ => "obs:other"

def off : Off → String
  | .recordSelf p => s!"recordSelf:{p}"
  | .partChanged p => s!"partChanged:{p}"
  | .observer i => s!"observer:{i}"
  | .recordChanged => "recordChanged"
  | .asks => "asks"

def cause : Cause → String
  | .books => "books"
  | .booksNoTwo => "booksNoTwo"
  | .before => "before"
  | .observer f => finding f
  | .late i => s!"late:{i}"
  | .silent => "silent"
  | .gate o => "gate:" ++ off o
  | .unfit => "refused"
  | .copyRules => "refused"
  | .rules => "refused"
  | .redone => "refused"
  | .during o => "during:" ++ off o
  | .notSettled => "notSettled"
  | .stillFound => "stillFound"
  | .twice => "twice"
  | .other _ => "other"

def bit (b : Bool) : String := if b then "1" else "0"

/-- The observables after one round. `rec` and `wk` are counted by the caller. -/
def obs (r : Run V Q Tm Dt) (rec wk : Nat) : String :=
  let g := r.g
  let c := match r.found with
    | some c => cause c
    | none => "-"
  let d := allParts.all fun p => g.sp p == g.rt p
  let k := (allParts.filter fun p => g.rt p != g.rc p).map (·.val)
  let o := (allWho.filter fun i => decide (g.ob i ≠ born P g i)).map (·.val)
  let a := decide (g.asks 0 = g.asks 1 ∧ g.asks 0 = g.asks 2)
  let b := decide (g.bk 0 = g.bk 1 ∧ g.bk 0 = g.bk 2)
  let f := decide (g.bf 0 = g.bf 1 ∧ g.bf 0 = g.bf 2)
  s!"H{bit g.halted} S{bit g.stuck} h{g.book.halts} r{g.book.restarts} sp{g.book.spoiled} rec{rec} wk{wk} c={c} D{bit d} k={nums k} o={nums o} a{bit a} b{bit b} f{bit f}"

/-- Five rounds, the first with the fault, and "Put it right" asked before the third. -/
def five (g : Game V Q Tm) (sch : Sched V Q Tm) : String :=
  let now := g.book.time
  let r1 := roundE P (.test 1 (now + 1)) sch g
  let c1 := (if r1.recorded.isSome then 1 else 0, if r1.worked then 1 else 0)
  let r2 := roundE P (.test 1 (now + 2)) .none r1.g
  let c2 := (c1.1 + if r2.recorded.isSome then 1 else 0, c1.2 + if r2.worked then 1 else 0)
  let r3 := roundE P (.test 1 (now + 3)) .none (event P (Ev.putRight : Ev E) r2.g).tab
  let c3 := (c2.1 + if r3.recorded.isSome then 1 else 0, c2.2 + if r3.worked then 1 else 0)
  let r4 := roundE P (.test 1 (now + 4)) .none r3.g
  let c4 := (c3.1 + if r4.recorded.isSome then 1 else 0, c3.2 + if r4.worked then 1 else 0)
  let r5 := roundE P (.test 1 (now + 5)) .none r4.g
  let c5 := (c4.1 + if r5.recorded.isSome then 1 else 0, c4.2 + if r5.worked then 1 else 0)
  s!"r1: {obs r1 c1.1 c1.2} | r2: {obs r2 c2.1 c2.2} | r3: {obs r3 c3.1 c3.2} | r4: {obs r4 c4.1 c4.2} | r5: {obs r5 c5.1 c5.2}"

/-- The hooks of the Rust table, and the step each is immediately before. -/
def hooks : List (Nat × Step) :=
  [(0, .settle1), (7, .number), (8, .running), (11, .signals), (13, .respond), (14, .selfCheck),
   (15, .stateCheck), (16, .obsCheck), (17, .asksCheck), (20, .readHeld), (22, .takeIn),
   (26, .unfit), (30, .redo), (32, .obsAgain), (33, .see), (36, .writeRecord),
   (37, .emptyAsks), (38, .close)]

/-- The faults of the Rust table: each makes its cell from the game as it is at the
instant, as the Rust fault does. -/
def faultsAt : List (String × (Game V Q Tm → Cell V Q Tm)) :=
  let ob (i : Who) (f : Observer V → Observer V) : Game V Q Tm → Cell V Q Tm :=
    fun g => .ob i (f (g.ob i))
  [("s2", fun g => .sp 2 (g.sp 2 + 80)), ("s3", fun g => .sp 3 (g.sp 3 + 1)),
   ("s4", fun g => .sp 4 (g.sp 4 + 5)), ("s6", fun g => .sp 6 (g.sp 6 + 1000)),
   ("t2", fun g => .rt 2 (g.rt 2 + 1000)), ("t4", fun g => .rt 4 (g.rt 4 + 1000)),
   ("c2", fun g => .rc 2 (g.rc 2 + 150)), ("c4", fun g => .rc 4 (g.rc 4 + 100000)),
   ("b0r", fun g => .bk 0 { g.bk 0 with rounds := (g.bk 0).rounds + 5 }),
   ("b1h", fun g => .bk 1 { g.bk 1 with halt := some ⟨.other 0, 0, none, true, true⟩ }),
   ("b2s", fun g => .bk 2 { g.bk 2 with spoiled := 3 }),
   ("f0", fun _ => .bf 0 none),
   ("f1", fun g => .bf 1 (match g.bf 1 with
      | some s => some fun p => if p = 4 then s 4 + 1 else s p
      | none => some g.sp)),
   ("a0r", fun g => .asks 0 (g.asks 0 ++ [0])), ("a0p", fun g => .asks 0 (g.asks 0 ++ [5])),
   ("a1p", fun g => .asks 1 (g.asks 1 ++ [5])), ("a2p", fun g => .asks 2 (g.asks 2 ++ [5]))]
  ++ ([0, 3, 5, 6].map fun i => (s!"oA-{i}", ob i fun o => { o with alive := false }))
  ++ ([0, 3, 5, 6].map fun i => (s!"oB-{i}", ob i fun o => { o with beat := o.beat + 1 }))
  ++ ([(0, 0), (3, 4), (5, 4), (6, 5)].map fun (i, p) =>
        (s!"oC-{i}", ob i fun o => { o with copies := fun q => if q = p then o.copies p + 1 else o.copies q }))
  ++ ([(0, 4), (5, 0), (6, 1)].map fun (i, p) =>
        (s!"oN-{i}", ob i fun o => { o with copies := fun q => if q = p then 7777 else o.copies q }))
  ++ ([0, 3, 5, 6].map fun i => (s!"oH-{i}", ob i fun o => { o with held := o.held + 9 }))
  ++ ([0, 3, 5, 6].map fun i => (s!"oF-{i}", ob i fun o => { o with flagged := true }))
  ++ ([0, 3, 5, 6].map fun i => (s!"oW-{i}", ob i fun o => { o with why := some (.other 1) }))
  ++ ([0, 3, 5, 6].map fun i => (s!"oM-{i}", ob i fun o => { o with name := 99 }))

def answersAt : List (String × Sched V Q Tm) :=
  [("n2", .answer 2 none), ("w2", .answer 2 (some (some (.other 1)))),
   ("n6", .answer 6 none), ("w5", .answer 5 (some (some (.other 1))))]

/-- The game as it is immediately before a step of the first round, with no fault. -/
def gameBefore (g : Game V Q Tm) (s : Step) : Game V Q Tm :=
  let now := g.book.time
  (runE P (.test 1 (now + 1)) .none (steps.takeWhile (· != s)) (start P (.test 1 (now + 1)) g)).g

def table : List String :=
  [("once", How.atOnce), ("pause", How.afterAPause), ("click", How.onAClick)].flatMap fun (name, how) =>
    let g := (keep (fun b => { b with how := how }) (baseAt 5)).tab
    (faultsAt.flatMap fun (id, mk) =>
      hooks.map fun (n, s) =>
        s!"{name} | {id} | {n} | {five g (.cell s (mk (gameBefore g s)))}")
    ++ (answersAt.map fun (id, sch) => s!"{name} | {id} | ans | {five g sch}")

def main : IO Unit := for l in table do IO.println l

#eval main
