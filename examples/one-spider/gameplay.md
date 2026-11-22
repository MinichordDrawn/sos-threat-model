# One Spider: The Game

What there is to play. How the game is watched is in [README.md](README.md) and
[observation.md](observation.md).

The page has four panels: what the game says on the left, the game in the middle with the
backdoor under it, and the state on the right.

## Moths and food

A moth comes in from an edge about 14 times a minute, while fewer than 4 are on the wing
and fewer than 10 are there in all. Moths wander, and keep away from the pointer. The
spider's food runs from full to empty in 30 seconds. When a third of it is left the spider
is hungry, and it goes after the nearest moth until it is full again. When it is full it
catches nothing.

## The web

While it is full the spider makes a web, in the order an orb weaver does: a bridge line, a
stem through the hub, the frame, the spokes, a wide spiral outward to walk on, and then a
close spiral inward that takes the wide one away as it passes. A step is made when the
spider reaches the end of it with the thread in hand. Coming back from a hunt, it first
walks to where it left off and takes the thread up again.

A moth that touches the close spiral is halted there. The spider can eat it, or a click on
it takes it. A moth taken by a click counts as caught, feeds nobody, and breaks the strand
it was on.

A finished web stands for 90 seconds. With its web finished the spider has nothing to wait
for, and eats as soon as it has room for a moth. Then the web is old: the spider takes it
down from the hub and begins another where it stands. There are seven sizes, and each new
web is one size larger than the last, up to the largest.

## The shop

A moth caught is worth one moth to spend, and more with the multipliers below. The large
number at the top of the left panel is what there is to spend, with the tenths. The shop
has four upgrades, each bought with moths, and each one dearer than the last:

| Upgrade | What one more does | First price | Each one dearer by | The most there is |
| --- | --- | --- | --- | --- |
| More moths | one more moth a minute, and room for one more on the wing and two more in all | 10 | 15% | 19: 33 moths a minute, 23 on the wing and 48 in all |
| Spider appetite | one more moth to fill the spider, at every age, so that it eats more of them | 12 | 15% | 24: 26 moths to fill a new spider, 32 a full-grown one |
| Spider multiplier | a tenth more for every moth the spider catches | 12 | 7% | no most |
| Web multiplier | a tenth more for every moth caught in the web | 10 | 7% | no most |

An upgrade that is at its most says "no more" where its price was, and cannot be bought.

A moth the spider catches is worth one moth times the spider's multiplier. A moth picked
out of the web by a click is worth one times the web's. A moth the spider eats in its web
is worth one times both. A click on a button only asks for the upgrade: the world, in its
own work, sells it if there are moths enough.

## One spider after another

A spider starts at half size and is full grown after two and a half minutes. Two moths
fill a new spider and eight a full-grown one, and its food runs down at the same rate
whatever its size, so a bigger spider eats more moths. It dies of old age at five minutes,
or sooner if its food runs out.

The game is still one spider. In the round a spider dies, the next one is there: a new
spider just outside the edge, on a side picked by chance, with its nearest feet at the edge,
already walking in. There is never a round without a living spider.

The new spider walks to the old one and eats it. That is a full meal, and it makes the new
spider quicker and its food last longer: by a hundredth for each moth the old one had eaten,
a tenth at most each time, and by 111% in all. Until it has eaten the old one it catches no
moths. The panel always says "spider no. 1", and counts the dead ones beside it.

## Picking the spider up

The pointer is also a hand. The page sends where it was pressed and that it was let up, and
the game decides what that means, in the next round's work. A press on the spider's body or
on one of its feet may take hold of it, once the pointer has moved four units from where it
pressed. A press anywhere else is a click, which takes a moth if one is halted there. The
ring that is drawn under the pointer, and the pointer's look, are what the game says a
press there would do.

Held by its body, the spider is carried, and all eight legs flail. Held by a foot, it is
dragged along by that leg, and the other seven flail. It cannot be taken over the edge.
While it is held it panics: it catches nothing, lets go of its web's thread, and its food
runs down in 5 seconds where it would last 30. So holding it for long kills it. If it dies
in the hand, the next spider walks in as after any other death, and the pointer has hold of
nothing. Let go, the spider puts its feet down and takes 0.7 seconds to get over it.

Being picked up is the spider's own work: it is not a change from outside, and there is no
halt. `spider.body.grip` says what the pointer has hold of, a leg by its number, 8 for the
body, or -1 for nothing. Writing that field at the backdoor picks nothing up: it is caught
like any other write.

## Reduced motion

The game has no setting for this. The page follows the viewer's own system: where the
system or the browser is set to reduce motion, the moths' wings and the alarm's pulse are
stilled. The page reads that setting once, when it loads. Hunger and ageing go on, because
the game does not run in the viewer's browser.

## The numbers

The numbers of the game are its own, chosen to make it play well and nothing more. Those the
rules hold the work to are stated in the work and again in the rules, and each of those is
written twice: in `src/game.rs` and `src/game/again.rs`, and in `src/rules.rs` and
`src/rules/again.rs`, but for the inset of the edge, which no round's work uses and the
second text of the work leaves out (see "Checking the work" in [observation.md](observation.md)). One of
those that a rule holds exactly, changed in fewer than all the places it is in, halts the
game. A
number no rule uses is in the two texts of the work, and has to be changed in both.

In one run of half an hour with nothing written from outside, with someone buying the
cheapest upgrade each time, seven spiders caught 459 moths between them, worth 1,289, and 57
upgrades were bought.
