# Slice 03 — Mode Field (cb-log) + Stakeholder Template (cb-init)

**Goal**: Two micro-improvements ship together: optional `mode:` field on cb-log entries,
and an enhanced Stakeholders section in the cb-init CONTEXT.md template.

## IN scope

### S3 — cb-log mode field
- Accept `--mode <value>` flag: `thinking-partner | advisory | facilitation`
- Default: `thinking-partner` (no change to existing entries without the flag)
- Validate mode value; reject with clear error if unrecognised
- Write `mode: <value>` to the log entry header in COACHING_LOG.md

### S4 — cb-init stakeholder template
- Update CONTEXT.md template to include structured Stakeholders section:
  - Columns: Role | Influence level | Inclusion notes | External pressures
  - "Who am I NOT seeing?" reflection prompt below the table
- Apply to NEW engagements only — do not modify existing CONTEXT.md files

## OUT scope
- Retroactively tagging existing log entries with a mode
- Automatic mode detection
- Multi-coach columns in the stakeholder table
- Migrating existing CONTEXT.md files to the new template

## Learning Hypothesis
Disproves "mode tracking adds overhead" if coaches use the `--mode` flag in ≥30% of
entries across active engagements. Disproves "coaches capture power dynamics naturally"
if the enhanced template surfaces stakeholders not previously listed.

## Acceptance Criteria
See feature-delta.md — Stories S3 (AC1–AC3) and S4 (AC1–AC3).

## Dependencies
- S3: No external dependencies; extends cb-log SKILL.md and COACHING_LOG write logic
- S4: No external dependencies; changes cb-init SKILL.md template only

## Effort Estimate
≤ 1 day (two small changes; can ship as a single conventional commit)

## Production Data Requirement
S3: Tested against a real engagement's cb-log invocation (not a synthetic file).
S4: cb-init run to generate a real engagement folder; stakeholder section reviewed by the coach.

## Dogfoot Moment
Coach logs an advisory-mode entry and initialises a new engagement folder on the same day.
