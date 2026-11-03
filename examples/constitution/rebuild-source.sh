#!/bin/sh
# Rebuild the evidence the threat model cites: House Document 110-50, "The Constitution of the
# United States of America As Amended" (U.S. Government Printing Office, 2007), a work of the
# United States federal government in the public domain under 17 U.S.C. §105.
#
# Downloads the PDF, checks its SHA-256, extracts it with page_text.py (pdftotext 4.00, -layout,
# encoding Latin1) into constitution-paged.txt, and checks the text's SHA-256. Stops on any
# mismatch.
#
# Usage: sh rebuild-source.sh PAGE_TEXT_PY [PDFTOTEXT]
#   PAGE_TEXT_PY  path to page_text.py from the SOS threat-model kit (or set PAGE_TEXT_PY)
#   PDFTOTEXT     path to pdftotext 4.00 (default: pdftotext on PATH; or set PDFTOTEXT)
#   PYTHON        the Python interpreter to use (default: python)
# Writes constitution.pdf and constitution-paged.txt in the current directory.

set -eu

URL="https://www.govinfo.gov/content/pkg/CDOC-110hdoc50/pdf/CDOC-110hdoc50.pdf"
PDF_SHA256="7f29c4a79e310cc7bcee5f3fd07fb1367e463bd4530fa5d854ebdd4fd4402e57"
TXT_SHA256="82a4e5f1d5b7a183f332c1f41be06515badfb724a8b9deb13f4f68b8adb31f0e"
PDF="constitution.pdf"
TXT="constitution-paged.txt"

PAGE_TEXT="${1:-${PAGE_TEXT_PY:-}}"
PDFTOTEXT="${2:-${PDFTOTEXT:-pdftotext}}"
PYTHON="${PYTHON:-python}"

fail() {
    echo "rebuild-source: $*" >&2
    exit 1
}

[ -n "$PAGE_TEXT" ] || fail "give the path to page_text.py as the first argument"
[ -f "$PAGE_TEXT" ] || fail "page_text.py not found: $PAGE_TEXT"

sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | cut -d ' ' -f 1
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | cut -d ' ' -f 1
    else
        fail "neither sha256sum nor shasum is available"
    fi
}

# pdftotext prints its version on standard error; the citations depend on version 4.00.
version="$("$PDFTOTEXT" -v 2>&1 | head -n 1)" || true
case "$version" in
    *" 4.00"*) ;;
    *) fail "pdftotext 4.00 is required; found: ${version:-none}" ;;
esac

if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$PDF" "$URL" || fail "download failed: $URL"
elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$PDF" "$URL" || fail "download failed: $URL"
else
    fail "neither curl nor wget is available"
fi

got="$(sha256 "$PDF")"
[ "$got" = "$PDF_SHA256" ] || fail "PDF SHA-256 mismatch: expected $PDF_SHA256, got $got"

"$PYTHON" "$PAGE_TEXT" "$PDF" "$TXT" --enc Latin1 --pdftotext "$PDFTOTEXT" \
    || fail "extraction failed"

got="$(sha256 "$TXT")"
[ "$got" = "$TXT_SHA256" ] || fail "text SHA-256 mismatch: expected $TXT_SHA256, got $got"

echo "rebuild-source: $PDF and $TXT match the recorded checksums"
