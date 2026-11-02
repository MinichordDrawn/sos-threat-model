# Cases: relayed fields, the widest reach and failed premises

Each case is a fragment of evidence. Line numbers are given as `file:N` and are what the
lines say; nothing else exists. Treat each case independently, except where a case says "as
case X": then it is case X with the changes it names.

## Case A (source tree)
`gate/relay.go:20` authenticates the caller's API token and loads the caller's roles.
`gate/relay.go:24` runs `job.Roles = append(job.Roles, caller.Roles...)` on the job the
caller submitted (decoded from the caller's request body at `gate/relay.go:18`), then
`gate/relay.go:26` sends the job to the worker queue, which only the gate can write
(`deploy/queue.yaml:4`). `worker/run.go:10` runs the job with administrator rights when
`"admin"` is in `job.Roles`, and with read-only rights otherwise. Roles are `viewer`,
`editor` and `admin` (`gate/roles.go:3`).

## Case B (source tree)
As case A, except `gate/relay.go:23` runs `job.Roles = nil` before the append at
`gate/relay.go:24`.

## Case C (source tree)
As case A, except `gate/relay.go:24` builds a new job, `out := Job{Owner: caller.ID, Roles:
caller.Roles, Script: job.Script}`, and `gate/relay.go:26` sends `out`.

## Case D (document)
An operations manual. `manual.md:40`: "The dispatcher checks the crew member's badge and
passes the member's name and certifications to the depot controller in the order's `certs`
field." `manual.md:41`: "Crew members submit orders through the dispatcher terminal; the
order form has a `certs` field." `manual.md:60`: "The depot controller releases hazardous
loads only on orders whose `certs` include `HAZMAT`." The depot controller accepts orders
only from the dispatcher (`manual.md:62`). Nothing else mentions `certs`.

## Case E (document)
As case D, plus `manual.md:42`: "The dispatcher discards any `certs` value in a submitted
order and writes the certifications on record for the badge."

## Case F (source tree)
`api/forward.go:12` authenticates the caller and calls `proxylib.Forward(req, caller)`.
`proxylib` is a vendored dependency that is not in the evidence. `backend/auth.go:30` reads
the `X-Acting-User` field of the forwarded request and serves that user's files. Nothing
else in the evidence mentions `X-Acting-User`.

## Case G (document)
A building security design. `design.md:10`: "The door controller reads the key classes from
the visitor's key chip." `design.md:11`: "The kiosk lets a visitor type extra classes for a
visit; the controller merges them with the chip's classes." `design.md:20`: "For every
visitor, the controller removes the `master` class from the classes it read from the chip
before deciding entry." `design.md:21`: "`master` opens every door in the building." Nothing
else mentions classes.

## Case H (document)
As case G, except `design.md:20`: "After merging the chip's classes with any typed at the
kiosk, the controller removes the `master` class from the merged list before deciding
entry."

## Case I (source tree)
Pass 2 wrote row E4: "The invite endpoint (`team/invite.go:15`) sets the invitee's role from
the request's `role` field with no check on its value; impact: the inviter grants the
invitee any role in the team." Roles are `member`, `maintainer` and `owner`
(`team/roles.go:2`); `team/delete.go:8` lets an `owner` delete the team and every repository
in it. The web form (`web/invite.tsx:40`) offers only `member` and `maintainer`. Any team
member may invite (`team/invite.go:12`).

## Case J (source tree)
As case I. The chain hunt proposed chain X3: E4 (invite with any role) joined to E9 (an
owner deletes the team and all its repositories, `team/delete.go:8`). Pass 5 dropped X3 as
"E4 already reaches it: any role". Row E4's impact reads exactly as in case I.

## Case K (source tree)
As case A, except the worker never reads `job.Roles`; `worker/run.go:10` always runs the job
with read-only rights, and prints `job.Note`, a free-text field the caller wrote, to the job
log.

## Case L (document)
As case D, except `manual.md:40` reads: "The dispatcher checks the crew member's badge. Crew
without a badge may still submit orders as guests." Nothing is said about guests' `certs`.

## Case M (source tree)
As case A, except `gate/relay.go:24` runs `job.Roles = caller.Roles`.

## Case N (source tree)
`desk/submit.go:8` authenticates the caller's session and reads the request body into
`ticket` (`desk/submit.go:9`); the body carries `ticket.Requester`. `desk/submit.go:12` logs
"submitted by" with the session's user and then calls `approvals.Run(ticket)`
(`desk/submit.go:14`). `approvals/run.go:20` approves refunds up to 10,000 when
`ticket.Requester` is a member of `finance` (`approvals/groups.go:5` lists members of
`finance` and `support`), and up to 50 otherwise. Nothing else sets `ticket.Requester`.

## Case O (source tree)
Pass 2 wrote row S7: "The import job (`jobs/import.go:30`) runs under the account named in
the uploaded manifest's `account` field with no binding to the uploader; impact: the
uploader acts as any account." Accounts carry a tier (`accounts/tier.go:4`: `basic`,
`staff`, `root`); `accounts/tier.go:9` lets a `root` account change any account's password.
The chain hunt proposed chain X5: S7 joined to T2 (log tampering). Pass 5 dropped X5 because
T2 does not hold at its lines. Row S7's impact reads exactly as above.

## Case P (source tree)
Pass 2 wrote row I3: "The log endpoint (`jobs/log.go:5`) serves the import log of the
account named in the request's `account` parameter, with no check that the caller owns it;
impact: the caller reads any account's import log." Accounts carry a tier
(`accounts/tier.go:4`: `basic`, `staff`, `root`); `accounts/tier.go:9` lets a `root` account
change any account's password. Import logs list file names only (`jobs/log.go:9`).

## Case Q (source tree)
`hub/forward.go:10` authenticates the caller and relays the caller's request, including its
`groups` list, to the shard without further changes to `groups`. `hub/forward.go:8` first
removes `superadmin` from the request's `groups` list. `shard/authz.go:3` grants every
action when `superadmin` is in `groups`; `shard/authz.go:6` grants read access to every
tenant's data when `auditor` is in `groups`; groups are `member`, `auditor`, `superadmin`
(`shard/groups.go:2`).

## Case R (document)
An architecture document. `arch.md:30`: "The hub removes `superadmin` from the request's
`groups` list and relays the request to the shard." `arch.md:31`: "Clients may put a
`groups` list in their requests." `arch.md:40`: "The shard grants every action to
`superadmin` and read access to every tenant's data to `auditor`." Groups are `member`,
`auditor`, `superadmin` (`arch.md:12`). Nothing else mentions `groups`.

## Case S (source tree)
Service `billing` (deployed for tenant A only, `deploy/billing.yaml:3`) sends requests to
its sidecar over a local socket. `sidecar/proxy.go:15` copies every request unchanged,
headers included, to the backend over a socket only the sidecar can write
(`deploy/sock.yaml:2`); the sidecar authenticates no one. `backend/data.go:22` serves the
data of the tenant named in the request's `X-Tenant` header. Tenants are peers
(`backend/tenants.go:1`).

## Case T (source tree)
The chain hunt proposed chain X7: row I2 (an export endpoint, `api/export.go:12`, serves any
project's member list with no check that the caller belongs to the project; impact: the
caller reads any project's member list) joined to row T4 (`api/import.go:30` lets any caller
overwrite any project's settings). Pass 4 rejected X7 as "already held by I2: I2 reaches
project settings". `api/export.go:12-14` serves member lists only; nothing in I2's lines
touches settings. Projects are peers (`api/projects.go:2`).

## Case U (source tree)
The chain hunt proposed chain X9: row S4 (`sync/pull.go:40` pulls any repository named in a
webhook's `repo` field with no check that the webhook's sender owns it; impact: the sender
pulls any repository) joined to row T6 (`ci/run.go:12` runs the pulled repository's build
script with the CI token). Pass 4 rejected X9 "as already held by S4: S4 reaches running
code with the CI token". Nothing in `sync/pull.go` or any other line says what happens after
the pull, and nothing shows S4 reaching the CI token or refuting it.

## Case V (source tree)
The chain hunt proposed chain X11 of three gaps: S9 (any caller names the tenant in
`X-Tenant`, `api/tenant.go:7`), T2 (said to let a tenant's config override the storage
bucket, `cfg/load.go:20`) and I5 (`store/get.go:31` serves any object in the configured
bucket). At pass 5, T2 does not hold: `cfg/load.go:20-24` reads the bucket from the
deployment file only. Rows S9 and I5 stand.

## Case W (source tree)
As case A, except there is no `deploy/queue.yaml`, and nothing in the evidence says who can
write the worker queue.

## Case X (source tree)
As case K, except `worker/run.go:10` runs `job.Note` as a shell command with the worker's
rights, which are wider than any caller's (`worker/rights.go:2`).

## Case Y (document)
As case L, plus `manual.md:43`: "For badge holders, the dispatcher overwrites `certs` with
the certifications on record."

## Case Z (source tree)
As case A, except `gate/relay.go:25` signs the job with the gate's key, and
`worker/run.go:8` rejects any job whose signature does not verify against the gate's key.

## Case AA (source tree)
As case B (the gate clears and sets `job.Roles`), and `worker/run.go:12` runs `job.Script`,
a field the caller wrote, under the caller's own roles as the gate set them.

## Case AB (source tree)
As case O, plus `jobs/import.go:34`: "an import run under a `staff` account may also rewrite
that account's team settings". Nothing states what an import run under `root` does beyond
what any import does.

## Case AC (source tree)
As case C, except `gate/relay.go:24` builds `out := Job{Owner: caller.ID, Roles: job.Roles,
Script: job.Script}`.

## Case AD (source tree)
As case B (the gate clears and sets `job.Roles`), except there is no `deploy/queue.yaml`,
and nothing in the evidence says who can write the worker queue.

## Case AE (document)
As case D, plus `manual.md:44`: "The dispatcher refuses any submitted order whose `certs`
field is filled in."
