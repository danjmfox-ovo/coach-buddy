---
name: cb-snapshot
description: >-
  Writes a dated board snapshot to engagements/[team-slug]/snapshots/YYYY-MM-DD-board.md.
  Four sections: WIP, Progress (last 14 days), Runway, Waiting. Age-flags WIP items beyond
  threshold. Prints a two-sentence risk read in chat. Use before coaching conversations.
metadata:
  user-invocable: true
  argument-hint: '[--slug [team-slug]] [--days [lookback-days]]'
---

# cb-snapshot — Board Snapshot

## What this does

Queries the team's project management tool (or accepts a manual paste), structures the current work state into four sections, writes a dated file to the engagement's `snapshots/` folder, and prints a brief risk read in the conversation.

## Reading the engagement config

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

Extract from `{engagement_path}config.json`:
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

Write the snapshot to `{engagement_path}snapshots/{YYYY-MM-DD}-board.md`:

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
Snapshot written: {engagement_path}snapshots/{YYYY-MM-DD}-board.md
  WIP: {N} items ({M} age-flagged)
  Progress (14d): {N} items
  Runway: {N} items
  Waiting: {N} items (top 10)
```

Then the two-sentence risk read.

---

## Coaching context (from COACHING_LOG.md)

After writing the snapshot file and printing the risk read, append a coaching context
section if `COACHING_LOG.md` exists for the engagement.

**Check**: attempt to read `{engagement_path}COACHING_LOG.md`.

- If the file does not exist or is empty (header only, no entries): skip this section entirely. No error.
- If the file exists with entries: select up to 3 entries, most-recent-first by `date:` field.

**Selection**: take the 3 entries with the most recent `date:` values. If fewer than 3 entries
exist, take all. Entries with `**Hypothesis**: (to fill)` are included (show observation only).

**Append to the snapshot file** (after the `## Waiting` section):

```markdown
## Coaching context

_Most recent entries from COACHING_LOG.md — use /cb-validate to close hypothesis loops_

**{YYYY-MM-DD}** {if mode present and not thinking-partner: `[{mode}]` }
Observed: {first 120 characters of **Observed** value, trimmed}
Hypothesis: {first 120 characters of **Hypothesis** value, or "(not yet written)" if (to fill)}

```

Repeat for each of the up to 3 entries, separated by a blank line. No `---` dividers.

If the `**Hypothesis**` value is `(to fill)`, write: `Hypothesis: (not yet written)`.

**Do not** append the section to the chat risk read. The risk read (two sentences in chat)
is unchanged. The coaching context appears only in the written file.

---

## Guardrails

- Do not write team names, issue titles, assignee names, or any board content into the skill logic itself. The snapshot file is generated at runtime from live data.
- Do not fabricate board items if the tool returns no data for a section. Write `_(none)_`.
- Do not interpret WIP age flags as problems in the file — they are flags, not diagnoses. Interpretation belongs in the coaching conversation.
- The risk read is observational. It names a pattern; it does not explain it.
- The coaching context section is additive — it never replaces or modifies board data.
- Do not include full log entries in the snapshot. Summaries only (120 char truncation).
