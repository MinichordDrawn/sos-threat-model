# Corrections 2 to `results-join.md` and `model-spec-join.md`

Made after a fresh reader's check of corrections 1 (`verify-corrections\handback.md`).
Every change is listed here with the text before and the text after, under the number
of the point it answers. Nothing else in either file was changed. The checker, the
catalogue and the answers were not changed. `corrections-1.md` is left as it is
(point 6).

The two files as they were before these corrections are kept beside this one:
`results-join.before-corrections-2.md` and `model-spec-join.before-corrections-2.md`.

## A. `results-join.md`

### A1 (point 1). Section 6.2, "The order of joining" (the sentence added by A10)

Why: Two rows of the chain table have a gap with every monitor checked, not three. The other two rows with a gap are rows in which N6 or N7 has no state checker. Checked against the chain table of this note (C6 of `run-output-join.txt`).

Before:

````text
that is the only way a gap arises (**checked**). It is not the only way in general: three
rows of the chain table below have a gap although every monitor always has a present
state checker.
````

After:

````text
that is the only way a gap arises (**checked**). It is not the only way in general: two
rows of the chain table below ("N5 does not read N6's signal" and "N6 does not report to
N5") have a gap although every monitor always has a present state checker.
````

### A2 (point 2). Section 10, "What two observers do give" (the sentence changed by A15)

Why: Theorem F's proof covers the first round with a fault. In a later round, when the model has not ended, a fault can go undetected. The reader's five-monitor system was replayed here and behaves as the reader says.

Before:

````text
every work process has a state checker, then in every round with a fault some live correct
monitor detects a fault of that round.
````

After:

````text
every work process has a state checker, then in the first round with a fault some live
correct monitor detects a fault of that round.
````

### A3 (point 3). Section 3, under the table "The theorems against the search"

Why: The row for Theorem L was not recounted when the theorem's hypothesis was reworded. Its test was narrower than the hypothesis as now worded, so the row is not wrong; the text now says what the test was.

Before:

````text
Each is sufficient and none is necessary. For Lemma M, one edge was added at random to
````

After:

````text
Each is sufficient and none is necessary. The row for Theorem L was counted with a
narrower test than the theorem's hypothesis as it is now worded: a system was counted as
meeting the conditions only if it has no slow edge at all, no switch on any monitor, no
substrate and no two monitors in one boundary. So every system in the row's first two
columns meets the hypothesis as worded, and a system that meets it with some other edge
slow is counted among those whose conditions fail. For Lemma M, one edge was added at random to
````

### A4 (point 4). Section 6.1, the bullets on way two and on the families

Why: Section 6.1 did not say what the 22 family systems are nor how the 12,240 divide, and its description of the mixture did not match what was run: the mixture was sampled at every size, 150 systems each, and was not run exhaustively at five and six monitors.

Before:

````text
- *Way two, each new monitor attached to any three.* From each of the four base rings, in
  each of the five shapes and in a mixture of them: every system of five monitors, every
  one of six or a sample of 400, and samples of 150 of seven and of eight. 12,240 systems
  in all. Every one has exactly the rate of its base ring: 3, 3, 2 and 2.
- *Families.* A hub (every new monitor on M1, M2, M3) to 11 monitors; a chain (every new
  monitor on the newest three) and a fan (on K and the newest two) to 20 monitors; each in
  the mesh shape and as cycle members. All have rate 3.
````

After:

````text
- *Way two, each new monitor attached to any three.* From each of the four base rings, in
  each of the five shapes: every system of five monitors, every one of six or a sample of
  400, and samples of 150 of seven and of eight. In a mixture of the shapes, each new
  monitor's shape drawn at random: samples of 150 at each of five, six, seven and eight
  monitors. The samples are random draws and may repeat a system. 12,240 systems in all,
  3,060 per base ring: 344 in the mesh shape, 344 as signal-reading coordinators, 724 in
  each of the two cycle-member shapes, 324 with one watcher and 600 in the mixture. Every
  one has exactly the rate of its base ring: 3, 3, 2 and 2.
- *Families.* A hub (every new monitor on M1, M2, M3) at 9, 10 and 11 monitors; a chain
  (every new monitor on the newest three) and a fan (on K and the newest two) at 9, 12, 16
  and 20 monitors; each in the mesh shape and as cycle members read by the coordinator.
  That is 22 systems. All have rate 3.
````

## B. `model-spec-join.md`

### B1 (point 5). J1, the sentence added by B1

Why: "A work process" there means a process listed in `works` (for the joiner the sentence would be false). The clause on a late monitor that has joined and been stopped is what J2 already implies, since `after` asks for present and not for alive.

Before:

````text
An entry of `after` may name any process of the system. One that names an initial monitor
or a work process is always satisfied. A group whose `after` names one of its own members
can never join.
````

After:

````text
An entry of `after` may name any process of the system. One that names an initial monitor
or a process listed in `works` is always satisfied, and one that names a late monitor is
satisfied once that monitor has joined, whether or not it has since been stopped. A group
whose `after` names one of its own members can never join.
````
