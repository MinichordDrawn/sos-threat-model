"""Faster randomised tests of E1, E2, E3, E5: the claims only need the result up to round 2
(E1) or round 1 (E2, E3, E5), so explore executions of at most that many rounds."""
import os
import random
import sys
from collections import deque

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import model  # noqa: E402
from test_claims import rand_system  # noqa: E402


def least_upto(system, limit):
    """Least violating round per goal among executions of at most `limit` rounds (None if none)."""
    S = model.norm(system)
    init = model.initial(S)
    depth = {init: 0}
    q = deque([init])
    res = {"G1": None, "G2": None}
    while q:
        st = q.popleft()
        d = depth[st]
        if d >= limit or model.responded(S, st):
            continue
        for s_env in model.env_reachable(S, st):
            s2, g1, g2, stepped, out = model.finish_round(S, s_env)
            if g1 and (res["G1"] is None or d + 1 < res["G1"]):
                res["G1"] = d + 1
            if g2 and (res["G2"] is None or d + 1 < res["G2"]):
                res["G2"] = d + 1
            if s2 not in depth:
                depth[s2] = d + 1
                q.append(s2)
    return res


def main(n):
    rng = random.Random(77)
    # E1
    hist, bad = {}, 0
    for _ in range(n):
        S = rand_system(rng, nmon=rng.randint(1, 4), nwork=rng.randint(0, 3), boundary="same")
        r = least_upto(S, 2)["G1"]
        key = (len(S["monitors"]), S["f"] if S["f"] < 2 else "2+", r)
        hist[key] = hist.get(key, 0) + 1
        if r not in (1, 2):
            bad += 1
            print("E1 FAIL", S)
    print("E1: %d systems (1..4 monitors, one shared boundary), failures %d" % (n, bad))
    print("    (monitors, f, G1) histogram:", sorted(hist.items(), key=str))
    # E2
    bad = 0
    for _ in range(n):
        S = rand_system(rng, nmon=rng.randint(0, 4), nwork=rng.randint(1, 3), window=1, gate=True)
        if least_upto(S, 1)["G2"] != 1:
            bad += 1
            print("E2 FAIL", S)
    print("E2: %d systems (window 1, gate true, works non-empty), failures %d" % (n, bad))
    # E3
    bad = 0
    for _ in range(n):
        S = rand_system(rng, nmon=rng.randint(0, 4), nwork=rng.randint(1, 3), gate=False)
        if least_upto(S, 1)["G2"] != 1:
            bad += 1
            print("E3 FAIL", S)
    print("E3: %d systems (gate false, works non-empty), failures %d" % (n, bad))
    # E5 as stated, and with the parenthesised restrictions and the halt_inputs condition dropped
    for general in (False, True):
        bad = done = 0
        while done < n:
            if general:
                S = rand_system(rng, nmon=rng.randint(0, 4), nwork=rng.randint(1, 3))
            else:
                S = rand_system(rng, nmon=rng.randint(1, 4), nwork=rng.randint(1, 3),
                                gate=True, window=0, slow_reports=False)
            mons = set(S["monitors"])
            ws = [w for w in S["works"]
                  if (general or S["halt_inputs"].get(w)) and not (set(S["checkers"].get(w, [])) & mons)]
            if not ws:
                continue
            done += 1
            if least_upto(S, 1)["G2"] != 1:
                bad += 1
                print("E5 FAIL", S)
        print("E5%s: %d systems, failures %d" % (
            " (any gate/window/slow_reports, halt_inputs may be empty)" if general else " as stated", n, bad))
    # Other readings: how often do they fail?
    cnt = tot = 0
    for _ in range(n):
        S = rand_system(rng, nmon=rng.randint(2, 3), nwork=rng.randint(0, 1), boundary="none")
        tot += 1
        if least_upto(S, 2)["G1"] not in (1, 2):
            cnt += 1
    print("E1 other reading (no monitor has a boundary): %d of %d systems have G1 > 2 or null" % (cnt, tot))
    cnt = tot = 0
    for _ in range(n):
        S = rand_system(rng, nmon=rng.randint(0, 3), nwork=0, joiner=True, window=1, gate=True)
        tot += 1
        if least_upto(S, 1)["G2"] != 1:
            cnt += 1
            assert S["f"] == 1, S
    print("E2 other reading (joiner is the only work process): %d of %d systems have G2 != 1, all with f = 1" % (cnt, tot))


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 5000)
