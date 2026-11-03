# Kit notes

Decisions taken where the kit is unclear, wrong or silent for this system, with the reason.
The kit itself is not edited.

1. **Extraction encoding when more than dashes differ.** `general-systems.md` says to keep
   Latin1 "where the two differ only in how they render dashes". Here the two extractions
   also differ in quotation marks (UTF-8 curly quotes; Latin1 two backticks and two
   apostrophes), an en dash (Latin1 U+00AD, a soft hyphen) and one bullet. Decision: Latin1,
   because it loses no character a claim needs (its non-space count is the higher by exactly
   the 62 em dashes it writes as `--`) and writes no em dash, which the writing rules ban.
   Consequence the kit does not foresee: Latin1's opening double quote is two backticks,
   which open a Markdown code span and break the citation resolver if copied. Every prompt
   tells the pass never to copy the source's quotation marks into Markdown.

2. **"Affected" in an editor's note.** `general-systems.md` ("A document that amends
   itself") fixes what is in force from the amending text's own words where they settle it,
   otherwise from an editor's notes. Most of this document's editor's notes say a clause
   "has been affected by" an amendment, which names no part as superseded. Decision: where
   the amending text's words displace a part, that part is context; where neither the
   amending text nor the editor says which part stands, the clause is treated as in force
   except as the amending text's words reach it, and the extent is recorded as not settled
   by the document. The survey's in-force table holds each case for pass 1 to check.

3. **Run constraint beyond the kit: no names and no history of use.** The brief forbids
   naming any person, party, office holder, court decision, statute or event after
   ratification, and any claim about how a power has been used. The kit has no such rule;
   the editorial bodies of this source name persons and court decisions. Decision: added as
   a binding rule to every prompt, with the instruction that editorial bodies are cited only
   for what they say is in force and no name is repeated from them.

4. **Shipping a public-domain source.** `general-systems.md` ("Copyright") says when the
   source and its extracted text may ship, not whether they must. Decision: neither is
   copied into `output/`; the assembly writes `output/rebuild-source.sh` (not run, since the
   run may not use the web), and both output documents state the address, the pdftotext
   version, the encoding, both checksums and the public-domain basis (17 U.S.C. §105, from
   the brief). Reason: the script keeps every citation checkable without redistributing a
   modified copy, and the kit's rule is satisfied either way.

5. **Unconfirmed items defined only in the chain hunt.** The assembly prompt in
   `templates/prompts/single-package.md` reads the verified file, the chain verification
   and the ring map, not the chain hunt's file. The chain verification confirmed the chain
   hunt's new unconfirmed items (U51 to U62) by id only, so the assembly had no copy of
   their wording and rebuilt them by hand, in places with different substance. Decision: at
   the assembly gate the orchestrator sent the assembly agent back to copy those items'
   wording from the chain hunt's file by script, reading that file for that purpose only,
   keeping pass 5's widenings. Reason: the kit requires carried content to be copied, never
   retyped, and the chain hunt's file is the only place the wording exists.

6. **The copyright rule names a statute the brief forbids naming.** `general-systems.md`
   ("Copyright") has both documents state the brief's public-domain statement "and the law
   that makes it so" (17 U.S.C. §105). The brief forbids naming any statute after
   ratification. The final sweep found the introductions' "no statute ... is named"
   contradicted by the copyright note. Decision (the sweep's, accepted): keep the statute in
   the copyright note, which the kit requires as the legal basis for the evidence, and
   narrow the introductions' claim to "beyond the copyright statute the brief cites below".
   Reason: the statute is about the document's status, not a claim about the system, and
   the kit's copyright rule cannot be met without it.

7. **A sweep correction reaching one document only, outside the standalone-only sections.**
   `single-package.md` Pass 6 step 2 expects every correction that reaches the standalone
   copy only to sit in its introduction, model in brief, Keys, Part E or Part F. Correction
   98 sat in "The present halt paths", a shared section, where the standalone copy had
   replaced the pass names in one paragraph and the deliverable had not. Decision: as step 2
   says, the deliverable's version went to `scratch/final-sweep-fixes.md` with the same
   correction, dry-run and applied to the deliverable alone. Reason: step 2 covers exactly
   this case; the kit's list of standalone-only sections does not foresee a shared section
   whose wording the standalone build changed.

8. **Pass 6 split across helpers.** The standalone copy ran to about 2,400 lines and 1,280
   citations. `running-agents.md` ("Split a large sweep") allows splitting a sweep across
   parallel helpers when the tooling lets a sub-agent launch its own; the pass 6 prompt said
   so. The sweep used eight helpers, judged every correction they returned, sampled at the
   line and wrote the one output file itself. Every other pass was told to work alone.
