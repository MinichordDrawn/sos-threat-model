# The generator

`gen.py` writes every file under `SelfObserving/Generated/`. It reads one thing: the
model check's checker, `check_model.py`. Each generated file states what that checker
computes, and Lean has to prove it. The generator decides nothing.

## Running it

Python 3.9 or later, standard library only (the files here were written with 3.12.2, and
no other version was tried). From the project folder:

```
python -I -B tools/gen.py                        write the files
python -I -B tools/gen.py --check                write nothing; fail if a file would change,
                                                 or if the output folder, or a folder
                                                 under it, holds a Lean file that the
                                                 generator does not write
python -I -B tools/gen.py --model-check DIR      look for check_model.py in DIR
python -I -B tools/gen.py --out DIR              write somewhere else
```

`check_model.py` is expected in `../model-check`, beside the project folder in the kit.
Give `--model-check` if it is elsewhere. Each generated file records the SHA-256 of the
`check_model.py` it was written from.

The output depends on `check_model.py` alone, and two runs write the same bytes. After
running it, `lake build` checks everything.

## What it writes

| File | From | Contents |
|---|---|---|
| `Fields.lean` | `reference(without=...)` | each of the eleven systems as the Python object has it, field by field (`Py.reference`, `Py.withoutP1`, ...), and the proof that the project's definition in `Reference.lean` equals it (`Py.*_eq`, from one lemma for each field) |
| `Executions.lean` | `explore()`, then `apply_env` and `process_phase` | for every goal `explore()` finds violated: its shortest violating execution, with the state and the two goals after each round (`Py.*_g1_trace`, `Py.*_g2_trace`) |
| `StatesReference.lean`, `StatesWithoutP4.lean`, `StatesWithoutP6.lean`, `StatesWithoutP8.lean` | the search of `explore()` | for the four systems in which a goal is never violated: every state the search reaches, in its order (`Py.*_states`), the round that first reaches each (`Py.*_parents`), and three statements: `Py.*_covers`, `Py.*_reached`, `Py.*_count` |

Three things come from the generator's own use of the Python's functions, and not from a
result `check_model.py` returns:

- `explore()` returns the steps of an execution and what it reports for each round, and
  not the state after each round. `run()` in `gen.py` applies the steps again with
  `apply_env` and `process_phase` to get the states, and `executions_file()` checks that
  the reports come out the same.
- `explore()` returns the number of states it reaches and not the states. `reach()` in
  `gen.py` repeats its loop to keep them, and `states_file()` checks that the number and
  the goals come out the same.
- The number of rounds in `Py.*_count` is counted by the generator: for each state that is
  not responded, one round with no step and one for each step `env_steps()` returns.
  `explore()` merges the steps of a state that end in the same state, so it runs fewer.

## How Lean checks it

`Executions.lean` and the four `States*.lean` files hold data and statements. Each
statement says that a computation gives a stated result, and is proved by
`decide +kernel`: the kernel carries out the computation on the project's own definitions
of `reference`, `withoutP1` and the rest. No statement is taken on trust from the Python,
and a statement that is false of the Lean model makes its proof fail. The computations
are in three hand-written files:

- `SelfObserving/Proofs/Finite.lean` makes the parts of a round computable on the types of
  the reference system. The predicates a round is made of get instances of `Decidable`, a
  state is written out as 31 truth values (`CState`), and `cafter` computes the phases
  after the environment phase. `Spread`, which is inductive, is computed through
  `spread_iff`.
- `SelfObserving/Proofs/Explore.lean` puts a round together, at one fault per round, from
  one enabled environment step or none and `cafter`. It has the three computations and
  what each one establishes: `ctrace` runs an execution; `covers` checks that a list of
  states holds the initial state, that every round from a state of the list that is not
  responded ends in a state of the list, and that none of those rounds violates the goals
  it is asked about; `reaches` checks that every state of a list is reached. `Py.*_count`
  is stated with `distinct` and `countRounds`.
- `SelfObserving/Proofs/Removals.lean` gives the eleven systems their instances, and has
  the lemma that two systems with equal fields are equal.

Lean checks that the statements are true. It does not check that the data is the
Python's where other data would make a statement true as well: that an execution in
`Executions.lean` is the shortest, that a list of states is in the order of the Python's
search, or that the round given for a state is the first that reaches it. `gen.py --check`
shows whether the files are still what the generator writes.

`Fields.lean` is different. Its proofs are written out by the generator (`rfl`, case
analysis, `simp`), and the other proofs do not use it. It is a statement of its own: the
systems of `Reference.lean` are the systems `reference(without=...)` builds.
`SelfObserving/Proofs/Agreement.lean` collects it, with the reachable states of the four
systems, and says what that agreement does not cover.
