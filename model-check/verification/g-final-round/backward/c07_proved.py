"""The statements marked Proved, tested on random systems with the checker's own functions,
looking for counterexamples. Also the naming argument and the second face of P2."""
import itertools
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bw import cm, res  # noqa: E402

rng = random.Random(20261118)


def rand_system(plain=False, nmax=4, kmax=2):
    s = cm.System("rand", rng.choice((1, 1, 2, 3)))
    n = rng.randint(1, nmax)
    k = rng.randint(0 if not plain else 0, kmax)
    s.monitors = [f"M{i}" for i in range(1, n + 1)]
    s.works = [f"W{i}" for i in range(1, k + 1)]
    dens = rng.choice((0.3, 0.6, 0.9, 1.0))

    def pick(pool):
        return [m for m in pool if rng.random() < dens]
    for m in s.monitors:
        s.hb_readers[m] = pick(s.monitors)
        s.fwd[m] = pick(s.monitors)
        s.checkers[m] = pick(s.monitors)
    for w in s.works:
        s.checkers[w] = pick(s.monitors)
        s.halt_inputs[w] = pick(s.monitors)
    if plain:
        s.f = 1
        s.boundary = {m: i for i, m in enumerate(s.monitors)}
        return s
    if rng.random() < 0.4:
        s.joiner = "J"
        s.checkers["J"] = pick(s.monitors)
        s.halt_inputs["J"] = pick(s.monitors)
    s.boundary = {m: rng.randint(0, 2) for m in s.monitors if rng.random() < 0.8}
    s.substrate = {p: rng.choice("ab") for p in s.monitors + s.works if rng.random() < 0.4}
    s.switches = [m for m in s.monitors if rng.random() < 0.2]
    s.coupling = rng.random() < 0.6
    s.window = rng.choice((0, 0, 1))
    s.gate = rng.random() < 0.7
    s.slow_reports = rng.random() < 0.3
    return s


def one_round(system, steps):
    s = cm.initial(system)
    for e in steps:
        assert e in cm.env_steps(system, s), (e, system.as_data())
        s = cm.apply_env(system, s, e)
    return cm.process_phase(system, s)


def strip(s):
    s.substrate, s.switches = {}, []
    return s


# ---- Theorem 0.1
bad = n = 0
for _ in range(3000):
    s = rand_system()
    if s.f >= len(s.monitors) >= 1:
        n += 1
        t, info = one_round(s, [("mutate", m) for m in s.monitors])
        bad += not info["G1"]
print("T0.1 (f >= monitors >= 1 -> G1 violated in round 1):", n, "systems,", bad, "counterexamples")

# ---- Theorem 0.2: one step stops every monitor (all in one boundary), then mutate any process
bad = n = 0
for _ in range(3000):
    s = rand_system()
    if len(s.monitors) < 2:
        continue
    s.boundary = {m: "b" for m in s.monitors}
    n += 1
    st = cm.initial(s)
    st = cm.apply_env(s, st, ("stop-boundary", "b"))
    st, info1 = cm.process_phase(s, st)
    if cm.responded(s, st):
        bad += 1
        continue
    target = rng.choice([p for p in cm.present(s, st) if p not in st.bad] or [None])
    if target is None:
        continue
    st = cm.apply_env(s, st, ("mutate", target))
    st, info2 = cm.process_phase(s, st)
    bad += not (info1["G1"] or info2["G1"])
print("T0.2 (all monitors in one boundary -> G1 violated within 2 rounds):", n, "systems,", bad, "counterexamples")

# ---- P3: a monitor with no checker other than itself (no substrates or switches)
bad = n = 0
for _ in range(4000):
    s = strip(rand_system())
    z = rng.choice(s.monitors)
    s.checkers[z] = [z] if rng.random() < 0.5 else []
    n += 1
    t, info = one_round(s, [("mutate", z)])
    bad += not (info["G1"] and not t.flagged)
print("P3 (monitor with no other checker: bad and no flag):", n, "systems,", bad, "counterexamples")

# ---- P5 rate form: a set of at most f monitors checked by no monitor outside it
bad = n = 0
for _ in range(4000):
    s = strip(rand_system())
    size = rng.randint(1, min(s.f, len(s.monitors)))
    N = rng.sample(s.monitors, size)
    for z in N:
        s.checkers[z] = [m for m in s.checkers.get(z, []) if m in N]
    n += 1
    t, info = one_round(s, [("mutate", z) for z in N])
    bad += not (info["G1"] and not t.flagged)
print("P5 rate form (set of <= f monitors unchecked from outside: nothing flags):", n, "systems,", bad, "counterexamples")

# ---- P8b: a work process with at most f halt inputs keeps working after they are all mutated
bad = n = empty = 0
bad_stop = n_stop = 0
for _ in range(6000):
    s = strip(rand_system())
    if not s.works:
        continue
    w = rng.choice(s.works)
    h = rng.sample(s.monitors, rng.randint(0, min(s.f, len(s.monitors))))
    s.halt_inputs[w] = h
    if not h:
        empty += 1
        continue
    n += 1
    t, info = one_round(s, [("mutate", m) for m in h])
    bad += not (w in info["executed"] and info["G2"])
    # the README's wording, "faulted": the same with stops in place of mutations
    if s.coupling and s.gate and s.window == 0:
        n_stop += 1
        t, info = one_round(s, [("stop", m) for m in h])
        bad_stop += w in info["executed"]
print("P8b (<= f halt inputs, all mutated: w works, G2 violated):", n, "systems,", bad, "counterexamples;",
      empty, "with no halt input skipped")
print("   same with the halt inputs stopped instead (coupling, gate, no window):", n_stop,
      "systems; w keeps working in", bad_stop)

# ---- P8 window, the gate: at least one work process present from the start
for name, setup in (("window", lambda s: setattr(s, "window", 1)), ("no gate", lambda s: setattr(s, "gate", False))):
    bad = n = 0
    for _ in range(4000):
        s = rand_system()
        if not s.works:
            continue
        setup(s)
        n += 1
        w = rng.choice(s.works)
        t, info = one_round(s, [("mutate", w)])
        bad += not (info["G2"] and all(x in info["executed"] for x in s.works))
    print(f"{name}: mutate a work process -> every work process steps, G2 violated:", n, "systems,", bad, "counterexamples")
# joiner only, f = 1: the 'present from the start' condition is needed
s = cm.System("joiner only", 1)
s.monitors, s.joiner, s.window = ["M"], "J", 1
print("   window, joiner only, f=1:", res(s)[:2])

# ---- Theorem S on random plain systems
hold = fail = 0
cex = []
tries = 0
while hold + fail < 3000 and tries < 400000:
    tries += 1
    s = rand_system(plain=True, nmax=5)
    if not cm.sufficient_f1(s):
        continue
    g1, g2, _, _ = res(s)
    if g1 is None and g2 is None:
        hold += 1
    else:
        fail += 1
        cex.append(s.as_data())
print("Theorem S: plain f=1 systems meeting (a)-(d):", hold + fail, "| a judgement violated in", fail, cex[:1])

# ---- the mesh: holds exactly when f <= n - 1
out = []
for n_ in range(1, 6):
    for f in range(1, 5):
        g1, g2, _, _ = res(cm.mesh(n_, f))
        out.append(((g1 is None and g2 is None) == (f <= n_ - 1)))
print("mesh n=1..5, f=1..4: 'holds iff f <= n-1' true in", sum(out), "of", len(out))

# ---- 8.1: d further work steps when reports take a round (slow-plain, one mutate, then idle)
bad = n = undefined = 0
for _ in range(3000):
    s = rand_system(plain=True, nmax=5)
    if not s.works:
        continue
    s.slow_reports = True
    x = rng.choice(s.works)
    # d = least report hops from a checker of x to a halt input of x
    level = set(s.checkers.get(x, []))
    seen = set(level)
    d = None
    for hop in range(len(s.monitors) + 1):
        if seen & set(s.halt_inputs.get(x, [])):
            d = hop
            break
        nxt = {r for m in level for r in s.fwd.get(m, [])} - seen
        if not nxt:
            break
        seen |= nxt
        level = nxt
    st = cm.initial(s)
    st = cm.apply_env(s, st, ("mutate", x))
    steps = 0
    rounds = 0
    while rounds < len(s.monitors) + 3:
        if rounds and cm.responded(s, st):
            break
        st, info = cm.process_phase(s, st)
        rounds += 1
        steps += x in info["executed"]
    n += 1
    if d is None:
        undefined += 1
        bad += steps != rounds
    else:
        bad += steps != d
print("8.1 (bad work process takes d work steps):", n, "systems,", undefined, "with d undefined,", bad, "counterexamples")

# ---- naming the faulty monitors: a rule exists iff k >= 2f + 1


def rule_exists(k, f, faulty_may_name_self=False):
    profiles = {}
    mons = range(k)
    for size in range(0, f + 1):
        for F in itertools.combinations(mons, size):
            Fs = frozenset(F)
            choices = []
            for m in mons:
                if m in Fs:
                    pool = [x for x in mons if faulty_may_name_self or x != m]
                    choices.append([frozenset(c) for r in range(len(pool) + 1) for c in itertools.combinations(pool, r)])
                else:
                    choices.append([Fs])
            for prof in itertools.product(*choices):
                if profiles.setdefault(prof, Fs) != Fs:
                    return False
    return True


print("naming: (k, f, rule exists):", [(k, f, rule_exists(k, f)) for k, f in ((2, 1), (3, 1), (4, 1), (5, 1), (3, 2), (4, 2), (5, 2))])


# ---- P2, second face: W halts on M's silence once M has been silent for k rounds
def second_face(k, shared, substrate_stops_work, first_step):
    """M is W's only checker and only halt input. Rounds: env, monitor, work. Returns whether W
    takes a work step while bad within 4 rounds under the worst schedule that starts with
    first_step ('substrate' = M's substrate fails; 'stop' = M alone crashes)."""
    m_alive, w_bad, w_running, silent = True, False, True, 0
    violated = False
    for rnd in range(1, 5):
        if rnd == 1:
            m_alive = False
            if first_step == "substrate" and shared:
                if substrate_stops_work:
                    w_running = False
                else:
                    w_bad = True              # the model's fail-substrate: W goes bad, hidden
        elif rnd == 2 and w_running and not w_bad:
            w_bad = True                       # mutate W
        # monitor phase: M is stopped, nobody else checks W
        # work phase: W halts once M has been silent for k rounds (silent counts completed rounds)
        if w_running:
            if not m_alive and silent >= k:
                w_running = False
            elif w_bad:
                violated = True
        if not m_alive:
            silent += 1
    return violated


print("P2 second face (does W act while bad?):")
for k in (0, 1, 2, 3):
    print(f"   k={k}: separate substrates, M's substrate fails: {second_face(k, False, True, 'substrate')}"
          f" | one substrate, loss stops W too: {second_face(k, True, True, 'substrate')}"
          f" | one substrate, loss leaves W running and bad (the model's fail-substrate): {second_face(k, True, False, 'substrate')}"
          f" | one substrate, M alone crashes: {second_face(k, True, True, 'stop')}")
