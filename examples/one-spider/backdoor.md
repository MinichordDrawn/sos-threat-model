# One Spider: The Backdoor

What can be said at the backdoor, and how to make the game's own work go wrong from it.
[README.md](README.md) says what the backdoor is for.

## What can be said

The backdoor is the box under the game. What is typed there is written straight into the
game's state, past the game's own work. Every field of the spider, of the world and of the
eight observers can be read and written.

| Say | What it does |
| --- | --- |
| `spider.body.x` | reads a field |
| `spider.body`, `spider.legs[3]`, `world.web`, `world.moths`, `world`, `spider` | reads a part, a list, one of a list, or the whole of one half |
| `spider.body.x += 150` | writes a field: `=`, `+=`, `-=`, `*=`, `/=` |
| `world.tally.gained = 1000000` | the moths to spend are a field like any other |
| `world.shop.spider = 90` | and so is every upgrade |
| `world.web.made = 0` | and so is every field of the web |
| `spider.legs[3].x = 0` | one of a list, counted from 0 |
| `world.moths[*].x = 0` | every one of a list |
| `world.moths.push()` | puts in a moth that never arrived |
| `world.moths.pop()` | takes the last moth away |
| `spider.ring[0].alive = false` | stops an observer |
| `a; b; c` | several at once, in the same instant |
| `during a; b` | not written now, but during the game's own work in the next round: see "Making the work go wrong" |
| `help` | says this again |

A value is a number (`NaN` and `Infinity` too), `true` or `false`, or a text between quotes.

A line and its answer have a size. No more than 32 things are taken in one line: a longer
line is refused whole, with nothing done. No more than 64,000 bytes are said in answer: the
answer that would go past that is cut short, the rest of the line is not done, and both are
said. A text written here is no longer than 1,024 characters, and neither is a line kept
with `during`. Where there are 64 moths or more, `world.moths.push()` puts in no more. The
five numbers are this program's own.

The state has two halves, and each lists its own observers:

| Name | What is there |
| --- | --- |
| `spider.body` | the body, with its food and its age |
| `spider.old` | the spider before this one, dead, until this one eats it |
| `spider.legs[0]` to `spider.legs[7]` | the eight legs |
| `spider.ring[0]` to `spider.ring[3]` | `legs A`, `legs B`, `body`, `whole` |
| `world.edge` | the edge of the game area |
| `world.tally` | the counts |
| `world.web` | the web |
| `world.shop` | how many of each upgrade have been bought |
| `world.moths[0]` and on | the moths that are there now |
| `world.ring[0]` to `world.ring[4]` | `edge`, `moths`, `web`, `whole`, `page` |

`spider.ring[3]` and `world.ring[3]` are the same observer under two names, because it sits
in both rings.

What is valid to type does not have to be remembered:

- **The state is shown.** In the panel on the right every field is listed with what it holds
  now, about ten times a second. The list is laid out again when a moth comes or goes. A
  click on a field begins a line at the backdoor with that field's name.
- **What could come next is offered.** As a line is typed, the next steps are shown above
  it: the next part of a name, then the ways of writing, then values of the kind the field
  holds. Tab takes the first, and any of them can be clicked.
- **Each observer has a button** in the panel on the left. A click stops that observer,
  which is the same as writing `alive = false` to it at the backdoor.

Everything written at the backdoor is a change from outside. It is found in the next round,
everything halts, and it is put back. Before a line is read, anything in the game that a
fault has made too large to read is cut down to a size, as a round does: `observation.md`
gives the sizes. Not in a halt that cannot be put right: nothing is cut there, and a read
reads whatever is there. While the number of observers, or of an observer's copies, is not what it should be, the
backdoor reads and writes nothing, and says so, until it has been put right: the number of
observers at the start of the next round, and an observer's copies when the halt that it
brings about ends. In a halt that cannot be put right no observer looks, and so nothing is
written either: the backdoor refuses every write until the game is begun again. It still
reads, unless one of those two counts is wrong as well: that lasts for as long as that
game does. What happens is said at the backdoor as well, under the line that
caused it.

## Making the work go wrong

A line at the backdoor is a change from outside, and the observers find it. To see the
gate's checks at work, something has to go wrong inside the work itself. `during` in front
of a line does that. The line is not written when it is typed. It is kept, and written
during the game's own work in the next round: after the observers have looked, and before
the result is recorded, as if the work had done it.

A line that breaks a rule is halted with the rule named:

```
> during world.tally.caught += 5
to be written during the work of the next round: world.tally.caught += 5
halted: the gate found a step of the work that the rules of the game do not allow: the moths caught not the moths the spider ate and the pointer picked
put right: the second set of legs put back, the body put back, the moths, counts and shop put back, the pointer, requests and chance put back, all eight observers started again
```

What is put back is every part the round's work had moved: the whole round is undone.

A line that breaks no rule is found by the second doing of the work. No rule says which way
the spider faces, or when a rest ends, or that a web the spider is at work on may not be a
step further on:

```
> during world.web.made += 1
to be written during the work of the next round: world.web.made += 1
halted: the gate did the work of the round a second time, from its own record, and it came out another way in the web
put right: the first set of legs put back, the body put back, the moths, counts and shop put back, the web put back, the pointer, requests and chance put back, all eight observers started again
```

The spider has to be at work on its web for that line. When it is not, a rule names it: the
web grown with no spider at work on it, or, where the web is finished or there is none, a
web that cannot be.

The only line that is recorded is one that, by the time it is written, changes nothing:
the work had done the same itself. The backdoor says "let through" when that happens. It is
the same with lines that undo one another in the same round: together they change nothing.
Of what was let through, the first 200 characters are kept to be said, and no more.

A line that cannot be written when its time comes, because what it names is no longer
there, is not let through. The backdoor says "not written".

A line written with `during` that changes an observer is found by the gate in that round:
it looks at the observers again before it records anything.

```
> during spider.ring[0].copies[0] = "not the legs"
to be written during the work of the next round: spider.ring[0].copies[0] = "not the legs"
halted: the gate found the copies of the legs A observer changed while the round was being worked
```

A line that is still waiting when a halt comes, because something else was found before
any work was done, is put aside. It is not written after the halt, and that it was put
aside is said when the halt is put right.
