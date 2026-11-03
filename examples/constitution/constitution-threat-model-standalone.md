# The United States federal government: a threat model of the Constitution as amended

This document is a threat model of the United States federal government as the Constitution of
the United States and its twenty-seven amendments establish it: the three branches and their
checks on each other, elections and the electoral count, presidential succession and inability,
the amendment process, and the division of power between the federal government and the States.
The system modeled is the text in force, with every amendment applied; superseded, repealed and
spent clauses are context. It judges that structure against one model, the self-observing-systems
model summarised in "Model in brief" below, and against nothing else. It names no person, office
holder, court decision, statute or event after ratification, beyond the copyright statute the brief cites below, and makes no claim about how any
power has been used.

**The evidence.** One document: House Document 110-50, "The Constitution of the United States of
America As Amended", U.S. Government Printing Office, 2007, published at the address
https://www.govinfo.gov/content/pkg/CDOC-110hdoc50/pdf/CDOC-110hdoc50.pdf (the address comes from
the brief that started the run; the document prints none). The PDF's SHA-256 is
7f29c4a79e310cc7bcee5f3fd07fb1367e463bd4530fa5d854ebdd4fd4402e57. It was extracted with pdftotext
4.00 (xpdf), `-layout`, encoding Latin1, into a page-marked text, `constitution-paged.txt`, with a
`=== PDF page N ===` line before each page; the text's SHA-256 is
82a4e5f1d5b7a183f332c1f41be06515badfb724a8b9deb13f4f68b8adb31f0e. Every citation is a line or range
in that text. The document also holds editorial bodies (front matter, a Historical Note, the
editor's notes, ratification and certification notes, unratified proposals and an Index); they are
context, cited only for what the editor says is in force, superseded or affected, and no name from
them is repeated. The rule that fixes what is in force is the brief's: the amending text's own
words where they settle a part, and otherwise the editor's notes, cited as the editor's statements.
Nothing was run. A claim that reading alone cannot settle is marked "not settled by the document",
with what would settle it.

**Copyright and rebuilding the evidence.** Every body of the document is in the public domain under
17 U.S.C. §105, as a work of the United States federal government, as the brief that started the
run states; the document prints no licence line. Neither the PDF nor the extracted text ships with
this model. The script `rebuild-source.sh`, published beside it, rebuilds the evidence: it
downloads the PDF from the address above, checks its SHA-256, extracts it with pdftotext 4.00,
`-layout`, encoding Latin1, into `constitution-paged.txt`, and checks the text's SHA-256, stopping
on any mismatch.

**How it was produced.** Static reading of the document only, in steps: an observer mapping, a gap
evaluation, a first verification of both, a chain hunt, and a chain verification. "Keys" below names
what each step's marks and ids mean. A finding is a path through the system, its precondition and
its lines, with no exploitation steps.

**How it is organized.** The model in brief; the system in brief; the risks, stated first; the
architectural model, the structure against the model property by property, the missing structural
components and the present halt paths; the keys; then Part A, the threats in STRIDE; Part B, the
chains; Part C, the rejected chain candidates; Part D, the impact; Part E, the seams not followed;
Part F, an index from each entry point to the rows and chains it reaches; then the availability
claims, the questions still unsettled, and the counts.

---

## Model in brief

**Scope.** The model applies where four constraints hold: no central controller (no agent has
authority over another); a catastrophic cost of undetected failure; an adversarial environment
(threats can mimic legitimate components); and no external maintenance (the system detects,
responds to and recovers from failure itself). The constraints put a problem in scope; they are not
a bar the system fails.

**Structure.** The observation functions form a ring of at least 3 + 1: three observers that
observe each other, and one coordinator, qualitatively different, that surface-checks every member,
itself included, takes their reports back, and is usually the ring's primary halt. Every observer
checks one other observer and reports to a different one. A coordinator is a member of the ring
above it and carries its ring's health upward, so rings nest until one ring closes the top. A pairwise
edge or a star counts as a missing ring.

**Halt on fault.** When any observer detects a fault the system halts until the fault clears or the
privileged actor leaves; any node can halt, and a halt reaches at least two other nodes.
Continue-on-fault (a default that serves, a fallback, a successor that keeps serving through the
fault) is a failed control. Execution is coupled to observation: work runs only while an observer's
heartbeat beats.

**The eight properties.** (1) Heartbeat: continuous proof of operation, whose stop is the alarm;
periodic proof such as an election is not continuous. (2) Substrate dependency: the check shares the
failure substrate of what it watches. (3) Continuous state verification: current state compared,
continuously, against the defined correct state, not only acts. (4) System-wide response: one
detection reaches every other check. (5) Self-defense: no single actor removes a check. (6) Death
signaling: a stopped check is visible in an independent institution and acted on there. (7)
Automatic integration: a new part is watched from the moment it exists; a text whose lines require
broad agreement for a new check is a refusal, not this gap. (8) Reflexive response: the response
follows the detection with no deliberation window. A pure observer satisfies 4, 5 and 8 only
through its place in a ring; where no ring exists those are gaps.

**Tiers.** Required observation scales with the cost of undetected failure: Bounded (cron and an
alarm), Significant (heartbeat and restart), Severe (redundant observers and escalation),
Catastrophic (the full 3 + 1 ring). Where a failure reaches the public's safety, or data about
persons, the tier is Catastrophic.

**Trust boundaries.** B1 is the machine-only observer ring itself; B2 is every privileged position
(here, every office and body the text creates or names, and the voters); B3 is an external party
with no foothold. A physical condition with no actor behind it is its own position.

**The bar for a system evidenced by a document.** The ring is machine-only. Where the text
establishes no machine, the candidate observers are the mechanisms it makes take effect by itself,
with no person deciding, carrying out or recognising any step: a fixed time that ends a term, an
automatic expiry, a default on inaction, an automatic transfer. A mechanism with such a step is a B2
control. No person's check discharges any property, but people's checks compose into chains like any
other. A protection a person can switch off is present only while it is on. A fact the document does
not state is unconfirmed, and silence is not absence: what the text does not describe is "none
stated" unless a line states the absence.

**Roles and records.** Each inventory entry is an observer, an observed component (the work, an
office, a bar that watches nothing), a B2 control, or a signal-path device (a record that only
carries a signal). The model also records, for every component: each hazard and its observer; each
read-back (a stored record acted on later), with who can write it, its provenance and shape checks
and any pair of a field naming an authority and a value applied under it; each deputy (a position
acting for another) and mint (authority created or handed on) with the check that keeps it within the
requester's or minter's authority; each stated exclusion (a line saying a check leaves something
out); each key a check reads; each input naming several objects; and each check stated for one of a
set of like inputs. Judging rules are cited by name in quotation marks, such as "A deliberate refusal
is not a gap" and "The widest reach is named". Availability and performance claims are listed and
never ranked.

---

## The system in brief

- **Purpose.** Confirmed at the lines. The text vests "All legislative Powers herein granted"
  in a Congress of two Houses (`constitution-paged.txt:175-177` (p.7, Art. I §1)), "The
  executive Power" in a President (`constitution-paged.txt:545-546` (p.12, Art. II §1 cl. 1))
  and "The judicial Power" in one supreme Court and such inferior courts as Congress
  establishes (`constitution-paged.txt:672-674` (p.14, Art. III §1)); it reserves undelegated
  powers to the States or the people (`constitution-paged.txt:978-980` (p.20, Amdt. X)) and
  makes the Constitution, the laws "made in Pursuance thereof" and treaties made "under the Authority of the United States" "the supreme Law of
  the Land" (`constitution-paged.txt:795-800` (p.16, Art. VI cl. 2)).
- **Customers, in two senses.** Confirmed. Who runs it: Members of the House "chosen every
  second Year by the People" (`constitution-paged.txt:235-239` (p.8, Art. I §2 cl. 1)),
  Senators "elected by the people thereof, for six years" (`constitution-paged.txt:1294-1298`
  (p.25, Amdt. XVII)), a President and Vice President chosen through electors each State
  appoints (`constitution-paged.txt:546-555` (p.12, Art. II §1 cl. 1-2)), judges "during good
  Behaviour" (`constitution-paged.txt:674-676` (p.14, Art. III §1)), officers appointed with the
  Senate's advice and consent (`constitution-paged.txt:632-648` (p.13-14, Art. II §2 cl. 2)),
  and the States' legislatures, executives and conventions wherever the text gives them a step.
  Who it acts on or for: "WE THE PEOPLE of the United States" (`constitution-paged.txt:166-171`
  (p.7, Preamble)); "All persons born or naturalized in the United States" and "any person
  within its jurisdiction" (`constitution-paged.txt:1119-1126` (p.22, Amdt. XIV §1)); "every
  State in this Union" (`constitution-paged.txt:759-763` (p.15, Art. IV §4)).
- **Its own goal, in its own words.** "to form a more perfect Union, establish Justice, insure
  domestic Tranquility, provide for the common defence, promote the general Welfare, and secure
  the Blessings of Liberty to ourselves and our Posterity" (`constitution-paged.txt:166-171`
  (p.7, Preamble)).

### Body boundaries and the in-force reading

The observer mapping's body ranges hold at the lines: the Preamble and Articles at
`constitution-paged.txt:166-813` (p.7-16), with the editor's footnotes at
`constitution-paged.txt:179-224` (p.7), `constitution-paged.txt:282-304` (p.8),
`constitution-paged.txt:374-375` (p.9), `constitution-paged.txt:441` (p.10),
`constitution-paged.txt:501` (p.11), `constitution-paged.txt:635-636` (p.13),
`constitution-paged.txt:703` (p.14) and `constitution-paged.txt:772` (p.15); the amendments
from `constitution-paged.txt:876` (p.19) with notes 14 to 17 at `constitution-paged.txt:1063`
(p.21), `constitution-paged.txt:1203` (p.23), `constitution-paged.txt:1352` (p.25) and
`constitution-paged.txt:1792` (p.31); the Editorial Note at `constitution-paged.txt:1899-1909`
(p.33). The printing slug and operator tag share text lines (for example
`constitution-paged.txt:382` (p.10) and `constitution-paged.txt:1730` (p.31)); the text on
those lines is cited as the body's. Nothing here rests on the Index.

The in-force reading the observer mapping applied is confirmed, with one addition:

- **SC1** confirmed. The spent first allocation begins mid-line with "and until such
  enumeration shall be made" at `constitution-paged.txt:256-262` (p.8, Art. I §2 cl. 3); the
  cap "shall not exceed one for every thirty Thousand" and the floor "each State shall have at
  Least one Representative" at `constitution-paged.txt:254-256` (p.8) are in force.
- Amendment XVIII is repealed by the amending text's own words (`constitution-paged.txt:1516-1517`
  (p.28, Amdt. XXI §1)). Confirmed; no row rests on it.
- Art. II §1 cl. 3 (`constitution-paged.txt:557-587` (p.12-13)) superseded on editor's note 8
  alone ("This clause has been superseded by amendment XII", `constitution-paged.txt:635`
  (p.13)), and the fourth-of-March sentence of Amendment XII (`constitution-paged.txt:1035-1040`
  (p.21)) superseded on editor's note 14 alone (`constitution-paged.txt:1063` (p.21)). Confirmed
  as DG4; no row rests on either.
- The spent and transitional parts listed by the observer mapping (`constitution-paged.txt:484-488` (p.11);
  `constitution-paged.txt:783-786` (p.16); `constitution-paged.txt:811-813` (p.16);
  `constitution-paged.txt:1307-1309` (p.25); `constitution-paged.txt:1473-1479` (p.27);
  `constitution-paged.txt:1524-1528` (p.28); `constitution-paged.txt:1570-1573` (p.28)) are
  confirmed as context.
- **Addition (correction to the observer mapping's reading of Art. II §1 cl. 6).** The observer mapping read cl. 6 as
  standing only "for the officer Congress may name by law". Editor's note 9 says the clause
  "has been affected by amendment XXV" (`constitution-paged.txt:636` (p.13)). Under the brief's
  in-force rule a clause an editor calls "affected" stands except as the amending text's own
  words reach it. Amendment XXV §1 reaches "removal ..., death or resignation"
  (`constitution-paged.txt:1718-1720` (p.30)); §3 and §4 reach inability "Whenever" a written
  declaration is transmitted (`constitution-paged.txt:1733-1747` (p.31)). No word of Amendment
  XXV reaches an inability for which no declaration is transmitted, so cl. 6's "Inability to
  discharge the Powers and Duties of the said Office, the Same shall devolve on the Vice
  President" (`constitution-paged.txt:600-603` (p.13)) stands for that case and is inventoried
  as O10. DG3 (the "devolve" against "become President" wording) is kept as recorded.

Rows resting on a clause an editor calls "affected" were each reopened: T2 and RB6 rest on Art.
I §2 cl. 3 (note 2, `constitution-paged.txt:300-303` (p.8)) only for the enumeration's manner
and on Amendment XIV §2 for apportionment, and on Art. I §9 cl. 4 (note 7,
`constitution-paged.txt:501` (p.11)) only for direct taxes that Amendment XVI's words (income
taxes, `constitution-paged.txt:1254-1257` (p.24)) do not reach; E6 rests on Art. I §6 cl. 1
(note 6, `constitution-paged.txt:441` (p.10)) for Congress fixing compensation by law, which
Amendment XXVII defers but does not displace; DA6, E22 and D5 rest on Art. II §1 cl. 6 (note 9)
for the case of "both", which Amendment XXV's words do not reach; BC9 rests on Art. III §2
(note 10) only where Amendment XI's words do not reach. No row rests on Art. IV §2 cl. 3 (note
11) or on superseded or repealed text. Nothing is dropped on this ground.

### Assets and tiers

The public-safety floor holds at the lines the observer mapping and the gap evaluation cited: the war, army, navy and
militia powers (`constitution-paged.txt:458-471` (p.11, Art. I §8 cl. 11-16)); the Commander in
Chief (`constitution-paged.txt:621-623` (p.13, Art. II §2 cl. 1)); protection "against Invasion"
and "against domestic Violence" (`constitution-paged.txt:759-763` (p.15, Art. IV §4)); the
writ of habeas corpus suspended "when in Cases of Rebellion or Invasion the public Safety may
require it" (`constitution-paged.txt:489-491` (p.11, Art. I §9 cl. 2)); the security of
"persons, houses, papers, and effects" (`constitution-paged.txt:905-909` (p.19, Amdt. IV)); no
person "deprived of life, liberty, or property, without due process of law"
(`constitution-paged.txt:943-945` (p.20, Amdt. V); `constitution-paged.txt:1123-1124` (p.22,
Amdt. XIV §1)). The records about persons hold as stated: the enumeration
(`constitution-paged.txt:251-254` (p.8)), the electors' lists (`constitution-paged.txt:1019-1021`
(p.21)), the Journals with names voting (`constitution-paged.txt:361-365` (p.9);
`constitution-paged.txt:410-412` (p.10)), the statement of accounts
(`constitution-paged.txt:512-514` (p.12)), warrants (`constitution-paged.txt:907-909` (p.19)).

| Subsystem | Reaches the public's safety or holds data about persons? | Tier | Why |
|---|:---:|---|---|
| Lawmaking | yes | Catastrophic | laws bind every judge (`constitution-paged.txt:795-800` (p.16)); war and militia powers (`constitution-paged.txt:458-471` (p.11)) |
| Executive | yes | Catastrophic | Commander in Chief and execution of the laws (`constitution-paged.txt:621-623` (p.13); `constitution-paged.txt:661-663` (p.14)) |
| Judicial | yes | Catastrophic | trial of all crimes (`constitution-paged.txt:699-701` (p.14)); life, liberty, property (`constitution-paged.txt:943-945` (p.20)) |
| Elections and the electoral count | yes | Catastrophic | decides who "shall be the President" (`constitution-paged.txt:1025-1028` (p.21)) |
| Succession, inability and acting offices | yes | Catastrophic | the executive power transferred, devolved or exercised by a deputy (`constitution-paged.txt:600-607` (p.13); `constitution-paged.txt:1453-1464` (p.27); `constitution-paged.txt:1718-1720` (p.30); `constitution-paged.txt:1733-1767` (p.31)) |
| Amendment | yes | Catastrophic | text "valid to all Intents and Purposes, as Part of this Constitution" (`constitution-paged.txt:779-781` (p.16)) |
| Federal-State division | yes | Catastrophic | protection and delivery of persons (`constitution-paged.txt:759-763` (p.15); `constitution-paged.txt:734-738` (p.15)) |
| The records | yes | Catastrophic | the inputs the count and the transfers act on (`constitution-paged.txt:1019-1025` (p.21); `constitution-paged.txt:1733-1758` (p.31)) |

Every subsystem requires the full 3+1 ring; no cell is N/A.

---

## Risks, stated first

Ranked by the rule stated in Part D, Impact across the deployment: what a position gains in one act,
times how many units one act reaches, then how far toward the floor the reach goes, a tie going
to the position that needs no privileged act. Availability is not ranked.

1. **"The removal of the President from office or ... his death or resignation" passes the
   office with no stated observer of the event.** The transfer follows the event itself, and no
   line names a position that recognises it or the addressee of a resignation
   (`constitution-paged.txt:1718-1720` (p.30, Amdt. XXV §1)); the Vice President holds the office
   for the rest of the term (`constitution-paged.txt:1443-1447` (p.27, Amdt. XX §1)), with no
   contrary declaration stated. (Conditional on U2.) Removal by conviction needs "two thirds
   of the Members present" (`constitution-paged.txt:331-332` (p.9, Art. I §3 cl. 6)), and a House
   judging members out by a vote the text does not state changes who is counted. (X1 conditional on U51.) The two-term bar reads
   election only (`constitution-paged.txt:1558-1559` (p.28, Amdt. XXII §1)), so a vacancy and
   succession can return a person twice elected. (M4 conditional on U57 and U12.)
   Ids: S3, X1, M4.

2. **"Such powers and duties shall be discharged by the Vice President as Acting President" on
   written declarations whose origin and majority no stated position checks.** A §3 declaration
   not the President's, or a §4 declaration without a true majority, transfers the executive
   power at once (`constitution-paged.txt:1733-1738, 1740-1747` (p.31, Amdt. XXV §3-4)).
   (Conditional on U3 and U4.) A two-thirds determination recorded in a Journal no other stated position
   reads, or two thirds produced by exclusion, then holds the transfer with no stated end
   (`constitution-paged.txt:1760-1765` (p.31, Amdt. XXV §4)). (S4 conditional on U27 for its
   writers and on U64 for the House's own entry; X3 on U4 and on one of U27, U64 or U51, its open
   end on U62.) A declaration held by the two officers to whom it is transmitted, or its "receipt"
   recorded early or late, moves the window, the text naming no receiver for "receipt"; and
   Congress "may by law provide" the "other body" that co-makes the §4 declarations
   (`constitution-paged.txt:1741-1742, 1753-1762` (p.31, Amdt. XXV §4)). (T6 conditional on U5.)
   Ids: S1, S2, S4, X3, T6, E41.

3. **"The votes shall then be counted" with no counter named and no stated source for "the whole
   number of Electors appointed".** The lists are opened "in the presence of the Senate and House
   of Representatives" and counted by no named position (`constitution-paged.txt:1023-1028`
   (p.21, Amdt. XII)). A list altered after sealing, cast by barred or unappointed persons, or
   carrying more votes than electors appointed decides who "shall be the President", and the
   States' and the District's numbers of electors are read by no stated check
   (`constitution-paged.txt:550-555` (p.12, Art. II §1 cl. 2); `constitution-paged.txt:1618-1621`
   (p.29, Amdt. XXIII §1)). (Conditional on U7, U8, U29 and
   U32.)
   Ids: E1, E2, E27, E28.

4. **Text "valid to all Intents and Purposes, as Part of this Constitution" on ratifications no
   named position counts, and a State "deprived of its equal Suffrage in the Senate" with no
   stated reader of its consent.** A ratification not a legislature's or a convention's changes
   every mechanism and bar in one act (`constitution-paged.txt:779-781` (p.16, Art. V)), an
   application not a legislature's reaching the text only through a proposal so ratified
   (`constitution-paged.txt:767-770` (p.15, Art. V)); and an amendment past the equal-suffrage
   proviso reaches the deprived State's
   suffrage and every act the Senate shares (`constitution-paged.txt:786-787` (p.16, Art. V)).
   (Conditional on U19.) A State "formed or erected within the Jurisdiction of any other State",
   or by junction, without the legislatures' consent carries Senate seats, Representatives,
   electors and a ratifying vote, and so moves every supermajority denominator
   (`constitution-paged.txt:746-751` (p.15, Art. IV §3)). (M9 conditional on U61.)
   Ids: T4, E33, M9.

5. **The President "unable to discharge the powers and duties of his office", with no position
   named to recognise the inability, and acting offices held past ends the text fixes with
   nothing stated to stop the holder.** For an inability no declaration reaches, "the Same shall
   devolve on the Vice President" with no recogniser (`constitution-paged.txt:600-603` (p.13,
   Art. II §1 cl. 6)), what devolves, the office or its powers and duties, being not settled by
   the document (DG3), so an unable President can hold the powers in fact, and custody of the President
   by delivery on demand or a legislative act may be such an inability. (D7
   conditional on U48; X7 on U65 and U48, and on U21 for the demand route.) A vacant Vice Presidency, a House without a Speaker or
   a Senate without a President pro tempore closes the declaration path, and an Acting President's
   own inability reaches no stated declaration (`constitution-paged.txt:1733-1747` (p.31, Amdt.
   XXV §3-4)). (D5 conditional on U28; M5 on U54; M11 on U66 and U28.) The others' inaction
   returns the powers to the declared-unable President (`constitution-paged.txt:1749-1767` (p.31,
   Amdt. XXV §4)), and the Vice President elect acts "until a President shall have qualified", an
   officer a law names "until a President or Vice President shall have qualified", with nothing
   stated to stop either at that end
   (`constitution-paged.txt:1455-1464` (p.27, Amdt. XX §3)). (E22, E23 and M6's law branch
   conditional on U6.)
   Ids: D7, X7, D5, M5, M11, E43, E22, E23, M6.

6. **A bill that "shall be a Law" or "shall not be a Law" on a record of its return, a
   presenter's timing and an adjournment no stated position checks.** The ten-day default reads
   whether a bill was "returned by the President within ten Days" (`constitution-paged.txt:412-417`
   (p.10, Art. I §7 cl. 2)); the originating House's record of the return, or a return delivered
   to the other House, decides whether the bill becomes law without approval and without two
   thirds. (T1 conditional on U26 for the originating House and on U27 for a writer not stated; M1 on U26 and U63.) The presenter, whom the text does
   not name, sets when the ten days start (`constitution-paged.txt:400-402` (p.10, Art. I §7
   cl. 2)), and the President's adjournment of the Houses on their disagreement may defeat a bill
   with no objections entered and no override (`constitution-paged.txt:657-660` (p.14, Art. II
   §3)). (D2 conditional on U1; X5 on U52.) Every law so made binds "the Judges in every State"
   (`constitution-paged.txt:798-800` (p.16, Art. VI cl. 2)), the clause reaching the laws "made in Pursuance thereof" (`constitution-paged.txt:795-796` (p.16, Art. VI cl. 2)).
   Ids: T1, M1, D2, E36, E42, X5.

7. **The writ "suspended ... when in Cases of Rebellion or Invasion the public Safety may require
   it" by a body no line names, and bars on laws read by no stated mechanism, applied by a court in a case.** The clause
   is passive and names neither the body that suspends nor the position that finds the case
   (`constitution-paged.txt:489-491` (p.11, Art. I §9 cl. 2)); it states only when the privilege
   may be suspended, naming no issuer of the writ and no effect of it, so what the suspension
   reaches is not stated. (E11 conditional on U15; its reach on U67.) A
   warrant's issuer is not named, a demand for delivery is read by no stated check, and a
   "Bill of Attainder", a term the text does not define, is barred at the line and applied by a court in a case, no other reader stated
   (`constitution-paged.txt:905-909` (p.19, Amdt. IV); `constitution-paged.txt:734-738` (p.15,
   Art. IV §2 cl. 2); `constitution-paged.txt:492` (p.11, Art. I §9 cl. 3)). (E16 conditional on
   U9; E46 on U21.) Laws against the standing bars, from the religion clauses to the uniformity
   of duties and the public debt, are executed until a court finds otherwise.
   Ids: E11, E16, E46, E12, E17, M10, E40, E45, E38.

8. **"No Money shall be drawn from the Treasury, but in Consequence of Appropriations made by
   Law", with no stated reader of the draw.** Neither the draw bar nor the two-year cap on army
   appropriations names a reader (`constitution-paged.txt:511-512` (p.12, Art. I §9 cl. 7);
   `constitution-paged.txt:460-461` (p.11, Art. I §8 cl. 12)), so a draw without or beyond an
   appropriation reaches the public money in whatever amount it names. The only stated record of
   draws is published "from time to time" by a position not named, and nothing stated acts on it
   (`constitution-paged.txt:512-514` (p.12, Art. I §9 cl. 7)). (Conditional on U11.)
   Ids: T5, E5, R3.

9. **"The supreme Law of the Land" binding every judge on texts with no stated custodian, and
   powers past "necessary and proper" or "appropriate" read by no stated check but a court in a case.** No line
   names a custodian of the laws and treaties the judges read, or a check that a text was made as
   required (`constitution-paged.txt:795-800` (p.16, Art. VI cl. 2)). (S6 conditional on U42.) A
   treaty past "the Authority of the United States", or a law vesting power in "any Department or
   Officer", the President included, past the enumerated powers or past "appropriate" in the
   seven enforcement articles, is read by no stated check but the judges' in a case. (E30 conditional on U44; E29 on U43;
   M8 on U58.) Officers hold office through the named conduct until two bodies act, the removal line not saying "only", and no line states the judges'
   removal path (`constitution-paged.txt:665-668, 674-676` (p.14, Art. II §4, Art. III §1)). (E4's
   judges' entry conditional on U50.)
   Ids: S6, E30, E29, M8, E10, E4.

10. **Offices "established by Law" filled or entered past their grant: recess commissions
    regranted across sessions, officers vested as "inferior", and commissions and oaths no stated
    position reads.** A recess commission expires "at the End of their next Session"
    (`constitution-paged.txt:650-652` (p.14, Art. II §2 cl. 3)), and a new one can be granted at
    the next recess, so an office is held across sessions while the Senate withholds consent. (X2
    conditional on U22 and U53.) The widest office a commission, a vesting law or an appointment
    can name is a principal officer, whose office carries a place in the §4 majority
    (`constitution-paged.txt:1740-1747` (p.31, Amdt. XXV §4)), or a judge of the supreme Court.
    (E20 conditional on U22; E21 on U16; E26 on U31; E19 on U12.) An office, the President's
    included, entered without the oath, and a holder continuing after a term "shall end", are
    read by no stated position (`constitution-paged.txt:615-619` (p.13, Art. II §1 cl. 8);
    `constitution-paged.txt:1443-1447` (p.27, Amdt. XX §1)). (E44 conditional on U20; E3 on U30;
    E7 on U35.)
    Ids: X2, E20, E21, E26, E19, E44, E3, E7.

11. **The representation of the States: an enumeration, a reduction, a writ and a temporary
    appointment no stated position checks.** The enumeration sets every State's Representatives
    and electors in one act (`constitution-paged.txt:1128-1131` (p.22, Amdt. XIV §2);
    `constitution-paged.txt:550-553` (p.12, Art. II §1 cl. 2)), and the reduction for a denied
    vote needs a position the text does not name. (T2 conditional on U40; E18 on U13.) A withheld
    writ, or a temporary appointment held past the election that ends it, keeps a seat outside the
    people's choice (`constitution-paged.txt:264-266` (p.8, Art. I §2 cl. 4);
    `constitution-paged.txt:1300-1305` (p.25, Amdt. XVII)), and a writ for a seat not vacant orders
    a second return for a seat held, which return is seated being each House's judgment
    (`constitution-paged.txt:350-351` (p.9, Art. I §5 cl. 1)). (T3 conditional on U41; E24 and E25
    on U14.) Who judges whether a State is invaded or in imminent danger, or whether its imposts
    are necessary for its inspection laws, is not stated, its impost laws being "subject to the Revision and Control of the Congress" after
    (`constitution-paged.txt:534-535` (p.12, Art. I §10 cl. 2)), and the proof of an act presented
    as a State's is left to Congress's general laws, not in the document
    (`constitution-paged.txt:727-729` (p.15, Art. IV §1)). (E13 and E14 conditional on U34; E15 on
    U35; S5 on U18.)
    Ids: T2, E18, T3, D3, E24, E25, E13, E14, E15, S5.

12. **Proceedings withheld as "may in their Judgment require Secrecy", votes with no names, acts
    by less than a quorum, and bounds on pardons, disabilities and judgments no stated check
    reads.** Each House withholds any part of its Journal on its own judgment, and names are
    entered only "at the Desire of one fifth of those Present" (`constitution-paged.txt:361-365`
    (p.9, Art. I §5 cl. 3)), the override alone requiring them (`constitution-paged.txt:410-412`
    (p.10, Art. I §7 cl. 2)). Acts by less than a majority beyond adjourning "from day to day" and
    compelling attendance (`constitution-paged.txt:352-355` (p.9, Art. I §5 cl. 1)), the Vice
    President's vote where the
    Senate is not "equally divided", and a pardon, a removal of "such disability" or a judgment
    past its scope are read by no stated check. (E31 conditional on U33; E32 on U45; E34 on U46.)
    Each State's votes are known to the holder of the sealed lists before the count, and a law
    varying the members' pay may take effect on an election that may not count. (I1 conditional
    on U32; M7 on U24.)
    Ids: R1, R2, I1, E8, E9, E6, E31, E32, E34, D1, D4, D6, M7.

---

## The architectural model

### The ring test

#### The role test

The observer mapping's test: an entry holds the role observer only where the text makes its effect follow
from a state of a component, or from the absence of an act within a window, with no position
deciding, carrying out or recognising a step between the condition and the effect, and the
effect lands on a position other than the one whose state it reads. Where the effect follows
from a position's decision about that very effect (a declaration, a vote, a count, a
ratification, a resignation, a conviction), the decision is a B2 control. A bar that states a
standing prohibition with no time or event at which a status changes (the eligibility,
incompatibility, attainder and treason bars, the supremacy clause, the rights of persons) takes
effect only through a position honouring it and is an observed component.

Tested at the lines:

- **B2 controls confirmed.** Amendment XXV §3: the powers pass "Whenever the President transmits
  ... his written declaration" (`constitution-paged.txt:1733-1738` (p.31)), the President's
  decision. §4: the Vice President "shall immediately assume" "Whenever the Vice President and a
  majority ... transmit ... their written declaration" (`constitution-paged.txt:1740-1747`
  (p.31)), their decision. The electoral majority rule applies only on "the votes shall then be
  counted" (`constitution-paged.txt:1024-1028` (p.21)), a step persons carry out with no counter
  named (U7). Ratification makes an amendment "valid ... when ratified by the Legislatures of
  three fourths" (`constitution-paged.txt:779-781` (p.16)), the ratifying decisions, with no
  counter named (U19). Each is a B2 control.
- **O1 to O9 confirmed as observers.** Each effect follows from a state or an absence within a
  window: O1 the President's non-return within ten days (`constitution-paged.txt:412-415`
  (p.10)); O2 the clock (`constitution-paged.txt:1443-1447` (p.27)); O3 the President's death
  (`constitution-paged.txt:1718-1720` (p.30)); O4 and O5 the absence of a second declaration
  within four days and of a two-thirds determination within twenty-one days
  (`constitution-paged.txt:1752-1767` (p.31)); O6 the President elect's death and O7 the absence
  of a chosen or qualified President at the time fixed (`constitution-paged.txt:1453-1459`
  (p.27)); O8 the end of the Senate's next session (`constitution-paged.txt:650-652` (p.14)); O9
  an intervening election (`constitution-paged.txt:1858-1860` (p.32)). The step that starts or
  sets each condition is a position's (presentment, a declaration, an adjournment, an election);
  that step is the input or a removal path, not a step between condition and effect. The
  recognising step is stated for none of them: no line requires a position to recognise the
  condition before the effect follows, and no line says none recognises it, so each effect
  stands by the text's own words with its recogniser not stated (U1, U2, U5, U6, U23, U24, U30).
  No observer is found to carry a person's recognising step at the lines.
- **Mechanisms the observer mapping missed (corrected and new).** The same test makes observers of four ends
  and one transfer the text states by its own words:
  - O7's end, "until a President shall have qualified" (`constitution-paged.txt:1458-1459`
    (p.27)): the Vice President elect's acting ends on that state. O7 is corrected to carry its
    end as well as its start.
  - O10 (new), Art. II §1 cl. 6: on the President's "Inability to discharge the Powers and
    Duties of the said Office, the Same shall devolve on the Vice President"
    (`constitution-paged.txt:600-603` (p.13)), in force for an inability no Amendment XXV
    declaration reaches (The system in brief). Effect on a state; no recogniser stated (U48).
  - O11 (new), Amendment XVII ¶2: the executive's "temporary appointments until the people fill
    the vacancies by election as the legislature may direct" (`constitution-paged.txt:1302-1305`
    (p.25)). The appointment ends on that event; no recogniser stated (U14).
  - O12 (new), the officer Congress's law names "shall act accordingly, until the Disability be
    removed, or a President shall be elected" (`constitution-paged.txt:606-607` (p.13)), and the
    person so named "shall act accordingly until a President or Vice President shall have
    qualified" (`constitution-paged.txt:1462-1464` (p.27)). The acting ends on those states; no
    recogniser stated (U6).
  The observer mapping recorded these in SS4 as "read by no stated machine" while giving O8 and O9, whose
  recognisers are equally not stated, the observer role. One test decides all of them.

#### Observer inventory

Every entry, the observers first, then the observed components, the B2 controls and the signal-path devices. OC3 is corrected below.

| # | Entry | Role | file:line | What it checks (key record) | Reports to | On fault | Person could disable, bypass or reset |
|---|---|---|---|---|---|---|---|
| O1 | Unreturned-bill default | observer | `constitution-paged.txt:412-417` (p.10, Art. I §7 cl. 2) | whether "any Bill" presented was "returned by the President within ten Days (Sundays excepted)"; key: the bill presented; lands on "the Same"; identical | no position | "shall be a Law": continue (C1) | adjournment preventing return (RP1); presentment by an unnamed presenter (U1, RP9) |
| O2 | Fixed term ends | observer | `constitution-paged.txt:1443-1447` (p.27, Amdt. XX §1) | the clock against noon on 20 January and 3 January; key: the date; lands on every term of the kind; identical by the text's terms | no position | terms "shall end": halt of every elected term (H4); what stops a holder continuing not stated (U30) | none stated; amendment only (BC15) |
| O3 | Vacancy transfer, death branch | observer | `constitution-paged.txt:1718-1720` (p.30, Amdt. XXV §1) | the office of President for "his death"; key: the office; identical | no position | "the Vice President shall become President": continue by a successor (C2); recogniser not stated (U2) | none stated; a vacant Vice Presidency leaves no recipient (U28) |
| O4 | Four-day default | observer | `constitution-paged.txt:1749-1758` (p.31, Amdt. XXV §4) | whether the second declaration is transmitted "within four days"; counting rule not stated (U5) | the two officers receive (SP4) | "he shall resume": continue by default (C3) | the declaration is the condition (BC13); "such other body" by law (RP2); the Vice President's non-participation or vacancy (RP12) |
| O5 | Twenty-one-day default | observer | `constitution-paged.txt:1758-1767` (p.31, Amdt. XXV §4) | whether Congress "within twenty-one days after receipt of the latter written declaration, or, if Congress is not in session, within twenty-one days after Congress is required to assemble", determines by two thirds; "receipt" by whom not stated (U5) | no position | "otherwise, the President shall resume": continue (C3) | the vote is the condition (BC13); PR1 |
| O6 | President-elect death transfer | observer | `constitution-paged.txt:1453-1455` (p.27, Amdt. XX §3) | whether "the President elect shall have died" at the time fixed | no position | "the Vice President elect shall become President": continue by a successor, held by no C id (C4 holds O7's acting and the law's person); recogniser not stated (U6) | none stated |
| O7 [corrected] | Unqualified-President default and its end | observer | `constitution-paged.txt:1455-1459` (p.27, Amdt. XX §3) | at the time fixed, whether "a President shall not have been chosen" or "failed to qualify"; and, after, whether "a President shall have qualified"; recogniser of each not stated (U6) | no position | the Vice President elect "shall act as President" (C4) and stops at the qualification (H5, new) | none stated; the case of "neither" goes to a law (DA6) |
| O8 | Recess-commission expiry | observer | `constitution-paged.txt:650-652` (p.14, Art. II §2 cl. 3) | whether the Senate's "next Session" has ended; class of commission recorded by no stated position (U22); recogniser not stated (U23) | no position | "shall expire": halt of the authority (H1) | the Houses' and the President's adjournments (RP4); whether an adjournment ends the "next Session" is not settled by the document |
| O9 | Pay-law deferral | observer | `constitution-paged.txt:1858-1860` (p.32, Amdt. XXVII) | whether "an election of Representatives shall have intervened"; recogniser not stated, and whether an election to fill one vacancy counts not settled (U24) | no position | the law "shall take effect" only then: halt (H2) | none stated; a single State executive's writ of election (`constitution-paged.txt:264-266` (p.8)) may release the halt if such an election counts (U24) |
| O10 | Inability devolution (new) | observer | `constitution-paged.txt:600-603` (p.13, Art. II §1 cl. 6) | the President's "Inability to discharge the Powers and Duties of the said Office", for an inability no Amendment XXV declaration reaches; key: the office; identical; recogniser not stated (U48) | no position | "the Same shall devolve on the Vice President": continue by a deputy (C9, new) | none stated; a §3 or §4 declaration takes the case into Amendment XXV's procedure (`constitution-paged.txt:1733-1747` (p.31)); a vacant Vice Presidency leaves no recipient (U28) |
| O11 | Temporary-appointment end (new) | observer | `constitution-paged.txt:1302-1305` (p.25, Amdt. XVII ¶2) | whether "the people fill the vacancies by election"; key: the seat; identical; recogniser not stated (U14) | no position | the temporary appointment ends: halt of the appointee's authority (H6, new) | the legislature directs the election ("as the legislature may direct") and the executive issues the writ with no time fixed (`constitution-paged.txt:1300-1302` (p.25), PR6) |
| O12 | Acting-officer end (new) | observer | `constitution-paged.txt:606-607` (p.13, Art. II §1 cl. 6); `constitution-paged.txt:1462-1464` (p.27, Amdt. XX §3) | whether "the Disability be removed", "a President shall be elected", or "a President or Vice President shall have qualified"; key: the office; identical; recogniser not stated (U6) | no position | the officer's acting ends: halt (H7, new) | Congress names the officer and the manner of selection by law (BC28, DA6) |
| OC1 | Assembly date | observed component (a schedule positions must act on) | `constitution-paged.txt:1449-1451` (p.27, Amdt. XX §2) | none: "such meeting shall begin at noon on the 3d day of January"; the assembling is the members' act (BC6) | none | none stated: a Congress not assembled is a hazard (hazards table) | "unless they shall by law appoint a different day" (`constitution-paged.txt:1451` (p.27)) (RP3) |
| OC2 | Terms of office | observed component | `constitution-paged.txt:235-236` (p.8, Art. I §2 cl. 1); `constitution-paged.txt:1294-1295` (p.25, Amdt. XVII); `constitution-paged.txt:277-280` (p.8, Art. I §3 cl. 2); `constitution-paged.txt:311` (p.9); `constitution-paged.txt:546-548` (p.12, Art. II §1 cl. 1) | none: two, six and four years; one third of the Senate chosen every second year | none | the end is O2 | none stated beyond amendment |
| OC3 [corrected] | Judges' tenure | observed component | `constitution-paged.txt:674-676` (p.14, Art. III §1) | none: "during good Behaviour"; no fixed end | none | no stated removal path for judges: Art. II §4 names "The President, Vice President and all civil Officers" (`constitution-paged.txt:665-668` (p.14)), and whether judges are "civil Officers" is not settled (U50); impeachment (BC5) is a person's check | BC5 |
| OC4 | Army-appropriation cap | observed component (a bar on Congress) | `constitution-paged.txt:460-461` (p.11, Art. I §8 cl. 12) | none by itself: "no Appropriation of Money to that Use shall be for a longer Term than two Years"; no reader named (U11) | none | none stated | Congress writes the appropriation (BC28) |
| OC5 | Treasury draw bar | observed component (a bar) | `constitution-paged.txt:511-514` (p.12, Art. I §9 cl. 7) | none by itself: "No Money shall be drawn from the Treasury, but in Consequence of Appropriations made by Law"; no reader named (U11) | the published "Statement and Account" (SP5) | none stated | Congress writes the appropriations (BC28) |
| OC6 | Compensation bars | observed component (bars) | `constitution-paged.txt:609-613` (p.13, Art. II §1 cl. 7); `constitution-paged.txt:676-678` (p.14, Art. III §1) | none by itself: the President's compensation "neither encreased nor diminished during the Period", no other emolument; judges' "not diminished during their Continuance in Office" | none | none stated | Congress fixes its members' compensation by law (`constitution-paged.txt:371-372` (p.9)) (BC28), and who fixes the President's and the judges' compensation is none stated; O9 defers only Congress's own pay |
| OC7 | Eligibility bars | observed component (bars) | `constitution-paged.txt:241-244` (p.8, Art. I §2 cl. 2); `constitution-paged.txt:316-319` (p.9, Art. I §3 cl. 3); `constitution-paged.txt:593-598` (p.13, Art. II §1 cl. 5); `constitution-paged.txt:1047-1049` (p.21, Amdt. XII); `constitution-paged.txt:1558-1562` (p.28, Amdt. XXII §1); `constitution-paged.txt:1148-1157` (p.23, Amdt. XIV §3) | none by itself: age, citizenship, residence, the two-term limit, the insurrection disability. Key read where applied: the person's attributes; where the act lands: the seat or office. For members, each House judges (BC6); for the President, Vice President and electors no judge is named (U12) | none | none stated | each House's judgment (BC6); Congress may "remove such disability" by two thirds (`constitution-paged.txt:1156-1157` (p.23)) (BC17) |
| OC8 | Incompatibility and emoluments bars | observed component (bars) | `constitution-paged.txt:389-394` (p.10, Art. I §6 cl. 2); `constitution-paged.txt:516-520` (p.12, Art. I §9 cl. 8); `constitution-paged.txt:553-555` (p.12, Art. II §1 cl. 2) | none by itself: no office holder "shall be a Member of either House"; no present, emolument, office or title from a foreign state "without the Consent of the Congress"; no Senator, Representative or office holder appointed an elector (U29) | none | none stated | each House's judgment (BC6); Congress's consent (BC18) |
| OC9 | Quorum rules | observed component (bars) | `constitution-paged.txt:351-352` (p.9, Art. I §5 cl. 1); `constitution-paged.txt:1033-1035, 1044-1047` (p.21, Amdt. XII) | none by itself: "a Majority of each shall constitute a Quorum"; the House's contingent-election quorum "a member or members from two-thirds of the states"; the Senate's "two-thirds of the whole number of Senators"; the count is each House's (BC6) | none | none stated | a smaller number "may adjourn from day to day, and may be authorized to compel the Attendance of absent Members" (`constitution-paged.txt:352-355` (p.9)) (PR5) |
| OC10 | Vice President's conditional vote | observed component (a rule a position acts on) | `constitution-paged.txt:321-322` (p.9, Art. I §3 cl. 4) | none by itself: "no Vote, unless they be equally divided"; the vote is the Vice President's act (BC19) | none | none stated | BC19 |
| OC11 | Supremacy clause | observed component (a bar on State law) | `constitution-paged.txt:795-800` (p.16, Art. VI cl. 2) | none by itself: the Constitution, laws "made in Pursuance thereof" and treaties are "the supreme Law of the Land; and the Judges in every State shall be bound thereby"; the judges apply it (BC31) | none | none stated | BC31 |
| OC12 | Habeas corpus, attainder, ex post facto and treason bars | observed component (bars) | `constitution-paged.txt:489-492` (p.11, Art. I §9 cl. 2-3); `constitution-paged.txt:525-526` (p.12, Art. I §10 cl. 1); `constitution-paged.txt:713-717` (p.15, Art. III §3 cl. 1) | none by itself: the writ "shall not be suspended, unless when in Cases of Rebellion or Invasion the public Safety may require it"; "No Bill of Attainder or ex post facto Law shall be passed"; treason "only" as defined, conviction only on "two Witnesses to the same overt Act, or on Confession in open Court" (the court's check, BC9) | none | none stated | suspension by a body the text does not name (U15) (RP6) |
| OC13 | State bars | observed component (bars) | `constitution-paged.txt:522-541` (p.12, Art. I §10) | none by itself: "No State shall" enter treaties, coin money, pass attainders or impair contracts; "without the Consent of the Congress" lay imposts, except "what may be absolutely necessary for executing its inspection Laws" (SE11), lay duties of tonnage, "keep Troops, or Ships of War in time of Peace", enter compacts, or "engage in War, unless actually invaded, or in such imminent Danger as will not admit of delay" (U34) | none | none stated | Congress's consent (BC18) |
| OC14 | Rights of persons | observed component (bars on government acts) | `constitution-paged.txt:885-980` (p.19-20, Amdts. I to X); `constitution-paged.txt:1119-1126` (p.22, Amdt. XIV §1); `constitution-paged.txt:1212-1214` (p.24, Amdt. XV §1); `constitution-paged.txt:1394-1396` (p.26, Amdt. XIX); `constitution-paged.txt:1671-1676` (p.30, Amdt. XXIV §1); `constitution-paged.txt:1816-1818` (p.32, Amdt. XXVI §1) | none by itself: "Congress shall make no law", "shall not be violated", "No person shall be held", "shall not be denied or abridged"; applied by courts (BC9) and by Congress's enforcement legislation (BC28) | none | none stated | BC9, BC28 |
| OC15 | Representation reduction | observed component (a rule positions must apply) | `constitution-paged.txt:1131-1146` (p.22-23, Amdt. XIV §2) | none by itself: where the right to vote "is denied ... or in any way abridged, except for participation in rebellion, or other crime, the basis of representation therein shall be reduced in the proportion"; the finding and the reduction need a position the text does not name (U13) | none | none stated | BC30 |
| OC16 | Electoral majority rule | observed component (the rule the count applies) | `constitution-paged.txt:1025-1028, 1040-1043` (p.21, Amdt. XII) | none by itself: "if such number be a majority of the whole number of Electors appointed"; applied on the count persons make (BC10); the denominator's source is not stated (U7) | none | no majority: the House or the Senate chooses (BC11) | BC10, BC11 |
| OC17 | The offices and the work | observed component | `constitution-paged.txt:175-177` (p.7, Art. I §1); `constitution-paged.txt:545-546` (p.12, Art. II §1 cl. 1); `constitution-paged.txt:672-674` (p.14, Art. III §1) | none: the legislative, executive and judicial powers as exercised | none | the hazards table | the positions themselves |
| BC1 | Veto | B2 control | `constitution-paged.txt:400-405` (p.10, Art. I §7 cl. 2) | the President's approval or return "with his Objections"; key: the bill; where it lands: "that House in which it shall have originated" (U26) | the originating House's Journal (SP2) | returned: reconsideration (BC2) | the President; O1 bounds the window |
| BC2 | Override | B2 control | `constitution-paged.txt:405-412` (p.10, Art. I §7 cl. 2) | "two thirds of that House" then "two thirds of that House" (the other); "the Votes of both Houses shall be determined by Yeas and Nays, and the Names ... entered on the Journal" | the Journals (SP1) | not reached: the bill fails | the Houses |
| BC3 | Presentment | B2 control | `constitution-paged.txt:400-402, 419-425` (p.10, Art. I §7 cl. 2-3) | that a bill, order, resolution or vote "shall ... be presented to the President"; the presenter is not named (U1); "except on a question of Adjournment" (SE3) | the President | not presented: no law; O1 never starts (RP9) | the Houses' officers (not named) |
| BC4 | Advice and consent | B2 control | `constitution-paged.txt:630-646` (p.13-14, Art. II §2 cl. 2) | the Senate's concurrence: treaties "provided two thirds of the Senators present concur"; appointments "by and with the Advice and Consent of the Senate" to offices "established by Law" | none stated | refused: no treaty or appointment | the Senate; the recess power bypasses it for a session (O8, DA2) |
| BC5 | Impeachment, trial, removal | B2 control | `constitution-paged.txt:268-269` (p.8, Art. I §2 cl. 5); `constitution-paged.txt:328-338` (p.9, Art. I §3 cl. 6-7); `constitution-paged.txt:665-668` (p.14, Art. II §4) | the House's "sole Power of Impeachment"; the Senate's trial "on Oath or Affirmation", the Chief Justice presiding when the President is tried, conviction by "two thirds of the Members present"; judgment limited to removal and disqualification; removal on conviction "of Treason, Bribery, or other high Crimes and Misdemeanors" | none stated | not convicted: the officer stays | the House (not impeaching), the Senate (not convicting) |
| BC6 | Each House judging its members, quorum, attendance | B2 control | `constitution-paged.txt:350-355` (p.9, Art. I §5 cl. 1) | "the Judge of the Elections, Returns and Qualifications of its own Members"; the quorum count; compelling attendance "under such Penalties as each House may provide". Key read: the member's return and qualifications (OC7, OC8); no vote threshold is stated for judging; expulsion needs two thirds (BC7): a like act that skips the two-thirds check, recorded here for the chain hunt | none stated | none stated | the House itself |
| BC7 | Rules, punishment, expulsion | B2 control | `constitution-paged.txt:357-359` (p.9, Art. I §5 cl. 2) | "with the Concurrence of two thirds, expel a Member" | none stated | none stated | the House itself |
| BC8 | Journal keeping and secrecy | B2 control | `constitution-paged.txt:361-365` (p.9, Art. I §5 cl. 3) | each House keeps and publishes its Journal "excepting such Parts as may in their Judgment require Secrecy" (SE1); yeas and nays "at the Desire of one fifth of those Present" (SE21) | the public (publication) | none stated | the House's judgment of secrecy (SE1) |
| BC9 | The judicial power, juries, treason proof | B2 control | `constitution-paged.txt:672-701` (p.14, Art. III §1-2); `constitution-paged.txt:713-717` (p.15, Art. III §3 cl. 1); `constitution-paged.txt:913-915` (p.19, Amdt. V); `constitution-paged.txt:949-956` (p.20, Amdt. VI); `constitution-paged.txt:960-964` (p.20, Amdt. VII) | courts decide "all Cases ... arising under this Constitution"; trial of crimes "by Jury"; no infamous crime "unless on a presentment or indictment of a Grand Jury, except in cases arising in the land or naval forces" (SE9); treason only on two witnesses or confession | none stated | none stated | Congress's exceptions to appellate jurisdiction (`constitution-paged.txt:694-697` (p.14)) (SE8, RP7); Congress ordains the inferior courts (`constitution-paged.txt:672-674` (p.14)) |
| BC10 | Opening and counting the electoral votes | B2 control | `constitution-paged.txt:1023-1028` (p.21, Amdt. XII) | "The President of the Senate shall, in the presence of the Senate and House of Representatives, open all the certificates and the votes shall then be counted"; the counter is not named (U7). Key read: names and vote numbers on the lists (RB2); key where the act lands: the person who "shall be the President"; correspondence by name only, not stated further; the denominator "the whole number of Electors appointed" has no stated source (U7) | the two Houses present | no majority: BC11 | the President of the Senate; the counter (unnamed) |
| BC11 | Contingent elections | B2 control | `constitution-paged.txt:1028-1035, 1043-1047` (p.21, Amdt. XII) | the House chooses "from the persons having the highest numbers not exceeding three", by States, quorum two thirds of the States, "a majority of all the states"; the Senate chooses the Vice President "from the two highest numbers", quorum two thirds of the whole number, majority of the whole number | none stated | not chosen by the time fixed: O7 | the Houses |
| BC12 | The President's inability declarations | B2 control | `constitution-paged.txt:1733-1738, 1749-1752` (p.31, Amdt. XXV §3-4) | the President's "written declaration that he is unable" and "a written declaration to the contrary" or "that no inability exists"; on the first "such powers and duties shall be discharged by the Vice President as Acting President" (the consequence); the origin of a declaration is checked by no stated position (U3) | the President pro tempore and the Speaker (SP4) | none stated | the President; a contrary declaration resets the transfer (RP8) |
| BC13 | The Vice President's and majority's declarations; Congress's decision | B2 control | `constitution-paged.txt:1740-1747, 1752-1765` (p.31, Amdt. XXV §4) | "the Vice President and a majority of either the principal officers of the executive departments or of such other body as Congress may by law provide" declare the President unable, and "the Vice President shall immediately assume the powers and duties of the office as Acting President" (the consequence); the majority is established by no stated position (U4); Congress "shall decide the issue" by "two-thirds vote of both Houses" | the President pro tempore and the Speaker (SP4); Congress | none stated | the Vice President (RP12); Congress's substitution of the body (RP2); O4 and O5 bound the windows |
| BC14 | Nomination and confirmation of a Vice President | B2 control | `constitution-paged.txt:1722-1731` (p.30-31, Amdt. XXV §2) | "the President shall nominate a Vice President who shall take office upon confirmation by a majority vote of both Houses of Congress" | none stated | not confirmed: the office stays vacant (U28) | the President (not nominating), either House |
| BC15 | Proposal and ratification of amendments | B2 control | `constitution-paged.txt:767-787` (p.15-16, Art. V) | two thirds of both Houses propose, or a convention called "on the Application of the Legislatures of two thirds of the several States"; "valid ... when ratified by the Legislatures of three fourths of the several States, or by Conventions in three fourths thereof, as the one or the other Mode of Ratification may be proposed by the Congress" (the consequence of the ratifying decisions); no counter of the two thirds or three fourths is named (U19); "no State, without its Consent, shall be deprived of its equal Suffrage in the Senate" (SE16) | none stated | not ratified: no change | the Houses, the State legislatures or conventions; Congress chooses the mode |
| BC16 | Pardons | B2 control | `constitution-paged.txt:627-628` (p.13, Art. II §2 cl. 1) | "Reprieves and Pardons for Offences against the United States, except in Cases of Impeachment" (SE7); who checks the offence's class is not stated (U33) | none stated | none stated | the President |
| BC17 | Removal of the insurrection disability | B2 control | `constitution-paged.txt:1156-1157` (p.23, Amdt. XIV §3) | "Congress may by a vote of two-thirds of each House, remove such disability" (SE15) | none stated | none stated | Congress |
| BC18 | Congress's consent to State and officer acts, and to new States | B2 control | `constitution-paged.txt:516-520` (p.12, Art. I §9 cl. 8); `constitution-paged.txt:529-541` (p.12, Art. I §10 cl. 2-3); `constitution-paged.txt:746-751` (p.15, Art. IV §3 cl. 1) | consent to emoluments from foreign states; to State imposts, tonnage duties, troops, compacts and war; to new States formed by "the Junction of two or more States, or Parts of States", barred "without the Consent of the Legislatures of the States concerned as well as of the Congress"; whether consent precedes the act is checked by no stated position (U35) | none stated | none stated | Congress |
| BC19 | The Vice President's tie-breaking vote | B2 control | `constitution-paged.txt:321-322` (p.9, Art. I §3 cl. 4) | the Vice President votes when the Senate is "equally divided" | none stated | none stated | the Vice President; the Senate's President pro tempore acts "in the Absence of the Vice President, or when he shall exercise the Office of President of the United States" (`constitution-paged.txt:324-326` (p.9)) |
| BC20 | The electors' votes and lists | B2 control | `constitution-paged.txt:1014-1023` (p.21, Amdt. XII) | the electors "vote by ballot for President and Vice-President, one of whom, at least, shall not be an inhabitant of the same state with themselves" (their own check), "name in their ballots the person voted for", "make distinct lists ... and of the number of votes for each, which lists they shall sign and certify, and transmit sealed" (RB2, NO1) | the President of the Senate (SP3) | none stated | the electors; the State legislature's manner of appointment (BC21) |
| BC21 | Appointment of electors | B2 control | `constitution-paged.txt:550-555, 589-591` (p.12-13, Art. II §1 cl. 2, 4); `constitution-paged.txt:1614-1626` (p.29, Amdt. XXIII §1) | "Each State shall appoint, in such Manner as the Legislature thereof may direct, a Number of Electors, equal to the whole Number of Senators and Representatives" to which it is entitled; the District appoints "in such manner as the Congress may direct", "in no event more than the least populous State"; Congress may fix the time of choosing and the day of voting; the number and the bar on office holders are checked by no stated position (U29) | none stated | none stated | the State legislatures; Congress for the District |
| BC22 | Writs of election; temporary Senate appointments | B2 control | `constitution-paged.txt:264-266` (p.8, Art. I §2 cl. 4); `constitution-paged.txt:1300-1305` (p.25, Amdt. XVII) | the State's "Executive Authority ... shall issue Writs of Election to fill such Vacancies"; "the legislature of any State may empower the executive thereof to make temporary appointments until the people fill the vacancies by election as the legislature may direct" (DA8, U14) | none stated | none stated | the State executive; the State legislature |
| BC23 | The President's execution, commissioning, convening and adjourning | B2 control | `constitution-paged.txt:654-663` (p.14, Art. II §3) | "he shall take Care that the Laws be faithfully executed, and shall Commission all the Officers of the United States"; may convene the Houses "on extraordinary Occasions" and, on their disagreement "with Respect to the Time of Adjournment", adjourn them (RP4) | Congress ("Information of the State of the Union", SP12) | none stated | the President |
| BC24 | Suspension of habeas corpus | B2 control | `constitution-paged.txt:489-491` (p.11, Art. I §9 cl. 2) | that "Rebellion or Invasion" exists and "the public Safety may require it"; the deciding body is not named (U15) | none stated | none stated | the body that suspends (RP6) |
| BC25 | Guarantee and protection | B2 control | `constitution-paged.txt:759-763` (p.15, Art. IV §4) | the United States "shall guarantee ... a Republican Form of Government", "shall protect each of them against Invasion; and on Application of the Legislature, or of the Executive (when the Legislature cannot be convened) against domestic Violence" (PR2) | none stated | none stated | the applying legislature or executive; the federal positions that respond |
| BC26 | Extradition | B2 control | `constitution-paged.txt:734-738` (p.15, Art. IV §2 cl. 2) | a person "charged in any State with Treason, Felony, or other Crime, who shall flee from Justice" is "on Demand of the executive Authority of the State from which he fled" delivered up (RB12, NO6); whether the demand is checked is not stated (U21) | none stated | none stated | the two States' executives |
| BC27 | Warrants | B2 control | `constitution-paged.txt:907-909` (p.19, Amdt. IV) | "no Warrants shall issue, but upon probable cause, supported by Oath or affirmation, and particularly describing the place to be searched, and the persons or things to be seized"; the issuer is not named (U9) (DA9, NO7) | none stated | none stated | the issuer |
| BC28 | Congress legislating under delegations | B2 control | `constitution-paged.txt:480-483` (p.11, Art. I §8 cl. 18); `constitution-paged.txt:340-344` (p.9, Art. I §4 cl. 1); `constitution-paged.txt:371-372` (p.9, Art. I §6 cl. 1); `constitution-paged.txt:511-512` (p.12, Art. I §9 cl. 7); `constitution-paged.txt:603-607` (p.13, Art. II §1 cl. 6); `constitution-paged.txt:1085-1086` (p.22, Amdt. XIII §2); `constitution-paged.txt:1168-1169` (p.23, Amdt. XIV §5); `constitution-paged.txt:1459-1471` (p.27, Amdt. XX §3-4); `constitution-paged.txt:1741-1742` (p.31, Amdt. XXV §4) | laws "necessary and proper"; election regulations "except as to the Places of chusing Senators" (SE5); compensation; appropriations; succession officers; enforcement legislation; the "other body"; each a document the source refers to but does not contain | the President (presentment, BC3) | none stated | Congress |
| BC29 | Exceptions to appellate jurisdiction | B2 control | `constitution-paged.txt:694-697` (p.14, Art. III §2 cl. 2) | the supreme Court's appellate jurisdiction holds "with such Exceptions, and under such Regulations as the Congress shall make" (SE8) | none stated | none stated | Congress (RP7) |
| BC30 | Enumeration and apportionment | B2 control | `constitution-paged.txt:251-254` (p.8, Art. I §2 cl. 3); `constitution-paged.txt:1128-1131` (p.22, Amdt. XIV §2) | "The actual Enumeration shall be made ... within every subsequent Term of ten Years, in such Manner as they shall by Law direct"; Representatives "apportioned among the several States according to their respective numbers" (RB6); the reduction finding (OC15, U13) | none stated | none stated | Congress's law on the manner |
| BC31 | State judges under the supremacy clause; oaths | B2 control | `constitution-paged.txt:798-807` (p.16, Art. VI cl. 2-3); `constitution-paged.txt:615-619` (p.13, Art. II §1 cl. 8) | "the Judges in every State shall be bound thereby"; legislators and officers "bound by Oath or Affirmation, to support this Constitution"; the President's oath before entering on the office; whether the oath was taken is checked by no stated position (U20) | none stated | none stated | the judges and officers |
| BC32 | Consent to adjournment | B2 control | `constitution-paged.txt:367-369` (p.9, Art. I §5 cl. 4) | "Neither House ... shall, without the Consent of the other, adjourn for more than three days, nor to any other Place"; an adjournment that prevents a presented bill's return removes O1 for it (RP1); whether an adjournment ends the Senate's session for O8 is not settled by the document (RP4) | none stated | none stated | the two Houses |
| BC33 | Full faith and credit, and proof | B2 control | `constitution-paged.txt:725-729` (p.15, Art. IV §1) | "Full Faith and Credit shall be given in each State to the public Acts, Records, and judicial Proceedings of every other State"; proof and effect as "the Congress may by general Laws prescribe" (RB9, U18) | none stated | none stated | Congress's general laws; the receiving State's positions |
| BC34 | War, forces and militia; the Commander in Chief | B2 control | `constitution-paged.txt:458-471` (p.11, Art. I §8 cl. 11-16); `constitution-paged.txt:621-623` (p.13, Art. II §2 cl. 1) | Congress declares war, raises and governs the forces, provides for calling forth the militia; the President commands the Army and Navy, and the Militia "when called into the actual Service of the United States"; the States keep "the Appointment of the Officers, and the Authority of training the Militia according to the discipline prescribed by Congress" | none stated | none stated | Congress, the President, the States |
| BC35 | The Senate's choice of a President pro tempore and officers; the House's Speaker | B2 control | `constitution-paged.txt:268-269` (p.8, Art. I §2 cl. 5); `constitution-paged.txt:324-326` (p.9, Art. I §3 cl. 5) | the Senate chooses a President pro tempore "in the Absence of the Vice President, or when he shall exercise the Office of President"; these two officers receive the inability declarations (SP4) | none stated | none stated | the Houses |
| SP1 | The Journals and the yeas and nays | signal-path device | `constitution-paged.txt:361-365` (p.9, Art. I §5 cl. 3); `constitution-paged.txt:410-412` (p.10, Art. I §7 cl. 2) | carries the proceedings and the names voting; written by each House (U27) | the public, by publication | parts "in their Judgment require Secrecy" are not published (SE1) | BC8 |
| SP2 | The objections on the Journal | signal-path device | `constitution-paged.txt:403-407` (p.10, Art. I §7 cl. 2) | carries the President's objections "at large" to the originating House and, with the bill, to the other House (RB1) | the Houses | none stated | the originating House writes the Journal |
| SP3 | The electors' certified, sealed lists | signal-path device | `constitution-paged.txt:1019-1025` (p.21, Amdt. XII) | carries each State's votes, signed and certified, sealed, "directed to the President of the Senate" (RB2) | the President of the Senate, opened before both Houses | none stated | the electors write; who can alter it after sealing is not settled by the document (U32) |
| SP4 | The written inability declarations | signal-path device | `constitution-paged.txt:1733-1758` (p.31, Amdt. XXV §3-4) | carries the declarations to "the President pro tempore of the Senate and the Speaker of the House of Representatives" (RB3, RB4) | those two officers; Congress | none stated | the writers (BC12, BC13) |
| SP5 | The statement of receipts and expenditures | signal-path device | `constitution-paged.txt:512-514` (p.12, Art. I §9 cl. 7) | "a regular Statement and Account of the Receipts and Expenditures of all public Money shall be published from time to time"; the writer is not named; no later act on it is stated | the public | none stated | the unnamed writer |
| SP6 | The enumeration | signal-path device | `constitution-paged.txt:251-254` (p.8, Art. I §2 cl. 3) | carries the count of persons to apportionment (RB6) | Congress (BC30) | none stated | Congress's law on the manner |
| SP7 | Oaths | signal-path device | `constitution-paged.txt:615-619` (p.13, Art. II §1 cl. 8); `constitution-paged.txt:802-807` (p.16, Art. VI cl. 3); `constitution-paged.txt:329-330` (p.9, Art. I §3 cl. 6) | carries the taker's undertaking; read back by Amendment XIV §3 ("having previously taken an oath", `constitution-paged.txt:1151-1154` (p.23)) (RB11, U20) | none stated | none stated | the taker |
| SP8 | Commissions | signal-path device | `constitution-paged.txt:650-652, 662-663` (p.14, Art. II §2 cl. 3, §3) | carries an officer's appointment; recess commissions expire (O8) (DA2, DA10, NO8) | the officer and whoever honours it (U31) | none stated | the President |
| SP9 | Writs of election | signal-path device | `constitution-paged.txt:264-266` (p.8, Art. I §2 cl. 4); `constitution-paged.txt:1300-1302` (p.25, Amdt. XVII) | carries a vacancy to an election (RB8, NO5) | the State's voters | none stated | the State executive |
| SP10 | State public acts, records and judicial proceedings | signal-path device | `constitution-paged.txt:725-729` (p.15, Art. IV §1) | carries one State's acts to every other (RB9) | the other States | none stated | each State |
| SP11 | Appropriations by law | signal-path device | `constitution-paged.txt:511-512` (p.12, Art. I §9 cl. 7); `constitution-paged.txt:460-461` (p.11, Art. I §8 cl. 12) | carries Congress's authority to draw money to whoever draws it (RB10) | the unnamed drawer (U11) | none stated | Congress |
| SP12 | The Opinion in writing; the State of the Union | signal-path device | `constitution-paged.txt:624-626, 654-656` (p.13-14, Art. II §2 cl. 1, §3) | carries the principal officers' opinions to the President and the President's information to Congress | the President; Congress | none stated | the writers |
| SP13 | Applications and demands by States | signal-path device | `constitution-paged.txt:761-763, 769-770` (p.15, Art. IV §4, Art. V); `constitution-paged.txt:734-738` (p.15, Art. IV §2 cl. 2) | carries a legislature's or executive's application for protection, a legislature's application for a convention, or an executive's demand for a fugitive (RB12, RB13) | the United States; Congress; the other State | none stated | the State positions |
| SP14 | The laws and treaties | signal-path device | `constitution-paged.txt:795-800` (p.16, Art. VI cl. 2) | carries Congress's and the treaty-makers' acts to every judge as "the supreme Law of the Land" (RB14) | the judges (BC31) | none stated | Congress, the President and the Senate |

- **OC3 judges' tenure, corrected.** The judges "shall hold their Offices during good Behaviour"
  (`constitution-paged.txt:674-676` (p.14, Art. III §1)). The observer mapping recorded "removal only on
  impeachment and conviction", citing Art. II §4. That line names "The President, Vice President
  and all civil Officers of the United States" (`constitution-paged.txt:665-668` (p.14)) and
  says they "shall be removed from Office on Impeachment for, and Conviction of" the named
  offences; it does not say "only", and it does not name judges. Whether judges are "civil
  Officers" under Art. II §4 is not settled by the document (U50, new). The House's "sole Power
  of Impeachment" and the Senate's "sole Power to try all Impeachments"
  (`constitution-paged.txt:268-269` (p.8); `constitution-paged.txt:328` (p.9)) name no class of
  persons. The role stays observed component; the hazard and E4 are corrected accordingly.
- **BC1 to BC35** confirmed at the lines the observer mapping cited (`constitution-paged.txt:400-425` (p.10);
  `constitution-paged.txt:630-668` (p.13-14); `constitution-paged.txt:328-369` (p.9);
  `constitution-paged.txt:672-701` (p.14); `constitution-paged.txt:1014-1047` (p.21);
  `constitution-paged.txt:1722-1765` (p.30-31); `constitution-paged.txt:767-787` (p.15-16);
  and the further lines in the observer mapping's table). BC22's temporary appointment remains a B2 control for
  the act of appointing; its end is O11.
- **SP1 to SP14** confirmed as signal-path devices at their lines.

Totals: 12 observers (O1 to O12), 17 observed components, 35 B2 controls, 14 signal-path
devices: 78 entries.

#### Edges and the ring test

| Observer | Checks | Reports to |
|---|---|---|
| O1 | the President's return of a bill (B2, BC1), `constitution-paged.txt:412-415` (p.10) | no observer; the bill's status |
| O2 | the clock, `constitution-paged.txt:1443-1447` (p.27) | no observer; every elected term |
| O3 | the office of President for death, `constitution-paged.txt:1718-1720` (p.30) | no observer; the Vice President |
| O4 | the second declaration (B2, BC13), `constitution-paged.txt:1752-1758` (p.31) | no observer; the President or Congress |
| O5 | Congress's determination (B2, BC13), `constitution-paged.txt:1760-1765` (p.31) | no observer; the President or the Vice President |
| O6 | the President elect's death, `constitution-paged.txt:1453-1455` (p.27) | no observer; the Vice President elect |
| O7 | the choice and qualification of a President, `constitution-paged.txt:1455-1459` (p.27) | no observer; the Vice President elect |
| O8 | the Senate's session, `constitution-paged.txt:650-652` (p.14) | no observer; the commissioned officer |
| O9 | an election of Representatives, `constitution-paged.txt:1858-1860` (p.32) | no observer; the pay law |
| O10 | the President's inability, `constitution-paged.txt:600-603` (p.13) | no observer; the Vice President |
| O11 | the election that fills a Senate vacancy, `constitution-paged.txt:1302-1305` (p.25) | no observer; the temporary appointee |
| O12 | the disability's removal, an election or a qualification, `constitution-paged.txt:606-607` (p.13); `constitution-paged.txt:1462-1464` (p.27) | no observer; the acting officer |

Confirmed: no observer reads another observer's state, and none reports to one. Each watches a
position's act or inaction, an office's state, an event or the clock. The touches the observer mapping named
hold as shared inputs, not observation: O4 and O5 read the same declaration path in sequence
(`constitution-paged.txt:1749-1767` (p.31)); O6, O7 and O2 read the same time
(`constitution-paged.txt:1443-1459` (p.27)). The added touches are of the same kind: O7's end
and O12's second passage read the same qualification (`constitution-paged.txt:1458-1464`
(p.27)); O3 and O10 land on the same recipient (`constitution-paged.txt:600-603` (p.13);
`constitution-paged.txt:1718-1720` (p.30)). None carries one observer's output into another's
input.

| Requirement | Present? | Evidence (file:line) |
|---|:---:|---|
| A cycle of at least three mutual observers | no | confirmed: the twelve edges above all end at a position or an object |
| Each observer checks one, reports to a different one | no | confirmed: every observer's effect is its only signal (`constitution-paged.txt:415` (p.10); `constitution-paged.txt:1447` (p.27); `constitution-paged.txt:1719-1720` (p.30); `constitution-paged.txt:1751-1752, 1766-1767` (p.31)) |
| One +1 that checks all observers including itself | no | confirmed: no mechanism reads any other |
| Nested rings, where the structure needs them | no (no base ring) | confirmed |

**Shape: isolated spokes.** Confirmed. Twelve mechanisms, each a single observer on one B2
position, one office, one event or the clock, with no edge to any other mechanism. The added
observers change the count, not the shape.

#### Execution-observation coupling

Confirmed. Execution checks no heartbeat and stops when none stops. The executive power runs for
a term (`constitution-paged.txt:545-548` (p.12)) until O2, O3, O10, a declaration, a removal or a resignation (`constitution-paged.txt:1718-1720` (p.30)) ends or
transfers it, and each transfer hands the same execution to a deputy or successor (C2, C9). The
legislative power runs between fixed assembly dates (`constitution-paged.txt:1449-1451` (p.27)),
a periodic proof. The judicial power runs "during good Behaviour"
(`constitution-paged.txt:674-676` (p.14)) with no stated signal. The appropriation gate
(`constitution-paged.txt:511-512` (p.12)) defaults to stopped but names no reader (U11). O8, O9,
O11 and O12 each couple one authority or one law to one event, locally. The observer mapping's statement that
no execution path is stated to stop when an observer is absent, suspended or reset holds at the
lines: where RP1 removes O1 or RP9 keeps it from starting, the bill does not become law
(`constitution-paged.txt:400-402, 415-417` (p.10)), but the position O1 watches, the President's
handling of the bill, runs on and gains the effect of a defeat; RP2, RP4, RP8 and RP12 leave the
execution they bear on running.

### Coordinators and super-rings

| Candidate | Can stop what | Checks every observer | Takes reports back | Surface check | In the ring | Result |
|---|---|:---:|:---:|:---:|:---:|---|
| O2, the fixed term ends, `constitution-paged.txt:1443-1447` (p.27) | every elected term that ends on its day | no: reads the clock | no | yes: the date only | yes (an observer) | fails; confirmed |
| Congress, `constitution-paged.txt:665-668` (p.14); `constitution-paged.txt:511-512` (p.12); `constitution-paged.txt:415-417` (p.10); `constitution-paged.txt:1760-1765` (p.31) | officers by impeachment and conviction; spending by withholding appropriations; a presented bill by an adjournment that prevents its return; the President's resumption by a two-thirds determination | no | partly: the declarations (SP4) and objections (SP2), none from a mechanism | no | no: B2 | fails; confirmed |
| The President, `constitution-paged.txt:402-405` (p.10); `constitution-paged.txt:657-660` (p.14); `constitution-paged.txt:1749-1752` (p.31) | a bill by return; the Houses' sitting by adjournment on disagreement; the acting by a contrary declaration | no | no | no | no: B2 | fails; confirmed |
| The Vice President with a majority of the principal officers, `constitution-paged.txt:1740-1747` (p.31) | the President's exercise of the powers | no | no | no | no: B2 | fails; confirmed |
| The courts, `constitution-paged.txt:672-697` (p.14) | an act before them in a case | no | no | no | no: B2 | fails; confirmed |
| The State legislatures or conventions, `constitution-paged.txt:779-783` (p.16); `constitution-paged.txt:550-553` (p.12) | amendment by withholding ratification; the choice of electors; the election ending a temporary appointment (`constitution-paged.txt:1302-1305` (p.25)) | no | no | no | no: B2 | fails; confirmed |
| The people as voters and the electors, `constitution-paged.txt:235-239` (p.8); `constitution-paged.txt:1294-1298` (p.25); `constitution-paged.txt:1014-1023` (p.21) | a holder's next term, at the election | no | no | no | no: B2 | fails; confirmed |
| The Senate alone, `constitution-paged.txt:630-646` (p.13-14); `constitution-paged.txt:328-332` (p.9) | an appointment or treaty by refusal; a removal by conviction | no | no | no | no: B2 | fails; confirmed |

No candidate passes. No layer above the observers exists, no super-ring forms, and the structure
does not close. O2 remains a passive, periodic reset that reads only the date.

---

## The structure against the model, property by property

### Observer groups

The six groups the gap evaluation formed are kept; the added observers join the groups whose subsystem
their effect acts on.

| Group | Observers | What the group watches |
|---|---|---|
| GR1 Lawmaking | O1 | the President's return of a presented bill within ten days, `constitution-paged.txt:412-417` (p.10) |
| GR2 Terms | O2 | the clock against the fixed days, `constitution-paged.txt:1443-1447` (p.27) |
| GR3 Succession and inability | O3, O4, O5, O10 (new) | death; the four-day and twenty-one-day windows; an inability no declaration reaches, `constitution-paged.txt:600-603` (p.13); `constitution-paged.txt:1718-1720` (p.30); `constitution-paged.txt:1749-1767` (p.31) |
| GR4 The time fixed and the acting offices | O6, O7 [corrected], O12 (new) | the President elect's death; a President not chosen or not qualified, and the qualification that ends the acting; the ends of an acting officer's service, `constitution-paged.txt:606-607` (p.13); `constitution-paged.txt:1453-1464` (p.27) |
| GR5 Interim authority expiries | O8, O11 (new) | the end of the Senate's next session; the election that fills a Senate vacancy, `constitution-paged.txt:650-652` (p.14); `constitution-paged.txt:1302-1305` (p.25) |
| GR6 Pay-law deferral | O9 | an election of Representatives intervening, `constitution-paged.txt:1858-1860` (p.32) |

### The scorecard

| Group | 1 HB | 2 Sub | 3 CSV | 4 SWR | 5 SD | 6 Death | 7 AutoInt | 8 Reflex |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| GR1 Lawmaking (O1) | G | G | G | G | G | G | G [corrected] | G |
| GR2 Terms (O2) | G | G | G | G | G [corrected] | G | G | G |
| GR3 Succession and inability (O3, O4, O5, O10) | G | G | G | G | G | G | G | G |
| GR4 The time fixed and the acting offices (O6, O7, O12) | G | G | G | G | G [corrected] | G | G | G |
| GR5 Interim authority expiries (O8, O11) | G | G | G | G | G | G | S | G |
| GR6 Pay-law deferral (O9) | G | G | G | G | G [corrected] | G | S | G |

**Totals:** 46 G, 2 S, 0 N/A over 48 cells (the gap evaluation: 42 G, 6 S). Four cells corrected from S to
G; no G cell was found to be S.

### Evidence per verdict

- **1 Heartbeat: G in every group, confirmed.** No mechanism emits a continuous proof of its
  operation whose stop is an alarm. O1 runs only once a bill is presented, by a presenter and at
  a time not named (`constitution-paged.txt:400-402` (p.10), U1). O2 reads a date
  (`constitution-paged.txt:1443-1447` (p.27)). O3 and O10 give no signal until a death or an
  inability, and their recognisers are not stated (`constitution-paged.txt:1718-1720` (p.30), U2;
  `constitution-paged.txt:600-603` (p.13), U48). O4 and O5 run only inside windows a declaration
  opens (`constitution-paged.txt:1749-1767` (p.31)). O6, O7 and O12 act at an instant or on an
  event (`constitution-paged.txt:1453-1464` (p.27); `constitution-paged.txt:606-607` (p.13)). O8
  and O11 wait for a session's end or an election (`constitution-paged.txt:651-652` (p.14);
  `constitution-paged.txt:1302-1305` (p.25)); O9 waits for an election
  (`constitution-paged.txt:1858-1860` (p.32)). For the institution, Congress proves its operation
  once a year (`constitution-paged.txt:1449-1451` (p.27)), a periodic proof.
- **2 Substrate dependency: G in every group, confirmed.** No mechanism shares the failure
  substrate of what it watches. O1's ten days run whether or not the office of President is held
  (`constitution-paged.txt:412-415` (p.10)). O2's date arrives whatever the offices' state. O4 and
  O5 depend on the two officers receiving the declarations
  (`constitution-paged.txt:1742-1744, 1749-1751, 1755-1756` (p.31)), the Houses' substrate, not the President's. O8 shares the Senate's
  substrate in the direction that prolongs the authority: a session that does not end leaves the
  commission running (`constitution-paged.txt:651-652` (p.14)); O11 depends in the same way on an
  election the legislature directs (`constitution-paged.txt:1302-1305` (p.25)). O6, O7, O9, O10
  and O12 read a date, an event or the President's state, nothing of their own effect's
  recipient.
- **3 Continuous state verification: G in every group, confirmed.** Every mechanism but O10
  reads an event or a date. O10 alone names a state ("Inability to discharge the Powers and
  Duties", `constitution-paged.txt:600-603` (p.13)), and no line names who compares the
  President's state against it or when (U48), so no comparison is stated to run continuously. A
  departure that persists after its act (a holder past the term, an appointee past the election
  that ends the appointment, money drawn without an appropriation) is found by no mechanism
  (`constitution-paged.txt:1443-1447` (p.27), U30; `constitution-paged.txt:1302-1305` (p.25),
  U14; `constitution-paged.txt:511-512` (p.12), U11).
- **4 System-wide response: G in every group, confirmed.** No observer's effect reaches another
  observer; each lands on a position or object (`constitution-paged.txt:415` (p.10);
  `constitution-paged.txt:1447` (p.27); `constitution-paged.txt:1719-1720` (p.30);
  `constitution-paged.txt:1751-1752, 1766-1767` (p.31); `constitution-paged.txt:652` (p.14);
  `constitution-paged.txt:1860` (p.32); `constitution-paged.txt:602-603, 606-607` (p.13)). A
  violation one branch finds reaches another only through positions (the House's impeachment,
  `constitution-paged.txt:268-269` (p.8); the Senate's trial, `constitution-paged.txt:328-332`
  (p.9)), each B2.
- **5 Self-defense: G in every group (GR2, GR4, GR6 corrected from S).** GR1, GR3 and GR5 are
  confirmed at the gap evaluation's lines: O1 is removed for a bill by the adjournment
  (`constitution-paged.txt:415-417` (p.10), RP1) and never starts where presentment is withheld
  (`constitution-paged.txt:400-402` (p.10), RP9); O4 and O5 lose the maker of their input by the
  Vice President's non-participation or a vacancy (`constitution-paged.txt:1740, 1752-1753`
  (p.31); `constitution-paged.txt:1722` (p.30), RP12) and Congress by law substitutes "such other
  body" (`constitution-paged.txt:1741-1742, 1753-1754` (p.31), RP2); O8 fires at the session's end, and whether the Houses' or
  the President's adjournment ends the session is not settled by the document (`constitution-paged.txt:367-369` (p.9);
  `constitution-paged.txt:657-660` (p.14), RP4); O11 fires when the election the legislature
  directs is held, and the executive issues the writ with no time fixed
  (`constitution-paged.txt:1300-1305` (p.25)). For GR2, GR4 and GR6 the gap evaluation scored S because the
  dates and conditions change only by amendment, which needs two thirds of both Houses or a
  convention and three fourths of the States (`constitution-paged.txt:767-787` (p.15-16)). Tested
  against the model: the model states that "a pure observer satisfies system-wide response,
  self-defense and reflexive response through its place in a ring", and its method that
  "an observer that cannot is showing the missing ring, so score that as a gap, not an
  exemption". No ring exists. The model's institutional reading ("Removing a check
  on power needs acts across several independent trust boundaries") describes what an observer
  over the institution would have to do and keeps the bar: "a person or a body that does any of
  these is a B2 control and discharges nothing". The amendment rule's resistance is the votes of
  the Houses, State legislatures and conventions, every one a B2 position inside the one B2 boundary the model defines, counted by no named position (U19); it discharges no property.
  "A deliberate refusal is not a gap" concerns a structure declining an unsafe act, and the
  institutional reading's refusal clause is stated for automatic integration only. The model and its method govern, the institutional reading agreeing: G. For GR6 the condition's release
  may also rest on one position: whether an election to fill one vacancy, ordered by one State
  executive's writ (`constitution-paged.txt:264-266` (p.8)), is "an election of Representatives"
  for `constitution-paged.txt:1858-1860` (p.32) is not settled by the document (U24).
- **6 Death signaling: G in every group, confirmed.** When a mechanism stops (O1 removed by
  adjournment, O4 and O5 without a maker, O8 or O11 held open by a session or an election not
  held), nothing is stated to cross into an independent institution and be acted on there. The only
  records the text says are published are the Journals, written by each House (`constitution-paged.txt:361-365` (p.9), U27), and the
  statement of accounts, whose writer is not named (`constitution-paged.txt:512-514` (p.12)).
- **7 Automatic integration: G in GR1 [corrected], GR2, GR3 and GR4; S in GR5 and GR6.** The
  property is not among the three the model says a ring place discharges, so an isolated observer
  can satisfy it, and the institutional reading takes it as a new part being "under the existing checks
  from the moment it exists". GR1, corrected: a passed bill, order, resolution or vote enters O1's
  window only "after it shall have been presented to him" (`constitution-paged.txt:413-414`
  (p.10)), and presentment is a step by a position the text does not name, at no fixed time
  (`constitution-paged.txt:400-402, 419-422` (p.10), U1); until a person presents it, the new
  part is unwatched by O1, the gap the institutional reading names. Whether O1's default reaches
  orders, resolutions and votes at all is not settled (U49, SS1). GR5, confirmed: every recess
  commission carries its expiry from the moment it is granted (`constitution-paged.txt:650-652`
  (p.14)), and every temporary appointment carries its end from the moment it is made
  (`constitution-paged.txt:1302-1305` (p.25)); no person's step stands between the new part and
  its observer. Whether a given commission fills a vacancy that "may happen during the Recess" is recognised by no
  stated position (U22), a gap carried by E20, not by this property. GR6, confirmed: "No law,
  varying the compensation" is deferred from the moment it is made
  (`constitution-paged.txt:1858` (p.32)). GR2, GR3 and GR4 confirmed at the gap evaluation's lines: offices
  "established by Law" (`constitution-paged.txt:645-646` (p.14)), the body Congress provides
  (`constitution-paged.txt:1741-1742` (p.31)) and the judges (`constitution-paged.txt:674-676`
  (p.14)) come under no term end the text states; O3 and O10 read "the President" only, and the Acting President
  is under no transfer on his own death or resignation, the case of "both" going to a law
  (`constitution-paged.txt:603-607` (p.13)); the Vice President elect who acts is under no
  mechanism on his own death, and whether that case is one where "neither a President elect nor a Vice President elect shall have qualified", which goes to a law
  (`constitution-paged.txt:1459-1464` (p.27)), is not settled by the document (U6). Adding a new mechanism needs the amendment rule
  (`constitution-paged.txt:767-787` (p.15-16)), broad agreement, which the institutional reading
  records as a refusal, not this gap.
- **8 Reflexive response: G in every group, confirmed.** O8, O9, O11, O12 and O7's end halt
  one authority or law, and O2 every elected term that ends on its day (H4), with no deliberation, and no halt is stated to reach two other mechanisms;
  what stops a holder continuing past an end is not stated (U30, U14, U6). O1, O3, O4, O5, O6,
  O7's start and O10 continue through the fault (C1 to C4, C9; O6's path held by no C id). O4 and O5 return the powers after
  a window in which "Congress shall decide the issue" (`constitution-paged.txt:1758` (p.31)): up
  to four days, then forty-eight hours to assemble if Congress is not in session, and twenty-one days to decide
  (`constitution-paged.txt:1755-1762` (p.31)), a deliberation window open to the violator.

The gaps the missing ring predicts (no cycle of three: 4, 5, 6; no +1: reliance on an external
authority) appear in every group: every group scores G on 4, 5 and 6. The required response
under halt on fault, for every G: the observer alerts and the system halts until the fault
clears or the privileged actor leaves. The text's responses instead halt one bill, authority or law, or the elected terms that end on one day (H1 to H7), none stated to reach another mechanism, or serve through the fault by a
successor, a deputy or a default (C1 to C4, C9).

---

## Missing structural components

Four of the five structural components are absent in every subsystem and the fifth, a halt path with propagation, is partly present, confirmed at the lines:

- **A mutual-observation cycle.** Absent. No mechanism reads another (The architectural model).
- **A coordinator.** Absent. No mechanism surface-checks the others; O2 resets every elected
  position at a fixed time (`constitution-paged.txt:1443-1447` (p.27)) and reads only the date.
- **Check and report separation.** Absent. Every observer's effect is its only output and lands
  on the position or object it acted on (`constitution-paged.txt:415` (p.10);
  `constitution-paged.txt:652` (p.14); `constitution-paged.txt:1858-1860` (p.32)).
- **A halt path with propagation.** Partly present. O2 halts every elected term that ends on its day (H4).
  O8, O9, O7's end, O11 and O12 halt one authority or law each (H1, H2, H5, H6, H7), reaching no
  other node. No halt is stated to reach two other mechanisms.
- **An upward chain.** Absent.

### Hazards and their observers

| Component | Hazardous state, in the source's words | Evidence | Observer that checks it against known-good |
|---|---|---|---|
| OC1 assembly date | the Congress not assembled "at least once in every year", or the meeting not begun "at noon on the 3d day of January" where no law appoints "a different day" | `constitution-paged.txt:1449-1451` (p.27) | none: the President "may, on extraordinary Occasions, convene both Houses" (`constitution-paged.txt:657` (p.14), BC23) |
| OC2 terms of office | a holder continuing after the term "shall end" | `constitution-paged.txt:1443-1447` (p.27) | O2 ends the term; what stops the holder is not stated (U30) |
| OC3 judges' tenure [corrected] | a judge holding other than "during good Behaviour" | `constitution-paged.txt:674-676` (p.14) | none; whether Art. II §4's removal reaches judges is not settled (U50); impeachment (BC5) is a person's check |
| OC4 army-appropriation cap | an appropriation "for a longer Term than two Years" | `constitution-paged.txt:460-461` (p.11) | none (U11) |
| OC5 Treasury draw bar | money "drawn from the Treasury" other than "in Consequence of Appropriations made by Law" | `constitution-paged.txt:511-512` (p.12) | none (U11); SP5 publishes after |
| OC6 compensation bars | the President's compensation "encreased nor diminished during the Period"; any "other Emolument from the United States, or any of them" within that Period; judges' compensation "diminished during their Continuance in Office" | `constitution-paged.txt:609-613` (p.13); `constitution-paged.txt:676-678` (p.14) | none |
| OC7 eligibility bars | a person holding a seat or office below the age, citizenship or residence; elected "more than twice"; one who "engaged in insurrection or rebellion" after "having previously taken an oath" as a member or officer "to support the Constitution of the United States" | `constitution-paged.txt:241-244` (p.8); `constitution-paged.txt:316-319` (p.9); `constitution-paged.txt:593-598` (p.13); `constitution-paged.txt:1558-1562` (p.28); `constitution-paged.txt:1148-1156` (p.23) | none: BC6 for members, a person's; for the President, Vice President and electors no judge is named (U12) |
| OC8 incompatibility and emoluments bars | an office holder "a Member of either House"; a present or emolument "from any King, Prince, or foreign State" accepted "without the Consent of the Congress"; a Senator, Representative or office holder "appointed an Elector" | `constitution-paged.txt:393-394` (p.10); `constitution-paged.txt:516-520` (p.12); `constitution-paged.txt:553-555` (p.12) | none: BC6 for members; for electors none (U29) |
| OC9 quorum rules | business without "a Majority of each"; a contingent choice without its quorum | `constitution-paged.txt:351-352` (p.9); `constitution-paged.txt:1033-1035, 1044-1047` (p.21) | none: each House counts (BC6) |
| OC10 the Vice President's conditional vote | a vote cast when the Senate is not "equally divided" | `constitution-paged.txt:321-322` (p.9) | none |
| OC11 supremacy clause | a State judge giving effect to "any Thing in the Constitution or Laws of any State to the Contrary" | `constitution-paged.txt:798-800` (p.16) | none: BC9, a person's |
| OC12 habeas, attainder, ex post facto, treason | the writ suspended other than "when in Cases of Rebellion or Invasion the public Safety may require it"; a bill of attainder or ex post facto law "passed"; a treason conviction without "two Witnesses to the same overt Act, or on Confession in open Court" | `constitution-paged.txt:489-492` (p.11); `constitution-paged.txt:715-717` (p.15) | none: BC9; the suspending body not named (U15) |
| OC13 State bars | a State's imposts or duties on imports or exports, duty of tonnage, troops or ships of war in time of peace, or compact "without the Consent of the Congress"; a State at war without that consent when not "actually invaded, or in such imminent Danger as will not admit of delay" | `constitution-paged.txt:529-541` (p.12) | none: BC18, BC9 (U34, U35) |
| OC14 rights of persons | a law "respecting an establishment of religion", "abridging the freedom of speech"; "unreasonable searches and seizures"; deprivation "without due process of law"; the vote "denied or abridged" "on account of race, color, or previous condition of servitude" | `constitution-paged.txt:885-889, 905-907` (p.19); `constitution-paged.txt:943-945` (p.20); `constitution-paged.txt:1123-1124` (p.22); `constitution-paged.txt:1212-1214` (p.24) | none: BC9, BC28 |
| OC15 representation reduction | the vote "denied ... or in any way abridged", other than "for participation in rebellion, or other crime", with the basis not "reduced in the proportion" | `constitution-paged.txt:1131-1146` (p.22-23) | none (U13) |
| OC16 electoral majority rule | a person treated as President without "a majority of the whole number of Electors appointed" | `constitution-paged.txt:1025-1028` (p.21) | none: BC10, a person's; denominator's source not stated (U7) |
| OC17 the offices and the work [corrected] | the President "unable to discharge the powers and duties of his office"; the President elect "failed to qualify"; vacancies in either House; "a vacancy in the office of the Vice President"; recess vacancies; the laws not "faithfully executed"; "Treason, Bribery, or other high Crimes and Misdemeanors"; "Insurrections", "Invasions", "domestic Violence" | `constitution-paged.txt:1735, 1744-1745` (p.31); `constitution-paged.txt:1457` (p.27); `constitution-paged.txt:264` (p.8); `constitution-paged.txt:1300` (p.25); `constitution-paged.txt:1722-1723` (p.30); `constitution-paged.txt:650-651` (p.14); `constitution-paged.txt:661-662, 667-668` (p.14); `constitution-paged.txt:466` (p.11); `constitution-paged.txt:763` (p.15) | the inability: O10 for an inability no declaration reaches, its recogniser not stated (U48); O4 and O5 act on declarations only; the President elect's death O6; not chosen or not qualified O7, and its end O7; a recess vacancy: O8 ends the commission, no observer of the vacancy stated; a Senate vacancy filled by temporary appointment: O11 ends it; the rest none: BC22, BC14, BC23, BC5, BC25, BC34 |
| OC18 bars on Congress's acts (new) | "all Duties, Imposts and Excises shall be uniform throughout the United States"; "No Tax or Duty shall be laid on Articles exported from any State"; no preference "by any Regulation of Commerce or Revenue" to the ports of one State, and no vessel bound to or from one State "obliged to enter, clear, or pay Duties in another"; "No Title of Nobility shall be granted by the United States"; revenue bills "shall originate in the House"; forfeiture on an attainder of treason only "during the Life of the Person attainted"; the electors' day "the same throughout the United States"; "no religious Test shall ever be required as a Qualification to any Office or public Trust under the United States" | `constitution-paged.txt:430-431` (p.10); `constitution-paged.txt:496-497` (p.11); `constitution-paged.txt:498-499` (p.11); `constitution-paged.txt:508-509` (p.12); `constitution-paged.txt:516` (p.12); `constitution-paged.txt:396-398` (p.10); `constitution-paged.txt:720-721` (p.15); `constitution-paged.txt:589-591` (p.13); `constitution-paged.txt:806-807` (p.16) | none |
| OC19 the public debt (new) | the validity of the public debt "authorized by law" "shall not be questioned", and "neither the United States nor any State shall assume or pay any debt or obligation incurred in aid of insurrection or rebellion against the United States" | `constitution-paged.txt:1159-1164` (p.23) | none |

### Read-backs

Provenance is who wrote the object as the store itself records it, or a signature or MAC under a
key only the writer (and, for a MAC, the reader) holds; an owner field or label a writer can set
is content, unless the store forces it to match the writer on every write. Shape is whether the
object's content matches what the system's own writer produces, or, where nothing in the system
writes it, the format the reader parses. Write access the store enforces is listed as who can
write it, not as a provenance check, while a schema the store enforces on every write is a shape
check.

All fourteen confirmed at their lines. No read-back has a stated provenance check (14) or a
stated shape check (14); five hold a pair with no binding check (RB2, RB3, RB4, RB8, RB12). The
"sign and certify", seals, oaths and attestations the text names are marks the writer places,
content under the model's rules. For RB8 and RB12 the only writer the lines show is the named
authority itself (the State's "Executive Authority", `constitution-paged.txt:264-266` (p.8);
the "executive Authority of the State from which he fled", `constitution-paged.txt:736-737`
(p.15)), so for that writer the gain is past the authority's own restriction ("When vacancies
happen"; "charged ... who shall flee from Justice"), held with the pair in one row as the judging rule "Identity is not authority" provides; for any other writer the pair is
unbound with the writers not stated (U41, U21). T3 and E46 stand as filed.

| # | Object and store | Read at | Who can write the store | Provenance check | Shape check | What is applied | What a value outside the writer's format reaches | Row |
|---|---|---|---|---|---|---|---|---|
| RB1 | the objections entered "at large" on the originating House's Journal | `constitution-paged.txt:404-408` (p.10) | the House (`constitution-paged.txt:361` (p.9)); others not stated (U27) | none stated | none stated; BC2 counts as none | the objections and the bill | objections not the President's, or a bill not the one presented, reach the two-thirds votes (U26) | T1 |
| RB2 [corrected] | the electors' lists, signed, certified, "transmit sealed" | `constitution-paged.txt:1023-1025` (p.21); read again by the House, "from the persons having the highest numbers not exceeding three on the list" (`constitution-paged.txt:1028-1030` (p.21)), and by the Senate, "from the two highest numbers on the list" (`constitution-paged.txt:1043-1044` (p.21)), with no check stated at either read | the electors (`constitution-paged.txt:1019-1021` (p.21)); after sealing not stated (U32); the District's electors, who "perform such duties as provided by the twelfth article" (`constitution-paged.txt:1624-1626` (p.29)) | none stated (U32) | none stated (U7, U8); BC20 counts as none | the names and numbers, to OC16 | the count and the office; bypasses BC20; unbound: the votes under the State's appointed electors | E1 |
| RB3 | the President's §3 declarations and his §4 declaration "that no inability exists" | `constitution-paged.txt:1736-1738, 1749-1752` (p.31) | the President; others not stated (U3) | none stated | none stated | the whole declaration | the transfer or its return; unbound: the finding under the President's authority | S1 |
| RB4 | the §4 declarations of the Vice President and a majority | `constitution-paged.txt:1745-1747, 1752-1758` (p.31) | the Vice President and the majority; others not stated (U4) | none stated | none stated (U4) | the whole declaration | the transfer; unbound: the finding under the named body's authority | S2 |
| RB5 | Congress's two-thirds determination, in each Journal | `constitution-paged.txt:1760-1765` (p.31) | each House; U27 | none stated | none stated; BC6 counts as none | the determination | the Vice President's continuing or the President's resumption (U5) | S4 |
| RB6 | the enumeration | `constitution-paged.txt:1128-1131` (p.22); `constitution-paged.txt:493-495` (p.11); `constitution-paged.txt:551-553` (p.12) | the position Congress's law directs (U40) | none stated | none stated | "their respective numbers" | the apportionment of Representatives and of electors | T2 |
| RB7 | a recess commission | `constitution-paged.txt:650-652` (p.14) | the President | none stated | none stated (U22) | the office's authority until O8 | a commission outside the recess carries the same authority (U22) | E20 |
| RB8 | a writ of election | `constitution-paged.txt:264-266` (p.8); `constitution-paged.txt:1300-1302` (p.25) | the State's executive authority; others not stated (U41) | none stated | none stated; BC6 after | the vacancy and the election | a writ for a seat not vacant; unbound: the vacancy under the State's authority | T3 |
| RB9 | another State's "public Acts, Records, and judicial Proceedings" | `constitution-paged.txt:725-727` (p.15) | each State | none stated (U18) | none stated | "Full Faith and Credit", with "the Effect thereof" as Congress's general laws prescribe (`constitution-paged.txt:727-729` (p.15)) | full faith and credit for an act not the State's (U18) | S5 |
| RB10 | "Appropriations made by Law" at the draw | `constitution-paged.txt:511-512` (p.12) | Congress | none stated (U11) | none stated (U11) | the authority to draw | a draw without or beyond an appropriation | T5 |
| RB11 | the oath or affirmation | `constitution-paged.txt:615-616` (p.13); `constitution-paged.txt:802-805` (p.16); `constitution-paged.txt:1151-1154` (p.23) | the taker | none stated | none stated (U20) | entry on the office; the disability | entry without the oath; a disability on an unverified record | E44 |
| RB12 | the extradition demand | `constitution-paged.txt:736-738` (p.15) | the demanding executive; others not stated (U21) | none stated | none stated (U21) | delivery of the person | delivery of a person not charged or not fled; unbound: the person under the demanding executive's authority | E46 |
| RB13 | applications and ratifications of the States | `constitution-paged.txt:769-770` (p.15); `constitution-paged.txt:779-783` (p.16) | the State legislatures or conventions; others not stated (U19) | none stated | none stated (U19) | the call; validity | an act not a legislature's counts toward two thirds or three fourths | T4 |
| RB14 | the laws and treaties the judges read | `constitution-paged.txt:795-800` (p.16) | Congress and the President; the President and the Senate; custodian not stated (U42) | none stated | none stated; BC9, BC31 count as none | the law or treaty | a text not made as required binds the judges | S6 |

### Deputies and mints

A deputy is a component acting for another position, and a mint is a place authority is created
or handed on. Every mint, and every deputy whose next check sees only its own identity, or the
requester's identity without every restriction on the requester, needs a check that keeps it
within the requester's or the minter's authority, every restriction on the requester's or the
minter's credential included.

Twenty-five rows over twenty-two components: twenty confirmed at their lines by the first verification, and DA21 to DA25 added by the chain verification; four rows corrected because an
observer added or confirmed in the architectural model reads one of their restrictions. The last column gives
the STRIDE id of the row that holds the pair (where the input names the authority) or the gap.

| # | Kind | Component | Credential and restrictions | Check that binds it | Row |
|---|---|---|---|---|---|
| DA1 | mint | appointment with advice and consent, `constitution-paged.txt:632-646` (p.13-14) | the President with the Senate's vote; offices "established by Law", the bars (OC7, OC8), the insurrection disability | BC4, a person's; none stated machine (U12); later reduction not stated (U10) | E19 |
| DA2 | mint | recess commissions, `constitution-paged.txt:650-652` (p.14) | the President alone; "Vacancies that may happen during the Recess" | the expiry is read by O8; the recess-vacancy restriction by none stated (U22) | E20 (RB7) |
| DA3 | mint of minting authority | vesting inferior appointments, `constitution-paged.txt:646-648` (p.14) | Congress by law; "such inferior Officers" | none stated (U16); repeal not stated (U10) | E21 |
| DA4 | deputy | the Vice President as Acting President on §3, `constitution-paged.txt:1733-1738` (p.31) | the office of Vice President with RB3; "until he transmits ... to the contrary" | none stated (U3); acts taken after resumption not stated (U37) | S1 (RB3) |
| DA5 [corrected] | deputy | the Vice President as Acting President on §4, `constitution-paged.txt:1740-1747, 1764-1765` (p.31) | the office of Vice President with RB4; the four-day and twenty-one-day windows; "a majority" | the windows are read by O4 and O5 (observers); the majority by none stated (U4) | S2 (RB4) |
| DA6 [corrected] | deputy | the officer named by law to act as President, `constitution-paged.txt:603-607` (p.13); `constitution-paged.txt:1459-1464` (p.27) | a law (not available); "until the Disability be removed, or a President shall be elected"; "until a President or Vice President shall have qualified" | the ends are read by O12 by the text's terms, recogniser not stated (U6); that the officer is the one the law names: none stated | E22 |
| DA7 [corrected] | deputy | the Vice President elect acting as President, `constitution-paged.txt:1455-1459` (p.27) | chosen by the count (BC10) or the Senate (BC11); "until a President shall have qualified" | the start and the end are read by O7 by the text's terms, recogniser not stated (U6) | E23 |
| DA8 [corrected] | mint | the temporary Senate appointment, `constitution-paged.txt:1302-1305` (p.25) | the legislature's empowerment (not available) and the executive; "until the people fill the vacancies by election" | the end is read by O11, recogniser not stated (U14); the empowerment by no stated check but BC6, a person's (U14) | E24 (empowerment), E25 (end) |
| DA9 | mint | warrants, `constitution-paged.txt:907-909` (p.19) | the affiant and an unnamed issuer (U9); "probable cause", "particularly describing" | BC27, a person's; none stated machine (U9) | E16 |
| DA10 | mint | commissions, `constitution-paged.txt:662-663` (p.14) | the President, following an appointment | none stated (U31); later reduction not stated (U10) | E26 |
| DA11 | mint | State electors, `constitution-paged.txt:550-555` (p.12) | a legislature's direction (not available); the number; the bar on office holders; the day Congress fixes (`constitution-paged.txt:589-591` (p.13)) | none stated (U29, U7); changed direction not stated (U38) | E27 (RB2 pair held by E1) |
| DA12 | mint | the District's electors, `constitution-paged.txt:1614-1626` (p.29) | a law (not available); "in no event more than the least populous State" | none stated (U29) | E28 |
| DA13 | mint | laws "necessary and proper", `constitution-paged.txt:480-483` (p.11) | Congress with presentment; "necessary and proper" | BC9, a person's; none stated machine (U43) | E29 |
| DA14 | mint | treaties, `constitution-paged.txt:630-632` (p.13) | the President with two thirds of the Senators present; "under the Authority of the United States" (`constitution-paged.txt:796-797` (p.16)) | BC4, BC31, persons'; none stated machine (U44) | E30 (RB14 held by S6) |
| DA15 | mint | reprieves and pardons, `constitution-paged.txt:627-628` (p.13) | the President; "Offences against the United States, except in Cases of Impeachment" | none stated (U33) | E31 |
| DA16 | mint | Congress's consents, `constitution-paged.txt:516-520, 529-541` (p.12) | a consent (not available); the Treasury's "net Produce"; "absolutely necessary" | none stated (U35, U34) | E7, E13, E14, E15 |
| DA17 | mint | removal of the insurrection disability, `constitution-paged.txt:1156-1157` (p.23) | two thirds of each House; "such disability" | BC17, a person's; none stated machine (U45) | E32 |
| DA18 | mint | amendments, `constitution-paged.txt:767-787` (p.15-16) | two thirds of both Houses or a convention, three fourths of the States; the equal-suffrage proviso | BC15, persons'; none stated machine (U19) | E33 (RB13 held by T4) |
| DA19 | mint | the judgment on impeachment, `constitution-paged.txt:334-338` (p.9) | two thirds "of the Members present" (`constitution-paged.txt:331-332` (p.9)); "shall not extend further than" | BC5, a person's; none stated machine (U46) | E34 |
| DA20 [corrected] | deputy | the President of the Senate opening the certificates, `constitution-paged.txt:1023-1025` (p.21) | the office of Vice President, "President of the Senate" (`constitution-paged.txt:321-322` (p.9)); whether the President pro tempore, chosen "in the Absence of the Vice President, or when he shall exercise the Office of President of the United States" (`constitution-paged.txt:324-326` (p.9)), opens the certificates (`constitution-paged.txt:1023-1025` (p.21)) in his absence is not settled by the document (U54); "in the presence of the Senate and House of Representatives" | none stated (U32) | E1, I1 (RB2) |
| DA21 (new) | mint | admission of new States, a mint from Congress (`constitution-paged.txt:746-751` (p.15)) | restrictions: no new State "formed or erected within the Jurisdiction of any other State", and none formed "by the Junction of two or more States, or Parts of States, without the Consent of the Legislatures of the States concerned as well as of the Congress"; whether that consent reaches the first bar is not settled by the document | none stated (U61) | M9 |
| DA22 (new) | mint | enforcement legislation, one mint from Congress in seven articles, bounded by "appropriate" (the lines in M8) | the bound "appropriate", in seven articles | BC9, a person's | M8 |
| DA23 (new) | mint | militia officers, "reserving to the States respectively, the Appointment of the Officers" (`constitution-paged.txt:469-471` (p.11)), commanded by the President when "called into the actual Service" (`constitution-paged.txt:621-623` (p.13)) | restriction on the States' training of the Militia, "according to the discipline prescribed by Congress"; on the appointment of the officers none stated | none stated | none: the power being granted at the line |
| DA24 (new) | deputy | the Chief Justice presiding "When the President of the United States is tried" (`constitution-paged.txt:330-331` (p.9)), a deputy for the Senate whose decisions are not stated (U55) | no restriction stated | none stated | none |
| DA25 (new) | deputy | the Speaker and the President pro tempore as the positions the latter declaration is transmitted to (`constitution-paged.txt:1755-1756` (p.31)), its "receipt" (`constitution-paged.txt:1760-1761` (p.31)) starting the twenty-one days; who records receipt is not settled by the document (U5) | no restriction stated | none stated | T6 |

Counts: no row has a check that binds its whole act; 5 rows have at least one restriction read by
an observer (DA2 by O8, DA5 by O4 and O5, DA6 by O12, DA7 by O7, DA8 by O11); 8 rows record only a
person's check (DA1, DA9, DA13, DA14, DA17, DA18, DA19, DA22); 12 rows have no check stated at all
(DA3, DA4, DA10, DA11, DA12, DA15, DA16, DA20, DA21, DA23, DA24, DA25). Twenty-two rows carry at
least one restriction not stated to reach a check that decides the act; DA7 alone has every
restriction read by an observer, its recogniser not stated (U6), and DA24 and DA25 record no
restriction.

### Stated exclusions

Twenty-six: twenty-three confirmed at their lines by the first verification, and SE24 to SE26 added by the chain verification. Dispositions tested under "A stated exclusion is a stated
absence": a row where a position reaches an act the excluded check would have decided and gains
what it lacked, or a condition reaches the hazardous state; a refusal only where a line shows
the system refusing the act; the absence of a check never a refusal. A position lacks what no
line shows it holding; where the exclusion's own line grants the power left unchecked, the
holder gains nothing it lacked, the disposition the gap evaluation gave SE9's impeachment branch and SE23.

| # | Line | What is left out | Disposition | Row |
|---|---|---|---|---|
| SE1 | `constitution-paged.txt:361-363` (p.9) | publication of "such Parts as may in their Judgment require Secrecy" | the record path SP1 cut by each House's judgment (BC8); a repudiation row on the cut signal path | R1 |
| SE2 [corrected] | `constitution-paged.txt:382-387` (p.10) | arrest during attendance and travel, "except Treason, Felony and Breach of the Peace"; questioning "in any other Place" for speech or debate | no position gains: the privilege is granted at the exclusion's own lines, and the check left out is the courts' (BC9), a person's, so no observer or signal path is removed | none (E35 dropped) |
| SE3 | `constitution-paged.txt:419-421` (p.10) | presentment of "a question of Adjournment" | no gain from the exclusion itself (the line excepts the question from presentment, and the Houses hold their adjournment at `constitution-paged.txt:367-369` (p.9)); the same act, where it prevents a presented bill's return, removes O1 for it (RP1), and whether it ends the session O8 waits on is not settled by the document (RP4); both held as removal paths | E36 |
| SE4 [corrected] | `constitution-paged.txt:415-417` (p.10) | the ten-day default for a bill whose return "the Congress by their Adjournment prevent" | a refusal: "it shall not be a Law"; a removal path for O1 (RP1). The refusal is the Houses', who hold their adjournment (`constitution-paged.txt:367-369` (p.9)). Where the adjournment is the President's on their disagreement (`constitution-paged.txt:657-660` (p.14)), the same branch is reached by a position that does not hold the Houses' adjournment: X5, conditional on U52. | none |
| SE5 | `constitution-paged.txt:342-344` (p.9) | Congress's alteration of "the Places of chusing Senators" | no position gains: the State legislature holds the power at `constitution-paged.txt:340-342` (p.9) | none |
| SE6 | `constitution-paged.txt:489-491` (p.11) | the habeas bar in "Cases of Rebellion or Invasion" where "the public Safety may require it" | no line shows any position holding the suspension power (U15), so a position that suspends gains what no line grants; continue-on-fault C7 | E11 |
| SE7 [corrected] | `constitution-paged.txt:627-628` (p.13) | pardons "in Cases of Impeachment" | a bound on the pardon power: a pardon in a case of impeachment reaches what the President lacks, and no check is stated to read the bound (U33) | E31 |
| SE8 [corrected] | `constitution-paged.txt:694-697` (p.14) | appellate jurisdiction "with such Exceptions ... as the Congress shall make" | no position gains: Congress holds the power at the exclusion's own line; the check removed is the courts' (BC9), a person's (RP7 removes no observer) | none (E37 dropped) |
| SE9 | `constitution-paged.txt:699` (p.14); `constitution-paged.txt:913-915, 940` (p.19-20) | jury trial "in Cases of Impeachment"; the grand jury in "cases arising in the land or naval forces, or in the Militia, when in actual service in time of War or public danger" | impeachment branch: no position gains, the Senate holds "the sole Power to try all Impeachments" at `constitution-paged.txt:328` (p.9); forces branch: no line names who holds the process (U25), a row | E38 (forces) |
| SE10 | `constitution-paged.txt:537-541` (p.12) | consent to a State's war when "actually invaded, or in such imminent Danger as will not admit of delay" | a bound whose judge the lines do not name (U34) | E13 |
| SE11 | `constitution-paged.txt:529-535` (p.12) | consent for imposts "absolutely necessary for executing its inspection Laws" | a bound whose judge the lines do not name (U34) | E14 |
| SE12 [corrected] | `constitution-paged.txt:984-987` (p.20) | the judicial power over suits against a State by citizens of another State or foreign subjects | no position gains: the limit is stated at the exclusion's own lines, and the check left out is the courts' (BC9), a person's | none (E39 dropped) |
| SE13 | `constitution-paged.txt:1080-1083` (p.22) | servitude "as a punishment for crime whereof the party shall have been duly convicted" | a bound ("duly convicted") read by the convicting court only (U47) | E40 |
| SE14 | `constitution-paged.txt:1142-1143` (p.23) | reduction for denials "for participation in rebellion, or other crime" | a bound found by no stated position (U13) | E18 |
| SE15 | `constitution-paged.txt:1156-1157` (p.23) | the disability of persons Congress relieves by two thirds | a bound ("such disability") read by no stated check (U45) | E32 |
| SE16 [corrected] | `constitution-paged.txt:786-787` (p.16) | an amendment depriving a State "without its Consent" of "its equal Suffrage in the Senate" | a bound on the amendment power (DA18): the minters reaching past it gain what they lack, and no check is stated to read it (U19) | E33 |
| SE17 | `constitution-paged.txt:1562-1568` (p.28) | the two-term limit for the holder when proposed and during the operative term | not settled by the document whether any such person remains (U17); no row unless settled | none |
| SE18 | `constitution-paged.txt:1307-1309` (p.25) | the election or term of a Senator "chosen before it becomes valid" | spent: the in-force table the brief fixes makes it context; no position or condition reaches it | none |
| SE19 | `constitution-paged.txt:1741-1742, 1753-1754` (p.31) | the declaring body: "such other body as Congress may by law provide" | a reset path for O4's and O5's input (RP2), a B2 path to an observer's input | E41 |
| SE20 | `constitution-paged.txt:713-717` (p.15) | treason conviction "unless on the Testimony of two Witnesses ... or on Confession in open Court" | a refusal at the lines; its application rests on BC9, a person's | none |
| SE21 | `constitution-paged.txt:363-365` (p.9) | the yeas and nays except "at the Desire of one fifth of those Present" | the record path SP1 cut for every other question but the override, whose names are always entered (`constitution-paged.txt:410-412` (p.10)); U36 settled as to the text | R2 |
| SE22 | `constitution-paged.txt:516-520` (p.12) | a present, emolument, office or title from "any King, Prince, or foreign State" accepted with "the Consent of the Congress" | a bound read by no stated position (U35) | E7 |
| SE23 | `constitution-paged.txt:701` (p.14); `constitution-paged.txt:710-711` (p.15) | the place of trial for crimes "not committed within any State" | no position gains: Congress holds the choice at the same lines; listed with the delegation boundaries | none |
| SE24 (new) | `constitution-paged.txt:1254-1257` (p.24) | taxes on incomes "without apportionment among the several States, and without regard to any census or enumeration", leaving out the rule at `constitution-paged.txt:493-495` (p.11) | no position gains, Congress holding the power at the line | none |
| SE25 (new) | `constitution-paged.txt:962-964` (p.20) | no re-examination of a fact tried by a jury "than according to the rules of the common law" | the check left out is the courts' (BC9), a person's | none |
| SE26 (new) | `constitution-paged.txt:720-721` (p.15) | forfeiture "except during the Life of the Person attainted" | the exception leaves forfeiture during the life within the power to declare the punishment (`constitution-paged.txt:719-720` (p.15)), so no position gains from it; the bar itself, read by no stated check, is M10's | none from the exclusion; the bar is M10's |

### Key records

Sixteen checks decide on an object by a key (thirteen from the observer mapping, three added). No line shows
two objects sharing a part a check may not read while a position can create, name or be granted
one, so no key record carries a U id of its own.

| Check | Key it reads | Identifying key where the act lands | Correspondence | Row |
|---|---|---|---|---|
| O1 | the bill presented, `constitution-paged.txt:412-414` (p.10) | "the Same", `constitution-paged.txt:414-415` (p.10) | identical | none: identical machine key; the record of return is T1's |
| O2 | the date, `constitution-paged.txt:1443-1446` (p.27) | every term of the kind, `constitution-paged.txt:1443-1447` (p.27) | identical by the text's terms | none |
| O3 | the office, `constitution-paged.txt:1718` (p.30) | the office, `constitution-paged.txt:1719-1720` (p.30) | identical | none |
| O4 | the second declaration naming "the President", `constitution-paged.txt:1755-1758` (p.31) | the office | identical; the makers' binding is RB4's | S2 |
| O5 | the determination, `constitution-paged.txt:1760-1764` (p.31) | the office | identical | S4 for the record |
| O6 | "the President elect", `constitution-paged.txt:1454` (p.27) | the office, `constitution-paged.txt:1454-1455` (p.27) | the person the count names (BC10) and the office his term begins in | none |
| O7 [corrected] | the choice and qualification, and the qualification that ends the acting, `constitution-paged.txt:1455-1459` (p.27) | the office | identical | none |
| O8 | the commission's class (filling "Vacancies that may happen during the Recess of the Senate"), `constitution-paged.txt:650-652` (p.14) | the commission | the class recorded by no stated position (U22) | E20 holds the class as a restriction |
| O9 | the pay law and the election, `constitution-paged.txt:1858-1860` (p.32) | the law | identical | none |
| O10 (new) | the President's inability, `constitution-paged.txt:600-602` (p.13) | the office, `constitution-paged.txt:602-603` (p.13) | identical | none |
| O11 (new) | the vacancy the election fills, `constitution-paged.txt:1304` (p.25) | the temporary appointment to "the vacancies", `constitution-paged.txt:1303-1304` (p.25) | identical by the text's terms | none |
| O12 (new) | the disability, election or qualification, `constitution-paged.txt:606-607` (p.13); `constitution-paged.txt:1463-1464` (p.27) | the office | identical | none |
| BC1 | the bill, `constitution-paged.txt:402-404` (p.10) | "that House in which it shall have originated", `constitution-paged.txt:403-404` (p.10) | not stated (U26); a B2 control's key binds nothing | none: the record serves the chain hunt |
| BC6 | the member's return and qualifications, `constitution-paged.txt:350-351` (p.9) | the seat | a B2 control's key binds nothing | none |
| BC10 | names and vote numbers on the lists, `constitution-paged.txt:1017-1021` (p.21) | the person who "shall be the President", `constitution-paged.txt:1025-1027` (p.21) | by name only, not stated further | none: a B2 control's key binds nothing, and no line shows two persons sharing a name on a list |
| OC7 | the person's attributes where applied, `constitution-paged.txt:241-244` (p.8); `constitution-paged.txt:593-598` (p.13) | the seat or office | the bar names the person; the judging position is BC6 or not named (U12) | none |

The recognising step is stated for no observer: O1's window start (U1) and the recognisers of
O2 to O12 (U30, U2, U5, U6, U23, U24, U48, U14) are not stated. The observer mapping's count of "5 with the
recognising step not stated (O4, O5, O6, O7, O8)" omitted O2 (U30), O3 (U2) and O9 (U24), which
its own inventory records as not stated; corrected to every observer.

### Named objects

Twelve inputs confirmed at their lines; three inputs the observer mapping treated as naming one object name
more than one and are added as records (no new row: each gap is held by the read-back's row
entered from the same position).

| # | Input | Objects and the check that binds each | Row |
|---|---|---|---|
| NO1 | the electors' lists, `constitution-paged.txt:1017-1021` (p.21) | the persons voted for: eligibility none stated (U8), inhabitancy BC20 only; the numbers against "the whole number of Electors appointed": none stated (U7); the signers against the State's appointment: none stated (U7, U29); the State: none stated | E1 (the pair's) |
| NO2 | the §4 declaration, `constitution-paged.txt:1740-1747` (p.31) | the President: bound by the text; the Vice President's participation and the majority: none stated (U4) | S2 |
| NO3 | the §3 declaration, `constitution-paged.txt:1733-1736` (p.31) | the President as authority and writer: none stated (U3); the Vice President: bound by the text | S1 |
| NO4 [corrected] | a bill returned, `constitution-paged.txt:403-404` (p.10) | the bill: bound by "it"; the originating House: none stated (U26); whether a return delivered to the other House is "returned" for the ten-day default: not stated (U63) | M1, conditional on U26 and U63 |
| NO5 | a writ of election, `constitution-paged.txt:264-266` (p.8); `constitution-paged.txt:1300-1302` (p.25) | the vacancy: none stated; the State: bound by "thereof" | T3 |
| NO6 | the extradition demand, `constitution-paged.txt:734-738` (p.15) | the person and the charge: none stated (U21); the demanding State as having jurisdiction: none stated (U21); the State where found: bound by the text | E46 |
| NO7 | a warrant, `constitution-paged.txt:907-909` (p.19) | the place, persons and things: "particularly describing", a shape requirement on the writer, read at execution by no stated position (U9); probable cause: BC27 | E16 |
| NO8 | a commission, `constitution-paged.txt:650-652, 662-663` (p.14) | the officer against the appointment (U31); the office against "established by Law" (U12); the recess vacancy (U22) | E26, E20 |
| NO9 | a draw under an appropriation, `constitution-paged.txt:511-512` (p.12) | the draw and the two-year term: none stated (U11) | T5 |
| NO10 | a law vesting inferior appointments, `constitution-paged.txt:646-648` (p.14) | the class "inferior": none stated (U16); the appointing position: one of three the text names | E21 |
| NO11 | a temporary Senate appointment, `constitution-paged.txt:1302-1305` (p.25) | the vacancy and the empowerment: none stated machine (U14); the appointee: OC7 judged by BC6 | E24 |
| NO12 | an application for protection, `constitution-paged.txt:761-763` (p.15) | whether the legislature "cannot be convened": none stated (U39); the applicant's standing: none stated | E45 |
| NO13 (new) | the enumeration, `constitution-paged.txt:251-254` (p.8); `constitution-paged.txt:1128-1131` (p.22) | each State, and its number as applied to its apportionment: none stated (U40) | T2 |
| NO14 (new) | a ratification, `constitution-paged.txt:779-783` (p.16) | the amendment ratified against the text proposed; the ratifying legislature or convention against "the one or the other Mode of Ratification ... proposed by the Congress": none stated (U19) | T4 |
| NO15 (new) | another State's act, record or proceeding, `constitution-paged.txt:725-729` (p.15) | the State; the act, record or proceeding as that State's: none stated (U18) | S5 |

Fifteen inputs naming thirty-three objects, one per entry the table separates: six bound by the text's own terms, confirmed (NO2's
President, NO3's Vice President, NO4's bill, NO5's State, NO6's State where found, NO10's
appointing position); twenty-seven with none stated, each carried by a U id or by the person's
check beside it; none with a line showing it needs none.

### Sibling sets

| # | What the members share | The stated check | Members and their checks | Row |
|---|---|---|---|---|
| SS1 [corrected] | Congress's acts taking effect without the President's approval, `constitution-paged.txt:412-417, 419-425` (p.10) | O1, `constitution-paged.txt:412-417` (p.10) | orders, resolutions and votes: the observer mapping read the ten-day default as reaching them "by the text's own reference". At the lines, the clause says that before such an act "shall take Effect, shall be approved by him, or being disapproved by him, shall be repassed ... according to the Rules and Limitations prescribed in the Case of a Bill" (`constitution-paged.txt:422-425` (p.10)); whether those Rules and Limitations carry the default is not settled by the document (U49). Either reading leaves no new row: with the default, an order neither approved nor returned takes effect as a bill does under C1 (E42); without the default, an act neither approved nor repassed does not take effect, a refusal. "a question of Adjournment": none at the lines (SE3) | E36 (adjournment, as RP1 and RP4) |
| SS2 | the transfer at the time fixed, `constitution-paged.txt:1453-1464` (p.27) | O6, O7 | neither a President elect nor a Vice President elect qualified: left to a law (`constitution-paged.txt:1459-1464` (p.27)), none stated machine; the death of a person from whom the House or Senate may choose: left to a law (`constitution-paged.txt:1466-1471` (p.27)), none stated machine | E22 |
| SS3 | the window-bounded default in the inability path, `constitution-paged.txt:1749-1767` (p.31) | O4, O5 | no window on the first §4 declaration (`constitution-paged.txt:1740-1747` (p.31)) or on the President's "no inability exists" (`constitution-paged.txt:1749-1751` (p.31)): none stated; the forty-eight hours (`constitution-paged.txt:1759-1760` (p.31)): no default beyond O5's clock | D7 |
| SS4 [corrected] | the end of an authority granted without the consenting body's act, `constitution-paged.txt:650-652` (p.14) | O8 | the temporary Senate appointment "until the people fill the vacancies by election": its own end, O11, at `constitution-paged.txt:1302-1305` (p.25); the officer named by law "until the Disability be removed, or a President shall be elected": its own end, O12, at `constitution-paged.txt:606-607` (p.13); the Vice President elect "until a President shall have qualified": its own end, O7, at `constitution-paged.txt:1458-1459` (p.27); each recogniser not stated (U14, U6) | E25, E22, E23 |

Four sets with ten members beyond the founding ones: three with the same kind of check at their
own lines (SS4's three), one not settled by the document (SS1's orders, resolutions and votes,
U49), one with none at the lines (SS1's adjournment, SE3), four with none stated (SS2's two,
SS3's two), one with no default beyond O5's clock (SS3's forty-eight hours).

---

## The present halt paths

- **H1** confirmed. A commission filling a vacancy that "may happen during the Recess of the Senate" "shall expire at the
  End of their next Session" (`constitution-paged.txt:650-652` (p.14), O8). Precondition: a
  recess commission in force when the next session ends. Propagation: none; nothing in the text
  acts on the vacancy that results. Recogniser not stated (U23).
- **H2** confirmed. "No law, varying the compensation for the services of the Senators and
  Representatives, shall take effect, until an election of Representatives shall have
  intervened" (`constitution-paged.txt:1858-1860` (p.32), O9). Propagation: the law alone.
  Recogniser, and whether an election to fill one vacancy counts, not settled (U24).
- **H3** confirmed as a B2 act. Where "the Congress by their Adjournment prevent its Return",
  the bill "shall not be a Law" (`constitution-paged.txt:415-417` (p.10)). Propagation: the bill
  alone. During the Session of Congress, neither House may adjourn "for more than three days" without "the Consent of the other"
  (`constitution-paged.txt:367-369` (p.9)); whether a shorter one prevents return is not settled
  by the document.
- **H4** confirmed. The terms "shall end at noon" on the fixed days "and the terms of their
  successors shall then begin" (`constitution-paged.txt:1443-1447` (p.27), O2). Propagation to
  every term that ends on its fixed day, by the text's own terms: the terms of the Representatives and of one of the Senate's three classes (`constitution-paged.txt:276-280` (p.8)) at noon on the 3d day of January, and those of the President and Vice President at noon on the 20th day of January, each in the years those terms end; the only halt in the text that reaches
  more than one office. What stops a holder continuing past the end is not settled (U30).
- **H5** (new). The Vice President elect "shall act as President until a President shall have
  qualified" (`constitution-paged.txt:1457-1459` (p.27), O7's end). Precondition: a President
  qualifies while the Vice President elect acts. Propagation: the acting alone. Recogniser and
  what stops the acting not stated (U6).
- **H6** (new). The temporary Senate appointment ends when "the people fill the vacancies by
  election" (`constitution-paged.txt:1302-1305` (p.25), O11). Propagation: the seat alone.
  Recogniser and what stops the appointee not stated (U14).
- **H7** (new). The officer named by law acts "until the Disability be removed, or a President
  shall be elected" (`constitution-paged.txt:606-607` (p.13)) or "until a President or Vice
  President shall have qualified" (`constitution-paged.txt:1462-1464` (p.27), O12). Propagation:
  the acting alone. Recogniser not stated (U6).

The propagation the observer mapping left open for H1, H2 and H3 beyond their own object is not stated at the
lines, as the gap evaluation found: none is stated to reach a second node. H4 remains the only halt that
reaches more than one office.

### Continue-on-fault paths

- **C1** confirmed. An unreturned bill "shall be a Law, in like Manner as if he had signed it"
  (`constitution-paged.txt:412-415` (p.10), O1). A default that serves; row E42.
- **C2** confirmed. "the Vice President shall become President" (`constitution-paged.txt:1718-1720`
  (p.30)); "shall immediately assume the powers and duties of the office as Acting President"
  (`constitution-paged.txt:1745-1747` (p.31)); "shall continue to discharge the same"
  (`constitution-paged.txt:1764-1765` (p.31)). Rows S1, S2, S3.
- **C3** confirmed. "he shall resume the powers and duties of his office unless" and "otherwise,
  the President shall resume" (`constitution-paged.txt:1751-1752, 1766-1767` (p.31), O4, O5). A
  default that returns the powers to the declared-unable position; row E43.
- **C4** confirmed. "the Vice President elect shall act as President"
  (`constitution-paged.txt:1455-1459` (p.27), O7); the person a law names where neither has
  qualified (`constitution-paged.txt:1459-1464` (p.27), DA6). Rows E22, E23.
- **C5** corrected. The temporary appointment "until the people fill the vacancies by election"
  (`constitution-paged.txt:1302-1305` (p.25), DA8) serves the seat through the vacancy, a
  continue path; rows E24, E25. The writ branch (`constitution-paged.txt:264-266` (p.8);
  `constitution-paged.txt:1300-1302` (p.25)) leaves the seat vacant until the election and is
  not a continue path; its delay is D3's row.
- **C6** confirmed. "to fill up all Vacancies that may happen during the Recess of the Senate, by
  granting Commissions" (`constitution-paged.txt:650-652` (p.14)); row E20.
- **C7** corrected as to wording. The writ "shall not be suspended, unless when in Cases of
  Rebellion or Invasion the public Safety may require it" (`constitution-paged.txt:489-491`
  (p.11)): in rebellion or invasion where the public safety "may" require it, the privilege is
  suspended by a body the text does not name (U15). The lines name no issuer of the writ and
  state no effect of it, so whether the suspension removes a check, and the system continues
  through the fault without it, is not settled by the document (U67). The observer mapping's and the gap evaluation's "in the state
  where detention is most used" is not stated by the document and is withdrawn; row E11.
- **C8** confirmed. "a smaller Number may adjourn from day to day, and may be authorized to
  compel the Attendance of absent Members" (`constitution-paged.txt:352-355` (p.9)); row E8.
  Whether the compulsion can itself be the fault (PR5) is not settled by the document.
- **C9** (new). On the President's "Inability", "the Same shall devolve on the Vice President"
  (`constitution-paged.txt:600-603` (p.13), O10), for an inability no Amendment XXV declaration
  reaches. The system serves through the fault by a deputy; recogniser not stated (U48); row D7.

Nine continue-on-fault paths (C1 to C9). C1, C3 and C9, O3's branch of C2 and O7's branch of C4
are the outputs of observers that serve through the fault by a default, a successor or a deputy,
scored as gaps under reflexive response (property 8) in their groups; C2's §4 branches follow the
declaration and the determination (BC13), C4's branch for the officer a law names follows the law
(DA6), and C5 to C8 are positions' paths, held by the rows named with each.

### Removal paths and prescribed responses

All confirmed at their lines: **RP1** (`constitution-paged.txt:415-417` (p.10)), **RP2**
(`constitution-paged.txt:1741-1742, 1753-1754` (p.31)), **RP3** (`constitution-paged.txt:1451`
(p.27)), **RP4** (`constitution-paged.txt:367-369` (p.9); `constitution-paged.txt:657-660`
(p.14)), **RP5** (`constitution-paged.txt:767-787` (p.15-16); its multi-body requirement is
recorded as the path, and the evidence per verdict records that it discharges no property), **RP6**
(`constitution-paged.txt:489-491` (p.11)), **RP7** (`constitution-paged.txt:694-697` (p.14); a
person's check, no observer removed), **RP8** (`constitution-paged.txt:1736-1737, 1749-1752`
(p.31)), **RP9** (`constitution-paged.txt:400-402` (p.10)), **RP12**
(`constitution-paged.txt:1740, 1752-1753` (p.31); `constitution-paged.txt:1722` (p.30)). RP10
and RP11 are unused ids. Two removal paths bear on the added observers and are recorded under
existing ids: RP4's sense extends to O11 (the legislature directs the election that ends a
temporary appointment, `constitution-paged.txt:1304-1305` (p.25)), and RP12's vacancy leaves O10
and §3 without a recipient as it leaves O3 (U28).

**PR1** to **PR7** confirmed at their lines (`constitution-paged.txt:1758-1767` (p.31);
`constitution-paged.txt:759-763` (p.15); `constitution-paged.txt:661-662` (p.14);
`constitution-paged.txt:405-412` (p.10); `constitution-paged.txt:352-355` (p.9);
`constitution-paged.txt:264-266` (p.8); `constitution-paged.txt:1455-1459` (p.27)).

### Disagreements between sources

- **DG1** confirmed. Editor's note 4: Art. I §3 cl. 2 "has been affected by clause 2 of amendment
  XVIII" (`constitution-paged.txt:374` (p.9)); Amendment XVIII §2 concerns concurrent power to
  enforce that article (`constitution-paged.txt:1345-1346` (p.25)); Amendment XVII's second
  paragraph concerns Senate vacancies (`constitution-paged.txt:1300-1305` (p.25)). Left as the
  source has it.
- **DG2** confirmed. Editor's note 17: "So in original. Probably should be" the plural
  (`constitution-paged.txt:1792` (p.31)), of "executive department" (`constitution-paged.txt:1753-1754`
  (p.31)) against "executive departments" (`constitution-paged.txt:1741` (p.31)); a hedged
  editor's statement.
- **DG3** confirmed, scope narrowed. Art. II §1 cl. 6 "shall devolve on the Vice President"
  (`constitution-paged.txt:600-603` (p.13)) against Amendment XXV §1 "shall become President"
  (`constitution-paged.txt:1718-1720` (p.30)); the editor says only "affected"
  (`constitution-paged.txt:636` (p.13)). For removal, death and resignation the amending text's
  words reach and govern. For an inability no declaration reaches, the brief's in-force rule
  keeps cl. 6 (O10); for an inability a §3 or §4 declaration reaches, Amendment XXV's words
  govern. What "devolve" carries (the office or its powers and duties) is not settled by the
  document.
- **DG4** confirmed. Note 14: "This sentence has been superseded by section 3 of amendment XX"
  (`constitution-paged.txt:1063` (p.21)); Amendment XX §3 (`constitution-paged.txt:1453-1464`
  (p.27)) names no other text. Note 8 (`constitution-paged.txt:635` (p.13)). Both read as
  context.

---

## Keys

**Actors.** B1: the machine-only observer ring (empty here). B2: a privileged position, every office,
body and officer the text creates or names, the States' legislatures, executives, conventions and
officers, the electors and the voters. B3: an external party with no foothold, here foreign states and
their subjects, and an insurgent or invading party where it holds no office. "None, a physical
condition": a state with no actor behind it, such as a death, an inability or the end of a session.

**Entry points.** (1) the voters and citizens; (2) a State's legislature; (3) a State's executive
authority; (4) a State's ratifying convention; (5) the electors; (6) the House of Representatives; (7)
the Senate; (8) the Congress acting by law; (9) the President; (10) the Vice President; (11) the
principal officers or the body Congress provides; (12) judges and courts; (13) juries; (14) officers of
the United States; (15) foreign states and their subjects, B3; (16) an insurgent or invading party, B3
or B2; (17) none, a physical condition; (18) the writers not stated, B2 where a position of the system
and not stated otherwise. In a chain, each entry point is marked required, optional, one branch, one
cause, or the reader. Part F maps every row and chain to its entries, the readers excepted.

**Evidence paths.** Every citation is its own backticked span naming `constitution-paged.txt`, a line
or range in it, then outside the backticks the PDF page from the nearest `=== PDF page N ===` marker
and, where given, the article, section or amendment. Printed page numbers are never used. A row's
Evidence cell gives the lines that establish it; a quotation keeps the source's words and qualifiers.
The text the citations resolve against is rebuilt by `rebuild-source.sh`.

**Halt-on-fault rule.** The required control for every finding is one thing: an observer alerts and the
system halts until the fault clears or the privileged actor leaves. The last column of each row says
whether that control is present, or what the system does instead; a person's check named there is a
B2 control and discharges nothing.

**Ids.** O observers, OC observed components, BC B2 controls, SP signal-path devices, H halt paths, C
continue-on-fault paths, RP removal paths, PR prescribed responses, U unconfirmed items, DG
disagreements between bodies of the source, RB read-backs, DA deputies and mints, SE stated
exclusions, NO named objects, SS sibling sets, SC corrections of the source map, GR scorecard groups;
S, T, R, I, D, E for STRIDE rows, M for rows found by the chain hunt (with the letter each is filed
under), X for chains. Every id is kept from the step that gave it; gaps in a series are ids dropped
or never used.

**Marks.** [corrected] marks a row, table entry, heading or scorecard cell that a verification pass
(the first verification or the chain verification) changed; the change is written into the entry,
which is restated in full. (new) marks an entry a verification pass added. The final sweep's
corrections are applied in place without a mark. Prose that says "confirmed" or "corrected" reports
a verification step's verdict on the claim beside it. The steps named in the text are the observer
mapping, the gap evaluation, the first verification, the chain hunt and the chain verification.

---

## Part A. Threats, in STRIDE

Structural facts every row rests on: the text establishes no machine, so the only candidate
observers are the twelve mechanisms it makes take effect by its own terms (O1 to O12), and every
position it names is B2; no mechanism reads another, so every row's halt-on-fault control is a
person's check or none, and the one halt that reaches more than one office is the fixed end of
every elected term (`constitution-paged.txt:1443-1447` (p.27, Amdt. XX §1), H4); the position that
recognises each mechanism's condition is stated for none (U1, U2, U5, U6, U14, U23, U24, U30, U48);
and every check the text leaves to a law, a House's rules or a State's law is a B2 control resting
on a document the source does not contain (Part E).

### Entry vocabulary

The gap evaluation's eighteen entry positions are confirmed at their lines: (1) the voters and citizens
(`constitution-paged.txt:235-239` (p.8); `constitution-paged.txt:1294-1298` (p.25)); (2) a
State's legislature (`constitution-paged.txt:340-342` (p.9); `constitution-paged.txt:550-553`
(p.12)); (3) a State's executive authority (`constitution-paged.txt:264-266` (p.8);
`constitution-paged.txt:736-737, 762` (p.15)); (4) a State's ratifying convention
(`constitution-paged.txt:781-782` (p.16)); (5) the electors (`constitution-paged.txt:1014-1023`
(p.21); `constitution-paged.txt:1618-1626` (p.29)); (6) the House of Representatives; (7) the
Senate; (8) the Congress acting by law (`constitution-paged.txt:400-412` (p.10)); (9) the
President; (10) the Vice President; (11) the principal officers or the body Congress provides
(`constitution-paged.txt:1740-1742` (p.31)); (12) judges and courts; (13) juries; (14) officers
of the United States; (15) foreign states and their subjects, B3
(`constitution-paged.txt:516-520, 539-540` (p.12); `constitution-paged.txt:986-987` (p.20)); (16)
an insurgent or invading party, B3 or B2; (17) none, a physical condition; (18) the writers not
stated, B2 where a position of the system and not stated otherwise. One correction to how the gap evaluation
used (18): its privilege is not stated, so the gap evaluation's closing claim that (18) reaches the top
"without a privileged act of its own" is not supported; the tie-break by privilege cannot be
applied to it.

### S, Spoofing

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| S1 | (18) U3; (10) | RB3, the President's §3 declaration held by the two officers | B2 (writers not stated, U3); the Vice President gains | A declaration "that he is unable", or "to the contrary", not the President's; no provenance or shape check stated; the pair (the finding under the President's authority) unbound (RB3, NO3). | "such powers and duties shall be discharged by the Vice President as Acting President" (`constitution-paged.txt:1737-1738` (p.31)): the whole executive power (`constitution-paged.txt:545` (p.12, Art. II §1 cl. 1); `constitution-paged.txt:621-628` (p.13)) until the next declaration; or the powers returned to a President who declared himself unable. Conditional on U3. | `constitution-paged.txt:1733-1738` (p.31) | RB3, NO3, DA4; property 3 | none; BC12, a person's |
| S2 | (10) with fewer than a majority of (11); (18) U4 | RB4, the §4 declaration | B2 | A declaration without the Vice President, without a majority, or signed by persons not holding the offices; who establishes the majority is not stated; the pair unbound (RB4, NO2). | "the Vice President shall immediately assume the powers and duties of the office as Acting President" (`constitution-paged.txt:1745-1747` (p.31)), held through the windows and continued on a two-thirds determination (`constitution-paged.txt:1752-1765` (p.31)). Conditional on U4. | `constitution-paged.txt:1740-1747, 1752-1758` (p.31) | RB4, NO2, DA5; property 3 | none at the transfer; BC12, BC13 after |
| S3 | (18) U2; (10) | the §1 transfer on the President's removal, death or resignation, O3 for death and a position's act for removal and resignation | B2 (writers not stated, U2); the Vice President gains | The text conditions the transfer on the death, removal or resignation itself, names no position that recognises it and no addressee of a resignation; a report of death or a resignation not the President's acted on by whoever recognises it makes the Vice President President, with no contrary declaration stated. | "the Vice President shall become President" (`constitution-paged.txt:1718-1720` (p.30)): the office for the remainder of the term (`constitution-paged.txt:1443-1447` (p.27)), the widest grant in the text. The input a position acts on is not stated by the document; the row stands conditional on U2 for every entry. | `constitution-paged.txt:1718-1720` (p.30) | O3; property 3 | none stated; BC5 |
| S4 [corrected] | (18) U27; (6), (7): a majority of each House | RB5, Congress's two-thirds determination in each Journal | B2 where a position of the system; not stated otherwise | A determination recorded by a writer other than the House, or a vote not recorded within the window; no provenance or shape check. No line requires the names of those voting on the §4 determination: they are entered only "at the Desire of one fifth of those Present" (`constitution-paged.txt:363-365` (p.9)), the override alone requiring them (`constitution-paged.txt:410-412` (p.10)). A House records a determination "by two-thirds vote" (`constitution-paged.txt:1762-1764` (p.31)) its members did not reach. Each House keeps its own Journal (`constitution-paged.txt:361` (p.9)); no line requires the names (`constitution-paged.txt:363-365` (p.9)) or names a reader of the recorded count (U64, new). | "the Vice President shall continue to discharge the same as Acting President" (`constitution-paged.txt:1764-1765` (p.31)), or "the President shall resume" (`constitution-paged.txt:1766-1767` (p.31)). Conditional on U27 for the writers; the absence of a required record of names stands on the lines (U36 settled); for that entry, the Vice President's continuance as Acting President (`constitution-paged.txt:1764-1765` (p.31)) without two thirds; conditional on U64. | `constitution-paged.txt:1760-1767` (p.31); `constitution-paged.txt:361-365` (p.9) | RB5, O5; property 3 | none; BC8 |
| S5 | (18) U18; (2), (3), (12) | RB9, another State's acts, records and proceedings | B2 where a State's position; not stated otherwise | An act, record or proceeding presented as a State's that is not; the manner of proof is what "the Congress may by general Laws prescribe" (`constitution-paged.txt:727-728` (p.15, Art. IV §1)), a law the document does not contain. | "Full Faith and Credit" in every other State (`constitution-paged.txt:725-727` (p.15, Art. IV §1)), with "the Effect thereof" as Congress may prescribe it (`constitution-paged.txt:727-729` (p.15)). Conditional on U18. | `constitution-paged.txt:725-729` (p.15) | RB9, NO15, BC33; property 3 | none stated |
| S6 | (18) U42 | RB14, the laws and treaties the judges read | B2 where a position of the system; not stated otherwise | A text presented as a law or treaty that was not made as required (a bill not presented, `constitution-paged.txt:400-402` (p.10); a treaty without two thirds of the Senators present, `constitution-paged.txt:630-632` (p.13)); no custodian or check at the read is stated. | "the supreme Law of the Land; and the Judges in every State shall be bound thereby" (`constitution-paged.txt:798-800` (p.16)), reaching a text the reader takes for a law "made in Pursuance thereof" or a treaty made "under the Authority of the United States" (`constitution-paged.txt:795-797` (p.16, Art. VI cl. 2)). Conditional on U42. | `constitution-paged.txt:795-800` (p.16) | RB14, SP14; property 3 | none; BC9, BC31 |

### T, Tampering

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| T1 | (6) or (7), the originating House; (18) U27 | RB1, the record of a bill's return on the originating Journal | B2 | O1 reads "returned by the President within ten Days"; a bill returned but recorded as not returned "shall be a Law" unless "the Congress by their Adjournment prevent its Return" (`constitution-paged.txt:415-416` (p.10, Art. I §7 cl. 2)); one not returned but recorded as returned goes to reconsideration. | For a House majority: a law without the President's approval and without two thirds (`constitution-paged.txt:412-415` (p.10)); conditional on U26. For (18): conditional on U27. | `constitution-paged.txt:403-408, 412-415` (p.10); `constitution-paged.txt:361-365` (p.9) | RB1, NO4; property 3 | none; the override's names (`constitution-paged.txt:410-412` (p.10)), a record only |
| T2 [corrected] | (18) U40; (8) | RB6, the enumeration | B2 where a position of the system; not stated otherwise | A count outside "the whole number of persons in each State, excluding Indians not taxed" (`constitution-paged.txt:1128-1131` (p.22, Amdt. XIV §2)) applied to the apportionment of Representatives and to electors, or an enumeration not made as directed applied to direct taxes, laid "in Proportion to the Census or Enumeration herein before directed to be taken" (`constitution-paged.txt:493-495` (p.11, Art. I §9 cl. 4)). | Every State's representation (`constitution-paged.txt:1128-1131` (p.22)) and electoral weight (`constitution-paged.txt:551-553` (p.12)), in one act. Conditional on U40. The apportionment (`constitution-paged.txt:1128-1131` (p.22)) sets each State's number of electors, "equal to the whole Number of Senators and Representatives" (`constitution-paged.txt:550-553` (p.12)), and so each State's weight in the count whose majority decides who "shall be the President" (`constitution-paged.txt:1025-1028` (p.21)); and it sets the House's membership, the base of every act counted of "that House" or "both Houses" (`constitution-paged.txt:406, 409` (p.10); `constitution-paged.txt:1730-1731, 1762-1763` (p.31)). It does not reach the House's choice of a President, "taken by states" (`constitution-paged.txt:1031-1033` (p.21)). | `constitution-paged.txt:251-254` (p.8); `constitution-paged.txt:1128-1131` (p.22); `constitution-paged.txt:493-495` (p.11) | RB6, NO13, SP6, BC30; property 3 | none stated |
| T3 | (3) | RB8, a writ of election | B2 | A writ for a seat not vacant. The executive is the named authority; its restriction "When vacancies happen" (`constitution-paged.txt:264` (p.8)) is read by no stated check, held with the pair (NO5). | An election ordered and a second return for a seat held; which return is seated is the House's or Senate's judgment (`constitution-paged.txt:350-352` (p.9)). Conditional on U41. | `constitution-paged.txt:264-266` (p.8); `constitution-paged.txt:1300-1302` (p.25) | RB8, NO5, SP9; property 3 | BC6 |
| T4 [corrected] | (18) U19; (2), (4) | RB13, the applications and ratifications | B2 where a State's position; not stated otherwise | An application or ratification not a legislature's or convention's, or a count of two thirds or three fourths by no named position. | For a ratification or a count of three fourths: text "valid to all Intents and Purposes, as Part of this Constitution" (`constitution-paged.txt:779-781` (p.16)): every mechanism and bar, in one act. For an application or a count of two thirds: a Convention "for proposing Amendments" called (`constitution-paged.txt:770` (p.15, Art. V)), its proposals valid only "when ratified" (`constitution-paged.txt:780` (p.16, Art. V)). Conditional on U19. A ratification or application not a legislature's or convention's reaches the proviso at `constitution-paged.txt:786-787` (p.16) as it reaches every other part, where the deprived State's "Consent" is read by the same unnamed position (U19, E33). | `constitution-paged.txt:767-787` (p.15-16) | RB13, NO14, SP13, BC15; property 3 | none stated |
| T5 | (18) U11; (14) | RB10, appropriations at the draw | B2 where a position of the system; not stated otherwise | Money drawn other than "in Consequence of Appropriations made by Law", or beyond the appropriation (NO9). | The public money, in whatever amount a draw names (`constitution-paged.txt:511-512` (p.12)). Conditional on U11. | `constitution-paged.txt:511-514` (p.12) | RB10, NO9, OC5, SP5; property 3 | none; SP5 after |
| T6 | (6), (7): the Speaker and the President pro tempore | SP4 at "receipt of the latter written declaration" | B2 | The text names no receiver for "receipt" (`constitution-paged.txt:1760-1761` (p.31)); the declarations are transmitted to the two officers (`constitution-paged.txt:1755-1756` (p.31)); a declaration held, or its receipt recorded late or early, moves the window and the default while Congress is in session; where it is not in session the twenty-one days run "after Congress is required to assemble" (`constitution-paged.txt:1761-1762` (p.31, Amdt. XXV §4)). | When the President resumes (`constitution-paged.txt:1766-1767` (p.31)), for up to the window. Conditional on U5. | `constitution-paged.txt:1755-1762` (p.31); `constitution-paged.txt:1733-1735` (p.31) | O4, O5, SP4; property 3 | none |

### R, Repudiation

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| R1 | (6), (7) | SP1, the Journal, published "excepting such Parts as may in their Judgment require Secrecy" (SE1) | B2 | A House withholds any part of its proceedings on its own judgment; the signal path to the public is cut and no reader of the judgment is stated. | The public record of any proceeding, the votes O5 and the §2 confirmation rest on included (`constitution-paged.txt:1730-1731, 1763` (p.31)). | `constitution-paged.txt:361-363` (p.9) | SE1, BC8, SP1; property 6 | none |
| R2 [corrected] | (6), (7): more than four fifths of those present | SP1, the yeas and nays "at the Desire of one fifth" (SE21) | B2 | Any question but the override decided with no record of who voted, the §4 determination and the §2 confirmation included; no line requires names for them. | The record of every vote but the override, for both Houses; stands on the lines (U36 settled as to the text). | `constitution-paged.txt:363-365` (p.9); `constitution-paged.txt:1730-1731, 1763` (p.31) | SE21, BC8, RB5; property 6 | none |
| R3 | (18) U11 | SP5, the statement of accounts | B2 where a position of the system; not stated otherwise | The only record of draws stated is the "regular Statement and Account", written by a position not named and published "from time to time"; no act on it is stated. | Every draw unrecorded or recorded late. Conditional on U11. | `constitution-paged.txt:512-514` (p.12) | SP5, OC5, RB10; property 6 | none |

### I, Information disclosure

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| I1 [corrected] | (10); (18) U32 | SP3, the lists "transmit sealed ... directed to the President of the Senate" | B2 | The lists are to be opened "in the presence of the Senate and House of Representatives"; who holds them before, and whether anyone reads the seal, is not stated; the President of the Senate's restriction "in the presence" reaches no stated check (DA20). | Each State's votes known to the holder, or to a position that reaches the sealed lists, before the count (`constitution-paged.txt:1021-1025` (p.21)): the content of every list held, ahead of the Houses. Conditional on U32. | `constitution-paged.txt:1021-1025` (p.21) | SP3, RB2, DA20; property 3 | none stated |

### D, Denial of service

File every row by its effect: a continue-on-fault path whose effect is accepting a forged
identity goes under S, one that grants an unearned privilege under E. Under D go the
continue-on-fault paths whose effect is service the model scores as lost or degraded.
Availability claims go in their own section, unranked.

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| D1 | (6), (7); (8) by law (RP3) | OC1, the assembly of Congress | B2 | The Houses do not assemble, or appoint "a different day"; no mechanism observes it; the twenty-one days still run from when Congress "is required to assemble" and O5 returns the powers. | The legislative power, the override, the contingent elections, the §2 confirmation and the §4 decision stopped while the Houses do not sit (`constitution-paged.txt:1758-1762` (p.31)). | `constitution-paged.txt:1449-1451` (p.27); `constitution-paged.txt:657` (p.14) | OC1, RP3, PR1; properties 1, 6 | none; PR1 on positions |
| D2 | (18) U1; (6), (7) | BC3, presentment | B2 where a position of the system; not stated otherwise | A passed bill presented late or never; the ten days run only "after it shall have been presented to him"; timing presentment so an adjournment falls within the ten days turns the default into "it shall not be a Law" where "the Congress by their Adjournment prevent its Return" (`constitution-paged.txt:415-417` (p.10, Art. I §7 cl. 2)); whether a given adjournment does is not settled by the document (H3). | A passed bill never becomes law, or, where the President neither signs nor returns it, lives or dies at the presenter's choice of time (RP9). Conditional on U1. | `constitution-paged.txt:400-402, 412-417` (p.10) | BC3, RP9, O1; properties 1, 5 | none |
| D3 [corrected] | (3) | PR6, the writ of election | B2 | No time is fixed for the writ; a withheld writ leaves the seat vacant, or held by the executive's temporary appointee where empowered (DA8). | The State's seat and vote while the writ is withheld (`constitution-paged.txt:1300-1305` (p.25)), or, where the legislature has empowered temporary appointments, the seat and vote held by the executive's own appointee for as long as the writ is withheld, the appointment lasting "until the people fill the vacancies by election as the legislature may direct"; whether that election can be held without the writ is not settled by the document (`constitution-paged.txt:1302-1305` (p.25)). | `constitution-paged.txt:264-266` (p.8); `constitution-paged.txt:1300-1305` (p.25) | PR6, SP9, DA8; property 1 | none |
| D4 | (17) the end of the session; (7) by withholding consent | H1, the office after a recess commission expires | none, a physical condition; B2 | The office stands vacant; no mechanism observes the vacancy; it may be refilled by a new recess commission at the next recess (C6) where the vacancy counts as one that "may happen during the Recess of the Senate" (`constitution-paged.txt:650-651` (p.14, Art. II §2 cl. 3)), not settled by the document (U22). | The office's work lost, or filled again without consent (E20). | `constitution-paged.txt:650-652` (p.14); `constitution-paged.txt:630-646` (p.13-14) | H1, O8, C6; properties 4, 6 | H1 halts the commission; nothing observes the vacancy |
| D5 [corrected] | (9) by not nominating; (6), (7) by not confirming; (10) by resignation or non-participation; (17) the Vice President's death | OC17, the office of Vice President vacant, or the Vice President not participating | B2; none, a physical condition | With the office vacant, O3, O10 and §3 have no recipient and the §4 declaration no maker; the case of "both" goes to a law. Where the Vice President does not join, no §4 declaration can be made. Beside a vacant Vice Presidency, a House that has not chosen the officer who receives the declarations closes the same path where a declaration with no addressee does not take effect, not settled by the document (M5, U54). | The executive power held by an unable President, or by no one, with no mechanism. Conditional on U28 as to what the law provides. | `constitution-paged.txt:1718-1723` (p.30); `constitution-paged.txt:1733-1740` (p.31); `constitution-paged.txt:600-607` (p.13) | OC17, RP12, BC14, DA6; properties 5, 6 | none; BC14 |
| D6 | (9) | PR3, "he shall take Care that the Laws be faithfully executed" | B2 | Execution is the act of the position the other paths address; no mechanism observes non-execution. | Any law, for the term, unexecuted. | `constitution-paged.txt:661-662` (p.14); `constitution-paged.txt:665-668` (p.14) | PR3, OC17; properties 3, 8 | none; BC5, BC13 |
| D7 [corrected] | (17) inability; (10), (11) by not declaring | OC17, the President "unable to discharge the powers and duties of his office", as a state | none, a physical condition; B2 | For an inability no Amendment XXV declaration reaches, the text makes "the Same" "devolve on the Vice President" (O10), what devolves not settled by the document (DG3), and no position is named to recognise the inability (U48). O4 and O5 act on declarations only, and no window bounding the first §4 declaration is stated (SS3). Where no position recognises the inability and none declares, an unable President holds the powers in fact. | The executive power held by a President unable to discharge it, for as long as no position recognises or declares the inability. Conditional on U48. | `constitution-paged.txt:600-603` (p.13); `constitution-paged.txt:1733-1747` (p.31) | OC17, O10, SS3, BC12, BC13; properties 1, 3 | none; the declarations, persons' acts |

### E, Elevation of privilege

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| E1 | (5); (18) U32 | RB2, the electors' lists as opened and counted | B2 where a position of the system; not stated otherwise | For the electors: a list naming a person within a bar (U8), carrying more votes than electors appointed (U7), or cast by persons barred or not appointed (U29); their own inhabitancy check is BC20. For (18): a list altered after sealing or not the State's electors', opened with no stated check (DA20, U32). The pair (the votes under the State's appointed electors) is unbound. | "shall be the President" and "shall be the Vice-President" (`constitution-paged.txt:1025-1028, 1040-1042` (p.21)). The electors' votes reach the count at the lines ("open all the certificates and the votes shall then be counted", `constitution-paged.txt:1024-1025` (p.21)); their gain past the bars is conditional on U8, U7, U29; (18) on U32. | `constitution-paged.txt:1014-1028` (p.21); `constitution-paged.txt:593-598` (p.13); `constitution-paged.txt:553-555` (p.12) | RB2, NO1, DA11, DA20, OC16; property 3 | none; BC10, BC11 |
| E2 [corrected] | (18) U7; (10); (6), (7) | OC16, the count | B2 where a position of the system; not stated otherwise | "the votes shall then be counted" names no counter; "the whole number of Electors appointed" has no stated source; the Houses' role is presence. No line bars the President of the Senate who opens the certificates (`constitution-paged.txt:1023-1025` (p.21)) from being a person voted for; `constitution-paged.txt:1047-1049` (p.21) reaches eligibility only. He presides over the Senate's choice of a Vice President (`constitution-paged.txt:321-322` (p.9); `constitution-paged.txt:1043-1047` (p.21)); his vote in it is E9's. | The offices of President and Vice President (`constitution-paged.txt:1025-1028, 1040-1043` (p.21)), or the choice passed to the House and Senate. Conditional on U7. | `constitution-paged.txt:1023-1028, 1040-1047` (p.21) | OC16, BC10, BC11; property 3 | none; BC11 |
| E3 | (9), (10), (6), (7): the holders | OC2, a term after it "shall end" | B2 | O2 ends the term; what stops a holder continuing is not stated; the successor's term "shall then begin" on no stated act. | The office's powers held past the term; for the President, the executive power (`constitution-paged.txt:545-548` (p.12)). Conditional on U30. | `constitution-paged.txt:1443-1447` (p.27) | OC2, O2, H4; property 8 | O2 ends the term; no stated act enforces the end |
| E4 [corrected] | (9), (10), (12), (14) | OC3 and OC17: offices whose holders' only stated removal is by persons' acts, or whose removal path is not stated | B2 | The President, Vice President and civil officers "shall be removed from Office on Impeachment for, and Conviction of" the named offences (`constitution-paged.txt:665-668` (p.14)); the line does not say "only". Judges hold "during good Behaviour" (`constitution-paged.txt:674-676` (p.14)); no line names their removal path, and whether they are "civil Officers" is not settled (U50). No mechanism observes the conduct or the condition; impeachment and conviction are persons' checks. | The office and its powers continued through the named conduct until two bodies act; for a judge, past the condition "good Behaviour" with no stated path, conditional on U50. The officers' entry stands on the lines. The most privileged officer the line names is the President (`constitution-paged.txt:665-668` (p.14)); the powers so continued are the executive power (`constitution-paged.txt:545-546` (p.12)), until the House impeaches (`constitution-paged.txt:268-269` (p.8)) and two thirds of the Members present convict (`constitution-paged.txt:331-332` (p.9)). | `constitution-paged.txt:665-668` (p.14); `constitution-paged.txt:674-676` (p.14); `constitution-paged.txt:268-269` (p.8); `constitution-paged.txt:328-332` (p.9) | OC3, OC17, BC5; properties 3, 8 | BC5 |
| E5 | (8) | OC4, the two-year cap on army appropriations | B2 | An appropriation for a longer term; no stated reader (U11). | An army funded past two years with no new act, the second-year election (`constitution-paged.txt:235-236` (p.8)) bypassed for that money. Conditional on U11. | `constitution-paged.txt:460-461` (p.11); `constitution-paged.txt:511-512` (p.12) | OC4, RB10, NO9; property 3 | none |
| E6 | (8) | OC6, the compensation bars | B2 | A law varying the President's compensation "during the Period", any "other Emolument", or diminishing the judges' compensation; no observer; O9 defers only Congress's own pay. | Leverage over the President and the judges through compensation. | `constitution-paged.txt:609-613` (p.13); `constitution-paged.txt:676-678` (p.14); `constitution-paged.txt:371-372` (p.9) | OC6, BC28; property 3 | none; BC9 in a case |
| E7 | (14); (15) | OC8 and DA16: a present, emolument, office or title "without the Consent of the Congress" (SE22) | B2; B3 | Acceptance without or before consent; no stated check (U35). | An officer holding a foreign state's office, title or emolument while acting under the United States; for the foreign state, a hold on an officer with no privileged act of its own. Conditional on U35. | `constitution-paged.txt:516-520` (p.12) | OC8, SE22, DA16, BC18; property 3 | none; BC18 |
| E8 [corrected] | (6), (7): less than a majority | OC9, the quorum | B2 | The quorum is counted by the House itself; "a smaller Number may adjourn from day to day, and may be authorized to compel the Attendance" (C8); acts beyond those two by less than a majority are read by no stated check. | Acts of the House by less than a majority; penalties set and applied by the House. The widest acts a House takes alone: impeachment, its "sole Power" (`constitution-paged.txt:268-269` (p.8)), which brings an officer, the President included, to trial (`constitution-paged.txt:328-331` (p.9)), conviction still needing two thirds of the Members present (`constitution-paged.txt:331-332` (p.9)); and the choice of a Speaker (`constitution-paged.txt:268` (p.8)), one of the two officers to whom every §3 and §4 declaration is transmitted (`constitution-paged.txt:1733-1735, 1742-1744, 1749-1751, 1755-1756` (p.31)), the text naming no receiver for "receipt" (T6). By less than a majority, each is read by no stated check. | `constitution-paged.txt:350-355` (p.9) | OC9, C8, PR5, BC6; property 8 | none |
| E9 [corrected] | (10) | OC10, the Vice President's vote "unless they be equally divided" | B2 | Whether the Senate was equally divided is counted by the Senate; no mechanism reads it. | A Senate vote the Vice President lacks, deciding the question. The widest question is the Senate's choice of a Vice President (`constitution-paged.txt:1043-1047` (p.21)), where the Vice President may be one of "the two highest numbers"; whether his vote counts toward "a majority of the whole number" is not stated (U56). Through the vote, the office of Vice President. Conditional on U56 for that question. | `constitution-paged.txt:321-322` (p.9) | OC10, BC19; property 3 | none |
| E10 | (12) the judges in every State | OC11, the supremacy clause | B2 | A State judge gives effect to contrary State law; the bar is applied by the judge himself. | A federal law or treaty without effect in the case. | `constitution-paged.txt:795-800` (p.16); `constitution-paged.txt:694-697` (p.14) | OC11, BC31, BC9; property 3 | none |
| E11 [corrected] | (18) U15 | OC12 and SE6, the writ suspended "when in Cases of Rebellion or Invasion the public Safety may require it" (C7) | B2 where a position of the system; not stated otherwise | No line names the body that suspends or the position that finds rebellion or invasion; a position that suspends holds no power any line grants it. The lines state only when "The Privilege of the Writ of Habeas Corpus" may be suspended; they name no issuer of the writ and state no effect of it, so whether the suspension removes any check, on detention or otherwise, is not stated (U67). | "The Privilege of the Writ of Habeas Corpus" suspended while the suspension lasts. Conditional on U15. The clause names no person whose privilege it is, so no person is stated more privileged than another under this act, and what the suspension reaches is not stated (U67), an unconfirmed item covering that part of the impact alone. | `constitution-paged.txt:489-491` (p.11) | OC12, SE6, C7, BC24, RP6; property 8 | none |
| E12 [corrected] | (8); (2) | OC12, the attainder and ex post facto bars | B2 | A "Bill of Attainder" or "ex post facto Law", terms the text does not define; applied by a court in a case. | Punishment of any person the act names, without trial. The most privileged person an act can name is the President; what a punishment by legislative act reaches for him is not stated (U65; X7). An act of Congress needs presentment (`constitution-paged.txt:400-402` (p.10)) and, over his return, two thirds of each House (`constitution-paged.txt:405-409` (p.10)); the bars are read by a court in a case (BC9). | `constitution-paged.txt:492` (p.11); `constitution-paged.txt:525-526` (p.12) | OC12, BC9; property 3 | BC9 |
| E13 | (2), (3) | SE10 and OC13, a State's war under the exception "unless actually invaded, or in such imminent Danger as will not admit of delay" | B2 | No line names who judges whether a State is "actually invaded" or "in such imminent Danger as will not admit of delay"; none is stated (U34). | A State at war without consent where it is neither invaded nor in such danger, with no stated position judging the condition before the act; the common defence. Whether the exception also reaches "keep Troops, or Ships of War in time of Peace" is not settled by the document. Conditional on U34. | `constitution-paged.txt:537-541` (p.12) | SE10, OC13, DA16; property 3 | none; BC18 after |
| E14 | (2) | SE11, imposts "absolutely necessary for executing its inspection Laws" | B2 | No line names who judges whether an impost is "absolutely necessary for executing its inspection Laws"; none is stated (U34). Congress's revision is after; the Treasury's "net Produce" is read by no stated position. | Imposts beyond what is "absolutely necessary" laid without consent, and their produce, with no stated position judging the necessity before the act. Conditional on U34. | `constitution-paged.txt:529-535` (p.12) | SE11, OC13, DA16, BC18; property 3 | BC18 after |
| E15 | (2), (3) | DA16, tonnage duties, troops, compacts | B2 | Whether consent precedes the act is not stated (U35). | A compact with another State or a foreign power, or troops kept, without consent. Conditional on U35. | `constitution-paged.txt:537-540` (p.12) | DA16, OC13, BC18; property 3 | none |
| E16 | (18) U9; (14) the executing officer | DA9 and NO7, a warrant | B2 where a position of the system; not stated otherwise | The issuer is not named; probable cause is the issuer's (BC27); whether the executing officer reads the description is not stated. | A search or seizure beyond the description: papers, effects and persons (`constitution-paged.txt:905-907` (p.19)). Conditional on U9. | `constitution-paged.txt:905-909` (p.19) | DA9, NO7, BC27, OC14; property 3 | none; BC27 |
| E17 | (8); (2) | OC14, the bars on laws | B2 | A law against the bars passed and executed; applied by a court in a case (BC9) and by enforcement legislation (BC28). | Any such law executed on every person it reaches until a court finds otherwise. | `constitution-paged.txt:885-889` (p.19); `constitution-paged.txt:1121-1126` (p.22); `constitution-paged.txt:1212-1214` (p.24); `constitution-paged.txt:1394-1396` (p.26); `constitution-paged.txt:1671-1676` (p.30); `constitution-paged.txt:1816-1818` (p.32) | OC14, BC9, BC28; property 3 | BC9, BC28 |
| E18 [corrected] | (2) | OC15 and SE14, the reduction of representation | B2 | The finding of a denial and the reduction need a position not named (U13); the exclusion for "rebellion, or other crime" is found by no stated position. The reduction reaches denials "to any of the male inhabitants of such State, being twenty-one years of age, and citizens of the United States" (`constitution-paged.txt:1134-1135` (p.22); `constitution-paged.txt:1142` (p.23)), in proportion to "the whole number of male citizens twenty-one years of age in such State" (`constitution-paged.txt:1145-1146` (p.23)). Amendments XIX and XXVI (`constitution-paged.txt:1394-1396` (p.26); `constitution-paged.txt:1816-1818` (p.32)) bar other denials and state no change to the formula; editor's note 15 (`constitution-paged.txt:1203` (p.23)) is a cross-reference. A denial to any other citizen reaches no reduction by the formula's own words. | The State's full representation and electors kept while the vote is denied. Conditional on U13. | `constitution-paged.txt:1131-1146` (p.22-23) | OC15, SE14, BC30; property 3 | none |
| E19 [corrected] | (9) with (7) | DA1, appointment with advice and consent | B2 | An appointment to an office not "established by Law", or of a person within a bar (U12); BC4 is a person's. | An officer holding the office's authority for its tenure. Conditional on U12. The widest offices named: a judge of the supreme Court (`constitution-paged.txt:643` (p.14)), holding "during good Behaviour" (`constitution-paged.txt:674-676` (p.14)) with no stated removal path (U50) and the judicial power (`constitution-paged.txt:680-697` (p.14)); and a principal officer, with a place in the §4 majority (`constitution-paged.txt:1740-1747` (p.31)). Neither is stated more privileged than the other. | `constitution-paged.txt:632-646` (p.13-14); `constitution-paged.txt:1148-1155` (p.23); `constitution-paged.txt:389-394` (p.10) | DA1, OC7, OC8, BC4; property 3 | BC4 |
| E20 [corrected] | (9) | DA2 and RB7, a recess commission (C6) | B2 | A commission for a vacancy not happening during the recess, or an office not vacant (U22); O8 ends it at the session's end. | Any office "established by Law" filled without consent until "the End of their next Session" (`constitution-paged.txt:645-646` (p.14); `constitution-paged.txt:651-652` (p.14)). Conditional on U22. The widest office a recess commission can fill: a principal officer of an executive department, with a place in the §4 majority (`constitution-paged.txt:1740-1747` (p.31)) until that end, whether a commissioned officer counts there being not stated (U4); X3's optional branch. Beside it, a judge of the supreme Court (`constitution-paged.txt:643` (p.14)), with the judicial power (`constitution-paged.txt:680-697` (p.14)) until that end. | `constitution-paged.txt:650-652` (p.14) | DA2, RB7, NO8, C6, H1, O8; property 3 | O8 at the session's end; no stated check reads the grant |
| E21 [corrected] | (8) | DA3 and NO10, vesting inferior appointments | B2 | Whether an officer so vested is "inferior" is read by no stated check (U16). | An office filled without the Senate's consent. Conditional on U16. The widest class a law can vest as "inferior", a class read by no stated check (U16): the principal officers of the executive departments, whose office carries a place in the §4 majority (`constitution-paged.txt:1740-1747` (p.31)), then appointed by "the President alone", "the Courts of Law" or "the Heads of Departments" (`constitution-paged.txt:646-648` (p.14)) without the Senate's consent. | `constitution-paged.txt:646-648` (p.14) | DA3, NO10; property 3 | none |
| E22 [corrected] | (8) by law; (14) the officer named | DA6, the officer who "shall then act as President" (C4, SS2, SS4) | B2 | The officer's acting ends by the text's own terms (O12) "until the Disability be removed, or a President shall be elected" or "until a President or Vice President shall have qualified"; who recognises the end and what stops the officer continuing past it are not stated, as for O2's term end (E3); the law naming the officer is not in the document. Where the law under `constitution-paged.txt:603-607` (p.13) names the President pro tempore or the Speaker as the officer who acts, that officer also receives the President's declaration "that no inability exists" (`constitution-paged.txt:1749-1751` (p.31)): a design assumption, a means past the end this row already names. | The executive power held by an officer no election named, past the end the text fixes. Conditional on U6. | `constitution-paged.txt:603-607` (p.13); `constitution-paged.txt:1459-1464` (p.27) | DA6, O12, SS2, SS4, C4, BC28; property 8 | O12 ends the acting; no stated act enforces the end |
| E23 [corrected] | (10) the Vice President elect | DA7, acting "until a President shall have qualified" (C4, PR7, SS4) | B2 | The acting ends by the text's terms (O7's end); who recognises "failed to qualify" and "shall have qualified", and what stops the acting, are not stated; the Vice President elect rests on the same count or Senate choice whose failure produced the state. | The executive power held past a qualification. Conditional on U6. | `constitution-paged.txt:1455-1459` (p.27) | DA7, O7, SS4, C4, PR7; property 8 | O7 ends the acting; no stated act enforces the end |
| E24 | (3) | DA8 and NO11, temporary Senate appointments (C5) | B2 | An appointment where the legislature has not empowered it, or beyond its direction; read by no stated check but BC6 (U14). | A Senate seat and vote held without election. Conditional on U14. | `constitution-paged.txt:1302-1305` (p.25); `constitution-paged.txt:350-352` (p.9) | DA8, NO11, C5, BC6; property 3 | BC6 |
| E25 [corrected] | (7) the appointee | DA8's end, "until the people fill the vacancies by election" (SS4) | B2 | The appointment ends by the text's terms (O11); who recognises the election and what stops the appointee continuing are not stated. | The seat and vote past the election. Conditional on U14. | `constitution-paged.txt:1302-1305` (p.25) | DA8, O11, SS4; property 8 | O11 ends the appointment; no stated act enforces the end |
| E26 [corrected] | (9) | DA10 and NO8, commissions | B2 | Whether a commission is checked against the appointment, and who reads it, is not stated (U31). | An officer acting under a commission for an office not appointed to. Conditional on U31. The widest office a commission can name: a principal officer of an executive department (`constitution-paged.txt:624-626` (p.13)), whose office carries a place in the §4 majority that transfers the executive power (`constitution-paged.txt:1740-1747` (p.31)); whether a person commissioned but not appointed counts among "the principal officers" is not stated (U4, U31). Beside it, a judge of the supreme Court (`constitution-paged.txt:643` (p.14)), holding the judicial power (`constitution-paged.txt:680-697` (p.14)) "during good Behaviour" (`constitution-paged.txt:674-676` (p.14)). Neither is stated more privileged than the other. | `constitution-paged.txt:662-663` (p.14) | DA10, NO8, SP8; property 3 | none |
| E27 | (2) | DA11, State electors | B2 | Electors beyond the State's number, or persons "holding an Office of Trust or Profit under the United States"; no stated check at the count (U29). | Votes beyond the State's entitlement, or by barred persons, in the count that decides the President (`constitution-paged.txt:1025-1028` (p.21)). Conditional on U29. | `constitution-paged.txt:550-555` (p.12) | DA11, OC8, RB2; property 3 | none |
| E28 | (8) | DA12, the District's electors | B2 | The cap reaches no stated check (U29). | The District's votes beyond the cap. Conditional on U29. | `constitution-paged.txt:1614-1624` (p.29) | DA12, RB2; property 3 | none |
| E29 [corrected] | (8) | DA13, laws "necessary and proper" | B2 | The restriction is read by a court in a case; no other check is stated (U43). | An officer's power beyond the enumerated powers. Conditional on U43. The most privileged officer a law can name under "any Department or Officer thereof" (`constitution-paged.txt:480-483` (p.11)) is the President (`constitution-paged.txt:545-546` (p.12)), where he is such an "Officer", which is not settled by the document; what such a law vests in him past the enumerated powers is not stated (U43, widened). | `constitution-paged.txt:480-483` (p.11) | DA13, BC9, BC28; property 3 | BC9 |
| E30 | (9) with (7) | DA14 and RB14, treaties | B2 | "under the Authority of the United States" is read by the judges; no other check is stated (U44). | Every judge bound by a treaty past that authority. Conditional on U44. | `constitution-paged.txt:630-632` (p.13); `constitution-paged.txt:795-800` (p.16) | DA14, RB14, BC4, BC31; property 3 | BC31 |
| E31 | (9) | DA15 and SE7, pardons "except in Cases of Impeachment" | B2 | Who decides that an offence is against the United States and not a case of impeachment is not stated (U33). | Relief from any offence the pardon names, a case of impeachment included. Conditional on U33. | `constitution-paged.txt:627-628` (p.13) | DA15, SE7, BC16; property 3 | none stated |
| E32 | (8): two thirds of each House | DA17 and SE15, removal of "such disability" | B2 | A vote purporting to remove another disability; "such disability" read by no stated check. | Eligibility granted past the text's own bars. Conditional on U45. | `constitution-paged.txt:1148-1157` (p.23) | DA17, SE15, BC17; property 3 | none stated |
| E33 [corrected] | (6), (7) or a convention, with (2) or (4): the minters | DA18 and SE16, the equal-suffrage proviso | B2 | An amendment depriving a State of its equal suffrage without its consent; no check is stated to read the proviso at proposal or ratification (U19). | The equal suffrage in the Senate of each State deprived, and through it every act the Senate shares (`constitution-paged.txt:630-646` (p.13-14); `constitution-paged.txt:328-332` (p.9); `constitution-paged.txt:1043-1047` (p.21)), in one act. Amending any other part is within the minters' authority under Art. V and gains them nothing they lack. Conditional on U19. | `constitution-paged.txt:767-787` (p.15-16) | DA18, SE16, RB13, BC15, RP5; property 3 | none stated |
| E34 [corrected] | (7) | DA19, the judgment on impeachment | B2 | "shall not extend further than" is read by no stated position. | A judgment beyond removal and disqualification. Conditional on U46. The most privileged person tried is the President (`constitution-paged.txt:330-331` (p.9)); what a judgment beyond "removal from Office, and disqualification" (`constitution-paged.txt:334-336` (p.9)) reaches is not stated (U46, widened). | `constitution-paged.txt:334-338` (p.9) | DA19, BC5; property 3 | none stated |
| E36 [corrected] | (6), (7) | RP1 and RP4: the Houses' adjournment, excepted from presentment (SE3, SS1) | B2 | An adjournment takes effect with no presentment (granted at `constitution-paged.txt:419-421` (p.10)). Where "the Congress by their Adjournment prevent its Return", the same act removes O1 for every bill presented within the ten days, so a bill the President neither signs nor returns "shall not be a Law" (`constitution-paged.txt:415-417` (p.10)); whether a given adjournment prevents the return is not settled by the document (H3, U52). The same act sets when the Senate's session ends and so when O8 fires; no concurrence is stated for holding the session open: no line requires another's act for the Senate to continue sitting, and one House's refusal of consent bars the other's adjournment for more than three days (`constitution-paged.txt:367-369` (p.9)), a disagreement on which the President "may adjourn them" (`constitution-paged.txt:658-660` (p.14)); whether an adjournment ends "their next Session" (`constitution-paged.txt:651-652` (p.14)) is not settled by the document; U23 holds who recognises the end, and U53 whether a session the President convenes counts. | The Houses decide, by their own concurrence and with no presentment, whether the President's inaction makes presented bills law or kills them, and either House alone, while the President does not adjourn them on its refusal, holds the session open and the recess commissions running. Conditional on whether an adjournment prevents the return (H3, U52) and on whether an adjournment ends a session, neither settled by the document. | `constitution-paged.txt:415-421` (p.10); `constitution-paged.txt:367-369` (p.9); `constitution-paged.txt:650-652` (p.14) | RP1, RP4, SE3, SS1, BC32, O1, O8; property 5 | none |
| E38 | (14): the officers of the forces and militia | SE9's forces branch | B2 | What process applies to the cases excepted from the grand jury is not stated (U25); Congress's rules for the land and naval forces (`constitution-paged.txt:463-464` (p.11)) and for governing the militia employed in the service of the United States (`constitution-paged.txt:467-469` (p.11)) are not available. The impeachment branch gives no row: the Senate holds "the sole Power to try all Impeachments" (`constitution-paged.txt:328` (p.9)). | Any person in the forces or militia, in such a case, held to answer on a process no line states. Conditional on U25. | `constitution-paged.txt:913-915` (p.19); `constitution-paged.txt:940` (p.20) | SE9, BC9, BC34; property 3 | none stated |
| E40 | (12), (2), (14) | SE13, servitude on a conviction | B2 | "duly convicted" is the convicting court's own check; no other reader stated. | Involuntary servitude on a conviction whose regularity no other position reads. Conditional on U47. | `constitution-paged.txt:1080-1083` (p.22) | SE13, BC9; property 3 | BC9 |
| E41 [corrected] | (8) | RP2 and SE19, "such other body as Congress may by law provide" | B2 | Congress may substitute by law the co-maker of both §4 declarations: the first, which transfers the executive power, and the second, the input O4 reads; Congress then "shall decide the issue" (`constitution-paged.txt:1758` (p.31)). Congress holds the power at the line, so the row stands on the removal path (a B2 path to an observer's input), not on a gain from the exclusion. | Who, with the Vice President, can declare the President unable may be set by a law. | `constitution-paged.txt:1741-1742, 1753-1754, 1758` (p.31) | RP2, SE19, BC28, O4, O5; property 5 | none; BC12 |
| E42 [corrected] | (9) | C1, a bill neither signed nor returned within ten days | B2 | By default the bill "shall be a Law, in like Manner as if he had signed it": a law on no affirmative act, with no approval recorded. The adjournment branch ("in which Case it shall not be a Law", SE4) is a refusal granted at the same lines and is no part of this row. | A law binding the public on the President's inaction. | `constitution-paged.txt:412-415` (p.10) | C1, O1; property 8 | none |
| E43 | (9); (6), (7) by not assembling or not deciding | C3 and PR1, the President resumes by default | B2 | No second declaration within four days, or no two-thirds determination within twenty-one days, returns the powers to the declared-unable position; where Congress does not assemble or decide, the default serves an unable President. | The executive power back to the declared-unable President by the others' inaction. | `constitution-paged.txt:1749-1767` (p.31) | C3, PR1, O4, O5; property 8 | none: the windows are the default |
| E44 [corrected] | (9), (14), (6), (7), (12), (2) | RB11 and SP7, the oath | B2 | Whether the President's oath was taken "Before he enter on the Execution of his Office" is read by no stated position (U20); the other officers and members "shall be bound by Oath or Affirmation" (`constitution-paged.txt:802-805` (p.16)) with no time stated, and whether they took it is read by no stated position; Amendment XIV §3 reads "having previously taken an oath" from a record no position is named to hold. | An office entered without the oath; the disability applied, or not, on an unverified record. Conditional on U20. The most privileged office entered is the President's, whose oath is taken "Before he enter on the Execution of his Office" (`constitution-paged.txt:615-619` (p.13)); through entry without it, the executive power (`constitution-paged.txt:545-546` (p.12)) for the term; whether "qualify" (`constitution-paged.txt:1457-1459` (p.27)) means the oath is not settled (U6). | `constitution-paged.txt:615-619` (p.13); `constitution-paged.txt:802-807` (p.16); `constitution-paged.txt:1151-1154` (p.23) | RB11, SP7, BC31, OC7; property 3 | none |
| E45 | (3) | PR2 and NO12, the executive's application "when the Legislature cannot be convened" | B2 | Whether the legislature cannot be convened is read by no stated position. | The protection of the United States "against domestic Violence" brought into a State on one executive's application, by means the text does not state. Conditional on U39. | `constitution-paged.txt:759-763` (p.15) | PR2, NO12, BC25, BC34; property 3 | none |
| E46 [corrected] | (3): the demanding State's executive | RB12 and NO6, the extradition demand | B2 | Delivery on demand of a person "charged" who "shall flee from Justice"; the charge, the flight and the jurisdiction are read by no stated check (U21). The executive is the named authority; its restriction and the pair are one row. | Custody of any person found in another State, delivered as the demand names; the person's liberty. Conditional on U21. "A Person charged in any State" (`constitution-paged.txt:734` (p.15)) names no exception, so the most privileged person a demand can name is the President; what delivery reaches for him is not stated (U65; X7). Beside him, members of either House: the privilege covers arrest during attendance except for "Treason, Felony and Breach of the Peace" (`constitution-paged.txt:383` (p.10)), so a demand for "other Crime" that is not a breach of the peace meets the privilege during attendance and "in going to and returning from the same" (`constitution-paged.txt:383-385` (p.10)), read by persons (BC9). | `constitution-paged.txt:734-738` (p.15) | RB12, NO6, SP13, BC26; property 3 | none stated |

### Found by the chain hunt, verified

Ids kept; a row the chain verification corrected is marked [corrected]. The chain hunt filed eleven rows; nine stand here, M2 is dropped and M3 is merged into E9.

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| M1 (T) [corrected] | (6) or (7), the House in which the bill did not originate; (9) delivering the return there | NO4, RB1 and O1: a bill returned "to that House in which it shall have originated" | B2 | The return's delivery is checked by no stated position (U26). Whether a bill returned to the other House is "returned by the President" for the ten-day default is not stated (U63, new). Read as not returned, the bill "shall be a Law" at ten days while the receiving House holds the return and the objections, which only the originating House must enter. Read as returned, the originating House holds nothing to reconsider and no override runs. | Not-returned reading, for the receiving House: a law without the President's approval and without two thirds of either House (`constitution-paged.txt:412-415` (p.10)), with no line requiring the receiving House to enter the objections. Returned reading, for (9): the objections standing with no reconsideration and no override (`constitution-paged.txt:403-409` (p.10)). Conditional on U26 and U63. | `constitution-paged.txt:403-409, 412-415` (p.10, Art. I §7 cl. 2) | NO4, RB1, BC1's key (U26), O1, BC2; property 3 | none |
| M4 (E) [corrected] | (10) resigning to leave the office of Vice President vacant; (9) nominating, then resigning; (6), (7) confirming | OC7's two-term limit against the nomination and succession path | B2 | "No person shall be elected to the office of the President more than twice" (`constitution-paged.txt:1558-1559` (p.28)) reads election. A vacancy in the office of Vice President is filled by nomination and "confirmation by a majority vote of both Houses" (`constitution-paged.txt:1722-1723` (p.30); `constitution-paged.txt:1730-1731` (p.31)); on the President's resignation "the Vice President shall become President" (`constitution-paged.txt:1718-1720` (p.30)). Whether a person twice elected is "constitutionally ineligible to the office of President" for `constitution-paged.txt:1047-1049` (p.21) is not stated (U57); no position is named to judge a Vice President's eligibility (U12). Where he is not ineligible, the path is the text's own and no position gains. | The office of President held again by a person twice elected to it, no election intervening, for the remainder of the term (`constitution-paged.txt:1443-1447` (p.27)). Conditional on U57 and U12. | `constitution-paged.txt:1558-1568` (p.28); `constitution-paged.txt:1718-1723` (p.30); `constitution-paged.txt:1047-1049` (p.21) | OC7, O3, BC14, SE17; property 3 | none; BC14, a person's |
| M5 (D) [corrected] | (6) by not choosing a Speaker; (7) by not choosing a President pro tempore | SP4's addressees: "the President pro tempore of the Senate and the Speaker of the House of Representatives" | B2 | Every §3 and §4 declaration is transmitted to those two officers (`constitution-paged.txt:1733-1735, 1742-1744, 1749-1751, 1755-1756` (p.31)); no substitute is named. The House "shall chuse their Speaker" with no time stated (`constitution-paged.txt:268` (p.8)); the Senate chooses a President pro tempore "in the Absence of the Vice President, or when he shall exercise the Office of President" (`constitution-paged.txt:324-326` (p.9)), so the text's own terms tie that office to those two cases. Whether either officer exists whenever a declaration may be sent, and whether a declaration with no addressee takes effect, are not stated (U54). | Where it does not take effect: the inability path closed by a House's inaction, an unable President keeping the powers or a President unable to hand them over under §3, cl. 6's devolution (O10, U48) the only path left. Conditional on U54. | `constitution-paged.txt:1733-1767` (p.31); `constitution-paged.txt:268` (p.8); `constitution-paged.txt:324-326` (p.9) | SP4, BC35, O4, O5, O10; properties 2, 5 | none |
| M6 (D) [corrected] | (6) by the members from more than one third of the States withholding the quorum, or by no majority of all the States forming; (7) by no majority of the whole number forming | BC11, the contingent elections, whose failure defaults only to an acting President (O7, DA6) | B2 | Where no person has a majority "the House of Representatives shall choose immediately, by ballot, the President" (`constitution-paged.txt:1030-1031` (p.21)), its quorum "a member or members from two-thirds of the states" and "a majority of all the states" necessary (`constitution-paged.txt:1033-1035` (p.21)); the Senate chooses the Vice President with "a majority of the whole number" necessary (`constitution-paged.txt:1044-1047` (p.21)). No line of Amendment XII attaches a consequence to failure, the fourth-of-March sentence being superseded on the editor's statement (`constitution-paged.txt:1063` (p.21), DG4). At the time fixed "the Vice President elect shall act as President until a President shall have qualified" (`constitution-paged.txt:1455-1459` (p.27), O7), and where neither has qualified the person a law names acts (`constitution-paged.txt:1459-1464` (p.27), DA6). How a divided State's vote is fixed, and whether "immediately" bounds the choice, are not stated (U60). | The executive power held by the Vice President elect, or by the officer a law names, for as long as no choice is made, on the act of a group short of the majority the choice needs. The Vice President elect branch stands on the lines; the law's branch is conditional on U6. | `constitution-paged.txt:1028-1047` (p.21, Amdt. XII); `constitution-paged.txt:1455-1464` (p.27, Amdt. XX §3) | BC11, O7, DA6, DA7, E23, E22; properties 1, 8 | none; O7 and O12 end the acting only on a qualification |
| M7 (E) [corrected] | (8), with the position that recognises "intervened", not named (U24); (3) by a writ | O9's condition, "until an election of Representatives shall have intervened" | B2 | A law varying the members' compensation is held by O9 (`constitution-paged.txt:1858-1860` (p.32)). A House vacancy is filled by an election the State's executive orders by writ (`constitution-paged.txt:264-266` (p.8)). Whether such an election is "an election of Representatives" is not settled (U24). Where it counts, the halt releases on one writ for a genuine vacancy by the text's own terms: no position gains what the text does not grant, and the single-act release is O9's self-defense gap (GR6), not a row. Where it does not count, the gain stands only where the position that recognises "intervened", which no line names, treats such an election as one. | The members' compensation varied before an election of Representatives intervened, the halt O9 holds the law for. Conditional on U24. | `constitution-paged.txt:1858-1860` (p.32, Amdt. XXVII); `constitution-paged.txt:264-266` (p.8, Art. I §2 cl. 4) | O9, H2, PR6, OC6; property 3 | O9 holds the law until an election; which election is not settled |
| M8 (E) | (8) | DA22: the enforcement powers, "Congress shall have power to enforce this article by appropriate legislation" | B2 | Seven articles mint legislative power bounded by "appropriate" (`constitution-paged.txt:1085-1086` (p.22, Amdt. XIII §2); `constitution-paged.txt:1168-1169` (p.23, Amdt. XIV §5); `constitution-paged.txt:1216-1217` (p.24, Amdt. XV §2); `constitution-paged.txt:1398-1399` (p.26, Amdt. XIX); `constitution-paged.txt:1628-1629` (p.29, Amdt. XXIII §2); `constitution-paged.txt:1678-1679` (p.30, Amdt. XXIV §2); `constitution-paged.txt:1820-1821` (p.32, Amdt. XXVI §2)); the bound is read by a court in a case (BC9); whether any other check reads it is not stated (U58). | Legislation past "appropriate" executed until a court finds otherwise; the same defect as E29 at a different mint. Conditional on U58. | the seven lines above | BC28, BC9, OC14, DA22; property 3 | BC9, a person's |
| M9 (E) [corrected] | (8), without the consent of the legislatures of the States concerned | DA21: admission of new States, a mint of Senate seats, Representatives, electors and ratifying States | B2 | "New States may be admitted by the Congress into this Union; but no new State shall be formed or erected within the Jurisdiction of any other State; nor any State be formed by the Junction of two or more States, or Parts of States, without the Consent of the Legislatures of the States concerned as well as of the Congress" (`constitution-paged.txt:746-751` (p.15)); the vote admission takes is not stated. Whether the restriction is read by any position is not stated (U61). Each State carries two Senators (`constitution-paged.txt:1294-1295` (p.25)), at least one Representative (`constitution-paged.txt:255-256` (p.8)), electors (`constitution-paged.txt:550-553` (p.12)) and a place among the three fourths that ratify (`constitution-paged.txt:779-782` (p.16)). | A State formed within another's jurisdiction, or by junction, without the consent the text requires, carrying its Senate seats, Representatives, electors and ratifying vote, and so every supermajority denominator. An admission within the restriction changes the same denominators as a granted power, which gives no row. Conditional on U61. | `constitution-paged.txt:746-751` (p.15); `constitution-paged.txt:1294-1295` (p.25); `constitution-paged.txt:779-782` (p.16) | BC18, BC28, OC16, DA18, DA21; property 3 | none |
| M10 (E) [corrected] | (8); (2) for the States' part of `constitution-paged.txt:1162-1166` (p.23) | OC18 and OC19: bars on Congress's acts with no observer: "all Duties, Imposts and Excises shall be uniform throughout the United States" (`constitution-paged.txt:430-431` (p.10)); "No Tax or Duty shall be laid on Articles exported from any State" (`constitution-paged.txt:496-497` (p.11)); no preference "by any Regulation of Commerce or Revenue" to the ports of one State, and no vessel bound to or from one State "obliged to enter, clear, or pay Duties in another" (`constitution-paged.txt:498-499` (p.11); `constitution-paged.txt:508-509` (p.12)); "No Title of Nobility shall be granted by the United States" (`constitution-paged.txt:516` (p.12)); revenue bills "shall originate in the House" (`constitution-paged.txt:396-398` (p.10)); forfeiture on an attainder of treason only "during the Life of the Person attainted" (`constitution-paged.txt:720-721` (p.15)); the electors' day "the same throughout the United States" (`constitution-paged.txt:589-591` (p.13)); "no religious Test shall ever be required as a Qualification to any Office or public Trust under the United States" (`constitution-paged.txt:806-807` (p.16)); the validity of the public debt, "authorized by law", "shall not be questioned", and no insurrection debt assumed or paid by the United States or any State (`constitution-paged.txt:1159-1166` (p.23)) | B2 | Each is a standing bar with no stated mechanism reading the act against it, applied by a court in a case (BC9); no line names a reader of the origination rule beyond each House's rules (`constitution-paged.txt:357` (p.9)). Like E12 and E17, the row stands on the lines. | A law or a State act against any of these bars in force and executed until a court finds otherwise: a non-uniform or export duty, a port preferred, a title granted, a forfeiture past the attainted person's life, electors voting on different days, a religious test required as a qualification to an office or public trust under the United States, the validity of the public debt authorized by law questioned, or an insurrection debt paid. | the lines above | OC18, OC19, BC9, BC7, BC28; property 3 | BC9, a person's |
| M11 (D) [corrected] | (17) the Acting President's inability; (10), (11) by not declaring | OC17: the Vice President, while Acting President, "unable" | none, a physical condition; B2 | Sections 3 and 4 name "the President" as the subject of every declaration (`constitution-paged.txt:1733-1747` (p.31)); whether "the President" there includes an Acting President is not stated (U66, new). The case of inability "both of the President and Vice President" goes to a law (`constitution-paged.txt:603-605` (p.13)), not in the document (U28). A Vice President who has become President under `constitution-paged.txt:1718-1720` (p.30) is "the President" and outside this row. | The executive power held by an Acting President unable to discharge it, with no mechanism, for as long as no declaration reaches him and the law provides nothing a position acts on. Conditional on U66 and U28. | `constitution-paged.txt:1733-1747` (p.31); `constitution-paged.txt:600-607` (p.13) | OC17, O10, DA4, DA5, DA6; properties 3, 7 | none |

**M2, dropped.** The Vice President "shall be President of the Senate"
(`constitution-paged.txt:321-322` (p.9)) and the Senate has "the sole Power to try all Impeachments"
(`constitution-paged.txt:328-329` (p.9)); the text substitutes the Chief Justice only "When the
President of the United States is tried" (`constitution-paged.txt:330-331` (p.9)). Whether the
chair at his own trial is his is not settled by the document (U55); where the lines grant it, he gains nothing he lacked, the rule the first verification
applied to SE2, SE8 and SE12. The substitution is a person's arrangement inside BC5; its absence
for the Vice President's trial is a like act skipping a person's check, recorded with BC5 for later
chain steps ("Links made of people count"), never a row. U55 stays open.

**M3, merged into E9.** The Vice President's vote "unless they be equally divided"
(`constitution-paged.txt:321-322` (p.9)) in the Senate's choice of a Vice President, where "a
majority of the whole number shall be necessary" (`constitution-paged.txt:1046-1047` (p.21)), is
E9's act: a vote whose condition the Senate counts and no mechanism reads, entered from the same
position (10). Where the vote is granted in that choice, he gains nothing; where it is not (U56),
the gain is E9's, and the choice of a Vice President is E9's widest question (in its row). His
presiding over the choice is granted at `constitution-paged.txt:321` (p.9). One defect is one row.

### Rows dropped in verification

- **E35** (SE2, the members' privilege). Dropped. The privilege is granted at the exclusion's own
  lines (`constitution-paged.txt:382-387` (p.10)), so no member gains what it lacked, and the
  check left out is the courts' (BC9), a person's, which removes no observer. The rule the gap evaluation
  applied to SE9's impeachment branch decides it.
- **E37** (SE8 and RP7, exceptions to appellate jurisdiction). Dropped. Congress holds the
  power at the line (`constitution-paged.txt:694-697` (p.14)); RP7 removes a person's check,
  and the observer mapping records that no observer is removed.
- **E39** (SE12, suits against a State). Dropped. The limit is stated at the exclusion's own
  lines (`constitution-paged.txt:984-987` (p.20)) and leaves out the courts' check, a person's;
  no position gains what it lacked.

**Row count.** 66 rows in the STRIDE sections above (6 S, 6 T, 3 R, 1 I, 7 D, 43 E) and 9 found by
the chain hunt above (M1, M4 to M11: 1 T, 5 E, 3 D), 75 in all, counted by the section each sits
in. Nineteen stand on the lines alone for at least one entry (R1, R2, D1, D3, D4, D6, E4 for the
officers, E6, E8, E9, E10, E12, E17, E36, E41, E42, E43, M10 and M6's Vice President elect
branch); the other fifty-six are conditional on at least one unconfirmed item.

**Dispositions that give no row, verified.** SE2, SE8, SE12 (no position gains: granted at the
exclusion's own lines); SE4 and SE20 (refusals at the lines); SE5 and SE23 (no position gains);
SE9's impeachment branch (the Senate holds the trial power at `constitution-paged.txt:328`
(p.9)); SE17 (U17); SE18 (spent). SS1's orders, resolutions and votes:
either reading of U49 gives no row. The key record BC10: a B2 control's key binds nothing, and
no line shows two persons sharing a name. U10, U17, U37 and U38 stay unconfirmed and give no
row. BC6 against BC7 (judging qualifications without the two-thirds vote expulsion needs) stays
with the chain hunt.

---

## Part B. Chains

Order: source-supported, then conditional on an unconfirmed item, then design assumptions.
Each step carries its verdict at the lines. A step not stated makes a chain conditional; a
step is not stated only where a line puts its two ends in contact.

### Source-supported

None. Every surviving chain rests on at least one step the text does not state.

### Conditional on an unconfirmed item

#### X1. Supermajorities by exclusion [corrected]

**Entry points.** Confirmed against the rows' preconditions.
- Required, (6) or (7): a House judging "the Elections, Returns and Qualifications of its own
  Members" (`constitution-paged.txt:350-351` (p.9, Art. I §5 cl. 1)), BC6, by a vote the text
  does not state (U51).
- Optional, (6) and (7) together, for the acts that need two thirds of both
  (`constitution-paged.txt:767-768` (p.15, Art. V); `constitution-paged.txt:1762-1764` (p.31,
  Amdt. XXV §4); `constitution-paged.txt:1156-1157` (p.23, Amdt. XIV §3)).
- One branch, (6) impeaching: "the sole Power of Impeachment" (`constitution-paged.txt:268-269`
  (p.8)), with no vote stated.
- One branch, (9) making the treaty "by and with the Advice and Consent of the Senate"
  (`constitution-paged.txt:630-632` (p.13)).
- The reader: every judge for a law or treaty (`constitution-paged.txt:795-800` (p.16)); the
  Vice President for the office of President (`constitution-paged.txt:1718-1720` (p.30)).

**Steps.**
1. Corrected. Each House judges its members' qualifications with no vote stated
   (`constitution-paged.txt:350-351` (p.9)), and may "with the Concurrence of two thirds, expel a
   Member" (`constitution-paged.txt:357-359` (p.9)). The judging act (BC6) reaches a member's
   seat without the two-thirds check BC7 makes: a skip of a person's check, recorded for chains
   ("Links made of people count"). Whether a judgment of qualifications removes a sitting member
   is not stated (U51). The qualifications read are at the lines cited: age, citizenship and
   inhabitancy (`constitution-paged.txt:241-244` (p.8); `constitution-paged.txt:316-319` (p.9)),
   incompatibility (`constitution-paged.txt:393-394` (p.10)) and the insurrection disability
   (`constitution-paged.txt:1148-1157` (p.23)). Two corrections: for Senators and
   Representatives the finder of the disability is the House itself under BC6, as OC7 hazard row records, not "no finder"; what has no stated holder is the record of the prior
   oath the disability reads (`constitution-paged.txt:1151-1154` (p.23), E44, U20). And "a
   majority imposes what two thirds are needed to lift" holds only where the judging vote is a
   majority, which is U51.
2. Confirmed. "a Majority of each shall constitute a Quorum" (`constitution-paged.txt:351-352`
   (p.9)); whether a member judged out leaves the base is not stated (U51).
3. Confirmed. Each count is at its line with its own base: "two thirds of that House"
   (`constitution-paged.txt:406, 409` (p.10)); "two thirds of the Members present"
   (`constitution-paged.txt:331-332` (p.9)); "two thirds of the Senators present"
   (`constitution-paged.txt:631-632` (p.13)); expulsion (`constitution-paged.txt:358-359` (p.9));
   "two-thirds vote of both Houses" (`constitution-paged.txt:1762-1763` (p.31)); "two-thirds of
   each House" (`constitution-paged.txt:1156-1157` (p.23)); "two thirds of both Houses"
   (`constitution-paged.txt:767` (p.15)). The text names no counter for any of them; each House
   sets "the Rules of its Proceedings" (`constitution-paged.txt:357` (p.9)).
4. Confirmed. A law so passed binds "the Judges in every State" (`constitution-paged.txt:798-800`
   (p.16)) where it is one "made in Pursuance thereof" (`constitution-paged.txt:795-796` (p.16)); conviction removes "The President, Vice President and all civil Officers"
   (`constitution-paged.txt:665-668` (p.14)), and "the Vice President shall become President"
   (`constitution-paged.txt:1718-1720` (p.30), O3); a determination keeps the Vice President
   acting (`constitution-paged.txt:1764-1765` (p.31)); a treaty is "the supreme Law of the Land"
   (`constitution-paged.txt:795-798` (p.16)).
5. Corrected. In the House's choice of a President "the votes shall be taken by states"
   (`constitution-paged.txt:1031-1033` (p.21)) with "a majority of all the states" the threshold
   (`constitution-paged.txt:1035` (p.21)). A delegation wholly judged out casts no vote while the
   threshold stays, which makes a choice harder, not easier, and members from two thirds of the
   States make the quorum (`constitution-paged.txt:1033-1035` (p.21)). What exclusion reaches here
   is the vote of a State whose members divide, where judging out some of them can change its one
   vote; how that vote is fixed is not stated (U60). The step feeds no part of the combined
   impact below; it is kept as a branch conditional on U51 and U60, and a choice blocked this way
   leads into M6.

**Seam crossed.** Confirmed: each House's judgment of its own membership, an internal B2 control
of the lawmaking subsystem, into the supermajority checks the text sets on the executive, the
judges, the office of President and the text itself. Line 406 takes "that House" by name, the
membership step 1 alters; the step between them, whether the judged member leaves the base, is
U51.

**Combined impact.** Confirmed, conditional on U51. Where the judging vote is a majority and a
member judged out leaves the base, a majority of a House reaches what the text reserves to two
thirds: a law over the President's objections; a conviction after the House's impeachment, the
office then passing by O3; the §4 determination that keeps the Vice President acting (X3); a
treaty; a proposal of amendments, which reaches nothing until ratified
(`constitution-paged.txt:779-781` (p.16)); and a disability imposed through the judgment that only
two thirds of each House can remove. BC6's skip of BC7 alone reaches one seat. Halt: none; names
are entered only "at the Desire of one fifth of those Present" (`constitution-paged.txt:363-365`
(p.9), R2), the override alone requiring them (`constitution-paged.txt:410-412` (p.10)).

**Composition [corrected].** BC6 skipping BC7, with U51 for the base, feeding BC2 (override),
BC5 with O3 (conviction, removal, succession), BC4 (treaties), BC13 (the §4 determination), BC15
(proposal) and BC17 (the disability's removal); OC7 and E44 as the qualifications and the
unheld oath record the judgment reads. E8 is removed from the composition: its gap, acts by
less than a majority read by no stated check, is the input of no step, and the quorum's base is U51's
question. Conditional on U51 (and U60 for step 5's branch).

#### X2. Recess commissions regranted across sessions [corrected]

**Entry points.** Corrected.
- Required, (9): the President granting commissions "to fill up all Vacancies that may happen
  during the Recess of the Senate" (`constitution-paged.txt:650-652` (p.14, Art. II §2 cl. 3),
  DA2, E20).
- Precondition, not an entry that gains: (7) withholding its advice and consent
  (`constitution-paged.txt:630-646` (p.13-14), BC4), the state the chain bypasses.
- Optional, corrected from required, (9): adjourning the Houses "in Case of Disagreement between
  them, with Respect to the Time of Adjournment" and convening them "on extraordinary Occasions"
  (`constitution-paged.txt:657-660` (p.14, Art. II §3), RP4, BC23); or (6) and (7) ending a
  sitting by their own adjournment (`constitution-paged.txt:367-369` (p.9), BC32).
- The reader: whoever honours the commissioned officer (U31).

**Steps.**
1. Confirmed. The Senate withholds consent to a nominee (`constitution-paged.txt:632-646`
   (p.13-14)); the office stays vacant.
2. Confirmed. In a recess the President grants a commission (`constitution-paged.txt:650-652`
   (p.14)); whether the vacancy is one "that may happen during the Recess" is read by no stated
   position (U22, E20).
3. Confirmed. The commission "shall expire at the End of their next Session"
   (`constitution-paged.txt:651-652` (p.14), O8, H1), and the office stands vacant (D4); whether
   a vacancy left by the expiry is one that happens "during the Recess" is not settled (U53).
4. Corrected. The President's adjournment on disagreement (`constitution-paged.txt:659-660`
   (p.14)) and his convening (`constitution-paged.txt:657-658` (p.14)) set when some sessions end
   and begin, but the regrant needs only a recess after the expiry. An adjournment he makes ends
   his own commission sooner where it ends the session, which is not settled by the document; it gives him the timing, not the
   holding. The step is optional, not a link; whether a session he convenes is a "Session" for
   the expiry is U53.
5. Confirmed. At the recess a new commission is granted for the same office (C6; D4
   names the refill).

**The join.** One line puts the ends in contact: `constitution-paged.txt:650-652` (p.14) makes
the commission expire "at the End of their next Session" and grants the power over "Vacancies
that may happen during the Recess". The step not shown is U53. Read one way, each regrant is
within the power, and H1's halt produces the vacancy the next grant fills: a halt that degrades
into a continue. Read the other way, each regrant is outside the restriction and passes through
E20's gap (U22). Either way the regrant follows.

**Seam crossed.** Confirmed: the Senate's sitting into the executive subsystem's appointments and
the Senate's consent (BC4).

**Combined impact.** Corrected. An office "established by Law" (`constitution-paged.txt:645-646`
(p.14)) held by the President's commissioned officer across successive sessions while the Senate
withholds consent. E20 alone reaches one commission, to "the End of their next Session"; D4 names one refill, not the succession. The
President's control of session timing is an optional branch, not part of the reach. Whether the
Senate's refusal ends a commission early is not stated (U22). Halt: H1 ends each commission;
no stated position reads the next grant.

**Composition [corrected].** DA2 and E20 (the recess-vacancy restriction read by no stated check) + H1
and D4 (the expiry that leaves the vacancy) + C6 (the regrant), bypassing BC4; RP4 optional.
Conditional on U22 and U53.

#### X3. A forged majority held by a forged two thirds [corrected]

**Entry points.** Corrected.
- Required, (10) with fewer than a majority of (11): a §4 declaration without a true majority
  (`constitution-paged.txt:1740-1747` (p.31, Amdt. XXV §4), S2, RB4, U4). Confirmed against S2.
- Required, one of three: (18) a writer of either Journal other than the House (S4, RB5, U27),
  confirmed against S4; (6) and (7), a majority of each House recording a two-thirds
  determination not reached, an entry tested as a gap and held by S4
  conditional on U64 (in its row); or majorities producing two thirds by exclusion (X1,
  U51).
- Optional, (6) and (7): the Speaker and the President pro tempore holding "receipt"
  (`constitution-paged.txt:1755-1762` (p.31), T6, U5).
- Optional, corrected from "(9) as Acting President" to (10) as Acting President, who assumes
  "the powers and duties of the office" (`constitution-paged.txt:1745-1747` (p.31)): commissions
  in a recess to vacancies among the principal officers (`constitution-paged.txt:650-652` (p.14),
  DA2, E20); whether officers so commissioned are "principal officers" for §4 is not stated (U4).
- The reader: whoever honours an act of the Acting President (DA5, U31).

**Steps.** All six confirmed at their lines: the assumption "immediately"
(`constitution-paged.txt:1745-1747` (p.31)); the President's declaration "that no inability
exists" (`constitution-paged.txt:1749-1751` (p.31)); the second declaration "within four days"
(`constitution-paged.txt:1752-1758` (p.31)); "Congress shall decide the issue", assembling
"within forty-eight hours" and deciding within twenty-one days "after receipt of the latter
written declaration" (`constitution-paged.txt:1758-1761` (p.31)); the determination "by
two-thirds vote of both Houses" on which "the Vice President shall continue"
(`constitution-paged.txt:1760-1765` (p.31)); and no further window stated after a determination
(U62).

**The join.** `constitution-paged.txt:1760-1761` (p.31) takes "the latter written declaration",
the second forged declaration, as the start of O5's window while Congress is in session, and otherwise the time Congress "is required to assemble" (`constitution-paged.txt:1761-1762` (p.31)); `constitution-paged.txt:1762-1765`
(p.31) takes the determination, the forged record or the excluded count, as O5's condition. S2's
output is the next gap's input at the lines.

**Seam crossed.** Confirmed: the declaration path (SP4) into the Journals (SP1) and back onto the
executive power.

**Combined impact.** Confirmed. The executive power held by the Vice President with neither a
true majority of the principal officers nor a true two thirds of both Houses, and no stated end
(U62). S2 alone ends at the windows unless Congress genuinely determines; S4 alone needs a
declaration path to reach the determination. Halt: none; the windows are the default (E43).

**Composition [corrected].** S2 (RB4 unbound, U4) + S4 (RB5, U27, or its added House entry, U64)
or X1 (U51), with T6 (U5) and DA2 with E20 (U22) optional. Conditional on U4 and on one of U27,
U64 or U51; on U62 for the open end; on U5 and U22 for the optional branches. The chain hunt's
list (U4, U27, U5) named U5, which belongs to an optional branch, and omitted U62.

#### X5. The President's adjournment into the pocket [corrected]

**Entry points.** Confirmed: (9) holding a presented bill and adjourning the Houses on their
disagreement (`constitution-paged.txt:657-660` (p.14), BC23, RP4); the precondition (6) and (7)
disagreeing "with Respect to the Time of Adjournment" (`constitution-paged.txt:658-659` (p.14)).

**Steps.**
1. Confirmed. Presentment (`constitution-paged.txt:400-402` (p.10)).
2. Confirmed. The President "may adjourn them to such Time as he shall think proper"
   (`constitution-paged.txt:659-660` (p.14)); no line limits when within the ten days he may do so.
3. Corrected. "unless the Congress by their Adjournment prevent its Return, in which Case it shall
   not be a Law" (`constitution-paged.txt:415-417` (p.10)). Two steps are not stated, not one:
   whether an adjournment the President makes is "the Congress by their Adjournment", and whether
   that adjournment prevents the return, which the first verification leaves open for adjournments of
   three days or less (H3). U52 is widened to carry both.
4. Confirmed. Objections and reconsideration both rest on a return
   (`constitution-paged.txt:403-409` (p.10)).

**The join.** `constitution-paged.txt:415-416` (p.10) takes an adjournment of the Congress by name
as its input; `constitution-paged.txt:659-660` (p.14) produces an adjournment of "them", the two
Houses. The step between them is U52.

**Seam crossed.** Confirmed.

**Combined impact.** Confirmed. The President defeats a presented bill with no objections entered
and no reconsideration, a defeat the text otherwise gives him only subject to two thirds of each
House (`constitution-paged.txt:405-409` (p.10)). RP4 alone gives him the Houses' adjournment and
nothing of the bill; SE4 alone is the Houses' act, a refusal for them. Halt: corrected as to
source: H3 records the bill's death as propagating to "the bill alone"; the phrase
the chain hunt quotes is not in E42.

**Composition [corrected].** BC23 and RP4 (the President's adjournment) into RP1 and SE4 (O1
removed for a presented bill), bypassing BC2. D2 and E36 are removed: the presenter's timing (D2)
and the Houses' own adjournment (E36's basis) are the input of no step here. Conditional on U52.

#### X7. Custody of the President into the devolution on inability (new)

Opened by the re-test of candidate 16 and of the forged-record candidate against the named widest
reach of E46 and E12 (in its row).

**Entry points.**
- One of two routes into custody:
  - (3) a State's executive: delivery on demand of "A Person charged in any State with Treason,
    Felony, or other Crime, who shall flee from Justice, and be found in another State" (`constitution-paged.txt:734-738` (p.15,
    Art. IV §2 cl. 2), E46, U21); no line exempts the President.
  - (8) with two thirds of each House over the President's return: a "Bill of Attainder", a term
    the text does not define (`constitution-paged.txt:492` (p.11), E12), barred at the line and applied by a
    court in a case (BC9); the act needs presentment (`constitution-paged.txt:400-402` (p.10)).
- Gains: (10) the Vice President, who receives the powers.

**Steps.**
1. The President is in custody by one of the routes above.
2. Whether a President in custody is under "Inability to discharge the Powers and Duties of the
   said Office" (`constitution-paged.txt:600-602` (p.13, Art. II §1 cl. 6)) is not stated (U65,
   new).
3. For an inability no §3 or §4 declaration reaches, "the Same shall devolve on the Vice
   President" (`constitution-paged.txt:602-603` (p.13), O10), with no position named to recognise
   the inability (U48) and no declaration needed. What "devolve" carries is not settled (DG3), and
   no line fixes when the devolution ends.

**The join.** `constitution-paged.txt:600-602` (p.13) takes the President's state by name, and
custody is the state the first step produces; the step between them is U65.

**Seam crossed.** The federal-State delivery of persons, or Congress's
lawmaking, into the succession and inability subsystem.

**Combined impact.** The executive power devolved on the Vice President by a demand
or an act no stated mechanism reads, with no declaration, no recogniser and no stated end; the act's bar is read by a court in a case (BC9). E46 and E12
alone each reach a person in custody or punished; O10 alone acts on an inability the text names
no one to find (D7 holds the reverse case, an unable President who keeps the powers). Halt: none.

**Composition.** E46 (U21) or E12 (with two thirds over a return), feeding O10 (U48).
Conditional on U65 and U48, and on U21 for the demand route.

### Design assumption

None. The chain hunt's one candidate needing a law to read a certain way (the recipient who
succeeds) stays rejected as held by E22 (the rejected list).

---

## Part C. Rejected chain candidates

Each entry gives the verdict on the chain hunt's reason at its lines, then the test of every row
the candidate joins or was held by under "The widest reach is named", and the re-test against
any addition. Every rejection below stands.

### Dropped after the chain hunt

- **X4, a State's war into the Union's.** Dropped: the gaps do not join. Step 1 holds: a State
  may not, "without the Consent of Congress", "engage in War, unless actually invaded, or in such imminent Danger as will not admit
  of delay" (`constitution-paged.txt:537-541` (p.12)), and no line names who judges whether the State is
  actually invaded or in such danger (E13, SE10, U34). Step 3 holds as to the text: the United States "shall
  protect each of them against Invasion" (`constitution-paged.txt:760-761` (p.15)), the
  application clause reaching "domestic Violence" only (`constitution-paged.txt:761-763` (p.15)),
  with no finder named (U59). Step 4 is corrected: the militia is called forth under the
  provision Congress makes (`constitution-paged.txt:465-466` (p.11)), a law not in the document,
  and the President commands it "when called into the actual Service"
  (`constitution-paged.txt:621-623` (p.13)). Step 2 is not a gap's effect: the text does not say
  who invades, and no line makes the State's war produce an invasion, or takes any judgment of
  the State's condition into the Union's protection. The protection attaches to an invasion whether or not
  a State began a war, so E13 and the protection duty are parallel. Restated without the
  invasion: a judgment that a State is "actually invaded", by a position no line names (U34),
  feeding the Union's protection directly. It fails too: no line takes that judgment as the
  Union's input, and the one clause that
  takes a State's input in Art. IV §4, the application, is confined to domestic violence at its line. What the
  lines say instead, tested as a gap: the protection against invasion names no finder (U59).
  The hazard is held by OC17 row ("Invasions": none; BC25, BC34); no position gains
  what it lacked, the command and the calling forth being granted at
  `constitution-paged.txt:621-623` (p.13) and `constitution-paged.txt:465-466` (p.11). No row; U59
  stays open. The rows X4 joins (E13, PR2's E45 by reference, BC25, BC34) name no "any" impact.
- **X6, detention without the writ into the counts of those present.** Rejected: its premise
  fails. The chain rested on a suspension of the writ removing the check on detention, so that
  "the detention E11 permits" kept members from the counts of those present. The suspension
  clause states only when "The Privilege of the Writ of Habeas Corpus" may be suspended
  (`constitution-paged.txt:489-491` (p.11)); it names no issuer of the writ and states no effect
  of it, so whether a suspension removes any check is not settled by the document (U67).
  Restated without the premise, adding none in its place: the writ suspended by a body no line
  names (E11, SE6, U15); members of a House arrested on a charge of "Treason, Felony and Breach
  of the Peace", which the privilege from arrest excepts (`constitution-paged.txt:383-385`
  (p.10)); the counts of "the Members present" and "the Senators present"
  (`constitution-paged.txt:331-332` (p.9); `constitution-paged.txt:631-632` (p.13)), and on to
  conviction and treaties as in X1's fourth step. No line puts the suspension in contact with an
  arrest or a detention: the suspension clause takes no detention, and the privilege's line does
  not take the writ, so E11 does not join the next step. What remains, an arrest on an excepted
  charge, is left outside the privilege at the exclusion's own lines (SE2: no position gains;
  E35 dropped), and the counts it would reach are the text's rules, so it joins no gap; whether
  an arrested member is kept from attending is not settled by the document. The restatement
  fails, and its reach exceeds no single row's: E11 alone reaches the privilege suspended, its
  reach not stated (U67). What the
  lines say in place of the premise, tested as a gap, is the suspension by a body no line names,
  E11's own gap (in its row). E11, the row X6 joined that read "any person", names the privilege
  with no person stated more privileged than another under the act (in its row). The quorum
  branch (Still unsettled) rested on the same premise.

### The chain hunt's rejections

- **Candidate 1, presentment timed to an adjournment (D2, E36, E42).** Confirmed. D2's threat
  already holds the join, "timing presentment so an adjournment falls within the ten days turns
  the default into 'it shall not be a Law'", at `constitution-paged.txt:400-402, 412-417` (p.10).
  D2's impact, "a passed bill", reaches no more under one bill than another. E36 is corrected as to holding the session open; the correction touches recess commissions, not this
  join, and the re-test leaves the rejection standing.
- **Candidate 4, the Vice Presidency left vacant to disarm §4 and cl. 6 (D5, D7, E43, O10).**
  Confirmed at `constitution-paged.txt:1718-1723` (p.30), `constitution-paged.txt:1740` (p.31) and
  `constitution-paged.txt:600-607` (p.13). D5 names the impact; with no Vice President no §4
  declaration has a maker, so O4's window never opens and E43 adds nothing.
- **Candidate 5, the lists and the count (E1, E2, E27, E28, I1).** Confirmed. E1 for (18) reaches
  who "shall be the President" (`constitution-paged.txt:1023-1028` (p.21)), the widest grant; the
  others reach the same office or the same count, except I1, which reaches the lists' content before the count (Part D, entry 12).
- **Candidate 6, the enumeration into the count and the House (T2, E1, E2, E18).** Confirmed, the
  addition to T2 corrected. The failed premise is confirmed: the House's choice is "taken by
  states, the representation from each state having one vote" (`constitution-paged.txt:1031-1033`
  (p.21)), which apportionment does not reach. What the lines say instead, tested as a gap: one
  vote per State is the text's own rule, granted at the line, and no position gains from it. The
  restatement is held by T2 with the addition in its row, which names each State's weight in
  the count, not the office: the outcome follows from the electors' votes, not from another gap.
  Corrected in wording: the chain hunt's addition said the apportionment "reaches the office of
  President".
- **Candidate 7, inferior officers and commissions (E21, E26, E44, E19).** Confirmed. Each of the
  four rows named "any" office or officer; each is given its widest office in its row (a
  principal officer, whose office carries a place in the §4 majority at
  `constitution-paged.txt:1740-1741` (p.31), and a judge of the supreme Court for E19; the
  President's own office for E44). Re-tested: E21 and E26 reach the principal office by two
  routes, which add; E44 and E19 reach the office held, in parallel. The rejection stands. A join
  of either route into the §4 path is an open question (Still unsettled).
- **Candidate 8, amendment by ratifications no named position counts (T4, E33).** Confirmed: two
  missing checks on one act at `constitution-paged.txt:779-787` (p.16), both under U19. T4 takes
  the addition in its row.
- **Candidate 9, a Congress that does not assemble or decide (D1, E43, PR1).** Confirmed: E43's
  entry and impact hold the join at `constitution-paged.txt:1758-1767` (p.31).
- **Candidate 11, a returned bill delivered to the wrong House (NO4, T1).** Confirmed as no chain:
  one act with two effects. The gain is recorded as M1, corrected among the chain hunt's rows.
- **Candidate 13, the pardon after an impeachment conviction (E31, E34, E4).** Confirmed, the
  reason corrected in wording. The chain hunt says the later "Indictment, Trial, Judgment and
  Punishment, according to Law" (`constitution-paged.txt:337-338` (p.9)) is an offence "the grant
  itself reaches, no gap being needed". At the lines, whether that prosecution falls under "Cases
  of Impeachment" (`constitution-paged.txt:627-628` (p.13)) is not settled (U33). Either way E31's
  impact, "a case of impeachment included", holds it. E34 and E4 named "a judgment" and "the
  office" without the most privileged person; both name the President in its row, and the
  re-test leaves the rejection standing.
- **Candidate 14, the President of the Senate as a person voted for (E2, E27, E28, BC10, BC11).**
  Confirmed. E2's entry includes (10) and its impact names both offices
  (`constitution-paged.txt:1023-1028, 1040-1047` (p.21)). M3 is merged into E9 (among the chain hunt's rows), whose
  widest question is the Senate's choice of a Vice President. Re-tested against it: E2 and E9
  reach the office of Vice President by two means, which add.
- **Candidate 15, a death recognised by no position, then the §2 nomination (S3, D5, R2).**
  Confirmed. S3 reaches the office for the term (`constitution-paged.txt:1718-1720` (p.30)); the
  nomination is granted (`constitution-paged.txt:1722-1731` (p.30-31)); R2 adds a missing record.
- **Candidate 16, the writ suspended with forces in a State (E11, E45, E12, C7).** Confirmed as
  composed. E11 and E12 named "any person" without the most privileged one. E12 names the
  President (reach not stated, U65, in its row). The suspension clause names no person and
  states no effect of the writ (`constitution-paged.txt:489-491` (p.11)), so E11 names the
  privilege with its reach not stated (U67, in its row). Re-tested: E45 and E12 do not join E11,
  so the candidate as composed still adds. E12's named reach opens a join no candidate held,
  tested with the chains and kept as X7 (the President, into O10); the join of E11 into the
  counts of those present, opened by the same re-test as X6, rested on a detention the
  suspension clause does not state and is rejected (X6, above).
- **Candidate 17, one law setting who declares and who acts (E22, E41, E43).** Confirmed. The
  failed premise is confirmed at `constitution-paged.txt:1740-1745` (p.31): §4's co-maker is "the
  Vice President", and the officer a law names acts, in the cases the lines state, for "both"
  (`constitution-paged.txt:603-607` (p.13)) or where neither elect has qualified
  (`constitution-paged.txt:1459-1464` (p.27)). What the lines say instead (the Vice President as a
  co-maker with no substitute) is RP12 and D5's gap, already recorded, RP12 as a removal path and D5 as a row. The restatement is held by D5
  and E22.
- **Candidate 18, a text presented as law with a class excepted from review (S6, E30, E29, RP7).**
  Confirmed. E29 named "an officer" without the most privileged one; it names the President in its row, with the reach of a law vesting power in him beyond the enumerated powers not stated
  (U43, widened). The re-test leaves the rejection standing: the reach is S6's and E29's own.
- **Candidate 19, the Treasury draw, the statement and the cap (T5, R3, E5).** Confirmed: one
  absent reader (U11) at `constitution-paged.txt:511-514` (p.12) and
  `constitution-paged.txt:460-461` (p.11).
- **Candidate 20, a holder past the term with a count that fails (E3, E2, E23, H4).** Confirmed,
  the quotation corrected: E3 reads "The office's powers held past the term; for the
  President, the executive power" (`constitution-paged.txt:1443-1447` (p.27)), not "until a
  position acts". A count that fails lengthens E3's precondition without widening its reach.
- **The recipient who succeeds (T6, D5, DA6, E22).** Confirmed as held by E22, whose impact names
  the executive power held past the end the text fixes (`constitution-paged.txt:603-607` (p.13);
  `constitution-paged.txt:1459-1464` (p.27)); the receipt of a declaration "that no inability
  exists" (`constitution-paged.txt:1749-1751` (p.31)) is one means past that end. The law's
  content is not in the document, so the candidate would otherwise be a design assumption; it
  adds no reach E22 lacks.
- **Writs withheld with a temporary appointee (D3, E25, O11).** Confirmed, the quotation
  corrected: the chain hunt quotes as D3's impact words that sit in D3's threat. At
  `constitution-paged.txt:1300-1305` (p.25) the executive issues the writs, with no time fixed,
  and an empowered executive's appointment lasts "until the people fill the vacancies by
  election"; the lines show the impact the candidate was held for, and D3's impact takes it as an
  addition (in its row). The rejection stands against the named impact.
- **A forged State record into an extradition demand (S5, E46).** Confirmed as composed. E46
  named "any person" without the most privileged one; it names the President (reach not stated,
  U65) and the members' privilege beside him (in its row). Re-tested: S5 still feeds a check that
  does not run, adding a means; E46's named reach is one route into X7.
- **A minority's acts recorded as the House's (E8, S4, R2).** Confirmed. E8 named "acts of the
  House" without the widest; it names impeachment and the choice of a Speaker in its row. The
  re-test leaves the rejection standing: S4 and R2 carry those acts without widening them.
- **Congress's pay varied before a general election (O9, PR6, U24).** Confirmed as no chain: one
  unconfirmed reading (U24), recorded as M7 and corrected among the chain hunt's rows.
- **A self-ratifying majority (S2, DA2, E20).** Confirmed as X3's optional branch. E20 named "any
  office" without the widest; it names a principal officer in its row, which is the branch X3
  uses.

Counts: 22 of the chain hunt's rejections confirmed; reasons corrected in wording for candidates
6, 13 and 20 and for the writs candidate; two chains (X4 and X6) added to the list. No rejected
candidate's restatement survived, X6's included; X7 is a join the re-tests opened, not a
restatement.

---

## Part D. Impact across the deployment

**Ordering rule, stated once.** One system with one installation: each risk is placed by what a
position gains in one act, times how many units one act reaches (an office, a State, a case, a
person, every State, every mechanism), then how far toward the floor the reach goes (part of the
system, the whole system, the public); a tie goes to the position that needs no privileged act.
Availability is not ranked. Rows conditional on an unconfirmed item are placed on what is stated
and marked. Each entry is placed by its rows' own impact; a link between rows is the chain hunt's.

1. **The office of President in one act, with no stated path back.** Confirmed. A death, removal or
   resignation recognised by no stated position makes the Vice President President for the term
   (`constitution-paged.txt:1718-1720` (p.30)). Conditional on U2. S3.
2. **The executive power in one act, as Acting President.** Confirmed. A §3 or §4 declaration
   whose origin or majority no stated position checks transfers the powers at once
   (`constitution-paged.txt:1737-1738, 1745-1747` (p.31)). Conditional on U3, U4. S1, S2.
3. **The office of President through the count.** Corrected: I1 removed. A list altered, forged
   or beyond the electors appointed, or a count by a counter not named against a denominator
   with no stated source, decides who "shall be the President" (`constitution-paged.txt:1023-1028`
   (p.21)). Conditional on U7, U8, U29, U32. E1, E2, E27, E28.
4. **The text itself, and the Senate's composition.** Corrected: E33's reach narrowed. A
   ratification not a legislature's or a convention's changes every mechanism and bar in one act
   (`constitution-paged.txt:779-781` (p.16)), an application not a legislature's reaching the text only through a proposal so ratified (`constitution-paged.txt:767-770` (p.15)); an amendment past the equal-suffrage proviso
   reaches the deprived State's suffrage and every act the Senate shares
   (`constitution-paged.txt:786-787` (p.16)). Both need the most privileged act in the text.
   Conditional on U19. T4, E33.
5. **The executive power by inaction, by the windows and by the acting offices.** Corrected as
   to bases. The President resumes by the others' default (`constitution-paged.txt:1766-1767`
   (p.31)); a declaration held by the two recipients, or its "receipt" recorded early or late, moves the window, the text naming no receiver for "receipt"; Congress may by law name the body that can declare
   (RP2); a determination recorded by writers not stated keeps the Vice President acting; an
   officer named by law, or the Vice President elect, holds the powers past an end the text fixes
   (O12, O7) with nothing stated to stop him; the office of Vice President left vacant removes
   the recipient of §1, §3 and cl. 6 and the maker of §4; an inability no position recognises
   leaves an unable President in place although cl. 6 makes the powers devolve. Conditional on
   U5, U6, U27, U28, U48. E43, T6, E41, S4, E22, E23, D5, D7.
6. **A law with or without the President.** Corrected: the President's adjournment-branch
   defeat removed (SE4, a refusal); E36's reach narrowed. The originating House's record of a
   return decides whether a bill "shall be a Law" (`constitution-paged.txt:412-415` (p.10)); the
   presenter's timing decides whether a bill the President neither signs nor returns lives or dies, where an adjournment prevents its return; the Houses' adjournment decides
   whether the President's inaction makes presented bills law or kills them, whether a given adjournment prevents the return being not settled by the document (H3); a default makes law
   on no affirmative act. Every law "made in Pursuance thereof" binds "the Judges in every State" (`constitution-paged.txt:795-800` (p.16)).
   Conditional on U26, U27 (T1), U1 (D2). T1, D2, E36, E42.
7. **Persons, at the public floor.** Confirmed, with C7's wording corrected.
   The privilege of the writ suspended by a body the text does not name, what the suspension
   reaches not stated (`constitution-paged.txt:489-491` (p.11)); a search or seizure beyond a warrant; delivery on a
   demand no stated position checks; a law against the bars executed until a court finds otherwise;
   punishment by legislative act; servitude on a conviction no other stated position reads; the forces
   brought into a State on one executive's application; cases in the forces on a process the
   text does not state. Conditional on U15 (E11; its reach on U67), U9 (E16), U21 (E46), U47 (E40), U39 (E45), U25
   (E38). E11, E16, E46, E17, E12, E40, E45, E38.
8. **The public money.** Confirmed. A draw with no named reader, an army appropriation past two years,
   and a statement written by no named position (`constitution-paged.txt:511-514` (p.12)).
   Conditional on U11. T5, E5, R3.
9. **Every judge, in every case.** Corrected: E37 and E39 dropped. A text presented as a law or
   treaty with no stated custodian and no stated check at the read; a treaty or law past the authority or the
   enumerated powers, read by no stated check but the judges' in a case; a State judge giving effect to contrary State
   law; officers removed on two bodies' votes, no other path stated, and judges by no stated path
   (`constitution-paged.txt:795-800` (p.16); `constitution-paged.txt:665-668, 674-676` (p.14)).
   Conditional on U42 (S6), U44 (E30), U43 (E29), U50 (E4's judges). S6, E30, E29, E10, E4.
10. **Offices held past their grant.** Confirmed. An appointment to an office not established
    by law or of a person within a bar; a recess commission outside the recess; an officer not
    inferior appointed without the Senate; a commission for an office not appointed to; an
    office entered without the oath; an emolument from a foreign state; a holder continuing
    past the term's end (`constitution-paged.txt:632-663` (p.13-14);
    `constitution-paged.txt:1443-1447` (p.27)). E7's foreign state needs no privileged act of its
    own. Conditional on U12 (E19), U22 (E20), U16 (E21), U31 (E26), U20 (E44), U35 (E7), U30
    (E3). E19, E20, E21, E26, E44, E7, E3.
11. **The representation of the States.** Corrected as to E25's basis. A count outside the
    enumeration rule reaches every State's representation and electoral weight in one act
    (`constitution-paged.txt:1128-1131` (p.22)); a State keeps full representation while the vote
    is denied; a State's war or imposts under an exception whose judge is not stated, or its compacts before consent, and troops where the war exception reaches them, which is not settled by the document; a
    Senate seat held without election, or past the election that ends it (O11); a writ for a seat
    not vacant or withheld; a record presented as a State's given credit in every other State.
    Conditional on U40 (T2), U13 (E18), U34 (E13, E14), U35 (E15), U14 (E24, E25), U41 (T3), U18
    (S5). T2, E18, E13, E14, E15, E24, E25, T3, D3, S5.
12. **Records and acts within the system.** Corrected: E35 dropped, I1 added. Proceedings
    withheld on each House's judgment; votes with no record of names; each State's votes known to
    the holder of the sealed lists before the count; acts by less than a quorum; the Vice
    President's vote where the Senate was not equally divided; compensation bars read by no mechanism; a
    pardon, a removal of disability or a judgment on impeachment past its scope; a Congress not
    assembled; a vacancy after a commission expires; the laws not executed
    (`constitution-paged.txt:361-365` (p.9); `constitution-paged.txt:1021-1025` (p.21)).
    Conditional on U32 (I1), U33 (E31), U45 (E32), U46 (E34). R1, R2, I1, E8, E9, E6, E31, E32,
    E34, D1, D4, D6.

Positions that need no privileged act of their own, corrected: a foreign state (entry 15) in
E7; a physical condition (entry 17) in D4, D5, D7 and M11. The gap evaluation also named entry 18 and E15: the
privilege of the writers not stated is not stated, and E15's entry is the State, a B2 position,
the foreign power being only the other party.

**The chain hunt's rows and the chains, placed by the same rule.** Each joins the entry whose
reach it shares. Entry 1: X1 and M4 (the office of President, through a conviction by fewer
than the text's two thirds or through a succession the two-term bar does not read). Entry 2: X3
(the executive power held as Acting President with no stated end). Entry 4: M9 (a State's Senate
seats, Representatives, electors and ratifying vote, and so every supermajority denominator).
Entry 5: X7, M5, M6 and M11. Entry 6: X5 and M1. Entry 7: M10. Entry 9: M8, beside E29. Entry 10:
X2. Entry 12: M7. E36's impact is narrowed by its correction and stays in entry 6. Each is
conditional as its row or chain states, except M10 and M6's Vice President elect branch, which
stand on the lines.

---

## Part E. Seams not followed

The evidence is a document, so there is no tree to count; the integration surface is counted from the
delegation boundaries listed below, each with its lines. The text leaves 42 matters to a document it
refers to but does not contain, made by 7 delegate positions:

| Delegate | Matters left to it | What is delegated |
|---|--:|---|
| Congress, by law or by each House's rules | 30 | each House's rules; attendance penalties; election regulations; the time of choosing electors and the day of voting; the manner of the enumeration; a different assembly day; the members' compensation; appropriations; laws "necessary and proper"; the forces and militia; the punishment of treason; quartering in war; trial districts; the officer who acts as President and the manner of selection; the death of a person from whom either House may choose; offices; inferior appointments; inferior courts; appellate exceptions; the place of trial outside any State; proof of State acts; new States; territory; consents to State acts; consents to emoluments; the mode of ratification; enforcement legislation; "such other body"; the District's electors; removal of the insurrection disability |
| The State legislatures | 3 | the manner of appointing electors; elections; temporary Senate appointments and the election that ends them |
| The State executives | 3 | writs of election; demands for delivery; applications for protection when the legislature cannot be convened |
| The States | 3 | militia officers and training; their own liquor laws; the qualifications of electors, whose maker the lines do not name |
| The issuer of warrants, not named | 1 | warrants |
| The writer of the statement of accounts, not named | 1 | the statement of accounts |
| The courts | 1 | the "rules of the common law" |

Each delegate is a B2 position, so a check left to it is a B2 control, never a delegation that covers
the check.

### The delegation boundaries

Listed, not followed.

Confirmed at every line the gap evaluation listed. Each is a law, rule, direction or consent the text leaves
to a position of the system, a B2 position, so a check left to it is a B2 control, never
"delegated"; each is a document the source refers to but does not contain, and every claim
resting on one stays marked as resting on a document not available:

- Congress: each House's rules and attendance penalties (`constitution-paged.txt:352-359`
  (p.9)); election regulations except the places of choosing Senators
  (`constitution-paged.txt:340-344` (p.9)); the time of choosing electors and the day of voting
  (`constitution-paged.txt:589-591` (p.13)); the manner of the enumeration
  (`constitution-paged.txt:251-254` (p.8)); a different assembly day
  (`constitution-paged.txt:1451` (p.27)); the members' compensation (`constitution-paged.txt:371-372` (p.9)),
  the President's and the judges' compensation naming no fixer at their lines
  (`constitution-paged.txt:609-610` (p.13); `constitution-paged.txt:676-678` (p.14));
  appropriations (`constitution-paged.txt:511-512` (p.12);
  `constitution-paged.txt:460-461` (p.11)); laws "necessary and proper", the forces and militia,
  the punishment of treason, quartering in war, trial districts
  (`constitution-paged.txt:463-483` (p.11); `constitution-paged.txt:719-721` (p.15);
  `constitution-paged.txt:899-901` (p.19); `constitution-paged.txt:950-952` (p.20)); the officer
  who acts as President and the manner of selection (`constitution-paged.txt:603-607` (p.13);
  `constitution-paged.txt:1459-1464` (p.27)); the death of a person from whom the House may choose a President or the Senate a Vice President (`constitution-paged.txt:1466-1471` (p.27)); offices, inferior appointments, inferior courts,
  appellate exceptions and the place of trial outside any State
  (`constitution-paged.txt:645-648, 672-674, 694-697` (p.14); `constitution-paged.txt:710-711`
  (p.15)); proof of State acts, new States, territory (`constitution-paged.txt:727-729, 746-755`
  (p.15)); consents to State acts and emoluments (`constitution-paged.txt:516-520, 529-541`
  (p.12)); the mode of ratification (`constitution-paged.txt:782-783` (p.16)); enforcement
  legislation (`constitution-paged.txt:1085-1086` (p.22); `constitution-paged.txt:1168-1169`
  (p.23); `constitution-paged.txt:1216-1217` (p.24); `constitution-paged.txt:1398-1399` (p.26);
  `constitution-paged.txt:1628-1629` (p.29); `constitution-paged.txt:1678-1679` (p.30);
  `constitution-paged.txt:1820-1821` (p.32)); "such other body", the District's electors, the
  removal of the insurrection disability (`constitution-paged.txt:1741-1742, 1753-1754` (p.31);
  `constitution-paged.txt:1614-1616` (p.29); `constitution-paged.txt:1156-1157` (p.23)).
- The State legislatures: the manner of appointing electors (`constitution-paged.txt:550-553`
  (p.12)); elections (`constitution-paged.txt:340-342` (p.9)); temporary Senate appointments
  and the election that ends them (`constitution-paged.txt:1302-1305` (p.25)).
- The State executives: writs, demands, applications when the legislature cannot be convened
  (`constitution-paged.txt:264-266` (p.8); `constitution-paged.txt:1300-1302` (p.25);
  `constitution-paged.txt:736-737, 761-763` (p.15)).
- The States: militia officers and training (`constitution-paged.txt:469-471` (p.11)); their
  own liquor laws (`constitution-paged.txt:1519-1522` (p.28)); the qualifications of electors of
  the most numerous branch, the lines naming the branch and not the maker of the qualifications
  (`constitution-paged.txt:237-239` (p.8); `constitution-paged.txt:1296-1298` (p.25)).
- The issuer of warrants, not named (`constitution-paged.txt:907-909` (p.19)).
- The writer of the statement of accounts, not named (`constitution-paged.txt:512-514` (p.12)).
- The courts: the "rules of the common law" (`constitution-paged.txt:962-964` (p.20)).

**Claims resting on a document the source refers to but does not contain.** Each stays marked as
resting on it wherever it is used:

- The law naming the officer who acts as President (Art. II §1 cl. 6; Amdt. XX §3): DA6, E22, E23, M6's law
  branch, M11, D5, D7, X7 (U6, U28, U48).
- The law providing "such other body" for §4 declarations: E41, RP2, SE19.
- Each House's rules (the presenter, the origin of a §3 declaration, the §4 majority, the receipt of
  declarations, the officers who receive them, the Journals' writers, the count of a two-thirds vote, the
  judging vote, a divided State's vote, the Vice President's vote in the Senate's choice, a recess
  commission's class and the session that ends it): D2, S1, S2, T1, T6, S4, R2, E8, E9, E20, M1, M5, X1,
  X2, X3 (U1, U3, U4, U5, U22, U26, U27, U51, U53, U54, U56, U60, U63, U64).
- The rules for transmitting and counting the electoral votes: E1, E2, I1, DA20, M4 (U7, U8, U12, U32, U54).
- The State legislatures' directions on electors and the empowerment of temporary appointments: DA11,
  E27, DA8, E24, E25 (U14, U29, U38).
- Congress's direction for the District's electors: DA12, E28.
- The law directing the enumeration: T2, E18 (U13, U40).
- Congress's general laws on proving State acts: S5 (U18).
- Congress's consents and its rules for the forces: E7, E13, E14, E15, E38 (U25, U34, U35).
- The laws establishing offices and vesting inferior appointments: E19, E21, E26 (U10, U12, U16, U31).
- The appropriation and Treasury laws: T5, E5, R3 (U11).
- The laws of the States and of Congress on delivery and on warrants: E46, E16 (U9, U21).
- The pay law and the State's election laws: M7, T3 (U24, U41).
- The law under which the United States responds to an application for protection: E45 (U39).

---

## Part F. Entry-point index

Every row and chain mapped to its entries, generated from the Entry cells of Part A and the entry points of Part B, the readers excepted. A row whose entry is "the writers not stated" is conditional for those writers on the unconfirmed item its cell names.

### By entry point

| Entry | Rows | Chains |
|---|---|---|
| (1) the voters and citizens | none | none |
| (2) a State's legislature | S5, T4, E12, E13, E14, E15, E17, E18, E27, E33, E40, E44, M10 (E) | none |
| (3) a State's executive authority | S5, T3, D3, E13, E15, E24, E45, E46, M7 (E) | X7 |
| (4) a State's ratifying convention | T4, E33 | none |
| (5) the electors | E1 | none |
| (6) the House of Representatives | S4, T1, T6, R1, R2, D1, D2, D5, E2, E3, E8, E33, E36, E43, E44, M1 (T), M4 (E), M5 (D), M6 (D) | X1, X2, X3, X5 |
| (7) the Senate | S4, T1, T6, R1, R2, D1, D2, D4, D5, E2, E3, E8, E19, E25, E30, E33, E34, E36, E43, E44, M1 (T), M4 (E), M5 (D), M6 (D) | X1, X2, X3, X5 |
| (8) the Congress acting by law | T2, D1, E5, E6, E12, E17, E21, E22, E28, E29, E32, E41, M7 (E), M8 (E), M9 (E), M10 (E) | X7 |
| (9) the President | D5, D6, E3, E4, E19, E20, E26, E30, E31, E42, E43, E44, M1 (T), M4 (E) | X1, X2, X5 |
| (10) the Vice President | S1, S2, S3, I1, D5, D7, E2, E3, E4, E9, E23, M4 (E), M11 (D) | X3, X7 |
| (11) the principal officers or the body Congress provides | S2, D7, M11 (D) | X3 |
| (12) judges and courts | S5, E4, E10, E40, E44 | none |
| (13) juries | none | none |
| (14) officers of the United States | T5, E4, E7, E16, E22, E38, E40, E44 | none |
| (15) foreign states and their subjects | E7 | none |
| (16) an insurgent or invading party | none | none |
| (17) none, a physical condition | D4, D5, D7, M11 (D) | none |
| (18) the writers not stated | S1, S2, S3, S4, S5, S6, T1, T2, T4, T5, R3, I1, D2, E1, E2, E11, E16 | X3 |

### By row and chain

| Id | Entries |
|---|---|
| S1 | (10), (18) |
| S2 | (10), (11), (18) |
| S3 | (10), (18) |
| S4 | (6), (7), (18) |
| S5 | (2), (3), (12), (18) |
| S6 | (18) |
| T1 | (6), (7), (18) |
| T2 | (8), (18) |
| T3 | (3) |
| T4 | (2), (4), (18) |
| T5 | (14), (18) |
| T6 | (6), (7) |
| R1 | (6), (7) |
| R2 | (6), (7) |
| R3 | (18) |
| I1 | (10), (18) |
| D1 | (6), (7), (8) |
| D2 | (6), (7), (18) |
| D3 | (3) |
| D4 | (7), (17) |
| D5 | (6), (7), (9), (10), (17) |
| D6 | (9) |
| D7 | (10), (11), (17) |
| E1 | (5), (18) |
| E2 | (6), (7), (10), (18) |
| E3 | (6), (7), (9), (10) |
| E4 | (9), (10), (12), (14) |
| E5 | (8) |
| E6 | (8) |
| E7 | (14), (15) |
| E8 | (6), (7) |
| E9 | (10) |
| E10 | (12) |
| E11 | (18) |
| E12 | (2), (8) |
| E13 | (2), (3) |
| E14 | (2) |
| E15 | (2), (3) |
| E16 | (14), (18) |
| E17 | (2), (8) |
| E18 | (2) |
| E19 | (7), (9) |
| E20 | (9) |
| E21 | (8) |
| E22 | (8), (14) |
| E23 | (10) |
| E24 | (3) |
| E25 | (7) |
| E26 | (9) |
| E27 | (2) |
| E28 | (8) |
| E29 | (8) |
| E30 | (7), (9) |
| E31 | (9) |
| E32 | (8) |
| E33 | (2), (4), (6), (7) |
| E34 | (7) |
| E36 | (6), (7) |
| E38 | (14) |
| E40 | (2), (12), (14) |
| E41 | (8) |
| E42 | (9) |
| E43 | (6), (7), (9) |
| E44 | (2), (6), (7), (9), (12), (14) |
| E45 | (3) |
| E46 | (3) |
| M1 (T) | (6), (7), (9) |
| M4 (E) | (6), (7), (9), (10) |
| M5 (D) | (6), (7) |
| M6 (D) | (6), (7) |
| M7 (E) | (3), (8) |
| M8 (E) | (8) |
| M9 (E) | (8) |
| M10 (E) | (2), (8) |
| M11 (D) | (10), (11), (17) |
| X1 | (6), (7), (9) |
| X2 | (6), (7), (9) |
| X3 | (6), (7), (10), (11), (18) |
| X5 | (6), (7), (9) |
| X7 | (3), (8), (10) |

---

## Availability and performance claims, listed and left unevaluated

Confirmed at their lines: the Congress "shall assemble at least once in every year"
(`constitution-paged.txt:1449-1451` (p.27)); the Journal, the statement of accounts and the
State of the Union "from time to time" (`constitution-paged.txt:361-363` (p.9);
`constitution-paged.txt:512-514` (p.12); `constitution-paged.txt:654-656` (p.14)); the "speedy
and public trial" (`constitution-paged.txt:949-950` (p.20)); compensation "at stated Times"
(`constitution-paged.txt:609-610` (p.13); `constitution-paged.txt:676-677` (p.14)); the seat and
the office serving in the interval of a temporary appointment or a recess commission
(`constitution-paged.txt:1302-1305` (p.25); `constitution-paged.txt:650-652` (p.14)); the
President's recommendations (`constitution-paged.txt:655-656` (p.14)). No stated exclusion,
named object or sibling-set member is disposed as an availability claim. The timing bounds inside
the mechanisms are parts of the mechanisms. Settling any of these means modeling the structural alternative, which this audit does not do.

---

## Still unsettled

Each item was reopened at its lines. "Confirmed as to the text" means the lines settle what the
text states and the rest is not settled by the document. Nothing can be run; each record named
is outside the document.

1. **U1** Not settled. Who presents a bill, and when (`constitution-paged.txt:400-402` (p.10)).
   Settles it: each House's rules (`constitution-paged.txt:357` (p.9)).
2. **U2** Not settled. Who recognises a removal, death or resignation, and to whom a resignation
   is addressed (`constitution-paged.txt:1718-1720` (p.30)). Settles it: a law or rule, not in
   the document.
3. **U3** Not settled. Whether a position other than the President can transmit a §3
   declaration, and whether the recipients check its origin (`constitution-paged.txt:1733-1738`
   (p.31)). Settles it: each House's rules and the officers' practice.
4. **U4** Not settled. Who establishes the Vice President's participation and the majority, and
   whether the signers hold the offices (`constitution-paged.txt:1740-1747` (p.31)). Settles it:
   the Houses' rules; the laws establishing the departments.
5. **U5** Not settled. The counting rule for four and twenty-one days, and who records
   "receipt" (`constitution-paged.txt:1755, 1760-1762` (p.31)), against "Sundays excepted"
   (`constitution-paged.txt:413-414` (p.10)). Settles it: the Journals and the Houses' rules.
6. **U6** Not settled. Who recognises that a President elect has died, was not chosen, failed to
   qualify or has qualified, and when "the Disability be removed" (`constitution-paged.txt:1453-1464`
   (p.27); `constitution-paged.txt:606-607` (p.13)); the recogniser of O7's start and end and of
   O12. "qualify" and "qualified" are not defined (`constitution-paged.txt:1457-1464` (p.27)); whether they mean the oath "Before he enter on the Execution of his Office" (`constitution-paged.txt:615-616` (p.13)) is not settled. Settles it, in part: a law under `constitution-paged.txt:1459-1464` (p.27), which reaches only the case "wherein neither a President elect nor a Vice President elect shall have qualified"; the rest is not settled by the document.
7. **U7** Confirmed as to the text: "the votes shall then be counted" names no counter, and "the
   whole number of Electors appointed" has no stated source (`constitution-paged.txt:1024-1028`
   (p.21)). Settles the rest: the rules for the count.
8. **U8** Not settled. Whether any position reads a person voted for against the bars
   (`constitution-paged.txt:593-598` (p.13); `constitution-paged.txt:1047-1049` (p.21);
   `constitution-paged.txt:1558-1562` (p.28)). Settles it: the rules for the count.
9. **U9** Not settled. The issuer of warrants and the reader at execution
   (`constitution-paged.txt:907-909` (p.19)). Settles it: the laws constituting the courts.
10. **U10** Not settled. Whether a term end, removal or inability reaches the appointees, and a
    repeal the officers in place (`constitution-paged.txt:632-648, 662-663` (p.13-14)). Settles
    it: the laws establishing the offices.
11. **U11** Confirmed as to the text: the draw bar and the two-year cap name no reader
    (`constitution-paged.txt:511-512` (p.12); `constitution-paged.txt:460-461` (p.11)). Settles
    the rest: the appropriation and Treasury laws.
12. **U12** Not settled. Who judges the eligibility of the President, Vice President and
    electors, and whether an office is "established by Law" (`constitution-paged.txt:593-598`
    (p.13); `constitution-paged.txt:553-555` (p.12); `constitution-paged.txt:645-646` (p.14)).
    Settles it: the rules for the count; the laws establishing offices.
13. **U13** Not settled. Who finds a denial of the vote and applies the reduction
    (`constitution-paged.txt:1131-1146` (p.22-23)). Settles it: the law directing the
    enumeration (`constitution-paged.txt:254` (p.8)).
14. **U14** Not settled. Who checks the empowerment, and who recognises the election that ends a
    temporary appointment (O11) and stops the appointee (`constitution-paged.txt:1302-1305`
    (p.25)). Settles it: the legislature's empowerment and direction.
15. **U15** Confirmed as to the text: the suspension clause is passive and names no body
    (`constitution-paged.txt:489-491` (p.11)). Settles the rest: nothing in the document.
16. **U16** Not settled. Who reads "inferior" (`constitution-paged.txt:646-648` (p.14)). Settles
    it: the vesting laws.
17. **U17** Not settled. Whether any person remains within Amendment XXII §1's second sentence
    (`constitution-paged.txt:1562-1568` (p.28)); the editorial notes name persons and are not
    cited. Settles it: a record outside the document of who held the office then.
18. **U18** Not settled. Who proves a State's acts, and whether a check precedes credit
    (`constitution-paged.txt:725-729` (p.15)). Settles it: Congress's general laws.
19. **U19** Confirmed as to the text: Art. V names no counter and no reader of the proviso
    (`constitution-paged.txt:767-787` (p.15-16)). Settles the rest: nothing in the document.
20. **U20** Not settled. Who checks that the oath preceded entry, and who holds the record
    Amendment XIV §3 reads (`constitution-paged.txt:615-619` (p.13);
    `constitution-paged.txt:802-807` (p.16); `constitution-paged.txt:1151-1154` (p.23)). Settles
    it: the laws on oaths.
21. **U21** Not settled. Whether a demand is checked for the charge, flight and jurisdiction,
    and who besides the demanding executive can write one (`constitution-paged.txt:734-738`
    (p.15)). Settles it: the laws of the States and of Congress on delivery.
22. **U22** Not settled. Who records a commission's class and checks the vacancy's timing, and
    whether the Senate's refusal ends the commission early (`constitution-paged.txt:650-652`
    (p.14)). Settles it: the Senate's rules and the practice of commissions.
23. **U23** Not settled. Who recognises "the End of their next Session"
    (`constitution-paged.txt:651-652` (p.14)). Settles it: the Journals.
24. **U24** Corrected (widened). Who recognises that "an election of Representatives shall have
    intervened", and whether an election to fill a single vacancy, ordered by one State
    executive's writ (`constitution-paged.txt:264-266` (p.8)), counts for
    `constitution-paged.txt:1858-1860` (p.32). Settles it: the pay law itself and whoever pays
    under it.
25. **U25** Not settled. What process applies to the cases excepted from the grand jury
    (`constitution-paged.txt:913-915` (p.19); `constitution-paged.txt:940` (p.20)). Settles it:
    Congress's rules for the land and naval forces (`constitution-paged.txt:463-464` (p.11)) and for governing the militia employed in the service of the United States (`constitution-paged.txt:467-469` (p.11)).
26. **U26** Not settled. Whether a return's delivery to the originating House is checked
    (`constitution-paged.txt:403-404` (p.10)). Settles it: the Houses' rules.
27. **U27** Not settled. Who besides each House can write its Journal
    (`constitution-paged.txt:361` (p.9)). Settles it: the rules naming the clerk and custody.
28. **U28** Corrected (widened), confirmed as to the structure: §4 names the Vice President as a
    maker with no substitute (`constitution-paged.txt:1740` (p.31)); §1, §3 and Art. II §1 cl. 6
    each land on "the Vice President" (`constitution-paged.txt:1718-1720` (p.30);
    `constitution-paged.txt:1738` (p.31); `constitution-paged.txt:602-603` (p.13)); the case of
    "both" goes to a law (`constitution-paged.txt:603-607` (p.13)). The observer mapping and the gap evaluation named §1
    and §4 only. Beside a vacant Vice Presidency, a House that has not chosen the officer who receives the declarations closes the same path where a declaration with no addressee does not take effect, not settled by the document (M5, U54). Settles the rest: that law.
29. **U29** Not settled. Who checks a State's elector count, the bar on office holders, and the
    District's cap (`constitution-paged.txt:550-555` (p.12); `constitution-paged.txt:1618-1621`
    (p.29)). Settles it: the rules for the count; the legislatures' directions.
30. **U30** Confirmed as to the text: the terms "shall end" and successors' "shall then begin" on
    no stated act (`constitution-paged.txt:1443-1447` (p.27)). Settles the rest: nothing in the
    document.
31. **U31** Not settled. Whether a commission is checked against the appointment, and who reads
    it (`constitution-paged.txt:662-663` (p.14)). Settles it: the laws establishing the offices.
32. **U32** Not settled. Who can alter a sealed list, and whether anyone reads the seal and
    signatures at the opening (`constitution-paged.txt:1021-1025` (p.21)). Settles it: the rules
    for transmission and the count.
33. **U33** Not settled. Who classes a pardoned offence (`constitution-paged.txt:627-628`
    (p.13)). Settles it: nothing in the document.
34. **U34** Not settled. Who judges whether a State is "actually invaded, or in such imminent
    Danger as will not admit of delay", and whether its imposts are "absolutely necessary for
    executing its inspection Laws"; the lines name no judge of either condition
    (`constitution-paged.txt:529-531, 537-541` (p.12)). Settles it: Congress's revision as
    exercised (`constitution-paged.txt:534-535` (p.12)), for the necessity of inspection duties only, since it reaches "all such Laws"; for invasion or imminent danger, nothing in the document.
35. **U35** Not settled. Whether consent precedes and is checked before the act
    (`constitution-paged.txt:516-520, 529-541` (p.12)). Settles it: the consents.
36. **U36** Corrected: confirmed as to the text. No line requires the names of those voting on
    the §4 determination or the §2 confirmation (`constitution-paged.txt:1730-1731, 1763`
    (p.31)); names are entered only "at the Desire of one fifth of those Present"
    (`constitution-paged.txt:363-365` (p.9)), the override alone requiring them
    (`constitution-paged.txt:410-412` (p.10)). Whether names were entered on a given vote is a
    record outside the document (the Journals).
37. **U37** Not settled. Whether acts of an Acting President stand after resumption
    (`constitution-paged.txt:1749-1767` (p.31)). Settles it: nothing in the document.
38. **U38** Not settled. Whether a changed direction reaches electors already appointed
    (`constitution-paged.txt:550-553` (p.12)). Settles it: the State's direction and the day
    Congress fixes (`constitution-paged.txt:589-591` (p.13)).
39. **U39** Not settled. Whether "cannot be convened" is checked before the United States acts
    (`constitution-paged.txt:761-763` (p.15)). Settles it: the law under which it responds.
40. **U40** Not settled. Who makes the enumeration and whether any check reads it against the
    rule (`constitution-paged.txt:251-254` (p.8); `constitution-paged.txt:1128-1131` (p.22)).
    Settles it: that law.
41. **U41** Not settled. Whether a writ is checked against an actual vacancy, and who besides
    the executive can write one (`constitution-paged.txt:264-266` (p.8);
    `constitution-paged.txt:1300-1302` (p.25)). Settles it: the State's election laws.
42. **U42** Not settled. Who holds the laws and treaties the judges read
    (`constitution-paged.txt:795-800` (p.16)). Settles it: the laws on custody and publication.
43. **U43** Not settled. Whether any check other than a court's reads "necessary and proper"
    (`constitution-paged.txt:480-483` (p.11)). Widened by the chain verification: what a law vesting power past the enumerated powers in "any Department or Officer" reaches, and whether the President is a "Department or Officer thereof" (`constitution-paged.txt:480-483` (p.11)). Settles it: nothing in the document.
44. **U44** Not settled. Whether any check other than the judges' reads "under the Authority of
    the United States" (`constitution-paged.txt:796-797` (p.16)). Settles it: nothing in the
    document.
45. **U45** Not settled. Whether any check reads "such disability"
    (`constitution-paged.txt:1156-1157` (p.23)). Settles it: nothing in the document.
46. **U46** Not settled. Whether any check reads "shall not extend further than"
    (`constitution-paged.txt:334-336` (p.9)). Widened by the chain verification: what a judgment beyond "removal from Office, and disqualification" (`constitution-paged.txt:334-336` (p.9)) reaches for the President tried (`constitution-paged.txt:330-331` (p.9)). Settles it: nothing in the document.
47. **U47** Not settled. Whether any check other than the convicting court reads "duly
    convicted" (`constitution-paged.txt:1080-1082` (p.22)). Settles it: the laws on punishment.
48. **U48** (new) Not settled. Who recognises the President's "Inability to discharge the Powers
    and Duties of the said Office" for cl. 6's devolution (O10), and what "devolve" carries
    (`constitution-paged.txt:600-603` (p.13)). Precondition: an inability for which no §3 or §4
    declaration is transmitted. Settles it: nothing in the document; a law under `constitution-paged.txt:603-607` (p.13) reaches only inability "both of the President and Vice President", and is
    not in the document.
49. **U49** (new) Not settled. Whether "according to the Rules and Limitations prescribed in the
    Case of a Bill" carries the ten-day default to orders, resolutions and votes
    (`constitution-paged.txt:419-425` (p.10)). Precondition: an order presented and neither
    approved nor returned. Settles it: the Houses' rules and practice, not in the document.
50. **U50** (new) Not settled. Whether the judges are "civil Officers of the United States"
    removable under Art. II §4 (`constitution-paged.txt:665-668, 674-676` (p.14)). Precondition:
    a judge's conduct outside "good Behaviour". Settles it: nothing in the document.
51. **U51** Not settled. The vote a House's judgment of a member's "Elections, Returns and Qualifications" takes (`constitution-paged.txt:350-351` (p.9)); whether a member so judged leaves the membership the quorum (`constitution-paged.txt:351-352` (p.9)) and the supermajorities are counted of; whether "two thirds of that House" (`constitution-paged.txt:406` (p.10)), "two-thirds vote of both Houses" (`constitution-paged.txt:1763` (p.31)) and "two-thirds of each House" (`constitution-paged.txt:1156-1157` (p.23)) are counted of the members or of those present, as `constitution-paged.txt:331-332` (p.9) and `constitution-paged.txt:631-632` (p.13) say. Settles it: each House's rules (`constitution-paged.txt:357` (p.9)), not in the document. U51 now bears on X1, X3, E8 and R2 (chain verification). Raised by the chain hunt and held by the chain verification.
52. **U52** (widened) Not settled. Whether an adjournment the President makes on the Houses' disagreement
    (`constitution-paged.txt:657-660` (p.14)) is "the Congress by their Adjournment", and whether it
    prevents the return, for `constitution-paged.txt:415-417` (p.10); the second part is open for
    adjournments in general, H3 recording it open for one of three days or less. Settles it: nothing in the document. Raised by the chain hunt; widened by the chain verification.
53. **U53** Not settled. Whether a vacancy arising when a commission expires "at the End of their next Session" (`constitution-paged.txt:651-652` (p.14)) is one "that may happen during the Recess" (`constitution-paged.txt:650-651` (p.14)), and whether a session the President convenes (`constitution-paged.txt:657-658` (p.14)) is a "Session" for the expiry. Settles it: the Senate's rules and the practice of commissions, not in the document. Raised by the chain hunt and held by the chain verification.
54. **U54** Not settled. Whether a Speaker (`constitution-paged.txt:268` (p.8)) and a President pro tempore, chosen "in the Absence of the Vice President, or when he shall exercise the Office of President" (`constitution-paged.txt:324-326` (p.9)), exist at every time a declaration may be transmitted to them (`constitution-paged.txt:1733-1735` (p.31)); and whether the President pro tempore is "the President of the Senate" who opens the certificates (`constitution-paged.txt:1023-1025` (p.21)) and holds the vote at `constitution-paged.txt:321-322` (p.9). Settles it: each House's rules. Raised by the chain hunt and held by the chain verification.
55. **U55** Not settled. What the presiding officer decides when the Senate sits on an impeachment (`constitution-paged.txt:328-332` (p.9)), and whether the Vice President presides at his own trial. Settles it: the Senate's rules. Raised by the chain hunt and held by the chain verification.
56. **U56** Not settled. Whether the Vice President's vote "unless they be equally divided" (`constitution-paged.txt:321-322` (p.9)) counts toward "a majority of the whole number" of Senators in the choice of a Vice President (`constitution-paged.txt:1044-1047` (p.21)). Settles it: the Senate's rules. Raised by the chain hunt and held by the chain verification.
57. **U57** Not settled. Whether a person twice elected President is "constitutionally ineligible to the office of President" for `constitution-paged.txt:1047-1049` (p.21), the bar at `constitution-paged.txt:1558-1562` (p.28) reading "elected". Settles it: nothing in the document. Raised by the chain hunt and held by the chain verification.
58. **U58** Not settled. Whether any check other than a court's reads "appropriate" against enforcement legislation (`constitution-paged.txt:1085-1086` (p.22) and the six like lines). Settles it: nothing in the document. Raised by the chain hunt and held by the chain verification.
59. **U59** Not settled. Whether the protection "against Invasion" (`constitution-paged.txt:759-761` (p.15)) needs a declaration of war (`constitution-paged.txt:458` (p.11)) or a finding by any named position, and who finds the invasion. Settles it: the law under which the United States responds, not in the document. Stays open after X4 is dropped (chain verification). Raised by the chain hunt and held by the chain verification.
60. **U60** Not settled. How a State's one vote in the House's choice of a President is determined where its members divide (`constitution-paged.txt:1031-1033` (p.21)), and whether "immediately" (`constitution-paged.txt:1031` (p.21)) bounds the choice in time. Settles it: the House's rules. Raised by the chain hunt and held by the chain verification.
61. **U61** Not settled. Whether any position reads the admission of a new State (`constitution-paged.txt:746-751` (p.15)) against "within the Jurisdiction of any other State" and the consent of the legislatures concerned. Settles it: nothing in the document. Raised by the chain hunt and held by the chain verification.
62. **U62** Not settled. Whether, after a two-thirds determination (`constitution-paged.txt:1762-1765` (p.31)), the President may again transmit a declaration "that no inability exists" (`constitution-paged.txt:1749-1751` (p.31)) and restart the four-day and twenty-one-day windows. Settles it: nothing in the document. Raised by the chain hunt and held by the chain verification.
63. **U63** (new) Not settled. Whether a bill returned "to that House in which it shall have originated"
    (`constitution-paged.txt:403-404` (p.10)) but delivered to the other House is "returned by the
    President" for the ten-day default (`constitution-paged.txt:412-415` (p.10)). Precondition: a
    return delivered to the other House within the ten days. Settles it: the Houses' rules and
    practice, not in the document. Raised by the chain verification.
64. **U64** (new) Not settled. Whether any position other than the House reads a House's recorded count on a
    two-thirds vote, the §4 determination included (`constitution-paged.txt:361-365` (p.9);
    `constitution-paged.txt:1762-1764` (p.31)). Precondition: a determination recorded without
    names. Settles it: each House's rules (`constitution-paged.txt:357` (p.9)), not in the
    document. Raised by the chain verification.
65. **U65** (new) Not settled. Whether a President in custody, by delivery on a demand
    (`constitution-paged.txt:734-738` (p.15)) or by punishment under a legislative act
    (`constitution-paged.txt:492` (p.11)), is under "Inability to discharge the Powers and Duties of
    the said Office" (`constitution-paged.txt:600-602` (p.13)), and what custody otherwise reaches
    of the office. Settles it: nothing in the document. Raised by the chain verification.
66. **U66** (new) Not settled. Whether "the President" in Amendment XXV §3 and §4
    (`constitution-paged.txt:1733-1747` (p.31)) includes an Acting President. Settles it: nothing in
    the document. Raised by the chain verification.
67. **U67** Not settled. What "The Privilege of the Writ of Habeas Corpus" is, whose it is, and
    whether its suspension removes any check, on detention or otherwise
    (`constitution-paged.txt:489-491` (p.11)): the lines state only when the privilege may be
    suspended, and name no issuer of the writ and no effect of it. Settles it: nothing in the
    document.

Other items kept open: whether an adjournment of three days or less "prevent[s]" a bill's return
(H3, `constitution-paged.txt:367-369, 415-417` (p.9-10)); whether the compulsion of absent
members can itself be the fault (PR5, `constitution-paged.txt:352-355` (p.9)).

Noticed outside the first verification's lane, for the step that owns each: OC12's hazard of a treason
conviction without "two Witnesses to the same overt Act, or on Confession in open Court"
(`constitution-paged.txt:715-717` (p.15)) carries no row, the line itself refusing the conviction
(SE20) while its application rests on BC9 (for the sweep); the ends the text fixes (O2, O7, O11,
O12) and what stops a holder continuing past each (U30, U6, U14) form one shape across E3, E22,
E23 and E25 (for the chain hunt).

### Open questions raised by the chain verification, not ruled

68. **The principal offices into the §4 path.** E21, E26 and E20 now name a principal
    officer as their widest office, with a place in the §4 majority
    (`constitution-paged.txt:1740-1747` (p.31)). Whether a vesting law
    (`constitution-paged.txt:646-648` (p.14)) or a commission lets the President, or an
    Acting President, choose the §4 co-makers without the Senate, as a chain distinct from
    X3's optional branch, was not hunted here. Settles it: the step that owns chains testing
    the join, and U4 and U16 for the lines. Raised by the chain verification, not ruled.
69. **A writ for a seat not vacant into O9.** T3's writ produces an election, and O9's
    condition takes "an election of Representatives" by name
    (`constitution-paged.txt:264-266` (p.8); `constitution-paged.txt:1858-1860` (p.32)).
    Whether that join releases the pay-law halt is a chain candidate outside the re-tests
    owed here, conditional on U24 and U41. Settles it: the step that owns chains. Raised by
    the chain verification, not ruled.
70. **X6's denial branch.** A detention that takes a House below "a Majority of each"
    (`constitution-paged.txt:351-352` (p.9)) stops its business, a parallel effect of the
    detention X6 rested on; X6 is rejected (the rejected list), no line stating that a
    suspension of the writ reaches a detention (U67). Whether it is a D row of its own
    beside D1 is for the sweep. Raised by the chain verification, not ruled.
71. **The Chief Justice's substitution skipped for the Vice President's trial.** Recorded
    with BC5 from M2 (`constitution-paged.txt:321-322, 328-331` (p.9)); whether it composes
    with another gap is for later chain steps. Settles what the chair decides: the Senate's
    rules (U55). Raised by the chain verification, not ruled.
72. **The supermajority bases.** U51 now bears on X1, X3, E8 and R2. Settles it: each
    House's rules (`constitution-paged.txt:357` (p.9)), not in the document; for the sweep
    to carry consistently. Raised by the chain verification, not ruled.
73. **Whether a by-election counts for O9.** U24 decides whether M7 is a row and whether
    O9's release rests on one writ. Settles it: the pay law and whoever pays under it.
    Raised by the chain verification, not ruled.
74. **Adjournments of three days or less.** Whether they "prevent" a return
    (`constitution-paged.txt:367-369` (p.9); `constitution-paged.txt:415-417` (p.10)) stays
    open for the Houses (H3) and is carried for the President in U52. Settles it: nothing in
    the document. Raised by the chain verification, not ruled.
75. **The reduction formula's scope.** DG5 is not entered; E18 takes the formula's class as
    an addition. Whether the sweep records that class as a stated scope of OC15 is for the
    sweep. Raised by the chain verification, not ruled.
76. **The President pro tempore.** Whether he is "the President of the Senate" for the
    opening and the casting vote (U54). The observer mapping's BC19 carries no correction
    from the chain verification, since it quotes the line. Settles it: the Senate's rules.
    Raised by the chain verification, not ruled.

---

## Counts

| | |
|---|---|
| Rows | 75, counted by the section each sits in: 66 in the STRIDE sections (6 S, 6 T, 3 R, 1 I, 7 D, 43 E) and 9 found by the chain hunt (M1, M4 to M11: 1 T, 5 E, 3 D); by filed letter, 6 S, 7 T, 3 R, 1 I, 10 D, 48 E. 19 stand on the lines alone for at least one entry; 56 are conditional on at least one unconfirmed item |
| Chains that compose | 5 of 29 candidates (X1, X2, X3, X5, X7), all conditional on an unconfirmed item; 0 source-supported; 0 design assumptions |
| Chain candidates rejected | 24 (22 from the chain hunt; X4, dropped in verification; and X6, opened by the chain verification and rejected on its failed premise) |
| Halt paths | 7 (H1 to H7): H4 reaches every elected term that ends on its day; H1, H2, H3, H5, H6 and H7 each reach one commission, law, bill, acting or seat; none reaches two other mechanisms |
| Continue-on-fault paths | 9 (C1 to C9) |
| Observers inventoried | 12 observers (O1 to O12) among 78 inventory entries (17 observed components, 35 B2 controls, 14 signal-path devices); 2 more observed components (OC18, OC19) in the hazards table, 19 hazards rows in all |
| Read-backs | 14, 14 with no provenance check stated, 14 with no shape check stated; 5 holding an unbound pair |
| Deputies and mints | 22 components in 25 rows; 12 rows with no check stated, 8 with a person's check only, 5 with a restriction an observer reads, 0 with a check that binds the whole act; 22 rows with a restriction not stated to reach a check that decides the act |
| Key records | 16, 3 with a row (O4 in S2, O5 in S4, O8 in E20), 3 with the correspondence not stated (O8, BC1, BC10), none with an unconfirmed item of its own |
| Named objects | 15 inputs naming 33 objects, one per entry the table separates: 6 bound, 0 needing none, 0 with a standing row, 27 with a row conditional on a U id, 0 availability claims, 0 with no row |
| Sibling sets | 4 sets of 10 members beyond the founding checks: 3 with the same kind of check (SS4), 0 covered by another machine check, 1 with a standing row (SS1's adjournment, E36), 4 with a row conditional on a U id (SS2's two, E22; SS3's two, D7), 1 with no default beyond O5's clock (SS3's forty-eight hours, D7), 0 availability claims, 1 with no row of its own (SS1's orders, resolutions and votes: E42 holds U49's default reading, and the other gives none) |
| Stated exclusions | 26: 14 with a row, 0 covered, 0 covering not stated, 2 refusals (SE4, SE20), 0 delegated, 0 availability claims, 10 not reached or with no position gaining (SE2, SE5, SE8, SE12, SE17, SE18, SE23, SE24, SE25, SE26) |
| Rings at any layer | 0 |
| Coordinators | 0 of 8 candidates |
| Scorecard | 46 gaps, 2 satisfied, 0 not required, over 48 cells in 6 groups |
| Availability claims, unevaluated | 9 |
| Unsettled questions | 80: 67 unconfirmed items (U1 to U67), 4 other items kept open, 9 open questions raised by the chain verification |

**The shape of it.** Twelve mechanisms take effect by the text's own terms: an unreturned bill
becomes law, fixed dates end every elected term, a death or an inability moves the executive
power, windows return it, an expiry ends a recess commission or a temporary appointment, an
election releases a pay law. Each is an isolated spoke on one position, office, event or the
clock; none reads another or reports to another, no coordinator or super-ring forms, and the
recogniser of every one is not stated. Everything else that checks power is a person's act, a
vote, a declaration, a count, a trial or a judgment, which composes into chains but discharges no
property, so the scorecard is 46 gaps in 48 cells. At the top of the risk list the office of
President passes on events no stated position recognises, the executive power moves on
declarations and recorded counts no stated position checks, and the electoral count runs with no
named counter; every chain that survives verification is conditional on an item the document
does not settle.

**How the system came to exist.** The text came into force by "The Ratification of the
Conventions of nine States", "sufficient for the Establishment of this Constitution between the
States so ratifying the Same" (`constitution-paged.txt:811-813` (p.16, Art. VII)): a decision of
State conventions, people deciding, with no counter named and no mechanism of the kind the model
asks for in the step. Every later change passes the same kind of gate: proposal "whenever two
thirds of both Houses shall deem it necessary" or by a convention called "on the Application of
the Legislatures of two thirds of the several States", and validity "when ratified by the
Legislatures of three fourths of the several States, or by Conventions in three fourths thereof"
(`constitution-paged.txt:767-787` (p.15-16, Art. V)), with no counter named (U19). The process
that produced the system and the process that changes it are votes of B2 bodies, and the same
amendment rule is the removal path for every mechanism the text contains (RP5). The paragraph
records an observation of the producing process, not a second audit of it.
