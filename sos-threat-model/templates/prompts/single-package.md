# Pass prompts: single package

Each prompt below follows the common block in `common.md`. Model choice: breadth passes
(1, 2, 4) on a fast, wide model; verification passes (3, 5, 6) and assembly on the most
careful model available.

---

## Pass 1. Ring map

Additional reading: `«KIT»/reference/eight-properties.md` and `«KIT»/templates/findings.md`
(Steps 0 to 1.5 for the shape of sections 2 to 7). The survey,
`«WORK»/scratch/«T»-survey.md`, is the earlier file this pass builds on. Of the method,
Steps 0 to 1.5 apply to this pass.

Where the core is: «directories». Observers to find at minimum: «health checks, gates,
refusals, halts, liveness loops, retries, verification of downloaded or received content,
signature checks, elections, supervision, startup checks, anything periodic, every place
the system runs an external program or opens a URL, every place it reads a stored object
back and acts on it; name the ones the survey found».

Produce `«WORK»/scratch/«T»-ring-map.md` with eight sections:
1. System in brief: purpose, customers in two senses, its own goal in its own words.
2. Step 0 tiers, with the customer-data floor first (what customer data exists and where).
3. Observer inventory table: name, role (observer, observed component, B2 control or
   signal-path device, as `«KIT»/reference/method.md` Step 1 defines them), file:line, what
   it checks (for a check deciding on an object by a key, the key it reads and the key that
   identifies the object where the act lands, and, where the two are in different terms,
   which part each part of the check's key stands for, with lines, or not stated (a U id
   only where a line shows two objects can share a part the check may not read and a
   position can create, name or be granted one; a stated exclusion naming a part the key
   leaves out (one delegating the check to a component outside the evidence excepted: that
   part's correspondence not stated, a U id, and a row conditional on it, only where a line
   shows two objects can share that part and a position can create, name or be granted one)
   states that part's correspondence: give its SE id, no U id, and where that part alone
   makes the row standing, the other parts' correspondence needs no U id for it either (in a
   source tree, where the code at the check's lines shows it reading that part, the code
   settles it: cite that line, and that part leaves no gap and needs no U id); a machine
   check whose key is identical to the identifying key binds the object whatever the naming,
   a B2 control's check binding nothing whatever key it reads, its key record serving the
   chain hunt alone); `«KIT»/reference/judging-rules.md`, "A check binds only the key it
   reads"), where it reports, what it does on fault.
4. The ring test and the resulting shape.
5. Coordinators and super-rings: every candidate that can stop the system, tested against
   the four clauses, as a table.
6. Missing components, descriptive only; where a halt path exists, how far it propagates.
   Include the hazards table: for every observed component, its hazardous state in the
   source's words and the observer that checks it, or none. Then the read-backs table: for
   every stored object the system reads back and acts on, named by its store, who can write
   the store (settled at the lines, or not stated with a U id; for a field of a relayed
   message the relaying side stores, "A relayed message is written by its sender" decides
   who wrote it), the provenance check and the shape check separately, each at or after the
   read and before anything is applied (a schema the store itself enforces on every write is
   a shape check; write access the store enforces goes under who can write the store, never
   as a provenance check), what is applied, and what a field or value outside the writer's
   format (what the system's own writer produces, or, where nothing in the system writes the
   object, the format the reader parses) would reach. Where that writer has the role
   observer (it checks what it stores: validates it, derives it from a source it checks, or
   selects it from configured choices), its check is part of the writer's format but counts
   as no check at the read: name the observer, say what a value it would refuse or never
   choose under the configuration in force at the read reaches, and, where no shape check
   makes the same check (a B2 control's check counts as none), record the read-back as
   bypassing it, with what reaches past it (objects another position writes, unless a
   provenance check confines the read to that writer (for a relayed message, to the fields
   that writer alone writes: "A relayed message is written by its sender"); objects a
   condition alters after the write; and objects holding a value chosen under an earlier
   configuration. A check that binds the whole content to that writer leaves only the last
   (for a relayed message, for the fields that writer alone writes: "A relayed message is
   written by its sender").) Where one field of the object names the authority the reader
   acts under (an account, issuer, key, tenant, role or configuration it looks up) and
   another field is applied under it, record the check at or after the read that binds the
   applied field to that authority, or none, and mark a pair with none as unbound
   (`«KIT»/reference/judging-rules.md`, "A named authority binds only what it chose"); a
   check that the authority exists or has the right type, a signature or MAC under another
   writer's key, and write access, the authority's own included, bind nothing else; a check
   that confines the input to the authority itself, or a constraint the store enforces on
   every write binding the naming field to the writer, binds the pair (a field it relays for
   another position excepted, unless that position is the authority the pair names: "A
   relayed message is written by its sender"). Then the removal paths (RP) and the
   prescribed responses (PR), each tested as `«KIT»/reference/method.md` Step 1 says, and
   any disagreement between sources (DG), with both lines. Then the deputies and mints table
   (DA): every component that acts for another position, with whom it acts for, the identity
   the next check down sees and the deputy's own check on the requester's right (for a
   document, none stated, a U id and the deputy's row conditional on it, unless a line
   states its absence, as one saying the deputy acts on whatever the requester names does),
   or, where that next check sees both the requester's identity, as the deputy authenticated
   it from the requester's credential (or an entry point did and passed it on a channel only
   that entry point can write, with lines (the identity it took from the requester's
   credential; a field of the message it relays carries that identity only where the entry
   point alone writes the field, which "A relayed message is written by its sender" decides
   even on a channel only the entry point can write), or the next check verifies the
   requester's own credential, forwarded unchanged), and every restriction on the requester
   (carried by its credential or held by the entry point's policy for it), that next check,
   or none, and for a deputy that queues or defers the act, whether a later reduction of the
   requester's authority reaches it, or not stated with a U id (in a source tree, for each
   kind of reduction, where the lines of the check at the act or at each use are in the
   evidence and read nothing that reflects that reduction of the minter's or the requester's
   own credential (a revocation, its expiry, a current role), and no other line removes or
   marks what was minted or queued when it happens, they show it does not, unless a line
   shows a component outside the evidence holding what was minted or queued, its removal
   then not stated, a U id); and every place the system creates or hands on authority, with
   its minters (the position that asks, and any position it asks on behalf of, never the
   position that receives what is minted, whose reach with it is the row's impact; the scope
   falls within each), the scope minted, the check, at minting or at each use, that it falls
   within each minter's own authority, or none, and whether a later reduction of the
   minter's authority reaches it, or not stated with a U id (in a source tree, for each kind
   of reduction, where the lines of the check at the act or at each use are in the evidence
   and read nothing that reflects that reduction of the minter's or the requester's own
   credential (a revocation, its expiry, a current role), and no other line removes or marks
   what was minted or queued when it happens, they show it does not, unless a line shows a
   component outside the evidence holding what was minted or queued, its removal then not
   stated, a U id). One row for each kind of credential that can drive a deputy or a mint (a
   credential type or a way of narrowing one: each principal type; a token narrowed in
   scope, use or target; a caller narrowed by the entry point's own policy; a delegated
   credential; not each value a restriction can take; for a mint on an event, the event and
   the position whose authority it hands on), with its restrictions (a validity window among
   them where the token itself is presented at the act) and whether each reaches a check
   that decides the act (the deputy's own, the next check, the minting check or the check at
   each use), or not stated with a U id; a line saying the next check applies the
   requester's permissions settles which identity that check uses, and a restriction only
   where that check's own policy holds it; a restriction reaches a check that decides the
   act only where a line shows that check reads it, from its own policy, from the entry
   point's policy read directly, or from what is passed to it; a restriction is passed on
   only from a credential the deputy verified, one the next check itself verifies, forwarded
   unchanged, or the entry point's own policy on a channel only that entry point can write,
   with lines (a relayed field the requester also writes is not such a channel: "A relayed
   message is written by its sender"); where the entry point's policy is passed on a channel
   whose writers are not stated, it is a pair conditional for those writers, a U id, its
   reach for the holder staying as the entry point set it; a restriction or an identity the
   request merely names is a pair, and so is the entry point's policy on a channel others
   can write, and an identity an entry point passed on, on a channel others can write or,
   with a U id on which the pair's finding row is conditional for those writers, on one
   whose writers are not stated; a credential the next check itself verifies needs no
   channel test; the hop from the deputy to its next check is a channel like any other:
   where a position other than the deputy can write it, what the next check sees is that
   position's too, and where its writers are not stated, a U id, the row conditional for
   those writers; a field of a message a component relays for a requester (an entry point or
   any other relay) is written by that component and by every position that wrote that
   message, the requester included, authenticated or not, whatever the writers of the
   channel on which the component passes it or a provenance check confining the message to
   the component, the writers of the channel into the component being recorded too (not
   stated, a U id, where the lines do not say; a channel on which the component
   authenticates the requester's own credential is that requester's alone, its writers
   needing no U id), unless a line shows the component removing or replacing that field on
   every message it relays on a route, whatever the requester's credential (a removal,
   replacement or refusal that holds only for some routes or credentials settles those
   alone, the rest staying as below), or refusing every message that carries the field (a
   refusal shown for some routes or credentials settling those alone), or building the
   message afresh and copying only fields a line names (a field copied from the requester's
   message staying the requester's); a line showing it adding its own values to a field that
   holds several does not show it removing the requester's, and a line clearing or
   overwriting the whole field does, while a line removing particular values removes those
   alone, the field for the others being neither removed nor replaced, so that for them the
   source-tree and document branches that follow decide; in a source tree with the relaying
   code, a call it makes included, in the evidence doing none of these (removal,
   replacement, refusal, a fresh build), the requester's value reaches the reader and the
   channel is one others can write, and with that code outside the evidence, or in a
   document with no line showing, on the message's route and for its credential, the removal
   or replacement of the field or of the value in question from the source the reader takes
   it from, or a refusal of every message that carries it, or a fresh build with only fields
   a line names (a removal, replacement or refusal shown for one route or credential settles
   that alone) (even where a line shows the requester writing the field or the component
   passing on its own values, unless a line states that the requester's value of that field
   reaches the reader (a line saying only that the message is relayed does not)), whether it
   reaches is not stated, one U id for the relay and any pair, named object or sibling
   member resting on it, on which their row is conditional; where the component is itself
   the deputy, the identity it authenticated is the identity it took from the requester's
   credential; a field of the message it relays carries that identity only where the
   component alone writes the field; the row is entered from every position whose message
   the component relays and that gains through the field (a position the lines confine to
   one scope, by a credential, a deployment or a policy, gains what lies outside it, and a
   position lacks what no line shows it holding, rights a line shows granted outside the
   evidence being not stated), a requester it authenticated included
   (`«KIT»/reference/judging-rules.md`, "A relayed message is written by its sender"); the
   DA row names the pair: its RB id where the input is stored, the STRIDE id added at pass
   3; where the lines of the check that decides the act are in the evidence and do not show
   it reading the restriction, it does not reach, and where they are not (a component
   outside the tree, a check a document names but does not describe, or a description of the
   check that does not mention the restriction), its reach is not stated, with a U id,
   unless a line states the absence; record only restrictions a line shows the credential or
   the entry point's policy carrying; and a check of the restriction against only part of
   what the deputy then does (the first of several targets, or only the incoming request's
   shape) does not by itself make the restriction reach a later hop, while the deputy's own
   check against the whole of what it then asks is the deputy's check
   (`«KIT»/reference/judging-rules.md`, "A deputy carries whom it acts for", "Minted
   authority is bounded by its minter" and "Identity is not authority"). Then the stated
   exclusions (SE): every line where the evidence says a check or a control leaves something
   out ("not covered", "not implemented", "out of scope", "todo", "TBD", deferred to a later
   design, release or the implementation, or a non-goal, said of a check, a control, a
   restriction, or the scope of a credential or an authority; or a "must" or "should"
   addressed to a caller or to code an integrator writes), with what it leaves out and its
   disposition (the row or rows that hold it (from pass 2, their ids from pass 3); another
   check at the lines that covers it; covering not stated (a check the pass finds elsewhere
   whose lines are not in the evidence, or that a document describes without mentioning what
   is left out: a U id, the row conditional on it); a refusal, only where a line shows the
   system refusing the act the excluded check would have decided; delegated to a component
   the exclusion's own line names and whose lines are not in the evidence, listed with the
   delegation boundaries (no row of its own, but never removing a row another rule gives for
   the same missing check, such as a named object's, a sibling-set member's or a pair's
   whose binding, or a key's whose correspondence, is not stated, conditional on its U id;
   the delegation states the check is made elsewhere, not that it is absent, so the
   object's, the member's or the pair's binding is not stated even in a source tree); an
   availability claim, listed with the availability claims and not evaluated; or no position
   or condition reaches it and no position gains from it, with the reason; the row comes at
   pass 2) (`«KIT»/reference/judging-rules.md`, "A stated exclusion is a stated absence").
   The absence of a check is never a refusal. An exclusion is an availability claim only
   where its only effect is on how much or how long the system serves (capacity, rate,
   uptime), with no fault left unobserved (demand beyond capacity is not a fault here) and
   no position gaining access, data or authority it lacked. A statement that a later design,
   release or implementation will decide is not a check. Left to a person (an operator, a
   reviewer), it is a B2 control, which discharges nothing; left to a caller or to code an
   integrator writes, it is a check the system does not make. Either way its disposition is
   never "delegated", and the person, the callbacks a caller supplies and code an integrator
   writes do not cover it. An excluded halt, alert or fault check (a limit on demand, such
   as a rate limit or a quota, is not a fault check; a limit on the system's own retries
   after a fault is one) is a continue-on-fault path, and the state it leaves out goes in
   the hazards table with no observer. Then the named objects (NO): every input (a request,
   a message, a call, a stored object read back) that names more than one object (a
   container and an item it holds, a parent and a child, a resource and the record or
   version it selects, two parties the act joins), or names one identity or authority the
   act is applied under while it is authenticated as another position or not authenticated
   at all, in one field or across several (a path, a header, a body), with every object it
   names and its line, and for each one of: the check that binds it (to the requester's
   right, or to the other objects it must agree with, such as the item being in the named
   container), with its line (in a document, a check it describes as made, "must" or
   "should", never one it only permits, "may"; a "must" or "should" that names the check as
   one the system or its implementations make counts, its qualifier kept, and where it
   leaves only the mechanism open, it binds the object, its key not stated (an unconfirmed
   item, with a row conditional on it, only where a line shows two objects can share a part
   the check may not read and a position can create, name or be granted one) ("A check binds
   only the key it reads"); one addressed to a caller or to code an integrator writes states
   that the system does not make it: a stated exclusion, its row standing on that line; a
   line leaving whether to check to an implementation or a later design is none, and is a
   stated exclusion); a load by a whole key whose container part a check at the lines binds,
   citing both lines; a line showing it needs none (the act is open on that object to every
   position that reaches the input, such as a recipient any account may name, and a line
   letting a position write the input is never one: that write is what makes the pair; in a
   source tree, a document, comment or test the project ships may show it, cited as the
   project's claim, where the code at the act's lines makes no check that contradicts it;
   code that merely omits a check is none, not this); an availability claim, where the act
   on that object serves no data and changes none (a rewrite that leaves what it rewrites as
   it was, such as an index entry rebuilt from the same source, changes none; a reply
   telling whether a guessed secret matched serves data) and only affects how much or how
   long the system serves; or none (in a source tree, none at the act's code; where the code
   that carries out the act on that object, a call the act makes included, is outside the
   evidence, or an exclusion's own line delegates the check to a component outside it, not
   stated, a U id; for a document, none stated, a U id unless a line states the absence). A
   check that decides on one named object binds that object only, and a check left to a
   person binds nothing; where one named object is the identity or authority the act is
   applied under and the input is authenticated as another position, it is also a pair:
   record it here with its binding, and its row is the pair's; where a check's key reads no
   part of a named object's identifying key, or does not state whether it reads any, record
   that object here, and give the key record no U id of its own for it
   (`«KIT»/reference/judging-rules.md`, "Every object an input names needs its own
   binding"). Then the sibling sets (SS): every check the evidence makes, requires or
   recommends (in a source tree, a check the code makes; in a document, one it describes as
   made, "must" or "should"; not one it only permits, "may"; a line leaving whether to check
   to an implementation or a later design, or addressed to a caller or to code an integrator
   writes, founds nothing) for one member of a set of like inputs or acts, a value the code
   derives from what it has already checked counting as a check (members that each carry
   what the check guards: the same data served, the same binding of a named identity or
   object, or the same right exercised over the same object or kind of object, the right the
   stated check reads (for a check that re-proves who the caller is, the right to the act it
   precedes alone; for a gate (a check on entry to a place or a resource, such as a door),
   admission to what its own line says it admits to and nothing beyond it (a further place
   several routes reach does not make each route a member); for a role or permission check,
   that role or permission exercised over the object or kind of object the act it precedes
   changes or serves, with a line), a broader identity both act under not counting; for a
   limit on demand, the same capacity drawn on or a secret tested that admits to the same
   account or right, whatever its form, such as a password and a reset code for one account;
   with a line for each, whatever their names or routes; a shared form alone, such as the
   same kind of identifier, does not make them alike; where the value the check reads can
   reach the guarded act from more than one source, such as a credential the check derives
   it from and a field the requester writes into a message relayed onward, each source is a
   member of its own, covered only where a line shows the check reading the value from that
   source, a line saying the check applies to every request, or that the value passes
   through the check's component, settling only which requests reach it, and a line scoping
   the check to one source not stating the absence of a check for another), with the shared
   property and its line, every member with its line, and for each member one of: the same
   check at its own lines; a line showing another machine check at its lines covers it; an
   availability claim, where the stated check only limits how much or how long the system
   serves (a cap on the system's own retries after a fault is a fault check, not this: a
   member without it is a continue-on-fault path, its hazard row filed by its effect) and
   further attempts through the member reach no access, data or authority a single attempt
   could not, or where the member's own act serves no data and changes none (a rewrite that
   leaves what it rewrites as it was, such as an index entry rebuilt from the same source,
   changes none; a reply telling whether a guessed secret matched serves data); or none (in
   a source tree, none at the member's code; where the code that carries out the member's
   act, a call it makes included, is outside the evidence, or an exclusion's own line
   delegates the check to a component outside it, not stated, a U id; for a document, none
   stated, a U id unless a line states the absence). A check left to a person is a B2
   control: it founds no set and covers no member, and a like input that skips it is
   recorded with that B2 control by its BC id and the input's line; a member whose only
   check is a person's has none (for a document, none stated unless a line states there is
   no machine check; a line naming only the person's check does not state it), with the BC
   id beside it; a comment or document claiming a check, a person's included, that the code
   at the member's lines does not make covers nothing, and goes in the disagreements (a
   claimed person's check is a B2 control only where a line shows it is made)
   (`«KIT»/reference/judging-rules.md`, "A check stated for one is owed by its like").
7. Execution-observation coupling.
8. Verdict within the model.

The survey's boundaries, ranges and counts are claims like any other: check each one this
pass relies on at the lines, and where one is wrong, use the correct value and say so in
section 1.

End with: the shape named; the observers counted (observers only, then the other roles); the
read-backs counted, with how many have no provenance check, how many no shape check and how
many hold an unbound pair; the deputies and mints counted by component and by row, with how
many rows have no check and how many rows have a restriction that does not reach, or is not
stated to reach; the stated exclusions counted; the key records counted, with how many not
stated; the named objects counted, with how many objects have none, not stated or none
stated; the sibling sets counted, with how many members have none, not stated or none
stated; the halt paths and the continue-on-fault paths listed separately; every unconfirmed
item, numbered; any survey claim corrected.

---

## Pass 2. Gap evaluation

Additional reading: `«KIT»/reference/eight-properties.md`, `«KIT»/templates/findings.md`,
`«KIT»/templates/threat-model.md`, and `«WORK»/scratch/«T»-ring-map.md`.

Produce `«WORK»/scratch/«T»-eval.md` containing:
1. Scorecard: every property for every observer group, G, S or N/A; only the tier exempts
   a property, never what an observer is for. Only entries the ring map gives the role
   observer are scored. Re-test every
   tier the map set and say whether each holds. Totals.
2. STRIDE tables with an Entry column. Build the entry vocabulary for this system from the
   ring map and the source: numbered positions, each saying who can reach what (a remote
   client, a file author, a network position, a local user, another account, an in-process
   plugin, an operator, as the system has them, and, where a channel's or a store's writers
   are not stated, "the writers not stated" with their U id). Every row cites `path:line`.
   Where a row's impact is any identity, role, object or value a position can name or reach,
   name the most privileged one the evidence states the position can name there (the one
   whose reach through the row's own act, at the lines that grant it, is widest (an identity
   or role the act grants and that lasts, as a grant does unless a line shows it ending with
   the act, reaches every act it grants, and one a single act runs under reaches that act
   alone), and where the lines do not state what the row's own act reaches under the one the
   evidence grants the widest reach anywhere (lines showing the act reaching the same under
   each count as stated), that one, its reach through this act then not stated, even where
   another's is stated, the row naming that other's stated reach beside it with its line;
   where a stated check shown reading the value on this path, from this source, refuses,
   removes or replaces it, the most privileged one no such check refuses, removes or
   replaces; a limit in a client, such as the choices a form offers, reads nothing on any
   path where the endpoint takes the value from the request itself) and what it reaches
   through the row's own act, with the line where the evidence grants it that (or say no one
   is stated more privileged than another, or that the row's own act reaches no more under
   one than under another; where what the row's own act reaches under that one is not
   stated, name it with that reach not stated, a U id, never a reach granted to another act;
   that U id covers that part of the impact alone, the row standing on what is stated), and,
   for each stated check that would refuse it, whether a line shows it reading the value on
   this path, from this source; this is the row's own impact, not a chain
   (`«KIT»/reference/judging-rules.md`, "The widest reach is named"). Every hazard the ring
   map records with no observer gets a row wherever a position or a condition reaches it,
   filed by its effect. So does every read-back the ring map records with no provenance
   check or no shape check, wherever a position other than the system's own writer, or a
   condition, can write or alter the store, or a field a relayed message carries into it ("A
   relayed message is written by its sender"), and that position gains, through what the
   reader applies, access, data or authority it lacked, or the condition reaches a hazardous
   state: what the reader applies from an object that position or condition wrote
   (conditional on the check's U id where it is none stated). (Any row this item gives for a
   position, a pair's included, whose impact names no identity, role, object or value at all
   shows nothing gained and is no row, while a hazard's row a condition reaches stands on
   the state it reaches; a row naming a value whose reach is not stated stands, as "The
   widest reach is named" asks.) So does every unbound pair, in a read-back or in a request,
   message or call the system acts on, wherever a position that cannot act under the named
   authority directly can write the input (or a value the system copies into it) and gains,
   through what the authority lends, access, data or authority it lacked: what the authority
   lends to a value that position chose. So does every mint, and every deputy whose next
   check sees only its own identity, that the ring map records with no check (or none
   stated, the row conditional on its U id), wherever a position with fewer rights than the
   deputy (a position lacks what no line shows it holding, rights a line shows granted
   outside the evidence being not stated), or one holding a restriction the deputy does not
   check, can make it act, or the position asking for a mint can name a scope any of its
   minters could not use itself: what that position reaches through it. Where the input that
   makes it act, or asks for the mint, names the authority it is served under, the pair's
   row is its row for the position that writes the input or a value the deputy copies into
   it: name the DA id in that row, not a second row; a position that can make the deputy act
   without writing the input is another entry position, and its borrowed-rights row stands
   as the deputy's row where it gains through the act what it lacked (changing only when or
   how often an act runs whose input another position wrote is an availability claim where a
   line shows running it again changes nothing more; otherwise the row stands, conditional
   on a U id where that is not stated); a restriction's row, entered from the holder of the
   restricted credential, stays its own row, except a restriction passed in a field the
   requester also writes, which is that pair's; where the holder of a restricted credential
   also writes a pair the deputy acts on, the pair's row holds the restriction's gap too,
   its impact naming what reaches past the restriction; and a read-back's row and a pair's
   or a deputy's row in one object, entered from the same position, are one row, the pair's
   or the deputy's. So does every mint, and every deputy that queues or defers the act,
   whose lines show that a later reduction of the minter's or the requester's authority does
   not reach it, wherever a position can use it, or the deputy carries the act out, after
   the minter or the requester could no longer act under that scope: what it reaches then
   (where nothing states whether a later reduction reaches it, an unconfirmed item, not a
   row, until a line settles it). So does every restriction on a requester's or minter's
   credential that the ring map records as not reaching, or not stated to reach, a check
   that decides the act (the deputy's own, the next check, the minting check or the check at
   each use), wherever the position holding that credential can make the deputy act, or ask
   for the mint, beyond that restriction: what that position reaches past the restriction,
   conditional on the unconfirmed item where the reach is not stated. So does every stated
   exclusion the ring map disposes as a row or as covering not stated (the row conditional
   on its U id), never one covered, refused, delegated, an availability claim or unreached,
   wherever a position reaches an act the excluded check would have decided and gains what
   it lacked (a position that supplies a value the excluded check would have refused gains
   it wherever that value reaches another position's data, or a reader that acts on it other
   than at the act the excluded check would have decided; sending more of what a limit on
   demand admits gains nothing here, unless further attempts reach what a single attempt
   could not, such as a password or code guessed by repetition), entered from that position
   (one row with a read-back's or a pair's row entered from the same position for the same
   missing check), or a condition reaches the hazardous state it would have observed (the
   hazard's row, not a second); and every machine check whose key leaves out a part of the
   object's identifying key or lets two objects share it, wherever a position can create,
   name or be granted an object that shares the narrower key and so gains an object its own
   authority does not reach: what that position reaches, conditional on the key record's U
   id where the key or the correspondence is not stated, unless a stated exclusion names the
   part left out (one delegating the check to a component outside the evidence excepted:
   that part's correspondence not stated, a U id, and a row conditional on it, only where a
   line shows two objects can share that part and a position can create, name or be granted
   one; in a source tree, where the code at the check's lines shows it reading that part,
   the code settles it: cite that line, and that part leaves no gap and needs no U id) or
   leaves the key's format to the implementation (not to a component outside the evidence:
   not stated), where it stands on that line, and one row where it meets a deputy's, a
   restriction's, a stated exclusion's, a named object's or a sibling-set member's row for
   the same entry position (`«KIT»/reference/judging-rules.md`, "A stated exclusion is a
   stated absence" and "A check binds only the key it reads"). So does every named object
   the ring map records with none, not stated or none stated (the row conditional on its U
   id), wherever the act serves the position data another position holds, or changes data
   another position holds, and the position gains access, data or authority it lacked: what
   a position permitted for the other objects named (or any position that reaches the input,
   where no check reads the requester's right) reaches by naming one they do not hold or
   select, entered from that position, never a row for an object a line shows needs none or
   one disposed as an availability claim; and every member of a sibling set the ring map
   records with none, not stated or none stated (the row conditional on its U id), wherever
   a position reaches, through that member, what the check would guard there (the same
   binding, data or right, for that member's own act) and gains what it lacked, entered from
   that position, citing the stated check's line beside the member's own and keeping a
   "should" as written, never a row for a member disposed as an availability claim
   (`«KIT»/reference/judging-rules.md`, "Every object an input names needs its own binding"
   and "A check stated for one is owed by its like"); either is one row with any other row
   entered from the same position for the same missing check, held by that other row, which
   cites the stated check's line and keeps a "should" as written (a pair's only where the
   pair is unbound or its binding is not stated or none stated, a deputy's only where its
   next check sees only its own identity), and where a named object's and a sibling-set
   member's gaps meet, the named object's row holds both. A like input the ring map records
   skipping a B2 control gets no row from these rules: list it under "Open questions for
   pass 4" with its BC id and the input's line. One defect is one row, and defects entered
   from different positions are different defects (the writers of one input excepted): the
   pair's row holds what a position that can write the input (a position that writes a value
   the system copies into the input included, such as a writer of the channel on which an
   entry point passed an identity, the requester whose message a component relays included,
   where it writes the field as "A relayed message is written by its sender" decides)
   reaches (one row for all the writers of that one input, each entry naming its own widest
   reach where they differ, and a value copied from one input into another is one pair, at
   the last check that should bind it), the deputy's row what a position that can make it
   act reaches through its rights, and a restriction's row what the holder of the restricted
   credential reaches past it (unless the deputy's row already names that holder as an
   entry); within one entry position, restrictions dropped by one call are one row, a call
   carrying a credential minted for it is one row with that minting check, at the minting
   check, and a mint with no check is one row, whatever kinds or deputies share it
   (`«KIT»/reference/judging-rules.md`, "Identity is not authority"). Where the ring map
   records a store's write access, or the writers of the channel a value or identity arrived
   on (a relayed field's included), as not stated, the read-back's or pair's row is
   conditional on that unconfirmed item for those writers, while its entry from a position a
   line shows writing the value, or the message that carries it, stays unconditional where
   the value is also shown reaching the reader (for a relayed field, as "A relayed message
   is written by its sender" decides); this settles the writers only, and a row resting also
   on another unconfirmed item, such as a sibling member's check none stated, stays
   conditional on that.
3. The mechanisms to settle: every unconfirmed item from the ring map, which the
   orchestrator lists here verbatim: «the ring map's numbered unconfirmed items». Also these
   refusals, halts and verification points, which the orchestrator builds from the ring
   map's halt paths and continue-on-fault paths: «each, with its id and line». Each settled as confirmed, refuted or needs a
   probe, with the exact precondition.
4. Impact, ordered by the ranking rule in `«KIT»/reference/judging-rules.md`, stated once.
5. Delegation boundaries: every component the system hands work to (libraries, services, the
   platform, callbacks a caller supplies, code an integrator writes), built from the ring
   map and the source, listed and not followed, with every stated exclusion the ring map
   disposes as delegated.
6. Availability claims, listed and left unevaluated, with every stated exclusion, named
   object and sibling-set member the ring map disposes as one.

No chains. Before the closing items, add a section "Open questions for pass 4": each
suspected chain in one line, with the ids it would join.

End with: scorecard totals; settled items (confirmed, refuted, needs a probe); STRIDE row
count.

---

## Pass 3. Verify

Additional reading: `«WORK»/scratch/«T»-ring-map.md` and `«WORK»/scratch/«T»-eval.md`.

Open every load-bearing citation in passes 1 and 2 at its line; confirm, correct or drop
it. A correction survives only if the true content still supports a finding. No new
findings unless a correction forces one; mark any such finding new. Where a claim rests on
a dependency, open the version the lockfile pins if it is available locally; if not, say
which version was not opened.

The claims that need the most care, strongest first: «numbered list from the evaluation's
headline findings and the ring map's verdict». Every open question and every needs-a-probe item from passes 1 and 2:
settle it with the file open, or keep it as needs a probe with the exact precondition.
Pass 2's open questions for pass 4 are not settled here: copy them unchanged into a last
section of the same name.

Produce `«WORK»/scratch/«T»-verified.md`: the verification log with counts (confirmed,
corrected, dropped, new) first; then the verified content in deliverable order: system in
brief with the tiers; architectural model with the coordinator test as a table; the
structure against the model, property by property (the scorecard with the evidence for each
verdict, re-verified); missing components, with the hazards, read-backs and deputies and
mints tables (each deputy or mint whose input names the authority it is served under giving
the pair's RB or STRIDE id in its last column, and each whose deputy or restriction gap
another row holds giving that row's id), the stated exclusions (each with its disposition,
and the id of the row or rows that hold it where it has any) and the key records (each check
deciding on an object by a key, with the key it reads, the identifying key and their
correspondence, with lines, and the id of the row that holds its gap, or none and why), the
named objects (each input, every object it names and the check that binds each, with lines,
a line showing it needs none, an availability claim, none, not stated or none stated, and
the id of the row that holds each gap, or none and why) and the sibling sets (each set's
shared property and stated check, and each member's check, a line showing another machine
check covers it, an availability claim, none, not stated or none stated, with the id of the
row that holds each gap, or none and why); present halt paths with propagation; STRIDE with
verified rows only (ids kept, corrected rows marked); impact by one rule; delegation
boundaries; availability claims; still unsettled questions, each with what would settle it.
End with the list of every correction that changes a headline finding.

---

## Pass 4. Chain hunt

Additional reading: the chain shape in `«KIT»/templates/threat-model.md`, then
`«WORK»/scratch/«T»-ring-map.md`, `«WORK»/scratch/«T»-eval.md` and
`«WORK»/scratch/«T»-verified.md` (authoritative wherever it differs from the evaluation).

Part A, chains. Walk the ring map's edges. For each observer, ask which other observers'
checks its gap defeats, blinds or bypasses, and what the actor reaches by combining them.
Test at least these candidates and add your own: «ten or more, which the orchestrator builds
from the verified file's STRIDE rows, its halt paths and its open questions for pass 4».
Record each chain: name; entry points (required, optional, one branch, one cause, the
reader); steps with evidence; the seam crossed; combined impact; composition line.
Source-supported chains first, then chains conditional on a probe, then
deployment-assumption chains, each marked. Then a rejected list with source reasons. Every
read-back the verified read-backs table records as bypassing an observer or a B2 control is
a candidate: what reaches past that check. An object that did not pass it is one another
position wrote, unless a provenance check confines the read to that writer (for a relayed
message, to the fields that writer alone writes: "A relayed message is written by its
sender"); one a condition altered after the write; or one holding a value chosen under an
earlier configuration. A check that binds the whole content to that writer leaves only the
last (for a relayed message, for the fields that writer alone writes: "A relayed message is
written by its sender"). Every unbound pair the verified file records is a candidate too:
what the named authority lends to a value a position that can write the input (or a value
copied into it) chose. So is every deputy or mint with no check: what a position reaches by
making the deputy act, or by asking for a scope any of its minters could not use itself,
joined to another gap the borrowed rights or the minted scope reach; a check further down
that trusts the deputy or honours the mint is not a gap, unless another position can write
the hop to it (where the hop's writers are not stated, a U id and the candidate conditional,
never rejected) or the value is a field the deputy relays that another position also writes
("A relayed message is written by its sender"), and a deputy or mint with no check that
joins no other gap is its row, not a chain. So is every restriction the verified file
records as not reaching, or not stated to reach, a check that decides the act (the deputy's
own, the next check, the minting check or the check at each use), joined to another gap; one
that joins no other gap is its row, not a chain, and one only not stated to reach makes the
chain conditional. So is every stated exclusion with a row, every key gap of a machine
check, and every named object and sibling-set member with a row, joined to another gap; one
that joins none is its row, not a chain. So is every B2 control a like input skips, and
every key gap of a B2 control's check, joined to another gap; one that joins none stays with
its B2 control and is no row. A check further down that applies the requester's permissions
is no reason to reject a candidate in which a restriction on the requester's credential is
not shown to reach that check (`«KIT»/reference/judging-rules.md`, "Identity is not
authority"). Apply "A failed premise rejects the premise, not the candidate"
(`«KIT»/reference/judging-rules.md`): where the lines do not support a candidate's premise,
restate it without that premise (where the premise is itself one of the joined gaps,
dropping that gap and keeping the rest) and test the restatement (a step the lines do not
state makes it conditional, never rejected for that alone, while a step the lines refute is
not unstated, and a step is not stated only where a line puts its two ends in contact (one
gap's effect is the other's input, as where one gap's line takes the other's output by name,
such as code reading "the pulled repository") without showing the step; with no such line
the gaps do not join; its gaps must still join through a step, one feeding the next, and the
combined impact exceed any one gap alone), and test what the lines say instead as a gap
before using it as a reason; the rejected list records the failed premise and the restated
test, and a restatement that survives goes to the chains (conditional where a step is not
stated), not the rejected list. Whatever the reason a candidate is rejected, where a row it
joins, or a row it was said to be already held by, has an "any" impact not naming the most
privileged one and what it reaches through the row's own act, as pass 2 defines them ("The
widest reach is named"), with the line that grants it, or with that reach not stated (a U
id, never a reach granted to another act; that U id covering that part of the impact alone),
or saying none is stated more privileged than another or that the act reaches no more under
one than another, and with any other's stated reach beside it with its line, or does not
name the impact the candidate was rejected as already reaching where the lines show it
reaches it, record what is missing in Part C as an addition to that row, which pass 5
confirms as an addition, and the rejection stands with it only once the candidate, tested
again against the named impact, still fails; where the lines do not show the impact the
candidate was rejected as already reaching, that premise has failed: restate the candidate
without it, adding none in its place, and test the restatement, and test what the lines say
instead as a gap ("A failed premise rejects the premise, not the candidate"), adding to that
row no impact its lines do not show (`«KIT»/reference/judging-rules.md`, "The widest reach
is named").

Part B, missed items: observers, edges and faults the earlier passes did not record. Look at
least at: every observed component's hazardous states, against the ring map's hazards table
(a hazard the table missed, or one with no row in the verified file); every read-back,
against the ring map's read-backs table (a read-back the table missed; one with a missing
check and no row in the verified file, where a position gains through it what it lacked; and
for each, what applying a field or value outside the writer's format (what the system's own
writer produces, or, where nothing in the system writes the object, the format the reader
parses) reaches, from an object another position or a condition wrote); every input, stored
or not, that names the authority its reader acts under, against the pairs the verified file
records (a pair it missed, or an unbound one with no row, where a position that cannot act
under the authority directly writes it and gains, through what the authority lends, what it
lacked); every deputy and every mint, against the ring map's deputies and mints table (one
the table missed, a kind of credential that can drive one and has no row of its own
(recorded in Part C as a correction to the verified deputies and mints table, and an M row
only where a restriction it carries is not shown to reach and no existing row holds that
defect), or one with no check and no row in the verified file); every stated exclusion,
against the ring map's list (one it missed, or one disposed as a row or as covering not
stated with no row in the verified file); every machine check that decides on an object by a
key, for a key narrower than the object's identifying key or one two objects can share,
where a position gains an object its own authority does not reach; every input that names
more than one object, for an object no check binds where a position gains through it what it
lacked (not one a line shows needs none, nor one whose act serves no data and changes none,
which goes with the availability claims); every machine check stated for one member of a set
of like inputs or acts (a person's check founds no set and covers no member), for a member
with none, not stated or none stated where a position gains through it what the check would
guard (never one whose lack is an availability claim); the request path's other checks;
rotation and rollback; startup-only decisions; anything that gates before the core; «the
system-specific places the orchestrator names from the survey and the ring map». Each as a
STRIDE-shaped row (M1, M2 ...).

Part C, contradictions of the verified file, with lines in both, and additions to its rows.

Output `«WORK»/scratch/«T»-chains.md`. End with: chains, rejected, missed, contradictions,
additions.

---

## Pass 5. Chain verify

Additional reading: `«WORK»/scratch/«T»-verified.md` (settled; reopen only where the chain
document claims a contradiction), `«WORK»/scratch/«T»-ring-map.md` (for contradictions
that concern the map and for the edges a chain walks) and `«WORK»/scratch/«T»-chains.md`.
The chain hunt's most striking claim gets the same line-by-line test as every other claim.

1. Open every chain step's evidence; confirm, correct or drop each step. A chain survives
   only if every remaining step holds, or is not stated at the lines (which makes it
   conditional, never dropped for that alone; a step the lines refute is not one that is not
   stated, and a step is not stated only where a line puts its two ends in contact (one
   gap's effect is the other's input, as where one gap's line takes the other's output by
   name, such as code reading "the pulled repository") without showing the step; with no
   such line the gaps do not join), one gap feeding the next through each step, and the
   combined impact exceeds any one gap alone; a chain dropped because a step fails at its
   lines is restated without that step (where the step is a whole gap, dropping that gap and
   keeping the rest) and tested, and what that step's lines say instead is tested as a gap
   ("A failed premise rejects the premise, not the candidate"), both recorded; whatever the
   reason a chain is dropped, where a row it joins, or a row it was said to be already held
   by, has an "any" impact that does not name the most privileged one and what it reaches
   through the row's own act, as pass 2 defines them ("The widest reach is named"), with the
   line that grants it, or with that reach not stated (a U id, never a reach granted to
   another act; that U id covering that part of the impact alone), or saying none is stated
   more privileged than another or that the act reaches no more under one than another, and
   with any other's stated reach beside it with its line, or does not name the impact the
   chain was dropped as already reaching where the lines show it reaches it, add what is
   missing to that row as a confirmed addition and test the chain again against it, the drop
   standing only if the chain still fails; where the lines do not show the impact the chain
   was dropped as already reaching, that premise has failed: restate the chain without it,
   adding none in its place, and test the restatement, and test what the lines say instead
   as a gap ("A failed premise rejects the premise, not the candidate"), adding to that row
   no impact its lines do not show.
2. Check each chain's entry points against the verified preconditions.
3. Give the strongest Part B claims special care: anything that says unreachable, no
   validation, fails open, executes or bypasses.
4. Check every rejected candidate's reason at the line (a restatement that survives moves to
   the verified chains), and that a candidate rejected on a failed premise was restated
   without it and tested, and what the lines say instead was tested as a gap, and that a
   candidate rejected because a next check applies the requester's permissions was tested
   for each restriction the requester's credential carries, and that every row a rejected
   candidate joins, or was said to be already held by, names what "The widest reach is
   named" asks, the candidate tested again against what is added, its rejection standing
   only if it still fails; where any was not done, do it here.

Output `«WORK»/scratch/«T»-chains-verified.md`: a verification log with counts; the
verified chains (source-supported first, then conditional, then deployment assumptions);
the verified rejected list; the missed items as rows ready to merge (ids kept, corrections
marked); every confirmed addition to an existing row (a posture note, a precondition, a
second citation), each with the row id and the text to add; every correction that reaches
back into the pass 3 file, with the verified file's line and the source line; then a
section "Open questions": each question this pass leaves open, with what would settle it.
End with: chains confirmed, corrected, dropped; rejected candidates confirmed; missed
rows; additions to existing rows; reach-back corrections; open questions.

---

## Assembly. The deliverable and the standalone copy

Additional reading: `«KIT»/templates/threat-model.md` for the section order and fixed
wording only (nothing else from it may appear in the output), then
`«WORK»/scratch/«T»-verified.md`, `«WORK»/scratch/«T»-chains-verified.md`, and
`«WORK»/scratch/«T»-ring-map.md` for the observer inventory, and
`«WORK»/scratch/«T»-chains.md` only to copy, by script, the wording of unconfirmed items it
defines that the chain verification confirms by id, keeping every correction pass 5 makes to
them. Do not edit the scratch files.

1. Apply every correction pass 5 lists as reaching back into the pass 3 file, and every
   addition it confirms to an existing row. Open the source line each one names, carry the
   corrected or added wording into the output (a stated exclusion, named object or
   sibling-set member pass 5 verifies goes into its table as well), and list each one in a
   short change note at the end of the deliverable. Write every citation in the change note
   with its file name: a bare continuation (`:40`) resolves only in the paragraph that names
   the file. End the deliverable with the heading `## Change note`, exactly, followed by
   "None." when there is nothing to list: the final sweep's commands depend on it. Carry
   every question pass 5 leaves open into the still unsettled questions, marked as raised by
   the chain verification and not ruled, with what would settle it; a question pass 5
   settles in its own verdict on a chain is a ruling and is not carried.
2. Assemble `«WORK»/output/«T»-threat-model.md` in the template's section order. Carry
   content from the pass files by script (a short script that copies line ranges and
   makes exact replacements), never by retyping and never through the file-writing tool:
   every citation stays byte-identical, every id is kept, corrected rows stay marked. Only
   the hand-written parts go through the file-writing tool. A citation into a pass file is not evidence: replace it with the row id it
   names or the source line it rests on. Merge pass 5's verified
   missed rows into the STRIDE tables under "Found by the chain hunt, verified". Write by
   hand only the introduction, the risks stated first (ranked by the impact rule as pass 3
   states it and pass 5 corrects it, in the shape the template's comment gives: a
   preamble that states the rule and nothing else; each risk a heading sentence naming the
   hazard its gaps leave unobserved (in the source's words, for a system evidenced by a
   document), then two to five sentences,
   then its ids on one closing line), the counts and the shape of
   it. Recompute every number in the counts from the assembled body.
3. Build `«WORK»/output/«T»-threat-model-standalone.md` from the deliverable as the
   template's closing note describes: a self-contained introduction; the model in brief on
   one page; the Keys section, which says that the [corrected] mark covers the
   verification passes and that the final sweep's corrections are applied in place
   without a mark; every reference to the workspace, the kit and the pass files
   removed; Parts A to F, with the entry-point index mapping every row and chain to its
   entries.
4. Check both files: no em dashes and no first person; no workspace paths or kit
   references in the standalone copy; rows per letter equal in both. Run
   `python «KIT»/scripts/resolve_citations.py FILE «trees» --list-bad` on each file, and
   report its counts. Move a citation into a dependency that was never opened into the
   prose with the dependency's name, and fix every other bad citation, so both files
   resolve at zero bad. Grep both files for « and »: zero hits.

End with: rows by letter, chains, the reach-back corrections applied, the open questions
carried from pass 5, and the resolver's counts for each file.

---

## Pass 6. Final sweep

Reading: `«KIT»/reference/writing.md`, then
`«WORK»/output/«T»-threat-model-standalone.md`, then the deliverable
`«WORK»/output/«T»-threat-model.md` where the dry run below sends you and for its
introduction, then the source as each claim needs it.

Two questions only, of every row, every hazards, read-backs and deputies and mints table
row, stated exclusion, key record, named object, sibling-set member, chain step, rejected
entry, impact entry, halt path, risk, the integration surface, the entry-point index, every
count, the deliverable's introduction, and the standalone copy's introduction, model in
brief and Keys (every entry, actor and path rule they state): do the cited lines say what
the claim says, and can an actor at the named entry reach the code path as described, with
the stated precondition. No opinions on intent or accepted risk. Do not edit the document. A
correction to a risk keeps the risk's shape: the heading sentence, two to five sentences,
the ids on their closing line; a qualifier it restores goes after the clause it qualifies,
never as a parenthesis in mid-sentence.

Output `«WORK»/scratch/final-sweep.md`: a log per section, one line per item (id, verdict
confirmed / narrowed / wrong / not checkable, and for a narrowing or a wrong item the file
and number of its correction, never the correction's text); then every correction on its
own line, numbered, in exactly this form, which the kit's `apply_edits.py` parses:

    12. Line 86. Old: `` exact phrase `` New: `` replacement ``

with one space inside each pair of double backticks, and each old phrase long enough to
occur exactly once in the document, lengthened within its line. To delete a phrase, write
`New:` followed by four backticks and nothing else:

    13. Line 90. Old: `` phrase to delete `` New: ````

A correction whose old text spans a hard-wrapped line, or that no lengthening within its
line makes unique, goes instead as a CURRENT/REPLACEMENT block in the form
`«KIT»/scripts/apply_edits.py` documents, quoted verbatim with its line breaks and running
onto the neighbouring lines as far as it must to occur once.

Before finishing, check the list against both documents:

    python «KIT»/scripts/apply_edits.py «WORK»/scratch/final-sweep.md «WORK»/output/«T»-threat-model-standalone.md «WORK»/output/«T»-threat-model.md --partial --anchor --skip-section "Change note" --dry-run

The standalone copy comes first: `--anchor` stops any entry whose old text it does not
hold. `--skip-section` leaves the deliverable's change note, which quotes corrected
passages, out of every match. The script prints which documents each entry reaches, then
any problems, naming a parsed sweep line by its number, a parsed block by the line of its
CURRENT label, and an entry that does not parse by its line in the edit list. Fix every
problem and run it again, until it reports none. Never lengthen a correction whose old
text sits outside the self-contained introduction, the model in brief, the Keys, Part E
and Part F so far that it stops reaching the deliverable.

Read the deliverable's introduction (everything before its first `##` heading) in full and
check it like any other part. A correction for text in it that the standalone copy does
not hold goes to `«WORK»/scratch/final-sweep-deliverable.md`, never to `final-sweep.md`,
even where the standalone's introduction, model in brief or Keys states the same claim in
other words and `final-sweep.md` corrects it there. Once the dry run reports no problem,
check every entry of `final-sweep.md` it shows reaching the deliverable against the
deliverable's introduction; where its old text sits there, confirm it corrects the same
claim there, or lengthen it within the
standalone's text until it no longer reaches the deliverable, and write nothing to
`final-sweep-deliverable.md` for text such an entry already changes.

Read the rest of the deliverable only where the dry run reports an old text more than once
in it. Each other occurrence sits in a part the standalone copy does not have (the
deliverable's introduction, or a passage the standalone dropped as a reference to the
workspace, the kit or the pass files): lengthen the entry within the standalone's text
until the deliverable holds it once, and where the occurrence there makes the claim the
entry corrects, write its correction to `final-sweep-deliverable.md`. Write that file in
the same forms, and check it against the deliverable as `final-sweep.md` leaves it: copy
both documents into `«WORK»/scratch/sweep-check/`, run the first command on the copies
without `--dry-run`, then run this, with fresh copies before every check:

    python «KIT»/scripts/apply_edits.py «WORK»/scratch/final-sweep-deliverable.md «WORK»/scratch/sweep-check/«T»-threat-model.md --skip-section "Change note" --dry-run

Then the counts per section and in total; then the claims that could not be checked
because they rest on code not available. Run the first dry run once more, and the check
of `final-sweep-deliverable.md` where that file exists, after writing these closing items:
none may report a problem.
