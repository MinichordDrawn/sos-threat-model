"""Last check, script 6: lists every added or changed line of the two documents with its
line number in the current file, and scans those lines for the mechanical writing rules.

Run: python -I -B lc06_changed_lines.py
"""
import difflib
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
PAIRS = (("results.md", os.path.join(ROOT, "sos-formal", "final-round", "swept-results.md"),
          os.path.join(ROOT, "shared-templates", "model-check", "results.md")),
         ("README.md", os.path.join(ROOT, "sos-formal", "final-round", "swept-README.md"),
          os.path.join(ROOT, "shared-templates", "model-check", "README.md")))

RULES = (
    ("em dash", re.compile("\u2014|\u2013| -- ")),
    ("first person", re.compile(r"\b(I|we|our|us|my|me)\b")),
    ("in order to", re.compile(r"\bin order to\b", re.I)),
    ("filler", re.compile(r"\b(comprehensive|robust|seamless|leverag\w*|fundamentally|essentially|basically)\b", re.I)),
    ("qualifier", re.compile(r"\b(I think|it seems|arguably|perhaps|probably|sort of|kind of)\b", re.I)),
    ("starts This is / That is", re.compile(r"(^|[.!?:]\s+|\*\*\s*)(This|That) is\b")),
    ("history word", re.compile(r"\b(now|no longer|used to|previously|formerly|at the time)\b", re.I)),
    ("capitals", re.compile(r"\b[A-Z]{4,}\b")),
    ("mirror", re.compile(r"\b(is|are|was|were|does|do|did) not\b[^.]*\.\s+(It|They|This|That) (is|are|was|were)\b")),
    ("passive (candidate)", re.compile(
        r"\b(is|are|was|were|be|been|being)\s+(\w+ed|given|shown|taken|written|made|done|found|seen|read|run|set|kept|left|held|built|put|lost|met|drawn)\b")),
    ("casual", re.compile(r"\b(very|really|just|simply|of course|a lot|lots|thing|things|stuff|pretty|quite|actually)\b", re.I)),
)

for name, old, new in PAIRS:
    with open(old, encoding="utf-8") as fh:
        a = fh.read().split("\n")
    with open(new, encoding="utf-8") as fh:
        b = fh.read().split("\n")
    sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
    changed = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag in ("replace", "insert"):
            changed.extend(range(j1, j2))
    print(f"==== {name}: {len(changed)} changed or added lines of {len(b)}")
    out = os.path.join(HERE, f"lc06_changed_{name.replace('.md', '')}.txt")
    with open(out, "w", encoding="utf-8") as fh:
        for j in changed:
            fh.write(f"{j + 1}\t{b[j]}\n")
    for j in changed:
        line = b[j]
        hits = [label for label, rx in RULES if rx.search(line)]
        if hits:
            print(f"  {j + 1:>5} [{'; '.join(hits)}] {line.strip()[:150]}")
