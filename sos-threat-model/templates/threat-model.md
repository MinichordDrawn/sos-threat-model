# «System»: a threat model of «the tree»

<!--
The single-package deliverable. Fill every «placeholder»; delete what does not apply.
Follow ../reference/writing.md. The standalone copy is built from this file by script
(see the "Standalone copy" note at the end).
-->

This describes one tree, as it stands: «repository» at commit `«hash»` («date»). Every
claim is a file and a line in it, judged within the self-observing-systems model. Nothing
was built or run unless stated; a claim that reading alone cannot settle is marked as
needing a probe.

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

Ranked by «the rule». Availability is not ranked.

1. **«The risk in one sentence.»** «Two to five sentences with citations: the path, the
   precondition, what it reaches.» Ids: «rows, chains».

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

«Per subsystem, descriptive only.»

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
| S1 | «(n)» | «name» | «B1/B2/B3, crossing» | «threat» | «what is gained, lost, how far» | `«path:line»` | «property / ring / constraint» | «present, or what happens instead» |

### T, Tampering

### R, Repudiation

### I, Information disclosure

### D, Denial of service

Continue-on-fault paths the model scores. Availability claims go in their own section.

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

### Deployment assumption

### Rejected

- **«Candidate».** «The source reason, with lines.»

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

1. **«Question.»** «What would settle it.»

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
| Rings at any layer | «n» |
| Coordinators | «n of n candidates» |
| Scorecard | «n gaps, n satisfied, n not required» |
| Availability claims, unevaluated | «n» |
| Unsettled questions | «n» |

**The shape of it.** «One paragraph: the structure, and what sits at the top of the risk
list.»

---

## Change note

«Every correction applied after the passes (pass 5's reach-back corrections, then the
sweep's), each with the line it changed and the source line that settles it. Left out of
the standalone copy.»

<!--
Standalone copy, in this order: a self-contained introduction; "Model in brief" (the
model's constraints, properties, structure, tiers and boundaries in one page); the system
in brief with tiers; risks stated first; the architectural model; the structure against
the model; missing structural components; the present halt paths; "Keys" (actor key,
numbered entry-point key, evidence path rules, halt-on-fault rule); Part A threats (the
STRIDE tables and the chain hunt's rows); Part B chains; Part C rejected chains; Part D
impact; Part E seams not followed (the delegation boundaries, with the integration surface
counted from the tree); Part F an
entry-point index mapping every row and chain to its entries; availability claims; still
unsettled; counts and the shape of it. No change note, and no reference to the workspace,
the kit or the pass files.
-->
