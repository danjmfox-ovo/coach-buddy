<!-- markdownlint-disable MD024 -->
# Slice 02: Downstream Path Resolution

**Feature**: cb-root-layout
**Slice ID**: slice-02
**Status**: Ready
**Jobs**: cowork-native-setup (US-CBR-02), infrastructure-only (US-CBR-03)
**ADR**: ADR-012
**Dependency**: Slice 01 (US-CBR-01) must be complete before this slice ships

---

## System Constraints

- Detection anchor is `config.json` at project root (ADR-012 D2). No new marker file, no heuristic.
- Detection chain for all downstream skills: (1) check `./config.json` for engagement schema → root layout; (2) else check `engagements/<slug>/config.json` → legacy layout; (3) else surface a clear error or prompt.
- Slug disambiguation (glob `engagements/` and prompt if multiple) is bypassed entirely in root layout. Slug is read directly from root `config.json`.
- Affected skills: cb-log, cb-retro, cb-snapshot, cb-validate, coach-buddy. All must implement the same detection chain.
- This slice must ship atomically — partial rollout (some skills updated, others not) produces a broken engagement cycle.
- Legacy `engagements/<slug>/` layout continues to work after this change. Backwards compatible by design.

---

# US-CBR-02: Downstream skills detect root layout and resolve engagement paths from root

## Problem

Dan has initialised an engagement at `~/teams/advisor-connect/` using `cb-init --root` (Slice 01). He runs `/cb-log` to capture a coaching observation. cb-log reads `engagements/<slug>/config.json` to find the engagement path — which does not exist. It either errors or prompts for a slug, neither of which makes sense in a project with no `engagements/` directory. Dan is forced to either use `--slug advisor-connect` every time (with no `engagements/` directory to even hold that slug) or maintain the legacy layout.

## Who

- Agile Coach who has used `cb-init --root` to set up a CoWork project
- Context: any downstream skill invocation after root-layout init (`/cb-log`, `/cb-retro`, `/cb-snapshot`, `/cb-validate`, `/coach-buddy`)
- Motivation: tools should just work — the presence of `config.json` at root is the declaration; every skill should follow it

## Elevator Pitch

**Before**: After `cb-init --root`, Dan runs `/cb-log` and gets either a path error or a slug disambiguation prompt, because cb-log hardcodes `engagements/<slug>/` as the engagement path and finds nothing there.

**After**: `/cb-log` checks `./config.json` first, finds the engagement schema, and reads/writes `./COACHING_LOG.md` — no prompt, no error, no `--slug` flag required.

**Decision enabled**: Whether root layout is ready for real use (this is the story that makes the init ergonomic actually usable end-to-end).

## Solution

All downstream skills (cb-log, cb-retro, cb-snapshot, cb-validate, coach-buddy) implement a two-step path resolution check at the start of their execution:

1. Attempt to read `./config.json`. If it exists and contains the engagement schema (`version`, `engagement.slug`), treat this as root layout and resolve all engagement file paths relative to `./`.
2. Otherwise, proceed with the existing `engagements/<slug>/config.json` discovery logic (unchanged).

If neither path yields a `config.json`, existing error/prompt behaviour is unchanged.

## Domain Examples

### 1: Happy Path — cb-log writes to root after root-layout init

Dan is in `~/teams/advisor-connect`. `config.json` is at `~/teams/advisor-connect/config.json`. He runs `/cb-log "I noticed the tech lead is not speaking in standups"`. cb-log reads `./config.json`, extracts slug `advisor-connect`, and prepends the new entry to `~/teams/advisor-connect/COACHING_LOG.md`. No disambiguation prompt. No `--slug` flag needed.

### 2: Edge Case — Legacy engagement in the same directory structure

Dan is in `~/coaching-workspace` which contains `engagements/platform-team/config.json` (legacy layout). He runs `/cb-log`. cb-log checks `./config.json` — not found. Falls back to `engagements/` discovery. Finds one engagement. Proceeds as before. Zero behaviour change for legacy layout.

### 3: Error / Boundary — Neither root nor legacy config found

Dan is in a directory with no `config.json` and no `engagements/` folder. He runs `/cb-log`. Detection chain finds nothing in either location. cb-log surfaces:

```
No engagement found at ./config.json or engagements/<slug>/config.json.
Run /cb-init to create an engagement, or /cb-init --root to scaffold at this location.
```

## UAT Scenarios (BDD)

### Scenario: cb-log resolves root layout transparently

Given Dan is in `~/teams/advisor-connect`
And `~/teams/advisor-connect/config.json` contains a valid engagement schema (slug: "advisor-connect")
When he runs `/cb-log "Tech lead is not speaking in standups"`
Then cb-log reads `./config.json` without being prompted for a slug
And the new entry is prepended to `~/teams/advisor-connect/COACHING_LOG.md`
And the confirmation shows `Entry 2026-05-19-001 added to ./COACHING_LOG.md`

### Scenario: cb-retro resolves root layout transparently

Given `~/teams/advisor-connect/config.json` is the only engagement config
When Dan runs `/cb-retro` with retro output pasted
Then cb-retro writes extracted actions to `~/teams/advisor-connect/RETRO_ACTIONS.md`
And no slug disambiguation prompt appears

### Scenario: cb-snapshot resolves root layout transparently

Given `~/teams/advisor-connect/config.json` is the only engagement config
When Dan runs `/cb-snapshot`
Then cb-snapshot writes the snapshot to `~/teams/advisor-connect/snapshots/2026-05-19-board.md`
And no slug disambiguation prompt appears

### Scenario: Legacy layout continues to work after downstream update

Given Dan is in `~/coaching-workspace` with `engagements/platform-team/config.json` (no root-level config.json)
When he runs `/cb-log "Planning was long this sprint"`
Then cb-log reads `engagements/platform-team/config.json` via the existing discovery path
And the entry is written to `engagements/platform-team/COACHING_LOG.md`
And behaviour is identical to before this change

### Scenario: Clear error when no engagement config is found in either location

Given Dan is in a directory with neither `./config.json` nor any `engagements/*/config.json`
When he runs `/cb-log "Something I noticed"`
Then cb-log outputs a message indicating no engagement was found
And it suggests running `/cb-init` or `/cb-init --root`

## Acceptance Criteria

- [ ] All five skills (cb-log, cb-retro, cb-snapshot, cb-validate, coach-buddy) implement the two-step detection chain
- [ ] Detection order: `./config.json` first; `engagements/<slug>/config.json` second
- [ ] In root layout, all file reads and writes target `./` not `engagements/<slug>/`
- [ ] In root layout, no slug disambiguation prompt is shown
- [ ] Legacy layout behaviour is unchanged (no regression)
- [ ] When neither layout is found, error message suggests the appropriate init command

## Outcome KPIs

- **Who**: Agile coach who has used `cb-init --root`
- **Does what**: Completes a full engagement cycle (init → log → retro → snapshot → coach-buddy) without path errors or disambiguation prompts
- **By how much**: Zero path errors or unexpected prompts across all five downstream skills in root layout
- **Measured by**: End-to-end test on advisor-connect reference implementation: init → log → retro → snapshot → coach-buddy — all succeed
- **Baseline**: Currently all downstream skills fail in root layout (hardcoded `engagements/<slug>/` path)

## Technical Notes

- Each affected SKILL.md needs a "Reading the engagement config" section update (currently only cb-log has the explicit path logic documented; others may handle it implicitly)
- `coach-buddy` SKILL.md: check whether it has its own path resolution or defers to `engagements/` assumption. Spot-check required in DELIVER wave.
- cb-validate: confirm what it validates (likely config.json schema) — detection chain applies equally
- Detection check must distinguish coach-buddy-schema `config.json` from any other `config.json` at root. Check for presence of `version` and `engagement.slug` fields as schema signal (per ADR-012 D2 rationale)
- Dependency: US-CBR-01 must be complete (root `config.json` must exist before detection can be verified)

---

# US-CBR-03: Slug disambiguation is bypassed in root layout

**Tags**: @infrastructure
**job_id**: infrastructure-only
**infrastructure_rationale**: Slug disambiguation bypass has no user-visible surface. The coach experiences only the absence of a prompt — which is a consequence of root layout detection (US-CBR-02), not a separately invocable behaviour. This story documents the internal logic change and its acceptance criteria for the DELIVER wave. No Elevator Pitch is required per standing rule for `@infrastructure` stories.

## Problem

The existing slug disambiguation logic (glob `engagements/` and prompt if multiple slugs exist) would run unnecessarily in root layout, where there is by definition exactly one engagement. The prompt is confusing and incorrect in this context — there is no `engagements/` directory to glob.

## Who

- Internal: the path resolution layer shared by all downstream skills
- Context: any skill invocation in root layout
- Effect: no disambiguation prompt is shown; slug is read directly from root `config.json`

## Solution

When root layout is detected (step 1 of the detection chain in US-CBR-02 returns a match), the slug disambiguation step is skipped entirely. The slug value is read from `config.json`.engagement.slug.

## Domain Examples

### 1: Root layout — no disambiguation

Dan is in `~/teams/advisor-connect`. `./config.json` contains `"slug": "advisor-connect"`. cb-log invoked. Slug resolved to "advisor-connect" directly from config. No glob of `engagements/`. No prompt.

### 2: Legacy layout with one engagement — existing behaviour preserved

Dan is in `~/coaching-workspace` with only `engagements/platform-team/`. cb-log finds one engagement. No prompt (existing behaviour — single engagement skips disambiguation). Unchanged.

### 3: Legacy layout with multiple engagements — existing behaviour preserved

Dan is in `~/coaching-workspace` with `engagements/platform-team/` and `engagements/checkout/`. cb-log finds two engagements, no `--slug` flag. Disambiguation prompt shown. Unchanged.

## UAT Scenarios (BDD)

### Scenario: Slug read from root config.json without disambiguation in root layout

Given `~/teams/advisor-connect/config.json` exists with `engagement.slug: "advisor-connect"`
And there is no `engagements/` directory
When any downstream skill resolves the engagement slug
Then the slug "advisor-connect" is returned directly from root `config.json`
And no disambiguation prompt is shown
And no `engagements/` directory is globbed

### Scenario: Multiple legacy engagements still trigger disambiguation

Given `engagements/platform-team/config.json` and `engagements/checkout/config.json` both exist
And there is no root-level `config.json`
When cb-log is invoked without `--slug`
Then the disambiguation prompt appears listing "platform-team" and "checkout"
And behaviour is identical to before this change

## Acceptance Criteria

- [ ] When root layout is detected, slug is read from `./config.json` engagement.slug — no glob, no prompt
- [ ] Existing slug disambiguation logic is preserved intact for legacy layout
- [ ] Detection chain in US-CBR-02 gates the disambiguation bypass (not a separate flag or config key)

## Technical Notes

- This story is fully covered by US-CBR-02's detection chain implementation. No additional SKILL.md changes are required beyond those specified in US-CBR-02.
- If implementation of US-CBR-02 naturally handles slug resolution as part of the detection chain, US-CBR-03 may be verified as a side-effect scenario rather than a separate implementation task.
- No infrastructure_rationale needed for the disambiguation logic itself — it is a consequence of the detection chain, not a new behaviour.

## Definition of Ready Validation — US-CBR-02

| DoR Item | Status | Evidence |
|----------|--------|----------|
| Problem statement clear | PASS | "cb-log errors after root-layout init" — specific, observable pain |
| User/persona identified | PASS | Agile Coach who has used cb-init --root; all 5 downstream skills affected |
| 3+ domain examples | PASS | cb-log happy path, legacy layout unchanged, no-config error |
| UAT scenarios (3-7) | PASS | 5 scenarios |
| AC derived from UAT | PASS | Each AC maps to a scenario |
| Right-sized (1-3 days) | PASS | 5 SKILL.md updates; uniform pattern; ~2 days |
| Technical notes | PASS | Detection chain, schema signal, SKILL.md sections to update |
| Dependencies tracked | PASS | Depends on US-CBR-01 (Slice 01) |

### DoR Status: PASSED

## Definition of Ready Validation — US-CBR-03

| DoR Item | Status | Evidence |
|----------|--------|----------|
| Problem statement clear | PASS | Disambiguation logic must not run in root layout |
| User/persona identified | PASS | Internal path resolution layer |
| 3+ domain examples | PASS | Root layout bypass, single-legacy unchanged, multi-legacy unchanged |
| UAT scenarios (3-7) | PASS | 2 scenarios (infrastructure story — minimal surface) |
| AC derived from UAT | PASS | Each AC maps to a scenario |
| Right-sized | PASS | Implemented as part of US-CBR-02 detection chain |
| Technical notes | PASS | Noted as consequence of US-CBR-02; no separate changes |
| Dependencies tracked | PASS | Depends on US-CBR-02 |

### DoR Status: PASSED

---

## Slice 02 Outcome KPIs

### Objective

All downstream skills operate transparently in root layout by the time Slice 02 ships, enabling a complete coaching cycle without path errors or disambiguation prompts.

### KPI Table

| # | Who | Does What | By How Much | Baseline | Measured By | Type |
|---|-----|-----------|-------------|----------|-------------|------|
| 1 | Agile coach in CoWork project | Completes init → log → retro → snapshot cycle without errors | 100% success (zero path failures) | 0% — all downstream skills fail in root layout today | End-to-end test on advisor-connect reference implementation | Leading |
| 2 | Agile coach in legacy layout | Continues using engagement skills without behaviour change | 0% regression (no new prompts, no path errors) | 100% pass rate | Regression test on existing engagement | Guardrail |

### Metric Hierarchy

- **North Star**: Full engagement cycle completes in root layout without intervention
- **Leading Indicators**: Each downstream skill resolves root path on first invocation
- **Guardrail Metrics**: Legacy layout regression rate = 0%
