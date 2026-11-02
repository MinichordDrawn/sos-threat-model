# Cases: whose check binds, stated exclusions, reductions and deputies

Each case is a fragment of evidence. Line numbers are given as `file:N` and are what the
lines say; nothing else exists. Treat each case independently, except where a case says "as
case X": then it is case X with the changes it names.

## Case J1 (source tree)
`ops/process.md:5`: "An operator reviews and approves every deploy by its full
`namespace/name` before it runs." `deploy/api.go:20` applies the deploy to whatever
`namespace/name` the caller's request names; the caller is authenticated
(`deploy/api.go:12`) and may deploy only to its own namespace (`deploy/policy.go:4`). No
code checks the named namespace against the caller.

## Case J2a (document)
`spec.md:30`: "`GET /c/{container}/items/{item}` returns the item." `spec.md:31`: "The
server MUST check the caller may read the container." `spec.md:32`: "Implementations should
verify that the item belongs to the container." Item ids are global (`spec.md:5`).

## Case J2b (document)
As case J2a, except `spec.md:32`: "Whether to verify that the item belongs to the container
is left to implementations."

## Case J2c (document)
As case J2a, except `spec.md:32`: "The caller MUST verify that the item belongs to the
container before calling the endpoint."

## Case J2d (document)
As case J2a, except `spec.md:32`: "Implementations MUST verify that the item belongs to the
container, by whatever means they choose."

## Case J3 (source tree)
`auth/mint.go:15` lets an admin mint an API token carrying the admin's role.
`auth/verify.go:10-20` checks a token's signature and its expiry claim and nothing else;
there is no revocation list and no lookup of the minting admin's current role anywhere in
the tree. `admin/demote.go:8` removes an admin's role.

## Case J3b (source tree)
As case J3, and `deploy/gateway.yaml:4` routes every API request through an external API
gateway that caches each issued token and answers from that cache (`deploy/gateway.yaml:6`);
the gateway's code is not part of the evidence.

## Case J4 (source tree)
`jobs/queue.go:20` stores the requester's API token with a job; `jobs/run.go:30` runs the
job hours later by calling the billing API with that stored token (`jobs/run.go:32`). The
billing API's own check is in a service outside the evidence. Tokens carry a validity window
(`auth/token.go:6`).

## Case J5 (document)
`design.md:50`: "On a lost connection the agent reconnects and resends; the cap on reconnect
retries is TBD." `design.md:51`: "Each resend re-applies the last command."

## Case J6 (document)
`spec.md:70`: "`GET /t/{tenant}/objects/{object}` returns the object; the gateway checks the
caller belongs to the tenant." `spec.md:71`: "Tenant isolation of object ids is out of scope
for this document; the storage service handles it." Object ids are global (`spec.md:8`). The
storage service's design is not part of the evidence.

## Case J7 (source tree)
`store/put.go:10` lets any signed-in user U write a record naming a tenant `T`.
`hooks/fire.go:5` lets anyone, unauthenticated, trigger the webhook for a record id.
`hooks/run.go:20` acts on the record under the webhook service's own identity, which may
write to any tenant (`hooks/identity.go:3`), applying the record's contents to tenant `T`,
and checks nothing about who triggered it or who wrote the record.

## Case J7b (source tree)
`hooks/register.go:8` lets a signed-in user U register a webhook with a target URL and body;
the webhook service sends that body to that URL under U's own grant (`hooks/send.go:20`).
`hooks/retry.go:5` lets anyone, unauthenticated, press "retry delivery" for any webhook id,
which re-sends the same body to the same URL; nothing is returned to the presser.

## Case J8 (document)
`arch.md:40`: "The report service fetches any report the caller names, using its own service
account, which can read every report." Nothing says what reports any caller may read.

## Case J8b (document)
`arch.md:40`: "The report service fetches the report the caller names, using its own service
account, which can read every report." Nothing else says what the report service checks, or
what reports any caller may read.

## Case J9 (source tree)
`db/policy.sql:3` makes the store force the `owner` column of every row to the writing
account on every insert and update, whoever writes. `app/share.go:25` reads a row back and
grants the row's `owner` edit rights over the shared document named in the same row,
checking nothing else.
