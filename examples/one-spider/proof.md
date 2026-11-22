# One Spider: The Proof

One part of what the README claims is proved in Lean 4: the protocol of a round. This
page says what is proved, of what, how it was checked, and what it leaves out. The proof
is in `lean`.

## What it is a proof of

It is a proof about a model of the protocol. It is not a proof about the program.

`lean/protocol-spec.md` writes the protocol down from `src/watch.rs`, with the lines each
item is taken from: what is stored and in how many copies, the 38 steps of a round in
their order, what a detection is, and each way things are put right.
`lean/GateProof/Model.lean` is that specification in Lean.

The game is not in the model. The work and the rules are any functions that meet four
assumptions: the two texts of the work compute the same; the two texts of which moths are
halted in the web compute the same; work done with no fault passes the gate's checks; and
a new game is a state the game can be in. They are assumed for every input. In the
program they rest on tests.

## What is proved

A fault here is one of these changed to any value: one part of the state, one observer,
one text or one copy of the gate's record, one of the three places of what the gate keeps
of its own, one of the three places of the state kept from when the round began, or one
of the three lists of what was asked. It lands immediately before any of the 38 steps, or
between two rounds. Or it is one observer's answer, missing or wrong.

From any state the game reaches with no fault, with one such fault:

- **Nothing wrong is written to the record** (`T1`). The round is not recorded, or what
  it writes to the record is what the same round with no fault writes.
- **No halt is left that cannot be put right** (`T3`). And in any later round that begins
  halted, the halt ends if halts are set to end at once, or it has been asked to end, or
  they are set to end after a pause and the pause is over (`T3_ends`). That statement
  does not cover the round of the fault itself, and nothing says a pause is ever over.
- **Found, or gone** (`T4`). The fault halts everything in the round it lands in or the
  next. Or after the second round everything stored is what it is with no fault.
- **Put right** (`T2`). When the halt is over, the state and both halves of the record
  are the same, every observer is as a new one made from the record, and the three places
  of everything kept in three agree. The record is what work with no fault makes, round
  by recorded round, of the record from before the fault.
- **One after another** (`T5`). The same for any number of faults, one to a round at the
  most. Each lands only when the one before has been found, its halt has ended and a
  round has been recorded since, and no sooner than the round after that one; or when the
  one before is gone.
- **Two faults do what one cannot** (`T6`). Three pairs, on a small game that meets the
  assumptions: a wrong value recorded, with nothing halted when the round ends; a halt
  that cannot be put right; and a halt that cannot be put right from a second fault that waited for the
  first one's halt to end and not for a round to be recorded.

There are fourteen statements, in `lean/GateProof/Challenge.lean`. That file, `Model.lean`,
`Claims.lean` and `Toy.lean` hold the definitions and the statements: they are what has to
be read to know what was proved.

## What is said less strongly than the README might be read

- **A round is lost.** The round a fault spoils is not worked again, and neither are the
  rounds of the halt. "Put right" means the record is what right work makes of the last
  good record, not that the game is where it would have been.
- **Not everything stored is as it would have been.** After a halt that did not end in
  the round it began, the three places of the state kept from when the round began can
  all still hold the changed state, until the next round writes over them. Nothing reads
  them in between but to choose between the two halves of the record. The proof was first
  asked for with "everything stored", and that is false of the model and of the program.
- **`T1` is about what a round writes.** A fault that changes the record after it is
  written is found at the start of the next round and put right.

## How it was checked

- **By Lean.** The project builds with no dependencies. No statement is left unproved
  outside `Challenge.lean`, where the proofs are left out on purpose. Each of the
  fourteen rests on the axioms `propext`, `Quot.sound` and `Classical.choice` and no
  other.
- **By the judge.** `lake comparator`, in its sandbox, accepts all fourteen: the
  statements proved are the statements of `Challenge.lean`. In its paranoid form they are
  accepted by Lean's kernel twice over and by four other checkers: `lean4lean`, `nanoda`,
  `con-leche` and `con-ron`.
- **By a second party.** An independent check, given a clean copy and none of the
  working behind it, built it and made those runs itself, and read each statement against
  what had been asked. Its hand-back is `lean/records/check.md`.
- **The model against the program, by reading.** Two readers, one of them that check,
  read the specification against the code and found no step that differs.
- **The model against the program, by running.** The check ran 11,757 situations, one
  fault each, at every one of the 38 steps and between rounds, in the program and in the
  model. The program was a copy with a hook before each step, for the test only. The
  model was run with the small game of `Toy.lean` in place of the real one. 11,616 came
  out the same. The other 141 are of three kinds, each explained in `check.md`, two of
  them from the small game not being the real one, and in each the program does
  something the theorems allow. In those runs, and in 183,330
  more in the program alone with extreme values, no halt was left that could not be put
  right and the program did not stop in the wrong place.

The copies of the program with hooks, and the tables they wrote, are not in this folder.

## What is not shown

- **That the program is the model.** That rests on the two readings and on the runs
  above. No machine checks it.
- **The four assumptions, for the real game.**
- **A fault that lands part of the way through a step.** Section 11 of the specification
  argues it. It is not proved.
- **A fault that lands while things are being put right.** That is a second fault in one
  halt, which is outside what is claimed. The specification names a case where it leaves
  a halt that cannot be put right.
- **What the model leaves out.** Section 12 of the specification lists it, in thirteen
  items. Among them: the observers' threads and the two things kept in three for them,
  lists made too long or too short, a stop in the wrong place, the lines kept at the
  backdoor to be written during the work, the clock, the words of a halt's reason, and
  that ten fields of what the gate keeps of its own are one value in the model.
- **What the three places of what the gate keeps, and the three lists, hold after a
  halt,** beyond that they agree.
- **Two faults in general.** `T6` is three examples.

## Running it

Lean 4 is needed, at the version in `lean/lean-toolchain`.

```
cd lean
lake build                   builds the model and checks the proofs
lake env lean Axioms.lean    prints the axioms each statement rests on
lake comparator              the judge: on Linux, with bubblewrap
```

## What is in `lean`

```
protocol-spec.md        the protocol, written down from the code
GateProof/Model.lean    the model
GateProof/Claims.lean   what the statements are made of
GateProof/Toy.lean      a small game that meets the assumptions
GateProof/Challenge.lean  the fourteen statements
GateProof/Solution.lean   the same fourteen, proved
GateProof/Proofs/       the proofs
GateProof/Eval.lean     the model as something that can be run
test/                   a test of the statements on the model, and the model's side of an
                        earlier, smaller comparison with the program, which the
                        write-up in the records gives
records/                the proof's own write-up and hand-back, what was asked for, the
                        check's hand-back, and three readers' reports, word for word
```

In the records, local paths are replaced by placeholders: «PROOF» and «CHECK» are the
folders the proof and the check were made in, «WSL» a folder under Linux, and «USER» a
user's name. They name files of those folders that are not here. The write-up is called
`results.md` in the hand-back and `claims.md` in the check.

Three sentences of `records/write-up.md`, which stand in `records/hand-back.md` too, are
not so, by the check: that every theorem
carries the two hypotheses (five of the fourteen do not need both); that the program
cannot say that no two of the gate's three places agree (it can, and does); and that the
judge could not be run in its sandbox (the check ran it there).

The proof was written and checked by Claude Fable 5.2, the model the program was written
with. The kernel and the other checkers are separate programs. The reading of the model
against the code has no such guard.
