"""impl_a.py -- implementation of model-spec.md and spec-addendum.md, derived from those
two files alone.

Usage (run as `python -I impl_a.py ...`):
    impl_a.py                      compute results-a.json from systems.json (literal reading)
    impl_a.py --extra              compute results-a-extra.json from systems-extra.json
    impl_a.py --verify             recompute the cases of systems.json and compare with the
                                   existing results-a.json; writes nothing
    impl_a.py --crosscheck         (with any of the above) also run the set-based
                                   transcription and compare; `--max-states N` skips that
                                   second run for cases with more than N reachable states
    impl_a.py --variants           re-run every case of both files under each alternative
                                   reading and list the cases whose result changes

Two implementations live in this file:
  * `explore`      -- bitmask states, used for the results;
  * `explore_sets` -- a direct transcription of the specification with Python sets, used
                      only to cross-check the bitmask code (same reading, different code).

Exploration is a breadth-first search over rounds with a visited set, never cut short:
it ends only when a level adds no unseen state.
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))

# Readings. The defaults are the literal reading of the specification. Each key names an
# alternative reading that can be switched on to test whether it changes a result.
DEFAULT_OPTS = {
    # fail-substrate: literal = every present non-monitor on the substrate is added to
    # `hidden`, including one that was already in `bad` (and visible). Alternative
    # (False) = only those not yet in `bad` are added to `bad` and `hidden`.
    "hide_already_bad": True,
    # fail-substrate enabling: literal = a non-monitor counts only when not in `bad`.
    # Alternative (True) = a non-monitor counts when not in `hidden`.
    "substrate_enable_not_hidden": False,
    # stop-boundary: literal = at least two monitors have the boundary (alive or not) and
    # one is alive. Alternative (True) = at least two of them are alive.
    "boundary_two_alive": False,
    # `out`: literal = flagged, alive, not bad (a switched-off flagged monitor stays in
    # `out`). Alternative (True) = also not in `off`.
    "out_excludes_off": False,
    # responded: literal = flagged, alive, not bad. Alternative (True) = also not in `off`.
    "responded_excludes_off": False,
    # heartbeat detection: literal = recomputed every round from `alive`.  (no alternative)
    # --- addendum ---
    # gate false: the addendum replaces only `out` in the work phase. Literal = the silence
    # clause (coupling) still reads `alive` as it is after this round's environment phase.
    # Alternative (True) = silence is delayed like flags: it reads `alive` as it was at the
    # start of the round.
    "gate_silence_delayed": False,
    # slow_reports: literal = the single pass starts from the monitors in `flagged` at the
    # start of the round. Alternative (True) = it starts from `flagged` after this round's
    # detection (one hop per round, but a new detector forwards at once). The addendum's
    # last sentence excludes the alternative; it is here only to measure its effect.
    "slow_from_post_detection": False,
}


def bits(x):
    """Indices of the set bits of x."""
    while x:
        low = x & -x
        yield low.bit_length() - 1
        x ^= low


class Model:
    def __init__(self, sysd, opts=None):
        self.opts = dict(DEFAULT_OPTS)
        if opts:
            self.opts.update(opts)
        self.f = sysd["f"]
        if not (isinstance(self.f, int) and self.f >= 1):
            raise ValueError("f must be an integer >= 1")
        monitors = list(sysd["monitors"])
        works = list(sysd["works"])
        joiner = sysd.get("joiner")
        names = monitors + works + ([joiner] if joiner is not None else [])
        if len(set(names)) != len(names):
            raise ValueError("process names are not distinct")
        self.names = names
        idx = {n: i for i, n in enumerate(names)}
        self.idx = idx

        def mask(lst):
            m = 0
            for n in lst:
                m |= 1 << idx[n]
            return m

        self.MON = mask(monitors)
        self.WORKS = mask(works)
        self.JBIT = (1 << idx[joiner]) if joiner is not None else 0
        self.SW = mask(sysd.get("switches", []))
        if self.SW & ~self.MON:
            raise ValueError("switch on a non-monitor")
        self.coupling = sysd["coupling"]
        if not isinstance(self.coupling, bool):
            raise ValueError("coupling must be a boolean")
        self.window = sysd["window"]
        if self.window not in (0, 1):
            raise ValueError("window must be 0 or 1")
        # addendum: optional fields
        self.gate = sysd.get("gate", True)
        self.slow = sysd.get("slow_reports", False)
        if not isinstance(self.gate, bool) or not isinstance(self.slow, bool):
            raise ValueError("gate and slow_reports must be booleans")

        n = len(names)

        def per_process(field, key_ok):
            arr = [0] * n
            for k, lst in sysd.get(field, {}).items():
                if k not in idx or not (1 << idx[k]) & key_ok:
                    raise ValueError("%s: bad key %r" % (field, k))
                m = mask(lst)
                if m & ~self.MON:
                    raise ValueError("%s[%s] lists a non-monitor" % (field, k))
                arr[idx[k]] = m
            return arr

        every = self.MON | self.WORKS | self.JBIT
        self.hb = per_process("hb_readers", self.MON)    # hb[p]  = monitors reading p
        self.chk = per_process("checkers", every)        # chk[x] = monitors checking x
        self.fwd = per_process("fwd", self.MON)          # fwd[m] = monitors m reports to
        self.hi = per_process("halt_inputs", self.WORKS | self.JBIT)

        # boundaries held by at least two monitors
        groups = {}
        for m, b in sysd.get("boundary", {}).items():
            if not (1 << idx[m]) & self.MON:
                raise ValueError("boundary on a non-monitor")
            groups.setdefault(json.dumps(b), 0)
            groups[json.dumps(b)] |= 1 << idx[m]
        self.boundary_masks = [g for g in groups.values() if bin(g).count("1") >= 2]

        groups = {}
        for p, s in sysd.get("substrate", {}).items():
            if s is None:
                continue  # "a process may have none"
            groups.setdefault(json.dumps(s), 0)
            groups[json.dumps(s)] |= 1 << idx[p]
        self.substrate_masks = list(groups.values())

        # state = (alive, bad, hidden, off, flagged, halted, pending, joined)
        self.init = (self.MON | self.WORKS, 0, 0, 0, 0, 0, 0, False)

    # ---- 3.1 environment phase -------------------------------------------------------
    def env_steps(self, e):
        """All states reached by one enabled environment step from e.
        e = (alive, bad, hidden, off, joined)."""
        alive, bad, hidden, off, joined = e
        MON = self.MON
        present = MON | self.WORKS | (self.JBIT if joined else 0)
        o = self.opts
        res = []
        # stop m
        for i in bits(alive & MON):
            res.append((alive & ~(1 << i), bad, hidden, off, joined))
        # stop-boundary b
        for g in self.boundary_masks:
            live = alive & g
            if live and (not o["boundary_two_alive"] or live & (live - 1)):
                res.append((alive & ~g, bad, hidden, off, joined))
        # fail-substrate s
        for g in self.substrate_masks:
            pg = g & present
            mon_part = pg & MON
            non_part = pg & ~MON
            blocker = hidden if o["substrate_enable_not_hidden"] else bad
            if (mon_part & alive) or (non_part & ~blocker):
                add = non_part if o["hide_already_bad"] else (non_part & ~bad)
                res.append((alive & ~mon_part, bad | add, hidden | add, off, joined))
        # mutate p
        for i in bits(present & ~bad):
            res.append((alive, bad | (1 << i), hidden, off, joined))
        # disable m
        for i in bits(self.SW & ~off):
            res.append((alive, bad, hidden, off | (1 << i), joined))
        # join
        if self.JBIT and not joined:
            res.append((alive | self.JBIT, bad, hidden, off, True))
        return res

    def env_reach(self, e):
        """States reached by a sequence of k enabled steps, 0 <= k <= f."""
        seen = {e}
        level = [e]
        for _ in range(self.f):
            nxt = []
            for x in level:
                for y in self.env_steps(x):
                    if y not in seen:
                        seen.add(y)
                        nxt.append(y)
            if not nxt:
                break
            level = nxt
        return seen

    # ---- 3.2 monitor phase, 3.3 work phase, 3.4 goals ---------------------------------
    def out_of(self, e, flagged):
        """Monitors in `flagged`, in `alive` and not in `bad`."""
        alive, bad, hidden, off, joined = e
        out = flagged & alive & ~bad
        if self.opts["out_excludes_off"]:
            out &= ~off
        return out

    def monitor_phase(self, e, flagged):
        """3.2. Returns (flagged, out). `flagged` on entry is also `flagged` at the start
        of the round: neither the environment phase nor the work phase changes it."""
        alive, bad, hidden, off, joined = e
        MON = self.MON
        at_start = flagged
        active = alive & MON & ~bad & ~off
        visible = bad & ~hidden
        det = 0
        for x in bits(visible):
            det |= self.chk[x]
        for p in bits(MON & ~alive):
            det |= self.hb[p]
        flagged |= det & active
        if self.slow:
            # addendum: one pass, from the monitors flagged at the start of the round
            src = flagged if self.opts["slow_from_post_detection"] else at_start
            add = 0
            for m in bits(src & active):
                add |= self.fwd[m] & active
            flagged |= add
        else:
            while True:
                new = flagged
                for m in bits(flagged & active):
                    new |= self.fwd[m] & active
                if new == flagged:
                    break
                flagged = new
        return flagged, self.out_of(e, flagged)

    def work_phase(self, e, out, halted, pending, silence_alive):
        """3.3. Returns (halted, pending, worked)."""
        alive, bad, hidden, off, joined = e
        stopped = self.MON & ~silence_alive
        worked = False
        present_non = self.WORKS | (self.JBIT if joined else 0)
        for w in bits(present_non & ~halted):
            b = 1 << w
            if pending & b:
                pending &= ~b
                halted |= b
            else:
                sees = bool(self.hi[w] & out) or (self.coupling and bool(self.hi[w] & stopped))
                if sees and self.window == 0:
                    halted |= b
                else:
                    if sees:
                        pending |= b
                    worked = True
        return halted, pending, worked

    def tail(self, e, flagged, halted, pending, alive0=None):
        """The two phases after the environment phase, and the goals (3.4).
        `alive0` (alive at the start of the round) is only used by the
        gate_silence_delayed alternative reading."""
        alive, bad, hidden, off, joined = e
        if self.gate:
            flagged, out = self.monitor_phase(e, flagged)
            halted, pending, worked = self.work_phase(e, out, halted, pending, alive)
        else:
            # addendum: environment, work, monitor. The work phase sees only the flags
            # of earlier rounds, read in the state after the environment phase.
            out_w = self.out_of(e, flagged)
            silence_alive = alive if alive0 is None else alive0
            halted, pending, worked = self.work_phase(e, out_w, halted, pending, silence_alive)
            flagged, out = self.monitor_phase(e, flagged)
        g1 = bad != 0 and out == 0
        g2 = bad != 0 and worked
        return (alive, bad, hidden, off, flagged, halted, pending, joined), g1, g2

    # ---- 3.5 ---------------------------------------------------------------------------
    def responded(self, st):
        alive, bad, hidden, off, flagged, halted, pending, joined = st
        resp = flagged & alive & ~bad
        if self.opts["responded_excludes_off"]:
            resp &= ~off
        present_non = self.WORKS | (self.JBIT if joined else 0)
        return resp != 0 and (present_non & ~halted) == 0


def explore(sysd, opts=None):
    """Exhaustive breadth-first search over rounds. Returns (G1, G2, stats)."""
    M = Model(sysd, opts)
    seen = {M.init}
    frontier = [M.init]
    G1 = G2 = None
    n = 0
    tail_memo = {}
    n_resp = 0
    delayed = M.opts["gate_silence_delayed"] and not M.gate
    while frontier:
        n += 1
        nxt = []
        for st in frontier:
            if M.responded(st):
                n_resp += 1
                continue  # no round starts from a responded state
            alive, bad, hidden, off, flagged, halted, pending, joined = st
            alive0 = alive if delayed else None
            for e in M.env_reach((alive, bad, hidden, off, joined)):
                key = (e, flagged, halted, pending, alive0)
                r = tail_memo.get(key)
                if r is None:
                    r = M.tail(e, flagged, halted, pending, alive0)
                    tail_memo[key] = r
                st2, g1, g2 = r
                if g1 and G1 is None:
                    G1 = n
                if g2 and G2 is None:
                    G2 = n
                if st2 not in seen:
                    seen.add(st2)
                    nxt.append(st2)
        frontier = nxt
    return G1, G2, {"states": len(seen), "responded": n_resp, "levels": n,
                    "post_env": len(tail_memo)}


# =========================================================================================
# Second implementation: a direct transcription with sets (literal reading only).
# =========================================================================================
def explore_sets(sysd):
    f = sysd["f"]
    monitors = list(sysd["monitors"])
    works = list(sysd["works"])
    joiner = sysd.get("joiner")
    monset = frozenset(monitors)
    boundary = sysd.get("boundary", {})
    substrate = sysd.get("substrate", {})
    hb_readers = sysd.get("hb_readers", {})
    checkers = sysd.get("checkers", {})
    fwd = sysd.get("fwd", {})
    halt_inputs = sysd.get("halt_inputs", {})
    switches = sysd.get("switches", [])
    coupling = sysd["coupling"]
    window = sysd["window"]
    boundary_ids = sorted({json.dumps(b) for b in boundary.values()})
    substrate_ids = sorted({json.dumps(s) for s in substrate.values() if s is not None})
    fs = frozenset

    def present(joined):
        return monitors + works + ([joiner] if joined else [])

    def nonmon_present(joined):
        return works + ([joiner] if joined else [])

    def steps(e):
        alive, bad, hidden, off, joined = e
        out = []
        for m in monitors:                                   # stop m
            if m in alive:
                out.append((alive - {m}, bad, hidden, off, joined))
        for b in boundary_ids:                               # stop-boundary b
            members = [m for m in monitors if m in boundary and json.dumps(boundary[m]) == b]
            if len(members) >= 2 and any(m in alive for m in members):
                out.append((alive - fs(members), bad, hidden, off, joined))
        for s in substrate_ids:                              # fail-substrate s
            on = [p for p in present(joined)
                  if substrate.get(p) is not None and json.dumps(substrate[p]) == s]
            if any((p in monset and p in alive) or (p not in monset and p not in bad)
                   for p in on):
                a2, b2, h2 = set(alive), set(bad), set(hidden)
                for p in on:
                    if p in monset:
                        a2.discard(p)
                    else:
                        b2.add(p)
                        h2.add(p)
                out.append((fs(a2), fs(b2), fs(h2), off, joined))
        for p in present(joined):                            # mutate p
            if p not in bad:
                out.append((alive, bad | {p}, hidden, off, joined))
        for m in switches:                                   # disable m
            if m not in off:
                out.append((alive, bad, hidden, off | {m}, joined))
        if joiner is not None and not joined:                # join
            out.append((alive | {joiner}, bad, hidden, off, True))
        return out

    gate = sysd["gate"] if "gate" in sysd else True
    slow_reports = sysd["slow_reports"] if "slow_reports" in sysd else False

    def one_round_tail(e, flagged_in, halted, pending):
        alive, bad, hidden, off, joined = e
        halted = set(halted)
        pending = set(pending)
        box = {"worked": False}

        def good_flags(fl):
            return {m for m in monitors if m in fl and m in alive and m not in bad}

        def work(out):
            for w in nonmon_present(joined):
                if w in halted:
                    continue
                if w in pending:
                    pending.discard(w)
                    halted.add(w)
                else:
                    his = halt_inputs.get(w, [])
                    sees = any(m in out for m in his) or \
                        (coupling and any(m not in alive for m in his))
                    if sees and window == 0:
                        halted.add(w)
                    else:
                        if sees:
                            pending.add(w)
                        box["worked"] = True

        def monitor():
            active = {m for m in monitors if m in alive and m not in bad and m not in off}
            visible = bad - hidden
            flagged = set(flagged_in)
            for m in active:
                if any(m in checkers.get(x, []) for x in visible) or \
                   any(p not in alive and m in hb_readers.get(p, []) for p in monitors):
                    flagged.add(m)
            if slow_reports:
                # one pass, sources = flagged at the start of the round
                for m in flagged_in:
                    if m in active:
                        for r in fwd.get(m, []):
                            if r in active:
                                flagged.add(r)
            else:
                changed = True
                while changed:
                    changed = False
                    for m in list(flagged):
                        if m in active:
                            for r in fwd.get(m, []):
                                if r in active and r not in flagged:
                                    flagged.add(r)
                                    changed = True
            return flagged

        if gate:
            flagged = monitor()
            out = good_flags(flagged)
            work(out)
        else:
            work(good_flags(flagged_in))     # flags of earlier rounds only
            flagged = monitor()
            out = good_flags(flagged)
        g1 = len(bad) > 0 and len(out) == 0
        g2 = len(bad) > 0 and box["worked"]
        return (alive, bad, hidden, off, fs(flagged), fs(halted), fs(pending), joined), g1, g2

    def responded(st):
        alive, bad, hidden, off, flagged, halted, pending, joined = st
        good = [m for m in monitors if m in flagged and m in alive and m not in bad]
        return len(good) > 0 and all(w in halted for w in nonmon_present(joined))

    init = (fs(monitors + works), fs(), fs(), fs(), fs(), fs(), fs(), False)
    seen = {init}
    frontier = [init]
    G1 = G2 = None
    n = 0
    while frontier:
        n += 1
        nxt = []
        for st in frontier:
            if responded(st):
                continue
            alive, bad, hidden, off, flagged, halted, pending, joined = st
            e0 = (alive, bad, hidden, off, joined)
            reach = {e0}
            level = [e0]
            for _ in range(f):
                nl = []
                for x in level:
                    for y in steps(x):
                        if y not in reach:
                            reach.add(y)
                            nl.append(y)
                level = nl
            for e in reach:
                st2, g1, g2 = one_round_tail(e, flagged, halted, pending)
                if g1 and G1 is None:
                    G1 = n
                if g2 and G2 is None:
                    G2 = n
                if st2 not in seen:
                    seen.add(st2)
                    nxt.append(st2)
        frontier = nxt
    return G1, G2, {"states": len(seen)}


# =========================================================================================
VARIANTS = [
    ("hide_already_bad=False", {"hide_already_bad": False}),
    ("substrate_enable_not_hidden=True", {"substrate_enable_not_hidden": True}),
    ("boundary_two_alive=True", {"boundary_two_alive": True}),
    ("out_excludes_off=True", {"out_excludes_off": True}),
    ("out_excludes_off+responded_excludes_off",
     {"out_excludes_off": True, "responded_excludes_off": True}),
    ("responded_excludes_off=True", {"responded_excludes_off": True}),
    ("gate_silence_delayed=True", {"gate_silence_delayed": True}),
    ("slow_from_post_detection=True", {"slow_from_post_detection": True}),
]


def load(name):
    with open(os.path.join(HERE, name), encoding="utf-8") as fh:
        return json.load(fh)


def serialise(results):
    return json.dumps(results, indent=1) + "\n"


def main(argv):
    only = None
    if "--only" in argv:                      # --only extra | --only base (for --variants)
        only = argv[argv.index("--only") + 1]

    if "--variants" in argv:
        cases = []
        if only in (None, "base"):
            cases += load("systems.json")
        if only in (None, "extra"):
            cases += load("systems-extra.json")
        base = {}
        for c in cases:
            g1, g2, _ = explore(c["system"])
            base[c["id"]] = (g1, g2)
        for label, o in VARIANTS:
            diffs = []
            for c in cases:
                g1, g2, _ = explore(c["system"], o)
                if (g1, g2) != base[c["id"]]:
                    diffs.append((c["id"], base[c["id"]], (g1, g2)))
            print("variant %-45s cases: %d  changed: %d" % (label, len(cases), len(diffs)))
            for d in diffs:
                print("    %s: literal %s -> variant %s" % d)
        return 0

    extra = "--extra" in argv
    verify = "--verify" in argv
    in_name = "systems-extra.json" if extra else "systems.json"
    out_name = "results-a-extra.json" if extra else "results-a.json"
    max_states = None
    if "--max-states" in argv:
        max_states = int(argv[argv.index("--max-states") + 1])

    cases = load(in_name)
    results = []
    n_checked = n_skipped = n_bad = 0
    t_all = time.time()
    for c in cases:
        t0 = time.time()
        g1, g2, stats = explore(c["system"])
        dt = time.time() - t0
        results.append({"id": c["id"], "G1": g1, "G2": g2})
        line = "%-62s G1=%-5s G2=%-5s states=%-7d levels=%-3d %.2fs" % (
            c["id"], g1, g2, stats["states"], stats["levels"], dt)
        if "--crosscheck" in argv:
            if max_states is not None and stats["states"] > max_states:
                n_skipped += 1
                line += "  sets:skipped"
            else:
                h1, h2, hs = explore_sets(c["system"])
                ok = (h1, h2, hs["states"]) == (g1, g2, stats["states"])
                n_checked += 1
                n_bad += 0 if ok else 1
                line += "  sets:%s" % ("ok" if ok else
                                       "MISMATCH %s %s %d" % (h1, h2, hs["states"]))
        print(line, flush=True)
    text = serialise(results)
    if verify:
        with open(os.path.join(HERE, out_name), encoding="utf-8", newline="") as fh:
            old_text = fh.read()
        # what a text-mode write of `text` would put on disk on this platform
        same_bytes = old_text == text.replace("\n", os.linesep)
        same_data = json.loads(old_text) == results
        print("verify against %s: same parsed content: %s; byte-identical: %s" % (
            out_name, same_data, same_bytes))
        if not same_data:
            old = json.loads(old_text)
            for a, b in zip(old, results):
                if a != b:
                    print("    DIFF old %s  new %s" % (a, b))
    else:
        with open(os.path.join(HERE, out_name), "w", encoding="utf-8") as fh:
            fh.write(text)
        print("wrote %s" % out_name)
    if "--crosscheck" in argv:
        print("crosscheck: %d compared, %d mismatched, %d skipped (over --max-states)" % (
            n_checked, n_bad, n_skipped))
    print("cases: %d  G1 null: %d  G2 null: %d  total %.1fs" % (
        len(results), sum(r["G1"] is None for r in results),
        sum(r["G2"] is None for r in results), time.time() - t_all))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
