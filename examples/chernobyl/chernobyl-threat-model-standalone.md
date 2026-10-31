# Chernobyl Unit 4: a threat model of the unit INSAG-7 describes, standalone copy

This document judges one historical system against the self-observing-systems model:
Chernobyl Unit 4, an RBMK-1000 reactor, as it stood on 25-26 April 1986, with its automatic
protection and control, its operating regime, and the design, operating and regulatory
arrangements around it. It reads without any other file. The model is summarized on one
page below, and the keys to its rows, entries and citations follow the halt paths.

**The evidence.** One document: IAEA Safety Series No. 75-INSAG-7, "The Chernobyl
Accident: Updating of INSAG-1", a report by the International Nuclear Safety Advisory
Group, published by the International Atomic Energy Agency, Vienna, 1992, at
`https://www-pub.iaea.org/MTCD/Publications/PDF/Pub913e_web.pdf`. The PDF has SHA-256
`75627db871b8cec591eaf9443ef32da70e6ccb72c34c38b01c18933e21152455`. Its text was extracted
with pdftotext version 4.00 (xpdf), options `-layout -enc Latin1`, with a line
`=== PDF page N ===` before each page; that text, `insag-7-paged.txt`, has 6,747 lines and
SHA-256 `a83c26e92dd7ac110314315850ba8e424b11facbdccbdd51e6d7cad20c321e32`. Every claim is
a line range in that text. Every citation is its own backticked span holding a line range,
with the PDF page from the nearest page marker above it outside the backticks, never the
printed page number. Nothing was run, and no PDF page was viewed; a claim the document does
not settle is marked not settled by the document. The source and its extracted text are
not shipped with this document. The script `rebuild-source.sh`, published with it,
downloads the PDF from the address above, checks its SHA-256, extracts the text with the
same tool and options, and checks the text's SHA-256, so every citation can be checked
against the same bytes.

**The document's bodies.** INSAG-7 holds several bodies by different authors, and each
citation is read as that kind of statement: the front matter and the Director General's
Foreword (lines 1-350); INSAG's own main text, Sections 1 to 6 (lines 351-1365); the
Appendix, what INSAG was told after the accident (lines 1368-1446); Annex I, the report of
a Commission to the USSR State Committee for the Supervision of Safety in Industry and
Nuclear Power (SCSSINP), chaired by N.A. Shteynberg (lines 1447-4468, its references from
line 4469); and Annex II, the report of a Working Group of USSR Experts chaired by A.A.
Abagyan (lines 5045-6536). Where two bodies disagree, both are cited and none is chosen.

**The verdict in one paragraph.** No ring of observers forms at any layer. The unit's
protections are isolated spokes from sensors to one shared actuator, the 211 control and
protection rods, where a fully withdrawn rod's first motion from its upper limit stop caused "a local insertion of
positive reactivity in the lower part of the core", `insag-7-paged.txt:477-480` (p.14,
INSAG), and whose worth, the ORM, had no "device to measure" it, `:3650-3651` (p.82,
Annex I). The risks are stated first, ranked; the counts and
the shape of the structure close the document.

---

## Model in brief

**Scope.** The model applies where four conditions hold: no central controller, a
catastrophic cost to an undetected failure, an adversarial environment (threats and faults
can mimic legitimate states), and no external maintenance (the system detects, responds
and recovers without an outside authority noticing). The conditions are a filter that puts
a problem in scope, not a bar the system is failing to clear.

**The eight properties.** Every observer is required to have: (1) a heartbeat, a liveness
signal whose absence triggers a response; (2) substrate dependency, sharing the failure
substrate of what it watches; (3) continuous state verification, checking current state
against known-good, not only events; (4) a system-wide response, its detection reaching
the other observers; (5) self-defense, resisting removal by a single action; (6) death
signaling, its own absence crossing an independent boundary and being acted on; (7)
automatic integration, new components entering observation with no manual window; and
(8) reflexive response, acting on detection with no evaluation window, any node able to
halt and the halt reaching at least two others.

**The structure.** The observers form a ring of at least three that observe each other,
plus one coordinator, the +1, which checks something about every member including itself
at the surface, takes their reports and validations back, and is usually the ring's primary
halt. Each observer checks one other and reports to a different one. Rings nest: a ring's
coordinator is a member of the ring above and carries its ring's health upward, so a
failure travels up the coordinators while deep checks stay local. A pairwise edge or a star
is a missing ring.

**Halt on fault.** When any observer detects a fault, the system halts until the fault
clears or the privileged actor leaves. Serving through a detected fault is serving through
a compromise; a degraded mode, a fallback or a warn-and-continue is a failed control. A
sequential check cannot contain an exponential process; only a reflexive, structural
response can.

**Execution-observation coupling.** Execution runs only while its observer's heartbeat
beats: when the observer stops, the work it watched stops. The default is stopped.

**Tiers.** Required observer structure scales with the cost of an undetected failure:
bounded (cron and an alarm), significant (heartbeat and automatic restart), severe
(redundant observers and escalation), catastrophic (the full 3+1 ring). Where a system's
failure reaches the public's safety, public safety sets the catastrophic floor.

**Trust boundaries.** B1 is the observer ring itself, machine to machine; no human belongs
in it. B2 is every privileged position, able to cause harm by mistake or by malice: here,
every person who ran, managed, designed, approved or regulated the unit. B3 is an external
party with no foothold. A privileged actor passes no critical observer without an alert and
a halt. Availability and performance claims are listed and left unevaluated, never ranked:
settling them needs the alternative structure modeled.

**For a system evidenced by a document.** The ring is machine-only: instruments, trips,
interlocks, protection systems and computers are the candidate observers, and no human
check discharges any property. A protection a person could switch off is present only
while it is on, and the means to switch it off is a B2 path to its absence. People's
observation still composes into chains, judged by the same test. Every gap is named, even
where no technology of the period could have closed it.

---

## The system in brief

- **Purpose.** A heterogeneous pressure tube thermal reactor with a graphite moderator and
  boiling light water coolant: 1660 fuel channels in two parallel forced circulation loops,
  steam separated in horizontal drums at about 7 MPa and sent to two turbines,
  `insag-7-paged.txt:5121-5136` (p.113, Annex II §II-1); "intended for base load operation (at
  constant power)", `insag-7-paged.txt:5200-5201` (p.115). The RCPS of 211 movable absorber
  rods maintains the preset power, makes swift reductions on "signals indicating main
  equipment failures" and terminates the chain reaction with the EPS rods on "signals
  indicating dangerous divergences", `insag-7-paged.txt:5138-5146` (p.113, the Working
  Group's description; the next word extracts as "hi", V28).
- **Customers, in two senses.** Who runs it: the senior reactor control engineer, the unit
  shift supervisors and the plant shift supervisor, `insag-7-paged.txt:3357-3358` (p.76),
  `:3296-3298` (p.75), `:3855-3857` (p.86); the plant management under its Chief Engineer,
  `insag-7-paged.txt:3608-3610` (p.81); the ministries, which made "the most important general
  decisions concerning a plant as a whole", `insag-7-paged.txt:4401-4403` (p.97). Who it acts
  on or for: the grid, represented by the Kiev grid controller's request to postpone the
  test, `insag-7-paged.txt:2686-2687` (p.63, Table I-I, a table row; Table II-III has the same
  request with its time column offset, `:5597-5598`, p.122), and the public.
- **Its own goal, in its own words.** The RCPS design documentation as Annex I quotes it: the
  plant's grid share makes "the traditional principle for the design of the RCPS
  unacceptable"; the system "does not make it possible to reduce the power abruptly, but
  does permit accelerated controlled reduction of power"; "A complete reactor shutdown by
  dropping all the RCPS rods is foreseen only for total loss of power to the plant",
  `insag-7-paged.txt:2267-2281` (p.55, quotation of [19], not contained; "all or pan of" in
  the same sentence is OCR, V28). The Working Group's statement of the design's claim:
  "reliable and effective operation of RBMKs in all authorized regimes and safety for the
  whole range of DBAs have been maintained", `insag-7-paged.txt:5284-5288` (p.116). The
  regulation the design was held to: the RCPS "must ensure that the power (chain reaction
  rate) is reliably controlled, that the chain reaction is controlled and can be swiftly
  terminated", `insag-7-paged.txt:1949-1952` (p.49, quoting NSR-04-74 Article 3.3.1).

### Assets and tiers

No customer data exists; public safety sets the floor. What reaches the public, and how:

- **The release path the design admitted.** Part of the main coolant circuit (70 mm and 300
  mm pipelines) lies outside leaktight buildings, in buildings whose "special deflecting plates ... direct
  the release of the radioactive steam-air mixture into the atmosphere",
  `insag-7-paged.txt:2343-2351` (p.56-57, Annex I §I-3.11). The estimate of "2.1 rem [21 mSv]
  to a child's thyroid" was "the grounds given to justify the admissibility of not having a
  proper accident localization system", `insag-7-paged.txt:2352-2355` (p.57, reporting [11],
  not contained).
- **The release path the design disregarded.** The reactor space was capable of withstanding the steam of nominally two
  simultaneous channel ruptures, a limit "due to the sizes of the pressure relief pipes";
  more "would generate a pressure high enough to fail the containment function by lifting
  the cover plate", `insag-7-paged.txt:697-703` (p.19, INSAG §2.10). A rupture of more than
  one channel "could, therefore, cause lifting of the reactor cover plate ... followed by
  failure of the whole RCPS rod insertion system", `insag-7-paged.txt:2119-2123` (p.52, Annex I
  §I-3.7). "The possibility of more serious initial events was disregarded",
  `insag-7-paged.txt:2357-2360` (p.57).
- **How the accident reached it.** The Commission's scenario, presented "no longer based on
  calculations", `insag-7-paged.txt:3457-3458` (p.78): fuel and channel destruction in a
  limited zone, pressure in the reactor space, "partial detachment of the reactor support
  plate from the shroud and consequent jamming of all the RCPS rods, which by that time were
  only half-way down", `insag-7-paged.txt:3501-3507` (p.79).
- **What the source says of the consequences.** "disastrous consequences",
  `insag-7-paged.txt:1461-1463` (p.39), `:1489-1491` (p.39); the Leningrad Unit 1 accident of
  1975 "resulted in radioactive releases", `insag-7-paged.txt:2411-2412` (p.58). The 1986
  release, doses and evacuation are not in the document (U1).

| Subsystem | Customer data? | Tier | Why |
|---|:-:|---|---|
| Reactor core and RCPS (rods, EPS signals, regulators, LAC-LAP) | no | Catastrophic (public-safety floor) | "substantial damage to even a few fuel assemblies ... can, and in this case did, result in destruction of the reactor itself and failure of its emergency protection system", `insag-7-paged.txt:3501-3504` (p.79, the Commission's scenario), presented as "no longer based on calculations", `:3457-3458` (p.78) [corrected] |
| Main coolant circuit and MCPs | no | Catastrophic | by calculations [28], "given the initial state of the reactor just before the tests", a leak of more than 300 mm "could have resulted in an accident which would have been just as serious", `insag-7-paged.txt:3155-3160` (p.72) [corrected, V22] |
| Steam drums and their protections, the turbine protections | no | Catastrophic | below 100 MW(e) "the reactor was left without any protection system to guard against pressure reduction", and "it might have resulted in a reactor runaway even at the regulatory ORM", `insag-7-paged.txt:3846-3851` (p.86, Annex I note) |
| ECCS and its DBA sensors | no | Catastrophic | the third subsystem's feedwater pumps are the design's cooling path on total loss of power in a DBA, `insag-7-paged.txt:2578-2581` (p.61), `:5537-5539` (p.121) |
| Accident localization system | no | Catastrophic | the last barrier; sized for two ruptures, `insag-7-paged.txt:697-703` (p.19) |
| SKALA, PRIZMA, DREG, RESTART | no | Catastrophic | the ORM "determined the ability of the reactor's EPS to perform its functions", `insag-7-paged.txt:4144-4148` (p.92), and the computer was its only computed source, `insag-7-paged.txt:3650-3655` (p.82) |
| Test instrumentation (DBA button, oscilloscope) | no | Catastrophic for the DBA button; the oscilloscope records only | a B2 control and a signal-path device, not scored, `insag-7-paged.txt:2885-2888` (p.67), `:2854-2861` (p.66) |
| Design, operating and regulatory arrangements | no | B2 positions, not a subsystem | people and documents, recorded as B2 controls and prescribed responses |

Every subsystem sits at the floor; the full stack (a 3+1 ring) is the bar for each. GR8's
tier is moot: its members are not scored (V4).

---

## Risks, stated first

Ranked by the rule stated in Impact across the deployment: what a position gains times how
many units one act or condition reaches, then how far toward the public-safety floor, with
nothing positioned to notice; a tie goes to the position that needs no privileged act.
Availability is not ranked.

1. **The design of every RBMK unit left two hazards with no stated observer, the halt's
   own "introduction of positive reactivity" and a void coefficient that varied with the
   core and the regime and, with the power coefficient, was "both positive" at the time of
   the accident, and left the ORM that governed the halt's worth with no observer against
   its limit.** The rod design with its
   graphite displacer was that "of each rod of all RBMK reactors",
   `insag-7-paged.txt:472-473` (p.14, INSAG), and the Scientific Manager wrote that
   "Triggering of the EPS in this case may lead to the introduction of positive
   reactivity", `insag-7-paged.txt:2204-2205` (p.54, quoted [24], not contained). INSAG: the
   void coefficient "varied over a wide range from negative to positive values as a
   function of the composition of the core and the operating regime of the reactor", while
   "the fast power coefficient remained negative under normal operating conditions", and
   "At the time of the accident, the void and power coefficients of reactivity were both
   positive", `insag-7-paged.txt:452-456` (p.13); "There is no safety analysis
   of the void coefficient of reactivity in the RBMK-1000 design documentation",
   `insag-7-paged.txt:1866-1867` (p.47, Annex I); the design "made no provisions for the
   ORM to be treated as a parameter which would trigger the alarm system or the EPS when
   it reached the limit value", `insag-7-paged.txt:1923-1925` (p.48, Annex I). The rod
   effect was known to the Chief
   Design Engineer and the Scientific Manager "before the accident", having been
   "discovered experimentally" in November/December 1983, `insag-7-paged.txt:2187-2190`
   (p.53), yet "the appropriate changes were not made to the Operating Procedures before
   1986", `insag-7-paged.txt:4139-4140` (p.92) (DG9). Annex I finds that "the event which
   initiated the accident was the pressing of the EPS-5 button when the RBMK-1000 reactor
   was operating at low power with a greater than permissible number of manual control
   rods withdrawn", `insag-7-paged.txt:3444-3447` (p.78); INSAG says the rods' insertion "was probably a
   decisive contributory factor", `insag-7-paged.txt:1293-1297` (p.33).
   Ids: S1, D7, T2, T10, T16, T18, E4, E5, R6, R7, R8, R9, M2, M3, M5, M9; X1 to X11.

2. **In the low-ORM, low-power state, "if positive reactivity had occurred for any reason,
   there could have been a power excursion" that no observer was placed to notice.** The
   Commission found "a rather extended initial reactor state" in which such an excursion
   would have met "conditions in which the reactor's EPS would be unable to perform its
   functions", `insag-7-paged.txt:3350-3353` (p.76, Annex I). More than two simultaneous
   channel ruptures "would generate a pressure high enough to fail the containment
   function by lifting the cover plate", `insag-7-paged.txt:701-703` (p.19, INSAG), and a
   rupture of more than one channel "could, therefore, cause lifting of the reactor cover
   plate ... followed by failure of the whole RCPS rod insertion system",
   `insag-7-paged.txt:2120-2123` (p.52, Annex I). Part of the main coolant circuit lies
   outside leaktight buildings, in buildings whose plates "direct the release of the radioactive
   steam-air mixture into the atmosphere", `insag-7-paged.txt:2343-2351` (p.56-57). The
   state needs no privileged act only on the Commission's hypothetical that conditions
   like those of 26 April "might have occurred without any intervention on the part of the
   personnel", `insag-7-paged.txt:3898-3900` (p.87). (Conditional on an unconfirmed item:
   the Commission's hypothetical.) On 26 April the state was reached through acts Annex I
   calls violations: "more than the permitted number of manual control absorbing rods"
   withdrawn, `insag-7-paged.txt:4193-4196` (p.93), and operation at an ORM of 15 rods or
   less, `insag-7-paged.txt:3939-3941` (p.88).
   Ids: S1, S4, D5, D9, D10, D11, D12, D13, D14, T18, M3, M5, M6, M11; X1, X2, X4, X5, X6,
   X8, X10.

3. **One hand at the console reached the EPS-5 button, the rod positions and the
   regulators' set points, with no device in the design to measure, in terms of effective
   manual control rods, the ORM those acts governed.** To compensate xenon poisoning "it proved necessary for some of the ORM rods
   to be withdrawn", `insag-7-paged.txt:3230-3232` (p.73, Annex I), and by the
   Commission's presumption the engineer "probably reduced the set points" and then
   restored power "by manipulating the set points", `insag-7-paged.txt:3732-3738` (p.83).
   INSAG: "it is likely that the operator did not know the value of the ORM during the
   critical part of the test", `insag-7-paged.txt:789-790` (p.21). "The Commission was
   unable to establish why the button was pressed", `insag-7-paged.txt:3360` (p.76).
   Annex I finds "no provision in the design of the RBMK reactor for a device to measure
   the ORM in terms of effective manual control rods", the operator summing the rod
   insertions read from the instruments or having to "instruct the plant computer to make
   the calculation and wait a few minutes for the result", `insag-7-paged.txt:3650-3655`
   (p.82), and the position, privileged, reaches the core at one unit through the state of
   the risk above.
   Ids: S1, T2, T10, T11, T14, D3, D4, D5, M6; X1, X3, X4, X5.

4. **"a ready capability for the operators manually to disable certain safety systems,
   bypass automatic scram trips, and reset or suppress various alarm signals" left each
   protection's absence unobserved.** The capability is INSAG's finding, and "The operating
   procedures permitted such disabling under some circumstances",
   `insag-7-paged.txt:585-589` (p.16, INSAG); the
   Reswitching Procedures [42] provided for disabling the two-turbine protection,
   switching off ECCS actuation and selecting the level and pressure set points,
   `insag-7-paged.txt:3866-3871` (p.86), `:3679-3683` (p.82), `:3795-3797`, `:3830-3833`
   (p.85), a document not contained. Nothing recorded or resisted a removal: of the level
   set point, "There are no notes on this in the operating logs",
   `insag-7-paged.txt:3795` (p.85); INSAG: disabling "seems to have been regarded rather
   lightly both in the operating procedures and by the operators",
   `insag-7-paged.txt:1086-1088` (p.28). A removal reaches whatever the removed protection
   guards and needs a fault to follow it.
   Ids: T1, T2, T3, T4, T5, T7, T8, E3, M9; X3, X4, X5, X6, X7, X8.

5. **Operation "at an ORM" below 26 rods and the switching off of "the whole ECCS" each
   rested on one authorization that nothing checked.** The quoted §9 required that
   "Reactor operation at an ORM" below 26 rods "must be authorized by the Chief Plant
   Engineer", `insag-7-paged.txt:4018-4019` (p.89, quoted [40], not contained). Whether
   that authorization was sought or given on 25 April is not stated (U25). [42] §2
   "authorized the Chief Engineer of the plant to switch off automatic actuation of the
   ECCS", "tantamount to switching off the fast acting part of the system and, therefore,
   the whole ECCS", `insag-7-paged.txt:3680-3683` (p.82, Annex I on [42]), and the plant ran at
   half power "for the period of approximately 11 hours leading up to the accident, with
   the ECCS blocked out", `insag-7-paged.txt:738-739` (p.20, INSAG). When the planned power
   could not be restored, "on the spot they modified the test conditions",
   `insag-7-paged.txt:1114-1115` (p.29, INSAG), and the regulations "did not require the
   plant managers to obtain approval for such tests" from the General Designer, the Chief Design Engineer, the Scientific Manager and the regulatory body, `insag-7-paged.txt:2603-2611` (p.61-62,
   Annex I) (DG14).
   Ids: E1, E2, E6, T5, T12, D6, M9; X6, X11.

6. **The test brought the reactor "to a state not specified by procedures or investigated
   by an independent safety body".** The words are INSAG's, `insag-7-paged.txt:1277-1279`
   (p.33). The programme isolated the ECCS under its §2.15,
   `insag-7-paged.txt:3673-3676` (p.82), added the seventh and eighth MCPs under its §2.12,
   `insag-7-paged.txt:3914-3917` (p.87), and used a button "specially installed for test
   purposes in order to simulate a DBA signal", `insag-7-paged.txt:2885-2886` (p.67).
   Annex I holds that "there is nothing wrong with the programme itself" and places the
   causes "in the ignorance on the part of the programme developers of the characteristics
   of the behaviour of the RBMK-1000 reactor under the planned operating conditions",
   `insag-7-paged.txt:2613-2623` (p.62). The planned mode's high flow and its subcooling "to
   just below boiling point" were factors that "proved to be directly related to the scale
   of effects manifested during the tests", `insag-7-paged.txt:2625-2629` (p.62).
   Ids: S3, T5, T12, T13, D12, E6; X6, X9.

7. **Feedwater, drum level and the turbine configuration moved by the shift's hands, under
   "manual control of the water level in the steam separator drums", with no observer of
   the states they set.** The listed operations are Annex I's, `insag-7-paged.txt:3247-3249`
   (p.74). The unit shift supervisors "gave the order to close the emergency stop valves",
   closed at 01:23:04, `insag-7-paged.txt:3296-3298` (p.75). At 00:41 turbogenerator No. 8
   was disconnected for vibration measurements, a procedure "not envisaged in the
   turbogenerator No. 8 rundown test programme", `insag-7-paged.txt:3855-3859` (p.86). The
   feedwater figures differ between bodies (DG12), and of the level set point "There are
   no notes on this in the operating logs", `insag-7-paged.txt:3795` (p.85).
   Ids: T12, T13, T14, T15, R3, D6, M1; X6.

8. **The one computed figure for the EPS's worth "did not take into account the position
   of the rods of automatic regulators Nos 1, 2 and 3" and was not computed at 01:22:30.**
   Annex I found PRIZMA "unreliable at this time", about 07:00 on 25 April,
   `insag-7-paged.txt:3612-3619` (p.81), and INSAG, "According to the record", places the
   unreliability of "the computer SKALA, which was used to calculate the ORM", "in the period
   in which the test took place", `insag-7-paged.txt:787-789`
   (p.21). "No operating calculations were performed by the PRIZMA program at this time",
   `insag-7-paged.txt:3251-3253` (p.74); its results were "recorded only on printouts",
   `insag-7-paged.txt:2850` (p.66), from a computer about 50 m from the console,
   `insag-7-paged.txt:552-553` (p.16, INSAG).
   Ids: S2, R1, D1; X1.

9. **The record of the last seconds is a reconstruction: "the rate of development of
   subsequent events is not compatible with the resolving power of the reactor parameter
   recording devices".** The sentence is Annex I's, `insag-7-paged.txt:3361-3362` (p.76).
   DREG recorded the position of "only nine of the 211 RCPS rods",
   `insag-7-paged.txt:2838-2839` (p.66), and the test oscilloscope lacked "synchronization
   between the electrical parameters and the reactor parameters recorded by the SKALA
   system", `insag-7-paged.txt:2859-2861` (p.66). The first account's statement that "all
   the thermal parameter reactor protection systems were switched off" Annex I calls "not
   true", `insag-7-paged.txt:3800-3802` (p.85) (DG10). The position reaches the record only.
   Ids: R4, R5, R10.

---

## The architectural model

### The ring test

#### Observer inventory

Each entry has a role: an observer watches something and reports or acts on what it
finds; observed components, B2 controls and signal-path devices are not observers.
Only observers go on the scorecard. The last column
answers whether a person could disable, bypass or reset the entry; "not stated" is itself
unconfirmed (U10, U16).

| # | Entry | Lines | What it checks | Reports to / on fault | Person could remove it |
|---|---|---|---|---|---|
| O1 | RCPS as a system (211 rods) | `insag-7-paged.txt:5138-5149` (p.113) | preset power; "signals indicating main equipment failures"; "signals indicating dangerous divergences" | the rods, 0.4 m/s, `:5148-5149` (p.113); full insertion 18 s (INSAG, `insag-7-paged.txt:486-487`, p.14) or 18-21 s (Annex I, `insag-7-paged.txt:2052-2053`, p.51), DG16 | jumper wires "permitted ... under some circumstances", `insag-7-paged.txt:585-589` (p.16); keys and straps under [42], `insag-7-paged.txt:3679-3683` (p.82), `:3867-3871` (p.86); an EPS rod convertible to a manual rod "without any technical or organizational problems", `insag-7-paged.txt:2055-2057` (p.51) |
| O2 | Emergency power protection | `insag-7-paged.txt:3382-3384` (p.76), `:2955-2959` (p.68) | total lateral chamber current against a set point; "power exceeded 530 MW(th)" is a table value, `insag-7-paged.txt:2785-2787` (p.65), U2 | the rods; DREG | personnel "did not deactivate" it, `insag-7-paged.txt:3977-3979` (p.88); the general capability at `:585-589` (p.16) |
| O3 | Emergency power increase rate protection, main and "working range" forms [corrected, V3] | `insag-7-paged.txt:2785-2786` (p.65), `:3702-3704`, `:3721-3724` (p.83) | rate of power rise ("less than 20 s", table only, U2) | the rods; a board lamp; DREG | the working range form changed state when all regulators left automatic regime; the log says it "is switched on" and the presumed lamp reads "is on"; whether it was armed or disarmed is not settled (U24) |
| O4 | LAC-LAP (LAC and LEP) | `insag-7-paged.txt:503-505` (p.14), `:524-525` (p.15), `:2004-2007` (p.50), `:5151-5156` (p.113) | in-core chambers; LEP ensures "the preset fuel assembly power level at specific core locations is not exceeded" | the rods (LAC); LEP's action unstated (U6); above 10% power only | switched off at low power, `insag-7-paged.txt:527-528` (p.15); the 00:28 transfer to global control, `insag-7-paged.txt:2702-2704` (p.63, Table I-I, "in operating log"), `:3223-3228` (p.73) |
| O5 | Automatic power regulators Nos 1 to 3 (12 rods) | `insag-7-paged.txt:470` (p.14), `:3617-3619` (p.81), `:3711-3735` (p.83) | power against a set point; measuring-circuit imbalance | lamps and DREG ('failure in measuring circuit', `insag-7-paged.txt:3728-3731`, p.83); drops out of automatic regime | set points lowered by the 'fast power reduction' button and adjusters, `insag-7-paged.txt:3732-3739` (p.83, presumption, "probably"), `:3637-3639` (p.81, quoted §12) |
| O6 | 'One overcompensation upwards' signal | `insag-7-paged.txt:3332-3338` (p.75) | whether the automatic rods can move into the core | DREG only; on 01:19:39-01:19:44 and 01:19:57-01:23:30 | not stated (U16) |
| O7 | Drum level protection: EPS-5 at -600 mm (selected by hand) and EPS-1 at -1100 mm | `insag-7-paged.txt:3790-3800` (p.85), `:813-819` (p.22) | drum level on an instrument whose range extracts as "-1-400 to -1200 mm", `insag-7-paged.txt:3810-3812` (p.85, quoted [43]; V28) | the rods: EPS-5 "complete shutdown of the reactor", `:3812-3813` (p.85) | the operator reswitches "manually using the general key when alarm signals appear", `insag-7-paged.txt:3814-3817` (p.85, quoted [43]); [42] §9, `:3795-3797` (p.85) |
| O8 | Drum pressure reduction protection | `insag-7-paged.txt:3828-3851` (p.85-86) | drum pressure, 55 then 50 kgf/cm2 from 00:36:24 | the turbine: "designed to stop the turbine", `insag-7-paged.txt:3842-3845` (p.86) | [42] §12, "entitled to select", `insag-7-paged.txt:3830-3833` (p.85) |
| O9 | Two-turbogenerator shutdown protection (EPS-5 on both turbines' stop valves) | `insag-7-paged.txt:3863-3873` (p.86), `:769-781` (p.21) | both turbines' stop valves | the rods (EPS-5; DG19, U14) | disabled under [42] §1 below 100 MW(e), `insag-7-paged.txt:3866-3871` (p.86); time DG2 |
| O10 | ECCS automatic actuation on a DBA signal | `insag-7-paged.txt:3514-3517` (p.79, scenario), `:2578-2581` (p.61), `:3673-3687` (p.82) | depressurization in "the reinforced leaktight compartments where the sensors are placed" | ECCS pumps and valves | slide valves closed at 14:00 under programme §2.15; [42] §2 lets the Chief Engineer switch off automatic actuation, "tantamount to switching off ... the whole ECCS", `insag-7-paged.txt:3673-3683` (p.82); no interlock stated (U10) |
| O11 | Reactor space overpressure EPS signal [corrected, V32] | `insag-7-paged.txt:2815-2816` (p.65, Table I-I), `:2955-2959` (p.68), `:5274` (p.116) | reactor space pressure | the rods; the relief pipes to the bubbler pools are a passive barrier (OC9), `insag-7-paged.txt:693-701` (p.19) | not stated (U16) |
| O12 | Main coolant circuit overpressure protection (relief valves, fast acting steam dump) | `insag-7-paged.txt:5273` (p.116), `:3247-3248` (p.74), `:2812-2813` (p.65) | drum or circuit pressure | opens valves; nothing reads the valves | not stated (U16) |
| O13 | Fuel rod leak monitoring | `insag-7-paged.txt:5183-5188` (p.114) | fission products in each steam-water line, sequentially, a detector "moved by a special dolly" | "All the data are sent to the computer", `insag-7-paged.txt:5196` (p.115) | not stated (U16) |
| O14 | Pressure tube integrity monitoring | `insag-7-paged.txt:5193-5194` (p.115) | gas humidity and temperature | the computer | not stated (U16); gas replacement beside 03:45 on 25 April in Table I-I, `insag-7-paged.txt:2669-2670` (p.63), and beside 01:06 in Table II-III, `:5592-5593` (p.122), a table pairing no running text confirms; effect unstated (U13) |
| O15 | Channel flow monitoring (ball flow meters) | `insag-7-paged.txt:5180-5182` (p.114) | per-channel flow | the computer | not stated (U16) |
| O16 | PPDDCS with radial and axial SPD monitoring | `insag-7-paged.txt:494-503` (p.14), `:5176-5177` (p.114) | power distributions in 10-120%, total power in 5-120% of nominal | the operator; a recorder (SP7) | switched off at low power, `insag-7-paged.txt:527-528` (p.15) |
| O17 | Startup monitoring systems | `insag-7-paged.txt:5179` (p.114) | not stated | not stated | role unconfirmed; not scored (U7, V4) |
| O18 | Radiation monitoring system | `insag-7-paged.txt:5282` (p.116) | not stated | not stated | role unconfirmed; not scored (U7, V4) |
| O19 | SKALA with PRIZMA (ORM) | `insag-7-paged.txt:552-562` (p.16), `:2828-2850` (p.66), `:5735-5755` (p.125) | the ORM from about 4000 inputs; cycle 10-15 min (INSAG), 5 min for SKALA's parameters (Annexes), 15 min for the ORM before the accident (Annex I, `insag-7-paged.txt:2490-2491`, p.59), DG25 | "recorded only on printouts", `insag-7-paged.txt:2850` (p.66); about 50 m from the console, `:552-553` (p.16); "signals indicating divergences" from "the computer", identified with SKALA by inference, `insag-7-paged.txt:5196-5198` (p.115) [corrected, V12, V38] | not stated; "nor was it incorporated into the reactor's protection system", `insag-7-paged.txt:901-902` (p.24) |
| O20 | 'No voltage, 48 V' signal | `insag-7-paged.txt:2816-2817` (p.65), `:5705-5706` (p.124), `:2085` (p.51, quoted NSR) | supply to the EPS servodrives | DREG; effect on the rods unstated (U4) | the clutch power switch, `insag-7-paged.txt:2822-2823` (p.65, log note) |
| O21 | EPS-1, EPS-2, EPS-3 | `insag-7-paged.txt:3890-3894` (p.87), `:3810-3812` (p.85), `:5141-5143` (p.113) | main equipment failures, from Annex II's RCPS description, which names no EPS mode; triggers otherwise unstated (U21) | controlled reduction; to 200-300 MW(th) under §11.4 after EPS-3, the "frequency variations" there going with a remote reduction, not with EPS-3; operation continues | the general capability, `insag-7-paged.txt:585-589` (p.16) |

#### Signal-path devices

| # | Entry | Lines | What it carries | Note |
|---|---|---|---|---|
| SP1 | Lateral ionization chambers (ex-core, in the lateral biological shield tank, all at the core mid-plane) | `insag-7-paged.txt:497-498` (p.14), `:528-533` (p.15), `:2008-2013` (p.50), `:3382-3384` (p.76) | total power to O2, O3 and the reactor power recorder (SP6) | cannot indicate the distribution within the core nor the axial distribution; at low power with LAC-LAP off they "do not provide signals for the central parts of the reactor core", `:2009-2013` (p.50) |
| SP2 | In-core ionization chambers | `insag-7-paged.txt:2005-2006` (p.50), `:5152-5153` (p.113) | signals to LAC-LAP (O4) | only above 10% power |
| SP3 | DREG, diagnostic parameter recording program | `insag-7-paged.txt:2834-2846` (p.66), `:5739-5750` (p.125) | several hundred discrete and analogue signals at under 1 s; not power, reactivity or channel flow; nine of 211 rod positions at 1 min | three interruptions in the last hour; Table I-I: did not work 00:39:32 to 00:43:35, 00:52:35 to 00:59:54, 01:12:10 to 01:18:49, `:2728`, `:2737-2738`, `:2748-2749` (p.64; running text confirms three interruptions, not their times) |
| SP4 | RESTART magnetic tape | `insag-7-paged.txt:2847-2848` (p.66), `:3251-3252` (p.74) | reactor state every 5 min; last record 01:22:30 | the ORM was computed from it after the accident at Smolensk, `:3253-3255` (p.74) |
| SP5 | Built-in chart recorders | `insag-7-paged.txt:2650-2655` (p.62), `:5729-5731` (p.125) | slow parameters, tape speed at most 240 mm/h | "cannot be used to record fast non-steady processes" |
| SP6 | Reactor power recorder (total lateral chamber current) | `insag-7-paged.txt:3382-3384` (p.76) | total power trace | recorded "a small decrease in power and a subsequent increase" after EPS-5 |
| SP7 | PPDDCS recorder and neutron power recorder | `insag-7-paged.txt:3747-3753` (p.84) | thermal and neutron power traces | did not record the reduction below 30 MW; neutron power recorder showed zero for about 5 min |
| SP8 | Test oscilloscope system | `insag-7-paged.txt:2852-2863` (p.66), `:5759-5763` (p.125) | electrical parameters of TG8, MCP, feedwater pump, sections 8RA and 8RB | not synchronized with SKALA; synchronized afterwards on two reference events, `:2861-2866` (p.66) |
| SP9 | Board indicators of the senior reactor control engineer | `insag-7-paged.txt:3723-3724`, `:3728-3731` (p.83), `:3817` (p.85) | regulator fault lamps, rate protection state, drum level alarm signals | a lamp to a B2 position; the alarm system NSR-04-74 Article 3.1.8 required is quoted at `:1911-1918` (p.48) and found absent for the ORM and "a number of other parameters", `:1923-1934` (p.48) |
| SP10 | Teletape | `insag-7-paged.txt:2781-2783` (p.65, Table I-I) | EPS-5 at 01:23:39 "on teletape" against 01:23:40 on DREG, `insag-7-paged.txt:2867-2870` (p.66) | two recorders, one second apart (DG11) |
| SP11 | Telephone tape recordings | `insag-7-paged.txt:5767-5769` (p.125) | personnel calls | "did not turn up any further essential data" |
| SP12 [added, K5] | Rod position indicators at the console | `insag-7-paged.txt:3652-3654` (p.82) | the operator read the depth of intermediate rods "from the measuring instruments" and corrected "for the non-linearity of the graduation scale" | whether a console device or a computer readout is not settled by the document |

#### B2 controls

| # | Entry | Lines | What the person does | Observer it removes, resets or injects into |
|---|---|---|---|---|
| BC1 | EPS-5 manual button | `insag-7-paged.txt:3357-3358` (p.76), `:4185-4187` (p.93), `:2093-2094` (p.52, quoted NSR) | commands insertion of all EPS and manual rods; pressed "for some reason which has not yet been established for certain" | injects the halt command into O1 |
| BC2 | Jumper wires on accessible terminals | `insag-7-paged.txt:585-589` (p.16, INSAG §2.7) | "disable certain safety systems, bypass automatic scram trips, and reset or suppress various alarm signals"; "The operating procedures permitted such disabling under some circumstances" | any trip or alarm (RP1) |
| BC3 | Reswitching keys and straps, the "general key" | `insag-7-paged.txt:3814-3817` (p.85), `:3867-3871` (p.86), `:3679-3683` (p.82), `:3795-3797`, `:3831-3833` (p.85) | select set points and disable protections per Procedures [42] §§1, 2, 9, 12 | O7, O8, O9, O10 (RP2 to RP5) |
| BC4 | 'Fast power reduction' button | `insag-7-paged.txt:3704-3705`, `:3732-3734` (p.83) | lowers regulator set points, by the log; the rate of 2% per second is in the Commission's presumption that the engineer "probably" used it | O5's set point |
| BC5 | Regulator set point adjusters | `insag-7-paged.txt:3637-3639` (p.81), `:3737-3739` (p.83) | manual power reduction and restoration | O5's set point |
| BC6 | Transfer from local to global control | `insag-7-paged.txt:2702-2704` (p.63, Table I-I, operating log), `:3223-3228` (p.73) | hands control from LAC to regulators Nos 1 and 2 | switches O4 off |
| BC7 | DBA button (installed for the test) | `insag-7-paged.txt:2885-2888` (p.67), `:5714-5717` (p.124) | simulates a DBA signal to the start-up system of diesel generator No. 6 and connects the TG8 rundown unit | injects a protection signal into the electrical supply (OC11); "the exact times at which the DBA button was pressed and at which the oscillograph was turned on are not known", `:5672-5674` (p.123, Table II-III) |
| BC8 | Order to close the TG8 emergency stop valves | `insag-7-paged.txt:3296-3298` (p.75) | starts the rundown at 01:23:04 | the physical coupling into the drums and the MCPs (see the edges below) |
| BC9 | ECCS manual isolating slide valves | `insag-7-paged.txt:3673-3676` (p.82) | isolates all three ECCS subsystems | removes O10's actuator (RP5) |
| BC10 | Manual control of drum level and feedwater flow | `insag-7-paged.txt:3247-3249` (p.74), `:3089-3093` (p.71, quoted [33] and the Commission's note) | sets feedwater; the quoted report says an operator "reduced the feedwater flow rate" at 01:20; the Commission says it "was brought back to the average value" | drives the level O7 watches |
| BC11 | Power switch of the clutch mechanisms | `insag-7-paged.txt:2822-2823` (p.65, log note), `:5711-5712` (p.124) | de-energizes the rod drive couplings | O1's actuator (effect unconfirmed, U4) |
| BC12 | Withdrawal of manual control rods to the upper limit stops | `insag-7-paged.txt:3230-3237` (p.73-74), `:3444-3447` (p.78), `:1013-1017` (p.27) | compensates xenon poisoning; sets the ORM | sets the state in which, by Annex I's finding, O1's halt was the initiating event (S1) |
| BC13 | Chief Engineer authorizations | `insag-7-paged.txt:3608-3610` (p.81), `:4018-4019` (p.89), `:3679-3683` (p.82), `:734-736` (p.20) | permits ORM below 26 rods; permits ECCS switch-off | the ORM limit (PR1); O10 |
| BC14 | Operating logs | `insag-7-paged.txt:2664-2666` (p.63), `:3698` (p.83), `:3855-3857` (p.86), `:2820-2823` (p.65) | human record of times and actions; no note of the level reswitching, `:3795` (p.85) | a record kept by a B2 position, not an instrument |
| BC15 | The approvals chain | `insag-7-paged.txt:1737-1759` (p.44-45), `:1684-1685` (p.43), `:2194-2196` (p.54), `:4105-4111` (p.91), `:4022-4025` (p.89), `:5557-5568` (p.121) | Technical Safety Report approved by three state committees with no list of violations; Physical Startup Commissions' proposals "none ... implemented"; the Chief Design Engineer's 1984 intention to limit withdrawn rods; the plant's "scientific managers" yearly review; the clearance the Operating Procedures required for non-design devices used at power | the design's hazards (R6, R7, E5) |
| BC16 | On-the-spot change of the test programme to 200 MW(th) | `insag-7-paged.txt:1096-1115` (p.29), `:1333-1335` (p.34), `:3877-3880` (p.86) | lowers the test power from 700 MW(th) | the low-power state of the test (T12, D12) |
| BC17 | Explanatory notes written by personnel | `insag-7-paged.txt:5683-5686` (p.124, Table II-III), `:5767-5770` (p.125) | the source for "the EPS-5 button was pressed" in Table II-III | a human record |

#### Observed components

| # | Entry | Lines |
|---|---|---|
| OC1 | The core: void and power coefficients, axial and radial fields, xenon poisoning, subcooling | `insag-7-paged.txt:426-456` (p.13), `:1781-1832` (p.45-46), `:3262-3284` (p.74) |
| OC2 | The RCPS rods: 5 m absorber, graphite displacer on a telescope, 1.25 m water, 18 s insertion | `insag-7-paged.txt:466-490` (p.14), `:2162-2185` (p.53) |
| OC3 | The ORM as a state of the core | `insag-7-paged.txt:894-905` (p.24), `:5229-5232` (p.115) |
| OC4 | The MFCC and its eight MCPs with their check valves, flow control valves and isolating valves | `insag-7-paged.txt:610-678` (p.17-18), `:3316-3320` (p.75) |
| OC5 | The steam separator drums | `insag-7-paged.txt:3785-3786` (p.84), `:2808-2811` (p.65, Table I-I) |
| OC6 | Feedwater supply | `insag-7-paged.txt:3089-3093` (p.71), `:5645-5654` (p.123, Table II-III, scrambled) |
| OC7 | Turbogenerators Nos 7 and 8, the rundown unit, diesel generator No. 6 | `insag-7-paged.txt:2562-2576` (p.61), `:2885-2888` (p.67) |
| OC8 | Fuel channels and fuel elements | `insag-7-paged.txt:5123-5126` (p.113), `:3415-3423` (p.77) |
| OC9 | Reactor space, lower plate, 2000 tonne cover plate, structure E, and the relief pipes to the bubbler pools (a passive barrier) | `insag-7-paged.txt:689-692` (p.19), `:693-701` (p.19), `:2119-2123` (p.52) |
| OC10 | Accident localization system: leaktight compartments, isolation valves, bubbler pools, deflecting plates | `insag-7-paged.txt:5275-5279` (p.116), `:682-695` (p.18-19), `:2349-2351` (p.57) |
| OC11 | Electrical supply: external source, TG8 rundown, RCPS bus bars, 48 V servodrive supply | `insag-7-paged.txt:651-653` (p.18), `:2085` (p.51), `:2816-2817` (p.65) |
| OC12 | SKALA computer hardware (V-3M) | `insag-7-paged.txt:2830-2831` (p.66), `:5735-5736` (p.125) |
| OC13 | Graphite stack gas circuit | `insag-7-paged.txt:2669-2670` (p.63, Table I-I) |
| OC14 | Upper and lower limit stop switches of the rods | `insag-7-paged.txt:487` (p.14), `:2821-2822` (p.65), `:4063-4065` (p.90) |

#### Edges and the ring requirements

Every observer checks the process (OC1 to OC11). Its reports go to one of three sinks: the
shared rod actuator, a recorder (SP3 to SP8), or a lamp or printout read by a B2 position.
Physical couplings carry one observer's output to another's input: the turbine stop valves
(BC8) slow four MCPs and raise drum pressure, `insag-7-paged.txt:667-671` (p.18),
`:3322-3324` (p.75); EPS-1 to EPS-3 drop the drum level to O7's -600 mm set point,
`insag-7-paged.txt:3810-3813` (p.85, quoted [43]); rod insertion from the upper stops
displaces water in the lower core, `insag-7-paged.txt:477-482` (p.14), `:2180-2185` (p.53);
the rupture of several channels partly detaches the support plate from the shroud and jams the rods, `insag-7-paged.txt:3504-3507`
(p.79, scenario).

| Requirement | Present? | Evidence |
|---|:-:|---|
| A cycle of at least three mutual observers | no | No observer watches another observer's health. The observer-to-observer edges found: O6 watches O5's actuator and reports to a recorder, `insag-7-paged.txt:3332-3338` (p.75); O5's mode changes O3's working range form, direction not settled, `insag-7-paged.txt:3702-3724` (p.83) [corrected, V3] |
| Each observer checks one, reports to a different one | no | Reports end at the actuator, a recorder or a B2 position; no observer validates another's report |
| One +1 that checks all observers including itself | no | Nothing checks whether the EPS can act; the ORM had no instrument, alarm or trip, `insag-7-paged.txt:1921-1925` (p.48), `:3650-3658` (p.82), `:4144-4148` (p.92) |
| Nested rings, where the structure needs them | N/A | no base ring forms |

**Shape: isolated spokes converging on one actuator, with passive hubs.** Each protection is
a spoke from a sensor to the 211 rods; the effect of every spoke depends on the ORM and the
rod positions, which no spoke measures. The other sinks are recorders that nothing reads in
time, `insag-7-paged.txt:2652-2655` (p.62), `:2850` (p.66), and a board read by one person,
`insag-7-paged.txt:3723-3731` (p.83). The Commission's words for the shape: "certain
protection functions were shifted from engineered features to the personnel",
`insag-7-paged.txt:2521-2522` (p.60, in a sentence whose "may have affected" governs the effect
of unclear limits, V35), and "many functions of the EPS (including its function when the ORM
reaches a critical value) were transferred to the personnel", `insag-7-paged.txt:4160-4163`
(p.92, "It is evident that").

### Coordinators and super-rings

| Candidate | Can stop what | Checks every observer | Takes reports back | Surface check | In the ring | Result |
|---|---|:-:|:-:|:-:|:-:|---|
| O2 power protection, `insag-7-paged.txt:3382-3384` (p.76) | the chain reaction, through the rods | no | no | yes | no ring | fails |
| O3 rate protection, `insag-7-paged.txt:3721-3724` (p.83) | the chain reaction | no | no | yes | no | fails; its working range form changes state with the regulators' mode, direction not settled [corrected, V3] |
| O9 two-turbine trip, `insag-7-paged.txt:3863-3873` (p.86) | the chain reaction | no | no | yes | no | fails; disabled by procedure at the time |
| O7 drum level EPS-5, `insag-7-paged.txt:3790-3800` (p.85) | the chain reaction | no | no | yes | no | fails; the -600 mm set point present only by a person's selection |
| O11 reactor space pressure, `insag-7-paged.txt:2815-2816` (p.65) | the chain reaction | no | no | yes | no | fails; fires after the rupture it should prevent |
| O20 loss of RCPS bus voltage, `insag-7-paged.txt:2085` (p.51, quoted NSR) | the chain reaction, if implemented (U3, U4) | no | no | yes | no | fails; implementation unconfirmed |
| O4 LEP, `insag-7-paged.txt:5154-5156` (p.113) | local assembly power (action unstated, U6) | no | no | yes | no | fails; off below 10% power |
| O21 EPS-1 to EPS-3, `insag-7-paged.txt:2274-2281` (p.55) | reduces power, does not stop | no | no | yes | no | fails |
| O8 drum pressure, `insag-7-paged.txt:3842-3845` (p.86) | the turbine | no | no | yes | no | fails |
| O10 ECCS, `insag-7-paged.txt:3514-3517` (p.79) | injects water; stops nothing | no | no | yes | no | fails; sensors outside the failed volume; isolated |
| O19 SKALA / PRIZMA, `insag-7-paged.txt:552-562` (p.16) | nothing: a printout | no | no: takes inputs, returns no validation | yes | no | fails; a collection hub with a human sink |
| BC1 EPS-5 button, `insag-7-paged.txt:3357-3358` (p.76) | the chain reaction, by a person's hand | no | no | not a check | B2 | fails by the bar |
| The senior reactor control engineer and the shift (BC13, BC14) | the unit, by order | reads lamps and a printout, `insag-7-paged.txt:3650-3658` (p.82) | returns none to the instruments | n/a | B2 | fails by the bar |
| Chief Engineer, Scientific Manager, Chief Design Engineer, regulator (BC13, BC15) | operation, by authorization | no | takes documents | n/a | B2 | fails by the bar; "No list of violations", `insag-7-paged.txt:1737-1741` (p.44) |

No candidate passes. No coordinator exists; no super-ring forms; the structure does not close
at any layer.

---

## The structure against the model, property by property

### Groups

| Group | Observers | Watches | Ends in |
|---|---|---|---|
| GR1 Reactor emergency protection | O1, O2, O3, O20, O21 | total power and its rate through SP1; main equipment failures; the rod drives' supply | the 211 rods; DREG |
| GR2 Power regulation and distribution control | O4, O5, O6, O16 | power against a set point; the fields through SP2; the regulator rods' freedom to move | regulator rods; lamps; DREG; a recorder |
| GR3 Steam drum and turbine protections | O7, O8, O9 | drum level, drum pressure, both turbines' stop valves | the rods (O7, O9); the turbine (O8) |
| GR4 Coolant circuit and fuel channel monitoring | O12, O13, O14, O15 | circuit pressure; fission products; gas humidity and temperature; channel flow | relief valves; the computer |
| GR5 Emergency core cooling | O10 | depressurization in the leaktight compartments | ECCS pumps and valves |
| GR6 Reactor space overpressure protection | O11 | reactor space pressure | the rods |
| GR7 Centralized control computer | O19 | the ORM, computed | printouts; signals to the operators |

GR8 (O17, O18) is not scored: the document names the two systems and nothing else, so their
role is unconfirmed (U7). Removed (V4).

### Scorecard

Codes: **G** gap confirmed at the lines; **S** satisfied at the lines; **U** not settled by
the document, with the item that would settle it. Every group is Catastrophic; no cell is
N/A.

| Group | 1 HB | 2 Sub | 3 CSV | 4 SWR | 5 SD | 6 Death | 7 AutoInt | 8 Reflex |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| GR1 | G | G | G | G | G | G | G | G |
| GR2 | G | G | G | G | G | G | G | G |
| GR3 | G | S | G | G | G | G | G | G |
| GR4 | G | S | G | G | G | G | U22 | G |
| GR5 | G | G | G | G | G | G | G | G |
| GR6 | G | S | G | G | G | G | G | G |
| GR7 | G | G | G | G | G | G | G | G |

**Totals:** 56 cells: 52 G, 3 S, 1 U, 0 N/A. GR8's eight cells are not scored (V4), and
GR4's property 7 is not settled by the document (V5).

### Evidence per verdict

**Shared, properties 4, 5 and 6 (every group).** No cycle of three, no check-and-report
separation, no coordinator (the architectural model). Every automatic halt ends in the rods and the DREG
record and reaches no other observer, `insag-7-paged.txt:2785-2787` (p.65, Table I-I),
`:2834-2846` (p.66). Self-defense has a direct confirmation: "a ready capability for the
operators manually to disable certain safety systems, bypass automatic scram trips, and
reset or suppress various alarm signals. This could be done ordinarily by connecting jumper
wires to accessible terminals. The operating procedures permitted such disabling under some
circumstances", `insag-7-paged.txt:585-589` (p.16, INSAG). What INSAG was told after the
accident points the same way: a measure "Precluding the possibility of bypassing the
emergency protection system while the reactor is at power", with "a two key system",
`insag-7-paged.txt:1389-1392` (p.37). Death signaling: when an observer went off, nothing
acted: PRIZMA "unreliable" with no prescribed action, `insag-7-paged.txt:3616-3623` (p.81);
DREG interrupted three times, `insag-7-paged.txt:2844-2846` (p.66); "no in-core
instrumentation available", `insag-7-paged.txt:527-528` (p.15); the ECCS out for about 11
hours, `insag-7-paged.txt:738-743` (p.20). Annex II names the shape: "insufficient automatic
engineered protection of the reactor to prevent its being put into an unauthorized regime",
`insag-7-paged.txt:5295-5296` (p.117).

**GR1.**
- 1 G. No liveness signal of the EPS gated the chain reaction. The quoted [19] makes full
  shutdown by "dropping all the RCPS rods" the response to "total loss of power to the
  plant", `insag-7-paged.txt:2278-2281` (p.55); the regulation required a trip on "failure of
  the voltage supply to the RCPS bus bars" and on failure "of any two of the three channels",
  `insag-7-paged.txt:2085-2088` (p.51, quoted NSR-04-74 Article 3.3.26); whether Unit 4 had
  either is not stated (U3, U4).
- 2 G. The power and rate protections read lateral chambers "all located at the mid-plane of
  the core", which "could not indicate the average axial distribution of flux",
  `insag-7-paged.txt:530-533` (p.15, INSAG); after EPS-5 "practically all of the power density
  shifted to the lower part of the core at a height of about 2 m",
  `insag-7-paged.txt:3384-3386` (p.76, calculations [21], [35]); the chamber signals appear
  "only 3 s after pressing of the EPS-5 button", `insag-7-paged.txt:3395-3397` (p.77,
  calculations [17], [20]).
- 3 G. "The list of emergency signals was incomplete and did not ensure that the reactor
  protection system would be triggered when certain parameters reached dangerous levels (for
  example, the parameters related to the operational reactivity margin, low power level, and
  so on)", `insag-7-paged.txt:2097-2101` (p.52); no provision for the ORM to "trigger the
  alarm system or the EPS", `insag-7-paged.txt:1921-1925` (p.48); DREG records nine of 211 rod
  positions, `insag-7-paged.txt:2838-2840` (p.66).
- 7 G. "As the fuel burnt out, the designers allowed these absorbers to be removed",
  `insag-7-paged.txt:911-913` (p.24, INSAG); "There is no safety analysis of the void
  coefficient of reactivity in the RBMK-1000 design documentation",
  `insag-7-paged.txt:1866-1867` (p.47); the EPS was designed for three reactivity effects,
  `insag-7-paged.txt:1954-1960` (p.49, citing [19]). The core held "one additional absorber",
  `insag-7-paged.txt:5307-5308` (p.117).
- 8 G. The quoted [19]: the system "does not make it possible to reduce the power abruptly",
  `insag-7-paged.txt:2274-2276` (p.55); full insertion 18 s or 18-21 s (DG16); the first
  motion from the upper stops inserts positive reactivity locally,
  `insag-7-paged.txt:477-480` (p.14, INSAG), with Annex II's "could induce a negative
  reactivity insertion during the first second and then a reactivity rise",
  `insag-7-paged.txt:5486-5489` (p.120) (DG23); "the integral reactor power increased ...
  several tens of times during a period of about 5 s", `insag-7-paged.txt:3392-3395` (p.77,
  calculations), where Annex II's three models give 3.5 to about 80 times,
  `insag-7-paged.txt:5997-6000` (p.131).

**GR2.**
- 1 G [corrected, V3]. When the regulators left automatic regime, power fell under
  poisoning and the engineer took over by hand, `insag-7-paged.txt:3721-3739` (p.83, the
  Commission's presumption); the local regulator was switched off "For some unknown reason
  (possibly owing to a perturbation associated with the MFCC ...)", `insag-7-paged.txt:3711-3715`
  (p.83). Nothing halted on either loss. The absence of LAC-LAP and PPDDCS below 10% power
  gated nothing, `insag-7-paged.txt:524-528` (p.15). The rate protection's state change is
  not part of this verdict (U24).
- 2 G. The systems that read the in-core detectors "operated at power levels above 10% of
  nominal" and were "switched off", `insag-7-paged.txt:524-528` (p.15); the regulators ran on
  the lateral chambers at the mid-plane, `insag-7-paged.txt:2007-2013` (p.50).
- 3 G [corrected, V19]. The set point is a person's: "the senior reactor control engineer
  probably reduced the set points ... using the 'fast power reduction button'", then
  restored power "by manipulating the set points", `insag-7-paged.txt:3732-3739` (p.83,
  presumption). At low power "a reactor operator had to rely mainly on experience and
  intuition", `insag-7-paged.txt:535-537` (p.15); "no calculations or experimental data" on
  the void coefficient below 50% power, `insag-7-paged.txt:1829-1832` (p.46).
- 7 G. Regulator No. 2 "did not come into automatic mode owing to an unacceptable imbalance",
  `insag-7-paged.txt:3717-3719` (p.83, presumption); nothing brought a regulator into
  observation when another left it.
- 8 G. The 'One overcompensation upwards' signal was on while "the automatic control rods
  could not move into the core", recorded by DREG and acted on by nothing,
  `insag-7-paged.txt:3332-3338` (p.75); LEP's action is unstated (U6) and it was off below 10%.

**GR3.**
- 1 G. The two-turbine trip disabled, `insag-7-paged.txt:3866-3871` (p.86); the level set
  point left at -1100 mm with "no notes on this in the operating logs",
  `insag-7-paged.txt:3790-3795` (p.85); the pressure set point changed, `:3828-3833` (p.85).
  No absence triggered a response.
- 2 S [narrowed, V41]. Each member sits on what it watches: the level instrument on the drum,
  `insag-7-paged.txt:3810-3812` (p.85, quoted [43]); the pressure protection on drum pressure,
  `insag-7-paged.txt:3842-3845` (p.86); the two-turbine protection on "the closure of the
  emergency stop valves of both turbines", `insag-7-paged.txt:3871-3873` (p.86).
- 3 G. The known-good is a person's selection: "Automatic reswitching of the set points of
  EPS-1 and EPS-5 ... is not permitted"; the operator "should reswitch them manually using the
  general key when alarm signals appear", `insag-7-paged.txt:3807-3817` (p.85, quoted [43]);
  [42] §12 "entitled" personnel to select the pressure set point, `insag-7-paged.txt:3830-3833`
  (p.85).
- 7 G. The two-turbine protection was to be disabled "in the event of a turbogenerator load
  of less than 100 MW(e)", `insag-7-paged.txt:3869-3871` (p.86), so it left observation
  whenever the plant entered that state; the level reswitch is manual by design.
- 8 G. O9 disabled, and O7 held at its -1100 mm set point, a protection that "existed and was brought into operation", `insag-7-paged.txt:3798-3799` (p.85); O8 acts on the turbine, leaving the reactor
  "without any protection system to guard against pressure reduction" below 100 MW(e),
  `insag-7-paged.txt:3846-3848` (p.86).

**GR4.**
- 1 G. O13 to O15 report to the computer, whose restarts stopped recording with no response,
  `insag-7-paged.txt:2844-2846` (p.66); nothing is stated to act on the loss of any reading.
- 2 S [narrowed, V6]. Placement: per-channel ball meters, a detector on each steam-water
  line, the gas through the channels, relief valves on the circuit,
  `insag-7-paged.txt:5180-5194` (p.114-115), `:5273` (p.116). Annex II's description of the
  design, not observation on 26 April.
- 3 G. The leak monitor samples "sequentially", a detector "moved by a special dolly from one
  line to the next", `insag-7-paged.txt:5183-5188` (p.114); the MCP flow limit was procedural,
  and "the flow rates of certain MCPs actually exceeded the limit" with no trip,
  `insag-7-paged.txt:3919-3923` (p.87).
- 7 U22 [corrected, V5]. The seventh and eighth MCPs entered the DREG printout,
  `insag-7-paged.txt:3921-3924` (p.87); DREG is a signal-path device. Not settled: whether any
  GR4 observer took the new pumps into observation. The MCP flow instrument behind Table
  I-I's per-pump readings, `insag-7-paged.txt:2793-2808` (p.65), is not in the inventory;
  DREG does not record "channel coolant flow rates", `insag-7-paged.txt:2837-2838` (p.66).
- 8 G. O13 to O15 end in "signals indicating divergences" to the operators,
  `insag-7-paged.txt:5196-5198` (p.115); the relief and dump valves act on pressure and
  propagate to nothing, `insag-7-paged.txt:2812-2813` (p.65).

**GR5.**
- 1 G. Isolated at 14:00 on 25 April; the reactor "was being operated at half power for the
  period of approximately 11 hours ... with the ECCS blocked out", `insag-7-paged.txt:738-739`
  (p.20); no interlock stated (U10).
- 2 G. "no DBA signal ... was given because the point at which the MFCC ruptured was not in
  the reinforced leaktight compartments where the sensors are placed, but in the core
  itself", `insag-7-paged.txt:3514-3517` (p.79, the scenario, "no longer based on
  calculations", `:3457-3458`, p.78).
- 3 G. §2.10.5 required, during heating of the MFCC after a scheduled outage "when the temperatures exceed 100°C", that "the ECCS must be brought to a state of readiness",
  `insag-7-paged.txt:3676-3679` (p.82, quoted); no device checked readiness (DG7 on whether the
  isolation was permitted).
- 7 G. The 1984, 1985 and 1986 programmes "provided for disconnection of the ECCS by manual
  isolating slide valves", `insag-7-paged.txt:2597-2598` (p.61); the test's DBA button injected
  a DBA signal beside the ECCS, `insag-7-paged.txt:2885-2888` (p.67).
- 8 G. "no signals for the automatic switching on of the ECCS were recorded",
  `insag-7-paged.txt:3685-3687` (p.82); the design's injection on total loss of power rests on
  the rundown the test was to prove, `insag-7-paged.txt:2578-2582` (p.61).

**GR6.**
- 1 G. Nothing signals the protection's own state; removal not stated (U16).
- 2 S [narrowed, V32]. The signal 'Pressure increase in reactor space (rupture of a fuel
  channel)', `insag-7-paged.txt:2815-2816` (p.65, Table I-I), and the DREG data on "the
  pressure increase in the reactor space 3, 6 and 9 s after pressing of the EPS-5 button",
  `insag-7-paged.txt:2955-2959` (p.68). Location inferred from the signal's name.
- 3 G. "The design did not provide the reactor space with a protection system against
  multiple ruptures of the fuel channels", `insag-7-paged.txt:2119-2120` (p.52).
- 7 G. The relief "is designed to cope with the steam discharge from a simultaneous rupture of
  two channels", `insag-7-paged.txt:6284-6286` (p.138, Annex II); more "was disregarded",
  `insag-7-paged.txt:2357-2360` (p.57).
- 8 G. The signal reaches rods "only half-way down" and jammed, `insag-7-paged.txt:3504-3507`
  (p.79, scenario).

**GR7.**
- 1 G. "No operating calculations were performed by the PRIZMA program at this time"
  (01:22:30); "The control room personnel and the SKALA system personnel did not have the
  operating calculation results", `insag-7-paged.txt:3251-3257` (p.74); three DREG
  interruptions "associated with restarting of the SKALA system", `insag-7-paged.txt:2844-2846`
  (p.66).
- 2 G. "approximately 50 m from the control console", `insag-7-paged.txt:552-553` (p.16); the
  code "did not take into account the position of the rods of automatic regulators Nos 1, 2
  and 3 (a total of 12 rods)", `insag-7-paged.txt:3616-3619` (p.81).
- 3 G [corrected, V12]. Cycle "about 10-15 min" (INSAG, `insag-7-paged.txt:558-559`, p.16), 5
  min for SKALA's parameters and PRIZMA (Annex I, `insag-7-paged.txt:2830-2831`, `:2847-2848`,
  p.66; Annex II, `insag-7-paged.txt:5735-5736`, p.125), and "every 15 min as was the case
  before the accident" for the ORM (Annex I, `insag-7-paged.txt:2490-2491`, p.59) (DG25); no
  limit compared, `insag-7-paged.txt:1921-1925` (p.48); "designed to provide guidance to the
  operator", `insag-7-paged.txt:559-560` (p.16); results "recorded only on printouts",
  `insag-7-paged.txt:2850` (p.66).
- 7 G. Twelve regulator rods never entered the computation, `insag-7-paged.txt:3616-3619`
  (p.81); the test oscilloscope was not synchronized with SKALA, `insag-7-paged.txt:2859-2861`
  (p.66).
- 8 G. Output is a printout; the procedures "did not prescribe the actions to be taken by
  personnel" on an unreliable or failed calculation, `insag-7-paged.txt:3620-3623` (p.81).

---

## Missing structural components

### Per subsystem

| Subsystem | Cycle | Coordinator | Check and report separation | Halt path with propagation | Upward chain |
|---|---|---|---|---|---|
| Core and RCPS (O1 to O6, O16, O21) | absent | absent: nothing checks the EPS's ability to act | absent | a halt to one actuator; propagation to the rods and DREG only, `insag-7-paged.txt:2785-2787` (p.65) | absent: the ORM reached a printout, `insag-7-paged.txt:2850` (p.66) |
| Main coolant circuit and MCPs (O12, O15) | absent | absent | absent | absent: the MCP limits were procedural, `insag-7-paged.txt:3919-3923` (p.87); a ban on operating four MCPs below 700 MW(th) came only after the accident, "this confirms that there was no such ban before", `insag-7-paged.txt:2493-2496` (p.59) | absent |
| Steam drums and turbine protections (O7, O8, O9) | absent | absent | absent | one actuator each; two of three disabled or left at a set point by procedure | absent |
| ECCS (O10) | absent | absent | absent | absent on 26 April, `insag-7-paged.txt:3685-3687` (p.82) | absent |
| Accident localization (O11, OC9, OC10) | absent | absent | absent | a relief path sized for two ruptures, `insag-7-paged.txt:697-703` (p.19) | absent |
| SKALA, PRIZMA, DREG (O19, SP3, SP4) | absent | absent | absent: reports to paper | absent, `insag-7-paged.txt:3616-3623` (p.81), `:3251-3257` (p.74) | absent |

### Hazards and their observers

| Component | Hazardous state, in the source's words | Evidence | Observer against known-good |
|---|---|---|---|
| OC3 the ORM | "When the ORM falls to 15 rods, the reactor should be shut down immediately" (quoted §9); at about 15 rods "less than" beta-effective of negative reactivity in six seconds, at "a non-regulation ORM of 7 control rods" positive for eight (research [20]) | `insag-7-paged.txt:4020-4021` (p.89), `:1976-1984` (p.49) | none: "no provisions for the ORM to be treated as a parameter which would trigger the alarm system or the EPS", `insag-7-paged.txt:1921-1925` (p.48); "no provision in the design ... for a device to measure the ORM in terms of effective manual control rods", `insag-7-paged.txt:3650-3651` (p.82). A missing observer |
| OC3 as computed | PRIZMA "unreliable" (12 rods omitted); no calculation at 01:22:30 | `insag-7-paged.txt:3616-3623` (p.81), `:3251-3257` (p.74) | none |
| OC1 coefficients | "At the time of the accident, the void and power coefficients of reactivity were both positive" (INSAG); no data below 50% power (Annex I) | `insag-7-paged.txt:455-456` (p.13), `:1829-1832` (p.46) | none |
| OC1 power level | operation "below 700 MW(th) was not proscribed, either in design, in regulatory limitations or in operating instructions" (INSAG); "no safe operating limits in terms of minimum permissible thermal reactor power" (Annex I) | `insag-7-paged.txt:754-756` (p.21), `:3886-3887` (p.87) | none; the signal list lacked "low power level", `insag-7-paged.txt:2097-2101` (p.52) |
| OC1 distribution | "a double peaked axial power density distribution over most of the core" (Annex I); the halves "proceeding almost independently" (INSAG) | `insag-7-paged.txt:3262-3263` (p.74), `:572-575` (p.16) | O4, O16 above 10% power only; off at the time, `insag-7-paged.txt:527-528` (p.15) |
| OC1 subcooling | "a low level of subcooling of the coolant below the boiling temperature", 3 degrees C (Annex I; V28); INSAG: "little or no" subcooling (the source spells it "subccoling", V28) | `insag-7-paged.txt:3270-3273` (p.74), `:1131-1132` (p.29) | none stated; inlet temperatures a table value, `insag-7-paged.txt:5653-5654` (p.123) |
| OC2 the rods | "more than the permitted number of water columns in the lower parts of the core" (Annex I scenario); "almost all the rods to extreme positions" (INSAG) | `insag-7-paged.txt:3474-3476` (p.78), `:1013-1014` (p.27) | none: nine of 211 positions recorded, `insag-7-paged.txt:2838-2840` (p.66); restrictions "never imposed", `insag-7-paged.txt:938-939` (p.25) |
| OC4 MFCC and MCPs | "the flow rates of certain MCPs actually exceeded the limit" | `insag-7-paged.txt:3921-3923` (p.87) | O15 to the computer; no trip; cavitation margin at 01:23:00 "higher than that at which a disruption in circulation ... could take place", `insag-7-paged.txt:3046-3048` (p.70, citing [31]) |
| OC4 leak | by [28], "given the initial state of the reactor just before the tests", a leak over 300 mm "could have resulted in an accident which would have been just as serious" | `insag-7-paged.txt:3155-3160` (p.72) | O10, only inside the leaktight compartments, `insag-7-paged.txt:3514-3517` (p.79, scenario) |
| OC5 level | fell below -600 mm "without triggering the EPS-5 signal" | `insag-7-paged.txt:3791-3792` (p.85) | O7 at -1100 mm; the -600 mm set point present only by a person's selection; both bodies find the state did not affect the accident (V7) |
| OC5 pressure | "the reactor was left without any protection system to guard against pressure reduction" | `insag-7-paged.txt:3846-3848` (p.86) | none for the reactor |
| OC6 feedwater | the quoted [33]: an operator "reduced the feedwater flow rate"; the Commission: "brought back to the average value" (DG12) | `insag-7-paged.txt:3089-3093` (p.71) | none; manual level control, `insag-7-paged.txt:3247-3249` (p.74) |
| OC7 turbogenerators | both off the grid with the two-turbine trip disabled | `insag-7-paged.txt:3863-3871` (p.86) | O9, disabled by procedure |
| OC8, OC9 channels and reactor space | "A rupture of more than one of the fuel channels could, therefore, cause lifting of the reactor cover plate" | `insag-7-paged.txt:2120-2122` (p.52) | O11 after the fact; relief limited to two ruptures, `insag-7-paged.txt:699-703` (p.19) |
| OC10 localization | part of the circuit outside leaktight buildings, vented to the atmosphere by design | `insag-7-paged.txt:2343-2351` (p.56-57) | none: a passive barrier |
| OC11 supply | the quoted [19]: full shutdown "only for total loss of power to the plant" | `insag-7-paged.txt:2278-2281` (p.55) | O20 records the 48 V loss; action unconfirmed (U4) |
| OC12 SKALA hardware | "three interruptions in the operation of the DREG program, associated with restarting of the SKALA system" | `insag-7-paged.txt:2844-2846` (p.66) | none |
| OC13 gas circuit | replacement with nitrogen from 03:45 (Table I-I) | `insag-7-paged.txt:2669-2670` (p.63) | O14, relation not stated (U13) |
| OC14 upper limit stops | the displacer "sat centrally within the fuelled region of the core with 1.25 m of water at either end" | `insag-7-paged.txt:475-477` (p.14), `:487` (p.14) | none: nothing counted rods at the upper stops |

### Prescribed responses tested as actuators [corrected, V8]

Each is tested as a halt path: can the prescribed response itself be the fault in the state
where it is prescribed? The answer carries the confidence of its line.

- **PR1** §9, "When the ORM falls to 15 rods, the reactor should be shut down immediately",
  `insag-7-paged.txt:4020-4021` (p.89, quoted). At that ORM the EPS gives "less than"
  beta-effective of negative reactivity in six seconds, `insag-7-paged.txt:1976-1982` (p.49,
  research [20]); "it would appear" the EPS could not be used from 00:30 "without damaging
  the core. This will have to be confirmed by further studies", `insag-7-paged.txt:3305-3309`
  (p.75). **Yes, on a hedged finding.** The Commission's surrounding sentence: the designers
  "were evidently not sufficiently aware of this fact before the accident, otherwise it is
  difficult to believe that they could have expected" to ensure safety by "organizational
  measures such as prohibiting reactor operation at low ORMs", `insag-7-paged.txt:1984-1988`
  (p.49) [corrected, V23].
- **PR2** §6.6.4, if while "the reactor is being brought to criticality the operational reactivity margin falls to 15 rods and continues to fall", "all rods must be dropped to the lower limit stop switches",
  `insag-7-paged.txt:4063-4065` (p.90, quoted). The same actuator from the same positions:
  **yes, on the same hedged finding.**
- **PR3** §12, a planned reduction "using the set point adjusters ... to 160 MW(th) ... and
  then the automatic power control system or the EPS-5 button",
  `insag-7-paged.txt:3636-3639` (p.81, quoted), with no ORM requirement, `:3632-3634` (p.81). Annex
  I's finding that the initiating event was EPS-5 "at low power with a greater than
  permissible number of manual control rods withdrawn", `insag-7-paged.txt:3444-3447` (p.78),
  is firm; its application to §12 is an inference, since why the button was pressed "has not
  yet been established for certain", `insag-7-paged.txt:4185-4187` (p.93). **Yes where the
  ORM is low, by inference from a firm finding.**
- **PR4** §11.4, hold at 200-300 MW(th) after EPS-3 with "no limitation on the period",
  `insag-7-paged.txt:3890-3896` (p.87). The Commission's Note: conditions like those of 26
  April "might have occurred without any intervention on the part of the personnel"; "any
  further action, whether automatic or remote, to shut down the reactor could have led to a
  similar repetition", `insag-7-paged.txt:3897-3907` (p.87). **Possible, on the Commission's
  hypothetical** [corrected, V24].
- **PR5** §6.7, restoration to rated power after a reduction not below the minimum
  controllable level, `insag-7-paged.txt:3754-3757` (p.84). "The authors of this report
  believe that the drop in reactor power at 00:28 and subsequent power increase were largely
  to blame", `insag-7-paged.txt:3769-3771` (p.84), and "It is impossible to draw a final
  conclusion", `insag-7-paged.txt:3777-3780` (p.84). **Yes, as the authors' belief, with the
  Commission's own caveat.**
- **PR6** [42] §1, disable the two-turbine EPS-5 below 100 MW(e), `insag-7-paged.txt:3866-3871`
  (p.86). INSAG: the trip's occurrence "might well have caused the destruction of the reactor
  at the time of turbine trip rather than shortly afterwards", `insag-7-paged.txt:1082-1084`
  (p.28). **The protection and its prescribed disabling both end at the same actuator; the
  protection's firing as a fault is INSAG's "might well".**
- **PR7** [42] §9 and [43], reswitch the level set point "manually using the general key",
  `insag-7-paged.txt:3795-3797`, `:3814-3817` (p.85). That a made reswitch would have
  commanded EPS-5 from the low-ORM positions is an inference resting on Table II-III's
  unconfirmed times, `insag-7-paged.txt:5620-5625` (p.122); both bodies find the level
  setting did not affect the accident, `insag-7-paged.txt:1076-1078` (p.28),
  `:3975-3977` (p.88). **Not shown to be the fault; an inference against both bodies'
  findings** [corrected, V7].
- **PR8** §5.8, MCP flow limited to 6500-7000 m3/h below 500 t/h feedwater,
  `insag-7-paged.txt:3919-3921` (p.87). The exceedance "did not cause cavitation",
  `:3921-3924` (p.87). **Not shown to be a fault.**
- **PR9** [42] §12, personnel "entitled to select" the pressure set point,
  `insag-7-paged.txt:3830-3833` (p.85). Below 100 MW(e) no reactor protection against pressure
  reduction; "it might have resulted in a reactor runaway even at the regulatory ORM",
  `insag-7-paged.txt:3846-3851` (p.86). **Yes, on the Commission's "might".**
- **PR10** [42] §2 and programme §2.15, the ECCS switched off, `insag-7-paged.txt:3673-3683`
  (p.82). Both bodies: it did not affect this accident, `insag-7-paged.txt:3685-3687` (p.82),
  `:736-737` (p.20). **Removes an observer; not the fault on 26 April by both bodies.**
- **PR11** programme §2.12, the seventh and eighth MCPs, `insag-7-paged.txt:3914-3916` (p.87).
  INSAG lists pump disturbance as a pitfall that "could have led to sudden augmentation",
  `insag-7-paged.txt:876-879` (p.24); Annex I, "It would appear" the eight pumps "if anything
  hindered the reactor runaway ... Additional theoretical analysis in this area is required",
  `insag-7-paged.txt:3969-3973` (p.88) (DG13). **Unresolved between bodies.**
- **PR12** the Chief Design Engineer's recommendation of 150 fully withdrawn rods,
  `insag-7-paged.txt:2229-2234` (p.54). Annex I: it "permitted a positioning of the RCPS rods
  whereby the breeding characteristics in the lower part of the core ... would increase", and
  would have allowed "an ORM of 3-5 manual control rods", `insag-7-paged.txt:2236-2242`
  (p.54). **Yes, by the Commission's firm finding; never in force** (T17 dropped, V10).
- **PR13** the test power changed from 700 to 200 MW(th), `insag-7-paged.txt:1096`, `:1113-1115`
  (p.29). "the accident might not have happened. However, this theory needs to be tested",
  `insag-7-paged.txt:4000-4002` (p.89). **Open.**
- **PR14** clearance of the test: Annex II's Operating Procedures requirement,
  `insag-7-paged.txt:5557-5568` (p.121), against Annex I's regulations that "did not require"
  approval, `insag-7-paged.txt:2609-2611` (p.62) (DG14); whether it was sought is U5.
- **PR15** NSR-04-74 Article 3.1.6, violations to be listed and authorized,
  `insag-7-paged.txt:1719-1725` (p.44, quoted); "No list of violations ... was given",
  `insag-7-paged.txt:1737-1740` (p.44). **Not performed; nothing observed that it was not.**

Of fifteen, the document states the response as the fault firmly for PR12 and, by inference
from a firm finding, PR3; on hedged findings for PR1, PR2 and PR9; as a hypothetical for
PR4; as INSAG's "might well" for PR6; as a belief with a caveat for PR5. PR7 and PR8 are not
shown to be the fault; PR10 removes an observer and was not the fault on 26 April by both
bodies; PR11 is disputed; PR13 is open; PR14 is a disagreement between bodies (DG14); PR15
was not performed.

### Removal paths

B2 paths to an observer's absence: **RP1** jumper wires, `insag-7-paged.txt:585-589` (p.16),
which trips unlisted (U16); **RP2** the general key on the level set point,
`insag-7-paged.txt:3814-3817` (p.85); **RP3** [42] §1 on the two-turbine trip,
`insag-7-paged.txt:3866-3871` (p.86); **RP4** [42] §12 on the pressure set point,
`insag-7-paged.txt:3830-3833` (p.85); **RP5** the ECCS slide valves and [42] §2,
`insag-7-paged.txt:3673-3683` (p.82); **RP6** LAC-LAP and PPDDCS off at low power,
`insag-7-paged.txt:527-528` (p.15); **RP7** an EPS rod converted to a manual rod,
`insag-7-paged.txt:2055-2057` (p.51); **RP8** the clutch power switch, off at 01:24,
`insag-7-paged.txt:2822-2823` (p.65, log note), effect not settled (U4). RP9 is dropped: the
document does not show the regulators' mode removing the rate protection (U24, V3).

### Execution-observation coupling

Absent. The chain reaction ran whatever the state of its observers: PRIZMA unreliable and
then not run, `insag-7-paged.txt:3616-3623` (p.81), `:3251-3253` (p.74); DREG interrupted,
`insag-7-paged.txt:2844-2846` (p.66); no in-core instrumentation, `insag-7-paged.txt:527-528`
(p.15); the ECCS isolated, `insag-7-paged.txt:738-743` (p.20); the two-turbine trip blocked and
the pressure set point reset, `insag-7-paged.txt:3828-3871` (p.85-86). The only halt the
quoted design ties to a loss is full shutdown on "total loss of power to the plant",
`insag-7-paged.txt:2278-2280` (p.55, quoted [19]); whether the test produced that condition is
U23, and whether the 48 V loss at 01:23:49 was a trip or a consequence is U4. Observation
gated nothing; the default was running.

---

## The present halt paths

Every automatic reactor halt ends in the 211 rods at 0.4 m/s, whose effect depends on the
ORM and the rod positions, which no halt path measures. None propagates to another observer.

- **H1** [corrected, V27] Power protection → rods. Annex I's running text: DREG recorded "the
  signals of the power increase rate protection and power protection systems",
  `insag-7-paged.txt:2955-2959` (p.68); Annex II gives the signals "three seconds after EPS-5
  is triggered" inside its sentence that "none of the three models reproduces the reactor
  runaway when" they are generated, `insag-7-paged.txt:6005-6008` (p.131); the personnel "did
  not deactivate" it, `insag-7-paged.txt:3977-3979` (p.88). Set point value table only (U2).
  Propagates to the rods and DREG.
- **H2** [corrected, V3] Rate protection → rods. The signal confirmed, same lines; the
  working range form's state at 00:28 not settled (U24). Propagates to the rods, DREG, a lamp.
- **H3** Two-turbine stop valves → EPS-5, `insag-7-paged.txt:3863-3873` (p.86). Disabled at
  the time (RP3); signal kind U14, time DG2. Propagates to the rods.
- **H4** [corrected, V7] Drum level → EPS-5 at -600 mm or EPS-1 at -1100 mm,
  `insag-7-paged.txt:3790-3800` (p.85). Only -1100 mm in force; both bodies say it remained
  in operation and that the level setting did not affect the accident; whether EPS-1 fired is
  U19. Propagates to the rods.
- **H5** Reactor space pressure → EPS signal, `insag-7-paged.txt:2815-2816` (p.65),
  `:2955-2959` (p.68); relief by the passive pipes, `insag-7-paged.txt:697-703` (p.19). The
  rods were jammed, in the scenario, by the same pressure increase, `insag-7-paged.txt:3504-3507` (p.79). Propagates
  to the rods.
- **H6** Drum pressure → turbine stop, `insag-7-paged.txt:3842-3845` (p.86). Not the reactor.
- **H7** DBA signal → ECCS, `insag-7-paged.txt:3673-3687` (p.82), `:3514-3517` (p.79).
  Isolated; no signal arose. Propagates to the ECCS pumps.
- **H8** [corrected, V9] Loss of plant power → "complete reactor shutdown by dropping all the
  RCPS rods", `insag-7-paged.txt:2278-2280` (p.55, quotation of [19], not contained).
  Implementation not shown; not the only full halt (DG24); whether the test produced its
  condition is U23; the 48 V event U4.
- **H9** EPS-5 button → EPS and manual rods, `insag-7-paged.txt:3357-3358` (p.76),
  `:2869-2870` (p.66, oscillogram); Table II-III's entry rests on "the explanatory notes written
  by personnel", `insag-7-paged.txt:5683-5685` (p.124). B2-initiated. Propagates to the rods,
  DREG, the teletape.
- **H10** LEP, `insag-7-paged.txt:5154-5156` (p.113). Action unstated (U6); off below 10%.

### Continue-on-fault paths

C1 PRIZMA unreliable, operation continues, `insag-7-paged.txt:3616-3623` (p.81). C2 SKALA
restarts, `insag-7-paged.txt:2844-2846` (p.66), `:5747-5750` (p.125). C3 [corrected, V3] all
regulators out of automatic regime, power falls under poisoning, the engineer takes over by
hand, `insag-7-paged.txt:3721-3739` (p.83, presumption); the rate protection's state is U24.
C4 LAC-LAP and PPDDCS off, control "relied solely on the ex-core detectors",
`insag-7-paged.txt:524-525` (p.15). C5 ORM at or below 15 rods with no alarm or trip, "from
07:00 until 13:30 on 25 April and from approximately 13:00 on 26 April until the time of the
accident" (DG6), `insag-7-paged.txt:3939-3941` (p.88). [added, A7] Table I-I, under "time in operating log", gives an ORM of 13.2 manual control rods at 07:10 and 16.8 at 15:20 on 25 April, `insag-7-paged.txt:2679`, `:2689` (p.63); Table II-III carries the same values with its time column offset, `insag-7-paged.txt:5594-5599` (p.122). The values are confirmed by two bodies' tables; the times rest on Table I-I and agree with the running text, 15 rods or less "from 07:00 until 13:30 on 25 April", `insag-7-paged.txt:3939-3940` (p.88). C6 power below 700 MW(th),
`insag-7-paged.txt:754-756` (p.21), `:3886-3896` (p.87). C7 [corrected, V9] the quoted [19]:
"Under all other accident conditions, the power is reduced in a controlled manner",
`insag-7-paged.txt:2280-2281` (p.55); against it, EPS-5's "complete shutdown of the reactor" on its
signals, `insag-7-paged.txt:3812-3813` (p.85, quoted [43]) (DG24). C8 the ECCS isolated with operation at half power about 11 hours,
`insag-7-paged.txt:738-743` (p.20). C9 [corrected, V7, V29] the level below -600 mm without
EPS-5, `insag-7-paged.txt:3790-3791` (p.85); the -1100 mm protection "remained effective
throughout the event", `insag-7-paged.txt:818-819` (p.22); six times are table values,
`insag-7-paged.txt:5620-5625` (p.122). C10 the two-turbine trip blocked,
`insag-7-paged.txt:3863-3871` (p.86). C11 the pressure set point changed, no reactor
protection below 100 MW(e), `insag-7-paged.txt:3828-3848` (p.85-86). C12 MCP flows above the
limit, `insag-7-paged.txt:3919-3923` (p.87). C13 'One overcompensation upwards' for 3 min 33
s, recorded, `insag-7-paged.txt:3332-3338` (p.75), the duration from Table I-I, `:2778-2779` (p.65), agreeing with the running text's interval. C14 the test changed on the spot,
`insag-7-paged.txt:1113-1115` (p.29). C15 rupture outside the sensed compartments, no DBA
signal, `insag-7-paged.txt:3514-3517` (p.79, scenario). C16 the 1983 positive scram finding,
"none of them were implemented before the accident", `insag-7-paged.txt:2194-2196` (p.54);
"Such restrictions were never imposed and apparently the matter was forgotten",
`insag-7-paged.txt:938-939` (p.25). C17 "Since officially there were no violations, no
technical and organizational measures were developed", `insag-7-paged.txt:1750-1752` (p.45).
C18 the Leningrad accident of 1975, operators "not informed of the real causes",
`insag-7-paged.txt:2417-2419` (p.58), `:1288-1291` (p.33). C19 the quoted [46]: the
Ministry of Power "did not take sufficient notice of the repeated unusual signals",
`insag-7-paged.txt:4244-4249` (p.94).

Nineteen continue-on-fault paths, C1 to C19. Each is scored in the STRIDE row that the
coverage list in Part A names for it, and each is a failed control under halt on
fault, not a mitigation.

---

## Keys

**Actors.** B1 is the observer ring, machine to machine; no person belongs in it, and no
row places one there. B2 is a privileged position: every person in this system (the
operating staff, the shift and plant management, the designers, the Scientific Manager,
the ministries, the regulator and the approving committees) and every document they wrote
that the console obeyed. B3 is an external party with no foothold; the document names
none, and the one sabotage scenario it reports, `insag-7-paged.txt:3138-3140` (p.72), was
among those a Kurchatov Institute study found to "contradict the objective data
available", `:3152-3153` (p.72). "No actor" marks a physical condition.

**Entry points.** Every row names the positions it needs, by number:

| # | Position |
|---|---|
| (1) | The senior reactor control engineer at the console |
| (2) | The shift and its supervisors |
| (3) | The Chief Engineer and plant management |
| (4) | The test programme's authors |
| (5) | The design organizations and their documents |
| (6) | The ministries |
| (7) | The regulator and the approving committees |
| (8) | A person at the jumper terminals, keys, straps and switches |
| (9) | The authors of the operating documentation: the Operating Procedures [40] and the Reswitching Procedures [42] |
| (10) | The SKALA system personnel |
| (11) | The reader of the records after the event |
| (12) | A physical condition with no actor behind it |

In a chain, each entry point is marked required, optional, or one cause (one of several
events any of which starts the chain). Part F maps every row and chain to its entries.

**Ids.** O observers, OC observed components, BC B2 controls, SP signal-path devices, H halt
paths, C continue-on-fault paths, RP removal paths (B2 paths to an observer's absence), PR
prescribed responses, U unsettled items, DG disagreements between the document's bodies, GR
scorecard groups; S, T, R, I, D and E for the STRIDE rows, M for the rows the chain hunt
found, X for chains.

**Evidence paths for a document.** Every citation is a backticked line range in
`insag-7-paged.txt`; a span holding only a line range continues the last path named in the
same paragraph, table row or list item. The PDF page in parentheses follows it, then the
body or section where it matters. Each citation is read as the kind of statement its lines
are: an INSAG finding (lines 351-1365), what INSAG was told (the Appendix), a finding,
belief or presumption of the SCSSINP Commission (Annex I), a finding of the Working Group
(Annex II), recorded data (the chronology tables, the DREG printout, the operating logs), a
calculation, Annex I's scenario presented as "no longer based on calculations", or a
quotation of a document the source quotes but does not contain, marked "quoted" with the
source's reference number. A quotation keeps every qualifier of its sentence. A time paired
with an event in Table I-I or Table II-III, which extract with their columns scrambled,
carries weight only where running text states it or another body confirms it. A time from
one chronology is not compared with a time from another without saying so. Where two bodies
disagree, both are cited under a DG id and neither is chosen; a typo, an impossible time or
a garbled value is left as the source has it, and a Greek symbol the extraction garbles is
named in words. A chain marked conditional on an unconfirmed item needs a statement the
document makes only as a hypothesis or a "might"; a chain marked design assumption needs a
state of the unit the document does not show existed.

**Halt on fault.** The required control for every row is one thing: an observer alerts and
the system halts until the fault clears or the privileged actor leaves. The last column of
each row says what happened instead. Continue-on-fault is a failed control, not a
mitigation. A protection a person could switch off is present only while it is on, and the
switch is a B2 path to its absence, whoever used it and whatever a procedure permitted.

**Marks.** "[corrected, ...]" and "[added, ...]" name the verification rulings behind a
change: V for the verification of the rows, W for the verification of the chains, K for the
chain verification's corrections reaching back into the rows, A for the additions it
confirmed. The rulings themselves are not reproduced. Corrections made after the
verification passes are applied in place without a mark.

---

## Part A. Threats, in STRIDE

### Entry positions

Positions as the document has them. Every person is B2. B3 is empty: the document names no
outside adversary with a foothold, and the one sabotage scenario was among those a Kurchatov
Institute study found to "contradict the objective data available",
`insag-7-paged.txt:3138-3140`, `:3152-3153` (p.72). Position (12) is the physical condition
with no actor behind it.

| # | Position | Reaches | Lines |
|---|---|---|---|
| (1) | The senior reactor control engineer at the console | the EPS-5 button; the manual rods; the regulator set points; the local-to-global transfer; the general key; the board and the log | `insag-7-paged.txt:3357-3358` (p.76), `:3702-3707`, `:3732-3739` (p.83), `:3230-3232` (p.73), `:3814-3817` (p.85) |
| (2) | The shift and its supervisors | the stop-valve order; the logs; feedwater by hand; the MCPs; the oscilloscope; the DBA button | `insag-7-paged.txt:3296-3298` (p.75), `:3855-3857` (p.86), `:3247-3249` (p.74), `:2761-2764` (p.64), `:2776` (p.65), `:5672-5674` (p.123) |
| (3) | The Chief Engineer and plant management | authorization of an ORM below 26 rods; switching off ECCS automatic actuation; test programmes; the on-the-spot change of test power | `insag-7-paged.txt:3608-3610` (p.81), `:3679-3683` (p.82), `:5557-5564` (p.121), `:1113-1115` (p.29) |
| (4) | The test programme's authors | ECCS isolation (§2.15), the seventh and eighth MCPs (§2.12), the planned power, the DBA button and oscilloscope | `insag-7-paged.txt:3673-3676` (p.82), `:3914-3916` (p.87), `:2593-2598` (p.61), `:2854-2855` (p.66), `:2885-2888` (p.67), `:4000-4001` (p.89) |
| (5) | The design organizations and their documents ([19], [43], [11], [44]) | the rod design, the EPS's principle and signal list, the manual reswitch, the core composition, what operators were told | `insag-7-paged.txt:1727-1731` (p.44), `:2162-2185` (p.53), `:2267-2281` (p.55), `:3804-3817` (p.85), `:909-913` (p.24), `:4098-4101` (p.91) |
| (6) | The ministries | decisions for the plant as a whole; bringing the plants "into line with the safety standards and regulations"; investigations of unusual EPS signals | `insag-7-paged.txt:4401-4403` (p.97), `:2546-2549` (p.60), `:4244-4249` (p.94, quoted [46]) |
| (7) | The regulator and the approving committees | approval of the Technical Safety Report; authorization of listed violations; the regulations | `insag-7-paged.txt:1719-1725` (p.44, quoted), `:1754-1762` (p.45), `:4437-4441` (p.98), `:1207-1211` (p.31) |
| (8) | A person at the jumper terminals, keys, straps and switches | any trip or alarm; the set points of O7 and O8; the two-turbine trip; ECCS actuation; the clutch switch | `insag-7-paged.txt:585-589` (p.16), `:3679-3681` (p.82), `:3814-3817`, `:3830-3833` (p.85), `:3866-3871` (p.86), `:2822-2823` (p.65) |
| (9) | The authors of the operating documentation: the Operating Procedures [40], the Reswitching Procedures [42] | what the console is permitted and required to do | `insag-7-paged.txt:4013-4025` (p.89), `:4040-4065` (p.90), `:3636-3639` (p.81), `:3890-3896` (p.87), `:4631-4632`, `:4638-4639` (p.101) |
| (10) | The SKALA system personnel | the operating calculations; what the control room is told of the ORM | `insag-7-paged.txt:3251-3257` (p.74) |
| (11) | The reader of the records after the event | the logs, DREG, RESTART, chart strips, oscillograms, notes; the account to the IAEA | `insag-7-paged.txt:2639-2648` (p.62), `:5767-5770` (p.125), `:372-375` (p.11) |
| (12) | A physical condition with no actor behind it | xenon poisoning; an MFCC perturbation; a measuring-circuit imbalance; a channel or weld failure; pump disturbance; a leak over 300 mm; a grid frequency variation; a SKALA restart; burnup over years | `insag-7-paged.txt:3236-3237` (p.74), `:3711-3719` (p.83, presumption), `:876-886` (p.24), `:3155-3160` (p.72), `:3893-3894` (p.87), `:2844-2846` (p.66), `:1803-1827` (p.46) |

Structural facts every row rests on: no ring, one shared actuator, no observer of the ORM
(the architectural model and the scorecard). The required control is one thing: an observer alerts and the system
halts until the fault clears or the privileged actor leaves. The last column says what
happened instead.

### S, Spoofing

A state, signal or value accepted as legitimate that is not what it presents itself as. S1
moved to the D table by its effect (V1).

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| S2 [added, A1] | (10), (1), (9) | The PRIZMA ORM (O19) standing for the EPS's margin | B2 | A computed margin that "did not take into account the position of the rods of automatic regulators Nos 1, 2 and 3 (a total of 12 rods)", found "unreliable at this time" by Annex I, with "a note to this effect" in the senior reactor control engineer's operating log; the staff "apparently believed that as long as the lower limit on ORM (15 equivalent rods) was satisfied, no matter what the actual rod configuration was, the demands of safety were met" (INSAG); summing partially inserted rods "is rather difficult" (Annex I note). Annex I dates the omission of the 12 regulator rods to about 07:00 on 25 April ("unreliable at this time"), `insag-7-paged.txt:3612-3619` (p.81); INSAG, "According to the record", places the unreliability of "the computer SKALA, which was used to calculate the ORM", "in the period in which the test took place", `insag-7-paged.txt:787-789` (p.21). | The one figure for the EPS's worth wrong by construction, compelling nothing. Reach: the whole core through S1 | `insag-7-paged.txt:3616-3620` (p.81), `:918-925` (p.24-25), `:4129-4133` (p.91), `:894-896` (p.24); ORM values DG5 | Continuous state verification (3) | Absent; no prescribed action, `insag-7-paged.txt:3620-3623` (p.81) |
| S3 [corrected, V15] | (4), (2) | The DBA button (BC7) on the electrical supply (OC11) | B2 | A button "specially installed for test purposes in order to simulate a DBA signal" to the diesel generator start-up and the TG8 rundown unit: a protection signal the plant did not generate. Its time: Table I-I 01:23:10; Annex I's text "6.6 s after closure" of the stop valves; Annex II "the exact times ... are not known" (DG21). Clearance of non-design devices per Annex II; whether sought is U5 | Bounded by the document's description to the diesel start-up and rundown circuits | `insag-7-paged.txt:2885-2888` (p.67), `:2776` (p.65), `:2882-2883` (p.67), `:5672-5674` (p.123), `:5714-5717` (p.124), `:5557-5568` (p.121) | Automatic integration (7) | Absent; the signal was the test's intent |
| S4 | (12), (1) | The lateral chambers' total current (SP1) as "reactor power" for O2, O3, O5 | no actor; read by B2 | One number for a core whose halves were "proceeding almost independently", read by chambers "all located at the mid-plane"; after EPS-5 the recorder showed "a small decrease in power and a subsequent increase" while the field shifted to about 2 m (calculations) | The protections and the operator act on a figure that does not represent the state that reaches the floor | `insag-7-paged.txt:566-575` (p.16), `:530-533` (p.15), `:3382-3386` (p.76), `:2009-2013` (p.50) | Substrate dependency (2); continuous state verification (3) | Absent; LAC-LAP and PPDDCS off, `insag-7-paged.txt:524-528` (p.15) |

### T, Tampering

An observer, its set point, its actuator or the state it depends on altered by a position,
with nothing observing the alteration. T9 and T17 dropped (V3, V10).

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| T1 | (8), (9) | Any trip or alarm (RP1, BC2) | B2 | "a ready capability for the operators manually to disable certain safety systems, bypass automatic scram trips, and reset or suppress various alarm signals"; "The operating procedures permitted such disabling under some circumstances". Which systems is not listed (U16) | One act removes an observer; nothing records or resists it | `insag-7-paged.txt:585-589` (p.16); INSAG, disabling "seems to have been regarded rather lightly", `:1086-1088` (p.28); quoted [14], "measures must be taken to exclude the possibility of an automatic protection system being deliberately switched off", `insag-7-paged.txt:4173-4174` (p.92) | Self-defense (5) | Absent |
| T2 [corrected, V7, V31] | (5), (9), (8), (1) | Drum level protection O7 (RP2, H4, C9, PR7) | B2 | The design decision [43] made the -600 mm EPS-5 set point a manual selection: automatic reswitching "is not permitted"; the operator "should reswitch them manually using the general key". The console did not select it; Annex I calls this a violation of [42] §9 ("did not switch", and in its list a "Change in the set point"); INSAG reports the operators "technically in violation" "according to the SCSSINP Commission". Six crossings below -600 mm are table times (U11). Both bodies: the -1100 mm protection remained in operation, and the level setting did not affect the accident | The -600 mm halt absent for the low-power period, present only by a person's act; reach on 26 April limited by both bodies' findings that it did not affect the accident | `insag-7-paged.txt:3807-3817` (p.85, quoted [43]), `:3790-3799` (p.85), `:813-819` (p.22), `:1076-1078` (p.28), `:3946-3949`, `:3975-3977` (p.88), `:5620-5625` (p.122) | Self-defense (5); continuous state verification (3) | Absent; a key and a procedure |
| T3 [corrected, V31; added, A8] | (9), (8), (1) | Two-turbine protection O9 (RP3, H3, C10, PR6) | B2 | [42] §1 "provided for the disabling of this protection system in the event of a turbogenerator load of less than 100 MW(e)"; the personnel obeyed it. Time: INSAG 00:43:27; tables scrambled (DG2). Signal kind U14 (DG19). INSAG: had it fired, it "might well have caused the destruction of the reactor at the time of turbine trip rather than shortly afterwards". The state that required the disabling arose from TG8's disconnection at 00:41 for vibration measurements "not envisaged in the turbogenerator No. 8 rundown test programme", `insag-7-paged.txt:3855-3863` (p.86) (M1). | A halt removed by procedure; had it fired, the halt was the same actuator from the same positions | `insag-7-paged.txt:3863-3873` (p.86), `:772-773` (p.21), `:1080-1084` (p.28) | Self-defense (5); automatic integration (7) | Absent; "The Commission believes that the personnel cannot be blamed", `insag-7-paged.txt:3871-3872` (p.86) |
| T4 [corrected, V31] | (5), (9), (8) | Drum pressure protection O8 (RP4, H6, C11, PR9) | B2 | At 00:36:24 the set point changed from 55 to 50 kgf/cm2 under [42] §12, which "entitled" personnel to select it. The protection "was designed to stop the turbine"; "the design was such that at a turbine power of less than 100 MW(e) the reactor was left without any protection system to guard against pressure reduction"; "it might have resulted in a reactor runaway even at the regulatory ORM" (Annex I note). The quoted [1] said "all the thermal parameter reactor protection systems were switched off"; Annex I, not true (DG10) | OC5 pressure with no reactor observer below 100 MW(e) | `insag-7-paged.txt:3828-3851` (p.85-86), `:3800-3802` (p.85) | Self-defense (5); continuous state verification (3) | Absent; the Commission does not blame the personnel, `insag-7-paged.txt:3834-3840` (p.85-86) |
| T5 [corrected, V31, V33] | (4), (9), (3) | ECCS O10 (RP5, H7, C8, PR10) | B2 | Slide valves closed at 14:00 under programme §2.15; [42] §2 "authorized the Chief Engineer of the plant to switch off automatic actuation of the ECCS. This is tantamount to switching off the fast acting part of the system and, therefore, the whole ECCS"; Annex I: a violation of §2.10.5. INSAG: "recent Soviet information confirms" it was permissible if authorized (DG7). Both bodies: it did not affect this accident | The only injection path absent about 11 hours at power, for any DBA in that time | `insag-7-paged.txt:3673-3687` (p.82), `:733-743` (p.20), `:1068-1074` (p.28) | Self-defense (5); death signaling (6) | Absent |
| T6 [corrected, V39; added, A10] | (1), (5), (12) | LAC-LAP, LEP O4; PPDDCS O16 (RP6, H10, C4) | B2; low power | The in-core systems "operated at power levels above 10% of nominal" and were "switched off"; "there was no in-core instrumentation available"; Annex I: "no limitations were imposed on reactor operation at low power levels". LEP's action U6. The hold at 200-300 MW(th) lies below 10% of nominal: Table II-I gives 3200 MW thermal power, `insag-7-paged.txt:5209` (p.115), a table value the quoted §12's "160 MW(th) (5% of nominal power)" confirms by arithmetic, `insag-7-paged.txt:3637-3638` (p.81); LAC-LAP controlled "at power levels greater than 10%", `insag-7-paged.txt:2004-2007` (p.50). | The only observers of the distribution absent where "large field non-uniformities and high disturbances of both axial and radial power density distributions can occur" | `insag-7-paged.txt:524-528`, `:543-546` (p.15), `:2004-2021` (p.50), `:2702-2704` (p.63, Table I-I, "in operating log") | Substrate dependency (2); self-defense (5) | Absent; off by design below 10% |
| T7 | (1), (8), (5) | The EPS rod group (RP7) | B2 | "an emergency protection system rod could be converted into a manual control rod and vice versa without any technical or organizational problems"; the division "was a notional one" | The EPS's membership is a person's setting; nothing counts it | `insag-7-paged.txt:2052-2057` (p.51) | Self-defense (5); automatic integration (7) | Absent |
| T8 | (1), (8) | Clutch power switch (RP8, BC11) | B2 | "power switch of clutch mechanisms is off" (log note, 01:24); "power supply to RCPS rod drive coupling switched off" (Table II-III). Effect not settled (U4) | One switch acts on the halt actuator with an effect the document does not state | `insag-7-paged.txt:2816-2823` (p.65), `:5705-5712` (p.124) | Self-defense (5) | Not settled by the document |
| T10 [corrected, V18; added, A6] | (1), (3), (5) | The rods' positions (OC2, OC14; BC12) | B2 | Rods withdrawn to compensate xenon poisoning, "almost all control rods in the upper position"; more water columns than permitted "(which occurs rarely, is subjective and permitted by personnel)"; INSAG: "raising almost all the rods to extreme positions led to conflict with the simultaneous requirements to maintain shutdown capability". Restrictions "never imposed and apparently the matter was forgotten". Nine of 211 positions recorded. The Commission's interpretation of the unimplemented 150-rod limit is PR12. Annex I: "It is not clear whether or not the personnel realized the serious consequences of their actions", `insag-7-paged.txt:3241-3242` (p.74); INSAG: "Probably he was aware that continued operation under conditions of increasing xenon content of the reactor was reducing the ORM", `insag-7-paged.txt:790-792` (p.21). | The halt actuator becomes the hazard (S1); OC2 and OC14 have no observer | `insag-7-paged.txt:3230-3240` (p.73-74), `:3264-3266` (p.74), `:3474-3476` (p.78), `:1013-1015` (p.27), `:938-939` (p.25), `:2838-2840` (p.66), `:3664-3669` (p.82) | Continuous state verification (3) | Absent; §8.9.1(a) lists reactivity, not the ORM, `insag-7-paged.txt:3646-3648` (p.82) |
| T11 [corrected, V19, V25] | (9), (1) | The regulators' set point (O5; BC4, BC5; PR5) | B2 | The engineer "probably reduced the set points ... using the 'fast power reduction button'" and restored power "by manipulating the set points" (presumption); §6.7 "authorized the power then to be restored to the rated value"; "The authors of this report believe that the drop in reactor power at 00:28 and subsequent power increase were largely to blame", with "It is impossible to draw a final conclusion". INSAG: "Recent reports suggest that there was no operator error as such" (DG8) | The known-good the regulators hold is a dial; the rise under poisoning drove T10 | `insag-7-paged.txt:3732-3739` (p.83), `:3754-3757`, `:3769-3780` (p.84), `:762-767` (p.21) | Continuous state verification (3) | Absent; the procedure authorized it |
| T12 [added, A12] | (3), (2), (4) | The test's planned power (BC16, C14, PR13) | B2 | "the test procedure was altered on an ad hoc basis"; "the operating staff did not stop and think"; "unapproved changes in the test procedure were deliberately made on the spot" (INSAG). Annex I: no document prohibited that power; "the accident might not have happened. However, this theory needs to be tested". The Commission "considers that the personnel cannot be held to blame for operating the unit at a power of less than 700 MW", `insag-7-paged.txt:3909-3910` (p.87). | The test ran where "low power levels proved to be the most dangerous ones" | `insag-7-paged.txt:1096-1115` (p.29), `:1333-1335` (p.34), `:3877-3882` (p.86), `:3992-4002` (p.89) | The +1 absent | Absent |
| T13 [corrected, V31] | (4), (9), (5), (12) | MCP flow (OC4) with eight pumps (PR8, PR11, C12) | B2 by the programme; the circuit's response | MCPs 12 and 22 switched on per §2.12, "the personnel committed no violations by these actions"; flows of certain pumps reached 7500 m3/h against the §5.8 limit, a procedural limit with no trip. INSAG: pump disturbance "could have led to sudden augmentation"; eight-pump operation "unsatisfactory"; Annex I: "It would appear" the eight pumps "if anything hindered the reactor runaway ... Additional theoretical analysis in this area is required" (DG13) | A circuit state beyond its limit with no observer but a record | `insag-7-paged.txt:3914-3928` (p.87), `:876-879` (p.24), `:1050-1052` (p.28), `:3969-3973` (p.88), `:3046-3048` (p.70) | Continuous state verification (3) | Absent |
| T14 [corrected, V28] | (1), (2), (12) | Feedwater (OC6), the level O7 watches, inlet subcooling (OC1) (BC10) | B2 | Feedwater by hand: the quoted [33], "A minute earlier (at 01:20) an operator reduced the feedwater flow rate"; the Commission, "brought back to the average value ... about 120 t/h for each side"; Annex I's text 200 t/h; Table II-III 90 and 180 t/h (DG12). Subcooling of 3 degrees C (Annex I, "3°C" in the source); INSAG "little or no" | Level and subcooling move on a hand, with no observer of either | `insag-7-paged.txt:3084-3093` (p.71), `:3293` (p.75), `:5650-5654` (p.123), `:3270-3273` (p.74), `:1131-1132` (p.29) | Continuous state verification (3) | Absent; "manual control of the water level" among "normal technical processes", `insag-7-paged.txt:3244-3249` (p.74) |
| T15 | (2), (12) | Graphite stack gas circuit (OC13) watched by O14 | B2 | Replacement of the nitrogen-helium mixture with nitrogen from 03:45 (Table I-I; Table II-III beside 01:06, column offset). Purpose and effect on O14 unstated (U13) | Not settled | `insag-7-paged.txt:2669-2670` (p.63), `:5592-5593` (p.122), `:5193-5194` (p.115) | Automatic integration (7), if the change reached O14 | Not settled by the document |
| T16 [corrected, V34] | (5), (12) | Core composition and coefficients (OC1) | B2 by design decision; burnup | "As the fuel burnt out, the designers allowed these absorbers to be removed ... This shifted the void coefficients significantly in the positive direction" (INSAG); at Leningrad Unit 1 the measured coefficient rose from negative to about +5 beta-effective as absorbers fell from 211 to 32 (values OCR-garbled, U8); second generation units approached about +5 beta-effective and "There were similar fuel burnups at Chernobyl Unit 4"; "There is no safety analysis of the void coefficient". The design documentation: negative (INSAG) or "a high positive value" foreseen (Annex I) (DG17) | OC1 coefficients changed over years with nothing integrating the change | `insag-7-paged.txt:909-916` (p.24), `:1807-1809`, `:1823-1827` (p.46), `:1866-1869` (p.47), `:450-456` (p.13), `:1783-1786` (p.45) | Automatic integration (7); continuous state verification (3) | Absent; NSR 3.2.2 required safety "guaranteed in the design and explicitly proved", `insag-7-paged.txt:1776-1779` (p.45, quoted) |
| T18 | (5), (7) | Accident localization (OC10) | B2 | Part of the circuit outside leaktight buildings with "deflecting plates which direct the release ... into the atmosphere"; the thyroid dose estimate "the grounds given to justify the admissibility of not having a proper accident localization system" (reporting [11]); GSP-73 Article 2.7.4 required "design features to ensure the safety of the public" | The last barrier vented to the atmosphere by design; a passive barrier watched by nothing | `insag-7-paged.txt:2333-2355` (p.56-57), `:2362-2365` (p.57) | A missing observer; constraint 2 | Absent; approved, `insag-7-paged.txt:1754-1759` (p.45) |

### R, Repudiation

A record that existed and compelled no action; a record missing where the state that mattered
was; a record that two bodies read differently.

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| R1 [corrected, V12; added, A2] | (1), (10), (9), (5) | The ORM's record (OC3; O19, SP4) | B2 | "no provision in the design ... for a device to measure the ORM"; the operator summed rod depths or waited "a few minutes" for the computer; cycle 10-15 min (INSAG), 5 min for SKALA and PRIZMA, 15 min for the ORM before the accident (Annex I) (DG25); printouts only; no calculation at 01:22:30, the 8 rods computed "after the accident". INSAG: "it is likely that the operator did not know the value of the ORM during the critical part of the test". The operator read rod depth "from the measuring instruments" on a non-linear scale (SP12), and the accuracy of the hand-summed ORM "depends on the power density field profile", which below 10% of nominal had no in-core observer (D4), `insag-7-paged.txt:3652-3658` (p.82). | The parameter that "determined the ability of the reactor's EPS to perform its functions" reached a printout and compelled nothing | `insag-7-paged.txt:3650-3658` (p.82), `:552-559` (p.16), `:2490-2491` (p.59), `:2830-2831`, `:2847-2850` (p.66), `:3251-3257` (p.74), `:789-790` (p.21), `:4144-4148` (p.92) | Continuous state verification (3); heartbeat (1) | Absent; "The ORM is not included in the list of important parameters", `insag-7-paged.txt:3646-3648` (p.82) |
| R2 [corrected, V28] | (12), (11) | DREG, RESTART, SKALA hardware (SP3, SP4, OC12) | no actor; the reader | DREG "does not record important reactor parameters, such as power, reactivity and channel coolant flow rates", nine of 211 rods, "one of the lowest priorities", three interruptions; Annex II's first stage lasted until the recording systems failed (the source's "railed") | The record of the state that mattered is partial; nothing watched the computer | `insag-7-paged.txt:2834-2850` (p.66), `:5739-5755` (p.125), `:5324-5326` (p.117) | Heartbeat (1); death signaling (6) | Absent |
| R3 | (2), (1), (11) | Logs and explanatory notes (BC14, BC17) | B2 | No note of the level setting, `insag-7-paged.txt:3794-3795` (p.85); Table II-III's EPS-5 entry rests on "the explanatory notes written by personnel"; personnel accounts "highly inaccurate" in some cases; the logs "confirm the chronology" (Annex II); "sparse and inaccurate plant data" (INSAG) (DG4) | Whether a protection was armed rests on a note or its absence | `insag-7-paged.txt:3794-3795` (p.85), `:5683-5685` (p.124), `:5767-5778` (p.125-126), `:372-375` (p.11), `:3779-3780` (p.84) | Death signaling (6) | Absent |
| R4 | (11) | The clocks: DREG, teletape, oscillogram, logs | the reader | EPS-5 at 01:23:40, "01:23:39 on teletape" (DG11); the oscilloscope not synchronized, aligned afterwards on two events; the first MCP pair "disconnected at 01:22:46" against "6.00 s to 6.45 s after" EPS-5 (DG1); Table I-I's clock markers alternate; "the rate of development of subsequent events is not compatible with the resolving power of the reactor parameter recording devices" | The order of the last seconds is a reconstruction | `insag-7-paged.txt:2781-2783` (p.65), `:2859-2880` (p.66-67), `:3361-3366` (p.76) | Continuous state verification (3) of the record | Not applicable: a record |
| R5 | (11), (12) | Chart recorders, PPDDCS and neutron power recorders (SP5, SP7) | the reader | The recorders "cannot be used to record fast" processes; the PPDDCS recorder "did not record the reduction in thermal power below 30 MW"; "If neutron power is meant, then the personnel violated the Operating Procedures; if thermal power is meant, there was no violation" | The record cannot settle the state the procedure turns on | `insag-7-paged.txt:2652-2655` (p.62), `:3747-3764` (p.84) | Continuous state verification (3) | Not applicable: a record |
| R6 [corrected, V16] | (5), (7) | The Technical Safety Report [11] and its approvals (BC15, PR15, C17) | B2 | NSR-04-74 Article 3.1.6 required violations listed and authorized; "No list of violations ... was given"; "no analysis was made of the acceptability of these violations and they were not authorized"; approved by three state committees in 1975; "the operating documentation ... could not possibly correspond to the actual parameters of the reactor". The approving committee's own date is DG22 | A record whose required content was absent compelled nothing; three approvals observed nothing | `insag-7-paged.txt:1719-1769` (p.44-45), `:5312-5318` (p.117), `:2320-2324` (p.56) | Continuous state verification (3) at the producing system; constraint 4 | Absent |
| R7 [corrected, K1; added, A9] | (5), (6) | The 1983 positive scram finding (C16) | B2 | "The Chief Design Engineer [22] and the Scientific Manager knew about this effect before the accident"; the Scientific Manager: "Triggering of the EPS in this case may lead to the introduction of positive reactivity. It seems likely that a more thorough analysis will reveal other dangerous situations" (quoted [24]); "none of them were implemented"; INSAG: "apparently the matter was forgotten". Year DG9. INSAG: "Apparently, there was a widespread view that the conditions under which the positive scram effect would be important would never occur. However, they did appear in almost every detail", `insag-7-paged.txt:855-858` (p.23). | A recorded hazard reached the plants as an announced intention to restrict rod withdrawal (Annex I) and, by INSAG, as "this information" (DG26), while the restriction was never imposed and the change to the Operating Procedures and any explanation to the personnel were not made; it reached no observer. | `insag-7-paged.txt:2187-2206` (p.53-54), `:938-939` (p.25), `:851-855` (p.23), `:4105-4111` (p.91), `:4138-4141` (p.92) | System-wide response (4) at the producing system | Absent |
| R8 | (6), (5) | The 1975 Leningrad accident; the unusual EPS signals (C18, C19) | B2 | The 1976 commission understood the accident "was a result of the reactor's design characteristics, rather than personnel errors"; "those who were in charge of the operation of plants with RBMK-1000 reactors were not informed of the real causes"; INSAG: "the operating staff at Chernobyl were not aware"; quoted [46]: the Ministry "did not take sufficient notice of the repeated unusual signals"; the 1976 recommendations "have still not been implemented" | Records held at ministry and design level, delivered to no operating position | `insag-7-paged.txt:2391-2419` (p.57-58), `:1288-1291` (p.33), `:4244-4249` (p.94), `:2405-2407` (p.58) | System-wide response (4) at the producing system | Absent |
| R9 [corrected, V20] | (9), (5) | The Operating Procedures' meaning of the ORM (PR1 to PR5) | B2 | §8.9.1(a) omits the ORM; §12 has no ORM requirement; the Procedures "did not draw the attention of the personnel to the importance of the ORM"; "in the Commission's opinion ... the designers did not inform the operating personnel"; §6.6.4's "incorrect indication" shows "the ORM was not treated as an operational safety limit"; floors of 15 (§9) and 10 rods ([44]) "equally contradictory" (DG18) | The operators' only known-good carried the wrong meaning of the parameter the EPS depended on | `insag-7-paged.txt:3646-3648`, `:3660-3662` (p.82), `:3632-3634` (p.81), `:4098-4103` (p.91), `:4073-4078` (p.90), `:4144-4148` (p.92) | Continuous state verification (3) | Absent; quoted [14]: "the safety of nuclear power plants cannot be based on instructions", `insag-7-paged.txt:4170-4171` (p.92) |
| R10 [corrected, V26] | (11), (6) | The official account [1] and INSAG-1's chronology | the authors of the account | [1]: "all the thermal parameter reactor protection systems were switched off"; Annex I: not true (DG10). INSAG-1's turbine trip blocking moved from 01:23:04 to 00:43:27; "The recent information suggests" the level change at 00:36 (DG2, DG20); "This trip would have saved the reactor" "seems not to be valid"; the 700 MW(th) proscription "based on incorrect information"; Annex I: the Council's decisions "paved the way for the one-sided presentation" | The account the first international judgement rested on misstated the protections' state | `insag-7-paged.txt:3800-3802` (p.85), `:771-781` (p.21), `:806-807` (p.22), `:1045-1048` (p.28), `:3062-3070` (p.70) | Not a property: the record of the system | Not applicable |

### I, Information disclosure

No row. The document names no path by which plant
information reached a position that should not have it. Its information failures are
undelivered or wrong records, filed as R1, R7, R8, R9, and missing components (Missing structural components).

### D, Denial of service

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| S1 [corrected, V1, V17; refiled from S] | (12), (1), (5) | The EPS-5 halt (H9; H1, H2, H4 by the same actuator) at the rod positions in force | any trip, no actor; or B2 at the console | The halt's service denied at the moment of demand: from the upper stops the rods' motion inserts reactivity locally in the lower core. Annex I's finding: "the event which initiated the accident was the pressing of the EPS-5 button when the RBMK-1000 reactor was operating at low power with a greater than permissible number of manual control rods withdrawn", the press made "for some reason which has not yet been established for certain"; hedged around it: "it would appear" the EPS could not be used from 00:30 "without damaging the core. This will have to be confirmed". INSAG: "may well have been the decisive contributory factor"; "It is not known for certain what started the power excursion"; "probably a decisive contributory factor". Research [20]: positive during the first eight seconds at "a non-regulation ORM of 7 control rods". Annex II: "could induce a negative reactivity insertion during the first second and then a reactivity rise" (DG23); the models do not reproduce the runaway at the 3 s signals. ORM at 01:22:30: DG5 | The halt is the initiating event by Annex I's finding; the whole core, then the plant. Nothing positioned to notice | `insag-7-paged.txt:3444-3447` (p.78), `:4185-4191` (p.93), `:3305-3309` (p.75), `:863-864` (p.23), `:1293-1297` (p.33), `:1976-1984` (p.49), `:477-480` (p.14), `:5486-5489` (p.120), `:6005-6008` (p.131) | Reflexive response (8); the +1 absent | Absent; "The Commission was unable to establish why the button was pressed", `insag-7-paged.txt:3360` (p.76) |
| D1 [added, A1] | (12), (10), (1) | PRIZMA's ORM calculation (O19, C1) | no actor; B2 | "unreliable at this time, because it did not take into account the position of the rods of automatic regulators"; the procedures "did not prescribe the actions to be taken ... (in the event of unreliable calculation)" or "complete failure of the PRIZMA code"; operation at 1500 MW below 15 rods "from about 07:00 to 13.30 on 25 April". Annex I dates the omission of the 12 regulator rods to about 07:00 on 25 April ("unreliable at this time"), `insag-7-paged.txt:3612-3619` (p.81); INSAG, "According to the record", places the unreliability of "the computer SKALA, which was used to calculate the ORM", "in the period in which the test took place", `insag-7-paged.txt:787-789` (p.21). | The one computation of the EPS's worth lost, operation continuing | `insag-7-paged.txt:3612-3628` (p.81), `:787-789` (p.21) | Heartbeat (1); reflexive response (8) | Absent: continue |
| D2 | (12) | SKALA and DREG (O19, SP3, OC12; C2) | no actor | Three restarts interrupted DREG; PRIZMA and RESTART "have a long cycle (5 min)" with "interruptions ... caused by restarting of the system" | The computing hub out of service with no response | `insag-7-paged.txt:2844-2849` (p.66), `:5747-5753` (p.125) | Heartbeat (1); death signaling (6) | Absent: continue |
| D3 [corrected, V3, V25] | (12), (1) | The automatic regulators (O5; C3) | no actor; then B2 | By the Commission's presumption: the local regulator off "For some unknown reason (possibly ...)", No. 1 to its upper stop, No. 2 not into automatic mode, all regulators out of automatic regime, power falling "As a result of the continued 'poisoning'", the engineer taking over by hand. The rate protection's state at that moment is U24. INSAG: "Recent reports suggest that there was no operator error as such" (DG8) | Automatic power control lost in one fault, the response a person's | `insag-7-paged.txt:3698-3739` (p.83), `:762-767` (p.21), `:3223-3228` (p.73), `:3777-3780` (p.84) | Heartbeat (1); system-wide response (4) | Absent: continue by hand |
| D4 [added, A13] | (12), (1) | LAC-LAP, LEP, PPDDCS (O4, O16; C4, H10, RP6) | low power; B2 | Below 10% "no in-core instrumentation"; the ex-core detectors "could not indicate the average axial distribution"; "a double peaked axial power density distribution"; "power peaking factor of 2.0"; "up to 1000 per hour" manipulations. Annex I: the change between 00:28 and 00:33 "gave rise to a new xenon reshaping of the power density fields which the personnel were unable to control"; "No calculational studies have been made of the power density field dynamics from this time until the time of the accident", `insag-7-paged.txt:3771-3775` (p.84). | OC1 distribution with its only observers off | `insag-7-paged.txt:524-538` (p.15), `:2007-2021` (p.50), `:3262-3263` (p.74), `:3367-3370` (p.76) | Substrate dependency (2); heartbeat (1) | Absent |
| D5 [corrected, V23; added, A7] | (1), (3), (12) | The ORM below the floor (OC3; C5) | B2; xenon | Operation at 15 rods or less "from 07:00 until 13:30 on 25 April and from approximately 13:00 on 26 April until the time of the accident" (DG6); §9 required shutdown; no alarm, no trip; research [20] on the EPS's worth; the Commission: the designers "were evidently not sufficiently aware of this fact before the accident, otherwise it is difficult to believe that they could have expected" to ensure safety by "organizational measures such as prohibiting reactor operation at low ORMs". INSAG: the ORM "was not conveniently available to the operator, nor was it incorporated into the reactor's protection system". Table I-I, under "time in operating log", gives an ORM of 13.2 manual control rods at 07:10 and 16.8 at 15:20 on 25 April, `insag-7-paged.txt:2679`, `:2689` (p.63); Table II-III carries the same values with its time column offset, `insag-7-paged.txt:5594-5599` (p.122). The values are confirmed by two bodies' tables; the times rest on Table I-I and agree with the running text, 15 rods or less "from 07:00 until 13:30 on 25 April", `insag-7-paged.txt:3939-3940` (p.88). | The hazard with no observer; the prescribed response to it is S1 | `insag-7-paged.txt:3939-3941` (p.88), `:4020-4021` (p.89), `:1921-1925` (p.48), `:1976-1988` (p.49), `:901-902` (p.24), `:4061-4065` (p.90) | Continuous state verification (3); heartbeat (1); the +1 absent | Absent: continue; the prescribed halt is the fault |
| D6 | (3), (2), (9), (5) | Power below 700 MW(th) (OC1; C6) | B2 | "not proscribed, either in design, in regulatory limitations or in operating instructions" (INSAG); "no safe operating limits in terms of minimum permissible thermal reactor power"; the designers "did not impose any restrictions"; "low power levels proved to be the most dangerous ones". After the accident a lower limit of 700 MW(th) (what INSAG was told) | OC1 power level with no observer and no limit | `insag-7-paged.txt:754-758` (p.21), `:1045-1048` (p.28), `:3886-3887` (p.87), `:1841-1844` (p.46), `:3995-3998` (p.89), `:1436-1439` (p.38) | Continuous state verification (3) | Absent: continue |
| D7 [corrected, V9] | (5) | The EPS's principle (O1, O21; C7) | B2 by design | The quoted [19]: the grid share makes "the traditional principle ... unacceptable"; "A complete reactor shutdown by dropping all the RCPS rods is foreseen only for total loss of power to the plant. Under all other accident conditions, the power is reduced in a controlled manner". The Commission: the designers analysed the algorithm "in terms of the efficiency of the plant's operation in the power supply system, rather than in terms of its ability to ensure nuclear safety". §11.4 required personnel to reduce power to 200-300 MW(th) "following automatic power reduction in the EPS-3 design mode", with "no limitation on the period". Against [19]'s "only", EPS-5 "complete shutdown of the reactor" on drum level and two-turbine signals, and Annex II's EPS terminating the chain reaction on dangerous divergences (DG24). The grid rationale is an availability claim (section 10) | Continue-on-fault in the design's stated principle and in EPS-1 to EPS-3 | `insag-7-paged.txt:2267-2292` (p.55), `:3890-3896` (p.87), `:3810-3813` (p.85), `:3866-3873` (p.86), `:5140-5146` (p.113) | Reflexive response (8) | Absent by design for EPS-1 to EPS-3 |
| D8 [corrected, V30] | (12) | The regulator rods' freedom to move (O6; C13) | no actor | 'One overcompensation upwards' from 01:19:39 until 01:19:44 and from 01:19:57 until 01:23:30, "at which time the automatic control rods could not move into the core"; positions last recorded at 01:22:37 | Automatic insertion unavailable for 3 min 33 s before EPS-5; recorded, acted on by nothing | `insag-7-paged.txt:3332-3338` (p.75), `:2751-2754` (p.64), `:2778-2779` (p.65) | Reflexive response (8); system-wide response (4) | Absent: a record |
| D9 [corrected, V22] | (12) | ECCS sensing (O10) against a rupture outside the sensed volume (C15); a leak over 300 mm (OC4) | no actor | "no DBA signal ... was given because the point at which the MFCC ruptured was not in the reinforced leaktight compartments where the sensors are placed, but in the core itself" (scenario, "no longer based on calculations"); by [28], "given the initial state of the reactor just before the tests", a leak over 300 mm "could have resulted in an accident which would have been just as serious"; the design assumed self-shutdown on voiding, which calculations of 1980, 1985 and 1987 reversed | The injection path blind to the substrate that failed | `insag-7-paged.txt:3514-3517` (p.79), `:3457-3458` (p.78), `:3155-3160` (p.72), `:1854-1864` (p.47) | Substrate dependency (2) | Absent: no signal |
| D10 [corrected, V21] | (12) | Reactor space relief and cover plate (O11, OC8, OC9; H5) | no actor | Two simultaneous ruptures the limit, "due to the sizes of the pressure relief pipes"; more "would generate a pressure high enough to fail the containment function by lifting the cover plate" (INSAG); a rupture of more than one channel "could, therefore, cause lifting ... followed by failure of the whole RCPS rod insertion system" (Annex I); the rods "only half-way down" and jammed (scenario, "no longer based on calculations"); Smolensk Unit 3's new dump handles 9-10 (Annex II, after the accident) | The halt actuator destroyed by the state it was halting; the barrier's capacity a property of pipes | `insag-7-paged.txt:697-703` (p.19), `:2120-2123` (p.52), `:3504-3507` (p.79), `:3457-3458` (p.78), `:6284-6297` (p.138) | Reflexive response (8); a missing observer above two ruptures | Absent |
| D11 | (12), (1) | Drum pressure below 100 MW(e) (OC5) | no actor; B2 | "the reactor was left without any protection system to guard against pressure reduction. At the actual" void coefficient "it might have resulted in a reactor runaway even at the regulatory ORM (for example, in the event of the opening or non-closing of the main pressure relief valves ...)" (Annex I note). The fast acting dump triggered during the power rise and at 01:23:48 (table) | A hazard with no reactor observer in the range the test used | `insag-7-paged.txt:3846-3851` (p.86), `:3247-3248` (p.74), `:2812-2813` (p.65) | A missing observer | Absent |
| D12 [corrected, V28; added, A11] | (12), (1), (4) | Inlet subcooling and steam quality (OC1, OC4, OC6) | low power, eight pumps, low feedwater; B2 by the programme | Subcooling of 3 degrees C and "a correspondingly low steam quality"; "a small power increase (for whatever reason) could result in a much higher increase in the volumetric steam quality in the lower part of the core"; INSAG: the inlet "may not have been subcooled at all"; "Such a mode of operation in itself could have led to a destructive accident"; Annex II: "slightly below boiling point"; Annex I: "Similar thermal-hydraulic parameters could occur during any power reduction". Annex I: "there is nothing wrong with the programme itself"; with the operating documentation it "provided sufficient basis for the safe testing of the planned operating conditions"; the high flow and the subcooling "to just below boiling point" were "a thermal-hydraulic characteristic of the planned mode", `insag-7-paged.txt:2613-2629` (p.62). | OC1 subcooling with no observer | `insag-7-paged.txt:3270-3284` (p.74), `:656-659` (p.18), `:1131-1134` (p.29), `:5570-5573` (p.121), `:2625-2628` (p.62) | Continuous state verification (3) | Absent |
| D13 [corrected, V9, V37] | (12), (4) | Loss of plant power (OC11), the full-shutdown halt H8, the 48 V signal (O20) | no actor; the programme | The quoted [19] makes full shutdown by dropping all rods the response to "total loss of power to the plant"; the same actuator from the same positions, so by inference S1 if it fires in that state. Whether the test produced that condition is not settled: Annex II's "total power loss", the quoted Smolensk report's loss "for the unit's internal requirements", and four MCPs on external power (U23). 'No voltage, 48 V' at 01:23:49 recorded on DREG; the rods "stopped moving before they reached the lower limit stop switches"; trip or consequence is U4 | The one loss-tied halt in the quoted design shares the actuator that is the hazard; its death signal reached a recorder | `insag-7-paged.txt:2278-2280` (p.55), `:5534-5535` (p.121), `:2574-2576` (p.61), `:651-653` (p.18), `:2816-2823` (p.65) | Heartbeat (1); death signaling (6) | Absent: the signal is a record |
| D14 [added, A10] | (12), (9) | The EPS-3 hold at 200-300 MW(th) (O21; PR4) | an EPS-3 actuation, its triggers unstated (U21), or a grid frequency variation and a remote reduction; the procedure | §11.4 required the reduction "following automatic power reduction in the EPS-3 design mode, or remotely in the event of abnormalities in the power supply system (frequency variations)" with "no limitation on the period". The Commission's Note: such conditions "might have occurred without any intervention on the part of the personnel. We only need to assume a perfectly possible situation"; the ORM "could have fallen"; any further shutdown "could have led to a similar repetition". The hold at 200-300 MW(th) lies below 10% of nominal: Table II-I gives 3200 MW thermal power, `insag-7-paged.txt:5209` (p.115), a table value the quoted §12's "160 MW(th) (5% of nominal power)" confirms by arithmetic, `insag-7-paged.txt:3637-3638` (p.81); LAC-LAP controlled "at power levels greater than 10%", `insag-7-paged.txt:2004-2007` (p.50). The Operating Procedures [40] are "for Units 3 and 4 of the Chernobyl Nuclear Power Plant", `insag-7-paged.txt:4631-4632` (p.101). | Possible, by the Commission's hypothetical: a prescribed response leading into the state where the halt is S1 | `insag-7-paged.txt:3890-3907` (p.87) | Reflexive response (8); the +1 absent | Absent by procedure |
| D15 | (12), (1) | The regulators' measuring circuits and actuators (O5) at the end | no actor | "signals 'failures of measuring systems' from both main range automatic controllers" at 01:23:47 and "'Failure of the actuators'" at 01:23:49 (Table I-I; Table II-III the same events, time column offset) | The last automatic observers' deaths recorded, acted on by nothing | `insag-7-paged.txt:2793-2818` (p.65), `:5691-5708` (p.124) | Death signaling (6) | Absent |

File every row by its effect: a continue-on-fault path whose effect is accepting a forged
identity goes under S, one that grants an unearned privilege under E. Under D go the
continue-on-fault paths whose effect is service the model scores as lost or degraded.
Availability claims go in their own section, unranked.

### E, Elevation of privilege

A position granted, by document or design, a power the model places inside the ring.

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| E1 [corrected, V40; K4, K6] | (9), (3), (5) | The ORM floor by Chief Engineer authorization (BC13, PR1) | B2 | §9: "Reactor operation at an ORM" below 26 rods "must be authorized by the Chief Plant Engineer" (the source's "pf", V28); at about 03:00 on 25 April the ORM fell below 26. The quoted [44], the Technical Safety Report of the third stage: "On the authorization of the Chief Plant Engineer, a reactor may be allowed to operate with an ORM below the minimum value, but for no longer than three days. Operation of the unit is not permitted at an ORM of less than 10 rods" (DG18); whether [44] governed Unit 4 is not stated. Whether the authorization below 26 rods was sought or given on 25 April is not stated (U25). The document places Units 3 and 4 in the second stage, whose Technical Safety Report is [11], and names [44] the third stage's, approved by the Chief Design Engineer's and the Scientific Manager's institutes, `insag-7-paged.txt:1727-1732` (p.44), `:4646-4649` (p.101). | One position lowers the limit on the parameter that set the EPS's worth; nothing checks the authorization | `insag-7-paged.txt:3606-3610` (p.81), `:4018-4019` (p.89), `:4078-4087` (p.90-91), `:4646-4649` (p.101) | Constraint 1 inverted; self-defense (5) | Absent |
| E2 [corrected, V31, V33] | (9), (3) | ECCS actuation by Chief Engineer authorization (BC13, RP5) | B2 | [42] §2 "authorized the Chief Engineer of the plant to switch off automatic actuation of the ECCS"; INSAG "understands" it was a test requirement and that approval "had been obtained from the Chief Engineer"; "it was not necessary to disable the ECCS for such a long period of time"; Annex I: a violation of §2.10.5 (DG7) | A grant that removes the only injection path for as long as the holder chooses | `insag-7-paged.txt:3679-3684` (p.82), `:1068-1074` (p.28), `:733-736` (p.20) | Self-defense (5) | Absent |
| E3 | (9), (8), (1) | The Reswitching Procedures [42] and the permission to disable (BC2, BC3) | B2 | "The operating procedures permitted such disabling under some circumstances"; [42] §1, §2, §9, §12. The Commission: "in cases where there was a choice between complying with the safety requirements and shutting down the unit, or giving priority to economic considerations and keeping the unit in operation, the choice used to be made in favour of the second alternative" | Every protection's presence is a console choice by document | `insag-7-paged.txt:588-589` (p.16), `:3866-3871` (p.86), `:3795-3797`, `:3830-3833` (p.85), `:3679-3681` (p.82), `:3819-3823` (p.85) | Self-defense (5); B1 breached by document | Absent |
| E4 | (5) | The EPS's function handed to the personnel | B2 by design | "certain protection functions were shifted from engineered features to the personnel" (in a sentence whose "may have affected" governs the effect of unclear limits, V35); "It is evident that ... many functions of the EPS ... were transferred to the personnel"; "such an understanding would be regarded as an unlawful transfer of reactor protection functions"; the quoted [14]: "If a particular parameter exceeds certain limits, the reactor must be shut down automatically without the intervention of the operator". INSAG: prevention "depended on quick action by the operating staff; this was in unacceptable conflict with this fundamental design tenet" | A B2 position placed in the ring's role, with none of its properties | `insag-7-paged.txt:2518-2522` (p.60), `:4160-4172` (p.92), `:4089-4092` (p.91), `:965-969` (p.26) | B1: no human belongs in the ring; constraint 4 | Absent |
| E5 [corrected, V16] | (7), (6) | The right to build and run the design (BC15, C17) | B2 | "The basic design of the RBMK reactors was approved despite the lack of conformity to many of the USSR's design requirements" (INSAG); the regulator "could not be regarded as an independent body"; "Until 1984" a division of the Ministry for Intermediate Sized Machinery; "established only three years before the Chernobyl accident" (DG22); "Nevertheless, the design was approved and authorization given for construction by all the relevant authorities" | Authorization granted without the check the regulation required (R6) | `insag-7-paged.txt:1219-1220` (p.31), `:4437-4441` (p.98), `:1761-1762` (p.45), `:1207-1211` (p.31), `:4427-4430` (p.97), `:4322-4324` (p.95) | Constraint 4 | Absent |
| E6 [added, A11] | (3), (4), (7) | The test's clearance (PR14) | B2 | Annex I: such tests "should be approved by the General Designer, the Chief Design Engineer, the Scientific Manager and the regulatory body. However, regulations NSR-04-74 and GSP-82 ... did not require the plant managers to obtain approval"; Annex II: the Operating Procedures required clearance of non-design devices (DG14); whether cleared is U5. INSAG: "brought to a state not specified by procedures or investigated by an independent safety body". Annex I: "there is nothing wrong with the programme itself"; with the operating documentation it "provided sufficient basis for the safe testing of the planned operating conditions"; the high flow and the subcooling "to just below boiling point" were "a thermal-hydraulic characteristic of the planned mode", `insag-7-paged.txt:2613-2629` (p.62). | The plant held the right to alter protection and supply circuits for a test with no external check | `insag-7-paged.txt:2600-2611` (p.61-62), `:5557-5568` (p.121), `:1277-1279` (p.33) | Constraint 4; the +1 absent | Absent |
| E7 [added, A3] | (9), (1) | Power restoration after a reduction (§6.7; PR5) | B2 | §6.7 "authorized the power then to be restored to the rated value"; §6.2 ties a rise after a short shutdown to a table whose 50 and 45 rod values sit under a garbled header (U17; the 30-rod row confirmed by Annex II); "the regulations and operating documentation in force at that time did not contain clear definitions of 'minimum controllable power level' and 'shutdown reactor'". §6.2 governs a rise after a short term shutdown "when there has been no iodine poisoning", with the required margin "determined from the margin prior to the shutdown", `insag-7-paged.txt:4040-4045` (p.90, quoted); the Commission gives these extracts as "associated with the situation at 00:28" to illustrate "the contradictory nature of the directives concerning the ORM", `insag-7-paged.txt:4036-4039` (p.90). Whether §6.2 or §6.7 governed the rise after 00:28 is not settled by the document: whether the fall was a short term shutdown turns on what power §6.1's definition of a short term shutdown means, which "it does not indicate", and on terms the documentation did not clearly define, `insag-7-paged.txt:3758-3768` (p.84). | A right to raise power from a poisoned state under undefined terms | `insag-7-paged.txt:3754-3768` (p.84), `:4040-4059` (p.90), `:5246-5248` (p.116) | Continuous state verification (3) | Absent |

### Found by the chain hunt, verified

Seven rows the chain hunt found, each verified and corrected; four more were dropped as rows
and their content carried into the rows they duplicate (R1, E7), the signal-path
devices (SP12) or unsettled items (U7, U22). Ids kept.

| # | Entry | Component | Actor | Threat | Impact | Evidence | Maps to | Halt-on-fault control |
|---|---|---|---|---|---|---|---|---|
| M1 (T) [corrected, W29] | (2) | Turbogenerator No. 8 (OC7) and the two-turbine protection O9 (RP3, H3) | B2 | At 00:41 TG8 "was disconnected from the system to determine the turbine vibration characteristics during rundown", which "was not envisaged in the turbogenerator No. 8 rundown test programme" and was "planned in a different programme", partly carried out on 25 April. With TG7 stopped at 13:05, the disconnection "meant that the EPS-5 system ... had to be disabled", which the personnel did under [42] §1. Whether the vibration programme was cleared is not stated. Table I-I gives the vibration measurements from 04:13 until 12:36 on 25 April (table). INSAG: disabling was "required by normal procedures at low power levels, such as the power level for the revised test" | A configuration change at power by a procedure outside the test programme, which brought forward the state in which [42] §1 prescribed removing H3; by INSAG, the power level for the revised test would have required the same removal | `insag-7-paged.txt:3855-3873` (p.86), `:2674-2677` (p.63), `:1080-1082` (p.28) | Automatic integration (7); self-defense (5) | Absent; the disabling followed [42] §1, and "the personnel cannot be blamed", `insag-7-paged.txt:3871-3873` (p.86) |
| M2 (R) [corrected, W30; refiled from D] | (5) | The design documentation of the power and rate protections' action (O2, O3) | B2 by design | Article 3.3.29, quoted: a protection action "is normally carried out fully", and the documentation "must contain an analysis of any cases where termination of the protection action is permitted ... when the signal triggering the protection system disappears". The Commission "did not find in the design documentation any other analyses of the admissibility of terminating a protection action following disappearance of the actuating signal (from the power increase protection system or the power excursion rate reduction protection system)" and concludes the design did not comply. Whether the action ended when its signal cleared is not settled by the document; [19]'s operating algorithm would settle it | A required analysis of how the halt ends missing from the design's record; the halt's behaviour when its signal clears is unknown at the lines | `insag-7-paged.txt:2261-2265` (p.55, quoted), `:2283-2286` (p.55), `:2297-2298` (p.56) | Continuous state verification (3) at the producing system; reflexive response (8), not settled | Absent; the design was approved without the analysis (R6, E5) |
| M3 (D) [corrected, W31] | (12), (5) | The 211 rods as one actuator (OC2, OC9, OC14) | no actor; the design | Every rod carried the same displacer on a telescope: "The graphite displacer of each rod of all RBMK reactors" was connected "via a 'telescope'". The insertion system shares structure E: a rupture of more than one channel "could, therefore, cause lifting of the reactor cover plate and upper structure of the reactor (structure E), followed by failure of the whole RCPS rod insertion system"; the scenario: "jamming of all the RCPS rods, which by that time were only half-way down". The quoted [1]: "The comparatively slow motion of the regulators is offset by their large number"; the Commission: "The mistakenness of this view was highlighted by the very accident", with no reason given beyond that. Whether the rods shared one drive supply is not stated (U4) | The halt's redundancy is 211 copies of one mechanism with common failure modes; the hazards table names OC2, OC9 and OC14 apart and not their shared failure | `insag-7-paged.txt:472-474` (p.14), `:2119-2123` (p.52), `:3504-3507` (p.79, scenario; `:3457-3458`, p.78), `:2064-2069` (p.51) | Substrate dependency (2); self-defense (5) | Absent |
| M5 (D) [corrected, W33] | (12), (5) | The RCPS rods' cooling circuit (a hazard missing from the hazards table) | no actor | The 1980 study [16], quoted as used in the safety analysis of the third stage: "Coolant vaporization in the RCPS cooling circuit gives rise to positive reactivity". The 1983 proposals included "the introduction of water film cooling in the channels of the RCPS"; none was implemented, nor the return to rods "without displacers but with water film cooling". No observer of the RCPS channel coolant is stated; its state on 26 April is not stated | A reactivity component inside the actuator's own channels with no stated observer | `insag-7-paged.txt:2426-2428`, `:2446-2447` (p.58), `:2195-2199` (p.54), `:2225-2229` (p.54) | A missing observer; continuous state verification (3) | Absent |
| M6 (D) [corrected, W34] | (12), (1) | Completion of a protection action (OC2, OC14) | no actor | The EPS was designed to compensate "the possible sticking of some of the emergency protection rods" (citing [19]), a hazard the design admitted; Article 3.3.29 required a protection action "normally carried out fully". No observer of the action's completion is stated; the record that the rods "stopped moving before they reached the lower limit stop switches" is a note in the chief reactor control engineer's operating log at 01:24 | The actuator's failure to complete reached a person's note | `insag-7-paged.txt:1954-1959` (p.49), `:2261-2263` (p.55, quoted), `:2820-2823` (p.65, log note) | Death signaling (6) | Absent: a record |
| M9 (E) [corrected, W37] | (9), (3), (5) | The yearly review of the field-stability regulations (§9) | B2 | §9, quoted: "The scientific managers of the plant must periodically (once a year) examine the specific regulations designed to maintain steady power density fields ... and, if necessary, change them to make them stricter", in agreement with the Scientific Manager and the Chief Design Engineer. "In the Commission's view" the terms are "rather loose concepts", defined in neither the Procedures nor the regulations. The grant runs toward stricter regulations only; no line shows the review performed or omitted | The maintenance of the known-good placed with an undefined B2 position on a yearly, sequential cycle; no reach on 26 April is stated | `insag-7-paged.txt:4022-4031` (p.89) | Continuous state verification (3) at the producing system; the +1 absent | Absent |
| M11 (D) [corrected, W39] | (12) | Fuel channel and weld integrity before rupture (OC8), watched by O13 and O14 | no actor | INSAG's pitfall: failure of channels or welds, "most probably near the core inlet", "would have been a cause of a sudden local increase in void fraction", among pitfalls any of which "could just as well have caused the initiating event"; INSAG asks "Which weakness ultimately caused the accident?". O13 samples "sequentially" with a detector "moved by a special dolly"; O14 watches gas humidity and temperature; "All the data are sent to the computer" (SKALA by inference, V38) and shown as "signals indicating divergences". No automatic action on either is stated; the reactor space pressure signal (O11) follows a rupture | INSAG's alternative initiator has no reflexive path stated: its observers are sequential or slow and end at a B2 position | `insag-7-paged.txt:866-868` (p.23), `:881-890` (p.24), `:5183-5188` (p.114), `:5193-5198` (p.115), `:2955-2959` (p.68) | Reflexive response (8); heartbeat (1) | Absent |

By letter, the surviving missed rows: T 1 (M1), R 1 (M2), D 4 (M3, M5, M6, M11), E 1 (M9).

### Coverage

Hazards with no observer, each filed: OC3 in S2, R1, D5, E1, T10; OC1 coefficients T16; power
level D6; distribution S4, T6, D4; subcooling D12, T14; OC2 T10, T7; OC4 T13, D9; OC5 T2, T4,
D11; OC6 T14; OC7 T3; OC8 and OC9 D10; OC10 T18; OC11 D13, T8, S3; OC12 D2, R2; OC13 T15;
OC14 T10. Removal paths RP1 to RP8 in T1 to T8, RP5 also E2. Continue-on-fault paths: C1 D1,
C2 D2, C3 D3, C4 D4, C5 D5, C6 D6, C7 D7, C8 T5, C9 T2, C10 T3, C11 T4, C12 T13, C13 D8, C14
T12, C15 D9, C16 R7 and T10, C17 R6 and E5, C18 and C19 R8.

Rows by letter in the S to E tables: S 3, T 16, R 10, I 0, D 16, E 7; 52 rows (T9 and T17
dropped; S1 moved from S to D). With the chain hunt's seven: S 3, T 17, R 11, I 0, D 20,
E 8; 59 rows.

---

## Part B. Chains

Three facts the chains share, each opened at its lines. No observer measured the ORM: "no
provision in the design of the RBMK reactor for a device to measure the ORM in terms of effective manual control rods",
`insag-7-paged.txt:3650-3651` (p.82, Annex I), and "no provisions for the ORM to be treated as
a parameter which would trigger the alarm system or the EPS", `insag-7-paged.txt:1923-1925`
(p.48). Every automatic reactor halt and the manual button end in the same 211 rods, where a
fully withdrawn rod's first motion from its upper limit stop inserts positive reactivity locally,
`insag-7-paged.txt:477-482` (p.14, INSAG), `:2172-2173`, `:2180-2185` (p.53, Annex I), with Annex II's
"could induce a negative reactivity insertion during the first second and then a reactivity
rise" for "a double peaked axial neutron flux distribution", `insag-7-paged.txt:5486-5489` (p.120) (DG23). And Annex I's hedged finding on the
state: "it would appear that ... as of 00:30 on 26 April 1986 it would have been impossible to
use the emergency protection system ... without damaging the core. This will have to be
confirmed by further studies", `insag-7-paged.txt:3305-3309` (p.75).

### Source-supported

#### X1. The blind margin: the one computed observer of the halt's worth was wrong, interrupted and printed away from the console, and the halt became the initiating event [corrected, W1, W2]

**Entry points.**
- Required, (12) a physical condition: xenon poisoning after the power fall, which had some
  ORM rods withdrawn to compensate, `insag-7-paged.txt:3230-3240` (p.73-74, the Commission's
  belief: "the Commission believes that the personnel brought the reactor into a state").
- Required, (10) and (5): PRIZMA's figure omitted "the rods of automatic regulators Nos 1, 2
  and 3 (a total of 12 rods)", found "unreliable at this time", about 07:00 on 25 April,
  `insag-7-paged.txt:3612-3620` (p.81); INSAG, "According to the record", the computer "became
  unreliable in the period in which the test took place", `insag-7-paged.txt:787-789` (p.21);
  the computer about 50 m from the console, `insag-7-paged.txt:552-559` (p.16, INSAG), its
  cycle DG25; "the results of the PRIZMA program are recorded only on printouts",
  `insag-7-paged.txt:2850` (p.66).
- Required, (1): the manual rods withdrawn, `insag-7-paged.txt:3230-3232` (p.73), and the
  EPS-5 button, `insag-7-paged.txt:3357-3358` (p.76).
- Optional, (3): the §9 authorization below 26 rods, required by
  `insag-7-paged.txt:3606-3610` (p.81); whether given is not stated (U25).
- One cause: any positive reactivity, "if positive reactivity had occurred for any reason,
  there could have been a power excursion", `insag-7-paged.txt:3348-3353` (p.76).

**Steps.**
1. The ORM "determined the ability of the reactor's EPS to perform its functions",
   `insag-7-paged.txt:4144-4148` (p.92), and had no instrument, alarm or trip,
   `insag-7-paged.txt:1923-1925` (p.48), `:3650-3651` (p.82). Its only machine computation was
   PRIZMA (O19), reporting to paper (R1).
2. [corrected, W1] PRIZMA's figure omitted twelve rods and was noted "unreliable", dated by
   Annex I to about 07:00 on 25 April; the procedures prescribed no action "in the event of
   unreliable calculation" or "complete failure of the PRIZMA code",
   `insag-7-paged.txt:3612-3623` (p.81) (S2, D1). INSAG places the unreliability of the computer SKALA in the
   period of the test, `insag-7-paged.txt:787-789` (p.21). SKALA restarted three times in the
   last hour, interrupting DREG; PRIZMA and RESTART had interruptions "caused by restarting of the system and the software characteristics", with no time given, `insag-7-paged.txt:2844-2849` (p.66)
   (D2). At 01:22:30 "No operating calculations were performed by the PRIZMA program", and the
   control room and SKALA personnel "did not know the calculated parameters, including the
   ORM", `insag-7-paged.txt:3251-3257` (p.74).
3. The remaining check was a person's: summing rod depths "from the measuring instruments"
   corrected for "the non-linearity of the graduation scale", or waiting "a few minutes" for
   the computer, with "it seems unreasonable to expect the personnel to treat this parameter
   as a directly controllable one", `insag-7-paged.txt:3650-3658` (p.82) (R1, SP12). INSAG:
   "it is likely that the operator did not know the value of the ORM during the critical part
   of the test", `insag-7-paged.txt:789-790` (p.21).
4. The state the blind check did not catch: an ORM of 15 rods or less "from approximately
   13:00 on 26 April until the time of the accident" (DG6), `insag-7-paged.txt:3939-3941`
   (p.88) (D5); INSAG, violated "by 01:00:00 on 26 April", `insag-7-paged.txt:785-787`
   (p.21); the manual rods withdrawn, `insag-7-paged.txt:3230-3237` (p.73-74) (T10). DREG
   recorded nine of 211 rod positions, `insag-7-paged.txt:2838-2840` (p.66).
5. In that state the prescribed response to the low ORM, "the reactor should be shut down
   immediately" (§9, quoted), `insag-7-paged.txt:4020-4021` (p.89) (PR1), and the planned end
   of the test, "the automatic power control system or the EPS-5 button" (§12, quoted),
   `insag-7-paged.txt:3636-3639` (p.81) (PR3), act through the same rods. Research [20] after
   the accident: at about 15 rods "less than" beta-effective of negative reactivity in the
   first six seconds; at "a non-regulation ORM of 7 control rods" positive for eight seconds,
   `insag-7-paged.txt:1976-1984` (p.49, in a paragraph that opens "There are grounds to
   think").
6. [corrected, W2] At 01:23:40 EPS-5 was pressed, `insag-7-paged.txt:3357-3358` (p.76); why
   is not established, `:3360` (p.76). Annex I's finding: "the event which initiated the accident was
   the pressing of the EPS-5 button when the RBMK-1000 reactor was operating at low power with
   a greater than permissible number of manual control rods withdrawn",
   `insag-7-paged.txt:3444-3447` (p.78); INSAG: "probably a decisive contributory factor",
   `insag-7-paged.txt:1293-1297` (p.33) (S1). The lateral ionization chamber signals, SP1's input to the power and rate protections, all appear, by
   calculations [17] and [20], "only 3 s after pressing of the EPS-5 button",
   `insag-7-paged.txt:3395-3397` (p.77) (H1, H2), into rods already moving. The level
   protection in force was EPS-1 at -1100 mm, `insag-7-paged.txt:3792-3799` (p.85); whether it
   fired is U19 (H4). That any other halt would have met the same fault rests on the hedged
   "it would appear", `insag-7-paged.txt:3305-3309` (p.75).

**Seam crossed.** From the computing hub (GR7: O19, SP3, SP4) through the B2 console into the
emergency protection group (GR1) and its actuator.

**Combined impact.** S1 alone is a property of the actuator in a given state; T10 and D5 alone
are a state with no instrument; S2, D1, D2 and R1 alone are a figure wrong by construction,
interrupted and printed away from the console. Joined, the state in which the halt was the
initiating event was reached and held from about 00:30 by Annex I's hedged statement
(`insag-7-paged.txt:3305-3309`, p.75), with the one computed check on it wrong, absent at
01:22:30 and with no prescribed action on its failure, so the prescribed responses PR1 and PR3
and the button H9 led into the initiating event. Reach: the whole core, then the plant, by
Annex I's finding and INSAG's "probably". Halt: absent; the halt was the path.

**Composition.** R1, S2, D1, D2 → (E1, optional) → D5, T10 → S1 (H9; PR1, PR3).

#### X2. The coefficient that turned a local insertion into a runaway [corrected, W3, W4, W5]

**Entry points.**
- Required, (5) by design decision with (12) burnup: "As the fuel burnt out, the designers
  allowed these absorbers to be removed ... This shifted the void coefficients significantly
  in the positive direction and also made them crucially sensitive to the extent of insertion
  of the control and protection rods", `insag-7-paged.txt:911-914` (p.24, INSAG); "There is no
  safety analysis of the void coefficient of reactivity in the RBMK-1000 design
  documentation", `insag-7-paged.txt:1866-1869` (p.47); the design documentation's own value
  is DG17.
- Required, the low ORM (D5): the 1980 study [16], quoted as "subsequently used in the
  analysis of the safety of the third stage", "A decrease in ORM causes a positive shift of all
  the coefficients of reactivity except the fuel temperature coefficient",
  `insag-7-paged.txt:2426-2435` (p.58) [corrected, W5]; INSAG, the ORM violation "led to
  increased void coefficients", `insag-7-paged.txt:1058-1062` (p.28).
- Required, low power and subcooling (D12): "a small power increase (for whatever reason)
  could result in a much higher increase in the volumetric steam quality in the lower part of
  the core", `insag-7-paged.txt:3273-3276` (p.74).
- One cause: the halt (S1), or any positive reactivity, `insag-7-paged.txt:3350-3353`
  (p.76).

**Steps.**
1. [corrected, W3] No observer of the coefficients is stated; "There were no calculations or
   experimental data" on the void coefficient "for power levels of less than 50%",
   `insag-7-paged.txt:1829-1832` (p.46) (T16). INSAG: "At the time of the accident, the void
   and power coefficients of reactivity were both positive", `insag-7-paged.txt:455-456`
   (p.13).
2. The low ORM shifted the coefficients further positive, `insag-7-paged.txt:2434-2435`
   (p.58, quoted [16]), `:1060-1062` (p.28).
3. [corrected, W4] The halt, by Annex I's interpretation ("This enables us to interpret"),
   decreased the flux in the upper layers and increased it in the lower sections where water
   columns were displaced, `insag-7-paged.txt:3372-3381` (p.76) (S1); Annex II, a possible
   negative first second (DG23), `insag-7-paged.txt:5486-5489` (p.120).
4. [corrected, W4] The feedback, Annex I's finding: "The initial reactivity increase resulted
   in a substantial growth in power since there was strong positive feedback between reactor
   reactivity and steam generation in the core", enhanced "by the low initial reactor power,
   by the thermal-hydraulic characteristics ... and by significant power density
   irregularities", `insag-7-paged.txt:4200-4205` (p.93). INSAG reporting others' work:
   "Detailed analysis indicated that the reactivity injected by the positive scram, when added
   to that provided by voids from increased boiling, was sufficient to generate a severe
   reactivity driven transient", `insag-7-paged.txt:842-845` (p.23).

**Seam crossed.** From the core's composition (OC1, a design-side state) through the actuator
(GR1) back into the core.

**Combined impact.** The halt's local insertion is bounded by the displaced water columns; the
unobserved coefficient is a number with no event. Joined, the one amplifies the other into
the destruction of the core, a join Annex I states as a finding and INSAG reports from
detailed analysis (`insag-7-paged.txt:4200-4205`, p.93; `:842-845`, p.23). S1's reach to the
floor is borrowed from this chain. Reach: the core at any unit in the same composition and
state; "All plants with RBMK-1000 reactors" operated with coefficients "obtained in
practice", `insag-7-paged.txt:1866-1869` (p.47). Halt: absent; no observer of the
coefficient, the ORM or the subcooling is stated.

**Composition.** T16, D5, D12 → S1.

#### X3. The known positive scram that never reached the console's procedures: links of people [corrected, W6, W7]

**Entry points.**
- Required, (5): "The Chief Design Engineer [22] and the Scientific Manager knew about this
  effect before the accident", discovered "in November/December 1983",
  `insag-7-paged.txt:2187-2190` (p.53); Annex I elsewhere says 1984,
  `insag-7-paged.txt:4105-4107` (p.91) (DG9).
- Required, (9): "the appropriate changes were not made to the Operating Procedures before
  1986 and no explanations were given to the personnel of plants with RBMK reactors",
  `insag-7-paged.txt:4138-4141` (p.92).
- Required, (1): the rods withdrawn on 26 April, `insag-7-paged.txt:3230-3232` (p.73).
- One cause: any halt (S1).

**Steps.**
1. The Physical Startup Commissions proposed limits on withdrawing manual rods to the upper
   stops, a rod redesign and water film cooling; "none of them were implemented before the
   accident", `insag-7-paged.txt:2195-2199` (p.54) (R7, C16). The Scientific Manager, quoted
   [24]: "Triggering of the EPS in this case may lead to the introduction of positive
   reactivity. It seems likely that a more thorough analysis will reveal other dangerous
   situations", `insag-7-paged.txt:2204-2206` (p.54).
2. The Chief Design Engineer's measure, at most 150 fully withdrawn rods with the rest
   inserted "by at least 0.5 m" (quoted [22]), `insag-7-paged.txt:2229-2234` (p.54), was
   announced to "all plants with RBMK reactors" as an intention,
   `insag-7-paged.txt:4107-4111` (p.91) (DG26); INSAG: "Such restrictions were never imposed
   and apparently the matter was forgotten", `insag-7-paged.txt:938-939` (p.25). By the
   Commission's finding the measure was itself a fault, permitting "an ORM of 3-5 manual
   control rods", `insag-7-paged.txt:2236-2242` (p.54) (PR12).
3. [corrected, W7] "In the Commission's opinion", the designers "did not inform the operating
   personnel accordingly of this fact, who if they had realized the danger might not have
   taken upon themselves the function", `insag-7-paged.txt:4098-4103` (p.91); "right up to the
   time of the accident, the personnel at units with RBMK reactors had no idea" that the ORM
   determined the EPS's ability, `insag-7-paged.txt:4143-4148` (p.92) (R9). Against it, on the
   consequences rather than the fact: "It is not clear whether or not the personnel realized
   the serious consequences of their actions", `insag-7-paged.txt:3241-3242` (p.74); INSAG,
   "Probably he was aware" the xenon was reducing the ORM, `insag-7-paged.txt:790-792` (p.21).
4. [corrected, W6] The rod state that followed: a distribution with "almost all control rods
   in the upper position", `insag-7-paged.txt:3264-3266` (p.74); INSAG: "the operator's
   actions in raising almost all the rods to extreme positions led to conflict with the
   simultaneous requirements to maintain shutdown capability",
   `insag-7-paged.txt:1013-1015` (p.27) (T10). The 150-rod restriction was never imposed; the
   limit in force was the ORM floor of §9, `insag-7-paged.txt:4020-4021` (p.89), and Annex I
   finds "a greater than permissible number of manual control rods withdrawn",
   `insag-7-paged.txt:3444-3447` (p.78).
5. The halt from those positions was the initiating event by Annex I's finding (S1),
   `insag-7-paged.txt:3444-3447` (p.78). INSAG on the conditions: "Apparently, there was a
   widespread view that the conditions under which the positive scram effect would be
   important would never occur. However, they did appear in almost every detail",
   `insag-7-paged.txt:855-858` (p.23).

**Seam crossed.** From the design organizations (5) through the authors of the operating
documentation (9) into the console (1) and the actuator (GR1).

**Combined impact.** R7 alone is a record held at design level; T10 alone is one unit's rod
state. Joined, a hazard known at the design level in 1983 or 1984 reached the plants as an
intention and, by INSAG, as information (DG26), while the change to the Procedures and the
explanation did not (`insag-7-paged.txt:4138-4141`, p.92), and the position that set the
actuator's state did so, in the Commission's opinion, without the fact that made it
dangerous. Reach: the operating regime at every RBMK unit, by one organizational omission
(`insag-7-paged.txt:4140-4145`, p.92). Halt: absent at every link; each link was a B2
position.

**Composition.** R7, C16, PR12 → R9 → T10 → S1.

#### X4. The margin's meaning: the console's known-good carried the wrong definition and a grant to lower it [corrected, W9]

**Entry points.**
- Required, (6) and (5): after Leningrad Unit 1 on 30 November 1975, which "resulted in
  radioactive releases", the commission understood the accident "was a result of the
  reactor's design characteristics, rather than personnel errors", though the personnel had
  operated "with an ORM well below 15 manual control rods"; the operators of RBMK-1000 plants
  "were not informed of the real causes", `insag-7-paged.txt:2409-2419` (p.58). INSAG: "the
  operating staff at Chernobyl were not aware of the nature and causes of the accident at
  Leningrad Unit 1", `insag-7-paged.txt:1288-1291` (p.33).
- Required, (9): the Procedures "unambiguously treat the ORM as a way of controlling the power
  density field", and §6.6.4's "incorrect indication" shows "the ORM was not treated as an
  operational safety limit", `insag-7-paged.txt:4070-4075` (p.90); §12 had no ORM requirement,
  `insag-7-paged.txt:3632-3634` (p.81); "The ORM is not included in the list of important
  parameters", `insag-7-paged.txt:3646-3648` (p.82).
- Optional, (3): the §9 grant below 26 rods, `insag-7-paged.txt:3608-3610` (p.81) (E1;
  U25); the quoted [44], three days on authorization and a floor of 10 rods,
  `insag-7-paged.txt:4078-4087` (p.90-91) (DG18; its scope is X11's design assumption).
- Required, (1) and (12): operation at 15 rods or less, `insag-7-paged.txt:3939-3941` (p.88)
  (D5).

**Steps.**
1. The precedent with the same precondition, an ORM "well below 15", was not delivered to the
   operating organizations, `insag-7-paged.txt:2416-2419` (p.58) (R8).
2. The console's known-good defined the ORM as a field-control parameter,
   `insag-7-paged.txt:4070-4071` (p.90); INSAG: the operators "were not aware that it had
   safety significance by virtue of the increase in positive void coefficient as the ORM was
   reduced", `insag-7-paged.txt:792-797` (p.21); they "apparently believed that as long as the
   lower limit on ORM (15 equivalent rods) was satisfied ... the demands of safety were met",
   `insag-7-paged.txt:919-926` (p.24-25) (R9).
3. The floor was 15 rods in §9 and 10 rods in the quoted [44], "equally contradictory",
   `insag-7-paged.txt:4077-4087` (p.90-91) (DG18), and one position could lower it,
   `insag-7-paged.txt:3608-3610` (p.81) (E1).
4. Operation below the floor followed: at 1500 MW "from about 07:00 to 13.30 on 25 April",
   a violation that "was not the cause of the accident and did not affect its consequences"
   (the source's "die"), `insag-7-paged.txt:3623-3628` (p.81); and again on 26 April,
   `insag-7-paged.txt:3939-3941` (p.88) (D5). The Commission "assumes that the personnel
   deliberately violated this requirement", `insag-7-paged.txt:3615-3616` (p.81).

**Seam crossed.** From the ministries and design organizations (6, 5) through the operating
documentation (9) and plant management (3) into the console (1).

**Combined impact.** [corrected, W9] R8 alone is a record delivered to no operating position;
R9 alone is a wrong definition; E1 alone is a grant. Joined, the one B2 observer of the ORM
held a definition under which operating below 15 was a field-control matter, without the
Leningrad causes, and under a floor two documents set differently and one signature could
lower: D5 was reached on 25 April and again on 26 April by a position that understood it as
something other than the loss of the EPS. The document does not state what delivering the
Leningrad causes would have changed. The chain gives X1's step 4 its reason. Reach: the
operating regime at the RBMK-1000 units run by those informed and not informed,
`insag-7-paged.txt:2417-2419` (p.58), `:4140-4145` (p.92). Halt: absent; no alarm, no trip,
`insag-7-paged.txt:1923-1925` (p.48).

**Composition.** R8 → R9, DG18, E1 → D5 (→ X1).

#### X5. The blind recovery: the fall at 00:28 and the rise by hand with no in-core observer [corrected, W10, W11]

**Entry points.**
- One cause, (12) or (1) [corrected, W10]: by the Commission's presumption, "For some unknown
  reason (possibly owing to a perturbation associated with the MFCC ...)" the local regulator
  was switched off, `insag-7-paged.txt:3711-3715` (p.83); by Annex I §I-4.6.1, the engineer
  "failed to eliminate fast enough the imbalance", `insag-7-paged.txt:3223-3228` (p.73);
  INSAG: "Recent reports suggest that there was no operator error as such",
  `insag-7-paged.txt:762-767` (p.21) (DG8).
- Required, (5) by design: the in-core systems "operated at power levels above 10% of
  nominal", `insag-7-paged.txt:524-525` (p.15); "no limitations were imposed on reactor
  operation at low power levels", `insag-7-paged.txt:2020-2021` (p.50).
- Required, (1): the recovery by hand, `insag-7-paged.txt:3732-3739` (p.83, presumption,
  "probably").
- Required, (9): §6.7 "authorized the power then to be restored to the rated value",
  `insag-7-paged.txt:3754-3757` (p.84).

**Steps.**
1. [corrected, W10] The power fell "from 500 MW to 0-30 MW (approximately)",
   `insag-7-paged.txt:3227-3228` (p.73), or "to 30 MW", `:3699-3700` (p.83), one body's two
   figures (DG27); the regulators left automatic regime and, under "continued
   'poisoning'", the engineer "probably reduced the set points" and then restored power "by
   manipulating the set points", `insag-7-paged.txt:3721-3739` (p.83, presumption) (D3, T11).
2. With LAC-LAP and the PPDDCS off at low power "there was no in-core instrumentation
   available"; the ex-core detectors could not indicate the distribution within the core nor
   "the average axial distribution of flux, since they were all located at the mid-plane",
   `insag-7-paged.txt:527-533` (p.15) (T6, D4, C4). INSAG names the state: the "non-uniformly
   poisoned reactor at low power", where "large field non-uniformities and high disturbances
   ... can occur", `insag-7-paged.txt:540-547` (p.15); Annex I, the operator "has to operate
   'blindly'", `insag-7-paged.txt:2013-2014` (p.50).
3. To hold power under poisoning "it proved necessary for some of the ORM rods to be
   withdrawn", `insag-7-paged.txt:3230-3232` (p.73) (T10).
4. [corrected, W11] The field: "a double peaked axial power density distribution over most of
   the core", attributed to a "partially burnt up core, almost all control rods in the upper
   position and xenon poisoning higher in the central parts", and "very unfavourable ... in
   combination with the design of the RCPS" by calculations [32] and [37],
   `insag-7-paged.txt:3262-3268` (p.74); INSAG: the halves "proceeding almost independently",
   `insag-7-paged.txt:572-575` (p.16). Annex I: the change between 00:28 and 00:33 "gave rise
   to a new xenon reshaping of the power density fields which the personnel were unable to
   control", and "No calculational studies have been made of the power density field dynamics
   from this time until the time of the accident", `insag-7-paged.txt:3771-3775` (p.84).
5. The positive scram's magnitude "depended on the spatial distribution of the power density
   and the operating regime", `insag-7-paged.txt:480-482` (p.14, INSAG). INSAG states the join:
   the conditions "arose owing to the previous operation at half power and the subsequent
   reduction to very low power levels", rendering the reactor "highly unstable",
   `insag-7-paged.txt:1105-1111` (p.29). Annex I: "The authors of this report believe that the
   drop in reactor power at 00:28 and subsequent power increase were largely to blame", with
   the caveat "It is impossible to draw a final conclusion" on "whether or not the personnel actions were correct", `insag-7-paged.txt:3769-3771` (p.84),
   `:3777-3781` (p.84).

**Seam crossed.** From the regulation group (GR2: O4, O5, O16) through the B2 console into the
core's field (OC1) and so into the actuator's effect (GR1).

**Combined impact.** D3 alone is a loss of automatic control; D4 alone is a blind spot at low
power; T10 alone is a rod state. Joined, the recovery from one fault was carried out by hand
in the regime the design left unobserved, and, by INSAG's statement and the Annex I authors'
belief, set the rod disposition and the field on which the halt's effect depended, with no
observer able to see either and no calculation of the field from 00:28 onward. The chain
gives X1 its T10 and X2 its "power density irregularities". Reach: the core at one unit per
occurrence; the regime is reachable at any power fall below 10% of nominal. Halt: absent;
§6.7 authorized the rise, `insag-7-paged.txt:3754-3757` (p.84).

**Composition.** D3 → T6, D4, C4 → T11, T10 → S1's magnitude.

#### X6. The ungated test state: a programme that, by Annex I, the regulations did not require the designers, the Scientific Manager or the regulator to approve, run at a power no document limited, into a thermal-hydraulic state no stated observer watched [corrected, W12, W13]

**Entry points.**
- Required, (4) and (3): NSR-04-74 and GSP-82 "did not require the plant managers to obtain
  approval for such tests" from the General Designer, the Chief Design Engineer, the
  Scientific Manager or the regulator, `insag-7-paged.txt:2600-2611` (p.61-62); Annex II: the
  Operating Procedures required clearance of devices not covered by the design and of changes
  with nuclear safety implications, `insag-7-paged.txt:5557-5568` (p.121) (DG14); whether
  cleared is U5 (E6, PR14). [corrected, W12] Annex I on the programme: "there is nothing wrong
  with the programme itself", and with the operating documentation it "provided sufficient
  basis for the safe testing of the planned operating conditions"; the causes lie "in the
  ignorance on the part of the programme developers of the characteristics of the behaviour
  of the RBMK-1000 reactor under the planned operating conditions",
  `insag-7-paged.txt:2613-2623` (p.62).
- Required, (3) and (2): the test power changed on the spot to 200 MW(th), "the test procedure
  was altered on an ad hoc basis", `insag-7-paged.txt:1096-1115` (p.29, INSAG) (T12, C14);
  the Commission holds the personnel "cannot be held to blame" for operating below 700 MW,
  `insag-7-paged.txt:3909-3910` (p.87).
- Required, (9) and (5): "neither the design documentation, the regulatory documentation nor
  the operating documentation prohibited operation of the unit at that power",
  `insag-7-paged.txt:3877-3887` (p.86-87) (D6).
- Optional, (4): §2.12, the seventh and eighth MCPs, `insag-7-paged.txt:3914-3916` (p.87)
  (T13, PR11); INSAG and Annex I differ on the effect (DG13), `insag-7-paged.txt:876-879`
  (p.24), `:3969-3973` (p.88).
- Required, (2) and (12): feedwater by hand and low power, `insag-7-paged.txt:3247-3249`
  (p.74) (T14).

**Steps.**
1. The test altered the protection and supply circuits: such tests "require interference in
   the protection and blocking system", `insag-7-paged.txt:2600-2603` (p.61); Annex II,
   "interventions on the normal protection and interlock systems",
   `insag-7-paged.txt:5553-5555` (p.121). By Annex I, the regulations required no approval from the designers, the Scientific Manager or the regulator; Annex II cites a clearance requirement in the Operating Procedures (E6, DG14).
2. The planned power could not be reached; "on the spot they modified the test conditions",
   `insag-7-paged.txt:1113-1115` (p.29); no document limited the new power (D6).
3. At that power, with eight pumps and low feedwater, the state: "a low level of subcooling of
   the coolant below the boiling temperature" and "a correspondingly low steam quality",
   `insag-7-paged.txt:3270-3273` (p.74); INSAG: "may not have been subcooled at all",
   `insag-7-paged.txt:656-659` (p.18) (D12). The Commission "believes" the susceptibility was
   created "primarily as a result of the low reactor power level",
   `insag-7-paged.txt:3279-3283` (p.74).
4. [corrected, W13] No observer of subcooling or steam quality is stated; the inlet
   temperature appears only as a Table II-III value, `insag-7-paged.txt:5650-5654` (p.123);
   Annex II's running text says "slightly below boiling point",
   `insag-7-paged.txt:5570-5573` (p.121).
5. Both Soviet bodies tie the thermal-hydraulics of the test regime to the scale: "Both these
   factors proved to be directly related to the scale of effects manifested during the tests",
   `insag-7-paged.txt:2625-2629` (p.62), where the factors are "a thermal-hydraulic
   characteristic of the planned mode"; "Both the above factors turned out to have a direct
   bearing on the scale" (the source's "die"), `insag-7-paged.txt:5570-5574` (p.121). INSAG:
   "Such a mode of operation in itself could have led to a destructive accident",
   `insag-7-paged.txt:1131-1134` (p.29).

**Seam crossed.** From the approvals (positions 3, 4, 7) through the programme into the coolant
circuit (OC4, OC6) and the core (OC1).

**Combined impact.** E6 alone is a missing external check; T12 alone is a deviation; D12 alone
is a state with no stated observer. Joined, a programme whose planned mode carried the
thermal-hydraulic characteristics both Soviet bodies tie to the scale, prepared by authors
Annex I finds ignorant of the reactor's behaviour in that mode, with no external approval
required, was carried to a lower power no document limited, into that state. INSAG states the
gate's part: a state "not specified by procedures or investigated by an independent safety
body", `insag-7-paged.txt:1277-1279` (p.33). Annex I's own view that the programme and the
documentation "provided sufficient basis for the safe testing of the planned operating
conditions" stands beside it, `insag-7-paged.txt:2618-2620` (p.62). Reach: the core at one
unit; the absent requirement reached every plant under the same regulations,
`insag-7-paged.txt:2609-2611` (p.62). The T13 link is disputed (DG13) and the chain does not
need it. Halt: absent; "the operating staff did not stop and think",
`insag-7-paged.txt:1113-1115` (p.29).

**Composition.** E6, PR14 → T12, C14, D6 → (T13) T14 → D12 (→ X2).

#### X7. The report with no list: the unperformed check at the top let the operating documentation be wrong at the bottom [corrected, W14, W15]

**Entry points.**
- Required, (5): Article 3.1.6 of NSR-04-74, violations "to be included in this part" and
  "authorized by the USSR State Committee for the Supervision of Nuclear Power Safety at the
  technical design stage", `insag-7-paged.txt:1719-1725` (p.44, quoted) (PR15); "No list of
  violations ... was given in any of the aforementioned design documents. Furthermore, no
  analysis was made of the acceptability of these violations and they were not authorized",
  `insag-7-paged.txt:1737-1741` (p.44) (R6).
- Required, (7): the approvals by three state committees in 1975,
  `insag-7-paged.txt:1754-1759` (p.45); the approving committee "Until 1984" a division of a
  ministry, `insag-7-paged.txt:1761-1762` (p.45) (DG22) (E5).
- Required, (9): the Operating Procedures.

**Steps.**
1. [corrected, W14] The check prescribed to the designers was not performed, and three
   committees approved the report that carried no list (PR15, R6, E5). INSAG: "The basic
   design of the RBMK reactors was approved despite the lack of conformity to many of the
   USSR's design requirements", `insag-7-paged.txt:1219-1220` (p.31).
2. The Commission's first consequence: "Since officially there were no violations, no
   technical and organizational measures were developed to compensate for them",
   `insag-7-paged.txt:1750-1752` (p.45) (C17).
3. Its second, stated as its conclusion: since the report "did not contain a list of the
   violations ... or measures to compensate for those violations, the operating documentation
   used by the personnel to run the plant could not possibly correspond to the actual
   parameters of the reactor", `insag-7-paged.txt:1764-1769` (p.45).
4. [corrected, W15] The operating documentation as found: the ORM outside the list of
   important parameters, `insag-7-paged.txt:3646-3648` (p.82); no ORM requirement in §12,
   `:3632-3634` (p.81); the floors "equally contradictory", `:4077-4087` (p.90-91); the EPS's
   function transferred to the personnel "with a deep faith",
   `insag-7-paged.txt:4160-4163` (p.92) (R9, E4, PR1 to PR5). The link from step 3 to each
   defect is the Commission's general conclusion, not a line per defect.

**Seam crossed.** From the regulator and the design organizations (7, 5) through the operating
documentation (9) into the console (1).

**Combined impact.** [corrected, W15] R6 alone is a record whose required content was absent;
E5 alone is an approval. Joined, by the Commission's own two statements, the absent list left
no compensating measures and made operating documentation that could not correspond to the
reactor, for the "at least two weak points" the quoted [14] names, the void coefficient and
an EPS that, "when the operating instructions were violated", "did not shut down the reactor fast enough, and in some cases could even briefly increase its power",
`insag-7-paged.txt:1741-1748` (p.44-45). The join lands on the operating documentation of the
units the report covered, the second stage, Units 3 and 4, `insag-7-paged.txt:1727-1729`
(p.44), and through the same approvals on the design, not on the design alone. X3 and X4 are
its two specific knowledge paths. Halt: absent; nothing is stated to have observed the absent
list (PR15).

**Composition.** PR15, R6, E5 → C17 → R9, E4 (→ X3, X4).

### Conditional on an unconfirmed item

#### X8. The prescribed path from rated power: EPS-3, the hold at 200-300 MW(th), and the next halt, with no person in it [corrected, W16]

Conditional on the Commission's hypothetical, stated as "might have occurred" and "We only
need to assume a perfectly possible situation", not as having occurred,
`insag-7-paged.txt:3897-3907` (p.87).

**Entry points.**
- One cause, (12): "automatic power reduction in the EPS-3 design mode, or remotely in the
  event of abnormalities in the power supply system (frequency variations)",
  `insag-7-paged.txt:3890-3894` (p.87); the "frequency variations" go with the remote reduction, and EPS-3's triggers are U21.
- Required, (5): the design principle, "Under all other accident conditions, the power is
  reduced in a controlled manner to the specified levels", `insag-7-paged.txt:2278-2281`
  (p.55, quoted [19]) (D7, C7), against EPS-5's complete shutdown on its own signals (DG24).
- Required, (9): §11.4, the reduction "to the level corresponding to the unit's internal
  consumption (200-300 MW(th))" with "no limitation on the period",
  `insag-7-paged.txt:3890-3896` (p.87) (D14, PR4).
- One cause: the next halt, "whether automatic or remote", `insag-7-paged.txt:3905-3906`
  (p.87).

**Steps.**
1. EPS-3 reduces rather than stops (O21, D7).
2. [corrected, W16] Dropped as a link; kept as a note. The hold lies below 10% of nominal: 3200
   MW(th) in Table II-I, `insag-7-paged.txt:5209` (p.115), agrees with the quoted §12's "160
   MW(th) (5% of nominal power)", `insag-7-paged.txt:3637-3638` (p.81), so 10% is 320 MW(th);
   LAC-LAP controlled "at power levels greater than 10%", `insag-7-paged.txt:2004-2007`
   (p.50). The Commission's Note does not join the blindness (T6, D4) to its path; it is a
   parallel gap.
3. The Commission's Note: "approximately one hour after triggering of EPS-3 the ORM could have
   fallen to less than 15 manual control rods at a reactor power of 200-300 MW(th)",
   `insag-7-paged.txt:3903-3905` (p.87). No observer of the ORM, `insag-7-paged.txt:1923-1925`
   (p.48) (D5).
4. "any further action, whether automatic or remote, to shut down the reactor could have led
   to a similar repetition of the events of 26 April 1986", `insag-7-paged.txt:3905-3907`
   (p.87) (S1).

**Seam crossed.** From the graded protections (O21, GR1) through the operating procedure (9)
back to the actuator (GR1).

**Combined impact.** D14 as filed carries the Commission's sentence; the chain joins it to D7,
the design principle that makes the hold state exist, so the whole path from rated power to
the state of 26 April runs through design and prescribed responses, "without any
intervention on the part of the personnel", `insag-7-paged.txt:3898-3900` (p.87). D7 alone is
a reduction that keeps running; D14 alone a hold with no time limit; D5 alone an unobserved
margin; joined, they reach the core with no B2 act. Reach [corrected, W16]: the units run
under the Operating Procedures [40], "for Units 3 and 4", `insag-7-paged.txt:4631-4632`
(p.101), after an EPS-3 actuation or a remote reduction on a grid frequency variation, `insag-7-paged.txt:3892-3894` (p.87); other units' procedures
are not stated. The unconfirmed item: the hypothetical itself. Halt: the halt is the path.

**Composition.** D7, C7 → O21, D14, PR4 → D5 → S1.

#### X10. Pressure reduction at the regulatory ORM: a path to the floor that needs neither the low ORM nor the rod positions [corrected, W18]

Conditional on Annex I's "might", in a Note, `insag-7-paged.txt:3846-3851` (p.86).

**Entry points.**
- Required, (5): "the design was such that at a turbine power of less than 100 MW(e) the
  reactor was left without any protection system to guard against pressure reduction",
  `insag-7-paged.txt:3846-3848` (p.86) (D11).
- Required, (5) and (12): the positive void coefficient (T16), `insag-7-paged.txt:455-456`
  (p.13).
- One cause, (12): "the opening or non-closing of the main pressure relief valves, or the
  valves of the fast acting steam dump system, pipe rupture, etc.",
  `insag-7-paged.txt:3849-3851` (p.86). The fast acting dump's triggering is listed among the
  "normal technical processes" of the power rise, `insag-7-paged.txt:3244-3249` (p.74) (O12).

**Steps.**
1. Below 100 MW(e) the only pressure protection (O8) "was designed to stop the turbine" and
   was not "a thermal parameter reactor protection system", `insag-7-paged.txt:3842-3845`
   (p.86).
2. A pressure reduction raises the void; with the coefficient positive and no observer of it
   stated (T16), "At the actual" void coefficient "it might have resulted in a reactor runaway
   even at the regulatory ORM", `insag-7-paged.txt:3848-3849` (p.86).

**Seam crossed.** From the drum protections (GR3) through the circuit's overpressure relief
(O12, GR4) into the core (OC1).

**Combined impact.** D11 alone is an absent protection; T16 alone a coefficient with no event.
Joined, a pressure reduction from a valve's opening or failure to close reaches a runaway
"even at the regulatory ORM", needing neither D5 nor T10, so the path stands outside the
state of 26 April. The document records no runaway from this path: "During the rundown of
turbogenerator No. 8 there was no increase in reactor power", `insag-7-paged.txt:3332-3333`
(p.75). Reach [corrected, W18]: Unit 4 below 100 MW(e), where "the design was such"; whether
other units had the same arrangement is not stated. The unconfirmed item: the Commission's
"might". Halt: absent for the reactor.

**Composition.** D11, T16 → (O12's valves as the cause) → the core; T4 excluded (see Part C).

### Design assumption

#### X9. The test and the full drop the quoted design ties to loss of plant power [corrected, W17; reclassed from conditional]

Needs a state the document does not show existed: total loss of power to the plant during
the test, with the rods in T10's positions. The lines show four MCPs on the external source,
`insag-7-paged.txt:651-653` (p.18), and a programme titled "in a Rundown Regime with the Plant
Internal Load", `insag-7-paged.txt:4634-4635` (p.101) (U23). What the drive supply loss did to
the rods is U4.

**Entry points.**
- Required, (5): "A complete reactor shutdown by dropping all the RCPS rods is foreseen only
  for total loss of power to the plant", `insag-7-paged.txt:2278-2280` (p.55, quoted [19])
  (D13, H8); against it, EPS-5's "complete shutdown of the reactor" on drum level,
  `insag-7-paged.txt:3812-3813` (p.85, quoted [43]) (DG24).
- Required, (4): the test's aim, cooldown "in the event of a total power loss",
  `insag-7-paged.txt:5534-5535` (p.121, Annex II); the design requirement it exercised,
  `insag-7-paged.txt:2578-2582` (p.61).
- Required, the rod state (T10).

**Steps.**
1. [corrected, W17] The quoted design ties its full drop to loss of plant power; it is not the
   only full halt in the document (DG24).
2. The test did not reproduce that condition as far as the document shows: four MCPs on the
   external source, `insag-7-paged.txt:651-653` (p.18); the quoted Smolensk report speaks of
   loss "for the unit's internal requirements", `insag-7-paged.txt:2574-2576` (p.61) (U23).
3. [corrected, W17] Had the condition arisen, the drop would have started from T10's
   positions with no person in it. Whether "dropping all the RCPS rods" differs from EPS-5's
   driven insertion is not stated (DG24), so that it would have been S1 is an inference, as in
   D13. The 'No voltage, 48 V' signal at 01:23:49 and the rods that "stopped moving before
   they reached the lower limit stop switches" leave the supply's effect unstated,
   `insag-7-paged.txt:2815-2823` (p.65) (U4, O20).

**Seam crossed.** From the electrical supply (OC11) through the design's halt logic into the
actuator (GR1).

**Combined impact.** If the state existed, a test that, by Annex I, the regulations did not require the plant managers to have the designers, the Scientific Manager or the regulator
approve (`insag-7-paged.txt:2609-2611`, p.62) would have commanded the quoted design's full
drop in the state where, by inference, the drop was the fault, with no person in the loop:
more than D13, which holds the inference without the test that would exercise it. Until the
state is shown, the chain reaches no further than D13 as filed.

**Composition.** E6 → D13, H8 → T10 → S1; design assumption on the test's power condition; U23,
U4.

#### X11. The ten-rod floor: an authorized regime below the shutdown floor [corrected, W19]

Needs a state the document does not show existed: that the Technical Safety Report [44]
governed Unit 4. The document places Units 3 and 4 in the second stage, whose report is [11],
`insag-7-paged.txt:1727-1732` (p.44), and names [44] the third stage's,
`insag-7-paged.txt:4646-4649` (p.101).

**Entry points.**
- Required, (5) [corrected, W19]: the quoted [44], "On the authorization of the Chief Plant
  Engineer, a reactor may be allowed to operate with an ORM below the minimum value, but for
  no longer than three days. Operation of the unit is not permitted at an ORM of less than 10
  rods", `insag-7-paged.txt:4078-4087` (p.90-91), approved by the Chief Design Engineer's and the Scientific Manager's institutes,
  `insag-7-paged.txt:4646-4649` (p.101) (DG18).
- Required, (3): the authorization (E1).
- One cause: any halt (S1).

**Steps.**
1. Research [20]: at about 15 rods "less than" beta-effective of negative reactivity in six
   seconds; at 7 rods positive for eight seconds, `insag-7-paged.txt:1978-1984` (p.49).
2. [corrected, W19] A floor of 10 rods for three days places the authorized regime below §9's
   shutdown point of 15 rods, `insag-7-paged.txt:4020-4021` (p.89), and between the research's
   15-rod and 7-rod cases, for which no figure at 10 rods is given; where the regime sits
   against S1's condition is not settled by the document.
3. The Commission calls the two floors "equally contradictory", `insag-7-paged.txt:4077`
   (p.90).

**Seam crossed.** From the design documentation (5) through plant management (3) into the
actuator's worth (GR1).

**Combined impact.** If [44] governed Unit 4, a design document authorized, "for no longer
than three days" on one signature, operation below the ORM at which §9 required immediate shutdown and
at which research [20] finds the EPS inserts "less than" beta-effective in its first six
seconds: E1 joined to D5 and S1, beyond E1's grant alone. The chain is X4's [44] branch,
recorded separately because its state is a design assumption.

**Composition.** DG18, E1 → D5 → S1; design assumption on [44]'s scope.

---

## Part C. Rejected chains

Each reason checked at its lines; each holds.

- **T3 with S1 (the disabled two-turbine trip).** Parallel, not a chain: the
  protection and its prescribed disabling end in the same actuator from the same positions.
  INSAG: "the occurrence of this trip might well have caused the destruction of the reactor at
  the time of turbine trip rather than shortly afterwards", `insag-7-paged.txt:1082-1084`
  (p.28); the disabling under [42] §1, `insag-7-paged.txt:3866-3871` (p.86). Its absence moved
  the halt by about 36 s, arithmetic on two Annex I running-text times, the stop valves at
  01:23:04 and the button at 01:23:40, `insag-7-paged.txt:3298` (p.75), `:3357-3358` (p.76),
  not what the halt reached. [qualifier restored, W20]
- **T5 with D9 and D10.** Two independent reasons for one absence on 26 April:
  "no DBA signal ... was given because the point at which the MFCC ruptured was not in the
  reinforced leaktight compartments where the sensors are placed, but in the core itself",
  `insag-7-paged.txt:3514-3517` (p.79, the scenario, "no longer based on calculations",
  `:3457-3458`, p.78); Annex I: switching off the ECCS "did not affect the initiation and
  development of the accident, since ... no signals for the automatic switching on of the
  ECCS were recorded", `insag-7-paged.txt:3683-3687` (p.82). D10 is the barrier's exhaustion
  by the same rupture, `insag-7-paged.txt:697-703` (p.19). T5's row already carries the reach
  for any DBA inside the sensed volume. Parallel effects of one fault.
- **T1 and E3 with R3 and R5, then R10.** The document records no jumper
  removal on 25-26 April; the removals it records were by slide valves, keys, a set point
  selection, [42] §1 and a mode transfer, `insag-7-paged.txt:3673-3676` (p.82), `:3795-3797`,
  `:3831-3833` (p.85), `:3867-3871` (p.86), `:3223-3228` (p.73). The chain's first step did
  not occur, and T1 already records that nothing records a removal. Whether [1]'s statement
  that "all the thermal parameter reactor protection systems were switched off" arose from the
  thin record is not stated, `insag-7-paged.txt:3800-3802` (p.85).
- **R2, R4 and R5 with R10.** The join reaches only the record: the 1986
  explanation "drawn from an analytical model 'normalized' to sparse and inaccurate plant
  data", `insag-7-paged.txt:372-375` (p.11), and its effect on INSAG-1's weight,
  `insag-7-paged.txt:1319-1322` (p.34). Nothing in the unit of April 1986 is reached and no
  position gained what it lacked.
- **T4 as a link of X10.** The pressure protection "was designed to stop the
  turbine", `insag-7-paged.txt:3842-3845` (p.86); its set point acts on the turbine and runs
  parallel to D11, the reactor's absence of any pressure-reduction protection below 100
  MW(e). X10 stands without it.
- **The design decision [43] as an observer-to-observer edge (O21 into O7) closed by a manual
  key.** Already T2 and PR7: "Automatic reswitching of the set points of EPS-1 and EPS-5 ...
  is not permitted", `insag-7-paged.txt:3807-3817` (p.85, quoted [43]). Nothing beyond T2.
- **The ECCS isolated with no gate, the half-power hold and the xenon state.** INSAG ties the
  test conditions to "the previous operation at half power and the subsequent reduction to
  very low power levels", `insag-7-paged.txt:1105-1107` (p.29), and the 11 hours at half power
  to the ECCS being blocked, `insag-7-paged.txt:738-743` (p.20), but never the one to the
  other. Rejected for want of a line.
- **The 'One overcompensation upwards' signal (D8) into the button.** The automatic rods
  "could not move into the core" from 01:19:57 until 01:23:30, `insag-7-paged.txt:3332-3338`
  (p.75); "The Commission was unable to establish why the button was pressed",
  `insag-7-paged.txt:3360` (p.76). The link is not stated.
- **The power and rate protections after EPS-5 into the jammed actuator.** Their signals
  appear by calculation "only 3 s after pressing of the EPS-5 button",
  `insag-7-paged.txt:3395-3397` (p.77), into rods already moving and, by the scenario, then
  jammed, `insag-7-paged.txt:3504-3507` (p.79). Two effects of one fault on one actuator.

---

## Part D. Impact across the deployment

**The rule, stated once.** Rank risks by what a position gains times how many units one act
or condition reaches, and how far toward the public-safety floor (part of the core, the whole
core, the plant, the public), with nothing positioned to notice. A tie goes to the position
that needs no privileged act. Availability is not ranked (the availability claims below). The reach "the
public" rests on the release paths the document confirms, `insag-7-paged.txt:2343-2351`
(p.56-57), `:697-703` (p.19); its magnitude is U1. [corrected, V2]

1. **(5) The design organizations and their documents, with (7) and (6) approving.** One
   design decision reaches every RBMK unit: the rod design with its displacers on "all RBMK
   reactors", `insag-7-paged.txt:472-473` (p.14), and the coefficients with which "All plants
   with RBMK-1000 reactors therefore operated", `insag-7-paged.txt:1867-1868` (p.47); the
   controlled-reduction principle (D7); the signal list without the ORM or low power,
   `insag-7-paged.txt:2097-2101` (p.52); the manual reswitch (T2); the EPS's function handed
   to the personnel (E4); the hazards known and not carried into the operating documentation or explained to the personnel (R7, R8; DG26) [corrected, K2]. Nothing positioned
   to notice: the Technical Safety Report carried no list of violations and three committees
   approved it, `insag-7-paged.txt:1737-1759` (p.44-45) (R6, E5). Rows: S1 (design side), D7,
   T10 (the limit never imposed), T16, T18, T2 (design side), E4, E5, R6, R7, R8, R9.
2. **(12) A physical condition in the low-ORM, low-power state, at one unit per occurrence.**
   Any trip, or any positive reactivity: "if positive reactivity had occurred for any
   reason, there could have been a power excursion under conditions in which the reactor's
   EPS would be unable to perform its functions", `insag-7-paged.txt:3350-3353` (p.76); the
   halt is S1; more than two simultaneous ruptures lift the cover plate (D10); the localization system
   vents by design (T18). Reach: the public at that plant. Nothing positioned to notice:
   `insag-7-paged.txt:1921-1925` (p.48), `:3650-3651` (p.82). Needs no privileged act only on
   the Commission's hypothetical that the state "might have occurred without any
   intervention on the part of the personnel", `insag-7-paged.txt:3897-3907` (p.87) (D14):
   conditional on an unconfirmed item. On 26 April the state was reached through acts the
   Commission calls violations, `insag-7-paged.txt:3939-3941` (p.88), `:4193-4198` (p.93). Rows:
   S1, S4, D5, D9, D10, D11, D12, D13, D14, T18.
3. **(1) The senior reactor control engineer at the console.** One hand reaches the EPS-5
   button (S1), the rod positions (T10), the set points (T11), feedwater (T14). Reach: the
   public at one plant through the path of rank 2. Nothing positioned to notice: no device
   measured the ORM "in terms of effective manual control rods", the plant computer calculating it on instruction in "a few minutes", `insag-7-paged.txt:3650-3655` (p.82); INSAG's corresponding statement is
   conditional, "If, as has been stated since, there was no effective facility in the control
   room for informing the operators of this parameter", `insag-7-paged.txt:998-1000` (p.27)
   [corrected, V14]. Privileged; ties rank 2 on reach and loses the tie. Rows: S1, T10, T11,
   T14, D3, D4, D5; T2 as the position that used the path.
4. **(8) with (9): a person at the terminals, keys and straps, under the documents that
   permit it.** One act removes any trip or alarm (T1) or a named protection (T2 to T5), with
   no record, `insag-7-paged.txt:585-589` (p.16), `:3794-3795` (p.85); the grant is E3. Reach:
   whatever the removed protection guards; a removal needs a fault to follow it. Rows: T1,
   T2, T3, T4, T5, T7, T8, E3.
5. **(3) The Chief Engineer and plant management.** Authorizations that lower the ORM floor
   (E1) and remove the ECCS (E2, T5); the on-the-spot change of test power (T12); the test's
   clearance (E6). Whether the authorization below 26 rods was sought or given on 25 April is not stated (U25). [corrected, K4] Rows: E1, E2, E6, T5, T12, D6.
6. **(4) The test programme's authors.** ECCS isolation (T5), the eighth pump (T13), the DBA
   button and oscilloscope (S3), a power the plant did not reach (T12). Rows: S3, T5, T12,
   T13, D12, E6.
7. **(2) The shift and its supervisors.** The rundown order, `insag-7-paged.txt:3296-3298`
   (p.75), feedwater by hand (T14), the pumps (T13), the logs (R3). Rows: T12, T13, T14, T15,
   R3, D6.
8. **(10) The SKALA system personnel.** The computation and what it reported. Rows: S2, R1,
   D1.
9. **(11) The reader of the records.** The record only. Rows: R4, R5, R10.

**The chain hunt's rows and the chains.** Under Risks, stated first, each row the chain
hunt found sits under every rank whose position appears in its entry column, and each
chain under every rank whose position is among its required or one-cause entry points;
optional entries do not place a chain. M2, M3, M5 and M9 sit at rank 1; M3, M5, M6 and M11
at rank 2; M6 at rank 3; M9 at ranks 4 and 5; M1 at rank 7. Every chain needs the design
position (5), so all eleven sit at rank 1. Ordered among themselves by the same rule, on
the reach each chain states:

1. X2: the core at any unit in the same composition and state; "All plants with RBMK-1000
   reactors therefore operated" with coefficient values "obtained in practice",
   `insag-7-paged.txt:1867-1868` (p.47).
2. X3: the operating regime at every RBMK unit, by one organizational omission,
   `insag-7-paged.txt:4140-4145` (p.92).
3. X4: the operating regime at the RBMK-1000 units run by those informed and not informed,
   `insag-7-paged.txt:2417-2419` (p.58), `:4140-4145` (p.92).
4. X8: the units run under the Operating Procedures [40], "for Units 3 and 4",
   `insag-7-paged.txt:4631-4632` (p.101), reaching the core with no B2 act. Conditional on
   an unconfirmed item, the Commission's hypothetical, `insag-7-paged.txt:3897-3907` (p.87).
5. X7: the operating documentation of the second stage, Units 3 and 4,
   `insag-7-paged.txt:1727-1729` (p.44), and through the same approvals the design; it
   reaches the documentation, where X8 reaches the core.
6. X1: the whole core, then the plant, at one unit, by Annex I's finding and INSAG's
   "probably", `insag-7-paged.txt:3444-3447` (p.78), `:1293-1297` (p.33).
7. X10: Unit 4 below 100 MW(e), where "the design was such", reaching a runaway with no
   B2 act. Conditional on an unconfirmed item, Annex I's "might",
   `insag-7-paged.txt:3846-3851` (p.86).
8. X5 and X6, tied: the core at one unit, each through privileged acts. X5's regime is
   reachable at any power fall below 10% of nominal; X6's absent approval requirement
   reached every plant under the same regulations, `insag-7-paged.txt:2609-2611` (p.62).
9. X9 and X11, design assumptions, listed last. X9 reaches no further than D13 until the
   test's power condition is shown (U23); where X11's regime sits against S1's condition is
   not settled by the document.

---

## Part E. Seams not followed: the delegation boundaries

Listed, not followed. Each is a component or body the system hands work to; the documents
marked are not contained in the source.

- **The operating personnel**: the EPS's function "when the ORM reaches a critical value",
  `insag-7-paged.txt:4160-4163` (p.92); the level reswitch by key, `insag-7-paged.txt:3814-3817`
  (p.85); low-power control by "experience and intuition", `insag-7-paged.txt:535-537` (p.15);
  the ORM by summing rod depths or waiting for the computer, `insag-7-paged.txt:3650-3655` (p.82).
- **The Operating Procedures [40]** (Soyuzatomehnergo, 1984), `insag-7-paged.txt:4631-4632`
  (p.101): §9, §6.2, §6.6.4, §12, §11.4, §6.7, §5.8, §2.10.5, §8.9.1(a); not contained.
- **The Reswitching Procedures [42]** (the plant), `insag-7-paged.txt:4638-4639` (p.101):
  §§1, 2, 9, 12; not contained.
- **The RCPS design documentation [19]**, `insag-7-paged.txt:4546-4548` (p.100): the EPS's
  principle, signal list, reactivity effects, rod drives on loss of supply, LEP, EPS-1 to
  EPS-3; not contained (U3, U4, U6, U21, U23).
- **The design decision [43]** (1983), `insag-7-paged.txt:4641-4644` (p.101), quoted at
  `:3807-3817` (p.85); not contained.
- **The test programme [41]**, `insag-7-paged.txt:4634-4636` (p.101): §2.12, §2.15, the planned
  power, the DBA button, the oscilloscope; not contained (U5).
- **The Technical Safety Reports [11] and [44]** and design documentation [10], [12], [13],
  `insag-7-paged.txt:4509-4522` (p.99), `:4646-4649` (p.101); [44] is the third stage's report
  (V40); not contained. [corrected, K6] The document places Units 3 and 4 in the second stage, whose Technical Safety Report is [11], and names [44] the third stage's, approved by the Chief Design Engineer's and the Scientific Manager's institutes, `insag-7-paged.txt:1727-1732` (p.44), `:4646-4649` (p.101).
- **The regulations NSR-04-74 [8], GSP-73 [9], GSP-82**, `insag-7-paged.txt:4503-4507` (p.99),
  `:2551-2552` (p.60); not contained.
- **The regulator and the approving committees**: authorization of violations,
  `insag-7-paged.txt:1722-1725` (p.44, quoted); the approvals of 1975, `insag-7-paged.txt:1754-1759`
  (p.45).
- **The ministries**: "the most important general decisions concerning a plant as a whole",
  `insag-7-paged.txt:4401-4403` (p.97); clearance by "the Chief Design Engineer, the Scientific
  Administrator, the General Designer and the regulatory body", `insag-7-paged.txt:4417-4421`
  (p.97).
- **The grid**: external supply for four MCPs, `insag-7-paged.txt:651-653` (p.18); frequency
  variations as the condition of §11.4's remote reduction, beside automatic reduction in the EPS-3 design mode, `insag-7-paged.txt:3893-3894` (p.87).
- **The SKALA computer and its programs**, `insag-7-paged.txt:2828-2850` (p.66); "the power of
  the V-3M type computer" sets the cycle, `insag-7-paged.txt:2830-2831` (p.66).
- **TG8's rundown unit and diesel generator No. 6**: the design's supply to the third ECCS
  subsystem's pumps, `insag-7-paged.txt:2578-2581` (p.61), `:2885-2888` (p.67).
- **The test oscilloscope** (SP8), `insag-7-paged.txt:2854-2866` (p.66).
- **The post-accident computations**: PRIZMA-ANALOG at Smolensk, `insag-7-paged.txt:3253-3255`
  (p.74); the models [17], [20], [21], [28], [35], `insag-7-paged.txt:3384-3398` (p.76-77),
  `:5997-6008` (p.131); the Japanese enthalpy data [35], `insag-7-paged.txt:3419-3430` (p.77).
- **The USSR reports [1] and [33] and INSAG-1**: the first account,
  `insag-7-paged.txt:372-375` (p.11), `:3072-3089` (p.70-71); not contained.
- **Research [20]** on the EPS's reactivity by ORM, `insag-7-paged.txt:1976-1984` (p.49); not
  contained.

**The integration surface.** Seventeen delegation boundaries, each listed above with its
lines, and none followed: nine documents the source quotes or cites but does not contain
(the Operating Procedures [40], the Reswitching Procedures [42], the RCPS design
documentation [19], the design decision [43], the test programme [41], the Technical
Safety Reports [11] and [44] with the design documentation [10], [12] and [13], the
regulations NSR-04-74, GSP-73 and GSP-82, the USSR reports [1] and [33] with INSAG-1, and
research [20]); three positions of people (the operating personnel, the regulator and the
approving committees, the ministries); four pieces of equipment and supply the unit hands
work to (the grid, the SKALA computer and its programs, TG8's rundown unit with diesel
generator No. 6, the test oscilloscope); and one body of analysis made after the accident
(the post-accident computations).

---

## Part F. Entry-point index

Every row and chain mapped to its entry points, generated from the rows' entry cells and
the chains' entry points above. Positions are those of the entry-point key.

### By position

| Position | Rows | Chains |
|---|---|---|
| (1) The senior reactor control engineer at the console | S2, S4, T2, T3, T6, T7, T8, T10, T11, T14, R1, R3, S1, D1, D3, D4, D5, D11, D12, D15, E3, E7, M6 | X1, X3, X4, X5 |
| (2) The shift and its supervisors | S3, T12, T14, T15, R3, D6, M1 | X6 |
| (3) The Chief Engineer and plant management | T5, T10, T12, D5, D6, E1, E2, E6, M9 | X1 (optional), X4 (optional), X6, X11 |
| (4) The test programme's authors | S3, T5, T12, T13, D12, D13, E6 | X6, X9 |
| (5) The design organizations and their documents ([19], [43], [11], [44]) | T2, T4, T6, T7, T10, T13, T16, T18, R1, R6, R7, R8, R9, S1, D6, D7, E1, E4, M2, M3, M5, M9 | X1, X2, X3, X4, X5, X6, X7, X8, X10, X9, X11 |
| (6) The ministries | R7, R8, R10, E5 | X4 |
| (7) The regulator and the approving committees | T18, R6, E5, E6 | X7 |
| (8) A person at the jumper terminals, keys, straps and switches | T1, T2, T3, T4, T7, T8, E3 | none |
| (9) The authors of the operating documentation: the Operating Procedures [40], the Reswitching Procedures [42] | S2, T1, T2, T3, T4, T5, T11, T13, R1, R9, D6, D14, E1, E2, E3, E7, M9 | X3, X4, X5, X6, X7, X8 |
| (10) The SKALA system personnel | S2, R1, D1 | X1 |
| (11) The reader of the records after the event | R2, R3, R4, R5, R10 | none |
| (12) A physical condition with no actor behind it | S4, T6, T13, T14, T15, T16, R2, R5, S1, D1, D2, D3, D4, D5, D8, D9, D10, D11, D12, D13, D14, D15, M3, M5, M6, M11 | X1, X2, X4, X5, X6, X8, X10 |

### By row

| Row | Entries |
|---|---|
| S2 | (10), (1), (9) |
| S3 | (4), (2) |
| S4 | (12), (1) |
| T1 | (8), (9) |
| T2 | (5), (9), (8), (1) |
| T3 | (9), (8), (1) |
| T4 | (5), (9), (8) |
| T5 | (4), (9), (3) |
| T6 | (1), (5), (12) |
| T7 | (1), (8), (5) |
| T8 | (1), (8) |
| T10 | (1), (3), (5) |
| T11 | (9), (1) |
| T12 | (3), (2), (4) |
| T13 | (4), (9), (5), (12) |
| T14 | (1), (2), (12) |
| T15 | (2), (12) |
| T16 | (5), (12) |
| T18 | (5), (7) |
| R1 | (1), (10), (9), (5) |
| R2 | (12), (11) |
| R3 | (2), (1), (11) |
| R4 | (11) |
| R5 | (11), (12) |
| R6 | (5), (7) |
| R7 | (5), (6) |
| R8 | (6), (5) |
| R9 | (9), (5) |
| R10 | (11), (6) |
| S1 | (12), (1), (5) |
| D1 | (12), (10), (1) |
| D2 | (12) |
| D3 | (12), (1) |
| D4 | (12), (1) |
| D5 | (1), (3), (12) |
| D6 | (3), (2), (9), (5) |
| D7 | (5) |
| D8 | (12) |
| D9 | (12) |
| D10 | (12) |
| D11 | (12), (1) |
| D12 | (12), (1), (4) |
| D13 | (12), (4) |
| D14 | (12), (9) |
| D15 | (12), (1) |
| E1 | (9), (3), (5) |
| E2 | (9), (3) |
| E3 | (9), (8), (1) |
| E4 | (5) |
| E5 | (7), (6) |
| E6 | (3), (4), (7) |
| E7 | (9), (1) |
| M1 | (2) |
| M2 | (5) |
| M3 | (12), (5) |
| M5 | (12), (5) |
| M6 | (12), (1) |
| M9 | (9), (3), (5) |
| M11 | (12) |

### By chain

| Chain | Entry points |
|---|---|
| X1 | required: (12), (10), (5), (1); optional: (3); one cause: any positive reactivity |
| X2 | required: (5), (12), the low ORM (D5), low power and subcooling (D12); one cause: the halt (S1), or any positive reactivity |
| X3 | required: (5), (9), (1); one cause: any halt (S1) |
| X4 | required: (6), (5), (9), (1), (12); optional: (3) |
| X5 | one cause: (12) or (1); required: (5), (1), (9) |
| X6 | required: (4), (3), (2), (9), (5), (12); optional: (4) |
| X7 | required: (5), (7), (9) |
| X8 | one cause: (12), the next halt; required: (5), (9) |
| X10 | required: (5), (12); one cause: (12) |
| X9 | required: (5), (4), the rod state (T10) |
| X11 | required: (5), (3); one cause: any halt (S1) |

---

## Availability and performance claims, listed and left unevaluated

Never a row, a severity or a reason to rank anything down. Each confirmed at its lines.

1. The design's rationale, the plant's grid share, `insag-7-paged.txt:2269-2273` (p.55,
   quoted [19]).
2. Base load operation "at constant power", `insag-7-paged.txt:5200-5201` (p.115).
3. The choice "in favour of the second alternative", keeping the unit in operation,
   `insag-7-paged.txt:3819-3823` (p.85, the Commission's finding); and [43]'s ground, that any
   EPS-1, 2 or 3 operation would otherwise bring "complete shutdown",
   `insag-7-paged.txt:3810-3813` (p.85).
4. The grid controller's request to postpone, `insag-7-paged.txt:2686-2687` (p.63, Table I-I);
   the 11 hours at half power, `insag-7-paged.txt:738-739` (p.20).
5. The incentive system: "this system encourages operating personnel to decide in favour of
   the former", `insag-7-paged.txt:4378-4380` (p.96).
6. RBMK plants' share of Soviet nuclear generation, `insag-7-paged.txt:6497-6501` (p.141,
   after the accident).
7. Large burnups for "high economic efficiency", `insag-7-paged.txt:1787-1788` (p.45).
8. The rundown test's necessity, `insag-7-paged.txt:2566-2567`, `:2581-2582` (p.61).
9. The EPS-3 hold with "no limitation on the period", `insag-7-paged.txt:3894-3896` (p.87).
10. The restoration right after a partial reduction, `insag-7-paged.txt:3754-3757` (p.84).
11. Operating experience, "over 580 reactor-years", `insag-7-paged.txt:5114-5115` (p.113);
    "a good performance record", `insag-7-paged.txt:6494-6495` (p.141, after the accident).
12. INSAG's note on enrichment and burnup after the accident, `insag-7-paged.txt:1404-1408`
    (p.37).

Settling any of them means modeling the structural alternative, which this audit does not do.

---

## Still unsettled

Each with the exact question and the record or document that would settle it. Nothing below
was settled by a viewed page.

1. **U1** What were the off-site release, doses and consequences of 1986? The document says
   "disastrous consequences", `insag-7-paged.txt:1461-1463` (p.39). A source outside this one.
2. **U2** [corrected, V27] Did power exceed 530 MW(th) with an excursion period under 20 s at
   01:23:43? Table only, `insag-7-paged.txt:2785-2787` (p.65); the signals are confirmed,
   `insag-7-paged.txt:2955-2959` (p.68); Annex II's account sits inside "none of the three
   models reproduces the reactor runaway when", `insag-7-paged.txt:6005-6008` (p.131). PDF page
   65 or the DREG printout.
3. **U3** Did Unit 4 have the trip on failure of two of three channels NSR-04-74 Article
   3.3.26 required, `insag-7-paged.txt:2085-2088` (p.51, quoted)? The Commission's finding is
   general, `insag-7-paged.txt:2096-2097` (p.52). [19].
4. **U4** What did the 48 V loss and the clutch switch do to the rods (drop, stop or nothing)?
   `insag-7-paged.txt:2816-2823` (p.65), `:5705-5712` (p.124); the scenario attributes the stop
   to jamming, `insag-7-paged.txt:3504-3507` (p.79). [19].
5. **U5** Was the 1986 programme cleared with the Scientific Manager, the Chief Design Engineer
   or the regulator? `insag-7-paged.txt:5557-5568` (p.121), `:2609-2611` (p.62). [41] and its
   approval sheet.
6. **U6** What did LEP do when a preset assembly power was exceeded?
   `insag-7-paged.txt:5154-5156` (p.113). [19].
7. **U7** [corrected, V4] What are the startup monitoring systems, the radiation monitoring
   system, the "executive safety systems" and the "control safety systems": observers or
   signal-path devices, what they check, where they report, their state on 26 April?
   `insag-7-paged.txt:5179` (p.114), `:5280-5282` (p.116). The design documentation and the logs.
   Eight scorecard cells wait on it. [added, A5] Fig. II-1's key, a schematic of "an RBMK plant", also names an "ECCS fast acting valve" and a "leak limiter", `insag-7-paged.txt:5162-5171` (p.114); role and state on 26 April not stated.
8. **U8** The OCR-garbled coefficients and exponents, `insag-7-paged.txt:446-449` (p.13),
   `:1789-1790` (p.45), `:1807-1809`, `:1836-1837` (p.46), `:5209-5227` (p.115). The PDF pages.
9. **U9** [corrected, V11] What was the ORM at 01:22:30? 8 rods, `insag-7-paged.txt:3290-3292`
   (p.75), `:2756-2759` (p.64); 1.9 and 6-8, `insag-7-paged.txt:5658-5665` (p.123); "no more than
   6-8", `insag-7-paged.txt:5807-5808` (p.126, the one dimensional simulation section); 7 in
   Fig. II-15's caption, `insag-7-paged.txt:6477-6478` (p.141). The RESTART tape and the codes.
10. **U10** Did any interlock resist the closure of the ECCS slide valves at power?
    `insag-7-paged.txt:3673-3683` (p.82). The ECCS documentation and [42] §2.
11. **U11** Table I-I's pairings at `insag-7-paged.txt:2719-2731` (p.64): six times against two
    events. PDF page 64.
12. **U12** Feedwater before the test: 90 and 180 t/h, `insag-7-paged.txt:5650-5652` (p.123);
    about 120 t/h a side, `insag-7-paged.txt:3091-3093` (p.71); 200 t/h,
    `insag-7-paged.txt:3293` (p.75). The DREG printout or the chart strips.
13. **U13** Why was the gas replaced from 03:45, and did it affect O14?
    `insag-7-paged.txt:2669-2670` (p.63), `:5193-5194` (p.115). The logs and the gas system's
    documentation.
14. **U14** Did the two-turbine protection command EPS-5 or a lesser EPS signal?
    `insag-7-paged.txt:3866-3867` (p.86), `:2729-2731` (p.64), `:5637-5638` (p.123). [42] §1.
15. **U15** Did the pressure and level controllers of Fig. II-1 act automatically on 26 April?
    `insag-7-paged.txt:5166`, `:5170` (p.114); manual level control, `insag-7-paged.txt:3247-3249`
    (p.74). The logs.
16. **U16** Could a person disable O6, O11, O12, O13, O14, O15? `insag-7-paged.txt:585-589`
    (p.16). [42] and the system documentation.
17. **U17** Table I-II's 50 and 45 rods, `insag-7-paged.txt:4047-4059` (p.90); the 30-rod row
    confirmed, `insag-7-paged.txt:5246-5248` (p.116). PDF page 90 or [40] §6.2.
18. **U18** Did the sirens and warning signals of NSR-04-74 Article 3.1.8 exist for the
    parameters with EPS set points? `insag-7-paged.txt:1911-1918` (p.48, quoted),
    `:1938-1942` (p.48). The alarm schedule in [19] or [40].
19. **U19** Did the -1100 mm level protection ever trip on 26 April? Armed by both bodies,
    `insag-7-paged.txt:3798-3799` (p.85), `:818-819` (p.22); no trip in either table. The DREG
    printout.
20. **U20** [corrected, V13] Are the two tables' drum pressures one record or two? Values
    confirmed, `insag-7-paged.txt:2808-2810` (p.65), `:5700-5701` (p.124); Table II-III's time by
    row order only. The DREG printout.
21. **U21** What triggered EPS-1, EPS-2 and EPS-3? Annex II's swift reduction on "main
    equipment failures" names no EPS mode, and §11.4's "frequency variations" go with a remote
    reduction, not with EPS-3. `insag-7-paged.txt:3890-3894` (p.87), `:5141-5143` (p.113). [19].
22. **U22** (new) Did any GR4 observer take the seventh and eighth MCPs into observation, and
    which instrument measured MCP flow? `insag-7-paged.txt:3921-3924` (p.87), `:2793-2808`
    (p.65), `:2837-2838` (p.66). The DREG signal list and the MCP instrumentation documents. [added, A4] Both tables record unreliable MCP flow readings after EPS-5: Table I-I under its DREG header, "unreliable flow rate readings of the MCPs taking part in the rundown" at 01:23:47 and "unreliable readings for MCP No. 23" at 01:23:48, `insag-7-paged.txt:2793-2808` (p.65); Table II-III, "misleading readings for the flow rates in the MCPs which were involved in the rundown operation", its time column offset, `insag-7-paged.txt:5691-5694` (p.124). Not settled: which instrument, and whether the readings were an instrument fault or the flow.
23. **U23** (new) Is [19]'s "total loss of power to the plant" the condition the test produced?
    `insag-7-paged.txt:2278-2280` (p.55), `:5534-5535` (p.121), `:2574-2576` (p.61),
    `:651-653` (p.18). [19] and [41]. [added, A14] The test programme [41] is titled "in a Rundown Regime with the Plant Internal Load", `insag-7-paged.txt:4634-4635` (p.101), beside four MCPs on the external source, `insag-7-paged.txt:651-653` (p.18).
24. **U24** (new) What did "put on standby" mean for the working range rate protection at
    00:28: armed in reserve or disarmed? The log, "is switched on"; the lamp in the Commission's presumed sequence, "is on",
    `insag-7-paged.txt:3702-3704`, `:3721-3724` (p.83). The RCPS operating algorithm in [19].
25. **U25** (new) Was the §9 authorization to operate below 26 rods sought or given when the ORM fell below 26 at about 03:00 on 25 April? `insag-7-paged.txt:3606-3610` (p.81), `:4018-4019` (p.89). The Chief Engineer's orders and the senior reactor control engineer's log.
26. **H8** Not settled: implementation, U4 and U23.
27. **H10** Not settled: U6.
28. **RP8** The switch confirmed, its effect not settled: U4.
29. **RP9** Dropped as a removal path; the question is U24.
30. **C3** [corrected, K3] The fall to 30 MW(th) in Annex I's §I-4.7.3,
    `insag-7-paged.txt:3698-3700` (p.83), Table II-III, `insag-7-paged.txt:5611-5616` (p.122),
    and INSAG's report of INSAG-1, `insag-7-paged.txt:762-763` (p.21); Annex I also gives
    "0-30 MW (approximately)", `insag-7-paged.txt:3227-3228` (p.73) (DG27); the sequence of regulator events is the Commission's presumption,
    `insag-7-paged.txt:3707-3709` (p.83). [19]'s algorithm and the DREG printout.

### Disagreements between bodies

Recorded as the source has them; none resolved.

- **DG1** First MCP pair: "disconnected at 01:22:46" and "6.00 s to 6.45 s after the EPS-5
  button was pressed", `insag-7-paged.txt:2878-2880` (p.67); Table I-I 01:23:46 and 01:23:46.5,
  `insag-7-paged.txt:2789-2791` (p.65). Confirmed.
- **DG2** Two-turbine trip blocking: INSAG 00:43:27, `insag-7-paged.txt:772-773` (p.21); Table
  I-I "until 00:43:35" beside it, scrambled, `insag-7-paged.txt:2728-2731` (p.64); Table II-III
  00:43:37, a table pairing no running text confirms, `insag-7-paged.txt:5637-5638` (p.123); Annex I's text no time. Confirmed.
- **DG3** [corrected, V7] Drum level protection. Agreement: the -600 mm set point was not
  selected, `insag-7-paged.txt:815-818` (p.22), `:3792-3795` (p.85); the -1100 mm protection
  remained, `insag-7-paged.txt:818-819` (p.22), `:3797-3799` (p.85); it did not affect the
  accident, `insag-7-paged.txt:1076-1078` (p.28), `:3975-3977` (p.88). Difference: INSAG §5.2,
  disabling "did not occur" and "would have been allowable"; INSAG §3(6)'s heading "Steam
  level protection disabled", `insag-7-paged.txt:804` (p.22); Annex I, a "Change in the set
  point" listed as a violation, `insag-7-paged.txt:3946-3949` (p.88), beside its own "did not
  switch".
- **DG4** The records: INSAG, the 1986 explanation "drawn from an analytical model 'normalized'
  to sparse and inaccurate plant data", `insag-7-paged.txt:372-375` (p.11); Annex I, "the
  inadequacy and contradictory nature of the data", `insag-7-paged.txt:3780` (p.84); Annex II,
  models "validated against available experimental data", `insag-7-paged.txt:5500-5502`
  (p.120), and the logs "confirm the chronology", `insag-7-paged.txt:5776-5778` (p.126).
  Confirmed.
- **DG5** [corrected, V11] ORM at 01:22:30: 8, 1.9, 6-8, 7 (U9). The 7 rods of
  `insag-7-paged.txt:1982` (p.49) is research [20]'s case, not a value for 01:22:30.
- **DG6** Annex I: at or below 15 rods "from approximately 13:00 on 26 April until the time of
  the accident", `insag-7-paged.txt:3939-3941` (p.88), against an accident at 01:23:40 on 26
  April, `insag-7-paged.txt:3357-3358` (p.76); INSAG: violated "by 01:00:00 on 26 April",
  `insag-7-paged.txt:785-787` (p.21). Kept as the source has it.
- **DG7** [corrected, V33] ECCS isolation: INSAG, "recent Soviet information confirms" it "was
  in fact permissible at Chernobyl if authorized by the Chief Engineer",
  `insag-7-paged.txt:733-736` (p.20), and "not prohibited in principle",
  `insag-7-paged.txt:1068-1069` (p.28); Annex I, "a violation of Section 2.10.5",
  `insag-7-paged.txt:3683-3684` (p.82), while [42] §2 authorized the switch-off, `:3679-3681` (p.82).
- **DG8** [corrected, V25] The 00:28 fall: INSAG, "Recent reports suggest that there was no
  operator error as such", `insag-7-paged.txt:762-767` (p.21); Annex I, the engineer "failed to
  eliminate fast enough the imbalance", `insag-7-paged.txt:3223-3228` (p.73), the presumed
  sequence, `insag-7-paged.txt:3707-3715` (p.83), and "It is impossible to draw a final
  conclusion", `insag-7-paged.txt:3777-3778` (p.84).
- **DG9** The positive scram effect: November/December 1983, `insag-7-paged.txt:2187-2190`
  (p.53), INSAG reporting the SCSSINP Commission, 1983, `:850-851` (p.23); "in 1984, when the positive reactivity insertion
  effect ... manifested itself during experiments", `insag-7-paged.txt:4105-4107` (p.91); the
  letter [22] of 2 February 1984, `insag-7-paged.txt:4558-4559` (p.100). Confirmed.
- **DG10** [1]: "all the thermal parameter reactor protection systems were switched off";
  Annex I, "not true", `insag-7-paged.txt:3800-3802` (p.85), and the pressure protection "was
  not 'a thermal parameter reactor protection system'", `insag-7-paged.txt:3842-3844` (p.86).
  Confirmed.
- **DG11** EPS-5 at 01:23:40 on DREG and in the text, 01:23:39 on the teletape,
  `insag-7-paged.txt:2781-2783` (p.65), `:2869-2870` (p.66). Confirmed.
- **DG12** Feedwater before the test (U12). Confirmed.
- **DG13** The eight MCPs: INSAG, pump disturbance "could have led to sudden augmentation",
  `insag-7-paged.txt:876-879` (p.24), operation "unsatisfactory", `:1050-1052` (p.28); Annex I,
  "It would appear" they "if anything hindered the reactor runaway",
  `insag-7-paged.txt:3969-3973` (p.88). Confirmed.
- **DG14** Test approval: regulations "did not require" it, `insag-7-paged.txt:2609-2611`
  (p.62); the Operating Procedures required clearance of non-design devices,
  `insag-7-paged.txt:5557-5568` (p.121). Confirmed.
- **DG15** [corrected, V36] Shortened absorber rods: 24 (INSAG), `insag-7-paged.txt:466-468`
  (p.14); 24 (Annex II), `insag-7-paged.txt:5156-5157` (p.113); 21 (Annex I),
  `insag-7-paged.txt:2169-2171` (p.53), `:2483` (p.59). Annex I also gives 21 EPS rods for the
  first stage and 24 for the second, `insag-7-paged.txt:2171-2172` (p.53), a separate count.
- **DG16** Full insertion: 18 s (INSAG), `insag-7-paged.txt:486-487` (p.14); 18 s and "18-21 s"
  (Annex I), `insag-7-paged.txt:1969-1971` (p.49), `:2052-2053` (p.51). Confirmed.
- **DG17** The void coefficient in the design documentation: negative "for initial and steady
  state conditions" (INSAG, citing Annex II §II-3), `insag-7-paged.txt:450-452` (p.13); "a high
  positive value" foreseen (Annex I), `insag-7-paged.txt:1783-1786` (p.45). Confirmed.
- **DG18** [corrected, V40] ORM floors: 10 rods in [44], the third stage's Technical Safety
  Report, `insag-7-paged.txt:4078-4087` (p.90-91), `:4646-4649` (p.101); 15 rods in §9,
  `insag-7-paged.txt:4020-4021` (p.89); "equally contradictory", `insag-7-paged.txt:4077`
  (p.90). [corrected, K6] The document places Units 3 and 4 in the second stage, whose Technical Safety Report is [11], and names [44] the third stage's, approved by the Chief Design Engineer's and the Scientific Manager's institutes, `insag-7-paged.txt:1727-1732` (p.44), `:4646-4649` (p.101).
- **DG19** The two-turbine protection's wording: EPS-5 to protect the reactor (Annex I),
  `insag-7-paged.txt:3866-3867` (p.86); "the EPS signal which would have shut down the two
  turbogenerators" (Table I-I), `insag-7-paged.txt:2729-2731` (p.64); "shuts down both" (Table
  II-III), `insag-7-paged.txt:5637-5638` (p.123). Confirmed.
- **DG20** [corrected, V26] INSAG §3(6): "The recent information suggests that the steam drum
  protection was changed as early as 00:36", `insag-7-paged.txt:806-807` (p.22); Annex I
  separates the pressure set point change at 00:36:24 from the level set point,
  `insag-7-paged.txt:3790-3833` (p.85).
- **DG21** (new) The DBA button's time: Table I-I 01:23:10, `insag-7-paged.txt:2776` (p.65);
  Annex I's text, "6.6 s after closure" of the stop valves, `insag-7-paged.txt:2882-2883`
  (p.67); Annex II, "the exact times at which the DBA button was pressed ... are not known",
  `insag-7-paged.txt:5672-5674` (p.123).
- **DG22** (new) The State Committee for the Supervision of Nuclear Power Safety: it approved
  the Technical Safety Report by a letter of 18 May 1975, `insag-7-paged.txt:1757-1758` (p.45);
  "Until 1984" it was a division of the Ministry for Intermediate Sized Machinery,
  `insag-7-paged.txt:1761-1762` (p.45); it "was established only three years before the
  Chernobyl accident", `insag-7-paged.txt:4437-4438` (p.98). All Annex I.
- **DG23** (new) The first seconds of rod insertion: research [20] reported by Annex I, at "a
  non-regulation ORM of 7 control rods, during the first eight seconds after triggering" the
  inserted reactivity is positive, `insag-7-paged.txt:1982-1984` (p.49); Annex II, insertion
  from the top position "could induce a negative reactivity insertion during the first second
  and then a reactivity rise", `insag-7-paged.txt:5486-5489` (p.120).
- **DG24** (new) The scope of full shutdown: the quoted [19], full shutdown "foreseen only for
  total loss of power to the plant", `insag-7-paged.txt:2278-2280` (p.55); the quoted [43], a
  level at -600 mm "will result in actuation of EPS-5 and complete shutdown of the reactor",
  `insag-7-paged.txt:3812-3813` (p.85); Annex I, EPS-5 on closure of both turbines' stop valves,
  `insag-7-paged.txt:3866-3873` (p.86); Annex II, the RCPS "terminates the chain reaction ... if
  there are signals indicating dangerous divergences", `insag-7-paged.txt:5143-5144` (p.113).
  Whether "dropping all the RCPS rods" differs from EPS-5's driven insertion is not stated.
- **DG25** (new) The ORM's cycle: INSAG "about 10-15 min", `insag-7-paged.txt:558-559` (p.16);
  Annex I, SKALA's parameters every 5 min, `insag-7-paged.txt:2830-2831` (p.66), and the ORM
  recalculated "every 5 min rather than every 15 min as was the case before the accident",
  `insag-7-paged.txt:2490-2491` (p.59); Annex II "approximately every 5 min",
  `insag-7-paged.txt:5735` (p.125).
- **DG26** (new) What reached the RBMK plants after the 1983 finding: INSAG, the Chief Design Engineer "promulgated this information to other RBMK plants" and "stated that design changes would be made", `insag-7-paged.txt:851-854` (p.23); Annex I, the Chief Design Engineering Organization "informed other organizations and all plants with RBMK reactors that it intended to restrict" the fully withdrawn rods, `insag-7-paged.txt:4105-4111` (p.91), and "no explanations were given to the personnel", `insag-7-paged.txt:4140-4141` (p.92); INSAG's own §4.2 reports Annex I's version as an intention, `insag-7-paged.txt:934-939` (p.25).
- **DG27** (new) The depth of the 00:28 fall, within Annex I and across bodies: "from 500 MW to 0-30 MW (approximately)", `insag-7-paged.txt:3227-3228` (p.73); "to 30 MW", `insag-7-paged.txt:3699-3700` (p.83); Annex I's Note, the PPDDCS recorder "did not record the reduction in thermal power below 30 MW", the neutron power recorder "recorded zero power" for about 5 min, and "the reactor power actually fell to the minimum controllable level", `insag-7-paged.txt:3747-3753` (p.84); Table II-III, "to 30 MW" with "(neutron power dropped to zero)", `insag-7-paged.txt:5611-5616` (p.122); INSAG, INSAG-1's "fall in power to 30 MW(th)", `insag-7-paged.txt:762-763` (p.21).

---

## Counts

| | |
|---|---|
| Rows | 59: S 3, T 17, R 11, I 0, D 20, E 8 (52 in the S to E tables, 7 found by the chain hunt: T 1, R 1, D 4, E 1) |
| Chains that compose | 11 of 20 candidates judged: 7 source-supported, 2 conditional on an unconfirmed item, 2 design assumption |
| Chain candidates rejected | 9 |
| Halt paths | 10, H1 to H10; the reactor halts end in the 211 rods and reach no other observer, H6 ends at the turbine and H7 at the ECCS pumps |
| Continue-on-fault paths | 19, C1 to C19 |
| Observers inventoried | 21, O1 to O21, of which 19 are scored and 2 are named only (O17, O18); beside them 12 signal-path devices, 17 B2 controls and 14 observed components |
| Rings at any layer | 0 |
| Coordinators | 0 of 14 candidates |
| Scorecard | 56 cells over 7 groups: 52 gaps, 3 satisfied, 1 not settled by the document, 0 not required |
| Prescribed responses tested as actuators | 15, PR1 to PR15 |
| Removal paths | 8, RP1 to RP8 |
| Delegation boundaries | 17 |
| Availability claims, unevaluated | 12 |
| Unsettled questions | 30 numbered items (U1 to U25 and five path items), and 27 disagreements between bodies, DG1 to DG27 |

**The shape of it.** No ring forms at any layer. The 21 observers are isolated spokes from
sensors to one shared actuator, the 211 rods, with recorders, a control board and a
printout as passive hubs: no observer watches another's health, no candidate passes the
coordinator test, and the structure does not close. Every reactor halt ends in rods whose
first motion from the upper stops inserted positive reactivity locally,
`insag-7-paged.txt:477-480` (p.14, INSAG), and whose worth, the ORM, had no device to
measure it, `insag-7-paged.txt:3650-3651` (p.82, Annex I); execution checked no observer,
and the scorecard holds 52 gaps in 56 cells. At the top of the risk list is the design
position, whose one decision reached every RBMK unit with the halt's own positive
reactivity, void and power coefficients with no safety analysis of the void coefficient,
and an ORM no observer checked against its limit, approved without the list of
violations the regulation
required; second is the physical condition in the low-ORM, low-power state, which needs
no privileged act only on the Commission's hypothetical.

**The system that produced the system.** An observation, not a second audit. The unit was
held to NSR-04-74 and GSP-73 as Annex I quotes them: violations of the regulations were to
be listed in the technical safety report and "authorized by the USSR State Committee for
the Supervision of Nuclear Power Safety at the technical design stage",
`insag-7-paged.txt:1719-1725` (p.44, quoted), and a positive power coefficient required
safety "guaranteed in the design and explicitly proved", `insag-7-paged.txt:1776-1779`
(p.45, quoted). The Technical Safety Report for the second stage, Units 3 and 4, was
approved by the Scientific Manager and the Chief Design Engineer,
`insag-7-paged.txt:1727-1732` (p.44), and by three state committees in 1975,
`insag-7-paged.txt:1754-1759` (p.45), though "No list of violations" was given and no
analysis of their acceptability was made, `insag-7-paged.txt:1737-1741` (p.44); the
approving committee was "Until 1984" a division of the USSR Ministry for Intermediate
Sized Machinery, `insag-7-paged.txt:1761-1762` (p.45) (DG22). Annex I: "Nevertheless, the
design was approved and authorization given for construction by all the relevant
authorities and regulatory bodies", `insag-7-paged.txt:4429-4430` (p.97); INSAG: the basic
design "was approved despite the lack of conformity to many of the USSR's design
requirements", `insag-7-paged.txt:1219-1220` (p.31). Faults were known before the
accident: the Leningrad Unit 1 accident of 30 November 1975, whose "real causes" were not
given to those in charge of operating RBMK-1000 plants, `insag-7-paged.txt:2411-2419`
(p.58); an additional, faster emergency protection asked for in 1976, whose recommendations
"have still not been implemented", `insag-7-paged.txt:2391-2394` (p.57), `:2405-2407`
(p.58); large positive coefficients that "became apparent from experiments" and were "not
adequately analysed", `insag-7-paged.txt:1874-1879` (p.47); and the positive scram,
"discovered experimentally in November/December 1983 during the physical startup of
Ignalina Unit 1 and that of Chernobyl Unit 4", with none of the proposed measures
implemented, `insag-7-paged.txt:2188-2196` (p.53-54).
