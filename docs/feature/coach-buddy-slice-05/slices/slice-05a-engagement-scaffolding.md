# Slice 05a — Engagement Scaffolding

**Goal**: Prove the engagement context layer's architectural core: skill invocation → prompt loop → file creation → usable folder structure. The coach can run `/cb-init`, answer prompts, and have a working engagement folder within 5 minutes.

## In Scope

- `engagements/skills/init/SKILL.md` — the init skill: prompts for team name, slug, tool type, tool key; creates `engagements/<team-slug>/` with four files; writes `config.json`
- File templates (embedded in init skill or as separate template files):
  - CONTEXT.md with labelled placeholder sections
  - COACHING_LOG.md with header and format reference
  - RETRO_ACTIONS.md with header and empty table
  - HISTORY.md with header and usage instructions
- `config.json` written to `engagements/<team-slug>/` with tool type and project key
- `snapshots/` subdirectory created eagerly at init time (full structure visible immediately)
- Overwrite guard: warns and requires confirmation if slug already exists
- README update: new `## Engagement context layer` section (what it is, when to use, how to init, Chat sync pattern)
- `custom-instructions.md` update: one-line mention of `/cb-init` for engagement setup

## Out of Scope

- coach-log skill (slice 05b)
- retro-action skill (slice 05b)
- board-snapshot skill (slice 05c)
- references/coaching-practice/ (slice 05b)
- ADR-010 (slice 05c, after full feature is visible)

## Learning Hypothesis

Disproves if it fails: the prompt loop → file-write pattern is viable for skill-based scaffolding in Claude Code. If `/cb-init` cannot produce a clean folder structure through a prompt conversation, the whole engagement layer's UX model is broken.

Confirms if it succeeds: a coach can scaffold a new engagement in ≤5 minutes with no manual file creation; the config.json pattern will work for downstream skills.

## Acceptance Criteria

- AC1.1 through AC1.9 from feature-delta.md S1
- Manual test: run `/cb-init`, enter a test team name and slug, verify folder exists with four files and config.json, verify no reference engagement content in any file

## Dependencies

- Slice 03 complete (portable install two-layer model) — no additional code dependency; init is a new skill file

## Effort Estimate

~1 hour. Reference class: other SKILL.md files in this repo (200-400 lines, prompt-driven, file-write output).

## Production Data

The acceptance test uses real `/cb-init` invocation with a synthetic team name. No production team data required to validate the skill.

## Dogfood Moment

The coach runs `/cb-init` for their next real engagement on the day slice 05a ships. Any friction surfaced becomes AC input for slice 05b.
