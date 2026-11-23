"""Random small systems that use every field of the three specification files (the
catalogue uses only some: it has no substrate, no switch, no joiner, no slow edge, no
window, and the gate everywhere). model.py and naive.py are run on each and compared.

Usage: python fuzz.py [count] [seed]
"""
import json
import random
import sys
from model import solve
from naive import Sys


def rand_system(rnd):
    nm = rnd.randint(2, 4)
    nw = rnd.randint(1, 2)
    mons = ['M%d' % i for i in range(1, nm + 1)]
    works = ['W%d' % i for i in range(1, nw + 1)]
    joiner = 'J' if rnd.random() < 0.3 else None
    nonmon = works + ([joiner] if joiner else [])
    procs = mons + nonmon

    def sub(lst, p):
        return [x for x in lst if rnd.random() < p]
    s = {
        'name': 'fuzz', 'f': rnd.randint(1, 3), 'monitors': mons, 'works': works, 'joiner': joiner,
        'boundary': {m: rnd.randint(1, 3) for m in mons if rnd.random() < 0.8},
        'substrate': {p: rnd.choice(['s1', 's2']) for p in procs if rnd.random() < 0.3},
        'hb_readers': {m: sub(mons, 0.5) for m in mons if rnd.random() < 0.9},
        'checkers': {p: sub(mons, 0.5) for p in procs if rnd.random() < 0.9},
        'fwd': {m: sub(mons, 0.5) for m in mons if rnd.random() < 0.9},
        'halt_inputs': {w: sub(mons, 0.6) for w in nonmon if rnd.random() < 0.95},
        'switches': sub(mons, 0.2),
        'coupling': rnd.random() < 0.7,
        'window': 1 if rnd.random() < 0.25 else 0,
        'gate': rnd.random() < 0.75,
        'slow_reports': rnd.random() < 0.25,
    }
    # late groups
    if rnd.random() < 0.6:
        cand = sub(mons, 0.4) + sub(works, 0.4) + ([joiner] if joiner and rnd.random() < 0.4 else [])
        rnd.shuffle(cand)
        groups = []
        while cand:
            k = rnd.randint(1, min(2, len(cand)))
            mem, cand = cand[:k], cand[k:]
            groups.append({'name': 'g%d' % len(groups), 'members': mem,
                           'after': sub(procs, 0.15)})
        if len(set(mons) - set(m for g in groups for m in g['members'])) == 0:
            groups = groups[:0]
        s['late'] = groups
        s['arrive_bad'] = rnd.random() < 0.5
        edges = [[r, k, m] for r in ('hb_readers', 'checkers', 'fwd', 'halt_inputs')
                 for k, lst in s[r].items() for m in lst]
        s['slow_edges'] = sub(edges, 0.25)
    if rnd.random() < 0.7:
        ids = ['a', 'b', 'c'][:rnd.randint(1, 3)]
        s['scope'] = {p: rnd.choice(ids) for p in procs}
        if rnd.random() < 0.5:
            s['scope_work'] = {i: sub(nonmon, 0.6) for i in ids + ['z'] if rnd.random() < 0.5}
        if rnd.random() < 0.7:
            s['told'] = {i: sub(mons, 0.4) for i in ids if rnd.random() < 0.7}
        s['freeze'] = rnd.random() < 0.5
    if rnd.random() < 0.3:
        s['max_rounds'] = rnd.randint(1, 3)
    return s


def norm(a):
    return json.dumps(a, sort_keys=True)


if __name__ == '__main__':
    count = int(sys.argv[1]) if len(sys.argv) > 1 else 300
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    rnd = random.Random(seed)
    diff = 0
    done = 0
    skipped = 0
    for i in range(count):
        s = rand_system(rnd)
        b = Sys(s).result(max_seconds=4)
        if b is None:
            # too large for the slow program: bound the rounds and try once more
            s['max_rounds'] = 2
            b = Sys(s).result(max_seconds=8)
        if b is None:
            skipped += 1
            continue
        a = solve(s)
        done += 1
        if norm(a) != norm(b):
            diff += 1
            print('DIFF on system', i)
            print(json.dumps(s))
            print(' model:', norm(a))
            print(' naive:', norm(b))
            if diff > 5:
                break
    print('%d random systems compared, %d differ, %d skipped (too large for naive.py even with max_rounds 2)' % (done, diff, skipped))
