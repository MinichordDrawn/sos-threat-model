"""B3: a system on which 'mutate applies to a stopped monitor' matters."""
from build import *
s = empty(1, ["m", "c", "g1", "g2"], ["W"])
add(s, "checkers", "m", "c")            # c checks m; nobody reads m's signal
watch(s, "m", "c")                      # m watches c
add(s, "checkers", "c", "g1")           # g1 also checks c
report(s, "c", "g1"); report(s, "m", "g1")
mesh_pair(s, "g1", "g2")
for g in ("g1", "g2"):
    add(s, "checkers", "W", g); add(s, "halt_inputs", "W", g)
r = M(s).solve(trace=True)
print("as specified (mine):", fmt(r), "| independent_model.py:", indep.Model(s).solve()[:2])
show_trace(r["t1"])
print("if mutate needed a monitor still in alive:", fmt(M(s, alt_mutate_alive_only=True).solve()))
