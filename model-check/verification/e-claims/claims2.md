# Claims to decide, second set

Each claim is about the model in `model-spec.md`. Decide each one: TRUE or FALSE, with a
proof or a counterexample. "The result for G1 is at most 2" means the result defined in
section 4 of the specification is 1 or 2, and so on.

**E1.** In every system that has at least one monitor, and in which every monitor has the
same boundary, the result for G1 is at most 2.

**E2.** In every system with `window` = 1, `gate` true and at least one work process, the
result for G2 is 1.

**E3.** In every system with `gate` false and at least one work process, the result for G2
is 1.

**E4.** Call a system *slow-plain* if `joiner` is null, `substrate` is empty, `switches` is
empty, every monitor has a boundary no other monitor has, `coupling` is true, `window` is
0, `gate` is true and `slow_reports` is true. In a slow-plain system, let `x` be a work
process. Let `d` be the least number of `fwd` edges on a path that starts at a monitor in
`checkers[x]` and ends at a monitor in `halt_inputs[x]`; `d` is 0 if some monitor is in
both lists, and `d` is undefined if there is no such path. Consider the execution in which
the environment takes exactly one step in total: `mutate x`, in round 1.

- (i) If `d` is defined, then `x` takes a work step in each of rounds 1 to `d`, and takes
  no work step in round `d + 1` or any later round.
- (ii) If `d` is undefined, `x` takes a work step in every round of that execution.

**E5.** In every system (with `gate` true, `window` 0, `slow_reports` false) and every
`f` >= 1: if some work process `w` has a non-empty `halt_inputs` list and no monitor in
`checkers[w]`, then the result for G2 is 1.

**E6 (lifting a halt).** This claim defines its own setting and does not use the
specification.

There are members 1, 2 and 3, and under rule C also a coordinator K. There is one fault,
which is present or gone. Each member either holds a halt or does not. Member 1 may be
*lost*; once lost it takes no more steps and its halt no longer counts. A halt *counts* if
its holder is not lost. The system *runs* when no halt counts.

A member's own checks are *clean* as follows: member 1 and K are clean exactly when the
fault is gone; members 2 and 3 are always clean (they cannot see the fault).

Start: the fault is present, every member holds a halt, member 1 is not lost.

Environment steps: `repair` (enabled while the fault is present; the fault is gone
afterwards and never returns) and `lose member 1` (enabled while member 1 is not lost).

Member steps, for any member that is not lost, under one of three rules:

- Rule A. A member that holds a halt may lift it when its own checks are clean.
- Rule B. A member that holds a halt may lift it when its own checks are clean and no
  other member's halt counts. A member that holds no halt may raise one when some other
  member's halt counts.
- Rule C. K, if it holds a halt, may lift it when its own checks are clean. Member 1, 2 or
  3, if it holds a halt, may lift it when its own checks are clean and K holds no halt.
  Member 1, 2 or 3, if it holds no halt, may raise one when K holds a halt.

Steps may happen in any order. Two properties:

- *Safety:* no reachable state has the fault present and the system running.
- *Recovery:* from every reachable state in which the fault is gone, some state in which
  the system runs is reachable.

Claim: under rule A, safety fails. Under rule B, safety holds and recovery fails. Under
rule C, both hold.
