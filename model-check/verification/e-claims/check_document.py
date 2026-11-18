"""Re-run every JSON system quoted in claims2-verdicts.md and print its result, with a
least-round witness, so the document's counterexamples are checked as written."""
import json
import os
import re
import sys

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import model  # noqa: E402

text = open(os.path.join(here, "claims2-verdicts.md"), encoding="utf-8").read()
blocks = re.findall(r"```json\n(.*?)```", text, flags=re.S)
print("%d JSON systems found" % len(blocks))
for b in blocks:
    S = json.loads(b)
    required = ["name", "f", "monitors", "works", "joiner", "boundary", "substrate", "hb_readers",
                "checkers", "fwd", "halt_inputs", "switches", "coupling", "window"]
    missing = [k for k in required if k not in S]
    res, paths = model.result(S, want_witness=True)
    print("-", S["name"], "| missing fields:", missing or "none")
    print("    result:", json.dumps(res))
    for g in ("G1", "G2"):
        if paths[g] is not None:
            print("    least %s execution (env steps per round): %s" % (g, [[" ".join(s) for s in r] for r in paths[g]]))
