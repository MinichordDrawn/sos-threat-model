# Judging rules

Rules that decide whether something is a finding. Each came from a correction on a real
audit; the reason is given so the rule can be applied to cases it does not name.

## What is and is not a gap

**A deliberate refusal is not a gap.** Where a structure declines to do something because
doing it would be unsafe, that is a property, not a deficiency. A declared member list is
not "automatic integration absent" when integration over the declared set is automatic and
what is refused is a component adding itself. Scoring the safe direction as a loss argues
against the model.

**Behavioural validation is not safety observation.** Whether the work produced the right
output is an integration test's job. An observer that checks business results in
production is a test holding production credentials, which is a new privileged position.

**A property is judged at the structure's own scale.** One coordinator is the model's own
closing condition, so an upward chain that ends at it has ended, not stopped short. Nested
rings do not apply to a structure that needs one ring.

**Do not score against an outside framework.** A comparison with another field's practice
tends to list deliberate scope boundaries as divergences. Judge within the model.

**Obedience is not a gap; skipping the check is.** At a seam between two packages, a package
that acts on the other's file, environment, return value or configuration, after checking
who wrote it and that its content has the shape the writing side produces (`method.md`, Step
1), any value applied under an authority it names included ("A named authority binds only
what it chose", below), is obeying, not failing: a value that passes those checks and is
still wrong is a gap on the side that produced it. A missing check is a gap on the reading
side, whoever could have written the value. For a value that is not stored (a return value,
an argument, an environment variable), who wrote it is the call or channel it arrived on,
recorded with its lines, with every other position that can write to that channel; a channel
only the writing side can write to needs no further provenance check (for a field of a
message the writing side relays for another position, "A relayed message is written by its
sender" decides who else wrote it); where the lines do not state who else can write the
channel, that is an unconfirmed item, and a row resting on it is conditional for those
writers. Obedience settles who wrote the value and its shape; where the reading side acts
for a position or honours a mint, its check as a deputy, or the check that what it honours
falls within the minter's authority, restrictions included, is judged separately ("Identity
is not authority"). This rule dissolves many seam candidates, and that is it working.

**A relayed message is written by its sender.** Where a component passes on a value in a
message it relays for a requester (a field, a header, a parameter, an attribute), the
writers of that value are the component and every position that wrote the message it relays,
the requester included, whether or not the component authenticated it: the component
authenticating the requester settles who the requester is, and its setting a value of its
own settles what it added, not who else wrote the field. The component alone writes the
value only where a line shows it removing or replacing that field on every message it relays
on a route, whatever the requester's credential (a removal, replacement or refusal that
holds only for some routes or credentials settles those alone, the rest staying as below),
or refusing every message that carries the field (a refusal shown for some routes or
credentials settling those alone), or building the message it passes on afresh and copying
only fields a line names (a field it does not copy is not relayed, and one a line shows it
copying from the requester's message stays the requester's). Where the field can hold
several values (a list, a repeated field, a map), a line showing the component adding its
own values to the field does not show it removing the requester's; a line clearing or
overwriting the whole field does, and a line removing particular values removes those alone:
for the requester's others the field is neither removed nor replaced, as below. In a source
tree, where the relaying code, a call it makes included, is in the evidence and does none of
these (removal, replacement, refusal, a fresh build), the requester's value reaches the
reader and the channel is one others can write; where that code, or a call it hands the
message to, is outside the evidence, whether it reaches is not stated: an unconfirmed item,
one U id for the relay and for any pair, named object or sibling member resting on it, and a
row resting on it is conditional. In a document, where no line shows the component removing
or replacing the field, or the value in question from the source the reader takes it from,
on the message's route and for its credential (a removal, replacement or refusal shown for
one route or credential settles that alone), or refusing every message that carries it, or
building the message afresh with only fields a line names, whether the requester's value
reaches the reader is not stated, even where a line shows the requester writing the field or
the component passing on its own values, unless a line states that the requester's value of
that field reaches the reader (a line saying only that the message is relayed does not): an
unconfirmed item, one U id for the relay and for any pair, named object or sibling member
resting on it, and a row resting on it is conditional. This holds where the component is
itself the deputy: the identity it authenticated is the identity it took from the
requester's credential; a field of the message it relays carries that identity only where
the component alone writes the field. In every case the row is entered from every position
whose message the component relays and that gains through the field (a position the lines
confine to one scope, by a credential, a deployment or a policy, gains what lies outside it,
and a position lacks what no line shows it holding, rights a line shows granted outside the
evidence being not stated), a requester it authenticated included, not only from one it does
not authenticate. A channel only the component can write, or a provenance check that
confines a message to the component, settles who wrote the message, not who wrote a field it
relays. The writers of the channel into the component are recorded too, as for any channel
(not stated, a U id, where the lines do not say; a channel on which the component
authenticates the requester's own credential is that requester's alone, its writers needing
no U id). Wherever the kit asks who else can write a channel, this rule decides it for a
relayed message; whether a check covers the value from each source it can come from is "A
check stated for one is owed by its like"'s, and a row resting on either stays conditional
on each U id for the writers or sources it covers, an entry the lines show staying
unconditional.

**Two gaps that add are not a chain.** A chain must reach more than its strongest gap
reaches alone. Two independent effects of one fault are a parallel effect, not a chain.

**The widest reach is named.** Where a row's impact is any identity, role, object or value a
position can name or reach (any user, any group, any tenant), the row names the most
privileged one the evidence states the position can name there (the one whose reach through
the row's own act, at the lines that grant it, is widest (an identity or role the act grants
and that lasts, as a grant does unless a line shows it ending with the act, reaches every
act it grants, and one a single act runs under reaches that act alone), and where the lines
do not state what the row's own act reaches under the one the evidence grants the widest
reach anywhere (lines showing the act reaching the same under each count as stated), that
one, its reach through this act then not stated, even where another's is stated, the row
naming that other's stated reach beside it with its line; where a stated check shown reading
the value on this path, from this source, refuses, removes or replaces it, the most
privileged one no such check refuses, removes or replaces; a limit in a client, such as the
choices a form offers, reads nothing on any path where the endpoint takes the value from the
request itself) and what that one reaches through the row's own act, with the line where the
evidence grants it that (where none is stated more privileged than another, or the row's own
act reaches no more under one than under another, the row says so; where what the row's own
act reaches under that one is not stated, the row names it with that reach not stated, an
unconfirmed item, never a reach granted to another act; that U id covers that part of the
impact alone, the row standing on what is stated), and, for each stated check that would
refuse that one, whether a line shows it reading the value on this path, from this source
("A check stated for one is owed by its like" decides). A row for a position, a pair's
included, whose impact names no identity, role, object or value at all shows nothing gained
and is no row; a hazard's row a condition reaches stands on the state it reaches, and a row
naming a value whose reach is not stated stands. What the strongest one reaches is part of
the row's own impact, not a chain: a chain candidate joining the row to another row is
tested by "Two gaps that add are not a chain" as usual, and whatever the reason a candidate
is rejected or a chain dropped, every row it joins whose impact is "any" must name its
strongest one, and any row the candidate was said to be already held by must name the impact
it was said to hold, where the lines show it holds it (where they do not, the premise has
failed and "A failed premise rejects the premise, not the candidate" decides): what is
missing is added to that row, and a candidate rejected while that row read "any" is tested
again against the named one, the rejection standing only if the candidate still fails.

**A failed premise rejects the premise, not the candidate.** Where a chain candidate rests
on a premise the lines do not support, restate it without that premise, adding none in its
place and keeping the gaps it joins (where the failed premise is itself one of those gaps,
dropping that gap and keeping the rest), and test the restatement by every chain rule (a
step the lines do not state makes it conditional on that unconfirmed item, never rejected
for that alone, while a step the lines refute is not unstated, and a step is not stated only
where a line puts its two ends in contact (one gap's effect is the other's input, as where
one gap's line takes the other's output by name, such as code reading "the pulled
repository") without showing the step; with no such line the gaps do not join; its gaps must
still join through a step, one feeding the next, or they only add), and a restatement that
survives is a chain, kept with the chains, not the rejection; reject the candidate only when
the restatement fails too, and record both. Where the lines say something other than the
premise, test what they say as a gap, under the rules above, before using it as a reason to
reject, since a fact that defeats the wording of a candidate can be the gap itself; a gap
that holds becomes a row, and a chain candidate where it joins another.

**Links made of people count.** The ring and the scorecard are machine-only, but where
people perform observation (a reviewer who approves a change, a designer who signs
off a design, a regulator who checks a document), gaps in their observation compose into chains
like any other and are judged by the same combined-impact test. A chain is not moved to
missing structure because its links are human.

**Only observers are scored.** An observer watches something and reports or acts on what
it finds. The work it watches, a passive barrier that watches nothing, a group of people,
and a device that only records or carries a signal are not observers, and a scorecard row
for one of them is a category error. People's checks are B2 controls; they discharge no
property.

**Information disclosure is information reaching a position that should not have it.**
Information the system held but never delivered to the position that would act on it is
not I: it is a missing component (no path carries it) or, where a record existed and
compelled no action, a repudiation row.

**Provenance is not content.** A check of who wrote a stored object (an attribute the store
itself sets from the writer's identity, such as the account that wrote it) says nothing
about what the object holds; an owner field, label or name a writer of the store can set is
content, not provenance, unless a signature or MAC that binds the whole content to its
writer (below) covers it, or the store itself forces it, on every write whoever writes, to
match the writer, which makes that field provenance. A check of its content says nothing
about who wrote it. Where the system reads an object back and acts on it, record each check
separately. What the system's own writer puts in the store describes that writer, not every
object the store can hold: a position that can write the store writes whatever the store
accepts, and a schema the store itself enforces on every write, whoever writes, is a shape
check, recorded with its lines. Write access the store enforces bounds who can write the
store (for a field of a relayed message the relaying side stores, "A relayed message is
written by its sender" decides who wrote it) and is never a provenance check (`method.md`,
Step 1). Ask what the reader applies (named fields, or everything the object contains) and
what an extra field or an out-of-range value reaches. Where the system's own writer (at a
seam, the writing side) has the role observer (it checks what it stores: validates it,
derives it from a source it checks, or selects it from configured choices), its check is
part of what that writer produces: a value it would refuse or never choose is outside the
writer's format, even in a field the writer fills, and a read-back with no shape check
making the same check bypasses that observer for every object that did not pass it
(`method.md`, Step 1). A check that binds the whole content to its writer (a signature under
a key only that writer holds, or a MAC under a key only that writer and the reader hold)
fills both checks with the same id, for the positions that cannot use the key (a field that
writer relays for another position stays that position's: "A relayed message is written by
its sender"); the record names those positions. It binds a pair only where that writer is
the named authority itself ("A named authority binds only what it chose", below).

**A named authority binds only what it chose.** Where an input names the authority its
reader acts under (an account, an issuer, a key, a tenant, a role or a configuration the
reader looks up by one of the input's fields) and carries another value the reader applies
under that authority, the value is the authority's only where a check at or after the read
binds it to what the authority holds or would choose. A check that the named authority
exists, or has the right type, binds nothing else. A provenance check that confines the
input to the named authority itself (the input authenticated as that authority, or a
signature under a key only it holds) binds every value the input carries, and so does a
constraint the store enforces on every write, whoever writes, that the naming field matches
the writer, either except a field relayed for another position that is not the authority
itself ("A relayed message is written by its sender"). Either binds the values to that
authority's identity, not to the restrictions on what the authority may do ("Identity is not
authority"). A signature or MAC that binds the content to another writer, and write access
the store enforces, the authority's own included, bind nothing here: they bound the
positions that can write the input. A pair is not a gap where a line shows the act open to
every position that reaches the input ("a line showing it needs none" for a named object; a
line letting a position write the input is never one: that write is what makes the pair). A
pair with no such check is unbound: a missing shape check, and a gap wherever a position
that cannot act under the authority directly can write the input (or a value its reader
copies into it) and gains, through what the authority lends, access, data or authority it
lacked, since the position lends the authority to a value of its own choosing. The input can
be stored (a read-back) or not (a request, a message, a call).

**A deputy carries whom it acts for.** Where a component acts for another position (a
controller acting on an object a user wrote, a service calling another under its own
identity for a caller, a job runner, a webhook, a scheduler), the check further down that
decides whether the action is allowed sees some identity. Where it sees only the deputy's,
every position that can make the deputy act borrows the deputy's rights, unless the deputy
itself checks, at or after it takes the request, that the position it acts for holds the
right to what it asks (its identity's rights and every restriction its credential carries).
Record whom the deputy acts for, the identity the next check sees, and the deputy's own
check on the requester's right, or none (for a document, none stated, a U id and the
deputy's row conditional on it, unless a line states its absence). A deputy whose next check
sees only its own identity and that makes no such check of its own is a gap at the deputy,
wherever a position with fewer rights than the deputy, or one holding a restriction the
deputy does not check, can make it act. Checking that the request is well formed, or that
its target exists, is not that check, nor is authenticating the requester, or the next check
authenticating the deputy: the check is that the requester holds the right to what it asks.
An identity the deputy passes down is the requester's only where the deputy authenticated it
(the identity it took from the requester's credential; a field of the message it relays
carries that identity only where the deputy alone writes the field: "A relayed message is
written by its sender"), or an entry point authenticated it and passed it to the deputy on a
channel only that entry point can write, with lines (the identity it took from the
requester's credential; a field of the message it relays carries that identity only where
the entry point alone writes the field, which "A relayed message is written by its sender"
decides even on a channel only the entry point can write), or where the next check itself
verifies the requester's own credential, forwarded unchanged (wherever the kit says "as the
deputy authenticated it", this is included); one the request merely names, or one an entry
point passed on a channel others can write or whose writers are not stated (an unconfirmed
item, the pair's row conditional on it for those writers; for a field of a message an entry
point relays for the requester, "A relayed message is written by its sender" decides who
writes it) where the next check does not itself verify the requester's credential, is a pair
under "A named authority binds only what it chose". Where the next check sees the
requester's identity, "Identity is not authority" decides whether the deputy needs a check
of its own. Whatever the next check sees, the hop from the deputy to it is a channel like
any other: where a position other than the deputy can write it, what the next check sees is
that position's too, and where its writers are not stated, a U id, the row conditional for
those writers.

**Minted authority is bounded by its minter.** Wherever the system creates or hands on
authority (a token, a session, a signed URL, a sub-credential, a delegated role, a stored
grant), the authority minted is the minter's to give only within what the minter itself
holds. The minter is the position whose authority is handed on (the one that asks for the
token or delegates the role), not the component that signs or stores it; where the one that
asks does so on behalf of another position, that position is a minter too, and the scope
falls within both, every restriction on each included; a component that mints on another
position's request is also a deputy, and its check is against the requester's authority.
Record the scope minted, the check, at minting or at each use, that it falls within the
minter's own authority at that time, or none, and whether a later reduction of the minter's
authority (revocation, expiry, a narrowed role) reaches what was minted, or is not stated. A
minted scope with no such check is a gap wherever the position asking for it can name a
scope any of its minters could not use itself; where nothing states whether a later
reduction reaches what was minted, that is an unconfirmed item, not a gap, until a line
settles it (in a source tree, for each kind of reduction, where the lines of the check at
the act or at each use are in the evidence and read nothing that reflects that reduction of
the minter's or the requester's own credential (a revocation, its expiry, a current role),
and no other line removes or marks what was minted or queued when it happens, they show it
does not, unless a line shows a component outside the evidence holding what was minted or
queued, its removal then not stated, a U id); where a line shows it does not, it is a gap
wherever a position can use what was minted after the minter could no longer act under that
scope. Where the input that makes a deputy act, or asks for a mint, names the authority it
is served under, the missing check and the unbound pair are one gap: record it once, as the
pair (its read-backs row or STRIDE row), for the position that writes the input or a value
the deputy copies into it, and give the deputies and mints row that id in its last column,
not a second row; a position that can make the deputy act without writing the input is
another entry position, and its borrowed-rights row stands as the deputy's row where it
gains through the act what it lacked (changing only when or how often an act runs whose
input another position wrote is an availability claim where a line shows running it again
changes nothing more; otherwise the row stands, conditional on a U id where that is not
stated); a restriction's row, entered from the holder of the restricted credential, stays
its own row ("Identity is not authority"), except a restriction passed in a field the
requester also writes, which is that pair's; a read-back's row and a pair's or a deputy's
row in one object, entered from the same position, are one row, the pair's or the deputy's.

**Identity is not authority.** What a requester or a minter may do is set by its identity
together with every restriction on what it may do, carried by its credential (in the token
or the session) or held by the policy of the entry point that admitted it; in this rule and
wherever the kit speaks of the restrictions a credential carries, both are meant. A
restriction is a bound in force at the moment of the act: a scope, a mark narrowing the
credential to reading, an audience, a permitted target, a time bound on when the act may
happen (hours of use, or a credential's validity window as a bound on when that credential
may be used). Record only restrictions a line shows the credential or the entry point's
policy carrying; a credential's type supplies none the evidence does not show. Wherever the
kit asks whether a position holds or lacks a right (fewer rights than a deputy, what it
gains, what it lacked), it lacks what no line shows it holding, except that rights a line
shows granted outside the evidence (a policy or role binding not in the tree) are not
stated, a U id and the row conditional on it, and a deputy's or component's own rights are
what the lines show, or not stated where granted outside the evidence, never taken to be
none. A line stating that a deputy acts on whatever the requester names ("fetches any report
the caller names") states the absence of its own check. Whether what was minted or queued
may outlive the minter's or the requester's credential (its expiry, a revocation, a narrowed
role) is a later reduction under "Minted authority is bounded by its minter", and so is an
act a deputy defers past that credential's window and carries out under its own identity;
where the requester's credential is itself presented at the act, its window is a bound in
force at that act. The two differ when nothing is stated: a bound in force that is not shown
to reach may already be exceeded by the act, so its row stands conditional, while whether a
later change reaches is open until a line settles it. Wherever the kit says a restriction
reaches, it means a check that decides the act reads it: the deputy's own check, its next
check, the minting check, or the check at each use of what was minted; a restriction copied
into what is minted reaches only where such a check reads it. A deputy needs no check of its
own where, and only where, its next check sees both the requester's identity, as the deputy
authenticated it, and every restriction on the requester. A mint falls within the minter's
authority only where a check, at minting or at each use, reads every restriction on the
minter against the scope minted. A check reads a restriction only where a line shows it
reading it, from its own policy, from the entry point's policy read directly, or from what
is passed to it; a restriction is passed on only from a credential the deputy verified, one
the next check itself verifies, forwarded unchanged, or the entry point's own policy on a
channel only that entry point can write, with lines (a relayed field the requester also
writes is not such a channel: "A relayed message is written by its sender"); where the entry
point's policy is passed on a channel whose writers are not stated, it is a pair conditional
for those writers, a U id, its reach for the holder staying as the entry point set it, and
on a channel others can write it is a pair; a credential the next check itself verifies
needs no channel test; a restriction the request merely names is a pair under "A named
authority binds only what it chose". A line saying the next check applies the requester's
permissions settles which identity that check uses (whether it is the requester's, as
authenticated, is settled under "A deputy carries whom it acts for"), and a restriction only
where that check's own policy holds it. Where the check's lines are in the evidence and do
not show it reading the restriction, the restriction is shown not to reach. Its reach is not
stated where those lines are not in the evidence (a component outside the tree, or a check a
document names but does not describe), and, for a system evidenced by a document, where the
description of the check does not mention the restriction, unless a line states the absence.
A check of the restriction against only part of what the deputy then does (the first of
several targets, or only the incoming request's shape) does not by itself make the
restriction reach a later hop; a deputy's own check of the restriction against the whole of
what it then asks is the deputy's check. Record each kind of credential that can drive a
deputy or a mint as its own row in the deputies and mints table, with its restrictions and
whether each reaches; a kind is a credential type or a way of narrowing one (each principal
type; a token narrowed in scope, use or target; a caller narrowed by the entry point's own
policy; a delegated credential), not each value a restriction can take, and for a mint on an
event, the event and the position whose authority it hands on. A restriction shown not to
reach is a gap wherever the position holding that credential can make the deputy act, or ask
for a mint, beyond that restriction; the row records what that position reaches past the
restriction, entered from that position. Where nothing states whether it reaches, record
that as an unconfirmed item; the gap's row stands, conditional on it. One defect is one row,
and defects entered from different positions are different defects, each its own row even
where another stands, except that the writers of one input share its pair's row: an unbound
pair's row holds what a position that can write the input (a position that writes a value
its reader copies into the input included) reaches, one row for all the writers of that one
input, each entry naming its own widest reach where they differ, and a value copied from one
input into another is one pair, at the last check that should bind it; a deputy's row, where
its next check sees only its identity and it makes no check that the requester holds the
right to what it asks, holds what a position that can make it act reaches through its
rights; a restriction's row holds what the holder of the restricted credential reaches past
it, unless the deputy's row already names that holder as an entry, or the holder also writes
a pair the deputy acts on, whose row then holds both, naming what reaches past the
restriction. Within one entry position, one missing check is one row: restrictions dropped
by the same call to the next check (the line where the deputy makes the call without them)
are one row, whatever kinds or deputies share that call; where that call carries a
credential a mint issued for it, the call and the minting check are one row, at the minting
check; and a mint with no check at all is one row, holding every restriction it ignores,
whatever kinds can ask for it. Every deputies and mints row involved gives the id of each
row it feeds.

**A stated exclusion is a stated absence.** Where the evidence says a check or a control
leaves something out (it is "not covered", "not implemented", "out of scope", "todo", "TBD",
deferred to a later design, release or the implementation, or a non-goal, said of a check, a
control, a restriction, or the scope of a credential or an authority; or a "must" or
"should" addressed to a caller or to code an integrator writes), that line states the
absence of that check for what it leaves out: a stated absence at the line rather than
silence. A line about the document's or the project's own scope that names no check is not
an entry. In a source tree, a comment or a document saying so is the project's claim
("Comments and log strings are claims, not behaviour"): the entry records it, and the code
at the lines settles whether the check leaves it out. Where the exclusion's own line hands
the part left out to a named component (a library, a service, the platform) whose lines are
not in the evidence, that is a delegation boundary, listed and not followed; where its lines
are in the evidence, they settle whether it covers it. Where it is left to a person (an
operator, a reviewer), it is a B2 control, which discharges nothing; where it is left to a
caller or to code an integrator writes, it is a check the system does not make. Either way
its disposition is decided like any other entry's, never "delegated", and the person, the
callbacks a caller supplies and code an integrator writes, listed among the delegation
boundaries, do not cover it. Where another check's lines are in the evidence, they settle
whether it covers what is left out; where they are not (a component outside the tree, or a
check a document describes without mentioning what is left out), covering is not stated (a
check the pass finds elsewhere, not one the exclusion's line names): an unconfirmed item,
and the row conditional on it. Each entry gets one disposition: the row or rows that hold it
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
position or condition reaches it and no position gains from it, with the reason. The absence
of a check is never a refusal, and is judged by this rule, not by "A deliberate refusal is
not a gap". An excluded halt, alert or fault check (a limit on demand, such as a rate limit
or a quota, is not a fault check; a limit on the system's own retries after a fault is one)
is a continue-on-fault path, judged under "Halt on fault is the control" below. A stated
exclusion gets a row wherever a position reaches an act the excluded check would have
decided and gains what it lacked (a position that supplies a value the excluded check would
have refused gains it wherever that value reaches another position's data, or a reader that
acts on it other than at the act the excluded check would have decided; sending more of what
a limit on demand admits gains nothing here, unless further attempts reach what a single
attempt could not, such as a password or code guessed by repetition), entered from that
position, or wherever a condition reaches the hazardous state the excluded check would have
observed (the hazard's row, filed by its effect); except that one whose only effect is on
how much or how long the system serves (capacity, rate, uptime), with no fault left
unobserved (demand beyond capacity is not a fault here) and no position gaining access, data
or authority it lacked, is an availability claim, never a row. A statement that a later
design, release or implementation will decide is not a check, and leaves the exclusion
standing at the evidence's date. A stated exclusion's row and a read-back's or a pair's row
entered from the same position for the same missing check are one row.

**A check binds only the key it reads.** A check that decides on an object by a key (a name,
a path, an id, a string a policy matches against) binds the object only as far as that key
identifies it. For each such check (an observer's, a deputy's own, or a B2 control's),
record the key it reads and the key that identifies the object where the act lands (the
store, the backend or the target), each with its line, and, where the two are in different
terms, which part of the identifying key each part of the check's key stands for, with its
line, or not stated. A part of the identifying key no line maps to a part of the check's key
is a part the check may not read. Where the check's key leaves out a part the identifying
key has (a namespace, a tenant, a project, a type, a version), or where a line shows the
naming lets two objects share the check's key (a separator a name may contain, a default
filled in for a missing part, or a short form that omits one), a position permitted for one
object reaches the other: for a machine check, a gap wherever a position can create, name or
be granted an object that shares the narrower key and so gains an object its own authority
does not reach, entered from that position. A check that reads no part of the object's
identifying key binds none of it, the narrowest case of this rule. A machine check whose key
is identical to the identifying key binds the object whatever the naming and leaves no gap
under this rule; a B2 control's check binds nothing whatever key it reads, its key record
serving the chain hunt alone; whether a value the input applies under an authority it names
is bound is judged separately ("A named authority binds only what it chose"). Where the
check's key reads no part of an object an input names, or is not stated to read any, "Every
object an input names needs its own binding" decides whether that object is bound, a line
showing it needs none included. Where the key the check reads, or the correspondence, is not
stated, record that; it is an unconfirmed item, with a row conditional on it, only where a
line shows that two objects can share a part the check may not read and a position can
create, name or be granted one, and otherwise no row. A stated exclusion that names a part
as left out of a check's key (one delegating that check to a component outside the evidence
excepted: that part's correspondence not stated, a U id, and a row conditional on it, only
where a line shows two objects can share that part and a position can create, name or be
granted one) states that part's correspondence: the key leaves it out, and the row stands on
the exclusion's line, not conditional on the key record; where that part alone makes the row
standing, the other parts' correspondence needs no unconfirmed item for it. In a source
tree, where the code at the check's lines shows it reading that part, the code settles it
and the exclusion states no gap there. A line leaving the key's format to the implementation
(not one delegating it to a component outside the evidence: not stated, as above) is a
stated exclusion: where a line shows two objects can share a part the format may leave out,
the row stands on that line. One defect is one row: for the same entry position, the key's
gap is the deputy's row or the restriction's row where the narrower key is a deputy's own
check or drops a restriction the requester's credential carries, the row of a stated
exclusion that names the part the key leaves out is the key's row, and a named object's or a
sibling-set member's gap for the same missing check is the key's row; rows entered from
different positions stay separate ("Identity is not authority"). The deputies and mints row,
the stated exclusion and the key record give the id of each row they feed.

**Every object an input names needs its own binding.** An input (a request, a message, a
call, a stored object read back) that names more than one object (a container and an item it
holds, a parent and a child, a resource and the record or version it selects, two parties
the act joins), or names one identity or authority the act is applied under while it is
authenticated as another position or not authenticated at all, in one field or across
several (a path, a header, a body), can land its act on any object it names. Record each
such input, every object it names with its line, and for each object one of: the check that
binds it (to the requester's right, or to the other objects it must agree with: that the
item is in the named container, that the child belongs to the named parent), with its line
(in a document, a check it describes as made, "must" or "should", never one it only permits,
"may"; a "must" or "should" that names the check as one the system or its implementations
make counts, its qualifier kept, and where it leaves only the mechanism open, it binds the
object, its key not stated (an unconfirmed item, with a row conditional on it, only where a
line shows two objects can share a part the check may not read and a position can create,
name or be granted one) ("A check binds only the key it reads"); one addressed to a caller
or to code an integrator writes states that the system does not make it: a stated exclusion,
its row standing on that line; a line leaving whether to check to an implementation or a
later design is none, and is a stated exclusion); a line showing it needs none (the act is
open on that object to every position that reaches the input, such as a recipient any
account may name, and a line letting a position write the input is never one: that write is
what makes the pair; in a source tree, a document, comment or test the project ships may
show it, cited as the project's claim, where the code at the act's lines makes no check that
contradicts it; code that merely omits a check is none, not this); an availability claim
(below); or none (in a source tree, none at the act's code; where the code that carries out
the act on that object, a call the act makes included, is outside the evidence, or an
exclusion's own line delegates the check to a component outside it, not stated; for a
document, none stated). A check that decides on one named object binds that object only ("A
check binds only the key it reads"), and a check left to a person is a B2 control and binds
nothing. Where one named object is the identity or authority the act is applied under and
the input is authenticated as another position, it is also a pair ("A named authority binds
only what it chose"): record it here with its binding, and its row is the pair's. Not stated
and none stated are unconfirmed items, and the row is conditional on them, unless a line
states the absence. Where the act serves, changes or acts on a named object with none, a
position permitted for the other objects (or any position that reaches the input, where no
check reads the requester's right) names one they do not hold or select (a file the named
project does not hold): a gap wherever the act serves that position data another position
holds, or changes data another position holds, and the position gains access, data or
authority it lacked, entered from that position. Where the act on that object serves no data
and changes none (a rewrite that leaves what it rewrites as it was, such as an index entry
rebuilt from the same source, changes none; a reply telling whether a guessed secret matched
serves data), and its only effect is on how much or how long the system serves (capacity,
rate, uptime: a prefetch, a reindex, a cache warm), it is an availability claim, listed with
the availability claims and never a row; the power to make such an act is not authority
gained. Where the item's identifier embeds its container's, record the line: it binds as far
as the key rule finds the embedded part read, and a load by that whole key, the embedded
part bound by a check at the lines, binds the item to that container: cite both lines. Where
a key record finds that a check's key reads no part of a named object's identifying key, or
does not state whether it reads any, this rule decides whether the object is bound, and the
key record gives no unconfirmed item of its own for it. One defect is one row: the named
object's gap and a pair's, a deputy's, a restriction's, a stated exclusion's or a key's row
entered from the same position for the same missing check are one row, held by that other
row (a pair's only where the pair is unbound, or its binding is not stated or none stated,
its row then conditional, and its row is entered from this position; a deputy's only where
the deputy's next check sees only its own identity); where a named object's and a
sibling-set member's gaps meet, the named object's row holds both, and a named object's gap
in an object read back with a missing check, entered from the same position, is one row with
the read-back's. A pair bound to the authority's identity (the writer authenticated as that
authority) binds the item to what the authority chose, not to what it may reach: the item is
still judged by this rule. The entry gives the id of the row that holds it.

**A check stated for one is owed by its like.** Where the evidence makes, requires or
recommends a check for one member of a set of like inputs or acts (in a source tree, a check
the code makes; in a document, one it describes as made, or requires, "must", or recommends,
"should"), the check and the act it precedes, with their lines, show what the check guards;
the row keeps any qualifier, and a check the evidence only permits ("may") states nothing
here, nor does a line leaving whether to check to an implementation or a later design, or
one addressed to a caller or to code an integrator writes. A value the code derives from
what it has already checked (the session's user set as a message's sender) is a check here.
Members are alike where each carries what the check guards, whatever their names or routes:
the same data served, the same binding of a named identity or object, or the same right
exercised over the same object or kind of object (the right the stated check reads: for a
check that re-proves who the caller is, such as a password re-entered, the right to the act
it precedes alone; for a gate (a check on entry to a place or a resource, such as a door),
admission to what its own line says it admits to and nothing beyond it (a further place
several routes reach does not make each route a member); for a role or permission check,
that role or permission exercised over the object or kind of object the act it precedes
changes or serves, with a line; a broader identity both act under, the caller's session or
the service's own, does not make them alike); for a limit on demand, the same capacity drawn
on or a secret tested that admits to the same account or right, whatever its form (a
password and a reset code for the same account are alike). Each member's share is shown with
a line; a shared form alone (the same kind of identifier, the same verb) does not make them
alike, and an input shown to carry none of it is not a member. Where the value the check
reads can reach the guarded act from more than one source (a credential the check derives it
from, a field the requester writes into a message relayed onward, a stored copy, a second
authenticator), each source is a member of its own, and the check covers a source only where
a line shows it reading the value from that source; a line saying the check applies to every
request, or that the value passes through the check's component, settles which requests
reach the check, not which sources it reads. A line scoping the check to one source does not
state the absence of a check for another. A check left to a person is a B2 control: it
founds no set and covers no member; where a like input or act skips that person's check,
record the skip with the B2 control, by its BC id and the input's line, as a gap in people's
observation for the chain hunt ("Links made of people count"), never a row from this rule. A
member whose only check is a person's is a member with none (for a document, none stated
unless a line states there is no machine check; a line naming only the person's check does
not state it), with its BC id recorded beside it. Record each set, the shared property,
every member with its line, and for each member one of: the same check at its own lines; a
line showing another machine check at its lines covers it (a person's check covers nothing,
and a comment or document claiming a check, a person's included, that the code at the
member's lines does not make covers nothing: record the claim as a disagreement, and a
claimed person's check as a B2 control only where a line shows it is made); an availability
claim (below); or none (in a source tree, none at the member's code; where the code that
carries out the member's act, a call it makes included, is outside the evidence, or an
exclusion's own line delegates the check to a component outside it, not stated, an
unconfirmed item and the row conditional on it; for a document, none stated, an unconfirmed
item and the row conditional on it, unless a line states the absence). A member with none is
a gap wherever a position reaches, through that member, what the check would guard there
(the same binding, data or right, for that member's own act) and gains what it lacked,
entered from that position; its row cites the stated check's line beside the member's own.
Where the stated check only limits how much or how long the system serves (a rate limit, a
quota; a cap on the system's own retries after a fault is a fault check, not this: a member
without it is a continue-on-fault path, its hazard row filed by its effect), the member's
lack is an availability claim, listed with the availability claims and never a row, unless
further attempts through the member reach access, data or authority a single attempt could
not (a password or code guessed by repetition), where it is a row like any other; demand
beyond capacity is not a fault here, and what it causes is an availability claim. Where the
member's own act serves no data and changes none (a rewrite that leaves what it rewrites as
it was, such as an index entry rebuilt from the same source, changes none; a reply telling
whether a guessed secret matched serves data), and its only effect is on how much or how
long the system serves, its lack is an availability claim too, whatever the stated check
guards; the power to make such an act is not authority gained. One defect is one row: the
member's gap and a read-back's, a pair's, a deputy's, a restriction's, a stated exclusion's,
a key's or a named object's row entered from the same position for the same missing check
are one row, held by that other row (a pair's only where the pair is unbound, or its binding
is not stated or none stated, its row then conditional, and its row is entered from this
position; a deputy's only where the deputy's next check sees only its own identity); the set
gives the id of the row that holds each member's gap, and that row cites the stated check's
line beside the member's own and keeps its qualifier.

**Comments and log strings are claims, not behaviour.** Cite them as what the project
says, never as what the code does.

## Availability is never ranked

Availability and performance claims go in a section listed and left unevaluated. They are
never a row, never a severity, never a reason to rank a finding down. This holds both
ways: for a component that keeps serving through a fault, and for a fix that makes a
component refuse. A refusal is the model being satisfied; ranking its cost argues against
halt on fault against a baseline nobody has modeled. What can be ranked is an
inconsistency between components (one part binds a destination while another substitutes
a different one), because that refuses work meant to succeed and is a defect.

Availability claims include output, demand and schedule: a production target, a delivery
date, a deadline. A party that sets the system's targets or schedule is not an attacker
for setting them: the target is listed with the availability claims, not made an entry
position. A party that reaches the system's inputs (a client that sends requests, an
operator at a console) is still an entry position for what it can do there.

## Halt on fault is the control

The required control for every finding is one thing: the observer alerts and the system
halts until the fault clears or the privileged actor leaves. Continue-on-fault is a failed
control, not a mitigation. A retry with no limit, a degraded mode, a "warn and continue",
a fallback to a weaker channel and a default that serves are all continue-on-fault. A halt
that degrades into a continue (a check that fails, after which the system skips the check)
is recorded as exactly that.

A safety check that is off by default is missing in every deployment that leaves it off;
record the default as the finding, not the option that would enable it. A check that an
option, flag or environment variable can switch off is present only while it is on, and
the switch is a B2 path to its absence: privileged actors cause harm by mistake as well
as by malice, and an operator who does not know about a hidden fault will reasonably turn
off the check that would have caught it.

## Evidence and scope

**Every claim is a file and a line someone opened.** A claim nobody opened is marked
unconfirmed. A claim that rests on code not available (a dependency, a runtime, a service)
is marked as resting on it, and stays marked wherever it is used.

**A claim carries its source's confidence, never more.** A quotation keeps every qualifier
in the sentence it comes from ("probably", "it would appear", "may"), and a claim built on
a hedged statement stays hedged. Say what kind of statement a citation is wherever it
matters: what the code does, what a comment or document says it does, a source's own
finding, its presumption, a quotation of another document inside it, or recorded data. A
row that rests on a presumption or a quoted claim says so. On the calibration run against
a published investigation, restoring dropped qualifiers was the final sweep's largest
category of correction.

**No counterfactuals.** What would have happened had a check fired, or what a party
would have done had it known, is the source's claim or nobody's. State what the lines show
and stop.

**Source-supported against inferred.** A step that is a line in the audited tree is
source-supported. A step that rests on a seam's behaviour (the kernel, a runtime, a
library, a service, an operator's configuration) is inferred, with the seam named.

**Posture is not code.** Charts, unit files, manifests, default configuration and
documentation are posture. Label them as posture wherever cited. Where a code default and
a posture default disagree, give both.

**Deployment assumptions are marked.** A row or chain that needs a configuration away from
the shipped default, or a deployment the tree cannot produce on its own, is marked as a
deployment assumption and listed after the source-supported ones.

**Scope extensions are declared.** When settling a claim needs one file outside the agreed
scope, open it, declare it as a scope extension wherever it is used, and keep it to the
one fact it settles.

**Delegation boundaries are listed, not followed.** Name what the system hands to other
components (a library, a service, the kernel, the operator) and leave it there.

## Ranking

**One package.** Rank risks by what a position gains times how many installations or users
it reaches in one act, with nothing positioned to notice. For a single system with one
installation and no users in that sense (one plant, one institution), read the reach as how
many units one act reaches, then how far toward the floor (part of the system, the whole
system, the public). The result is an order:
place each risk against the others and break a tie by the position that needs no
privileged act. The scales below are not used for one package.

**An aggregate.** Rank by severity times detection times exposure, each scored 1 to 4:

- **Severity.** 4: an external position (B3) reaches customer data or identities with no
  further condition, for every user in one act. 3: the same reach behind a privileged
  condition, a deployment assumption or a caller's behaviour, or an external gain bounded to
  part of the system. 2: no position gains what it lacked, but a check on the path is
  absent, removable or inconsistent, or the gap is the only record of a fault. 1: the
  position already holds what the gap gives, or a record is missing with nothing gained.
- **Detection.** 4: nothing notices the path. 3: a log only. 2: an alert. 1: a halt.
- **Exposure.** The evidence step's tier for the risk. 4: the top list. 3: the second tier.
  2: an unverified lead. 1: none found. When no evidence step ran, say so and rank by
  severity times detection alone.

Ties go to the higher severity, then the lower rank in the risk's own package's impact
order, then the position that needs no privileged act. State the scales once, at the head
of the risks. A finding that reaches customer data ranks above one that reaches only the
system's own records; availability is not ranked. Give each ranked entry its row and chain
ids. The deliverable states this rule once, as its ranking rule.

## Modeling only

The audit describes code paths and their preconditions. It never includes exploitation
steps, working payloads, field values that make an attack work, addresses of live systems,
or instructions to run anything against a system the auditor does not own. A deliverable
states the path, the precondition and the file and line, and stops there.
