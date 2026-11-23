I need an independent implementation of a small transition-system model, written from its specification alone, and its answers for a catalogue of systems. Another implementation exists and its answers will be compared with yours afterwards. You must not see it: the comparison is only worth making if yours is written from the specification and nothing else.

## Where things are

Work only in this folder: `«WORK»\sos-minimal-ring\verify-impl\`

Do not open any other folder, in particular not the folder above this one or the folders beside it. You do not need the web.

- `model-spec.md`: the model, complete. A system, a state, one round, two goals G1 and G2, and the result to compute for a system.
- `model-spec-join.md`: an extension in which monitors may be absent at the start and join.
- `model-spec-scope.md`: a further extension in which each process belongs to a scope, a flag carries its scope, and the goals are judged scope by scope, with two further things judged ("told" and "spill"), a way of closing a scope, and a bound on rounds. A system with none of an extension's fields is the model without that extension. This third file is new and has been read by nobody but its author, so it is the one most likely to be unclear.
- `systems-minimal.json`: a list of 465 cases, each `{"id": ..., "system": {...}}`.

## What I want

1. A program, in Python, written by you from the three specification files, that computes for a system the result the specification defines, in the form its section on files gives (for a system with scopes that is more than G1 and G2: read `model-spec-scope.md` X10 and X12).

2. `answers.json` in this folder: one entry per case of `systems-minimal.json`, in the same order, in the answer format the specification gives.

3. Wherever the specification is unclear, silent, or can be read two ways and the reading changes an answer: do not guess silently. List each such place in your hand-back, say which reading you implemented and why, and if it is cheap, give the answers under the other reading as well (in `answers-other-reading.json`, with a note of which cases differ). These places are as valuable to me as the answers. Expect more of them in the third file than in the first two.

4. The two extensions give small examples with their results (J8, and X13). Use them as a test of your program and say whether it reproduces them. If it does not, do not bend the program to them: say what the specification says and what the example says.

## Rules

- Write the program yourself from the specification. Do not look for another implementation.
- Some cases are large (forty monitors) or carry a bound on rounds for that reason. Keep memory under about two gigabytes: other work is running on this machine. If some cases are too large to finish, give the answers you have, list the cases you could not finish, and say why. Do not shrink a case to make it finish.
- Do not use git. Do not start other agents.
- If a tool restriction or anything else stops you from doing something, do not look for a way round it. Say plainly what you could not do.

Your final message is the hand-back. I will keep it word for word: say whether every case was answered, whether the examples are reproduced, every place the specification was unclear and what you did there, and the files you wrote.
