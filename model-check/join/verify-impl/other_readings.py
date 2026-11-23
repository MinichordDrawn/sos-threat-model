"""Answers under other readings of the specification, to see which cases a
reading changes.  usage: python other_readings.py NAME [state limit]

Each reading is model.py with one rule replaced.  The readings are described
in the hand-back; the names here are the ones it uses.
"""
import collections
import json
import os
import sys

from model import Model

HERE = os.path.dirname(os.path.abspath(__file__))


class MutateNeedsAlive(Model):
    """R1.  J4 `mutate p` read as not applying to a stopped monitor (the
    parenthesis of section 3.1 that said it does is not in the J4 table)."""

    def env_steps(self, st):
        alive = st[0]
        out = []
        for t in Model.env_steps(self, st):
            if t[1] != st[1] and t[0] == alive and t[7] == st[7] and t[2] == st[2]:
                b = t[1] ^ st[1]            # the process this mutate step made bad
                if (b & self.MON) and not (b & alive):
                    continue
            out.append(t)
        return out


READINGS = {"R1": MutateNeedsAlive}


def main():
    name = sys.argv[1]
    limit = int(sys.argv[2]) if len(sys.argv) > 2 else 3000000
    cls = READINGS[name]
    data = json.load(open(os.path.join(HERE, "systems-join.json")))
    main_answers = json.load(open(os.path.join(HERE, "answers.json")))
    out = []
    diff = []
    unfinished = []
    for n, (c, x) in enumerate(zip(data, main_answers)):
        g1, g2, ns, ok = cls(c["system"]).solve(state_limit=limit)
        if not ok:
            unfinished.append(c["id"])
        out.append({"id": c["id"], "G1": g1, "G2": g2, "complete": ok})
        if ok and (g1, g2) != (x["G1"], x["G2"]):
            diff.append({"id": c["id"], "main": [x["G1"], x["G2"]], "other": [g1, g2]})
        if (n + 1) % 1000 == 0:
            print(name, "done", n + 1, "differ", len(diff), "unfinished", len(unfinished), flush=True)
    with open(os.path.join(HERE, "other-%s.json" % name), "w") as fh:
        json.dump({"reading": name, "what": cls.__doc__, "answers": out, "differ": diff,
                   "unfinished": unfinished}, fh, indent=0)
    print(name, "cases", len(out), "differ", len(diff), "unfinished", len(unfinished), flush=True)
    print("by family:", sorted(collections.Counter(d["id"].split("/")[0] for d in diff).items()), flush=True)
    print("by change:", sorted(collections.Counter(
        "%s -> %s" % (d["main"], d["other"]) for d in diff).items(), key=lambda kv: -kv[1])[:15], flush=True)
    for d in diff[:8]:
        print("  ", d, flush=True)


if __name__ == "__main__":
    main()
