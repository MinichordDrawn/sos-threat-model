# Findings B: independent review of `check_model.py`

*Saved by the main session from the reviewer's hand-back, word for word. The reviewer could
not write this file itself. Line numbers refer to the copy of `check_model.py` in this
folder, which is the version the reviewer was given.*

Reviewed: `model-spec.md`, `properties.md` and `check_model.py` in the folder, and nothing else. Everything below was read off the source, derived by hand, or produced by the scratch scripts in section 7, all run with `python -I`. Line numbers refer to `check_model.py` unless a file is named.

## 1. Conformance

### 1.1 Method

- I read the specification clause by clause against the code (table in 1.2).
- I wrote an independent implementation, `scratch_indep.py`, from `model-spec.md` only. It shares no code with the checker and differs in method on purpose:
  - Environment sequences are enumerated exhaustively, with no pruning by resulting state.
  - Rounds are explored layer by layer with no visited set. Layer d is every state reachable in exactly d rounds without passing through a responded state. The search stops when a layer repeats.
- I compared G1, G2 and the number of reachable states between the two:

| Compared | Count | Differences |
|---|---|---|
| Cases the script writes with `--json` (39 base cases, 55 single-edge removals), recomputed from the JSON system alone; largest 524,308 states | 94 | 0 |
| Random small systems (1 to 3 monitors, 1 or 2 work processes, optional joiner, random maps, switches, coupling, window, `f` 1 to 3) | 1,648 | 0 |
| Random neighbours of R (0 to 2 properties dropped, edges cut and added, `f` 1 or 2) | 600 | 0 |

The two random batches skipped systems over a state cap, so those were not compared: 352 over 1,500 states in the first, 371 over 2,500 in the second.

The first random batch is weighted toward early failure: 1,557 of 1,648 break both goals in round 1, and 18 hold both. The neighbours-of-R batch is more varied: 112 hold both goals, 271 break both in round 1, and 217 have a goal that holds or first breaks in rounds 2 to 4.

### 1.2 Specification clause against code

| Specification | Code | Verdict |
|---|---|---|
| §2 initial state | `initial`, 57-60 | exact |
| §1 present processes | `present`, 52-54 | exact |
| §3.1 `stop m` | 67-69 / 92-93 | exact |
| §3.1 `stop-boundary b` | 70-73 / 94-97 | exact |
| §3.1 `fail-substrate s` | 74-77 / 98-107 | exact |
| §3.1 `mutate p` | 78-80 / 108-109 | exact |
| §3.1 `disable m` | 81-83 / 110-111 | exact |
| §3.1 `join` | 84-85 / 112-114 | exact except D1 |
| §3.1 any k with 0 <= k <= f, each step enabled where taken | `env_choices`, 177-190 | exact (1.3) |
| §3.2 `active`, `visible` | 122-123 | exact |
| §3.2 detection | 125-130 | exact |
| §3.2 propagation to a fixed point, active monitors only | 131-139 | exact |
| §3.2 `out` (flagged, alive, not bad; `off` not excluded) | 141 | exact |
| §3.3 work phase | 143-159 | exact |
| §3.4 G1, G2 | 163-164 | exact |
| §3 phase order | 211-212 calling 119-168 | exact |
| §3.5 responded; no round from a responded state | 171-174, 209-210 | exact |
| §4 least n, or null | `explore`, 193-219 | exact (1.4) |

### 1.3 `env_choices` (177-190): one step sequence per distinct resulting state

The pruning is sound and loses no execution outcome. Three facts establish this.

1. Every state reachable from `s` by an enabled sequence of at most `f` steps is returned. The argument is by induction on length. A state reachable in j steps is `apply_env(u, e)` for some `u` reachable in j-1 steps. That `u` went on a frontier at its least length i <= j-1, and every enabled step from it was applied at iteration i+1 <= j. A state first seen at a short length is extended from there, so it has at least as much remaining budget as any longer route to it.
2. The start state with zero steps is included (`seen = {s: ()}`).
3. The rest of the round is a function of the state after the environment phase and nothing else. Two sequences reaching the same state give the same next state and the same G1 and G2.

Every enabled step changes the state, so no sequence returns to an earlier state within a round.

The pruning affects only which sequence is displayed. For example, `stop M3` is shown where `fail-substrate s3` reaches the same state.

### 1.4 How the shortest violating execution is found (207-218)

`explore` is a breadth-first search over round-boundary states.

- States leave the queue in non-decreasing order of least round count. The first violation recorded for a goal therefore starts from a state of least depth d among all states with a violating choice, and the reported length d+1 is the least n of §4.
- `path_to` follows first-discovery parents, so its prefix has exactly d rounds.
- Violations are recorded for every environment choice from every non-responded reachable state, including choices whose resulting state is already known. The `parent` test on line 216 skips nothing.
- Responded states are counted but never expanded.

"Shortest" means fewest rounds, as the specification asks, not fewest steps. Ties go to the first execution in enumeration order. The layered search in `scratch_indep.py` returns the same least n in every comparison.

### 1.5 Deviations

| # | Where | What | Could it change a result? |
|---|---|---|---|
| D1 | line 84 | `if system.joiner and not s.joined` tests truthiness; the spec says "not null". A joiner named `""` or `0` never gets the join step. | Not for any system the script builds. Yes for a system with such a name. |
| D2 | `replay` 222-234; `broken` 538-540 | `replay` never checks `responded`, so it runs rounds the spec forbids. `broken` reports a goal broken in any round, not the last. | The G1/G2 tables are unaffected. Output section 3 is affected: for P1, the "same schedule in full R" has a second round that starts from a responded state (checked). "Breaks nothing" is printed for a round that should not have run. In full R, `stop M1; stop M2; stop M3; mutate W1` is reported by `replay` as breaking G1, while `explore` says G1 holds. |
| D3 | `reference`, line 260 | `p not in without` is a substring test when `without` is a string. `reference(without="P8b")` also removes P8 (window 1) and names the system "R without P, 8, b". | Not in the script, which passes tuples. Yes for a caller writing `without="P8b"` or `("P8b")`. |
| D4 | `reference`, 299-305 | `unread_extra=True` with `without=("P3",)` raises `KeyError: 'W1'`. | Not used by the script. |
| D5 | 70, 74, 154, 181, 52-54 with 144 | No input validation. `sorted(set(...))` raises `TypeError` on ids of mixed types. Any non-zero `window` acts as 1. `f` = 0 is accepted. A name in both `works` and `joiner` is offered `join` while present and is visited twice in a work phase after joining (confirmed). | Not for the script's systems. The spec is silent on malformed input. |
| D6 | `main`, 624-633 | §5 describes reading `systems.json`. The script only writes its own cases. `--json` entries carry an extra `system` field. | No. |
| D7 | docstring line 2; `properties.md` line 1 | Both say "eight" for nine properties. Docstring line 7 words G1 "at the end of a round"; the spec says after the monitor phase. The value is the same because the work phase changes neither `bad` nor `out`. | No. |
| D8 | `growth` 431-458, `heartbeat_spec` 463-498 | Neither has a counterpart in `model-spec.md`. The `Heartbeat.tla` it says it mirrors is not in the folder. | Output sections 9 and 10 cannot be checked against anything here. I read them but did not review them. |

I found no deviation in the environment steps, the phases, the goal checks, the end rule or the search.

## 2. Builders

### 2.1 What each removal changes (field diff against `reference()`)

| Removed | Fields changed | Change |
|---|---|---|
| P1 | `hb_readers`, `coupling` | all six reader edges removed; coupling True to False |
| P2 | `substrate` | M1 s1 to s4, M2 s2 to s5 |
| P3 | `checkers` | all nine checker edges removed, J's included |
| P4 | `fwd` | all six report edges removed |
| P5 | `switches` | empty to M1, M2, M3 |
| P6 | `boundary` | 1, 2, 3 to 1, 1, 1 |
| P7 | `checkers`, `halt_inputs` | J's checker (M3) and J's halt inputs (M3, M1) removed |
| P8 | `window` | 0 to 1 |
| P8b | `halt_inputs` | W1: M1,M3 to M1; W2: M2,M3 to M2; J: M3,M1 to M3 |

### 2.2 Per property: removed as stated, and nothing else?

**P1: removed, and more.**
- Emptying `hb_readers` is P1 as stated. Turning `coupling` off (line 277) is not in P1's text; a work process halting on a monitor's silence is a halt-path matter.
- I split the two. R with coupling off and readers kept holds both goals (23 states, identical to R). R with readers emptied and coupling kept breaks G1 and G2 in round 1.
- So the extra switch changes neither number. It does change the execution (with coupling kept, W1 halts and only W2 works) and the state count (700 against 2,210).
- By dependency, P2's last clause ("observable through P1") and P6 have nothing to work with once no signal is read. P5's first sentence becomes false, because `stop M1` removes W1's only checker unobserved.
- Evidence: the two shortest counterexamples of R without P1 (`fail-substrate s1`, `s2`) are exactly the two shortest of R without P2.

**P2: removed as stated, clean.** It is removed for both pairs at once. The new substrates s4 and s5 add two steps that are the same as `stop M1` and `stop M2`.

**P3: removed as stated, in the widest form.** Every check goes: monitor on work process, monitor on monitor, and M3 on J. The last is the checker half of P7.

**P4: removed as stated, clean.** Whether anything breaks depends on the halt wiring (section 3).

**P5: only the second sentence is removed.** The builder gives every monitor a switch. The first sentence ("no single environment step removes the monitoring of a process without that step being observed") is not a parameter. It is true in R: every enabled single step except `join` and the empty step raises a flag in the same round. It becomes false as a side effect of removing P1 (silent `stop`) or P6 (one step stops every monitor).

**P6: removed in the only form the model offers, and what is removed is not what the text says.**
- `boundary` is read in one place only, to enable `stop-boundary` (70-73). It has no effect on who reads whose signal.
- In R without P6, every monitor's signal still has two readers. The removal takes away no observer; it gives the environment one step that stops all three monitors.
- A partial sharing (M1 and M2 together, M3 apart) holds both goals (25 states).
- Side effect: P5's first sentence fails.

**P7: removed, and more.**
- J loses its checker and its halt inputs. "Under monitoring" covers the checker; the halt inputs are P8b's subject.
- Split: with only the checker removed, G1 and G2 break in round 2 (`join J; mutate J`). With only the halt inputs removed, G2 breaks in round 2 and G1 in round 4.
- A further side effect: once J has joined it can never halt, so no state is responded and the model never ends (2,565 states).

**P8: removed as stated, slightly wider.** `window` = 1 also delays a halt on a monitor's silence through coupling. P8's text is about a raised flag only. No number changes.

**P8b: removed as its last sentence states it, clean.**

### 2.3 Does R really have all nine when nothing is removed?

- **P8b: only in the "model's terms" sentence.**
  - "Any process can trigger the halt" is not true of R. Only monitors can, and only for work processes that list them. M2 cannot halt W1 or J except by reporting to M1 or M3 (that is, through P4), and M1 cannot halt W2 directly.
  - "Every halt is passed to at least two other processes, each of which passes it to at least two more" is not in the transition system at all. That wording is modelled only in `growth()`, which is unconnected to `System`.
- **P2: for W1 and W2 only.** J has no substrate, so P2 is vacuous for it. Monitors watching monitors share no substrate. That is harmless, since a substrate failure under a monitor is a stop, which P1 shows.
- **P7: statically.** J is in `checkers` and `halt_inputs` from the start; `join` only makes J present.
- **P4: one hop.** R has no chains and no coordinators.
- P1, P3, P5, P6 and P8 are present as stated.

### 2.4 Supporting experiments

- **Cross matrix.** Each `CANONICAL` schedule was replayed with the end rule enforced in every R-minus-one.
  - Three of the nine schedules are the same single step, `mutate W1` (P3, P4, P8).
  - P2's schedule breaks both goals in R without P1.
  - In R without P8, every schedule that makes a process bad breaks G2.
  - P1's schedule is not a legal two-round execution in R or in seven of the other R-minus-one systems; the model ends after round 1.
- **Single-edge removals from full R** (27 edges, `f` = 1): 9 are needed and 18 are spare.
  - Needed: the one checker of W1, of W2 and of J, and all six halt inputs.
  - Spare: all six reader edges, all six monitor-on-monitor checks and all six report edges.
  - So P1, P4 and the monitor-on-monitor part of P3 matter only in bulk, which is how the builders remove them.
- **Pairs.** No pair of removals restores both goals (36 pairs).

## 3. By construction or by dynamics

**How I judged.**
- DEFINITION: the violating execution is made of environment steps whose effect is fixed by the step's definition once the property's parameter is flipped. No monitor or work-process behaviour matters to it, and the same violation exists in any system lacking the property, whatever its other wiring.
- DYNAMICS: the violation needs processes to act on each other, and a different wiring that still lacks the property avoids it.
- MIXED: one of each.

To test "any system", I forced each removal onto 400 random systems (`scratch_universal.py`). The violation was there 400 of 400 times for eight of the nine. P4 is the exception.

**P1: DEFINITION.** The shortest is `fail-substrate s1` (or `s2`): one step, round 1, G1 and G2. This is P2's counterexample. The step stops M1 and makes W1 bad and hidden, and with no reader of M1's silence nothing can react. The script's listed P1 execution (`stop M1`, then `mutate W1`) takes two rounds and is not the shortest; it becomes the shortest only when substrates are taken out of R (checked). Either way no process does anything. In any system with no readers and no coupling, the environment can stop every monitor unobserved and then mutate.

**P2: DEFINITION.** The shortest is `fail-substrate s1` (or `s2`): one step, round 1, G1 and G2. `hidden` is defined as invisible to every state comparison, and `fail-substrate` is the only step that produces it. The only other mark the step can leave is the stop of a monitor on the same substrate. Take the monitor off the substrate and the step is undetectable by definition.

**P3: DEFINITION.** The shortest is any one `mutate` (five choices): round 1, G1 and G2. `mutate` only puts a process in `bad`, and `checkers` is the only relation that reads `bad`.

**P4: DYNAMICS.** The shortest is `mutate W1` (or `W2`): round 1, G2 only. G1 holds in all 59 states. M1 detects and W1 halts, but M1's flag reaches neither M2 nor M3, and W2 reads only those two, so W2 takes a work step. This is the one removal whose violation comes from processes acting on each other, though within a single round and not across rounds. It is contingent on R's wiring. R without P4 holds both goals if every work process reads all three monitors, and also if W1 and W2 are additionally checked by M3 (23 states each). A mesh of three with no report edges holds too. It also needs G2's system-wide scope: W2 is not bad, and must halt because W1 is.

**P5: DEFINITION.** The shortest is `disable M1` then `mutate W1` (or M2 and W2): two rounds, G1 and G2. Nothing in the model reads `off`. A disabled monitor stays in `alive`, so its signal continues and coupling stays quiet. "P5 present" means only that the step does not exist; the script itself reports that the schedule "has a step that does not exist" in full R. Two rounds are needed only because `f` = 1 separates the two steps.

**P6: DEFINITION.** The shortest is `stop-boundary 1` then any step that makes a process bad (seven choices): two rounds, G1 only. One step stops all three monitors, `out` is then empty for good, and G1 falls to the first bad state. In the violating round every work process has already halted through coupling and nothing takes a step. Full R shows the same violation at `f` = 3 (`stop M1, stop M2, mutate M3` in one round). In this model, removing P6 lets three stops count as one step.

**P7: DEFINITION.** The shortest is `join J` then `mutate J`: two rounds, G1 and G2. `join` only makes J present; whether J is checked is fixed in the maps beforehand. With J's entries removed, this is P3's counterexample for one process. G2 alone also breaks by `join J` and then any step that makes a process bad (eight choices), because J has no halt input.

**P8: DEFINITION.** The shortest is any one step that makes a process bad (seven choices): round 1, G2 only. `window` = 1 means a work process takes a work step in the round it sees a reason to halt, and G2 forbids any work step while a process is bad. The removal is the negation of the goal. It holds in every system with a work process: in round 1 nothing is yet pending or halted, so after any `mutate` every work process steps. The situation P8's text describes, the environment acting during the evaluation, is not what breaks the goal and cannot arise here. A pending process always halts in its next work phase (0 exceptions over every transition of R without P8).

**P8b: MIXED.**
- G2 breaks in round 1 with `mutate M1` (or `M2`). W1's only halt input is the mutated monitor, which `out` excludes by definition, and it is still alive, so coupling is quiet. This part is definitional and holds in any system where a work process has one halt input. M2 and M3 flagging plays no part.
- G1 breaks in round 3: `mutate M1`, then M2 and M3 removed in either order (30 shortest sequences). W1 never halts, so the model never ends, and the environment removes the two flagged monitors one per round. This part is dynamics over rounds.

**Across all nine.** Each property has its own parameter. Where a parameter alone could not produce a violation, it also has its own environment step: `fail-substrate` and `hidden` (P2), `disable` (P5), `stop-boundary` (P6), `join` (P7), and `window` (P8). The model is parameterised by the properties. For eight of the nine, "removing Pi breaks a goal" restates how the parameter was defined; the search did not discover it. Every shortest counterexample is one or two environment steps long.

## 4. Trying to break R (all nine present, `f` = 1)

In the initial state nothing is flagged, bad, halted or pending, and all three monitors are alive. At most one step is allowed. I went through every kind of step.

- **No step.** The state repeats.
- **`stop Mi`.** The other two monitors are active and both read Mi's signal, so both flag. Every work process has two halt inputs and at most one is Mi, so each has an input in `out` and halts. `bad` is empty. The state is responded.
- **`stop-boundary`.** Never enabled: three monitors, three boundaries.
- **`fail-substrate s1`** (s2 is symmetric). M1 stops and W1 becomes bad and hidden. M2 and M3 read M1's silence and flag, so `out` is not empty and G1 holds. W1 halts on M3 and W2 on M2 or M3. Nobody takes a work step, so G2 holds. Responded. `fail-substrate s3` is the same as `stop M3`.
- **`mutate W1`** (W2 is symmetric). M1 checks W1, flags, and reports to M2 and M3. All three are in `out`. Both work processes halt. Responded.
- **`mutate Mi`.** Mi leaves `active`. The other two both check Mi and flag. As for `stop Mi`, every work process has a halt input among them. Responded.
- **`disable`.** Never enabled: there are no switches.
- **`join`.** J becomes present. Nothing is bad. This is the only step leading to a second live state.

From the state after `join` the same cases apply, with J reading M3 and M1.
- `stop`, `fail-substrate` and `mutate` of a monitor leave at least one of M3 and M1 in `out`, so J halts.
- `mutate J` is seen by M3, which reports to the others.
- `join` is no longer enabled.

**Conclusion: no execution violates G1 or G2.** Every step that makes a process bad or removes a monitor is answered in the same round by a flag on a live correct monitor and the halt of every present work process, and the model ends there. A second such step never happens.

The reachable states are:
- the initial state and the state after `join`;
- 10 responded states from the first (three stops, two substrate failures, five mutations; `fail-substrate s3` coincides with `stop M3`);
- 11 responded states from the second.

That is 23. `explore(reference())` returns `{'G1': None, 'G2': None}` and 23 states. `scratch_checks.py` prints all 26 transitions, and each agrees with the reasoning above.

**What this result is.** R answers any single first step completely. It does not say R survives one step per round for many rounds, because the model ends at the first response. With `f` = 2, G2 breaks in round 1 (`mutate M1, mutate M3`: both halt inputs of W1 are bad) and G1 in round 2. With `f` = 3, both break in round 1. The script prints these itself.

## 5. Goal fit

| Property | Removal breaks in R (`f` = 1) | Is that the right goal? |
|---|---|---|
| P1 | G1 round 1, G2 round 1 | G1 is the right kind of goal, but neither goal mentions a stopped monitor. A silent stop alone breaks nothing because `bad` is empty. G1 fails only when a bad state arrives with the stop or after it. The G2 failure is the same step in the same round, not separate evidence. |
| P2 | G1 round 1, G2 round 1 | G1, and it fits well. G2 fails as a consequence. |
| P3 | G1 round 1, G2 round 1 | G1, and it fits. G2 fails as a consequence. |
| P4 | G2 round 1 only | Neither goal states what P4 states. G1 asks for one flagged monitor, so it cannot see P4 at all. G2 sees it only through the halt wiring. G2 is defensible, since reports exist so that everything halts, but the result measures R's halt wiring as much as P4. A matching goal would be "every live correct monitor is flagged". |
| P5 | G1 round 2, G2 round 2 | G1 fits. G2 also has its own route: `disable M1; mutate M3`. M2 flags, and W1's inputs are M1 (switched off, never told) and M3 (bad). |
| P6 | G1 round 2 only | G1 is the right kind of goal. But in the violating round every work process is already halted and no monitor is alive; G1 is broken by mutating a halted process. G2 never breaks. If the model ended when every present work process is halted, removing P6 would break nothing (checked: 25 states, both hold). With coupling also off, G2 breaks too, so it is coupling, bundled into P1, that protects G2 here. |
| P7 | G1 round 2, G2 round 2 | Both, one each. No checker is a G1 matter and no halt input is a G2 matter. The builder removes both together. |
| P8 | G2 round 1 only | G2 is the right kind of goal, but the fit is circular: the window is one more work step and G2 forbids that step. A goal testing P8's stated reason would ask whether the halt still completes when the environment acts during the window. Here it always does. |
| P8b | G2 round 1, G1 round 3 | G2 fits. It fails because a monitor is bad while a healthy work process runs; G2 counts any bad process. The G1 failure is a consequence of the model not ending. |

Two general points.
- Whenever G1 fails while a work process is still running, G2 fails in the same round by definition. For P1, P2, P3, P5 and P7 the two goals record one event. Only P4 and P8 break G2 alone, and only P6 breaks G1 alone.
- Neither goal says anything about a stopped monitor while nothing is bad, which is what P1 and P6 are about.

A smaller point on G1: `flagged` never shrinks, so a flag raised for an earlier event satisfies G1 for a later bad state that nobody detects. I counted the rounds where G1 holds on such a flag alone. There are none in R or in eight of the R-minus-one systems. There are 1,410 in R without P5, the earliest in round 3, which is after that system's shortest violation. No printed result depends on it.

## 6. What limits trust in the results

The checker computes what the specification defines; I could not make it disagree with an independent implementation. The limits are in what the tables are taken to show.

1. **"Each of the nine is necessary" is mostly built in.** Eight of the nine removals produce a violation that follows from the definition of a step or parameter and exists in any system.
2. **The P1 row measures P2.** R without P1 is "broken in 1 round" by P2's counterexample. The execution listed for P1 in `CANONICAL` takes two rounds and is not the shortest. Without substrates the figure is 2.
3. **The P4 row measures R's wiring.** Two small rewirings make P4 unnecessary at `f` = 1.
4. **The P6 row is a G1 failure in a fully halted system.** It disappears under an end rule that accepts a complete halt.
5. **The P8 row is a tautology.** The model cannot express the situation P8 describes.
6. **"R holds" is a 23-state, one-step result.** It is correct, it is small, and it holds for `f` = 1 only.
7. **Output section 3 uses `replay`, which ignores the end rule (D2).**
8. **Output sections 9 and 10 have no specification in the folder (D8).** P8b's cascade wording is supported only by section 9.
9. **Removals are all-or-nothing.** In full R, 18 of 27 single edges are spare. The tables do not show how much of P1, P3 or P4 is needed, only that none at all is too little.
10. **There are small hazards for a caller.** These are a string passed as `without` (D3), a falsy joiner name (D1), and no validation (D5).

## 7. Scratch files

All are in this folder.

| File | What it does |
|---|---|
| `scratch_indep.py` | independent implementation of `model-spec.md` |
| `scratch_compare.py` | differential test against `explore` (`--named`, `--random N`, `--perturb N`, `--cap`) |
| `scratch_json_compare.py` | recomputes every case in `scratch_cases.json` from the JSON alone |
| `scratch_r.py` | R, the nine removals and the `CANONICAL` replays, with executions |
| `scratch_variants.py` | split removals, end-rule variants, all shortest executions, cross matrix, single-edge removals, pairs |
| `scratch_checks.py` | the 26 transitions of full R, the `replay` and string-argument checks, the pending check |
| `scratch_universal.py` | each removal forced onto 400 random systems |
| `scratch_stale.py` | rounds where G1 holds only on an earlier flag |
| `scratch_full_run.txt`, `scratch_cases.json` | one full run of `check_model.py --traces --json` |
| `scratch_random_out.txt`, `scratch_perturb_out.txt`, `scratch_json_compare_out.txt` | outputs of the three comparisons |

`scratch_compare.py --named` was not run to completion; the `--json` comparison covers the same systems.
