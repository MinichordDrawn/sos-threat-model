# Independent check of `results-join.md`: hand-back

## Result in brief

**Yes, some statements are false as written.** No proof has a wrong step for the class its argument actually uses. Every counterexample table is a real execution with the result claimed. Every Checked table I recomputed came out as printed.

The statements that do not hold as written:

1. **Theorem L (section 3)** holds only with a hypothesis it does not state. It says the late monitors are added "with any edges". If the state check (or the signal read, or the report) it relies on is listed in `slow_edges`, or if a late monitor that another leans on has an off switch, the conclusion fails. The write-up's own section 5 table is a counterexample to the theorem as worded.
2. **Section 8, "So the least is six edges"** is false at `f` = 1. By the write-up's own list of least attachments, five edges are enough at `f` = 1, and I confirmed it. The verdict's "A ring that brings its own work needs one two-way link with one monitor of the ring it joins" is therefore sufficient but not required.
3. **Verdict, "Three" bullet**: "has no gap up to `f` = the number of monitors the new one is attached to" fails for four attached monitors. The rate is 3, as the section 4.3 table itself says.
4. **Section 6.2**: "In general a gap follows exactly when some monitor can be present with no present state checker (proved, section 3)". The "only when" half is not general. Three rows of the chain table in the same subsection have a gap although every monitor always has a present checker.
5. **Section 10**: "some live correct monitor detects every fault" (cited as Theorem F) is false for a work-process fault whose only checker is faulted in the same round. It also needs Theorem F's hypothesis that every work process has a state checker, which the sentence omits.
6. **Section 4.3, first paragraph**: "four edges at `f` = 3" is given for a monitor that "a work process or a later monitor depends on". For a monitor that only a later monitor depends on, three edges are enough at `f` = 3 (section 6.2 chain, "as built"). The verdict words this correctly.
7. **Misquote, harmless here**: section 4.3 says P8b "is proved there for every system". `results-original.md` proves it "in a system with no substrates or switches".

## How I checked

I wrote my own decider from `model-spec.md` and `model-spec-join.md` only. It reproduces:

- all eight results of the J8 examples in `model-spec-join.md`;
- R of `results-original.md`: 23 reachable states and no gap at `f` = 1, G1 in 2 and G2 in 1 at `f` = 2;
- the ten removals of its section 6 and the four reflex results of its section 8.1.

Random systems below were not de-duplicated. "Tried" means systems that met the statement's hypotheses and were explored in full.

## Statements marked Proved

| Statement | Verdict | Systems tried | Counterexamples |
|---|---|---|---|
| Lemma M | holds | 2,659 pairs | 0 |
| Lemma N | holds | 2,326 pairs | 0 |
| Theorem L | holds only with an unstated hypothesis | 47,261 with the hypothesis added | 0 |
| Theorem J | holds | 76,303 | 0 |
| Theorem F | holds | 217,756 | 0 |
| Theorem S in every set of present processes (`f` = 1) | holds | 221,900 | 0 |
| A monitor nobody checks | holds | 853,800 | 0 |
| 4.1 completeness over 2^24 attachments | holds | see below | 0 |
| 4.2 least attachments | holds | see below | 0 |
| 4.3 "proved in one direction", and the per-fault reading | holds | proof read; table recomputed | 0 |
| 6.1 growth result | holds, resting on Theorem L | 62 + 1,608 + 28 | 0 |
| 6.3 "no gap exactly when `f` is less than both" | holds | 28 | 0 |
| 7 (1) "proved in one direction by P8b and P3" | holds | table recomputed | 0 |
| 7 (2) mesh shape by Theorem J, and section 8 "first three proved by Theorem J" | holds | recomputed | 0 |
| 9 rings of at most four, count is monitors less three | holds | 62,192 labelled systems | 0 |
| 9 slow reports at `f` = 1 | holds | 1,128,663 | 0 |
| 10 "Not necessary" (Theorem L) | holds | recomputed | 0 |
| 10 "What two observers do give" (Theorem F) | theorem holds; one sentence overstated | see item 5 | 1 |

Detail for each:

- **Lemma M: holds.** Every step follows. Enabledness and `alive`/`bad`/`hidden`/`off`/present do not depend on edges, and flagged and halted are monotone in the edges in force. This includes no-gate and slow-reports systems. Pairs were 2 to 4 initial monitors, 0 to 2 late, 1 or 2 work processes with or without a joiner, `f` 1 or 2, with shared boundaries, substrates, switches, slow edges, no gate, slow reports and `arrive_bad` switched on at random.
- **Lemma N: holds**, including with a window.
- **Theorem L: holds only with a hypothesis that is not stated.** The grown system must be plain with joins in the write-up's own sense, in two respects:
  - the state check, signal read and report that the ranking relies on are not in `slow_edges`;
  - no late monitor has an off switch.

  With those added, every proof step follows. Systems had 2 to 4 base monitors, 1 to 3 late monitors, `f` 1 to 3, and both ways of arriving. What I found about each possible extra condition:

  | Variation | Tried | With a gap |
  |---|---|---|
  | one of the three relied-on edges slow | 48,270 | 7,787 |
  | one late monitor with an off switch | 28,856 | 1,402 |
  | other edges slow | 41,952 | 0 |
  | a late monitor sharing a boundary | 40,350 | 0 |
  | late monitors on a substrate | 44,713 | 0 |

  So distinct boundaries and absence of substrates are not needed for late monitors; the two conditions above are.

  Counterexample (a). B is the mesh of four with W checked by and halting on all four; it meets both hypotheses at `f` = 1. N is late, `arrive_bad` is true. M1 checks N's state (this edge is in `slow_edges`), M1 reads N's signal, N reports to M1.

  | Round | Environment | End of round |
  |---|---|---|
  | 1 | join-bad N | N bad; nothing flagged; W working |

  Breaks G1 and G2 at `f` = 1. With N arriving good and `f` = 2:

  | Round | Environment | End of round |
  |---|---|---|
  | 1 | join N, mutate N | N bad; nothing flagged; W working |

  Breaks G1 and G2. These are the write-up's own section 5 executions.

  Counterexample (b). Same B, `f` = 1, monitors arrive good. N5 has one watcher M1 and reports to M1. N6 has one watcher N5, reports to N5, and joins after N5. N5 has an off switch.

  | Round | Environment | End of round |
  |---|---|---|
  | 1 | join N5 | nothing flagged; W working |
  | 2 | join N6 | nothing flagged; W working |
  | 3 | disable N5 | nothing bad; nothing flagged; W working |
  | 4 | mutate N6 | N6 bad; nothing flagged; W working |

  Breaks G1 and G2.

  Nothing downstream is affected: the five shapes of section 2 have no slow edges and no switches.
- **Theorem J: holds.** Systems had 2 to 4 initial monitors, up to 3 late, a joiner alone, in a group or absent, `f` 1 to 3, and both ways of arriving.
- **Theorem F: holds.** 3 to 5 monitors, `f` 1 to 3.
- **4.1: holds.** On each of the four base rings, with W reading all or two, both ways of arriving, `f` = 1, 2, 3: each of the four single checks of N has no gap wherever the base has none, and the 20-edge attachment without them has a gap. 1,200 random attachment/rate cases agreed with the rule.
- **4.2: holds.** On the mesh, both ways of arriving:
  - `f` = 1 and 2: all 64 three-edge sets have no gap, and the three 20-edge sets missing one kind have a gap.
  - `f` = 3: all 256 four-edge sets have no gap, and the four maximal sets containing none of them have a gap.

  That makes the lists complete.
- **6.1: holds.** I confirmed the checked premise: on all eight base systems, at every `f` up to the rate, every non-empty first round ends in a complete response. I then recomputed:
  - all 62 way-one systems (1, 3, 10, 48 up to renaming, as stated): rate 3;
  - 1,608 way-two systems of five to eight monitors, across all four base rings and all five shapes and mixtures: each has exactly its base ring's rate;
  - hub, chain and fan at 8 to 20 monitors (28 systems): no gap to 3, gap at 4.
- **6.3: holds.** All 14 way-one systems of 5, 6, 7 monitors, both wirings of W: rates 3, 3, 3 and 4, 5, 6.
- **9, slow reports: holds.** Every one of the random plain systems failing the stated necessary condition has a gap.

## The verdict's sentences and conditions

- **Opening sentence: follows.**
- **"What holds": follows**, with the evidence kinds given. "At every size" rests on Theorem L, which is for the class, so it is not an over-reach. It should be read with Theorem L's missing hypothesis, which is the verdict's own condition (1). I could not reconcile the count 12,324: 62 + 12,240 = 12,302, and the remaining 22 cannot be derived from the description of the families.
- **Condition (1): follows.** Section 5 tables all recomputed and agree.
- **Condition (2): follows** (proved, and recomputed).
- **Condition (3): follows.** "Without (2) or (3) there is a gap at `f` = 1" is true when (3) is read at `f` = 1. A work process with two present halt inputs fails (3) only at `f` = 2 and has its gap there.
- **Condition (4): follows** (proved statement of section 9, plus the 62 systems).
- **"Three" bullet:**
  - One edge for a monitor nothing depends on: follows.
  - Three edges, and a fourth at `f` = 3 when work takes its halt from it: follows.
  - "A ring that brings its own work needs one two-way link": sufficient (Theorem J) but **not required**. Ring A and ring B are meshes, joining in one step. KB's only edges with ring A are: M1 checks KB, M1 reads KB's signal, KB reports to M1, M1 reports to KB, M2 reports to KB. That is five edges, and KB watches nothing in A. It has no gap at `f` = 1 under either way of arriving. Three reports to KB in place of the watch also give no gap at `f` = 2, and four at `f` = 3.
  - "No gap up to `f` = the number of monitors the new one is attached to": **fails at four**. N in a mesh with all four, J halting on N and the four, `f` = 4:

    | Round | Environment | End of round |
    |---|---|---|
    | 1 | mutate M1, mutate M2, mutate M3, mutate K | all four bad; nothing flagged; W working |

    Breaks G1 and G2. True for 1, 2, 3.
- **"Two observers" bullet: follows.** "They are enough with no reports at all (Theorem F)" also needs every work process to have a state checker, which the sentence leaves out.

On section 10's "detects every fault": mesh of three, no reports, W checked by M1 only and halting on all three, `f` = 2.

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate W, mutate M1 | W and M1 bad; M2, M3 flagged (for M1); W halted |

Neither judgement is broken, but no live correct monitor detects W's fault.

## Counterexample tables in the write-up

All are real executions. Each step is enabled where taken, the step count is within `f`, no round starts from a responded state, and the goal is violated in the round stated. I stepped through each by hand and replayed each in my decider.

- Section 2 (`f` = 3)
- 4.1
- 4.2 (three tables)
- 4.3
- 5 (two)
- 6.1, including the `f` = 3 remark
- 6.2 (two)
- 7 (two)
- 8 (three)
- 9
- 10 (three)

Two are real but not the shortest under the setting their section states (a new monitor may arrive bad):

- the five-round chain table of 6.2: the result is 4/4, by join-bad N7 in round 4;
- the five-round table of 9: G2 breaks in 4.

Neither table claims to be shortest.

## Checked results recomputed

All agree with the write-up.

- **Section 2:** rates, fewest checkers/readers/watchers, and Theorem S's conditions on all eight.
- **Section 4:** both tables of 4.1; the 18-edge removal results; the whole 4.2 table on three base rings; the 4.3 table.
- **Section 5:** both tables. The least prompt sets (9, 27, 27 sets) each have no gap, and every maximal set without one has a gap.
- **Section 6:** the 6.2 "any order" result (61 keep rate 3; one has a gap at `f` = 1, the one with N8 on N5, N6, N7); the 6.2 chain table; 6.3.
- **Section 7:** both tables (32 systems for the second).
- **Section 8:** the six-row table, on both meshes and both checking cycles with each placement of KB; the whole-ring-lost results.
- **Section 8, least attachments:** the list is exact and complete over all 24 edges at `f` = 1, 2 and 3 for two meshes joining in one step.

  | `f` | Listed sets, all with no gap | Maximal sets without one, all with a gap | Edges in the least sets |
  |---|---|---|---|
  | 1 | 640 | 11 | 384 of five, 256 of six |
  | 2 | 512 | 27 | all six |
  | 3 | 320 | 35 | 256 of six, 64 of seven |

  This also settles the write-up's open item for `f` = 3 over 24 edges.
- **Section 9:** every figure in the counted table; the 62 slow-report systems (61 no gap, one gap); no gap with W halting on all eight.
- **Section 10:** all six rows, and the ring of three (no gap at `f` = 1, 2).

## What I could not check

- **Counts of systems and anything about the author's programs.** This covers 12,324; 12,240; 5,658; about 156,000; 59,086 and the section 3 table of theorems against the search; 201/623; 2,399/2,719/602; the agreement of the two implementations; and the "existing results are unchanged" comparison. The scripts, catalogues and outputs are not in this folder.
- **The restart game results in section 4.3.** The game is not defined in the two specification files. The stated outcomes are what the reachability theorem of `results-original.md` section 10.3 predicts.
- **The items section 4.3 carries over from `results.md`** (naming the faulty monitor, the cascade).
- **Least attachments on the cycle shapes** (4.2 and 8). I did the meshes only.
- **Way two beyond my 1,608 systems**, and families between the sizes I ran.
- **The Proved statements for all sizes by search.** That rests on reading the proofs. My searches cover up to six monitors for the section 3 statements and up to twenty for growth.

## Files

My decider, scripts and outputs are in `«WORK»\sos-join-model\verify-proofs\own-check\`. I opened nothing outside `verify-proofs\`.
