"""Replay of every round-by-round table in the two write-ups, through the reader's model."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys
from ring import *
from tower import system
from grow import grow_system

NODES = ["A", "B", "C", "D"]
CAND = [("A", "B"), ("B", "C"), ("C", "A"), ("D", "A"), ("D", "B"), ("D", "C"), ("A", "D"), ("B", "D"), ("C", "D")]


def ring_sys(arrows, rname, work, f, scoped=True):
    hb, chk, fwd = edges_of(arrows, READINGS[rname])
    return Sys(make_system(NODES, hb, chk, fwd, work, f, "D", "A", scoped=scoped))


def run(title, s, rounds):
    print("=" * 100)
    print(title)
    try:
        s.replay(rounds)
    except AssertionError as e:
        print("  !!! NOT A LEGAL EXECUTION:", e)


for rn in ("flow", "actor"):
    run("part-a 2.1: candidate, %s, W reads two, f=2" % rn, ring_sys(CAND, rn, "two", 2),
        [[("mutate", "A"), ("mutate", "D")]])

w8 = [("A", "B"), ("A", "D"), ("B", "A"), ("B", "D"), ("C", "A"), ("C", "D"), ("D", "A"), ("D", "B")]
run("part-a 2.2: flow, eight-connection wiring, W reads all, f=3", ring_sys(w8, "flow", "all", 3),
    [[("mutate", "A"), ("mutate", "B"), ("mutate", "D")]])

for rn in ("flow", "actor"):
    run("rm 4.1 (a): tower one system, %s, reads all, f=4" % rn, Sys(system(2, rn, "all", 4)),
        [[("mutate", "A1"), ("mutate", "B1"), ("mutate", "C1"), ("mutate", "D1")]])
    run("rm 4.1 (b): tower one system, %s, ring boundaries, f=4" % rn,
        Sys(system(2, rn, "all", 4, ring_boundaries=True)),
        [[("stopb", ["A1", "B1", "C1", "D1"]), ("stopb", ["A2", "B2", "C2", "D2"]),
          ("stopb", ["A3", "B3", "C3", "D3"]), ("mutate", "T")]])

for fr in (True, False):
    run("rm 4.1 (c): flow, without T->D1, scopes, f=1, freeze=%s" % fr,
        Sys(system(2, "flow", "all", 1, scoped=True, freeze=fr, remove=[("T", "D1")])),
        [[("stop", "D3")], [("mutate", "T")]])

for rn in ("flow", "actor"):
    for fr in (True, False):
        run("rm 4.3 (a): scopes, %s, f=2, freeze=%s: G1 of top" % (rn, fr),
            Sys(system(2, rn, "all", 2, scoped=True, freeze=fr)),
            [[("stop", "D1"), ("stop", "D2")], [("stop", "D3"), ("mutate", "T")]])
        run("rm 4.3 (b): scopes, %s, f=2, freeze=%s: told of ring 1" % (rn, fr),
            Sys(system(2, rn, "all", 2, scoped=True, freeze=fr)),
            [[("stop", "D2")], [("stop", "T"), ("mutate", "A1")]])
    run("rm 4.3 (b'): scopes, %s, f=3: the same three steps in one round" % rn,
        Sys(system(2, rn, "all", 3, scoped=True, freeze=True)),
        [[("stop", "D2"), ("stop", "T"), ("mutate", "A1")]])
    run("rm 4.3 (c): scopes, %s, f=4" % rn, Sys(system(2, rn, "all", 4, scoped=True, freeze=True)),
        [[("mutate", "A1"), ("mutate", "B1"), ("mutate", "C1"), ("mutate", "D1")]])
    run("rm 4.3 (d): scopes, %s, ring boundaries, freeze, f=2" % rn,
        Sys(system(2, rn, "all", 2, scoped=True, freeze=True, ring_boundaries=True)),
        [[("stopb", ["A1", "B1", "C1", "D1"]), ("stopb", ["A2", "B2", "C2", "D2"])],
         [("stopb", ["A3", "B3", "C3", "D3"]), ("stop", "T")], [("mutate", "W3")]])
    run("rm 4.6: forty monitors, scopes, %s, freeze, f=1" % rn,
        Sys(system(3, rn, "all", 1, scoped=True, freeze=True)),
        [[("stop", "D1")], [("stop", "E1")], [("mutate", "A3")]])

for sc in (False, True):
    run("rm 5.1 (a): author order, flow, f=1, scoped=%s" % sc,
        Sys(grow_system("author", "flow", 1, scoped=sc)), [[("joinbad", ["D2"], "D2")]])
    run("rm 5.1 (b): author order, actor, f=1, scoped=%s" % sc,
        Sys(grow_system("author", "actor", 1, scoped=sc)),
        [[("join", ["D2"])], [("joinbad", ["A2"], "A2")]])
run("rm 5.1 (c): author order, actor, scopes, freeze, f=1",
    Sys(grow_system("author", "actor", 1, scoped=True)),
    [[("join", ["D2"])], [("join", ["A2"])], [("join", ["B2"])], [("join", ["C2"])], [("join", ["W2"])],
     [("stop", "D2")], [("joinbad", ["D3"], "D3")], [("joinbad", ["A3"], "A3")],
     [("joinbad", ["B3"], "B3")], [("joinbad", ["C3"], "C3")], [("join", ["W3"])]])

# 5.3: N with no connection
for rn in ("flow", "actor"):
    hb, chk, fwd = edges_of(CAND, READINGS[rn])
    d = make_system(NODES + ["N"], hb, chk, fwd, "all", 1, "D", "A", scoped=True)
    d["checkers"]["W"] = list(NODES); d["halt_inputs"]["W"] = list(NODES)
    d["late"] = [{"name": "N", "members": ["N"]}]
    d["arrive_bad"] = True
    run("rm 5.3: N with no connection, %s, f=1" % rn, Sys(d), [[("joinbad", ["N"], "N")]])
