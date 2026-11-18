import os, sys, hashlib, difflib, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rc import *

print("[mesh of 4 with the work not halting on silence]")
for f in (1, 2, 3):
    s = cm.mesh(4, f); s.coupling = False
    first, states = cm.explore(s)
    print(f"  f={f}: G1={n(first['G1'])} G2={n(first['G2'])} states={states}")

print("\n[spec copies]")
V = os.path.join(MC, "verification")
ref = open(os.path.join(MC, "model-spec.md"), "rb").read()
for d in ("a-reimplementation", "b-review", "d-claims", "e-claims", "f-falsifier"):
    b = open(os.path.join(V, d, "model-spec.md"), "rb").read()
    print(f"  {d:<20} {len(b):>6} bytes  sha1 {hashlib.sha1(b).hexdigest()[:10]}  identical to model-spec.md: {b == ref}")

print("\n[diff: pass A's copy -> model-spec.md]")
a = open(os.path.join(V, "a-reimplementation", "model-spec.md"), encoding="utf-8").read().splitlines()
r = ref.decode("utf-8").splitlines()
for line in difflib.unified_diff(a, r, "A-copy", "model-spec.md", lineterm="", n=0):
    print("  " + line)

print("\n[TLA listing against Heartbeat.tla]")
doc = open(os.path.join(MC, "results.md"), encoding="utf-8").read()
m = re.search(r"```tla\n(.*?)\n```", doc, re.S)
listing = m.group(1).splitlines()
tla = open(os.path.join(MC, "Heartbeat.tla"), encoding="utf-8").read().splitlines()
print("  listing lines:", len(listing), " file lines:", len(tla))
i = 0; missing = []
for ln, t in enumerate(tla, 1):
    if i < len(listing) and listing[i] == t:
        i += 1
    else:
        missing.append((ln, t))
print("  every listing line found in order:", i == len(listing))
print("  file lines not in the listing:")
for ln, t in missing: print(f"    {ln:>3}: {t}")
print("  cfg:", open(os.path.join(MC, "Heartbeat.cfg"), encoding="utf-8").read().replace("\n", " | "))
