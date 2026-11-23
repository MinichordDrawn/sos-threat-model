I need an independent implementation of a small transition-system model, written from its specification alone, and its answers for a catalogue of systems. Another implementation exists and its answers will be compared with yours afterwards. You must not see it: the comparison is only worth making if yours is written from the specification and nothing else.

## Where things are

Work only in this folder: `«WORK»\sos-join-model\verify-impl\`

Do not open any other folder, in particular not the folders beside this one. You do not need the web.

- `model-spec.md`: the model, complete. A system, a state, one round, two goals G1 and G2, and the result to compute for a system.
- `model-spec-join.md`: an extension of it in which monitors may be absent at the start and join. A system with none of the extension's fields is the original model.
- `systems-join.json`: a list of 5,658 cases, each `{"id": ..., "system": {...}}`.

## What I want

1. A program, in Python, written by you from the two specification files, that computes for a system the result the specification defines: for each of G1 and G2, the least number of rounds in which some execution violates it, or `null` if no execution of any length does. Decide `null` by exploring every reachable state, as the specification says.

2. `answers.json` in this folder: a list of `{"id": ..., "G1": n or null, "G2": n or null}`, one entry per case of `systems-join.json`, in the same order.

3. Wherever the specification is unclear, silent, or can be read two ways and the reading changes an answer: do not guess silently. List each such place in your hand-back, say which reading you implemented and why, and if it is cheap, give the answers under the other reading as well (in `answers-other-reading.json`, with a note of which cases differ). These places are as valuable to me as the answers.

4. The extension gives three small examples with their results (its section J8). Use them as a test of your program and say whether it reproduces them. If it does not, do not bend the program to them: say what the specification says and what the example says.

## Rules

- Write the program yourself from the specification. Do not look for another implementation.
- Keep it modest: other work is running on this machine. Keep memory under about two gigabytes. If some cases are too large to finish, give the answers you have, list the cases you could not finish, and say why.
- Do not use git. Do not start other agents.
- If a tool restriction or anything else stops you from doing something, do not look for a way round it. Say plainly what you could not do.

Your final message is the hand-back. I will keep it word for word: say whether every case was answered, whether the three examples are reproduced, every place the specification was unclear and what you did there, and the files you wrote.
