"""Every quotation used in findings-backward.md must be in the document, word for word
(line breaks and the indentation of wrapped lines aside). Run against the snapshot and
against the live files."""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
import os as _os
LIVE = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))

Q = [
    ("B1", "F", "Add `--traces` to print every violating execution."),
    ("B1", "R", "python -I check_model.py --traces   also print every violating execution"),
    ("B2", "F", "Every phase was checked by an agent started fresh for the purpose."),
    ("B2", "R", "Every phase was checked by an agent started fresh for the purpose and given only the artefacts"),
    ("B3", "F", "Each was given only the artefacts to check, in a folder of its own, and never the author's reasoning, expected results or proofs."),
    ("B3", "R", "None was given the author's reasoning or expected results."),
    ("B4", "F", "ten ambiguities in the wording, none of which changed a result"),
    ("B5", "F", "*From A.* The specification's wording was tightened in ten places."),
    ("B6", "F", "(the last two were computed afterwards with its code unchanged)"),
    ("B7", "F", "and were checked by computation before being adopted."),
    ("B7", "F", "and were checked here by computation for every `n` up to 3,000 and for powers of two beyond."),
    ("B8", "F", "The comparison with the implementation in section 10.5 began as a survey by two agents. Every line it quotes from the specification was then read directly."),
    ("B9", "F", "The verdict table now carries B's label for each removal."),
    ("B9", "F", "Each removal carries two labels."),
    ("B10", "F", "An attempt was made with three agents given only the four constraints, but each could see this workspace's own one-line description of the ring, so they were not independent, and their derivations are set aside."),
    ("B11", "F", "| the gate: monitors check before work steps | emergent, from the second constraint: no impact before detection |"),
    ("B11", "F", "| C2, a false flag is cheap |"),
    ("B12", "F", "**Result:** not met. No system was found that meets all four constraints, has no gap, and lacks the properties."),
    ("B13", "F", "So the form in which a signal is read, and the form in which a flag reaches the work, vary from system to system. That the silence is read, and that one detection stops the system, do not."),
    ("B13", "R", "That the silence is read, and that one detection stops the system, do not."),
    ("B14", "F", "The two predicates about edges between monitors fail in most systems with no gap, including systems in which no monitor is spare: 515,030 of the 742,352 in the third row."),
    ("B15", "F", "wrote its own deciders and settled every system of these sizes, one by one for the first four rows and by counting for the last."),
    ("B15", "R", "Every system with two or three monitors and one or two work processes was decided one by one, and every system with four monitors and one work process by counting."),
    ("B16", "F", "*Propagation* takes its smallest form in 289 of them. Some monitor's flag does not reach every other monitor, that monitor is not spare, and there is still no gap, because the work process takes its halt directly from whichever monitor detects, or halts on a monitor's silence. No flag has to travel between monitors when the work can read them all."),
    ("B16", "F", "One detection still stops the whole system, which is what the property is for; the path is one read long."),
    ("B17", "F", "The framework states four ways it could be shown wrong."),
    ("B18", "F", "Rounds give every monitor a step between faults."),
    ("B18", "R", "The model gives every monitor a step between faults."),
    ("B19", "F", "Two implementations of the ring exist, both public:"),
    ("B19", "F", "the two implementations, built and run."),
    ("B19", "R", "Two rings have been built on this structure, and both are public:"),
    ("B20", "F", "The fuller of the two is ghostunnel's."),
    ("B21", "F", "Line numbers are at commit `0741dac`."),
    ("B22", "F", "| a round | one cycle; a change is seen \"with a latency of at most one cycle\" (604) |"),
    ("B23", "F", "| state check | `copy-current`, `binary-expected` and others: current state against a reference | |"),
    ("B23", "F", "history checks: hash chains and a trace that may only grow (I1, I3, I4, `trace-consistent`)"),
    ("B24", "F", "five operating-system users, one store per member, one writer per path; all on one host (911)"),
    ("B25", "F", "By the survey's reading of the procedures, a change made and undone between two reads, seen by nobody, is caught by neither."),
    ("B26", "F", "How many such members there are is the one thing here that is chosen and not forced."),
    ("B26", "F", "One member must be able to start by itself, and it must observe the rest."),
    ("B26", "F", "| Recover without an outside hand | one member that can start by itself and observes the rest | proved and checked, section 10.3 |"),
    ("B27", "F", "A flag crosses between rings only through a member that belongs to both and is watched from both (every such edge is needed in section 10.1)."),
    ("B27", "F", "| A flag crosses between rings | a member shared by both, watched from both | checked, section 10.1 |"),
    ("B28", "F", "Four monitors, all pairs watching, one work process reading all four. This is the ring as built in both implementations: three members and a coordinator."),
    ("B28", "F", "The ring as built in the two implementations (three members and a coordinator, all pairs checking) holds up to three faults per round in the model."),
    ("B28", "R", "The ring as built in the two implementations (four members, all pairs checking) holds at one, two and three faults per round."),
    ("B29", "F", "```tla"),
    ("B30", "F", "(the proofs are the independent verifier's, in `verify-d/claims-verdicts.md`)"),
    ("B31", "F", "At two hops per tick the damage is at most `sqrt(n / 2)`, a share that goes to 0."),
    ("B31", "F", "At one hop per tick, the same speed as the fault, a doubling halt loses a quarter of the system (exactly `n / 4` when `n` is a power of two)."),
    ("B32", "F", "If everything halts `w` ticks after detection, the damage is `2^w`."),
    ("B33", "F", "**Proved,** from the round semantics: when reports take a round, a work process that goes bad takes `d` further work steps"),
    ("B33", "R", "When reports take time, a bad work process acts once for every hop between the monitor that checks it and the monitor that stops it."),
    ("B34", "F", "| P8b Halt fan-out | G2 | reachability | mixed | `f + 1` halt sources in general |"),
    ("B34", "F", "| The gate | G2 | reachability | not reviewed (added later) | an emergent requirement, not one of the eight |"),
    ("B35", "F", "The reviewer forced each removal onto 400 random systems."),
    ("B36", "F", "Without the gate the round in which a fault lands is never a complete response, so the environment also gets further rounds."),
    ("B37", "F", "*One substrate, any `k`.* The only step that stops M in this way stops W with it. W takes no further work step, so nothing it could do while bad happens."),
    ("B37", "F", "If a monitor and the work it watches run on one substrate, losing that substrate stops both."),
    ("B37", "F", "| fail-substrate `s` | stops every monitor on `s`; every work process on `s` goes bad, and every state check of it keeps returning the last good value |"),
    ("B38", "F", "R is the smallest system found in which all ten removals can be told apart."),
    ("B39", "F", "| P8b Halt fan-out | every work process takes its halt from at least two monitors; every halt is passed to at least two more | mutate, of a relay |"),
    ("B40", "F", "### 3.1 Three layers"),
    ("B41", "F", "This is the goal as the task statement defines it."),
    ("B42", "F", "Two levels of recursive interleaved rings hold too, including when a whole base ring is lost in one step."),
    ("B43", "F", "Judged against detection alone, P4, P8 and the halt fan-out would look unnecessary, which shows that detection alone is too weak a goal."),
    ("B44", "F", "In a model where at most `f` faults land between two monitor rounds, a reference system that has all the properties has no gap, and removing any one of them, alone, opens one."),
    ("B45", "R", "The kit rests on three claims: that each of the eight properties is needed, that a system with all of them has no gap, and that the structure of three observers and a coordinator follows from the four constraints."),
    ("B46", "R", "**Theorem S.** Four conditions on the wiring are enough for any system, of any size and depth, to respond completely to every single fault."),
    ("B47", "R", "A work process with `f` or fewer halt sources keeps working after they are all faulted."),
    ("B48", "R", "A halt passed to two keeps pace when a hop is quicker than the doubling."),
    ("B49", "R", "Each folder under `verification/` holds the specification as it stood when that pass ran, so the copies differ slightly from `model-spec.md`."),
    ("B50", "R", "Local paths in the reviewer's scripts were replaced by paths relative to each script; nothing else in those folders was changed."),
    ("B51", "R", "It needs Python 3.8 or later and nothing else."),
]


def norm(s):
    return re.sub(r"\s+", " ", s).strip()


def check(folder, label):
    docs = {"F": norm(open(os.path.join(folder, "formal-results.md"), encoding="utf-8").read()),
            "R": norm(open(os.path.join(folder, "README.md"), encoding="utf-8").read())}
    missing = [(i, f, q) for i, f, q in Q if norm(q) not in docs[f]]
    print(label, "quotes:", len(Q), "missing:", len(missing))
    for m in missing:
        print("   MISSING", m)


check(os.path.join(HERE, "snapshot"), "snapshot")
check(LIVE, "live")
import hashlib
for name in ("formal-results.md", "README.md"):
    a = hashlib.md5(open(os.path.join(HERE, "snapshot", name), "rb").read()).hexdigest()
    b = hashlib.md5(open(os.path.join(LIVE, name), "rb").read()).hexdigest()
    print(name, "snapshot", a, "live", b, "same" if a == b else "CHANGED")
