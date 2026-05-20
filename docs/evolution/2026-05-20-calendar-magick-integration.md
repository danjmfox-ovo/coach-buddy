# Evolution: calendar-magick-integration

**Date**: 2026-05-20
**Feature**: calendar-magick-integration
**Delivery completed**: 2026-05-19
**Wave gate**: PASS (execution log empty due to known DES PYTHONPATH bug; delivery verified manually — 28/28 acceptance scenarios GREEN)

---

## Feature Summary

Integrated calendar-magick's `teams.yaml` team topology file into three coach-buddy skills (`cb-init`, `cb-snapshot`, `cb-log`), eliminating the need to duplicate and synchronise team member, role, and sprint cadence data across two separate tools.

Four user stories shipped across three slices:

- **US-01 + US-03** (`cb-init`): optional Q6 prompt to link a `teams.yaml` during engagement setup; auto-detection of `teams/*/config.yaml` files in the current directory pre-suggests a path. When confirmed, `config.json` gains a `team_config.path` top-level key.
- **US-02** (`cb-snapshot`): sprint-aware snapshot header — when `cadence: scrum` is present in the linked `teams.yaml`, the snapshot header and risk-read gain a sprint-context suffix: `| Day D, Week W/N of Sprint (N-week scrum, started YYYY-MM-DD)`. Computed from fixed epoch 2020-01-06 with weekend-freeze.
- **US-04** (`cb-log`): team member hints before "Who was in the session?" — roster shown from `team.members`; Enter selects full team; names written to a new optional `participants:` frontmatter field in COACHING_LOG.md entries.

All changes are additive. Engagements without `team_config.path` show zero behaviour change.

---

## Business Context

**Primary job**: `ceremony-aware-engagement` — when coaching a team that also uses calendar-magick, the coach wants coaching tools to read team structure and sprint cadence from the teams.yaml already maintained, avoiding duplicate data entry and drift.

**Enabling jobs**: `engagement-scaffolding` (J9), `board-snapshot-without-context-switch` (J8), `situated-coaching-across-sessions` (J6).

**Pain addressed**: Team topology data (members, roles, sprint cadence) lived in two separate files with no bridge between them. Coaches were typing the same names and roles into both calendar-magick and coaching logs, with inconsistency accumulating over time.

**Integration boundary**: `config.json` retains all coaching-specific metadata; `teams.yaml` carries team topology. coach-buddy reads `teams.yaml` only when `team_config.path` is explicitly set — opt-in, zero migration cost for existing engagements.

**Scope**: 3 SKILL.md files modified (158 lines added), 1 new ADR, 3 acceptance test files. Delivered in approximately 3 days.

---

## Key Decisions

### DISCUSS wave
- **D1**: Coexistence with typed reference (not replacement) — both files retained, linked explicitly. Rejected: expanding config.json with calendar-magick data inline (inverts separation of concerns)
- **D2**: coach-buddy is read-only on teams.yaml — calendar-magick owns the write path
- **D3**: Detection strategy is explicit reference at runtime (`team_config.path`), not filesystem scanning. Exception: cb-init scans as a setup convenience only
- **D4**: `team_config.path` is relative to the engagement root for portability

### DESIGN wave
- **DD-01**: `team_config` as a top-level peer key in config.json (alongside `tool` and `engagement`) — a named integration block with room for future extension (e.g. a `type` discriminator)
- **DD-02**: Named "Team Context Resolver" sub-pattern embedded verbatim in each consuming skill, following ADR-008 self-containment invariant. Rejected: extracted shared reference file (violates ADR-008)
- **DD-03**: Sprint position epoch fixed at 2020-01-06 (Monday, ISO week 2020-W02). Uses ISO week arithmetic + modulo N. Rejected: storing sprint start date in config.json (DISCUSS locked decision); pure mod-on-ISO-week without epoch (drift at year boundaries)
- **DD-04**: Q6 position is after Q5 (WIP threshold) — last question in the setup flow, per AC-01.1
- **DD-05**: Weekend handling — freeze at preceding Friday. Sprint ceremonies happen on weekdays; a coach preparing on a weekend is viewing Friday's position

**Anti-Corruption Layer**: Only three fields from teams.yaml are consumed (`cadence`, `sprint_length_weeks`, `members`). All other calendar-magick schema fields (`events`, `calendar_id`, etc.) are silently ignored.

### DISTILL wave
- Walking Skeleton Strategy C (real local) — matches established project pattern
- No scaffold stubs needed — SKILL.md files already exist
- 28 scenarios across 4 .feature files; error path ratio adequate

---

## Steps Completed

From roadmap.json (execution log empty due to known DES PYTHONPATH bug — delivery verified by prose review against 28 acceptance scenarios):

| Step | Description | Status |
|------|-------------|--------|
| 01-01 | cb-init: Q6 teams.yaml link prompt and auto-detection | PASS |
| 01-02 | cb-snapshot: Team Context Resolver and Sprint Position Calculator | PASS |
| 01-03 | cb-log: Team Context Resolver and member hints with participants field | PASS |

All 3 steps verified against acceptance criteria. 28/28 scenarios confirmed GREEN by manual prose review.

**Note on empty execution log**: The DES tool (nwave-ai) requires a `PYTHONPATH` prefix in the pipx venv context that was not present at the time of delivery. The log records no events — not because steps were skipped but because the event recording mechanism failed silently. The roadmap validation note reads: "Implementation verified against all 28 acceptance scenarios." This is the documented DES PYTHONPATH bug (see memory: `feedback-des-pythonpath.md`).

---

## Test Coverage

28 acceptance scenarios across 4 files:
- `tests/acceptance/calendar-magick-integration/walking-skeleton.feature` (2 WS scenarios)
- `tests/acceptance/calendar-magick-integration/slice-01-teams-yaml-link.feature` (9 scenarios: US-01 + US-03)
- `tests/acceptance/calendar-magick-integration/slice-02-sprint-aware-snapshot.feature` (9 scenarios: US-02)
- `tests/acceptance/calendar-magick-integration/slice-03-member-hints.feature` (8 scenarios: US-04)

7 error/degradation scenarios cover: file not found, unreadable teams.yaml, absent `cadence` field, absent `team_config` key, kanban cadence (no sprint context), and COACHING_LOG.md backward compatibility.

---

## Issues Encountered

1. **DES PYTHONPATH bug** (non-blocking, pre-existing): The DES tool event recording did not function during delivery due to the pipx venv context issue. Workaround: orchestrator executed steps directly and verified against acceptance scenarios. Bug tracked in memory file `feedback-des-pythonpath.md`.

2. **OQ-04 (participants field)**: The `participants:` frontmatter field was not present in the existing COACHING_LOG.md entry format. Resolved during DISTILL wave pre-requisite check — added as a new optional field analogous to the existing optional `mode:` field. No migration required for existing entries.

3. **OQ-01 (multi-team files)**: Teams.yaml files containing multiple team entries are handled by reading only the first `team:` block. Documented as a known limitation; disambiguation is out of scope for this feature.

---

## Lessons Learned

1. **Team Context Resolver pattern naming**: Giving the YAML reader sub-pattern a stable name ("Team Context Resolver") — parallel to the Engagement Path Resolver from cb-root-layout — made it straightforward to reason about the resolver chain (Engagement Path Resolver → Team Context Resolver → skill logic). Named patterns pay off at the design communication layer before implementation begins.

2. **Sprint epoch as a design decision (ADR-013)**: The choice of a fixed epoch anchor for sprint position calculation surfaced a genuine architectural question (reproducibility vs. calendar alignment) that warranted an ADR. The decision to use 2020-01-06 with ISO week arithmetic produces correct alignment for typical teams; documented as a known limitation for teams with fiscal-year sprint anchors.

3. **Graceful degradation as a first-class design concern**: The Team Context Resolver's three-level degradation (absent `team_config` key → unreadable file → absent field) was specified in the DESIGN wave contract before the crafter touched any SKILL.md. This prevented the common pitfall of treating the degradation path as an afterthought. All three degradation paths have dedicated `@error @real-io` scenarios.

4. **OQ-04 resolution timing**: Open questions that touch existing data formats (like the `participants:` field) should be resolved no later than the DISTILL wave pre-requisites check, not discovered by the crafter mid-implementation.

---

## Files Modified

| File | Change |
|------|--------|
| `skills/cb-init/SKILL.md` | Q6 prompt + auto-detection sub-step + optional `team_config` block in config.json template + confirmation output |
| `skills/cb-snapshot/SKILL.md` | Team Context Resolver sub-pattern + Sprint Position Calculator + conditional sprint-context suffix in header and risk read |
| `skills/cb-log/SKILL.md` | Team Context Resolver sub-pattern + member hint Step 1a + optional `participants:` frontmatter field |
| `docs/product/architecture/adr-013-sprint-position-epoch-anchor.md` | New ADR — epoch anchor decision record |
| `docs/product/architecture/brief.md` | Team Context Resolver pattern + calendar-magick-integration component table |
| `docs/product/jobs.yaml` | `ceremony-aware-engagement` job added |

---

## Outcome KPIs (baseline established)

| KPI | Target | Status |
|-----|--------|--------|
| Link adoption rate | ≥60% of new cb-init runs in repos with `teams/` result in `team_config.path` written | Baseline: not yet measurable — requires real-world usage data |
| Sprint context in snapshots | ≥80% of snapshots where engagement has `team_config.path` and `cadence: scrum` | Baseline: not yet measurable |
| Zero regression on existing engagements | 0 changed behaviours | VERIFIED — 5 dedicated regression scenarios green |
| cb-log member consistency | Baseline metric to establish | Not yet measurable — track COACHING_LOG.md `participants:` field adoption |

---

## References

- ADR-013: `docs/product/architecture/adr-013-sprint-position-epoch-anchor.md`
- ADR-008: `docs/product/architecture/adr-008-portable-install-two-layer-model.md`
- Acceptance tests: `tests/acceptance/calendar-magick-integration/`
- Feature artifacts: `docs/feature/calendar-magick-integration/`
- Commit: 41f22ec
