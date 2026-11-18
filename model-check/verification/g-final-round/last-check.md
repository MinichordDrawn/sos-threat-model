# Final round: last check

*Saved by the main session from the last check's hand-back, word for word, except that one path
to a working folder is replaced by a relative one. The pass could not write a report
file itself.*

# Last check of the passages changed since the sweep

Scope: every hunk of `results.diff` and `README.diff`, read in the current `results.md` (1,595 lines) and `README.md` (465 lines). Both diffs were regenerated and match the ones supplied. Line numbers below are those of the current documents.

Independence: every verdict was formed from the folder, the specification, the checker and the cited implementation lines before the four reports in `verification/g-final-round/` were opened. One early command that would have printed the head of `findings-forward.md` was refused by the permission system before it returned anything. The four reports were then read only as the last step, and only for what the documents say about those passes. Outside the folder, this check read `sos-formal/check_model.py` (to see which docstrings changed) and counted the lines of the document snapshots under `sos-formal/final-round/`. Nothing under `shared-templates\` was written.

## What was confirmed (no entry needed)

- **Ring of three (item 1).** `ring(3, "same", 2)` satisfies every row of the section 3.2 table (P2 and P7 vacuously) and the gate, and has G2 broken in one round and G1 in three. After `mutate M1`, M3 flags and reports to M1, and the work, reading M1 and M2, takes a step.
- **Item 2.** In R, G2 breaks for every removal but P6. G1 holds without P4 and without P8, and breaks in three rounds without P8b and without the gate.
- **Item 3.** Theorem 0 part 3 matches `model-spec.md` 3.2: detection has exactly those two clauses, and `flagged` grows only from a detection. This sentence is not in either diff. The mesh of four in one boundary gives G1 broken in two rounds and G2 holding.
- **Item 4.** The `f` = 2 execution replays exactly as written and is the one the search finds.
- **Item 5.** In R without P8b, W1 halts in no round while M1 is bad and alive (0 of all transitions over 1,818 states), and halts when M1 is stopped. The checker explores each removal (`main`, section 2) and replays each table execution (`CANONICAL`).
- **Item 6.** `findings-b.md` section 3 gives the argument from definitions and 400 of 400 for eight removals. The five proofs are where the sentence says (but see L33).
- **Item 7.** `observers/SPEC.md:827` and `:831` and `PR2: common/observer_gate.php:383` say what section 8.1 claims. `growth` gives damage 1 at `n` = 2 and 3, all three bounds hold for `n` from 2 to 3,000 and for powers of two to 2^24, and the share runs from 0.2002 to 0.4000.
- **Item 8.** The definition of "can start first" and all four table rows match `restart_game` and its output (5, 14, 45 and 36 states). Both quotations at `:564` and `:568` are exact. `:556`, `:556-558`, `:28`, `:184`, `:383` and `:818-834` support their sentences. "The coordinator's own assertions do not test that each member has read it" is confirmed: `:454` judges only non-null `observed` values and `:753` allows null.
- **Item 9.** `:834` and `:911` together put the proxy and every member on one host. `:15`, `:890`, `:34`, `:266` and `:364` support their rows.
- **Item 10.** 1,024 plain systems with no self-edges; 6,000 draws, 3,000 uniform and 3,000 a full mesh with 0 to 6 entries removed; 4,890 distinct; 12 and 1,721 with no gap. The falsifier decided rows one and three one by one (`exhaustive_2x1_reference.py`, `honest_3x1.py`), rows two and four through `allowed_sets`, and counted the last. The quotation "The claim is false" is exact.
- **Item 11.** All counts for A to F and for the final round match the reports: 422 = 357 + 40 + 4 + 21; 494 = 423 + 40 + 4 + 27; 37 + 51 = 88 entries into 52 points; 13, 21, 11, 7; four `[correction unsafe]` marks at R6, R28, R34, R47 (the report's own opening line says three); N1 to N9; three NEEDS AUTHOR items; 724 = 677 + 37 + 5 + 5 with 7 style and 13 sense entries. The list "From the sweep" matches S1 to S4 and the narrowings S5, S7, S8, S15. Both verifiers' reports give 1,330 lines for the note. The README's 178 lines is not stated in any report (they give 10,236 bytes); the snapshots both verifiers kept outside the folder have 178 lines.
- **Item 12.** The README's eight rows are word for word the middle column of section 3.1. Its two definitions agree with section 3.2 (but see L36).
- **Item 13.** Every section number, file name and path in a changed passage exists and is the right one. The two documents agree wherever both state a changed result, apart from L18 and L36.
- **Pass B.** D1 to D4 are fixed in the current script and D5 stands (`lc07`).

## Part 1: facts

**L1. `results.md`, section 1, lines 26 to 27; `README.md`, "The result", lines 18 to 19. NARROWED.**
"For any plain system, four conditions on the wiring are enough for no gap (Theorem S, section 10.1)." / "For any system of a stated class, four conditions on the wiring are enough for no gap."
Evidence: Theorem S is stated "for one fault per round" (line 936) and "plain" does not include the rate (lines 938 to 941). The mesh of two is plain, meets (a) to (d), and at `f` = 2 has G1 and G2 broken in round 1. Section 11 says "Theorem S is for one fault per round".
Corrected (results): "For any plain system at one fault per round, four conditions on the wiring are enough for no gap (Theorem S, section 10.1)." Corrected (README): "For any system of a stated class, at one fault per round, four conditions on the wiring are enough for no gap."

**L2. `results.md`, opening, lines 18 to 19. NARROWED.**
"Each such passage is marked."
Evidence: four marks exist (lines 552, 820, 1352, 1450). At least two argued passages in changed text carry none: the cost paragraph (lines 316 to 318, see L4) and "By the same counting the general number is `2f + 1`; that is not proved here" (lines 1082 to 1083), which is marked with other words.
Corrected: mark both. Line 1082: "By the same counting the general number is `2f + 1` (argued, not proved here)." Line 316: see L28.

**L3. `results.md`, section 1, lines 113 to 116, and section 10.3, lines 1130 to 1133. NARROWED.**
"In the implementations a halted member still watches, so the member that starts first is watched like any member, and it checks the others before it moves (section 10.3)." / "In an implementation where a stopped member still watches, that member is observed like any member and checks the others like any member: it starts with the others watching it, and only once it has checked them".
Evidence: section 10.3 shows "checks the others before it moves" for ghostunnel only (`observers/SPEC.md:556`, `:364-379`). The only Platform Racing 2 citation is `observers/README.md:94-95`, "the observers keep cycling". That a member starts only once it has checked the others is ghostunnel's rule and does not follow from stopped members still watching. The README (lines 457 to 459) already limits it correctly.
Corrected, lines 113 to 116: "Starting first does not mean starting unobserved. In both implementations a halted member keeps cycling. In ghostunnel's ring the member that starts first is therefore watched like any member, and it checks the others before it moves (section 10.3)."
Corrected, lines 1130 to 1133: "In ghostunnel's ring, where a stopped member still watches, that member is observed like any member and checks the others like any member: it starts with the others watching it, and only once it has checked them ("The implementation", below)."

**L4. `results.md`, section 2.7, lines 316 to 318; `README.md`, line 67. NOT CHECKABLE.**
"The cost of each ring is therefore fixed, and a ring costs no more as the system grows. The whole grows with the number of rings and with nothing else."
Evidence: nothing in the folder measures or models cost. The passage is argued and carries no mark (L2). Corrected wording under L28.

**L5. `results.md`, section 4, lines 406 to 411. WRONG, for the last clause under the new label.**
"**Checked.** … And R gives each work process a single state checker. One is enough at one fault per round, because a step against the checker is itself seen by the other two monitors; a higher tier would need more."
Evidence: the label is new and presents the paragraph as checked. The checker contradicts the last clause (`lc04`). R at `f` = 2 with every work process given all three monitors as halt sources and still one state checker has no gap (115 states). R at `f` = 2 with three state checkers each and two halt sources each still has G1 broken in two rounds and G2 in one. A mesh of three at `f` = 2, and of four at `f` = 2 and 3, with the work process checked by M1 alone, has no gap. Section 10.2 asks for `f + 1` monitors and `f + 1` halt sources, and for no number of state checkers.
Corrected: "**Checked.** The reference system of the next section shows the same in two more ways. Add a fourth monitor to it whose signal nobody reads, and at one fault per round there is still no gap. And R gives each work process a single state checker. One is enough, because a step against the checker is itself seen by the other two monitors. At two faults per round R fails through its halt sources and not through its single checker (section 5)."

**L6. `results.md`, section 5, lines 432 to 433. NARROWED.**
"In a second round the environment stops M2, no correct monitor is left flagged, and G1 is broken."
Evidence: M2 is correct, stopped and still flagged (nothing leaves `flagged`). G1 breaks because no live, correct monitor is flagged, which is how section 2.4 words it.
Corrected: "In a second round the environment stops M2, no live, correct monitor is flagged, and G1 is broken."

**L7. `results.md`, section 10.3, lines 1092 to 1094. NARROWED.**
"The round model's rule for silence is that nothing runs unobserved: a work process halts when a monitor it takes its halt from is silent. Apply the same rule to the observers themselves."
Evidence: the two rules differ in their quantifier. A work process halts when any one of its halt inputs is silent (`check_model.py:168-169`, specification 3.3). A member of the game stops only when every member that observes it has stopped (`check_model.py:720`). The difference decides the table. With the round model's quantifier, the ring of three with a coordinator that can start first cannot always restart: `stop X1` stops X2 and X3, and X1 then waits for X3 (`lc02`, part G).
Corrected: "The round model's rule for silence is that nothing runs unobserved: a work process halts when a monitor it takes its halt from is silent. The game applies that rule to the observers themselves in a weaker form: a member stops only when every member that observes it has stopped."

**L8. `results.md`, section 10.3, lines 1102 to 1103. NARROWED.**
"The Platform Racing 2 ring says the same of its observers (`PR2: observers/README.md:94-95`)."
Evidence: "the same" is "a halted member keeps cycling and keeps reading every other member". Lines 94 to 95 say "the observers keep cycling. What stops is the work." That every member watches every other is at `:23`, as a general statement.
Corrected: "The Platform Racing 2 README says that its observers keep cycling while the work is stopped (`PR2: observers/README.md:94-95`), and that every member watches every other (`:23`)."

**L9. `results.md`, section 10.3, the proof, lines 1140 to 1147. NARROWED (wording of two steps; the statement stands).**
"Suppose K reaches every member …" / "let U be the set of members K does not reach. Every observer of a member of U is itself in U, since a member observed by one that K reaches would be reached too. … none of them can start."
Evidence: K reaches itself only when a chain leads back to K, which fails in 32 of the 64 graphs and 1,200 of the 4,096. Read literally, "K reaches every member" is then false where the ring always restarts (K observing every member, nobody observing K), U contains K, and "none of them can start" is false of K. The reason given for closure also omits a member that K itself observes. With "every other member", U as the other members, and K added to the reason, every step holds for the game exactly as the script defines it (`lc02`, part E: first half 0 failures over every state with nobody blocked; second half 0 failures on all 32 and 1,664 graphs it applies to). The environment can reach the state the second half needs from the start: it stops the running members of U one at a time, and K and the members it reaches keep running.
Corrected: "*Proof.* Suppose K reaches every other member, and take any state in which the environment has released every member it stopped. K starts if it is not running. Each member K observes may then start, then each member those observe, and so on along every chain, until all are running. Now suppose some other member is not reached, and let U be the set of other members K does not reach. Every observer of a member of U is itself in U, since a member observed by K, or by a member that K reaches, is reached too. From the state in which all are running, the environment stops every running member of U and releases it. K and the members it reaches keep running, since each of them is K or has an observer among them. No member of U then has a running observer, so by the argument of Theorem R none of them can start. ∎"

**L10. `results.md`, section 10.3, lines 1149 to 1152. NARROWED (minor).**
"There are 64 and 4,096 such graphs, and none is an exception".
Evidence: `s02_sections_6_to_10.py` lines 368 to 389 and `s02_out.txt` lines 157 to 158 give exactly this, and this check reproduces it with the script's game and with a second implementation written from the text. The counts are of graphs in which no member observes itself, with the starter a fixed member. The statement also holds for every choice of starter (192 and 16,384 cases), with self-observation allowed (1,536 cases and 65,536 graphs), and on 4,000 and 1,500 random graphs of five and six members.
Corrected: "There are 64 and 4,096 such graphs in which no member observes itself, and none is an exception".

**L11. `results.md`, section 10.3, lines 1170 to 1173. NARROWED.**
"… and its heartbeat has advanced within the staleness bound (`:364-379`). So the coordinator stands down only when it has checked every member and found each one cycling."
Evidence: within the cited lines, V5 (`:374`) says that when the reader has no basis for a member "Nothing fails". On such a cycle (the first after the coordinator starts) only the absolute backstop V4b (`:370`) tests freshness, by the heartbeat's own timestamp. `:372` says a reader with no basis "cannot tell a live member from one that died an hour ago" without it.
Corrected: "Those assertions cover every other member: its store is readable, it is present, and its heartbeat is fresh. It has advanced within the staleness bound or, on a cycle in which the coordinator holds no earlier reading of it, it carries a timestamp within the absolute bound (`:364-379`). So the coordinator stands down only when it has checked every member and found each one's heartbeat fresh."

**L12. `results.md`, section 10.3, lines 1174 to 1175. NARROWED (citation).**
"a member that cannot read the coordinator holds a fault (`:364`), which blocks the stand-down (`:556`)."
Evidence: `:364` says the assertion `store-readable` fails. That a failing assertion makes the member publish a `fault` is at `:531-533`.
Corrected: "a member that cannot read the coordinator fails an assertion (`:364`) and so publishes a fault (`:531-533`), which blocks the stand-down (`:556`)."

**L13. `results.md`, section 12.1, lines 1319 to 1321. NARROWED.**
"the checker tested the structural forms of the four properties a plain system can lack: signal read, state check, propagation and halt sources."
Evidence: a plain system can also fail the P6 predicate of section 3.2. Where no two monitors share a boundary it is the same predicate as "every signal is read by another monitor": equal on all 7,024 generated systems, failing in 2,676 (`lc03`, part C). The census tests six predicates.
Corrected: "For each of those, the checker tested six predicates on signal reads, state checks, reports and halt sources. These are the structural forms of the properties a plain system can lack. The out-of-boundary predicate of section 3.2 is the same as the signal-read predicate where no two monitors share a boundary."

**L14. `results.md`, section 12.1, lines 1375 to 1376. NARROWED.**
"Its findings agree with the census at every size it decided, and its samples of larger systems agree too."
Evidence: the census covers two of the falsifier's five sizes. At two monitors the counts are identical (1,024; 12; 9 failing the report predicate). At three the census is a weighted sample: the report predicate fails in 378 of its 1,721 systems with no gap (22%) against 798,222 of 1,169,616 (68%). What agrees is the three findings in the bullets that follow.
Corrected: "At each of its five sizes it found what the census found at its two, and its samples of larger systems show the same."

**L15. `results.md`, section 13, line 1493. NARROWED.**
"ran the checker in full on the script as it stands".
Evidence: `sweep.md` S31 lists as faults the `is_plain` docstring and "G2 halt" in the module docstring. The current script has both corrected (`check_model.py:10`, `:500-501`) and is dated after the sweep's files. The code is unchanged: against the working copy the only differences are docstrings and one comment. This check's run of the current script reproduces the outputs.
Corrected: "ran the checker in full on the script as it then stood; its docstrings were edited afterwards, in answer to the sweep".

**L16. `results.md`, section 13, lines 1537 to 1541. NARROWED.**
"The reconciler left three points for the author, and each was settled from the two public repositories: … and which kinds of fault the four constraints assert (section 7)."
Evidence: `reconciliation.md` R44 asks "where the framework's text asserts" boundary loss and joining. Neither implementation file this check may read states the four constraints. Section 7 settles the point by assigning those two faults to the systems being modelled.
Corrected: "The reconciler left three points for the author. Two were settled from the two public repositories: the line in the second implementation that says every member watches every other, and that the commits cited are the heads of the public branches. The third, which kinds of fault the four constraints assert (section 7), was settled from the framework's statement of the constraints."

**L17. `results.md`, section 13, lines 1566 to 1568. NARROWED.**
"In the final round the verifiers checked each against the script, and the reconciler and the sweep recomputed each."
Evidence: `findings-forward.md` F18 says "The threshold `k` is in neither `model-spec.md` nor `check_model.py`". The verifiers checked the second face of P2 against the definition of `fail-substrate`, and the reconciler recomputed it in a threshold model of its own (`reconcile/r08.py`).
Corrected: "In the final round the verifiers checked the restart result and the two-tier case against the script, and the second face of P2 against the definition of `fail-substrate`, since its threshold is in neither the specification nor the script. The reconciler and the sweep recomputed each."

**L18. `README.md`, "The run", lines 246 to 247. NARROWED.**
"No pass found a result of the checker wrong: every correction was to the wording around a result."
Evidence: the sentence closes a list of all six passes. Pass B found four defects in the script, which the author fixed (`results.md` lines 1510 to 1512). One of them, D2, changed a printed line of output section 3 ("Breaks nothing" was printed for a round that should not have run). `results.md` lines 1496 to 1499 limits the claim to the two verifiers and the sweep, which their reports support.
Corrected: "No pass of the final round found a result of the checker wrong: every correction it led to was to the wording around a result."

**L19. `results.md`, section 9, lines 924 to 925; `README.md`, line 352. NOT CHECKABLE.**
"The module has not been run through TLC. The author produced the trace by hand" / "The author traced the TLA+ module by hand".
Evidence: no artefact records either. The checker's copy (8 states; the seven-state trace) is confirmed. No change needed.

**L20. `results.md`, section 13, line 1478; `README.md`, line 208. NOT CHECKABLE.**
"ran on one model, Claude Fable 5.2".
Evidence: no file in the folder records a model. No change needed.

**L21. `results.md`, section 13, line 1574; `README.md`, lines 261 to 262. NOT CHECKABLE.**
"The author then read every line it cites" / "and changed nothing else in those folders."
Evidence: no artefact records either. No absolute path remains (L23). No change needed.

**L22. `check_model.py`, docstrings (item 14). Three small disagreements; not counted in the tables.**
- Line 405: "a coordinator K with a surface view". `results.md` line 990 dropped that term. Corrected: "Three mutually checking monitors plus a coordinator K that reads their signals and flags and checks no state."
- Lines 18 to 19 (and `README.md` lines 437 to 438): `--traces` "also print the shortest execution that breaks each goal". The option also prints the ten replayed executions, as `results.md` lines 1592 to 1594 says. Corrected: "also print the ten executions of the write-up and the shortest execution that breaks each goal".
- Line 599: "All of them when count is None". The generator leaves out self-edges. Corrected: "All of them without self-edges when count is None".
The other docstrings and comments agree with the code and with the documents.

**L23. The whole folder (item 15). No finding.**
No local absolute path, user name or email address in any file, the four reports included. Three things for the author to judge. The reports carry relative names of working folders (`shared-templates\`, `formal-model\`, `final-round\backward\`). `reconciliation.md` line 91 says the session's notes record commit `0741dac9` as "a local merge commit not pushed as of 2026-10-26", beside documents that give that commit as public. `sweep.md` line 312 names `readme.diff`, `results.diff` and `tla_listing.txt`, and line 299 says each script has its output beside it; those three files and the outputs of `s07`, `s11` and `s12` are not in `sweep/`.

## Part 2: writing rules

The mechanical scan of all changed lines is clean: no em dash, no first person, no "in order to", no listed filler, no sentence starting "This is" or "That is", no capitals for emphasis. "Now suppose" (line 1143) is proof wording, and "at the time" (line 1505) is in a passage that records.

**L24. STYLE. `results.md`, lines 23 to 26; `README.md`, lines 15 to 18.** One sentence of about 55 words: "Under the four constraints, and against every kind of fault in the model, a reference system that has the eight properties, and whose work runs only on a current observation, has no gap at one fault per round, and none of the eight can be removed from it without opening one."
Corrected: "The setting is the four constraints and every kind of fault in the model. A reference system that has the eight properties, and whose work runs only on a current observation, has no gap at one fault per round. None of the eight can be removed from it without opening one."

**L25. STYLE. `results.md`, line 27; `README.md`, line 19.** "The properties are meant by what they do". Not idiomatic. Corrected: "Each property is defined by what it does (section 3.1)."

**L26. STYLE, restating. `results.md`, lines 41 to 43.** "follow from them: they are emergent, and they are not extra constraints." Three wordings of one statement. Corrected: "The framework holds that the properties, and the further requirements found below, follow from them and are not further constraints."

**L27. STYLE, passive with a named actor. `results.md`, lines 81 to 83.** "The other half, that these kinds of fault exist, is asserted in part by the four constraints and is otherwise a claim about the systems being modelled (section 7)." Corrected: "The four constraints assert part of the other half, that these kinds of fault exist. The rest is a claim about the systems being modelled (section 7)."

**L28. STYLE, restating, and no kind of evidence. `results.md`, lines 316 to 318; `README.md`, line 67.** "The cost of each ring is therefore fixed, and a ring costs no more as the system grows." The second clause repeats the first.
Corrected (results): "Growth adds rings and levels and never makes a ring larger. **Argued.** The cost of each ring therefore does not rise as the system grows, and the cost of the whole grows with the number of rings and with nothing else."
Corrected (README): "set by the substrate, and no higher for a ring as the system grows, because growth adds rings and never makes a ring bigger. The whole grows with the number of rings and with nothing else".

**L29. STYLE, restating. `results.md`, lines 1128 to 1129.** "Recovery needs one member that the rule does not bind: it may start, and keep running, while no other member of its ring is running." Lines 1114 to 1115 give the same definition fourteen lines earlier. Corrected: "**What the theorem forces.** Recovery needs one member that can start first. The theorem forces that difference and no other."

**L30. STYLE, passive where the actor is the author.** The bullets "From A" and "From B" were made active; these were not.
- `results.md` line 1470: "The gate's was added after B's pass." Corrected: "The author added the gate's after B's pass."
- Lines 1522 to 1527: "Five statements were wrong and were corrected" / "The narrowed claims were given the conditions they hold under." Corrected: "The author corrected five wrong statements" / "The author gave the narrowed claims the conditions they hold under."
- Line 1537: Corrected: "The author gave the comparison of section 10.5 a citation for every line it relies on."
- Lines 1558 to 1560: Corrected: "The author added a fourth kind of evidence, argued, at the head of this note and marked the passages of that kind. The author applied the sweep's entries on style and sense, two of them in part".
- Lines 733 to 734: "These last two faults were introduced to express a property." Corrected: "The model introduces these last two faults to express one property each."
- `README.md` line 221: Corrected: "The author fixed the four that were defects in the script's code."
- Lines 240 to 241: Corrected: "The author applied all of its rulings and edited some of the wordings it gave further."
- Lines 244 to 245: Corrected: "The author applied its corrections, and a last agent checked the passages they changed".

**L31. STYLE, long list sentences with unlike members. `results.md`, lines 1522 to 1526 and 1542 to 1546.** Each runs to about 60 words, and the second mixes a clause ("that every property is needed …") with noun phrases ("the number of …"). Make each a list, as was done for "The chief ones". For the second: "Five statements were wrong, four of them in text the correction had added:" then "- the claim that every property is needed against "no impact" alone (P6 is the exception);" "- the number of schedules in the checker given to B;" "- the number of statements the earlier passes had found wrong;" "- in both documents, the number of rulings the reconciler marked unsafe."

**L32. STYLE, kind of evidence. `README.md`, line 327, against `results.md`, lines 13 to 15.** "**Checked, exhaustively, by an independent agent.**" The head of the note defines Checked as explored "by `check_model.py`". This result comes from the falsifier's own deciders, and its last row from counting. Corrected, `results.md` lines 13 to 15: "**Checked.** Every reachable state of a small, fully specified system was explored by `check_model.py` or, where the text says so, by a verifier's own decider. The result is complete for that system and says nothing about any other."

## Part 3: sense

**L33. SENSE, contradiction. `results.md`, section 7, lines 711 to 713 against the table, lines 695 and 699.** "Five are also proved for every system of a class: P3 for monitors, P5 in its rate form, P6, P8 and P8b". The table's Evidence cell for P6 says "checked" only, and its cell for P2 says "proved from two executions". By the table the five would be P2, P3, P5, P8 and P8b.
Corrected, line 699, Evidence cell: "checked; proved for every system in which one step stops every monitor (section 2.7)". Corrected, lines 711 to 713: "Five are also proved for every system of a class in the round model: P3 for monitors, P5 in its rate form, P6, P8 and P8b (sections 2.7 and 6). The second face of P2 is proved in a model with a threshold, outside the round model."

**L34. SENSE, term never defined. `results.md`, section 10.3, lines 1122 and 1137 to 1138.** "can always restart" is the result of the table and the conclusion of the proved statement, and is defined nowhere. In the script it means: no state the environment can bring about, with nobody held stopped, from which "all running" cannot be reached without a further stop.
Corrected, to add at line 1116: "A ring *can always restart* if, from every state the environment can bring about, once it has released every member it stopped, the members can start one after another until all are running."

**L35. SENSE, terms used before they are defined. `results.md`, lines 47 to 50; `README.md`, line 17.** The paragraph that defines "gap" and "tier" stands after their first uses (lines 25, 35 and 45). The README uses "gap" and "round" in "The result" and defines "gap" at lines 190 to 191.
Corrected (results): move lines 47 to 50 to stand before "**The result.**" Corrected (README), to add after the first sentence of "The result": "A gap is an execution in which a bad state goes unflagged or work acts while a state is bad. A round is one check by every observer."

**L36. SENSE, the README against `results.md`. `README.md`, line 46.** "Two further requirements have names in what follows." `results.md` lines 36 to 37 calls the halt fan-out "the halt fan-out clause of the eighth taken separately", and the README's own row for P8 includes "outpaces the fault". Only the gate is outside the eight (`results.md` line 62).
Corrected: "Two requirements have names of their own in what follows. The *gate*, which the eight do not name: the observers check before any work is done, so work runs only on a current observation. The *halt fan-out*, a clause of P8 taken separately: work takes its halt from at least two observers, and a halt is passed on to at least two more."

**L37. SENSE, the README says more than `results.md` supports. `README.md`, lines 58 to 60.** "A bug shipped in a release is stopped the same way as a compromise. Its only effect in production is the halt itself". The paragraph above it bounds impact by one check interval, and `results.md` section 11 says the impact before response is "bounded by the cadence, not zero". A bug that passes every check is not stopped (the inward side of the edge). "Its" has two possible referents.
Corrected: "A bug shipped in a release that makes a checked state bad is stopped the same way as a compromise. The bug's effect in production is bounded by one check interval, and after that it is the halt itself, on the rule that stopping completely is better than running unverified."

**L38. SENSE. `README.md`, lines 198 to 199.** "An agent started fresh for the purpose checked each phase up to the falsifier search. It was given only the artefacts". This reads as one agent for all phases. Corrected: "A separate agent, started fresh for the purpose, checked each phase up to the falsifier search. Each was given only the artefacts: the specification, the cases, the code, or a claim as a bare statement."

**L39. SENSE, shifting referents. `README.md`, lines 219 to 225.** "It listed eight deviations" follows a sentence whose subject is the checker. "its code" is the script's and "Its own implementation" is the reviewer's. Three of the eight deviations are unaccounted for (D6 to D8).
Corrected: "*Review (B).* The reviewer compared the checker with the specification clause by clause and found no deviation in the model. The review lists eight deviations at the edges of the script. The author fixed the four that were defects in the script's code. One, that the script does not validate its input, stands. The other three concern the docstring and parts of the script that the specification does not cover. The reviewer's own implementation agrees with the checker on 94 cases, 1,648 random systems and 600 variants of the reference system."

**L40. SENSE. `README.md`, design notes, lines 377 to 378 and 410 to 418.** The preamble says the notes "follow from the results"; note 10 says it "goes beyond what was checked". In note 10, "the handover", "the switch", "the old observation" and "the chain" appear with nothing said about what is handed over, and the title speaks of bringing a member in. "Every property holds for the whole of the switch" is stated as fact in a note that says it was not checked, and "No member is left unobserved at any point" repeats part of it.
Corrected, preamble: "These follow from the results, except where a note says otherwise, and are not results themselves."
Corrected, note 10: "**Bring a new ring member in through the checks the ring already runs.** Members already check each other's health. The observers that know of the new member watch it from the start, and check in each cycle whether it has come up. Where the new member takes over from an old one, the old one keeps observing until the new one is running, healthy and sending its reports. The observers that have been watching for that change then switch to the new member and drop the old one last. While the two overlap the ring has more observers than it needs and loses none, so no member is left unobserved at any point. The model check covers a work process joining and does not model a ring member joining, so this note goes beyond what was checked."

**L41. SENSE, tension with the results and with note 9. `README.md`, note 11, lines 419 to 424.** "Nothing depends yet on a member that has never run: it is a join in progress". `results.md` line 1226 reports that in ghostunnel "a declared member with no store halts the ring", and `observers/SPEC.md:266` says such a position "reads as a member that never ran, and halts the ring". Under note 9, work that finds no observers refuses to run, and at a cold start no member has ever run.
Corrected: open the note "**In a running ring, tell a member that has never run from one that has stopped running.**" and add at its end: "At a cold start no member has run, and the work refuses as in note 9. A declared membership in which any absence halts, as in ghostunnel's ring (section 10.5 of `results.md`), is the stricter choice."

**L42. SENSE, distant referent. `results.md`, lines 1470 to 1471.** "The final round was given this note and the README, which hold all three." The three are named three sentences earlier. Corrected: "The final round was given this note and the README, which contain the author's reasoning, expected results and proofs."

**L43. SENSE, term used before it is explained. `results.md`, line 1490.** "as they stood before the correction". Nothing before the table says what "the correction" is. Corrected: "this note, the README and the folder, as they stood before the reconciler's rulings were applied (the correction)".

**L44. SENSE, minor. `results.md`, lines 271 to 273.** "loses every monitor to that one step, and G1 can then be violated in two rounds." This can be read as two further rounds; the search gives two in all. Corrected: "loses every monitor to that one step, and G1 is violated in the round after it, two rounds in all."

**L45. SENSE, minor. `README.md`, lines 299 to 300.** "a work process acts while a state is bad at least once." Under "Proved" this reads as true of every execution; the proofs show that the environment can bring it about. Corrected: "With an evaluation window, or without the gate, in any system with a work process present from the start, the environment can make a work process act while a state is bad."

## Counts

A claim is one checkable statement, one table row or one citation in a changed or added passage. A claim in both documents is counted in each. STYLE and SENSE are counts of entries that touch the document.

| Document | Examined | CONFIRMED | NARROWED | WRONG | NOT CHECKABLE | STYLE entries | SENSE entries |
|---|---|---|---|---|---|---|---|
| `results.md` | 173 | 151 | 16 | 1 | 5 | 9 | 6 |
| `README.md` | 79 | 74 | 2 | 0 | 3 | 5 | 8 |
| Both | 252 | 225 | 18 | 1 | 8 | 9 distinct | 13 distinct |

Entries: L1 to L3 and L6 to L18 NARROWED; L5 WRONG; L4 and L19 to L21 NOT CHECKABLE; L22 and L23 on the script and the folder, not counted; L24 to L32 STYLE; L33 to L45 SENSE.

**Full run.** One run of `python -I -B check_model.py --json results.json --systems systems-all.json` from the scratch folder (Python 3.12.2, exit 0, nothing on standard error) produced output and two JSON files byte for byte the same as `run-output.txt`, `results.json` and `systems-all.json`, the two final lines included, since the same file names were used.

**The proof in section 10.3.** The statement is true of the game exactly as `restart_game` defines it. It holds with no exception on all 64 and 4,096 graphs, for every choice of the starting member, with self-observation allowed, and on samples of five and six members, under both the script's game and a second implementation. Each step of the proof holds once "every member" and U are read as the other members and K itself is added to the closure step (L9), and once "can always restart" is defined (L34). The setting's claim to apply "the same rule" as the round model is not accurate, and the table's third row depends on the weaker rule the game uses (L7).

**Scripts**, all in `last-check/`, each with its output beside it:
- `lc01_sections_1_to_8.py`: the ring of three against every section 3.2 predicate, the ten removals, the scope cases, the `f` = 2 execution, P8b, the table replays, the reflex table, the three growth bounds, the coordinator row and the meshes.
- `lc02_restart.py`: the four rings, the statement of section 10.3 on every graph of three and four members and on samples of five and six, with a second implementation of the game, each step of the proof, and the round model's rule in place of the game's.
- `lc03_census_and_misc.py`: how the census was drawn, the P6 predicate on plain systems, Theorem S at `f` above 1, pass A's result files against `results.json`.
- `lc04_single_checker.py`: a single state checker at two and three faults per round.
- `lc05_tla_listing.py`: the listing of section 9 against `Heartbeat.tla`.
- `lc06_changed_lines.py`: every changed line with its current line number, and the mechanical scan for the writing rules.
- `lc07_b_defects.py`: pass B's four fixed defects and the one left standing, on the current script.
- `fullrun/`: the output and the two JSON files of the full run. `my-results.diff` and `my-README.diff`: the two diffs regenerated.
