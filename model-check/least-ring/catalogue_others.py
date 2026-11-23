#!/usr/bin/env python3
"""G1 and G2 of the catalogue by the two other implementations, where they apply.

fast_join.py (in join) and model.py (in verify-impl) know nothing of scopes. They are run on
every case of systems-minimal.json that has no bound on rounds and at most one scope
(a system with one scope has the G1 and G2 of the same system without scopes:
model-spec-scope.md, X11), and compared with results-minimal.json.

Run:  python -B catalogue_others.py
"""
import importlib.util
import json
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(os.path.dirname(HERE), "join")
sys.path.insert(0, ROOT)
import fast_join as fj  # noqa: E402

spec = importlib.util.spec_from_file_location("verify_model",
                                              os.path.join(ROOT, "verify-impl", "model.py"))
vm = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vm)

systems = json.load(open(os.path.join(HERE, "systems-minimal.json"), encoding="utf-8"))
answers = {a["id"]: a for a in
           json.load(open(os.path.join(HERE, "results-minimal.json"), encoding="utf-8"))}
n = bad_f = bad_v = skipped = 0
for case in systems:
    d = case["system"]
    if d.get("max_rounds") is not None or len(set((d.get("scope") or {}).values())) > 1 \
            or d.get("scope_work") or d.get("freeze"):
        skipped += 1
        continue
    plain = {k: v for k, v in d.items() if k not in ("scope", "told")}
    want = (answers[case["id"]]["G1"], answers[case["id"]]["G2"])
    r = fj.explore(plain, stop_early=True)
    g1, g2, _, complete = vm.Model(plain).solve()
    n += 1
    if (r["G1"], r["G2"]) != want:
        bad_f += 1
        print("fast_join.py differs:", case["id"], (r["G1"], r["G2"]), want)
    if (g1, g2) != want or not complete:
        bad_v += 1
        print("verify-impl model.py differs:", case["id"], (g1, g2), want)
print(f"{n} cases compared ({skipped} have several scopes, freeze or a bound on rounds and "
      f"were left out); fast_join.py differs on {bad_f}; verify-impl model.py differs on {bad_v}")
