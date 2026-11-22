//! The rings, the gate, and one round of the game.
//!
//! Eight observers in two rings that share one member.
//!   The spider's ring: legs A, legs B, body, and the spider's coordinator ("whole").
//!   The world's ring: edge, moths, web, the spider's coordinator again, and the world's coordinator ("page").
//! The state has seven parts: the two sets of legs and the body (the spider, and with its body
//! the body of the spider before it, dead, until this one eats it), then the edge,
//! the moths with the counts and the shop, and the web (the world), and last what the game
//! keeps for itself, which the backdoor does not reach but in an observer's copy of it: the pointer, what has been asked of the
//! game, and chance. The world's ring watches that too. Every observer keeps its own copy of
//! every part of each ring it sits in: the part written out in full, or for the two
//! coordinators only a fingerprint of it. In every round, before anything moves, every
//! observer compares each part of its ring with its own copy, compares its copy with those
//! of the others in the ring, and checks that the others in the ring have signalled, are
//! running and are in shape. So inside a ring every observer checks every part and every
//! other observer: a full mesh. A flag on a sound observer reaches the rest of its ring in
//! the same round, and through the shared coordinator it reaches the other ring. One
//! detection halts everything, and so does the silence of any observer.
//!
//! Each observer looks by a copy of the rule that is its own (`watch/looks.rs`), and in the
//! program each runs on a thread of its own. Every round each running observer is asked to
//! look and answers for itself, and its answer is its signal for the round. It looks first
//! at whether it has been given eight observers and seven parts, and then at its own last
//! signal. One that does not answer in time is silent.
//!
//! The moths observer also halts the moths that are in the web. It keeps a list of them,
//! written after each round's work, and the world does not move a moth that is on it. The
//! others of the world's ring work the list out for themselves and compare.
//!
//! Behind the observers is the gate. The game keeps its own record, which the backdoor does not
//! reach: the state as the game's own work last left it, and so what every observer should
//! be holding. Nothing moves unless the observers have found nothing and everything matches
//! that record. The record holds each part twice, written out and as a copy, and the two
//! must say the same thing. Where they do not, the state and the observers settle which of
//! the two is right.
//!
//! Everything else the gate keeps of its own, the number of the round among it, is held in
//! three places (`Book`). What is read is what two of them agree on, whatever is written is
//! written to all three, and the gate compares the three at the start of every round.
//!
//! What is asked of the game from outside, by the pointer or at the shop, is taken down
//! three times as it arrives. The gate compares the three. The round's work takes in the
//! first of them, and the second doing of the work takes in the second.
//!
//! The gate also does the work of every round a second time, from its own record, by a text of
//! the work that is its own (`game/again.rs`), and holds the work to the rules of the game,
//! which are written twice (`rules.rs`, `rules/again.rs`). After a round's work, and
//! before anything is recorded, the result must be a state the game can be in, and one that a
//! round can make of the state before. If it is not, nothing is recorded, everything halts,
//! and the round is undone.
//!
//! A halt ends in one of three ways, as it is set: at once, in the round the change is
//! found; after the state has been left alone for a pause; or when it is asked for.

use crate::backdoor::{quote, short, Val};
use crate::game::{again, in_web, moth_at, pick, shelf_written, spider_work, stomach, take_in, web_reach, world_work, Ask, Own, Part, Spider, World, LIFE, SETS, SIZE, UPGRADES};
use crate::rules::{self, wrong_in, wrong_step, Asked};
use std::sync::mpsc::{channel, Receiver, RecvTimeoutError, Sender};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

mod looks;

pub const NAMES: [&str; 8] = ["legs A", "legs B", "body", "whole", "edge", "moths", "page", "web"];
pub const PARTS: [&str; 7] = ["first set of legs", "second set of legs", "body", "edge", "moths, counts and shop", "web", "pointer, requests and chance"];
/// The last part: what the game keeps for itself, and the backdoor does not reach.
const OWN: usize = 6;
struct Ring {
    who: &'static [usize],
    parts: &'static [usize],
}
const RINGS: [Ring; 2] = [Ring { who: &[0, 1, 2, 3], parts: &[0, 1, 2] }, Ring { who: &[4, 5, 7, 3, 6], parts: &[3, 4, 5, 6] }];
/// The two coordinators.
const COORD: [usize; 2] = [3, 6];
/// The moths observer, which keeps the list of the moths halted in the web.
const MOTHS: usize = 5;
/// The order of starting again: the coordinators first, the outer before the inner.
const START: [usize; 8] = [6, 3, 0, 1, 2, 4, 5, 7];
/// The observers of each scope, in the order the backdoor lists them. The spider's coordinator is in both.
pub const SPIDER_RING: [usize; 4] = [0, 1, 2, 3];
pub const WORLD_RING: [usize; 5] = [4, 5, 7, 3, 6];
/// How long the state has to be left alone before a change is put right, in thousandths of a second.
const QUIET: f64 = 600.0;
/// Of the lines written during a round's work, no more than this many characters are kept
/// to be said afterwards. Of an observer's name, its list and its reason, no more than this
/// many are sent to a screen. The two numbers are this program's own.
const MOST_TOLD: usize = 200;
const MOST_SHOWN: usize = 160;
/// No list the game holds is looked at by a round with more than this many entries in it,
/// and no text with more than this many bytes. A game has far less of everything, so only
/// something a fault has made is larger. The two numbers are this program's own.
const MOST_HELD: usize = 1024;
const MOST_HELD_TEXT: usize = 1 << 20;
/// Of anything else, no more than this is sent to a screen: characters of a text in a part,
/// and legs, moths, observers, copies of one observer or catches in number. It is far more
/// than a game has of any of them, so only what a fault has made long, or many, is cut. The
/// list of halted moths and what the game says of itself are sent at more length: twenty
/// times this, and four times. This number is this program's own.
const MOST_SENT: usize = 1024;

/// How a halt ends. This is the game's own setting: the backdoor does not reach it.
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum How {
    /// In the round the change is found, so that nothing pauses.
    AtOnce,
    /// Once the state has been left alone for a pause.
    AfterAPause,
    /// When it is asked for.
    OnAClick,
}
impl How {
    pub fn name(self) -> &'static str {
        match self {
            How::AtOnce => "at once",
            How::AfterAPause => "after a pause",
            How::OnAClick => "on a click",
        }
    }
    pub fn named(text: &str) -> Option<How> {
        [How::AtOnce, How::AfterAPause, How::OnAClick].into_iter().find(|how| how.name() == text.trim())
    }
}

fn sees(i: usize, part: usize) -> bool {
    RINGS.iter().any(|r| r.who.contains(&i) && r.parts.contains(&part))
}

/// An observer. `beat` is its signal: the number of the round it last signalled in. `copies`
/// has a place for each part: its copy of the part, or nothing for a part outside its rings.
/// `held` is the list of the moths it has halted, and only the moths observer has any.
/// `flagged` and `why` are its flag and its reason.
#[derive(Clone, Debug)]
pub struct Observer {
    pub name: String,
    pub alive: bool,
    pub beat: f64,
    pub copies: Vec<String>,
    pub held: String,
    pub flagged: bool,
    pub why: String,
}
impl Part for Observer {
    fn fields(&self) -> &'static [&'static str] {
        &["name", "alive", "beat", "held", "flagged", "why"]
    }
    fn get(&self, field: &str) -> Option<Val> {
        match field {
            "name" => Some(Val::Text(self.name.clone())),
            "alive" => Some(Val::Bool(self.alive)),
            "beat" => Some(Val::Num(self.beat)),
            "held" => Some(Val::Text(self.held.clone())),
            "flagged" => Some(Val::Bool(self.flagged)),
            "why" => Some(Val::Text(self.why.clone())),
            _ => None,
        }
    }
    fn set(&mut self, field: &str, to: Val) -> Result<(), String> {
        match (field, to) {
            ("name", Val::Text(t)) => self.name = t,
            ("held", Val::Text(t)) => self.held = t,
            ("why", Val::Text(t)) => self.why = t,
            ("alive", Val::Bool(b)) => self.alive = b,
            ("flagged", Val::Bool(b)) => self.flagged = b,
            ("beat", Val::Num(n)) => self.beat = n,
            ("name", _) | ("held", _) | ("why", _) => return Err(format!("{} holds a text, and that is fixed", field)),
            ("alive", _) | ("flagged", _) => return Err(format!("{} holds true or false, and that is fixed", field)),
            ("beat", _) => return Err("beat holds a number, and that is fixed".into()),
            _ => return Err(format!("there is no {}", field)),
        }
        Ok(())
    }
    fn written(&self) -> String {
        self.shown(usize::MAX, usize::MAX, usize::MAX)
    }
    fn sent(&self, most: usize) -> String {
        self.shown(most, most, most)
    }
}
impl Observer {
    /// The observer written out, with no more than so many of its copies, no more than so much of each copy, and no more than so much of each of its other texts.
    fn shown(&self, count: usize, copy: usize, text: usize) -> String {
        let copies: Vec<String> = self.copies.iter().take(count).map(|c| quote(&short(c, copy))).collect();
        format!(
            "{{\"name\":{},\"alive\":{},\"beat\":{},\"copies\":[{}],\"held\":{},\"flagged\":{},\"why\":{}}}",
            quote(&short(&self.name, text)), self.alive, Val::Num(self.beat).written(), copies.join(","), quote(&short(&self.held, text)), self.flagged, quote(&short(&self.why, text))
        )
    }
}

/// Any part written out: one of the six of the two scopes, or what the game keeps for itself.
fn text_of(spider: &Spider, world: &World, own: &Own, part: usize) -> String {
    if part == OWN { own.written() } else { snap(spider, world, part) }
}
/// One part copied from one place to another: between the state, the gate's record, and the state as it was when a round began.
fn copy_part(p: usize, from: (&Spider, &World, &Own), to: (&mut Spider, &mut World, &mut Own)) {
    match p {
        2 => {
            to.0.body = from.0.body.clone();
            to.0.old = from.0.old.clone();
        }
        3 => to.1.edge = from.1.edge.clone(),
        4 => {
            to.1.tally = from.1.tally.clone();
            to.1.shop = from.1.shop.clone();
            to.1.moths = from.1.moths.clone();
        }
        5 => to.1.web = from.1.web.clone(),
        OWN => *to.2 = from.2.clone(),
        _ => {
            // Where the two do not have the same number of legs, the count is put right with the set.
            if to.0.legs.len() != from.0.legs.len() {
                to.0.legs = from.0.legs.clone();
            }
            for &k in SETS[p].iter() {
                if let (Some(to), Some(from)) = (to.0.legs.get_mut(k), from.0.legs.get(k)) {
                    *to = from.clone();
                }
            }
        }
    }
}
/// A part of the two scopes, written out.
pub fn snap(spider: &Spider, world: &World, part: usize) -> String {
    match part {
        2 => format!("{{\"body\":{},\"old\":{}}}", spider.body.written(), spider.old.written()),
        3 => world.edge.written(),
        4 => format!("{{\"tally\":{},\"shop\":{},\"moths\":[{}]}}", world.tally.written(), world.shop.written(), world.moths.iter().map(|m| m.written()).collect::<Vec<_>>().join(",")),
        5 => world.web.written(),
        // A set of legs is written out with how many legs the spider has in all, so that a leg too many
        // or too few is a change like any other.
        _ => format!("{{\"of\":{},\"legs\":[{}]}}", spider.legs.len(), SETS[part].iter().map(|&k| spider.legs.get(k).map_or_else(|| "null".to_string(), |leg| leg.written())).collect::<Vec<_>>().join(",")),
    }
}
/// A short mark of a text.
pub fn fingerprint(text: &str) -> String {
    let mut h: u32 = 2166136261;
    for byte in text.bytes() {
        h = (h ^ byte as u32).wrapping_mul(16777619);
    }
    h.to_string()
}
/// What an observer holds of a part: a coordinator a fingerprint, anyone else the whole part.
pub fn holds(i: usize, text: &str) -> String {
    if COORD.contains(&i) { fingerprint(text) } else { text.to_string() }
}
fn print_of(i: usize, held: &str) -> String {
    if COORD.contains(&i) { held.to_string() } else { fingerprint(held) }
}
/// An observer's copies, from the texts of all the parts: only the parts of its own rings.
fn copies_for(i: usize, texts: &[String]) -> Vec<String> {
    texts.iter().enumerate().map(|(p, t)| if sees(i, p) { holds(i, t) } else { String::new() }).collect()
}

/// The gate's record: the state as the game's own work last left it. It holds every part
/// twice: written out, and as a copy. The two must always say the same thing. The moths
/// that were in the web then, and the highest number any moth has yet had, are worked out
/// from the copy when they are wanted, and are kept nowhere else.
#[derive(Clone)]
struct Record {
    texts: Vec<String>,
    spider: Spider,
    world: World,
    own: Own,
}
/// What a doing of a round's work makes: every part written out, and every part as it is.
type Made = (Vec<String>, Spider, World, Own);
/// What the two texts of the rules say of one thing: the first, and the second.
type Said = (Option<&'static str>, Option<&'static str>);

/// A text cut down to so many bytes, between two characters.
fn cut_text(text: &mut String, most: usize) {
    if text.len() > most {
        let mut end = most;
        while !text.is_char_boundary(end) {
            end -= 1;
        }
        text.truncate(end);
    }
}
/// A text cut down to the most of one that is looked at.
fn fit_text(text: &mut String) {
    cut_text(text, MOST_HELD_TEXT);
}
/// A text inside a part, cut down to an eighth of that. Written out, a text can be six times
/// as long as it is, and the part it is in, and every copy of that part, must still be within
/// the most.
fn fit_field(text: &mut String) {
    cut_text(text, MOST_HELD_TEXT / 8);
}
/// The lists and the texts of one copy of the state, cut down to the most that is looked at.
fn fit_state(spider: &mut Spider, world: &mut World, own: &mut Own) {
    spider.legs.truncate(MOST_HELD);
    world.moths.truncate(MOST_HELD);
    own.clicks.truncate(MOST_HELD);
    own.buys.truncate(MOST_HELD);
    own.gains.truncate(MOST_HELD);
    fit_field(&mut spider.body.state);
    fit_field(&mut world.web.torn);
}
#[derive(Clone)]
struct Halt {
    why: String,
    quiet: f64,
    last: String,
    asked: bool,
    stuck: bool,
    /// Were there lines waiting to be written during the work when this halt came? They were put aside.
    aside: bool,
    /// What the gate had already put right of its own when this halt began.
    put: Vec<String>,
}

/// What the gate keeps of its own, besides its record: whether everything is halted and why,
/// how a halt ends, what there is to say about the last halt, the counts, what is waiting to
/// be written during the work, what was let through or could not be written, the number of
/// the round, what the machine's clock last said, and the game's own time.
///
/// The game holds it in three places. Whatever is read of it is read from two places that
/// agree, and whatever the gate writes to it is written to all three. So one place that
/// has been changed is never what is read, and at the start of every round the gate
/// compares the three: where one differs from the other two, that is a detection like any
/// other, and it is put right from them.
#[derive(Clone)]
pub struct Book {
    halt: Option<Halt>,
    how: How,
    why: Option<String>,
    fixed: Option<(String, f64)>,
    pub halts: u64,
    pub restarts: u64,
    calm_since: f64,
    spoiled: u8,
    /// What was said at the backdoor to be written during the next round's work.
    inside: Vec<String>,
    /// What was written during the last round's work and recorded: if the next round finds nothing, it has been let through.
    pending: Vec<String>,
    passed: u64,
    /// How many games there have been: one, and one more each time the game was begun again.
    games: u64,
    /// The last of what was let through, for a screen to say: no more than its beginning.
    let_through: Option<String>,
    /// In how many rounds a line kept to be written during the work could not be written
    /// when its time came, and the last such lines, for a screen to say: no more than their beginning.
    unwritten: u64,
    not_written: Option<String>,
    /// What the machine's clock said at the last round, in thousandths of a second. How long a
    /// round is, is how long it has been since by that clock. Nothing else is taken from it.
    at: f64,
    /// The game's own time, in thousandths of a second: each round moves it on by the round's
    /// length. Everything in the game that waits for a time waits for this one.
    time: f64,
    /// The number of the round. Every observer's signal is held to it.
    rounds: f64,
    /// How many times the program has stopped in the wrong place since a round that began with
    /// nothing halted was last recorded.
    stops: u8,
}
/// A state of the game: the spider, the world, and what the game keeps for itself.
type State = (Spider, World, Own);
/// A state written out whole, for comparing one with another: nothing, where there is none.
fn state_text(state: &Option<Box<State>>) -> String {
    match state {
        None => String::new(),
        Some(state) => (0..PARTS.len()).map(|p| text_of(&state.0, &state.1, &state.2, p)).collect::<Vec<_>>().join("\u{0}"),
    }
}
impl Book {
    fn new(now: f64) -> Book {
        Book { halt: None, how: How::AfterAPause, why: None, fixed: None, halts: 0, restarts: 0, calm_since: now, spoiled: 0, inside: Vec::new(), pending: Vec::new(), passed: 0, games: 1, let_through: None, unwritten: 0, not_written: None, at: now, time: now, rounds: 0.0, stops: 0 }
    }
    /// Do two of the three places hold the same? Every field is compared, and a number by
    /// what it is written as in the machine, so that no two different numbers are the same.
    fn same(&self, other: &Book) -> bool {
        let Book { halt, how, why, fixed, halts, restarts, calm_since, spoiled, inside, pending, passed, games, let_through, unwritten, not_written, at, time, rounds, stops } = self;
        let halts_same = match (halt, &other.halt) {
            (None, None) => true,
            (Some(mine), Some(theirs)) => {
                let Halt { why, quiet, last, asked, stuck, aside, put } = mine;
                *why == theirs.why && quiet.to_bits() == theirs.quiet.to_bits() && *last == theirs.last && *asked == theirs.asked && *stuck == theirs.stuck && *aside == theirs.aside && *put == theirs.put
            }
            _ => false,
        };
        let fixed_same = match (fixed, &other.fixed) {
            (None, None) => true,
            (Some(mine), Some(theirs)) => mine.0 == theirs.0 && mine.1.to_bits() == theirs.1.to_bits(),
            _ => false,
        };
        halts_same
            && fixed_same
            && *how == other.how
            && *why == other.why
            && *halts == other.halts
            && *restarts == other.restarts
            && calm_since.to_bits() == other.calm_since.to_bits()
            && *spoiled == other.spoiled
            && *inside == other.inside
            && *pending == other.pending
            && *passed == other.passed
            && *games == other.games
            && *let_through == other.let_through
            && *unwritten == other.unwritten
            && *not_written == other.not_written
            && at.to_bits() == other.at.to_bits()
            && time.to_bits() == other.time.to_bits()
            && rounds.to_bits() == other.rounds.to_bits()
            && *stops == other.stops
    }
}

#[derive(Clone)]
pub struct Game {
    // The two scopes: open to the backdoor.
    pub spider: Spider,
    pub world: World,
    pub ring: Vec<Observer>,
    // The game's own: the backdoor does not reach these.
    record: Record,
    /// What the gate keeps of its own, in three places: see `Book`.
    books: [Book; 3],
    own: Own,
    /// What has been asked of the game since the last round's work, in order, taken down three
    /// times. The round's work takes in the first and its second doing the second. Where one of
    /// the three differs, the two that agree are what was asked.
    asks: Vec<Ask>,
    asks_again: Vec<Ask>,
    asks_third: Vec<Ask>,
    /// The state as it was when a round's work last began. If that round was not recorded,
    /// this is a third place a part can be put right from: see `restore`. It is itself kept
    /// in three places, read from two that agree, and compared at the start of every round.
    before: [Option<Box<State>>; 3],
    /// The eight observers on threads of their own, if they are run that way. Without it they
    /// are run together, in the thread that does the round. The hold on them is kept in three
    /// places, and read from two that agree: see `threads`.
    apart: [Option<Apart>; 3],
    /// For the tests: a fault inside a round, after the gate has compared what is its own and its
    /// counts, and before the observers are asked.
    #[cfg(test)]
    early: Option<fn(&mut Game)>,
    /// For the tests: a fault in the work itself, which goes wrong the same way in every round.
    #[cfg(test)]
    fault: Option<fn(&mut Game)>,
    /// For the tests: a fault at one of four later instants. 0: after the gate has looked, and
    /// before the work begins. 1: after the second doing of the work has been found to agree, and
    /// before the round is recorded. 2: while it is being recorded, after the observers have
    /// taken their copies. 3: after the rules have been asked, and before the work is done a
    /// second time.
    #[cfg(test)]
    late: Option<(u8, fn(&mut Game))>,
    /// For the tests: what the two texts of the rules said, of the gate's own copy (0) or of the
    /// step (1), replaced by something else before the gate heeds it. The two texts say the
    /// same of the same thing, so a test cannot make only one of them refuse the gate's copy.
    #[cfg(test)]
    sway: Option<fn(usize, Said) -> Said>,
}
/// What is read of the gate's own is read from two of its three places that agree.
impl std::ops::Deref for Game {
    type Target = Book;
    fn deref(&self) -> &Book {
        let books = &self.books;
        if books[0].same(&books[1]) || books[0].same(&books[2]) {
            &books[0]
        } else if books[1].same(&books[2]) {
            &books[1]
        } else {
            &books[0] // no two agree: the gate finds that at the start of the next round, and nothing can be put right
        }
    }
}

impl Game {
    /// The gate writes to what it keeps of its own: the same to each of the three places.
    fn keep(&mut self, write: impl Fn(&mut Book)) {
        for book in self.books.iter_mut() {
            write(book);
        }
    }
    /// The gate compares the three places where it keeps what is its own. Where one differs
    /// from the other two, everything halts, and it is put right from them. Where no two
    /// agree, nothing says which is right, and the halt cannot be put right.
    fn settle_books(&mut self, now: f64) {
        let books = &self.books;
        let (ab, ac, bc) = (books[0].same(&books[1]), books[0].same(&books[2]), books[1].same(&books[2]));
        if ab && ac {
            return;
        }
        let right = if ab || ac { Some(0) } else if bc { Some(1) } else { None };
        match right {
            Some(k) => {
                let book = self.books[k].clone();
                self.books = [book.clone(), book.clone(), book];
                if self.halt.is_none() {
                    self.stop_all("the gate found that one of the three places where it keeps what is its own no longer agreed with the other two, and no observer had flagged it".into(), now);
                    self.keep(|book| {
                        if let Some(halt) = book.halt.as_mut() {
                            halt.put.push("what the gate keeps of its own put right from the two places that agreed".into());
                        }
                    });
                }
            }
            None => {
                let book = self.books[0].clone();
                self.books = [book.clone(), book.clone(), book];
                if self.halt.is_none() {
                    self.stop_all("the gate found that the three places where it keeps what is its own no longer agreed".into(), now);
                }
                self.stick("it could not be put right: no two of the three places where the gate keeps what is its own agree".into());
            }
        }
    }
    /// The state as it was when the last round's work began, as two of its three places have it.
    fn began(&self) -> Option<&Box<State>> {
        let texts: Vec<String> = self.before.iter().map(state_text).collect();
        let place = if texts[0] == texts[1] || texts[0] == texts[2] { 0 } else if texts[1] == texts[2] { 1 } else { 0 };
        self.before[place].as_ref()
    }
    /// The gate compares the three places where that state is kept. Where one differs from the
    /// other two, everything halts, and it is put right from them. Where no two agree, nothing
    /// says which is right, and it is no longer kept: the record stands without it.
    fn settle_before(&mut self, now: f64) {
        if self.before.iter().all(|kept| kept.is_none()) {
            return;
        }
        let texts: Vec<String> = self.before.iter().map(state_text).collect();
        let (ab, ac, bc) = (texts[0] == texts[1], texts[0] == texts[2], texts[1] == texts[2]);
        if ab && ac {
            return;
        }
        let right = if ab || ac { Some(0) } else if bc { Some(1) } else { None };
        let (kept, put) = match right {
            Some(place) => (self.before[place].clone(), "the state kept from when the last round's work began put right from the two places that agreed"),
            None => (None, "the state kept from when the last round's work began put aside"),
        };
        self.before = [kept.clone(), kept.clone(), kept];
        if self.halt.is_none() {
            self.stop_all("the gate found that the three places where it keeps the state from when the last round's work began no longer agreed, and no observer had flagged it".into(), now);
            self.keep(|book| {
                if let Some(halt) = book.halt.as_mut() {
                    halt.put.push(put.into());
                }
            });
        }
    }
    /// The game's hold on its observers' threads, as two of its three places have it.
    fn threads(&self) -> Option<Apart> {
        let held = &self.apart;
        if same_hold(&held[0], &held[1]) || same_hold(&held[0], &held[2]) {
            held[0].clone()
        } else if same_hold(&held[1], &held[2]) {
            held[1].clone()
        } else {
            held[0].clone() // no two agree: the gate finds that before the round, and nothing can be put right
        }
    }
    /// What has been asked of the game and not yet taken in, as two of the three lists have it.
    fn asked(&self) -> &Vec<Ask> {
        if self.asks == self.asks_again || self.asks == self.asks_third {
            &self.asks
        } else if self.asks_again == self.asks_third {
            &self.asks_again
        } else {
            &self.asks
        }
    }
    /// The counts that are fixed by how the game is made: seven texts in the gate's record, and
    /// eight observers. A text too many is not one of them, and is not kept. One that is
    /// missing is one that says nothing, which agrees with nothing: it is put right with the
    /// rest of the record. An observer too many is not one of the eight, and is not kept.
    /// Where there are too few, stopped ones are put at the end, under the last names, to make
    /// eight: with one gone from the middle, those after it then stand a place early. That is
    /// enough to go on by until the halt ends, when all eight are replaced. What was wrong
    /// comes back, or nothing.
    fn right_counts(&mut self) -> Option<&'static str> {
        let mut wrong = None;
        if self.ring.len() != NAMES.len() {
            self.ring.truncate(NAMES.len());
            for i in self.ring.len()..NAMES.len() {
                let gone = Observer { name: NAMES[i].into(), alive: false, beat: self.rounds, copies: vec![String::new(); PARTS.len()], held: String::new(), flagged: false, why: String::new() };
                self.ring.push(gone);
            }
            wrong = Some("the gate found that the number of observers had changed, and no observer had flagged it");
        }
        if self.record.texts.len() != PARTS.len() {
            self.record.texts.resize(PARTS.len(), String::new());
            wrong = Some("the gate found that its own record no longer had one text for each part, and no observer had flagged it");
        }
        wrong
    }
    /// The program stopped where it should not have while it had hold of the game: a round, or
    /// something done with the game between two rounds, did not come to its end. Once, and
    /// not in a halt that already cannot be put right, that is a halt like any other. The
    /// counts are put right first, so that nothing done after the stop leans on a wrong one,
    /// and when the halt ends every part goes back to the gate's record, whatever the stop left
    /// half done. If it happens again before a round that began with nothing halted has been
    /// recorded, what is here cannot be trusted, and it is put aside whole: see `fail`.
    /// `clock` is the machine's time, for the game that is then begun. A line that has just
    /// arrived at the backdoor, and stops as it is run, is caught there, and this is not told of it.
    pub fn stopped(&mut self, why: &str, clock: f64) {
        if self.stops > 0 || self.stuck() {
            self.fail(why, clock);
            return;
        }
        let counted = self.right_counts().is_some();
        let now = self.time;
        if self.halt.is_none() {
            self.stop_all(why.to_string(), now);
        }
        self.keep(|book| {
            book.stops = book.stops.saturating_add(1);
            if let Some(halt) = book.halt.as_mut() {
                if counted {
                    halt.put.push("the gate's counts put right".into());
                }
            }
        });
    }
    /// How long a round is that the clock says begins now: how long it has been since the gate's
    /// note of what the clock last said, a twentieth of a second at the most, and never less
    /// than nothing.
    ///
    /// A clock that cannot be read, which comes here as no number, gives a round of the
    /// ordinary length: the rounds are paced, so that is how long it has most likely been.
    fn length(&self, clock: f64) -> f64 {
        if !clock.is_finite() {
            return ROUND_LENGTH;
        }
        ((clock - self.at) / 1000.0).min(0.05).max(0.0)
    }
    /// The program has just started, and this is what the machine's clock says: the first
    /// round is then as long as it has been since, and not as long as a round may be.
    pub fn clocked(&mut self, clock: f64) {
        if clock.is_finite() {
            self.keep(|book| book.at = clock);
        }
    }
    pub fn new(now: f64, seed: u64) -> Self {
        let (spider, world, own) = (Spider::new(now), World::new(), Own::new(now, seed));
        let texts: Vec<String> = (0..PARTS.len()).map(|p| text_of(&spider, &world, &own, p)).collect();
        let mut game = Game {
            record: Record { texts, spider: spider.clone(), world: world.clone(), own: own.clone() },
            spider,
            world,
            ring: Vec::new(),
            books: [Book::new(now), Book::new(now), Book::new(now)],
            own,
            asks: Vec::new(),
            asks_again: Vec::new(),
            asks_third: Vec::new(),
            before: [None, None, None],
            apart: [None, None, None],
            #[cfg(test)]
            early: None,
            #[cfg(test)]
            fault: None,
            #[cfg(test)]
            late: None,
            #[cfg(test)]
            sway: None,
        };
        game.ring = (0..NAMES.len()).map(|i| game.born(i)).collect();
        game
    }
    /// A part as it is now, written out.
    fn text(&self, p: usize) -> String {
        text_of(&self.spider, &self.world, &self.own, p)
    }
    /// The gate's copy of a part, written out.
    fn kept(&self, p: usize) -> String {
        text_of(&self.record.spider, &self.record.world, &self.record.own, p)
    }
    fn texts(&self) -> Vec<String> {
        (0..PARTS.len()).map(|p| self.text(p)).collect()
    }
    /// The list of halted moths an observer should have: for the moths observer, the moths that are in the web as the record has it, and none for anyone else.
    fn held_of(&self, i: usize) -> String {
        if i == MOTHS { in_web(&self.record.world) } else { String::new() }
    }
    /// Does every observer that watches a part hold this text of it?
    fn all_hold(&self, p: usize, text: &str) -> bool {
        (0..self.ring.len()).filter(|&i| sees(i, p)).all(|i| self.ring[i].copies.get(p) == Some(&holds(i, text)))
    }
    /// A new observer, with its copies from the record.
    fn born(&self, i: usize) -> Observer {
        Observer { name: NAMES[i].into(), alive: true, beat: self.rounds, copies: copies_for(i, &self.record.texts), held: self.held_of(i), flagged: false, why: String::new() }
    }
    fn sound(&self, i: usize) -> bool {
        // an observer that is not there is not sound
        self.ring.get(i).map_or(false, |o| o.alive && o.beat == self.rounds)
    }
    /// Is an observer there, sound, and with its flag up?
    fn flagging(&self, i: usize) -> bool {
        self.sound(i) && self.ring.get(i).map_or(false, |o| o.flagged)
    }
    /// The moths the moths observer has halted: none, if that observer is not there. The
    /// work goes through this list for every moth and every click, so no more of it is read
    /// than the numbers of as many moths as a screen is sent, whatever a fault has made of it.
    fn halted_moths(&self) -> String {
        self.ring.get(MOTHS).map_or_else(String::new, |o| {
            let mut end = o.held.len().min(MOST_SENT * 20);
            while !o.held.is_char_boundary(end) {
                end -= 1;
            }
            o.held[..end].to_string()
        })
    }
    pub fn halted(&self) -> bool {
        self.halt.is_some()
    }
    /// Is everything halted in a way that cannot be put right? Then, until it is asked for, no
    /// round and nothing asked of the game does anything to its state. For a stop in the wrong
    /// place there, see `stopped`.
    pub fn stuck(&self) -> bool {
        self.halt.as_ref().map_or(false, |halt| halt.stuck)
    }
    #[cfg(test)]
    pub fn why(&self) -> String {
        self.halt.as_ref().map(|h| h.why.clone()).unwrap_or_default()
    }

    /// What there is for the observers to look at, as it is now. `last` is the number that the
    /// last signal of every running observer should carry.
    fn look(&self, last: f64) -> Look {
        Look { rounds: self.rounds, last, texts: self.texts(), ring: self.ring.clone(), world: self.world.clone() }
    }
    /// The observers look before anything moves. Returns the first thing found wrong.
    ///
    /// Each running observer is asked to look, and answers for itself. Run together, as in the
    /// tests, each is asked in turn in this same thread, and all of them answer. Each on a
    /// thread of its own, as the program runs them, all eight are asked at once and waited
    /// for, a fixed number of short waits. One that has not answered by then has not
    /// signalled: it is silent.
    fn watch(&mut self) -> String {
        let rounds = self.rounds;
        let n = self.ring.len();
        let running: Vec<bool> = self.ring.iter().map(|o| o.alive).collect();
        // What there is to look at is put together before anything is signalled. The last signal
        // of every running observer was the round before this one, and each looks at its own before anything else but how many observers it has been given. An observer that is stopped does nothing, and is not asked. The others will find it.
        let look = self.look(rounds - 1.0);
        let answers: Vec<Option<String>> = match self.threads() {
            None => (0..n).map(|i| if running[i] { Some(look_of(i, &look)) } else { None }).collect(),
            Some(apart) => apart.look(&running, look),
        };
        let mut late: Option<usize> = None;
        for i in 0..n {
            match (&answers[i], running[i]) {
                // An observer's answer is its signal for the round: that it answered is written down
                // as the number of the round, and what it found, if anything, puts its flag up.
                (Some(why), true) => {
                    // an observer that has gone since it was asked has no signal to write down
                    if let Some(o) = self.ring.get_mut(i) {
                        o.beat = rounds;
                        if !why.is_empty() {
                            o.flagged = true;
                            o.why = why.clone();
                        }
                    }
                }
                // It was asked and did not answer in time. It has not signalled: its last signal is
                // still the round before's, and from the next round the others of its ring find that.
                (None, true) => late = late.or(Some(i)),
                _ => {}
            }
        }
        let first = match (0..self.ring.len()).find(|&i| self.flagging(i)) {
            Some(i) => i,
            // No flag is up. If an observer did not answer, that is what was found.
            None => return late.map_or_else(String::new, |i| format!("the {} observer did not answer in time", named(i))),
        };
        let why = match self.ring.get(first) {
            Some(o) if !o.why.is_empty() => short(&o.why, MOST_TOLD),
            _ => format!("the {} observer has a flag up", named(first)),
        };
        // A sound observer's flag reaches the rest of its ring, and through the shared coordinator the other ring.
        for _ in 0..RINGS.len() {
            for ring in RINGS.iter() {
                if !ring.who.iter().any(|&i| self.flagging(i)) {
                    continue;
                }
                for &i in ring.who {
                    if self.sound(i) {
                        if let Some(o) = self.ring.get_mut(i) {
                            if !o.flagged {
                                o.flagged = true;
                                o.why = why.clone();
                            }
                        }
                    }
                }
            }
        }
        why
    }
    /// Is there a flag on a sound observer, or is any observer silent?
    fn respond(&self) -> bool {
        (0..self.ring.len()).any(|i| (self.ring[i].flagged && self.sound(i)) || self.ring[i].beat != self.rounds)
    }
    /// The gate: the first thing that is not as the record has it, or nothing. It looks at
    /// its own record first: what it has written out of each part, and its copy of that
    /// part, must be the same thing.
    fn differs(&self) -> String {
        // one text for each part: a text too many or too few is found here, whenever it came
        if self.record.texts.len() != PARTS.len() {
            return "that its own record no longer had one text for each part".into();
        }
        for p in 0..PARTS.len() {
            if self.record.texts.get(p) != Some(&self.kept(p)) {
                return format!("its own record of the {} no longer agrees with itself", PARTS[p]);
            }
        }
        for p in 0..PARTS.len() {
            if self.record.texts.get(p) != Some(&self.text(p)) {
                return format!("the {} changed", PARTS[p]);
            }
        }
        if let Some(off) = self.observers_off() {
            return off;
        }
        // What was asked of the game is taken down three times, and the three must be the same.
        if self.asks != self.asks_again || self.asks != self.asks_third {
            return "what was asked of the game not the same in the three places it is taken down".into();
        }
        String::new()
    }
    /// Before a round writes out, copies or compares anything the game holds, it is cut down
    /// to a size that can be: every list to `MOST_HELD` entries, and every text to
    /// `MOST_HELD_TEXT` bytes. A game never has that much of anything, so what is cut is
    /// something a fault made, and what is left of it still differs from what should be
    /// there: it is found and put right like any other change. Without this, one list made
    /// long enough would keep a round from ending for so long that the observers took the
    /// rounds to have stopped. It is done at six points of a round: at its start, before the
    /// observers are asked, before the work, before the gate checks the work, before the work is
    /// done a second time, and before the record is written. And when a line arrives at the backdoor: see `cut_down`. At the start
    /// what the gate keeps from the round before is cut first, by `fit_kept`, and the rest
    /// once the round is known not to be in a halt that cannot be put right: in such a halt
    /// nothing else is cut.
    ///
    /// Of what the gate keeps in three places, only that state is cut. A place of the rest
    /// that has grown differs from the other two by its length alone, and is put right from
    /// them.
    ///
    /// This bounds what a round costs wherever something too large is met at one of those
    /// points. It does not reach something that grows in the few steps between a point and the
    /// next reading of it. A list made millions of entries long there is read whole, the round
    /// does not end in time, and the program ends as it does for any round that does not
    /// return. That many entries are that many values changed, and not one: it is outside
    /// what is held.
    fn fit(&mut self) {
        fit_state(&mut self.spider, &mut self.world, &mut self.own);
        fit_state(&mut self.record.spider, &mut self.record.world, &mut self.record.own);
        self.record.texts.truncate(MOST_HELD);
        self.record.texts.iter_mut().for_each(fit_text);
        self.fit_kept();
        self.ring.truncate(MOST_HELD);
        for o in self.ring.iter_mut() {
            o.copies.truncate(MOST_HELD);
            o.copies.iter_mut().for_each(fit_text);
            fit_text(&mut o.name);
            fit_text(&mut o.held);
            fit_text(&mut o.why);
        }
        self.asks.truncate(MOST_HELD);
        self.asks_again.truncate(MOST_HELD);
        self.asks_third.truncate(MOST_HELD);
    }
    /// For the backdoor: what a line may read or copy is cut down to a size first. Not in a
    /// halt that cannot be put right, where a line at the backdoor leaves the game as it is.
    pub fn cut_down(&mut self) {
        if !self.stuck() {
            self.fit();
        }
    }
    /// The state kept from when the last round's work began, cut down in each of its three
    /// places to a size that can be looked at: see `fit`. The gate compares the three at the
    /// start of every round, in every kind of halt, so this is done before that.
    fn fit_kept(&mut self) {
        for kept in self.before.iter_mut().flatten() {
            let state: &mut State = &mut **kept;
            fit_state(&mut state.0, &mut state.1, &mut state.2);
        }
    }
    /// A count that is fixed by how the game is made, and is not what it should be: what the
    /// gate found. Or nothing. See `right_counts`.
    fn counts_off(&self) -> Option<&'static str> {
        if self.ring.len() != NAMES.len() {
            return Some("that the number of observers had changed");
        }
        if self.record.texts.len() != PARTS.len() {
            return Some("that its own record no longer had one text for each part");
        }
        None
    }
    /// The first observer that is not as the gate's record says it should be, or nothing.
    fn observers_off(&self) -> Option<String> {
        // There are eight, and the record they are held to has a text for each part: the gate
        // counts before it looks at each. With a text gone, every observer's copies would differ
        // from the record, and it is the record that changed.
        if let Some(what) = self.counts_off() {
            return Some(what.into());
        }
        for (i, o) in self.ring.iter().enumerate() {
            let who = format!("the {} observer", NAMES[i]);
            if o.name != NAMES[i] {
                return Some(format!("{} changed", who));
            }
            if !o.alive {
                return Some(format!("{} stopped", who));
            }
            if o.beat != self.rounds {
                return Some(format!("{} silent", who));
            }
            if o.copies != copies_for(i, &self.record.texts) {
                // where the record's texts no longer say what its copy says, it is the record that changed
                if (0..PARTS.len()).any(|p| self.record.texts[p] != self.kept(p)) {
                    return Some("that its own record had changed".into());
                }
                return Some(format!("the copies of {} changed", who));
            }
            if o.held != self.held_of(i) {
                return Some(format!("the list of halted moths of {} changed", who));
            }
            if o.flagged || !o.why.is_empty() {
                return Some(format!("{} with a flag up", who));
            }
        }
        None
    }
    fn stop_all(&mut self, why: String, now: f64) {
        // While everything is halted there is no work for a line to be written during. What was waiting is not kept.
        let aside = !self.inside.is_empty();
        self.keep(|book| {
            book.halts = book.halts.saturating_add(1);
            book.calm_since = now;
            book.why = Some(why.clone());
            book.inside.clear();
            book.halt = Some(Halt { why: why.clone(), quiet: now, last: String::new(), asked: false, stuck: false, aside, put: Vec::new() });
        });
    }
    /// The game is put aside whole. This is done when the program has stopped where it should
    /// not have a second time with no round between that began with nothing halted and was
    /// recorded, or once while the game was
    /// already in a halt that cannot be put right, or when what a screen is sent could not be
    /// written out after a stop: see `stopped`. What is here cannot then be trusted, and is not
    /// gone on with or looked at again. What stands in its place is a game not yet begun,
    /// halted in a way that cannot be put right: when that is asked for, the game is begun.
    pub fn fail(&mut self, why: &str, now: f64) {
        // if the clock could not be read, the game that waits to be begun begins at nought
        let now = if now.is_finite() { now } else { 0.0 };
        let (how, games, halts, restarts) = (self.how, self.games, self.halts, self.restarts);
        let mut game = Game::new(now, now.to_bits() ^ 0x9E37_79B9_7F4A_7C15);
        game.apart = self.apart.clone();
        game.keep(|book| {
            book.how = how;
            book.games = games;
            book.halts = halts.saturating_add(1);
            book.restarts = restarts;
            book.why = Some(why.to_string());
            book.halt = Some(Halt { why: why.to_string(), quiet: now, last: String::new(), asked: false, stuck: true, aside: false, put: Vec::new() });
        });
        *self = game;
    }
    /// A halt that cannot be put right. It ends only by the game being begun again, and that
    /// has to be asked for after this: what was asked of the halt before it came to this was
    /// asked for something else, and is not kept.
    fn stick(&mut self, why: String) {
        self.keep(|book| {
            book.why = Some(why.clone());
            if let Some(halt) = book.halt.as_mut() {
                halt.stuck = true;
                halt.asked = false;
                halt.why = why.clone();
            }
        });
    }
    /// Is every number in the state a real one? If a part has one that is not, the name of that part.
    fn unfit(&self) -> Option<&'static str> {
        if !self.spider.body.fit() || !self.spider.old.fit() {
            return Some(PARTS[2]);
        }
        if let Some(k) = self.spider.legs.iter().position(|leg| !leg.fit()) {
            return Some(PARTS[if SETS[0].contains(&k) { 0 } else { 1 }]);
        }
        if !self.world.edge.fit() {
            return Some(PARTS[3]);
        }
        if !self.world.tally.fit() || !self.world.shop.fit() || self.world.moths.iter().any(|m| !m.fit()) {
            return Some(PARTS[4]);
        }
        if !self.world.web.fit() {
            return Some(PARTS[5]);
        }
        if !self.own.fit() {
            return Some(PARTS[OWN]);
        }
        None
    }
    /// After the work of a round, the result is recorded, by the gate and by every sound
    /// observer, if it can be: every number in it a real one, a state the game can be in, and
    /// a step the rules of the game allow from the state recorded before. If it is not,
    /// nothing is recorded, and what is wrong comes back. `step` is what was asked of the
    /// round's work, how long the round was, and the time.
    fn record_now(&mut self, step: (&Asked, f64, f64)) -> Option<String> {
        // What has grown since the gate looked is cut down before the work is checked: see `fit`.
        self.fit();
        // The counts first: one that has gone wrong since the gate looked would be taken below for
        // a wrong step of the work.
        if let Some(what) = self.counts_off() {
            return Some(format!("the gate found {} while the round was being worked", what));
        }
        if let Some(part) = self.unfit() {
            return Some(format!("the work left the {} in a state that cannot be recorded", part));
        }
        let (asked, dt, now) = step;
        // The gate's own copy of the round before has to be a state the game can be in, or nothing can be held to it.
        // Both texts of the rules are asked, here and below, and what either refuses is refused.
        let copy: Said = (wrong_in(&self.record.spider, &self.record.world), rules::again::wrong_in(&self.record.spider, &self.record.world));
        #[cfg(test)]
        let copy = self.sway.map_or(copy, |sway| sway(0, copy));
        if let Some(what) = copy.0.or(copy.1) {
            return Some(format!("the gate found that its own copy of the round before is not a state the game can be in: {}", what));
        }
        let said: Said = self.ruled(asked, dt, now);
        #[cfg(test)]
        let said = self.sway.map_or(said, |sway| sway(1, said));
        if let Some(what) = said.0.or(said.1) {
            return Some(format!("the gate found a step of the work that the rules of the game do not allow: {}", what));
        }
        #[cfg(test)]
        if let Some((3, fault)) = self.late {
            fault(self);
        }
        // Once more before the work is done a second time: the second doing looks every moth of the
        // gate's copy up among the halted ones, which is slow in a way the first doing is not.
        self.fit();
        let made = match self.redone(dt, now) {
            Ok(made) => made,
            Err(what) => return Some(format!("the gate did the work of the round a second time, from its own record, and it came out another way in {}", what)),
        };
        // The observers have no part in the work. Each must still be as the gate saw it before the work began.
        if let Some(what) = self.observers_off() {
            return Some(format!("the gate found {} while the round was being worked", what));
        }
        #[cfg(test)]
        if let Some((1, fault)) = self.late {
            fault(self);
        }
        // once more before the record is written, which writes every part out
        self.fit();
        self.write_record(made);
        None
    }
    /// What each of the two texts of the rules says of the round's result: the first, and the
    /// second. The first is asked with what the round's work was asked and with the halted
    /// moths as the first text of the work has them. The second is handed nothing of that: it
    /// is asked with what the second text of the work makes of the second list of what was
    /// asked, from the gate's record, and with the halted moths as that text has them. Both
    /// are asked about the one result, the state as the round's work left it.
    fn ruled(&self, asked: &Asked, dt: f64, now: f64) -> (Option<&'static str>, Option<&'static str>) {
        let first = wrong_in(&self.spider, &self.world)
            .or_else(|| wrong_step((&self.record.spider, &self.record.world), &in_web(&self.record.world), self.record.own.next_id, (&self.spider, &self.world), asked, dt, now));
        let mut own = self.record.own.clone();
        again::take_in(&mut own, &self.record.spider, &self.asks_again);
        let asked = Asked { buys: own.buys.clone(), clicks: own.clicks.len(), next_moth: own.next_moth, held: again::in_hand(&own) };
        let second = rules::again::wrong_in(&self.spider, &self.world)
            .or_else(|| rules::again::wrong_step((&self.record.spider, &self.record.world), &again::in_web(&self.record.world), self.record.own.next_id, (&self.spider, &self.world), &asked, dt, now));
        (first, second)
    }
    /// The work of the round done a second time. It starts from the gate's own record of the
    /// round before, and takes in the second of the three places where what was asked of the
    /// game is taken down. It is the same work, and so it must give the same result in every
    /// part. If what is there now is that result, what the second doing made comes back: every
    /// part of it, written out and as it is. If it is not, what differs comes back.
    ///
    /// Anything that changed the state during the round, other than the work, is found this
    /// way, whether or not it breaks a rule. A mistake in the work itself is not: the work
    /// makes it both times. That is what the rules are for.
    fn redone(&self, dt: f64, now: f64) -> Result<Made, String> {
        let (mut spider, mut world, mut own) = (self.record.spider.clone(), self.record.world.clone(), self.record.own.clone());
        // the second doing is done by its own text of the work
        again::take_in(&mut own, &spider, &self.asks_again);
        again::world_work(&mut world, &spider, &again::in_web(&self.record.world), &mut own, dt, now);
        again::spider_work(&mut spider, &world, &mut own, dt, now);
        let texts: Vec<String> = (0..PARTS.len()).map(|p| text_of(&spider, &world, &own, p)).collect();
        let parts: Vec<String> = (0..PARTS.len()).filter(|&p| texts[p] != self.text(p)).map(|p| format!("the {}", PARTS[p])).collect();
        if parts.is_empty() { Ok((texts, spider, world, own)) } else { Err(parts.join(", ")) }
    }
    /// For the tests: a state set up by hand is recorded as if the work had left it. It has to be a state the game can be in.
    #[cfg(test)]
    fn settle(&mut self) {
        assert_eq!((self.unfit(), wrong_in(&self.spider, &self.world)), (None, None));
        let made = (self.texts(), self.spider.clone(), self.world.clone(), self.own.clone());
        self.write_record(made);
    }
    /// The round is recorded. The gate's record is what its own second doing of the work
    /// made, which has just been found to be what is there. Nothing of the record is read
    /// from the state again: a change to the state after the two were compared is not
    /// recorded, and is found in the next round. Each sound observer takes its copies from
    /// the state itself, so the record and the observers come from the two doings, one each.
    fn write_record(&mut self, made: Made) {
        let (seen, held) = (self.texts(), in_web(&self.world));
        for i in 0..self.ring.len() {
            if self.sound(i) {
                self.ring[i].copies = copies_for(i, &seen);
            }
        }
        if self.sound(MOTHS) {
            if let Some(moths) = self.ring.get_mut(MOTHS) {
                moths.held = held; // the moths observer halts the moths that are now in the web
            }
        }
        #[cfg(test)]
        if let Some((2, fault)) = self.late {
            fault(self);
        }
        let (texts, spider, world, own) = made;
        self.record = Record { texts, spider, world, own };
        // What was asked has been taken in, by the work and by its second doing, and the round that
        // took it in is now recorded. It is emptied here, with nothing between that could stop.
        self.asks.clear();
        self.asks_again.clear();
        self.asks_third.clear();
    }
    /// Putting it right. Every part is put right (see `restore`). Then every observer is
    /// started again: eight new ones in place of the old, the coordinators first, each with
    /// its copies from the record. Nothing an old observer held is carried over. Then the
    /// gate and every new observer look once more, and only if none of them finds anything
    /// is the halt ended. If any does, this cannot be put right.
    fn correct(&mut self, now: f64) {
        let restored = match self.restore() {
            Ok(done) => done,
            Err(why) => {
                self.stick(format!("it could not be put right: {}", why));
                return;
            }
        };
        let mut done = restored.clone();
        // what the gate had already put right of its own when the halt began comes first, and a count
        // that was put right then and again now is said once
        if let Some(halt) = &self.halt {
            let counts = "the gate's counts put right";
            if halt.put.iter().any(|put| put == counts) {
                done.retain(|did| did != counts);
            }
            done.splice(0..0, halt.put.clone());
        }
        if self.halt.as_ref().map_or(false, |halt| halt.aside) {
            done.push("what was waiting to be written during the work put aside".into());
        }
        let mut ring = self.ring.clone();
        for &i in START.iter() {
            ring[i] = self.born(i);
        }
        self.ring = ring;
        // Where each observer is on a thread of its own, the eight new observers are eight new threads.
        if let Some(apart) = self.threads() {
            apart.again();
        }
        done.push("all eight observers started again".into());
        // Every new observer looks once more, each for itself: on its own thread, where they are run
        // that way. One that does not answer has not looked. Then the halt is not ended, and
        // everything is put right again with eight more: in the next round, or after the pause where
        // halts end after one and this try put a part of the state back.
        let look = self.look(self.rounds);
        let answers: Vec<Option<String>> = match self.threads() {
            None => (0..self.ring.len()).map(|i| Some(look_of(i, &look))).collect(),
            Some(apart) => apart.look(&vec![true; self.ring.len()], look),
        };
        if answers.iter().any(|answer| answer.is_none()) {
            // what was put back at this try is kept, to be said when the halt does end
            self.keep(|book| {
                if let Some(halt) = book.halt.as_mut() {
                    halt.put.extend(restored.iter().cloned());
                }
            });
            return;
        }
        self.keep(|book| book.restarts = book.restarts.saturating_add(1));
        let found = answers.into_iter().flatten().find(|why| !why.is_empty());
        let off = self.differs();
        if let Some(why) = found.or(if off.is_empty() { None } else { Some(off) }) {
            self.stick(format!("it could not be put right: {}", why));
            return;
        }
        let did = done.join(", ");
        self.keep(|book| {
            book.halt = None;
            book.fixed = Some((did.clone(), now + 5000.0));
        });
    }
    /// Every part is put right, and what was done is said. Or, if a part cannot be put right, why.
    ///
    /// Where the gate's record of a part agrees with itself, the record is what counts: a part
    /// of the state that differs from it is put back to it, whatever the observers hold.
    /// Where the record does not agree with itself, because what it has written out of the
    /// part says one thing and its copy of the part says another, the state and the observers
    /// settle which of the two is right. If the state and every observer of that part hold to
    /// one of them, the other is put right from the state. If the state has moved on in a
    /// round that was not recorded, the state as it was when that round began stands in for
    /// it, whichever half it holds to. If none of this settles it, nothing can be put right,
    /// and nothing of the part is changed.
    ///
    /// What was asked of the game is taken down in three places. If one differs, it is put
    /// right from the two that agree. If no two agree, it is put aside: there is nothing to
    /// say what was asked, and so none is taken. A letting go may have been among it, so the
    /// pointer is made to let go.
    fn restore(&mut self) -> Result<Vec<String>, String> {
        let mut done: Vec<String> = Vec::new();
        // the counts first: what follows goes through the record's texts and the observers one by one
        if self.right_counts().is_some() {
            done.push("the gate's counts put right".into());
        }
        let before = self.began().cloned();
        for p in 0..PARTS.len() {
            let (is, text, kept) = (self.text(p), self.record.texts[p].clone(), self.kept(p));
            if text == kept {
                if is != text {
                    copy_part(p, (&self.record.spider, &self.record.world, &self.record.own), (&mut self.spider, &mut self.world, &mut self.own));
                    done.push(format!("the {} put back", PARTS[p]));
                }
                continue;
            }
            // what the part was when the last round's work began, written out
            let began = before.as_ref().map(|b| text_of(&b.0, &b.1, &b.2, p));
            let (began, began_kept) = (began.as_ref() == Some(&text), began.as_ref() == Some(&kept));
            if is == text && self.all_hold(p, &text) {
                copy_part(p, (&self.spider, &self.world, &self.own), (&mut self.record.spider, &mut self.record.world, &mut self.record.own));
            } else if is == kept && self.all_hold(p, &kept) {
                self.record.texts[p] = kept;
            } else if began && self.all_hold(p, &text) {
                // The state has moved on, in a round that was not recorded, and the gate's copy
                // of the part is the half that went wrong. What the part was when that round's
                // work began is still held. It is what the gate wrote out and what every observer
                // holds, so the state and the gate's copy both go back to it.
                if let Some(b) = before.as_ref() {
                    copy_part(p, (&b.0, &b.1, &b.2), (&mut self.spider, &mut self.world, &mut self.own));
                    copy_part(p, (&b.0, &b.1, &b.2), (&mut self.record.spider, &mut self.record.world, &mut self.record.own));
                }
                done.push(format!("the {} put back", PARTS[p]));
            } else if began_kept && self.all_hold(p, &kept) {
                // The same, the other way about: the state has moved on in a round that was not
                // recorded, and what the gate wrote out of the part is the half that went wrong.
                // What the part was when that round's work began is what the gate's copy says and
                // what every observer holds. So what is written out is put right from the copy,
                // and the state goes back to it.
                self.record.texts[p] = kept;
                copy_part(p, (&self.record.spider, &self.record.world, &self.record.own), (&mut self.spider, &mut self.world, &mut self.own));
                done.push(format!("the {} put back", PARTS[p]));
            } else {
                return Err(format!("the gate's record of the {} does not agree with itself, and the state and the observers do not settle which of the two is right", PARTS[p]));
            }
            done.push(format!("the gate's record of the {} put right", PARTS[p]));
        }
        let (ab, ac, bc) = (self.asks == self.asks_again, self.asks == self.asks_third, self.asks_again == self.asks_third);
        if !(ab && ac) {
            if ab || ac || bc {
                // One of the three lists has gone wrong. The two that agree are what was asked, and nothing of it is lost.
                let right = self.asked().clone();
                self.asks = right.clone();
                self.asks_again = right.clone();
                self.asks_third = right;
                done.push("what was asked of the game put right from the two places that agreed".into());
            } else {
                // No two agree, and nothing says what was asked: none is taken. A letting go may have
                // been among it. The pointer is made to let go: that is the side to err on.
                self.asks = vec![Ask::Release];
                self.asks_again = vec![Ask::Release];
                self.asks_third = vec![Ask::Release];
                done.push("what was asked of the game put aside, and the pointer made to let go".into());
            }
        }
        Ok(done)
    }
    /// A halt ends as it is set to: at once, after the state has been left alone for a
    /// pause, or when it has been asked for. Asking ends it under any setting.
    fn mend(&mut self, now: f64) {
        let (stuck, asked, quiet) = match &self.halt {
            Some(halt) => (halt.stuck, halt.asked, halt.quiet),
            None => return,
        };
        if stuck {
            return;
        }
        if !asked {
            match self.how {
                How::AtOnce => {}
                How::AfterAPause => {
                    let seen = self.texts().concat();
                    let (quiet, changed) = if self.halt.as_ref().map_or(false, |halt| halt.last != seen) { (now, true) } else { (quiet, false) };
                    if changed {
                        // while it is still being changed, wait
                        self.keep(|book| {
                            if let Some(halt) = book.halt.as_mut() {
                                halt.last = seen.clone();
                                halt.quiet = now;
                            }
                        });
                    }
                    if now - quiet < QUIET {
                        return;
                    }
                }
                How::OnAClick => return,
            }
        }
        self.correct(now);
    }

    /// One round, at the time it is now. How long the round is, is how long it has been since
    /// the last one, by the gate's own note of when that was: no longer than a twentieth of a
    /// second, and never less than nothing. If the clock cannot be read, the round is of the
    /// ordinary length. So the length of a round rests on nothing that is
    /// held in one place only.
    ///
    /// The game's own time moves on by that length, and that is the time the round is worked
    /// at. So the machine's clock decides how long one round is, and nothing else: a clock
    /// that jumps, or a machine that has stood still, moves the game on by one round.
    pub fn round_at(&mut self, clock: f64) {
        let time = self.time;
        self.settle_books(time);
        let dt = self.length(clock);
        // a clock that could not be read leaves the note of the last reading as it is
        if clock.is_finite() {
            self.keep(|book| book.at = clock);
        }
        let now = self.time + dt * 1000.0;
        self.turn(dt, now);
    }
    /// The game's own time.
    pub fn time(&self) -> f64 {
        self.time
    }
    /// One round of a given length at a given time, as the tests ask for it: the time given is
    /// then the game's own and the clock's both.
    #[cfg(test)]
    pub fn round(&mut self, dt: f64, now: f64) {
        self.settle_books(now);
        self.keep(|book| book.at = now);
        self.turn(dt, now);
    }
    /// One round. The observers look and the gate checks. Then the world and the spider do
    /// their work and the result is recorded. Or everything halts.
    fn turn(&mut self, dt: f64, now: f64) {
        // Before anything else, what the gate keeps from the round before is cut down to a size that
        // can be looked at: see `fit`.
        self.fit_kept();
        // Then the gate compares the three places where it keeps what is its own.
        self.settle_books(now);
        self.settle_before(now);
        self.keep(|book| book.time = now);
        // A halt that cannot be put right ends only when it is asked for, and then by the game being
        // begun again. Until then this round leaves the game's state as it is: it is not worked, and no observer looks at it.
        if let Some(halt) = &self.halt {
            if halt.stuck {
                if halt.asked {
                    self.begin_again(now);
                }
                // No observer is asked to look. The observers are still told that the rounds go on.
                if let Some(apart) = self.threads() {
                    apart.tick();
                }
                return;
            }
        }
        // From here on the state, the record and the observers are looked at, and so they are cut
        // down to a size that can be.
        self.fit();
        // The gate has written out each of the seven parts, and there are eight observers: see `right_counts`.
        if let Some(wrong) = self.right_counts() {
            if self.halt.is_none() {
                self.stop_all(wrong.into(), now);
            }
            // that it was put right is said with what else is done when the halt ends
            self.keep(|book| {
                if let Some(halt) = book.halt.as_mut() {
                    // said once in a halt, however often it has to be done in it
                    if !halt.put.iter().any(|put| put == "the gate's counts put right") {
                        halt.put.push("the gate's counts put right".into());
                    }
                }
            });
        }
        // The game's hold on its observers' threads is in three places, and compared the same way.
        let (ab, ac, bc) = (same_hold(&self.apart[0], &self.apart[1]), same_hold(&self.apart[0], &self.apart[2]), same_hold(&self.apart[1], &self.apart[2]));
        if !(ab && ac) {
            let settled = ab || ac || bc;
            let right = self.threads();
            self.apart = [right.clone(), right.clone(), right];
            if self.halt.is_none() {
                self.stop_all("the gate found that one of the three places that hold the observers' threads no longer agreed with the other two, and no observer had flagged it".into(), now);
                if settled {
                    self.keep(|book| {
                        if let Some(halt) = book.halt.as_mut() {
                            halt.put.push("the hold on the observers' threads put right from the two places that agreed".into());
                        }
                    });
                }
            }
            if !settled {
                self.stick("it could not be put right: no two of the three places that hold the observers' threads agree".into());
                return;
            }
        }
        // What the observers' threads are run by is held in three places too, and compared the same way.
        if let Some(apart) = self.threads() {
            if let Some(settled) = apart.settle() {
                if self.halt.is_none() {
                    self.stop_all("the gate found that one of the three places that hold what the observers' threads are run by no longer agreed with the other two, and no observer had flagged it".into(), now);
                    if settled {
                        self.keep(|book| {
                            if let Some(halt) = book.halt.as_mut() {
                                halt.put.push("what the observers' threads are run by put right from the two places that agreed".into());
                            }
                        });
                    }
                }
                if !settled {
                    self.stick("it could not be put right: no two of the three places that hold what the observers' threads are run by agree".into());
                    return;
                }
            }
        }
        #[cfg(test)]
        if let Some(fault) = self.early.take() {
            fault(self);
        }
        let began_halted = self.halt.is_some();
        // The round is numbered, in each of the three places where its number is kept.
        self.keep(|book| book.rounds += 1.0);
        // cut down again, for anything that has grown since the start of the round
        self.fit();
        let why = self.watch();
        let stop = self.respond();
        if self.halt.is_none() {
            let off = self.differs();
            if stop || !off.is_empty() {
                let reason = if !stop {
                    format!("the gate found {}, and no observer had flagged it", off)
                } else if why.is_empty() {
                    "an observer is silent".to_string()
                } else {
                    why
                };
                self.stop_all(reason, now);
            }
        }
        // What was written during the last round's work, and recorded: if nothing has found it now, it has been let through.
        if !self.pending.is_empty() {
            if self.halt.is_none() {
                let told = short(&self.pending.join("; "), MOST_TOLD);
                self.keep(|book| {
                    book.passed = book.passed.saturating_add(1);
                    book.let_through = Some(told.clone());
                });
            }
            self.keep(|book| book.pending.clear());
        }
        if self.halt.is_some() {
            self.mend(now);
            // Put right at once, the round goes on as if nothing had happened. Otherwise the work begins again in the next round.
            if self.halt.is_some() || self.how != How::AtOnce {
                return;
            }
        }
        #[cfg(test)]
        if let Some((0, fault)) = self.late {
            fault(self);
        }
        // and again before the work, for anything that has grown since the gate looked
        self.fit();
        let held = self.halted_moths();
        // The state as it is now, which the observers and the gate have just found to be right, is kept until the next round's work begins.
        let began = Some(Box::new((self.spider.clone(), self.world.clone(), self.own.clone())));
        self.before = [began.clone(), began.clone(), began];
        // The work begins by taking in what has been asked of the game since the last round.
        take_in(&mut self.own, &self.spider, &self.asks);
        // what is asked of this round's work from outside the state, for the rules to hold the result to
        let asked = Asked { buys: self.own.buys.clone(), clicks: self.own.clicks.len(), next_moth: self.own.next_moth, held: self.own.held() };
        world_work(&mut self.world, &self.spider, &held, &mut self.own, dt, now);
        spider_work(&mut self.spider, &self.world, &mut self.own, dt, now);
        #[cfg(test)]
        if let Some(fault) = self.fault {
            fault(self);
        }
        // What was said at the backdoor to be written during the work is written now: after the
        // observers have looked and before the result is recorded, as if the work had done it.
        // A line that cannot be written whole when its time comes is not one that was let
        // through, whatever becomes of the round: that it was not written is said.
        let inside = self.inside.clone();
        self.keep(|book| book.inside.clear());
        let (written, not): (Vec<String>, Vec<String>) = inside.iter().cloned().partition(|line| crate::backdoor::write_now(self, line));
        if !not.is_empty() {
            let told = short(&not.join("; "), MOST_TOLD);
            self.keep(|book| {
                book.unwritten = book.unwritten.saturating_add(1);
                book.not_written = Some(told.clone());
            });
        }
        match self.record_now((&asked, dt, now)) {
            None => {
                self.keep(|book| {
                    book.spoiled = 0;
                    // a stop in the wrong place is forgotten only by a round that began with nothing
                    // halted: the round that puts one right is not yet one that went by without it
                    if !began_halted {
                        book.stops = 0;
                    }
                    book.pending = written.clone();
                });
            }
            Some(reason) => {
                // The work has left something that cannot be recorded, or that the rules do not
                // allow, or that is not what the work gives when it is done again. It is not kept:
                // when the halt ends everything goes back to the last record, and with it what
                // the game keeps for itself. What was asked of this round is still waiting,
                // and the round that follows the halt takes it in.
                self.stop_all(reason.clone(), now);
                if inside.is_empty() {
                    // a fault of the work's own, not one written in at the backdoor: twice running, and the game cannot go on
                    self.keep(|book| book.spoiled = book.spoiled.saturating_add(1));
                    if self.spoiled > 1 {
                        // nothing of the wrong round is kept, and nothing starts again
                        let why = match self.restore() {
                            Ok(_) => format!("twice running, {}", reason),
                            Err(why) => format!("it could not be put right: {}", why),
                        };
                        self.stick(why);
                    }
                }
            }
        }
    }

    /// Something asked of the game from outside it is taken down three times, each on its own.
        /// The gate compares the three before any work is done.
    ///
    /// No list can grow without end between two rounds. Presses and upgrades are
    /// counted before they come here. Of the pointer's places that follow one another with
    /// nothing between, only the last four are kept, and while everything is halted only the
    /// last one. A letting go is never left out: only one that follows another with no press
    /// between, which lets go of nothing more, is not taken down again.
    fn ask(&mut self, ask: Ask) {
        // In a halt that cannot be put right nothing asked of the game is taken down.
        if self.stuck() {
            return;
        }
        let halted = self.halt.is_some();
        for asks in [&mut self.asks, &mut self.asks_again, &mut self.asks_third] {
            match ask {
                Ask::Point(..) => {
                    let run = asks.iter().rev().take_while(|before| matches!(before, Ask::Point(..))).count();
                    if run >= if halted { 1 } else { 4 } {
                        asks.pop(); // the pointer's newest place is written over the one before it
                    }
                    asks.push(ask);
                }
                Ask::Release => {
                    let let_go = asks.iter().rev().find(|before| matches!(before, Ask::Press(..) | Ask::Release)).map_or(false, |before| matches!(before, Ask::Release));
                    if !let_go {
                        asks.push(ask);
                    }
                }
                Ask::Press(..) | Ask::Buy(_) => asks.push(ask),
            }
        }
    }
    /// How many of one kind of thing are waiting to be taken in.
    fn waiting(&self, kind: fn(&Ask) -> bool) -> usize {
        self.asked().iter().filter(|ask| kind(ask)).count()
    }
    /// The pointer has moved. A place that is not a real one is not taken.
    pub fn point(&mut self, x: f64, y: f64, inside: bool, now: f64) {
        if x.is_finite() && y.is_finite() {
            self.ask(Ask::Point(x, y, inside, now));
        }
    }
    /// The pointer has been pressed in the game area: only where. What it means is the
    /// game's to decide, in the next round's work. On a foot or the body of the spider, the
    /// pointer may take hold of it. Anywhere else it is a click, for the world to act on.
    /// While everything is halted a press is not kept, and no more than eight wait for one round.
    pub fn press(&mut self, x: f64, y: f64, now: f64) {
        if x.is_finite() && y.is_finite() && self.halt.is_none() && self.waiting(|ask| matches!(ask, Ask::Press(..))) < 8 {
            self.ask(Ask::Press(x, y, now));
        }
    }
    /// The pointer has been let up: it has hold of nothing.
    pub fn release(&mut self) {
        self.ask(Ask::Release);
    }
    /// What the pointer is over that it could take hold of or take, for a screen to show:
    /// its place, how wide to ring it, and what it is. Nothing while it has hold of the
    /// spider, and nothing while everything is halted.
    fn over(&self) -> Option<(f64, f64, f64, &'static str)> {
        let (pointer, body) = (&self.own.pointer, &self.spider.body);
        if self.halt.is_some() || self.own.grab.is_some() || !pointer.inside {
            return None;
        }
        // More than MOST_HELD moths are a fault not yet found. Each would be looked up among
        // the halted ones, so nothing is said to be under the pointer until it has been.
        if self.world.moths.len() > MOST_HELD {
            return None;
        }
        match pick(&self.spider, pointer.x, pointer.y) {
            Some(k) if k < self.spider.legs.len() => Some((self.spider.legs[k].x, self.spider.legs[k].y, 8.0, "leg")),
            Some(_) => Some((body.x, body.y, body.size * 0.6, "body")),
            None => moth_at(&self.world, &self.halted_moths(), pointer.x, pointer.y).map(|moth| (moth.x, moth.y, SIZE * 0.5, "moth")),
        }
    }
    /// An upgrade asked for at the shop. The world decides whether it can be paid for, in
    /// its own work. While everything is halted it is not kept, and no more than eight wait
    /// for one round.
    pub fn buy(&mut self, what: &str) {
        if self.halt.is_some() || self.waiting(|ask| matches!(ask, Ask::Buy(_))) >= 8 {
            return;
        }
        if let Some(&(name, _, _)) = UPGRADES.iter().find(|u| u.0 == what.trim()) {
            self.ask(Ask::Buy(name));
        }
    }
    /// A line said at the backdoor to be written during the next round's work. While everything is halted there is no work, and it is not kept.
    pub fn during(&mut self, line: &str) -> bool {
        if self.halt.is_some() || self.inside.len() >= 8 {
            return false;
        }
        self.keep(|book| book.inside.push(line.to_string()));
        true
    }
    /// Is everything in the two scopes, and every observer, the same as in another game?
    pub fn same_state(&self, other: &Game) -> bool {
        self.texts() == other.texts() && self.ring.iter().zip(other.ring.iter()).all(|(mine, theirs)| mine.written() == theirs.written())
    }
    /// The game is begun again from the start: a new spider, no moths, nothing bought, eight
    /// new observers and a new record. Nothing of the old game is kept but how a halt ends,
    /// and the count of how many games there have been. What is the program's and not the
    /// game's goes on as it was: the game's own time, the note of what the clock last said, and
    /// the hold on the observers' threads.
    fn begin_again(&mut self, now: f64) {
        let (how, games, at) = (self.how, self.games.saturating_add(1), self.at);
        let seed = now.to_bits() ^ games.wrapping_mul(0x9E37_79B9_7F4A_7C15);
        let mut game = Game::new(now, seed);
        game.keep(|book| {
            book.how = how;
            book.games = games;
            book.at = at; // what the clock said at the last round is the same clock's
        });
        // A new game has eight new observers: where each is on a thread of its own, eight new threads.
        game.apart = self.apart.clone();
        if let Some(apart) = game.threads() {
            apart.again();
        }
        *self = game;
    }
    /// From now on each observer is run on a thread of its own.
    pub fn run_apart(&mut self, apart: Apart) {
        self.apart = [Some(apart.clone()), Some(apart.clone()), Some(apart)];
    }
    /// How a halt ends from now on.
    pub fn set_how(&mut self, how: How) {
        self.keep(|book| book.how = how);
    }
    /// Asked to put it right: the next round does it.
    pub fn put_right(&mut self) {
        self.keep(|book| {
            if let Some(halt) = book.halt.as_mut() {
                halt.asked = true;
            }
        });
    }

    /// Everything a screen needs, as one line of text: the open state, laid out by the names
    /// the backdoor knows it by, and what the game has to say about itself. Of what is long,
    /// or many, only so much is sent: see below.
    pub fn shown(&self, now: f64) -> String {
        let list = |items: Vec<String>| format!("[{}]", items.join(","));
        // A copy is long, so only its beginning is sent, and so it is with an observer's
        // other texts if they have been made long: the backdoor reads the whole. And of
        // everything else no more is sent than `MOST_SENT`, in length or in number, or the few
        // times that given below for two things, so that nothing a fault makes long or many is
        // sent whole to every screen in every round.
        let observers = |which: &[usize]| list(which.iter().filter_map(|&i| self.ring.get(i)).map(|o| o.shown(MOST_SENT, 24, MOST_SHOWN)).collect());
        let state = format!(
            "{{\"spider\":{{\"body\":{},\"old\":{},\"legs\":{},\"ring\":{}}},\"world\":{{\"edge\":{},\"tally\":{},\"web\":{},\"shop\":{},\"moths\":{},\"ring\":{}}}}}",
            self.spider.body.sent(MOST_SENT),
            self.spider.old.sent(MOST_SENT),
            list(self.spider.legs.iter().take(MOST_SENT).map(|l| l.sent(MOST_SENT)).collect()),
            observers(&SPIDER_RING),
            self.world.edge.sent(MOST_SENT),
            self.world.tally.sent(MOST_SENT),
            self.world.web.sent(MOST_SENT),
            self.world.shop.sent(MOST_SENT),
            list(self.world.moths.iter().take(MOST_SENT).map(|m| m.sent(MOST_SENT)).collect()),
            observers(&WORLD_RING)
        );
        // Each observer by its own name, how it is, which scope it is listed with, and what the backdoor calls it.
        let watch = list(
            self.ring
                .iter()
                .take(MOST_SENT)
                .enumerate()
                .map(|(i, o)| {
                    let state = if !o.alive || o.beat != self.rounds { "silent" } else if o.flagged { "flagged" } else { "ok" };
                    let (row, at) = match SPIDER_RING.iter().position(|&k| k == i) {
                        Some(k) => (0, format!("spider.ring[{}]", k)),
                        None => (1, format!("world.ring[{}]", WORLD_RING.iter().position(|&k| k == i).unwrap_or(0))),
                    };
                    format!("{{\"name\":{},\"state\":\"{}\",\"row\":{},\"at\":{}}}", quote(named(i)), state, row, quote(&at))
                })
                .collect(),
        );
        // What the game says of itself is the gate's own words, and short. It is cut all the same,
        // at a length none of it comes to, so that nothing at all is sent whole whatever its length.
        let text = |t: Option<&str>| t.map(|t| quote(&short(t, MOST_SENT * 4))).unwrap_or_else(|| "null".to_string());
        let (halt, stuck) = match &self.halt {
            Some(h) => (text(Some(&h.why)), h.stuck),
            None => (text(None), false),
        };
        let fixed = match &self.fixed {
            Some((did, until)) if now < *until && self.halt.is_none() => text(Some(did)),
            _ => text(None),
        };
        format!(
            "{{\"state\":{},\"watch\":{},\"halt\":{},\"stuck\":{},\"fixed\":{},\"how\":{},\"why\":{},\"did\":{},\"halts\":{},\"restarts\":{},\"games\":{},\"calm\":{},\"reach\":{},\"halted\":{},\"stomach\":{},\"shelf\":{},\"rate\":{},\"gains\":{},\"life\":{},\"over\":{},\"holding\":{},\"passed\":{},\"let\":{},\"unwritten\":{},\"not\":{}}}",
            state,
            watch,
            halt,
            stuck,
            fixed,
            quote(self.how.name()),
            text(self.why.as_deref()),
            text(self.fixed.as_ref().map(|(did, _)| did.as_str())),
            self.halts,
            self.restarts,
            self.games,
            Val::Num(((now - self.calm_since) / 1000.0).max(0.0).floor()).written(),
            Val::Num(web_reach(&self.world.edge, &self.world.web)).written(),
            // the numbers of as many moths as are sent, each with its comma
            quote(&self.ring.get(MOTHS).map_or_else(String::new, |o| short(&o.held, MOST_SENT * 20))),
            Val::Num(stomach(&self.world.shop, &self.spider.body)).written(),
            shelf_written(&self.world),
            Val::Num((self.own.gains.iter().map(|gain| gain.worth).sum::<f64>() / 100.0).round()).written(),
            // the catches of the last second, for a screen to show each once: which it was, where, and for how much
            list(self.own.gains.iter().filter(|gain| now - gain.at < 1000.0).take(MOST_SENT).map(|gain| format!("[{},{},{},{}]", Val::Num(gain.n).written(), Val::Num(gain.x).written(), Val::Num(gain.y).written(), Val::Num(gain.worth).written())).collect()),
            LIFE,
            match self.over() {
                Some((x, y, wide, what)) => format!("{{\"x\":{},\"y\":{},\"r\":{},\"what\":\"{}\"}}", Val::Num(x).written(), Val::Num(y).written(), Val::Num(wide).written(), what),
                None => "null".to_string(),
            },
            self.own.grab.is_some(),
            // what was written during the work and let through, because the gate found nothing wrong with the round: how many times, and the last
            self.passed,
            text(self.let_through.as_deref()),
            // what was kept to be written during the work and could not be written when its time came: how many times, and the last
            self.unwritten,
            text(self.not_written.as_deref())
        )
    }
}

/// The name of an observer by its place, for saying what was found. A place past the eighth
/// is no observer's, and has no name.
fn named(i: usize) -> &'static str {
    NAMES.get(i).copied().unwrap_or("ninth")
}
/// Do two of the three places that hold the observers' threads hold the same: nothing, or the same threads?
fn same_hold(one: &Option<Apart>, other: &Option<Apart>) -> bool {
    match (one, other) {
        (None, None) => true,
        (Some(one), Some(other)) => Arc::ptr_eq(&one.0, &other.0),
        _ => false,
    }
}
/// Are the copies apart in the program as it is built? The eight copies of the rule must be
/// eight functions there, the functions the second doing of the work is called by must not be
/// the ones the work is called by, and the second text of the rules must not be the first. Each copy carries a mark of its own so that they
/// are, and the program checks this at its start and does not start without it.
pub fn copies_apart() -> bool {
    let work = [
        (take_in as *const () as usize, again::take_in as *const () as usize),
        (world_work as *const () as usize, again::world_work as *const () as usize),
        (spider_work as *const () as usize, again::spider_work as *const () as usize),
        (in_web as *const () as usize, again::in_web as *const () as usize),
        (wrong_in as *const () as usize, rules::again::wrong_in as *const () as usize),
        (wrong_step as *const () as usize, rules::again::wrong_step as *const () as usize),
    ];
    looks::all_apart() && work.iter().all(|(first, second)| first != second)
}
/// What an observer is given to look at: the number of the round, the number its own last
/// signal and every other's should carry, the seven parts as they are now, written out, the
/// eight observers as they are, and the world as it is.
pub struct Look {
    rounds: f64,
    last: f64,
    texts: Vec<String>,
    ring: Vec<Observer>,
    world: World,
}
/// For the tests: is an observer in shape? It has its own name, holds a copy for each part and
/// nothing for a part outside its rings, has halted no moths unless it is the moths observer,
/// and gives no reason for a flag it has not put up.
#[cfg(test)]
fn in_shape(o: &Observer, j: usize) -> bool {
    o.name == NAMES[j]
        && o.copies.len() == PARTS.len()
        && (0..PARTS.len()).all(|p| sees(j, p) || o.copies[p].is_empty())
        && (j == MOTHS || o.held.is_empty())
        && (o.flagged || o.why.is_empty())
}
/// What one observer finds wrong in what it is given to look at, or nothing. Each observer
/// looks by a copy of the rule that is its own: see `looks`.
fn look_of(i: usize, look: &Look) -> String {
    // an observer past the eighth is not one of the eight, and has no rule to look by
    looks::LOOKS.get(i).map_or_else(String::new, |rule| rule(i, look))
}

/// How long the round waits for the observers' answers: this many waits, each no longer than
/// this. The wait is counted in waits and not by the clock, so that a machine that stands
/// still for a while uses up one of them and no more. An observer that has not answered by
/// then is silent. And for how many seconds running an observer hears nothing of the rounds
/// before it takes them to have stopped. These numbers are this program's own.
/// The ordinary length of a round, in seconds: sixty a second.
const ROUND_LENGTH: f64 = 1.0 / 60.0;
const WAITS: u32 = 8;
const WAIT: Duration = Duration::from_millis(5);
const QUIET_MOST: u32 = 5;

/// What an observer on a thread of its own is told.
enum Call {
    /// Look at this, and answer.
    Look(Arc<Look>),
    /// A round has gone by with nothing to look at.
    Tick,
    /// For the tests: answer nothing more.
    #[cfg(test)]
    Stall,
    /// For the tests: answer the next asking with this, whatever there is to find.
    #[cfg(test)]
    Say(String),
}
/// An observer's answer: which starting of the observers it belongs to, which observer it
/// is, the round it looked in, and what it found.
type Answer = (u64, usize, f64, String);

/// The eight observers, each on a thread of its own. The round asks all of them to look and
/// waits for their answers. One that does not answer in time is silent, and is not asked
/// again: it is replaced, with the other seven, when the halt it brings about is put right.
///
/// Each of them also watches that the rounds go on. One that hears nothing of them for some
/// seconds running takes them to have stopped, and does what it was given to do then: in the
/// program it says so, and the second of the same eight to say so stops the program.
#[derive(Clone)]
pub struct Apart(Arc<Mutex<Threads>>);
struct Threads {
    calls: Vec<Option<Sender<Call>>>,
    answers: Receiver<Answer>,
    /// What the threads are run by, held in three places. What is read of it is read from two that agree.
    run: [Run; 3],
    /// For the tests: of the next eight to be started, this one answers nothing from its start.
    #[cfg(test)]
    stall_next: Option<usize>,
    /// For the tests: of the next eight to be started, this one answers its first asking with this.
    #[cfg(test)]
    say_next: Option<(usize, String)>,
    /// The most waits any one round has used, and the longest any round took to have all its
    /// answers, for measuring. Nothing is decided by them.
    most: u32,
    longest: Duration,
}
/// What the observers' threads are run by: which starting of the observers this is (an
/// answer from an earlier one is not taken), what an observer does when it finds that the
/// rounds have stopped, for how many waits of how long it hears nothing before it does, and
/// for how many waits of how long the round waits for answers.
#[derive(Clone, Copy)]
struct Run {
    start: u64,
    stopped: fn(u64),
    quiet: (u32, Duration),
    waits: (u32, Duration),
}
impl Run {
    fn same(&self, other: &Run) -> bool {
        self.start == other.start && self.stopped as usize == other.stopped as usize && self.quiet == other.quiet && self.waits == other.waits
    }
}
impl Threads {
    /// What the threads are run by, as two of the three places have it.
    fn run(&self) -> Run {
        let run = &self.run;
        if run[0].same(&run[1]) || run[0].same(&run[2]) {
            run[0]
        } else if run[1].same(&run[2]) {
            run[1]
        } else {
            run[0] // no two agree: the gate finds that before the round, and nothing can be put right
        }
    }
}
impl Apart {
    /// Eight observers are started, each on a thread of its own. `stopped` is what one of
    /// them does when it finds that the rounds have stopped: it is told which starting of the
    /// observers the one that found it belongs to.
    pub fn start(stopped: fn(u64)) -> Apart {
        Apart::start_with(stopped, (QUIET_MOST, Duration::from_secs(1)), (WAITS, WAIT))
    }
    fn start_with(stopped: fn(u64), quiet: (u32, Duration), waits: (u32, Duration)) -> Apart {
        let (_, answers) = channel();
        let run = Run { start: 0, stopped, quiet, waits };
        let apart = Apart(Arc::new(Mutex::new(Threads {
            calls: Vec::new(),
            answers,
            run: [run; 3],
            #[cfg(test)]
            stall_next: None,
            #[cfg(test)]
            say_next: None,
            most: 0,
            longest: Duration::ZERO,
        })));
        apart.again();
        apart
    }
    fn held(&self) -> std::sync::MutexGuard<'_, Threads> {
        self.0.lock().unwrap_or_else(|broken| broken.into_inner())
    }
    /// The eight are replaced by eight new ones. An old one ends when it finds that nothing
    /// can call it any more. One that is stuck stays stuck, and is left behind.
    pub fn again(&self) {
        let mut threads = self.held();
        // The next starting, written to all three places.
        let mut run = threads.run();
        run.start = run.start.wrapping_add(1);
        threads.run = [run; 3];
        let (send, answers) = channel();
        threads.answers = answers;
        let (start, stopped, quiet) = (run.start, run.stopped, run.quiet);
        threads.calls = (0..NAMES.len())
            .map(|i| {
                let (call, calls) = channel();
                let send = send.clone();
                std::thread::Builder::new().name(format!("observer {}", NAMES[i])).spawn(move || observe(i, start, calls, send, stopped, quiet)).ok().map(|_| call)
            })
            .collect();
        #[cfg(test)]
        if let Some(i) = threads.stall_next.take() {
            if let Some(Some(call)) = threads.calls.get(i) {
                let _ = call.send(Call::Stall);
            }
        }
        #[cfg(test)]
        if let Some((i, what)) = threads.say_next.take() {
            if let Some(Some(call)) = threads.calls.get(i) {
                let _ = call.send(Call::Say(what));
            }
        }
    }
    /// Do the three places that hold what the threads are run by still hold the same? If they
    /// do, nothing comes back. If one differs from the other two, it is put right from them,
    /// and that comes back as true. If no two agree, false.
    fn settle(&self) -> Option<bool> {
        let mut threads = self.held();
        let run = threads.run;
        let (ab, ac, bc) = (run[0].same(&run[1]), run[0].same(&run[2]), run[1].same(&run[2]));
        if ab && ac {
            return None;
        }
        if ab || ac || bc {
            let right = threads.run();
            threads.run = [right; 3];
            return Some(true);
        }
        Some(false)
    }
    /// Every running observer is asked to look, and each one's answer is waited for.
    fn look(&self, running: &[bool], look: Look) -> Vec<Option<String>> {
        let mut threads = self.held();
        let (look, start, began) = (Arc::new(look), threads.run().start, Instant::now());
        let mut got: Vec<Option<String>> = vec![None; running.len()];
        let mut asked_of = vec![false; running.len()];
        let mut waiting = 0;
        for i in 0..running.len() {
            if running[i] {
                let asked = threads.calls.get(i).and_then(|call| call.as_ref()).map_or(false, |call| call.send(Call::Look(look.clone())).is_ok());
                if asked {
                    waiting += 1;
                    asked_of[i] = true;
                } else if let Some(call) = threads.calls.get_mut(i) {
                    *call = None; // it has gone: it is not asked again
                }
            } else if let Some(Some(call)) = threads.calls.get(i) {
                let _ = call.send(Call::Tick); // a stopped observer is not asked to look, and its thread is still told the rounds go on
            }
        }
                // An answer is taken from an observer that was asked in this round, of this starting, once.
        // Anything else that arrives is not an answer: one left over from an observer that was
        // late and has been dropped, at most. Fewer of those are waited through than there are
        // observers, so one asking waits at most the waits with no answer, one for each answer, and
        // one for each of those, whatever arrives. A round that puts a halt right asks twice.
        let (mut waits, mut others, (most, wait)) = (0, 0, threads.run().waits);
        while waiting > 0 && waits < most && others < running.len() {
            match threads.answers.recv_timeout(wait) {
                Ok((from, i, round, found)) => {
                    if from == start && round.to_bits() == look.rounds.to_bits() && i < got.len() && asked_of[i] && got[i].is_none() {
                        // An answer can be of any length. What is taken of it is no longer than
                        // the longest thing said here.
                        got[i] = Some(short(&found, MOST_TOLD));
                        waiting -= 1;
                    } else {
                        others += 1;
                    }
                }
                Err(RecvTimeoutError::Timeout) => waits += 1,
                Err(RecvTimeoutError::Disconnected) => break,
            }
        }
        // One that was asked and has not answered is not asked again.
        for i in 0..running.len() {
            if running[i] && got[i].is_none() {
                if let Some(call) = threads.calls.get_mut(i) {
                    *call = None;
                }
            }
        }
        threads.most = threads.most.max(waits);
        if waiting == 0 {
            threads.longest = threads.longest.max(began.elapsed());
        }
        got
    }
    /// The observers are told that a round has gone by with nothing for them to look at.
    fn tick(&self) {
        for call in self.held().calls.iter().flatten() {
            let _ = call.send(Call::Tick);
        }
    }
    /// The most waits any one round has used so far, and the longest any round took to have all its answers.
    #[cfg(test)]
    fn measured(&self) -> (u32, Duration) {
        let threads = self.held();
        (threads.most, threads.longest)
    }
    /// For the tests: a fault in one of the three places that hold what the threads are run by.
    #[cfg(test)]
    fn change(&self, place: usize, fault: fn(&mut Run)) {
        fault(&mut self.held().run[place]);
    }
    /// For the tests: of the next eight observers to be started, this one answers nothing from its start.
    #[cfg(test)]
    fn stall_next(&self, i: usize) {
        self.held().stall_next = Some(i);
    }
    /// For the tests: of the next eight observers to be started, this one answers its first asking with this.
    #[cfg(test)]
    fn say_next(&self, i: usize, what: String) {
        self.held().say_next = Some((i, what));
    }
    /// For the tests: one observer's thread answers nothing more.
    #[cfg(test)]
    fn stall(&self, i: usize) {
        if let Some(Some(call)) = self.held().calls.get(i) {
            let _ = call.send(Call::Stall);
        }
    }
    /// For the tests: one observer's thread answers the next asking with this.
    #[cfg(test)]
    fn say(&self, i: usize, what: String) {
        if let Some(Some(call)) = self.held().calls.get(i) {
            let _ = call.send(Call::Say(what));
        }
    }
}
/// One observer on a thread of its own: it looks when it is called, and answers.
fn observe(i: usize, start: u64, calls: Receiver<Call>, answers: Sender<Answer>, stopped: fn(u64), quiet: (u32, Duration)) {
    let mut heard_nothing = 0;
    #[cfg(test)]
    let mut say: Option<String> = None;
    loop {
        match calls.recv_timeout(quiet.1) {
            Ok(Call::Look(look)) => {
                heard_nothing = 0;
                let found = look_of(i, &look);
                #[cfg(test)]
                let found = say.take().unwrap_or(found);
                if answers.send((start, i, look.rounds, found)).is_err() {
                    return;
                }
            }
            Ok(Call::Tick) => heard_nothing = 0,
            #[cfg(test)]
            Ok(Call::Stall) => {
                while calls.recv().is_ok() {}
                return;
            }
            #[cfg(test)]
            Ok(Call::Say(what)) => say = Some(what),
            Err(RecvTimeoutError::Timeout) => {
                heard_nothing += 1;
                if heard_nothing >= quiet.0 {
                    stopped(start);
                    return;
                }
            }
            // Nothing can call it any more: it has been replaced.
            Err(RecvTimeoutError::Disconnected) => return,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::backdoor;
    use crate::game::{cost_of, purse, H, W};
    use std::sync::OnceLock;

    const STEP: f64 = 1000.0 / 60.0;
    type At = (Game, f64);

    fn play(game: &mut Game, now: &mut f64, rounds: usize) {
        for _ in 0..rounds {
            *now += STEP;
            game.round(STEP / 1000.0, *now);
        }
    }
    /// A game that has been running for a while: a web is being made, the spider has
    /// hunted, and there are moths on the wing.
    fn fresh() -> At {
        static BASE: OnceLock<At> = OnceLock::new();
        BASE.get_or_init(|| {
            let (mut game, mut now, mut rounds) = (Game::new(0.0, 7), 0.0, 0);
            while rounds < 2400 || game.world.moths.len() < 2 || game.world.tally.caught < 1.0 {
                play(&mut game, &mut now, 1);
                rounds += 1;
                assert!(rounds < 20000, "after five minutes there were {} moths and {} caught", game.world.moths.len(), game.world.tally.caught);
            }
            assert_eq!(game.halts, 0, "a game left alone halted: {}", game.why());
            assert!(game.world.web.on && game.world.web.made > 0.0, "no web had been begun");
            (game, now)
        })
        .clone()
    }
    /// A game with a moth halted in its web, and another on the wing.
    fn webbed() -> At {
        static BASE: OnceLock<At> = OnceLock::new();
        BASE.get_or_init(|| {
            let (mut game, mut now) = fresh();
            let mut rounds = 0;
            while game.ring[MOTHS].held.is_empty() || game.world.moths.len() < 2 || !game.spider.body.full {
                play(&mut game, &mut now, 1);
                rounds += 1;
                assert!(rounds < 216000, "after an hour no moth was halted in the web: {} webs made, web at step {}", game.world.tally.webs, game.world.web.made);
            }
            assert_eq!(game.halts, 0, "a game left alone halted: {}", game.why());
            (game, now)
        })
        .clone()
    }
    /// Everything the work can change, written out.
    fn all(game: &Game) -> String {
        game.texts().concat() + "|" + &game.ring[MOTHS].held
    }
    /// What the game will keep for itself once the next round has taken in what has been asked of it.
    fn taken(game: &Game) -> Own {
        let mut own = game.own.clone();
        take_in(&mut own, &game.spider, &game.asks);
        own
    }
    fn whole(game: &Game) -> bool {
        (0..game.ring.len()).all(|i| game.ring[i].alive && !game.ring[i].flagged && game.ring[i].why.is_empty() && in_shape(&game.ring[i], i))
    }

    /// One change through the backdoor with the halt ending after a pause: found in the next
    /// round, nothing moves while it is halted, everything is put back exactly, eight new
    /// observers, and then it goes on.
    fn after_a_pause(base: &At, line: &str) {
        let (mut game, mut now) = base.clone();
        let before = all(&game);
        let said = backdoor::run(&mut game, line);
        let changed = all(&game);
        play(&mut game, &mut now, 1);
        assert!(game.halted(), "{}: not halted in the next round (the backdoor said: {})", line, said);
        let why = game.why();
        play(&mut game, &mut now, 10);
        assert_eq!(all(&game), changed, "{}: something moved while halted", line);
        let mut waited = 0;
        while game.halted() && waited < 120 {
            play(&mut game, &mut now, 1);
            waited += 1;
        }
        assert!(!game.halted(), "{}: still halted two seconds later: {}", line, game.why());
        assert_eq!(all(&game), before, "{}: not put back exactly ({})", line, why);
        assert_eq!((game.halts, game.restarts), (1, 1), "{}: halts and restarts", line);
        assert!(whole(&game), "{}: the ring is not whole", line);
        play(&mut game, &mut now, 300);
        assert_eq!(game.halts, 1, "{}: halted again afterwards: {}", line, game.why());
    }
    /// The same with the halt ending on a click: it stays halted, with nothing moved, until
    /// it is asked for, and then everything is put back exactly.
    fn on_a_click(base: &At, line: &str) {
        let (mut game, mut now) = base.clone();
        game.set_how(How::OnAClick);
        let before = all(&game);
        backdoor::run(&mut game, line);
        let changed = all(&game);
        play(&mut game, &mut now, 180);
        assert!(game.halted(), "{}: on a click, it did not stay halted", line);
        assert_eq!(all(&game), changed, "{}: on a click, something moved while halted", line);
        assert_eq!((game.halts, game.restarts), (1, 0), "{}: on a click, halts and restarts while waiting", line);
        game.put_right();
        play(&mut game, &mut now, 1);
        assert!(!game.halted(), "{}: on a click, still halted after it was asked for: {}", line, game.why());
        assert_eq!(all(&game), before, "{}: on a click, not put back exactly", line);
        assert_eq!((game.halts, game.restarts), (1, 1), "{}: on a click, halts and restarts", line);
        assert!(whole(&game), "{}: on a click, the ring is not whole", line);
        play(&mut game, &mut now, 300);
        assert_eq!(game.halts, 1, "{}: on a click, halted again afterwards: {}", line, game.why());
    }
    /// The same with the halt ending at once: no round is lost. The game is exactly where a
    /// game that was never changed would be, round for round.
    fn at_once(base: &At, line: &str) {
        let ((mut game, mut now), (mut twin, mut then)) = (base.clone(), base.clone());
        game.set_how(How::AtOnce);
        twin.set_how(How::AtOnce);
        backdoor::run(&mut game, line);
        play(&mut game, &mut now, 1);
        play(&mut twin, &mut then, 1);
        assert!(!game.halted(), "{}: at once, still halted after the round: {}", line, game.why());
        assert_eq!((game.halts, game.restarts), (1, 1), "{}: at once, halts and restarts", line);
        assert_eq!(all(&game), all(&twin), "{}: at once, the game is not where it would have been", line);
        assert!(whole(&game), "{}: at once, the ring is not whole", line);
        play(&mut game, &mut now, 300);
        play(&mut twin, &mut then, 300);
        assert_eq!(all(&game), all(&twin), "{}: at once, the game went another way afterwards", line);
        assert_eq!((game.halts, twin.halts), (1, 0), "{}: at once, halted again afterwards: {}", line, game.why());
    }
    /// One change through the backdoor, under each of the three settings.
    fn caught(base: &At, line: &str) {
        after_a_pause(base, line);
        on_a_click(base, line);
        at_once(base, line);
    }
    fn level_of(game: &Game, what: &str) -> f64 {
        match game.world.shop.get(what) {
            Some(Val::Num(level)) => level,
            _ => panic!("the shop has no {}", what),
        }
    }
    /// A game given moths to spend, as if it had gained them by its own work.
    fn with_moths(base: &At, moths: f64) -> At {
        let (mut game, now) = base.clone();
        game.world.tally.gained += 100.0 * moths;
        game.settle();
        (game, now)
    }
    /// Does a line at the backdoor change anything in this game? A field may already hold what is written to it.
    fn changes(base: &At, line: &str) -> bool {
        let mut tried = base.0.clone();
        backdoor::run(&mut tried, line);
        all(&tried) != all(&base.0) || tried.ring.iter().zip(base.0.ring.iter()).any(|(a, b)| a.written() != b.written())
    }
    /// A game with no moths in it, so that its spider starves at half a minute.
    fn starving() -> At {
        let mut game = Game::new(0.0, 11);
        game.own.next_moth = 1e15; // no moth is ever due
        game.settle();
        (game, 0.0)
    }
    /// A game whose first spider has just died: its body lies there, and the next spider is walking in to it.
    fn handing() -> At {
        static BASE: OnceLock<At> = OnceLock::new();
        BASE.get_or_init(|| {
            let (mut game, mut now) = starving();
            while game.spider.body.gen < 2.0 {
                play(&mut game, &mut now, 1);
                assert!(now < 40000.0, "after forty seconds the next spider had not come in");
            }
            play(&mut game, &mut now, 20);
            assert!(game.spider.old.on && game.spider.body.state == "walking" && game.halts == 0);
            (game, now)
        })
        .clone()
    }
    /// A game whose spider has a full meter (filled here, and that recorded as its own work), so
    /// that it can be held for a few seconds without starving.
    fn fed() -> At {
        let (mut game, now) = fresh();
        game.spider.body.food = 1.0;
        game.settle();
        (game, now)
    }
    /// A game whose spider is being carried by the pointer, and has been for a second.
    fn carried() -> At {
        static BASE: OnceLock<At> = OnceLock::new();
        BASE.get_or_init(|| {
            let (mut game, mut now) = fed();
            let (x, y) = (game.spider.body.x, game.spider.body.y);
            game.press(x, y, now);
            game.point(900.0, 300.0, true, now);
            play(&mut game, &mut now, 60);
            assert!(game.spider.body.state == "panic" && game.spider.body.grip == 8.0 && game.halts == 0, "{:?}", game.spider.body);
            (game, now)
        })
        .clone()
    }
    /// Is the spider's body outside the game area?
    fn outside(game: &Game) -> bool {
        let body = &game.spider.body;
        body.x < 0.0 || body.x > W || body.y < 0.0 || body.y > H
    }
    /// A line for each field of a piece of the state, each a change to it.
    fn lines(path: &str, piece: &dyn Part) -> Vec<String> {
        piece
            .fields()
            .iter()
            .map(|field| match piece.get(field) {
                Some(Val::Bool(b)) => format!("{}.{} = {}", path, field, !b),
                Some(Val::Text(_)) => format!("{}.{} = 'something else'", path, field),
                _ => format!("{}.{} += 80", path, field),
            })
            .collect()
    }

    #[test]
    fn left_alone_for_half_an_hour_it_never_halts() {
        let mut game = Game::new(0.0, 3);
        let (mut now, mut most, mut held, mut sizes) = (0.0, 0, 0, Vec::new());
        for round in 0..108000 {
            now += STEP;
            if round % 400 < 200 {
                game.point(600.0 + 500.0 * (now / 2300.0).sin(), 400.0 + 300.0 * (now / 1700.0).cos(), true, now);
            }
            if round % 300 == 0 {
                // someone at the shop, who buys the cheapest thing whenever there are moths enough for it
                let cheapest = UPGRADES.iter().map(|u| (cost_of(u.0, level_of(&game, u.0)).unwrap(), u.0)).fold((f64::INFINITY, ""), |a, b| if b.0 < a.0 { b } else { a });
                if purse(&game.world.tally) >= 100.0 * cheapest.0 {
                    game.buy(cheapest.1);
                }
            }
            game.round(STEP / 1000.0, now);
            assert!(purse(&game.world.tally) >= 0.0, "more was spent than had been gained");
            assert!(game.world.moths.len() <= 10 + 2 * game.world.shop.spawn as usize, "more moths than there is room for");
            let (body, web) = (&game.spider.body, &game.world.web);
            // only a new spider, on its way in to the old one, is ever outside the game area, and there is never a round without a living spider
            assert!(game.spider.old.on || (body.x > 0.0 && body.x < W && body.y > 0.0 && body.y < H), "the spider left the game area");
            assert!(body.state == "walking" || body.state == "resting", "the spider is {}", body.state);
            assert!(body.age <= LIFE && body.size >= 26.5 && body.size <= 53.0 && body.boost >= 0.0 && body.boost <= 1.11, "age {}, size {}, boost {}", body.age, body.size, body.boost);
            assert!(body.food >= 0.0 && body.food <= 1.0, "the food meter went past one of its ends");
            for leg in &game.spider.legs {
                assert!((leg.x - body.x).hypot(leg.y - body.y) < 4.0 * body.size, "a foot went further than a leg can reach");
            }
            most = most.max(game.world.moths.len());
            held = held.max(game.ring[MOTHS].held.split(',').filter(|t| !t.is_empty()).count());
            for moth in &game.world.moths {
                assert!(moth.x >= 14.0 && moth.x <= W - 14.0 && moth.y >= 14.0 && moth.y <= H - 14.0, "a moth left the edge");
            }
            if web.on {
                let reach = web_reach(&game.world.edge, web);
                assert!(web.x - reach > 10.0 && web.x + reach < W - 10.0 && web.y - reach > 10.0 && web.y + reach < H - 10.0, "the web reaches past the edge");
                if !sizes.contains(&web.level) {
                    sizes.push(web.level);
                }
            }
        }
        let tally = &game.world.tally;
        assert_eq!(game.halts, 0, "{}", game.why());
        assert!(tally.caught > 60.0, "{} moths caught in half an hour, {} there at most", tally.caught, most);
        assert!(tally.webs >= 3.0 && sizes.len() >= 3 && held >= 1, "{} webs made, of sizes {:?}, and {} moths halted at most", tally.webs, sizes, held);
        assert_eq!(game.spider.body.eaten, tally.caught - tally.picked);
        // one spider after another, and each that died was eaten by the next
        let body = &game.spider.body;
        assert!(body.gen >= 5.0 && body.husks >= body.gen - 2.0 && body.boost > 0.0, "spider no. {}, {} old ones eaten, boost {}", body.gen, body.husks, body.boost);
        // what was spent is the prices of what was bought, and no more than was gained
        let shop = &game.world.shop;
        let bought = shop.spawn + shop.appetite + shop.spider + shop.web;
        let prices: f64 = UPGRADES.iter().map(|u| (0..level_of(&game, u.0) as usize).map(|level| cost_of(u.0, level as f64).unwrap()).sum::<f64>()).sum();
        assert!(bought >= 8.0 && tally.spent == prices && tally.gained >= 100.0 * tally.caught, "{} bought for {} (prices {}), {} gained from {} caught: {:?}", bought, tally.spent, prices, tally.gained, tally.caught, shop);
        println!("half an hour: {:?} {:?}, {} moths there at most, {} halted at most, sizes {:?}, spider no. {} with boost {}", tally, shop, most, held, sizes, body.gen, body.boost);
    }
    #[test]
    fn every_field_of_the_spider_is_watched() {
        // with a spider alone, with the one before it lying dead and this one walking in to it, and with it carried by the pointer
        for base in [fresh(), handing(), carried()] {
            for (path, piece) in [("spider.body", &base.0.spider.body as &dyn Part), ("spider.old", &base.0.spider.old)] {
                for line in lines(path, piece) {
                    caught(&base, &line);
                }
            }
            for k in 0..8 {
                for line in lines(&format!("spider.legs[{}]", k), &base.0.spider.legs[k]) {
                    caught(&base, &line);
                }
            }
            for line in [
                "spider.body.x = NaN", "spider.body.size = Infinity", "spider.legs[*].x += 30", "spider.body.food = 1; spider.body.full = true", "spider.body.age = 0", "spider.body.age = 299.99",
                "spider.body.gen = 9", "spider.body.boost = 0.5", "spider.body.state = 'dead'", "spider.body.food = 0", "spider.body.husks = 5", "spider.old.on = true", "spider.old.on = false",
                "spider.old.on = false; spider.body.husks += 1; spider.body.food = 1; spider.body.boost += 0.1", "spider.old.meals = 1000", "spider.old.x = 600; spider.old.y = 400; spider.old.on = true",
                "spider.body.grip = -1", "spider.body.grip = 3", "spider.body.grip = 8; spider.body.state = 'panic'", "spider.body.grip = -1; spider.body.state = 'resting'", "spider.body.state = 'recovering'",
            ] {
                // a line that changes nothing here is not a change: a field may already hold what is written to it
                if changes(&base, line) {
                    caught(&base, line);
                }
            }
        }
    }
    #[test]
    fn every_field_of_the_world_is_watched() {
        for base in [fresh(), webbed()] {
            for (path, piece) in [("world.edge", &base.0.world.edge as &dyn Part), ("world.tally", &base.0.world.tally), ("world.web", &base.0.world.web), ("world.shop", &base.0.world.shop)] {
                for line in lines(path, piece) {
                    caught(&base, &line);
                }
            }
            for k in 0..base.0.world.moths.len() {
                for line in lines(&format!("world.moths[{}]", k), &base.0.world.moths[k]) {
                    caught(&base, &line);
                }
            }
            for line in [
                "world.moths.push()", "world.moths.pop()", "world.moths[*].x = 600", "world.edge.inset = -300", "world.tally.caught = 99", "world.tally.picked = 5", "world.tally.webs = 6",
                "world.web.on = false", "world.web.made = 0", "world.web.made = 1000", "world.web.made = NaN", "world.web.torn = '1,2,3,4,5,6,7,8,9'", "world.web.level = 6", "world.web.level = 0.5",
                "world.web.old = true", "world.web.x += 300; world.web.y += 300", "world.tally.gained = 1000000", "world.tally.spent = -1000", "world.shop.spider = 990", "world.shop.spawn = 40",
                "world.shop.appetite = -2", "world.shop.web = NaN", "world.tally.gained += 5000; world.shop.spawn += 1; world.tally.spent += 10",
            ] {
                caught(&base, line);
            }
        }
    }
    #[test]
    fn every_observer_is_watched() {
        let base = webbed();
        for (scope, count) in [("spider", SPIDER_RING.len()), ("world", WORLD_RING.len())] {
            for i in 0..count {
                let at = format!("{}.ring[{}]", scope, i);
                for line in [
                    format!("{}.alive = false", at), format!("{}.name = 'nobody'", at), format!("{}.flagged = true", at), format!("{}.why = 'because'", at),
                    format!("{}.alive = false; {}.beat += 1", at, at), format!("{}.beat += 1", at), format!("{}.beat = 0", at), format!("{}.held = '99'", at), format!("{}.held = ''; {}.held = '0'", at, at),
                ] {
                    caught(&base, &line);
                }
                for p in 0..PARTS.len() {
                    caught(&base, &format!("{}.copies[{}] = 'x'", at, p));
                }
            }
        }
        for line in ["spider.ring[*].alive = false", "world.ring[*].alive = false", "spider.ring[*].alive = false; world.ring[*].alive = false", "world.ring[*].held = ''"] {
            caught(&base, line);
        }
    }
    #[test]
    fn the_list_of_halted_moths_is_watched() {
        // The moths observer's list emptied: the moth it had halted would be let go. The others of its ring find it.
        let (mut game, mut now) = webbed();
        assert_eq!(game.ring[MOTHS].held, in_web(&game.world));
        backdoor::run(&mut game, "world.ring[1].held = ''");
        play(&mut game, &mut now, 1);
        assert_eq!(game.why(), "the moths observer's list of halted moths has been changed");
        // A halted moth is not moved by the world, for as long as it is in the web.
        let (mut game, mut now) = webbed();
        let id = game.ring[MOTHS].held.split(',').next().unwrap().to_string();
        let place = |game: &Game| game.world.moths.iter().find(|m| Val::Num(m.id).written() == id).map(|m| (m.x, m.y));
        let was = place(&game);
        assert!(was.is_some());
        let mut rounds = 0;
        while game.spider.body.full && rounds < 600 {
            play(&mut game, &mut now, 1);
            rounds += 1;
            if let Some(at) = place(&game) {
                assert_eq!(Some(at), was, "a halted moth moved");
            }
        }
        assert!(rounds > 0);
    }
    #[test]
    fn a_click_takes_a_moth_out_of_the_web() {
        // A click is a press on nothing of the spider's. So first: a moth halted in the web with no part of
        // the spider in the way of a press on it, and another moth on the wing, also clear of the spider.
        let (mut game, mut now) = webbed();
        let mut rounds = 0;
        let (moth, loose) = loop {
            let held: Vec<String> = game.ring[MOTHS].held.split(',').map(String::from).collect();
            let halted = |id: f64| held.contains(&Val::Num(id).written());
            let free = game.world.moths.iter().find(|m| halted(m.id) && pick(&game.spider, m.x + 5.0, m.y - 5.0).is_none());
            let loose = game.world.moths.iter().find(|m| !halted(m.id) && pick(&game.spider, m.x, m.y).is_none());
            if let (Some(moth), Some(loose)) = (free, loose) {
                break (moth.clone(), loose.clone());
            }
            play(&mut game, &mut now, 1);
            rounds += 1;
            assert!(rounds < 216000, "after an hour there was no halted moth with the spider out of the way of it");
        };
        assert_eq!(game.halts, 0, "{}", game.why());
        let (id, base) = (Val::Num(moth.id).written(), (game.clone(), now));
        let (tally, meals, torn) = (game.world.tally.clone(), game.spider.body.meals, game.world.web.torn.clone());
        // a click on nothing, and a click on a moth that is on the wing: neither takes anything
        game.press(20.0, 20.0, now);
        game.release();
        game.press(loose.x, loose.y, now);
        game.release();
        play(&mut game, &mut now, 1);
        assert_eq!((game.world.tally.caught, game.world.tally.picked), (tally.caught, tally.picked));
        // a click on the halted moth takes it: it counts as caught, it feeds nobody, and the strand it was on is broken
        assert!(pick(&game.spider, moth.x + 5.0, moth.y - 5.0).is_none(), "the spider has come to be in the way");
        game.press(moth.x + 5.0, moth.y - 5.0, now);
        game.release();
        play(&mut game, &mut now, 1);
        assert!(!game.world.moths.iter().any(|m| Val::Num(m.id).written() == id), "the moth is still there");
        assert_eq!((game.world.tally.caught, game.world.tally.picked), (tally.caught + 1.0, tally.picked + 1.0));
        assert_eq!(game.spider.body.meals, meals);
        assert!(game.world.web.torn.len() > torn.len(), "no strand was broken");
        play(&mut game, &mut now, 600);
        assert_eq!(game.halts, 0, "{}", game.why());
        assert_eq!(game.spider.body.eaten, game.world.tally.caught - game.world.tally.picked);
        // while everything is halted a click is not kept
        let (mut game, mut now) = base;
        backdoor::run(&mut game, "spider.body.x += 150");
        play(&mut game, &mut now, 1);
        game.press(moth.x, moth.y, now);
        while game.halted() {
            play(&mut game, &mut now, 1);
        }
        play(&mut game, &mut now, 2);
        assert_eq!(game.world.tally.picked, tally.picked);
    }
    #[test]
    fn a_flag_in_one_ring_reaches_the_other() {
        for line in ["spider.body.x += 150", "world.edge.inset = -300", "world.web.made += 1"] {
            let (mut game, mut now) = fresh();
            backdoor::run(&mut game, line);
            play(&mut game, &mut now, 1);
            assert!(game.ring.iter().all(|o| o.flagged), "{}: flags: {:?}", line, game.ring.iter().map(|o| o.flagged).collect::<Vec<_>>());
        }
    }
    #[test]
    fn a_signal_written_from_outside_is_found() {
        // An observer's signal is the number of the round it last signalled in. It is written again in
        // every round, so a change to it leaves nothing behind. It is found all the same: the observer
        // finds that its last signal is not the one it gave, and the others of its ring find that it is
        // not the round before's.
        let base = webbed();
        for line in ["spider.ring[0].beat = 5", "world.ring[2].beat = NaN", "spider.ring[3].beat -= 1", "world.ring[4].beat += 1", "spider.ring[*].beat += 3; world.ring[*].beat += 3"] {
            caught(&base, line);
        }
        let (mut game, mut now) = fresh();
        backdoor::run(&mut game, "world.ring[0].beat += 1");
        play(&mut game, &mut now, 1);
        assert_eq!(game.ring[4].why, "the edge observer found its own signal changed");
        for i in [3, 5, 6, 7] {
            assert_eq!(game.ring[i].why, "the edge observer is silent", "the {} observer", NAMES[i]);
        }
        // what the halt is said to be for is what the first of them found
        assert_eq!(game.why(), "the edge observer is silent");
    }
    #[test]
    fn what_the_observers_miss_the_gate_stops() {
        // A part changed, and every observer's copy of it made to agree, in the same instant.
        for (line, part, who) in [("spider.body.x += 150", 2, &SPIDER_RING[..]), ("spider.old.meals = 99", 2, &SPIDER_RING[..]), ("world.tally.caught = 99", 4, &WORLD_RING[..]), ("world.shop.spider = 50", 4, &WORLD_RING[..]), ("world.web.age += 5", 5, &WORLD_RING[..])] {
            for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
                let (mut game, mut now) = fresh();
                game.set_how(how);
                let before = all(&game);
                backdoor::run(&mut game, line);
                let forged = snap(&game.spider, &game.world, part);
                for &i in who {
                    game.ring[i].copies[part] = holds(i, &forged);
                }
                if how == How::AtOnce {
                    let (mut twin, mut then) = fresh();
                    play(&mut game, &mut now, 1);
                    play(&mut twin, &mut then, 1);
                    assert_eq!((game.halts, game.restarts, game.halted()), (1, 1, false), "{}", line);
                    assert_eq!(all(&game), all(&twin), "{}", line);
                    assert!(game.why.as_deref().unwrap_or("").starts_with(&format!("the gate found the {} changed", PARTS[part])), "{:?}", game.why);
                    continue;
                }
                play(&mut game, &mut now, 1);
                assert!(game.halted(), "{}", line);
                assert!(game.why().starts_with(&format!("the gate found the {} changed", PARTS[part])), "{}", game.why());
                game.put_right();
                play(&mut game, &mut now, 1);
                assert!(!game.halted());
                assert_eq!(all(&game), before, "{}", line);
            }
        }
    }
    #[test]
    fn the_shape_is_fixed() {
        let (mut game, mut now) = fresh();
        let before = all(&game);
        for line in [
            "spider.body.x = 'left'", "spider.body.state = 5", "spider.legs[2].up = 3", "spider.body.extra = 1", "spider.legs[9].x = 1", "spider.ring[0].copies[7] = 'x'",
            "spider.ring[1].alive = 'no'", "world.edge.inset = 'out'", "world.moths[99].x = 1", "world.tally.lost = 1", "world.ring[5].alive = false", "nothing.at.all = 1",
            "world.shop.spawn = 'many'", "world.shop.luck = 1", "world.shop = 4", "world.tally.gained = true",
            "spider.old.on = 2", "spider.old.legs = 8", "spider.old = 1", "spider.body.gen = 'next'", "spider.next.x = 1", "world.husk.on = true", "spider.ring[0].knows = 2",
            "world.web.on = 3", "world.web.torn = 5", "world.web.made = 'all'", "world.web.strands = 1", "world.ring[1].held = 7", "world.web = 1",
        ] {
            let said = backdoor::run(&mut game, line);
            assert!(said.contains("fixed") || said.contains("there is no") || said.contains("there are only") || said.contains("is not"), "{} -> {}", line, said);
        }
        assert_eq!(all(&game), before);
        play(&mut game, &mut now, 60);
        assert_eq!(game.halts, 0, "{}", game.why());
    }
    #[test]
    fn changes_made_during_the_pause_do_not_steer_the_putting_right() {
        let (mut game, mut now) = fresh();
        let before = all(&game);
        backdoor::run(&mut game, "spider.body.x += 150");
        play(&mut game, &mut now, 1);
        for i in [0, 1, 3] {
            backdoor::run(&mut game, &format!("spider.ring[{}].copies[2] = 'x'", i));
            play(&mut game, &mut now, 1);
        }
        let mut waited = 0;
        while game.halted() && waited < 300 {
            play(&mut game, &mut now, 1);
            waited += 1;
        }
        assert!(!game.halted());
        assert_eq!(all(&game), before);
        assert_eq!(game.halts, 1);
    }
    #[test]
    fn a_halt_ends_as_it_is_set_to() {
        assert_eq!(Game::new(0.0, 1).how, How::AfterAPause);
        for how in [How::AtOnce, How::AfterAPause, How::OnAClick] {
            assert_eq!(How::named(how.name()), Some(how));
        }
        assert_eq!(How::named("never"), None);
        // After a pause: not before the state has been left alone for the whole of it.
        let (mut game, mut now) = fresh();
        backdoor::run(&mut game, "spider.body.x += 150");
        play(&mut game, &mut now, 30);
        assert!(game.halted(), "put right before the pause was over");
        backdoor::run(&mut game, "spider.body.y += 150");
        play(&mut game, &mut now, 30);
        assert!(game.halted(), "put right while it was still being changed");
        play(&mut game, &mut now, 10);
        assert!(!game.halted(), "{}", game.why());
        // Asking puts it right at once under that setting too.
        let (mut game, mut now) = fresh();
        backdoor::run(&mut game, "spider.body.x += 150");
        play(&mut game, &mut now, 2);
        game.put_right();
        play(&mut game, &mut now, 1);
        assert!(!game.halted());
        // Asking when nothing is halted does nothing, and is not remembered.
        let (mut game, mut now) = fresh();
        game.set_how(How::OnAClick);
        game.put_right();
        play(&mut game, &mut now, 5);
        backdoor::run(&mut game, "spider.body.x += 150");
        play(&mut game, &mut now, 120);
        assert!(game.halted(), "an earlier asking ended a later halt");
        // The setting changed while halted: the halt ends the new way.
        game.set_how(How::AtOnce);
        play(&mut game, &mut now, 1);
        assert!(!game.halted());
        assert_eq!((game.halts, game.restarts), (1, 1));
        // On a click, changes made while it waits are all put back when it is asked for.
        let (mut game, mut now) = fresh();
        game.set_how(How::OnAClick);
        let before = all(&game);
        for line in ["spider.body.x += 150", "world.tally.caught = 7", "world.web.on = false", "spider.ring[*].alive = false", "world.moths.pop()"] {
            backdoor::run(&mut game, line);
            play(&mut game, &mut now, 20);
        }
        assert_eq!((game.halts, game.restarts, game.halted()), (1, 0, true));
        game.put_right();
        play(&mut game, &mut now, 1);
        assert!(!game.halted(), "{}", game.why());
        assert_eq!(all(&game), before);
    }
    #[test]
    fn the_next_spider_walks_in_as_the_old_one_dies_of_old_age() {
        // With moths in plenty the spider does not starve, and lives out its five minutes.
        let (mut game, mut now) = with_moths(&fresh(), 100000.0);
        for _ in 0..8 {
            game.buy("spawn");
        }
        let (mut was, mut grown) = (game.spider.clone(), 0.0);
        while game.spider.body.gen < 2.0 {
            was = game.spider.clone();
            play(&mut game, &mut now, 1);
            let body = &game.spider.body;
            assert!(now < 400000.0, "it is still alive at age {}", body.age);
            if body.gen < 2.0 && body.age >= 150.0 {
                grown = body.size; // full grown at two and a half minutes
                assert_eq!((body.size, stomach(&game.world.shop, body)), (53.0, 8.0));
            }
        }
        assert_eq!(grown, 53.0);
        // the round before, the old one was alive, in the last round of its five minutes, and no body lay there
        assert!(was.body.gen == 1.0 && was.body.age > LIFE - 0.02 && was.body.age < LIFE && was.body.food > 0.0 && !was.old.on, "{:?}", was.body);
        // in the round it died the next one is there: a new spider, outside the edge, already walking to the old one, which lies where it was
        let (body, old) = (&game.spider.body, &game.spider.old);
        assert!(outside(&game) && body.state == "walking" && body.v > 0.0 && (body.size - 26.5).abs() < 0.01 && body.age < 0.02 && body.meals == 0.0, "{:?}", body);
        assert!(old.on && (old.x, old.y, old.h, old.size) == (was.body.x, was.body.y, was.body.h, 53.0) && old.meals >= was.body.meals && (body.tx - old.x).hypot(body.ty - old.y) < 1.0, "{:?}", old);
        // its front feet are at the edge, so it is seen at once
        let reach = game.spider.legs.iter().map(|leg| leg.x.min(W - leg.x).min(leg.y).min(H - leg.y)).fold(f64::NEG_INFINITY, f64::max);
        assert!(reach > -6.0 && reach < 30.0, "its nearest foot is {} inside the game area", reach);
        assert!(whole(&game) && game.halts == 0, "{}", game.why());
        // it walks to the old one and eats it: a full meal, and a boost for the moths that one had eaten
        let (meals, mut rounds) = (old.meals, 0);
        while game.spider.old.on {
            play(&mut game, &mut now, 1);
            rounds += 1;
            assert!(rounds < 1800, "half a minute on, it had not reached the old one");
            assert_eq!(game.world.tally.caught - game.world.tally.picked, game.spider.body.eaten, "it ate a moth on its way to the old one");
        }
        let body = &game.spider.body;
        assert_eq!((body.husks, body.full, body.gen), (1.0, true, 2.0));
        assert!(body.food > 0.99 && meals > 10.0 && body.boost == 0.1, "food {}, the old one ate {}, boost {}", body.food, meals, body.boost);
        // boosted, its food lasts a tenth longer
        let food = body.food;
        play(&mut game, &mut now, 1);
        assert!((food - game.spider.body.food - STEP / 1000.0 / 33.0).abs() < 1e-12);
        assert_eq!(game.halts, 0, "{}", game.why());
    }
    #[test]
    fn the_next_spider_walks_in_as_the_old_one_starves() {
        let (mut game, mut now) = starving();
        let mut was = game.spider.clone();
        while game.spider.body.gen < 2.0 {
            was = game.spider.clone();
            play(&mut game, &mut now, 1);
            assert!(now < 40000.0);
        }
        assert!(was.body.food > 0.0 && was.body.food < 0.001 && was.body.age < 31.0, "{:?}", was.body);
        assert!(outside(&game) && game.spider.old.on && game.spider.body.state == "walking" && game.spider.old.meals == 0.0);
        // with nothing to eat but the old one, each spider in turn starves and is followed at once: there is never a round without a living spider
        while game.spider.body.gen < 5.0 {
            play(&mut game, &mut now, 1);
            assert!(game.spider.body.state == "walking" || game.spider.body.state == "resting");
            assert!(now < 400000.0);
        }
        assert!(game.spider.body.husks >= 3.0 && game.halts == 0, "{} eaten: {}", game.spider.body.husks, game.why());
    }
    #[test]
    fn the_boost_goes_up_by_a_tenth_at_most_and_stops_at_111_hundredths() {
        // An old spider that had eaten so many moths, and a new one walking in to it with so much boost already
        // (set here, and recorded as the game's own work). What the new one's boost is once it has eaten the old one.
        for (meals, had, has) in [(30.0, 0.0, 0.1), (4.0, 0.2, 0.24), (0.0, 0.3, 0.3), (30.0, 0.45, 0.55), (30.0, 1.0, 1.1), (30.0, 1.05, 1.11), (30.0, 1.11, 1.11), (2.0, 1.1, 1.11)] {
            let (mut game, mut now) = handing();
            game.spider.old.meals = meals;
            game.spider.body.boost = had;
            game.settle();
            let mut rounds = 0;
            while game.spider.old.on {
                play(&mut game, &mut now, 1);
                rounds += 1;
                assert!(rounds < 1800 && !game.halted(), "the old one that had eaten {}, the new one with {}: {}", meals, had, game.why());
            }
            assert!((game.spider.body.boost - has).abs() < 1e-12, "the old one had eaten {}, the new one had {}, and has {}", meals, had, game.spider.body.boost);
            // boosted, it walks faster and its food lasts longer, by that much
            let (food, at) = (game.spider.body.food, (game.spider.body.x, game.spider.body.y));
            play(&mut game, &mut now, 1);
            let body = &game.spider.body;
            assert!((food - body.food - STEP / 1000.0 / (30.0 * (1.0 + has))).abs() < 1e-12);
            assert!((body.x - at.0).hypot(body.y - at.1) <= body.size * 5.5 * (1.0 + has) * STEP / 1000.0 + 1e-9);
            play(&mut game, &mut now, 300);
            assert_eq!(game.halts, 0, "{}", game.why());
        }
        // more than that is no state the game can be in
        let (mut game, mut now) = fresh();
        backdoor::run(&mut game, "during spider.body.boost = 1.12");
        play(&mut game, &mut now, 1);
        assert!(game.why().ends_with("a boost greater than a spider can have"), "{}", game.why());
    }
    #[test]
    fn a_death_of_any_kind_is_followed_in_the_same_round() {
        // Its meter all but emptied in one go (and that recorded as its own work): no death could be less looked for.
        let (mut game, mut now) = fresh();
        game.spider.body.food = 0.0001;
        game.settle();
        let at = (game.spider.body.x, game.spider.body.y);
        play(&mut game, &mut now, 1);
        let spider = &game.spider;
        assert!(spider.body.gen == 2.0 && outside(&game) && spider.old.on && (spider.old.x, spider.old.y) == at && whole(&game) && game.halts == 0, "{:?}", spider.body);
        // A spider that dies before it has reached the old one leaves its own body in that one's place.
        game.spider.body.food = 0.0001;
        game.settle();
        let at = (game.spider.body.x, game.spider.body.y);
        play(&mut game, &mut now, 1);
        let spider = &game.spider;
        assert!(spider.body.gen == 3.0 && spider.old.on && (spider.old.x, spider.old.y) == at && spider.body.husks == 0.0 && game.halts == 0, "{:?}", spider.old);
        play(&mut game, &mut now, 600);
        assert_eq!((game.spider.body.husks, game.halts), (1.0, 0), "{}", game.why());
    }
    #[test]
    fn the_pointer_picks_the_spider_up_by_its_body() {
        let (mut game, mut now) = fed();
        // A press on nothing is a click for the world, and takes hold of nothing.
        game.press(30.0, 30.0, now);
        assert!(taken(&game).grab.is_none() && taken(&game).clicks.len() == 1 && game.own.clicks.is_empty());
        play(&mut game, &mut now, 1);
        // A press on the body that does not move takes hold of nothing: the spider goes on as it was.
        let (x, y) = (game.spider.body.x, game.spider.body.y);
        game.press(x, y, now);
        assert!(matches!(&taken(&game).grab, Some(grab) if grab.what == 8 && !grab.moved) && taken(&game).clicks.is_empty());
        game.point(x + 3.0, y, true, now);
        play(&mut game, &mut now, 30);
        assert!(game.spider.body.grip == -1.0 && (game.spider.body.state == "walking" || game.spider.body.state == "resting"));
        game.release();
        assert!(taken(&game).grab.is_none());
        play(&mut game, &mut now, 1);
        assert!(game.own.grab.is_none() && game.asks.is_empty() && game.asks_again.is_empty());
        // Pressed and moved: it is carried to the pointer, panicking, with every leg in the air.
        let (x, y) = (game.spider.body.x, game.spider.body.y);
        game.press(x, y, now);
        game.point(900.0, 300.0, true, now);
        play(&mut game, &mut now, 1);
        assert!(game.spider.body.state == "panic" && game.spider.body.grip == 8.0);
        let (food, fed) = (game.spider.body.food, game.spider.body.eaten);
        play(&mut game, &mut now, 60);
        let body = &game.spider.body;
        assert!((body.x - 900.0).abs() < 1.0 && (body.y - 300.0).abs() < 1.0 && body.v == 0.0, "carried to {}, {}", body.x, body.y);
        assert!(game.spider.legs.iter().all(|leg| leg.up && (leg.x - body.x).hypot(leg.y - body.y) < 3.0 * body.size));
        // its food runs down six times as fast, and it catches nothing
        assert!((food - body.food - 60.0 * STEP / 1000.0 / 5.0).abs() < 1e-9, "food went from {} to {}", food, body.food);
        assert_eq!(game.world.tally.caught - game.world.tally.picked, fed);
        assert!(!game.world.web.tied);
        // It cannot be taken over the edge.
        for (px, py, corner) in [(0.0, 0.0, (0.0, 0.0)), (5000.0, 5000.0, (W, H))] {
            game.point(px, py, true, now);
            play(&mut game, &mut now, 40);
            assert!(game.spider.body.gen == 1.0 && game.spider.body.state == "panic");
            let (body, m) = (&game.spider.body, 10.0 + game.spider.body.size * 2.4);
            assert!(((body.x - corner.0).abs() - m).abs() < 1.0 && ((body.y - corner.1).abs() - m).abs() < 1.0, "carried to {}, {}", body.x, body.y);
        }
        // Let go, it puts its feet down, and for a short while it does nothing else.
        game.release();
        play(&mut game, &mut now, 1);
        let at = (game.spider.body.x, game.spider.body.y);
        assert!(game.spider.body.state == "recovering" && game.spider.body.grip == -1.0);
        play(&mut game, &mut now, 36);
        assert!(game.spider.body.state == "recovering" && (game.spider.body.x, game.spider.body.y) == at);
        play(&mut game, &mut now, 10);
        assert!(game.spider.body.state == "walking" || game.spider.body.state == "resting", "{}", game.spider.body.state);
        play(&mut game, &mut now, 600);
        assert_eq!(game.halts, 0, "{}", game.why());
    }
    #[test]
    fn the_pointer_drags_the_spider_by_a_leg() {
        let (mut game, mut now) = fed();
        let (fx, fy) = (game.spider.legs[2].x, game.spider.legs[2].y);
        game.press(fx, fy, now);
        assert!(matches!(&taken(&game).grab, Some(grab) if grab.what == 2));
        // moved less far than takes hold, it holds nothing yet
        game.point(fx + 3.0, fy + 1.0, true, now);
        play(&mut game, &mut now, 1);
        assert!(game.spider.body.grip == -1.0 && game.spider.body.state != "panic");
        for step in 2..=120 {
            // the pointer goes off across the game area, and the spider is pulled after it by that leg
            let (px, py) = (fx + 3.0 * step as f64, fy + 1.0 * step as f64);
            game.point(px, py, true, now);
            play(&mut game, &mut now, 1);
            let (body, leg) = (&game.spider.body, &game.spider.legs[2]);
            assert!(body.state == "panic" && body.grip == 2.0 && !leg.up);
            assert!((leg.x - px.min(W - 14.0)).hypot(leg.y - py.min(H - 14.0)) < 1.0, "step {}: the foot is at {}, {} and the pointer at {}, {}", step, leg.x, leg.y, px, py);
            assert!((leg.x - body.x).hypot(leg.y - body.y) <= body.size * 1.8 * 1.15 + 0.001, "the leg is stretched to {}", (leg.x - body.x).hypot(leg.y - body.y) / body.size);
            assert!(game.spider.legs.iter().enumerate().all(|(k, other)| k == 2 || other.up));
        }
        assert!((game.spider.body.x - fx).hypot(game.spider.body.y - fy) > 200.0, "the body was not pulled along");
        game.release();
        play(&mut game, &mut now, 1);
        assert!(game.spider.body.state == "recovering" && game.spider.legs.iter().all(|leg| !leg.up || leg.t > 0.0));
        play(&mut game, &mut now, 600);
        assert_eq!(game.halts, 0, "{}", game.why());
    }
    #[test]
    fn held_too_long_it_dies_and_the_pointer_has_hold_of_nothing() {
        let (mut game, mut now) = carried();
        let mut rounds = 0;
        while game.spider.body.gen < 2.0 {
            play(&mut game, &mut now, 1);
            rounds += 1;
            assert!(rounds < 330, "held for five and a half seconds, it is still alive with food {}", game.spider.body.food);
        }
        let (body, old) = (&game.spider.body, &game.spider.old);
        assert!(game.own.grab.is_none() && body.grip == -1.0 && body.state == "walking" && outside(&game), "{:?}", body);
        assert!(old.on && (old.x - 900.0).abs() < 1.0 && (old.y - 300.0).abs() < 1.0 && game.halts == 0, "{:?}", old);
        // the pointer, still where it was, does not have hold of the new one as it walks in
        play(&mut game, &mut now, 120);
        assert!(game.spider.body.state != "panic" && game.spider.body.grip == -1.0);
    }
    #[test]
    fn a_halt_and_the_pointer() {
        // While everything is halted a press is not kept.
        let (mut game, mut now) = fresh();
        backdoor::run(&mut game, "spider.legs[0].x += 40");
        play(&mut game, &mut now, 1);
        assert!(game.halted());
        let (x, y) = (game.spider.body.x, game.spider.body.y);
        game.press(x, y, now);
        game.press(30.0, 30.0, now);
        assert!(game.asks.is_empty() && game.asks_again.is_empty() && game.own.grab.is_none() && game.own.clicks.is_empty());
        // and of the pointer's places while it is halted, only the last is kept
        for step in 0..500 {
            game.point(100.0 + step as f64, 100.0, true, now);
        }
        assert!(game.asks == vec![Ask::Point(599.0, 100.0, true, now)] && game.asks_again == game.asks);
        // A spider that was being carried is carried on when the halt is over, from where the record has it.
        let (mut game, mut now) = carried();
        let at = (game.spider.body.x, game.spider.body.y);
        backdoor::run(&mut game, "spider.body.x = 100; spider.body.grip = -1; spider.body.state = 'resting'");
        play(&mut game, &mut now, 1);
        assert!(game.halted() && game.own.grab.is_some());
        while game.halted() {
            play(&mut game, &mut now, 1);
        }
        assert!((game.spider.body.x, game.spider.body.y) == at && game.spider.body.state == "panic" && game.spider.body.grip == 8.0);
        play(&mut game, &mut now, 1);
        assert!(game.spider.body.state == "panic" && (game.halts, game.restarts) == (1, 1));
        // Letting go during a halt lets go.
        backdoor::run(&mut game, "spider.body.y += 50");
        play(&mut game, &mut now, 1);
        game.release();
        while game.halted() {
            play(&mut game, &mut now, 1);
        }
        play(&mut game, &mut now, 1);
        assert!(game.spider.body.state == "recovering" && game.halts == 2);
    }
    /// A line written during the work of the next round, as if the work itself had gone wrong.
    /// The rules of the game must find it in that round: nothing of the round is recorded,
    /// everything halts with a reason that names what is wrong, the round is undone, and then
    /// the game goes on.
    static MISNAMED: std::sync::Mutex<Vec<String>> = std::sync::Mutex::new(Vec::new());
    fn undone(base: &At, line: &str, names: &str) {
        let (mut game, mut now) = base.clone();
        let before = all(&game);
        let said = backdoor::run(&mut game, &format!("during {}", line));
        assert!(said.starts_with("to be written during the work of the next round"), "{}: the backdoor said: {}", line, said);
        assert_eq!(all(&game), before, "{}: written at once", line);
        play(&mut game, &mut now, 1);
        assert!(game.halted(), "{}: the round with it in was recorded", line);
        let why = game.why();
        assert!(why.starts_with("the gate found a step of the work that the rules of the game do not allow: "), "{}: halted for another reason: {}", line, why);
        if !why.contains(names) {
            MISNAMED.lock().unwrap().push(format!("{} -> {}", line, &why[75..]));
        }
        assert!(game.ring.iter().all(|o| !o.flagged), "{}: an observer flagged what only the gate could have found", line);
        while game.halted() {
            play(&mut game, &mut now, 1);
        }
        assert_eq!(all(&game), before, "{}: the round was not undone", line);
        assert_eq!((game.halts, game.restarts, game.passed), (1, 1, 0), "{}", line);
        play(&mut game, &mut now, 300);
        assert_eq!(game.halts, 1, "{}: halted again afterwards: {}", line, game.why());
    }
    #[test]
    fn a_wrong_step_of_the_work_is_found_by_the_rules_and_undone() {
        let base = fresh();
        assert!(!base.0.world.moths.is_empty() && base.0.spider.body.food < 0.99 && base.0.world.web.on && !base.0.spider.old.on);
        for (line, names) in [
            // the moths, and what was caught
            ("world.tally.caught += 5", "the moths caught not the moths the spider ate and the pointer picked"),
            ("world.tally.caught += 5; spider.body.eaten += 5", "moths counted as caught that were never there"),
            ("world.moths.pop()", "gone without being counted"),
            ("world.moths.push()", "a moth with no number of its own"),
            ("world.moths[0].id += 50", "moth"),
            ("world.moths[0].x += 100", "moth"),
            ("world.moths[0].y = 5", "a moth outside the edge"),
            ("world.tally.gained += 100000", "moths gained that the catches do not account for"),
            ("world.tally.picked += 1", "moth"),
            ("world.tally.webbed += 1", "moth"),
            // the shop
            ("world.shop.spider += 1", "an upgrade that was not paid for"),
            ("world.tally.spent += 5", "an upgrade that was not paid for"),
            ("world.shop.spawn += 1; world.tally.spent += 10; world.tally.gained += 1000", "moths gained that the catches do not account for"),
            ("world.shop.web = 20000", "more upgrades than can be counted"),
            // the edge and the web
            ("world.edge.inset = 0", "the edge not where it is fixed"),
            ("world.web.made += 5", "web"),
            ("world.web.made -= 1", "web"),
            ("world.web.level = 3", "a web of a size it cannot be"),
            ("world.web.x += 50", "the web moved or changed size"),
            ("world.web.on = false", "web"),
            ("world.web.old = true", "a web that cannot be"),
            ("world.web.age += 30", "the web older than the time played allows"),
            ("world.web.torn = '7'", "a strand broken with no moth taken from it"),
            ("world.tally.webs += 1", "a web counted as finished that was not"),
            // the spider
            ("spider.body.x += 150", "a foot further from the body than a leg can reach"),
            ("spider.body.x += 30; spider.legs[*].x += 30", "the spider moving faster than it can walk"),
            ("spider.body.x = -500", "the spider outside the game area"),
            ("spider.body.food = 1", "the food meter not what eating and time make it"),
            ("spider.body.food -= 0.3", "the food meter not what eating and time make it"),
            ("spider.body.food = 7", "the food meter past one of its ends"),
            ("spider.body.age += 100", "the spider's size not matching its age"),
            ("spider.body.age = 400", "the spider older than a spider gets"),
            ("spider.body.size += 5", "the spider's size not matching its age"),
            ("spider.body.boost = 0.3", "a boost that the old spiders eaten do not account for"),
            ("spider.body.boost = 3", "a boost greater than a spider can have"),
            ("spider.body.gen += 1", "a spider dying before its time"),
            ("spider.body.gen += 5", "more than one spider coming"),
            ("spider.body.husks += 1", "more old spiders eaten than have died"),
            ("spider.body.meals += 30", "the spider fed on moths it did not catch"),
            ("spider.body.eaten += 1", "the moths caught not the moths the spider ate and the pointer picked"),
            ("spider.body.grip = 8; spider.body.state = 'panic'", "the spider held with no pointer holding it"),
            ("spider.body.grip = 3", "the spider held and not held at once"),
            ("spider.body.state = 'recovering'", "the spider getting over a holding that never was"),
            ("spider.body.state = 'dead'", "the spider in a state it does not have"),
            ("spider.legs[3].x += 500", "a foot further from the body than a leg can reach"),
            ("spider.old.on = true", "an old spider that cannot be"),
            ("spider.old.meals = 50", "the old spider changed where it lies"),
            ("world.tally.gained -= 100", "a count gone backwards"),
        ] {
            undone(&base, line, names);
        }
        // An upgrade with its price paid, out of moths that are there, but which nobody asked for.
        undone(&with_moths(&base, 1000.0), "world.shop.spawn += 1; world.tally.spent += 10", "an upgrade bought that was not asked for");
        // A moth that is halted in the web, moved a little.
        let base = webbed();
        let k = base.0.world.moths.iter().position(|m| base.0.ring[MOTHS].held.split(',').any(|h| h == Val::Num(m.id).written())).unwrap();
        undone(&base, &format!("world.moths[{}].x += 1", k), "a moth halted in the web that moved");
        // A spider that is being carried, let go of by the state alone.
        undone(&carried(), "spider.body.grip = -1; spider.body.state = 'resting'", "the spider not held by what the pointer has hold of");
        // An old spider eaten from the other side of the game area, and one moved where it lies.
        let (mut inside, mut now) = handing();
        while outside(&inside) {
            play(&mut inside, &mut now, 1);
        }
        assert!(inside.spider.old.on);
        undone(&(inside, now), "spider.old.on = false; spider.body.husks += 1", "an old spider eaten that was not reached");
        undone(&handing(), "spider.old.on = false; spider.body.husks += 1", "the spider outside the game area");
        undone(&handing(), "spider.old.x += 10", "the old spider changed where it lies");
        let misnamed = MISNAMED.lock().unwrap();
        assert!(misnamed.is_empty(), "found, but for another reason than the one looked for:
{}", misnamed.join("
"));
    }
    #[test]
    fn a_wrong_step_that_breaks_no_rule_is_found_by_doing_the_work_twice() {
        // None of these breaks a rule of the game: the rules do not say when a rest ends, which way
        // the spider faces or goes, where its feet are, where a moth is making for, or where the
        // spider must be for its web to grow. Each steers the game. The gate does the round's work
        // a second time from its own record, gets another result, and the round is undone.
        let base = fed();
        assert!(base.0.spider.body.full && base.0.world.web.tied && !base.0.world.moths.is_empty(), "{:?}", base.0.spider.body);
        for (line, part) in [
            ("spider.body.until += 5", "the body"),
            ("spider.body.full = false", "the body"),
            ("spider.body.h += 1", "the body"),
            ("spider.body.tx = 100; spider.body.ty = 100", "the body"),
            ("spider.body.phase += 0.5", "the body"),
            ("spider.legs[*].x += 20", "the first set of legs, the second set of legs"),
            ("spider.legs[3].y -= 1", "the second set of legs"),
            ("world.moths[0].wx = 600; world.moths[0].wy = 400", "the moths, counts and shop"),
            ("world.web.made += 1", "the web"),
            ("world.web.tied = false", "the web"),
            ("spider.body.until += 5; world.web.made += 1", "the body, the web"),
        ] {
            let (mut game, mut now) = base.clone();
            let (before, own) = (all(&game), game.own.clone());
            assert!(backdoor::run(&mut game, &format!("during {}", line)).starts_with("to be written during"), "{}", line);
            play(&mut game, &mut now, 1);
            assert_eq!(game.why(), format!("the gate did the work of the round a second time, from its own record, and it came out another way in {}", part), "{}", line);
            while game.halted() {
                play(&mut game, &mut now, 1);
            }
            // the round is undone, and with it everything the game keeps for itself: chance, when the next moth is due, what a screen was to be told
            assert_eq!(all(&game), before, "{}: the round was not undone", line);
            assert!(game.own == own, "{}: what the game keeps for itself was not put back", line);
            assert_eq!((game.halts, game.restarts, game.passed), (1, 1, 0), "{}", line);
            play(&mut game, &mut now, 300);
            assert_eq!(game.halts, 1, "{}: halted again afterwards: {}", line, game.why());
        }
        // The one thing that is let through is a line that, by the time it is written, changes
        // nothing: here the spider's age is set to exactly what the round's work makes it.
        let (mut game, mut now) = fresh();
        let next = game.spider.body.age + STEP / 1000.0;
        assert!(backdoor::run(&mut game, &format!("during spider.body.age = {}", next)).starts_with("to be written during"));
        play(&mut game, &mut now, 2);
        assert!(!game.halted() && game.passed == 1 && game.halts == 0, "{}", game.why());
        assert!(game.shown(now).ends_with(&format!("\"passed\":1,\"let\":\"spider.body.age = {}\",\"unwritten\":0,\"not\":null}}", next)));
        // An observer has no part in the work. One that is changed while a round is worked is found by the gate,
        // which looks at the observers again before it records anything. The round is undone, and nothing is said to have been let through.
        for (line, what) in [
            ("spider.ring[0].alive = false", "the legs A observer stopped"),
            ("spider.ring[0].copies[0] = 'not the legs'", "the copies of the legs A observer changed"),
            ("world.ring[1].held = '1,2,3'", "the list of halted moths of the moths observer changed"),
            ("spider.ring[1].beat = 7", "the legs B observer silent"),
            ("world.ring[4].flagged = true", "the page observer with a flag up"),
            ("world.ring[0].name = 'nobody'", "the edge observer changed"),
        ] {
            let (mut game, mut now) = fresh();
            let before = all(&game);
            assert!(backdoor::run(&mut game, &format!("during {}", line)).starts_with("to be written during"), "{}", line);
            play(&mut game, &mut now, 1);
            assert_eq!(game.why(), format!("the gate found {} while the round was being worked", what), "{}", line);
            while game.halted() {
                play(&mut game, &mut now, 1);
            }
            assert!(all(&game) == before && (game.halts, game.restarts, game.passed) == (1, 1, 0) && whole(&game), "{}: {}", line, game.why());
            play(&mut game, &mut now, 300);
            assert_eq!(game.halts, 1, "{}: halted again afterwards: {}", line, game.why());
        }
    }
    #[test]
    fn a_line_waiting_when_a_halt_comes_is_put_aside() {
        // A line said to be written during the next round's work, and then, before that round, a change from
        // outside. The round halts before any work, so there is no work for the line to be written during.
        // It is not kept for later: it is put aside, and that is said when the halt is put right.
        for how in [How::AfterAPause, How::OnAClick, How::AtOnce] {
            let (mut game, mut now) = fresh();
            game.set_how(how);
            let caught = game.world.tally.caught;
            assert!(backdoor::run(&mut game, "during world.tally.caught += 5").starts_with("to be written during"));
            backdoor::run(&mut game, "spider.body.x += 150");
            play(&mut game, &mut now, 1);
            assert!(game.inside.is_empty() && game.halts == 1, "{:?}", how);
            game.put_right();
            play(&mut game, &mut now, 120);
            assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && game.world.tally.caught - caught < 5.0, "{:?}: {}", how, game.why());
            let did = &game.fixed.as_ref().unwrap().0;
            assert!(did.contains("the body put back") && did.contains("what was waiting to be written during the work put aside"), "{:?}: {}", how, did);
        }
        // A halt with nothing waiting says nothing of the kind.
        let (mut game, mut now) = fresh();
        backdoor::run(&mut game, "spider.body.x += 150");
        play(&mut game, &mut now, 120);
        assert_eq!(game.fixed.as_ref().unwrap().0, "the body put back, all eight observers started again");
    }
    #[test]
    fn a_line_at_the_backdoor_and_its_answer_have_a_size() {
        let (mut game, _) = fresh();
        let (before, moths) = (all(&game), game.world.moths.len());
        // More things in one line than are taken at once: nothing of it is done, now or during the work.
        let many = "world.tally.caught += 1;".repeat(33);
        assert!(backdoor::run(&mut game, &many).ends_with("no more than 32 are taken at once: nothing was done"));
        assert!(backdoor::run(&mut game, &format!("during {}", many)).ends_with("no more than 32 are taken at once: nothing was done"));
        assert!(all(&game) == before && game.inside.is_empty());
        // Thirty-two are taken.
        assert_eq!(backdoor::run(&mut game, &"world.tally.caught;".repeat(32)).lines().count(), 32);
        // An answer has a length. Reading everything over and over stops when enough has been said, and says so.
        let one = backdoor::run(&mut game, "world").len() + backdoor::run(&mut game, "spider").len();
        let said = backdoor::run(&mut game, &"world;spider;".repeat(16));
        assert!(said.len() < 64_000 + 200 && said.len() < 16 * one && said.ends_with("of that line were not done"), "{} said, {} for one of each", said.len(), one);
        assert!(said.contains("... and no more of this is said: there is too much to say\nthere is too much to say already: the last "), "the answer that went past what may be said was not cut");
        // One answer that is by itself more than may be said is cut too.
        backdoor::run(&mut game, &format!("spider.ring[*].why = \"{}\"; world.ring[*].why = \"{}\"; spider.ring[*].name = \"{}\"; world.ring[*].name = \"{}\"", "\u{1}".repeat(1024), "\u{1}".repeat(1024), "\u{1}".repeat(1024), "\u{1}".repeat(1024)));
        let everything = backdoor::run(&mut game, "spider.ring; world.ring");
        assert!(everything.len() < 64_000 + 200 && everything.contains("... and no more of this is said"), "{} said", everything.len());
        let (mut game, mut now) = fresh();
        // Moths put in from the backdoor: where there are 64, no more, however often it is asked and whether or not everything is halted.
        game.set_how(How::OnAClick);
        for _ in 0..50 {
            backdoor::run(&mut game, &"world.moths.push();".repeat(32));
        }
        assert_eq!(game.world.moths.len(), 64);
        assert!(backdoor::run(&mut game, "world.moths.push()").ends_with("no more are put in from here"));
        play(&mut game, &mut now, 1);
        assert!(game.halted());
        for _ in 0..50 {
            backdoor::run(&mut game, &"world.moths.push();".repeat(32));
        }
        assert_eq!(game.world.moths.len(), 64);
        game.put_right();
        play(&mut game, &mut now, 2);
        assert!(!game.halted() && game.world.moths.len() <= moths + 1 && (game.halts, game.restarts) == (1, 1), "{}", game.why());
    }
    #[test]
    fn a_game_put_aside_whole_waits_to_be_begun_again() {
        // The game is put aside whole, as it is when the program has stopped where it should not have twice
        // running. What stands in its place is a game not yet begun, halted, which the rounds leave as it is until it is asked for.
        let (mut game, mut now) = webbed();
        game.set_how(How::AtOnce);
        let (halts, restarts) = (game.halts, game.restarts);
        game.fail("the game's own work stopped where it should not have", now);
        assert!(game.halted() && game.shown(now).contains("\"stuck\":true") && game.why() == "the game's own work stopped where it should not have");
        assert!(game.shown(now).contains("\"why\":\"the game's own work stopped where it should not have\""));
        assert!((game.halts, game.restarts) == (halts + 1, restarts) && game.how == How::AtOnce && game.world.moths.is_empty() && game.spider.body.gen == 1.0);
        let before = (all(&game), game.rounds, game.ring.iter().map(|o| o.written()).collect::<Vec<_>>());
        play(&mut game, &mut now, 600);
        assert!(game.halted() && before == (all(&game), game.rounds, game.ring.iter().map(|o| o.written()).collect::<Vec<_>>()) && game.shown(now).contains("\"games\":1,"));
        // Asked for, the game is begun, and it plays.
        game.put_right();
        play(&mut game, &mut now, 1);
        assert!(!game.halted() && game.shown(now).contains("\"games\":2,") && game.halts == 0 && game.how == How::AtOnce);
        play(&mut game, &mut now, 3600);
        assert!(game.halts == 0 && game.world.tally.caught > 0.0, "{}", game.why());
    }
    #[test]
    fn a_game_put_aside_while_the_clock_cannot_be_read_begins_at_nought() {
        // The game is put aside whole at a moment when the machine's clock cannot be read. The game that
        // waits to be begun has nought for its time and for its note of the clock, and not something
        // that is no number. Rounds in which the clock still cannot be read go by. Once the game is asked
        // for it is begun, and it plays.
        let (mut game, _) = webbed();
        game.fail("the game's own work stopped where it should not have", f64::NAN);
        assert!(game.stuck() && game.time == 0.0 && game.at == 0.0, "its time is {}, and its note of the clock {}", game.time, game.at);
        for _ in 0..10 {
            game.round_at(f64::NAN);
        }
        assert!(game.stuck() && game.time.is_finite() && game.at == 0.0, "its time is {}, and its note of the clock {}", game.time, game.at);
        game.put_right();
        let mut clock = 5000.0;
        for _ in 0..7200 {
            clock += STEP;
            game.round_at(clock);
        }
        assert!(!game.halted() && game.halts == 0 && game.games == 2 && game.time.is_finite() && game.world.tally.caught > 0.0, "{}", game.why());
    }
    #[test]
    fn a_finding_of_any_length_is_cut_where_it_is_taken() {
        // One observer's thread answers with a finding three million characters long. It is a halt like any
        // other, put right, and what is kept of the finding, and what a screen is sent of it, is no
        // longer than the longest thing said here.
        let most = MOST_TOLD + 3;
        for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
            let (mut game, mut now) = webbed();
            game.set_how(how);
            let apart = patient();
            game.run_apart(apart.clone());
            play(&mut game, &mut now, 30);
            assert_eq!(game.halts, 0, "{:?}: {}", how, game.why());
            let usual = game.shown(now).len();
            apart.say(2, "x".repeat(3_000_000));
            play(&mut game, &mut now, 1);
            assert!(game.halts == 1 && game.why.as_ref().map_or(false, |why| why.starts_with("xxx") && why.chars().count() <= most), "{:?}: the halt's reason is not the finding cut short", how);
            assert!(game.ring.iter().all(|o| o.why.chars().count() <= most) && game.shown(now).len() < usual + 2000, "{:?}: what is kept or sent is too long", how);
            game.put_right();
            play(&mut game, &mut now, 120);
            assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && game.shown(now).len() < usual + 2000, "{:?}", how);
        }
        // The same where the reason is already in an observer when a round begins.
        let (mut game, mut now) = webbed();
        game.ring[2].flagged = true;
        game.ring[2].why = "y".repeat(3_000_000);
        let usual = game.shown(now).len();
        play(&mut game, &mut now, 1);
        assert!(game.halts == 1 && game.why.as_ref().map_or(false, |why| why.starts_with("yyy") && why.chars().count() <= most), "the halt's reason is not the reason cut short");
        game.put_right();
        play(&mut game, &mut now, 120);
        assert!(!game.halted() && game.shown(now).len() < usual + 2000);
        // And at the second asking of a round, of the eight new observers when a halt is put right. One
        // observer stops answering, and one of the eight new ones answers with such a finding: a second
        // fault in the same halt, so the halt cannot be put right, and its reason is cut the same way.
        let (mut game, mut now) = webbed();
        game.set_how(How::AtOnce);
        let apart = patient();
        game.run_apart(apart.clone());
        play(&mut game, &mut now, 30);
        let usual = game.shown(now).len();
        apart.say_next(5, "z".repeat(3_000_000));
        apart.stall(2);
        play(&mut game, &mut now, 1);
        let begins = "it could not be put right: ";
        assert!(game.stuck() && game.why.as_ref().map_or(false, |why| why.starts_with(&format!("{}zzz", begins)) && why.chars().count() <= begins.len() + most), "the reason of the halt that cannot be put right is not the finding cut short");
        assert!(game.shown(now).len() < usual + 2000, "what a screen is sent is too long");
    }
    #[test]
    fn what_a_screen_is_sent_has_a_size_whatever_a_fault_makes_long() {
        // One thing in the game is made three million characters long, or a hundred thousand in number,
        // with halts set to end on a click, so that the halt lasts. What a screen is sent in every round
        // of that halt stays within a fixed size, and when the halt has ended it is as it was.
        let faults: [(&str, fn(&mut Game)); 9] = [
            ("the moths observer's list of halted moths", |game| game.ring[MOTHS].held = "7,".repeat(1_500_000)),
            ("what the body is doing", |game| game.spider.body.state = "x".repeat(3_000_000)),
            ("the web's torn strands", |game| game.world.web.torn = "7,".repeat(1_500_000)),
            ("one observer's copies", |game| game.ring[1].copies.extend(vec!["x".repeat(30); 100_000])),
            ("one observer's copy", |game| game.ring[1].copies[0] = "x".repeat(3_000_000)),
            ("the legs", |game| game.spider.legs = vec![game.spider.legs[0].clone(); 100_000]),
            ("the moths", |game| game.world.moths = vec![game.world.moths[0].clone(); 100_000]),
            ("the observers", |game| game.ring = vec![game.ring[0].clone(); 100_000]),
            ("the catches of the last second", |game| game.own.gains = vec![crate::game::Gain { n: 1.0, x: 1.0, y: 1.0, worth: 1.0, at: game.time }; 100_000]),
        ];
        for (what, fault) in faults {
            let (mut game, mut now) = webbed();
            game.set_how(How::OnAClick);
            let usual = game.shown(now).len();
            fault(&mut game);
            // as it is sent before the next round, with the fault there and nothing yet found
            let sent = game.shown(now).len();
            assert!(sent < usual + 400_000, "{}: {} characters to a screen before it was found, and {} before", what, sent, usual);
            for _ in 0..5 {
                play(&mut game, &mut now, 1);
                let sent = game.shown(now).len();
                assert!(game.halted() && !game.stuck() && sent < usual + 400_000, "{}: {} characters to a screen in the halt, and {} before", what, sent, usual);
            }
            game.put_right();
            play(&mut game, &mut now, 3);
            assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && game.shown(now).len() < usual + 2000, "{}: {}", what, game.why());
        }
        // What is cut for a screen is cut between two characters, before it is written out, and marked as cut.
        let long: String = "\u{e9}\"\\\u{1}".chars().cycle().take(3000).collect();
        let (mut body, mut cut) = (webbed().0.spider.body.clone(), webbed().0.spider.body.clone());
        body.state = long.clone();
        cut.state = short(&long, MOST_SENT);
        assert!(cut.state.chars().count() == MOST_SENT + 3 && cut.state.ends_with("..."));
        assert!(body.sent(MOST_SENT) == cut.written() && body.sent(usize::MAX) == body.written(), "a text of a part is not cut as a text is cut");
        // The list of halted moths is sent at more length than 1,024 characters: one of 1,400 goes whole.
        let (mut game, now) = webbed();
        game.ring[MOTHS].held = "7,".repeat(700);
        assert!(game.shown(now).contains(&format!("\"halted\":\"{}\"", "7,".repeat(700))), "a list of halted moths of 1,400 characters was cut");
        // And one of 20,600 characters is sent as its first 20,480, marked as cut.
        let long = "7,".repeat(10_300);
        game.ring[MOTHS].held = long.clone();
        assert!(game.shown(now).contains(&format!("\"halted\":\"{}...\"", &long[..20_480])), "a list of halted moths of 20,600 characters was not cut at 20,480");
        // The work reads no more of that list than that, whatever its length.
        game.ring[MOTHS].held = ",".repeat(32_000_000);
        assert_eq!(game.halted_moths().len(), 20_480, "the work is handed more of the list of halted moths than its first 20,480 characters");
        // It is the first 20,480 bytes that are handed on, and not the last, and never part of a
        // character: one letter and ten thousand characters of three bytes each give the letter and
        // 6,826 of them.
        game.ring[MOTHS].held = format!("a{}", "\u{20ac}".repeat(10_000));
        assert_eq!(game.halted_moths(), format!("a{}", "\u{20ac}".repeat(6_826)), "the list of halted moths is not cut at its first 20,480 bytes, between two characters");
        // With more than MOST_HELD moths, nothing is said to be under the pointer.
        let (mut game, _) = webbed();
        let moth = game.world.moths.iter().find(|moth| pick(&game.spider, moth.x, moth.y).is_none()).cloned().expect("a moth that the spider is not standing on");
        game.ring[MOTHS].held = Val::Num(moth.id).written();
        game.own.pointer.x = moth.x;
        game.own.pointer.y = moth.y;
        game.own.pointer.inside = true;
        assert!(game.over().map_or(false, |over| over.3 == "moth"), "the pointer is not over the moth it was put on");
        game.world.moths = vec![moth.clone(); MOST_HELD];
        assert!(game.over().map_or(false, |over| over.3 == "moth"), "with MOST_HELD moths and no more, nothing is said to be under the pointer");
        game.world.moths = vec![moth.clone(); MOST_HELD + 1];
        assert!(game.over().is_none(), "with more than MOST_HELD moths, something is still said to be under the pointer");
        game.world.moths = vec![moth.clone(); MOST_HELD * 4];
        assert!(game.over().is_none(), "with four times MOST_HELD moths, something is still said to be under the pointer");
        // And not a leg either, though no moth would be looked up for it.
        game.own.pointer.x = game.spider.legs[0].x;
        game.own.pointer.y = game.spider.legs[0].y;
        game.world.moths = vec![moth.clone(); MOST_HELD];
        assert!(game.over().map_or(false, |over| over.3 == "leg"), "the pointer is not over the leg it was put on");
        game.world.moths = vec![moth.clone(); MOST_HELD + 1];
        assert!(game.over().is_none(), "with more than MOST_HELD moths, a leg is still said to be under the pointer");
        // A quote and a backslash are written with a backslash before them, and other characters as they are.
        assert_eq!(quote("a\"b\\c \u{7f}\u{e9}"), "\"a\\\"b\\\\c \u{7f}\u{e9}\"");
        let (mut game, now) = webbed();
        // Every control character is written out as it always was, and a text of sixteen million of
        // them in less than a second.
        for c in 0u8..0x20 {
            let written = match c {
                b'\n' => "\\n".to_string(),
                b'\r' => "\\r".to_string(),
                b'\t' => "\\t".to_string(),
                c => format!("\\u{:04x}", c),
            };
            assert_eq!(quote(&(c as char).to_string()), format!("\"{}\"", written));
        }
        let began = Instant::now();
        assert_eq!(quote(&"\u{1}".repeat(16_000_000)).len(), 96_000_002);
        assert!(began.elapsed() < Duration::from_secs(1), "sixteen million control characters took {:?} to write out", began.elapsed());
        // What the game says of itself is cut at 4,096 characters, in each thing it says.
        game.keep(|book| book.why = Some("w".repeat(10_000)));
        let sent = game.shown(now);
        assert!(sent.contains(&format!("\"why\":\"{}...\"", "w".repeat(4096))) && !sent.contains(&"w".repeat(4097)), "what the game says of itself was not cut at 4,096 characters");
        // an observer is a piece like any other, and is sent as it is shown: with its copies
        let observer = &webbed().0.ring[MOTHS];
        assert!(observer.sent(usize::MAX) == observer.written() && observer.sent(MOST_SENT).contains("\"copies\":["));
    }
    #[test]
    fn the_shop_has_no_more_of_an_upgrade_that_is_at_its_most() {
        // Two upgrades have a most: nineteen of the one for more moths, which is room for 48 moths in
        // all, and twenty-four of the one for appetite, which is 32 moths to fill a full-grown spider. With
        // moths enough for far more, each is asked for until long after the shop has none left. It is
        // bought that many times and no more, nothing is spent on what was not bought, and the shelf
        // has no price for it.
        let (mut game, mut now) = with_moths(&fresh(), 1_000_000.0);
        for _ in 0..12 {
            for _ in 0..4 {
                game.buy("spawn");
                game.buy("appetite");
            }
            play(&mut game, &mut now, 1);
        }
        assert_eq!(game.halts, 0, "{}", game.why());
        assert_eq!((game.world.shop.spawn, game.world.shop.appetite), (19.0, 24.0));
        let prices = |what: &str, bought: usize| (0..bought).map(|n| cost_of(what, n as f64).unwrap_or(f64::NAN)).sum::<f64>();
        assert_eq!(game.world.tally.spent, prices("spawn", 19) + prices("appetite", 24), "something was spent on what was not bought");
        let shelf = shelf_written(&game.world);
        assert!(shelf.contains("\"now\":\"33 a minute\",\"step\":\"+1\",\"cost\":null,\"can\":false"), "{}", shelf);
        assert!(shelf.contains("\"now\":\"26\u{2013}32 moths\",\"step\":\"+1\",\"cost\":null,\"can\":false"), "{}", shelf);
        assert_eq!(shelf.matches("\"can\":true").count(), 2, "the other two can no longer be bought: {}", shelf);
        // The other two have no most: one more of each is bought.
        game.buy("spider");
        game.buy("web");
        play(&mut game, &mut now, 1);
        assert_eq!((game.world.shop.spider, game.world.shop.web, game.halts), (1.0, 1.0, 0));
        // More of either than the shop has is not a state the game can be in. Each text of the rules
        // says so by itself, and one more written during a round's work is refused by them.
        let found = Some("more of an upgrade than the shop has");
        for more in [|world: &mut World| world.shop.spawn = 20.0, |world: &mut World| world.shop.appetite = 25.0] as [fn(&mut World); 2] {
            let mut world = game.world.clone();
            more(&mut world);
            assert_eq!((wrong_in(&game.spider, &world), rules::again::wrong_in(&game.spider, &world)), (found, found));
        }
        assert_eq!((wrong_in(&game.spider, &game.world), rules::again::wrong_in(&game.spider, &game.world)), (None, None));
        undone(&(game.clone(), now), "world.shop.spawn += 1", "more of an upgrade than the shop has");
        undone(&(game.clone(), now), "world.shop.appetite += 1", "more of an upgrade than the shop has");
        // And with every one of them bought there are never more than 48 moths, in ten minutes of the game.
        let mut most = 0;
        for _ in 0..36000 {
            play(&mut game, &mut now, 1);
            most = most.max(game.world.moths.len());
        }
        assert!(most <= 48 && most > 10 && game.halts == 0, "{} moths at the most: {}", most, game.why());
    }
    #[test]
    fn what_can_be_said_to_be_written_during_the_work() {
        let (mut game, mut now) = fresh();
        let before = all(&game);
        for (line, says) in [
            ("during", "say what is to be written during the work"),
            ("during during spider.body.x += 1", "say what is to be written during the work"),
            ("during spider.body.nothing = 1", "there is no nothing in spider.body"),
            ("during spider.body.x = 'left'", "holds a number, and that is fixed"),
            ("during spider.body.x += 1; spider.legs[9].x = 0", "there are only 8 legs"),
            ("during spider.body.x", "that writes nothing"),
            ("duringspider.body.x += 1", "there is no"),
        ] {
            let said = backdoor::run(&mut game, line);
            assert!(said.contains(says), "{} -> {}", line, said);
        }
        assert!(game.inside.is_empty() && all(&game) == before);
        play(&mut game, &mut now, 60);
        assert_eq!(game.halts, 0, "{}", game.why());
        // no more than eight lines wait at once, and they are all written in the one round
        for n in 0..9 {
            let said = backdoor::run(&mut game, "during spider.body.until += 1");
            assert_eq!(said.starts_with("to be written during"), n < 8, "{}", said);
        }
        play(&mut game, &mut now, 1);
        assert!(game.inside.is_empty() && game.halted() && game.halts == 1 && game.passed == 0, "{}", game.why());
        // while everything is halted there is no work for anything to be written during
        assert!(backdoor::run(&mut game, "during world.tally.caught += 5").starts_with("everything is halted"));
        assert!(game.inside.is_empty());
    }
    #[test]
    fn a_wrong_step_is_undone_under_each_way_a_halt_can_end() {
        for how in [How::AtOnce, How::AfterAPause, How::OnAClick] {
            let (mut game, mut now) = fresh();
            game.set_how(how);
            let before = all(&game);
            backdoor::run(&mut game, "during world.tally.caught += 5; world.tally.gained += 500");
            play(&mut game, &mut now, 1);
            assert!(game.halted(), "{:?}", how);
            match how {
                How::AtOnce => play(&mut game, &mut now, 1),
                How::AfterAPause => play(&mut game, &mut now, 40),
                How::OnAClick => {
                    play(&mut game, &mut now, 120);
                    assert!(game.halted() && all(&game) != before);
                    game.put_right();
                    play(&mut game, &mut now, 1);
                }
            }
            assert!(!game.halted() && (game.halts, game.restarts) == (1, 1), "{:?}: {}", how, game.why());
            assert!(game.world.tally.caught < 5.0 || all(&game) == before, "{:?}", how);
            play(&mut game, &mut now, 300);
            assert_eq!(game.halts, 1, "{:?}: {}", how, game.why());
        }
    }
    #[test]
    fn work_that_goes_wrong_twice_running_cannot_go_on() {
        // A fault in the work itself, the same in every round: the first time the round is undone, and the second the game cannot go on.
        let (mut game, mut now) = fresh();
        let before = all(&game);
        game.fault = Some(|game| game.world.tally.caught += 5.0);
        play(&mut game, &mut now, 1);
        assert!(game.halted() && !game.shown(now).contains("\"stuck\":true"));
        let mut rounds = 0;
        while !game.shown(now).contains("\"stuck\":true") {
            play(&mut game, &mut now, 1);
            rounds += 1;
            assert!(rounds < 200, "after three seconds it was not stopped: {}", game.why());
        }
        assert!(game.why().starts_with("twice running, the gate found a step of the work that the rules of the game do not allow"), "{}", game.why());
        assert_eq!((game.halts, game.restarts), (2, 1));
        // time does not put that right, and the state is as the last good round left it, with nothing of the wrong rounds kept
        play(&mut game, &mut now, 600);
        assert!(game.halted() && game.restarts == 1 && game.shown(now).contains("\"games\":1,"));
        assert_eq!(all(&game), before);
        // Asked to put it right, the game is begun again: a new game, with nothing of the old one but how a halt ends.
        game.set_how(How::OnAClick);
        game.put_right();
        play(&mut game, &mut now, 1);
        let (new, body, tally) = (Game::new(now, 1), &game.spider.body, &game.world.tally);
        assert!(!game.halted() && (game.halts, game.restarts, game.passed) == (0, 0, 0) && game.how == How::OnAClick, "{}", game.why());
        assert!(game.shown(now).contains("\"games\":2,") && game.shown(now).contains("\"why\":null,\"did\":null"));
        // in everything but chance: each game is given its own
        assert_eq!(game.texts()[..OWN], new.texts()[..OWN], "it is not a new game");
        assert!(game.own.buys.is_empty() && game.own.clicks.is_empty() && game.own.gains.is_empty() && game.own.next_id == 0.0 && game.asks.is_empty() && game.asks_again.is_empty());
        assert!(body.gen == 1.0 && body.age == 0.0 && tally.caught == 0.0 && tally.gained == 0.0 && game.world.moths.is_empty() && !game.world.web.on);
        assert!(whole(&game) && game.inside.is_empty() && game.own.grab.is_none());
        // and it plays on, with the fault that stopped the old one gone
        play(&mut game, &mut now, 3600);
        assert!(game.halts == 0 && game.world.tally.caught > 0.0 && game.world.web.on, "{}", game.why());
        // asking when the halt is one that can be put right does that, and begins nothing again
        backdoor::run(&mut game, "spider.body.x += 150");
        play(&mut game, &mut now, 1);
        let caught = game.world.tally.caught;
        game.put_right();
        play(&mut game, &mut now, 1);
        assert!(!game.halted() && game.world.tally.caught == caught && game.shown(now).contains("\"games\":2,"));
    }
    #[test]
    fn beginning_again_is_asked_for_after_the_halt_that_needs_it() {
        // A halt waiting on a click is asked to be put right. If it then cannot be, that click
        // was not a click to begin the game again: it takes another.
        let (mut game, mut now) = fresh();
        game.set_how(How::OnAClick);
        backdoor::run(&mut game, "spider.body.x += 150");
        play(&mut game, &mut now, 1);
        game.put_right();
        game.stick("it could not be put right: the body".to_string());
        play(&mut game, &mut now, 600);
        assert!(game.halted() && game.shown(now).contains("\"stuck\":true") && game.shown(now).contains("\"games\":1,"));
        game.put_right();
        play(&mut game, &mut now, 1);
        assert!(!game.halted() && game.shown(now).contains("\"games\":2,"));
    }
    #[test]
    fn a_record_changed_in_both_halves_to_agree_outranks_the_state() {
        // With a value that no rule forbids, the game halts once, and then goes on with that value.
        let (mut game, mut now) = fresh();
        let gained = game.world.tally.gained;
        game.record.world.tally.gained += 100000.0;
        game.record.texts[4] = snap(&game.record.spider, &game.record.world, 4);
        play(&mut game, &mut now, 1);
        assert_eq!(game.why(), "the gate found the moths, counts and shop changed, and no observer had flagged it");
        play(&mut game, &mut now, 600);
        assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && game.world.tally.gained >= gained + 100000.0, "{}", game.why());
        // With a value the rules do forbid, the game cannot go on with it.
        // The gate's record of the body changed in both its halves, so that they agree: two faults in one round.
        // The state and all eight observers are as they were. A record that agrees with itself outranks them.
        let (mut game, mut now) = fresh();
        game.record.spider.body.x += 150.0;
        game.record.texts[2] = snap(&game.record.spider, &game.record.world, 2);
        play(&mut game, &mut now, 1);
        // It is found: the state no longer matches the record. No observer flags, for they all agree with the state.
        assert_eq!(game.why(), "the gate found the body changed, and no observer had flagged it");
        // It is put right the wrong way round, to the faulty record. The rules then find a spider that
        // cannot be, twice running, and the game is stopped until it is begun again.
        let mut rounds = 0;
        while !game.shown(now).contains("\"stuck\":true") {
            play(&mut game, &mut now, 1);
            rounds += 1;
            assert!(rounds < 300, "after five seconds it was not stopped: {}", game.why());
        }
        assert!(game.why().ends_with("a foot further from the body than a leg can reach"), "{}", game.why());
        game.put_right();
        play(&mut game, &mut now, 600);
        assert!(!game.halted() && game.halts == 0 && game.shown(now).contains("\"games\":2,"), "{}", game.why());
    }
    #[test]
    fn the_shop_sells_what_can_be_paid_for() {
        // The first of each costs what it is priced at, and the next one more.
        for (what, first, second) in [("spawn", 10.0, 12.0), ("appetite", 12.0, 14.0), ("spider", 12.0, 13.0), ("web", 10.0, 11.0)] {
            assert_eq!((cost_of(what, 0.0), cost_of(what, 1.0)), (Some(first), Some(second)), "{}", what);
            let (mut game, mut now) = with_moths(&fresh(), first + 1.0);
            let (had, spent) = (purse(&game.world.tally), game.world.tally.spent);
            game.buy(what);
            play(&mut game, &mut now, 1);
            assert_eq!((level_of(&game, what), game.world.tally.spent - spent), (1.0, first), "{}", what);
            assert!(purse(&game.world.tally) <= had - 100.0 * first + 250.0, "{}: the moths were not paid", what);
            // there are not moths enough for the next one, so asking for it does nothing
            game.buy(what);
            play(&mut game, &mut now, 1);
            assert_eq!((level_of(&game, what), game.world.tally.spent - spent), (1.0, first), "{}: sold for less than its price", what);
            assert_eq!(game.halts, 0);
        }
        // Nothing but the four things on the shelf can be asked for, and no more than eight at a time.
        let (mut game, mut now) = with_moths(&fresh(), 100000.0);
        for what in ["luck", "", "spawn; world.shop.web = 9", "SPAWN", "tally"] {
            game.buy(what);
        }
        assert!(game.asks.is_empty() && game.asks_again.is_empty());
        for _ in 0..20 {
            game.buy(" spawn\n");
        }
        assert!(game.asks == vec![Ask::Buy("spawn"); 8] && game.asks_again == game.asks && game.own.buys.is_empty());
        play(&mut game, &mut now, 1);
        assert_eq!(game.world.shop.spawn, 8.0);
        // More moths: more of them a minute, and room for more.
        play(&mut game, &mut now, 3600);
        assert!(game.world.moths.len() > 10, "{} moths with eight bought", game.world.moths.len());
        assert_eq!(game.halts, 0, "{}", game.why());
        // Appetite: one more moth to fill the meter for each.
        let (mut game, mut now) = with_moths(&fresh(), 100.0);
        let holds = stomach(&game.world.shop, &game.spider.body);
        game.buy("appetite");
        game.buy("appetite");
        play(&mut game, &mut now, 1);
        assert_eq!(stomach(&game.world.shop, &game.spider.body), holds + 2.0);
        // Moths written in from outside buy nothing: the write is found before any work is done, and what was asked for then is not kept.
        for how in [How::AfterAPause, How::AtOnce] {
            let (mut game, mut now) = fresh();
            game.set_how(how);
            let had = game.world.tally.gained;
            backdoor::run(&mut game, "world.tally.gained = 1000000");
            game.buy("spider");
            play(&mut game, &mut now, 1);
            game.buy("spider");
            play(&mut game, &mut now, 120);
            assert!(!game.halted() && game.halts == 1, "{:?}", how);
            assert!(had < 1200.0 && game.world.tally.gained < 100000.0, "the game had {} to begin with and has {} now", had, game.world.tally.gained);
            assert_eq!((game.world.shop.spider, game.world.tally.spent), (0.0, 0.0), "{:?}: bought with moths that were written in", how);
        }
    }
    #[test]
    fn a_catch_is_worth_what_the_multipliers_make_it() {
        // With nothing bought, every moth caught is worth one moth.
        let (game, _) = webbed();
        assert_eq!(game.world.tally.gained, 100.0 * game.world.tally.caught);
        // With the spider's multiplier at x1.5 and the web's at x1.3: a moth the spider catches is worth 1.5,
        // one the pointer picks out of the web 1.3, and one the spider eats in its web 1.95.
        let (mut game, mut now) = webbed();
        game.world.shop.spider = 5.0;
        game.world.shop.web = 3.0;
        // bought and paid for: what was spent is their prices, out of moths gained
        let paid: f64 = (0..5).map(|n| cost_of("spider", n as f64).unwrap()).sum::<f64>() + (0..3).map(|n| cost_of("web", n as f64).unwrap()).sum::<f64>();
        game.world.tally.spent += paid;
        game.world.tally.gained += 100.0 * paid;
        game.settle();
        let (was, mut rounds) = (game.world.tally.clone(), 0);
        let of = |tally: &crate::game::Tally| (tally.caught - tally.picked - tally.webbed, tally.picked, tally.webbed);
        while rounds < 72000 && { let (plain, picked, webbed) = of(&game.world.tally); let (a, b, c) = of(&was); plain - a < 3.0 || picked - b < 3.0 || webbed - c < 3.0 } {
            rounds += 1;
            if rounds % 900 == 0 {
                // now and then the pointer takes a moth that is halted in the web
                let held = game.ring[MOTHS].held.clone();
                if let Some(moth) = game.world.moths.iter().find(|m| held.split(',').any(|h| h == Val::Num(m.id).written())) {
                    let (x, y) = (moth.x, moth.y);
                    game.press(x, y, now);
                    game.release();
                }
            }
            play(&mut game, &mut now, 1);
        }
        let ((plain, picked, webbed), (a, b, c)) = (of(&game.world.tally), of(&was));
        assert!(plain - a >= 3.0 && picked - b >= 3.0 && webbed - c >= 3.0, "in twenty minutes: {} caught by the spider, {} picked, {} eaten in the web", plain - a, picked - b, webbed - c);
        assert_eq!(game.world.tally.gained - was.gained, 150.0 * (plain - a) + 130.0 * (picked - b) + 195.0 * (webbed - c));
        assert_eq!(game.halts, 0, "{}", game.why());
        // each catch is told to a screen once, with what it was worth, and the last minute's are added up
        let sent = game.shown(now);
        let minute: f64 = game.own.gains.iter().map(|gain| gain.worth).sum();
        assert!(game.own.gains.iter().all(|gain| now - gain.at <= 60000.0 + STEP && [150.0, 130.0, 195.0].contains(&gain.worth)));
        assert!(sent.contains(&format!("\"rate\":{}", (minute / 100.0).round())), "{}", &sent[sent.len() - 300..]);
    }
    #[test]
    fn what_a_screen_is_sent() {
        let (mut game, mut now) = webbed();
        let sent = game.shown(now);
        for piece in ["\"how\":\"after a pause\"", "\"why\":null", "\"did\":null", "\"halt\":null", "\"halts\":0", "{\"name\":\"web\",\"state\":\"ok\",\"row\":1,\"at\":\"world.ring[2]\"}", "{\"name\":\"whole\",\"state\":\"ok\",\"row\":0,\"at\":\"spider.ring[3]\"}"] {
            assert!(sent.contains(piece), "{} is not in {}", piece, sent);
        }
        for piece in ["\"shelf\":[{\"what\":\"spawn\",\"name\":\"More moths\",\"now\":\"14 a minute\",\"step\":\"+1\",\"cost\":10,\"can\":", "{\"what\":\"web\",\"name\":\"Web multiplier\",\"now\":\"x1.0\",\"step\":\"+0.1\",\"cost\":10,\"can\":", "\"name\":\"Spider appetite\",\"now\":\"2–8 moths\"", "\"gains\":[", "\"life\":300,\"over\":null,\"holding\":false,\"passed\":0,\"let\":null,\"unwritten\":0,\"not\":null}", "\"spider\":{\"body\":{\"x\":", ",\"old\":{\"on\":false,\"x\":0,"] {
            assert!(sent.contains(piece), "{} is not in {}", piece, &sent[sent.len() - 700..]);
        }
        let reach = web_reach(&game.world.edge, &game.world.web);
        assert!(reach > 90.0 && sent.contains(&format!("\"halted\":{}", quote(&game.ring[MOTHS].held))) && sent.contains(&format!("\"reach\":{}", reach)), "{}", sent);
        game.set_how(How::AtOnce);
        backdoor::run(&mut game, "world.web.made = 3");
        play(&mut game, &mut now, 1);
        let sent = game.shown(now);
        for piece in ["\"how\":\"at once\"", "\"why\":\"the whole observer found the web changed\"", "\"did\":\"the web put back, all eight observers started again\"", "\"halt\":null", "\"halts\":1,\"restarts\":1"] {
            assert!(sent.contains(piece), "{} is not in {}", piece, sent);
        }
    }
    #[test]
    fn a_screen_is_told_what_the_pointer_is_over() {
        // Where the pointer is reaches the game in the next round's work, and a screen is told after that.
        let (mut game, mut now) = fresh();
        // over the body, over a foot, and over nothing
        let (x, y) = (game.spider.body.x, game.spider.body.y);
        game.point(x, y, true, now);
        assert!(game.shown(now).contains("\"over\":null,\"holding\":false,"), "it was told before the round");
        play(&mut game, &mut now, 1);
        let body = game.spider.body.clone();
        assert!(game.shown(now).contains(&format!("\"over\":{{\"x\":{},\"y\":{},\"r\":{},\"what\":\"body\"}},\"holding\":false,", body.x, body.y, body.size * 0.6)), "{}", &game.shown(now)[game.shown(now).len() - 120..]);
        let down = game.spider.legs.iter().position(|leg| !leg.up).unwrap();
        game.point(game.spider.legs[down].x + 2.0, game.spider.legs[down].y, true, now);
        play(&mut game, &mut now, 1);
        let (fx, fy) = (game.spider.legs[down].x, game.spider.legs[down].y);
        assert!(game.shown(now).contains(&format!("\"over\":{{\"x\":{},\"y\":{},\"r\":8,\"what\":\"leg\"}},\"holding\":false,", fx, fy)), "{}", &game.shown(now)[game.shown(now).len() - 120..]);
        game.point(30.0, 30.0, true, now);
        play(&mut game, &mut now, 1);
        assert!(game.shown(now).contains("\"over\":null,\"holding\":false,"));
        // not over the game area at all
        let (x, y) = (game.spider.body.x, game.spider.body.y);
        game.point(x, y, false, now);
        play(&mut game, &mut now, 1);
        assert!(game.shown(now).contains("\"over\":null,\"holding\":false,"));
        // pressed on the body: it is held, and nothing else is offered
        let (x, y) = (game.spider.body.x, game.spider.body.y);
        game.press(x, y, now);
        play(&mut game, &mut now, 1);
        assert!(game.shown(now).contains("\"over\":null,\"holding\":true,"));
        game.release();
        play(&mut game, &mut now, 1);
        assert!(game.shown(now).contains("\"holding\":false,") && game.halts == 0);
        // over a moth that is halted in the web, when no part of the spider is in the way
        let (mut game, mut now) = webbed();
        let id = game.ring[MOTHS].held.split(',').next().unwrap().to_string();
        let moth = game.world.moths.iter().find(|m| Val::Num(m.id).written() == id).unwrap().clone();
        game.point(moth.x, moth.y, true, now);
        play(&mut game, &mut now, 1);
        let what = if pick(&game.spider, moth.x, moth.y).is_some() { "\"what\":\"" } else { "\"what\":\"moth\"}" };
        assert!(game.shown(now).contains(what));
        // and nothing while everything is halted
        backdoor::run(&mut game, "world.web.age += 1");
        play(&mut game, &mut now, 1);
        assert!(game.halted() && game.shown(now).contains("\"over\":null,\"holding\":false,"));
    }
    #[test]
    fn the_backdoor_reads_what_it_writes() {
        let (mut game, _) = fresh();
        assert_eq!(backdoor::run(&mut game, "world.tally.caught = 12"), "world.tally.caught = 12");
        assert_eq!(backdoor::run(&mut game, "world.tally.caught"), "12");
        assert!(backdoor::run(&mut game, "world").starts_with("{\"edge\":{\"inset\":10,"));
        assert!(backdoor::run(&mut game, "world.web").starts_with("{\"on\":true,"));
        assert_eq!(backdoor::run(&mut game, "spider.old"), "{\"on\":false,\"x\":0,\"y\":0,\"h\":0,\"size\":0,\"meals\":0}");
        assert!(backdoor::run(&mut game, "spider").starts_with("{\"body\":{\"x\":") && backdoor::run(&mut game, "spider").contains("},\"old\":{\"on\":false,"));
        assert_eq!(backdoor::run(&mut game, "world.shop"), "{\"spawn\":0,\"appetite\":0,\"spider\":0,\"web\":0}");
        assert_eq!(backdoor::run(&mut game, "world.shop.web += 2"), "world.shop.web = 2");
        assert_eq!(backdoor::run(&mut game, "world.web.torn = '4,5'"), "world.web.torn = \"4,5\"");
        assert!(backdoor::run(&mut game, "spider.ring[3].name").contains("whole") && backdoor::run(&mut game, "world.ring[3].name").contains("whole"));
        assert_eq!(backdoor::run(&mut game, "world.ring[*].name"), "[\"edge\",\"moths\",\"web\",\"whole\",\"page\"]");
        assert_eq!(backdoor::run(&mut game, "world.ring[1].held = '3'"), "world.ring[1].held = \"3\"");
    }

    /// One thing is changed that only a fault could change, with halts set to end at once.
    /// It must be found in the next round, for the reason given, and put right in that
    /// round, with what was done said. From then on the game must be, round for round,
    /// exactly where a game that was never touched is.
    fn mended(base: &At, what: &str, fault: &dyn Fn(&mut Game), found: &str, did: &str) {
        let (mut game, mut now) = base.clone();
        game.set_how(How::AtOnce);
        let (mut twin, mut twin_now) = (game.clone(), now);
        fault(&mut game);
        play(&mut game, &mut now, 1);
        play(&mut twin, &mut twin_now, 1);
        assert_eq!(game.why.as_deref(), Some(found), "{}", what);
        assert_eq!((game.halts, game.restarts, game.halted()), (1, 1, false), "{}: {}", what, game.why());
        assert_eq!(game.fixed.as_ref().map(|(did, _)| did.as_str()), Some(did), "{}", what);
        assert!(game.same_state(&twin), "{}: after it was put right the game is not where a game that was never touched is", what);
        assert!((0..PARTS.len()).all(|p| game.kept(p) == game.record.texts[p] && game.kept(p) == twin.kept(p)), "{}: the gate's record is not right", what);
        assert!(game.asks.is_empty() && game.asks_again.is_empty(), "{}: something asked is still waiting", what);
        play(&mut game, &mut now, 600);
        play(&mut twin, &mut twin_now, 600);
        assert!(game.halts == 1 && twin.halts == 0 && game.same_state(&twin), "{}: ten seconds on: {}", what, game.why());
    }
    #[test]
    fn a_fault_in_one_half_of_the_gates_record_is_put_right_from_the_state() {
        let copies: [(usize, fn(&mut Game)); 10] = [
            (0, |game| game.record.spider.legs[SETS[0][0]].x += 1.0),
            (1, |game| game.record.spider.legs[SETS[1][0]].fy -= 0.001),
            (2, |game| game.record.spider.body.x += 150.0),
            (2, |game| game.record.spider.body.full = !game.record.spider.body.full),
            (3, |game| game.record.world.edge.inset += 1.0),
            (4, |game| game.record.world.tally.gained += 100000.0),
            (4, |game| game.record.world.moths.clear()),
            (5, |game| game.record.world.web.age += 1.0),
            (OWN, |game| game.record.own.buys.push("spawn")),
            (OWN, |game| game.record.own.next_id += 1000.0),
        ];
        let mut tested = 0;
        for base in [with_moths(&fresh(), 1000.0), webbed(), handing(), carried()] {
            for p in 0..PARTS.len() {
                let (found, did) = (
                    format!("the gate found its own record of the {} no longer agrees with itself, and no observer had flagged it", PARTS[p]),
                    format!("the gate's record of the {} put right, all eight observers started again", PARTS[p]),
                );
                // what the gate has written out of the part
                mended(&base, &format!("the text of the {}", PARTS[p]), &|game| game.record.texts[p].push('x'), &found, &did);
                mended(&base, &format!("the text of the {}, emptied", PARTS[p]), &|game| game.record.texts[p].clear(), &found, &did);
                // the gate's copy of the part
                for (k, (_, fault)) in copies.iter().enumerate().filter(|(_, (part, _))| *part == p) {
                    // a change that changes nothing in this game is no fault: a list emptied that was empty
                    let mut tried = base.0.clone();
                    fault(&mut tried);
                    if tried.kept(p) != tried.record.texts[p] {
                        mended(&base, &format!("the copy of the {}, change {}", PARTS[p], k), &|game| fault(game), &found, &did);
                        tested += 1;
                    }
                }
            }
        }
        assert!(tested >= 38, "only {} changes to the gate's copies were tried", tested);
        // Under the other two ways a halt can end it is put right as well, and the game goes on from where it was.
        for how in [How::AfterAPause, How::OnAClick] {
            let (mut game, mut now) = webbed();
            game.set_how(how);
            let before = all(&game);
            game.record.world.moths.clear();
            play(&mut game, &mut now, 1);
            assert_eq!(game.why(), "the gate found its own record of the moths, counts and shop no longer agrees with itself, and no observer had flagged it");
            game.put_right();
            play(&mut game, &mut now, 60);
            assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && !game.shown(now).contains("\"stuck\":true"), "{}", game.why());
            assert!(all(&game) != before && game.differs().is_empty(), "the game did not go on");
            play(&mut game, &mut now, 3600);
            assert_eq!(game.halts, 1, "{}", game.why());
        }
    }
    #[test]
    fn a_fault_in_the_gates_record_while_a_round_is_worked_is_put_right() {
        // The gate has looked and the round's work is being done when the gate's copy of a part goes wrong.
        // The second doing of the work starts from that copy, so the round is not recorded. By then the
        // state has moved on, and nothing that is there now is what the gate wrote out. What the state was
        // when the round began is, and the state and the gate's copy both go back to that.
        let faults: [(usize, fn(&mut Game)); 8] = [
            // a web of a size there is not, an upgrade bought more times than there are moths in the world, a number that is not one
            (5, |game| if game.halts == 0 { game.record.world.web.level = 7.0 }),
            (4, |game| if game.halts == 0 { game.record.world.shop.spawn = 1e300 }),
            (2, |game| if game.halts == 0 { game.record.spider.body.food = f64::NAN }),
            (0, |game| if game.halts == 0 { game.record.spider.legs[SETS[0][0]].x += 0.001 }),
            (2, |game| if game.halts == 0 { game.record.spider.body.x += 150.0 }),
            (4, |game| if game.halts == 0 { game.record.world.tally.gained += 100000.0 }),
            (5, |game| if game.halts == 0 { game.record.world.web.age += 1.0 }),
            (OWN, |game| if game.halts == 0 { game.record.own.next_moth -= 1e6 }),
        ];
        let mut moved = 0;
        for (p, fault) in faults {
            for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
                let (mut game, mut now) = webbed();
                game.set_how(how);
                let before = all(&game);
                game.fault = Some(fault);
                play(&mut game, &mut now, 1);
                assert!(game.halted() && game.halts == 1 && all(&game) != before, "{} {:?}: {}", PARTS[p], how, game.why());
                assert!(["the gate found a step of the work", "the gate did the work of the round a second time", "the gate found that its own copy of the round before is not a state the game can be in"].iter().any(|start| game.why().starts_with(start)), "{}", game.why());
                if how != How::AtOnce {
                    // when the halt is over, and before any more work is done, everything is as it was when the round began
                    game.put_right();
                    let mut rounds = 0;
                    while game.halted() {
                        play(&mut game, &mut now, 1);
                        rounds += 1;
                        assert!(rounds < 120 && !game.shown(now).contains("\"stuck\":true"), "{} {:?}: {}", PARTS[p], how, game.why());
                    }
                    assert_eq!(all(&game), before, "{} {:?}: not as it was when the round began", PARTS[p], how);
                }
                play(&mut game, &mut now, 600);
                assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && game.differs().is_empty(), "{} {:?}: {}", PARTS[p], how, game.why());
                // a part the round's work had not moved is put right from the state as it is; one it had moved, from the state as the round began
                let did = &game.fixed.as_ref().unwrap().0;
                assert!(did.contains(&format!("the gate's record of the {} put right", PARTS[p])), "{} {:?}: {}", PARTS[p], how, did);
                moved += did.contains(&format!("the {} put back, the gate's record of the {} put right", PARTS[p], PARTS[p])) as usize;
            }
        }
        assert!(moved >= 6, "only {} of these were put right from the state as the round began", moved);
        // The second list of what was asked changed while the round is worked: an upgrade nobody asked for,
        // with moths enough to pay for it. The round is not recorded, the list is put right from the other two, and nothing is bought.
        let (mut game, mut now) = with_moths(&fresh(), 1000.0);
        game.fault = Some(|game| if game.halts == 0 { game.asks_again.push(Ask::Buy("spawn")) });
        play(&mut game, &mut now, 1);
        assert!(game.why().starts_with("the gate did the work of the round a second time, from its own record, and it came out another way in the moths, counts and shop"), "{}", game.why());
        play(&mut game, &mut now, 600);
        assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && game.world.shop.spawn == 0.0 && game.world.tally.spent == 0.0, "{}", game.why());
        assert!(game.fixed.as_ref().unwrap().0.contains("what was asked of the game put right from the two places that agreed"));
    }
    #[test]
    fn a_fault_in_what_the_gate_wrote_out_while_a_round_is_worked_is_put_right() {
        // The gate has looked and the round's work is being done when what the gate has written out of a
        // part goes wrong. The second doing of the work does not read that, and agrees with what is there.
        // Then the gate looks at the observers once more, by what it has written out, and finds that what
        // it has written out no longer says what its copy says: the round is not recorded. By then the state has moved on. For a part the work moved, nothing
        // that is there now is what the gate's copy says. What the part was when the round began is, and
        // it is what every observer holds: what is written out is put right from the copy, and the state
        // goes back to it. The body is moved by every round's work.
        let longer: [fn(&mut Game); 7] = [
            |game| if game.halts == 0 { game.record.texts[0].push('x') },
            |game| if game.halts == 0 { game.record.texts[1].push('x') },
            |game| if game.halts == 0 { game.record.texts[2].push('x') },
            |game| if game.halts == 0 { game.record.texts[3].push('x') },
            |game| if game.halts == 0 { game.record.texts[4].push('x') },
            |game| if game.halts == 0 { game.record.texts[5].push('x') },
            |game| if game.halts == 0 { game.record.texts[OWN].push('x') },
        ];
        let emptied: [fn(&mut Game); 7] = [
            |game| if game.halts == 0 { game.record.texts[0].clear() },
            |game| if game.halts == 0 { game.record.texts[1].clear() },
            |game| if game.halts == 0 { game.record.texts[2].clear() },
            |game| if game.halts == 0 { game.record.texts[3].clear() },
            |game| if game.halts == 0 { game.record.texts[4].clear() },
            |game| if game.halts == 0 { game.record.texts[5].clear() },
            |game| if game.halts == 0 { game.record.texts[OWN].clear() },
        ];
        let (mut moved, mut still) = (0, 0);
        for base in [with_moths(&fresh(), 1000.0), webbed(), handing(), carried()] {
            for p in 0..PARTS.len() {
                for (kind, fault) in [("made longer", longer[p]), ("emptied", emptied[p])] {
                    for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
                        let what = format!("what is written out of the {} {}, {:?}", PARTS[p], kind, how);
                        let (mut game, mut now) = base.clone();
                        game.set_how(how);
                        let (before, part) = (all(&game), game.text(p));
                        game.fault = Some(fault);
                        play(&mut game, &mut now, 1);
                        assert!(game.halted() && game.halts == 1, "{}: {}", what, game.why());
                        assert_eq!(game.why(), "the gate found that its own record had changed while the round was being worked", "{}", what);
                        let worked = game.text(p) != part; // did this round's work move the part?
                        if how != How::AtOnce {
                            // when the halt is over, and before any more work is done, everything is as it was when the round began
                            if how == How::OnAClick {
                                game.put_right(); // set to end after a pause, the pause is waited out
                            }
                            let mut rounds = 0;
                            while game.halted() {
                                play(&mut game, &mut now, 1);
                                rounds += 1;
                                assert!(rounds < 120 && !game.shown(now).contains("\"stuck\":true"), "{}: {}", what, game.why());
                            }
                            assert_eq!(all(&game), before, "{}: not as it was when the round began", what);
                        }
                        play(&mut game, &mut now, 600);
                        assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && game.differs().is_empty(), "{}: {}", what, game.why());
                        // a part the round's work had moved is put back as well as its record put right; one it had not moved has only its record put right
                        let did = &game.fixed.as_ref().unwrap().0;
                        assert!(did.contains(&format!("the gate's record of the {} put right", PARTS[p])), "{}: {}", what, did);
                        assert_eq!(did.contains(&format!("the {} put back, the gate's record of the {} put right", PARTS[p], PARTS[p])), worked, "{}: {}", what, did);
                        moved += worked as usize;
                        still += !worked as usize;
                    }
                }
            }
        }
        // the body in every one of these games, and the edge in none
        assert!(moved >= 24 + 24 && still >= 24, "{} with the part moved by the work and {} with it not", moved, still);
        // The same fault later, once the gate has looked at the observers again, or while the round is being
        // recorded: what is written out is then written anew with the rest of the record, and nothing is left of it.
        for instant in [1u8, 2] {
            let (mut game, mut now) = webbed();
            let (mut twin, mut twin_now) = (game.clone(), now);
            game.late = Some((instant, |game| game.record.texts[2].push('x')));
            play(&mut game, &mut now, 600);
            play(&mut twin, &mut twin_now, 600);
            assert!(game.halts == 0 && game.same_state(&twin) && game.differs().is_empty(), "at {}: {}", instant, game.why());
        }
    }
    #[test]
    fn what_is_written_at_the_backdoor_and_what_is_said_of_it_have_a_size() {
        // A text written at the backdoor is no longer than 1,024 characters. One that long is taken, and found like any other write.
        let (mut game, mut now) = fresh();
        let before = all(&game);
        assert!(backdoor::run(&mut game, &format!("spider.body.state = \"{}\"", "a".repeat(1025))).ends_with("is no longer than 1024 characters"));
        assert!(backdoor::run(&mut game, &format!("spider.ring[*].why = \"{}\"", "a".repeat(1025))).ends_with("is no longer than 1024 characters"));
        assert!(backdoor::run(&mut game, &format!("spider.ring[0].copies[0] = \"{}\"", "a".repeat(1025))).ends_with("is no longer than 1024 characters"));
        assert!(all(&game) == before && game.ring.iter().all(|o| o.why.is_empty()));
        assert!(backdoor::run(&mut game, &format!("spider.body.state = \"{}\"", "a".repeat(1024))).starts_with("spider.body.state = "));
        play(&mut game, &mut now, 120);
        assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && all(&game) != before && game.spider.body.state.len() < 20, "{}", game.why());

        // With every text there is made as long as it can be, of marks that are written out six times as
        // long, what a screen is sent stays small: of an observer's texts only the beginning is sent.
        let (mut game, mut now) = webbed();
        game.set_how(How::OnAClick);
        let plain = game.shown(now).len();
        let long = "\u{1}".repeat(1024);
        for field in ["spider.ring[*].name", "spider.ring[*].held", "spider.ring[*].why", "world.ring[*].name", "world.ring[*].held", "world.ring[*].why", "spider.body.state", "world.web.torn"] {
            let said = backdoor::run(&mut game, &format!("{} = \"{}\"", field, long));
            assert!(said.ends_with("written") || said.contains(" = "), "{}: {}", field, &said[..said.len().min(80)]);
        }
        play(&mut game, &mut now, 1);
        assert!(game.halted() && game.ring[0].why.chars().count() <= 1024);
        let shown = game.shown(now).len();
        assert!(shown < plain + 60_000, "{} characters to a screen, and {} before", shown, plain);
        game.put_right();
        play(&mut game, &mut now, 2);
        assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && game.shown(now).len() < plain + 2000, "{}", game.why());

        // A line kept to be written during the work is no longer than 1,024 characters.
        let (mut game, mut now) = fed();
        let pad = " ".repeat(1100);
        assert!(backdoor::run(&mut game, &format!("during spider.body.x +={}1", pad)).ends_with("is no longer than 1024 characters"));
        assert!(game.inside.is_empty());
        // Two lines that undo one another, each as long as a line may be. Together they change nothing, so
        // the round is recorded and they are let through. What is kept of them to be said is only their beginning.
        let pad = " ".repeat(990);
        assert!(backdoor::run(&mut game, &format!("during spider.body.x +={}1", pad)).starts_with("to be written during"));
        assert!(backdoor::run(&mut game, &format!("during spider.body.x -={}1", pad)).starts_with("to be written during"));
        let plain = game.shown(now).len();
        play(&mut game, &mut now, 2);
        assert!(game.halts == 0 && game.passed == 1, "{}", game.why());
        let said = game.let_through.clone().unwrap();
        assert!(said.chars().count() == 203 && said.starts_with("spider.body.x +=") && said.ends_with("..."), "{} characters", said.chars().count());
        assert!(game.shown(now).len() < plain + 400);
        // A halt later, and its putting right, change none of that.
        backdoor::run(&mut game, "spider.body.x += 150");
        play(&mut game, &mut now, 120);
        assert!(!game.halted() && game.halts == 1 && game.shown(now).len() < plain + 600, "{}", game.why());
    }
    #[test]
    fn a_line_that_cannot_be_written_when_its_time_comes_is_not_let_through() {
        // A line kept to be written during the work, of something that is no longer there when its time
        // comes: a moth that has been caught since. It writes nothing. The round is recorded, and the line
        // is not said to have been let through: it is said not to have been written.
        let (mut game, mut now) = fed();
        game.keep(|book| book.inside.push("world.moths[99].x = 100".into()));
        play(&mut game, &mut now, 2);
        assert!(game.halts == 0 && game.passed == 0 && game.let_through.is_none() && game.unwritten == 1, "{}", game.why());
        assert_eq!(game.not_written.as_deref(), Some("world.moths[99].x = 100"));
        assert!(game.shown(now).contains("\"passed\":0,\"let\":null,\"unwritten\":1,\"not\":\"world.moths[99].x = 100\""));
        // A line of two things, the first of which can be written and the second not. What was written is
        // found like anything else written during the work, and the line is not let through either way.
        let caught = game.world.tally.caught;
        game.keep(|book| book.inside.push("world.tally.caught += 5; world.moths[99].x = 100".into()));
        play(&mut game, &mut now, 1);
        assert!(game.halted() && game.halts == 1 && game.unwritten == 2 && game.why().starts_with("the gate found a step of the work"), "{}", game.why());
        play(&mut game, &mut now, 120);
        assert!(!game.halted() && game.passed == 0 && game.world.tally.caught - caught < 5.0, "{}", game.why());
        // A line that is written whole and changes nothing by then is let through, as before, and one beside it that cannot be written is not.
        assert_eq!(game.spider.body.gen, 1.0);
        game.keep(|book| book.inside.push("spider.body.gen = 1".into()));
        game.keep(|book| book.inside.push("world.moths[99].x = 100".into()));
        play(&mut game, &mut now, 2);
        assert!(game.halts == 1 && game.unwritten == 3 && game.passed == 1, "{}", game.why());
        assert_eq!(game.let_through.as_deref(), Some("spider.body.gen = 1"));
    }
    #[test]
    fn an_observers_reason_with_no_flag_is_found_by_the_others() {
        // An observer's reason for a flag, written from outside with no flag put up. The others of its ring
        // find that it has been changed, as they find a changed name or list: it is not left to the gate.
        let eight = [("spider.ring[0]", "legs A"), ("spider.ring[1]", "legs B"), ("spider.ring[2]", "body"), ("spider.ring[3]", "whole"), ("world.ring[0]", "edge"), ("world.ring[1]", "moths"), ("world.ring[2]", "web"), ("world.ring[4]", "page")];
        for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
            for (at, who) in eight {
                let what = format!("{} {:?}", at, how);
                let (mut game, mut now) = webbed();
                game.set_how(how);
                let before = all(&game);
                backdoor::run(&mut game, &format!("{}.why = \"x\"", at));
                play(&mut game, &mut now, 1);
                assert_eq!(game.why.as_deref(), Some(format!("the {} observer has been changed", who).as_str()), "{}", what);
                if how != How::AtOnce {
                    assert!(game.halted() && all(&game) == before, "{}: something moved", what);
                }
                if how == How::OnAClick {
                    game.put_right();
                }
                play(&mut game, &mut now, 120);
                assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && game.ring.iter().all(|o| o.why.is_empty()), "{}: {}", what, game.why());
            }
        }
    }
    #[test]
    fn what_the_gate_wrote_out_is_not_settled_against_an_observer_that_differs() {
        // Two faults in one round, which is more than is held: what the gate has written out of the body, and
        // one observer's copy of the body. The body as it was when the round began is what the gate's copy
        // says, but not every observer of the body holds that. So nothing settles it. The record is not put
        // right from its copy, and the game cannot go on until it is begun again.
        for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
            let (mut game, mut now) = webbed();
            game.set_how(how);
            game.fault = Some(|game| {
                if game.halts == 0 {
                    game.record.texts[2].push('x');
                    game.ring[2].copies[2].push('y');
                }
            });
            play(&mut game, &mut now, 1);
            assert!(game.halted() && game.halts == 1, "{:?}: {}", how, game.why());
            game.put_right();
            play(&mut game, &mut now, 2);
            assert!(game.shown(now).contains("\"stuck\":true"), "{:?}: it was put right: {}", how, game.why());
            assert!(game.why().starts_with("it could not be put right: the gate's record of the body does not agree with itself"), "{:?}: {}", how, game.why());
        }
    }
    #[test]
    fn a_text_is_cut_between_two_characters_whatever_they_are_made_of() {
        // Where a text is cut for a screen, and where an answer at the backdoor is cut, the cut falls between
        // two characters, also where a character is two, three or four bytes long.
        assert_eq!(short("\u{8718}\u{86db}\u{8718}\u{86db}", 2), "\u{8718}\u{86db}...");
        assert_eq!(short("\u{e9}\u{e9}\u{e9}", 3), "\u{e9}\u{e9}\u{e9}");
        assert_eq!(short("a\u{1f577}b", 2), "a\u{1f577}...");
        let (mut game, mut now) = webbed();
        game.set_how(How::OnAClick);
        for (field, mark) in [("name", "\u{e9}"), ("held", "\u{8718}"), ("why", "\u{1f577}")] {
            for ring in ["spider", "world"] {
                let said = backdoor::run(&mut game, &format!("{}.ring[*].{} = \"{}\"", ring, field, mark.repeat(1024)));
                assert!(said.ends_with("written"), "{}", &said[..said.len().min(80)]);
            }
        }
        // what a screen is sent of each: 160 characters and three dots
        let shown = game.shown(now);
        assert!(shown.contains(&format!("\"name\":\"{}...\"", "\u{e9}".repeat(160))), "the names were not cut where they should be");
        assert!(shown.contains(&format!("\"why\":\"{}...\"", "\u{1f577}".repeat(160))), "the reasons were not cut where they should be");
        // an answer cut at eight places one byte apart, so that the cut falls at every place across a character
        for pad in 0..8 {
            let said = backdoor::run(&mut game, &format!("{}spider.ring; world.ring; spider.ring; world.ring", "spider.body.gen; ".repeat(pad)));
            assert!(said.len() <= 64_000 + 200 && said.contains("... and no more of this is said"), "{} said with {} before it", said.len(), pad);
        }
        play(&mut game, &mut now, 1);
        assert!(game.halted());
    }
    #[test]
    fn a_number_that_is_not_one_does_not_break_what_a_screen_is_sent() {
        // One fault in what the game keeps for itself: what a catch of the last minute was worth, and where it
        // was, become numbers that are not numbers. Everything halts. What a screen is sent while it does is
        // still something a screen can read: no bare number that is not one is in it. And it is put right.
        let (mut game, mut now) = with_moths(&webbed(), 1000.0);
        game.set_how(How::OnAClick);
        game.own.gains.push(crate::game::Gain { n: 1e9, x: f64::INFINITY, y: f64::NEG_INFINITY, worth: f64::NAN, at: now });
        play(&mut game, &mut now, 1);
        assert!(game.halted(), "not found");
        let shown = game.shown(now);
        for bare in [":NaN", ",NaN", "[NaN", ":inf", ",inf", "[inf", ":-inf", ",-inf", "[-inf"] {
            assert!(!shown.contains(bare), "{} is in what a screen is sent", bare);
        }
        assert!(shown.contains("\"rate\":\"NaN\""), "{}", &shown[shown.len() - 400..]);
        game.put_right();
        play(&mut game, &mut now, 2);
        assert!(!game.halted() && (game.halts, game.restarts) == (1, 1), "{}", game.why());
    }
    #[test]
    fn a_leg_too_many_or_too_few_is_a_change_like_any_other() {
        // How many legs the spider has is written out with each set of legs. So a ninth leg, or a leg
        // gone, is found before the next round's work by the observers of the legs, and put back. In
        // the gate's copy it is found by the gate in its own record, and put right from the state.
        let (state, state_did) = ("the legs A observer found the first set of legs changed", "the first set of legs put back, all eight observers started again");
        let (record, record_did) = (
            "the gate found its own record of the first set of legs no longer agrees with itself, and no observer had flagged it",
            "the gate's record of the first set of legs put right, all eight observers started again",
        );
        for base in [webbed(), carried()] {
            let leg = base.0.spider.legs[0].clone();
            mended(&base, "a ninth leg", &|game| game.spider.legs.push(leg.clone()), state, state_did);
            mended(&base, "a leg gone", &|game| drop(game.spider.legs.pop()), state, state_did);
            mended(&base, "a ninth leg in the gate's copy", &|game| game.record.spider.legs.push(leg.clone()), record, record_did);
            mended(&base, "a leg gone from the gate's copy", &|game| drop(game.record.spider.legs.pop()), record, record_did);
        }
    }
    #[test]
    fn a_change_to_the_number_of_the_round_while_a_round_is_worked_is_never_taken_up() {
        // The number of the round is kept in three places with the rest of what is the gate's own. One of
        // them is changed while a round is being worked: to no number, to a number further on, and to one
        // that one more does not change. The round reads the two that agree and is recorded under the
        // right number. The next round finds the place and puts it right. After that an observer that
        // stops answering is still found: nothing has come to rest on the wrong number.
        let faults: [fn(&mut Game); 6] = [
            |game| game.books[0].rounds = f64::NAN,
            |game| game.books[1].rounds += 1000.0,
            |game| game.books[2].rounds -= 1.0,
            |game| game.books[0].rounds = f64::INFINITY,
            |game| game.books[1].rounds = 1.0e300,
            |game| game.books[2].rounds = 9007199254740992.0,
        ];
        for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
            for (k, fault) in faults.iter().enumerate() {
                let what = format!("{} {:?}", k, how);
                let (mut game, mut now) = webbed();
                game.set_how(how);
                let apart = patient();
                game.run_apart(apart.clone());
                play(&mut game, &mut now, 30);
                let (number, twin) = (game.rounds, game.clone());
                game.fault = Some(*fault);
                play(&mut game, &mut now, 1);
                game.fault = None;
                assert!(game.halts == 0 && game.rounds == number + 1.0 && game.ring.iter().all(|o| o.beat == number + 1.0), "{}: {}", what, game.why());
                let mut twin = twin;
                twin.run_apart(patient());
                let mut twin_now = now - STEP;
                play(&mut twin, &mut twin_now, 1);
                assert!(game.same_state(&twin), "{}: the round did not go as one that was never touched", what);
                play(&mut game, &mut now, 1);
                assert!(game.halts == 1 && game.why.as_deref().unwrap_or("").starts_with("the gate found that one of the three places where it keeps what is its own"), "{}: {}", what, game.why());
                game.put_right();
                play(&mut game, &mut now, 120);
                assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && game.books.iter().all(|book| book.rounds == game.rounds) && game.rounds == number + 122.0, "{}: {}", what, game.why());
                apart.stall(2);
                play(&mut game, &mut now, 1);
                assert!(game.halts == 2 && game.why.as_deref() == Some("the body observer did not answer in time"), "{}: {}", what, game.why());
            }
        }
    }
    #[test]
    fn the_state_kept_from_when_a_rounds_work_began_is_in_three_places() {
        // The state as it was when the last round's work began is kept in three places. One is changed, or
        // emptied: the gate finds it at the start of the next round, everything halts, it is put right from
        // the other two, and the game goes on where a game that was never touched is.
        let found = "the gate found that the three places where it keeps the state from when the last round's work began no longer agreed, and no observer had flagged it";
        let did = "the state kept from when the last round's work began put right from the two places that agreed, all eight observers started again";
        let faults: [fn(&mut Option<Box<State>>); 4] = [|kept| kept.as_mut().unwrap().0.body.x += 150.0, |kept| kept.as_mut().unwrap().1.tally.gained += 1000.0, |kept| kept.as_mut().unwrap().2.next_id += 5.0, |kept| *kept = None];
        for base in [webbed(), carried()] {
            for fault in faults {
                for place in 0..3 {
                    let (mut game, mut now) = base.clone();
                    play(&mut game, &mut now, 1);
                    mended(&(game, now), "the kept state", &|game| fault(&mut game.before[place]), found, did);
                }
            }
        }
        // It is what a part is put right from when a round was not recorded and the gate's record has gone
        // wrong in the same part. With one of its three places changed as well, that still comes out right:
        // that is three faults at once, more than is claimed, and the two places that agree carry it.
        let (mut game, mut now) = webbed();
        play(&mut game, &mut now, 1);
        let right = state_text(&game.before[0]);
        for place in 0..3 {
            let mut one = game.clone();
            one.before[place].as_mut().unwrap().0.body.x += 150.0;
            assert_eq!(state_text(&one.began().cloned()), right, "the changed place was read: {}", place);
        }
        game.before[1].as_mut().unwrap().0.body.x += 150.0;
        assert_eq!(state_text(&game.began().cloned()), right);
        // Two places changed, each another way: nothing says which is right. It is put aside, and the game goes on.
        game.before[2].as_mut().unwrap().0.body.x -= 150.0;
        play(&mut game, &mut now, 1);
        assert!(game.halts == 1 && !game.stuck() && game.before.iter().all(|kept| kept.is_none()), "{}", game.why());
        play(&mut game, &mut now, 120);
        assert!(!game.halted() && (game.halts, game.restarts) == (1, 1), "{}", game.why());
    }
    /// Every function and every number of a second text must be in the first word for word. What
    /// comes back is how many functions and numbers the second text has, and how many of its
    /// functions begin with its mark, which is the one thing it has more.
    fn word_for_word(first: &str, second: &str, name: &str, methods: &str) -> (usize, usize, usize) {
        let plain = |text: &str| text.replace("\r\n", "\n").replace("\npub fn ", "\nfn ").replace("\npub const ", "\nconst ");
        let (first, second) = (plain(first), plain(second));
        // What the second text takes from the rest of the program is kinds of thing, by name, and no
        // function or number: one of those taken from the first text would be one text used twice. It
        // says what it takes at its head, however that is laid out over lines, and nowhere else: nothing
        // below is reached by a path into the rest of the program, and nothing is called on a kind
        // that the kind brings with it, but for how a thing is written out.
        let mut rest = second.clone();
        let mut kinds: Vec<String> = Vec::new();
        while let Some(at) = rest.find("\nuse ") {
            let end = at + rest[at..].find(';').expect("a taking in with no end");
            let said: String = rest[at + 5..end].split_whitespace().collect();
            let from_std = said.starts_with("std::");
            let names = said.rsplit("::").next().unwrap_or("").trim_matches(|c| c == '{' || c == '}').to_string();
            for one in names.split(',').filter(|one| !one.is_empty()) {
                let a_kind = one.chars().next().map_or(false, |c| c.is_ascii_uppercase()) && !one.chars().all(|c| c.is_ascii_uppercase() || c == '_');
                assert!(a_kind || from_std, "the second text of {} takes {} from outside itself", name, one);
                if !from_std {
                    kinds.push(one.to_string());
                }
            }
            rest.replace_range(at..=end, "");
        }
        let below: String = rest.lines().filter(|line| !line.trim_start().starts_with("//")).collect::<Vec<_>>().join("\n");
        assert!(!below.contains("crate::") && !below.contains("super::"), "the second text of {} reaches into the rest of the program by a path", name);
        for kind in &kinds {
            let called = format!("{}::", kind);
            let by_kind = below.match_indices(&called).any(|(at, _)| below[at + called.len()..].chars().next().map_or(false, |c| c.is_ascii_lowercase()) && !below[..at].ends_with(|c: char| c.is_alphanumeric() || c == '_'));
            assert!(!by_kind, "the second text of {} calls something that {} brings with it", name, kind);
        }
        for line in methods.lines().filter(|line| line.starts_with("    ")) {
            let said = line.trim_start().trim_start_matches("pub ");
            if let Some(method) = said.strip_prefix("fn ").and_then(|said| said.split('(').next()) {
                if method != "written" && method.chars().all(|c| c.is_ascii_alphanumeric() || c == '_') {
                    assert!(!below.contains(&format!(".{}(", method)), "the second text of {} calls {}, which a kind of thing brings with it", name, method);
                }
            }
        }
                let marks = second.clone();
        let is_mark = |line: &str| line.starts_with("    second(\"") && line.ends_with("\");");
        let marked = second.lines().filter(|line| is_mark(line)).count();
        let second = second.lines().filter(|line| !is_mark(line)).collect::<Vec<_>>().join("\n");
        let lines: Vec<&str> = second.lines().collect();
        let (mut functions, mut numbers, mut k) = (0, 0, 0);
        while k < lines.len() {
            let (function, number) = (lines[k].starts_with("fn ") && !lines[k].starts_with("fn second("), lines[k].starts_with("const "));
            if !function && !number {
                k += 1;
                continue;
            }
            let mut to = k;
                        if function {
                if !lines[k].ends_with('}') {
                    while lines[to] != "}" {
                        to += 1;
                    }
                }
                // its mark is its first line, and carries its own name
                let called = lines[k]["fn ".len()..].split(|c: char| c == '(' || c == '<').next().unwrap_or("");
                assert!(marks.contains(&format!("{}\n    second(\"{}\");\n", lines[k], called)), "{} in the second text of {} does not begin with its own mark", called, name);
                functions += 1;
            } else {
                while !lines[to].contains(';') {
                    to += 1;
                }
                numbers += 1;
            }
            let item = lines[k..=to].join("\n");
            assert!(first.contains(&format!("\n{}\n", item)), "this is not in {} as it is here:\n{}", name, item);
            k = to + 1;
        }
        (functions, numbers, marked)
    }
    #[test]
    fn the_second_text_of_the_work_is_the_first_word_for_word() {
        // The gate's second doing of a round's work is done by a text of its own, `game/again.rs`. Every
        // function and every number in it must be in `game.rs` word for word, so that a change made to
        // one of the two texts and not to the other fails here, before it halts a game.
        let held = word_for_word(include_str!("game.rs"), include_str!("game/again.rs"), "game.rs", include_str!("game.rs"));
        assert_eq!(held, (41, 29, 41), "the second text does not hold what it held, or a function of it has no mark");
    }
    #[test]
    fn the_second_text_of_the_rules_is_the_first_word_for_word() {
        // The gate holds every round to the rules of the game in two texts, `rules.rs` and
        // `rules/again.rs`. Every function and every number of the second must be in the first word for
        // word, and the second must have them all: a rule changed in one text only fails here.
        let held = word_for_word(include_str!("rules.rs"), include_str!("rules/again.rs"), "rules.rs", include_str!("game.rs"));
        assert_eq!(held, (9, 16, 9), "the second text of the rules does not hold what it held, or a function of it has no mark");
        let first = include_str!("rules.rs").replace("\r\n", "\n");
        let (functions, numbers) = (first.lines().filter(|line| line.starts_with("fn ") || line.starts_with("pub fn ")).count(), first.lines().filter(|line| line.starts_with("const ") || line.starts_with("pub const ")).count());
        assert_eq!((functions, numbers), (9, 16), "the first text of the rules has something the second has not");
    }
    /// The game as the program runs a round of it: if the round stops where it should not, the
    /// stop is caught and the game is told, as `play` in `main.rs` does.
    fn guarded(game: &mut Game, now: &mut f64) -> bool {
        use std::panic::{catch_unwind, AssertUnwindSafe};
        *now += STEP;
        let at = *now;
        // the round and what a screen is sent, under one catch
        let stopped = catch_unwind(AssertUnwindSafe(|| {
            game.round(STEP / 1000.0, at);
            game.shown(at);
        }))
        .is_err();
        if stopped {
            game.stopped("the game's own work stopped where it should not have", at);
            // what a screen is sent is written out again: if that stops too, the game is put aside whole
            if catch_unwind(AssertUnwindSafe(|| drop(game.shown(at)))).is_err() {
                game.fail("the game's own work stopped where it should not have", at);
            }
        }
        stopped
    }
    #[test]
    fn a_stop_that_comes_back_every_round_puts_the_game_aside_at_the_second() {
        // The program stops in the wrong place in the same way in every round, as it would if the stop
        // came from how the program is written and not from a fault. Wherever in a round it stops, and
        // however halts are set to end, the second stop puts the game aside whole: it does not halt and
        // go on for ever. One such place is after the round, when what a screen is sent is written out.
        let quiet = std::panic::take_hook();
        std::panic::set_hook(Box::new(|_| {}));
        for how in [How::AtOnce, How::AfterAPause, How::OnAClick] {
            // in the work of every round
            let (mut game, mut now) = webbed();
            game.set_how(how);
            game.fault = Some(|_| panic!("the work stops here in every round"));
            let mut stops = 0;
            for _ in 0..200 {
                stops += guarded(&mut game, &mut now) as usize;
                game.put_right();
                if game.stuck() {
                    break;
                }
            }
            assert!(game.stuck() && stops == 2 && game.games == 1, "{:?}: {} stops, {}", how, stops, game.why());
            // after every round in which nothing is halted, as a stop in what a screen is sent would be
            let (mut game, mut now) = webbed();
            game.set_how(how);
            let mut stops = 0;
            for _ in 0..200 {
                play(&mut game, &mut now, 1);
                if !game.halted() {
                    game.stopped("the game's own work stopped where it should not have", now);
                    stops += 1;
                }
                game.put_right();
                if game.stuck() {
                    break;
                }
            }
            assert!(game.stuck() && stops == 2 && game.games == 1, "{:?}: after the round, {} stops, {}", how, stops, game.why());
        }
        std::panic::set_hook(quiet);
    }
    #[test]
    fn a_count_that_goes_wrong_inside_a_round_is_put_right() {
        // The gate has looked at its counts and the round goes on. Then a count goes wrong: a text of
        // the gate's record too many or too few, an observer too many or too few. It is found in a halt
        // like any other, or the round's own recording writes over it and nothing is left of it. Nothing
        // stops in the wrong place, the counts are as they should be afterwards, and the game goes on.
        let faults: [(&str, fn(&mut Game)); 9] = [
            ("a text too many", |game| game.record.texts.push("x".into())),
            ("a text too few", |game| drop(game.record.texts.pop())),
            ("a text gone from the middle", |game| drop(game.record.texts.remove(2))),
            ("an observer too many", |game| game.ring.push(game.ring[0].clone())),
            ("an observer too few", |game| drop(game.ring.pop())),
            ("an observer gone from the middle", |game| drop(game.ring.remove(2))),
            ("no observers", |game| game.ring.clear()),
            // with these the first member of a ring is gone while the observers that are left have flags up
            ("three observers left", |game| game.ring.truncate(3)),
            ("four observers left", |game| game.ring.truncate(4)),
        ];
        let quiet = std::panic::take_hook();
        std::panic::set_hook(Box::new(|_| {}));
        let mut stops = 0;
        for how in [How::AtOnce, How::AfterAPause, How::OnAClick] {
            for (what, fault) in faults {
                // before the observers are asked, after the work, before the round is recorded, and between
                // the gate's look and the work
                for when in 0..4 {
                    let what = format!("{}, {:?}, at instant {}", what, how, when);
                    let (mut game, mut now) = webbed();
                    game.set_how(how);
                    let before = all(&game);
                    match when {
                        0 => game.early = Some(fault),
                        1 => game.fault = Some(fault),
                        2 => game.late = Some((1, fault)),
                        _ => game.late = Some((0, fault)),
                    }
                    stops += guarded(&mut game, &mut now) as usize;
                    game.fault = None;
                    game.late = None;
                    assert!(!game.stuck() && game.halts <= 1, "{}: {}", what, game.why());
                    // a count that goes wrong after the work is said to be what it is, and not an observer's copies or a wrong step
                    if (when == 1 || when == 3) && what.starts_with("a text") {
                        assert_eq!(game.why.as_deref(), Some("the gate found that its own record no longer had one text for each part while the round was being worked"), "{}", what);
                    }
                    if (when == 1 || when == 3) && what.contains("observer") {
                        assert_eq!(game.why.as_deref(), Some("the gate found that the number of observers had changed while the round was being worked"), "{}", what);
                    }
                    for _ in 0..3 {
                        stops += guarded(&mut game, &mut now) as usize;
                    }
                    game.put_right();
                    for _ in 0..120 {
                        assert!(!guarded(&mut game, &mut now), "{}: it stopped in the wrong place again", what);
                    }
                    // one halt, or none where the round that followed wrote over what had gone wrong
                    assert!(!game.halted() && !game.stuck() && game.halts <= 1 && game.games == 1, "{}: halts {}, {}", what, game.halts, game.why());
                    assert!(game.ring.len() == NAMES.len() && game.record.texts.len() == PARTS.len() && game.differs().is_empty(), "{}: the counts are not right", what);
                    assert!(all(&game) != before, "{}: the game did not go on", what);
                }
            }
        }
        std::panic::set_hook(quiet);
        assert_eq!(stops, 0, "a count gone wrong stopped the round in the wrong place");
        // A text of the gate's record that changes after the work, or is emptied, is not a count. It is
        // said to be the record all the same, and not an observer's copies.
        let changes: [fn(&mut Game); 2] = [|game| game.record.texts[2].push('x'), |game| game.record.texts[5].clear()];
        for change in changes {
            let (mut game, mut now) = webbed();
            game.set_how(How::OnAClick);
            game.fault = Some(change);
            play(&mut game, &mut now, 1);
            game.fault = None;
            assert_eq!(game.why.as_deref(), Some("the gate found that its own record had changed while the round was being worked"));
            game.put_right();
            play(&mut game, &mut now, 3);
            assert!(!game.halted() && (game.halts, game.restarts) == (1, 1), "{}", game.why());
        }
    }
    #[test]
    fn two_counts_gone_wrong_with_one_round_between_are_two_halts() {
        // The number of observers goes wrong inside a round, twice, with one round recorded between: one
        // fault for each halt. Each is found and put right, and the game is not put aside. And with a
        // count wrong, nothing that is asked of the game, said at the backdoor or written out for a
        // screen stops either.
        for how in [How::AtOnce, How::AfterAPause, How::OnAClick] {
            let faults: [fn(&mut Game); 5] = [|game| drop(game.ring.pop()), |game| game.ring.clear(), |game| game.ring.truncate(3), |game| game.ring.push(game.ring[1].clone()), |game| drop(game.record.texts.pop())];
            for fault in faults {
                // how many rounds are worked and recorded after the first halt has ended and before the
                // second fault: one, and for good measure two. Set to end at once, the round the fault
                // lands in is itself put right, worked and recorded, so there none more is needed.
                for between in [0usize, 1, 2] {
                    if between == 0 && how != How::AtOnce {
                        continue;
                    }
                    let (mut game, mut now) = webbed();
                    game.set_how(how);
                    play(&mut game, &mut now, 3);
                    for halts in 1..=2 {
                        game.early = Some(fault);
                        assert!(!guarded(&mut game, &mut now), "{:?}: the round stopped in the wrong place", how);
                        assert!(game.halts == halts && game.stops == 0 && !game.stuck(), "{:?}: {}", how, game.why());
                        game.put_right();
                        // under the other two settings the round that ends the halt does no work
                        if how != How::AtOnce {
                            assert!(!guarded(&mut game, &mut now) && !game.halted(), "{:?}: {}", how, game.why());
                        }
                        let recorded = game.rounds;
                        for _ in 0..between {
                            assert!(!guarded(&mut game, &mut now), "{:?}", how);
                        }
                        assert!(!game.halted() && game.restarts == halts && game.games == 1 && game.rounds == recorded + between as f64, "{:?}, {} between: {}", how, between, game.why());
                    }
                }
            }
            // A line at the backdoor with a count wrong is refused, and reads nothing: it does not stop.
            for wrong in [|game: &mut Game| drop(game.ring.pop()), |game: &mut Game| drop(game.ring[1].copies.pop())] as [fn(&mut Game); 2] {
                let (mut game, _) = webbed();
                wrong(&mut game);
                for line in ["world.ring", "world", "world.ring[2].alive", "world.ring[2].alive = false", "spider.ring[1].copies[6]", "spider.ring[1].copies[6] = \"x\"", "spider.body.x += 150"] {
                    assert!(backdoor::run(&mut game, line).contains("nothing is read or written here"), "{}", line);
                }
            }
            // A line kept to be written during the work, which names an observer, in a round whose work
            // loses an observer after the gate has looked: the line is not written, and the round does not stop.
            let (mut game, mut now) = webbed();
            game.set_how(how);
            assert!(backdoor::run(&mut game, "during world.ring[2].alive = false").starts_with("to be written during"));
            game.fault = Some(|game| drop(game.ring.pop()));
            assert!(!guarded(&mut game, &mut now), "{:?}: the round stopped in the wrong place", how);
            game.fault = None;
            assert!(game.halts == 1 && game.stops == 0 && game.unwritten == 1 && !game.stuck(), "{:?}: {}", how, game.why());
            game.put_right();
            for _ in 0..3 {
                assert!(!guarded(&mut game, &mut now), "{:?}", how);
            }
            assert!(!game.halted() && game.ring.len() == NAMES.len(), "{:?}: {}", how, game.why());
            // With no observers left, none of them can find it. The gate counts them in its own look, and
            // halts before any work is done: it is not left to the rules to find what the work then did.
            let (mut game, mut now) = webbed();
            game.set_how(how);
            play(&mut game, &mut now, 3);
            let moved = game.texts().concat();
            game.early = Some(|game| game.ring.clear());
            assert!(!guarded(&mut game, &mut now));
            assert_eq!(game.why.as_deref(), Some("the gate found that the number of observers had changed, and no observer had flagged it"), "{:?}", how);
            if how != How::AtOnce {
                assert!(game.halted() && game.texts().concat() == moved, "{:?}: work was done with no observer", how);
            }
            // between two rounds, with the count wrong: a screen is written for, and things are asked
            let (mut game, mut now) = webbed();
            game.set_how(how);
            game.ring.truncate(3);
            let _ = game.shown(now);
            game.point(10.0, 10.0, true, now);
            game.press(10.0, 10.0, now);
            game.buy("spawn");
            assert!(!guarded(&mut game, &mut now) && game.halts == 1 && game.stops == 0, "{:?}: {}", how, game.why());
        }
    }
    #[test]
    fn what_was_asked_is_emptied_where_the_round_is_recorded() {
        // The three lists of what was asked are emptied by the writing of the record itself, so that
        // nothing can come between a round being recorded and what it took in being forgotten.
        let (mut game, now) = webbed();
        game.point(10.0, 10.0, true, now);
        game.buy("spawn");
        assert!(game.asks.len() == 2 && game.asks_again.len() == 2 && game.asks_third.len() == 2);
        game.settle();
        assert!(game.asks.is_empty() && game.asks_again.is_empty() && game.asks_third.is_empty(), "the record was written and what was asked is still waiting");
    }
    #[test]
    fn a_count_put_right_is_said() {
        // A count put right is said with what else was done when the halt ends, wherever it is put right:
        // when the program has stopped in the wrong place, in the putting right of a halt, or by the gate
        // at the start of a round.
        let (mut game, mut now) = webbed();
        game.set_how(How::OnAClick);
        game.ring.pop();
        game.stopped("the game's own work stopped where it should not have", now);
        game.put_right();
        play(&mut game, &mut now, 2);
        assert!(!game.halted() && game.fixed.as_ref().map_or(false, |(did, _)| did.starts_with("the gate's counts put right")), "{:?}", game.fixed);
        let (mut game, mut now) = webbed();
        game.set_how(How::AtOnce);
        game.early = Some(|game| game.record.texts.push("x".into()));
        play(&mut game, &mut now, 1);
        assert!(!game.halted() && game.halts == 1 && game.fixed.as_ref().map_or(false, |(did, _)| did.contains("the gate's counts put right")), "{:?}", game.fixed);
        // Where the gate finds the count wrong for itself at the start of a round: gone wrong between two
        // rounds, or inside a round and found again at the start of the next. It is said, and once.
        let wrongs: [fn(&mut Game); 2] = [|game| drop(game.ring.pop()), |game| drop(game.record.texts.pop())];
        for how in [How::AtOnce, How::AfterAPause, How::OnAClick] {
            for wrong in wrongs {
                for inside in [false, true] {
                    let (mut game, mut now) = webbed();
                    game.set_how(how);
                    if inside {
                        game.early = Some(wrong);
                    } else {
                        wrong(&mut game);
                    }
                    play(&mut game, &mut now, 1);
                    game.put_right();
                    play(&mut game, &mut now, 3);
                    let said = game.fixed.as_ref().map_or(0, |(did, _)| did.matches("the gate's counts put right").count());
                    assert!(!game.halted() && game.halts == 1 && said == 1, "{:?}, inside a round {}: said {} times in {:?}", how, inside, said, game.fixed);
                }
            }
        }
        // And where a count goes wrong again while the halt lasts, which is a second fault in it, the
        // gate puts it right again and still says it once.
        let (mut game, mut now) = webbed();
        game.set_how(How::OnAClick);
        for _ in 0..5 {
            game.ring.pop();
            play(&mut game, &mut now, 1);
            assert!(game.halted() && game.ring.len() == NAMES.len());
        }
        game.put_right();
        play(&mut game, &mut now, 3);
        let said = game.fixed.as_ref().map_or(0, |(did, _)| did.matches("the gate's counts put right").count());
        assert!(!game.halted() && game.halts == 1 && said == 1, "said {} times in {:?}", said, game.fixed);
        // And where it goes wrong again in the round that puts the halt right, after the gate has looked
        // at its counts, so that the putting right finds it: once still.
        let (mut game, mut now) = webbed();
        game.set_how(How::OnAClick);
        game.ring.pop();
        play(&mut game, &mut now, 1);
        game.put_right();
        game.early = Some(|game| drop(game.ring.pop()));
        play(&mut game, &mut now, 3);
        let said = game.fixed.as_ref().map_or(0, |(did, _)| did.matches("the gate's counts put right").count());
        assert!(!game.halted() && game.halts == 1 && said == 1, "said {} times in {:?}", said, game.fixed);
    }
    #[test]
    fn a_stop_in_the_wrong_place_is_once_a_halt_and_twice_running_the_end_of_the_game() {
        // The program stops where it should not while it has hold of the game. Once, that is a halt like
        // any other: nothing of the round is kept, it is put right from the gate's record, and the game
        // goes on where a game that was never touched is. A second stop before a round that began
        // with nothing halted has been recorded is not gone on with: the game is put aside whole, and has to be begun again.
        for how in [How::AtOnce, How::AfterAPause, How::OnAClick] {
            let (mut game, mut now) = webbed();
            game.set_how(how);
            let (mut twin, mut twin_now) = (game.clone(), now);
            // the work has half moved the state when it stops
            game.spider.body.x += 33.0;
            game.world.tally.caught += 2.0;
            game.stopped("the game's own work stopped where it should not have", now);
            assert!(game.halted() && !game.stuck() && game.why() == "the game's own work stopped where it should not have" && game.stops == 1, "{:?}", how);
            game.put_right();
            play(&mut game, &mut now, 2);
            // set to end at once, both of those rounds are worked; otherwise the second only
            if how != How::AtOnce {
                twin_now += STEP;
            }
            play(&mut twin, &mut twin_now, if how == How::AtOnce { 2 } else { 1 });
            assert!(!game.halted() && (game.halts, game.restarts, game.games, game.stops) == (1, 1, 1, 0), "{:?}: {}", how, game.why());
            // every part is where the untouched game has it; where the halt took a round of its own, the
            // observers have signalled once more than the other game's, and are not compared
            assert!(all(&game) == all(&twin) && (how != How::AtOnce || game.same_state(&twin)), "{:?}: the game is not where a game that was never touched is", how);
            // twice, with no round between that began with nothing halted and was recorded
            game.stopped("the game's own work stopped where it should not have", now);
            game.stopped("the game's own work stopped where it should not have", now);
            assert!(game.stuck() && game.games == 1 && game.halts == 3, "{:?}: {}", how, game.why());
            game.put_right();
            play(&mut game, &mut now, 2);
            assert!(!game.halted() && game.games == 2, "{:?}: {}", how, game.why());
        }
    }
    #[test]
    fn a_round_is_held_to_both_texts_of_the_rules() {
        // A step that the rules forbid is refused by each text of the rules by itself: the second is not
        // there for show. A count of moths caught that goes up with no moth gone is such a step. Each
        // text is asked alone, and each names the same rule.
        let (mut game, mut now) = with_moths(&fresh(), 1000.0);
        // In a round of the game, the second text of the rules is asked, and so is the second text of
        // the work: each counts how often its mark is passed, and neither count stands still.
        let work = |name: &str| again::PASSED.with(|passed| passed.borrow().get(name).copied().unwrap_or(0));
        let asked_of = |name: &str| rules::again::PASSED.with(|passed| passed.borrow().get(name).copied().unwrap_or(0));
        let before: Vec<u64> = ["take_in", "world_work", "spider_work", "in_web"].iter().map(|name| work(name)).chain(["wrong_in", "wrong_step"].iter().map(|name| asked_of(name))).collect();
        play(&mut game, &mut now, 3);
        assert_eq!(game.halts, 0, "{}", game.why());
        // The second doing does the world's work and the spider's once a round. It takes in what was
        // asked and works out the halted moths twice: once for itself, and once for the second text
        // of the rules, which is handed nothing that the first text of the work made.
        for (k, (name, times)) in [("take_in", 6), ("world_work", 3), ("spider_work", 3), ("in_web", 6)].iter().enumerate() {
            assert_eq!(work(name), before[k] + times, "the second text's {} was not passed {} times in three rounds", name, times);
        }
        // each text of the rules is asked of the gate's own copy and of the state, and of the step once
        assert_eq!(asked_of("wrong_in"), before[4] + 6, "the second text of the rules was not asked of the gate's copy and of the state in each round");
        assert_eq!(asked_of("wrong_step"), before[5] + 3, "the second text of the rules was not asked of the step in each round");
        // Each text of the rules is asked, and each refuses by itself a step the rules forbid: moths
        // caught that no moth was lost for. That is asked here as the gate asks it.
        let mut wrong = game.clone();
        wrong.world.tally.caught += 5.0;
        let step = Asked { buys: Vec::new(), clicks: 0, next_moth: wrong.own.next_moth, held: wrong.own.held() };
        let (one, other) = wrong.ruled(&step, 0.0, now);
        assert!(one.is_some() && one == other, "the two texts of the rules do not both refuse it: {:?} and {:?}", one, other);
        let (one, other) = game.ruled(&step, 0.0, now);
        assert_eq!((one, other), (None, None), "a round of no length that changes nothing was refused");
        let was = (game.record.spider.clone(), game.record.world.clone());
        let mut world = game.world.clone();
        world.tally.caught += 5.0;
        let asked = Asked { buys: Vec::new(), clicks: 0, next_moth: game.own.next_moth, held: game.own.held() };
        let held = in_web(&was.1);
        let one = wrong_step((&was.0, &was.1), &held, game.record.own.next_id, (&game.spider, &world), &asked, 0.0, now);
        let other = rules::again::wrong_step((&was.0, &was.1), &held, game.record.own.next_id, (&game.spider, &world), &asked, 0.0, now);
        assert!(one.is_some() && one == other, "{:?} and {:?}", one, other);
        // And each allows what the other allows: the state as it is, and a round of no length that changes nothing.
        assert_eq!((wrong_in(&game.spider, &game.world), rules::again::wrong_in(&game.spider, &game.world)), (None, None));
        let none = (
            wrong_step((&was.0, &was.1), &held, game.record.own.next_id, (&was.0, &was.1), &asked, 0.0, now),
            rules::again::wrong_step((&was.0, &was.1), &held, game.record.own.next_id, (&was.0, &was.1), &asked, 0.0, now),
        );
        assert_eq!(none.0, none.1);
        // The second text of the rules is asked with what the second text of the work makes of the
        // second list of what was asked, and with nothing the first is handed. An upgrade is asked for
        // and a round is worked: both texts allow it. Handed an account with no upgrade in it, the first
        // refuses the upgrade, and the second, which is not handed that account, does not. And with no
        // upgrade in the second list, the second refuses, whatever the first is handed.
        let (mut game, mut now) = with_moths(&fresh(), 1000.0);
        play(&mut game, &mut now, 3);
        game.buy(UPGRADES[0].0);
        assert!(!game.asks.is_empty() && !game.asks_again.is_empty(), "the upgrade was not taken down");
        let mut worked = game.clone();
        play(&mut worked, &mut now, 1);
        assert_eq!(worked.halts, 0, "{}", worked.why());
        // the gate's record of the round before, the lists as they were, and the state as the round's work left it
        let mut judged = game.clone();
        judged.spider = worked.spider.clone();
        judged.world = worked.world.clone();
        let mut own = judged.record.own.clone();
        take_in(&mut own, &judged.record.spider, &judged.asks);
        let with = Asked { buys: own.buys.clone(), clicks: own.clicks.len(), next_moth: own.next_moth, held: own.held() };
        assert_eq!(with.buys.len(), 1);
        let without = Asked { buys: Vec::new(), clicks: with.clicks, next_moth: with.next_moth, held: with.held };
        assert_eq!(judged.ruled(&with, STEP / 1000.0, now), (None, None), "a round with an upgrade bought in it was refused");
        let (one, other) = judged.ruled(&without, STEP / 1000.0, now);
        assert!(one.is_some() && other.is_none(), "handed an account with no upgrade in it: {:?} and {:?}", one, other);
        judged.asks_again.clear();
        let (one, other) = judged.ruled(&with, STEP / 1000.0, now);
        assert!(one.is_none() && other.is_some(), "with no upgrade in the second list: {:?} and {:?}", one, other);
        // And the gate's recording heeds each text by itself. The same round is given to the gate to
        // record three ways. What only the first text refuses is not recorded, and what only the second
        // refuses is not recorded, each for the rule's reason. What neither refuses is recorded.
        let rule = "the gate found a step of the work that the rules of the game do not allow: ";
        let mut whole = game.clone();
        whole.spider = worked.spider.clone();
        whole.world = worked.world.clone();
        whole.own = worked.own.clone();
        let mut first_only = whole.clone();
        let said = first_only.record_now((&without, STEP / 1000.0, now));
        assert!(said.as_ref().map_or(false, |why| why.starts_with(rule)), "what only the first text of the rules refuses: {:?}", said);
        let mut second_only = whole.clone();
        second_only.asks_again.clear();
        let said = second_only.record_now((&with, STEP / 1000.0, now));
        assert!(said.as_ref().map_or(false, |why| why.starts_with(rule)), "what only the second text of the rules refuses: {:?}", said);
        // The gate's own copy of the round before is asked of both texts as well, and each is heeded by
        // itself. The two texts say the same of any copy, so here each one's answer is put in by hand:
        // of the copy, and then of the step.
        let copy = "the gate found that its own copy of the round before is not a state the game can be in: ";
        let sways: [(fn(usize, Said) -> Said, &str); 4] = [
            (|at, said| if at == 0 { (Some("x"), None) } else { said }, copy),
            (|at, said| if at == 0 { (None, Some("x")) } else { said }, copy),
            (|at, said| if at == 1 { (Some("x"), None) } else { said }, rule),
            (|at, said| if at == 1 { (None, Some("x")) } else { said }, rule),
        ];
        for (k, (sway, begins)) in sways.into_iter().enumerate() {
            let mut swayed = whole.clone();
            swayed.sway = Some(sway);
            assert_eq!(swayed.record_now((&with, STEP / 1000.0, now)), Some(format!("{}x", begins)), "one text's answer put in by hand, case {}", k);
        }
        assert_eq!(whole.record_now((&with, STEP / 1000.0, now)), None, "what neither text of the rules refuses was not recorded");
    }
    #[test]
    fn the_second_text_of_the_rules_takes_nothing_from_the_first() {
        // What a round's work was asked has four things in it: the upgrades, the clicks, when the next
        // moth is due, and what the pointer has hold of. The second text of the rules works each out
        // for itself. The test before this one has a round that turns on the upgrades. Here a round is
        // worked that turns on each of the other three, and the first text is handed an account that
        // has that one thing wrong: the first refuses the round, and the second, which is handed
        // nothing of it, allows it.
        fn judged(before: &Game, after: &Game) -> Game {
            let mut game = before.clone();
            game.spider = after.spider.clone();
            game.world = after.world.clone();
            game.own = after.own.clone();
            game
        }
        fn account(game: &Game) -> Asked {
            let mut own = game.record.own.clone();
            take_in(&mut own, &game.record.spider, &game.asks);
            Asked { buys: own.buys.clone(), clicks: own.clicks.len(), next_moth: own.next_moth, held: own.held() }
        }
        let dt = STEP / 1000.0;
        // A click that takes a moth out of the web.
        let (mut game, mut now) = webbed();
        let mut rounds = 0;
        let moth = loop {
            let halted = in_web(&game.world);
            let found = game.world.moths.iter().find(|m| halted.split(',').any(|id| id == Val::Num(m.id).written()) && pick(&game.spider, m.x + 5.0, m.y - 5.0).is_none()).cloned();
            if let Some(moth) = found {
                break moth;
            }
            play(&mut game, &mut now, 1);
            rounds += 1;
            assert!(rounds < 216000, "after an hour there was no halted moth with the spider out of the way of it");
        };
        game.press(moth.x + 5.0, moth.y - 5.0, now);
        game.release();
        let mut worked = game.clone();
        play(&mut worked, &mut now, 1);
        assert!(worked.halts == 0 && worked.world.tally.picked == game.world.tally.picked + 1.0, "the click took no moth");
        let round = judged(&game, &worked);
        assert_eq!(round.ruled(&account(&game), dt, now), (None, None), "a round with a moth picked in it was refused");
        let said = round.ruled(&Asked { clicks: 0, ..account(&game) }, dt, now);
        assert_eq!(said, (Some("a moth picked out of the web with no click"), None), "handed an account with no click in it");
        // And the second text counts the clicks for itself: with the click taken out of the second
        // list of what was asked alone, it refuses the round and the first allows it.
        let mut unclicked = round.clone();
        unclicked.asks_again.retain(|ask| !matches!(ask, Ask::Press(..)));
        assert_eq!(unclicked.ruled(&account(&game), dt, now), (None, Some("a moth picked out of the web with no click")), "with the click taken out of the second list alone");
        // And the gate hands the texts the account it was given, and no other: given the one with no
        // click in it, it does not record the round.
        let said = round.clone().record_now((&Asked { clicks: 0, ..account(&game) }, dt, now));
        assert_eq!(said.as_deref(), Some("the gate found a step of the work that the rules of the game do not allow: a moth picked out of the web with no click"));
        // A moth arriving.
        let (mut game, mut now) = fresh();
        let mut rounds = 0;
        let (before, after) = loop {
            let before = game.clone();
            play(&mut game, &mut now, 1);
            // a moth has come, and some number given before it is no longer any moth's
            let free = (1..=before.own.next_id as usize).any(|n| !game.world.moths.iter().any(|moth| moth.id == n as f64));
            if game.own.next_id > before.own.next_id && free {
                break (before, game.clone());
            }
            rounds += 1;
            assert!(rounds < 216000 && game.halts == 0, "after an hour no moth had come");
        };
        let round = judged(&before, &after);
        assert_eq!(round.ruled(&account(&before), dt, now), (None, None), "a round with a moth arriving in it was refused");
        let said = round.ruled(&Asked { next_moth: now + 1e9, ..account(&before) }, dt, now);
        assert_eq!(said, (Some("a moth coming before one was due"), None), "handed an account in which no moth was due");
        // Each text is told the time of the round for itself: a minute earlier, the moth came before it was due.
        let due = Some("a moth coming before one was due");
        assert_eq!(round.ruled(&account(&before), dt, now - 60000.0), (due, due), "the round judged as of a minute before");
        // The gate hands on the account and the time it was given, and no others: given an account in
        // which no moth was due, or the time of a minute before, it does not record the round.
        let refused = Some("the gate found a step of the work that the rules of the game do not allow: a moth coming before one was due".to_string());
        assert_eq!(round.clone().record_now((&Asked { next_moth: now + 1e9, ..account(&before) }, dt, now)), refused, "given an account in which no moth was due");
        assert_eq!(round.clone().record_now((&account(&before), dt, now - 60000.0)), refused, "given the time of a minute before");
        assert_eq!(round.clone().record_now((&account(&before), dt, now)), None, "the round with a moth arriving was not recorded");
        // And each is told the number the last moth was given: a moth that comes with a number given
        // before is refused by each.
        let used = (1..=before.own.next_id as usize).map(|n| n as f64).find(|n| !after.world.moths.iter().any(|moth| moth.id == *n)).unwrap_or(f64::NAN);
        let mut again = round.clone();
        for moth in again.world.moths.iter_mut().filter(|moth| moth.id > before.own.next_id) {
            moth.id = used;
        }
        let said = again.ruled(&account(&before), dt, now);
        assert!(said.0.is_some() && said.0 == said.1, "a moth come with a number given before: {:?}", said);
        let told = wrong_step((&before.record.spider, &before.record.world), &in_web(&before.record.world), 0.0, (&again.spider, &again.world), &account(&before), dt, now);
        assert_ne!(told, said.0, "told that no moth has had a number, the rule that holds the number was not what refused it");
        // The spider held by the pointer.
        let (before, mut now) = carried();
        let mut after = before.clone();
        play(&mut after, &mut now, 1);
        let (round, with) = (judged(&before, &after), account(&before));
        assert!(with.held.is_some() && after.halts == 0);
        assert_eq!(round.ruled(&with, dt, now), (None, None), "a round with the spider held in it was refused");
        // which the first text refuses for the first rule that turns on the holding: how fast the food goes
        let said = round.ruled(&Asked { held: None, ..account(&before) }, dt, now);
        assert!(said.0.is_some() && said.1.is_none(), "handed an account in which nothing was held: {:?}", said);
        // and the gate hands that account on as it was given it: it does not record the round
        let said = round.clone().record_now((&Asked { held: None, ..account(&before) }, dt, now));
        assert!(said.as_ref().map_or(false, |why| why.starts_with("the gate found a step of the work that the rules of the game do not allow: ")), "given an account in which nothing was held: {:?}", said);
        assert_eq!(round.clone().record_now((&with, dt, now)), None, "the round with the spider held was not recorded");
        // And what the pointer has hold of is worked out by the second text of the work, once for each asking.
        let passed = || again::PASSED.with(|passed| passed.borrow().get("in_hand").copied().unwrap_or(0));
        let was = passed();
        round.ruled(&with, dt, now);
        assert_eq!(passed(), was + 1, "the second text of the rules was not handed the second text's account of what the pointer holds");
    }
    /// For the tests: is every list and every text that the game holds of a size that is looked at?
    fn sized(game: &Game) -> bool {
        let state = |spider: &Spider, world: &World, own: &Own| {
            spider.legs.len() <= MOST_HELD
                && world.moths.len() <= MOST_HELD
                && own.clicks.len() <= MOST_HELD
                && own.buys.len() <= MOST_HELD
                && own.gains.len() <= MOST_HELD
                && spider.body.state.len() <= 131_072
                && world.web.torn.len() <= 131_072
        };
        state(&game.spider, &game.world, &game.own)
            && state(&game.record.spider, &game.record.world, &game.record.own)
            && game.record.texts.len() <= MOST_HELD
            && game.record.texts.iter().all(|text| text.len() <= MOST_HELD_TEXT)
            && game.before.iter().flatten().all(|kept| state(&kept.0, &kept.1, &kept.2))
            && game.ring.len() <= MOST_HELD
            && game.ring.iter().all(|o| o.copies.len() <= MOST_HELD && o.copies.iter().chain([&o.name, &o.held, &o.why]).all(|text| text.len() <= MOST_HELD_TEXT))
            && [&game.asks, &game.asks_again, &game.asks_third].iter().all(|asks| asks.len() <= MOST_HELD)
            // and the two sizes are what they are said to be
            && (MOST_HELD, MOST_HELD_TEXT) == (1024, 1_048_576)
    }
    #[test]
    fn what_a_fault_makes_very_large_is_cut_down_before_it_is_looked_at() {
        // One list in the game is made a million entries long, the observers a hundred thousand, or one text
        // sixty-four million characters.
        // That is more than a round can write out, copy and compare in the time the observers give the
        // rounds before they take them to have stopped. It is cut down before anything looks at it. What
        // is left of it is found like any other change, or written over, and the game goes on.
        let faults: [(&str, fn(&mut Game)); 23] = [
            // moths with numbers no moth has had, lying where a halted moth lies: the second doing looks
            // each one up among the halted ones
            ("moths no game has had, in the gate's copy, where a halted moth lies", |game| {
                let halted = in_web(&game.record.world);
                let at = game.record.world.moths.iter().find(|moth| halted.split(',').any(|id| id == Val::Num(moth.id).written())).cloned();
                if let Some(at) = at {
                    game.record.world.moths.extend((0..60_000).map(|k| {
                        let mut moth = at.clone();
                        moth.id = 1e9 + k as f64;
                        moth
                    }));
                }
            }),
            ("the moths in the first place of the state kept from the round before", |game| {
                if let Some(kept) = game.before[0].as_mut() {
                    kept.1.moths = vec![kept.1.moths[0].clone(); 1_000_000];
                }
            }),
            ("the moths in the last place of the state kept from the round before", |game| {
                if let Some(kept) = game.before[2].as_mut() {
                    kept.1.moths = vec![kept.1.moths[0].clone(); 1_000_000];
                }
            }),
            ("the upgrades taken in", |game| game.own.buys = vec![UPGRADES[0].0; 1_000_000]),
            ("the web's torn strands", |game| game.world.web.torn = "7,".repeat(32_000_000)),
            ("one observer's name", |game| game.ring[2].name = "x".repeat(64_000_000)),
            ("the moths observer's list", |game| game.ring[MOTHS].held = "7,".repeat(32_000_000)),
            ("one observer's reason", |game| game.ring[6].why = "x".repeat(64_000_000)),
            ("the second list of what was asked", |game| game.asks_again = vec![Ask::Release; 1_000_000]),
            ("the third list of what was asked", |game| game.asks_third = vec![Ask::Release; 1_000_000]),
            ("the moths", |game| game.world.moths = vec![game.world.moths[0].clone(); 1_000_000]),
            ("the legs", |game| game.spider.legs = vec![game.spider.legs[0].clone(); 1_000_000]),
            ("the catches", |game| game.own.gains = vec![crate::game::Gain { n: 1.0, x: 1.0, y: 1.0, worth: 1.0, at: game.time }; 1_000_000]),
            ("the clicks taken in", |game| game.own.clicks = vec![(1.0, 1.0); 1_000_000]),
            ("what the body is doing", |game| game.spider.body.state = "x".repeat(64_000_000)),
            ("the moths in the gate's copy", |game| game.record.world.moths = vec![game.record.world.moths[0].clone(); 1_000_000]),
            ("the texts of the gate's record", |game| game.record.texts = vec![String::new(); 1_000_000]),
            ("one text of the gate's record", |game| game.record.texts[4] = "x".repeat(64_000_000)),
            ("the moths in one place of the state kept from the round before", |game| {
                if let Some(kept) = game.before[1].as_mut() {
                    kept.1.moths = vec![kept.1.moths[0].clone(); 1_000_000];
                }
            }),
            // a hundred thousand of these: an observer is many texts, and making a million takes longer than a round
            ("the observers", |game| game.ring = vec![game.ring[0].clone(); 100_000]),
            ("one observer's copies", |game| game.ring[1].copies = vec![String::new(); 1_000_000]),
            ("one observer's copy", |game| game.ring[5].copies[4] = "x".repeat(64_000_000)),
            ("the first list of what was asked", |game| game.asks = vec![Ask::Release; 1_000_000]),
        ];
        let mut longest = (Duration::ZERO, String::new());
        for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
            for (what, fault) in faults {
                // between two rounds, inside a round before the observers are asked, after the work,
                // between the gate's look and the work, before the record is written, and between the
                // rules and the second doing of the work
                for when in 0..6 {
                    let what = format!("{}, {:?}, at instant {}", what, how, when);
                    let (mut game, mut now) = webbed();
                    game.set_how(how);
                    match when {
                        0 => fault(&mut game),
                        1 => game.early = Some(fault),
                        2 => game.fault = Some(fault),
                        3 => game.late = Some((0, fault)),
                        4 => game.late = Some((1, fault)),
                        _ => game.late = Some((3, fault)),
                    }
                    let began = Instant::now();
                    assert!(!guarded(&mut game, &mut now), "{}: the round stopped in the wrong place", what);
                    if began.elapsed() > longest.0 {
                        longest = (began.elapsed(), what.clone());
                    }
                    game.fault = None;
                    game.late = None;
                    // whatever the setting, and whether or not the halt has ended, nothing is left of that size
                    assert!(sized(&game), "{}: something of that size is still held", what);
                    // what landed after the work in something the round did not read is found at the start of the next
                    let began = Instant::now();
                    assert!(!guarded(&mut game, &mut now), "{}: the round after stopped in the wrong place", what);
                    if began.elapsed() > longest.0 {
                        longest = (began.elapsed(), what.clone());
                    }
                    assert!(sized(&game) && game.halts <= 1 && !game.stuck(), "{}: {}", what, game.why());
                    // between two rounds there is no work to write it over: it is found, every time
                    if when == 0 {
                        assert_eq!(game.halts, 1, "{}: it was not found", what);
                    }
                    game.put_right();
                    for _ in 0..3 {
                        assert!(!guarded(&mut game, &mut now), "{}", what);
                    }
                    assert!(!game.halted() && game.halts <= 1 && game.restarts == game.halts && game.games == 1 && sized(&game), "{}: {}", what, game.why());
                    assert!(game.ring.len() == NAMES.len() && game.record.texts.len() == PARTS.len() && game.differs().is_empty(), "{}: the game is not whole again", what);
                }
            }
        }
        println!("the longest round with something made very large in it: {:?}, with {}", longest.0, longest.1);
        // A round that had to write a million of anything out would take seconds. The making of the
        // large thing is counted in this time, and takes most of it.
        assert!(longest.0 < Duration::from_secs(1), "a round with {} took {:?}", longest.1, longest.0);
        // A line at the backdoor that comes before the next round reads a whole list, or copies the game
        // to try itself on. What has been made large is cut down before it does.
        for line in ["world", "world.moths", "spider", "during world.tally.caught += 5"] {
            let (mut game, _) = webbed();
            game.world.moths = vec![game.world.moths[0].clone(); 1_000_000];
            game.spider.legs = vec![game.spider.legs[0].clone(); 1_000_000];
            // and not in the state only: in the gate's copy, in an observer and in a list of what was asked
            game.record.world.moths = vec![game.record.world.moths[0].clone(); 1_000_000];
            game.ring[1].copies = vec![String::new(); 1_000_000];
            game.asks = vec![Ask::Release; 1_000_000];
            let began = Instant::now();
            backdoor::run(&mut game, line);
            assert!(sized(&game) && began.elapsed() < Duration::from_secs(1), "{}: {:?}", line, began.elapsed());
        }
        // In a halt that cannot be put right a round and a line at the backdoor leave the game's state
        // as it is, and the cutting down keeps to that: a list made long there is left as it is. What
        // the gate keeps from the round before is still compared in such a halt, and so is still cut.
        let (mut game, mut now) = webbed();
        game.fail("the game's own work stopped where it should not have", now);
        game.spider.legs = vec![game.spider.legs[0].clone(); 5000];
        let kept = Some(Box::new((game.spider.clone(), game.world.clone(), game.own.clone())));
        game.before = [kept.clone(), kept.clone(), kept];
        // each of the three places is cut, and not one or two of them with the rest left to be settled
        let mut cut = game.clone();
        cut.fit_kept();
        assert!(cut.before.iter().flatten().all(|kept| kept.0.legs.len() == MOST_HELD), "a place of what the gate keeps from the round before was not cut");
        for _ in 0..3 {
            assert!(!guarded(&mut game, &mut now));
        }
        // a line at the backdoor reads the state there, and cuts nothing of it
        for line in ["spider", "world", "spider.legs"] {
            backdoor::run(&mut game, line);
        }
        assert!(game.stuck() && game.spider.legs.len() == 5000, "in a halt that cannot be put right the state was touched: {} legs", game.spider.legs.len());
        assert!(game.before.iter().flatten().all(|kept| kept.0.legs.len() == MOST_HELD), "what the gate keeps from the round before was not cut down");
    }
    #[test]
    fn the_copies_are_apart_in_the_program_as_built() {
        // Eight copies of the rule and two texts of the work are of no use as copies if the program as it
        // is built holds one of each. Each carries a mark of its own so that it does not, and the program
        // checks at its start that the eight rules are eight functions and that the second doing is not
        // called by the functions of the first. This is that check, on the tests as they are built.
        assert!(looks::all_apart(), "two copies of the rule are one function");
        assert!(copies_apart(), "the second doing of the work is called by a function of the first");
    }
    #[test]
    fn what_is_asked_is_taken_down_three_times_and_one_list_gone_wrong_loses_nothing() {
        // A press, an upgrade and the pointer's place have been asked and not yet taken in. Then one of
        // the three lists is changed: something put in, something taken out, the list emptied, a place
        // moved. The gate finds that the three differ, everything halts, the list is put right from the
        // other two, and the round takes in what was asked: the game is where a game that was never
        // touched is, with the press and the upgrade acted on.
        let found = "the gate found what was asked of the game not the same in the three places it is taken down, and no observer had flagged it";
        let did = "what was asked of the game put right from the two places that agreed, all eight observers started again";
        let faults: [fn(&mut Vec<Ask>); 4] = [|asks| asks.push(Ask::Buy("web")), |asks| { asks.pop(); }, |asks| asks.clear(), |asks| asks[0] = Ask::Press(1.0, 1.0, 0.0)];
        for base in [webbed(), carried()] {
            let (mut game, now) = base;
            game.point(W * 0.5, H * 0.5, true, now);
            game.press(W * 0.25, H * 0.25, now);
            game.buy("spawn");
            assert!(game.asks.len() == 3 && game.asks == game.asks_again && game.asks == game.asks_third);
            let base = (game, now);
            for fault in faults {
                mended(&base, "the first list", &|game| fault(&mut game.asks), found, did);
                mended(&base, "the second list", &|game| fault(&mut game.asks_again), found, did);
                mended(&base, "the third list", &|game| fault(&mut game.asks_third), found, did);
            }
            // Two of the three changed, each another way: nothing says what was asked. None of it is taken, and the pointer is made to let go.
            let (mut game, mut now) = base.clone();
            game.asks.clear();
            game.asks_third.push(Ask::Buy("web"));
            play(&mut game, &mut now, 1);
            play(&mut game, &mut now, 120);
            assert!(!game.halted() && (game.halts, game.restarts) == (1, 1), "{}", game.why());
            assert!(game.fixed.as_ref().map_or(false, |(did, _)| did.starts_with("what was asked of the game put aside, and the pointer made to let go")), "{:?}", game.fixed);
        }
    }
    #[test]
    fn the_hold_on_the_observers_threads_is_in_three_places() {
        // The game's hold on its observers' threads is kept in three places. One of them is changed to
        // hold nothing. Read by itself, that would have the round run the observers together in its own
        // thread, and the eight threads, hearing nothing more, take the rounds to have stopped. The two
        // places that agree are what is read: the threads are still asked. The gate finds the place before
        // the round, everything halts, it is put right, and no observer takes the rounds to have stopped.
        use std::sync::atomic::{AtomicU32, Ordering};
        static STOPPED: AtomicU32 = AtomicU32::new(0);
        fn stopped(_: u64) {
            STOPPED.fetch_add(1, Ordering::SeqCst);
        }
        let found = "the gate found that one of the three places that hold the observers' threads no longer agreed with the other two, and no observer had flagged it";
        for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
            for place in 0..3 {
                let what = format!("place {}, {:?}", place, how);
                let (mut game, mut now) = webbed();
                game.set_how(how);
                game.run_apart(Apart::start_with(stopped, (3, Duration::from_millis(150)), (400, Duration::from_millis(5))));
                play(&mut game, &mut now, 30);
                let before = all(&game);
                game.apart[place] = None;
                assert!(game.threads().is_some(), "{}: the changed place was read", what);
                play(&mut game, &mut now, 1);
                assert_eq!(game.why.as_deref(), Some(found), "{}", what);
                assert!(game.apart.iter().all(|held| same_hold(held, &game.apart[0])) && game.apart[0].is_some(), "{}: the three places do not agree again", what);
                if how != How::AtOnce {
                    assert!(game.halted() && all(&game) == before, "{}: something moved", what);
                }
                game.put_right();
                for _ in 0..70 {
                    play(&mut game, &mut now, 1);
                    std::thread::sleep(Duration::from_millis(10));
                }
                assert!(!game.halted() && (game.halts, game.restarts) == (1, 1), "{}: {}", what, game.why());
                assert_eq!(STOPPED.load(Ordering::SeqCst), 0, "{}: an observer took the rounds to have stopped", what);
            }
        }
        // Two places changed, each another way: nothing says which is right.
        let (mut game, mut now) = webbed();
        game.run_apart(patient());
        game.apart[0] = None;
        game.apart[1] = Some(patient());
        play(&mut game, &mut now, 2);
        assert!(game.stuck() && game.why().starts_with("it could not be put right: no two of the three places that hold the observers' threads"), "{}", game.why());
    }
    #[test]
    fn the_eight_copies_of_the_rule_are_one_rule() {
        // Each observer looks by its own copy of the rule. The eight must say the same of everything: here,
        // of every observer's look at a game with each of many faults in it, as it is before a round and as
        // a round would show it. A copy changed by itself fails this.
        let lines = [
            "spider.body.x += 150",
            "spider.legs[3].x += 1",
            "world.tally.gained = 1000000",
            "world.edge.inset += 1",
            "world.web.age += 1",
            "world.moths.push()",
            "spider.ring[0].alive = false",
            "world.ring[1].alive = false",
            "spider.ring[3].flagged = true",
            "spider.ring[2].beat += 1",
            "world.ring[2].beat = NaN",
            "spider.ring[1].name = \"x\"",
            "world.ring[1].held = \"1,2,3\"",
            "world.ring[0].why = \"x\"",
            "spider.ring[0].copies[0] = \"\"",
            "spider.ring[3].copies[2] = \"1\"",
            "world.ring[3].copies[4] = \"1\"",
            "world.ring[*].copies[5] = \"\"",
            "spider.ring[1].copies[4] = \"x\"",
            "spider.ring[0].held = \"1\"",
            "world.ring[0].held = \"1,2\"",
        ];
        let direct: [fn(&mut Game); 9] = [
            |game| drop(game.ring[1].copies.pop()),
            |game| game.ring[6].copies.clear(),
            |game| game.own.next_id += 1.0,
            |game| game.spider.legs.truncate(7),
            |game| game.ring[1].copies.push(String::new()),
            |game| game.ring[4].copies.push("x".into()),
            |game| game.ring.push(game.ring[0].clone()),
            |game| drop(game.ring.pop()),
            |game| drop(game.ring.remove(3)),
        ];
        let mut games: Vec<Game> = vec![webbed().0, carried().0, fresh().0];
        // Every kind of thing that can go wrong in an observer, in each of the eight in turn, by each
        // name the backdoor has for it: a copy of the rule that did not mind one of them would differ.
        let mut each: Vec<String> = Vec::new();
        for at in ["spider.ring[0]", "spider.ring[1]", "spider.ring[2]", "spider.ring[3]", "world.ring[0]", "world.ring[1]", "world.ring[2]", "world.ring[3]", "world.ring[4]"] {
            for wrong in ["alive = false", "beat += 1", "beat = NaN", "name = \"x\"", "why = \"x\"", "held = \"1\"", "flagged = true", "copies[0] = \"x\"", "copies[4] = \"x\"", "copies[6] = \"x\""] {
                each.push(format!("{}.{}", at, wrong));
            }
        }
        for line in &each {
            let (mut game, before) = (webbed().0, webbed().0);
            backdoor::run(&mut game, line);
            assert!(!game.same_state(&before), "{}: nothing was changed by it", line);
            games.push(game);
        }
        for base in [webbed(), carried()] {
            for line in lines {
                let mut game = base.0.clone();
                backdoor::run(&mut game, line);
                games.push(game);
            }
            for fault in direct {
                let mut game = base.0.clone();
                fault(&mut game);
                games.push(game);
            }
        }
        let mut said = std::collections::BTreeSet::new();
        for game in &games {
            for look in [game.look(game.rounds), game.look(game.rounds - 1.0)] {
                for i in 0..NAMES.len().min(look.ring.len()) {
                    let first = looks::LOOKS[0](i, &look);
                    for (k, rule) in looks::LOOKS.iter().enumerate() {
                        assert_eq!(rule(i, &look), first, "the {} observer's copy of the rule, looking as the {} observer", NAMES[k], NAMES[i]);
                    }
                    said.insert(first.replace(NAMES[i], ""));
                }
            }
        }
        assert!(said.len() >= 12 && said.contains(""), "the looks said too few different things to tell the copies apart by: {:?}", said);
        // Each copy looks first at whether it has been given eight observers and seven parts. A text too
        // few or too many, or an observer too few, is what each of the eight copies finds, as each observer.
        let whole = webbed().0;
        let parts = "it was no longer given seven parts to look at";
        let spoils: [(fn(&mut Look), &str); 3] = [(|look| drop(look.texts.pop()), parts), (|look| look.texts.push(String::new()), parts), (|look| drop(look.ring.pop()), "there were no longer eight observers")];
        for (spoil, found) in spoils {
            let mut look = whole.look(whole.rounds - 1.0);
            spoil(&mut look);
            for (k, rule) in looks::LOOKS.iter().enumerate() {
                for i in 0..NAMES.len() {
                    assert_eq!(rule(i, &look), format!("the {} observer found that {}", NAMES[i], found), "the {} observer's copy of the rule", NAMES[k]);
                }
            }
        }
    }
    #[test]
    fn nothing_is_written_in_a_halt_that_cannot_be_put_right() {
        // In a halt that cannot be put right no observer looks, and the backdoor writes nothing: it
        // refuses every write, and still reads while its two counts are right.
        let (mut game, now) = webbed();
        game.fail("the game's own work stopped where it should not have", now);
        let before = (all(&game), game.ring.iter().map(|o| o.written()).collect::<Vec<_>>());
        for line in ["spider.body.x += 150", "world.moths.push()", "world.moths.pop()", "spider.ring[*].alive = false", "world.tally.gained = 1000000; spider.body.gen = 9"] {
            assert!(backdoor::run(&mut game, line).contains("nothing is written to it until it is begun again"), "{}", line);
        }
        assert!(before == (all(&game), game.ring.iter().map(|o| o.written()).collect::<Vec<_>>()), "something was written");
        assert_eq!(backdoor::run(&mut game, "spider.body.gen"), "1");
    }
    /// Every kind of thing the gate keeps of its own, each changed in one place.
    const OWN_FAULTS: [(&str, fn(&mut Book)); 25] = [
        ("how often the program has stopped in the wrong place", |book| book.stops = 1),
        ("the game's own time", |book| book.time += 3600000.0),
        ("the game's own time, made no number", |book| book.time = f64::NAN),
        ("the number of the round", |book| book.rounds += 5.0),
        ("the number of the round, made no number", |book| book.rounds = f64::NAN),
        ("the number of the round, to where one more is no more", |book| book.rounds = f64::INFINITY),
        ("when the last round was", |book| book.at += 5000.0),
        ("when the last round was, made no number", |book| book.at = f64::NAN),
        ("a halt that is not there, one that cannot be put right and has been asked to end", |book| book.halt = Some(Halt { why: "x".into(), quiet: 0.0, last: String::new(), asked: true, stuck: true, aside: false, put: Vec::new() })),
        ("a halt that is not there, an ordinary one", |book| book.halt = Some(Halt { why: "x".into(), quiet: 1.0e12, last: String::new(), asked: false, stuck: false, aside: true, put: Vec::new() })),
        ("how a halt ends", |book| book.how = if book.how == How::AtOnce { How::AfterAPause } else { How::AtOnce }),
        ("why the last halt was", |book| book.why = Some("x".into())),
        ("what was done about the last halt", |book| book.fixed = Some(("x".into(), f64::NAN))),
        ("the count of halts", |book| book.halts += 7),
        ("the count of halts, to its end", |book| book.halts = u64::MAX),
        ("the count of restarts", |book| book.restarts += 7),
        ("when it was last calm", |book| book.calm_since = f64::NAN),
        ("when it was last calm, by the sign of nothing", |book| book.calm_since = -book.calm_since * 0.0),
        ("how many rounds have gone wrong running", |book| book.spoiled = 9),
        ("a line to be written during the work", |book| book.inside.push("spider.body.x = 1".into())),
        ("what was written during the last round's work", |book| book.pending.push("spider.body.x = 1".into())),
        ("the count of what was let through", |book| book.passed += 1),
        ("the count of games", |book| book.games += 1),
        ("the last of what was let through", |book| book.let_through = Some("x".into())),
        ("what could not be written", |book| {
            book.unwritten += 1;
            book.not_written = Some("x".into());
        }),
    ];
    #[test]
    fn a_change_to_one_place_of_what_the_gate_keeps_of_its_own_is_never_read_and_is_put_right() {
        // What the gate keeps of its own is in three places. One of them is changed, every kind of thing in
        // it in turn. Until the next round, everything that is read of it and everything a screen is sent is
        // what it was: the two places that agree are what is read. In the next round the gate finds it,
        // everything halts, the place is put right from the other two, and the game goes on where a game
        // that was never touched is.
        let found = "the gate found that one of the three places where it keeps what is its own no longer agreed with the other two, and no observer had flagged it";
        let did = "what the gate keeps of its own put right from the two places that agreed, all eight observers started again";
        let mut tested = 0;
        for base in [webbed(), carried()] {
            for (what, fault) in OWN_FAULTS {
                for place in 0..3 {
                    let what = format!("{}, in place {}", what, place);
                    // before the round: nothing that is read has changed
                    let (mut game, now) = base.clone();
                    game.set_how(How::AtOnce);
                    let twin = game.clone();
                    fault(&mut game.books[place]);
                    assert!(!game.books[place].same(&twin.books[place]), "{}: the fault changed nothing", what);
                    assert!(game.same(&twin) && game.shown(now) == twin.shown(now) && game.halted() == twin.halted() && game.stuck() == twin.stuck(), "{}: the changed place was read", what);
                    // the round, and after
                    mended(&base, &what, &|game| fault(&mut game.books[place]), found, did);
                    tested += 1;
                }
            }
        }
        assert_eq!(tested, 2 * 25 * 3);
        // The same under the other two settings: it halts with nothing moved, and is put right as any halt is.
        for how in [How::AfterAPause, How::OnAClick] {
            for (what, fault) in OWN_FAULTS {
                let (mut game, mut now) = webbed();
                game.set_how(how);
                let before = all(&game);
                fault(&mut game.books[1]);
                play(&mut game, &mut now, 1);
                assert!(game.halted() && !game.stuck() && game.why() == found && all(&game) == before, "{} {:?}: {}", what, how, game.why());
                assert!(game.books[0].same(&game.books[1]) && game.books[0].same(&game.books[2]), "{} {:?}: the three places do not agree again", what, how);
                assert_eq!(game.how, how, "{}", what);
                if how == How::OnAClick {
                    play(&mut game, &mut now, 300);
                    assert!(game.halted() && all(&game) == before, "{}: it did not wait to be asked", what);
                    game.put_right();
                }
                play(&mut game, &mut now, 120);
                assert!(!game.halted() && (game.halts, game.restarts, game.games) == (1, 1, 1) && game.spider.body.x != 1.0, "{} {:?}: {}", what, how, game.why());
                play(&mut game, &mut now, 600);
                assert_eq!(game.halts, 1, "{} {:?}: {}", what, how, game.why());
            }
        }
    }
    #[test]
    fn a_change_to_one_place_while_everything_is_halted_does_not_end_the_halt_or_lose_the_game() {
        // Everything is halted, waiting to be asked. Then one place of what the gate keeps of its own is
        // changed: it says there is no halt, or that the halt has been asked to end, or that it cannot be put
        // right. That is a second fault before the first is put right, which is more than is claimed. It is
        // here because the three places give it: the halt stays as it was, and ends when it is asked to.
        let faults: [(&str, fn(&mut Book)); 4] = [
            ("no halt", |book| book.halt = None),
            ("asked to end", |book| book.halt.as_mut().unwrap().asked = true),
            ("cannot be put right", |book| book.halt.as_mut().unwrap().stuck = true),
            ("cannot be put right, and asked", |book| {
                book.halt.as_mut().unwrap().stuck = true;
                book.halt.as_mut().unwrap().asked = true;
            }),
        ];
        for (what, fault) in faults {
            for place in 0..3 {
                let (mut game, mut now) = webbed();
                game.set_how(How::OnAClick);
                backdoor::run(&mut game, "spider.body.x += 150");
                play(&mut game, &mut now, 3);
                assert!(game.halted(), "{}", what);
                let why = game.why();
                fault(&mut game.books[place]);
                play(&mut game, &mut now, 300);
                assert!(game.halted() && !game.stuck() && game.why() == why && (game.halts, game.restarts, game.games) == (1, 0, 1), "{}, in place {}: {}", what, place, game.why());
                assert!(game.books[0].same(&game.books[1]) && game.books[0].same(&game.books[2]), "{}, in place {}", what, place);
                game.put_right();
                play(&mut game, &mut now, 3);
                assert!(!game.halted() && (game.halts, game.restarts, game.games) == (1, 1, 1), "{}, in place {}: {}", what, place, game.why());
            }
        }
    }
    #[test]
    fn where_no_two_places_of_what_the_gate_keeps_agree_nothing_can_be_put_right() {
        // Two of the three places changed, each another way: two faults. No two agree, nothing says which
        // is right, and the halt cannot be put right. The game can still be begun again.
        let (mut game, mut now) = webbed();
        game.books[0].halts += 7;
        game.books[2].halts += 9;
        play(&mut game, &mut now, 2);
        assert!(game.stuck() && game.why().starts_with("it could not be put right: no two of the three places"), "{}", game.why());
        let before = all(&game);
        play(&mut game, &mut now, 300);
        assert!(game.stuck() && all(&game) == before);
        game.put_right();
        play(&mut game, &mut now, 2);
        assert!(!game.halted() && game.games == 2, "{}", game.why());
    }
    #[test]
    fn a_change_to_one_place_of_what_the_observers_threads_are_run_by_is_put_right() {
        // Each observer on a thread of its own. What the threads are run by is in three places, and one is
        // changed: the round would wait for no answer at all, or take no answer as this starting's, or an
        // observer would take the rounds to have stopped at once. The two places that agree are what is
        // read, so no observer is taken for silent. The gate finds the changed place before the round,
        // everything halts, it is put right, and the game goes on.
        let faults: [(&str, fn(&mut Run)); 4] = [
            ("no wait for answers", |run| run.waits = (0, Duration::ZERO)),
            ("another starting", |run| run.start += 5),
            ("no quiet before the rounds are taken to have stopped", |run| run.quiet = (0, Duration::ZERO)),
            ("something else to do when the rounds stop", |run| run.stopped = |_| panic!("this is not what was given")),
        ];
        let found = "the gate found that one of the three places that hold what the observers' threads are run by no longer agreed with the other two, and no observer had flagged it";
        for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
            for (what, fault) in faults {
                for place in 0..3 {
                    let what = format!("{}, in place {}, {:?}", what, place, how);
                    let (mut game, mut now) = webbed();
                    game.set_how(how);
                    let apart = patient();
                    game.run_apart(apart.clone());
                    play(&mut game, &mut now, 30);
                    assert_eq!(game.halts, 0, "{}: {}", what, game.why());
                    let before = all(&game);
                    apart.change(place, fault);
                    play(&mut game, &mut now, 1);
                    assert_eq!(game.why.as_deref(), Some(found), "{}", what);
                    assert!(apart.settle().is_none(), "{}: the three places do not agree again", what);
                    if how != How::AtOnce {
                        assert!(game.halted() && all(&game) == before, "{}: something moved", what);
                    }
                    if how == How::OnAClick {
                        game.put_right();
                    }
                    play(&mut game, &mut now, 120);
                    assert!(!game.halted() && (game.halts, game.restarts) == (1, 1), "{}: {}", what, game.why());
                    assert!(game.fixed.as_ref().map_or(false, |(did, _)| did.starts_with("what the observers' threads are run by put right")), "{}", what);
                    play(&mut game, &mut now, 300);
                    assert_eq!(game.halts, 1, "{}: {}", what, game.why());
                }
            }
        }
        // Two places changed, each another way: nothing says which is right.
        let (mut game, mut now) = webbed();
        let apart = patient();
        game.run_apart(apart.clone());
        apart.change(0, |run| run.start += 5);
        apart.change(1, |run| run.start += 6);
        play(&mut game, &mut now, 2);
        assert!(game.stuck() && game.why().starts_with("it could not be put right: no two of the three places that hold"), "{}", game.why());
    }
    #[test]
    fn an_observer_or_a_copy_too_many_or_too_few_is_a_change_like_any_other() {
        // There are eight observers, and each holds a place for every part. One observer more or one fewer,
        // or one observer's list of copies a place longer or shorter: it is found, everything halts, eight
        // new observers are started, and the game goes on where a game that was never touched is.
        let did = "all eight observers started again";
        let number = "the gate found that the number of observers had changed, and no observer had flagged it";
        for base in [webbed(), carried()] {
            // where it was the number of observers, the gate says that it put its counts right
            let counted = "the gate's counts put right, all eight observers started again";
            mended(&base, "an observer too many", &|game| game.ring.push(game.ring[0].clone()), number, counted);
            mended(&base, "the last observer gone", &|game| drop(game.ring.pop()), number, counted);
            mended(&base, "an observer gone from the middle", &|game| drop(game.ring.remove(2)), number, counted);
            mended(&base, "no observers", &|game| game.ring.clear(), number, counted);
            mended(&base, "a copy too few", &|game| drop(game.ring[1].copies.pop()), "the legs B observer has been changed", did);
            mended(&base, "a copy too many", &|game| game.ring[1].copies.push("x".into()), "the legs B observer has been changed", did);
            mended(&base, "no copies", &|game| game.ring[5].copies.clear(), "the moths observer's copy of the edge differs from the whole observer's", did);
            mended(&base, "a coordinator's copies, too few", &|game| game.ring[3].copies.truncate(1), "the whole observer's copy of the second set of legs differs from the legs A observer's", did);
        }
        // The same with each observer on a thread of its own, under each way a halt can end.
        let faults: [fn(&mut Game); 4] = [|game| game.ring.push(game.ring[0].clone()), |game| drop(game.ring.remove(2)), |game| drop(game.ring[1].copies.pop()), |game| game.ring[5].copies.clear()];
        for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
            for (k, fault) in faults.iter().enumerate() {
                let (mut game, mut now) = webbed();
                game.set_how(how);
                game.run_apart(patient());
                play(&mut game, &mut now, 30);
                fault(&mut game);
                play(&mut game, &mut now, 1);
                assert!(game.halts == 1 && !game.stuck(), "{} {:?}: {}", k, how, game.why());
                if how == How::OnAClick {
                    play(&mut game, &mut now, 30);
                    game.put_right();
                }
                play(&mut game, &mut now, 120);
                assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && game.ring.len() == 8 && game.ring.iter().all(|o| o.copies.len() == PARTS.len()), "{} {:?}: {}", k, how, game.why());
                play(&mut game, &mut now, 300);
                assert_eq!(game.halts, 1, "{} {:?}: {}", k, how, game.why());
            }
        }
    }
    #[test]
    fn the_length_of_a_round_comes_from_the_gates_own_note_of_the_last() {
        // Two games from one beginning. One is given the length of each round. The other is given only
        // the time, and works the length out from its own note of when the last round was. They go alike.
        // The second also keeps its own time, moved on by each round's length, and that must be the
        // time the first is given.
        let (mut one, mut now) = webbed();
        let mut other = one.clone();
        let mut time = now;
        for _ in 0..300 {
            let last = now;
            now += STEP;
            let dt = ((now - last) / 1000.0).min(0.05).max(0.0);
            time += dt * 1000.0;
            one.round(dt, time);
            other.round_at(now);
            assert!(one.same_state(&other) && other.halts == 0 && other.time() == time, "{}", other.why());
        }
        // The note changed in one of its three places, to a time long past or to no number: the round is no
        // longer for it. The gate finds the place, as it finds any other, and the game goes on alike.
        for fault in [|book: &mut Book| book.at -= 60000.0, |book: &mut Book| book.at = f64::NAN, |book: &mut Book| book.at += 60000.0] {
            // read while one place is changed, the length is what the two that agree give
            for place in 0..3 {
                let mut changed = other.clone();
                fault(&mut changed.books[place]);
                assert_eq!(changed.length(now + STEP).to_bits(), other.length(now + STEP).to_bits(), "the changed place was read: {}", place);
            }
            let (mut one, mut other) = (one.clone(), other.clone());
            let mut now = now;
            one.set_how(How::AtOnce);
            other.set_how(How::AtOnce);
            fault(&mut other.books[0]);
            let mut time = time;
            for _ in 0..120 {
                let last = now;
                now += STEP;
                let dt = ((now - last) / 1000.0).min(0.05).max(0.0);
                time += dt * 1000.0;
                one.round(dt, time);
                other.round_at(now);
            }
            assert!(one.same_state(&other) && (other.halts, other.restarts, other.halted()) == (1, 1, false), "{}", other.why());
        }
        // A clock that cannot be read comes as no number. It gives rounds of the ordinary length, as many
        // as there are, and leaves the note of the last reading alone, so that the first round after it is
        // as long as it has been since that reading, and a twentieth of a second at the most.
        let (mut game, now) = webbed();
        let (time, at) = (game.time(), game.at);
        for round in 1..=6 {
            game.round_at(f64::NAN);
            assert!(game.halts == 0 && game.at == at && (game.time() - time - round as f64 * 1000.0 / 60.0).abs() < 1e-6, "{}: {}", round, game.time() - time);
        }
        game.round_at(now + STEP);
        assert!(game.halts == 0 && (game.time() - time - 100.0 - STEP).abs() < 1e-6, "{}", game.time() - time);
        // The program's first round: told what the clock says when it starts, the game's first round is as
        // long as it has been since, and not the twentieth of a second a round may be at the most.
        let mut game = Game::new(0.0, 7);
        game.clocked(1.7e12);
        game.round_at(1.7e12 + STEP);
        assert!((game.time() - STEP).abs() < 1e-3 && game.halts == 0, "the first round was {} thousandths long", game.time());
        // A clock that stands still, goes back, or jumps an hour ahead: a round of no length, and one of
        // a twentieth of a second at the most. The game's own time moves by that and no more, so nothing
        // that waits for a time comes due because the clock jumped.
        let (mut game, now) = webbed();
        let (age, time, moths, due) = (game.spider.body.age, game.time(), game.world.moths.len(), game.own.next_moth);
        assert!(due > time + 60.0, "the next moth is due too soon for this to show anything");
        game.round_at(now);
        game.round_at(now - 90000.0);
        assert!(game.halts == 0 && game.spider.body.age == age && game.time() == time, "{}", game.why());
        game.round_at(now + 3600000.0);
        assert!(game.halts == 0 && (game.spider.body.age - age - 0.05).abs() < 1e-12 && game.time() == time + 50.0, "{}: {}", game.why(), game.time() - time);
        assert!(game.world.moths.len() == moths && game.own.next_moth == due, "a moth came because the clock jumped");
        // And the clock going on from there is the clock again: a round of its own length.
        game.round_at(now + 3600000.0 + STEP);
        assert!(game.halts == 0 && (game.time() - time - 50.0 - STEP).abs() < 1e-6, "{}", game.time() - time);
    }
    #[test]
    fn a_text_too_many_or_too_few_in_the_gates_record_is_a_change_like_any_other() {
        // The gate has written out each of the seven parts. One text more, or one fewer, or one gone from
        // the middle so that those after it stand in the wrong places: everything halts, the record is put
        // right, and the game goes on where a game that was never touched is.
        let found = "the gate found that its own record no longer had one text for each part, and no observer had flagged it";
        let each: Vec<String> = PARTS.iter().map(|part| format!("the gate's record of the {} put right", part)).collect();
        for base in [webbed(), carried()] {
            // that the gate put its counts right is said first, then what else was put right
            mended(&base, "a text too many", &|game| game.record.texts.push("x".into()), found, "the gate's counts put right, all eight observers started again");
            mended(&base, "the last text gone", &|game| drop(game.record.texts.pop()), found, &format!("the gate's counts put right, {}, all eight observers started again", each[OWN]));
            mended(&base, "no texts", &|game| game.record.texts.clear(), found, &format!("the gate's counts put right, {}, all eight observers started again", each.join(", ")));
        }
        for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
            let (mut game, mut now) = webbed();
            game.set_how(how);
            let before = all(&game);
            game.record.texts.remove(0);
            play(&mut game, &mut now, 1);
            assert!(game.halts == 1 && !game.stuck() && game.why.as_deref() == Some(found), "{:?}: {}", how, game.why());
            if how != How::AtOnce {
                assert!(game.halted() && all(&game) == before, "{:?}: something moved", how);
            }
            game.put_right();
            play(&mut game, &mut now, 120);
            assert!(!game.halted() && (game.halts, game.restarts) == (1, 1) && (0..PARTS.len()).all(|p| game.kept(p) == game.record.texts[p]), "{:?}: {}", how, game.why());
        }
    }
    #[test]
    fn an_observer_that_does_not_answer_is_found_by_the_others_of_its_ring() {
        // Each observer on a thread of its own, and the body observer's thread stops answering. In that
        // round the gate finds that it has not signalled, and everything halts. No other observer could
        // have known: all eight were asked at once. From the next round the others of its ring find for
        // themselves that its last signal is not the round before's, and each puts its flag up.
        let (mut game, mut now) = webbed();
        game.set_how(How::OnAClick);
        let apart = patient();
        game.run_apart(apart.clone());
        play(&mut game, &mut now, 30);
        let before = all(&game);
        apart.stall(2);
        play(&mut game, &mut now, 1);
        assert_eq!(game.why(), "the body observer did not answer in time");
        assert!(game.ring.iter().all(|o| !o.flagged) && game.ring[2].beat == game.rounds - 1.0 && all(&game) == before);
        play(&mut game, &mut now, 1);
        for i in [0, 1, 3] {
            assert!(game.ring[i].flagged && game.ring[i].why == "the body observer is silent", "the {} observer: {:?}", NAMES[i], game.ring[i].why);
        }
        assert!(!game.ring[2].flagged && game.halted() && game.why() == "the body observer did not answer in time" && all(&game) == before);
        game.put_right();
        play(&mut game, &mut now, 2);
        assert!(!game.halted() && (game.halts, game.restarts) == (1, 1), "{}", game.why());
    }
    #[test]
    fn a_halt_does_not_end_until_the_eight_new_observers_have_looked() {
        // Each observer on a thread of its own, and halts set to end at once. An observer stops answering,
        // everything halts, and it is put right in the same round: eight new observers, eight new threads.
        // One of the new ones answers nothing from its start. It has not looked, so the halt is not ended
        // and no work is done. The next round starts eight more, all of them look, and the game goes on.
        let (mut game, mut now) = webbed();
        game.set_how(How::AtOnce);
        let apart = patient();
        game.run_apart(apart.clone());
        play(&mut game, &mut now, 30);
        let before = all(&game);
        apart.stall_next(5);
        apart.stall(2);
        play(&mut game, &mut now, 1);
        assert!(game.halted() && !game.stuck() && (game.halts, game.restarts) == (1, 0) && all(&game) == before, "{}", game.why());
        play(&mut game, &mut now, 1);
        assert!(!game.halted() && (game.halts, game.restarts) == (1, 1), "{}", game.why());
        assert!(all(&game) != before, "the round after it was put right did no work");
        play(&mut game, &mut now, 300);
        assert_eq!(game.halts, 1, "{}", game.why());
    }
    /// For the tests: eight observers on threads of their own, waited for far longer than the program
    /// waits, so that a test run on a loaded machine does not take a slow answer for a silence.
    fn patient() -> Apart {
        Apart::start_with(|_| {}, (QUIET_MOST, Duration::from_secs(1)), (400, Duration::from_millis(5)))
    }
    #[test]
    fn observers_on_threads_of_their_own_find_what_observers_run_together_find() {
        // Two games from one beginning. In one the observers are run together, in the thread that does the
        // round. In the other each is on a thread of its own. The same is written at the backdoor of both.
        // Round for round they must be in the same state, halted or not alike, for the same reason.
        let (mut one, mut now) = webbed();
        let (mut other, mut other_now, apart) = (one.clone(), now, patient());
        other.run_apart(apart.clone());
        let lines = [
            "spider.body.x += 150",
            "spider.ring[0].alive = false",
            "world.tally.gained = 1000000",
            "world.ring[*].copies[4] = \"\"",
            "during world.tally.caught += 5",
            "spider.ring[3].flagged = true",
            "world.moths.push()",
            "spider.ring[*].beat += 1; world.ring[*].beat += 1",
            "world.ring[1].held = \"1,2,3\"",
            "spider.ring[*].alive = false; world.ring[*].alive = false",
        ];
        for line in lines {
            assert_eq!(backdoor::run(&mut one, line), backdoor::run(&mut other, line), "{}", line);
            for round in 0..90 {
                play(&mut one, &mut now, 1);
                play(&mut other, &mut other_now, 1);
                assert!(one.same_state(&other) && one.why == other.why, "{}, round {}: {:?} and {:?}", line, round, one.why, other.why);
                assert_eq!((one.halts, one.restarts, one.halted()), (other.halts, other.restarts, other.halted()), "{}, round {}", line, round);
            }
        }
        assert!(one.halts >= 10 && !one.halted(), "{} halts: {}", one.halts, one.why());
        assert!(apart.measured().0 < 400, "an answer was waited for to the end");
    }
    #[test]
    fn an_observer_that_does_not_answer_is_silent_and_is_replaced() {
        // Each observer is on a thread of its own, and one of them stops answering. It has not signalled:
        // it is silent, and everything halts with nothing moved. When the halt is put right the eight are
        // replaced by eight new ones, each on a new thread, and the game goes on.
        for how in [How::AfterAPause, How::AtOnce, How::OnAClick] {
            let (mut game, mut now) = webbed();
            game.set_how(how);
            let apart = Apart::start(|_| {});
            game.run_apart(apart.clone());
            play(&mut game, &mut now, 30);
            assert_eq!(game.halts, 0, "{:?}: {}", how, game.why());
            let before = all(&game);
            apart.stall(2);
            play(&mut game, &mut now, 1);
            assert_eq!(game.why.as_deref(), Some("the body observer did not answer in time"), "{:?}", how);
            if how != How::AtOnce {
                assert!(game.halted() && all(&game) == before, "{:?}: something moved", how);
            }
            if how == How::OnAClick {
                game.put_right();
            }
            play(&mut game, &mut now, 120);
            assert!(!game.halted() && (game.halts, game.restarts) == (1, 1), "{:?}: {}", how, game.why());
            play(&mut game, &mut now, 600);
            assert_eq!(game.halts, 1, "{:?}: {}", how, game.why());
        }
    }
    #[test]
    fn observers_on_threads_of_their_own_find_that_the_rounds_have_stopped() {
        // While rounds go by, no observer takes them to have stopped: with something to look at, and in a
        // halt that cannot be put right, in which no observer is asked to look. When the rounds stop coming, each
        // of the eight finds it for itself, and does what it was given to do.
        use std::sync::atomic::{AtomicU32, Ordering};
        static STOPPED: AtomicU32 = AtomicU32::new(0);
        fn stopped(_: u64) {
            STOPPED.fetch_add(1, Ordering::SeqCst);
        }
        let (mut game, mut now) = webbed();
        // An observer takes the rounds to have stopped after three waits of 150 thousandths of a second
        // with nothing heard. Each stretch of rounds here lasts longer than that, so that an observer
        // that was not told of the rounds in one of them would take them to have stopped.
        game.run_apart(Apart::start_with(stopped, (3, Duration::from_millis(150)), (400, Duration::from_millis(5))));
        for _ in 0..80 {
            play(&mut game, &mut now, 1);
            std::thread::sleep(Duration::from_millis(10));
        }
        assert_eq!(STOPPED.load(Ordering::SeqCst), 0, "an observer took the rounds to have stopped while it was asked to look in each");
        game.ring[4].alive = false;
        game.set_how(How::OnAClick);
        for _ in 0..80 {
            play(&mut game, &mut now, 1);
            std::thread::sleep(Duration::from_millis(10));
        }
        assert_eq!(STOPPED.load(Ordering::SeqCst), 0, "an observer took the rounds to have stopped while one was stopped and everything halted");
        game.fail("the game's own work stopped where it should not have", now);
        for _ in 0..80 {
            play(&mut game, &mut now, 1);
            std::thread::sleep(Duration::from_millis(10));
        }
        assert_eq!(STOPPED.load(Ordering::SeqCst), 0, "an observer took the rounds to have stopped while they went by");
        std::thread::sleep(Duration::from_millis(1500));
        assert_eq!(STOPPED.load(Ordering::SeqCst), 8, "not every observer found that the rounds had stopped");
    }
    #[test]
    fn observers_on_threads_of_their_own_keep_up_with_the_rounds() {
        // Thirty thousand rounds with each observer on a thread of its own, waited for as the program waits
        // for them. No answer may be late. What was measured is said, for whoever runs this to read.
        let (mut game, mut now) = webbed();
        let apart = Apart::start(|_| {});
        game.run_apart(apart.clone());
        let began = Instant::now();
        play(&mut game, &mut now, 30000);
        let (most, longest) = apart.measured();
        println!("30,000 rounds in {:?}; the longest any round waited for all eight answers: {:?}; the most waits any round used: {} of {}", began.elapsed(), longest, most, WAITS);
        assert_eq!(game.halts, 0, "{}", game.why());
    }
    #[test]
    fn a_change_to_the_state_as_the_round_is_recorded_is_not_recorded() {
        // The second doing of the work has been found to agree with what is there. Then one thing in the state
        // changes: before the round is recorded (1), or while it is being recorded, after the observers have
        // taken their copies (2). The gate's record is what the second doing made, so the change is not in it.
        // It is found in the next round and put back, and the game is where a game that was never touched is.
        let faults: [(&str, fn(&mut Game)); 9] = [
            ("moths gained", |game| if game.halts == 0 { game.world.tally.gained += 100000.0 }),
            ("moths caught", |game| if game.halts == 0 { game.world.tally.caught += 5.0 }),
            ("the body moved", |game| if game.halts == 0 { game.spider.body.x += 1.0 }),
            ("a foot moved", |game| if game.halts == 0 { game.spider.legs[3].y -= 0.5 }),
            ("the web grown a step", |game| if game.halts == 0 { game.world.web.made += 1.0 }),
            ("an upgrade", |game| if game.halts == 0 { game.world.shop.web += 1.0 }),
            ("the edge", |game| if game.halts == 0 { game.world.edge.inset += 1.0 }),
            ("the next moth brought forward", |game| if game.halts == 0 { game.own.next_moth -= 1e6 }),
            ("an upgrade nobody asked for, waiting", |game| if game.halts == 0 { game.own.buys.push("spawn") }),
        ];
        for instant in [1u8, 2] {
            for (what, fault) in faults {
                let (mut game, mut now) = with_moths(&webbed(), 1000.0);
                game.set_how(How::AtOnce);
                let (mut twin, mut twin_now) = (game.clone(), now);
                game.late = Some((instant, fault));
                play(&mut game, &mut now, 1);
                play(&mut twin, &mut twin_now, 1);
                // The round is recorded as the second doing made it: the record is the untouched game's, and the change is not in it.
                assert!(!game.halted() && !game.same_state(&twin), "{} at {}: nothing was changed", what, instant);
                assert!((0..PARTS.len()).all(|p| game.kept(p) == twin.kept(p) && game.record.texts[p] == twin.record.texts[p]), "{} at {}: it was recorded", what, instant);
                play(&mut game, &mut now, 1);
                play(&mut twin, &mut twin_now, 1);
                assert_eq!((game.halts, game.restarts, game.halted()), (1, 1, false), "{} at {}: {}", what, instant, game.why());
                assert!(game.same_state(&twin), "{} at {}: after it was put right the game is not where a game that was never touched is", what, instant);
                // found by the gate alone when the observers took their copies after the change, and by an observer when they took them before
                let why = game.why.clone().unwrap_or_default();
                assert_eq!(why.starts_with("the gate found"), instant == 1, "{} at {}: {}", what, instant, why);
                play(&mut game, &mut now, 600);
                play(&mut twin, &mut twin_now, 600);
                assert!(game.halts == 1 && twin.halts == 0 && game.same_state(&twin), "{} at {}: ten seconds on: {}", what, instant, game.why());
            }
        }
    }
    #[test]
    fn what_the_game_keeps_for_itself_is_watched() {
        // The pointer, what has been asked for and not yet acted on, chance, and when the next moth is due:
        // none of these is changed by anything but the work. A change to any of them is found by the world's
        // observers before the next round's work, and put back.
        let faults: [(&str, fn(&mut Game)); 10] = [
            ("an upgrade nobody asked for", |game| game.own.buys.push("spawn")),
            ("a click nobody made", |game| game.own.clicks.push((600.0, 400.0))),
            ("the next moth brought forward", |game| game.own.next_moth -= 1e6),
            ("the next moth put off", |game| game.own.next_moth += 1e6),
            ("the number the next moth will be given", |game| game.own.next_id += 5.0),
            ("chance moved on", |game| {
                game.own.chance.next();
            }),
            ("the pointer moved", |game| game.own.pointer.x += 10.0),
            ("the pointer taken out of the game", |game| game.own.pointer.inside = !game.own.pointer.inside),
            ("the pointer made to let go, or to take hold", |game| game.own.grab = if game.own.grab.is_some() { None } else { Some(crate::game::Grab { what: 8, x: 0.0, y: 0.0, moved: true }) }),
            ("the count of catches", |game| game.own.gain_n += 1.0),
        ];
        let (found, did) = ("the whole observer found the pointer, requests and chance changed", "the pointer, requests and chance put back, all eight observers started again");
        for base in [with_moths(&fresh(), 1000.0), webbed(), carried()] {
            for (what, fault) in faults.iter() {
                mended(&base, what, &|game| fault(game), found, did);
            }
        }
        // The backdoor does not reach this part. It can be read there, in a copy an observer of the world's ring holds of it.
        let (mut game, _) = fresh();
        let read = backdoor::run(&mut game, "world.ring[0].copies[6]");
        assert!(read.contains("next_moth") && read.contains("chance") && read.contains("pointer"), "{}", read);
        assert!(backdoor::run(&mut game, "spider.ring[0].copies[6]").ends_with("\"\""), "an observer of the spider's ring holds something of it");
        // Left to the pause, nothing is done on the strength of it: the upgrade is not bought, and no moth comes early.
        let (mut game, mut now) = with_moths(&fresh(), 1000.0);
        let (before, moths) = (all(&game), game.world.moths.len());
        game.own.buys.push("spawn");
        game.own.next_moth -= 1e6;
        play(&mut game, &mut now, 1);
        assert_eq!(game.why(), found);
        assert!(game.world.shop.spawn == 0.0 && game.world.tally.spent == 0.0 && game.world.moths.len() == moths);
        while game.halted() {
            play(&mut game, &mut now, 1);
        }
        assert_eq!(all(&game), before);
    }
    #[test]
    fn what_is_asked_of_the_game_is_taken_down_three_times() {
        let base = with_moths(&fresh(), 1000.0);
        let (found, did) = (
            "the gate found what was asked of the game not the same in the three places it is taken down, and no observer had flagged it",
            "what was asked of the game put right from the two places that agreed, all eight observers started again",
        );
        // Something in one of the three places that nobody asked for: an upgrade, a press, a letting go.
        // The two that agree say that nothing was asked, and nothing is bought, taken hold of or let go.
        mended(&base, "an upgrade in the first", &|game| game.asks.push(Ask::Buy("spawn")), found, did);
        mended(&base, "an upgrade in the second", &|game| game.asks_again.push(Ask::Buy("web")), found, did);
        mended(&base, "an upgrade in the third", &|game| game.asks_third.push(Ask::Buy("web")), found, did);
        let (x, y) = (base.0.spider.body.x, base.0.spider.body.y);
        mended(&base, "a press on the spider in the first", &|game| game.asks.push(Ask::Press(x, y, 0.0)), found, did);
        // A letting go that nobody made, in the second, while the spider is being carried: it stays carried.
        mended(&carried(), "a letting go in the second", &|game| game.asks_again.push(Ask::Release), found, did);
        let (mut game, mut now) = carried();
        game.set_how(How::AtOnce);
        game.asks_again.push(Ask::Release);
        play(&mut game, &mut now, 1);
        assert!(game.own.grab.is_some() && game.asks.is_empty() && game.asks_again.is_empty() && game.asks_third.is_empty(), "{}", game.spider.body.state);
        // The three places are compared to the last bit. A place at 0 in one and at -0 in the others are equal
        // as numbers, and the work can tell them apart: they are not the same, and the two that agree are taken.
        assert!(Ask::Point(1.0, 0.0, true, 5.0) != Ask::Point(1.0, -0.0, true, 5.0) && Ask::Press(0.0, 1.0, 5.0) != Ask::Press(-0.0, 1.0, 5.0) && Ask::Point(1.0, 2.0, true, 0.0) != Ask::Point(1.0, 2.0, true, -0.0));
        assert!(Ask::Press(2.0, 1.0, 5.0) == Ask::Press(2.0, 1.0, 5.0) && Ask::Buy("web") == Ask::Buy("web") && Ask::Buy("web") != Ask::Buy("spawn") && Ask::Release == Ask::Release);
        let mut pressed = base.clone();
        pressed.0.press(x, 0.0, 7.0);
        mended(&pressed, "the sign of a nought in a press, in the second", &|game| game.asks_again[0] = Ask::Press(x, -0.0, 7.0), found, did);
        let mut pointed = base.clone();
        pointed.0.point(0.0, y, true, 7.0);
        mended(&pointed, "the sign of a nought in the pointer's place, in the first", &|game| game.asks[0] = Ask::Point(-0.0, y, true, 7.0), found, did);
        // Something that was asked for, lost from one of the three or changed in it: it is still what was asked, and it is bought.
        let mut bought = base.clone();
        bought.0.buy("spawn");
        mended(&bought, "an upgrade lost from the second", &|game| game.asks_again.clear(), found, did);
        mended(&bought, "an upgrade changed in the first", &|game| game.asks[0] = Ask::Buy("web"), found, did);
        let (mut game, mut now) = bought.clone();
        let level = game.world.shop.spawn;
        game.asks.clear();
        play(&mut game, &mut now, 120);
        assert!(game.world.shop.spawn == level + 1.0 && game.halts == 1, "the upgrade that was asked for was not bought: {}", game.why());
        // Two of the three changed, each another way: nothing says what was asked. None of it is taken, nothing is
        // bought, and the pointer is made to let go: a letting go that was lost would leave the spider held.
        let (mut game, mut now) = carried();
        game.set_how(How::AtOnce);
        game.asks_again.push(Ask::Release);
        game.asks_third.push(Ask::Buy("web"));
        play(&mut game, &mut now, 1);
                assert_eq!(game.fixed.as_ref().map(|(did, _)| did.as_str()), Some("what was asked of the game put aside, and the pointer made to let go, all eight observers started again"));
        assert!(game.own.grab.is_none() && game.spider.body.state == "recovering" && game.asks.is_empty() && game.asks_again.is_empty() && game.asks_third.is_empty(), "{}", game.spider.body.state);
        // The same with moths enough to pay: an upgrade in one list and another in a second. Neither is bought.
        let (mut game, mut now) = with_moths(&fresh(), 1000.0);
        let (shop, spent) = (game.world.shop.written(), game.world.tally.spent);
        game.asks.push(Ask::Buy("web"));
        game.asks_third.push(Ask::Buy("spawn"));
        play(&mut game, &mut now, 120);
        assert!(!game.halted() && game.halts == 1 && game.world.shop.written() == shop && game.world.tally.spent == spent, "something was bought: {}", game.world.shop.written());
        // A flood of the pointer's places between two rounds crowds nothing out. A press that comes in the
        // middle of it is taken, and so is a letting go.
        let (mut game, mut now) = fed();
        let (x, y) = (game.spider.body.x, game.spider.body.y);
        for step in 0..5000 {
            game.point(10.0 + (step % 100) as f64, 10.0, true, now);
        }
        game.press(x, y, now);
        for step in 0..5000 {
            game.point(900.0, 300.0 + (step % 7) as f64, true, now);
        }
        assert!(game.asks.len() == 9 && game.asks == game.asks_again && game.asks == game.asks_third, "{} waiting", game.asks.len());
        play(&mut game, &mut now, 1);
        assert!(game.own.grab.is_some() && game.spider.body.state == "panic", "the press was lost");
        for _ in 0..5000 {
            game.point(900.0, 300.0, true, now);
        }
        game.release();
        game.release();
        for _ in 0..5000 {
            game.point(900.0, 300.0, true, now);
        }
        assert!(game.asks.iter().filter(|ask| matches!(ask, Ask::Release)).count() == 1 && game.asks.len() == 9 && game.asks == game.asks_again);
        play(&mut game, &mut now, 1);
        assert!(game.own.grab.is_none() && game.halts == 0, "the letting go was lost");
        // No more than eight presses wait for one round, and a letting go after each is still taken.
        for _ in 0..100 {
            game.press(30.0, 30.0, now);
            game.release();
        }
        assert!(game.asks.iter().filter(|ask| matches!(ask, Ask::Press(..))).count() == 8 && game.asks.len() <= 17 && game.asks == game.asks_again, "{} waiting", game.asks.len());
        play(&mut game, &mut now, 1);
        assert!(game.own.grab.is_none() && game.asks.is_empty() && game.halts == 0);
                // Left alone, what is asked is in all three places, is taken in by the next round's work, and then is in none.
        let (mut game, mut now) = base.clone();
        game.buy("spawn");
        game.point(300.0, 200.0, true, now);
        assert!(game.asks.len() == 2 && game.asks == game.asks_again && game.own.buys.is_empty());
        play(&mut game, &mut now, 1);
        assert!(game.asks.is_empty() && game.asks_again.is_empty() && game.world.shop.spawn == 1.0 && game.own.pointer.x == 300.0 && game.halts == 0);
        // What was asked of a round that went wrong is still waiting when the halt is over, and is taken in then.
        let (mut game, mut now) = base.clone();
        game.buy("web");
        assert!(game.during("world.tally.caught += 5"));
        play(&mut game, &mut now, 1);
        assert!(game.halted() && game.world.shop.web == 1.0 && game.asks == vec![Ask::Buy("web")] && game.asks_again == game.asks);
        while game.halted() {
            play(&mut game, &mut now, 1);
        }
        assert!(game.world.shop.web == 0.0, "the round was not undone");
        play(&mut game, &mut now, 1);
        assert!(game.world.shop.web == 1.0 && game.asks.is_empty() && (game.halts, game.restarts) == (1, 1), "{}", game.why());
    }
    #[test]
    fn a_record_that_nothing_can_settle_stops_the_game_until_it_is_begun_again() {
        // Both halves of the gate's record of the body changed, each another way: two faults in one round.
        // Neither is what the state and the observers hold, so there is nothing to put either right from.
        let (mut game, mut now) = fresh();
        let before = all(&game);
        game.record.spider.body.x += 150.0;
        game.record.texts[2].push('x');
        play(&mut game, &mut now, 1);
        assert_eq!(game.why(), "the gate found its own record of the body no longer agrees with itself, and no observer had flagged it");
        play(&mut game, &mut now, 120);
        assert!(game.shown(now).contains("\"stuck\":true") && (game.halts, game.restarts) == (1, 0));
        assert_eq!(game.why(), "it could not be put right: the gate's record of the body does not agree with itself, and the state and the observers do not settle which of the two is right");
        // nothing was changed in the attempt
        assert_eq!(all(&game), before);
        game.put_right();
        play(&mut game, &mut now, 600);
        assert!(!game.halted() && game.halts == 0 && game.shown(now).contains("\"games\":2,"), "{}", game.why());
        // One half of the record wrong, and the state changed too: again two faults, and again nothing settles it.
        let (mut game, mut now) = fresh();
        game.record.texts[2].push('x');
        backdoor::run(&mut game, "spider.body.x += 150");
        while !game.shown(now).contains("\"stuck\":true") {
            play(&mut game, &mut now, 1);
            assert!(game.halted(), "it went on");
        }
        assert!(game.why().starts_with("it could not be put right: the gate's record of the body does not agree with itself"), "{}", game.why());
    }
}
