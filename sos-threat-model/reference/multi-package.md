# Multi-package process: seams, aggregates and the validated document

Real systems are several packages that hand each other things: a credential file, a
return value, a clock, a configuration, a pod. Each package can be sound alone and the
system still fail at the boundary, because each treats its neighbour as the place where
the guarantee lives. This process finds what crosses those boundaries, folds the packages
into one aggregate document, and validates the result in two directions until it holds.

It builds on the single-package process. Every package in the aggregate gets its own full
six-pass model first.

As there, every step with a prompt in `../templates/prompts/multi-package.md` is a
separate sub-agent launched by the orchestrating session: each seam hunt and seam
verification, the assembly, the two chain passes and their fold, the register, the
evidence collection, the two validation reviews and their reconciliation, the front and
the sweep. The two chain passes are independent of each other, and so are the two reviews.
The orchestrator records the versions, does the seam selection and the upstream fetch for
the currency check, checks every gate, applies every edit list a step produces with
`../scripts/apply_edits.py` (never by hand), and reruns `../scripts/resolve_citations.py`
at the gates. The assembly agent runs the resolver on what it builds.

## Workspace

One folder for the aggregate beside the packages' own workspaces, which stay as they are.

```
<aggregate>/
  scratch/   seams.md, one hunt and one verified file per seam, the chain passes and their
             fold, the register and currency files, evidence, the two reviews, the
             reconciled edits, the front, the sweep, and every prompt
  output/    <aggregate>-threat-model.md
```

Each package's input is its finished deliverable, `<t>/output/<t>-threat-model.md`, with
the pass 6 corrections applied.

## The sequence

1. The versions fixed to the ones that ship together, then a full single-package model of
   every package.
2. Seam selection: which pairs of packages hand each other something.
3. A seam hunt and an independent seam verification for every pair.
4. Assembly of the aggregate document, with a draft front.
5. Directional chain passes over the whole aggregate, down and up, then a fold.
6. The load-bearing claims register, the currency check and the posture matrix.
7. Optional evidence collection.
8. Two independent validation reviews in opposite directions, then reconciliation.
9. The final front: risks stated first, evidence, process, pattern and the reading guide,
   rewritten from the validated body.
10. The final sweep, applied by script, with a citation resolver run to zero.

**Widest reach at every step.** Every step that keeps, drops, rejects or overturns a
candidate or chain, or changes what a row reaches (seam hunt and verification, assembly, the
chain passes and the fold, the register, the reviews, reconciliation and the sweep, which
only records, adding and dropping nothing: §10), leaves each row it touches, joins, uses or
says a candidate is already held by naming what "The widest reach is named" asks
(`judging-rules.md`), and where that changes a row's strongest one, tests again, whichever
way it changed, every candidate, kept chain, front risk or Part C2 rejection judged against
the old one, a rejection no longer failing becoming a chain and a chain or risk that no
longer holds corrected or dropped; a row a confirmed rejection rests on is carried, as
assembly carries a row. Each step's output lists the rows it named or the reason none was
needed, and the tests again with their verdicts, and its check confirms that list. Where a
step narrows a row's strongest one, every kept chain and front risk using that row is tested
again against it (one that no longer holds corrected or dropped), and every rejection said
to be already held by that row whose impact it no longer holds has a failed premise,
restated and tested. The reviews read `scratch/fold.md` and the verified seam files for the
rejections this may reach; a new row a review proposes takes a provisional id naming the
review (`REV-DOWN-R1`), and reconciliation gives it the next id per letter after every row
the document and the package deliverable hold.

The order matters in two places. The reviews need a front to anchor on, so assembly writes
a draft one; the final front is rewritten after the reviews, from what they validated, and
only the sweep checks it after that. And the register and the evidence come before the
reviews, so the reviews check them too.

Aggregates fold the same way: two finished aggregates become one by the same sequence.
The inputs are the two aggregate documents after their final sweeps; the units at step 3
are the packages, one seam per pair of packages on opposite sides that hand each other
something; the prefixes of both aggregates go into one `versions.md`, renamed where they
collide; and ids already carrying a package prefix (`API-S1`) keep it, while each
aggregate's crossing group keeps its letter with the aggregate's short name added
(`J-X1` becomes `AB-J-X1`).

## 1. Clone at the versions that meet

Before the single-package models, fix the versions. When one package depends on another,
clone the dependency at the version the consumer's lockfile or module file requires, not
at its default branch, and record both tags and commits. A seam modeled across versions
that never ship together describes no real system. Where several consumers pin different
versions, pick one deployment and say which.

Before the package surveys, the orchestrator also assigns every citation prefix, each
package's own and every dependency's, unique across the aggregate (`STD_A:` and `STD_B:`
for two standard libraries at different versions), and the package surveys use those
prefixes. A package modeled earlier under other prefixes is carried with
`resolve_citations.py --rewrite ... --rename OLD=NEW`.

The orchestrator writes `scratch/versions.md`: every package with its tag, commit, date
and citation prefix, which consumer pins which version, and the start time of the
aggregate run. **Check:** every dependency between packages in the aggregate pinned to the
version its consumer requires.

## 2. Seam selection

A seam is a pair of packages where one's output or state becomes the other's input. List
every pair and, for each, the crossing surface in one sentence: a constructor and its call
sites, a shared file, an environment variable, a network call, a clock, a lifecycle event.
A pair with no crossing surface is not a seam; say so and move on. When the crossing
surface is small (one constructor and four call sites, for example), it can be walked
exhaustively, and that is worth saying in the document.

Written by the orchestrator to `scratch/seams.md`. **Check:** every pair listed, each
with its crossing surface and both citations, or the reason it is not a seam.

## 3. Seam hunt and seam verification

**The hunt** (breadth model) reads both packages' verified models and both trees. Part A
maps the crossing surface: every point where one side's output becomes the other's input,
with both citations; for every hand-off, the reading side's shape check (a schema the store
enforces on every write counts), or none, and, where the writing side checks what it writes,
whether the reading side makes the same check (if not, the hand-off bypasses that check for
what reaches past it, a value another position writes or a condition alters: a Part B
candidate, joined to the gap that lets such a value reach the hand-off); where the hand-off
names the authority the reading side acts under and carries a value applied under it, the
reading side's check that binds the two, or none (an unbound pair, `judging-rules.md`);
where the reading side decides on an object by a key, the key it reads and the key that
identifies the object where the act lands, on whichever side holds it, each with its line,
or not stated, and, where the two are in different terms, which part each part of the
check's key stands for (`judging-rules.md`, "A check binds only the key it reads"); where
the hand-off names more than one object, the check on either side that binds each, or none
(an object neither side binds, where `judging-rules.md` makes it a gap (never one a line
shows needs none, nor one whose act serves no data and changes none, which goes with the
availability claims), is one row: the deputy's where one side acts for the requester and its
next check sees only its own identity, otherwise at the reading side, carried as a Part D
new row or closure, not a seam chain; `judging-rules.md`, "Every object an input names needs
its own binding"); where one side's machine check is stated for one of a set of like
hand-offs (a person's check founds no set), each other member's check on either side, a line
showing another machine check covers it, an availability claim, or none (a member with none,
where a position gains through it what the check would guard, never one whose lack is an
availability claim (a check that only limits how much or how long the system serves, unless
further attempts reach access, data or authority a single attempt could not, or a member
whose act serves no data and changes none), is a Part D new row or closure, not a seam
chain; `judging-rules.md`, "A check stated for one is owed by its like"); every stated
exclusion either model disposes as delegated to, or covering not stated by, the other
package, and whether the other side's check at the lines covers it (for an entry disposed as
covering not stated, the row conditional on its U id is dropped where the other side's check
covers it and made standing where it does not, each a closure; where the other side's lines
are not in the evidence, or a document describes its check without mentioning what is left
out, the row stays conditional and the entry is an unsettled question in the hunt's Part D,
not a closure; for a delegated entry, the row another rule gave conditional on its U id is
dropped where the other side's check covers it and made standing where it does not, each a
closure; where the other side's lines are not in the evidence, or a document describes its
check without mentioning what is left out, that row stays conditional and the entry is an
unsettled question in the hunt's Part D, not a closure; where there is no such row and the
other side does not cover it, a new row wherever a position gains what it lacked or a
condition reaches the hazardous state, as `judging-rules.md` says); where one side acts as a
deputy, for a position the other side serves or toward a check the other side makes, or
mints authority the other side honours, the deputy's check that the position it acts for
holds the right (every restriction on that position's credential included, and whether each
reaches a check on the other side), or the minter's check that the scope falls within its
own authority (every restriction on the minter's credential included, and whether each
reaches a check on the other side), or none (`judging-rules.md`, "A deputy carries whom it
acts for", "Minted authority is bounded by its minter" and "Identity is not authority"); for
a stored hand-off, who besides the writing side can write the store (with lines, or not
stated, an unconfirmed item; for a field of a message the writing side relays for a
requester and stores, "A relayed message is written by its sender" decides who wrote it;
enforced write access goes here, never as a provenance check) and the reading side's
provenance check, or none; for a value not stored, the call or channel it arrives on, with
lines, as who wrote it, with every other position that can write to that channel (for a
field of a message one side relays for a requester, "A relayed message is written by its
sender" decides who writes it) and, where any can, the reading side's provenance check, or
none; a relayed field the reading side applies as authority with no check binding the field
itself (a check that the message came from the relaying side binds nothing in it) is one
row, placed as "Identity is not authority" places a pair's and a deputy's (at the relaying
side's deputy row where the reading side's next check sees only the relaying side's
identity, otherwise at the reading side), entered from every position whose message the
relaying side relays and that gains through the field, a Part D new row, row addition or
closure (the other side's row names it, never a second row, and where the other side already
holds a row for it, the part of that row about this field is folded into the placed one, its
text carried there and a pointer left, the rest of that row standing as it was, never a
standing second row, and assembly merges into the placed row only; where the reading side
honours values beyond the relaying side's own authority, the excess is the reading side's
row, entered from the requester), never a seam chain joining the relaying side's not
removing it to the reading side's not checking it (a channel only the writing side can write
to needs no further check, except for a field it relays for a requester; where the lines do
not state who else can write the channel, that is an unconfirmed item, and a row resting on
it is conditional for those writers). Part B walks it in both directions and proposes seam
chains: a gap on one side joined to a gap on the other so that the combined impact exceeds
what either reaches alone. Part C lists the candidates rejected and why (whatever the reason
a candidate is rejected or a chain dropped, what `judging-rules.md`, "The widest reach is
named", asks of every row it joins or was said to be already held by, and that row lacks, is
a Part D row addition); a candidate whose premise fails is restated without it and tested
before it is rejected, and what the lines say instead is tested as a gap before it is used
as a reason, and a check on the other side that applies the requester's permissions is no
reason to reject a candidate in which a restriction on the requester is not shown to reach
it (`judging-rules.md`). Part D lists new rows the seam reveals in either package, closures
(an open question in one package's model that the other package's code settles), reach-back
corrections (a statement in one model the other side's code contradicts), row additions (an
impact a row must name under "The widest reach is named"), and unsettled questions (an entry
whose covering the other side's evidence leaves not stated, its row still conditional).

Three rules decide most candidates:

- **Obedience is not a gap; skipping the check is.** A package that acts on the other's
  file, environment, return value or configuration after checking who wrote it and its
  shape, with any value applied under an authority it names bound to that authority, is
  obeying, and a wrong value that passes those checks is a gap where it came from. For a
  value not stored, who wrote it is the call or channel it arrived on, with every other
  position that can write to that channel (for a field of a message one side relays for a
  requester, "A relayed message is written by its sender" decides who writes it); a channel
  only the writing side can write to needs no further provenance check, except for a field
  it relays for a requester; where the lines do not state who else can write the channel,
  that is an unconfirmed item, and a row resting on it is conditional for those writers. A
  missing check is a gap on the reading side. Obedience settles who wrote the value and its
  shape; where the reading side acts for a position or honours a mint, its check as a
  deputy, or the check that what it honours falls within the minter's authority,
  restrictions included, is judged separately (`judging-rules.md`).
- **Adding is not amplifying.** Two gaps whose effects add do not make a chain.
- **A duplicate is not new.** A chain that already exists in full inside one package's
  model is that model's chain.

**The verification** (verifier model) reopens every citation in the tree that owns it, takes
no reading on trust, and gives every crossing point (its write access, the reading side's
checks with the key each reads, the check on either side that binds each named object, each
like member's check, and any deputy's or minter's check included, with each restriction's
reach across the seam), seam chain, rejection (a rejection on a failed premise stands only
if it was restated without it and tested and what the lines say instead was tested as a gap,
and a rejection because the other side applies the requester's permissions stands only if
each restriction was tested; where any was not done, it does so), new row, closure,
reach-back, row addition, row fold-in and unsettled question a verdict; for every candidate
it rejects or upholds as rejected and every seam chain it drops, for whatever reason, each
row that candidate or chain joins or was said to be already held by gets, as a row addition,
what it lacks so that it names its strongest one (a candidate rejected while that row read
"any" is tested again against the named one, the rejection standing only if the candidate
still fails) where its impact is "any", and the impact it was said to hold where it was said
to hold one and the lines show it holds it (where they do not, the premise has failed and "A
failed premise rejects the premise, not the candidate" decides) ("The widest reach is
named"). Its counts are reported as they are; zero surviving seam chains is a result, not a
failure, and it should be stated plainly with every rejection kept.

Scope extensions found at a seam (one file outside the agreed scope, opened to settle one
fact) are declared and carried wherever used.

**Check after the hunt:** the four parts present, with counts per part. **Check after the
verification:** a verdict on every hunt item, a row addition or a reason for none, with the
candidate's test again against it and its verdict, for every row joined, or said to be
already holding the impact, by a candidate rejected or upheld as rejected or a chain
dropped, every new row whose impact is "any" naming its strongest one, and for each premise
found failed, its restatement and test and what the lines say instead tested as a gap (a gap
that holds is a Part D new row where no row of that package, its deliverable included,
already holds it, and otherwise a row addition to the row that does, and a chain candidate
wherever it joins another gap on either side, tested with its verdict and kept, where it
survives, as a verified seam chain, marked as within one package where it joins only that
package's gaps), the counts, and the Part D material (new rows, closures, reach-back
corrections, row additions, row fold-ins (the part of a row about a relayed field moved into
the row the field is placed at, a pointer left), unsettled questions, scope extensions)
listed with its target package and row id (a new row by a provisional id naming the seam,
`NEW-<pair>-1` and so on, and a seam chain by `NEW-<pair>-X1`, never a package or group id;
assembly gives each seam chain its group id and lists the mapping), ready for assembly to
carry.

## 4. Assembly

The assembler writes `output/<aggregate>-threat-model.md` from the package deliverables and
the verified seam files. It carries each seam's Part D into the body: new rows join their
package's tables under the next id per letter after the package deliverable's rows, carried
or not, and the rows this assembly has already added to it, two seams' new rows that hold
one defect, or one that a package's own row already holds, or one a row of the package on
the other side of its seam holds as the same defect (a relayed field's placed row and the
reading side's excess row excepted, each staying where it is placed, never merged into the
other side's row, which a fold-in reduces to a pointer), merged into one, the holding row
carried where the document does not hold it, every such comparison listed (every Part D
item, seam chain and Part C2 entry citing a new row by its provisional id cites the id
assembly gives it instead, and the change log lists each provisional id beside its assigned
id), closures settle the open item they name, reach-back corrections replace the statement
they correct, row additions join the row they extend (where two seams, or two merged new
rows, name one row's strongest one differently, the wider at the lines is named (where
neither reaches all the other does, both, each with its line) and every seam rejection and
seam chain judged against the narrower is tested again, a chain the wider one reaches alone
dropped into Part C2, its Part C2 entry showing the new verdict, and the assembly report
lists each), and unsettled questions go to Part E, each marked and listed in the change log.
It also writes a draft front from the assembled impact part: the risks in impact order with
their ids, and the reading guide. The packages' own "Risks, stated first" lists are not
carried: the draft front restates the risks from the corrected rows, and any Part D clause
that names a package's risk-list entry is recorded as not carried. A seam item that belongs
in the posture matrix waits in the joins section until the register step builds the matrix.

**Carry rows or only crossing findings.** With two or three packages, carry every row from
every model. With more, carry the crossing findings, the rows the chains use, every row a
verified Part D item names and every row a Part C2 entry or a confirmed rejection rests on,
and say which rule was used.

**Rewrite each carried citation once, by script.** Every citation in the aggregate carries a
tree prefix (`API:`, `LIB:` and so on), declared once in the reading guide, with the full
repository-relative path. A package deliverable may cite bare file names under its own path
convention, so assembly rewrites each carried citation once, mechanically, into `PFX:
full/path:line`, and changes nothing else in it: `resolve_citations.py --rewrite` does
exactly that, and refuses to rewrite while any citation in the document is bad, so each
package deliverable must reach zero bad first: in the assembler's working copy, a citation
into a pass file is replaced by the row id or source line it rests on, and a citation into a
dependency that was never opened is moved into the prose with its name. Dependency prefixes
are distinct across packages, as step 1 assigns them. The resolver prints its count per
prefix, and the expected count is, for each prefix, the count under it over everything
carried (taken from the working copy after the rewrite), plus the citations under it the
assembler adds (the new chain group, Part D items and other hand-written parts), less those
under it in any carried text a Part D item replaces or removes, each listed. Never retype a
carried citation by hand. When the body is large, assemble it by mechanical concatenation
with a script and verify the counts afterwards (rows per package, chains per group).

**Keep each source's shape.** Where two sources built their tables on different column
schemas, keep both schemas in two halves rather than reshaping one, so every carried row
stays identical to its source apart from the citation rewrite, the id prefix and the Part D
items carried into it.

**Keep ids, with a package prefix.** Rows and chains keep their source ids, each prefixed
with its package's short name (`API-S1`, `LIB-X2`), so ids from different packages cannot
collide in the front, the reviews or the gates. A new row continues its package's numbering
per letter. New cross-package chains get a new group letter, placed first in the chains
part, and an empty group is stated as empty with the reason; a chain a seam or fold finds
within one package goes in that group too, marked as within one package, and is not counted
as crossing.

**Forbid importing from shape references.** An assembler given an earlier document as a
shape reference will copy its content (a posture row, a "chart default" phrasing) into the
new one. Say in the prompt that the reference is for shape only and nothing in it may
appear in the output.

**Check:** the assembly report in `scratch/assembly-report.md`; rows per package equal to
the rows carried under the rule used plus the seam rows added; Part C2 present, its count
per seam matching the verified files plus the entries assembly adds, each marked (Part C2
holds every rejection and dropped chain of the run: the fold and reconciliation add theirs,
and later steps re-test from it); every row two seams named differently, with every
rejection and kept chain tested again and its verdict; chains per group; every Part D item
carried, or recorded as not carried with the reason; the resolver run on the document with
every tree prefix, its count per prefix matching the expected count.

## 5. Directional chain passes

Two passes over the assembled aggregate, independent of each other:

- **Down**, from every entry point toward impact, hunting chains that use gaps in three or
  more packages, or that join an existing crossing chain to a chain in another group. With
  two packages, where the seam hunt has already tested pairs of gaps across the boundary,
  the passes hunt chains of three or more gaps that span both packages, and joins of a chain
  in one group to a row or chain in the other.
- **Up**, from every impact term toward every entry that can produce it.

Each reports new chains, rejections and corrections, and for every candidate it rejects and
every existing chain a correction drops (each tested again against what is added, standing
rejected only if it still fails), what each row it joins or was said to be already held by
lacks so that it names its strongest one where its impact is "any", and the impact it was
said to hold where it was said to hold one and the lines show it holds it (where they do
not, the premise has failed and "A failed premise rejects the premise, not the candidate"
decides) ("The widest reach is named"), as a correction. A fold agent merges them: it
verifies each new chain at the line, confirms or overturns each rejection in either pass
(and for each chain it rejects, each rejection it confirms, and each existing chain a
correction drops, adds the same correction where a pass left it out, restating and testing
any confirmed rejection whose premise fails, testing what the lines say instead as a gap,
and carrying from its deliverable any row a correction or kept chain needs and the document
does not hold, rewritten as assembly rewrites a carried row, and adding a gap that holds as
a new row under the next id after its package deliverable's rows, the rows the document
already holds for that package and the rows this edit list has already added to it, tested
as a chain wherever it joins another gap), settles the two passes' disagreements, and writes
one CURRENT and REPLACEMENT edit list that adds the surviving chains to the new group and
the corrections to the body. The orchestrator applies it by script. Zero new chains in both
directions is a common and valid result; state it with the walk that supports it.

**Check:** both passes' counts; every rejection and dropped chain of the fold in Part C2;
the fold's verdict on every new chain, correction and pass rejection; for every chain it
rejects, every rejection it confirms and every existing chain a correction drops, each row
joined or said to be already holding the impact gets its correction or the reason none is
needed, and each premise found failed its restatement and test, and what the lines say
instead tested as a gap, and, for each gap that holds, its new row's id or the row that
already holds it (with that row's correction or the reason none is needed), its strongest
one where its impact is "any", and its chain test and verdict; the edit list applied with no
failures, then the resolver's count per prefix beside the expected count (the count before,
plus the citations the edits add, less those they replace).

## 6. Load-bearing claims, currency and posture

**The register.** The facts the risks rest on, each with an id (`LB1`, `LB2` and so on),
the claim, its citations, the posture or configuration and its default, its standing
(source-supported, inferred with the seam named, a deployment assumption) and what rests
on it. Each claim is re-verified at the line for the register.

**Currency.** The orchestrator fetches each package's upstream head into a separate
checkout, lists the cited files with `resolve_citations.py --list-files`, and records in
`scratch/currency.md` the checkout's path and upstream commit for each package and every
cited file that differs from the audited commit. The register agent
re-reads each changed file; a claim that no longer holds is corrected or marked as true at
the audited commit only. The currency table lists each changed file with its lines added
and removed, never a count of the document's citations into it: later steps change those
counts and leave the table stale.

**The posture matrix.** Which deployments and configurations each risk needs, with the
shipped defaults, so a reader can tell which risks apply to them. Rows are keyed by row
and chain ids, not by risk numbers, because the final front reranks the risks.

The register agent writes the register, the currency table and the matrix as one section for
the document, plus an edit list for any claim in the body the re-verification corrected.
**Check:** every risk's facts have an LB id; every LB claim has a verdict at the line; every
changed cited file re-read; the edit list applied with no failures, then the resolver's
count per prefix beside the expected count (the count before, plus the citations the edits
add, less those they replace).

## 7. Evidence collection (optional)

Public evidence that the risks reach real deployments: products and repositories that ship
the components in the configuration a risk needs, and issues that corroborate a mechanism.
Accuracy over volume: a closed issue is cited as closed, an issue about a different backend
is not evidence for this one, and every seed assumption is checked before it is used. Keep a
short top list, a second tier and an unverified-leads list, and record every seed
correction. Written to `scratch/evidence.md`, then carried into the document as an
**Evidence.** line on each chain it supports. **Check:** every item cited to a public source
with its state (open, closed, version), and every seed checked, the resolver's count per
prefix beside the expected count (the count before, plus the citations the edits add, less
those they replace).

## 8. Validation reviews in two directions

Two reviews of the whole document, run independently, each producing an edit list (a new row
or chain a review proposes takes a provisional id naming the review, and reconciliation
assigns the next id after every row the document, the deliverable and the reconciliation
already hold, merges two reviews' rows for one defect, carries any row an edit needs, merges
a review's row into a row of the document or the deliverable that already holds it, and
lists each provisional id beside its assigned id):

- **Top to bottom**, with the draft front as the anchor.
- **Bottom to top**, with the impacts and counts as the anchor.

Every edit is a numbered pair: a CURRENT block quoted verbatim from the document and its
REPLACEMENT. A reconciliation step merges the two lists, records every disagreement with
the deciding line and the winner, and checks that every CURRENT block is verbatim and
unique in the document. A script applies the merged set.

Both directions are required. The bottom-to-top reading catches what a forward reading
structurally cannot: on one aggregate, the front matter's chain ids were the numbers from
before a reclassification, and a forward reader took the front's numbering as the anchor.

**Check:** both edit lists present; every rejection and dropped chain of the reviews and of
the reconciliation in Part C2, each tested against both reviews' changes, every entry a
re-test overturns corrected, and every chain of either review resting on a changed row
tested again; no provisional `REV-` id left, each beside its assigned id, every merge
listed; each disagreement in the reconciliation settled at a line; the merged list applied
with no failures, then the resolver run again, its count per prefix beside the expected
count (the count before, plus the citations the edits add, less those they replace).

## 9. The final front

Rewritten after the reviews, from the validated body, replacing the draft:

- **Risks, stated first.** Ranked by severity times detection times exposure, where
  exposure is the evidence of real deployments. Each entry names its rows and chains and
  carries its rank in the impact part beside it.
- **What the evidence shows and does not.**
- **How fast, and by what process.** The start time from `scratch/versions.md` and the
  finish time, which is when the final front is written, and the step sequence. No
  per-package timeline.
- **The pattern behind the findings.** The shape the gaps share, in one paragraph per
  boundary.
- **How to read this document.** The order of the parts, the schemas, the citation
  prefixes, the posture rule, scope extensions, source-supported against inferred,
  deployment assumptions and the id scheme.

**Check:** every id in the front resolves to the row or chain it names in the body; every
rank in the risks matches the impact part; the start and finish times present and nothing
else on timing, the resolver's count per prefix beside the expected count (the count before,
plus the citations the edits add, less those they replace).

## 10. The final sweep

As in the single-package process, on the whole aggregate, with two questions only. The sweep
checks its list against the one document with `--anchor --skip-section "Change log"
--dry-run` and leaves it clean. The orchestrator dry-runs the list, applies it by script
with `--anchor --skip-section "Change log"`, confirms no old text remains outside the change
log unless its replacement keeps it, and records the sweep's count in the change log with
one CURRENT/REPLACEMENT edit applied with no option, then runs
`../scripts/resolve_citations.py` with a `--tree PREFIX=DIR` for every tree prefix the
reading guide declares, at the audited commits. **Check:** every correction applied or
recorded as not applicable; every item the sweep's log marks narrowed or wrong names a
correction present in `final-sweep.md`; the count per prefix beside the expected count (the
count before, plus the citations the sweep adds, less those it replaces); and zero bad
citations, apart from any into a dependency never opened, listed by name. Ship at zero.

## Document skeleton

`../templates/aggregate.md` gives the section order: risks, evidence, process, pattern,
reading guide, load-bearing claims, the model in brief, the trees and how they join, the
present halt paths, Part A (the combined structure and the ring test), Part B (findings by
package, in STRIDE), Part C (chains by group), Part C2 (every rejection and dropped chain of
the run, each marked with its step), Part D (impact), Part E (seams not followed),
availability claims, counts, change log.
