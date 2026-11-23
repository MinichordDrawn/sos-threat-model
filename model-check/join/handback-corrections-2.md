# Hand-back: corrections 2 to `join\results-join.md` and `join\model-spec-join.md`

All six points are dealt with: four changes to the write-up, one to the specification, and `corrections-1.md` left as it is. The checker, the catalogue and the answers were not touched. I found nothing wrong in the reader's work.

## The six points

1. **Section 6.2 (A10).** The reader is right: in my chain table two rows have a gap with every monitor checked, and the other two rows with a gap are ones where N6 or N7 has no state checker. The text now says: "two rows of the chain table below ("N5 does not read N6's signal" and "N6 does not report to N5") have a gap although every monitor always has a present state checker."

2. **Section 10 (A15).** The reader is right. I replayed the five-monitor system at `f` = 2: after stop M2, stop M3 and then mutate M1, only M4 and M5 are flagged, from round 1, and nothing detects M1. The text now says: "then in the first round with a fault some live correct monitor detects a fault of that round." The counterexample is not added.

3. **Theorem L row (section 3).** The row is not wrong and was not recomputed. Its counts were made with a narrower test than the hypothesis as now worded, and a passage under the table now says so:
   - a system counted as meeting the conditions only if it has no slow edge at all, no switch on any monitor, no substrate and no two monitors in one boundary;
   - so every system in the row's first two columns meets the hypothesis as worded;
   - a system that meets it with some other edge slow is counted among those whose conditions fail.

4. **Section 6.1 (A1).** The description of the mixture did not match what was run and is corrected.
   - The five shapes are as before: every system of five monitors, every one of six or a sample of 400, and samples of 150 at seven and at eight.
   - The mixture was sampled at every size, 150 at each of five, six, seven and eight monitors, each new monitor's shape drawn at random. It was not run exhaustively at five and six.
   - The text now says the samples are random draws and may repeat a system.
   - The 12,240 are 3,060 per base ring: 344 in the mesh shape, 344 as signal-reading coordinators, 724 in each of the two cycle-member shapes, 324 with one watcher and 600 in the mixture. This is the reader's reconstruction, and it matches my script.
   - The families are now spelled out: the hub at 9, 10 and 11 monitors, the chain and the fan at 9, 12, 16 and 20, each in the mesh shape and as cycle members read by the coordinator, "That is 22 systems."

5. **`model-spec-join.md`, J1 (B1).** The sentence now reads: "One that names an initial monitor or a process listed in `works` is always satisfied, and one that names a late monitor is satisfied once that monitor has joined, whether or not it has since been stopped." Both programs already behave this way, so no answer changes.

6. **`corrections-1.md`, A13.** Left unchanged, as a record.

## Files

All in `«WORK»\sos-join-model\join\`:

- `results-join.md` (4 changes)
- `model-spec-join.md` (1 change)
- `corrections-2.md` (every change as before and after text, under the number of the point it answers)
- `results-join.before-corrections-2.md`
- `model-spec-join.before-corrections-2.md`

I wrote and then deleted a one-shot script that applied the edits and generated `corrections-2.md` from the same texts. `diff` of each before-copy against its current file shows exactly the changes listed. Nothing was read or written outside `sos-join-model\`.
