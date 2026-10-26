# SOS: Threat Modeling For Self-Observing Systems

A method, templates and agent prompts for auditing a software system's self-observation
structure and producing a source-cited STRIDE threat model. The model behind it holds that
where undetected failure would be catastrophic, everything that matters must be observed,
and that under adversarial conditions this converges on a ring of at least three mutually
observing observers plus one coordinator, with execution gated on observation and a halt
on any detected fault. The audit measures a real system against that structure and records
every shortfall as a finding proven by a file and a line.

<p align="center">
  <img src="images/survivorship-bias.svg" alt="Outline of a bomber seen from above, covered in red dots marking where returning aircraft were hit; the engines, cockpit and tail centre carry almost none" width="480">
</p>

The figure illustrates a study of bombers returning from missions in the Second World War:
each dot marks where a returning plane had been hit. The damage is everywhere except the
engines and the cockpit. The statistician Abraham Wald pointed out why: the planes hit
there did not come back, so their damage was never counted, and nobody thought to look for
it. The data showed only what survived to be seen. A system's own checks work the same
way. Each one looks for the faults someone thought to write it for, and a fault nobody
thought of produces no signal at all, which reads exactly like health. You do not know
what you are not looking for. So this kit does not start from the system's checks. It
starts from a model in which everything that matters is observed, so no failure goes
undetected, measures the real system against it, and reads for the silence: the missing
observer, the unchecked path, the fault with nothing positioned to notice it, each proven
with a file and a line.

To find something nobody is looking for, you need to know what to look for. The
codebreakers at Bletchley Park could not try every Enigma setting blind. They worked from
a crib: a fragment of plaintext a message was expected to contain, such as the wording of
a routine weather report, and tested settings against it. The machine's own structure
narrowed the search further, because Enigma never enciphered a letter as itself, so any
alignment where a letter of the crib fell on the same letter of the ciphertext was ruled
out at once. The model in this kit is the crib. It states what a system must contain for
nothing that matters to go unobserved (a ring of observers, eight properties, a halt on
any fault), so an audit tests the code against that pattern instead of searching it blind.

The people who run a system face the same problem. A decision is only as good as the data
behind it, and a fault the system does not report is missing from every decision made
after it. At Chernobyl, trained operators made each decision on the data the plant gave
them, and that data did not include a design fault in the emergency shutdown itself (IAEA,
INSAG-7, 1992). So the model treats privileged actors as positions that cause harm by
mistake as well as by malice, keeps every human outside the observer ring, and counts a
safety check an operator can switch off as missing.

The calibration runs behind it cover Go, Python, Rust and TypeScript projects, from a
single library to an aggregate of eleven infrastructure packages.

The model itself is not specific to software: it applies wherever its four constraints
hold. This implementation was built for software.

## What is in it

```
LICENSE                          CC BY 4.0 for the documents, MIT for the scripts
images/                          the figure above
sos-threat-model/                an agent skill (SKILL.md is the entry point)
  LICENSE                        a copy, so the licence travels with the skill
  SKILL.md                       what the skill does, what to read, the sequence
  reference/
    model.md                     the model: structure, constraints, properties, tiers
    eight-properties.md          the attack each property closes
    method.md                    the ring-first method, steps 0 to 3
    judging-rules.md             what is and is not a finding
    single-package.md            six passes for one repository
    multi-package.md             seams, aggregates, two-direction validation
    running-agents.md            operational lessons for running passes as agents
    writing.md                   the style every output follows
  templates/
    findings.md                  working template for passes 1 and 2
    threat-model.md              the single-package deliverable
    aggregate.md                 the multi-package document skeleton
    prompts/common.md            the block every pass prompt starts with
    prompts/single-package.md    one prompt per pass
    prompts/multi-package.md     seam, assembly, review and reconciliation prompts
  scripts/
    apply_edits.py               applies edit lists, asserting each target occurs once
    resolve_citations.py         checks every file:line citation against the source
```

## Using it with an agent

The `sos-threat-model` folder is an Agent Skill: a folder with a `SKILL.md` whose front
matter names and describes it. To install it for Claude Code, copy the folder into a
project's `.claude/skills/` (or `~/.claude/skills/` for every project). Other agents that
read skills load it the same way; any agent can also be pointed at `SKILL.md` directly and
told to follow it.

Then ask for an audit, for example: "Run the sos-threat-model single-package process on
the repository at `./packages/<repo>`." The agent reads the reference files, surveys the
tree, and launches every pass as a separate sub-agent, checking each one's counts before
the next.

Ask from the top-level session. Every pass must be its own sub-agent so the verifiers do
not check their own reasoning, and some tools do not let a sub-agent launch sub-agents of
its own. An orchestrator that cannot launch sub-agents stops rather than running the
passes in one context.

## Using it by hand

Read `reference/model.md` and `reference/method.md`, then follow
`reference/single-package.md`. Each pass's prompt in `templates/prompts/` works as a
checklist for a human reviewer too.

## What it will and will not do

- It reads source. It builds and runs nothing unless the auditor decides a probe is
  needed, and it never acts against systems the auditor does not own.
- Every claim is a file and a line. A claim nobody could confirm is marked unconfirmed.
- Findings are code paths and preconditions. The kit produces no exploitation steps.
- Availability and performance claims are listed and left unevaluated, never ranked.
- It names missing structure and leaves the design of any fix to the reader.

## Requirements

An agent or reviewer with read access to the source, and Python 3.8 or later for the two
scripts. For the multi-package process, enough context or enough sub-agents to hold one
package's verified model at a time.

## Credits

The survivorship bias figure, `images/survivorship-bias.svg`, is by Martin Grandjean
(vector), McGeddon (picture) and the US Air Force (hit plot concept), from
[Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Survivorship-bias.svg), used
unchanged under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

## Licence

Free to use, share and adapt, with credit: "SOS: Threat Modeling For Self-Observing
Systems, by Alexandra Thaler". The documents are under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) and the scripts under the MIT
licence; the figure keeps its own CC BY-SA 4.0 licence. See [LICENSE](LICENSE).
