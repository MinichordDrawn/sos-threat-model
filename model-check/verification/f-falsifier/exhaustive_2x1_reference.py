"""Every plain system with two monitors and one work process, self-loops included (2^16
systems), judged by the reference implementation (model.py) and the JSON-level definitions of
task.md alone (verify_falsifiers.py).  No bitmask code is involved.

Run:  python -I exhaustive_2x1_reference.py     (about half a minute)
"""
import os
import sys
import time
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import verify_falsifiers as vf

MONS = ["a", "b"]


def lst(bits):
    return [m for i, m in enumerate(MONS) if bits >> i & 1]


def systems():
    for bits in range(1 << 16):
        yield {
            "name": f"2x1-{bits}", "f": 1, "monitors": list(MONS), "works": ["w"], "joiner": None,
            "boundary": {"a": "b_a", "b": "b_b"}, "substrate": {},
            "hb_readers": {"a": lst(bits), "b": lst(bits >> 2)},
            "checkers": {"a": lst(bits >> 4), "b": lst(bits >> 6), "w": lst(bits >> 8)},
            "fwd": {"a": lst(bits >> 10), "b": lst(bits >> 12)},
            "halt_inputs": {"w": lst(bits >> 14)},
            "switches": [], "coupling": True, "window": 0, "gate": True, "slow_reports": False,
        }


if __name__ == "__main__":
    t0 = time.time()
    c = Counter()
    for d in systems():
        c["systems"] += 1
        assert vf.is_plain(d)
        if not vf.gap_free(d):
            continue
        c["gap-free"] += 1
        fails = vf.failing(d)
        c["gap-free failing " + ("+".join(fails) or "nothing")] += 1
        spare = [m for m in MONS if vf.gap_free(vf.delete(d, m))]
        c[f"gap-free with {len(spare)} spare monitors"] += 1
        if fails and all(vf.failing(t) for t in vf.terminals(d)):
            c["falsifiers"] += 1
            selfloops = any(m in d[key][m] for key in ("hb_readers", "checkers", "fwd") for m in MONS)
            c["falsifiers without self-loops"] += not selfloops
    for key in sorted(c):
        print(f"{key}: {c[key]}")
    print(f"[{time.time()-t0:.0f}s]")
