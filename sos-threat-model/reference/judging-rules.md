# Judging rules

Rules that decide whether something is a finding. Each came from a correction on a real
audit; the reason is given so the rule can be applied to cases it does not name.

## What is and is not a gap

**A deliberate refusal is not a gap.** Where a structure declines to do something because
doing it would be unsafe, that is a property, not a deficiency. A declared member list is
not "automatic integration absent" when integration over the declared set is automatic and
what is refused is a component adding itself. Scoring the safe direction as a loss argues
against the model.

**Behavioural validation is not safety observation.** Whether the work produced the right
output is an integration test's job. An observer that checks business results in
production is a test holding production credentials, which is a new privileged position.

**A property is judged at the structure's own scale.** One coordinator is the model's own
closing condition, so an upward chain that ends at it has ended, not stopped short. Nested
rings do not apply to a structure that needs one ring.

**Do not score against an outside framework.** A comparison with another field's practice
tends to list deliberate scope boundaries as divergences. Judge within the model.

**Obedience is not a gap.** At a seam between two packages, a package that does what the
other's file, environment, return value or configuration tells it to is obeying, not
failing. The gap, if any, is on the side that produced the value. This rule dissolves most
seam candidates, and that is it working.

**Two gaps that add are not a chain.** A chain must reach more than its strongest gap
reaches alone. Two independent effects of one fault are a parallel effect, not a chain.

**Links made of people count.** The ring and the scorecard are machine-only, but where
people perform observation (a reviewer who approves a change, a designer who signs
off a design, a regulator who checks a document), gaps in their observation compose into chains
like any other and are judged by the same combined-impact test. A chain is not moved to
missing structure because its links are human.

**Only observers are scored.** An observer watches something and reports or acts on what
it finds. The work it watches, a passive barrier that watches nothing, a group of people,
and a device that only records or carries a signal are not observers, and a scorecard row
for one of them is a category error. People's checks are B2 controls; they discharge no
property.

**Information disclosure is information reaching a position that should not have it.**
Information the system held but never delivered to the position that would act on it is
not I: it is a missing component (no path carries it) or, where a record existed and
compelled no action, a repudiation row.

**Comments and log strings are claims, not behaviour.** Cite them as what the project
says, never as what the code does.

## Availability is never ranked

Availability and performance claims go in a section listed and left unevaluated. They are
never a row, never a severity, never a reason to rank a finding down. This holds both
ways: for a component that keeps serving through a fault, and for a fix that makes a
component refuse. A refusal is the model being satisfied; ranking its cost argues against
halt on fault against a baseline nobody has modeled. What can be ranked is an
inconsistency between components (one part binds a destination while another substitutes
a different one), because that refuses work meant to succeed and is a defect.

Availability claims include output, demand and schedule: a production target, a delivery
date, a deadline. A party that sets the system's targets or schedule is not an attacker
for setting them: the target is listed with the availability claims, not made an entry
position. A party that reaches the system's inputs (a client that sends requests, an
operator at a console) is still an entry position for what it can do there.

## Halt on fault is the control

The required control for every finding is one thing: the observer alerts and the system
halts until the fault clears or the privileged actor leaves. Continue-on-fault is a failed
control, not a mitigation. A retry with no limit, a degraded mode, a "warn and continue",
a fallback to a weaker channel and a default that serves are all continue-on-fault. A halt
that degrades into a continue (a check that fails, after which the system skips the check)
is recorded as exactly that.

A safety check that is off by default is missing in every deployment that leaves it off;
record the default as the finding, not the option that would enable it. A check that an
option, flag or environment variable can switch off is present only while it is on, and
the switch is a B2 path to its absence: privileged actors cause harm by mistake as well
as by malice, and an operator who does not know about a hidden fault will reasonably turn
off the check that would have caught it.

## Evidence and scope

**Every claim is a file and a line someone opened.** A claim nobody opened is marked
unconfirmed. A claim that rests on code not available (a dependency, a runtime, a service)
is marked as resting on it, and stays marked wherever it is used.

**A claim carries its source's confidence, never more.** A quotation keeps every qualifier
in the sentence it comes from ("probably", "it would appear", "may"), and a claim built on
a hedged statement stays hedged. Say what kind of statement a citation is wherever it
matters: what the code does, what a comment or document says it does, a source's own
finding, its presumption, a quotation of another document inside it, or recorded data. A
row that rests on a presumption or a quoted claim says so. On the calibration run against
a published investigation, restoring dropped qualifiers was the final sweep's largest
category of correction.

**No counterfactuals.** What would have happened had a check fired, or what a party
would have done had it known, is the source's claim or nobody's. State what the lines show
and stop.

**Source-supported against inferred.** A step that is a line in the audited tree is
source-supported. A step that rests on a seam's behaviour (the kernel, a runtime, a
library, a service, an operator's configuration) is inferred, with the seam named.

**Posture is not code.** Charts, unit files, manifests, default configuration and
documentation are posture. Label them as posture wherever cited. Where a code default and
a posture default disagree, give both.

**Deployment assumptions are marked.** A row or chain that needs a configuration away from
the shipped default, or a deployment the tree cannot produce on its own, is marked as a
deployment assumption and listed after the source-supported ones.

**Scope extensions are declared.** When settling a claim needs one file outside the agreed
scope, open it, declare it as a scope extension wherever it is used, and keep it to the
one fact it settles.

**Delegation boundaries are listed, not followed.** Name what the system hands to other
components (a library, a service, the kernel, the operator) and leave it there.

## Ranking

**One package.** Rank risks by what a position gains times how many installations or users
it reaches in one act, with nothing positioned to notice. For a single system with one
installation and no users in that sense (one plant, one institution), read the reach as how
many units one act reaches, then how far toward the floor (part of the system, the whole
system, the public). The result is an order:
place each risk against the others and break a tie by the position that needs no
privileged act. The scales below are not used for one package.

**An aggregate.** Rank by severity times detection times exposure, each scored 1 to 4:

- **Severity.** 4: an external position (B3) reaches customer data or identities with no
  further condition, for every user in one act. 3: the same reach behind a privileged
  condition, a deployment assumption or a caller's behaviour, or an external gain bounded to
  part of the system. 2: no position gains what it lacked, but a check on the path is
  absent, removable or inconsistent, or the gap is the only record of a fault. 1: the
  position already holds what the gap gives, or a record is missing with nothing gained.
- **Detection.** 4: nothing notices the path. 3: a log only. 2: an alert. 1: a halt.
- **Exposure.** The evidence step's tier for the risk. 4: the top list. 3: the second tier.
  2: an unverified lead. 1: none found. When no evidence step ran, say so and rank by
  severity times detection alone.

Ties go to the higher severity, then the lower rank in the risk's own package's impact
order, then the position that needs no privileged act. State the scales once, at the head
of the risks. A finding that reaches customer data ranks above one that reaches only the
system's own records; availability is not ranked. Give each ranked entry its row and chain
ids. The deliverable states this rule once, as its ranking rule.

## Modeling only

The audit describes code paths and their preconditions. It never includes exploitation
steps, working payloads, field values that make an attack work, addresses of live systems,
or instructions to run anything against a system the auditor does not own. A deliverable
states the path, the precondition and the file and line, and stops there.
