//! The rules of the game, a second time.
//!
//! The gate holds the result of every round to the rules of the game, which are written
//! apart from the work. This is those rules written out again from `rules.rs`: every
//! function and every number. The gate holds each round to both texts, and a round that
//! either refuses is not recorded. The two say the same thing, and are meant to. They are two
//! texts, and not one text used twice, so that a change to a rule has to be made in both: a
//! rule loosened in one text only is still held by the other. A test holds each function and
//! each number here to the one in `rules.rs`, word for word.
//!
//! A program that is built may hold one copy of two things that are the same. So every
//! function here begins with this text's mark, `second()`, which makes it another function
//! than the one in `rules.rs` in the program as built too. The program checks at its start
//! that the two functions the gate calls here are not the ones it calls there.
use crate::game::{Body, Moth, Shop, Spider, World};
use super::Asked;

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

const INSET: f64 = 10.0;

/// A moth keeps this far inside the game area.
const LO: f64 = 14.0;

/// The length of a full-grown spider's body. A new one is half that.
const GROWN_SIZE: f64 = 53.0;

const GROWN_AT: f64 = 150.0;

const LIFE: f64 = 300.0;

/// The most a spider can be boosted: by 111 hundredths.
const BOOST_MOST: f64 = 1.11;

/// A new spider stands no further outside the game area than this.
const OUTSIDE: f64 = 36.0;

/// A foot is never further from the body than this many body lengths.
const FOOT: f64 = 4.0;

/// Each upgrade: its name, the price of the first, and how many times dearer each one is than the last.
const PRICES: [(&str, f64, f64); 4] = [("spawn", 10.0, 1.15), ("appetite", 12.0, 1.15), ("spider", 12.0, 1.07), ("web", 10.0, 1.07)];

/// The most the shop has of the two upgrades that have a most: the one for more moths, and the one for appetite.
const SPAWN_MOST: f64 = 19.0;

const APPETITE_MOST: f64 = 24.0;

/// How far each of the seven sizes of web reaches, as a share of the furthest.
const SHARES: [f64; 7] = [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0];

const WEB_LASTS: f64 = 90.0;

/// The longest round there is, in seconds.
const ROUND_MOST: f64 = 0.05;

fn whole(n: f64) -> bool {
    second("whole");
    n.is_finite() && n >= 0.0 && n.fract() == 0.0
}

fn size_at(age: f64) -> f64 {
    second("size_at");
    GROWN_SIZE * (0.5 + 0.5 * (age / GROWN_AT).clamp(0.0, 1.0))
}

/// How many moths fill a spider of an age, with so many appetites bought.
fn stomach(age: f64, appetite: f64) -> f64 {
    second("stomach");
    2.0 + (6.0 * (age / GROWN_AT).clamp(0.0, 1.0)).round() + appetite
}

/// What everything bought at the shop has cost.
fn price_of(shop: &Shop) -> f64 {
    second("price_of");
    let levels = [shop.spawn, shop.appetite, shop.spider, shop.web];
    PRICES.iter().zip(levels).map(|(&(_, first, dearer), level)| (0..level as usize).map(|n| (first * dearer.powf(n as f64)).ceil()).sum::<f64>()).sum()
}

/// How many steps a web of a size takes to make, and how far it reaches from its hub.
fn web_of(level: f64) -> (f64, f64) {
    second("web_of");
    // a size that is not one of the seven is refused before this is asked: this only keeps the asking from stopping the program
    let share = SHARES[(level as usize).min(SHARES.len() - 1)];
    let (wide, close) = ((3.0 * share).round().max(1.0), (8.0 * share).round().max(2.0));
    (36.0 + 12.0 * (wide + close), (GROWN_SIZE * 4.5).min(H / 2.0 - INSET - GROWN_SIZE * 2.4 - 2.0) * share)
}

fn free(body: &Body) -> bool {
    second("free");
    body.state == "walking" || body.state == "resting"
}

/// A moth's number, as it is written in the list of the moths halted in the web.
fn number(moth: &Moth) -> String {
    second("number");
    format!("{}", moth.id)
}

/// What is wrong in a state of the game, taken by itself, or nothing.
pub fn wrong_in(spider: &Spider, world: &World) -> Option<&'static str> {
    second("wrong_in");
    let (body, old, tally, shop, web, edge) = (&spider.body, &spider.old, &world.tally, &world.shop, &world.web, &world.edge);
    if (edge.inset, edge.w, edge.h) != (INSET, W, H) {
        return Some("the edge not where it is fixed");
    }
    let counts = [tally.caught, tally.picked, tally.webs, tally.spent, tally.gained, tally.webbed, shop.spawn, shop.appetite, shop.spider, shop.web, body.husks, body.eaten, body.meals, old.meals];
    if counts.iter().any(|&n| !whole(n)) || !whole(body.gen) || body.gen < 1.0 {
        return Some("a count that is not a whole number");
    }
    if [shop.spawn, shop.appetite, shop.spider, shop.web].iter().any(|&n| n > 10000.0) {
        return Some("more upgrades than can be counted");
    }
    if shop.spawn > SPAWN_MOST || shop.appetite > APPETITE_MOST {
        return Some("more of an upgrade than the shop has");
    }
    if tally.picked + tally.webbed > tally.caught {
        return Some("more moths picked or eaten in the web than caught");
    }
    if tally.spent != price_of(shop) {
        return Some("an upgrade that was not paid for");
    }
    if 100.0 * tally.spent > tally.gained {
        return Some("more moths spent than gained");
    }
    if body.husks > body.gen - 1.0 {
        return Some("more old spiders eaten than have died");
    }
    if !(body.age >= 0.0 && body.age <= LIFE) {
        return Some("the spider older than a spider gets");
    }
    if !((body.size - size_at(body.age)).abs() <= 1e-9) {
        return Some("the spider's size not matching its age");
    }
    if !(body.boost >= 0.0 && body.boost <= BOOST_MOST) {
        return Some("a boost greater than a spider can have");
    }
    if !(body.food >= 0.0 && body.food <= 1.0) {
        return Some("the food meter past one of its ends");
    }
    if !["walking", "resting", "panic", "recovering"].contains(&body.state.as_str()) {
        return Some("the spider in a state it does not have");
    }
    if !(body.grip == -1.0 || (whole(body.grip) && body.grip <= 8.0)) || (body.state == "panic") != (body.grip >= 0.0) {
        return Some("the spider held and not held at once");
    }
    if body.eaten != tally.caught - tally.picked {
        return Some("the moths caught not the moths the spider ate and the pointer picked");
    }
    if body.meals > body.eaten {
        return Some("the spider fed on moths it did not catch");
    }
    let outside = body.x < 0.0 || body.x > W || body.y < 0.0 || body.y > H;
    if !(body.x >= -OUTSIDE && body.x <= W + OUTSIDE && body.y >= -OUTSIDE && body.y <= H + OUTSIDE) || (outside && !old.on) {
        return Some("the spider outside the game area");
    }
    if spider.legs.len() != 8 || spider.legs.iter().any(|leg| !((leg.x - body.x).hypot(leg.y - body.y) <= FOOT * body.size)) {
        return Some("a foot further from the body than a leg can reach");
    }
    if old.on && !(old.size >= GROWN_SIZE * 0.5 - 1e-9 && old.size <= GROWN_SIZE + 1e-9 && old.x >= -OUTSIDE && old.x <= W + OUTSIDE && old.y >= -OUTSIDE && old.y <= H + OUTSIDE) {
        return Some("an old spider that cannot be");
    }
    if world.moths.len() as f64 > 10.0 + 2.0 * shop.spawn {
        return Some("more moths than there is room for");
    }
    for (k, moth) in world.moths.iter().enumerate() {
        if !whole(moth.id) || moth.id < 1.0 || world.moths[..k].iter().any(|other| other.id == moth.id) {
            return Some("a moth with no number of its own");
        }
        if !(moth.x >= LO && moth.x <= W - LO && moth.y >= LO && moth.y <= H - LO) {
            return Some("a moth outside the edge");
        }
    }
    if !whole(web.level) || web.level > 6.0 || web.level > tally.webs {
        return Some("a web of a size it cannot be");
    }
    let (steps, reach) = web_of(web.level);
    let strands = web.torn.is_empty() || web.torn.split(',').all(|k| !k.is_empty() && k.len() < 5 && k.bytes().all(|c| c.is_ascii_digit()));
    if !(web.made >= 0.0 && web.made <= steps && web.age >= 0.0 && web.age <= WEB_LASTS + ROUND_MOST + 1e-9) || !strands {
        return Some("a web that cannot be");
    }
    if (web.old && web.age < WEB_LASTS) || (!web.old && !whole(web.made)) || (web.tied && !web.on) || (!web.on && web.made != 0.0) {
        return Some("a web that cannot be");
    }
    let room = INSET + GROWN_SIZE * 2.4 + reach;
    if web.on && !(web.x >= room && web.x <= W - room && web.y >= room && web.y <= H - room) {
        return Some("the web reaching past the edge");
    }
    None
}

/// What is wrong in the step from one recorded state to the next, or nothing. `held` is the
/// list of the moths that were halted in the web, and `top` the highest number any moth has
/// yet had. `dt` is how long the round was, in seconds, and `now` the time, in thousandths.
pub fn wrong_step(was: (&Spider, &World), held: &str, top: f64, is: (&Spider, &World), asked: &Asked, dt: f64, now: f64) -> Option<&'static str> {
    second("wrong_step");
    let ((s0, w0), (s1, w1)) = (was, is);
    let (b0, b1, o0, o1, t0, t1) = (&s0.body, &s1.body, &s0.old, &s1.old, &w0.tally, &w1.tally);

    // Nothing that is counted goes backwards.
    let counted = [
        (t0.caught, t1.caught), (t0.picked, t1.picked), (t0.webs, t1.webs), (t0.spent, t1.spent), (t0.gained, t1.gained), (t0.webbed, t1.webbed),
        (w0.shop.spawn, w1.shop.spawn), (w0.shop.appetite, w1.shop.appetite), (w0.shop.spider, w1.shop.spider), (w0.shop.web, w1.shop.web),
        (b0.gen, b1.gen), (b0.husks, b1.husks), (b0.eaten, b1.eaten),
    ];
    if counted.iter().any(|&(before, after)| after < before) {
        return Some("a count gone backwards");
    }

    // ---- the moths. A moth that is gone was caught, and a moth that was caught is gone. At
    // most one comes in a round, when one is due, at the edge, with a number not used before.
    let halted: Vec<&str> = held.split(',').collect();
    let was_halted = |moth: &Moth| halted.contains(&number(moth).as_str());
    let gone: Vec<&Moth> = w0.moths.iter().filter(|m| !w1.moths.iter().any(|n| n.id == m.id)).collect();
    let come: Vec<&Moth> = w1.moths.iter().filter(|m| !w0.moths.iter().any(|n| n.id == m.id)).collect();
    let caught = t1.caught - t0.caught;
    if caught != gone.len() as f64 {
        return Some("moths counted as caught that were never there, or gone without being counted");
    }
    if come.len() > 1 {
        return Some("more than one moth coming in a round");
    }
    if let Some(moth) = come.first() {
        if now < asked.next_moth {
            return Some("a moth coming before one was due");
        }
        if moth.id <= top {
            return Some("a moth with a number that has been used");
        }
        if !(moth.x == LO || moth.x == W - LO || moth.y == LO || moth.y == H - LO) {
            return Some("a moth coming in away from the edge");
        }
    }
    let fastest = GROWN_SIZE * 3.4 * dt + 1e-6;
    for moth in &w1.moths {
        if let Some(before) = w0.moths.iter().find(|m| m.id == moth.id) {
            let moved = (moth.x - before.x).hypot(moth.y - before.y);
            if was_halted(before) && (moved != 0.0 || moth.h != before.h) {
                return Some("a moth halted in the web that moved");
            }
            if moved > fastest {
                return Some("a moth flying faster than a moth flies");
            }
        }
    }

    // ---- what was caught. A moth is picked out of the web by a click, or caught by a spider
    // that is hungry, free, has room for it, and can reach it. Each is worth what the
    // multipliers make it, and that is what is gained.
    let (picked, webbed) = (t1.picked - t0.picked, t1.webbed - t0.webbed);
    let fed = caught - picked; // the moths the spider caught
    let plain = fed - webbed; // and of those, the ones not in its web
    if fed < 0.0 || plain < 0.0 {
        return Some("more moths picked or eaten in the web than caught");
    }
    if picked > asked.clicks as f64 {
        return Some("a moth picked out of the web with no click");
    }
    if (gone.iter().filter(|m| was_halted(m)).count() as f64) < picked + webbed {
        return Some("a moth taken from the web that was not in it");
    }
    if fed > 0.0 {
        if !free(b0) || b0.full || o0.on {
            return Some("the spider catching a moth while it was full, held, or on its way to the old spider");
        }
        if fed > ((1.0 - b0.food + 1e-9) / (1.0 / stomach(b0.age, w1.shop.appetite))).floor() {
            return Some("the spider catching more moths than it has room for");
        }
        if (gone.iter().filter(|m| (m.x - b0.x).hypot(m.y - b0.y) < b0.size * 0.7).count() as f64) < fed {
            return Some("the spider catching a moth it could not reach");
        }
    }
    let (by_spider, by_web) = (10.0 + w1.shop.spider, 10.0 + w1.shop.web);
    if t1.gained - t0.gained != picked * 10.0 * by_web + webbed * by_spider * by_web + plain * 10.0 * by_spider {
        return Some("moths gained that the catches do not account for");
    }

    // ---- the shop. An upgrade is bought only when it was asked for, with moths already caught.
    for (name, before, after) in [("spawn", w0.shop.spawn, w1.shop.spawn), ("appetite", w0.shop.appetite, w1.shop.appetite), ("spider", w0.shop.spider, w1.shop.spider), ("web", w0.shop.web, w1.shop.web)] {
        if after - before > asked.buys.iter().filter(|asked| **asked == name).count() as f64 {
            return Some("an upgrade bought that was not asked for");
        }
    }
    if 100.0 * t1.spent > t0.gained {
        return Some("an upgrade paid for with moths not yet caught");
    }

    // ---- the web. It is begun new, grows a step at a time under a spider at work on it,
    // stands, grows old, and is taken down from its hub. It does not move or change size.
    let (web0, web1, at_work, finished) = (&w0.web, &w1.web, free(b0) && b0.full, t1.webs - t0.webs);
    if !web0.on {
        if finished != 0.0 {
            return Some("a web counted as finished that was not");
        }
        if web1.on {
            if !at_work || web1.made != 0.0 || web1.age != 0.0 || web1.old || !web1.torn.is_empty() || web1.level != t1.webs.min(6.0) {
                return Some("a web begun that is not a new one");
            }
        } else if (web1.x, web1.y, web1.made, web1.age, web1.old, &web1.torn) != (web0.x, web0.y, web0.made, web0.age, web0.old, &web0.torn) || (web1.level != web0.level && web1.level != t1.webs.min(6.0)) {
            return Some("a web that is not there changed");
        }
    } else {
        let (steps, _) = web_of(web0.level);
        if (web1.x, web1.y, web1.level) != (web0.x, web0.y, web0.level) {
            return Some("the web moved or changed size");
        }
        if web0.old && (!web1.old || web1.age != web0.age) {
            return Some("an old web that did not stay old");
        }
        if !web0.old {
            let aged = web1.age - web0.age;
            if aged < 0.0 || aged > dt + 1e-9 || (aged > 0.0 && web0.made < steps) {
                return Some("the web older than the time played allows");
            }
        }
        if web1.old {
            // An old web, which it may have become in this very round, is taken down from its hub and never grows.
            if web1.made > web0.made || web1.on != (web1.made > 0.0) {
                return Some("an old web that grew, or was taken away before it was taken down");
            }
            if web1.made < web0.made {
                if web0.made - web1.made > 50.0 * dt + 1e-9 {
                    return Some("the web taken down faster than a spider can");
                }
                if !at_work || (web0.x - b0.x).hypot(web0.y - b0.y) >= b0.size * 0.5 {
                    return Some("the web taken down with no spider at its hub");
                }
            }
        } else {
            let grew = web1.made - web0.made;
            if !web1.on || (grew != 0.0 && grew != 1.0) {
                return Some("the web grown by more than a step, or taken away");
            }
            if grew == 1.0 && !(at_work && web0.tied && web0.made < steps) {
                return Some("the web grown with no spider at work on it");
            }
        }
        if !web1.torn.starts_with(web0.torn.as_str()) || (web1.torn.len() > web0.torn.len() && picked < 1.0) {
            return Some("a strand broken with no moth taken from it");
        }
        if finished != if !web0.old && web0.made < steps && web1.made >= steps { 1.0 } else { 0.0 } {
            return Some("a web counted as finished that was not");
        }
    }

    // ---- the spider. It eats the old one only where it can reach it, and is boosted by
    // that and by nothing else. Its food is what eating and time make it.
    let (born, ate_old) = (b1.gen - b0.gen, b1.husks - b0.husks);
    if born > 1.0 || ate_old > 1.0 {
        return Some("more than one spider coming, or eaten, in a round");
    }
    if ate_old == 1.0 {
        let room = INSET + b0.size * 2.4;
        let (near_x, near_y) = (o0.x.max(room).min(W - room), o0.y.max(room).min(H - room));
        if !o0.on || !free(b0) || (near_x - b0.x).hypot(near_y - b0.y) >= b0.size * 0.5 {
            return Some("an old spider eaten that was not reached");
        }
    }
    let boost = if ate_old == 1.0 { (b0.boost + (0.01 * o0.meals).min(0.1)).min(BOOST_MOST) } else { b0.boost };
    if b1.boost != boost {
        return Some("a boost that the old spiders eaten do not account for");
    }
    let lasts = if asked.held.is_some() { 5.0 } else { 30.0 } * (1.0 + boost);
    let mut food = if ate_old == 1.0 { 1.0 } else { b0.food };
    if fed > 0.0 {
        food = (food + 1.0 / stomach(b0.age + dt, w1.shop.appetite) * fed).min(1.0);
    }
    let food = (food - dt / lasts).max(0.0);

    if born == 1.0 {
        // It died in this round, of old age or with nothing left, and the next one is there:
        // a new spider outside the edge, with the old one lying where it died.
        if !(b0.age + dt >= LIFE || food <= 1e-12) {
            return Some("a spider dying before its time");
        }
        if b1.age != 0.0 || !((b1.size - GROWN_SIZE * 0.5).abs() <= 1e-9) || b1.meals != 0.0 || b1.food != 0.5 || b1.full || !free(b1) {
            return Some("the next spider not a new one");
        }
        if !(b1.x < 0.0 || b1.x > W || b1.y < 0.0 || b1.y > H) {
            return Some("the next spider not coming in from outside the edge");
        }
        if !o1.on || (o1.x, o1.y, o1.h) != (b0.x, b0.y, b0.h) || !((o1.size - size_at(b0.age + dt)).abs() <= 1e-9) || o1.meals != b0.meals + fed {
            return Some("the old spider not left where it died");
        }
        return None;
    }
    if b1.age != b0.age + dt {
        return Some("the spider's age not the time played");
    }
    if b1.meals != b0.meals + fed {
        return Some("the spider's meals not the moths it caught");
    }
    if !((b1.food - food).abs() <= 1e-9) {
        return Some("the food meter not what eating and time make it");
    }
    if (o1.x, o1.y, o1.h, o1.size, o1.meals) != (o0.x, o0.y, o0.h, o0.size, o0.meals) || o1.on != (o0.on && ate_old == 0.0) {
        return Some("the old spider changed where it lies");
    }
    // Held, it panics. Let go, it gets over it without moving. Otherwise it walks no faster than a spider can.
    match asked.held {
        Some(what) => {
            if b1.state != "panic" || b1.grip != what as f64 {
                return Some("the spider not held by what the pointer has hold of");
            }
        }
        None => {
            let moved = (b1.x - b0.x).hypot(b1.y - b0.y);
            if b1.state == "panic" || b1.grip != -1.0 {
                return Some("the spider held with no pointer holding it");
            }
            if (b0.state == "panic") != (b1.state == "recovering" && b0.state != "recovering") {
                return Some("the spider getting over a holding that never was, or not getting over one that was");
            }
            if b1.state == "recovering" && moved != 0.0 {
                return Some("the spider moving while it gets over being held");
            }
            if moved > b1.size * 5.5 * (1.0 + b1.boost) * dt + 1e-6 {
                return Some("the spider moving faster than it can walk");
            }
        }
    }
    None
}
