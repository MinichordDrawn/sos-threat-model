# Survey: `constitution`

The orchestrator's map of the evidence. Every boundary, range and status below is a claim
for pass 1 to check at the lines.

## The source

- **Title.** House Document 110-50, "The Constitution of the United States of America As
  Amended", with "Unratified Amendments" and an "Analytical Index" (title page,
  `constitution-paged.txt:2-19` (p.1)).
- **Publisher and date.** U.S. Government Printing Office, Washington, 2007, ordered printed
  by the House of Representatives, 110th Congress, 1st Session
  (`constitution-paged.txt:2-3, 29-34` (p.1); `constitution-paged.txt:46-52` (p.2)).
- **Address.** `https://www.govinfo.gov/content/pkg/CDOC-110hdoc50/pdf/CDOC-110hdoc50.pdf`
  (from the brief; the document itself prints no such address).
- **PDF.** `sources/constitution.pdf`, SHA-256
  7f29c4a79e310cc7bcee5f3fd07fb1367e463bd4530fa5d854ebdd4fd4402e57 (checked against the
  brief before extraction).
- **Extraction.** pdftotext 4.00 (xpdf, Glyph & Cog), `-layout`, encoding Latin1, through
  the kit's `page_text.py`; `sources/constitution-paged.txt`, 6,281 lines, 86 parts (85
  pages and the empty part after the last form feed), SHA-256
  82a4e5f1d5b7a183f332c1f41be06515badfb724a8b9deb13f4f68b8adb31f0e.
- **Encoding choice.** `page_text.py --compare`: UTF-8 gave 0 replacement characters, 62 em
  dashes, 259,402 non-space characters, other non-ASCII U+00C6 U+2013 U+2018 U+2019 U+2022;
  Latin1 gave 0 replacement characters, 259,464 non-space characters, other non-ASCII U+00AD
  U+00B7 U+00C6. Both have 6,110 raw lines. A line-by-line diff showed only rendering
  differences: an em dash becomes `--` in Latin1 (the 62 extra non-space characters), an en
  dash becomes U+00AD (a soft hyphen, 13 places, all in front matter, editorial notes and
  the unratified-amendments note), curly quotation marks become two backticks (opening) and
  two apostrophes (closing), and one bullet becomes U+00B7. Latin1 is kept: it loses no
  character a claim needs and writes no em dash, which the writing rules ban. Two cautions
  for every pass: an opening double quotation mark in the extraction is two backticks, so
  never copy one into Markdown (it opens a code span and breaks the citation resolver), and
  the soft hyphen is invisible in most viewers.
- **Licence.** Every body is a work of the United States federal government, in the public
  domain under 17 U.S.C. §105, as the brief states. The document prints no licence line of
  its own.

## Printing artifacts

Every page carries a typesetting slug ("VerDate ... E:\HR\OC\...", 85 lines) and many carry
an operator tag at the start of a line ("cprice-sewell on PROD1PC72 with HEARING"), which in
some places sits on the same line as body text (for example
`constitution-paged.txt:382` (p.10)). Neither is part of any body. Printed page numbers (the
running heads "CONSTITUTION OF THE UNITED STATES" with a number) differ from PDF pages; cite
the PDF page from the nearest marker.

## Bodies and their line ranges

| Body | Lines | PDF pages | Author or role | How the run reads it |
|---|---|---|---|---|
| Title page, printing order, contents, blank insert | 1-73 | 1-4 | the printer and the ordering House | context |
| Historical Note | 74-161 | 5-6 | unsigned editor's essay | context, outside the system |
| Preamble | 166-171 | 7 | the constitutional text | the system (statement of purpose) |
| Articles I to VII, the text as engrossed | 173-813 | 7-16 | the constitutional text | the system, with the in-force rules below |
| Editorial footnotes inside Articles I to VII (notes 1 to 11) | 179-224, 282-298, 300-304, 374-375, 441, 501, 635-636, 703, 772 | 7-15 | editor | context; notes 2 to 11 are the editor's statements on what is affected or superseded |
| Attestation and signatures | 815-868 | 16-17 | the Convention's signers | context, outside the system |
| Heading of the amendments, with notes 12 and 13 | 876-881, 917-931 | 19 | editor | context |
| Amendments I to X | 883-980 | 19-20 | the constitutional text | the system |
| Amendment XI | 982-987 | 20 | the constitutional text | the system |
| Amendment XII | 1012-1049 | 21 | the constitutional text | the system, with the in-force rules below |
| Amendments XIII to XXVII | 1078-1860, interleaved with editorial notes | 22-33 | the constitutional text | the system, with the in-force rules below |
| "Proposal and Ratification" notes after amendments XI to XXVII | 989-1010, 1051-1076, 1088-1115, 1171-1201, 1219-1250, 1259-1290, 1311-1335, 1362-1390, 1401-1439, 1481-1512, 1530-1554, 1580-1604, 1631-1661, 1681-1708, 1769-1806, 1823-1848, 1862-1891 | 20-33 | editor | context (ratification history) |
| "Certification of Validity" notes after amendments XXII to XXVII | 1606-1610, 1663-1667, 1710-1714, 1808-1812, 1850-1854, 1893-1897 | 29-33 | editor, quoting certifying officials' publications | context |
| Editorial notes 14 to 17 inside the amendments | 1063, 1203, 1352, 1792 | 21, 23, 25, 31 | editor | context; notes 14 and 16 fix what is in force (below) |
| Editorial Note on ratification dates | 1899-1909 | 33 | editor | context |
| Proposed Amendments Not Ratified | 1917-2096 | 35-37 | editor, quoting six joint resolutions | context, outside the system (proposals never adopted) |
| Index to the Constitution and Amendments | 2103-6281 | 39-85 | editor | context, outside the system; its article, section and clause columns extract scrambled, so nothing may rest on it |

Pages 18, 34 and 38 hold only the slug (`constitution-paged.txt:873, 1914, 2100`).

The editorial bodies name persons, a printing committee's chairman, court decisions and
events after ratification. The brief forbids naming any of them; no pass cites an editorial
body for anything but what it says is in force, and none repeats a name from it.

## What is in force

The system is the text with every amendment applied. Superseded, repealed and spent parts
are context. Status per part, with its basis; "affected" in an editor's note does not say
which part of a clause stands, so where the amending text's own words do not settle it, the
extent is not settled by the document.

| Part | Lines | Status | Basis |
|---|---|---|---|
| Amendment XVIII | 1337-1360 | repealed, context | the amending text: Amendment XXI §1 (`constitution-paged.txt:1516-1517` (p.28)); editor's note 16 agrees (`constitution-paged.txt:1352` (p.25)) |
| Art. II §1 cl. 3 (original electoral vote procedure) | 557-587 | superseded, context | editor's note 8 (`constitution-paged.txt:635` (p.13)); the editor's ratification note for Amendment XII says it was proposed "in lieu of" that paragraph (`constitution-paged.txt:1053-1056` (p.21)); Amendment XII's own text does not say so |
| Amendment XII, the sentence on the Vice President acting when the House has not chosen by the fourth day of March | 1035-1040 | superseded, context | editor's note 14 (`constitution-paged.txt:1063` (p.21)); Amendment XX §3 (`constitution-paged.txt:1453-1464` (p.27)) does not name it |
| Art. I §2 cl. 3, the counting rule for apportionment | 246-251 | displaced by the amending text for apportioning Representatives: Amendment XIV §2 (`constitution-paged.txt:1128-1131` (p.22)); the direct-tax part affected by Amendment XVI (`constitution-paged.txt:1254-1257` (p.24)) | editor's note 2 says "affected" (`constitution-paged.txt:300-303` (p.8)) |
| Art. I §2 cl. 3, the first allocation "until such enumeration" | 255-262 | spent by its own terms | its own words |
| Art. I §3 cl. 1, Senators chosen by the Legislature | 271-273 | displaced by Amendment XVII (`constitution-paged.txt:1294-1298` (p.25)) | editor's note 3 says "affected" (`constitution-paged.txt:304` (p.8)) |
| Art. I §3 cl. 2, vacancy appointments by the State executive during the Legislature's recess | 311-314 | displaced by Amendment XVII's second paragraph (`constitution-paged.txt:1300-1305` (p.25)); the first division into classes spent | editor's note 4 cites "clause 2 of amendment XVIII" (`constitution-paged.txt:374` (p.9)); see "Noticed while surveying" |
| Art. I §4 cl. 2, the first Monday in December | 346-348 | displaced by Amendment XX §2 (`constitution-paged.txt:1449-1451` (p.27)) | editor's note 5 says "affected" (`constitution-paged.txt:375` (p.9)) |
| Art. I §6 cl. 1, compensation ascertained by law | 371-372 | in force, with Amendment XXVII added (`constitution-paged.txt:1858-1860` (p.32)) | editor's note 6 says "affected" (`constitution-paged.txt:441` (p.10)) |
| Art. I §9 cl. 1 (migration or importation before 1808) | 484-488 | spent by its own terms | its own words |
| Art. I §9 cl. 4 (direct taxes in proportion to the census) | 493-495 | in force except as Amendment XVI's words reach taxes on incomes | editor's note 7 says "affected" (`constitution-paged.txt:501` (p.11)) |
| Art. II §1 cl. 6 (removal, death, resignation, inability) | 600-607 | in force except as Amendment XXV's words displace it; the extent is not settled by the document | editor's note 9 says "affected" (`constitution-paged.txt:636` (p.13)) |
| Art. III §2 cl. 1, controversies between a State and citizens of another State | 686-687 | narrowed by Amendment XI (`constitution-paged.txt:984-987` (p.20)) | editor's note 10 says "affected" (`constitution-paged.txt:703` (p.14)) |
| Art. IV §2 cl. 3 (persons held to service delivered up) | 740-744 | displaced by Amendment XIII §1 (`constitution-paged.txt:1080-1083` (p.22)); the extent is the amending text's | editor's note 11 says "affected" (`constitution-paged.txt:772` (p.15)) |
| Art. V proviso on amendments before 1808 | 783-786 | spent by its own terms; the equal-suffrage proviso stands | its own words |
| Art. VII (ratification by nine States) | 811-813 | spent; context | its own words |
| Amendment XIV §2, "male inhabitants ... twenty-one years of age" | 1134-1146 | in force as printed; editor's note 15 points to Amendment XIX and Amendment XXVI §1 (`constitution-paged.txt:1203` (p.23)) without saying what changes | the extent is not settled by the document |
| Amendment XVII third paragraph (Senators chosen before it took effect) | 1307-1309 | transitional, context | its own words |
| Amendment XX §5 and §6; Amendment XXI §3; Amendment XXII §2 (effective dates and seven-year ratification limits) | 1473-1479, 1524-1528, 1570-1573 | spent conditions of adoption, context | their own words |
| Amendment XXII §1, second sentence (persons holding the office when proposed or during the term it became operative) | 1562-1568 | transitional; whether any such person remains is not settled by the document | its own words |

Everything else in Articles I to VI and Amendments I to XXVII (XVIII excepted) is in force as
printed.

## Positions the source names

The people of the several States and the electors who vote for Representatives and
Senators (`constitution-paged.txt:235-239` (p.8); `constitution-paged.txt:1294-1298`
(p.25)); citizens and their voting rights (Amendments XV, XIX, XXIV, XXVI); the States, their
legislatures, executives and conventions; the House of Representatives, its Speaker and
officers; the Senate, its President (the Vice President) and President pro tempore; the
Congress; the President; the Vice President; presidential electors; the Chief Justice; the
supreme Court and inferior courts and their judges; the principal officers of the executive
departments and the heads of departments; inferior officers; ambassadors, ministers and
consuls; the land and naval forces and the militia; a convention for proposing amendments;
grand juries and juries; persons accused; "such other body as Congress may by law provide"
(Amendment XXV §4, `constitution-paged.txt:1740-1742` (p.31)); the District constituting the
seat of government (Amendment XXIII, `constitution-paged.txt:1614-1626` (p.29)); foreign
states and their subjects. No position in the text is a machine.

## Records the text describes

- Each House's Journal, published "from time to time" except parts that "in their Judgment
  require Secrecy"; yeas and nays entered at the desire of one fifth
  (`constitution-paged.txt:361-365` (p.9)).
- The President's objections to a bill, entered "at large" on the originating House's
  Journal; the yeas and nays on reconsideration entered on each Journal
  (`constitution-paged.txt:403-412` (p.10)).
- Electors' signed and certified lists, transmitted sealed to the President of the Senate,
  opened before both Houses, counted (`constitution-paged.txt:1014-1025` (p.21));
  the superseded Art. II §1 cl. 3 held the same steps (`constitution-paged.txt:557-565`
  (p.12)).
- Written declarations of inability and of no inability, transmitted to the President pro
  tempore and the Speaker (`constitution-paged.txt:1733-1757` (p.31)).
- A regular statement and account of receipts and expenditures, published from time to
  time (`constitution-paged.txt:511-514` (p.12)).
- The enumeration, every ten years (`constitution-paged.txt:251-254` (p.8)).
- Oaths or affirmations: the President's (`constitution-paged.txt:615-619` (p.13)); all
  legislators and officers (`constitution-paged.txt:802-807` (p.16)); the Senate sitting to
  try impeachments (`constitution-paged.txt:328-330` (p.9)); warrants supported by oath
  (`constitution-paged.txt:905-909` (p.19)).
- Commissions of officers (`constitution-paged.txt:650-652` (p.14);
  `constitution-paged.txt:661-663` (p.14)); writs of election (`constitution-paged.txt:264-266`
  (p.8); `constitution-paged.txt:1300-1302` (p.25)).
- Public acts, records and judicial proceedings of every State
  (`constitution-paged.txt:725-729` (p.15)).
- Appropriations made by law (`constitution-paged.txt:511-512` (p.12)); armies'
  appropriations limited to two years (`constitution-paged.txt:460-461` (p.11)).

## Lines that bear on the floor

There is no customer data in the software sense. The public-safety floor is the candidate:
the Preamble's "insure domestic Tranquility, provide for the common defence"
(`constitution-paged.txt:166-171` (p.7)); the guarantee of a republican form of government
and protection against invasion and domestic violence (`constitution-paged.txt:759-763`
(p.15)); habeas corpus suspended only when "the public Safety may require it"
(`constitution-paged.txt:489-491` (p.11)); the war, army, navy and militia powers
(`constitution-paged.txt:458-471` (p.11)); the Commander in Chief
(`constitution-paged.txt:621-623` (p.13)). The nearest thing to the public's data is the
security of "persons, houses, papers, and effects" (`constitution-paged.txt:905-909`
(p.19)), and the rights in Amendments I to X and XIV §1. Pass 1 decides the tier.

## Mechanisms that take effect by themselves (candidate observers for pass 1)

The bar admits as candidates only mechanisms the text makes take effect with no person
deciding, carrying out or recognising any step. Candidates the survey found; pass 1's role
test decides each, and zero observers is an acceptable result.

- Fixed term ends at noon on fixed dates, and successors' terms begin
  (`constitution-paged.txt:1443-1447` (p.27)).
- Congress assembles at noon on 3 January unless a law appoints another day
  (`constitution-paged.txt:1449-1451` (p.27)).
- A bill not returned within ten days (Sundays excepted) becomes law, unless adjournment
  prevents its return (`constitution-paged.txt:413-417` (p.10)).
- Recess commissions expire at the end of the Senate's next session
  (`constitution-paged.txt:650-652` (p.14)).
- No army appropriation for longer than two years (`constitution-paged.txt:460-461` (p.11)).
- A law varying congressional compensation takes no effect until an election of
  Representatives has intervened (`constitution-paged.txt:1858-1860` (p.32)).
- The President's compensation neither increased nor diminished during the term; judges'
  not diminished (`constitution-paged.txt:609-613` (p.13); `constitution-paged.txt:675-678`
  (p.14)).
- Succession: the Vice President becomes President on removal, death or resignation
  (`constitution-paged.txt:1718-1720` (p.30)); the Vice President elect becomes President
  if the President elect has died, or acts if none has qualified
  (`constitution-paged.txt:1453-1464` (p.27)).
- Inability: on a written declaration the Vice President "shall immediately assume" the
  powers; the President resumes unless a counter-declaration arrives within four days;
  Congress decides within twenty-one days, otherwise the President resumes
  (`constitution-paged.txt:1740-1767` (p.31)).
- The Vice President votes in the Senate only when it is equally divided
  (`constitution-paged.txt:321-322` (p.9)).
- Incompatibility: no person holding federal office is a member of either House
  (`constitution-paged.txt:393-394` (p.10)); ineligibility rules (ages, citizenship,
  residence, two-term limit, insurrection disqualification) at
  `constitution-paged.txt:241-244` (p.8), `constitution-paged.txt:316-319` (p.9),
  `constitution-paged.txt:593-598` (p.13), `constitution-paged.txt:1148-1157` (p.23),
  `constitution-paged.txt:1558-1562` (p.28).
- Supremacy and the oath: the Constitution, laws and treaties are supreme and bind State
  judges (`constitution-paged.txt:795-800` (p.16)).
- Quorum and the yeas-and-nays record (`constitution-paged.txt:350-355, 361-365` (p.9)).

## Checks people perform (B2 controls, for pass 1 to record)

Veto and override (`constitution-paged.txt:400-425` (p.10)); advice and consent to treaties
and appointments (`constitution-paged.txt:630-648` (p.13-14)); impeachment by the House,
trial by the Senate, removal (`constitution-paged.txt:268-269` (p.8);
`constitution-paged.txt:328-338` (p.9); `constitution-paged.txt:665-668` (p.14)); each House
judging its members' elections and expelling by two thirds (`constitution-paged.txt:350-359`
(p.9)); the judicial power over cases (`constitution-paged.txt:672-697` (p.14)); juries and
grand juries (`constitution-paged.txt:699-701` (p.14); `constitution-paged.txt:913-915`
(p.19); `constitution-paged.txt:949-964` (p.20)); counting the electoral votes before both
Houses (`constitution-paged.txt:1023-1025` (p.21)); the House and Senate contingent
elections (`constitution-paged.txt:1028-1035, 1043-1047` (p.21)); inability declarations and
Congress's decision (`constitution-paged.txt:1733-1767` (p.31)); confirmation of a
nominated Vice President (`constitution-paged.txt:1722-1731` (p.30-31)); proposal and
ratification of amendments (`constitution-paged.txt:767-787` (p.15-16)); pardons
(`constitution-paged.txt:627-628` (p.13)); Congress removing the insurrection disability
(`constitution-paged.txt:1156-1157` (p.23)); consent of Congress for State compacts, duties
and troops (`constitution-paged.txt:529-541` (p.12)).

## Stated-exclusion candidates

Lines where the text says a check, a control, a restriction or the scope of an authority
leaves something out. Pass 1 lists each that qualifies, with its disposition.

- Journal publication excepts parts that "in their Judgment require Secrecy"
  (`constitution-paged.txt:361-363` (p.9)).
- Members privileged from arrest "except Treason, Felony and Breach of the Peace", and not
  questioned elsewhere for speech or debate (`constitution-paged.txt:382-387` (p.10)).
- Presentment of orders, resolutions and votes "except on a question of Adjournment"
  (`constitution-paged.txt:419-421` (p.10)); a bill unreturned becomes law "unless the
  Congress by their Adjournment prevent its Return" (`constitution-paged.txt:413-417`
  (p.10)).
- Congress may alter election regulations "except as to the Places of chusing Senators"
  (`constitution-paged.txt:340-344` (p.9)).
- Habeas corpus suspended "when in Cases of Rebellion or Invasion the public Safety may
  require it" (`constitution-paged.txt:489-491` (p.11)); the text names no body that decides.
- Pardons "except in Cases of Impeachment" (`constitution-paged.txt:627-628` (p.13)).
- Appellate jurisdiction "with such Exceptions, and under such Regulations as the Congress
  shall make" (`constitution-paged.txt:694-697` (p.14)).
- Jury trial "except in Cases of Impeachment" (`constitution-paged.txt:699` (p.14)); grand
  jury except "in cases arising in the land or naval forces, or in the Militia, when in
  actual service in time of War or public danger" (`constitution-paged.txt:913-915` (p.19);
  `constitution-paged.txt:940` (p.20)).
- States may not engage in war "unless actually invaded, or in such imminent Danger as will
  not admit of delay" (`constitution-paged.txt:537-541` (p.12)); inspection duties excepted
  (`constitution-paged.txt:529-535` (p.12)).
- Amendment XI: the judicial power "shall not be construed to extend" to suits against a
  State by citizens of another State or of a foreign state (`constitution-paged.txt:984-987`
  (p.20)).
- Amendment XIII: servitude "except as a punishment for crime"
  (`constitution-paged.txt:1080-1083` (p.22)); Amendment XIV §2 "except for participation in
  rebellion, or other crime" (`constitution-paged.txt:1142-1143` (p.23)); Amendment XIV §3
  "But Congress may by a vote of two-thirds of each House, remove such disability"
  (`constitution-paged.txt:1156-1157` (p.23)).
- Art. V: no State deprived of equal suffrage in the Senate "without its Consent"
  (`constitution-paged.txt:786-787` (p.16)).
- Amendment XXII §1 does not apply to certain office holders (`constitution-paged.txt:1562-1568`
  (p.28)); Amendment XVII does not affect Senators chosen before it
  (`constitution-paged.txt:1307-1309` (p.25)).
- Amendment XXV §4 lets the declaring body be "such other body as Congress may by law
  provide" (`constitution-paged.txt:1740-1742, 1754` (p.31)).
- Art. III §3 cl. 1: treason "only" as defined, and conviction only on two witnesses or
  confession (`constitution-paged.txt:713-717` (p.15)).

## Matters left to law or to a body's own rules (delegation boundaries; the body making each is a B2 position)

"By Law" or similar at `constitution-paged.txt:254` (p.8) (manner of the enumeration),
`constitution-paged.txt:342-343` (p.9) (election regulations), `constitution-paged.txt:348`
(p.9), `constitution-paged.txt:354-355` (p.9) (penalties to compel attendance),
`constitution-paged.txt:357-359` (p.9) (rules of proceedings), `constitution-paged.txt:372`
(p.9) (compensation), `constitution-paged.txt:480-483` (p.11) (necessary and proper),
`constitution-paged.txt:511-512` (p.12) (appropriations), `constitution-paged.txt:550-551`
(p.12) (manner of appointing electors, by each State's legislature),
`constitution-paged.txt:589-591` (p.13) (time of choosing electors), `constitution-paged.txt:603-607`
(p.13) (succession beyond the Vice President), `constitution-paged.txt:643-648` (p.14)
(offices established by law; inferior officers), `constitution-paged.txt:672-674` (p.14)
(inferior courts), `constitution-paged.txt:694-697` (p.14), `constitution-paged.txt:710-711`
(p.15) (trial place), `constitution-paged.txt:719-721` (p.15) (punishment of treason),
`constitution-paged.txt:727-729` (p.15) (proof of State acts), `constitution-paged.txt:1085-1086`
(p.22) and every "appropriate legislation" enforcement section, `constitution-paged.txt:1451`
(p.27), `constitution-paged.txt:1459-1464` (p.27), `constitution-paged.txt:1466-1471` (p.27),
`constitution-paged.txt:1614-1616` (p.29), `constitution-paged.txt:1740-1742` (p.31).

## Documents the source refers to but does not contain

The laws Congress makes under each delegation above; each House's rules and Journals; State
constitutions, laws and the manner each legislature directs; the Articles of Confederation
(`constitution-paged.txt:791-793` (p.16)); treaties; the twelfth article as Amendment XXIII
names it (contained); the resolutions, proclamations, certificates and Federal Register
documents the editorial notes cite. A claim resting on any of them is marked as resting on a
document not available.

## Time bases

- The text's own clocks: terms of two, four and six years; noon on 20 January and 3 January
  (`constitution-paged.txt:1443-1451` (p.27)); ten days, Sundays excepted
  (`constitution-paged.txt:413-414` (p.10)); four days, forty-eight hours and twenty-one days
  (`constitution-paged.txt:1755-1762` (p.31)); three days for adjournment without consent
  (`constitution-paged.txt:367-369` (p.9)); the ten-year enumeration; seven-year
  ratification windows (context). These are rules, not records.
- The editor's ratification chronology (dates of each State's action, completion and
  certification), which the Editorial Note says rests on "the best information available"
  and conflicting sources (`constitution-paged.txt:1899-1909` (p.33)). Context only.
- No chronology of events under the system. The document records none, and the brief forbids
  claims about how any power has been used.

## Noticed while surveying, unverified

Claims for pass 1 to check at the lines; none is a finding.

1. Editor's note 4 says Art. I §3 cl. 2 "has been affected by clause 2 of amendment XVIII"
   (`constitution-paged.txt:374` (p.9)). Amendment XVIII §2 concerns enforcing prohibition
   (`constitution-paged.txt:1345-1346` (p.25)); Amendment XVII's second paragraph concerns
   Senate vacancies (`constitution-paged.txt:1300-1305` (p.25)). A disagreement; leave it as
   the source has it.
2. Editor's note 17 marks Amendment XXV §4's "executive department" (singular, line 1754)
   "So in original. Probably should be" plural (`constitution-paged.txt:1792` (p.31)); the
   first paragraph reads "executive departments" (`constitution-paged.txt:1741` (p.31)). A
   hedged editor's statement.
3. Art. II §1 cl. 6 says the powers and duties "shall devolve on the Vice President"
   (`constitution-paged.txt:600-603` (p.13)); Amendment XXV §1 says the Vice President
   "shall become President" on removal, death or resignation (`constitution-paged.txt:1718-1720`
   (p.30)). The editor says only "affected". What is in force for inability is not settled by
   the document beyond Amendment XXV §3-4's own words.
4. Amendment XXV §4's four days and twenty-one days name no rule for counting (compare
   "Sundays excepted" at `constitution-paged.txt:413-414` (p.10)).
5. Amendment XII's House contingent election needs a quorum of "a member or members from
   two-thirds of the states" (`constitution-paged.txt:1033-1035` (p.21)), and the Senate's a
   quorum of "two-thirds of the whole number of Senators" (`constitution-paged.txt:1044-1047`
   (p.21)); with the superseded sentence on 4 March, the default when the House does not
   choose is Amendment XX §3's (`constitution-paged.txt:1456-1464` (p.27)).
6. Amendment XX §3 and §4 and Art. II §1 cl. 6 leave the case where neither a President elect
   nor a Vice President elect qualifies, and the deaths of persons from whom the House or
   Senate may choose, to law (`constitution-paged.txt:1459-1471` (p.27)).
7. The count of electoral votes: the text says the certificates are opened "and the votes
   shall then be counted" (`constitution-paged.txt:1023-1025` (p.21)), in the passive; it
   names no counter and no check on a certificate.
8. Editor's note 2 calls Art. I §2 cl. 3 "affected" while Amendment XIV §2's own words
   replace its counting rule (`constitution-paged.txt:300-303` (p.8);
   `constitution-paged.txt:1128-1131` (p.22)).

## Grep record

Mechanism greps over lines 164-1897 ("by Law", "may by law", "as provided", "appropriate
legislation", "except", "unless", "construed", "notwithstanding", "Provided") returned the
lines listed under stated-exclusion candidates and delegation boundaries above, plus
ratification-note lines (context). Halts and refusals in the text are prohibitions ("No
State shall", "Congress shall make no law", "shall not be") that take effect only through a
person or court acting on them; pass 1 decides whether any is a mechanism that acts by
itself.
