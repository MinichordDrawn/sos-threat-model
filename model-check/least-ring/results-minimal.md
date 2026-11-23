# The Least Ring Of Four, And The Same Ring One Level Up: Results

**Verdict on the candidate: it turns on what an arrow is taken to carry, and on one
choice each in R2 and R5. Of the 27 readings in which an arrow carries all three kinds of
edge, the candidate is least under six, one connection over under twelve, short of R2 as
stated under six, and four over under three.** Each kind can run along the arrow,
against it, or both ways. Two of the readings are worked through in full (every rate,
both wirings of the work, every combination of requirements); all 27 are run for the
whole list at one fault per round with the work reading all (section 2).

- *actor* (`X -> Y`: X observes Y and reports to Y), its mirror, and four close to them:
  nine connections are the fewest that meet the whole list, and the candidate is among
  the wirings that have nine. Under actor itself it is one of six shapes that have nine.
  This is with R5 read as the member's report edge to the coordinator. With R5 read as
  the coordinator watching each member, eight are enough under actor too, and the
  candidate is one over.
- *flow* (`X -> Y`: what X shows and says goes to Y), its mirror, and four close to them:
  eight are enough and the candidate is one over. Under flow itself it is the eight plus
  one of the coordinator's downward arrows, which nothing on the list forces in a single
  ring.
- *Watching one way, a flag passing both ways along a connection* (six readings): eight
  are enough; the candidate meets the list and is one over.
- *The signal read and the state check run opposite ways,* as when each of the three is
  something the tail of the arrow does: it emits its signal, it checks, it reports (six
  readings). The candidate does not meet R2 as stated, because each member then has only
  the coordinator both reading and checking it. If R2 is counted as two readers and two
  checkers by any nodes, the candidate meets the list and is least, at nine.
- *The signal and the state both ways* (three readings): five are enough.

Kind by kind the list needs 19 edges when an observer is one node that both reads the
signal and checks the state, which is how R2 is stated here, and the candidate's arrows
carry them with eight to spare. It needs 15 when an observer is a signal reader. Under
flow and under actor the count comes from R2 and R5 alone.

**Verdict on the goal: the structure repeats, with four conditions the goal does not
give, and "always minimal" holds only in a narrower sense than it says.**

- *What holds.* Three candidate rings under a top coordinator, the three ring coordinators
  in a cycle, is a system with no gap at one, two and three faults per round when each
  ring's work reads its four monitors, the same rate as one ring, at every number of
  levels when every monitor is in a boundary of its own (**proved**; **checked** at 13 and
  at 40 monitors). Judged scope by scope, a
  fault in one ring halts that ring's work, the other two go on working and the upper ring
  holds a flag for the ring at fault: at one fault per round that holds at thirteen
  monitors (**checked**: every reachable state when nothing more lands in a ring that has
  halted, every execution of six rounds when it may), and the halt half of it holds at up
  to three faults per round at every number of levels when every monitor is in a boundary
  of its own (**proved**).
- *Condition 1: a flag must carry its scope.* In the model as it is a flag is one bit,
  and a fault anywhere halts all three rings. "A halt that stays in one ring" needs the
  flag to say which ring it is for, and the work to halt only on a flag for a scope that
  covers it. That is the extension `model-spec-scope.md`.
- *Condition 2: the order the goal gives has a gap, and with the top coordinator first
  there is none.* Grown in the order the goal gives (each new ring coordinator first, the
  top coordinator last), there is a gap at one fault per round under either reading: the
  second ring's coordinator arrives with nobody to check it, or with nobody to report to.
  Grown with the top coordinator first, which is "coordinator first" applied to the upper
  ring too, there is no gap at one, two or three faults per round as one system (**proved**
  and **checked**), and none scope by scope at one (**checked**). That is what is
  established, among the ten orders tried (section 5.1). It is not that the top
  coordinator must be first. Under actor it cannot be last in any order, as one system:
  three rings without it have a gap at one fault per round, and its join can be left
  untaken. Under flow it can be last, as one system: two top-last orders have no gap at
  one, two or three (**checked**), rings 2 and 3 arriving whole in one step, and their two
  coordinators arriving in one step before the members. Those are sufficient cases, not a
  classification of the orders. With scopes "told" is violated in two rounds under either
  reading in the first of them, the one top-last order checked with scopes; that it is
  violated in every top-last order is **argued** (section 5.1). And it need not be
  strictly first: in the same step
  as the second ring's coordinator, or as the whole second ring, is enough (**checked**).
- *Condition 3: one level up the coordinator's connections are all needed.* The
  connection that nothing forces in one ring (the coordinator's third downward arrow, or
  the third member's watch of the coordinator) is forced in the upper ring, where each
  member stands in front of work that hears nobody else: without it the top coordinator's
  own fault leaves one ring working. And as one system the upper ring needs the reports
  that no single ring needs: the top coordinator's to the ring coordinators, or those
  along the upper cycle.
- *Condition 4: the rate is one fault per round for everything beyond the halt.* At two
  faults per round the top coordinator can be left with nobody that watches it and then
  fail unseen, in two rounds; the work has halted by then. "The ring above is told" fails
  at two faults per round, and at forty monitors it fails at one, in three rounds.
- *"Always minimal."* Nine per ring, 36 for thirteen nodes, 3(n-1) in general, is the
  least among structures built as rings of rings in which each ring meets the list by
  itself, under actor with R5 read as the report edge. It is not the least for thirteen
  nodes as one system: 33 connections meet R1 to R5 under flow and under actor when R2 is
  counted over the whole system, and 26 do under flow with one coordinator.

The candidate and the goal are in `brief.md`. This note is an
extension of the model check and of its first extension in `join\` (`model-spec.md`, `model-spec-join.md`,
`results.md`, `results-join.md`). It uses the same four kinds of evidence:

- **Checked.** Every reachable state of a small, fully specified system was explored, by
  `mr_model.py`. Where the text says "every execution of at most N rounds", the search was
  bounded and says nothing about longer executions.
- **Proved.** An argument that holds for every system of a stated class, of any size.
- **Counted.** Arithmetic.
- **Argued.** Reasoning in prose that is neither proved for a class nor checked.

A system has a *gap* if some execution violates G1 or G2. Its *rate* is the greatest `f`
at which it has no gap. "Watches" means both reads the signal of and checks the state of.

## 1. The setting

**The ring.** Four monitors A, B, C and D, each in a boundary of its own, and a work
process W. D is the coordinator. The work *reads all* (checked by all four, halting on
all four) or *reads two* (checked by A, halting on A and D), as in `results-join.md`
section 2. Systems are plain: no substrates, switches or window, work halts on silence,
the gate is in place, reports arrive within the round.

**An arrow.** The candidate's nine arrows are `A -> B -> C -> A`, `D -> A, B, C` and
`A, B, C -> D`. An arrow is taken to carry all three kinds of edge, in one of two ways:

| Reading | X -> Y carries |
|---|---|
| **flow** | Y reads X's signal, Y checks X's state, X reports to Y (Y watches X; X reports to Y) |
| **actor** | X reads Y's signal, X checks Y's state, X reports to Y (X watches Y; X reports to Y) |

The mirror images of the two give the same systems with the arrows reversed, and the
candidate reversed is the candidate renamed (**proved**, `part-a.md` section 1.2). Under
flow the candidate is the "cycle, checking coordinator" of `results-join.md`, edge for
edge. In both readings D and each member watch each other and report to each other.

These two are the readings worked through in full. They are not the only fair ones:
each of the three kinds can run along the arrow, against it, or both ways, which makes
27, and section 2 gives what each does to the verdict.

**The requirements,** and the choices made where the list leaves one. Each is given with
the other choice in `part-a.md` section 1.3.

| | In the model |
|---|---|
| R1 | no execution violates G1 or G2 at `f` = 1 (also reported at 2 and 3) |
| R2 | every monitor is watched by at least two others. A watcher is one node that both reads the signal and checks the state. That is a choice; the others are in section 2 |
| R3 | D reaches every other node along "watches"; by `restart_iff_reached` (Lean) that is exactly when the ring can always restart with D the member that starts first |
| R4 | a count, as the Lean statements have it: three nodes to name the faulty one, four to still name it after a loss. Every wiring of four meets it. Read at the wiring (a node names only what it watches) it is marked R4w, and after a loss R4wl |
| R5 | each member has a report edge to D. The other choice, D watches each member, is in section 2 |
| R6 | for one ring: G2, and *told*: in a round at whose end something is bad, if D is alive and not bad then D is flagged. For rings of rings: section 4.2 |

## 2. Part A. The least ring of four

`part-a.md` is the full account. In brief.

**Connections as the drawing has them. Checked** on all 4,096 wirings, each reading, each
wiring of the work, `f` = 1, 2, 3 (49,152 systems, on which three implementations give
the same G1 and G2).

| | flow | actor |
|---|---|---|
| R2 alone | 8 | 8 |
| R5 alone | 3 | 3 |
| R2 + R5 | 8 | 9 |
| R1 alone; R3 alone; R6 alone (`f` = 1) | 4; 3; 4 | 4; 3; 4 |
| everything but R2 (`f` = 1) | 4 | 6 |
| **the whole list** | **8** (24 wirings, 4 shapes) | **9** (26 wirings, 6 shapes) |
| the candidate among the least | no | yes, for the 16 combinations that hold R2 and R5 |

The least numbers for the whole list, 8 and 9, are the same at `f` = 2 and 3 with the
work reading all (under flow six of the 24 wirings fall out at `f` = 3), and at `f` = 1
with the work reading two. The counts beside them are not the same there: with the work
reading two it is 22 wirings in 11 shapes under flow and 26 in 14 under actor. With the
work reading two nothing meets R1 or R6 at `f` = 2.

**Counted.** Under flow the upward arrow `X -> D` is also X's first observer, so a member
needs one arrow more and D two: 3 + 3 + 2 = 8. Under actor the upward arrow is a watch of
D, so D has three observers and each member needs two arrows pointing at it:
3 + 6 = 9. The author's view, two where possible and three for the coordinator, is exact
under actor, where the third follows from R5. Under flow the coordinator's three observers
are its own three downward arrows and two would do.

**Kind by kind. Checked,** complete by Lemma M, and for the whole list also by listing
all 81 candidates without Lemma M. The whole list needs **19 edges**: eight signal reads
and eight state checks (two watchers each, R2) and three reports to D (R5). That figure
is for R2 as stated, a watcher being one node that does both; the other choices are
below. 78 sets of 19
meet it with the work reading all at `f` = 1 and 2, 69 at `f` = 3, 52 with the work
reading two at `f` = 1. R1 alone needs 6 edges, 7 and 8 at `f` = 2 and 3; R3 alone 6 (3
if "observes" is "reads the signal"); R6 alone 4.

**The candidate's nine connections.** What each carries, and what forces it. "Spare"
means no requirement on the list needs it, in one ring, at any rate up to three.

| Connection | Under flow it carries | Under actor it carries | Forced by |
|---|---|---|---|
| A -> B | B watches A. *Spare:* A reports to B | A watches B. *Spare:* A reports to B | the watch: R2 |
| B -> C | C watches B. *Spare:* B reports to C | B watches C. *Spare:* B reports to C | the watch: R2 |
| C -> A | A watches C. *Spare:* C reports to A | C watches A. *Spare:* C reports to A | the watch: R2 |
| A -> D | D watches A; A reports to D | A watches D; A reports to D | flow: R2 and R5. actor: the report R5, the watch R2 (two of the three) |
| B -> D | D watches B; B reports to D | B watches D; B reports to D | the same |
| C -> D | D watches C; C reports to D | C watches D; C reports to D | the same |
| D -> A | A watches D. *Spare:* D reports to A | D watches A. *Spare:* D reports to A | flow: R2, two of the three. actor: R2 |
| D -> B | B watches D. *Spare:* D reports to B | D watches B. *Spare:* D reports to B | the same |
| D -> C | C watches D. *Spare:* D reports to C | D watches C. *Spare:* D reports to C | the same |

The 27 edges under either reading hold 19 that are needed and eight that are not: the
three reports along the cycle, D's three reports to its members, and one member's watch
of D (under flow that is the whole of one downward arrow; under actor it is the watching
half of one upward arrow). Removing any one of the nine connections opens no gap: R1, R3
and R6 force none of them. R4, as a count, forces none.

**Further readings of an arrow. Checked** here, and independently by the reader of
`verify-reader\handback.md`, who reported it first. Every wiring, `f` = 1, the work
reading all, R2, R3 and R5 as stated. An arrow carries all three kinds, and each kind
runs along the arrow (Y reads X's signal; Y checks X's state; X reports to Y), against
it, or both ways: 27 readings, with 7 different outcomes.

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

**R2's other choices. Checked** here, and independently by the same reader, who reported
it first. R2 as stated takes an observer to be one node that both reads the signal and
checks the state. Between connections under flow or actor that choice cannot show,
because a connection carries both. Kind by kind it decides the figure.

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

**R5's other choice. Checked** here, and independently by the same reader, who reported
it first. R5 is read here as the member's report edge to D. Under the other choice, "D
watches each member", the whole list needs 8 connections under flow and under actor
alike: 24 wirings in 4 shapes at `f` = 1 and 2 and 18 in 3 at `f` = 3 with the work
reading all, 22 in 11 shapes at `f` = 1 with the work reading two. The candidate meets
the list and is one over. So "least under actor" is for R5 as the report edge.

**The verdict.** Under actor, with R5 as the report edge: least, tied with five other
shapes of nine. Under flow: not least; four shapes of eight, one of them the candidate
without one downward arrow. Under the further readings and the other choices of R2 and
R5: as the three paragraphs above give it.
If naming after a loss is read at the wiring (R4wl), nine are the fewest under both
readings and the candidate is one of three shapes; kind by kind the arrows then carry 21.
With an arrow read as a link in both directions, five links are enough and the candidate
is all six.

**The mesh of four** gives the same result as the candidate for every requirement, both
wirings of the work, `f` = 1, 2 and 3, and also where reports take a round. It costs
twelve connections against nine, and every node watching three against two.

## 3. Part B. Wider rings

`k` members in a cycle under one coordinator K, `k` + 1 monitors.

**Counted,** for every `k`: under flow R2 and R5 need 2`k` + 2 connections, under actor
3`k`, kind by kind 5`k` + 4 edges. The cycle with a coordinator has 3`k`.

**Checked,** `k` = 3, 4, 5:

| | `k` = 3 | `k` = 4 | `k` = 5 |
|---|---|---|---|
| the cycle with a coordinator: connections | 9 | 12 | 15 |
| least for the whole list, flow | 8 (24 wirings, 4 shapes) | 10 (486 wirings, 24 shapes) | 12 (10,240 wirings, 97 shapes) |
| least for the whole list, actor | 9 (26, 6 shapes) | 12 (1,203 of 1,296; 59 shapes) | 15 (the cycle meets it; of 2,000 drawn at random from the 100,000 wirings of fifteen that meet R2 and R5, 1,789 meet the whole list) |
| the cycle with a coordinator is least | actor: yes. flow: no | actor: yes. flow: no, two over | actor: yes. flow: no, three over |
| kind by kind, 5`k` + 4 edges on the cycle's arrows meet the list | 19: yes | 24: yes | 29: yes |
| rate, work reads every monitor | 3 | 4 | 5 |
| rate, work reads two | 1 | 1 | 1 |
| a member watches, is watched by | 2, 2 | 2, 2 | 2, 2 |
| the coordinator watches, is watched by, hears from | 3, 3, 3 | 4, 4, 4 | 5, 5, 5 |

The whole list is met at `f` = 1, 2 and 3 with the work reading all, and at `f` = 1 with
the work reading two, in each case. The meshes: of four, 12 connections, every node
watching three, rate 3; of five, 20 connections, every node watching four, rate 4; of
six, 30 and five, rate 5.

**Proved,** for every `k` and both readings: the cycle with a coordinator, the work
reading every monitor, has no gap exactly when `f` is at most `k`. The coordinator and
each member watch and report to each other, so Theorem J of `results-join.md` applies up
to `f` = `k`, and at `f` = `k` + 1 every monitor can be mutated (Theorem 0). For the mesh
of `n` the rate is `n` - 1 (`mesh_exact`, Lean).

So a wider ring under one coordinator is still least under actor with R5 read as the
report edge, tied with more and more
others, and under flow falls further behind (`k` - 2 over). Its rate rises with `k` only
because the work has more halt sources. A member's load stays at two. The coordinator's
grows with `k`: it watches, is watched by and hears from every member. That is the price
the author names.

## 4. Part C. One level up

Three candidate rings, ring `i` being A`i`, B`i`, C`i` with coordinator D`i` and work
W`i`, and a top coordinator T. The upper ring is `D1 -> D2 -> D3 -> D1`, `T -> D1, D2, D3`
and `D1, D2, D3 -> T`. Thirteen monitors, 36 connections. Each W`i` reads its own ring:
all four, or A`i` and D`i`.

### 4.1 As one system

The model as it is: any flag at a halt input halts a work process.

**Checked.** G1, G2 by three implementations where there is no gap.

| | `f` = 1 | `f` = 2 | `f` = 3 | `f` = 4 |
|---|---|---|---|---|
| work reads all, flow or actor | no gap | no gap | no gap | G2 in 1 round |
| the same, each base ring whole in one boundary | no gap | no gap | no gap | a gap in 1 round |
| work reads two | no gap | G2 in 1 round | G2 in 1 round | G2 in 1 round |

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate A1, B1, C1, D1 | those four bad; every other monitor flagged; W2, W3 halted; W1 working |

Breaks G2 (`f` = 4, work reads all). Every halt source of W1 is mutated: P8b of
`results.md`.

| Round | Environment | End of round |
|---|---|---|
| 1 | stop the boundary of ring 1, of ring 2, of ring 3; mutate T | T bad; twelve monitors stopped; nothing flagged; all work halted on silence |

Breaks G1 (`f` = 4, each base ring whole in one boundary).

With each base ring in one boundary, one step loses a ring. At `f` = 1 the loss of ring 1
is read by T and by a neighbouring coordinator, the flag reaches the other rings, all
three work processes halt and the model ends.

**Against `nested` and the Lean statements.** `nested` of `check_model.py` is two base
rings and an upper ring of the two coordinators and a third member, with no coordinator
above; its base coordinators read signals only and its work reads two. **Checked** here:
no gap at `f` = 1 with or without the ring boundaries, which is `nested_noGap` and
`nested_boundaries_noGap` (Lean); at `f` = 2, G2 in one round. The tower differs in three
ways: a third ring, an upper ring that has its own coordinator, and coordinators that
check state. With the work reading two it has the same rate as `nested`, 1. With the work
reading all four it has rate 3, because the work then has four halt sources.

**Which connections the tower depends on. Checked,** one connection removed, the work
reading all.

| Removed | As one system, `f` = 1, 2, 3 | With scopes (section 4.3), `f` = 1 |
|---|---|---|
| any one arrow of a base ring | no gap | nothing violated |
| an arrow of the upper ring's cycle | no gap | nothing violated |
| all three arrows of the upper ring's cycle (33 connections left) | no gap | nothing violated |
| `D1 -> T`, flow | no gap | told in 2 rounds |
| `D1 -> T`, actor | no gap at 1; G2 in 1 round at 2 and 3 | G2 in 2 rounds, G1 in 3 |
| `T -> D1`, flow | no gap | G2 in 2 rounds, G1 in 3 |
| `T -> D1`, actor | G2 in 1 round | told in 2 rounds |

| Round | Environment | End of round |
|---|---|---|
| 1 | stop D3 | ring 3's flag raised everywhere; W3 halted; W1, W2 working; ring 3 closed |
| 2 | mutate T | T bad; ring 2's monitors flagged for the top scope; W2 halted; W1 working |

Breaks G2 of the top scope (flow, without `T -> D1`, `f` = 1). D1 does not watch T, and
the report that would have come round the cycle from D3 does not come.

So the six connections between T and the ring coordinators are each needed, the upper
ring's cycle is needed by neither judgement, and in a base ring no single arrow is.

**Kind by kind. Checked,** complete over the spare edges: by Lemma M for the half "as
one system", and for the half "with scopes" by its scoped form, Lemma M-scope of section
4.2. Give every ring, upper ring included, only its 19 edges (76 in all).

- *As one system* there is a gap at `f` = 1: a fault in ring 1 is flagged in ring 1 and
  reported to T, and nothing passes it on. The fewest edges that close it are all in the
  upper ring. Under flow, three reports, at `f` = 1, 2 and 3: along the upper cycle, or
  from T down to a coordinator, in four mixtures. Under actor, T's three reports to the
  ring coordinators and one report along the cycle at `f` = 1 (four edges), and at `f` = 2
  and 3 T's three reports and the third coordinator's watch of T (five).
- *With scopes,* `f` = 1, under either reading, the fewest to add is the third
  coordinator's watch of T (two edges; one, its state check, if only G1 and G2 are asked
  and not told). No report is needed except the upward ones.

So the reports that a single ring never needs are what carries a flag between rings when
any flag is meant to halt everything, and the watch of the coordinator that a single ring
does not need is what a scope needs one level up.

### 4.2 The extension that judges scope by scope

`model-spec-scope.md` is the whole of it, written to be implemented from. In brief:

- Every process has a *scope*, where a fault at it lands. A scope has its *work*: by
  default the work processes of that scope, or a list. Here ring `i`'s four monitors and
  W`i` are of scope `ring i`, whose work is W`i`; T is of scope `top`, whose work is W1,
  W2 and W3.
- A flag is raised *for* the scope of the process detected, and keeps that scope as it is
  reported on. A work process halts on a flag at one of its halt inputs only if the flag
  is for a scope that covers it. It still halts on the silence of a halt input.
- **G2 of a scope** is violated when something of that scope is bad and work of that
  scope takes a work step. **G1 of a scope**, which is what the first judgement becomes,
  is violated when something of that scope is bad and no live correct monitor holds a
  flag for that scope.
- **Told** is violated for a scope when something of it is bad, some monitor on the
  scope's list is alive and correct, and none of the listed monitors holds a flag for the
  scope. For ring `i` the list is the rest of the upper ring: the other two coordinators
  and T. The top scope has no list. Like G1 and G2 of a scope, told is judged only in a
  round at whose end something of the scope is bad and the scope is still open. So a stop
  alone is never a violation of any of the three, and for a base ring of the tower, under
  the hypotheses of section 4.3, told is judged in the round of the ring's first fault,
  if that fault leaves something bad, and in no other, because the ring's scope closes in
  that round. If the first fault is a stop with nothing bad, told is judged in no round.
- **Spill** is violated when a work process halts and nothing in any scope that covers
  it is faulty. "The other two rings' work goes on" is "no spill".
- A scope *closes* when a live correct monitor holds its flag and its work has halted. A
  closed scope is no longer judged. That is the earlier model's "the model ends at the
  first complete response", scope by scope. With `freeze`, no fault lands on a process of
  a closed scope and no step joins one; without it faults go on landing on its processes,
  unjudged for that scope.
- The model ends as before: all work halted and some live correct monitor flagged.
- With one scope it is the earlier model.

**Two choices** the brief leaves. *Where a ring coordinator's own fault lands:* in its own
ring's scope (it is a member of that ring; its ring's work halts; the upper ring finds
out by watching it). The other choice, that it lands in the scope above, is given below.
*What "told" asks:* that one of the upper ring's other monitors holds the flag, if one can.

**The assumption** all of this rests on: *a fault in one scope can affect another scope's
work only through connections that are watched.* In the model a fault is a state bit of
one process and nothing else changes with it, so the assumption is built in. Nothing here
proves it of any real system.

**Lemma M-scope (more edges never hurt, scope by scope). Proved,** for any two systems of
`model-spec-scope.md` with no window, in which either no two monitors share a boundary
and nothing runs on a substrate, or `freeze` is false, that have the same processes,
scopes, work, lists, halt inputs and `freeze`, and differ only in that the second has
more signal-read, state-check or report edges. For each scope and each of G1, G2 and told, and for spill,
the least number of rounds to violate it in the second is at least that in the first.
The argument is the reader's (`verify-reader\handback.md`, check 4). I went through it
and agree with it.

*Proof.* In this class an environment step, where it is enabled, does the same in both
systems to which processes are alive, bad or present. With no shared boundary and no
substrate every step acts on one process or on one joining group, whatever is frozen; and
without `freeze` no step looks at what is closed. (With `freeze` and a shared boundary or
substrate this is false: `stop-boundary` and `fail-substrate` then pass over the frozen
processes, and which are frozen depends on the flags, which depend on the edges.) Run one
schedule in both systems. By induction on rounds,
the second's flags for every scope, its halted set and its closed set contain the
first's: detection and propagation only gain from more edges, a work process that sees a
reason to halt in the first sees it in the second, and a scope that closes in the first
closes in the second. With `freeze`, a step enabled in the second is enabled in the
first, because the second has frozen at least as much. A state that is responded in the
first is responded in the second. So every schedule the second can run, the first can
run. If a round violates G1, G2 or told of a scope in the second, then in the first that
scope is open too, the same processes are bad, no more monitors hold its flag, and a work
process that steps in the second has not halted and steps: the same round violates it in
the first. For spill: a halt on a flag for a covering scope is never a spill, since such
a flag was raised on a fault in that scope and faults stay. So a spill in the second is a
halt on the silence of a halt input, and the same process, which has not halted in the
first, halts there on the same silence in the same round, with the same processes
faulty. ∎

It does not hold for added halt-input edges. `example/1` and `example/4` of the
catalogue differ by one halt input, and the second has a spill in one round where the
first has none. The searches of this note add no halt input.

Nor does it hold outside that class, where it was first stated here. **Checked** here
and independently; the reader of `verify-corrections\handback.md` found it. With `freeze`
true and four monitors in one boundary, one more signal read brings G1 of a scope from 4
rounds to 3. The system: `f` = 1; monitors x, m1, m2, m3, m4, z, zp, z2, y and work w; m1
to m4 share a boundary and every other monitor has its own; scopes p (x and m1), q (m2,
m3, m4), r (y), o (z, zp, z2) and one for w; z and zp read m1's signal, m2, m3 and m4
check y's state, and w takes its halt from m1. The second system has one edge more: z2
reads x's signal.

| Round | Environment | End of round in the second system | End of round in the first |
|---|---|---|---|
| 1 | stop x | z2 flagged for p; p has no work, so p closes; w working | nothing flagged; p open; w working |
| 2 | stop the boundary of m1 to m4 | m1 is frozen, so only m2, m3, m4 stop; nothing new flagged; w working | all four stop; z and zp flagged for p; w halted on m1's silence; the model ends |
| 3 | mutate y | y bad; its three checkers are stopped; nobody holds a flag for r | |

Breaks G1 of r in round 3 in the second system. In the first, no execution of at most 3
rounds breaks it (every one was explored), and the least is 4: stop m2; stop m3; stop m4;
mutate y. With `freeze` false both systems give 4.

The two places this note uses the lemma are in the narrower class. The towers of section
4.1 have thirteen monitors in thirteen boundaries and no substrate. The ring with a fifth
node of section 5.3 has five monitors in five boundaries, no substrate and no `freeze`.

### 4.3 With a scope per ring

**Checked,** thirteen monitors, the work reading all. Entries are least rounds; "-" is
"not violated", in every reachable state or within the bound the row gives. Flow and
actor give the same entries throughout.

| | G2, every scope | G1, base scopes | G1, top scope | told | spill |
|---|---|---|---|---|---|
| `f` = 1, freeze: every reachable state | - | - | - | - | - |
| `f` = 1, no freeze: every execution of at most 6 rounds | - | - | - | - | - |
| `f` = 2, freeze: every reachable state | - | - | 2 | 2 | - |
| `f` = 3, freeze: every execution of at most 2 rounds | - | - | 2 | 1 | - |
| `f` = 4 | 1 | | | | |

Without freeze the bounded searches at `f` = 2 (every execution of at most 2 rounds) and
`f` = 3 (1 round) give the same entries as far as they reach. With the work reading two:
nothing is violated at `f` = 1 (every reachable state with freeze, every execution of at
most 4 rounds without), and at `f` = 2 G2 of a ring is violated in one round, as in one
ring.

So at one fault per round: **a fault inside one base ring halts that ring's work, the
other two rings' work goes on, and the upper ring is told.** At two and three the first
two parts still hold and the third does not.

| Round | Environment | End of round |
|---|---|---|
| 1 | stop D1, stop D2 | flags for rings 1 and 2 held by their own members, by ring 3's monitors and by T; W1, W2 halted; W3 working; rings 1 and 2 closed |
| 2 | stop D3, mutate T | T bad; a flag for ring 3 held by its members; W3 halted; nobody holds a flag for the top scope |

Breaks G1 of the top scope (`f` = 2). The three monitors that watch T are the three ring
coordinators. Each can fail in a way that is answered and contained, and when all three
have, T is unobserved. G2 holds: every work process had halted. In the model as one
system the first round would have ended everything.

| Round | Environment | End of round |
|---|---|---|
| 1 | stop D2 | a flag for ring 2 held by every live monitor; W2 halted; W1, W3 working; ring 2 closed |
| 2 | stop T, mutate A1 | A1 bad; B1, C1, D1 flagged for ring 1; W1 halted; W3 halted on T's loss; D3 is alive and correct and holds no flag for ring 1 |

Breaks told of ring 1 (`f` = 2). D1 reports to D2 and to T, and both are gone. At `f` = 3
the same three steps fit in one round.

**Proved,** for a tower of any number of levels, either reading, every monitor in a
boundary of its own, with or without `freeze`, a ring coordinator's own fault landing in
its own ring's scope, at every `f` up to 3 when each ring's work reads its four monitors
(up to 1 when it reads two). The boundary hypothesis is needed by statement 1: with a
base ring whole in one boundary statement 1 fails, by the last table of this section. The
proof of statement 2 uses statement 1, and so uses the hypothesis; that statement 2
itself needs it is not shown.

1. *G1 and G2 of a base scope are never violated, and the scope closes in the first round
   in which a fault lands in it.* Before that round the ring's four monitors are alive
   and correct. In it at most three of them are faulty. If the coordinator is faulty,
   every live correct member watches it and is flagged for the scope, and one exists. If
   the coordinator is alive and correct it watches every member, so it is flagged if a
   member is faulty; and if no monitor of the ring is faulty the work is bad and its
   checkers flag. So a live correct monitor of the ring holds the scope's flag. The work
   takes its halt from every monitor of the ring, so it halts on that flag or on a silent
   monitor, without a work step. (Where the work reads two and `f` is 1, the one fault
   leaves A or D alive, correct and flagged by the same three cases.) In particular the
   ring's own coordinator, when it is alive and correct, always holds the flag.
2. *G2 of an upper scope is never violated.* Let U be the upper coordinator at fault and
   W a work process beneath it that has not halted. By 1 no fault has landed in W's ring.
   Follow the coordinators from U down to W's own. If all are alive and correct, the
   first watches U and is flagged for U's scope, each reports to its members, and the
   last is a halt input of W. Otherwise take the lowest faulty one. If it is W's own
   coordinator, 1 applies in this round. If not, the coordinator below it watched it in
   the round it failed, raised the flag for its scope, which covers W, and the flag ran
   down to W's coordinator then.
3. *There is no spill,* in any system in which each work process takes its halt only from
   monitors of scopes that cover it: it halts on the silence of such a monitor, which is
   then faulty, or on a flag for a covering scope, which was raised on a fault in it.

At `f` = 4 the four monitors of a ring can be mutated in one round and its work goes on:

| Round | Environment | End of round |
|---|---|---|
| 1 | mutate A1, B1, C1, D1 | those four bad; every monitor of rings 2 and 3 and T flagged for ring 1; W1, W2, W3 all working |

Breaks G2 of ring 1 (`f` = 4). W2 and W3 working is as it should be. The upper ring knows
and cannot stop W1: W1 takes its halt from its own ring only.

**Argued,** for the thirteen-monitor tower at `f` = 1 without `freeze`, beyond the six
rounds checked: G1 of the top scope and told cannot be violated. T watches all three ring
coordinators, so the first fault at any of them flags T. If T then fails, each ring whose
coordinator is still alive and correct has it flagged for the top scope and halts, and
the rings whose coordinators failed earlier had halted then, so the model ends with a
flag held. And a fault in ring `i` reaches T directly: by D`i`'s report, or, if D`i` is
the fault, by T's own watch.

**The other choice,** a ring coordinator's own fault landing in the scope above it.
**Checked,** freeze, every reachable state at `f` = 1 and at 2. At `f` = 1 nothing is
violated. At `f` = 2 G1 and G2 of every scope hold and told is violated in one round. G1
of the top scope is not violated under this choice, because a ring coordinator's fault is
then a fault of the top scope: it halts all three rings and the model ends, so the
coordinators cannot be lost one at a time. That is also its price: one coordinator's fault
halts every ring, and the halt no longer stays in a ring.

**With each base ring whole in one boundary. Checked,** freeze. At `f` = 1, every
reachable state: nothing is violated. The loss of a whole ring is read by T and by a
neighbouring coordinator, which raise the flag for that ring, and only that ring's work
halts. At `f` = 2, every execution of at most 3 rounds: G1 of the top scope and told in 2
rounds, as without the boundaries, G2 not violated, and G1 of a base scope in 3:

| Round | Environment | End of round |
|---|---|---|
| 1 | stop the boundary of ring 1, of ring 2 | eight monitors stopped; flags for rings 1 and 2 held by ring 3's monitors and by T; W1, W2 halted; W3 working |
| 2 | stop the boundary of ring 3, stop T | every monitor stopped; W3 halted on silence; no live monitor holds a flag (the stopped monitors of ring 3 and T still hold theirs) |
| 3 | mutate W3 | W3 bad; nothing alive to flag it |

Breaks G1 of ring 3 (`f` = 2, each base ring in one boundary). Four steps over two
rounds stop all thirteen monitors, and nothing is left to flag the mutation. It is a
loss as wide as the system. Neither part of Theorem 0 of `results.md` applies to it as
stated: `f` is less than the number of monitors, and no one step stops them all.

### 4.4 What reaches the upper ring

**Checked,** by the executions in `part-c-forced-flat.txt`.

| The fault | What the upper ring gets | Halted |
|---|---|---|
| a member of ring 1, or its work, goes bad | D1 is flagged for ring 1 and reports it to T and round the cycle; T reports it to the other coordinators, they to their members. Every live correct monitor of the thirteen ends the round holding a flag for ring 1 | W1 only |
| D1 goes bad | nothing is sent: a bad monitor shows nominal. T and one neighbouring coordinator see D1's state by their own check and raise the flag for ring 1 themselves; ring 1's members do the same | W1 only |
| D1 stops | the same, by its signal | W1 only |
| T goes bad | the three coordinators see it by their own check and raise a flag for the top scope | W1, W2, W3 |

What reaches the upper ring is one flag: "something of ring 1 is at fault". It does not
say which node, nor that the work has halted. D1's own signal and state do not change
when its ring halts, so the flag is the only thing that tells. And when D1 is the fault
the upper ring is not told at all: it finds out, which is why T's watch of each
coordinator is among the connections the tower depends on.

### 4.5 Least at this size

**Counted.** A tower of `L` levels has (3^`L` - 1)/2 rings and `n` = (3^(`L`+1) - 1)/2
monitors, so (`n` - 1)/3 rings: 4 for 13, 13 for 40. At nine connections a ring that is
36 and 117, 3(`n` - 1) in general. Kind by kind at 19 a ring it would be 76 and 247,
but an upper ring needs more than 19: two more with scopes, three to five as one system
(section 4.1).

**Does 3(n-1) follow from Part A alone?** The count does, as arithmetic. That it is
*least* follows from Part A only in this sense, and under actor with R5 read as the
report edge: among structures built as
rings of rings, each ring of four meeting the list by itself, none has fewer, because no
ring of four has fewer than nine. It does not follow that each ring should have nine
under flow (eight meet the list in one ring), and Part A is silent on wirings of
thirteen that are not rings of rings.

**What it does not show. Checked,** as one system, the work reading all, `f` = 1, 2, 3
(no gap in each case), with R2, R3 and R5 tested on the wiring:

| Wiring of thirteen | Connections | R2 over the whole system | R3 | R5 |
|---|---|---|---|---|
| the tower | 36 | yes | yes | ring by ring |
| the tower without the upper ring's cycle, flow or actor | 33 | yes | yes | ring by ring |
| twelve nodes in one cycle, each `-> T`, and `T ->` two of them; flow | 26 | yes | yes | to the one coordinator T |
| twelve nodes in one cycle under T both ways (the wide ring, `k` = 12); actor | 36 | yes | yes | to the one coordinator T |

- *The 33.* A ring coordinator is watched by its own three members and by T. That is
  two observers and more, counted over the whole system. The upper ring's cycle gives it
  a second observer *inside the upper ring*, which R2 asks for only when it is applied
  ring by ring. Neither judgement needs the cycle (section 4.1). So thirteen nodes as one
  system meet R1 to R5 with 33, under either reading, R5 being each node's report to its
  own coordinator.
- *The 26.* Under flow, with every node reporting to one coordinator, R2 and R5 need two
  arrows out of each node: 26. The wiring above has no gap at `f` = 1, 2 or 3 as one
  system. Its price is the one the author names: T watches twelve nodes and hears from
  twelve.
- *Under actor, with R5 read as the report edge, with one coordinator nothing has fewer
  than 36.* **Counted:** twelve
  upward arrows, which are watches of T, and two arrows into each of the twelve others.
  So under actor with that reading of R5 the flat ring and the ring of rings tie at
  3(`n` - 1), and what the ring
  of rings buys is that no node watches more than three.

*Each ring at its least under flow does not survive the level above.* Give every ring
eight connections, dropping one downward arrow in each (32 in all). As one system there
is no gap at `f` = 1, 2, 3. With scopes, at `f` = 1, G2 of the top scope is broken in two
rounds, by the execution of section 4.1: the dropped arrow in the upper ring is one of
T's.

### 4.6 One more level, and every level

**Proved,** for a tower of any number of levels, either reading, as one system, every
monitor in a boundary of its own: there is no gap exactly when `f` is less than the
number of halt sources of the work, so the rate is 3 with the work reading all four and 1
with it reading two. *Proof.* A coordinator and each of its members watch each other and
report to each other, and the rings are joined through the coordinators they share, so
such pairs connect all the monitors. Every work process has a state checker. Theorem J of
`results-join.md` then gives no gap while `f` is less than the number of halt sources and
of monitors. At `f` equal to the number of halt sources, they are all mutated in one
round and the work steps (P8b of `results.md`). ∎

**Proved,** at `f` = 1, with each base ring whole in one boundary, any number of levels
from two: no gap. The four conditions (a) to (d) of Theorem S hold, and the loss of a
whole base ring is read by the coordinator above it, from which report edges reach every
monitor outside the ring without passing through it, which is the boundary clause of
`theorem_S_wide` (Lean). The conclusion comes from `theorem_S_wide` alone: `theorem_S`
is for plain systems, and a system with a ring in one boundary is not plain.

What was evaluated by program is narrower than that. `sufficient_f1` of `check_model.py`
tests conditions (a) to (d) and nothing else; it does not look at boundaries. It was run
on towers of 1 to 4 levels (4, 13, 40 and 121 monitors), under each reading and each
wiring of the work: (a) to (d) hold in all sixteen. The boundary clause was not
evaluated by program. It is the argument of the paragraph above, and it is for two
levels or more: for one level, a single ring whole in one boundary, it cannot hold, and
there is a gap (Theorem 0 of `results.md`, part 2).

**Checked,** forty monitors (nine rings, three middle coordinators E1, E2, E3, and T),
as one system: no gap at `f` = 1, 2 and 3 with the work reading all; G2 in one round at
`f` = 2 with the work reading two; no gap at `f` = 1 with each base ring in one boundary.
At `f` = 4 the execution of section 4.1 applies.

**With scopes, every level.** The three statements of section 4.3 are proved for every
number of levels, with every monitor in a boundary of its own. What is not: told, and G1
of an upper scope.

The scopes at forty monitors are the tower's, as at thirteen: one for each base ring,
one for each middle coordinator, whose work is all the work beneath it, and one for T,
whose work is all the work. The list of a base ring is the other two coordinators of the
ring above it and that ring's coordinator (for ring 3: D1, D2 and E1). The list of a
middle coordinator's scope is the other two middle coordinators and T. The top scope has
no list. `model-spec-scope.md` does not fix any of this; `mr_tower.py` builds it.

**Checked,** forty monitors, freeze, `f` = 1, every execution of at most three rounds:
G1 and G2 of every scope are not violated, there is no spill, and **told is violated in
three rounds**.

| Round | Environment | End of round |
|---|---|---|
| 1 | stop D1 | ring 1's flag raised; W1 halted; ring 1 closed |
| 2 | stop E1 | the flag for E1's scope raised; W2, W3 halted (W1 already) |
| 3 | mutate A3 | A3 bad; B3, C3, D3 flagged for ring 3; D3 reports to D1 and to E1, both stopped; D2 is alive and correct and holds no flag for ring 3 |

Breaks told of ring 3 (flow, `f` = 1). The ring above ring 3 has lost its coordinator and
the one neighbour D3 reports to, one fault at a time, each answered. At thirteen monitors
the same cannot happen at `f` = 1, because the loss of T halts everything and the model
ends. So told at one fault per round is a result for two levels and not for three.

## 5. Part D. Getting there by joins

The thirteen-monitor tower with only ring 1 present at the start. Everything else is
late and joins by steps of `model-spec-join.md`, with one addition (`model-spec-scope.md`
X1): a work process may be late, so that W2 and W3 can both join. Joins and faults are
interleaved in every order the environment can choose, a monitor may arrive bad, and only
the tower's own connections exist: an edge comes into force when both its ends are
present.

### 5.1 The orders

| Order | What it is |
|---|---|
| author | D2, then A2, B2, C2 in any order, then W2; then ring 3 the same way; then T |
| author-loose | the same, but ring 3 may start before ring 2 is complete |
| top-after-ring-2 | ring 2 as above; then T; then ring 3 |
| whole | ring 2 whole in one step; ring 3 whole in one step; then T |
| **top-first** | T; then ring 2 (D2, members, W2); then ring 3 |
| top-first-loose | T; then the two rings in any interleaving |
| whole-top-first | T; then ring 2 whole in one step; then ring 3 whole |

**Checked.** As one system, the first round that violates a judgement. With scopes
(freeze), least rounds over all scopes at `f` = 1, every reachable state.

| Order | As one system, flow | As one system, actor | With scopes, `f` = 1, flow | With scopes, `f` = 1, actor |
|---|---|---|---|---|
| author | G1 and G2 in 1 round, at every rate | G2 in 2 rounds at `f` = 1, in 1 at 2 and 3 | G1 in 1, G2 in 5, told in 1 | G1 in 7, G2 in 11, told in 2 |
| author-loose | G1 and G2 in 1 | G1 and G2 in 1 | G1 in 1, G2 in 5, told in 1 | G1 in 1, G2 in 5, told in 1 |
| top-after-ring-2 | G1 and G2 in 1 | G2 in 2 at `f` = 1 | G1 in 1, G2 in 5, told in 1 | G1, G2 not violated; told in 2 |
| whole | G2 in 1 | G2 in 1 | G1, G2 not violated; told in 1 | G1, G2 not violated; told in 1 |
| **top-first** | **no gap at `f` = 1, 2, 3** | **no gap at `f` = 1, 2, 3** | **nothing violated** | **nothing violated** |
| top-first-loose | no gap at `f` = 1, 2, 3 | no gap at `f` = 1, 2, 3 | nothing violated | nothing violated |
| whole-top-first | no gap at `f` = 1, 2, 3 | no gap at `f` = 1, 2, 3 | nothing violated | nothing violated |

**The order the goal gives has a gap at one fault per round, at its first step.**

| Round | Environment | End of round |
|---|---|---|
| 1 | D2 joins already bad | D2 bad; nothing flagged; W1 working |

Breaks G1 and G2 as one system, and G1 of ring 2 with scopes (flow, `f` = 1). Under flow
`D1 -> D2` makes D2 watch D1. Nothing watches D2 until its members or D3 or T arrive.

| Round | Environment | End of round |
|---|---|---|
| 1 | D2 joins | nothing flagged; W1 working |
| 2 | A2 joins already bad | A2 bad; D2 flagged; W1 working |

Breaks G2 as one system (actor, `f` = 1). Under actor D1 watches D2 and reports to it,
and D2 reports to nobody that is there. Ring 1 is protected from nothing in ring 2.

With scopes that second execution is no violation of G1 or G2: W1 working while ring 2
is at fault is what a scope allows. Told is violated, and under actor the order still
has a gap, later:

| Round | Environment | End of round |
|---|---|---|
| 1 to 5 | D2, A2, B2, C2, W2 join, one a round | nothing flagged; W1, W2 working |
| 6 | stop D2 | D2 stopped; A2, B2, C2 and ring 1 flagged for ring 2; W2 halted; ring 2 closed |
| 7 | D3 joins already bad | D3 bad; nobody holds a flag for ring 3 |

Breaks G1 of ring 3 (actor, `f` = 1, with scopes). D3's only watcher in the upper ring,
until T comes, is D2. The rounds 8 to 11 bring A3, B3 and C3 in bad and then W3, which
works: G2 of ring 3.

**With the top coordinator first there is no gap.** T is the upper ring's coordinator,
and "a ring joins coordinator first" (`results-join.md`, the conditions of its verdict)
applied to the upper ring puts T before the upper ring's second member. Then every new
ring coordinator arrives with T watching it, watched by it and reporting both ways.

**What the rows with scopes include.** A scope whose work has not yet joined closes as
soon as a live correct monitor holds its flag (`model-spec-scope.md`, X7). So a ring that
is hit while it is being built is closed at once. With `freeze`, which these rows have,
nothing more can then join that ring, and a ring that must wait for it never joins.
"Nothing violated" under the top-first orders includes those executions, in which growth
stops. It is not a statement that growth completes.

**What the table does and does not establish.** Among the seven orders, the goal's order
has a gap and the top-first orders have none. It does not follow that the top coordinator
must be first. Three more orders were run. The first was reported by the reader of
`verify-reader\handback.md` and is recomputed here; all three are **checked** here and
independently, as one system at `f` = 1, 2 and 3, and with scopes and freeze at `f` = 1
in every reachable state.

| Order | As one system, flow | As one system, actor | With scopes, `f` = 1, flow and actor |
|---|---|---|---|
| both-whole: rings 2 and 3 whole, together in one step; then T | no gap at `f` = 1, 2, 3 | G2 in 1 round at each rate | G1, G2 not violated; told in 2 rounds |
| top-with-D2: T and D2 in one step; then A2, B2, C2, then W2; then D3, its members, W3 | no gap at `f` = 1, 2, 3 | no gap at `f` = 1, 2, 3 | nothing violated |
| top-with-ring-2: T and the whole of ring 2 in one step; then ring 3 whole | no gap at `f` = 1, 2, 3 | no gap at `f` = 1, 2, 3 | nothing violated |

So the condition, as it now stands:

- *Under actor the top coordinator cannot be last in any order, as one system.* Three
  rings with their coordinators in a cycle and no T have G2 broken in one round at
  `f` = 1, 2 and 3 (**checked**):

  | Round | Environment | End of round |
  |---|---|---|
  | 1 | mutate D1 | D1 bad; A1, B1, C1 and ring 3's four flagged; W1, W3 halted; W2 working |

  Under actor D1 is the one coordinator that reports to D2. In any order that has T last,
  the joins can bring all three rings in with T's join left untaken, and a round of joins
  alone raises no flag. So either there is a gap before that, or this execution follows
  (**proved** from the check, for every order with T last).
- *Under flow it can be last, as one system, in at least two orders.* Three rings without
  T have no gap at `f` = 1, 2 and 3 (**checked**), and order both-whole has none. Nor has
  a second top-last order, found by the reader of `verify-corrections\handback.md` and
  recomputed here: D2 and D3 in one step; then the six members one at a time in any
  order; then each work process once its three members are present; then T. It has no gap
  at `f` = 1, 2 and 3 in every reachable state (**checked**: `mr_model.py` and
  `verify-impl\model.py`, both run by me, finished it at all three rates, with 1,732,
  17,733 and 118,732 states; the reader reports the same from two programs at `f` = 1 and
  2 and from one at 3). These are sufficient cases and not a classification of the
  orders. Two top-last orders that do have a gap under flow: order `whole` of the table
  above, the rings whole but one after the other, with G2 broken in one round while ring
  3 is absent; and the goal's order, where D2 arrives with nobody to check it.
- *With scopes, top-last leaves told violated,* in two rounds under either reading in
  order both-whole (**checked**, for that one order): the two rings join with D2 already
  bad, which closes ring 2; then A1 is mutated, D1 is flagged and reports to D2 and to
  nobody else, and D3 is alive, correct and not told. For every order with T last it is
  **argued**, by the same reader, and not run: bring all three rings in, mutate D2, which
  closes ring 2, then mutate A1; D1 reports to D2 only, and D3 is not told.
- *It need not be strictly first.* In the same step as D2, or as the whole of ring 2, is
  enough.

### 5.2 Which statements of `results-join.md` cover each step

**Checked,** by evaluating the conditions on every set of present processes the joins can
reach (`part-d-steps-fifth.txt`).

| Order | Sets of present processes | Theorem J's condition holds in | Theorem S's holds in (flow, actor) | Some monitor has no state checker |
|---|---|---|---|---|
| author | 20 | 2 (ring 1 alone; all thirteen) | 11, 2 | flow: D2 on arrival |
| author-loose | 101 | 2 | 83, 2 | flow: D2; actor: D3 if it comes before D2 |
| top-after-ring-2 | 20 | 11 | 11, 11 | flow: D2 on arrival |
| whole | 4 | 2 | 3, 2 | none |
| top-first, top-first-loose, whole-top-first | 20, 101, 4 | all | all | none |

- *top-first and its two variants.* **Proved** as one system up to `f` = 3: Theorem J
  covers every step, since in every set of present processes the monitors are connected by
  pairs that watch and report to each other, and a work process is present only with its
  four halt sources. At `f` = 1 Theorem S in every set of present processes covers it
  too. This is the first three rows of the table in `results-join.md` section 8 with a
  ring of rings in place of two rings.

  The class is wider than the one those statements name. Theorem J and "Theorem S in
  every set of present processes" are stated in `results-join.md` for plain systems with
  joins, which have late monitors and the model's one joiner. The grown tower has two
  late work processes, which only X1 of `model-spec-scope.md` allows. Their proofs carry
  over as they stand. Each takes the first round with a fault and uses only the set of
  processes then present: that its monitors are connected by mutual pairs (or meet (a)
  to (d)), and that each work process then present has a present state checker and more
  than `f` present halt inputs. Theorem J asks besides for more than `f` initial
  monitors, which is met: ring 1's four are there from the start and `f` is at most 3.
  Neither proof counts how many work processes are late or asks by which step one joined. With that said the result is **proved**; it is also
  **checked**.
- *The author's order, D2's arrival.* Under flow it is "a monitor nobody checks"
  (`results-join.md` section 3, **proved** there to give a gap at `f` = 1), and condition
  2 of that file's verdict: a monitor must not join before a monitor that checks it.
  Under actor D2 is checked and read by D1, but has no report target present, so Theorem
  L's hypothesis fails. Of the least attachment of a joining ring's coordinator (section
  8 there: checked, read and reporting to one; and watching one that reports back) D2 has
  exactly the second half under flow. Under actor it has neither half whole: it is
  checked and read but does not report, and it is reported to but does not watch. The
  execution above under actor (D2 joins; A2 joins bad; D2 is flagged; W1 goes on working)
  is the one `results-join.md` section 4.2 gives for a missing "N reports to X": the flag
  exists and goes nowhere. Section 8's own execution, "nothing comes back to ring B", is
  not this one. It is the mirror case: a fault in the old ring, which the new ring's work
  does not hear of.
- *No statement of `results-join.md` covers* any step of the author's order between ring
  1 alone and the complete tower, under actor, nor nine of them under flow. Under flow
  Theorem S's conditions return once all three coordinators are present, because the
  cycle then closes: at `f` = 1, three rings without T have no gap as one system.
- *With scopes* none of that file's theorems applies as it stands: they are about halting
  everything. Section 4.3's three statements cover a ring once it is whole. The steps in
  between are checked, at `f` = 1, and not proved.

At two faults per round with scopes, during growth, G1 of some scope is violated within
two rounds under every order (every execution of at most 3 rounds was explored). Under
the three top-first orders it is the top scope, in one round: while ring 1 is the only
ring, D1 is T's only watcher, and `stop D1`, `mutate T` leaves T's fault unseen. G2 is
not violated in those three rounds under the top-first orders. So growth with scopes is
a result for one fault per round.

What the model cannot say here is what the author leaves to the builder: attaching
through a temporary mesh, or moving a member. Both need an edge that is later removed,
and nothing leaves in this model.

### 5.3 The least attachment of a fifth node

One late monitor N joins the candidate ring. W reads the four that were there. N may
arrive bad. The list is applied to the five: N needs two watchers (R2), must be reached
by D (R3), must report to D (R5), and D must be told (R6).

**Checked,** all 256 attachments as connections, each reading, `f` = 1, 2, 3 with the
work reading all and `f` = 1 with it reading two; and kind by kind over the 24 edges
between N and the four, complete by Lemma M and, for told, by Lemma M-scope of section
4.2.

| | flow | actor |
|---|---|---|
| R1 alone | 1 connection: `N -> X`, any X | 1 connection: `X -> N`, any X |
| the whole list | **2**: `N -> D` and `N -> X`, X a member (3 attachments) | **3**: `N -> D` and two arrows into N (6 attachments) |
| kind by kind, the whole list | **5 edges**: two of the four watch N (four edges), and N reports to D | the same 5 |
| kind by kind, R1 alone | 1 edge: one of the four checks N's state | the same |

In the author's notation, the candidate and the least attachment of N:

```
flow                                  actor
A -> B -> C -> A                      A -> B -> C -> A
D -> A, B, C                          D -> A, B, C
A, B, C -> D                          A, B, C -> D
N -> D                                N -> D
N -> A                                A, B -> N      (or A, D -> N)
```

Under flow `N -> D` is N's report to D and D's watch of N at once, and `N -> A` gives the
second watcher. Under actor `N -> D` is the report (and N's watch of D), and N's two
watchers are two more arrows. These are the wider ring's counts again: two per added
member under flow, three under actor.

| Round | Environment | End of round |
|---|---|---|
| 1 | N joins already bad | N bad; nothing flagged; W working |

Breaks G1, G2 and told (N with no connection, `f` = 1): `results-join.md` section 4.1.

## 6. What the results rest on

- **G1 and G2 by three implementations.** `mr_model.py` (this work, built on
  `fast_join.py`), `fast_join.py` and `verify-impl\model.py` (another hand, from the
  specification files) agree on all 49,152 systems of Part A and on the thirteen-monitor
  tower as one system where it has no gap. `mr_model.py` reproduces all 5,658 recorded
  answers of the join catalogue.
- **Scopes, told and spill by two implementations of one author, and since by one of
  another party** (the item on independent checks, below). `mr_model.py` and
  `scope_naive.py`, the second written from the three specification files with no code
  from the first. They give the same answers on 417 of the catalogue's 465 cases, which
  is every case the plain one was run on to the end; the other 48 are too large for it
  (the towers with scopes and no freeze, forty monitors with scopes, growth with scopes
  under the orders that have many reachable states). That is a check on slips, not an
  independent opinion. The independent one has since been made: the item on independent
  checks, below.
- **The catalogue.** `systems-minimal.json` holds 465 systems: the specification's nine
  examples, and those behind Parts A to D. 120 of them carry a bound on rounds
  (`max_rounds`), because exploring every state is too large or, where there is a gap,
  pointless; their answers are for executions within the bound. On the 302 cases that
  have one scope or none and no bound, `fast_join.py` and `verify-impl\model.py` give the
  same G1 and G2 as `results-minimal.json` (`catalogue-others.txt`).
- **Lemma M** carries the kind by kind searches, and Lemma M-scope of section 4.2 the
  halves of them made with scopes (sections 4.1 and 5.3). Two of them were repeated
  without either:
  R1 alone over all 2,391,496 sets of at most six edges, and the whole list over its 81
  candidates.
- **Lean statements are cited, not redone:** `restart_iff_reached`, `ringK_can_restart`,
  `ring3_cannot_restart` (R3); `one_or_two_cannot_name`, `three_or_more_can_name`,
  `cannot_name_after_loss`, `can_name_after_loss` (R4); `theorem_S`, `theorem_S_wide`
  (sections 4.6 and 5.2); `mesh_exact` (section 3); `nested_noGap`,
  `nested_boundaries_noGap` (section 4.1). They were read in `Challenge.lean`, where each
  is a statement; the proofs were not opened.
- **Independent checks, made after this note was first written.** An implementation
  written from the three specification files alone, by another party, gives the same
  answers on all 465 cases of the catalogue and on the added systems
  (`verify-impl\handback.md`; on the added systems it was run by me). An independent
  reader recomputed the tables and the counterexamples with a
  program of their own (`verify-reader\handback.md`). A second reader checked the
  corrections (`verify-corrections\handback.md`). What none of them checked, from their
  own lists:
  - thirteen monitors with scopes at `f` = 3 beyond two rounds, and without freeze beyond
    six rounds at `f` = 1, two at 2 and one at 3;
  - forty monitors with scopes beyond three rounds at `f` = 1 and one round at 2 and 3,
    except runs confined to one chain and random runs;
  - whether a wiring of thirteen has fewer than 33 or 26 connections;
  - the rows of `part-a-kinds.txt` beyond those printed in `part-a.md` section 3.2;
  - for the further readings of an arrow, the 63 combinations and the kind by kind
    labels, and readings in which different arrows carry different things;
  - Lemma M-scope in its narrower class beyond reading the proof and 3,800 random pairs;
  - `nested`, `sufficient_f1` and `restart_game` of `check_model.py` as programs, and the
    Lean proofs: the statements were read;
  - the parts of the model that no system of the catalogue uses (the joiner, substrates,
    switches, slow edges, the window, the order without the gate), beyond the examples of
    the specifications and 400 random systems on which the implementer's two programs
    agree;
  - the author's list and goal in their own words, which were not in the readers'
    folders.
- **Bounds.** Thirteen monitors with scopes: complete at `f` = 1 and 2 with freeze; two
  rounds at `f` = 3; without freeze six rounds at `f` = 1, two at 2, one at 3. Forty
  monitors with scopes: three rounds at `f` = 1, one at `f` = 2. Growth with scopes:
  complete at `f` = 1, three rounds at `f` = 2. Part B at `k` = 5 under actor: a sample.
  A bounded search says nothing about longer executions; the statements of section 4.3
  that are marked proved do not depend on them.

## 7. Not settled

- **Which reading of an arrow the drawing means.** The verdict on the candidate turns on
  it. Nothing in the model decides it. The verdict also turns on one choice each in R2
  (what an observer is) and in R5 (the member's report edge, or D watching each member),
  and nothing in the model decides those either.
- **Whether R4 is a count or a property of the wiring.** As a count it forces nothing in
  a ring of four. Read at the wiring after a loss it forces the ninth connection under
  flow.
- **Where a ring coordinator's own fault lands.** Here, in its own ring's scope. The
  other choice is reported: it gives the same at one fault per round, and at two it keeps
  G1 of the top scope and makes a coordinator's fault halt every ring.
- **G1 of an upper scope, and told, at every level.** G1 of the top scope fails at two
  faults per round at thirteen monitors. Told fails at one at forty. No statement for
  every level is proved for either, and none was found that could be.
- **Scopes at `f` = 3 beyond two rounds,** and without freeze beyond the rounds listed.
- **Growth with scopes** is checked at `f` = 1 and not proved, and at `f` = 2 has the
  one-watcher stage of section 5.2.
- **A second faults in a halted ring, a join into a halted ring, lifting a halt,
  repairing, removing a connection, a temporary mesh, moving a member.** None is
  modelled. With `freeze` the first two are left out; without it they happen and are not
  judged. Whether a halted ring can be rebuilt or rejoined is the question that would
  need them.
- **The assumption of section 4.2** is an assumption.
- **Rates above three** in a ring of four, and anything where reports take a round beyond
  the one comparison of Part A.

## Files

All in `least-ring\`.

| File | What it is |
|---|---|
| `brief.md` | the request |
| `part-a.md` | Part A in full, delivered first |
| `results-minimal.md` | this note |
| `model-spec-scope.md` | the extension of the specification: late work processes, scopes, told, spill, freeze, a bound on rounds |
| `systems-minimal.json`, `results-minimal.json` | the catalogue of systems the results rest on, in the specification's format, and its answers |
| `mr_model.py` | the model with the extension, on bit masks |
| `scope_naive.py` | a plain second implementation of the three specification files |
| `mr_ring.py`, `mr_tower.py`, `mr_examples.py`, `mr_show.py` | the ring and its requirements, the complete search for least sets, the tower, the specification's examples, printing |
| `part_a1.py`, `part_a2.py`, `part_a3.py`, `part_a_brute.py` and their `part-a-*.txt`, `.json` | Part A |
| `part_b.py`, `part_b2.py`, `part-b.txt`, `part-b-k5.txt` | Part B |
| `part_c.py`, `part-c-one.txt`, `part-c-forced-flat.txt`, `part-c-scoped.txt`, `part-c-scoped-rest.txt`, `part-c-kinds.txt`, `part-c-forty.txt` | Part C |
| `part_d.py`, `part-d-grow.txt`, `part-d-steps-fifth.txt` | Part D |
| `make_catalogue.py`, `make-catalogue.txt` | the catalogue and its answers |
| `catalogue_others.py`, `catalogue-others.txt` | G1 and G2 of the catalogue by `fast_join.py` and `verify-impl\model.py`, where they apply |
| `naive-compare.txt`, `naive-part-*.txt`, `naive-extra.txt` | `scope_naive.py` against the catalogue's answers |
| `part_a_recheck.py`, `part-a-recheck.txt` | Part A's table recomputed with `mr_model.py` as it stands at the end |
| `corrections-1.md`, `*.before-corrections-1.md` | every change made after the two independent checks, as before and after text, and the three files as they were |
| `corrections_1.py`, `corrections-1-readings.txt`, `corrections-1-r2.txt`, `corrections-1-orders.txt`, `corrections-1-added.txt` | the recomputations behind those corrections: the 27 readings, R2's and R5's other choices, the three further join orders |
| `systems-minimal-added.json`, `results-minimal-added.json` | 39 systems the corrections rest on that the catalogue does not have, and their answers: the 36 of corrections 1, with the fifteen-edge system replaced by corrections 2 by one that meets the whole list, and three more for the second top-last order of section 5.1. The catalogue and its answers are unchanged |
| `corrections-2.md`, `*.before-corrections-2.*`, `corrections_2.py`, `corrections-2-lemma.txt`, `corrections-2-order.txt`, `corrections-2-added.txt` | the second and last set of corrections, as before and after text; the files as they were; the recomputations behind them |
| `mr_crosscheck.py`, `crosscheck-join-catalogue.txt` | `mr_model.py` against the join catalogue |
