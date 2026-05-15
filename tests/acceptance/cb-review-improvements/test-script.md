# cb-review-improvements Manual Test Script
# Run in Claude Code with coach-buddy skills installed.
# Use a real engagement folder — do not fabricate test data.
# Start a fresh conversation for each numbered scenario.
# Annotate pass/fail and timestamps in the results section at the bottom.

---

## Pre-run setup

1. Ensure coach-buddy skills are installed: `ls .claude/skills/cb-validate/` should show SKILL.md.
2. Create or confirm an engagement folder exists: `engagements/<slug>/`.
3. Confirm COACHING_LOG.md has at least 3 entries, including:
   - At least one with `date:` > 14 days ago and a real (non `(to fill)`) hypothesis
   - At least one with `date:` within the last 7 days
4. Confirm at least one entry does NOT have `**Validation**:` written yet.

---

## Slice 01 — cb-validate

### Scenario 1a: Overdue hypotheses presented (S1, walking skeleton)

**Run**: `/cb-validate` (or `/cb-validate --slug <slug>`)

**Expect**:
- Skill reads COACHING_LOG.md
- Hypotheses grouped: Overdue (>14d) shown first
- Each entry shows id, date, full hypothesis text
- Prompt: "(c)onfirmed / (d)isconfirmed / (x) defer / (s)kip all remaining"

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 1b: Validation written back to COACHING_LOG.md (S1)

**Run**: Mark one overdue hypothesis as `confirmed`

**Expect**:
- COACHING_LOG.md updated: entry contains `**Validation**: confirmed ({today})`
- All other fields in the entry unchanged
- Summary: `Confirmed: 1`

**Verify**: `grep -A 20 "id: {entry-id}" engagements/<slug>/COACHING_LOG.md | grep Validation`

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 1c: No COACHING_LOG — graceful exit (S1)

**Setup**: rename COACHING_LOG.md temporarily

**Run**: `/cb-validate --slug <slug>`

**Expect**: "No coaching log found for `<slug>`. Run /cb-log to start capturing observations."

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 1d: Recent entries not prompted (S1)

**Setup**: Ensure one entry has today's date

**Run**: `/cb-validate`

**Expect**: Recent section shows entry with "too recent to validate" note; no prompt for it

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 1e: Advisory mode pattern note (S1)

**Setup**: Ensure ≥2 entries have `mode: advisory`

**Run**: `/cb-validate`

**Expect**: After summary, pattern note mentions count of advisory-mode entries. No prescriptive framing.

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 1f: Duplicate validation guard (S1, error)

**Setup**: Run 1b first so one entry has `**Validation**: confirmed (...)`

**Run**: `/cb-validate` again

**Expect**: "Already validated as confirmed. Update? (yes / no / skip)" — does NOT write a second line

**Pass / Fail**: ________ | **Notes**: ________

---

## Slice 02 — cb-snapshot (extended)

### Scenario 2a: Snapshot includes coaching context section (S2, walking skeleton)

**Run**: `/cb-snapshot` (with COACHING_LOG.md having ≥1 entry)

**Expect**:
- Snapshot file written to `engagements/<slug>/snapshots/<date>-board.md`
- File contains `## Coaching context` section
- Up to 3 entries shown, most-recent-first
- Each entry: date, truncated Observed, truncated Hypothesis (≤120 chars each)

**Verify**: `cat engagements/<slug>/snapshots/<date>-board.md | grep -A 20 "Coaching context"`

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 2b: Chat risk read unchanged (S2)

**Run**: same as 2a

**Expect**: Chat output shows exactly two sentences of risk read. No coaching context in chat.

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 2c: No COACHING_LOG — snapshot generates as before (S2)

**Setup**: rename COACHING_LOG.md temporarily

**Run**: `/cb-snapshot`

**Expect**: Snapshot file written normally. No `## Coaching context` section. No error.

**Pass / Fail**: ________ | **Notes**: ________

---

## Slice 03 — cb-log mode field

### Scenario 3a: --mode advisory writes mode field (S3, walking skeleton)

**Run**: `/cb-log "The team lead asked for direct input on the call" --mode advisory`

**Expect**: New entry in COACHING_LOG.md contains `mode: advisory` in the header

**Verify**: `tail -30 engagements/<slug>/COACHING_LOG.md | grep mode`

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 3b: Default mode is thinking-partner (S3)

**Run**: `/cb-log "Sprint review felt flat — energy low despite delivery"`

**Expect**: Entry contains `mode: thinking-partner`

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 3c: Unrecognised mode rejected (S3, error)

**Run**: `/cb-log "observation" --mode mentor`

**Expect**: "Mode must be one of: thinking-partner, advisory, facilitation" — no entry written

**Pass / Fail**: ________ | **Notes**: ________

---

## Slice 03 — cb-init stakeholder template

### Scenario 4a: Structured Stakeholders table in CONTEXT.md (S4, walking skeleton)

**Run**: `/cb-init` for a NEW engagement slug

**Expect**:
- CONTEXT.md Stakeholders section contains a table: Role | Influence | Inclusion notes | External pressures
- "Who am I NOT seeing?" prompt present below the table

**Verify**: `grep -A 10 "Stakeholders" engagements/<new-slug>/CONTEXT.md`

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 4b: COACHING_LOG.md template shows mode field (S4)

**Run**: same /cb-init run as 4a

**Expect**: COACHING_LOG.md entry format template shows `mode: thinking-partner`

**Verify**: `grep "mode:" engagements/<new-slug>/COACHING_LOG.md`

**Pass / Fail**: ________ | **Notes**: ________

---

## Results Summary

| Scenario | Pass/Fail | Notes |
|----------|-----------|-------|
| 1a | | |
| 1b | | |
| 1c | | |
| 1d | | |
| 1e | | |
| 1f | | |
| 2a | | |
| 2b | | |
| 2c | | |
| 3a | | |
| 3b | | |
| 3c | | |
| 4a | | |
| 4b | | |

Tested by: ________________ | Date: ________________ | Version: 1.8.0
