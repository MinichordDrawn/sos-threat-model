#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Alexandra Thaler. Part of SOS: Threat Modeling For Self-Observing Systems.
"""Check that every file:line citation in a document resolves against the source trees.

Every citation is its own backticked span, one file per span, and the path has a slash or
a file extension:

    `path/to/file.ext:12`       `file.ext:12-30`      `file.ext:12, 40-44`
    `./Makefile:9`              (an extensionless file needs a slash)
    `PFX: path/to/file.ext:12`  (a tree prefix declared with --tree PFX=DIR; a prefix is
                                 capital letters, digits and underscores, then ": ")
    `:44`                       (continues the last path named in the same paragraph,
                                 table row or list item)

A span such as `localhost:8080`, `postgres:15` or `12:30` is not a citation and is left
alone, because its left side has no slash and no file extension.

A citation resolves when the file exists inside the named tree (or, without a prefix,
inside any tree given; a bare file name or a path suffix matches a unique file) and every
line or range satisfies 1 <= start <= end <= the file's line count. A path with a `..`
segment never resolves. When a bare name matches several files, the directories given with
--prefer (relative to the trees, in order) decide; a name still ambiguous after that does
not resolve. Files under .git, node_modules, target and vendor are not indexed by name, so
they resolve only by their path from the tree root.

Three kinds of failure are counted as bad:

    unresolved   the file is missing, ambiguous, outside the tree, or a line is out of range
    undeclared   the citation names a prefix with no --tree PFX=DIR
    unparsed     a span that looks like a citation but is not in the forms above (two files
                 in one span, trailing words, `file.go:L12`, no space after a prefix, or an
                 unfilled template placeholder in «guillemets»)

A document with no citations at all is an error, not a pass. Counts are printed per prefix,
with every bare tree counted together under "(bare)".

    python resolve_citations.py DOCUMENT.md --tree DIR [--tree PFX=DIR ...]
                                [--prefer SUBDIR ...] [--list-bad] [--list-files]
                                [--rewrite PFX OUT.md [--rename OLD=NEW ...]]

--list-files prints every file the document cites, by prefix, with its citation count;
the currency check uses it to know which files to compare upstream.

--rewrite writes OUT.md, a copy of the document in which every unprefixed citation that
resolves is rewritten as `PFX: repo/relative/path:lines`, the path taken relative to the
tree it resolved in, and every citation under a prefix named in --rename OLD=NEW is
rewritten under NEW; nothing else changes. It refuses to write while any citation is bad.
Assembly uses it to carry a package's citations into an aggregate, and --rename to make a
dependency prefix distinct across packages.

Exit status 0 when every citation resolves, 1 when any is bad or none is found, 2 on a
usage error.
"""
import os
import re
import sys

SPAN = re.compile(r"`([^`\n]+)`")
PATHCH = r"[\w./\\+@\-\[\]()]"
PATH = r"(?:" + PATHCH + r"*/" + PATHCH + r"*[\w+@\-\])]|" + PATHCH + r"*\.[A-Za-z]\w*)"
LINES = r"(?P<lines>\d+(?:-\d+)?(?:,\s*\d+(?:-\d+)?)*)"
CITE = re.compile(r"^(?:(?P<pfx>[A-Z][A-Z0-9_]*):\s+)?(?P<path>" + PATH + r")?:" + LINES + r"$")
LOOKS = re.compile(r"(?:^|[\s(])(?:[A-Z][A-Z0-9_]*:\s*)?" + PATH + r":\s*L?\d")
SKIP = {".git", "node_modules", "target", "vendor"}


def index(root):
    by_name = {}
    root = os.path.realpath(root)
    for d, dirs, files in os.walk(root):
        dirs[:] = [x for x in dirs if x not in SKIP]
        for f in files:
            by_name.setdefault(f, []).append(os.path.join(d, f))
    return by_name


def inside(path, root):
    path, root = os.path.realpath(path), os.path.realpath(root)
    return path == root or path.startswith(root + os.sep)


def find(path, trees, names, prefer=()):
    """Return (realpath, tree root) or (None, None)."""
    if ".." in re.split(r"[\\/]", path):
        return None, None
    path = re.sub(r"^(?:\./)+", "", path)
    for root in trees:
        p = os.path.join(root, path)
        if os.path.isfile(p) and inside(p, root):
            return os.path.realpath(p), root
    base = os.path.basename(path.replace("\\", "/"))
    want = "/" + path.replace("\\", "/").lstrip("/")
    cands = {(os.path.realpath(c), root) for root in trees for c in names[root].get(base, [])
             if ("/" + c.replace(os.sep, "/")).endswith(want)}
    if len({c for c, _ in cands}) == 1:
        return cands.pop()
    for sub in prefer:
        for root in trees:
            p = os.path.join(root, sub, path)
            if os.path.isfile(p) and inside(p, root):
                return os.path.realpath(p), root
    return None, None


def length(p, cache={}):
    if p not in cache:
        with open(p, "rb") as f:
            data = f.read()
        n = data.count(b"\n")
        if data and not data.endswith(b"\n"):
            n += 1
        cache[p] = n
    return cache[p]


def in_range(spec, n):
    for r in re.split(r",\s*", spec):
        a, _, b = r.partition("-")
        a, b = int(a), int(b or a)
        if not (1 <= a <= b <= n):
            return False
    return True


ITEM = re.compile(r"^\s*(?:[-*+]|\d+\.)\s")


def units(text):
    """(start offset, text) for each paragraph, with each table row and each list item its
    own unit, so a continuation stays within the unit that named its path."""
    pos = 0
    for para in re.split(r"(\n\s*\n)", text):
        if re.fullmatch(r"\n\s*\n", para or "\n\n"):
            pos += len(para)
            continue
        off = pos
        buf_start, buf = None, []
        for line in para.split("\n"):
            if line.lstrip().startswith("|"):
                if buf:
                    yield buf_start, "\n".join(buf)
                    buf, buf_start = [], None
                yield off, line
            else:
                if ITEM.match(line) and buf:
                    yield buf_start, "\n".join(buf)
                    buf, buf_start = [], None
                if buf_start is None:
                    buf_start = off
                buf.append(line)
            off += len(line) + 1
        if buf:
            yield buf_start, "\n".join(buf)
        pos += len(para)


def main(argv):
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    if not argv or "--tree" not in argv:
        print(__doc__)
        return 2
    doc = argv[0]
    trees, prefixed, prefer, rewrite, rename = [], {}, [], None, {}
    list_bad = list_files = False
    i = 1
    while i < len(argv):
        a = argv[i]
        if a in ("--tree", "--prefer"):
            if i + 1 >= len(argv):
                print(f"{a} needs a value")
                return 2
            v = argv[i + 1]
            if a == "--prefer":
                prefer.append(v)
            elif re.match(r"^[A-Z][A-Z0-9_]*=", v):
                k, d = v.split("=", 1)
                prefixed[k] = d
            elif re.match(r"^[A-Za-z_]\w*=", v) and not os.path.isdir(v):
                print(f"prefix in {v!r} must be capital letters, digits and underscores")
                return 2
            else:
                trees.append(v)
            i += 2
        elif a == "--rewrite":
            if i + 2 >= len(argv) or not re.match(r"^[A-Z][A-Z0-9_]*$", argv[i + 1]):
                print("--rewrite needs a prefix (capital letters, digits, underscores) and an output file")
                return 2
            rewrite = (argv[i + 1], argv[i + 2])
            i += 3
        elif a == "--rename":
            if i + 1 >= len(argv) or not re.match(r"^[A-Z][A-Z0-9_]*=[A-Z][A-Z0-9_]*$", argv[i + 1]):
                print("--rename needs OLD=NEW, both prefixes of capital letters, digits and underscores")
                return 2
            k, v = argv[i + 1].split("=", 1)
            rename[k] = v
            i += 2
        elif a == "--list-bad":
            list_bad = True
            i += 1
        elif a == "--list-files":
            list_files = True
            i += 1
        else:
            print(f"unknown argument {a!r}")
            return 2
    if rename and not rewrite:
        print("--rename works only with --rewrite")
        return 2
    for root in trees + list(prefixed.values()):
        if not os.path.isdir(root):
            print(f"tree not found: {root}")
            return 2
    names = {r: index(r) for r in trees + list(prefixed.values())}
    text = open(doc, encoding="utf-8").read()
    counts, bad, repl, files = {}, [], [], {}
    for start, unit in units(text):
        last = None
        for m in SPAN.finditer(unit):
            span = m.group(1).strip()
            c = CITE.match(span)
            if not c:
                if "«" in span or "»" in span or LOOKS.search(span):
                    bad.append(("unparsed", span))
                continue
            pfx, path, lines = c.group("pfx"), c.group("path"), c.group("lines")
            if pfx and pfx not in prefixed:
                bad.append(("undeclared", span))
                last = None
                continue
            roots = [prefixed[pfx]] if pfx else trees
            label = pfx or "(bare)"
            if path:
                resolved, root = find(path, roots, names, prefer)
                last = (resolved, root, label) if resolved else None
            if not last:
                bad.append(("unresolved", span))
                continue
            resolved, root, label = last
            if in_range(lines, length(resolved)):
                counts[label] = counts.get(label, 0) + 1
                rel = os.path.relpath(resolved, os.path.realpath(root)).replace(os.sep, "/")
                files.setdefault(label, {}).setdefault(rel, 0)
                files[label][rel] += 1
                if rewrite and not pfx and path:
                    repl.append((start + m.start(1), start + m.end(1), f"{rewrite[0]}: {rel}:{lines}"))
                elif rewrite and pfx in rename:
                    span_text = m.group(1)
                    repl.append((start + m.start(1), start + m.end(1),
                                 re.sub(r"^\s*" + pfx + r":", rename[pfx] + ":", span_text, count=1)))
            else:
                bad.append(("unresolved", span))
    good = sum(counts.values())
    print(f"{good} citations resolve, {len(bad)} do not")
    for label in sorted(counts):
        print(f"   {label}: {counts[label]}")
    if list_bad:
        for kind, span in bad:
            print(f"   {kind:<10} {span}")
    if list_files:
        for label in sorted(files):
            for rel in sorted(files[label]):
                print(f"   file {label} {rel} {files[label][rel]}")
    if good + len(bad) == 0:
        print("no citations found: every citation must be its own backticked span")
        return 1
    if bad:
        if rewrite:
            print("nothing rewritten while citations are bad")
        return 1
    if rewrite:
        out = text
        for a, b, new in sorted(repl, reverse=True):
            out = out[:a] + new + out[b:]
        open(rewrite[1], "w", encoding="utf-8", newline="\n").write(out)
        print(f"rewrote {len(repl)} citations into {rewrite[1]}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
