"""Section 8.1's proved statement: what it needs besides 'reports take a round'."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bw import cm  # noqa: E402


def chain(window=0):
    s = cm.mesh(3, 1)
    s.checkers["W"] = ["M1"]
    s.halt_inputs = {"W": ["M3"]}
    s.fwd = {"M1": ["M2"], "M2": ["M3"], "M3": []}
    s.slow_reports = True
    s.window = window
    return s


def steps_of_w(system, schedule):
    st = cm.initial(system)
    n = 0
    for rnd in schedule:
        if cm.responded(system, st):
            break
        for e in rnd:
            assert e in cm.env_steps(system, st)
            st = cm.apply_env(system, st, e)
        st, info = cm.process_phase(system, st)
        n += ("W" in info["executed"]) and bool(info["bad"])
    return n


print("d = 2 (M1 -> M2 -> M3). Work steps of W while bad:")
print("  mutate W, then nothing:            ", steps_of_w(chain(), [[("mutate", "W")], [], [], [], []]))
print("  mutate W, then stop M3 in round 2: ", steps_of_w(chain(), [[("mutate", "W")], [("stop", "M3")], [], [], []]))
print("  mutate W, then mutate M2 in round 2:", steps_of_w(chain(), [[("mutate", "W")], [("mutate", "M2")], [], [], [], []]))
print("  with a window of one round:        ", steps_of_w(chain(1), [[("mutate", "W")], [], [], [], []]))
