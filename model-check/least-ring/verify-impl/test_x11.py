"""Checks of the program against what the specification says must hold.

1. X11: every case that is not scoped, given one scope for every process, must keep its
   G1 and G2; `freeze` must make no difference; adding `told` must change nothing else.
2. X10: a case with `max_rounds` N must agree with the same case without the bound, cut
   at N (compared only where the unbounded case finishes within the limits below).

Usage: python test_x11.py [workers]
"""
import copy
import json
import sys
import multiprocessing as mp
from model import solve, Unfinished


def x11(c):
    s = c['system']
    base = solve(s)
    procs = s['monitors'] + s['works'] + ([s['joiner']] if s['joiner'] else [])
    out = []
    n = 0
    for freeze in (False, True):
        for told in (False, True):
            t = copy.deepcopy(s)
            t['scope'] = {p: 'one' for p in procs}
            t['freeze'] = freeze
            if told:
                t['told'] = {'one': s['monitors'][:2]}
            r = solve(t)
            n += 1
            if (r['G1'], r['G2']) != (base['G1'], base['G2']) or \
                    (r['scopes']['one']['G1'], r['scopes']['one']['G2']) != (base['G1'], base['G2']):
                out.append('X11 DIFF %s freeze=%s told=%s %s %s' % (c['id'], freeze, told, base, r))
            if r['spill'] is not None:
                out.append('X11 spill in a one-scope system %s %s' % (c['id'], r))
    return n, out


def cut(v, n):
    return v if v is not None and v <= n else None


def bound(c):
    s = c['system']
    N = s['max_rounds']
    bounded = solve(s)
    t = dict(s)
    del t['max_rounds']
    st = {}
    try:
        free = solve(t, max_states=400000, max_seconds=90, stats=st)
    except Unfinished as e:
        return c['id'], 'skipped', str(e)
    exp = {'G1': cut(free['G1'], N), 'G2': cut(free['G2'], N)}
    if 'scopes' in free:
        exp['scopes'] = {k: {j: cut(x, N) for j, x in v.items()} for k, v in free['scopes'].items()}
        exp['spill'] = cut(free['spill'], N)
    return c['id'], 'same' if exp == bounded else 'DIFF', 'unbounded: %d states, depth %d' % (st['states'], st['depth'])


if __name__ == '__main__':
    workers = int(sys.argv[1]) if len(sys.argv) > 1 else 3
    cases = json.load(open('systems-minimal.json', encoding='utf-8'))
    with mp.Pool(workers) as pool:
        n1 = 0
        bad = 0
        for n, out in pool.imap_unordered(x11, [c for c in cases if not c['system'].get('scope')]):
            n1 += n
            bad += len(out)
            for line in out:
                print(line)
        print('X11: %d one-scope variants of the cases that are not scoped, %d differ' % (n1, bad), flush=True)
        res = list(pool.imap_unordered(bound, [c for c in cases if c['system'].get('max_rounds')]))
    same = [r for r in res if r[1] == 'same']
    diff = [r for r in res if r[1] == 'DIFF']
    skip = [r for r in res if r[1] == 'skipped']
    print('max_rounds: %d cases agree with their unbounded run cut at the bound, %d differ, '
          '%d not compared (unbounded run over the limits)' % (len(same), len(diff), len(skip)))
    for r in diff:
        print('   DIFF', r[0])
    for r in sorted(skip):
        print('   not compared:', r[0], r[2])
