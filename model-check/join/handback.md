# Hand-back: monitors that join a running system

## Verdict on the claim

**The claim holds under conditions it does not give, and its two numbers (three attachments, two observers) are not what the model requires.**

- **What holds.** A monitor can join a running ring with no gap, and the system can be grown this way without end. This is true from either ring shape (the mesh of four, or three in a cycle with a coordinator attached to all three) and whether the three a new monitor attaches to watch each other or not. The fault rate with no gap stays exactly the starting ring's, at every size and for every choice of where to attach. Joining never raises it. **Proved** for the whole class (Theorem L and Lemma N below); **checked** on 12,324 grown systems of 5 to 20 monitors, each at `f` = 1, 2, 3, 4.
- **Conditions the claim does not give:**
  1. A state check of the new monitor must be in force in the step that adds it. A round late gives a gap at `f` = 1 if it may arrive bad, at `f` = 2 if it always arrives good.
  2. A monitor must not join before a monitor that checks it. A ring joins coordinator first, or whole. Otherwise there is a gap at `f` = 1.
  3. Every work process, whenever present, needs a present state checker and more than `f` present halt inputs. So work must not join before its ring, and a monitor that has not joined cannot count as a halt input or the only checker. Otherwise there is a gap at `f` = 1.
  4. Reports must arrive within the round. With slow reports, growth away from the monitors the work reads gives a gap at `f` = 1 (G2).
- **Three is more than the two judgements require.** The least attachment is:
  - one edge (an existing monitor checks its state) for a monitor nothing depends on;
  - three edges, all possibly with one existing monitor (state checked, signal read, one report out), for a monitor that work or later monitors lean on, plus a fourth at `f` = 3;
  - one two-way link with one monitor for a joining ring with its own work.
  
  Three is exactly right in one respect only: work that takes its halt from the new ring alone has rate equal to the number of monitors the new one is attached to (1, 2, 3).
- **"Every monitor has two observers" is neither necessary nor sufficient.** One watcher each holds at every rate the base supports. Two watchers each with no route to the work has a gap at `f` = 1.

## The extension and the unchanged results

- **Specification.** `join\model-spec-join.md` adds three fields and one state component:
  - `late`: groups that join by one step `join g`, with an optional `after` condition; a group may hold several monitors and the one joining work process.
  - `arrive_bad`: enables the step `join-bad g m`, one step, in which monitor `m` arrives bad.
  - `slow_edges`: edges missing in the join round only.
  - `arrived`: the new state component.
  
  Before a monitor joins, none of its edges is in force: its absence is not read as silence, no work waits on it, and no fault applies to it. A system with none of the new fields is the old model.
- **Existing results unchanged. Checked.** `check_model_join.py` on the original catalogue gives output identical to `model-check\run-output.txt` in its first 201 lines; the last two differ only in output file names. The JSON files it writes are byte-identical (`cmp`) to `model-check\results.json` and `systems-all.json`.
- **Second implementation.** `fast_join.py` was written from the two specification files alone. It agrees with the original catalogue on all 103 cases, and with `check_model_join.py` on all 5,658 cases of the new catalogue. Both were written by me, so this is not the independent comparison.
- **Coverage.** About 156,000 different systems were explored in all. Those outside the catalogue were explored by `fast_join.py` only.

## Statements proved for whole classes

Each was tested against the search on 59,086 systems, with zero cases of "conditions hold, a gap".

- **Lemma M. Proved** (no window): adding edges, or making a slow edge prompt, never opens a gap and never shortens a violation. This makes the least-attachment searches complete over all 2^24 attachments. Random test: 2,005 pairs, 0 worse.
- **Lemma N. Proved:** a system with late processes is never better than the same system with them deleted, because the environment may never join them. Tested on 58,880 systems, 0 better.
- **Theorem L. Proved,** any size, any `f`. Take a plain base in which every fault round ends in a complete response at rate `f`, and a flag at any monitor reaches a halt input of every work process. Add late monitors that can be ranked so each has a state checker, a signal reader and a report target of lower rank (or in the base), present whenever it is. With work reading the base, there is no gap at `f`.
- **Theorem J. Proved,** any size, any `f`. Suppose that in every reachable set of present processes the monitors are connected by pairs that watch and report to each other, every present work process has a present checker and more than `f` present halt inputs, and there are more than `f` initial monitors. Then there is no gap. This covers joining work, and needs only connectedness.
- **Theorem F. Proved,** nothing joining. If every monitor has `f` state checkers and `f` signal readers, every work process has a checker, and from every monitor a halt input of every work process is reachable along reports avoiding any `f` other monitors, there is no gap.
- **Theorem S in every reachable set of present processes. Proved** for `f` = 1.
- **A monitor nobody checks. Proved:** a present monitor with no state checker in force gives a gap at `f` = 1. This is the P7 analogue.

## (a) What must a joining monitor be attached to?

Base rings, all meeting Theorem S (**checked**):

| Base ring | Rate, W reads all four | Rate, W reads two |
|---|---|---|
| mesh of four | 3 | 1 |
| cycle, coordinator checks state | 3 | 1 |
| cycle, coordinator reads signals and flags only | 2 | 1 |
| cycle as the nested rings build it | 2 | 1 |

The signal-only coordinator fails at `f` = 3: mutate M1, M2, M3 and nothing is flagged.

**N that nothing depends on. Checked and proved complete** (Lemma M) for all 2^24 attachments, on every base, at every rate the base holds.
- There is no gap exactly when some existing monitor (any of the four) checks N's state.
- Each of the other five edge kinds alone, no edge, and all 20 edges other than the checks of N give the same gap. At `f` = 1 it is G1 and G2 in 2 rounds (join N; mutate N), or 1 round if N may arrive bad. At `f` = 2 and 3 it is 1 round.
- In the claimed 18-edge mesh attachment, removing any single edge changes nothing. Removing a whole kind matters only for the checks of N.

**N that a work process depends on. Checked,** complete by the same search. J joins with N, is checked only by N, and halts on N and its three. Removing a whole kind from the mesh attachment:

| Kind removed | Result |
|---|---|
| checks of N | G1/G2 in 2 rounds at `f` = 1 |
| reads of N's signal | 3/3 at `f` = 1 (join; stop N; mutate J) |
| N's reports | G2 in 2 rounds at `f` = 1, G1 holds |
| N's checks of others | gap only at `f` = 3 (mutate N's three; N cannot learn it; J works) |
| N's reads of signals | spare |
| reports to N | spare |

- Least attachments at `f` = 1 and 2: 64, each one check of N, one read of N's signal and one report from N, at any monitors, possibly one monitor.
- Least attachments at `f` = 3: 256, the same three plus either N checks one of its three or the monitor outside its ring reports to N.
- The cycle-member shapes (all six orders) have no gap to `f` = 3. The signal-only coordinator shape and the one-watcher shape have a gap at `f` = 3.

**Is three the number?** It is more than required, as above. It is exact for ring-local work (**checked**; one direction **proved** by P8b): N in a mesh with `k` monitors and J halting on N and those `k` gives rate 1, 2, 3 for `k` = 1, 2, 3.

What else in `results.md` bears on three, none of it in the round model or checked here:
- Naming the faulty monitor needs two watchers, three to survive a loss (10.2).
- The cascade needs two report targets.
- Restart needs only one observer reached from K (10.3). The restart game was **checked** on four grown graphs, and all can always restart.
- **Proved** by counting, outside the judgements: for every bad monitor to be itself checked by a live correct monitor at rate `f`, it needs `f` state checkers. G1 asks less, since any flag satisfies it.

## (b) From the step that adds it

**Checked** (mesh and checking-coordinator cycle give the same):

| N's edges | N arrives good | N may arrive bad |
|---|---|---|
| all a round late | no gap at `f` = 1; G1/G2 in 1 round at `f` = 2, 3 | G1/G2 in 1 round at `f` = 1 |
| only the checks of N late | same as above | same as above |
| one check of N on time, everything else late | no gap | no gap |
| checks of N never | 2/2 at `f` = 1 | 1/1 |

- So the monitor's P7 is: a state check of it in force in the join step.
- When J joins with N, more must be on time. At `f` = 1 with bad arrival: a check of N and a halt input of J other than N. At `f` = 2: also N's check of J, a report from N and a second halt input. At `f` = 3: also a read of N's signal and a third halt input.
- The no-gap entry for good arrival with late edges at `f` = 1 is an artefact of the join using up the round's one step.

## (c) Growing without end

**Proved** (Theorem L and Lemma N): for a base of rate `r`, grown by any number of monitors in any of the five shapes, there is no gap exactly when `f` ≤ `r`. The five shapes are: mesh with three; signal-reading coordinator of three; cycle member with the coordinator checking it; cycle member with the coordinator only reading it; one watcher. Each joins when its attached monitors are present. The rate stays, never rises, never falls, and does not depend on the choices.

**Checked:**
- Way one from the mesh: all systems up to renaming (1, 3, 10, 48 at 5, 6, 7, 8 monitors) have rate 3.
- Way two: 12,240 systems from the four bases in the five shapes and mixtures, exhaustive to 6 monitors and sampled at 7 and 8, all at the base's rate (3, 3, 2, 2).
- Families: hub to 11 monitors, chain and fan to 20, all rate 3.

**Boundary counterexample** (mesh grown to eight, `f` = 4): mutate M1, M2, M3, K in round 1 before anything joins. G1 and G2 are broken. At `f` = 3 the first three are flagged by K and W halts.

**Join order. Checked:** with any order allowed, 61 of the 62 way-one systems keep rate 3. One has a gap at `f` = 1: N8 attached to three late monitors joins first (join N8; mutate N8).

**A chain with one watcher each:**
- Removing the state check of any monitor gives a gap at `f` = 1.
- Removing the signal read or the report of a monitor another leans on gives a gap at `f` = 1 (4/4, and G2 in 3).
- The same two edges on the last monitor are spare.

**All monitors present from the start** (way one, 5 to 7 monitors): rate 3 if W reads the base four, `n` − 1 if W reads every monitor. **Proved** exact via Theorem J, Theorem 0 and P8b.

**Two observers. Checked counterexamples:**
- Cycle with checking coordinator, reports removed, W halting on M1 and M2: every monitor has two watchers, G2 broken at `f` = 1 (mutate M1; M3 and K flag; W works).
- Two meshes of three joined by two report pairs, W on ring A: two watchers each and Theorem S holds, G2 broken at `f` = 2 (stop B1, mutate B2).
- Two members checking each other with a signal-only coordinator: G1/G2 broken at `f` = 2.
- Not necessary: a ring of three with one watcher each holds at `f` = 2, as does one-watcher growth.
- What two watchers do give (Theorem F, **proved**): at `f` = 2 they suffice when work reads every monitor directly, with no reports.

## (d) The work processes

**Checked:**
- N may become an additional halt input or checker of existing W with no gap (rate 3).
- W halting on M1, M2, N has rate 1. W halting on M1 and N has G2 broken at `f` = 1 in 1 round. W whose only checker is N has a gap in 1 round. In each case N has not joined yet.
- J checked by N has no gap to 3 if it joins with or after N, and a gap at `f` = 1 (2/2) if it may join first.
- J on each of the four new rings of systems grown to eight (chain and hub) has rate 3 for the mesh shape and both cycle-member shapes, and rate 2 for the signal-only coordinator. The mesh shape is **proved** (Theorem J); the cycle shapes are **checked** for those sixteen systems only.
- The model has one joining work process.

## (e) A joiner that is itself a ring

Ring B (B1, B2, B3, KB, work WB) joins ring A by KB in a mesh with three of A.

**Checked** (**proved** by Theorem J for the first three rows), `f` = 1 to 4, a member may arrive bad:

| How ring B joins | Result |
|---|---|
| one step for all five | no gap to 3 |
| four monitors, then WB | no gap to 3 |
| KB, then members, then WB | no gap to 3 |
| WB at any time | gap at `f` = 1 (2/2) |
| KB, then members and WB in any order | gap at `f` = 1 (G2 in 3: join KB; join WB; mutate KB) |
| all in any order | gap at `f` = 1 (join B1; mutate B1) |

- **Least attachment of KB** (complete search at `f` = 1 and 2 over 24 edges; at `f` = 3 over 15 edges): A checks KB, A reads KB's signal, KB reports to A, and either KB watches one monitor X of A with X reporting to KB, or `f` + 1 monitors of A report to KB. One mutual link with one monitor is enough to `f` = 3.
- With only "M1 watches KB, KB reports to M1" there is a gap at `f` = 1: mutate M1; W halts; WB works.
- With both rings present from the start and each in one boundary, there is no gap at `f` = 1 and G1 is broken in 2 rounds at `f` = 2.
- **One step versus several.** One step means the ring exists whole and the attachment is the only act. Several means it is built in place and order matters.
- **What the model cannot say:** what ring B was before joining; whether A observes B or only KB; a halt confined to B; lifting a halt.

## (f) Rings do not get bigger

- **Proved:** in way one every mutually watching set has at most four monitors, and there are `n` − 3 rings.
- **Counted**, mesh shape: 18 edges per new monitor; 18`n` − 36 in all; mean per monitor 36 − 72/`n`. Other shapes add 15, 10, 9 and 3.
- W reads 4 throughout.
- **What grows:**
  - The number of rings and edges.
  - The edges at a monitor chosen repeatedly: 42, 90, 186, 378 at `n` = 8, 16, 32, 64 for a hub, against a constant 36 for a chain.
  - The report distance to the work for a chain: 1, 3, 9, 19 hops.
- **Counted:** bounded edges per monitor and bounded reads by W force hops to grow at least logarithmically.
- **Proved,** slow reports, `f` = 1: no gap requires each work process to halt on a state checker of every monitor. **Checked:** 1 of the 62 way-one systems then has a gap (N8 on three non-base monitors; G2 in round 5). A halt confined to part of a system would be needed here, and the model has none.

## Not settled

- Whether the two that a reflexive response needs are two observers per monitor (tested) or two halt sources per work process (that is P8b, necessary at `f` = 1).
- No theorem for ring-local work in the cycle shapes; only the sixteen systems are checked.
- Least attachments of a joining ring at `f` = 3 over all 24 edges (done over 15).
- No sufficient condition that is also necessary for `f` > 1.
- Way two is sampled, not exhaustive, at 7 and 8 monitors.
- Naming, the cascade and restart are carried from `results.md`, not checked in the round model.
- Not modelled: repair, lifting a halt, scoped halts, retiring a monitor, edges appearing between present monitors, more than one joining work process, delays longer than one round, asynchrony.
- G1 is satisfied by any flag and the response is always a global halt. This is why so little attachment is required; per-fault detection is outside the judgements.
- The independent implementation has not been run.

## Notes on process

- The first correction (the cycle-with-coordinator ring) is incorporated throughout.
- The withdrawn pair construction (a coordinator and a member joining together) was never started; nothing of it is in any file.
- `model-check\` was not modified.
- Temporary patch scripts and partial outputs were written to the session scratchpad directory outside the folder; nothing else was read or written elsewhere.
- No git, no other agents, no web.

## Files written

All in `«WORK»\sos-join-model\join\`:

- `model-spec-join.md`: the specification extension, with three small examples and their results
- `model-spec.md`: unchanged copy of the original
- `check_model_join.py`: the original checker, extended
- `fast_join.py`: second implementation, bit masks
- `join_lib.py`, `join_runs.py`: systems, searches, tables (`python -I join_runs.py --write`)
- `run-output-join.txt`: full output of that run
- `systems-join.json`, `results-join.json`: the catalogue of 5,658 cases and its answers
- `original-output-join.txt`, `original-results-join.json`, `original-systems-join.json`: the extended checker on the original catalogue
- `results-join.md`: the write-up, with the verdict first, the author's two statements, evidence kinds, round-by-round tables, limits and the not-settled list
