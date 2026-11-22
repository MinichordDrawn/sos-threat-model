# A Self-Observing System: One Spider

The kit in this repository audits a system against a model of self-observing systems. The
model holds that where an unnoticed failure would be catastrophic, everything that matters
has to be observed, by a ring of observers that watch each other, with the work stopped on
any detected fault. The other examples here are audits of systems that exist. This one is a
system built on the model, small enough to read whole.

It is an idle game. One spider hunts moths, makes webs, grows old and is followed by the
next. One program, written in Rust with nothing but the standard library, runs the game. In
the same program eight observers in two rings, each on a thread of its own and each with its
own copy of the rule it looks by, watch every part of the game's state, with a gate behind
them. No round of the game's work is done until they
have looked, and one detection halts everything. The game gives the observers something to
watch that a person can see.

Under the game there is a backdoor: a console with open write access to every field of the
spider, of the world and of the observers. Whatever is written there that changes anything
is found before the next round's work, everything halts, and it is put back. That is what
the example is for: a fault can be put into a self-observing system by hand, and what
becomes of it can be watched.

![The page of One Spider. On the left, what the game says: the moths, the upgrades, the count of halts, and the eight observers. In the middle the spider sits in its web, with moths halted on it, and under it is the backdoor. On the right is the state, field by field.](one-spider.png)

The picture is the page while the game runs. At the backdoor the spider's size has just been
doubled, with `spider.body.size *= 2`. The lines under it are what followed: the `legs A`
observer found the body changed, everything halted, the body was put back, and all eight
observers were started again.

A moth is halted by the first strand that can hold it, at the outside of the web. A change
from outside is halted the same way, before any work is done on it.

## The result

One fault at a time, in the state, in an observer, in what the gate keeps or in what was
asked of the game, is found before any work done on it is recorded, and is put right, and
the game goes on.

A fault is one stored value changed by something other than the game's own work: a field of
the state, a field of an observer, either half of the gate's record, an entry in one of the
three lists of what was asked of the game, or one of the three places in which the gate
keeps everything else that is its own. Or it is one observer's thread that stops answering. It may
land between two rounds or inside one. A fault
between two rounds is found before any work is done, unless what is asked next writes over
it in its list, and then nothing is left of it. For a fault inside a round, one of two
things happens. The round is not recorded, and when the halt is over the state is what it
was when the round began. Or what is recorded is exactly what a round with no fault would
have recorded, and whatever is left of the fault is found in the next round. A changed value
is never recorded as true, and no single fault leaves the game unable to go on.

What is held is one fault for each halt, with a round recorded before the next fault lands
in the work. A second fault that lands before the first has been put right is outside it. So
is one that lands in the first round worked after a round that went wrong: two wrong rounds
running stop the game, unless a line kept at the backdoor made one of them. And so is
everything under "Where it ends".

This is tested. That a changed value is never recorded, and that no single fault leaves
the game unable to go on, are also proved in Lean, for a model of the protocol of a round:
`proof.md` says what that covers. Earlier versions were reviewed, each review of the
single-fault claims found a case where it failed, and those cases are closed and are tests.
The wiring of the observers, taken by itself, is model checked. That this program is that
wiring is argued. "What is established" says which claim rests on what.

## How safe the spider is

Within the scope, the spider cannot be changed from outside its own game. A change written
at the backdoor is found before the spider takes its next step, and put back. At any moment
the system is in one of three conditions.

1. **Working as designed.** Every round was looked at before it was worked, and checked
   before it was recorded.
2. **Not working.** Something was found and everything has stopped. It is put right, or at
   the worst the game is begun again. No work is done in between.
3. **Something outside its scope has gone wrong.** The program was stopped, or the machine
   it runs on failed. "Stop this and the spider dies", the program says when it starts. A
   person can kill this spider as a person can kill a real one.

There is no fourth condition, in which the game runs on with a state that is not its own
work's. The safety systems of critical things are built for that same property, and they
get it the same way.

| A safety system | How it fails safe | The same thing here |
| --- | --- | --- |
| A railway signal | It shows clear only while a current through the rails holds a relay up. A train, a broken rail and a dead supply all drop the relay, and all read as danger. | An observer's silence halts everything, as a flag does. |
| A train's air brake | The brakes are held off by pressure in a pipe the length of the train. If the train parts, the pressure goes and the brakes go on. | No work is done unless the observers and the gate have looked and found nothing. Every observer has to signal in every round, and one that has not stops everything. |
| The control rods of a pressurised water reactor | They are held above the core by latches that need power to hold. Take the power away and they fall. Nobody has to decide. | One detection halts the whole game in the round it is made, and no setting turns a check off. |
| An Airbus flight control computer | It has two channels. One commands and one monitors, each works the answer out, and if they disagree the computer is taken out and another takes over. | The gate does every round's work a second time, and records nothing unless the two agree. |
| A hardware security module | It guards keys, and erases them when it detects tampering, sooner than let them be read. | When the gate's record cannot be settled, the game is not gone on with. It stays halted, and a click on "Put it right" puts it aside whole and begins it again. |

The Chernobyl example in this repository is the same list read the other way: protections
a person could remove, and a shutdown whose first motion made things worse.

The comparison is of structure, not of assurance. Those systems are built and certified to
standards this game has not been held to. What holds here is one fault at a time. It
is tested, and proved for a model of the protocol and not for the program.

### Compared with other software

Most software checks what comes in at its edge and trusts its own memory after that. The
pieces of what is done here exist, each under a name of its own.

- **Stopping sooner than doing wrong.** A processor that halts instead of making a wrong
  change is called fail-stop (Schlichting and Schneider, 1983), and a module that either
  works or stops at once is called fail-fast (Gray, 1985). That is the three conditions
  above.
- **The work done twice.** Lockstep processors run the same instructions on two cores and
  raise a fault on a difference. Some railway signalling computers work out a coded check
  alongside every result, and stop if the two do not agree. The gate's second doing is the
  same idea, in software, for a whole round.
- **A record written only on agreement.** A replicated state machine, and a ledger built on
  one, records a step only when enough replicas have agreed on it. When a round is recorded
  here, the gate's record is written only from the second doing, once the two agree.
- **State checked against a record and put right.** A checksumming file system verifies
  each block as it is read and repairs a bad one from a good copy. Here it is every part of
  the state, before every round.
- **Watching for a death.** A supervision tree restarts a process that dies. It sees a
  death. It does not see a state that has gone wrong without one.

What is unusual here is having all of them at once, in an ordinary program, around its
game's state, its observers and its record, with the check made before the work and a halt
as the only response. Aside from the other implementations of this model, which the model
check's README lists, the author knows of no other application built that way. That is a
remark about what the author has seen, and not a result.

## Overview

The game first, and then how it is watched. The scope of what is claimed comes after.

### The game

A moth comes in from an edge every few seconds. The spider hunts when it is hungry, and
while it is full it makes a web, which halts the moths that touch it. A click takes a moth
out of the web. Moths caught are spent at a shop with four upgrades. The spider grows, and
dies of old age at five minutes or of hunger before that. In the round it dies the next
spider is there, walking in. It eats the old one, and is the quicker for each moth that one
had eaten. The pointer can pick the spider up by its body or drag it by a leg.
`gameplay.md` has all of it, with the numbers.

### The eight properties

The model asks eight things of a system's observers. This is how each is met here.

| Id | Property | What must be true | How it is met here |
| --- | --- | --- | --- |
| P1 | Liveness signal | an observer's silence triggers a response | Every running observer is asked to look in every round, and its answer is its signal, `beat`. One that is stopped is found by the others of its ring in that round. One that has not answered when the round's waits are used up is found by the gate in that round, and by the others of its ring from the next. Either way everything halts. |
| P2 | Shared substrate | work cannot run where its observer cannot | The observers, the gate and the work are one program. Each observer is a thread of it, and the round asks them to look and waits for them before the gate checks and the work is done. After a halt, the eight new observers look, each for itself, before the halt ends. There is nowhere for the work to run without them. |
| P3 | State check | a state that goes bad without a sign is seen | Every observer keeps a copy of every part of its ring, or for the two coordinators a fingerprint of it, and compares it with the state in every round. The gate compares every part with its own record. |
| P4 | Propagation | one detection stops the whole system | One flag reaches every observer of its ring in the same round, and through `whole`, which sits in both rings, it reaches the other ring. On any flag the spider, the moths and the web stop together. |
| P5 | No single-step removal | there is no sanctioned way to stop an observer checking | Nothing in the program turns an observer, the gate or a check off. The one setting there is decides only when a halt ends. An observer's rule is part of the program and not a field. Stopping an observer at the backdoor is a change from outside like any other, and is found as a silence. An observer that has not answered is not asked again until it is replaced, and it counts as silent for as long, so everything stays halted. |
| P6 | Out-of-boundary signal | an observer's loss is seen from somewhere that survives it | An observer's loss is seen by every other observer of its ring, in that round or the next, and by the gate, which is not an observer and is not lost with one. A loss in either ring halts everything, and through `whole` the flag reaches the observers of the other ring. Everything here is one program, so a boundary is a single observer. The loss of the whole program is seen only by the person at the screen. |
| P7 | Automatic enrolment | nothing exists unobserved | The shape of the state is fixed, and every field of it is in one of the seven watched parts. What comes and goes, a moth or the next spider, is in a watched part from the round it is there. |
| P8 | Immediate response | the response has no window, and outpaces the fault | The observers and the gate look before any work, in every round. What they find halts that round, so no work is done on a changed state. |

P5 and P7 are met by how the program is built. Nothing runs for them, and there is nothing
to test but that the program is as described. The other six are tested.

The model check in this repository gives two requirements names of their own. The first is
the *gate*: the observers check before any work is done. This program has that order, and it
also has a thing it calls the gate, which keeps its own record of the state behind the
observers and checks the work against it. The second is the *halt fan-out*: here every part
halts on a flag from any observer, and a flag is passed on to every observer of both rings.

### The observers and the parts

The state has seven parts: the two sets of legs, the body, the edge, the moths with the
counts and the shop, the web, and what the game keeps for itself (the pointer, what has
been asked of it, and chance). Six are open to the backdoor. The seventh is not.

| Ring | Observers | Parts |
| --- | --- | --- |
| the spider's | `legs A`, `legs B`, `body`, and its coordinator `whole` | the two sets of legs and the body |
| the world's | `edge`, `moths`, `web`, `whole` again, and its coordinator `page` | the edge, the moths with the counts and the shop, the web, and what the game keeps for itself |

Inside a ring the observers are a full mesh: every observer checks every part of the ring
and every other observer of it. The spider's ring is the model's ring of three and a
coordinator. The world's has one member more, which is the spider's coordinator again, and
that is how the two rings are joined. An observer is state too, and every field of it is
open to the backdoor.

Each observer runs on a thread of its own, and looks by a copy of the rule that is its own:
the rule is written out eight times, and a test holds the eight to one another. Each copy
carries a mark of its own, so that the program as it is built holds eight functions and not
one, and the program checks that when it starts. Every round
each running observer is sent what there is to look at, looks, and answers for itself. Its
answer is its signal. The work waits for the answers: eight waits of five thousandths of a
second with no answer at the most, and one more for each thing that arrives: 110 thousandths
at the very most for one asking, and a round that puts a halt right asks twice. The waits are counted and not timed by the clock, so a machine that stands
still for a while uses up one of them and no more. In one run of 30,000 rounds on the
machine this was built on, the longest the work waited for all eight was 1.09
thousandths of a second, and no round used one of its waits. In other runs, with the
machine busy with other work, the longest was 23 thousandths and no round used more than one wait.
An observer that does not answer is silent. It is not asked again, and is replaced with the other seven when the halt
is put right: eight new observers are eight new threads, and the halt does not end until all
eight have looked. The observers also watch that the rounds go on. One that hears nothing of
them for five seconds takes a round to have stuck, and when a second one finds the same, the
program stops. The numbers are this program's own.

One observer also does something. The `moths` observer keeps the list of the moths halted in
the web, and the world does not move a moth that is on it. The others of its ring work the
list out for themselves in every round and compare.

### One round

1. The gate compares the three places in which it keeps what is its own. Then every running
   observer is asked to look, each on its own thread, and the round waits for their answers.
   Each checks first that it has been given eight observers and seven parts to look at, and
   then that its own last signal is the round before's. Then it compares every
   part of its ring with what it holds of it, compares what it holds with what the others of
   its ring hold, and checks that the others signalled in the round before, are running and
   are in shape. An observer's answer is its signal for the round. One that has not answered
   when the waits are used up is silent.
2. The gate looks: at its record against itself, at the state against the record, at the
   observers against the record, and at the three lists of what was asked of the game
   against one another.
3. If any of them found anything, everything halts, and no work is done on what was found.
   Set to end at once, the halt is put right there and the round goes on. Otherwise the
   round ends here, and "How a halt ends" says what follows.
4. The state as it stands is kept, for putting right. Then the work is done: what was asked
   of the game is taken in, the world does its work, and the spider does its work. A line
   kept at the backdoor to be written during the work is written now.
5. The gate checks the work. Every number in the result must be a real one. The gate's own
   copy of the round before, and then the result, are held to the rules of the game. The
   work is done a second time from the gate's own record, and the observers are looked at
   once more.
6. The round is recorded: the gate's record becomes what the second doing made, and each
   observer takes its copies from the state. If a check failed, nothing is recorded and
   everything halts. If that happens two rounds running, not counting a round for which a
   line was kept at the backdoor, the game cannot go on.

While a halt lasts, the observers still signal and look, a letting go and the pointer's last
place are still taken down, and nothing else is done. In a halt that cannot be put right,
no observer looks at the game's state and nothing asked of it is taken down. A round
leaves it as it is until the game is begun again. The gate still compares the places where it keeps
what is its own, the game's time still moves, and the observers are told only that the
rounds go on.

### The gate

Behind the observers is the gate. The program keeps its own record, which the backdoor
does not reach: the state as the game's own work last left it, and so what every observer
should be holding. A change that every observer has been made to agree on in the same
instant is stopped there.

- **The record is in two halves.** It holds every part twice, written out and as a copy,
  and the gate checks the two against each other before it looks at the state. A
  record that agrees with itself is what counts when a halt ends, and the state is put
  back to it. Where the halves disagree, the state and the observers settle which is
  right.
- **What is asked is taken down three times.** The pointer's places, a press, a letting go
  and an upgrade asked for each go into three lists as they arrive. The gate compares the
  three, the work takes in the first and the second doing the second. Where one list
  differs, the two that agree are what was asked, and nothing that was asked is lost.
- **Everything else of the gate's is in three places.** Whether everything is halted and
  why, how a halt ends, the counts, the number of the round, the game's own time, and what
  is waiting to be written during the work are each held three times. What is read is
  what two of the three agree on, so one place that has been changed is never what is read,
  at any instant. The gate compares the three at the start of every round, and one that
  differs is a detection like any other: everything halts, and it is put right from the
  other two. The state kept for putting right, the game's hold on its observers' threads,
  and what those threads are run by, are held the same way.
- **The game keeps its own time.** The length of a round is how long it has been since the
  last, by the machine's clock and the gate's own note of what that clock last said: a
  twentieth of a second at the most, and never less than nothing. A clock that cannot be
  read gives a round of the ordinary length. The game's time moves on
  by that length, and everything in the game that waits for a time waits for the game's.
  So from round to round the machine's clock decides how long one round is, and nothing
  else. A clock that jumps, or a machine that has stood still, moves the game on by one
  round. The time of day is read for two things besides: at the start it seeds chance, and a game
  put aside whole takes its time from it. The machine's other clock paces the rounds and
  times the waits, and nothing of that is taken into the game.
- **The work is checked in two ways.** The gate does every round's work a second time from
  its own record, by a text of the work that is its own, and the two must agree exactly.
  Every function of that text carries a mark, which is there to make it another function
  than the first's in the program as built.
  And it holds the result to the rules of the game, which are written apart from the work,
  and written twice: a round is held to both texts, `src/rules.rs` and `src/rules/again.rs`.

`observation.md` has every part's fields, how a part is put right, and the
rules.

### How a halt ends

| Setting | What happens |
| --- | --- |
| at once | A change found before the work is put right in the round it is found: nothing pauses, and no round of the game is lost. A round the gate refuses is put right at the start of the next round, and that one round is lost. |
| after a pause | Everything stays halted until the state has been left alone for 0.6 seconds, or it is asked for. Then it is put right. This is how it starts. |
| on a click | Everything stays halted until the "Put it right" button is clicked. |

Under every setting there is a halt, it is counted, and what was found and what was put
back are said at the backdoor. When a halt ends, every part is put right, all eight
observers are started again as new ones, and each of them looks once more before the halt
is over. The repair is a simple one, to keep the example small:
`observation.md` says what a finer one would be.

One kind of halt is ended by none of the three: a halt that cannot be put right. A
round then leaves the game's state as it is until "Put it right" is clicked, and that
click begins the game again. No single fault of the kinds above brings one about.

## The scope

Everything on this page is claimed inside a scope. This section is the whole of what the
page says about it: what is inside, where it ends, and how it could be moved.

| The scope | What it is |
| --- | --- |
| Inside | One program on one machine: the game's state, the game's work, the eight observers and the gate. |
| Held inside | One fault for each halt: found before any work done on it is recorded, and put right. |
| Outside | The page and the person at the screen, what the program stands on, what is written in the program, and more than one fault at a time. |

### What is inside

The scope is the program. It holds the game's state, the game's own work, the observers and
the gate, and it does one round after another, about sixty a second.

Two properties of the scope follow from how the program is built.

- **One system.** Everything inside the scope is one system: the state, the game's work, the
  eight observers and the gate. It begins when the program starts and ends when it stops.
  The eight observers are a ring of four and a ring of five that share one member.
- **No state at rest.** The system exists only while it runs. Its whole state is in the
  memory of the running program. Nothing is written to disk, and nothing is read back when
  the program starts. So there is no interval in which any of it sits where nothing is
  running. Stopping the program ends the system: there is nothing to resume, and nothing
  saved that could have been changed in the meantime.

The page in the browser is outside it: a screen and a pointer. It is sent what to draw. It
sends back where the pointer is, where it was pressed and that it was let up, what was
asked for at the shop, what was typed at the backdoor, which way a halt is set to end, and
a click on "Put it right". The page reports nothing about the game. Changing the page
changes what its owner sees and what is sent in the owner's name, and nothing that is
observed.

The person at the screen is outside it too, and is the next observer up. If the program
stops, the page says the server is silent, and only the person sees that. That level is a
person and not a ring of machines, and it is not modelled here.

### Where it ends

Its edge is met from three sides, the third in two ways.

- **Outward: the loss of the whole program.** If the program stops, or the machine does, the
  observers go with the work. Nothing wrong is done, because nothing is done. But nothing
  inside the scope sees it: the page says the server is silent, and only the person at the
  screen knows. A round that sticks comes to the same: the observers find that the rounds
  have stopped, and stop the program. So does a round made too long by a list grown by
  millions of entries, or a text by some hundred million characters, between two of the
  points where what is held is cut down.
- **Downward: what the program stands on.** The compiler, the standard library, the
  operating system and the machine. Whoever can change the program or its memory is past
  everything here.
- **Inward: what is left to vary unchecked.** The rules of the game, what is asked of the
  game before it is taken down, and what the server keeps of who is connected: a fault
  there can drop a screen, and cannot touch the game. And a second fault before the first
  has been put right, or in the first round worked after a round that went wrong.
- **Inward: what the observers share.** The eight are separate threads of one program. They
  share its memory, the lists that say who watches what, and how a part is written out.
  Each looks by its own copy of the rule, the work's second doing has its own text of the
  work, and the rules of the game are written twice. But every copy was made from one
  text, by one hand, in one repository: a mistake in the observers' rule is in all eight,
  a mistake in the work or in a rule of the game is in both texts, and a fault in the
  program itself takes them together.

### How it could be moved

None of these edges is fixed. Each is where this example stops, and each can be moved out
by the same structure again. None of what follows is built here.

- **More faults at once: a larger ring.** Every part is held in full by three observers
  here, and twice more by the gate. More observers on the same part cover more faults in one
  round: the model check proves that a full mesh of *n* monitors holds for up to *n* - 1
  faults a round. In this program an observer is a name, a place in a few lists, a thread
  and a copy of the rule, with the two coordinators and the `moths` observer told apart
  inside it. So a larger ring is little more than longer lists and one more copy. What the
  gate keeps would need the same: two halves or three places settle one fault, and it would
  take three halves and five places to settle two.
- **A mistake in what is written: copies kept apart.** Each observer here has its own copy
  of the rule, and the work and the rules of the game are each written out twice. So a
  change to either has to be made in every copy, and a change made in one copy only is
  found by the others. But the copies are in one repository, and one commit can change them
  all. Keep each copy in a repository of its own, and a change takes as many commits as
  there are copies, by as many hands as the repositories have. Written apart from one
  description, and not copied, the copies would no longer share a mistake either.
- **The loss of the program: more than one server.** Run the game on several servers that
  watch each other, and the servers are a ring. The loss of one program, or of one machine,
  is then seen by the others, and the person is no longer the only one who would know.
- **What the program stands on: a ring at that level.** A ring on the operating system can
  watch what the program cannot watch of itself: that it is running, and that it is the
  program it should be. One level in, the same holds for the program as built: what the
  copies here still share is one copy in it. A ring at that level would hold that more than
  once and compare.
- **All the way down, and across a network.** The same structure can be put at every level
  at once. Hardware already has pieces of it: cores that run in lockstep, memory that
  checks itself, a timer that resets a machine gone quiet. A system built from its first
  instruction up with a ring at each level, on a network whose members watch each other,
  would push the edge of its scope down to the hardware and out to the whole network.
  Isolating such a machine adds no observer. It takes away the ways in, until what is
  outside is physical, and the case is the edge of the scope. An edge needs observers of
  its own: a ring on the case, as a hardware security module has, makes opening it a fault
  that is found. That is a design, and nothing of it exists here.

Each level is the same thing again: observers that watch each other, a check before the
work, and a halt on any fault. Growth adds rings, and each ring costs what it did before.
Where the scope can grow no further, the last level is a ring, whose members watch each
other, so nothing sits unwatched at the top.

## What is here

```
README.md            this page
one-spider.png       the page, while the game runs
gameplay.md          what there is to play, with the numbers
observation.md       how the game is watched, in full: the parts and their fields, the
                     observers, the gate's record, putting right, the rules of the game,
                     and everything that is not observed
backdoor.md          what can be said at the backdoor, and how to make the work go wrong
outside.md           what the program takes from outside itself, and the size of each thing
checks.md            the tests and checks, and what each review found
proof.md             the proof of the protocol in Lean: what it shows and what it does not
Cargo.toml           the program has no dependencies
Cargo.lock
page.html            the page: a screen, a pointer and the backdoor's box. It is built into
                     the program
src/
  main.rs            the rounds, one after another on a clock, and the server, written
                     by hand
  game.rs            the state, and the game's own work
  game/again.rs      the work, written out a second time, for the gate's second doing
  rules.rs           the rules of the game, stated apart from the work
  rules/again.rs     the rules, written out a second time: a round is held to both
  watch.rs           the observers, the gate and its record, one round, putting right, and
                     the tests
  watch/looks.rs     the rule by which an observer looks, eight times over
  backdoor.rs        the backdoor
test/
  limits.js          checks on what the program takes from outside
  drive.js           drives the page in a headless browser and prints what it shows
  wiring.py          the wiring, as a system of the model check
  review-*.md        the independent reviews and checks, word for word
lean/                the proof: the protocol written down, the model, the statements, the
                     proofs, and their records
```

## Running it

```
cargo run --release
```

Then open `http://localhost:8138`. Another port can be given after `--`, as in
`cargo run --release -- 9000`. Built with Rust 1.98. Nothing but the standard library.

The page has four panels: what the game says on the left, the game in the middle with the
backdoor under it, and the state on the right. Some lines to type at the backdoor:

| Say | What it is | What happens |
| --- | --- | --- |
| `spider.body.x += 150` | a change from outside | found in the next round by the observers, everything halts, and it is put back |
| `spider.ring[0].alive = false` | an observer stopped | the others find it silent, and everything halts |
| `world.tally.gained = 1000000` | moths to spend that were never caught | found, and put back before anything is bought |
| `during world.tally.caught += 5` | a fault in the game's own work that breaks a rule | found by the gate, with the rule named, and the round is undone |
| `during spider.body.until += 5` | a fault in the work that breaks no rule | found by the second doing of the work, and the round is undone |

`backdoor.md` has everything that can be said there.

## The checks

- **Tests.** 84 tests in the program, run by `cargo test --release`, in about five minutes.
  Every field of the spider, of the world and of every observer is changed through the
  backdoor, one at a time, under each way a halt can end. Single faults are put straight
  into what the backdoor does not reach: each half of the gate's record, what the game keeps
  for itself, the three lists of what was asked, and each of the three places of everything
  else the gate keeps. Faults are put in after a round's work
  and before the gate checks it, and at two instants while the round is recorded. Some sixty
  wrong steps are written during the work. Each test says where the game must be afterwards,
  and the tests of single faults also say what must be found and by whom.
- **Limits.** `test/limits.js` starts the program on a port of its own and sends it
  requests: 55 checks of what the program takes from outside, in a few minutes.
- **The page.** `test/drive.js` drives the page in a headless browser through eleven plans
  and prints what the page shows, for a person to read. The one verdict a plan gives by
  itself is that the page threw nothing and logged no error.
- **The wiring.** `test/wiring.py` writes the eight observers and seven parts down as a
  system of this repository's model check and runs its checker on it.
- **The kit's ring map.** The first pass of this repository's kit was run on the program, by
  an orchestrator given only the kit and the code, and stopped there. What its ring map
  listed was checked by hand, and what held and could be closed was closed: each observer
  was put on a thread of its own, the count of legs was made part of what is watched, and
  the number of the round is held more than once.
- **Reviews.** Four independent reviews in two rounds, then fifteen checks of changes and twenty-one
  checks of these documents. Each of the four reviewers was given the code, the README as it
  then was and the claims to check, and none of the working behind them. A check of a
  change was given the program before and after it, and a check of the documents the
  documents and the program. Between them they found eleven single faults that were recorded,
  or that stopped the game or the program, or that left a later fault unseen. Each is
  closed, and each but one is a test: the instant the clock was counted from is closed by
  there being no such instant. All forty hand-backs are in `test`, word for word but for local
  paths: the folder each was run in is «WORK», and the user's own folder «HOME».
- **One model.** The reviews of the single-fault claims and the thirty-six later checks ran on
  Claude Fable 5.2, the model the program was written with. A mistake that model makes
  consistently would pass them. The two reviews of what can be done from outside ran on a
  Claude Opus model.

The checks were made the way the program works. A fresh reviewer looks. What it finds is
put right before anything else is done. Then a new reviewer, given nothing of the one
before, looks at the result, and that is repeated for as long as a round finds something. A
round that finds nothing means that reviewer found nothing, as a round of the game with no
flag means those observers found nothing. That is why the reviews are called tests and not a proof.

`checks.md` lists the tests and checks, and says what each review found.

## What is established

- **Tested.** The result above, for the kinds of fault it names, at the instants the tests
  use. The eleven plans, the limits and the 84 tests all pass on the program as it is here.
- **Model checked, for the wiring only.** The wiring meets the four conditions of the model
  check's Theorem S, and no state its checker can reach breaks either of its goals at one,
  two, three or four faults in a round. That is a result about the wiring. It says nothing
  about whether this program is that wiring.
- **Reviewed, in earlier versions.** Each review of the single-fault claims found them
  false in some case of the version it read. Those cases are closed. The checks of
  changes that followed found more, and those inside what is claimed are closed:
  `checks.md` says what each ran and found.
- **Proved in Lean, for a model of the protocol.** One fault of any value, immediately
  before any of the 38 steps of a round or between two rounds, never has a wrong value
  written to the record, never leaves a halt that cannot be put right, and is found within
  two rounds or is gone. The same holds for faults one after another, spaced as `proof.md`
  says. There are fourteen
  statements, accepted by Lean's kernel and four other checkers and checked
  independently. `proof.md` says what the model is and what it leaves out.
- **Argued.** That the program is the wiring that was model checked. That P5 and P7 hold by
  how the program is built.

## What is not established

- **The program is not proved.** The proof is of a model written from the code. That the
  code is that model rests on two readings and on 11,757 situations run in both. The
  game's own work and rules are assumed sound in it, and a fault part of the way through
  a step is argued. `proof.md` lists the rest.
- **Not every correction to these documents has been checked.** The last check of a
  change led to no change in the program or its tests. The entries under "Reviews" in
  `checks.md` say what each check read.
- **The clock.** It is in the server, where there are no tests: what is tested
  is what the game does with whatever clock it is given.
- **That the rules never refuse a right round.** 640,000 rounds of random play in the
  second review, and half an hour of play in the tests, found no such refusal. One rule in
  particular, that a foot is never more than four body lengths from the body, was seen kept
  and not proved: the most seen was 2.70.
- **The page in a browser a person uses.** The plans run it in a headless browser, and no
  reviewer tried it in any.
- **Any system but the one it was built on.** The waits and the limits were checked on one
  Windows machine, and they depend on how its sockets behave.

## Licence

The documents and the picture in this folder are under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/), and the program, its page, the
check scripts and the proof under the MIT licence. See `LICENSE`, at the top of this repository.
