# Pass prompts: seams and aggregates

Each prompt follows the common block in `common.md`, with two changes. Its opening
paragraph (the one naming the target, the clone and the commit) is replaced by this one:

> You are the «step» step of a multi-package threat-model process using the
> self-observing-systems model. Aggregate `«A»`, workspace `«AGG»`. Packages, each with
> its clone, commit and citation prefix: «for every package: short name, clone path, tag
> and commit, prefix». The versions are in `«AGG»/scratch/versions.md`. Static reading
> only: do not build or run the targets or anything from their trees, and do not edit the
> clones; the kit's scripts may be run where this prompt says so. Besides the kit and
> `«AGG»`, read only the clones and package workspaces named here«, and the upstream
> checkouts listed in `«AGG»/scratch/currency.md`».

And `«KIT»/reference/multi-package.md` is added to its reading list. Each package's input
is its finished deliverable, `«WORK»/output/«T»-threat-model.md` in that package's own
workspace, with the pass 6 corrections applied.

Model choice: the seam hunts and the two chain passes on a fast, wide model; every other
step (seam verification, assembly, the fold, the register, evidence collection, the
reviews, reconciliation, the front and the sweep) on the most careful model available.
The steps run in the order of `«KIT»/reference/multi-package.md`, each gated before the
next.

Every step that writes edits includes the edit-list form section of `common.md`.

---

## Seam hunt

Packages: `«P1»` and `«P2»`, with their clones and deliverables as the opening paragraph
lists them. Citation prefixes: `«P1PFX»:` and `«P2PFX»:`, full repository-relative
paths. The crossing surface from `«AGG»/scratch/seams.md`: «the
sentence and citations for this pair».

Part A, the crossing surface: every point where one side's output or state becomes the
other's input, with both citations. Part B, seam chains, walked in both directions: a gap
on one side joined to a gap on the other so that the combined impact exceeds what either
reaches alone, in the chain shape. Part C, rejected candidates with the deciding line.
Apply the three rules: obedience is not a gap; adding is not amplifying; a chain that
exists in full in one model is a duplicate. Part D: new rows either model should carry,
closures (an open question one side's code settles), reach-back corrections (a statement
in one model the other side's code contradicts), and scope extensions opened.

Output `«AGG»/scratch/seam-hunt-«pair».md`. End with the counts per part.

---

## Seam verify

Reading: both deliverables and `«AGG»/scratch/seam-hunt-«pair».md`. Reopen every citation
in the tree that owns it and take no reading on trust. Give every crossing point, seam
chain, rejection, new row, closure, reach-back and scope extension a verdict. Report zero
surviving chains plainly if that is the result.

Output `«AGG»/scratch/seam-verified-«pair».md`: the log, then the verified material in the
hunt's parts, then the counts. List the verified Part D material last, each item with its
target package, the row id or statement it touches, and the exact wording to carry.

---

## Assembly

Reading: every package's deliverable, every seam's verified file, and
`«KIT»/templates/aggregate.md` for the section order. **The template is for shape only:
nothing from it, or from any document not listed here, may appear in the output.**

Write `«AGG»/output/«A»-threat-model.md`. First rewrite each package deliverable's
citations into a copy with the resolver's rewrite mode, which turns every bare citation
into `PFX: repo/relative/path:line` and changes nothing else:
`python «KIT»/scripts/resolve_citations.py DELIVERABLE «that package's trees» --rewrite PFX COPY`.
Every dependency prefix must be distinct across packages (two packages that both cite the
standard library at different versions use two prefixes). Prefix every carried row and
chain id with its package's short name (`«P1»-S1`), keeping the rest of the id, so ids
from different packages cannot collide. Assemble the body (Parts A to E) from the copies
by script, keeping each source's row schema. Carry «every row | the crossing findings and
the rows the chains use», and say which. Carry each seam's verified Part D: new rows into
their package's tables under its next id, closures into the item they settle, reach-back
corrections in place of the statement they correct, each marked and listed in the change
log. Write by hand only what is new: the combined structure in Part A, the new chain group
(stated as empty with the reason if no seam chain survived), the joins, and a draft front
(the risks in the impact part's order with their ids, and the reading guide with the
prefixes and the id scheme). Then run
`python «KIT»/scripts/resolve_citations.py «AGG»/output/«A»-threat-model.md «trees» --list-bad`.

End with: rows per package, chains per group, every Part D item carried or not carried
with the reason, and the resolver's count per prefix beside the expected count (each
package's count over the rows carried, plus the citations in seam rows and hand-written
parts, each addition listed).

---

## Directional chain pass

DIRECTION = «down | up». Reading: `«AGG»/output/«A»-threat-model.md`. Walk it «from every
entry point toward impact | from every impact term toward every entry that can produce
it», hunting chains that use gaps in three or more packages, or that join an existing
crossing chain to a chain in another group (with two packages: chains of three or more
gaps that span both packages, and joins of a chain in one group to a row or chain in the
other). Report new chains in the chain shape, rejections with the deciding line, and
corrections. Output `«AGG»/scratch/chainpass-«direction».md`. End with the counts. The
other direction runs independently; do not read its file.

---

## Chain fold

Reading: the document and both `«AGG»/scratch/chainpass-*.md` files. Verify every new
chain and every correction at the line, in the tree that owns it. Where the two passes
disagree, settle it at the line and record both readings and the winner. Write
`«AGG»/scratch/fold.md`: the verification log; then one numbered edit list in the
edit-list form that adds the surviving chains to the new group, applies the corrections,
and updates the counts. End with: new chains kept, rejected, corrections, edits.

---

## Load-bearing claims, currency and posture

Reading: the document and `«AGG»/scratch/currency.md` (the cited files that changed
upstream since each audited commit, listed by the orchestrator with the upstream commit).

1. The register: every fact the risks rest on, with an id `LB1`, `LB2` ..., the claim, its
   citations, the posture or configuration and its default, its standing (source-supported,
   inferred with the seam named, a deployment assumption) and what rests on it. Re-verify
   each at the line.
2. Currency: re-read each changed cited file at the upstream commit; for each claim that
   rests on it, say whether it still holds, and if not, mark it as true at the audited
   commit only.
3. The posture matrix: which deployments and configurations each risk needs, with the
   shipped defaults. Key each row by the risk's row and chain ids, never by its number in
   the front: the final front reranks the risks.

Write `«AGG»/scratch/register.md`: the section for the document (register table, currency
table, posture matrix), then a numbered edit list in the edit-list form that inserts it
and corrects any body claim the re-verification changed. End with: LB claims, confirmed,
corrected, changed files re-read.

---

## Evidence collection (optional)

Reading: the risks in the document's draft front and the chains they name. Find public
evidence that each risk reaches real deployments: products and repositories that ship the
components in the configuration the risk needs, and issues that corroborate a mechanism.
Accuracy over volume: cite a closed issue as closed, never use an issue about a different
backend or version as evidence for this one, and check every seed before using it. This
step may read public web sources; contact no one and open nothing that needs an
account. A public repository may be cloned shallow into its own empty folder and read with
search tools only; build and run nothing from it.

Write `«AGG»/scratch/evidence.md`: a short top list, a second tier and an unverified-leads
list, each item with its public source and its state; the seed corrections; then a
numbered edit list in the edit-list form adding an **Evidence.** line to each chain it
supports.

---

## Validation review

DIRECTION = «down | up». Reading: the whole document, «from the top, with the draft front
as the anchor | from the bottom, with the impacts and counts as the anchor», and
`«AGG»/scratch/evidence.md`, if the evidence step ran, to check the Evidence lines
against. Verify every
number against the body, every risk against its row and rank, every id against what it
resolves to, the register's claims, the evidence lines, and a sample of citations at the
line, with every load-bearing and newly added item opened in full. Output
`«AGG»/scratch/review-«direction».md`: a log table (check, citation as given, verdict,
correction), then numbered edits, each a CURRENT block quoted verbatim from the document
and its REPLACEMENT. The other direction runs independently; do not read its file.

---

## Reconciliation

Reading: both review files and the document. Merge the two edit lists into one ordered,
mechanically applicable set in the edit-list form. Record every disagreement in plain
prose, never as CURRENT or REPLACEMENT blocks: both proposals described, the deciding line
in the document or the source, and the winner with the reason. The only edit blocks in the
file are the final merged set. Confirm every CURRENT block is verbatim and unique in the
current document. Output `«AGG»/scratch/reconciled-edits.md`. End with: edits in from each
review, edits out, disagreements settled.

---

## Final front

Reading: the document as the reviews left it, and `«AGG»/scratch/evidence.md` if it
exists. Rewrite the front from the validated body, replacing the draft, in this order:

1. Risks, stated first, ranked by severity times detection times exposure, where exposure
   is the evidence of real deployments; each entry names its rows and chains and carries
   its rank in the impact part beside it.
2. What the evidence shows and does not.
3. How fast, and by what process: the start time «start» and the finish time «finish», and
   the step sequence. No per-package timeline.
4. The pattern behind the findings: the shape the gaps share, one paragraph per boundary.
5. How to read this document: the order of the parts, the schemas, the citation prefixes,
   the posture rule, scope extensions, source-supported against inferred, deployment
   assumptions and the id scheme.

Write `«AGG»/scratch/front.md`: the new front, then one CURRENT and REPLACEMENT edit that
replaces the draft front in the document. End with every id the front names and the row or
chain each resolves to.

---

## Final sweep

As the single-package pass 6, over `«AGG»/output/«A»-threat-model.md`, with the output
`«AGG»/scratch/final-sweep.md` and the corrections in the same numbered sweep-line form,
or the edit-list form for text that spans lines. Skip the single-package items an
aggregate does not have (the integration surface and the entry-point index); check the
register, the posture matrix and the evidence lines instead.
