# Wave Decisions — cb-root-layout
<!-- DISTILL wave decisions log -->
<!-- Feature: cb-root-layout -->
<!-- Date: 2026-05-19 -->

## Scope Assessment: PASS — 3 stories (US-CBR-01, US-CBR-02, US-CBR-03 @infrastructure), SKILL.md-only

---

## Wave Decision TD-001: No RED Scaffold Stubs Required

**Decision**: The DELIVER wave crafter does not need stub SKILL.md files to be created before the first test. The six SKILL.md files already exist in `plugins/coach-buddy/skills/`. These tests are written AGAINST the existing files.

**Rationale**: This project has no compiled production modules. SKILL.md files are markdown prose instructions. The "red" state is: the test scenario describes behaviour the current SKILL.md does not yet implement. The crafter reads the failing scenario and modifies the existing SKILL.md to satisfy it. The feedback loop is: (1) run manual scenario, (2) observe skill does not yet exhibit the described behaviour, (3) update SKILL.md, (4) re-run scenario.

**Impact on handoff**: DELIVER wave crafter receives: (a) existing SKILL.md files at their current state, (b) acceptance test files defining target behaviour, (c) DESIGN wave's change blueprint (REF-D5) specifying exactly which sections to modify. No stub generation step.

---

## Wave Decision TD-002: Walking Skeleton Strategy — C (Real Local)

**Decision**: WS Strategy C (real local) is the correct strategy for this feature.

**Rationale**: All resources are local filesystem SKILL.md files. There are no external APIs, no network calls, no database, no Docker containers, and no costly external services. The "driven adapter" is the SKILL.md file itself — Claude Code reads it and follows its instructions. The walking skeleton invokes a real slash command (`/cb-init --root`, `/cb-log`, etc.) in a real Claude Code session against the real installed SKILL.md file.

**Implication**: No `@in-memory` tags are appropriate for walking skeleton scenarios. The `@real-io` tag signals that the test requires real filesystem access (the SKILL.md file must be installed and readable). Test doubles or mocks have no meaningful role at this layer.

---

## Wave Decision TD-003: Test Format Matches Existing Project Convention

**Decision**: Acceptance tests are delivered as:
1. `walking-skeleton.feature` — Gherkin `.feature` file with all scenarios
2. `test-script.md` — Manual test script with explicit run instructions, verification commands, and pass/fail table

**Rationale**: This matches the format established in `tests/acceptance/cb-review-improvements/` and `tests/acceptance/coach-buddy-slice-03/`. The project uses manual conversation testing (LLM behaviour cannot be automated with Vitest), supplemented by a structured Gherkin file that serves as living documentation and the outer-loop definition of done.

**What is NOT used**: pytest, pytest-bdd, Behave, or any Python BDD framework. Vitest unit tests in `tests/unit/` cover installer and plugin-validation logic — a different concern, not extended here.

---

## Wave Decision TD-004: Outcomes Registry Skip

**Decision**: The outcomes registry is not updated for this feature.

**Rationale**: This is a SKILL.md-only change. There is no typed contract surface, no new domain model, no new TypeScript or JavaScript type exported, and no outcomes registry entry that this feature affects. Documented here per DD-001 in the DESIGN wave decisions. No further justification required.

---

## Wave Decision TD-005: KPI Contracts — Not Applicable

**Decision**: No `@kpi` scenarios are required for this feature.

**Rationale**: `docs/product/kpi-contracts.yaml` was checked. The KPI for this feature is framed as an operational metric in the slice documentation ("100% of root-layout inits produce usable file placement with zero manual follow-up steps") but is not registered as a machine-measurable contract in `kpi-contracts.yaml`. The metric is validated by the walking skeleton test (Scenario 1a) — if cb-init --root creates all files correctly and the downstream skills read them, the KPI is satisfied. No separate `@kpi` observability scenario is warranted.

---

## Wave Decision TD-006: US-CBR-03 Coverage via US-CBR-02 Scenarios

**Decision**: US-CBR-03 (slug disambiguation bypass, `@infrastructure`) does not require dedicated isolated scenarios beyond those already covering US-CBR-02. A targeted scenario is included that explicitly verifies slug resolution from root config.json, tagged `@US-CBR-03`.

**Rationale**: US-CBR-03's DISCUSS wave decision (WD-003) established that this story has no user-visible surface beyond the absence of a disambiguation prompt. That absence is validated as a Then clause in every US-CBR-02 scenario that runs in root layout. The dedicated scenario (Scenario 2f in the feature file) provides explicit traceability coverage for the Dimension 8 traceability check.

---

## Wave Decision TD-007: Error Path Ratio

**Total scenarios**: 21
**Error/edge scenarios**: 9 (Scenarios: overwrite guard, --force bypass, collision warning, no engagement cb-log, no engagement cb-validate, non-engagement config fallback, --root with path, multiple legacy disambiguation, coach-buddy silent no-engagement)
**Error ratio**: 9/21 = 43% — exceeds the 40% threshold.

Scenario categories:
- Walking skeleton: 3 (@walking_skeleton @real-io)
- Happy path: 7 (root layout per-skill, legacy regression)
- Error/edge: 9 (overwrite guards, collision warning, no-engagement errors, schema specificity, unsupported flag usage, disambiguation preservation)

---

## Wave Decision TD-008: coach-buddy Coverage Note

**Decision**: coach-buddy acceptance scenarios are included with the caveat that coach-buddy's engagement context loading is silent (DD-003 from DESIGN wave). Scenarios verify (a) no error when context is present, (b) no error when context is absent. They do NOT assert on the quality of the coaching response — that is out of scope for this feature.

**Rationale**: The feature change to coach-buddy is the addition of the Engagement Path Resolver section. The test surfaces observable behaviour: presence or absence of errors/prompts, not response quality.

---

## Peer Review Record

See Phase 4 review output in feature-delta.md DISTILL section.

---

## Quality Gate Status

| Gate | Status | Evidence |
|---|---|---|
| All stories covered | PASS | US-CBR-01: 7 scenarios; US-CBR-02: 8 scenarios; US-CBR-03: 1 dedicated + embedded in all US-CBR-02 |
| Error path ratio >= 40% | PASS | 9/21 = 43% |
| Business language verified | PASS | Zero technical terms in Gherkin; file paths are domain language in this context |
| @walking_skeleton tagged | PASS | 3 scenarios tagged @walking_skeleton @real-io |
| @kpi scenarios | N/A | No kpi-contracts.yaml entry for this feature |
| Strategy C declared | PASS | TD-002; @real-io on all WS scenarios; no @in-memory tags |
| Scaffold note | PASS | TD-001; DELIVER receives existing SKILL.md files + tests + change blueprint |
