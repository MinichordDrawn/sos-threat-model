//! One Spider, run here.
//!
//! This program runs the game itself: the spider's own work, the ring that watches it, and
//! the gate behind the ring. A page in a browser is only a screen and a pointer. It is sent
//! what to draw, and it sends back where the pointer is and what was typed at the backdoor.
//! Changing the page changes what its owner sees and what is sent in the owner's name, and
//! nothing that is observed.
//!
//! Usage: one-spider [port]        then open the address it prints. The port is 8138 unless
//! another is given. Nothing but the standard library. It listens on this machine only.

mod backdoor;
mod game;
mod rules;
mod watch;

use std::io::{BufRead, BufReader, ErrorKind, Read, Write};
use std::net::{Shutdown, TcpListener, TcpStream};
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::{Arc, Condvar, Mutex, MutexGuard};
use std::thread;
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

const PAGE: &str = include_str!("../page.html");
/// A round of the game is this long, about a sixtieth of a second.
const ROUND: Duration = Duration::from_micros(16_667);
/// What is taken from outside has a size. A line of a request is no longer than this, a
/// request has no more headers than this and carries no more than this, no more connections
/// than this are served at once, and no more screens than this are sent the game. A write
/// that has not gone out in this long is given up. A request is all here this long after
/// its first character, or it is given up, and a connection on which nothing is asked is
/// kept no longer than this. Connections that have been put out and have not yet gone are
/// counted too, and with them there are never more than this. These numbers are this
/// program's own.
const MOST_LINE: usize = 8192;
const MOST_HEADERS: usize = 64;
const MOST_CARRIED: usize = 65536;
const MOST_CONNECTIONS: usize = 32;
const MOST_SCREENS: usize = 8;
const WRITE_WAITS: Duration = Duration::from_secs(10);
const REQUEST_WAITS: Duration = Duration::from_secs(10);
const IDLE_WAITS: Duration = Duration::from_secs(15);
const MOST_HELD: usize = 256;
/// Sent with every answer: nothing is kept, nothing is guessed at, and no other site may
/// put the page in a frame or load anything from here.
const HEADERS: &str = "Cache-Control: no-store\r\nX-Content-Type-Options: nosniff\r\nX-Frame-Options: DENY\r\nContent-Security-Policy: frame-ancestors 'none'\r\nCross-Origin-Resource-Policy: same-origin\r\n";

/// A connection being served: its number, the connection itself, whether what it asked is
/// all here and being answered, whether it is a screen being sent the game, and since when
/// it has been as it is.
struct Served {
    id: u64,
    socket: TcpStream,
    answering: bool,
    screen: bool,
    since: Instant,
}
struct Shared {
    game: Mutex<watch::Game>,
    /// What there is to draw, and the number of the round it is from.
    shown: Mutex<(u64, String)>,
    fresh: Condvar,
    /// The connections being served, and of them the screens being sent the game, oldest first.
    open: Mutex<Vec<Served>>,
    screens: Mutex<Vec<(u64, TcpStream)>>,
    /// How many connections are held in all: those being served, and those that have been
    /// put out and have not yet gone.
    held: AtomicUsize,
}
/// What a lock keeps. If something stopped where it should not have while it had the lock,
/// what it keeps is still taken: none of what is kept this way is the game.
fn kept<T>(lock: &Mutex<T>) -> MutexGuard<'_, T> {
    lock.lock().unwrap_or_else(|broken| broken.into_inner())
}
/// A connection's place among those held, given up when this is let go, however that comes about.
struct Place<'a>(&'a Shared, u64);
impl Drop for Place<'_> {
    fn drop(&mut self) {
        self.0.gone(self.1);
        self.0.held.fetch_sub(1, Ordering::SeqCst);
    }
}
/// The time by the machine's clock, in thousandths of a second. It is asked of the machine each
/// time, and counted from nothing that is kept here: from round to round the game takes from it
/// only how long it has been since it last asked, so it does not matter what the clock counts
/// from, or if it jumps. A game put aside whole after a second stop in the wrong place takes
/// its time and its seed from it, or begins at nought if it cannot be read, and chance at the
/// start is seeded from it.
fn clock() -> f64 {
    // if it cannot be read, that is said by no number: the game then takes a round to be of ordinary length
    SystemTime::now().duration_since(UNIX_EPOCH).map(|since| since.as_secs_f64() * 1000.0).unwrap_or(f64::NAN)
}

impl Shared {
    /// The game, to work on. If the program stopped where it should not have while it had
    /// hold of the game, the game is told: see `watch::Game::stopped`. A line that has just
    /// arrived at the backdoor, and stops as it is run, is caught there, and the game is not told.
    fn game(&self) -> MutexGuard<'_, watch::Game> {
        match self.game.lock() {
            Ok(game) => game,
            Err(broken) => {
                let mut game = broken.into_inner();
                game.stopped("the program stopped where it should not have while it had hold of the game", clock());
                self.game.clear_poison();
                game
            }
        }
    }
    /// A new connection takes a place among those served. If every place is taken, another
    /// gives up its place and is put out: the one that has waited longest with nothing of
    /// its own being answered, or, if every one is being answered, the one that has been
    /// answered longest. A screen is not put out for a connection. So this takes the
    /// newest, unless every place is a screen's.
    fn admit(&self, id: u64, socket: TcpStream) -> bool {
        let mut open = kept(&self.open);
        if open.len() >= MOST_CONNECTIONS {
            let longest = |answering: bool| open.iter().enumerate().filter(|(_, one)| !one.screen && one.answering == answering).min_by_key(|(_, one)| one.since).map(|(k, _)| k);
            match longest(false).or_else(|| longest(true)) {
                Some(k) => {
                    let out = open.remove(k);
                    let _ = out.socket.shutdown(Shutdown::Both);
                }
                None => return false,
            }
        }
        open.push(Served { id, socket, answering: false, screen: false, since: Instant::now() });
        true
    }
    /// Is this connection still one of those served, or has it been put out?
    fn still(&self, id: u64) -> bool {
        kept(&self.open).iter().any(|one| one.id == id)
    }
    /// What a connection asked is all here and is to be answered, or it has been answered
    /// and the connection waits again. Not so if the connection has been put out in the
    /// meantime: then nothing it asked is done.
    fn answering(&self, id: u64, answering: bool) -> bool {
        match kept(&self.open).iter_mut().find(|one| one.id == id) {
            Some(one) => {
                one.answering = answering;
                one.since = Instant::now();
                true
            }
            None => false,
        }
    }
    /// A connection becomes a screen, to be sent the game. If there are as many screens as
    /// there may be, the one that has been sent the game longest is put out for it.
    fn screen(&self, id: u64, socket: TcpStream) -> bool {
        let mut screens = kept(&self.screens);
        while screens.len() >= MOST_SCREENS {
            // It is put out of the connections served as well: a screen that is slow to go must not keep a place there.
            let out = screens.remove(0);
            let _ = out.1.shutdown(Shutdown::Both);
            kept(&self.open).retain(|one| one.id != out.0);
        }
        // Only now, with room made, is this one marked as a screen. So no more places are ever held by screens than there may be screens.
        match kept(&self.open).iter_mut().find(|one| one.id == id) {
            Some(one) => one.screen = true,
            None => return false,
        }
        screens.push((id, socket));
        true
    }
    /// A connection is no longer served.
    fn gone(&self, id: u64) {
        kept(&self.open).retain(|one| one.id != id);
        kept(&self.screens).retain(|one| one.0 != id);
    }
}

fn main() {
    // The one argument is the port. One that is not a port is not guessed at: the program says so and does not start.
    // Nor is anything given after it passed over: one argument is all there is.
    let given: Vec<String> = std::env::args().skip(1).collect();
    let port: u16 = match given.as_slice() {
        [] => 8138,
        [one] => match one.parse() {
            // digits and nothing else, and not 0, which is no port
            Ok(port) if port != 0 && one.bytes().all(|byte| byte.is_ascii_digit()) => port,
            _ => refuse_to_start(&format!("{} is not a port. Usage: one-spider [port]", one)),
        },
        _ => refuse_to_start("One thing can be given, the port. Usage: one-spider [port]"),
    };
    // Each observer's copy of the rule, and the second text of the work, have to be apart in the
    // program as it was built. If they are not, it is not the program it is said to be.
    if !watch::copies_apart() {
        refuse_to_start("In this program as it was built, two copies of something that is written more than once are one function: of the observers' rule, of the work, or of the rules of the game. It does not start.");
    }
    let seed = SystemTime::now().duration_since(UNIX_EPOCH).map(|d| d.as_nanos() as u64).unwrap_or(1);
    let shared = Arc::new(Shared {
        game: Mutex::new(watch::Game::new(0.0, seed)),
        shown: Mutex::new((0, String::new())),
        fresh: Condvar::new(),
        open: Mutex::new(Vec::new()),
        screens: Mutex::new(Vec::new()),
        held: AtomicUsize::new(0),
    });

    // The eight observers are started, each on a thread of its own. If one of them finds that the
    // rounds have stopped, the program stops.
    shared.game().run_apart(watch::Apart::start(rounds_stopped));
    // The game is told what the clock says now, so that its first round is as long as it has been since.
    shared.game().clocked(clock());

    // The game: one round after another, each at the time the machine's clock gives. If this ever comes to
    // an end, the program ends with it: a screen then finds the server silent, and that is so.
    let playing = shared.clone();
    thread::spawn(move || {
        let _ = catch_unwind(AssertUnwindSafe(|| play(&playing)));
        // Saying so must not be able to keep the program from stopping: if the words cannot be written, it stops all the same.
        let _ = catch_unwind(|| {
            let _ = writeln!(std::io::stderr(), "The game cannot be gone on with, and so the program stops.");
        });
        std::process::exit(1);
    });

    let listener = match TcpListener::bind(("127.0.0.1", port)) {
        Ok(listener) => listener,
        Err(why) => {
            eprintln!("port {} cannot be opened: {}", port, why);
            std::process::exit(1);
        }
    };
    println!("One Spider is at http://localhost:{}", port);
    println!("The game runs here. The page is a screen and a pointer. Stop this and the spider dies.");
    let mut last = 0u64;
    for stream in listener.incoming() {
        let mut stream = match stream {
            Ok(stream) => stream,
            Err(_) => {
                thread::sleep(Duration::from_millis(50)); // not round and round at full speed while nothing can be taken
                continue;
            }
        };
        // A connection on which the wait for a write cannot be set is not served: it could be waited on without end.
        if stream.set_write_timeout(Some(WRITE_WAITS)).is_err() {
            continue;
        }
        last += 1;
        let id = last;
        // Too many are held, counting those put out and not yet gone: this one is not taken, and nothing is read from it.
        if shared.held.load(Ordering::SeqCst) >= MOST_HELD {
            answer(&mut stream, 503, "text/plain", "too many are connected");
            continue;
        }
        if !stream.try_clone().map_or(false, |copy| shared.admit(id, copy)) {
            refuse(stream);
            continue;
        }
        shared.held.fetch_add(1, Ordering::SeqCst);
        let serving = shared.clone();
        // If no more threads can be had, the connection is let go. The program goes on.
        let begun = thread::Builder::new().spawn(move || {
            let _place = Place(&serving, id);
            serve(stream, &serving, port, id);
        });
        if begun.is_err() {
            shared.gone(id);
            shared.held.fetch_sub(1, Ordering::SeqCst);
        }
    }
}

/// The program was started with something it does not take. It says so, if it can be said, and
/// ends without starting.
fn refuse_to_start(why: &str) -> ! {
    let _ = catch_unwind(|| {
        let _ = writeln!(std::io::stderr(), "{}", why);
    });
    std::process::exit(2)
}

/// What an observer does when it has heard nothing of the rounds for some seconds: a round
/// has not returned, and nothing can be done with the game. The program stops, so that a
/// screen finds the server silent and not a game that stands still.
fn rounds_stopped(start: u64) {
    // One observer alone does not stop the program. When the rounds have stopped, all eight find
    // it at about the same time, and the second to say so is believed. One that says so by itself
    // has gone wrong: it ends, is found silent, and is replaced with the others, and what it said
    // is not counted against the eight that follow, which are another starting of the observers.
    static FOUND: Mutex<(u64, u32)> = Mutex::new((0, 0));
    {
        let mut found = FOUND.lock().unwrap_or_else(|broken| broken.into_inner());
        if found.0 != start {
            *found = (start, 0);
        }
        found.1 = found.1.saturating_add(1);
        if found.1 < 2 {
            return;
        }
    }
    // It is said once, by the first to come here. The others give it a moment to be said, and no
    // longer: if it cannot be said, the program stops all the same.
    static SAID: std::sync::atomic::AtomicBool = std::sync::atomic::AtomicBool::new(false);
    static HEARD: std::sync::atomic::AtomicBool = std::sync::atomic::AtomicBool::new(false);
    if !SAID.swap(true, Ordering::SeqCst) {
        let _ = catch_unwind(|| {
            let _ = writeln!(std::io::stderr(), "No round of the game has ended for some seconds, and so the program stops.");
        });
        HEARD.store(true, Ordering::SeqCst);
    } else {
        for _ in 0..30 {
            if HEARD.load(Ordering::SeqCst) {
                break;
            }
            thread::sleep(Duration::from_millis(10));
        }
    }
    std::process::exit(1);
}

/// One round of the game after another, without end.
fn play(playing: &Shared) {
    loop {
        let began = Instant::now();
        // The time is read from the clock for each round. How long the round is, the game works out
        // from its own note of when the last one was.
        let now = clock();
        let text = {
            let mut game = playing.game();
            // If the work stops where it should not, that is not the end of the program: it is a halt, and it is said.
            match catch_unwind(AssertUnwindSafe(|| {
                game.round_at(now);
                game.shown(game.time())
            })) {
                Ok(text) => text,
                Err(_) => {
                    // Once, that is a halt like any other, put right from the gate's record. Twice with
                    // no round between that began with nothing halted and was recorded, what was there
                    // is put aside whole. If even that stops
                    // where it should not, this comes to an end, and the program with it.
                    game.stopped("the game's own work stopped where it should not have", now);
                    match catch_unwind(AssertUnwindSafe(|| game.shown(game.time()))) {
                        Ok(text) => text,
                        Err(_) => {
                            game.fail("the game's own work stopped where it should not have", now);
                            game.shown(game.time())
                        }
                    }
                }
            }
        };
        {
            let mut shown = kept(&playing.shown);
            shown.0 += 1;
            shown.1 = text;
        }
        playing.fresh.notify_all();
        thread::sleep(ROUND.saturating_sub(began.elapsed()));
    }
}

/// An answer. Did it go out, and can the connection be gone on with? Only after an answer
/// that all is well: after any other, the connection is closed, and the answer says so.
fn answer(out: &mut TcpStream, code: u16, kind: &str, body: &str) -> bool {
    let what = match code {
        200 => "OK",
        403 => "Forbidden",
        404 => "Not Found",
        408 => "Request Timeout",
        413 => "Content Too Large",
        503 => "Service Unavailable",
        _ => "Bad Request",
    };
    let closing = if code == 200 { "" } else { "Connection: close\r\n" };
    let head = format!("HTTP/1.1 {} {}\r\nContent-Type: {}\r\nContent-Length: {}\r\n{}{}\r\n", code, what, kind, body.len(), closing, HEADERS);
    out.write_all(head.as_bytes()).and_then(|_| out.write_all(body.as_bytes())).and_then(|_| out.flush()).is_ok() && code == 200
}
/// An answer to a connection that is being served. After one that closes the connection,
/// what the other side is still sending is heard out first, so that the answer arrives.
fn reply(out: &mut TcpStream, code: u16, kind: &str, body: &str) -> bool {
    let go_on = answer(out, code, kind, body);
    if code != 200 {
        heard_out(out);
    }
    go_on
}
/// What the other side is still sending is read and let go: for half a second at most, and
/// no more than so much of it. A connection closed with something unread is broken off, and
/// the answer just given is then lost with it. Nothing that is read here is used.
fn heard_out(out: &mut TcpStream) {
    let _ = out.shutdown(Shutdown::Write);
    let (until, mut left, mut some) = (Instant::now() + Duration::from_millis(500), 262_144usize, [0u8; 8192]);
    while left > 0 {
        let wait = until.saturating_duration_since(Instant::now());
        if wait.is_zero() || out.set_read_timeout(Some(wait)).is_err() {
            return;
        }
        match out.read(&mut some) {
            Ok(n) if n > 0 => left = left.saturating_sub(n),
            _ => return,
        }
    }
}
/// A connection that is not taken is told so. What it has sent by then is read first, for
/// a moment, so that the answer is not lost with it.
fn refuse(mut stream: TcpStream) {
    if stream.set_read_timeout(Some(Duration::from_millis(50))).is_ok() {
        let _ = stream.read(&mut [0u8; 4096]);
    }
    answer(&mut stream, 503, "text/plain", "too many are connected");
    let _ = stream.shutdown(Shutdown::Write);
}

/// What came of waiting for the other side to send something more: it did; or the time
/// allowed ran out; or it has gone, or this connection has been put out.
#[derive(PartialEq)]
enum Wait {
    More,
    Late,
    Gone,
}
/// Waits until the other side has sent something more, and says what came of it. After a
/// wait that ran out, nothing more that the connection asks is read.
fn more(reader: &mut BufReader<TcpStream>, shared: &Shared, id: u64, by: Instant) -> Wait {
    loop {
        if !reader.buffer().is_empty() {
            return Wait::More;
        }
        if !shared.still(id) {
            return Wait::Gone;
        }
        let left = by.saturating_duration_since(Instant::now());
        if left.is_zero() {
            return Wait::Late;
        }
        // If the wait cannot be set, the connection is given up: it is not read from without one.
        if reader.get_ref().set_read_timeout(Some(left)).is_err() {
            return Wait::Gone;
        }
        match reader.fill_buf() {
            Ok(got) if got.is_empty() => return Wait::Gone,
            Ok(_) => return if shared.still(id) { Wait::More } else { Wait::Gone },
            Err(why) if why.kind() == ErrorKind::Interrupted => continue,
            // The wait itself ran out. That is what says the time is up: the clock is not asked again.
            Err(why) if matches!(why.kind(), ErrorKind::TimedOut | ErrorKind::WouldBlock) => return if shared.still(id) { Wait::Late } else { Wait::Gone },
            Err(_) => return Wait::Gone,
        }
    }
}
/// Waits for more of a request. If its time runs out, it is told so, and that is the end of it.
fn more_of(reader: &mut BufReader<TcpStream>, out: &mut TcpStream, shared: &Shared, id: u64, by: Instant) -> bool {
    match more(reader, shared, id, by) {
        Wait::More => true,
        Wait::Late => {
            reply(out, 408, "text/plain", "that request took too long to come");
            false
        }
        Wait::Gone => false,
    }
}
/// One line of a request. Nothing if the other side has gone or has not sent it in time,
/// or if what it sent is not text. If the line is longer than a line may be, that is said
/// back, and nothing more is read.
fn line_of(reader: &mut BufReader<TcpStream>, out: &mut TcpStream, shared: &Shared, id: u64, by: Instant) -> Option<String> {
    let mut line: Vec<u8> = Vec::new();
    loop {
        if !more_of(reader, out, shared, id, by) {
            return None;
        }
        let (got, room) = (reader.buffer(), MOST_LINE - line.len());
        let (take, whole) = match got.iter().take(room).position(|&byte| byte == b'\n') {
            Some(at) => (at + 1, true),
            None => (got.len().min(room), false),
        };
        line.extend_from_slice(&got[..take]);
        reader.consume(take);
        if whole {
            return String::from_utf8(line).ok();
        }
        if line.len() >= MOST_LINE {
            reply(out, 400, "text/plain", "a line of that request is too long");
            return None;
        }
    }
}
/// What a request carries, of the length it said. Nothing if the other side has gone or has not sent it in time.
fn carried(reader: &mut BufReader<TcpStream>, out: &mut TcpStream, shared: &Shared, id: u64, by: Instant, length: usize) -> Option<String> {
    let mut body: Vec<u8> = Vec::with_capacity(length);
    while body.len() < length {
        if !more_of(reader, out, shared, id, by) {
            return None;
        }
        let got = reader.buffer();
        let take = got.len().min(length - body.len());
        body.extend_from_slice(&got[..take]);
        reader.consume(take);
    }
    Some(String::from_utf8_lossy(&body).to_string())
}

/// One browser's connection: one request after another until it goes away, or is put out.
fn serve(stream: TcpStream, shared: &Shared, port: u16, id: u64) {
    let _ = stream.set_nodelay(true);
    let mut reader = match stream.try_clone() {
        Ok(copy) => BufReader::new(copy),
        Err(_) => return,
    };
    let mut out = stream;
    let names = [format!("localhost:{}", port), format!("127.0.0.1:{}", port)]; // the only names this answers to
    loop {
        // Between one request and the next the connection waits, and not for long.
        if more(&mut reader, shared, id, Instant::now() + IDLE_WAITS) != Wait::More {
            return;
        }
        // From its first character a request has so long to be all here.
        let by = Instant::now() + REQUEST_WAITS;
        let first = match line_of(&mut reader, &mut out, shared, id, by) {
            Some(first) => first,
            None => return,
        };
        let mut words = first.split_whitespace();
        let (method, target) = (words.next().unwrap_or("").to_string(), words.next().unwrap_or("").to_string());
        let (mut length, mut host, mut origin, mut site, mut headers) = (0usize, String::new(), None::<String>, None::<String>, 0);
        loop {
            let line = match line_of(&mut reader, &mut out, shared, id, by) {
                Some(line) => line,
                None => return,
            };
            let line = line.trim_end();
            if line.is_empty() {
                break;
            }
            headers += 1;
            if headers > MOST_HEADERS {
                reply(&mut out, 400, "text/plain", "that request has too many headers");
                return;
            }
            if let Some((key, value)) = line.split_once(':') {
                match key.trim().to_ascii_lowercase().as_str() {
                    "content-length" => length = value.trim().parse().unwrap_or(usize::MAX),
                    "host" => host = value.trim().to_string(),
                    "origin" => origin = Some(value.trim().to_string()),
                    "sec-fetch-site" => site = Some(value.trim().to_ascii_lowercase()),
                    _ => {}
                }
            }
        }
        if !names.contains(&host) {
            reply(&mut out, 403, "text/plain", "not here");
            return;
        }
        // Only the page this served, or someone at the address bar. A browser says where a
        // request comes from. One that says it comes from another site is refused, whatever
        // it asks. One that would change anything has to say that it comes from the page
        // this served.
        let here = |origin: &str| names.iter().any(|name| origin == format!("http://{}", name));
        let from_here = origin.as_deref().map_or(false, here);
        let from_elsewhere = origin.as_deref().map_or(false, |origin| !here(origin)) || site.as_deref().map_or(false, |site| site != "same-origin" && site != "none");
        if from_elsewhere || (method == "POST" && !from_here) {
            reply(&mut out, 403, "text/plain", "not from here");
            return;
        }
        if length > MOST_CARRIED {
            reply(&mut out, 413, "text/plain", "that request carries too much");
            return;
        }
        let body = match carried(&mut reader, &mut out, shared, id, by, length) {
            Some(body) => body,
            None => return,
        };
        // What was asked is all here. If the connection was put out while it came, nothing of it is done.
        if !shared.answering(id, true) {
            return;
        }
        let sent = match (method.as_str(), target.as_str()) {
            ("GET", "/") | ("GET", "/index.html") => reply(&mut out, 200, "text/html; charset=utf-8", PAGE),
            ("GET", "/stream") => {
                if out.try_clone().map_or(false, |copy| shared.screen(id, copy)) {
                    stream_to(&mut out, shared);
                }
                return;
            }
            ("POST", "/pointer") => {
                let mut parts = body.split(',').map(|p| p.trim());
                let (x, y, inside) = (parts.next().and_then(|p| p.parse::<f64>().ok()), parts.next().and_then(|p| p.parse::<f64>().ok()), parts.next() == Some("1"));
                if let (Some(x), Some(y)) = (x, y) {
                    // when it was asked is the game's own time, not the clock's
                    let mut game = shared.game();
                    let now = game.time();
                    game.point(x, y, inside, now);
                }
                reply(&mut out, 200, "text/plain", "")
            }
            ("POST", "/backdoor") => {
                // If the backdoor stops where it should not on a line, the line is refused. Whatever it had
                // written by then is in the open state, and is found in the next round like any other write.
                let said = {
                    let mut game = shared.game();
                    catch_unwind(AssertUnwindSafe(|| backdoor::run(&mut game, &body))).unwrap_or_else(|_| "that line could not be done: the backdoor stopped where it should not have".to_string())
                };
                reply(&mut out, 200, "text/plain; charset=utf-8", &said)
            }
            // The pointer pressed in the game area: only where. The game decides what it means.
            ("POST", "/down") => {
                let mut parts = body.split(',').map(|p| p.trim().parse::<f64>().ok());
                if let (Some(Some(x)), Some(Some(y))) = (parts.next(), parts.next()) {
                    let mut game = shared.game();
                    let now = game.time();
                    game.press(x, y, now);
                }
                reply(&mut out, 200, "text/plain", "")
            }
            // The pointer let up.
            ("POST", "/up") => {
                shared.game().release();
                reply(&mut out, 200, "text/plain", "")
            }
            // An upgrade asked for at the shop: only its name. The world decides whether it can be paid for.
            ("POST", "/buy") => {
                shared.game().buy(&body);
                reply(&mut out, 200, "text/plain", "")
            }
            // How a halt ends from now on: at once, after a pause, or on a click.
            ("POST", "/how") => match watch::How::named(&body) {
                Some(how) => {
                    shared.game().set_how(how);
                    reply(&mut out, 200, "text/plain", how.name())
                }
                None => reply(&mut out, 400, "text/plain", "at once, after a pause, or on a click"),
            },
            // Asked to put it right.
            ("POST", "/right") => {
                shared.game().put_right();
                reply(&mut out, 200, "text/plain", "")
            }
            ("GET", "/plans") => reply(&mut out, 200, "application/json", &game::plans_written()),
            _ => reply(&mut out, 404, "text/plain", "nothing here"),
        };
        if !sent || !shared.answering(id, false) {
            return;
        }
    }
}

/// What there is to draw, sent to a screen round after round for as long as it listens. A
/// screen that loses this asks for it again a second later: that is said to it first.
fn stream_to(out: &mut TcpStream, shared: &Shared) {
    if out.write_all(format!("HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\n{}\r\nretry: 1000\n\n", HEADERS).as_bytes()).is_err() {
        return;
    }
    let mut seen = 0u64;
    loop {
        let text = {
            let mut shown = kept(&shared.shown);
            while shown.0 == seen {
                shown = shared.fresh.wait_timeout(shown, Duration::from_secs(1)).unwrap_or_else(|broken| broken.into_inner()).0;
            }
            seen = shown.0;
            shown.1.clone()
        };
        if out.write_all(format!("data: {}\n\n", text).as_bytes()).and_then(|_| out.flush()).is_err() {
            return;
        }
    }
}
