I need an independent check of a set of corrections to two write-ups of results about a small transition-system model, and to one of its three specification files. The write-ups were checked once in full by an earlier reader and an independent implementation; these corrections are what those checks led to. Check the corrections and nothing else. Try to refute each corrected statement. Do not take the list's word for anything: it is the subject, not a source.

## Where things are

Work only in this folder: `«WORK»\sos-minimal-ring\verify-corrections\`

Do not open any other folder, in particular not the folder above this one or the folders beside it (the list of corrections names files there: you are not to read them). You do not need the web.

- `model-spec.md`, `model-spec-join.md`: the model and its first extension (monitors that join). Not changed.
- `model-spec-scope.md`: the second extension (scopes), as it is now, after ten passages were tightened. `model-spec-scope.before-corrections-1.md` is the file before.
- `part-a.md` and `results-minimal.md`: the two write-ups as they are now. The `.before-corrections-1.md` files are the write-ups before.
- `corrections-1.md`: the list of every change, with the text before and after, as its author gives it. This is the subject, together with the three diffs.
- `systems-minimal-added.json` and `results-minimal-added.json`: 36 systems the corrections rest on, in the specification's format, with the author's answers.
- Background, checked separately: `results-join.md` (Lemma M, Theorem J and others the write-ups cite), `results-original.md` (the four evidence kinds at its top; Theorem S; Theorem 0; P8b), and `lean-statements\` (statements proved in Lean that the write-ups cite by name).
- `independent_model.py`: an implementation of all three specification files that was written from them alone, by someone other than the write-ups' author, before the specification was tightened. It agrees with the author's program on 465 systems. Run `python independent_model.py <systems file> <answers file>`. You may use it, or write your own. If you use it, read enough of it to know what it computes.

## What the write-ups are about

A ring of four monitors drawn as nine arrows (three members in a cycle, a coordinator with an arrow to and from each), said by the model's author to be the least such ring, the arrows meaning "a connection"; and the same ring one level up (three rings under a top coordinator). The write-ups say whether it is least against six requirements R1 to R6, under different readings of what an arrow carries, and whether the structure repeats.

## What to check

1. **The list is the whole of the change.** Make the three diffs yourself. Every changed line must be in `corrections-1.md`, and every entry must be in the files as it says.

2. **The 36 added systems.** Compute them with `independent_model.py` or a program of your own and compare with `results-minimal-added.json`. Then check that each is the system the write-up says it is: build at least the ones the corrected verdicts rest on from the write-ups' own descriptions (the further readings of an arrow; rings 2 and 3 arriving whole and then the top coordinator; the top coordinator in one step with the second ring's coordinator; three rings and no top coordinator) and see that your system and the catalogue's give the same answers.

3. **Every corrected statement is true as it now stands.** For each entry of `corrections-1.md`, read the statement after the change in its place. If it gives a count or a result for named systems, recompute it. If it is marked **Proved**, read the argument and look for a system of the stated class for which it fails. Look hardest at:
   - **The table of readings of an arrow** (27 readings, their outcomes, "least under six, one connection over under twelve, short of R2 as stated under six, and four over under three"): recompute it on all 4,096 wirings for each reading. Is every reading in which an arrow carries all three kinds of edge counted once, are the families what they are said to be, and is there a fair reading of "a connection" that is in none of the 27 (an arrow that carries fewer than three kinds, for instance)?
   - **R2's and R5's other choices** (15 edges; 19 in 5,004 sets; 8 connections under actor with R5 as "D watches each member").
   - **Condition 2 on the goal, as restated**: under actor the top coordinator cannot be last in any order (marked proved from a check on three rings without it: is that a proof for every order, or for the orders that pass through that state?); under flow it can be last if rings 2 and 3 arrive whole and together in one step, and not if they arrive whole one after the other or coordinator by coordinator; with scopes, top-last leaves told violated; it need not be strictly first.
   - **Lemma M-scope**, newly stated and marked **Proved**: is the statement exactly what the proof shows, does it hold for added signal-read, state-check and report edges with and without freeze, and does the write-up use it only for such edges?
   - **Theorem J applied to systems with late work processes**: do the sentences given really show the proof carries over?
   - **The hypothesis "every monitor in a boundary of its own"** now on the statements of section 4.3: is it enough, and is it now stated wherever those statements are repeated (the verdict, section 4.6)?
   - **The verdicts in the first lines of both write-ups**: does each now say the same as the corrected statements it summarises, and no more?

4. **No correction made a statement wrong that was right before**, and none added a claim that is not supported where it stands.

5. **The ten tightened passages of `model-spec-scope.md` do not change the model.** For each: is the new text what the old text, read with `model-spec-join.md`, already meant in the reading `independent_model.py` implements (it was written from the old words)? Or does it settle something that could be read two ways, and could the other reading change a result? Say in particular whether X1's four replacements of sentences in `model-spec-join.md` leave that file's own results untouched for a system with no late work process.

6. **Left behind.** The author says two sentences are now out of date and were left because they were not on the list ("No independent reader has checked this part" in `part-a.md` section 6, and its like in `results-minimal.md` section 6), and that two true remarks on table cells of section 4.3 were not acted on. Say whether there are others: a sentence anywhere in the two write-ups that a correction has made untrue or out of date.

## What I want back

In the first lines: whether you found anything wrong, and what.

Then the six checks, each with what you did and what you found. For each entry of `corrections-1.md`, one of **holds**, **fails** (with the system and the execution as a round-by-round table, or the step that does not follow), or **could not check** (why). Then a short list of what you could not check.

Do not report style or wording you would choose differently.

Your final message is the hand-back. I will keep it word for word, so make it complete and self-contained, and keep working notes out of it.

## Rules

- Keep runs modest: other work is running on this machine. Keep memory under about two gigabytes. If a search is too large, bound it and say what the bound leaves out.
- Do not use git. Do not start other agents.
- If a tool restriction or anything else stops you from checking something, do not look for a way round it. Say plainly what you could not check.
