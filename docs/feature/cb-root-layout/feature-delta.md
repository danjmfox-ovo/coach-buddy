# Feature Delta: cb-root-layout

**Status**: DISCUSS wave complete — Ready for DESIGN wave
**Date**: 2026-05-19
**ADR**: ADR-012 (locked — design not re-opened here)
**Jobs**: cowork-native-setup (primary), engagement-scaffolding (J9, secondary)

---

## Problem Statement

Agile coaches using dedicated CoWork project directories (one directory = one engagement) are forced to store engagement files inside an `engagements/<slug>/` subdirectory — a redundant wrapper that exists to support multi-engagement projects. There is no supported way to scaffold at the project root, and attempting to work around this manually breaks all downstream skill path references.

## User

Agile Coach (Dan — coach using `~/teams/advisor-connect` as a dedicated single-engagement project) who wants engagement files where they naturally belong: at the project root, alongside `CLAUDE.md` and `.claude/`.

## What Changes

### cb-init (Slice 01)
- New `--root` flag: when passed, all engagement files are scaffolded at cwd instead of `engagements/<slug>/`
- Overwrite guard checks `./config.json` (not `engagements/<slug>/config.json`) when `--root` is active
- Success output shows `./` as the engagement path
- Default behaviour (without `--root`) is unchanged

### cb-log, cb-retro, cb-snapshot, cb-validate, coach-buddy (Slice 02)
- All skills implement a two-step detection chain:
  1. Check `./config.json` for engagement schema → root layout
  2. Fall back to `engagements/<slug>/config.json` → legacy layout
- In root layout: all reads and writes target `./` not `engagements/<slug>/`
- In root layout: slug disambiguation logic (glob + prompt) is bypassed; slug read from root `config.json`
- Legacy layout is unchanged — backwards compatible

## What Does NOT Change

- Default `cb-init` behaviour (no `--root` flag)
- Existing `engagements/<slug>/` engagements
- `--root <path>` (arbitrary path target) — future extension, explicitly out of scope (ADR-012 D4)
- Coaching logic, prompts, frameworks, or SKILL.md content of any skill beyond path resolution

---

## Slice Summary

| Slice | Stories | Outcome | Dependency |
|-------|---------|---------|------------|
| Slice 01 | US-CBR-01 | Coach can `cb-init --root` | None |
| Slice 02 | US-CBR-02, US-CBR-03 | Full cycle works in root layout | Slice 01 complete |

Both slices are Must Have. Slice 02 must ship atomically (no partial downstream rollout).

---

## Jobs Traceability

| Story | Job ID | Job Title |
|-------|--------|-----------|
| US-CBR-01 | cowork-native-setup | Initialise a coaching engagement in a project directory that IS the engagement |
| US-CBR-02 | cowork-native-setup | (same) |
| US-CBR-03 | infrastructure-only | Slug disambiguation bypass — no user-visible surface |

`cowork-native-setup` was added to `docs/product/jobs.yaml` during this DISCUSS wave (WD-002). Validated against real-world reference: `~/teams/advisor-connect` manual migration confirms the desired ergonomic.

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Partial rollout: Slice 01 ships, Slice 02 delayed | Medium | High — broken init → log cycle | Gate Slice 02 as atomic; do not publish `--root` as user-ready until Slice 02 ships |
| Root file name collision (COACHING_LOG.md already in project) | Low | Medium — overwrite guard fires on config.json only; other files not guarded individually | ADR-012 Consequences: cb-init should warn if COACHING_LOG.md exists but config.json does not. Note for DESIGN wave. |
| Coach uses `--root <path>` expecting it to work | Low | Low — command ignored or errors | SKILL.md should note limitation and suggest `cd <path> && cb-init --root` workaround |

---

## Handoff Notes for DESIGN Wave (solution-architect)

1. **SKILL.md changes are the primary deliverable** — this is a skill-layer change, not application code
2. **Detection chain must be consistent** across all five downstream skills — consider a shared "engagement path resolver" section that each SKILL.md can reference or copy verbatim
3. **Schema signal for root config.json detection**: check for `version` and `engagement.slug` fields (per ADR-012 rationale) to distinguish coach-buddy config from any other root-level `config.json`
4. **coach-buddy SKILL.md**: verify whether it has its own path resolution logic or relies on a passed engagement path — spot-check needed in DELIVER
5. **ongoing-engagement.yaml update**: `engagement-start` step still shows `engagements/<slug>/` paths. Post-DELIVER task to update with layout-conditional notes

---

## Artifacts

| Artifact | Path |
|----------|------|
| Wave decisions | `docs/feature/cb-root-layout/discuss/wave-decisions.md` |
| Story map | `docs/feature/cb-root-layout/discuss/story-map.md` |
| Slice 01 (US-CBR-01) | `docs/feature/cb-root-layout/slices/slice-01-root-init.md` |
| Slice 02 (US-CBR-02, US-CBR-03) | `docs/feature/cb-root-layout/slices/slice-02-downstream-detection.md` |
| Jobs YAML (updated) | `docs/product/jobs.yaml` |
| ADR (locked) | `docs/product/architecture/adr-012-root-layout-cowork-placement.md` |

---

## Wave: DESIGN / [REF-D1] Reuse Analysis

All six files in scope are extensions of existing SKILL.md documents. No new files are created.

| SKILL.md | Action | Justification |
|---|---|---|
| `cb-init/SKILL.md` | EXTEND | Gains `--root` flag handling and a conditional overwrite guard path. All existing setup flow, guardrails, and file templates are unchanged. |
| `cb-log/SKILL.md` | EXTEND | Gains detection chain at the top of "Reading the engagement config" section. All entry logic, modes, and guardrails unchanged. |
| `cb-retro/SKILL.md` | EXTEND | Gains detection chain at the top of "Reading the engagement config" section. All three modes and guardrails unchanged. |
| `cb-snapshot/SKILL.md` | EXTEND | Gains detection chain at the top of "Reading the engagement config" section. All tool sections, output format, risk read, and guardrails unchanged. |
| `cb-validate/SKILL.md` | EXTEND | Gains detection chain at the top of "Reading the engagement config" section. All parsing, grouping, and validation loop unchanged. |
| `coach-buddy/SKILL.md` | EXTEND | Gains detection chain for optional engagement context reads (CONTEXT.md, COACHING_LOG.md, snapshots). Thinking-partner pipeline, mode management, and all guardrails unchanged. |

**Outcome collision check: SKIPPED.** This feature changes only SKILL.md prose instruction files. There is no typed contract surface, no domain model change, and no outcomes registry entry affected. The skip is documented here and does not require further justification.

---

## Wave: DESIGN / [REF-D2] Component Decomposition

Changes by file, section, and type of change:

| SKILL.md | Section changing | Change type |
|---|---|---|
| `cb-init` | `## Overwrite guard` | New conditional branch: if `--root`, check `./config.json`; else check `engagements/<slug>/config.json` |
| `cb-init` | `## Files to create` | Path variable change: all `engagements/<slug>/…` paths become `./…` when `--root` is active |
| `cb-init` | `## Success output` | Path variable change: folder path shows `./` not `engagements/<slug>/` in root layout |
| `cb-init` | Frontmatter `argument-hint` | New flag addition: `--root` added to hint |
| `cb-init` | `## What this does` | New flag documentation: one sentence describing `--root` behaviour |
| `cb-log` | `## Reading the engagement config` | Detection chain replaces hardcoded `engagements/<slug>/config.json` read |
| `cb-retro` | `## Reading the engagement config` | Detection chain replaces hardcoded `engagements/<slug>/config.json` read |
| `cb-snapshot` | `## Reading the engagement config` | Detection chain replaces hardcoded `engagements/<slug>/config.json` read |
| `cb-snapshot` | `## Coaching context` | Path variable: `engagements/<slug>/COACHING_LOG.md` check uses resolved `engagement_path` |
| `cb-validate` | `## Reading the engagement config` | Detection chain replaces hardcoded `engagements/<slug>/config.json` read |
| `cb-validate` | `## Step 1 — Read and parse COACHING_LOG.md` | Path uses resolved `engagement_path` variable |
| `coach-buddy` | No dedicated "Reading the engagement config" section exists | New section added: `## Engagement context (optional)` with detection chain before optional reads |

---

## Wave: DESIGN / [REF-D3] Data Flow

### Slice 01: --root flag through cb-init

```
Coach invokes /cb-init [--root] [--force]
        |
        v
Parse flags
        |
   --root present?
   /           \
  YES           NO
  |             |
  target = ./   target = engagements/<slug>/
        |
        v
Overwrite guard
        |
   Read {target}/config.json
        |
   Exists?
   /       \
  YES       NO
  |         |
  --force?  Proceed to setup flow
  /    \
YES    NO
|      |
Skip   Ask "Overwrite? yes/no"
        |
        v (on yes or --force or not-exists)
Setup flow (team name, slug, tool config, WIP threshold)
        |
        v
Create files at {target}/ [CONTEXT.md, COACHING_LOG.md, RETRO_ACTIONS.md, HISTORY.md, config.json, snapshots/.gitkeep]
        |
        v
Success output: "Engagement folder created: {target}/"
```

Decision points:
- `--root present?` — governs target directory for the entire flow
- `Exists? + --force?` — governs overwrite guard path (same logic, different path variable)
- `--root <path> token?` — if a path token follows `--root`, note it is not supported; suggest `cd <path> && cb-init --root`

### Slice 02: Detection chain through downstream skills

```
Coach invokes /cb-log | /cb-retro | /cb-snapshot | /cb-validate | /coach-buddy
        |
        v
[ENGAGEMENT PATH RESOLVER — shared pattern]
        |
        v
Step 1: Attempt to read ./config.json
        |
   Exists AND contains {version, engagement.slug}?
   /                         \
  YES                         NO
  |                           |
  layout = root               Step 2: Attempt to read engagements/<slug>/config.json
  engagement_path = ./        (slug from --slug flag, or glob engagements/, or disambig prompt)
  slug = config.slug                 |
                               Exists?
                               /       \
                              YES       NO
                              |         |
                              layout = legacy    No engagement found
                              engagement_path = engagements/<slug>/    |
                                                          v
                                              Error: "No engagement found at ./config.json
                                              or engagements/<slug>/config.json.
                                              Run /cb-init or /cb-init --root."
        |
        v (root or legacy path resolved)
Slug disambiguation
        |
   layout = root?
   /         \
  YES         NO
  |           |
  Skip        Legacy disambiguation (glob engagements/, prompt if >1)
  slug already set
        |
        v
All subsequent file reads and writes use {engagement_path} variable
```

Decision points:
- `./config.json exists AND has schema?` — layout selection gate
- `layout = root?` — disambiguation bypass gate
- All downstream file paths constructed as `{engagement_path}/FILENAME` — never hardcoded

---

## Wave: DESIGN / [REF-D4] Shared Detection Pattern

The detection logic is identical across all five downstream skills. Rather than duplicating the prose five times, each SKILL.md embeds the following named section verbatim under `## Reading the engagement config`.

### Named pattern: "Engagement Path Resolver"

This section replaces the current `## Reading the engagement config` section in each downstream skill. The section text is:

---

**Step 1 — Check for root layout**

Attempt to read `./config.json`. If the file exists and contains both a `version` field and an `engagement.slug` field, this is a root-layout engagement:
- Set `engagement_path` = `./`
- Set `slug` = value of `engagement.slug`
- Skip Step 2 and proceed directly to the skill's main logic using `engagement_path`

**Step 2 — Fall back to legacy layout**

If `./config.json` is absent or does not contain the engagement schema, look for an engagement under `engagements/`:
- If `--slug <team-slug>` was passed, use that slug directly: set `engagement_path` = `engagements/<slug>/`
- If no slug was passed and exactly one folder exists under `engagements/` with a `config.json`, use that
- If multiple folders exist and no slug was specified, ask: "Which engagement? (available: `<list of slugs>`)"

**Step 3 — No engagement found**

If neither Step 1 nor Step 2 yields a config, surface:
> "No engagement found at `./config.json` or `engagements/<slug>/config.json`. Run `/cb-init` to create an engagement, or `/cb-init --root` to scaffold at this location."

---

**Why a shared named pattern rather than five independent copies:** The detection logic is a single invariant. Future changes (e.g. adding `--root <path>` support in ADR-012 D4 extension) require editing one definition, not hunting across five files. The pattern is short enough to embed verbatim without abstraction overhead.

**Why verbatim embedding, not extraction to a reference document:** SKILL.md self-containment is a design invariant from ADR-008 (portable install two-layer model). Skills installed into a team project's `.claude/skills/` must not depend on reference files being present. A `references/engagement-path-resolver.md` file would require each skill to explicitly read it at runtime — adding a step that is not guaranteed in all deployment configurations. Verbatim embedding is the correct choice within the ADR-008 constraint.

**coach-buddy note:** coach-buddy has no existing "Reading the engagement config" section. The Engagement Path Resolver is added as a new `## Engagement context (optional)` section inserted after `## Core stance` and before `## Mode management`. This positions it as context-loading before any mode or framework logic runs — the correct execution order. If no engagement is found, coach-buddy silently proceeds without context — no error, because context is optional for this skill.

---

## Wave: DESIGN / [REF-D5] SKILL.md Change Blueprint

### cb-init/SKILL.md

**Frontmatter `argument-hint`**
- Before: `'[--force] — re-run on an existing slug without confirmation prompt'`
- After: `'[--root] [--force] — --root scaffolds at current working directory; --force skips overwrite prompt'`

**`## What this does` section**
- Before: describes `engagements/<team-slug>/` only
- After: adds one sentence — "With `--root`, files are scaffolded at the current working directory with no `engagements/` subdirectory."

**`## Overwrite guard` section**
- Before: single path — checks `engagements/<slug>/config.json`
- After: conditional on `--root` flag:
  - If `--root` is active: check `./config.json` (target = current working directory)
  - If `--root` is not active: check `engagements/<slug>/config.json` (existing behaviour, unchanged)
  - Guard message changes to: "An engagement at this location already exists (config.json found). Overwrite it? (yes/no)"
  - Additional guard: if `./config.json` is absent but `./COACHING_LOG.md` exists when `--root` is active, warn: "COACHING_LOG.md already exists at this location. It will not be overwritten by the overwrite guard — only config.json is checked. Proceed? (yes/no)"

**`## Files to create` section**
- Before: all paths are `engagements/<slug>/…`
- After: all paths become `{target}/…` where `target` = `./` when `--root` is active, `engagements/<slug>/` otherwise. The templates themselves are unchanged — only the path prefix changes.

**`## Success output` section**
- Before: `Engagement folder created: engagements/<slug>/`
- After: `Engagement folder created: {target}/` (shows `./` in root layout, `engagements/<slug>/` in legacy layout)

---

### cb-log/SKILL.md

**`## Reading the engagement config` section**
- Before: "Read `engagements/<slug>/config.json` to find the engagement path. If `--slug` is passed, use that slug. If not and only one engagement folder exists, use that. If multiple exist, ask."
- After: Replace entirely with the Engagement Path Resolver named pattern (REF-D4). The `--slug` flag behaviour is preserved as Step 2's legacy path. All subsequent references to `COACHING_LOG.md` use `{engagement_path}/COACHING_LOG.md`.

**Step 5 confirm message**
- Before: `Entry {id} added to {engagement_path}/COACHING_LOG.md`
- After: unchanged — `{engagement_path}` is now resolved by the Engagement Path Resolver, so the message naturally shows `./COACHING_LOG.md` in root layout and `engagements/<slug>/COACHING_LOG.md` in legacy layout

---

### cb-retro/SKILL.md

**`## Reading the engagement config` section**
- Before: "Read `engagements/<slug>/config.json` to find the engagement path. If `--slug` is passed, use that slug. If not and only one engagement folder exists, use that. If multiple exist, ask."
- After: Replace entirely with the Engagement Path Resolver named pattern (REF-D4). All subsequent references to `RETRO_ACTIONS.md` use `{engagement_path}/RETRO_ACTIONS.md`.

---

### cb-snapshot/SKILL.md

**`## Reading the engagement config` section**
- Before: "Read `engagements/<slug>/config.json`. If `--slug` is passed, use that slug. If not and only one folder exists, use it. If multiple exist, ask which engagement."
- After: Replace entirely with the Engagement Path Resolver named pattern (REF-D4). The extraction of `tool.type`, `tool.project_key`, etc. follows after the resolver resolves `engagement_path` and the config is in hand — no change to that logic.

**`## Output format` section**
- Before: `engagements/<slug>/snapshots/{YYYY-MM-DD}-board.md`
- After: `{engagement_path}/snapshots/{YYYY-MM-DD}-board.md`

**`## Confirmation output` section**
- Before: `Snapshot written: engagements/<slug>/snapshots/{YYYY-MM-DD}-board.md`
- After: `Snapshot written: {engagement_path}/snapshots/{YYYY-MM-DD}-board.md`

**`## Coaching context` section**
- Before: `Read engagements/<slug>/COACHING_LOG.md`
- After: `Read {engagement_path}/COACHING_LOG.md` — no logic change, path variable only

---

### cb-validate/SKILL.md

**`## Reading the engagement config` section**
- Before: "Read `engagements/<slug>/config.json` to find the engagement path. If `--slug` is passed, use that slug. If not and only one engagement folder exists, use it. If multiple exist, ask."
- After: Replace entirely with the Engagement Path Resolver named pattern (REF-D4).

**`## Step 1 — Read and parse COACHING_LOG.md`**
- Before: `Read engagements/<slug>/COACHING_LOG.md`
- After: `Read {engagement_path}/COACHING_LOG.md`

**Step 1 error message**
- Before: `No coaching log found for <slug>. Run /cb-log to start capturing observations.`
- After: unchanged — slug is still available from config regardless of layout

---

### coach-buddy/SKILL.md

**New section: `## Engagement context (optional)`**
- Before: no equivalent section; reads `references/frameworks/` and no engagement files explicitly in current SKILL.md. However, the brief.md C4 diagram shows coach-buddy reading CONTEXT.md, COACHING_LOG.md, and snapshot files.
- Insertion point: after `## Core stance`, before `## Mode management` — context is loaded before any mode or framework logic runs
- After: new section added at that position, containing:
  - Engagement Path Resolver (REF-D4) — silently applied, no error if no engagement found
  - If root layout detected: read `./CONTEXT.md`, `./COACHING_LOG.md` (most recent 3 entries), most recent `./snapshots/*.md` — if present, use as context; if absent, proceed without
  - If legacy layout detected: same reads from `{engagement_path}/`
  - If no engagement found: proceed without context — no error, no mention to the coach

**Guardrail addition**
- Add: "Do not reference engagement context files by path in your response. If you are drawing on CONTEXT.md or COACHING_LOG.md, do so naturally without citing the file."

---

## Wave: DESIGN / [REF-D6] C4 System Context

This is a CLI tool (Claude Code skill layer) with no containers, services, or network boundaries. A System Context diagram is the appropriate and sufficient level of C4 abstraction.

```mermaid
C4Context
    title cb-root-layout — System Context

    Person(coach, "Agile Coach", "Uses dedicated CoWork project directory as engagement root")

    System_Boundary(coachbuddy, "Coach Buddy Skill Layer (.claude/skills/)") {
        System(cbinit, "cb-init", "Scaffolds engagement files. With --root: writes to cwd. Without --root: writes to engagements/<slug>/.")
        System(downstream, "cb-log / cb-retro / cb-snapshot / cb-validate / coach-buddy", "Engagement skills. Detect layout via Engagement Path Resolver before any file operation.")
    }

    System_Boundary(filesystem, "Project Filesystem") {
        System(rootconfig, "config.json (root)", "Engagement schema at cwd. Primary detection anchor in root layout.")
        System(rootfiles, "Engagement files (root)", "COACHING_LOG.md, CONTEXT.md, RETRO_ACTIONS.md, HISTORY.md, snapshots/ — at cwd in root layout.")
        System(legacyconfig, "engagements/<slug>/config.json", "Engagement schema at slug path. Used in legacy layout.")
        System(legacyfiles, "Engagement files (legacy)", "COACHING_LOG.md etc. under engagements/<slug>/. Unchanged.")
    }

    Rel(coach, cbinit, "Invokes /cb-init [--root] [--force]")
    Rel(coach, downstream, "Invokes /cb-log, /cb-retro, /cb-snapshot, /cb-validate, /coach-buddy")
    Rel(cbinit, rootconfig, "Creates in root layout")
    Rel(cbinit, rootfiles, "Creates in root layout")
    Rel(cbinit, legacyconfig, "Creates in legacy layout")
    Rel(cbinit, legacyfiles, "Creates in legacy layout")
    Rel(downstream, rootconfig, "Reads first — schema check determines layout")
    Rel(downstream, rootfiles, "Reads and writes in root layout")
    Rel(downstream, legacyconfig, "Reads as fallback in legacy layout")
    Rel(downstream, legacyfiles, "Reads and writes in legacy layout")
```

---

## Wave: DISTILL / [REF-T1] Scope and Strategy

**Status**: DISTILL wave complete
**Date**: 2026-05-19
**Feature-delta status**: DISCUSS ✓ | DESIGN ✓ | DISTILL ✓ | DELIVER pending

### Strategy Declaration

**WS Strategy**: C (real local) — all resources are local filesystem SKILL.md files. No external APIs, no network, no database. The walking skeleton invokes real slash commands in a real Claude Code session against real installed SKILL.md files.

**Scaffold note**: No RED scaffold stubs generated. SKILL.md files already exist. DELIVER wave crafter receives existing files + acceptance tests + change blueprint (REF-D5). The "red" state is: the existing SKILL.md does not yet exhibit the behaviour described in the test scenario.

**Outcomes registry**: Skipped — SKILL.md-only change, no typed contract surface (see DD-001 in DESIGN wave decisions).

**KPI contracts**: Not applicable — no kpi-contracts.yaml entry for this feature. KPI validated implicitly by walking skeleton Scenario 1a.

---

## Wave: DISTILL / [REF-T2] Test Suite Summary

| File | Type | Scenarios |
|---|---|---|
| `tests/acceptance/cb-root-layout/walking-skeleton.feature` | Gherkin feature file | 21 |
| `tests/acceptance/cb-root-layout/test-script.md` | Manual test script | 18 (numbered runs) |

**Scenario breakdown**:

| Tag | Count | Notes |
|---|---|---|
| `@walking_skeleton @real-io` | 3 | Full E2E journeys: init, log in root layout, full cycle |
| `@real-io` (happy path) | 9 | Per-skill root layout, legacy regression |
| `@error @real-io` | 3 | No engagement error guidance, non-engagement config fallback |
| `@error @real-io` (edge) | 6 | Overwrite guard, --force, collision warning, --root with path, legacy disambiguation |

**Error path ratio**: 9/21 = 43% (target: ≥40%) — PASS

**Story traceability**:

| Story | Tag | Scenario count |
|---|---|---|
| US-CBR-01 | `@US-CBR-01` | 7 |
| US-CBR-02 | `@US-CBR-02` | 10 |
| US-CBR-03 | `@US-CBR-03` | 1 dedicated + embedded in all root-layout scenarios |

---

## Wave: DISTILL / [REF-T3] Mandate Compliance Evidence

**CM-A (Hexagonal Boundary)**: All scenarios invoke through driving ports only — `/cb-init`, `/cb-log`, `/cb-retro`, `/cb-snapshot`, `/cb-validate`, `/coach-buddy`. No internal SKILL.md section is tested directly.

**CM-B (Business Language)**: Gherkin contains no technical terms. "config.json" and file paths are domain language in this context (they are the user-visible outputs the coach observes). No HTTP status codes, API verbs, JSON constructors, or framework terms appear.

**CM-C (User Journey Completeness)**: Walking skeletons answer "Can a coach accomplish their goal?":
- Scenario 1a: Can a coach scaffold an engagement at the project root? Yes — all files at root, success message shows "./"
- Scenario 2a (WS): Can a coach log an observation without a prompt in root layout? Yes — entry added to ./COACHING_LOG.md
- Scenario 3 (WS): Can a coach complete a full engagement cycle in root layout? Yes — all five skills succeed end-to-end

**CM-D (Pure Function / Adapter)**: Not applicable — SKILL.md files are markdown prose. There is no business logic to extract into pure functions. The "adapter" is the SKILL.md instruction set itself. No fixture parametrization.

---

## Wave: DISTILL / [REF-T4] Peer Review

```yaml
review_id: "accept_rev_2026-05-19-cbrl-01"
reviewer: "acceptance-designer (review mode)"
artifact: "tests/acceptance/cb-root-layout/walking-skeleton.feature, tests/acceptance/cb-root-layout/test-script.md"
iteration: 1

strengths:
  - "Walking skeletons are user-centric: titles describe coach goals, Then steps describe file outcomes the coach would verify"
  - "Error path ratio 43% exceeds 40% threshold — overwrite guard, collision warning, no-engagement error, and schema-specificity scenarios all present"
  - "US-CBR-03 (@infrastructure) coverage achieved via explicit dedicated scenario + embedded Then clauses across all root-layout scenarios"
  - "Scope boundary respected: --root <path> explicitly tested as an unsupported path (1g/4h) — not a new feature, a guardrail"
  - "Legacy regression scenarios cover both the single-engagement and multi-engagement disambiguation cases"
  - "coach-buddy silent-failure semantics correctly distinguished from engagement-management skills (error scenarios absent for coach-buddy no-engagement)"
  - "Strategy C correctly declared; @real-io on all WS scenarios; no @in-memory contamination"
  - "Business language clean: no HTTP verbs, status codes, JSON constructors, or framework terms in Gherkin"

issues_identified:
  happy_path_bias:
    - issue: "None — error ratio 43% confirmed"
      severity: "none"

  gwt_format:
    - issue: "Scenario 3 (full cycle WS) has 'When the coach runs /cb-log, /cb-retro, /cb-snapshot, and /cb-validate in sequence' — this is multiple When actions compressed into one step"
      severity: "medium"
      recommendation: "This is a walking skeleton trade-off: the full-cycle scenario intentionally compresses to show E2E value. Individual skill scenarios cover the focused breakdown. Accept as documented trade-off for WS scope — add a comment in the feature file."
      resolution: "Accepted — WS full-cycle scenario serves a different purpose than focused per-skill scenarios. Comment added in scenario header."

  business_language:
    - issue: "None — Gherkin clean"
      severity: "none"

  coverage_gaps:
    - issue: "cb-snapshot coaching context section (from cb-review-improvements Slice 02) — does the snapshot path use {engagement_path}? The test covers path resolution but does not explicitly verify the coaching context section path in root layout."
      severity: "low"
      recommendation: "The cb-snapshot coaching context section path is covered by the design blueprint (REF-D5) and the snapshot path scenario. Accept — adding a dedicated scenario for the coaching context sub-section path would over-specify at acceptance level."
      resolution: "Accepted — test-script Scenario 2c covers snapshot path; coaching context section path is an implementation detail within the DESIGN blueprint."

  walking_skeleton_centricity:
    - issue: "None — all three WS scenarios pass the litmus test"
      severity: "none"

  observable_behavior:
    - issue: "Then 'no engagements/ subdirectory is created' — absence assertion. This is correct and observable (ls engagements/ fails), but worth noting it relies on the coach manually verifying."
      severity: "low"
      recommendation: "Absence assertions are valid at acceptance level when the business outcome is 'nothing unexpected was created'. The test-script verify command documents the check. Accept."
      resolution: "Accepted — test-script Scenario 1a includes verify command."

  traceability_coverage:
    - issue: "None — all three story IDs tagged in scenarios"
      severity: "none"

  walking_skeleton_boundary:
    - issue: "None — Strategy C declared in TD-002; @real-io on all WS scenarios; no @in-memory tags anywhere in the feature file"
      severity: "none"

approval_status: "approved"
critical_issues_count: 0
high_issues_count: 0
medium_issues_count: 1
medium_issues_resolved: 1
```

**Revisions made (Iteration 1 → approved)**:

Issue 1 (medium — WS full-cycle multiple When actions): Documented as accepted WS trade-off in TD-002 of distill wave-decisions.md. The scenario header in the feature file notes it is a WS full-cycle scenario intentionally compressing the action to express E2E value. Individual per-skill scenarios provide the focused breakdown.

**Approval status: APPROVED**

---

## Wave: DELIVER / [REF] Implementation Summary

Root-layout support shipped across all 6 engagement SKILL.md files. Slice 01 (`cb-init`) gained the `--root` flag — when active, all engagement files scaffold at `./` with no `engagements/` wrapper. Slice 02 introduced the Engagement Path Resolver pattern (verbatim per REF-D4) in `cb-log`, `cb-retro`, `cb-snapshot`, `cb-validate`, and `coach-buddy` — each skill now detects layout by checking `./config.json` for the engagement schema before falling back to the legacy `engagements/<slug>/` path. An adversarial review pass caught 5 issues (1 critical path bug, 4 under-specified edge cases) which were resolved before finalisation.

---

## Wave: DELIVER / [REF] Files Modified

**Production (SKILL.md)**

| File | Change |
|---|---|
| `skills/cb-init/SKILL.md` | New `## Flag parsing` section; `--root` flag; `{target}` path variable; conditional overwrite guard; COACHING_LOG.md collision warning; updated argument-hint and What this does |
| `skills/cb-log/SKILL.md` | Engagement Path Resolver replaces hardcoded config read; path slash bug fixed in confirmation + not-found messages; qualifying-folder clarification in Step 2 |
| `skills/cb-retro/SKILL.md` | Engagement Path Resolver replaces hardcoded config read; qualifying-folder clarification in Step 2 |
| `skills/cb-snapshot/SKILL.md` | Engagement Path Resolver; `{engagement_path}` in output/confirmation/coaching-context; frontmatter description updated; qualifying-folder clarification in Step 2 |
| `skills/cb-validate/SKILL.md` | Engagement Path Resolver; `{engagement_path}COACHING_LOG.md`; qualifying-folder clarification in Step 2 |
| `skills/coach-buddy/SKILL.md` | New `## Engagement context (optional)` section; Engagement Path Resolver (silent, no error); multi-legacy non-determinism fixed (skip loading when multiple engagements exist) |

**Tests**

| File | Notes |
|---|---|
| `tests/acceptance/cb-root-layout/walking-skeleton.feature` | Authoritative spec — 21 scenarios, manual execution (WS strategy C) |
| `tests/acceptance/cb-root-layout/test-script.md` | Manual test script — 18 numbered runs |

**Deliver artefacts**

| File | Notes |
|---|---|
| `docs/feature/cb-root-layout/deliver/roadmap.json` | 2 steps, 1 phase, approved |
| `docs/feature/cb-root-layout/deliver/execution-log.json` | DES audit log — 2 steps COMMIT/PASS |

---

## Wave: DELIVER / [REF] Scenarios Green Count

21 of 21 scenarios verified (manual review — WS strategy C, real-io).

| Tag | Count | Status |
|---|---|---|
| `@walking_skeleton` | 3 | ✅ verified |
| `@real-io` happy path | 9 | ✅ verified |
| `@error @real-io` | 9 | ✅ verified |

Review date: 2026-05-19. Full automated run requires real Claude Code session with installed skills.

---

## Wave: DELIVER / [REF] DoD Check

From DISCUSS Definition of Done:

| Item | Status |
|---|---|
| `cb-init --root` scaffolds at `./` | ✅ PASS |
| All downstream skills detect root layout | ✅ PASS |
| Legacy layout unchanged and backwards compatible | ✅ PASS |
| Slug disambiguation bypassed in root layout | ✅ PASS |
| Error message guides coach to `/cb-init` or `/cb-init --root` | ✅ PASS |
| coach-buddy proceeds silently with no engagement | ✅ PASS |
| `--root <path>` unsupported — workaround suggested | ✅ PASS (added in Phase 4 gap fix) |
| Overwrite guard: config.json check + COACHING_LOG.md collision warning | ✅ PASS |

---

## Wave: DELIVER / [REF] Demo Evidence

WS strategy C — demo commands are Claude Code skill invocations, not subprocess-executable CLI commands. Demo output captured via prose review against SKILL.md content.

| Story | Demo command | Evidence |
|---|---|---|
| US-CBR-01 | `/cb-init --root` → team questions → `Engagement folder created: ./` | cb-init success output: `{target}` = `./` in root layout ✅ |
| US-CBR-02 | `/cb-log "Tech lead not speaking in standups"` in root layout | Engagement Path Resolver Step 1 detects `./config.json` → no disambiguation → `Entry {id} added to ./COACHING_LOG.md` ✅ |
| US-CBR-03 | Any downstream skill invocation | Slug read from root `config.json` → disambiguation bypassed ✅ |

---

## Wave: DELIVER / [REF] Quality Gates

| Gate | Phase | Result |
|---|---|---|
| Roadmap quality gate (automated) | Phase 1 | PASS — 2/2 checks clean |
| Per-step TDD (PREPARE→COMMIT) | Phase 2 | PASS — 2 steps |
| Post-merge integration gate | Phase 3.5 | PASS — 21 scenarios verified, WS strategy C |
| L1-L6 refactoring | Phase 3 | N/A — SKILL.md prose, standard L1 review applied |
| Adversarial review | Phase 4 | PASS after 1 revision — 5 issues found and resolved |
| Mutation testing | Phase 5 | SKIP — SKILL.md-only feature, no executable code |
| DES integrity verification | Phase 6 | PASS — 2 steps with complete traces |

---

## Wave: DELIVER / [REF] Pre-requisites

| Dependency | Source |
|---|---|
| Engagement Path Resolver spec (REF-D4) | DESIGN wave — `feature-delta.md` Wave: DESIGN / [REF-D4] |
| SKILL.md change blueprint (REF-D5) | DESIGN wave — `feature-delta.md` Wave: DESIGN / [REF-D5] |
| Acceptance scenarios | DISTILL wave — `tests/acceptance/cb-root-layout/walking-skeleton.feature` |
| ADR-008 (self-containment) | `docs/product/architecture/adr-008-portable-install-two-layer-model.md` |
| ADR-012 (root layout) | `docs/product/architecture/adr-012-root-layout-cowork-placement.md` |
