## Independent security review: One Spider (Rust server, review copy)

**Scope:** `src/main.rs`, `src/door.rs`, `src/watch.rs`, `src/game.rs`, `src/rules.rs` and `page.html` in
`«WORK»\review-outside\`

**Summary:**
- I found no way to get anything into the recorded state that the game's own work did not produce, from the console, the POST endpoints, or both together.
- The serious weaknesses are all availability. Several inputs make the process use memory, threads or CPU without bound, and some of these can kill it. The worst one needs only one console line typed into the page.
- Three writes are not found, but none of them keeps a change.
- The only thing another website can do is clickjacking.

**How it was checked:**
- I built the copy and ran it on 127.0.0.1:8171, and sent requests only there.
- Before stopping it I confirmed which process was mine by its listening port (PID 28236). I stopped it through its background task. Port 8138 (PID 19432) was still listening afterwards, and I never contacted it.
- The probe scripts I used are in `...\review-outside\probe\`: `lib.py`, `t_beat.py`, `t_during.py`, `t_during_obs.py`, `t_amp.py`, `t_grow.py`, `t_hold.py`, `t_header.py`, `t_threads.py`, `t_fuzz.py`.
- Every console request below is a POST to `http://127.0.0.1:8171/door` with the header `Origin: http://127.0.0.1:8171`.

---

## Findings, most serious first

### 1. One console line can produce output about 1,000 to 1,500 times its own size, and it is built while the game is locked
- **Where:**
  - `door.rs:116-117` and `door.rs:120-122`: each `;`-separated part is run and its answer collected. There is no limit on the number of parts or on the size of the answer.
  - `door.rs:407-441`: `world` and `spider` write out every observer's copies in full (`watch.rs:140-142`, `shown(usize::MAX)`).
  - `main.rs:160`: the whole line runs while holding the game lock.
- **Reproduce:** `curl -s -H "Origin: http://127.0.0.1:8171" --data-binary "$(printf 'world;%.0s' $(seq 2000))" http://127.0.0.1:8171/door | wc -c`
- **What happens (run):**
  - A 12,000-byte line returned 12,661,999 bytes (×1,055) in 0.10 s.
  - Adding pushes first makes it worse, because each `world` read then also lists the pushed moths. `"world.moths.push();"*500 + "world;"*500` (12,500 bytes) returned 18,129,899 bytes (×1,450).
- **Extrapolated, not run:**
  - A full 64 KB body of about 1,700 pushes plus 5,400 reads gives about 600 MB of answers. The final `join` doubles that, so roughly 1.2 GB per request.
  - The lock is released before the reply is written, so concurrent requests each hold their own buffer. A handful of them can exhaust memory. Rust then aborts the process, and the game dies.
  - The page's own console is enough to send this. Any local program can send it too.
- **Fix:**
  - Cap the number of statements in one line (for example 64) and refuse the rest.
  - Cap the total answer size (for example 256 KB) while building it, and stop with a "too much to say" message.
  - Optionally, cap a single read of a whole scope.

### 2. A header line or request line of any length is buffered in memory
- **Where:** `main.rs:107` and `main.rs:115`. `read_line` on a `BufReader` grows its `String` until it sees `\n`. There is no limit on line length or on the number of headers. The 64 KB limit (`main.rs:131`) applies only to the body.
- **Reproduce:** open a TCP connection to 8171 and send `GET / HTTP/1.1\r\nHost: 127.0.0.1:8171\r\nX-Long: ` followed by 200 MB of `a` with no newline (`probe\t_header.py 28236 200`).
- **What happens (run):** the server's working set went from 8 MB to 209 MB with the connection still open, and back to 9 MB when it closed. A few such connections at once would exhaust memory and abort the process.
- **Who can do it:** only a local program. A browser cannot send lines this long.
- **Why it counts:** this is a malformed request that kills the process, not an ordinary one.
- **Fix:**
  - Read every line through `reader.by_ref().take(8192)`. If the line does not end in `\n`, answer 431 or 400 and close.
  - Cap the header count (for example 64) and total header bytes (for example 16 KB).

### 3. The moths list grows without limit through the console, and every round's cost grows with it
- **Where:**
  - `door.rs:149-151`: `world.moths.push()` has no cap.
  - `door.rs:95-118`: ordinary console writes are accepted during a halt.
  - `watch.rs:348-381` and `watch.rs:426-463`: each world-ring observer and the gate write out the moths part every round.
  - `watch.rs:855`: `shown()` sends the whole list to every `/stream` reader about 60 times a second.
- **Reproduce:**
  1. POST `/how` with body `on a click`.
  2. POST to `/door` 30 times with `"world.moths.push();"*3400` (`probe\t_grow.py 30`).
  3. POST `/right` to put it right.
- **What happens (run):**
  - The first push is found and halts the game, and pushes keep landing while it is halted: 98,606 moths.
  - The `/stream` rate fell from 59.2 to 1.8 frames a second. Each frame went from about 5.9 KB to 6.0 MB.
  - "Put it right" restored it: 59.4 frames a second, 5.9 KB.
- **Same cause, more cost:** `[*]` writes over the list run under the game lock. With 34,009 moths, a line of 50 `world.moths[*].x = 1;` held the lock for about 0.8 s (`probe\t_hold.py`). A full 64 KB line of them would hold it for tens of seconds (extrapolated).
- **"After a pause" also accumulates:** the halt waits for quiet, and every push resets the wait.
- **The page too (read only):** `learn()`/`layOut()` in `page.html:466-563` build one button per field of every moth. A tab would freeze long before the server failed.
- **The halt does fire, and the put-right does restore.** The problem is only the growth in between, and the possible memory exhaustion before anyone clicks.
- **Fix:**
  - Refuse `push()` above a small fixed bound (for example 64, or 10 + 2·spawn + some room). It is still found, because the rules already reject more than `10 + 2·spawn` (`rules.rs:140`).
  - Bound `[*]` writes per line (see finding 1).
  - In the page, show at most N moths in the state panel.

### 4. One unbounded thread per connection; `thread::spawn` can panic the main thread; stream writers have no timeout
- **Where:**
  - `main.rs:78-81`: a thread is spawned per accepted connection with no limit.
  - `thread::spawn` panics if the OS cannot create a thread. That panic would be in the accept loop on the main thread, which ends the process (read only).
  - `listener.incoming().flatten()` silently drops accept errors. If accept fails repeatedly, the loop spins at full CPU (read only).
  - `main.rs:97`: only a read timeout is set (120 s, per read call). A client that sends one byte every 119 s keeps its thread forever.
  - `main.rs:206-223`: there is no write timeout, so a `/stream` client that never reads keeps its thread blocked in `write_all` indefinitely. Any local program can open as many `/stream` connections as it likes.
- **Reproduce:** `probe\t_threads.py 28236` opens 300 silent connections, then 20 `/stream` connections that never read, then waits 130 s.
- **What happens (run):**
  - Threads went from 2 to 302.
  - After 130 s, past the read timeout, the 20 unread streams still held 22 threads.
  - Closing everything went back to 2.
- **Not run:** I did not drive thread creation to failure. It would load the shared machine.
- **Fix:**
  - Keep an atomic count of live connections and refuse past a limit (for example 32).
  - Use `thread::Builder::spawn` and handle its `Err` by closing the socket.
  - Back off on accept errors.
  - Call `set_write_timeout` on every socket.
  - Allow only a few `/stream` clients (for example 4).
  - Optionally, use a short header-read deadline for the whole request, not per read.

### 5. The page can be framed by another site (clickjacking)
- **Where:** `main.rs:91`. Replies set only `Content-Type`, `Content-Length`, `Cache-Control` and `X-Content-Type-Options`. Confirmed with `curl -D - http://127.0.0.1:8171/`.
- **How it works (read only, not tried in a browser):**
  - Another site can embed `http://localhost:8171/` in an iframe. The `Host` check passes, because the browser sends `localhost:8171`.
  - The framed page's own fetches carry `Origin: http://localhost:8171`, so they are accepted.
  - The outer site cannot script the frame. It can only overlay or disguise it, so that the owner's clicks or typing land on the stop-observer chips, the shop, "Put it right", or the console.
  - It needs the owner to interact. Nothing in the page acts without a user action.
  - This is the only cross-site path I found.
- **Fix:**
  - Send `X-Frame-Options: DENY` and `Content-Security-Policy: frame-ancestors 'none'` with the page.
  - Optionally add a CSP that allows the inline script by hash.
  - Optionally add `Cross-Origin-Resource-Policy: same-origin` on `/stream` and `/plans`.

### 6. Writes to an observer's `beat` are never found
- **Where:** `watch.rs:385-389`. `watch()` overwrites `beat = rounds` for every running observer before any comparison. Nothing checks what `beat` held before.
- **Reproduce:** console line `spider.ring[0].beat = 5; world.ring[2].beat = NaN; spider.ring[*].beat -= 1000` (`probe\t_beat.py`).
- **What happens (run):** the console said "spider.ring[0].beat = 5 / world.ring[2].beat = "NaN" / 4 written". There was no halt (halts stayed 0), and the next read showed a normal value. Nothing is kept, but the write is not found, and that includes a NaN.
- **Fix:** before overwriting, check that each running observer's `beat` equals `rounds - 1`, the value the last round left. If it does not, flag it ("the X observer's signal was changed").

### 7. `during` writes to observer copies or the halted-moths list are not found, and the page says they were recorded
- **Where:** `watch.rs:722-725` runs the `during` lines, then `record_now`. `redone()` (`watch.rs:532-539`) compares only the seven parts, not the observers. `write_record` (`watch.rs:546-557`) then overwrites the copies of every sound observer and `held` of the moths observer.
- **Reproduce:** `during spider.ring[0].copies[0] = 'not the legs'`, then `during world.ring[1].held = '1,2,3'` (`probe\t_during_obs.py`).
- **What happens (run):**
  - Neither halted. `passed` went 0→1→2, and `let` showed each line.
  - The page then says "let through … The work done a second time gave the same, and no rule of the game forbids it" (`page.html:385`), and its comment calls it "recorded all the same". In fact the write was silently overwritten.
  - For comparison, `during spider.ring[1].beat = 7` was found in the next round.
- **Fix:**
  - In `record_now`, before `write_record`, check every observer against what it should hold at that point. Use the same checks as `differs()`, lines 437-457, against the record from before the work. Halt on any difference.
  - At the least, do not report these as recorded.

### 8. A `during` line queued before a halt survives the halt and runs after the put-right
- **Where:** `watch.rs:821-827`. `during()` refuses while halted ("it is not kept"). But `self.inside` is never cleared by `stop_all` (`watch.rs:464-469`), `restore` or `correct`. So a line queued before the halt runs in the first working round after it (`watch.rs:722`).
- **Reproduce:** with the setting "on a click", send `during world.tally.caught += 5`, then on the same connection `spider.body.x += 1`, both before the next round. Then POST `/right` (`probe\t_during.py`).
- **What happens (run):**
  - The first halt was "the legs A observer found the body changed".
  - Right after the put-right came a second halt: "the gate found a step of the work that the rules of the game do not allow: the moths caught…".
  - It was caught, so nothing was kept. But the queued fault outlives the halt it was meant to fall within, and under "on a click" it waits indefinitely.
- **Fix:** clear `inside` in `stop_all`, matching `during()`'s own refusal.

### 9. Any panic would poison the game lock and stop the program piece by piece (hardening)
- **Where:** `main.rs:55, 60, 155, 160, 168, 174, 179, 185, 192, 213, 215`, each `lock().unwrap()`.
- **What would happen:** a panic while the lock is held would poison it. The game thread and every later request would then panic in turn. The page would only say "the server is silent".
- **Did I find a panic?** No. I read every index into state-sized data in `door.rs`, `watch.rs`, `game.rs` and `rules.rs`. I also sent 4,000 random console lines (`probe\t_fuzz.py`) covering odd paths, indices, quotes, NaN/Infinity/1e400, 5,000-character texts, bad UTF-8, nested `during`, push and pop. The process survived, halts 4→50 and restarts 4→50, never stuck.
- **Fix:** turn a panic into a deliberate, visible stop. Wrap `door::run` in `catch_unwind` so a panic becomes a refused line. Have the game thread catch a panic and halt the game with a stated reason, rather than dying with the lock held.

### 10. A per-round limit on queued input drops later presses and releases (minor, local only)
- **Where:** `watch.rs:767`. Each of the two input lists keeps at most 64 entries per round.
- **What happens (read only):** a local program flooding `/pointer` can push the owner's `/up` or `/down` past the limit, and it is silently dropped. A dropped release leaves the spider held and panicking, and it starves faster. The two lists drop the same entries, so the gate does not notice. The README already accepts input from local programs; this is noted only because of the side effect.

---

## Looked at and found sound
- **Host check** (`main.rs:104, 139`): exact match only. A missing header, wrong case, missing port, `[::1]`, a trailing dot, or a list all got 403 (run). DNS rebinding is stopped, because the browser would send the attacker's name.
- **Origin check on every POST** (`main.rs:143, 196`): a missing origin, `null`, another origin, or a trailing slash all got 403 (run). Cross-site form posts, no-preflight fetches and cross-origin redirects (which send `null`) all fail closed.
- **GET endpoints have no effects:** `/`, `/index.html`, `/stream` and `/plans` only read.
- **Other sites cannot read `/stream` or `/plans`:** there is no `Access-Control-Allow-Origin` (run), so an EventSource or fetch from another origin is opaque.
- **`Content-Length`:** a malformed or negative value becomes `usize::MAX` and the connection is dropped. Bodies over 64 KB are refused before allocation. The body read is exact.
- **The stream's JSON:** every text field passes through `quote()` (`door.rs:66-82`), which escapes `"`, `\`, CR, LF, tab and other control characters. That covers the during lines in `let`. Non-real numbers are written as JSON strings (`door.rs:49-56`). Every other unquoted number in `shown()` and `shelf_written` comes from the game's own finite values or from `Val::written`. Nothing can put a newline into an SSE `data:` line.
- **The page never builds markup from what it is sent:** every value goes in through `textContent`, `createElement` or `setAttribute`. The class names it sets come from server constants. It does not read `location` or the URL, so another site cannot make it run console lines.
- **Console parser** (`door.rs`):
  - Every slice is on an ASCII boundary.
  - Indices are checked against the current length each time they are used, including `during` lines run a round later.
  - A field's kind is enforced, and list lengths cannot change except moths.
  - A `[*]` write cannot partly apply, because all its places share one kind.
  - `during during` and `during` followed by nothing are refused.
  - Fuzzed with no failure.
- **Recorded state:** the gate compares the full text of all seven parts with its record, and the observers' every field except `beat` (`watch.rs:426-463`). Number text is shortest-round-trip, so distinct values give distinct text, including `-0`. `quote()` is injective, so text fields cannot imitate one another. The record is written only after the real-numbers check, the rules and the second doing of the work (`watch.rs:508-523`). The second doing uses the same `held` list and the same inputs, both checked equal beforehand. So a `during` change to any part is found (run). A halt always restores every part from the record, which nothing outside can reach, and starts all eight observers again.
- **The rules cannot be made to hang or panic:** `price_of` loops only after the whole-number check and the ≤10000 check (`rules.rs:88-97`), `web_of` only after the level check, and the O(n²) moth checks only after the count check.
- **Network exposure:** it binds 127.0.0.1 only.

## Could not review, and why
- **Behaviour in a real browser** (framing, EventSource's cross-origin rules, connection-pool partitioning, Chrome's local-network permission): I reasoned about these but did not test them. I did not drive a browser.
- **Running to exhaustion:** I did not push memory or thread creation to actual failure (findings 1, 2, 4). The machine is shared and in use. The figures given are measured at a smaller scale and extrapolated where marked.
- **Whether outside input alone can make the work break a rule:** I did not prove that no sequence of `/pointer`, `/down`, `/up` and `/buy` can make the game's own work break a rule from a valid state. I read the press, drag, click and buy paths against `rules.rs` and found none. This matters because what was asked of a failed round is kept and taken in again after the halt (`watch.rs:734-752`). Such an input would fail twice running, leave the game unable to go on, and force a new game.
- **The test suite:** not run, as instructed.
- **The README:** I did not audit its claims beyond reading the section "What is not observed" for context.
- **Physics and game logic:** I read `game.rs` only for panics and for whether its output can be trusted, not for whether the game itself is correct.
