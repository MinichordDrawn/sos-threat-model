# «System» observer audit: findings

Working template for passes 1 and 2: pass 1 fills Steps 0 to 1.5 (the ring map), pass 2
the properties scorecard. Fill every «placeholder». Delete rows and blocks that do not
apply. Follow `../reference/writing.md`.

Cell codes: **G** gap, confirmed at the cited line. **S** satisfied. **N/A** the tier does not
require this stack (name the tier). Every observer satisfies every property; only the tier
lowers the bar.

Ids, the same in every pass so none collides with another: **O** observers, **OC** observed
components, **BC** B2 controls, **SP** signal-path devices, **H** halt paths, **C**
continue-on-fault paths, **RP** removal paths (B2 paths that remove an observer), **PR**
prescribed responses, **U** unconfirmed items, **DG** disagreements between sources, **RB**
read-backs, **DA** deputies and mints, **SE** stated exclusions, **NO** named objects,
**SS** sibling sets, **SC** corrections of the survey, **GR** scorecard groups; the STRIDE
letters **S T R I D E** for rows, **M** for the chain hunt's rows, **X** for chains. A pass
that needs another kind picks a prefix that is none of these. A row refiled under another
letter keeps its id; count rows by the section they sit in, and say so in the counts.

---

## System in brief

- **Purpose.** «what it does, two lines»
- **Customers, in two senses.** «who runs it; who it acts on or for»
- **Its own goal, in its own words.** «quote», `«path:line»`

## Step 0. Consequence tiers

Customer data first: «what customer data exists, where it lives, citations».

| Subsystem | Carries customer data? | Tier | Why |
|---|:---:|---|---|
| «name» | «yes/no» | «tier» | «one line» |

## Step 1. Ring topology

### Observer inventory

| # | Entry | Role | file:line | What it checks | Reports to | On fault |
|---|---|---|---|---|---|---|
| «O1 / OC1 / BC1 / SP1» | «name» | «observer / observed component / B2 control / signal-path device» | `«path:line»` | «check; for a check deciding on an object by a key, the key it reads and the key that identifies the object where the act lands, and, where the two are in different terms, which part each part of the check's key stands for, with lines, or not stated (a U id only where a line shows two objects can share a part the check may not read and a position can create, name or be granted one; a stated exclusion naming a part the key leaves out (one delegating the check to a component outside the evidence excepted: that part's correspondence not stated, a U id, and a row conditional on it, only where a line shows two objects can share that part and a position can create, name or be granted one) states that part's correspondence: give its SE id, no U id, and where that part alone makes the row standing, the other parts' correspondence needs no U id for it either (in a source tree, where the code at the check's lines shows it reading that part, the code settles it: cite that line, and that part leaves no gap and needs no U id); a machine check whose key is identical to the identifying key binds the object whatever the naming, a B2 control's check binding nothing whatever key it reads, its key record serving the chain hunt alone; the row id from pass 3, or none and why)» | «observer, log, UI, nothing» | «halt, error, continue» |

Only entries with the role observer go on the scorecard (`../reference/method.md`, Step 1).

### Ring requirements

| Requirement | Present? | Evidence (file:line) |
|---|:---:|---|
| A cycle of at least three mutual observers | «yes/no» | «...» |
| Each observer checks one, reports to a different one | «yes/no» | «...» |
| One +1 that checks all observers including itself | «yes/no» | «...» |
| Nested rings, where the structure needs them | «yes/no/N/A» | «...» |

**Shape:** «no ring / star / passive hubs / isolated spokes / ring». «One or two
sentences.»

### Coordinators and super-rings

| Candidate | Can stop what | Checks every observer | Takes reports back | Surface check | In the ring | Result |
|---|---|:---:|:---:|:---:|:---:|---|
| «name», `«path:line»` | «...» | «yes/no» | «yes/no» | «yes/no» | «yes/no» | «passes / fails» |

## Step 1.5. Missing structural components

Per subsystem: cycle, coordinator, check and report separation, halt path with
propagation, upward chain, each present or absent, descriptive only.

### Hazards and their observers

One row per observed component (role "observed component" in the inventory).

| Component | Hazardous state, in the source's words | Evidence | Observer that checks it against known-good |
|---|---|---|---|
| «OC1 name» | «state» | `«path:line»` | «O-id, or none: a missing observer» |

### Read-backs

One row per stored object the system reads back and acts on (`../reference/method.md`, Step
1), named by the store that holds it, not by what the system's own writer puts there. The
writer's format is what the system's own writer produces, or, where nothing in the system
writes the object, the format the reader parses, and the row says which; a position that can
write the store is not bound by it. Where the system's own writer has the role observer (it
checks what it stores: validates it, derives it from a source it checks, or selects it from
configured choices), its check is part of the writer's format: a value it would refuse or
never choose under the configuration in force at the read is outside it, though the check
itself counts as no check at the read. Where no shape check makes the same check (a B2
control's check counts as none), the last column names that observer as bypassed and says
what reaches past it: objects another position writes, unless a provenance check confines
the read to that writer (for a relayed message, to the fields that writer alone writes: "A
relayed message is written by its sender"), objects a condition alters after the write (a
check that binds the whole content to that writer leaves neither of these (for a relayed
message, for the fields that writer alone writes: "A relayed message is written by its
sender")), and objects holding a value chosen under an earlier configuration. Where one
field names the authority the reader acts under (an account, issuer, key, tenant, role or
configuration it looks up) and another field is applied under it, the shape column records
the check that binds the applied field to that authority, or none, and the last column names
a pair with none as "unbound: «applied field» under «naming field»" and says what the
authority lends to a value the writer chose (`../reference/judging-rules.md`, "A named
authority binds only what it chose"). Who can write the store is settled at the lines (for a
field of a relayed message the relaying side stores, "A relayed message is written by its
sender" decides who wrote it); where the source does not state it, write "not stated" with
its U id, the row conditional on it for those writers. Provenance is an attribute the store
itself sets from the writer's identity, a signature under a key only the writer holds, or a
MAC under a key only the writer and the reader hold; an owner field, label or name a writer
of the store can set is content, never the provenance column, unless the store itself forces
it to match the writer on every write. A check the writer makes before storing is neither
check; a schema the store itself enforces on every write is a shape check; write access the
store enforces goes in "Who can write the store", never in the provenance column. For a
system evidenced by a document, a check the document does not describe is "none stated", not
"none": a U id, and the row it feeds conditional on it.

| # | Object and store | Read at | Who can write the store | Provenance check at or after the read | Shape check at or after the read, or the store's own schema | What is applied | What a field or value outside the writer's format reaches |
|---|---|---|---|---|---|---|---|
| «RB1» | «name» | `«path:line»` | «positions, with lines, or not stated (U-id)» | «O-id with line; a BC-id with line, which discharges nothing and leaves the observer missing; or none» | «O-id with line; the store's schema with its lines; a BC-id with line, which discharges nothing and leaves the observer missing; or none» | «named fields, or everything the object contains» | «what it reaches, or not settled; where no shape check makes the writer-observer's check, "bypasses «O-id or BC-id»" and what reaches past it; for a pair no check binds, "unbound: «applied field» under «naming field»" and what the authority lends» |

### Deputies and mints

One row per component that acts for another position (a deputy) and per place the system
creates or hands on authority (a mint), for each kind of credential that can drive it
(`../reference/method.md`, Step 1; `../reference/judging-rules.md`, "A deputy carries whom
it acts for", "Minted authority is bounded by its minter" and "Identity is not authority").
For a deputy: whom it acts for, the identity the next check down sees, and the deputy's own
check that the position it acts for holds the right to what it asks. For a mint: what is
minted from whose authority (the position that asks, and any position it asks on behalf of;
the scope falls within each), the scope minted, the check, at minting or at each use, that
the scope falls within the minter's own authority, and whether a later reduction of the
minter's authority reaches it. A check that the request is well formed, that its target
exists, or that authenticates the requester or the deputy is neither check. An identity the
request merely names, or one an entry point passed on a channel others can write or whose
writers are not stated (with a U id, the pair's finding row conditional on it for those
writers; for a field of a message an entry point relays for the requester, "A relayed
message is written by its sender" decides who writes it) where the next check does not
itself verify the requester's credential, is a pair under "A named authority binds only what
it chose", and the DA row names the pair (its RB id where the input is stored; pass 3 adds
the STRIDE id). A deputy needs no check of its own where, and only where, its next check
sees both the requester's identity, as the deputy authenticated it from the requester's
credential (a field of a message it relays carrying that identity only where the deputy
alone writes the field: "A relayed message is written by its sender"; or an entry point did
and passed it on a channel only that entry point can write, with lines (the identity it took
from the requester's credential; a field of the message it relays carries that identity only
where the entry point alone writes the field, which "A relayed message is written by its
sender" decides even on a channel only the entry point can write), or the next check
verifies the requester's own credential, forwarded unchanged), and every restriction on the
requester (carried by its credential or held by the entry point's policy for it): the check
column names that next check for the restrictions shown to reach it; for one whose reach is
not stated it reads "none unless «U-id» settles it", and the gap's row stands, conditional
on it. A deputy or mint that more than one kind of credential can drive takes one row for
each kind (a credential type or a way of narrowing one: each principal type; a token
narrowed in scope, use or target; a caller narrowed by the entry point's own policy; a
delegated credential; not each value a restriction can take; for a mint on an event, the
event and the position whose authority it hands on): the DA row names the kind and its
restrictions (a validity window among them where the token itself is presented at the act),
and whether each reaches a check that decides the act (the deputy's own, the next check, the
minting check or the check at each use), with a line, or not stated with a U id. A line
saying the next check applies the requester's permissions settles which identity that check
uses, and a restriction only where that check's own policy holds it; a check reads a
restriction only where a line shows it reading it, from its own policy, from the entry
point's policy read directly, or from what is passed to it, and a restriction is passed on
only from a credential the deputy verified, one the next check itself verifies, forwarded
unchanged, or the entry point's own policy on a channel only that entry point can write,
with lines (a relayed field the requester also writes is not such a channel: "A relayed
message is written by its sender"); where the entry point's policy is passed on a channel
whose writers are not stated, it is a pair conditional for those writers, a U id, its reach
for the holder staying as the entry point set it, and a restriction the request merely
names, or the entry point's policy on a channel others can write, is a pair; a credential
the next check itself verifies needs no channel test; the hop from the deputy to its next
check is a channel like any other: where a position other than the deputy can write it, what
the next check sees is that position's too, and where its writers are not stated, a U id,
the row conditional for those writers; where the lines of the check that decides the act are
in the evidence and do not show it reading the restriction, it does not reach, and where
they are not (a component outside the tree, a check a document names but does not describe,
or a description of the check that does not mention the restriction), its reach is not
stated, with a U id, unless a line states the absence; record only restrictions a line shows
the credential or the entry point's policy carrying. Each deputies and mints row gives the
id of every finding row it feeds (pass 1 gives RB ids; pass 3 adds the STRIDE ids); rows
entered from different positions (whoever writes a named input or a value copied into it,
whoever makes a deputy act, the holder of a restricted credential) are separate findings,
the writers of one input sharing its pair's row, and a value copied from one input into
another being one pair, at the last check that should bind it; within one entry position one
missing check is one finding (`../reference/judging-rules.md`, "Identity is not authority").
Where the input that makes a deputy act, or asks for a mint, names the authority it is
served under, the missing check and the unbound pair are one gap: the finding's row is the
pair's, for the position that writes the input or a value the deputy copies into it, and the
last column here gives its id; a position that can make the deputy act without writing the
input is another entry position, and its borrowed-rights row stands as the deputy's row
where it gains through the act what it lacked (changing only when or how often an act runs
whose input another position wrote is an availability claim where a line shows running it
again changes nothing more; otherwise the row stands, conditional on a U id where that is
not stated); a restriction's row, entered from the holder of the restricted credential,
stays its own row, except a restriction passed in a field the requester also writes, which
is that pair's; where the holder of a restricted credential also writes a pair the deputy
acts on, the pair's row holds the restriction's gap too, its impact naming what reaches past
the restriction. For a system evidenced by a document, a check the document does not
describe is "none stated", with a U id, and any finding row it feeds stands conditional on
it.

| # | Deputy or mint | Component | Acts for, or minted from, and the credential kind | What the next check sees, or the scope minted | The check that binds it to the requester's or the minter's authority | What a position reaches through it |
|---|---|---|---|---|---|---|
| «DA1» | «deputy or mint» | «name, `«path:line»`» | «position, and the kind of credential of the position acted for, or of each minter whose authority is handed on, with its restrictions (for a mint on an event, the event and the position whose authority it hands on), with lines» | «identity, or scope; whether each of the credential's restrictions reaches a check that decides the act (the deputy's own, the next check, the minting check or the check at each use), with a line, or not stated (U-id); for a mint, or a deputy that queues or defers the act, whether a later reduction of the minter's or the requester's authority reaches it, or not stated (U-id; in a source tree, for each kind of reduction, where the lines of the check at the act or at each use are in the evidence and read nothing that reflects that reduction of the minter's or the requester's own credential (a revocation, its expiry, a current role), and no other line removes or marks what was minted or queued when it happens, they show it does not, unless a line shows a component outside the evidence holding what was minted or queued, its removal then not stated, a U id)» | «O-id with line; a BC-id with line, which discharges nothing and leaves the observer missing; the deputy's own check with its line; the next check with its line, for the restrictions shown to reach it; "none unless «U-id» settles it" for one whose reach is not stated; or none» | «what it reaches, or not settled; the id of each finding row it feeds (the pair's, the deputy's, a restriction's), never a second row for one defect» |

### Stated exclusions

One entry per line where the evidence says a check or a control leaves something out ("not
covered", "not implemented", "out of scope", "todo", "TBD", deferred to a later design,
release or the implementation, or a non-goal, said of a check, a control, a restriction, or
the scope of a credential or an authority; or a "must" or "should" addressed to a caller or
to code an integrator writes; `../reference/judging-rules.md`, "A stated exclusion is a
stated absence"): the line, what is left out, and one disposition: the row or rows that hold
it (from pass 2, their ids from pass 3); another check at the lines that covers it; covering
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
position or condition reaches it and no position gains from it, with the reason. The absence
of a check is never a refusal. An excluded halt, alert or fault check (a limit on demand,
such as a rate limit or a quota, is not a fault check; a limit on the system's own retries
after a fault is one) is a continue-on-fault path, and the state it leaves out goes in the
hazards table with no observer. An exclusion is an availability claim only where its only
effect is on how much or how long the system serves (capacity, rate, uptime), with no fault
left unobserved (demand beyond capacity is not a fault here) and no position gaining access,
data or authority it lacked. A statement that a later design, release or implementation will
decide is not a check. A line about the document's or the project's own scope that names no
check is not an entry. A stated exclusion's row and a read-back's or a pair's row entered
from the same position for the same missing check are one row: give that row's id. In a
source tree, a comment or a document saying so is the project's claim, and the code at the
lines settles whether the check leaves it out. Left to a person (an operator, a reviewer),
it is a B2 control, which discharges nothing; left to a caller or to code an integrator
writes, it is a check the system does not make. Either way its disposition is never
"delegated", and the person, the callbacks a caller supplies and code an integrator writes
do not cover it. Where it names the part a check's key leaves out (one delegating the check
to a component outside the evidence excepted: that part's correspondence not stated, a U id,
and a row conditional on it, only where a line shows two objects can share that part and a
position can create, name or be granted one), its row is the key's row, standing on the
exclusion's line, not conditional on the key record (in a source tree, where the code at the
check's lines shows it reading that part, the code settles it: cite that line, and that part
leaves no gap and needs no U id).

- «SE1»: `«path:line»`, «what is left out», «row or rows (pass 2; their ids from pass 3);
  covering check with its line; covering not stated, U-id and the conditional row's id;
  refusal, with the line showing it; delegated to «component»; availability claim; or no
  position or condition reaches it and no position gains from it, and why»

### Named objects

One entry per input (a request, a message, a call, a stored object read back) that names
more than one object (a container and an item it holds, a parent and a child, a resource and
the record or version it selects, two parties the act joins), or names one identity or
authority the act is applied under while it is authenticated as another position or not
authenticated at all, in one field or across several (a path, a header, a body)
(`../reference/judging-rules.md`, "Every object an input names needs its own binding"). For
each object: the check that binds it (in a document, a check it describes as made, "must" or
"should", never one it only permits, "may"; a "must" or "should" that names the check as one
the system or its implementations make counts, its qualifier kept, and where it leaves only
the mechanism open, it binds the object, its key not stated (an unconfirmed item, with a row
conditional on it, only where a line shows two objects can share a part the check may not
read and a position can create, name or be granted one) ("A check binds only the key it
reads"); one addressed to a caller or to code an integrator writes states that the system
does not make it: a stated exclusion, its row standing on that line; a line leaving whether
to check to an implementation or a later design is none, and is a stated exclusion); a line
showing it needs none (the act is open on that object to every position that reaches the
input, such as a recipient any account may name, and a line letting a position write the
input is never one: that write is what makes the pair; in a source tree, a document, comment
or test the project ships may show it, cited as the project's claim, where the code at the
act's lines makes no check that contradicts it; code that merely omits a check is none, not
this); an availability claim; or none (in a source tree, none at the act's code; where the
code that carries out the act on that object, a call the act makes included, is outside the
evidence, or an exclusion's own line delegates the check to a component outside it, not
stated, a U id; where the object arrives in a field of a relayed message, "A relayed message
is written by its sender" decides whether the requester's value reaches the reader, and
where it leaves that not stated, the relay and the object share one U id; for a document,
none stated, a U id unless a line states the absence). A check that decides on one named
object binds that object only, and a check left to a person binds nothing. An object that is
the identity or authority the act is applied under, where the input is authenticated as
another position, is also a pair, and its row is the pair's. An object with none is a gap
wherever the act serves the position data another position holds, or changes data another
position holds, and the position gains access, data or authority it lacked; an act that
serves no data and changes none, with an effect only on how much or how long the system
serves, is an availability claim. One defect is one row: where an unbound pair's (or one
whose binding is not stated or none stated), a deputy's (only where its next check sees only
its own identity), a restriction's, a stated exclusion's or a key's row is entered from the
same position for the same missing check, that row holds the object's gap, and the last
column gives its id.

| # | Input | Objects it names | The check that binds each | What a position reaches | Row |
|---|---|---|---|---|---|
| «NO1» | «input, `«path:line»`» | «each object, with its line» | «for each object: the check, with its line (to the requester's right, or that the item is in the named container), the embedded container part where the identifier carries one, a line showing it needs none (the project's claim, where no code contradicts it), an availability claim, none (with the act's line), not stated where the code that carries out the act on that object, a call the act makes included, is outside the evidence, or an exclusion's own line delegates the check to a component outside it (U-id), or none stated (U-id)» | «what a position permitted for the other objects, or any position where no check reads the requester's right, reaches by naming one outside them; an availability claim; or nothing, and why» | «row id, or none and why» |

### Sibling sets

One entry per check the evidence makes, requires or recommends (in a source tree, a check
the code makes; in a document, one it describes as made, "must" or "should"; not one it only
permits, nor a line leaving whether to check to an implementation or a later design, or one
addressed to a caller or to code an integrator writes) for one member of a set of like
inputs or acts: members that each carry what the check guards (the same data served, the
same binding of a named identity or object, or the same right exercised over the same object
or kind of object, the right the stated check reads: for a check that re-proves who the
caller is, the right to the act it precedes alone; for a gate (a check on entry to a place
or a resource, such as a door), admission to what its own line says it admits to and nothing
beyond it (a further place several routes reach does not make each route a member); for a
role or permission check, that role or permission exercised over the object or kind of
object the act it precedes changes or serves, with a line; for a limit on demand, the same
capacity drawn on or a secret tested that admits to the same account or right, whatever its
form), with a line for each, whatever their names or routes; a value the code derives from
what it has already checked is a check here; a shared form alone, or a broader identity both
act under, does not make them alike, and an input shown to carry none of what the check
guards is not a member (`../reference/judging-rules.md`, "A check stated for one is owed by
its like"). Where the value the check reads can reach the guarded act from more than one
source (a credential the check derives it from, a field the requester writes into a message
relayed onward, a stored copy, a second authenticator), each source is a member of its own,
and the check covers a source only where a line shows it reading the value from that source;
a line saying the check applies to every request, or that the value passes through the
check's component, settles which requests reach the check, not which sources it reads. A
line scoping the check to one source does not state the absence of a check for another. A
check left to a person makes no set and covers no member: record a like input that skips it
with the B2 control. A member whose only check is a person's has none (for a document, none
stated unless a line states there is no machine check; a line naming only the person's check
does not state it), with the BC id beside it. A comment or document claiming a check, a
person's included, that the code at the member's lines does not make covers nothing, and
goes in the disagreements (a claimed person's check is a B2 control only where a line shows
it is made). A member with none (in a source tree, none at its code; where the code that
carries out the member's act, a call it makes included, is outside the evidence, or an
exclusion's own line delegates the check to a component outside it, not stated, a U id; for
a document, none stated, a U id unless a line states the absence) is a gap wherever a
position reaches, through it, what the check would guard there and gains what it lacked; its
row cites the stated check's line beside its own and keeps a "should" as written. Where the
stated check only limits how much or how long the system serves (a cap on the system's own
retries after a fault is a fault check, not this: a member without it is a continue-on-fault
path, its hazard row filed by its effect), or the member's own act serves no data and
changes none, the member's lack is an availability claim, unless further attempts reach
access, data or authority a single attempt could not. One defect is one row: where a
read-back's, an unbound pair's (or one whose binding is not stated or none stated), a
deputy's (only where its next check sees only its own identity), a restriction's, a stated
exclusion's, a key's or a named object's row is entered from the same position for the same
missing check, that row holds the member's gap, citing the stated check's line and keeping
its qualifier, and the last column gives its id.

| # | What the members share | The stated check | Members and their checks | Row |
|---|---|---|---|---|
| «SS1» | «the shared property, `«path:line»`» | «the check and the member it is stated for, `«path:line»`» | «each other member with its line: the same check at its lines, a line showing another machine check covers it (a person's check covers nothing), an availability claim, none (with the member's line), not stated where the code that carries out the member's act, a call it makes included, is outside the evidence, or an exclusion's own line delegates the check to a component outside it (U-id), or none stated (U-id)» | «row id for each member's gap, or none and why» |

### Present halt paths

- **H1** «trigger» → «what stops» (`«path:line»`). Propagates to «how far».

### Continue-on-fault paths

- **C1** «fault» → «what continues» (`«path:line»`).

### Removal paths and prescribed responses

- **RP1** «the B2 control or setting» removes «observer id» (`«path:line»`).
- **PR1** «the prescribed response», in «the state where it is prescribed»: «whether it can
  be the fault there, and why» (`«path:line»`).

### Disagreements between sources

- **DG1** «what each says», `«path:line»` against `«path:line»`; left as the source has it.

### Execution-observation coupling

«Does execution check an observer's heartbeat and stop when it stops? Citations.»

## Step 2. Properties

| Subsystem | 1 HB | 2 Sub | 3 CSV | 4 SWR | 5 SD | 6 Death | 7 AutoInt | 8 Reflex |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| «subsystem» | «G/S/N/A» | | | | | | | |

**Totals:** «n G, n S, n N/A over n cells».

Evidence per verdict: one bullet per property, citing the lines that settle it.

## Unconfirmed

1. «claim», «where to look», «what would settle it».
