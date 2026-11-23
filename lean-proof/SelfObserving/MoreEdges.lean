/-
"The second system has more edges": the relation between two systems in Lemma M of
`results-join.md`, section 3, for the model of `Model.lean` and for the model with joins
of `Join.lean`. Everything in this file is a definition.
-/
import SelfObserving.Join

namespace SelfObserving

variable {M W B S G : Type}

/-- `MoreEdges sys₁ sys₂`: two systems of `model-spec.md` that differ only in that the
second has more edges. Every signal read, state check, report and halt input of the first
is one of the second (`hb`, `check`, `fwd`, `halt`), and every other field is the same in
both. -/
structure MoreEdges (sys₁ sys₂ : System M W B S) : Prop where
  f : sys₁.f = sys₂.f
  joiner : sys₁.joiner = sys₂.joiner
  boundary : ∀ m, sys₁.boundary m = sys₂.boundary m
  substrate : ∀ p, sys₁.substrate p = sys₂.substrate p
  switches : ∀ m, sys₁.switches m ↔ sys₂.switches m
  coupling : sys₁.coupling = sys₂.coupling
  window : sys₁.window = sys₂.window
  gate : sys₁.gate = sys₂.gate
  slowReports : sys₁.slowReports = sys₂.slowReports
  hb : ∀ p m, sys₁.hbReaders p m → sys₂.hbReaders p m
  check : ∀ x m, sys₁.checkers x m → sys₂.checkers x m
  fwd : ∀ m r, sys₁.fwd m r → sys₂.fwd m r
  halt : ∀ w m, sys₁.haltInputs w m → sys₂.haltInputs w m

/-- `JMoreEdges sys₁ sys₂`: two systems with joins that differ only in that the second
has more edges, or has an edge prompt that is slow in the first.

- `base`: the fields of `model-spec.md` are related as in `MoreEdges`.
- The groups, the joiner's group, the `after` conditions and `arriveBad` are the same.
- `slow_hb`, `slow_check`, `slow_fwd`, `slow_halt`: an edge of the first system that is a
  slow edge in the second is a slow edge in the first. So an edge of both may be slow in
  the first and prompt in the second, and not the other way round; an edge that only the
  second has may be slow or prompt. -/
structure JMoreEdges (sys₁ sys₂ : JSystem M W B S G) : Prop where
  base : MoreEdges sys₁.base sys₂.base
  group : ∀ m, sys₁.group m = sys₂.group m
  joinerGroup : sys₁.joinerGroup = sys₂.joinerGroup
  after : ∀ g p, sys₁.after g p ↔ sys₂.after g p
  arriveBad : sys₁.arriveBad = sys₂.arriveBad
  slow_hb : ∀ p m, sys₁.base.hbReaders p m → sys₂.slowHb p m → sys₁.slowHb p m
  slow_check : ∀ x m, sys₁.base.checkers x m → sys₂.slowCheck x m → sys₁.slowCheck x m
  slow_fwd : ∀ m r, sys₁.base.fwd m r → sys₂.slowFwd m r → sys₁.slowFwd m r
  slow_halt : ∀ w m, sys₁.base.haltInputs w m → sys₂.slowHalt w m → sys₁.slowHalt w m

end SelfObserving
