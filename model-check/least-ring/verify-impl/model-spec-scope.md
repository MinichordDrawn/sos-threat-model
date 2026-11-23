# Model specification, extension: scopes

This file extends `model-spec.md` and `model-spec-join.md`. It adds scopes: a flag carries
the scope it was raised for, a work process halts only on a flag for a scope that covers
it, and the judgements are made scope by scope. Read the two earlier files first: section
numbers without a letter are those of `model-spec.md`, numbers with J are those of
`model-spec-join.md`, and everything they say stands unless this file replaces it. The
three files together define the extended model completely.

A system that has no `scope` field (or has it empty) is a system of the two earlier files
and behaves exactly as they say, with the two small additions of X1 and X10, which change
nothing for a system that does not use them.

## X1. A work process may join in a group (adds to J1 and J3)

A member of a group may also be a name listed in `works`. Such a work process is a *late
work process*: it is absent at the start, it becomes present when its group's `join g` or
`join-bad g m` step is taken, and from then on it is a work process like any other. It is
not in `alive` initially and is added to `alive` by its group's step, like every member.
An entry of `after` that names a late work process is satisfied once that process is
present. `join-bad g m` still requires `m` to be a late monitor.

Nothing else in `model-spec-join.md` changes. In particular J5 applies to the edges at a
late work process (its entries in `checkers` and `halt_inputs`), and the `joiner` of
`model-spec.md` is as before.

## X2. A system: five new fields

| Field | Type | Meaning |
|---|---|---|
| `scope` | map process -> scope id, empty if missing | the scope a process belongs to: a fault at the process lands in that scope |
| `scope_work` | map scope id -> list of non-monitor processes | the work of a scope. For a scope id that is not a key of this map, the work of the scope is the non-monitor processes whose `scope` it is |
| `told` | map scope id -> list of monitors, empty if missing | the monitors that are to hear of a fault in the scope. A scope id that is not a key has the empty list |
| `freeze` | boolean, false if missing | whether a scope is left as it is once it has closed: no fault lands in it and nothing joins it (X7) |
| `max_rounds` | integer >= 1, or missing | if present, only executions of at most this many rounds are considered (X10) |

A scope id is a string. If `scope` is not empty the system is *scoped*, and then every
name in `monitors`, every name in `works` and the `joiner` (if not null) has an entry in
`scope`. The *scopes* of a scoped system are the ids that occur as a value of `scope` or
as a key of `scope_work` or of `told`. A system that is not scoped has no `scope_work`,
no `told` and no `freeze`.

Write `work(s)` for the work of scope `s`. A non-monitor process may be in the work of
several scopes, of one, or of none. Scope `s` *covers* a non-monitor process `w` if `w`
is in `work(s)`. A process *of* scope `s` is one whose entry in `scope` is `s`.

## X3. A state: one component changed, one new (amends section 2 and J3)

| Component | Contents | Initially |
|---|---|---|
| `flagged` | set of pairs (monitor, scope id): the monitor holds a flag *for* that scope | empty |
| `closed` | set of scope ids | empty |

Nothing leaves `flagged` or `closed`.

## X4. The monitor phase (replaces section 3.2 as amended by J6)

`active` is the set of present monitors that are in `alive`, not in `bad`, and not in
`off`. `visible` is `bad` minus `hidden`.

1. Detection. A monitor `m` in `active` *detects for scope `s`* if at least one of these
   holds:
   - some `x` in `visible` whose scope is `s` has the edge `["checkers", x, m]` in force;
   - some present monitor `p` not in `alive` whose scope is `s` has the edge
     `["hb_readers", p, m]` in force.

   For every such `m` and `s`, the pair (`m`, `s`) is added to `flagged`.
2. Propagation. Repeat until nothing changes: for every pair (`m`, `s`) in `flagged` with
   `m` in `active`, and every `r` in `active` with the edge `["fwd", m, r]` in force, add
   (`r`, `s`) to `flagged`.
3. For each scope `s`, let `out[s]` be the set of monitors `m` with (`m`, `s`) in
   `flagged`, `m` in `alive` and `m` not in `bad`.

A flag keeps the scope it was raised for as it is passed on. A monitor may hold flags for
several scopes.

## X5. The work phase (amends section 3.3 as amended by J6)

Section 3.3 is read with one change. For a present non-monitor process `w` that is not in
`halted` and not in `pending`, `sees` is true if at least one of these holds:

- some monitor `m` with the edge `["halt_inputs", w, m]` in force is in `out[s]` for some
  scope `s` that covers `w`;
- `coupling` is true and some monitor `m` with the edge `["halt_inputs", w, m]` in force
  is not in `alive`.

So a flag for a scope that does not cover `w` does not halt `w`, whoever holds it. The
silence of a halt input halts `w` whatever that monitor's scope.

## X6. The judgements (replaces section 3.4 for a scoped system)

They use `bad` and `out[s]` as they are at the end of the monitor phase of the round, and
`closed` as it is at the start of the round.

For each scope `s` that is not in `closed`:

- **G1[s]** is violated in the round if some process of scope `s` is in `bad` and
  `out[s]` is empty.
- **G2[s]** is violated in the round if some process of scope `s` is in `bad` and at
  least one process in `work(s)` took a work step in the round's work phase.
- **told[s]** is violated in the round if all three hold: some process of scope `s` is in
  `bad`; at least one monitor listed in `told[s]` is in `alive` and not in `bad`; no
  monitor listed in `told[s]` is in `out[s]`.

And once for the whole system:

- **spill** is violated in the round if some non-monitor process `w` that was in neither
  `halted` nor `pending` before the round's work phase is in one of them after it, and no
  process of a scope that covers `w` is *faulty*. A process is faulty if it is in `bad`,
  or if it is a present monitor that is not in `alive`.

G1 of the system is violated in a round if G1[s] is violated for some scope, and G2
likewise.

In words: G2[s] says a fault in a scope has no impact through that scope's work; G1[s]
says some live correct monitor holds a flag for that scope; told[s] says that, if any of
the listed monitors can hear, one has; spill says no work halts unless a fault has landed
in a scope that covers it.

## X7. Closing a scope (new)

At the end of each round, after the work phase, every scope `s` not in `closed` for which
both of these hold is added to `closed`:

- `out[s]`, as computed in the round's monitor phase, is not empty;
- every present process in `work(s)` is in `halted`.

(A scope whose work is empty, or has no present process, closes as soon as `out[s]` is
not empty.) A closed scope is not judged in any later round (X6). Its processes are
otherwise as before: its monitors detect, hold flags and pass them on, and are counted by
every rule.

**With `freeze` true,** no fault lands in a closed scope. In the environment phase
(section 3.1 as replaced by J4), a process whose scope is in `closed` is *frozen*, and:

- `stop m`, `mutate p` and `disable m` are not enabled for a frozen process;
- `stop-boundary b` is enabled when at least two present monitors have boundary `b` and
  at least one of them is in `alive` and not frozen; it removes from `alive` every present
  monitor with boundary `b` that is not frozen;
- `fail-substrate s` is enabled when some present process `p` with substrate `s` that is
  not frozen is either a monitor in `alive` or a non-monitor process not in `bad`; its
  effect applies to every present process with substrate `s` that is not frozen;
- `join` is not enabled if the joiner is frozen, and `join g` and `join-bad g m` are not
  enabled if some member of `g` is frozen. (An absent process can be frozen: what matters
  is its entry in `scope`.)

So with `freeze` true a closed scope is left exactly as it was when it closed, as the
earlier model leaves a system at its first complete response. With `freeze` false the
environment phase is unchanged: faults go on landing in a closed scope and processes go on
joining it, and none of that is judged for that scope.

## X8. Where the model ends (replaces section 3.5 for a scoped system)

A state is *responded* if both of these hold: some monitor that is in `alive` and not in
`bad` holds a flag for at least one scope; and every present non-monitor process is in
`halted`. No round starts from a responded state.

## X9. The two optional variants (amends section 3.6 for a scoped system)

**No gate.** The phases run in the order environment, work, monitor. The work phase uses,
as `out[s]`, the monitors that hold a flag for `s`, are in `alive` and are not in `bad`,
in the state reached after the environment phase. The silence clause reads `alive` as it
is after the environment phase. G2[s] and spill are judged as in X6. G1[s] and told[s]
are judged, and scopes are closed (X7), with `out[s]` as computed at the end of the
round's monitor phase.

**Slow reports.** Step 2 of X4 is replaced by a single pass: for every pair (`m`, `s`)
that was in `flagged` at the start of the round, with `m` in `active`, add (`r`, `s`) for
every `r` in `active` with the edge `["fwd", m, r]` in force.

## X10. The result for a system (adds to section 4)

For a scoped system the result is, for each scope `s` and each of G1[s], G2[s] and
told[s], the least `n` such that some execution of `n` rounds violates it in its `n`-th
round, or `null` if no execution of any length does; and the same for spill. `G1` of the
system is the least of the G1[s] that are not `null`, or `null` if all are; `G2` likewise.

If `max_rounds` is present, with value `N`, only executions of at most `N` rounds are
considered, for a scoped system or not: each result is the least `n <= N`, or `null` if
no execution of at most `N` rounds violates the judgement. A `null` is then a statement
about executions of at most `N` rounds and no more.

## X11. One scope is the earlier model

A scoped system in which every process has the same scope, with no `scope_work` and no
`told`, gives, for that one scope, the G1 and G2 of the same system without `scope`: the
flags are then the earlier flags, the scope covers every non-monitor process, and the
scope closes exactly when the state is responded, after which no round starts. `freeze`
makes no difference to such a system. Adding `told` to it adds the judgement told and
changes nothing else.

## X12. Files (adds to section 5 and J7)

`systems-minimal.json` is a list of `{"id": ..., "system": {...}}`, where a system may
carry the fields of all three files. The answer for a case is

- for a system that is not scoped: `{"id": ..., "G1": n or null, "G2": n or null}`;
- for a scoped system: `{"id": ..., "G1": ..., "G2": ..., "scopes": {scope id:
  {"G1": ..., "G2": ..., "told": ...}, ...}, "spill": n or null}`, with one entry in
  `scopes` for every scope of the system.

## X13. Small examples, with their results

They are given so that an implementation can be tried before it is run on a catalogue.
They are the cases `example/1` to `example/9` of `systems-minimal.json`, and the results
below are their entries in `results-minimal.json`.

In all of them `coupling` is true, `window` is 0, the gate is in place, reports arrive
within the round, there are no substrates and no switches, and every monitor is in a
boundary of its own. "X and Y are mutual" means each reads the other's signal, checks the
other's state and reports to the other.

**A.** Monitors `P1`, `P2`, `Q1`, `Q2`. `P1` and `P2` are mutual, `Q1` and `Q2` are
mutual, `P1` and `Q1` are mutual. Work `WP` is checked by `P1` and `P2` and takes its
halt from both; work `WQ` likewise with `Q1` and `Q2`. `P1`, `P2`, `WP` are of scope `p`;
`Q1`, `Q2`, `WQ` of scope `q`. `told` is `{"p": ["Q1", "Q2"], "q": ["P1", "P2"]}`.

1. `f` = 1. G1 and G2 `null` for both scopes; told[p] 2 and told[q] 2; spill `null`.
   Told[p] in two rounds: round 1 `stop Q1` (`P1`, `P2`, `Q2` are flagged for `q`, `WQ`
   halts on silence, `WP` takes a work step, `q` closes); round 2 `mutate P1` (`P2` is
   flagged for `p`, `WP` halts; `Q2` is alive and correct and holds no flag for `p`).
2. `f` = 2. For `p`: G1 2, G2 1, told 1. The same for `q`. Spill `null`. G2[p] in one
   round: `mutate P1`, `mutate P2`. Told[p] in one: `stop Q1`, `mutate P1`. G1[p] in two:
   round 1 `stop Q1`; round 2 `stop P1`, `mutate P2`.
3. The system of 1 without `scope` and `told`, `f` = 1: G1 `null`, G2 `null`.
4. As 1, but `WQ` also takes its halt from `P1`, `f` = 1: spill 1 (`stop P1`: `WQ` halts
   on the silence of `P1`, and nothing of scope `q` is faulty). The other results are
   those of 1.

**B.** As A with one more monitor `T`, of scope `top`, mutual with `P1` and with `Q1`,
and `scope_work` `{"top": ["WP", "WQ"]}`. `told` as in A.

5. `f` = 1. G1 and G2 `null` for all three scopes; told[p] 2, told[q] 2, told[top]
   `null`; spill `null`.
6. `f` = 2, `freeze` true. For `p` and for `q`: G1 3, G2 1, told 1. For `top`: G1 2, G2
   2, told `null`. Spill `null`. G1[top] in two rounds: round 1 `stop P1` (scope `p`
   closes); round 2 `stop Q1`, `mutate T` (nobody that watches `T` is left).
9. As 6 with `max_rounds` 1. For `p` and for `q`: G1 `null`, G2 1, told 1. For `top`:
   all `null`. Spill `null`.

**C.** Monitors `A`, `B`, `C`, `D` and work `W`, all of scope `ring`; `told` is
`{"ring": ["D"]}`; `W` is checked by all four and takes its halt from all four. `A` and
`B` check each other's state and read each other's signal; `A` checks the state of `C`
and of `D`. `f` = 1.

7. No reports. G1 `null`, G2 `null`, told 1 (`mutate A`: `B` is flagged, `W` halts, `D`
   is alive and correct and is not flagged), spill `null`.
8. With the edges `["fwd", "A", "D"]` and `["fwd", "B", "D"]`: every result `null`.
