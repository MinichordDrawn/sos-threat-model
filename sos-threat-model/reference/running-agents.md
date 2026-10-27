# Running the passes with agents

Operational lessons from running these passes as separate agents. None of them changes
what the audit finds; each one prevents a lost pass or a wrong file.

## One agent per pass, no shared memory

Each pass is a fresh sub-agent that reads only its listed inputs. That independence is the
point of the verification passes: a verifier that inherited the breadth pass's reasoning
would confirm it. Give every agent its inputs by path and its output by path.

The orchestrator (the session running the process) launches every pass and does no pass
itself. Run it wherever it can launch sub-agents: the top-level session, or a sub-agent
when the tooling lets a sub-agent launch its own. In some agent tools a sub-agent cannot,
so an orchestrator started as one would end up doing every pass in one context, and its
verifiers would be checking their own work. An orchestrator that finds it cannot launch
sub-agents stops and says so.

## Save every prompt before launching it

Write each step's prompt to `scratch/passN-prompt.md` (or `scratch/<step>-prompt.md` for a
step without a number, such as `assembly-prompt.md` or `seam-hunt-<pair>-prompt.md`)
before launching the agent. A machine restart, a closed editor or an interrupted turn
kills a running agent; with the prompt on disk, a pass can be relaunched verbatim, or
resumed from its saved transcript where the tooling allows. Record the run's state (which
passes are done, which output files exist, which models ran each pass, what runs next) in
`scratch/run-state.md` as each pass finishes. It is the one file in `scratch/` the
orchestrator edits by hand.

## Write output in sections

Ask every agent to write its output file in several writes (create the file with the
header and the first section, then append each further section) rather than one large
write. A content classifier can stop a large single write of security analysis partway,
losing the whole pass. Keeping every finding as a code path, its precondition
and its file and line, with no exploitation steps, also keeps the content clearly
defensive.

Write each section with the agent's file-writing tool (to a part file in the workspace's
`scratch/`, then append it and delete the part, or as a direct append where the tool
allows) rather than through a shell heredoc. Security prose is full of quotes, backticks
and dollar signs, and on some shells the heredoc fails on quoting partway through a pass.
Stage part files inside the workspace: a system temporary directory is not always visible
to both the file tool and the shell.

If a verifier finishes its checks but cannot write its file, ask it to report its
corrections in its final message, then assemble the file from the earlier pass and those
corrections by script. Record that the file was assembled that way.

## Split a large sweep

A sweep or review of a large document can split the reading across parallel helpers, one
per section, each told to read only the document and the source trees, when the tooling
lets a sub-agent launch its own. The agent that launched them judges every correction they
return, checks a sample at the line, and writes the one output file.

## Expect early hand-backs

Long reviews and sweeps sometimes hand back before their own helpers finish. Resume them
and ask for the rest; apply any partial edit list first.

## Apply edits by script

Edit lists come in two forms: CURRENT and REPLACEMENT blocks (the reviews, the
reconciliation, the fold, the register, the evidence and the front) and numbered sweep
lines (pass 6). `../scripts/apply_edits.py` applies either, all or nothing: it stops with
nothing changed on any entry it cannot parse and on any old text that does not occur
exactly once. Pass 5's reach-back corrections are prose, carried by the assembly agent.
Then grep for the old strings to confirm none remain. Never retype a carried section by
hand.

## Resolve citations by script

`../scripts/resolve_citations.py` checks every backticked citation in a document against
the trees at the audited commits, prints a count per prefix and lists the bad ones with
`--list-bad`. Run it at every gate; every document ships at zero bad, with any citation
into a dependency that was never opened moved into the prose by name.

## Keep the target's tests away from real data

If a pass, a probe or a fix runs the target's own test suite, check first that it cannot
write outside a temporary directory on the auditor's operating system, and snapshot any
real application folders (with creation times) before every run so any cleanup can remove
exactly what the run created and nothing else.

## Gates between passes

Never launch the next pass until the previous one passes its gate check (the counts and
lists named in the process). A pass that skipped its counts usually skipped work.

## Testing the kit against known answers

When a run doubles as a test (a past bug the passes should find on their own), the answer
often lives in the tree: a changelog, a retraction note in a module file, a security
advisory folder. Tell every pass not to open it, and never ask a pass for a fact that sits
in the same file (a toolchain version, a dependency pin); put that fact in the prompt
instead. If a pass reports opening the file, record the blind check as possibly
compromised.

An instruction alone does not keep an agent away from a file it has its own reason to
open: on one test run, five separate agents read past the permitted lines of a module file
while checking a toolchain version, though every prompt forbade it. For a blind check that
holds, audit a copy of the tree with the answer removed, record exactly what was removed,
and cite the copy's commit as the audited one.
