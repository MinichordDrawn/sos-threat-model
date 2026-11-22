# One Spider: The Checks

Every test and check there is, and what each review found. [README.md](README.md) has the
summary, and says what all of it does and does not establish.

## The tests

```
cargo test --release
```

Every field of the body, of every leg, of the edge, of the counts, of the shop, of the web,
of every moth and of every observer is changed through the backdoor, one at a time, and so
is the number of moths. Each change is made three times, once under each way a halt can end:

- **after a pause**: found in the next round with nothing moved, put back exactly, eight
  new observers, and a game that goes on;
- **on a click**: the same, and it stays halted with nothing moved until it is asked for;
- **at once**: put right in the same round, and the game is then exactly where a game that
  was never changed is, in that round and again some hundreds of rounds on.

An observer's signal is one of those fields: written from outside, it must be found by the
observer itself, and by the others of its ring, to which it is no longer the round before's.

Also: a flag raised in one ring, which must reach the other; a change every observer was
made to agree on, in the spider, the counts, the shop and the web, which the gate must stop;
the moths observer's list emptied, which the others must find; a halted moth, which must not
move; a click on a halted moth, on a moth on the wing and on nothing; writes of the wrong
kind, which the backdoor must refuse; changes made during the pause; and the setting changed
during a halt.

The shop: each upgrade is sold at its price and not for less; nothing but the four can be
asked for; moths written in from outside buy nothing; and with the multipliers at x1.5 and
x1.3, what is gained is exactly 1.5, 1.3 or 1.95 moths for each catch of each kind. Two of
the upgrades have a most. Asked for long after the shop has none left, with moths enough
for far more, the one for more moths must be bought nineteen times and the one for appetite
twenty-four, and no more; nothing may be spent on what was not bought; the shelf must have no
price for either; and the other two must still be sold. More of either than the shop has
must be refused by each text of the rules by itself, and by the gate when it is written in
during a round's work. And with all of them bought there must never be more than 48 moths,
in ten minutes of the game.

The spider's lives: a spider that lives out its five minutes, one that starves, and one
whose food is emptied in a single round. In each, in the round of the death there must be
the old spider and a new one outside the edge. For the death of old age the rest is checked
too: the round before, a living spider and no body, and in the round of the death the new
one already walking in, with a foot at the edge. Then it must reach the old one, eat it, and
be boosted by the right amount. A spider that dies before it reaches the old one must leave
its own body in that one's place. The boost must go up by a hundredth for each moth the old
one ate, by a tenth at most, and stop at 111%, and a boosted spider's food must last longer
by that much.

The pointer: that what it does waits for the next round's work; a press on nothing, which
must be a click and take hold of nothing; a press
on the body that does not move, which must hold nothing; the spider carried by its body,
with every leg in the air, its food running down six times as fast, catching nothing, and
stopped at the edge; the spider dragged by a leg, whose foot must stay at the pointer while
the body is pulled after it; letting go, and the 0.7 seconds after; holding it until it
dies, after which the pointer must have hold of nothing; a press during a halt, which must
not be kept; the pointer's places during a halt, of which only the last must be kept; and
a spider carried through a halt, which must be carried on from where the
record has it. What a screen is told the pointer is over is checked too.

The spider's every-field test is run again on a game where the old spider lies there and the
new one is walking in, and on one where the spider is being carried. The world's is run on
two games, and the observers' on one.

Where it says below that something is tried under each way a halt can end, some of the
tests wait the pause out and others ask for the halt to end. The two on the gate's copy of a part ask for the halt to end under
both settings that wait.

The gate's checks on the work, in two ways. First, that they do not stop a right game: every
test here plays with both checks on, so a rule that was wrong about the game, or work that
did not come out the same the second time, would halt it, and a halt in a game left alone
fails the test. Second, that they stop a wrong one. Some fifty lines are written during the
work, one at a time, each a different kind of wrong step that breaks a rule. Each must be
found in that round by the gate and by no observer, with the rule it breaks given as the
reason, and the round must be undone exactly. Then eleven lines that break no rule and
steer the game: a rest made longer, the spider turned, its feet moved, a moth sent
elsewhere, the web grown a step. Each must be found by the second doing of the work, with
the part that differs named, and the round undone, along with everything the game keeps for
itself. Also: a line that changes nothing by the time it is written, which must be recorded
and said to have been let through; an observer changed during the work, in six ways, which
the gate must find in that round; a line still waiting when a halt comes, which must be put
aside and said to have been; a wrong step under each of the three ways a halt can end; what
`during` refuses; and work that goes wrong the same way twice running, after which the game
must stay halted, with the state as the last good round left it, for as long as nothing
asks.

Beginning again: asked for in that halt, the next round must be a new game in every part,
with the counts of halts and restarts at nothing, the setting kept, and a minute of play
after it with no halt. Asking in a halt that can be put right must put it right and begin
nothing. A click made before the halt became one that cannot be put right must not begin the
game again.

Faults that only a fault could make, each put straight into the program by the test, with
halts set to end at once. Each must be found in the next round for the right reason and put
right in that round, and the game must then be exactly where a game that was never touched
is, in that round and again ten seconds on:

- **the gate's record**: what it has written out of each of the seven parts, changed and
  emptied; and its copy of each part, changed in one or two ways. On four games: one with
  moths to spend, one with a moth in the web, one where the old spider lies there, and one
  where the spider is being carried. The record must be put right from the state, and
  nothing in the state may change. One of these, the gate's copy of the moths emptied, is
  tried under the other two ways a halt can end;
- **what the game keeps for itself**: an upgrade nobody asked for, a click nobody made,
  the next moth brought forward and put off, its number changed, chance moved on, the
  pointer moved, taken out of the game, made to let go and to take hold, and the count of
  catches. The world's observers must find each, and nothing may be bought and no moth
  may come on the strength of it;
- **the three lists of what was asked**: something in one that nobody asked for, something
  asked for lost from one, something changed in one, and a place at 0 made -0 in one. The
  list must be put right from the other two: what nobody asked for must not be done, and
  what was asked for must be, an upgrade bought among it. With a press, an upgrade and the
  pointer's place waiting, each of the three lists changed in four ways must leave the game
  where a game that was never touched is. Two lists changed each another way: all three
  must be put aside, the pointer made to let go, and nothing bought, also with moths enough
  to pay for what each of the two lists asked. A flood of 5,000 of the
  pointer's places must crowd out neither a press nor a letting go.

A fault in the gate's copy of a part after a round's work and before the gate checks it,
under each way a halt can end: the round must not be recorded, and when the halt is over
everything must be as it was when the round began, with the game going on from there. That
includes a copy changed to something the game cannot be: a web of a size there is not. The
same with an upgrade written into the second list while a round is being worked.

A fault in what the gate has written out of a part after a round's work and before the gate
checks it: each of the seven parts, made longer and emptied, on the same four games, under
each way a halt can end. The round must not be recorded, the halt must never be one that
cannot be put right, and when it is over everything must be as it was when the round began.
Where the round's work had moved the part, the part must be put back as well as its record
put right, and where it had not, only the record. The same fault a little later, once the
gate has looked at the observers again, must leave nothing behind.

A change to the state as the round is recorded, at two instants: after the second doing
has been found to agree and before the record is written, and while the record is being
written, after the observers have taken their copies. Nine changes at each. The record
must be the one a game never touched would have, the change must be found in the next
round, and from then on the game must be exactly where that untouched game is.

The backdoor's limits: a line of 33 things, which must be refused whole now and as a
`during` line; an answer that must be cut where enough has been said; and 1,600 moths asked
for, which must come to 64, halted or not. A text of 1,025 characters, which must not be
written, and one of 1,024, which must be, and be found. Eight of the texts there are, an
observer's name, list and reason among them, made as long as they may be, with what a screen
is sent staying small. Texts of characters two, three and four bytes long, cut for a screen
and in an answer, which must be cut between two characters. A line of more than 1,024
characters, which must not be kept for the work. Two long lines that undo one another, which
must be let through with only their beginning kept to be said. A line that cannot be written
when its time comes, which must be said not to have been written and never to have been let
through. An observer's reason written with no flag put up, which the others of its ring must
find, on each of the eight observers and under each way a halt can end. And what is done
when the program stops in the wrong place while it has hold of the game, which the tests
call for directly. Once: it must be a halt, put right from the gate's record with nothing
of the half-done round kept, and the game must go on where a game that was never touched
is. Twice with no round between that began with nothing halted and was recorded: it must leave
a game not yet begun, halted, which the rounds leave as it is until it is asked for. A stop that
comes back in every round, in the work or after the round where what a screen is sent is
written out: under each way a halt can end the second must put the game aside, and it must
not halt and go on for ever. A count gone wrong inside a round, after the gate
has looked at its counts: a text of the gate's record or an observer too many or too few, or all but three or four
of the observers gone, at four instants and under each way a halt can end. Where the count
goes wrong between the gate's look and the work, or after the work, the halt's reason must
name the count: the number of observers, or the texts of the record. A text of the record
that changes or is emptied after the work must be said to be the record, and not an
observer's copies. It must be found in a halt
like any other, or be written over by the round's own recording and leave nothing, with
nothing stopping in the wrong place either way, and the game must go on. The same twice, with one round recorded between, and with two: two halts, and the game
not put aside. With a count wrong, seven lines at the backdoor, each of which must be
refused and read nothing, and a line kept for the work that names an observer, which must
not be written and must not stop the round. A count put right must be said, wherever it is put right: after a stop, in the putting
right of a halt, or by the gate at the start of a round, and there once, also where a count goes wrong
five times in one halt, and where it is put right at the start of a round and again in the
putting right of the halt. And what was asked must be emptied by the writing of the
record itself. That a stop is caught is from reading the program, from the test of a stop that
comes back, which catches it as the program does, and from the first check of a change, which put stops
into a copy and saw it. A stop on an
observer's own thread is not that: it ends that thread only, and comes out as an observer
that does not answer.

A number that is not one in what the game keeps of its catches, which must be found and put
right, with what a screen is sent still readable while it is there. And what the gate wrote
out of a part together with one observer's copy of it, two faults, which must not be settled
from the gate's copy: the game must stop until it is begun again.

And two faults at once in the gate's record. Both halves of a part changed to agree, with a
value no rule forbids: the game must halt once and go on, which shows what the record
outranks. The same with a value the rules do forbid, and both halves changed each another
way, and one half with the state changed too: each must leave the game unable to go on. For
both halves changed each another way, nothing may be changed in the attempt, and it must be
gone from the game begun after it.

What a screen is sent, piece by piece, before a halt and after one put right at once. That
the backdoor reads back what it writes.

What came of the kit's ring map. A leg too many and a leg too few, in the state and in the
gate's copy, which must be found before the work and put back. Five kinds of write in a halt that cannot be put right, which the backdoor must refuse,
and one read, which it must still answer.

What the gate keeps of its own, in three places. Each of 25 kinds of change, to every kind
of thing kept there, in each of the three places: until the next round nothing that is read
and nothing a screen is sent may differ, the next round must find it and halt, and put right
at once the game must be where a game that was never touched is. The same under the other
two settings, in one of the three places, with nothing moved while it is halted. One place changed while everything is
halted, to say there is no halt, or that it has been asked to end, or that it cannot be put
right: the halt must stay as it was. That is a second fault before the first is put right,
more than is claimed. Two places changed each another way, which nothing settles. The number
of the round changed in one place while a round is being worked, to six values, one more of
which is no more among them: the round must be recorded under the right number, the next
round must find the place, and an observer that then stops answering must still be found.
The state kept from when a round's work began, changed or emptied in one of its three
places, and in two. What the observers' threads are run by, changed in one place so that the
round would wait for no answer, take none as this starting's, or an observer would take the
rounds to have stopped at once: no observer may be taken for silent, and the gate must find
the place and put it right. The length of a round, worked out from the gate's own note: it
must go as a game given the length does, a note changed in one place must be found, and a
clock that stands still, goes back or jumps an hour ahead must give a round of no length, or
of a twentieth of a second at the most, a clock that cannot be read rounds of the ordinary
length, a game put aside while it cannot be read a time of nought, and a game that is
begun and plays when it is asked for, and the first round after the program is told the time a round no longer than the
rest: the game's own time must move by that and no more,
and no moth may come because the clock jumped. A text too many or too few in what the gate has written
out, and an observer or a copy too many or too few, with the observers together and apart.

The observers on threads of their own. Two games from one beginning, one with its observers
run together and one with each on its own thread, given the same ten lines at the backdoor:
round for round they must be in the same state, halted or not alike, for the same reason. An
observer that stops answering, under each way a halt can end: the halt must be for that, and
when it is put right eight new observers must take over and the game go on. Set to end after
a pause or on a click, nothing may have moved. The others of its ring must have no flag up
in that round and each its flag up in the next, for a silence. A new observer that answers
nothing from its start: the halt must not end and no work be done until eight more have all
looked. Rounds that stop coming: every one of the eight must find it for itself, and none
may take them to have stopped while they go by, in three stretches each longer than an
observer waits: with each asked to look, with one stopped and everything halted, and in a
halt that cannot be put right. An observer's thread that answers with a finding three
million characters long, and a reason of that length already in an observer: one halt, put
right, and no more than the first 200 characters kept or sent to a screen. The same answer
from one of the eight new observers when a halt is put right: the halt cannot be put right,
and its reason is cut the same way. One thing made three million characters long, or a
hundred thousand in number, with halts set to end on a click: the moths observer's list,
what the body is doing, the web's torn strands, one observer's copies or one copy, the
legs, the moths, the observers, the catches of the last second. What a screen is sent, before it is found and in each
round of the halt, must stay within a fixed size, and be back to its usual length when the halt has ended. A
list of halted moths of 1,400 characters must be sent whole, and a thing the game says of
itself of 10,000 characters must be sent as its first 4,096. A list of halted moths of
20,600 characters must be sent as its first 20,480, and one of thirty-two million must be
handed to the work as no more than that. A list of one letter and ten thousand characters
of three bytes each must be handed to the work as the letter and 6,826 of them: its first
20,480 bytes, cut between two characters. With 1,024 moths the one under the pointer must
still be said, and with one more, or four times as many, nothing may be. The same with
the pointer on a leg: said with 1,024 moths, and not with one more. A quote and a backslash must be written with a backslash
before them. Each of the thirty-two control characters must
be written out as it always was, and sixteen million of them in less than a second. A
text of a part cut for a screen must be the text cut between two characters, marked as cut,
and then written out, and an observer must be sent as it is shown, with its copies. One
list made a million entries long, the observers a hundred thousand, or one text sixty-four
million characters: in the state, in the gate's copy, in the texts of its record, in one
place of the state kept from the round before, in an observer, or in each of the three
lists of what was asked, and in each of the three places of the state kept from the round
before, twenty-three such in all, one of them sixty thousand moths with numbers no moth has had,
put into the gate's copy where a halted moth lies; between two rounds and at five instants
inside one, the last two just before the record is written and between the rules and the
second doing of the work, under each way a halt can end.
Nothing of that size may be left when the round is over, the round after it must find what
is left or nothing, between two rounds it must be found every time, the game must be whole
again, and neither the round it lands in nor the round after may take as long as one second. The two sizes must be 1,024 entries
and 1,048,576 bytes. A million moths and a million legs, and then a line at the backdoor
before any round, with the gate's copy, an observer and a list of what was asked made
large as well: four such lines, each of which must leave nothing of that size and take
less than a second. In a halt that cannot be put right, a list made long
in the state must be left as it is, by a round and by three lines read at the backdoor,
and what the gate keeps from the round before must still be cut, in each of its three
places. Taking the cutting down out before the observers are asked, before the
work is checked, before the work is done a second time, or before the record is written,
fails this test by what is left held.
Taking out the first cut at the start of a round, of what is kept from the round before,
fails it by time: writing a million moths out took a round about two seconds on the
machine it was run on. Taking out the second cut at the start, or the one before the work,
does not fail it: the next point cuts the same thing down, or the round ends in time at
the sizes the test uses. What the test does not hold, and nothing does, is
a list made millions of entries long that lands between two of the points:
`observation.md` says what becomes of that. The eight copies of the rule: each copy, looking as each
observer, at games with each of 120 faults in them, 101 of them different, every kind of thing that can
go wrong in an observer in each of the eight among them, must say what the other seven
say, and each copy, given a text or an observer too few or a text too many to look at,
must find that before anything else, and say which of the two it was. The two texts of the work: every function and every number of the second must be in
the first word for word, 41 functions and 29 numbers, and each function of the second must
begin with its mark, which must carry that function's name. What a second text takes from the rest of the program must be kinds of
thing, and no function or number by name. From the standard library the second text of the
work takes two numbers, as the first does. Below its head a second text must reach nothing in the rest of the program by a path, and
call nothing that a kind of thing brings with it but how a thing is written out. In three
rounds of a game each of the four functions the second doing is called by must be passed
as often as it should be, by the count each mark keeps under its function's name, and the
second text of the rules asked of the gate's copy, of the state and of the step in each.
Each text of the rules, asked as the gate asks it, must refuse by itself a step the rules
forbid, and allow a round that changes nothing. A round with an upgrade bought in it: both
must allow it, the first must refuse it when it is handed an account with no upgrade in
it while the second still allows it, and the second must refuse it when the second list of
what was asked has no upgrade in it, whatever the first is handed. The same round, given
to the gate to record: what only the first text refuses and what only the second refuses
must each not be recorded, for the rule's reason, and what neither refuses must be. The
two texts say the same of the same thing, so for the gate's own copy of the round before,
which both are asked about, each text's answer is put in by hand in turn, and the gate
must heed each. A round with a moth picked by a click, one with a moth arriving, and one
with the spider held: the first text, handed an account with that one thing wrong, must
refuse the round, and the second, which works the account out for itself, must allow it.
With the click taken out of the second list of what was asked alone, the second must
refuse the round and the first allow it.
And what the pointer has hold of must be worked out for the second text by the second
text of the work. Given an account with no click in it, the gate must not record the round
with the moth picked. Judged as of a minute before, the round with a moth arriving must be
refused by each text, and so must a moth that comes with a number given before. Given
an account in which no moth was due, or the time of a minute before, the gate must not
record that round, and given what it should be given, it must. Given an account in which
the pointer holds nothing, it must not record the round with the spider held. The two texts of the rules of the game the same way, 9 functions and
16 numbers, with nothing in the first that the second has not. A step the rules forbid,
which each text must refuse by itself, naming the same rule. That the copies are apart as the tests are built: the eight rules
eight functions, and the second doing not called by the functions of the first. The hold
on the observers' threads, changed in one of its three places to hold nothing: the threads
must still be asked, the gate must find the place, and no observer may take the rounds to
have stopped. And 30,000 rounds with the waits the program uses, in which no answer may be late: the
test prints the longest wait.

And half an hour of play with nothing written from outside, the pointer moving over the game
half the time, and someone buying the cheapest upgrade whenever there are moths enough.
There must be no halt, at least three webs of three sizes, a moth halted in one, never more
spent than gained, what was spent must be the prices of what was bought, at least five
spiders, and never a round without a living one. The tests take about five minutes, since
every round of them is worked twice.

Two things are from trials and not tests. A copy of the program was given a round that never
returns, three seconds in. Five seconds later the observers had found that the rounds had
stopped, and the program ended. And a copy was given one observer that says, three seconds
in, that the rounds have stopped while they go on. The program did not stop: that observer
was found silent, the eight were replaced, and the game went on with one halt counted.

## The limits on what it takes from outside

What the program takes from outside is checked by `test/limits.js`, which starts a copy of
the program on a port of its own and sends it requests: `node test/limits.js <the program>
<a port>`. It takes a few minutes, since several of its checks are waits. It checks:

- the headers sent with every answer;
- the stream asked for from another site, from another port of this machine and with another
  origin, and the page and the plans asked for from another site, which must all be refused,
  and by the page itself and at the address bar, which must not;
- a header line too long and one with no end, too many headers, and too much carried;
- the backdoor's sizes: a line of 2,000 reads, an answer cut at 64,000 bytes, a text and a
  kept line too long, 1,280 moths asked for, and eight texts made as long as they may be,
  after which what a screen is sent must still be small;
- eight long lines that undo one another, of which only the beginning may be kept;
- 40 idle connections, and 40 more that have each sent half a request, past which one more
  must still be served, a click on "Put it right" among them;
- 450 connections that do not hang up when they are put out, with which the program must
  hold no more than 256, take no more while it does, and take requests again within
  fifteen seconds or so;
- half a request, which must be given up after ten seconds, and a connection on which
  nothing is asked, which must be closed after fifteen;
- a ninth screen, which must be sent the game, with the first of the eight put out for it;
- eight screens that do not read, which must be given up on, and their threads gone;
- 56 screens that do not read, eight at a time, each lot putting out the one before while
  the program is still waiting to write to it, after each of which a line at the backdoor
  must still be taken;
- the program started again with something that is not a port, with the port 0, and with a
  port and something after it, each of which must say so and end without starting.

## The page

What the page shows is printed by the eleven plans of `test/drive.js`, which drive it in a
headless browser, and is read by a person. The one verdict a plan gives by itself is that
the page threw nothing and logged no error. The plans are `start`, `backdoor`, `wide`,
`moths`, `web`, `buy`, `shelf`, `lives`, `grab`, `during` and `again`. Each is run as `node
test/drive.js <chrome> <a folder for its profile> <a folder for pictures> <the plan> <the
program>`. The `lives` plan waits five minutes for a spider to grow old. The `again` plan
shows the page a halt that cannot be put right. Nothing typed at the backdoor can bring one
about, so the plan puts a relay between the page and the program, which writes such a halt
into what the page is sent and takes it out when the page asks for it to be put right. It
checks the page only: that the button is shown under each setting, that a click on it asks,
and what the page says after. What the program does when it is asked is checked by the tests
above.

## The wiring

The wiring of the eight observers and seven parts, taken by itself as a system of monitors
and work, is checked by `test/wiring.py`, with the checker of this repository's model
check: `python test/wiring.py ../../model-check 1 2 3 4`. It meets the four conditions of
that model check's Theorem S, and no state the checker can reach breaks either of its
goals at one, two, three or four faults in a round. That is a result about the wiring. It
says nothing about whether this program is that wiring.

## Reviews

Four independent reviews have been made, in two rounds of two, each by a reviewer that was
given the code, the README as it then was and the claims to check, and none of the working
behind them. Each was made on the version before the changes it led to. They are kept word
for word in `test`, with the thirty-six checks that followed. In the earlier of them the backdoor
is called the door, which was its name then. The local path of the folder each was run in is replaced by
the placeholder «WORK», and in the one that names another path, the user's own folder by
«HOME». Nothing else in them is changed.

- `review-math.md`: whether the single-fault claims are true of the code. It found four
  cases where they were not, and ran each. A place at 0 and at -0 in the two lists of what
  was asked were taken as the same. A change to the state in the instant after the two
  doings were compared was recorded as true. A change while the record was being written
  left the game unable to go on. And a change to the gate's copy of the web's size during
  a round stopped the program. All four are closed, and each is now a test. The review
  found the texts exact, the second doing to depend on nothing but what it is given, no
  detection resting on a fingerprint alone, and the wiring to be the wiring that
  `wiring.py` describes.
- `review-outside.md`: what can be done to the program from outside it. It found no way to
  get a change recorded. It found ways to make the program grow or wait without end, the
  worst of them one line at the backdoor, and that another site could put the page in a
  frame. Those are closed by the limits in `outside.md`, and checked by `test/limits.js`. It
  also found two kinds of write that were not found, neither of which kept a change: a write
  to an observer's signal, and a write to an observer during the work. And it found that a
  kept line outlived its halt. Those are closed too, and are tests. It was made by a less
  capable model than the first, so a clean result from it counts for less.
- `review-math-2.md`: the single-fault claims again, on the version with the first round's
  changes in it. Nine of ten held. One did not: what the gate had written out of a part,
  changed while a round was being worked, left the game unable to go on whenever that
  round's work had moved the part, and the body is moved by every round. No wrong value
  was recorded. It is closed, and is a test. The review put in some 50,000 single faults,
  between rounds and at twelve instants of a round, and found no wrong record and no stop
  of the program. One thing it did not settle: that a foot is never more than four body
  lengths from the body is a rule it saw kept, at 2.70 at most in 640,000 rounds, and did
  not prove.
- `review-outside-2.md`: the outside again, by the same less capable model. Again it found
  no way to get a change recorded. It found ten things at the edge. Lines written during
  the work that undo one another were kept whole to be said, in everything a screen was
  sent, for the rest of the game. Every connection, or every screen's place, could be held
  by something that asked for nothing, and the page did not ask again. A text had no size.
  The stream of the game was given to a request from another site. And smaller ones. They
  are closed by what is said in `backdoor.md` and `outside.md`,
  and checked by the tests and by `test/limits.js`.

Thirty-six checks and one pass of the kit followed the second round. They are given here in the
order they were made in. The pass of the kit came after the first three. After it the checks
came in pairs, a check of a change and a check of the documents on the same version:
`review-change-2.md` with `review-documents-3.md`, and so on to `review-change-10.md` with
`review-documents-11.md`. Checks of the documents came after those while the next
check of a change was still out: `review-documents-12.md` of the whole, and each one
after it of the corrections the one before it led to and of nothing else.
`review-change-11.md` is that check of a change, and `review-documents-19.md` a check of
the updates it led to in these documents. `review-change-12.md` is a check of the change
the eleventh led to, `review-change-13.md` of the lines of tests the twelfth led to, `review-change-14.md` of the case the thirteenth led to, and `review-change-15.md` of
the case the fourteenth led to. `review-documents-20.md` is a check of the corrections to
these documents that no check had read, and `review-documents-21.md` of `proof.md` and of
what the README says of the proof.

- `review-change.md`: a check of the changes the second round led to, by a reviewer given
  the program before and after them. Fourteen of seventeen claims about the change held. It
  ran 17,136 single faults in the program before and after, and the two differed only where
  the change says they should. It found that the program would not have stopped when the
  rounds came to an end if it could not write to its error output. It found that a number
  that is not one, in what the game keeps of its catches, made what a screen is sent
  unreadable. It found that refusals were often lost on their way to the sender, and that
  the new tests were weaker than they looked in seven places. Those are closed, and tests
  added, but for three of the seven places, which are as it found them. One thing it found
  is left as it was: a fault in the gate's record in the first round worked after another
  round went wrong is taken as the work going wrong twice running (see "What is not
  observed" in `observation.md`).
- `review-documents.md`: a check of the README and of `gameplay.md` against the program. Of
  some 680 claims it found 4 wrong and 35 true only in a narrower form, and each has been
  corrected. The documents were laid out again after it, into a README and its companions.
- `review-documents-2.md`: a check of the six documents as they are now laid out. It found
  no claim in the README wrong and fifteen true only in a narrower form. In the companions
  it found one sentence and one count wrong, and about twenty claims to narrow. Each has
  been corrected.
- `review-change-2.md`: a check of what the kit's ring map led to, by a reviewer given the
  program before and after. Most of its eight claims held, and it ran them. It found one
  case inside what is claimed: the number of the round, then held twice, changed while a
  round was being worked, was put right with the wrong number, because the observers'
  signals had been written from it. With a number that one more does not change, an
  observer that later stopped answering was not found. The number is now in three places
  with the rest of what the gate keeps, read from two that agree, and that case is a test.
  It found the round could be made to wait longer than was said, and that is now bounded
  and said as it is. It found one test that passed with half of what it names taken out,
  which now runs long enough to fail. And it found that a pointer's place was still taken
  down in a halt that cannot be put right, and that `+8190` and `0` were taken as ports:
  both closed.
- `review-documents-3.md`: a check of the six documents after the same change. Of the lines
  the change had altered it found four wrong and fifteen true only in a narrower form. The
  four were about what an observer on its own thread did: that one which does not answer
  was found by the others of its ring, that each worked out the moths in the web for
  itself, that an observer wrote and checked its own signal, and what a copy too few did.
  For each of the four the program was changed to do what the documents said, as nearly as
  it can be done: an observer on a thread of its own cannot write its signal into the
  game, so its answer is its signal, and the round writes it down when the answer comes.
  For the rest the documents were corrected.
- `review-change-3.md`: a check of what the two before it led to, and of what was done
  beyond them: the three places, each observer's own copy of the rule, the second texts of
  the work and of the rules, the third list, the game's own time. It took 21 claims and
  ran several thousand single faults at a dozen instants inside a round. Most held, the
  earlier case of the number of the round among them. It found a count gone wrong inside a
  round: a text too many in the gate's record, with halts set to end at once, left the game
  unable to go on, where the version before had put it right, and a text or an observer too
  few stopped the program in the wrong place. The counts are now put right wherever they
  are next leaned on, and a stop in the wrong place is once a halt like any other. It found
  that the instant the clock was counted from, moved into the future, left the game
  standing still with nothing said, and the clock is now counted from nothing the program
  keeps. It found the second doing of the work still calling five functions of the first
  text. Those, and a sixth found after it, are now in both. And it found three tests that passed with the thing they
  name taken out, and three changes to one copy of the rule that its test let by: those
  tests now fail for them.
- `review-documents-4.md`: a check of the six documents after the same changes. Three
  statements wrong and nine true only in a narrower form, each corrected. The three were
  left over from before the changes: what is asked said to be taken down twice, a number of
  the game said to be in two places where it is now in four, and a count of tests.
- `review-change-4.md`: a check of what the third led to. It ran some nine thousand single
  faults and stops in the wrong place, at two dozen instants of a round, and found no
  single fault inside what is claimed that is recorded or that loses the game: a count
  gone wrong at any instant is put right, and after one stop the game is where a game that
  was never touched is. What it found was at the edges. A stop placed by hand between the
  writing of the record and the emptying of the lists, where the program cannot stop by
  itself, had something asked taken in twice: the lists are now emptied where the record is
  written. A stop that came back after every round, with halts set to end at once, halted
  and went on for ever where it should have been put aside at the second: a stop is now
  forgotten only by a round that began with nothing halted. The program's first round was
  three times the ordinary length, and a clock that could not be read stood the game
  still: both closed. And it found four tests that passed with the thing they name taken
  out, and three ways for the two texts of the work to share something unseen by their
  test: those tests now fail for each.
- `review-documents-5.md`: a check of the six documents after the same changes, and of the
  page, which no check before it had read. Three statements wrong and eleven true only in a
  narrower form, each corrected, none of them about what the program does: a bound given a
  little too high, two comments left over, and one count given two ways. What the documents
  say of the page it found true.
- `review-change-5.md`: a check of the whole claim, looked at fresh, and of what the fourth
  led to. It ran 14,700 single faults at random, in random states and at random instants,
  each beside a game that was never touched, and several hundred placed ones, among them
  faults in the observers' threads and in what passes to and from them. None was recorded
  as true, and none ended the program. It ran the program as built: every fault written at
  the backdoor was found for the reason given here and put right, also with five threads
  asking at once. It found one sequence that lost the game. The number of observers going
  wrong inside a round still stopped the round's own thread, which made it a stop in the
  wrong place and not a plain halt. Two of those with one recorded round between, with
  halts set to end at once, put the game aside whole. Every place that leaned on there
  being eight observers now asks first, the gate's own look counts them, and that sequence
  is two halts and a test. It found that the second text of the rules was handed a list and
  an asking that the first text of the work had made: it is now handed its own. And it
  found three changes that no test failed for, each of which now has one.
- `review-documents-6.md`: a check of the six documents after the fourth check's changes.
  Two statements wrong and nine true only in a narrower form, each corrected, none of them
  about what the program does: the order in which an observer looks, and a sentence that
  had come to stand under the wrong paragraph.
- `review-change-6.md`: a check of the whole claim, looked at fresh, and of what the fifth
  led to. It ran some 21,000 single faults, 15,000 of them at instants between the gate's
  look and the writing of the record, and some 12,000 pairs of faults with a recorded round
  between, each beside a game that was never touched, with the observers together and each
  on a thread, and four long games. None was recorded as true, none lost the game, and none
  ended the program. It ran the program as built: 344 faults written at the backdoor with
  four threads asking, and 344 halts, each put right. What it found was in the tests and at
  the edges. The test of the two texts of the rules still passed when the second was handed
  the first's account of what was asked: it now fails. No test held one of the places that
  ask before they lean on eight observers, the look at seven parts, or a game put aside
  while the clock cannot be read: each has one now. A count put right by the gate at the
  start of a round was not said, and is. An observer's finding had no size, and one three
  million characters long was sent whole to every screen from then on: a finding is now cut
  where it is taken. It ran pairs of faults that are just outside what is held. Three with
  both faults in one halt, a round recorded between them: each lost the game. And 2,400
  with a halt each and no round recorded between, under the two settings where the round
  that ends a halt does no work: 169 lost the game. `observation.md` says so of both. And it found the backdoor's leaning on eight observers,
  as the check of the documents on the same version did.
- `review-documents-7.md`: a check of the six documents after the fifth check's changes.
  Two statements wrong and six true only in a narrower form. One of the six was about the
  program: the documents said every place that leaned on there being eight observers now
  asked first, and the backdoor did not. A line there with a count wrong stopped, and was
  refused, and a line kept for the work could stop a round. The backdoor now reads and
  writes nothing while the number of observers, or of an observer's copies, is wrong.
- `review-change-7.md`: a check of what the sixth led to, and of the backdoor while a count
  is wrong. It ran 7,424 placed lines and 60,000 random ones at the backdoor with a count
  wrong, at the console and kept for the work, some 110,000 lines with every count right,
  and 7,560 single faults and pairs in the program before and after the change, which came
  out the same line for line. None was recorded as true, none lost the game, none ended the
  program, and nothing stopped where it should not. What it found was at the edges and in
  the tests. A text made three million characters long by one fault, or a hundred thousand
  copies in one observer, was sent whole to every screen in every round for as long as the
  halt lasted: what a screen is sent of anything now has a size. The test of the two
  texts of the rules passed when the gate heeded only one of the two: it now gives the
  gate a round that only one text refuses, each way round. A text of the record gone after
  the work gave a reason that named an observer's copies: the reason now names the record.
  And it found that after a stop in the wrong place, with halts set to end at once, one
  recorded round before a second stop is not enough: the game is put aside, as
  `observation.md` says of a second stop before a round that began with nothing halted
  has been recorded. No fault of what is held causes a stop.
- `review-documents-8.md`: a check of the six documents after the sixth check's changes.
  One statement wrong and six true only in a narrower form. One of the six was about the
  program: a finding was cut at the first asking of a round, and not at the second, of the
  eight new observers when a halt is put right. It is now cut where an answer is taken
  from an observer's thread, which both go through. The rest were statements made too
  wide, each corrected: when a wrong number of an observer's copies is put right, which
  counts the backdoor asks about, and the order of this list.
- `review-change-8.md`: a check of what the seventh led to, and of the whole claim where it
  had been reached least. It ran 21,280 cases beside games that were never touched, among
  them faults part-way through the work, observers' threads that answer late, end, or say
  that the rounds have stopped, and a build that stops on whole-number overflow. None was
  recorded as true and none lost the game. It found one kind of single fault that ended the
  program: the moths made a million between two rounds, or half a million inside one. A
  round then took longer than five seconds to write them out, copy and compare them, the
  observers took the rounds to have stopped, and the program ended. What the game holds is
  now cut down to a size before a round looks at it, and such a fault is found like any
  other. It found seven ways the test of the two texts of the rules still passed with what
  it names broken: there are tests now for each. It found halts whose reason named
  something other than what went wrong. A count gone wrong since the gate looked, and a
  record changed after the work, are now said to be that, and an observer says which of its
  two counts it found wrong. Others it found are left as they are, and name what the gate found
  and not what went wrong. A leg too many or too few, or a moth too few in the gate's copy,
  landing after the gate's look, is refused as a step the rules do not allow. One thing
  too many in a list of what was asked is refused for what comes of it: a step the rules
  do not allow, or a second doing that comes out another way. And it counted what a screen
  can be sent at the very most: some eight million characters.
- `review-documents-9.md`: a check of the six documents after the seventh check's changes.
  No statement false of the program, and six true only in a narrower form, each corrected:
  what is sent whole to a screen, what a test asks of what is sent after a halt, which
  number of a moth is kept, and comments that said a wrong step within the rules is
  recorded as true, where the second doing of the work finds it.
- `review-change-9.md`: a check of what the eighth led to, and of the two upgrades' most.
  It ran 33,534 single faults and 15,876 pairs beside games that were never touched. None
  was recorded as true and none lost the game, and with nothing wrong the game was the
  same, round for round, as the version before. It found where the cutting down ends. The
  four points covered a fault that landed before one of them. A list made two million
  entries long that landed after the last of them, just before the record was written, or
  in the few steps after any of them, or between two rounds with a line at the backdoor
  arriving first, was still read whole: the round took more than five seconds and the
  program ended. There are now cuts before the record is written and when a line arrives
  at the backdoor. The few steps after a cut are left as they are: a list made millions of
  entries long is not one value changed, and is outside what is held, as
  `observation.md` says. It found the shop selling no more than the most of either
  upgrade in every order of asking it tried. It found four more ways the tests of the two
  texts of the rules passed with what they name broken, and things the test of the cutting
  down did not hold: there are tests now for each. And it found a count said twice where it
  was put right at the start of a round and again in the putting right: it is said once.
  Its forty for the upgrade for appetite is of the version it read: the most is now
  twenty-four.
- `review-documents-10.md`: a check of the six documents after the eighth check's changes.
  Two statements wrong and six true only in a narrower form. One was about the program:
  the documents said that nothing is done to the game's state in a halt that cannot be
  put right, and the cutting down did cut it there. It no longer does. One was about a test:
  taking the cut out at the start of a round was said to fail none, and it failed one by
  the time a round took. The rest were statements made too wide, each corrected.
- `review-change-10.md`: a check of what the ninth led to. It ran 40,896 single faults and
  9,000 pairs through the version it read and the one before, beside games that were never
  touched: none was recorded as true, none lost the game, and the two versions came out
  the same line for line. In halts that cannot be put right it ran rounds, the pointer,
  presses, upgrades, the setting and lines at the backdoor, and the state was byte for
  byte the same throughout. It found that nothing an ordinary game has is cut or changed. It found the
  edge of the cutting down again, for a text. In the steps after a cut, a text of 24
  million control characters, or the list of halted moths made 32 million commas in a game
  with many moths and clicks waiting, made a round take more than five seconds, and so did
  one such text followed by reads from thirty connections at the backdoor. A control
  character had been written out by a slow way, and is now written directly, and the work
  is handed no more of the list of halted moths than its first 20,480 characters. A text
  made long enough to do the same after that stays outside what is held, as a list of
  millions of entries does. And that check found five things the tests did not hold: there
  are tests now for each.
- `review-documents-11.md`: a check of the six documents after the ninth check's changes.
  Two statements wrong and two true only in a narrower form, all four about the test of
  the cutting down or about the backdoor, and none about what the program does. Each is
  corrected.
- `review-documents-12.md`: a check of the six documents after the tenth check's changes,
  made while the next check of a change was still out. No statement false of the program,
  and six true only in a narrower form, each corrected. It measured what is left of the
  edge for a text, now that a control character is written directly: 24 million of them
  cost a round a second and a half at the most, 64 million four and a half, and 96 million
  more than five.
- `review-documents-13.md`: a check of the corrections the twelfth led to, and of nothing
  else. Every corrected statement about the program was true. It found two sentences in
  this list wrong or loose, one phrase said too widely in several places, and five places
  where an old wording had been left: each is corrected.
- `review-documents-14.md`: a check of the corrections the thirteenth led to, and of
  nothing else. It found one statement that the two entries added to this list had made
  wrong, the old phrase left in one more comment, two comments looser than the
  corrections beside them, and that the phrase put in its place was true on every path
  but one, a stop in the wrong place during such a halt: each is corrected.
- `review-documents-15.md`: a check of the corrections the fourteenth led to, and of
  nothing else. One sentence they had added to the README disagreed with another line of
  it, and the exception they gave was too wide: a stop while a line is being done at the
  backdoor is caught, and leaves the game as it was. Two more comments had an "always"
  left in them. Each is corrected: the sentence is taken out, and the statement is now of
  what a round and what is asked of the game do in such a halt.
- `review-documents-16.md`: a check of the corrections the fifteenth led to, and of
  nothing else. No statement they added or altered was wrong. The old phrase was still in
  one paragraph of the README and in seven comments, and two corrected statements had
  lost a qualification they needed: each is corrected.
- `review-documents-17.md`: a check of the corrections the sixteenth led to, and of
  nothing else. Nothing they said was false of the program as it was meant. One sentence
  put into the middle of a paragraph had made the next one read of the wrong thing, the
  README still gave a stop in the wrong place more than it does, and four places had
  been left: each is corrected.
- `review-documents-18.md`: a check of the corrections the seventeenth led to, and of
  nothing else. Nothing they added or altered was wrong, and no correction had made a
  right statement wrong. Two comments and three lines of this list said a little more
  than the program or the corrections do: each is corrected.
- `review-change-11.md`: a check of what the tenth led to. It ran 121,836 single faults and
  9,000 pairs through the version it read and the one before, beside games that were never
  touched: none was recorded as true, none lost the game, and the two versions came out
  the same line for line. It found that a control character is written out the same as
  before and twenty times faster, and that in every game it played the work was handed
  the whole of the list of halted moths. It found the edge of the cutting down once more.
  Thirty thousand moths with numbers no moth has had, lying where a halted moth lies, in the
  gate's copy between the rules and the second doing of the work, cost a round nearly seven
  seconds with eight clicks waiting, because the second doing looks each moth up among the
  halted ones, and the program ended. There is now a cut at that place, and with more than
  1,024 moths nothing is said to be under the pointer. And it found seven things the tests
  did not hold: there are tests now for each.
- `review-documents-19.md`: a check of the updates the eleventh check of a change led to
  in these documents, and of nothing else. Nothing they added or altered was wrong. Two
  statements were true only in a narrower form than they were worded: each is corrected.
- `review-change-12.md`: a check of what the eleventh led to. It found nothing that needs
  a change to the code. It ran 88,095 single faults and 4,344 pairs through the version it
  read and the one before, beside games that were never touched: none was recorded as
  true, none lost the game or ended the program, and the two versions came out the same.
  Of 13,929 runs with something made too large, none came out wrong. It broke the code in
  a hundred ways against the three changed tests and found two breaks that a test names
  and lets by: the tests now hold each.
- `review-change-13.md`: a check of the lines of tests the twelfth led to, and of what
  these documents say of them, and of nothing else. It found nothing wrong. One break it
  tried, right at each number of moths at which the test asked what is under the pointer
  and wrong at larger ones, passed that test: the test now asks at a larger number too.
- `review-change-14.md`: a check of the case in a test the thirteenth led to, and of what
  these documents say of it, and of nothing else. It found nothing wrong in either. The
  entry above said a little more than is so: it is corrected. One change it tried passed
  the test, the number of moths heeded only where a moth is looked for, so that a leg
  would still be said: the test now puts the pointer on a leg too.
- `review-change-15.md`: a check of the case in a test the fourteenth led to, and of what
  these documents say of it, and of nothing else. It found nothing wrong, and no natural
  change of where or how the number of moths is heeded that the test lets by. Two
  wordings in the two entries above were not exact: they are corrected. It led to no
  change in the program or its tests.
- `review-documents-20.md`: a check of the corrections to these documents that no check
  had read. Nothing they added or altered was wrong, and no count disagreed. One sentence
  of the README said more than is so, one of `outside.md` had been left as it was, and
  one entry of this list had lost its verb: each is corrected.
- `review-documents-21.md`: a check of `proof.md`, and of what the README says of the
  proof, against the Lean statements and the records in `lean`, and of nothing else. One
  statement was wrong, four said more than is supported, and some things that are not
  shown were not named: each is corrected.

- The kit's ring map: the first pass of this repository's kit, run on the program by an
  orchestrator that was given only the kit and the code. The run was stopped after that
  pass, so its ring map is a first reading that no later pass verified, and it is not kept
  here. What it listed was checked by hand. Closed from it: the eight observers were one
  loop on one thread, and each is now on a thread of its own; a round that never returned
  had no observer, and the observers now stop the program; the count of legs was not looked
  at before the work, and is now part of what is watched; the number every signal is held to
  was one copy, and is now held more than once; a write made in a halt that cannot be put
  right was neither found nor put back, and is now refused; and six places where the
  documents and the code did not say the same. Left as it found it: that a flag written
  from outside is taken as a detection, which is what a flag is for. The gate's other
  bookkeeping, which it also listed, has since been put in three places.

The reviews of the single-fault claims and the thirty-six checks ran on Claude Fable 5.2, the
model the program was written with, so a mistake that model makes consistently would pass
them. The two reviews of the outside ran on a Claude Opus model.

The last check of a change led to no change in the program or its tests. Not every
correction made to these documents since they were last checked has been checked. No reviewer tried
the page in a browser, and none proved that the rules never refuse a right round.
