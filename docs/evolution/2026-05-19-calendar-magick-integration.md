# Evolution: calendar-magick-integration

**Date**: 2026-05-19
**Feature**: calendar-magick-integration
**Version target**: v1.10.0
**ADR**: [ADR-013](../product/architecture/adr-013-sprint-position-epoch-anchor.md)

---

## Feature Summary

Added calendar-magick teams.yaml integration to three existing SKILL.md skills (`cb-init`, `cb-snapshot`, `cb-log`). Coaches who maintain a `teams.yaml` in calendar-magick now have a single source of truth for team topology — member names, roles, sprint cadence, and sprint length. coach-buddy reads the file directly; no duplication, no sync step.

`cb-init` gains an optional Q6 prompt plus an auto-detection sub-step that scans `teams/*/config.yaml` at the current directory. When a path is confirmed, `config.json` gains an optional top-level `team_config` block. `cb-snapshot` embeds the Team Context Resolver (reads the `team_config.path` reference from `config.json`, parses the teams.yaml subset) and the Sprint Position Calculator (fixed epoch 2020-01-06, ISO week arithmetic, weekend-freeze rule); the snapshot header and risk-read gain an optional sprint-context suffix when `cadence: scrum`. `cb-log` embeds the same Team Context Resolver and adds a member hint before the "Who was in the session?" prompt; pressing Enter for the full team writes all member names to a new optional `participants:` frontmatter field in COACHING_LOG.md entries.

All changes are additive. Engagements without `team_config.path` show zero behaviour change.

**Scope**: SKILL.md prose changes only — three files modified, 158 insertions, 0 new files created.

---

## Business Context

**Primary JTBD**: `ceremony-aware-engagement` — *When I coach a team that also uses calendar-magick, I want my coaching tools to read team structure and sprint cadence from the teams.yaml I already maintain, so I don't have to duplicate and sync the same data in two places.*

**Enabling jobs**: `engagement-scaffolding` (J9), `board-snapshot-without-context-switch` (J8), `situated-coaching-across-sessions` (J6).

The reference context is a CoWork project directory that sits alongside a calendar-magick teams directory. Before this feature, an agile coach maintaining both tools had to enter team member names, roles, and sprint cadence in two separate files and keep them manually synchronised. The friction point was most visible when a team member joined or left: both `config.json` and `teams.yaml` required separate updates.

**Outcome KPIs**:

| KPI | Target |
|-----|--------|
| Link adoption rate | ≥60% of new `cb-init` runs in repos with a `teams/` dir result in a `team_config.path` being written |
| Sprint context in snapshots | Sprint header present in ≥80% of snapshots where engagement has `team_config.path` and teams.yaml has `cadence: scrum` |
| Zero regression on existing engagements | 0 engagements without `team_config.path` show changed behaviour |

---

## Key Decisions

### DISCUSS Decisions

**D1 — Coexistence, not replacement**
`config.json` retains all coaching-specific metadata. `teams.yaml` carries team topology. coach-buddy reads `teams.yaml` only when `team_config.path` is explicitly set in `config.json`. Neither file is eliminated. Replacing `config.json` with `teams.yaml` would force calendar-magick's schema onto coaches who don't use it; coexistence keeps both tools independently usable.

**D2 — Read-only access from coach-buddy**
coach-buddy skills read `teams.yaml`; they never write it. calendar-magick owns the write path.

**D3 — Explicit reference, not filesystem scanning at runtime**
coach-buddy reads `team_config.path` from `config.json` at runtime. Filesystem scanning (except for `cb-init` setup convenience) was ruled out — explicit is better than implicit.

**D4 — `team_config.path` relative to engagement root**
Keeps the reference portable when the CoWork project is moved or cloned.

### DESIGN Decisions

**DD-01 — `team_config` as a top-level peer key**
Follows the established pattern of `tool` and `engagement` as top-level peers in `config.json`. Nesting under `engagement` would conflate engagement identity with integration references. A flat string `"team_config_path"` has no room for future extension (e.g. a `type` discriminator).

**DD-02 — Team Context Resolver as a named sub-pattern, embedded verbatim**
A named pattern gives acceptance-designer and software-crafter a stable identifier to test against. "Verbatim embedded" preserves ADR-008 self-containment. Three skills share the identical pattern text — a known multi-site maintenance cost, acceptable at this scale to avoid creating a shared reference file dependency.

**DD-03 — Sprint position epoch anchor: 2020-01-06** (see ADR-013)
A fixed epoch anchor eliminates year-boundary drift in modulo-sprint arithmetic. The epoch is arbitrary but permanent. Two coaches with 2-week sprints see the same sprint boundaries for any given date.

**DD-04 — Q6 placed last in the setup flow (after Q5 WIP threshold)**
AC-01.1 was explicit: "last question, after all existing prompts." Auto-detection sub-step executes immediately before Q6 — not a separate question.

**DD-05 — Weekend handling: freeze at Friday**
Sprint ceremonies happen on weekdays. A coach preparing on a weekend is viewing Friday's position. No error surface needed.

---

## Steps Completed

### Step 1 — `cb-init`: Q6 + auto-detection
Extended with a detection sub-step that scans `teams/*/config.yaml` one level deep. When exactly one match is found, cb-init pre-suggests it with `[Y/n]`. Multiple matches produce a numbered list. No match falls through to manual entry. Q6 (manual entry path) is the last question in the setup flow. File existence is validated before `team_config.path` is written to `config.json`. Confirmation message emitted on success.

### Step 2 — `cb-snapshot`: Team Context Resolver + Sprint Position Calculator
Team Context Resolver embedded verbatim after the existing config read. Reads `team_config.path`, resolves to absolute path, parses the calendar-magick YAML subset (`team.cadence`, `team.sprint_length_weeks`, `team.members`). Sprint Position Calculator embedded with the fixed epoch 2020-01-06 and ISO week arithmetic. When `cadence: scrum`, snapshot header gains the suffix `| Day D, Week W/N of Sprint (N-week scrum, started YYYY-MM-DD)`. Risk-read in chat gains the same suffix (AC-02.6). Graceful degradation: absent `team_config`, unreadable file, non-scrum cadence — all produce no suffix and no error.

### Step 3 — `cb-log`: Team Context Resolver + member hints
Team Context Resolver embedded verbatim after config read. New Step 1a displays `"Team roster: <name (ROLE), ...> — enter names or press Enter for full team."` before the "Who was in the session?" prompt. Full team selection writes all `team.members` names to a new optional `participants:` frontmatter field. Coach can type any names; roster hint is informational only. Absent or unreadable teams.yaml degrades silently.

---

## Lessons Learned

**L1 — Named sub-patterns are worth the verbatim repetition cost**
Embedding the Team Context Resolver verbatim in three skills is a known three-site maintenance commitment. It was the correct call over a shared reference file (ADR-008 compliance). Future changes to the resolver require three edits, but the skills remain independently deployable.

**L2 — The epoch anchor is the right trade-off for a prose-implemented algorithm**
The Sprint Position Calculator needed to be implementable as SKILL.md arithmetic — no code, no library. The fixed epoch anchor makes it deterministic without requiring the coach to store or recall sprint dates. The known limitation (Monday-start assumption) is logged in ADR-013 and is a coaching-convenience issue, not a correctness failure.

**L3 — DES PYTHONPATH issue is a consistent friction point**
The DES deliver tooling (`des-verify-integrity`, `des-run`) requires a `PYTHONPATH` prefix and has a schema path resolution bug in the pipx context. This caused the execution-log.json to record empty `events: []` even though all steps completed successfully. Mitigation: the roadmap.json validation block (`status: "approved"`) is the source of truth when the execution log is empty due to this bug.

**L4 — Manual conversation testing (Strategy C) is sufficient for SKILL.md prose**
There is no automated test runner for SKILL.md behaviour. All 28 scenarios were verified as manual conversation tests. The Gherkin `.feature` files serve as specification documents and human test scripts, not automated test suites. This is the correct strategy for this project's rigor profile.

---

## Issues Encountered

**DES PYTHONPATH issue (known, pre-existing)**
All DES commands (`des-verify-integrity`, `des-run`) require a `PYTHONPATH=<path>` prefix to resolve module imports in the pipx execution context. Additionally, `des-verify-integrity` has a schema path resolution bug that causes it to fail when invoked from the project root. Both issues were documented as pre-existing in the DES feedback memory file. Steps were executed directly by the orchestrator; the execution-log.json records empty `events: []` as a result. The roadmap.json validation block (`status: "approved", note: "Implementation verified against all 28 acceptance scenarios"`) is the authoritative completion record.

**Empty execution-log.json**
`docs/feature/calendar-magick-integration/deliver/execution-log.json` has `events: []`. This is a known DES instrumentation gap, not an incomplete feature. All evidence of completion is in `feature-delta.md` (Wave DELIVER section: 28/28 scenarios GREEN, all DoD PASS, all quality gates PASS, commit `41f22ec`).

---

## Files Changed

### SKILL.md files

| File | Change |
|------|--------|
| `plugins/coach-buddy/skills/cb-init/SKILL.md` | Q6 prompt + auto-detection sub-step + optional `team_config` block in config.json template + confirmation output |
| `plugins/coach-buddy/skills/cb-snapshot/SKILL.md` | Team Context Resolver sub-pattern + Sprint Position Calculator + conditional sprint-context suffix in header and risk-read |
| `plugins/coach-buddy/skills/cb-log/SKILL.md` | Team Context Resolver sub-pattern + Step 1a member hint + optional `participants:` frontmatter field in entry format |

### Architecture and tests

| File | Change |
|------|--------|
| `docs/product/architecture/adr-013-sprint-position-epoch-anchor.md` | New — sprint epoch anchor decision record |
| `docs/product/architecture/brief.md` | Team Context Resolver pattern added; calendar-magick-integration component table row added |
| `docs/product/jobs.yaml` | `ceremony-aware-engagement` job added |
| `tests/acceptance/calendar-magick-integration/walking-skeleton.feature` | 2 walking-skeleton scenarios (US-01 write path + US-02 read path) |
| `tests/acceptance/calendar-magick-integration/slice-01-teams-yaml-link.feature` | 9 scenarios (US-01 + US-03) |
| `tests/acceptance/calendar-magick-integration/slice-02-sprint-aware-snapshot.feature` | 9 scenarios (US-02) |
| `tests/acceptance/calendar-magick-integration/slice-03-member-hints.feature` | 8 scenarios (US-04) |

### Wave artifacts (preserved)

| File | Purpose |
|------|---------|
| `docs/feature/calendar-magick-integration/feature-delta.md` | Full wave record: DISCUSS, DESIGN, DISTILL, DELIVER sections |
| `docs/feature/calendar-magick-integration/discuss/wave-decisions.md` | D1 through D4 + scope assessment |
| `docs/feature/calendar-magick-integration/slices/slice-01-teams-yaml-link.md` | Slice 01 definition (US-01, US-03) |
| `docs/feature/calendar-magick-integration/slices/slice-02-sprint-aware-snapshot.md` | Slice 02 definition (US-02) |
| `docs/feature/calendar-magick-integration/slices/slice-03-member-hints.md` | Slice 03 definition (US-04) |
| `docs/feature/calendar-magick-integration/deliver/roadmap.json` | DES roadmap (status: approved) |
| `docs/feature/calendar-magick-integration/deliver/execution-log.json` | DES execution log (events: [] — DES PYTHONPATH issue; see Issues Encountered) |

---

## File Migration

No standard design/ or distill/ subdirectory artifacts to migrate — all design and test documentation is embedded in feature-delta.md. ADR-013 was written directly to the SSOT (`docs/product/architecture/`) during the DELIVER wave.

---

## Watch Items / Open Threads

1. **OQ-02 — Sprint epoch assumes Monday-start sprints** (ADR-013 Known Limitation): Teams starting sprints on other days will see a position offset of 1–4 days. If coaches report misalignment, a future `team_config.sprint_anchor_date` override can be added without changing the core algorithm.

2. **OQ-04 — `participants:` field resolution**: The DISCUSS wave Open Question OQ-04 (whether `participants` is an existing COACHING_LOG.md field) was resolved in DISTILL — it is a new optional frontmatter field, analogous to the existing optional `mode:` field. No open items remain.

3. **Link adoption rate is unmeasured**: The KPI (≥60% link adoption in repos with `teams/`) requires inspecting config.json files across CoWork projects. No automated collection exists. Manual review is the measurement method.

4. **Multi-team file handling (OQ-01)**: If a teams.yaml contains multiple `team:` blocks, the Team Context Resolver reads only the first. This is logged as a known limitation. calendar-magick's standard layout (`teams/<name>/config.yaml`) places one team per file, making this edge case rare.

---

## Test Results

28/28 acceptance scenarios GREEN (manual conversation testing, WS Strategy C). No automated runner — SKILL.md prose tests are verified by manual execution against a real CoWork project directory.

| Feature file | Scenarios | Stories |
|---|---|---|
| `walking-skeleton.feature` | 2 | US-01, US-02 |
| `slice-01-teams-yaml-link.feature` | 9 | US-01, US-03 |
| `slice-02-sprint-aware-snapshot.feature` | 9 | US-02 |
| `slice-03-member-hints.feature` | 8 | US-04 |

Unit test suite: 69/69 passing (no regressions — SKILL.md-only changes do not affect compiled unit tests).

---

## Permanent Artifacts

| Artifact | Location |
|----------|----------|
| ADR-013 (sprint epoch anchor) | `docs/product/architecture/adr-013-sprint-position-epoch-anchor.md` |
| Acceptance tests | `tests/acceptance/calendar-magick-integration/` |
| Wave history | `docs/feature/calendar-magick-integration/` |
