#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Alexandra Thaler. Part of SOS: Threat Modeling For Self-Observing Systems.
"""Apply an edit list to one or more documents, all or nothing.

Two edit formats are accepted, in any mix. A CURRENT/REPLACEMENT block, as the reviews,
the reconciliation, the fold and the register write them, with each label alone on its
line and each text in a fence:

    CURRENT:
    ```
    exact text from the document
    ```
    REPLACEMENT:
    ```
    new text (an empty fence deletes the text)
    ```

Use a longer fence (````) when the text itself contains ```; the closing fence must match
the opening one. A sweep line, as the final sweep writes them, one per line:

    12. Line 86. Old: `` exact phrase `` New: `` replacement ``

with one space inside each pair of double backticks; `New: ```` deletes the phrase.

The script stops with nothing changed when any of these holds:

  - a line in the edit list looks like an edit (a CURRENT, REPLACEMENT or Old: label, or a
    numbered "Line N." entry) but does not parse in the forms above;
  - an old text does not occur exactly once in a document at the moment it is applied,
    after the edits before it;
  - with several documents, an edit reaches only some of them, unless --partial is given.

Usage:

    python apply_edits.py EDITS.md DOCUMENT.md [DOCUMENT2.md ...] [--partial] [--dry-run]

It prints one line per edit naming the documents it changed. Exit status 0 when every
edit applied or the list holds none, 1 when the script stopped, 2 on a usage error. A
deletion also removes the line break after a deleted block, or the space before a deleted
phrase.
"""
import os
import re
import sys

LABEL = re.compile(
    r"^\W*(?:\d+\.\s*)?(?:CURRENT|REPLACEMENT|current text|new text|old text)\b"
    r"|\bLines?\s+\d+\W*\s*Old\b|\bOld:\s*[`\"']",
    re.I,
)
OPEN = re.compile(r"^\s*(?:\d+\.\s*)?CURRENT:\s*$")
SWEEP = re.compile(
    r"^\s*(?P<num>\d+)\.\s*Line\s+(?P<line>\d+)\.\s*Old:\s*``\s(?P<old>.*?)\s``\s*"
    r"New:\s*(?:``\s(?P<new>.*?)\s``|````)\s*$"
)
FENCE = re.compile(r"^(`{3,})[^`]*$")


def read_fenced(lines, i):
    """lines[i] must open a fence; return (text, index after the closing fence)."""
    m = FENCE.match(lines[i])
    if not m:
        return None, i
    fence = m.group(1)
    body = []
    j = i + 1
    while j < len(lines):
        if lines[j].rstrip() == fence:
            return "\n".join(body), j + 1
        body.append(lines[j])
        j += 1
    return None, i


def parse(text):
    lines = text.replace("\r\n", "\n").split("\n")
    edits, problems, used = [], [], set()
    i = 0
    while i < len(lines):
        line = lines[i]
        if OPEN.match(line):
            start = i + 1
            j = i + 1
            while j < len(lines) and not lines[j].strip():
                j += 1
            old, j = read_fenced(lines, j) if j < len(lines) else (None, j)
            while j < len(lines) and not lines[j].strip():
                j += 1
            if old is not None and j < len(lines) and lines[j].strip() == "REPLACEMENT:":
                rl = j
                j += 1
                while j < len(lines) and not lines[j].strip():
                    j += 1
                new, k = read_fenced(lines, j) if j < len(lines) else (None, j)
                if new is not None:
                    edits.append((f"line {start}", old, new))
                    used.update(range(i, k))
                    used.add(rl)
                    i = k
                    continue
            problems.append(f"edit list line {start}: CURRENT block does not parse")
            used.add(i)
            i += 1
            continue
        m = SWEEP.match(line)
        if m:
            edits.append((f"item {m.group('num')} (line {i + 1})", m.group("old"), m.group("new") or ""))
            used.add(i)
        i += 1
    for n, line in enumerate(lines):
        if n not in used and LABEL.search(line):
            problems.append(f"edit list line {n + 1}: looks like an edit but does not parse: {line.strip()[:90]!r}")
    return edits, problems


def main(argv):
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    flags = {a for a in argv if a.startswith("--")}
    unknown = flags - {"--dry-run", "--partial"}
    if unknown:
        print("unknown option:", ", ".join(sorted(unknown)))
        return 2
    dry = "--dry-run" in flags
    partial = "--partial" in flags
    args = [a for a in argv if not a.startswith("--")]
    if len(args) < 2:
        print(__doc__)
        return 2
    edits, problems = parse(open(args[0], encoding="utf-8").read())
    if problems:
        print("\n".join(problems))
        print(f"{len(problems)} unparsed entries; nothing was changed")
        return 1
    if not edits:
        print("no edits in", args[0] + "; nothing to apply")
        return 0
    raw = {p: open(p, encoding="utf-8", newline="").read() for p in args[1:]}
    crlf = {p: 0 < s.count("\r\n") == s.count("\n") for p, s in raw.items()}
    docs = {p: s.replace("\r\n", "\n") for p, s in raw.items()}
    errors, report = [], []
    for name, old, new in edits:
        if not old:
            errors.append(f"{name}: empty old text")
            continue
        hit, miss = [], []
        for p in docs:
            n = docs[p].count(old)
            if n == 1:
                target = old
                if new == "":
                    # a deleted block takes its line break with it; a deleted phrase, the
                    # space before it
                    for wider in (old + "\n", " " + old):
                        if docs[p].count(wider) == 1:
                            target = wider
                            break
                docs[p] = docs[p].replace(target, new, 1)
                hit.append(p)
            elif n > 1:
                errors.append(f"{name}: old text occurs {n} times in {p}")
            else:
                miss.append(p)
        if not hit and not any(name in e for e in errors):
            errors.append(f"{name}: old text not found: {old[:80]!r}")
        elif miss and len(docs) > 1 and not partial:
            errors.append(f"{name}: not found in {', '.join(miss)} (use --partial to allow)")
        report.append(f"{name}: {'applied to ' + ', '.join(hit) if hit else 'not applied'}"
                      + (f"; not found in {', '.join(miss)}" if hit and miss else ""))
    if errors:
        print("\n".join(errors))
        print(f"{len(errors)} problems in {len(edits)} edits; nothing was changed")
        return 1
    print("\n".join(report))
    if not dry:
        # every document goes to a temporary file first, then all move into place
        tmp = {}
        for p, s in docs.items():
            tmp[p] = p + ".apply-edits.tmp"
            open(tmp[p], "w", encoding="utf-8", newline="").write(s.replace("\n", "\r\n") if crlf[p] else s)
        for p in docs:
            os.replace(tmp[p], p)
    print(f"{'would apply' if dry else 'applied'} {len(edits)} edits to {len(docs)} document(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
