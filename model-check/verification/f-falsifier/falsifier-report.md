# Falsifier report

Claim under test (task.md): every plain system that is gap-free at f = 1 and has at least one
work process satisfies Q1, Q3, Q4 and Q8, except for monitors the system does not depend on
(spare monitors).

## 1. Outcome

**The claim is false. Falsifiers exist, and they are the majority of gap-free plain systems.**

| Predicate | In every gap-free plain system? | After spare monitors are deleted? |
|---|---|---|
| Q3 (state check) | **yes, no exception** (proved for every size, section 7) | yes |
| Q8 (halt sources) | **yes, no exception** (proved for every size, section 7) | yes |
| Q1 (signal) | no. Holds without exception with two monitors; fails from three monitors on | **still fails**: systems with no spare monitor at all fail it |
| Q4 (propagation) | no. Fails already with two monitors | **still fails**: systems with no spare monitor at all fail it |

So no predicate is in the class "holds only after spare monitors are deleted". Q3 and Q8 never
need the exception; Q1 and Q4 are not rescued by it.

The smallest falsifier has two monitors and seven edges (Q4). The smallest falsifier for Q1 has
three monitors and nine edges. Both are written out in section 6.

## 2. How the task was read

* Gap-free at f = 1: the result of model-spec.md section 4 is `null` for G1 and for G2 with `f`
  set to 1.
* Plain, Q1, Q3, Q4, Q8, S − m, spare: word for word from task.md.
* Falsifier. The sentence "after deleting spare monitors one at a time, in any order, for as
  long as any monitor is spare, the system that remains still fails one of the four predicates"
  can be read two ways when the order matters. Both were computed:
  * **strict**: every order of deletion ends in a system that fails a predicate;
  * **partial**: some order does, some order does not. These are counted apart and are not
    called falsifiers below.
  * A system that fails a predicate and has **no spare monitor at all** is a falsifier under any
    reading, since nothing can be deleted. All the falsifiers written out in this report are of
    that kind. A falsifier exists if and only if one of that kind exists (the end of every
    deletion sequence is such a system).
* "Edges" below means the total number of entries in `hb_readers`, `checkers`, `fwd` and
  `halt_inputs`. It is only used to say which falsifiers are smallest.
* Self-loops (`m` in `hb_readers[m]`, `checkers[m]` or `fwd[m]`) never matter: a stopped or bad
  monitor is not active, and Q1, Q3, Q4 exclude the process itself. This was not assumed for
  the two-monitor case (all 2^16 systems with self-loops were run) and is assumed above it.

## 3. Implementations and how they were checked against each other

Three deciders, written from model-spec.md only. No other implementation was looked at.

| File | What it is |
|---|---|
| `model.py` | Reference. Sets and breadth-first reachability, every field of the spec, both variants (no gate, slow reports), returns the least round for G1 and G2 and a witness execution. |
| `plain.py` `gap_free_bfs` | Bitmask reachability for plain systems at f = 1. No structural shortcut. |
| `plain.py` `allowed_sets` | Same exploration organised per mutated process (see section 8, fact B). The fact it rests on is asserted at run time. |
| `census.py` | A faster re-implementation of `allowed_sets` with closure tables, used for four monitors. |

Checks, all passing with zero disagreements:

* `test_model.py`: 13 systems whose G1/G2 values were worked out by hand before the code was
  run (plain pair, one halt input, one monitor, window 1, no gate, slow reports, a switch,
  f = 2, a substrate, a shared boundary, a joiner, coupling off).
* `crosscheck.py`: all 65,536 two-monitor/one-work plain systems with self-loops, and 15,500
  random plain systems with 3 to 5 monitors and 1 or 2 work processes with self-loops:
  `model.py` = `gap_free_bfs` = `allowed_sets`.
* `honest_3x1.py`: all 16,777,216 three-monitor/one-work systems decided by `gap_free_bfs` with
  no pruning and no symmetry; the set of gap-free systems (1,169,616) is identical, element by
  element, to the set produced through `allowed_sets`.
* `census.py 3` reproduces every count of the one-by-one search for three monitors.
* `validate_census.py` (four monitors): 20,000 random triples against `allowed_sets`; 6,000
  random systems against `model.py`; 8,212 single-monitor deletions (4,080 spare) against
  `model.py` on the JSON system with the monitor deleted as task.md says; the counting formula
  for "no spare monitor" against a one-by-one count on 60 triples (156,705 systems).
* `verify_falsifiers.py`: every falsifier quoted in this report re-judged with `model.py` and
  JSON-level definitions of plain, Q1, Q3, Q4, Q8, S − m and spare only.

## 4. What the search covered

| Monitors, work processes | Systems | How | Script |
|---|---|---|---|
| 2, 1 | 65,536 (self-loops included) | every system, reference implementation only | `exhaustive_2x1_reference.py` |
| 2, 1 | 1,024 (no self-loops) | every system | `search_small.py 2 1` |
| 2, 2 | 16,384 (no self-loops) | every system | `search_small.py 2 2` |
| 3, 1 | 16,777,216 (no self-loops) | every labelled system, no symmetry reduction, decided twice (plain reachability; per-process sets) | `honest_3x1.py`, `search_small.py 3 1`, `search_par.py 3 1 classes` |
| 3, 2 | 1,073,741,824 (no self-loops) | every labelled system; each gap-free one visited one by one | `search_par.py 3 2` |
| 4, 1 | 17,592,186,044,416 (no self-loops) | complete, but by counting, not one by one (below) | `census.py 4` |
| 4, 2 / 5, 1 / 5, 2 / 6, 2 | 3,499,776 / 1,107,754 / 1,027,213 / 365,226 | random sample only | `sample_large.py` |

How four monitors and one work process were made feasible (`census.py`):

* For fixed `hb_readers`, `fwd`, `halt_inputs` the gap-free choices of `checkers` are a product
  of one set per process (fact B, section 8). The census visits all 2^28 triples and counts
  products instead of visiting 2^44 systems.
* The only symmetry reduction: monitors are renamed so the halt inputs come first, so
  `halt_inputs[w]` is one of five shapes and each count is multiplied by 1, 4, 6, 4, 1. All
  4096 × 4096 pairs of `hb_readers` and `fwd` are visited for each shape.
* Systems with no spare monitor are counted by inclusion-exclusion over the sets of monitors
  that are spare; "m is spare" is decided from the three-monitor tables.
* The fewest-edge falsifiers are found exactly (inclusion-minimal checker lists of every
  feasible triple).
* Not computed for four monitors: the strict/partial verdict of systems that do have spare
  monitors. It is not needed to decide whether falsifiers exist.

The samples: each system has independent random edge densities per relation (several levels,
`fwd` including empty). Each gap-free sample is judged, then thinned (edges removed in random
order while it stays gap-free) and judged again. The run is time-boxed (60 s per size on 12
processes), so the sample counts above are from my run and will differ on another machine.

Not covered: f other than 1; non-plain systems; systems with no work process; more than one
work process with four monitors other than by sampling; anything above six monitors.

Longest single program run: `sample_large.py`, about four and a half minutes; `census.py 4`,
about two and a half minutes.

## 5. Results

Counts are labelled systems without self-loops. "No spare" = gap-free with no spare monitor.

| | 2 mon, 1 work | 2 mon, 2 work | 3 mon, 1 work | 3 mon, 2 work | 4 mon, 1 work |
|---|---|---|---|---|---|
| systems | 1,024 | 16,384 | 16,777,216 | 1,073,741,824 | 17,592,186,044,416 |
| gap-free | 12 | 36 | 1,169,616 | 25,364,400 | 3,753,341,342,976 |
| gap-free failing Q3 or Q8 | 0 | 0 | 0 | 0 | 0 |
| gap-free failing Q1 | 0 | 0 | 178,176 | 3,546,240 | 714,172,039,680 |
| gap-free failing Q4 | 9 | 27 | 798,222 | 16,284,462 | 2,099,158,352,622 |
| no spare | 12 | 36 | 742,352 | 20,131,760 | 924,423,748,864 |
| no spare, all four hold | 3 | 9 | 227,322 | 6,784,002 | 385,722,806,764 |
| no spare, only Q1 fails | 0 | 0 | 23,904 | 824,256 | 69,543,215,544 |
| no spare, only Q4 fails | 9 | 27 | 447,446 | 11,128,622 | 389,452,892,436 |
| no spare, Q1 and Q4 fail | 0 | 0 | 43,680 | 1,394,880 | 79,704,834,120 |
| **falsifiers with no spare monitor** | **9** | **27** | **515,030** | **13,347,758** | **538,700,942,100** |
| the same, up to renaming | 5 | 10 | 85,895 | not counted | not counted |
| fewest edges: Q4 / Q1+Q4 / Q1 only | 7 / – / – | 10 / – / – | 9 / 9 / 11 | 12 / 12 / 14 | 11 / 11 / 13 |

With self-loops, two monitors and one work process: 65,536 systems, 768 gap-free, 576
falsifiers (all Q4), 192 satisfying all four, none with a spare monitor.

Systems that do have spare monitors and fail a predicate (three monitors):

| | 3 mon, 1 work | 3 mon, 2 work |
|---|---|---|
| strict falsifiers in total (with or without spare monitors) | 789,294 | 16,714,734 |
| of which with spare monitors | 274,264 | 3,366,976 |
| partial (depends on the deletion order) | 3,276 | 16,464 |
| failure fully blamed on spare monitors | 60,660 | 750,768 |

Per predicate, three monitors and one work process:

* Q1 fails in 178,176 gap-free systems: 67,584 have no spare monitor; in the other 110,592
  Q1 holds after deletion in every order (only two monitors remain, and two-monitor gap-free
  systems always satisfy Q1).
* Q4 fails in 798,222: 491,126 have no spare monitor; 258,712 have spare monitors and still fail
  Q4 after every deletion order; 3,276 depend on the order; 45,108 are repaired by deletion.

Samples of larger systems (no Q3 or Q8 failure in any gap-free sample):

| | sampled | gap-free | no spare | no spare failing Q1 or Q4 |
|---|---|---|---|---|
| 4 mon, 2 work | 3,499,776 | 524,846 | 74,784 | 54,818 |
| 5 mon, 1 work | 1,107,754 | 368,734 | 6,877 | 4,713 |
| 5 mon, 2 work | 1,027,213 | 258,526 | 10,026 | 6,664 |
| 6 mon, 2 work | 365,226 | 130,852 | 1,163 | 785 |

After thinning, the no-spare systems failing Q1 or Q4 were 344,148 of 345,134 (4 mon, 2 work),
135,908 of 135,908 (5, 1), 138,192 of 139,018 (5, 2) and 56,041 of 56,495 (6, 2).

## 6. The falsifiers

Every system below has `"f": 1, "joiner": null, "substrate": {}, "switches": [],
"coupling": true, "window": 0, "gate": true, "slow_reports": false` and one boundary per
monitor (`"boundary": {"a": "b_a", "b": "b_b", ...}`). Only the remaining fields are printed.
The complete JSON objects, the reference verdicts, the reason each monitor is not spare (the
shortest violating execution of S − m) and the complete list of executions are in
`falsifiers.json` and `falsifiers.txt` (44 systems: 41 no-spare falsifiers and 3 illustrations
with spare monitors).

### 6.1 Smallest of all: two monitors, Q4 fails (7 edges) — `F2x1-Q4-1`

```json
{"monitors": ["a", "b"], "works": ["w"],
 "hb_readers": {"a": ["b"], "b": ["a"]},
 "checkers": {"a": ["b"], "b": ["a"], "w": ["a"]},
 "fwd": {},
 "halt_inputs": {"w": ["a", "b"]}}
```

* Fails Q4: there is no `fwd` edge at all, so b cannot be reached from a.
* No spare monitor: a system with one monitor is never gap-free (`mutate` it: nobody flags).
* Why no execution violates a goal. There are five possible first steps and each ends the
  execution in a responded state after one round:

  | step | who flags | why w halts |
  |---|---|---|
  | stop a | b reads a | a is silent (coupling), and b is a flagged halt input |
  | stop b | a reads b | same, mirrored |
  | mutate a | b checks a | b is a flagged halt input |
  | mutate b | a checks b | a is a flagged halt input |
  | mutate w | a checks w | a is a flagged halt input |

  The monitor that detects is always itself a halt input, so no flag ever has to be reported to
  another monitor. With two monitors `fwd` has no effect on gap-freedom at all: the 12 gap-free
  systems are 3 choices of `checkers[w]` times all 4 `fwd` relations, and only the one with both
  edges satisfies Q4. Nine labelled falsifiers, five up to renaming (576 with self-loops).

### 6.2 Three monitors, Q1 and Q4 fail (9 edges) — `F3x1-Q1Q4-1`

```json
{"monitors": ["a", "b", "c"], "works": ["w"],
 "hb_readers": {"a": [], "b": ["c"], "c": ["b"]},
 "checkers": {"a": ["b"], "b": ["c"], "c": ["b"], "w": ["b"]},
 "fwd": {"c": ["a"]},
 "halt_inputs": {"w": ["a", "b"]}}
```

* Fails Q1: nobody reads a's liveness signal. Fails Q4: a and b report to nobody.
* No spare monitor. Without a: `mutate b` is flagged by c only, c is not a halt input and has
  nobody left to report to, w takes a work step (G2 in round 1). Without b: `mutate a` has no
  checker (G1 in round 1). Without c: `mutate b` has no checker (G1 in round 1).
* Why no execution violates a goal:
  * `stop a` raises no flag at all. That is not a violation: both goals are only judged in a
    round where some process is bad, and a stopped monitor is not bad. w halts at once on a's
    silence, because a is one of its halt inputs. The state is not responded, so the execution
    goes on, and b and c are still a complete pair: they read each other and between them check
    a, b, c and w. Whatever comes next (stop b, stop c, mutate a, b, c or w) is flagged by a
    live healthy monitor in that round; w is already halted; the state is responded.
  * From the start, every other step is flagged in its round and w halts in its round:
    stop b (c reads b and reports to a; w halts), stop c (b reads c), mutate a (b checks a),
    mutate b (c checks b and reports to a, a halt input), mutate c and mutate w (b checks).

Two more systems of this size (`F3x1-Q1Q4-2`, `-3`) differ only in who checks w or in replacing
the report c → a by a second checker of b.

### 6.3 Three monitors, Q1 alone fails (11 edges) — `F3x1-Q1-1`

The system of 6.2 with a full reporting ring:

```json
{"monitors": ["a", "b", "c"], "works": ["w"],
 "hb_readers": {"a": [], "b": ["c"], "c": ["b"]},
 "checkers": {"a": ["b"], "b": ["c"], "c": ["b"], "w": ["b"]},
 "fwd": {"a": ["b"], "b": ["c"], "c": ["a"]},
 "halt_inputs": {"w": ["a", "b"]}}
```

Q3, Q4 and Q8 hold; Q1 fails for a. Same reason as 6.2. No spare monitor (same three
violations).

### 6.4 Three monitors, Q4 alone fails (9 edges) — `F3x1-Q4-1`

```json
{"monitors": ["a", "b", "c"], "works": ["w"],
 "hb_readers": {"a": ["b"], "b": ["a"], "c": ["a"]},
 "checkers": {"a": ["b"], "b": ["c"], "c": ["b"], "w": ["b"]},
 "fwd": {},
 "halt_inputs": {"w": ["b", "c"]}}
```

* Q1, Q3, Q8 hold; `fwd` is empty.
* Every first step ends the execution in one round: stop a (b reads a; b is a halt input),
  stop b (a reads b; w halts on b's silence), stop c (a reads c; w halts on c's silence),
  mutate a (b checks), mutate b (c checks, c is a halt input), mutate c and mutate w (b checks).
* No spare monitor. a is not a halt input and reports to nobody, yet it is needed: without a,
  `stop b` is read by nobody, and `mutate c` in the next round has no live checker (G1 in
  round 2). a's own flag is what keeps `out` non-empty; the work halts by silence. A flag that
  only has to exist does not have to travel.

Twelve systems of this size up to renaming (`F3x1-Q4-1` to `-12`).

### 6.5 Four monitors: both halt inputs unwatched, Q1 alone fails (13 edges) — `F4x1-Q1-1`

```json
{"monitors": ["a", "b", "c", "d"], "works": ["w"],
 "hb_readers": {"a": [], "b": [], "c": ["d"], "d": ["c"]},
 "checkers": {"a": ["c"], "b": ["d"], "c": ["d"], "d": ["c"], "w": ["c"]},
 "fwd": {"a": ["c"], "b": ["d"], "c": ["b"], "d": ["a"]},
 "halt_inputs": {"w": ["a", "b"]}}
```

Neither halt input has a reader. Either can stop silently (w halts on the silence), then the
other (still silent), and c and d, which read and check each other and check a, b and w, flag
whatever comes third. No spare monitor: without a or b, w has one halt input (G2 in round 1);
without c or d, a or b has no checker (G1 in round 1). Dropping the two reports a → c and b → d
gives the 11-edge Q1+Q4 falsifier `F4x1-Q1Q4-1`. At four monitors 1,915,467,264 no-spare
systems have two reader-less monitors.

### 6.6 Four monitors, Q4 alone fails (11 edges) — `F4x1-Q4-1`

```json
{"monitors": ["a", "b", "c", "d"], "works": ["w"],
 "hb_readers": {"a": ["b"], "b": ["a"], "c": ["a"], "d": ["c"]},
 "checkers": {"a": ["b"], "b": ["d"], "c": ["b"], "d": ["b"], "w": ["b"]},
 "fwd": {},
 "halt_inputs": {"w": ["b", "d"]}}
```

This one shows a third tolerated situation: after `stop c`, a raises a flag but w keeps working
(neither a nor c is a halt input and nothing is reported). That is not a violation, because no
process is bad. Every step after it is flagged and halts w in its round.

### 6.7 The two families, in plain words

Both goals are judged only in a round where some process is bad. G1 then needs one flag on
one live, healthy monitor. G2 then needs every work process to be halted, and a work process
halts on a flagged halt input **or on the silence of a halt input**. Nothing more is required,
and that leaves room for two kinds of system.

**Family A — the flag never has to travel (Q4 fails; from two monitors on).** Whenever a
process goes bad, a monitor that checks it is a halt input of every work process still
running, or the work processes were already halted by an earlier silence. Reports between
monitors are then optional, in part or in whole. With three monitors and one work process,
13,143 gap-free systems (6,467 with no spare monitor) have no `fwd` edge at all; since adding
edges never loses gap-freedom (fact A), each stays gap-free under all 64 `fwd` relations, which
is 841,152 of the 1,169,616 gap-free systems. With four monitors: 493,015,245 gap-free systems
with empty `fwd`, 61,709,704 of them with no spare monitor. Where a report is needed it is
needed along particular edges (from a checker that is not a halt input to one that is), not
between every pair of monitors.

**Family B — an unwatched halt input (Q1 fails; from three monitors on).** A monitor nobody
reads can stop without a flag. This is harmless when (1) its silence halts the work processes
that listen to it, and (2) the monitors that remain still read and check one another and
check everything else, so that the next step is flagged. Such a monitor is not spare, because
it is one of the two halt inputs a work process needs (Q8) or a needed checker.

Systems with spare monitors that are still falsifiers under the strict reading are these
families with an extra monitor attached, for example the two-monitor pair of 6.1 plus a third
monitor that one of them checks (`I3x1-with-spare-strict`, 8 edges): the third monitor is spare
and deleting it leaves the pair, which fails Q4.

## 7. Which predicates hold without exception, and which do not

**Q3 holds in every gap-free plain system, at every size.** In round 1 the environment may
`mutate x` for any process x. Nothing is stopped and nothing is flagged yet, so the only
possible detection is by a member of `checkers[x]` other than x (x itself is bad, so not
active). If there is none, `out` is empty while `bad` is not: G1 is violated in round 1.

**Q8 holds in every gap-free plain system, at every size.** Take a work process w and any
monitor h, and `mutate h` in round 1. Every monitor is alive, so w cannot halt on silence; it
halts only if a halt input of w is in `out`, and `out` does not contain h. Otherwise w takes a
work step while `bad` is non-empty: G2 in round 1. So for every monitor h, `halt_inputs[w]`
contains a monitor other than h; hence it has at least two members.

Both were also confirmed by the counts: zero gap-free systems fail Q3 or Q8 in every exhaustive
set and in every sample.

**Q1** holds in every gap-free system with two monitors (12 of 12; 768 of 768 with self-loops).
From three monitors on it fails, and deleting spare monitors does not restore it: 67,584
systems (3 monitors, 1 work), 2,219,136 (3, 2) and 149,248,049,664 (4, 1) fail Q1 and have no
spare monitor.

What does survive of Q1: **in a gap-free plain system with no spare monitor, every monitor
without a reader is in some `halt_inputs` list.** Zero exceptions among all no-spare systems of
the exhaustive sets and of the thinned samples. Proof: let m have no reader and be in no
`halt_inputs` list. Any execution of S − m becomes an execution of S by putting a round
`stop m` in front. That round changes nothing but `alive` (nobody reads m, nobody halts on its
silence, nothing is bad), and afterwards m is not active, so the two systems move in step and a
violation of S − m is a violation of S. So S − m is gap-free and m is spare.

**Q4** fails from two monitors on, with and without spare monitors: 491,126 (3, 1), 12,523,502
(3, 2) and 469,157,726,556 (4, 1) no-spare systems fail it. I found no weaker form of Q4 that
holds; a monitor that is neither a halt input nor reports to anyone can still be indispensable
(system 6.4).

## 8. Structural facts found on the way

Each was checked, not assumed, where the searches depend on it.

* **A. Adding an edge never loses gap-freedom.** With more entries in any of the four
  relations, the same environment steps give at least the same flags and the same halts. So a
  state that is responded in the smaller system is responded in the larger one, every
  execution of the larger system is an execution of the smaller one, and every violation of
  the larger system is a violation of the smaller. Checked exhaustively for
  (2, 1), (2, 2) and (3, 1): zero counter-examples (`search_small.py`). Consequences: the
  failing predicates of a system are inherited by every gap-free system below it; a system with
  no spare monitor stays so when edges are removed and it remains gap-free; the fewest-edge
  falsifiers are edge-minimal gap-free systems. Of the 119 edge-minimal gap-free systems (up to
  renaming) with three monitors and one work process, all 119 fail Q4 and 11 also fail Q1; with
  two work processes all 783 fail Q4.
* **B. Executions of a plain system at f = 1 are a run of stop (or idle) rounds followed by at
  most one mutate round.** While `bad` is empty no goal can be violated. In the first round in
  which a process is bad, either a goal is violated or `out` is non-empty and no work process
  took a step, which with window 0 means all are halted: the state is responded and the
  execution is over. Hence for fixed `hb_readers`, `fwd`, `halt_inputs` the gap-free choices of
  `checkers` are a product of one set per process. `plain.allowed_sets` asserts the "violated
  or responded" step every time it is used, and its output equals unrestricted reachability on
  all 2^24 three-monitor systems.
* **C. Idle rounds change nothing** in a plain system (asserted in `verify_falsifiers.py` for
  every state of every reported system; not relied on by the deciders, which explore the idle
  round like any other).

## 9. Limits of this account

* Only the claim as stated: plain systems, f = 1. Nothing here says what happens at f = 2 or
  with any non-plain feature.
* Four monitors with one work process is complete only through the counting argument of
  section 4, cross-checked on random samples (section 3), not through visiting each system.
* Four monitors with two work processes and all larger sizes are samples. The absence of Q3 or
  Q8 failures there adds nothing to the proofs of section 7; the presence of Q1 and Q4
  falsifiers there is certain, since each reported one was re-judged by the reference.
* Class counts up to renaming were computed only where the table says so.
* The reference implementation keeps the joiner out of `works` if it is listed there; no plain
  system has a joiner, so this choice does not touch the result.

## 10. Files

| File | Purpose |
|---|---|
| `model.py` | reference implementation of model-spec.md (`python -I model.py systems.json answers.json`) |
| `test_model.py` | 13 hand-derived expectations |
| `plain.py` | bitmask deciders, predicates, S − m, renaming, JSON conversion |
| `crosscheck.py` | the three deciders against each other |
| `exhaustive_2x1_reference.py` | two monitors, one work process, self-loops, reference only |
| `search_small.py` | one-by-one search (2, 1), (2, 2), (3, 1) → `result_2x1.json`, `result_2x2.json`, `result_3x1.json` |
| `search_par.py` | the same in parallel, (3, 1) and (3, 2) → `result_3x1_par.json`, `result_3x2_par.json` |
| `honest_3x1.py` | all 2^24 systems by plain reachability, compared with the per-process sets |
| `census.py` | (4, 1) census → `census_4x1.json`, `census_4x1_log.txt`, `census_4x1_two_silent.json`; `census.py 3` → `census_3x1.json` |
| `validate_census.py` | census against `plain.py` and `model.py` on random samples |
| `sample_large.py` | samples of larger sizes → `sample_large.json` |
| `verify_falsifiers.py` | final judgement of the reported systems by the reference → `falsifiers.json`, `falsifiers.txt` |
| `show.py` | prints the smallest systems of a result file |

Every script is run as `python -I <script> [arguments]` from this folder, standard library
only. `python -I` does not put the script folder on the module path, so each script adds its
own folder.
