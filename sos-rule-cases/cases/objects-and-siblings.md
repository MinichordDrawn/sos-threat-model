# Cases: named objects and sibling sets

Each case is a fragment of evidence. Line numbers are given as `file:N` and are what the
lines say; nothing else exists. Treat each case independently, except where a case says "as
case X": then it is case X with the changes it names.

## Case A (source tree)
`api/files.go:40` handles `GET /projects/{p}/files/{f}`. `api/files.go:42` calls
`requireMember(caller, p)`, which returns 403 unless the caller is a member of project `p`.
`api/files.go:45` calls `store.GetFile(f)`, which runs `SELECT * FROM files WHERE id = ?`
with `f` (`store/files.go:12`); file ids are global integers. `api/files.go:47` writes the
file's content to the response. Nothing else touches the request.

## Case B (source tree)
As case A, except `store/files.go:12` runs `SELECT * FROM files WHERE project_id = ? AND id
= ?` with `p` and `f`, and returns not-found when no row matches.

## Case C (source tree)
As case A, except after `api/files.go:45`, `api/files.go:46` calls `requireReader(caller,
file.ACL)`, which returns 403 unless the caller is on the file's own access list.

## Case D (document)
A specification. `spec.md:100`: "`POST /rooms/{roomId}/fetch` takes a body `{"ids": [...]}`
and returns the listed events." `spec.md:102`: "The server MUST apply the room's access
control list to the requesting server before answering." Event ids are global (`spec.md:20`:
"Event ids are unique across all rooms."). Nothing else in the document mentions the
endpoint.

## Case E (document)
A specification of messages one server pushes to another. `spec.md:200`: "A `typing` message
names `user_id`. Receiving servers should verify that the user belongs to the sending
server." `spec.md:220`: "A `status` message names `user_id` and sets that user's displayed
status on the receiving server." Nothing else is said about `status`. Every message arrives
authenticated as from its sending server (`spec.md:10`).

## Case F (source tree)
`api/export.go:30` (`POST /export`) calls `ratelimit.Take(caller)` at `:31`, then exports
the caller's own data. `api/import.go:30` (`POST /import`) imports into the caller's own
data and calls no rate limit. Both require the caller's session (`:29` in each).

## Case G (document)
`spec.md:300`: "`GET /rooms/{roomId}/state` returns the room's state. It returns 403 when
the requesting server is not in the room." `spec.md:320`: "`GET /version` returns the
server's software name and version." Nothing else is said about either.

## Case H (source tree)
`api/move.go:50` handles `POST /accounts/{a}/transfer` with body `{"to_account": t,
"amount": n}`. `:52` checks the caller owns account `a`. `:55` moves `n` from `a` to `t`
with no check on `t` beyond its existence. Moving money into an account is the point of a
transfer; any account may receive (`docs/transfers.md:3`: "Any account may receive a
transfer.").

## Case I (source tree)
`api/docs.go:20` handles `GET /docs/{id}` where ids have the form `<tenant>/<n>`
(`model/doc.go:5`). `:22` parses the tenant from the id and checks the caller belongs to it;
`:24` loads the document by the full id string.

## Case J (document)
`spec.md:400`: "Uploads to `/media` are reviewed by an administrator before they are shown
to other users." `spec.md:420`: "Avatars uploaded to `/avatar` are shown to other users."
Nothing else is said about either.

## Case K (source tree)
`api/login.go:20` (`POST /login`, a password) calls `ratelimit.Take(ip)` at `:21` before
checking the password. `api/reset.go:20` (`POST /reset/confirm`, a 6-digit code mailed to
the account's owner) checks the code at `:24` and, on a match, sets a new password; it calls
no rate limit. Both are open to anyone.

## Case L (source tree)
`api/keys.go:10` (`POST /keys/rotate`) checks at `:12` that the caller holds the `admin`
role. `api/keys.go:40` (`POST /keys/revoke`) has no role check in its code; `:38` is a
comment: "Revocations are approved by the on-call operator before they take effect", and the
code at `:41` revokes the key at once. Both change the service's signing keys
(`model/keys.go:3`).

## Case M (source tree)
`api/users.go:10` (`DELETE /users/{u}`) checks at `:12` that the caller is `u` or an admin.
`api/users.go:30` (`GET /users/{u}/profile`) checks nothing; `docs/profiles.md:4`: "Profiles
are public: any visitor may read any profile." Both name a user id.

## Case N (source tree)
`api/msg.go:10` (`POST /messages`, from a signed-in user) sets `from` to the session's user
at `:12`. `api/msg.go:30` (`POST /messages/system`, from an internal service holding a
service token checked at `:31`) takes `from` from the body and stores it at `:34`; any user
id is accepted. Both store a message with a `from` that recipients see as its sender
(`model/msg.go:6`).

## Case O (two packages, a seam)
Package P1 `client/fetch.go:15` sends `GET /orgs/{o}/items/{i}` to package P2 on behalf of
its user, after checking at `:12` that its user may act in org `o`. P2 `server/items.go:30`
serves it, checks at `:32` that the request comes from P1 (a service credential), and loads
item `i` by its global id at `:34`. Nothing else checks `i`.

## Case P (source tree)
`api/search.go:10` (`POST /tenants/{t}/reindex/{doc}`) checks at `:12` that the caller is a
member of tenant `t`, then at `:14` queues a rebuild of the search index entry for document
`doc`, a global id, without checking `doc` belongs to `t`. The rebuild reads the document
and rewrites only its index entry, which holds the same words (`index/build.go:8`); nothing
is returned to the caller.

## Case Q (source tree)
`api/account.go:10` (`POST /account/email`) requires the caller to re-enter their password
at `:12` before changing the session user's email. `api/account.go:30` (`POST
/account/display-name`) changes the session user's display name with no password check. Both
act under the caller's session (`:9`, `:29`).

## Case R (document)
`spec.md:500`: "A server may check that a `read_marker` message names a user in the room."
`spec.md:520`: "A `pin` message names a user and pins a message for that user." Nothing else
is said about either.

## Case S (document, a physical system)
`plant.md:40`: "Entry to the reactor hall requires a badge read by the hall door's card
reader, which admits only badge holders cleared for the hall." `plant.md:44`: "Entry to the
turbine hall is by the guard at its door, who checks badges." `plant.md:46`: "The cable
tunnel joins both halls; its hatch is unlocked." All three give access to the same
switchgear room (`plant.md:50`).

## Case T (source tree, one package)
`api/report.go:20` (`GET /orgs/{o}/reports/{r}`) checks at `:22` that the caller is in org
`o`, then calls the vendored client `vendor/reports.Get(r)` at `:24` and returns the result.
The `vendor/` directory is outside the evidence (not in the tree given to the run).
