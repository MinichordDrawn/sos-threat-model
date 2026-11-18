# Findings, forward pass

*Saved by the main session from the verifier's hand-back, word for word. The verifier could
not write this file itself.*

Result: 422 claim instances examined; 357 CONFIRMED, 40 NARROWED, 4 WRONG, 21 NOT CHECKABLE, in 37 entries (23 NARROWED, 3 WRONG, 11 NOT CHECKABLE).

## Three things to know first

1. **The write-up changed while I was verifying it.** `formal-results.md` was rewritten at 00:52:10 (75,727 bytes and 1,328 lines when first read; 75,839 bytes and 1,330 lines after). Three places differ, and they account for the whole byte difference:
   - section 7, first paragraph and table header ("My label" became "Kind of argument");
   - section 10.2, the paragraph "The coordinator, as a role" (rewritten);
   - section 13, one sentence under "From B".

   Everything below is about the later text. A copy is `snapshot-formal-results-0052.md` in my folder; the live file still equalled it at the end. Quotations are from it.
2. **My imports created two bytecode folders under `shared-templates\`, and I removed them.** They were `formal-model\__pycache__\` and `verification\a-reimplementation\__pycache__\`; neither existed at my first listing. I ran with `-B` afterwards. Nothing else there was touched.
3. **I listed the file names in `final-round\backward\` once, by accident,** in a command that printed timestamps for the sibling folders. No file there was opened.

## What was checked

- **Full run** of `check_model.py` (Python 3.12.2, `python -I`): 327 seconds, peak working set 1.93 GB. Output is identical to `run-output.txt` apart from the two "wrote ..." lines; JSON is identical to `results.json` (103 cases).
- **Pass A's `impl_a.py`**, unchanged, on all 103 systems: 0 disagreements.
- **Executions**: the ten of section 6, the two-tier case, ring chains, reflex, coordinator, restart cases and the TLA+ mirror, replayed through the script's functions.
- **General "proved" statements** (rate bound, unchecked set, halt sources, one boundary, window, no gate, unchecked process) on 4,000 random systems of every kind, decided with pass A's implementation: 0 failures.
- **Theorem S** on 16,150 random plain systems meeting (a) to (d): 0 failures.
- **Growth bounds** by computation, the **halting order** by exhaustive search over orders, the **naming rule** by enumeration (it also confirms `2f + 1` at `f` = 2).
- **The author's census**, recomputed system by system: all numbers confirmed.
- **The falsifier's counts**: (2,1) and (2,2) recomputed exhaustively; (3,1) on a uniform sample of 40,000, which agrees with every share.
- **TLA+**: printed module diffed against `Heartbeat.tla`, and traced by hand.
- **Implementation**: `observers/SPEC.md` at the cited lines, plus a count of occurrences of identifiers and quoted phrases cited without a line number; `observer_gate.php` in full.
- Every verifier's report and result files.

## Entries

An entry sits where the claim first appears and names the later places that repeat it or rest on it.

### README.md

**F1. README, "The method", item 6; formal-results section 13, first sentence. NARROWED.**
- Claim: "**Independent verification.** Every phase was checked by an agent started fresh for the purpose and given only the artefacts: the specification, the cases, the code, or a claim as a bare statement. None was given the author's reasoning or expected results." Section 13: "Every phase was checked by an agent started fresh for the purpose."
- Evidence: section 13 itself lists what the passes did not cover: "The restart result of section 10.3, the second face of P2 in section 6, and the case of one unread signal at two tiers in section 4 were added after them", plus the TLA+ module and the comparison of 10.5. The README lists Theorem R under "Proved" with no such note.
- Pass A's own result files hold 101 cases (94 + 7); the two `mesh3-unread-M3` cases are not there. I re-ran A's code on them and it agrees.
- What A and B were told is not in their folders, so the last sentence cannot be checked for those two. For D, E and F the briefs are there and are bare statements.
- Corrected: "**Independent verification.** Each phase up to the falsifier search was checked by an agent started fresh for the purpose and given only the artefacts: the specification, the cases, the code, or a claim as a bare statement. None was given the author's reasoning or expected results. Three results added afterwards were not checked this way (the restart result, the second face of P2, and one unread signal at two tiers), nor were the TLA+ module and the comparison with the implementation."

**F2. README, "What is established", Proved. NARROWED.**
- Claim: "**Theorem S.** Four conditions on the wiring are enough for any system, of any size and depth, to respond completely to every single fault."
- Evidence: the theorem (10.1; D's C4) is for plain systems. The four conditions hold on the mesh of four in one boundary (`sufficient_f1` true, `is_plain` false) and G1 is broken in 2 rounds (`mesh4-one-boundary/f1`). They hold on a mesh of three with a window, and G2 is broken in round 1.
- Corrected: "**Theorem S.** Four conditions on the wiring are enough for any plain system (no joiner, substrates or switches, no shared boundary, work that halts on silence, no window, the gate in place, reports within the round), of any size and depth, to respond completely to every single fault."

**F3. README, Proved; formal-results section 8.1. NARROWED.**
- Claim (README): "When reports take time, a bad work process acts once for every hop between the monitor that checks it and the monitor that stops it."
- Claim (8.1): "**Proved,** from the round semantics: when reports take a round, a work process that goes bad takes `d` further work steps, where `d` is the least number of report hops from one of its state checkers to one of its halt inputs."
- Evidence: the proof is E's E4, which is for "the execution in which the environment takes exactly one step in total: `mutate x`, in round 1", with no window and the gate in place. Where no path exists the process works in every round (E4 ii).
- A further fault changes the count. Chain c, p, q, h with W checked by c and halted by h (`d` = 3):
  - mutation alone: W works in rounds 1 to 3;
  - `stop h` in round 2: W works in round 1 only;
  - `mutate p` or `stop p` in round 2: W works in every round.
- Corrected (README): "When reports take time and no further fault lands, a work process that is mutated acts once for every hop between the monitor that checks it and the monitor that stops it, and never stops if there is no such path."
- Corrected (8.1): "**Proved,** from the round semantics, for the execution in which the mutation of the work process is the environment's only step (no window, the gate in place): when reports take a round, the work process takes `d` work steps while bad, where `d` is the least number of report hops from one of its state checkers to one of its halt inputs, and it works in every round if there is no such path. A further fault can make it fewer (a halt input is stopped) or more (a relay is stopped or mutated)."

**F4. README, "Checked"; formal-results section 1 ("On the structure"), 10.1 (first row of checked instances), 10.5 ("signal read ... all pairs"). NOT CHECKABLE, for the "all pairs" part.**
- Claim (README): "The ring as built in the two implementations (four members, all pairs checking) holds at one, two and three faults per round." Section 10.1: "Four monitors, all pairs watching, one work process reading all four. This is the ring as built in both implementations: three members and a coordinator."
- Confirmed: the model part (mesh of 4 holds at `f` = 1, 2, 3) and four members (SPEC.md line 34, "All four stores"; `observer_gate_members()` returns web, multi, policy, super).
- Not checkable: SPEC.md 358 and 370 define the staleness bound and backstop of `member-fresh` and do not say who reads whom. Line 673 has every member, `super` included, recompute the checks of the three surfaces it does not own; it shows no member recomputing `super`. `observer_gate.php` is the gate, not the members.

**F5. README, "Searched, by an independent agent"; formal-results section 12.1, twice. NARROWED.**
- Claim: "That the silence is read, and that one detection stops the system, do not." Section 12.1 also: "One detection still stops the whole system, which is what the property is for; the path is one read long."
- Evidence: the falsifier's report, 6.6 (`F4x1-Q4-1`): "after `stop c`, a raises a flag but w keeps working". Reproduced: flagged a, worked w, in that round and the next; no monitor spare; neither judgement can be violated (18 states).
- The report's section 7: "I found no weaker form of Q4 that holds".
- The write-up's own table has "a flag reaches a halt source of every work process | 32 | 9": nine systems where some monitor's flag reaches no halt source with spare monitors set aside.
- What every system with no gap has is the definition of no gap. The README attributes the sentence to the independent agent; it is not among that agent's findings.
- Corrected (README, and the sentence before "Result" in 12.1): "That the silence of every monitor the system depends on is read, by a monitor or by the work, does not vary. Nor does the halt in the round a state goes bad, which is what no gap means. A detection of a silence alone need not stop the work (the falsifier's system 6.6)."
- Corrected (12.1, "One detection still stops ..."): "A bad state still stops the whole system in its round, which is what the property is for; in 243 of the 289 the path is one read long."

**F6. README, "Verification". NARROWED.**
- Claim: "Each folder under `verification/` holds the specification as it stood when that pass ran, so the copies differ slightly from `model-spec.md`."
- Evidence: the copies in `e-claims/` and `f-falsifier/` are byte-identical to `model-spec.md` (8,022 bytes). Those in `a-reimplementation/`, `b-review/` and `d-claims/` (6,358 bytes, identical to each other) lack section 3.6 and six clarifying sentences.
- Corrected: "Each folder under `verification/` holds the specification as it stood when that pass ran. The copies for A, B and D differ slightly from `model-spec.md`; those for E and F are identical to it."

**F7. README, "Verification". NOT CHECKABLE.**
- Claim: "Local paths in the reviewer's scripts were replaced by paths relative to each script; nothing else in those folders was changed."
- B's scripts do take paths from the script's own folder, and no absolute local path remains under `formal-model/`. The originals are not available, so "nothing else" cannot be checked.

**F8. README, "Verification"; formal-results section 13 ("One caveat applies to all of them"). NOT CHECKABLE.**
- Claim: "All of these agents could see a one-line description of the framework. They were independent of the reasoning here. They were not unaware of the framework."
- No artefact records what an agent could see.

**F9. README, "Running it"; formal-results, last line. NARROWED.**
- Claim: "`python -I check_model.py --traces   also print every violating execution`"; "Add `--traces` to print every violating execution."
- Evidence: `report()` prints the shortest execution breaking each judgement for each system listed, and output section 3 shows the write-up's ten executions. The 55 one-edge removals run with traces off (`report(..., False, quiet=True)`).
- Corrected: "also print, for each system listed, the shortest execution that violates each judgement" and "Add `--traces` to print, for each system listed, the shortest execution that violates each judgement."

**F10. README, "Running it". WRONG.**
- Claim: "It needs Python 3.8 or later and nothing else."
- Evidence: `check_model.py` lines 572 to 573, in `key_of`: `{...} | {"m": sorted(system.monitors)}`. Dictionary union exists from Python 3.9. `key_of` is used by the census, so on 3.8 the run would fail with a TypeError at output section 12, before any JSON is written.
- The script runs on 3.9.6 and 3.12.2. Python 3.8 is not installed here, so the failure itself was not observed.
- Corrected: "It needs Python 3.9 or later and nothing else."

**F11. README, "The implementations"; formal-results section 10.5. NOT CHECKABLE.**
- Claim: "Two rings have been built on this structure, and both are public", with the two addresses and branches `portal` and `drawn`; 10.5: "The fuller of the two is ghostunnel's" and "Line numbers are at commit `0741dac`."
- No web access, and the repositories' history was not to be opened. The working copy of `observers/SPEC.md` (911 lines) matches the write-up at every cited line number.

### formal-results.md

**F12. Section 1, item 1. NARROWED (true for P4 and P8 only).**
- Claim: "Judged against detection alone, P4, P8 and the halt fan-out would look unnecessary, which shows that detection alone is too weak a goal."
- Evidence: `run-output.txt` section 2: "R without P8b ... G1 broken in 3 rounds  G2 broken in 1 round" (mutate M1, stop M2, stop M3; `R-P8b/f1` has G1 = 3). B's findings, section 5: "P8b | G2 round 1, G1 round 3" and "Only P4 and P8 break G2 alone".
- Corrected: "Judged against detection alone, P4 and P8 would look unnecessary (without either, G1 holds in every reachable state of R), and the halt fan-out nearly so (without it G1 is broken only in three rounds, because work that never halts keeps the model running), which shows that detection alone is too weak a goal."

**F13. Section 1, "On the structure", Sufficient. NARROWED.**
- Claim: "Two levels of recursive interleaved rings hold too, including when a whole base ring is lost in one step." (It follows "holds up to three faults per round in the model.")
- Evidence: the two-level rings are checked at `f` = 1 only. At `f` = 2: mutate A1 and KA, and WA works (G2, round 1). `nested1-upper2/f2` is broken in `run-output.txt`. The README says "at one fault per round".
- Corrected: "Two levels of recursive interleaved rings hold too, at one fault per round, including when a whole base ring is lost in one step."

**F14. Section 1, "On the structure", Wiring. NARROWED.**
- Claim: "*Wiring:* the monitor that checks a work process must itself be able to stop it. A halt that has to reach a coordinator first arrives after the bad process has acted."
- Evidence: section 8.1's own table: with the work halted only by M2 and M3 and reports arriving at once, "neither judgement can be violated" (`reflex-relayed-instant/f1`). The requirement holds when a report takes a round.
- Corrected: "*Wiring:* when a report takes time, the monitor that checks a work process must itself be able to stop it. A halt that has to reach a coordinator first then arrives after the bad process has acted."

**F15. Section 2.4. NOT CHECKABLE.**
- Claim: "This is the goal as the task statement defines it."
- The task statement is not among the artefacts.

**F16. Section 3.2, table, row P8b. NARROWED.**
- Claim: "| P8b Halt fan-out | every work process takes its halt from at least two monitors; every halt is passed to at least two more | mutate, of a relay |" (under "a statement about the system's relations").
- Evidence: removing P8b changes `halt_inputs` only (B, 2.1). B, 2.3: the second clause "is not in the transition system at all. That wording is modelled only in `growth()`, which is unconnected to `System`." The section 6 execution mutates a halt source (M1).
- Corrected: "| P8b Halt fan-out | every work process takes its halt from at least two monitors (that every halt is passed to at least two more is not a relation of the model; it is counted in section 8.2) | mutate, of a halt source |"

**F17. Section 5. NOT CHECKABLE.**
- Claim: "R is the smallest system found in which all ten removals can be told apart."
- No record of a search over smaller systems is in the folder.

**F18. Section 6, P2, second face. NARROWED.**
- Claim, under "**Proved.**": "- *One substrate, any `k`.* The only step that stops M in this way stops W with it. W takes no further work step, so nothing it could do while bad happens."
- It holds only for a substrate loss that stops the work process, which is not the step the model defines.
- Evidence: section 2.2: "fail-substrate `s` | stops every monitor on `s`; every work process on `s` goes bad". `model-spec.md` 3.1: a non-monitor on the substrate is added "to `bad` and to `hidden`"; it is not stopped.
- Under that step a shared substrate with any delay gives an impact in the round the substrate fails:
  - R with a one-round window and shared substrates kept (R without P8), `fail-substrate s1`: bad W1, flagged M2 and M3, worked W1 and W2. This is the search's own shortest execution breaking G2 there.
  - One monitor M and one work process W on one substrate, W halting on M after a window of one round, `fail-substrate s`: W bad and working, G1 and G2 broken.
- The threshold `k` is in neither `model-spec.md` nor `check_model.py`, and section 13 says no pass covered this result.
- Statements that rest on it:
  - section 1 item 6: "sharing a substrate leaves no threshold in which work runs unobserved";
  - the section 6 verdict: "Shared substrate does it by construction, with no check and no threshold";
  - section 7 table: "proved from an execution (second face)";
  - section 10.5: "losing the host stops both, which is P2's second face";
  - section 12.2: "Sharing the substrate has none".
- Corrected: "- *One substrate, any `k`, where losing the substrate stops the work process as well as the monitor.* This is not the `fail-substrate` step of section 2.2, under which a work process on the lost substrate goes bad and keeps running. The step stops M and W together. W takes no further work step, so nothing it could do while bad happens. Under the step of section 2.2 sharing the substrate does not help: W goes bad in the round the substrate fails and, with any threshold of a round or more, acts in that round."

**F19. Section 6, the gate, last paragraph. NARROWED.**
- Claim: "Without the gate the round in which a fault lands is never a complete response, so the environment also gets further rounds."
- Evidence: in R without the gate, `stop M3` in round 1: W1 and W2 halt on its silence, M1 and M2 flag, and the response is complete in that round. Of 2,365 reachable rounds in which a state goes bad, 136 end in a complete response, because flags from earlier rounds exist.
- What holds: no first round in which a state goes bad is a complete response (all six such choices).
- Corrected: "Without the gate, in R, the round in which a first bad state lands is never a complete response, so the environment also gets further rounds."

**F20. Section 7, first sentence; section 13, "From B". NARROWED.**
- Claim: "Each removal carries two labels." Section 13: "The verdict table now carries B's label for each removal."
- Evidence: the gate's row has "not reviewed (added later)" in the reviewer's column. Nine of ten rows carry B's label.
- Corrected: "Each removal carries a label for the kind of argument it needs. All but the gate carry a second, the independent reviewer's, which says something sharper: ..." and "The verdict table now carries B's label for each of the nine removals B reviewed."

**F21. Section 7, table, column "Judgement broken", rows P8b and the gate. NARROWED.**
- Claim: "| P8b Halt fan-out | G2 | ..." and "| The gate | G2 | ...".
- Evidence: `run-output.txt` section 2: both "R without P8b" and "R without gate" show "G1 broken in 3 rounds  G2 broken in 1 round". Section 6 says so for the gate.
- Corrected: "| P8b Halt fan-out | G2 in one round; G1 in three | ..." and "| The gate | G2 in one round; G1 in three | ...".

**F22. Section 8.2, "The setting"; section 11, "The growth results". WRONG.**
- Claim: "The halt reaches good processes first, which is the worst order." Section 11: "- **The growth results are for one growth law,** doubling, with the worst halting order."
- Evidence: exhaustive search over which running processes each hop halts.
  - `n` = 8, two per hop, one hop per tick: good-first gives 2. Halting two good in hop 1, then one bad and three good in hop 2, leaves one bad and one good running; the spread makes it 3.
  - Sizes 2 to 200, two per hop, one hop per tick: another order does more damage in 109 sizes, by up to a factor of 1.5 (`n` = 158: 48 against 32). At powers of two it is `n / 4 + 1` (8: 3; 1,024: 257).
  - Two per hop, two hops per tick: 6 sizes up to 200 (`n` = 32: 3 against 2).
  - One per hop, one hop per tick: `n` = 4: 3 against 2.
- D's C9 fixes the good-first order and does not claim it is the worst. The bound `sqrt(n / 2)` still holds under the true worst order for every `n` up to 400.
- Corrected: "The halt reaches good processes first. This is not the worst order: an order that spends part of a hop on bad processes can leave a good one to be turned (for `n` = 8, two per hop at one hop per tick, 3 instead of 2). For `n` up to 200 the difference is at most a factor of 1.5." and "- **The growth results are for one growth law,** doubling, **and one halting order,** good processes first, which is not the worst."

**F23. Section 8.2, "The window (P8)". NARROWED (small).**
- Claim: "If everything halts `w` ticks after detection, the damage is `2^w`."
- Evidence: `growth(n, "window", w)` equals `min(2^w, n)` for every `n` below 400 and `w` below 12.
- Corrected: "If everything halts `w` ticks after detection, the damage is `2^w`, or the whole system if that is smaller."

**F24. Section 8.2, third bullet and the paragraph after it. NARROWED.**
- Claim: "- At one hop per tick, the same speed as the fault, a doubling halt loses a quarter of the system (exactly `n / 4` when `n` is a power of two)." and "These three bounds are **proved** ... and were checked here by computation for every `n` up to 3,000 and for powers of two beyond."
- Evidence: `growth(n, "cascade", 2, 1)` gives 1 for `n` = 1, 1 for `n` = 2, 2 for `n` = 4 (half), and exactly `n / 4` for 2^3 to 2^60.
- For other sizes the share runs from 20.0% (`n` = 2,558) to 40% (`n` = 10) over 8 to 3,000.
- D's proof of C9 (iii) begins "Let `n = 2^m`, `m >= 3`" and covers powers of two only.
- The second bound fails at `n` = 1 (damage 1); D's form is `max(1, sqrt(n/2))`.
- The computation "for every `n` up to 3,000" is not in `check_model.py`, so it cannot be re-run from the folder. My own run confirms the first bound for `n` from 1 to 3,000 and the second from 2 to 3,000.
- Corrected: "- At one hop per tick, the same speed as the fault, a doubling halt loses between a fifth and two fifths of the system (exactly `n / 4` when `n` is a power of two of 8 or more)." and "The first two bounds are **proved** for every `n` of 2 or more, and the third for powers of two from 8 (the proofs are the independent verifier's, in `verification/d-claims/claims-verdicts.md`), and all three were checked here by computation for every `n` from 2 to 3,000 and for powers of two beyond."

**F25. Section 8.2, the paragraph after the three bullets. WRONG.**
- Claim: "(the proofs are the independent verifier's, in `verify-d/claims-verdicts.md`)".
- Evidence: there is no `verify-d` folder. The file is `verification/d-claims/claims-verdicts.md`.
- Corrected: "(the proofs are the independent verifier's, in `verification/d-claims/claims-verdicts.md`)".

**F26. Section 9, the module as printed; the "Files" table ("the TLA+ module of section 9"). NARROWED.**
- Claim: the block from "---------------------------- MODULE Heartbeat ----------------------------" to the line of equals signs, presented as the module.
- Evidence: every printed line is in `Heartbeat.tla`, in order. The file has 72 lines, the listing 57. The listing leaves out four comment blocks and the definition of `TypeOK` (file lines 63 to 67), which `Heartbeat.cfg` names under `INVARIANTS`. The listing with the supplied configuration would not check.
- The rest of section 9 is confirmed: 8 reachable states with `HB = TRUE`, the seven-state trace with `HB = FALSE`, and no shorter one.
- Corrected (add before the listing): "The listing leaves out the module's comments and its `TypeOK` invariant, which `Heartbeat.cfg` also checks."

**F27. Section 10.2, table and "The coordinator, as a role"; section 10.3; section 12.3, table. NARROWED.**
- Claims:
  - "| Recover without an outside hand | one member that can start by itself and observes the rest | proved and checked, section 10.3 |"
  - "One member must be able to start by itself, and it must observe the rest."
  - "How many such members there are is the one thing here that is chosen and not forced."
  - "| a member that can start alone and observes the rest | emergent, from the fourth constraint |"
- That one member must start alone is confirmed. That it must observe the rest is not forced in the restart model.
- Evidence (`restart_game`):
  - ring of three, each observed by the one before it, X1 able to start alone (X1 observes X2 only): can always restart (15 states);
  - three members and K, K able to start alone and observing X1 only: can always restart (33 states).
- What is forced: every member is reached from a member that can start alone, along observation edges. Section 10.3 itself says "so it should observe all of them".
- Corrected, table rows: "one member that can start by itself, from which every other member is reached along observation edges".
- Corrected, text: "One member must be able to start by itself, and every other member must be reached from it along observation edges. Observing all of them directly is the shortest such arrangement."
- Corrected, 10.3: "How many such members there are, and whether the one observes every other member directly or through a chain, are chosen and not forced."

**F28. Section 10.2, "The coordinator, as a role". NARROWED.**
- Claim: "A flag crosses between rings only through a member that belongs to both and is watched from both (every such edge is needed in section 10.1)."
- Evidence: `run-output.txt` section 8: "spare:  A1 reads KA's signal" and "spare:  B1 reads KB's signal". Needed: A1's and U3's checks of KA's state, U3's read of KA's signal, and every report in the upper ring. Each single report between a coordinator and its own ring is spare too.
- Corrected: "(in section 10.1 both checks of its state, the upper ring's read of its signal and every report in the upper ring are needed; its own ring's read of its signal, and each single report between it and its own ring, are spare)".

**F29. Section 10.3, "The implementation"; section 10.5, first of "Three things follow". NOT CHECKABLE, for "cannot clear if it is lost".**
- Claim: "the others clear only once its halt is gone, and cannot clear if it is lost (554 to 558)."
- Confirmed: the first two clauses, at line 556 (the coordinator's clear-condition is that no declared store holds a `fault`) and line 558 (each application observer also needs "`/stores/super/halt` does not exist").
- Not checkable: nothing in 554 to 558 speaks of a lost coordinator. Line 560 says a file is removed only by its writer, so a coordinator lost while its own halt stands leaves the others unable to clear. For one lost with no halt of its own, the cited lines do not decide.
- Wording the cited lines do support: "and cannot clear while a halt of its own stands that it is no longer there to remove (558, 560)".

**F30. Section 10.5, table, row "a round". NARROWED (the quotation is not exact).**
- Claim: "one cycle; a change is seen "with a latency of at most one cycle" (604)".
- Evidence: SPEC.md line 604: "A change that lands between the first and a later read of a path within one cycle is judged by the next cycle's first read: a latency of at most one cycle." The phrase with "with" occurs nowhere in SPEC.md, and the sentence is about a change landing between two reads of one path inside a cycle.
- The other three quotations are exact (568, 872, 899).
- Corrected: "one cycle; a change that lands between two reads of a path within a cycle is judged by the next cycle's first read, "a latency of at most one cycle" (604)".

**F31. Section 10.5, table, row "boundaries". NOT CHECKABLE, for "five operating-system users".**
- Claim: "five operating-system users, one store per member, one writer per path; all on one host (911)".
- The word "five" occurs nowhere in SPEC.md. Line 911 gives the one host; line 34 gives four stores and "Every path has one writer".

**F32. Section 10.5, second of "Three things follow"; section 13, last bullet. NOT CHECKABLE.**
- Claim: "its hash chains and its append-only trace catch a state that was bad when some member read it and was put back afterwards. By the survey's reading of the procedures, a change made and undone between two reads, seen by nobody, is caught by neither." Section 13: "The comparison with the implementation in section 10.5 began as a survey by two agents. Every line it quotes from the specification was then read directly."
- No line is cited for what the history checks catch, and the survey is not in the folder. The identifiers exist in SPEC.md (I1 at 451, I3 at 458, I4 at 462, `trace-consistent` at 516 and 674).

**F33. Section 12.1, first bullet after the census table. NARROWED (the cross-reference).**
- Claim: "*State checking and two halt sources* hold in every system with no gap. Both are also proved for every system (sections 6 and 10.2)."
- Evidence: section 6 proves the need for a state checker of a monitor, and for more than `f` halt sources, each "in a system with no substrates or switches"; 10.2 restates the counts. That a work process needs a state checker is proved in the falsifier's report (its section 7) and in E5, not in section 6 or 10.2.
- Both statements are true of every system: 4,000 random systems of every kind, 0 failures.
- Corrected: "Both are also proved: two halt sources, and a state checker for every monitor, in section 6 (stated there for systems with no substrates or switches, which the proofs do not use); a state checker for every work process in the falsifier's report, section 7."

**F34. Section 12.1, third bullet after the census table; section 12.2, third bullet. NARROWED.**
- Claim: "*Propagation* takes its smallest form in 289 of them. Some monitor's flag does not reach every other monitor, that monitor is not spare, and there is still no gap, because the work process takes its halt directly from whichever monitor detects, or halts on a monitor's silence. No flag has to travel between monitors when the work can read them all." Section 12.2: "Propagation is a direct read in the small systems of section 12.1."
- The count 289 is confirmed (9 and 280). The reason given holds for 243 of them.
- Evidence: in 46 of the 289, removing every report edge opens a gap, so a flag does have to travel there. Example from the sample: M2 is checked only by M1, the work halts on M2 or M3, and M1 must report to M3; without reports, `mutate M2` leaves M1 flagged and W working. Only 3 of the 289 have no report edge at all.
- The falsifier's report says the same: "Where a report is needed it is needed along particular edges (from a checker that is not a halt input to one that is)".
- Corrected (12.1): "*Propagation* is partial in 289 of them. Some monitor's flag does not reach every other monitor, with spare monitors set aside, and there is still no gap. In 243 of the 289 no report is needed at all: the work process takes its halt directly from whichever monitor detects, or halts on a monitor's silence. In the other 46 a flag still has to travel, but only from a checker that is not a halt source to a monitor that is."
- Corrected (12.2): "Propagation is a direct read in most of the small systems of section 12.1, and a single report in the rest."

**F35. Section 12.1, second bullet after the falsifier's table. NARROWED.**
- Claim: "The two predicates about edges between monitors fail in most systems with no gap, including systems in which no monitor is spare: 515,030 of the 742,352 in the third row."
- The numbers are confirmed. Only one of the two predicates fails in most.
- Evidence, the falsifier's third row: the signal predicate fails in 178,176 of 1,169,616 systems with no gap (15%; none of 12 with two monitors; 19% with four); the propagation predicate in 798,222 (68%). 515,030 counts no-spare systems failing either (23,904 + 43,680 + 447,446). My sample of 40,000 gives 15.1% and 68.1%.
- Corrected: "One or other of the two predicates about edges between monitors fails in most systems with no gap (in the third row the propagation predicate in 798,222 of the 1,169,616, the signal predicate in 178,176), including systems in which no monitor is spare: 515,030 of the 742,352 in the third row fail at least one."

**F36. Section 12.4. NOT CHECKABLE.**
- Claim: "An attempt was made with three agents given only the four constraints, but each could see this workspace's own one-line description of the ring, so they were not independent, and their derivations are set aside."
- Nothing from that attempt is in the folder.

**F37. Section 13, table row A and "From A". NOT CHECKABLE.**
- Claim: "ten ambiguities in the wording, none of which changed a result" and "The specification's wording was tightened in ten places."
- Pass A's folder holds no report. `impl_a.py` documents seven alternative readings (its `DEFAULT_OPTS`).
- The difference between A's copy of the specification (with its addendum) and `model-spec.md`, apart from the two new fields, is eight places by my count:
  1. a monitor or process missing from a map "has none";
  2. the joiner before it joins;
  3. "whether or not it was already in `bad`";
  4. a halted process is treated like any other;
  5. "passes its flag to nobody";
  6. a flagged monitor that is switched off is in `out`;
  7. the silence clause when there is no gate;
  8. "(before this round's detection)".

## Counts

Counted as claim instances at the grain of one stated result, one table cell, one execution row, one quotation or one cross-reference. An entry covers every instance of its claim.

| Part | Examined | Confirmed | Narrowed | Wrong | Not checkable |
|---|---|---|---|---|---|
| README.md | 66 | 55 | 6 | 1 | 4 |
| Section 1 | 21 | 16 | 4 | 0 | 1 |
| Section 2 | 34 | 33 | 0 | 0 | 1 |
| Section 3 | 13 | 12 | 1 | 0 | 0 |
| Section 4 | 7 | 7 | 0 | 0 | 0 |
| Section 5 | 9 | 8 | 0 | 0 | 1 |
| Section 6 | 33 | 30 | 3 | 0 | 0 |
| Section 7 | 23 | 19 | 4 | 0 | 0 |
| Section 8 | 30 | 24 | 4 | 2 | 0 |
| Section 9 | 13 | 12 | 1 | 0 | 0 |
| Section 10 | 77 | 62 | 6 | 0 | 9 |
| Section 11 | 10 | 9 | 0 | 1 | 0 |
| Section 12 | 47 | 38 | 8 | 0 | 1 |
| Section 13 and Files | 39 | 32 | 3 | 0 | 4 |
| **Total** | **422** | **357** | **40** | **4** | **21** |

Entries: 37 (23 NARROWED, 3 WRONG, 11 NOT CHECKABLE).

## Notes outside the two documents (not counted)

- `check_model.py` line 767 calls the mirror "(section 7)"; the section is 9. Its docstring says "eight-property model" and "`--traces` also print every execution".
- `run-output.txt` ends "wrote 103 systems to systems-all.json"; that file is not in the folder.
- E's report names `test_bounded.log`, which is not in `e-claims/`.
