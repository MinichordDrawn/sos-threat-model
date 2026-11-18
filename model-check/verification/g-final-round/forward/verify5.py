"""Forward verifier, fifth batch: the hop count of section 8.1 with and without further faults.
Run with python -I -B."""
import sys
import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, FM)
import check_model as cm

s = cm.System("chain c->p->q->h, slow reports", 1)
s.monitors = ["c", "p", "q", "h"]
s.works = ["W"]
s.boundary = {m: i for i, m in enumerate(s.monitors)}
s.checkers = {"W": ["c"]}
s.fwd = {"c": ["p"], "p": ["q"], "q": ["h"]}
s.halt_inputs = {"W": ["h"]}
s.slow_reports = True
print("d = 3 (c -> p -> q -> h); plain apart from slow reports:", cm.is_plain(s) is False)
for label, sched in (
        ("only the mutation", [[("mutate", "W")], [], [], [], []]),
        ("then stop the halt input in round 2", [[("mutate", "W")], [("stop", "h")], [], []]),
        ("then mutate the relay p in round 2", [[("mutate", "W")], [("mutate", "p")], [], [], [], [], []]),
        ("then stop the relay p in round 2", [[("mutate", "W")], [("stop", "p")], [], [], [], [], []])):
    rounds, why = cm.replay(s, sched)
    worked = [i for i, (_, info) in enumerate(rounds, 1) if "W" in info["executed"]]
    print(f"  {label}: W takes a work step in rounds {worked} ({why}, {len(rounds)} rounds run)")
