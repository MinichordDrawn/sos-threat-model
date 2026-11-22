## Independent review of One Spider (Rust server, door, page)

I reviewed the copy at `«WORK»\review-outside-2\`. I read `src/main.rs`, `src/door.rs`, `src/game.rs`, `src/rules.rs`, `src/watch.rs` (lines 1–1024; the tests after that were skimmed only), `page.html` and `README.md`. I built the release binary, ran it on 127.0.0.1:8181 and probed it with node scripts. They are in `...\review-outside-2\probe\` (`lib.js`, `big.js`, `hold.js`, `hold2.js`, `fuzz.js`, `slow.js`, `letthrough.js`). I stopped only the process I started (the one whose path is in my folder). Nothing went to port 8138, I did not use the web, and I did not run `cargo test`.

No write or request I tried got a change into the game's recorded state without a halt. No write survived a halt either: every door write was found and put back. What I did find is mostly at the boundary: a text that outlives every halt and slows the game, connection and screen limits that anyone on the machine can hold, and text fields with no size limit.

---

### Findings, most serious first

**1. Eight cancelling `during` lines are "let through", and their text is then sent in every frame for the rest of the game (up to about 3 MB a frame). The game slows silently from about 59 to about 17 rounds a second.** Ran it.

- **Where:**
  - `door.rs` 102–125: each `during` line is tried on a fresh clone of the current game, never with the lines already queued.
  - `watch.rs` 804–811: all queued lines run, and if the round is recorded, `self.pending = inside`.
  - `watch.rs` 775–779: `self.let_through = Some(self.pending.join("; "))`.
  - `watch.rs` 1021: `text(self.let_through)` goes into every frame.
  - `let_through` is never cleared by `correct()`. Only a new `Game` or a later let-through replaces it.
  - The queue holds up to 8 lines (`watch.rs` 917–923), each up to the 65,536-byte body limit.
  - `quote()` (`door.rs` 66–82) turns each control character into `\u00XX`, six characters for one.
- **Mechanism:** `during spider.body.x += 1` and `during spider.body.x -= 1` each change the state when tried, so both are accepted. Run together after the work, they cancel exactly, because adding and taking away 1 is exact for x between 1 and 2^53 unless it crosses a power of two. So the round is recorded and both lines are let through.
  - The door ignores whitespace between the operator and the value, so each line can carry about 64,000 vertical tabs (U+000B counts as whitespace to Rust's `trim`).
  - Once quoted, the eight lines are about 3 MB of text.
- **Reproduce:**
  - Run `node probe\letthrough.js`.
  - It sets `/how` to `at once` and sends eight POSTs to `/door` at the same time. Four are `during spider.body.x +=<64000×U+000B> 1` and four are `during spider.body.x -=<64000×U+000B> 1`.
  - It retries if the lines land in two different rounds, which gives an ordinary halt that is put right.
- **What happened:**
  - Before: frames of 6,735 characters, `passed` 0, 58.4 rounds a second.
  - On the second try: `passed` 1 and a `let` of 512,158 characters. Frames became 3,079,216 characters and the game (not halted) ran at 17.2 rounds a second, measured by `world.ring[4].beat`.
  - Since `dt` is capped at 0.05 s, game time then runs at about 85% of real time.
  - After a further door write, its halt and its putting right, the frame was still 3,078,746 characters.
  - Nothing tells the owner this happened, and nothing they can do clears it except a later short let-through.
- **Fix:**
  - Keep only a short summary in `let_through` (for example the first 200 characters, or just the count).
  - Limit the length of a `during` line (for example 1 KB) and the total size of the queue.
  - Try each new `during` line on a clone with the already-queued lines applied, so a line that cancels a queued one is refused as "writes nothing".
  - Consider clearing `let_through` when a halt is put right.

**2. Any program on the machine can hold all 32 connection slots indefinitely, which shuts the owner's page out. "Put it right" then fails with nothing shown.** Ran it.

- **Where:**
  - `main.rs` 141–151: a cap of 32, counted from connect.
  - `main.rs` 184: `set_read_timeout(120 s)`, which applies to each read, not to the whole request.
  - `main.rs` 170–180: `line_of` takes a line of up to 8,192 bytes, and there can be up to 64 header lines.
  - `page.html` 438: `fetch('/right')…catch(() => {})` swallows the failure.
- **Reproduce:**
  - Run `node probe\hold2.js`: 40 TCP connections to 8181 that send nothing.
  - Run `node probe\hold.js` for the slow-sender case: the request line plus `X-Slow: ` header, then one byte every 60 s.
- **What happened:**
  - With the connections open, `GET /` and `POST /right` (correct Origin) got no answer at all, and `GET /stream` got 503.
  - Idle connections were closed by the server at about 120 s.
  - The two trickling connections were still open after the 120 s mark, as expected from a timeout that applies to each read. One byte every 119 s holds a slot for as long as the sender likes.
  - Meanwhile:
    - the owner cannot load or reload the page;
    - pointer and door POSTs fail ("the server did not answer");
    - the "Put it right" click does nothing with no message;
    - an EventSource that drops cannot get back in.
  - The 33rd and later connections get the 503 written before their request is read and are then closed. In practice the client often saw a reset and no answer.
- **Fix:**
  - Give a request head a total deadline (for example 5–10 s from the first byte), not 120 s for each read.
  - Give idle keep-alive connections a short timeout (for example 15 s).
  - When the cap is reached, close the oldest connection that has no request in progress, rather than refusing the newest.
  - Read (or shut down) the request before closing a refused connection, so the 503 actually arrives.

**3. Eight readers of `/stream` shut the owner's page out of the game, and the page never tries again.** Server side ran; page behaviour read only.

- **Where:**
  - `main.rs` 238–246: the 9th screen gets 503.
  - `page.html` 185–186: `new EventSource('/stream')` with no `onerror` and no reconnect. Under the HTML spec, an EventSource that gets a non-200 status fails for good and does not retry.
- **Reproduce:** `node probe\hold.js`, first part (8 readers of `GET /stream`).
- **What happened:**
  - The 9th `GET /stream` got `503 Service Unavailable` while `GET /` still got 200.
  - So if the owner reloads, or the page's stream drops (sleep, network blip) while 8 screens are held, that tab shows "The server is silent" until it is reloaded after the readers leave.
  - No Origin is needed (see 5).
- **Fix:**
  - When full, drop the oldest screen rather than refusing the new one.
  - In the page, handle `onerror`: if `readyState === EventSource.CLOSED`, make a new EventSource after a short wait.
  - Refuse cross-site GETs (see 5).

**4. A handful of door lines can make each frame about 8 MB and slow rounds from about 59 to 15 a second, for as long as the halt lasts.** Ran it.

- **Where:**
  - Text fields have no length limit (`door.rs` 240–244; `game.rs` 159–167; `watch.rs` 125–139).
  - `Observer::shown(24)` (`watch.rs` 146–159) shortens only the copies. `name`, `held` and `why`, plus `spider.body.state`, `world.web.torn` and the moths observer's `held` (again in `"halted"`), are sent in full in every frame (`watch.rs` 951–1022).
  - The frame is built inside the game lock on the game thread.
- **Reproduce:**
  - `node probe\big.js` sets `on a click`, then sends 8 lines: `spider.ring[*].why = "<65000×U+0001>"`, the same for `name` and `held`, the same three for `world.ring[*]`, plus `spider.body.state = "…"` and `world.web.torn = "…"`.
  - `node probe\slow.js` measures the round rate.
- **What happened:**
  - Frames went from 5,559 to 8,196,001 characters. They were still valid JSON, and the halt was found ("the gate found the legs A observer with a flag up…").
  - One local reader got about 5 frames a second, which is 38 MB a second.
  - The game thread fell from 58.6 to 14.8 rounds a second (13.7 with 7 screens).
  - Once put right, everything was back to normal (5,822 characters; "the body put back, the web put back, all eight observers started again").
  - The default "after a pause" ends this in 0.6 s. Under "on a click" it lasts until the click, and a browser parsing 8 MB frames may make that click hard. I did not test this in a browser.
- **Fix:**
  - In `shown()`, shorten every text the way copies already are (24 characters plus "…"); the door can still read them in full.
  - Optionally, limit the length of a text written at the door (for example 1 KB).

**5. The GET endpoints (`/`, `/plans`, `/stream`) accept requests from any origin.** Read; checked with curl; browser effect not tested.

- **Where:** `main.rs` 231–246 and 297. Only `Host` is checked, and a foreign page's request carries the true Host.
- **Reproduce:** `curl -i -H "Origin: http://evil.test" -H "Sec-Fetch-Site: cross-site" -H "Sec-Fetch-Mode: cors" http://127.0.0.1:8181/stream` gives `200 OK` and the stream starts.
- **What it means:**
  - A page on another site cannot read the reply: there is no `Access-Control-Allow-Origin`, and CORP is `same-origin` with nosniff.
  - It can still make the browser open these requests: an EventSource, a no-cors fetch, an `<img>`. Each one costs a screen or connection slot until the browser drops the blocked reply, and the site can tell that the program is listening.
  - How long a browser keeps such a connection, whether its connection pools let one site reach 32, and whether the browser asks permission before a public site reaches loopback all depend on the browser. I could not test any of it.
- **Fix:** For every method, refuse a request whose `Sec-Fetch-Site` is present and is not `same-origin` or `none`, and one whose `Origin` is present and is not one of the two own origins. A same-origin EventSource and a typed URL still pass.

**6. The door's 64,000-character answer limit is a threshold, not a ceiling.** Ran it.

- **Where:** `door.rs` 140–153: the limit is checked before each part, so the last part done can take the answer past it.
- **Reproduce:** POST `/door` with `world;world;…` (32 times).
- **What happened:** a 67,905-character answer, ending "the last 23 of that line were not done". One part can be as large as the whole state (several MB after 4).
- **Fix:** Stop before a part would take the answer over the limit, or cut the answer at 64,000 characters.

**7. The ring does not check another observer's `why`; only the gate does.** Ran it.

- **Where:** `watch.rs` 347–349: `shaped()` checks `name`, the empty copies and `held`; `rule()` (375–385) checks beat and alive. Nothing checks `why` (or `flagged` on an observer that is not sound).
- **Reproduce:** `spider.ring[*].why = "x"`.
- **What happened:** halt reason "the gate found the legs A observer with a flag up, and no observer had flagged it". The write is found, so by your definition this is not a finding. It does go against the README's "every observer… checks that the others… are in shape".
- **Fix:** In `shaped(j)`, also require `self.ring[j].flagged || self.ring[j].why.is_empty()`.

**8. A `during` line that fails when it runs is still reported as "let through".** Read only.

- **Where:** `watch.rs` 804–811: the result of `door::run` is thrown away, and every queued line goes into `pending`. 775–779 then report it as let through.
- **Reproduce (depends on timing):** `during world.moths[N].x = 100` for the last moth, in the round that moth is caught. At run time the line gets "there are only N moths" and writes nothing, the round is recorded, and the page says "let through: …".
- **Fix:** Put a line into `pending` only if it ran without error and wrote something.

**9. The game thread can die while the server goes on answering.** Read only; I found nothing that triggers it.

- **Where:** `main.rs` 107–110: the `Err` branch (`game.fail`, `game.shown`) runs outside `catch_unwind`. Line 114 uses `playing.shown.lock().unwrap()`.
- **What it means:** a panic there would end the game loop for good. POSTs would still get 200, and screens would be held while waiting.
- **Fix:** Use `unwrap_or_else(into_inner)` for `shown`, put the whole round under `catch_unwind`, and stop the process if the game thread ever ends, so the page's "server is silent" is the truth.

**10. Minor HTTP behaviour.**

- A body over 65,536 bytes is closed with no answer (`main.rs` 223–225). The page shows "the server did not answer". Fix: reply 413.
- The 503 for too many connections is written before the request is read (`main.rs` 141–143), so the client often gets a reset instead (seen in 2).
- README nit: "It comes in three ways" is followed by four bullets.

---

### Looked at and found sound

- **Host check:** it is an exact match against the two names, and anything else gets 403. That blocks DNS rebinding; tried with `Host: evil.test:8181`.
- **Origin on POSTs:** every POST needs an exact own Origin. Missing or `null` gets 403 (tried both), and browsers send Origin on every cross-site POST, form posts included. No GET changes the game.
- **Framing:** `X-Frame-Options: DENY` and `frame-ancestors 'none'` go with every reply, including errors and the stream. CORP `same-origin` and nosniff are on every reply.
- **Page:** there is no `innerHTML`, `document.write`, `eval` or the like. All server text goes in through `textContent` or canvas `fillText`; the cursor and styles come from fixed values.
- **JSON and SSE framing:** `quote()` escapes `"`, `\` and every control character. Numbers that are not real are written as strings and other numbers with `{}`. The 8 MB frame full of U+0001 still parsed as JSON, with no raw newline in a `data:` line.
- **Door parser:**
  - Quotes are handled the same way in `split` and in the write scan.
  - Indexes are checked against the current list lengths, `[*]` works, and kinds are fixed.
  - `NaN`, `inf` and `1e999` are taken and found. Slicing stays on character boundaries.
  - I found no panic in `door::run`, including when a `during` line runs on a state that has moved on. So nothing typed brings about a halt that cannot be put right, which agrees with the README.
- **Gate:** each round that is not halted, `differs()` compares every part's text and every observer field with the record, so every door write was found. Putting right copies every part back and starts all eight observers again from the record. Writes made during a halt were all put back.
- **Endpoints:** `fuzz.js` sent 2,780 odd-order `/down`, `/pointer`, `/up` and `/buy` requests over 150 s: double presses, drags off the edge, presses on legs and on a new spider outside the edge. There were 40 spider deaths and no halt. Non-finite places are refused (`watch.rs` 874, 883).
- **What is asked:** both lists stay bounded (about 130 entries) with the press, buy, release and pointer-run rules, and are pushed identically.
- **Panics:** for the door and the game round, the lock guard lives outside `catch_unwind`, so a panic does not poison the lock. `Shared::game()` recovers a poisoned lock into `Game::fail` and clears the poison once. `fail` leaves a sound halt that cannot be put right, which "Put it right" turns into a new game.
- **Limits:** line (8,192, via `take`), header count (64), body (65,536) and moths at the door (64) are enforced where the README says, and I found no way round them.

### What I could not review

- **Anything in a real browser** (none was available): how a cross-site EventSource or no-cors fetch is cut off and how quickly the slot frees up, whether one site's connection pools can reach 32, permission prompts for loopback, and how the page copes with 3–8 MB frames.
- **The test suite and the folder above:** `cargo test` was not run, as instructed. `test/limits.js`, `test/drive.js` and `test/wiring.py` are not in my copy, and I only skimmed the tests in `watch.rs`.
- **Whether `rules.rs` agrees with `game.rs` for every input:** I fuzzed the endpoints and read both, but did not prove it. This matters more than it looks. The requests of a wrong round are taken in again after the halt, so any request that makes the rules reject a genuine step would fail twice running. That makes a halt that cannot be put right, from the endpoints alone. I found no such input.
- **Windows send timeouts:** whether the 10 s applies to each `send` call or to the whole frame was not tested. A screen that reads slowly keeps its slot either way.
