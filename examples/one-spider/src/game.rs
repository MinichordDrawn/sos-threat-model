//! The game's state and its own work.
//!
//! The state is plain data of a fixed shape, in two scopes. The spider: a body and eight
//! legs. The world around it: the edge, the counts, the web, and the moths. Every field has
//! a name and a kind, and can be read and written by that name. That is what the backdoor
//! (`backdoor.rs`) uses, and it is all the backdoor can do to a field: a field cannot be added,
//! taken away, or made into something else.

use crate::backdoor::Val;
use std::f64::consts::{PI, TAU};

/// The work, written out a second time, for the gate's second doing of it.
pub mod again;

/// The game area, in its own units, and how far in from its sides the edge is.
pub const W: f64 = 1200.0;
pub const H: f64 = 800.0;
pub const INSET: f64 = 10.0;
/// The length of the spider's body.
pub const SIZE: f64 = 53.0;

// Lengths are in body lengths. Each list runs from the front pair of legs to the back pair.
const FOOT: [f64; 4] = [0.44, 0.91, 2.23, 2.65]; // where a pair's feet rest, as an angle from the heading
const REACH: [f64; 4] = [1.7, 1.4, 1.4, 1.8]; // how far out a pair's feet rest
/// The legs are numbered 0 to 3 down the left side and 4 to 7 down the right. They step in
/// two sets: the first and third legs of the left with the second and fourth of the right,
/// and then the other four.
pub const SETS: [[usize; 4]; 2] = [[0, 2, 5, 7], [1, 3, 4, 6]];
// Food. A full meter runs down to empty in 30 seconds. How much of it one moth fills depends
// on the spider's size. The spider eats until it has no room for another moth. Then it is
// full, and it neither hunts nor eats until the meter is down to a third. With its web
// finished it has nothing to wait for, and eats as soon as it has room for a moth.
const EMPTY: f64 = 30.0;
const HUNGRY: f64 = 1.0 / 3.0;
// Held by the pointer, the spider panics: its meter runs down in 5 seconds, not 30. Let
// go, it takes so many thousandths of a second to get over it. A press takes hold only
// once the pointer has moved this far from where it pressed.
const FRIGHT: f64 = 5.0;
const RECOVERS: f64 = 700.0;
pub const DRAGS: f64 = 4.0;
// Age. A spider starts at half size and is full grown after two and a half minutes. It dies
// of old age at five. Two moths fill a new spider's meter, and eight a full-grown one's, and
// one more for each appetite bought. The meter runs down at the same rate whatever the
// size, so a bigger spider eats more moths.
const GROWN: f64 = 150.0;
pub const LIFE: f64 = 300.0;
const STOMACH: f64 = 2.0;
const STOMACH_GROWS: f64 = 6.0;
// A spider that eats the one before it is quicker than that one, and its food lasts longer:
// by a hundredth for each moth the old one ate, a tenth at most each time, and by 111 hundredths in all.
const BOOST_STEP: f64 = 0.1;
const BOOST_MOST: f64 = 1.11;
// The next spider. In the round a spider dies, the next one is there: just outside the
// edge, so many of its own body lengths out, which puts its nearest feet at the edge
// whichever way it faces, so that it is seen at once. Both are the spider's: the dead one's
// body and the living one are in the same scope, under the same observers, so there is
// nothing for anyone to take on first.
const WAITS_OUT: f64 = 1.3;
// Moths. They arrive at about 14 a minute, a little unevenly, over the edge. There can be
// four on the wing and ten in all, and each upgrade bought for more of them allows one and
// two more. A moth keeps this far inside the edge.
const MOTHS_A_MINUTE: f64 = 14.0;
const MOTHS_LOOSE: usize = 4;
const MOTHS_MOST: usize = 10;
const MOTHS_MORE: usize = 2;
// Two upgrades have a most. Nineteen of the one for more moths: that is 33 a minute, 23 on the
// wing and 48 in all. Twenty-four of the one for appetite: that is 26 moths to fill a new
// spider and 32 to fill a full-grown one.
const SPAWN_MOST: f64 = 19.0;
const APPETITE_MOST: f64 = 24.0;
const MOTH_EDGE: f64 = 4.0;
// The shop. Each upgrade is priced the way idle games price them: every one bought adds the
// same amount and costs so much more than the one before. Here, for each: its name, the
// price of the first, and how many times dearer each one is than the last.
//   spawn     one more moth a minute
//   appetite  one more moth to fill the spider's meter, so that it eats more of them
//   spider    a tenth more for every moth the spider catches
//   web       a tenth more for every moth caught in the web
// A moth caught is worth one moth: times the spider's multiplier if the spider caught it,
// times the web's if the pointer picked it out of the web, and times both if the spider ate
// it in the web. What has been gained that way is kept in hundredths of a moth, so that it
// stays a whole number. What there is to spend is what has been gained less what has been
// spent.
pub const UPGRADES: [(&str, f64, f64); 4] = [("spawn", 10.0, 1.15), ("appetite", 12.0, 1.15), ("spider", 12.0, 1.07), ("web", 10.0, 1.07)];
// The web. There are seven sizes, numbered 0 to 6: the first reaches four tenths of the way
// a web can reach here, and each one after it a tenth further. A finished web stands for 90
// seconds before it is old. A strand holds a moth that comes within this share of a body
// length of it, and a click takes a moth that is within this share of one.
pub const SHARES: [f64; 7] = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];
const WEB_LASTS: f64 = 90.0;
const WEB_HOLDS: f64 = 0.16;
pub const CLICK_TAKES: f64 = 0.6;

/// A kind of value a field can hold.
pub trait Kind: Sized {
    const NAME: &'static str;
    fn from_val(v: Val) -> Option<Self>;
}
impl Kind for f64 {
    const NAME: &'static str = "a number";
    fn from_val(v: Val) -> Option<Self> {
        match v {
            Val::Num(n) => Some(n),
            _ => None,
        }
    }
}
impl Kind for bool {
    const NAME: &'static str = "true or false";
    fn from_val(v: Val) -> Option<Self> {
        match v {
            Val::Bool(b) => Some(b),
            _ => None,
        }
    }
}
impl Kind for String {
    const NAME: &'static str = "a text";
    fn from_val(v: Val) -> Option<Self> {
        match v {
            Val::Text(t) => Some(t),
            _ => None,
        }
    }
}

/// A piece of the state whose fields can be listed, read and written by name.
pub trait Part {
    fn fields(&self) -> &'static [&'static str];
    fn get(&self, field: &str) -> Option<Val>;
    fn set(&mut self, field: &str, to: Val) -> Result<(), String>;
    /// The piece written out, every field by name.
    fn written(&self) -> String {
        self.sent(usize::MAX)
    }
    /// The piece written out for a screen: the same, with no more than so many characters of
    /// any text in it.
    fn sent(&self, most: usize) -> String {
        let mut text = String::from("{");
        for (n, field) in self.fields().iter().enumerate() {
            if n > 0 {
                text.push(',');
            }
            text.push('"');
            text.push_str(field);
            text.push_str("\":");
            text.push_str(&match self.get(field) {
                Some(Val::Text(t)) if most < usize::MAX => Val::Text(crate::backdoor::short(&t, most)).written(),
                Some(v) => v.written(),
                None => String::new(),
            });
        }
        text.push('}');
        text
    }
    /// Is every number in it a real one?
    fn fit(&self) -> bool {
        self.fields().iter().all(|f| !matches!(self.get(f), Some(Val::Num(n)) if !n.is_finite()))
    }
}

macro_rules! part {
    ($(#[$doc:meta])* $name:ident { $($field:ident : $kind:ty),* $(,)? }) => {
        $(#[$doc])*
        #[derive(Clone, Debug)]
        pub struct $name { $(pub $field: $kind),* }
        impl Part for $name {
            fn fields(&self) -> &'static [&'static str] { &[$(stringify!($field)),*] }
            fn get(&self, field: &str) -> Option<Val> {
                match field {
                    $(stringify!($field) => Some(Val::from(self.$field.clone())),)*
                    _ => None,
                }
            }
            fn set(&mut self, field: &str, to: Val) -> Result<(), String> {
                match field {
                    $(stringify!($field) => match <$kind as Kind>::from_val(to) {
                        Some(v) => { self.$field = v; Ok(()) }
                        None => Err(format!("{} holds {}, and that is fixed", field, <$kind as Kind>::NAME)),
                    },)*
                    _ => Err(format!("there is no {}", field)),
                }
            }
        }
    };
}

part! {
    /// The body. `h` is its heading and `v` its speed. `tx`, `ty` is where it is going, and
    /// `exact` says whether it stops right there or a little short. `state` is `walking` or
    /// `resting`, and `until` is when a rest ends. `phase` runs the cycle of the legs.
    /// `moved` and `turned` are how far it went and turned in the last round. `food` runs
    /// from 0, empty, to 1. `full` says it has had its fill and is not yet hungry again.
    /// `eaten` is how many of the moths caught it has been fed by, and `meals` how many
    /// this spider has eaten. `gen` is which spider this is, counting from 1, and `age` how
    /// many seconds it has lived. `boost` is how much quicker it is than the first, and how
    /// much longer its food lasts. `husks` is how many old spiders have been eaten. `grip`
    /// says what the pointer has hold of: a leg by its number, 8 for the body, or -1 for
    /// nothing. Held, its `state` is `panic`, and for a short while after, `recovering`.
    Body { x: f64, y: f64, h: f64, v: f64, size: f64, tx: f64, ty: f64, exact: bool, state: String, until: f64, phase: f64, moved: f64, turned: f64,
           food: f64, full: bool, eaten: f64, meals: f64, gen: f64, age: f64, boost: f64, husks: f64, grip: f64 }
}
part! {
    /// The spider before this one, dead, until this one eats it: whether there is one, where
    /// it lies, how it lies, its size, and how many moths it had eaten.
    Old { on: bool, x: f64, y: f64, h: f64, size: f64, meals: f64 }
}
part! {
    /// A leg. `side` is -1 on the left and 1 on the right, `pair` is 0 at the front to 3 at
    /// the back, and `set` is which of the two sets it steps with. `x`, `y` is its foot.
    /// While the foot is in the air `up` is true, `t` runs from 0 to 1 over `dur` seconds,
    /// and `fx`, `fy` is where it lifted from.
    Leg { side: f64, pair: f64, set: f64, up: bool, x: f64, y: f64, t: f64, dur: f64, fx: f64, fy: f64 }
}
part! {
    /// The edge: the dashed line the spider and the moths stay inside. `inset` is how far in
    /// it is from the sides of the game area, which is `w` by `h`.
    Edge { inset: f64, w: f64, h: f64 }
}
part! {
    /// The counts. `caught` is how many moths have been caught, `picked` how many of those
    /// the pointer took out of the web, and `webs` how many webs have been finished.
    /// `spent` is how many moths have been spent at the shop, `gained` what the moths
    /// caught have been worth, in hundredths of a moth, and `webbed` how many moths the
    /// spider ate in its web.
    Tally { caught: f64, picked: f64, webs: f64, spent: f64, gained: f64, webbed: f64 }
}
part! {
    /// The shop: how many of each upgrade have been bought.
    Shop { spawn: f64, appetite: f64, spider: f64, web: f64 }
}
part! {
    /// The web. `on` says there is one. `x`, `y` is its hub. `made` is how many steps of it
    /// have been made, and `tied` whether the spider has hold of its thread. `age` is how
    /// long it has stood finished, in seconds, and `old` says that is long enough. `torn`
    /// is the numbers of the strands that have been broken, with commas between. `level` is
    /// which of the seven sizes it is.
    Web { on: bool, x: f64, y: f64, made: f64, tied: bool, age: f64, old: bool, torn: String, level: f64 }
}
part! {
    /// A moth. `id` is the number it was given when it arrived. `x`, `y` is where it is and
    /// `h` its heading. `wx`, `wy` is where it is making for, until `until`.
    Moth { id: f64, x: f64, y: f64, h: f64, wx: f64, wy: f64, until: f64 }
}

#[derive(Clone, Debug)]
pub struct Spider {
    pub body: Body,
    pub old: Old,
    pub legs: Vec<Leg>,
}
#[derive(Clone, Debug)]
pub struct World {
    pub edge: Edge,
    pub tally: Tally,
    pub web: Web,
    pub shop: Shop,
    pub moths: Vec<Moth>,
}

/// The pointer: where it is, when it last moved, and whether it is over the game.
#[derive(Clone, Debug, PartialEq)]
pub struct Pointer {
    pub x: f64,
    pub y: f64,
    pub moved: f64,
    pub inside: bool,
}

/// Chance, kept where nothing outside can reach it.
#[derive(Clone, PartialEq)]
pub struct Chance(u64);
impl Chance {
    pub fn new(seed: u64) -> Self {
        Chance(seed | 1)
    }
    /// Where it has got to, written out.
    pub fn written(&self) -> String {
        self.0.to_string()
    }
        /// For the tests: a number from 0 up to, but not reaching, 1.
    #[cfg(test)]
    pub fn next(&mut self) -> f64 {
        draw(self)
    }
}

/// A moth caught: which catch it was, counted from 1, where, what it was worth in
/// hundredths of a moth, and when.
#[derive(Clone, PartialEq)]
pub struct Gain {
    pub n: f64,
    pub x: f64,
    pub y: f64,
    pub worth: f64,
    pub at: f64,
}
/// What the pointer pressed on: a leg by its number, or 8 for the body. Where it pressed,
/// and whether it has moved far enough since to have taken hold.
#[derive(Clone, PartialEq)]
pub struct Grab {
    pub what: usize,
    pub x: f64,
    pub y: f64,
    pub moved: bool,
}
/// The game's own: what the work needs and the backdoor does not reach. The pointer and what
/// it pressed on, the clicks and the upgrades asked for that the world has yet to act on,
/// chance, when the next moth is due, the number the last moth was given, and the
/// catches of the last minute, for a screen to show.
#[derive(Clone, PartialEq)]
pub struct Own {
    pub pointer: Pointer,
    pub grab: Option<Grab>,
    pub clicks: Vec<(f64, f64)>,
    pub buys: Vec<&'static str>,
    pub chance: Chance,
    pub next_moth: f64,
    pub next_id: f64,
    pub gains: Vec<Gain>,
    pub gain_n: f64,
}
impl Own {
    pub fn new(now: f64, seed: u64) -> Self {
        Own {
            pointer: Pointer { x: 0.0, y: 0.0, moved: -1e9, inside: false },
            grab: None,
            clicks: Vec::new(),
            buys: Vec::new(),
            chance: Chance::new(seed),
            next_moth: now + 1500.0,
            next_id: 0.0,
            gains: Vec::new(),
            gain_n: 0.0,
        }
    }
    /// What the pointer has hold of, if anything: a leg by its number, or 8 for the body. A
    /// press that has not moved holds nothing.
    pub fn held(&self) -> Option<usize> {
        in_hand(self)
    }
    /// Is every number here a real one?
    pub fn fit(&self) -> bool {
        let real = |n: f64| n.is_finite();
        real(self.pointer.x)
            && real(self.pointer.y)
            && real(self.pointer.moved)
            && self.grab.as_ref().map_or(true, |grab| real(grab.x) && real(grab.y))
            && self.clicks.iter().all(|&(x, y)| real(x) && real(y))
            && real(self.next_moth)
            && real(self.next_id)
            && real(self.gain_n)
            && self.gains.iter().all(|gain| real(gain.n) && real(gain.x) && real(gain.y) && real(gain.worth) && real(gain.at))
    }
    /// All of it written out, exactly: two of these give the same text only if nothing in them differs.
    pub fn written(&self) -> String {
        format!(
            "{{\"pointer\":[{:?},{:?},{:?},{}],\"grab\":{},\"clicks\":[{}],\"buys\":[{}],\"chance\":{},\"next_moth\":{:?},\"next_id\":{:?},\"gain_n\":{:?},\"gains\":[{}]}}",
            self.pointer.x,
            self.pointer.y,
            self.pointer.moved,
            self.pointer.inside,
            match &self.grab {
                Some(grab) => format!("[{},{:?},{:?},{}]", grab.what, grab.x, grab.y, grab.moved),
                None => "null".to_string(),
            },
            self.clicks.iter().map(|&(x, y)| format!("[{:?},{:?}]", x, y)).collect::<Vec<_>>().join(","),
            self.buys.iter().map(|what| format!("\"{}\"", what)).collect::<Vec<_>>().join(","),
            self.chance.written(),
            self.next_moth,
            self.next_id,
            self.gain_n,
            self.gains.iter().map(|gain| format!("[{:?},{:?},{:?},{:?},{:?}]", gain.n, gain.x, gain.y, gain.worth, gain.at)).collect::<Vec<_>>().join(",")
        )
    }
}

/// One thing asked of the game from outside it: by the pointer, or at the shop.
#[derive(Clone, Copy)]
pub enum Ask {
    /// The pointer is here: where, whether it is over the game, and when.
    Point(f64, f64, bool, f64),
    /// The pointer was pressed here, and when.
    Press(f64, f64, f64),
    /// The pointer was let up.
    Release,
    /// An upgrade asked for at the shop.
    Buy(&'static str),
}
/// Two of these are the same only if they are the same to the last bit. A place at 0 and a
/// place at -0 are two places: as numbers they are equal, but the work can tell them apart.
impl PartialEq for Ask {
    fn eq(&self, other: &Ask) -> bool {
        let same = |a: f64, b: f64| a.to_bits() == b.to_bits();
        match (*self, *other) {
            (Ask::Point(x, y, inside, at), Ask::Point(x2, y2, inside2, at2)) => same(x, x2) && same(y, y2) && inside == inside2 && same(at, at2),
            (Ask::Press(x, y, at), Ask::Press(x2, y2, at2)) => same(x, x2) && same(y, y2) && same(at, at2),
            (Ask::Release, Ask::Release) => true,
            (Ask::Buy(what), Ask::Buy(what2)) => what == what2,
            _ => false,
        }
    }
}
/// A number from 0 up to, but not reaching, 1, drawn from chance.
fn draw(chance: &mut Chance) -> f64 {
    chance.0 ^= chance.0 >> 12;
    chance.0 ^= chance.0 << 25;
    chance.0 ^= chance.0 >> 27;
    (chance.0.wrapping_mul(0x2545_F491_4F6C_DD1D) >> 11) as f64 / (1u64 << 53) as f64
}
/// A moth has been caught, for so much.
fn note_gain(own: &mut Own, x: f64, y: f64, worth: f64, now: f64) {
    own.gain_n += 1.0;
    own.gains.push(Gain { n: own.gain_n, x, y, worth, at: now });
}
/// What the pointer has hold of, if anything: a leg by its number, or 8 for the body. A
/// press that has not moved holds nothing.
fn in_hand(own: &Own) -> Option<usize> {
    match &own.grab {
        Some(grab) if grab.moved => Some(grab.what),
        _ => None,
    }
}
/// The pointer is here now. A press takes hold once the pointer has moved far enough from where it pressed.
fn point_to(own: &mut Own, x: f64, y: f64, inside: bool, at: f64) {
    own.pointer = Pointer { x: x.max(0.0).min(W), y: y.max(0.0).min(H), moved: at, inside };
    if let Some(grab) = own.grab.as_mut() {
        if (x - grab.x).hypot(y - grab.y) >= DRAGS {
            grab.moved = true;
        }
    }
}
/// A click, for the world to act on in its own work. No more than eight are kept for one round.
fn click_at(own: &mut Own, x: f64, y: f64) {
    if own.clicks.len() < 8 {
        own.clicks.push((x, y));
    }
}
/// The first thing a round's work does: it takes in what has been asked of the game since
/// the last round, in the order it was asked. A press on a foot or the body of the spider
/// may take hold of it, and the spider's own work does the rest. A press anywhere else is
/// a click. What a click or an upgrade asked for comes to is the world's to decide, in its
/// own work. No more than eight of each are kept for one round.
pub fn take_in(own: &mut Own, spider: &Spider, asks: &[Ask]) {
    for ask in asks {
        match *ask {
            Ask::Point(x, y, inside, at) => point_to(own, x, y, inside, at),
            Ask::Press(x, y, at) => {
                point_to(own, x, y, true, at);
                match pick(spider, x, y) {
                    Some(what) => own.grab = Some(Grab { what, x, y, moved: false }),
                    None => click_at(own, x, y),
                }
            }
            Ask::Release => own.grab = None,
            Ask::Buy(what) => {
                if own.buys.len() < 8 {
                    own.buys.push(what);
                }
            }
        }
    }
}
/// What of the spider is at a place, for the pointer to take hold of: a foot, by its leg's
/// number, or the body, as 8, or nothing.
pub fn pick(spider: &Spider, x: f64, y: f64) -> Option<usize> {
    let body = &spider.body;
    let (mut best, mut near) = (None, (body.size * 0.4).max(18.0));
    for (k, leg) in spider.legs.iter().enumerate() {
        let d = (leg.x - x).hypot(leg.y - y);
        if d < near {
            near = d;
            best = Some(k);
        }
    }
    if best.is_none() && (body.x - x).hypot(body.y - y) < body.size * 0.6 {
        best = Some(8);
    }
    best
}
/// A moth halted in the web, at a place, for the pointer to take.
pub fn moth_at<'a>(world: &'a World, held: &str, x: f64, y: f64) -> Option<&'a Moth> {
    let halted: Vec<&str> = held.split(',').collect();
    world.moths.iter().find(|moth| halted.contains(&number(moth).as_str()) && (moth.x - x).hypot(moth.y - y) < SIZE * CLICK_TAKES)
}

fn clamp(v: f64, lo: f64, hi: f64) -> f64 {
    lo.max(hi.min(v))
}
/// An angle, brought to within half a turn either side of zero.
fn turn(a: f64) -> f64 {
    a - TAU * ((a + PI) / TAU).floor()
}
fn pair_of(leg: &Leg) -> usize {
    (leg.pair.max(0.0) as usize).min(3)
}
/// Where a leg's foot belongs when the body is at x, y and heads h.
fn rest_of(leg: &Leg, size: f64, x: f64, y: f64, h: f64) -> (f64, f64) {
    let a = h + leg.side * FOOT[pair_of(leg)];
    let (r, c) = (size * REACH[pair_of(leg)], size * 0.18);
    (x + c * h.cos() + r * a.cos(), y + c * h.sin() + r * a.sin())
}
/// The spider stays inside the edge: any place it is sent is pulled back within it.
fn in_scope(edge: &Edge, size: f64, x: f64, y: f64) -> (f64, f64) {
    let m = edge.inset + size * 2.4;
    (clamp(x, m, m.max(edge.w - m)), clamp(y, m, m.max(edge.h - m)))
}
/// How grown a spider is: 0 for a new one, 1 for a full-grown one.
fn growth(body: &Body) -> f64 {
    clamp(body.age / GROWN, 0.0, 1.0)
}
/// The length of a spider's body, for its age.
fn size_now(body: &Body) -> f64 {
    SIZE * (0.5 + 0.5 * growth(body))
}
/// What one moth adds to the food meter.
fn bite(shop: &Shop, body: &Body) -> f64 {
    1.0 / stomach(shop, body)
}
/// How many moths fill the spider's meter: more as it grows, and one more for each appetite bought.
pub fn stomach(shop: &Shop, body: &Body) -> f64 {
    STOMACH + (STOMACH_GROWS * growth(body)).round() + shop.appetite
}
/// The price of the next one of an upgrade, in moths, when so many have been bought.
pub fn cost_of(what: &str, level: f64) -> Option<f64> {
    UPGRADES.iter().find(|u| u.0 == what).map(|&(_, price, dearer)| (price * dearer.powf(level)).ceil())
}
/// What there is to spend, in hundredths of a moth.
pub fn purse(tally: &Tally) -> f64 {
    tally.gained - 100.0 * tally.spent
}
/// The shelf of the shop, written out for a screen: for each upgrade what it is called,
/// what there is of it now, what one more adds, what the next one costs, and whether there
/// are moths enough for it. One that is at its most has no price, and cannot be bought. It is told from the state as it stands.
pub fn shelf_written(world: &World) -> String {
    let rows: Vec<String> = UPGRADES
        .iter()
        .map(|&(what, _, _)| {
            let level = match world.shop.get(what) {
                Some(Val::Num(n)) => n,
                _ => f64::NAN,
            };
            let (name, now, step) = match what {
                "spawn" => ("More moths", format!("{} a minute", MOTHS_A_MINUTE + level), "+1"),
                "appetite" => ("Spider appetite", format!("{}\u{2013}{} moths", STOMACH + level, STOMACH + STOMACH_GROWS + level), "+1"), // from a new spider to a full-grown one
                "spider" => ("Spider multiplier", format!("x{:.1}", 1.0 + level / 10.0), "+0.1"),
                _ => ("Web multiplier", format!("x{:.1}", 1.0 + level / 10.0), "+0.1"),
            };
            let cost = cost_of(what, level).unwrap_or(f64::NAN);
            // an upgrade at its most has no price: the shop has no more of it
            let most = most_of(what).map_or(false, |most| level >= most);
            format!(
                "{{\"what\":\"{}\",\"name\":\"{}\",\"now\":\"{}\",\"step\":\"{}\",\"cost\":{},\"can\":{}}}",
                what,
                name,
                now,
                step,
                if most { "null".to_string() } else { Val::Num(cost).written() },
                !most && purse(&world.tally) >= 100.0 * cost
            )
        })
        .collect();
    format!("[{}]", rows.join(","))
}

impl Spider {
    /// A new spider in the middle of the game area, at rest and full, with its feet where they belong.
    pub fn new(now: f64) -> Self {
        let body = Body {
            x: W / 2.0, y: H / 2.0, h: -PI / 2.0, v: 0.0, size: SIZE * 0.5, tx: W / 2.0, ty: H / 2.0, exact: false,
            state: "resting".into(), until: now + 500.0, phase: 0.45, moved: 0.0, turned: 0.0,
            food: 1.0, full: true, eaten: 0.0, meals: 0.0, gen: 1.0, age: 0.0, boost: 0.0, husks: 0.0, grip: -1.0,
        };
        let old = Old { on: false, x: 0.0, y: 0.0, h: 0.0, size: 0.0, meals: 0.0 };
        let mut legs = Vec::new();
        for i in 0..8 {
            let mut leg = Leg {
                side: if i < 4 { -1.0 } else { 1.0 }, pair: (i % 4) as f64, set: if SETS[0].contains(&i) { 0.0 } else { 1.0 },
                up: false, x: 0.0, y: 0.0, t: 0.0, dur: 0.16, fx: 0.0, fy: 0.0,
            };
            let (x, y) = rest_of(&leg, body.size, body.x, body.y, body.h);
            leg.x = x; leg.y = y; leg.fx = x; leg.fy = y;
            legs.push(leg);
        }
        Spider { body, old, legs }
    }
}
impl World {
    pub fn new() -> Self {
        World {
            edge: Edge { inset: INSET, w: W, h: H },
            tally: Tally { caught: 0.0, picked: 0.0, webs: 0.0, spent: 0.0, gained: 0.0, webbed: 0.0 },
            shop: Shop { spawn: 0.0, appetite: 0.0, spider: 0.0, web: 0.0 },
            web: Web { on: false, x: 0.0, y: 0.0, made: 0.0, tied: false, age: 0.0, old: false, torn: String::new(), level: 0.0 },
            moths: Vec::new(),
        }
    }
}

// ---- the web
//
// A web is made in the order an orb weaver makes one. Each step is a place to walk to,
// measured from the hub in units of the web's reach, and whether a strand is laid on the way.
//   1. the bridge: one line across the top
//   2. a stem from the middle of the bridge down through the hub to the bottom
//   3. the frame round the sides and bottom, and then the rest of the spokes, each out from the hub
//   4. a wide spiral from the hub outward, which is only there to walk on
//   5. a close spiral from the outside inward, which takes the wide one away as it passes
// A wider web has more turns of both spirals, so its strands are as close together as a
// small one's.

/// What a step of a web lays, if anything.
#[derive(Clone, Copy, PartialEq)]
pub enum Strand {
    Walk,
    Frame,
    Spoke,
    Wide,
    Close,
}
/// A step of a web. `f` is how far out it is, from 0 at the hub to 1.
pub struct Step {
    pub u: f64,
    pub v: f64,
    pub lay: bool,
    pub kind: Strand,
    pub f: f64,
}
/// The steps of a web that reaches `share` of the way.
fn web_plan(share: f64) -> Vec<Step> {
    const N: usize = 12;
    let at = |j: usize| -PI / 2.0 + j as f64 * TAU / N as f64;
    let far = |j: usize| if at(j).sin() < -0.5 { -0.5 / at(j).sin() } else { 1.0 }; // the spokes that point up end on the bridge
    let mut steps = Vec::new();
    let mut add = |j: usize, f: f64, lay: bool, kind: Strand| steps.push(Step { u: far(j) * f * at(j).cos(), v: far(j) * f * at(j).sin(), lay, kind, f });
    let (wide, close) = ((3.0 * share).round().max(1.0) as usize, (8.0 * share).round().max(2.0) as usize);
    add(10, 1.0, false, Strand::Walk); // 1
    add(2, 1.0, true, Strand::Frame);
    add(0, 1.0, false, Strand::Walk); // 2
    add(0, 0.0, true, Strand::Spoke);
    add(6, 1.0, true, Strand::Spoke);
    for j in [7, 8, 9, 10] {
        add(j, 1.0, true, Strand::Frame); // 3: up the left side,
    }
    add(2, 1.0, false, Strand::Walk); //    back along the bridge,
    for j in [3, 4, 5, 6] {
        add(j, 1.0, true, Strand::Frame); //    down the right side,
    }
    add(0, 0.0, false, Strand::Walk); //    and in to the hub
    for j in [1, 2, 3, 4, 5, 7, 8, 9, 10, 11] {
        add(j, 1.0, true, Strand::Spoke);
        add(0, 0.0, false, Strand::Walk);
    }
    for i in 0..wide * N {
        add(i % N, 0.18 + 0.76 / wide as f64 * (i as f64 / N as f64), true, Strand::Wide); // 4
    }
    for i in 0..close * N {
        add((N - 1 - (i % N)) % N, 0.97 - 0.7 / close as f64 * (i as f64 / N as f64), true, Strand::Close); // 5
    }
    add(0, 0.0, false, Strand::Walk);
    steps
}
/// The steps of each of the seven sizes.
/// The steps of every size of web, for a screen to draw them by. They are worked out each time
/// they are wanted, here and in the work: nothing of them is kept.
pub fn plans() -> Vec<Vec<Step>> {
    SHARES.iter().map(|&share| web_plan(share)).collect()
}
/// The plans written out, for a screen to draw a web from: for each size its steps, and for
/// each step where it ends, whether it lays a strand, what kind, and how far out it is.
pub fn plans_written() -> String {
    let size = |steps: &Vec<Step>| {
        let step = |s: &Step| {
            let kind = match s.kind {
                Strand::Walk => "walk",
                Strand::Frame => "frame",
                Strand::Spoke => "spoke",
                Strand::Wide => "wide",
                Strand::Close => "close",
            };
            format!("{{\"u\":{},\"v\":{},\"lay\":{},\"kind\":\"{}\",\"f\":{}}}", s.u, s.v, s.lay, kind, s.f)
        };
        format!("[{}]", steps.iter().map(step).collect::<Vec<_>>().join(","))
    };
    format!("[{}]", plans().iter().map(size).collect::<Vec<_>>().join(","))
}
/// Which of the seven sizes the web is: the first for anything that is not one of them.
fn level(web: &Web) -> usize {
    if web.level >= 0.0 && web.level.fract() == 0.0 && web.level < SHARES.len() as f64 { web.level as usize } else { 0 }
}
fn plan(web: &Web) -> Vec<Step> {
    web_plan(SHARES[level(web)])
}
/// How far a web of this size reaches from its hub: a share of as far as one can reach here.
pub fn web_reach(edge: &Edge, web: &Web) -> f64 {
    (SIZE * 4.5).min(edge.w.min(edge.h) / 2.0 - edge.inset - SIZE * 2.4 - 2.0) * SHARES[level(web)]
}
/// Where step k of the web ends: the hub for anything that is not a step.
fn web_point(steps: &[Step], edge: &Edge, web: &Web, k: f64) -> (f64, f64) {
    if k >= 0.0 && k.fract() == 0.0 && k < steps.len() as f64 {
        let (step, reach) = (&steps[k as usize], web_reach(edge, web));
        (web.x + reach * step.u, web.y + reach * step.v)
    } else {
        (web.x, web.y)
    }
}
/// The strands that can hold a moth, each with its number and its two ends. Only the close
/// spiral holds a moth, and a broken strand holds nothing.
fn holding(world: &World) -> Vec<(usize, (f64, f64), (f64, f64))> {
    let web = &world.web;
    if !web.on || !web.made.is_finite() {
        return Vec::new();
    }
    let steps = plan(web);
    let made = (web.made.floor().max(0.0) as usize).min(steps.len());
    let torn: Vec<usize> = web.torn.split(',').filter_map(|t| t.parse().ok()).collect();
    (1..made)
        .filter(|k| steps[*k].kind == Strand::Close && !torn.contains(k))
        .map(|k| (k, web_point(&steps, &world.edge, web, (k - 1) as f64), web_point(&steps, &world.edge, web, k as f64)))
        .collect()
}
/// The strand a moth is touching, by its number, or nothing.
fn strand_of(strands: &[(usize, (f64, f64), (f64, f64))], moth: &Moth) -> Option<usize> {
    strands.iter().find_map(|&(k, (ax, ay), (bx, by))| {
        let (dx, dy) = (bx - ax, by - ay);
        let long = dx * dx + dy * dy;
        let t = clamp(((moth.x - ax) * dx + (moth.y - ay) * dy) / if long > 0.0 { long } else { 1.0 }, 0.0, 1.0); // the nearest place on the strand
        if (moth.x - ax - t * dx).hypot(moth.y - ay - t * dy) < SIZE * WEB_HOLDS { Some(k) } else { None }
    })
}
/// A moth's number, as it is written in a list.
fn number(moth: &Moth) -> String {
    Val::Num(moth.id).written()
}
/// Which moths are in the web: their numbers, written out with commas between.
pub fn in_web(world: &World) -> String {
    let strands = holding(world);
    world.moths.iter().filter(|moth| strand_of(&strands, moth).is_some()).map(number).collect::<Vec<_>>().join(",")
}
/// The web's own turn in a round. It is begun where the spider first sits full, pulled in
/// to fit. A step of it is made when the spider reaches the end of that step with the
/// thread in hand. Finished, it stands for a while and then is old. An old web is taken
/// down from the hub, the last strand first, and then there is none and one is begun again.
fn web_work(world: &mut World, body: &Body, free: bool, dt: f64) {
    let at_work = free && body.full;
    if at_work && !world.web.on {
        world.web.level = (world.tally.webs.max(0.0) as usize).min(SHARES.len() - 1) as f64; // each new web reaches further than the last
        let reach = web_reach(&world.edge, &world.web);
        if reach > SIZE * 0.6 {
            let m = world.edge.inset + SIZE * 2.4 + reach;
            let (x, y) = (clamp(body.x, m, m.max(world.edge.w - m)), clamp(body.y, m, m.max(world.edge.h - m)));
            world.web = Web { on: true, x, y, made: 0.0, tied: false, age: 0.0, old: false, torn: String::new(), level: world.web.level };
        }
    }
    let steps = plan(&world.web).len() as f64;
    let web = &mut world.web;
    if web.on && !web.old && web.made >= steps {
        web.age += dt; // a finished web stands for a while, and then it is old
        web.old = web.age >= WEB_LASTS;
    }
    if !(at_work && web.on) {
        web.tied = false; // away from its web, the spider has let the thread go
    } else if web.old {
        if (web.x - body.x).hypot(web.y - body.y) < body.size * 0.5 {
            web.made = (web.made - dt * 50.0).max(0.0);
            web.on = web.made > 0.0;
        }
    } else if web.made < steps {
        let (wx, wy) = web_point(&plan(web), &world.edge, web, if web.tied { web.made } else { web.made - 1.0 });
        let there = (wx - body.x).hypot(wy - body.y) < body.size * 0.4;
        if !web.tied {
            web.tied = web.made == 0.0 || there; // back where it left off, it takes the thread up
        } else if there {
            web.made += 1.0; // a step is made when the spider reaches the end of it
            if web.made >= steps {
                world.tally.webs += 1.0;
            }
        }
    }
}

// ---- the world's own work: the moths

/// A moth comes in over the edge and is given its number.
fn arrive(world: &mut World, own: &mut Own) {
    let (edge, side, t) = (&world.edge, (draw(&mut own.chance) * 4.0).floor(), draw(&mut own.chance));
    let lo = edge.inset + MOTH_EDGE;
    let x = if side < 2.0 { lo + t * (edge.w - 2.0 * lo) } else if side == 2.0 { lo } else { edge.w - lo };
    let y = if side >= 2.0 { lo + t * (edge.h - 2.0 * lo) } else if side == 0.0 { lo } else { edge.h - lo };
    own.next_id += 1.0;
    let moth = Moth { id: own.next_id, x, y, h: (edge.h / 2.0 - y).atan2(edge.w / 2.0 - x), wx: edge.w / 2.0, wy: edge.h / 2.0, until: 0.0 };
    world.moths.push(moth);
}
/// A moth wanders, never in a straight line, and keeps away from the pointer.
fn flutter(moth: &mut Moth, edge: &Edge, own: &mut Own, dt: f64, now: f64) {
    let lo = edge.inset + MOTH_EDGE;
    let (wide, tall) = (lo.max(edge.w - lo), lo.max(edge.h - lo));
    let (dx, dy) = (moth.x - own.pointer.x, moth.y - own.pointer.y);
    let d = dx.hypot(dy).max(1e-9);
    let near = SIZE * 3.2;
    let shy = own.pointer.inside && d < near; // the pointer is too close
    if shy {
        // it makes for a place on the far side of itself from the pointer
        moth.wx = clamp(moth.x + dx / d * near * 2.0, lo, wide);
        moth.wy = clamp(moth.y + dy / d * near * 2.0, lo, tall);
        moth.until = now + 1200.0;
    } else if now >= moth.until {
        moth.wx = lo + draw(&mut own.chance) * (edge.w - 2.0 * lo);
        moth.wy = lo + draw(&mut own.chance) * (edge.h - 2.0 * lo);
        moth.until = now + 1500.0 + draw(&mut own.chance) * 2500.0;
    }
    moth.h += turn((moth.wy - moth.y).atan2(moth.wx - moth.x) - moth.h) * (dt * if shy { 8.0 } else { 2.5 }).min(1.0) + (draw(&mut own.chance) - 0.5) * 9.0 * dt;
    let v = SIZE * if shy { 3.4 } else { 2.1 }; // and it goes faster while it is getting away
    moth.x = clamp(moth.x + moth.h.cos() * v * dt, lo, wide);
    moth.y = clamp(moth.y + moth.h.sin() * v * dt, lo, tall);
}
/// The level of an upgrade at the shop, for the work to read and to raise: nothing, for a
/// name that is no upgrade.
fn level_of<'a>(shop: &'a mut Shop, what: &str) -> Option<&'a mut f64> {
    match what {
        "spawn" => Some(&mut shop.spawn),
        "appetite" => Some(&mut shop.appetite),
        "spider" => Some(&mut shop.spider),
        "web" => Some(&mut shop.web),
        _ => None,
    }
}
/// The most the shop has of an upgrade: nothing, for one that has no most.
fn most_of(what: &str) -> Option<f64> {
    match what {
        "spawn" => Some(SPAWN_MOST),
        "appetite" => Some(APPETITE_MOST),
        _ => None,
    }
}
/// One round of the world's own work. Only this, and the putting right, may change the world.
/// `held` is the moths observer's list of the moths it has halted in the web: the world does
/// not move a moth that is on it.
pub fn world_work(world: &mut World, spider: &Spider, held: &str, own: &mut Own, dt: f64, now: f64) {
    let body = &spider.body;
    own.gains.retain(|gain| now - gain.at < 60000.0);
    // An upgrade is bought if there are moths enough to pay for it.
    for what in std::mem::take(&mut own.buys) {
        let level = match level_of(&mut world.shop, what) {
            Some(level) => *level,
            None => continue,
        };
        // the shop has no more of an upgrade that is at its most
        if most_of(what).map_or(false, |most| level >= most) {
            continue;
        }
        let cost = match cost_of(what, level) {
            Some(cost) => cost,
            None => continue,
        };
        if purse(&world.tally) >= 100.0 * cost {
            if let Some(bought) = level_of(&mut world.shop, what) {
                *bought = level + 1.0;
                world.tally.spent += cost;
            }
        }
    }
    let free = body.state == "walking" || body.state == "resting";
    web_work(world, body, free, dt);
    // Full, or on its way to the old spider, the spider catches nothing. Otherwise it catches as many as it has room for.
    let mut room = if free && !body.full && !spider.old.on { ((1.0 - body.food + 1e-9) / bite(&world.shop, body)).floor() } else { 0.0 };
    let (by_spider, by_web) = (10.0 + world.shop.spider, 10.0 + world.shop.web); // what a catch is worth, in tenths
    let halted: Vec<&str> = held.split(',').collect();
    let is_halted = |moth: &Moth| halted.contains(&number(moth).as_str());
    // A click on a moth halted in the web takes it, and tears away the strand it was on.
    let mut taken: Vec<usize> = Vec::new();
    for (cx, cy) in std::mem::take(&mut own.clicks) {
        let hit = (0..world.moths.len()).find(|&i| !taken.contains(&i) && is_halted(&world.moths[i]) && (world.moths[i].x - cx).hypot(world.moths[i].y - cy) < SIZE * CLICK_TAKES);
        if let Some(i) = hit {
            if let Some(k) = strand_of(&holding(world), &world.moths[i]) {
                if !world.web.torn.is_empty() {
                    world.web.torn.push(',');
                }
                world.web.torn.push_str(&k.to_string());
            }
            taken.push(i);
        }
    }
    let (mut kept, mut loose) = (Vec::with_capacity(world.moths.len()), 0);
    for (i, mut moth) in std::mem::take(&mut world.moths).into_iter().enumerate() {
        if taken.contains(&i) {
            // picked out of the web by the pointer: it counts as caught, and feeds nobody
            let worth = 10.0 * by_web;
            world.tally.caught += 1.0;
            world.tally.picked += 1.0;
            world.tally.gained += worth;
            note_gain(own, moth.x, moth.y, worth, now);
            continue;
        }
        if room > 0.0 && (moth.x - body.x).hypot(moth.y - body.y) < body.size * 0.7 {
            // caught by the spider, and worth more if it was in the web
            let in_web = is_halted(&moth);
            let worth = if in_web { by_spider * by_web } else { 10.0 * by_spider };
            room -= 1.0;
            world.tally.caught += 1.0;
            if in_web {
                world.tally.webbed += 1.0;
            }
            world.tally.gained += worth;
            note_gain(own, body.x, body.y, worth, now);
            continue;
        }
        if !is_halted(&moth) {
            flutter(&mut moth, &world.edge, own, dt, now); // a halted moth stays where it is
            loose += 1;
        }
        kept.push(moth);
    }
    world.moths = kept;
    // Moths arrive at so many a minute, a little unevenly. There can be four on the wing and
    // ten in all, and each upgrade bought for more of them allows one and two more.
    let more = world.shop.spawn.max(0.0);
    if loose < MOTHS_LOOSE.saturating_add(more as usize) && world.moths.len() < MOTHS_MOST.saturating_add(MOTHS_MORE.saturating_mul(more as usize)) && now >= own.next_moth {
        arrive(world, own);
        own.next_moth = now + 60000.0 / (MOTHS_A_MINUTE + more) * (0.6 + 0.8 * draw(&mut own.chance));
    }
}

// ---- the spider's own work

fn enter(body: &mut Body, state: &str, now: f64, chance: &mut Chance) {
    if body.state == state {
        return;
    }
    body.state = state.into();
    if state == "resting" {
        body.until = now + 600.0 + draw(chance) * 1800.0;
    }
}
fn go_to(body: &mut Body, edge: &Edge, x: f64, y: f64, exact: bool, now: f64, chance: &mut Chance) {
    if !x.is_finite() || !y.is_finite() {
        return;
    }
    let (tx, ty) = in_scope(edge, body.size, x, y);
    body.tx = tx; body.ty = ty; body.exact = exact;
    enter(body, "walking", now, chance);
}
/// Where to go: after the nearest moth when it is hungry, to its web when it is full, after
/// the pointer while it moves, and otherwise somewhere new after a rest.
fn decide(body: &mut Body, old: &Old, world: &World, own: &mut Own, now: f64) -> bool {
    if old.on {
        go_to(body, &world.edge, old.x, old.y, true, now, &mut own.chance); // a new spider goes first to the old one
        return false;
    }
    if !body.full {
        let mut prey: Option<(f64, f64, f64)> = None;
        for moth in &world.moths {
            let d = (moth.x - body.x).hypot(moth.y - body.y);
            if prey.map_or(true, |(near, _, _)| d < near) {
                prey = Some((d, moth.x, moth.y));
            }
        }
        if let Some((_, x, y)) = prey {
            go_to(body, &world.edge, x, y, true, now, &mut own.chance);
            return false;
        }
    }
    if body.full && world.web.on {
        // Full, it works on its web, or sits at the middle of it. Making it, it walks to the
        // end of the next step. Coming back to it, it first walks to where it left off, to
        // take up the thread again. A finished or an old web: the hub.
        let web = &world.web;
        let steps = plan(web);
        let k = if web.old || web.made >= steps.len() as f64 { -1.0 } else if web.tied { web.made } else { web.made - 1.0 };
        let (wx, wy) = web_point(&steps, &world.edge, web, k);
        if k >= 0.0 || (wx - body.x).hypot(wy - body.y) > body.size * 0.5 {
            go_to(body, &world.edge, wx, wy, true, now, &mut own.chance);
        }
        return false;
    }
    let following = own.pointer.inside && now - own.pointer.moved < 3000.0;
    if following {
        let (tx, ty) = in_scope(&world.edge, body.size, own.pointer.x, own.pointer.y);
        body.tx = tx; body.ty = ty; body.exact = false;
        if body.state == "resting" && (tx - body.x).hypot(ty - body.y) > body.size * 2.6 {
            enter(body, "walking", now, &mut own.chance);
        }
    } else if body.state == "resting" && now >= body.until {
        let m = world.edge.inset + body.size * 2.4;
        let (x, y) = (m + draw(&mut own.chance) * (world.edge.w - 2.0 * m), m + draw(&mut own.chance) * (world.edge.h - 2.0 * m));
        go_to(body, &world.edge, x, y, true, now, &mut own.chance);
    }
    following
}

fn step_body(body: &mut Body, pointer: &Pointer, following: bool, dt: f64, now: f64, chance: &mut Chance) {
    let h0 = body.h;
    let mut goal = 0.0;
    if body.state == "walking" {
        let (dx, dy) = (body.tx - body.x, body.ty - body.y);
        let d = dx.hypot(dy);
        let stop_at = body.size * if body.exact { 0.25 } else { 1.9 }; // it stops short of the pointer, and right on anything else
        if d <= stop_at {
            enter(body, "resting", now, chance);
        } else {
            let da = turn(dy.atan2(dx) - body.h);
            body.h += clamp(da, -3.2 * dt, 3.2 * dt);
            let ahead = da.cos().max(0.0); // it slows down to turn
            goal = (body.size * 5.5 * (1.0 + body.boost)).min((d - stop_at) * 5.0 + body.size * 0.8) * ahead * ahead;
        }
    } else if following {
        // at rest it still turns to face the pointer
        let (dx, dy) = (pointer.x - body.x, pointer.y - body.y);
        if dx.hypot(dy) > body.size {
            body.h += clamp(turn(dy.atan2(dx) - body.h), -2.5 * dt, 2.5 * dt);
        }
    }
    body.v += (goal - body.v) * (dt * 9.0).min(1.0);
    if goal == 0.0 && body.v < 0.5 {
        body.v = 0.0;
    }
    body.x += body.v * body.h.cos() * dt;
    body.y += body.v * body.h.sin() * dt;
    body.moved = body.v * dt;
    body.turned = turn(body.h - h0);
}

/// The eight legs step in two sets of four that take turns. A set lifts, swings to where its
/// feet will be needed, and plants them. The body then moves on over the planted feet. The
/// faster the body goes, the longer its steps and the more of them it takes each second, as
/// spiders do. Once the body stops, the sets go on stepping until every foot is back where
/// it belongs.
fn step_legs(spider: &mut Spider, dt: f64) {
    if dt <= 0.0 {
        return;
    }
    let Spider { body, legs, .. } = spider;
    let s = body.size;
    // How fast the feet have to keep up, in body lengths a second. A turn counts by how far it moves the far feet.
    let speed = 9.0f64.min((body.moved + body.turned.abs() * s * 1.8) / (dt * s));
    let still = speed < 0.25;
    let (mut worst, mut any_up) = (0.0f64, false); // how far the worst planted foot is from where it belongs
    for leg in legs.iter() {
        if leg.up {
            any_up = true;
            continue;
        }
        let (rx, ry) = rest_of(leg, s, body.x, body.y, body.h);
        worst = worst.max((leg.x - rx).hypot(leg.y - ry) / s);
    }
    let mut rate = speed / (0.55 + 0.1 * speed); // steps a second for each leg: the speed over the length of a step
    if still {
        rate = if any_up || worst > 0.2 { 2.2 } else { 0.0 };
    } else {
        rate *= 1.0 + clamp((worst - 0.4) / 0.3, 0.0, 1.0); // a foot left far behind hurries the next steps
    }
    let swing = if rate > 0.0 { clamp(0.35 / rate, 0.08, 0.16) } else { 0.16 }; // the seconds a foot spends in the air
    // A foot is planted ahead of where it belongs, by as far as the body will go in half the time the foot is down.
    let lead = if still { 0.0 } else { 0.5 * (1.0 / rate - swing) };
    let (px, py, ph) = (body.x + body.v * body.h.cos() * lead, body.y + body.v * body.h.sin() * lead, body.h + body.turned / dt * lead);
    let before = body.phase;
    body.phase += rate * dt;
    for leg in legs.iter_mut() {
        let at = leg.set / 2.0 + (3.0 - leg.pair) * 0.02; // when in the cycle this leg lifts: within a set, the back legs go a moment sooner
        if !leg.up && (body.phase + at).floor() > (before + at).floor() {
            leg.up = true; leg.t = 0.0; leg.dur = swing; leg.fx = leg.x; leg.fy = leg.y;
        }
        if !leg.up {
            continue;
        }
        leg.t = (leg.t + dt / leg.dur).min(1.0);
        let (gx, gy) = rest_of(leg, s, px, py, ph);
        let e = leg.t * leg.t * (3.0 - 2.0 * leg.t);
        leg.x = leg.fx + (gx - leg.fx) * e;
        leg.y = leg.fy + (gy - leg.fy) * e;
        if leg.t >= 1.0 {
            leg.up = false;
        }
    }
}

/// The spider dies, and in the same round the next one is there. The dead one stays where
/// it is, as the old spider. The living one is a new spider just outside the edge, on a
/// side picked by chance, facing the old one, with its front feet at the edge. Both are the
/// spider's, under the same observers, so the new one is watched from the round it is there.
fn succeed(spider: &mut Spider, edge: &Edge, own: &mut Own, now: f64) {
    let Spider { body, old, legs } = spider;
    *old = Old { on: true, x: body.x, y: body.y, h: body.h, size: body.size, meals: body.meals };
    let (side, t, out) = ((draw(&mut own.chance) * 4.0).floor(), draw(&mut own.chance), SIZE * 0.5 * WAITS_OUT);
    body.x = if side == 0.0 { -out } else if side == 1.0 { edge.w + out } else { t * edge.w };
    body.y = if side == 2.0 { -out } else if side == 3.0 { edge.h + out } else { t * edge.h };
    body.h = (old.y - body.y).atan2(old.x - body.x);
    body.gen += 1.0;
    body.grip = -1.0;
    own.grab = None; // what the pointer had hold of has died: it has hold of nothing now
    body.age = 0.0; body.size = size_now(body); body.meals = 0.0; body.food = 0.5; body.full = false;
    body.v = 0.0; body.moved = 0.0; body.turned = 0.0; body.phase = 0.45;
    body.state = "resting".into(); body.until = now; body.tx = body.x; body.ty = body.y;
    for leg in legs.iter_mut() {
        let (x, y) = rest_of(leg, body.size, body.x, body.y, body.h);
        leg.x = x; leg.y = y; leg.up = false;
    }
}

/// Panic: what the spider does while the pointer has hold of it. Held by the body, it is
/// carried, and all eight legs flail. Held by a leg, it is dragged along by that leg, and the
/// other seven flail. It cannot be taken over the edge.
fn panics(spider: &mut Spider, edge: &Edge, pointer: &Pointer, held: usize, dt: f64, now: f64) {
    let Spider { body, legs, .. } = spider;
    body.state = "panic".into();
    body.grip = held as f64;
    body.v = 0.0; body.moved = 0.0; body.turned = 0.0;
    let (s, lo) = (body.size, edge.inset + MOTH_EDGE);
    if held >= legs.len() {
        let (px, py) = in_scope(edge, s, pointer.x, pointer.y);
        body.x += (px - body.x) * (dt * 20.0).min(1.0);
        body.y += (py - body.y) * (dt * 20.0).min(1.0);
        body.h += (now * 0.021).sin() * 4.0 * dt; // it twists about
    } else {
        let (side, pair) = (legs[held].side, pair_of(&legs[held]));
        let reach = s * REACH[pair];
        let (px, py) = (clamp(pointer.x, lo, lo.max(edge.w - lo)), clamp(pointer.y, lo, lo.max(edge.h - lo)));
        let (dx, dy) = (body.x - px, body.y - py);
        let d = dx.hypot(dy);
        if d > reach {
            // the leg is at full stretch, so the body is pulled along
            let (x, y) = in_scope(edge, s, px + dx / d * reach, py + dy / d * reach);
            body.x = x; body.y = y;
        }
        let (ex, ey) = (px - body.x, py - body.y);
        let e = ex.hypot(ey);
        let (ux, uy) = if e > 0.0 { (ex / e, ey / e) } else { (1.0, 0.0) };
        let far = e.min(reach * 1.15); // a leg only stretches so far
        legs[held].x = body.x + ux * far; legs[held].y = body.y + uy * far; legs[held].up = false;
        body.h += clamp(turn(uy.atan2(ux) - side * FOOT[pair] - body.h), -6.0 * dt, 6.0 * dt); // it swings round until that leg points at the pointer
    }
    for (k, leg) in legs.iter_mut().enumerate() {
        if k == held {
            continue;
        }
        // every leg that is not held thrashes about its place
        let ((rx, ry), wide) = (rest_of(leg, s, body.x, body.y, body.h), s * 0.5);
        leg.x = rx + wide * (now * 0.031 + k as f64 * 1.7).cos();
        leg.y = ry + wide * (now * 0.037 + k as f64 * 2.3).sin();
        leg.up = true; leg.t = 0.0; leg.dur = 0.1; leg.fx = leg.x; leg.fy = leg.y;
    }
}

/// One round of the spider's own work. Only this, and the putting right, may change the spider.
pub fn spider_work(spider: &mut Spider, world: &World, own: &mut Own, dt: f64, now: f64) {
    let Spider { body, old, .. } = &mut *spider;
    let free = body.state == "walking" || body.state == "resting";
    let (near_x, near_y) = in_scope(&world.edge, body.size, old.x, old.y); // as near to the old one as a spider can come
    if old.on && free && (near_x - body.x).hypot(near_y - body.y) < body.size * 0.5 {
        // it has reached the old spider, and eats it: a full meal, and the better for each moth that one ate
        old.on = false;
        body.husks += 1.0;
        body.food = 1.0;
        body.full = true;
        body.boost = BOOST_MOST.min(body.boost + BOOST_STEP.min(0.01 * old.meals));
    }
    body.age += dt; // it grows older and, until it is full grown, bigger
    body.size = size_now(body);
    let ate = world.tally.caught - world.tally.picked; // the moths it caught itself: the ones the pointer picked do not feed it
    if ate > body.eaten {
        // what it has just caught fills it
        body.food = (body.food + bite(&world.shop, body) * (ate - body.eaten)).min(1.0);
        body.meals += ate - body.eaten;
        body.eaten = ate;
    }
    let lasts = if in_hand(own).is_some() { FRIGHT } else { EMPTY } * (1.0 + body.boost); // how long a full meter lasts: not long while it is panicking
    body.food = (body.food - dt / lasts).max(0.0); // and it runs down again
    if body.age >= LIFE || body.food <= 0.0 {
        succeed(spider, &world.edge, own, now); // it dies, of old age or with nothing left, and the next one walks in
    }
    let body = &mut spider.body;
    let idle = world.web.on && !world.web.old && world.web.made >= plan(&world.web).len() as f64; // its web is finished, so it has nothing to wait for
    if body.food > 1.0 - bite(&world.shop, body) + 1e-9 {
        body.full = true; // full after its fill
    } else if body.food <= HUNGRY || idle {
        body.full = false; // hungry once most of that has gone, or at once if its web is finished
    }
    if let Some(held) = in_hand(own) {
        panics(spider, &world.edge, &own.pointer, held, dt, now);
        return;
    }
    if spider.body.grip >= 0.0 {
        // let go: it puts its feet down where it is
        let Spider { body, legs, .. } = &mut *spider;
        body.grip = -1.0;
        body.tx = body.x; body.ty = body.y;
        body.state = "recovering".into();
        body.until = now + RECOVERS;
        for leg in legs.iter_mut() {
            leg.up = false;
        }
    }
    if spider.body.state == "recovering" {
        // it does nothing else until the short while is over
        if now < spider.body.until {
            spider.body.moved = 0.0; spider.body.turned = 0.0;
            step_legs(spider, dt);
            return;
        }
        enter(&mut spider.body, "resting", now, &mut own.chance);
    }
    let Spider { body, old, .. } = &mut *spider;
    let following = decide(body, old, world, own, now);
    step_body(body, &own.pointer, following, dt, now, &mut own.chance);
    step_legs(spider, dt);
}
