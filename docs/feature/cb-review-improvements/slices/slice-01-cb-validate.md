# Slice 01 — cb-validate

**Goal**: Coach runs `/cb-validate <team-slug>` and closes the loop on aged hypotheses in their coaching log.

## IN scope
- New `/cb-validate` skill file
- Reads `engagements/<team-slug>/COACHING_LOG.md`
- Groups hypotheses by age (>14d / 7–14d / <7d)
- Prompts coach to mark each: confirmed / disconfirmed / defer
- Writes `validation_status` and `validated_on` back to the entry in COACHING_LOG.md
- Advisory mode pattern detection: if ≥2 entries have `mode: advisory`, surfaces a pattern note

## OUT scope
- Cross-engagement aggregation
- Automatic hypothesis confirmation (coach decides, always)
- Modifying the Safety-II structure of existing entries

## Learning Hypothesis
Disproves "coaches will revisit hypotheses without a prompt" if log entries remain perpetually
unvalidated in engagements that do use /cb-log. Confirms if validation_status fields appear
regularly within 30 days of hypothesis creation.

## Acceptance Criteria
See feature-delta.md — Story S1, AC1–AC4.

## Dependencies
- `engagements/<team-slug>/COACHING_LOG.md` must exist (graceful exit if not)
- COACHING_LOG format must include `hypothesis:` field (established by cb-log)

## Effort Estimate
≤ 1 day (single skill file + COACHING_LOG read/write logic)

## Production Data Requirement
Tested against a real engagement's COACHING_LOG.md (not synthetic data).

## Dogfood Moment
Coach validates hypotheses from an active engagement on the same day the slice ships.
