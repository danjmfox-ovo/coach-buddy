---
name: cb-snapshot
description: >-
  Writes a dated board snapshot to engagements/<team-slug>/snapshots/YYYY-MM-DD-board.md.
  Four sections: WIP, Progress (last 14 days), Runway, Waiting. Age-flags WIP items beyond
  threshold. Prints a two-sentence risk read in chat. Use before coaching conversations.
allowed-tools: Read, Write
metadata:
  user-invocable: true
  argument-hint: '[--slug <team-slug>] [--days <lookback-days>]'
---

# cb-snapshot — Board Snapshot

## What this does

Queries the team's project management tool (or accepts a manual paste), structures the current work state into four sections, writes a dated file to the engagement's `snapshots/` folder, and prints a brief risk read in the conversation.

## Reading the engagement config

Read `engagements/<slug>/config.json`.

- If `--slug <team-slug>` is passed, use that slug.
- If not passed and only one engagement folder exists, use it.
- If multiple exist and no slug is specified, ask which engagement.

Extract from config:
- `tool.type` — determines which section below to follow
- `tool.project_key` — used in queries
- `tool.board_id` — used in queries (Jira)
- `tool.wip_age_threshold_days` — default 5 if absent
- `engagement.name` — used in the snapshot header

Lookback window for Progress section: `--days` flag if passed, otherwise 14.

---

## Tool: Jira

Follow this section when `tool.type = "jira"`.

Use the available Jira MCP tools to run the following queries. Adapt tool names to whatever Jira MCP is installed — the intent of each query is described; the exact MCP call depends on your environment.

**WIP** — items currently in progress:
- Query: issues in the open sprint for `project_key`, status = "In Progress" (or equivalent active status)
- Sort by: last updated, descending
- Fields needed: issue key, summary, parent epic summary, parent initiative (if available), assignee, date moved to current status (for age calculation)

**Progress** — items completed in the last `{lookback}` days:
- Query: issues in `project_key`, status = Done (or equivalent), updated within last `{lookback}` days
- Sort by: resolved date, descending
- Fields needed: issue key, summary, parent epic, resolved date

**Runway** — items ready to be picked up:
- Query: issues in `project_key`, sprint = open sprint, status in ("To Do", "Ready", "Refined") (or equivalent not-yet-started statuses)
- Sort by: priority, descending
- Fields needed: issue key, summary, parent epic, priority

**Waiting** — backlog items not in any active sprint:
- Query: issues in `project_key`, sprint not in openSprints(), status != Done
- Sort by: priority, descending
- Limit: top 10 by priority (full backlog is noise for coaching)
- Fields needed: issue key, summary, parent epic

**Age calculation for WIP:**
For each WIP item, calculate days since status changed to "In Progress" (or since last update if status date is unavailable). If days > `wip_age_threshold_days`, mark with ⚠.

---

## Tool: Linear

Follow this section when `tool.type = "linear"`.

Use the available Linear MCP tools to run equivalent queries using `tool.project_key` as the team ID.

- **WIP**: issues in the current cycle, state type = "started"
- **Progress**: issues completed in the last `{lookback}` days
- **Runway**: issues in the current cycle, state type = "unstarted"
- **Waiting**: backlog issues not in any cycle

Age calculation: days since issue moved to started state.

---

## Tool: none (manual paste)

Follow this section when `tool.type = "none"` or when no MCP is available.

Ask the coach: "No board tool is configured. Paste your current board state and I'll structure it — WIP items first, then anything recently done, then what's queued."

Accept freeform paste. Structure it into the four sections using the coach's own categorisation. If items are ambiguous (unclear if WIP or queue), ask once for clarification. Do not fabricate items.

---

## Output format

Write the snapshot to `engagements/<slug>/snapshots/{YYYY-MM-DD}-board.md`:

```markdown
# Board Snapshot — {engagement.name}
Generated: {YYYY-MM-DD}
Tool: {tool.type} | Project: {project_key}

## WIP (In Progress)

- **[{initiative}]** {epic summary}
  - {issue key}: {summary} | Age: {N} days{" ⚠" if aged}
  - {issue key}: {summary} | Age: {N} days

## Progress (Last {lookback} days)

- **[{initiative}]** {epic summary}
  - {issue key}: {summary} | Done: {YYYY-MM-DD}

## Runway (Ready / Refinement)

- **[{initiative}]** {epic summary}
  - {issue key}: {summary}

## Waiting (Backlog — top 10)

- **[{initiative}]** {epic summary}
  - {issue key}: {summary}
```

**Hierarchy**: show Initiative → Epic → Story where data is available. If initiative level is not available from the tool, show Epic → Story. Use `[No Epic]` for orphaned stories.

**Empty sections**: if a section has no items, write `_(none)_` rather than omitting the section header.

---

## Risk read (in chat, not in the file)

After writing the file, print two sentences in the conversation:

1. The most significant flow signal from the snapshot (WIP volume, age flags, throughput gap, or empty runway).
2. One question worth holding before the coaching conversation.

Example:
> "9 items in WIP with 3 age-flagged, against 4 completions in the last 14 days — the team is accumulating faster than completing. Worth asking what's blocking resolution rather than starting on root causes."

Keep it factual and concise. Do not diagnose the team.

---

## Confirmation output

After writing the file, print:

```
Snapshot written: engagements/<slug>/snapshots/{YYYY-MM-DD}-board.md
  WIP: {N} items ({M} age-flagged)
  Progress (14d): {N} items
  Runway: {N} items
  Waiting: {N} items (top 10)
```

Then the two-sentence risk read.

---

## Guardrails

- Do not write team names, issue titles, assignee names, or any board content into the skill logic itself. The snapshot file is generated at runtime from live data.
- Do not fabricate board items if the tool returns no data for a section. Write `_(none)_`.
- Do not interpret WIP age flags as problems in the file — they are flags, not diagnoses. Interpretation belongs in the coaching conversation.
- The risk read is observational. It names a pattern; it does not explain it.
