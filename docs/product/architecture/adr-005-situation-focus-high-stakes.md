# ADR-005: Situation Focus Wins When Stakes Are Consequential or Irreversible

**Status**: Accepted
**Date**: 2026-05-12
**Feature**: coach-buddy-architecture
**Quality attribute served**: Safety (primary), Coherence (secondary)

---

## Context

ADR-004 establishes that the tool asks when mode is ambiguous. But asking has a cost: if the coach is working through something consequential and the tool asks a clarifying question, it adds friction at exactly the wrong moment.

A tiebreaker rule is needed for when the stakes are known. The cost asymmetry is asymmetric: wrongly staying in learning-mode during a high-stakes situation costs more than wrongly staying in situation-focus during a learning session. The tiebreaker should resolve toward the higher-cost failure mode.

The remaining design question is: who determines stakes — the coach or the tool?

---

## Decision

**Stakes determination: coach-stated OR coach-prompted.**

When a coach explicitly states that a situation is consequential or irreversible, the tool adopts situation-focus and holds it for the conversation. Framework introduction is deferred unless the coach explicitly asks.

When mode is ambiguous and stakes are not stated, the tool may prompt once:
> "How live is this — is there a session or decision in the next 48 hours?"

If the coach confirms stakes: situation-focus wins.
If the coach denies stakes or doesn't respond to the prompt directly: ADR-004 (ask about mode) applies.

**The tool does not infer stakes from language patterns alone.** Phrases like "this is tricky" or "I'm worried about this" do not trigger the rule. Stakes must be explicit (stated) or elicited (prompted and confirmed).

### Stakes indicators (stated)

The tool recognises a stakes statement when the coach explicitly references:
- A specific upcoming session or meeting ("I have a session tomorrow", "we're meeting on Thursday")
- A decision that must be made ("I need to decide by end of week")
- A live or in-progress situation ("this is happening right now", "I'm in this conversation today")
- Irreversibility language ("this could end the engagement", "no going back on this", "can't reverse this")

### Behaviour in situation-focus (high-stakes state)

- No unrequested framework introduction
- Attribution still fires on first mention if a framework is referenced (coach asked for it or the tool uses one in passing), but no deep-dive offer
- Mode management redirects (ADR-003) still apply
- Tool surfaces orientation briefly if helpful: "Keeping this in situation-focus given the stakes"

---

## Consequences

**Positive**:
- Protects Job 1 at the moments when it matters most — the coach working through something live and consequential is not disrupted by growth-vehicle mechanics
- Stakes prompt ("how live is this?") is a useful question in its own right — coaches often underspecify stakes and the prompt helps them think about it
- Explicit stakes criteria prevent scope creep (the tool over-applying situation-focus)

**Negative**:
- Stakes prompt adds one turn of friction when mode is ambiguous — trades latency for accuracy
- "Irreversibility language" recognition is interpretive — model may miss or over-trigger. Mitigation: when uncertain, treat as ambiguous and use ADR-004

---

## Interaction with ADR-004

ADR-004 applies when mode is ambiguous and stakes are not stated.
ADR-005 applies when stakes are known (either because the coach stated them or the prompt elicited them).

Sequence: stakes prompt (ADR-005) → if stakes confirmed, ADR-005 governs; if not, ADR-004 (mode question) applies.

---

## Alternatives Considered

**Stakes stated only, never prompted**: Rejected. Many coaches don't spontaneously state stakes. Prompting elicits the information needed to apply the rule correctly without requiring coaches to memorise a protocol.

**Stakes inferred from language patterns**: Rejected. Too many false positives ("this is really tricky" does not mean the same as "I have a session tomorrow"). The inference cost (wrong-mode error) exceeds the friction cost (one clarifying question).

**Situation-focus always wins when uncertain (no tiebreaker question)**: Rejected. Fails coaches in genuine learning-mode. The prompt allows the rule to apply precisely rather than bluntly.
