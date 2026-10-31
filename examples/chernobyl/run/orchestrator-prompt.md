You are the orchestrator of an SOS threat-model run. Use the skill at
`«KIT»/` and follow its `SKILL.md`
exactly: read what it says to read, then run the single-package process.

Target: Chernobyl Unit 4, an RBMK-1000 reactor, as it stood on 25-26 April 1986, with its
automatic protection and control, its operating regime, and the design, operating and
regulatory arrangements around it. It is a historical system, so the evidence is a
document: IAEA Safety Series No. 75-INSAG-7, "The Chernobyl Accident: Updating of INSAG-1"
(1992), already downloaded to `«WORK»/sources/insag-7.pdf`
from `https://www-pub.iaea.org/MTCD/Publications/PDF/Pub913e_web.pdf`. Do not download it
again and do not use the web.

Workspace: `«WORK»/` (target short name `chernobyl`).
pdftotext (xpdf 4.00) is at `«PDFTOTEXT»` (in Git Bash,
`«PDFTOTEXT»`).
Python: run scripts with `python -I`.

Constraints for this run:
- Read nothing under `«PARENT»/` except the skill folder and this
  workspace, and nothing under `«AGENT-SETTINGS»/`. In particular, never open
  `«PARENT»/chernobyl/` or any other target's folder.
- Do not edit anything in the skill folder. If an instruction in the kit is unclear, wrong
  or missing for this kind of system, decide as the kit's rules best allow, record the
  decision and the reason in `«WORK»/scratch/kit-notes.md`,
  and carry on.
- Every pass, the assembly and the final sweep are separate sub-agents you launch; you do
  none of them yourself. If you cannot launch sub-agents, stop and say so.
- Models for sub-agents: fable for the breadth passes (1, 2, 4), opus for the verification
  passes (3, 5, 6) and the assembly, as the skill says. Record them in the run-state file.
- Do not quote the source at length in anything you write; quote only the words a claim
  needs.

Finish when the final sweep's corrections are applied and both output files resolve at
zero bad citations. Then report: the counts at every gate, the final outputs' paths and
citation counts, the shape and the top risks in a few lines, and every entry in
`kit-notes.md`.
