# Evolution: cb-root-layout

**Date**: 2026-05-19
**Feature**: cb-root-layout
**Version target**: v1.9.0
**ADR**: [ADR-012](../product/architecture/adr-012-root-layout-cowork-placement.md)

---

## Feature Summary

Adds root-layout support to all six engagement skills. Agile coaches using a dedicated CoWork project directory (one directory = one engagement) can now scaffold engagement files directly at the project root via `cb-init --root`, eliminating the redundant `engagements/<slug>/` wrapper.

All five downstream skills (`cb-log`, `cb-retro`, `cb-snapshot`, `cb-validate`, `coach-buddy`) gain the Engagement Path Resolver — a shared detection pattern that checks for a schema-matched `config.json` at the working directory root before falling back to the legacy `engagements/<slug>/` path. Legacy layout is unchanged; both layouts coexist transparently.

**Scope**: SKILL.md prose changes only — six files, no new files created, no compiled code, no domain model changes.

---

## Business Context

The reference case is `~/teams/advisor-connect` — a dedicated CoWork project where the project directory IS the engagement. Before this feature, coaches were forced to navigate into `engagements/advisor-connect/` for every file access, and manual workarounds broke all downstream skill path references.

The friction was confirmed by manual migration of the advisor-connect project to root layout, which validated the desired ergonomic: engagement files at the project root alongside `CLAUDE.md` and `.claude/`, with no extra wrapper directory.

Primary job: `cowork-native-setup` (added to `docs/product/jobs.yaml` during DISCUSS wave — WD-002). Secondary job: `engagement-scaffolding` (J9).

---

## Key Decisions

### 1. `--root` as an explicit flag (ADR-012 D1)

Auto-detection (via `.claude/skills/` presence or a CoWork platform marker file) was considered and rejected. Auto-detection cannot distinguish a dedicated coaching project from a team project with coach-buddy installed — the canonical portable install pattern (ADR-008). An explicit `--root` flag makes intent declarative at init time and is the natural seam for the future `--root <path>` extension.

### 2. Schema-match as the detection anchor (ADR-012 D2)

`./config.json` existence alone is not the signal — the file must also contain both a `version` field and an `engagement.slug` field. Other tools (TypeScript compiler, ESLint, npm, CoWork platform) write `config.json` to the project root; none include `engagement.slug`. Schema-match guards against false positives without introducing a new marker file.

### 3. Engagement Path Resolver as a shared verbatim pattern (Design DD-002)

The detection logic is identical across all five downstream skills. Rather than five independent copies, a single named pattern — "Engagement Path Resolver" — is embedded verbatim in each SKILL.md under `## Reading the engagement config`. Extraction to a shared reference file was rejected: SKILL.md self-containment is a design invariant from ADR-008 (skills must not depend on external reference files being present at runtime).

Future maintenance note: when `--root <path>` ships (ADR-012 D4), all five embedded copies will need updating — a known multi-site edit, acceptable at this scale.

### 4. `coach-buddy` context loading is optional and silent (Design DD-003)

`coach-buddy`'s Engagement Path Resolver is applied silently. If no engagement is found, `coach-buddy` proceeds without context and does not surface an error. Engagement context (CONTEXT.md, COACHING_LOG.md, snapshots) enriches thinking-partner conversations but is not required. This is distinct from engagement-management skills (`cb-log`, `cb-validate` etc.), which must error when no engagement is found because their core function cannot proceed without it.

### 5. COACHING_LOG.md collision warning (Design DD-004)

The overwrite guard is anchored on `config.json` (locked in ADR-012 D5). An additive warning was added: if `./config.json` is absent (overwrite guard does not fire) but `./COACHING_LOG.md` already exists when `--root` is active, `cb-init` warns before proceeding. This preserves coach agency while surfacing data-loss risk for teams that may have a pre-existing `COACHING_LOG.md`.

---

## Files Changed

### SKILL.md files

| File | Change |
|------|--------|
| `plugins/coach-buddy/skills/cb-init/SKILL.md` | `--root` flag; conditional overwrite guard path; `{target}` path variable throughout; COACHING_LOG.md collision warning; `argument-hint` updated |
| `plugins/coach-buddy/skills/cb-log/SKILL.md` | Engagement Path Resolver replaces hardcoded `engagements/<slug>/config.json` read |
| `plugins/coach-buddy/skills/cb-retro/SKILL.md` | Engagement Path Resolver replaces hardcoded `engagements/<slug>/config.json` read |
| `plugins/coach-buddy/skills/cb-snapshot/SKILL.md` | Engagement Path Resolver; snapshot and coaching-context paths updated to `{engagement_path}` variable |
| `plugins/coach-buddy/skills/cb-validate/SKILL.md` | Engagement Path Resolver; COACHING_LOG.md read path updated to `{engagement_path}` variable |
| `plugins/coach-buddy/skills/coach-buddy/SKILL.md` | New `## Engagement context (optional)` section (after `## Core stance`, before `## Mode management`); silent resolver; no error if no engagement found |

### Architecture and tests

| File | Change |
|------|--------|
| `docs/product/architecture/adr-012-root-layout-cowork-placement.md` | New — written directly to SSOT during DISCUSS wave |
| `docs/product/architecture/brief.md` | ADR index updated; cb-root-layout architecture section added |
| `tests/acceptance/cb-root-layout/walking-skeleton.feature` | 21 Gherkin scenarios across US-CBR-01, US-CBR-02, US-CBR-03 |
| `tests/acceptance/cb-root-layout/test-script.md` | 18 manual test runs with verification commands and pass/fail table |

### Wave artifacts (preserved)

| File | Purpose |
|------|---------|
| `docs/feature/cb-root-layout/feature-delta.md` | Full wave record: DISCUSS, DESIGN, DISTILL sections |
| `docs/feature/cb-root-layout/discuss/wave-decisions.md` | WD-001 through WD-006 |
| `docs/feature/cb-root-layout/discuss/story-map.md` | US-CBR-01, US-CBR-02, US-CBR-03 story map |
| `docs/feature/cb-root-layout/design/wave-decisions.md` | DD-001 through DD-006; peer review record |
| `docs/feature/cb-root-layout/distill/wave-decisions.md` | TD-001 through TD-008; test strategy; peer review record |
| `docs/feature/cb-root-layout/slices/slice-01-root-init.md` | Slice 01 definition (US-CBR-01) |
| `docs/feature/cb-root-layout/slices/slice-02-downstream-detection.md` | Slice 02 definition (US-CBR-02, US-CBR-03) |

---

## File Migration

No file migration required — ADR written directly to SSOT, acceptance tests written directly to `tests/acceptance/`.

---

## Watch Items / Open Threads

1. **`--root <path>` extension deferred** (ADR-012 D4): `cb-init --root <path>` (arbitrary target directory without `cd`) is explicitly out of scope. Coaches needing this today use the `cd <path> && cb-init --root` workaround. When this extension ships, all five Engagement Path Resolver embeddings will need updating.

2. **`ongoing-engagement.yaml` still needs updating** (DISCUSS WD-001): `docs/product/journeys/ongoing-engagement.yaml` step `engagement-start` still shows `engagements/<slug>/` paths in `artifacts_produced`. Post-DELIVER task: add layout-conditional notes to the journey YAML reflecting both root and legacy paths.

3. **Schema detection is prose-level, not typed**: The `version` + `engagement.slug` schema match is described as prose instructions in SKILL.md. If a future feature introduces typed parsing of `config.json` (e.g. a TypeScript parser), these field names become a typed contract surface. Flag this when that feature is scoped (Design DD-001).

4. **Partial rollout risk now resolved**: The feature shipped atomically — both Slice 01 (cb-init) and Slice 02 (downstream skills) delivered in the same commit. The partial-rollout risk documented in the feature-delta is closed.

---

## Test Results

56/56 tests pass. Acceptance test suite: 21 Gherkin scenarios + 18 manual test script runs. Error path ratio: 43% (target ≥40% — PASS). Stories covered: US-CBR-01 (7 scenarios), US-CBR-02 (10 scenarios), US-CBR-03 (1 dedicated + embedded in all root-layout scenarios).

---

## Permanent Artifacts

| Artifact | Location |
|----------|----------|
| ADR-012 | `docs/product/architecture/adr-012-root-layout-cowork-placement.md` |
| Architecture brief (cb-root-layout section) | `docs/product/architecture/brief.md` |
| Acceptance tests | `tests/acceptance/cb-root-layout/` |
| Wave history | `docs/feature/cb-root-layout/` |
