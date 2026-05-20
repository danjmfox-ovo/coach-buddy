# Evolution: cb-root-layout

**Date**: 2026-05-20
**Feature**: cb-root-layout
**Delivery completed**: 2026-05-19
**Wave gate**: PASS (all 12 execution events EXECUTED/PASS)

---

## Feature Summary

Added `--root` flag support to the coach-buddy skill layer, enabling agile coaches who use a single dedicated CoWork project directory (e.g., `~/teams/advisor-connect`) to scaffold and operate an engagement at the project root rather than inside an `engagements/<slug>/` subdirectory.

Two slices shipped atomically:

- **Slice 01** (`cb-init`): new `--root` flag, conditional overwrite guard, `{target}` path variable, COACHING_LOG.md collision warning, updated argument-hint and documentation
- **Slice 02** (all five downstream skills): the Engagement Path Resolver pattern embedded verbatim in `cb-log`, `cb-retro`, `cb-snapshot`, `cb-validate`, and `coach-buddy` — each skill detects root layout by checking `./config.json` for the engagement schema before falling back to the legacy `engagements/<slug>/` path

All changes are SKILL.md prose only. No executable code was produced or modified.

---

## Business Context

**Primary job**: `cowork-native-setup` — initialise a coaching engagement in a project directory that IS the engagement, with no redundant wrapper folder.

**Pain addressed**: Coaches using dedicated CoWork directories were forced to store engagement files inside `engagements/<slug>/` — a path structure designed for multi-engagement projects that created friction in single-engagement projects. Manual workarounds broke all downstream skill path references.

**Real-world validation**: `~/teams/advisor-connect` manual migration confirmed the desired ergonomic before implementation began.

**Scope**: 6 SKILL.md files modified, 2 slices, 1 bounded context (engagement path resolution). Delivered in approximately 3 days.

---

## Key Decisions

### DISCUSS wave
- **WD-002**: New JTBD `cowork-native-setup` added to `docs/product/jobs.yaml` — the existing `engagement-scaffolding` (J9) job did not capture the CoWork-pattern pain specifically
- **WD-003**: US-CBR-03 (slug disambiguation bypass) designated `@infrastructure` — no user-visible surface beyond absence of disambiguation prompt
- **WD-004**: `--root <path>` variant explicitly out of scope per ADR-012 D4
- **WD-006**: Slice 02 must ship atomically — partial downstream rollout would leave coaches with a broken init → log cycle

### DESIGN wave
- **DD-002**: Engagement Path Resolver specified as a single named pattern embedded verbatim in each downstream SKILL.md rather than extracted to a shared reference file. Rationale: ADR-008 self-containment invariant — skills installed into team project directories must not depend on reference files being present at runtime. The pattern is short enough that verbatim embedding costs less than the indirection overhead
- **DD-003**: `coach-buddy` engagement context is optional and silent — if no engagement is found, coach-buddy proceeds without context and does not surface an error. This contrasts with engagement-management skills (cb-log, cb-retro, etc.) where a missing engagement is a hard error
- **DD-004**: COACHING_LOG.md collision warning added to `cb-init` — when `--root` is active and `./config.json` is absent but `./COACHING_LOG.md` exists, cb-init warns before proceeding. The overwrite guard anchors on config.json (ADR-012 D5 locked), but the file collision risk warranted a warning
- **DD-005**: No new ADR created — ADR-012 (locked) covers the architectural decision; wave decisions record implementation specifications only
- **DD-006**: C4 scope limited to System Context (L1) — no containers or services in a CLI skill layer

### DISTILL wave
- **TD-001**: No RED scaffold stubs — SKILL.md files already exist; the crafter modifies existing files against failing scenarios
- **TD-002**: Walking Skeleton Strategy C (real local) — all resources are local filesystem SKILL.md files, no automated test runner applicable
- **TD-003**: Acceptance tests as Gherkin feature file + manual test script, matching established project convention

---

## Steps Completed

From execution-log.json (schema_version 3.0):

| Step | Phase | Result |
|------|-------|--------|
| 01-01 | PREPARE | PASS |
| 01-01 | RED_ACCEPTANCE | PASS |
| 01-01 | RED_UNIT | PASS |
| 01-01 | GREEN | PASS |
| 01-01 | COMMIT | PASS |
| 01-02 | PREPARE | PASS |
| 01-02 | RED_ACCEPTANCE | PASS |
| 01-02 | RED_UNIT | PASS |
| 01-02 | GREEN | PASS |
| 01-02 | COMMIT | PASS |
| 01-01 | GREEN (gap fix) | PASS — `--root <path>` unsupported handling added to cb-init Flag parsing section |
| 01-02 | COMMIT (integration gate) | PASS — post-merge integration gate; 21 scenarios verified via prose review; gap fix logged |

**Quality gate summary**: 2/2 steps, all phases EXECUTED/PASS. Gap fix applied post-GREEN for `--root <path>` unsupported path handling. Adversarial review passed after 1 revision (5 issues found and resolved: 1 critical path bug, 4 under-specified edge cases).

---

## Test Coverage

21 acceptance scenarios across 2 files:
- `tests/acceptance/cb-root-layout/walking-skeleton.feature` (21 scenarios)
- `tests/acceptance/cb-root-layout/test-script.md` (18 numbered manual runs)

Error path ratio: 9/21 = 43% (threshold: 40%) — PASS.

Story traceability: US-CBR-01 (7 scenarios), US-CBR-02 (10 scenarios), US-CBR-03 (1 dedicated + embedded in all root-layout scenarios).

---

## Issues Encountered

1. **`--root <path>` edge case gap** (caught in gap fix phase): The initial GREEN implementation did not explicitly handle the case where a coach types `--root ./some-path`. Added handling to the Flag parsing section of cb-init to note the limitation and suggest `cd <path> && cb-init --root` as the workaround.

2. **Adversarial review findings** (resolved in single iteration):
   - 1 critical path bug (undisclosed in delta, resolved before finalisation)
   - 4 under-specified edge cases addressed via SKILL.md prose clarification
   - DESIGN peer review: coach-buddy insertion point under-specified (medium issue) — resolved by adding exact insertion point: after `## Core stance`, before `## Mode management`

3. **DES PYTHONPATH issue** (not blocking this feature, noted for future): DES tool requires PYTHONPATH prefix in pipx venv context. This did not affect cb-root-layout delivery as the execution log was written correctly.

---

## Lessons Learned

1. **Named patterns as first-class design artifacts**: The Engagement Path Resolver naming convention proved valuable — giving the pattern a stable identifier made peer review, acceptance testing, and the crafter handoff cleaner. Worth applying to future cross-cutting SKILL.md patterns.

2. **Verbatim embedding vs. extraction**: ADR-008 (SKILL.md self-containment) creates a recurring tension when patterns are shared across multiple skills. The resolution — verbatim embedding with a named identifier — is the correct pattern for this project's deployment model. Document the "five-site edit" maintenance cost explicitly in any future extension of the resolver.

3. **Walking Skeleton Strategy C sufficiency**: For SKILL.md-only features, manual prose review against Gherkin scenarios is the appropriate and sufficient verification strategy. Automated runners add no value at this layer.

4. **Gap fix timing**: The adversarial review phase is the correct place to catch edge cases like `--root <path>`. The initial RED/GREEN cycle caught the primary behaviour; the review pass caught boundary conditions. This sequence is working as designed.

---

## Files Modified

| File | Change |
|------|--------|
| `skills/cb-init/SKILL.md` | New `## Flag parsing` section; `--root` flag; `{target}` path variable; conditional overwrite guard; COACHING_LOG.md collision warning; updated argument-hint and What this does |
| `skills/cb-log/SKILL.md` | Engagement Path Resolver replaces hardcoded config read; path slash bug fixed; qualifying-folder clarification |
| `skills/cb-retro/SKILL.md` | Engagement Path Resolver replaces hardcoded config read; qualifying-folder clarification |
| `skills/cb-snapshot/SKILL.md` | Engagement Path Resolver; `{engagement_path}` in output/confirmation/coaching-context; frontmatter description updated |
| `skills/cb-validate/SKILL.md` | Engagement Path Resolver; `{engagement_path}COACHING_LOG.md`; qualifying-folder clarification |
| `skills/coach-buddy/SKILL.md` | New `## Engagement context (optional)` section; Engagement Path Resolver (silent, no error); multi-legacy non-determinism fixed |

---

## References

- ADR-012: `docs/product/architecture/adr-012-root-layout-cowork-placement.md`
- ADR-008: `docs/product/architecture/adr-008-portable-install-two-layer-model.md`
- Acceptance tests: `tests/acceptance/cb-root-layout/`
- Feature artifacts: `docs/feature/cb-root-layout/`
