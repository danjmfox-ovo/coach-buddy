---
name: cb-validate
description: >-
  Reviews logged coaching hypotheses and closes the loop by marking each as
  confirmed, disconfirmed, or deferred. Groups by age (>14 days, 7-14 days, <7 days).
  Use when you want to revisit predictions from past sessions and see which landed.
metadata:
  user-invocable: true
  argument-hint: '[--slug <team-slug>]'
---

# cb-validate — Hypothesis Validation

## What this does

Reads `COACHING_LOG.md` for an engagement, finds all entries with a real hypothesis
(not `(to fill)`), groups them by age, and leads you through marking each as
`confirmed`, `disconfirmed`, or `defer`. Writes the result back in-place.

After the review, surfaces any advisory-mode pattern if ≥2 entries were logged in that mode.

## Reading the engagement config

Read `engagements/<slug>/config.json` to find the engagement path.

- If `--slug <team-slug>` is passed, use that slug.
- If not passed and only one engagement folder exists under `engagements/`, use it.
- If multiple exist and no slug is specified, ask: "Which engagement? (available: <list of slugs>)"

## Step 1 — Read and parse COACHING_LOG.md

Read `engagements/<slug>/COACHING_LOG.md`.

If the file does not exist, exit:
> "No coaching log found for `<slug>`. Run /cb-log to start capturing observations."

Parse all entry blocks. An entry block is everything between two `---` separators,
starting with `id:` on the first line after `---`.

For each entry, extract:
- `id` (from `id: {value}` line)
- `date` (from `date: {value}` line)
- `mode` (from `mode: {value}` line, if present — default `thinking-partner` if absent)
- `**Hypothesis**` field value
- `**Validation**` field value (if present)

**Filter to validatable entries only:** entries where `**Hypothesis**:` is present and
the value is NOT `(to fill)`. Entries with no hypothesis or `(to fill)` are skipped silently.

If no validatable entries found, print:
> "No hypotheses to validate in `<slug>` — all entries are either unwritten or already complete.
> Add hypotheses with /cb-log."
Then exit.

## Step 2 — Group by age

Calculate each entry's age in days from today using the `date:` field.

Group:
- **Overdue** (>14 days): "These predictions are over two weeks old — worth checking now"
- **Maturing** (7–14 days): "These are old enough to have some signal"
- **Recent** (<7 days): "Too early to validate — shown for awareness only"

If a group is empty, skip it entirely (don't show the header).

## Step 3 — Present for validation

Print the groups in order (Overdue first, then Maturing, then Recent).

For each entry in Overdue and Maturing groups:

```
[{id}] {date}
Hypothesis: {full hypothesis text}
{if **Validation** already exists}: Already marked: {status} ({validated_on})
```

If `**Validation**` already exists for this entry, show it and ask:
> "Already validated as `{status}`. Update? (yes / no / skip)"
> - `yes` → treat as unvalidated, ask for new status
> - `no` / `skip` → leave unchanged, move to next

If not yet validated, ask:
> "Mark as: (c)onfirmed / (d)isconfirmed / (x) defer / (s)kip all remaining"
> - `c` or `confirmed` → status = `confirmed`
> - `d` or `disconfirmed` → status = `disconfirmed`
> - `x` or `defer` → status = `deferred`
> - `s` or `skip all` → stop the loop, proceed to Step 4

For Recent entries: show them but do NOT prompt for validation.
Print: `[{id}] {date} — too recent to validate (hypothesis shown for awareness only)`

## Step 4 — Write validation results back

For each entry where the coach provided a status (confirmed / disconfirmed / deferred):

Locate the entry block in COACHING_LOG.md by matching `id: {id}`.

**If `**Validation**:` does not exist in the block:**
Insert a new line `**Validation**: {status} ({YYYY-MM-DD})` immediately before the
closing `---` of the entry block.

**If `**Validation**:` already exists in the block (update case):**
Replace the existing `**Validation**:` line with `**Validation**: {status} ({YYYY-MM-DD})`.

Write the updated file. Preserve all other content exactly.

## Step 5 — Confirm

Print a summary:
```
Validation complete — {engagement_name}

  Confirmed:      {N} hypotheses
  Disconfirmed:   {N} hypotheses
  Deferred:       {N} hypotheses
  Skipped/recent: {N} hypotheses
```

## Step 6 — Advisory mode pattern note (conditional)

Count entries in COACHING_LOG.md where `mode: advisory` is present.

If the count is ≥2:
> "Pattern note: {N} of your entries in this log were captured in advisory mode.
> Coaching situations where you gave direct input rather than held the thinking-partner stance.
> Is this intentional, or a pattern worth noticing?"

Only show this note once per cb-validate run, after the summary.

---

## Guardrails

- Do not modify any field other than `**Validation**` in any entry.
- Do not infer a validation status from the coaching arc — the coach decides, always.
- Do not skip entries without showing them; the coach may choose to defer rather than validate.
- Do not validate Recent (<7 day) entries interactively — show for awareness only.
- If the file write fails for any reason, report the error and show the intended changes
  as text so the coach can apply them manually.
- The advisory mode note is observational. Do not frame it as a problem or suggest action.
