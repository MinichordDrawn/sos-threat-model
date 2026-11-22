import GateProof.Toy
import GateProof.Eval
open Gate Gate.Toy

/-!
A test of the statements on the toy game, by evaluation: every step of a round, a list of
faults, the three settings; then five more ticks. It checks T1, T2, T3, T4, T2 at once and
that the run ends clean. Here two values can share a fingerprint and the pause is three
ticks of the clock, so that coordinators can miss a change and a pause can end.

Run from the `lean` folder:  lake env lean test/SelfTest.lean
-/

def Pc : Params V Q E Tm Dt :=
  { P with fp := fun v => v % 5 + 1000, pauseOver := fun quiet now => decide (quiet + 3 ≤ now) }

def playedE : Nat → Game V Q Tm
  | 0 => newGame Pc 0
  | n + 1 => (roundE Pc (.clock (n + 1)) .none (playedE n)).g
def baseE (h : How) : Game V Q Tm := (keep (fun b => { b with how := h }) (playedE 3)).tab

def gameEq (a b : Game V Q Tm) : Bool :=
  decide (a.sp = b.sp) && decide (a.rt = b.rt) && decide (a.rc = b.rc) && decide (a.ob = b.ob)
  && decide (a.bk = b.bk) && decide (a.bf = b.bf) && decide (a.asks = b.asks)

def settledB (g : Game V Q Tm) : Bool :=
  decide (g.sp = g.rt) && decide (g.rc = g.rt) && decide (∀ i, g.ob i = born Pc g i)
  && decide (g.bk 0 = g.bk 1 ∧ g.bk 0 = g.bk 2) && (g.bk 0).halt.isNone
  && decide (g.bf 0 = g.bf 1 ∧ g.bf 0 = g.bf 2) && decide (g.asks 0 = g.asks 1 ∧ g.asks 0 = g.asks 2)

def someObs (g : Game V Q Tm) : List (Observer V) :=
  let o := g.ob 5
  [{ o with alive := false }, { o with beat := o.beat + 1 }, { o with beat := 0 }, { o with held := 77 },
   { o with flagged := true }, { o with why := some (.other 1) }, { o with name := 9 },
   { o with copies := fun p => if p = 4 then 55 else o.copies p },
   { o with copies := fun p => if p = 0 then 55 else o.copies p }]
def cells (g : Game V Q Tm) : List (Cell V Q Tm) :=
  [.sp 2 99, .sp 4 99, .sp 6 99, .sp 3 11, .sp 5 (g.sp 5 + 3), .rt 2 99, .rt 4 99, .rt 5 (g.rt 5 + 5), .rc 2 99, .rc 4 99, .rc 3 11, .rc 6 1,
   .rc 5 (g.rc 5 + 3), .rc 5 (g.rc 5 + 1),
   .bk 0 { g.bk 0 with rounds := 77 }, .bk 1 { g.bk 1 with halt := some ⟨.other 0, 0, none, true, true⟩ },
   .bk 2 { g.bk 2 with spoiled := 5 }, .bk 1 { g.bk 1 with how := .onAClick }, .bk 2 { g.bk 2 with clock := 99 },
   .bf 0 none, .bf 1 (some fun _ => 3), .asks 0 [5], .asks 1 [5], .asks 2 [5], .asks 1 [0]]
   ++ (someObs g).map (.ob 5) ++ [.ob 3 { g.ob 3 with copies := fun p => if p = 4 then 1001 else (g.ob 3).copies p },
     .ob 0 { g.ob 0 with alive := false }, .ob 6 { g.ob 6 with flagged := true, why := some .flagUp }]

def faults (g : Game V Q Tm) : List (Fault V Q Tm) :=
  (steps.flatMap fun s => (cells g).map fun c => Fault.before s c)
  ++ (cells g).flatMap (fun c => [Fault.between 0 c, Fault.between 1 c, Fault.between 2 c])
  ++ [Fault.answer 2 none, .answer 2 (some (some (.other 3))), .answer 6 none, .answer 5 (some (some .list)), .answer 5 (some none)]

def es0 : List (Ev E) := [.ask 0, .ask 4]
def es1 : List (Ev E) := [.ask 7, .putRight]
def es1' : List (Ev E) := [.ask 7]

/-- one fault, then up to 6 ticks; returns list of violations -/
def check (h : How) (f : Fault V Q Tm) : List String :=
  let g := baseE h
  let r0 := tickE Pc es0 (.clock 4) (some f) g
  let t0 := tickE Pc es0 (.clock 4) none g
  let v1 := if r0.recorded.isNone || decide (r0.recorded = t0.recorded) then [] else ["T1"]
  let r1 := tickE Pc es1' (.clock 5) none r0.g
  let t1 := tickE Pc es1' (.clock 5) none t0.g
  let v4 := if r0.found.isSome || r1.found.isSome || (gameEq r1.g t1.g && decide (r0.recorded = t0.recorded) && decide (r1.recorded = t1.recorded)) then [] else ["T4"]
  let r2 := tickE Pc es1 (.clock 6) none r1.g
  let r3 := tickE Pc [] (.clock 7) none r2.g
  let r4 := tickE Pc [] (.clock 20) none r3.g
  let r5 := tickE Pc [] (.clock 21) none r4.g
  let all := [r0, r1, r2, r3, r4, r5]
  let v3 := if all.any (fun r => r.g.stuck) then ["T3"] else []
  let v2 := if all.any (fun r => !r.g.halted && decide (g.book.halts < r.g.book.halts) && !settledB r.g) then ["T2"] else []
  let v5 := if r5.g.halted || !settledB r5.g || (r5.g.book.spoiled != 0) then ["end"] else []
  let v6 := if r0.found.isSome && r0.ended && r0.worked && !(decide (r0.g.sp = t0.g.sp) && decide (r0.g.ob = t0.g.ob) && decide (r0.g.rt = t0.g.rt) && decide (r0.g.bf = t0.g.bf) && decide (r0.g.asks = t0.g.asks)) then ["T2ao"] else []
  v1 ++ v2 ++ v3 ++ v4 ++ v5 ++ v6

def allChecks : List (String) :=
  [How.atOnce, .afterAPause, .onAClick].flatMap fun h =>
    ((faults (baseE h)).zipIdx.filterMap fun (f, n) =>
      let v := check h f
      if v.isEmpty then none else some s!"{repr h} #{n}: {v}")
#eval (faults (baseE .atOnce)).length
#eval allChecks
