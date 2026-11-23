# Hand-back: check of corrections 1

Folder checked: `«WORK»\sos-minimal-ring\verify-corrections\`. I read nothing outside it and left it as I found it (I removed one `__pycache__` that my own runs created there).

## In the first lines

**One corrected statement is wrong as it stands, one added system is not what its name says, and a few corrected sentences say slightly more or less than is shown. Every number I recomputed came out as printed, and no result changes.**

1. **Fails: Lemma M-scope (change 13).** It is stated, and marked Proved, for "any two systems of `model-spec-scope.md` with no window". In that class it is false when `freeze` is true and several monitors share a boundary (or a substrate). One added signal read lowers G1 of a scope from 4 rounds to 3; the system and the execution are under check 3. The step that does not follow is the proof's first sentence. The lemma does hold when no two monitors share a boundary and nothing runs on a substrate, or when `freeze` is false. That covers both places the write-up uses it, as the write-up describes those systems. The class has to be narrowed; nothing else moves.
2. **The added system `added/r2-readers/fifteen-edges` does not meet the whole list.** In it D reads no signal and checks no state, so R3 fails under either choice. It is one of the 6,561 listed sets but not one of the 6,318. The figure 15 and all the counts are right.
3. **Smaller points**, none changing a result: the new bullet in `part-a.md`'s verdict (change 26) says more than its table; one sentence each in changes 12, 14 and 19 is looser than what is shown; the flow part of Condition 2 gives a sufficient case, and I found a second top-last order under flow with no gap.
4. **Left behind:** six more sentences besides the two the author names (check 6).
5. **My own conduct:** one of my runs broke your memory rule. A search I had left unbounded grew to about 6.2 GB for a few minutes before I saw it and stopped it. Every later run carried a bound on states and stayed under about 0.4 GB as far as I sampled.

## Check 1. The list is the whole of the change

**Did.** Parsed the 45 entries of `corrections-1.md`. For each, confirmed the before text occurs exactly once in the before file and the after text exactly once in the current file. Then applied all entries to the three before files and compared with the current files, after normalising line ends (the three files use CRLF, the list LF).

**Found.** The result equals the current file exactly in all three cases: `results-minimal.md` (entries 1 to 22), `part-a.md` (23 to 35), `model-spec-scope.md` (36 to 45, the ten passages). A line diff gives 22, 14 and 12 changed blocks, all inside entries. Nothing changed that is not listed, and every entry is in the files as printed.

## Check 2. The 36 added systems

**Did.**
- Ran `independent_model.py` on `systems-minimal-added.json`: all 36 answers equal `results-minimal-added.json`.
- Wrote a plain implementation of my own from the three specification files as they are now (sets of names, gate in place). It gives the same on 35. The 36th, `added/grow/both-whole/actor/one/f3` (1.2 million states), is too large for it. Its G2 in one round I confirmed by replay; its "G1 not within 2 rounds" rests on `independent_model.py` alone.
- Compared the two implementations on 2,400 random single rings (`f` = 1, 2, 3, both wirings of the work): no difference.
- Built all 36 from the write-ups' descriptions and compared every field the model reads.

**Found.**
- My systems equal the catalogue's except in two ways of writing the same thing. The catalogue writes `scope_work` out for the ring scopes; and its `after` lists name the work process (W2, W3) where mine name monitors. Answers are the same.
- The further readings: `added/reading/split/...` is the candidate under "Y reads X's signal, X checks Y's state, X reports to Y"; `added/reading/watch-against-report-both/...` is the candidate under actor's watching with the report both ways.
- The three join orders and the three-rings-without-T systems are what the text says.
- **The fifteen-edge system is not a set that meets the list.** Its edges: A is read by B, C; B by A, C; C by A, B; D by A, B; A is checked by B; B, C and D by A; A, B, C report to D. D observes nobody, so D reaches nobody and R3 fails, read as "watches" or as "reads the signal". At `f` = 1 it has no gap and told holds, as recorded; at `f` = 2 and 3 it has a gap, as recorded. The fourteen-edge system is this set less "A checks D" and gives G1 and G2 in one round, as the text says.
- A set of 15 that does meet the whole list at `f` = 1, 2 and 3: reads A by B, C; B by A, C; C by A, D; D by A, B; checks A by B, B by C, C by D, D by A; the three reports to D.

## Check 3. Every corrected statement

### The table of readings of an arrow

**Did.** All 27 readings on all 4,096 wirings, `f` = 1, the work reading all, R2, R3 and R5 as stated.

| Readings | Fewest (wirings) | The candidate |
|---|---|---|
| flow, its mirror, and the four with one watching kind both ways | 8 (24, 4 shapes) | meets the list, one over |
| actor, its mirror, and the four alike | 9 (26, 6 shapes) | least |
| those six watching patterns, report both ways | 8 (54) | meets the list, one over |
| signal and state opposite ways, report one way (4) | 9 (3) | fails R2 as stated |
| the same, report both ways (2) | 9 (6) | fails R2 as stated |
| signal and state both ways (3) | 5 (12; 96 with the report both ways) | meets the list, four over |

**Found.**
- Each of the 27 is counted once (6 + 6 + 6 + 4 + 2 + 3), the families are as described, and there are 7 outcomes.
- "Least under six, one over under twelve, short of R2 as stated under six, four over under three" holds.
- With R2 as two readers and two checkers by any nodes, the six opposite-ways readings give 9 (11 wirings, 38 with the report both ways); the candidate meets the list at `f` = 1, 2, 3 and is least.
- Two runs the author did not make give the same least numbers and the same verdicts on the candidate: all wirings at `f` = 2 and 3, and the work reading two at `f` = 1. So the sentence under the table of `part-a.md` section 4 ("This holds with the work reading all at `f` = 1, 2 and 3 and with the work reading two at `f` = 1") is true of the new rows for the least numbers, though the author ran them at `f` = 1 only.
- **A fair reading in none of the 27.** An arrow that carries fewer than three kinds. Under R2 and R5 as stated nothing can meet the list then, which the text says for observation only. Under R5's other choice, which the write-up itself offers, an observation-only arrow does meet it. I ran the nine at `f` = 1, the work reading all: 8 (24 wirings) with the candidate one over in six; 10 (3 wirings) with the candidate failing R2 in the two opposite-ways ones; 5 with both kinds both ways. The candidate is least in none. This does not contradict the verdict, which is scoped to arrows carrying all three kinds.
- Readings in which different arrows carry different things are in none of the 27 either. I did not compute any.

### R2's and R5's other choices

All recomputed and all as printed.
- R2 as stated: 78, 78, 69 of the 81 sets of 19; 52 with the work reading two.
- Two readers and two checkers by any nodes: 5,004, 5,004, 2,469 of 6,561; 3,336 with the work reading two.
- An observer a signal reader, in R2 and R3: 6,318, 2,340, 96 of 6,561. With R3 kept as "watches": 1,152, 576, 96.
- The lower bounds are sound: 19 is 8 + 8 + 3, and 15 is 8 + 3 + 4, a monitor nobody checks being a gap.
- R5 as "D watches each member": 8 connections under flow and under actor alike; 24 wirings in 4 shapes at `f` = 1 and 2, 18 in 3 at `f` = 3, 22 in 11 with the work reading two. The candidate meets the list and is one over. The example wiring of section 2.7 meets it at `f` = 1 and 2.
- Change 8: 22 wirings in 11 shapes under flow and 26 in 14 under actor with the work reading two; nothing meets the list there at `f` = 2.

### Condition 2, as restated

| Statement | What I computed |
|---|---|
| Three rings, no T, actor | G2 in 1 round at `f` = 1, 2, 3. Replay of "mutate D1": A1, B1, C1, A3, B3, C3, D3 flagged; W1, W3 halted; W2 working. D1 is the only coordinator that reports to D2 |
| Three rings, no T, flow | no gap at `f` = 1, 2, 3, every reachable state |
| both-whole | flow: no gap at 1, 2, 3. Actor: G2 in 1. With scopes, either reading: G1, G2, spill not violated; told of ring 1 in 2 rounds by the execution the text gives |
| top-with-D2, top-with-ring-2 | no gap at 1, 2, 3 under both readings; with scopes nothing violated |
| Order `whole`, flow | G2 in 1 round with ring 3 absent (ring 2 arrives with A2 bad; W1 works) |
| The goal's order, flow | D2 arrives bad: G1 and G2 in 1 round |

- **"Under actor it cannot be last in any order": holds, and it is a proof for every such order.** If T's join is a step of its own after everything else, the environment may take every other join and leave T's untaken. Rounds of joins alone raise no flag and end nothing. So the state "three rings, no T, nothing flagged" is reachable in every such order, and the checked execution follows from it. The claim is about the least rounds over all executions, so it needs no more than that.
- The same holds in the wider sense of "last". Under actor, any state with W2 or W3 present and T absent has the gap: mutate D1, or D2, and that work goes on.
- **Under flow the text gives a sufficient case, not the only one.** A second top-last order has no gap as one system at `f` = 1, 2, 3 in every reachable state: D2 and D3 in one step; then the six members one at a time in any order; then each W once its three members are present; then T. Both implementations agree at `f` = 1 and 2; `independent_model.py` alone at 3. The text does not say "only if", and its two exclusions hold, but the three sentences together read as a classification, which they are not.
- "With scopes, top-last leaves told violated" is checked for both-whole only. It is true of every top-last order by the same argument (argued, not run): bring all three rings in, mutate D2, which closes ring 2, then mutate A1; D1 reports to D2 only and D3 is not told.

### Lemma M-scope: fails as stated

**The step that does not follow.** "Which processes are alive, bad or present after a sequence of environment steps does not depend on those edges." With `freeze`, X7 makes `stop-boundary` and `fail-substrate` act only on processes that are not frozen. What is frozen depends on what has closed, which depends on the flags, which depend on the edges. So one step can have different effects in the two systems, and "every schedule the second can run, the first can run" fails.

**The system.** `f` = 1, `coupling` true, no window, gate in place, `freeze` true; no substrates, switches or late processes.

| | |
|---|---|
| Monitors | x, m1, m2, m3, m4, z, zp, z2, y |
| Work | w |
| Boundaries | m1, m2, m3, m4 share boundary b; every other monitor in its own |
| Scopes | p: x, m1. q: m2, m3, m4. r: y. o: z, zp, z2. ws: w. No `scope_work`, no `told` |
| Edges in both | z and zp read m1's signal; m2, m3, m4 check y's state; w takes its halt from m1 |
| Second only | z2 reads x's signal |

**Result.** G1 of scope r: 4 rounds in the first, 3 in the second. Both implementations agree. With a bound of 3 rounds the first gives `null`.

Second system:

| Round | Environment | End of round |
|---|---|---|
| 1 | stop x | z2 flagged for p; p has no work, so p closes; w working |
| 2 | stop-boundary b | m1 is frozen, so only m2, m3, m4 stop; nothing new flagged; w working |
| 3 | mutate y | y bad; its three checkers are stopped; nobody holds a flag for r: **G1 of r** |

First system, same steps:

| Round | Environment | End of round |
|---|---|---|
| 1 | stop x | nothing flagged; p open |
| 2 | stop-boundary b | m1, m2, m3, m4 stop; z and zp flagged for p; w halted on m1's silence; the model ends |

In the first, y must be mutated while m2, m3 and m4 are all inactive, or one of them flags and r closes at once. Stopping them one at a time takes three rounds. The one step that stops all three also stops m1 and ends the model, unless z and zp are stopped first, which takes two more rounds. So the least is 4 (stop m2; stop m3; stop m4; mutate y).

- With `freeze` false both systems give 4.
- With m1 to m4 on one substrate and own boundaries the same pair gives 4 and 3.

**Where it holds.** I went through the proof for systems in which no two monitors share a boundary and nothing has a substrate. Every step then has the same effect in both systems, and the induction (flags, halted and closed sets of the second contain the first's; a step enabled in the second is enabled in the first; responded in the first implies responded in the second) goes through for G1, G2, told and spill. With `freeze` false it goes through whatever the boundaries.

**Random pairs**, small systems (3 to 5 monitors, 1 or 2 work processes, 2 or 3 scopes, `f` 1 or 2, late groups, random lists and `scope_work`), bound of 5 rounds:

| Class | Pairs | Violated sooner with more edges |
|---|---|---|
| own boundaries, freeze | 1,900 | 0 |
| own boundaries, no freeze | 1,900 | 0 |
| shared boundaries, no freeze | 400 | 0 |
| shared boundaries, freeze | 400 | 0 (the failure needs the construction above) |
| own boundaries, freeze, added halt inputs | 400 | 35, spill among them |

**Other parts of the question.**
- Examples 1 and 4, built from X13, give spill `null` and spill 1, as the text says.
- The write-up uses the lemma only for signal-read, state-check and report edges (section 4.1's spare edges; section 5.3's 24 edges between N and the four), on systems it describes as having every monitor in a boundary of its own. I could not see the search code to confirm the systems.

### Theorem J on systems with late work processes

Holds. Theorem J's proof takes the first round with a fault and uses, of the processes then present: connectedness by mutual pairs, a present state checker and more than `f` present halt inputs for each present work process, and no slow edges. A late work process enters only through those. The same reading holds for "Theorem S in every set of present processes" at `f` = 1.

One omission in the correction's summary: "uses only the set of processes then present" leaves out Theorem J's third hypothesis, more than `f` initial monitors. It is met here (four initial monitors, `f` up to 3).

### "Every monitor in a boundary of its own" (section 4.3)

- **It is enough.** With it, no substrates and `f` up to 3, a round puts at most three faults on a ring's five processes, and the case analysis of statement 1 is complete. Statement 2 follows from 1; statement 3 needs no hypothesis.
- Bounded searches at thirteen monitors agree, under both readings: G1 of a base scope, G2 of every scope and spill are never violated at `f` = 1 with freeze (every state), `f` = 2 with freeze (3 rounds), `f` = 3 with freeze (2 rounds), `f` = 2 without (2 rounds), `f` = 1 without (4 rounds).
- The reason given is right. Replaying the last table of the section (ring boundaries, `f` = 2) gives G1 of ring 3 in round 3; ring 3's scope does not close in the round its first fault lands.
- **"Needed by statement 2 through it" is true of the proof, not shown of the statement.** With ring boundaries the work of a ring still halts in the first round a fault lands in that ring, on silence if the whole ring is stopped, so G2 of an upper scope seems to survive (argued). The section's own check finds G2 not violated there.
- It is now stated in the verdict (change 2) and in section 4.6 (change 17). Section 4.2 refers to "the hypotheses of section 4.3"; section 5.2 and the Bounds item of section 6 mention the statements without their conditions, on systems that meet them.
- In the same verdict bullet the first half ("no gap ... at every number of levels (**proved**)") also rests on own boundaries, which section 4.6 states and the bullet does not. That half was not corrected.

### The verdicts in the first lines

- `results-minimal.md`, on the candidate: says what section 2 gives, and no more.
- `results-minimal.md`, on the goal: the corrected parts ("What holds", Condition 2, "Always minimal") say what sections 4.3, 5.1 and 4.5 give. I recomputed the 33 connections (no gap at `f` = 1, 2, 3 under flow and actor; R2 over the whole system, R3, R5 hold) and one instance of the 26 under flow (the same).
- `part-a.md`: the bold lines and the bullets on actor, flow and kind by kind say what sections 2.6, 2.7 and 3.5 give.
- **The new last bullet (change 26) says more than the table.** "'One over' where a flag passes both ways along a connection" is true of six of the nine readings with the report both ways. Two of the other three are the opposite-ways readings (short of R2, which the bullet's third clause covers); the ninth, all three kinds both ways, is four over.

## Check 4. Nothing made wrong, nothing added without support

- No correction made a true statement false.
- **One added claim is not supported where it stands:** the class of Lemma M-scope.
- One added sentence is loose (change 12): "told is judged in the round of the ring's first fault and in no other". If that first fault is a stop with nothing bad, told is judged in no round, by the sentence before it. "In no other" is the true part.
- Change 20 holds against `results-join.md`. Section 4.2 there gives the "flag exists and goes nowhere" execution for a missing "N reports to X". Section 8's execution is a fault in the old ring (mutate M1) with the new ring's work going on. D2 on arrival has exactly the second half of the attachment under flow and neither half whole under actor.
- Change 34 holds, by `independent_model.py` alone, for one choice of each ring's 19 edges (the third member not watching the coordinator):
  - Flow: the 76 edges plus the three reports along the upper cycle have no gap at `f` = 1, 2, 3.
  - Actor: the full tower less any one of T's reports to a coordinator has G2 in 1 round.
  - With scopes, either reading: the 76 plus the third coordinator's watch of T have nothing violated at `f` = 1.
- Change 16: conditions (a) to (d) hold in all sixteen towers (1 to 4 levels, both readings, both wirings). The boundary clause of `theorem_S_wide` holds for 2, 3 and 4 levels and fails for one. As one system at `f` = 1 with ring boundaries, 13 and 40 monitors have no gap and a single ring has G1 in 2 rounds.
- Change 17: the forty-monitor execution, replayed with the scopes and lists as the text now gives them, violates told of ring 3 in round 3.

## Check 5. The ten tightened passages of `model-spec-scope.md`

None changes the model in the reading `independent_model.py` implements. Its default is the new text in every case, and my implementation, written from the new text, agrees with it.

| Change | New text against old | Could the other reading change a result? |
|---|---|---|
| 36 (X1) | Settles a real contradiction: J1 said an `after` entry naming a process in `works` is always satisfied; old X1 said one naming a late work process waits. The new text takes X1's side, which is the implemented default | Yes. With J1's sentence kept, 16 of the 36 added answers change (top-with-D2 under flow at `f` = 1 gets G1 in 9 rounds and G2 in 6 where the catalogue has none) |
| 37, 43, 44 (freeze) | Old X7 already froze "a process whose scope is in closed"; old X2's row ("nothing joins it") was looser. The new text is X7's rule said once more, and drops "left exactly as it was" | Yes in principle, none here. Freezing covered work too changes none of the 36. On a system of two monitors and two work processes that I built it moves G1 of a scope from 2 rounds to 3 |
| 38 (X2 edge cases) | A consequence for a scope no process is of; a statement that a non-scoped system carrying scope fields is outside the specification | No valid system is affected |
| 39 (told and `off`) | The literal old text | Only in a system with switches; none here |
| 40 (spill) | The literal old text: spill is defined once for the whole system | Only for work covered by no scope, or work joining a closed scope without freeze; none here |
| 41 (when the three are judged) | A consequence of X6 | No |
| 42 (X7) | A consequence of X6's "`closed` as it is at the start of the round" and of X5 | No |
| 45 (key order) | Format only | No |

**X1's four replacements and `model-spec-join.md`'s own results: untouched for a system with no late work process.** Each replacement differs from the printed sentence only where a name listed in `works` is a member of a group. The `members` row of J1 as printed does not allow that, so no system of `model-spec-join.md` has one. For such a system "the processes listed in `works` that are members of no group" is all of `works`, and "satisfied exactly when that process is present" gives the printed cases, the joiner included (J4's step table already says "present"). I found no other sentence of `model-spec-join.md` that a late work process contradicts.

## Check 6. Left behind

The author's two are out of date as stated. Others:

1. `part-a.md` section 6, "**Told has one author so far.**", and `results-minimal.md` section 6, "**Scopes, told and spill by two implementations of one author** ... not an independent opinion. The catalogue and the specification are there so that an independent one can be made." Out of date for the same reason as the two named.
2. `results-minimal.md` section 4.5: "under actor ... no ring of four has fewer than nine" and "Under actor with one coordinator nothing has fewer than 36". The verdict now says "under actor with R5 read as the report edge" (change 4); these do not. Section 2 now says eight are enough under actor with R5's other choice. Section 3 ("still least under actor") is the same case.
3. `results-minimal.md` section 6: "**Lemma M** carries the kind by kind searches." Sections 4.1 and 5.3 now rest their scoped halves on Lemma M-scope.
4. `results-minimal.md` section 4.2: "With `freeze`, nothing more lands in or joins a closed scope". This is the wording the specification's correction (changes 37, 43, 44) replaced. It is exact for the tower's ring scopes and loose for a scope that covers other scopes' work.
5. Both "Not settled" lists name the reading of an arrow as what the verdict turns on. The verdict now also turns on one choice each in R2 and R5; the lists do not say so.
6. `part-a.md` section 4, the sentence under the table: true of the new rows by my runs, but those rows were run by the author at `f` = 1 with the work reading all only.

The author's two unacted remarks on section 4.3 are both true by replay. At `f` = 4 every monitor of rings 2 and 3 and T holds ring 1's flag. In the ring-boundaries table the stopped monitors of ring 3 and T still hold flags in round 2.

## Each entry of `corrections-1.md`

| # | File | Verdict | Basis |
|---|---|---|---|
| 1 | results-minimal | holds | 27 readings, R2 and R5 figures recomputed |
| 2 | results-minimal | holds | hypothesis enough |
| 3 | results-minimal | holds | all orders recomputed; actor part proved for every top-last order; flow part sufficient, not the only case |
| 4 | results-minimal | holds | 33 and 26 recomputed |
| 5 | results-minimal | holds | 27 counted |
| 6 | results-minimal | holds | |
| 7 | results-minimal | holds | |
| 8 | results-minimal | holds | 22 in 11, 26 in 14 recomputed |
| 9 | results-minimal | holds | |
| 10 | results-minimal | holds | three tables recomputed; the catalogue's fifteen-edge example is not a meeting set |
| 11 | results-minimal | holds | for own-boundary systems, where Lemma M-scope is true |
| 12 | results-minimal | holds | "judged in the round of the first fault" is loose when that fault is a stop |
| 13 | results-minimal | **fails** | class too wide: freeze with a shared boundary or substrate; system and execution above |
| 14 | results-minimal | holds | sufficient; "needed by statement 2" is true of the proof only |
| 15 | results-minimal | holds | replayed; neither part of Theorem 0 applies |
| 16 | results-minimal | holds; one part could not check | (a) to (d) and the boundary clause recomputed; what `sufficient_f1` tests is not in the folder |
| 17 | results-minimal | holds; one part could not check | lists consistent with the replayed execution; `mr_tower.py` is not in the folder |
| 18 | results-minimal | holds | table, execution and four points recomputed |
| 19 | results-minimal | holds | proofs read; the summary omits "more than `f` initial monitors" |
| 20 | results-minimal | holds | against `results-join.md` 4.2 and 8 |
| 21 | results-minimal | holds | as 11 |
| 22 | results-minimal | could not check | the files named are outside the folder; the 36 systems are as said, bar the fifteen-edge one |
| 23 | part-a | holds | |
| 24 | part-a | holds | |
| 25 | part-a | holds | |
| 26 | part-a | holds in substance | says more than the table for three of the nine report-both-ways readings |
| 27 | part-a | holds | |
| 28 | part-a | holds | |
| 29 | part-a | holds | |
| 30 | part-a | holds | sections 2.6 and 2.7 recomputed |
| 31 | part-a | holds | |
| 32 | part-a | holds | section 3.5 and the table rows recomputed |
| 33 | part-a | holds | |
| 34 | part-a | holds | three sentences checked on the 76-edge tower |
| 35 | part-a | could not check | files outside the folder |
| 36 | model-spec-scope | holds | settles J1 against X1 as implemented; join results untouched without late work |
| 37 | model-spec-scope | holds | |
| 38 | model-spec-scope | holds | |
| 39 | model-spec-scope | holds | |
| 40 | model-spec-scope | holds | |
| 41 | model-spec-scope | holds | |
| 42 | model-spec-scope | holds | |
| 43 | model-spec-scope | holds | |
| 44 | model-spec-scope | holds | |
| 45 | model-spec-scope | holds | |

## What I could not check

- Anything that rests on files outside the folder: the two earlier hand-backs and who reported what first; `corrections_1.py` and its outputs; `mr_model.py`, `mr_tower.py`, `scope_naive.py`, `check_model.py` (what `sufficient_f1` tests, and that it was run); the catalogue of 465 and its answers, so also "the catalogue is unchanged", "38 answers turn on it", and that the catalogue's `example/1` and `example/4` are the systems of X13 (I built those from X13).
- That `model-spec.md` and `model-spec-join.md` are unchanged: there are no before copies.
- Whether the searches of sections 4.1 and 5.3 that cite Lemma M-scope were run only on systems with every monitor in a boundary of its own. The write-up describes them so.
- `added/grow/both-whole/actor/one/f3` by a second implementation.
- Lemma M-scope in the narrower class beyond reading the proof and 3,800 random pairs bounded at 5 rounds.
- The Lean statements: I read the statements; the files here carry no proofs.
- For the further readings: the 63 combinations and the kind by kind labels, which the author also did not redo. Readings in which different arrows carry different things.
- The complete searches behind unchanged statements: forty monitors with scopes, the first seven join orders with scopes, the kind by kind search of section 4.1 beyond the instances above.

My scripts and logs are in `«SCRATCH»\`, a temporary folder. The pair of systems that refutes Lemma M-scope as stated is `«SCRATCH»\mscope_cx.json`, in the specification's format.
