# DESIGN Decisions — coach-buddy-slice-02

## Key Decisions

- [D-S2-D1] No new ADRs: all Slice 02 behaviours implement decisions already made in ADR-001 through ADR-007. No new architectural decision with lasting consequence has emerged.
- [D-S2-D2] All changes are EXTEND operations on SKILL.md: no new sections needed. The five targeted additions fit within the existing named section structure (Attribution, Delivery, Mode management, Conversation arc).
- [D-S2-D3] ER-004 confirmed resolved: SKILL.md v1.3 already contains the vocabulary exemption removal. No further change required. The "Outstanding" flag in DISCUSS pre-requisites is stale — clean up at DELIVER.
- [D-S2-D4] Five changes identified (not four): Stories 1 and 2 each require one change in their primary section, but together also require a fifth change to the N-phase lifecycle in Conversation arc. This is additive — it does not change scope, it makes the arc behavioural contract explicit.
- [D-S2-D5] N-phase lifecycle is specified as a branch, not a destination: after deep-dive, tool returns to Phase A and resumes D or A phase tracking. N does not become a persistent mode.
- [D-S2-D6] Post-deep-dive return phrase ("what's your read on that?") deferred to DELIVER authoring — recommend registering it as a fixed phrase to prevent drift (OQ-S2-2).

## Architecture Summary

- Pattern: Cutler-pattern — unchanged from Slice 01
- Component being modified: SKILL.md (orchestrator), 5 targeted additions
- Sections changed: Attribution, Delivery, Mode management (×2), Conversation arc
- Estimated SKILL.md line count after slice: 170-178 (well within 500-line upgrade trigger)

## Reuse Analysis

| Change | Section | Type |
|--------|---------|------|
| Interest signal offer constraints (Story 1) | Attribution | EXTEND |
| Situated deep-dive delivery structure (Story 2) | Delivery | EXTEND |
| Mode redirect exhaustive-set + prohibition (Story 3) | Mode management | EXTEND |
| Ambiguity check inverse constraint + D5 interaction (Story 4) | Mode management | EXTEND |
| N-phase lifecycle (Stories 1+2, DNA arc) | Conversation arc | EXTEND |

## ADR Mapping

| Story | ADR(s) governing |
|-------|-----------------|
| Story 1 — Interest signal to framework offer | ADR-002 (interest signals, pull-based) |
| Story 2 — Situated deep-dive | ADR-002 (attribution), ADR-007 (N-phase, return to Phase A) |
| Story 3 — Mode redirect | ADR-003 (coaching register, phrase list, timing, override) |
| Story 4 — Ambiguity check | ADR-004 (three-condition gate), ADR-005 (D5 suppresses ask) |

## Constraints Carried Forward from Slice 01

All constraints from the Slice 01 DESIGN wave carry forward unchanged:
- SKILL.md named sections — additions must fit within the existing structure
- Mode management language must remain within the coaching register
- Attribution: no vocabulary exemption (already in v1.3)
- Context window is the binding constraint on SKILL.md length
- Stakes determination: stated or prompted, never inferred from language patterns

## Constraints Established in Slice 02 DESIGN

- Interest signal offer fires once per concept per conversation — no re-prompting on decline
- Deep-dive must be situationally grounded — references the coach's described situation explicitly; no generic textbook summary
- After deep-dive, tool returns to Phase A — N-phase is a branch, not a destination
- Mode redirect phrase set is exhaustive (four phrases) — not illustrative
- Ambiguity check fires only when all three D4 conditions are simultaneously true — inverse constraint explicit in SKILL.md
- D5 (stated stakes) suppresses ambiguity check — interaction specified in SKILL.md, not just in ADR-005

## Open Questions for DELIVER

| ID | Question | Recommendation |
|----|----------|----------------|
| OQ-S2-1 | Exact phrasing of deep-dive offer when attribution is embedded | Minor wording — resolve in DELIVER authoring |
| OQ-S2-2 | Is "what's your read on that?" a registered return phrase or an example? | Register it as fixed phrase to prevent drift |
| OQ-S2-3 | Mode redirect re-fire rule: never again in conversation, or not until new topic discontinuity? | Recommend: not until new topic discontinuity (mirrors Story 1 one-per-concept rule) |
| OQ-S2-4 | ER-004 "Outstanding" flag in DISCUSS artifacts is stale | Housekeeping — clean up in DELIVER |

## Upstream Changes

None. All Slice 01 ADRs carry forward unchanged. No DISCUSS user stories or ACs changed. The five changes identified by DESIGN are refinements that make ADR rules actionable in SKILL.md — they do not alter the stated requirements.
