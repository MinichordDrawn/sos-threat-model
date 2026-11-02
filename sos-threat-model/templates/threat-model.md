# «System»: a threat model of «the tree»

<!--
The single-package deliverable. Fill every «placeholder»; delete what does not apply.
Follow ../reference/writing.md. The standalone copy is built from this file by copying;
only its introduction, Model in brief, Keys, integration surface and index are written new
(see the "Standalone copy" note at the end).
-->

This describes one tree, as it stands: «repository» at commit `«hash»` («date»). Every
claim is a file and a line in it, judged within the self-observing-systems model. Nothing
was built or run unless stated; a claim that reading alone cannot settle is marked as
needing a probe.

<!-- For a system evidenced by a document: the source's title, publisher, date and
address (or that it has none), the pdftotext version, the encoding and both checksums in
place of the tree and commit (for a source that is not a PDF, one address, or that it has
none, and one checksum per file, with the pdftotext version and the encoding not
applicable), and "not settled by the document" in place of "needing a probe"
(../reference/general-systems.md). -->

**What the model asks.** It applies where four things hold: no central controller, a
catastrophic cost to an undetected failure, an adversarial environment, and no external
maintenance. It asks for eight properties: a heartbeat, substrate dependency, continuous
state verification, a system-wide response, self-defense, death signaling, automatic
integration and reflexive response. The four conditions are a filter that puts a problem
in the model's scope, not a bar the system is failing to clear.

**How to read a row.** Each names one component, the boundary the actor sits on (B1 the
ring, B2 a privileged position, B3 an external party), the entry the actor needs, what the
gap reaches, the lines that establish it, and what happens on fault. Entries are numbered
positions: «(1) ...; (2) ...; (3) ...». In a chain, each entry point is marked required,
optional, one branch, one cause, or the reader (the party whose reading of an output
completes the chain). A chain joins a gap in one component to a gap in
another so that the combined impact exceeds what either reaches alone. Rows keep their
identifiers from the verification passes.

**Path convention.** «How bare file names resolve; which third-party versions were opened
and which were not.»

---

## The system in brief

«Purpose, customers in two senses, its own goal in its own words, with citations.»

### Assets and tiers

«Customer data first, with citations, then the tier table.»

| Subsystem | Tier | One line |
|---|---|---|
| «name» | «tier» | «why» |

---

## Risks, stated first

Ranked by the rule stated in Impact across the deployment. Availability is not ranked.

<!-- The preamble states the rule once and nothing else; an argument about one risk's
place goes in Impact. Each risk: a heading sentence that names the hazard its gaps leave
unobserved, then two to five sentences with citations (count them), then the ids on one
closing line. A marker for an unconfirmed item goes after the sentence it qualifies, never
inside it. For a system evidenced by a document: the heading names the hazard in the
source's words; where the source names a component's state as a main cause, the risk that
carries it names that state in its heading, even when the component is observed rather
than an observer; a heading says "no stated observer" only where no observer of that state
appears anywhere in the source, and "no observer against its limit" where something
measures the state but nothing acts at the limit. -->

1. **«The risk in one sentence, naming the hazard left unobserved.»** «Two to five
   sentences with citations: the path, the precondition, what it reaches.»
   Ids: «rows, chains».

---

## The architectural model

### The ring test

«Edges, the requirements table, the shape.»

### Coordinators and super-rings

| Candidate | Can stop what | (1) | (2) | (3) | (4) | Result |
|---|---|---|---|---|---|---|

---

## The structure against the model, property by property

«The scorecard and the evidence per verdict.»

---

## Missing structural components

«Per subsystem, descriptive only. Then the hazards table as pass 3 verified it: each
observed component, its hazardous state and the observer that checks it, or none. Then the
read-backs table as pass 3 verified it, with one sentence saying that provenance is who
wrote the object as the store itself records it, or a signature or MAC under a key only the
writer (and, for a MAC, the reader) holds (an owner field or label a writer can set is
content, unless the store forces it to match the writer on every write), and shape is
whether its content matches what the system's own writer produces, or, where nothing in the
system writes it, the format the reader parses; and that write access the store enforces is
listed as who can write it, not as a provenance check, while a schema the store enforces on
every write is a shape check. Then the deputies and mints table as pass 3 verified it, with
one sentence saying that a deputy is a component acting for another position and a mint is a
place authority is created or handed on, and that every mint, and every deputy whose next
check sees only its own identity, or the requester's identity without every restriction on
the requester, needs a check that keeps it within the requester's or the minter's authority,
every restriction on the requester's or the minter's credential included. Then the stated
exclusions as pass 3 verified them, each with its disposition: the row or rows that hold it
(from pass 2, their ids from pass 3); another check at the lines that covers it; covering
not stated (a check the pass finds elsewhere whose lines are not in the evidence, or that a
document describes without mentioning what is left out: a U id, the row conditional on it);
a refusal, only where a line shows the system refusing the act the excluded check would have
decided; delegated to a component the exclusion's own line names and whose lines are not in
the evidence, listed with the delegation boundaries (no row of its own, but never removing a
row another rule gives for the same missing check, such as a named object's, a sibling-set
member's or a pair's whose binding, or a key's whose correspondence, is not stated,
conditional on its U id; the delegation states the check is made elsewhere, not that it is
absent, so the object's, the member's or the pair's binding is not stated even in a source
tree); an availability claim, listed with the availability claims and not evaluated; or no
position or condition reaches it and no position gains from it, with the reason. Then the
key records as pass 3 verified them, each with the row that holds its gap, or none and why.
Then the named objects and the sibling sets as pass 3 verified them, each with the row that
holds its gap, or none and why.»

---

## The present halt paths

- **H1** «trigger» → «what stops» (`«path:line»`). «How far it propagates.»

«The continue-on-fault paths, counted, and where they are scored.»

---

## Findings, in STRIDE

Structural facts every row rests on: «the facts many rows share, cited once».

### S, Spoofing

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| S1 | «(n)» | «name» | «B1/B2/B3, crossing» | «threat» | «what is gained, lost, how far; for "any", what `judging-rules.md`, "The widest reach is named", asks» | `«path:line»` | «property / ring / constraint» | «present, or what happens instead» |

### T, Tampering

### R, Repudiation

### I, Information disclosure

### D, Denial of service

File every row by its effect: a continue-on-fault path whose effect is accepting a forged
identity goes under S, one that grants an unearned privilege under E. Under D go the
continue-on-fault paths whose effect is service the model scores as lost or degraded.
Availability claims go in their own section, unranked.

### E, Elevation of privilege

### Found by the chain hunt, verified

«Rows M1 onward, same columns, corrections marked.»

---

## Chains

### Source-supported

#### «Id». «Name»

**Entry points.**
- «Required / optional / one branch / one cause / the reader», «actor, position»: «what
  it needs» (`«path:line»`).

**Steps.**
1. «Step» (`«path:line»`).

**Seam crossed.** «From what into what.»

**Combined impact.** «What the join reaches that no single gap reaches alone. Halt: ...»

**Composition.** «Row ids joined.»

### Conditional on a probe

<!-- For a system evidenced by a document: "Conditional on an unconfirmed item". -->

### Deployment assumption

<!-- For a system evidenced by a document: "Design assumption". -->


### Rejected

- **«Candidate».** «The source reason, with lines; where a premise failed, the premise and
  the restatement tested.»

---

## Impact across the deployment

Ordering rule, stated once: «...».

1. «Position»: «what it reaches, ids».

---

## Delegation boundaries

Listed, not followed:

- «Component»: «what is delegated» (`«path:line»`).

---

## Availability and performance claims, listed and left unevaluated

- «Claim» (`«path:line»`).

Settling any of these means modeling the structural alternative, which this audit does not
do.

---

## Still unsettled

1. **«Question.»** «What would settle it.» «For a question pass 5 left open: raised by the
   chain verification, not ruled.»

---

## Counts

| | |
|---|---|
| Rows | «n by letter» |
| Chains that compose | «n of n candidates» |
| Chain candidates rejected | «n» |
| Halt paths | «n, how far they reach» |
| Continue-on-fault paths | «n» |
| Observers inventoried | «n» |
| Read-backs | «n, n with no provenance check, n with no shape check» |
| Deputies and mints | «n components in n rows, n rows with no check, n rows with a restriction not shown to reach» |
| Key records | «n, n with a row, n not stated» |
| Named objects | «n inputs naming n objects: n bound, n needing none, n with a standing row, n with a row conditional on a U id, n availability claims, n with no row and why» |
| Sibling sets | «n sets of n members: n with the check, n covered by another machine check, n with a standing row, n with a row conditional on a U id, n availability claims, n with no row and why» |
| Stated exclusions | «n: n with a row, n covered, n covering not stated, n refusals, n delegated, n availability claims, n not reached» |
| Rings at any layer | «n» |
| Coordinators | «n of n candidates» |
| Scorecard | «n gaps, n satisfied, n not required» |
| Availability claims, unevaluated | «n» |
| Unsettled questions | «n» |

**The shape of it.** «One paragraph: the structure, and what sits at the top of the risk
list.»

<!-- For a system evidenced by a document, one more paragraph here: how the design,
standards and approval process let the system exist, with lines; an observation, not a
second audit (../reference/general-systems.md). -->


---

## Change note

«Every correction applied after the passes (pass 5's reach-back corrections, then the
sweep's), each with the line it changed and the source line that settles it, each citation
with its file name; "None." when there is nothing to list; changes after the sweep under a
"### Post-review changes" subheading. Left out of the standalone copy.»

<!--
Standalone copy, in this order: a self-contained introduction; "Model in brief" (the
model's constraints, properties, structure, tiers and boundaries in one page); the system
in brief with tiers; risks stated first; the architectural model; the structure against
the model; missing structural components; the present halt paths; "Keys" (actor key,
numbered entry-point key, evidence path rules, halt-on-fault rule, and what the
[corrected] mark covers: the verification passes, while the sweep's corrections are
applied in place without a mark); Part A threats (the
STRIDE tables and the chain hunt's rows); Part B chains; Part C rejected chains; Part D
impact; Part E seams not followed (the delegation boundaries, with the integration surface
counted from the tree); Part F an
entry-point index mapping every row and chain to its entries; availability claims; still
unsettled; counts and the shape of it. No change note, and no reference to the workspace,
the kit or the pass files.
-->
