# «System» observer audit: findings

Working template for passes 1 and 2: pass 1 fills Steps 0 to 1.5 (the ring map), pass 2
the properties scorecard. Fill every «placeholder». Delete rows and blocks that do not
apply. Follow `../reference/writing.md`.

Cell codes: **G** gap, confirmed at the cited line. **S** satisfied. **N/A** the tier does not
require this stack (name the tier). Every observer satisfies every property; only the tier
lowers the bar.

Ids, the same in every pass so none collides with another: **O** observers, **OC**
observed components, **BC** B2 controls, **SP** signal-path devices, **H** halt paths,
**C** continue-on-fault paths, **RP** removal paths (B2 paths that remove an observer),
**PR** prescribed responses, **U** unconfirmed items, **DG** disagreements between sources,
**SC** corrections of the survey, **GR** scorecard groups; the STRIDE letters **S T R I D E**
for rows, **M** for the chain hunt's rows, **X** for chains. A pass that needs another kind
picks a prefix that is none of these. A row refiled under another letter keeps its id;
count rows by the section they sit in, and say so in the counts.

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

| # | Entry | Role | file:line | What it checks | Reports to | On fault |
|---|---|---|---|---|---|---|
| «O1 / OC1 / BC1 / SP1» | «name» | «observer / observed component / B2 control / signal-path device» | `«path:line»` | «check» | «observer, log, UI, nothing» | «halt, error, continue» |

Only entries with the role observer go on the scorecard (`../reference/method.md`, Step 1).

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

### Hazards and their observers

One row per observed component (role "observed component" in the inventory).

| Component | Hazardous state, in the source's words | Evidence | Observer that checks it against known-good |
|---|---|---|---|
| «OC1 name» | «state» | `«path:line»` | «O-id, or none: a missing observer» |

### Present halt paths

- **H1** «trigger» → «what stops» (`«path:line»`). Propagates to «how far».

### Continue-on-fault paths

- **C1** «fault» → «what continues» (`«path:line»`).

### Removal paths and prescribed responses

- **RP1** «the B2 control or setting» removes «observer id» (`«path:line»`).
- **PR1** «the prescribed response», in «the state where it is prescribed»: «whether it can
  be the fault there, and why» (`«path:line»`).

### Disagreements between sources

- **DG1** «what each says», `«path:line»` against `«path:line»`; left as the source has it.

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
