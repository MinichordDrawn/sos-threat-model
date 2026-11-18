"""Scratch: an independent implementation of model-spec.md, written from the spec text only.

It shares no semantics code with check_model.py. Differences in method, on purpose:
  - environment sequences are enumerated exhaustively (every sequence of 0..f enabled
    steps), with no pruning by resulting state;
  - rounds are explored layer by layer (layer d = every state reachable in exactly d
    rounds without passing through a responded state), with no global visited set; the
    search stops when a layer repeats an earlier layer, at which point every later layer
    is a repeat too.
"""


def get(mapping, key):
    return mapping.get(key, [])


class Spec:
    def __init__(self, d):
        self.f = d["f"]
        self.monitors = list(d["monitors"])
        self.works = list(d["works"])
        self.joiner = d["joiner"]
        self.boundary = d["boundary"]
        self.substrate = d["substrate"]
        self.hb = d["hb_readers"]
        self.chk = d["checkers"]
        self.fwd = d["fwd"]
        self.halt_in = d["halt_inputs"]
        self.switches = list(d["switches"])
        self.coupling = d["coupling"]
        self.window = d["window"]
        self.monset = set(self.monitors)

    # state: dict-free tuple (alive, bad, hidden, off, flagged, halted, pending, joined)
    def init(self):
        e = frozenset()
        return (frozenset(self.monitors) | frozenset(self.works), e, e, e, e, e, e, False)

    def present(self, st):
        ps = list(self.monitors) + list(self.works)
        if st[7] and self.joiner is not None:
            ps.append(self.joiner)
        return ps

    def nonmon_present(self, st):
        ps = list(self.works)
        if st[7] and self.joiner is not None:
            ps.append(self.joiner)
        return ps

    def enabled(self, st):
        alive, bad, hidden, off, flagged, halted, pending, joined = st
        out = []
        # stop m
        for m in self.monitors:
            if m in alive:
                out.append(("stop", m))
        # stop-boundary b
        ids = []
        for m in self.monitors:
            if m in self.boundary and self.boundary[m] not in ids:
                ids.append(self.boundary[m])
        for b in ids:
            mem = [m for m in self.monitors if m in self.boundary and self.boundary[m] == b]
            if len(mem) >= 2 and any(m in alive for m in mem):
                out.append(("stop-boundary", b))
        # fail-substrate s
        pres = self.present(st)
        sids = []
        for p in pres:
            if p in self.substrate and self.substrate[p] not in sids:
                sids.append(self.substrate[p])
        for s in sids:
            ok = False
            for p in pres:
                if p in self.substrate and self.substrate[p] == s:
                    if p in self.monset:
                        if p in alive:
                            ok = True
                    else:
                        if p not in bad:
                            ok = True
            if ok:
                out.append(("fail-substrate", s))
        # mutate p
        for p in pres:
            if p not in bad:
                out.append(("mutate", p))
        # disable m
        for m in self.switches:
            if m not in off:
                out.append(("disable", m))
        # join
        if self.joiner is not None and not joined:
            out.append(("join", self.joiner))
        return out

    def apply(self, st, step):
        alive, bad, hidden, off, flagged, halted, pending, joined = st
        kind, arg = step
        if kind == "stop":
            alive = alive - {arg}
        elif kind == "stop-boundary":
            gone = {m for m in self.monitors if m in self.boundary and self.boundary[m] == arg}
            alive = alive - gone
        elif kind == "fail-substrate":
            for p in self.present(st):
                if p in self.substrate and self.substrate[p] == arg:
                    if p in self.monset:
                        alive = alive - {p}
                    else:
                        bad = bad | {p}
                        hidden = hidden | {p}
        elif kind == "mutate":
            bad = bad | {arg}
        elif kind == "disable":
            off = off | {arg}
        elif kind == "join":
            joined = True
            alive = alive | {arg}
        else:
            raise ValueError(kind)
        return (alive, bad, hidden, off, flagged, halted, pending, joined)

    def after_env(self, st):
        """Every (sequence, state) for sequences of 0..f enabled steps. No pruning."""
        results = [((), st)]
        level = [((), st)]
        for _ in range(self.f):
            nxt = []
            for seq, cur in level:
                for step in self.enabled(cur):
                    nxt.append((seq + (step,), self.apply(cur, step)))
            results.extend(nxt)
            level = nxt
        return results

    def monitor_and_work(self, st):
        alive, bad, hidden, off, flagged, halted, pending, joined = st
        active = {m for m in self.monitors if m in alive and m not in bad and m not in off}
        visible = bad - hidden
        fl = set(flagged)
        # 1. detection
        for m in self.monitors:
            if m not in active:
                continue
            det = False
            for x in visible:
                if m in get(self.chk, x):
                    det = True
            for p in self.monitors:
                if p not in alive and m in get(self.hb, p):
                    det = True
            if det:
                fl.add(m)
        # 2. propagation to a fixed point
        while True:
            add = set()
            for m in fl:
                if m in active:
                    for r in get(self.fwd, m):
                        if r in active and r not in fl:
                            add.add(r)
            if not add:
                break
            fl |= add
        # 3. out
        out = {m for m in fl if m in alive and m not in bad}
        # work phase
        h, pe = set(halted), set(pending)
        stepped = False
        for w in self.nonmon_present(st):
            if w in halted:
                continue
            if w in pending:
                pe.discard(w)
                h.add(w)
                continue
            ins = get(self.halt_in, w)
            sees = any(m in out for m in ins)
            if self.coupling and any(m not in alive for m in ins):
                sees = True
            if sees and self.window == 0:
                h.add(w)
            else:
                if sees:
                    pe.add(w)
                stepped = True
        g1 = len(bad) > 0 and len(out) == 0
        g2 = len(bad) > 0 and stepped
        return (alive, bad, hidden, off, frozenset(fl), frozenset(h), frozenset(pe), joined), g1, g2

    def responded(self, st):
        alive, bad, hidden, off, flagged, halted, pending, joined = st
        good = {m for m in flagged if m in alive and m not in bad}
        return len(good) > 0 and all(w in halted for w in self.nonmon_present(st))

    def result(self, cap_layers=10000):
        layer = frozenset([self.init()])
        seen_layers = set()
        res = {"G1": None, "G2": None}
        cache = {}
        all_states = set(layer)
        n = 0
        while layer not in seen_layers and n < cap_layers:
            seen_layers.add(layer)
            n += 1
            nxt = set()
            for st in layer:
                if self.responded(st):
                    continue
                for _seq, a in self.after_env(st):
                    if a not in cache:
                        cache[a] = self.monitor_and_work(a)
                    t, g1, g2 = cache[a]
                    if g1 and res["G1"] is None:
                        res["G1"] = n
                    if g2 and res["G2"] is None:
                        res["G2"] = n
                    nxt.add(t)
            layer = frozenset(nxt)
            all_states |= layer
        return res, len(all_states), n
