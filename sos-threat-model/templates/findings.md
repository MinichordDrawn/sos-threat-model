# «System» observer audit: findings

Working template for passes 1 and 2: pass 1 fills Steps 0 to 1.5 (the ring map), pass 2
the properties scorecard. Fill every «placeholder». Delete rows and blocks that do not
apply. Follow `../reference/writing.md`.

Cell codes: **G** gap, confirmed in code. **S** satisfied. **N/A** the tier does not
require this stack (name the tier). Every observer satisfies every property; only the tier
lowers the bar.

---

## System in brief

- **Purpose.** «what it does, two lines»
- **Customers, in two senses.** «who runs it; who it acts on or for»
- **Its own goal, in its own words.** «quote», `«path:line»`

## Step 0. Consequence tiers

Customer data first: «what customer data exists, where it lives, citations».

| Subsystem | Carries customer data? | Tier | Why |
|---|:---:|---|---|
| «name» | «yes/no» | «tier» | «one line» |

## Step 1. Ring topology

### Observer inventory

| # | Observer | file:line | What it checks | Reports to | On fault |
|---|---|---|---|---|---|
| O1 | «name» | `«path:line»` | «check» | «observer, log, UI, nothing» | «halt, error, continue» |

### Ring requirements

| Requirement | Present? | Evidence (file:line) |
|---|:---:|---|
| A cycle of at least three mutual observers | «yes/no» | «...» |
| Each observer checks one, reports to a different one | «yes/no» | «...» |
| One +1 that checks all observers including itself | «yes/no» | «...» |
| Nested rings, where the structure needs them | «yes/no/N/A» | «...» |

**Shape:** «no ring / star / passive hubs / isolated spokes / ring». «One or two
sentences.»

### Coordinators and super-rings

| Candidate | Can stop what | Checks every observer | Takes reports back | Surface check | In the ring | Result |
|---|---|:---:|:---:|:---:|:---:|---|
| «name», `«path:line»` | «...» | «yes/no» | «yes/no» | «yes/no» | «yes/no» | «passes / fails» |

## Step 1.5. Missing structural components

Per subsystem: cycle, coordinator, check and report separation, halt path with
propagation, upward chain, each present or absent, descriptive only.

### Present halt paths

- **H1** «trigger» → «what stops» (`«path:line»`). Propagates to «how far».

### Continue-on-fault paths

- **C1** «fault» → «what continues» (`«path:line»`).

### Execution-observation coupling

«Does execution check an observer's heartbeat and stop when it stops? Citations.»

## Step 2. Properties

| Subsystem | 1 HB | 2 Sub | 3 CSV | 4 SWR | 5 SD | 6 Death | 7 AutoInt | 8 Reflex |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| «subsystem» | «G/S/N/A» | | | | | | | |

**Totals:** «n G, n S, n N/A over n cells».

Evidence per verdict: one bullet per property, citing the lines that settle it.

## Unconfirmed

1. «claim», «where to look», «what would settle it».
