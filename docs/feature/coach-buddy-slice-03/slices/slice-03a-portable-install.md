# Slice 03a: Portable Install Procedure

**Goal**: Verify the two-step install procedure works in a real team project.

## IN Scope
- Following README "team project" install path: paste `custom-instructions.md` into custom instructions, upload `SKILL.md` as project knowledge
- Confirming the lean always-on layer activates (coaching sensibility present, full pipeline not active)
- Confirming `/coach-buddy` invocation is possible after install

## OUT of Scope
- Uploading reference files (Slice 03c)
- Running full coaching conversations (Slice 03b)
- Testing install in Claude Code or Cursor paths (future)

## Learning Hypothesis
Disproves: "the portable install procedure requires more than two steps or produces unexpected behaviour in a real team project."
Confirms: Two-step install is sufficient; custom-instructions.md does not activate the full pipeline automatically; SKILL.md is available for invocation.

## Acceptance Criteria
- Coach completes install by following README without consulting any other documentation
- Install takes ≤10 minutes
- After install: a new conversation in the team project reflects the coaching sensibility from `custom-instructions.md` (Theory Y stance, attribution rule, no performative affirmations) without activating the full SKILL.md pipeline
- After install: `/coach-buddy` in a new message is recognised and activates the full pipeline (see Slice 03b for full validation)

## Dependencies
- A real Claude Chat team project (not synthetic)
- `custom-instructions.md` and `SKILL.md` available from the current repo

## Effort Estimate
~1 hour

## Reference Class
Configuration validation — no code changes expected. Done when install completes and invocation is possible.
