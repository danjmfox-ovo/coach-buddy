<!-- markdownlint-disable MD024 -->
# Slice 01: Root Scaffolding

**Feature**: cb-root-layout
**Slice ID**: slice-01
**Status**: Ready
**Jobs**: cowork-native-setup, engagement-scaffolding
**ADR**: ADR-012

---

## System Constraints

- `--root <path>` (arbitrary target path) is NOT in scope (ADR-012 D4). Only `cb-init --root` (current working directory) is supported in this slice.
- Default behaviour of `cb-init` (without `--root`) is unchanged (ADR-012 D3). No regression risk to existing engagements.
- Overwrite guard must check `config.json` in the target directory (not `engagements/<slug>/config.json`) when `--root` is passed (ADR-012 D5).
- Downstream skill path updates are NOT part of this slice — that is Slice 02. Shipping this slice alone means `cb-init --root` works, but `cb-log` etc. will not yet find the files. Acceptable for staged delivery; do not publish as user-ready until Slice 02 ships.

---

# US-CBR-01: Scaffold engagement at project root with `cb-init --root`

## Problem

Dan is an Agile Coach who has set up a dedicated Claude Code project at `~/teams/advisor-connect` — a directory whose sole purpose is coaching the advisor-connect team. He finds it awkward to have engagement files buried at `engagements/advisor-connect/COACHING_LOG.md` when the whole project is that engagement. He currently works around this by manually moving files to the root after `cb-init` runs, which breaks every downstream skill reference and requires manual path fixes.

## Who

- Agile Coach in a CoWork-pattern project (dedicated directory per engagement)
- Context: running `cb-init` for the first time in a project that IS the engagement
- Motivation: wants engagement files at the root alongside `CLAUDE.md` and `.claude/`, matching the real structure of a single-engagement project

## Elevator Pitch

**Before**: Coach runs `cb-init`, then manually moves `COACHING_LOG.md`, `CONTEXT.md` etc. from `engagements/advisor-connect/` to the project root — breaking all downstream skill path references in the process.

**After**: Coach runs `cb-init --root` and engagement files land directly at the current working directory, ready for use with no post-init restructuring.

**Decision enabled**: Whether to use root layout for this engagement (coach chooses explicitly; default layout unchanged).

## Solution

`cb-init` accepts an optional `--root` flag. When passed, all engagement files are scaffolded at the current working directory with no `engagements/<slug>/` wrapper. The overwrite guard checks for `config.json` at the target directory (cwd). Confirmation output reflects the root path. The `--force` flag continues to work with `--root`.

## Domain Examples

### 1: Happy Path — First init in a dedicated project directory

Dan is in `~/teams/advisor-connect` (an empty Claude Code project). He runs `/cb-init --root`. cb-init asks: team name ("Advisor Connect"), slug ("advisor-connect"), PM tool ("Jira"), project key ("AC"), board ID ("42"), WIP threshold (accepts default 5). Files created at:

```
~/teams/advisor-connect/CONTEXT.md
~/teams/advisor-connect/COACHING_LOG.md
~/teams/advisor-connect/RETRO_ACTIONS.md
~/teams/advisor-connect/HISTORY.md
~/teams/advisor-connect/config.json
~/teams/advisor-connect/snapshots/.gitkeep
```

Output:
```
Engagement folder created: ./

  CONTEXT.md          — fill in what you know about the team
  COACHING_LOG.md     — use /cb-log to capture observations
  RETRO_ACTIONS.md    — use /cb-retro to track actions
  HISTORY.md          — record structural changes over time
  snapshots/          — /cb-snapshot writes here
  config.json         — tool: jira

Next: fill in CONTEXT.md, then use /coach-buddy when you're ready to think something through.
```

### 2: Edge Case — `--root` with `--force` flag on an existing root engagement

Dan runs `/cb-init --root --force` in a project that already has `config.json` at root. The overwrite guard is bypassed (same behaviour as `--force` in standard layout). Files are recreated. Dan uses this to reset scaffolding after a slug typo.

### 3: Error / Boundary — `config.json` already exists at root

Dan runs `/cb-init --root` in a project that already has a `config.json` at root (from a previous init). The overwrite guard fires:

```
An engagement at this location already exists (config.json found). Overwrite it? (yes/no)
```

Dan types "no" — cb-init stops without touching any files.

## UAT Scenarios (BDD)

### Scenario: Engagement files land at project root when --root flag is passed

Given Dan is in `~/teams/advisor-connect` with no existing engagement files
When he runs `/cb-init --root` and provides team name "Advisor Connect", slug "advisor-connect", PM tool "Jira", key "AC", board ID "42", WIP threshold 5
Then `config.json` is created at `~/teams/advisor-connect/config.json`
And `COACHING_LOG.md`, `CONTEXT.md`, `RETRO_ACTIONS.md`, `HISTORY.md` are created at `~/teams/advisor-connect/`
And `snapshots/` directory is created at `~/teams/advisor-connect/snapshots/`
And no `engagements/` subdirectory is created

### Scenario: Success output references root path

Given Dan has just run `/cb-init --root` successfully
When cb-init prints the success summary
Then the summary shows `Engagement folder created: ./`
And it does not mention `engagements/advisor-connect/`

### Scenario: Overwrite guard fires when config.json exists at root

Given `~/teams/advisor-connect/config.json` already exists from a previous init
When Dan runs `/cb-init --root` (without --force)
Then cb-init asks "An engagement at this location already exists (config.json found). Overwrite it? (yes/no)"
And if Dan answers "no", no files are modified
And if Dan answers "yes", files are recreated

### Scenario: --force bypasses overwrite guard in root layout

Given `~/teams/advisor-connect/config.json` already exists
When Dan runs `/cb-init --root --force`
Then cb-init recreates all files without asking for confirmation
And the engagement slug from the previous init is not assumed — questions are asked fresh

### Scenario: Default init (without --root) is unchanged

Given Dan runs `/cb-init` (no --root flag) in `~/teams/advisor-connect`
When cb-init completes
Then engagement files are created at `engagements/<slug>/` (legacy path)
And no files are written to the project root

## Acceptance Criteria

- [ ] `cb-init --root` creates all engagement files at cwd with no `engagements/` wrapper
- [ ] `config.json` is the overwrite guard anchor in root layout (checks `./config.json`, not `engagements/<slug>/config.json`)
- [ ] Success output shows `./` as the engagement path, not `engagements/<slug>/`
- [ ] `--force` flag works in combination with `--root`
- [ ] `cb-init` without `--root` is unaffected — all files still go to `engagements/<slug>/`
- [ ] `--root <path>` (with a path argument) is rejected or ignored — not in scope for this slice

## Outcome KPIs

- **Who**: Agile coach using a dedicated CoWork project directory
- **Does what**: Completes engagement initialisation without post-init file restructuring
- **By how much**: 100% of root-layout inits produce usable file placement with zero manual follow-up steps
- **Measured by**: Manual verification on advisor-connect reference implementation; no post-init migration steps required
- **Baseline**: Currently requires 6+ manual file moves after every init to achieve root layout

## Technical Notes

- `cb-init` SKILL.md requires a new `--root` flag handler before the setup flow begins
- Overwrite guard logic must branch: if `--root`, check `./config.json`; else check `engagements/<slug>/config.json`
- All `engagements/<slug>/` path strings in file creation steps become `./` when `--root` is active
- `snapshots/` subdirectory path becomes `./snapshots/` in root layout
- `--root <path>` parsing: if `--root` is followed by a path-like token, the SKILL.md should note this is not supported yet and suggest `cd <path> && cb-init --root` as a workaround
- Dependency: none — this is the foundation story

## Definition of Ready Validation

| DoR Item | Status | Evidence |
|----------|--------|----------|
| Problem statement clear | PASS | "files buried at engagements/<slug>/" — domain language, specific pain |
| User/persona identified | PASS | Agile Coach, CoWork-pattern project, first-time init |
| 3+ domain examples | PASS | Happy path, --force edge case, overwrite guard error path |
| UAT scenarios (3-7) | PASS | 5 scenarios |
| AC derived from UAT | PASS | Each AC maps to a scenario |
| Right-sized (1-3 days) | PASS | cb-init SKILL.md update only; ~1 day |
| Technical notes | PASS | Flag handler, overwrite guard branch, path substitution |
| Dependencies tracked | PASS | No dependencies; Slice 02 depends on this |

### DoR Status: PASSED
