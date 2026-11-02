# SOS rule cases

Abstract cases, each with an answer key, for checking that a change to the
`sos-threat-model` kit's rules still gives the intended outcomes. They sit outside the skill
folder: the skill never loads them, and a model run never sees them.

Each case is a few lines of made-up evidence (a source tree, a design document or a physical
plant) built to exercise one rule or the boundary between two. The key says what the kit
directs for it: whether a check binds, whether a row results, whether the row stands or
rests on an unconfirmed item, which positions it is entered from, and, where the case asks,
the widest reach the row names.

## Layout

| Cases | Key | Rules exercised |
|---|---|---|
| `cases/objects-and-siblings.md` (A–T) | `keys/objects-and-siblings.md` | every object an input names needs its own binding; a check stated for one is owed by its like; B2 controls; seams |
| `cases/relays-and-reach.md` (A–AE) | `keys/relays-and-reach.md` | a relayed message is written by its sender; the widest reach is named; failed premises in the chain hunt |
| `cases/checks-and-deputies.md` (J1–J9 and variants) | `keys/checks-and-deputies.md` | whose check binds; "must" and "should"; stated exclusions and delegation; later reductions; validity windows; retry caps; trigger-only positions; deputies' own checks; store-forced owner fields |

Cases refer to one another only within a file ("as case A").

## Running a check

Kit paths below are relative to `../sos-threat-model/`.

Run each case file past two readers, each a fresh model session with no earlier context:

1. **Full rules.** Reads `reference/judging-rules.md` in full, then
   `templates/prompts/single-package.md` and `templates/findings.md`, then the case file.
2. **Prompt only.** Reads `templates/prompts/single-package.md` and nothing else from the
   kit, then the case file. This tests that the pass prompt's own restatements carry the
   rules without `judging-rules.md` behind them.

From this folder, give the readers the case file only. Keep the `keys/` folder out of their
reach (a separate copy of the cases in a fresh folder works). Ask each reader, for every
case, for:

- the binding or check outcome (bound, none, not stated with a U id, a stated exclusion,
  delegated, an availability claim, an unconfirmed item);
- whether a row results, what it is in one line, whether it stands or is conditional and on
  what, and which entry positions it is entered from;
- the widest reach the row names, where the case asks;
- the rule applied, quoted briefly with its file and line;
- anywhere the kit is silent, ambiguous or disagrees with itself for that case.

## Scoring

A case is a hit when the reader's outcome matches the key on each point the key gives:
binding, row or no row, standing or conditional, entry positions, and widest reach. Wording,
ids and severity are not scored. A further "writers not stated" entry for a channel or hop
the case leaves unstated (`judging-rules.md`, "A relayed message is written by its sender"
and "A deputy carries whom it acts for") is not an error; the relay key says where it
applies. A flagged ambiguity with the right outcome is still a hit; read it anyway, since it
often points at the next fix.

When a reader and a key differ, decide which is wrong before changing anything. Where
`judging-rules.md` directs the reader's answer, the key is wrong: correct it. Where the
authority and the key agree and the reader followed another file, a restatement has drifted:
correct that file. A prompt-only miss the full-rules reader gets right usually means the
prompt is missing a restatement.

## After a rule change

Re-run both readers on every case file, not only the one the change was aimed at, and have a
separate reader check the change itself: that it appears wherever the rule is restated
(`judging-rules.md`, the prompts, `templates/findings.md`, `reference/method.md`,
`reference/single-package.md`, `reference/general-systems.md`, `templates/threat-model.md`,
and for seams `reference/multi-package.md` and `templates/prompts/multi-package.md`) and
conflicts with no other rule. When a change is meant to move an outcome, update the key in
the same change and the kit version its header names.
