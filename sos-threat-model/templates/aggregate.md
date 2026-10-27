# «Systems»: a self-observing-systems threat model of «n» packages

<!--
The aggregate document. Built by ../reference/multi-package.md. Parts B to E are
carried by script from the packages' deliverables and the verified seam files, each
carried citation rewritten once by `resolve_citations.py --rewrite` and nothing else in it
changed. Assembly writes a draft front (the risks in impact order and the
reading guide) for the reviews to anchor on; the register step adds Load-bearing claims;
the final front (Risks to How to read) is rewritten after the reviews, from the validated
body. Follow ../reference/writing.md.
-->

## Risks, stated first

Ranked by severity times detection times exposure. Each entry carries its Part D rank.

1. **«Risk.»** «Path, precondition, reach, citations.» Severity «...», detection «...»,
   exposure «...». Part D rank «n». Ids: «...».

## What the evidence shows and does not

«What the public evidence establishes about real deployments, and what it does not.»

## How fast, and by what process

The exercise began at «start» and finished at «finish». «The pass sequence, the seams and
their verified counts, using only numbers the source files carry.»

## The pattern behind the findings

«One paragraph per boundary: which component treats which neighbour as the place where the
guarantee lives.»

## How to read this document

«The order of the parts; the row schemas (two halves if two sources used two schemas); the
citation prefixes and path rules; the posture rule; scope extensions; source-supported
against inferred; deployment assumptions; the id scheme.»

## Load-bearing claims

| Id | Claim | Citations | Posture or configuration and default | Standing | Rests on it |
|---|---|---|---|---|---|
| LB1 | «...» | `«PFX: path:line»` | «...» | «source-supported / inferred (seam) / deployment assumption» | «ids» |

### Posture matrix

«Which deployments and configurations each risk needs, with the shipped defaults.»

### Currency

| Package | Audited commit | Upstream head at «date» | Cited files changed | Effect |
|---|---|---|---|---|

## The model in brief

«The constraints, the eight properties, the structure, the tiers with the customer-data
floor, the trust boundaries. One page.»

## The «n» trees and how they join

«What each places, what each observes, and the edges between them.»

## The present halt paths

«Per package, numbered with package prefixes, each with how far it propagates.»

## Part A: The combined structure and the ring test

### The observation graph
### The coordinator test
### What the «n» form
### The eight-property verdict across the structure

## Part B: Findings, in STRIDE

«One subsection per STRIDE category; rows keep their source ids and schemas.»

## Part C: Chains

### Group «J»: chains that cross between «stacks»

«New cross-package group first. If empty, say so and why.»

### Group «X»: chains inside «package»

## Part C2: Candidates tested and rejected at the seams

## Part D: Impact across the stack

## Part E: Seams not followed

«Delegation boundaries per package; the closures and unsettled questions from the seams.»

## Availability and performance claims, left unevaluated

## Counts

## Change log

«What each validation pass changed, by count.»
