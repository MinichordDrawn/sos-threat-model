# Writing style

Every deliverable, row and prompt in this kit follows these rules. They keep a long
technical document checkable: every sentence states something a reader can verify.

## Voice

- Professional and direct.
- Short declarative sentences. Say the thing, then stop.
- Contractions are fine.
- Active voice.

## Rules

- No em dashes. Use commas, colons, periods or semicolons.
- No first person in deliverables.
- No capitals for emphasis.
- No filler: "comprehensive", "robust", "seamless", "leverage", "fundamentally",
  "essentially", "basically".
- No rhetorical mirrors ("This is not X. It is Y.").
- No qualifiers: "I think", "it seems", "arguably". State it, or mark it unconfirmed.
- "To", not "in order to".
- No sentence that starts with "This is" or "That is".
- No restating what was just said in other words.
- No history words in a document that describes code as it is: "now", "no longer",
  "used to", "previously", "after the fix", "this pass".
- No design suggestions in an audit. Name the missing structure, not the build.
- No vocabulary from the threat model in commit messages or pull requests for fixes:
  describe the defect and the fix in the project's own terms.

## Citations

Every citation is its own backticked span, one file per span: `path/file.go:12`,
`path/file.go:12-30`, `path/file.go:12, 40-44`, or with a tree prefix
`PFX: path/file.go:12` (a space after the colon). A later `:40` continues the last path
named in the same paragraph or table row. Words go outside the backticks:
`file.go:12` (posture), never `file.go:12 (posture)` inside them. The citation resolver
checks only backticked spans and reports any span that looks like a citation but is not
in one of these forms. A cited path has a slash or a file extension (`./Makefile:9` for an
extensionless file at the root), so code spans such as `localhost:8080` or `postgres:15`
are left alone; a bare `:443` is read as a continuation, so write a port as `host:443` or
in words. Inside a table, escape a pipe in a code span as `\|`, or the row breaks.
