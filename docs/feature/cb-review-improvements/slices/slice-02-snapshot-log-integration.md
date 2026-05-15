# Slice 02 — Snapshot + COACHING_LOG Integration

**Goal**: `/cb-snapshot` appends a "Relevant coaching context" section sourced from COACHING_LOG.md,
so the coach has board state and coaching arc in a single pre-session file.

## IN scope
- Extend existing `/cb-snapshot` skill
- Read `engagements/<team-slug>/COACHING_LOG.md` if it exists
- Select up to 3 log entries (most recent, or correlated to WIP age flags)
- Append `## Relevant coaching context` section to the snapshot file
- Each entry: date + observation summary + hypothesis (not full entry)
- No COACHING_LOG → snapshot generates exactly as before (no section, no error)

## OUT scope
- Automatic correlation algorithm (recency is the default heuristic; WIP correlation is a bonus if simple)
- Modifying COACHING_LOG.md entries
- Changing the two-sentence risk read in chat

## Learning Hypothesis
Disproves "the board snapshot alone is sufficient pre-session prep" if coaches consistently
open COACHING_LOG.md separately anyway. Confirms if the integrated snapshot becomes the
single pre-session artifact in real engagements.

## Acceptance Criteria
See feature-delta.md — Story S2, AC1–AC4.

## Dependencies
- Existing `/cb-snapshot` skill (extension, not replacement)
- COACHING_LOG.md entry format must include `date`, `observation`, and `hypothesis` fields

## Effort Estimate
≤ 1 day (extend existing skill + file-read logic for COACHING_LOG)

## Production Data Requirement
Run against a real engagement with both board data and a populated COACHING_LOG.md.

## Dogfood Moment
Coach uses the integrated snapshot as their sole pre-session prep artifact on day of ship.
