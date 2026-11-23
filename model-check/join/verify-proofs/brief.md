I need an independent check of a write-up of results about a small transition-system model. The write-up states a verdict, several lemmas and theorems marked **Proved**, results marked **Checked** with counterexamples given as round-by-round tables, and counts. I want to know which of its statements do not hold as written. Try to refute each one. Do not take the write-up's word for anything: it is the subject, not a source.

## Where things are

Work only in this folder: `«WORK»\sos-join-model\verify-proofs\`

Do not open any other folder, in particular not the folders beside this one. You do not need the web.

- `model-spec.md`: the model, complete in 147 lines. A system, a state, one round, two goals G1 and G2, and the result computed for a system.
- `model-spec-join.md`: an extension in which monitors may be absent at the start and join.
- `results-join.md`: the write-up. This is the subject.
- `results-original.md`: the earlier results the write-up builds on. Its top defines the four evidence kinds (**Checked**, **Proved**, **Counted**, **Argued**), and it holds Theorem S, Theorem 0, the definition of a *plain* system and property P8b, which the write-up cites. Treat it as background: it has been checked separately, and it is not the subject, except where the write-up misquotes or misuses it.

## What to do

1. **Every statement marked Proved.** Read the proof against the two specification files. A statement is **Proved** only if the argument holds for every system of the class it names, of any size. For each: does every step follow from the specification as written? Is every hypothesis the proof uses stated in the statement? Is there a system of the stated class for which the conclusion fails? Look hardest at: steps that say "the same" or "similarly"; what is true of a monitor before it has joined and in the round it joins; a monitor that arrives bad; more than one fault in a round; the optional variants (no gate, slow reports, a window); and whether "no gap at `f`" is claimed for every `f` or only some.

2. **Every counterexample given as a table of rounds.** Step through it by hand against the specification: is each environment step enabled in the state it is taken in, is the number of steps in the round within `f`, and is the goal violated in the round the table says? Say of each whether it is a real execution with the result claimed.

3. **The verdict in the write-up's first lines, and each of its numbered conditions.** Does each sentence follow from something the write-up establishes, with the evidence kind it gives? Is anything said more widely than what is proved or checked supports (for instance "at every size" resting on systems of particular sizes without a proof for the class)?

4. **Your own search.** Write a small program of your own from the two specification files (Python is fine) that explores every reachable state of a system, and use it to look for counterexamples to the statements marked **Proved**: systems that meet a statement's hypotheses and violate its conclusion. Small systems are enough: three to six monitors, one or two work processes, `f` from 1 to 3. Also use it to confirm or refute a sample of the **Checked** results, the ones the verdict rests on first. Say how many systems you tried for each statement.

## What I want back

In the first lines: whether you found any statement that is false as written, and which.

Then, for each statement marked **Proved**: one of **holds**, **fails** (with a counterexample as a round-by-round table, or the step of the proof that does not follow and why), or **holds only with a hypothesis that is not stated** (which). Then the same for the verdict's sentences and conditions. Then the counterexample tables: real or not. Then a short list of what you could not check and why.

Do not report style or wording you would choose differently.

Your final message is the hand-back. I will keep it word for word, so make it complete and self-contained, and keep working notes out of it.

## Rules

- Keep runs modest: other work is running on this machine. Keep memory under about two gigabytes.
- Do not use git. Do not start other agents.
- If a tool restriction or anything else stops you from checking something, do not look for a way round it. Say plainly what you could not check.
