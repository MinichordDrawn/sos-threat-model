# Final round: sweep

*Saved by the main session from the sweep's hand-back, word for word, except that one local
path is replaced by a relative one. The pass could not write a report file itself.*

# Final sweep of `model-check/README.md` and `results.md`

## Outcome in brief

- The checker's results stand. My full run of the current `check_model.py` reproduced `run-output.txt`, `results.json` and `systems-all.json` byte for byte (Python 3.12.2, 318 s). Every number in sections 1, 4, 5, 6, 7, 8, 9, 10 and 12 that comes from the checker recomputes.
- I found 5 wrong statements, 37 narrowed ones and 5 not checkable. Four of the five wrong ones are in text the correction added.
- The most important findings: S1 (a sentence in section 1 contradicted by section 6), S5 (the headline result is wider than what the folder shows), S6 (the final round read the documents before the correction, so about half the README and several passages of the note have been checked by this sweep alone), S7 (the recast of section 10.3 departs from what the checker's restart game runs).
- Public-repository check: no local absolute path, user name or email anywhere in the folder.

What I recomputed and found correct, with my own scripts: all ten removals and their executions; R at `f` = 1, 2, 3; the two-tier table; the scope cases of 2.7; the reflex table and the hop count `d` on 20,000 random systems (0 mismatches); every growth figure and bound, the `n` = 8 example and the fifth-to-two-fifths range; the TLA+ mirror; 72 = 31 + 14 + 27; 23 of 55 with the edge lists; the mesh grid; the restart table; 18 of 27; the census counts 289, 243 and 46; pass A's code on all 103 cases (0 mismatches) and its eight variant readings; pass B's 400-system trial (400 of 400, eight removals); the falsifier's row for three monitors and one work process with a decider of my own, validated against `explore` (16,777,216 systems, 1,169,616 with no gap, 178,176, 798,222, 742,352 and 515,030, all exact). I read every cited line of the two implementations. Every citation resolves and every quotation is exact.

---

## Part 1: facts

### WRONG

**S1. `results.md`, section 1, item 1, line 44.** "Judged against "no impact", every one of the properties is needed."
Evidence: `explore(reference(without=("P6",)))` gives G1 = 2 and G2 = none over 239 states. Section 6 says the same ("Breaks G1. G2 holds in every reachable state") and so does the section 7 table. Judged against no impact alone, P6 looks unnecessary in R.
Corrected: "Judged against "no impact", every property but P6 is needed. Removing P6 leaves the work halted and breaks detection only (section 6). Judged against detection alone, P4 and P8 would look unnecessary: without either, G1 holds in every reachable state of R. Both judgements are needed to show all ten removals."

**S2. `results.md`, section 13, lines 1416 to 1417.** "The checker given to B carries its own comments and the ten schedules of section 6."
Evidence: `verification/b-review/check_model.py`, lines 525 to 535: `CANONICAL` has nine entries, P1 to P8b. `PROPS` there has no "gate". The gate was added after B.
Corrected: "The checker given to B carries its own comments and nine of the ten schedules of section 6. The gate's was added after B's pass."

**S3. `results.md`, section 13, lines 1461 to 1464.** "Four statements were wrong and were corrected: the Python version …, a path …, a quotation …, and the claim that a halt reaching good processes first is the worst order."
Evidence: the two verifiers marked five distinct statements WRONG between them. Forward: F10 (Python), F22 (worst order), F25 (path). Backward: B51 (Python), B30 (path), B22 (quotation), B40 (the heading "3.1 Three layers" above a table of four layers). All five were corrected; the heading is missing from the list.
Corrected: "Five statements were wrong and were corrected: the Python version the script needs, a path to a verifier's file, a quotation from the implementation's specification with one word too many, the heading of section 3.1, which named three layers above a table of four, and the claim that a halt reaching good processes first is the worst order (section 8.2)."

**S4. `results.md`, section 13, line 1438; `README.md`, lines 205 to 206.** "Three of the verifiers' own corrections would have put an error into the text." / "It found three of the verifiers' own corrections unsafe".
Evidence: `reconciliation.md` says "three" in its opening line, but the mark **[correction unsafe]** stands in four rulings: R6 (B33's wording), R28 (both F19's and B36's), R34 (F24's), R47 (B14's). That is five proposed corrections in four rulings.
Corrected (results): "It marked four rulings in which a verifier's own correction would have put an error into the text (R6, R28, R34, R47)." Corrected (README): "It marked four rulings in which a verifier's own correction was unsafe, and raised nine further points."

### NARROWED

**S5. `results.md`, section 1, lines 21 to 25; `README.md`, lines 15 to 17.** "a system that has the eight properties, and whose work runs only on a current observation, has no gap, and none of the eight can be removed."
Evidence: the folder shows this for R at `f` = 1 (checked) and, for plain systems, under the four conditions of Theorem S. It does not hold for the eight as section 3.2 writes them. `ring(3, "same", 2)` satisfies every predicate of the section 3.2 table and the gate, and has G2 broken in one round and G1 in three (section 6, P4, uses this system). In the author's own census sample, 29 of the 1,297 three-monitor systems that satisfy all four graph predicates have a gap. R itself has a gap at `f` = 2. New text, not seen by the final round.
Corrected (results): "**The result.** Under the four constraints, and against every kind of fault in the model, a reference system that has the eight properties, and whose work runs only on a current observation, has no gap at one fault per round, and none of the eight can be removed from it without opening one. For any plain system, four conditions on the wiring are enough for no gap (Theorem S, section 10.1). The eight written as predicates (section 3.2) are not enough alone: a ring of three in which each monitor reports to the monitor it checks satisfies them all and has a gap (section 6, P4). No kind of fault was found that the eight do not answer. The claim stands until one of the framework's falsification criteria is met (section 12)." Use the same text in the README, with "section 10.1 of `results.md`".

**S6. `results.md`, section 13, lines 1436 to 1437; `README.md`, lines 171 to 172 and 197 to 198.** "checked every claim against the folder" / "Two verifiers checked every claim in this page and in `results.md`".
Evidence: both reports state the versions they read: the note at 1,330 lines (75,839 bytes) and the README at 10,236 bytes (178 lines). The note is 1,504 lines and the README 400. None of these phrases occurs in any of the three reports: "against every kind of fault", "What is checked", "met from three sides", "binds a bad work process", "start first", "in this one respect", "stands down only when", "Growth adds rings", "Level of assurance", "Design notes".
Passages only this sweep has checked: in the note, "The result"; assumption 7 of 2.5 (confirmed against specification 3.3); Theorem 0 part 3 (confirmed against specification 3.2: detection has exactly those two clauses, and `flagged` grows only from a detection); "One edge, met from three sides" and the cost paragraph of 2.7; "The coordinator, as a role" in 10.2; section 10.3 in its "start first" form; the final-round text of section 13. In the README: "The result", all of "Overview", "The run", "Design notes", "A reference system, and the skill", "Licence", and the reworded bullets of "What is established".
Corrected, to add after the table in section 13: "The two verifiers and the reconciler read the documents as they stood before the correction, when the README had 178 lines and this note 1,330. The correction added passages none of them saw. The sweep is the only pass that has checked those." README line 171: "All of them were covered by the final round, which checked every claim in both documents as they then stood."

**S7. `results.md`, section 10.3, lines 1065 to 1069, 1084 to 1085, 1097 to 1103.** "Each member of a ring is *running* or *stopped*. It runs only while at least one member that observes it is running." / "A member *can start first* if its start does not wait for another member to be running." / "That member differs in kind from the rest in this one respect and in no other. … If they are not there to watch it, it does not start."
Evidence: in `restart_game` a self-starting member is exempt from the rule throughout. `settle` never stops it, so it keeps running while no member that observes it is running (after stopping X1, X2, X3, K alone is running). It also starts unconditionally. I ran the variant the text describes, in which K may start first but is otherwise bound by the rule: the ring of four then cannot restart after "stop X1, release X1, stop K, release K" (`s07_restart_variant.py`). So the table's third row holds only with the wider exemption. The last two quoted sentences describe the ghostunnel implementation, not the game. The text before the correction matched the checker ("the coupling rule does not bind it"). New text, not seen by the final round.
Corrected, line 1084: "**Checked.** A member *can start first* if the rule above does not bind it: it may start, and stay running, while no member that observes it is running. In the game it starts unconditionally."
Corrected, lines 1097 to 1103: "**What the theorem forces.** Recovery needs one member that the rule does not bind: it may start, and keep running, while no other member of its ring is running. The theorem forces that difference and no other. In an implementation where a stopped member still watches, that member is observed like any member and checks the others like any member: it starts with the others watching it, and only once it has checked them ("The implementation", below)."
The checker's docstring and output say "self-starting" and "starts by itself"; see S31.

**S8. `results.md`, section 10.3, lines 1127 to 1128.** "So the coordinator stands down only when it has checked every member and every member is up and reading it."
Evidence: `SPEC.md:556` makes the stand-down wait on no fault at any root and on none of the coordinator's own assertions failing. `:364-379` make those assertions cover every other member's store, presence and freshness. So "has checked every member" and "every member is up" are supported. "Reading it" rests on `:28` and `:184`, which say what a cycling member does. The coordinator's assertions do not test it: `I1(b)` (`:454`) judges only non-null `observed` values. What binds is indirect: a member that cannot read the coordinator fails `store-readable` (`:364`), holds a fault, and `:556` then blocks the stand-down. The sentence holds for members that follow the specification.
Corrected: "So the coordinator stands down only when it has checked every member and found each one cycling. By the specification a member that is cycling reads the coordinator in every cycle (`:28`), and a member that cannot read it holds a fault (`:364`), which blocks the stand-down (`:556`). The coordinator's own assertions do not test that each member has read it."

**S9. "In both implementations", without a citation for the second. `results.md`, lines 1072 to 1073 and 736 to 737; `README.md`, lines 264 to 266.**
Evidence: section 10.3 cites ghostunnel only. For Platform Racing 2, "observers keep cycling" is at `PR2: observers/README.md:94-95`, uncited. Nothing I may read there shows that its coordinator checks every other member before it clears. For line 736, the PR2 gate's read of each member's own fault is `PR2: common/observer_gate.php:383`, cited in 10.1 and not in 10.5, where the sentence points.
Corrected, line 1072: "Whether it still watches is outside the game. In ghostunnel's ring it does: a halted member keeps cycling and keeps reading every other member. The Platform Racing 2 ring says the same of its observers (`PR2: observers/README.md:94-95`)."
Corrected, line 736: "Both implementations are wired this way: the gate reads every member's own fault record, not only a relayed one (`observers/SPEC.md:827`, `:831`; `PR2: common/observer_gate.php:383`)."
Corrected, README 264: "Starting first does not mean starting unobserved: in both implementations a stopped member still watches, and in ghostunnel's the coordinator starts only after it has checked every other member."

**S10. `results.md`, section 13, lines 1414 to 1416; `README.md`, lines 176 to 179.** "Each was given only the artefacts to check … and never the author's reasoning, expected results or proofs."
Evidence: the same table says the final-round passes were given "this note, the README and the folder", which hold all three. The README applies the sentence to all six passes and omits the caveat about B that the note carries.
Corrected (results): "Passes A to F were each given only the artefacts to check, in a folder of its own, and never the author's reasoning, expected results or proofs. The final round was given this note and the README, which hold all three." Corrected (README): "Passes A to F were given the artefacts to check and never the author's reasoning, expected results or proofs; the checker given to B carries its own comments and nine of the ten schedules. The final round was given the two documents and the folder."

**S11. `results.md`, section 1, item 5, lines 68 to 69.** "The other half, that these kinds of fault exist, is what the four constraints assert".
Evidence: section 7 (lines 696 to 703) and the README (232 to 235) were corrected to "Part of it is what the four constraints assert … The rest is a claim about the systems being modelled". Item 5 was left as it was and contradicts both.
Corrected: "The other half, that these kinds of fault exist, is asserted in part by the four constraints and is otherwise a claim about the systems being modelled (section 7). No checker can supply it."

**S12. `results.md`, section 5, lines 408 to 410.** "With `f` = 2 both can: the environment mutates M1 and M3 in one round, M2 flags, W2 halts, and W1 … keeps working."
Evidence: that execution breaks G2 only. G1 breaks in a second round, when the environment stops M2 (search: G1 = 2, G2 = 1).
Corrected: "With `f` = 2 both can. The environment mutates M1 and M3 in one round, M2 flags, W2 halts, and W1, whose two halt sources are the two mutated monitors, keeps working: G2 is broken in one round. In a second round the environment stops M2, no correct monitor is left flagged, and G1 is broken."

**S13. `results.md`, section 6, P8b, line 623.** "W1 never halts, so the model runs on".
Evidence: replay of "mutate M1" then "stop M1" (or "fail-substrate s1") in R without P8b: W1 halts on M1's silence and the model ends. New text.
Corrected: "W1 does not halt while M1 stays alive, so the model runs on, and the search finds G1 broken in three rounds: mutate M1, then stop M2, then stop M3."

**S14. `results.md`, section 7, lines 684 to 685.** "The necessity of those eight is not peculiar to the reference system. It holds for any system."
Evidence: the support is B's argument from each step's definition and a trial on 400 random systems per removal (rerun here: 400 of 400). A random trial is none of the three kinds of evidence. Five of the eight are proved for a class elsewhere in the note.
Corrected: "The necessity of those eight is not peculiar to the reference system. The reviewer argued from the definition of each step that the gap exists in any system that lacks the property, and found it in every one of the 400 random systems tried for each. Five are also proved for every system of a class (P3 for monitors, P5 in its rate form, P6, P8 and P8b; sections 2.7 and 6)."

**S15. `results.md`, section 12.1, lines 1266 to 1270; `README.md`, lines 287 to 289.** "Every system with two monitors and one work process (1,024 of them), and a sample of 4,890 with three monitors … the structural form of each property was tested."
Evidence: the 1,024 are plain systems without self-edges (`small_systems`; the output heading says "plain"). The 4,890 are the distinct systems among 6,000 draws, half uniform and half a full mesh with up to six edges removed. That is why 35% of them have no gap against 7% in the falsifier's exhaustive row. Only four properties are tested, by six predicates.
Corrected: "**Checked: a census.** Every plain system with two monitors, one work process and no self-edges (1,024 of them), and 4,890 distinct plain systems with three monitors, at one fault per round. The three-monitor systems come from 6,000 draws, half uniform and half a full mesh with up to six edges removed, so that enough of them have no gap. 12 and 1,721 of them have no gap. For each of those, the structural forms of the four properties a plain system can lack were tested: signal read, state check, propagation and halt sources." README: "Every plain system with two or three monitors and one or two work processes was decided at one fault per round, …".

**S16. `results.md`, line 1338; `README.md`, line 295.** "A bad state stops the work in the round it appears, which is what no gap means."
Evidence: in the checker, no gap means neither judgement can be violated, so the bad state is also flagged in that round (`gap_free`). The sentence gives the G2 half. "Gap" is defined nowhere else in the note (S43).
Corrected: "A bad state is flagged and stops the work in the round it appears, which is what no gap means in these systems."

**S17. `results.md`, section 13, line 1431; `README.md`, lines 183 to 185.** "for two points it ran no alternative".
Evidence: `report-a.md` lists ten points. Alternatives were run for five (points 1, 2 and 5, and addendum points 1 and 2; my rerun of its `VARIANTS` on all 103 cases changes one result, under the excluded reading). For five none was run: points 6 and 7 ("No alternative tested"), point 3 (argued to be unable to change a result), point 4 and addendum point 3 (no case contains the input).
Corrected: "The alternative readings it ran, for five of the ten points, changed no result, apart from one reading the text excludes. For the other five it ran none: two it left untested, one it argued cannot change a result, and two concern inputs that no case contains."

**S18. `README.md`, lines 186 to 187.** "no deviation in the model, and four defects in the script, all fixed."
Evidence: `findings-b.md` 1.5 lists eight deviations, D1 to D8. D1 to D4 are fixed in the current script. D5 (no validation of input: any non-zero `window` acts as 1, `f` = 0 is accepted) stands. D6 to D8 concern the docstring and what lies outside the specification. The note's wording ("Four defects in the script were fixed") is correct.
Corrected: "no deviation in the model. It listed eight deviations at the edges of the script. The four that were defects in its code were fixed. One, that the script does not validate its input, stands."

**S19. `README.md`, lines 192 to 194.** "All fifteen hold. Two needed a wording fix".
Evidence: three claims took one of two fixes: C4 ("two different halt inputs"), E2 and E3 ("present from the start"). E also made E1, E5 and E6 depend on a reading, and D did the same for C9.
Corrected: "All fifteen hold under the reading each prover chose. Three needed one of two wording fixes, and D returned sharper growth bounds than the ones claimed."

**S20. `README.md`, lines 112 to 114.** "an agent given only that file reimplemented it and reproduced every result."
Evidence: A was given the specification, an addendum and the cases, and reproduced G1 and G2 for the cases (101 itself, two by its code afterwards). The growth process, the restart game and the TLA+ module are not in `model-spec.md` and A did not reimplement them.
Corrected: "precisely enough that an agent given only the specification and the cases reimplemented it and reproduced the result of every case. The growth process, the restart game and the TLA+ module are separate small models, stated in `results.md` and in the checker."

**S21. `README.md`, lines 218 to 220.** "Each folder under `verification/` holds the specification as it stood when that pass ran. The copies for A, B and D differ slightly".
Evidence: `g-final-round/` holds no copy. The A, B and D copies (identical to each other) lack section 3.6 and the fields `gate` and `slow_reports`, plus eight clarifications; A has the two fields as `spec-addendum.md`.
Corrected: "Each folder under `verification/` but that of the final round holds the specification as it stood when that pass ran. The copies for A, B and D lack section 3.6 and its two fields (A has them as `spec-addendum.md`) and eight later clarifications; those for E and F are identical to `model-spec.md`."

**S22. `README.md`, line 206.** "All of its rulings were applied."
Evidence: of the 50 wordings the reconciler gave, 35 are in the documents word for word. Fifteen were edited further (`s10_rulings_applied.py`), among them R8 (limited to ghostunnel by the reconciler; the documents say "both implementations", now with a correct PR2 citation), R37 ("start by itself" became "start first") and R27.
Corrected: "All of its rulings were applied. Fifteen of the fifty wordings it gave were then edited further, among them the recast of the member that "starts by itself" as the member that "can start first"."

**S23. `README.md`, "Proved, for every system of a stated class", lines 258 to 259 and 262 to 266.**
(a) "With an evaluation window, or without the gate, a work process acts on a bad state at least once." The class is missing. E2 and E3 hold only with a work process present from the start. Corrected: "With an evaluation window, or without the gate, in any system with a work process present from the start, a work process acts while a state is bad at least once."
(b) "every other member must be reached from it" stands under "Proved"; the note's table in 10.2 says "the second argued". My exhaustive check supports the statement: over all 64 and all 4,096 observer graphs on three and four members with one member that can start first, the ring can always restart exactly when every other member is reached from that member (0 disagreements). The sentence about the implementations is a reading of a specification and is not proved. Corrected: "**Theorem R.** Members that start only once another member has started cannot restart from a full stop, so one member must be able to start first. That every other member must be reached from it is argued in section 10.3 of `results.md` and checked on small rings." Move the sentence on the implementations to "The implementations", worded as in S9.

**S24. `results.md`, section 10.5, lines 1175 to 1177.** "all on one host (`:911`)" and "the proxy and its observers run on the one host (`observers/SPEC.md:911`)".
Evidence: line 911 says every member runs on one host. That the proxy is on that host is at `:834` ("its own host's, which is the coordinator's host too"). In the P7 row, `:266` says a missing store is reported by the reads that follow; that the report halts the ring is `:364`.
Corrected: cite "(`observers/SPEC.md:834`, `:911`)" in both rows, and "(`observers/SPEC.md:266`, `:364`)" in the P7 row.

**S25. `results.md`, section 9, lines 804 to 805.** "The listing leaves out the module's comments".
Evidence: a diff of the listing against `Heartbeat.tla` shows only the `(* … *)` block comments and `TypeOK` removed. The trailing `\*` comments on the declarations are in the listing.
Corrected: "The listing leaves out the module's block comments and its `TypeOK` invariant, which `Heartbeat.cfg` lists."

**S26 (minor). `results.md`, section 2.7, line 253.** "loses G1 to that one step." The search gives G1 broken in two rounds: the step, then a mutation. Corrected: "loses every monitor to that one step, and G1 can then be violated in two rounds."

**S27 (minor). `README.md`, line 143; `results.md`, line 1497.** "`systems-all.json` every system the checker ran, as data". It holds the 103 cases; the census systems and the restart rings are not in it. Corrected: "the 103 cases, without their results".

**S28 (minor). `README.md`, line 152.** "stop everything in one boundary". The step stops every monitor in the boundary and no work process. Corrected: "stop every monitor in one boundary".

**S29 (minor). `results.md`, lines 1501 to 1504; `README.md`, lines 373 to 380.** "To rerun: `python -I check_model.py`". That command writes neither JSON file, and `run-output.txt` ends with two lines that only `--json` and `--systems` print. Add: "`run-output.txt`, `results.json` and `systems-all.json` were made with `--json results.json --systems systems-all.json`."

**S30 (minor). `README.md`, lines 366 to 367.** "each property as one edge or one setting". In R, P1 is six edges and a setting, and P3 is nine edges. Corrected: "each property as one relation or one setting".

**S31. `check_model.py`, docstrings and output against the documents.**
- `is_plain` docstring omits two conditions the code and section 10.1 have. Corrected: "…; coupling on; no window; the gate in place; reports arrive within the round."
- Module docstring calls G2 "halt"; the documents call it "no impact".
- The specification, the script and `run-output.txt` say "goal"; the documents say "judgement" and never note it. Add to section 2.4: "The specification and the checker's output call the two judgements goals."
- `restart_game` says "self-starting" and prints "starts by itself"; the documents say "can start first". Add to 10.3: "(In the checker's output this member "starts by itself".)"
- The documents do not mention `--json` and `--systems` (S29).
The rest of the docstrings and comments agree. The script was edited after the two verifiers' runs (its date is later than theirs, and the reconciler's N8 lists docstring faults that are now gone). My run of the edited script reproduces the stored outputs byte for byte.

### NOT CHECKABLE

**S32. `results.md`, section 10.2, lines 1055 to 1056.** "`2f + 1` to name the faulty members when each monitor's output is read directly." The folder proves the `f` = 1 case (D's C7). The general count has no proof here and no kind of evidence. Corrected: "and three to name one faulty monitor (proved above). By the same counting the general number is `2f + 1`; that is not proved here."

**S33. `results.md`, section 1, lines 34 to 36.** "The properties, and the further requirements found below, follow from them". The folder shows where each constraint enters (2.6) and that each property is needed in the model. That the properties follow from the constraints is the framework's derivation, and 12.4 says it was not reproduced. Corrected: "The framework holds that the properties, and the further requirements found below, follow from them."

**S34. `results.md`, lines 527 to 528 and 1300 to 1302.** "reading every monitor before each action is itself an evaluation window (section 8)". Section 8 counts what a window costs. It does not show that reading many monitors is one. Mark it: "(argued, not modelled)".

**S35. `results.md`, section 2.4, lines 183 to 184.** "The request this work was done for set detection as its goal." The text itself says the request is not in the folder. No change needed.

---

## Part 2: writing rules

Clean on the mechanical rules: no em dash, no first person, no "in order to", no sentence starting "This is" or "That is", no capitals for emphasis, none of the listed filler words outside the quoted criterion, none of the four history words.

**S36. Kinds of evidence other than Checked, Proved, Counted.**
- `results.md` 441: "The second is argued from an execution." Line 487 and the section 7 table call the same result proved. Corrected: "The second is proved from two executions."
- 1001: "follows". Corrected: "proved, from the row above".
- 1004: "the first proved, the second argued, both checked on one ring of four"; and 1398: "This paragraph is argued and was not checked." Either add a fourth kind at the top ("**Argued.** Reasoning in prose, neither proved for a class nor checked.") or reword each.
- `README.md` 287: "**Searched, by an independent agent.**" The note calls it "Checked independently, and exhaustively." Corrected: "**Checked, exhaustively, by an independent agent.**"
- 680: the 400-system trial is a sample (S14). 1323: "at larger sizes by sampling" sits under a heading that says "exhaustively".
- No kind where one is due: 385 to 389 (R with an unread fourth monitor: add "**Checked.**"); section 9 (add "**Checked,** on the checker's copy of the module."); 788 to 796 (the two conditions: argued).

**S37. Figurative or casual phrasing.**
- `README.md` 48, `results.md` 263: "the asteroid". Corrected: "*Outward: a fault wider than the scope.*"
- `README.md` 49 to 50, `results.md` 264 to 265: "nothing in it acts wrongly, because nothing in it acts." Corrected: "The loss is real, and it is not a failure of the system: no part of it acts while the fault stands."
- `results.md` 705 to 706: "A lock is shown to be needed by a burglar who comes through the door. That the lock stops him is a test. That there are burglars is a premise." Corrected: "The checker tests that each property stops its fault. That the fault occurs is a premise."
- 1097: "Someone has to go first." Delete; the next sentence says it.
- 1235: "**A finite check is a finite check.**" Corrected: "**A finite check covers the system checked.**"
- 676: "the window is the very step G2 forbids". Corrected: "the window is the step G2 forbids".
- `README.md` 338: "with no check that has to remember to run". Corrected: "with no check that has to run" (see S50).

**S38. Rhetorical mirrors.**
- `results.md` 168 to 169: "It is not part of the problem. The implementation sets it: …". Corrected: "The implementation sets `f`, by how often the monitors check against how fast faults can arrive."
- 684 to 685: "… is not peculiar to the reference system. It holds for any system." See S14.
- 1014 to 1015: "So the count of three does not come from responding to a single fault. It comes from one of three other places." Corrected: "Responding to a single fault needs two. The count of three comes from one of three other places."
- The one-sentence form "X, not Y" remains at `README.md` 81 and `results.md` 530, 1209, 1216 and 1223. The correction removed the others.

**S39. Restating.**
- `README.md` 209 to 211: "Every verifier therefore knew the conclusion being claimed. … They were not unaware of the framework." Delete the last sentence.
- `results.md` 1034 to 1041 against 1097 to 1109: the same three sentences twice. In 10.2 keep: "The fourth constraint forces it: section 10.3 shows why, and what it forces."
- 1296 to 1299 restates 1290 to 1294. Delete "In 243 the path is one read long, and in the other 46 it includes a report."
- 1347 to 1350 restates 1336 to 1338. End the Result at "…was "The claim is false". What holds in every one of those systems is narrower (above)."

**S40. Long sentences.**
- `results.md` 698 to 703, one sentence of about 80 words. Make it a list.
- 1309 to 1313. Corrected: "… wrote its own deciders and settled every system of these sizes. It decided the first and third rows one by one. For the second and fourth it decided each wiring of signal reads, reports and halt inputs, and then visited every system with no gap. It counted the last."
- 1465 to 1471, "The chief ones: …", seven clauses. Make it a list.

**S41. Passive voice.** 62 lines of the README and 222 of the note carry a passive. Most are formal ("can be violated", "is flagged") and I leave them. These hide an actor the text has:
- `results.md` 414: "The checker replayed each execution in a table below".
- 779: "A computation with `growth` in `check_model.py` checked all three, for every `n` from 2 to 3,000 and for powers of two beyond."
- 892: "The author produced the trace by hand and checked it against a state-for-state copy …".
- 1268 to 1270: "For each of those, the checker tested … Where one failed, it first set aside the monitors the system does not depend on".
- 1448, 1449: "The author tightened the specification's wording in eight places." "The author fixed four defects in the script".
- 1476 to 1478: "In the final round the verifiers checked each against the script and the reconciler recomputed each. No prover received any of them as a bare statement."
- 1484: "The author then read every line it cites, and the reconciler read each again".
- `README.md` 166: "An agent started fresh for the purpose checked each phase up to the falsifier search".
- 221 to 223: "The author replaced local paths … and changed nothing else in those folders."
- 312: "The author traced the TLA+ module by hand and against a copy in the checker."

**S42. History in a passage that describes.** `results.md` 678: "not reviewed (added later)". Corrected: "not reviewed: the gate was not among the removals given to the reviewer".

---

## Part 3: sense

**S43. `results.md`: terms used before or without a definition.**
- "gap" (from line 4) and "tier" (from line 38) are never defined. Add to 2.4: "A system has a *gap* if some execution violates G1 or G2." Add to section 4: "A *tier* is the class of fault a system is built to cover: how many faults per round, and how wide a loss."
- Lines 44 to 79 use P1 to P8, G1, G2 and R before sections 2.4, 3 and 5 introduce them. Add after "How the pieces fit": "The eight properties are listed in section 3.1, the two judgements G1 and G2 in section 2.4, and R is the reference system of section 5."
- "plain" at 83 (defined at 906), "the reflex; the cascade" at 309 (section 8), "P2's first face" at 350 (section 6). Add the pointers.
- "surface view" at 958 is not defined. Corrected: "a coordinator that reads the members' signals and flags and checks no state".
- "the definition of a falsifier" at 1310. Add: "(a system with no gap in which a predicate fails and no deletion of spare monitors repairs it)".

**S44. `README.md`: terms never defined.** The README never lists the eight properties. It uses "the second face of P2" and "two tiers" (169 to 170), "the gate" (254, 258, 274) and "the halt fan-out" (274) without saying what they are. Add a list of the eight after line 7, and to method item 1: "The order, monitors before work, is called the gate."

**S45. "Coupling" names two things.** At `results.md` 51 and 173 the gate is "the model's execution-observation coupling". At 1065 and 1094 "the model's coupling rule" is the halt on silence, which is the `coupling` field of the specification. Corrected, 1065: "The model's rule for silence is that nothing runs unobserved: a work process halts when a monitor it takes its halt from is silent."

**S46. "The gate made structural".** `results.md` 76, 488 to 490 and 670 say P2 does by construction what "the gate" does by a check with a threshold. The thing with the threshold is the halt on silence, as 1364 to 1367 says. The gate of 2.3 is the order of the phases. Corrected, 488: "Against the loss of a substrate, P2 is the halt on silence made structural. The halt on silence keeps work from outliving its observer by a check, and a check has a threshold." Change 76 and 670 to match.

**S47. Cost.** `results.md` 296 to 297, `README.md` 38: "The structure's cost is therefore fixed for each ring, and it does not rise with scale." "It" reads as the whole structure's cost, which grows with the number of rings. Corrected: "The cost of each ring is therefore fixed. The whole grows with the number of rings and with nothing else."

**S48. "In no other" against "its other difference".** `results.md` 1099 says the member differs "in this one respect and in no other". Line 1185 says "Its other difference is that it sees more", and 99, 1039 and 1108 say it has no work of its own. The wording in S7 ("The theorem forces that difference and no other") removes the contradiction.

**S49.** `results.md` 3: "This note answers one question: can the claim … be proved, and can the ring structure be derived from it?" Two questions. Corrected: "This note answers two questions:".

**S50. `README.md`, 337 to 338.** "In each, the property holds because of how the system is built, with no check that has to remember to run." Notes 3, 4 and 6 are checks and note 8 is review. Corrected: "In notes 1, 2, 5 and 7 the property holds because of how the system is built, with no check that has to run."

**S51. `results.md`, 1421 to 1423.** "An agent started in the workspace … They were independent of the reasoning here." "They" has no antecedent. Corrected: "The verifiers were independent of the reasoning here. Each knew the conclusion being claimed."

**S52. `results.md`, 771 against 777.** The bullet states the second bound for `n` of 2 or more; the next paragraph says it is proved for `n` of 4 or more. Both are right (D's proof from 4; my computation gives damage 1 at `n` = 2 and 3). Add at 778: "(for `n` = 2 and 3 the second bound holds by the computation)".

**S53. Smaller places.**
- `README.md` 10 to 11: "has each step redone by independent agents" says more than section 13. Corrected: "has each step checked by independent agents".
- `README.md` 74: "Four cases are provided here." Two are links and two are in `../examples`. Corrected: "Four cases are public."
- `README.md` 105 to 106: "an established model checker is a widely used tool for it, such as TLC". Corrected: "The method is called model checking. TLC, for the TLA+ language, is a widely used model checker."
- `README.md` 217 to 218: "what none of them covered". The note's heading is "What the passes before the final round did not cover". Use that.
- `README.md` 204: "from its own recomputation"; the note says "recomputation or reading". Use the note's.
- `results.md` 1323: "It found the same at every size, and at larger sizes by sampling." Corrected: "Its findings agree with the census at every size it decided, and its samples of larger systems agree too."

**S54. `results.md`, 414 to 415.** "Each execution in a table below was replayed in the checker, so each result is **checked**." By the definition at the top, Checked means every reachable state was explored. Both were done. Corrected: "The checker explored each removal in full and replayed each execution in a table below, so each result is **checked**."

**S55. The saved final-round reports use names that are not in the folder.** `findings-forward.md` and `findings-backward.md` call the note `formal-results.md` and the folder `formal-model\`, and the forward report names `snapshot-formal-results-0052.md`, which is not there. They are stored word for word, so add to section 13: "The two verifiers' reports call this note `formal-results.md` and this folder `formal-model`, their names at the time, and give line numbers of the text before the correction."

---

## Public-repository check

No local absolute path, no user name and no email address in any file of the folder. The only personal identifiers are the two GitHub URLs the documents give on purpose. `report-a.md` line 31 mentions "the session scratchpad" without a path. See S55 for the earlier names.

## Counts

A claim is one checkable statement, one table row, or one cell where the cells are separate results. A claim in both documents is counted in each. STYLE and SENSE are counts of flagged places.

| Part | Examined | CONFIRMED | NARROWED | WRONG | NOT CHECKABLE | STYLE | SENSE |
|---|---|---|---|---|---|---|---|
| `results.md` opening and 1 | 30 | 26 | 2 | 1 | 1 | 0 | 8 |
| 2 | 48 | 46 | 1 | 0 | 1 | 3 | 2 |
| 3 to 5 | 36 | 35 | 1 | 0 | 0 | 1 | 2 |
| 6 | 67 | 65 | 1 | 0 | 1 | 2 | 2 |
| 7 | 35 | 34 | 1 | 0 | 0 | 6 | 1 |
| 8 | 44 | 43 | 1 | 0 | 0 | 2 | 1 |
| 9 | 17 | 16 | 1 | 0 | 0 | 2 | 0 |
| 10.1 and 10.2 | 70 | 69 | 0 | 0 | 1 | 4 | 1 |
| 10.3 to 10.5 | 56 | 51 | 5 | 0 | 0 | 1 | 2 |
| 11 | 15 | 15 | 0 | 0 | 0 | 1 | 0 |
| 12 | 76 | 73 | 2 | 0 | 1 | 6 | 2 |
| 13 and Files | 85 | 77 | 5 | 3 | 0 | 5 | 2 |
| **`results.md`** | **579** | **550** | **20** | **4** | **5** | **33** | **23** |
| README: opening, result, overview, assurance | 22 | 20 | 2 | 0 | 0 | 2 | 3 |
| README: what is here, method | 21 | 18 | 3 | 0 | 0 | 1 | 3 |
| README: the run | 38 | 31 | 6 | 1 | 0 | 2 | 1 |
| README: two halves, what is established | 43 | 38 | 5 | 0 | 0 | 2 | 1 |
| README: the rest | 21 | 20 | 1 | 0 | 0 | 2 | 1 |
| **`README.md`** | **145** | **127** | **17** | **1** | **0** | **9** | **9** |
| **Both** | **724** | **677** | **37** | **5** | **5** | **42** | **32** |
| `check_model.py` docstrings and comments | 25 | 21 | 4 | 0 | 0 | | |

Entries: S1 to S4 WRONG, S5 to S31 NARROWED, S32 to S35 NOT CHECKABLE, S36 to S42 STYLE (7), S43 to S55 SENSE (13).

Statements about the final round, checked against its three reports as the last step: 422 = 357 + 40 + 4 + 21 (37 entries) and 494 = 423 + 40 + 4 + 27 (51 entries) are right; 88 entries into 52 points is right; 13, 21, 11 and 7 with none rejected whole is right; nine further points (N1 to N9) is right; each verifier reproduced the outputs; the reconciler recomputed the restart result, the second face of P2 and the unread signal; all three files say they were saved word for word. Wrong or narrowed: S3, S4, S6, S22.

For the two placeholders: "724 claims: 677 confirmed, 37 narrowed, 5 wrong, 5 not checkable; 7 style and 13 sense entries; it ran the checker in full on the script as it stands."

## Full run

My one full run of `check_model.py` (with `--json results.json --systems systems-all.json`, Python 3.12.2, 318 s) reproduced `run-output.txt`, `results.json` and `systems-all.json` byte for byte. I did not measure memory.

## Scripts

All in `sweep/`, each with its output beside it. Nothing under `shared-templates\` was written.

- `s01_sections_1_to_6.py`: R at `f` = 1 to 3, the ten removals and their tables, the two-tier case, the scope cases of 2.7.
- `s02_sections_6_to_10.py`: P8b and P2 follow-ups, the ring chains, the reflex table and hop count on 20,000 random systems, growth figures and bounds, the `n` = 8 order, the TLA+ mirror, the 10.1 instances and tally, meshes, the restart game on every observer graph of three and four members.
- `s03_impl_a_all103.py`: pass A's implementation and its eight variant readings on all 103 systems.
- `s04_census_and_misc.py`: 18 of 27, pass B's P4 systems, the falsifier's system 6.6, the census with 289, 243 and 46.
- `s05_style_scan.py`: mechanical scan for the writing rules.
- `s06_passives.py`: lists passive constructions by line.
- `s07_restart_variant.py`: the restart game with the first starter bound by the rule after it starts.
- `s08_recount_3x1.py`: my own decider, validated against `explore`, and the exact recount of the falsifier's rows for two and three monitors with one work process.
- `s10_rulings_applied.py`: which of the reconciler's proposed wordings are in the documents word for word.
- `s11_predicates_ring3.py`: a system that meets every predicate of section 3.2 and has a gap; the same count in the census sample.
- `s12_locate.py`: line numbers for the quoted phrases.
- Outputs without a script of mine: the full run (`run-output.txt`, `results.json`, `systems-all.json`), `s09_b_universal_out.txt` (pass B's `scratch_universal.py`, run unchanged), `readme.diff`, `results.diff`, `tla_listing.txt`.
