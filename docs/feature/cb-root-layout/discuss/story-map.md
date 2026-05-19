# Story Map: cb-root-layout

## User: Agile Coach (Dan — coaching advisor-connect, using a dedicated CoWork project directory)
## Goal: Start and maintain a coaching engagement in a dedicated project directory without a redundant subdirectory wrapper

---

## Backbone

| Init engagement at root | Downstream skills read root layout | Engagement flows without disambiguation |
|------------------------|-----------------------------------|----------------------------------------|
| Run `cb-init --root`   | cb-log resolves root path          | No slug prompt in root layout          |
| Files land at cwd      | cb-retro resolves root path        |                                        |
| Overwrite guard fires on root `config.json` | cb-snapshot resolves root path |                          |
|                        | cb-validate resolves root path     |                                        |
|                        | coach-buddy resolves root path     |                                        |

---

### Walking Skeleton

Thinnest end-to-end slice that proves the layout works:

1. **Init at root**: `cb-init --root` scaffolds all files at cwd (not `engagements/<slug>/`)
2. **Read from root**: `cb-log` detects `config.json` at root and writes to `COACHING_LOG.md` at root (not `engagements/<slug>/COACHING_LOG.md`)

These two tasks are the minimum proof that init and at least one downstream skill operate correctly in root layout. They span the full chain: write → detect → read.

---

### Slice 01: Root Scaffolding (Walking Skeleton — init half)

**Target outcome**: Coach can scaffold an engagement at project root with `cb-init --root`

Stories:
- US-CBR-01: `cb-init --root` scaffolds engagement files at the current working directory

Outcome KPI: Coach completes root-layout init without manual post-init file migration.

Priority rationale: Foundation. Nothing else works until `config.json` is at root. Lowest risk slice — cb-init is the writer; no reads to coordinate.

---

### Slice 02: Downstream Path Resolution

**Target outcome**: All downstream skills work transparently with root layout

Stories:
- US-CBR-02: All downstream skills detect root layout and resolve engagement paths from root
- US-CBR-03: Slug disambiguation is bypassed in root layout (infrastructure — no prompt, slug read from root `config.json`)

Outcome KPI: Full engagement cycle (init → log → retro → snapshot → coach-buddy) completes without path errors in root layout.

Priority rationale: Completes the walking skeleton. Must ship as an atomic unit — partial downstream rollout produces a broken cycle (see WD-006). Deferred from Slice 01 to allow independent validation of the init path.

---

## Priority Rationale

| Priority | Slice | Target Outcome | Rationale |
|----------|-------|----------------|-----------|
| 1 | Slice 01 | Coach can init at root | Foundation; no downstream work possible without `config.json` at root |
| 2 | Slice 02 | Full cycle works in root layout | Completing the skeleton; atomic delivery required; no value without this |

Both slices are Must Have for the feature to deliver value. No optional enhancements in scope.

`--root <path>` extension is explicitly out of scope (ADR-012 D4 / WD-004).
