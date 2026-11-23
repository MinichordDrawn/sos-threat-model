"""R3: the restart game of Restart.lean, played out on all 4,096 observer graphs of four
members with D the one member that can start first, against 'D reaches A, B and C'."""
import itertools

N = 4          # 0,1,2 = A,B,C ; 3 = D
D = 3
PAIRS = [(o, x) for o in range(N) for x in range(N) if o != x]     # o observes x


def settle(obs, R):
    F = 0
    ch = True
    while ch:
        ch = False
        for x in range(N):
            if x == D or (F >> x & 1):
                continue
            if all((F >> o & 1) for o in obs[x] if R >> o & 1):
                F |= 1 << x
                ch = True
    return R & ~F


def moves(obs, st, stops=True):
    run, blk = st
    out = []
    for m in range(N):
        b = 1 << m
        if run & b:
            if stops:
                out.append((settle(obs, run & ~b), blk | b))
        else:
            if blk & b:
                out.append((run, blk & ~b))
            elif m == D or any(run >> o & 1 for o in obs[m]):
                out.append((settle(obs, run | b), blk))
    return out


def can_always_restart(obs):
    init = ((1 << N) - 1, 0)
    seen = {init}
    todo = [init]
    while todo:
        s = todo.pop()
        for t in moves(obs, s):
            if t not in seen:
                seen.add(t)
                todo.append(t)
    for s in seen:
        if s[1]:
            continue
        ok = False
        seen2 = {s}
        todo = [s]
        while todo:
            u = todo.pop()
            if u[0] == (1 << N) - 1:
                ok = True
                break
            for t in moves(obs, u, stops=False):
                if t not in seen2:
                    seen2.add(t)
                    todo.append(t)
        if not ok:
            return False
    return True


def reaches_all(obs):
    watched_by = {o: [x for x in range(N) if o in obs[x]] for o in range(N)}
    seen = set()
    todo = [D]
    while todo:
        o = todo.pop()
        for x in watched_by[o]:
            if x not in seen:
                seen.add(x)
                todo.append(x)
    return all(x in seen for x in range(N) if x != D)


dis = 0
yes = 0
for mask in range(4096):
    obs = {x: [] for x in range(N)}
    for i, (o, x) in enumerate(PAIRS):
        if mask >> i & 1:
            obs[x].append(o)
    g = can_always_restart(obs)
    r = reaches_all(obs)
    yes += g
    if g != r:
        dis += 1
print("observer graphs: 4096; can always restart: %d; disagreements with 'D reaches every other member': %d" % (yes, dis))
