"""Forty monitors with scopes: every execution in which the faults are confined to one chain
(ring 1's four monitors and W1, the neighbouring coordinator D2, the middle coordinators E1 and
E2, and T).  A bounded, restricted search: it leaves out every execution with a fault elsewhere."""
import sys, os, time
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys
from tower import system

SLICE = ["A1", "B1", "C1", "D1", "W1", "D2", "D3", "E1", "E2", "T"]


class Sliced(Sys):
    def set_slice(self, names):
        self.smask = 0
        for x in names:
            self.smask |= 1 << self.idx[x]

    def env_steps(self, e, frozen):
        return Sys.env_steps(self, e, frozen | (self.ALL & ~self.smask))


for rn in ("flow", "actor"):
    for work, f, mr in (("all", 3, 2), ("all", 2, 3), ("all", 1, 5), ("two", 1, 5)):
        for freeze in (True, False):
            t0 = time.time()
            s = Sliced(system(3, rn, work, f, scoped=True, freeze=freeze, max_rounds=mr))
            s.set_slice(SLICE)
            r = s.solve_scoped(state_limit=1500000)
            base = [k for k in r["scopes"] if k.startswith("sD")]
            up = [k for k in r["scopes"] if not k.startswith("sD")]

            def least(keys, j):
                vs = [r["scopes"][k][j] for k in keys if r["scopes"][k][j] is not None]
                return min(vs) if vs else None
            print("forty, %s, reads %s, f=%d, freeze %s, at most %d rounds, faults in the chain only: G1 base %s | G2 base %s | "
                  "G2 upper %s | spill %s | (not claimed: G1 upper %s, told %s) | states %d complete %s [%.0fs]" % (
                      rn, work, f, freeze, mr, least(base, "G1"), least(base, "G2"), least(up, "G2"), r["spill"],
                      least(up, "G1"), r["told"], r["states"], r["complete"], time.time() - t0), flush=True)
