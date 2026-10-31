You are a verifier for post-review edits to a finished threat model of Chernobyl Unit 4,
built from IAEA INSAG-7 (1992). The evidence is a document:
`«WORK»/sources/insag-7-paged.txt`, the report's text with a
`=== PDF page N ===` line before each page. Do not edit it, and do not edit either output.

Read first: `«KIT»/reference/writing.md`,
`«KIT»/reference/judging-rules.md`
(the qualifier rule under "Evidence and scope" matters most) and
`«KIT»/reference/general-systems.md`.

The edited documents: `«WORK»/output/chernobyl-threat-model.md`
and `«WORK»/output/chernobyl-threat-model-standalone.md`.
Their versions before the edits, for comparison only:
`«WORK»/scratch/pre-review-chernobyl-threat-model.md` and
`«WORK»/scratch/pre-review-chernobyl-threat-model-standalone.md`.
Run `diff` between each pair to see exactly what changed. The edits touch risk 1 and risk 3
under "Risks, stated first", one sentence of "The shape of it", and, in the deliverable
only, the change note's opening paragraph and its "Post-review changes" entry.

Use no source outside the document: no web, no memory of other accounts. Read nothing else
under `«PARENT»/`.

Check every changed passage:
1. Every quotation is verbatim at its cited lines, and keeps every qualifier in the sentence
   it comes from; a claim carries its source's confidence, never more.
2. Every citation's PDF page matches the nearest `=== PDF page N ===` marker above its first
   line, and the body named (INSAG main text lines 352-1445, Annex I 1448-5043, Annex II
   5046-6535) is right.
3. Every heading claim is supported by its body's lines. "No stated observer" must be
   accurate: no observer of that hazard is stated anywhere in the document.
4. Every id on an "Ids:" line names a row or chain that exists in the document, and each
   chain named belongs to that risk's position. Compare risk 1's chains with each chain's
   own entry points and composition in the Chains section.
5. Nothing the edits removed leaves a claim elsewhere in the documents unsupported, and the
   change note describes the edits accurately.
6. The risk shape: a heading sentence naming the hazard its gaps leave unobserved, two to
   five sentences, the ids on one closing line, a marker after the sentence it qualifies.
   Writing rules: no em dashes, no first person.

Then run `python -I «KIT»/scripts/resolve_citations.py FILE --tree «WORK»/sources --list-bad`
on both documents and report the counts.

Write `«WORK»/scratch/post-review-verify.md` with the file-writing
tool: a log, one line per checked item (verdict confirmed / narrowed / wrong, and for a
narrowing or wrong item the number of its correction); then every correction, numbered, as
a CURRENT/REPLACEMENT block in exactly the form
`«KIT»/scripts/apply_edits.py`
parses (each edit numbered, CURRENT and REPLACEMENT each alone on its line, each text in a
fence, CURRENT verbatim and occurring exactly once in each document it applies to, saying
which document or both); then the counts. Confirm the list with
`python -I .../apply_edits.py EDITS DOC --dry-run` on each document it applies to. No first
person, no em dashes, no design suggestions.
