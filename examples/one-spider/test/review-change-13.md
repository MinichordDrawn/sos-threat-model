**I found nothing wrong.** All three claims hold. One thing to know under claim 2: one break of the moth edge passes the first test and, as far as I ran, nothing else holds it.

All line references are into `after/`.

## Claim 1. Nothing but the tests is changed in `src`: holds

- I made the difference again with `diff -ruN before/src after/src`; it is `changes.diff` byte for byte. The only other files that differ between the two trees are `README.md` and `checks.md`.
- The test module is `src/watch.rs:2104-5907` (`#[cfg(test)] mod tests {` to the file's last line). Lines 1-2103 are identical in the two versions.
- The two added lines `3313-3314` are inside `what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long` (`3250-3341`).
- The five added lines `4769-4773` are inside `the_second_text_of_the_rules_takes_nothing_from_the_first` (`4727-4835`).

## Claim 2. Each added assertion tests what it says: holds

Both tests pass on the code as it is; I ran each three times in a throwaway copy identical to `after/`. Every result below was run, one break at a time, against the named test.

### The edge of the number of moths

Code: `over()`, `src/watch.rs:1597`. Added assertion: `src/watch.rs:3314`.

| Break | Named test | Assertion that failed |
|---|---|---|
| `>=` for `>` (the break named in the brief) | fails | 3314, the added one |
| `> MOST_HELD - 1` | fails | 3314 |
| `> MOST_HELD / 2` | fails | 3314 |
| `> 1023` written as a number | fails | 3314 |
| `> MOST_HELD + 1` | fails | 3316 |
| `> 1025` written as a number | fails | 3316 |
| `> MOST_HELD * 2` | fails | 3316 |
| the check taken out (`if false`) | fails | 3316 |
| the legs counted in place of the moths | fails | 3316 |
| the record's moths counted in place of the state's | fails | 3316 |
| `!= MOST_HELD` | fails | 3312 |
| `<` for `>` | fails | 3312 |
| `== MOST_HELD + 1` for `> MOST_HELD` | **passes** | none |
| `MOST_HELD` itself made 1023 (line 92) | **passes** | none |
| `MOST_HELD` itself made 1025 (line 92) | **passes** | none |

- **The named break is held by the added line alone.** The same `>=` break in a copy of `before/` passes the test.
- **`== MOST_HELD + 1` is let by.** The test tries 1,024 and 1,025 moths and no larger number with the pointer inside, so a break that is right at exactly those two numbers and wrong further out passes. It also passes `what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at`, which I ran against it. I did not run the rest of the suite against it. One more assertion with many more than `MOST_HELD + 1` moths would hold it.
- **The constant made 1023 or 1025 is let by this test but held by another.** The test names the constant, not the number. Each of the two fails `what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at` at line 4941, through the pin at line 4856.

### The second text counting the clicks for itself

Code: `ruled()`, `src/watch.rs:1059-1061`, and the second text's rule at `src/rules/again.rs:272`. Added assertion: `src/watch.rs:4773`.

All seventeen breaks fail the named test.

| Break | Assertion that failed |
|---|---|
| `clicks: usize::MAX` (the break named in the brief) | 4773, the added one |
| the second takes in `self.asks` | 4773 |
| the second takes in `self.asks_third` | 4773 |
| `own.clicks.len() + 1` | 4773 |
| `own.clicks.len().max(1)` | 4773 |
| `own.clicks.len().max(asked.clicks)` | 4773 |
| presses counted in the first list | 4773 |
| presses counted in the third list | 4773 |
| the second list used only if it is as long as the first | 4773 |
| the click rule taken out of the second text (`if false`) | 4773 |
| that rule one click loose (`+ 1.0`) | 4773 |
| `clicks: asked.clicks`, the first's account | 4768 |
| the second handed the first's whole account | 4768 |
| `own.clicks.len().min(asked.clicks)` | 4768 |
| clicks counted in the state the work left | 4764 |
| the second starting from the state and not the record | 2129, in the helper that sets the game up |
| `>=` for `>` in the second text's rule | 2129 |

- **Three of these pass the test in a copy of `before/`**, so the added line alone holds them: `usize::MAX`, the greater of its own count and the first's, and the click rule taken out of the second text altogether.
- Where the added assertion failed, it failed as it says: left `(None, None)`, right `(None, Some("a moth picked out of the web with no click"))`.
- The assertion reaches `ruled()` directly. In a real round the three lists differing is itself looked for elsewhere (line 818); that does not bear on what the assertion says of the two texts.

## Claim 3. Every line `documents.diff` adds or alters is true of the code and tests: holds

- **`checks.md:251-252`**, "With 1,024 moths the one under the pointer must still be said, and with one more, nothing may be": true.
  - `watch.rs:3313-3314` sets `MOST_HELD` moths and requires `over()` to give a moth.
  - `watch.rs:3315-3316` sets `MOST_HELD + 1` and requires nothing.
  - `MOST_HELD` is 1024 at line 92, and `over()` is what a screen is sent (line 1741).
  - Narrow reading, not an error: the assertion requires that what is said is a moth (`over.3 == "moth"`), not which one or where. The 1,024 are copies of one moth in one place, so there is no other it could be.
- **`checks.md:308-309`**, "With the click taken out of the second list of what was asked alone, the second must refuse the round and the first allow it": true.
  - `watch.rs:4771-4772` clones the round and takes every `Ask::Press` out of `asks_again` only; `asks` and `asks_third` are untouched.
  - `watch.rs:4773` requires `(None, Some("a moth picked out of the web with no click"))`: first allows, second refuses.
  - `asks_again` is the second list (lines 421-426), and the one `ruled()` gives the second text (line 1060).
- **The counts agree in every place they are given.**
  - The list in `checks.md` has 12 `review-change*` entries, 19 `review-documents*` entries and the 4 first reviews: 31 checks, 35 entries, none twice.
  - `README.md:484` says twelve and nineteen; `README.md:491` says thirty-five hand-backs; `README.md:493` says thirty-one later checks.
  - `checks.md:397`, `437` and `728` say thirty-one.
  - No old count (eleven checks, thirty, thirty-four) is left in any of the six documents or in `page.html`.
- **`checks.md:445-446`**, "`review-change-12.md` is a check of the change the eleventh led to": agrees with its entry at 707 and with where the entry stands, last in the list.
- **`checks.md:707-713`**, the entry for `review-change-12.md`: nothing in it is contradicted by the code.
  - "It found nothing that needs a change to the code" agrees with claim 1.
  - "found two breaks that a test names and lets by: the tests now hold each" I ran: each named break passes its test in `before/` and fails it in `after/`.

## What I could not check, and why

- **What `review-change-12.md` itself ran or found**: 88,095 single faults, 4,344 pairs, 13,929 runs, "a hundred ways", "the three changed tests", the two versions coming out the same. The hand-backs are left out of this copy and the version before `before/` is not here.
- **That thirty-five hand-backs are in `test`**, and that the checks were made in the order the list gives. I checked only that the counts match the list.
- **Whether any other test holds `== MOST_HELD + 1`.** I ran it against two tests only, because the full suite was not to be run.
- **The program was not run**, and nothing outside the two tests and the altered document lines was checked, as the brief asked.

## Left in the folder

- `mutate.sh` and `run-all.sh`, the scripts that made the breaks.
- `log.txt`, `log2.txt` and `log3.txt`, every break with its diff line and result.
- The throwaway copies are removed. `before/` and `after/` were not written to and still give `changes.diff`.
- The tool harness saved some of its own output outside the folder; I did not open those files and re-ran the work with the output logged inside the folder.
