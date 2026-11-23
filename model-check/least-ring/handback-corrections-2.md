# Hand-back: corrections 2 to `part-a.md`, `results-minimal.md` and the added catalogue

All six points are done: 26 changes, 21 in `results-minimal.md` and 5 in `part-a.md`. I agreed with the reader on every point and found nothing of theirs wrong. `model-spec-scope.md` needed no change and has none. The catalogue of 465 and its answers are untouched.

## The six points

**1. Lemma M-scope fails as stated. Agreed, confirmed with my own program.**
- On the saved counterexample, G1 of scope `r` is 4 rounds in `first` (none within 3 rounds, every execution of at most 3 explored) and 3 in `second`. With `freeze` false both give 4. The runs were bounded at 4 rounds and stayed small (under 7,000 states).
- The class is narrowed and the proof's first sentence corrected (stated below).
- The counterexample is given under the lemma as a table of rounds, for both systems side by side.
- One sentence says the two uses are in the narrower class. I checked that they are: section 4.1's towers have thirteen monitors in thirteen boundaries and no substrate; section 5.3's ring with a fifth node has five monitors in five boundaries, no substrate and no `freeze`.

**2. `added/r2-readers/fifteen-edges` does not meet the whole list. Agreed.** In the old system D observes nobody, so R3 fails.
- It is replaced at `f` = 1, 2, 3 by the reader's set. I verified it meets the whole list at all three rates, with R3 read either way.
- `added/r2-readers/fourteen-edges/f1` is now that set without the state check of D. It still gives G1 and G2 in one round.
- `verify-impl\model.py`, run by me on the changed file, agrees on all 39 answers.
- No sentence of the write-ups presented the old system as a meeting set, so none needed correcting. The Files table's count of added systems is corrected from 36 to 39.

**3. Looser than shown. Agreed on all four.**
- Change 26 (the last bullet of `part-a.md`'s verdict): now "one over" where the watching runs one way and a flag passes both ways, "six of the nine readings with the report both ways".
- Change 12: told is judged in the round of the ring's first fault "if that fault leaves something bad, and in no other"; if the first fault is a stop with nothing bad, in no round.
- Change 14: the boundary hypothesis is needed by statement 1; the proof of statement 2 uses it; "that statement 2 itself needs it is not shown".
- Change 19: Theorem J's hypothesis of more than `f` initial monitors is named and said to be met (ring 1's four, `f` at most 3).

**4. Condition 2 under flow. Agreed.**
- I recomputed the reader's second top-last order (D2 and D3 in one step; the six members one at a time; each work process once its members are present; then T). It has no gap as one system under flow at `f` = 1, 2, 3 in every reachable state. **Checked**: `mr_model.py` and `verify-impl\model.py`, both run by me, finished it at all three rates (1,732, 17,733 and 118,732 states). The reader reports the same from two programs at `f` = 1 and 2 and from one at 3.
- The verdict and section 5.1 now say "at least two orders" and "sufficient cases and not a classification".
- "With scopes, top-last leaves told violated" now says it is **checked** for the one order, and gives the reader's argument for every top-last order, marked **Argued** and not run.
- The three systems for the new order are added to `systems-minimal-added.json`.

**5. The verdict bullet's first half. Agreed.** It now reads "at every number of levels when every monitor is in a boundary of its own (**proved**; **checked** at 13 and at 40 monitors)".

**6. Left behind. Agreed on all.**
- **Independent checking, both files.** The sentences now say:
  - an implementation written from the three specification files alone, by another party, gives the same answers on all 465 cases and on the added systems;
  - an independent reader recomputed the tables and counterexamples with a program of their own;
  - a second reader checked the corrections.

  `results-minimal.md` section 6 then lists what none of them checked, taken from their own lists. "Told has one author so far" is now "Told now has a second author".
- **"Under actor"** now has "with R5 read as the report edge" in sections 3 and 4.5 (three places).
- **Section 6:** "Lemma M carries the kind by kind searches, and Lemma M-scope of section 4.2 the halves of them made with scopes".
- **Section 4.2:** the `freeze` sentence uses the specification's wording: "no fault lands on a process of a closed scope and no step joins one".
- **Both "Not settled" lists** now say the verdict also turns on one choice each in R2 and R5.
- **The sentence under the table of `part-a.md` section 4** says the two rows on further readings were run by me at `f` = 1 with the work reading all only, and that the reader found the least numbers and verdicts the same at the other rates and with the work reading two. I did not rerun them.
- **The two table cells of section 4.3:** at `f` = 4, "every monitor of rings 2 and 3 and T flagged for ring 1"; with ring boundaries, "no live monitor holds a flag (the stopped monitors of ring 3 and T still hold theirs)".

## The lemma as it is now stated

> **Lemma M-scope (more edges never hurt, scope by scope). Proved,** for any two systems of `model-spec-scope.md` with no window, in which either no two monitors share a boundary and nothing runs on a substrate, or `freeze` is false, that have the same processes, scopes, work, lists, halt inputs and `freeze`, and differ only in that the second has more signal-read, state-check or report edges. For each scope and each of G1, G2 and told, and for spill, the least number of rounds to violate it in the second is at least that in the first.

The proof now opens: "In this class an environment step, where it is enabled, does the same in both systems to which processes are alive, bad or present. With no shared boundary and no substrate every step acts on one process or on one joining group, whatever is frozen; and without `freeze` no step looks at what is closed." It then says why this is false with `freeze` and a shared boundary or substrate. The rest of the proof is unchanged.

After it, the text says the lemma does not hold for added halt-input edges (as before), nor outside the class, with the counterexample table and its result: G1 of `r` in round 3 in the second system; least 4 in the first; 4 in both with `freeze` false.

## Anything of the reader's I found wrong

Nothing.

## Files

All in `«WORK»\sos-minimal-ring\`.

Changed:
- `part-a.md`
- `results-minimal.md`
- `systems-minimal-added.json`: 39 systems, with four replaced and three new.
- `results-minimal-added.json`: two answers changed (the fifteen-edge system at `f` = 2 and 3 now has no gap) and three new.
- `results-minimal-added-by-verify-impl.json`: rewritten for the 39.

Written:
- `corrections-2.md`: the six points and all 26 changes as before and after text.
- `part-a.before-corrections-2.md`
- `results-minimal.before-corrections-2.md`
- `systems-minimal-added.before-corrections-2.json`
- `results-minimal-added.before-corrections-2.json`
- `corrections_2.py`
- `corrections_2_apply.py`
- `corrections-2-lemma.txt`
- `corrections-2-order.txt`
- `corrections-2-added.txt`
- `corrections-2-added-verify-impl.txt`

Not changed: `model-spec-scope.md`, `systems-minimal.json`, `results-minimal.json`, `corrections-1.md`, and everything under `verify-impl\`, `verify-reader\` and `verify-corrections\`.
