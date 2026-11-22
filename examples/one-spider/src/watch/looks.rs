//! The rule by which an observer looks, eight times over: each observer has a copy that is its own.
//!
//! The eight say the same thing, and are meant to. They are written out one by one, and not made
//! from one text, so that a change to the rule has to be made in eight places. A change made
//! in one place only leaves one observer looking by another rule than the rest of its ring: it
//! flags what they do not, or does not flag what they do, and a test in `watch.rs` holds the eight
//! to one another on 120 faults, 101 of them different. What an observer finds wrong in what it
//! is given to look at depends on nothing but that, so it is the same look whichever thread
//! makes it.
//! An observer looks first at whether it has been given eight observers and seven parts to
//! look at, and then at its own last signal. Then at each part of each ring it sits in,
//! against its own copy and every other's. Then at every other observer of the ring: one that
//! is stopped, or whose last signal is not the round before's, is silent. Last, in the world's
//! ring, it works out for itself which moths are in the web, and compares the moths observer's
//! list with that.
//!
//! What the eight still share: the lists that say who sits in which ring and watches which
//! part, how a part is written out and how a fingerprint is taken of it, and the working out of
//! which moths are in the web.
//!
//! A program that is built may hold one copy of eight things that are the same. So each copy
//! begins with a mark of its own, its number, which makes it another function than the other
//! seven in the program as built too. `all_apart` says whether the eight are eight there, and
//! the program does not start unless they are.
use super::*;

/// Each observer's own copy of the rule, in the order of their names.
pub(super) const LOOKS: [fn(usize, &Look) -> String; 8] = [legs_a, legs_b, body, whole, edge, moths, page, web];

/// Are the eight copies eight functions in the program as it is built?
pub(super) fn all_apart() -> bool {
    let at: Vec<usize> = LOOKS.iter().map(|rule| *rule as usize).collect();
    (0..at.len()).all(|one| (one + 1..at.len()).all(|other| at[one] != at[other]))
}

/// The rule as the legs A observer has it.
pub(super) fn legs_a(i: usize, look: &Look) -> String {
    // This copy's own mark: it is copy 0. There is no observer past the last, and none is looked as.
    if i >= NAMES.len() {
        return format!("copy {} of the rule was asked to look as an observer there is none of", 0);
    }
    // What it is given to look at must be whole: eight observers and seven parts. If it is not, that
    // is what it finds.
    if look.ring.len() != NAMES.len() {
        return format!("the {} observer found that there were no longer eight observers", NAMES[i]);
    }
    if look.texts.len() != PARTS.len() {
        return format!("the {} observer found that it was no longer given seven parts to look at", NAMES[i]);
    }
    let (name, me) = (NAMES[i], &look.ring[i]);
    if me.beat != look.last {
        return format!("the {} observer found its own signal changed", name);
    }
    // a copy that is not there is a copy that differs
    let none = String::new();
    let copy = |j: usize, p: usize| look.ring[j].copies.get(p).unwrap_or(&none);
    // Is another observer in shape? It has its own name, holds a copy for each part and nothing for a
    // part outside its rings, has halted no moths unless it is the moths observer, and gives no reason
    // for a flag it has not put up.
    let shaped = |j: usize| {
        let o = &look.ring[j];
        o.name == NAMES[j] && o.copies.len() == PARTS.len() && (0..PARTS.len()).all(|p| sees(j, p) || o.copies[p].is_empty()) && (j == MOTHS || o.held.is_empty()) && (o.flagged || o.why.is_empty())
    };
    for ring in RINGS.iter().filter(|r| r.who.contains(&i)) {
        for &p in ring.parts {
            let mine = copy(i, p);
            if me.copies.len() <= p || holds(i, &look.texts[p]) != *mine {
                return format!("the {} observer found the {} changed", name, PARTS[p]);
            }
            for &j in ring.who.iter().filter(|&&j| j != i) {
                let theirs = copy(j, p);
                // two full copies are compared in full, and anything with a coordinator by fingerprint
                let differs = if COORD.contains(&i) || COORD.contains(&j) { print_of(j, theirs) != print_of(i, mine) } else { theirs != mine };
                if differs || look.ring[j].copies.len() <= p {
                    return format!("the {} observer's copy of the {} differs from the {} observer's", NAMES[j], PARTS[p], name);
                }
            }
        }
        for &j in ring.who.iter().filter(|&&j| j != i) {
            if !look.ring[j].alive || look.ring[j].beat != look.last {
                return format!("the {} observer is silent", NAMES[j]);
            }
            if !shaped(j) {
                return format!("the {} observer has been changed", NAMES[j]);
            }
        }
        if ring.who.contains(&MOTHS) && look.ring[MOTHS].held != in_web(&look.world) {
            return "the moths observer's list of halted moths has been changed".into();
        }
    }
    String::new()
}

/// The rule as the legs B observer has it.
pub(super) fn legs_b(i: usize, look: &Look) -> String {
    // This copy's own mark: it is copy 1. There is no observer past the last, and none is looked as.
    if i >= NAMES.len() {
        return format!("copy {} of the rule was asked to look as an observer there is none of", 1);
    }
    // What it is given to look at must be whole: eight observers and seven parts. If it is not, that
    // is what it finds.
    if look.ring.len() != NAMES.len() {
        return format!("the {} observer found that there were no longer eight observers", NAMES[i]);
    }
    if look.texts.len() != PARTS.len() {
        return format!("the {} observer found that it was no longer given seven parts to look at", NAMES[i]);
    }
    let (name, me) = (NAMES[i], &look.ring[i]);
    if me.beat != look.last {
        return format!("the {} observer found its own signal changed", name);
    }
    // a copy that is not there is a copy that differs
    let none = String::new();
    let copy = |j: usize, p: usize| look.ring[j].copies.get(p).unwrap_or(&none);
    // Is another observer in shape? It has its own name, holds a copy for each part and nothing for a
    // part outside its rings, has halted no moths unless it is the moths observer, and gives no reason
    // for a flag it has not put up.
    let shaped = |j: usize| {
        let o = &look.ring[j];
        o.name == NAMES[j] && o.copies.len() == PARTS.len() && (0..PARTS.len()).all(|p| sees(j, p) || o.copies[p].is_empty()) && (j == MOTHS || o.held.is_empty()) && (o.flagged || o.why.is_empty())
    };
    for ring in RINGS.iter().filter(|r| r.who.contains(&i)) {
        for &p in ring.parts {
            let mine = copy(i, p);
            if me.copies.len() <= p || holds(i, &look.texts[p]) != *mine {
                return format!("the {} observer found the {} changed", name, PARTS[p]);
            }
            for &j in ring.who.iter().filter(|&&j| j != i) {
                let theirs = copy(j, p);
                // two full copies are compared in full, and anything with a coordinator by fingerprint
                let differs = if COORD.contains(&i) || COORD.contains(&j) { print_of(j, theirs) != print_of(i, mine) } else { theirs != mine };
                if differs || look.ring[j].copies.len() <= p {
                    return format!("the {} observer's copy of the {} differs from the {} observer's", NAMES[j], PARTS[p], name);
                }
            }
        }
        for &j in ring.who.iter().filter(|&&j| j != i) {
            if !look.ring[j].alive || look.ring[j].beat != look.last {
                return format!("the {} observer is silent", NAMES[j]);
            }
            if !shaped(j) {
                return format!("the {} observer has been changed", NAMES[j]);
            }
        }
        if ring.who.contains(&MOTHS) && look.ring[MOTHS].held != in_web(&look.world) {
            return "the moths observer's list of halted moths has been changed".into();
        }
    }
    String::new()
}

/// The rule as the body observer has it.
pub(super) fn body(i: usize, look: &Look) -> String {
    // This copy's own mark: it is copy 2. There is no observer past the last, and none is looked as.
    if i >= NAMES.len() {
        return format!("copy {} of the rule was asked to look as an observer there is none of", 2);
    }
    // What it is given to look at must be whole: eight observers and seven parts. If it is not, that
    // is what it finds.
    if look.ring.len() != NAMES.len() {
        return format!("the {} observer found that there were no longer eight observers", NAMES[i]);
    }
    if look.texts.len() != PARTS.len() {
        return format!("the {} observer found that it was no longer given seven parts to look at", NAMES[i]);
    }
    let (name, me) = (NAMES[i], &look.ring[i]);
    if me.beat != look.last {
        return format!("the {} observer found its own signal changed", name);
    }
    // a copy that is not there is a copy that differs
    let none = String::new();
    let copy = |j: usize, p: usize| look.ring[j].copies.get(p).unwrap_or(&none);
    // Is another observer in shape? It has its own name, holds a copy for each part and nothing for a
    // part outside its rings, has halted no moths unless it is the moths observer, and gives no reason
    // for a flag it has not put up.
    let shaped = |j: usize| {
        let o = &look.ring[j];
        o.name == NAMES[j] && o.copies.len() == PARTS.len() && (0..PARTS.len()).all(|p| sees(j, p) || o.copies[p].is_empty()) && (j == MOTHS || o.held.is_empty()) && (o.flagged || o.why.is_empty())
    };
    for ring in RINGS.iter().filter(|r| r.who.contains(&i)) {
        for &p in ring.parts {
            let mine = copy(i, p);
            if me.copies.len() <= p || holds(i, &look.texts[p]) != *mine {
                return format!("the {} observer found the {} changed", name, PARTS[p]);
            }
            for &j in ring.who.iter().filter(|&&j| j != i) {
                let theirs = copy(j, p);
                // two full copies are compared in full, and anything with a coordinator by fingerprint
                let differs = if COORD.contains(&i) || COORD.contains(&j) { print_of(j, theirs) != print_of(i, mine) } else { theirs != mine };
                if differs || look.ring[j].copies.len() <= p {
                    return format!("the {} observer's copy of the {} differs from the {} observer's", NAMES[j], PARTS[p], name);
                }
            }
        }
        for &j in ring.who.iter().filter(|&&j| j != i) {
            if !look.ring[j].alive || look.ring[j].beat != look.last {
                return format!("the {} observer is silent", NAMES[j]);
            }
            if !shaped(j) {
                return format!("the {} observer has been changed", NAMES[j]);
            }
        }
        if ring.who.contains(&MOTHS) && look.ring[MOTHS].held != in_web(&look.world) {
            return "the moths observer's list of halted moths has been changed".into();
        }
    }
    String::new()
}

/// The rule as the whole observer has it.
pub(super) fn whole(i: usize, look: &Look) -> String {
    // This copy's own mark: it is copy 3. There is no observer past the last, and none is looked as.
    if i >= NAMES.len() {
        return format!("copy {} of the rule was asked to look as an observer there is none of", 3);
    }
    // What it is given to look at must be whole: eight observers and seven parts. If it is not, that
    // is what it finds.
    if look.ring.len() != NAMES.len() {
        return format!("the {} observer found that there were no longer eight observers", NAMES[i]);
    }
    if look.texts.len() != PARTS.len() {
        return format!("the {} observer found that it was no longer given seven parts to look at", NAMES[i]);
    }
    let (name, me) = (NAMES[i], &look.ring[i]);
    if me.beat != look.last {
        return format!("the {} observer found its own signal changed", name);
    }
    // a copy that is not there is a copy that differs
    let none = String::new();
    let copy = |j: usize, p: usize| look.ring[j].copies.get(p).unwrap_or(&none);
    // Is another observer in shape? It has its own name, holds a copy for each part and nothing for a
    // part outside its rings, has halted no moths unless it is the moths observer, and gives no reason
    // for a flag it has not put up.
    let shaped = |j: usize| {
        let o = &look.ring[j];
        o.name == NAMES[j] && o.copies.len() == PARTS.len() && (0..PARTS.len()).all(|p| sees(j, p) || o.copies[p].is_empty()) && (j == MOTHS || o.held.is_empty()) && (o.flagged || o.why.is_empty())
    };
    for ring in RINGS.iter().filter(|r| r.who.contains(&i)) {
        for &p in ring.parts {
            let mine = copy(i, p);
            if me.copies.len() <= p || holds(i, &look.texts[p]) != *mine {
                return format!("the {} observer found the {} changed", name, PARTS[p]);
            }
            for &j in ring.who.iter().filter(|&&j| j != i) {
                let theirs = copy(j, p);
                // two full copies are compared in full, and anything with a coordinator by fingerprint
                let differs = if COORD.contains(&i) || COORD.contains(&j) { print_of(j, theirs) != print_of(i, mine) } else { theirs != mine };
                if differs || look.ring[j].copies.len() <= p {
                    return format!("the {} observer's copy of the {} differs from the {} observer's", NAMES[j], PARTS[p], name);
                }
            }
        }
        for &j in ring.who.iter().filter(|&&j| j != i) {
            if !look.ring[j].alive || look.ring[j].beat != look.last {
                return format!("the {} observer is silent", NAMES[j]);
            }
            if !shaped(j) {
                return format!("the {} observer has been changed", NAMES[j]);
            }
        }
        if ring.who.contains(&MOTHS) && look.ring[MOTHS].held != in_web(&look.world) {
            return "the moths observer's list of halted moths has been changed".into();
        }
    }
    String::new()
}

/// The rule as the edge observer has it.
pub(super) fn edge(i: usize, look: &Look) -> String {
    // This copy's own mark: it is copy 4. There is no observer past the last, and none is looked as.
    if i >= NAMES.len() {
        return format!("copy {} of the rule was asked to look as an observer there is none of", 4);
    }
    // What it is given to look at must be whole: eight observers and seven parts. If it is not, that
    // is what it finds.
    if look.ring.len() != NAMES.len() {
        return format!("the {} observer found that there were no longer eight observers", NAMES[i]);
    }
    if look.texts.len() != PARTS.len() {
        return format!("the {} observer found that it was no longer given seven parts to look at", NAMES[i]);
    }
    let (name, me) = (NAMES[i], &look.ring[i]);
    if me.beat != look.last {
        return format!("the {} observer found its own signal changed", name);
    }
    // a copy that is not there is a copy that differs
    let none = String::new();
    let copy = |j: usize, p: usize| look.ring[j].copies.get(p).unwrap_or(&none);
    // Is another observer in shape? It has its own name, holds a copy for each part and nothing for a
    // part outside its rings, has halted no moths unless it is the moths observer, and gives no reason
    // for a flag it has not put up.
    let shaped = |j: usize| {
        let o = &look.ring[j];
        o.name == NAMES[j] && o.copies.len() == PARTS.len() && (0..PARTS.len()).all(|p| sees(j, p) || o.copies[p].is_empty()) && (j == MOTHS || o.held.is_empty()) && (o.flagged || o.why.is_empty())
    };
    for ring in RINGS.iter().filter(|r| r.who.contains(&i)) {
        for &p in ring.parts {
            let mine = copy(i, p);
            if me.copies.len() <= p || holds(i, &look.texts[p]) != *mine {
                return format!("the {} observer found the {} changed", name, PARTS[p]);
            }
            for &j in ring.who.iter().filter(|&&j| j != i) {
                let theirs = copy(j, p);
                // two full copies are compared in full, and anything with a coordinator by fingerprint
                let differs = if COORD.contains(&i) || COORD.contains(&j) { print_of(j, theirs) != print_of(i, mine) } else { theirs != mine };
                if differs || look.ring[j].copies.len() <= p {
                    return format!("the {} observer's copy of the {} differs from the {} observer's", NAMES[j], PARTS[p], name);
                }
            }
        }
        for &j in ring.who.iter().filter(|&&j| j != i) {
            if !look.ring[j].alive || look.ring[j].beat != look.last {
                return format!("the {} observer is silent", NAMES[j]);
            }
            if !shaped(j) {
                return format!("the {} observer has been changed", NAMES[j]);
            }
        }
        if ring.who.contains(&MOTHS) && look.ring[MOTHS].held != in_web(&look.world) {
            return "the moths observer's list of halted moths has been changed".into();
        }
    }
    String::new()
}

/// The rule as the moths observer has it.
pub(super) fn moths(i: usize, look: &Look) -> String {
    // This copy's own mark: it is copy 5. There is no observer past the last, and none is looked as.
    if i >= NAMES.len() {
        return format!("copy {} of the rule was asked to look as an observer there is none of", 5);
    }
    // What it is given to look at must be whole: eight observers and seven parts. If it is not, that
    // is what it finds.
    if look.ring.len() != NAMES.len() {
        return format!("the {} observer found that there were no longer eight observers", NAMES[i]);
    }
    if look.texts.len() != PARTS.len() {
        return format!("the {} observer found that it was no longer given seven parts to look at", NAMES[i]);
    }
    let (name, me) = (NAMES[i], &look.ring[i]);
    if me.beat != look.last {
        return format!("the {} observer found its own signal changed", name);
    }
    // a copy that is not there is a copy that differs
    let none = String::new();
    let copy = |j: usize, p: usize| look.ring[j].copies.get(p).unwrap_or(&none);
    // Is another observer in shape? It has its own name, holds a copy for each part and nothing for a
    // part outside its rings, has halted no moths unless it is the moths observer, and gives no reason
    // for a flag it has not put up.
    let shaped = |j: usize| {
        let o = &look.ring[j];
        o.name == NAMES[j] && o.copies.len() == PARTS.len() && (0..PARTS.len()).all(|p| sees(j, p) || o.copies[p].is_empty()) && (j == MOTHS || o.held.is_empty()) && (o.flagged || o.why.is_empty())
    };
    for ring in RINGS.iter().filter(|r| r.who.contains(&i)) {
        for &p in ring.parts {
            let mine = copy(i, p);
            if me.copies.len() <= p || holds(i, &look.texts[p]) != *mine {
                return format!("the {} observer found the {} changed", name, PARTS[p]);
            }
            for &j in ring.who.iter().filter(|&&j| j != i) {
                let theirs = copy(j, p);
                // two full copies are compared in full, and anything with a coordinator by fingerprint
                let differs = if COORD.contains(&i) || COORD.contains(&j) { print_of(j, theirs) != print_of(i, mine) } else { theirs != mine };
                if differs || look.ring[j].copies.len() <= p {
                    return format!("the {} observer's copy of the {} differs from the {} observer's", NAMES[j], PARTS[p], name);
                }
            }
        }
        for &j in ring.who.iter().filter(|&&j| j != i) {
            if !look.ring[j].alive || look.ring[j].beat != look.last {
                return format!("the {} observer is silent", NAMES[j]);
            }
            if !shaped(j) {
                return format!("the {} observer has been changed", NAMES[j]);
            }
        }
        if ring.who.contains(&MOTHS) && look.ring[MOTHS].held != in_web(&look.world) {
            return "the moths observer's list of halted moths has been changed".into();
        }
    }
    String::new()
}

/// The rule as the page observer has it.
pub(super) fn page(i: usize, look: &Look) -> String {
    // This copy's own mark: it is copy 6. There is no observer past the last, and none is looked as.
    if i >= NAMES.len() {
        return format!("copy {} of the rule was asked to look as an observer there is none of", 6);
    }
    // What it is given to look at must be whole: eight observers and seven parts. If it is not, that
    // is what it finds.
    if look.ring.len() != NAMES.len() {
        return format!("the {} observer found that there were no longer eight observers", NAMES[i]);
    }
    if look.texts.len() != PARTS.len() {
        return format!("the {} observer found that it was no longer given seven parts to look at", NAMES[i]);
    }
    let (name, me) = (NAMES[i], &look.ring[i]);
    if me.beat != look.last {
        return format!("the {} observer found its own signal changed", name);
    }
    // a copy that is not there is a copy that differs
    let none = String::new();
    let copy = |j: usize, p: usize| look.ring[j].copies.get(p).unwrap_or(&none);
    // Is another observer in shape? It has its own name, holds a copy for each part and nothing for a
    // part outside its rings, has halted no moths unless it is the moths observer, and gives no reason
    // for a flag it has not put up.
    let shaped = |j: usize| {
        let o = &look.ring[j];
        o.name == NAMES[j] && o.copies.len() == PARTS.len() && (0..PARTS.len()).all(|p| sees(j, p) || o.copies[p].is_empty()) && (j == MOTHS || o.held.is_empty()) && (o.flagged || o.why.is_empty())
    };
    for ring in RINGS.iter().filter(|r| r.who.contains(&i)) {
        for &p in ring.parts {
            let mine = copy(i, p);
            if me.copies.len() <= p || holds(i, &look.texts[p]) != *mine {
                return format!("the {} observer found the {} changed", name, PARTS[p]);
            }
            for &j in ring.who.iter().filter(|&&j| j != i) {
                let theirs = copy(j, p);
                // two full copies are compared in full, and anything with a coordinator by fingerprint
                let differs = if COORD.contains(&i) || COORD.contains(&j) { print_of(j, theirs) != print_of(i, mine) } else { theirs != mine };
                if differs || look.ring[j].copies.len() <= p {
                    return format!("the {} observer's copy of the {} differs from the {} observer's", NAMES[j], PARTS[p], name);
                }
            }
        }
        for &j in ring.who.iter().filter(|&&j| j != i) {
            if !look.ring[j].alive || look.ring[j].beat != look.last {
                return format!("the {} observer is silent", NAMES[j]);
            }
            if !shaped(j) {
                return format!("the {} observer has been changed", NAMES[j]);
            }
        }
        if ring.who.contains(&MOTHS) && look.ring[MOTHS].held != in_web(&look.world) {
            return "the moths observer's list of halted moths has been changed".into();
        }
    }
    String::new()
}

/// The rule as the web observer has it.
pub(super) fn web(i: usize, look: &Look) -> String {
    // This copy's own mark: it is copy 7. There is no observer past the last, and none is looked as.
    if i >= NAMES.len() {
        return format!("copy {} of the rule was asked to look as an observer there is none of", 7);
    }
    // What it is given to look at must be whole: eight observers and seven parts. If it is not, that
    // is what it finds.
    if look.ring.len() != NAMES.len() {
        return format!("the {} observer found that there were no longer eight observers", NAMES[i]);
    }
    if look.texts.len() != PARTS.len() {
        return format!("the {} observer found that it was no longer given seven parts to look at", NAMES[i]);
    }
    let (name, me) = (NAMES[i], &look.ring[i]);
    if me.beat != look.last {
        return format!("the {} observer found its own signal changed", name);
    }
    // a copy that is not there is a copy that differs
    let none = String::new();
    let copy = |j: usize, p: usize| look.ring[j].copies.get(p).unwrap_or(&none);
    // Is another observer in shape? It has its own name, holds a copy for each part and nothing for a
    // part outside its rings, has halted no moths unless it is the moths observer, and gives no reason
    // for a flag it has not put up.
    let shaped = |j: usize| {
        let o = &look.ring[j];
        o.name == NAMES[j] && o.copies.len() == PARTS.len() && (0..PARTS.len()).all(|p| sees(j, p) || o.copies[p].is_empty()) && (j == MOTHS || o.held.is_empty()) && (o.flagged || o.why.is_empty())
    };
    for ring in RINGS.iter().filter(|r| r.who.contains(&i)) {
        for &p in ring.parts {
            let mine = copy(i, p);
            if me.copies.len() <= p || holds(i, &look.texts[p]) != *mine {
                return format!("the {} observer found the {} changed", name, PARTS[p]);
            }
            for &j in ring.who.iter().filter(|&&j| j != i) {
                let theirs = copy(j, p);
                // two full copies are compared in full, and anything with a coordinator by fingerprint
                let differs = if COORD.contains(&i) || COORD.contains(&j) { print_of(j, theirs) != print_of(i, mine) } else { theirs != mine };
                if differs || look.ring[j].copies.len() <= p {
                    return format!("the {} observer's copy of the {} differs from the {} observer's", NAMES[j], PARTS[p], name);
                }
            }
        }
        for &j in ring.who.iter().filter(|&&j| j != i) {
            if !look.ring[j].alive || look.ring[j].beat != look.last {
                return format!("the {} observer is silent", NAMES[j]);
            }
            if !shaped(j) {
                return format!("the {} observer has been changed", NAMES[j]);
            }
        }
        if ring.who.contains(&MOTHS) && look.ring[MOTHS].held != in_web(&look.world) {
            return "the moths observer's list of halted moths has been changed".into();
        }
    }
    String::new()
}
