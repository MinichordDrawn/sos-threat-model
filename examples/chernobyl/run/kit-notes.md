# Kit notes: chernobyl

Decisions taken where the kit was unclear, wrong or missing for this run, with the reason.
The kit folder was not edited.

1. **Encoding comparison needs a scratch extraction.** `general-systems.md` asks to compare
   `--enc UTF-8` and `--enc Latin1` first, but `page_text.py` refuses to overwrite its
   output and has no comparison mode. Decision: ran pdftotext directly in both encodings
   into a temporary folder under `scratch/`, compared the non-ASCII characters, deleted
   the folder, then ran `page_text.py` once with the chosen encoding. Both decode clean;
   `UTF-8` renders the source's dashes as em dashes, `Latin1` as `--`. `Latin1` kept, since
   the writing rules forbid em dashes inside a quotation, which is the tie-break the kit
   names.

2. **The survey records orchestrator observations.** The kit's survey list has no slot
   for disagreements the orchestrator notices while mapping the document. Decision: a
   short "Noticed while surveying, unverified" section in the survey, framed as claims for
   pass 1 to check at the lines and never as findings. Reason: the kit treats every
   survey claim as a claim pass 1 checks, and dropping them would lose evidence pointers.

3. **The one-package ranking rule in a single physical plant.** `judging-rules.md` ranks
   one package by what a position gains "times how many installations or users it
   reaches in one act". A single historical plant has one installation and no users.
   Decision: pass 2 states the rule once with "installations or users" read as the reach
   toward the public-safety floor (how much of the core, the plant and the public one act
   or condition reaches), with nothing positioned to notice, ties broken by the position
   that needs no privileged act. Reason: the public-safety floor stands in for the
   customer-data floor everywhere else in the kit.

4. **The sweep and `general-systems.md`.** `common.md` says every step of a
   document-evidenced run reads `general-systems.md` after the four reference files, but
   the final sweep's block starts with **Reading:** and replaces those files so that it
   reads as an outside reader. Decision: the sweep does not read `general-systems.md`; its
   prompt carries the document-evidence changes that file prescribes (work only from the
   document, no web, PDF-page citation form, "not settled by the document", claims
   resting on a document the source quotes but does not contain). Reason: the sweep's
   outside-reader stance is the kit's stated purpose for its reading list, and the
   standalone's Keys state the evidence rules the reader needs.

5. **`rebuild-source.sh` without the web.** `general-systems.md` asks the assembly to write
   `output/rebuild-source.sh`, which downloads the source. This run forbids the web and
   any new download. Decision: the assembly writes the script and does not run it; the
   checksums in it are those recorded in the survey. Reason: writing the script needs no
   download, and the kit requires it so every citation stays checkable.

6. **The sweep's prompt and the survey.** The common block points every pass at the survey,
   a workspace file. Decision: the sweep's prompt drops that pointer and the four reference
   files, keeps the document-evidence rules inline, and forbids opening the scratch files
   and the deliverable. It allows the sweep to split its reading across helpers, as
   `running-agents.md` permits, with the sweep judging every correction. Reason: the sweep
   reads as an outside reader, and the survey is not part of what the reader receives.

7. **"Grep for the corrected strings" and additions.** `single-package.md` asks the
   orchestrator to grep for the corrected strings after the sweep to confirm none remain.
   A correction that only appends to its old phrase (here 12 and 34) leaves the old phrase
   in place by construction. Decision: such hits were read and accepted as additions, not
   misses. Reason: the check is meant to catch edits that did not land, which an addition
   cannot show by absence.

8. **Rows filed by effect keep their letter id.** The judging rules file a row by its
   effect and the common block keeps every id. Pass 3 refiled S1 under D by its effect
   with its id kept, so counts by section (S 3, D 20) and counts by id prefix (S 4, D 15)
   differ. Decision: the documents count rows by the section they sit in and say so. The
   kit names neither convention.

9. **No PDF rendering.** `general-systems.md` lets a pass view a PDF page to settle a
   garbled table value. Pass 2 found no renderer in this environment (pdftoppm missing),
   and no pass viewed a page. Decision: every table-only value stays unconfirmed, as the
   kit's first rule for tables says. Reason: the kit names this rule as the one to rely on.

10. **Orchestrator slip, recorded.** The orchestrator's verbatim paste of the ring map's
    unconfirmed list into pass 2's prompt cut U21 after "and". Pass 2 read the full item
    from the ring map and recorded that. No kit change is implied; a paste by line range
    should end at the next item's start.
