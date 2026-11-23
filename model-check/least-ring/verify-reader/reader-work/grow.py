"""Part D: the thirteen-monitor tower with only ring 1 present at the start."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from tower import system


def ring_groups(i, after_first, whole):
    a, b, c, d, w = ("A%d" % i, "B%d" % i, "C%d" % i, "D%d" % i, "W%d" % i)
    if whole:
        return [{"name": "ring%d" % i, "members": [d, a, b, c, w], "after": list(after_first)}]
    gs = [{"name": d, "members": [d], "after": list(after_first)}]
    for x in (a, b, c):
        gs.append({"name": x, "members": [x], "after": [d]})
    gs.append({"name": w, "members": [w], "after": [a, b, c, d]})
    return gs


def order_groups(order):
    if order == "author":
        return ring_groups(2, [], False) + ring_groups(3, ["W2"], False) + \
            [{"name": "T", "members": ["T"], "after": ["W3"]}]
    if order == "author-loose":
        return ring_groups(2, [], False) + ring_groups(3, [], False) + \
            [{"name": "T", "members": ["T"], "after": ["W2", "W3"]}]
    if order == "top-after-ring-2":
        return ring_groups(2, [], False) + [{"name": "T", "members": ["T"], "after": ["W2"]}] + \
            ring_groups(3, ["T"], False)
    if order == "whole":
        return ring_groups(2, [], True) + ring_groups(3, ["W2"], True) + \
            [{"name": "T", "members": ["T"], "after": ["W3"]}]
    if order == "top-first":
        return [{"name": "T", "members": ["T"], "after": []}] + ring_groups(2, ["T"], False) + \
            ring_groups(3, ["W2"], False)
    if order == "top-first-loose":
        return [{"name": "T", "members": ["T"], "after": []}] + ring_groups(2, ["T"], False) + \
            ring_groups(3, ["T"], False)
    if order == "whole-top-first":
        return [{"name": "T", "members": ["T"], "after": []}] + ring_groups(2, ["T"], True) + \
            ring_groups(3, ["W2"], True)
    raise ValueError(order)


ORDERS = ["author", "author-loose", "top-after-ring-2", "whole", "top-first", "top-first-loose",
          "whole-top-first"]


def grow_system(order, reading, f, work="all", scoped=False, freeze=True, max_rounds=None,
                arrive_bad=True):
    d = system(2, reading, work, f, scoped=scoped, freeze=freeze, max_rounds=max_rounds)
    d["late"] = order_groups(order)
    d["arrive_bad"] = arrive_bad
    return d


def present_sets(order):
    """All sets of present late processes the joins can reach (as frozensets of names)."""
    gs = order_groups(order)
    start = frozenset()
    seen = {start}
    todo = [start]
    initial = {"A1", "B1", "C1", "D1", "W1"}
    while todo:
        cur = todo.pop()
        for g in gs:
            mem = set(g["members"])
            if mem & cur:
                continue
            if all((x in cur) or (x in initial) for x in g.get("after", [])):
                nx = frozenset(cur | mem)
                if nx not in seen:
                    seen.add(nx)
                    todo.append(nx)
    return seen
