# Feature Delta — calendar-magick-integration
<!-- Wave: DISCUSS | Date: 2026-05-19 | Density: lean+ask-intelligent -->

---

## Wave: DISCUSS / [REF] Persona ID

**Persona**: `agile-coach` — Practitioner running ongoing team engagements who also uses
calendar-magick to manage ceremony schedules. Uses both tools from the same CoWork project
directory. Primary friction: team topology data (members, roles, sprint cadence) lives in
two separate files with no bridge between them.

---

## Wave: DISCUSS / [REF] JTBD One-Liner

**Primary job**: `ceremony-aware-engagement` — *When I coach a team that also uses
calendar-magick, I want my coaching tools to read team structure and sprint cadence from
the teams.yaml I already maintain, so I don't have to duplicate and sync the same data
in two places.*

**Enabling jobs (from SSOT)**: `engagement-scaffolding` (J9), `board-snapshot-without-context-switch` (J8), `situated-coaching-across-sessions` (J6).

---

## Wave: DISCUSS / [REF] Locked Decisions

### D1 — Integration boundary: coexistence with typed reference (not replacement)

**Verdict**: `config.json` retains all coaching-specific metadata (pm_tool, wip_threshold,
engagement slug). `teams.yaml` carries team topology (members, roles, cadence,
sprint_length_weeks, timezone). coach-buddy reads `teams.yaml` **only when**
`team_config.path` is explicitly set in `config.json`. Neither file is eliminated.

**Rationale**: Replacing config.json with teams.yaml forces calendar-magick's schema
(calendar_id, events, attendees) onto coaches who don't need it. Coexistence keeps both
tools independently usable. The typed reference makes the link explicit and opt-in —
existing engagements require zero migration.

**Rejected alternative**: config.json fields expanded with calendar-magick data inline —
rejected because it makes coach-buddy's config file aware of a separate tool's domain,
inverting the separation of concerns.

### D2 — coach-buddy is read-only on teams.yaml

**Verdict**: coach-buddy skills read `teams.yaml`; they never write it. calendar-magick
owns the write path. No shared write lock, no conflict.

### D3 — detection strategy: explicit reference, not filesystem scanning

**Verdict**: coach-buddy reads `team_config.path` from `config.json`. It does not scan
the filesystem for `teams/` directories at runtime (except during `cb-init` setup, where
detection is a convenience hint, not a coupling). Explicit is better than implicit.

### D4 — `team_config.path` is relative to the engagement root

**Verdict**: path is resolved relative to the directory containing `config.json`.
This keeps the reference portable when the CoWork project is moved. Example:
`"path": "../../calendar-magick/teams/phoenix/config.yaml"` or, in a co-located
CoWork project, `"path": "teams/phoenix/config.yaml"`.

---

## Wave: DISCUSS / [REF] User Stories

---

### US-01 — Link a teams.yaml during engagement setup

**As** an Agile coach who uses calendar-magick,  
**when** I run `/cb-init` to scaffold a new coaching engagement,  
**I want** to optionally declare a path to my existing `teams.yaml`,  
**so that** both tools read from the same team topology without a second data-entry step.

`job_id`: ceremony-aware-engagement, engagement-scaffolding

#### Elevator Pitch
Before: config.json and teams.yaml are entirely separate; member/role data entered twice.  
After: run `/cb-init` → answer optional prompt "Path to teams.yaml (or leave blank to skip)" → `config.json` gains `"team_config": { "path": "teams/phoenix/config.yaml" }`.  
Decision enabled: I know that updating teams.yaml for calendar-magick is sufficient — no second file to keep in sync.

#### Acceptance Criteria
- AC-01.1: cb-init presents an optional prompt: *"Link a calendar-magick teams.yaml? Enter a path relative to this directory, or press Enter to skip."* The prompt is the last question in the setup flow, after all existing prompts.
- AC-01.2: If a path is entered, cb-init validates the file exists before writing config.json. If the file does not exist, cb-init surfaces: *"File not found at `<path>`. You can add this later by editing config.json."* and writes config.json without the `team_config` field.
- AC-01.3: If a path is entered and the file exists, config.json is written with `"team_config": { "path": "<entered-path>" }` nested under the top-level config object.
- AC-01.4: If Enter is pressed (skip), config.json is written without a `team_config` field. Existing engagements without `team_config` continue to work identically.
- AC-01.5: cb-init prints a confirmation line when `team_config` is written: *"Linked teams.yaml: `<resolved-path>`."*

---

### US-02 — Sprint-aware snapshot header

**As** an Agile coach preparing for a coaching conversation,  
**when** I run `/cb-snapshot` and a linked `teams.yaml` declares `cadence: scrum`,  
**I want** the snapshot header to show the current sprint day and week,  
**so that** I can reason from where the team is in their sprint cadence rather than just a calendar date.

`job_id`: ceremony-aware-engagement, board-snapshot-without-context-switch

#### Elevator Pitch
Before: snapshot header shows `2026-05-19 — Advisor Connect` with no sprint context.  
After: run `/cb-snapshot` → snapshot header reads `2026-05-19 — Advisor Connect | Day 2, Week 1/2 of Sprint (2-week scrum, started 2026-05-18)`.  
Decision enabled: I know whether I'm heading into a mid-sprint check-in or approaching retro/planning, which changes what coaching questions are most useful.

#### Acceptance Criteria
- AC-02.1: When `config.json` contains a valid `team_config.path` pointing to a teams.yaml that includes `cadence: scrum` and `sprint_length_weeks: N`, cb-snapshot reads those fields.
- AC-02.2: cb-snapshot infers the current sprint position using the sprint start date. Sprint start date is calculated from: the most recent sprint-aligned Monday on or before today, using `sprint_length_weeks` to determine the cycle length. (No sprint start date is stored — it is derived from the cycle.)
- AC-02.3: The snapshot file header line gains a sprint-context suffix in the format: `| Day D, Week W/N of Sprint (N-week scrum, started YYYY-MM-DD)` where D = day-of-sprint (1-based, weekdays only), W = current week within sprint, N = sprint_length_weeks.
- AC-02.4: When `teams.yaml` has `cadence: kanban` or the `cadence` field is absent, no sprint context is appended. The snapshot header is unchanged from current behaviour.
- AC-02.5: When `team_config.path` is absent or the file cannot be read, cb-snapshot proceeds normally with no sprint context and no error. (Graceful degradation — calendar-magick is optional.)
- AC-02.6: The sprint-context suffix is also included in the two-sentence risk-read printed in chat.

---

### US-03 — cb-init detects and suggests an existing teams.yaml

**As** an Agile coach running `/cb-init` in a directory that already contains a
`teams/` folder (calendar-magick's standard layout),  
**I want** cb-init to detect the available team configs and pre-suggest one,  
**so that** I don't have to type the path manually when it's already on disk.

`job_id`: ceremony-aware-engagement, engagement-scaffolding

#### Elevator Pitch
Before: even with `teams/phoenix/config.yaml` on disk, cb-init asks "Path to teams.yaml?" and I type it manually.  
After: run `/cb-init` in a project with `teams/` → cb-init auto-detects: *"Found teams/phoenix/config.yaml — link this? [Y/n]"* → confirm → path written automatically.  
Decision enabled: I know the link was set from the real file on disk, not a typed path that might contain a typo.

#### Acceptance Criteria
- AC-03.1: During setup, before presenting the teams.yaml link prompt, cb-init checks for `teams/*/config.yaml` at the current directory. Detection depth: one level (`teams/<name>/config.yaml` only — no recursive scan).
- AC-03.2: If exactly one match is found, cb-init presents: *"Found `teams/<name>/config.yaml`. Link this as your teams.yaml? [Y/n]"*. Y (or Enter) writes the path; n falls through to the manual entry prompt.
- AC-03.3: If more than one match is found, cb-init presents a numbered list and asks the coach to choose, or enter a custom path, or skip.
- AC-03.4: If no match is found, cb-init falls through to the manual entry prompt unchanged (behaviour identical to US-01).
- AC-03.5: Detection is best-effort: if the `teams/` directory cannot be read (permissions, absent), cb-init silently falls through to manual entry with no error.

---

### US-04 — cb-log member suggestions from teams.yaml

**As** an Agile coach logging an observation after a session,  
**when** a linked `teams.yaml` is present and I am asked "Who was in the session?",  
**I want** cb-log to suggest names from the team roster,  
**so that** my log entries use consistent names and roles without me remembering them.

`job_id`: ceremony-aware-engagement, structured-observation-capture

#### Elevator Pitch
Before: cb-log asks "Who was in the session?" and I type names from memory, inconsistently.  
After: run `/cb-log` → "Who was in the session? Team roster: Dan Fox (SM), Alice Chen (DEV), Priya Patel (PO) — enter names or press Enter for full team" → names consistent with teams.yaml.  
Decision enabled: I know my coaching log entries reference the same names I see in calendar invites, making cross-referencing straightforward.

#### Acceptance Criteria
- AC-04.1: When `config.json` contains a valid `team_config.path`, cb-log reads `team.members` from the linked teams.yaml before the "Who was in the session?" prompt.
- AC-04.2: cb-log presents the member list as a suggestion hint in the prompt: *"Team roster: `<name (ROLE), name (ROLE), ...>` — enter names or press Enter for full team."*
- AC-04.3: The coach can type any names (not restricted to the roster). The roster hint is informational only.
- AC-04.4: If "full team" (Enter with no input) is selected, cb-log populates the `participants` field with all member names from `team.members`.
- AC-04.5: When `team_config.path` is absent or teams.yaml cannot be read, cb-log presents the "Who was in the session?" prompt unchanged. (Graceful degradation.)

---

## Wave: DISCUSS / [REF] Story Map

```
BACKBONE (user activities, left → right)
────────────────────────────────────────────────────────────────────────────
Set up engagement         Capture team context         Run coaching session
        │                         │                             │
────────┼─────────────────────────┼─────────────────────────────┼──────────
Slice 1 │ US-01: Link teams.yaml  │                             │
        │ US-03: Auto-detect      │                             │
────────┼─────────────────────────┼─────────────────────────────┼──────────
Slice 2 │                         │                             │
        │                         │                   US-02: Sprint header
────────┼─────────────────────────┼─────────────────────────────┼──────────
Slice 3 │                         │ US-04: Member hints         │
────────┴─────────────────────────┴─────────────────────────────┴──────────

Walking skeleton: US-01 (link written to config.json) + US-02 (read in snapshot)
= proves the full data path: cb-init writes reference → cb-snapshot reads YAML → header rendered
```

**Prioritisation** (learning-leverage order):
1. Slice 1 — US-01 + US-03: highest uncertainty (does the coach actually declare the link, or find it too fiddly?)
2. Slice 2 — US-02: depends on Slice 1 path existing; validates the primary value claim (is sprint context useful?)
3. Slice 3 — US-04: lowest uncertainty (member hints are a clear improvement but have no architectural unknowns)

---

## Wave: DISCUSS / [REF] Outcome KPIs

| KPI | Target | Measurement |
|-----|--------|-------------|
| Link adoption rate | ≥60% of new cb-init runs in repos with a `teams/` dir result in a `team_config.path` being written | Count config.json files with `team_config.path` / total configs in repos containing `teams/` |
| Sprint context in snapshots | Sprint header present in ≥80% of snapshots where engagement has `team_config.path` and teams.yaml has `cadence: scrum` | Inspect snapshot files |
| Zero regression on existing engagements | 0 engagements without `team_config.path` show changed cb-init or cb-snapshot behaviour | Acceptance tests on existing engagement fixtures |
| cb-log member consistency | N/A for now — baseline metric to establish in Slice 3 | Manual review of COACHING_LOG.md entries |

---

## Wave: DISCUSS / [REF] Walking Skeleton Strategy

**Strategy B** (thin extension on brownfield) — no new system; extend two existing skills.

Walking skeleton = US-01 + US-02:
- US-01 proves the **write path**: cb-init can capture and persist the reference
- US-02 proves the **read path**: cb-snapshot can load a YAML file and render derived data into the snapshot

Together they prove all three integration points (config.json schema extension, YAML reader, snapshot header render) before Slice 3 adds member hints.

---

## Wave: DISCUSS / [REF] Driving Ports

| Port | Type | Entry point |
|------|------|-------------|
| `/cb-init` skill invocation | Inbound (Claude Code skill) | New optional prompt at end of setup flow |
| `/cb-snapshot` skill invocation | Inbound (Claude Code skill) | Reads `team_config.path` from config.json before rendering snapshot |
| `/cb-log` skill invocation | Inbound (Claude Code skill) | Reads `team.members` from teams.yaml before "Who was in the session?" prompt |
| `config.json` (file read) | Inbound (file) | Extended with `team_config` field |
| `teams/{name}/config.yaml` (file read) | Inbound (file) | calendar-magick YAML schema, read-only |

---

## Wave: DISCUSS / [REF] Pre-requisites

| Dependency | Status |
|---|---|
| cb-init SKILL.md with `--root` support | Delivered (cb-root-layout feature) |
| cb-snapshot with root-layout path resolution | Delivered (cb-root-layout feature) |
| calendar-magick teams.yaml schema | External — stable (~/calendar-magick). coach-buddy reads a subset: `team.name`, `team.members[].name`, `team.members[].role`, `team.cadence`, `team.sprint_length_weeks`, `team.timezone`. |
| No dependency on calendar-magick CLI being installed | Integration is YAML-read-only. calendar-magick CLI is not required at runtime. |

---

## Wave: DISCUSS / [REF] Out of Scope

- coach-buddy **writing** to teams.yaml (ownership remains with calendar-magick)
- coach-buddy **scaffolding** a new teams.yaml (that is calendar-magick's `init` command)
- Reading `team.events` ceremony schedule into coaching artifacts (future slice — events schema is complex; start with cadence only)
- Multi-team engagements (one engagement = one teams.yaml; disambiguation is out of scope)
- Syncing Jira/Linear **attendees** from teams.yaml roles (separate concern from calendar data)
- Detecting calendar-magick CLI installation at runtime

---

## Wave: DISCUSS / [REF] Definition of Done

- [ ] All ACs verified by acceptance tests (Vitest or skill-level scenarios)
- [ ] US-01 and US-03: cb-init setup flow tested with fixture teams.yaml present and absent
- [ ] US-02: snapshot header tested with scrum cadence, kanban cadence, and missing team_config.path
- [ ] US-04: cb-log tested with and without team_config.path
- [ ] Existing engagement fixtures (no team_config.path) show zero behaviour change
- [ ] SKILL.md files for cb-init, cb-snapshot, cb-log updated with new behaviour documented
- [ ] `team_config.path` validation logic documented in cb-init SKILL.md (valid file / file not found / skip paths)
- [ ] docs/product/jobs.yaml updated with `ceremony-aware-engagement`
- [ ] docs/product/journeys/ongoing-engagement.yaml extended with calendar-magick steps
- [ ] Slice briefs exist at docs/feature/calendar-magick-integration/slices/

---

## Wave: DISCUSS / [REF] Wave Decisions

See [wave-decisions.md](wave-decisions.md).

---

*Wave completed: 2026-05-19 | Density events: no triggers fired (silent lean) | Next: DESIGN*

---

## Wave: DESIGN / [REF] DDD List

This feature is a **thin integration layer** on an existing engagement context architecture. There is no new bounded context. The domain model is unchanged.

| Concept | Type | Owner | Notes |
|---------|------|-------|-------|
| `team_config` | Configuration value object | coach-buddy (config.json) | Holds the typed reference to the external teams.yaml |
| `team_config.path` | String (relative path) | coach-buddy (config.json) | Relative to engagement root. Resolved at runtime. |
| `team.cadence` | Enum: `scrum` \| `kanban` | calendar-magick (teams.yaml) | Read-only. Drives sprint-context branch in cb-snapshot. |
| `team.sprint_length_weeks` | Integer (positive) | calendar-magick (teams.yaml) | Read-only. Used in sprint position calculation. |
| `team.members[]` | Array of `{name, role}` | calendar-magick (teams.yaml) | Read-only. Used in cb-log member hint. |
| Sprint Position | Derived value | cb-snapshot (computed) | Not stored. Computed from `sprint_length_weeks` + today's date at runtime. |
| Team Context Resolver | Inline sub-pattern | All three skills | Named pattern, embedded verbatim per ADR-008. Parallel to Engagement Path Resolver. |

**Anti-Corruption Layer note**: The calendar-magick schema (`team.events`, `team.calendar_id`, etc.) is deliberately NOT read. The three consuming fields (`cadence`, `sprint_length_weeks`, `members`) constitute an explicit, minimal ACL over the calendar-magick domain. Additions to teams.yaml that coach-buddy does not reference are silently ignored.

---

## Wave: DESIGN / [REF] Component Decomposition

No new SKILL.md files. Three existing skills are extended inline.

| Component | Change type | Scope of change | User stories |
|-----------|-------------|-----------------|--------------|
| `cb-init` | EXTEND | New Q6 in setup flow; detection sub-step before Q6; config.json template update | US-01, US-03 |
| `cb-snapshot` | EXTEND | New Team Context Resolver sub-pattern after config read; sprint-context header logic; risk-read suffix | US-02 |
| `cb-log` | EXTEND | New Team Context Resolver sub-pattern after config read; member hint before "Who was in the session?" | US-04 |
| `config.json` schema | EXTEND | New top-level `team_config` key (`path` only). All existing keys unchanged. | US-01 |

Rejected: extracting Team Context Resolver to a shared reference file. ADR-008 requires SKILL.md self-containment. Extraction would make skills dependent on a reference file being present — a deployment coupling that violates the existing invariant.

---

## Wave: DESIGN / [REF] Driving Ports

These are the inbound invocation surfaces that trigger the new behaviour:

| Port | Trigger | Change |
|------|---------|--------|
| `/cb-init` invocation | Coach runs `/cb-init` or `/cb-init --root` | New Q6 prompt + auto-detection sub-step; config.json template gains optional `team_config` block |
| `/cb-snapshot` invocation | Coach runs `/cb-snapshot` | After config read: Team Context Resolver executes; if scrum cadence, sprint-context suffix injected into header and risk read |
| `/cb-log` invocation | Coach runs `/cb-log` | After config read: Team Context Resolver executes; member hint displayed before "Who was in the session?" prompt |

No new driving ports are created. The three existing skill invocation surfaces carry the new behaviour via conditional extension.

---

## Wave: DESIGN / [REF] Driven Ports and Adapters

### Port: Team Context Resolver

**Purpose**: read `team_config.path` from config.json, resolve the absolute path, read teams.yaml, and extract the relevant subset. Gracefully degrade if absent or unreadable.

**Contract** (prose, not code — this is SKILL.md behaviour):

```
TEAM CONTEXT RESOLVER
─────────────────────
Step 1 — Check for team_config reference
  Read `team_config.path` from the engagement config.json already loaded.
  If the field is absent: team context is not configured — skip Steps 2-3 entirely.
  Set `teams_yaml_path` = resolve `team_config.path` relative to `engagement_path`.

Step 2 — Read teams.yaml
  Attempt to read the file at `teams_yaml_path`.
  If the file cannot be read (not found, permission error, unreadable content):
    Log nothing. Team context is unavailable — skip Step 3 entirely. Continue skill.
  Parse only the following fields:
    team.name, team.cadence, team.sprint_length_weeks, team.timezone, team.members

Step 3 — Expose team context to calling skill
  Set `team_cadence`          = team.cadence (string; absent → null)
  Set `team_sprint_weeks`     = team.sprint_length_weeks (integer; absent → null)
  Set `team_members`          = team.members array (absent or empty → empty array)
  Any other fields in teams.yaml are ignored.
```

**Probe requirement**: The Team Context Resolver pattern includes an explicit degradation test in the skill's acceptance criteria. Before the crafter submits Slice 02, they must verify the resolver silently skips when (a) `team_config` is absent from config.json, (b) the file at the resolved path does not exist, and (c) the file exists but contains no `team.cadence` field.

**adapter**: teams.yaml file on local filesystem — calendar-magick owns the write path. coach-buddy reads subset only.

**No new driven ports for filesystem I/O** — reading local files is already the established pattern for `config.json`, `COACHING_LOG.md`, and snapshot files. The teams.yaml adapter follows the same idiom.

### Port: Sprint Position Calculator

**Purpose**: derive sprint day and week from `sprint_length_weeks` and today's date. Deterministic. No stored state.

**Algorithm** (prose, to be embedded verbatim in cb-snapshot SKILL.md):

```
SPRINT POSITION CALCULATOR
──────────────────────────
Inputs: sprint_length_weeks (integer N, ≥ 1), today (YYYY-MM-DD)

Step 1 — Find the most recent sprint-aligned Monday
  a. Determine today's ISO week number (week_num) and year.
  b. Find the Monday of the current ISO week (call it week_monday).
  c. Sprint cycle length in weeks = N.
  d. Use a fixed epoch anchor: 2020-01-06 (Monday, ISO week 2020-W02).
     Weeks elapsed since epoch = floor((week_monday − epoch_monday) / 7).
     Sprint cycle index = weeks_elapsed mod N.
     Sprint start Monday = week_monday − (sprint_cycle_index × 7 days).

Step 2 — Calculate sprint day (weekdays only)
  Count business days (Mon–Fri) from sprint_start_monday to today, inclusive.
  sprint_day = count of Mon–Fri days from sprint_start_monday to today (1-based).

Step 3 — Calculate sprint week
  sprint_week = ceil(sprint_day / 5).  [5 business days per week]
  sprint_week_of_total = sprint_week / N.

Step 4 — Output
  sprint_start_label = sprint_start_monday formatted as YYYY-MM-DD
  Return: "Day {sprint_day}, Week {sprint_week}/{N} of Sprint
           ({N}-week scrum, started {sprint_start_label})"

Edge cases:
  - If today is Saturday or Sunday: use Friday as today for day count.
    Sprint position does not advance on weekends.
  - If sprint_length_weeks is absent or zero: skip sprint context entirely.
```

**Rationale for epoch anchor**: A fixed epoch (2020-01-06) makes the algorithm reproducible across all environments without user input. The epoch is arbitrary but fixed — two coaches with 2-week sprints will see the same sprint boundaries for any given date. This is the correct trade-off: calendar alignment is a coaching convenience, not a payroll calculation. See ADR-013.

---

## Wave: DESIGN / [REF] Technology Choices

This feature operates entirely within the SKILL.md prose architecture. There is no compiled code, no new runtime dependencies, and no npm packages.

| Concern | Choice | Rationale | License |
|---------|--------|-----------|---------|
| YAML parsing | Claude's built-in YAML comprehension | SKILL.md skills rely on Claude to read and parse files. Claude can parse YAML natively as part of instruction following. No library needed. | N/A |
| Sprint position calculation | Prose algorithm embedded in SKILL.md | Arithmetic only. Implementable purely as LLM instruction-following steps. No library needed. | N/A |
| teams.yaml schema | calendar-magick schema subset (read-only) | Locked in DISCUSS wave. Subset: `team.name`, `team.cadence`, `team.sprint_length_weeks`, `team.timezone`, `team.members[].name`, `team.members[].role`. | N/A — external schema |

**No new proprietary dependencies.** No new OSS dependencies. The integration is file-read-only and relies on Claude's reasoning capabilities already present in the runtime.

---

## Wave: DESIGN / [REF] Decisions Table

| # | Decision | Options considered | Chosen | Rationale |
|---|----------|--------------------|--------|-----------|
| DD-01 | config.json placement of team_config | (a) top-level peer key `"team_config": {"path": "..."}` — (b) nested under `"engagement"` — (c) flat string `"team_config_path"` | (a) | `tool` and `engagement` are existing top-level peer keys. `team_config` follows the same pattern: a named integration block. Nesting under `engagement` would conflate engagement identity with integration references. A flat string has no room for future extension (e.g. a `type` discriminator if a second topology source is ever added). |
| DD-02 | Pattern name for YAML reader logic | (a) unnamed inline conditional — (b) named "Team Context Resolver" sub-pattern, embedded verbatim — (c) extracted to shared reference file | (b) | A named pattern gives acceptance-designer and software-crafter a stable identifier to test against. "Verbatim embedded" preserves ADR-008 self-containment. Unnamed inline prose is harder to reason about across three skills. Extracted reference file violates ADR-008. |
| DD-03 | Sprint position epoch | (a) fixed epoch 2020-01-06 — (b) ISO week number mod N — (c) stored sprint start date in config.json | (a) + (b) combined | The algorithm in DD-03 uses ISO week arithmetic to find weeks-since-epoch, then modulo N. The epoch (2020-01-06) anchors the cycle. Storing sprint start date was ruled out by the DISCUSS constraint "no stored sprint start date." A pure mod-on-ISO-week without an epoch anchor produces drift when sprint length doesn't divide evenly into year boundaries. See ADR-013. |
| DD-04 | cb-init prompt position | (a) after Q5 (WIP threshold) — (b) after Q3 (PM tool selection) — (c) before Q1 as a pre-flow check | (a) | AC-01.1 is explicit: "last question in the setup flow, after all existing prompts." The detection sub-step (US-03) executes immediately before the Q6 prompt, not as a separate question. |
| DD-05 | Weekend handling in sprint calculator | (a) advance sprint day on weekends — (b) freeze at Friday — (c) error/skip on weekends | (b) | Sprint ceremonies happen on weekdays. A coach preparing on a weekend is viewing Friday's position. Freezing at Friday is the natural coaching interpretation. No error surface needed. |

---

## Wave: DESIGN / [REF] Reuse Analysis

| Existing Component | File | Overlap | Decision | Justification |
|--------------------|------|---------|----------|---------------|
| Engagement Path Resolver pattern | Embedded verbatim in cb-snapshot, cb-log, cb-retro, cb-validate, coach-buddy | Provides the engagement_path resolution that the Team Context Resolver builds on | EXTEND — Team Context Resolver executes after Engagement Path Resolver completes | The resolver chain is sequential: first resolve engagement_path (existing), then conditionally resolve teams.yaml from that path (new). No coupling change. |
| cb-init setup flow (Q1–Q5) | `skills/cb-init/SKILL.md` lines 20–31 | Setup flow pattern with sequential questions and deferred writing | EXTEND — add Q6 and detection sub-step at end of existing flow | The five-question pattern is established. Q6 follows the same one-at-a-time discipline. Detection sub-step executes before Q6 is displayed. No questions are reordered. |
| cb-init config.json template | `skills/cb-init/SKILL.md` config.json template block | JSON template for the file written at end of flow | EXTEND — add optional `team_config` block, written only when path is confirmed | The template is additive. When no path is entered, the block is omitted. Existing template fields are unchanged. |
| cb-snapshot config read section | `skills/cb-snapshot/SKILL.md` "Reading the engagement config" | Reads config.json and extracts tool fields | EXTEND — after existing extraction, add Team Context Resolver execution | The existing read section already extracts all tool.* fields. Team Context Resolver reads `team_config.path` from the same already-loaded config object. No second file read of config.json. |
| cb-snapshot output format (header line) | `skills/cb-snapshot/SKILL.md` output format block | Snapshot header line format | EXTEND — conditional suffix appended to header when cadence=scrum | The header line `Generated: {YYYY-MM-DD}` gains an optional `| Day D, Week W/N of Sprint (...)` suffix. Format is additive; no existing fields change. |
| cb-snapshot risk read | `skills/cb-snapshot/SKILL.md` risk read section | Two-sentence in-chat risk read | EXTEND — when sprint context is present, risk read gains the sprint-context suffix (AC-02.6) | One sentence added conditionally. Existing risk-read discipline (observational, no diagnosis) is unchanged. |
| cb-log config read section | `skills/cb-log/SKILL.md` "Reading the engagement config" | Reads config.json for engagement_path | EXTEND — after existing extraction, add Team Context Resolver execution | Same pattern as cb-snapshot extension. |
| cb-log "Who was in the session?" prompt | `skills/cb-log/SKILL.md` Mode 1, Step 1 | Prompt text for participants field | EXTEND — hint line prepended when team_members is non-empty | The prompt is unchanged when team_config is absent. Hint is informational only; coach can type any names. |

**CREATE NEW count**: 0. Every change is an EXTEND on an existing component.

---

## Wave: DESIGN / [REF] Open Questions

| # | Question | Impact | Disposition |
|---|----------|--------|-------------|
| OQ-01 | What happens if teams.yaml contains multiple team entries (a flat array at root)? | Sprint calculator and member hints would need to know which entry to use | Deferred — DISCUSS locked D4 to "one engagement = one teams.yaml." calendar-magick's standard layout places one team per file at `teams/<name>/config.yaml`. If a multi-team file is encountered, the Team Context Resolver reads only the first `team:` block found. |
| OQ-02 | Does the sprint position epoch (2020-01-06) need to be configurable? | Coaches on unusual sprint calendars (fiscal year anchors, non-Monday start) may see misaligned positions | Deferred — accept as a known limitation for v1. The epoch produces correct alignment for most teams. A future `team_config.sprint_anchor_date` override can be added if coaches report misalignment. |
| OQ-03 | Should cb-init validate that the path points to a recognisable calendar-magick file (i.e., contains a `team:` key), or only validate file existence? | Deeper validation catches typos to wrong YAML files but adds a parsing step and a failure mode | Decision for acceptance-designer: AC-01.2 specifies "file exists" validation only. Deeper schema validation is not in scope for Slice 01. This question should be reviewed in Slice 01 retrospective. |
| OQ-04 | cb-log US-04 populates `participants` field when Enter is pressed ("full team") — is `participants` an existing COACHING_LOG.md entry field? | If not, the field needs to be added to the entry format | RISK: the current cb-log entry format does not include a `participants:` frontmatter field. The crafter must confirm whether to add it as a new optional field or embed names in the `**Context**:` field. Raise with acceptance-designer before Slice 03 begins. |

---

*Wave completed: 2026-05-19 | Next: DISTILL*

---

## Wave: DISTILL / [REF] Scenario List

| # | Scenario | File | Tags |
|---|----------|------|------|
| 1 | Coach links a teams.yaml during cb-init and config.json records the path | walking-skeleton.feature | `@walking_skeleton @real-io @US-01` |
| 2 | cb-snapshot renders sprint context in the snapshot header when teams.yaml has scrum cadence | walking-skeleton.feature | `@walking_skeleton @real-io @US-02` |
| 3 | Coach enters a valid path and config.json is written with team_config | slice-01-teams-yaml-link.feature | `@real-io @US-01` |
| 4 | Coach presses Enter to skip and config.json is written without team_config | slice-01-teams-yaml-link.feature | `@real-io @US-01` |
| 5 | Coach enters a path to a file that does not exist — cb-init warns and skips the field | slice-01-teams-yaml-link.feature | `@real-io @US-01` |
| 6 | teams.yaml link prompt is the last question in the setup flow | slice-01-teams-yaml-link.feature | `@real-io @US-01` |
| 7 | Existing engagements without team_config continue to work after cb-init update | slice-01-teams-yaml-link.feature | `@real-io @US-01` |
| 8 | Exactly one teams/*/config.yaml is found — cb-init pre-suggests it | slice-01-teams-yaml-link.feature | `@real-io @US-03` |
| 9 | Multiple teams/*/config.yaml files found — cb-init presents a numbered list | slice-01-teams-yaml-link.feature | `@real-io @US-03` |
| 10 | No teams/ directory found — cb-init falls through to manual entry unchanged | slice-01-teams-yaml-link.feature | `@real-io @US-03` |
| 11 | teams/ directory exists but cannot be read — cb-init falls through silently | slice-01-teams-yaml-link.feature | `@real-io @US-03` |
| 12 | Snapshot header includes sprint day and week when cadence is scrum | slice-02-sprint-aware-snapshot.feature | `@real-io @US-02` |
| 13 | Risk read in chat includes sprint context when cadence is scrum | slice-02-sprint-aware-snapshot.feature | `@real-io @US-02` |
| 14 | Sprint position algorithm uses fixed epoch — reproducible for any date | slice-02-sprint-aware-snapshot.feature | `@real-io @US-02` |
| 15 | Weekend is treated as the preceding Friday for sprint position | slice-02-sprint-aware-snapshot.feature | `@real-io @US-02` |
| 16 | No sprint context when teams.yaml has cadence: kanban | slice-02-sprint-aware-snapshot.feature | `@real-io @US-02` |
| 17 | No sprint context when teams.yaml has no cadence field | slice-02-sprint-aware-snapshot.feature | `@real-io @US-02` |
| 18 | No sprint context when config.json has no team_config field | slice-02-sprint-aware-snapshot.feature | `@real-io @US-02` |
| 19 | No sprint context and no error when teams.yaml cannot be read | slice-02-sprint-aware-snapshot.feature | `@error @real-io @US-02` |
| 20 | No sprint context and no error when teams.yaml has no team.cadence field | slice-02-sprint-aware-snapshot.feature | `@error @real-io @US-02` |
| 21 | cb-log shows the team roster as a hint before asking who was in the session | slice-03-member-hints.feature | `@real-io @US-04` |
| 22 | Coach presses Enter to select full team — participants field populated with all members | slice-03-member-hints.feature | `@real-io @US-04` |
| 23 | Coach types custom names — participants field reflects exactly what was typed | slice-03-member-hints.feature | `@real-io @US-04` |
| 24 | Coach types names not in the roster — cb-log accepts them without warning | slice-03-member-hints.feature | `@real-io @US-04` |
| 25 | No member hint when config.json has no team_config field | slice-03-member-hints.feature | `@real-io @US-04` |
| 26 | No member hint and no error when teams.yaml cannot be read | slice-03-member-hints.feature | `@error @real-io @US-04` |
| 27 | participants field is omitted when team context is absent | slice-03-member-hints.feature | `@real-io @US-04` |
| 28 | Existing COACHING_LOG.md entries without participants field remain valid | slice-03-member-hints.feature | `@real-io @US-04` |

Total: 28 scenarios (2 walking skeleton, 7 error paths, 0 property-based)

---

## Wave: DISTILL / [REF] Walking Skeleton Strategy

**Strategy C (real local)** — all resources are local filesystem SKILL.md files. No automated test runner. Manual conversation tests executed in Claude Code with a real CoWork project directory.

**Justification**: The system under test is Claude executing SKILL.md prose instructions. There is no compiled code to instrument. Strategy C is the established pattern for this project (matches cb-root-layout feature). Strategy A (InMemory) and Strategy B (fake costly) are not applicable — there are no automated test adapters to substitute.

**WS scope**: US-01 write path + US-02 read path. Together they prove: config.json schema extension (team_config written) → Team Context Resolver (YAML loaded) → Sprint Position Calculator (header rendered). All three integration points exercised before Slice 3 adds member hints.

---

## Wave: DISTILL / [REF] Adapter Coverage

| Driven adapter | Type | Real-IO scenario |
|----------------|------|-----------------|
| config.json reader (existing) | Local filesystem | Scenarios 1, 3, 12, 18, 21, 25 |
| teams.yaml reader (new — Team Context Resolver) | Local filesystem | Scenarios 1, 2, 3, 8, 12-17, 21-24 |
| config.json writer (cb-init) | Local filesystem | Scenarios 1, 3, 4, 5 |
| COACHING_LOG.md writer (cb-log) | Local filesystem | Scenarios 22, 23, 24, 27, 28 |
| Snapshot file writer (cb-snapshot) | Local filesystem | Scenario 2, 12 |

Every driven adapter has at least one `@real-io` scenario. Graceful-degradation paths (missing file, absent field) are covered by `@error @real-io` scenarios — the real filesystem is used, the file is simply absent.

---

## Wave: DISTILL / [REF] Scaffolds

No `__SCAFFOLD__` RED stubs are needed. SKILL.md files already exist. The DELIVER wave crafter modifies existing files in-place. The acceptance tests verify content, not scaffolded stubs.

Acceptance test files created (RED — not yet satisfied):

| File | Scenarios | Status |
|------|-----------|--------|
| `tests/acceptance/calendar-magick-integration/walking-skeleton.feature` | 2 | RED |
| `tests/acceptance/calendar-magick-integration/slice-01-teams-yaml-link.feature` | 9 | RED |
| `tests/acceptance/calendar-magick-integration/slice-02-sprint-aware-snapshot.feature` | 9 | RED |
| `tests/acceptance/calendar-magick-integration/slice-03-member-hints.feature` | 8 | RED |

---

## Wave: DISTILL / [REF] Test Placement

`tests/acceptance/calendar-magick-integration/` — follows the established pattern from `tests/acceptance/cb-root-layout/` (the cb-root-layout feature's acceptance tests are co-located in their own directory under `tests/acceptance/`).

---

## Wave: DISTILL / [REF] Driving Adapter Coverage

| Driving port (from DESIGN) | Covered by scenario |
|---------------------------|---------------------|
| `/cb-init` skill invocation | Scenarios 1, 3, 4, 5, 6, 7, 8, 9, 10, 11 |
| `/cb-snapshot` skill invocation | Scenarios 2, 12, 13, 14, 15, 16, 17, 18, 19, 20 |
| `/cb-log` skill invocation | Scenarios 21, 22, 23, 24, 25, 26 |

All three driving ports from the DESIGN wave have at least one scenario each.

---

## Wave: DISTILL / [REF] Pre-requisites

| Pre-requisite | Status |
|---|---|
| DESIGN driving ports: /cb-init, /cb-snapshot, /cb-log | Defined in DESIGN Driving Ports section |
| DESIGN driven ports: Team Context Resolver, Sprint Position Calculator | Fully specified in DESIGN with prose contracts |
| DESIGN decisions DD-01 to DD-05 | All locked; no open contradictions |
| OQ-04 resolution: `participants:` as new optional frontmatter field | Resolved — analogous to existing optional `mode:` field; DELIVER crafter adds to COACHING_LOG.md entry format |
| cb-root-layout feature | Delivered — cb-init --root, cb-snapshot root layout, slug disambiguation all complete |
| calendar-magick teams.yaml schema subset | Locked at DISCUSS (team.name, team.cadence, team.sprint_length_weeks, team.timezone, team.members) |
| Sprint epoch anchor ADR-013 | Written — 2020-01-06 fixed Monday |
| Date fixture for scenario 14 | today=2026-05-19, sprint_length_weeks=2, epoch=2020-01-06 → sprint start=2026-05-18, Day 2, Week 1/2 |

*Wave completed: 2026-05-19 | 28 scenarios across 4 files | WS Strategy C | Density: lean | Next: DELIVER*
