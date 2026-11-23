"""Run model.py over systems-join.json.

usage: python run.py [--workers N]

Results are appended to a cache file (one JSON line per case) as they are
computed, so an interrupted run resumes.  When every case is in the cache the
answer file is written, in the order of the catalogue.
"""
import json
import os
import sys
import time
from multiprocessing import Pool

from model import Model

HERE = os.path.dirname(os.path.abspath(__file__))

CACHE = "cache-main.jsonl"
ANSWERS = "answers.json"


def size_key(c):
    s = c["system"]
    return (len(s["monitors"]) * s["f"], len(s["monitors"]))


def work(arg):
    i, cid, system = arg
    t0 = time.time()
    g1, g2, ns, ok = Model(system).solve()
    return {"i": i, "id": cid, "G1": g1, "G2": g2, "states": ns, "complete": ok,
            "secs": round(time.time() - t0, 3)}


def main():
    workers = 1
    a = sys.argv[1:]
    while a:
        x = a.pop(0)
        if x == "--workers":
            workers = int(a.pop(0))
        else:
            raise SystemExit("unknown argument " + x)
    answer_name = ANSWERS
    cache_path = os.path.join(HERE, CACHE)
    data = json.load(open(os.path.join(HERE, "systems-join.json")))
    done = {}
    if os.path.exists(cache_path):
        for line in open(cache_path):
            line = line.strip()
            if line:
                r = json.loads(line)
                done[r["i"]] = r
    todo = [(i, c["id"], c["system"]) for i, c in enumerate(data) if i not in done]
    todo.sort(key=lambda t: size_key({"system": t[2]}))
    print("cases %d, cached %d, to do %d" % (len(data), len(done), len(todo)), flush=True)
    t0 = time.time()
    with open(cache_path, "a") as out:
        def take(r):
            done[r["i"]] = r
            out.write(json.dumps(r) + "\n")
            out.flush()
            if r["secs"] > 20 or len(done) % 500 == 0:
                print("%6.0fs  done %d/%d  last %s  %ss  states %d" % (
                    time.time() - t0, len(done), len(data), r["id"], r["secs"], r["states"]),
                    flush=True)
        if workers <= 1:
            for t in todo:
                take(work(t))
        else:
            with Pool(workers, maxtasksperchild=50) as pool:
                for r in pool.imap_unordered(work, todo, chunksize=1):
                    take(r)
    assert len(done) == len(data)
    incomplete = [done[i]["id"] for i in range(len(data)) if not done[i]["complete"]]
    answers = []
    for i, c in enumerate(data):
        r = done[i]
        assert r["id"] == c["id"]
        answers.append({"id": c["id"], "G1": r["G1"], "G2": r["G2"]})
    with open(os.path.join(HERE, answer_name), "w") as fh:
        json.dump(answers, fh, indent=0)
        fh.write("\n")
    print("wrote %s: %d answers, %d incomplete, total states %d, %.0fs" % (
        answer_name, len(answers), len(incomplete),
        sum(done[i]["states"] for i in range(len(data))), time.time() - t0))
    if incomplete:
        print("incomplete:", incomplete)


if __name__ == "__main__":
    main()
