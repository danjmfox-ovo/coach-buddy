# Wave Decisions — cb-root-layout
<!-- DISCUSS wave decisions log -->
<!-- Feature: cb-root-layout -->
<!-- Date: 2026-05-19 -->

## Scope Assessment: PASS — 3 stories, 1 bounded context (engagement path resolution), estimated 3-4 days

Stories:
- US-CBR-01: Coach can scaffold an engagement at the project root via `cb-init --root`
- US-CBR-02: Downstream skills detect root layout and resolve paths correctly
- US-CBR-03: Slug disambiguation is bypassed in root layout (infrastructure — no user-visible surface beyond existing flow)

Contexts touched: engagement lifecycle (cb-init, cb-log, cb-retro, cb-snapshot, cb-validate, coach-buddy). All share one concern: path resolution. Treated as one bounded context.

---

## Wave Decision WD-001: Journey Visualisation Phase Skipped

**Rationale**: The user journey for this feature is already captured in `docs/product/journeys/ongoing-engagement.yaml` (step `engagement-start`). The `--root` flag changes the target directory of scaffolding, not the shape or emotional arc of the journey. Producing a new journey YAML would duplicate existing artifacts with only a path variable change.

**Risk**: `ongoing-engagement.yaml` still shows `engagements/<slug>/` paths in `artifacts_produced`. This should be updated post-implementation to show both layouts. Noted as a post-DELIVER task.

**Gate status**: Waived with documented justification.

---

## Wave Decision WD-002: New Job Added — cowork-native-setup

**Rationale**: Existing job `engagement-scaffolding` (J9) describes "scaffold a new engagement folder with one command" but frames the outcome as consistent structure. It does not capture the pain specific to CoWork-pattern projects: the redundant `engagements/<slug>/` wrapper when the project IS the engagement. A new job `cowork-native-setup` was added to `docs/product/jobs.yaml` to anchor US-CBR-01 and US-CBR-02.

**Decision**: J9 remains the secondary job anchor (this feature extends scaffolding, not replaces it). `cowork-native-setup` is the primary job for the user-facing stories.

---

## Wave Decision WD-003: US-CBR-03 designated @infrastructure

**Rationale**: Slug disambiguation bypass has no user-visible surface. The coach does not see a disambiguation prompt in root layout — the absence of a prompt is the outcome, and it is a consequence of root layout detection (US-CBR-02), not an independently invocable behaviour. Tagged `@infrastructure` with rationale. JTBD field set to `infrastructure-only`.

**Reviewer note**: US-CBR-03 is embedded in Slice 02 alongside US-CBR-02 (a user-visible story). Slice 02 is not an all-infrastructure slice.

---

## Wave Decision WD-004: --root `<path>` variant explicitly out of scope

Per ADR-012 D4: `cb-init --root <path>` (arbitrary target) is a future extension and is NOT included in any story or scenario. If a scenario tests `cb-init --root ./some-path`, it is out of scope and should be removed.

---

## Wave Decision WD-005: Overwrite guard path change is part of Slice 01

The overwrite guard currently checks `engagements/<slug>/config.json`. In root layout it must check `config.json` in the target directory. This is a direct consequence of the `--root` flag and is included in US-CBR-01 (not a separate story).

---

## Wave Decision WD-006: Partial rollout is a known risk

ADR-012 Consequences section flags: shipping cb-init `--root` without updating downstream skills produces a broken init-then-log cycle. The two slices are ordered to mitigate this: Slice 01 (cb-init) must ship before Slice 02 (downstream skills), and Slice 02 must be treated as a single atomic delivery — no partial downstream rollout.
