I need an independent check of a set of corrections to a write-up of results about a small transition-system model, and to one of its two specification files. The write-up was checked once in full by an earlier reader; these corrections are what that check led to. Check the corrections and nothing else. Try to refute each corrected statement. Do not take the list's word for anything: it is the subject, not a source.

## Where things are

Work only in this folder: `«WORK»\sos-join-model\verify-corrections\`

Do not open any other folder, in particular not the folders beside this one (the list of corrections names files there: you are not to read them). You do not need the web.

- `model-spec.md`: the model, complete. A system, a state, one round, two goals G1 and G2, the result computed for a system.
- `model-spec-join.md`: an extension in which monitors may be absent at the start and join. As it is now, after six sentences were tightened. `model-spec-join.before-corrections-1.md` is the file before.
- `results-join.md`: the write-up as it is now. `results-join.before-corrections-1.md` is the file before.
- `corrections-1.md`: the list of every change, with the text before and after, as its author gives it. This is the subject, together with the two diffs.
- `results-original.md`: the earlier results the write-up builds on (the four evidence kinds at its top, Theorem S, Theorem 0, a *plain* system, P8b). Background, checked separately.
- `independent_model.py`: an implementation of the two specification files that was written from them alone, by someone other than the write-up's author, and agrees with the author's program on 5,658 systems. You may use it to explore systems, or write your own from the specification. If you use it, say so, and read enough of it to know how to give it a system.

## What to check

1. **The list is the whole of the change.** Make the two diffs yourself. Every changed line must be in `corrections-1.md`, and every entry of `corrections-1.md` must be in the files as it says. Say what, if anything, is changed and not listed, or listed and not changed.

2. **Every corrected statement of the write-up is true as it now stands.** For each entry under A in `corrections-1.md`: read the statement after the change, in its place in `results-join.md`. If it is marked **Proved**, read the argument against the specification and look for a system of the stated class for which it fails. If it is marked **Checked** or states a result for a named system, build the system and compute it. Look hardest at:
   - Theorem L with its added hypothesis, the paragraph after its proof, and the new table of four rounds: is the hypothesis enough, is the table a real execution with the result claimed, and is "the least for both goals is 4 rounds" so?
   - The new table of least attachments of a joining ring in section 8 (640, 512, 320 least attachments; 12, 36, 68 greatest sets holding none of them), the statement that every set of edges holding no listed attachment lies inside one of the greatest sets (**proved** by a case division), and the system the list gives as showing an earlier check was incomplete: KB with every one of the 24 edges except the four reports from ring A to KB, said to have a gap at `f` = 1 that any one of those reports closes. Recompute what you can and say what you could not.
   - The corrected sentences of the verdict in the first lines: does each now say the same as the corrected statement it summarises, and no more?
   - The count 12,324 as now spelled out: do the parts given add up, and do they match what the sections say was run?

3. **No correction made a statement wrong that was right before**, and none added a claim that is not supported where it stands.

4. **The six tightened sentences of the specification do not change the model.** For each: is the new sentence a consequence of what the two specification files already said, so that a program written from the old words and one written from the new must compute the same? Or does it settle something that could have been read two ways, and if so, could the other reading change a result? `independent_model.py` was written from the old words.

## What I want back

In the first lines: whether you found anything wrong, and what.

Then the four checks, each with what you did and what you found. For each entry of `corrections-1.md`, one of **holds**, **fails** (with the system and the execution as a round-by-round table, or the step that does not follow), or **could not check** (why). Then a short list of what you could not check.

Do not report style or wording you would choose differently.

Your final message is the hand-back. I will keep it word for word, so make it complete and self-contained, and keep working notes out of it.

## Rules

- Keep runs modest: other work is running on this machine. Keep memory under about two gigabytes.
- Do not use git. Do not start other agents.
- If a tool restriction or anything else stops you from checking something, do not look for a way round it. Say plainly what you could not check.
