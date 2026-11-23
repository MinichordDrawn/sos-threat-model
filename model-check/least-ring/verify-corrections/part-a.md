# Part A. The Least Ring Of Four

**Verdict on the candidate: it depends on what an arrow carries. Two readings are worked
through in full below and give different answers. They are not the only fair ones: of
the 27 readings in which an arrow carries all three kinds of edge, the candidate is least
under six, one connection over under twelve, short of R2 as stated under six, and four
over under three (section 2.6).**

- *If an arrow X -> Y means "X observes Y and reports to Y"* (called **actor** below): the
  candidate is **least, tied with five others**, with R5 read as the member's report edge.
  (With R5 read as "D watches each member", eight are enough under actor too: section
  2.7.) Nine connections are the fewest that meet
  the whole list, 26 wirings have nine, they fall into six shapes up to renaming of the
  members, and the candidate is one of the six. Each of its nine connections is forced, by
  R2 (two observers) or by R5 (upward) and by nothing else.
- *If an arrow X -> Y means "what X shows and says goes to Y"* (called **flow** below): the
  candidate is **not least**. Eight connections meet the whole list. One of the eight-
  connection wirings is the candidate with one of the coordinator's three downward arrows
  removed. Of `D -> A`, `D -> B`, `D -> C`, the list forces two (the coordinator's two
  observers) and the third is forced by nothing on the list as it is written.
- *In both readings* the count is fixed by R2 and R5 alone. R1 (no gap), R3 (restart) and
  R6 (scope), at one fault per round, forbid a few of the least wirings and add no
  connection. R4 (naming), as the Lean statements have it, is a count of nodes and adds
  nothing to the wiring of four.
- *Kind by kind,* the fewest edges for the whole list are 19: eight signal reads and
  eight state checks (R2) and three reports to the coordinator (R5). That is for an
  observer that is one node both reading the signal and checking the state, which is how
  R2 is stated here; with an observer read as a signal reader the fewest are 15 (section
  3.5). The candidate's nine
  arrows can carry 27 edges under either reading, 19 of them are enough, and the eight
  that nothing on the list needs are the same eight in both readings: the three reports
  along the cycle, the coordinator's three reports to its members, and one member's watch
  of the coordinator.
- *The mesh of four buys nothing on this list.* At one, two and three faults per round,
  for every requirement and both ways of wiring the work, the mesh and the candidate give
  the same answers.
- *One reading of R4 that the list does not make* changes the first two points. If
  "still naming the faulty node after losing one" is read at the wiring (a node can name
  only a node it watches), then nine connections are the fewest under both readings and
  the candidate is one of three least shapes. This is noted and not relied on: section 1.3
  says why it is a reading and not the Lean statement.
- *The further readings of an arrow* (section 2.6) give "one over" where a flag passes
  both ways along a connection, "least" where only one of the watching kinds is sent both
  ways under actor, and "does not meet R2 as stated" where the signal read and the state
  check run opposite ways.

Everything below is **checked** unless marked otherwise: every reachable state of each
system was explored. Evidence kinds are those of `results.md`: **Checked**, **Proved**,
**Counted**, **Argued**.

## 1. What was checked

### 1.1 The ring and the work

Four monitors A, B, C and D, each in a boundary of its own, and one work process W. D is
the coordinator: it is the node R3 lets start first, the node R5 connects every member to,
and the node R6 says must be told. A, B and C are the members.

The work is wired in the two ways `results-join.md` section 2 uses:

- **W reads all:** W is checked by all four and takes its halt from all four.
- **W reads two:** W is checked by A and takes its halt from A and D.

`results-join.md` words the first as "checked by every monitor that checks any state".
For a wiring in which some node checks nothing that is a different system. Both were run
on all 4,096 wirings at the three rates: no result differs, under either reading.

There are no substrates, switches or joiner, work halts on silence, there is no window,
the gate is in place and reports arrive within the round (a *plain* system).

### 1.2 What an arrow carries

The model has three kinds of edge: `m` reads `p`'s signal; `m` checks `x`'s state; `m`
reports its flag to `r`. "A connection X -> Y carries everything in that direction" can be
taken in more than two ways. Two are done in full, here and in every section below. The
others are run for the whole list at `f` = 1 in section 2.6.

| Reading | X -> Y carries | In words |
|---|---|---|
| **flow** | Y reads X's signal; Y checks X's state; X reports to Y | everything that leaves X goes to Y: Y watches X, and X reports to Y |
| **actor** | X reads Y's signal; X checks Y's state; X reports to Y | everything X does, it does toward Y: X watches Y, and X reports to Y |

The two differ in who watches whom. The report runs from X to Y in both.

Two more readings are the mirror images of these (X -> Y: X watches Y and Y reports to X;
and Y watches X and Y reports to X). They need no separate run: reversing every arrow
turns each into one of the two above, the 4,096 wirings are the same 4,096 systems, and
the candidate reversed is the candidate with B and C renamed. So each mirror reading gives
the same numbers as its original (**proved**, by that renaming).

The candidate under each reading, edge by edge:

| Arrow | flow | actor |
|---|---|---|
| A -> B | B watches A; A reports to B | A watches B; A reports to B |
| B -> C | C watches B; B reports to C | B watches C; B reports to C |
| C -> A | A watches C; C reports to A | C watches A; C reports to A |
| D -> A, B, C | each member watches D; D reports to each member | D watches each member; D reports to each member |
| A, B, C -> D | D watches each member; each member reports to D | each member watches D; each member reports to D |

"Watches" is both: reads the signal and checks the state. Each reading gives 27 edges. In
both, D and each member watch each other and report to each other, because both arrows
are there. The readings differ only on the cycle: under flow a member reports to the
member that watches it, under actor to the member it watches.

Under flow the candidate is, edge for edge, the "cycle, checking coordinator" of
`results-join.md` section 2 (**checked** by comparing the edge sets under every renaming).
Under actor it is a ring that file does not have.

An arrow read as a link with no direction (all six edges between the two nodes) makes the
candidate the mesh: its nine arrows join all six pairs. Section 2.5 gives that case.

### 1.3 The requirements, as they are stated in the model

| | Stated as | Choices made |
|---|---|---|
| **R1** | No execution violates G1 or G2 at `f` = 1. Also reported at `f` = 2 and 3. | none |
| **R2** | Every one of the four nodes has at least two other nodes that both read its signal and check its state. | "Node" is a monitor. The work has no signal and is not counted. An observer is taken to be one node that does both: reads the signal and checks the state. The other choices (a signal reader; two readers and two checkers by any nodes) change the kind by kind figure and are in section 3.5. |
| **R3** | The ring can always restart in the game of `results.md` 10.3, D being the one member that can start first. By `restart_iff_reached` (Lean) that is: D reaches A, B and C along observation. | "Observes" is "watches" (signal and state). The other choice, "reads the signal", is given in section 3.4. Under either reading of an arrow a connection carries both, so the choice only matters kind by kind. |
| **R4** | A rule exists that always names the faulty node when at most one is faulty. | Taken as the Lean statements have it, a count: three nodes are enough (`three_or_more_can_name`), fewer are not (`one_or_two_cannot_name`), and four are needed to still name after losing one (`cannot_name_after_loss`, `can_name_after_loss`). Every wiring of four nodes meets it. See below. |
| **R5** | Each of A, B, C has a report edge to D. | "Connected directly so that its flag reaches the coordinator in one hop" is the report edge. D watching a member is not that: it carries the member's state to D, not the member's flag. The numbers under that other choice are in section 2.7: with it the candidate is not least under actor either. |
| **R6** | For one ring: no execution violates G2 (the ring's work halts), and none violates **told**. *Told* is violated in a round at whose end something is bad, D is alive and not bad, and D is not flagged. | A single ring has no ring above it. What is above it is D, the one member it would share with an upper ring. So "the ring above is told" is "D holds the flag whenever D can". When D is itself the fault it cannot tell anyone, and the ring above must see D by watching it: that is Part C. The other choice, leaving "told" out of a single ring, makes R6 the second half of R1. |

**R4 and the wiring.** The Lean definition `CanName` supposes that every correct monitor
names the faulty one exactly. It has no edges in it, so it says nothing about a wiring:
with four nodes R4 holds, and holds after the loss of one, whatever the connections are.
That is how R4 is counted in every table below.

To make R4 say something about the wiring one more supposition is needed, and the list
does not make it: *a correct node names the faulty node only if it watches it, and
otherwise names nobody.* `results-join.md` section 4.3 uses this supposition in passing.
Under it:

> **Naming at the wiring. Proved,** for any number of nodes. A rule that always names the
> faulty node (or says that none is faulty) exists exactly when every node has a watcher
> and no two nodes are each watched by nobody but the other.

*Proof.* A rule exists exactly when no two cases with different answers can produce the
same names. "Nobody faulty" produces no names at all. "X faulty" produces: X named by
each of X's watchers, anything from X, nothing from the rest. That can be empty exactly
when X has no watcher. "X faulty" and "Y faulty" can coincide exactly when no third node
names either, that is, every watcher of X is Y and every watcher of Y is X: then X names Y
in the first case as a lie and in the second as the truth, and likewise Y. ∎

**Checked** against a search over the cases on all 4,096 wirings under both readings: no
disagreement. The rows marked **R4w** (naming at the wiring) and **R4wl** (the same after
the loss of any one node, on the three that remain) use this rule. Two watchers each (R2)
give R4w. They do not give R4wl.

## 2. Connections as the drawing has them

There are twelve possible connections, so 4,096 wirings. Each was explored under each
reading, with each wiring of the work, at `f` = 1, 2 and 3: 49,152 systems. For every one
of the 63 combinations of the six requirements the least number of connections, the
wirings that have it and whether the candidate is among them are in
`part-a-connections.txt` (all 756 rows) and `part-a-connections-summary.json`. The rows
that carry the result follow. "Shapes" are wirings up to renaming of the members (D is
kept; where the work reads two, A is kept too).

### 2.1 Each requirement alone, and the whole list

Least number of connections (number of least wirings, shapes). W reads all.

| Requirement | flow, `f` = 1 | flow, 2 | flow, 3 | actor, `f` = 1 | actor, 2 | actor, 3 |
|---|---|---|---|---|---|---|
| R1 | 4 (81, 15) | 4 (30, 5) | 4 (6, 1) | 4 (81, 15) | 4 (30, 5) | 4 (6, 1) |
| R2 | 8 (81, 15) | same | same | 8 (81, 15) | same | same |
| R3 | 3 (16, 4) | same | same | 3 (16, 4) | same | same |
| R4 | 0 | 0 | 0 | 0 | 0 | 0 |
| R5 | 3 (1, 1) | same | same | 3 (1, 1) | same | same |
| R6 | 4 (48, 9) | 4 (24, 4) | 4 (6, 1) | 4 (12, 3) | 5 (63, 11) | 6 (142, 26) |
| R2 + R5 | 8 (24, 4) | same | same | **9** (27, 7) | same | same |
| all but R2 | 4 (3, 1) | 5 (9, 2) | 6 (16, 4) | 6 (16, 4) | 6 (16, 4) | 6 (16, 4) |
| **the whole list** | **8** (24, 4) | **8** (24, 4) | **8** (18, 3) | **9** (26, 6) | **9** (26, 6) | **9** (26, 6) |

W reads two, `f` = 1: the whole list needs 8 under flow (22 wirings, 11 shapes) and 9
under actor (26 wirings, 14 shapes). At `f` = 2 and 3 no wiring of any size meets R1 or R6
when the work reads two: the work has two halt sources and both can be mutated in one
round (P8b of `results.md`).

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate A, mutate D | A, D bad; B, C flagged; W working |

Breaks G2 (the candidate, either reading, W reads two, `f` = 2).

**The candidate is among the least wirings in exactly these cases.** Under actor: for the
16 combinations that hold both R2 and R5, with either wiring of the work, at every rate at
which the combination can be met at all. Under flow: for no combination. The candidate
meets every requirement and every combination; where it is not least it is because fewer
connections also do.

### 2.2 Where the count comes from

**Counted.** Under either reading R5 is the three connections `A -> D`, `B -> D`,
`C -> D`, and R2 is two watchers for each of four nodes.

- *flow.* A node is watched by the nodes its arrows point to. `X -> D` gives member X
  its first watcher, D. Each member needs one more arrow, to another member or not: three
  more. D needs two arrows out. 3 + 3 + 2 = **8**, and eight are enough only in that
  pattern.
- *actor.* A node is watched by the nodes whose arrows point at it. `X -> D` gives D a
  watcher and gives X none. So D has three watchers, which is one more than R2 asks and
  is what R5 forces. Each member still needs two arrows pointing at it: six more.
  3 + 6 = **9**.

So the difference between the readings is which requirement the upward arrow also
serves. Under flow it is also the member's first observer. Under actor it is also one of
the coordinator's observers, and the coordinator ends with three because all three
members must reach it.

**Checked.** R2 + R5 alone has 24 least wirings under flow and 27 under actor. The whole
list has 24 and 26 at `f` = 1 and 2: R1, R3 and R6 remove none under flow and one under
actor (the wiring in which D watches no member, which R3 forbids). At `f` = 3 under flow
R1 removes six more, one shape:

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate A, mutate B, mutate D | A, B, D bad; nothing flagged; W working |

Breaks G1 and G2 (flow; `A->B, A->D, B->A, B->D, C->A, C->D, D->A, D->B`; W reads all;
`f` = 3). C is watched by A and D and watches nobody.

### 2.3 Every least wiring for the whole list

**flow, eight connections, four shapes** (W reads all, `f` = 1 and 2; at `f` = 3 the
first is out):

```
1.  A -> B,  B -> A,  C -> A        A, B, C -> D        D -> A, B
2.  A -> B,  B -> A,  C -> A        A, B, C -> D        D -> A, C
3.  A -> B,  B -> A,  C -> A        A, B, C -> D        D -> B, C
4.  A -> B -> C -> A                A, B, C -> D        D -> A, B
```

Shape 4 is the candidate without `D -> C`. Where the work reads two there are eleven
shapes, because A is then different from B and C: they are in `part-a-connections.txt`.

**actor, nine connections, six shapes** (W reads all, every rate):

```
1.  A -> B, C     B -> A, C     C -> A              A, B, C -> D        D -> B
2.  A -> B, C     B -> A, C                         A, B, C -> D        D -> A, B
3.  A -> B, C     B -> A        C -> A              A, B, C -> D        D -> B, C
4.  A -> B, C     B -> A        C -> B              A, B, C -> D        D -> A, C
5.  A -> B, C     B -> A                            A, B, C -> D        D -> A, B, C
6.  A -> B -> C -> A                                A, B, C -> D        D -> A, B, C     (the candidate)
```

All six have the three upward arrows and six arrows into the members, two into each, at
least one of them from D. Where the work reads two there are fourteen shapes.

### 2.4 Which requirement forces each connection

Remove one connection from the candidate and see which requirements it then fails.
**Checked,** the same for both wirings of the work and at each rate at which the candidate
met the requirement before.

| Connection | flow: fails | actor: fails |
|---|---|---|
| A -> B, B -> C, C -> A (each) | R2 | R2 |
| A -> D, B -> D, C -> D (each) | R2 and R5 | R5 |
| D -> A, D -> B, D -> C (each) | nothing | R2 |

Removing one connection never opens a gap: R1 and R6 still hold at `f` = 1, 2 and 3 with
W reading all, and at `f` = 1 with W reading two. R3 still holds. So in the candidate
**R1, R3 and R6 force no connection, R2 forces six or eight of the nine, and R5 forces
three.** Under flow, removing a second of D's downward arrows fails R2 (D then has one
watcher): two of the three are forced, jointly, and no particular one.

If naming after a loss is read at the wiring (R4wl, section 1.3), every one of the nine
is forced under both readings, and the whole list has the same three least shapes under
both:

```
a.  A -> B, C     B -> A        C -> A              A, B, C -> D        D -> B, C
b.  A -> B, C     B -> A        C -> B              A, B, C -> D        D -> A, C
c.  A -> B -> C -> A                                A, B, C -> D        D -> A, B, C     (the candidate)
```

The case that needs `D -> C` under flow: lose B from the eight-connection shape 4. A is
then watched only by D and D only by A, and when they name each other no rule can tell
which is at fault. With `D -> C`, C also watches D.

### 2.5 An arrow with no direction

If a connection is a link that carries all six edges between its two nodes, there are 64
wirings. **Checked:** the whole list needs **five** links, at `f` = 1, 2 and 3 with W
reading all and at `f` = 1 with W reading two: D linked to each member, and two of the
three links among the members. The candidate, whose arrows join all six pairs, is then
the mesh and is one link over.

### 2.6 The further readings of an arrow

Flow and actor are the two readings in which the watching runs one way and the report
runs along the arrow. They are not the only fair ones. Each of the three kinds can run
along the arrow (Y reads X's signal; Y checks X's state; X reports to Y), against it, or
both ways: 27 readings. Flow is along, along, along. Actor is against, against, along.

**Checked** here (`corrections_1.py`, `corrections-1-readings.txt`), and independently by
the reader of `verify-reader\handback.md`, who reported it first: all 27, every one of the
4,096 wirings, `f` = 1, W reading all, R2, R3 and R5 as section 1.3 states them. There
are 7 different outcomes.

| Reading of X -> Y | How many of the 27 | Fewest for the whole list | The candidate |
|---|---|---|---|
| flow, its mirror, and the four that differ from them by sending one of the two watching kinds both ways | 6 | 8 (24 wirings) | meets the list; one over |
| actor, its mirror, and the four that differ from them in the same way | 6 | 9 (26 wirings) | least |
| watching one way as in any of those twelve, a flag passing both ways along a connection | 6 | 8 (54 wirings) | meets the list; one over |
| the signal read and the state check run opposite ways (for one of them: Y reads X's signal, X checks Y's state, X reports to Y), the report one way | 4 | 9 (3 wirings) | does not meet R2 as stated: each member has only D both reading and checking it |
| the same, a flag passing both ways | 2 | 9 (6 wirings) | does not meet R2 as stated |
| the signal and the state both ways, the report one way or both | 3 | 5 (12 wirings; 96 with the report both ways) | meets the list; four over |

Under the six readings in which the signal read and the state check run opposite ways,
if R2 is counted as two readers and two checkers by any nodes, nine are still the fewest
(11 wirings with the report one way, 38 with it both ways), and the candidate meets the
list at `f` = 1, 2 and 3 and is least. A reading in which an arrow is observation only
has no report edge at all, and no wiring then meets R5 as stated.

So a third reading does change the verdict. If an arrow says who observes whom and a flag
passes either way along a connection, the candidate is one over even with actor's
direction of watching. If each of the three is something the tail of the arrow does
(it emits its signal, it checks, it reports), the candidate does not meet R2 as stated.
These readings were run for the whole list at `f` = 1 only, and for the candidate at
`f` = 2 and 3 where it meets the list; the 63 combinations, the other wiring of the work
and the kind by kind labels were not redone for them.

### 2.7 The other choice for R5

**Checked** here (`corrections-1-orders.txt`, its first lines), and independently by the
same reader, who reported it first. Read R5 as "D watches each of A, B, C" and ask for no
report. Then the whole list needs **8 connections under flow and under actor alike**: 24
wirings in 4 shapes at `f` = 1 and 2 and 18 in 3 shapes at `f` = 3 with W reading all, 22
in 11 shapes at `f` = 1 with W reading two. The candidate meets the list and is one over
under both. One of the eight under actor:

```
A -> B, C, D     B -> A, D     D -> A, B, C
```

So "least under actor" is a statement for R5 as the report edge.

## 3. Connections kind by kind

There are 36 possible edges: twelve signal reads, twelve state checks, twelve reports.

### 3.1 How the search is complete, and where Lemma M is used

Every requirement is *monotone*: adding an edge never makes it fail.

- For R1 that is Lemma M of `results-join.md` (**proved** there).
- For *told* it is the same proof with one line added (**proved**): run one schedule in
  the system with fewer edges and in the one with more. By the induction of Lemma M the
  first can run every schedule the second can, and in each round the flagged set of the
  second contains that of the first. So if a round of the second ends with D alive,
  correct and not flagged, the same round of the first does too: a violation of told with
  more edges is a violation with fewer, in the same round.
- R2, R3 and R5 are counts and reachability over edges, which only grow.

For a monotone requirement the sets of the fewest edges are found completely this way.
Every set known to fail gives a *clause*, the edges it lacks: every set that meets the
requirement has at least one of them. The smallest sets that have an edge from every
clause are listed and each is explored. One that fails is grown, edge by edge, to a
greatest failing set, which gives a new clause. When every listed set passes, they are
all the sets of the fewest edges: any other would have an edge from every clause and
would have been listed. Lemma M is relied on at exactly one step: a set that lies inside
a failing set is taken to fail without being explored.

**Two checks that do not use Lemma M.**

- *R1 alone.* Every set of at most six of the 36 edges was explored one by one, W reading
  all, `f` = 1: 2,391,496 sets. None of the 443,704 sets of five or fewer edges has no
  gap, and exactly 24 of the 1,947,792 sets of six have none, as the search found.
- *The whole list.* It needs no search. R2 is eight signal reads and eight state checks
  with the two readers of a node the same two as its checkers, R5 is three reports, and
  the sets of exactly those 19 edges are 81 (three choices of the watcher each node does
  without). All 81 were explored: 78 meet the whole list at `f` = 1 and at 2, 69 at 3,
  and 52 at `f` = 1 where the work reads two, as the search found.

### 3.2 The fewest edges

W reads all. Fewest edges (number of sets, shapes).

| Requirement | `f` = 1 | `f` = 2 | `f` = 3 |
|---|---|---|---|
| R1 | 6 (24, 5) | 7 (24, 4) | 8 (6, 1) |
| R2 | 16 (81, 15) | same | same |
| R3 | 6 (16, 4) | same | same |
| R4 | 0 | 0 | 0 |
| R5 | 3 (1, 1) | same | same |
| R6 | 4 (3, 1) | 5 (9, 2) | 6 (16, 4) |
| R1 + R6 | 6 (3, 1) | 8 (18, 3) | 10 (30, 5) |
| R2 + R5 | 19 (81, 15) | same | same |
| all but R2 | 11 (144, 25) | not run | not run |
| **the whole list** | **19** (78, 14) | **19** (78, 14) | **19** (69, 12) |

W reads two, `f` = 1: R1 6 (4 sets), R6 6 (4), the whole list **19** (52 sets, 26
shapes). At `f` = 2 and 3 all 36 edges together do not meet R1 or R6.

All 63 combinations at `f` = 1, for both wirings of the work, are in `part-a-kinds.txt`.
At `f` = 2 and 3 only the four rows above were run.

**The whole list is 19 edges: R2's sixteen and R5's three, for R2 as stated (section 3.5
has its other choices). Counted** as a lower bound,
**checked** as met. The sets that meet it are: each node watched by exactly two others,
each member reporting to D, and

- not the three sets in which D watches no member (R3 fails: D reaches nobody);
- at `f` = 3, not nine more (R1 fails);
- where the work reads two, A must be one of D's two watchers (27 sets out): when D is
  mutated, A is the only other node the work listens to.

No report edge is needed except the three to D, at any rate up to 3, with either wiring
of the work. In particular no report from D to a member and no report between members is
in any least set.

R1 alone, the six edges: two nodes check each other and read each other's signal, and
each of the other two nodes is checked by one of those two. With W reading all, a flag anywhere
halts the work, so nothing has to be reported.

### 3.3 The candidate's nine arrows, labelled

For each reading the arrows can carry 27 edges. Of those, 19 are enough for the whole
list (three ways with W reading all, two with W reading two: the choice is which two
members watch D). "Must carry" below means the edge is in every such set.

**Arrows read as flow.**

| Arrow | Must carry | Forced by | Nothing on the list needs |
|---|---|---|---|
| A -> B, B -> C, C -> A | the signal read and the state check (the node at the head watches the node at the tail) | R2: the tail's second observer | the report along the cycle |
| A -> D, B -> D, C -> D | the signal read and the state check (D watches the member), and the member's report to D | R2: the member's first observer. R5: the report | nothing: all three kinds are needed |
| D -> A, D -> B, D -> C | on two of the three: the signal read and the state check (the member watches D). Where the work reads two, `D -> A` is one of the two | R2: the coordinator's two observers | D's report to the member, on all three; and everything on the third arrow |

**Arrows read as actor.**

| Arrow | Must carry | Forced by | Nothing on the list needs |
|---|---|---|---|
| A -> B, B -> C, C -> A | the signal read and the state check (the tail watches the head) | R2: the head's first observer | the report along the cycle |
| D -> A, D -> B, D -> C | the signal read and the state check (D watches the member) | R2: the member's second observer | D's report to the member |
| A -> D, B -> D, C -> D | the report to D, on all three. On two of the three: the signal read and the state check (the member watches D). Where the work reads two, `A -> D` is one of the two | R5: the report. R2: the coordinator's two observers | the third member's watch of D |

The spare edges are the same eight in both readings: three reports along the cycle, three
reports from D to its members, and one member's signal read and state check of D. The 19
differ between the readings only in which way the watching runs round the cycle.
Removing any single one of the 19 fails R2 or R5 and nothing else.

With R4wl (naming after a loss, read at the wiring) the arrows must carry 21 edges under
either reading: every member watches D, and the six reports just named are still spare.

### 3.4 The other choice for R3

If "observes" in the restart game is "reads the signal" and not "watches", R3 alone needs
3 edges instead of 6 (three signal reads in a chain or a star from D). The whole list is
unchanged: 19 edges, the same 78 sets (52 where the work reads two), because R2 already
gives every node two watchers and the only sets R3 removes are those in which D watches
nobody.

**Checked** for R3 as used: on all 4,096 wirings under each reading, `restart_game` of
`check_model.py`, with D able to start first, can always restart exactly when D reaches
every node. No disagreement. This is `restart_iff_reached` (Lean) on these rings, and
`ringK_can_restart` is the candidate.

### 3.5 The other choices for R2

R2 as stated takes an observer to be one node that both reads the signal and checks the
state. That is a choice. Between connections under flow or actor it cannot show, because
a connection carries both kinds. Kind by kind it decides the figure.

**Checked** here (`corrections_1.py`, `corrections-1-r2.txt`), and independently by the
reader of `verify-reader\handback.md`, who reported it first. W reads all.

| An observer is | Fewest edges for the whole list | Sets that meet it at `f` = 1, 2, 3 |
|---|---|---|
| one node that both reads the signal and checks the state (R2 as stated) | 19 | 78, 78, 69 |
| a reader or a checker: two readers and two checkers, any nodes | 19 | 5,004, 5,004, 2,469 |
| a signal reader, in R2 and in R3 | 15 | 6,318, 2,340, 96 |

The 15 are eight signal reads, three reports to D and one state check of each monitor.
R1 forces the four checks: a monitor nobody checks is a gap at `f` = 1 (with the check of
D left out of one such set, G1 and G2 are violated in one round). With R3 kept as
"watches" and only R2 read as signal readers the fewest is still 15, in 1,152, 576 and 96
sets. The second and third rows were done by listing all 6,561 sets of the fewest size
(the reads and checks, or the reads and one checker each, chosen freely, and the three
reports) and exploring each, without Lemma M. With the work reading two the second row
has 3,336 sets at `f` = 1.

So "19 edges" is the figure for an observer that both reads and checks, the same node
doing both. What the candidate's arrows must carry under the other two choices was not
worked out.

## 4. The verdict on the candidate

| Reading of an arrow | Fewest connections for the whole list | The candidate (nine) | Others as small |
|---|---|---|---|
| flow | 8 | not least | four shapes of eight (section 2.3) |
| actor, R5 as the report edge | 9 | least | tied with five other shapes (section 2.3) |
| actor, R5 as "D watches each member" | 8 | not least | four shapes of eight (section 2.7) |
| watching one way, a flag passing both ways (`f` = 1) | 8 | not least | 54 wirings of eight (section 2.6) |
| the signal read and the state check opposite ways (`f` = 1) | 9 | does not meet R2 as stated; least if R2 is two readers and two checkers by any nodes | section 2.6 |
| flow, with R4wl | 9 | least | tied with two (section 2.4) |
| actor, with R4wl | 9 | least | tied with two (the same two) |
| a link with no direction | 5 links | not least: it is all six | three wirings of five, one shape |
| kind by kind, an observer both reading and checking | 19 edges | its arrows carry 27; 19 of them are enough | 78 sets of 19 (52 where the work reads two) |
| kind by kind, an observer a signal reader | 15 edges | not worked out on its arrows | 6,318 sets of 15 at `f` = 1 (section 3.5) |

This holds with the work reading all at `f` = 1, 2 and 3 and with the work reading two at
`f` = 1. With the work reading two at `f` = 2 or 3 nothing meets R1 or R6.

**What forces each of the nine.**

| Connection | Under flow | Under actor |
|---|---|---|
| A -> B | R2 (A's second observer is B) | R2 (B's first observer is A) |
| B -> C | R2 | R2 |
| C -> A | R2 | R2 |
| A -> D | R5 (A's report), and R2 (A's first observer is D) | R5 |
| B -> D | R5, and R2 | R5 |
| C -> D | R5, and R2 | R5 |
| D -> A | R2, as one of two: any two of the three give D its two observers | R2 (A's second observer is D) |
| D -> B | the same | R2 |
| D -> C | the same. **One of the three is forced by nothing on the list.** | R2 |

The author's view, that it has two where possible and that the coordinator needs three, is
exact under actor: each member has two observers, the coordinator has three, and the
third is not chosen but follows from R5, since each member's upward arrow is also a watch
of the coordinator. Under flow the coordinator's three observers come from its own three
downward arrows, R5 does not touch them, and two would do.

What the list does not ask for, in one ring, is that the coordinator *tells* its members
anything: no requirement needs a report from D to a member (section 3.3). Whether one
level up needs it is Part C. (Added when Part C was done, and since corrected: only in
part. `results-minimal.md` section 4.1: as one system the upper ring needs reports this
ring does not. Under actor those include the coordinator's reports to its members. Under
flow three reports along the upper cycle are enough, with none from the coordinator. With
scopes no downward report is needed at all; what is needed there is that every member of
the upper ring watches the coordinator.)

## 5. What a mesh buys

The mesh of four is all twelve connections, 36 edges, under either reading.

**Checked.** For each reading, each wiring of the work and `f` = 1, 2, 3, the mesh and
the candidate give the same least number of rounds for G1, for G2 and for told, and the
same answer on R2, R3, R4, R4w, R4wl and R5. They differ on nothing in the list.

| | W reads all: G1, G2, told | W reads two |
|---|---|---|
| candidate, flow or actor | none can be violated at `f` = 1, 2, 3 | none at `f` = 1; at `f` = 2 and 3 G2 in 1 round, G1 in 2 |
| mesh | the same | the same |

The same is true where a report takes a round (`slow_reports`, outside the list): with W
reading all neither has a gap at any of the three rates, and with W reading two both
have told broken in one round at `f` = 1 (W's only checker is A, and A's report reaches D
a round later) and G2 at `f` = 2.

What the mesh has that the candidate has not, none of it on the list:

- *One more observer for each member* (three against two). **Counted,** from
  `results-join.md` section 4.3: if every bad monitor is to be checked in its own round by
  a live correct monitor, `f` checkers each are needed, so the mesh gives that at three
  faults per round and the candidate at two. G1 asks for less, and the candidate meets G1
  at three.
- *The price,* which is the author's point: in the mesh every node reads three signals,
  checks three states, reports to three and hears from three. In the candidate a member
  does two of each and the coordinator three. Twelve connections against nine, 36 edges
  against 27, or against the 19 that are needed.

## 6. What this rests on

- **Three implementations agree. Checked.** G1 and G2 for all 49,152 systems of section 2
  were computed by `mr_model.py` (written for this work on `fast_join.py`), by
  `fast_join.py` itself and by `verify-impl\model.py` (written by another hand from the
  specification files). No answer differs. `mr_model.py` also reproduces all 5,658
  recorded answers of the join catalogue (`crosscheck-join-catalogue.txt`).
- **Told has one author so far.** It is a new judgement (`model-spec-scope.md`, written
  for a second implementation to be compared). A second, plain implementation by the same
  hand (`scope_naive.py`) agrees on the catalogue cases it was run on
  (`results-minimal.md` section 6). It enters the result in one place only: R6. And R6 changes no count: the
  least wirings for the whole list are those of R2 + R5 less the few that R3 or R1
  removes.
- **The kind by kind search relies on Lemma M** for every row of section 3.2 except the
  whole list and R1 at `f` = 1, which were also done by listing (section 3.1).
- **No independent reader has checked this part.** The brief rules out starting other
  agents, so the usual pass by a fresh verifier was not made.

## 7. Not settled in Part A

- Which reading of an arrow the drawing means. The verdict turns on it, and nothing in
  the model can decide it.
- Whether R4 is meant as a count or at the wiring. As a count it forces nothing. Read at
  the wiring after a loss it forces the candidate's ninth connection under flow.
- R6 for a ring that has a ring above it. Here it is "D is told". What reaches the upper
  ring, and whether the downward reports that nothing here needs are needed there, is
  Part C.
- Rates above three. With four monitors nothing holds at four (Theorem 0 of `results.md`).

## Files for Part A

| File | What it is |
|---|---|
| `mr_model.py` | the model, with scopes and told; built on `fast_join.py` |
| `mr_ring.py` | the ring, the two readings, the requirements, the complete search for least sets |
| `part_a1.py`, `part-a-connections.txt`, `part-a-connections.json`, `part-a-connections-summary.json` | section 2: all 4,096 wirings, every combination |
| `part_a2.py`, `part-a-kinds.txt`, `part-a-kinds-summary.json` | section 3: kind by kind, and the labelled arrows |
| `part_a3.py`, `part-a-checks.txt` | the two other implementations, the mesh where reports take a round, loads, R4wl, executions |
| `part_a_brute.py`, `part-a-brute.txt` | the two checks that do not use Lemma M |
| `corrections_1.py`, `corrections-1-readings.txt`, `corrections-1-r2.txt`, `corrections-1-orders.txt` | sections 2.6, 2.7 and 3.5, added by `corrections-1.md` |
| `mr_crosscheck.py`, `crosscheck-join-catalogue.txt` | `mr_model.py` against the join catalogue |
| `part_a_recheck.py`, `part-a-recheck.txt` | section 2's table recomputed with `mr_model.py` as it stood at the end of the whole work: 49,152 systems, none different |
