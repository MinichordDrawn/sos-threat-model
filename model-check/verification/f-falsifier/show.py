"""Print the smallest falsifiers and the edge-minimal systems of a result file compactly.

    python -I show.py result_3x1.json [max-per-family]
"""
import json
import sys


def compact(s):
    def m(d):
        return " ".join(f"{k}:[{','.join(v)}]" for k, v in d.items())
    return (f"hb_readers {m(s['hb_readers'])} | checkers {m(s['checkers'])} | "
            f"fwd {m(s['fwd'])} | halt_inputs {m(s['halt_inputs'])}")


if __name__ == "__main__":
    res = json.load(open(sys.argv[1], encoding="utf-8"))
    cap = int(sys.argv[2]) if len(sys.argv) > 2 else 6
    for fam, info in res["families"].items():
        print(f"== no-spare falsifiers failing {fam}: min edges {info['min_edges']}, "
              f"{info.get('classes_at_min_edges', '?')} classes at that size, {info.get('classes', '?')} in all")
        for s in info["smallest"][:cap]:
            print("  ", compact(s))
    if "edge_minimal_systems" in res:
        print(f"== edge-minimal gap-free classes: {res['edge_minimal_gap_free_classes']}")
        for s in res["edge_minimal_systems"][:cap * 2]:
            print(f"   e={s['_edges']} fails={'+'.join(s['_failing']) or 'none'} spare={s['_spare']}  {compact(s)}")
