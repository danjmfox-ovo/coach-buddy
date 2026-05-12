# Slice 03b: In-Context Activation

**Goal**: Verify `/coach-buddy` activates the full thinking-partner pipeline in a team project, and coaching continues without requiring a context switch.

## IN Scope
- `/coach-buddy [initial description]` activates SKILL.md opening protocol
- Coach can reference team artefacts visible in the conversation (sprint data, decision text, retro notes) and receive situation-grounded coaching
- Full thinking-partner conversation (3+ turns) completes in the team project context
- All SKILL.md behavioural rules hold: observation before question, no unrequested frameworks, mode management, attribution on first mention

## OUT of Scope
- Testing without reference files (Slice 03c)
- Quantifying quality against dedicated-project baseline (future)

## Learning Hypothesis
Disproves: "in-context coaching in a team project is qualitatively worse than dedicated-project coaching — context contamination from team knowledge files disrupts the coaching pipeline."
Confirms: SKILL.md pipeline operates normally in a shared project context; team knowledge files do not break mode management or attribution rules.

## Acceptance Criteria
- `/coach-buddy [situation]` receives a response that: (1) makes one observation from the description, (2) asks one calibrating question — not all three calibration signals upfront
- Coach can describe a situation referencing team artefacts in their messages; tool responds with situation-grounded reflection without confusing team context with coaching context
- Full conversation (3+ turns) completes without: (a) unrequested framework introductions, (b) tool-specific interruptions breaking coaching register, (c) calibration loop without exit
- Coach self-reports the conversation as "useful" (free-form post-conversation note)

## Dependencies
- Slice 03a complete: team project with `custom-instructions.md` + `SKILL.md` installed
- Reference files may or may not be present (test both; Slice 03c focuses the no-files case)

## Effort Estimate
~2 hours (run 2-3 real conversations with real situations)

## Reference Class
Conversation validation — no code changes expected. Done when 2 independent conversations complete with useful outcomes and no AC violations.

## Dogfood Moment
This slice IS the dogfood: use a real team project you are actively coaching. The triggering situation should come from that project's actual context.
