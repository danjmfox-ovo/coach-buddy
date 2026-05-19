# Slice 03 — member-hints

## Goal
cb-log reads `team.members` from a linked teams.yaml and uses the roster to offer
name suggestions in the "Who was in the session?" prompt.

## IN scope
- cb-log reads `team_config.path` from config.json (when present)
- Loads `team.members` and formats: `name (ROLE)` list
- Presents as a hint in the session-participants prompt
- "Press Enter for full team" shortcut writes all member names to `participants` field
- Graceful degradation: absent path, unreadable file → prompt unchanged

## OUT scope
- Validating that entered names are in the roster (hint only, not a gate)
- Role-based filtering of suggestions (show all members, not filtered by session type)
- Any changes to other cb-log prompts

## Learning Hypothesis
Having the team roster visible at the "Who was in the session?" prompt increases consistency
of participant naming across COACHING_LOG.md entries. Disproved if: coaches still type
inconsistent names despite the hint (suggesting the hint is not in the right place or
not visible enough). Confirmed if: COACHING_LOG.md entries show consistent name/role
formatting matching teams.yaml after Slice 03 lands.

## Acceptance Criteria (from feature-delta.md)
AC-04.1 through AC-04.5 (US-04)

## Dependencies
- Slice 01 must be merged first
- teams.yaml `team.members[].name` and `team.members[].role` fields

## Effort estimate
0.5 day — SKILL.md change to cb-log only

## Reference class
Informational hint pattern used elsewhere in skill flows. No architectural novelty.

## Pre-slice SPIKE needed?
No. Lowest-uncertainty slice in the set.
