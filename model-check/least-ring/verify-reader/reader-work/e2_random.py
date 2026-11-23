"""Random executions against the three statements of results-minimal 4.3 marked Proved:
(1) G1 and G2 of a base scope are never violated and the scope closes in the first round in
which a fault lands in it; (2) G2 of an upper scope is never violated; (3) no spill.
Towers of 2, 3 and 4 levels, f = 1..3 (reads all) and f = 1 (reads two), freeze on and off."""
import sys, os, random, time
sys.path.insert(0, os.path.dirname(__file__))
from rmodel import Sys, bits
from tower import system


def run(levels, rname, work, f, freeze, n_exec, rounds, seed):
    s = Sys(system(levels, rname, work, f, scoped=True, freeze=freeze))
    rnd = random.Random(seed)
    MON = s.MON
    ns = s.ns
    base = [si for si in range(ns) if s.scopes[si].startswith("sD")]
    isbase = [s.scopes[si].startswith("sD") for si in range(ns)]
    viol = {"G1 base": 0, "G2 base": 0, "G2 upper": 0, "spill": 0, "base scope open after a fault landed": 0,
            "G1 upper": 0, "told": 0}
    nrounds = 0
    for _ in range(n_exec):
        alive, bad, present = s.present0 & MON, 0, s.present0
        fl = [0] * ns
        halted = 0
        closed = 0
        for rn in range(rounds):
            if any(fl[si] & alive & ~bad for si in range(ns)) and not ((present & ~MON) & ~halted):
                break
            frozen = 0
            if freeze:
                for si in range(ns):
                    if closed >> si & 1:
                        frozen |= s.members[si]
            e = (alive, bad, present)
            k = rnd.randint(1, f)
            landed = 0      # scopes in which a fault lands this round
            for _k in range(k):
                opts = s.env_steps(e, frozen)
                if not opts:
                    break
                ne = rnd.choice(opts)
                ch = (e[0] ^ ne[0]) | (e[1] ^ ne[1])
                for b in bits(ch):
                    landed |= 1 << s.scope_of[b.bit_length() - 1]
                e = ne
            a, b, p = e
            nrounds += 1
            pm = p & MON
            active = a & ~b & MON
            for xb in bits(b):
                x = xb.bit_length() - 1
                fl[s.scope_of[x]] |= s.chk[x] & active
            for pb in bits(pm & ~a):
                q = pb.bit_length() - 1
                fl[s.scope_of[q]] |= s.hb[q] & active
            out = [0] * ns
            for si in range(ns):
                cur = fl[si]
                if cur:
                    ch = True
                    while ch:
                        ch = False
                        for mb in bits(cur & active):
                            e_ = s.fwd[mb.bit_length() - 1] & active
                            if e_ & ~cur:
                                cur |= e_
                                ch = True
                    fl[si] = cur
                out[si] = fl[si] & a & ~b
            faulty = b | (pm & ~a)
            stepped = 0
            for wb in bits(p & ~MON & ~halted):
                w = wb.bit_length() - 1
                hi = s.halt[w] & pm
                sees = bool(hi & ~a) or any((s.covers[w] >> si & 1) and (hi & out[si]) for si in range(ns))
                if sees:
                    halted |= wb
                    if not any((s.covers[w] >> si & 1) and (s.members[si] & faulty) for si in range(ns)):
                        viol["spill"] += 1
                else:
                    stepped |= wb
            newclosed = closed
            for si in range(ns):
                if closed >> si & 1:
                    continue
                if s.members[si] & b:
                    if not out[si]:
                        viol["G1 base" if isbase[si] else "G1 upper"] += 1
                    if s.work[si] & stepped:
                        viol["G2 base" if isbase[si] else "G2 upper"] += 1
                    if (s.told[si] & a & ~b) and not (s.told[si] & out[si]):
                        viol["told"] += 1
                if out[si] and not (s.work[si] & p & ~halted):
                    newclosed |= 1 << si
            for si in base:
                if (landed >> si & 1) and not (newclosed >> si & 1):
                    viol["base scope open after a fault landed"] += 1
            closed = newclosed
            alive, bad, present = a, b, p
    return nrounds, viol


t0 = time.time()
tot = 0
for levels, n_exec, rounds in ((2, 6000, 6), (3, 3000, 8), (4, 600, 10)):
    for rname in ("flow", "actor"):
        for work, fs in (("all", (1, 2, 3)), ("two", (1,))):
            for f in fs:
                for freeze in (True, False):
                    nr, v = run(levels, rname, work, f, freeze, n_exec, rounds, seed=levels * 1000 + f * 10 + freeze)
                    tot += nr
                    print("levels %d %-5s reads %-3s f=%d freeze %-5s: %7d rounds | proved statements violated: %s | "
                          "(not claimed: G1 upper %d, told %d)" % (
                              levels, rname, work, f, freeze, nr,
                              {k: v[k] for k in ("G1 base", "G2 base", "G2 upper", "spill", "base scope open after a fault landed") if v[k]} or "none",
                              v["G1 upper"], v["told"]), flush=True)
print("total rounds", tot, "time %.0fs" % (time.time() - t0))
