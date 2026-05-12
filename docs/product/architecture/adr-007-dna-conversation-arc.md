# ADR-007: DNA Conversation Arc

## Status
Accepted

## Context

ER-003 emerged from the Slice 01 real-use trial (2026-05-12): after a strong diagnostic phase, the tool shifted into action-planning without signalling the phase change. It continued using D-phase behaviour — follow-up question after each coach answer — in A-phase, producing a rapid-fire interrogation effect.

Root cause: SKILL.md had no explicit conversation lifecycle model. The ER-001 fix (transition phrase after 3-4 exchanges) addressed the calibration loop but left the A-phase unregulated. The tool knew how to open a conversation and how to respond turn-by-turn, but not how to change behaviour as the conversation moved from diagnosis to exploration to action.

## Decision

Adopt the DNA arc as the explicit conversation lifecycle:

- **D — Define**: Situational diagnosis. Observation-led. Calibration signals gathered here. No frameworks unless the coach signals interest.
- **N — New topics**: Exploration. Frameworks available on interest signal. The space for what else might be at play. J2 (growth vehicle) lives here; may be pulled forward into D on early signal.
- **A — Actions**: Planning and intervention design. Synthesis before questions. Don't drill step-by-step toward a plan.

**Transition naming**: Phase shifts are named explicitly using coaching language. The coach can redirect any transition.

**Backward movement**: The coach can re-enter D from N or A when new information surfaces. Name the repivot: "Does this change what we thought we understood?"

## Transition signals

| From | To | Coach cues |
|------|----|------------|
| D | N | "what else could this be?", "is there a framework for this?", shift from describing to wondering |
| D or N | A | "so what do I do?", "how do I approach this?", naming an upcoming session or decision |
| N or A | D | new information that changes the diagnosis |

## A-phase behaviour (ER-003 fix)

When the conversation is in Actions:
1. Open with a synthesis of what the diagnostic phase established — not a question
2. Ask at most one question: what the coach wants to do with that foundation
3. If the coach answers, offer something before asking again — don't chain questions

## Consequences

- Framework discovery (J2) sits in N by default; may surface in D on early interest signal — consistent with D2 (ADR-002) and D4 (ADR-004)
- Phase transitions are named, not silent — gives the coach agency to redirect, consistent with D3 (ADR-003) coaching register
- The ER-001 "I have enough to work with" phrase becomes a D→N or D→A signal rather than a fixed turn-count trigger
- Backward movement (repivot) is a first-class coaching move, not a deviation — consistent with D5 (ADR-005): stakes can surface at any phase and reset orientation
- Phase A/B delivery modes (plain response vs deep-dive) are orthogonal to DNA and unchanged
