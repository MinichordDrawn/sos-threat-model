#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Alexandra Thaler. Part of SOS: Threat Modeling For Self-Observing Systems.
# Rebuild the page-marked text every citation in chernobyl-threat-model.md and
# chernobyl-threat-model-standalone.md is written against.
#
#   sh rebuild-source.sh [DIR]
#
# Downloads IAEA Safety Series No. 75-INSAG-7 (IAEA, Vienna, 1992) into DIR (default
# ./sources), checks the PDF's SHA-256, extracts it with pdftotext version 4.00
# (xpdf, Glyph & Cog) using -layout -enc Latin1, writes the text as UTF-8 with LF line
# endings and a line "=== PDF page N ===" before each page, and checks the text's SHA-256.
# It stops with a non-zero status on any missing tool, download failure or mismatch, and
# never overwrites an existing file.
#
# Set PAGE_TEXT to the path of the kit's page_text.py to extract with it instead of the
# built-in pipeline; both give the same bytes from the same pdftotext.

set -eu

URL='https://www-pub.iaea.org/MTCD/Publications/PDF/Pub913e_web.pdf'
PDF_SHA256='75627db871b8cec591eaf9443ef32da70e6ccb72c34c38b01c18933e21152455'
TXT_SHA256='a83c26e92dd7ac110314315850ba8e424b11facbdccbdd51e6d7cad20c321e32'
PDFTOTEXT_VERSION='4.00'

DIR=${1:-sources}
PDF="$DIR/insag-7.pdf"
TXT="$DIR/insag-7-paged.txt"

fail() {
    printf 'rebuild-source: %s\n' "$*" >&2
    exit 1
}

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | cut -d ' ' -f 1
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | cut -d ' ' -f 1
    else
        fail "no sha256sum or shasum found"
    fi
}

[ -e "$PDF" ] && fail "refusing to overwrite $PDF"
[ -e "$TXT" ] && fail "refusing to overwrite $TXT"
mkdir -p "$DIR" || fail "cannot create $DIR"

command -v pdftotext >/dev/null 2>&1 || fail "pdftotext not found; install xpdf $PDFTOTEXT_VERSION"
found=$(pdftotext -v 2>&1 | sed -n 's/^pdftotext version \([0-9.]*\).*/\1/p' | head -n 1)
[ "$found" = "$PDFTOTEXT_VERSION" ] || fail "pdftotext version ${found:-unknown}, need $PDFTOTEXT_VERSION (xpdf)"

TMP=$(mktemp -d) || fail "cannot create a temporary directory"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

# 1. Download.
if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$TMP/source.pdf" "$URL" || fail "download failed: $URL"
elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$TMP/source.pdf" "$URL" || fail "download failed: $URL"
else
    fail "no curl or wget found"
fi

# 2. Check the PDF.
got=$(sha256_of "$TMP/source.pdf")
[ "$got" = "$PDF_SHA256" ] || fail "PDF SHA-256 mismatch: got $got, expected $PDF_SHA256"
cp "$TMP/source.pdf" "$PDF" || fail "cannot write $PDF"

# 3. Extract with the recorded tool and options, and mark the pages.
if [ -n "${PAGE_TEXT:-}" ]; then
    PY=
    for c in python3 python; do
        if "$c" -c 'import sys; sys.exit(sys.version_info < (3, 6))' >/dev/null 2>&1; then
            PY=$c; break
        fi
    done
    [ -n "$PY" ] || fail "PAGE_TEXT is set but no Python 3 is found"
    [ -f "$PAGE_TEXT" ] || fail "no such file: $PAGE_TEXT"
    "$PY" -I "$PAGE_TEXT" "$PDF" "$TMP/paged.txt" --enc Latin1 >/dev/null \
        || fail "page_text.py failed"
else
    pdftotext -layout -enc Latin1 "$PDF" "$TMP/raw.txt" || fail "pdftotext failed"
    command -v iconv >/dev/null 2>&1 || fail "iconv not found"
    CR=$(printf '\r')
    # Latin1 to UTF-8, CRLF to LF.
    iconv -f ISO-8859-1 -t UTF-8 "$TMP/raw.txt" | sed "s/${CR}\$//" > "$TMP/utf8.txt" \
        || fail "re-encoding failed"
    # pdftotext ends every page with a form feed. Split on it, keeping the empty part
    # after the last one, and put "=== PDF page N ===" before each part; parts are joined
    # by a newline.
    LC_ALL=C awk 'BEGIN { RS = "\f"; n = 0 }
        {
            n++
            if (n > 1) printf "\n"
            printf "=== PDF page %d ===\n%s", n, $0
        }
        END { if (n == 0) exit 1; print n > "/dev/stderr" }' "$TMP/utf8.txt" \
        > "$TMP/paged.txt" 2> "$TMP/count" || fail "page marking failed"
    parts=$(cat "$TMP/count")
    # awk sees no record after a final form feed; add the empty last part.
    last=$(tail -c 1 "$TMP/utf8.txt" | od -An -c | tr -d ' ')
    if [ "$last" = '\f' ]; then
        printf '\n=== PDF page %d ===\n' $((parts + 1)) >> "$TMP/paged.txt"
    fi
fi

# 4. Check the text.
got=$(sha256_of "$TMP/paged.txt")
[ "$got" = "$TXT_SHA256" ] || fail "text SHA-256 mismatch: got $got, expected $TXT_SHA256"
cp "$TMP/paged.txt" "$TXT" || fail "cannot write $TXT"

printf 'rebuild-source: %s and %s match the recorded SHA-256 values\n' "$PDF" "$TXT"
