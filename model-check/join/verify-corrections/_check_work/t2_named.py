"""Named systems of the corrected statements: A7, A3/A8/A9, A10/A11 (chain), section 5 row, A14."""
import copy
from build import *


def tr(s, which="t1"):
    r = M(s).solve(trace=True)
    if r[which]:
        show_trace(r[which])
    return r


print("=== A7: off switch on a leaned-on late monitor")
def a7(f, arrive_bad=False, switch=True):
    s = base_mesh(f)
    add_monitor(s, "N5"); add_monitor(s, "N6")
    watch(s, "M1", "N5"); report(s, "N5", "M1")
    watch(s, "N5", "N6"); report(s, "N6", "N5")
    late_group(s, "N5", ["N5"]); late_group(s, "N6", ["N6"], after=["N5"])
    s["switches"] = ["N5"] if switch else []
    s["arrive_bad"] = arrive_bad
    return s
for ab in (False, True):
    for sw in (True, False):
        print("  arrive_bad=%s switch=%s: f=1,2,3 ->" % (ab, sw), [fmt(both(a7(f, ab, sw))) for f in (1, 2, 3)])
m = M(a7(1))
print("  replay of the table in the write-up (f=1, arrive good):")
for labs, d, v1, v2, resp in m.replay([["join N5"], ["join N6"], ["disable N5"], ["mutate N6"]]):
    print("   |", ", ".join(labs), "|", d, "| G1 violated:", v1, "G2 violated:", v2, "responded:", resp)
print("  least-round witnesses found by search (G1 then G2):")
r = tr(a7(1), "t1"); print("   ->", fmt(r)); tr(a7(1), "t2")

print("=== Theorem L: each of the three edges slow, on the chain N5<-M1, N6<-N5")
def slowchain(f, slow, ab):
    s = a7(f, ab, switch=False)
    s["slow_edges"] = [slow]
    return s
for slow in (["checkers", "N6", "N5"], ["hb_readers", "N5", "M1"], ["fwd", "N5", "M1"], ["checkers", "N5", "M1"]):
    print("  slow", slow, "good f=1,2,3:", [fmt(both(slowchain(f, slow, False))) for f in (1, 2, 3)],
          "may arrive bad:", [fmt(both(slowchain(f, slow, True))) for f in (1, 2, 3)])

print("=== section 5 row: N in a mesh with M1,M2,M3; the three checks of N a round late, the rest at once")
def s5(f, ab, slowkind):
    s = base_mesh(f)
    add_monitor(s, "N")
    for x in ("M1", "M2", "M3"):
        mesh_pair(s, "N", x)
    late_group(s, "N", ["N"])
    s["arrive_bad"] = ab
    if slowkind == "checks":
        s["slow_edges"] = [["checkers", "N", x] for x in ("M1", "M2", "M3")]
    return s
print("  good:", [fmt(both(s5(f, False, "checks"))) for f in (1, 2, 3)], " may arrive bad:", [fmt(both(s5(f, True, "checks"))) for f in (1, 2, 3)])
print("  (none slow) good:", [fmt(both(s5(f, False, None))) for f in (1, 2, 3)], " may arrive bad:", [fmt(both(s5(f, True, None))) for f in (1, 2, 3)])

print("=== A3 / section 4.3 table: N in a mesh with k monitors, J joins with N, checked by N, halting on N and the k")
def s43(f, k, ab):
    s = base_mesh(f)
    add_monitor(s, "N")
    ks = ["M1", "M2", "M3", "K"][:k]
    for x in ks:
        mesh_pair(s, "N", x)
    s["joiner"] = "J"
    add(s, "checkers", "J", "N")
    for x in ["N"] + ks:
        add(s, "halt_inputs", "J", x)
    late_group(s, "NJ", ["N", "J"])
    s["arrive_bad"] = ab
    return s
for k in (1, 2, 3, 4):
    for ab in (False, True):
        print("  k=%d arrive_bad=%s f=1..4:" % (k, ab), [fmt(both(s43(f, k, ab))) for f in (1, 2, 3, 4)])
print("  k=1 f=2 witness (G2):")
tr(s43(2, 1, False), "t2")

print("=== chain of section 6.2: N5 on M1, N6 on N5, N7 on N6 (one watcher each), new monitors may arrive bad")
def chain(f, ab=True, drop=None):
    s = base_mesh(f)
    prev = "M1"
    for n in ("N5", "N6", "N7"):
        add_monitor(s, n)
        watch(s, prev, n); report(s, n, prev)
        late_group(s, n, [n], after=[] if prev == "M1" else [prev])
        prev = n
    if drop:
        rem(s, *drop)
    s["arrive_bad"] = ab
    return s
rows = [("as built", None),
        ("N5 does not check N6's state", ("checkers", "N6", "N5")),
        ("N5 does not read N6's signal", ("hb_readers", "N6", "N5")),
        ("N6 does not report to N5", ("fwd", "N6", "N5")),
        ("N6 does not check N7's state", ("checkers", "N7", "N6")),
        ("N6 does not read N7's signal", ("hb_readers", "N7", "N6")),
        ("N7 does not report to N6", ("fwd", "N7", "N6"))]
for name, d in rows:
    s1 = chain(1, True, d)
    # does every monitor have a state checker (other than itself) that is present whenever it is?
    unchecked = [m for m in s1["monitors"] if not [c for c in s1["checkers"].get(m, []) if c != m]]
    print("  %-30s may arrive bad f=1,2,3: %s | arrive good: %s | monitors with no state checker: %s"
          % (name, [fmt(both(chain(f, True, d))) for f in (1, 2, 3)], [fmt(both(chain(f, False, d))) for f in (1, 2, 3)], unchecked))
print("  A11: 'N5 does not read N6's signal', f=1, arrive good: replay of the five-round table")
d = ("hb_readers", "N6", "N5")
for labs, dd, v1, v2, resp in M(chain(1, False, d)).replay([["join N5"], ["join N6"], ["stop N6"], ["join N7"], ["mutate N7"]]):
    print("   |", ", ".join(labs), "|", dd, "| G1:", v1, "G2:", v2)
print("  same, may arrive bad: witness found by search")
tr(chain(1, True, d), "t1")
print("  A8: chain as built at f=4 (base rate is 3):", fmt(both(chain(4, True, None))))

print("=== A14: mesh grown to eight in meshes, slow reports, f=1")
def eight(f, ab, slow_reports=True, order=True):
    s = base_mesh(f)
    att = {"N5": ["M1", "M2", "M3"], "N6": ["N5", "M1", "M2"], "N7": ["N5", "N6", "M1"], "N8": ["N5", "N6", "N7"]}
    for n, xs in att.items():
        add_monitor(s, n)
        for x in xs:
            mesh_pair(s, n, x)
        late_group(s, n, [n], after=[x for x in xs if x.startswith("N")] if order else [])
    s["arrive_bad"] = ab
    s["slow_reports"] = slow_reports
    return s
for ab in (False, True):
    r = M(eight(1, ab)).solve(limit=400000)
    g = indep.Model(eight(1, ab)).solve(state_limit=400000)
    print("  arrive_bad=%s: mine %s (states %d, complete %s); independent_model.py: %s" % (ab, fmt(r), r["states"], r["complete"], g))
print("  replay of the table (arrive good):")
for labs, dd, v1, v2, resp in M(eight(1, False)).replay([["join N5"], ["join N6"], ["join N7"], ["join N8"], ["mutate N8"]]):
    print("   |", ", ".join(labs), "|", dd, "| G1:", v1, "G2:", v2)
print("  may arrive bad: replay join N5, join N6, join N7, join-bad N8 N8")
for labs, dd, v1, v2, resp in M(eight(1, True)).replay([["join N5"], ["join N6"], ["join N7"], ["join-bad N8 N8"]]):
    print("   |", ", ".join(labs), "|", dd, "| G1:", v1, "G2:", v2)
print("  boundary counterexample system of 6.1 (no slow reports), f=1..4:", [fmt(both(eight(f, True, False))) for f in (1, 2, 3, 4)])
