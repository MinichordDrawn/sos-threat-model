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
what the customer data is and where it lives, with citations, before anything else. Where
the system's failure reaches the public's safety instead, the public-safety floor applies
the same way.

The tier sets the bar the later steps score against. A bounded observer on a cron and an
alarm meets its bar, and the absent ring there is not a gap. Record the tier and one line
of justification per subsystem.

A library is tiered and scored like any system, whether or not it runs a process of its
own. Example programs and test helpers carry no customer data and sit at the Bounded tier.
A subsystem that decides whether customer data or an identity is accepted sits at the
customer-data floor, even when the data itself lives in the importing program, so the full
stack is required of it; where the library has nowhere to host that stack, the property is
a gap at that decision, not N/A. Score the importing program as the hub the structure
would need, judged at the structure's own scale.

## Step 1. Map the rings, layer by layer

Map every observer. A wide net catches them: health checks, gates, refusals, halts,
liveness loops, watchdogs, retries, supervisors, elections, revocation, validation at a
boundary, anything periodic in the core, and every callback that reports a result. For
each, record: the check it makes, the file and line, where it reports, and what it does
on a fault.

Give each entry a role before scoring anything: **observer** (it watches something and
reports or acts on what it finds), **observed component** (the work, the data, a passive
barrier that watches nothing), **B2 control** (a check a person performs, or a person's
means to switch an observer off, whose path to that observer's absence is also listed as a
removal path), or **signal-path device** (it only records or carries a
signal). The scorecard takes observers only; the others are recorded where their roles
put them: components in the missing components, B2 controls in the STRIDE rows and the
removal paths, signal-path devices on the edges they carry.

Treat each prescribed response (a runbook step, an operating procedure, a regulation's
required action) as an actuator on the paths it touches, and test it like a halt path: can
the prescribed response itself be the fault in the state where it is prescribed?

Treat each read-back as a boundary. Wherever the system reads a stored object back and acts
on it (a snapshot it restores, a cached entry it serves, a configuration it saved and loads
again, a queued message it replays, a record or log entry it acts on later, a stored item it
draws on), the read is an input like any other, whoever wrote the object. Record two checks
separately: who wrote the object (provenance: an attribute the store itself sets from the
writer's identity, or a signature or MAC as `judging-rules.md` defines it; never another
field a writer can set, unless the store itself forces it to match the writer on every
write), and whether its content has the shape the system's own writer produces (which
fields, which values). Each counts only where it is made at or after the read and before
anything is applied, with one exception: a schema the store itself enforces on every write,
whoever writes, is a shape check, recorded with its lines. A check the writer makes before
it stores the object is neither. Write access the store enforces is recorded as who can
write the store, never as a provenance check: it bounds the positions that can write, not
who wrote this object. Where nothing in the system writes the object (a file an operator
writes), the reference shape is the format the reader parses, and the record says so; at a
seam between two modeled packages it is what the writing side produces (`judging-rules.md`).

A position that can write the store is not bound by the format the system's own writer
produces, so a description of what the writer stores is not a bound on what the store holds.
Name the object by the store that holds it, not by what the system's own writer puts there.
Who can write the store is a claim like any other, settled at the lines (for a field of a
relayed message the relaying side stores, "A relayed message is written by its sender"
decides who wrote it): a statement of what the system writes names the intended writer, not
every position that can write the store. Where the source does not state the store's write
access, record it as not stated, an unconfirmed item, never as the system's writer alone.
For each read-back, name what is applied (named fields, or everything the object contains;
where the reader applies the whole object, say so rather than listing the writer's fields)
and what a field or a value outside that reference shape would reach once applied.

What the system's own writer produces includes what it checks before it writes. Where that
writer has the role observer in the inventory (it checks the value before storing it:
validates it, derives it from a source it checks, or selects it from configured choices), a
value its check would refuse, or its selection would never choose under the configuration in
force at the read, is outside the reference shape, even in a field the writer fills; a value
chosen under an earlier configuration is outside it too, recorded as chosen under that
configuration, and an object holding one is one that did not pass the check. That check
still counts as no check at the read: it sets what the read-back's shape check must match.
Name that observer beside the read-back. A read-back with no shape check that makes the same
check (a B2 control's check counts as none) bypasses that observer for every object that did
not pass it: one another position writes, unless a provenance check confines the read to
that writer (for a relayed message, to the fields that writer alone writes: "A relayed
message is written by its sender"), one a condition alters after the write (a check that
binds the whole content to that writer leaves neither of these (for a relayed message, for
the fields that writer alone writes: "A relayed message is written by its sender")), and one
holding a value chosen under an earlier configuration. Record the bypass as an edge from the
read-back to that observer, with what reaches past it, for the chain hunt to walk. At a
seam, the writing side's check stands in the same place.

An object can name the authority its reader acts under: one field selects an account, an
issuer, a key, a tenant, a role or a configuration the reader looks up and acts with. Where
the reader applies another field of the same object under that authority, what the authority
holds or would choose is part of the reference shape for the applied field. Record each such
pair (the field that names the authority, the field applied under it) and the check at or
after the read that binds the two, or none; a check that the authority exists or has the
right type, a signature or MAC under another writer's key, and write access, the authority's
own included, bind nothing else, while a check that confines the input to the authority
itself, or a constraint the store enforces on every write binding the naming field to the
writer, binds the pair (a field it relays for another position excepted, unless that
position is the authority the pair names: "A relayed message is written by its sender"); a
pair with none is unbound, and a gap where a position that cannot act under the authority
writes the input and gains what it lacked (`judging-rules.md`, "A named authority binds only
what it chose"). The same holds for an input that is not stored: a request, message or call
that names the authority it is served under and carries a value applied under it is judged
the same way, and an unbound one is a STRIDE row (Step 3) wherever a position that cannot
act under the authority directly can write it (or a value its reader copies into it).

Record each deputy and each mint of authority (`judging-rules.md`, "A deputy carries whom it
acts for", "Minted authority is bounded by its minter" and "Identity is not authority"). A
deputy is a component that, on another position's request or input, takes an action a
further check decides on (a call, a write, a file opened, under its own identity or one it
passes): record whom it acts for, the identity the next check down sees, and the deputy's
own check at or after it takes the request that the position it acts for holds the right to
what it asks (where the next check sees both the requester's identity, as the deputy
authenticated it from the requester's credential (a field of a message it relays carrying
that identity only where the deputy alone writes the field: "A relayed message is written by
its sender"; or an entry point did and passed it on a channel only that entry point can
write, with lines (the identity it took from the requester's credential; a field of the
message it relays carries that identity only where the entry point alone writes the field,
which "A relayed message is written by its sender" decides even on a channel only the entry
point can write), or the next check verifies the requester's own credential, forwarded
unchanged), and every restriction on the requester (carried by its credential or held by the
entry point's policy for it), that next check), or none (for a document, none stated, a U id
and the deputy's row conditional on it, unless a line states its absence), and, for a deputy
that queues or defers the act, whether a later reduction of the requester's authority
reaches it, or not stated (an unconfirmed item; in a source tree, for each kind of
reduction, where the lines of the check at the act or at each use are in the evidence and
read nothing that reflects that reduction of the minter's or the requester's own credential
(a revocation, its expiry, a current role), and no other line removes or marks what was
minted or queued when it happens, they show it does not, unless a line shows a component
outside the evidence holding what was minted or queued, its removal then not stated, a U
id); an identity the request merely names, or one an entry point passed on a channel others
can write or whose writers are not stated (with a U id, the pair's row conditional on it for
those writers; for a field of a message an entry point relays for the requester, "A relayed
message is written by its sender" decides who writes it) where the next check does not
itself verify the requester's credential, is a pair (`judging-rules.md`, "A named authority
binds only what it chose"); the hop from the deputy to its next check is a channel like any
other: where a position other than the deputy can write it, what the next check sees is that
position's too, and where its writers are not stated, a U id, the row conditional for those
writers. A mint is any place the system issues authority on a request or an event (a
configuration it only loads is a read-back, not a mint); the minter is the position whose
authority is handed on (the position that asks, and any position it asks on behalf of; the
scope falls within each), not the component that signs or stores it: record the scope
minted, the check, at minting or at each use, that it falls within the minter's own
authority, or none, and whether a later reduction of the minter's authority reaches what was
minted, or not stated (an unconfirmed item; in a source tree, for each kind of reduction,
where the lines of the check at the act or at each use are in the evidence and read nothing
that reflects that reduction of the minter's or the requester's own credential (a
revocation, its expiry, a current role), and no other line removes or marks what was minted
or queued when it happens, they show it does not, unless a line shows a component outside
the evidence holding what was minted or queued, its removal then not stated, a U id). Each
goes in the deputies and mints table (DA), with its lines, one row for each kind of
credential that can drive it (a credential type or a way of narrowing one: each principal
type; a token narrowed in scope, use or target; a caller narrowed by the entry point's own
policy; a delegated credential; not each value a restriction can take; for a mint on an
event, the event and the position whose authority it hands on), with that credential's
restrictions (a validity window among them where the token itself is presented at the act)
and whether each reaches a check that decides the act (the deputy's own, the next check, the
minting check or the check at each use; `judging-rules.md`, "Identity is not authority").

For each check (an observer's, a deputy's own, or a B2 control's, which binds nothing and
whose record serves the chain hunt alone) that decides on an object by a key, record the key
it reads and the key that identifies the object where the act lands, each with its line,
and, where the two are in different terms, which part each part of the check's key stands
for, or not stated (`judging-rules.md`, "A check binds only the key it reads"; an
unconfirmed item only where a line shows two objects can share a part the check may not read
and a position can create, name or be granted one). List every line where the evidence says
a check or a control leaves something out, with what it leaves out, as a stated exclusion
(SE), recorded with the missing components (`judging-rules.md`, "A stated exclusion is a
stated absence"). For every input that names more than one object (a container and an item
it holds, a parent and a child), record each object and the check that binds it, a line
showing it needs none, an availability claim, or none (in a source tree with the code in the
evidence, none; not stated or none stated where the evidence is silent or an exclusion's own
line delegates the check to a component outside it), as a named object (NO;
`judging-rules.md`, "Every object an input names needs its own binding"); and for every
machine check the evidence makes, requires or recommends ("must" or "should"; one it only
permits, "may", founds nothing, and so does a line leaving whether to check to an
implementation or a later design, or one addressed to a caller or to code an integrator
writes), for one of a set of like inputs or acts, record each member's check, a line showing
another machine check covers it, an availability claim, or none (in a source tree with the
code in the evidence, none; not stated or none stated where the evidence is silent or an
exclusion's own line delegates the check to a component outside it; a person's check founds
no set and covers no member), as a sibling set (SS; `judging-rules.md`, "A check stated for
one is owed by its like").

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

For each missing ring, mark each component present or absent. The last three, an observer
for each hazard, an observer for each read-back and a check for each deputy and each mint,
are recorded for every observed component, read-back, deputy and mint whether or not a ring
is missing:

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
- **An observer for each hazard.** For each observed component, name the state of it that
  reaches the floor, in the source's words (an operating state outside its analysed
  envelope, a corrupted record, an unverified download), and the observer that checks that
  state against known-good. A hazard with no observer is a missing observer. Record it
  here with its lines; every later pass carries it, the evaluation as a row wherever a
  position reaches it, the chain hunt as a candidate. Taking a component off the scorecard
  never takes its hazard out of the audit.
- **An observer for each read-back.** For each stored object the system reads back and acts
  on, who can write the store (with its lines, or not stated), the provenance check and the
  shape check (each with its lines, or none), what is applied, each pair of a field naming
  the authority the reader acts under and a field applied under it, with the check that
  binds them, or none, and, where the system's own writer has the role observer and no shape
  check makes the same check, which observer the read-back bypasses. A missing shape check
  is a missing observer even where provenance is checked, and a missing provenance check is
  one even where shape is. A check that binds the whole content to its writer fills both,
  but binds a pair only where that writer is the named authority (`judging-rules.md`).
- **A check for each deputy and each mint.** For each deputy whose next check down sees only
  the deputy's identity, or not every restriction the requester's credential carries, the
  check that the position it acts for holds the right to what it asks; for each mint, the
  check that the scope minted falls within the minter's own authority, every restriction on
  the minter's credential included. Either missing is a missing observer.

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
