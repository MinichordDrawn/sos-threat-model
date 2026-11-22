# One Spider: What It Takes From Outside

What the program takes from outside itself, and the size of each thing. This is the edge
of the scope that [README.md](README.md) describes, seen from the network.

The program listens on this machine only, answers only to its own two names, and takes a
request that changes anything only from a sender that says it is the page it served: what is
compared is a header the sender writes. A request that a browser says comes from another
site is refused, whatever it asks for: the page, the stream of the game and the plans of the
webs too. Beyond that, everything the program takes has a size, so that nothing sent to it
can make it grow or wait without end. The numbers are this program's own.

| What | The most |
| --- | --- |
| a line of a request | 8,192 bytes |
| the headers of a request | 64 |
| what a request carries | 65,536 bytes |
| a request, from its first character to its last | 10 seconds, and then the connection is given up |
| a connection on which nothing is asked | 15 seconds, and then it is closed |
| a write that has not gone out | 10 seconds, and then the connection is given up |
| connections served at once | 32 |
| screens sent the game at once | 8 |
| connections held in all, with those put out and not yet gone | 256 |
| things in one line at the backdoor | 32 |
| the answer to one line at the backdoor | 64,000 bytes: it is cut there, and the rest of the line is not done. That both happened is said on top of that |
| a text written at the backdoor | 1,024 characters |
| a line kept to be written during the work | 1,024 characters |
| lines kept to be written during the work, waiting at once | 8 |
| what is kept of the lines let through, to be said | 200 characters |
| an observer's name, list or reason, as a screen is sent it | 160 characters |
| moths, for one more to be put in at the backdoor | 64 |
| the wait for the observers' answers, each round | 8 waits of 5 thousandths of a second with no answer, and then one that has not answered is silent; 22 waits at the very most for one asking, whatever arrives, and a round that puts a halt right asks twice |
| rounds that do not end | 5 seconds, and then, when two observers have found it, the program stops |

When a connection comes and all 32 places are taken, the newest is the one that is taken.
The connection that has waited longest with nothing of its own being answered is put out
for it, or, if every one is being answered, the one that has been answered longest. A
screen is not put out for a connection. It is the same with screens: a ninth is sent the game, and the one that has been
sent it longest is put out. So a page that has lost its place has it back by asking again,
and the page does ask again, a second later. A page whose "Put it right" or any other
button is not taken says so at the backdoor.

A connection that has been put out is not always gone at once: one that was waiting, or
that the program was waiting to write to, may take as long as that wait was allowed to
be. It keeps no place among the 32 or the 8 while it goes. The program counts those too,
and while it holds 256 in all it takes no more. That clears in fifteen seconds at most. A
program on this machine that opens connections faster than that can crowd the page out
for as long as it keeps on.

The one argument the program takes is its port: digits, and not 0. Anything else, and
anything given after it, is refused, and the program does not start. Nor does it start if,
as it was built, two copies of the observers' rule are one function, or the work and its
second doing, or the two texts of the rules of the game, are called by the same ones. A connection on which a wait cannot be set is not served.

Every answer is sent with headers that keep another site from putting the page in a frame or
loading anything from here. A link to the page from another site, or from another port of
this machine, is refused like any other request from there: the address has to be typed, or
kept as a bookmark.

A refusal is given time to arrive. What the other side is still sending is read, for half a
second at most, before the connection is closed. The refusals given before a connection is
taken are not heard out: the one given while 256 are held, and the one given when no place
can be made.

If the program stops where it should not have (a panic) while the backdoor is doing a line that has just arrived,
the line is refused, and whatever it had written by then is found in the next round like any
other write. If it stops while the game's own work is being done, that is once a halt like
any other, and twice with no round between that began with nothing halted and was recorded, or once in
a halt that already cannot be put right, a halt that cannot be put right (see
"How a halt ends" in [observation.md](observation.md)). Neither is the end of the program.
If it stops again while putting that game aside, or the rounds come to an end
for any other reason, the whole program stops, whether or not it can say so: a screen then
says the server is silent, and it is.
