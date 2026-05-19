---
name: cb-log
description: >-
  Captures or updates a structured coaching observation in COACHING_LOG.md.
  Safety-II informed: observations are Work-as-Done, hypotheses are testable If/Then.
  Use after any team session, ceremony, or interaction worth tracking.
metadata:
  user-invocable: true
  argument-hint: '[observation] [--update [id] [field] [value]] [--mode [value]] [--slug [team-slug]]'
---

# cb-log — Coaching Log Capture

## What this does

Prepends a new entry to `COACHING_LOG.md`, or updates a field on an existing entry. Quick capture is the default — provide an observation and context, the rest scaffolds as `(to fill)`.

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
- If multiple qualifying folders exist and no slug was specified, ask: "Which engagement? (available: `<list of slugs>`)"

**Step 3 — No engagement found**

If neither Step 1 nor Step 2 yields a config, surface:
> "No engagement found at `./config.json` or `engagements/<slug>/config.json`. Run `/cb-init` to create an engagement, or `/cb-init --root` to scaffold at this location."

## Team Context Resolver

After resolving `engagement_path` (Steps 1–3 above), run this resolver to load optional calendar-magick team context.

```
TEAM CONTEXT RESOLVER
─────────────────────
Step 1 — Check for team_config reference
  Read `team_config.path` from the engagement config.json already loaded.
  If the field is absent: team context is not configured — skip Steps 2–3 entirely.
  Set `teams_yaml_path` = resolve `team_config.path` relative to `engagement_path`.

Step 2 — Read teams.yaml
  Attempt to read the file at `teams_yaml_path`.
  If the file cannot be read (not found, permission error, unreadable content):
    Log nothing. Team context is unavailable — skip Step 3 entirely. Continue skill.
  Parse only the following fields:
    team.name, team.cadence, team.sprint_length_weeks, team.timezone, team.members

Step 3 — Expose team context
  Set `team_cadence`      = team.cadence (string; absent → null)
  Set `team_sprint_weeks` = team.sprint_length_weeks (integer; absent → null)
  Set `team_members`      = team.members array (absent or empty → empty array)
  Any other fields in teams.yaml are ignored.
```

If the resolver completes without team context (Step 1 or Step 2 short-circuit), `team_members` remains an empty array. The skill continues normally with no member hint and no error.

---

## Two modes

### Mode 1: New entry (default)

Invoked as: `/cb-log <observation text>` or just `/cb-log` (then ask for the observation).

**Step 1 — Capture observation and context**

Ask (or use what was provided):
- What did you observe? (Work-as-Done — what actually happened, not what should have happened)
- In what context? (ceremony or moment — e.g. "sprint review", "standup", "1:1 with tech lead", "reviewing the board")

**Step 1a — Capture session participants (optional)**

If `team_members` is non-empty (loaded by Team Context Resolver above):
- Present the member hint as part of the "who was in the session?" question:
  > "Who was in the session? Team roster: `<name (ROLE), name (ROLE), ...>` — enter names or press Enter for full team."
- If the coach presses Enter without input: use all members from `team_members` as the participants list. Write the `participants` field as a comma-separated list of names.
- If the coach types names: use exactly what the coach typed. Names are not validated against the roster — the hint is informational only.

If `team_members` is empty (team context absent or unreadable): ask "Who was in the session?" without the roster hint. The `participants` field is omitted from the entry (current behaviour preserved).

**Step 1b — Capture mode (optional)**

If `--mode <value>` was passed, validate it against the allowed values:
`thinking-partner` | `advisory` | `facilitation`

If the value is unrecognised, reject immediately:
> "Mode must be one of: thinking-partner, advisory, facilitation"

If `--mode` was not passed, default to `thinking-partner`. Do not ask.

**Step 2 — Generate entry ID**

Read the current `COACHING_LOG.md`. Count any existing entries for today (YYYY-MM-DD). Assign ID: `{YYYY-MM-DD}-{NNN}` where NNN is a zero-padded sequence starting at 001. If today has no entries, use 001.

**Step 3 — Ask whether to fill full entry or quick capture**

Ask: "Want to fill in the full entry now, or capture quickly and refine later?" 

- **Quick capture**: write Observed + Context from what the coach provided; scaffold all other fields as `(to fill)`.
- **Full entry**: ask for each remaining field in sequence:
  - Pattern/Signal: "What pattern or signal does this suggest? (tentative label — it's a hypothesis, not a diagnosis)"
  - Hypothesis: "If you had to write a testable hypothesis: If [what continues or changes] then [what will happen]?"
  - Intervention: "Any intervention in mind? (or leave as 'none yet')"
  - Follow-up: "What will you watch for? What question are you holding?"

**Step 4 — Prepend entry to COACHING_LOG.md**

Read the current file. Insert the new entry immediately after the `<!-- Entries below this line -->` comment. Do not append — entries are most-recent-first.

Entry format:

```markdown
---
id: {id}
date: {YYYY-MM-DD}
mode: {mode}
participants: {comma-separated names — omit this line entirely when no participants were captured}

**Observed**: {observed}
**Context**: {context}
**Pattern/Signal**: {pattern or "(to fill)"}
**Hypothesis**: {hypothesis or "(to fill)"}
**Intervention**: {intervention or "(none yet)"}
**Follow-up**: {follow_up or "(to fill)"}

---
```

The `participants:` line is optional. Write it only when participants were captured in Step 1a. When omitted, the entry remains valid — existing entries without `participants:` are unaffected.

**Step 5 — Confirm**

Print: `Entry {id} added to {engagement_path}COACHING_LOG.md`

If any fields are `(to fill)`, add: `Run /cb-log --update {id} <field> <value> to refine.`

---

### Mode 2: Update existing entry

Invoked as: `/cb-log --update <id> <field> <value>`

Valid field names: `observed`, `context`, `pattern`, `hypothesis`, `intervention`, `followup`

Steps:
1. Read `COACHING_LOG.md`.
2. Find the entry with matching `id:` in the frontmatter.
3. Update the specified field's value in place. Do not change any other field.
4. Write the updated file.
5. Print: `Entry {id} updated — {field} revised.`

If the entry ID is not found, print: `Entry {id} not found in {engagement_path}COACHING_LOG.md. Check the ID with /cb-log --list.`

---

## Guardrails

- Observed field must be Work-as-Done framing: what actually happened, observable behaviour. If the coach writes in Work-as-Imagined framing ("they should have..."), gently reframe before writing: "Captured as: [reframed version] — does that feel right?"
- Hypothesis must be testable If/Then format. If the coach provides a judgement instead ("they're not engaged"), offer a conversion: "Turning that into a testable hypothesis: 'If engagement stays low, then [observable outcome]' — want to use that?"
- Do not add coaching analysis, interpretations beyond what the coach provided, or invented content.
- Do not modify any field the coach did not ask to update.
