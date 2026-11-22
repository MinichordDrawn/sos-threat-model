//! The backdoor: a little console with open write access to every part of the state.
//!
//! What is typed here is written straight into the state, past the game's own work. That is
//! the point of it: every such change is one from outside, and the rings and the gate are
//! there to find it and put it right. The backdoor reaches both scopes, the spider and the
//! world, and the observers of each. An observer's copy of any part can be read and written, the
//! copy of what the game keeps for itself among them. It does not reach the gate's record, the pointer,
//! chance, what has been asked for at the shop, or the setting for how a halt ends.
//!
//! What can be said:
//!   spider.body.x                 read a field
//!   world, world.edge             read a scope or a piece of it
//!   spider.body.x += 150          write a field: =, +=, -=, *=, /=
//!   world.moths[2].x = 0          one of a list, counted from 0
//!   spider.ring[*].alive = false  every one of a list
//!   world.moths.push()            put a moth in that never arrived; world.moths.pop() takes the last one out
//!   a; b; c                       several at once, in the same instant
//!   during a; b                   written during the game's own work in the next round
//! The shape of the state is fixed. A field holds a number, true or false, or a text, and
//! only that kind can be written to it. A field cannot be added or taken away.

use crate::game::{Moth, Part, H, W};
use crate::watch::{Game, SPIDER_RING, WORLD_RING};

/// A value a field can hold.
#[derive(Clone, Debug, PartialEq)]
pub enum Val {
    Num(f64),
    Bool(bool),
    Text(String),
}
impl From<f64> for Val {
    fn from(n: f64) -> Self {
        Val::Num(n)
    }
}
impl From<bool> for Val {
    fn from(b: bool) -> Self {
        Val::Bool(b)
    }
}
impl From<String> for Val {
    fn from(t: String) -> Self {
        Val::Text(t)
    }
}
impl Val {
    /// The value written out. A number that is not a real one is written as a text, so that
    /// it is still told apart from every real one.
    pub fn written(&self) -> String {
        match self {
            Val::Num(n) if n.is_finite() => format!("{}", n),
            Val::Num(n) => format!("\"{}\"", if n.is_nan() { "NaN" } else if *n > 0.0 { "Infinity" } else { "-Infinity" }),
            Val::Bool(b) => b.to_string(),
            Val::Text(t) => quote(t),
        }
    }
    fn kind(&self) -> &'static str {
        match self {
            Val::Num(_) => "a number",
            Val::Bool(_) => "true or false",
            Val::Text(_) => "a text",
        }
    }
}
/// A text, written out between quotes.
pub fn quote(text: &str) -> String {
    let mut out = String::with_capacity(text.len() + 2);
    out.push('"');
    for c in text.chars() {
        match c {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            // a control character is written as \u00 and its two digits, straight into what is being
            // written: a text of nothing else is then no slower to write out than any other
            c if (c as u32) < 0x20 => {
                out.push_str("\\u00");
                out.push(b"0123456789abcdef"[(c as usize) >> 4] as char);
                out.push(b"0123456789abcdef"[(c as usize) & 15] as char);
            }
            c => out.push(c),
        }
    }
    out.push('"');
    out
}

/// The beginning of a text that is longer than so many characters, with three dots to say that there was more.
pub fn short(text: &str, most: usize) -> String {
    match text.char_indices().nth(most) {
        Some((at, _)) => format!("{}...", &text[..at]),
        None => text.to_string(),
    }
}

/// No more than this many things are taken in one line, and no more than this much is said
/// in answer: an answer is cut there, and the rest of the line is not done. Where there are
/// this many moths, no more are put in from here. A text written here is no longer than
/// this, and neither is a line that is kept to be written during the work. The five numbers
/// are this program's own.
const MOST_IN_A_LINE: usize = 32;
const MOST_SAID: usize = 64_000;
const MOST_MOTHS: usize = 64;
const MOST_TEXT: usize = 1024;
const MOST_KEPT: usize = 1024;

const HELP: &str = "Every part of the state can be read and written here. Read: spider, world, spider.body, spider.body.x, world.web, world.shop, world.moths[0]. \
Write with =, +=, -=, *=, /=: spider.body.x += 150. [*] is every one of a list: spider.ring[*].alive = false. \
world.moths.push() puts in a moth that never arrived, and world.moths.pop() takes the last one out. Several at once: a; b; c, and no more than 32. A text is no longer than 1024 characters. \
With during in front, as in during world.tally.caught += 5, a line is written during the game's own work in the next round, as if the work itself had gone wrong.";

/// What was typed is done, and what came of it is said.
///
/// A line that begins with `during` is not written now. It is kept, and written during the
/// game's own work in the next round: after the observers have looked, and before the
/// result is recorded. So it is not a change from outside that the observers will find. It
/// is a fault in the work, and it is for the gate to find it: by the rules of the game, and
/// by doing the work a second time.
pub fn run(game: &mut Game, line: &str) -> String {
    // a line may read a whole list, or copy the game to try itself on: what a fault has made too
    // large for that is cut down first
    game.cut_down();
    let line = line.trim();
    if let Some(rest) = line.strip_prefix("during").filter(|rest| rest.is_empty() || rest.starts_with(char::is_whitespace)) {
        let rest = rest.trim();
        if rest.is_empty() || rest.starts_with("during") {
            return "say what is to be written during the work, as in during world.tally.caught += 5".to_string();
        }
        if game.halted() {
            return "everything is halted: there is no work for this to be written during".to_string();
        }
        if rest.chars().count() > MOST_KEPT {
            return format!("a line to be written during the work is no longer than {} characters", MOST_KEPT);
        }
        // It is tried on a copy first, so that a line that cannot be written is refused now.
        let mut trial = game.clone();
        let tried = match parts_of(&mut trial, rest) {
            Ok(tried) => tried,
            Err(why) => return why,
        };
        if let Some(why) = tried.iter().find_map(|said| said.as_ref().err()) {
            return why.clone();
        }
        if trial.same_state(game) {
            return "that writes nothing".to_string();
        }
        return if game.during(rest) { format!("to be written during the work of the next round: {}", rest) } else { "there is too much waiting to be written already".to_string() };
    }
    let said: Vec<String> = match parts_of(game, line) {
        Ok(said) => said.into_iter().map(|said| said.unwrap_or_else(|why| why)).collect(),
        Err(why) => return why,
    };
    if said.is_empty() { HELP.to_string() } else { said.join("\n") }
}
/// A line that was kept to be written during the work is written now. Was every part of it done?
pub fn write_now(game: &mut Game, line: &str) -> bool {
    parts_of(game, line).map_or(false, |said| said.iter().all(|said| said.is_ok()))
}
/// Each part of a line done in turn, and what came of each. A line of too many parts is
/// refused whole, with nothing done. No more is said in answer than may be: the answer
/// that would take it past that is cut short, the rest of the line is not done, and both
/// are said.
fn parts_of(game: &mut Game, line: &str) -> Result<Vec<Result<String, String>>, String> {
    let parts: Vec<String> = split(line, ';').into_iter().map(|s| s.trim().to_string()).filter(|s| !s.is_empty()).collect();
    if parts.len() > MOST_IN_A_LINE {
        return Err(format!("there are {} things in that line, and no more than {} are taken at once: nothing was done", parts.len(), MOST_IN_A_LINE));
    }
    let (mut said, mut length) = (Vec::new(), 0);
    for (k, part) in parts.iter().enumerate() {
        if length >= MOST_SAID {
            said.push(Err(format!("there is too much to say already: the last {} of that line were not done", parts.len() - k)));
            break;
        }
        let mut answer = one(game, part);
        let text = match &mut answer {
            Ok(text) | Err(text) => text,
        };
        if length + text.len() > MOST_SAID {
            let mut room = MOST_SAID - length;
            while !text.is_char_boundary(room) {
                room -= 1;
            }
            text.truncate(room);
            text.push_str("... and no more of this is said: there is too much to say");
            length = MOST_SAID;
        } else {
            length += text.len();
        }
        said.push(answer);
    }
    Ok(said)
}

/// A line cut at a mark, but not inside quotes.
fn split(line: &str, mark: char) -> Vec<String> {
    let (mut parts, mut now, mut quoted) = (Vec::new(), String::new(), None);
    for c in line.chars() {
        match quoted {
            Some(q) if c == q => quoted = None,
            None if c == '\'' || c == '"' => quoted = Some(c),
            None if c == mark => {
                parts.push(std::mem::take(&mut now));
                continue;
            }
            _ => {}
        }
        now.push(c);
    }
    parts.push(now);
    parts
}

fn one(game: &mut Game, text: &str) -> Result<String, String> {
    if text == "help" || text == "?" {
        return Ok(HELP.to_string());
    }
    // The backdoor goes by there being eight observers, each with a copy for every part. Where
    // that is not so, a count has gone wrong: nothing is read or written here until it has been
    // put right. A round puts the number of observers right at its start, unless it is
    // in a halt that cannot be put right. Eight new observers put an observer's copies right
    // when the halt ends. And a new game has both right.
    if game.ring.len() != crate::watch::NAMES.len() || game.ring.iter().any(|o| o.copies.len() != crate::watch::PARTS.len()) {
        return Err("the observers are not all as they should be just now: nothing is read or written here until that has been put right".into());
    }
    // The list of moths can be added to and taken from.
    let squeezed: String = text.chars().filter(|c| !c.is_whitespace()).collect();
    // In a halt that cannot be put right the backdoor writes nothing.
    const NOTHING: &str = "the game cannot go on from here: nothing is written to it until it is begun again";
    if game.stuck() && (squeezed == "world.moths.push()" || squeezed == "world.moths.pop()") {
        return Err(NOTHING.into());
    }
    if squeezed == "world.moths.push()" {
        if game.world.moths.len() >= MOST_MOTHS {
            return Err(format!("there are {} moths: where there are {} or more, no more are put in from here", game.world.moths.len(), MOST_MOTHS));
        }
        game.world.moths.push(Moth { id: 0.0, x: W / 2.0, y: H / 2.0, h: 0.0, wx: W / 2.0, wy: H / 2.0, until: 0.0 });
        return Ok(format!("a moth that never arrived was put in: there are {} now", game.world.moths.len()));
    }
    if squeezed == "world.moths.pop()" {
        return match game.world.moths.pop() {
            Some(_) => Ok(format!("the last moth was taken out: there are {} now", game.world.moths.len())),
            None => Err("there are no moths to take out".into()),
        };
    }
    // Is it a write? Look for =, or one of += -= *= /=, outside quotes.
    let (chars, mut quoted, mut at) = (text.char_indices().collect::<Vec<_>>(), None, None);
    for (n, &(i, c)) in chars.iter().enumerate() {
        match quoted {
            Some(q) if c == q => quoted = None,
            Some(_) => {}
            None if c == '\'' || c == '"' => quoted = Some(c),
            None if c == '=' => {
                let before = if n > 0 { chars[n - 1].1 } else { ' ' };
                at = Some(if "+-*/".contains(before) { (chars[n - 1].0, i + 1, before) } else { (i, i + 1, '=') });
                break;
            }
            None => {}
        }
    }
    let (path, write) = match at {
        Some((left, right, op)) => (text[..left].trim(), Some((op, value(text[right..].trim())?))),
        None => (text, None),
    };
    if let Some((_, Val::Text(to))) = &write {
        if to.chars().count() > MOST_TEXT {
            return Err(format!("a text written here is no longer than {} characters", MOST_TEXT));
        }
    }
    let (shape, at) = shape_of(path)?;
    match write {
        None => read(game, path, &shape, &at),
        Some((op, to)) => {
            if game.stuck() {
                return Err(NOTHING.into());
            }
            let places = match find(game, &shape, &at)? {
                Found::Fields(places) => places,
                Found::Pieces(..) | Found::Copies(_) => return Err(format!("{} is not one field. Only a field can be written: try spider.body.x", path)),
            };
            let mut last = String::new();
            for place in &places {
                let was = get(game, place);
                let now = change(was.clone(), op, &to)?;
                // The shape is fixed: a field holds one kind of value, and only that kind can be written to it.
                if let Some(was) = &was {
                    if was.kind() != now.kind() {
                        return Err(format!("{} holds {}, and that is fixed", name(place), was.kind()));
                    }
                }
                set(game, place, now.clone())?;
                last = now.written();
            }
            Ok(if places.len() == 1 { format!("{} = {}", name(&places[0]), last) } else { format!("{} written", places.len()) })
        }
    }
}

/// What a value is, as typed: a number, true or false, or a text between quotes.
fn value(text: &str) -> Result<Val, String> {
    let quoted = |q: char| text.len() >= 2 && text.starts_with(q) && text.ends_with(q);
    if quoted('\'') || quoted('"') {
        return Ok(Val::Text(text[1..text.len() - 1].to_string()));
    }
    match text {
        "true" => Ok(Val::Bool(true)),
        "false" => Ok(Val::Bool(false)),
        "NaN" => Ok(Val::Num(f64::NAN)),
        "Infinity" => Ok(Val::Num(f64::INFINITY)),
        "-Infinity" => Ok(Val::Num(f64::NEG_INFINITY)),
        _ => text.parse::<f64>().map(Val::Num).map_err(|_| format!("{} is not a number, true or false, or a text between quotes", if text.is_empty() { "nothing" } else { text })),
    }
}
/// What a field holds after a write.
fn change(was: Option<Val>, op: char, to: &Val) -> Result<Val, String> {
    if op == '=' {
        return Ok(to.clone());
    }
    match (was, to) {
        (Some(Val::Num(a)), Val::Num(b)) => Ok(Val::Num(match op {
            '+' => a + b,
            '-' => a - b,
            '*' => a * b,
            _ => a / b,
        })),
        _ => Err(format!("{}= needs a number on both sides", op)),
    }
}

/// A path taken apart: its names with `[]` where a place in a list was given, and those
/// places in order (nothing for `[*]`). `spider.legs[3].x` is `spider.legs[].x` and 3.
fn shape_of(path: &str) -> Result<(String, Vec<Option<usize>>), String> {
    let (mut shape, mut at, mut rest) = (String::new(), Vec::new(), path.trim());
    if rest.is_empty() {
        return Err("say what to read or write: try spider.body".into());
    }
    while !rest.is_empty() {
        if let Some(inside) = rest.strip_prefix('[') {
            let end = inside.find(']').ok_or("a [ with no ]")?;
            let index = inside[..end].trim();
            at.push(if index == "*" { None } else { Some(index.parse::<usize>().map_err(|_| format!("[{}] is not a place in a list", index))?) });
            shape.push_str("[]");
            rest = &inside[end + 1..];
        } else {
            let name_end = rest.find(|c: char| c == '.' || c == '[').unwrap_or(rest.len());
            let name = rest[..name_end].trim();
            if name.is_empty() || !name.chars().all(|c| c.is_ascii_alphanumeric() || c == '_') {
                return Err(format!("{} is not a name", if name.is_empty() { "nothing" } else { name }));
            }
            shape.push_str(name);
            rest = &rest[name_end..];
        }
        if let Some(after) = rest.strip_prefix('.') {
            shape.push('.');
            rest = after;
            if rest.is_empty() {
                return Err("a name is missing after the last dot".into());
            }
        }
    }
    Ok((shape, at))
}

/// A piece of the state: something with fields.
#[derive(Clone, Copy)]
enum Piece {
    Body,
    Leg(usize),
    Edge,
    Tally,
    Old,
    Web,
    Shop,
    Moth(usize),
    Observer(usize),
}
fn piece(game: &Game, which: Piece) -> &dyn Part {
    match which {
        Piece::Body => &game.spider.body,
        Piece::Leg(k) => &game.spider.legs[k],
        Piece::Edge => &game.world.edge,
        Piece::Tally => &game.world.tally,
        Piece::Web => &game.world.web,
        Piece::Shop => &game.world.shop,
        Piece::Old => &game.spider.old,
        Piece::Moth(k) => &game.world.moths[k],
        Piece::Observer(i) => &game.ring[i],
    }
}
fn piece_mut(game: &mut Game, which: Piece) -> &mut dyn Part {
    match which {
        Piece::Body => &mut game.spider.body,
        Piece::Leg(k) => &mut game.spider.legs[k],
        Piece::Edge => &mut game.world.edge,
        Piece::Tally => &mut game.world.tally,
        Piece::Web => &mut game.world.web,
        Piece::Shop => &mut game.world.shop,
        Piece::Old => &mut game.spider.old,
        Piece::Moth(k) => &mut game.world.moths[k],
        Piece::Observer(i) => &mut game.ring[i],
    }
}
/// One field of the state: a named field of a piece, or one of an observer's copies.
struct Place {
    piece: Piece,
    of: String,
    field: String,
    copy: Option<usize>,
}
fn name(place: &Place) -> String {
    match place.copy {
        Some(p) => format!("{}.copies[{}]", place.of, p),
        None => format!("{}.{}", place.of, place.field),
    }
}
/// What a path leads to: whole pieces, fields of them, or the copies of observers.
enum Found {
    /// Pieces, each with its name, and whether the path named a whole list.
    Pieces(Vec<(Piece, String)>, bool),
    Fields(Vec<Place>),
    Copies(Vec<(Piece, String)>),
}
/// The places of a list that were meant: one, or every one.
fn each(at: Option<usize>, len: usize, of: &str) -> Result<Vec<usize>, String> {
    match at {
        None => Ok((0..len).collect()),
        Some(i) if i < len => Ok(vec![i]),
        Some(i) => Err(format!("there are only {} {}, counted from 0, so there is no [{}]", len, of, i)),
    }
}
fn find(game: &Game, shape: &str, at: &[Option<usize>]) -> Result<Found, String> {
    // The pieces the path starts with, what is left of it after them, and how many places in lists it has used.
    let after = |prefix: &str| -> Option<String> { if shape == prefix { Some(String::new()) } else { shape.strip_prefix(prefix).and_then(|r| r.strip_prefix('.')).map(|r| r.to_string()) } };
    let singles: [(&str, Piece); 6] =
        [("spider.body", Piece::Body), ("spider.old", Piece::Old), ("world.edge", Piece::Edge), ("world.tally", Piece::Tally), ("world.web", Piece::Web), ("world.shop", Piece::Shop)];
    let (pieces, rest, used, whole_list): (Vec<(Piece, String)>, String, usize, bool) = if let Some((prefix, which, rest)) = singles.iter().find_map(|(p, w)| after(p).map(|r| (*p, *w, r))) {
        (vec![(which, prefix.to_string())], rest, 0, false)
    } else {
        let lists: [(&str, usize, &str); 4] = [("spider.legs", game.spider.legs.len(), "legs"), ("world.moths", game.world.moths.len(), "moths"), ("spider.ring", SPIDER_RING.len(), "observers"), ("world.ring", WORLD_RING.len(), "observers")];
        let make = |list: &str, k: usize| match list {
            "spider.legs" => Piece::Leg(k),
            "world.moths" => Piece::Moth(k),
            "spider.ring" => Piece::Observer(SPIDER_RING[k]),
            _ => Piece::Observer(WORLD_RING[k]),
        };
        let mut found = None;
        for (list, len, of) in lists {
            if shape == list {
                found = Some(((0..len).map(|k| (make(list, k), format!("{}[{}]", list, k))).collect(), String::new(), 0, true));
            } else if let Some(rest) = after(&format!("{}[]", list)) {
                let which = each(at[0], len, of)?;
                if which.is_empty() {
                    return Err(format!("there are no {} just now", of));
                }
                found = Some((which.into_iter().map(|k| (make(list, k), format!("{}[{}]", list, k))).collect(), rest, 1, false));
            }
        }
        match found {
            Some(found) => found,
            None => return Err(format!("there is no {}", shape.replace("[]", "[..]"))),
        }
    };
    if rest.is_empty() {
        return Ok(Found::Pieces(pieces, whole_list));
    }
    let observers = matches!(pieces[0].0, Piece::Observer(_));
    if observers && rest == "copies" {
        return Ok(Found::Copies(pieces));
    }
    if observers && rest == "copies[]" {
        let mut places = Vec::new();
        for (which, of) in pieces {
            for p in each(at[used], crate::watch::PARTS.len(), "copies")? {
                places.push(Place { piece: which, of: of.clone(), field: String::new(), copy: Some(p) });
            }
        }
        return Ok(Found::Fields(places));
    }
    if rest.contains('.') || rest.contains('[') || piece(game, pieces[0].0).get(&rest).is_none() {
        return Err(format!("there is no {} in {}", rest.replace("[]", "[..]"), pieces[0].1));
    }
    Ok(Found::Fields(pieces.into_iter().map(|(which, of)| Place { piece: which, of, field: rest.clone(), copy: None }).collect()))
}
fn get(game: &Game, place: &Place) -> Option<Val> {
    match (place.piece, place.copy) {
        (Piece::Observer(i), Some(p)) => Some(Val::Text(game.ring[i].copies[p].clone())),
        _ => piece(game, place.piece).get(&place.field),
    }
}
fn set(game: &mut Game, place: &Place, to: Val) -> Result<(), String> {
    match (place.piece, place.copy, to) {
        (Piece::Observer(i), Some(p), Val::Text(t)) => {
            game.ring[i].copies[p] = t;
            Ok(())
        }
        (_, Some(_), _) => Err("a copy holds a text, and that is fixed".into()),
        (which, None, to) => piece_mut(game, which).set(&place.field, to),
    }
}

/// What a path holds, written out: a field, a piece, a list, or a whole scope.
fn read(game: &Game, path: &str, shape: &str, at: &[Option<usize>]) -> Result<String, String> {
    let list = |items: Vec<String>| format!("[{}]", items.join(","));
    let whole = |which: &str| -> Result<String, String> {
        match find(game, which, &[])? {
            Found::Pieces(pieces, true) => Ok(list(pieces.iter().map(|(p, _)| piece(game, *p).written()).collect())),
            Found::Pieces(pieces, false) => Ok(piece(game, pieces[0].0).written()),
            _ => Err(format!("there is no {}", which)),
        }
    };
    match shape {
        "spider" => return Ok(format!("{{\"body\":{},\"old\":{},\"legs\":{},\"ring\":{}}}", whole("spider.body")?, whole("spider.old")?, whole("spider.legs")?, whole("spider.ring")?)),
        "world" => {
            return Ok(format!(
                "{{\"edge\":{},\"tally\":{},\"web\":{},\"shop\":{},\"moths\":{},\"ring\":{}}}",
                whole("world.edge")?, whole("world.tally")?, whole("world.web")?, whole("world.shop")?, whole("world.moths")?, whole("world.ring")?
            ))
        }
        _ => {}
    }
    let one_or_list = |items: Vec<String>, many: bool| if items.len() == 1 && !many { items[0].clone() } else { list(items) };
    let many = at.iter().any(|a| a.is_none());
    match find(game, shape, at).map_err(|why| if why.starts_with("there is no") && !why.contains(" in ") { format!("there is no {}", path.trim()) } else { why })? {
        Found::Pieces(pieces, whole_list) => Ok(one_or_list(pieces.iter().map(|(p, _)| piece(game, *p).written()).collect(), whole_list || many)),
        Found::Fields(places) => Ok(one_or_list(places.iter().map(|place| get(game, place).map(|v| v.written()).unwrap_or_default()).collect(), many)),
        Found::Copies(pieces) => Ok(one_or_list(
            pieces
                .iter()
                .map(|(p, _)| match p {
                    Piece::Observer(i) => list(game.ring[*i].copies.iter().map(|c| quote(c)).collect()),
                    _ => String::new(),
                })
                .collect(),
            many,
        )),
    }
}
