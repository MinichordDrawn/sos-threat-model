# Independent check of corrections-1: hand-back

## Result in brief

I found two things wrong, both in sentences the corrections added. Everything else I could compute or argue holds.

1. **A10 (section 6.2) fails on a count.** The new sentence says "three rows of the chain table below have a gap although every monitor always has a present state checker". It is two rows, not three: "N5 does not read N6's signal" and "N6 does not report to N5". The other two rows with a gap ("N5 does not check N6's state", "N6 does not check N7's state") are rows in which a monitor (N6, N7) has no state checker at all. The point the sentence makes (a missing checker is not the only way to a gap) stands on the two rows.

2. **A15 (section 10) fails as worded.** "In every round with a fault some live correct monitor detects a fault of that round" is true of the first round with a fault, which is all Theorem F's proof covers. It is false of a later round when the model has not ended, which is exactly the case the next sentence ("The detection must still reach the work") is about. System and execution are under A15 below.

Lesser points, none of them a failed statement:

- The 22 family systems in A1 cannot be derived from section 6.1, and the 12,240 only on an assumption about the mixture.
- The Theorem L row of the table "The theorems against the search" was not changed although the theorem's hypothesis was.
- The brief says the list names the system "KB with all 24 edges except the four reports to KB". My copy of `corrections-1.md` does not name it; A13 gives only the counts 11, 27, 35 against 12, 36, 68. I computed it anyway and it behaves as the brief says.
- B1's new sentence uses "work process", the term B2 replaces as ambiguous.

## How I worked

- I wrote my own implementation from `model-spec.md` and `model-spec-join.md`: `«WORK»\sos-join-model\verify-corrections\_check_work\mymodel.py`.
- I also used `independent_model.py`. I read all of it; a system is given as the JSON object of the specification, `Model(system).solve()` returns `(G1, G2, states, complete)`.
- The two agree on G1 and G2 for every system I put through both, more than 9,000, among them 6,000 random systems using every feature of both specification files (window, no gate, slow reports, switches, substrates, shared boundaries, groups, `after`, slow edges, `arrive_bad`). On about 1,600 further random systems I compared only gap or no gap, and they agree there too.
- All my scripts and their outputs are in `«WORK»\sos-join-model\verify-corrections\_check_work\`, a subfolder I created. I changed no other file and opened no other folder.
- Results are written "rounds to break G1 / rounds to break G2"; "null" means never.

## Check 1. The list is the whole of the change: holds

- I made both diffs. `results-join.md` has 18 changed hunks and `model-spec-join.md` has 6. They map one to one onto A1 to A18 and B1 to B6.
- For every entry, the "before" text occurs exactly once in the before-file, and the "after" text exactly once in the file as it is now. A16's passage is absent, as the list says.
- Applying the 24 entries as literal text to the two before-files reproduces the two current files byte for byte.
- Nothing is changed and not listed; nothing is listed and not changed.

## Check 2. Each corrected statement of the write-up

**A1 (verdict, the count): holds in part, could not check in part.**
- 62 + 12,240 + 22 = 12,324.
- The 62 I recomputed: way one gives 1, 3, 10, 48 systems of five to eight monitors up to renaming (base four among themselves, new ones among themselves). All 62 have no gap at `f` = 1, 2, 3 and a gap at 4, with ordered joins and a monitor allowed to arrive bad.
- 12,240 is the figure section 6.1 states. Counting from the description, the five shapes give 2,460 systems per base ring (mesh and signal-reading coordinator 4 + 40 + 300 each, the two cycle shapes 24 + 400 + 300 each, one watcher 4 + 20 + 300), so 9,840 for four base rings. The remaining 2,400 is 600 per base ring for the mixture. Read literally ("every system of five monitors, every one of six or a sample of 400"), the mixture would be 60 + 400 + 300 = 760 per base ring and the total 12,880. So 12,240 fits only if the mixture was run as 600 per base ring, for instance 150 at each size. This is my reconstruction and I cannot settle it from here.
- 22 is stated nowhere in section 6.1 and its description of the families (hub to 11, chain and fan to 20, mesh shape and cycle members) does not determine it. Could not check.

**A2 (verdict, ring with its own work): holds.**
- Two meshes, ring B joining in one step, a member allowed to arrive bad: one two-way link between KB and M1 (six edges) has no gap at `f` = 1, 2, 3 and 1/1 at 4.
- Same result for two cycles with checking coordinators, link on M1 or on K.
- Five edges with no such link (M1 checks KB and reads its signal, KB reports to M1, M2 and M3 report to KB) have no gap at `f` = 1 and 3/2 at `f` = 2.
- The sentence says the same as section 8 as corrected.
- Scope: "up to 3" is for rings whose own rate is 3. For two cycles with a coordinator that checks no state, the same link gives no gap at 1 and 2 and 1/1 at 3, which is those rings' own rate.

**A3 (verdict, the number attached): holds.** N in a mesh with `k` monitors, J joining with N, checked by N, halting on N and the `k`. Rate is 1, 2, 3, 3 for `k` = 1, 2, 3, 4, both arriving good and allowed to arrive bad. Same as the table of section 4.3.

**A4 (verdict, two observers): holds.**
- The argument is sound: with the work halting on every monitor, Theorem F's third condition holds through the detecting monitor itself.
- 1,500 random plain systems (three to six monitors, every monitor at least two watchers, every work process a state checker and a halt input from every monitor, no report edges, `f` = 2): none has a gap.
- The sentence says no more than Theorem F gives.

**A5 (section 1, independent comparison): could not check.** The catalogue, its answers and the comparison are not in this folder. Consistent with it: `independent_model.py` and my implementation agree everywhere I ran both.

**A6 (Theorem L, the statement): holds.**
- Proof read against the specification. With the two added conditions each step follows:
  - the only step that is neither a fault nor a join is `disable`, and no monitor has a switch;
  - the checker, reader and report edges of each late monitor are in force from its join round;
  - a monitor of lower rank than the lowest faulty one is alive, correct and not off.
- Boundaries and substrates of late monitors, which the statement leaves free, do not break it: one step still faults at most one process of B.
- 8,300 random systems of the class, on the four base rings at every `f` up to the base rate: one to four late monitors in groups, the three edges to B or lower rank with `after` making them present, any other edges including checks of and halt inputs to W, slow edges anywhere but the three, late monitors sharing boundaries with each other or with base monitors, substrates on late monitors, arriving good or bad. None has a gap.
- 3,000 more on the four base rings with "W reads two" at `f` = 1 (their rate). None has a gap.
- The same generator with the hypothesis broken finds gaps: a switch on one late monitor, 402 of 8,300; one of the three edges slow, 1,219 of 8,300; a state check slow, 3,452 of 8,300.
- I checked that each base ring meets the theorem's condition on B: every one-round outcome with a fault is a complete response at each `f` up to its rate.

**A7 (paragraph and table after the proof): holds.**
- The system as described (mesh of four, W reading all; N5 watched by M1 and reporting to it; N6 watched by N5 and reporting to it, `after` N5; N5 in `switches`; arriving good; `f` = 1) gives 4/4 in both implementations. The least for both goals is 4 rounds.
- The table replays as a real execution: after round 3 N5 is off, nothing bad, nothing flagged; in round 4 N6 is bad, nothing flagged, W takes a work step; G1 and G2 are both violated in round 4.
- Same system at `f` = 2, 3: 2/2, 2/2. Allowed to arrive bad: 3/3, 2/2, 1/1. Without the switch: no gap at 1, 2, 3 either way.
- "The executions are those of section 5": recomputed that row (N in a mesh with M1, M2, M3, the three checks of N slow): no gap, 1/1, 1/1 arriving good; 1/1, 1/1, 1/1 allowed to arrive bad. As section 5 has it.
- Each of the three edges matters. On the chain N5 on M1, N6 on N5: N5's check of N6 slow gives 2/2 at `f` = 1 when a monitor may arrive bad; M1's read of N5 slow gives 1/1 at `f` = 3 when a monitor may arrive bad; N5's report to M1 slow gives G2 in 1 at `f` = 2 (may arrive bad) and at `f` = 3 (arriving good).
- "No system of sections 4 and 6 to 10 has a slow edge or a switch" agrees with the text of those sections. Against the catalogue: could not check.

**A8 (section 4.3, first paragraph): holds.**
- N with J as in section 4.2: all 64 three-edge attachments (a check of N, a read of N, a report from N) have no gap at `f` = 1 and 2, and all 64 have a gap at `f` = 3.
- All 256 four-edge attachments of section 4.2 have no gap at `f` = 3.
- None of the 276 two-edge attachments has no gap at `f` = 1.
- The chain of section 6.2 as built has no gap at `f` = 1, 2, 3, and each of N6's three edges, removed, gives a gap.

**A9 (P8b's class): holds.** `results-original.md` section 6 says "proved in general: in a system with no substrates or switches".

**A10 (section 6.2, order of joining): fails on the count; the rest holds.**
- Chain table recomputed, a monitor allowed to arrive bad, `f` = 1, 2, 3. It matches the write-up row for row:

| The chain | Result | A monitor with no state checker |
|---|---|---|
| as built | no gap, no gap, no gap | none |
| N5 does not check N6's state | 2/2, 1/1, 1/1 | N6 |
| N5 does not read N6's signal | 4/4, 2/2, 2/2 | none |
| N6 does not report to N5 | G2 in 3, 2, 1; G1 holds | none |
| N6 does not check N7's state | 3/3, 2/2, 1/1 | N7 |
| N6 does not read N7's signal | no gap | none |
| N7 does not report to N6 | no gap | none |

- Two rows, not three, have a gap with every monitor checked.
- The other two sentences hold. With joins in any order and a monitor allowed to arrive bad, 61 of the 62 systems have no gap at `f` = 1, 2, 3. One has a gap at `f` = 1, and it is the one system in which some monitor's three are all late.

**A11 (under the five-round chain table): holds.**
- "N5 does not read N6's signal", `f` = 1, arriving good: 5/5, and the table replays as written.
- Allowed to arrive bad: 4/4, by join N5; join N6; stop N6; N7 joins already bad.
- The 4/4 depends on `after` being satisfied by a monitor that is present and stopped, which is what J2 says. If `after` needed the monitor alive it would be 5/5.

**A12 (section 8, fewest edges): holds.** See A13: the least attachments are 384 of five edges and 256 of six at `f` = 1, 512 of six at `f` = 2, 256 of six and 64 of seven at `f` = 3. With M1 watching KB and KB reporting to M1, none of the 21 possible fourth edges gives no gap at `f` = 1.

**A13 (section 8, completeness at `f` = 3 and the table): holds.** All for the two meshes joining in one step.
- The list gives 640 (384, 256, 0), 512 (0, 512, 0) and 320 (0, 256, 64) attachments at `f` = 1, 2, 3. No one contains another.
- Every one of the 1,472 has no gap at its `f` with a member allowed to arrive bad. Removing any single edge from any of them gives a gap.
- The greatest sets holding none, computed from the list as complements of its minimal hitting sets with no use of the write-up's cases: 12, 36 and 68, each of 20 edges, each checked greatest.
- They are exactly the family the four cases describe: three sets from the first three cases, plus, for each set T of at most `f` monitors of A reporting to KB and each choice of "KB does not check" or "KB does not read" per member of T, one set. That is 3 + the sum over t ≤ `f` of C(4,t)·2^t = 12, 36, 68. So the division into cases is exact and every set holding no listed attachment lies inside one of them.
- Every one of the 116 greatest sets has a gap at its `f`, even with every member arriving good.
- 450 random sets of edges (150 per rate, weighted toward the boundary) against the rule "no gap exactly when it holds a listed attachment": none disagrees.
- The 20-edge set (every edge except the four reports from A to KB): G1 null, G2 in 2 at `f` = 1, by ring B joining and then mutate W. Ring A flags and W halts, nothing tells ring B, WB works. Adding any one of the four reports gives no gap at `f` = 1, 2, 3.
- It lies inside none of the sets of the smaller family that takes exactly `f` reporters, which has 11, 27, 35 sets. That accounts for the difference the list describes.
- Could not check: that the count is "the reader's", and `recheck_corrections.py`.

**A14 (under the slow-reports table): holds.**
- The mesh grown to eight (N5 on M1, M2, M3; N6 on N5, M1, M2; N7 on N5, N6, M1; N8 on N5, N6, N7), slow reports, `f` = 1: arriving good G1 null and G2 5, the table replaying as written; allowed to arrive bad G2 4, N8 arriving bad in round 4.
- Over the 62 systems: 61 have no gap, and the one with a gap is the one where some monitor has no base monitor among its three.

**A15 (section 10, what two observers give): fails as worded for rounds after the first; holds for the first round with a fault.**
- System: plain, nothing joining, `f` = 2. Five monitors M1 to M5, each in its own boundary. Each is watched (state checked and signal read) by the next two: M1 by M2 and M3, M2 by M3 and M4, M3 by M4 and M5, M4 by M5 and M1, M5 by M1 and M2. No report edges. W is checked by M1 and takes its halt from M1. `coupling` true, `window` 0.
- Every monitor has two watchers and the work process has a state checker.

| Round | Environment | End of round |
|---|---|---|
| 1 | stop M2, stop M3 | nothing bad; M4 flagged (silence of M2 and M3), M5 flagged (silence of M3); W working |
| 2 | mutate M1 | M1 bad; no live correct monitor detects it, since its two watchers M2 and M3 are stopped; M4 and M5 flagged as before, on round 1's faults; W working |

- Round 2 is a round with a fault in which no live correct monitor detects a fault of that round. It also breaks G2.
- In the first round with a fault the statement holds: over 600 random plain systems with two watchers each and a checker for each work process, all 37,077 one-round outcomes at `f` = 2 have a detection of a fault of that round.
- The sentence about a work process and its only checker going bad together is right: on this system, mutate W and mutate M1 gives M2 and M3 flagged on M1, and nothing sees W.
- The verdict sentence (A4) does not carry the overreach.

**A16 (section 12, item removed): holds,** given A13.

**A17 (section 12, new item): could not check.** It rests on what the catalogue uses. It is consistent with A7, whose system has a switch and is outside the catalogue.

**A18 (files table): holds as a listing.** Could not check that the three files exist.

## Check 3. Nothing made wrong that was right, nothing added without support

- No correction turned a right statement into a wrong one.
- Two added statements are not supported as they stand: the "three rows" of A10 and the "every round" of A15.
- One consequence the list does not mention: the table "The theorems against the search" in section 3 has a row of counts for "Theorem L's conditions" (29,506 / 0 / 4,019 / 25,561) over systems that include those of section 5, which have slow edges. The theorem's hypothesis changed and the row did not. The 0 can only stand if the test already excluded slow edges in some way. Whether the other counts are for the hypothesis as now worded I cannot tell. Could not check.
- Section 6.1's proof ("so Theorem L applies") now also needs no slow edges and no switches. The sentence added in A7 supplies that.

## Check 4. The six tightened sentences of the specification

None changes the model. On each point `independent_model.py`, written from the old words, does what the new words say.

**B1 (`after`): holds.**
- A consequence of J2 and the `join g` row: initial monitors and the processes in `works` are always present, and a member of a group is not present until the group joins.
- "Work process" there must be read as "listed in `works`". For the joiner the sentence would be false, and "work process" is the term B2 replaces for that ambiguity.
- The sentence does not cover a late monitor named in `after` that has joined and been stopped. J2 already makes it satisfied, and that reading matters to a result (A11: 4/4 against 5/5).

**B2 (initial `alive`): holds.**
- No rule reads `alive` for a process that is not a monitor (`stop`, `stop-boundary`, `fail-substrate`, `active`, detection, `out`, the silence clause and the responded test all read it for monitors only). Neither reading of the old sentence can change a result.
- "Not listed in `works`" is not said outright in `model-spec.md`, though its section 1 implies it. `independent_model.py` refuses a system whose names are not distinct, so no answer can differ.

**B3 (`mutate` row): holds.**
- The old row's condition was complete as written, and J2's "present" does not involve `alive`.
- The other reading would change results: a system of four monitors gives 3/3 as specified (stop m, stop c, mutate m) and no gap if a stopped monitor could not be mutated. The system is in `«WORK»\sos-join-model\verify-corrections\_check_work\t11_mut.py`.
- `independent_model.py` gives 3/3.

**B4 (slow edges): holds.**
- The new sentences follow from conditions 1 and 2, which are unchanged and are the definition.
- The old summary could be read as "missing only in the round its first end joined". That would change results, for instance a slow check of N6 by N5 with N6 arriving bad a round after N5: 2/2 by the conditions, no gap on that reading.
- `independent_model.py` implements the two conditions.

**B5 (joiner's halt inputs): holds.**
- Section 3.3 and J6 already read `halt_inputs[w]` for every present non-monitor process, and J1 defines an edge for any key.
- Not reading the joiner's entry would change results: N with J at `f` = 1 gives no gap as specified and 6/2 otherwise.

**B6 (N's boundary in J8): holds.** It concerns the examples only. All eight example results come out as J8 states them whether N is in a boundary of its own, in none, or in M1's.

## What I could not check

- A5 and A17: the catalogue, its answers, the comparison on 5,658 cases, and what the catalogue does and does not use.
- A1: the 22 family systems; the 12,240 beyond the reconstruction above. I did not rebuild the families or way two.
- A7: "no system of sections 4 and 6 to 10 has a slow edge or a switch", beyond the text of those sections.
- A13: the attribution to the earlier reader and the author's `recheck_corrections.py` and its output. The numbers themselves I recomputed.
- A18: that the listed files exist.
- The Theorem L row of the table "The theorems against the search".
- The opening claims of `corrections-1.md`: seven findings all found right; checker, catalogue and answers unchanged; "both programs already behaved as the new words say" for the author's two programs.
- Lemma M's proof, which A13 leans on, I used and did not re-derive. The 450 random sets agree with what it implies.
