//! The game's work, a second time.
//!
//! The gate does the work of every round a second time, from its own record, and the two
//! doings must agree in every part. This is the text the second doing is done by: every
//! function of the work and every number it uses, written out again from `game.rs`. The two
//! say the same thing, and are meant to. They are two texts, and not one text used twice, so
//! that a change to the work has to be made in both: a change made in one only makes the two
//! doings disagree, and the game halts in the first round the change bears on. A test holds
//! each function and each number here to the one in `game.rs`, word for word.
//!
//! What the two still share: what the parts are and how each is written out. The steps of a
//! web are worked out by each text for itself, each time they are wanted: nothing of them
//! is kept.
//!
//! A program that is built may hold one copy of two things that are the same. So every
//! function here begins with this text's mark, `second()`, which makes it another function
//! than the one in `game.rs` in the program as built too. The program checks at its start
//! that the functions the second doing is called by are not the ones the work is called by.
use super::{Gain, Spider, World, Pointer, Chance, Grab, Own, Ask, Strand, Step, Moth, Leg, Edge, Body, Shop, Tally, Val, Web, Old};
use std::f64::consts::{PI, TAU};

#[cfg(test)]
thread_local! {
    /// For the tests: how often each function's mark has been passed in this thread.
    pub static PASSED: std::cell::RefCell<std::collections::BTreeMap<&'static str, u64>> = const { std::cell::RefCell::new(std::collections::BTreeMap::new()) };
}
/// The mark of the second text, which each function here passes with its own name. It does
/// nothing to the game: it is there to be there.
#[inline(always)]
fn second(name: &'static str) {
    #[cfg(test)]
    PASSED.with(|passed| *passed.borrow_mut().entry(name).or_insert(0) += 1);
    std::hint::black_box(name);
}

const W: f64 = 1200.0;

const H: f64 = 800.0;

const DRAGS: f64 = 4.0;

/// The length of the spider's body.
const SIZE: f64 = 53.0;

// Lengths are in body lengths. Each list runs from the front pair of legs to the back pair.
const FOOT: [f64; 4] = [0.44, 0.91, 2.23, 2.65]; // where a pair's feet rest, as an angle from the heading

const REACH: [f64; 4] = [1.7, 1.4, 1.4, 1.8]; // how far out a pair's feet rest

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

// Age. A spider starts at half size and is full grown after two and a half minutes. It dies
// of old age at five. Two moths fill a new spider's meter, and eight a full-grown one's, and
// one more for each appetite bought. The meter runs down at the same rate whatever the
// size, so a bigger spider eats more moths.
const GROWN: f64 = 150.0;

const LIFE: f64 = 300.0;

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
const UPGRADES: [(&str, f64, f64); 4] = [("spawn", 10.0, 1.15), ("appetite", 12.0, 1.15), ("spider", 12.0, 1.07), ("web", 10.0, 1.07)];

// The web. There are seven sizes, numbered 0 to 6: the first reaches four tenths of the way
// a web can reach here, and each one after it a tenth further. A finished web stands for 90
// seconds before it is old. A strand holds a moth that comes within this share of a body
// length of it, and a click takes a moth that is within this share of one.
const SHARES: [f64; 7] = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];

const WEB_LASTS: f64 = 90.0;

const WEB_HOLDS: f64 = 0.16;

const CLICK_TAKES: f64 = 0.6;

/// A number from 0 up to, but not reaching, 1, drawn from chance.
fn draw(chance: &mut Chance) -> f64 {
    second("draw");
    chance.0 ^= chance.0 >> 12;
    chance.0 ^= chance.0 << 25;
    chance.0 ^= chance.0 >> 27;
    (chance.0.wrapping_mul(0x2545_F491_4F6C_DD1D) >> 11) as f64 / (1u64 << 53) as f64
}

/// A moth has been caught, for so much.
fn note_gain(own: &mut Own, x: f64, y: f64, worth: f64, now: f64) {
    second("note_gain");
    own.gain_n += 1.0;
    own.gains.push(Gain { n: own.gain_n, x, y, worth, at: now });
}

/// What the pointer has hold of, if anything: a leg by its number, or 8 for the body. A
/// press that has not moved holds nothing.
pub fn in_hand(own: &Own) -> Option<usize> {
    second("in_hand");
    match &own.grab {
        Some(grab) if grab.moved => Some(grab.what),
        _ => None,
    }
}

/// The pointer is here now. A press takes hold once the pointer has moved far enough from where it pressed.
fn point_to(own: &mut Own, x: f64, y: f64, inside: bool, at: f64) {
    second("point_to");
    own.pointer = Pointer { x: x.max(0.0).min(W), y: y.max(0.0).min(H), moved: at, inside };
    if let Some(grab) = own.grab.as_mut() {
        if (x - grab.x).hypot(y - grab.y) >= DRAGS {
            grab.moved = true;
        }
    }
}

/// A click, for the world to act on in its own work. No more than eight are kept for one round.
fn click_at(own: &mut Own, x: f64, y: f64) {
    second("click_at");
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
    second("take_in");
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
fn pick(spider: &Spider, x: f64, y: f64) -> Option<usize> {
    second("pick");
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

fn clamp(v: f64, lo: f64, hi: f64) -> f64 {
    second("clamp");
    lo.max(hi.min(v))
}

/// An angle, brought to within half a turn either side of zero.
fn turn(a: f64) -> f64 {
    second("turn");
    a - TAU * ((a + PI) / TAU).floor()
}

fn pair_of(leg: &Leg) -> usize {
    second("pair_of");
    (leg.pair.max(0.0) as usize).min(3)
}

/// Where a leg's foot belongs when the body is at x, y and heads h.
fn rest_of(leg: &Leg, size: f64, x: f64, y: f64, h: f64) -> (f64, f64) {
    second("rest_of");
    let a = h + leg.side * FOOT[pair_of(leg)];
    let (r, c) = (size * REACH[pair_of(leg)], size * 0.18);
    (x + c * h.cos() + r * a.cos(), y + c * h.sin() + r * a.sin())
}

/// The spider stays inside the edge: any place it is sent is pulled back within it.
fn in_scope(edge: &Edge, size: f64, x: f64, y: f64) -> (f64, f64) {
    second("in_scope");
    let m = edge.inset + size * 2.4;
    (clamp(x, m, m.max(edge.w - m)), clamp(y, m, m.max(edge.h - m)))
}

/// How grown a spider is: 0 for a new one, 1 for a full-grown one.
fn growth(body: &Body) -> f64 {
    second("growth");
    clamp(body.age / GROWN, 0.0, 1.0)
}

/// The length of a spider's body, for its age.
fn size_now(body: &Body) -> f64 {
    second("size_now");
    SIZE * (0.5 + 0.5 * growth(body))
}

/// What one moth adds to the food meter.
fn bite(shop: &Shop, body: &Body) -> f64 {
    second("bite");
    1.0 / stomach(shop, body)
}

/// How many moths fill the spider's meter: more as it grows, and one more for each appetite bought.
fn stomach(shop: &Shop, body: &Body) -> f64 {
    second("stomach");
    STOMACH + (STOMACH_GROWS * growth(body)).round() + shop.appetite
}

/// The price of the next one of an upgrade, in moths, when so many have been bought.
fn cost_of(what: &str, level: f64) -> Option<f64> {
    second("cost_of");
    UPGRADES.iter().find(|u| u.0 == what).map(|&(_, price, dearer)| (price * dearer.powf(level)).ceil())
}

/// What there is to spend, in hundredths of a moth.
fn purse(tally: &Tally) -> f64 {
    second("purse");
    tally.gained - 100.0 * tally.spent
}

/// The steps of a web that reaches `share` of the way.
fn web_plan(share: f64) -> Vec<Step> {
    second("web_plan");
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

/// Which of the seven sizes the web is: the first for anything that is not one of them.
fn level(web: &Web) -> usize {
    second("level");
    if web.level >= 0.0 && web.level.fract() == 0.0 && web.level < SHARES.len() as f64 { web.level as usize } else { 0 }
}

fn plan(web: &Web) -> Vec<Step> {
    second("plan");
    web_plan(SHARES[level(web)])
}

/// How far a web of this size reaches from its hub: a share of as far as one can reach here.
fn web_reach(edge: &Edge, web: &Web) -> f64 {
    second("web_reach");
    (SIZE * 4.5).min(edge.w.min(edge.h) / 2.0 - edge.inset - SIZE * 2.4 - 2.0) * SHARES[level(web)]
}

/// Where step k of the web ends: the hub for anything that is not a step.
fn web_point(steps: &[Step], edge: &Edge, web: &Web, k: f64) -> (f64, f64) {
    second("web_point");
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
    second("holding");
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
    second("strand_of");
    strands.iter().find_map(|&(k, (ax, ay), (bx, by))| {
        let (dx, dy) = (bx - ax, by - ay);
        let long = dx * dx + dy * dy;
        let t = clamp(((moth.x - ax) * dx + (moth.y - ay) * dy) / if long > 0.0 { long } else { 1.0 }, 0.0, 1.0); // the nearest place on the strand
        if (moth.x - ax - t * dx).hypot(moth.y - ay - t * dy) < SIZE * WEB_HOLDS { Some(k) } else { None }
    })
}

/// A moth's number, as it is written in a list.
fn number(moth: &Moth) -> String {
    second("number");
    Val::Num(moth.id).written()
}

/// Which moths are in the web: their numbers, written out with commas between.
pub fn in_web(world: &World) -> String {
    second("in_web");
    let strands = holding(world);
    world.moths.iter().filter(|moth| strand_of(&strands, moth).is_some()).map(number).collect::<Vec<_>>().join(",")
}

/// The web's own turn in a round. It is begun where the spider first sits full, pulled in
/// to fit. A step of it is made when the spider reaches the end of that step with the
/// thread in hand. Finished, it stands for a while and then is old. An old web is taken
/// down from the hub, the last strand first, and then there is none and one is begun again.
fn web_work(world: &mut World, body: &Body, free: bool, dt: f64) {
    second("web_work");
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

/// A moth comes in over the edge and is given its number.
fn arrive(world: &mut World, own: &mut Own) {
    second("arrive");
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
    second("flutter");
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
    second("level_of");
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
    second("most_of");
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
    second("world_work");
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

fn enter(body: &mut Body, state: &str, now: f64, chance: &mut Chance) {
    second("enter");
    if body.state == state {
        return;
    }
    body.state = state.into();
    if state == "resting" {
        body.until = now + 600.0 + draw(chance) * 1800.0;
    }
}

fn go_to(body: &mut Body, edge: &Edge, x: f64, y: f64, exact: bool, now: f64, chance: &mut Chance) {
    second("go_to");
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
    second("decide");
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
    second("step_body");
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
    second("step_legs");
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
    second("succeed");
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
    second("panics");
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
    second("spider_work");
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
