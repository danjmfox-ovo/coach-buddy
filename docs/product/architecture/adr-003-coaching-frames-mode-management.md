# ADR-003: Coaching Frames for Mode Management

**Status**: Accepted
**Date**: 2026-05-12
**Feature**: coach-buddy-architecture
**Quality attribute served**: Coherence, Safety

---

## Context

Conversations drift. Topics shift. A coach may start in situation-focus, veer into a broader organisational observation, and not notice they've lost the thread. Or the tool may detect a topic shift and need to redirect without breaking the register of the conversation.

Two types of redirect exist:
1. **Tool-specific interruption** — "I notice we've shifted topics. Would you like to return to X?" — This is explicit, transparent, but breaks the coaching register. It reads as a system message, not a coaching response.
2. **Coaching language redirect** — "What do you want to achieve here today?" or "Is this the real topic?" — This is standard coaching practice. It redirects without drawing attention to the tool's own mechanics.

Coach Buddy is a thinking *partner* for coaches. Its language should be indistinguishable from what a skilled coach-supervisor would say. Tool-specific language creates a category error.

---

## Decision

Mode management redirects use **standard coaching language only**. All redirect phrases must be drawn from established coaching practice — not invented for this tool.

**Permitted redirect phrases** (illustrative, not exhaustive):
- "What do you want to achieve here today?"
- "Is this the real topic?"
- "What would be most useful right now?"
- "Where do you want to focus?"
- "What's pulling you toward this thread?"

**Prohibited**: Any phrase that references the tool's own mechanics ("I notice we've shifted", "switching modes", "returning to our earlier topic", "you've mentioned X twice now").

### Timing constraint

Redirects fire only at **natural turn boundaries** — not mid-thought, not immediately after the coach has shared something significant. A redirect during active disclosure is an interruption, not a redirect.

### Override behaviour

If the coach continues the new thread after a redirect, the tool follows. The redirect is an offer, not a gate. Pushing past a redirect is itself a signal about where the coach wants to go.

---

## Consequences

**Positive**:
- Maintains the coaching register throughout — tool language is consistent with coaching supervision practice
- Coach is less likely to experience the redirect as a system constraint and more likely to engage with it as a genuine question
- Reduces the risk of the tool appearing mechanical or intrusive

**Negative**:
- Coaching redirects are softer than tool-specific interruptions — a coach who doesn't notice the redirect will continue drifting. Mitigation: if the redirect is not taken up and the drift continues for 2+ more turns, the tool can ask more directly (without tool-specific language: "What's the most important thing to resolve before we're done here?")
- The phrase list in SKILL.md must be authored carefully — language that sounds natural in a coaching context but feels odd in a technical tool review

---

## Alternatives Considered

**Tool-specific interruption**: Rejected. Breaks the coaching register. "I notice we've shifted topics" makes the tool's mechanics visible in a way that undermines trust and feels like a software system, not a thinking partner.

**No mode management (let conversations drift)**: Rejected. Without redirection, the tool cannot serve Job 1 (situation focus) reliably. Drift means the coach may finish a conversation without having thought through the actual situation.
