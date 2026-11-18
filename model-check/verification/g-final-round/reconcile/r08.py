import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rc import *
print("[R with a one-round window, substrates shared: fail-substrate s1]")
r = cm.reference(without=("P8",))
rounds, why = cm.replay(r, [[("fail-substrate", "s1")], []]); cm.show(rounds)
print("[one monitor M and one work W on one substrate, window 1]")
s = cm.System("MW", 1); s.monitors = ["M"]; s.works = ["W"]; s.boundary = {"M": 0}
s.substrate = {"M": "s", "W": "s"}; s.checkers = {"W": ["M"]}; s.halt_inputs = {"W": ["M"]}; s.window = 1
rounds, why = cm.replay(s, [[("fail-substrate", "s")], []]); cm.show(rounds)
print("[same, no window: the round model's coupling is immediate]")
s.window = 0
rounds, why = cm.replay(s, [[("fail-substrate", "s")], []]); cm.show(rounds); print(why)

# threshold model of section 6, second face: W halts once M has been silent for k rounds.
def threshold(shared, k, loss_stops_work, schedule):
    """schedule: list of rounds, each a list of steps among 'lose-substrate', 'stop M', 'mutate W'.
    Returns the rounds in which W took a work step while bad."""
    m_alive, w_alive, w_bad, silent, halted, out = True, True, False, 0, False, []
    for i, steps in enumerate(schedule, 1):
        for st in steps:
            if st == "lose-substrate":      # M's substrate
                m_alive = False
                if shared:
                    if loss_stops_work: w_alive = False
                    else: w_bad = True
            elif st == "stop M": m_alive = False
            elif st == "mutate W": w_bad = True
        if not m_alive: silent += 1
        # W notices M's silence only after k rounds of it (k = 0: at once)
        if not m_alive and silent > k - 1 and k >= 1 and silent >= k: halted = True
        if k == 0 and not m_alive: halted = True
        if w_alive and not halted and w_bad: out.append(i)
    return out
for k in (1, 2, 3):
    print(f"k={k}",
          "| separate, lose M's substrate then mutate W:", threshold(False, k, True, [["lose-substrate"], ["mutate W"], []]),
          "| shared, loss stops both:", threshold(True, k, True, [["lose-substrate"], ["mutate W"], []]),
          "| shared, loss as in 2.2 (W bad, running):", threshold(True, k, False, [["lose-substrate"], [], []]),
          "| shared, crash of M alone then mutate W:", threshold(True, k, True, [["stop M"], ["mutate W"], []]))
