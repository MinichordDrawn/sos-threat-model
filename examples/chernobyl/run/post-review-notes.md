# Post-review changes (for the example README)

The run finished every gate on its own (final sweep applied, 0 bad citations). Afterwards,
on a review of the risk list, the following were changed by hand in both documents and
recorded in the deliverable's change note under "Post-review changes"; a separate Opus
verifier then checked every changed passage at its lines (scratch/post-review-verify.md).

- Risk 1: the heading names the void coefficient (INSAG's "most importantly, the physical
  characteristics of the reactor") beside the halt's positive reactivity and the ORM, as
  hazards with no stated observer; INSAG's coefficient sentence quoted whole (the void
  coefficient varied, the fast power coefficient stayed negative normally, both positive
  at the time of the accident); Annex I's initiating-event finding kept with its
  conditions; the chain ids narrowed from "X1 to X11" to X1, X2, X3, X7, X11; the
  Technical Safety Report sentence moved out (it stands in Impact rank 1 and the
  producing-system paragraph).
- Risk 3: heading shortened; Annex I's absent-device finding quoted whole; INSAG's
  conditional control-room sentence left to Impact rank 3.
- The shape of it: the design position's reach names the coefficients.
- Change note: stale "No sweep has run" corrected.

Why: the run's risk list did not name the void coefficient in any heading, and two risks
ran past the five-sentence shape; the kit tweak for future runs is pending (kit-tweaks.md).
Pre-review copies: scratch/pre-review-*.md; edit script: scratch/post_review.py (plus the
three follow-up corrections made inline, all in the change note).

## The verification of these changes

A separate Opus verifier checked 32 items: 23 confirmed, 6 narrowed, 3 wrong; its 11
corrections were applied by apply_edits.py --partial (7 to both documents, 4 to the
deliverable's change note only). The three wrong items were the editor's: a line range
(4138-4139 for words on 4139-4140), the chain ids narrowed to five when the document's own
impact rule places all eleven chains at the design position (restored to "X1 to X11"), and
the change note repeating both. The narrowings: the ORM had an observer (SKALA with PRIZMA
computed it), so the heading says it had none against its limit; Annex I's device finding
keeps "in terms of effective manual control rods" and the plant computer path; the change
note's wording aligned. Both documents resolve at 0 bad afterwards (1,430 and 1,356).
