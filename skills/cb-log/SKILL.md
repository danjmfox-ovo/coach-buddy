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
- If no slug was passed and exactly one folder exists under `engagements/` with a `config.json`, use that
- If multiple folders exist and no slug was specified, ask: "Which engagement? (available: `<list of slugs>`)"

**Step 3 — No engagement found**

If neither Step 1 nor Step 2 yields a config, surface:
> "No engagement found at `./config.json` or `engagements/<slug>/config.json`. Run `/cb-init` to create an engagement, or `/cb-init --root` to scaffold at this location."

## Two modes

### Mode 1: New entry (default)

Invoked as: `/cb-log <observation text>` or just `/cb-log` (then ask for the observation).

**Step 1 — Capture observation and context**

Ask (or use what was provided):
- What did you observe? (Work-as-Done — what actually happened, not what should have happened)
- In what context? (ceremony or moment — e.g. "sprint review", "standup", "1:1 with tech lead", "reviewing the board")

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

**Observed**: {observed}
**Context**: {context}
**Pattern/Signal**: {pattern or "(to fill)"}
**Hypothesis**: {hypothesis or "(to fill)"}
**Intervention**: {intervention or "(none yet)"}
**Follow-up**: {follow_up or "(to fill)"}

---
```

**Step 5 — Confirm**

Print: `Entry {id} added to {engagement_path}/COACHING_LOG.md`

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

If the entry ID is not found, print: `Entry {id} not found in {engagement_path}/COACHING_LOG.md. Check the ID with /cb-log --list.`

---

## Guardrails

- Observed field must be Work-as-Done framing: what actually happened, observable behaviour. If the coach writes in Work-as-Imagined framing ("they should have..."), gently reframe before writing: "Captured as: [reframed version] — does that feel right?"
- Hypothesis must be testable If/Then format. If the coach provides a judgement instead ("they're not engaged"), offer a conversion: "Turning that into a testable hypothesis: 'If engagement stays low, then [observable outcome]' — want to use that?"
- Do not add coaching analysis, interpretations beyond what the coach provided, or invented content.
- Do not modify any field the coach did not ask to update.
