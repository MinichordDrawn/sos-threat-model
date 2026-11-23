"""Check 1: apply every entry of corrections-1.md to the 'before' file and compare with the file as it is now.
Two comparisons: exact (line for line, entries applied as literal text) and with white space normalised."""
import re, os, difflib
D = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
rd = lambda n: open(os.path.join(D, n), encoding="utf-8").read()
corr = rd("corrections-1.md")
assert "\r" not in corr
parts = re.split(r"^### ", corr, flags=re.M)[1:]
entries = []
for p in parts:
    head = p.split("\n", 1)[0]
    blocks = re.findall(r"````text\n(.*?)\n````", p, flags=re.S)
    assert len(blocks) == 2, head
    entries.append((head, blocks[0], blocks[1]))
print(len(entries), "entries:", [e[0].split(".")[0] for e in entries])

def norm(t):
    return re.sub(r"\s+", " ", t).strip()

for label, bf, af, pick in (("results-join", "results-join.before-corrections-1.md", "results-join.md", "A"),
                            ("model-spec-join", "model-spec-join.before-corrections-1.md", "model-spec-join.md", "B")):
    before, after = rd(bf), rd(af)
    print("==", label, "CR in files:", "\r" in before, "\r" in after)
    cur = before
    curn = norm(before)
    for head, b, a in entries:
        if not head.startswith(pick):
            continue
        removed = a.strip() == "(nothing: the passage is removed)"
        cb, ca = before.count(b), after.count(a) if not removed else None
        nb = curn.count(norm(b))
        na = norm(after).count(norm(a)) if not removed else None
        # exact application
        ok_exact = cur.count(b) == 1
        if ok_exact:
            if removed:
                # remove the lines including their line end
                cur = cur.replace(b + "\n", "", 1)
            else:
                cur = cur.replace(b, a, 1)
        if nb == 1:
            curn = curn.replace(norm(b), "" if removed else norm(a), 1)
            curn = norm(curn)
        print("  %-4s before-text found in before-file: exact %d, normalised %d | after-text found in file now: exact %s, normalised %s"
              % (head.split(".")[0], cb, nb, ca, na))
    print("  exact: before-file with every entry applied == file now:", cur == after)
    print("  white space normalised: same:", curn == norm(after))
    if cur != after:
        for l in difflib.unified_diff(cur.split("\n"), after.split("\n"), lineterm="", n=0):
            print("     ", l)
    # hunks
    sm = difflib.SequenceMatcher(None, before.split("\n"), after.split("\n"), autojunk=False)
    hunks = [op for op in sm.get_opcodes() if op[0] != "equal"]
    print("  changed hunks (line diff):", len(hunks), "; lines before", before.count("\n"), "after", after.count("\n"))
