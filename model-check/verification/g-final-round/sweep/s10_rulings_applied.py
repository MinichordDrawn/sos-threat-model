"""Last step: for each wording the reconciler proposed (a bullet of the form
'- <place>: "<wording>"' in reconciliation.md), is that wording in the corrected documents?
Prints the rulings whose proposed wording is not found word for word."""
import re
import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


MC = _mc()


def norm(t):
    return re.sub(r"\s+", " ", t).strip()


docs = norm(open(MC + r"\README.md", encoding="utf-8").read()) + " " + norm(open(MC + r"\results.md", encoding="utf-8").read())
lines = open(MC + r"\verification\g-final-round\reconciliation.md", encoding="utf-8").read().split("\n")
cur = None
found = missing = 0
per = {}
for l in lines:
    m = re.match(r"\*\*(R\d+)\.", l)
    if m:
        cur = m.group(1)
        continue
    if cur and l.startswith("- ") and ': "' in l:
        body = l.split(': "', 1)[1]
        body = body.rstrip()
        if body.endswith('"'):
            body = body[:-1]
        elif '"' in body:
            body = body[:body.rfind('"')]
        w = norm(body)
        w2 = w.replace("**", "")
        ok = w in docs or w2 in docs.replace("**", "")
        per.setdefault(cur, []).append((ok, w))
        found += ok
        missing += (not ok)
print("proposed wordings:", found + missing, "found word for word:", found, "not found:", missing)
for r, items in per.items():
    for ok, w in items:
        if not ok:
            # longest prefix found, to show where the text diverges
            lo, hi = 0, len(w)
            while lo < hi:
                mid = (lo + hi + 1) // 2
                if w[:mid].replace("**", "") in docs.replace("**", ""):
                    lo = mid
                else:
                    hi = mid - 1
            print(f"\n{r}: NOT FOUND. Matches up to char {lo} of {len(w)}.")
            print("   proposed:", w[:max(0, lo - 60)][-0:][:0] + w[max(0, lo - 80):lo + 160])
