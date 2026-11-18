# Addendum to model-spec.md

Two optional fields are added to a system. Everything else in `model-spec.md` is unchanged,
and a system that has neither field behaves exactly as before.

## `gate` (boolean; true when the field is missing)

When `gate` is false, the three phases of a round run in the order environment, work,
monitor.

- The work phase (section 3.3) then uses, as `out`, the set of monitors that are in
  `flagged`, in `alive` and not in `bad` in the state reached after the environment phase.
  So only flags raised in earlier rounds count.
- The monitor phase (section 3.2) follows and is unchanged.
- G2 is judged as before: `bad` is not empty and at least one process took a work step in
  the round's work phase.
- G1 is judged with `out` as computed at the end of the round's monitor phase.

## `slow_reports` (boolean; false when the field is missing)

When `slow_reports` is true, step 2 of the monitor phase (propagation) is replaced by this
single pass: for every monitor `m` that was in `flagged` at the start of the round and is
in `active`, add to `flagged` every `r` in `fwd[m]` that is in `active`.

There is no repetition. A flag makes at most one hop per round, and a monitor that first
detects in this round passes its flag on in the next round at the earliest.
