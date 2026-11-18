"""The other reading of 'work process' in E2, E3, E5: the joiner counted as a work process.

Checks, on random systems, the exact condition derived in claims2-verdicts.md:
  E2/E3 with `works` empty and a joiner:  G2 = 1  iff  f >= 2.
  E5 with w = the joiner (no member of `works` qualifies): f >= 2 implies G2 = 1; f = 1 can fail."""
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from test_claims import rand_system  # noqa: E402
from test_bounded import least_upto  # noqa: E402


def main(n):
    rng = random.Random(5)
    for label, fixed in (("E2", dict(window=1, gate=True)), ("E3", dict(gate=False))):
        tally = {}
        bad = 0
        for _ in range(n):
            S = rand_system(rng, nmon=rng.randint(0, 3), nwork=0, joiner=True, **fixed)
            is1 = least_upto(S, 1)["G2"] == 1
            key = ("f=1" if S["f"] == 1 else "f>=2", "G2=1" if is1 else "G2!=1")
            tally[key] = tally.get(key, 0) + 1
            if is1 != (S["f"] >= 2):
                bad += 1
                print(label, "MISMATCH", S)
        print("%s, joiner is the only work process: %d systems, mismatches with 'G2 = 1 iff f >= 2': %d, tally %s"
              % (label, n, bad, sorted(tally.items())))
    tally = {}
    bad = done = 0
    while done < n:
        S = rand_system(rng, nmon=rng.randint(1, 3), nwork=rng.randint(0, 1), joiner=True,
                        gate=True, window=0, slow_reports=False)
        mons = set(S["monitors"])
        qual = lambda w: bool(S["halt_inputs"].get(w)) and not (set(S["checkers"].get(w, [])) & mons)
        if not qual("j") or any(qual(w) for w in S["works"]):
            continue
        done += 1
        is1 = least_upto(S, 1)["G2"] == 1
        key = ("f=1" if S["f"] == 1 else "f>=2", "G2=1" if is1 else "G2!=1")
        tally[key] = tally.get(key, 0) + 1
        if S["f"] >= 2 and not is1:
            bad += 1
            print("E5 MISMATCH", S)
    print("E5, only the joiner qualifies as w: %d systems, f >= 2 but G2 != 1: %d, tally %s"
          % (n, bad, sorted(tally.items())))


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 1500)
