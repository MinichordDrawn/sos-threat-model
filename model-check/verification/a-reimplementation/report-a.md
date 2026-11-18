# Pass A: reports

*Saved by the main session from the two hand-backs of pass A, word for word. The pass could
not write a report file itself.*

## First report

**Results:** `results-a.json` (implementation: `impl_a.py`, same folder).

**Counts:** 94 of 94 cases computed, input order. G1 null: 53. G2 null: 49.

**Exhaustiveness:** every case was searched breadth-first over rounds until no unseen state remained; nothing was cut short. The whole file runs in 33 s.

**State counts differ from your estimate:** ten cases have 53,129 to 524,308 reachable states, not tens of thousands. All ten have both goals non-null. The largest case with a null has 21,516 states.

**Self-check:** a second set-based transcription in `impl_a.py` agrees on G1, G2 and state count for all 94 cases. It shares my reading, so it only catches coding slips.

**Ambiguities** (literal reading chosen each time; alternatives 1, 2 and 5 were run on all 94 cases and changed 0 results):
1. `fail-substrate`: "otherwise add it to `bad` and to `hidden`". I also hide a non-monitor that is already visibly bad. The alternative hides only those not yet bad. I also tested enabling on "not in `hidden`" instead of "not in `bad`".
2. "Let `out` be the set of monitors that are in `flagged`, in `alive`, and not in `bad`" against "A monitor that is in `flagged` but no longer in `active` reports to nobody." A flagged monitor that is later switched off stays in `out` and counts for responded; I read "reports" as `fwd` only. I tested excluding `off` from `out`, from responded, and from both.
3. "`joiner` … a work process that is absent at the start" against `alive` initially holding "all work processes", and `halt_inputs` typed "map work -> list". I read "work processes" as the `works` list, and let `halt_inputs` and `checkers` keys apply to the joiner. `alive` is never read for a non-monitor, so this cannot change a result.
4. "A key missing from a map means an empty list": `boundary` and `substrate` map to ids, not lists. I read a missing key as none. No monitor in the file lacks a boundary.
5. `stop-boundary`: "at least two monitors have boundary `b`" is counted over all monitors, alive or not. Requiring two alive is equivalent, since with one alive the step equals `stop m`.
6. The specification is silent on halted processes in `mutate` and `fail-substrate`. I apply both to them ("present" is the only condition), so `bad` can grow after all work has halted. No alternative tested.
7. Responded: "every present non-monitor process is in `halted`". An unjoined joiner is not counted, so an execution can end before it joins. No alternative tested.

**Wrong or unimplementable:** nothing. The specification is implementable as written.

**Coverage of the cases:** `stop-boundary` is enabled only in `R-P6/f1`, and `disable` only in `R-P5/f1`. Substrates and the joiner appear only in the 13 `R` cases. The zero-change results above are therefore weak evidence for those steps.

**Rule deviation:** I wrote two files of my own (a run log and a copy of my results) to the session scratchpad, outside the folder. I read nothing else outside the folder.

## Second report, on the addendum and seven further cases

**New cases** (`results-a-extra.json`), as `id: G1, G2`:
- `mesh4-one-boundary/f1`: 2, null
- `nested3-upper3-ring-boundaries/f1`: null, null
- `R-gate/f1`: 3, 1
- `reflex-direct-instant/f1`: null, null
- `reflex-direct-slow/f1`: null, null
- `reflex-relayed-instant/f1`: null, null
- `reflex-relayed-slow/f1`: null, 1

All seven were explored exhaustively; the largest has 1,257 states.

**Original 94:** unchanged. The extended `impl_a.py` reproduces `results-a.json` byte for byte; I compared without rewriting the file.

**Ambiguities in the addendum:**
1. `gate` false: "The work phase (section 3.3) then uses, as `out`, … So only flags raised in earlier rounds count." It is silent on the silence clause. My reading: silence still reads `alive` after this round's environment phase. Delaying it to `alive` at round start leaves `R-gate/f1`, the only `gate`-false case, unchanged.
2. `slow_reports`: "was in `flagged` at the start of the round". I take this as `flagged` before this round's detection. Forwarding from post-detection flags is excluded by the addendum's last sentence, and would change `reflex-relayed-slow/f1` G2 from 1 to null.
3. No case combines `gate` false with `slow_reports` true, or with `window` 1.

The six earlier alternative readings change none of the seven new results. Nothing was written outside the folder.

## Two cases added after this pass

`mesh3-unread-M3/f1` and `mesh3-unread-M3/f2` were added to the catalogue after pass A had
reported. The main session ran `impl_a.py`, unchanged, on those two systems. It returned
(null, null) with 14 states and (2, null) with 76 states, the same as the checker.
