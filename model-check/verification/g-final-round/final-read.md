# Final round: final read

*Saved by the main session from the final read's hand-back, word for word. The pass was
told not to write a report file.*

# Final read of the hand-written passages

Both supplied diffs match diffs regenerated from `sos-formal\final-round\confirm\k05_patched_*.txt` to the current documents. Nothing was written anywhere, and the checker was not run.

## The five passages

**1. `results.md`, section 10.3, first sentence of the second paragraph of "The implementation". CONFIRMED.**
- The first clause holds as "not without its own check": `observers/SPEC.md:556` gives the clear-condition, and `:364-379` shows that its assertions cover every other member.
- The second clause holds by `:364`, `:425`, `:558` and `:418`: the member's failing `store-readable` raises a halt, the member removes nothing while the assertion fails, and a halt in force keeps the ring halted.
- The sentence agrees with the rest of the paragraph, including "that halt does not block the stand-down" (`:199`, `:556`). No writing rule is broken.

**2. `results.md`, section 13, row "Final round, confirmation". CONFIRMED.**
- Every count matches `confirm.md`: 183 = 167 + 8 + 2 + 6, with 4 entries on style and 5 on sense.
- 42 corrections is L1 to L45 less L19 to L21: 36 as worded, 6 in other words, none missing.
- 20 entries is K1 to K20, each with an exact replacement.
- The report supports "two diffs", the two steps in that order, and the full run.

**3. `results.md`, section 13, paragraph after the table. One entry; the rest CONFIRMED.**
- All five reports record a full run that reproduced the outputs, and none records a wrong result of the checker.
- The sweep, the last check and the confirmation reproduced the files byte for byte. The two verifiers' output differed only in the file names on the two closing lines, and the JSON was identical. No change is asked.
- The sentence on `lc06_changed_lines.py` is confirmed: its root resolves to `model-check`, under which neither `sos-formal` nor `shared-templates` exists.

**NARROWED**, the sentence on the confirmation's files.
- The report also says each script has "its output beside it as `k0N_out.txt`". The outputs of k03, k04 and k05 are not in `confirm\`, and the sentence omits them.
- "The scripts read working files" is true of two of the three. `k03_script_compare.py` reads the older working copy of the script, and `k04_style_scan.py` reads the two supplied diffs. `k05_check_replacements.py` reads only `results.md`, `README.md` and `check_model.py` in the folder itself, as they stood before the replacements.

```
OLD: three patched copies, two listings and three scripts that are not in its folder: the
scripts read working files.
NEW: three patched copies, two listings, and three scripts and their three outputs that are
not in its folder. Two of the scripts read working files. The third checks the
confirmation's replacements against the two documents and the script as they stood before
the author applied them.
```

**4. `results.md`, section 13, bullet "From the confirmation". One entry; the rest CONFIRMED.**
- Both wrong statements and what the bullet says of each match K1 and K2.
- All 20 entries (22 replacements) are in the current files word for word, K20 in a docstring. Three had their line breaks moved afterwards.

**NARROWED**, the list of four passages. It does not match the diffs. The diffs show hand-written text the list leaves out:
- In the paragraph after the table, the sentence on reproduction gained "and the confirmation", and "None of the four" became "None of the five".
- In the README, the sentence with the counts replaced a placeholder by hand, and the sentence "The author applied its replacements by script." was added. The bullet names the first only as something read, and the second not at all.
- The other three items (the 10.3 sentence, the table row, the bullet) match. I read every one of these passages, including the second README sentence.

```
OLD: The author then wrote four passages by hand: the first
  sentence of the second paragraph of "The implementation" in section 10.3, to agree with
  the first of those corrections; the confirmation's row in the table above; the two
  sentences on the files its report names; and this bullet. One further agent read those
  four passages and the sentence of the README that gives the confirmation's counts.
NEW: The author then wrote these passages by hand.
  In this note: the first sentence of the second paragraph of "The implementation" in
  section 10.3, to agree with the first of those corrections; the confirmation's row in
  the table above; in the paragraph after that table, the count of five passes, the
  sentence on `lc06_changed_lines.py` and the sentence on the files the confirmation's
  report names; and this bullet. In the README: the sentence that gives the confirmation's
  counts and the sentence after it. One further agent read each of them.
```

If both replacements are applied, the bullet will not record that. One more sentence after "read each of them." would cover it, for example: "The author applied that agent's two replacements."

**5. `README.md`, "The run", the sentence with the confirmation's counts. CONFIRMED.**
- The counts match `confirm.md` and the table row.
- The added sentence "The author applied its replacements by script." agrees with the files: the documents differ from the script's output only in the hand-written hunks.

## Closing lines

- **Statements:** 60 examined (2, 15, 20, 14 and 9 by passage), 57 confirmed, 3 narrowed, in the two entries above.
- **Line-break hunks:** the three hunks of `results.diff` at old lines 1093, 1133 and 1558 are identical to the script's output once white space is normalised.
- **Script:** `shared-templates\model-check\check_model.py` is byte for byte the same as `sos-formal\final-round\confirm\k05_patched_check_model.py.txt` (42,487 bytes, same SHA-256).
- **Local paths:** `verification\g-final-round\confirm.md` and the four files of `verification\g-final-round\confirm\` hold no local absolute path, no user name and no email address.
