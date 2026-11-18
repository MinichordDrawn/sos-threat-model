"""Helper: import the checker under review without writing anything into its folder."""
import sys

sys.dont_write_bytecode = True
import os as _os
FM = _os.path.normpath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), "..", "..", ".."))
if FM not in sys.path:
    sys.path.insert(0, FM)
import check_model as cm  # noqa: E402


def res(system):
    first, states = cm.explore(system)
    g1 = first["G1"] and len(first["G1"])
    g2 = first["G2"] and len(first["G2"])
    return g1, g2, states, first


def from_json(d):
    s = cm.System(d.get("name", "x"), d.get("f", 1))
    for k, v in d.items():
        setattr(s, k, v)
    for k in ("boundary", "substrate", "hb_readers", "checkers", "fwd", "halt_inputs"):
        if not hasattr(s, k) or getattr(s, k) is None:
            setattr(s, k, {})
    return s
