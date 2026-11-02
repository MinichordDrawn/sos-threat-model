# Key: relayed fields, the widest reach and failed premises

For `cases/relays-and-reach.md`. Keyed to the kit at plugin version 1.1.1. "Standing" means
the row holds on the lines given; "conditional" means it rests on an unconfirmed item (a U
id).

Where a case leaves a channel's or a hop's writers unstated (F, Q, S and others), the kit
(`judging-rules.md`, "A relayed message is written by its sender" and "A deputy carries whom
it acts for") gives a further "writers not stated" entry, conditional on its own U id. A
reader who adds it is applying the rule, not erring; the key names it only where the case is
about it (W, AD).

- **A:** relay gap. The append at `gate/relay.go:24` adds the gate's values and removes none
  of the caller's, so the caller still writes `job.Roles`; the queue only the gate writes
  settles who wrote the message, not the field. Unbound pair, standing row, entered from
  every authenticated caller without `admin`. Widest reach: `admin`, admitted at
  `worker/run.go:10`. The deputies-and-mints row gives the pair's id.
- **B:** `job.Roles` is cleared and set, so the gate alone writes it. No row.
- **C:** built afresh, copying named fields from the gate's own data. No row.
- **D:** no line shows the dispatcher removing or replacing the crew member's `certs`
  (`manual.md:40` describes the dispatcher's own values; `:41` shows the requester writing
  the field). One U id; conditional row, entered from every crew member without `HAZMAT`,
  badge-checked ones included. Widest reach: `HAZMAT`, a hazardous release (`manual.md:60`).
- **E:** `:42` discards and replaces `certs` on every order. No row.
- **F:** the relaying code (`proxylib`) is outside the evidence: whether the caller's value
  reaches the backend is not stated, one U id for the relay and the pair. Conditional row,
  entered from every authenticated caller; any user's files, no user stated more privileged.
  `proxylib` listed as a delegation boundary.
- **G:** sibling set (the removal at `:20`). The kiosk-typed classes (`:11`) are a source of
  their own, none stated, a U id: a line scoping the check to one source does not state its
  absence for another. Conditional row, entered from any visitor. Widest reach: `master`,
  every door (`design.md:21`).
- **H:** `:20` reads the merged list, so both sources are covered. The remaining classes
  name no value reaching anything. No row.
- **I:** row E4 names `owner` (`team/roles.go:2`): a granted role lasts, so it reaches
  deleting the team and every repository (`team/delete.go:8`). The web form
  (`web/invite.tsx:40`) reads nothing on the API path. Standing, entered from any team
  member (`team/invite.go:12`).
- **J:** E4's impact must name `owner` and the deletion it reaches; that reach is added to
  E4. Re-tested against the named impact, X3 adds nothing E4 does not reach, so the drop
  stands, recorded with the addition.
- **K:** nothing applies `job.Roles`, and `job.Note` is only logged; no one gains. No row.
- **L:** as D, one row entered from both badge-checked crew and guests (the writers of one
  input share its row). Widest reach: `HAZMAT`.
- **M:** a whole-field overwrite from the credential. No row.
- **N:** the desk authenticated the session but passes `ticket.Requester`, a body field:
  unbound pair, standing row, entered from every session user outside `finance`. Widest
  reach: a `finance` member, refunds up to 10,000 (`approvals/run.go:20`). The "submitted
  by" log binds nothing.
- **O:** S7 names `root` with its reach through the import not stated (a U id covering that
  part of the impact alone); never the password change at `accounts/tier.go:9`, which is
  another act. X5 restated without T2 is S7 alone, not a chain: the drop stands, with T2's
  lines tested as a gap.
- **P:** I3 says the act reaches no more under one account than another (import logs list
  file names only, `jobs/log.go:9`). Never `root`'s password change.
- **Q:** `:8` removes `superadmin` only; the caller's `auditor` reaches the shard. Unbound
  pair, standing row, entered from every authenticated caller without `auditor`. Widest
  reach: `auditor`, reading every tenant's data (`shard/authz.go:6`).
- **R:** as Q in a document: a partial removal settles nothing about the other values, and
  "relays" alone does not state they reach. One U id; conditional row, entered from every
  client. Widest reach: `auditor` (`arch.md:40`).
- **S:** the sidecar copies `X-Tenant` unchanged; the socket only it writes settles the
  message, not the field. `billing`, confined to tenant A by its deployment, gains the other
  tenants' data. Standing row, entered from `billing`; tenants are peers.
- **T:** X7's premise fails at I2's lines (member lists only). Restated without it, no line
  puts I2's output into T4's input, so the two only add: rejected, with the failed premise
  and the restatement recorded. Nothing is added to I2; I2 says no project is more
  privileged.
- **U:** X9's premise fails. Restated as S4 then T6, `ci/run.go:12` takes "the pulled
  repository", which puts the ends in contact without showing the step: a conditional chain,
  moved out of the rejected list. No CI-token impact is added to S4.
- **V:** X11 restated without T2: `cfg/load.go:20-24` refutes the tenant-to-bucket step, and
  a refuted step is not an unstated one, so S9 and I5 do not join and the rejection stands,
  recorded with the restatement. T2's lines tested as a gap: none.
- **W:** as A, the caller's entry standing (the code shows the caller's value reaching the
  worker); a further entry for the queue's writers, not stated, conditional on their U id.
  One row.
- **X:** the worker runs the caller's `job.Note` with its own wider rights and checks
  nothing about the caller: the deputy's row, standing, entered from every authenticated
  caller. Reach: the worker's rights (`worker/rights.go:2`).
- **Y:** the badge holders' route is settled by the overwrite at `:43`; the guests' route is
  not stated. Conditional row, entered from guests. Widest reach: `HAZMAT`.
- **Z:** as A, standing: the signature confines the message to the gate, not the field it
  relays for the caller.
- **AA:** the caller's own script under the caller's own roles gains nothing. No row.
- **AB:** as O, S7 names `root` with its reach through the import not stated (a U id), and
  beside it `staff`'s stated reach, rewriting that account's team settings
  (`jobs/import.go:34`). Never the password change. The drop of X5 stands.
- **AC:** the fresh build copies the requester's `Roles`, which stay the requester's: as A,
  standing, widest reach `admin`.
- **AD:** the gate alone writes `Roles`, so the caller has no entry; the gate-to-worker
  hop's writers are not stated: a conditional row for those writers (a queue writer naming
  `admin`).
- **AE:** the dispatcher refuses every order carrying `certs`, so it alone writes the field.
  No row.
