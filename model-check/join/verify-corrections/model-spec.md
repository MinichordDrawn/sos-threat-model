# Model specification

A small transition-system model of processes that monitor each other. This file defines the
model completely: a system, a state, one round, two goals, and the result to compute for a
system. Nothing outside this file is needed to implement it.

## 1. A system

A system is a JSON object with these fields. A key missing from a map means an empty list.

| Field | Type | Meaning |
|---|---|---|
| `name` | string | a label, not used by the model |
| `f` | integer >= 1 | the most environment steps in one round |
| `monitors` | list of names | the monitor processes |
| `works` | list of names | the work processes |
| `joiner` | name or null | a work process that is absent at the start and may join |
| `boundary` | map monitor -> id | the trust boundary a monitor is in |
| `substrate` | map process -> id | the substrate a process runs on (a process may have none) |
| `hb_readers` | map monitor -> list of monitors | `r` in `hb_readers[m]`: `r` reads `m`'s liveness signal |
| `checkers` | map process -> list of monitors | `m` in `checkers[x]`: `m` compares `x`'s state with a known-good reference |
| `fwd` | map monitor -> list of monitors | `r` in `fwd[m]`: `m` reports its flag to `r` |
| `halt_inputs` | map work -> list of monitors | the monitors whose flag, or silence, halts that work process |
| `switches` | list of monitors | monitors that have an off switch |
| `coupling` | boolean | whether a work process halts on the silence of a monitor in its `halt_inputs` |
| `window` | 0 or 1 | rounds between a work process seeing a reason to halt and halting |
| `gate` | boolean, true if missing | whether the monitors check before the work processes step in each round (section 3.6) |
| `slow_reports` | boolean, false if missing | whether a report takes one round to arrive (section 3.6) |

A monitor missing from `boundary`, or a process missing from `substrate`, has none.

The *non-monitor processes* are the work processes and the joiner. The *present* processes
are the monitors, the work processes, and the joiner once it has joined. Before it joins,
the joiner is not present: no step applies to it and no rule counts it.

## 2. A state

| Component | Contents | Initially |
|---|---|---|
| `alive` | set of processes that have not been stopped | all monitors and all work processes |
| `bad` | set of processes whose state differs from the known-good reference | empty |
| `hidden` | subset of `bad` that no state comparison can see | empty |
| `off` | set of monitors that have been switched off | empty |
| `flagged` | set of monitors that have raised a flag | empty |
| `halted` | set of non-monitor processes that have halted | empty |
| `pending` | set of non-monitor processes that will halt in their next work phase | empty |
| `joined` | whether the joiner has joined | false |

Nothing ever leaves `bad`, `hidden`, `off`, `flagged` or `halted`, and nothing returns to
`alive`.

## 3. One round

A round is three phases in this order: the environment phase, the monitor phase, the work
phase. It maps a state to a state and reports whether each goal was violated in the round.

### 3.1 Environment phase

The environment applies a sequence of `k` steps, for any `k` with `0 <= k <= f`. Each step
must be enabled in the state reached by the steps before it. The steps:

| Step | Enabled when | Effect |
|---|---|---|
| `stop m` | `m` is a monitor in `alive` | remove `m` from `alive` |
| `stop-boundary b` | at least two monitors have boundary `b`, and at least one of them is in `alive` | remove every monitor with boundary `b` from `alive` |
| `fail-substrate s` | some present process `p` with substrate `s` is either a monitor in `alive` or a non-monitor process not in `bad` | for every present process `p` with substrate `s`: if `p` is a monitor, remove it from `alive`; otherwise add it to `bad` and to `hidden`, whether or not it was already in `bad` |
| `mutate p` | `p` is a present process not in `bad` (it may be a monitor or not, in `alive` or not, in `off` or not) | add `p` to `bad` |
| `disable m` | `m` is in `switches` and not in `off` | add `m` to `off` |
| `join` | `joiner` is not null and `joined` is false | set `joined` to true and add the joiner to `alive` |

A halted process is treated like any other: `mutate` and `fail-substrate` apply to it.

### 3.2 Monitor phase

Let `active` be the set of monitors that are in `alive`, not in `bad`, and not in `off`.
Let `visible` be `bad` minus `hidden`.

1. Detection. A monitor `m` in `active` *detects* if at least one of these holds:
   - some `x` in `visible` has `m` in `checkers[x]`;
   - some monitor `p` not in `alive` has `m` in `hb_readers[p]`.

   Every detecting monitor is added to `flagged`.
2. Propagation. Repeat until nothing changes: for every `m` that is in `flagged` and in
   `active`, and every `r` in `fwd[m]` that is in `active`, add `r` to `flagged`.
3. Let `out` be the set of monitors that are in `flagged`, in `alive`, and not in `bad`.

A monitor that is in `flagged` but no longer in `active` passes its flag to nobody. A
monitor that is in `flagged` but stopped or in `bad` is not in `out`. A monitor that is in
`flagged` and in `off`, and is alive and not in `bad`, is in `out`.

### 3.3 Work phase

For each present non-monitor process `w` that is not in `halted`:

- If `w` is in `pending`: remove it from `pending`, add it to `halted`. It takes no work step.
- Otherwise let `sees` be true if some monitor in `halt_inputs[w]` is in `out`, or if
  `coupling` is true and some monitor in `halt_inputs[w]` is not in `alive`.
  - If `sees` and `window` is 0: add `w` to `halted`. It takes no work step.
  - Otherwise: if `sees`, add `w` to `pending`. Then `w` takes a work step.

The order in which the processes are handled does not matter.

### 3.4 The goals, judged per round

Using `bad` and `out` as they are at the end of the monitor phase of the round:

- **G1** is violated in the round if `bad` is not empty and `out` is empty.
- **G2** is violated in the round if `bad` is not empty and at least one process took a
  work step in the round's work phase.

### 3.5 Where the model ends

A state is *responded* if both of these hold: the set of monitors that are in `flagged`, in
`alive` and not in `bad` is not empty; and every present non-monitor process is in
`halted`. No round starts from a responded state.

### 3.6 Two optional variants

**No gate.** When `gate` is false, the phases of a round run in the order environment,
work, monitor. The work phase then uses, as `out`, the set of monitors that are in
`flagged`, in `alive` and not in `bad` in the state reached after the environment phase, so
only flags raised in earlier rounds count. The silence clause of the work phase still reads
`alive` as it is after the environment phase. The monitor phase follows and is unchanged.
G2 is judged as before. G1 is judged with `out` as computed at the end of the round's
monitor phase.

**Slow reports.** When `slow_reports` is true, step 2 of the monitor phase is replaced by a
single pass: for every monitor `m` that was in `flagged` at the start of the round (before
this round's detection) and is in `active`, add to `flagged` every `r` in `fwd[m]` that is
in `active`. There is no
repetition, so a flag makes at most one hop per round, and a monitor that first detects in
this round passes its flag on in the next round at the earliest.

## 4. The result for a system

An *execution of n rounds* is a sequence of n rounds starting from the initial state, in
which no round starts from a responded state.

For each goal, the result is the least `n` such that some execution of `n` rounds violates
that goal in its `n`-th round, or `null` if no execution of any length does. The state space
is finite, so `null` is decided by exploring every reachable state.

## 5. Files

`systems.json` is a list of `{"id": ..., "system": {...}}`. The answer is a list of
`{"id": ..., "G1": n or null, "G2": n or null}`, one entry per case, in a file named by the
task.
