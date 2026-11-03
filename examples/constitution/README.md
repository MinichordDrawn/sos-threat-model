# SOS Threat Model: the United States Constitution, as amended

A complete run of the SOS threat model on a system made of people and institutions: the
United States federal government as the Constitution and its twenty-seven amendments
establish it, modeled only from the text (House Document 110-50, U.S. Government Printing
Office, 2007). It is here to show what the kit produces on an institution, and to let anyone
check that output against the text line by line.

**Agents running the kit: do not read this folder during a run.** A finished example
steers what a pass looks for and how it phrases what it finds. It is for people, and for
reviewing the kit, not a template.

## What is here

```
constitution-threat-model.md              the deliverable, with the change note
constitution-threat-model-standalone.md   the self-contained copy (Parts A to F, the Keys)
sources/constitution-paged.txt            the page-marked text every citation points into
rebuild-source.sh                         downloads the PDF and rebuilds that text
run/                                      the orchestrator's brief, the survey, every pass
                                          prompt, the run state, the orchestrator's notes on
                                          the kit, and the post-review notes, rationale
                                          and verification
```

The pass outputs (ring map, evaluation, verification, chains) are not included; everything
in them that survived verification is in the deliverable. Local paths in `run/` are
replaced by placeholders («KIT», «WORK», «PARENT», «PDFTOTEXT», «AGENT-SETTINGS»).

## Checking the citations

Every claim cites the text by line, as `constitution-paged.txt:489-491` (p.11, Art. I §9
cl. 2), with the PDF page beside it. The text ships here, so a check is one command:

```
python ../../sos-threat-model/scripts/resolve_citations.py constitution-threat-model.md --tree sources --list-bad
```

Both documents resolve at 0 bad citations (1,413 and 1,305). To rebuild the text from the
original instead, make an empty folder here and, inside it, run `sh ../rebuild-source.sh
../../../sos-threat-model/scripts/page_text.py` (pdftotext on the path, or its path as a
second argument): it downloads the PDF from govinfo.gov, checks its SHA-256
(`7f29c4a7...4402e57`), extracts it with xpdf's `pdftotext` 4.00 (`-layout -enc Latin1`) and
checks the text's SHA-256 (`82a4e5f1...b31f0e`), stopping on any mismatch. Another pdftotext
version can change the layout and every line number, so the version is checked too.

## The run

- **Kit and models.** One orchestrator given only the skill and the PDF. Breadth passes
  (ring map, evaluation, chain hunt) on Claude Fable; verification passes, assembly and the
  final sweep on Claude Opus. No web and no other account of the system: a fact the text
  does not state is unconfirmed.
- **The bar.** The ring is machine-only. Every person and body (each House, the President,
  the courts, electors, State legislatures) is a B2 position, and no human check
  discharges a property. The text sets up no machine, so the candidate observers are the
  mechanisms it makes take effect by themselves, with no person deciding, carrying out or
  recognising any step. Gaps are named; no fixes are proposed.
- **The brief's own rule.** The run judges the structure the text establishes and nothing
  else: it names no person, party, court decision, statute or event after ratification
  (beyond the copyright statute the brief cites for the source's status), and makes no claim
  about how any power has been used. What the text leaves open is marked
  "not settled by the document".
- **Gates.** Survey 161 citations; ring map 567; evaluation 69 rows; verification of 419
  items (370 confirmed, 46 corrected, 3 dropped) with 16 new; chain hunt 5 chains of 27
  candidates; chain verification 6 chains (X4 dropped, X6 and X7 added); final sweep of 834
  items (643 confirmed, 162 narrowed, 25 wrong, 4 not checkable), all 251 corrections
  applied. `run/run-state.md` has every count and the model behind each step.

## Results

**Shape.** No ring at any layer and no coordinator (0 of 8 candidates). Twelve mechanisms
take effect by the text's own terms: an unreturned bill becomes law, fixed dates end every
elected term, a death or an inability moves the executive power, time windows return it, an
expiry ends a recess commission or a temporary appointment, an election releases a pay law.
Each is an isolated spoke; none reads or reports to another, and for every one the text
names no one who recognises the event that sets it off. Everything else that checks power
is a person's act: a vote, a declaration, a count, a trial or a judgment.

**Counts.** 75 STRIDE rows (S 6, T 7, R 3, I 1, D 10, E 48), 19 standing on the lines alone
and the rest conditional on an unconfirmed item; 5 chains of 29 candidates, all conditional
on an unconfirmed item; 7 halt paths, none reaching a second mechanism; 9 continue-on-fault
paths; a scorecard of 46 gaps and 2 satisfied in 48 cells over 6 observer groups; 80
questions the text does not settle: 67 unconfirmed items, each with what would settle it, 4
other items kept open and 9 open questions raised by the chain verification.

**The risks, in the model's order.**

1. The office of President passes on a removal, death or resignation that no stated
   position recognises.
2. The executive power moves to an Acting President on written declarations whose origin
   and majority no stated position checks.
3. The electoral votes "shall then be counted" with no counter named and no stated source
   for "the whole number of Electors appointed".
4. Amendments become valid on ratifications no named position counts, and a State's
   consent to losing equal suffrage in the Senate has no stated reader.
5. A presidential inability no position is named to recognise, and acting offices held past
   the ends the text fixes.
6. A bill becomes law or not on a record of its return, a presenter's timing and an
   adjournment no stated position checks.
7. The privilege of the writ suspended by a body no line names, and bars on laws read only
   by a court in a case.
8. Money drawn from the Treasury with no stated reader of the draw.
9. "The supreme Law of the Land" binding every judge on texts with no stated custodian.
10. Offices filled or entered past their grant: recess commissions, officers vested as
    "inferior", commissions and oaths no stated position reads.
11. The representation of the States: an enumeration, a reduction, a writ of election and a
    temporary appointment no stated position checks.
12. Secret proceedings, votes with no names, acts by less than a quorum, and bounds on
    pardons, disabilities and judgments no stated check reads.

## How it compares with the literature

The Constitution is among the most analysed texts there is, so this is a validation case,
not a search for new problems. Research agents scored gaps found in the text against case
law, statutes, congressional practice, executive-branch legal opinions and scholarship, and
this run's findings took the score of a scored gap on the same component citing the same or
overlapping lines (93 findings: 75 rows, 6 chains and 12 observers, matched before the
post-review, while X6 still stood; 8 matched none).

- **Answered by law or practice, still gaps in the model: 62** (10 of them only on a
  neighbouring point). Statutes, rules, practice and decisions outside the text answer what
  most of these gaps mean or who acts, but close none of them in the model's terms: the
  Electoral Count Reform Act of 2022 for the count, the Presidential Succession Act (3
  U.S.C. §19) for succession, 3 U.S.C. §20 for resignation, 1 U.S.C. §106b for certifying
  ratifications, the enrolled-bill rule for what a bill says, and decisions such as *Powell
  v. McCormack* (1969) and *NLRB v. Noel Canning* (2014).
- **What that settlement adds, in the model's terms.** For 38 of the 62 it adds a people's
  procedure: a deadline or a person's or body's check, which leaves the row standing. For
  24 it settles only what the text means. For none does it add a machine check, a mechanism
  that acts with no person in any step. Two statutes are candidates for mechanisms of the
  kind the model counts as observers: the acting officer's tenure under 3 U.S.C. §19 and
  automatic apportionment under 2 U.S.C. §2a; the notes do not say whether a person's step
  comes between either one's condition and its effect.
- **Known and still open: 19,** 15 of them on presidential inability and succession (Art.
  II's inability clause and the 20th, 22nd and 25th Amendments); the others are the 14th
  Amendment's reduction of representation, the equal-suffrage proviso, a State's war when
  invaded or in imminent danger, and the non-execution of the laws.
- **Not commonly discussed: 4.** Checking that a 25th Amendment §3 declaration really comes
  from the President (S1); a writ of election issued for a seat that is not vacant (T3);
  what follows if Congress does not assemble (D1); and majorities using their judgment of
  members' qualifications to reach the two-thirds votes the text requires (chain X1). The
  literature found little on the three rows, and on X1 only its links, each known, not the
  combination.
- **Not scored: 8.** Five findings fell outside what the research covered: an office holder
  past the end of the term (E3), the President's and judges' compensation (E6), the oath and
  its record (E44), a new State formed without the consent the text requires (M9) and the
  fixed end of every term as an observer (O2). Three chains were scored only through their
  links, never as combinations: X5 (one of its two links), X6 (since rejected) and X7.
- **One reading the case law settles otherwise.** Row E46 reads the members' privilege from
  arrest at its words, "except Treason, Felony and Breach of the Peace"; since *Williamson
  v. United States* (1908) the privilege has been read to cover civil arrests only. The text
  alone does not settle it, and the run was told to use the text alone, so the row stands as
  the run wrote it.

## Limits

- **Not blind.** The text and its history are famous, and the models that ran the passes
  already knew both; no instruction removes that. The run shows the model can represent a
  well-known institution in its own terms.
- **The text alone.** The statutes, chamber rules and case law that operate the
  institutions are outside the evidence. Where the text leaves something to be made "by
  Law" the run marks it not settled by the document, and a chain that needs such a law is a
  design assumption. The literature section above is where that outside settlement appears.
- **No names.** By the brief's rule the documents name no person, party, decision, statute
  or later event, beyond the copyright statute; this README does, to place the findings.

## Changes after the run

The run passed every gate on its own. A review then found two readings the cited lines do
not support. The documents said suspending the privilege of the writ of habeas corpus
removes the check on detention, and built chain X6 on it; the text
(`constitution-paged.txt:489-491`) states only when the privilege may be suspended. And rows
E13 and E14 said a State judges its own invasion, danger or necessity; the lines
(`:529-531`, `:537-541`) name no judge. Both were corrected by script in both documents: X6,
restated without its failed premise, moved to the rejected list, X7 narrowed, and the rows
now say who judges is not stated. A separate Opus verifier checked every changed passage at
its lines: of 54 edits, 52 confirmed, 1 narrowed and 1 wrong, and its 2 corrections were
applied. The deliverable's change note lists every edit under "Post-review changes";
`run/post-review-notes.md`, `run/post-review-rationale.md` and `run/post-review-verify.md`
have the detail.

## How the kit got here

The first run on this text, on the kit as it then stood, found no observers at all: every
check the text sets up is a person's, and nothing in the kit said what could stand for a
machine in a system with none. Its orchestrator recorded seven places where the kit did not
fit a legal text, and they were folded into `reference/general-systems.md` and the prompts:
the mechanisms a text makes take effect by themselves as candidate observers; reading a text
that amends itself; editorial bodies kept out of the claims; laws the text leaves to be
made; and a source in the public domain by law. The same update added "The eight properties
for an institution", which reads each property on an institution's substrate. This run used
that kit, and its own eight notes were folded in after it. This run is the one shipped.

## Public domain

House Document 110-50 is a work of the United States federal government and is not subject
to copyright in the United States (17 U.S.C. §105). `sources/constitution-paged.txt` is a
modified copy of it: the text extracted with `pdftotext`, with a page marker before each
page. The run shipped neither the PDF nor the text, and both documents say so
(`run/kit-notes.md`, note 4, gives the reason); this example adds the text so the citations
can be checked without a download. The PDF is not included; `rebuild-source.sh` downloads
it from the Government Publishing Office.
