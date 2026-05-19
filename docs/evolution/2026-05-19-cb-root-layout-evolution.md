# Evolution: cb-root-layout

**Date**: 2026-05-19
**Feature**: cb-root-layout
**ADR**: [ADR-012](../product/architecture/adr-012-root-layout-cowork-placement.md)
**DES integrity**: PASS

---

## Feature Summary

Adds root-layout support to all six engagement skills. Agile coaches using a dedicated CoWork project directory (one directory = one engagement) can now scaffold engagement files directly at the project root via `cb-init --root`, eliminating the redundant `engagements/<slug>/` wrapper.

All five downstream skills (`cb-log`, `cb-retro`, `cb-snapshot`, `cb-validate`, `coach-buddy`) gain the Engagement Path Resolver — a shared detection pattern that checks for a schema-matched `config.json` at the working directory root before falling back to the legacy `engagements/<slug>/` path. Legacy layout is unchanged; both layouts coexist transparently.

**Scope**: SKILL.md prose changes only — six files modified, no new files created, no compiled code, no domain model changes.

---

## Business Context

The reference case is `~/teams/advisor-connect` — a dedicated CoWork project where the project directory IS the engagement. Before this feature, coaches were forced to navigate into `engagements/advisor-connect/` for every file access, and manual workarounds broke all downstream skill path references.

The friction was confirmed by manual migration of the advisor-connect project to root layout, which validated the desired ergonomic: engagement files at the project root alongside `CLAUDE.md` and `.claude/`, with no extra wrapper directory.

Primary job: `cowork-native-setup` (added to `docs/product/jobs.yaml` during DISCUSS wave — WD-002). Secondary job: `engagement-scaffolding` (J9).

---

## Key Decisions

### ADR-012: Root layout CoWork placement via `--root` flag

Three core decisions locked in ADR-012:

- **D1 — Explicit flag, not auto-detection**: Auto-detection cannot distinguish a dedicated coaching project from a team project with coach-buddy installed (the portable install pattern from ADR-008). An explicit `--root` flag makes intent declarative at init time.
- **D2 — Schema-match as the detection anchor**: `./config.json` existence alone is not the signal — the file must contain both a `version` field and an `engagement.slug` field. Other tools (TypeScript compiler, ESLint, npm) write `config.json` to the project root; none include `engagement.slug`.
- **D4 — `--root <path>` explicitly out of scope**: `cb-init --root <path>` (arbitrary target without `cd`) is a future extension. Coaches use `cd <path> && cb-init --root` today.

### Engagement Path Resolver: verbatim embedding per ADR-008 self-containment invariant

The detection logic is identical across all five downstream skills. Rather than five independent copies, a single named pattern — "Engagement Path Resolver" — is embedded verbatim in each SKILL.md. Extraction to a shared reference file was rejected because ADR-008 (portable install two-layer model) requires SKILL.md files to be self-contained — skills must not depend on external reference files being present at runtime.

The pattern has three steps:
1. Attempt to read `./config.json`; if it exists and contains `version` + `engagement.slug`, set `engagement_path = ./` and skip Step 2.
2. Otherwise, use existing `engagements/<slug>/config.json` discovery (slug from `--slug`, single-folder auto-select, or disambiguation prompt).
3. If neither yields a config, surface the error message with `/cb-init` and `/cb-init --root` guidance.

### `coach-buddy` context loading is optional and silent

`coach-buddy`'s Engagement Path Resolver is applied silently. If no engagement is found, `coach-buddy` proceeds without context — no error. Engagement context enriches conversations but is not required, unlike engagement-management skills (`cb-log`, `cb-validate`) which cannot function without an engagement.

### COACHING_LOG.md collision warning

The overwrite guard is anchored on `config.json` (ADR-012 D5). An additive warning fires when `./config.json` is absent but `./COACHING_LOG.md` exists while `--root` is active — preserving coach agency while surfacing data-loss risk.

---

## Steps Completed

### DISCUSS wave
- Scope assessed: 3 stories (US-CBR-01, US-CBR-02, US-CBR-03 @infrastructure), 1 bounded context
- New job `cowork-native-setup` added to `docs/product/jobs.yaml` (WD-002)
- ADR-012 written and locked at DISCUSS — design not re-opened downstream
- Journey visualisation phase waived (WD-001): existing `ongoing-engagement.yaml` captures the journey shape; updating post-DELIVER is tracked as a watch item
- 6 wave decisions documented (WD-001 through WD-006)

### DESIGN wave
- Reuse analysis: all six SKILL.md files are extensions (REF-D1); no new files
- Component decomposition across all 12 section changes (REF-D2)
- Data flow diagrams for Slice 01 (flag parsing) and Slice 02 (detection chain) (REF-D3)
- Engagement Path Resolver named pattern defined verbatim (REF-D4)
- SKILL.md change blueprint section-by-section for all six files (REF-D5)
- C4 System Context diagram (REF-D6)
- Outcomes registry skip documented (DD-001): no typed contract surface
- Peer review: approved iteration 1 — 0 critical, 0 high, 3 medium issues (all resolved)

### DISTILL wave
- WS Strategy C (real local) declared (TD-002)
- No RED scaffold stubs required (TD-001): SKILL.md files already exist; "red" = scenario describes behaviour not yet present
- 21 Gherkin scenarios across 3 tags: `@walking_skeleton`, `@real-io` happy path, `@error @real-io` (REF-T2)
- Error path ratio: 9/21 = 43% (target ≥40% — PASS)
- Story traceability: US-CBR-01 (7), US-CBR-02 (10), US-CBR-03 (1 dedicated + embedded)
- Peer review: approved iteration 1 — 0 critical, 0 high, 1 medium (accepted as documented WS trade-off)

### DELIVER wave
- 2 steps, 1 phase: Step 01-01 (cb-init), Step 01-02 (downstream skills)
- DES execution log: all phases PREPARE / RED_ACCEPTANCE / RED_UNIT / GREEN / COMMIT — PASS
- Gap fix applied to Step 01-01 during adversarial review: `--root <path>` unsupported handling added
- Post-merge integration gate: 21/21 scenarios verified (WS strategy C, prose review)
- Adversarial review: 5 issues found and resolved (see Issues Encountered)
- Mutation testing: SKIP — SKILL.md-only feature, no executable code
- DES integrity verification: PASS — 2 steps with complete traces

---

## Issues Encountered and Resolved

Five issues surfaced during the adversarial review pass (Phase 4):

1. **Critical path bug — path slash in cb-log confirmation message** (Severity: critical)
   The `Entry {id} added to {engagement_path}COACHING_LOG.md` confirmation message was missing a `/` separator. In root layout where `engagement_path = ./`, this produced `./COACHING_LOG.md` correctly by accident, but in legacy layout produced `engagements/<slug>COACHING_LOG.md` (no slash). Fixed: all `{engagement_path}` references use `{engagement_path}/FILENAME` consistently.

2. **Under-specified qualifying-folder logic in Step 2** (Severity: medium)
   Step 2 of the Engagement Path Resolver in all five skills said "look for folders under `engagements/`" without specifying that only folders containing a `config.json` qualify. A folder without `config.json` would have caused ambiguous disambiguation behaviour. Fixed: clarification added — "qualifying folder" is defined as one containing a `config.json`.

3. **`--root <path>` handling not addressed in cb-init** (Severity: medium)
   The Flag parsing section did not handle the case where a coach writes `/cb-init --root ./some-path`. Fixed: a note added to the Flag parsing section stating that `--root <path>` is not supported and suggesting `cd <path> && cb-init --root` as the workaround.

4. **coach-buddy multi-legacy non-determinism** (Severity: medium)
   If multiple legacy engagements exist under `engagements/`, the Engagement Path Resolver in coach-buddy would enter the disambiguation prompt path — but coach-buddy's context loading is supposed to be silent. Fixed: when multiple legacy engagements exist, coach-buddy skips context loading entirely (no prompt, no error) rather than triggering disambiguation.

5. **cb-snapshot frontmatter description stale** (Severity: low)
   The `description` field in cb-snapshot's frontmatter still referenced the old single-layout behaviour. Updated to reflect both root-layout and legacy-layout support.

---

## File Migration

No file migration required. ADR-012 was written directly to SSOT (`docs/product/architecture/`) during the DISCUSS wave. Acceptance tests were written directly to `tests/acceptance/cb-root-layout/`. No temporary design files needed migration.

**Phase B skipped**: this feature has no separate `design/architecture-design.md`, `design/adrs/`, `distill/walking-skeleton.md`, or `discuss/journey-*.yaml` files. The design is embedded in `feature-delta.md`. ADR-012 already lives at its permanent location. Nothing to migrate.

---

## Watch Items / Open Threads

1. **`--root <path>` extension deferred** (ADR-012 D4): when this extension ships, all five Engagement Path Resolver embeddings will need updating — a known multi-site edit, acceptable at current scale.

2. **`ongoing-engagement.yaml` post-DELIVER update** (DISCUSS WD-001): `docs/product/journeys/ongoing-engagement.yaml` step `engagement-start` still shows `engagements/<slug>/` paths. Add layout-conditional notes to reflect both root and legacy layouts.

3. **Schema detection is prose-level, not typed** (Design DD-001): the `version` + `engagement.slug` schema match is prose instruction in SKILL.md. If a future feature introduces typed `config.json` parsing, these field names become a typed contract surface. Flag when that feature is scoped.

---

## Permanent Artifacts

| Artifact | Location |
|----------|----------|
| ADR-012 | `docs/product/architecture/adr-012-root-layout-cowork-placement.md` |
| Architecture brief (cb-root-layout section) | `docs/product/architecture/brief.md` |
| Acceptance tests | `tests/acceptance/cb-root-layout/` |
| Wave history | `docs/feature/cb-root-layout/` |
| Deliver roadmap | `docs/feature/cb-root-layout/deliver/roadmap.json` |
| DES execution log | `docs/feature/cb-root-layout/deliver/execution-log.json` |
