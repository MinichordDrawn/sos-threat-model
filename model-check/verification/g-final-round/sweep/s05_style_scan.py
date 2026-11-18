"""Mechanical style scan of README.md and results.md: prints candidate lines for each rule."""
import re
import sys
import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


MC = _mc()
RULES = [
    ("em dash / en dash", re.compile(r"[\u2014\u2013]|--(?!-)")),
    ("in order to", re.compile(r"\bin order to\b", re.I)),
    ("starts This is / That is", re.compile(r"(?:^|[.!?:;]\s+|\*\*\s*|^\s*[-*\d.]+\s+)(This|That) is\b")),
    ("filler", re.compile(r"\b(comprehensive|robust|seamless|leverag\w*|fundamentally|essentially|basically|simply|very|really|quite|clearly|obviously|of course|just|actually|in fact|truly|merely|crucial\w*|key|powerful|elegant\w*)\b", re.I)),
    ("first person", re.compile(r"\b(I|we|our|us|my|me|ours|mine)\b")),
    ("qualifier", re.compile(r"\b(I think|it seems|seems|arguably|perhaps|maybe|probably|likely|presumably|apparently|somewhat|fairly|rather|roughly|more or less|sort of|kind of|in a sense|in some sense|might|may well|appears to)\b", re.I)),
    ("history word", re.compile(r"\b(now|no longer|used to|previously|formerly|earlier version|originally|at first|since fixed|was replaced|replaced)\b", re.I)),
    ("ALL CAPS", re.compile(r"\b[A-Z]{3,}\b")),
    ("mirror: not X ... It is", re.compile(r"\b(is|are|was|were|does|do|did) not\b[^.]*\.\s+(It|They|This|That) (is|are|was|were)\b", re.I)),
    ("not X but Y / not only", re.compile(r"\bnot (only|just|merely)\b|\bnot\b[^.,;]{0,40}\bbut\b", re.I)),
    ("exclamation / question", re.compile(r"[!?](\s|$)")),
    ("passive (candidates)", re.compile(r"\b(is|are|was|were|be|been|being)\s+(\w+ed|given|shown|taken|written|made|done|found|seen|read|run|set|kept|left|held|built|put|lost|met|drawn)\b")),
]
for name in ("README.md", "results.md"):
    lines = open(MC + "\\" + name, encoding="utf-8").read().split("\n")
    print("=" * 30, name, len(lines))
    in_code = False
    for rule, rx in RULES:
        hits = []
        in_code = False
        for i, line in enumerate(lines, 1):
            if line.strip().startswith("```"):
                in_code = not in_code
                continue
            if in_code:
                continue
            for m in rx.finditer(line):
                hits.append((i, m.group(0), line.strip()[:150]))
        print(f"--- {rule}: {len(hits)}")
        if rule.startswith("passive"):
            continue   # only count; read by eye
        for h in hits:
            print(f"   {h[0]:>5}: [{h[1]}] {h[2]}")
    # non-ASCII characters
    odd = {}
    for i, line in enumerate(lines, 1):
        for ch in line:
            if ord(ch) > 127:
                odd.setdefault(ch, []).append(i)
    print("--- non-ASCII:", {f"U+{ord(k):04X} {k}": v[:12] for k, v in odd.items()})
    # long sentences (> 40 words)
    text = "\n".join(lines)
    print("--- TODO-SWEEP lines:", [i for i, l in enumerate(lines, 1) if "TODO-SWEEP" in l])
