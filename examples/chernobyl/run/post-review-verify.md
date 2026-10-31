# Post-review verification

Scope: the passages that differ between `scratch/pre-review-chernobyl-threat-model.md` and
`output/chernobyl-threat-model.md`, and between the two standalone copies. The edits in the
two documents are identical in risk 1, risk 3 and the shape of it; the change note's
opening paragraph and its "Post-review changes" entry are in the deliverable only. Page
markers checked against `sources/insag-7-paged.txt`; bodies checked against INSAG main
text 352-1445, Annex I 1448-5043, Annex II 5046-6535.

## Log

Risk 1 (both documents)

1. Heading, "three hazards with no stated observer" - narrowed (1, 2). The halt's positive
   reactivity: no observer stated anywhere; the hazards table gives "none" for OC2 and OC14,
   and the source reports only the people's experimental discovery, `insag-7-paged.txt:2187-2190`
   (p.53). The void coefficient: no observer stated; it was "determined experimentally" by
   people, `insag-7-paged.txt:1799-1801` (p.46), a B2 check, and the hazards table gives
   "none" for OC1 coefficients. The ORM: an observer is stated. INSAG: "the computer SKALA,
   which was used to calculate the ORM", `insag-7-paged.txt:787-788` (p.21); Annex I: the
   operator could "instruct the plant computer to make the calculation",
   `insag-7-paged.txt:3654-3655` (p.82); the document's own inventory holds O19 "SKALA with
   PRIZMA (ORM)" and X1's title calls it "the one computed observer of the halt's worth".
   What is absent is an observer against the limit: "no provisions for the ORM to be treated
   as a parameter which would trigger the alarm system or the EPS when it reached the limit
   value", `insag-7-paged.txt:1923-1925` (p.48), matching the hazards table's "Observer
   against known-good: none" for OC3.
2. Heading, "every RBMK unit" and "both positive" at the time of the accident - confirmed.
   `insag-7-paged.txt:472-473` (p.14, "all RBMK reactors"), `:439-441` (p.13, "RBMK type
   reactors"), `:455-456` (p.13).
3. "Triggering of the EPS in this case may lead to the introduction of positive
   reactivity", `insag-7-paged.txt:2204-2205` (p.54, quoted [24]) - confirmed; verbatim,
   "may" kept, p.54 (marker 2194).
4. INSAG on the coefficients, `insag-7-paged.txt:452-456` (p.13) - confirmed; three
   quotations verbatim, marker 418, main text; the source's "although ... remained
   negative" contrast is carried by "while".
5. "There is no safety analysis of the void coefficient ...", `insag-7-paged.txt:1866-1867`
   (p.47, Annex I) - confirmed; marker 1848, Annex I.
6. "made no provisions for the ORM ...", `insag-7-paged.txt:1923-1925` (p.48, Annex I) -
   confirmed; verbatim, marker 1899, Annex I. Correction 2 extends the quotation to the
   sentence's limit clause as the body support for correction 1.
7. "before the accident", "discovered experimentally" in November/December 1983,
   `insag-7-paged.txt:2187-2190` (p.53) - confirmed; verbatim, marker 2141, no body named.
8. "the appropriate changes were not made to the Operating Procedures before 1986",
   `insag-7-paged.txt:4138-4139` (p.92) - wrong (3). The quotation runs from line 4139
   ("the appropriate changes were not made to the Operating") to line 4140 ("Procedures
   before 1986"); line 4138 holds none of it. Page 92 is right (marker 4137). The shortened
   sentence drops no qualifier.
9. DG9 marker after the sentence - confirmed; DG9 is the 1983 against 1984 discovery year,
   and the marker closes the sentence holding the 1983 claim.
10. Annex I on the initiating event, `insag-7-paged.txt:3444-3447` (p.78) - confirmed;
    verbatim with its conditions, marker 3443, Annex I. The Note after it qualifies the
    subsequent scenario ("no longer based on calculations"), not this sentence.
11. INSAG, "was probably a decisive contributory factor", `insag-7-paged.txt:1293-1297`
    (p.33) - confirmed; "probably" kept, main text.
12. Removal of the Technical Safety Report sentence - confirmed; the impact order's rank 1
    carries `insag-7-paged.txt:1737-1759` (p.44-45) with R6 and E5, and the system that
    produced the system carries `:1737-1741` and `:1754-1759`.
13. Removal of "and no explanations were given to the personnel ..." - confirmed; R7 cites
    `insag-7-paged.txt:4138-4141` (p.92), and rank 1 carries R7 and R8.
14. Row ids S1, D7, T2, T10, T16, T18, E4, E5, R6, R7, R8, R9, M2, M3, M5, M9 - confirmed;
    each row exists in both documents, and M2, M3, M5 and M9 sit at rank 1 by the impact
    order's own statement.
15. Chain ids X1, X2, X3, X7, X11 - wrong (4). Each named chain has position (5) among its
    required entries, but so do the six left out: X4 "Required, (6) and (5)", X5 "Required,
    (5) by design", X6 "Required, (9) and (5)", X8 "Required, (5)", X9 "Required, (5)", X10
    "Required, (5)" and "(5) and (12)". The impact order's placement rule in both documents
    states "Every chain needs the design position (5), so all eleven sit at rank 1", and
    risk 1 is rank 1's position. The edit leaves that statement contradicted.
16. Shape and writing - confirmed; heading and four body sentences, the ids on one closing
    line, no em dash, no first person.

Risk 3 (both documents)

17. Heading, "with no device in the design to measure the ORM those acts governed" -
    narrowed (5, 6). Annex I's finding is limited to a device to measure the ORM "in terms
    of effective manual control rods", and its next sentence gives the plant computer's
    calculation, `insag-7-paged.txt:3650-3655` (p.82). The heading drops both; the impact
    order's rank 3, as the final sweep narrowed it, carries both.
18. "it proved necessary for some of the ORM rods to be withdrawn",
    `insag-7-paged.txt:3230-3232` (p.73, Annex I) - confirmed; verbatim, marker 3184.
19. "probably reduced the set points", "by manipulating the set points",
    `insag-7-paged.txt:3732-3738` (p.83) - confirmed; the presumption and "probably" kept,
    marker 3692.
20. INSAG, "it is likely that the operator did not know the value of the ORM during the
    critical part of the test", `insag-7-paged.txt:789-790` (p.21) - confirmed; "likely"
    kept, main text.
21. "The Commission was unable to establish why the button was pressed",
    `insag-7-paged.txt:3360` (p.76) - confirmed.
22. Annex I, "no provision in the design ... in terms of effective manual control rods",
    `insag-7-paged.txt:3650-3651` (p.82) - confirmed; verbatim, marker 3643, Annex I.
23. Removal of INSAG's conditional on the control room - confirmed; rank 3 keeps it at
    `insag-7-paged.txt:998-1000` (p.27).
24. Ids and shape - confirmed; ids unchanged and existing, heading and four body
    sentences.

The shape of it (both documents)

25. "void and power coefficients with no safety analysis of the void coefficient" -
    confirmed; `insag-7-paged.txt:452-456` (p.13), `:1866-1867` (p.47).
26. "an unobserved ORM", on the changed line - narrowed (7); the same O19 point as item 1.

Change note (deliverable only)

27. Opening paragraph, "then the final sweep's corrections; then the post-review
    changes" - confirmed; the final sweep's list and the post-review entry follow in that
    order.
28. "Each was then checked at its lines by a separate verification (listed below)" -
    narrowed (8); nothing is listed below the entry.
29. "applied to both documents in place without a mark" - confirmed by the two diffs.
30. Risk 1 entry - wrong (9); it gives the Operating Procedures quotation as `4138-4139`
    (item 8) and calls X1, X2, X3, X7 and X11 "the chains of the design position" (item
    15), and its heading description follows the heading item 1 narrows.
31. Risk 3 entry - narrowed (10); follows corrections 5 and 6.
32. The shape of it entry - narrowed (11); follows correction 7.

Citations: every changed citation's PDF page matches the nearest marker above its first
line; the one wrong citation is a line range (item 8).

## Corrections

1. Risk 1 heading. Applies to both documents.

CURRENT:
```
1. **The design of every RBMK unit left three hazards with no stated observer: the halt's
   own "introduction of positive reactivity", a void coefficient that varied with the core
   and the regime and, with the power coefficient, was "both positive" at the time of the
   accident, and the ORM that governed the halt's worth.** The rod design with its
```
REPLACEMENT:
```
1. **The design of every RBMK unit left two hazards with no stated observer, the halt's
   own "introduction of positive reactivity" and a void coefficient that varied with the
   core and the regime and, with the power coefficient, was "both positive" at the time of
   the accident, and left the ORM that governed the halt's worth with no observer against
   its limit.** The rod design with its
```

2. Risk 1 body, the quotation behind the ORM half of the heading. Applies to both
   documents.

CURRENT:
```
   ORM to be treated as a parameter which would trigger the alarm system or the EPS",
   `insag-7-paged.txt:1923-1925` (p.48, Annex I). The rod effect was known to the Chief
```
REPLACEMENT:
```
   ORM to be treated as a parameter which would trigger the alarm system or the EPS when
   it reached the limit value", `insag-7-paged.txt:1923-1925` (p.48, Annex I). The rod
   effect was known to the Chief
```

3. Risk 1 body, the Operating Procedures citation. Applies to both documents.

CURRENT:
```
`insag-7-paged.txt:4138-4139` (p.92) (DG9)
```
REPLACEMENT:
```
`insag-7-paged.txt:4139-4140` (p.92) (DG9)
```

4. Risk 1 ids. Applies to both documents.

CURRENT:
```
   Ids: S1, D7, T2, T10, T16, T18, E4, E5, R6, R7, R8, R9, M2, M3, M5, M9; X1, X2, X3, X7,
   X11.
```
REPLACEMENT:
```
   Ids: S1, D7, T2, T10, T16, T18, E4, E5, R6, R7, R8, R9, M2, M3, M5, M9; X1 to X11.
```

5. Risk 3 heading. Applies to both documents.

CURRENT:
```
   regulators' set points, with no device in the design to measure the ORM those acts
   governed.** To compensate
```
REPLACEMENT:
```
   regulators' set points, with no device in the design to measure, in terms of effective
   manual control rods, the ORM those acts governed.** To compensate
```

6. Risk 3 body, Annex I's finding with the computer path beside it. Applies to both
   documents.

CURRENT:
```
   the ORM in terms of effective manual control rods", `insag-7-paged.txt:3650-3651`
   (p.82), and the position, privileged,
```
REPLACEMENT:
```
   the ORM in terms of effective manual control rods", the operator summing the rod
   insertions read from the instruments or having to "instruct the plant computer to make
   the calculation and wait a few minutes for the result", `insag-7-paged.txt:3650-3655`
   (p.82), and the position, privileged,
```

7. The shape of it, the design position's reach. Applies to both documents.

CURRENT:
```
and an unobserved ORM, approved without the list of violations the regulation
```
REPLACEMENT:
```
and an ORM no observer checked against its limit, approved without the list of
violations the regulation
```

8. Change note, the post-review opening. Applies to the deliverable only.

CURRENT:
```
lines by a separate verification (listed below).
```
REPLACEMENT:
```
lines by a separate verification, whose corrections are folded into the entries below.
```

9. Change note, the risk 1 entry. Applies to the deliverable only.

CURRENT:
```
- **Risk 1.** The heading names the void coefficient beside the halt's positive reactivity
  and the ORM, as hazards with no stated observer; the body quotes INSAG's sentence on the
  coefficients whole, `insag-7-paged.txt:452-456` (p.13), keeps Annex I's finding on the
  initiating event with its conditions, `insag-7-paged.txt:3444-3447` (p.78), and shortens
  the Operating Procedures quotation to `insag-7-paged.txt:4138-4139` (p.92). The sentence
  on the Technical Safety Report moves out of the risk (it stands in the impact order's
  rank 1 and in the system that produced the system); the chain ids "X1 to X11" become the
  chains of the design position, X1, X2, X3, X7 and X11.
```
REPLACEMENT:
```
- **Risk 1.** The heading names the void coefficient beside the halt's positive reactivity,
  as hazards with no stated observer, and the ORM as a hazard with no observer against its
  limit, quoting the limit clause of `insag-7-paged.txt:1923-1925` (p.48); the body quotes
  INSAG's sentence on the coefficients whole, `insag-7-paged.txt:452-456` (p.13), keeps
  Annex I's finding on the initiating event with its conditions,
  `insag-7-paged.txt:3444-3447` (p.78), and shortens the Operating Procedures quotation to
  `insag-7-paged.txt:4139-4140` (p.92). The sentence on the Technical Safety Report moves
  out of the risk (it stands in the impact order's rank 1 and in the system that produced
  the system); the chain ids stay "X1 to X11", since every chain has the design position
  among its required entry points.
```

10. Change note, the risk 3 entry. Applies to the deliverable only.

CURRENT:
```
- **Risk 3.** The heading is shortened to the position and the absent device; Annex I's
  finding on the device is quoted whole, `insag-7-paged.txt:3650-3651` (p.82); INSAG's
```
REPLACEMENT:
```
- **Risk 3.** The heading is shortened to the position and the absent device, in Annex I's
  terms; Annex I's finding on the device is quoted whole with the plant computer's
  calculation beside it, `insag-7-paged.txt:3650-3655` (p.82); INSAG's
```

11. Change note, the shape of it entry. Applies to the deliverable only.

CURRENT:
```
- **The shape of it.** The design position's reach names the void and power coefficients
  with no safety analysis of the void coefficient.
```
REPLACEMENT:
```
- **The shape of it.** The design position's reach names the void and power coefficients
  with no safety analysis of the void coefficient, and the ORM as one no observer checked
  against its limit.
```

## Counts

- Items checked: 32. Confirmed 23, narrowed 6 (items 1, 17, 26, 28, 31, 32), wrong 3
  (items 8, 15, 30).
- Corrections: 11; 7 apply to both documents (1 to 7), 4 to the deliverable only (8 to
  11).
- Citation resolver, before the corrections: deliverable 1429 resolve, 0 do not;
  standalone 1356 resolve, 0 do not. On copies with the corrections applied: deliverable
  1430 resolve, 0 do not (correction 9 adds one); standalone 1356 resolve, 0 do not.
- Dry runs: `apply_edits.py` on the deliverable alone, 11 of 11 would apply, exit 0; on
  both documents with `--partial`, edits 1 to 7 would apply to both and 8 to 11 to the
  deliverable only, exit 0. A run on the standalone alone stops on edits 8 to 11 by design,
  since they apply to the deliverable only.
