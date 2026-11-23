# A Model Check Of The Eight Properties And The 3+1 Ring

The kit in this repository audits a system against a model of self-observing systems. The
model holds that where an unnoticed failure would be catastrophic, everything that matters
has to be observed. Under four constraints it arrives at eight properties every observer
must have, and at a structure: a ring of three observers that watch each other, plus a
coordinator, with the work stopped on any detected fault.

This folder tests that claim. It writes the model down exactly, checks it by
exhaustive search on small systems, proves what can be proved for systems of any size, and
has each step checked by independent agents.

## The result

Under the four constraints, and against every kind of fault in the model, a reference
system that has the eight properties, and whose work runs only on a current observation,
has no gap at one fault per round. A gap is an execution in which a bad state goes
unflagged or work acts while a state is bad. A round is one check by every observer. None
of the eight can be removed from the reference system without opening a gap. For any
system of a stated class, at one fault per round, four conditions on the wiring are enough
for no gap. Each property is defined by what it does. Written as fixed rules about which
observer reads which, the eight are not enough alone: a ring of three in which each
observer reports to the one it checks satisfies every such rule and has a gap, because a
detection there does not reach the work. No kind of fault was found that the eight do not
answer. The claim stands until one of the framework's falsification criteria is met. Three
were tested here and none was. The fourth, independent reproduction, was not tested.

`results.md` gives the full account, in the vocabulary of fault-tolerant distributed
computing. This page summarises it.

Two later pieces of work extend the model, each in a folder of its own. `join/` lets
monitors join a running system. `least-ring/` asks which ring of four is the least, and
how it repeats one level up. "Two extensions", further down, summarises both.

## Overview

### The eight properties

Each is something that must be true of a system's observers.

| Id | Property | What must be true |
|---|---|---|
| P1 | Liveness signal | an observer's silence triggers a response |
| P2 | Shared substrate | work cannot run where its observer cannot |
| P3 | State check | a state that goes bad without a sign is seen |
| P4 | Propagation | one detection stops the whole system |
| P5 | No single-step removal | there is no sanctioned way to stop an observer checking |
| P6 | Out-of-boundary signal | an observer's loss is seen from somewhere that survives it |
| P7 | Automatic enrolment | nothing exists unobserved |
| P8 | Immediate response | the response has no window, and outpaces the fault |

Two requirements have names of their own in what follows. The *gate*, which the eight do
not name: the observers check before any work is done, so work runs only on a current
observation. The *halt fan-out*, a clause of P8 taken separately: work takes its halt from
at least two observers, and a halt is passed on to at least two more.

### What the structure does

Ordinary monitoring runs in the order impact, time, stop. A fault acts, something
notices, someone decides, and the work is stopped. Here the work does not act on a state
its observers have not examined, so the stop comes first. The impact of a fault is bounded
by one check interval, whatever a response would take.

The structure does not ask why a state is bad. A bug shipped in a release that makes a
checked state bad is stopped the same way as a compromise. The bug's effect in production
is bounded by one check interval, and after that it is the halt itself, on the rule that
stopping completely is better than running unverified.

### Costs and benefits

| | |
|---|---|
| Cost to build | once; the kit's skill finds what is missing |
| Cost to run | set by the substrate, and fixed for each ring because growth adds rings and never makes a ring bigger. The whole grows with the number of rings and with nothing else |
| What it gives | every known failure mode watched; impact bounded by one check interval; a response that reaches the whole system and keeps pace with a fault that grows; recovery without an outside hand |
| Left to the implementation | the response itself, chosen so that a false trigger is cheap; how often to check; how many faults between checks to cover; the scope |
| Limit | the scope of the implementation |

### Scope and limits

Inside the scope of the implementation the model has no gap. The scope has one edge, met
from three sides.

- **Outward: a fault as wide as the whole substrate,** such as an asteroid strike. The
  system cannot see it, and the work goes down with the observers. The loss is real, and it
  is not a failure of the system: no part of it acts while the fault stands.
- **Downward and sideways: what the system depends on and did not write.** The substrate
  beneath and the services beside. They are listed and not seen into.
- **Inward: what is left to vary unchecked.** A fault that passes every check the system
  makes looks like health. It can exist only in a part of the system that is allowed to
  vary. A part that is fixed, and checked against a reference, is out of its reach, so the
  more of a system is fixed, the smaller this side becomes.

At the edge there are two choices. Raise the scope: add the level, the boundary or the
check that brings the fault inside. Or accept the risk and cover it from outside, for
example by review. The second is the owner's decision to make, and it leaves a named gap:
a check made at intervals by someone outside the system does not satisfy the model.

Where the scope can grow no further, the last level is a ring. Its members watch each
other, so nothing sits unwatched at the top.

### Applicability

The model applies to any system, on any substrate, in which the four constraints hold:
no central controller; an unnoticed failure that costs far more than a false alarm; faults
that can look like health; and no outside party to notice or repair.

The model has been applied well beyond this folder. The kit's calibration runs cover Go,
Python, Rust and TypeScript projects, from a single library to an aggregate of eleven
infrastructure packages. Four cases are provided here.

- Built on the structure: an observer ring around the ghostunnel proxy, and one around the
  Platform Racing 2 server (links at the end).
- Audited against it, outside software: the Chernobyl reactor and the United States
  Constitution, in `../examples/chernobyl` and `../examples/constitution`.

Some systems of the kind it suits. These are illustrations, not results of the model
check.

| System | The work | What must not be acted on | The response |
|---|---|---|---|
| A proxy or gateway | accepting connections | an access decision that does not match the rules on record | refuse new connections, close those in flight |
| A payment or ledger service | posting entries | a ledger that fails its own reconciliation | stop posting; reads may continue |
| A sign-in or token service | issuing tokens | signing material or policy that differs from the reference | stop issuing |
| A release pipeline | promoting a build | an artefact whose digest differs from the one that was built | stop the rollout |
| A database failover controller | promoting a replica | two primaries, or a replica behind the record | fence writes |
| A backup job | replacing the last copy | a new copy that fails a restore check | keep the last good copy and stop |
| An agent runner or sandbox | letting the workload act | confinement that cannot be shown to be in place | stop the workload |
| A plant or device controller | actuating | a reading outside the envelope, or a silent sensor | go to the safe state |

### Level of assurance

A result of this kind can be held to several standards. In rising order:

1. **An argument in prose.** Reasoning that a reader follows and judges.
2. **A precise model with written proofs.** The definitions are exact enough to implement,
   and each proof can be checked step by step by a reader. Published proofs in mathematics
   and computer science are held to this standard.
3. **Exhaustive checking.** A program explores every reachable state of a finite system
   and reports whether a property holds. For that system the answer is certain. It says
   nothing about a larger one. The method is called model checking. TLC, for the TLA+
   language, is a widely used model checker.
4. **Machine-checked proof.** A proof assistant is a program that checks every step of a
   proof against the rules of logic, so that no step rests on a reader's judgement.

Where this work stands:

- **The model** meets the second standard. It is specified completely in `model-spec.md`,
  precisely enough that an agent given only the specification and the cases reimplemented
  it and reproduced the result of every case. The growth process, the restart game and the
  TLA+ module are separate small models, stated in `results.md` and in the checker.
- **Results about named systems** meet the third. Each comes from an exhaustive search.
  The checker was written for this work, and the evidence that it is correct is that an
  independent implementation agrees with it on all 103 cases.
- **Results about systems of any size** meet the second. Each is proved in writing, and
  each was proved again or tested by an independent agent. They have not been through peer
  review.
- **Nothing in this folder is at the fourth standard. Part of the work now is, in
  `../lean-proof/`.** That folder restates the model in Lean 4, a proof assistant, and
  proves ninety-six statements there. From `results.md`: Theorem S; that the reference
  system has no gap while each of the ten removals opens one; most of the general results
  on what any system needs; the mesh at any number of faults per round; restarting; how
  fast a halt must travel; and naming a faulty monitor. Written for the Lean work: a form
  of Theorem S for systems that are not plain. From the two extensions: Theorem J and
  Theorem F, the ring of `k` members, the least ring for two of its requirements, the ring
  one level up at every number of levels, and growth by joins. Its `statements.md` lists
  them one by one.
  Everything else stands where this list puts it, and the model has not been ported to an
  established model checker. A machine-checked proof guards against a slip in a proof. It
  does not change what is claimed.

One question lies outside all four standards: whether the definitions in the model say
what the framework's words mean. The framework is stated in prose and the model in
definitions, so each constraint and each property had to be translated. A result about the
model is a result about the framework only as far as that translation is faithful. No
program can check it. Section 3 of `results.md` sets the two side by side.

The model check establishes properties of the model. Whether an implementation conforms to
the model is a separate question, assessed by auditing the implementation with the kit's
skill. Confidence in an implementation increases with repeated audits.

## What is here

```
results.md               the results, the proofs and the verification record
model-spec.md            the model, stated completely
check_model.py           the checker, and every system it was run on
run-output.txt           its full output
results.json             every case with its result
systems-all.json         the 103 cases, without their results
Heartbeat.tla, .cfg      one property, the liveness signal, as a TLA+ module
verification/            one folder for each independent pass: what it was given, what it
                         wrote, and the code it wrote for itself. The final round, with
                         its reports, is in g-final-round/
join/                    the first extension, monitors that join: results-join.md,
                         model-spec-join.md, the checker extended, a catalogue of 5,658
                         cases, and the records
least-ring/              the second extension, the least ring and the ring one level up:
                         part-a.md, results-minimal.md, model-spec-scope.md, the
                         programs, a catalogue of 465 cases, and the records
```

The two extension folders are the folders the work was done in. Each holds what was
asked for (`brief.md`), what the author handed back (`handback.md` and the corrections
after it), and a folder for each independent check (`verify-impl`, `verify-proofs` or
`verify-reader`, `verify-corrections`) with what it was given and what it wrote. In those
records `«WORK»` stands for the folder that held the work, and `«SCRATCH»` for a temporary
folder that is not here. Where a record quoted the author's own messages, this copy gives
them in paraphrase. `join/` was `sos-join-model\join\` there, with `brief.md`, the
hand-backs, its three `verify-` folders and a copy of this model check beside it and not
inside it, and `least-ring/` was `sos-minimal-ring\`. So the write-ups name some files
without their folder: `results.md` and `check_model.py` are at the top of this folder, and
what `least-ring/` names of the first extension is in `join/`. To run from where they now
are, six programs of `least-ring/` had the lines that build folder paths changed, and two
sentences of `results-minimal.md` name the folders as they are here.

## The method

1. **A model.** Processes are of two kinds: work processes, and monitors that watch them
   and each other. An environment causes faults. It can stop a monitor, stop every monitor
   in one boundary, fail a substrate, corrupt a state without any sign, switch a monitor
   off, and add a process. Time runs in rounds: at most `f` faults, then every monitor
   checks, then every work process either halts or works. The order, monitors before
   work, is the gate. `model-spec.md` defines all of it.
2. **Two judgements.** *No impact:* no work process acts while any state is bad. The model
   takes this judgement as the goal. *Detection:* when a state is bad, some live, correct
   monitor has flagged. Both are reported, because together they say which half failed. A
   system has a *gap* if some execution breaks either one.
3. **A checker.** `check_model.py` explores every reachable state of a small system and
   returns the shortest execution, if there is one, that breaks a judgement.
4. **Proofs.** Where a result is meant for every system of some class, of any size, it is
   proved, and the proof is in `results.md` or in a verifier's folder.
5. **Counting.** How fast a halt must travel against a fault that doubles is arithmetic on
   a growth process.
6. **Independent verification.** A separate agent, started fresh for the purpose, checked
   each phase up to the falsifier search. Each was given only the artefacts: the
   specification, the cases, the code, or a claim as a bare statement. Three results added
   afterwards did not
   get that check: the restart result, a second argument for the shared substrate, and a
   case that shows one missing edge at two fault rates. Nor did the TLA+ module or the
   comparison with the implementation. The final round covered all of them. The next
   section gives each pass and its counts.

## The run

- **Models.** The author's work and every verification pass ran on Claude Fable 5.2. Each
  verifier was a separate agent, started fresh for its pass in a folder of its own. Passes
  A to F were given the artefacts to check and never the author's reasoning, expected
  results or proofs; the checker given to B carries its own comments and nine of the ten
  schedules. The final round was given the two documents and the folder.
- **Gates.** Six passes, each in its own folder under `verification/`.
  - *Reimplementation (A).* An implementation written from the specification alone agrees
    with the checker on all 103 cases: 101 computed by the pass, and the last two
    afterwards by its code, unchanged. It reported ten points of ambiguous wording. The
    alternative readings it ran, for five of the ten, changed no result, apart from one
    reading the text excludes. For the other five it ran none.
  - *Review (B).* The reviewer compared the checker with the specification clause by
    clause and found no deviation in the model. The review lists eight deviations at the
    edges of the script. The author fixed the four that were defects in the script's code.
    One, that the script does not validate its input, stands. The other three concern the
    docstring, the files that section 5 of the specification names, and parts of the script
    that the specification does not cover. The
    reviewer's own implementation agrees with the checker on 94 cases, 1,648 random
    systems and 600 variants of the reference system. The reviewer forced eight of the
    nine removals onto 400 random systems each, and the gap appeared every time. The
    ninth, propagation, the reviewer showed to depend on wiring.
  - *Provers (D and E).* Fifteen general claims, given as bare statements with no proof.
    All fifteen hold under the reading each prover chose. Three needed one of two wording
    fixes, and D returned sharper growth bounds than the ones claimed.
  - *Falsifier (F).* Three deciders of its own, and the search described under "What is
    established": five sizes, up to 2^44 systems.
  - *Final round.* Two verifiers checked every claim in this page and in `results.md`
    against the folder, as the two documents then stood, one reading from the first
    section to the last and one from the last to the first. Forwards: 422 claims, of which
    357 confirmed, 40 narrowed, 4 wrong and 21 not checkable. Backwards: 494 claims, of
    which 423 confirmed, 40 narrowed, 4 wrong and 27 not checkable. Each ran the checker in
    full and reproduced `run-output.txt` and `results.json`. A third agent merged their 88
    entries into 52 points and ruled on each from its own recomputation or reading: 13
    accepted, 21 accepted with a change, 11 reworded, 7 kept, none rejected whole. It
    marked four rulings in which a verifier's own correction was unsafe, and raised nine
    further points. The author applied all of its rulings and edited some of the wordings
    it gave further. The correction added passages those three agents had not seen. A
    fourth agent then swept the corrected documents and the folder: 724 claims, of which
    677 confirmed, 37 narrowed, 5 wrong and 5 not checkable, with 7 entries on style and 13
    on sense. It ran the checker in full and reproduced all three output files. The author
    applied its corrections, and a last agent checked the passages they changed: 252
    claims, of which 225 confirmed, 18 narrowed, 1 wrong and 8 not checkable, with 9
    entries on style and 13 on sense. It ran the checker in full with the same result, and
    refereed the proof written in answer to the sweep. The author applied those corrections
    too, and a further agent checked them: 183 claims, of which 167 confirmed, 8 narrowed,
    2 wrong and 6 not checkable, with 4 entries on style and 5 on sense. The author applied
    its replacements by script. No pass of the final round found a result of the checker
    wrong: every correction it led to was to the wording around a result.
- **Not blind.** An agent started in the workspace where this was done can see that
  workspace's one-line description of the framework. Every verifier therefore knew the
  conclusion being claimed. The verifiers were independent of the reasoning here.
- **One model.** Author and verifiers are the same model. A mistake that model makes
  consistently would pass every gate. For results about named systems, the
  reimplementation and the exhaustive searches guard against it. The written proofs have
  no guard of that kind in this folder, and have not been through peer review. Theorem S
  and most of the results on what any system needs are also proved in Lean, in
  `../lean-proof/`, where a separate program checks the proofs.

Section 13 of `results.md` records what each pass was given, what changed because of it,
and what the passes before the final round did not cover. Each folder under
`verification/` but that of the final round holds the specification as it stood when that
pass ran. The copies for A, B and D lack section 3.6 and its two fields (A has them as
`spec-addendum.md`) and eight later clarifications; those for E and F are identical to
`model-spec.md`. The author replaced local paths in the verifiers' scripts and reports by
paths relative to each file, and changed nothing else in those folders. The files that
hold the reports of passes A and B and of the final round say that they were saved from
the hand-backs, word for word.

## The argument has two halves

The model lists the kinds of fault first, and then writes each property as the thing that
catches one of them. That decides what a checker can and cannot show.

- **If these kinds of fault exist, each property is needed, and together they leave no
  gap.** The checker and the provers supply this half.
- **These kinds of fault exist.** No checker can supply this half. The four constraints
  assert part of it: that a fault can look like health, and that nobody is on hand to
  notice or repair. The rest is a claim about the systems being modelled: that a process
  can stop, that a whole boundary can be lost at once, that processes join.

A system built on a substrate whose rules its builder wrote has both halves: the kinds of
fault are whatever the rules permit. The model here is such a system, which is why "no
gap" could be proved in it.

## What is established

**Proved, for every system of a stated class.**

- Every guarantee is relative to a fault rate, a scope and what is checked. If every
  monitor can be faulted between two checks, or all can be stopped in one step, no
  arrangement inside the system survives. A fault that changes nothing any monitor reads
  is seen by none.
- A monitor that no other monitor checks, or a set of `f` or fewer monitors that nothing
  outside the set checks, leaves a gap.
- A work process with `f` or fewer halt sources keeps working after they are all mutated.
- A full mesh of `n` monitors holds exactly when `f` is at most `n - 1`.
- **Theorem S.** Four conditions on the wiring are enough for any plain system (no joiner,
  substrates, switches, shared boundary, window or delayed reports; the gate and the halt
  on silence in place), of any size and depth, to respond completely to every single
  fault.
- Two monitors cannot name which of them is faulty. Three can.
- With an evaluation window, or without the gate, in any system with a work process
  present from the start, the environment can make a work process act while a state is
  bad.
- When reports take time and no other fault lands, a work process that goes bad acts once
  for every hop between the monitor that checks it and the monitor that stops it.
- **Theorem R.** Members that start only once another member has started cannot restart
  from a full stop, so one member must be able to start first. The ring can then always
  restart exactly when every other member is reached from that member, which was also
  checked on every ring of three and of four members.
- A halt passed to one process per hop is outrun by a fault that doubles, at any speed. A
  halt passed to two keeps pace at two hops per doubling. Both results are for a halt that
  reaches good processes first.

**Checked, exhaustively, on named systems.**

- A reference system with all the properties has no gap at one fault per round. Removing
  any one of the eight, or the halt fan-out, or the gate, alone, opens one.
- A full mesh of four monitors holds at one, two and three faults per round. Both
  implementations build this ring: three members and a coordinator, every member watching
  every other.
- Recursive interleaved rings on two levels hold at one fault per round, including when a
  whole base ring is lost in one step. Removing one edge at a time, 23 of 55 are needed.
- The same missing edge is no gap at one tier and a gap at the next. Three monitors with
  one signal that nobody reads have no gap at one fault per round and a gap at two.
- A ring of three is fully stopped after one stop and cannot come back. With a member
  that can start first, and from which the rest are reached, it always can.
- 103 cases in all. An implementation written independently from the specification agrees
  on every one.

**Checked, exhaustively, by an independent agent.** Every plain system with two or three
monitors and one or two work processes was decided at one fault per round, one by one or
wiring by wiring, and every plain system with four monitors and one work process by
counting. State checking and two halt sources hold in every system with no gap. The edge
by which a silence is read, and the edge by which a flag reaches the work, vary from
system to system. Written as fixed edges between monitors, one or the other of those two
properties fails in most of these systems, and the agent's verdict on the claim in that
form was that it is false. Two things do not vary. Another monitor, or the work, reads the
silence of every monitor the system depends on. A bad state is flagged and stops the work
in the round it appears, which is what no gap means in these systems. A flag raised for a
silence alone need not stop the work: in one system with four monitors it does not.

## Two extensions

Both were made after the work above and by the same method: an author, an implementation
written by another agent from the specification alone, and independent readers, with every
correction recorded. Each has its own specification, programs, catalogue and results, and
uses the kinds of evidence that `results.md` defines.

**Monitors that join (`join/`).** In the model above every monitor is present from the
start. `model-spec-join.md` lets a monitor be absent at the start and join by a step of
the environment, alone or in a group. `results-join.md` has the results.

- A system can be grown by joins without end. The number of faults per round at which it
  has no gap stays exactly the starting ring's, at every size and whichever monitors each
  new one is attached to. This is proved for the class (Theorem L and Lemma N) and checked
  on 12,324 grown systems of five to twenty monitors.
- It holds under four conditions. A state check of a new monitor is in force in the step
  that adds it. No monitor joins before a monitor that checks it. Every work process,
  whenever it is present, has a present state checker and more than `f` present halt
  inputs. Reports arrive within the round.
- A joining monitor that nothing depends on needs one edge: an existing monitor that
  checks its state. One that later monitors or a work process lean on needs three: its
  state checked, its signal read, and a report from it (and a fourth at three faults per
  round when work takes its halt from it).
- Theorem J is a sufficient condition for no gap at any number of faults per round, in a
  plain system: the monitors connected by pairs that watch each other and report to each
  other, every work process with a state checker and more than `f` halt inputs, and more
  than `f` monitors.

**The least ring (`least-ring/`).** `part-a.md` takes the ring of three members in a cycle
and a coordinator connected to each both ways, nine connections, and asks whether fewer
would do. It checks all 4,096 wirings of four monitors against a list of six
requirements. `results-minimal.md` goes on to wider rings, to three rings under a top
coordinator, and to getting from one ring to three by joins. `model-spec-scope.md` extends
the model so that a flag carries the scope it was raised for and a halt can stay within one
ring.

- Whether nine is the least depends on what a connection is taken to carry. Of the 27
  readings in which it carries all three kinds of edge, the ring is least under six, one
  connection over under twelve, short of "two observers each" as stated under six, and
  four over under three.
- A ring of `k` members and a coordinator, the work reading every monitor, has no gap
  exactly when `f` is at most `k`.
- Three such rings under a top coordinator, the three ring coordinators in a cycle, have
  no gap at one, two and three faults per round as one system, when each ring's work reads
  its four monitors. So has the same structure at every number of levels, when every
  monitor is in a boundary of its own.
- Judged scope by scope, a fault in one ring halts that ring's work, the other two go on
  working, and the upper ring holds a flag for the ring at fault. This is checked at
  thirteen monitors and one fault per round, when nothing more lands in a ring that has
  halted.
- Grown by joins with the top coordinator first, the three rings have no gap at one, two
  or three faults per round as one system. With the top coordinator last, the order first
  tried has a gap at one fault per round. Under one of the two readings worked through in
  full it cannot be last in any order, and under the other, two orders with it last have
  no gap.
- Nine connections per ring is the least among structures built as rings of rings in
  which each ring meets the list by itself, under one reading of a connection and of the
  requirement on reports. Judged as one flat system of thirteen monitors, fewer are enough
  for five of the six requirements.

The order in which monitors and rings are attached is the builder's choice, so long as the
conditions hold at each step. Theorem J with joins asks only that its conditions hold in
every set of present processes the joins can reach. Removing or moving a connection is not
in the model.

Many of the general results of both extensions are also proved in Lean, as statements 63
to 96 of `../lean-proof/statements.md`. The results with scopes are not.

## What is not established

- **Uniqueness.** No finite check can show that the ring is the only structure that
  works. The claim can only be refuted, by a system that meets all four constraints, has
  no gap and is not a variant of the ring. None was found.
- **The second half of the argument.** That the kinds of fault in the model are the right
  ones, and that none is missing. The implementations test that.
- **More than one fault per round, on an arbitrary wiring.** The necessary conditions are
  proved and the full mesh is settled. `results.md` gives no general sufficient condition.
  Theorem J of the first extension is one. It is not also a necessary condition.
- **Recovery beyond restarting.** Lifting a halt while a fault may still be present, and a
  second fault in a halted system, are not modelled. How a bad state is repaired belongs
  to the implementation.
- **Unbounded delay.** The model gives every monitor a step after at most `f` faults.
- **TLC.** The author traced the TLA+ module by hand and against a copy in the checker. It
  has not been run through a model checker for TLA+.
- **Independent reproduction.** Whether someone starting from the four constraints alone
  arrives at the same structure was not tested here.

## Against the falsification criteria

| Criterion | Result |
|---|---|
| An alternative stable configuration | not met: none found that meets all four constraints |
| An unnecessary property | not met: each of the eight, removed whole, opens a gap in some system, which rules out a proof that it is removable |
| A fifth constraint | not met by anything tried, open in general: what the model needed beyond the eight was either an emergent requirement or the implementation's choice |
| Non-convergence under reproduction | not tested |

## Function and form

A property is something that must be true. A system realises it in some form, and the
form varies with scale. In a system of three, the work can read every monitor directly,
and no flag has to pass between observers. In a large one it cannot, and the flag has to
travel. Several results in `results.md` that look like exceptions are of this kind: a
different form of the same property at a different scale, which the scaling law says
should vary. The full structure is the ceiling. Lower tiers need part of it.

## Design notes

These follow from the results, except where a note says otherwise, and are not results
themselves. Several make a property hold by how the system is built, so that no check has
to run for it.

1. **Share the whole dependency set, not only the compute.** Put the observer on
   everything the work depends on. No failure underneath can then leave the observer up
   and the work wrong.
2. **Make the halt a shared fact that everything reads before acting, and have more than
   one.** A single replicated flag reaches the whole system at once, with no chain of
   messages for a fault to outrun. Put a second halt on a different substrate. Make at
   least one of them take away the ability to act: a faulty worker cannot be relied on to
   obey a flag.
3. **Check for the ability to remove an observer, not only for its removal.** Verifying
   that nothing holds that permission closes the gap before anyone uses it.
4. **Compare against the complete set of what should exist.** If the reference is the
   whole inventory, in order, with its permissions, anything unaccounted for is a finding.
   New things come under observation in the same stroke.
5. **Interleave the boundaries.** Arrange observers so that a loss spanning neighbouring
   boundaries still leaves one outside it. Two for each scope, in separate boundaries, is
   the smallest version.
6. **Use the platform's own primitives as the checks.** A read of a flag, a permission
   query and an inventory comparison each resolve in one step, which keeps the response
   faster than the fault.
7. **Fix everything that can be fixed.** Turn what must vary into a record checked against
   a fixed rule.
8. **Where no machine check reaches, name the gap and cover it with review.** Review sits
   outside the model.
9. **Deploy observers before workers, and plan the build order.** Bring the ring up first,
   and start the work only once the ring is running and healthy. Once the gate is in place
   the wrong order is safe, because work that finds no observers refuses to run. Until
   then it is not. While a ring is being built the system has gaps: some observers do not
   exist yet, and the work may not check the ring at all. The order in which the parts are
   built and switched on decides which gaps are open and for how long. For the most
   critical systems, plan that order as carefully as the design.
10. **Bring a new ring member in through the checks the ring already runs.** Members
    already check each other's health. A new member can mean that an existing member has
    to change which member it observes. The observers that know of the new member watch it
    from the start, and check in each cycle whether it has come up. No observer changes
    what it observes until the new member is running, healthy and sending its reports
    round the ring. The observers that have been watching for that change then take up
    their new observations, and each drops its old one last. While the old and the new
    overlap, the ring has more observation than it needs and loses none, so no member is
    left unobserved at any point. The model check covers a work process joining and does
    not model a ring member joining, so this note goes beyond what was checked.
11. **In a running ring, tell a member that has never run from one that has stopped
    running.** Both are silent, and they mean different things. Nothing depends yet on a
    member that has never run: it is a join in progress, handled as in the note above.
    Something did depend on a member that ran and stopped: it is a loss, and the response
    fires. A record that the member was seen once is enough to tell them apart. Without
    the distinction, a join reads as a loss, or a loss is excused as a member that has not
    started yet. At a cold start no member has run, and the work refuses as in note 9. A
    declared membership in which any absence halts, as in ghostunnel's ring (section 10.5
    of `results.md`), is the stricter choice. Like note 10, this note goes beyond what was
    checked.

## A reference system, and the skill

`check_model.py` and the reference system in `results.md` show the model at its smallest:
each property as one relation or one setting, and the execution that follows when that one
thing is missing. They are a reference for the model. To compare a real system against the
model, use the kit's skill, in `../sos-threat-model`.

## Running it

```
python -I check_model.py            summary tables
python -I check_model.py --traces   also print the ten executions of section 6 of
                                    results.md and the shortest execution that breaks
                                    each judgement
```

It needs Python 3.9 or later and nothing else. A full run takes several minutes and about
two gigabytes of memory at its peak. `run-output.txt`, `results.json` and
`systems-all.json` were made by adding `--json results.json --systems systems-all.json`.

## The implementations

Two rings built on this structure are public:

- an observer ring around the ghostunnel proxy:
  <https://github.com/QupDrawn/ghostunnel> (branch `portal`, at commit `0741dac`; its
  specification is `observers/SPEC.md`);
- an observer ring around the Platform Racing 2 server:
  <https://github.com/MinichordDrawn/platform-racing-2-server> (branch `drawn`, at commit
  `b8066d0`).

Section 10.5 of `results.md` sets the model beside the first of them, row by row, with a
citation to the specification for each. In both, a halted observer keeps cycling. In
ghostunnel's, the coordinator lifts its halt first, and only after it has checked every
other member (section 10.3 of `results.md`).

## Licence

The documents and result files in this folder are under [CC BY
4.0](https://creativecommons.org/licenses/by/4.0/), and the checker, the programs of the
two extensions, the verifiers' code and the TLA+ module under the MIT licence. See
[LICENSE](../LICENSE).
