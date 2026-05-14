---
name: cb-retro
description: >-
  Adds or updates retro actions in RETRO_ACTIONS.md. Supports single action entry,
  status updates by ID, and bulk extraction from pasted retro output.
  Use after retrospectives to track follow-through in the engagement folder.
metadata:
  user-invocable: true
  argument-hint: '<action> [--update <id> <field> <value>] [--paste "<raw text>"] [--slug <team-slug>]'
---

# cb-retro — Retro Action Tracking

## What this does

Manages the `RETRO_ACTIONS.md` table for a coaching engagement. Three modes: add a single action, update an existing action by ID, or extract all actions from a raw paste of retro output.

## Reading the engagement config

Read `engagements/<slug>/config.json` to find the engagement path. If `--slug <team-slug>` is passed, use that slug. If not and only one engagement folder exists, use that. If multiple exist and no slug is specified, ask which engagement.

## Three modes

### Mode 1: Add a single action (default)

Invoked as: `/cb-retro <action description>`

Steps:
1. Read `RETRO_ACTIONS.md` to find the current highest action ID. New ID = highest + 1, zero-padded to 3 digits (e.g. `004`). If no rows exist, start at `001`.
2. Ask for owner (who owns this action) and today's date is used for Raised. Owner may be left blank if unknown.
3. Append a new row to the table:

```markdown
| {id} | {action} | {owner} | {YYYY-MM-DD} | open | |
```

4. Print: `Action {id} added: "{action}"`

---

### Mode 2: Update an existing action

Invoked as: `/cb-retro --update <id> <field> <value>`

Valid fields: `action`, `owner`, `status`, `notes`

Valid status values: `open` | `in-progress` | `done` | `dropped`

Steps:
1. Read `RETRO_ACTIONS.md`.
2. Find the row with matching ID in the first column.
3. Update the specified field. Do not change other fields.
4. Write the updated file.
5. Print: `Action {id} updated — {field}: {value}`

If the ID is not found: `Action {id} not found in RETRO_ACTIONS.md.`

---

### Mode 3: Bulk extraction from paste

Invoked as: `/cb-retro --paste "<raw retro output>"`

Steps:

**Step 1 — Extract candidate actions**

Read through the pasted text. Extract items that look like actions: commitments, next steps, named owners, "we will...", "someone will...", explicit verb phrases.

Mark each candidate as:
- `✓ action` — clear, specific, has an owner or can be assigned one
- `⚠ ambiguous` — may be an action but is vague, duplicated, or lacks clarity

**Step 2 — Present for confirmation**

List all extracted items with their classification:

```
Found {N} candidate actions:

✓  001 — "{action text}" (owner: {owner if named, else "unassigned"})
✓  002 — "{action text}"
⚠  003 — "{item text}" — ambiguous: [reason: vague / no owner / possible duplicate of 001]

Add all ✓ items? (yes / no / edit)
```

Wait for coach response before writing anything.

**Step 3 — Write confirmed actions**

On confirmation (yes or edit):
- Add all confirmed ✓ items as new rows using the same ID sequencing as Mode 1.
- For ambiguous ⚠ items: only add if the coach explicitly confirms them during the edit step.
- Print a summary: `{N} actions added to RETRO_ACTIONS.md`

---

## Guardrails

- Do not add the same action twice. Before writing, check if an action with very similar text already exists. If so, ask: "This looks similar to action {id}: '{existing}'. Add as a new action or update the existing one?"
- Do not interpret or rewrite action text. Capture what the coach or the retro output said, exactly.
- Ambiguous items from `--paste` must not be silently added — they require explicit confirmation.
