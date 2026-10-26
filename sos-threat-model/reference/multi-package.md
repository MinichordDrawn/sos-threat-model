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

The order matters in two places. The reviews need a front to anchor on, so assembly writes
a draft one; the final front is rewritten after the reviews, from what they validated, and
only the sweep checks it after that. And the register and the evidence come before the
reviews, so the reviews check them too.

Aggregates fold the same way: two finished aggregates become one by the same sequence,
with the seams between them as step 3.

## 1. Clone at the versions that meet

Before the single-package models, fix the versions. When one package depends on another,
clone the dependency at the version the consumer's lockfile or module file requires, not
at its default branch, and record both tags and commits. A seam modeled across versions
that never ship together describes no real system. Where several consumers pin different
versions, pick one deployment and say which.

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
with both citations. Part B walks it in both directions and proposes seam chains: a gap on
one side joined to a gap on the other so that the combined impact exceeds what either
reaches alone. Part C lists the candidates rejected and why. Part D lists new rows the
seam reveals in either package, closures (an open question in one package's model that the
other package's code settles) and reach-back corrections (a statement in one model the
other side's code contradicts).

Three rules decide most candidates:

- **Obedience is not a gap.** A package doing what the other's file, environment, return
  value or configuration says is obeying. The gap, if any, is where the value came from.
- **Adding is not amplifying.** Two gaps whose effects add do not make a chain.
- **A duplicate is not new.** A chain that already exists in full inside one package's
  model is that model's chain.

**The verification** (verifier model) reopens every citation in the tree that owns it,
takes no reading on trust, and gives every seam chain, rejection, new row, closure and
reach-back a verdict. Its counts are reported as they are; zero surviving seam chains is a
result, not a failure, and it should be stated plainly with every rejection kept.

Scope extensions found at a seam (one file outside the agreed scope, opened to settle one
fact) are declared and carried wherever used.

**Check after the hunt:** the four parts present, with counts per part. **Check after
the verification:** a verdict on every hunt item, the counts, and the Part D material (new
rows, closures, reach-back corrections, scope extensions) listed with its target package
and row id, ready for assembly to carry.

## 4. Assembly

The assembler writes `output/<aggregate>-threat-model.md` from the package deliverables
and the verified seam files. It carries each seam's Part D into the body: new rows join
their package's tables under the package's next id, closures settle the open item they
name, and reach-back corrections replace the statement they correct, each marked and
listed in the change log. It also writes a draft front from the assembled impact part: the
risks in impact order with their ids, and the reading guide. The packages' own "Risks,
stated first" lists are not carried: the draft front restates the risks from the corrected
rows, and any Part D clause that names a package's risk-list entry is recorded as not
carried. A seam item that belongs in the posture matrix waits in the joins section until
the register step builds the matrix.

**Carry rows or only crossing findings.** With two or three packages, carry every row from
every model. With more, carry the crossing findings and the rows the chains use, and say
which rule was used.

**Rewrite each carried citation once, by script.** Every citation in the aggregate carries
a tree prefix (`API:`, `LIB:` and so on), declared once in the reading guide, with the
full repository-relative path. A package deliverable may cite bare file names under its
own path convention, so assembly rewrites each carried citation once, mechanically, into
`PFX: full/path:line`, and changes nothing else in it: `resolve_citations.py --rewrite`
does exactly that, and refuses to rewrite while any citation in the document is bad, so
each package deliverable must reach zero bad first: in the assembler's working copy, a
citation into a pass file is replaced by the row id or source line it rests on, and a
citation into a dependency that was never opened is moved into the prose with its name.
Dependency prefixes are distinct across packages. The resolver prints its count per
prefix; the aggregate's count for each prefix equals the package's count over the rows
carried plus the citations in seam rows and hand-written parts, each listed. Never retype
a carried citation by hand. When the body is large, assemble it by mechanical
concatenation with a script and verify the counts afterwards (rows per package, chains per
group).

**Keep each source's shape.** Where two sources built their tables on different column
schemas, keep both schemas in two halves rather than reshaping one, so every carried row
stays identical to its source apart from the citation rewrite and the id prefix.

**Keep ids, with a package prefix.** Rows and chains keep their source ids, each prefixed
with its package's short name (`API-S1`, `LIB-X2`), so ids from different packages cannot
collide in the front, the reviews or the gates. A new row continues its package's
numbering per letter. New cross-package chains get a new group letter, placed
first in the chains part, and an empty group is stated as empty with the reason.

**Forbid importing from shape references.** An assembler given an earlier document as a
shape reference will copy its content (a posture row, a "chart default" phrasing) into the
new one. Say in the prompt that the reference is for shape only and nothing in it may
appear in the output.

**Check:** rows per package equal to the deliverables plus the seam rows added; chains per
group; every Part D item carried, or recorded as not carried with the reason; the resolver
run on the document with every tree prefix.

## 5. Directional chain passes

Two passes over the assembled aggregate, independent of each other:

- **Down**, from every entry point toward impact, hunting chains that use gaps in three or
  more packages, or that join an existing crossing chain to a chain in another group. With
  two packages, where the seam hunt has already tested pairs of gaps across the boundary,
  the passes hunt chains of three or more gaps that span both packages, and joins of a chain
  in one group to a row or chain in the other.
- **Up**, from every impact term toward every entry that can produce it.

Each reports new chains, rejections and corrections. A fold agent merges them: it
verifies each new chain at the line, settles the two passes' disagreements, and writes one
CURRENT and REPLACEMENT edit list that adds the surviving chains to the new group and the
corrections to the body. The orchestrator applies it by script. Zero new chains in both
directions is a common and valid result; state it with the walk that supports it.

**Check:** both passes' counts; the fold's verdict on every new chain and correction; the
edit list applied with no failures.

## 6. Load-bearing claims, currency and posture

**The register.** The facts the risks rest on, each with an id (`LB1`, `LB2` and so on),
the claim, its citations, the posture or configuration and its default, its standing
(source-supported, inferred with the seam named, a deployment assumption) and what rests
on it. Each claim is re-verified at the line for the register.

**Currency.** The orchestrator fetches each package's upstream head into a separate
checkout and lists, in `scratch/currency.md`, the checkout's path and upstream commit for
each package and every cited file that differs from the audited commit. The register agent
re-reads each changed file; a claim that no longer holds is corrected or marked as true at
the audited commit only. The currency table lists each changed file with its lines added
and removed, never a count of the document's citations into it: later steps change those
counts and leave the table stale.

**The posture matrix.** Which deployments and configurations each risk needs, with the
shipped defaults, so a reader can tell which risks apply to them. Rows are keyed by row
and chain ids, not by risk numbers, because the final front reranks the risks.

The register agent writes the register, the currency table and the matrix as one section
for the document, plus an edit list for any claim in the body the re-verification
corrected. **Check:** every risk's facts have an LB id; every LB claim has a verdict at
the line; every changed cited file re-read; the edit list applied with no failures.

## 7. Evidence collection (optional)

Public evidence that the risks reach real deployments: products and repositories that ship
the components in the configuration a risk needs, and issues that corroborate a mechanism.
Accuracy over volume: a closed issue is cited as closed, an issue about a different
backend is not evidence for this one, and every seed assumption is checked before it is
used. Keep a short top list, a second tier and an unverified-leads list, and record every
seed correction. Written to `scratch/evidence.md`, then carried into the document as an
**Evidence.** line on each chain it supports. **Check:** every item cited to a public
source with its state (open, closed, version), and every seed checked.

## 8. Validation reviews in two directions

Two reviews of the whole document, run independently, each producing an edit list:

- **Top to bottom**, with the draft front as the anchor.
- **Bottom to top**, with the impacts and counts as the anchor.

Every edit is a numbered pair: a CURRENT block quoted verbatim from the document and its
REPLACEMENT. A reconciliation step merges the two lists, records every disagreement with
the deciding line and the winner, and checks that every CURRENT block is verbatim and
unique in the document. A script applies the merged set.

Both directions are required. The bottom-to-top reading catches what a forward reading
structurally cannot: on one aggregate, the front matter's chain ids were the numbers from
before a reclassification, and a forward reader took the front's numbering as the anchor.

**Check:** both edit lists present; each disagreement in the reconciliation settled at a
line; the merged list applied with no failures, then the resolver run again.

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
else on timing.

## 10. The final sweep

As in the single-package process, on the whole aggregate, with two questions only. The
orchestrator applies every correction by script, then runs
`../scripts/resolve_citations.py` with a `--tree PREFIX=DIR` for every tree prefix the
reading guide declares, at the audited commits. **Check:** every correction applied or
recorded as not applicable, and zero bad citations, apart from any into a dependency never
opened, listed by name. Ship at zero.

## Document skeleton

`../templates/aggregate.md` gives the section order: risks, evidence, process, pattern,
reading guide, load-bearing claims, the model in brief, the trees and how they join, the
present halt paths, Part A (the combined structure and the ring test), Part B (findings by
package, in STRIDE), Part C (chains by group), Part C2 (candidates rejected at the seams),
Part D (impact), Part E (seams not followed), availability claims, counts, change log.
