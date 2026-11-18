"""Last check, script 5: results.md section 9. Compares the listing in results.md with
Heartbeat.tla, line by line, and reports what the listing leaves out.

Run: python -I -B lc05_tla_listing.py
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
FOLDER = os.path.normpath(os.path.join(HERE, "..", "..", ".."))

with open(os.path.join(FOLDER, "results.md"), encoding="utf-8") as fh:
    doc = fh.read().split("\n")
start = doc.index("```tla")
end = doc.index("```", start + 1)
listing = doc[start + 1:end]
with open(os.path.join(FOLDER, "Heartbeat.tla"), encoding="utf-8") as fh:
    tla = fh.read().split("\n")
while tla and not tla[-1].strip():
    tla.pop()

# walk the module; every line must be the next listing line, or be left out
i = 0
left_out = []
for n, line in enumerate(tla, 1):
    if i < len(listing) and line.rstrip() == listing[i].rstrip():
        i += 1
    else:
        left_out.append((n, line))
print("listing lines:", len(listing), "| module lines:", len(tla), "| listing lines matched in order:", i)
print("module lines the listing leaves out:")
for n, line in left_out:
    print(f"  {n:>3}: {line}")
with open(os.path.join(FOLDER, "Heartbeat.cfg"), encoding="utf-8") as fh:
    print("Heartbeat.cfg:")
    print("  " + fh.read().strip().replace("\n", "\n  "))
