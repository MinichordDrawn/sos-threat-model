#!/usr/bin/env python3
"""mr_model.py against the join catalogue and its recorded answers.

Reads (and does not change) join\\systems-join.json and join\\results-join.json, runs
mr_model.explore on every case, and compares G1 and G2. With --stop-early semantics the
recorded answers are least numbers of rounds, which is what explore returns.

Run:  python -B mr_crosscheck.py
"""
import json
import os
import sys
import time

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
JOIN = os.path.join(os.path.dirname(HERE), "join")
sys.path.insert(0, HERE)
import mr_model as mm  # noqa: E402


def main():
    systems = json.load(open(os.path.join(JOIN, "systems-join.json"), encoding="utf-8"))
    answers = {a["id"]: a for a in
               json.load(open(os.path.join(JOIN, "results-join.json"), encoding="utf-8"))}
    t0 = time.time()
    bad = 0
    for i, case in enumerate(systems):
        r = mm.explore(case["system"], stop="both", max_states=400000)
        if r["bounded"]:
            print("BOUNDED", case["id"])
        a = answers[case["id"]]
        if (r["G1"], r["G2"]) != (a["G1"], a["G2"]):
            bad += 1
            print("DIFFERENT", case["id"], (r["G1"], r["G2"]), (a["G1"], a["G2"]))
    print(f"{len(systems)} cases, {bad} different, {time.time() - t0:.0f} s")


if __name__ == "__main__":
    main()
