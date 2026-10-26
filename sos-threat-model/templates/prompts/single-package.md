# Pass prompts: single package

Each prompt below follows the common block in `common.md`. Model choice: breadth passes
(1, 2, 4) on a fast, wide model; verification passes (3, 5, 6) and assembly on the most
careful model available.

---

## Pass 1. Ring map

Additional reading: `«KIT»/reference/eight-properties.md`, `«KIT»/templates/findings.md`
(Steps 0 to 1.5 for the shape of sections 2 to 7), and the survey
`«WORK»/scratch/«T»-survey.md`.

Where the core is: «directories». Observers to find at minimum: «health checks, gates,
refusals, halts, liveness loops, retries, verification of downloaded or received content,
signature checks, elections, supervision, startup checks, anything periodic, every place
the system runs an external program or opens a URL; name the ones the survey found».

Produce `«WORK»/scratch/«T»-ring-map.md` with eight sections:
1. System in brief: purpose, customers in two senses, its own goal in its own words.
2. Step 0 tiers, with the customer-data floor first (what customer data exists and where).
3. Observer inventory table: name, file:line, what it checks, where it reports, what it
   does on fault.
4. The ring test and the resulting shape.
5. Coordinators and super-rings: every candidate that can stop the system, tested against
   the four clauses, as a table.
6. Missing components, descriptive only; where a halt path exists, how far it propagates.
7. Execution-observation coupling.
8. Verdict within the model.

End with: the shape named; the observers counted; the halt paths and the continue-on-fault
paths listed separately; every unconfirmed item, numbered.

---

## Pass 2. Gap evaluation

Additional reading: `«KIT»/reference/eight-properties.md`, `«KIT»/templates/findings.md`,
`«KIT»/templates/threat-model.md`, and `«WORK»/scratch/«T»-ring-map.md`.

Produce `«WORK»/scratch/«T»-eval.md` containing:
1. Scorecard: every property for every observer group, G, S or N/A, with no role
   exemption; re-test every tier the map set and say whether each holds. Totals.
2. STRIDE tables with an Entry column. Build the entry vocabulary for this system from
   the ring map and the source: numbered positions, each saying who can reach what (a
   remote client, a file author, a network position, a local user, another account, an
   in-process plugin, an operator, as the system has them). Every row cites
   `path:line`.
3. The mechanisms to settle: every unconfirmed item from the ring map, pasted here
   verbatim, plus «the refusals,
   halts and verification points to settle». Each settled as confirmed, refuted or needs a
   probe, with the exact precondition.
4. Impact, ordered by the ranking rule in `«KIT»/reference/judging-rules.md`, stated once.
5. Delegation boundaries: every component the system hands work to (libraries, services,
   the platform, callbacks a caller supplies), built from the ring map and the source,
   listed and not followed.
6. Availability claims, listed and left unevaluated.

End with: scorecard totals; settled items (confirmed, refuted, needs a probe); STRIDE row
count.

---

## Pass 3. Verify

Additional reading: `«WORK»/scratch/«T»-ring-map.md` and `«WORK»/scratch/«T»-eval.md`.

Open every load-bearing citation in passes 1 and 2 at its line; confirm, correct or drop
it. A correction survives only if the true content still supports a finding. No new
findings unless a correction forces one; mark any such finding new. Where a claim rests on
a dependency, open the version the lockfile pins if it is available locally; if not, say
which version was not opened.

The claims that need the most care, strongest first: «numbered list from the evaluation's
headline findings». Every open question and every needs-a-probe item from passes 1 and 2:
settle it with the file open, or keep it as needs a probe with the exact precondition.

Produce `«WORK»/scratch/«T»-verified.md`: the verification log with counts (confirmed,
corrected, dropped, new) first; then the verified content in deliverable order: system in
brief with the tiers; architectural model with the coordinator test as a table; the
structure against the model, property by property (the scorecard with the evidence for
each verdict, re-verified); missing components; present halt paths with propagation;
STRIDE with verified rows only (ids kept, corrected rows marked); impact by one rule;
delegation boundaries; availability claims; still unsettled questions, each with what
would settle it. End with the list of every correction that changes a headline finding.

---

## Pass 4. Chain hunt

Additional reading: the chain shape in `«KIT»/templates/threat-model.md`, then
`«WORK»/scratch/«T»-ring-map.md`, `«WORK»/scratch/«T»-eval.md` and
`«WORK»/scratch/«T»-verified.md` (authoritative wherever it differs from the evaluation).

Part A, chains. Walk the ring map's edges. For each observer, ask which other observers'
checks its gap defeats, blinds or bypasses, and what the actor reaches by combining them.
Test at least these candidates and add your own: «ten or more, built from verified rows».
Record each chain: name; entry points (required, optional, one branch, one cause, the
reader); steps with evidence; the seam crossed; combined impact; composition line.
Source-supported chains first, then chains conditional on a probe, then
deployment-assumption chains, each marked. Then a rejected list with source reasons.

Part B, missed items: observers, edges and faults the earlier passes did not record. Look
at least at: the request path's other checks; rotation and rollback; startup-only
decisions; anything that gates before the core; «system-specific places». Each as a
STRIDE-shaped row (M1, M2 ...).

Part C, contradictions of the verified file, with lines in both.

Output `«WORK»/scratch/«T»-chains.md`. End with: chains, rejected, missed, contradictions.

---

## Pass 5. Chain verify

Additional reading: `«WORK»/scratch/«T»-verified.md` (settled; reopen only where the chain
document claims a contradiction) and `«WORK»/scratch/«T»-chains.md`.

1. Open every chain step's evidence; confirm, correct or drop each step. A chain survives
   only if every remaining step holds and the combined impact exceeds any one gap alone.
2. Check each chain's entry points against the verified preconditions.
3. Give the strongest Part B claims special care: anything that says unreachable, no
   validation, fails open, executes or bypasses.
4. Check every rejected candidate's reason at the line.

Output `«WORK»/scratch/«T»-chains-verified.md`: a verification log with counts; the
verified chains (source-supported first, then conditional, then deployment assumptions);
the verified rejected list; the missed items as rows ready to merge (ids kept, corrections
marked); every correction that reaches back into the pass 3 file, with the verified file's
line and the source line.

---

## Assembly. The deliverable and the standalone copy

Additional reading: `«KIT»/templates/threat-model.md` for the section order and fixed
wording only (nothing else from it may appear in the output), then
`«WORK»/scratch/«T»-verified.md`, `«WORK»/scratch/«T»-chains-verified.md`, and
`«WORK»/scratch/«T»-ring-map.md` for the observer inventory. Do not edit the scratch files.

1. Apply every correction pass 5 lists as reaching back into the pass 3 file. Open the
   source line each one names, carry the corrected wording into the output, and list each
   applied correction in a short change note at the end of the deliverable.
2. Assemble `«WORK»/output/«T»-threat-model.md` in the template's section order. Carry
   content from the pass files by copying it (by script where the tooling allows), never
   by retyping: every citation stays byte-identical, every id is kept, corrected rows stay
   marked. A citation into a pass file is not evidence: replace it with the row id it
   names or the source line it rests on. Merge pass 5's verified
   missed rows into the STRIDE tables under "Found by the chain hunt, verified". Write by
   hand only the introduction, the risks stated first (ranked by the impact rule as pass 3
   states it and pass 5 corrects it, each risk with its ids), the counts and the shape of
   it. Recompute every number in the counts from the assembled body.
3. Build `«WORK»/output/«T»-threat-model-standalone.md` from the deliverable as the
   template's closing note describes: a self-contained introduction; the model in brief on
   one page; the Keys section; every reference to the workspace, the kit and the pass files
   removed; Parts A to F, with the entry-point index mapping every row and chain to its
   entries.
4. Check both files: no em dashes and no first person; no workspace paths or kit
   references in the standalone copy; rows per letter equal in both. Run
   `python «KIT»/scripts/resolve_citations.py FILE «trees» --list-bad` on each file, and
   report its counts; a bad citation into a dependency that was never opened is listed by
   name, every other bad citation is fixed.

End with: rows by letter, chains, the reach-back corrections applied, and the resolver's
counts for each file.

---

## Pass 6. Final sweep

Reading: `«KIT»/reference/writing.md`, then
`«WORK»/output/«T»-threat-model-standalone.md`, then the source as each claim needs it.

Two questions only, of every row, chain step, rejected entry, impact entry, halt path,
risk, the integration surface, the entry-point index and every count: do the cited lines
say what the claim says, and can an actor at the named entry reach the code path as
described, with the stated precondition. No opinions on intent or accepted risk. Do not
edit the document.

Output `«WORK»/scratch/final-sweep.md`: a log per section, one line per item (id, verdict
confirmed / narrowed / wrong / not checkable, and for a narrowing or a wrong item the
number of its correction, never the correction's text); then every correction on its own
line, numbered, in exactly this form, which
the kit's `apply_edits.py` parses:

    12. Line 86. Old: `` exact phrase `` New: `` replacement ``

with one space inside each pair of double backticks, and each old phrase long enough to
occur exactly once in the whole document, lengthened within its line. `New: ````
deletes the phrase. A correction whose old text spans a hard-wrapped line goes instead as
a CURRENT/REPLACEMENT block in the form `«KIT»/scripts/apply_edits.py` documents, quoted
verbatim with its line breaks. Then the counts per section and in total; then the claims
that could not be checked because they rest on code not available.
