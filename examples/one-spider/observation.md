# One Spider: How It Is Watched

The whole of what is observed in the game, and how. [README.md](README.md) has the summary.

## What is observed

The state has seven parts. Six are open to the backdoor. The seventh is what the game keeps
for itself, and the backdoor does not reach it.

| Part | What is in it |
| --- | --- |
| first set of legs | legs 0, 2, 5, 7: `side`, `pair`, `set`, `up`, `x`, `y`, `t`, `dur`, `fx`, `fy` |
| second set of legs | legs 1, 3, 4, 6: the same fields |
| body | the living spider's: `x`, `y`, `h`, `v`, `size`, `tx`, `ty`, `exact`, `state`, `until`, `phase`, `moved`, `turned`, `food`, `full`, `eaten`, `meals`, `gen`, `age`, `boost`, `husks`, `grip`. The old spider's: `on`, `x`, `y`, `h`, `size`, `meals` |
| edge | `inset`, `w`, `h` |
| moths, counts and shop | the tally: `caught`, `picked`, `webs`, `spent`, `gained`, `webbed`. The shop: `spawn`, `appetite`, `spider`, `web`. For every moth: `id`, `x`, `y`, `h`, `wx`, `wy`, `until` |
| web | `on`, `x`, `y`, `made`, `tied`, `age`, `old`, `torn`, `level` |
| pointer, requests and chance | not open to the backdoor. Where the pointer is and what it has hold of; the clicks and the upgrades taken in and not yet acted on; chance; when the next moth is due and the number the last one was given; and the catches of the last minute, for a screen to show |

Eight observers watch them, in two rings that share one member.

| Ring | Observers | Parts |
| --- | --- | --- |
| the spider's | `legs A`, `legs B`, `body`, and its coordinator `whole` | the two sets of legs and the body |
| the world's | `edge`, `moths`, `web`, `whole` again, and its coordinator `page` | the edge, the moths with the counts and the shop, the web, and the pointer, requests and chance |

Each observer but the coordinators is named for one part. The shop has no observer named
for it: it is in the part the `moths` observer is named for, with the counts. The seventh
part has none named for it either. Every observer of the world's ring checks both all the
same.

Nothing but the game's own work changes the seventh part. So an upgrade that nobody asked
for, a click that nobody made, the next moth brought forward or chance moved on is a change
like any other: the world's observers find it before the next round's work, and it is put
back.

The `body` observer's part holds both spiders: the living one's body, and the old one's for
as long as it lies there. In the living one's, `gen` is which spider this is, `age` how
long it has lived, and `husks` how many old spiders have been eaten.

So the next spider is watched from the round it is there, and there is nothing for anyone
to take on first. The dead one stays where it died, as `spider.old`, and the living one is
`spider.body` and `spider.legs`. The same four observers watch both. The new spider is made
by the spider's own work, in a round like any other: the observers looked before that work
began, the result was recorded when it ended, and they look again before anything else
moves.

Each observer runs on a thread of its own. Every round each running observer is sent what
there is to look at: the number of the round, the number its own last signal and every
other's should carry, the seven parts as they are, written out, the eight observers as they
are, and the world as it is. Each looks at that and at nothing else, and answers. An
observer that is stopped is not asked, and its thread is only told that a round has gone by.
The work waits for the answers: eight waits of five thousandths of a second with no answer
at the most, counted in waits and not by the clock. An answer is taken from an observer that
was asked in this round, once, and no more than the first 200 characters of what it found
are kept. Anything else that arrives is waited through, fewer times than
there are observers, so one asking waits at most 22 waits, 110 thousandths
of a second. A round in which a halt is put right asks twice, the second time of
the eight new observers. One that has not answered by then has not signalled: it is silent,
everything halts, and it is not asked again until it is replaced. In most of the tests the
observers are run together, in the thread that does the round, so that a test gives the same
result every time. Some run each on a thread of its own, and one runs both ways side by side
and requires the same state, round for round.

Each observer looks by a copy of the rule that is its own. The rule is written out eight
times in `src/watch/looks.rs`, one by one and not made from one text, so a change to it has
to be made in eight places. A change made in one place leaves one observer looking by
another rule than the rest of its ring, and a test holds the eight to one another on 120
faults, 101 of them different: every kind of thing that can go wrong in an observer, in each
of the eight. The eight still share the lists that say who sits in which
ring and watches which part, how a part is written out, how a fingerprint is taken, and the
working out of which moths are in the web. A program that is built may hold one copy of
eight things that are the same, so each copy begins with a mark of its own, its number,
which makes it another function than the other seven in the program as built too. The
program checks at its start that the eight are eight there, and does not start otherwise.

Inside a ring the observers are a full mesh. In every round, before anything moves, every
running observer checks that it has been given eight observers and seven parts to look at
and that its own last signal is the round before's, compares every part
of its ring with its own copy, compares its copy with the copies of the others in the ring,
and checks that the others signalled in the round before, are running and are in shape. The
two coordinators keep a fingerprint of each part where the others keep the whole part.

An observer is state too: `name`, `alive`, `beat`, `copies`, `held`, `flagged`, `why`, all
open to the backdoor.
`copies` has a place for each of the seven parts, and a place is empty for a part outside
the observer's rings. The seventh part can be read there, in the copy that `edge`, `moths`
or `web` holds of it: `world.ring[0].copies[6]`.

An observer is in shape when it has its own name, holds a place for each of the seven parts
and nothing for a part outside its rings, has halted no moths unless it is the `moths`
observer, and gives no reason for a flag it has not put up. A copy too many or too few, and
an observer too many or too few, are found like any other change, and eight new observers
put it right.

A screen is sent only the beginning of an observer's texts: the first 24 characters of each
copy, and the first 160 of its name, its list and its reason. The backdoor reads the whole
of each. Of anything else a screen is sent no more than 1,024: characters of a text in a
part, and legs, moths, observers, copies of one observer or catches in number. That is far
more than a game has of any of them, so only what a fault has made long or many is cut.

Two things are sent at more length: the `moths` observer's list, by which a screen knows
which moths are halted, up to its first 20,480 characters, which is room for the numbers of
as many moths as are sent, and what the game says of itself, the reason of a halt among
it, up to 4,096. A reason is the gate's own words, or the first 200 characters of what an
observer found, and comes to a few hundred characters at the most.

What the game holds is cut down to a size that can be looked at: every list to 1,024
entries, every text to 1,048,576 bytes, and a text inside a part to an eighth of that, so
that a part with such a text in it, written out, is still within it. A game never has that much of anything (48
moths is the most there can be), so what is cut is something a fault made, and what is left
of it still differs from what should be there: it is found and put right like any other
change. It is done at six points of a round: at its start, before the observers are
asked, before the work, before the gate checks the work, before the work is done a second
time, and before the record is written.
And it is done when a line arrives at the backdoor, which may read a whole list or copy the
game to try itself on. At the start of a round, what the gate keeps from the round before
is cut first, and the rest once the round is known not to be in a halt that cannot be put
right: in such a halt nothing else is cut, by a round or by a line at the backdoor. The
list of halted moths is read by the work for every moth and every click, so the work is
handed no more of it than its first 20,480 characters, whatever a fault has made of it. Of what the gate keeps in three places, only the state kept
from when the last round's work began is cut. A place of the rest that has grown differs
from the other two by its length alone, and is put right from them.

This bounds what a round costs wherever something too large is met at one of those points.
It has an edge. Something that grows in the few steps between a point and the next reading
of it is read whole. How much it takes depends on what it is made of and where
it lands. Two million copies of a moth landing there cost a round more than five seconds:
the observers took the rounds to have stopped, and the program ended. Thirty thousand
moths with numbers no moth has had, lying where a halted moth lies and with eight clicks
waiting, did the same in the costliest place found, the gate's
copy just before the work is done a second time, and that place now has a cut of its own. A text has to be far longer to do the same: one of
sixty-four million control characters cost a round four and a half seconds at the most,
and one of ninety-six million more than five. That is the system halting, as it does for any round that does not return: nothing
wrong is recorded, because nothing more is done. And it is outside what is held. A fault
is one stored value changed. A list two million entries longer is two million values, and
a text ninety-six million characters longer is ninety-six million.

`beat` is an observer's signal: the number of the round it last answered in. An observer's
answer is its signal: when the answer comes, the round writes down that it came, as the
number of the round. Once it has seen that it has been given eight observers and seven parts to look at, and
before it looks at anything else, an observer checks that its own last signal is the round before's. So a signal changed from outside is found by the observer
itself, though nothing of the change would have been left, and the others of its ring find
it too. One that does not answer has not signalled. The gate finds that in the same round,
and from the next round the others of its ring find that its last signal is no longer the
round before's.

The `moths` observer is also what halts a moth in the web. After each round's work it
writes in its `held` the numbers of the moths that are touching the web, and the world does
not move a moth that is on that list. The others of the world's ring work the list out for
themselves in every round and compare. No other observer has any moths in its `held`.

One flag reaches every observer of its ring in the same round, and through `whole`, which
sits in both, it reaches the other ring. Everything halts on a flag and on the silence of
any observer: the spider, the moths and the web stop together.

Behind the observers is the gate. The program keeps its own record, which the backdoor does
not reach: the state as the game's own work last left it, and so what every observer should
be holding. Nothing moves unless the observers have found nothing and everything matches
that record. So a change that every observer has been made to agree on in the same instant
is stopped there.

The record holds every part twice: written out, and as a copy. In every round, before it
looks at the state, the gate checks that the two halves say the same thing. What it has
written out has one text for each part: a text too many or too few is found there too.

Everything else that is the gate's own is kept in three places: whether everything is
halted and why, whether that halt has been asked to end, how halts are set to end, how many
wrong rounds there have been running, the counts of halts, restarts and games, what is
waiting to be written during the work, what was let through or could not be written, the number of the round, which every observer's signal is held to, how often the program has
stopped in the wrong place since a round that began with nothing halted was recorded, what the machine's clock said at
the last round, from which the length of the next is worked out, and the game's own
time, which each round moves on by its length. Everything in the game that waits for a time
waits for the game's own: when the next moth is due, how long the spider stays as it is,
how long a halt has been left alone. Whatever is read of these is read
from two places that agree, and whatever the gate writes is written to all three. So one
place that has been changed is never what is read, whenever it was changed. At the start of
every round, before anything else, the gate compares the three. Where one differs from the
other two, that is a detection like any other: everything halts, the place is put right from
the other two, and the halt ends as any halt does. A place that the gate's own next write
makes agree again before then is never found: it was never read, and nothing is left of it. The state kept from when a round's work
began is held in three places the same way, and so are the game's hold on its observers'
threads and what those threads are run by: which starting of the observers this is, how long the round waits, and how long an
observer hears nothing before it takes the rounds to have stopped.

When a round is recorded, both halves of the record are what the gate's second doing of
the work made (see "Checking the work"), and each observer takes its copies from the state
itself. So the record and the observers' copies come from the two doings of the work, one
each, and nothing of the record is read from the state.

When a halt ends, every part is put right:

- Where the two halves of the record agree, the record is what counts. A part of the state
  that differs from it is put back to it, whatever the observers hold. The backdoor reaches
  the state and the observers, and it does not reach the record.
- Where the two halves do not agree, one of them has gone wrong, and the state and the
  observers settle which. If the state and every observer of that part hold to one half,
  the other half is put right from the state. If the state has moved on, in a round that
  was not recorded, the state as it was when that round began stands in for it: the half
  that it and every observer hold to is the right one, and the state goes back to that.
- If that does not settle it, nothing can be: the halt is one that cannot be put right.

Then all eight observers are started again as new ones: `page` first, then `whole`, then the
rest. Where each is on a thread of its own, the eight threads are replaced by eight new
ones. An old one ends when it finds that nothing can call it any more, and one that is stuck
is left behind. The gate and every new observer look once more, each observer for itself,
and only if none of them finds anything is the halt over. If a new observer does not answer,
it has not looked: the halt is not ended, and everything is put right again with eight more.
That is in the next round, but for one case: where halts end after a pause, this one has
not been asked to end, and the first try put a part of the state back, the pause is waited
out again first. What was put back at the first try is still said when the halt ends.

The repair here is a simple one, chosen to keep the example small: everything halts, and all
eight observers are replaced together. A finer one is possible, and is not built here: the
broken member of a ring is identifiable, and the ring could act to repair it.

### What is asked of the game

What comes from outside is asked of the game: where the pointer is, a press, a letting go,
an upgrade at the shop. Each is taken down three times as it arrives, in three lists, and
nothing else is done with it then. No list can grow without end between two rounds: no more
than eight presses and eight upgrades wait for one round, and of the pointer's places that
follow one another only the last four are kept. A letting go is never left out, but for one
that follows another with no press between, which lets go of nothing more.

In the next round the gate compares the three lists before any work is done. The round's
work begins by taking in the first list. The gate's second doing of the work takes in the
second (see "Checking the work"). After a round that is recorded, all three are empty.
What was taken in is then in the seventh part, and watched with the rest.

The lists are compared to the last bit: a place at 0 in one and at -0 in another are equal
as numbers, and are not the same. If the three are not the same, everything halts. Where
one differs from the other two, putting right makes it what they are: the two that agree
are what was asked, and the round after the halt takes it in. A list changed where neither doing of the work reads it again, or
so that the round comes out the same, is emptied with the others when the round is recorded,
and nothing is left of it. The lists are emptied where the round is recorded, with nothing
between the two that could stop. Where no two agree, there is
nothing to say what was asked, and all three are put aside. A letting go may have been
among it, so the pointer is made to let go, and anything else that was asked has to be
asked again. That takes two faults.

While everything is halted, a press and an upgrade are not taken down. A letting go is, and
of the pointer's places that come during the halt only the last. What was asked of a round
that went wrong is still in the lists when the halt ends, and the round after it takes it
in.

## Checking the work

The observers and the gate's record find a change made between rounds. They cannot say
whether a round of the game's own work was a right one: they hold the state as the work
last left it, whatever it left. So the gate checks the work itself, in two ways, after
each round of work and before anything is recorded.

**It does the work a second time.** The gate takes its own copies of all seven parts as
the round before left them, and the second of the three lists of what was asked. From those
it does the round's work again, by a text of the work that is its own: every function of
the work and every number it uses is written out a second time in `src/game/again.rs`, and
a test holds the two texts to each other word for word. Every function of the second text
begins with that text's mark, which is there to make it another function than the first
text's in the program as built. The program checks that at its start for the four that the
second doing is called by. It is the same work, so it must give exactly what is there, in every part. If it does not, something other than the work changed the state
during the round, or the two doings did not start from the same thing. When the two agree,
what is recorded is what the second doing made. The state is not read again for the
record, so a change to the state in the instant after the two were compared is not
recorded: it is found in the next round and put back.

**It holds the result to the rules of the game.** The result must be made of real numbers,
a state the game can be in, and a step that one round can make of the state recorded
before. The gate's own copy of the state recorded before is held to the rules first: if
that is not a state the game can be in, nothing can be held to it, and the round is not
recorded. The rules are written out twice, in `src/rules.rs` and `src/rules/again.rs`, and
the round is held to both: what either text refuses is refused. Both texts are asked about the one result, the state as the round's work left it. Beyond
that the second text is handed nothing the first text of the work made. It is asked with what the second text of the work
makes of the second list of what was asked, and with the halted moths as that text has
them. A test holds the two texts
to each other word for word, and each function of the second carries that text's mark.

Last, the gate looks at the observers once more. They have no part in the work, and one
that has changed while the round was worked is found there.

If any of these fails, nothing of the round is recorded. Everything halts, with what was
found given as the reason, and when the halt ends the whole round is undone. The state goes
back to the last record, and with it what the game keeps for itself: chance, when the next
moth is due, and what a screen was to be told about a catch. What was asked of that round is
still waiting, and the round after the halt takes it in. If the work goes wrong twice
running, the state is put back and the game cannot go on from there. It stays halted until
"Put it right" is clicked, and then it is begun again (see "How a halt ends").

The two find different things. Doing the work twice is exact: it finds anything that is
not the work's own result, whether or not it breaks a rule. It cannot find a mistake in the
work, because the work makes the same mistake both times. The rules are written apart from
the work, so they can find such a mistake, but only one that breaks a rule: they are bounds
and counts.

These are the gate's checks and not the observers'. The observers watch the state between
one round and the next. The gate watches the work.

### The rules of the game

| Of | A state of the game | A step of one round |
| --- | --- | --- |
| the counts | whole numbers, and none below nothing | none goes backwards |
| the moths | each inside the edge, with a number of its own, and no more than there is room for | a moth gone was caught, and a moth caught is gone; at most one comes, when one is due, at the edge, with a number not used before; none flies faster than a moth can; one halted in the web does not move |
| a catch | no more picked or eaten in the web than caught | a moth is picked only by a click, out of the web; the spider catches one only when hungry, free, with room for it, and within reach; what is gained is exactly what the multipliers make the catches worth |
| the shop | what was spent is the prices of what was bought, and no more than was gained; no more of an upgrade than the shop has | an upgrade is bought only when it was asked for, with moths already caught |
| the web | a size it can be, no more steps than it has, no older than a web gets, inside the edge | begun new; grown one step at a time under a spider at work on it; aged no faster than time; taken down only when old, from the hub, no faster than a spider can; never moved; a strand broken only with a moth taken from it; counted as finished only when it is |
| the spider | its size what its age makes it; its age, food and boost within their ends; a state it has; held and panicking together or not at all; its feet within reach; inside the game area, but for a new one coming in | its age is the time played; its meals are the moths it caught; its food is what eating and time make it; a boost only for an old spider eaten, by what that one had eaten; an old one eaten only where it was reached; it walks no faster than it can; held only by what the pointer has hold of; let go, it gets over it without moving |
| a death | no more old spiders eaten than have died | only of old age or an empty meter; the next spider new, outside the edge; the old one left where it died |
| the edge | where it is fixed | |

The rules are in `src/rules.rs`, apart from the work in `src/game.rs`, and each is written
out a second time, in `src/rules/again.rs` and `src/game/again.rs`. The numbers the rules
use are stated in the rules for themselves, and nothing there calls the work's own
functions. A check that asked the work for the right answer would agree with whatever the
work did. So one of those numbers that a rule holds the work to exactly has to be changed in
every place it is in, and until it is, the game halts: four places, or three for the inset
of the edge, which no round's work uses. Where a rule is only a bound, the work's
number can be changed on the near side of it, in both texts of the work, and nothing halts.
A number that no rule uses is in the two texts of the work. Changed in one of them only, it
makes the two doings disagree as soon as it bears on a round. The numbers of how a game
begins are another matter: a new spider, a new world and what the game keeps for itself
at the start are made by `src/game.rs` alone, once, and are no part of a round's work.

## How a halt ends

Whatever changes the state from outside is found in the next round, and everything halts.
How the halt ends is set by the three buttons under "Put a change right":

| Setting | What happens |
| --- | --- |
| at once | A change found before the work is put right in the round it is found: nothing pauses, and no round of the game is lost. A round the gate refuses is put right at the start of the next round, and that one round is lost. |
| after a pause | Everything stays halted until the state has been left alone for 0.6 seconds, or it is asked for. Then it is put right. This is how it starts. |
| on a click | Everything stays halted until the "Put it right" button is clicked. |

Under every setting there is a halt, it is counted, and what was found and what was put
back are said at the backdoor. The setting only decides when the putting right happens. The
setting is the program's own: the backdoor does not reach it.

One kind of halt is not ended by any of the three: a halt that cannot be put right. It
comes in five ways:

- the work goes wrong twice running, not counting a round for which a line was kept at the
  backdoor;
- the gate's record of a part does not agree with itself, and the state and the observers
  do not settle which half of it is right;
- no two of the three places in which the gate keeps what is its own agree, or no two of
  the three that hold the observers' threads, or what those threads are run by: two faults
  at once;
- after everything has been put right, the gate or any of the eight new observers still
  finds something;
- the program itself stops where it should not have while it has hold of the game (in
  Rust, a panic), twice with no round between that began with nothing halted and was
  recorded. Once, and not in a halt that already cannot be
  put right, that is a halt like any other: the counts are put right, and when the halt ends every part goes back to the
  gate's record, whatever the stop left half done. Twice, what was there is not gone on
  with or looked at again: it is put aside whole, and what waits in its place is a game not
  yet begun. No fault of the kinds claimed stops the program in the wrong place, so this is
  for a mistake in how the program is written. One that came back less often than every
  other worked round would be a halt each time, and would not be put aside. A stop while
  a line that has just arrived at the backdoor is being done is none of this: it is caught
  where the line is run, and the line is refused.

Nothing of a wrong round is recorded, and everything stays halted: until it is asked for,
no round and nothing asked of the game does anything to the game's state. A stop in the
wrong place during such a halt, in a round or in a request other than a line at the
backdoor, puts the game aside whole. Where the gate's record of a part could not be
settled, the parts before it have been put back, and that part and those after it are left
as they were found, and may still show a round that was not recorded. The "Put it right"
button is then shown under every setting, and clicking it begins the game again: a new
spider, no moths, nothing bought, eight new observers and a new record. Nothing of the old
game is kept but the setting above and the count of how many games there have been. What is
the program's and not the game's goes on as it was: the game's own time, the gate's note of
what the clock last said, and its hold on the observers' threads. The
program does not do this by itself, however long it waits, and a click made before the halt
came to this does not count: it takes one made after.

## What is fixed by how it is built

Some of what the model asks for is met here by there being nothing that can vary.

- **The shape of the state is fixed.** A field holds a number, true or false, or a text, and
  only that kind can be written to it. A field cannot be added, taken away, frozen or turned
  into something that runs code. The list of moths can grow and shrink, and that is caught
  like any other change.
- **An observer's rule is not a thing that can be changed.** It is part of the program, and
  each observer has its own copy of it.
- **The observers are separate threads, and no more than that.** Each looks for itself, and
  one that stops or sticks is lost alone and found by the gate and by the rest. They are
  still threads of one program: they share its memory.
- **Nothing can be switched off.** There is no setting for an observer, for the gate or for
  any of its checks. The backdoor does not reach the gate's record, and it does not reach
  the setting for how a halt ends. An observer that has not answered is not asked again
  until it is replaced, and counts as silent for as long: everything stays halted.
- **One observer does not stop the program.** An observer that finds the rounds stopped is
  believed when a second one of the same eight finds the same.
- **The page reports nothing.** There is no record held by the page and no check on the
  page's code, because none is needed: a changed page changes what its owner sees and
  what is sent in the owner's name, and nothing that is observed.

## What is not observed

- **More than one fault for each halt, or two wrong rounds running.** What is held is one
  fault for each halt. Set to end "at once", a halt lasts no longer than to the start of the
  next round, unless a new observer does not answer, which is a second fault, so that is one fault from one look to the next. Under the other two settings a
  halt lasts many rounds, and a second fault that lands while it lasts is two faults
  together. So is a second fault that lands before the first has been found. A fault that
  lands in a round after the gate has compared what it keeps is found at the start of the
  next round, and a second before then is two faults in one halt, though a round was
  recorded between them: a check ran three such pairs, and the game could not go on. The review of these claims ran three such cases. After a pause: the state
  changed, and three rounds later the gate's text of that part, and the game could not go
  on. On a click: one half of the record changed, and rounds later the other half to the
  same value, and it was kept. And two rounds running that each went wrong in the work, each
  by one fault of its own, are taken as work that goes wrong twice running: the game cannot
  go on. That is so whatever the second fault is in. One in the gate's record, in the first
  round worked after another round went wrong, comes to the same.
- **The gate's record, when more than one thing has gone wrong in the same round.** One
  fault in the record is found and put right: in either half of any part, between rounds
  or while a round is being worked. Two are another matter. The backdoor cannot reach the
  record, so nothing that can be typed there causes either of these.
  - *Both halves of a part changed, so that they agree.* A record that agrees with itself
    outranks the state and all eight observers. With a value no rule forbids, the game
    halts once and then goes on with the wrong value. With one the rules do forbid, the
    game has to be begun again.
  - *Both halves changed, each another way; or one half and the state too, in a part the
    last round's work had moved.* Nothing settles which is right. Nothing is changed, and
    the game has to be begun again.
- **What is asked of the game, before it is taken down.** Once it is in the three lists, a
  fault in one of them is found and put right from the other two. What the page sent, and whether the person sent it, is
  not checked by anything: a press that never happened, sent to the program by something
  else on this machine, is a press.
- **What the server keeps.** Which connections are open, how many screens there are, and
  what was last written out for a screen: one copy of each, watched by nothing. A fault
  there can drop a screen, refuse a connection or send a screen something stale. It cannot
  reach the game. The channels to the observers' threads are of this kind too: one that
  goes wrong is an observer that does not answer.
- **What a screen is sent.** The program writes out what there is to show, and nothing
  checks that the page shows it.
- **Whether the work, as it is written, is the right game.** This is not a fault that lands
  in a round. Anything that happens during a round to what only one doing reads makes the
  two doings disagree, and the game halts at once: for a wrong round to be recorded, two
  faults in the same round would have to agree. What the work is written to do is another
  matter. It is the same in both doings: the second has a text of its own, but that text is
  the first one written out again, and a mistake in one is in the other. A change made to
  one text only is found, because the two doings then disagree. The rules, written apart,
  say something about what the work is written to do, and only where a rule is broken.
- **The rules themselves.** Two texts that say the same, written by the same hand as the
  work. A rule changed in one text only is still held by the other. A rule that is wrong in
  both halts a right game, or lets a wrong step through, and nothing checks that but the
  tests.
- **A mistake in the rule the observers look by, in the work, or in the rules of the
  game.** Each observer has its own copy of the rule, the work and the rules of the game
  have two texts each, and a change to one copy is found by the rest. A mistake that was there when the copies were made is in all of them. Copies written
  apart, kept in repositories of their own, would not share it, and a change to them would
  take a commit for each: that is the next scope, and is not built here.
- **The program itself, and what it runs on.** Whoever can change the program or its memory
  is past everything here: a debugger, a memory editor, the operating system, whoever has
  root. One machine under one person. The copies of the rule and the two texts of the work
  are held apart in the program as built, by a mark in each, and the program checks at its
  start the eight rules, the four functions the two doings are called by, and the two that
  each text of the rules of the game is called by. What those
  call in turn that is shared, how a part is written out among it, is one copy there.
- **The rest of the shape of the state.** What kind of thing a field holds, and where a list
  keeps its length: the program holds these, and they are not fields. Four counts are
  watched all the same, because a change to each can be said in the program's own terms and
  was once enough to stop it in the wrong place: how many legs the spider has, how many
  observers there are, how many copies each holds, and how many texts the gate has written
  out. One too many or too few of any is found and put right, between two rounds or inside one,
  and nothing stops in the wrong place for it: the observers and the gate each count what
  they are given before they lean on it, and the backdoor reads and writes nothing while the
  number of observers, or of an observer's copies, is wrong. A review once put in a ninth
  leg, which was then in no part's text, and the game could not go on.
- **Whether the game keeps running.** If the program stops, the page says the server is
  silent, and only the person sees it. A round that never returns ends the same way: each
  observer, on its own thread, finds that it has heard nothing of the rounds for five
  seconds, and when two have found it the program stops.
- **The machine's clock.** It is asked of the machine once a round, counted from nothing the
  program keeps, and decides how long that round is: a
  twentieth of a second at the most, and never less than nothing. If it cannot be read, the
  round is of the ordinary length. The game is told what it says when the program starts,
  so the first round is no longer than the rest. That is all it decides from round to round. The time at the start seeds chance, and after a
  stop in the wrong place the game that waits to be begun takes its time and its seed, or begins at nought where the clock cannot be read, from
  the clock.
  A clock that jumps or goes back, and a machine that stands still for an hour, move the
  game on by one round. A clock that runs fast or slow by a little makes the game run fast
  or slow by as much, and nothing here finds that.
- **Who is at the pointer.**
