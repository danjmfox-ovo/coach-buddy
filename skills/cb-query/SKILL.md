---
name: cb-query
description: >-
  Retrieves a consolidated engagement health summary from COACHING_LOG.md and RETRO_ACTIONS.md.
  Surfaces open retro actions, open/deferred hypotheses, last capture and retro dates, and optional board WIP age.
  Use before sessions for a quick orientation, or by a PA agent for structured data with --format json.
metadata:
  user-invocable: true
  argument-hint: '[--slug TEAM-SLUG] [--since ISO-DATE] [--format json]'
---

# cb-query — Engagement Health Query

## What this does

Reads `COACHING_LOG.md` and `RETRO_ACTIONS.md` from an engagement folder. Applies the Named Extraction Grammar to surface: open retro actions, open and deferred hypotheses, last capture date, and last retro date. Optionally queries the board MCP for WIP age data. Returns readable prose by default, or structured JSON with `--format json`.

---

## Reading the engagement config

**Step 1 — Check for root layout**

Attempt to read `./config.json`. If the file exists and contains both a `version` field and an `engagement.slug` field, this is a root-layout engagement:
- Set `engagement_path` = `./`
- Set `slug` = value of `engagement.slug`
- Skip Step 2 and proceed directly to the skill's main logic using `engagement_path`

**Step 2 — Fall back to legacy layout**

If `./config.json` is absent or does not contain the engagement schema, look for an engagement under `engagements/`:
- If `--slug <team-slug>` was passed, use that slug directly: set `engagement_path` = `engagements/<slug>/`
- If no slug was passed and exactly one folder exists under `engagements/` with a `config.json`, use that (folders without a `config.json` are not counted as candidates)
- If multiple qualifying folders exist and no slug was specified, ask: "Which engagement to query? (available: `<list of slugs>`)"

**Step 3 — No engagement found**

If neither Step 1 nor Step 2 yields a config:
- If `--format json` was passed, emit the following and stop:
  ```json
  {"status":"error","team":"<value of --slug arg, or 'unknown' if no slug was given>","error":"No engagement found at ./config.json or engagements/<slug>/config.json"}
  ```
- Otherwise, surface a clear prose error naming the slug and explaining the folder was not found. Do not suggest running `/cb-init` in the error message.

---

## Reading the --since window

- `--since` defaults to 14 days before today (i.e. `today - 14 days`)
- Accepts an ISO date override: `--since 2026-01-01`
- The `--since` window filters which **log entries** are included in the recent captures section and summary counts
- The `--since` window does NOT close hypotheses. A hypothesis from 30 days ago with no Validation or with `Validation: open/deferred` is still surfaced as open, with a note that it falls outside the recent window

---

## Named Extraction Grammar (ADR-014)

Apply these rules after reading both engagement files. The grammar is the stable interface between the deterministic entry format (cb-log-deterministic-writes) and the query output.

### Open Retro Actions (from RETRO_ACTIONS.md)

Read the RETRO_ACTIONS.md table. For each row:
- If the `Evidenced` column value is exactly `yes` (case-insensitive): classify as **evidenced** — do NOT list as open
- If the `Status` column value is `done` (case-insensitive): classify as **done** — do NOT list as open
- Otherwise: classify as **open**

An open action has: `description` (from the action text column), `owner` (from the owner column), `evidenced: false`

If all actions are evidenced or done: note "No open retro actions."

### Open and Deferred Hypotheses (from COACHING_LOG.md)

For each log entry (frontmatter block between `---` delimiters):
1. Read the `**Hypothesis**` body field. Skip entries where Hypothesis is `(to fill)` or absent.
2. Check for a `**Validation**` body field:
   - Field absent OR field value is `open`: classify as **open**
   - Field value is `deferred`: classify as **deferred**
   - Field value is `confirmed` or `rejected`: skip — do not surface
3. The `--since` window does NOT affect whether a hypothesis is open. A hypothesis is open if its Validation status says so, regardless of the entry's date.
4. For hypotheses outside the `--since` window: include them in the open list with a note "(outside recent window — entry date: {date})"

Each hypothesis has: `text` (the Hypothesis field value), `status` (open/deferred), `entry_id` (from `id:` frontmatter), `date` (from `date:` frontmatter)

### Last Capture Date

The `date:` frontmatter field of the most recent entry in COACHING_LOG.md (regardless of --since window).

### Last Retro Date

The most recent date value in RETRO_ACTIONS.md (from the Date column, or the table's last modified date if no date column). Null if no retro entries exist.

### Signal Summary (engagement-health scope only — DW-2)

A 2–3 sentence summary drawn exclusively from engagement-file signals:
- Hypothesis age: how many hypotheses are open and how long the oldest has been open
- Action evidenced ratio: what fraction of retro actions have been evidenced
- WIP age signal: whether any WIP items are aged beyond threshold (if board data available)

The signal summary MUST NOT reference calendar events, chat messages, Jira tickets (by name), or any signal source outside COACHING_LOG.md and RETRO_ACTIONS.md. WIP age from the board MCP is an acceptable input only as an aggregate signal (e.g. "3 items aged >5 days"), not as ticket-specific detail.

---

## Board MCP (optional)

After resolving `engagement_path`, read `board_tool` from `config.json`:
- If `board_tool` is absent or empty: skip board MCP call. Set `wip_aged = []`. Set degraded reason: "No board tool configured."
- If `board_tool` is `jira` or `linear`: attempt to call the relevant MCP to retrieve WIP items with age > `wip_age_threshold_days` (from `config.json`, default 5).
  - On success: populate `wip_aged` with items containing `title` and `age_days` (positive integer)
  - On failure (MCP unavailable, error, timeout): set `wip_aged = []`. Set degraded reason: "Board MCP unavailable."

---

## Output — Prose (default, no --format json)

Produce a readable summary with the following sections. Omit the board section entirely if `wip_aged` would be empty (no board_tool configured or MCP unavailable) — do not show an error about missing board configuration.

```
## Engagement Health — {slug}
*Summary for the last {N} days (since {since-date})*

### Open Retro Actions
{list of open actions with owner, or "No open retro actions."}

### Coaching Hypotheses
**Open:**
{list of open hypotheses with entry date, or "None."}

**Deferred:**
{list of deferred hypotheses with entry date, or "None."}

### Dates
- Last capture: {last_capture}
- Last retro: {last_retro or "No retro entries"}

### WIP Age  ← omit this section entirely if no board data
{list of aged WIP items with age_days, or "No aged WIP items."}
```

---

## Output — JSON (--format json)

When `--format json` is present, emit ONLY the JSON object to the response — no prose before or after.

**status: ok** — path resolved, files read successfully, board data available or not attempted:

```json
{
  "status": "ok",
  "team": "{slug}",
  "open_actions": [
    {"description": "...", "owner": "...", "evidenced": false}
  ],
  "open_hypotheses": [
    {"text": "...", "status": "open", "entry_id": "...", "date": "YYYY-MM-DD"}
  ],
  "last_capture": "YYYY-MM-DD",
  "last_retro": "YYYY-MM-DD",
  "wip_aged": [
    {"title": "...", "age_days": 7}
  ],
  "signal_summary": "..."
}
```

**status: degraded** — path resolved and files read, but board MCP unavailable or not configured:

```json
{
  "status": "degraded",
  "team": "{slug}",
  "open_actions": [...],
  "open_hypotheses": [...],
  "last_capture": "YYYY-MM-DD",
  "last_retro": "YYYY-MM-DD",
  "wip_aged": [],
  "signal_summary": "...",
  "warnings": ["Board MCP unavailable." ]
}
```

All non-wip fields are populated normally in a degraded response. The signal_summary may note that WIP age data was unavailable.

**status: error** — engagement not found:

```json
{
  "status": "error",
  "team": "{slug or 'unknown'}",
  "error": "No engagement found at ./config.json or engagements/<slug>/config.json"
}
```

No other fields (open_actions, open_hypotheses, signal_summary, etc.) are present on an error response.

---

## Guardrails

- cb-query is read-only. It does not write to any file.
- The signal_summary field is scoped to engagement-health domain only (DW-2). Do not include calendar, chat, or external system signals.
- Do not suggest running `/cb-init` in error messages.
- `wip_aged` items must include both `title` and `age_days` fields when populated from board MCP.
- The `evidenced` field on open_actions items is a boolean: `true` only when the Evidenced column is exactly `yes`; `false` otherwise.
