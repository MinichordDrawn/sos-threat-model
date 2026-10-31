# Survey: chernobyl

Target: Chernobyl Unit 4, an RBMK-1000 reactor, as it stood on 25-26 April 1986: its
automatic protection and control, its operating regime, and the design, operating and
regulatory arrangements around it. A historical system evidenced by one document. Every
range below is the orchestrator's claim, checked by pass 1 at the lines.

## The source

- **Title.** IAEA Safety Series No. 75-INSAG-7, "The Chernobyl Accident: Updating of
  INSAG-1", a report by the International Nuclear Safety Advisory Group (INSAG).
- **Publisher and date.** International Atomic Energy Agency, Vienna, 1992 (printed
  November 1992), `insag-7-paged.txt:110-117` (p.4).
- **Address.** `https://www-pub.iaea.org/MTCD/Publications/PDF/Pub913e_web.pdf`
- **PDF.** `sources/insag-7.pdf`, SHA-256
  `75627db871b8cec591eaf9443ef32da70e6ccb72c34c38b01c18933e21152455`.
- **Extraction.** `sources/insag-7-paged.txt`, 6,747 lines, 149 parts (148 pages and the
  empty part after the last form feed), SHA-256
  `a83c26e92dd7ac110314315850ba8e424b11facbdccbdd51e6d7cad20c321e32`.
- **Tool.** pdftotext version 4.00 (xpdf, Glyph & Cog), `-layout -enc Latin1`, through
  the kit's `page_text.py`.
- **Encoding.** Both `UTF-8` and `Latin1` decode with no replacement characters. `UTF-8`
  renders the source's dashes as em dashes (168) and its bullets as U+2022; `Latin1`
  renders the dashes as `--` and the bullets as a middle dot. `Latin1` was kept, because
  the writing rules forbid em dashes inside a quotation.
- **Page numbers.** Citations use the PDF page from the `=== PDF page N ===` marker. The
  printed page number is the PDF page minus 10 from the Introduction onwards (printed
  page 1 is PDF page 11, `insag-7-paged.txt:351-399`).
- **Copyright.** © IAEA 1992 (`insag-7-paged.txt:110`, p.4). Never ship the PDF or the
  text; quote only the words a claim needs.

## The bodies inside the source

| Body | Lines | PDF pages | Author |
|---|---|---|---|
| Front matter: series note, title pages, member states, INSAG's functions, Foreword by the Director General, contents | `insag-7-paged.txt:1-350` | 1-10 | IAEA; the Foreword is the Director General's |
| INSAG main text, Sections 1 to 6 | `insag-7-paged.txt:351-1365` | 11-36 | INSAG |
| Appendix: measures to improve the safety of RBMK plants (what INSAG was told after the accident) | `insag-7-paged.txt:1368-1446` | 37-38 | INSAG, reporting statements made to it |
| Annex I: report by a Commission to the USSR State Committee for the Supervision of Safety in Industry and Nuclear Power (SCSSINP), chaired by N.A. Shteynberg, Moscow 1991, translated by the IAEA | `insag-7-paged.txt:1447-4469` | 39-98 | the SCSSINP Commission |
| Annex I references and bibliography, English then Russian | `insag-7-paged.txt:4470-5044` | 99-110 | the Commission, translated |
| Annex II: report by a Working Group of USSR Experts, chaired by A.A. Abagyan, Moscow 1991, translated by the IAEA | `insag-7-paged.txt:5045-6536` | 111-142 | the Working Group |
| List of acronyms and symbols | `insag-7-paged.txt:6537-6617` | 143-144 | IAEA |
| Members of INSAG, working group and associated experts; ordering information | `insag-7-paged.txt:6618-6747` | 145-149 | IAEA |

Section starts inside the bodies:

- INSAG main text: §1 Introduction `insag-7-paged.txt:352`; §2 Features of the reactor
  `:419` (§2.1 void coefficient `:426`, §2.2 control and safety rods `:464`, §2.3 rod
  insertion speed `:484`, §2.4 control of power `:492`, §2.5 instrumentation for the
  reactivity margin `:550`, §2.6 core size `:564`, §2.7 capability to alter safety
  systems, trips and alarms `:582`, §2.8 inlet subcooling `:592`, §2.9 primary coolant
  system `:610`, §2.10 containment `:680`); §3 The accident `:706`; §4 More recent
  analyses `:824` (§4.1 `:826`, §4.2 ORM `:892`); §5 Views of INSAG `:944` (§5.1 design
  `:956`, §5.2 operator actions `:1032`, §5.3 safety framework `:1151`, §5.4 ignoring
  deficiencies `:1165`, §5.5 safety analysis `:1179`, §5.6 regulatory regime `:1197`,
  §5.7 safety culture `:1222`, §5.8 summary `:1246`); §6 Conclusions `:1260`. PDF page 36
  is empty (`insag-7-paged.txt:1366-1367`).
- Annex I (the extraction prints the annex number "I" as the digit "1", so Section I-3.8
  appears as `1-3.8`; the INSAG text cites the annex the same way, `insag-7-paged.txt:851`):
  I-1 Introduction `insag-7-paged.txt:1487` (extracted as "M. INTRODUCTION"); I-2
  description of the design `:1609`; I-3 violations of safety standards in the design
  `:1697`, with subsections I-3.1 to I-3.13 at `:1717`, `:1771`, `:1909`, `:1947`,
  `:2027`, `:2043`, `:2076`, `:2130`, `:2259`, `:2300`, `:2326`, `:2373`, `:2501`; I-4
  causes and circumstances `:2557` (I-4.1 test programme `:2559`, I-4.2 chronology
  `:2631`, I-4.3 recorded data `:2637`, I-4.4 modelling `:2890`, I-4.5 scenarios
  `:3017`, I-4.6 the Commission's scenario `:3213`, I-4.7 actions of the personnel
  `:3585`, I-4.8 ORM `:4004`, I-4.9 causes `:4183`); I-5 conclusions `:4253` (I-5.1
  `:4292`, I-5.2 `:4326`, I-5.3 `:4390`, I-5.4 `:4456`).
- Annex II: II-1 description and features `insag-7-paged.txt:5111`; II-2 latest views on
  how the accident occurred `:5320` (II-2.1 test programme `:5529`, II-2.2 chronology
  `:5576`, II-2.3 information sources `:5719`, II-2.4 initial explanations `:5780`, II-2.5
  simulation `:5792`); II-3 measures to improve safety `:6101`; II-4 conclusions `:6506`.

Where two bodies disagree, both are recorded with their lines; the survey resolves none.

## The core and its observers, as the source names them

The core is the reactor and its main coolant circuit; the observers and protections the
source names, with the first lines found (passes 1 to 3 settle each at the lines):

- Reactor control and protection system (RCPS), 211 movable absorber rods; automatic
  power control, swift power reduction, emergency protection (EPS) on dangerous
  divergences, `insag-7-paged.txt:5138-5148` (Annex II).
- Emergency protection rods and the manual EPS-5 button; 18 s full insertion from the
  upper limit stops, `insag-7-paged.txt:486-490`; rod design with graphite displacers and
  the positive scram effect, `:466-482`; EPS-5 pressed at 01:23:40 (Annex I),
  `:3357-3358`.
- Local automatic control and local automatic protection (LAC-LAP) on in-core detectors,
  above 10% of nominal power only, `insag-7-paged.txt:503-525`; Annex II's description of
  LAC and LEP, `:5151-5158`.
- Physical power density distribution control system (PPDDCS), in-core detectors, the
  ranges it covered, `insag-7-paged.txt:494-503`; the state with PPDDCS and LAC-LAP
  switched off, `:527-538`.
- Ex-core detectors at the core mid-plane, `insag-7-paged.txt:528-533`.
- The SKALA computer and the operating reactivity margin (ORM) calculation (PRIZMA): 10-15
  min cycle, about 50 m from the console, `insag-7-paged.txt:552-562`; ORM not in the
  protection system, `:901-902`; SKALA unreliable during the test, `:787-789`; SKALA's
  5 min cycle and restarts, `:2828-2850`.
- Steam separator drum level and pressure protections (EPS-1 and EPS-5 set points),
  `insag-7-paged.txt:806-819` (INSAG) and `:3783-3840` (Annex I).
- Protection on the shutdown of both turbogenerators, blocked, `insag-7-paged.txt:769-781`
  (INSAG) and `:3860-3870` (Annex I).
- Emergency core cooling system (ECCS), blocked from 14:00 on 25 April,
  `insag-7-paged.txt:730-743`.
- The alarm system the safety rules required, `insag-7-paged.txt:1909-1935` (Annex I,
  NSR-04-74 Article 3.1.8).
- The main circulating pumps (MCPs), flow and cavitation margin,
  `insag-7-paged.txt:610-678`.
- The localized containment and its relief capacity, `insag-7-paged.txt:680-703`;
  Annex I on the absence of a full containment, `:2326-2360`.
- Other monitoring systems listed by Annex II (radial and axial power distribution
  monitors with self-powered detectors, startup monitors and reactivity meters, channel
  flow meters, fuel rod leak monitoring, pressure tube integrity),
  `insag-7-paged.txt:5175-5192`.
- The capability to disable safety systems, bypass scram trips and reset or suppress
  alarms with jumper wires, permitted by procedure in some circumstances,
  `insag-7-paged.txt:585-589`; the Procedures for Reswitching Keys and Straps,
  `:816-818` and `:3830-3834`.
- The test programme and its approval, `insag-7-paged.txt:2559-2630` (Annex I) and
  `:5529-5575` (Annex II); the DBA button installed for the test, `:2882-2885`.
- After-accident measures (the Appendix and II-3), recorded as what INSAG was told, not
  as the system of April 1986: `insag-7-paged.txt:1368-1446`, `:6101-6505`.

Mechanism greps run by the orchestrator (pass 1 extends them): "EPS-5" (31 lines from
`insag-7-paged.txt:2112`), "set point" (from `:3637`), "blocked" (`:739`, `:769`,
`:776`, `:810`, `:2729`), "jumper" (`:587`), "bypass" (`:586`, `:1389`), "alarm"
(`:586`, `:1911-1932`), "LAC-LAP" and "PPDDCS" (`:496-528`, `:1997-2009`).

## Positions the source names

In place of endpoints, credentials and data stores.

- Operating staff of the unit: the senior reactor control engineer
  (`insag-7-paged.txt:3357`, `:3702`, `:3724-3737`), unit shift supervisors (`:3296`),
  the plant shift supervisor, electrical workshop shift supervisor and senior turbine
  control engineer (`:3855-3856`).
- Plant management: the Chief Engineer, whose authorization allowed the ECCS blocking
  (`insag-7-paged.txt:734-736`); the Deputy Chief Engineer for Operations (`:765-767`).
- Designers: the General Designer (the Gidroproekt Institute), the Chief Design Engineer
  (NIKIET), the Scientific Manager (I.V. Kurchatov Institute of Atomic Energy)
  (`insag-7-paged.txt:1667-1676`, `:1728-1735`, `:2187-2267`, `:2543-2547`, `:4022-4027`).
- Ministries: the USSR Ministry of Power (operation, design approval) and the Ministry of
  Intermediate Sized Machinery (`insag-7-paged.txt:1617-1625`, `:1650-1676`, `:4244`).
- The regulator: Soviet regulatory authorities, SCSSINP (`insag-7-paged.txt:1197-1221`,
  `:2547`).
- The Kiev grid controller, which asked for the test to be postponed (`insag-7-paged.txt:2686-2687`
  in Table I-I; `:5598` in Table II-III). A party asking for later or more delivery is an
  availability claim, not an attacker (`judging-rules.md`).
- The Ignalina plant, where the positive scram effect was identified in 1983
  (`insag-7-paged.txt:849-858`, `:934-939`).
- A physical condition with no actor behind it: xenon poisoning, low inlet subcooling,
  pump coastdown, the positive void and scram effects (`insag-7-paged.txt:540-547`,
  `:651-678`, `:860-886`).

## The public-safety floor, first lines

No customer data exists. The floor is public safety. Lines that bear on it:
"disastrous consequences", `insag-7-paged.txt:1460-1463` and `:1489-1491` (Annex I); the
containment capable of two simultaneous channel ruptures and the cover plate lifting
beyond that, `:697-703`; the design-basis radiological estimate and the disregarded
more serious events, `:2333-2360`; Annex II on first generation units with no structures
to localize releases, `:6172-6176` (after-accident text). The source says little about
the off-site consequences themselves; pass 1 states what it does say, with lines, and
marks the rest unconfirmed.

## Records the source describes

- Operating logs, with times "in operating log" (`insag-7-paged.txt:2664-2666`, `:3696`,
  `:3855-3856`).
- Built-in chart recorders, slow (tape speed at most 240 mm/h), `insag-7-paged.txt:2650-2656`.
- SKALA: DREG (diagnostic parameter recording program), PRIZMA (calculated parameters,
  printouts only), RESTART magnetic tape; DREG records the position of only nine of 211
  rods and had three interruptions in the last hour, `insag-7-paged.txt:2828-2850`.
- The test's oscilloscope system, not synchronized with SKALA, `insag-7-paged.txt:2852-2885`.
- Telephone tape recordings and explanatory notes by personnel, `insag-7-paged.txt:5765-5778`
  (Annex II).
- The PPDDCS recorder, `insag-7-paged.txt:3748-3751`.

## Chronologies and their clocks

1. **INSAG §3**: times "as quoted in Table I of INSAG-1" (`insag-7-paged.txt:726-728`), a
   document not contained, with some times corrected from the Soviet reports
   (`:772-773`, `:806-807`).
2. **Annex I Table I-I** (`insag-7-paged.txt:2660-2827`): 25 April times "in operating
   log" (`:2664-2666`); 26 April times "on printout of DREG" (`:2690`), with some rows
   marked "(in operating log)" (`:2693`, `:2701`, `:2735`). Two clocks inside one table.
3. **Annex I running text**: times "according to the operating logs" (`insag-7-paged.txt:3696`,
   `:3855`) and times from DREG and the oscillogram (`:2864-2885`).
4. **Annex I oscillogram**: not synchronized with SKALA; synchronized afterwards on two
   reference events (`insag-7-paged.txt:2858-2866`).
5. **Annex II Table II-III** (`insag-7-paged.txt:5584-5718`): times "in operating log" and
   "on printout of DREG"; one row cites "the explanatory notes written by personnel"
   (`:5683-5686`).
6. **Model time** in the simulations: seconds after the EPS-5 button (`insag-7-paged.txt:6021`).

A time from one chronology is never compared with a time from another without saying so.

## Extraction hazards

- **Both chronology tables extract scrambled.** In Table I-I and Table II-III,
  `pdftotext -layout` stacks times in columns away from their events (for example
  `insag-7-paged.txt:2718-2726` and `:5586-5600`, `:5619-5624`). A time-event pairing
  read from either table carries weight only where running text states it or another
  body confirms it; otherwise it is unconfirmed. Table I-I's first rows read in order
  (`:2668-2690`); Table II-III's opening rows are visibly offset from their events.
- **Greek letters as guillemets.** The coefficient symbols (alpha) extract as « or »
  (`insag-7-paged.txt:1799`, `:1836`, `:5221-5222`, `:6596-6598`). Name them in words,
  never copy a guillemet.
- **OCR'd numbers.** Exponents and the delayed neutron fraction garble (`insag-7-paged.txt:446-449`:
  "10"4" for ten to the minus four, "j3" and "|8" for beta). Name such values in words or
  mark them unconfirmed unless running text restates them.
- **Section numbers.** "II" extracts as "n", "H", "11" or "77" in Annex II headings
  (`insag-7-paged.txt:5320`, `:5727`, `:5765`); "I" as "1" in Annex I.
- **Russian lists.** The Russian reference and bibliography lists (`insag-7-paged.txt:4758-5044`) extract
  as transliteration garbage; cite the English lists.
- **Figures and tables.** Pages 129-142 hold figures and tables that extract as noise
  (for example `insag-7-paged.txt:6184-6187`, `:6364-6367`); nothing there carries weight
  unless running text states it.

## Documents the source quotes or cites but does not contain

A claim resting on one of these is marked as resting on a quotation of a document not
available.

- INSAG-1 (IAEA Safety Series No. 75-INSAG-1, 1986), including its Table I
  (`insag-7-paged.txt:211-213`, `:726-728`, `:747-749`).
- INSAG-3 and INSAG-4 (safety principles and safety culture), cited in §5 and §6
  (`insag-7-paged.txt:1226-1236`, `:1311`; INSAG-3 is Annex I Ref. [48], `:4664-4665`).
- NSR-04-74, Nuclear Safety Regulations (Annex I Ref. [8]) and GSP-73, General Safety
  Provisions (Ref. [9]); Annex I quotes articles of both (`insag-7-paged.txt:1717-2300`,
  `:2333-2341`, `:4500-4505`).
- The RBMK technical design documentation and technical safety reports (Refs [7], [10],
  [11], [12], `insag-7-paged.txt:4497-4512`).
- The Operating Procedures for Units 3 and 4 (Ref. [40]), the test programme (Ref. [41]),
  the Procedures for Reswitching Keys and Straps (Ref. [42]) (`insag-7-paged.txt:3604-3610`,
  `:3830-3834`, `:3912-3916`).
- The USSR report to the IAEA of August 1986 (Annex I Ref. [1]), quoted by Annex II
  (`insag-7-paged.txt:4478-4481`, `:5490-5498`).
- The Chief Design Engineer's correspondence after Ignalina and proposal No. 8794
  (`insag-7-paged.txt:2187-2258`).
- A private communication from A.S. Dyatlov (`insag-7-paged.txt:765-767`).
- The full list: Annex I references `insag-7-paged.txt:4470-4683` and bibliography
  `:4685-4757` in English, then both lists in Russian `:4758-5044`.

## Noticed while surveying, unverified

Orchestrator observations for pass 1 to check at the lines; none is a finding.

1. Annex I gives the first pair of MCPs as disconnected at 01:22:46 and as 6.00 to 6.45 s
   after the EPS-5 button pressed at 01:23:40 (`insag-7-paged.txt:2868-2880`). The two
   statements cannot both hold as extracted.
2. INSAG §3 gives the blocking of the turbogenerator trip at 00:43:27
   (`insag-7-paged.txt:772`); Table I-I shows "until 00:43:35" next to that blocking
   (`:2728-2731`), from a scrambled table.
3. INSAG §3(6) says protection at the lower steam drum level "remained effective
   throughout" (`insag-7-paged.txt:818-819`); Annex I says the level fell below the -600
   mm emergency set point without triggering EPS-5 (`:3789-3800`).
4. INSAG §1 calls the Soviet 1986 explanation "drawn from an analytical model
   'normalized' to sparse and inaccurate plant data" (`insag-7-paged.txt:372-375`).

## Not applicable to this target

No clone, commit, dependency sources or test suite. Nothing is run against any system.
No web source is used by any pass.
