# A Model Check Of The Eight Properties And The 3+1 Ring: Results

This note answers two questions. Can the claim "each of the eight properties is necessary,
and removing any one opens a gap" be proved? And can the ring structure be derived from it?

It is written in the vocabulary of fault-tolerant distributed computing: processes,
faults, rounds, executions. An *execution* is a sequence of steps of a system from its
starting state. A *counterexample* is an execution that ends somewhere the goal says the
system must never be.

Four kinds of evidence appear, and each result says which it is:

- **Checked.** Every reachable state of a small, fully specified system was explored by
  `check_model.py` or, where the text says so, by a verifier's own decider. The result is
  complete for that system and says nothing about any other.
- **Proved.** An argument that holds for every system of a stated class, of any size.
- **Counted.** Arithmetic on a growth process.
- **Argued.** Reasoning in prose that is neither proved for a class nor checked. Each such
  passage is marked.

## 1. Results in brief

The eight properties are listed in section 3.1 and the two judgements, G1 and G2, in
section 2.4. R is the reference system of section 5. A system has a *gap* if some
execution violates either judgement. A *tier* is the class of fault a system is built to
cover: how many faults per round, and how wide a loss.

**The result.** Under the four constraints, and against every kind of fault in the model,
a reference system that has the eight properties, and whose work runs only on a current
observation, has no gap at one fault per round. None of the eight can be removed from it
without opening one. For any plain system at one fault per round, four conditions on the
wiring are enough for no gap (Theorem S, section 10.1). Each property is defined by what
it does (section 3.1). Written as fixed predicates on edges (section 3.2) the eight are
not enough alone: a ring of three in which each monitor reports to the monitor it checks
satisfies every predicate and has a gap, because a detection there does not reach the work
(section 6, P4). No kind of fault was found that the eight do not answer. The claim stands
until one of the framework's falsification criteria is met (section 12).

**In the model's terms.** In a model where at most `f` faults land between two monitor
rounds, a reference system that has all the properties has no gap at `f` = 1, and removing
any one of them, alone, opens one. Section 6 gives the ten executions: the eight
properties, the halt fan-out clause of the eighth taken separately, and the gate.

**How the pieces fit.** The four constraints state the problem. They are: no central
controller (C1); an undetected failure costs far more than a false alarm (C2); a fault can
mimic a legitimate component (C3); no external maintenance (C4). The framework holds that
the properties, and the further requirements found below, emerge from them and are not
further constraints. How much of the structure a system needs is set by the scaling law:
by the class of fault worth covering, as those who bear the cost judge it. The full
structure is the ceiling, and lower tiers need part of it.

**What the model makes precise.**

1. *The goal is that a fault has no impact before the system responds.* Detection alone is
   too weak a goal. A fault that is flagged while work carries on has the same effect as
   one that is never flagged. Judged against "no impact", every property but P6 is needed.
   Removing P6 leaves the work halted and breaks detection only (section 6). Judged
   against detection alone, P4 and P8 would look unnecessary: without either, G1 holds in
   every reachable state of R. Removing the halt fan-out does break G1, in three rounds,
   but only because the work it fails to halt keeps the model running. Both judgements are
   needed to show all ten removals.
2. *The gate is an emergent requirement that the list of eight does not name.* In every
   round the monitors must check before any work process steps, so that work is stopped by
   default and runs only on a current observation. It is the model's execution-observation
   coupling. Without it, a system with all eight properties still lets a bad work process
   act once before anything can stop it.
3. *Necessity is relative to the tier.* A property is needed for every observer the
   system's tier depends on. Three monitors with one signal that nobody reads have no gap
   at one fault per round, where two monitors would do, and have a gap at two faults per
   round, where all three are needed (section 4).
4. *Every guarantee is relative to a rate, a scope and what is checked, and all three are
   the implementation's to set.* If every monitor can be faulted before any of them steps,
   or all can be stopped in one step, no arrangement inside the system survives. A fault
   that changes nothing any monitor reads is flagged by none. The counts grow with the
   rate: at least `f + 1` monitors, at least `f + 1` halt sources per work process. A
   fault as wide as the whole system is answered by adding a level, and the conditions at
   that level are the same conditions (section 2.7).
5. *The argument has two halves.* The model lists the kinds of fault and writes each
   property as the thing that catches one of them. So the checker's half is: if these kinds
   of fault exist, each property is needed, the properties together leave no gap, and none
   is covered by the others. The four constraints assert part of the other half, that
   these kinds of fault exist. The rest is a claim about the systems being modelled
   (section 7). No checker can supply it. An independent reviewer found
   that eight of the nine removals it examined open a gap in any system for this reason.
   Only propagation depends on how a system is wired, and that is a matter of scale: a
   small system can have the work read its detectors directly, a large one cannot
   (section 7).
6. *The properties build on one another, and none is removable.* P6 builds on P1: it takes
   the liveness signal and requires a reader that survives the loss. P2 does by
   construction what the halt on silence does by a check: when a substrate is lost,
   sharing it leaves no threshold in which work runs unobserved. P5's own content is that
   there is no sanctioned way to stop an observer checking; that removal takes more than
   one step follows once the others are in place. Each of them, removed alone, still
   opens a gap.

**On the structure.**

- *Sufficient:* yes. A general theorem (section 10.1, which also defines a plain system)
  gives conditions under which any plain system, of any size and depth, responds
  completely to every single fault. The ring
  as the two implementations build it (three members and a coordinator, every pair
  watching each other) holds up to three faults per round in the model. Two levels of
  recursive interleaved rings hold too, at one fault per round, including when a whole
  base ring is lost in one step.
- *Three members:* forced at the top of the scale, by any one of: two faults between
  rounds; naming which monitor is the faulty one; or the rule that every node passes a
  halt to at least two others, which is what lets a halt keep pace with a fault that
  doubles. At the bottom of the scale, responding to a single fault, two monitors that
  check each other are enough.
- *The coordinator:* forced by recovery. Members that start only once another member has
  started cannot restart from a full stop: each waits for another to go first. That breaks
  C4. So one member must be able to start first, and every other member must be reached
  from it, the same reachability a flag needs (P4). Starting first does not mean starting
  unobserved. In both implementations a halted member keeps cycling. In ghostunnel's ring
  the member that starts first is therefore watched like any member, and it checks the
  others before it moves (section 10.3). One such member is the fewest. It has no work of
  its own to observe, so it observes every member directly. At scale it is also the member
  that joins a ring to the one above.
- *Wiring:* when a report takes time, the monitor that checks a work process must itself
  be able to stop it. A halt that has to reach a coordinator first then arrives after the
  bad process has acted.
- *Unique:* not settled. Uniqueness cannot be established by any finite check, only
  refuted by a counterexample, and none was found. The arrangements that pass the
  detect-and-halt checks either fail another requirement or are the ring with different
  wiring or counts.

**Against the framework's own falsification criteria** (section 12). No alternative
configuration was found, no property could be removed whole without a gap, and nothing the
model needed turned out to be a fifth constraint. Independent reproduction was not tested.

## 2. The model

### 2.1 Processes

There are two kinds of process. *Work processes* do the system's work. *Monitors* watch
work processes and each other. A system is described by who does what to whom:

| Relation | Meaning |
|---|---|
| signal reads | monitor `r` reads monitor `m`'s liveness signal, and flags when it is absent |
| state checks | monitor `m` compares process `x`'s state with a known-good reference, and flags when they differ |
| reports | monitor `m` passes its flag to monitor `r` |
| halt inputs | work process `w` halts when one of these monitors is flagged, or silent |

Each monitor also sits in a *trust boundary* (a host, an account, a site) and each process
may run on a *substrate* (power, storage, a clock source).

A process is alive or stopped, and its state is good or bad. A monitor is nominal or
flagged. A work process is running or halted.

**What "halted" stands for.** A work process is halted when the response has fired for it:
it takes no more normal work steps. What the response does belongs to the system and to
the scope it is applied at. It may be to refuse (ghostunnel's proxy refuses new
connections and closes the ones in flight). It may be a defensive action: fail over,
isolate a component, shut something down. Nothing in the model restricts it to doing
nothing. The model asks two things of it:

1. it ends the process's normal work;
2. it is acceptable to trigger falsely.

The second is scope condition C2, and it is a real constraint. Any monitor can trigger the
response and a flag needs no proof, so a faulty monitor can set it off at will.

### 2.2 The environment

The environment is everything that causes faults. Its steps:

| Step | Effect | Stands for |
|---|---|---|
| stop `m` | `m` takes no more steps and emits nothing. Its state is unchanged. | a crash |
| stop-boundary `b` | stops every monitor in boundary `b` at once | losing a host or a site |
| fail-substrate `s` | stops every monitor on `s`; every work process on `s` goes bad, and every state check of it keeps returning the last good value | losing power, storage or a clock |
| mutate `p` | `p`'s state goes bad. A mutated monitor keeps emitting its signal, flags nothing and reports nothing. | a fault that looks like health |
| disable `m` | `m` keeps its signal and its good state and checks nothing. Exists only where a monitor has an off switch. | a sanctioned off switch |
| join | a new work process appears | a deployment |

### 2.3 Rounds, the fault rate and the gate

Time is a sequence of rounds. In one round:

1. the environment takes at most `f` steps;
2. every monitor checks once, and flags travel along report edges;
3. every work process either halts or takes a work step.

`f` is the fault rate: how many faults can land between two monitor rounds. The
implementation sets `f`, by how often the monitors check against how fast faults can
arrive. A quicker cadence lowers it, and more monitors tolerate a higher one.

The order of 2 and 3 is the *gate*. Work steps only after the monitors have looked at the
state it is about to act on. The order is the model's execution-observation coupling: work
is stopped by default and runs on a current observation. Section 6 shows what happens when
the order is reversed.

### 2.4 The two judgements

- **G2, no impact.** No work process takes a work step while any process's state is bad.
  G2 is the goal. It says a fault never acts through the system's work: the response
  comes first.
- **G1, detection.** At the end of a round, if any process's state is bad, some monitor
  that is alive and not itself mutated is flagged. The request this work was done for set
  detection as its goal. That request is not in this folder.

The specification and the checker's output call the two judgements goals.

Both are reported because together they say which half failed. G1 broken means nothing in
the system knows. G2 broken with G1 intact means something knows and work went on anyway,
which for the purpose of impact is the same as not knowing. G1 broken with G2 intact means
the work stopped and nothing knows why.

### 2.5 What the model assumes

Each of these is a place where a result could be an artefact of the model, so each is
stated.

1. *The fault rate is bounded.* Theorem 0 below shows nothing holds otherwise.
2. *The model has no step that repairs a bad state.* How a system gets back to good is its
   own recovery, which differs from one implementation to the next and is outside the
   model. One consequence is that the model never sees a state that goes bad and is put
   back between two checks. Whether such a change is caught depends on the form P3 takes.
   A comparison of current state misses it. A record that may only grow catches it when
   the change left an entry or some member read the bad state, and misses it otherwise
   (sections 3.1 and 10.5).
3. *The round model ends at the first complete response:* some live, correct monitor
   flagged and every work process halted. It does not follow a halted system further. How
   a stopped ring comes back is treated separately, through the coordinator, in section
   10.3.
4. *A mutated monitor shows nominal.* This is the worst case scope condition C3 allows. A
   mutated monitor that flags falsely does no harm to either judgement.
5. *A flag makes all its hops within one round.* Section 8 drops this.
6. *A substrate fault cannot be seen by a state check from off the substrate.* The
   assumption gives P2 its role, and it is why the first face of P2 follows at once from
   the definition of the step (section 6).
7. *The response binds a bad work process.* A work process whose state is bad still halts
   when one of its halt inputs is flagged or silent. The halt in the model is therefore
   one the work cannot decline: a gate in front of the work, or the removal of its ability
   to act. A request that a faulty process is trusted to obey is a weaker thing, and the
   results do not cover it.

### 2.6 Where the scope conditions enter

| Condition | Where it is used |
|---|---|
| C1, no central process | No single monitor's loss or mutation defeats a goal in any passing system; section 10 shows a coordinator cannot be the only halt source. It is also why views are local, which is what makes P4 matter. |
| C2, an undetected failure costs far more than a false flag | Any flag halts. No vote is taken and a flag needs no proof of origin, because a wrong halt is the acceptable error. It is also the condition on what the response may be (section 2.1). |
| C3, a fault may look like health | The mutate step. It is why signals alone are not enough (P3) and why monitors must be checked by other monitors. |
| C4, no outside operator | No step in the model is taken by a person. Enrolment is not guaranteed to happen (P7), and a switch is not supervised (P5). |

### 2.7 Theorem 0: the rate, the scope and what is checked

**Proved.**

1. *Rate.* In every system with at least one monitor, if `f` is at least the number of
   monitors, G1 can be violated. *Proof.* The environment mutates every monitor in one
   round. A state is bad and no correct monitor exists to be flagged.
2. *Scope.* In every system where one environment step stops every monitor (they all sit
   in one boundary), G1 can be violated in two rounds: that step, then mutate any process.
   Nothing is alive to flag it.
3. *What is checked.* A monitor detects two things only: the silence of a monitor whose
   signal it reads, and a state it checks that differs visibly from its reference
   (`model-spec.md`, section 3.2). A fault that produces neither, for every monitor, is
   detected by none, and no flag is raised. *Proof.* A flag starts only at a detection.

So every guarantee is relative to a rate, to a scope and to what is checked. A fault as
wide as the whole system is outside what any arrangement inside the system can see. No
system escapes this: there is always a wider fault.

**Checked.** The remedy for a wider fault is one more level. Take the two-level system of
interleaved rings of section 10 and put each base ring whole inside one boundary, so that
one step can stop an entire ring. That step is flagged in the same round by the upper-ring
member that watches the lost ring's coordinator, the flag reaches the other ring, and both
work processes halt. Neither judgement can be violated at `f` = 1. A single ring of four
monitors in one boundary, by contrast, loses every monitor to that one step, and G1 can be
violated in the round after it, two rounds in all. Its work process still halts, because
work that cannot hear its monitors stops.

The conditions at the upper level are the same conditions as at the lower one. Widening
the scope (servers, then racks, then sites) adds rings, depth and boundaries, and changes
nothing else.

**One edge, met from three sides.** Inside the scope of an implementation the model has no
gap. The scope has one edge, and a fault can lie beyond it in three directions.

- *Outward: a fault as wide as the whole substrate,* such as an asteroid strike. The
  system cannot see it, and the work goes down with the observers (P2). The loss is real,
  and it is not a failure of the system: no part of it acts while the fault stands.
- *Downward and sideways: what the system depends on and did not write.* The substrate
  beneath and the services beside. They are listed and not seen into.
- *Inward: what is left to vary unchecked.* A fault that passes every check the system
  makes looks like health, which is part 3 above. It can exist only in a part of the
  system that is allowed to vary. A part that is fixed, and checked against a reference,
  is out of its reach, and a system that is fixed throughout has no such side.

At the edge there are two choices. Raise the scope: add the level, the boundary or the
check that brings the fault inside. Or accept the risk and cover it from outside, for
example by review at intervals. The second leaves a named gap: a check made at intervals
by someone outside the system does not satisfy the model.

Where the scope can grow no further, the last level is a ring. Its members watch each
other, so nothing sits unwatched at the top.

**The scaling law.** The framework's rule is that the complexity a system needs is
proportional to the cost of an unnoticed failure, as its stakeholders judge it. In the
model the least structure grows with the class of fault to be covered:

- one more monitor, and one more halt source for each work process, for each further fault
  that may land between two checks (sections 6 and 10.2);
- one more level for each wider boundary that may be lost in one step;
- quicker hops for a fault that grows faster (section 8).

Which class is worth covering is a judgement about consequences, and it is made outside
the model: "catastrophic" is relative to whoever bears the cost. The rate, the scope and
what is checked are therefore the implementation's to choose, and they are not further
constraints. The full structure of section 10 is the ceiling, what the top of that scale
requires. Lower tiers need part of it.

Growth adds rings and levels and never makes a ring larger. **Argued.** The cost of each
ring therefore does not rise as the system grows, and the cost of the whole grows with the
number of rings and with nothing else. What a ring costs to run depends on the substrate
it runs on.

## 3. Function and form

### 3.1 Three layers, and the model's own choices

What this note reports falls into layers, and it matters which layer a result is about.

| Layer | What is in it |
|---|---|
| Constraints | the four, taken as premises |
| Emergent: the framework | each property, by what it does; the gate; the reflex and the cascade (section 8); a member that can start first, from which the rest are reached; a halt on any detection; the scaling law |
| Implementation: set by the scaling law | which edge carries a property; how many monitors and halt sources; cadence and thresholds; scope and levels; mesh or ring; what the halt does; how a bad state is repaired |
| This model's own choices | rounds; the two judgements; where the model ends; what a mutated monitor shows |

A property is a function: something that must be true. A system realises it in some form,
and the form varies with scale and with the tier the system is built for.

| Property | What must be true | Forms it takes |
|---|---|---|
| P1 Liveness signal | an observer's silence triggers a response | another monitor reads the signal; or the work halts on its silence |
| P2 Shared substrate | work cannot run where its observer cannot | one substrate for both; or a freshness check with a threshold |
| P3 State check | a state that goes bad without a sign is seen | a state comparison; a recomputation; a record that may only grow |
| P4 Propagation | one detection stops the whole system | the work reads the detector directly; the flag is passed between observers; a chain through coordinators |
| P5 No single-step removal | there is no sanctioned way to stop an observer checking | no switch; or the switch position is itself checked |
| P6 Out-of-boundary signal | an observer's loss is seen from somewhere that survives it | separate accounts, hosts or sites; a level above |
| P7 Automatic enrolment | nothing exists unobserved | enrolment in the step that adds a process; or a declared membership in which an absence halts |
| P8 Immediate response | the response has no window, and outpaces the fault | the checker stops the work directly; a halt passed to at least two; quick hops |

The results in sections 6 to 10 are about the middle column. Several of the qualifications
found along the way are about the right-hand column: which form a small system can use and
a large one cannot. Section 12 comes back to this.

### 3.2 The forms used in the model

For the model each property needs one definite form, a statement about the system's
relations.

| Property | As a predicate | The environment step it answers |
|---|---|---|
| P1 Liveness signal | every monitor's signal is read by another monitor; a work process halts when a halt input is silent | stop |
| P2 Shared substrate | every work process on a substrate has a state checker on the same substrate | fail-substrate |
| P3 State check | every process, monitor or work, has a state checker other than itself | mutate |
| P4 Propagation | from every monitor's flag, every other monitor is reached along report edges, directly or through other monitors | any, when views are local |
| P5 No single-step removal | no monitor has an off switch | disable |
| P6 Out-of-boundary signal | every monitor's signal has a reader in a different boundary | stop-boundary |
| P7 Automatic enrolment | a joining process has a state checker and halt inputs from the step that adds it | join |
| P8 Immediate response | a work process halts in the round it sees a flag | any |
| P8b Halt fan-out | every work process takes its halt from at least two monitors (that every halt is passed to at least two more is counted in section 8.2, not modelled here) | mutate, of a halt source |
| The gate | in every round the monitors check before any work process steps | any |

Two of the properties build on another. P6 is P1 plus a condition on where the reader
sits. The first of P2's two faces (section 6) works by turning a substrate fault into a
monitor's silence, so it needs P1 to be read.

## 4. What "necessary" means here

**Necessary for what the system is built to cover.** By the scaling law (section 2.7), how
much structure a system needs depends on the class of fault it must cover. "Necessary" is
read the same way. A property is necessary for every observer the system's tier depends
on, and as the tier rises the system depends on more of them.

Two forms of this are proved or checked in what follows.

- **Independence.** There is a system with all the other properties in which removing this
  one, alone, opens a gap. So the property is not implied by the others, and the others do
  not suffice. Section 6 shows this for each.
- **Load-bearing.** A missing property lets the environment remove some monitor or edge
  without anything noticing. If the system depends on that monitor or edge, a gap follows.
  It holds by construction: it is what "depends on" means. Its content lies in showing
  which monitors and edges a given system depends on. Section 10 does that for one system
  by removing each edge in turn.

**The same missing edge at two tiers. Checked.** Take three monitors that all check each
other and one work process, and let nobody read the third monitor's signal.

| Faults per round | Every signal read | Nobody reads M3's signal |
|---|---|---|
| 1 | no gap | no gap |
| 2 | no gap | G1 broken in two rounds |

At one fault per round two monitors are enough, so the third is beyond what the tier
requires, and losing it unseen loses nothing the tier needs. At two faults per round all
three are needed. The environment stops M3 unseen, then stops M1 and mutates M2 together,
and nothing is left to flag it. The missing property is a gap exactly where the tier relies
on the observer that lacks it.

**Checked.** The reference system of the next section shows the same in two more ways. Add
a fourth monitor to it whose signal nobody reads, and at one fault per round there is
still no gap. And R gives each work process a single state checker. One is enough, because
a step against the checker is itself seen by the other two monitors. At two faults per
round R fails through its halt sources and not through its single checker (section 5):
with a third halt source for each work process and still one checker it has no gap
(`lc04_single_checker.py` in `verification/g-final-round/last-check/`).

So section 6 establishes this: at the tier R is built for, each property, removed whole,
opens a gap. How much of each property counts as whole grows with the tier.

## 5. The reference system R

R is a small system in which all ten removals can be told apart.

- Work processes W1 and W2, and a work process J that may join later.
- Monitors M1, M2 and M3, each in its own boundary.
- M1 is W1's local monitor: it runs on W1's substrate and is the only state checker of W1.
  M2 is the same for W2. M3 has its own substrate.
- The three monitors read each other's signals, check each other's state and report to
  each other.
- W1 halts on M1 or M3. W2 halts on M2 or M3. J, once joined, is checked by M3 and halts on
  M3 or M1.

**Checked.** With everything in place and `f` = 1, neither judgement can be violated (23
reachable states). With `f` = 2 both can. The environment mutates M1 and M3 in one round,
M2 flags, W2 halts, and W1, whose two halt sources are the two mutated monitors, keeps
working: G2 is broken in one round. In a second round the environment stops M2, no live,
correct monitor is flagged, and G1 is broken. R is built for one fault per round.

## 6. The ten removals

Each removal is made alone, with `f` = 1. The checker explored each removal in full and
replayed each execution in a table below, so each result is **checked**. Where a result is
also **proved** for every
system of a class, the text says so. "In full R" says what the same environment steps do
when nothing is removed. Section 7 sets each result beside an independent reviewer's
label.

### P1, liveness signal

*Removed:* no monitor reads a missing signal, and work does not halt on silence.

| Round | Environment | End of round |
|---|---|---|
| 1 | stop M1 | nothing flagged; W1 and W2 working |
| 2 | mutate W1 | W1 bad; nothing flagged; W1 and W2 working |

Breaks G1 and G2. Stopping M1 changes no state, so the state checks of M1 still pass. W1's
only checker is gone, and nothing reports that.

*In full R:* in round 1, M2 and M3 flag M1's silence and both work processes halt. The
model ends there, so round 2 never happens.

*Evidence:* checked. In R the shortest violation the search finds is one round, and it is
P2's (a substrate fault), because the first face of P2 works only through P1. The
two-round execution above is the one that belongs to P1 alone.

### P2, shared substrate

P2 has two faces. The model checks the first. The second is proved from two executions.

**First face: the watched process's substrate fails, and an observer elsewhere cannot feel
it.**

*Removed:* M1 and M2 run on substrates of their own.

| Round | Environment | End of round |
|---|---|---|
| 1 | fail-substrate s1 | W1 bad; nothing flagged; W1 and W2 working |

Breaks G1 and G2. M1 is alive and its check of W1 returns the last good value.

*In full R:* the same step stops M1 too. M2 and M3 flag its silence and both work processes
halt.

*Evidence:* checked, and immediate from the definition of the step. The step is defined as
invisible to a state check from off the substrate, so once that is granted the result
follows at once. The assumption doing the work is that a monitor's read of the watched
process fails *stale* when the substrate goes. A freshness requirement on every read, with
"cannot verify" treated as a fault, closes this face of the gap by a check.

**Second face: the observer falls, and the work must fall with it.** Take a loss that
stops whatever runs on the substrate, such as a power cut. The round model's
`fail-substrate` is a different loss: it leaves a work process on the substrate running
and bad (section 2.2), and against it a threshold of a round or more lets the work act
while bad even on a shared substrate. If a monitor and the work it watches run on one
substrate, a loss of the first kind stops both. There is then no moment at which the work
runs and nothing watches it, and a system that is down cannot be made to act.

The round model hides this, because in it a work process notices a silent monitor at once.
Real systems do not: a signal counts as missing only after a threshold. Let work process W
have M as its only state checker, and let W halt on M's silence once M has been silent for
`k` rounds.

**Proved.**

- *Separate substrates, `k` of 2 or more.* Round 1: the environment takes M's substrate
  away. M stops; W works on. Round 2: the environment mutates W. M has been silent for one
  round, fewer than `k`, so W takes a work step while bad, and no monitor is alive to see
  it. G2 is broken.
- *One substrate, any `k`.* The step that takes M's substrate stops W with it. W takes no
  further work step, so nothing it could do while bad happens. A crash of M alone is
  outside this face. On either arrangement it leaves W working for `k` rounds, and the
  halt on silence, with its threshold, is what answers it.

*Evidence:* proved, from the two executions above. Against the loss of a substrate, P2 is
the halt on silence made structural. The halt on silence keeps work from outliving its
observer by a check, and a check has a threshold. Against that loss, shared substrate does
it by construction, with no check and no threshold.

### P3, state check

*Removed:* no state checks. Monitors read signals only.

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate W1 | W1 bad; nothing flagged; W1 and W2 working |

Breaks G1 and G2.

*In full R:* M1 flags, the flag reaches M2 and M3, and both work processes halt.

*Evidence:* checked. It rests on C3: mutate is a change that no event announces. The same
holds for monitors. **Proved:** in a system with no substrates or switches, a monitor with
no state checker other than itself can be mutated, leaving a bad state and no flag. A
monitor's check of itself is void, because the mutated monitor is the one that would run
it.

### P4, propagation

*Removed:* no report edges.

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate W1 | W1 bad; M1 flagged; W1 halted; W2 working |

Breaks G2. G1 holds in every reachable state: the flag exists. M2 and M3 never learn of
it, and W2, which does not read M1, works on with a fault in the system.

*In full R:* M1's flag reaches M2 and M3 and both work processes halt.

*Evidence:* checked. P4 is needed because the response is system-wide and views are local.
How far a flag has to travel is a matter of scale. In a system small enough for every work
process to read every monitor directly, the flag reaches the work in one read and nothing
has to pass between observers: propagation at its smallest. A larger system cannot
support it, because reading every monitor before each action is itself an evaluation
window (argued, not modelled; section 8 counts what a window costs). There the flag has
to travel.

P4 is reachability, not adjacency: the flag may travel a chain, and at scale it travels up
and down through coordinators. A chain must survive a mutated monitor on it. **Checked:**
in a ring of three where each monitor reports to the monitor it checks, mutating M1 makes
M3 flag and report to M1, where the flag dies; the work process, reading M1 and M2, works
on. Where each monitor reports to the one it does *not* check, the flag goes round the other
way and neither judgement can be violated. The rule "check one, report to a different one"
is exactly the condition that a report about a faulty monitor is not delivered to that
monitor.

### P5, no single-step removal

This has two readings, and they come out differently.

*Off switch. Removed:* every monitor has one.

| Round | Environment | End of round |
|---|---|---|
| 1 | disable M1 | nothing flagged; W1 and W2 working |
| 2 | mutate W1 | W1 bad; nothing flagged; W1 and W2 working |

Breaks G1 and G2. M1's signal continues and its state is good, so there is nothing for M2
or M3 to see.

*Evidence:* checked, given that the switched-off position counts as a good state. If the
reference a peer compares against included "checks enabled", P3 would catch the switch.
So this reading of P5 is a condition on what known-good means: there is no known-good
state in which a live monitor is not checking.

*Count ("removal takes at least two steps").* Not necessary at `f` = 1 as a statement about
each process (section 4). What is necessary is its rate form. **Proved:** in a system with
no substrates or switches, if some set of at most `f` monitors is checked by no monitor
outside the set, the environment mutates the whole set in one round and nothing flags.
"At least two steps" is this at `f` = 1 for the monitors taken together: at least two, each
checked by another.

### P6, out-of-boundary signal

*Removed:* all three monitors sit in one boundary.

| Round | Environment | End of round |
|---|---|---|
| 1 | stop-boundary | all monitors stopped; W1 and W2 halted |
| 2 | mutate W1 | W1 bad; nothing flagged |

Breaks G1. G2 holds in every reachable state: the work processes halt in round 1 because
their halt inputs went silent.

*Evidence:* checked. P6 is the one removal where the work is safe and the system is blind.
Halting on silence stops the work; P6 is what lets something still alive know that it
happened. It is also the step where scope grows (section 2.7).

### P7, automatic enrolment

*Removed:* a joining process has no state checker and no halt input.

| Round | Environment | End of round |
|---|---|---|
| 1 | join J | J working |
| 2 | mutate J | J bad; nothing flagged; W1, W2 and J working |

Breaks G1 and G2.

*In full R:* M3 checks J from the round it joins, flags, and all three work processes halt.

*Evidence:* checked. It needs a model in which processes join. It rests on C4: enrolment is
a separate step that nobody is bound to take.

### P8, immediate response

*Removed:* a work process halts one round after it sees a flag.

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate W1 | W1 bad; M1, M2, M3 flagged; W1 and W2 take one more work step |

Breaks G2. All three monitors have flagged and the bad process acts anyway.

*Evidence:* checked, and proved below. The result is one of timing. A fault that is flagged
and still acting is, for its effect, an undetected one. How much the extra step costs
depends on what the fault does during it; section 8 gives the rate assumption.
**Proved,** for every system with a window and at
least one work process present from the start: the environment mutates a work process, and
in that round every work process takes a step, because none may halt before the window has
passed.

### P8b, halt fan-out

*Removed:* each work process halts on its local monitor only.

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate M1 | M1 bad; M2 and M3 flagged; W2 halted; W1 working |

Breaks G2. W1's only halt source is alive and shows nominal. W1 does not halt while M1
stays alive, so the model runs on, and the search finds G1 broken in three rounds: mutate
M1, then stop M2, then stop M3.

*Evidence:* checked, and **proved** in general: in a system with no substrates or switches,
a work process with at most `f` halt inputs keeps working after the environment mutates
all of them.

### The gate

*Removed:* in each round the work processes step first, on the flags as they stood at the
end of the round before. The monitors check afterwards. All of P1 to P8b are in place.

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate W1 | W1 and W2 take a work step with W1 bad; then M1, M2, M3 flag |
| 2 | none | W1 and W2 halt |

Breaks G2. The response is complete one round later, after the bad process has acted
once.

*In full R:* the monitors check first, and W1 halts in round 1 without acting.

*Evidence:* checked, and proved below. Every property of the observers is present and the
fault still has an impact, because the work did not wait for the observation. The eight
are properties of the observers; the gate is a property of the work. It is the reason the
halt exists: to keep a fault from acting in the interval before it is detected.
**Proved,** for every system without the gate that has at least one work process present
from the start: the environment mutates a work process in round 1, no flag exists yet, and
the work processes step.

In R without the gate, no step that makes a state bad in round 1 is answered completely in
that round, because no flag is up when the work processes step. So the environment also
gets further rounds. The search finds G1 broken in three: mutate M1, then M3, then stop
M2, with W1 working throughout.

## 7. Verdicts

Each removal but the gate carries two labels. The first is the kind of evidence, in the
terms set out at the top of this note. The second is the independent reviewer's, and says
something sharper: whether the gap comes from how the processes act on each other
(*dynamics*), or follows at once from how the fault step or the parameter is defined, and
so exists in any system without the property (*definition*).

| Removed | Judgement broken | Evidence | Reviewer's label | Note |
|---|---|---|---|---|
| P1 Liveness signal | G1 and G2 | checked | definition | P6 builds on it; in R the shortest gap is P2's |
| P2 Shared substrate | G1 and G2 | checked (first face); proved from two executions, for a loss that stops the work too (second face) | definition | the halt on silence made structural, against the loss of a substrate; a freshness rule on reads does the first face's job by a check |
| P3 State check | G1 and G2 | checked; proved for monitors | definition | must cover monitors, by another monitor |
| P4 Propagation | G2 | checked | dynamics | a matter of scale: in a small system the work reads its detectors directly, and in a large one the flag has to travel |
| P5 No single-step removal | G1 and G2 | checked (off switch); proved (rate form) | definition | the "two steps" reading follows from the others at `f` = 1 |
| P6 Out-of-boundary signal | G1 | checked; proved for every system in which one step stops every monitor (section 2.7) | definition | the work still halts, on silence |
| P7 Automatic enrolment | G1 and G2 | checked | definition | needs a model with joining |
| P8 Immediate response | G2 | checked; proved for every system with a window | definition | the window is the step G2 forbids; see section 8 |
| P8b Halt fan-out | G2 in one round; G1 in three | checked; proved for `f` or fewer halt sources | mixed | `f + 1` halt sources in general |
| The gate | G2 in one round; G1 in three | checked; proved for every system without it | not reviewed: the gate was not among the removals given to the reviewer | an emergent requirement, and not one of the eight |

**What this means.** The reviewer forced eight of the nine removals onto 400 random
systems each, and the gap appeared every time. P4 it showed to depend on wiring, by two
systems without report edges that have no gap. That has two sides.

- The necessity of those eight is not peculiar to the reference system. The reviewer
  argued from the definition of each step that the gap exists in any system that lacks the
  property, and found it in every one of the 400 random systems tried for each. Five are
  also proved for every system of a class in the round model: P3 for monitors, P5 in its
  rate form, P6, P8 and P8b (sections 2.7 and 6). The second face of P2 is proved in a
  model with a threshold, outside the round model.
- The gap exists in any system because of how the model is built. The kinds of fault were
  written down first, and each property was then written as the thing that catches one of
  them. In the model,
  for instance, nothing but a state check can notice a state that went bad without a sign.
  Remove the state checks and that fault goes unnoticed, in any system.

So the argument has two halves, and they come from different places.

- *If these kinds of fault exist, each property is needed.* This half is the checker's.
  It also shows that the properties together leave no gap, and that none of them is
  covered by the others.
- *These kinds of fault exist.* This half is not the checker's. Part of it is what the
  four constraints assert: that a fault can look like health (the third), and that nobody
  is on hand to enrol a new process or to supervise a switch (the fourth). The rest is a
  claim about the systems being modelled:
  - a process can stop;
  - everything in one boundary can be lost together;
  - processes join;
  - a fault keeps acting while a response is being weighed;
  - a substrate failure leaves reads stale, and an off switch counts as a good state.
    The model introduces these last two faults to express one property each.

The checker tests that each property stops its fault. That the fault occurs is a premise.

## 8. Timing: the reflex, the window and the cascade

In the model so far a flag makes all its hops within a round. This section drops that and
asks how fast, and from where, the halt must come.

### 8.1 The reflex

**Checked.** Three monitors check each other and report to each other. Only M1 checks the
work process. A report takes one round to arrive.

| The work process takes its halt from | Reports arrive at once | Reports take a round |
|---|---|---|
| M1 and M2: its own checker is a halt source | neither judgement can be violated | neither judgement can be violated |
| M2 and M3: monitors that must first hear from M1 | neither judgement can be violated | G2 broken in one round |

In the failing case the environment mutates the work process, M1 flags in the same round,
and the work process takes a step before M1's report lands.

**Proved,** from the round semantics, for the execution in which the mutation of the work
process is the environment's only step, with no window and the gate in place: when reports
take a round, the work process takes `d` work steps while bad, where `d` is the least
number of report hops from one of its state checkers to one of its halt inputs. `d` is 0
exactly when a checker is itself a halt input. With no such path it works in every round.
A further fault can lower the count (a halt input stops, and the work halts on its
silence) or raise it (a relay stops or goes bad).

So the monitor that sees a process's fault must be wired to stop that process directly.
A halt that has to be registered somewhere else first arrives after the fault has acted.
Both implementations are wired this way: the gate reads every member's own fault record
as well as a relayed one (`observers/SPEC.md:827`, `:831`;
`PR2: common/observer_gate.php:383`).

### 8.2 The window and the cascade

**The setting. Counted.** There are `n` running processes. One is bad. Every tick, each bad
process still running makes one more running process bad, so the bad ones double. A halt
starts at tick 0. The damage is the number of bad processes when nothing bad is still
running. The halt reaches good processes first, and every figure and bound below is for
that order. Another order can do more damage. For `n` = 8, at two per hop and one hop per
tick, a second hop that halts one bad process and three good ones leaves one bad and one
good running, and the damage is 3 against 2.

| How the halt travels | `n` = 1,024 | `n` = 1,048,576 |
|---|---|---|
| everything halts together, in the same tick | 1 | 1 |
| everything halts together, 5 ticks later | 32 | 32 |
| passed to 1 per hop, 1 hop per tick | 1,014 (99%) | 1,048,556 (100%) |
| passed to 1 per hop, 128 hops per tick | 128 (12.5%) | 1,046,016 (99.8%) |
| passed to 2 per hop, 1 hop per tick | 256 (25%) | 262,144 (25%) |
| passed to 2 per hop, 2 hops per tick | 16 (1.6%) | 512 (0.05%) |
| passed to 2 per hop, 4 hops per tick | 4 (0.4%) | 16 (0.002%) |

**The window (P8).** If everything halts `w` ticks after detection, the damage is `2^w`,
or the whole system if that is smaller. An evaluation window is paid for in doublings. The
rate assumption that makes P8 matter is this growth: the fault grows during the window.

**The cascade (P8b).** A halt passed to `c` processes per hop has reached at most
`1 + c + c^2 + ... + c^j` processes after `j` hops. With `c` = 1 that is `j + 1`: a chain
grows by one per hop. With `c` = 2 it is `2^(j+1) - 1`: it doubles.

- A chain loses to a doubling fault at any speed. With `h` hops per tick the damage is at
  least `n - h * ceil(log2 n)`, so the share of the system lost goes to 1 as `n` grows.
  Making the chain faster only moves the size at which it fails.
- A halt that doubles keeps pace when a hop is faster than the doubling time. At two hops
  per tick the damage is at most `sqrt(n / 2)` for every `n` of 2 or more, a share that
  goes to 0.
- At one hop per tick, the same speed as the fault, a doubling halt loses between a fifth
  and two fifths of the system for every `n` from 8 to 3,000, and exactly `n / 4` when `n`
  is a power of two of 8 or more.

The first bound is **proved** for every `n` of 2 or more, the second for every `n` of 4 or
more, and the exact value `n / 4` for powers of two from 8 (the proofs are the independent
verifier's, in `verification/d-claims/claims-verdicts.md`). A computation with `growth` in
`check_model.py` checked all three, for every `n` from 2 to 3,000 and for powers of two
beyond. For `n` = 2 and 3 the second bound holds by that computation. The range of a fifth
to two fifths is from it too.

So "each node passes the halt to at least two, which each pass it to at least two" is what
makes the halt grow as fast as the fault, and it must be paired with hops that are quick
next to the fault's doubling time. A check that resolves in one step is such a hop. One that
evaluates is not.

Two conditions come with this. Both are argued.

- *The two must be new.* Passing the halt to two neighbours on a line still covers ground
  at a fixed rate. The doubling needs each hop to reach processes not yet reached, which is
  what recursive interleaved rings provide: a ring's coordinator hands the halt to a whole
  ring above, and each member of that ring hands it to a whole ring below.
- *The depth is bounded by time.* A chain of `d` hops, each taking `t`, responds in `d * t`.
  That must stay under the fault's doubling time, which bounds how deep a detection chain
  may be for a given hop speed.

## 9. P1 in TLA+

The module isolates the liveness signal. Monitors state-check one work process. With `HB`
true, each monitor also flags when another monitor's signal is absent. The environment may
stop a monitor or corrupt the work process, one step per round. To keep the module small it
leaves out mutation of monitors, substrates, boundaries and joining; those are in
`check_model.py`. The listing leaves out the module's block comments and its `TypeOK`
invariant, which `Heartbeat.cfg` lists. Every other line is as in `Heartbeat.tla`.

```tla
---------------------------- MODULE Heartbeat ----------------------------
EXTENDS Naturals

CONSTANTS Mon,     \* the set of monitors, for example {m1, m2}
          HB       \* TRUE: P1 holds. FALSE: nobody reads a missing signal.

VARIABLES alive,   \* monitors that have not been stopped
          bad,     \* TRUE once the work process's state differs from known-good
          out,     \* out[m] is "nominal" or "flagged"
          turn,    \* "env" or "mon"
          halted   \* TRUE once a monitor has flagged: the response has fired

vars == <<alive, bad, out, turn, halted>>

Init == /\ alive = Mon
        /\ bad = FALSE
        /\ out = [m \in Mon |-> "nominal"]
        /\ turn = "env"
        /\ halted = FALSE

Stop(m) == /\ m \in alive
           /\ alive' = alive \ {m}
           /\ UNCHANGED bad

Corrupt == /\ ~bad
           /\ bad' = TRUE
           /\ UNCHANGED alive

Skip == UNCHANGED <<alive, bad>>

Env == /\ turn = "env"
       /\ ~halted
       /\ \/ \E m \in Mon : Stop(m)
          \/ Corrupt
          \/ Skip
       /\ turn' = "mon"
       /\ UNCHANGED <<out, halted>>

SeesBad(m)     == bad
SeesSilence(m) == HB /\ \E p \in Mon \ {m} : p \notin alive
Detects(m)     == SeesBad(m) \/ SeesSilence(m)

MonRound == /\ turn = "mon"
            /\ out' = [m \in Mon |->
                         IF m \in alive /\ Detects(m) THEN "flagged" ELSE out[m]]
            /\ halted' = (\E m \in alive : Detects(m))
            /\ turn' = "env"
            /\ UNCHANGED <<alive, bad>>

Done == halted /\ UNCHANGED vars

Next == Env \/ MonRound \/ Done

Spec == Init /\ [][Next]_vars

NoUndetectedBad == (turn = "env" /\ bad) => (\E m \in alive : out[m] = "flagged")
=============================================================================
```

`NoUndetectedBad` is judged between rounds: once a monitor round has run on a bad state,
some live monitor is flagged.

**With `HB = TRUE` and `Mon = {m1, m2}`** the invariant holds. To reach a bad state with no
live monitor flagged, both monitors must be stopped before the work process is corrupted.
The first stop is followed by a monitor round in which the survivor sees the silence, flags
and sets `halted`, after which `Env` is disabled.

**With `HB = FALSE`** the invariant fails. The shortest trace:

| State | Step | alive | bad | flagged | turn |
|---|---|---|---|---|---|
| 1 | Init | m1, m2 | no | none | env |
| 2 | Stop(m1) | m2 | no | none | mon |
| 3 | MonRound | m2 | no | none | env |
| 4 | Stop(m2) | none | no | none | mon |
| 5 | MonRound | none | no | none | env |
| 6 | Corrupt | none | yes | none | mon |
| 7 | MonRound | none | yes | none | env |

State 7 has `turn = "env"`, `bad` true and no live monitor, so the invariant is false. No
shorter trace exists: `bad` only becomes true at an environment step, the next step is a
monitor round, and any monitor alive in that round sees the bad state. So both monitors
must be stopped first, which takes four steps, and then two more.

**Checked,** on the checker's copy of the module. The module has not been run through TLC.
The author produced the trace by hand and checked it against a state-for-state copy of the
module in `check_model.py`, which finds 8 reachable states with `HB = TRUE`, all
satisfying the invariant, and the seven-state trace above with `HB = FALSE`.

## 10. The structure claim

The structure claim is a different and stronger statement than the ten results above. It
comes apart into four questions, followed by a comparison with the ring as built.

### 10.1 Is the structure sufficient?

**Theorem S. Proved,** for one fault per round, any number of processes, any depth.

Call a system *plain* if it has no joiner, substrates or switches, no two monitors share a
boundary, work halts on silence, there is no window, the gate is in place and reports
arrive within the round. Say a monitor *watches* another if it both checks its state and
reads its signal. Suppose a plain system with `f` = 1 has:

- (a) every monitor is watched by some other monitor;
- (b) every work process has a state checker and at least two different halt inputs;
- (c) for every monitor `z`, every other monitor either watches `z` or is reached from a
  watcher of `z` along report edges that do not pass through `z`;
- (d) every work process has a state checker from which every monitor is reached along
  report edges.

Then neither judgement can be violated.

*Proof.* A round in which the environment takes no step changes nothing. Consider the first
round in which it takes a step. There are three kinds.

- *It mutates a work process `x`.* Every monitor is alive and correct. By (d), a checker of
  `x` flags and the flag reaches every monitor. Every work process has a halt input, all of
  which are flagged, so every work process halts without taking a work step.
- *It mutates a monitor `z`.* Every other monitor is alive and correct. By (a) some watcher
  of `z` sees the bad state and flags, as does every other watcher. By (c) every monitor
  other than `z` is then flagged. By (b) every work process has a halt input other than
  `z`, which is flagged, so it halts without taking a work step.
- *It stops a monitor `z`.* The same, with the watchers seeing silence instead of a bad
  state. No state is bad, so neither judgement is in question.

In each case the round ends with a live, correct monitor flagged and every work process
halted. The response is complete, and the model ends there. No round has violated
either judgement. ∎

Nothing in the proof depends on size or depth. A ring with a coordinator presents to the
level above the three things the theorem uses: a signal, a state a peer can compare, and a
flag that passes through. So the conditions are checked on the whole graph at once, however
many levels it has. In this sense the same structure holds at every scale.

**Recursive interleaved rings** are the shape the structure takes as it grows.
*Recursive:* a member of a ring may itself be a ring. *Interleaved:* neighbouring rings
share a member, the coordinator, which belongs to its own ring and to the one above, so
that the rings are linked like a chain and not stacked like a tree with a root. (In the
checker's output these systems are labelled "nested".)

**Checked against the search.** The catalogue holds 72 plain systems with `f` = 1,
including each one-edge removal below. The four conditions hold in 31 of them, and in all
31 the search finds neither judgement can be violated. The conditions are sufficient and
not necessary: 14 systems fail them and still pass. The other 27 fail them and fail.

**Checked instances.**

| System | Result |
|---|---|
| Four monitors, all pairs watching, one work process reading all four. Both implementations build this ring: three members and a coordinator, every member watching every other (`observers/README.md:20`, `observers/SPEC.md:28`; `PR2: observers/README.md:23`). | neither judgement can be violated at `f` = 1, 2 or 3 |
| Three monitors and a coordinator that reads the members' signals and flags and checks no state; work reads the coordinator and one member | neither judgement can be violated at `f` = 1 |
| Interleaved rings on two levels: two base rings, each three members and a coordinator, joined by an upper ring of the two coordinators and a third member | neither judgement can be violated at `f` = 1 |
| The same, each base ring whole in one boundary | neither judgement can be violated at `f` = 1 |

**One arrangement fails. Checked.** Let the work process take its halt from the
coordinator and from nothing else, and let the coordinator be the member that goes bad
while still looking healthy. The three members see the fault and flag it. The work listens
only to the coordinator, which shows nominal, so the work carries on: the fault is
detected and nothing stops. A coordinator may be the first place the work looks for a
halt. It cannot be the only place: the work must also take its halt from at least one
member directly. In both implementations the gate reads every member's halt record as well
as the coordinator's signal (`observers/SPEC.md:818-834`;
`PR2: common/observer_gate.php:342`, `:365-383`), so any member stops the work without the
coordinator.

**Which edges the interleaved rings depend on. Checked.** Removing one edge at a time from
the two-level system, 23 of 55 removals let a judgement be violated:

- every state check: each member's check of the next, each first member's check of its
  coordinator and of its work process, and each upper member's check of the next;
- every signal read and every report in the upper ring;
- every halt input.

The other 32 are each spare on their own: the signal reads and reports inside the base
rings. Each of those has a second edge doing the same job. A member's signal is read by its
checker and by the coordinator; a coordinator's by a member and by the upper ring; a member
reports to another member and to the coordinator. So one of each pair can go. For a
coordinator's signal it is the member's read: the upper ring's is needed. The upper ring,
as built here, has no such pairs, and every edge in it is needed.

### 10.2 Are three monitors and a coordinator forced?

By the scaling law (section 2.7) the structure grows with what must be covered. The table
reads the ring that way: each requirement, and what it adds. With only the first
requirement on, two monitors are enough. With all of them on, the result is three members
that check each other and one that differs in kind: the ceiling.

| Requirement | Forces | Evidence |
|---|---|---|
| Respond to one fault per round | at least two monitors, each checked by another | proved; checked on meshes and rings |
| Respond to `f` faults per round | at least `f + 1` monitors, with no set of `f` or fewer left unchecked from outside, and at least `f + 1` halt sources for each work process | proved |
| No impact while a report is in transit | a state checker of each work process among its halt sources | proved and checked, section 8.1 |
| Name the faulty monitor | at least three | proved, below |
| Still name it after losing one | at least four | proved, from the row above |
| A halt that keeps pace with a doubling fault at any size | every node passes the halt to at least two new nodes, so at least three per ring | counted, section 8.2 |
| A flag crosses between rings | a member shared by both, checked from both and read from above | checked, section 10.1 |
| Recover without an outside hand | one member that can start first, from which every other member is reached along observation edges | proved, and checked on every ring of three and of four members, section 10.3 |
| Survive the loss of a whole scope | a level above | proved and checked, section 2.7 |

**Two suffice to respond to a single fault. Checked.** Two monitors that watch each other,
with a work process reading both, cannot be made to violate either judgement at `f` = 1.
The same holds for interleaved rings whose base rings are one member and a coordinator. Both
fail at `f` = 2, where three monitors hold. In general a mesh of `n` holds exactly when
`f <= n - 1`. **Proved** in both directions; **checked** for `n` from 1 to 4 and `f` from 1
to 3.

Responding to a single fault needs two. The count of three comes from one of three other
places.

1. *Two faults between rounds.* Two monitors can both be faulted before either steps.
   Three hold.
2. *Naming the faulty one.* **Proved.** Suppose at most one monitor is faulty, each correct
   monitor names the faulty one exactly, and a faulty monitor may name anyone. With two
   monitors, "1 names 2 and 2 names 1" arises both when 1 is faulty and when 2 is, so no
   rule can tell which. With three or more, the faulty one is named by at least two and a
   correct one by at most one, so "the one named twice" is always right. Detection needs
   two; a third settles the dispute between two. A system that only halts never needs to
   know which monitor is at fault. One that must recover without an outside operator, which
   C4 asks for, does.
3. *The cascade.* If every node must pass a halt to at least two others, a closed group
   has at least three members. Section 8.2 shows why the rule is needed: a halt passed to
   one is outrun.

**The fourth, as a count.** Four is the first size at which the loss of one monitor still
leaves three, and so still leaves a ring that can name a second fault.

**The coordinator, as a role.** The fourth constraint forces it: section 10.3 shows why,
and what it forces.

The coordinator has a second job where there is more than one ring. A flag crosses between
rings only through a member that belongs to both, is checked from both and is read from
above. In section 10.1 both state checks of a coordinator, the upper ring's read of its
signal and every report in the upper ring are needed. Its own ring's read of its signal,
and each single report between it and its own ring, are spare. The coordinator is that
member.

The checks of sections 6 and 10.1 stop at the halt, so they do not exercise recovery. A
mesh of three and a ring of three pass them with no coordinator, and cannot restart.

**The 3f+1 bound.** That bound is for *masking*: keeping a service correct while `f`
members are faulty. The model halts on a detected fault instead, and under that rule the
bound does not apply. What applies is `f + 1` to detect, and three to name one faulty
monitor (proved above). By the same counting the general number is `2f + 1` (argued, not
proved here). Three and one make four, which is `3f + 1` at `f` = 1, but for different
reasons: three is `2f + 1` at `f` = 1, and one is the spare.

### 10.3 Restarting: why one member must differ in kind

The round model ends when the response is complete. Scope condition C4 asks for more: the
system must come back without an outside hand. This section treats that in a smaller
model.

**The setting.** The round model's rule for silence is that nothing runs unobserved: a
work process halts when a monitor it takes its halt from is silent. The game applies that
rule to the observers themselves in a weaker form: the rule stops a member only when every
member that observes it has stopped. Each member of a ring is *running* or *stopped*. It
runs only
while at least one member that observes it is running. When none is, it stops at once, and
it can start again only when one is. The game starts with every member running. The
environment may stop a member, and later release it.

The game has these two states and no third. A stopped member has given up its go-ahead.
Whether it still watches is outside the game. In ghostunnel's ring it does: a halted
member keeps cycling and keeps reading every other member (`observers/SPEC.md:28`,
`:544`). The Platform Racing 2 README says that its observers keep cycling while the work
is stopped (`PR2: observers/README.md:94-95`), and that every member watches every other
(`:23`).

**Theorem R. Proved.** If every member of a ring runs only while a running member observes
it, then once every member has stopped, none can ever start.

*Proof.* A member may start only when one of its observers is running. None is running, so
no start is possible, and nothing else changes the state. ∎

So a ring whose members all wait on each other cannot recover from a full stop by itself.
That breaks C4. And a full stop is reachable.

**Checked.** A member *can start first* if the rule above does not bind it: it may start,
and stay running, while no member that observes it is running. In the game it starts
unconditionally. (In the checker's output this member "starts by itself".) A ring *can
always restart* if, from every state the environment can bring about, once it has released
every member it stopped, the members can start one after another until all are running.

| Ring | Result |
|---|---|
| three members, each observed by the one before it | cannot restart after one member is stopped and released: the stop passes round the ring and all three are stopped |
| three members, each observed by the other two | cannot restart after two members are stopped and released |
| three members and a coordinator that observes all three and can start first | can always restart |
| the same four, but the coordinator cannot start first | cannot restart after one member and the coordinator are stopped and released |

In the first row the rule does what it is for: it stops whatever is left unobserved. The
deadlock is the other face of the same rule.

**What the theorem forces.** Recovery needs one member that can start first. The theorem
forces that difference and no other. In ghostunnel's ring, where a stopped member still
watches, the member that starts first is observed like any member and checks the others
like any member: it starts with the others watching it, and only once it has checked them
("The
implementation", below).

**Every other member must be reached from it. Proved.** Let K be the one member that can
start first. K *reaches* a member if a chain of observation leads from K to it: K observes
a member, which observes another, and so on. The ring can always restart exactly when K
reaches every other member.

*Proof.* Suppose K reaches every other member, and take any state in which the environment
has released every member it stopped. K starts if it is not running. Each member K
observes may then start, then each member those observe, and so on along every chain,
until all are running. Now suppose some other member is not reached, and let U be the set
of other members K does not reach. Every observer of a member of U is itself in U, since a
member observed by K, or by a member that K reaches, is reached too. From the state in
which all are running, the environment stops every running member of U and releases it. K
and the members it reaches keep running, since each of them is K or has an observer among
them. No member of U then has a running observer, so by the argument of Theorem R none of
them can start. ∎

**Checked,** by the sweep of section 13: on every observer graph of three members and of
four, one of them able to start first, the ring can always restart exactly when that
member reaches every other. There are 64 and 4,096 such graphs in which no member observes
itself, and none is an exception
(`s02_sections_6_to_10.py` in `verification/g-final-round/sweep/`).

That reachability is the property a flag uses to travel (P4), turned to recovery.
Observing every member directly is the shortest arrangement. Such a member is the
coordinator. It has no work of its own to observe, so observing the members is what it
does.

How many such members there are, and whether the one observes every other member directly
or through a chain, are chosen and not forced. One is the fewest.

**The implementation.** In ghostunnel's ring the game's "stopped" is "halted", and the
start at issue is the lifting of a halt. "Nobody restarts anything"
(`observers/SPEC.md:564`). The asymmetry the theorem forces is there: "Detection is
unilateral, recovery is agreed" (`:568`). The coordinator stands down first, and each other
member's condition for clearing includes that the coordinator's halt is gone (`:556-558`).

The coordinator does not stand down unchecked, and the ring does not resume while a member
cannot read the coordinator. Its condition is that no
store holds a fault and that none of its own assertions failed in the cycle
(`observers/SPEC.md:556`). Those assertions cover every other member: its store is
readable, it is present, and its heartbeat is fresh. It has advanced within the staleness
bound or, on a cycle in which the coordinator holds no earlier reading of it, it carries a
timestamp within the absolute bound (`:364-379`). So the coordinator stands down only when
it has checked every member and found each one's heartbeat fresh. By the specification a
member that is cycling reads the coordinator in every cycle (`:28`) and records what it
read (`:184`), and a member that cannot read the coordinator fails an assertion (`:364`)
and raises a halt of its own (`:425`). A failing assertion about another member publishes
no fault (`:199`), so that halt does not block the stand-down (`:556`). It keeps the ring
halted until the member can read the coordinator again (`:418`, `:558`).
The coordinator's own assertions do not test that each member has read it. None of the
members clears while the coordinator is lost, because its silence is a failing assertion
of each (`:383`). The proxy's gate also treats the coordinator's heartbeat as the one
signal it cannot run without (`:818-834`).

### 10.4 Is the structure unique?

Not settled. Uniqueness is a claim about every possible system, so no finite check can
establish it. It can only be refuted, by a system that meets all four constraints, has no
gap, and is not a variant of the ring.

No such system was found. Several arrangements pass the detect-and-halt checks at one fault
per round: a mesh of two, of three, of four; a ring of three; three and a coordinator; the
interleaved rings. None is a counterexample. Each either fails another requirement, or is
the ring with different wiring or counts. A mesh or ring with no member that can start
first cannot recover from a full stop (section 10.3). Two monitors cannot name the faulty
one (section 10.2).

What this work does show is that every count and every role in the ring has a reason.
Whether those reasons leave room for something different in kind is open. Section 12 sets
this against the falsification criteria.

### 10.5 The ring as built, against the model

Two implementations of the ring exist, both public:

- an observer ring around the ghostunnel proxy:
  <https://github.com/QupDrawn/ghostunnel> (branch `portal`);
- an observer ring around the Platform Racing 2 server:
  <https://github.com/MinichordDrawn/platform-racing-2-server> (branch `drawn`).

The fuller of the two is ghostunnel's. This table sets the model beside its
specification, `observers/SPEC.md`. Citations in this note are to the ghostunnel
repository at commit `0741dac`. Those with the prefix PR2 are to the Platform Racing 2
repository at commit `b8066d0`.

| In the model | In the implementation | Comment |
|---|---|---|
| a round | one cycle; a change that lands after the first read of a path within a cycle is judged by the next cycle's first read, "a latency of at most one cycle" (`observers/SPEC.md:604`) | the model's unit of time is the cadence |
| signal read | `member-fresh`: a heartbeat must change within the staleness bound (`observers/SPEC.md:358`, `:375`) | all pairs (`:28`) |
| state check | `copy-current` (`observers/SPEC.md:403`), `binary-expected` (`:713`) and others: current state against a reference | |
| state check of a monitor by a monitor | `surface-disagree`: each member recomputes another's published result (`observers/SPEC.md:673`) | the check that catches a member that shows nominal while faulty |
| not modelled | history checks: hash chains and a trace that may only grow (I1, I3, I4, `observers/SPEC.md:451-462`; `trace-consistent`, `:674`) | they catch a change that was seen once and later undone; see below |
| reports | the finder writes its halt into every other member's store; the others relay next cycle (`observers/SPEC.md:531-548`) | direct to all three, so fan-out three |
| halt inputs | the gate reads every member's `halt`, `fault` and `halts/`, and the coordinator's heartbeat (`observers/SPEC.md:818-834`) | the reflex wiring of section 8.1 |
| the gate | "Permission requires both … read and found clean" (`observers/SPEC.md:899`); the proxy "starts, and refuses visibly" (`:872`) | stopped by default |
| the response | refuses, and closes every connection in flight (`observers/SPEC.md:820`) | an action as well as a stop |
| the model ends here | the clear protocol (`observers/SPEC.md:554-568`): "Detection is unilateral, recovery is agreed" (`:568`) | the coordinator clears first; the others clear only once its halt is gone (`:558`) |
| boundaries | five operating-system users, the proxy and each of the four members (`observers/SPEC.md:15`, `:890`); one store per member and one writer per path (`:34`); all on one host (`:834`, `:911`) | the host is the scope; a level above is outside the specification |
| shared substrate | the proxy and its observers run on the one host (`observers/SPEC.md:834`, `:911`) | losing the host stops both, which is P2's second face |
| P7 | members are declared, not discovered; a declared member with no store halts the ring (`observers/SPEC.md:266`, `:364`) | for monitors, absence is made detectable in place of automatic enrolment |

Three things follow.

- *The coordinator's special role is in recovery, which is where section 10.3 places it.*
  Any member halts the ring alone. The coordinator clears first, when no member's store
  holds a fault and none of its own assertions failed; the others clear only once its halt
  is gone (`observers/SPEC.md:554-558`). None of them clears while it is lost, because its
  silence is a failing assertion of each (`:383`). Its other difference is that it sees
  more: it holds a copy of the other three stores, a comparison no other member can make,
  and it watches no work of its own (`observers/README.md:18`, `:22`).
- *The implementation goes further than the model on history.* The model has no step that
  repairs a bad state. The implementation does better than that assumption needs: its hash
  chains and its append-only trace catch a state that was bad when some member read it and
  was put back afterwards (I1, `observers/SPEC.md:451-454`; `trace-consistent`, `:674`).
  Both compare the store with what a member recorded at an earlier read. A change made and
  undone between two reads, seen by nobody, leaves nothing recorded, and neither catches
  it. Assumption 2 leaves that case out, and the cadence bounds it.
- *The scope is one host.* Everything the ring guarantees is inside that boundary. Losing
  the host is the step of section 2.7, and the answer is the level above. The
  specification states its own edge in the terms of section 2.7: the intended build, the
  host, the legitimacy of a member and the checking code itself are facts the deployment
  cannot establish from inside (`observers/SPEC.md:911`).

## 11. Limits

- **The model is synchronous.** Rounds give every monitor a step after at most `f` faults.
  A system
  whose monitors can be delayed without bound is a different model, and the results would
  need redoing there.
- **A round hides what happens inside it.** G2 is judged per round, and a round is one
  monitor cycle. Work done between two checks acts on the earlier check. In a real system
  the impact before response is therefore bounded by the cadence, not zero, unless each
  action is itself checked before it takes effect.
- **Recovery is treated only in a small model.** The round model ends at the first
  complete response. Section 10.3 covers restarting from a stop in a model that has only
  liveness; it is not joined to the round model. Lifting a halt while a fault may still be
  present, and what a second fault does to a halted system, are not modelled. The argument
  for three that rests on naming the faulty monitor is proved as a statement about
  outputs, not checked in the transition system.
- **"R has no gap" is a one-step result.** Because the model ends at the first complete
  response, what the search establishes for R is that every possible first fault is
  answered completely in its own round. It is exact, it is small (23 states), and it is for
  one fault per round.
- **Removals are all or nothing.** Each removal in section 6 takes a whole property away.
  In R, 18 of 27 single edges can be removed one at a time without opening a gap (the
  reviewer's count), so the tables show that none of a property is too little, not how much
  of it is needed.
- **A flag never goes down.** A flag raised for an earlier event satisfies G1 for a later
  bad state that nobody detected. The reviewer found no printed result that depends on
  this.
- **Repair, and a change that is made and undone, are outside it.** Both belong to the
  implementation (section 2.5, item 2).
- **Theorem S is for one fault per round.** For more, the necessary conditions are proved
  and the mesh is settled, but no general sufficient condition for an arbitrary graph is
  given.
- **The growth results are for one growth law,** doubling, **and one halting order,** good
  processes first. Another order can do more damage (section 8.2).
- **A finite check covers the system checked.** "Neither judgement can be violated" for a
  named system means every reachable state of that system was explored. It carries to
  other systems only through Theorem S.

## 12. Against the falsification criteria

The framework states four ways it could be shown wrong. This section sets the results
against each. A criterion that is "not met" has not been satisfied by anything found here.
No proof is claimed that nothing could satisfy it.

**What this work could reach, and what it could not.** Section 7 divides the argument into
two halves. The criteria divide the same way.

| Claim | What tests it |
|---|---|
| If these kinds of fault exist, each property is needed, and together they leave no gap | the checker, the independent provers and the falsifier search: done here |
| These are the kinds of fault, and only these properties answer them | the fourth criterion; and the first, by exhibiting a real system, or a model built from a different list of faults, that answers one of them another way |
| No kind of fault is missing from the list | building real systems and trying to break them |

Inside this model the first criterion cannot touch the second claim, because the model
assumes it: no search here can find a system that catches a fault in a way the model does
not contain. In each case what would refute the claim is a single counterexample. Nothing
here asks for proof of a negative, such as that some kind of fault never occurs; the third
constraint rules that assumption out in any case. The third claim is not one of the four
criteria. It is what the two implementations test.

### 12.1 An alternative stable configuration

*A system that meets all four constraints, does not exhibit the properties, and still has
no gap.*

**Checked: a census.** Every plain system with two monitors, one work process and no
self-edges (1,024 of them), and 4,890 distinct plain systems with three monitors, at one
fault per round. The three-monitor systems come from 6,000 draws, half uniform and half a
full mesh with up to six edges removed, so that enough of them have no gap. 12 and 1,721
of them have no gap. For each of those, the checker tested six predicates on signal reads,
state checks, reports and halt sources. These are the structural forms of the properties a
plain system can lack. The out-of-boundary predicate of section 3.2 is the same as the
signal-read predicate where no two monitors share a boundary. Where one failed, it first
set aside the monitors the system does not depend on: a monitor is *spare* if the system
with that monitor deleted still has no gap.

| Predicate | Fails among the 1,733 systems with no gap | Still fails with spare monitors set aside |
|---|---|---|
| every process has a state checker other than itself | 0 | 0 |
| every work process has two different halt sources | 0 | 0 |
| every monitor's signal is read by another monitor | 103 | 22 |
| every monitor's signal is read by another monitor, or by a work process that halts on its silence | 23 | 0 |
| a flag reaches every other monitor | 387 | 289 |
| a flag reaches a halt source of every work process | 32 | 9 |

What this shows:

- *State checking and two halt sources* hold in every system with no gap. Both are also
  proved: a state checker for every monitor, and two halt sources, in section 6; a state
  checker for every work process in the falsifier's report
  (`verification/f-falsifier/falsifier-report.md`, section 7).
- *The liveness signal* holds in every system with no gap, once it is read by what it
  does: the silence of every monitor the system depends on is read by another monitor, or
  by a work process that stops on it.
- *Propagation* fails as a predicate in 289 of them even with spare monitors set aside,
  and there is still no gap. In 243 of the 289 no report is needed at all: the system has
  no gap with every report edge removed, because the work process takes its halt directly
  from whichever monitor detects, or halts on a monitor's silence. In the other 46 a flag
  does travel, along particular report edges and not between every pair.

Scale accounts for this, as it did in section 6, and none of these systems is an
alternative configuration. In all 289 one detection still stops the whole system, which is
what the property is for. The short path is available only while the system is small
enough for the work to read every monitor that might detect. At scale, reading every flag
before each action is itself an evaluation window (argued, as in section 6), and the flag
has to travel between observers.

Two limits on what the census can say. It covers one work process and at most three
monitors. And it judges detection and halting only: it says nothing about recovery, so
none of these systems has been shown to meet the fourth constraint, and by section 10.3 a
ring with no member that can start first does not.

**Checked independently, and exhaustively.** A separate agent, given only the
specification and the definition of a falsifier (a system with no gap in which a predicate
fails and no deletion of spare monitors repairs it), wrote its own deciders and settled
every system of these sizes. It decided the first and third rows one by one. For the
second and fourth it decided each wiring of signal reads, reports and halt inputs, and
then visited every system with no gap. It counted the last.

| Monitors, work processes | Systems | With no gap | Of those, with no spare monitor |
|---|---|---|---|
| 2, 1 | 1,024 | 12 | 12 |
| 2, 2 | 16,384 | 36 | 36 |
| 3, 1 | 16,777,216 | 1,169,616 | 742,352 |
| 3, 2 | 1,073,741,824 | 25,364,400 | 20,131,760 |
| 4, 1 | 2^44 | about 3.75 x 10^12 | about 9.24 x 10^11 |

At each of its five sizes it found what the census found at its two: which predicates
never fail and which do. At three monitors the shares differ, because the census weighted
its draw. Its samples of larger systems show the same.

- State checking and two halt sources hold in every system with no gap, without
  exception. It proved both for systems of any size.
- Of the two predicates about edges between monitors, the one for signal reads fails in a
  minority of systems with no gap (178,176 of the 1,169,616 in the third row, and none
  with two monitors) and the one for reports in most (798,222 of them). One or the other
  fails in most, including where no monitor is spare: 515,030 of the 742,352 in the third
  row.
- What is left of the signal-read predicate is proved without exception: where no monitor
  is spare, a monitor whose signal no other monitor reads is always one the work halts on.

So the form in which a signal is read, and the form in which a flag reaches the work, vary
from system to system. Two things do not. Another monitor, or the work, reads the silence
of every monitor the system depends on. A bad state is flagged and stops the work in the
round it appears, which is what no gap means in these systems. A flag raised for a silence
alone need not stop the
work: in the falsifier's four-monitor system 6.6 one monitor flags another's stop and the
work carries on.

**Result:** not met. No system was found that meets all four constraints, has no gap, and
lacks the properties. The searches judge detection and halting only, and none of their
systems has been shown to meet the fourth constraint. Within them the predicate forms of
the signal-read and report properties (section 3.2) do fail in systems with no gap and no
spare monitor, and the falsifier's verdict on the claim as put to it, which was the claim
in its predicate forms, was "The claim is false". What holds in every one of those systems
is narrower, and is stated above: the function of section 3.1 in a smaller form.

### 12.2 An unnecessary property

*A proof that one of the eight properties can be removed without creating a gap.*

Such a proof would have to hold for every system, so one system in which the removal opens
a gap rules it out. For each of the eight there is such a system (section 6). Of the four
criteria, the model check closes this one most firmly.

How the properties relate to each other does not make any of them removable.

- P6 builds on P1. P1 can be present without P6, and then one loss of a whole boundary
  takes the signal and its reader together. P6 cannot be present without P1.
- P2 does by construction what a check can also do. A freshness rule on reads catches a
  substrate failure under the watched process, and halting on silence stops work whose
  observer is gone. Both are checks, and a check has a threshold, during which work runs
  unobserved. Against the loss of a substrate, sharing it has none (section 6).
- Propagation is a direct read in 243 of the 289 small systems of section 12.1, and a
  report along particular edges in the other 46. The direct read is the property's form at
  the smallest scale. The property is present in it.

**Result:** not met.

### 12.3 A fifth constraint

*An additional constraint that produces a fundamentally different fixed point.*

No finite piece of work can list every constraint, so this cannot be settled here. What can
be reported is what the model turned out to need beyond the eight properties, and what kind
of thing each was.

| What the model needed | What it is |
|---|---|
| the gate: monitors check before work steps | emergent, from the second constraint: no impact before detection |
| the reflex wiring, and a halt passed to at least two | emergent, from the second constraint and a fault that grows |
| a member that can start first, from which every other member is reached | emergent, from the fourth constraint |
| a bound on faults between two checks | the implementation's choice, under the scaling law |
| a scope, and a level above it | the implementation's choice, under the scaling law |

Nothing in that list is a new constraint. Making the model harder along each axis it has
(more faults per round, wider boundaries, deeper recursion) changed counts and levels and
never the kind of structure.

One candidate was considered and not tested: a requirement to keep serving through a
fault. The model's halt rule rejects it. If the halt is read as the system's own response,
which may be to cut out the faulty part and carry on, the requirement becomes naming the
faulty member, and that adds a count (three, section 10.2) and no different structure.
This paragraph is argued and was not checked.

**Result:** not met by anything tried; open in general.

### 12.4 Non-convergence under reproduction

*An independent team, starting from the same four constraints, arriving at a different
class of solution.*

Not tested. An attempt was made with three agents given only the four constraints, but
each could see this workspace's own one-line description of the ring, so they were not
independent, and their derivations are set aside. The evidence that exists on this point
is of another kind: the two implementations, built and run.

## 13. Verification record

Every phase but those listed at the end of this section was checked by an agent started
fresh for the purpose. Passes A to F were each given only the artefacts to check, in a
folder of its own, and never the author's reasoning, expected results or proofs. The
checker given to B carries its own comments and nine of the ten schedules of section 6.
The author added the gate's after B's pass. The final round was given this note and the
README, which contain the author's reasoning, expected results and proofs.

Two caveats apply to all of them.

- An agent started in the workspace where this was done can see that workspace's one-line
  description of the framework. The verifiers were independent of the reasoning here. Each
  knew the conclusion being claimed.
- The author's work and every pass ran on one model, Claude Fable 5.2. A mistake that
  model makes consistently would pass every one of them. The reimplementation and the
  exhaustive searches guard against it for results about named systems. The written proofs
  have no guard of that kind in this folder. Theorem S and most of the results on what any
  system needs are also proved in Lean, in `../lean-proof/`, where a separate program
  checks the proofs.

| Pass | Given | What it did | Result |
|---|---|---|---|
| A, reimplementation | the specification and the cases | implemented the model from the specification alone and computed every case | identical on all 103 cases (the last two were computed afterwards with its code unchanged); ten points of ambiguous wording, listed in `report-a.md`. The alternative readings it ran, for five of the ten points, changed no result, apart from one reading the text excludes. For the other five it ran none: two it left untested, one it argued cannot change a result, and two concern inputs that no case contains |
| B, review | the specification, the property statements and the checker | compared them clause by clause; wrote its own implementation and compared 94 cases, 1,648 random systems and 600 variants of R; judged each removal; tried to break R by hand | no deviation in the model; defects at the edges of the script; the labels in section 7 and several of the limits in section 11 |
| D, prover | the specification and nine claims as bare statements | proved or refuted each | all nine hold; one needed "two different halt inputs"; it gave sharper growth bounds |
| E, prover | the specification and six further claims | the same | all six hold; "at least one work process" must mean one present from the start |
| F, falsifier | the specification and the definition of a falsifier | wrote three deciders of its own and searched | section 12.1 |
| Final round, forwards | this note, the README and the folder, as they stood before the author applied the reconciler's rulings (the correction) | checked every claim against the folder, from the first section to the last, and ran the checker in full | 422 claims: 357 confirmed, 40 narrowed, 4 wrong, 21 not checkable |
| Final round, backwards | the same | the same, from the last section to the first | 494 claims: 423 confirmed, 40 narrowed, 4 wrong, 27 not checkable |
| Final round, reconciliation | both lists of findings and the folder | merged their 88 entries into 52 points and ruled on each from its own recomputation or reading | 13 accepted, 21 accepted with a change, 11 reworded, 7 kept; none rejected whole. It marked four rulings in which a verifier's own correction would have put an error into the text (R6, R28, R34, R47). It raised nine further points |
| Final round, sweep | the corrected note and README, and the folder | checked every claim again, and every sentence against the writing rules; ran the checker in full on the script as it then stood; the author edited its docstrings afterwards, in answer to the sweep | 724 claims: 677 confirmed, 37 narrowed, 5 wrong, 5 not checkable; 7 entries on style and 13 on sense |
| Final round, last check | the passages changed in answer to the sweep, as two diffs, and the folder | checked every changed passage against the folder and the writing rules; refereed the proof of section 10.3; ran the checker in full | 252 claims: 225 confirmed, 18 narrowed, 1 wrong, 8 not checkable; 9 entries on style and 13 on sense. It found the statement proved in section 10.3 true of the game as the script defines it, and two steps of the proof in need of rewording |
| Final round, confirmation | the passages changed in answer to the last check, as two diffs, and the folder | judged each changed passage on the evidence, then checked that each of the last check's corrections was in the documents; ran the checker in full | 183 claims: 167 confirmed, 8 narrowed, 2 wrong, 6 not checkable; 4 entries on style and 5 on sense. All 42 corrections were in the documents. It gave 20 entries with exact replacements |

The letters are those of the working folders. No pass was lettered C. The two verifiers of
the final round, the sweep, the last check and the confirmation each reproduced
`run-output.txt` and `results.json` from the script. None of the five found a result of
the checker wrong: every correction was to the wording around a result. Their reports are in
`verification/g-final-round/`. The sweep's report names two diffs, a listing and the
three files of its full run that are not in its folder, because they repeat the documents
and the files of this folder, and three of its scripts have no saved output. The last
check's report names two diffs and a folder for its full run that are not in its folder,
for the same reason. One of its scripts, `lc06_changed_lines.py`, reads working files and
does not run where it stands. The confirmation's report names a folder for its full run,
three patched copies, two listings, and three scripts and their three outputs that are
not in its folder. Two of the scripts read working files. The third checks the
confirmation's replacements against the two documents and the script as they stood before
the author applied them.

The two verifiers and the reconciler read the documents as they stood before the
correction, when the README had 10,236 bytes and this note 1,330 lines. The correction
added passages none of them saw. The sweep is the first pass that checked those. The two
verifiers' reports call this note `formal-results.md` and this folder `formal-model`,
their names at the time, and give line numbers of the text before the correction.

**What changed because of these passes.**

- *From A.* The author tightened the specification's wording in eight places.
- *From B.* The author fixed four defects in the script: a replay that ran past the point
  where the model ends, an argument that misbehaved when given as a string, the test for a
  joiner, and a missing key. The verdict table carries B's label for each of the nine
  removals B reviewed. Section 6 says that the shortest gap in R without P1 is P2's. Three
  limits were added to section 11.
- *From D.* Theorem S says "two different halt inputs". The growth bounds of section 8.2
  are D's, which are sharper than the ones first claimed, and were checked by computation
  before being adopted.
- *From E.* The two statements that hold for every system, for the window and for the
  gate, say "present from the start".
- *From F.* Section 12.1 reports F's exhaustive counts beside the author's smaller census,
  and its proofs for systems of any size.
- *From the two verifiers and the reconciler.* The author corrected five wrong statements:
  - the Python version the script needs;
  - a path to a verifier's file;
  - a quotation from the implementation's specification with one word too many;
  - the heading of section 3.1, which named three layers above a table of four;
  - the claim that a halt reaching good processes first is the worst order (section 8.2).

  The author gave the narrowed claims the conditions they hold under. The chief ones:
  - the reflex count of section 8.1 holds when no other fault lands;
  - the second face of P2 is for a loss that stops the work too;
  - the interleaved rings were checked at one fault per round;
  - the halt fan-out and the gate also break G1;
  - the reviewer's random trial covered eight removals;
  - two of the falsifier's five sizes were decided wiring by wiring;
  - the result of section 12.1 reports the falsifier's own verdict on the claim in its
    predicate forms.

  The author gave the comparison of section 10.5 a citation for every line it relies on.
  The reconciler left three points for the author. The author settled two from the two
  public repositories: the line in the second implementation that says every member watches
  every other, and that the commits cited are the heads of the public branches. The author
  settled the third,
  which kinds of fault the four constraints assert (section 7), from the
  framework's statement of the constraints.
- *From the sweep.* Five statements were wrong, four of them in text the correction had
  added:
  - the claim that every property is needed against "no impact" alone (P6 is the
    exception);
  - the number of schedules in the checker given to B;
  - the number of statements the earlier passes had found wrong;
  - in both documents, the number of rulings the reconciler marked unsafe.

  The chief narrowings:
  - the result at the head of section 1 is stated for the reference system and for
    Theorem S, and says that the properties written as fixed predicates are not enough
    alone;
  - section 10.3 states the restart game as the checker runs it, and keeps what is true of
    the implementation apart from what is true of the game. That every other member must
    be reached from the member that starts first is proved there, and the sweep checked it
    on every graph of three and of four members;
  - the sentence on when the coordinator stands down says what the specification's lines
    support and what they do not;
  - the census of section 12.1 says how its systems were drawn.

  The author added a fourth kind of evidence, argued, at the head of this note and marked
  the passages of that kind. The author applied the sweep's entries on style and sense,
  two of them in part: the README keeps the wording "Four cases are provided here", and
  the asteroid stays in section 2.7 as an example.
- *From the last check.* One statement was wrong: section 4 said, under the label
  "checked", that a higher tier would need more than one state checker for a work process,
  and the checker shows otherwise. The author removed the clause. The chief narrowings:
  - the general theorem named in the result of section 1 is for one fault per round;
  - the restart game applies the round model's rule for silence in a weaker form;
  - the author reworded two steps of the proof in section 10.3 and defined "can always
    restart". The statement stands;
  - what section 10.3 says of both implementations is limited to what the cited lines of
    each one show;
  - the census of section 12.1 tests six predicates;
  - the README says that no pass of the final round found a result of the checker wrong,
    where it had said no pass.

  The author corrected three docstrings in the script. The script's code is as the last
  check ran it.
- *From the confirmation.* Two statements were wrong. Section 10.3 said that a member
  which cannot read the coordinator publishes a fault, and that the fault blocks the
  coordinator's stand-down. By the specification that member raises a halt, which keeps
  the ring halted and does not block the stand-down. This section said that the last check
  had read every line section 10.5 cites. It read the lines cited in the passages it was
  given. The author applied the confirmation's 20 entries by script, as it worded them,
  one of them to a docstring. The author then wrote these passages by hand.
  In this note: the first sentence of the second paragraph of "The implementation" in
  section 10.3, to agree with the first of those corrections; the confirmation's row in
  the table above; in the paragraph after that table, the count of five passes, the
  sentence on `lc06_changed_lines.py` and the sentence on the files the confirmation's
  report names; and this bullet. In the README: the sentence that gives the confirmation's
  counts and the sentence after it. One further agent read each of them. The author
  applied that agent's two replacements.

**What the passes before the final round did not cover.**

- The restart result of section 10.3, the second face of P2 in section 6, and the case of
  one unread signal at two tiers in section 4 were added after them. In the final round
  the verifiers checked the restart result and the two-tier case against the script, and
  the second face of P2 against the definition of `fail-substrate`, since its threshold is
  in neither the specification nor the script. The reconciler and the sweep recomputed
  each. No prover received any of them as a bare statement.
- The TLA+ module of section 9 has not been run through TLC.
- One claim given to E, about lifting a halt, is not used. It rested on a premise that
  does not hold in a ring whose members watch each other, and section 10.3 stands in its
  place.
- The comparison with the implementation in section 10.5 began as a survey by two agents.
  The author then read every line it cites, and the reconciler and the sweep read each
  again. The last check read the lines cited in the passages it was given. Every citation
  resolves against the two repositories at the commits named.

## Files

| File | Contents |
|---|---|
| `README.md` | what this folder is, the method, and what is and is not established |
| `results.md` | this note |
| `model-spec.md` | the model, stated completely |
| `check_model.py` | the explicit-state checker and every system above |
| `run-output.txt` | its full output |
| `results.json` | every case with its result |
| `systems-all.json` | the 103 cases, without their results |
| `Heartbeat.tla`, `Heartbeat.cfg` | the TLA+ module of section 9 |
| `verification/` | one folder for each independent pass, with what it was given and what it produced |

To rerun: `python -I check_model.py` (Python 3.9 or later; several minutes, and about two
gigabytes of memory at its peak). Add `--traces` to print the ten executions of section 6
and, for each system with a result line, the shortest execution that breaks each
judgement. The 55 one-edge removals print none. `run-output.txt`, `results.json` and
`systems-all.json` were made with `--json results.json --systems systems-all.json`.
