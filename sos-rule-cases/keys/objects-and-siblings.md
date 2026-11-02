# Key: named objects and sibling sets

For `cases/objects-and-siblings.md`. Keyed to the kit at plugin version 1.1.1. Each entry
gives what the kit directs: the binding, whether a row results, standing or conditional, and
the entry position. A row is "standing" when it holds on the lines given and "conditional"
when it rests on an unconfirmed item (a U id).

- **A:** named object. `p` is bound at `api/files.go:42`; `f` has none at the code (the load
  at `store/files.go:12` is by global id). Standing row, entered from a member of any
  project: it reads any project's file. No file is stated more privileged than another. The
  membership check reads no part of the file's key, so the key record adds no U id.
- **B:** named object. The load binds `f` to `p` at `store/files.go:12`, and `p` is bound at
  `api/files.go:42`; cite both lines. No row.
- **C:** named object. `f` is bound to the requester's right at `:46`. No row.
- **D:** named object. The room is bound by the MUST at `spec.md:102`; the events have none
  stated, a U id. Conditional row: a server admitted to one room fetches events of any room.
- **E:** sibling set: the "should" at `spec.md:200` binds `typing`'s `user_id`; `status`
  (`:220`) is a member with none stated, a U id. `status`'s `user_id` is also a pair (the
  message is authenticated only as the sending server, `:10`). One conditional row, the
  pair's, citing `:200` beside `:220`, the "should" kept; entered from a sending server.
- **F:** `import` is not shown to draw on the capacity export's limit guards, so it is not a
  member; even as a member, its lack would be an availability claim. No row.
- **G:** `/version` carries none of the room's state: not a member. No row.
- **H:** `a` is bound at `:52`; `t` needs none, shown by `docs/transfers.md:3` (the
  project's claim; no code contradicts it). No row.
- **I:** named object and key record. The tenant part is read at `:22` and the load uses the
  whole id at `:24`: bound; cite both lines. No row, no U id.
- **J:** the `/media` review is a B2 control (a person's check): it founds no set and covers
  nothing. `/avatar`'s skip is recorded beside the review's B2 control id for the chain
  hunt. No row.
- **K:** sibling set (secrets for the same account: the password at `api/login.go:21`, the
  reset code at `api/reset.go:24`). The reset lacks the limit and repetition guesses the
  code. Standing row, entered from anyone: it sets a new password on any account.
- **L:** sibling set (rights over the signing keys, `model/keys.go:3`); `/keys/revoke` has
  none at its code. The comment at `api/keys.go:38` claims a check the code at
  `api/keys.go:41` does not make: it covers nothing and goes in the disagreements. Standing
  row, entered from a caller without `admin`.
- **M:** not alike (different rights, a shared identifier form only). No row.
- **N:** sibling set (`from` bound by the value derived from the session at `:12`);
  `/messages/system` has none at `:34` and is also an unbound pair. One standing row, the
  pair's, citing `:12` beside `:34`, entered from the service token's holder.
- **O:** in P2's own run, `i` and `o` have none (`:32` reads only the caller); in P1's own
  run, a deputy row (P1 acts for its user; its own check covers `o` only) with `i` not
  stated (P2 is outside its evidence). At the seam neither side binds `i`: one standing row,
  the deputy's at P1, holding the named-object gap at P2.
- **P:** named object. `doc` has none, but the act serves no data and its rewrite leaves the
  entry as it was: an availability claim. No row.
- **Q:** not alike (the password re-entry guards the email change alone). No row.
- **R:** the "may" founds no set. `pin` names a user under the sending server: a pair whose
  binding is none stated, a U id. Conditional row.
- **S:** the card reader (`:40`) founds a set over routes into the reactor hall, what its
  own line admits to. The tunnel hatch (`:46`, "unlocked") is a member whose check is stated
  absent: standing row, entered from a person not cleared for the hall. The shared
  switchgear room makes no route a member; the turbine-hall guard is a B2 control, recorded
  as such, no row.
- **T:** named object. `o` is bound at `:22`; `r` is not stated (the code that acts on it is
  in `vendor/`, outside the evidence), a U id. Conditional row; `vendor/` listed as a
  delegation boundary.
