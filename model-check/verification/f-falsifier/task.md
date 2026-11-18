# Task: try to falsify a claim about the model

The model is defined completely in `model-spec.md`. A system is **gap-free at f** if, with
the field `f` set to that value, the result for G1 and the result for G2 (section 4 of the
specification) are both `null`.

## The claim under test

A system is **plain** if `joiner` is null, `substrate` is empty, `switches` is empty, every
monitor has a boundary no other monitor has, `coupling` is true, `window` is 0, `gate` is
true and `slow_reports` is false.

Four predicates on a plain system:

- **Q1 (signal).** Every monitor `m` has at least one monitor other than `m` in
  `hb_readers[m]`.
- **Q3 (state check).** Every process `x`, monitor or work process, has at least one
  monitor other than `x` in `checkers[x]`.
- **Q4 (propagation).** For every two different monitors `a` and `b`, `b` can be reached
  from `a` by following `fwd` edges through monitors.
- **Q8 (halt sources).** Every work process has at least two different monitors in
  `halt_inputs`.

The claim: **every plain system that is gap-free at f = 1 and has at least one work process
satisfies Q1, Q3, Q4 and Q8, except for monitors the system does not depend on.**

"Does not depend on" is made exact as follows. For a plain system S and a monitor `m`, let
S − m be S with `m` deleted from `monitors`, from `boundary`, and from every list and every
key of `hb_readers`, `checkers`, `fwd` and `halt_inputs`. Monitor `m` is **spare** in S if
S − m is also gap-free at f = 1.

So a **falsifier** is a plain system S, gap-free at f = 1, with at least one work process,
in which one of the four predicates fails and the failure cannot be blamed on spare
monitors: after deleting spare monitors one at a time, in any order, for as long as any
monitor is spare, the system that remains still fails one of the four predicates.

## What to do

1. Implement the model from `model-spec.md` in your own code. Do not look for any other
   implementation.
2. Search for falsifiers. Cover at least: every plain system with two monitors and one work
   process, exhaustively; and a large sample (or, if you can make it feasible with symmetry
   reduction, all) of plain systems with three monitors and one work process. Go further
   (two work processes, four monitors) if time allows.
3. For every falsifier you find, or every family of them, describe the system, state which
   predicate fails, and explain in plain words why the system has no violating execution
   anyway.
4. Separately, list which of Q1, Q3, Q4, Q8 you found to hold in every gap-free plain
   system without exception, and which only hold after spare monitors are deleted.
5. If you find no falsifier, say exactly what you covered, so the absence can be weighed.

Nobody has told you what the outcome should be. A falsifier is a useful result.
