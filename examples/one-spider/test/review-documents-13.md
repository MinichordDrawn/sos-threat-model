There are things to correct, but none of them is a corrected statement about what the program does: every such statement in the two diffs is true of the code. What needs attention is two sentences added to one entry in `checks.md`, one phrase kept in an altered comment, and five places left behind.

All paths below are under `«WORK»\check-twelve-b\docs\now\`.

## Findings

### 1. `checks.md` 633-636: wrong as the document reads, or cannot be told from the folder

> "The check of the documents that followed measured what is left of that edge: a text of 24 million control characters now costs a round a second and a half at the most"

- **If it means `review-documents-11.md`, it is wrong.** That is the next entry and the last check `checks.md` lists. Lines 428-430 say that check read the same version as `review-change-10.md`, and line 386 says each check was made on the version before the changes it led to. That is the version in which 24 million control characters still cost more than five seconds, so it cannot have measured what they cost "now". Its own entry (639-642) says none of its four findings was about what the program does.
- **If it means a later check, the documents do not list it.** They count twenty-one checks (387, 426, 657) ending at `review-documents-11.md` (430). They also still say "What the last two checks led to is tested, and no reviewer has read it" (`checks.md` 661, `README.md` 538-539).
- **"And it found five things the tests did not hold" (637) now has an unclear subject.** It follows two sentences about the other check, so "it" no longer plainly means `review-change-10.md`.

### 2. `checks.md` 635-636: narrower than stated

> "and it takes one of ninety-six million to pass five"

- The documents give three figures: 24 million at a second and a half (`checks.md` 634-635), 64 million at four and a half (`observation.md` 128-129), and 96 million at more than five (`observation.md` 130).
- In the code every reading of a text is one pass over it: `quote()` at `src/backdoor.rs` 67-89, `text_of` at `src/watch.rs` 191, and the clones and comparisons in `look`, `differs` and `redone`. So the cost grows in proportion to the length.
- By the documents' own figures, five seconds is then passed at about 71 to 80 million, not 96.
- What the figures support is that 64 million does not pass five and 96 million does. `observation.md` 128-130 says exactly that and is fine.
- `README.md` 344-346, "a text by some hundred million characters", is loose enough to stand.

### 3. `checks.md` 634-635: cannot be told from the folder

> "a text of 24 million control characters now costs a round a second and a half at the most"

- This figure is in no other document and is not among the measurements your brief describes; those are 64 and 96 million.
- It agrees with the other two by proportion: about 16 million a second against about 14.
- The code could give all three. A text that lands after the cut at `src/watch.rs` 1417 is read whole by `look` (717-718), `differs` (795-809) and, in a halt, `mend` (1274) before the next cut at 1456. The same holds after the cut at 998, in `redone` (1071). Each control character is written as six bytes by direct pushes (`src/backdoor.rs` 79-83).
- The five seconds are `QUIET_MOST` waits of one second (`src/watch.rs` 1805, 1883, 2075-2080), and the second observer to find it stops the program (`src/main.rs` 276-310).
- I did not measure anything.

### 4. `src/watch.rs` 1338, altered comment: narrower than stated

> "Until then nothing at all is done with the game's state: it is not worked, and no observer looks at it."

- "No observer looks" is true. "Nothing at all is done with the game's state" is too wide for the same reasons "nothing looks" was.
- The state is still written out for a screen after every round of such a halt: `play` calls `shown` at `src/main.rs` 322-325, which reads the spider and the world at `src/watch.rs` 1662-1674.
- The backdoor still reads it (`src/backdoor.rs` 274; only writes are stopped, at 276-278).
- The same phrase stands outside the diffs, which is why I list it and leave the call to you:
  - comments at `src/watch.rs` 706, 861 and 1529, and `src/backdoor.rs` 230;
  - documents at `README.md` 230-232 and 294-295, `observation.md` 357-358, and `checks.md` 619 and 626.
- `README.md` 230-234 limits it with a list ("no observer looks at it, nothing is written to it, and nothing asked of it is taken down"), and every item in that list is true.

### 5. Left behind: the corrected statements still said the old way

- **`src/watch.rs` 4920-4921, test comment:** "a list made long there is left as it is, since nothing looks at it". Fourteen lines on, the same test has the backdoor read it (4935-4938).
- **`src/watch.rs` 5125-5126, test comment:** "nothing at all is done with the game, and nothing looks. So nothing is written to it either". This is the twin of `backdoor.md` 74, which now says "no observer looks".
- **`src/watch.rs` 5578-5579, test comment:** "a halt that cannot be put right, in which nothing is looked at".
- **`src/watch.rs` 3283, a test's message:** "the work is handed more of the list of halted moths than a game could have". This is the phrase correction 3 took out of `checks.md`. The bound is 20,480, which is room for as many moths as a screen is sent (comment at 691-693), not for as many as a game could have.
- **`test/limits.js` 140, comment:** "the one that has waited longest gives up its place". This is the short form `outside.md` 36-38 had before; it leaves out the connection answered longest and the screens.

## What I checked and found true

- **`backdoor.md` 74-75, `src/watch.rs` 1344: no observer looks.** In such a halt `turn` returns at `src/watch.rs` 1339-1349, before `watch()`, and sends only `Tick` (2010-2013).
- **`backdoor.md` 74-75: every write is refused.** `push()` and `pop()` are refused at `src/backdoor.rs` 232-233, a write to a field at 276-278, and a `during` line at 132-133.
- **`observation.md` 118, `src/watch.rs` 827-830: nothing else is cut.**
  - A round cuts with `fit_kept` first (1332) and reaches `fit` (1353) only past the return at 1348.
  - A line at the backdoor cuts nothing, because `cut_down` (862-866) does nothing in such a halt.
  - The five points of a round are 1353, 1417, 1456, 998 and 1035.
- **`backdoor.md` 70 is not left behind.** "Nothing is cut there" is said of the line at the backdoor, where it is true.
- **`checks.md` 632-633: the 20,480 characters.**
  - `halted_moths()` (`src/watch.rs` 694-702) takes at most `MOST_SENT * 20`, which is 20,480 (line 99).
  - That is 20,480 bytes, moved back to a character boundary, so never more than 20,480 characters.
  - It is the only way the list reaches the work (1457, 1465). The second doing is handed `again::in_web` of the record (1068), not the list.
  - `observation.md` 103 and 119-120 and `checks.md` 247-249 say the same.
- **`observation.md` 128-130 and 133, `README.md` 344-346: the text's edge.** They agree with one another, and no "tens of millions" or "thirty million" is left anywhere.
- **`outside.md` 36-38: which connection is put out.** This is `admit()` at `src/main.rs` 114-128.
  - First choice: the non-screen connection that is not being answered and has the oldest `since`.
  - Otherwise: the non-screen connection that is being answered and has the oldest `since`.
  - `since` is set on admission and at each change of `answering` (136-141).
  - A screen is always marked as answering (563, 569), so "if every one is being answered" is exact.
  - The comment at 109-113 says the same.
- **`checks.md` 623-624: "the version it read".** This agrees with line 386 and with the changes the same entry says came after it.

## Did a correction make a right statement wrong?

No. Each statement that was replaced was wrong or too wide before, and its replacement is true of the code. The two problems in `checks.md` (findings 1 and 2) are in sentences the correction added, not in ones it changed.

## What I could not check

- **The measurements.** Your brief rules out running the program, and I did not take new ones.
- **The reviewers' hand-backs.** `test/review-*.md` are absent, as you said. So the counts on `checks.md` 623-624 and the "five things" on 637 are unverified.
- **Tests.** I ran none: no statement in the diffs turned on a test's outcome that reading the code left open.
- **One read outside the folder.** One of my searches of the folder returned more than the tool shows, and the harness saved its output to its own results file under `«HOME»\.claude\projects\`. I read that file. It held only that search's output and was the only thing I read outside the folder. I wrote nothing anywhere.
