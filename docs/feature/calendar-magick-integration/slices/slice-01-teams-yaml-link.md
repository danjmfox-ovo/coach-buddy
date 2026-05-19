# Slice 01 — teams-yaml-link

## Goal
cb-init gains an optional final prompt to declare a path to an existing `teams.yaml`.
When entered and valid, `config.json` is written with `team_config.path`. The data path
from cb-init → config.json is proven end-to-end.

## IN scope
- New optional prompt in cb-init setup flow (last question)
- Path existence validation before writing
- `team_config.path` field written to config.json when a valid path is supplied
- Auto-detection of `teams/*/config.yaml` (US-03) bundled here — detection feeds the same prompt
- Confirmation output line when path is written

## OUT scope
- Reading teams.yaml in any skill (that's Slice 02 and 03)
- Scaffolding a new teams.yaml
- Writing to teams.yaml

## Learning Hypothesis
A coach who uses both tools will declare the link when prompted rather than finding it too
fiddly to set up. Disproved if: link completion rate < 20% in repos with a `teams/` directory
present. Confirmed if: coaches declare the link in the first session and don't ask how to undo it.

## Acceptance Criteria (from feature-delta.md)
AC-01.1 through AC-01.5 (US-01), AC-03.1 through AC-03.5 (US-03)

## Dependencies
- cb-init SKILL.md (cb-root-layout feature must be merged first — it is)
- config.json schema must accept new top-level `team_config` key without breaking existing readers

## Effort estimate
0.5 day — SKILL.md change only; no production code

## Reference class
Similar to: adding PM tool prompts to cb-init (slice-05). Known pattern. Low uncertainty.

## Pre-slice SPIKE needed?
No. The pattern is established: cb-init reads files at setup time; this is the same.
