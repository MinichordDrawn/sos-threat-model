# Verdicts on claims E1 to E6

Specification: `model-spec.md`, cited below as §1 to §5. Claims: `claims2.md`.
Everything here was derived from those two files only. Programs are in this folder and run
with `python -I` (standard library only); what each one printed is quoted in the evidence
paragraphs. A test is cited as evidence only; each TRUE verdict rests on the proof.

## Summary

| Claim | Verdict | What the verdict depends on |
|---|---|---|
| E1 | TRUE | Read as: one boundary id is assigned to every monitor. If "the same boundary" is stretched to cover "no monitor has a boundary", it is false (counterexample in E1). |
| E2 | TRUE | Read as: `works` is non-empty. If the joiner is counted as a work process (the table in §1 calls it one), TRUE ONLY IF `works` is non-empty or `f` >= 2. |
| E3 | TRUE | Same dependency as E2. |
| E4 (i) | TRUE | No dependency. |
| E4 (ii) | TRUE | No dependency. |
| E5 | TRUE | Read as: `w` is in `works`. If `w` may be the joiner, TRUE ONLY IF `w` is in `works` or `f` >= 2. |
| E6 | TRUE | Read as: K is a member, so it holds a halt at the start. If K starts without a halt, safety fails under rule C. |

## Conventions and facts used throughout

`M` is the list `monitors`, `W` is the list `works`.

Well-formed systems are assumed: the names in `monitors`, `works` and `joiner` are pairwise
distinct, and every list that §1 types as "list of monitors" contains only names from
`monitors`. The specification does not say what a system outside these types means.

- **F1** (§2, §3.5). In the initial state `flagged` is empty, so the initial state is not
  responded and round 1 may start. More generally, a state in which no monitor is in
  `flagged`, in `alive` and not in `bad` is not responded.
- **F2** (§1, §3.1). `f` >= 1, so an environment phase consisting of exactly one enabled
  step is always allowed (`k` = 1 <= `f`).
- **F3** (§2, §3.2, §3.3). Nothing leaves `bad`; nothing returns to `alive`. The monitor
  phase changes only `flagged`; the work phase changes only `halted` and `pending`. So
  `alive`, `bad`, `hidden`, `off` are, for the rest of a round, what the environment phase
  left.
- **F4** (§4). The result for a goal is the least `n` for which some execution of `n` rounds
  violates the goal in round `n`. So exhibiting such an execution proves "result <= n", and
  the result, when not `null`, is at least 1.

---

## E1. TRUE

> In every system that has at least one monitor, and in which every monitor has the same
> boundary, the result for G1 is at most 2.

**Reading.** There is a boundary id `b` with `boundary[m] = b` for every monitor `m`. (§1: a
monitor missing from `boundary` "has none", so such a monitor does not "have the same
boundary" as anything.)

**Proof.** Let the system satisfy the hypothesis. Two cases.

*Case 1: exactly one monitor `m`.* `stop-boundary b` is never enabled (§3.1 needs at least
two monitors with boundary `b`), so the argument cannot use it. Take the one-round execution
whose environment phase is the single step `mutate m`.
1. Round 1 may start (F1) and one step is allowed (F2).
2. `mutate m` is enabled: `m` is a present process (§1: monitors are present) and `bad` is
   empty (§2). After it `bad = {m}`.
3. `out` is a set of monitors not in `bad` (§3.2 step 3). The only monitor is in `bad`, so
   `out` is empty at the end of the monitor phase, in either phase order (§3.6).
4. `bad` is not empty and `out` is empty: G1 is violated in round 1 (§3.4). The result is 1.

*Case 2: at least two monitors.* Take the two-round execution: round 1 environment phase
`stop-boundary b`; round 2 environment phase `mutate m` for any monitor `m`.
1. Round 1 may start (F1). `stop-boundary b` is enabled: at least two monitors have boundary
   `b` and all of them are in `alive` (§2). Its effect removes every monitor from `alive`.
2. In round 1's monitor phase `active` is empty (§3.2: `active` needs `alive`). Detection
   adds only monitors in `active`; propagation, in the normal and in the slow-reports form
   (§3.6), adds only monitors in `active`. So `flagged` stays empty. This holds whether the
   monitor phase runs before or after the work phase (§3.6), because the work phase does not
   change `flagged` (F3).
3. `bad` is empty in round 1, so nothing is claimed about round 1. After round 1 `flagged`
   is empty, so the state is not responded (F1) and round 2 may start, whatever the work
   processes did.
4. In round 2, `mutate m` is enabled: `m` is present and `bad` is empty; §3.1 says the
   target may be "in `alive` or not". After it `bad = {m}`.
5. No monitor is in `alive` (F3: nothing returns), so `out` is empty at the end of round 2's
   monitor phase (§3.2 step 3; for `gate` false, §3.6 judges G1 with that same `out`).
6. G1 is violated in round 2 (§3.4). By F4 the result is at most 2, and it is not `null`,
   so it is 1 or 2.

**Edge cases checked.**
- One monitor: Case 1; the result is exactly 1.
- `f` > 1 with two or more monitors: `stop-boundary b` then `mutate m` fit in round 1, so the
  result is 1. Still "at most 2".
- `works` empty, a joiner, substrates, switches, `window`, `coupling`: not used by the proof.
- `gate` false and `slow_reports` true: covered in steps 2 and 5.
- The bound is tight: for the three-monitor full mesh in `check_cases.py` (`f` = 1, every
  monitor in boundary `b`) the program returns G1 = 2, by exactly the execution above.

**Other reading.** If "every monitor has the same boundary" is taken to hold also when no
monitor has a boundary at all, the claim is false. Counterexample:

```json
{"name": "E1 other reading", "f": 1, "monitors": ["m1", "m2"], "works": [], "joiner": null,
 "boundary": {}, "substrate": {},
 "hb_readers": {"m1": ["m2"], "m2": ["m1"]},
 "checkers": {"m1": ["m2"], "m2": ["m1"]},
 "fwd": {}, "halt_inputs": {}, "switches": [], "coupling": true, "window": 0}
```

With `f` = 1 the only environment phases from the initial state are: no step; `stop m1`;
`stop m2`; `mutate m1`; `mutate m2` (no boundary group, substrate, switch or joiner exists).
Taking no step leaves the state unchanged, with `bad` empty. `stop m1` leaves `bad` empty; `m2`
reads `m1`'s liveness, flags, and the state is responded (no non-monitor process exists).
`mutate m1` gives `bad = {m1}`; `m2` checks `m1`, flags, `out = {m2}`, no violation, and the
state is responded. The other two are symmetric. So the only non-responded reachable state
is the initial one and no round from it violates G1: the result is `null`. `model.result`
returns `{"G1": null, "G2": null}` for it.

**Evidence.** `test_bounded.py 2500`: 2,500 random systems with 1 to 4 monitors in one
boundary, 0 failures. `test_e1_dense.py 3000`: 3,000 well-monitored systems with `f` = 1,
full exploration, 0 failures (G1 = 2 in 2,119 of them, G1 = 1 in 881); the same systems with
a separate boundary per monitor give `null`, 3 or 4 in 1,901 cases, so the hypothesis does
real work.

---

## E2. TRUE

> In every system with `window` = 1, `gate` true and at least one work process, the result
> for G2 is 1.

**Reading.** "At least one work process" means `works` is non-empty. This is how the body of
the specification uses the term (§1: "the non-monitor processes are the work processes and
the joiner"; §2: `alive` initially holds "all monitors and all work processes").

**Proof.** Let `w` be in `works`. Take the one-round execution whose environment phase is the
single step `mutate w`.
1. Round 1 may start (F1); one step is allowed (F2).
2. `mutate w` is enabled: `w` is present (§1) and `bad` is empty (§2). After it
   `bad = {w}`, and this is still so at the end of the monitor phase (F3).
3. `gate` is true, so the work phase follows the monitor phase (§3). In it, `w` is a present
   non-monitor process; `halted` and `pending` are still empty, because they are empty
   initially (§2) and only a work phase changes them (F3).
4. So `w` falls under the second bullet of §3.3. `window` is 1, so the sub-case "`sees` and
   `window` is 0" does not apply whatever `sees` is, and the other sub-case ends with "`w`
   takes a work step".
5. `bad` is not empty and a process took a work step: G2 is violated in round 1 (§3.4). By
   F4 the result is 1.

The proof does not depend on what the monitors detect, so it holds with zero or one monitor,
with `w` checked or unchecked, with `halt_inputs[w]` empty or not, with `coupling` either
way, with `slow_reports` true, and for every `f` >= 1.

**Other reading (changes the verdict).** The table in §1 describes `joiner` as "a work
process that is absent at the start". If the joiner counts as a work process, a system with
`works` empty and a joiner satisfies the hypothesis, and then the claim is
**TRUE ONLY IF `works` is non-empty or `f` >= 2**:
- `f` >= 2, joiner `j`: the phase `join`, `mutate j` makes `j` present, alive and bad; steps
  3 to 5 above apply to `j`; the result is 1.
- `f` = 1, `works` empty: a work step in round 1 needs `join` (no other non-monitor process
  can be present), which uses the only step, so `bad` is empty in round 1. The result is not 1.

Counterexample for that reading:

```json
{"name": "E2 other reading", "f": 1, "monitors": [], "works": [], "joiner": "j",
 "boundary": {}, "substrate": {}, "hb_readers": {}, "checkers": {}, "fwd": {},
 "halt_inputs": {}, "switches": [], "coupling": false, "window": 1, "gate": true}
```

Round 1 can only be no step or `join`; either way `bad` is empty. Round 1 `join`, round 2
`mutate j`: `j` takes a work step with `bad = {j}`. The program returns G2 = 2.

**Evidence.** `test_bounded.py 2500`: 2,500 random systems with `works` non-empty, 0
failures. `test_joiner.py 1500`: with the joiner as the only work process, G2 = 1 exactly
when `f` >= 2 (498 systems with `f` = 1, none with G2 = 1; 1,002 with `f` >= 2, all G2 = 1).

---

## E3. TRUE

> In every system with `gate` false and at least one work process, the result for G2 is 1.

**Reading.** As in E2: `works` is non-empty.

**Proof.** Let `w` be in `works`. Take the one-round execution whose environment phase is the
single step `mutate w` (enabled as in E2; F1, F2).
1. `gate` is false, so the order is environment, work, monitor (§3.6).
2. The work phase uses as `out` the monitors that are in `flagged`, in `alive` and not in
   `bad` after the environment phase (§3.6). `flagged` is empty (§2; no environment step
   changes it), so this `out` is empty.
3. The silence clause reads `alive` after the environment phase (§3.6). `mutate` removes
   nothing from `alive`, so every monitor is in `alive` (§2) and no monitor in
   `halt_inputs[w]` is "not in `alive`".
4. So `sees` is false for `w` (§3.3), with `coupling` true or false. `w` is not in `halted`
   or `pending` (both empty). With `sees` false, §3.3 gives "`w` takes a work step" for
   `window` 0 and for `window` 1.
5. `bad = {w}` at the end of the monitor phase (F3). G2 is "judged as before" (§3.6): `bad`
   is not empty and a process took a work step, so G2 is violated in round 1. The result is 1.

Holds for any `window`, `coupling`, `slow_reports`, `f` >= 1, any number of monitors, and
whatever `checkers[w]` and `halt_inputs[w]` are.

**Other reading.** Same as E2: if the joiner is the only work process and `f` = 1, the
result is 2, not 1. Counterexample (same shape, `gate` false, `window` 0):

```json
{"name": "E3 other reading", "f": 1, "monitors": [], "works": [], "joiner": "j",
 "boundary": {}, "substrate": {}, "hb_readers": {}, "checkers": {}, "fwd": {},
 "halt_inputs": {}, "switches": [], "coupling": false, "window": 0, "gate": false}
```

Round 1 `join` (`j` works, `bad` empty); round 2 `mutate j` (`j` works, `bad = {j}`). The
program returns G2 = 2. Under that reading: TRUE ONLY IF `works` is non-empty or `f` >= 2.

**Evidence.** `test_bounded.py 2500`: 2,500 random systems, 0 failures.
`test_joiner.py 1500`: joiner-only systems have G2 = 1 exactly when `f` >= 2.

---

## E4. TRUE, both parts

> Slow-plain: `joiner` null, `substrate` empty, `switches` empty, every monitor in a boundary
> of its own, `coupling` true, `window` 0, `gate` true, `slow_reports` true. `x` a work
> process, `d` the least number of `fwd` edges from a monitor in `checkers[x]` to a monitor
> in `halt_inputs[x]`. The environment takes exactly one step in total: `mutate x`, in
> round 1. (i) If `d` is defined, `x` takes a work step in each of rounds 1 to `d` and none
> in round `d + 1` or later. (ii) If `d` is undefined, `x` takes a work step in every round.

**Reading.** "That execution" has no stated length. I read it as the execution continued for
as long as §3.5 allows; the statements below hold for every such length. Part (i) also needs
rounds 1 to `d + 1` to exist, which is proved (step 6).

**Setup.** Let `C = checkers[x]`, `H = halt_inputs[x]` (missing key: empty, §1). For `j` >= 0
let `B_j` be the set of monitors reachable from `C` by a path of at most `j` `fwd` edges:
`B_0 = C`, `B_j = B_{j-1}` together with every `r` in `fwd[m]` for `m` in `B_{j-1}`. By
definition, `d` is defined and `d <= j` exactly when `H` meets `B_j`.

**Proof.**
1. *The fixed part of the state.* `mutate x` is enabled in round 1 (`x` present, `bad`
   empty). No other environment step is taken. By F3, in every round after the environment
   phase: `alive` holds every monitor and every work process, `bad = {x}`, `hidden` is empty,
   `off` is empty. So in every monitor phase `active` is the set of all monitors and
   `visible = {x}` (§3.2).
2. *Detection.* In every round, a monitor `m` detects exactly when `m` is in `C`: the first
   clause of §3.2 step 1 with `visible = {x}`; the second clause never holds because every
   monitor is in `alive`.
3. *Flags, by induction on the round `r`: at the end of round `r`'s monitor phase,
   `flagged = B_{r-1}`.* Round 1: `flagged` is empty at the start (§2); detection adds `C`;
   the slow-reports pass (§3.6) ranges over monitors flagged at the start of the round, of
   which there are none. So `flagged = C = B_0`. Round `r` >= 2: at the start
   `flagged = B_{r-2}` (induction; the work phase and the environment phase do not change
   `flagged`). Detection adds `C`, already inside `B_{r-2}`. The single pass adds, for each
   `m` in `B_{r-2}`, every `r'` in `fwd[m]` (all are active). Result: `B_{r-1}`.
4. *`out`.* Every monitor is in `alive` and none is in `bad`, so `out = flagged = B_{r-1}`
   at the end of round `r`'s monitor phase (§3.2 step 3).
5. *What `x` does in round `r`, if not yet halted.* `window` is 0, so nothing is ever added
   to `pending` (§3.3: the only addition is in the sub-case "otherwise ... if `sees`", which
   with `window` 0 is reached only when `sees` is false). `gate` is true, so the work phase
   reads the `out` of step 4. The silence clause is false (every monitor is in `alive`). So
   `sees` is true exactly when `H` meets `B_{r-1}`, that is, exactly when `d` is defined and
   `d <= r - 1`. If `sees`, `x` is added to `halted` and takes no work step; otherwise it
   takes a work step.
6. *Part (i).* Let `d` be defined. For `r <= d`: `sees` is false, `x` takes a work step and
   stays out of `halted`. A responded state needs every present non-monitor process in
   `halted` (§3.5), and `x` is not, so rounds 1 to `d + 1` all start. In round `d + 1`,
   `sees` is true, so `x` halts and takes no work step. Nothing leaves `halted` (§2) and
   the work phase skips halted processes (§3.3), so `x` takes no work step in any later
   round, if there is one.
7. *Part (ii).* Let `d` be undefined. Then `H` meets no `B_j`, `sees` is false in every
   round, `x` takes a work step in every round and is never halted. The state is never
   responded, so the execution can be continued to any length, and the statement holds in
   every round of it.

**Edge cases checked.**
- `d` = 0: "rounds 1 to 0" is empty; `x` halts in round 1 (step 5 with `r` = 1).
- `checkers[x]` empty or missing, or `halt_inputs[x]` empty or missing, or no monitors at
  all: `d` is undefined, part (ii).
- One monitor `m`: `d` = 0 if `m` is in both lists, otherwise undefined (a self-loop in
  `fwd` adds nothing).
- Other work processes: they may halt earlier or later; the execution continues at least
  until `x` halts (step 6), and they do not affect `x`.
- `x` "also affected by another rule": the silence rule cannot fire (no monitor is ever
  stopped); the `pending` rule cannot fire (`window` 0); `hb_readers` cannot cause a flag
  (no monitor is stopped); `x` is the only bad process, so no other checker fires.
- `f` > 1: irrelevant, the environment takes one step in total.
- Which hypotheses are used: `window` 0, `gate` true, `slow_reports` true. The others only
  restrict steps the environment does not take in this execution.

**Evidence.** `e4_exhaustive.py`: all 33,033 slow-plain systems with 0 to 3 monitors over
every choice of `checkers[x]`, `halt_inputs[x]` and `fwd` (other free fields random): 0
failures. `e4_sparse.py 30000`: 30,000 slow-plain systems with 2 to 10 monitors and sparse
`fwd` (`d` up to 7): 0 failures; 30,000 arbitrary systems keeping only `window` 0, `gate`
true, `slow_reports` true: 0 failures. `check_cases.py` prints the chain `c -> p -> q -> h`
(`d` = 3): `x` works in rounds 1, 2, 3 and halts in round 4; without the edge `q -> h` it
works in every round.

---

## E5. TRUE

> In every system (with `gate` true, `window` 0, `slow_reports` false) and every `f` >= 1: if
> some work process `w` has a non-empty `halt_inputs` list and no monitor in `checkers[w]`,
> then the result for G2 is 1.

**Reading.** `w` is in `works`.

**Proof.** Take the one-round execution whose environment phase is the single step
`mutate w` (enabled: `w` present, `bad` empty; F1, F2).
1. After it `bad = {w}`, `hidden` is empty, every monitor is in `alive`, `off` is empty. So
   `visible = {w}` (§3.2).
2. Detection (§3.2 step 1). First clause: some `x` in `visible` has `m` in `checkers[x]`;
   the only `x` is `w`, and no monitor is in `checkers[w]`. Second clause: some monitor not
   in `alive`; there is none. So no monitor detects, and `flagged` stays empty.
3. Propagation starts from flagged monitors only, so `flagged` is still empty and `out` is
   empty (§3.2 steps 2 and 3).
4. Work phase (§3.3): `w` is present, not in `halted`, not in `pending`. `sees` is false: no
   monitor in `halt_inputs[w]` is in `out` (empty), and none is "not in `alive`", so the
   silence clause is false even with `coupling` true. With `sees` false, `w` takes a work
   step.
5. `bad` is not empty and a process took a work step: G2 is violated in round 1 (§3.4). The
   result is 1, for every `f` >= 1.

**Edge cases checked.**
- The proof never uses that `halt_inputs[w]` is non-empty, and never uses the three fixed
  fields: with `gate` false the work phase runs first with an empty `out` (E3, steps 2 to
  4); with `window` 1, `w` works in round 1 anyway (E2); with `slow_reports` true, step 3 is
  unchanged. So the statement holds for every value of those fields.
- `checkers[w]` missing: an empty list (§1), covered.
- One monitor, `f` > 1, `w` on a substrate, `w` in other processes' lists: not used.

**Other reading (changes the verdict).** `halt_inputs` is typed "map work -> list of
monitors" and §3.3 applies it to the joiner too, so `w` could be meant to include the
joiner. Then the claim is **TRUE ONLY IF `w` is in `works`, or `f` >= 2** (with `f` >= 2:
`join`, `mutate j`, then steps 1 to 5 for `j`). Counterexample for `f` = 1:

```json
{"name": "E5 other reading", "f": 1, "monitors": ["m"], "works": [], "joiner": "j",
 "boundary": {}, "substrate": {}, "hb_readers": {}, "checkers": {}, "fwd": {},
 "halt_inputs": {"j": ["m"]}, "switches": [], "coupling": false, "window": 0,
 "gate": true, "slow_reports": false}
```

Round 1 can be: no step, `stop m`, `mutate m`, or `join`. The first three leave no
non-monitor process present, so no work step; `join` leaves `bad` empty. So the result is
not 1. Round 1 `join`, round 2 `mutate j`: nobody checks `j`, `out` is empty, `m` is alive,
`j` takes a work step with `bad = {j}`. The program returns G2 = 2.

**Evidence.** `test_bounded.py 2500`: 2,500 systems as stated, 0 failures; 2,500 with the
fixed fields and the `halt_inputs` condition dropped, 0 failures. `test_joiner.py 1500`:
with only the joiner qualifying, all 1,035 systems with `f` >= 2 have G2 = 1, and 284 of the
465 with `f` = 1 do not.

---

## E6. TRUE

> Under rule A, safety fails. Under rule B, safety holds and recovery fails. Under rule C,
> both hold.

**Reading.** K is a member. The text supports this: its checks are defined under "a
member's own checks", and its lift is listed under "member steps". So "every member holds a
halt" at the start includes K, K's halt counts (K is never lost), and under rule C the
system runs only when K's halt is lifted too.

**State.** (fault present or gone; member 1 lost or not; a halt bit for each of 1, 2, 3, and
for K under rule C). A halt counts if its holder holds it and is not lost. Steps exactly as
in the claim. `e6.py` enumerates every reachable state by breadth-first search and, for
recovery, searches again from every reachable fault-gone state.

**Rule A: safety fails.** The sequence `member 2 lifts`, `member 3 lifts`, `lose member 1`.
Member 2 holds a halt and is always clean, so it may lift; the same for member 3; member 1
is not lost, so it can be lost. In the state reached, the fault is present, members 2 and 3
hold no halt, and member 1's halt does not count. No halt counts, so the system runs with
the fault present. (Losing member 1 is necessary: member 1 is not clean while the fault is
present, so it never lifts.) Program: 24 reachable states, 48 transitions, exactly this one
unsafe state.

**Rule B: safety holds, recovery fails.** Invariant: members 2 and 3 both hold a halt. It
holds at the start. Only a lift removes a halt. Member 2 may lift only when no other
member's halt counts, but member 3 holds a halt and cannot be lost, so its halt counts;
symmetrically for member 3. So neither ever lifts, and the invariant holds in every
reachable state. Hence some halt counts in every reachable state and the system never runs:
safety holds. After `repair` the fault is gone and, by the same invariant, no running state
is reachable: recovery fails. Program: 4 reachable states (fault present or gone, member 1
lost or not), all with three halts held; safety holds; both fault-gone states cannot reach a
running state.

**Rule C: both hold.** Safety: invariant "if the fault is present, K holds a halt". True at
the start; K lifts only when clean, which is only when the fault is gone; the fault never
returns. K is never lost, so while the fault is present K's halt counts and the system does
not run. Recovery: from any reachable state with the fault gone, let K lift if it holds a
halt (it is clean). No rule lets K raise a halt, and members may raise only while K holds
one, so from here no halt is ever raised. Then each of members 1 (if not lost), 2, 3 that
holds a halt lifts it: each is clean (member 1 because the fault is gone, 2 and 3 always)
and K holds no halt. Now no halt counts and the system runs. Program: 20 reachable states,
34 transitions, no unsafe state, every fault-gone state reaches a running state.

**Other readings.**
- If K is not counted among "every member" and starts without a halt, rule C fails safety
  by the rule A sequence: `member 2 lifts`, `member 3 lifts`, `lose member 1`. The claim is
  then false in its third part. So E6 needs: K holds a halt at the start.
- If K starts with a halt but its halt is not counted towards "runs", the verdict is
  unchanged: while the fault is present K holds, so members 2 and 3 cannot lift, and their
  halts count. `e6.py` prints all four combinations.

---

## Programs in this folder

| File | What it does |
|---|---|
| `model.py` | My implementation of the specification: environment steps, the three phases, both variants of §3.6, the responded test, and the result of §4 by breadth-first search with witness executions. |
| `check_cases.py` | The concrete systems quoted above: witnesses, the tight E1 example, the other-reading counterexamples, the E4 chain. |
| `test_bounded.py` | Random systems for E1 (executions of at most 2 rounds), E2, E3, E5 (1 round), and the other readings. Output in `test_bounded.log`. |
| `test_e1_dense.py` | E1 on well-monitored systems with full exploration, against the same systems with separate boundaries. |
| `test_claims.py` | Random generators; full-exploration versions of the E1 to E5 tests; the `d` computation for E4. |
| `e4_exhaustive.py`, `e4_sparse.py` | E4 exhaustively for up to 3 monitors, then on larger sparse graphs and on general systems. |
| `test_joiner.py` | The joiner reading of E2, E3, E5. |
| `e6.py` | Exhaustive exploration of rules A, B, C, with the other readings of rule C (`--states` lists every reachable state). |
| `check_document.py` | Re-runs the four JSON systems quoted in this file as written: results `null`/`null`, G2 = 2, G2 = 2, G2 = 2, as stated. |

Limits of the evidence: the tests exercise my own implementation of the specification, so
they would not catch a misreading that the implementation and the proofs share. The proofs
quote the specification's clauses directly so that each step can be checked against it.
