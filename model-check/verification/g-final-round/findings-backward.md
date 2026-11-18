# Findings, backward pass

*Saved by the main session from the verifier's hand-back, word for word. The verifier could
not write this file itself.*

**Versions examined.** `formal-results.md` 75,839 bytes, 1,330 lines, md5 `8420937c5e4d912252b55ee0de677d38` (modified 00:52:10). `README.md` 10,236 bytes, md5 `dbfd7fd596696ab41d52c864f99669ff`.

**`formal-results.md` was changed by someone else while this pass ran.** The copy I first read was 75,727 bytes and 1,328 lines. I read the whole current version again. Three places differ: the opening of section 7 and its column heading, the coordinator paragraph of section 10.2, and one sentence of section 13 ("B's label for each removal"). Every quotation below was checked by script to be in the current files word for word (`c09_quotes.py`). Line numbers are those of the current version.

**What was recomputed.**
- The unchanged script run in full, twice (plain and `--traces`). Output is identical to `run-output.txt` but for the two file names on its last lines. The JSON is byte for byte identical to `results.json`. 326 s and 321 s; peak 1,843 MB.
- Every execution table of sections 2.7, 4, 5, 6, 8.1 and 10.1, replayed round by round.
- The Theorem S tally with my own reading of (a) to (d): 72 = 31 + 0 + 14 + 27.
- The author's census: every number of the first table in 12.1.
- My own decider (400 random systems against `explore`, 0 disagreements): the rows for 2 and 1, 2 and 2, 3 and 1 of the second table in 12.1, to the last digit, and 515,030. The 2 and 2 row also one by one with the checker.
- The module of section 9 as its own state machine written from `Heartbeat.tla`: 8 states with `HB = TRUE`, invariant and `TypeOK` hold; the seven-state trace with `HB = FALSE`.
- Pass A's code on the two cases it has no result file for; pass A's `--variants`; pass B's `scratch_universal.py`; pass F's result files against its report.
- Each statement marked Proved, tested on some thousands of random systems for a counterexample (none found); the proofs in the D, E and F reports read.
- `observers/SPEC.md` at the cited lines, and `observer_gate.php`.

Verdicts: NARROWED (true only in a narrower form), WRONG, NOT CHECKABLE. "(minor)" marks an entry that changes no result.

---

## Files

### B1. NARROWED (minor)
- **Where:** `formal-results.md`, Files, line 1330. Also `README.md`, Running it, line 163.
- **Claim:** "Add `--traces` to print every violating execution." / "python -I check_model.py --traces   also print every violating execution"
- **Evidence:** A full run with `--traces` prints 48 blocks: the shortest execution for each judgement broken in the systems listed in the tables, plus the ten executions of section 6. It prints none for the 55 one-edge removals, where 43 judgement violations exist (`report(..., False, quiet=True)`). A system has many violating executions; the script keeps the shortest.
- **Corrected wording:** "Add `--traces` to print, for each system in the tables, the shortest execution that breaks each judgement." / "python -I check_model.py --traces   also print the shortest violating execution for each listed system"

## Section 13

### B2. NARROWED
- **Where:** `formal-results.md` 13, line 1273. Also `README.md`, The method, item 6, line 44.
- **Claim:** "Every phase was checked by an agent started fresh for the purpose." / "Every phase was checked by an agent started fresh for the purpose and given only the artefacts"
- **Evidence:** Section 13 itself lists what no pass covered: the restart result of 10.3 (Theorem R, on which the coordinator rests), the second face of P2, the unread signal at two tiers, the TLA+ module under TLC, and the comparison of 10.5. Pass B's copy of the checker has no `restart_game`. Pass A's files have no result for the two `mesh3-unread-M3` cases. The README lists Theorem R under "Proved" with no such caveat.
- **Corrected wording:** "Every phase but those listed at the end of this section was checked by an agent started fresh for the purpose." / "Every phase but the late additions (the restart result, the second face of P2, the unread signal at two tiers) was checked by an agent started fresh for the purpose and given only the artefacts"

### B3. NOT CHECKABLE
- **Where:** `formal-results.md` 13, lines 1273 to 1275. Also `README.md`, The method, item 6, line 46.
- **Claim:** "Each was given only the artefacts to check, in a folder of its own, and never the author's reasoning, expected results or proofs." / "None was given the author's reasoning or expected results."
- **Evidence:** What an agent was not given leaves no artefact. The folders are consistent with it: A has the cases without results, D and E bare claims, F a task that ends "Nobody has told you what the outcome should be". B's input was the checker itself, which carries the author's comments and the list of executions "written out in the write-up".

### B4. NOT CHECKABLE
- **Where:** `formal-results.md` 13, table, row A, line 1283.
- **Claim:** "ten ambiguities in the wording, none of which changed a result"
- **Evidence:** Pass A's folder holds no report. `impl_a.py` codes seven alternative readings (eight variants). Its own `--variants`, rerun: seven variants change none of the 101 cases. The eighth, which the file says the text excludes, changes `reflex-relayed-slow/f1` from (none, 1) to (none, none). "Ten" cannot be counted from anything in the folder.

### B5. NOT CHECKABLE
- **Where:** `formal-results.md` 13, line 1291.
- **Claim:** "*From A.* The specification's wording was tightened in ten places."
- **Evidence:** A diff of pass A's copy of the specification against `model-spec.md` shows eight sentences added or reworded, besides the two new fields and section 3.6, which fold in A's addendum. Which ten places are meant is not recorded.

### B6. NOT CHECKABLE
- **Where:** `formal-results.md` 13, table, row A, line 1283.
- **Claim:** "(the last two were computed afterwards with its code unchanged)"
- **Evidence:** Pass A's result files hold 94 + 7 = 101 cases, all equal to `results.json`. They hold nothing for `mesh3-unread-M3/f1` and `/f2`. I ran `impl_a.py`'s `explore` on those two: (none, none) and (2, none), equal to `results.json`. So "identical on all 103 cases" is confirmed by rerun. That it was done before, and that the code is as A left it, has no artefact.

### B7. NOT CHECKABLE
- **Where:** `formal-results.md` 13, lines 1298 to 1299, and 8.2, lines 705 to 706.
- **Claim:** "and were checked by computation before being adopted." / "and were checked here by computation for every `n` up to 3,000 and for powers of two beyond."
- **Evidence:** No script or output in the folder runs the bounds over a range; `check_model.py` prints the growth table for two sizes only. My own run of `growth` for every `n` from 1 to 3,000, and powers of two to 2^40, confirms the three bounds with the exceptions in B31.

### B8. NOT CHECKABLE
- **Where:** `formal-results.md` 13, lines 1313 to 1314.
- **Claim:** "The comparison with the implementation in section 10.5 began as a survey by two agents. Every line it quotes from the specification was then read directly."
- **Evidence:** A statement of history with no artefact. One of the three quotations is not word for word (B22).

### B9. NARROWED (minor)
- **Where:** `formal-results.md` 13, line 1294, and 7, line 598.
- **Claim:** "The verdict table now carries B's label for each removal." / "Each removal carries two labels."
- **Evidence:** The table has ten rows. B labelled nine. The tenth, the gate, reads "not reviewed (added later)".
- **Corrected wording:** "The verdict table now carries B's label for each of the nine removals it reviewed." / "Each removal but the gate carries two labels."

## Section 12

### B10. NOT CHECKABLE
- **Where:** `formal-results.md` 12.4, lines 1266 to 1268.
- **Claim:** "An attempt was made with three agents given only the four constraints, but each could see this workspace's own one-line description of the ring, so they were not independent, and their derivations are set aside."
- **Evidence:** Nothing of that attempt is in the folder. (That an agent started in this workspace sees a one-line description of the framework is so: this pass sees one.)

### B11. NOT CHECKABLE (possible inconsistency inside the write-up)
- **Where:** `formal-results.md` 12.3, table, lines 1243 to 1244; against 2.6, line 202, and 2.1, line 128.
- **Claim:** "| the gate: monitors check before work steps | emergent, from the second constraint: no impact before detection |"
- **Evidence:** Sections 2.1 and 2.6 give the second scope condition as "C2, a false flag is cheap". Sections 10.2, 10.3 and 12.1 use "the fourth constraint" and "scope condition C4" for the same thing (recovery without an outside hand), which reads as one list. If it is one list, "the second constraint: no impact before detection" does not match C2. The framework's own text is outside what this pass may open, so which is right cannot be decided here. The write-up never lists "the four constraints".

### B12. NARROWED
- **Where:** `formal-results.md` 12.1, lines 1209 to 1210.
- **Claim:** "**Result:** not met. No system was found that meets all four constraints, has no gap, and lacks the properties."
- **Evidence:** Pass F's verdict on the claim it was given is "The claim is false. Falsifiers exist, and they are the majority of gap-free plain systems." In the predicate forms of section 3.2, P1 ("every monitor's signal is read by another monitor") and P4 ("from every monitor's flag, every other monitor is reached") fail in systems with no gap and no spare monitor: 515,030 of 742,352 with three monitors and one work process (my recount agrees). The sentence is true only with the properties read by what they do, and because no census system was shown to meet the fourth constraint. The README's wording ("none found that meets all four constraints") is the narrower, accurate one.
- **Corrected wording:** "**Result:** not met, with the properties read by what they do. In their predicate forms (section 3.2) the signal-read and report properties do fail in systems with no gap and no spare monitor, and the falsifier's verdict on the claim as it was put was "The claim is false". In every such system each monitor's silence is still read, by a monitor or by the work, and a bad state still stops the work in its round. None of them has been shown to meet the fourth constraint."

### B13. NARROWED
- **Where:** `formal-results.md` 12.1, lines 1205 to 1207. Also `README.md`, Searched, lines 103 to 104.
- **Claim:** "So the form in which a signal is read, and the form in which a flag reaches the work, vary from system to system. That the silence is read, and that one detection stops the system, do not."
- **Evidence:** Pass F's system 6.6 (`F4x1-Q4-1`, four monitors). Rebuilt in the checker: plain, no gap (18 states), no spare monitor. After `stop c`, monitor `a` is flagged and the work process takes a work step. A detection of a silence stopped nothing. F says so itself: "a raises a flag but w keeps working". What does not vary is that a bad state stops the work in its round, which is what "no gap" means.
- **Corrected wording:** "That the silence is read, and that a bad state stops the system in the round it appears, do not. A flag raised for a silence alone need not stop anything: in the falsifier's four-monitor system 6.6 one monitor flags another's stop and the work carries on."

### B14. NARROWED
- **Where:** `formal-results.md` 12.1, lines 1200 to 1201.
- **Claim:** "The two predicates about edges between monitors fail in most systems with no gap, including systems in which no monitor is spare: 515,030 of the 742,352 in the third row."
- **Evidence:** F's `result_3x1.json`, and my recount: of the 1,169,616 systems with no gap, the report predicate fails in 798,222 (68%), the signal-read predicate in 178,176 (15%), one or the other in 853,230 (73%). With two monitors the signal-read predicate never fails (0 of 12, 0 of 36). In the other two rows it fails in 14% and 19%. The count 515,030 is right.
- **Corrected wording:** "Of the two predicates about edges between monitors, the one for reports fails in most systems with no gap (798,222 of the 1,169,616 in the third row) and the one for signal reads in a minority (178,176 of them, and none with two monitors). One or the other fails in most, including where no monitor is spare: 515,030 of the 742,352 in the third row."

### B15. NARROWED
- **Where:** `formal-results.md` 12.1, lines 1185 to 1186. Also `README.md`, Searched, lines 99 to 101.
- **Claim:** "wrote its own deciders and settled every system of these sizes, one by one for the first four rows and by counting for the last." / "Every system with two or three monitors and one or two work processes was decided one by one, and every system with four monitors and one work process by counting."
- **Evidence:** F decided each system on its own, by plain reachability, for 2 and 1 (`exhaustive_2x1_reference.py`) and 3 and 1 (`honest_3x1.py`). For 2 and 2 and for 3 and 2 its scripts (`search_small.py`, `search_par.py`) decide each wiring of signal reads, reports and halt inputs, then visit only the systems with no gap one by one: 39,936 feasible wirings and 25,364,400 systems in 29.4 s, against 1,073,741,824 systems in all. F's report words the fourth row "every labelled system; each gap-free one visited one by one". (I decided the 16,384 of the second row one by one with the checker: 36 and 36.)
- **Corrected wording:** "wrote its own deciders and settled every system of these sizes: one by one for the first and third rows; for the second and fourth by deciding each wiring of signal reads, reports and halt inputs and then visiting every system with no gap one by one; and by counting for the last." / "Every system with two or three monitors and one work process was decided one by one; with two work processes, every wiring was decided and every system with no gap visited one by one; and every system with four monitors and one work process was settled by counting."

### B16. NARROWED
- **Where:** `formal-results.md` 12.1, lines 1167 to 1171 and 1173 to 1174.
- **Claim:** "*Propagation* takes its smallest form in 289 of them. Some monitor's flag does not reach every other monitor, that monitor is not spare, and there is still no gap, because the work process takes its halt directly from whichever monitor detects, or halts on a monitor's silence. No flag has to travel between monitors when the work can read them all." and "One detection still stops the whole system, which is what the property is for; the path is one read long."
- **Evidence:** The 289 recounted (9 + 280). With every report edge removed, 243 of them still have no gap and 46 do not: in those 46 a flag does have to travel. The work reads every monitor in 138 of the 289. In 20 of them every monitor whose flag fails to reach the others is spare in the system as given (the failure remains only after the deletions). "One detection still stops the whole system" holds in all 289: no round ends with a live correct flag and a work step.
- **Corrected wording:** "*Propagation* fails as a predicate in 289 of them even with spare monitors set aside, and there is still no gap. In 243 of the 289 no report is needed at all: the system has no gap with every report edge removed, because the work process takes its halt directly from whichever monitor detects, or halts on a monitor's silence. In the other 46 a flag does travel, along particular report edges and not between every pair." and "One detection still stops the whole system, which is what the property is for; in 243 of them the path is one read long, and in the other 46 it includes a report."

### B17. NOT CHECKABLE
- **Where:** `formal-results.md` 12, line 1120, and the four statements in italics that open 12.1 to 12.4.
- **Claim:** "The framework states four ways it could be shown wrong."
- **Evidence:** The framework's text is outside the folder and outside what this pass may open. The same holds for what "the four constraints" are (sections 1, 7, 12).

## Section 11

### B18. NARROWED (minor)
- **Where:** `formal-results.md` 11, line 1084. Also `README.md`, What is not established, line 118.
- **Claim:** "Rounds give every monitor a step between faults." / "The model gives every monitor a step between faults."
- **Evidence:** With `f` of 2 or more, faults land together with no monitor step between them: section 5's own execution for R at `f` = 2 mutates M1 and M3 in one round.
- **Corrected wording:** "Rounds give every monitor a step after at most `f` faults." / "The model gives every monitor a step after at most `f` faults."

## Section 10.5

### B19. NOT CHECKABLE
- **Where:** `formal-results.md` 10.5, line 1041, and 12.4, line 1269. Also `README.md`, The implementations, line 171.
- **Claim:** "Two implementations of the ring exist, both public:" / "the two implementations, built and run." / "Two rings have been built on this structure, and both are public:"
- **Evidence:** No web access. Both exist on this machine (the two files this pass may open are there). That they are public at the two addresses and branches, and that they were run, cannot be checked here.

### B20. NOT CHECKABLE
- **Where:** `formal-results.md` 10.5, line 1048.
- **Claim:** "The fuller of the two is ghostunnel's."
- **Evidence:** Needs the second implementation's specification, which this pass may not open.

### B21. NOT CHECKABLE
- **Where:** `formal-results.md` 10.5, line 1049.
- **Claim:** "Line numbers are at commit `0741dac`."
- **Evidence:** Every cited line number matches `observers/SPEC.md` as it is on disk (911 lines). Which commit that is needs the repository, which this pass may not open.

### B22. WRONG (the quotation only; minor)
- **Where:** `formal-results.md` 10.5, table, row "a round", line 1053.
- **Claim:** "| a round | one cycle; a change is seen "with a latency of at most one cycle" (604) |"
- **Evidence:** `SPEC.md` line 604 reads "... is judged by the next cycle's first read: a latency of at most one cycle." The word "with" is not in the source. The substance holds. The other two quotations (872, 568) are exact, and 899 is exact around its ellipsis.
- **Corrected wording:** "| a round | one cycle; a change is seen with "a latency of at most one cycle" (604) |"

### B23. NOT CHECKABLE
- **Where:** `formal-results.md` 10.5, table, rows "state check" and "not modelled", lines 1055 and 1057.
- **Claim:** "| state check | `copy-current`, `binary-expected` and others: current state against a reference | |" and "history checks: hash chains and a trace that may only grow (I1, I3, I4, `trace-consistent`)"
- **Evidence:** Neither row cites a line. On the lines cited elsewhere, `binary-expected` is at 673 and 911, I1 and I4 at 365, `trace-consistent` at 674 ("a segment may only grow"). `copy-current` and I3 are on no cited line, and this pass may open the file only there.

### B24. NOT CHECKABLE
- **Where:** `formal-results.md` 10.5, table, row "boundaries", line 1063.
- **Claim:** "five operating-system users, one store per member, one writer per path; all on one host (911)"
- **Evidence:** Line 911 confirms "all on one host" ("every member runs on one host under one kernel and one service manager"). The five users, the stores and the one writer per path are not on line 911 or any other cited line.

### B25. NOT CHECKABLE
- **Where:** `formal-results.md` 10.5, lines 1076 to 1077.
- **Claim:** "By the survey's reading of the procedures, a change made and undone between two reads, seen by nobody, is caught by neither."
- **Evidence:** The survey is not in the folder and no line is cited.

## Sections 10.3 and 10.2

### B26. NARROWED
- **Where:** `formal-results.md` 10.3, line 1011; 10.2, lines 954 to 955; 10.2, table, line 922.
- **Claim:** "How many such members there are is the one thing here that is chosen and not forced." / "One member must be able to start by itself, and it must observe the rest." / "| Recover without an outside hand | one member that can start by itself and observes the rest | proved and checked, section 10.3 |"
- **Evidence:** Theorem R forces a member that can start alone, and nothing more. That it observes every other member is enough, and is not forced. `restart_game` on a ring of three in which the coordinator starts by itself and observes X1 only (X1 observes X2, X2 observes X3): "can always restart", 33 states. The coordinator starts, then X1, then X2, then X3. Section 10.3 itself says "should", and so does section 1.
- **Corrected wording:** "How many such members there are, and whether the one that starts alone observes every other member directly or reaches some of them through members it has started, are chosen and not forced." / "One member must be able to start by itself, and every other member must be reachable from it along observation edges. Observing all of them directly is the simplest way." / "| Recover without an outside hand | one member that can start by itself, from which every other member is reached by observation | the first proved, the second checked on one ring of four, section 10.3 |"

### B27. NARROWED
- **Where:** `formal-results.md` 10.2, lines 957 to 959, and table, line 921.
- **Claim:** "A flag crosses between rings only through a member that belongs to both and is watched from both (every such edge is needed in section 10.1)." / "| A flag crosses between rings | a member shared by both, watched from both | checked, section 10.1 |"
- **Evidence:** `results.json`, the one-edge removals. Of the four edges by which a coordinator is watched, three are needed (A1 checks KA; U3 checks KA; U3 reads KA's signal) and one is spare: "A1 reads KA's signal" (and "B1 reads KB's signal"), both judgements hold. Each single report between a coordinator and its own members is spare too. Section 10.1 says the same: "a coordinator's by a member and by the upper ring ... So one of each pair can go."
- **Corrected wording:** "A flag crosses between rings only through a member that belongs to both, is checked from both and is read from above (in section 10.1 both state checks of the coordinator, and the upper ring's read of its signal and its reports, are each needed; the first member's read of its coordinator's signal is spare)." / "| A flag crosses between rings | a member shared by both, checked from both and read from above | checked, section 10.1 |"

## Section 10.1

### B28. NOT CHECKABLE
- **Where:** `formal-results.md` 10.1, table, line 881, and section 1, lines 73 to 75. Also `README.md`, Checked, line 88.
- **Claim:** "Four monitors, all pairs watching, one work process reading all four. This is the ring as built in both implementations: three members and a coordinator." / "The ring as built in the two implementations (three members and a coordinator, all pairs checking) holds up to three faults per round in the model." / "The ring as built in the two implementations (four members, all pairs checking) holds at one, two and three faults per round."
- **Evidence:** The model result is confirmed: the mesh of four holds at `f` = 1, 2 and 3. That it is the ring as built can be checked only in part. Seen: both have three members and a coordinator; both gates read every member's `halt`, `fault` and `halts/`; in ghostunnel every member reads every other's heartbeat (356). Not seen: that every pair checks state in both. In ghostunnel the recomputation covers the three members that own a surface (673, 675). For the second implementation the gate file does not say who checks whom. One difference from the model: its work process halts on the silence of any of the four, while the gates read the heartbeat of the coordinator only (and, in the second, of the local observer).

## Section 9

### B29. NARROWED
- **Where:** `formal-results.md` 9, the listing, lines 731 to 789.
- **Claim:** the module as printed, opening "---------------------------- MODULE Heartbeat ----------------------------".
- **Evidence:** Line by line against `Heartbeat.tla`: 57 printed lines, 72 in the file. No printed line differs. Missing from the listing are nine comment lines and the definition of `TypeOK` (five lines), which `Heartbeat.cfg` names as an invariant. The table of states, the count of 8 and the argument that no shorter trace exists are confirmed.
- **Corrected wording:** add after the listing: "The listing leaves out the module's comments and its `TypeOK` definition, which `Heartbeat.cfg` also checks. Every other line is as in `Heartbeat.tla`."

## Section 8

### B30. WRONG
- **Where:** `formal-results.md` 8.2, lines 704 to 705.
- **Claim:** "(the proofs are the independent verifier's, in `verify-d/claims-verdicts.md`)"
- **Evidence:** There is no `verify-d` folder. The file is `verification/d-claims/claims-verdicts.md`.
- **Corrected wording:** "(the proofs are the independent verifier's, in `verification/d-claims/claims-verdicts.md`)"

### B31. NARROWED (minor)
- **Where:** `formal-results.md` 8.2, lines 699 to 702.
- **Claim:** "At two hops per tick the damage is at most `sqrt(n / 2)`, a share that goes to 0." and "At one hop per tick, the same speed as the fault, a doubling halt loses a quarter of the system (exactly `n / 4` when `n` is a power of two)."
- **Evidence:** `growth` for every `n` from 1 to 3,000. The first fails at `n` = 1 only (damage 1). D states it as `max(1, sqrt(n/2))` for `n` of 4 or more. The second: the damage is 1, 1, 2 for `n` = 1, 2, 4, not `n / 4`. It is exactly `n / 4` for powers of two from 8 to 2^40, which is the range D proved. For other `n` from 8 to 3,000 the share lies between 0.20 and 0.40.
- **Corrected wording:** "At two hops per tick the damage is at most `sqrt(n / 2)` for every `n` of 2 or more, a share that goes to 0." and "At one hop per tick, the same speed as the fault, a doubling halt loses about a quarter of the system (exactly `n / 4` when `n` is a power of two and at least 8; between a fifth and two fifths for every other `n` from 8 to 3,000)."

### B32. NARROWED (minor)
- **Where:** `formal-results.md` 8.2, line 688.
- **Claim:** "If everything halts `w` ticks after detection, the damage is `2^w`."
- **Evidence:** `growth(8, "window", 5)` is 8, not 32: the damage stops at `n`.
- **Corrected wording:** "If everything halts `w` ticks after detection, the damage is `2^w`, up to the whole system."

### B33. NARROWED (minor)
- **Where:** `formal-results.md` 8.1, lines 661 to 664. Also `README.md`, Proved, lines 77 to 78.
- **Claim:** "**Proved,** from the round semantics: when reports take a round, a work process that goes bad takes `d` further work steps" / "When reports take time, a bad work process acts once for every hop between the monitor that checks it and the monitor that stops it."
- **Evidence:** What pass E proved (E4) is for a plain system with slow reports in which the mutation is the environment's only step. On 2,017 random such systems: no counterexample. Outside those conditions the count changes. A chain with `d` = 2 gives 2 work steps; with a halt input stopped in round 2, 1; with a window of one round, 3.
- **Corrected wording:** "**Proved,** from the round semantics, for a plain system in which reports take a round and the mutation is the environment's only step: a work process that goes bad takes `d` further work steps" / "When reports take time and nothing else goes wrong, a bad work process acts once for every hop between the monitor that checks it and the monitor that stops it."

## Section 7

### B34. NARROWED
- **Where:** `formal-results.md` 7, table, lines 614 and 615.
- **Claim:** "| P8b Halt fan-out | G2 | reachability | mixed | `f + 1` halt sources in general |" and "| The gate | G2 | reachability | not reviewed (added later) | an emergent requirement, not one of the eight |"
- **Evidence:** `run-output.txt` lines 15 and 16: without P8b, and without the gate, "G1 broken in 3 rounds" as well as "G2 broken in 1 round". The search's execution for P8b: mutate M1, stop M2, stop M3. The rows for P4, P6 and P8 name one judgement because the other holds in every reachable state. These two rows read the same way and it is not so. Section 6 does say it for the gate.
- **Corrected wording:** "| P8b Halt fan-out | G2, in one round; G1 too, in three | ..." and "| The gate | G2, in one round; G1 too, in three | ..."

### B35. NARROWED (minor)
- **Where:** `formal-results.md` 7, line 617.
- **Claim:** "The reviewer forced each removal onto 400 random systems."
- **Evidence:** B's report says so, but its script `scratch_universal.py` runs eight trials of 400 (P1, P2, P3, P5, P6, P7, P8, P8b). Rerun: 400 of 400 in each. P4 is not put through the random trial. It is shown to depend on wiring by two fixed systems without report edges that have no gap.
- **Corrected wording:** "The reviewer forced eight of the nine removals onto 400 random systems each, and the gap appeared every time. P4 it showed to depend on wiring, by two systems without report edges that have no gap."

## Section 6

### B36. NARROWED
- **Where:** `formal-results.md` 6, The gate, lines 592 to 593.
- **Claim:** "Without the gate the round in which a fault lands is never a complete response, so the environment also gets further rounds."
- **Evidence:** In R without the gate, `stop M3` (and `fail-substrate s3`) is answered completely in round 1: W1 and W2 halt on M3's silence, M1 and M2 flag it, the state is responded. A later fault can be too: `stop M1`, then `mutate W2` ends in a complete response in round 2 with no work step while bad. What is never answered in its own round is the first step that makes a state bad (all five first mutations, and `fail-substrate s1` and `s2`). The G1 execution quoted after it is the one the search finds.
- **Corrected wording:** "Without the gate the round in which a state first goes bad is never a complete response, so the environment also gets further rounds. (A stop can be answered in its own round: `stop M3` halts both work processes on its silence, and M1 and M2 flag it.)"

### B37. NARROWED
- **Where:** `formal-results.md` 6, P2, second face, lines 426 to 427 (with line 411).
- **Claim:** "*One substrate, any `k`.* The only step that stops M in this way stops W with it. W takes no further work step, so nothing it could do while bad happens."
- **Evidence:** This rests on "losing that substrate stops both" (line 411). That is not the model's step. In `model-spec.md` 3.1, and in section 2.2 of the write-up, `fail-substrate` stops the monitors on the substrate and leaves a work process on it running and bad. Read that way, with a threshold `k` of 1 or more, W on the shared substrate takes a work step while bad in round 1. And a crash of M alone (the model's `stop`) leaves W working for `k` rounds on either arrangement, so the gap of the first bullet is there too for `k` of 2 or more. A small simulation of the threshold model confirms all four cases. The first bullet holds as written. No earlier pass checked this argument (section 13).
- **Corrected wording:** "*One substrate, any `k`.* Read the loss of the substrate as stopping W as well as M. (This is not the round model's `fail-substrate`, which leaves a work process on the substrate running and bad.) Then the only step that stops M in this way stops W with it, and W takes no further work step. A crash of M alone is not covered: it leaves W working for `k` rounds on either arrangement."

## Section 5

### B38. NOT CHECKABLE
- **Where:** `formal-results.md` 5, line 344.
- **Claim:** "R is the smallest system found in which all ten removals can be told apart."
- **Evidence:** No record of a search for smaller systems is in the folder.

## Section 3

### B39. NARROWED
- **Where:** `formal-results.md` 3.2, table, line 294.
- **Claim:** "| P8b Halt fan-out | every work process takes its halt from at least two monitors; every halt is passed to at least two more | mutate, of a relay |"
- **Evidence:** The table is headed "a statement about the system's relations". The second clause is no relation of the round model: `reference()` builds P8b as two halt inputs for each work process and nothing else, and the removal takes one away. "Passed to at least two more" exists only in `growth`, the count of section 8.2, which is not joined to the round model. Pass B found the same (its 2.3).
- **Corrected wording:** "| P8b Halt fan-out | every work process takes its halt from at least two monitors (that every halt is passed to at least two more is counted in section 8.2, not modelled here) | mutate, of a halt source |"

### B40. WRONG (minor)
- **Where:** `formal-results.md` 3.1, heading, line 250.
- **Claim:** "### 3.1 Three layers"
- **Evidence:** The table under it, headed "Layer", has four rows: Constraints; Emergent; Implementation; This model's own choices.
- **Corrected wording:** "### 3.1 Three layers, and the model's own choices"

## Section 2

### B41. NOT CHECKABLE
- **Where:** `formal-results.md` 2.4, lines 167 to 168.
- **Claim:** "This is the goal as the task statement defines it."
- **Evidence:** No task statement is in the folder.

## Section 1

### B42. NARROWED
- **Where:** `formal-results.md` 1, lines 75 to 76.
- **Claim:** "Two levels of recursive interleaved rings hold too, including when a whole base ring is lost in one step."
- **Evidence:** The sentence follows "holds up to three faults per round in the model". The two-level system was checked at `f` = 1 only, and fails at `f` = 2: mutate A1 and KA in one round, and WA, whose two halt inputs they are, takes a work step. The README says "at one fault per round".
- **Corrected wording:** "Two levels of recursive interleaved rings hold at one fault per round, including when a whole base ring is lost in one step."

### B43. NARROWED
- **Where:** `formal-results.md` 1, item 1, lines 37 to 38.
- **Claim:** "Judged against detection alone, P4, P8 and the halt fan-out would look unnecessary, which shows that detection alone is too weak a goal."
- **Evidence:** `run-output.txt`: without P4 and without P8, G1 holds. Without P8b, "G1 broken in 3 rounds" (mutate M1, stop M2, stop M3). So against G1 alone the halt fan-out does not look unnecessary in the checker's result. The G1 break exists only because W1, never halted, keeps the model running (pass B says the same).
- **Corrected wording:** "Judged against detection alone, P4 and P8 would look unnecessary: without either, G1 holds in every reachable state. That shows detection alone is too weak a goal. Removing the halt fan-out does break G1, in three rounds, but only because the work it fails to halt keeps the model running."

### B44. NARROWED (minor)
- **Where:** `formal-results.md` 1, lines 20 to 22.
- **Claim:** "In a model where at most `f` faults land between two monitor rounds, a reference system that has all the properties has no gap, and removing any one of them, alone, opens one."
- **Evidence:** True at `f` = 1. At `f` = 2 the reference system has a gap in both judgements (section 5).
- **Corrected wording:** "In a model where at most `f` faults land between two monitor rounds, a reference system that has all the properties has no gap at `f` = 1, and removing any one of them, alone, opens one."

## README.md

### B45. NOT CHECKABLE
- **Where:** `README.md`, opening, lines 3 to 5.
- **Claim:** "The kit rests on three claims: that each of the eight properties is needed, that a system with all of them has no gap, and that the structure of three observers and a coordinator follows from the four constraints."
- **Evidence:** The kit is outside the folder and outside what this pass may open.

### B46. NARROWED
- **Where:** `README.md`, Proved, lines 73 to 74.
- **Claim:** "**Theorem S.** Four conditions on the wiring are enough for any system, of any size and depth, to respond completely to every single fault."
- **Evidence:** The theorem is for plain systems (`formal-results.md` 10.1). In `results.json` the four conditions hold and a judgement is broken at `f` = 1 in eight systems that are not plain: `R-P2`, `R-P5`, `R-P6`, `R-P7`, `R-P8`, `R-gate`, `mesh4-one-boundary`, `reflex-relayed-slow`. For plain systems it is confirmed: 3,000 random ones meeting the conditions, no violation; the tally of 72 recounted.
- **Corrected wording:** "**Theorem S.** Four conditions on the wiring are enough for any plain system (no joiner, substrates, switches, shared boundary, window or delayed reports; the gate and the halt on silence in place), of any size and depth, to respond completely to every single fault."

### B47. NARROWED (minor)
- **Where:** `README.md`, Proved, line 71.
- **Claim:** "A work process with `f` or fewer halt sources keeps working after they are all faulted."
- **Evidence:** True when they are mutated, which is what `formal-results.md` section 6 says. A stop is also a fault here, and a work process halts on the silence of a stopped halt source: with them stopped it kept working in 0 of 612 random systems.
- **Corrected wording:** "A work process with `f` or fewer halt sources keeps working after they are all mutated."

### B48. NARROWED (minor)
- **Where:** `README.md`, Proved, lines 81 to 82.
- **Claim:** "A halt passed to two keeps pace when a hop is quicker than the doubling."
- **Evidence:** Listed under "Proved". What D proved is the bound at exactly two hops per tick. For 3, 4 and 8 hops per tick my computation finds the same bound met for every `n` to 3,000, which supports the sentence and is not a proof.
- **Corrected wording:** "A halt passed to two keeps pace at two hops per doubling (proved); at one hop per doubling it loses about a quarter of the system."

### B49. NARROWED (minor)
- **Where:** `README.md`, Verification, lines 152 to 153.
- **Claim:** "Each folder under `verification/` holds the specification as it stood when that pass ran, so the copies differ slightly from `model-spec.md`."
- **Evidence:** The copies in A, B and D are one older text and differ from `model-spec.md`. The copies in E and F are identical to it, byte for byte.
- **Corrected wording:** "Each folder under `verification/` holds the specification as it stood when that pass ran. The copies in A, B and D differ slightly from `model-spec.md`; those in E and F are the same as it."

### B50. NOT CHECKABLE
- **Where:** `README.md`, Verification, lines 153 to 154.
- **Claim:** "Local paths in the reviewer's scripts were replaced by paths relative to each script; nothing else in those folders was changed."
- **Evidence:** B's scripts hold no absolute path, which is consistent. What else was or was not changed has no artefact.

### B51. WRONG
- **Where:** `README.md`, Running it, line 166.
- **Claim:** "It needs Python 3.8 or later and nothing else."
- **Evidence:** `check_model.py` line 573, in `key_of`, joins two dictionaries with `|`, which exists from Python 3.9. `key_of` is called by the census, so on 3.8 the run fails with a `TypeError` at output section 12. No 3.8 is installed here to show it; under 3.9.6 the census runs. Nothing else in the file needs more than 3.8.
- **Corrected wording:** "It needs Python 3.9 or later and nothing else."

---

## Counts

One claim is one checkable statement, one table row, or one cell where the cells of a row are separate results. A claim that appears in both documents is counted in each. An entry above may cover two or three claims that share one piece of evidence.

| Part | Examined | CONFIRMED | NARROWED | WRONG | NOT CHECKABLE |
|---|---|---|---|---|---|
| Files | 12 | 11 | 1 | 0 | 0 |
| 13 | 48 | 40 | 2 | 0 | 6 |
| 12 | 55 | 45 | 6 | 0 | 4 |
| 11 | 15 | 14 | 1 | 0 | 0 |
| 10.5 | 30 | 22 | 0 | 1 | 7 |
| 10.4 | 4 | 4 | 0 | 0 | 0 |
| 10.3 | 13 | 12 | 1 | 0 | 0 |
| 10.2 | 29 | 25 | 4 | 0 | 0 |
| 10.1 | 22 | 21 | 0 | 0 | 1 |
| 9 | 12 | 11 | 1 | 0 | 0 |
| 8.2 | 19 | 14 | 3 | 1 | 1 |
| 8.1 | 8 | 7 | 1 | 0 | 0 |
| 7 | 38 | 34 | 4 | 0 | 0 |
| 6 | 35 | 33 | 2 | 0 | 0 |
| 5 | 9 | 8 | 0 | 0 | 1 |
| 4 | 10 | 10 | 0 | 0 | 0 |
| 3 | 14 | 12 | 1 | 1 | 0 |
| 2 | 34 | 33 | 0 | 0 | 1 |
| 1 and the opening | 20 | 16 | 3 | 0 | 1 |
| `README.md` | 67 | 51 | 10 | 1 | 5 |
| **Total** | **494** | **423** | **40** | **4** | **27** |

Entries: 51 (27 NARROWED, 4 WRONG, 20 NOT CHECKABLE).

## Notes

- No result of the checker, no execution table and no count taken from a run or from a verifier's file was found wrong. The four WRONG entries are a file path, a quotation, a heading and the Python version.
- The entries that bear on what the write-up concludes are B12, B13, B16, B26, B27, B34, B36, B37, B43 and B46.
- Two statements were confirmed by my own check and have no proof in the folder. "`2f + 1` to name the faulty members" (10.2): a rule exists exactly when there are at least `2f + 1` monitors, in every case up to five monitors and two faulty. "A ring in which every member could start by itself would also restart" (10.3): `restart_game`, 27 states.
- The new sentence in 10.2, "A mesh of three and a ring of three pass them with no coordinator, and cannot restart", is confirmed.
- A `__pycache__` folder appeared in `formal-model\` at 00:44:43 and was gone by 00:54. It was not made by this pass: every run here used `python -I -B`.
