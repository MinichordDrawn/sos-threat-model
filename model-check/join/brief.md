I need an extension of an existing model check, and an honest answer to a question about it. The model is a small transition system of processes that monitor each other. The question is what a monitor that joins a running system must be attached to, from the step that adds it, for the system to have no gap.

## Where things are

Work only in this folder: `«WORK»\sos-join-model\`

- `model-check\` is a working copy of the model check as it stands. Read these first, in this order:
  - `model-check\model-spec.md`: the model, complete in 147 lines. A system, a state, one round, the two goals G1 and G2, and the result computed for a system.
  - `model-check\results.md`: what has been established. Read the list of evidence kinds at its top (**Checked**, **Proved**, **Counted**, **Argued**), then sections 2.3 to 2.7, 5, 6 (P7, automatic enrolment, above all), 10.1 (Theorem S, the definition of a *plain* system, and "recursive interleaved rings"), 10.2, 10.3 and 11.
  - `model-check\check_model.py`: the checker.
- Write everything new into `join\` beside it. Do not change any file in `model-check\`: copy what you need.
- Do not read or write anywhere else. In particular do not open the other folders under `«WORK»\`. You do not need the web.

## What the model has and what it lacks

The model has one process that can join: `joiner`, a work process that is absent at the start. Property P7 says a joining work process must have its state checker and its halt inputs from the step that adds it, and the model check shows the gap when it does not.

No monitor can join. Every monitor is present from the start. Theorem S is for plain systems, which have no joiner at all.

## The claim to test

The author of the model states the following. It is a claim to test, not a result. If it is false as stated, or true only under a condition it does not give, that is a finding and an important one: report it with the counterexample.

A new observer joining a running system should be modelled. An observer can itself be a ring, as with an outer ring that watches the inner rings of individual programs. Rings never get bigger, because a new node only needs to be attached to three other nodes to be part of a full mesh, which is one more ring. A node can be part of any number of rings.

In the model's terms, as I read it: a system starts as a mesh of four monitors (three members and a coordinator, every one watching every other). A new monitor joins by being attached to three monitors that already watch each other, so that it and those three are a mesh of four. No existing ring gains a member: there is one more ring, which shares three members with the rest. This may be repeated without end, each new monitor attaching to any three that watch each other, the earlier joiners among them. (Graph theory calls what this builds a 3-tree. That is a fact about the construction and says nothing yet about gaps.)

## What I want

1. **An extension of the specification.** Write `join\model-spec-join.md`: the least addition to `model-spec.md` in which a monitor can be absent at the start and join by an environment step, after which it is a monitor like any other (it can be stopped, mutated, switched off; it detects, flags, reports). Say exactly what is true of its edges before it joins. Add a second way of joining in which the monitor arrives already bad. Allow more than one joining monitor in a system. Keep the existing model unchanged as the special case with no joining monitor. Write it so that someone given only the two specification files could implement it: an independent implementation will be made from them afterwards and its answers compared with yours.

2. **The checker extended to it**, in `join\`, with every result the existing checker prints for the existing catalogue unchanged. Show that they are unchanged.

3. **Answers, each with its evidence kind as `results.md` defines them:**
   - (a) *What must a joining monitor be attached to?* For a base system that meets Theorem S's conditions, enumerate the attachments of one joining monitor: which existing monitors read its signal, check its state, receive its reports, and which it reads, checks and reports to, each edge separately and in each direction. For each, the result for G1 and G2 at `f` = 1, 2 and 3. Give the least attachments that leave no gap, and say what each edge of the claimed attachment is needed for, by removing it. Is three the number the model requires, more than it requires, or less? If the two judgements alone require fewer than three, say what else in `results.md` (sections 10.2 and 10.3) bears on the number, and do not stretch it.
   - (b) *From the step that adds it.* The analogue of P7 for a monitor: the gap, if there is one, when a monitor joins and its attachments arrive a round later, or some of them never. Include the monitor that arrives already bad.
   - (c) *Growing without end.* Systems grown by the construction above to five, six, seven and eight monitors and as far beyond as stays cheap, by different choices of which three to attach to, with joins and faults interleaved in every order the environment can choose, at `f` = 1, 2 and 3. Does the fault rate a grown system has no gap at stay what the mesh of four has, fall, or depend on the choices? Give the exact boundary and a counterexample at it. If you can state and prove a theorem for every system built this way, of any size, do, and mark it **Proved** only if the argument holds for the whole class. Otherwise say what is checked and for which systems.
   - (d) *The work processes.* What the answers to (a) to (c) depend on in how the work processes take their halt inputs and checkers, and whether a joining monitor may become a checker or a halt input of an existing or a joining work process without a gap.
   - (e) *A joiner that is itself a ring.* A base ring with its own work process, and a second ring of three members and a coordinator with its own work process, that joins by its coordinator being attached as above. Model it as faithfully as the specification allows (all four monitors of the joining ring join; say whether in one step or four, and what each choice means). State plainly what the model can and cannot say about it.
   - (f) *Rings do not get bigger.* Whether, in every system you built, the cost the model can count (edges per monitor, monitors a work process reads) stays bounded as the system grows, and what does grow.

4. **A write-up**, `join\results-join.md`, in the plain register of `results.md`: what was established, with the evidence kind on each statement, the counterexamples as round-by-round tables in the style of section 6, the limits, and a short list of what you could not settle. Put the claim's verdict in the first lines: holds as stated, holds under a condition (which), or fails (where).

5. **Files for the comparison**: `join\systems-join.json`, a catalogue of the systems you checked in the format of section 5 of the specification with your extension's fields, and `join\results-join.json`, your answers for it.

## Rules

- Say "model check", never "formal verification". Mark nothing **Proved** that is checked for particular sizes.
- Never bend a statement to make it come out. A gap is an execution in which G1 or G2 is violated: give the execution.
- The model is synchronous and ends at the first complete response (section 11). Do not model repair, or lifting a halt, or a halt that stays within part of a system: say where a question would need them.
- Keep runs small: other work is running on this machine. Keep memory under about two gigabytes, and if a search is too large, bound it and say what the bound leaves out. A copy of the existing checker may be running in `model-check\` when you start: leave it alone.
- Do not use git. Do not start other agents.
- If a tool restriction or anything else stops you from checking something, do not look for a way round it. Say plainly what you could not check.

Your final message is the hand-back. I will keep it word for word, so make it complete and self-contained: the verdict on the claim first, then each answer with its evidence kind, then what is not settled, then the list of files you wrote.
