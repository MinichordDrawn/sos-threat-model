"""Runs the examples of J8 (built here from the text of J8) and of X13 (the cases
example/1 to example/9 of systems-minimal.json, against the results written in X13)."""
import json
import sys
from model import solve

READINGS = tuple(sys.argv[1:])
ok = True


def check(label, got, want):
    global ok
    good = got == want
    ok = ok and good
    print('%-4s %s' % ('ok' if good else 'DIFF', label))
    if not good:
        print('     spec says :', json.dumps(want, sort_keys=True))
        print('     program   :', json.dumps(got, sort_keys=True))


# ---------------------------------------------------------------- J8
def j8(n_edges, slow, arrive_bad, f):
    ms = ['M1', 'M2', 'M3', 'M4']
    others = {m: [x for x in ms if x != m] for m in ms}
    s = {
        'name': 'J8', 'f': f, 'monitors': ms + ['N'], 'works': ['W'], 'joiner': None,
        'boundary': {'M1': 1, 'M2': 2, 'M3': 3, 'M4': 4, 'N': 5}, 'substrate': {},
        'hb_readers': dict(others), 'checkers': dict(others, W=list(ms)), 'fwd': dict(others),
        'halt_inputs': {'W': list(ms)}, 'switches': [], 'coupling': True, 'window': 0,
        'late': [{'name': 'N', 'members': ['N']}], 'arrive_bad': arrive_bad, 'slow_edges': [],
    }
    if n_edges:
        s['checkers']['N'] = ['M1']
        if slow:
            s['slow_edges'] = [['checkers', 'N', 'M1']]
    return s


N_ = {'G1': None, 'G2': None}
for f in (1, 2, 3):
    check('J8.1 arrive_bad f=%d' % f, solve(j8(True, False, True, f), READINGS), N_)
check('J8.2 no arrive_bad f=1', solve(j8(False, False, False, 1), READINGS), {'G1': 2, 'G2': 2})
check('J8.2 arrive_bad f=1', solve(j8(False, False, True, 1), READINGS), {'G1': 1, 'G2': 1})
check('J8.3 no arrive_bad f=1', solve(j8(True, True, False, 1), READINGS), N_)
check('J8.3 no arrive_bad f=2', solve(j8(True, True, False, 2), READINGS), {'G1': 1, 'G2': 1})
check('J8.3 arrive_bad f=1', solve(j8(True, True, True, 1), READINGS), {'G1': 1, 'G2': 1})

# ---------------------------------------------------------------- X13
cases = {c['id']: c['system'] for c in json.load(open('systems-minimal.json', encoding='utf-8'))}


def sc(g1, g2, told):
    return {'G1': g1, 'G2': g2, 'told': told}


def whole(scopes, spill):
    def least(k):
        v = [x[k] for x in scopes.values() if x[k] is not None]
        return min(v) if v else None
    return {'G1': least('G1'), 'G2': least('G2'), 'scopes': scopes, 'spill': spill}


want = {
    'example/1': whole({'p': sc(None, None, 2), 'q': sc(None, None, 2)}, None),
    'example/2': whole({'p': sc(2, 1, 1), 'q': sc(2, 1, 1)}, None),
    'example/3': {'G1': None, 'G2': None},
    'example/4': whole({'p': sc(None, None, 2), 'q': sc(None, None, 2)}, 1),
    'example/5': whole({'p': sc(None, None, 2), 'q': sc(None, None, 2),
                        'top': sc(None, None, None)}, None),
    'example/6': whole({'p': sc(3, 1, 1), 'q': sc(3, 1, 1), 'top': sc(2, 2, None)}, None),
    'example/9': whole({'p': sc(None, 1, 1), 'q': sc(None, 1, 1),
                        'top': sc(None, None, None)}, None),
    'example/7': whole({'ring': sc(None, None, 1)}, None),
    'example/8': whole({'ring': sc(None, None, None)}, None),
}
for cid in sorted(want):
    check(cid + '  (' + cases[cid]['name'] + ')', solve(cases[cid], READINGS), want[cid])

# ---------------------------------------------------------------- the text of X13 against the cases
# The cases example/1..9 are taken from the catalogue; these are a few checks that they are
# the systems X13 describes (so that a disagreement is not a disagreement about the system).
e1 = cases['example/1']
assert e1['f'] == 1 and e1['told'] == {'p': ['Q1', 'Q2'], 'q': ['P1', 'P2']}
assert cases['example/2']['f'] == 2
assert 'scope' not in cases['example/3'] or not cases['example/3']['scope']
assert 'P1' in cases['example/4']['halt_inputs']['WQ']
assert cases['example/6'].get('freeze') is True and cases['example/6']['f'] == 2
assert cases['example/9'].get('max_rounds') == 1
print('ALL REPRODUCED' if ok else 'SOME DIFFER')
