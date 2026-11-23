"""Part A sections 2 and 5 from a1.json."""
import json, sys, os, itertools
sys.path.insert(0, os.path.dirname(__file__))
from ring import *
from a1_compute import NODES, ARROWS, arrows_of

D = json.load(open(os.path.join(os.path.dirname(__file__), "a1.json")))
AIDX = {a: i for i, a in enumerate(ARROWS)}
CAND = [("A", "B"), ("B", "C"), ("C", "A"), ("D", "A"), ("D", "B"), ("D", "C"), ("A", "D"), ("B", "D"), ("C", "D")]
CMASK = sum(1 << AIDX[a] for a in CAND)
MESH = 4095


def perm_mask(mask, p):
    m = 0
    for i in range(12):
        if mask >> i & 1:
            x, y = ARROWS[i]
            m |= 1 << AIDX[(p.get(x, x), p.get(y, y))]
    return m


PERMS_ALL = [dict(zip("ABC", q)) for q in itertools.permutations("ABC")]
PERMS_TWO = [{}, {"B": "C", "C": "B"}]


def shapes(masks, work):
    perms = PERMS_ALL if work == "all" else PERMS_TWO
    return len({min(perm_mask(m, p) for p in perms) for m in masks})


def fmt(mask):
    return " ".join("%s->%s" % a for a in arrows_of(mask))


STATIC = {}
for rname, reading in READINGS.items():
    st = []
    for mask in range(4096):
        hb, chk, fwd = edges_of(arrows_of(mask), reading)
        st.append({"R2": R2(NODES, hb, chk), "R3": R3(NODES, hb, chk, "D"), "R4": True,
                   "R5": R5(NODES, fwd, "D"), "R4w": R4w(NODES, hb, chk), "R4wl": R4wl(NODES, hb, chk),
                   "nm": naming_search(NODES, watchers(NODES, hb, chk))})
    STATIC[rname] = st

# naming rule against brute force
for rname in READINGS:
    bad = [m for m in range(4096) if STATIC[rname][m]["R4w"] != STATIC[rname][m]["nm"]]
    print("naming at the wiring: rule vs search over cases, %s: %d disagreements" % (rname, len(bad)))


def meets(rname, work, f, mask, req):
    if req in ("R2", "R3", "R4", "R5", "R4w", "R4wl"):
        return STATIC[rname][mask][req]
    g1, g2, told = D["%s|%s|%d" % (rname, work, f)][mask]
    if req == "R1":
        return g1 is None and g2 is None
    if req == "R6":
        return g2 is None and told is None
    raise ValueError(req)


def least(rname, work, f, reqs):
    ok = [m for m in range(4096) if all(meets(rname, work, f, m, r) for r in reqs)]
    if not ok:
        return None, [], False
    k = min(bin(m).count("1") for m in ok)
    ls = [m for m in ok if bin(m).count("1") == k]
    return k, ls, CMASK in ok


ALL6 = ["R1", "R2", "R3", "R4", "R5", "R6"]
rows = [("R1", ["R1"]), ("R2", ["R2"]), ("R3", ["R3"]), ("R4", ["R4"]), ("R5", ["R5"]), ("R6", ["R6"]),
        ("R2+R5", ["R2", "R5"]), ("all but R2", ["R1", "R3", "R4", "R5", "R6"]), ("whole list", ALL6)]
for work in ("all", "two"):
    print("\n=== section 2.1, W reads %s: least connections (number of least wirings, shapes) ===" % work)
    for label, reqs in rows:
        cells = []
        for rname in ("flow", "actor"):
            for f in (1, 2, 3):
                k, ls, c = least(rname, work, f, reqs)
                cells.append("%s f%d: %s" % (rname, f, "none" if k is None else "%d (%d, %d)%s" % (
                    k, len(ls), shapes(ls, work), " cand-least" if CMASK in ls else "")))
        print("%-11s | %s" % (label, " | ".join(cells)))

print("\n=== candidate meets every requirement? ===")
for rname in ("flow", "actor"):
    for work in ("all", "two"):
        for f in (1, 2, 3):
            print(rname, work, f, {r: meets(rname, work, f, CMASK, r) for r in ALL6 + ["R4w", "R4wl"]},
                  D["%s|%s|%d" % (rname, work, f)][CMASK])

print("\n=== candidate among the least: over all 63 combinations ===")
for rname in ("flow", "actor"):
    for work in ("all", "two"):
        for f in (1, 2, 3):
            yes, unmeet, no = [], [], []
            for n in range(1, 7):
                for combo in itertools.combinations(ALL6, n):
                    k, ls, c = least(rname, work, f, combo)
                    if k is None:
                        unmeet.append(combo)
                    elif CMASK in ls:
                        yes.append(combo)
                    else:
                        no.append(combo)
            y_r2r5 = [c for c in yes if "R2" in c and "R5" in c]
            n_r2r5 = [c for c in no if "R2" in c and "R5" in c]
            print("%s %s f=%d: candidate least in %d combos (of them with R2 and R5: %d); "
                  "not least in %d (with R2 and R5: %d); cannot be met at all: %d" % (
                      rname, work, f, len(yes), len(y_r2r5), len(no), len(n_r2r5), len(unmeet)))

print("\n=== 2.2: R2+R5 least wirings against the whole list ===")
for rname in ("flow", "actor"):
    for f in (1, 2, 3):
        k, ls, _ = least(rname, "all", f, ["R2", "R5"])
        k2, ls2, _ = least(rname, "all", f, ALL6)
        gone = [m for m in ls if m not in ls2]
        why = {}
        for m in gone:
            w = tuple(r for r in ALL6 if not meets(rname, "all", f, m, r))
            why.setdefault(w, []).append(m)
        print(rname, f, "R2+R5:", k, len(ls), "whole:", k2, len(ls2), "removed:",
              {w: len(v) for w, v in why.items()}, "shapes of removed:",
              {w: shapes(v, "all") for w, v in why.items()})
        if rname == "actor" and f == 1:
            for m in gone:
                print("   removed under actor:", fmt(m))

print("\n=== 2.3: the least wirings, one per shape ===")
for rname in ("flow", "actor"):
    for f in (1, 3):
        k, ls, _ = least(rname, "all", f, ALL6)
        reps = sorted({min(perm_mask(m, p) for p in PERMS_ALL) for m in ls})
        print(rname, "f=%d" % f, k, "connections,", len(ls), "wirings,", len(reps), "shapes")
        for r in reps:
            print("    ", fmt(r), "  <- candidate" if r == min(perm_mask(CMASK, p) for p in PERMS_ALL) else "",
                  "  <- candidate minus one D-arrow" if any(
                      r == min(perm_mask(CMASK & ~(1 << AIDX[("D", x)]), p) for p in PERMS_ALL) for x in "ABC") else "")

print("\n=== 2.4: remove one connection from the candidate ===")
for rname in ("flow", "actor"):
    for a in CAND:
        m = CMASK & ~(1 << AIDX[a])
        res = {}
        for work in ("all", "two"):
            for f in (1, 2, 3):
                was = [r for r in ALL6 if meets(rname, work, f, CMASK, r)]
                res[(work, f)] = tuple(r for r in was if not meets(rname, work, f, m, r))
        vals = set(res.values())
        print(rname, "%s->%s" % a, "fails:", vals if len(vals) > 1 else list(vals)[0],
              "| R4w %s R4wl %s" % (STATIC[rname][m]["R4w"], STATIC[rname][m]["R4wl"]))
    # two of D's downward arrows under flow / two upward watches
    for x, y in itertools.combinations("ABC", 2):
        m = CMASK & ~(1 << AIDX[("D", x)]) & ~(1 << AIDX[("D", y)])
        print(rname, "minus D->%s, D->%s fails:" % (x, y), [r for r in ALL6 if not meets(rname, "all", 1, m, r)])

print("\n=== R4wl added to the whole list ===")
for rname in ("flow", "actor"):
    for work in ("all", "two"):
        for f in (1, 2, 3):
            k, ls, c = least(rname, work, f, ALL6 + ["R4wl"])
            if k is None:
                print(rname, work, f, "none")
                continue
            print(rname, work, f, k, len(ls), "wirings", shapes(ls, work), "shapes; candidate least:", CMASK in ls)
            if work == "all" and f == 1:
                for r in sorted({min(perm_mask(m, p) for p in PERMS_ALL) for m in ls}):
                    print("    ", fmt(r))
    for a in CAND:
        m = CMASK & ~(1 << AIDX[a])
        print("  ", rname, "candidate minus %s->%s: R4wl %s" % (a[0], a[1], STATIC[rname][m]["R4wl"]),
              "fails:", [r for r in ALL6 + ["R4wl"] if not meets(rname, "all", 1, m, r)])
    k, ls, c = least(rname, "all", 1, ALL6 + ["R4w"])
    print("  with R4w only:", rname, k, len(ls), CMASK in ls)

print("\n=== 2.5: links with no direction ===")
PAIRS = list(itertools.combinations(NODES, 2))
for rname in ("flow", "actor"):
    for work, fs in (("all", (1, 2, 3)), ("two", (1,))):
        for f in fs:
            ok = []
            for lm in range(64):
                mask = 0
                for i, (x, y) in enumerate(PAIRS):
                    if lm >> i & 1:
                        mask |= 1 << AIDX[(x, y)] | 1 << AIDX[(y, x)]
                if all(meets(rname, work, f, mask, r) for r in ALL6):
                    ok.append(lm)
            k = min(bin(m).count("1") for m in ok)
            ls = [m for m in ok if bin(m).count("1") == k]
            print(rname, work, f, "least links:", k, "wirings:", len(ls),
                  [[PAIRS[i] for i in range(6) if m >> i & 1] for m in ls] if (work == "all" and f == 1 and rname == "flow") else "")

print("\n=== section 5: the mesh against the candidate ===")
for rname in ("flow", "actor"):
    for work in ("all", "two"):
        for f in (1, 2, 3):
            key = "%s|%s|%d" % (rname, work, f)
            st = {r: (STATIC[rname][CMASK][r], STATIC[rname][MESH][r]) for r in ("R2", "R3", "R5", "R4w", "R4wl")}
            print(rname, work, f, "candidate [G1,G2,told]:", D[key][CMASK], "mesh:", D[key][MESH],
                  "same" if D[key][CMASK] == D[key][MESH] and all(a == b for a, b in st.values()) else "DIFFERENT")
