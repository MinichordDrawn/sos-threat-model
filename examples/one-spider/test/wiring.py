# Usage: python wiring.py <the folder that holds the model check's check_model.py> [faults a round ...]
# as in: python test/wiring.py ../../model-check 1 2 3 4
#
# The game's wiring, as one system of the model check: two rings that share a
# member. The spider's ring: legs A, legs B, body and the coordinator "whole", over the two
# sets of legs and the body. The world's ring: edge, moths, web, "whole" again and the
# coordinator "page", over the edge, the moths with the counts and the shop, the web, and
# what the game keeps for itself (the pointer, what has been asked of it, and chance).
# Inside a ring every member checks every other member and every part of that ring. Every
# part halts on a flag from any monitor: one detection stops the whole game.
#
# Each monitor is given a boundary of its own. That is the game's own scale: inside it, what
# can be lost is one observer. The loss of the whole program is not an event in this system.
import sys
sys.path.insert(0, sys.argv[1])
import check_model as cm

SPIDER, WORLD = ["legsA", "legsB", "body", "whole"], ["edge", "moths", "web", "whole", "page"]
PARTS = {"first legs": SPIDER, "second legs": SPIDER, "the body": SPIDER, "the edge": WORLD, "moths counts shop": WORLD, "the web": WORLD, "pointer requests chance": WORLD}

def build(f):
    s = cm.System("the spider's ring and the world's ring sharing 'whole', eight monitors, seven parts", f)
    s.monitors = ["legsA", "legsB", "body", "whole", "edge", "moths", "web", "page"]
    s.works = list(PARTS)
    s.boundary = {m: i for i, m in enumerate(s.monitors)}
    for ring in (SPIDER, WORLD):
        for m in ring:
            for x in ring:
                if x != m:
                    cm.add(s.hb_readers, m, x); cm.add(s.checkers, m, x); cm.add(s.fwd, m, x)
    for w, ring in PARTS.items():
        s.checkers[w] = list(ring)
        s.halt_inputs[w] = list(s.monitors)
    return s

# The four conditions of Theorem S, checked on the graph directly.
def conditions(s):
    M = s.monitors
    watches = lambda r, z: r in s.checkers.get(z, []) and r in s.hb_readers.get(z, [])
    def reach(start, avoid=None):
        seen, todo = set(), [start]
        while todo:
            x = todo.pop()
            if x in seen or x == avoid: continue
            seen.add(x); todo += s.fwd.get(x, [])
        return seen
    a = all(any(r != z and watches(r, z) for r in M) for z in M)
    b = all(s.checkers.get(w) and len(set(s.halt_inputs.get(w, []))) >= 2 for w in s.works)
    c = all(any(r != z and watches(r, z) and y in reach(r, avoid=z) for r in M) for z in M for y in M if y != z)
    d = all(any(set(M) <= reach(k) for k in s.checkers.get(w, [])) for w in s.works)
    plain = s.joiner is None and not s.substrate and not s.switches and s.coupling and s.window == 0 and s.gate and not s.slow_reports \
            and len(set(s.boundary.values())) == len(M)
    return plain, a, b, c, d

s = build(1)
print(s.name)
print("  plain, (a), (b), (c), (d):", conditions(s))
for f in [int(n) for n in sys.argv[2:]] or [1]:
    found, states = cm.explore(build(f))
    print(f"  f={f}: " + ", ".join(f"{g}: " + ("no violation" if found[g] is None else f"violated in round {len(found[g])}") for g in ("G1", "G2")) + f"; {states} states", flush=True)
    if found["G1"] is not None: cm.show(found["G1"])
    elif found["G2"] is not None: cm.show(found["G2"])
