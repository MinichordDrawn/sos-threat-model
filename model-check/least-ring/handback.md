# Hand-back: the least ring of four, and the same ring one level up

Everything is in `«WORK»\sos-minimal-ring\`. `part-a.md` was delivered first; `results-minimal.md` is the full write-up. Nothing outside that folder was changed. No git, no other agents, no web.

## Verdict on the candidate

**It depends on what an arrow carries, and the two defensible readings give different answers.**

- **actor** (`X -> Y`: X reads Y's signal, checks Y's state, reports to Y). Nine connections are the fewest that meet the whole list. The candidate is **least, tied with five other shapes** (26 wirings of nine, six shapes up to renaming of the members). Every one of its nine connections is forced, by R2 or R5 and by nothing else.
- **flow** (`X -> Y`: Y reads X's signal, checks X's state, X reports to Y). **Not least: eight are enough** (24 wirings, four shapes). One of them is the candidate without one of `D -> A, B, C`. Two of those three are forced jointly by R2 (the coordinator's two observers); the third is forced by nothing on the list in a single ring.
- In both readings **the count comes from R2 and R5 alone** (counted: 3+3+2 = 8 under flow, 3+6 = 9 under actor). R1, R3 and R6 remove a few least wirings and add no connection. R4, as the Lean statements have it, is a count of nodes and forces nothing.
- **Kind by kind: 19 edges** (eight signal reads and eight state checks for R2, three reports to D for R5). The candidate's arrows carry 27 under either reading; the eight spare are the same eight: three reports along the cycle, D's three reports to its members, one member's watch of D.
- **The mesh of four buys nothing on this list**: same result for every requirement, both wirings of the work, f = 1, 2, 3, and also where reports take a round.
- One reading the list does not make changes this: if "still naming after a loss" is read at the wiring (a node names only what it watches), nine are the fewest under both readings and the candidate is one of three least shapes. Reported, not relied on.

The author's view, two where possible and three for the coordinator, is exact under actor (the third follows from R5) and not under flow.

## Verdict on the goal

**The structure repeats, with four conditions the goal does not give; "always minimal" holds only in a narrower sense.**

- **What holds.** Three candidate rings under a top coordinator T has no gap at f = 1, 2, 3 as one system when each ring's work reads its four monitors, the same rate as one ring, **at every number of levels** (proved by Theorem J of `results-join.md` plus P8b; checked at 13 and 40 monitors). Judged scope by scope at f = 1 on thirteen monitors: a fault in one ring halts that ring's work, the other two go on, and the upper ring holds a flag for the ring at fault (checked).
- **Condition 1: a flag must carry its scope.** In the model as it is a flag is one bit and a fault anywhere halts all three rings. This needed an extension (`model-spec-scope.md`).
- **Condition 2: the top coordinator joins first, not last.** The order the goal gives has a gap at f = 1 at its first step. Under flow: D2 arrives bad and nothing checks it (G1 and G2, one round). Under actor: D2 joins, A2 arrives bad, D2 is flagged and W1 goes on working (G2, two rounds). With T first, which is "coordinator first" applied to the upper ring, there is no gap at f = 1, 2, 3 as one system (proved by Theorem J, checked) and nothing violated scope by scope at f = 1 (checked, every reachable state).
- **Condition 3: one level up the coordinator's connections are all needed.** Removing `T -> D1` under flow breaks G2 of the top scope at f = 1 in two rounds (stop D3; mutate T; W1 keeps working). The connection nothing forces in one ring is forced in the upper ring. Kind by kind, an upper ring needs more than 19: the third coordinator's watch of T with scopes, and three to five report edges as one system.
- **Condition 4: beyond the halt, the rate is one.** At f = 2, G1 of the top scope breaks in two rounds (stop D1, D2; then stop D3, mutate T: nobody that watches T is left; all work had halted). "Told" breaks at f = 2 in two rounds, at f = 3 in one, and **at forty monitors at f = 1 in three rounds** (stop D1; stop E1; mutate A3).
- **"Always minimal."** Nine per ring, 36 for thirteen, 3(n-1) in general, is least only among rings of rings in which each ring meets the list by itself, under actor. As one system fewer suffice: **33** under either reading (the tower without the upper ring's cycle, R2 counted over the whole system), and **26** under flow with one coordinator (twelve in a cycle, each `-> T`, `T ->` two of them), both with no gap at f = 1, 2, 3. Under actor with one coordinator nothing has fewer than 36 (counted). Each ring at its flow least (eight) fails the scope judgement at the upper ring.

## Part A (`part-a.md`)

- **Checked**: all 4,096 wirings as connections, each reading, each wiring of the work, f = 1, 2, 3 (49,152 systems), against all 63 combinations. Three implementations agree on G1 and G2 for all 49,152 (`mr_model.py`, `fast_join.py`, `verify-impl\model.py`).
- **Checked, complete by Lemma M**: kind by kind over 36 edges. Two rows repeated without Lemma M: R1 alone over all 2,391,496 sets of at most six edges (none of five or fewer, exactly 24 of six), and the whole list by listing its 81 candidates (78 at f = 1 and 2, 69 at 3, 52 with the work reading two).
- **Counted**: the lower bounds from R2 and R5.
- **Proved**: the naming rule at the wiring (a rule exists exactly when every node has a watcher and no two nodes are each watched only by the other); told is monotone in edges.
- With the work reading two, nothing meets R1 or R6 at f = 2 (mutate A and D).
- Choices made, each with the other choice reported: R3 "observes" is "watches"; R4 is a count; R5 is the report edge; R6 for one ring is G2 plus "D is flagged whenever it can be".

## Part B

- **Counted** for every k: 2k+2 connections under flow, 3k under actor, 5k+4 edges kind by kind.
- **Checked** k = 3, 4, 5: the cycle with a coordinator is least under actor (k = 4: 1,203 wirings of twelve, 59 shapes) and k-2 over under flow. Rate k with the work reading every monitor, 1 with it reading two. A member watches two and is watched by two at every k; the coordinator watches, is watched by and hears from k.
- **Proved** for every k: rate exactly k. Mesh of five: rate 4, every node watching four.
- k = 5 under actor was sampled (1,789 of 2,000 drawn wirings meet the list), not listed in full.

## Part C

- **As one system, checked**: thirteen monitors, no gap at f = 1, 2, 3 with the work reading all, with or without each base ring in one boundary; gap at f = 4; with the work reading two, G2 at f = 2. Consistent with `nested` and with `nested_noGap`, `nested_boundaries_noGap`.
- **The extension** (`model-spec-scope.md`): a scope per process, flags that carry their scope, G1 and G2 per scope, told, spill, closing a scope, `freeze`, a bound on rounds, late work processes. One scope is the earlier model.
- **With scopes, checked**: f = 1 nothing violated (every reachable state with freeze; every execution of six rounds without). f = 2: G2 holds, G1 of the top scope in 2, told in 2. f = 3 (two rounds): told in 1. No spill anywhere.
- **Proved, every level, f up to 3**: G1 and G2 of a base scope are never violated; G2 of an upper scope is never violated; no spill.
- **What reaches the upper ring**: one flag for the ring at fault, reported by its coordinator. When the coordinator is itself the fault nothing is sent, and T and a neighbour find out by watching it.
- **Assumption stated, not proved**: a fault in one scope affects another scope's work only through watched connections.
- **Every level**: as one system proved (above); f = 1 with ring boundaries proved via `theorem_S` and `theorem_S_wide`. Told and G1 of an upper scope are not proved for every level, and told fails at forty.

## Part D

- **Checked**: seven join orders, joins and faults interleaved, newcomers allowed to arrive bad. The three top-first orders have no gap; the four top-last orders have one at f = 1 (table in section 5.1).
- **Coverage by `results-join.md`**: Theorem J's condition holds in every reachable set of present processes for the top-first orders, and in only 2 of 20 for the author's order. Under flow D2's arrival is "a monitor nobody checks".
- With scopes at f = 2 growth is not safe under any order: while ring 1 is the only ring, D1 is T's only watcher.
- **Fifth node**: least attachment for the whole list is two connections under flow (`N -> D`, `N -> A`), three under actor (`N -> D`, `A, B -> N` or `A, D -> N`), five edges kind by kind.

## Part E

`results-minimal.md`, `model-spec-scope.md`, `systems-minimal.json` (465 systems, 120 with a bound on rounds), `results-minimal.json`.

## What the results rest on, and what I could not do

- `mr_model.py` reproduces all 5,658 answers of the join catalogue, and Part A's 49,152 systems were recomputed with its final version: none different.
- On the 302 catalogue cases with one scope or none and no bound, `fast_join.py` and `verify-impl\model.py` give the same G1 and G2.
- **Scopes, told and spill have two implementations by one author** (`mr_model.py` and a plain `scope_naive.py`). They agree on 417 of 465 cases; the other 48 were too large for the plain one. This is a check on slips, not an independent opinion.
- **No independent reader checked any part.** The brief rules out starting agents.
- Lean statements were read in `Challenge.lean` as statements; the proofs were not opened.
- **Bounded searches**: scopes at f = 3 (two rounds); scopes without freeze (six, two, one rounds at f = 1, 2, 3); forty monitors with scopes (three rounds at f = 1); growth with scopes at f = 2 (three rounds). The proved statements do not depend on them.
- One design point I changed mid-work: `freeze` first blocked only faults in a closed scope; it now also blocks joins into one. Part D was rerun after that.

## Not settled

- Which reading of an arrow the drawing means. The verdict on the candidate turns on it.
- Whether R4 is a count or a property of the wiring.
- Where a ring coordinator's own fault lands. Taken as its own ring's scope. The other choice gives the same at f = 1, and at f = 2 keeps G1 of the top scope but makes one coordinator's fault halt every ring.
- G1 of an upper scope and told, for every level.
- Growth with scopes: checked at f = 1, not proved.
- A second fault in a halted ring, a join into a halted ring, lifting a halt, repair, removing a connection, a temporary mesh, moving a member: not modelled.

## Files

- Write-ups: `part-a.md`, `results-minimal.md`
- Specification: `model-spec-scope.md`
- Catalogue: `systems-minimal.json`, `results-minimal.json`, `make_catalogue.py`
- Model: `mr_model.py`, `scope_naive.py`, `mr_ring.py`, `mr_tower.py`, `mr_examples.py`, `mr_show.py`
- Part A: `part_a1.py`, `part_a2.py`, `part_a3.py`, `part_a_brute.py`, `part_a_recheck.py`, and `part-a-*.txt` / `.json`
- Part B: `part_b.py`, `part_b2.py`, `part-b.txt`, `part-b-k5.txt`
- Part C: `part_c.py`, `part-c-one.txt`, `part-c-forced-flat.txt`, `part-c-scoped.txt`, `part-c-scoped-rest.txt`, `part-c-kinds.txt`, `part-c-forty.txt`
- Part D: `part_d.py`, `part-d-grow.txt`, `part-d-steps-fifth.txt`
- Comparisons: `mr_crosscheck.py`, `crosscheck-join-catalogue.txt`, `catalogue_others.py`, `catalogue-others.txt`, `naive-compare.txt`, `naive-part-*.txt`, `naive-extra.txt`
