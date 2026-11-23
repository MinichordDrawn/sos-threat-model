/-
The count of `results.md`, section 8.2: a fault that doubles every tick against a halt
that travels. It is a separate small model, transcribed from the setting of that section
and from `growth` in `check_model.py`, which is the count as the model check runs it.
Everything in this file is a definition. Nothing is imported.
-/

namespace SelfObserving

/-- The state of the count. -/
structure Spreading where
  /-- running processes that are good -/
  good : Nat
  /-- running processes that are bad -/
  bad : Nat
  /-- bad processes the halt has reached -/
  haltedBad : Nat
  /-- how many processes the halt reached in its last hop; at the start, 1, for the place
  the halt starts from -/
  frontier : Nat

/-- The start: `n` running processes, one of them bad, and a halt that starts from one
place. The count is for `n` of 1 or more. -/
def Spreading.start (n : Nat) : Spreading where
  good := n - 1
  bad := 1
  haltedBad := 0
  frontier := 1

/-- One hop of a halt passed to `c` per hop. The halt reaches `c` processes for each one
it reached in the hop before, or every running process if that is fewer. It reaches good
processes first. -/
def Spreading.hop (c : Nat) (s : Spreading) : Spreading :=
  let newly := min (s.frontier * c) (s.good + s.bad)
  let g := min newly s.good
  { good := s.good - g
    bad := s.bad - (newly - g)
    haltedBad := s.haltedBad + (newly - g)
    frontier := newly }

/-- The fault spreads: each bad process still running makes one more running process bad,
while good ones are left. -/
def Spreading.spread (s : Spreading) : Spreading :=
  let k := min s.bad s.good
  { s with good := s.good - k, bad := s.bad + k }

/-- `iter f k a`: `f` applied `k` times to `a`. -/
def iter {α : Type} (f : α → α) : Nat → α → α
  | 0, a => a
  | k + 1, a => f (iter f k a)

/-- One tick of a halt passed to `c` per hop at `h` hops per tick: the hops, then the
fault spreads. -/
def Spreading.tick (c h : Nat) (s : Spreading) : Spreading :=
  (iter (Spreading.hop c) h s).spread

/-- The number of bad processes, running or halted. -/
def Spreading.damage (s : Spreading) : Nat := s.haltedBad + s.bad

/-- The state after `t` ticks of a halt passed to `c` per hop at `h` hops per tick, from
`n` processes. -/
def cascade (c h n t : Nat) : Spreading := iter (Spreading.tick c h) t (Spreading.start n)

/-- `CascadeDamage c h n d`: `d` is the damage, the number of bad processes when nothing
bad is still running, for a halt passed to `c` per hop at `h` hops per tick. The count
runs tick by tick and ends at the first tick after which no bad process is running. -/
def CascadeDamage (c h n d : Nat) : Prop :=
  ∃ T, (cascade c h n T).bad = 0 ∧ (∀ t, t < T → (cascade c h n t).bad ≠ 0) ∧
    d = (cascade c h n T).damage

/-- The damage when everything halts together `w` ticks after detection: the fault has
spread `w` times, and nothing has been halted before. -/
def windowDamage (n w : Nat) : Nat := (iter Spreading.spread w (Spreading.start n)).damage

/-- `1 + c + c^2 + ... + c^j`. -/
def geom (c : Nat) : Nat → Nat
  | 0 => 1
  | j + 1 => geom c j + c ^ (j + 1)

end SelfObserving
