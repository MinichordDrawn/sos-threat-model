# Final round: confirmation

*Saved by the main session from the confirmation pass's hand-back, word for word, except that one local
path is replaced by a relative one. The pass could not write a report file itself.*

# Confirmation check of the passages changed since the last check

Scope: all 25 hunks of `results.diff` and all 11 hunks of `README.diff`, read in the current `results.md` (1,634 lines) and `README.md` (482 lines). I regenerated both diffs from the last-checked documents and they match the ones supplied. Line numbers below are those of the current documents.

Three things to know first.

- **One line of `last-check.md` was shown to me during step 1.** A grep over `g-final-round/*.md` for "10,236" printed line 25 of that report (its item 11, on the counts of section 13 and the README's byte size). I had not opened the report. No verdict below rests on that line. I excluded the file from every later search until step 2.
- **Outside the folder I read** `sos-formal/check_model.py`, the snapshots and diffs under `sos-formal/final-round/` (for sizes, and for when each proof entered the note), `observers/SPEC.md` and `observers/README.md` in the ghostunnel tree, and `observers/README.md` in the PR2 tree. In `SPEC.md` I read beyond the cited lines (193 to 222, 258 to 268, 408 to 429, 522 to 606), which is where K1 comes from.
- **Nothing under `shared-templates\` was written.** All runs used `python -I -B`. No `__pycache__` exists there.

## Step 1: what was confirmed, by item

1. **Section 1.** R at `f` = 1 has no gap (23 states). Each of the ten removals opens one. The catalogue holds 72 plain systems at `f` = 1: 31 meet the four conditions and pass, 14 fail them and pass, 27 fail and fail, none meets them and fails. `ring(3, "same", 2)` satisfies every predicate of section 3.2 and the gate, and has G2 broken in one round and G1 in three; after `mutate M1`, M3 flags and the work takes a step. The coordinator bullet is supported by `SPEC.md:28`, `:544`, `:556`, `:364-379` and `PR2: observers/README.md:94-95`.
2. **Section 2.7.** The mesh of four in one boundary has G1 broken in two rounds and G2 holding. See K3. The cost paragraph carries its label. Nothing in the folder models cost, so its two claims are not checkable, and no change is needed.
3. **Section 4, the "Checked" paragraph, sentence by sentence.** "Add a fourth monitor": shown by the run (R plus unread M4, no gap, 50 states). "A single state checker": shown by the code. "One is enough": shown by R at `f` = 1. "At two faults per round R fails through its halt sources": shown by the run and by the shortest execution (mutate M1 and M3, W1 works). "And not through its single checker": not shown by any of the 103 cases. It is shown by a variant that the last check ran and I reproduced: R at `f` = 2 with three halt sources and one checker for each work process has no gap (115 states), and with three checkers and two halt sources it still fails. See K4.
4. **Section 5.** The replay of mutate M1, mutate M3, then stop M2 gives exactly what the text says, and is the execution the search finds.
5. **Section 7.** The P6 cell is Theorem 0, part 2. On 400 random systems with every monitor in one boundary, G1 broke within two rounds in all 400. The five proofs are where the sentence says, all in the round model. The second face of P2 uses a threshold that neither the specification nor the script has.
6. **Section 10.3.** See K1, K7, K8 and K9. Everything else holds: the weaker form (any silent halt input against every observer stopped), the definition of "can always restart" against the script's return value, the proof, the counts of 64 and 4,096, the sweep's script and its output, and every other citation in "The implementation" (`:564` and `:568` are exact quotations; `:556-558`, `:556`, `:364-379`, `:28`, `:184`, `:364`, `:383` and `:818-834` say what their sentences claim). On `:364-379` one remark, with no change asked: the absolute bound of V4b is tested on every cycle, and a retired member (V4) also fails freshness. The sentence states a necessary condition correctly.
7. **Section 12.1.** The census tests six predicates. In a plain system the out-of-boundary predicate is the signal-read predicate by definition. See K5.
8. **Section 13.** Every number in the changed rows and bullets matches the reports, apart from K2 and K6. 10,236 bytes and 1,330 lines are stated in `findings-backward.md` line 6. The reconciler's three points are R8, R17 and R44. Two statements are not checkable from the folder and need no change: that the cited commits are the heads of the public branches, and that the third point was settled from the framework's statement of the constraints.
9. **README.** See K14 to K18. The rest is confirmed, including pass B's eight deviations (D1 to D8; D1 to D4 fixed in the current script, D5 standing), the reworded bullet under "Proved", and the `--traces` line against the code.
10. **Agreement of the two documents.** They agree wherever a changed passage states a result both carry, apart from K19.
11. **The script.** See K20 and the lines at the end.
12. **`verification\g-final-round\`.** No local absolute path, no user name and no email address in any of its 83 files. Three things for the author to judge. (a) `last-check.md` line 11 and `last-check/lc06_changed_lines.py` lines 12 to 15 name the working folders `sos-formal` and `shared-templates` by relative path. (b) `lc06_changed_lines.py` cannot run where it is published: its root resolves to the `model-check` folder, under which neither `sos-formal/final-round/swept-results.md` nor `shared-templates/model-check/results.md` exists. (c) `reconciliation.md` line 91 still quotes session notes on commit `0741dac9`.

## Entries

### `results.md`

**K1. `results.md`, section 10.3, line 1183. WRONG.**
The specification says the opposite of "and so publishes a fault". `SPEC.md:199`: "A problem with a different observer is a halt, not a fault … Everything about another member (absent, stale, unreadable, a copy out of date) … raises a halt and does not appear here at all"; `:218` leaves `store-readable` off the list of local checks; `:523` says a dead peer "makes none of them faulty". The coordinator's clear-condition (`:556`) counts fault files and its own assertions only, so that member's halt does not block the stand-down. This is correction L12 applied as worded; `:531-533` supports it only when read without `:199`.

```
OLD: and so publishes a fault (`:531-533`), which blocks the stand-down (`:556`).
NEW: and raises a halt of its own (`:425`). A failing assertion about another member publishes
no fault (`:199`), so that halt does not block the stand-down (`:556`). It keeps the ring
halted until the member can read the coordinator again (`:418`, `:558`).
```

**K2. `results.md`, section 13, lines 1612 to 1613. WRONG for the last check.**
The last check read only the changed hunks (`last-check.md` line 9). From section 10.5 it names `:834`, `:911`, `:15`, `:890`, `:34`, `:266` and `:364`, which are three rows of the table. `:604`, `:358`, `:375`, `:403`, `:713`, `:673`, `:451-462`, `:674`, `:531-548`, `:899`, `:872` and `:820` appear nowhere in its report.

```
OLD:   The author then read every line it cites, and the reconciler, the sweep and the last
  check read each again. Every citation resolves against the two repositories at the
  commits named.
NEW:   The author then read every line it cites, and the reconciler and the sweep read each
  again. The last check read the lines cited in the passages it was given. Every citation
  resolves against the two repositories at the commits named.
```

**K3. `results.md`, section 2.7, line 272. NARROWED.**
G1 is violated in that round only if the environment mutates a process in it. Replaying `stop-boundary` followed by an empty round violates nothing. Theorem 0, part 2, says "can be". This is L44 as worded.

```
OLD: loses every monitor to that one step, and G1 is
NEW: loses every monitor to that one step, and G1 can be
```

**K4. `results.md`, section 4, line 410. NARROWED.**
"Not through its single checker" is shown only by a system that is not among the checker's 103 cases (item 3 above). The head of the note says a checked result names its source where it is not the checker's own run.

```
OLD: round R fails through its halt sources and not through its single checker (section 5).
NEW: round R fails through its halt sources and not through its single checker (section 5):
with a third halt source for each work process and still one checker it has no gap
(`lc04_single_checker.py` in `verification/g-final-round/last-check/`).
```

**K5. `results.md`, section 12.1, lines 1385 to 1386. NARROWED.**
The falsifier and the census agree on which predicates never fail and which do. They do not agree on how often: the report predicate fails in 387 of the census's 1,733 systems with no gap (22%) and in 798,222 of the falsifier's 1,169,616 (68%), which the next bullet calls "most". The falsifier also tested four predicates, not six. This is L14 as worded; its own evidence makes the same reservation.

```
OLD: At each of its five sizes it found what the census found at its two, and its samples of
larger systems show the same.
NEW: At each of its five sizes it found what the census found at its two: which predicates
never fail and which do. At three monitors the shares differ, because the census weighted
its draw. Its samples of larger systems show the same.
```

**K6. `results.md`, section 13, lines 1511 to 1513. NARROWED.**
`sweep.md` line 312 also names the three files of its full run as being in `sweep/`, and they are not there. `last-check.md` line 237 names `fullrun/`, `my-results.diff` and `my-README.diff`, and none is in `last-check/`.

```
OLD: `verification/g-final-round/`. The sweep's report names two diffs and a listing that are
not in its folder, because they repeat the documents, and three of its scripts have no
saved output.
NEW: `verification/g-final-round/`. The sweep's report names two diffs, a listing and the
three files of its full run that are not in its folder, because they repeat the documents
and the files of this folder, and three of its scripts have no saved output. The last
check's report names two diffs and a folder for its full run that are not in its folder,
for the same reason.
```

**K7. `results.md`, section 10.3, line 1094. NARROWED (minor).**
Three sentences later the environment may also stop a member. The clause is true of the rule, not of the game. This is L7 as worded.

```
OLD: rule to the observers themselves in a weaker form: a member stops only when every member
NEW: rule to the observers themselves in a weaker form: the rule stops a member only when every member
```

**K8. `results.md`, section 10.3, lines 1097 to 1098. SENSE.**
The text never says where the game starts. The definition of "can always restart" quantifies over states reached from a start, and the second half of the proof begins "From the state in which all are running". The script starts there (`check_model.py:737`). In 84 of the 192 pairs of a three-member graph and a starter, that state holds a member nobody observes, which the rule as worded would have stopped. The result is unaffected.

```
OLD: it can start again only when one is. The environment may stop a member, and later release
it.
NEW: it can start again only when one is. The game starts with every member running. The
environment may stop a member, and later release it.
```

**K9. `results.md`, section 10.3, line 1134. SENSE (minor).**
"That member" follows "a stopped member" and reads as the stopped one. The member meant is the one that starts first.

```
OLD: watches, that member is observed like any member and checks the others like any member: it
NEW: watches, the member that starts first is observed like any member and checks the others like any member: it
```

**K10. `results.md`, section 13, line 1500. STYLE, passive where the actor is the author.** L43 as worded.

```
OLD: as they stood before the reconciler's rulings were applied (the correction)
NEW: as they stood before the author applied the reconciler's rulings (the correction)
```

**K11. `results.md`, section 13, line 1503. STYLE, the same.** L15 as worded.

```
OLD: as it then stood; its docstrings were edited afterwards, in answer to the sweep
NEW: as it then stood; the author edited its docstrings afterwards, in answer to the sweep
```

**K12. `results.md`, section 13, lines 1554 to 1557. STYLE, the same, three places.** L16 as worded.

```
OLD:   The reconciler left three points for the author. Two were settled from the two public
NEW:   The reconciler left three points for the author. The author settled two from the two public
```
```
OLD:   every other, and that the commits cited are the heads of the public branches. The third,
NEW:   every other, and that the commits cited are the heads of the public branches. The author
  settled the third,
```
```
OLD:   which kinds of fault the four constraints assert (section 7), was settled from the
NEW:   which kinds of fault the four constraints assert (section 7), from the
```

**K13. `results.md`, section 13, lines 1588 to 1589. STYLE, the same.**

```
OLD:   - two steps of the proof in section 10.3 were reworded, and "can always restart" was
    defined. The statement stands;
NEW:   - the author reworded two steps of the proof in section 10.3 and defined "can always
    restart". The statement stands;
```

### `README.md`

**K14. `README.md`, "The run", line 227. NARROWED.**
Of the three, D7 is the docstring and D8 is parts the specification does not cover. D6 is neither: "§5 describes reading `systems.json`. The script only writes its own cases" (`findings-b.md`, section 1.5). This is L39 as worded.

```
OLD:     docstring and parts of the script that the specification does not cover. The
NEW:     docstring, the files that section 5 of the specification names, and parts of the script
    that the specification does not cover. The
```

**K15. `README.md`, "The run", line 254. NARROWED.**
Two proofs were written during the round. The correction added Theorem 0, part 3, with its proof (`sweep.md` line 46 lists "What is checked" among the phrases the correction added). The proof of section 10.3 came in answer to the sweep, and it is the one the last check refereed.

```
OLD: refereed the one proof written during the round.
NEW: refereed the proof written in answer to the sweep.
```

**K16. `README.md`, "The run", line 255. NARROWED.**
This pass confirms that all the corrections are in the documents. It does not confirm their content: K1, K3, K5 and K14 are corrections applied as worded.

```
OLD: a further agent confirmed them
NEW: a further agent checked them
```

**K17. `README.md`, "Costs and benefits", line 70. SENSE.**
The reason given belongs to "fixed for each ring" and now follows "set by the substrate". L28's wording kept the reason beside its claim.

```
OLD: fixed for each ring and set by the substrate, because growth adds rings and never makes a ring bigger.
NEW: set by the substrate, and fixed for each ring because growth adds rings and never makes a ring bigger.
```

**K18. `README.md`, design note 11, line 440. SENSE (minor).**
The preamble says the notes follow from the results "except where a note says otherwise". Note 11 rests on a ring member joining, which the model does not have, and does not say so.

```
OLD:     of `results.md`), is the stricter choice.
NEW:     of `results.md`), is the stricter choice. Like note 10, this note goes beyond what was
    checked.
```

**K19. `README.md`, "The implementations", line 474. SENSE, the two documents. Not in the diff.**
`results.md` lines 114 and 1103 to 1105 say of both implementations only that a halted member "keeps cycling", and section 13 says that limit was deliberate. The README still says more of the second implementation.

```
OLD: In both, a halted observer keeps watching.
NEW: In both, a halted observer keeps cycling.
```

### `check_model.py` (not counted in the tables)

**K20. `check_model.py`, `nested` docstring, line 436. Minor.**
With an upper ring of two, each member reports to the member it checks (line 468). With a base ring of one, the member has no next member, is checked by the coordinator and reports only to it (lines 445 to 455). Both occur in two of the catalogue's cases. Every other docstring and comment agrees with the code and with the documents. The change alters no output; the syntax tree is the same apart from the docstring.

```
OLD:     In the upper ring each member checks the next and reports to the one it does not check.
NEW:     In the upper ring each member checks the next and reports to the one it does not check.
    These sentences describe base rings of three and an upper ring of three. A lone base
    member is checked by its coordinator and reports only to it, and in an upper ring of
    two each member reports to the other.
```

Every OLD above occurs exactly once in its file, and all of them apply together (`k05`).

## Step 2: the corrections L1 to L45

L19 to L21 ask for no change. Of the other 42, none is missing.

- **As worded (36):** L1 to L3, L5 to L18, L22, L25, L27, L29 to L39, L41 to L45. In L22 the README's line adapts the docstring's wording ("of section 6 of `results.md`", "judgement"). In L25 the README leaves out the section reference.
- **In other words, meaning kept (6):**
  - L24. Current: "Under the four constraints, and against every kind of fault in the model, a reference system that has the eight properties, and whose work runs only on a current observation, has no gap at one fault per round. None of the eight can be removed from it without opening one." The sentence is split, and the opening clause is kept. The first sentence is 38 words.
  - L26. Current: "emerge from them and are not further constraints". One wording in place of three.
  - L28, README part. Current: "fixed for each ring and set by the substrate, because growth adds rings and never makes a ring bigger." The restatement is gone. The reason clause is misplaced (K17).
  - L40, note 10. Current: "A new member can mean that an existing member has to change which member it observes. … No observer changes what it observes until the new member is running, healthy and sending its reports round the ring. … While the old and the new overlap, the ring has more observation than it needs and loses none". It says what changes hands and drops "Every property holds for the whole of the switch". The preamble is as worded.
  - L4. Carried through L28.
  - L23. Its third point is taken up by the sentence on the sweep's report in section 13 (K6 completes it).
- **Applied as worded, and questioned here:** L12 (K1), L44 (K3), L14 (K5), L39 (K14), L7 (K7), L43 (K10), L15 (K11), L16 (K12).

**What the documents say about the last check, against its report.** All of it matches, apart from K2 and K15. 252 = 225 + 18 + 1 + 8, with 9 entries on style and 13 on sense. It was given two diffs and the folder. It refereed the proof and found the statement true of the game as the script defines it, with two steps to reword (L9). Its full run reproduced all three files. Its one wrong statement is L5. The six "chief narrowings" are L1, L7, L9 with L34, L3 with L8, L13 and L18. The three docstrings are those of L22, and all three are in the current script.

## Counts

A claim is one checkable statement, one table row or one citation in a changed or added passage, counted in each document that carries it. In section 10.3 the seven citations of "The implementation" that the diff does not touch are counted too.

| Document | Examined | CONFIRMED | NARROWED | WRONG | NOT CHECKABLE | STYLE entries | SENSE entries |
|---|---|---|---|---|---|---|---|
| `results.md` | 133 | 122 | 5 | 2 | 4 | 4 | 2 |
| `README.md` | 50 | 45 | 3 | 0 | 2 | 0 | 3 |
| Both | 183 | 167 | 8 | 2 | 6 | 4 | 5 |

Entries: K1 and K2 WRONG; K3 to K7 and K14 to K16 NARROWED; K10 to K13 STYLE; K8, K9 and K17 to K19 SENSE; K20 on the script, not counted. The six NOT CHECKABLE claims need no change: the two cost claims in each document, and the two in section 13 named under item 8.

| Step 2 | Corrections |
|---|---|
| As worded | 36 |
| In other words, meaning kept | 6 |
| Not applied | 0 |

**The script against the older copy.** No line that is not a docstring or a comment differs: eight docstring hunks and one comment (`section 7` to `section 9`), and the two syntax trees are equal once docstrings are removed.

**The full run.** One run of `python -I -B check_model.py --json results.json --systems systems-all.json` from the scratch folder (Python 3.12.2, exit 0, nothing on standard error, about 320 seconds) produced output and two JSON files byte for byte the same as `run-output.txt`, `results.json` and `systems-all.json`.

**The proof in section 10.3.** The statement and every step of the proof hold for the game as `restart_game` defines it. I found no exception on the 64 and 4,096 graphs for every choice of the starting member (192 and 16,384 cases), nor with self-observation allowed, and the second half held step by step on every graph it applies to. The one gap is in the setting, not in the proof: the text does not say that the game starts with every member running, which the definition and the second half both use (K8).

**Scripts**, all in `confirm/`, each with its output beside it as `k0N_out.txt`:
- `k01_recompute.py`: R and the ten removals, the ring of three against every predicate of section 3.2, the scope cases, the single-checker variants at `f` = 1 and 2, the `f` = 2 execution, Theorem 0 part 2 on 400 random systems, and the tally of plain systems.
- `k02_restart.py`: the restart game on every graph of three and four members, with a second decider written from the text, each step of the proof, and the case with no member able to start first.
- `k03_script_compare.py`: `check_model.py` against the older copy, line by line and by syntax tree.
- `k04_style_scan.py`: every added line of the two diffs with its current line number, and the mechanical scan for the writing rules. It also writes `k04_added_results.txt` and `k04_added_README.txt`.
- `k05_check_replacements.py`: that every OLD text occurs once and that all replacements apply together. It also writes three patched copies, `k05_patched_*.txt`, for reading.
- `run\`: the output and the two JSON files of the full run, and the two diffs regenerated.
