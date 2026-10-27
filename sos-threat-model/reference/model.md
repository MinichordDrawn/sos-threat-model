# The model: self-observing systems

A framework for self-observing distributed systems. Four sections: the structure the
framework converges on, the four constraints it rests on, the eight properties the
constraints require, and the rules that scale it to a system's consequences and trust
boundaries. Every audit in this kit judges a system against this model and nothing else.

## 1. Emergent structure

The structure emerges from satisfying the constraints and properties together. A correct
self-observing system converges on it, so it works as a reference architecture: read the
structure to find where a real system deviates, then name the missing property.

### The ring

The observation functions form a ring of at least 3 + 1. The 3 are three observers that
mutually observe each other.

- A ring of two can be compromised by killing both nodes, one after the other or at once.
- A ring of three is much harder to kill at once.
- Rings within rings, where a node is itself a ring, strengthen the structure further.

The +1 is the ring's coordinator, an observation function qualitatively different from
the rest. It belongs to the ring, not outside it. It checks something about every other
observer in the ring, including itself, and the others report and validate back to it.
Its check stays at the surface, because its role is coordination, not deep inspection.
That surface vantage usually makes the coordinator the ring's primary halt.

Every observer checks one other observer and reports to a different observer.

Nested rings chain upward through their coordinators. A ring's coordinator is a member of
the ring above it and carries its ring's health up. A coordinator two levels up does not
check the rings two levels down; those rings verify themselves and report to the ring
above them. A failure propagates up the chain of coordinators, so the top sees it without
inspecting the bottom. Deep verification stays local; only the surface signal travels.

### Triangulation

Three points define a plane, three edges a rigid polygon, three independent constraints a
unique solution. Three is the minimum for determinacy; below three, a structure carries
degrees of freedom (gaps, ambiguity, instability). The +1 uses that determinacy to act.

### Structure and information

The framework prefers deterministic, static, verifiable structure over process: hash
verification over human approval, cryptographic proof over trust, machine override over
committee decision. A process-oriented design carries more human gates and more
coordination, and it fails the constraints as a workflow.

Satisfying the constraints pushes a system onto structural checks rather than procedural
ones. A structural check resolves in a step; a procedural one walks its inputs. Chained
structural checks still beat chained procedural ones, which is why a structural response
can match an exponentially growing threat and a procedural one cannot.

Because structure is faster, the model can evaluate availability and performance too, not
only safety. A tradeoff made in the name of availability is not automatically superior:
the structural alternative may win on availability as well, and only modeling that
alternative settles it. An availability claim is a claim, not a justification.

Everything is either structure (spatial, persistent, rigid) or information (temporal,
dynamic, causal): what things are, and what things do. Three is the minimum count where
structure holds without unresolved failure modes (Hamming distance 2 can detect an error
but not correct it). The +1 is always singular, qualitatively different from the three,
and the part that makes rigid structure do something rather than merely exist.

### Halt on fault

Byzantine fault tolerance is the wrong model here. A system that keeps serving through a
detected fault keeps serving through a compromise. When any observer detects a fault, the
system halts. No actor, however privileged, passes a critical observer without the
observer alerting and the system halting until that actor has left.

Any node can halt the system, and any halt propagates to at least two other nodes.

A sequential observer (a scheduled check, a periodic review, an evaluation gate) cannot
contain an exponential process: during the evaluation window the process doubles. Only a
reflexive, structural response matches the growth curve, because detection by one agent
triggers activation across all of them at once.

### Execution-observation coupling

The observer emits a heartbeat. The execution thread checks that heartbeat and runs only
while it beats; when the heartbeat stops, execution stops. Execution cannot outlive its
observer, so killing the observer also stops the work it watched. The default is stopped,
and only a live heartbeat permits work: observation gates execution.

## 2. The four constraints

Let S be a system of distributed agents satisfying:

1. **No central controller.** No agent coordinates the others; no agent has authority
   over any other.
2. **Catastrophic cost of undetected failure.** Silent failure of any agent's observation
   function produces consequences disproportionate to the cost of a false-positive
   response.
3. **Adversarial environment.** Threats can mimic legitimate components; the system
   cannot assume benign failures.
4. **No external maintenance.** The system detects, responds to and recovers from
   failures without relying on an external authority to notice or intervene.

The constraints are a filter that puts a problem in the model's scope, not a bar the
system under audit is failing to clear.

## 3. The eight properties

The constraints require these eight observation properties. Removing any one opens a
specific attack (`eight-properties.md`). Every observer satisfies every property; the ring
is what lets a pure observer satisfy the response properties through its peers rather
than alone.

1. **Heartbeat.** A liveness signal whose absence triggers response.
2. **Substrate dependency.** The observer shares the failure substrate of what it watches.
3. **Continuous state verification.** The observer checks current state against
   known-good, not only events.
4. **System-wide response.** One observer's detection propagates to the others.
5. **Self-defense.** The observer resists single-action removal.
6. **Death signaling.** When an observer dies, its absence crosses an independent
   boundary and is acted on.
7. **Automatic integration.** New components enter observation automatically, with no
   manual-configuration window.
8. **Reflexive response.** The observer responds on detection, with no evaluation window
   an attacker can act in. Any node can halt the system, and a halt propagates to at
   least two other nodes.

## 4. Consequence tiers and trust boundaries

### Consequence-proportional complexity

Required observer complexity scales with the cost of undetected failure.

| Consequence tier | Required stack |
|---|---|
| Bounded (one service) | Cron and an alarm |
| Significant (multi-team) | Heartbeat and automatic restart |
| Severe (organizational) | Redundant observers, escalation |
| Catastrophic (system-wide) | The full stack: the 3+1 ring |

**Customer data sets the floor.** Any subsystem that carries customer information or data
runs at the Catastrophic tier, whatever else is true of it, and requires the full stack.
The public comes first.

"Catastrophic" is relative to the observer. A small organization may judge silent
compromise of its critical systems catastrophic to its operations, and the constraints
apply at any scale where that judgement holds. Only the morphology varies: the number of
rings, the depth of the detection chains, the number of independent trust boundaries.

### Trust boundaries

Three boundaries, nested from the inside out.

1. **B1, the observer ring.** The machine-to-machine observer network itself. No human
   belongs inside it; any human access is an adversary event the ring detects and halts
   on.
2. **B2, privileged actors.** Backend, deploy, configuration, key or host access. Actors
   who can cause production impact by mistake or by malice.
3. **B3, external actors.** Customers and outside adversaries, with no foothold.

The ring treats every actor outside itself as an adversary, privileged insiders included.
Halt on fault holds for B2: a privileged actor passes no critical observer without an
alert and a halt. A finding reachable from B3 alone, with no crossing, matters most.
