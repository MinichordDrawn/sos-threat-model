"""Shared loader for the reconciler's checks. Run every script as: python -I -B <script>."""
import os, sys, json
import os as _os
MC = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, MC)
sys.dont_write_bytecode = True
import check_model as cm

def from_data(d):
    s = cm.System(d.get("name", "x"), d.get("f", 1))
    for k, v in d.items():
        setattr(s, k, v)
    return s

def load_cases():
    with open(os.path.join(MC, "results.json"), encoding="utf-8") as fh:
        return json.load(fh)

def n(path):
    return len(path) if path else None
