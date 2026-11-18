# Final round: reconciliation

*Saved by the main session from the reconciler's hand-back, word for word, except that one local
path is replaced by a relative one. The pass could not write a report file itself.*

# Reconciliation of the forward (F1 to F37) and backward (B1 to B51) findings

All 88 entries merge into 52 points. Every ruling below rests on my own recomputation or re-reading, not on either verifier's word. Scripts are in `reconcile/` (`rc.py`, `r01.py` to `r09.py`), run with `python -I -B`. Nothing under `shared-templates\` was written. Line numbers are those of the current `README.md` and `results.md`. SPEC line numbers are those of `observers/SPEC.md` on disk.

Three cases where a verifier's own correction would have put an error into the document are marked **[correction unsafe]**.

---

## README.md

**R1. B45. README, opening (3 to 5). KEEP.**
Reason: a statement of what the kit claims. The author's facts confirm the four constraints. No artefact in the folder could show it, and it is a fair statement of scope.

**R2. F1, B2. README, The method, item 6 (44 to 46); results.md 13, first sentence (1273). ACCEPT WITH CHANGE** (F1 for the README, B2 for section 13).
- README item 6: "**Independent verification.** Each phase up to the falsifier search was checked by an agent started fresh for the purpose and given only the artefacts: the specification, the cases, the code, or a claim as a bare statement. None was given the author's reasoning or expected results. Three results added afterwards did not get this check: the restart result, the second face of P2, and one unread signal at two tiers. Nor did the TLA+ module or the comparison with the implementation."
- results.md 13: "Every phase but those listed at the end of this section was checked by an agent started fresh for the purpose."
Reason: section 13 itself lists what no pass covered. Checked: pass B's copy of the checker has no `restart_game`; pass A's result files hold 101 cases and lack the two `mesh3-unread-M3` cases.

**R3. B3 (and the last line of F1). README item 6, last sentence; results.md 13 (1273 to 1275). REWORD** (README sentence KEEP; one sentence added in section 13).
- results.md 13, after "... and never the author's reasoning, expected results or proofs.": "The checker given to B carries its own comments and the ten schedules of section 6."
Reason: what an agent was not given leaves no artefact, and the folders are consistent with the claim (A: cases without results; D, E, F: bare briefs). The one checkable exception is B's input: `verification/b-review/check_model.py` line 525 lists "the executions written out in the write-up".

**R4. B47. README, Proved (71). ACCEPT** (B47).
- "A work process with `f` or fewer halt sources keeps working after they are all mutated."
Reason: a stopped halt source halts the work on its silence (spec 3.3). D's proof of C5 says the same: "the environment mutates rather than stops the halt inputs".

**R5. F2, B46. README, Proved (73 to 74). ACCEPT** (B46, the more compact list; it matches the definition in results.md 10.1 term for term).
- "**Theorem S.** Four conditions on the wiring are enough for any plain system (no joiner, substrates, switches, shared boundary, window or delayed reports; the gate and the halt on silence in place), of any size and depth, to respond completely to every single fault."
Reason: recomputed from `results.json`: the four conditions hold and a judgement is broken at `f` = 1 in exactly the eight non-plain systems B46 names. The plain tally is 31 / 0 / 14 / 27 of 72.

**R6. F3, B33. README, Proved (77 to 78); results.md 8.1 (661 to 664). ACCEPT WITH CHANGE** (F3's conditions; B33's wording is unsafe).
- README: "When reports take time and no other fault lands, a work process that goes bad acts once for every hop between the monitor that checks it and the monitor that stops it."
- 8.1: "**Proved,** from the round semantics, for the execution in which the mutation of the work process is the environment's only step, with no window and the gate in place: when reports take a round, the work process takes `d` work steps while bad, where `d` is the least number of report hops from one of its state checkers to one of its halt inputs. `d` is 0 exactly when a checker is itself a halt input. With no such path it works in every round. A further fault can lower the count (a halt input stops, and the work halts on its silence) or raise it (a relay stops or goes bad)."
Reason: replayed a chain with `d` = 3: mutation alone, rounds 1 to 3; `stop h` in round 2, round 1 only; a relay stopped or mutated, every round; a window or no gate adds one. **[correction unsafe]** B33's "a plain system in which reports take a round" contradicts 10.1, where plain means reports arrive within the round. E's own note says only window 0, gate and slow reports are used.

**R7. B48 (with the README consequence of F22). README, Proved (81 to 82). ACCEPT WITH CHANGE.**
- "A halt passed to one process per hop is outrun by a fault that doubles, at any speed. A halt passed to two keeps pace at two hops per doubling. Both results are for a halt that reaches good processes first."
Reason: D proved the bound at exactly two hops per tick (C9 ii) and the chain bound for every `h` (C9 i), both with the good-first order fixed in the claim. B48's added "about a quarter" is dropped: the share at one hop per tick runs from 20% to 40% (R34).

**R8. F4, B28. README, Checked (88 to 89); results.md 1 (73 to 75), 10.1 table row 1 (881), 10.5 row "signal read" (1054). REWORD for ghostunnel (settled), NEEDS AUTHOR for the second implementation.**
Settled from the files: `observers/README.md` line 20, "**Every member watches every other member.** Four members, twelve one-way edges, every pair mutual."; SPEC 28, "Every observer is a reader of every other member each cycle"; SPEC 593 (step 4: each member checks every other's store shape and runs procedures V and C). `observer_gate.php` line 62 gives four members with `super`, and lines 342 and 365 to 396 give the gate's reads. It does not say who checks whom.
- README: "The ring as ghostunnel builds it (four members, every pair watching each other) holds at one, two and three faults per round."
- results.md 1: "The ring as ghostunnel builds it (three members and a coordinator, every pair watching each other) holds up to three faults per round in the model."
- 10.1 row 1: "Four monitors, all pairs watching, one work process reading all four. Both implementations have three members and a coordinator. In ghostunnel every member watches every other (`observers/README.md` line 20; SPEC 28)."
- 10.5 row "signal read", comment cell: "all pairs (28)". The check that a heartbeat "must change" is V6 at 375; 358 and 370 are the bound and the backstop, so "(358, 375)" is the closer citation.
Missing from the author: the line in the second implementation's specification that says every member reads and checks every other. With it, "the two implementations" can stay, with both citations.
Reason: B28's noted difference (the gates read only the coordinator's heartbeat, the model's work halts on any silence) changes no result: the mesh of four with the halt on silence switched off still holds at `f` = 1, 2 and 3 (10, 46, 130 states).

**R9. B15. README, Searched (99 to 101); results.md 12.1 (1185 to 1186). ACCEPT WITH CHANGE** (B15's content, shorter README form).
- README: "Every system with two or three monitors and one or two work processes was decided, one by one or wiring by wiring, and every system with four monitors and one work process by counting."
- 12.1: "wrote its own deciders and settled every system of these sizes: one by one for the first and third rows; for the second and fourth by deciding each wiring of signal reads, reports and halt inputs and then visiting every system with no gap; and by counting for the last."
Reason: read `search_small.py` and `search_par.py`: both decide per triple through `plain.allowed_sets` and loop only over systems with no gap. Only `exhaustive_2x1_reference.py` and `honest_3x1.py` decide each system by plain reachability. F's report words the fourth row the same way.

**R10. F5, B13. README, Searched (102 to 104); results.md 12.1 (1205 to 1207). ACCEPT WITH CHANGE** (combined: F5's exact form of the signal clause, B13's example).
- README, last two sentences: "The edge by which a silence is read, and the edge by which a flag reaches the work, vary from system to system. Two things do not vary. Another monitor, or the work, reads the silence of every monitor the system depends on. A bad state stops the work in the round it appears, which is what no gap means. A flag raised for a silence alone need not stop the work: in one system with four monitors it does not."
- 12.1: "So the form in which a signal is read, and the form in which a flag reaches the work, vary from system to system. Two things do not. Another monitor, or the work, reads the silence of every monitor the system depends on. A bad state stops the work in the round it appears, which is what no gap means. A flag raised for a silence alone need not stop the work: in the falsifier's four-monitor system 6.6 one monitor flags another's stop and the work carries on."
Reason: rebuilt system 6.6: plain, no gap (18 states), no spare monitor; after `stop c`, `a` is flagged and `w` works. F's proof (report section 7) covers every non-spare monitor, so "depends on" is the exact qualifier. One piece of F5's evidence does not bear: in none of the 1,733 census systems (including the nine of the "32 | 9" row) does a round end with a live flag and a work step. The counterexample needs four monitors.

**R11. B18. README, What is not established (118); results.md 11 (1084). ACCEPT** (B18).
- README: "The model gives every monitor a step after at most `f` faults."
- 11: "Rounds give every monitor a step after at most `f` faults."
Reason: at `f` = 2 the section 5 execution lands two faults with no monitor step between (replayed).

**R12. F6, B49. README, Verification (152 to 153). ACCEPT** (F6).
- "Each folder under `verification/` holds the specification as it stood when that pass ran. The copies for A, B and D differ slightly from `model-spec.md`; those for E and F are identical to it."
Reason: byte comparison: A, B, D are one 6,358-byte text; E and F equal `model-spec.md` (8,022 bytes).

**R13. F7, B50. README, Verification (153 to 154). REWORD.**
- "Local paths in the reviewer's scripts were replaced by paths relative to each script. The files that hold the reports of passes A and B say that they were saved from the hand-backs, word for word. Nothing else in those folders was changed."
Reason: no absolute path remains under the folder (searched). `report-a.md` and `findings-b.md` each state how they were saved, and `report-a.md` ends with a section the author's session wrote. "Nothing else" stays as a statement of history.

**R14. F8. README, Verification (156 to 157); results.md 13 (1277 to 1279). KEEP.**
Reason: no artefact records what an agent could see. B10 notes that its own pass saw such a description, which is consistent.

**R15. F9, B1. README, Running it (163); results.md, last line (1330). ACCEPT WITH CHANGE.**
- README: `python -I check_model.py --traces   also print the shortest execution that breaks each judgement`
- results.md: "Add `--traces` to print the ten executions of section 6 and, for each system with a result line, the shortest execution that breaks each judgement. The 55 one-edge removals print none."
Reason: read `main()` and `report()`: output section 3 shows the ten replays, `report` prints one shortest execution per judgement, and the removals run with `quiet=True`.

**R16. F10, B51. README, Running it (166). ACCEPT** (identical wording).
- "It needs Python 3.9 or later and nothing else."
Reason: `key_of` (lines 572 to 573) joins two dictionaries with `|`, which exists from 3.9. The census calls it, so 3.8 would fail at output section 12.

**R17. F11, B19, B20, B21. README, The implementations (171 to 176); results.md 10.5 (1041 to 1049), 12.4 (1269). KEEP, with one NEEDS AUTHOR.**
KEEP: "both are public", "built and run", "The fuller of the two is ghostunnel's". No web access; these are the author's statements about two repositories a reader can open.
NEEDS AUTHOR: "Line numbers are at commit `0741dac`." Every cited line matches `observers/SPEC.md` on disk. Missing: confirmation that `0741dac` is reachable from the public branch `portal`. This session's notes record `0741dac9` as a local merge commit not pushed as of 2026-10-26; the repository itself was not opened. If it is not public, cite the public commit that carries these line numbers.

---

## results.md

**R18. B44. Section 1 (20 to 22). ACCEPT** (B44).
- "In a model where at most `f` faults land between two monitor rounds, a reference system that has all the properties has no gap at `f` = 1, and removing any one of them, alone, opens one."
Reason: R at `f` = 2 breaks both judgements (run output line 3; replayed).

**R19. F12, B43. Section 1, item 1 (36 to 38). ACCEPT WITH CHANGE** (B43, shorter sentences, plus "of R").
- "Judged against detection alone, P4 and P8 would look unnecessary: without either, G1 holds in every reachable state of R. That shows detection alone is too weak a goal. Removing the halt fan-out does break G1, in three rounds, but only because the work it fails to halt keeps the model running."
Reason: recomputed `R-P8b/f1`: G1 = 3, by mutate M1, stop M2, stop M3, with W1 working throughout. See R30 for the two other places.

**R20. F13, B42. Section 1, On the structure, Sufficient (75 to 76). ACCEPT** (F13).
- "Two levels of recursive interleaved rings hold too, at one fault per round, including when a whole base ring is lost in one step."
Reason: replayed at `f` = 2: mutate A1 and KA in one round, and WA works (G2 broken), with and without ring boundaries.

**R21. F14. Section 1, Wiring (87 to 88). ACCEPT** (F14).
- "*Wiring:* when a report takes time, the monitor that checks a work process must itself be able to stop it. A halt that has to reach a coordinator first then arrives after the bad process has acted."
Reason: `reflex-relayed-instant/f1` holds both judgements (recomputed). Sections 8.1, 10.2 and the README already carry the condition.

**R22. F15, B41. Section 2.4 (167 to 168). REWORD.**
- Replace "This is the goal as the task statement defines it." with: "The request this work was done for set detection as its goal. That request is not in this folder."
Reason: the author's fact. The new wording says what the reader cannot check and why.

**R23. B11. Section 1 (26), 2.6 (202), 12.3 (1243 to 1244). REWORD.**
- Section 1, after "The four constraints state the problem.": "They are: no central controller (C1); an undetected failure costs far more than a false alarm (C2); a fault can mimic a legitimate component (C3); no external maintenance (C4)."
- 2.6, row label: "C2, an undetected failure costs far more than a false flag" (the cell text stays).
- 12.3 stays as it is.
Reason: by the author's statement the second constraint has both halves. "A false flag is cheap" (2.6) and "no impact before detection" (12.3) are each one half, so there is no contradiction, but the document never lists the four. The other three labels match the author's list.

**R24. B40. Section 3.1, heading (250). ACCEPT** (B40).
- "### 3.1 Three layers, and the model's own choices"
Reason: the table under it has four rows.

**R25. F16, B39. Section 3.2, row P8b (294). ACCEPT** (B39; F16 is the same in substance).
- "| P8b Halt fan-out | every work process takes its halt from at least two monitors (that every halt is passed to at least two more is counted in section 8.2, not modelled here) | mutate, of a halt source |"
Reason: `reference()` builds P8b as halt inputs only; the second clause lives only in `growth`. The section 6 execution mutates M1, a halt source.

**R26. F17, B38. Section 5 (344). REWORD.**
- "R is a small system in which all ten removals can be told apart."
Reason: no search for smaller systems is recorded. The ten outcomes do differ (section 6 tables, recomputed).

**R27. F18, B37. Section 6, P2 second face (410 to 431); section 1 item 6 (64 to 66); section 7 row P2 (607); section 12.2 (1224 to 1227). ACCEPT WITH CHANGE** (combined; both verifiers' wordings contain "This is not ...", which the style rules exclude).
- Section 6, opening of the second face: "**Second face: the observer falls, and the work must fall with it.** Take a loss that stops whatever runs on the substrate, such as a power cut. The round model's `fail-substrate` is a different loss: it leaves a work process on the substrate running and bad (section 2.2), and against it a threshold of a round or more lets the work act while bad even on a shared substrate. If a monitor and the work it watches run on one substrate, a loss of the first kind stops both. There is then no moment at which the work runs and nothing watches it, and a system that is down cannot be made to act."
- Section 6, second bullet under Proved: "- *One substrate, any `k`.* The step that takes M's substrate stops W with it. W takes no further work step, so nothing it could do while bad happens. A crash of M alone is outside this face. On either arrangement it leaves W working for `k` rounds, and the halt on silence, with its threshold, is what answers it."
- Section 6, verdict: "*Verdict:* against the loss of a substrate, P2 is the gate made structural. The gate keeps work from outliving its observer by a check, and a check has a threshold. Against that loss, shared substrate does it by construction, with no check and no threshold."
- Section 1 item 6: "P2 does by construction what the gate does by a check: when a substrate is lost, sharing it leaves no threshold in which work runs unobserved."
- Section 7, row P2: kind of argument "by definition (first face); proved from an execution, for a loss that stops the work too (second face)"; note "the gate made structural, against the loss of a substrate; a freshness rule on reads does the first face's job by a check".
- Section 12.2, last sentence of the P2 bullet: "Against the loss of a substrate, sharing it has none (section 6)."
- Section 10.5, row "shared substrate": no change ("losing the host stops both" is the premise above).
Reason: replayed R without P8, `fail-substrate s1`: W1 is bad and W1 and W2 work. One monitor and one work process on one substrate with a one-round window: G1 and G2 broken in round 1. A small threshold model confirms the four cases, including B37's: a crash of M alone leaves W working while bad on either arrangement for `k` of 2 or more.

**R28. F19, B36. Section 6, The gate, last paragraph (592 to 593). ACCEPT WITH CHANGE. [correction unsafe]**
- "In R without the gate, no step that makes a state bad in round 1 is answered completely in that round, because no flag is up when the work processes step. So the environment also gets further rounds."
Reason: both corrections ("the round in which a first bad state lands", "the round in which a state first goes bad") are false as worded. In R without the gate, `stop M1` then `mutate W2` ends round 2 in a complete response with no work step while bad, and round 2 is the round in which a state first goes bad. Counted over all reachable rounds: of 45 in which the first bad state appears, 30 end responded. What holds is the round 1 form: all seven first-round steps that make a state bad leave the round unanswered. `stop M3` in round 1 is answered completely, as both verifiers say.

**R29. F20, B9. Section 7, first sentence (598); section 13, From B (1294). ACCEPT WITH CHANGE** (B9; "now" removed from the second).
- Section 7: "Each removal but the gate carries two labels."
- Section 13: "The verdict table carries B's label for each of the nine removals B reviewed."
Reason: the gate's row reads "not reviewed (added later)".

**R30. F21, B34. Section 7, rows P8b and the gate (614 to 615); section 6, P8b (563). ACCEPT WITH CHANGE** (F21's cells, plus one sentence in section 6 so the three places agree).
- Row P8b, judgement cell: "G2 in one round; G1 in three". Row "The gate", judgement cell: "G2 in one round; G1 in three".
- Section 6, P8b, after "W1's only halt source is alive and shows nominal.": "W1 never halts, so the model runs on, and the search finds G1 broken in three rounds: mutate M1, then stop M2, then stop M3."
Reason: recomputed both (G1 = 3, G2 = 1). Section 6 says this for the gate and not for P8b; neither verifier gave wording for that place.

**R31. B35. Section 7 (617 to 618). ACCEPT** (B35; it replaces the first two sentences of the paragraph).
- "The reviewer forced eight of the nine removals onto 400 random systems each, and the gap appeared every time. P4 it showed to depend on wiring, by two systems without report edges that have no gap."
Reason: read `scratch_universal.py`: eight trials of 400, then two fixed systems for P4.

**R32. F22. Section 8.2, The setting (675 to 676); section 11 (1113). ACCEPT WITH CHANGE** (F22 stands; reworded for style, and without the figure that no file in the folder reproduces).
- 8.2: "The halt reaches good processes first, and every figure and bound below is for that order. Another order can do more damage. For `n` = 8, at two per hop and one hop per tick, a second hop that halts one bad process and three good ones leaves one bad and one good running, and the damage is 3 against 2."
- 11: "- **The growth results are for one growth law,** doubling, **and one halting order,** good processes first. Another order can do more damage (section 8.2)."
- README: see R7.
Reason: my own exhaustive search over halting orders (`r04.py`): another order does more damage in 109 sizes from 2 to 200 at two per hop and one hop per tick, by up to a factor of 1.5 (`n` = 158: 48 against 32), and `n / 4 + 1` at powers of two. The bound `sqrt(n / 2)` still holds under the true worst order for every `n` to 400. F22's "at most a factor of 1.5 for `n` up to 200" is true and may be added if the search goes into the script.

**R33. F23, B32. Section 8.2, The window (688). ACCEPT** (F23).
- "If everything halts `w` ticks after detection, the damage is `2^w`, or the whole system if that is smaller."
Reason: `growth(n, "window", w)` equals `min(2^w, n)` for every `n` below 400 and `w` below 12.

**R34. F24, B31, B7 (first half). Section 8.2, second and third bullets and the paragraph after (699 to 706). ACCEPT WITH CHANGE** (combined; D's stated ranges kept exactly).
- Second bullet: "- A halt that doubles keeps pace when a hop is faster than the doubling time. At two hops per tick the damage is at most `sqrt(n / 2)` for every `n` of 2 or more, a share that goes to 0."
- Third bullet: "- At one hop per tick, the same speed as the fault, a doubling halt loses between a fifth and two fifths of the system for every `n` from 8 to 3,000, and exactly `n / 4` when `n` is a power of two of 8 or more."
- Paragraph: "The first bound is **proved** for every `n` of 2 or more, the second for every `n` of 4 or more, and the exact value `n / 4` for powers of two from 8 (the proofs are the independent verifier's, in `verification/d-claims/claims-verdicts.md`). All three were checked here by computation, with `growth` in `check_model.py`, for every `n` from 2 to 3,000 and for powers of two beyond. The range of a fifth to two fifths is from that computation."
Reason: recomputed: bound 1 holds from 1 to 3,000; bound 2 fails only at `n` = 1; exact `n / 4` fails at 1, 2 and 4; the share runs from 20.02% (`n` = 2,558) to 40% (`n` = 10). **[correction unsafe]** F24's "the first two bounds are proved for every `n` of 2 or more" goes past D's claim (ii), which is for `n` of 4 or more. The history clause (B7) is KEEP with the range corrected; naming `growth` makes it repeatable.

**R35. F25, B30. Section 8.2 (704 to 705). ACCEPT** (identical).
- "(the proofs are the independent verifier's, in `verification/d-claims/claims-verdicts.md`)"
Reason: there is no `verify-d` folder; the file exists at the corrected path. Included in the R34 paragraph.

**R36. F26, B29. Section 9, before the listing (729). ACCEPT WITH CHANGE** (combined).
- Add at the end of the paragraph before the listing: "The listing leaves out the module's comments and its `TypeOK` invariant, which `Heartbeat.cfg` lists. Every other line is as in `Heartbeat.tla`."
Reason: line-by-line comparison: 57 printed lines, 72 in the file, all printed lines present in order; missing are nine comment lines, the five lines of `TypeOK` and one blank. "Lists" in place of "checks", since the module has not been run.

**R37. F27, B26. Section 10.2 table (922) and "The coordinator, as a role" (954 to 955); 10.3 (1006, 1011); 12.3 table (1245). ACCEPT WITH CHANGE** (combined).
- 10.2 table: "| Recover without an outside hand | one member that can start by itself, from which every other member is reached along observation edges | the first proved, the second argued, both checked on one ring of four, section 10.3 |"
- 10.2 text: "One member must be able to start by itself, and every other member must be reached from it along observation edges. Observing all of them directly is the shortest such arrangement."
- 10.3, in "What the theorem forces", replacing "Once it is up, every member it observes may start, so it should observe all of them.": "Once it is up, every member it observes may start, and then every member those observe. So every other member must be reached from it along observation edges, and observing all of them directly is the shortest way."
- 10.3 (1011): "How many such members there are, and whether the one observes every other member directly or through a chain, are chosen and not forced."
- 12.3 table: "| a member that can start alone, from which every other member is reached | emergent, from the fourth constraint |"
- Section 1 and the README need no change ("should observe"; the checked case).
Reason: `restart_game`: a coordinator that starts alone and observes X1 only, can always restart (33 states); a ring of three with X1 able to start alone, can always restart (15). A coordinator that starts alone and observes nobody cannot. B26's evidence cell said "checked" for a case the checker's output does not contain; the cell above claims only what the folder shows.

**R38. F28, B27. Section 10.2 table (921) and text (957 to 959); optional 10.1 (903). ACCEPT WITH CHANGE** (B27's main clause, F28's fuller list).
- 10.2 text: "A flag crosses between rings only through a member that belongs to both, is checked from both and is read from above. In section 10.1 both state checks of a coordinator, the upper ring's read of its signal and every report in the upper ring are needed. Its own ring's read of its signal, and each single report between it and its own ring, are spare. The coordinator is that member."
- 10.2 table: "| A flag crosses between rings | a member shared by both, checked from both and read from above | checked, section 10.1 |"
- Optional, 10.1: "So one of each pair can go. For a coordinator's signal it is the member's read: the upper ring's is needed."
Reason: from `results.json`: A1 checks KA, U3 checks KA and U3 reads KA's signal are needed; A1 reads KA's signal is spare; each single report between KA and A1, A2, A3 is spare.

**R39. F29. Section 10.3, The implementation (1018 to 1019); 10.5, first of "Three things follow" (1070 to 1072). REWORD** (settled from SPEC).
- Both places: "The coordinator clears first, when no member's store holds a fault; the others clear only once its halt is gone (554 to 558). None of them clears while it is lost, because its silence is a failing assertion of each (383)."
Reason: SPEC 383: the coordinator is read like any other member, and `member-fresh` fails for it and raises a halt. SPEC 558: a member's clear-condition needs none of its own assertions to have failed. The clause is true. It is true of any lost member (523), so it is not part of the asymmetry; the wording above no longer presents it as such.

**R40. F30, B22. Section 10.5, row "a round" (1053). ACCEPT WITH CHANGE** (F30, tightened; B22's fix is exact but drops what the line is about).
- "| a round | one cycle; a change that lands after the first read of a path within a cycle is judged by the next cycle's first read, "a latency of at most one cycle" (604) | the model's unit of time is the cadence |"
Reason: SPEC 604 read. The word "with" is not in the source. The other quotations (568, 872, 899 around its ellipsis) are exact.

**R41. B23. Section 10.5, rows "state check" and "not modelled" (1055, 1057). REWORD** (settled; add the lines).
- "| state check | `copy-current` (403), `binary-expected` (713) and others: current state against a reference | |"
- "| not modelled | history checks: hash chains and a trace that may only grow (I1, I3, I4, 451 to 462; `trace-consistent`, 674) | they catch a change that was seen once and later undone; see below |"
Reason: read SPEC in full: K6 at 403, `binary-expected` at 713, I1 at 451, I3 at 458, I4 at 462, "a segment may only grow" at 674.

**R42. F31, B24. Section 10.5, row "boundaries" (1063). REWORD** (settled; add the lines).
- "| boundaries | five operating-system users, the proxy and each of the four members (15, 890); one store per member and one writer per path (34); all on one host (911) | the host is the scope; a level above is outside the specification |"
Reason: SPEC 890: "The deployment runs the proxy and each observer as different users". `observers/README.md` line 103 says it outright: "Five processes, five users, one Linux host, no containers".

**R43. F32 (first half), B25. Section 10.5, second of "Three things follow" (1074 to 1077). REWORD** (settled from the procedures; the survey drops out).
- Replace the third and fourth sentences of the bullet with: "The implementation does better than that assumption needs: its hash chains and its append-only trace catch a state that was bad when some member read it and was put back afterwards (I1, 451 to 454; `trace-consistent`, 674). Both compare the store with what a member recorded at an earlier read. A change made and undone between two reads, seen by nobody, leaves nothing recorded, and neither catches it." The bullet's last sentence stays.
Reason: I1 fires when a recorded hash is in no entry of the subject's chain; `trace-consistent` when a remembered prefix hashes differently. Neither has anything to compare for a change no member read. See new finding N2 for the clash with section 2.5.

**R44. B17. Section 12 (1120) and the italic statements of 12.1 to 12.4; "the four constraints" in sections 1, 7, 12. KEEP, with one NEEDS AUTHOR.**
KEEP: "The framework states four ways it could be shown wrong." The author confirms the four criteria and that section 12 quotes them; the four headings match the author's list.
NEEDS AUTHOR (section 7, 632 to 635; README 55 to 56): "It is what the four constraints assert: that a process can stop, that a fault can look like health, that everything in one boundary can be lost together, that processes join and nobody is on hand to enrol them, that a fault keeps acting while a response is being weighed." On the author's statement of the four constraints, a fault that looks like health is the third and the absent operator is the fourth. Loss of a whole boundary and processes joining are in none of the four as stated. Missing: where the framework's text asserts those two. If it does not, move them to the sentence that follows, which already assigns two faults to "the systems being modelled".

**R45. F33. Section 12.1, first bullet after the census table (1162 to 1163). ACCEPT WITH CHANGE** (F33, shortened).
- "- *State checking and two halt sources* hold in every system with no gap. Both are also proved: a state checker for every monitor, and two halt sources, in section 6; a state checker for every work process in the falsifier's report (`verification/f-falsifier/falsifier-report.md`, section 7)."
Reason: section 6 proves the monitor case and the halt-source count; 10.2 only restates counts. The work-process case is in F's section 7 and in E5.

**R46. F34, B16, and the second half of F5. Section 12.1 (1167 to 1174); 12.2, third bullet (1228). ACCEPT WITH CHANGE** (B16 for 12.1, scoped; F5's change to the "one detection" clause is rejected).
- 12.1 bullet: "- *Propagation* fails as a predicate in 289 of them even with spare monitors set aside, and there is still no gap. In 243 of the 289 no report is needed at all: the system has no gap with every report edge removed, because the work process takes its halt directly from whichever monitor detects, or halts on a monitor's silence. In the other 46 a flag does travel, along particular report edges and not between every pair."
- 12.1, after "This is scale again, not an alternative configuration.": "In all 289 one detection still stops the whole system, which is what the property is for. In 243 the path is one read long, and in the other 46 it includes a report."
- 12.2, first sentence of the third bullet: "Propagation is a direct read in 243 of the 289 small systems of section 12.1, and a report along particular edges in the other 46."
Reason: recounted: 289 = 9 + 280; 243 keep no gap with all reports removed, 46 do not; in 20 the failing monitor is spare in the system as given, so "that monitor is not spare" goes. No round in any of the 289 ends with a live flag and a work step, so the document's "one detection still stops the whole system" is right for the census and F5's replacement of it is not needed. It must be scoped to the 289, or it contradicts R10. F34's "only from a checker that is not a halt source" and "a single report" were not verified for all 46 and are left out.

**R47. F35, B14. Section 12.1, second and third bullets after the falsifier's table (1200 to 1203). ACCEPT WITH CHANGE** (B14, reordered). **[correction unsafe]**
- "- Of the two predicates about edges between monitors, the one for signal reads fails in a minority of systems with no gap (178,176 of the 1,169,616 in the third row, and none with two monitors) and the one for reports in most (798,222 of them). One or the other fails in most, including where no monitor is spare: 515,030 of the 742,352 in the third row."
- "- What is left of the signal-read predicate is proved without exception: where no monitor is spare, a monitor whose signal no other monitor reads is always one the work halts on."
Reason: from F's result files: 15%, 68%, and 73% for either, in the third row; the same pattern in the other rows (signal reads 0%, 0%, 14%, 19%). B14 as worded names reports first, which would turn "the first of them" in the next bullet into the wrong predicate. The order above and the explicit name remove that.

**R48. B12. Section 12.1, Result (1209 to 1210). ACCEPT WITH CHANGE.**
- "**Result:** not met. No system was found that meets all four constraints, has no gap, and lacks the properties. The searches judge detection and halting only, and none of their systems has been shown to meet the fourth constraint. Within them the predicate forms of the signal-read and report properties (section 3.2) do fail in systems with no gap and no spare monitor, and the falsifier's verdict on the claim as put to it was "The claim is false". What holds in every one of those systems is narrower: the silence of every monitor is read, by another monitor or by the work, and a bad state stops the work in its round."
Reason: F's report, line 9, read. B12's phrase "with the properties read by what they do" is left out: system 6.6 (R10) has no gap while one detection stops nothing, which is the function section 3.1 gives P4. The README's row ("none found that meets all four constraints") is accurate as it is.

**R49. F36, B10. Section 12.4 (1266 to 1268). KEEP.**
Reason: history of an attempt that left nothing in the folder; it reports its own failure.

**R50. F37, B4, B5, B6. Section 13, row A (1283) and From A (1291). REWORD for B4 and B5 (settled by `report-a.md` and a diff); KEEP for B6.**
- Row A, result cell: "identical on all 103 cases (the last two were computed afterwards with its code unchanged); ten points of ambiguous wording, listed in `report-a.md`. The alternative readings it ran changed no result, apart from one reading the text excludes; for two points it ran no alternative"
- From A: "*From A.* The specification's wording was tightened in eight places."
Reason: `report-a.md` lists seven points in the first report and three in the second, so "ten" stands. "None of which changed a result" does not: the second addendum point says the other reading "would change `reflex-relayed-slow/f1` G2 from 1 to null" and is excluded by the text, and points 6 and 7 say "No alternative tested". My diff of A's copy against `model-spec.md` shows eight sentences added or reworded, besides the two fields and section 3.6 (the same eight F37 lists). B6: `report-a.md` records that the author's session ran `impl_a.py` unchanged on the two late cases; I ran it too: (none, none) with 14 states and (2, none) with 76.

**R51. B7 (second half). Section 13, From D (1298 to 1299). KEEP.**
Reason: "were checked by computation before being adopted" is history. My run confirms the bounds over the stated range (R34).

**R52. B8, F32 (second half). Section 13 (1313 to 1314). KEEP.**
Reason: history. I read every cited SPEC line: with R40 applied, every quotation is exact, and R39, R41, R42 and R43 supply the lines that were missing.

---

## Raised by only one verifier, and it matters

- **F22 (R32, R7).** "The worst order" is false. It touches 8.2, section 11 and the README. Backward missed it.
- **B12 (R48).** The Result line of 12.1 never reported the falsifier's verdict "The claim is false". Forward missed it.
- **B48 and B47 (R7, R4).** Two README lines under "Proved" said more than the proofs do.
- **F14 (R21).** The wiring rule of section 1 holds only when a report takes time.
- **B15 (R9).** "One by one" overstates how two of the four sizes were decided.
- **B35 (R31).** The 400-system trial covered eight removals; P4 was shown by two fixed systems.
- **B44 (R18), B11 (R23), F29 (R39), B23 (R41).** Smaller, and each stands.

## Found by neither

- **N1. R28.** Both corrections of the gate paragraph are false as worded; B36's own evidence contradicts B36's wording.
- **N2. Section 2.5 item 2 against 10.5.** 2.5 says of a state that goes bad and is put back between two checks: "a record that may only grow catches it". 10.5 says the implementation's hash chains and append-only trace catch such a change by "neither". Suggested wording for 2.5: "Whether such a change is caught depends on the form P3 takes. A comparison of current state misses it. A record that may only grow catches it when the change left an entry or some member read the bad state, and misses it otherwise (sections 3.1 and 10.5)." The author should confirm the intent.
- **N3. R44.** The list of fault kinds attributed to "the four constraints" in section 7 goes beyond the constraints as the author states them.
- **N4. R30.** Section 6 says "Breaks G2" for P8b and never mentions the G1 break; it does for the gate.
- **N5. R17.** Commit `0741dac` may not be on the public branch.
- **N6. Interactions between corrections:** B33 against the definition of plain (R6); B14 against "the first of them" (R47); B16 against the 6.6 correction unless scoped (R46); B12's "read by what they do" against 6.6 (R48); F24's range against D's claim (R34); B26's "checked" for an unshipped case (R37).
- **N7. System 6.6 and section 3.1.** Section 3.1 gives P4's function as "one detection stops the whole system". System 6.6 has no gap and no spare monitor, and one detection of a silence stops nothing. R10 and R48 state this; the 3.1 table is left as the framework's wording.
- **N8. The script, outside the two documents and not changed:** the `growth` docstring says "(the worst order)", which R32 contradicts; the module docstring says `--traces` prints "every execution" and "eight-property model"; line 767 says "(section 7)" for the TLA+ mirror, which is section 9. F noted the last two.
- **N9. Minor:** section 13 "From F" says "its two proofs"; 12.1 reports three proved statements. `run-output.txt` names `systems-all.json` and E's report names `test_bounded.log`; neither file is in the folder (F noted both). The pass letters skip C with no explanation.

## Count of rulings by kind (52)

| Kind | Count | Rulings |
|---|---|---|
| ACCEPT | 13 | R4, R5, R11, R12, R16, R18, R20, R21, R24, R25, R31, R33, R35 |
| ACCEPT WITH CHANGE | 21 | R2, R6, R7, R9, R10, R15, R19, R27, R28, R29, R30, R32, R34, R36, R37, R38, R40, R45, R46, R47, R48 |
| REJECT | 0 | none whole; two parts rejected inside R10 and R46 (F5's census-table evidence, F5's change to "one detection") |
| KEEP | 7 | R1, R14, R17, R44, R49, R51, R52 |
| REWORD | 11 | R3, R8, R13, R22, R23, R26, R39, R41, R42, R43, R50 |
| NEEDS AUTHOR | 3 items inside other rulings | R8 (the second implementation's all-pairs line), R17 (commit `0741dac` public), R44 (where the framework asserts boundary loss and joining) |

Five entries the verifiers marked NOT CHECKABLE are settled from the files allowed: F4/B28 for ghostunnel, F29, B23, F31/B24, F32/B25. F37/B4/B5/B6 are settled from `report-a.md`.
