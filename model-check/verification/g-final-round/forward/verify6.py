"""Forward verifier, sixth batch: R without the gate, round by round. Run with python -I -B."""
import sys
import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, FM)
import check_model as cm

r = cm.reference(without=("gate",))
s0 = cm.initial(r)
print("R without the gate: every first-round environment choice")
for steps, after in cm.env_choices(r, s0):
    t, info = cm.process_phase(r, after)
    print(f"  {str(steps):<32} bad={info['bad']} flagged={info['out']} halted={info['halted']} "
          f"worked={info['executed']} complete-response={cm.responded(r, t)}")
# every reachable round in which the set of bad processes grows: is the state after it ever responded?
from collections import deque
seen = {s0}
q = deque([s0])
grow_resp = grow = 0
while q:
    s = q.popleft()
    if cm.responded(r, s):
        continue
    for steps, after in cm.env_choices(r, s):
        t, info = cm.process_phase(r, after)
        if len(after.bad) > len(s.bad):
            grow += 1
            if cm.responded(r, t):
                grow_resp += 1
                if grow_resp <= 3:
                    print("  a round in which a state goes bad and the response is complete:", steps, info)
        if t not in seen:
            seen.add(t)
            q.append(t)
print("rounds in which a state goes bad:", grow, "; of which end in a complete response:", grow_resp, "; states", len(seen))
