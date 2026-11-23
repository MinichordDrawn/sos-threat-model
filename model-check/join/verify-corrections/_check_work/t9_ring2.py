"""A13: the greatest sets computed from the list equal the family the write-up's four cases describe.
A2: one two-way link, rings of other shapes (for information)."""
import itertools
exec(open("t3_ring.py").read().split("FULL = (1 << 24) - 1")[0])
FULL = (1 << 24) - 1
for f in (1, 2, 3):
    Ls = sorted(listed(f))
    G = set(FULL & ~t for t in min_transversals(Ls))
    fam = set()
    for kind in ("cK", "rK", "fromK"):
        fam.add(FULL & ~mask([(kind, x) for x in A]))
    for t in range(0, f + 1):
        for T in itertools.combinations(A, t):
            for choice in itertools.product(("kc", "kr"), repeat=t):
                fam.add(FULL & ~mask([("toK", x) for x in A if x not in T] + [(c, x) for c, x in zip(choice, T)]))
    print("f=%d: greatest sets from the list %d; family of the four cases %d; equal: %s" % (f, len(G), len(fam), G == fam))

def ring2(f, edges, ab, kind):
    s = base_cycle(f, kind)
    for b in B:
        add_monitor(s, b)
    s["joiner"] = "WB"
    watch(s, "B1", "B2"); watch(s, "B2", "B3"); watch(s, "B3", "B1")
    report(s, "B1", "B3"); report(s, "B2", "B1"); report(s, "B3", "B2")
    for m in ("B1", "B2", "B3"):
        report(s, m, "KB"); report(s, "KB", m)
        if kind == "checking":
            watch(s, "KB", m)
        else:
            add(s, "hb_readers", m, "KB")
        if kind in ("checking", "reading"):
            watch(s, m, "KB")
    if kind == "nested":
        watch(s, "B1", "KB")
    for b in B:
        if kind == "checking" or b != "KB":
            add(s, "checkers", "WB", b)
        add(s, "halt_inputs", "WB", b)
    for k, x in edges:
        if k == "cK": add(s, "checkers", "KB", x)
        elif k == "rK": add(s, "hb_readers", "KB", x)
        elif k == "fromK": add(s, "fwd", "KB", x)
        elif k == "kc": add(s, "checkers", x, "KB")
        elif k == "kr": add(s, "hb_readers", x, "KB")
        elif k == "toK": add(s, "fwd", x, "KB")
    late_group(s, "B", B + ["WB"])
    s["arrive_bad"] = ab
    return s
for kind in ("checking", "reading", "nested"):
    for x in ("M1", "K"):
        six = [(k, x) for k in KINDS]
        print("  both rings cycles (%s coordinator), one two-way link KB-%s, one step, may arrive bad, f=1..4: %s"
              % (kind, x, [fmt(both(ring2(f, six, True, kind))) for f in (1, 2, 3, 4)]))
