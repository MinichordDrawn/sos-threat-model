## Hand-back: independent implementation of the model, and its answers for `systems-minimal.json`

All 465 cases are answered, both sets of examples are reproduced, and I found one place where the reading changes answers (38 cases). I worked only inside `«WORK»\sos-minimal-ring\verify-impl\`, with no git, no web and no other agents, and I did not look for or see any other implementation or any results file.

### 1. Was every case answered?

Yes. `answers.json` has 465 entries in the order of `systems-minimal.json`: 128 not scoped (`id`, `G1`, `G2`) and 337 scoped (`id`, `G1`, `G2`, `scopes`, `spill`).

- **Nothing unfinished, nothing shrunk.** Every `null` comes from exploring every reachable state, or every execution of at most `max_rounds` rounds where the case carries that field.
- **Cost.** The whole catalogue takes about 50 CPU-seconds. The largest case is `c/minus/actor/TD1/one/f3` with 549,603 states. One process running the three largest cases in sequence peaked at 263 MB.
- **Summary counts, for a quick comparison:**
  - G1 is `null` in 381 cases, G2 in 378, both in 358.
  - `spill` is non-null in exactly one case, `example/4` (1).
  - 74 scoped cases have at least one non-null `told`.
  - There are 580 per-scope entries in all.
- **SHA-256 of `answers.json`:** `84af54e3c3aea8770c04922e2f831a8c9cf0b6708f4bfadfcac7a7aca69214bc`

### 2. Are the examples reproduced?

Yes, all of them, with no change made to the program for them.

- **J8.** I built the systems from the text of J8; all eight stated results are reproduced.
  - J8.1: `arrive_bad` true, f = 1, 2, 3 give `null`/`null`.
  - J8.2: f = 1 gives 2/2 without `arrive_bad` and 1/1 with it.
  - J8.3: without `arrive_bad`, f = 1 gives `null`/`null` and f = 2 gives 1/1; with `arrive_bad`, f = 1 gives 1/1.
- **X13.** Cases `example/1` to `example/9` reproduce every number written in X13, per scope, including `told` and `spill`. I compared against the numbers in the X13 text, since I do not have `results-minimal.json`.
- **Limit of the examples.** None has a late work process, so they cannot tell apart the two readings of place A below; both readings reproduce all of them.

### 3. Places where the specification is unclear, silent, or can be read two ways

#### A. The one place where the reading changes answers: an `after` entry naming a late work process

- J1 says an `after` entry "that names an initial monitor or a process listed in `works` is always satisfied".
- X1 says "An entry of `after` that names a late work process is satisfied once that process is present", and then "Nothing else in `model-spec-join.md` changes". The J1 sentence is never withdrawn in so many words.
- **What I implemented:** X1. It is the later file and is explicit.
- **The other reading:** the J1 sentence kept literally, so a group whose `after` names a late work process such as `W2` need not wait for it. Its answers are in `answers-other-reading.json` (same format, 465 entries).
- **38 cases differ, all in `d/grow`:**
  - `d/grow/author/flow/scoped/f1`, `f2`
  - `d/grow/author/actor/one/f1`, `f2`, `f3`
  - `d/grow/author/actor/scoped/f1`, `f2`
  - `d/grow/author-loose/flow/scoped/f1`, `f2`
  - `d/grow/author-loose/actor/scoped/f1`, `f2`
  - `d/grow/top-first/flow/one/f1`, `f2`, `f3` and `scoped/f1`, `f2`
  - `d/grow/top-first/actor/one/f1`, `f2`, `f3` and `scoped/f1`, `f2`
  - `d/grow/top-after-ring-2/flow/scoped/f2`
  - `d/grow/top-after-ring-2/actor/scoped/f2`
  - `d/grow/whole/flow/scoped/f1`, `f2`
  - `d/grow/whole/actor/one/f2`
  - `d/grow/whole/actor/scoped/f1`, `f2`
  - `d/grow/whole-top-first/flow/one/f1`, `f2`, `f3` and `scoped/f1`, `f2`
  - `d/grow/whole-top-first/actor/one/f1`, `f2`, `f3` and `scoped/f1`, `f2`
- **Example of the difference:** `d/grow/top-first/flow/one/f1` is G1 `null`, G2 `null` under X1, and G1 9, G2 6 under the J1 sentence (D3 joins in round 1 without waiting for W2).
- **Related stale sentences.** J2 still lists "the work processes" as present from the start, and J3 says `alive` initially holds "the processes listed in `works`". X1 contradicts both for a late work process. I followed X1: a late work process is absent until its group joins. I did not compute answers for J2 read literally.

#### B. Places that are unclear or silent but change no answer in this catalogue

1. **X2 against X7 on what freezing covers.** X2 says of a closed scope "nothing joins it"; X7 freezes a process only when its own `scope` entry is closed. A late work process covered by a closed scope through `scope_work`, but of another scope, is therefore not frozen. I implemented X7. I also ran the wider reading (a non-monitor process in the work of a closed scope is frozen too): 0 of 465 cases differ.
2. **X7's closing sentence** ("a closed scope is left exactly as it was when it closed") is looser than X7's own rules. Monitors of a closed scope still receive and pass on flags for other scopes, and a work process in its work but of another scope can still be mutated. I implemented the rules.
3. **X6 spill for a process covered by no scope.** "No process of a scope that covers w is faulty" is then vacuously true, so every halt of such a process is a spill. I implemented that. No case has such a process (checked).
4. **X6 told and switched-off monitors.** The "can hear" condition is "in `alive` and not in `bad`", which counts a switched-off monitor although by X4 it can receive nothing. I implemented it as written. No case has a switch.
5. **X2 edge cases.**
   - A system that is not scoped "has no `scope_work`, no `told` and no `freeze`"; if one did, my program ignores them. None does.
   - A scope id that appears only as a key of `scope_work` or `told` has no process, so all three of its judgements are `null`. None occurs.
6. **X12 output details.**
   - The order of keys in `scopes` is not specified. Mine is order of first appearance: `scope` values in the order monitors, works, joiner, then `scope_work` keys, then `told` keys.
   - Boundary ids are numbers in the data; I treat any JSON value as an id, and `null` as "none".
7. **Section 3.1, `fail-substrate`.** The enabling condition does not let the step fire when its only effect would be to hide a non-monitor process that is already visibly bad. I implemented it as written. No case has a substrate.

#### C. Design choices that could explain a difference if one turns up

- **Least n.** Computed by breadth-first search over states by rounds; the state includes `closed`. A round of zero environment steps is allowed. A responded state is recorded but never expanded.
- **Early stop.** The search stops early only when every judgement that can be violated at all has been found.
- **X6 and X7 timing.** A scope that closes in a round is still judged in that round (`closed` as at the start of the round).
- **Spill.** Judged for the whole system, including work covered by closed scopes; faults in closed scopes count as faulty.
- **Flags for a closed scope** still halt work that the scope covers (X5 makes no exception).
- **`told[s]`** does not count an absent late monitor as able to hear, because it is not in `alive`.
- **A system that is not scoped** runs through the same code with one internal scope that holds every process and covers every non-monitor process, with no told, no spill, no closing and no freeze. That is sections 3.2 to 3.5 and J6 exactly. The second program below codes the unscoped rules separately and agrees.

### 4. Checks I ran, and what they do and do not show

- **Second implementation, `naive.py`.** A slow, literal transcription with sets of names, with separate code for scoped and unscoped systems. It agrees with `model.py` on all 465 cases, entry for entry. Both are mine, so this rules out coding slips, not a misreading shared by both.
- **Random systems, `fuzz.py`.** The catalogue has no joiner, no substrate, no switch, no slow edge, `window` always 0, the gate always in place and `coupling` always true. Those parts are exercised only by J8.3 (slow edges) and by 400 random small systems using every field, on which the two programs agree (0 differ).
- **X11, `test_x11.py`.** Each of the 128 unscoped cases, given one scope for every process, with and without `freeze` and with and without `told` (512 variants), keeps its G1 and G2 and never spills.
- **X10, `test_x11.py`.** Of the 120 cases with `max_rounds`, 75 agree with their own unbounded run cut at the bound. The other 45 were not compared, because unbounded they exceed the limits I set for this check (400,000 states or 90 seconds). That check is separate from the answers, which honour the bound and all finished.

### 5. Things to know

- **Memory.** One early run of the random test let `naive.py` grow to about 0.7 GB in one process while other checks of mine were running. I stopped it and capped it. I did not measure the total at that moment; I believe it stayed under 2 GB but cannot prove it. The main program stays far below the limit.
- **Agreement between `model.py` and `naive.py` is not independent evidence** about the specification's meaning; the comparison with your other implementation is.
- **No tool restriction** stopped me from doing anything.

### 6. Files written, all in `«WORK»\sos-minimal-ring\verify-impl\`

- `answers.json`: the answers, 465 entries, format of section 5 and X12.
- `answers-other-reading.json`: the answers under the other reading of place A; 38 cases differ, listed above. SHA-256 `76cc66e513a406fe9ee0945d4cdca3d9942e40d0a589087d041db89028203499`.
- `model.py`: the program. Run `python model.py systems-minimal.json answers.json [--workers N] [--reading after-work-always|freeze-by-cover]`.
- `naive.py`: the second, literal implementation used as a cross-check.
- `test_examples.py`: the J8 and X13 examples; prints `ALL REPRODUCED`.
- `test_x11.py`: the X11 and `max_rounds` checks.
- `fuzz.py`: the random comparison of `model.py` and `naive.py`.
- `witness.py`: prints a shortest violating execution with its environment steps, for checking a disputed answer by hand. Run `python witness.py systems-minimal.json CASE-ID G1|G2|told|spill [SCOPE] [--reading NAME]`.
- `work\`: logs and by-products.
  - `log-final.json`, `run-final.txt`: per-case state counts for the final run.
  - `answers-naive.json`: `naive.py`'s answers, identical to `answers.json`.
  - `answers-freeze-by-cover.json`: identical to `answers.json`.
  - `test-x11.txt`, `fuzz-1.txt`, `naive-small.txt`, `naive-big.txt`, `run-awa.txt`, `run-fbc.txt`, `ids-small.json`, `ids-big.json`.

I did not modify the three specification files, `brief.md` or `systems-minimal.json`.

---

Comparison made afterwards by the coordinator (not part of the hand-back above): `answers.json` against `results-minimal.json`, entry by entry with key order ignored: 465 ids, the same ids in the same order, 0 entries differ. `answers-other-reading.json` differs from `results-minimal.json` in 38 entries, the 38 the hand-back lists: so the author's program implements the reading the implementer chose (X1), and the loose sentence in J1 against X1 is a real place where the specification needs one sentence corrected.
