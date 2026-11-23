# The Ninety-Six Statements

Every statement that `SelfObserving/Challenge.lean` states and `SelfObserving/Solution.lean`
proves, in plain words, numbered in the order of `Challenge.lean`. The README summarises
them. The name beside each is its name in Lean.

The documents named here are in the model check, `../model-check/`: `model-spec.md` and
`results.md` at its top, `results-join.md` and `model-spec-join.md` in its folder `join/`,
and `part-a.md` and `results-minimal.md` in its folder `least-ring/`.

Throughout, `f` is the number of faults that may land in one round. The two goals are
detection (a bad state is flagged by a live, correct monitor) and no impact (no work is
done while a state is bad). A system has *no gap* when no execution of any length violates
either goal. One monitor *watches* another when it both checks the other's state and reads
its liveness signal.

## 1 to 26. The general result, the reference system, what any system needs, naming

**1. Theorem S.** A plain system that meets the four conditions has no gap at one fault
per round. The numbers of monitors and of work processes are arbitrary, and neither has to
be finite.

*Plain* means the system has the two basic kinds of fault and the ordinary timing:

- every process is present from the start;
- no substrate is modelled, and no monitor has an off switch;
- no two monitors sit in the same boundary;
- a work process halts when a monitor it listens to goes silent;
- a work process halts at once when it sees a reason to, with no waiting period;
- in each round the monitors check before any work is done;
- a report arrives within the round it is sent.

*The four conditions* on the wiring are:

- (a) every monitor is watched by another monitor, which both checks its state and reads
  its liveness signal;
- (b) every work process has a monitor that checks its state, and takes its halt from at
  least two different monitors;
- (c) if any one monitor is faulty, every other monitor either watches it or hears from a
  monitor that does, along reports that do not pass through the faulty one;
- (d) every work process has a checker whose report reaches every monitor.

**2. The conditions can be met.** A full mesh of two or more monitors, with any work
processes, is plain and meets all four conditions, so it has no gap. In a full mesh every
monitor watches and reports to every other, and every work process is checked by, and
takes its halt from, every monitor. The ring of four that both implementations named in
the model check's README build is a full mesh. A theorem about systems that meet four
conditions would say nothing if no system could meet them.

**3. The property can fail.** A work process that nothing watches has a gap: the
environment can corrupt it, and nothing is there to flag it. This statement is a check on
the definitions. "No gap" is defined in this folder, and a slip in a definition could make
it true of every system, the unwatched one included. Theorem S would then be provable and
would mean nothing. Proving that one plainly unsafe system has a gap shows that the
definition tells the two apart.

**4. The reference system has no gap.** The reference system is the model check's system
with every feature in place: three monitors that watch each other, two work processes, and
a third process that may join later. It is not plain: it has substrates and a process
that joins late. Four of the model's six kinds of step can occur in it; with no off switch
and no shared boundary, the other two cannot. At one fault per round, no execution of any
length violates either goal.

**5 to 14. Each of ten removals opens a gap.** Each statement takes one feature away from
the reference system and says which of the two goals some execution then violates. The
two goals are detection (a bad state is flagged by a live, correct monitor) and no impact
(no work is done while a state is bad).

| Without | Detection | No impact |
|---|---|---|
| P1, the liveness signal | fails | fails |
| P2, shared substrate | fails | fails |
| P3, the state check | fails | fails |
| P4, propagation | holds | fails |
| P5, no single-step removal | fails | fails |
| P6, the out-of-boundary signal | fails | holds |
| P7, automatic enrolment | fails | fails |
| P8, immediate response | holds | fails |
| the halt fan-out | fails | fails |
| the gate | fails | fails |

*Fails* means that some execution violates the goal. *Holds* means that none does, and
that is proved as well. Three removals break one goal only. Without propagation the fault
is flagged, and the work goes on. Without the out-of-boundary signal the work stops, and
nothing is left to know why. Without immediate response every monitor has flagged, and the
work takes one more step. The halt fan-out is the clause of the eighth property by which a
work process takes its halt from more than one monitor, and the gate is the rule that the
monitors check before any work is done.

**15 to 24. What any system needs.** These ten statements are about every system, of any
size and with any wiring. The first says where a flag comes from. The other nine each say
that a system which lacks something has a gap, whatever else it has. In them `f` is the
number of faults that may land in one round, and may be any number from 1 up.

| Id | For every system |
|---|---|
| 15 | A flag starts only at a detection. With no flag up, if no monitor detects, none is raised |
| 16 | If some non-empty set of at most `f` monitors is checked by no monitor outside the set, detection can fail |
| 17 | If there is at least one monitor, and `f` is at least their number, detection can fail |
| 18 | A monitor with no state checker but itself can be corrupted with no flag |
| 19 | A work process that no monitor checks can be corrupted with no flag, whether it is present from the start or joins later |
| 20 | If every monitor sits in one boundary, and there are at least two, detection can fail |
| 21 | With a waiting period before a halt, a corrupted work process acts |
| 22 | A work process with at most `f` halt inputs keeps working after all of them are corrupted |
| 23 | Without the gate, a corrupted work process acts before any flag exists |
| 24 | When reports take a round, a work process none of whose halt inputs checks its state acts while bad |

Statements 16, 17 and 22 are the counts in the model check's scaling law, in the direction
of need. Each further fault that may land in one round needs one more monitor, no set of
that many monitors left unchecked from outside, and one more halt input for each work
process.

Statements 21 to 24 are stated for a work process that is present from the start, as the
model check words 21 and 23. They hold for one that joins later as well. The agent that
wrote the proofs reports a Lean proof of that outside this folder, the tests of the third
agent described in `method.md` agree, and it is not among the statements.

**25 and 26. Naming the faulty monitor.** Responding to a fault does not need to know
which monitor is at fault. Recovering without outside help does. Exactly one monitor is
faulty. Every other monitor names it, the faulty one may name anyone, and a rule reads the
names. With two monitors no rule is always right, because "each names the other" arises
whichever of the two is faulty (25). With three or more, a rule exists that is always
right (26). This is one of the reasons the ring has three members beside its coordinator.

The names in Lean, in order:

| Id | Name | Id | Name |
|---|---|---|---|
| 1 | `theorem_S` | 14 | `withoutGate_gap` |
| 2 | `mesh_noGap` | 15 | `flag_needs_detection` |
| 3 | `unwatched_gap` | 16 | `unchecked_set_gap` |
| 4 | `reference_noGap` | 17 | `rate_bound` |
| 5 | `withoutP1_gap` | 18 | `unchecked_monitor_gap` |
| 6 | `withoutP2_gap` | 19 | `unchecked_work_gap` |
| 7 | `withoutP3_gap` | 20 | `one_boundary_gap` |
| 8 | `withoutP4_gap` | 21 | `window_gap` |
| 9 | `withoutP5_gap` | 22 | `few_halt_inputs_gap` |
| 10 | `withoutP6_gap` | 23 | `noGate_gap` |
| 11 | `withoutP7_gap` | 24 | `slow_report_gap` |
| 12 | `withoutP8_gap` | 25 | `two_cannot_name` |
| 13 | `withoutP8b_gap` | 26 | `three_can_name` |

## 27 to 34, and 54. Restarting

From section 10.3 of `results.md`. The definitions are in `Restart.lean`.

This is a separate small model. Each member of a ring is running or stopped. A member that
cannot start first runs only while a running member observes it. The moves are to stop a
member, to release it, and to start one that can start first or that a running member
observes. A ring *can always restart* when, from every state the moves can reach in which
no member is still blocked, some further moves, none of them a stop, bring every member
back to running.

| Id | Name | Statement |
|---|---|---|
| 27 | `theorem_R` | Theorem R. If no member can start first, then from any state in which no member is running, no moves ever make one run. For any ring, finite or not |
| 28 | `restart_needs_first` | A finite ring with at least one member, none of which can start first, cannot always restart |
| 29 | `restart_iff_reaches` | With exactly one member that can start first, a finite ring can always restart exactly when that member reaches every other along chains of observation |
| 30 | `restart_iff_reached` | The same for any number of members that can start first: exactly when every member that cannot start first is reached from one that can. The model check states it for one |
| 31 | `ring3_cannot_restart` | A ring of three, none of which can start first: after one member is stopped and released, all three are stopped and the ring does not recover |
| 32 | `mesh3_cannot_restart` | A mesh of three, none of which can start first: it does not recover after two members are stopped and released in turn |
| 33 | `ringK_can_restart` | Three members and a coordinator that can start first can always restart |
| 34 | `ringK_cannot_restart_without_first` | The same four with no member that can start first: it does not recover after a member and then the coordinator are stopped and released |
| 54 | `full_stop_reachable` | In every finite ring, some sequence of moves leaves no member running and none blocked |

Statements 28 to 30 and 54 are for a finite ring: each carries a list of all the members.

## 35 to 37. Systems that are not plain

The definitions are in `Wide.lean`. Theorem S is for plain systems. `results.md` has no
general result for a system with substrates, shared boundaries or a process that joins
late, and this one was written for the Lean work, from section 3.1 of `model-spec.md` and
sections 5 and 10.1 of `results.md`.

The wider class: no monitor has an off switch, a work process halts when a monitor it
listens to goes silent, there is no waiting period, the monitors check before any work is
done, and a report arrives within the round. A process that joins late, substrates and
shared boundaries are all allowed.

The conditions are the four of Theorem S, taken over the joining process as well, and two
more: for every substrate that some process runs on, the loss of every monitor on it is
answered; and for every boundary that two monitors share, the loss of every monitor in it
is answered. A loss is *answered* when some monitor is outside the lost set, and every
monitor outside it either reads the signal of a lost one or is reached from one that does,
along reports that stay outside.

| Id | Name | Statement |
|---|---|---|
| 35 | `theorem_S_wide` | A system of the wider class that meets these conditions has no gap at one fault per round. Any size, finite or not |
| 36 | `plain_is_wide` | A plain system that meets the four conditions is such a system, so Theorem S is a special case |
| 37 | `reference_is_wide` | The reference system is such a system, so statement 4, which is proved by computation, also follows by argument |

## 38 to 48, and 55. How fast a halt must travel

From section 8.2 of `results.md`. The definitions are in `Growth.lean`.

This is a count and not the round model. A fault doubles each tick among `n` processes,
and a halt spreads from the place where the fault is detected. The halt reaches good
processes first. The damage is the number of processes the fault has reached when the
count ends.

| Id | Name | Statement |
|---|---|---|
| 38 | `window_damage` | If everything halts `w` ticks after detection, the damage is `2^w`, or `n` if that is smaller, for `n` of 1 or more |
| 39 | `cascade_ends` | For a halt passed to at least one process per hop, at one or more hops per tick, the count ends, so the damage is one number. The model check assumes this and does not state it |
| 40 | `cascade_reach` | After `j` hops, a halt passed to `c` processes per hop has reached at most `1 + c + ... + c^j`, the starting place counted |
| 41, 42 | `geom_one`, `geom_two` | That bound is `j + 1` when the halt is passed to one, and `2^(j+1) - 1` when it is passed to two |
| 43 | `chain_bound` | A halt passed to one per hop, at `h` hops per tick, with `n` of 2 or more: the damage is at least `n - h * L`, for any `L` with `n ≤ 2^L` |
| 44 | `doubling_two_hops_bound` | A halt passed to two per hop, at two hops per tick: the damage `d` satisfies `2 * d^2 ≤ n`, for every `n` of 2 or more |
| 45 | `doubling_one_hop_exact` | A halt passed to two per hop, at one hop per tick: the damage is exactly `n / 4` when `n = 2^k` and `k` is 3 or more |
| 46 to 48 | `halt_table_together`, `halt_table_chain`, `halt_table_doubling` | The fourteen figures of the table in section 8.2 |
| 55 | `doubling_one_hop_range` | The halt of statement 45 loses between a fifth and two fifths of the processes for every `n` from 8 to 3,000, both ends included |

## 49 to 53. Whether three monitors are forced

From section 10.2 of `results.md`. The definition is in `Naming.lean`.

At most one monitor is faulty. A rule *names* the faulty monitor when it is always right
about which one it is, and says so when none is. Statements 25 and 26 suppose exactly one
faulty monitor, and these suppose at most one.

| Id | Name | Statement |
|---|---|---|
| 49 | `one_or_two_cannot_name` | With one monitor or two, no rule is always right |
| 50 | `three_or_more_can_name` | With three or more, a rule exists |
| 51 | `cannot_name_after_loss` | With two or three monitors, after any one of them is lost, no rule names the faulty one among the rest |
| 52 | `can_name_after_loss` | With four or more, after any one is lost, a rule still exists |
| 53 | `pass_to_two_needs_three` | If every member of a non-empty group passes a halt to at least two other members, the group has at least three members |

## 56 and 57. What a slow report costs

From section 8.1 of `results.md`. The definitions are in `Reflex.lean`.

| Id | Name | Statement |
|---|---|---|
| 56 | `slow_report_count` | Reports take a round, there is no waiting period, the monitors check before any work, and the environment's only step corrupts one work process in round 1. That process takes a work step while bad in round `j + 1` exactly when no checker of it reaches one of its halt inputs in `j` report hops or fewer |
| 57 | `slow_report_execution` | Those rounds are rounds of an execution of the model |

So the process works while bad once for every hop between the monitor that checks it and
the monitor that stops it, and in every round if no report path joins them. Statement 24
is the case of at least one.

## 58 and 59. The mesh at any number of faults per round

From section 10.2 of `results.md`. The definition is in `MeshAt.lean`.

| Id | Name | Statement |
|---|---|---|
| 58 | `mesh_holds` | A full mesh with more than `f` monitors has no gap at `f` faults per round. The numbers of monitors and of work processes need not be finite |
| 59 | `mesh_exact` | A mesh of `n` monitors, `n` at least 1, has no gap exactly when `f` is at most `n - 1` |

## 60 to 62. The interleaved rings on two levels

From sections 2.7 and 10.1 of `results.md`. The definition is in `Nested.lean`.

| Id | Name | Statement |
|---|---|---|
| 60 | `nested_noGap` | Two base rings of three members and a coordinator, joined by an upper ring, have no gap at one fault per round |
| 61 | `nested_boundaries_noGap` | The same with each base ring whole in one boundary, so that one step can stop a whole ring: no gap at one fault per round |
| 62 | `nested_is_wide` | Both are cases of statement 35 |

The model check has these two as checked systems. Here they are proved from the wiring,
with no search of states.

## 63 to 67. No gap at any number of faults per round

From section 3 of `results-join.md`, for systems in which nothing joins. The definitions
are in `AnyRate.lean`. Section 11 of `results.md` lists a condition of this kind as
missing: Theorem S is for one fault per round.

Two monitors are a *pair* when each watches the other and each reports to the other.

| Id | Name | Statement |
|---|---|---|
| 63 | `theorem_J` | Theorem J. A plain system has no gap at `f` faults per round if its monitors are connected by pairs, every work process has a state checker and more than `f` halt inputs, and there are more than `f` monitors |
| 64 | `theorem_J_one_way` | The same with the first condition in one direction only: from every monitor, every monitor is reached by steps that each go from a monitor to one it watches and hears from |
| 65 | `paired_is_one_way` | The conditions of statement 63 give those of statement 64, so Theorem J is a special case |
| 66 | `mesh_is_connected` | A mesh of more than `f` monitors is plain and meets the conditions of Theorem J, so statement 58 is a special case |
| 67 | `theorem_F` | Theorem F. A plain system has no gap at `f` faults per round if every monitor has at least `f` state checkers and `f` signal readers other than itself, every work process has a state checker, and from every monitor a halt input of every work process is reached along reports that avoid any set of at most `f` other monitors |

Statement 64 is not in the model check. It asks for what the written proof of Theorem J
uses of a pair, and no more.

## 68 to 70. The ring of `k` members and a coordinator

From section 3 of `results-minimal.md`. The definitions are in `Rings.lean`.

The ring has `k` members in a cycle, each connected to the next, and a coordinator
connected to every member both ways. With `k` = 3 it is the candidate of `part-a.md`:
`A -> B -> C -> A`, `D -> A, B, C` and `A, B, C -> D`, nine connections. What a connection
`X -> Y` carries depends on the reading. Under *flow*, `Y` watches `X` and `X` reports to
`Y`. Under *actor*, `X` watches `Y` and `X` reports to `Y`. There is one work process,
checked by every monitor and taking its halt from every monitor.

| Id | Name | Statement |
|---|---|---|
| 68 | `ring_is_connected` | For `f` at most `k`, the ring, under either reading, is plain and meets the conditions of Theorem J |
| 69 | `ring_exact` | The ring has no gap exactly when `f` is at most `k`, for every `k` and under either reading |
| 70 | `candidate_noGap` | The candidate has no gap at one, two and three faults per round, under either reading |

## 71 to 75. The least ring

From section 2 of `part-a.md` and section 3 of `results-minimal.md`. The definitions are
in `Rings.lean`.

Two requirements are counted. R2: every monitor is watched by at least two other
monitors. R5: every monitor other than the coordinator reports to the coordinator. *Least*
here means the fewest directed connections among these monitors that meet these two
requirements, under the reading named. It is not a claim about any other requirement or
any other reading.

| Id | Name | Statement |
|---|---|---|
| 71 | `least_actor` | Under actor, every wiring of `k` members and a coordinator that meets R2 and R5 has at least `3 * k` connections |
| 72 | `least_flow` | Under flow, every wiring of `k` members and a coordinator that meets R2 has at least `2 * k + 2` connections |
| 73 | `candidate_is_ring` | The list of the candidate's nine connections is exactly the ring's connections at `k` = 3 |
| 74 | `least_of_four_actor` | Four monitors under actor: R2 and R5 need at least nine connections, and the candidate has nine and meets both |
| 75 | `least_of_four_flow` | Four monitors under flow: R2 and R5 need at least eight connections; the candidate without `D -> C` has eight and meets both; the candidate, with nine, meets both, so it is one over |

The bounds are counting arguments that hold for every `k`. No computation over the 4,096
wirings of four monitors is in the proofs. That the bounds are reached is proved for
`k` = 3 only. With no member or one, no wiring meets R2, so statements 71 and 72 say
nothing there.

## 76 to 81. The same ring one level up

From section 4.6 of `results-minimal.md`. The definitions are in `Tower.lean`.

A tower of one level is one ring: three members in a cycle and a coordinator connected to
each both ways. A tower of one level more is three towers and a top coordinator, with the
three towers' top coordinators as the members of the upper ring: in a cycle, and the new
top coordinator connected to each both ways. One, two and three levels have 4, 13 and 40
monitors. Each ring at the bottom has one work process, checked by the four monitors of
its ring and taking its halt from those four.

| Id | Name | Statement |
|---|---|---|
| 76 | `tower_is_connected` | For one level or more and `f` at most 3, with every monitor in a boundary of its own, the tower is plain and meets the conditions of Theorem J |
| 77 | `tower_exact` | For one level or more, with every monitor in a boundary of its own, the tower has no gap exactly when `f` is at most 3 |
| 78 | `tower_noGap` | For one level or more, with every monitor in a boundary of its own: no gap at one, two and three faults per round, under either reading |
| 79 | `tower_boundaries_is_wide` | With each ring at the bottom whole in one boundary, and two levels or more, the tower at one fault per round is of the wider class and meets the conditions of statement 35 |
| 80 | `tower_boundaries_noGap` | So it has no gap at one fault per round, for every number of levels from two up |
| 81 | `tower_one_level_boundaries_gap` | One ring whole in one boundary has a gap at one fault per round: detection can fail |

The model check also gives the tower's result when each work process reads two of its
ring's monitors. That wiring is not in Lean.

## 82 to 94. Monitors that join

From `model-spec-join.md` and sections 2, 3, 5 and 6 of `results-join.md`. The model is in
`Join.lean`, the conditions in `JoinConditions.lean` and the two example systems in
`JoinExamples.lean`.

`Join.lean` is a second model beside `Model.lean`, in which monitors can be absent at the
start and join in groups by a step of the environment. An edge is in force only between
processes that are present, and an edge may be *slow*: in force from the round after its
late end joins. `Model.lean` is unchanged.

| Id | Name | Statement |
|---|---|---|
| 82 | `plainJoin_reachable` | A system that uses none of the three new fields reaches the same states in both models |
| 83 | `plainJoin_same` | For such a system, no gap in one model exactly when in the other, and the same for each goal |
| 84 | `unchecked_present_monitor_gap` | A monitor nobody checks. If the joins can reach a set of present processes in which a present monitor has no present state checker but itself, detection can fail at any `f` of 1 or more |
| 85 | `lemma_N` | Lemma N. Take a system and delete its late monitors with their edges. Each goal that can be violated in the smaller system can be violated in the whole one: late monitors never help |
| 86 | `theorem_J_joins` | Theorem J with joins. A system that is plain apart from its joins, with no slow edge, has no gap if, in every set of present processes the joins can reach, the present monitors are connected by pairs and every present work process has a present state checker and more than `f` present halt inputs, and there are more than `f` monitors at the start |
| 87 | `connected_answers` | In a plain system that meets the conditions of Theorem J, every round in which a fault lands ends in a complete response |
| 88 | `theorem_L` | Theorem L. Take a system that is plain apart from its joins and its slow edges, with no joining work process, and the same system without its late monitors. Suppose that in the smaller one every round with a fault ends in a complete response, and a flag at any monitor reaches a halt input of every work process along reports. Suppose the late monitors can be ranked so that each has a state checker, a signal reader and a monitor it reports to, each of them present from the start or of lower rank, and present whenever it is. If those three edges are not slow and no monitor has an off switch, the grown system has no gap, whether or not monitors may arrive already bad |
| 89 | `grown_ring_exact` | The ring of `k` members and a coordinator, under either reading, grown in that way by any number of monitors, has no gap exactly when `f` is at most `k` |
| 90 | `grown_mesh_exact` | A mesh of `n` monitors, `n` at least 1, grown in that way has no gap exactly when `f` is at most `n - 1` |
| 91 | `slow_check_example_gap` | A mesh of four with one late monitor whose three state checks are slow: both goals can be violated at two faults per round, and at one when the late monitor may arrive already bad |
| 92 | `slow_check_example_rest` | That system meets every other hypothesis of statement 88, for `f` at most 3 and whether or not monitors may arrive already bad |
| 93 | `switch_example_gap` | A mesh of four with two late monitors, the first with an off switch and the second relying on the first: both goals can be violated at one fault per round. Both join, the first is switched off, and the second is corrupted |
| 94 | `switch_example_rest` | That system meets every other hypothesis of statement 88 |

Statements 91 to 94 show that two hypotheses of Theorem L are needed: each example meets
all the others and has a gap.

Where these differ from the model check's sentences:

- Statement 84 is stated there for systems that are plain apart from their joins, at one
  fault per round. Here it holds for every system of the model with joins.
- Lemma N is proved for late monitors, and not for a system whose joining work process is
  in a group or has a slow edge.
- Statement 87 is not there as a general statement. It has the fact, as checked, for its
  eight base systems.
- Theorem L is proved here for grown systems in which no late monitor runs on a substrate
  and no two monitors share a boundary. The model check asks that of the base system only.
- Of the model check's four base rings, statements 89 and 90 cover two: the cycle with a
  coordinator that checks state, and the mesh.
- The model check's Lemma N and Lemma M also say how many rounds a violation needs. Rounds
  are not counted in Lean, here or in statements 95 and 96.

## 95 and 96. More edges never hurt

From section 3 of `results-join.md`. The definitions are in `MoreEdges.lean`.

| Id | Name | Statement |
|---|---|---|
| 95 | `lemma_M` | Lemma M. Take two systems of `Model.lean` with no waiting period that differ only in that the second has more edges. A goal that can be violated in the second can be violated in the first, so no gap in the first gives no gap in the second |
| 96 | `lemma_M_joins` | The same in the model with joins, where the second system may also have, as a prompt edge, an edge that is slow in the first |
