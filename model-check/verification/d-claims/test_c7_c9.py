"""Checks for C7 (naming the faulty one) and C9 (growth against a spreading halt)."""
import itertools
import math


# ---------------- C7 ----------------

def c7_cases(k):
    """Yield (outputs tuple, required answer). Outputs are frozensets of monitor indices."""
    e = frozenset()
    yield tuple(e for _ in range(k)), "none"
    for j in range(k):
        others = [i for i in range(k) if i != j]
        for r in range(len(others) + 1):
            for sub in itertools.combinations(others, r):
                outs = [frozenset([j])] * k
                outs[j] = frozenset(sub)
                yield tuple(outs), j


def c7_rule_exists(k, ordered=True):
    need = {}
    clash = None
    for outs, ans in c7_cases(k):
        key = outs if ordered else tuple(sorted(tuple(sorted(o)) for o in outs))
        need.setdefault(key, set()).add(ans)
        if len(need[key]) > 1 and clash is None:
            clash = (key, need[key])
    return clash is None, clash, len(need)


def c7_rule(outs):
    """Return the monitor named by at least two outputs, else 'none'."""
    k = len(outs)
    named = [i for i in range(k) if sum(1 for o in outs if i in o) >= 2]
    if len(named) == 1:
        return named[0]
    return "none"


def test_c7():
    for k in range(2, 8):
        ex_o, clash_o, n_o = c7_rule_exists(k, True)
        ex_u, clash_u, n_u = c7_rule_exists(k, False)
        rule_ok = all(c7_rule(outs) == ans for outs, ans in c7_cases(k))
        print("C7 k=%d: rule exists (outputs labelled by sender)=%s, (unlabelled)=%s, named-by-two rule correct=%s" % (k, ex_o, ex_u, rule_ok))
        if clash_o:
            print("     clash (labelled):", [sorted(o) for o in clash_o[0]], "needs answers", clash_o[1])


# ---------------- C9 ----------------

def damage(n, c, h, reset_each_tick=False):
    good = n - 1
    bad_run = 1
    bad_total = 1
    F = 1
    ticks = 0
    while bad_run > 0:
        if reset_each_tick:
            F = 1
        for _ in range(h):
            running = good + bad_run
            k = min(c * F, running)
            hg = min(k, good)
            good -= hg
            bad_run -= (k - hg)
            F = k
        s = min(bad_run, good)
        bad_run += s
        good -= s
        bad_total += s
        ticks += 1
        assert ticks < 10 ** 7
    assert good == 0
    return bad_total


def clog2(n):
    return (n - 1).bit_length()  # exact ceil(log2 n) for n >= 1


def test_c9():
    # (i)
    worst = None
    for n in range(2, 4001):
        for h in list(range(1, 41)) + [n - 1, n, 10 * n]:
            if h < 1:
                continue
            d = damage(n, 1, h)
            bound = n - h * (clog2(n) + 1)
            slack = d - bound
            if worst is None or slack < worst[0]:
                worst = (slack, n, h, d, bound)
            if d < bound:
                print("C9(i) COUNTEREXAMPLE n=%d h=%d damage=%d bound=%d" % (n, h, d, bound))
                return
            # also the sharper bound from the proof
            assert d >= n - h * clog2(n), (n, h, d)
    print("C9(i): n=2..4000, h=1..40 and h in {n-1,n,10n}: holds; least slack damage-bound = %d at n=%d h=%d (damage %d, bound %d)" % worst)

    # (ii)
    worst = None
    for n in range(4, 300001):
        d = damage(n, 2, 2)
        if d * d > 4 * n:
            print("C9(ii) COUNTEREXAMPLE n=%d damage=%d" % (n, d))
            return
        assert 2 * d * d <= n or d == 1, (n, d)  # sharper: damage <= max(1, sqrt(n/2))
        ratio = d / math.sqrt(n)
        if worst is None or ratio > worst[0]:
            worst = (ratio, n, d)
    print("C9(ii): n=4..300000: holds; largest damage/sqrt(n) = %.4f at n=%d (damage %d)" % worst)
    for m in range(19, 61):
        n = 2 ** m + 7
        d = damage(n, 2, 2)
        assert d * d <= 4 * n
    print("C9(ii): also n = 2^m + 7, m=19..60: holds")

    # (iii)
    allq = True
    for m in range(3, 61):
        n = 2 ** m
        d = damage(n, 2, 1)
        if not (n // 8 <= d <= n // 2):
            print("C9(iii) COUNTEREXAMPLE n=2^%d damage=%d" % (m, d))
            return
        if d != n // 4:
            allq = False
    print("C9(iii): n=2^3..2^60: holds; damage == n/4 in every case: %s" % allq)

    # other reading: F starts again at 1 in every tick
    bad2 = next((n for n in range(4, 5000) if damage(n, 2, 2, True) ** 2 > 4 * n), None)
    bad3 = next((2 ** m for m in range(3, 30) if not (2 ** m // 8 <= damage(2 ** m, 2, 1, True) <= 2 ** m // 2)), None)
    print("Other reading (F reset to 1 each tick): (ii) first failing n = %s (damage %s); (iii) first failing n = %s (damage %s)" % (
        bad2, damage(bad2, 2, 2, True) if bad2 else None, bad3, damage(bad3, 2, 1, True) if bad3 else None))
    ok_i = all(damage(n, 1, h, True) == damage(n, 1, h) for n in range(2, 300) for h in range(1, 12))
    print("Other reading leaves (i) unchanged (c=1, F is always 1): %s" % ok_i)


if __name__ == "__main__":
    test_c7()
    test_c9()
