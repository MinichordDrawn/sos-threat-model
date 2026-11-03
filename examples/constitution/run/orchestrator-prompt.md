You are the orchestrator of an SOS threat-model run. Use the skill at
`«KIT»\` and follow its `SKILL.md`
exactly: read what it says to read, then run the single-package process.

Target: the United States federal government as the Constitution of the United States and
its twenty-seven amendments establish it: the three branches and how each checks the others
(the veto and its override, appointments with the Senate's advice and consent, impeachment
and removal, the judicial power as the text states it), elections and the counting of
electoral votes, presidential succession and inability, the amendment process, and the
division of power between the federal government and the states. The system is the text in
force with every amendment applied; a clause an amendment supersedes or repeals is context,
not part of the system. It is a system of people and institutions, so the evidence is a
document: House Document 110-50, "The Constitution of the United States of America As
Amended" (U.S. Government Printing Office, 2007), a work of the United States federal
government and so in the public domain under 17 U.S.C. §105, already downloaded to
`«WORK»\sources\constitution.pdf` from
`https://www.govinfo.gov/content/pkg/CDOC-110hdoc50/pdf/CDOC-110hdoc50.pdf` (SHA-256
7f29c4a79e310cc7bcee5f3fd07fb1367e463bd4530fa5d854ebdd4fd4402e57). Besides the text in force
it holds an editorial historical note, proposed amendments never ratified and an index; the
survey decides how each of those bodies is read. Do not download it again and do not use the
web.

Workspace: `«WORK»\` (target short name `constitution`).
pdftotext (xpdf 4.00) is at `«PDFTOTEXT»` (in Git Bash,
`«PDFTOTEXT»`). Python: run scripts with `python -I`.

Constraints for this run:
- Read nothing under `«PARENT»\` except the skill folder and this
  workspace, and nothing under `«AGENT-SETTINGS»\`. In particular, never open
  `«PARENT»\shared-templates\examples\`,
  `«PARENT»\us-constitution\` (an earlier run on this target),
  `«PARENT»\us-constitution-literature\`, or any other target's folder.
- Judge the structure the text establishes, and only that. Name no person, party, office
  holder, court decision, statute or event after ratification, and make no claim about how
  any power has been used: what the text does not settle is marked not settled by the
  document, as the kit says.
- Do not edit anything in the skill folder. If an instruction in the kit is unclear, wrong
  or missing for this kind of system, decide as the kit's rules best allow, record the
  decision and the reason in `«WORK»\scratch\kit-notes.md`,
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
