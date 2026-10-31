#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Alexandra Thaler. Part of SOS: Threat Modeling For Self-Observing Systems.
"""Extract a PDF to page-marked text for citation by line.

    python page_text.py SOURCE.pdf OUT.txt [--enc UTF-8|Latin1|ASCII7] [--pdftotext PATH]
    python page_text.py SOURCE.pdf --compare [--pdftotext PATH]

Runs `pdftotext -layout` (xpdf or Poppler) on SOURCE.pdf and writes OUT.txt with a line
`=== PDF page N ===` before each page, so a line citation (`OUT.txt:120-128`) can name its
page. Prints the SHA-256 of the PDF and of OUT.txt; record both, with the pdftotext
version and the encoding, in the survey, because every citation depends on the exact bytes
of OUT.txt. Never edit OUT.txt after this.

Output is written with LF line endings and UTF-8, whatever the platform, so the same PDF,
pdftotext version and --enc give the same file everywhere. --enc (default UTF-8) is passed
to pdftotext and the output is decoded with it strictly: a byte that does not decode stops
the script rather than becoming a replacement character. Some PDFs map dashes or symbols
in one encoding only. --compare extracts in UTF-8 and Latin1, writes nothing, and reports
for each the replacement characters, em dashes, non-space characters and other non-ASCII
characters, so the choice can be made before the one extraction that citations will depend
on. Latin1 output can hold neither a replacement character nor an em dash, so its zero
counts prove nothing; a lower non-space count is text that encoding lost.
"""
import hashlib
import os
import shutil
import subprocess
import sys
import tempfile

CODECS = {"UTF-8": "utf-8", "Latin1": "latin-1", "ASCII7": "ascii"}
REPLACEMENT = chr(0xFFFD)
EM_DASH = chr(0x2014)


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def option(argv, name, default):
    if name not in argv:
        return default
    i = argv.index(name)
    if i + 1 >= len(argv):
        sys.exit(f"{name} needs a value")
    value = argv[i + 1]
    del argv[i:i + 2]
    return value


def extract(exe, src, enc):
    with tempfile.TemporaryDirectory() as tmp:
        raw = os.path.join(tmp, "raw.txt")
        subprocess.run([exe, "-layout", "-enc", enc, "-eol", "unix", src, raw], check=True)
        with open(raw, "rb") as f:
            data = f.read()
    try:
        return data.decode(CODECS[enc]).replace("\r\n", "\n")
    except UnicodeDecodeError as e:
        sys.exit(f"pdftotext output does not decode as {enc}: {e}")


def compare(exe, src):
    for enc in ("UTF-8", "Latin1"):
        text = extract(exe, src, enc)
        other = sorted({c for c in text if ord(c) > 127 and c not in (REPLACEMENT, EM_DASH)})
        listed = " ".join(f"U+{ord(c):04X}" for c in other) or "none"
        visible = sum(1 for c in text if not c.isspace())
        print(f"{enc}: {text.count(REPLACEMENT)} replacement, {text.count(EM_DASH)} em dash,"
              f" {text.count(chr(10))} lines, {visible} non-space characters,"
              f" other non-ASCII: {listed}")


def main(argv):
    exe = option(argv, "--pdftotext", "pdftotext")
    enc = option(argv, "--enc", "UTF-8")
    if enc not in CODECS:
        sys.exit(f"--enc must be one of {', '.join(CODECS)}")
    compare_only = "--compare" in argv
    if compare_only:
        argv.remove("--compare")
    if len(argv) != (1 if compare_only else 2):
        sys.exit(__doc__)
    src = argv[0]
    if not os.path.isfile(src):
        sys.exit(f"no such file: {src}")
    if shutil.which(exe) is None and not os.path.isfile(exe):
        sys.exit(f"pdftotext not found ({exe}); install xpdf or Poppler, or pass --pdftotext PATH")
    if compare_only:
        compare(exe, src)
        return
    out = argv[1]
    if os.path.exists(out):
        sys.exit(f"refusing to overwrite {out}: citations may depend on it")
    text = extract(exe, src, enc)
    bad = text.count(REPLACEMENT)
    if bad:
        print(f"warning: {bad} replacement characters in the extraction; run --compare",
              file=sys.stderr)
    # pdftotext ends every page with a form feed, so the last part is empty; it is kept
    # and numbered as the extraction gives it.
    pages = text.split("\f")
    if len(pages) < 2:
        sys.exit("no form feed in the extraction: check the pdftotext configuration")
    with open(out, "x", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(f"=== PDF page {n} ===\n{page}" for n, page in enumerate(pages, 1)))
    print(f"{len(pages)} parts, -enc {enc}")
    print(f"sha256 {sha256(src)}  {src}")
    print(f"sha256 {sha256(out)}  {out}")


if __name__ == "__main__":
    main(sys.argv[1:])
