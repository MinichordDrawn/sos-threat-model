"""Last check, script 7: the four script defects pass B listed (D1 to D4) and the one
left standing (D5), tried on the current check_model.py.

Run: python -I -B lc07_b_defects.py
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
FOLDER = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, FOLDER)
import check_model as cm  # noqa: E402

# D1: a joiner whose name is falsy still gets the join step
s = cm.mesh(2)
s.joiner = 0
print("D1 join offered to a joiner named 0:", ("join", 0) in cm.env_steps(s, cm.initial(s)))
# D2: replay stops at a complete response
rounds, why = cm.replay(cm.reference(), [[("stop", "M1")], [("mutate", "W1")]])
print("D2 replay of P1's schedule in full R:", why, "after", len(rounds), "round(s)")
# D3: a string argument names one property
r = cm.reference(without="P8b")
print("D3 reference(without='P8b'):", r.name, "| window", r.window, "| halt inputs", r.halt_inputs)
# D4: unread_extra with P3 removed
try:
    r = cm.reference(without=("P3",), unread_extra=True)
    print("D4 no KeyError; checkers:", r.checkers)
except KeyError as exc:
    print("D4 KeyError", exc)
# D5: no validation: window 2 acts as 1, f = 0 is accepted
r = cm.reference()
r.window = 2
first, _ = cm.explore(r)
print("D5 window=2:", {g: (len(p) if p else None) for g, p in first.items()},
      "| window=1:", {g: (len(p) if p else None) for g, p in cm.explore(cm.reference(without=('P8',)))[0].items()})
first, states = cm.explore(cm.reference(f=0))
print("D5 f=0 accepted:", {g: (len(p) if p else None) for g, p in first.items()}, states, "state(s)")
