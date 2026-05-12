# Slice 01: Thinking Partner (Walking Skeleton)

**Goal**: A coach can work through a real situation in a single conversation — symptoms in, named dynamic + intervention options out — with the tool remaining in situation-focus mode throughout.

## IN Scope
- SKILL.md configured with situation-focus as default orientation
- Attribution on first framework mention (Name + Source, inline)
- Explicit orchestration signal when mode is active
- Reference files scoped to framework knowledge and intervention library

## OUT of Scope
- Interest detection (Slice 02)
- Deep-dive on framework (Slice 02)
- Mode management redirects (Slice 02)
- Multi-turn mode switching

## Learning Hypothesis
Disproves: "the Cutler-pattern (SKILL.md orchestrator) cannot maintain situation-focus discipline — it will introduce frameworks proactively."
Confirms: Architecture risk resolved — the pattern can serve Job 1 without Job 2 leaking in.

## Acceptance Criteria
- Coach describes a real situation → tool responds with symptoms named and dynamics articulated, no unrequested framework introduction
- If a framework is referenced, it is attributed on first mention: `Name (Source)`
- Tool surfaces its current orientation in at least one response per conversation
- Coach can complete a full thinking-through in a single conversation

## Dependencies
- SKILL.md authored (DESIGN wave)
- Initial reference file set scoped (DESIGN wave)

## Effort Estimate
~4 hours (configure + validate with 2-3 test conversations)

## Reference Class
Configuration-only slice — no code, no build pipeline. Done when real conversations validate the acceptance criteria.
