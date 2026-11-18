import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rc import *
s = cm.nested(3, True, 1, ring_boundaries=True)
print("boundaries:", s.boundary)
rounds, why = cm.replay(s, [[("stop-boundary", "A")]]); cm.show(rounds); print(why)
print("who reads KA's signal:", s.hb_readers["KA"], "| who checks KA:", s.checkers["KA"])
m = cm.mesh(4, 1, one_boundary=True)
rounds, why = cm.replay(m, [[("stop-boundary", 0)], [("mutate", "W")]]); cm.show(rounds)
# section 4 execution
t = cm.mesh(3, 2, unread="M3")
rounds, why = cm.replay(t, [[("stop", "M3")], [("stop", "M1"), ("mutate", "M2")]]); cm.show(rounds)
# section 5 f=2 execution
r = cm.reference(f=2)
rounds, why = cm.replay(r, [[("mutate", "M1"), ("mutate", "M3")]]); cm.show(rounds)
# naming: 2f+1 check, k monitors, up to f faulty; correct monitors output exactly the faulty set; faulty output any subset of others
from itertools import combinations, product
def nameable(k, f):
    mons = range(k)
    profiles = {}
    for nf in range(0, f + 1):
        for F in combinations(mons, nf):
            Fs = frozenset(F)
            choices = []
            for m in mons:
                if m in Fs:
                    others = [x for x in mons if x != m]
                    choices.append([frozenset(c) for r in range(len(others) + 1) for c in combinations(others, r)])
                else:
                    choices.append([Fs])
            for prof in product(*choices):
                if profiles.setdefault(prof, Fs) != Fs:
                    return False
    return True
print("naming rule exists (k, f):", {(k, f): nameable(k, f) for f in (1, 2) for k in range(2, 6)})
