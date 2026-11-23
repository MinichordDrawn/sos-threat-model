# How The Statements Were Made And Checked

The ninety-six statements were made in three rounds: 1 to 26, then 27 to 62, then 63 to
96. This file gives the method and the record of each round. `statements.md` gives the
statements, and its numbers are used here.

In every round Claude Fable 5.2 wrote the Lean, and the readers, testers and checkers were
separate agents of the same model, each started fresh. The kernel and the four independent
checkers are separate programs. The reports of the agents are working files and are not
part of this folder.

## The method

These are the steps of the first round. The later rounds keep steps 1, 2, 8 and 9, and
their new definitions and statements were read against the model check before the proofs
were written, with one exception that is given below.

1. **Transcribe the model.** Each clause of `model-spec.md` becomes a Lean definition, in
   the order of the specification, with the section number beside it. The transcription
   covers the whole model, including the four kinds of fault and the two timing variants
   that Theorem S does not use.
2. **Keep the statement apart from the proof.** The definitions and the statements sit in
   files of their own, so that a reader can check what is claimed without reading how it
   is proved.
3. **Prove Theorem S.** The proof follows the written one in `results.md`. From a state in
   which nothing has happened, a round with no fault changes nothing. A round with one
   fault ends with a live monitor flagged and every work process halted, and the model
   ends there.
4. **Guard against an empty statement.** Statements 2 and 3 show that the theorem's
   conditions can hold and that its conclusion can fail.
5. **Define the reference system.** One Lean definition follows the checker's builder,
   `reference(without=...)`, line for line, with a switch for each of the ten features.
6. **Prove its statements by computation.** The reference system is finite, so one round
   of the model can be made computable for it, and that is proved once. Lean's kernel then
   works each result out on the project's own definitions. That no execution violates a
   goal is shown by a list of states that holds the start and that every round maps back
   into, with no violation on the way. That some execution violates a goal is shown by one
   such execution. The Python checker supplies the lists and the executions and nothing
   else. A statement that is false of the Lean model fails, whatever the Python says.
7. **Prove the statements about every system by hand.** Each of the nine gaps is shown by
   one or two rounds that the environment can always play in a system of that kind: it
   corrupts monitors that nobody else checks, or every monitor a work process takes its
   halt from, or stops the one boundary, or corrupts a work process that nothing checks or
   nothing will halt in time. The proof follows those rounds through the model's
   definitions, for either order of the monitor and work phases.
8. **Judge.** `lake comparator` builds the statement file and the proof file separately,
   confirms that each proved statement is the stated one, checks that only the permitted
   axioms are used, and replays the proofs in the kernel. With `--paranoid` it replays
   them in every other checker shipped with Lean.
9. **Compare with the specification.** A separate agent, which has not seen the proofs,
   reads the Lean definitions against the specification clause by clause, and proves in
   Lean that executions the model check's own checker reports do occur in the Lean model.
   A second reads the reference system and its statements against the checker and its
   recorded results. A third reads the statements about every system against the model
   check's text, and tests those about systems with the checker on random systems.

## The first round: statements 1 to 26

- **Models.** Claude Fable 5.2 wrote the Lean definitions and the proofs, from the
  specification of the model check. The three comparisons, with the specification, with
  the checker's results and with the model check's general results, are by separate agents
  of the same model, started fresh and not shown the proofs. The checks of the generated
  data are by other fresh agents.
- **Gates.**
  - *Build.* From a clean copy, with no dependencies to fetch: 30 build steps for the
    proofs, the slowest of them about a quarter of a minute, and under a minute in all.
  - *Axioms.* No statement depends on anything but `propext`, `Quot.sound` and
    `Classical.choice`, the three axioms nearly all of mathematics in Lean uses.
    Statements 15 and 25 depend on no axiom at all, and eight others on `propext` alone.
    No step is skipped with `sorry`, and no result is taken from compiled code: every
    computation is carried out by the kernel.
  - *Judge.* `lake comparator`, in its sandbox, on a clean copy under Linux: accepted, for
    all twenty-six statements.
  - *Independent checkers.* `lake comparator --paranoid`: accepted by Lean's kernel in its
    default and paranoid forms and by `lean4lean`, `nanoda`, `con-leche` and `con-ron`. The
    last two ran in the mode they call `--verified`.
  - *Comparison with the specification.* A separate agent, which did not read the proofs,
    compared the Lean definitions with `model-spec.md` clause by clause: 73 clauses, none
    stated differently. Where the two are not the same in form, the Lean is the more
    general (it allows infinitely many processes, and does not enforce that `f` is at
    least 1), or the clause is a convention of the specification's file format. One thing
    is left out: the number of the round in which a gap first opens, which no statement
    needs. That comparison covered the model, the conditions and the two named systems.
  - *The reference system and its statements, read without the proofs.* A second separate
    agent compared `Reference.lean`, the two definitions that say a goal can be violated,
    and statements 4 to 14 with the checker and with sections 5 to 7 of `results.md`. The
    eleven systems match the checker's field by field, and so does every combination of
    removals, 1,024 in all. Each statement agrees with the checker's recorded result, and
    none claims more. The ten about removals claim less: they leave out the round in which
    the gap first opens. The agent also wrote the Lean definitions out by hand as a
    separate program and ran it beside the checker. On all eleven systems the reachable
    states and the outcome of every round were the same. The agent did not run Lean: what
    it says of the Lean rests on its reading of the text and on that hand-written copy.
  - *The statements about every system, read without the proofs.* A third separate agent
    compared statements 15 to 26 with the passages of `results.md` they formalise. Six say
    the same as their passage. Six say more in some respect, and each wider claim is true:
    three of them drop the model check's restriction to systems with no substrates or
    switches. The agent then tested each of the nine statements about a gap with the
    Python checker, on 19,500 random systems built to meet its hypotheses and on two
    sweeps of 60,000 and 196,608 systems. Every system that met a statement's hypotheses
    showed the gap. It tested statement 15 on some 200,000 random states, none of which
    raised a flag, and statements 25 and 26 on every case for up to five monitors. It
    found no counterexample, and it did not run Lean.
  - *The reference system against the checker.* Every field of the reference system and of
    each removal is proved equal to the system the Python checker builds, as the generator
    writes it out. For the reference system and the three removals in which a goal is
    never violated, the reachable states of the Lean model are proved to be exactly the
    states the checker's search reaches: 23, 59, 239 and 228 of them.
  - *Checks of the generated data.* Fresh agents checked this part of the work in five
    passes. One derived all the generated data again from the Python with a script of its
    own, and found no difference. Before statements 15 to 26 were added, it also made 33
    single changes to the files, of which Lean rejected 29 and accepted 4. Three of the
    four changed data, and one changed the model's rule for slow reports, which none of
    the eleven systems uses. Data changed in a way that leaves a statement true is
    accepted: an execution need not be the shortest, and a list need not be in the order
    of the checker's search. `tools/gen.py --check` is what shows that the files are still
    the generator's.
  - *Test against the model check's checker.* The agent that made the first comparison
    wrote a generator of its own, which turns a system into Lean statements of exactly
    what the Python checker computes for it, so that Lean has to prove each one. Lean
    proved all of them: every reachable state and every round of 22 named systems and of
    36 systems from the census, and 500 rounds on 200 random systems that use every kind
    of fault and both timing variants. As a test of the test, the agent changed one rule
    of the Python in each of 36 ways a transcription could go wrong, and Lean rejected all
    36.
  - *The two checks left over.* Two exhaustive checks of that test were too large to
    finish in one piece: the reference system without the gate (1,257 states) and without P7
    (2,565 states). They were completed afterwards, outside that agent's run. A
    script cut each generated file into parts at the boundaries between states, changing no
    statement and no proof. Lean checked each part as a separate file, four at once, and
    then the closing theorems that import them, and accepted both on the standard axioms.
    The results are the Python checker's: without the gate, detection first fails in round
    3 and no impact in round 1; without P7, both first fail in round 2.

  The files of the last two gates, and the records of the comparisons and of the checks
  of the generated data, are working files and are not part of this folder. In this
  folder, the statements about those two systems are proved by the executions that show
  their gaps.
- **What the kernel does and does not settle.** The kernel that accepts the proofs is a
  separate program from the model that wrote them, so a mistake that model makes
  consistently cannot pass it. The same is not true of the definitions. A definition that
  says the wrong thing compiles as well as one that says the right thing, which is why the
  comparison with the specification is a gate of its own.

## The second round: statements 27 to 62

- **Made.** One agent wrote the definitions, the statements and the proofs, working
  through others. New definitions went into files of their own. The twenty-six statements
  and their proofs were left as they were.
- **Read before proof.** Every new definition and statement went to a fresh agent before
  any proof of it was written, but for statement 54, which was proved as a lemma before
  its reader reported, and approved unchanged. The agent was given the Lean files and the
  model check's documents only, and was not told what to expect. Seven such readings cover
  the thirty-six statements.
- **Tested against the checker.** Three further fresh agents wrote the Lean definitions
  out in Python and compared them with the model check's checker.
  - The restart model, on every ring of up to four members with every choice of members
    that can start first, 1,052,741 rings, and on 100,000 rings of five: no difference.
  - The count of the spreading halt, on 249,580 cases and the waiting-period form on
    130,259: no difference for `n`, `c` and `h` of 1 or more.
  - A search for a counterexample to statement 35: of 1,503,788 systems that meet its
    hypotheses, none has a gap.
  - The two rings of statements 60 to 62 against the checker's: equal field by field.
- **Read after proof.** Fresh agents, shown neither the proofs' reasoning nor the readers',
  checked that each proved statement is the approved one, character for character, and
  that nothing else in the project had changed.
- **Checked independently.** One more agent was given a clean copy, the model check's
  documents and the list of what was claimed, and nothing of the author's notes or
  reports. In its own run:
  - the project built from clean, and no `sorry`, `axiom`, `native_decide`, `unsafe` or
    `set_option` was in any file but the `sorry` of the statement file;
  - `lake comparator` and `lake comparator --paranoid` accepted all sixty-two;
  - it wrote its own reading of each of the thirty-six before reading what was claimed,
    and found none that says something different or wider. Against `results.md`,
    statements 30, 49 and 54 say more and statement 51 says less, each as its comment in
    Lean declares;
  - Lean's own evaluation of the halt count gave 2,366 lines of output equal to the
    checker's; 754 Lean statements of the wiring of the two rings, generated from the
    checker, were all accepted, and four deliberately wrong ones were rejected; its own
    Python copy of the restart model agreed with the checker on 28,096 games, and of the
    slow-report count on 26,122 rounds of 6,000 random systems.
- **What the round found.** Nothing the model check states turned out false. Some of its
  sentences hold only under a condition it does not give. The results on restarting need a
  finite ring. "Between a fifth and two fifths" holds with both ends included: at `n` = 10
  the share is exactly two fifths. The mesh result needs at least one monitor. Statement
  35 is a theorem the model check did not have.

## The third round: statements 63 to 96

- **Made.** As in the second round. Sixteen files are new: seven of definitions and nine
  of proofs. `Challenge.lean`, `Solution.lean` and `comparator.json` gained lines and lost
  none (one line of `comparator.json` gained a comma). `Join.lean` is a second model
  beside `Model.lean`, which was not changed.
- **Read before proof.** Three readings: statements 63 to 81, statements 82 to 94, and
  statements 95 and 96.
- **Tested against the model check's programs.**
  - Lean itself evaluated the systems (the ring, the tower, the two lists of connections,
    the two example systems) and the two requirements. Over all 4,096 wirings of four
    monitors its counts are those of `part-a.md`: the fewest connections for R2 and R5
    together are 8 under flow, in 24 wirings, and 9 under actor, in 27.
  - The conditions of the theorems were tested through Python copies of the Lean text,
    written once by a tester and again, independently, by a checker.
  - The model with joins was tested through a Python copy of `Join.lean` against the
    model check's independent implementation, on 9,553 systems: no answer differed.
    Seventy catalogue entries were left out, because they have late work processes, which
    `model-spec-join.md` does not allow.
  - Lemma M was tested by its reader only, on 6,600 pairs of systems, in none of which
    the system with more edges did worse.
- **Read after proof.** Two fresh agents checked that what was proved is what was
  approved, and that nothing else had changed.
- **Checked independently.** One more agent, given a clean copy, the sixty-two-statement
  project, the model check's documents and the list of what was claimed. In its own run:
  - the project built from clean, 97 build steps, with no warning;
  - none of the ninety-six depends on an axiom beyond `propext`, `Quot.sound` and
    `Classical.choice`;
  - `lake comparator` and `lake comparator --paranoid` accepted all ninety-six;
  - the sixty-two earlier statements are untouched. Their text is identical, and so is
    what Lean elaborates them to: for each of them and for the 256 definitions they rest
    on, the type Lean computes has the same hash in the old project and the new;
  - it wrote its own reading of each of the thirty-four before reading what was claimed,
    and found none that says something other than claimed. Where a statement covers less
    than the model check's sentence, `statements.md` says so;
  - `Join.lean` was read against `model-spec-join.md` rule by rule, and is that model;
  - 107 systems printed from the Lean definitions were run through the model check's
    programs, and those the catalogue has were compared with it field by field: no
    difference;
  - it ran the Lean model with joins itself, and not a copy of it, beside the independent
    implementation: 1,249 schedules, 3,695 rounds and 4,480 steps of the environment, of
    all eight kinds, with no difference. Two deliberate changes to the systems given to
    Lean each made the comparison fail, as they should;
  - it proved in Lean, in files of its own, that the hypotheses of Theorem L and of
    Theorem J with joins can be met by a mesh of four with a late monitor, and those of
    Theorem F by a mesh of four.
- **What that check found, and what was done.** One proof file switched off a linter
  warning for two theorems (`set_option linter.unusedVariables false`), which does not
  touch what the kernel checks. Afterwards those two lines were taken out, and the unused
  hypothesis of the two helper theorems was renamed so that the linter has nothing to
  warn of. Four comments that described an earlier state of the project were corrected.
  No definition and no statement was changed. The folder as it is here was then built
  again from a clean copy, with no warning, and `lake comparator` and
  `lake comparator --paranoid` accepted all ninety-six again.
- **What the round found.** Nothing transcribed from the model check turned out false.
  - Theorem J needs less than it asks: statement 64 proves it with watching one way.
  - Under flow, two watchers for every monitor already need `2k + 2` connections, without
    the requirement on reports.
  - Each of the three edges a late monitor relies on has to be in force at once.
    Statements 91 and 92 prove this for the state check. For the signal read and the
    report it was found by search with the model check's programs, and is not in Lean.
  - Theorem L is proved for a narrower class than the model check words it for.
    `statements.md` gives the difference.

## The version of Lean

4.37.0-rc1, a release candidate.
