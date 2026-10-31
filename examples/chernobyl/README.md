# SOS Threat Model: Chernobyl Unit 4, from INSAG-7

A complete run of the SOS threat model on a system that is not software: Chernobyl Unit 4
as it stood on 25-26 April 1986, modeled only from INSAG-7 (1992), the report in
which the IAEA's International Nuclear Safety Advisory Group updated its conclusions on
the accident's causes. It is here to show what the kit produces on a document-evidenced system,
and to let anyone check that output against the source line by line.

**Agents running the kit: do not read this folder during a run.** A finished example
steers what a pass looks for and how it phrases what it finds. It is for people, and for
reviewing the kit, not a template.

## What is here

```
chernobyl-threat-model.md              the deliverable, with the change note
chernobyl-threat-model-standalone.md   the self-contained copy (Parts A to F, the Keys)
rebuild-source.sh                      downloads INSAG-7 and rebuilds the cited text
run/                                   the orchestrator's brief, the survey, every pass
                                       prompt, the run state, the orchestrator's notes on
                                       the kit, and the post-review notes and verification
```

The pass outputs (ring map, evaluation, verification, chains) are not included: they hold
far more quotation than the final documents, and everything in them that survived
verification is in the deliverable. Local paths in `run/` are replaced by
placeholders («KIT», «WORK», «PARENT», «PDFTOTEXT», «AGENT-SETTINGS»).

## Checking the citations

Every claim cites the report's text by line, as `insag-7-paged.txt:582-588` (p.16, §2.7),
with the PDF page beside it. The text is not shipped (see Copyright); rebuild it:

```
sh rebuild-source.sh sources
python ../../sos-threat-model/scripts/resolve_citations.py chernobyl-threat-model.md --tree sources --list-bad
```

The script downloads the PDF from the IAEA, checks its SHA-256
(`75627db8...21152455`), extracts it with xpdf's `pdftotext` 4.00 (`-layout -enc Latin1`)
and checks the text's SHA-256 (`a83c26e9...c321e32`), stopping on any mismatch. Another
pdftotext version can change the layout and every line number, so the version is checked
too. Setting `PAGE_TEXT` to the kit's `scripts/page_text.py` extracts with it instead; both
paths give the same bytes. Both documents resolve at 0 bad citations (1,430 and 1,356).

## The run

- **Kit and models.** One orchestrator given only the skill and the PDF. Breadth passes
  (ring map, evaluation, chain hunt) on Claude Fable; verification passes, assembly and the
  final sweep on Claude Opus. No web, no other account of the accident: a fact the report
  does not state is unconfirmed.
- **The bar.** The ring is machine-only. Operators, managers, designers and regulators are
  B2 positions; no human check discharges a property. Gaps are named even where no
  technology of 1986 could have closed them. No fixes are proposed.
- **Gates.** Ring map 674 citations; evaluation 54 rows; verification of 246 items (171
  confirmed, 64 corrected, 11 dropped); 11 chains, every one corrected and none dropped by
  the chain verifier; final sweep of 668 items (605 confirmed, 57 narrowed, 6 wrong), all 69
  corrections applied. `run/run-state.md` has every count and the model behind each step.

## Results

**Shape.** No ring at any layer and no coordinator (0 of 14 candidates). 21 observers form
isolated spokes into one shared actuator, the 211 control and protection rods, with
recorders, a control board and a printout as passive hubs, the
board read by one person. Execution checked no observer, so the default was running.
Every reactor halt ended in rods whose first motion from the upper stops inserted positive
reactivity locally, and the margin that governed the halt's worth (the operating reactivity
margin, ORM) had no device in the design to measure it in terms of effective manual
control rods, only a hand summation or a plant computer run of a few minutes, and nothing
that acted at its limit.

**Counts.** 59 STRIDE rows (S 3, T 17, R 11, I 0, D 20, E 8); 11 chains (7 source-supported,
2 conditional on an unconfirmed item, 2 design assumptions) of 20 candidates; 10 halt
paths, none reaching a second observer; 19 continue-on-fault paths; 15 prescribed
responses tested as actuators; a scorecard of 52 gaps, 3 satisfied and 1 unsettled in 56
cells; 27 disagreements within and between the report's bodies and the documents they
quote, recorded and not resolved.

**The risks, in the model's order.**

1. The design of every RBMK unit: the halt's own positive reactivity and a void
   coefficient that was positive at the time of the accident, with no stated observer, and
   an ORM with no observer against its limit.
2. The low-ORM, low-power state, in which any positive reactivity or any trip could reach
   the public at one plant. That it needs no person's act rests only on the Commission's
   hypothetical, and is marked conditional.
3. The console: one hand on the halt button, the rod positions and the set points, with
   no device in the design to measure the ORM in terms of effective manual control rods.
4. Protections removable by jumper wires, keys and straps, which the procedures permitted
   under some circumstances, with no observer of a protection's absence and, for the drum
   level set point, no note in the operating logs.
5. One authorization each to run below 26 rods and to switch off the emergency core
   cooling, with nothing checking it.
6. A test that brought the reactor to a state no procedure specified and no independent
   body examined.
7. Feedwater, drum level and turbines moved by hand with no observer of the states they set.
8. The one computed figure for the halt's worth, found unreliable, not computed at
   01:22:30, and recorded only on printouts from a computer about 50 m from the console.
9. A record of the last seconds that is a reconstruction.

## How it compares with INSAG-7

The model was told nothing about the accident except the report, so every fact it uses is
INSAG-7's. What differs is the frame and the emphasis.

**Where they agree.** INSAG-7's §6 names three main factors (`insag-7-paged.txt:1276-1280`):
the reactor's physical characteristics ("most importantly"), the design of the control
elements, and a state "not specified by procedures or investigated by an independent
safety body". These are the model's risks 1 and 6 and chains X1, X2 and X6. INSAG
reports the join chain X2 models too: "Detailed analysis indicated" that the positive
scram's reactivity, added to that of the voids, sufficed for a severe transient
(`insag-7-paged.txt:842-845`). INSAG's broader
list (`insag-7-paged.txt:1342-1362`) maps the same way: the standards the plant fell short
of and the approvals it got anyway are the paragraph on the system that produced the
system; inadequate safety analysis is "no safety analysis of the void coefficient";
procedures not founded on analysis are the prescribed responses tested as actuators;
unshared safety information is the Leningrad 1975 and Ignalina 1983 rows. The measures
INSAG was told had been developed and implemented afterwards
(`insag-7-paged.txt:1379-1392`, the Appendix) aimed at a lower void coefficient, a faster
scram, a numeric ORM display in the control room, and precluding a bypass of the emergency
protection at power through an operating limit and a two-key system. Each answers a gap the model names.

**Where they differ.**

- **Structure, not culture.** INSAG says the accident "can be said to have flowed from
  deficient safety culture" (`insag-7-paged.txt:1304`). The model names missing structure instead:
  no ring, one actuator, a margin nothing acted on, protections a person could remove,
  and a design that handed protection functions to the personnel.
- **The operators.** INSAG weighs their understanding and their respect for procedures.
  The model places them at B2 and asks why one person's act could reach the core at all;
  where they did what a procedure permitted, the gap sits with the procedure.
- **Production pressure** enters INSAG's broader list as a regulatory regime "unable to
  counter pressures for production" (`insag-7-paged.txt:1359-1360`). The model lists the
  document's instances of it (the grid controller's request to postpone, the incentive
  system, the choice to keep the unit in operation) as availability claims and does not
  rank them.
- **Confidence.** The model keeps every hedge the report uses ("probably", "may well",
  "it would appear") and records 27 disagreements (DG1 to DG27) between INSAG's main text,
  Annex I (the USSR State Committee's commission), Annex II (USSR experts) and the
  documents they quote, some within one body, rather than choosing between them.

**What the model brings forward that INSAG's main text does not.** All of it is in the
report, mostly in Annex I; none of it is new fact.

- The plant's own procedures permitted conditions similar to those of 26 April, which, by
  the Commission's note, "might have occurred without any intervention on the part of the
  personnel": after an automatic power reduction (EPS-3) from rated power at an ORM of 26
  rods, the margin could have fallen below 15 rods about an hour later, and any further
  shutdown "could have led to a similar repetition" (chain X8, conditional on that
  hypothetical). EPS-3 does not appear in INSAG's main text.
- A protection setting could go unrecorded: of the drum level set point the personnel did
  not switch to -600 mm, "There are no notes on this in the operating logs" (risks 4 and
  7). The main text reports the unreset level, not the missing note.
- The one machine that computed the margin recorded its results "only on printouts" and
  ran no calculation at 01:22:30 (risk 8); the main text places it about 50 m from the
  console and the ORM outside the protection system (`insag-7-paged.txt:552-553`,
  `:901-902`).
- None of Annex II's three models "reproduces the reactor runaway when", three seconds
  after EPS-5, the power and rate signals are generated (`insag-7-paged.txt:6005-6008`);
  INSAG's main text, which calls the rods' insertion "probably a decisive contributory
  factor", does not discuss these models (row S1).
- Every halt ended in the same rods, and a rupture of more than one channel could lift the
  cover plate and fail "the whole RCPS rod insertion system": the halt and the last
  barrier could fail together (risk 2).
- One person's authorization allowed running below 26 rods, and whether it was sought or
  given on 25 April is not stated (risk 5, U25); the main text reports the Chief
  Engineer's approval for blocking the ECCS (`insag-7-paged.txt:734-736`, `:1068-1071`),
  not this one.

## Limits

- **Not blind.** The accident is famous, and the models that ran the passes already knew
  its outcome; no instruction removes that. The run shows the model can represent a known
  failure in its own terms. Whether it can find one is a question for a less famous,
  well-investigated case.
- **One source.** Every claim rests on INSAG-7 and the documents it quotes; a claim that
  rests on a document it quotes but does not contain is marked so. 30 questions stay
  unsettled by the document, each with what would settle it.
- **No page images.** No PDF page was rendered during the run. A value that appears only
  in a table, or an OCR'd figure, stays unconfirmed unless another body or the running
  text states it.

## Changes after the run

The run passed every gate on its own. A review of the risk list then found that the void
coefficient, one of the physical characteristics INSAG names "Most importantly" among the
accident's factors (`insag-7-paged.txt:1279-1280`), sat in rows and in chain X2 but in no risk
heading. Risk 1, risk 3 and one sentence of the shape were edited by hand in both
documents. A separate Opus verifier checked every changed passage at its lines: of 32
items, 23 confirmed, 6 narrowed and 3 wrong, all three the editor's (a line range, a
narrowed chain list, and the change note repeating both). Its 11 corrections were applied by
script. The deliverable's change note lists the changes to risks 1 and 3 and the shape under
"Post-review changes";
`run/post-review-notes.md` and `run/post-review-verify.md` have the detail.

## How the kit got here

The run is the third on this report. The first found 33 places where the kit's
instructions did not fit a document-evidenced system, and they were folded into
`reference/general-systems.md` and the prompts. The second, with a smaller model on the
breadth passes, was stopped after its second pass: with the reactor core correctly marked
as an observed component rather than an observer, nothing asked what watched its hazards,
and the void coefficient dropped out. The kit's hazards table (`reference/method.md`, Step
1.5) came from that. This run is the one shipped.

## Copyright

INSAG-7 is © IAEA 1992; the IAEA states that permission to reproduce or translate the
information in it may be obtained by writing to the IAEA. The PDF and its text are not
included. The documents quote it for review, in short quotations of at most 44 words,
about ten words on average, that together cover under a tenth of the report's text.
Quotations from INSAG-7 are © IAEA 1992, cited for review.
