"""Hand-derived expectations for the reference implementation (model.py).

Each expected value was worked out on paper from model-spec.md before the code was run.
Run:  python -I test_model.py
"""
import copy
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))  # python -I drops the script folder
from model import result

PAIR = {
    "name": "pair", "f": 1, "monitors": ["a", "b"], "works": ["w"], "joiner": None,
    "boundary": {"a": "ba", "b": "bb"}, "substrate": {},
    "hb_readers": {"a": ["b"], "b": ["a"]},
    "checkers": {"a": ["b"], "b": ["a"], "w": ["a"]},
    "fwd": {}, "halt_inputs": {"w": ["a", "b"]},
    "switches": [], "coupling": True, "window": 0,
}

RING3 = {
    "name": "ring3", "f": 1, "monitors": ["a", "b", "c"], "works": ["w"], "joiner": None,
    "boundary": {"a": 1, "b": 2, "c": 3}, "substrate": {},
    "hb_readers": {"a": ["b", "c"], "b": ["a", "c"], "c": ["a", "b"]},
    "checkers": {"a": ["b", "c"], "b": ["a", "c"], "c": ["a", "b"], "w": ["a"]},
    "fwd": {"a": ["b"], "b": ["c"], "c": ["a"]}, "halt_inputs": {"w": ["b", "c"]},
    "switches": [], "coupling": True, "window": 0,
}


def variant(base, **kw):
    d = copy.deepcopy(base)
    d.update(kw)
    return d


CASES = [
    # (label, system, G1, G2, reasoning)
    ("pair, plain", PAIR, None, None,
     "every single stop or mutate is seen by the other monitor and halts w"),
    ("pair, halt_inputs only a", variant(PAIR, halt_inputs={"w": ["a"]}), 2, 1,
     "mutate a: b flags but w does not listen to b -> work step (G2@1); then mutate b -> out empty (G1@2)"),
    ("one monitor", {"f": 1, "monitors": ["a"], "works": ["w"], "joiner": None,
                     "checkers": {"w": ["a"]}, "halt_inputs": {"w": ["a"]},
                     "coupling": True, "window": 0}, 1, 1,
     "mutate a: nobody left to flag, w keeps working"),
    ("pair, window 1", variant(PAIR, window=1), 2, 1,
     "mutate w: w only pends and works (G2@1); stop a then mutate b empties out (G1@2)"),
    ("pair, no gate", variant(PAIR, gate=False), 2, 1,
     "work runs before monitors: mutate w -> work step (G2@1); mutate a, mutate b -> out empty (G1@2)"),
    ("ring3, plain", RING3, None, None, "complete mutual monitoring, flag of a reaches b and c in the round"),
    ("ring3, slow reports", variant(RING3, slow_reports=True), None, 1,
     "mutate w: only a flags this round, w listens to b,c -> work step; out is never empty"),
    ("pair, switch on b", variant(PAIR, switches=["b"]), 2, 2,
     "disable b, then mutate a: nobody active checks a"),
    ("pair, f=2", variant(PAIR, f=2), 1, 1,
     "stop a + mutate b -> out empty; mutate a + mutate b -> out empty and w works"),
    ("pair, w on a substrate", variant(PAIR, substrate={"w": "s1"}), 1, 1,
     "fail-substrate makes w bad and hidden: no flag, w works"),
    ("pair, shared boundary", variant(PAIR, boundary={"a": "x", "b": "x"}), 2, None,
     "stop-boundary x (w halts on silence), then mutate w: out empty; w never works while bad"),
    ("pair, joiner unchecked", variant(PAIR, joiner="j"), 2, 2,
     "join, then mutate j: nobody checks j, j has no halt input"),
    ("pair, coupling off", variant(PAIR, coupling=False), None, None,
     "both monitors read each other, so every stop is flagged by a halt input"),
]

if __name__ == "__main__":
    bad = 0
    for label, system, g1, g2, why in CASES:
        r = result(system)
        ok = (r["G1"], r["G2"]) == (g1, g2)
        bad += not ok
        print(("ok   " if ok else "FAIL ") + f"{label:28s} G1={r['G1']} G2={r['G2']} expected ({g1},{g2})"
              + ("" if ok else f"  witness={r['witness']}"))
    print("failures:", bad)
