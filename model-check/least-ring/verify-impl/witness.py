"""Prints a shortest execution that violates one judgement of one case, with the
environment steps of each round, so that an answer can be checked by hand.

Usage:
    python witness.py systems-minimal.json CASE-ID JUDGEMENT [SCOPE] [--reading NAME]
    JUDGEMENT is G1, G2, told or spill; SCOPE is needed for G1, G2 and told of a scoped
    system.
"""
import json
import sys
from model import Model, bits


def labelled_env(M, S):
    """Like Model.env, but returns {environment outcome: tuple of step labels}. The step
    rules are written a second time here, with labels; main() checks that the outcomes
    are the same set as Model.env gives."""
    MON = M.MON
    name = M.procs
    frozen = 0
    if M.freeze and S[7]:
        for s in bits(S[7]):
            frozen |= M.scopemask[s]
            if 'freeze-by-cover' in M.readings:
                frozen |= M.workmask[s]
    start = S[:5]
    seen = {start: ()}
    level = [start]
    jb = M.joiner_bit if M.joiner_own_step else 0
    for _ in range(M.f):
        nxt = []

        def add(t, lab, pre):
            if t not in seen:
                seen[t] = seen[pre] + (lab,)
                nxt.append(t)
        for e in level:
            alive, bad, hidden, off, present = e
            for i in bits(alive & ~frozen):
                add((alive ^ (1 << i), bad, hidden, off, present), 'stop ' + name[i], e)
            for bm, bid in zip(M.boundaries, M.boundary_ids):
                pm = bm & present
                if pm & (pm - 1) and pm & alive & ~frozen:
                    add((alive & ~(pm & ~frozen), bad, hidden, off, present), 'stop-boundary %s' % (bid,), e)
            for sm, sid in zip(M.substrates, M.substrate_ids):
                pm = sm & present & ~frozen
                if (pm & MON & alive) or (pm & ~MON & ~bad):
                    nm = pm & ~MON
                    add((alive & ~pm, bad | nm, hidden | nm, off, present), 'fail-substrate %s' % (sid,), e)
            for i in bits(present & ~bad & ~frozen):
                add((alive, bad | (1 << i), hidden, off, present), 'mutate ' + name[i], e)
            for i in bits(M.switches & present & ~off & ~frozen):
                add((alive, bad, hidden, off | (1 << i), present), 'disable ' + name[i], e)
            if jb and not (present & jb) and not (jb & frozen):
                add((alive, bad, hidden, off, present | jb), 'join', e)
            for (mem, aft, mons), gname in zip(M.groups, M.group_names):
                if mem & present or (aft & present) != aft or mem & frozen:
                    continue
                a2 = alive | (mem & MON)
                p2 = present | mem
                add((a2, bad, hidden, off, p2), 'join ' + gname, e)
                if M.arrive_bad:
                    for b in mons:
                        add((a2, bad | b, hidden, off, p2),
                            'join-bad %s %s' % (gname, name[b.bit_length() - 1]), e)
        level = nxt
    return seen


def names(M, mask):
    return '{' + ', '.join(M.procs[i] for i in bits(mask)) + '}'


def describe(M, S):
    alive, bad, hidden, off, present, halted, pending, closed, fl = S
    parts = ['stopped ' + names(M, present & M.MON & ~alive), 'bad ' + names(M, bad)]
    if hidden:
        parts.append('hidden ' + names(M, hidden))
    if off:
        parts.append('off ' + names(M, off))
    for s, sid in enumerate(M.scope_ids):
        if fl[s]:
            parts.append('flagged%s %s' % ('' if sid is None else ' for ' + sid, names(M, fl[s])))
    parts.append('halted ' + names(M, halted))
    if pending:
        parts.append('pending ' + names(M, pending))
    if M.scoped:
        parts.append('closed {' + ', '.join(M.scope_ids[s] for s in bits(closed)) + '}')
    absent = ((1 << M.P) - 1) & ~present
    if absent:
        parts.append('absent ' + names(M, absent))
    return '; '.join(parts)


def witness(sysd, judgement, scope=None, readings=()):
    M = Model(sysd, readings)
    if judgement == 'spill':
        j = 3 * M.nS
    else:
        s = M.scope_ids.index(scope) if M.scoped else 0
        j = 3 * s + {'G1': 0, 'G2': 1, 'told': 2}[judgement]
    init = (M.alive0, 0, 0, 0, M.present0, 0, 0, 0, (0,) * M.nS)
    parent = {init: None}
    frontier = [init]
    n = 0
    while frontier:
        n += 1
        if M.max_rounds is not None and n > M.max_rounds:
            break
        nxt = []
        for S in frontier:
            envs = M.env(S)
            for E in envs:
                S2, v, responded = M.round(S, E)
                if v >> j & 1:
                    chain = [(S, E, S2)]
                    while parent[chain[0][0]] is not None:
                        P0, E0 = parent[chain[0][0]]
                        chain.insert(0, (P0, E0, chain[0][0]))
                    lines = ['%s violated in round %d' % (judgement + ('[%s]' % scope if scope else ''), n)]
                    for r, (A, EE, B) in enumerate(chain, 1):
                        lab = labelled_env(M, A)
                        assert set(lab) == set(M.env(A)), 'labelled steps disagree with Model.env'
                        lines.append('round %d: %s' % (r, ', '.join(lab[EE]) or '(no step)'))
                        lines.append('   after: ' + describe(M, B))
                    return n, lines
                if S2 not in parent:
                    parent[S2] = (S, E)
                    if not responded:
                        nxt.append(S2)
        frontier = nxt
    return None, ['no execution violates it']


def main(argv):
    readings = []
    while '--reading' in argv:
        i = argv.index('--reading')
        readings.append(argv[i + 1])
        del argv[i:i + 2]
    cases = {c['id']: c['system'] for c in json.load(open(argv[0], encoding='utf-8'))}
    scope = argv[3] if len(argv) > 3 else None
    n, lines = witness(cases[argv[1]], argv[2], scope, readings)
    print('\n'.join(lines))


if __name__ == '__main__':
    main(sys.argv[1:])
