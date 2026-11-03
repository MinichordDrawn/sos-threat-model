# Run state: `constitution`

Kit: `«KIT»` (single-package process,
document-evidenced system per `reference/general-systems.md`).
Workspace: `«WORK»`.

Models: breadth passes (1, 2, 4) on fable; verification passes (3, 5, 6) and assembly on
opus, as the brief and the skill say.

| Step | Model | Prompt | Output | State |
|---|---|---|---|---|
| Survey | orchestrator | n/a | scratch/constitution-survey.md | done; 161 citations, 0 bad |
| Pass 1 Ring map | fable | scratch/pass1-prompt.md | scratch/constitution-ring-map.md | done |
| Pass 2 Gap evaluation | fable | scratch/pass2-prompt.md | scratch/constitution-eval.md | done |
| Pass 3 Verify | opus | scratch/pass3-prompt.md | scratch/constitution-verified.md | done |
| Pass 4 Chain hunt | fable | scratch/pass4-prompt.md | scratch/constitution-chains.md | done |
| Pass 5 Chain verify | opus | scratch/pass5-prompt.md | scratch/constitution-chains-verified.md | done |
| Assembly | opus | scratch/assembly-prompt.md | output/constitution-threat-model.md, output/constitution-threat-model-standalone.md | done |
| Pass 6 Final sweep | opus | scratch/pass6-prompt.md | scratch/final-sweep.md, scratch/final-sweep-deliverable.md | done |

## Gate log

- Pass 1 gate (fable): shape isolated spokes; 9 observers, 17 OC, 35 BC, 14 SP (75 entries);
  hazards 17 rows, read-backs 14 (14 no provenance, 14 no shape, 5 unbound pairs), DA 17
  components / 20 rows (20 no machine check), SE 23, key records 13, NO 12 inputs / 38
  objects (32 none stated), SS 4 / 9 members (8 none or none stated), H1-H4, C1-C8, RP 10,
  PR 7, DG 4, U1-U38, SC1. Resolver 567/0 bad (orchestrator rerun). Passed.
- Pass 2 prompt built by script: U1-U38, H1-H4 and C1-C8 pasted verbatim from the ring map.
- Pass 2 gate (fable): scorecard 42 G, 6 S, 0 N/A over 48 cells (GR1-GR6); 47 U items
  (6 confirmed as stated, 0 refuted, 41 not settled by the document); H1-H4, C1-C8 confirmed;
  69 STRIDE rows (6 S, 6 T, 3 R, 1 I, 7 D, 46 E), 21 unconditional; every OC, RB, DA and SE
  id appears in a row; 13 open questions for pass 4. Resolver 499/0 bad. Passed.
- Pass 3 prompt built: nine care items from the impact order, the verdict and the
  non-row dispositions.
- Pass 3 gate (opus): 370 confirmed, 46 corrected, 3 dropped, 16 new. Headline corrections:
  observers 9 to 12 (O7 extended; O10, O11, O12 new), shape unchanged (isolated spokes);
  scorecard 46 G, 2 S; SE16 held by E33, SE7 by E31; E35, E37, E39 dropped (66 rows: 6 S,
  6 T, 3 R, 1 I, 7 D, 43 E); I1 out of impact entry 3; D7 conditional on U48; U48-U50 new;
  DA counts 5 observer-read, 7 person-only, 8 none stated. Resolver 824/0 bad. Every
  correction read. Passed; the front follows the verified file.
- Pass 4 prompt built: 20 candidates and the system-specific places.
- Pass 4 gate (fable): 5 chains (X1-X5, all conditional on an unconfirmed item), 22 rejected,
  11 missed rows (M1-M11), 3 contradictions of the verified file, 13 additions, U51-U62,
  DG5. Resolver 257/0 bad. Passed; no chain reported as a finding until pass 5 rules.
- Pass 5 gate (opus): chains 0 confirmed, 4 corrected, 1 dropped (X4), 2 new (X6, X7): 6
  verified, all conditional on an unconfirmed item; 23 rejected; 9 missed rows to merge (M1,
  M4-M11), M2 dropped, M3 merged into E9; 27 additions; 4 reach-back corrections (VR1-VR4);
  9 open questions; U63-U66. Resolver 327/0 bad. Passed.
- Assembly prompt built; decision: source not copied into output, rebuild-source.sh written
  and not run (no web).
- Assembly gate (opus): 75 rows (S 6, T 6, R 3, I 1, D 7, E 43, M 9: by filed letter S 6, T 7,
  R 3, I 1, D 10, E 48), equal in both files (the standalone's doubled counts are Part F's
  index rows); 6 chains of 29 candidates; VR1-VR4 in the change note; pass 5's 9 open
  questions in Still unsettled. U51, U53-U62 had been rebuilt by hand; sent back, now copied
  by script from the chain hunt's file (orchestrator check: verbatim in both files), pass 5's
  additions kept, change-note line added. Resolver: deliverable 1,338/0, standalone 1,284/0.
  No guillemets, em dashes or workspace strings. Passed.
- Pass 6 prompt built (sweep reading list, evidence rules, edit-list form, optional helpers).
- Pass 6 gate (opus, eight helpers): 834 items: 643 confirmed, 162 narrowed, 25 wrong, 4 not
  checkable; 249 corrections in final-sweep.md, 1 in final-sweep-deliverable.md; dry runs clean.
- Applied (Pass 6 steps 1-3): copies kept in scratch/pre-sweep/; final-sweep.md applied to both
  (standalone first, --partial --anchor --skip-section "Change note"): 249 edits, 23 reaching
  the standalone only; 22 sit in its introduction, Keys, Part E or Part F; correction 98 sat in
  the shared halt-paths section, so the deliverable's version went to final-sweep-fixes.md (1
  edit). final-sweep-deliverable.md (1) and final-sweep-fixes.md (1) dry-run and applied to the
  deliverable alone. No old text remains outside the change note in either document. Every
  correction recorded in the deliverable's change note ("### Final sweep corrections", one
  entry each, added citations with file names) by one CURRENT/REPLACEMENT edit on its last line.
  Every narrowed or wrong log line names a correction in the lists.
- Final: resolver deliverable 1,431/0 bad, standalone 1,326/0 bad; rows equal in both (S 6,
  T 6, R 3, I 1, D 7, E 43, M 9 = 75); no guillemets, em dashes or workspace strings. RUN
  COMPLETE.
