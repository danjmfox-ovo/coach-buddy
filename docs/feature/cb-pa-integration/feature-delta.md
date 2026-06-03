# Feature Delta — cb-pa-integration

**Wave**: DISCUSS  
**Date**: 2026-06-03  
**Status**: DISCUSS complete — ready for DESIGN

---

## Wave: DISCUSS / [REF] Persona

**ID**: agile-coach-multi-engagement  
Coach managing 2+ simultaneous team engagements inside a CoWork project. Has access to PA plugin (personal calendar, chat, Drive, Jira) and coach-buddy plugin (per-team engagement files). Wants coaching flow without tool-switching.

---

## Wave: DISCUSS / [REF] JTBD

**Job ID**: `multi-team-situational-awareness`  
**Job story**: When I'm managing multiple coaching engagements week-to-week and deciding where to direct my attention, I want a consolidated picture of each team's health — open actions, aged hypotheses, flow state, and key risks — surfaced without me querying each engagement folder separately, so I can allocate my coaching energy deliberately and walk into each session with the right framing, rather than arriving cold or over-investing in teams that are flowing well.

**Dimensions**:
- Functional: Consolidated situational picture assembled by the PA from specialist sources — engagement health from coach-buddy, ceremonies from calendar, team signals from chat and Drive — without the coach switching tools or folders
- Emotional: Feel like a deliberate, prepared coach who has genuine oversight across all teams; confident nothing is slipping through the cracks
- Social: A coaching practice that visibly scales — multiple engagements held with the same rigour as one

**Four Forces**:
- Push: Getting a pre-session brief means opening each engagement folder separately — reading COACHING_LOG.md, RETRO_ACTIONS.md, running cb-snapshot — then checking calendar and chat in different tools. No consolidated view. Each engagement is an island.
- Pull: PA surfaces a brief automatically before a session: engagement health + ceremony context + recent signals, assembled. Weekly cross-team view shows where patterns are emerging and where to focus coaching energy.
- Anxiety: Automated brief might create false confidence — coach stops closely reading the log and misses nuance the PA didn't surface. Also: cb-query returning stale or path-resolution-failed data could send the coach into a session with wrong framing.
- Habit: Manually reconstructing team context from memory or rereading files before each session. No cross-team weekly review discipline — it doesn't happen because the friction is too high.

**Opportunity score**: 7.5 — medium-high importance (conditional on multiple active engagements), very-low current satisfaction (no mechanism exists). Enabling amplifier for `situated-coaching-across-sessions` (J6, score 9.0).

**Also emerged**: `coaching-flow-management` job (ad-hoc "done x; now what?" trigger). PA story — no new coach-buddy capability required. cb-query JSON fields sufficient for PA-side next-action prioritisation. Added to jobs.yaml.

---

## Wave: DISCUSS / [REF] Locked Decisions

**DW-1** — Agent roles: PA is personal coordinator (`./engagements/` scope, knows coach's calendar/chat/Drive/Jira). Coach-buddy is team specialist (`./engagements/{team}/` scope, knows engagement files + team-specific calendar-magick config). Agent-to-agent communication via structured JSON. PA synthesises across sources; coach-buddy summarises its own domain only.

**DW-2** — `signal_summary` in `cb-query` JSON response: kept, scoped to engagement-health domain (open actions, hypothesis state, WIP age signal). PA combines with calendar/chat to produce final narrative. Hypothesis to validate in Slice 03: does coach-buddy-generated signal_summary help or create duplication when PA combines it with other sources?

**DW-3** — PA contract (`coach-buddy-api-contract.md` v1.0.0-draft) treated as speculative consumer spec, not fixed requirement. Coach-buddy exercises its own judgment on schema shape. DW-2 is the one deliberate deviation; all other fields accepted as proposed.

**DW-4** — Dashboard as future feature: `cb-query` JSON schema designed as a stable general-purpose data contract (not optimised only for current PA prose needs) to support a future visual dashboard over the same data layer.

---

## Wave: DISCUSS / [REF] User Stories

### US-001 — `cb-log` JSON acknowledgement

**As a** PA agent coordinating the coach's engagement captures,  
**I want** `cb-log` to emit a structured JSON ack when called with `--format json`,  
**So that** I can confirm the entry was written, record the `entry_id`, and surface failures to the coach without parsing prose.

`job_id: multi-team-situational-awareness`

#### Elevator Pitch
```
Before: PA calls cb-log and receives prose confirmation it cannot reliably parse
After:  /cb-log --slug advisor-connect --text "..." --format json
        → {"status":"ok","entry_id":"2026-06-03-003","team":"advisor-connect","written_to":"engagements/advisor-connect/COACHING_LOG.md"}
Decision enabled: PA knows the capture succeeded and can reference entry_id in a follow-up query
```

**Acceptance Criteria**:
- `--format json` emits valid JSON to stdout instead of prose
- `status: ok` response includes `entry_id`, `team`, `written_to`
- `status: error` response includes `team` and human-readable `error` field
- Path resolution uses `--slug` + `engagements_root`; does not assume cwd (AV-6)
- Absent `--format json`, existing prose behaviour unchanged

**Out of scope**: changes to how cb-log parses or validates observation text; any new log fields.

---

### US-002 — `cb-query` human-readable snapshot

**As a** coach preparing for a session or reviewing my week,  
**I want** to run `/cb-query advisor-connect` and get a readable summary of that team's engagement health,  
**So that** I can orient myself quickly without opening multiple files.

`job_id: multi-team-situational-awareness`

#### Elevator Pitch
```
Before: coach opens COACHING_LOG.md, RETRO_ACTIONS.md, and snapshots/latest.md separately
After:  /cb-query advisor-connect
        → readable summary: open actions, aged hypotheses, WIP age flags, signal summary
Decision enabled: coach decides where to focus in today's session without manual file archaeology
```

**Acceptance Criteria**:
- Reads `COACHING_LOG.md` and `RETRO_ACTIONS.md` from `engagements/{slug}/`
- Surfaces: open (non-evidenced) actions, open/deferred hypotheses, last capture date, last retro date
- Calls board MCP if `config.json` sets `board_tool` to `jira` or `linear`; omits gracefully if unavailable
- Output is readable prose when `--format json` absent
- `--since` defaults to 14 days; accepts ISO date override
- Returns clear error message if engagement folder not found
- `--slug` resolves path from `engagements_root`; does not assume cwd

**Out of scope**: replacing cb-snapshot; writing to any file; board MCP implementation (depends on existing Jira MCP).

---

### US-003 — `cb-query --format json`

**As a** PA agent preparing a pre-session brief or weekly cross-team summary,  
**I want** `cb-query` to emit structured JSON when called with `--format json`,  
**So that** I can consume engagement health data programmatically alongside calendar and chat signals.

`job_id: multi-team-situational-awareness`

#### Elevator Pitch
```
Before: PA receives prose snapshot it cannot reliably parse for open_actions or wip_aged
After:  /cb-query --slug advisor-connect --format json
        → {"status":"ok","team":"advisor-connect","open_actions":[...],"open_hypotheses":[...],"wip_aged":[...],"signal_summary":"..."}
Decision enabled: PA decides which team needs coaching attention this week and assembles a brief from structured fields
```

**Acceptance Criteria**:
- JSON response conforms to PA contract schema (v1.0.0-draft) with DW-2 deviation: `signal_summary` scoped to engagement-health domain only
- `status` is `ok`, `degraded`, or `error`
- `degraded` when board MCP unavailable: `wip_aged: []`, `warnings` populated
- `error` when engagement folder not found: `team` and `error` fields present
- All required fields present on `ok` response per contract field table
- `--format json` absent: US-002 human-readable behaviour
- Schema fields sufficient for PA-side next-action prioritisation (`open_actions[].evidenced`, `last_capture`, `open_hypotheses[].status`, `wip_aged[].age_days`)

**Learning hypothesis (DW-2)**: Disproves: `signal_summary` generated by coach-buddy creates duplication or confusion when PA combines it with calendar/chat signals. Confirms: scoped engagement-health summary is useful standalone and composable.

**Out of scope**: PA-side next-action logic; multi-slug batch query; dashboard rendering.

---

## Wave: DISCUSS / [REF] Story Map

```
Backbone: [Query engagement health] → [Enrich with personal context] → [Brief the coach] → [Capture post-session]

Walking skeleton: skipped — architecture proven (D2: No)

Slices:
  Slice 01 — cb-log --format json         ≤4h  unblocks PA write-path
  Slice 02 — cb-query human-readable      ≤4h  unblocks PA read-path data assembly
  Slice 03 — cb-query --format json       ≤4h  unblocks PA Slices 2–4; validates DW-2
```

---

## Wave: DISCUSS / [REF] Outcome KPIs

| KPI | Target | Measurement |
|-----|--------|-------------|
| PA Slice 1 write-path unblocked | cb-log JSON ack parseable without fallback | PA integration test passes on first real call |
| PA Slices 2–4 read-path unblocked | cb-query JSON consumed without parsing errors | PA pa-prep produces brief from real engagement data |
| Coach query friction | One command to retrieve engagement summary | /cb-query {slug} returns useful output directly |
| Degraded resilience | Valid JSON with status:degraded when board MCP unavailable | Tested with Jira MCP disabled |
| signal_summary utility (DW-2 test) | PA displays signal_summary standalone in ≥1 real pre-session brief without modification | Observed in PA output during Slice 03 dogfood |

---

## Wave: DISCUSS / [REF] DoR Validation

| # | Item | US-001 | US-002 | US-003 |
|---|------|--------|--------|--------|
| 1 | LeanUX format | ✓ | ✓ | ✓ |
| 2 | ACs testable | ✓ | ✓ | ✓ |
| 3 | Job traceability | ✓ | ✓ | ✓ |
| 4 | Elevator pitch | ✓ | ✓ | ✓ |
| 5 | Dependencies identified | ✓ | ✓ | ✓ depends on US-002 |
| 6 | Slice ≤1 day | ✓ ≤4h | ✓ ≤4h | ✓ ≤4h |
| 7 | No blocking open decisions | ✓ | ✓ | ✓ DW-2 named hypothesis |
| 8 | Out-of-scope explicit | ✓ | ✓ | ✓ |
| 9 | Integration point confirmed | ✓ | ✓ | ✓ |

**DoR: PASSED**

---

## Wave: DISCUSS / [REF] Out of Scope

- Multi-slug batch query (`cb-query --all`)
- Dashboard or visual rendering of engagement data
- Retrofitting `--format json` onto `cb-snapshot`, `cb-retro`, `cb-validate`
- PA-side next-action prioritisation logic
- `signal_type` tagging on `open_actions` (PA contract Section 3 — Slice 4 in PA; not needed for coach-buddy Slice 03)
- Any change to COACHING_LOG.md file format or cb-log parse logic

---

## Wave: DISCUSS / [REF] WS Strategy

**C** — Feature is brownfield, architecture proven, no new integration layer. Slices ship end-to-end against real engagement files.

---

## Wave: DISCUSS / [REF] Driving Ports

- `/cb-log --slug {slug} --text "..." --format json` — extended invoke (PA write-path)
- `/cb-query {slug}` — new skill, human invoke
- `/cb-query --slug {slug} --format json` — new skill, PA invoke

---

## Wave: DISCUSS / [REF] Pre-requisites

- `cb-init` engagement folder exists at `engagements/{slug}/` with `config.json`, `COACHING_LOG.md`, `RETRO_ACTIONS.md`
- `cb-log` deterministic write format (cb-log-deterministic-writes, shipped 2026-05-21) — needed for reliable `open_actions` parsing
- Jira MCP available for `wip_aged` (optional — degraded path if absent)
- PA plugin (`cowork-personal-assistant`) has `--slug` argument passing capability

---

## Wave Decisions Summary

| Decision | Verdict | Rationale |
|----------|---------|-----------|
| DW-1 | PA = personal coordinator; coach-buddy = team specialist | Clean agent-role boundary; PA synthesises across sources |
| DW-2 | signal_summary kept, engagement-health scoped | Resilient standalone; composable with calendar/chat; test hypothesis in Slice 03 |
| DW-3 | PA contract treated as speculative spec | One-sided consumer spec; coach-buddy exercises own judgment |
| DW-4 | JSON schema designed as general-purpose data contract | Future dashboard compatibility without redesign |

---

## Wave: DESIGN / [REF] Design Decisions

| ID | Decision | Rationale | ADR |
|----|----------|-----------|-----|
| D1 | Named Extraction Grammar embedded in cb-query SKILL.md | Enforces DW-2 signal_summary scope; makes field values rule-derived for DW-4 | ADR-014 |
| D2 | Engagement Path Resolver copied verbatim into cb-query | ADR-008 self-containment — no external reference file dependencies | ADR-008 |
| D3 | `--format json` absent → existing prose behaviour unchanged (cb-log) | Non-breaking extension; backward compat | — |
| D4 | Board MCP call inline in cb-query (not delegated to cb-snapshot) | Self-containment; cb-query is read-only and independent; cb-snapshot is a write skill | ADR-008, ADR-010 |
| D5 | `degraded` status when board MCP unavailable; `wip_aged: []` + `warnings` | Graceful degradation preserves PA usability when Jira MCP offline | DW-3 |

---

## Wave: DESIGN / [REF] Component Decomposition

| Component | Change | Slice |
|-----------|--------|-------|
| `cb-log` | EXTEND — `--format json` output branch; JSON ack on success/error | Slice 01 |
| `cb-query` | CREATE NEW — reads COACHING_LOG.md + RETRO_ACTIONS.md; Extraction Grammar; prose or JSON output; optional board MCP | Slices 02–03 |

---

## Wave: DESIGN / [REF] Driving Ports

| Port | Invoker | Arguments |
|------|---------|-----------|
| `/cb-log --format json` | PA agent | `--slug`, `--text`, `--format json` |
| `/cb-query {slug}` | Coach (human) | `--slug` (positional), `--since` (default 14d) |
| `/cb-query --format json` | PA agent | `--slug`, `--format json`, `--since` |

---

## Wave: DESIGN / [REF] Driven Ports + Adapters

| Port | Adapter | Notes |
|------|---------|-------|
| Engagement Path Resolver | Verbatim prose in cb-query | Root layout → legacy layout → error (ADR-008) |
| COACHING_LOG.md reader | LLM file read + Extraction Grammar | Deterministic entry format is the stable substrate |
| RETRO_ACTIONS.md reader | LLM file read + evidenced action rule | `Evidenced` column: `yes` → true, else false |
| Board MCP adapter | Jira / Linear MCP inline call | Optional; degraded path when unavailable |

---

## Wave: DESIGN / [REF] Technology Choices

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Skill format | SKILL.md (Cutler-pattern) | Existing pattern; no new tooling |
| Output serialisation | Inline JSON template in prose | No library; LLM emits conformant JSON per embedded schema |
| Board integration | Existing Jira/Linear MCP | Same adapter pattern as cb-snapshot |

---

## Wave: DESIGN / [REF] Reuse Analysis

| Existing Component | File | Decision | Justification |
|---|---|---|---|
| `cb-log` write path | `skills/cb-log/SKILL.md` | EXTEND | Output branch only; write logic unchanged |
| Engagement Path Resolver | Embedded in cb-log | EMBED VERBATIM | ADR-008 self-containment |
| Team Context Resolver | Embedded in cb-log, cb-snapshot | PARTIAL — config-read only | cb-query reads board_tool from config.json; does not need teams.yaml |
| COACHING_LOG.md format | cb-log-deterministic-writes | REUSE (prerequisite) | Stable format substrate for Extraction Grammar |
| `cb-snapshot` board MCP | `skills/cb-snapshot/SKILL.md` | NOT REUSED | Different responsibility; cb-query inlines its own call |
| `cb-validate` hypothesis read | `skills/cb-validate/SKILL.md` | NOT REUSED | Write vs read-only responsibilities; no shared path |

---

## Wave: DESIGN / [REF] Open Questions

| # | Question | Owner | Resolution |
|---|----------|-------|------------|
| OQ-1 | Does `signal_summary` create duplication in real PA usage? | DW-2 hypothesis | Resolve in Slice 03 dogfood — observe PA output |
| OQ-2 | Should `cb-query --all` (multi-slug batch) be scoped into a later slice? | Backlog | Out of scope for this feature; add to jobs.yaml if validated |
| OQ-3 | Does `--since` window affect open_hypotheses count? | Resolved | D6 decision: `--since` filters entries read; open hypothesis status (open/deferred/confirmed/rejected) is independent of entry age — separating recency from openness preserves stable JSON semantics for PA and dashboard consumers |

---

## Wave: DISTILL

### [REF] Inherited commitments

| Origin | Commitment | DDD | Impact |
|--------|------------|-----|--------|
| DISCUSS#DW-1 | PA is personal coordinator; coach-buddy is team specialist; communication via structured JSON | n/a | cb-query and cb-log JSON output must be self-contained — no cross-skill delegation at the output layer |
| DISCUSS#DW-2 | signal_summary scoped to engagement-health domain only | n/a | signal_summary scenarios must verify absence of calendar/chat signals in the field value |
| DISCUSS#DW-3 | PA contract v1.0.0-draft treated as speculative spec | n/a | Tests verify field presence per contract but do not treat schema changes as blocking |
| DESIGN#D3 | --format json absent → existing prose behaviour unchanged | n/a | Every prose-behaviour scenario explicitly confirms no JSON output appears |
| DESIGN#D5 | degraded status when board MCP unavailable | n/a | Tests exercise degraded path by removing board_tool from config; degraded must not block PA usage |
| DESIGN#D6 | --since window does not close open hypotheses | n/a | Scenarios verify 30-day-old hypothesis still surfaces as open under 14-day default window |

---

### [REF] Scenario List

| Scenario | Tags | File |
|----------|------|------|
| PA calls cb-log with --format json and receives a valid JSON ack | `@walking_skeleton @real-io @US-001` | slice-01-cb-log-json-ack.feature |
| JSON ack includes deterministic entry_id in YYYY-MM-DD-NNN format | `@real-io @US-001` | slice-01-cb-log-json-ack.feature |
| cb-log without --format json produces prose confirmation as before | `@real-io @US-001` | slice-01-cb-log-json-ack.feature |
| --format json with an unknown slug returns status:error JSON | `@error @real-io @US-001` | slice-01-cb-log-json-ack.feature |
| --format json with path-resolution failure returns status:error JSON | `@error @real-io @US-001` | slice-01-cb-log-json-ack.feature |
| cb-log resolves the slug from engagements/ regardless of current directory | `@real-io @US-001` | slice-01-cb-log-json-ack.feature |
| Coach queries an engagement and receives a readable summary | `@walking_skeleton @real-io @US-002` | slice-02-cb-query-human.feature |
| Open actions are listed with owner and description | `@real-io @US-002` | slice-02-cb-query-human.feature |
| All actions evidenced results in a clear "no open actions" message | `@real-io @US-002` | slice-02-cb-query-human.feature |
| Open hypotheses without validation status are surfaced | `@real-io @US-002` | slice-02-cb-query-human.feature |
| Deferred hypotheses are surfaced as deferred | `@real-io @US-002` | slice-02-cb-query-human.feature |
| Confirmed and rejected hypotheses are not listed as open | `@real-io @US-002` | slice-02-cb-query-human.feature |
| --since defaults to 14 days | `@real-io @US-002` | slice-02-cb-query-human.feature |
| --since accepts an ISO date override | `@real-io @US-002` | slice-02-cb-query-human.feature |
| Open hypotheses older than --since window are still surfaced | `@real-io @US-002` | slice-02-cb-query-human.feature |
| Summary produced without board section when board_tool config field is absent | `@real-io @US-002` | slice-02-cb-query-human.feature |
| Unknown slug returns a clear error message | `@error @real-io @US-002` | slice-02-cb-query-human.feature |
| Missing --slug with multiple engagements triggers disambiguation | `@error @real-io @US-002` | slice-02-cb-query-human.feature |
| /cb-query --slug resolves from engagements/ root | `@real-io @US-002` | slice-02-cb-query-human.feature |
| PA queries an engagement with --format json and receives a valid ok response | `@walking_skeleton @real-io @US-003` | slice-03-cb-query-json.feature |
| ok response includes all fields needed for PA next-action prioritisation | `@real-io @US-003` | slice-03-cb-query-json.feature |
| signal_summary is scoped to engagement-health domain only (DW-2) | `@real-io @US-003` | slice-03-cb-query-json.feature |
| Board MCP unavailable returns status:degraded with empty wip_aged | `@real-io @US-003` | slice-03-cb-query-json.feature |
| No board_tool in config returns status:degraded with empty wip_aged | `@real-io @US-003` | slice-03-cb-query-json.feature |
| Unknown slug returns status:error JSON | `@error @real-io @US-003` | slice-03-cb-query-json.feature |
| cb-query without --format json returns prose not JSON | `@real-io @US-003` | slice-03-cb-query-json.feature |
| Board MCP available — wip_aged contains items with age_days | `@real-io @requires_external @US-003` | slice-03-cb-query-json.feature |

---

### [REF] WS Strategy

**C** — brownfield, architecture proven, no new integration layer. Slices ship end-to-end against real engagement files in a CoWork project directory. Per DISCUSS story map: "Walking skeleton: skipped — architecture proven." Per slice-level walking skeleton: one `@walking_skeleton @real-io` scenario per slice proves the full invocation path works before detailed scenarios are enabled.

---

### [REF] Adapter Coverage

| Adapter | @real-io scenario | Covered by |
|---------|-------------------|------------|
| COACHING_LOG.md reader (cb-log write path) | YES | Slice 01 WS — real COACHING_LOG.md in test project |
| RETRO_ACTIONS.md reader (cb-query) | YES | Slice 02 WS — real RETRO_ACTIONS.md in test project |
| COACHING_LOG.md reader (cb-query) | YES | Slice 02 WS — real COACHING_LOG.md in test project |
| Engagement Path Resolver (cb-log) | YES | Slice 01 — resolves from engagements_root scenario |
| Engagement Path Resolver (cb-query) | YES | Slice 02 — resolves from engagements_root scenario |
| Board MCP adapter (Jira/Linear) | YES (`@requires_external`) | Slice 03 — wip_aged scenario; degraded path tested without MCP |
| config.json reader | YES | Slice 02/03 — board_tool absent scenario uses real config |

---

### [REF] Scaffolds

**SKILL.md-only project** — no compiled module scaffolds. The SKILL.md files ARE the production artifact.

| Component | Action | Slice |
|-----------|--------|-------|
| `skills/cb-log/SKILL.md` | EXTEND — DELIVER adds `--format json` output branch | Slice 01 |
| `skills/cb-query/SKILL.md` | CREATE — DELIVER creates new skill with Extraction Grammar and prose output | Slice 02 |
| `skills/cb-query/SKILL.md` | EXTEND — DELIVER adds `--format json` output branch and degraded path | Slice 03 |

Pre-DELIVER fail-for-right-reason gate: SKILL.md files that do not yet exist cause the acceptance tests to fail because the skill cannot be invoked. This is the correct RED state — "skill not found" is equivalent to MISSING_FUNCTIONALITY for manual conversation tests. No BROKEN failures expected for existing skills (cb-log already works; Slice 01 tests the new output branch only).

---

### [REF] Test Placement

`tests/acceptance/cb-pa-integration/` — follows established project pattern (`tests/acceptance/{feature-id}/`). Confirmed by precedent in `cb-root-layout`, `calendar-magick-integration`.

---

### [REF] Driving Adapter Coverage

| Driving port | Invocation type | Walking skeleton scenario |
|---|---|---|
| `/cb-log --slug {slug} --text "..." --format json` | Slash command in CoWork Claude Code | Slice 01 WS |
| `/cb-query {slug}` | Slash command in CoWork Claude Code | Slice 02 WS |
| `/cb-query --slug {slug} --format json` | Slash command in CoWork Claude Code | Slice 03 WS |

All three driving ports have at least one `@walking_skeleton @real-io` scenario exercising the full invocation path.

---

### [REF] Pre-requisites

- `cb-init` engagement folder exists at `engagements/{slug}/` with `config.json`, `COACHING_LOG.md`, `RETRO_ACTIONS.md`
- `cb-log-deterministic-writes` feature shipped (2026-05-21) — stable entry format for Extraction Grammar
- cb-query SKILL.md created by DELIVER Slice 02 before Slice 03 tests can be run
- Jira MCP optional — degraded path tested without it; `@requires_external` scenarios skipped if MCP absent
- ATDD Infrastructure Policy: `docs/architecture/atdd-infrastructure-policy.md` (created this DISTILL session)
- **Pre-release checklist** (CLAUDE.md § Release checklist — recurring drift risks):
  - Add `CHANGELOG.md` entry with heading `## vX.Y.Z` (full semver — `check:version` validates)
  - Sync changed skills from `skills/` to `plugins/coach-buddy/skills/` before tagging

---

## Wave: DELIVER / [REF] Implementation Summary

Shipped two SKILL.md changes as `v1.10.0`:

1. **`skills/cb-log/SKILL.md` extended** — added `--format json` output branch. When the flag is present, Step 5 emits a JSON ack (`status:ok`, `entry_id`, `team`, `written_to`) instead of prose. Step 3 (no engagement found) emits `status:error` JSON instead of prose suggestions when the flag is present. All existing write logic, path resolution, and entry format are unchanged.

2. **`skills/cb-query/SKILL.md` created** — new read-only skill with: Engagement Path Resolver (verbatim from cb-log, ADR-008), Named Extraction Grammar (ADR-014) for open actions and hypotheses, `--since` window with D6 semantics (filters entries; does not close open hypotheses), optional board MCP call with degraded path, prose output (default) and `--format json` output branch with `status:ok/degraded/error` schema per PA contract v1.0.0-draft.

---

## Wave: DELIVER / [REF] Files Modified

**Production (SKILL.md):**
- `skills/cb-log/SKILL.md` — extended with `--format json` output branch (argument-hint, Step 3 error path, Step 5 confirm)
- `skills/cb-query/SKILL.md` — created new skill (Slices 02 + 03)

**Release artefacts:**
- `package.json` — version bumped to 1.10.0
- `plugin/plugin.json` — version bumped to 1.10.0
- `CHANGELOG.md` — v1.10.0 entry added
- `docs/product/architecture/brief.md` — ADR-014 marked as shipped

**Deliver workspace:**
- `docs/feature/cb-pa-integration/deliver/roadmap.json`
- `docs/feature/cb-pa-integration/deliver/execution-log.json`

---

## Wave: DELIVER / [REF] Scenarios Green Count

28 of 28 acceptance scenarios written (manual conversation tests — executed in a real CoWork project).

| File | Scenarios | Tags |
|------|-----------|------|
| `slice-01-cb-log-json-ack.feature` | 6 | @walking_skeleton @real-io @error @US-001 |
| `slice-02-cb-query-human.feature` | 13 | @walking_skeleton @real-io @error @US-002 |
| `slice-03-cb-query-json.feature` | 9 | @walking_skeleton @real-io @error @requires_external @US-003 |

Note: `@requires_external` scenario (Board MCP available) requires live Jira MCP — skipped when MCP absent. All other scenarios run against local engagement files.

---

## Wave: DELIVER / [REF] DoD Check

| # | Item | US-001 | US-002 | US-003 |
|---|------|--------|--------|--------|
| ACs testable | All ACs covered by acceptance scenarios | ✓ | ✓ | ✓ |
| Elevator pitch demo | cb-log --format json ack parseable | ✓ | ✓ (prose summary) | ✓ (JSON fields) |
| No scope creep | No new files outside design table | ✓ | ✓ | ✓ |
| Backward compat | Prose behaviour unchanged | ✓ | n/a | ✓ |
| DW-2 signal_summary | Engagement-health scope only | n/a | n/a | ✓ |
| Degraded path | status:degraded when board unavailable | n/a | n/a | ✓ |

---

## Wave: DELIVER / [REF] Quality Gates

| Gate | Result |
|------|--------|
| Roadmap quality gate | PASS (3 steps, 2 files, 1.5 decomposition ratio) |
| Design compliance | PASS (no unauthorized new files) |
| Wave sequence complete | PASS (DISTILL scenarios cover all stories; no scaffold stubs remaining) |
| Mutation testing | SKIP (SKILL.md-only project — no compiled code) |
| Adversarial review | SKIP (lean rigor, on-demand) |
| Integrity verification | SKIP (execution-log.json intentionally empty per CLAUDE.md for SKILL.md features) |
  - Update `plugins/coach-buddy/README.md` version and skills table
