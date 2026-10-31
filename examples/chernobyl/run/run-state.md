# Run state: chernobyl

Kit: `«KIT»/` (read only).
Workspace: `«WORK»/`. Process: single package, document
evidenced (`reference/general-systems.md`).

Source: `sources/insag-7.pdf` SHA-256 `75627db871b8cec591eaf9443ef32da70e6ccb72c34c38b01c18933e21152455`;
`sources/insag-7-paged.txt` SHA-256 `a83c26e92dd7ac110314315850ba8e424b11facbdccbdd51e6d7cad20c321e32`
(pdftotext 4.00, `-layout -enc Latin1`, 6,747 lines).

Resolver: `python -I <kit>/scripts/resolve_citations.py FILE --tree «WORK»/sources --list-bad`

| Step | Model | Prompt | Output | State | Gate |
|---|---|---|---|---|---|
| Survey | orchestrator | n/a | `scratch/chernobyl-survey.md` | done | 215 citations, 0 bad |
| 1 Ring map | fable | `scratch/pass1-prompt.md` | `scratch/chernobyl-ring-map.md` | done | no ring (isolated spokes to one actuator); 21 observers, 11 SP, 17 BC, 14 OC, 9 RP, 15 PR; 10 halt paths, 19 continue-on-fault; 21 hazards rows; 21 U, 20 DG, 7 SC; 674 citations, 0 bad |
| 2 Gap evaluation | fable | `scratch/pass2-prompt.md` | `scratch/chernobyl-eval.md` | done | 8 groups, 60 G, 4 S, 0 N/A over 64 cells; settled 34 confirmed, 0 refuted, 25 not settled of 59; 54 rows (S4 T18 R10 I0 D15 E7); 12 entries; 17 boundaries; 12 availability claims; 745 citations, 0 bad. Note: the prompt's paste of U21 was cut after "and"; the pass used the ring map's full wording |
| 3 Verify | opus | `scratch/pass3-prompt.md` | `scratch/chernobyl-verified.md` | done | 246 items: 171 confirmed, 64 corrected, 11 dropped, 8 new items (U22-U24, DG21-DG25), 0 new findings; scorecard 56 cells, 52 G, 3 S, 1 U; 52 rows (S3 T16 R10 I0 D16 E7); headline corrections V1 (S1 refiled under D), V2 (impact order: design first), V3 (T9, RP9 dropped), V4, V5, V7, V8, V9; 1,032 citations, 0 bad |
| 4 Chain hunt | fable | `scratch/pass4-prompt.md` | `scratch/chernobyl-chains.md` | done | 11 chains (7 source-supported, 3 conditional, 1 design assumption), 9 rejected, 11 missed (M1-M11), 3 contradictions (CT1-CT3) for pass 5; 255 citations, 0 bad |
| 5 Chain verify | opus | `scratch/pass5-prompt.md` | `scratch/chernobyl-chains-verified.md` | done | 11 of 11 chains survive, all corrected (X1-X7 source-supported; X8, X10 conditional; X9, X11 design assumption); 45 steps: 29 confirmed, 15 corrected, 1 dropped; 9 of 9 rejected confirmed; 7 missed rows (M1, M2, M3, M5, M6, M9, M11; T1 R1 D4 E1); 14 additions (A1-A14); 6 reach-back corrections (K1-K6, new DG26, DG27, U25, SP12); CT1-CT3 confirmed; 438 citations, 0 bad |
| Assembly | opus | `scratch/assembly-prompt.md` | `output/chernobyl-threat-model.md`, `output/chernobyl-threat-model-standalone.md`, `output/rebuild-source.sh` | done | 59 rows (S3 T17 R11 I0 D20 E8 counting M rows by letter; 52 verified + 7 M), equal in both; 11 chains of 20 candidates, 9 rejected; K1-K6 and A1-A14 applied; deliverable 1,393 citations 0 bad, standalone 1,348 citations 0 bad; 0 guillemets, 0 em dashes, no first person outside quotations, no workspace strings in the standalone; rebuild-source.sh written, not run against the web (its extraction steps were checked on the local PDF) |
| 6 Final sweep | opus | `scratch/pass6-prompt.md` | `scratch/final-sweep.md` | done | 668 items: 605 confirmed, 57 narrowed, 6 wrong, 0 not checkable; 69 corrections (dry run clean); the sweep split its reading across seven helpers |

Sweep applied: `apply_edits.py scratch/final-sweep.md <deliverable> <standalone> --partial` applied 69 of 69; correction 1 reached the standalone only (its self-contained introduction, line 37; no deliverable counterpart), so no `final-sweep-fixes.md` was needed. The sweep's numbered corrections were added to the deliverable's change note by one CURRENT/REPLACEMENT edit on its last line (`scratch/final-sweep-changenote.md`). Old phrases remaining: corrections 12 and 34 only, both additions whose new text begins with the old phrase. Pre-sweep copies in `scratch/pre-sweep/`.

Final: deliverable 1,426 citations, 0 bad; standalone 1,358 citations, 0 bad; 59 rows in each (by id prefix S4 T16 R10 D15 E7 M7; by section S3 T17 R11 I0 D20 E8, S1 being filed under D); 0 guillemets, 0 em dashes.

Run complete.
