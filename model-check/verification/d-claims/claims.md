# Claims to decide

Each claim is about the model in `model-spec.md`, except C7 and C9, which define their own
setting. Decide each one: TRUE or FALSE, with a proof or a counterexample.

## Terms

- A system is **plain** if `joiner` is null, `substrate` is empty, `switches` is empty,
  every monitor has a boundary no other monitor has, `coupling` is true and `window` is 0.
- A monitor `m` **watches** a monitor `z` if `m` is not `z`, `m` is in `checkers[z]` and `m`
  is in `hb_readers[z]`.
- "G1 can be violated" means the result for G1 (section 4 of the specification) is not null.
  "Can be violated in round 1" means the result is 1. The same for G2.

## Claims

**C1.** In every system with at least one monitor and with `f` at least the number of
monitors, G1 can be violated.

**C2.** In every plain system: if some monitor has no checker other than itself, G1 can be
violated in round 1.

**C3.** In every plain system: if there is a non-empty set N of monitors with at most `f`
members such that no monitor outside N is a checker of any member of N, then G1 can be
violated in round 1.

**C4.** In every plain system with `f` = 1 that satisfies all of (a) to (d), neither goal
can be violated.

- (a) Every monitor has a watcher.
- (b) Every work process has at least one checker and at least two halt inputs.
- (c) For every monitor `z`, every monitor `u` other than `z` is a watcher of `z`, or can be
  reached from a watcher of `z` by following `fwd` edges through monitors other than `z`.
- (d) For every work process `x` there is a checker `d` of `x` such that every monitor is
  `d` or can be reached from `d` by following `fwd` edges.

**C5.** In every plain system: if some work process has at most `f` halt inputs, G2 can be
violated in round 1.

**C6.** For `n` >= 1, let the mesh of `n` be the plain system with monitors M1..Mn and one
work process W, in which every monitor watches every other monitor, `fwd[m]` is every other
monitor, `checkers[W]` is every monitor and `halt_inputs[W]` is every monitor. Then neither
goal can be violated in the mesh of `n` if and only if `f` <= `n` - 1.

**C7 (naming the faulty one).** There are `k` >= 2 monitors and at most one of them is
faulty. Every correct monitor outputs the set containing the faulty monitor if there is
one, and the empty set if there is none. A faulty monitor outputs any subset of the other
monitors. A rule maps the `k` outputs to one monitor or to "none". The rule is correct if in
every case it returns the faulty monitor when there is one and "none" when there is none.
Claim: no correct rule exists for `k` = 2, and a correct rule exists for every `k` >= 3.

**C8.** There is a system in which some monitor has an empty `hb_readers` list and yet, with
`f` = 1, neither goal can be violated.

**C9 (growth against a spreading halt).** There are `n` processes, all running. One is bad
and the rest are good. Time passes in ticks, starting at tick 0. In each tick, first the
halt makes `h` hops, then the bad processes spread.

- A hop: let `F` be the number of processes the previous hop halted (`F` = 1 before the
  first hop). The hop halts `min(c * F, number still running)` running processes, taking
  good ones first and bad ones only when no good one is running.
- The spread: every running bad process turns one running good process bad, as far as good
  ones remain. So the number of running bad processes grows by
  `min(running bad, running good)`.

The process ends when no bad process is running. The *damage* is the number of processes
that are bad at the end, halted or not.

- (i) With `c` = 1, for every `n` >= 2 and `h` >= 1, the damage is at least
  `n - h * (ceil(log2 n) + 1)`.
- (ii) With `c` = 2 and `h` = 2, for every `n` >= 4, the damage is at most `2 * sqrt(n)`.
- (iii) With `c` = 2 and `h` = 1, for every `n` >= 8 that is a power of two, the damage is
  between `n / 8` and `n / 2`.
