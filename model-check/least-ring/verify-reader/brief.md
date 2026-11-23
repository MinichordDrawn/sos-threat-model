I need an independent check of two write-ups of results about a small transition-system model. They state verdicts, results marked **Checked** with counterexamples given as round-by-round tables, counts marked **Counted**, and statements marked **Proved**. I want to know which of their statements do not hold as written. Try to refute each one. Do not take the write-ups' word for anything: they are the subject, not a source.

## Where things are

Work only in this folder: `«WORK»\sos-minimal-ring\verify-reader\`

Do not open any other folder, in particular not the folder above this one or the folders beside it. You do not need the web.

- `model-spec.md`: the model, complete in 147 lines.
- `model-spec-join.md`: an extension in which monitors may be absent at the start and join.
- `model-spec-scope.md`: a further extension, new, in which each process belongs to a scope, a flag carries its scope, the two goals are judged scope by scope, and two more things are judged ("told", "spill"). It is part of the subject: say where it is unclear, where it does not say what the write-up uses it for, and whether "one scope is the earlier model" (its X11) is so.
- `part-a.md`: the first write-up. The least wiring of a ring of four monitors against a list of six requirements, R1 to R6. **This is the subject.**
- `results-minimal.md`: the full write-up: the same, then wider rings, three rings under a top coordinator (as one system, and with scopes), getting there by joins, and the verdicts. **This is the subject.**
- Background, each checked separately and not the subject except where a write-up misquotes or misuses it:
  - `results-join.md`: results about joining. The write-ups cite its Lemma M (adding edges never opens a gap), Theorem J and others.
  - `results-original.md`: the earlier results (the four evidence kinds at its top; Theorem S; Theorem 0; P8b; section 10.3 on restarting, whose game is defined in prose there).
  - `lean-statements\`: statements proved in Lean that the write-ups cite by name (`Challenge.lean`), with the definitions they use (`Restart.lean`, `Naming.lean`, `Wide.lean`, `Conditions.lean`, `Model.lean`). Read them as statements; check that a write-up says of each no more than the statement says.
- `independent_model_join.py`: an implementation of the first two specification files, written from them alone by someone other than the write-ups' author, which agrees with another implementation on 5,658 systems. It knows nothing of scopes. You may use it for systems without scopes, or write your own.

## The question the write-ups answer

The author of the model drew a ring of four nodes, A, B, C and a coordinator D, as nine arrows:

```
A -> B -> C -> A
D -> A, B, C
A, B, C -> D
```

and said it is the least such ring, the arrows meaning "a connection"; and gave as a goal that three such rings under one coordinator, the three ring coordinators in a cycle like ring members, is again least, so that growth is always building new rings. The write-ups say the candidate is least under one reading of an arrow and not under another, and that the goal holds with four conditions and "always minimal" only in a narrower sense.

## What to do

1. **The readings and the requirements (`part-a.md` section 1).** Are "actor" and "flow" each a fair reading of "a connection", is there a third fair reading the write-up does not take, and does a third change a verdict? Is each of R1 to R6 stated in the model as the plain words would lead a reader to expect, and where a choice was made, is the other choice really reported?

2. **The least ring of four.** With a program of your own (four monitors and a work process: 4,096 wirings as connections is small), recompute for each reading and each requirement and the whole list: the least number of connections, how many wirings achieve it, whether the candidate is among them, and the table of which requirement each of the candidate's nine connections is forced by. Then the kind-by-kind result: that 19 edges are enough for the whole list and 18 are not, by a search of your own, and say where you relied on Lemma M and where you did not. Then "the mesh of four buys nothing on this list".

3. **Every counterexample table** in both write-ups: step through it by hand against the specification files. Is each environment step enabled where taken, is the number of steps within `f`, is the thing said to be violated violated in the round stated? For the tables that use scopes, do this against `model-spec-scope.md` as written.

4. **Every statement marked Proved.** Read the argument against the specifications and the cited statements. Does every step follow, is every hypothesis the proof uses stated, is there a system of the stated class for which the conclusion fails? Look hardest at: "at every number of levels"; "for every k"; statements about scopes (they rest on a specification nobody else has read); and each place a result of `results-join.md` or a Lean statement is applied (does the system meet its hypotheses, in every reachable set of present processes where that is what is needed?).

5. **The verdicts in the first lines of each write-up, and the four conditions on the goal.** Does each sentence follow from what the write-up establishes, with the evidence kind it gives? Is anything said more widely than it is supported: in particular "least" (among which wirings, under which reading, for which list), "at every number of levels", and the figures 33, 26 and 36 for thirteen monitors. Recompute what is small enough: the thirteen-monitor system as one system at one, two and three faults per round; the systems of 33 and 26 connections said to have no gap; the join orders said to have a gap at the first step, and the top-first order said to have none.

6. **What it does not say.** A list of what a reader might take the write-ups to establish that they do not.

## What I want back

In the first lines: whether you found any statement that is false as written, and which.

Then the six checks, each with what you did and what you found. For each statement marked **Proved**: holds, fails (with a counterexample as a round-by-round table, or the step that does not follow), or holds only with a hypothesis that is not stated. For each counterexample table: real or not. For each verdict sentence and each condition: follows, or says more than is supported.

Then a short list of what you could not check and why. Do not report style or wording you would choose differently.

Your final message is the hand-back. I will keep it word for word, so make it complete and self-contained, and keep working notes out of it.

## Rules

- Keep runs modest: other work is running on this machine. Keep memory under about two gigabytes. If a search is too large, bound it and say what the bound leaves out.
- Do not use git. Do not start other agents.
- If a tool restriction or anything else stops you from checking something, do not look for a way round it. Say plainly what you could not check.
