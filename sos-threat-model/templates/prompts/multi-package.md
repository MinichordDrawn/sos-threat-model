# Pass prompts: seams and aggregates

Each prompt follows the common block in `common.md`, with two changes. Its opening
paragraph (the one naming the target, the clone and the commit) is replaced by this one:

> You are the «step» step of a multi-package threat-model process using the
> self-observing-systems model. Aggregate `«A»`, workspace `«AGG»`. Packages, each with
> its clone, commit, citation prefixes and deliverable: «for every package: short name,
> clone path, tag and commit, its own prefix and its dependency prefixes, and its
> deliverable `«WORK»/output/«T»-threat-model.md`». The versions are in
> `«AGG»/scratch/versions.md`. Static reading only: do not build or run the targets or
> anything from their trees, and do not edit the clones; the kit's scripts may be run where
> this prompt says so. Besides the kit and `«AGG»`, read only the clones and package
> workspaces named here«, the upstream checkouts listed in `«AGG»/scratch/currency.md`»«,
> and `«AGG»/evidence-clones/`».

And `«KIT»/reference/multi-package.md` is added to its reading list. Each package's input
is its finished deliverable, `«WORK»/output/«T»-threat-model.md` in that package's own
workspace, with the pass 6 corrections applied.

Model choice: the seam hunts and the two chain passes on a fast, wide model; every other
step (seam verification, assembly, the fold, the register, evidence collection, the
reviews, reconciliation, the front and the sweep) on the most careful model available.
The steps run in the order of `«KIT»/reference/multi-package.md`, each gated before the
next.

Every step follows "Widest reach at every step" in `«KIT»/reference/multi-package.md`: each
row the step touches, joins, uses or says a candidate is already held by names what "The
widest reach is named" asks, where a step changes a row's strongest one, either way, every
candidate, kept chain, front risk or Part C2 rejection judged against the old one is tested
again (a rejection no longer failing becoming a chain, a chain or risk that no longer holds
corrected or dropped), and the step's output lists the rows named or the reason none was
needed, with the tests again and their verdicts; where a step narrows a row's strongest one,
every kept chain and front risk using that row is tested again against it, and every
rejection said to be already held by that row whose impact it no longer holds is restated
and tested as a failed premise (the reviews read `«AGG»/scratch/fold.md` and the verified
seam files for these; a new row a review proposes takes a provisional id naming the review,
`REV-DOWN-R1`, and reconciliation gives it the next id per letter after every row the
document and the package deliverable hold).

Every step that writes edits includes the edit-list form section of `common.md` and lists,
per prefix, the citations its edits add and replace.

---

## Seam hunt

Packages: `«P1»` and `«P2»`, with their clones and deliverables as the opening paragraph
lists them. Citation prefixes: `«P1PFX»:` and `«P2PFX»:`, full repository-relative
paths. The crossing surface from `«AGG»/scratch/seams.md`: «the
sentence and citations for this pair».

Part A, the crossing surface: every point where one side's output or state becomes the
other's input, with both citations; for every hand-off, the reading side's shape check (a
schema the store enforces on every write counts), or none, and, where the writing side
checks what it writes, whether the reading side makes the same check (if not, the hand-off
bypasses that check for what reaches past it, a value another position writes or a condition
alters: a Part B candidate, joined to the gap that lets such a value reach the hand-off);
where the hand-off names the authority the reading side acts under and carries a value
applied under it, the reading side's check that binds the two, or none (an unbound pair,
`judging-rules.md`); where the reading side decides on an object by a key, the key it reads
and the key that identifies the object where the act lands, on whichever side holds it, each
with its line, or not stated, and, where the two are in different terms, which part each
part of the check's key stands for (`judging-rules.md`, "A check binds only the key it
reads"); where the hand-off names more than one object, the check on either side that binds
each, or none (an object neither side binds, where `judging-rules.md` makes it a gap (never
one a line shows needs none, nor one whose act serves no data and changes none, which goes
with the availability claims), is one row: the deputy's where one side acts for the
requester and its next check sees only its own identity, otherwise at the reading side,
carried as a Part D new row or closure, not a seam chain; `judging-rules.md`, "Every object
an input names needs its own binding"); where one side's machine check is stated for one of
a set of like hand-offs (a person's check founds no set), each other member's check on
either side, a line showing another machine check covers it, an availability claim, or none
(a member with none, where a position gains through it what the check would guard, never one
whose lack is an availability claim (a check that only limits how much or how long the
system serves, unless further attempts reach access, data or authority a single attempt
could not, or a member whose act serves no data and changes none), is a Part D new row or
closure, not a seam chain; `judging-rules.md`, "A check stated for one is owed by its
like"); every stated exclusion either model disposes as delegated to, or covering not stated
by, the other package, and whether the other side's check at the lines covers it (for an
entry disposed as covering not stated, the row conditional on its U id is dropped where the
other side's check covers it and made standing where it does not, each a closure; where the
other side's lines are not in the evidence, or a document describes its check without
mentioning what is left out, the row stays conditional and the entry is an unsettled
question in the hunt's Part D, not a closure; for a delegated entry, the row another rule
gave conditional on its U id is dropped where the other side's check covers it and made
standing where it does not, each a closure; where the other side's lines are not in the
evidence, or a document describes its check without mentioning what is left out, that row
stays conditional and the entry is an unsettled question in the hunt's Part D, not a
closure; where there is no such row and the other side does not cover it, a new row wherever
a position gains what it lacked or a condition reaches the hazardous state, as
`judging-rules.md` says); where one side acts as a deputy, for a position the other side
serves or toward a check the other side makes, or mints authority the other side honours,
the deputy's check that the position it acts for holds the right (every restriction on that
position's credential included, and whether each reaches a check on the other side), or the
minter's check that the scope falls within its own authority (every restriction on the
minter's credential included, and whether each reaches a check on the other side), or none
(`judging-rules.md`, "A deputy carries whom it acts for", "Minted authority is bounded by
its minter" and "Identity is not authority"); for a stored hand-off (a file, a cache, a
queue), who besides the writing side can write the store (with lines, or not stated, an
unconfirmed item; for a field of a message the writing side relays for a requester and
stores, "A relayed message is written by its sender" decides who wrote it; enforced write
access goes here, never as a provenance check) and the reading side's provenance check, or
none; for a value not stored, the call or channel it arrives on, with lines, as who wrote
it, with every other position that can write to that channel (for a field of a message one
side relays for a requester, "A relayed message is written by its sender" decides who writes
it, and a channel only the relaying side can write does not settle it) and, where any can,
the reading side's provenance check, or none; a relayed field the reading side applies as
authority with no check binding the field itself (a check that the message came from the
relaying side binds nothing in it) is one row, placed as "Identity is not authority" places
a pair's and a deputy's (at the relaying side's deputy row where the reading side's next
check sees only the relaying side's identity, otherwise at the reading side), entered from
every position whose message the relaying side relays and that gains through the field, a
Part D new row, row addition or closure (the other side's row names it, never a second row,
and where the other side already holds a row for it, the part of that row about this field
is folded into the placed one, its text carried there and a pointer left, the rest of that
row standing as it was, never a standing second row, and assembly merges into the placed row
only; where the reading side honours values beyond the relaying side's own authority, the
excess is the reading side's row, entered from the requester), never a seam chain joining
the relaying side's not removing it to the reading side's not checking it (a channel only
the writing side can write to needs no further check, except for a field it relays for a
requester; where the lines do not state who else can write the channel, that is an
unconfirmed item, and a row resting on it is conditional for those writers). Part B, seam
chains, walked in both directions: a gap on one side joined to a gap on the other so that
the combined impact exceeds what either reaches alone, in the chain shape. Part C, rejected
candidates with the deciding line (whatever the reason a candidate is rejected or a chain
dropped, what `judging-rules.md`, "The widest reach is named", asks of every row it joins or
was said to be already held by, and that row lacks, is a Part D row addition); a candidate
whose premise fails is restated without it and tested before it is rejected, and what the
lines say instead is tested as a gap before it is used as a reason, and a check on the other
side that applies the requester's permissions is no reason to reject a candidate in which a
restriction on the requester is not shown to reach it. Apply the three rules. "Obedience is
not a gap; skipping the check is": acting on the other side's value after checking who wrote
it and its shape, with any value applied under an authority it names bound to that
authority, is obeying; for a value not stored, and for a field of a stored message one side
relays for a requester, who wrote it is the call or channel it arrived on, with every other
position that can write to that channel (for a field of a message one side relays for a
requester, "A relayed message is written by its sender" decides who writes it), and a
channel only the writing side can write to needs no further provenance check, except for a
field it relays for a requester (where the lines do not state who else can write the
channel, that is an unconfirmed item, and a row resting on it is conditional for those
writers); a missing check is a gap on the reading side; obedience settles who wrote the
value and its shape; where the reading side acts for a position or honours a mint, its check
as a deputy, or the check that what it honours falls within the minter's authority,
restrictions included, is judged separately ("Identity is not authority"). "Adding is not
amplifying." "A chain that exists in full in one model is a duplicate." Part D: new rows
either model should carry, closures (an open question one side's code settles), reach-back
corrections (a statement in one model the other side's code contradicts), row additions (an
impact a row must name under "The widest reach is named"), row fold-ins (the part of a row
about a relayed field moved into the row the field is placed at, a pointer left), unsettled
questions (an entry whose covering the other side's evidence leaves not stated, its row
still conditional), and scope extensions opened.

Output `«AGG»/scratch/seam-hunt-«pair».md`. End with the counts per part.

---

## Seam verify

Additional reading: both deliverables and `«AGG»/scratch/seam-hunt-«pair».md`. Reopen every
citation in the tree that owns it and take no reading on trust. Give every crossing point
(its write access, the reading side's checks with the key each reads, the check on either
side that binds each named object, each like member's check, and any deputy's or minter's
check included, with each restriction's reach across the seam), seam chain, rejection (a
rejection on a failed premise stands only if it was restated without it and tested and what
the lines say instead was tested as a gap, and a rejection because the other side applies
the requester's permissions stands only if each restriction was tested; where any was not
done, do it here), new row, closure, reach-back, row addition, row fold-in, unsettled
question and scope extension a verdict; for every candidate you reject or uphold as rejected
and every seam chain you drop, for whatever reason, each row that candidate or chain joins
or was said to be already held by gets, as a row addition, what it lacks so that it names
its strongest one (a candidate rejected while that row read "any" is tested again against
the named one, the rejection standing only if the candidate still fails) where its impact is
"any", and the impact it was said to hold where it was said to hold one and the lines show
it holds it (where they do not, the premise has failed and "A failed premise rejects the
premise, not the candidate" decides) ("The widest reach is named"). Every row a verified
seam chain uses whose impact reads "any" gets, as a row addition, its strongest one ("The
widest reach is named"). Report zero surviving chains plainly if that is the result.

Output `«AGG»/scratch/seam-verified-«pair».md`: the log, then the verified material in the
hunt's parts, then the counts. For every candidate rejected or upheld as rejected and every
chain dropped, give for each row it joins or was said to be already held by the row addition
or the reason none is needed, and the candidate's test again against it with its verdict
(one that no longer fails moves to Part B as a verified seam chain), for every new row whose
impact is "any" its strongest one ("The widest reach is named"), and for each premise found
failed, its restatement and test and what the lines say instead tested as a gap: a gap that
holds is, where no row of that package (its deliverable included) already holds it, a Part D
new row with its target package, and otherwise a row addition to the row that does, and a
chain candidate wherever it joins another gap on either side, tested here with its verdict
and kept, where it survives, as a verified seam chain, marked as within one package where it
joins only that package's gaps. List the verified Part D material last, each item with its
target package, the row id or statement it touches (a new row by a provisional id naming the
seam, `NEW-«pair»-1` and so on, and a seam chain by `NEW-«pair»-X1`, never a package or
group id), and the exact wording to carry.

---

## Assembly

Additional reading: every package's deliverable, every seam's verified file, and
`«KIT»/templates/aggregate.md` for the section order. **The template is for shape only:
nothing from it, or from any document not listed here, may appear in the output.**

Write `«AGG»/output/«A»-threat-model.md`. First make a working copy of each package
deliverable at `«AGG»/scratch/carry/«P».md`, in which a citation into a pass file is
replaced by the row id or source line it rests on and a citation into a dependency never
opened is moved into the prose with its name, until the resolver reports it clean; then
rewrite each copy's citations, in place, with the resolver's rewrite mode, which turns every
bare citation into `PFX: repo/relative/path:line` and changes nothing else: `python
«KIT»/scripts/resolve_citations.py COPY --tree «the package's own tree» --tree «PFX»=«the
package's own tree» --tree «DEP»=«each dependency tree» --rewrite PFX COPY`, after a
separate run of the same command without `--rewrite`, with each dependency tree also passed
bare in turn and `--list-bad` (a bare citation that now fails as ambiguous, or that resolves
into the dependency tree, is one to check), its findings listed in the assembly report, so
that a bare citation that resolves in a dependency tree as well as the package's own is
found and given its prefix by hand in the copy (a single-package deliverable cites a
dependency only under its prefix; `--rename OLD=NEW` needs `--tree OLD=DIR` too) (the
package's own tree bare and each dependency under its prefix, so a bare citation can resolve
only in the package's own tree; a bare citation into a dependency is bad, and is fixed in
the copy by giving it its prefix), COPY being `«AGG»/scratch/carry/«P».md`. Every dependency
prefix must be distinct across packages, as `versions.md` assigns them; where a package's
deliverable used a different prefix, add `--rename OLD=NEW` to the same rewrite command.
Prefix every carried row and chain id with its package's short name (`«P1»-S1`), keeping the
rest of the id, and every bare id in carried prose that names a row of the same package, so
ids from different packages cannot collide. Carry Parts B to E from the copies by script,
keeping each source's row schema. Carry «every row | the crossing findings, the rows the
chains use, every row a verified Part D item names and every row a Part C2 entry or a
confirmed rejection rests on», and say which. Carry each seam's verified Part D: new rows
into their package's tables under the next id per letter after the package deliverable's
rows, carried or not, and the rows this assembly has already added to it, two seams' new
rows that hold one defect, or one that a package's own row already holds, or one a row of
the package on the other side of its seam holds as the same defect (a relayed field's placed
row and the reading side's excess row excepted, each staying where it is placed, never
merged into the other side's row, which a fold-in reduces to a pointer), merged into one,
the holding row carried from its deliverable where the document does not hold it (each seam
chain given its group id in the new chain group, and every Part D item, seam chain and Part
C2 entry citing a new row or chain by its provisional id cites the id assembly gives it
instead, and the change log lists each provisional id beside its assigned id), closures into
the item they settle, reach-back corrections in place of the statement they correct, row
fold-ins into the placed row with the pointer left at the source, row additions into the row
they extend (where two seams, or two merged new rows, name one row's strongest one
differently, name the wider at the lines (where neither reaches all the other does, name
both, each with its line, and test against both) and test again every seam rejection and
seam chain judged against the narrower, a rejection no longer failing becoming a new chain
and its Part C2 entry showing the new verdict, a chain the wider one already reaches alone
dropped and entered in Part C2 with its reason; list each such row, the tests and verdicts
in the assembly report), unsettled questions into Part E, each marked and listed in the
change log. Part C2 is the one record of every rejection and every dropped chain in the run:
the fold's edit list adds its own and the passes' confirmed ones, each with any failed
premise's restatement and test and what the lines say instead, and reconciliation adds the
reviews', each marked with its step. Carry Part C2 from the verified seam files: each seam
rejection (the hunt's, the verifier's own and each chain it dropped) with its deciding line,
any failed premise with its restatement and test and what the lines say instead tested as a
gap (the row it gives, by its assigned id, and that gap's chain verdict), its test again
against any row addition, and its verdict, the count per seam matching the verified file
plus the entries assembly adds (chains it drops, rejections it overturns), each marked.
Write the closing report below to `«AGG»/scratch/assembly-report.md` as well. Write by hand
only what is new: Part A (the combined structure and the ring test), the model in brief, the
trees and how they join, the new chain group (stated as empty with the reason if no seam
chain survived), the counts, and a draft front (the risks in the impact part's order with
their ids, and the reading guide with the prefixes and the id scheme). Then grep the
document for « and »: zero hits, no unfilled placeholder. Then run `python
«KIT»/scripts/resolve_citations.py «AGG»/output/«A»-threat-model.md «trees» --list-bad`.

End with: rows per package, chains per group, every Part D item carried or not carried with
the reason, each provisional id beside its assigned id (two provisional ids share an
assigned id only where their rows were merged as one defect), every pair of new rows for one
package compared for one defect, and against that package's own rows and, for a relayed
field, the other side's row (each fold-in and pointer listed), with the merge or the reason
none, and the resolver's count per prefix beside the expected count (for each prefix, the
count under it over everything carried (taken from the working copy after the rewrite), plus
the citations under it the assembler adds (the new chain group, Part D items and other
hand-written parts), less those under it in any carried text a Part D item replaces or
removes, each listed).

---

## Directional chain pass

DIRECTION = «down | up». Additional reading: `«AGG»/output/«A»-threat-model.md`. Walk it
«from every entry point toward impact | from every impact term toward every entry that can
produce it», hunting chains that use gaps in three or more packages, or that join an
existing crossing chain to a chain in another group (with two packages: chains of three or
more gaps that span both packages, and joins of a chain in one group to a row or chain in
the other). Report new chains in the chain shape, numbered by direction (`DOWN-1`, `UP-1`;
the fold gives each kept chain its group id and lists the mapping), rejections with the
deciding line, and corrections, including, for every rejected candidate and every existing
chain a correction drops (each tested again against what is added, standing rejected only if
it still fails), what each row it joins or was said to be already held by lacks so that it
names its strongest one where its impact is "any", and the impact it was said to hold where
it was said to hold one and the lines show it holds it (where they do not, the premise has
failed and "A failed premise rejects the premise, not the candidate" decides) ("The widest
reach is named"). Output `«AGG»/scratch/chainpass-«direction».md`. End with the counts. The
other direction runs independently; do not read its file.

---

## Chain fold

Additional reading: the document, both `«AGG»/scratch/chainpass-*.md` files, and a package
deliverable where a new row needs its next id. Verify every new chain, every correction and
every rejection in either pass at the line, give each kept chain its group id and list the
mapping from the pass's id, in the tree that owns it, confirming or overturning each
rejection; for every chain the fold rejects, every rejection in either pass that it
confirms, and every existing chain a correction drops, see that each row the candidate or
chain joins or was said to be already held by names its strongest one where its impact is
"any", and the impact it was said to hold where it was said to hold one and the lines show
it holds it (where they do not, the premise has failed and "A failed premise rejects the
premise, not the candidate" decides) ("The widest reach is named"), adding as a correction
what it lacks and testing the candidate or chain again against it (a rejection standing only
if it still fails, and one that no longer fails becoming a new chain); where a correction
changes a row's strongest one, every kept chain, draft-front risk and Part C2 rejection
judged against the old one is tested again too, its entry corrected, and every rejection
said to be already held by that row whose impact it no longer holds is restated and tested
as a failed premise; a rejection it confirms on a premise that fails stands only once
restated without it and tested, and what the lines say instead tested as a gap, which the
fold does here; a gap that holds goes into the edit list, as a correction to the row that
holds it (or none, with the reason, where that row already states it in full, the row
carried either way where the document does not hold it) where a row of that package (its
deliverable included) does, and otherwise as a new row, under the next id per letter after
its package deliverable's rows, the rows the document already holds for that package and the
rows this edit list has already added to it (read the deliverable for it), and is tested as
a chain wherever it joins another gap, kept as a new chain where it survives, every row a
kept chain uses whose impact reads "any" naming its strongest one (marked as within one
package, and not counted as crossing, where it joins only one package's gaps); every row the
edit list adds or carries is listed for the change log; corrections to one row are merged
into one edit; a correction, a kept chain or a rejection (its own or a confirmed one) that
needs or rests on a row the document does not carry carries that row from its deliverable in
the same edit list, copied from its working copy in `«AGG»/scratch/carry/`, which assembly
has already rewritten (its citations as they stand there, its id, and every bare id in its
prose naming a row of the same package, with its package prefix); and list, per prefix, the
citations the edit list adds and replaces, so that the count after it is applied can be
checked. Where the two passes disagree, settle it at the line and record both readings and
the winner. Write `«AGG»/scratch/fold.md`: the verification log; then one numbered edit list
in the edit-list form that adds the surviving chains to the new group, applies the
corrections, and adds to Part C2, each marked with its step, every chain it rejects, every
pass rejection it confirms or overturns (with its new verdict) and every chain a correction
drops, and updates the counts. End with: new chains kept, rejected, pass rejections
confirmed and overturned, new rows, corrections (for every chain it rejects, every rejection
it confirms and every existing chain a correction drops, each row joined or said to be
already holding the impact gets its correction or the reason none is needed, and each
premise found failed its restatement and test, and what the lines say instead tested as a
gap, and, for each gap that holds, its new row's id or the row that already holds it (with
that row's correction or the reason none is needed), its strongest one where its impact is
"any", and its chain test and verdict), edits.

---

## Load-bearing claims, currency and posture

Additional reading: the document and `«AGG»/scratch/currency.md` (the cited files that changed
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
table, posture matrix), then a numbered edit list in the edit-list form that inserts it and
corrects any body claim the re-verification changed; a correction that changes a row's
strongest one follows the widest-reach paragraph above (every candidate, kept chain, front
risk and Part C2 entry judged against the old one tested again, each listed). End with: LB
claims, confirmed, corrected, changed files re-read.

---

## Evidence collection (optional)

Additional reading: the risks in the document's draft front and the chains they name. Find public
evidence that each risk reaches real deployments: products and repositories that ship the
components in the configuration the risk needs, and issues that corroborate a mechanism.
Accuracy over volume: cite a closed issue as closed, never use an issue about a different
backend or version as evidence for this one, and check every seed before using it. This
step may read public web sources; contact no one and open nothing that needs an
account. A public repository may be cloned shallow into
`«AGG»/evidence-clones/<name>/` and read with search tools only; build and run nothing from
it.

Write `«AGG»/scratch/evidence.md`: a short top list, a second tier and an unverified-leads
list, each item with its public source and its state; the seed corrections; then a
numbered edit list in the edit-list form adding an **Evidence.** line to each chain it
supports.

---

## Validation review

DIRECTION = «down | up». Additional reading: the whole document, «from the top, with the
draft front as the anchor | from the bottom, with the impacts and counts as the anchor»,
`«AGG»/scratch/evidence.md`, if the evidence step ran, to check the Evidence lines against,
and Part C2 with `«AGG»/scratch/fold.md` and the verified seam files for the re-tests the
widest-reach paragraph above asks; a new row or chain you propose takes a provisional id
naming your direction and its kind (`REV-DOWN-R1` for a row, `REV-DOWN-X1` for a chain).
Verify every number against the body, every risk against its row and rank, every id against
what it resolves to, the register's claims, the evidence lines, and a sample of citations at
the line, with every load-bearing and newly added item opened in full. Output
`«AGG»/scratch/review-«direction».md`: a log table (check, citation as given, verdict,
correction), then numbered edits, each a CURRENT block quoted verbatim from the document and
its REPLACEMENT. The other direction runs independently; do not read its file.

---

## Reconciliation

Additional reading: both review files, the document, `«AGG»/scratch/fold.md`, the verified
seam files, and a package deliverable where a new row needs its next id or a row the
document does not hold. Give each new row a review proposes (`REV-DOWN-R1`, `REV-UP-R1`) the
next id per letter after every row the document, the package deliverable and this
reconciliation have already assigned, merging two reviews' rows that hold one defect into
one, and a review's row that a row of the document, the fold, assembly or the package
deliverable already holds into that row (carried where the document does not hold it); a gap
a review finds from a failed premise goes to the row that holds it, where one does, and is
otherwise a new row, tested as a chain wherever it joins another gap, its verdict listed;
give each new chain its group id; carry from its working copy in `«AGG»/scratch/carry/`,
which assembly has already rewritten, with its id and every bare id in its prose prefixed,
any row an edit needs that the document does not hold; replace every provisional id in the
edit blocks with its assigned id and list each pair for the change log. Where one review
changes a row's strongest one, test again against it every rejection, drop and chain of the
other review that rests on that row. Add to Part C2, each marked with its step, every chain
the reviews or this reconciliation drop and every rejection they or this reconciliation
make, confirm or overturn, with its current verdict and any failed premise's restatement and
test, each existing Part C2 entry a re-test overturns corrected in place. Merge the two edit
lists into one ordered, mechanically applicable set in the edit-list form. Record every
disagreement in plain prose, never as CURRENT or REPLACEMENT blocks: both proposals
described, the deciding line in the document or the source, and the winner with the reason.
The only edit blocks in the file are the final merged set. Confirm every CURRENT block is
verbatim and unique in the current document. Output `«AGG»/scratch/reconciled-edits.md`. End
with: edits in from each review, edits out, disagreements settled.

---

## Final front

Additional reading: the document as the reviews left it, and `«AGG»/scratch/evidence.md` if it
exists. Rewrite the front from the validated body, replacing the draft, in this order:

1. Risks, stated first, ranked by severity times detection times exposure with the scales
   in `«KIT»/reference/judging-rules.md`, taking exposure from `«AGG»/scratch/evidence.md`;
   if that file does not exist, rank by severity times detection and say so. Each entry
   names its rows and chains and carries its rank in the impact part beside it.
2. What the evidence shows and does not.
3. How fast, and by what process: the start time «start», the finish time, which this
   step writes from the system clock at the moment it writes the front, and the step
   sequence. No per-package timeline.
4. The pattern behind the findings: the shape the gaps share, one paragraph per boundary.
5. How to read this document: the order of the parts, the schemas, the citation prefixes,
   the posture rule, scope extensions, source-supported against inferred, deployment
   assumptions and the id scheme.

Write `«AGG»/scratch/front.md`: the new front, then one CURRENT and REPLACEMENT edit that
replaces the draft front in the document. End with every id the front names and the row or
chain each resolves to.

---

## Final sweep

As the single-package pass 6, over `«AGG»/output/«A»-threat-model.md` (the sweep adds no row
and no chain and drops none, the widest-reach paragraph above notwithstanding: a re-test
that would make a chain, or that finds a chain or risk no longer holds, is recorded as an
open question in the Part C2 entry or the chain's own text, and a chain or risk a re-test
finds no longer holds is marked so in its text, in the front's risk that rests on it, in its
impact rank, in the register's "what rests on it" and the posture matrix row keyed by it,
and in the counts, and entered in Part C2 (or its entry's verdict corrected) as found not
holding by the sweep; a gap it finds is an open question; where its correction changes a
row's strongest one, it tests again every rejection, failed-premise restatement and chain in
Part C2 and the chains part, and every front risk resting on that row, and records as a
failed premise every rejection said to be already held by that row whose impact it no longer
holds, judged against the old one, with a verdict for each, written into that entry, and a
re-test that would make a new chain is recorded in that entry as an open question for a
later run, never added by the sweep), with the output `«AGG»/scratch/final-sweep.md` and the
corrections in the same numbered sweep-line form, or the edit-list form for text that spans
lines or that no lengthening within its line makes unique. Skip the single-package items an
aggregate does not have (the integration surface, the entry-point index, the standalone
copy, and what the single-package prompt says about the deliverable); check the register,
the posture matrix, the evidence lines, the model in brief and the reading guide (every path
rule, prefix and id scheme it states) instead. The dry run takes the one document, with
`--anchor` and the change log skipped and without `--partial`; fix everything it reports
until it reports no problem, and run it once more after writing the closing counts and
claims:

    python «KIT»/scripts/apply_edits.py «AGG»/scratch/final-sweep.md «AGG»/output/«A»-threat-model.md --anchor --skip-section "Change log" --dry-run
