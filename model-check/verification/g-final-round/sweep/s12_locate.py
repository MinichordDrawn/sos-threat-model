"""Locate quoted phrases in README.md and results.md (whitespace-insensitive), print line numbers."""
import bisect
import re
import sys
import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


MC = _mc()
PHRASES = [
    "every one of the properties is needed", "is what the four constraints assert, and no checker", "both can: the environment mutates M1 and M3",
    "loses G1 to that one step", "W1 never halts", "It holds for any system", "leaves out the module's comments",
    "in this one respect and in no other", "*can start first* if", "So the coordinator stands down only", "run on the one host",
    "in both implementations it does", "are wired this way", "Every system with two monitors and one work process",
    "which is what no gap means", "the ten schedules", "never the author's reasoning", "it ran no alternative",
    "Four statements were wrong", "Three of the verifiers' own corrections", "three of the verifiers' own corrections", "every system the checker ran",
    "To rerun:", "to name the faulty members when", "follow from them", "is itself an evaluation", "The second is argued",
    "| follows |", "the second argued", "This paragraph is argued", "the asteroid", "A lock is shown", "Someone has to go first",
    "does not come from responding", "It is not part of the problem", "the very step", "added later", "A finite check is a finite check",
    "it does not rise with scale", "does not rise with scale", "Its other difference", "This note answers one question", "They were independent of the reasoning",
    "They were not unaware", "It found the same at every size", "the gate made structural", "what the gate does by a check", "coupling rule",
    "execution-observation coupling", "surface view", "any plain system", "every reachable state of R", "the definition of a falsifier",
    "In 243 the path is one read long", "no work of its own", "checked every claim", "All of its rulings were applied",
    "Each folder under `verification/` holds", "four defects in the script, all fixed", "Two needed a wording fix", "reproduced every result",
    "stop everything in one boundary", "has each step redone", "Four cases are provided here", "Searched, by an independent agent",
    "is a widely used tool", "what none of them covered", "with no check that has to remember to run", "one edge or one setting",
    "the second face of P2", "a work process acts on a bad state at least once", "every other member must be reached from it",
    "the second for every `n` of 4 or more", "for every `n` of 2 or more, a share", "Each execution in a table below was replayed",
    "Add a fourth monitor to it", "nothing in it acts wrongly", "Scale accounts for this", "What holds in every one of those systems",
    "these two states and no third", "The rest is a claim about the systems being modelled", "one by one for the first and third rows",
    "The chief ones", "the tier", "tiers", "a sample of 4,890", "The model's coupling rule", "It is observed like any member",
    "Both implementations (section 10.5)", "Both are also proved", "Two things do not", "the reflex; the cascade", "P2's first face works",
    "the same reachability a flag needs", "turned to recovery", "an established model checker", "not unaware", "The model has been applied",
    "Every verifier therefore knew", "which checked every claim in both documents", "Two verifiers checked every claim",
]
for name in ("results.md", "README.md"):
    text = open(MC + "\\" + name, encoding="utf-8").read()
    offs = [0]
    for l in text.split("\n"):
        offs.append(offs[-1] + len(l) + 1)
    # normalised copy with a map back to original offsets
    norm_chars, back = [], []
    prev_space = False
    for i, ch in enumerate(text):
        if ch.isspace():
            if not prev_space:
                norm_chars.append(" "); back.append(i)
            prev_space = True
        else:
            norm_chars.append(ch); back.append(i); prev_space = False
    norm = "".join(norm_chars)
    print("=====", name)
    for p in PHRASES:
        q = re.sub(r"\s+", " ", p)
        hits = []
        start = 0
        while True:
            j = norm.find(q, start)
            if j < 0:
                break
            hits.append(bisect.bisect_right(offs, back[j]))
            start = j + 1
        if hits:
            print(f"  {p[:60]:<62} {hits[:14]}{' ...' if len(hits) > 14 else ''}")
