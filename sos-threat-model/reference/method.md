# The method: ring-first gap analysis

## Premise

The 3+1 ring emerges from satisfying all four constraints and eight properties at once,
so it works as a reference architecture: any deviation from it points to a missing
property. The method runs backwards. Find where the ring breaks, then name the gap.

Check structure before information. The three mutually observing nodes are structure:
persistent and rigid. The +1 is information: the active function that uses the ring's
determinacy to act. Information stays reliable only on structure that already holds, so
the ring comes first.

The ring gap is often the root cause of several property gaps, and a ring closes them
together. Finding the broken ring first saves chasing each symptom on its own.

## Step 0. Tier by consequence

Before scoring anything, give each observer subsystem a consequence tier.

| Consequence tier | Required stack |
|---|---|
| Bounded (one service) | Cron and an alarm |
| Significant (multi-team) | Heartbeat and automatic restart |
| Severe (organizational) | Redundant observers, escalation |
| Catastrophic (system-wide) | The full stack: the 3+1 ring |

Check the customer-data floor first: if customer information or data flows through the
observer or the thing it watches, the tier is Catastrophic and the ring is mandatory. Name
what the customer data is and where it lives, with citations, before anything else.

The tier sets the bar the later steps score against. A bounded observer on a cron and an
alarm meets its bar, and the absent ring there is not a gap. Record the tier and one line
of justification per subsystem.

## Step 1. Map the rings, layer by layer

Map every observer. A wide net catches them: health checks, gates, refusals, halts,
liveness loops, watchdogs, retries, supervisors, elections, revocation, validation at a
boundary, anything periodic in the core, and every callback that reports a result. For
each, record: the check it makes, the file and line, where it reports, and what it does
on a fault.

Then record two edges per observer: which observer it checks, and which observer it
reports to. Build the structure from the bottom up:

1. **Base rings.** Group observers into rings: at least three that mutually observe each
   other. An observer in no ring is a gap.
2. **Coordinators.** For each ring, find the +1: the node that checks something about
   every other observer in the ring, including itself, takes their reports and
   validations back, and checks at the surface. A ring with no coordinator is a gap.
3. **Super-rings.** Treat each coordinator as a node one layer up and group the
   coordinators into rings the same way.
4. **Repeat** until the top layer is a single ring, or no ring forms at the next layer.
   The second case is a gap: the structure does not close.

Test every candidate that can stop the system against the four coordinator clauses: it
checks something about every other observer including itself; it takes their reports and
validations back; its check is surface-level; it belongs to the ring. Record the test as a
table, one row per candidate.

Test the map against the four ring requirements and mark each present or missing:

- A cycle of at least three observers that mutually watch each other.
- Each observer checks one other observer and reports to a different one.
- One +1, qualitatively different, that checks all observers including itself.
- Nested rings, where a node is itself a ring (not applicable to a structure that needs
  only one ring; see `judging-rules.md`).

A pairwise edge or a star (many nodes, one hub) counts as a missing ring. Name the shape
the observers actually form: no ring, a star, passive hubs, isolated spokes, a ring.

## Step 1.5. Name the missing structural components

Where a ring is missing, name which structural components the model requires and which
are absent. Stay descriptive: report the missing structure, not a design. The system's
architects know the architecture; the audit names the gap, not a build.

For each missing ring, mark each component present or absent:

- **A mutual-observation cycle.** At least three observers that watch each other and close
  a loop. Absent when every edge runs one way: a chain, a star, a DAG.
- **A coordinator.** A +1 that surface-checks the members and can halt. Absent when the
  only breadth observer is a collection hub that takes no validation back.
- **Check and report separation.** Each observer checks one node and reports to a
  different one. Absent when an observer reports only to itself or to a passive sink.
- **A halt path with propagation.** Any member can halt, and the halt reaches at least two
  others. Absent when a halt stays local. Record how far each existing halt propagates.
- **An upward chain.** A coordinator that carries this ring's health into the ring above.
  Absent when the layer does not close or nothing reports upward.

List the present halt paths and the continue-on-fault paths separately. Record the
execution-observation coupling: does execution check a heartbeat and stop when it stops?

## Step 2. Score the eight properties

For every observer group, score every property **G** (gap, confirmed in code), **S**
(satisfied) or **N/A** (the tier does not require this stack; name the tier). Nothing but
the tier exempts a property. A pure observer satisfies system-wide response, self-defense
and reflexive response through its place in a ring; an observer that cannot is showing the
missing ring, so score that as a gap, not an exemption.

A missing ring predicts specific property gaps:

- No cycle of three: system-wide response (4), self-defense (5), death signaling (6).
- Check target and report target collapsed into one node: self-defense (5).
- No +1: reliance on an external authority, which breaks constraint 4.

For each gap, record the required response under halt on fault: the observer alerts and
the system halts until the fault clears or the privileged actor leaves. Continue-on-fault
behaviour is itself a gap. Graceful degradation, failover that keeps serving, and
Byzantine availability all serve through a detected fault, which serves through a
compromise. Flag every one.

## Step 3. Record the findings as STRIDE

Map each gap to its STRIDE category (spoofing, tampering, repudiation, information
disclosure, denial of service, elevation of privilege). Each finding records:

- the component;
- the entry point the actor needs, from a numbered vocabulary built for this system;
- the actor, by trust boundary (B1, B2, B3), naming any crossing the threat needs;
- the threat, and the file and line that proves it;
- the impact in concrete terms: what an attacker gains, what is lost, the blast radius;
- the property, ring gap or constraint it maps to;
- the halt-on-fault control: present, or what the system does instead.

Then hunt chains: a gap in one observer that defeats, blinds or bypasses another
observer's check, so that the combined impact exceeds what either reaches alone. A chain
records its entry points, its steps with evidence, the seam it crosses, the combined
impact, and a composition line naming the gaps it uses.

## Judge only within the model

Report the structure against this model, not against outside standards. A structure that
does not close into rings is unsafe under these constraints, whatever its conventional
merits. Do not credit a design as superior because it serves availability or performance;
list such claims and leave them unevaluated, not conceded, because settling them means
modeling the alternative structure. State the system's own goal where it clarifies a
deviation. The detailed rules are in `judging-rules.md`.
