# Slice 02 — sprint-aware-snapshot

## Goal
cb-snapshot reads `team_config.path` from config.json, loads the linked teams.yaml,
and — when `cadence: scrum` and `sprint_length_weeks` are present — extends the snapshot
header with current sprint day and week context.

## IN scope
- cb-snapshot reads `team_config.path` from config.json (when present)
- Loads teams.yaml and extracts: `team.cadence`, `team.sprint_length_weeks`, `team.timezone`
- Calculates current sprint position: day-of-sprint (weekdays), week-of-sprint, sprint start date
- Appends sprint-context suffix to snapshot header line
- Graceful degradation: absent path, unreadable file, kanban cadence → no change to current behaviour

## OUT scope
- Reading `team.events` (ceremony schedule) into the snapshot
- Calculating sprint number (no sprint tracking in teams.yaml; would require a start-date baseline)
- Any changes to the four snapshot sections (WIP / Progress / Runway / Waiting)

## Learning Hypothesis
Sprint-day context in the snapshot header is used by coaches to frame the coaching conversation
differently (e.g., mid-sprint vs pre-retro). Disproved if: coaches ignore the header addition
or say it's confusing. Confirmed if: coaches reference sprint position in subsequent /coach-buddy
conversations without having to calculate it manually.

## Acceptance Criteria (from feature-delta.md)
AC-02.1 through AC-02.6 (US-02)

## Dependencies
- Slice 01 must be merged first (so `team_config.path` can be set in config.json)
- teams.yaml schema subset needed: `cadence`, `sprint_length_weeks`, `timezone`
- Sprint day calculation: derive from current date + most recent sprint-aligned Monday
  (sprint cadence anchored to ISO week; first sprint of cycle starts on the nearest Monday
  that is a multiple of sprint_length_weeks from a reference epoch — simplest approach:
  use the first Monday of the year as epoch, mod by sprint_length_weeks)

## Effort estimate
0.5 day — SKILL.md change + sprint-day calculation logic (simple date arithmetic, no external deps)

## Reference class
Similar to: age-flag logic in cb-snapshot (date arithmetic on WIP items). Same skill, known pattern.

## Pre-slice SPIKE needed?
No. Sprint position calculation is straightforward. The calculation should be documented
in the SKILL.md with worked examples so Claude Code can reproduce it without ambiguity.
