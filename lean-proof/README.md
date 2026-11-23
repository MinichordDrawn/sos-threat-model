# A Lean 4 Formalisation Of Self-Observing Systems

The model check in this kit writes a model of self-observing systems down exactly, checks
small systems by exhaustive search, and proves general results in writing. A written proof
is checked by whoever reads it. This folder takes the next step. It restates the model in
Lean 4, a proof assistant, and proves the main results there.

A proof assistant is a program that checks every step of a proof against the rules of
logic. A step it cannot justify is rejected, so nothing rests on a reader finding a proof
convincing.

## The result

Ninety-six statements about the model are proved in Lean. They fall into seven groups.

**One fault per round.** Take any system of monitors and work processes, of any size, that
is plain and whose wiring meets four conditions. Let at most one fault land between two
rounds of checks. Then, whatever the environment does and however long the system runs, no
state is ever bad without a live, correct monitor having flagged it, and no work is ever
done while a state is bad. Such a system has no gap. This is Theorem S of the model check.
A second theorem says the same of a wider class of systems, which may have substrates,
shared boundaries and a process that joins late, under two more conditions.

**The reference system.** The model check's reference system has the eight properties. At
one fault per round it has no gap. Take away any one of ten features, the eight properties
among them, and a gap opens.

**What any system needs.** One statement says that a flag starts only at a detection. Nine
say that a system which lacks something has a gap, whatever else it has.

**Any number of faults per round.** Let `f` faults land in one round. A plain system has
no gap if its monitors are connected by pairs that watch each other and report to each
other, every work process has a state checker and more than `f` halt inputs, and there are
more than `f` monitors. This is Theorem J. The model check had listed a condition of this
kind as missing.

**The ring.** Take `k` members in a cycle, a coordinator connected to each both ways, and
work that every monitor checks and can halt. This ring has no gap exactly when `f` is at
most `k`. With three members it has nine connections. Ask that every monitor is watched by
two others and that every member reports to the coordinator: under one reading of a
connection no wiring of four monitors does it with fewer than nine, and under the other
eight are enough. Put three such rings under a top coordinator, and do the same again
above that, to any number of levels. With every monitor in a boundary of its own, the
tower has no gap at one, two and three faults per round.

**Growth.** In a second model, monitors can join a running system. Grow a ring or a mesh
by any number of late monitors, each in a boundary of its own and on no substrate, each
with a state checker, a signal reader and a monitor it reports to among those there before
it, those three edges in force from the step it joins, and no monitor with an off switch.
The grown system has no gap at exactly the numbers of faults per round the ring or mesh
had none at.

**Three small models.** A ring in which every member starts only once another has started
cannot restart from a full stop, so one member must be able to start first. A halt passed
to one process per hop is outrun by a fault that doubles, and a halt passed to two keeps
pace at two hops per tick, when the halt reaches good processes first. A faulty monitor
cannot be named with two monitors and can be named with three.

Lean's kernel accepts the proofs, and so do four independent checkers.

`results.md` in the model check gives the full account of the model. `statements.md` lists
the ninety-six statements one by one, and `method.md` says how they were made and checked.
This page says what is proved in Lean, what "checked" means for it, and what is still to
do.

## Overview

### The ninety-six statements

The first twenty-six are set out here. `statements.md` has all ninety-six, each with its
name in Lean.

**1. Theorem S.** A plain system that meets the four conditions has no gap at one fault
per round. The numbers of monitors and of work processes are arbitrary, and neither has to
be finite.

*Plain* means the system has the two basic kinds of fault and the ordinary timing:

- every process is present from the start;
- no substrate is modelled, and no monitor has an off switch;
- no two monitors sit in the same boundary;
- a work process halts when a monitor it listens to goes silent;
- a work process halts at once when it sees a reason to, with no waiting period;
- in each round the monitors check before any work is done;
- a report arrives within the round it is sent.

*The four conditions* on the wiring are:

- (a) every monitor is watched by another monitor, which both checks its state and reads
  its liveness signal;
- (b) every work process has a monitor that checks its state, and takes its halt from at
  least two different monitors;
- (c) if any one monitor is faulty, every other monitor either watches it or hears from a
  monitor that does, along reports that do not pass through the faulty one;
- (d) every work process has a checker whose report reaches every monitor.

**2. The conditions can be met.** A full mesh of two or more monitors, with any work
processes, is plain and meets all four conditions, so it has no gap. In a full mesh every
monitor watches and reports to every other, and every work process is checked by, and
takes its halt from, every monitor. The ring of four that both implementations named in
the model check's README build is a full mesh. A theorem about systems that meet four
conditions would say nothing if no system could meet them.

**3. The property can fail.** A work process that nothing watches has a gap: the
environment can corrupt it, and nothing is there to flag it. This statement is a check on
the definitions. "No gap" is defined in this folder, and a slip in a definition could make
it true of every system, the unwatched one included. Theorem S would then be provable and
would mean nothing. Proving that one plainly unsafe system has a gap shows that the
definition tells the two apart.

**4. The reference system has no gap.** The reference system is the model check's system
with every feature in place: three monitors that watch each other, two work processes, and
a third process that may join later. It is not plain: it has substrates and a process
that joins late. Four of the model's six kinds of step can occur in it; with no off switch
and no shared boundary, the other two cannot. At one fault per round, no execution of any
length violates either goal.

**5 to 14. Each of ten removals opens a gap.** Each statement takes one feature away from
the reference system and says which of the two goals some execution then violates. The
two goals are detection (a bad state is flagged by a live, correct monitor) and no impact
(no work is done while a state is bad).

| Without | Detection | No impact |
|---|---|---|
| P1, the liveness signal | fails | fails |
| P2, shared substrate | fails | fails |
| P3, the state check | fails | fails |
| P4, propagation | holds | fails |
| P5, no single-step removal | fails | fails |
| P6, the out-of-boundary signal | fails | holds |
| P7, automatic enrolment | fails | fails |
| P8, immediate response | holds | fails |
| the halt fan-out | fails | fails |
| the gate | fails | fails |

*Fails* means that some execution violates the goal. *Holds* means that none does, and
that is proved as well. Three removals break one goal only. Without propagation the fault
is flagged, and the work goes on. Without the out-of-boundary signal the work stops, and
nothing is left to know why. Without immediate response every monitor has flagged, and the
work takes one more step. The halt fan-out is the clause of the eighth property by which a
work process takes its halt from more than one monitor, and the gate is the rule that the
monitors check before any work is done.

**15 to 24. What any system needs.** These ten statements are about every system, of any
size and with any wiring. The first says where a flag comes from. The other nine each say
that a system which lacks something has a gap, whatever else it has. In them `f` is the
number of faults that may land in one round, and may be any number from 1 up.

| Id | For every system |
|---|---|
| 15 | A flag starts only at a detection. With no flag up, if no monitor detects, none is raised |
| 16 | If some non-empty set of at most `f` monitors is checked by no monitor outside the set, detection can fail |
| 17 | If there is at least one monitor, and `f` is at least their number, detection can fail |
| 18 | A monitor with no state checker but itself can be corrupted with no flag |
| 19 | A work process that no monitor checks can be corrupted with no flag, whether it is present from the start or joins later |
| 20 | If every monitor sits in one boundary, and there are at least two, detection can fail |
| 21 | With a waiting period before a halt, a corrupted work process acts |
| 22 | A work process with at most `f` halt inputs keeps working after all of them are corrupted |
| 23 | Without the gate, a corrupted work process acts before any flag exists |
| 24 | When reports take a round, a work process none of whose halt inputs checks its state acts while bad |

Statements 16, 17 and 22 are the counts in the model check's scaling law, in the direction
of need. Each further fault that may land in one round needs one more monitor, no set of
that many monitors left unchecked from outside, and one more halt input for each work
process.

Statements 21 to 24 are stated for a work process that is present from the start, as the
model check words 21 and 23. They hold for one that joins later as well. The agent that
wrote the proofs reports a Lean proof of that outside this folder, the tests of the third
agent described in `method.md` agree, and it is not among the statements.

**25 and 26. Naming the faulty monitor.** Responding to a fault does not need to know
which monitor is at fault. Recovering without outside help does. Exactly one monitor is
faulty. Every other monitor names it, the faulty one may name anyone, and a rule reads the
names. With two monitors no rule is always right, because "each names the other" arises
whichever of the two is faulty (25). With three or more, a rule exists that is always
right (26). This is one of the reasons the ring has three members beside its coordinator.

**27 to 96.**

| Statements | What they say |
|---|---|
| 27 to 34, 54 | Restarting from a full stop: Theorem R, and when a ring can always restart |
| 35 to 37 | Theorem S for the wider class. Theorem S and the reference system's result are special cases of it |
| 38 to 48, 55 | How fast a halt must travel to keep up with a fault that doubles |
| 49 to 53 | Naming the faulty monitor when at most one is faulty: it takes three monitors, and four if it has to survive the loss of one |
| 56, 57 | When reports take a round, a work process that goes bad works once for every hop between its checker and its halt |
| 58, 59 | A full mesh of `n` monitors has no gap exactly when `f` is at most `n - 1` |
| 60 to 62 | Two rings joined by an upper ring have no gap at one fault per round, also when one step can stop a whole ring |
| 63 to 67 | Theorem J, a form of it that asks less, and Theorem F: no gap at any `f`, on any wiring that meets the conditions |
| 68 to 70 | The ring of `k` members and a coordinator has no gap exactly when `f` is at most `k` |
| 71 to 75 | The least ring: the fewest connections that give every monitor two watchers and every member a report to the coordinator |
| 76 to 81 | The same ring one level up, at every number of levels |
| 82 to 94 | Monitors that join: the second model, Theorem J with joins, Theorem L on growth, and two examples that show two of its conditions are needed |
| 95, 96 | Adding edges to a system with no waiting period never opens a gap |

**The least ring, read with care.** A connection `X -> Y` can be read two ways. Under
*actor*, `X` watches `Y` and reports to `Y`. Under *flow*, `Y` watches `X` and `X` reports
to `Y`. Statements 71 to 75 count connections for two requirements only: every monitor is
watched by two others, and every member reports to the coordinator. Under actor, `k`
members and a coordinator need at least `3k` connections, and with three members the
ring's nine are that least. Under flow they need at least `2k + 2`, so with three members
the ring's nine are one more than the least. *Least* means nothing beyond this count.
`part-a.md` in the model check takes the other requirements and the other readings in
turn.

### Level of assurance

The model check's README sets out four standards a result can be held to: an argument in
prose; a precise model with written proofs; exhaustive checking of a finite system; and
machine-checked proof.

The ninety-six statements are at the fourth. Before, the model check held most of them as
written proofs or as checked systems. A few are stated here for the first time. More than
once in the model check's later work, a written proof turned out to need a condition it
did not state, and an independent reader caught it. That is the reason these results were
taken to Lean, where a statement is proved exactly as written or not at all. Results of
the model check that are not among the ninety-six stay where its README puts them.

One question lies outside all four standards, here as there: whether the definitions say
what the words mean. The model check translates the framework's words into a
specification. This folder translates that specification into Lean. A result about the
Lean model is a result about the specification only as far as the second translation is
faithful, and no program can check it. The files that hold the translation are listed
under "What is here", and hold no proofs.

### What "checked in Lean" covers

What a claim of "checked in Lean" is worth depends on what was checked. A post on the Xena
project blog,
["...and the proof is checked in Lean"](https://xenaproject.wordpress.com/2026/11/12/and-the-proof-is-checked-in-lean/)
(November 2026), sets out four questions to ask of any such claim. This folder takes them
in the post's order. `method.md` has the detail behind each answer.

| Question | How it is answered | Answer |
|---|---|---|
| Does the Lean statement say what the plain-language claim says? | by reading and by test; the definitions are in files apart from the proofs | agents that had not seen the proofs read the definitions and statements against the model check's text, and others tested them against the model check's programs; statements 27 to 96 were then checked again, from a clean copy, by agents given nothing of the author's reasoning |
| Does the code compile? | `lake build`, from a clean copy | yes |
| Does the proof prove that statement, with the standard axioms only? | `lake comparator`, Lean's own judge, in its sandbox | accepted, for all ninety-six |
| Could a fault in Lean's checker have let a wrong proof through? | `lake comparator --paranoid`, which checks the proofs again with every independent checker shipped with Lean | accepted by Lean's kernel in both its forms and by four independent checkers |

## What is here

```
statements.md                   the ninety-six statements, one by one, in plain words
method.md                       how the statements were made and checked, round by round
living-things.md                the full comparison with living things that this page
                                summarises: grades, limits, sources

SelfObserving/Challenge.lean    the ninety-six statements, with the proofs left out
SelfObserving/Solution.lean     the same statements, proved

The definitions, to be read against the model check. They hold no proofs.
SelfObserving/Model.lean        the model: a system, a state, the environment's steps, one
                                round, the two goals, executions (model-spec.md)
SelfObserving/Conditions.lean   what "plain" means, and the four conditions of Theorem S
SelfObserving/Systems.lean      the full mesh and the unwatched work process
SelfObserving/Reference.lean    the reference system and its ten removals
SelfObserving/Restart.lean      the restart model
SelfObserving/Wide.lean         the wider class and its conditions
SelfObserving/Growth.lean       the count of a spreading halt
SelfObserving/Naming.lean       naming the faulty monitor, at most one faulty
SelfObserving/Reflex.lean       the count a slow report costs
SelfObserving/MeshAt.lean       the mesh at any number of faults per round
SelfObserving/Nested.lean       two rings joined by an upper ring
SelfObserving/AnyRate.lean      the conditions of Theorem J and Theorem F
SelfObserving/Rings.lean        the ring of k members, the two readings, R2 and R5
SelfObserving/Tower.lean        the ring one level up, at any number of levels
SelfObserving/Join.lean         the second model: monitors that join (model-spec-join.md)
SelfObserving/JoinConditions.lean   the conditions of Theorem J with joins, of Lemma N
                                and of Theorem L
SelfObserving/JoinExamples.lean the two example systems
SelfObserving/MoreEdges.lean    what "the second system has more edges" means

SelfObserving/Proofs/           the proofs, which the kernel checks and nobody has to read
SelfObserving/Generated/        six files written by tools/gen.py from the model check's
                                checker, for the reference system: the systems as the
                                checker builds them, the executions that show each gap,
                                and the lists of reachable states
tools/gen.py                    the generator, with its own README
comparator.json                 tells the judge which statements to compare and which
                                axioms to permit
lean-toolchain                  pins the version of Lean
lakefile.toml                   the project file for Lake, Lean's build tool
lake-manifest.json              Lake's list of dependencies, which is empty
SelfObserving.lean              the root of the library that lake build compiles
```

To trust the result, read `Challenge.lean` and the definitions against the model check:
`model-spec.md` and `results.md` at its top, `model-spec-join.md` and `results-join.md` in
its folder `join/`, and `part-a.md` and `results-minimal.md` in its folder `least-ring/`.
Nothing else needs to be read. The kernel checks the rest, and the judge confirms that
`Solution.lean` proves the statements of `Challenge.lean` and no others.

The project imports nothing outside the Lean core. A set is written as a yes-or-no
question about each element: `s.alive p` reads "is `p` alive in state `s`".

## What is established

**Proved, and checked by machine:** the ninety-six statements, as the table above groups
them and as `statements.md` words them. Nothing else on this page is.

The proofs were written by Claude Fable 5.2, and so were the comparisons of the Lean with
the model check, by separate agents of the same model that were started fresh and not
shown the proofs. The kernel that accepts the proofs is a separate program, so a mistake
the model makes consistently cannot pass it. The same is not true of the definitions. A
definition that says the wrong thing compiles as well as one that says the right thing,
which is why the comparison with the model check is a step of its own.

## What is not established

- **A general result for every property.** Statements 15 to 24 cover most of what the
  model check proves on what any system needs. It proves none for propagation, and for the
  liveness signal only one about plain systems with no gap and no spare monitor, which is
  not in Lean. Its general result for shared substrate needs a model with a silence
  threshold, which the round model does not have.
- **When a gap first opens.** The statements say that some execution violates a goal, and
  not in which round.
- **Scopes.** The model check's newest extension lets a halt stay within one ring and a
  flag carry the scope it was raised in. It is not in Lean. The statements about the tower
  judge it as one system, in which any detection halts all the work.
- **The least ring beyond two requirements.** Statements 71 to 75 count connections for
  two requirements under two readings. That the bounds are reached is proved for three
  members only. The model check's other requirements, its other readings of a connection
  and its counts edge by edge are not in Lean.
- **Growth in every case the model check covers.** Theorem L is proved for grown systems
  in which no late monitor runs on a substrate and no two monitors share a boundary. That
  each of its three edges must be in force at once is proved for the state check, and
  found by search for the other two. Lemma N is proved for late monitors only.
- **The tower with whole rings in one boundary, beyond one fault per round.**
- **Every clause of the model, by test.** For clauses that the tested systems do not use,
  the faithfulness of the Lean model rests on the comparisons by reading.
- **That the model is the right model.** Lean checks what follows from the definitions. It
  cannot check that the kinds of fault in the model are the right ones, or that none is
  missing.
- **Anything about an implementation.** These are results about the model. Whether a
  system as built conforms to the model is a separate question, answered by auditing it.

## Running it

Install Lean with [elan](https://github.com/leanprover/elan). The file `lean-toolchain`
selects the version.

```
lake build                    compile the model and the proofs
lake comparator               judge the proofs against the statements
lake comparator --paranoid    the same, with every independent checker
python tools/gen.py --check   confirm the generated files are what the generator writes
```

The last command reads the model check's `check_model.py`, and `tools/README.md` says
where it looks for it.

The judge's sandbox needs Linux and `bubblewrap`. On other systems,
`lake comparator --inadvisably-no-sandbox` makes the same comparison without it. The Lean
reference explains what each check establishes, under
[Validating a Lean Proof](https://lean-lang.org/doc/reference/latest/ValidatingProofs/).

## Living Things

*A comparison, and not a result.*

Living things follow the model's four constraints. Within a tissue, nothing central
decides which cell lives. A missed cancer or infection can cost far more than a wasted
cell. A fault can look like health, as a cancer does. And nothing outside a solitary
organism watches it. Under those constraints, living things have arrived over time at
solutions similar to the model's.

A separate search went through the published biology one part of the model at a time. It
graded each counterpart, and looked for evidence against the comparison as well as for it.
Its grades, from closest to furthest, are *same structure*, *partial* and *loose*, and its
report does not define them further. **Each of the eight properties, the first eight rows
of the table, has a counterpart in living things: three with the same structure and five
in part.** The examples come from different organisms. A later check, described below,
asked the same of one kind of animal. The closed ring has no counterpart that the search
found.

| In the model | In living things | How close |
|---|---|---|
| Liveness signal | Silence is the signal. A healthy mitochondrion, the cell's power unit, keeps destroying a marker protein. When the unit fails, the marker builds up and the cell disposes of the unit. Oxygen is read the same way: while oxygen is present, the cell keeps destroying a protein, and when the oxygen stops, that protein builds up and switches on the cell's response to low oxygen. Tumour cells that lack the normal markers of self are rejected | Same structure, between two parts |
| Shared substrate | The observer is part of the machine that does the work. The attachment point on a chromosome both holds it to the fibres that pull it and hosts the check that it is attached, though the review cited calls part of that role "controversial". Two ribosomes colliding is itself the signal that protein-making has stalled | Partial |
| State check | Mismatch repair. After DNA is copied, the new strand is compared with the old one, and the old one is taken as the reference | Same structure |
| Propagation | Inside a dividing cell, one unattached chromosome holds back the separation of all of them | Same structure, within one cell |
| No single-step removal | Disabling one observer sets off a second. In bacteria, a virus that blocks one defence triggers another, which kills the infected cell. In animal cells, blocking one cell-death enzyme releases a second death pathway. Some observers are also essential: mice without them die as embryos | Partial |
| Out-of-boundary signal | A dying cell is seen from outside. It shows an "eat me" signal on its surface, and a cell that dies in disorder releases a protein that raises inflammation | Partial |
| Automatic enrolment | A new cell inherits the genes for its checks (the search did not source this directly) | Partial |
| Immediate response | A reflex through the spinal cord answers pain in about 90 to 150 thousandths of a second | Partial |
| The gate | A dividing cell does not separate its chromosomes until the last one is attached. When the last unattached attachment point was destroyed with a laser, separation followed about 20 minutes later. A cell's survival is held the same way: cells depend on signals from other cells | Same structure |
| The halt | An infected bacterium kills itself before the virus has finished copying, which protects the colony. A plant cell at the site of an infection does the same | Same structure, for a cell in a body or in a colony of relatives |
| A member that starts first | The pacemaker cells of the heart fire by themselves. Slower pacemakers further down are held silent by the faster one and take over when it stops. Dormant bacteria wake on chemicals shed by bacteria that are already growing, so something has to wake first, and a few appear to wake at random | Partial |
| Naming the faulty one | Mismatch repair again. Two strands show that they differ, and cannot show which is wrong | Partial |
| The ring | Not found. The nearest is a guard on a guard, two layers deep | Loose to partial |

Two parts of the model got the lowest grade. For the scope outward, the search found
failures and no counterpart. For the recursion, it found no coordinator that is a member
of a ring one level up.

**One animal.** The table draws on many organisms. A later check asked the same questions
of one kind of animal, the jellyfish. A moon jellyfish has no central controller. It
usually has eight pacemakers round the rim of its bell. Each fires by itself, and in one
account, which is disputed, each beat restarts the countdown of all the others, so that if
the leaders fall silent another fires in their place. In experiments reported in 1885,
with seven of the eight cut away, the last one kept the bell beating. That is close to the
liveness signal and to a member that starts first, in one animal, and the relation between
the pacemakers is the same as a watchdog timer's. The other half of the model is missing.
Nothing checks a pacemaker that is running wrong: the fastest one is simply obeyed. And
the animal does not stop on a fault. It swims on through damage, and in the young animal
the swimming is what does the repair. All eight properties have some counterpart in the
jellyfish, one with the same structure, five in part and two loosely, and none of those
counterparts observes faults. A moon jellyfish is covered against a silent pacemaker, and
not against a wrong one.

**The model extends further.** The search found no closed ring: no three observers that
all watch each other. What it found is a guard on a guard, two layers deep, which evolved
separately in bacteria, in plants and in animals. In every guard on a guard the top layer
is watched by nothing. Living things also let a halt time out, have some checks that
ignore small faults, and carry on through other faults. The model closes the structure, so
that the observers are themselves observed, and its gate has no timeout and no threshold.
The ring is a fixed point of the question "who watches this?": the answer is always a
member already in it. One caution applies to the ring missing from living things: the
search for a loop among the immune system's regulators was one of the checks that was
stopped.

**What the model covers.** The model covers every way of observing and stopping that the
search found in living things. Each mechanism in the table matches one or more parts of
the model, in whole or in part. The model has all the parts together, and the closure. Two
things that look like additions are already in it. Repair after a stop is the model's
recovery: the affected work stops, the fault is repaired or clears, and the work resumes.
A cell that stops for damaged DNA and later restarts does this, unless it restarts with
the damage still in place. Foresight is the gate with a wider scope. Take a self-driving
vehicle with a laser scanner. Built to the model, it moves only on a current reading that
the road ahead is clear, and it stops if the scanner goes silent. A mind that sees a
danger coming and stops for it does the same in part.

**What the model leaves out.** Apart from the places where living things contradict the
model, one thing they do has no part in it: changing the standard itself. An animal
learns, and evolution reworks the whole arrangement over generations. The model describes
a fixed system, with set kinds of fault. A fixed system can be safe without that ability,
and a lineage that has to keep up with a changing world cannot do without it. The result
that there is no gap holds for a given wiring, so a system that changes itself has to meet
the conditions again after each change. Growth is the part of this the model already has:
a new process or a new member takes effect only once it is being observed. A dividing cell
is held on a check in the same way only in part: that check leaks, and it is weak in egg
cells. A system built to the model would treat a change of standard as work too: it takes
effect only on a current check that the conditions still hold.

**Cancer.** Cancer is the fault on the inward side of the scope, the kind that can pass
the checks. Medicine answers it in the way the model says an owner can answer a fault its
own checks do not reach: with a check from outside, made at intervals. A screening is an
audit. A cancer that arises between two screenings, which doctors call an interval cancer,
is the fault that lands between two checks.

**The mind.** The conscious mind reads as a member of the body's observers. It is not
their controller, and it is not outside them. It shares the supply, and fails first: when
blood flow to the brain stops, consciousness is lost in about seven or eight seconds, and
the brainstem, which carries automatic functions, is the part of the brain that withstands
a lack of oxygen longest. It cannot switch another member off. Breathing can be held for a
time, and then an involuntary mechanism normally overrides the hold. The other members can
stop its work: after enough lost sleep, short lapses into sleep break in even when a
person resists them. The reading has limits. One is that the body does have central
control of its automatic functions, in the brain, and the conscious mind is only not that
control.

**One scope up.** A person is in turn a member of larger systems: a household, a
workplace, a town. There, people act as observers of each other, slowly and unevenly: when
someone goes quiet, others tend to notice.

These are correspondences and not results. Nothing here is proved about biology. The
search was not completed: two of its four checking passes were stopped, and about a third
of the planned source checks were not made. `living-things.md` has the full comparison:
the grades, where each match breaks, the places where living things contradict the model,
what was checked and what was not, which statements are this comparison's own reading or
rest on another search, and the sources.

## The Universe

*A reflection, and not a result.*

A system has a scope, and what lies outside one system is inside the next: a part, the
system that contains it, the system that contains that. For us, the universe is where that
recursion ends. We know of nothing outside it that we can observe. Every observer we know
of is inside it, shares its substrate, and would stop if it did. We observe it from the
inside.

The model rests on four constraints, and the fourth is that there is no outside party to
notice or repair. For a smaller system that is an assumption chosen for the design, or a
circumstance that could be otherwise, as for a solitary organism. At this limit we do not
choose it. It is as far as our observation reaches. To build to the model is to treat a
system, in this one respect, as if it were the outermost one we know of.

Whether the universe is gapless is in one sense an empty question. The model calls a state
bad against a standard of soundness, and the only standard we can check the universe
against is its own laws. By that standard nothing in it can be bad, so nothing bad passes
unseen. In any other sense the question stays open: we observe it from inside and cannot
tell how much of it we see, so observation cannot settle it. The universe shares that much
with the status the author gives the systems built on this model: it is not proven
gapless. This says nothing about what lies beyond our observation.

The only others on this page with no gap are systems of the model itself, the reference
system and those that Theorem S covers among them. They are models, so it can be proved of
them, and it is. The universe and the reference system have no gap for opposite reasons. The
universe has none in the empty sense, because by the standard of its own laws nothing in
it can count as a fault. The reference system has none, at one fault per round, because
every fault is seen and the work is stopped.
