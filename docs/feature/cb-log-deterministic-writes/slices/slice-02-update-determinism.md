# Slice 02 — Update Determinism

**Goal**: Make the Mode 2 update path (`--update`) reliable by specifying an exact CLI→label mapping and a precise single-line replacement rule.

## IN Scope

- Mode 2 steps: add explicit CLI field name → file label mapping table
- Mode 2 steps: define the replacement mechanic as "find the line beginning with `{label}: ` and replace the entire line with `{label}: {new_value}`"
- Make explicit that the new value is single-line and all other lines are preserved unchanged

## OUT Scope

- Mode 1 (new entry path) — Slice 01
- UX changes
- Multi-line value support
- Adding new CLI field names

## Learning Hypothesis

**Disproves**: If `--update` changes the wrong line or produces side effects (blank line changes, other fields affected), the replacement rule or label mapping is insufficient.
**Confirms**: If `--update` changes exactly one line — the target label line — with all other lines byte-for-byte unchanged, the rule is correct.

## Acceptance Criteria

- AC2.1: `/cb-log --update <id> pattern "X"` changes only `**Pattern/Signal**: <old>` → `**Pattern/Signal**: X`. All other lines in the file are unchanged.
- AC2.2: `/cb-log --update <id> followup "X"` changes only `**Follow-up**: <old>` → `**Follow-up**: X`. All other lines unchanged.
- AC2.3: CLI→label mapping is enforced: `observed`→`**Observed**`, `context`→`**Context**`, `pattern`→`**Pattern/Signal**`, `hypothesis`→`**Hypothesis**`, `intervention`→`**Intervention**`, `followup`→`**Follow-up**`.
- AC2.4: Unknown entry ID → exactly: `Entry {id} not found in {engagement_path}COACHING_LOG.md. Check the ID with /cb-log --list.`

## Dependencies

**Depends on Slice 01**. Update reliability can only be verified once entry format is deterministic — the label line that `--update` targets must exist in a known, consistent form.

## Effort Estimate

< 1 hour. Smaller change — adds mapping table and tightens the Mode 2 steps section only.

## Reference Class

SKILL.md spec tightening.

## Pre-slice SPIKE

None required.
