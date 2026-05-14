# Slice 05b — Coaching Log Capture

**Goal**: Give the coach a fast, structured way to capture observations and retro actions after a session. Quick capture is the priority — the coach should be able to log a minimal observation in under a minute; full entry can be refined later.

## In Scope

- `engagements/skills/coach-log/SKILL.md` — the coach-log skill: new entry prepend, quick capture, field update
- `engagements/skills/retro-action/SKILL.md` — the retro-action skill: add row, update row, paste extraction
- `references/coaching-practice/coaching-log-format.md` — Safety-II rationale for the COACHING_LOG.md structure
- `references/coaching-practice/board-snapshot-guide.md` — how to read a board snapshot in a coaching context (written here even though the snapshot skill is in 05c; the guide is reference material, not a dependency)

## Out of Scope

- board-snapshot skill (slice 05c)
- Any changes to SKILL.md (the thinking-partner pipeline)
- Analytics or reporting on the coaching log

## Learning Hypothesis

Disproves if it fails: the Safety-II field structure is too heavy for post-session capture. If the coach finds the prompt loop for a full entry too slow or annoying, quick-capture needs to be the dominant path (not a fallback). This is a real risk — surfaced as Anxiety in J7's four forces.

Confirms if it succeeds: the coach can log an observation within 1 minute using quick-capture; can refine it later using `--update`; the Safety-II structure does not feel like overhead when the quick-capture path is the default.

## Acceptance Criteria

- AC2.1 through AC2.6 from feature-delta.md S2 (coach-log)
- AC3.1 through AC3.5 from feature-delta.md S3 (retro-action)
- AC6.1 through AC6.3 from feature-delta.md S6 (reference docs)
- Manual test: after running `/init` (05a), run `/cb-log` with a minimal description; verify entry prepended to COACHING_LOG.md; run `/coach-log --update <id> hypothesis "If X then Y"`; verify field updated

## Dependencies

- Slice 05a complete: config.json must exist for the skill to read the engagement path

## Effort Estimate

~2 hours. Reference class: similar to coach-log skill in the reference implementation. retro-action is simpler (table append); coaching-practice reference docs are factual prose, not pipeline logic.

## Production Data

The coach uses a real observation from a recent session as the test input. Synthetic data is acceptable for the retro-action paste test.

## Dogfood Moment

The coach uses `/cb-log` to record the observation that prompted this feature in the first place. If the format feels right for that entry, the hypothesis is confirmed.
