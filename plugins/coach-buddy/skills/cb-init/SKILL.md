---
name: cb-init
description: >-
  Scaffolds a new coaching engagement folder. Creates CONTEXT.md, COACHING_LOG.md,
  RETRO_ACTIONS.md, HISTORY.md, config.json, and a snapshots/ subdirectory under
  engagements/<team-slug>/. Use when starting a new team engagement.
allowed-tools: Read, Write
metadata:
  user-invocable: true
  argument-hint: '[--force] — re-run on an existing slug without confirmation prompt'
---

# cb-init — Engagement Scaffolding

## What this does

Creates a complete engagement folder structure at `engagements/<team-slug>/`. Run once per engagement at the start of a new coaching relationship.

## Setup flow

Ask the following questions in order. Do not ask all at once — one at a time, in sequence.

1. **Team name** — the display name used in file headers (e.g. "Platform Team", "Checkout Squad")
2. **Team slug** — a short, path-safe identifier used in the folder name (kebab-case, e.g. "platform-team", "checkout"). Suggest a slug from the name; let the coach confirm or change it.
3. **Project management tool** — which tool does the team use? Options: Jira / Linear / Shortcut / None (or other — ask for a name)
4. **Tool config** — only if not "None":
   - Jira: project key (e.g. "PLAT") and board ID (numeric, found in the Jira board URL)
   - Linear: team ID (found in team settings)
   - Shortcut: workspace slug (found in the URL)
   - Other: ask for whatever identifier the coach needs to query the tool
5. **WIP age threshold** — how many business days before an in-progress item is flagged as aged? Default: 5. Accept the default unless the coach specifies otherwise.

## Overwrite guard

Before creating any files, check whether `engagements/<slug>/` already exists using the Read tool (attempt to read `engagements/<slug>/config.json`).

- If it **does not exist**: proceed.
- If it **does exist** and the `--force` flag was NOT passed: ask "An engagement folder for `<slug>` already exists. Overwrite it? (yes/no)". If the coach says no, stop. If yes, proceed.
- If it **does exist** and `--force` was passed: proceed without asking.

## Files to create

Create all of the following. Use the exact content in the templates below, substituting `{team_name}`, `{slug}`, `{date}` (today's date as YYYY-MM-DD), and `{tool_type}` as appropriate.

### `engagements/<slug>/config.json`

```json
{
  "version": 1,
  "engagement": {
    "name": "{team_name}",
    "slug": "{slug}",
    "created": "{date}"
  },
  "tool": {
    "type": "{tool_type}",
    "project_key": "{project_key_or_empty_string}",
    "board_id": "{board_id_or_empty_string}",
    "wip_age_threshold_days": {threshold}
  }
}
```

For `tool_type = "none"`: set `project_key` and `board_id` to `""`.

### `engagements/<slug>/CONTEXT.md`

```markdown
# Team Context — {team_name}
<!-- Populate this file with what you know about the team. Update as things change. -->
<!-- Last updated: {date} -->

## Team Purpose
<!-- What this team exists to do. One paragraph. -->

## Team Structure
<!-- Roles, headcount, reporting lines, embedded vs. consultative relationships. -->

## Ways of Working
<!-- Explicit agreements, norms, working style. -->

## Ceremonies
<!-- Sprint length, retro format, planning approach, standup pattern. -->

## Workflow
<!-- How work moves from idea to done. Stages, gates, handoffs. -->

## Boards & Comms
<!-- Where the work lives. Tool links, Slack channels, dashboards. -->

## Repos
<!-- Key repositories and what they contain. -->

## Stakeholders

| Role | Influence | Inclusion notes | External pressures |
|------|-----------|-----------------|-------------------|
| <!-- Name, title --> | <!-- High / Medium / Low --> | <!-- Included in key decisions? Marginalised? Whose voice is missing? --> | <!-- Deadlines, pressures, incentives shaping their behaviour --> |

<!-- Who am I NOT seeing? (individuals, groups, or perspectives absent from your current picture) -->

## Inherited Commitments & Constraints
<!-- What the team inherited. Contracts, timelines, dependencies, technical debt. -->

## Product & Roadmap Context
<!-- Current focus, near-term priorities, known pressures. -->
```

### `engagements/<slug>/COACHING_LOG.md`

```markdown
# Coaching Log — {team_name}
<!-- Safety-II informed. Observations are Work-as-Done, not Work-as-Imagined. -->
<!-- Most-recent entry first. Use /cb-log to add or update entries. -->

## Entry format

---
id: YYYY-MM-DD-NNN
date: YYYY-MM-DD
mode: thinking-partner

**Observed**: [What you saw — Work-as-Done framing, not interpretation]
**Context**: [Ceremony or moment — e.g. sprint review, standup, 1:1]
**Pattern/Signal**: [Tentative label — e.g. "pressure → soldier on", "estimation avoidance"]
**Hypothesis**: If [X continues / changes] then [Y will happen]
**Intervention**: [Named intervention, or "(none yet)"]
**Follow-up**: [What to watch, or question to hold]

---

<!-- Entries below this line -->
```

### `engagements/<slug>/RETRO_ACTIONS.md`

```markdown
# Retro Actions — {team_name}
<!-- Use /cb-retro to add or update actions. -->
<!-- Status values: open | in-progress | done | dropped -->

| # | Action | Owner | Raised | Status | Notes |
|---|--------|-------|--------|--------|-------|
```

### `engagements/<slug>/HISTORY.md`

```markdown
# Team History — {team_name}
<!-- Record structural changes, significant events, and team lineage here. -->
<!-- Most-recent entry first. -->

## Format

`YYYY-MM-DD: [What changed and why]`

---

<!-- History entries below this line -->
```

### `engagements/<slug>/snapshots/` (directory)

Create this directory by writing a placeholder file:

`engagements/<slug>/snapshots/.gitkeep` — empty file. This makes the directory visible and signals that snapshots belong here.

## Success output

After all files are created, print:

```
Engagement folder created: engagements/<slug>/

  CONTEXT.md          — fill in what you know about the team
  COACHING_LOG.md     — use /cb-log to capture observations
  RETRO_ACTIONS.md    — use /cb-retro to track actions
  HISTORY.md          — record structural changes over time
  snapshots/          — /cb-snapshot writes here
  config.json         — tool: {tool_type}

Next: fill in CONTEXT.md, then use /coach-buddy when you're ready to think something through.
```

## Guardrails

- Do not add any coaching observations, example entries, sample data, or fictional content to any file. Templates contain only structural elements and prompts.
- Do not reference any specific team, organisation, tool instance, or engagement in the skill logic.
- Slug must be path-safe: lowercase, letters, numbers, hyphens only. If the coach provides a slug with spaces or special characters, suggest a normalised version and confirm.
