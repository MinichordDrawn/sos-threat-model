"""A system that satisfies every predicate form of section 3.2 and still has a gap at f = 1."""
import sys
import os as _os


def _mc(*parts):
    here = _os.path.dirname(_os.path.abspath(__file__))
    return _os.path.normpath(_os.path.join(here, "..", "..", "..", *parts))


sys.path.insert(0, _mc())
import check_model as cm
s = cm.ring(3, "same", 2)
f, n = cm.explore(s)
print(s.name, {g: (len(p) if p else None) for g, p in f.items()}, n, "states")
print("predicates:", cm.predicates(s))
print("plain:", cm.is_plain(s), "| conditions (a)-(d):", cm.sufficient_f1(s))
print("boundaries distinct:", len(set(s.boundary.values())) == len(s.monitors), "| switches:", s.switches, "| joiner:", s.joiner,
      "| window:", s.window, "| gate:", s.gate, "| coupling:", s.coupling, "| substrates:", s.substrate)
print("every monitor's signal has a reader in a different boundary:",
      all(any(s.boundary[r] != s.boundary[m] for r in s.hb_readers.get(m, ())) for m in s.monitors))
# the census: how many gap-free... the converse direction: systems with all four predicates true that have a gap (2 monitors, all 1,024)
bad = tot = 0
for sy in cm.small_systems(2, None, 1):
    p = cm.predicates(sy)
    if p["Q1"] and p["Q3"] and p["Q4"] and p["Q8"]:
        tot += 1
        if not cm.gap_free(sy):
            bad += 1
print("2 monitors, 1 work: systems satisfying Q1, Q3, Q4, Q8:", tot, "of which have a gap:", bad)
tot = bad = 0
seen = set()
for sy in cm.small_systems(3, 6000, 1):
    k = cm.key_of(sy)
    if k in seen:
        continue
    seen.add(k)
    p = cm.predicates(sy)
    if p["Q1"] and p["Q3"] and p["Q4"] and p["Q8"]:
        tot += 1
        if not cm.gap_free(sy):
            bad += 1
print("3 monitors, 1 work (the census sample): systems satisfying Q1, Q3, Q4, Q8:", tot, "of which have a gap:", bad)
