"""List passive-voice candidates in both documents, with line numbers, for reading by eye."""
import os
import re
import sys
import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


MC = _mc()
rx = re.compile(r"\b(is|are|was|were|be|been|being)\s+(not\s+|also\s+|then\s+|still\s+|only\s+|each\s+|all\s+)?"
                r"(\w+ed|given|shown|taken|written|made|done|found|seen|read|run|set|kept|left|held|built|put|lost|met|drawn)\b")
for name in sys.argv[1:]:
    lines = open(os.path.join(MC, name), encoding="utf-8").read().split("\n")
    code = False
    for i, l in enumerate(lines, 1):
        if l.strip().startswith("```"):
            code = not code
            continue
        if code:
            continue
        ms = [m.group(0) for m in rx.finditer(l)]
        if ms:
            print(i, ms, "|", l.strip()[:160])
