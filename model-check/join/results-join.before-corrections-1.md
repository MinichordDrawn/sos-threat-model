# Monitors That Join A Running System: Results

**Verdict on the claim: it holds under conditions that it does not give, and the two
numbers in it, three attachments and two observers, are not what the model requires.**

- *What holds.* A monitor can join a running ring without opening a gap, and the system
  can be grown this way without end, from either shape of ring, attaching each new monitor
  to three that watch each other or to three that do not. The fault rate at which the
  grown system has no gap is exactly the starting ring's, at every size and for every
  choice of where to attach. Joining never raises it. **Proved** for the whole class
  (Theorem L and Lemma N, section 3), and **checked** on 12,324 grown systems of five to
  twenty monitors, each at `f` = 1, 2, 3 and 4.
- *The conditions the claim does not give.* (1) A state check of the new monitor must be
  in force in the step that adds it, not a round later. (2) A monitor must not join before
  a monitor that checks it; a ring joins coordinator first, or whole. (3) Every work
  process, at every moment it is present, needs a present state checker and more than `f`
  present halt inputs, so a work process must not join before its ring, and work that takes
  its halt only from a new ring needs that ring to have `f + 1` members and to be told of
  faults elsewhere. (4) Reports must arrive within the round: when a report takes a round,
  growth away from the monitors the work reads opens a gap at one fault per round.
  Without (2) or (3) there is a gap at `f` = 1. Without (1) there is a gap at `f` = 1 if
  a monitor may arrive already bad, and at `f` = 2 if it always arrives good. Each is shown
  by an execution below.
- *Three.* The two judgements do not require three attachments. A joining monitor that
  nothing depends on needs one edge: one existing monitor that checks its state. One that
  later monitors or a work process lean on needs three edges, which may all be with a
  single existing monitor: its state checked, its signal read, and a report from it (and a
  fourth at `f` = 3 when work takes its halt from it). A
  ring that brings its own work needs one two-way link with one monitor of the ring it
  joins. Three attachments matter in the model in one place only: a work process that
  takes its halt from the new ring alone has no gap up to `f` = the number of monitors the
  new one is attached to. Outside the round model, `results.md` gives two more reasons for
  three (naming the faulty monitor after losing one, and the cascade). They are not checked
  here.
- *Two observers.* "Every monitor has two observers" is neither necessary nor sufficient
  for the two judgements. One watcher each is enough at every rate the starting ring
  supports (Theorem L). Two watchers each, with no route from the detection to the work,
  have a gap at `f` = 1. What two watchers do give, **proved**: at two faults per round,
  when every work process takes its halt directly from every monitor, they are enough
  with no reports at all (Theorem F).

The author's two statements of the claim, in paraphrase. The first: a new observer joining
a running system should be modelled. An observer can itself be a ring, as with an outer
ring that watches the inner rings of individual programs. Rings never get bigger, because
a new node only needs to be attached to three other nodes to be part of a full mesh, which
is one more ring. A node can be part of any number of rings.

The second, a correction to how the first was first read: the nodes do not have to watch
each other. The ring also works with three in a cycle and a coordinator attached to all of
them, since that gives the two that a reflexive response needs.

This note is an extension of the model check in `model-check\` (`model-spec.md`,
`results.md`, `check_model.py`). It uses the same four kinds of evidence, with the same
meanings:

- **Checked.** Every reachable state of a small, fully specified system was explored.
  Here that is done by `fast_join.py`. The catalogue (`systems-join.json`) holds 5,658 of
  the cases, among them those behind the tables of sections 2, 4, 5, 7, 8 and 10 and the
  62 systems of way one, and each of those was also explored by `check_model_join.py`, the original checker extended; the two agree on
  all 5,658. The sweeps and the searches for least attachments go further, to about
  156,000 different systems in all, and what is not in the catalogue was explored by
  `fast_join.py` alone.
- **Proved.** An argument that holds for every system of a stated class, of any size.
- **Counted.** Arithmetic.
- **Argued.** Reasoning in prose that is neither proved for a class nor checked.

A system has a *gap* if some execution violates G1 or G2. The *rate* of a system is the
greatest `f` at which it has no gap. "Watches" means both checks the state of and reads the
signal of, as in `results.md` section 10.1.

## 1. The extension

`model-spec-join.md` is the whole of it. In brief:

- A system may list *groups* of processes that are absent at the start (`late`). A group
  joins by one environment step, `join g`, which counts as one of the `f` steps of a
  round. A group may hold one monitor, several monitors that arrive together, and the
  model's one joining work process. A group may carry a condition, `after`: it may join
  only when the processes named there are present.
- Before a monitor joins, none of its edges is in force. Nobody reads its absence as
  silence, no work process waits on it, it reads, checks and reports nothing, and no fault
  can be applied to it. After it joins it is a monitor like any other.
- `join-bad g m` is the second way of joining: the group joins and its monitor `m` is bad
  on arrival. It is one step. It exists only where the system sets `arrive_bad`.
- `slow_edges` lists edges that are missing in the round in which a process at one of
  their ends joins, and in force from the next round. An edge that never arrives is
  simply not in the system.
- A system with none of the three new fields is a system of `model-spec.md`, unchanged.

**The existing results are unchanged. Checked.** `check_model_join.py` was run on the
original catalogue with `--json` and `--systems`. Its output (`original-output-join.txt`)
is the 203 lines of `model-check\run-output.txt`: `diff` finds the first 201 identical,
every result, count of states and census figure among them, and the last two different
only in the names of the two files written. Those two files, the 103 cases and their
results (`original-systems-join.json`, `original-results-join.json`), are byte for byte
`model-check\systems-all.json` and `model-check\results.json` (`cmp` finds no difference).
`fast_join.py`, written separately from the two specification files, gives the same G1
and G2 on all 103.

## 2. The systems

**The base rings.** Four monitors, M1, M2, M3 and K, each in a boundary of its own, and one
work process W. Four shapes:

| Name | Shape |
|---|---|
| mesh | the mesh of four: every one watches every other and reports to every other |
| cycle, checking coordinator | M1 watches M2, M2 watches M3, M3 watches M1; each member reports to the member it does not check and to K; K watches every member and reports to every member; every member watches K |
| cycle, signal-reading coordinator | the same, but K reads signals and flags only and checks no state (the coordinator of `results.md` section 10.1, second row) |
| cycle, as the nested rings build it | the same again, and only M1 watches K (the base ring of `check_model.py`'s nested systems) |

W is checked by every monitor that checks any state and takes its halt from all four
("W reads all"), or is checked by M1 and takes its halt from M1 and K ("W reads two").

**Checked.** With nothing joining:

| Base ring | W reads all: rate | W reads two: rate | Fewest state checkers, signal readers, watchers of a monitor |
|---|---|---|---|
| mesh | 3 | 1 | 3, 3, 3 |
| cycle, checking coordinator | 3 | 1 | 2, 2, 2 |
| cycle, signal-reading coordinator | 2 | 1 | 1, 2, 1 |
| cycle, as the nested rings build it | 2 | 1 | 1, 1, 1 |

All eight meet Theorem S's conditions. In all of them, at every `f` up to the rate, every
round in which a fault lands ends in a complete response. The cycle with a checking
coordinator does hold to three faults per round, like the mesh. With a coordinator that
checks no state it holds to two: at three the environment mutates the three members, and
the one monitor left checks no state.

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate M1, mutate M2, mutate M3 | M1, M2, M3 bad; nothing flagged; W working |

Breaks G1 and G2 (cycle with a signal-reading coordinator, `f` = 3).

**The six edges of a joining monitor.** Between a joining monitor N and an existing
monitor X there are six possible edges, three in each direction:

| Toward N | From N |
|---|---|
| X checks N's state | N checks X's state |
| X reads N's signal | N reads X's signal |
| X reports to N | N reports to X |

**The shapes N is attached in.** Each is a set of those edges to three existing monitors
a, b, c (one, for the last).

| Shape | Edges |
|---|---|
| mesh | all six with each of a, b, c. With a, b, c that watch each other this is the claim's first form. With any a, b, c it is N as a coordinator that checks state. |
| signal-reading coordinator | N reads the signals of a, b, c and reports to them; they watch N and report to it. N checks no state. |
| cycle member, checked by the coordinator | N is a member of a cycle N, a, b with c as its coordinator: N watches a; b watches N; N reports to b and to c; a and c report to N; c reads N's signal and checks N's state. N has two watchers, b and c. |
| cycle member, read by the coordinator | the same, c reading N's signal only. N has one state checker and two signal readers. |
| one watcher | one existing monitor a watches N, and N reports to a. Three edges. |

In the cycle shapes only the edges at N are added: a, b and c keep whatever edges they had
with each other. An edge between two existing monitors cannot be made to appear at a join
in this model. By Lemma M below, having it from the start is never worse.

## 3. Statements used throughout

Call a system *plain with joins* if it is plain in the sense of `results.md` section 10.1
except that it may have late groups and a joiner: no substrates or switches, no two
monitors in one boundary, work halts on silence, no window, the gate in place, reports
within the round, and no slow edges.

**Lemma M (more edges never hurt). Proved,** for any two systems with no window that
differ only in that the second has more edges (signal reads, state checks, reports or halt
inputs), or has an edge prompt that is slow in the first. For each goal, the least number
of rounds to violate it in the second is at least that in the first; in particular if the
first has no gap, neither has the second.

*Proof.* Which processes are alive, bad, hidden, off or present after any sequence of
environment steps does not depend on the edges, and neither does which step is enabled.
Run the same schedule in both. By induction on rounds, the second system's flagged set and
halted set contain the first's: detection and propagation only gain from more edges, and a
work process that sees a reason to halt in the first sees one in the second. So a state
that is responded in the first is responded in the second, and a schedule that the second
can run to its end the first can run too. If a round violates G1 in the second, no live
correct monitor is flagged there, so none is in the first. If a work process steps in the
second, it has not halted there, so it has not halted in the first and steps there too. ∎

Removing an edge therefore never closes a gap, and the attachments of a joining monitor
that leave no gap are closed under adding edges. Section 4 uses this to turn a few hundred
checks into a complete answer for all 2^24 attachments.

**Lemma N (joining never raises the rate). Proved,** for every system. Delete every late
process and its edges. Each result of the system with them is no better than the result of
the system without them.

*Proof.* The environment may leave every join step untaken. Absent processes count for
nothing in any rule, so the executions without a join are exactly the executions of the
smaller system. ∎

**Theorem L (layered growth). Proved,** for any number of monitors and any `f`.
Take a plain system B with no joiner, in which, at rate `f`, every round with a fault ends
in a complete response, and in which a flag at any monitor reaches a halt input of every
work process along report edges. Add late monitors, in groups, with any edges, so that the
late monitors can be ranked with this property: each has a state checker, a signal reader
and a report target (not necessarily different) that are each either a monitor of B or a
late monitor of lower rank, and that are present whenever it is. The work processes are
B's. Then at rate `f` the grown system has no gap, whether or not monitors may arrive bad.

*Proof.* A round in which the environment only joins monitors changes nothing else: no
state is bad, no present monitor is silent, so nothing is detected and no flag exists.
Consider the first round with a fault. If some process of B is faulty, there are at most
`f` such faults, B alone would end the round with a live correct monitor of B flagged and
every work process halted, and by the argument of Lemma M the larger system does at least
that. Otherwise every monitor of B is alive and correct, and the faulty processes are late
monitors. Take the faulty one of lowest rank, `z`. Its checker and its reader of lower
rank are present, alive and correct. If `z` is bad its checker flags; if `z` is stopped its
reader flags. From that monitor a chain of report targets, each of lower rank than the one
before and so each alive and correct, leads to a monitor of B. That monitor is flagged, the
flag reaches a halt input of every work process, and every work process halts. In both
cases the round ends in a complete response, the model ends, and no round has violated
either judgement. ∎

**Theorem J (a connected mutual graph). Proved,** for any number of monitors and any `f`.
In a plain system with joins, suppose that in every set of present processes the joins can
reach: the monitors are connected by pairs that watch each other and report to each other;
every present work process has a present state checker and more than `f` present halt
inputs; and there are more than `f` initial monitors. Then there is no gap at rate `f`.

*Proof.* As above, consider the first round with a fault, with at most `f` faulty
monitors. If a present monitor is alive, correct and not flagged at the end of the monitor
phase, each monitor paired with it is alive and correct (otherwise it would have detected
that monitor) and not flagged (otherwise the flag would have been reported to it). By
connectedness every present monitor is then alive and correct. So if any monitor is
faulty, every live correct monitor is flagged. If none is, some work process is bad, its
checker flags, and the flag reaches every monitor. At least one monitor is live and
correct, because a monitor that arrives bad adds one to both counts and there are more
than `f` initial monitors. Every work process has more than `f` halt inputs, at most `f`
of them faulty, so one is flagged and it halts. ∎

This one covers work processes that join, and it needs only connectedness: one mutual link
is as good as three.

**Theorem F (watchers and report paths). Proved,** for any number of monitors and any
`f`, for plain systems with nothing joining. Suppose every monitor has at least `f` state
checkers and at least `f` signal readers other than itself; every work process has a state
checker; and for every monitor `d`, every work process `w` and every set of at most `f`
monitors not containing `d`, some halt input of `w` outside the set is reached from `d`
along report edges that avoid the set (trivially so when `w` takes its halt from `d`).
Then there is no gap at rate `f`.

*Proof.* In the first round with a fault at most `f` monitors are faulty. If one is, it
has `f` checkers and `f` readers, at most `f - 1` of them faulty, so a live correct monitor
detects it. If none is, a work process is bad and its checker detects it. From the
detecting monitor the flag reaches a live correct halt input of every work process, so
every work process halts, the round ends in a complete response and the model ends. ∎

At `f` = 2 the first condition is "every monitor has two watchers". When every work process
takes its halt from every monitor, the third condition holds with no report edges at all.

**Theorem S in every set of present processes. Proved,** for `f` = 1. If a plain system
with joins meets conditions (a) to (d) of Theorem S in every set of present processes the
joins can reach, counting only present processes and their edges, it has no gap at `f` =
1, whether or not monitors may arrive bad. *Proof.* With one step per round, a round holds
either a join or a fault. A fault is answered as in the proof of Theorem S, in the set of
processes then present. A monitor that arrives bad is a mutated monitor of the set it
arrives in. ∎

**A monitor nobody checks. Proved,** for plain systems with joins. If the joins can reach
a set of present processes in which some monitor has no state checker in force other than
itself, there is a gap at `f` = 1: the joins are taken one a round, and then that monitor is
mutated. Nothing detects it. This is P3 of `results.md` section 6 applied at the moment of
joining, and it is the analogue of P7 for a monitor.

**The theorems against the search. Checked.** Each statement's conditions were tested on the
59,086 different systems that the tables of sections 4 to 10 are drawn from (the systems
tried inside the searches of sections 4 and 5 are not among them), and set beside what the
search found.

| Statement | Conditions hold, no gap | Conditions hold, a gap | Conditions fail, no gap | Conditions fail, a gap |
|---|---|---|---|---|
| Theorem J | 3,502 | 0 | 30,023 | 25,561 |
| Theorem L | 29,506 | 0 | 4,019 | 25,561 |
| Theorem F (systems with nothing joining) | 90 | 0 | 33,435 | 25,561 |
| Theorem S in every set of present processes, the systems with `f` = 1 | 10,718 | 0 | 2,910 | 3,982 |

Each is sufficient and none is necessary. For Lemma M, one edge was added at random to
2,005 of these systems, and no result got worse. For Lemma N, each of the 58,880 systems
with late processes was set against the same system with them deleted, and none did
better.

## 4. (a) What must a joining monitor be attached to?

### 4.1 A joining monitor that nothing depends on

One late monitor N is added to a base ring. W is as it was. The 24 possible edges between
N and the four existing monitors give 2^24 attachments.

**Checked,** for the mesh of four, W reading all, `f` = 1, 2 and 3. Results are "rounds to
break G1 / rounds to break G2". They are the same whichever of the four existing monitors
the edge is with.

| N's only edge | N arrives good: `f` = 1, 2, 3 | N may arrive bad: `f` = 1, 2, 3 |
|---|---|---|
| X checks N's state | no gap, no gap, no gap | no gap, no gap, no gap |
| X reads N's signal | 2/2, 1/1, 1/1 | 1/1, 1/1, 1/1 |
| X reports to N | 2/2, 1/1, 1/1 | 1/1, 1/1, 1/1 |
| N checks X's state | 2/2, 1/1, 1/1 | 1/1, 1/1, 1/1 |
| N reads X's signal | 2/2, 1/1, 1/1 | 1/1, 1/1, 1/1 |
| N reports to X | 2/2, 1/1, 1/1 | 1/1, 1/1, 1/1 |
| no edge | 2/2, 1/1, 1/1 | 1/1, 1/1, 1/1 |
| all 24 edges except the four checks of N | 2/2, 1/1, 1/1 | 1/1, 1/1, 1/1 |
| all 24 edges | no gap, no gap, no gap | no gap, no gap, no gap |

**The least attachment is one edge: one existing monitor checks N's state.** Each of the
four such edges alone leaves no gap, and the attachment with every edge except those four
has a gap (**checked**). By Lemma M every attachment that contains one of the four has no
gap and every attachment that contains none has one, so the answer is complete for all
2^24 attachments at each of the three rates (**proved** from those checks). A thousand
random attachments at each rate, for each base ring and each way of arriving, were checked
against that rule and none disagreed.

The same holds on all four base rings, with W reading all or reading two, at every rate at
which the base ring itself has no gap. Above that rate nothing N brings can help (Lemma N).
**Checked,** with the same completeness:

| Base ring | W reads | Attachments of N with no gap, `f` = 1 | `f` = 2 | `f` = 3 |
|---|---|---|---|---|
| mesh | all | those with a check of N | those with a check of N | those with a check of N |
| cycle, checking coordinator | all | those with a check of N | those with a check of N | those with a check of N |
| cycle, signal-reading coordinator | all | those with a check of N | those with a check of N | none: the base ring has a gap |
| cycle, as the nested rings build it | all | those with a check of N | those with a check of N | none: the base ring has a gap |
| each of the four | two | those with a check of N | none: the base ring has a gap | none |

The check of N may be by any of the four existing monitors, in every row.
On the two cycles whose coordinator checks no state, an added edge "K checks N's state"
works like any other: the enumeration is over edges, and such an edge makes K a state
checker of N.

The execution when no monitor checks N is the analogue of P7:

| Round | Environment | End of round |
|---|---|---|
| 1 | join N | nothing flagged; W working |
| 2 | mutate N | N bad; nothing flagged; W working |

Breaks G1 and G2 (`f` = 1). *With one check of N in place:* in round 2 the checker flags,
the flag reaches the four base monitors and W halts.

**The claimed attachment, edge by edge. Checked.** Put N in a mesh with M1, M2 and M3: 18
edges. Removing any one of the 18 changes no result at `f` = 1, 2 or 3. Removing all three
edges of one kind changes a result for one kind only, "X checks N's state", which gives the
execution above. Seventeen of the eighteen edges, in this system, are needed for nothing.

### 4.2 A joining monitor that a work process depends on

So that the other edges have something to do, let a work process J join in the same step
as N. Only N checks J's state. J takes its halt from N and from the three monitors of N's
ring. This is a new ring with work of its own.

**Checked,** for the mesh of four with N on M1, M2, M3, and for the two cycle shapes with
N on M1, M2, K. The table is for the mesh; the cycle with a checking coordinator gives the
same entries, and the cycle with a signal-reading coordinator gives the same at `f` = 1
and 2 and has a gap at 3 whatever N has.

| N's attachment | `f` = 1 | `f` = 2 | `f` = 3 |
|---|---|---|---|
| mesh with its three (18 edges) | no gap | no gap | no gap |
| the mesh minus any one edge | no gap | no gap | no gap |
| minus every "X checks N's state" | 2/2 (1/1 if N may arrive bad) | 1/1 | 1/1 |
| minus every "X reads N's signal" | 3/3 | 2/2 | 1/1 |
| minus every "N reports to X" | G1 holds, G2 in 2 | G2 in 1 | G2 in 1 |
| minus every "N checks X's state" | no gap | no gap | 3/2 |
| minus every "N reads X's signal" | no gap | no gap | no gap |
| minus every "X reports to N" | no gap | no gap | no gap |
| cycle member, either form, any of the six orders of a, b, c | no gap | no gap | no gap |
| signal-reading coordinator | no gap | no gap | 3/2 |
| one watcher (M1 watches N, N reports to M1) | no gap | no gap | 3/2 |

What each kind of edge is for, by the execution its removal allows:

- *X checks N's state.* N going bad is seen. Without it: join; mutate N.
- *X reads N's signal.* N is J's only checker, so N's stopping must be seen.

  | Round | Environment | End of round |
  |---|---|---|
  | 1 | join N and J | nothing flagged; W and J working |
  | 2 | stop N | nothing bad; nothing flagged; J halted on N's silence; W working |
  | 3 | mutate J | J bad; nothing flagged; W working |

  Breaks G1 and G2 (`f` = 1).
- *N reports to X.* N's detection must reach the rest of the system.

  | Round | Environment | End of round |
  |---|---|---|
  | 1 | join N and J | nothing flagged; W and J working |
  | 2 | mutate J | J bad; N flagged; J halted; W working |

  Breaks G2. G1 holds: the flag exists and goes nowhere.
- *N checks X's state.* Needed at `f` = 3 only. J's fourth halt input is N, and when the
  other three are bad N must find it out for itself.

  | Round | Environment | End of round |
  |---|---|---|
  | 1 | join N and J | nothing flagged; W and J working |
  | 2 | mutate M1, mutate M2, mutate M3 | M1, M2, M3 bad; K flagged; W halted; J working |

  Breaks G2 (`f` = 3; N a coordinator that checks no state). K sees the three and stops W.
  K is not in N's ring and does not report to N, and the three that do are the faulty
  ones.
- *N reads X's signal* and *X reports to N* are spare here. A silent halt input halts J
  directly, and N's own checks make the reports to it unnecessary. A report to N is needed
  in exactly one arrangement: when N checks none of its three, the monitor outside N's
  ring must report to it.

**The least attachments, complete. Checked and proved** as in 4.1 (201 systems checked at
each of `f` = 1 and 2, 623 at `f` = 3; complete for all 2^24 by Lemma M):

- `f` = 1 and `f` = 2: 64 least attachments, each of three edges: one existing monitor
  checks N's state, one reads N's signal, N reports to one. Any of the four monitors will
  do for each, and one monitor may do all three. That is the "one watcher" shape.
- `f` = 3: 256 least attachments, each of four edges: the same three, and either N checks
  the state of one of the three monitors of its ring (192) or the monitor outside its ring
  reports to N (64).

### 4.3 Is three the number?

**Three is more than the two judgements require of a joining monitor's own attachment.**
The least is one edge for a monitor nothing depends on, three edges with one existing
monitor for a monitor that a work process or a later monitor depends on at `f` = 1 or 2,
and four edges at `f` = 3.

**Three is exactly the number in one respect. Checked,** and **proved** in one direction.
Let J take its halt from N and from the `k` monitors N is in a mesh with, and from nothing
else:

| N is in a mesh with | Rate |
|---|---|
| 1 monitor (J has 2 halt inputs) | 1 |
| 2 monitors (J has 3) | 2 |
| 3 monitors (J has 4) | 3 |
| 4 monitors (J has 5) | 3: the base ring's own limit |

The gap at `k` = 1, `f` = 2:

| Round | Environment | End of round |
|---|---|---|
| 1 | join N and J | nothing flagged; W and J working |
| 2 | mutate M1, mutate N | M1 and N bad; M2, M3, K flagged; W halted; J working |

Breaks G2. This is P8b of `results.md` section 6, which is proved there for every system:
a work process with at most `f` halt inputs keeps working when all of them are mutated. So
a new ring of four gives its own work the rate of the mesh of four because a work process
then has four halt sources, not because the new monitor has three watchers.

**What else in `results.md` bears on three.** None of it is in the round model, and none of
it is checked here.

- *Naming the faulty monitor (section 10.2, proved there as a statement about outputs).*
  With at most one faulty monitor, a faulty monitor is named by each of its correct
  watchers and a correct one by at most one. So N can be told from a correct monitor when
  it has two watchers, and still can after losing one when it has three. This is a count
  in favour of three attachments, and of two observers. The round model halts on any flag
  and never asks which monitor is at fault.
- *The cascade (sections 8.2 and 10.2, counted).* Every node passes a halt to at least two
  new nodes. For N that is two report targets. The round model's reports arrive within the
  round, so it cannot show this.
- *Restarting (section 10.3).* A member can restart only if the member that can start
  first reaches it along observation edges. For N that is one observer that K reaches, not
  three. **Checked** in the game of section 10.3, with K able to start first: the mesh of
  four, a system grown to eight in meshes, one grown to seven as cycle members and one
  grown to seven with one watcher each can always restart; a system with a monitor that
  nobody observes cannot. The game is not joined to the round model, here as there.
- *A per-fault reading.* **Proved,** by counting, outside the two judgements: if every bad
  monitor is to be checked in its own round by a live correct monitor, then at rate `f`
  each monitor needs at least `f` state checkers, since the environment can mutate a
  monitor and `f - 1` of its checkers together, and `f` are enough. Two observers give
  that at `f` = 2 and three attachments at `f` = 3. G1 asks for less: one flag anywhere
  satisfies it, and in every system above a fault that takes out a monitor's checker is
  itself seen.

## 5. (b) From the step that adds it

N joins in a mesh with three existing monitors. A "late" edge is missing in the round N
joins and in force from the next.

**Checked,** on the mesh of four and on the cycle with a checking coordinator, which give
the same entries. Nothing depends on N.

| N's edges | N arrives good: `f` = 1, 2, 3 | N may arrive bad: `f` = 1, 2, 3 |
|---|---|---|
| all in force from the join step | no gap, no gap, no gap | no gap, no gap, no gap |
| all a round late | no gap, 1/1, 1/1 | 1/1, 1/1, 1/1 |
| the three checks of N late, the rest at once | no gap, 1/1, 1/1 | 1/1, 1/1, 1/1 |
| one check of N at once, every other edge late | no gap, no gap, no gap | no gap, no gap, no gap |
| each other kind late, alone | no gap, no gap, no gap | no gap, no gap, no gap |
| the checks of N never | 2/2, 1/1, 1/1 | 1/1, 1/1, 1/1 |

So the analogue of P7 for a monitor: **a state check of the joining monitor must be in
force in the step that adds it.** A round's delay opens a gap at one fault per round if the
monitor may arrive bad, and at two if it arrives good.

| Round | Environment | End of round |
|---|---|---|
| 1 | N joins already bad | N bad; nothing flagged; W working |

Breaks G1 and G2 (`f` = 1, attachments a round late). *With the attachments in force at
once:* M1, M2 and M3 flag in round 1 and W halts.

| Round | Environment | End of round |
|---|---|---|
| 1 | join N, mutate N | N bad; nothing flagged; W working |

Breaks G1 and G2 (`f` = 2, N arrives good, attachments a round late).

A monitor that arrives good, with one fault per round, can have every attachment a round
late and no gap follows: the round it joins is used up by the join. That is a property of
the round model's counting, not a licence. A delay of two rounds is not modelled.

**When J joins with N** (J checked by N, halting on N and its three), more must be on time.
**Checked:**

| Late, alone | `f` = 1, 2, 3 (good) | `f` = 1, 2, 3 (may arrive bad) |
|---|---|---|
| the checks of N | no gap, 1/1, 1/1 | 1/1, 1/1, 1/1 |
| the reads of N's signal | no gap, no gap, 1/1 | no gap, no gap, 1/1 |
| N's reports | no gap, G2 in 1, G2 in 1 | no gap, G2 in 1, G2 in 1 |
| N's check of J | no gap, 1/1, 1/1 | no gap, 1/1, 1/1 |
| J's halt inputs | no gap, G2 in 1, 2/1 | G2 in 1, 3/1, 2/1 |
| N's checks of others, N's reads, reports to N | no gap throughout | no gap throughout |

The least sets of edges that must be in force in the join round, complete by the same
monotone search: at `f` = 1 with N arriving bad, one check of N and one halt input of J
other than N (9 such pairs); at `f` = 2, those and also N's check of J, one report from N
and a second halt input of J; at `f` = 3, also a read of N's signal and a third halt
input.

## 6. (c) Growing without end

Every system here starts as a base ring with W checked by the base monitors and taking its
halt from the four of them. New monitors are N5, N6, and so on. A monitor may join only
when every late monitor it is attached to is present, unless the text says "any order".
Joins and faults are interleaved in every order the environment can choose, and a new
monitor may arrive bad.

### 6.1 The result

**Proved.** Let a base ring have rate `r`, with every round with a fault ending in a
complete response at every `f` up to `r`. Grow it by any number of monitors, each attached
in any of the five shapes of section 2 to monitors that are present when it joins. Then
the grown system has no gap exactly when `f` is at most `r`: the rate stays what the base
ring has. It does not rise, it does not fall, and it does not depend on which monitors are
chosen.

*Proof.* Each of the five shapes gives the new monitor a state checker, a signal reader
and a report target among the monitors it is attached to, so Theorem L applies at every
`f` up to `r`. Above `r` Lemma N applies. ∎

For the mesh of four and for the cycle with a checking coordinator `r` is 3. For the two
cycles whose coordinator checks no state it is 2 (section 2, checked).

**The boundary and a counterexample at it.** For the mesh of four grown to eight in meshes
(N5 on M1, M2, M3; N6 on N5, M1, M2; N7 on N5, N6, M1; N8 on N5, N6, N7), at `f` = 4:

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate M1, mutate M2, mutate M3, mutate K | M1, M2, M3, K bad; nothing flagged; W working |

Breaks G1 and G2. No monitor has joined yet, and nothing obliges one to. At `f` = 3 the
first three of those mutations are flagged by K, W halts and the model ends.

**Checked,** all with a new monitor allowed to arrive bad, at `f` = 1, 2, 3 and 4:

- *Way one, each new monitor in a mesh with three that watch each other, from the mesh of
  four.* Every system up to renaming: 1 of five monitors, 3 of six, 10 of seven, 48 of
  eight. All 62 have rate 3.
- *Way two, each new monitor attached to any three.* From each of the four base rings, in
  each of the five shapes and in a mixture of them: every system of five monitors, every
  one of six or a sample of 400, and samples of 150 of seven and of eight. 12,240 systems
  in all. Every one has exactly the rate of its base ring: 3, 3, 2 and 2.
- *Families.* A hub (every new monitor on M1, M2, M3) to 11 monitors; a chain (every new
  monitor on the newest three) and a fan (on K and the newest two) to 20 monitors; each in
  the mesh shape and as cycle members. All have rate 3.

So as to the claim's two forms: a new monitor in a mesh with three that watch each other,
a new monitor that is the coordinator of three that do not, and a new monitor that is a
member of a cycle with a coordinator, all leave no gap, at the base ring's rate. So does a
new monitor with one watcher.

### 6.2 The conditions

**The order of joining. Checked.** Let a monitor join before those it is attached to
("any order"). Of the 62 systems of way one, 61 keep rate 3 and one has a gap at `f` = 1:
the one in which a monitor's three are all late. In general a gap follows exactly when
some monitor can be present with no present state checker (**proved**, section 3).

| Round | Environment | End of round |
|---|---|---|
| 1 | join N8 | nothing flagged; W working |
| 2 | mutate N8 | N8 bad; nothing flagged; W working |

Breaks G1 and G2 (`f` = 1; N8 is attached to N5, N6 and N7, none of which has joined).

The claim says a new node is attached to three *other nodes*, which are there already, so
it gives this condition in effect. The model needs it stated: nothing in an edge list
makes a monitor wait.

**What each edge of the least layered attachment is for. Checked.** A chain with one
watcher each: N5 on M1, N6 on N5, N7 on N6.

| The chain | `f` = 1, 2, 3 |
|---|---|
| as built | no gap, no gap, no gap |
| N5 does not check N6's state | 2/2, 1/1, 1/1 |
| N5 does not read N6's signal | 4/4, 2/2, 2/2 |
| N6 does not report to N5 | G2 in 3, in 2, in 1; G1 holds |
| N6 does not check N7's state | 3/3, 2/2, 1/1 |
| N6 does not read N7's signal | no gap, no gap, no gap |
| N7 does not report to N6 | no gap, no gap, no gap |

A state check is needed for every monitor. A signal read and a report are needed for a
monitor that another leans on, here N6, and are spare for the last monitor of the chain.

| Round | Environment | End of round |
|---|---|---|
| 1 | join N5 | nothing flagged; W working |
| 2 | join N6 | nothing flagged; W working |
| 3 | stop N6 | nothing bad; nothing flagged; W working |
| 4 | join N7 | nothing flagged; W working |
| 5 | mutate N7 | N7 bad; nothing flagged; W working |

Breaks G1 and G2 (`f` = 1; nobody reads N6's signal, and N6 is N7's only checker).

### 6.3 The same systems with every monitor present from the start

The result for a system is taken over every execution, and one execution is "nothing
joins". So no system that grows can be credited with what it would withstand once grown.
The nearest the model comes is the grown system with every monitor present from the
start.

**Checked,** for every system of way one with five, six and seven monitors, `f` up to the
number of monitors:

| What W takes its halt from | Rate with 5, 6, 7 monitors |
|---|---|
| the base four | 3, 3, 3 |
| every monitor | 4, 5, 6 |

**Proved:** such a system has no gap exactly when `f` is less than both the number of
monitors and the fewest halt inputs of a work process. Theorem J gives the one direction.
The other is Theorem 0 and P8b of `results.md`: mutate every monitor, or every halt input
of one work process. So the rate of a grown
system is set by what its work reads and by nothing in how its monitors are attached,
provided they are connected.

## 7. (d) The work processes

Everything in sections 4 to 6 depends on the work in three ways.

**1. Present halt inputs and a present checker, at every moment. Proved** in one
direction by P8b and P3 of `results.md`, **checked** here. The mesh of four, N in a mesh
with M1, M2, M3; `f` = 1, 2, 3, 4:

| The work | Result |
|---|---|
| W as before | no gap to 3 |
| N becomes a fifth halt input of W, or a fifth checker, or both | no gap to 3 |
| W halts on M1, M2 and N | rate 1: before N joins W has two halt inputs |
| W halts on M1 and N | gap at `f` = 1, G2 in 1 round |
| W's only checker is N | gap at `f` = 1, both in 1 round |
| J checked by N, halting on N and its three; J joins in N's step, or by a step enabled once N is present | no gap to 3 |
| the same, J may join at any time | gap at `f` = 1, both in 2 rounds |
| J may join at any time, checked by M1 and halting on the base four | no gap to 3 |
| the same with N as a second checker and a fifth halt input | no gap to 3 |

So **a joining monitor may become a checker or a halt input of an existing work process
without a gap** (it is an added edge, and Lemma M covers it), but it cannot be counted
toward the `f + 1` halt inputs or stand as the only checker, because until it joins it is
neither. It may be a checker and a halt input of a joining work process, provided the work
process cannot join before it.

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate M1 | M1 bad; M2, M3, K flagged; W working |

Breaks G2 (`f` = 1; W takes its halt from M1 and from N, which has not joined).

| Round | Environment | End of round |
|---|---|---|
| 1 | join J | nothing flagged; W and J working |
| 2 | mutate J | J bad; nothing flagged; W and J working |

Breaks G1 and G2 (`f` = 1; J's only checker N has not joined). This is P7 itself.

**2. Where the work takes its halt from.** Theorem L is for work that takes its halt from
the base ring. Then the attachment of a new monitor hardly matters, because every flag
runs down to the base ring and the base ring stops everything. Work that takes its halt
from a new ring makes the ring matter: it needs `f + 1` halt inputs there (section 4.3),
and the ring must be told of faults elsewhere, which needs N to check one of its three or
to be reported to from outside them (section 4.2).

**Checked.** J on each of the four new rings of the mesh of four grown to eight, as a
chain and as a hub, checked by that ring's new monitor and halting on it and its three:

| Shape of each new monitor | Rate, J on ring 1, 2, 3, 4 |
|---|---|
| mesh | 3, 3, 3, 3 |
| cycle member, checked by the coordinator | 3, 3, 3, 3 |
| cycle member, read by the coordinator | 3, 3, 3, 3 |
| signal-reading coordinator | 2, 2, 2, 2 |

With the mesh shape this is **proved** for every size (Theorem J). For the cycle shapes it
is checked for these sixteen systems and no more. A new monitor that is a coordinator
which checks no state caps its ring's work at two faults per round, as it does in a base
ring.

**3. One joining work process.** The specification has one. A system in which every new
ring brings work of its own can be modelled for one ring at a time.

## 8. (e) A joiner that is itself a ring

Ring A is a base ring with W. Ring B is B1, B2, B3 and a coordinator KB, in the same
shape, with a work process WB that only ring B checks and that takes its halt from ring B's
four. Ring B joins by KB being put in a mesh with three monitors of A. All four monitors of
B and WB are late.

**One step or several, and what each means.** In one step, the five arrive together: the
model treats ring B as built and already watching its work before it is attached, and the
attachment as the only act. In several steps, ring B is assembled inside the running
system, and the order is the environment's to choose within the conditions given.

**Checked,** `f` = 1, 2, 3, 4, with a member allowed to arrive bad. The entries are the
same for ring A and ring B both meshes with KB on M1, M2, K or on M1, M2, M3, and for both
cycles with checking coordinators.

| How ring B joins | Result |
|---|---|
| all of ring B and WB in one step | no gap to 3 |
| the four monitors in one step, then WB | no gap to 3 |
| KB, then each member once KB is present, then WB once all four are (five steps) | no gap to 3 |
| the four monitors in one step, WB at any time | gap at `f` = 1, both in 2 rounds |
| KB, then members and WB in any order | gap at `f` = 1: G2 in 3 rounds, G1 in 7 |
| all five in any order | gap at `f` = 1, both in 2 rounds (1 if a member may arrive bad) |

The first three are **proved** by Theorem J, in both shapes (in the cycle shape the
pairs that watch each other are each member with its coordinator, and KB with its three). The last three are the
conditions of sections 6.2 and 7 again: a member must not come before the coordinator that
links it to ring A, and the work must not come before its ring.

| Round | Environment | End of round |
|---|---|---|
| 1 | join B1 | nothing flagged; W working |
| 2 | mutate B1 | B1 bad; nothing flagged; W working |

Breaks G1 and G2 (`f` = 1; B1 has joined before any monitor that checks it).

| Round | Environment | End of round |
|---|---|---|
| 1 | join KB | nothing flagged; W working |
| 2 | join WB | nothing flagged; W and WB working |
| 3 | mutate KB | KB bad; M1, M2, M3, K flagged; W halted; WB working |

Breaks G2 (`f` = 1; WB has joined when KB is the only one of its halt inputs present).

**What KB must be attached by. Checked,** complete by the monotone search of section 4 for
`f` = 1 and 2 over all 24 edges between KB and ring A (2,399 and 2,719 systems checked),
and for `f` = 3 over the 15 edges left when A's check of KB, A's read of KB's signal and
KB's report to A are placed on M1 (602 systems checked). The least attachments at rate
`f`:

- one monitor of A checks KB's state, one reads KB's signal, and KB reports to one; and
- either KB watches one monitor X of A and X reports to KB, or `f + 1` monitors of A
  report to KB.

So the least is six edges, all of which may be with one monitor of A: KB and that monitor
watch each other and report to each other. Three attached monitors are not required at
any rate up to 3 (Theorem J proves that one mutual link is enough). Without the second
item, ring A is protected from ring B's faults and not the reverse:

| Round | Environment | End of round |
|---|---|---|
| 1 | ring B and WB join | nothing flagged; W and WB working |
| 2 | mutate M1 | M1 bad; M2, M3, K flagged; W halted; WB working |

Breaks G2 (`f` = 1; M1 watches KB and KB reports to M1, and nothing comes back to ring B).

**A whole ring lost in one step. Checked,** with both rings present from the start and
each whole in one boundary. At `f` = 1 there is no gap: the loss of ring B is flagged by
the three monitors of A that read KB's signal, and both work processes halt; the loss of
ring A is flagged by KB. At `f` = 2 both rings can be lost in one round, and G1 is broken
in the next; G2 holds, because work that cannot hear its monitors stops. This is
`results.md` section 2.7 with two rings in place of two levels. With ring B joining in one step, the
result at `f` = 1 is G1 broken in 2 rounds and G2 holding. That is ring A's own result
when it is whole in one boundary (`results.md` section 2.7), as Lemma N requires: ring A
can be lost before ring B has come.

**What the model can say about a ring as an observer.** That a ring attached through its
coordinator behaves, for the two judgements, as its monitors and their edges do: there is
no gap under the conditions above, at the rate of the weaker ring. That is all the unit of
the model allows. To ring A, ring B is KB: one signal, one state, one flag, which is what
`results.md` section 10.1 says a ring presents to the level above.

**What it cannot say.**

- *What ring B was before it joined.* A process that has not joined does not exist in the
  model. A ring that was running, with a fault of its own or a halt of its own, and is
  then attached, is not expressible: edges do not appear between present processes. The
  nearest is a member that arrives bad, which is covered.
- *Whether ring A observes ring B or only KB.* If KB shows nominal while ring B behind it
  is wrong in a way KB's state does not show, ring A sees nothing. In the model KB's state
  is one bit that its checkers see, so the question does not arise.
- *A halt that stays in ring B.* G2 counts a work step anywhere while any state is bad
  anywhere, so the only response the model accepts is that both rings stop. Whether ring
  A's work may run on while ring B is halted is outside it.
- *Lifting the halt, and a joining ring's own coordinator starting first.* The model ends
  at the first complete response.

## 9. (f) Rings do not get bigger

**Proved.** In way one, every set of monitors that all watch each other has at most four
members, at every size: a new monitor's neighbours are exactly the three it joined, so a
set that contains it lies within it and those three, and a set that does not was there
before. The number of such rings of four is the number of monitors less three.

**Counted,** for systems grown from the mesh of four to `n` monitors. An edge is one
signal read, one state check or one report.

| | Hub: always M1, M2, M3 | Chain: the newest three | Fan: K and the newest two |
|---|---|---|---|
| Edges added per new monitor, mesh shape | 18 | 18 | 18 |
| Edges in all, mesh shape | 18`n` - 36 | 18`n` - 36 | 18`n` - 36 |
| Mean edges at a monitor, mesh shape | 36 - 72/`n` | 36 - 72/`n` | 36 - 72/`n` |
| Most edges at one monitor, mesh shape, `n` = 8, 16, 32, 64 | 42, 90, 186, 378 | 36, 36, 36, 36 | 42, 90, 186, 378 |
| Most, cycle member read by the coordinator | 30, 54, 102, 198 | 27, 27, 27, 27 | 30, 54, 102, 198 |
| Most, one watcher | 30, 54, 102, 198 | 21, 21, 21, 21 | 21, 21, 21, 21 |
| Monitors W takes its halt from | 4 | 4 | 4 |
| Most report hops from a checker of a monitor to a halt input of W, mesh shape | 0, 0, 0, 0 | 1, 3, 9, 19 | 0, 0, 0, 0 |

The other shapes add fewer edges per monitor: 15 as a signal-reading coordinator, 10 and 9
as a cycle member, 3 with one watcher.

**What stays bounded.** The size of a ring, the edges a new monitor brings, the mean
number of edges at a monitor, and the monitors a work process reads, in every system
built.

**What grows.** The number of rings and the number of edges, in step with the number of
monitors. The edges at a monitor that is chosen again and again: a monitor in `m` rings
has 6(`m` + 2) edges in the mesh shape. "Nodes can be part of any number of rings" is true
for the judgements and is where the cost goes. And, where no monitor is chosen often, the
distance a flag travels to reach the work.

**Counted.** These cannot all be bounded together. If each monitor is the target of at most
`d` report edges and W reads at most `c` monitors, at most `c`(1 + `d` + ... + `d`^`h`)
monitors are within `h` report hops of a halt input of W. So with `c` and `d` fixed the
number of hops grows with the number of monitors, at least as its logarithm.

In the round model a flag makes all its hops within the round and the distance costs
nothing. When a report takes a round it does. **Proved,** for plain systems with slow
reports at `f` = 1: no gap requires every work process to take its halt from a state
checker of every monitor, because when a monitor is mutated only its checkers are flagged
in that round. So if a work process reads at most `c` monitors, some monitor it reads
checks at least (`n` - `c`)/`c` others.

**Checked,** for the 62 systems of way one with slow reports at `f` = 1: 61 have no gap and
one has, the one where some monitor has no base monitor among its three.

| Round | Environment | End of round |
|---|---|---|
| 1 to 4 | join N5, N6, N7, N8, one a round | nothing flagged; W working |
| 5 | mutate N8 | N8 bad; N5, N6, N7 flagged; W working |

Breaks G2 (`f` = 1, reports take a round; W reads the base four). With W taking its halt
from all eight there is no gap, and W then reads a number of monitors that grows with the
system. This is the reflex of `results.md` section 8.1 at the scale of a grown system, and
the point at which a halt that stays within part of a system would be needed: the model
has none.

## 10. "Every monitor has two observers"

The author's reason for the cycle with a coordinator is that every member then has two
observers. **The model's answer is that this is not the condition, in either direction.**

**Not necessary. Proved** (Theorem L) and **checked.** A base ring grown with one watcher
per new monitor has the base ring's rate at every size. A ring of three in which each
monitor is watched by one other and reports to the one it does not check, with W reading
all three, has no gap at `f` = 1 or 2 (`check_model.py`'s catalogue has it; it is rechecked
here). Theorem S's condition (a) asks for one watcher. At `f` = 2 what is necessary is that
no set of two monitors is left unchecked from outside (`results.md` section 10.2), which
one watcher each can meet.

**Not sufficient. Checked.** Each of these systems has nothing joining.

| System | Fewest state checkers, signal readers, watchers | Theorem S (a) to (d) | `f` = 1, 2, 3 |
|---|---|---|---|
| Cycle with a checking coordinator, every report removed, W checked by M1 and halting on M1 and M2 | 2, 2, 2 | fail | 4/1, 2/1, 2/1 |
| The same, W halting on all four | 2, 2, 2 | fail | no gap, no gap, no gap |
| M1 and M2 check each other; K reads both signals and checks no state; both watch K; W halts on all three | 1, 2, 1 | hold | no gap, 1/1, 1/1 |
| Two meshes of three; A1 and B1 report to each other, A2 and B2 too; W checked by and halting on ring A | 2, 2, 2 | hold | no gap, 2/1, 1/1 |
| The same with A3 and B3 reporting to each other too | 2, 2, 2 | hold | no gap, no gap, 1/1 |
| The same two pairs of reports, W halting on all six | 2, 2, 2 | hold | no gap, no gap, 1/1 |

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate M1 | M1 bad; M3 and K flagged; W working |

Breaks G2 (`f` = 1; row 1). Every monitor has two watchers, both of M1's see the fault, and
W, which reads M1 and M2, hears of it from neither.

| Round | Environment | End of round |
|---|---|---|
| 1 | stop B1, mutate B2 | B2 bad; B3 flagged; W working |

Breaks G2 (`f` = 2; row 4). Every monitor has two watchers and Theorem S's conditions hold.
The two routes from ring B to the work are B1 and B2.

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate M1, mutate M2 | M1, M2 bad; nothing flagged; W working |

Breaks G1 and G2 (`f` = 2; row 3). Each member has two observers, and one of the two reads
its signal only.

**What two observers do give. Proved** (Theorem F). At two faults per round, if every
monitor has two watchers, each of which both checks its state and reads its signal, then
some live correct monitor detects every fault. The detection must still reach the work:
directly, where every work process takes its halt from every monitor (row 2 above has no
report edge at all, so it is the same system when reports take a round), or along report
paths to three different halt inputs that share no other monitor. So "two for the reflex" is a true statement about the model at `f`
= 2 for a ring whose work reads its detectors directly, which is the wiring of both
implementations (`results.md` section 8.1). It is not what lets a monitor join.

**Against Theorem S.** Theorem S's (a) to (d) are the right comparison at `f` = 1, and they
carry over to joining: they must hold in every set of present processes the joins can
reach (section 3). They ask for one watcher, two halt inputs, and report paths that avoid
the faulty monitor.

## 11. Limits

Those of `results.md` section 11 all stand. In addition:

- **G1 is satisfied by any flag, and the response is always everything.** This is why so
  little is required of a joining monitor's attachment. When a monitor and its only
  checker go bad together, the checker's fault is seen, everything halts, and the model
  ends without anyone having seen the first monitor's fault. Whether each fault is itself
  detected, which monitor is at fault, and whether a halt may be confined to a ring are
  not questions the two judgements ask.
- **The result for a system that grows includes the executions in which it does not.** So
  no result here says what a grown system withstands once grown. Section 6.3 gives the
  nearest stand-in.
- **Edges are fixed.** A monitor's edges come into force when it joins. An edge between two
  present monitors cannot appear, a halt input cannot be moved from one monitor to
  another, and nothing can leave. Retiring a monitor is not modelled.
- **One joining work process.**
- **A late edge is late by exactly one round.**
- **The model is synchronous and ends at the first complete response.** A join during a
  halt, a join while a fault is being repaired, lifting a halt after a join, and a
  joining ring whose own coordinator must start first are outside it.
- **Declared membership is the other form of P7** (`results.md` section 3.1): a member that
  is declared and absent halts the ring. Under it a monitor's absence is a fault and
  nothing can join a running system at all. The extension models the first form only,
  enrolment in the step that adds the process.

## 12. Not settled

- Whether the two that a reflexive response needs are what section 10 tests. It was read as
  "every monitor has two observers", as the brief directs. If it means two halt sources for
  each work process, that is P8b and is necessary at `f` = 1 (`results.md` section 6).
- A theorem for work that takes its halt from a new ring in the cycle shapes. The sixteen
  systems of section 7 are checked; no proof for every size is given. Theorem J covers the
  mesh shape only.
- The least attachments of a joining ring at `f` = 3 over all 24 edges. The search was
  completed over 15.
- A sufficient condition for an arbitrary graph at more than one fault per round that is
  also necessary. Theorems J, L and F are each sufficient, and each is missed by systems
  that have no gap.
- Way two is checked exhaustively to six monitors and by sample at seven and eight. The
  theorem covers every size; the search does not.
- Everything in section 4.3 under "What else in `results.md` bears on three" is carried
  over from `results.md`, not checked here.
- The independent implementation has not been run. The two implementations compared here
  were written by the same hand.

## Files

All in `join\`.

| File | What it is |
|---|---|
| `model-spec-join.md` | the extension of the specification |
| `model-spec.md` | a copy of the original specification, unchanged |
| `check_model_join.py` | the original checker, extended; a plain run prints what the original prints |
| `fast_join.py` | a second implementation, on bit masks, written from the two specification files |
| `join_lib.py`, `join_runs.py` | the systems, the searches and the tables of this note |
| `run-output-join.txt` | the output of `python -I join_runs.py --write` |
| `systems-join.json`, `results-join.json` | the catalogue, 5,658 cases, and its answers |
| `original-output-join.txt`, `original-results-join.json`, `original-systems-join.json` | the extended checker's output and files for the original catalogue |
| `results-join.md` | this note |
