# Verdicts on claims C1 to C9

Prover's result for `claims.md` against `model-spec.md`. Section numbers (§) refer to
`model-spec.md`.

## Summary

| Claim | Verdict | Note |
|---|---|---|
| C1 | TRUE | mutate every monitor in round 1 |
| C2 | TRUE | special case of C3 with N = {z} |
| C3 | TRUE | mutate every member of N in round 1 |
| C4 | TRUE, reading "two halt inputs" as two different monitors | FALSE if a name repeated in a `halt_inputs` list counts twice; counterexample given |
| C5 | TRUE | mutate the halt inputs (or the work process itself if it has none) |
| C6 | TRUE | both directions proved |
| C7 | TRUE | clash for k = 2; "named by at least two" rule for k >= 3 |
| C8 | TRUE | three-monitor witness, fully enumerated |
| C9 (i) | TRUE | sharper: damage >= n - h * ceil(log2 n) |
| C9 (ii) | TRUE, reading F as carried from tick to tick | sharper: damage <= max(1, sqrt(n/2)); FALSE if F restarts at 1 each tick |
| C9 (iii) | TRUE, same reading of F | damage is exactly n/4; FALSE if F restarts at 1 each tick |

No claim is refuted under its natural reading. Two readings matter: the count of halt
inputs in C4 (b), and whether F carries across ticks in C9.

## Standing assumptions and facts used below

**Well-formed systems.** I assume what the type column of §1 says: the names in `monitors`
and `works` are pairwise different, the joiner is none of them, and every list typed "list
of monitors" holds only monitor names. A list may or may not repeat a name; where that
matters (C4) I say so.

**F0.** The initial state is not responded, because `flagged` is empty (§2, §3.5). So
round 1 can always start, and a goal violated in round 1 has result 1, the least possible
(§4).

**F1.** `mutate p` is enabled for every present process `p` not in `bad`, whatever its
`alive` or `off` status (§3.1). Monitors and work processes are present from the start
(§1). A mutated monitor stays in `alive`.

**F2.** A monitor in `bad` is not in `active` and not in `out` (§3.2).

**F3.** `flagged` grows only by detection, or by propagation from a monitor that is already
in `flagged` (§3.2). So if `flagged` is empty before a monitor phase and no active monitor
detects in it, then `out` is empty after it.

**F4 (plain systems).** In a plain system the only steps that are ever enabled are `stop m`
and `mutate p`:
`stop-boundary b` needs two monitors with the same boundary, and no two monitors share one;
`fail-substrate s` needs a present process with substrate `s`, and `substrate` is empty;
`disable m` needs `m` in `switches`, which is empty; `join` needs a joiner (§3.1).
Hence in every reachable state `hidden` and `off` are empty, `joined` is false, `visible`
equals `bad`, and the present non-monitor processes are exactly the work processes. Because
`window` is 0, nothing is ever added to `pending` (§3.3).

---

## C1. TRUE

*In every system with at least one monitor and with `f` at least the number of monitors, G1
can be violated.*

Proof. Let the monitors be `m_1 .. m_k`, with `1 <= k <= f`.

1. Round 1 starts from the initial state (F0).
2. The environment applies `mutate m_1`, ..., `mutate m_k`. That is `k <= f` steps, allowed
   by §3.1. Each is enabled when applied: `m_i` is present and not yet in `bad` (F1).
3. Now every monitor is in `bad`, so `bad` is not empty (`k >= 1`).
4. Monitor phase: `active` is empty, since it excludes monitors in `bad`. Whatever
   `flagged` holds, `out` excludes monitors in `bad` (§3.2 step 3), and every monitor is in
   `bad`, so `out` is empty.
5. `bad` not empty and `out` empty: G1 is violated in round 1 (§3.4). The result for G1 is
   1, so it is not null.

The proof uses no other field of the system, so it holds for systems with a joiner,
substrates, shared boundaries, switches, either `coupling`, either `window`, and with or
without work processes. If `f` is larger than `k` the environment simply uses fewer steps
than it may.

Test: 3,033 random systems (not only plain) with `f` >= number of monitors >= 1; every one
had G1 = 1.

## C2. TRUE

*In every plain system: if some monitor has no checker other than itself, G1 can be
violated in round 1.*

Proof. Let `z` be such a monitor: `checkers[z]` is empty, missing, or holds only `z`.

1. Round 1, from the initial state (F0). The environment applies the single step
   `mutate z` (enabled by F1; one step is allowed because `f >= 1`, §1).
2. `bad = {z}`, `hidden` is empty, so `visible = {z}`. Every monitor is still in `alive`.
3. `active` is every monitor except `z` (F2).
4. Detection (§3.2 step 1) for a monitor `m` in `active`: the first condition needs
   `m` in `checkers[z]`, but `m` is not `z` and `z` has no other checker; the second needs
   a monitor not in `alive`, and there is none. So nobody detects.
5. `flagged` was empty and stays empty (F3), so `out` is empty.
6. `bad` is not empty and `out` is empty: G1 is violated in round 1 (§3.4). Result 1.

Edge cases: an empty or missing `checkers[z]`; `z` in its own list (the monitor that
checks itself is in `bad`, so it is not in `active` and cannot detect); `z` the only
monitor; `f` larger than 1. The word "plain" is not needed by the proof. C2 is also C3
with N = {z}.

Test: 2,781 random plain systems with such a monitor (lists with self entries, repeats and
missing keys included); every one had G1 = 1.

## C3. TRUE

*In every plain system: if there is a non-empty set N of monitors with at most `f` members
such that no monitor outside N is a checker of any member of N, then G1 can be violated in
round 1.*

Proof. Let `N = {z_1 .. z_j}`, `1 <= j <= f`.

1. Round 1 (F0). The environment applies `mutate z_1`, ..., `mutate z_j`: `j <= f` steps,
   each enabled (F1).
2. `bad = N`, not empty. `hidden` is empty, so `visible = N`. Every monitor is in `alive`.
3. `active` is the set of monitors outside N (F2).
4. Detection for `m` in `active`: the first condition needs some `x` in N with `m` in
   `checkers[x]`; `m` is outside N, and no monitor outside N checks a member of N. The
   second condition needs a monitor not in `alive`; there is none. Nobody detects.
5. `flagged` stays empty (F3), `out` is empty, `bad` is not: G1 is violated in round 1.

Edge cases: N is every monitor (then `active` is empty, and step 4 is vacuous); members of
N that check themselves or each other (they are in `bad`, hence not active); empty or
missing `checkers` lists; `f` larger than the size of N (fewer steps are used). "Plain" is
not needed.

Test: 4,474 random plain systems in which such an N exists (in 2,366 of them the least N
is every monitor); every one had G1 = 1.

## C4. TRUE, reading "at least two halt inputs" as two different monitors

*In every plain system with `f` = 1 that satisfies (a) to (d), neither goal can be
violated.*

**Reading.** I read (b) as: `halt_inputs[w]` names at least two different monitors. If a
list such as `["A", "A"]` is counted as two halt inputs, the claim is false; the
counterexample is at the end of this section. Stated as an assumption: C4 is true only if
the two halt inputs required by (b) are two different monitors.

Proof. By F4 the only steps are `stop m` and `mutate p`; `hidden`, `off` and `pending`
stay empty; with `f` = 1 a round has zero steps or one step.

**Lemma 1 (idle round).** From the initial state, a round with zero steps violates no goal
and ends in the initial state.
`bad` is empty, so neither goal is violated (§3.4 needs `bad` not empty for both).
`visible` is empty and every monitor is alive, so nobody detects; `flagged` and `out` stay
empty. In the work phase `sees` is false for every work process (no monitor in `out`, none
outside `alive`), so each takes a work step and no state component changes.

**Lemma 2 (one step).** From the initial state, a round with exactly one step violates no
goal and ends in a responded state. There are three cases.

*Case S: `stop z`, `z` a monitor.* `bad` is empty, so neither goal is violated in this
round. `active` is every monitor except `z`. By (a) `z` has a watcher; every watcher `m`
of `z` is not `z`, is active, and is in `hb_readers[z]`, and `z` is not in `alive`, so `m`
detects and is flagged. By (c) every monitor `u` other than `z` is a watcher of `z` or is
the end of a `fwd` path that starts at a watcher and passes only through monitors other
than `z`; all of those are active, so propagation (§3.2 step 2) flags each monitor on the
path in turn, by induction on its position in the path. So `flagged` is every monitor
except `z`, all alive and none in `bad`, and `out` is that set; it is not empty because
`z` has a watcher. Work phase: by (b) each work process `w` has two different halt inputs,
so one of them is not `z` and is in `out`; `sees` is true, `window` is 0, `w` halts. Every
work process is halted and `out` is not empty: the state is responded (§3.5).

*Case M: `mutate z`, `z` a monitor.* `bad = visible = {z}`; every monitor is alive;
`active` is every monitor except `z` (F2). Every watcher of `z` is active and is in
`checkers[z]`, so it detects. Propagation is exactly as in case S. `out` is every monitor
except `z`, not empty, so G1 is not violated. As in case S every work process halts without
a work step, so no process takes a work step and G2 is not violated. The state is
responded.

*Case X: `mutate x`, `x` a work process.* `bad = visible = {x}`; every monitor is active.
By (d) there is a checker `d` of `x` from which every other monitor can be reached along
`fwd` edges. `d` detects; propagation flags every monitor (all are active). `out` is every
monitor, not empty (`d` exists), so G1 is not violated. Every work process has at least
one halt input by (b), and it is in `out`, so every work process halts without a work
step: G2 is not violated. The state is responded.

**Conclusion.** No round starts from a responded state (§3.5, §4). By the two lemmas and
induction on the number of rounds, every execution is a run of idle rounds from the
initial state, optionally followed by one round with one step, after which no round can
follow. No round of either kind violates G1 or G2. Both results are null.

Edge cases checked.
- No monitor at all: (b) requires a checker, which is a monitor, so there is no work
  process either; the system has no process, no step is ever enabled, `bad` stays empty.
- No work process: (b) and (d) are vacuous, case X does not arise, and the second half of
  "responded" is vacuous; cases S and M go through unchanged.
- Exactly one monitor: excluded by (a), since a watcher is a different monitor.
- Self entries (`z` in its own `checkers`, `hb_readers` or `fwd` list): harmless, `z` is
  not active in cases S and M.
- `f` = 1 is used: it is what makes the state after the first step responded. With `f` = 2
  the claim fails (the mesh of 2 satisfies (a) to (d), see C6).

Tests: 24,552 random plain `f` = 1 systems satisfying (a) to (d) (10,930 with no work
process, 3,489 with no process at all), all null/null. Exhaustive over every plain system
with 2 monitors and 0 or 1 work process (self entries allowed), 2 monitors and 2 work
processes, and 3 monitors and 0 or 1 work process (no self entries): 102,473 systems
satisfy (a) to (d), all null/null.

**Counterexample under the other reading** (a repeated name counts as two halt inputs):

```json
{"name": "c4-repeated-entry", "f": 1,
 "monitors": ["A", "B"], "works": ["W"], "joiner": null,
 "boundary": {"A": "ba", "B": "bb"}, "substrate": {},
 "hb_readers": {"A": ["B"], "B": ["A"]},
 "checkers": {"A": ["B"], "B": ["A"], "W": ["A"]},
 "fwd": {"A": ["B"], "B": ["A"]},
 "halt_inputs": {"W": ["A", "A"]},
 "switches": [], "coupling": true, "window": 0}
```

It is plain with `f` = 1. (a): B watches A and A watches B. (b): W has checker A and a
`halt_inputs` list of length two. (c): the only other monitor is always a watcher. (d):
`d` = A, and B is reached by `fwd[A]`.
Execution: round 1, step `mutate A`. `bad = {A}`; B is active and in `checkers[A]`, so B
is flagged; `out = {B}`. W's halt inputs name only A, which is not in `out` (it is in
`bad`) and is in `alive`, so `sees` is false and W takes a work step with `bad` not empty:
G2 is violated in round 1. The state is not responded (W is not halted); round 2, step
`stop B`: `out` is empty and `bad = {A}`: G1 is violated in round 2. My implementation
returns G1 = 2, G2 = 1 for this system.

## C5. TRUE

*In every plain system: if some work process has at most `f` halt inputs, G2 can be
violated in round 1.*

Proof. Let `w` be such a work process and `H` the set of monitors named in
`halt_inputs[w]`; `H` has at most `f` members (a set is no larger than the list).

*Case `H` not empty.* Round 1 (F0): the environment applies `mutate m` for every `m` in
`H`: at most `f` steps, each enabled (F1). Then `bad = H`, not empty. Every monitor in `H`
is in `bad`, hence not in `out` (F2), and is still in `alive`, so the coupling clause of
§3.3 is false too. `sees` is false for `w`. `w` is present, not halted and not pending, so
it takes a work step. `bad` is not empty and a process took a work step: G2 is violated in
round 1 (§3.4).

*Case `H` empty* (the list is empty or the key is missing). The environment applies
`mutate w` (one step, `f >= 1`). `bad = {w}`. `sees` is false because there is no halt
input. `w` takes a work step (§3.3 does not exempt a process in `bad`). G2 is violated in
round 1.

The result for G2 is 1 in both cases. Edge cases: the empty list; `f` larger than the size
of `H`; a list that repeats a name (true under either way of counting); the environment
mutates rather than stops the halt inputs, which is what keeps `coupling` from halting
`w`. "Plain" is not needed.

Test: 4,189 random plain systems with such a work process (2,193 with an empty list);
every one had G2 = 1.

## C6. TRUE

*Neither goal can be violated in the mesh of `n` if and only if `f` <= `n` - 1.*

**Reading.** The mesh fixes everything but `f`; the claim is for every `n >= 1` and every
`f >= 1`. "Every monitor watches every other" fixes `checkers[Mi]` and `hb_readers[Mi]` up
to whether `Mi` is in its own lists; that does not matter (a monitor that is stopped or in
`bad` is not active), and I tested both.

*Only if* (if `f >= n`, a goal can be violated). The mesh has `n >= 1` monitors and
`f >= n`, so by C1 G1 can be violated.

*If* (if `f <= n - 1`, neither goal can be violated). Since `f >= 1` this needs `n >= 2`.
By F4 the steps are `stop m` and `mutate p`, and `hidden`, `off`, `pending` stay empty.

- A round with zero steps from the initial state: `bad` is empty, no goal is violated,
  nobody detects, W takes a work step, the state is unchanged (as Lemma 1 of C4).
- A round with `k` steps from the initial state, `1 <= k <= f <= n - 1`. Each step stops
  or mutates one process, so at most `n - 1` monitors are stopped or in `bad`; the others
  form `active`, which is therefore not empty. Each step changes the state, so afterwards
  some monitor is not alive or some process is in `bad`. Take any `m` in `active`:
  - if some monitor `p` was stopped, `p` is not `m`, `m` watches `p`, so `m` is in
    `hb_readers[p]` and detects;
  - otherwise some process `x` is in `bad` (and visible): if `x` is a monitor it is not
    `m`, and `m` is in `checkers[x]`; if `x` is W, `m` is in `checkers[W]`; `m` detects.

  So every active monitor is flagged and `out` equals `active`, not empty: G1 is not
  violated. `halt_inputs[W]` is every monitor, so it contains a monitor in `out`; `sees`
  is true, `window` is 0, W halts without a work step: G2 is not violated. The state is
  responded (§3.5).

So every execution is idle rounds followed by at most one round with steps, after which no
round follows; none violates a goal. Both results are null.

Edge case `n` = 1: `f <= 0` is impossible, and with any `f >= 1` the step `mutate M1`
gives `bad = {M1}`, `out` empty, so both sides of the equivalence are false.

Test: meshes `n` = 1..5 with `f` = 1..7, with and without self entries: null/null exactly
when `f <= n - 1`, and G1 = G2 = 1 otherwise.

## C7. TRUE

*No correct rule exists for `k` = 2, and a correct rule exists for every `k` >= 3.*

**Reading.** "The set containing the faulty monitor" is the one-element set `{j}`. The
cases are: no monitor faulty (every output is the empty set); or monitor `j` faulty with
output `S`, any subset of the others (every other output is `{j}`). A rule is a function
of the outputs, so a correct rule exists exactly when no profile of outputs arises in two
cases that demand different answers.

*`k` = 2, monitors 1 and 2.* Case "1 faulty, outputs {2}": monitor 1 outputs {2}, monitor
2 outputs {1}. Case "2 faulty, outputs {1}": monitor 1 outputs {2}, monitor 2 outputs {1}.
The two profiles are identical, and the rule must return 1 in the first and 2 in the
second. No correct rule exists. (This holds whether or not the rule knows which monitor
sent which output.)

*`k` >= 3.* Rule R: for each monitor `i` let `c_i` be the number of outputs that contain
`i`; if exactly one monitor has `c_i >= 2` return it, otherwise return "none".
- No monitor faulty: every output is empty, every `c_i` is 0, R returns "none".
- `j` faulty with output `S`: the `k - 1 >= 2` correct monitors each output `{j}`, and `S`
  does not contain `j`, so `c_j = k - 1 >= 2`. For `i` other than `j`, only `j`'s output
  can contain `i`, so `c_i <= 1`. Exactly one monitor has count at least 2, namely `j`,
  and R returns `j`.

R is correct. It uses only the counts, so it also works if the outputs are not labelled by
sender. Edge cases: the faulty monitor outputs the empty set, or names every other
monitor.

Other reading: if a correct monitor could output any set that merely contains the faulty
monitor, no rule would exist for any `k` (the profile in which every monitor outputs all
the others arises with each monitor as the faulty one). The claim's wording ("the set",
paired with "the empty set") does not support that reading.

Test: exhaustive over all cases for `k` = 2..7: a consistent rule exists for `k` = 3..7
and not for `k` = 2, labelled or unlabelled; R is correct on every case for `k` = 3..7.

## C8. TRUE

*There is a system in which some monitor has an empty `hb_readers` list and yet, with
`f` = 1, neither goal can be violated.*

Witness (monitor A has an empty `hb_readers` list):

```json
{"name": "c8-no-work", "f": 1,
 "monitors": ["A", "B", "C"], "works": [], "joiner": null,
 "boundary": {"A": "ba", "B": "bb", "C": "bc"}, "substrate": {},
 "hb_readers": {"A": [], "B": ["A", "C"], "C": ["A", "B"]},
 "checkers": {"A": ["B", "C"], "B": ["A", "C"], "C": ["A", "B"]},
 "fwd": {}, "halt_inputs": {}, "switches": [], "coupling": true, "window": 0}
```

Proof by complete enumeration. The system is plain, so the steps are `stop` and `mutate`
(F4), one or none per round. There is no non-monitor process, so no process ever takes a
work step and G2 can never be violated; a state is responded as soon as `out` is not
empty.

From the initial state I:

| Step | Who detects | `bad` | `out` | G1 violated | Next state |
|---|---|---|---|---|---|
| none | nobody | empty | empty | no (`bad` empty) | I |
| `stop A` | nobody (no reader of A) | empty | empty | no (`bad` empty) | S1 |
| `stop B` | A, C (in `hb_readers[B]`) | empty | {A, C} | no | responded |
| `stop C` | A, B (in `hb_readers[C]`) | empty | {A, B} | no | responded |
| `mutate A` | B, C (in `checkers[A]`) | {A} | {B, C} | no | responded |
| `mutate B` | A, C (in `checkers[B]`) | {B} | {A, C} | no | responded |
| `mutate C` | A, B (in `checkers[C]`) | {C} | {A, B} | no | responded |

S1 is the initial state with A removed from `alive`; it is not responded because `flagged`
is empty. From S1 (`active` is {B, C} unless the step changes it):

| Step | Who detects | `bad` | `out` | G1 violated | Next state |
|---|---|---|---|---|---|
| none | nobody | empty | empty | no (`bad` empty) | S1 |
| `stop B` | C (in `hb_readers[B]`) | empty | {C} | no | responded |
| `stop C` | B (in `hb_readers[C]`) | empty | {B} | no | responded |
| `mutate A` | B, C (in `checkers[A]`) | {A} | {B, C} | no | responded |
| `mutate B` | C (in `checkers[B]`) | {B} | {C} | no | responded |
| `mutate C` | B (in `checkers[C]`) | {C} | {B} | no | responded |

The only states from which a round can start are I and S1, and no round from either
violates a goal. Both results are null. My implementation prints the same two tables and
returns null/null.

A second witness with a work process: add `"works": ["W"]`, `"checkers": {..., "W": ["A",
"B", "C"]}` and `"halt_inputs": {"W": ["A", "B", "C"]}` to the system above. It also
returns null/null, with `coupling` true (W halts in the round A is stopped) and with
`coupling` false (W keeps working after `stop A` while `bad` is empty, and halts in the
round of the next step because B or C is in `out`).

Aside: three monitors are needed. With two monitors A and B and no reader of A, the
execution `stop A` then `mutate B` violates G1 in round 2 (checked).

## C9. Growth against a spreading halt

**Reading.** F is carried from each hop to the next, across tick boundaries ("the previous
hop"; "F = 1 before the first hop" speaks of the one first hop). Notation: `g` running
good, `b` running bad, `B` all bad (running or halted); initially `g = n - 1`, `b = B = 1`.

Common facts.

- **P1.** A hop halts a bad process only at a moment when `g = 0`, and `g` never grows. So
  once any bad process has been halted, `g = 0` for good and no spread changes anything.
- **P2.** The process ends, and `damage = n - (number of good processes halted)`. While
  `b >= 1` something is running; F starts at 1 and each hop sets it to
  `min(c * F, running) >= 1`, so each hop halts at least one process and the running count
  falls until `b = 0`. `b` starts at 1 and falls only when a bad process is halted, so at
  the end `g = 0` by P1. Every process is then bad or a halted good one.
- **P3 (doubling).** If `g > 0` at the start of tick `t`, then at that moment no bad
  process has been halted and `b = B = 2^t`. Induction on `t`: true for `t = 0`. If
  `g > 0` at the start of tick `t + 1`, then `g > 0` throughout tick `t`, so by P1 no bad
  process was halted in it, and the spread of tick `t` left good processes over, which
  means it added `min(b, g) = b`; so `b` doubled.
- **P4.** If `g > 0` at the start of tick `t` then `2^t = b < b + g <= n`, so
  `t < log2 n`, that is `t <= ceil(log2 n) - 1`.

### (i) TRUE

With `c` = 1, F is 1 at every hop while anything runs, so each hop halts at most one
process. A good process can be halted only in a tick that starts with `g > 0`; by P4 there
are at most `ceil(log2 n)` such ticks, each with `h` hops. So at most `h * ceil(log2 n)`
good processes are halted, and by P2

`damage >= n - h * ceil(log2 n) >= n - h * (ceil(log2 n) + 1)`.

Edge cases: `n` = 2 (damage 1, bound 0); `h` so large that every good process is halted
in tick 0 (damage 1, bound negative).

Test: `n` = 2..4000 with `h` = 1..40 and `h` in {n - 1, n, 10n}: holds, and the sharper
bound without the "+ 1" holds too; least slack against the claimed bound is 1, at `n` = 2,
`h` = 1.

### (ii) TRUE

With `c` = 2, number the hops from 1 over all ticks. By induction on `j`: if no hop before
hop `j` halted everything that was running, then F is `2^(j-1)` at hop `j`, and hop `j`
halts `2^j` processes if at least that many are running, and otherwise everything that is
running.

If no spread ever turns a good process bad, the damage is 1, which is at most
`2 * sqrt(n)`. Otherwise let `T` be the last tick whose spread turns at least one. With
`h` = 2, hops 1 to `2T + 2` have been made before that spread. None of them halted
everything running, and none halted a bad process (by P1, either would leave `g = 0`
before the spread), so hop `j` halted exactly `2^j` and together they halted
`2 + 4 + ... + 2^(2T+2) = 2^(2T+3) - 2` processes, all good. By P3 `b = 2^T` at the start of tick `T`. At least one good process is still running
at the spread. So

`n >= (2^(2T+3) - 2) + 2^T + 1 >= 2^(2T+3)`.

The spread at most doubles `B`, and no later spread changes it, so
`damage <= 2^(T+1) = sqrt(2^(2T+3) / 2) <= sqrt(n / 2) < 2 * sqrt(n)`.

Test: every `n` from 4 to 300,000 and `n = 2^m + 7` for `m` = 19..60: holds; the largest
value of `damage / sqrt(n)` is 0.7071, at `n` = 8 (damage 2), matching `sqrt(n / 2)`.

### (iii) TRUE: the damage is exactly n / 4

Let `n = 2^m`, `m >= 3`, `c` = 2, `h` = 1. Invariant, for `0 <= t <= m - 2`, at the start
of tick `t`: `b = B = 2^t`, `F = 2^t`, `2^(t+1) - 2` good processes halted, no bad process
halted, so `g = 2^m - 3 * 2^t + 2`.

- `t = 0`: `b = 1`, `F = 1`, nothing halted, `g = 2^m - 1`. Holds.
- Step, for `t <= m - 3`: then `2^m >= 8 * 2^t`, so `g >= 5 * 2^t + 2 >= 2^(t+1)`. The hop
  halts `2^(t+1)` processes, all good, and F becomes `2^(t+1)`. Now
  `g = 2^m - 5 * 2^t + 2 >= 3 * 2^t + 2 > b`, so the spread adds `2^t`: `b = B = 2^(t+1)`,
  `g = 2^m - 3 * 2^(t+1) + 2`, and `2^(t+2) - 2` good processes are halted. Holds for
  `t + 1`.

At the start of tick `m - 2`: `b = B = 2^(m-2)`, `F = 2^(m-2)`, `g = 2^(m-2) + 2`. The
hop halts `min(2^(m-1), 2^(m-1) + 2) = 2^(m-1)` processes, good ones first; since
`g = 2^(m-2) + 2 <= 2^(m-1)` (true for `m >= 3`), every good process is halted. No spread
can change `B` after that. Damage `= 2^(m-2) = n / 4`, which lies between `n / 8` and
`n / 2`, strictly, so it does not matter whether "between" includes the ends.

Test: `n = 2^3 .. 2^60`: damage equals `n / 4` in every case.

### The other reading of F

If F restarted at 1 in every tick, each tick would halt a fixed number of processes
(6 for (ii), 2 for (iii)) and the bad set would outgrow the halt:
- (ii) would be FALSE: `n` = 37 gives ticks `g`: 36 -> 30, spread to `b` = 2; 29 -> 23,
  `b` = 4; 21 -> 15, `b` = 8; 11 -> 5, `b` = 13. Damage 13 > `2 * sqrt(37)` = 12.17.
- (iii) would be FALSE: `n` = 32 gives damage 22 > 16.
- (i) is unchanged (with `c` = 1, F is always 1).

I do not adopt this reading; the text defines F from "the previous hop" and gives the
starting value once.

---

## How the tests were run

All with `python -I`, standard library only, in this folder.

- `model.py`: my own implementation of §1 to §4 (all six environment steps, the three
  phases, the responded rule, breadth-first exploration of every reachable state).
- `test_claims.py`: random tests for C1, C2, C3, C4, C5; the meshes for C6; the witnesses
  for C8; the repeated-entry search for C4.
- `test_c4_exhaustive.py`: every small plain system for C4.
- `test_c7_c9.py`: exhaustive case check for C7; simulation for C9 under both readings
  of F.
- `show_cases.py`: prints the full exploration of the C8 witnesses and the trace of the
  C4 repeated-entry system.

The tests are evidence only; each verdict rests on the argument given with it.
