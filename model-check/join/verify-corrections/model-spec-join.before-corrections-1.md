# Model specification, extension: monitors that join

This file extends `model-spec.md`. It adds monitors that are absent at the start and join
by an environment step. Read `model-spec.md` first: section numbers below are its section
numbers, and everything it says stands unless this file replaces it. The two files together
define the extended model completely.

A system that has none of the three new fields (or has them empty or false) is a system of
`model-spec.md` and behaves exactly as that file says. Nothing here changes it.

## J1. A system: three new fields

| Field | Type | Meaning |
|---|---|---|
| `late` | list of groups, empty if missing | the processes that are absent at the start and join by a group's step |
| `arrive_bad` | boolean, false if missing | whether a late monitor may arrive already bad (the step `join-bad`) |
| `slow_edges` | list of edges, empty if missing | edges that are not in force in the round in which a process at one of their ends joins |

A *group* is a JSON object:

| Key | Type | Meaning |
|---|---|---|
| `name` | string | the group's name; group names are distinct |
| `members` | non-empty list of names | each member is a name in `monitors`, or is the `joiner` |
| `after` | list of process names, empty if missing | the group may join only when every one of these is present |

No process is a member of two groups. A group may hold several monitors, which then join
together in one step, and a group may consist of the joiner alone. A group's name may be
the name of one of its members; it is never the name of a joiner that is in no group, so
that the step `join` of `model-spec.md` and the step `join g` below cannot be confused. A
monitor that is a member of a group is a *late
monitor*. A monitor that is in no group is an *initial monitor*. Late monitors are listed in
`monitors` like any other and appear in `boundary`, `substrate`, `hb_readers`, `checkers`,
`fwd`, `halt_inputs` and `switches` like any other.

The `joiner` of `model-spec.md` is unchanged when it is in no group. When it is a member of
a group it joins by that group's step and by no other.

An *edge* is a triple `[relation, key, monitor]` where `relation` is one of `"hb_readers"`,
`"checkers"`, `"fwd"`, `"halt_inputs"` and `monitor` is in the list `relation[key]` of the
system. Its *ends* are the process `key` and the monitor `monitor`. In words:

| Edge | Reads |
|---|---|
| `["hb_readers", p, m]` | `m` reads `p`'s liveness signal |
| `["checkers", x, m]` | `m` checks `x`'s state |
| `["fwd", m, r]` | `m` reports its flag to `r` (here the monitor named third is `r`) |
| `["halt_inputs", w, m]` | `w` takes its halt from `m` |

Every entry of `slow_edges` must be an edge of the system.

## J2. Present processes (replaces the last paragraph of section 1)

The *present* processes are: the initial monitors; the work processes; every member of a
group that has joined; and the joiner once it has joined, by its own step or by a group's.
A process that is not present is *absent*.

No step applies to an absent process and no rule counts it. In particular, of the edges at
an absent late monitor `m`:

- nobody reads its signal: a monitor in `hb_readers[m]` does not detect the absence of `m`;
- a work process with `m` in its `halt_inputs` does not treat `m` as silent, and `m` raises
  no flag for it to see;
- `m` reads no signal, checks no state, receives no report and sends none;
- `m` cannot be stopped, mutated or switched off, is not counted by `stop-boundary`, and is
  not affected by `fail-substrate`.

These follow from the rules below. They are listed so that nothing is left to be inferred.

## J3. A state: one new component (adds to section 2)

| Component | Contents | Initially |
|---|---|---|
| `arrived` | set of names of the groups that have joined | empty |

`alive` initially holds the initial monitors and the work processes, and no late monitor.
`joined` is true once the joiner has joined, by either route. Nothing leaves `arrived`.

## J4. The environment phase (replaces the table of section 3.1)

The environment applies a sequence of `k` steps, `0 <= k <= f`, as before. Every step
below counts as one step, the two joining steps included.

| Step | Enabled when | Effect |
|---|---|---|
| `stop m` | `m` is a present monitor in `alive` | remove `m` from `alive` |
| `stop-boundary b` | at least two present monitors have boundary `b`, and at least one of them is in `alive` | remove every present monitor with boundary `b` from `alive` |
| `fail-substrate s` | some present process `p` with substrate `s` is either a monitor in `alive` or a non-monitor process not in `bad` | for every present process `p` with substrate `s`: if `p` is a monitor, remove it from `alive`; otherwise add it to `bad` and to `hidden`, whether or not it was already in `bad` |
| `mutate p` | `p` is a present process not in `bad` | add `p` to `bad` |
| `disable m` | `m` is a present monitor in `switches` and not in `off` | add `m` to `off` |
| `join` | `joiner` is not null, is a member of no group, and `joined` is false | set `joined` to true and add the joiner to `alive` |
| `join g` | `g` is a group not in `arrived`, and every process in its `after` is present | add `g` to `arrived`; add every member of `g` to `alive`; if the joiner is a member, set `joined` to true |
| `join-bad g m` | `arrive_bad` is true; `join g` is enabled; `m` is a late monitor that is a member of `g` | the effect of `join g`, and then add `m` to `bad` |

A late monitor joins alive, not bad (unless it is the `m` of `join-bad`), not off, not
flagged, whatever happened before it joined to its boundary or its substrate. After it has
joined it is a monitor like any other.

`join-bad g m` is one step. It reaches the same state as `join g` followed by `mutate m`,
which are two.

## J5. Edges in force (new; used by sections 3.2, 3.3 and 3.6)

For a round, let `new` be the set of processes that became present in that round's
environment phase: the members of every group whose `join g` or `join-bad g m` step was
taken in it, and the joiner if its `join` step was taken in it.

An edge is *in force* in a round if both of these hold:

1. both its ends are present after the round's environment phase;
2. it is not listed in `slow_edges`, or neither of its ends is in `new`.

So an edge listed in `slow_edges` is missing for exactly one round, the round in which the
process at one of its ends joined, and is in force from the next round on. An edge between
two processes that are present from the start is always in force. An edge that should never
arrive is simply not in the system.

`new` and the edges in force are fixed for the whole round, in whatever order the phases
run.

## J6. The monitor phase and the work phase (amend sections 3.2, 3.3 and 3.6)

Sections 3.2, 3.3 and 3.6 are read with these changes and no others.

- `active` is the set of present monitors that are in `alive`, not in `bad`, and not in
  `off`. (A late monitor that has not joined is not in `alive`, so this is the same set as
  before.)
- Detection. A monitor `m` in `active` detects if at least one of these holds:
  - some `x` in `visible` has the edge `["checkers", x, m]` in force;
  - some present monitor `p` not in `alive` has the edge `["hb_readers", p, m]` in force.
- Propagation, in both its forms (section 3.2 step 2 and the slow-reports pass of section
  3.6): a flag passes from `m` to `r` only if the edge `["fwd", m, r]` is in force.
- Work phase. For a present non-monitor process `w`, `sees` is true if some monitor `m`
  with the edge `["halt_inputs", w, m]` in force is in `out`, or if `coupling` is true and
  some monitor `m` with that edge in force is not in `alive`.

The goals (section 3.4), the responded states (section 3.5), the order of the phases with
and without the gate (section 3.6) and the result for a system (section 4) are unchanged.
"Present" in them means present as defined in J2.

## J7. Files (adds to section 5)

`systems-join.json` is a list of `{"id": ..., "system": {...}}` as in section 5, where a
system may carry the three new fields. The answer file has the same form as before: a list
of `{"id": ..., "G1": n or null, "G2": n or null}`, one entry per case.

## J8. Three small examples, with their results

They are given so that an implementation can be tried before it is run on a catalogue. In
each, the four initial monitors `M1` to `M4` all read each other's signals, check each
other's state and report to each other, each in its own boundary, with no substrates and no
switches, `coupling` true, `window` 0. The work process `W` is checked by all four and takes
its halt from all four. `N` is the one late monitor, in a group named `N` with no `after`.

1. `N` has one edge: `["checkers", "N", "M1"]`. With `arrive_bad` true and `f` = 1, 2 or 3:
   G1 `null`, G2 `null`.
2. `N` has no edge at all. With `arrive_bad` false and `f` = 1: G1 2, G2 2 (`join N`, then
   `mutate N`). With `arrive_bad` true and `f` = 1: G1 1, G2 1 (`join-bad N N`).
3. `N` has the edge `["checkers", "N", "M1"]`, and it is listed in `slow_edges`. With
   `arrive_bad` false: `f` = 1 gives G1 `null`, G2 `null`; `f` = 2 gives G1 1, G2 1 (`join
   N` and `mutate N` in one round). With `arrive_bad` true and `f` = 1: G1 1, G2 1.
