# A Lean 4 Formalisation Of Self-Observing Systems

The model check in this kit writes a model of self-observing systems down exactly, checks
small systems by exhaustive search, and proves general results in writing. A written proof
is checked by whoever reads it. This folder takes the next step. It restates the model in
Lean 4, a proof assistant, and proves the main results there.

A proof assistant is a program that checks every step of a proof against the rules of
logic. A step it cannot justify is rejected, so nothing rests on a reader finding a proof
convincing.

## The result

Two results of the model check are proved in Lean.

The first is general. Take any system of monitors and work processes, of any size, that is
plain and whose wiring meets four conditions. Let at most one fault land between two
rounds of checks. Then, whatever the environment does and however long the system runs, no
state is ever bad without a live, correct monitor having flagged it, and no work is ever
done while a state is bad. Such a system has no gap. This is Theorem S of the model check.

The second is about the model check's reference system, which has the eight properties. At
one fault per round it has no gap. Take away any one of ten features, the eight properties
among them, and a gap opens.

Lean's kernel accepts the proofs, and so do four independent checkers.

`results.md` in the model check gives the full account of the model. This page says what
is proved in Lean, what "checked" means for it, and what is still to do.

## Overview

### The fourteen statements

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

### Level of assurance

The model check's README sets out four standards a result can be held to: an argument in
prose; a precise model with written proofs; exhaustive checking of a finite system; and
machine-checked proof. It places the general results of the model check at the second, and
says that nothing there is at the fourth.

The fourteen statements above are at the fourth. Theorem S moves from the second standard
to the fourth. The reference system's result and the ten removals move from the third to
the fourth, at one fault per round. Every other result of the model check stays where that
README puts it.

One question lies outside all four standards, here as there: whether the definitions say
what the words mean. The model check translates the framework's words into a
specification. This folder translates that specification into Lean. A result about the
Lean model is a result about the specification only as far as the second translation is
faithful, and no program can check it. The files that hold the translation are short, and
they are listed under "What is here".

### What "checked in Lean" covers

What a claim of "checked in Lean" is worth depends on what was checked. A post on the Xena
project blog,
["...and the proof is checked in Lean"](https://xenaproject.wordpress.com/2026/11/12/and-the-proof-is-checked-in-lean/)
(November 2026), sets out four questions to ask of any such claim. This folder takes them
in the post's order.

| Question | How it is answered | Answer |
|---|---|---|
| Does the Lean statement say what the plain-language claim says? | by reading; the definitions are in four files that import nothing outside this folder | an independent agent compared 73 clauses of the specification with the Lean and found none stated differently, then tested the Lean model against the model check's own checker; the reference system and its ten removals are proved equal, field by field, to the systems that checker builds, and a second agent read them and their statements against the checker's results and found that they agree |
| Does the code compile? | `lake build`, from a clean copy | yes, in under a minute |
| Does the proof prove that statement, with the standard axioms only? | `lake comparator`, Lean's own judge, in its sandbox | accepted, for all fourteen |
| Could a fault in Lean's checker have let a wrong proof through? | `lake comparator --paranoid`, which checks the proofs again with every independent checker shipped with Lean | accepted by Lean's kernel in both its forms and by four independent checkers |

## What is here

```
SelfObserving/Model.lean        the model: a system, a state, the environment's steps, one
                                round, the two goals, executions. It follows model-spec.md
                                section by section (291 lines)
SelfObserving/Conditions.lean   what "plain" means, and the four conditions (61 lines)
SelfObserving/Systems.lean      two named systems: the full mesh and the unwatched work
                                process (47 lines)
SelfObserving/Reference.lean    the reference system and its ten removals, as one
                                definition with a switch for each feature (145 lines)
SelfObserving/Challenge.lean    the fourteen statements, with the proofs left out (87 lines)
SelfObserving/Solution.lean     the proofs of the fourteen statements (370 lines)
SelfObserving/Proofs/           four files. Three carry the proofs for the reference
                                system: they make one round computable, and say what each
                                computation establishes. The fourth states the agreement
                                with the checker (1,143 lines)
SelfObserving/Generated/        six files written by tools/gen.py from the model check's
                                checker: the systems as the checker builds them, the
                                executions that show each gap, and the lists of reachable
                                states (2,503 lines)
tools/gen.py                    the generator, with its own README
comparator.json                 tells the judge which statements to compare and which
                                axioms to permit
lean-toolchain                  pins the version of Lean
lakefile.toml                   the project file for Lake, Lean's build tool
lake-manifest.json              Lake's list of dependencies, which is empty
SelfObserving.lean              the root of the library that lake build compiles
living-things.md                the full comparison with living things that this page
                                summarises: grades, limits, sources
```

To trust the result, read the first five files against `model-spec.md` and sections 5 to
7 and 10.1 of `results.md` in the model check. They hold definitions and statements and no
proofs. Nothing else needs to be read. The kernel checks the rest, and the judge confirms
that `Solution.lean` proves the statements of `Challenge.lean` and no others.

The project imports nothing outside the Lean core. A set is written as a yes-or-no
question about each element: `s.alive p` reads "is `p` alive in state `s`".

## The method

1. **Transcribe the model.** Each clause of `model-spec.md` becomes a Lean definition, in
   the order of the specification, with the section number beside it. The transcription
   covers the whole model, including the four kinds of fault and the two timing variants
   that Theorem S does not use.
2. **Keep the statement apart from the proof.** The definitions and the statements sit in
   files of their own, so that a reader can check what is claimed without reading how it
   is proved.
3. **Prove Theorem S.** The proof follows the written one in `results.md`. From a state in
   which nothing has happened, a round with no fault changes nothing. A round with one
   fault ends with a live monitor flagged and every work process halted, and the model
   ends there.
4. **Guard against an empty statement.** The two smaller statements show that the
   theorem's conditions can hold and that its conclusion can fail.
5. **Define the reference system.** One Lean definition follows the checker's builder,
   `reference(without=...)`, line for line, with a switch for each of the ten features.
6. **Prove its statements by computation.** The reference system is finite, so one round
   of the model can be made computable for it, and that is proved once. Lean's kernel then
   works each result out on the project's own definitions. That no execution violates a
   goal is shown by a list of states that holds the start and that every round maps back
   into, with no violation on the way. That some execution violates a goal is shown by one
   such execution. The Python checker supplies the lists and the executions and nothing
   else. A statement that is false of the Lean model fails, whatever the Python says.
7. **Judge.** `lake comparator` builds the statement file and the proof file separately,
   confirms that each proved statement is the stated one, checks that only the permitted
   axioms are used, and replays the proofs in the kernel. With `--paranoid` it replays
   them in every other checker shipped with Lean.
8. **Compare with the specification.** A separate agent, which has not seen the proofs,
   reads the Lean definitions against the specification clause by clause, and proves in
   Lean that executions the model check's own checker reports do occur in the Lean model.
   A second reads the reference system and its statements against the checker and its
   recorded results.

## The run

- **Models.** Claude Fable 5.2 wrote the Lean definitions and the proofs, from the
  specification of the model check. The two comparisons, with the specification and with
  the checker's results, are by separate agents of the same model, started fresh and not
  shown the proofs. The checks of the generated data are by other fresh agents.
- **Gates.**
  - *Build.* From a clean copy, with no dependencies to fetch: 28 build steps for the
    proofs, the slowest of them about a quarter of a minute, and under a minute in all.
  - *Axioms.* The statements depend on `propext`, `Quot.sound` and `Classical.choice`, the
    three axioms nearly all of mathematics in Lean uses, and on nothing else. The third
    statement depends on `propext` alone. No step is skipped with `sorry`, and no result
    is taken from compiled code: every computation is carried out by the kernel.
  - *Judge.* `lake comparator`, in its sandbox, on a clean copy under Linux: accepted, for
    all fourteen statements.
  - *Independent checkers.* `lake comparator --paranoid`: accepted by Lean's kernel in its
    default and paranoid forms and by `lean4lean`, `nanoda`, `con-leche` and `con-ron`. The
    last two ran in the mode they call `--verified`.
  - *Comparison with the specification.* A separate agent, which did not read the proofs,
    compared the Lean definitions with `model-spec.md` clause by clause: 73 clauses, none
    stated differently. Where the two are not the same in form, the Lean is the more
    general (it allows infinitely many processes, and does not enforce that `f` is at
    least 1), or the clause is a convention of the specification's file format. One thing
    is left out: the number of the round in which a gap first opens, which no statement
    needs. That comparison covered the model, the conditions and the two named systems.
  - *The reference system and its statements, read without the proofs.* A second separate
    agent compared `Reference.lean`, the two definitions that say a goal can be violated,
    and statements 4 to 14 with the checker and with sections 5 to 7 of `results.md`. The
    eleven systems match the checker's field by field, and so does every combination of
    removals, 1,024 in all. Each statement agrees with the checker's recorded result, and
    none claims more. The ten about removals claim less: they leave out the round in which
    the gap first opens. The agent also wrote the Lean definitions out by hand as a
    separate program and ran it beside the checker. On all eleven systems the reachable
    states and the outcome of every round were the same. The agent did not run Lean: what
    it says of the Lean rests on its reading of the text and on that hand-written copy.
  - *The reference system against the checker.* Every field of the reference system and of
    each removal is proved equal to the system the Python checker builds, as the generator
    writes it out. For the reference system and the three removals in which a goal is
    never violated, the reachable states of the Lean model are proved to be exactly the
    states the checker's search reaches: 23, 59, 239 and 228 of them.
  - *Checks of the generated data.* Fresh agents checked this part of the work in five
    passes. One derived all the generated data again from the Python with a script of its
    own, and found no difference. It also made 33 single changes to the files, of which
    Lean rejected 29 and accepted 4. Three of the four changed data, and one changed the
    model's rule for slow reports, which none of the eleven systems uses. Data changed in
    a way that leaves a statement true is accepted: an execution need not be the shortest,
    and a list need not be in the order of the checker's search. `tools/gen.py --check` is
    what shows that the files are still the generator's.
  - *Test against the model check's checker.* The agent that made the first comparison
    wrote a generator of its own, which turns a system into Lean statements of exactly
    what the Python checker computes for it, so that Lean has to prove each one. Lean
    proved all of them: every reachable state and every round of 22 named systems and of
    36 systems from the census, and 500 rounds on 200 random systems that use every kind
    of fault and both timing variants. As a test of the test, the agent changed one rule
    of the Python in each of 36 ways a transcription could go wrong, and Lean rejected all
    36.
  - *The two checks left over.* Two exhaustive checks of that test were too large to
    finish in one piece: the reference system without the gate (1,257 states) and without P7
    (2,565 states). They were completed afterwards, outside that agent's run. A
    script cut each generated file into parts at the boundaries between states, changing no
    statement and no proof. Lean checked each part as a separate file, four at once, and
    then the closing theorems that import them, and accepted both on the standard axioms.
    The results are the Python checker's: without the gate, detection first fails in round
    3 and no impact in round 1; without P7, both first fail in round 2.

  The files of the last two gates, and the records of the comparisons and of the checks
  of the generated data, are working files and are not part of this folder. In this
  folder, the statements about those two systems are proved by the executions that show
  their gaps.
- **What the kernel does and does not settle.** The kernel that accepts the proofs is a
  separate program from the model that wrote them, so a mistake that model makes
  consistently cannot pass it. The same is not true of the definitions. A definition that
  says the wrong thing compiles as well as one that says the right thing, which is why the
  comparison with the specification is a gate of its own.
- **The version of Lean.** 4.37.0-rc1, a release candidate.

## What is established

**Proved, and checked by machine.**

- Theorem S, for every plain system that meets the four conditions, of any size, at one
  fault per round.
- A full mesh of two or more monitors, with any work processes, has no gap at one fault
  per round.
- A work process that nothing watches has a gap.
- The reference system has no gap at one fault per round, whatever the environment does.
- Each of ten features of the reference system is needed: taking it away opens a gap. For
  three of them one goal still holds, and that is proved too.

## What is not established

- **That each property is needed in every system.** The removals are proved for the
  reference system. The model check's general results on what any system needs are
  written proofs and are not in Lean.
- **When a gap first opens.** The statements say that some execution violates a goal, and
  not in which round. The tests against the checker prove the round for some of the
  removals, in working files outside this folder.
- **More than one fault per round.** Every statement here is for one.
- **Restarting, and how fast a halt must travel.** Both are separate small models in the
  model check. Neither is in Lean yet.
- **Every clause of the model, by test.** The eleven systems of the reference family do
  not use every clause of the model. None has slow reports, and in none does a flag have to
  travel two report edges. For clauses like those, the faithfulness of the Lean model
  rests on the clause-by-clause comparison and on the tests with random systems.
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

| In the model | In living things | How close | Where it differs |
|---|---|---|---|
| Liveness signal | Silence is the signal. A healthy mitochondrion, the cell's power unit, keeps destroying a marker protein. When the unit fails, the marker builds up and the cell disposes of the unit. Oxygen is read the same way: while oxygen is present, the cell keeps destroying a protein, and when the oxygen stops, that protein builds up and switches on the cell's response to low oxygen. Tumour cells that lack the normal markers of self are rejected | Same structure, between two parts | Whatever reads the silence is itself watched by nothing. The response is usually a disposal or the death of the cell, and not a stop that can resume |
| Shared substrate | The observer is part of the machine that does the work. The attachment point on a chromosome both holds it to the fibres that pull it and hosts the check that it is attached, though the review cited calls part of that role "controversial". Two ribosomes colliding is itself the signal that protein-making has stalled | Partial | The halt needs the supply as well. Orderly cell death uses the cell's energy, and without it the same trigger gives a disorderly death |
| State check | Mismatch repair. After DNA is copied, the new strand is compared with the old one, and the old one is taken as the reference | Same structure | The reference is only the parent copy, so an inherited error passes. The repair is made without a halt |
| Propagation | Inside a dividing cell, one unattached chromosome holds back the separation of all of them | Same structure, within one cell | Across a body, the search found no single detection that stops everything |
| No single-step removal | Disabling one observer sets off a second. In bacteria, a virus that blocks one defence triggers another, which kills the infected cell. In animal cells, blocking one cell-death enzyme releases a second death pathway. Some observers are also essential: mice without them die as embryos | Partial | Removals in one step exist. A papillomavirus protein has the damage protein p53 destroyed. Cells slip out of a long arrest, and yeast go on to divide with a broken chromosome. Each backup can itself be removed by one more step |
| Out-of-boundary signal | A dying cell is seen from outside. It shows an "eat me" signal on its surface, and a cell that dies in disorder releases a protein that raises inflammation | Partial | True of a cell in a body. Nothing outside a solitary organism sees its loss |
| Automatic enrolment | A new cell inherits the genes for its checks (the search did not source this directly) | Partial | The checks are not always switched on. Frog embryos do not stop for damaged DNA before the twelfth division, and mouse egg cells do not wait for a few misaligned chromosomes |
| Immediate response | A reflex through the spinal cord answers pain in about 90 to 150 thousandths of a second | Partial | Many responses are slow |
| The gate | A dividing cell does not separate its chromosomes until the last one is attached. When the last unattached attachment point was destroyed with a laser, separation followed about 20 minutes later. A cell's survival is held the same way: cells depend on signals from other cells | Same structure | It leaks. Cells escape a long arrest with the check still active, and the check is weak in egg cells |
| The halt | An infected bacterium kills itself before the virus has finished copying, which protects the colony. A plant cell at the site of an infection does the same | Same structure, for a cell in a body or in a colony of relatives | A free-living single cell does the opposite and carries on. Mature nerve cells, which are not replaced, block their own death. Halted cells that linger do harm |
| A member that starts first | The pacemaker cells of the heart fire by themselves. Slower pacemakers further down are held silent by the faster one and take over when it stops. Dormant bacteria wake on chemicals shed by bacteria that are already growing, so something has to wake first, and a few appear to wake at random | Partial | The pacemaker starts work, and not observers. The bacteria use a random first starter, and not a member different in kind |
| Naming the faulty one | Mismatch repair again. Two strands show that they differ, and cannot show which is wrong | Partial | Biology settles it with a mark of which strand is the original, and not with a third copy |
| The ring | Not found. The nearest is a guard on a guard, two layers deep | Loose to partial | The top layer is watched by nothing |

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

The only others on this page with no gap are systems of the model itself: the reference
system, and those that Theorem S covers. They are models, so it can be proved of them, and
it is. The universe and the reference system have no gap for opposite reasons. The
universe has none in the empty sense, because by the standard of its own laws nothing in
it can count as a fault. The reference system has none, at one fault per round, because
every fault is seen and the work is stopped.
