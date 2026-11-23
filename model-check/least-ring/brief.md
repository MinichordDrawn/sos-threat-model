I need a model check that answers one question exactly: what is the least structure a ring of four must have to meet a stated list of requirements, and does that structure, repeated one level up, still meet them? The author of the model has a candidate and a goal. Both are to be tested, not assumed. If the candidate is not the least, or the goal fails somewhere, that is the most useful thing you can find: report it with the system and the execution.

## Where things are

Work only in this folder: `«WORK»\sos-minimal-ring\`

Read, and do not change:

- `«WORK»\sos-join-model\join\`: the model as it now stands.
  - `model-spec.md`: the model, complete. A system, a state, one round, two goals G1 and G2, the result computed for a system.
  - `model-spec-join.md`: an extension in which monitors may be absent at the start and join.
  - `results-join.md`: what a model check of joining established, checked by an independent implementation and two independent readers. Read its first lines (the verdict and its conditions), section 3 (the lemmas and theorems: Lemma M, that adding edges never opens a gap, is the one that makes least-set searches complete), section 2 (the base rings and their rates) and section 8 (a ring that joins).
  - `check_model_join.py`, `fast_join.py`, `join_lib.py`, `join_runs.py`: its programs, which you may copy and build on.
- `«WORK»\sos-join-model\verify-impl\model.py`: an implementation written from the two specification files alone by someone else, which agrees with the above on 5,658 systems. Use it as a second opinion on anything the result rests on.
- `«WORK»\sos-join-model\model-check\`: the earlier results. `results.md` top (the four evidence kinds: **Checked**, **Proved**, **Counted**, **Argued**), sections 2.4 to 2.7, 8, 10.1, 10.2 (whether three monitors and a coordinator are forced) and 10.3 (restarting: why one member must differ in kind). `check_model.py` has `restart_game` (the restart model of 10.3) and `nested` (two rings under an upper ring).
- `«WORK»\sos-lean-build3\lean-proof\SelfObserving\`: statements already proved in Lean, to cite and not to redo: `Restart.lean` and `Naming.lean` (definitions), and in `Challenge.lean` the statements `restart_iff_reached`, `ringK_can_restart`, `ring3_cannot_restart`, `one_or_two_cannot_name`, `three_or_more_can_name`, `cannot_name_after_loss`, `can_name_after_loss`, `theorem_S`, `theorem_S_wide`, `mesh_exact`, `nested_noGap`, `nested_boundaries_noGap`.

Open nothing else under `«WORK»\`. You do not need the web.

## The candidate and the goal

The candidate ring, four nodes A, B, C and a coordinator D:

```
A -> B -> C -> A
D -> A, B, C
A, B, C -> D
```

The author takes this to be a ring of three and a coordinator, and the least one: every node has two where that is possible, and the coordinator has three because coordinating needs them. Every member has to report upwards, for the scope. An arrow of the drawing means a connection and no more.

So it is nine directed connections, and the drawing does not say which carry watching (reading the signal, checking the state) and which carry reports. Part A settles that.

The goal:

To get from a least structure made of one ring to a least structure made of three rings and one coordinator. If that can be done, a system built this way can keep growing and is always minimal. The three ring coordinators are in a cycle, as the members of a ring are. Growth is always the building of new rings, and once there are enough of them a scope moves up. A halt that stays in one ring is the scope of the halt action. Joining is already worked out, so growth is joining done in the right order.

And three things the author has decided, which are not to be modelled as work of their own, only kept in mind and mentioned where they bear: a ring may be made a mesh, or wider than three under a coordinator, wherever the builder wants (the price is how much each node observes); a node may belong to several rings; and how rings are attached, in what order, through a temporary mesh or by moving a member, is the builder's choice so long as the conditions hold at each step.

## The requirements

"Least" is always relative to a list of requirements, so do every part against each requirement alone and each combination, and say which requirement forces which connection. The list:

- **R1. No gap.** Neither judgement can be violated, at one fault per round. Report also at two and three.
- **R2. Two observers.** Every node is watched (signal read and state checked) by at least two others.
- **R3. Restart.** The ring can always restart, in the model of `results.md` 10.3 (`restart_game`), with the coordinator the member that can start first.
- **R4. Naming.** With at most one faulty node, the faulty one can be named. `results.md` 10.2 and the Lean statements say how many are needed; say what that means for the wiring, if anything beyond the count of nodes, and do not stretch it.
- **R5. Upward.** Every member is connected directly to the coordinator, so that its flag reaches the coordinator in one hop and does not depend on another member.
- **R6. Scope.** Stated per ring: a fault in a ring's scope halts that ring's work, and the ring above is told. See Part C.

If you find a requirement cannot be stated in the model without a choice the list does not make, make the choice, say what it is, and give the result under the other choice too.

## What I want

**Part A. The least ring of four.** Four monitors and work. Deliver this first, as `part-a.md`, before going on: the rest depends on it and it will be read while you continue.

1. *Connections as the drawing has them.* Take a directed connection X -> Y to carry everything in that direction, and say exactly what you take that to be in the model's three kinds of edge (who reads whose signal, who checks whose state, who reports to whom). If more than one reading is defensible, do each. There are twelve possible connections, so 4,096 wirings: check every one, under each reading, against each requirement and each combination, for each way the work may be wired that `results-join.md` section 2 uses (work reading all four; work reading two). For each combination: the least number of connections, every wiring that achieves it up to renaming of the nodes, and whether the candidate is among them.
2. *Connections kind by kind.* The same with the three kinds of edge separate (36 possible edges). Use Lemma M to make the search complete, as section 8 of `results-join.md` does, and say where you rely on it. Then label the candidate's nine arrows: which kinds each must carry, and for which requirement.
3. *The verdict on the candidate:* least, not least (give a smaller one), or tied with others (list them). And which requirement forces each of its nine connections. If one of the nine is forced by nothing on the list, say so.
4. *What a mesh buys.* The full mesh of four against the candidate: at which fault rates and for which requirements they differ, if any.

**Part B. Wider rings.** The same shape with k members in a cycle under one coordinator, k = 4 and 5, and the mesh of five: is the cycle-with-coordinator still least for the list, what is each node's load, and what rate does each have? Short.

**Part C. One level up.** Three candidate rings, each with its own work, and a top coordinator: the three ring coordinators in a cycle, the top coordinator connected to each both ways, so that the upper ring has the candidate's own shape. Thirteen monitors.

1. *As one system* (the model as it is, where any detection is meant to halt everything): gap or no gap at one, two and three faults per round; with each base ring whole in one boundary, so that one step loses a ring; and compare with `nested` and the two Lean statements about it.
2. *With scope per ring.* The model's second judgement is over the whole system. Write the least extension that judges it per scope: each work process belongs to a ring's scope, a fault belongs to the scope it lands in, and the judgement for a scope is violated when something in that scope is bad and work of that scope takes a work step. Say what the first judgement becomes. Then: a fault inside one base ring halts that ring's work, the other two rings' work goes on, and the upper ring is told: does that hold, at which rates, and what exactly reaches the upper ring? State the assumption this rests on (a fault in one scope can affect another scope's work only through connections that are watched) as an assumption, and do not try to prove it.
3. *Least at this size.* With the requirements applied ring by ring, the count is nine per ring, 36 for thirteen nodes, 3(n-1) in general. Say whether that follows from Part A alone, and what it does and does not show (least among structures built as rings of rings, each ring meeting the list; not least among all wirings of thirteen nodes as one flat system). If you can find a flat wiring of thirteen that meets R1 to R5 with fewer than 36, give it.
4. *One more level* (forty monitors) if it stays cheap, or the argument for every level if you can make one. Mark it **Proved** only if it holds for every level.

**Part D. Getting there by joins.** From one ring to three rings and a coordinator, as a sequence of joins in the extension's sense, each new ring joining coordinator first (connected to the coordinators already present), then its members, then its work, and the top coordinator last. With joins and faults interleaved in every order the environment can choose, a newcomer allowed to arrive bad: gap or no gap at each rate, and at which stage if there is one. Say which of `results-join.md`'s conditions and theorems cover each step, and which step, if any, they do not. Then the least attachment of a fifth node to the candidate ring against the whole list (256 attachments as connections; kind by kind with Lemma M), drawn in the author's notation.

**Part E. The write-up**, `results-minimal.md`, in the plain register of `results.md`: the verdict on the candidate and on the goal in the first lines; each result with its evidence kind; a table of the candidate's nine connections with what each carries and which requirement forces it; counterexamples as round-by-round tables; what is not settled. And for a second implementation to be compared with yours: the extension of the specification you needed, if any, as `model-spec-scope.md`, written so that someone with only the specification files could implement it; a catalogue `systems-minimal.json` of the systems the results rest on, in the specification's format; and your answers `results-minimal.json`.

## Rules

- Say "model check". Mark nothing **Proved** that is checked for particular sizes. A gap is an execution: give it.
- Never bend a statement or a requirement to make the candidate come out least. If the candidate is least only under one reading of a connection or one wiring of the work, say exactly that.
- Do not model removing a connection, repairing, or lifting a halt. Say where a question would need them.
- Keep runs modest: other work is running on this machine. Keep memory under about two gigabytes; if a search is too large, bound it and say what the bound leaves out.
- Do not use git. Do not start other agents.
- If a tool restriction or anything else stops you from doing something, do not look for a way round it. Say plainly what you could not do.

Your final message is the hand-back. I will keep it word for word: the verdict on the candidate and on the goal first, then each part with its evidence kinds, then what is not settled, then the files you wrote.
