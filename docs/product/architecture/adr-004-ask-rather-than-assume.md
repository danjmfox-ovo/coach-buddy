# ADR-004: Ask Rather Than Assume When Mode Is Ambiguous

**Status**: Accepted
**Date**: 2026-05-12
**Feature**: coach-buddy-architecture
**Quality attribute served**: Coherence, Safety

---

## Context

Coach Buddy serves two jobs that want different orientations from the tool. Operating in the wrong mode when stakes are high produces real harm: a coach working through a consequential situation does not need framework introductions; a coach in learning mode does not need the tool withholding material they've asked for.

When mode is clear, the tool defaults to it. When mode is ambiguous, the tool needs a decision rule. Two options:

1. **Default to one mode** (e.g. always situation-focus when uncertain): Simple, but produces systematic errors in the direction of the default
2. **Ask**: Adds friction, but avoids wrong-mode errors at high stakes

The decision turns on the cost asymmetry: a wrong-mode error in situation-focus is more costly (coach is less prepared for a real session) than a wrong-mode error in learning-mode (coach gets a framework they didn't ask for, easy to redirect). Given that asymmetry, asking is the safer default when genuinely ambiguous.

---

## Decision

### Ambiguity threshold

The tool asks when **all three** of the following conditions are true:
1. Two active mode signals are present simultaneously (signals from both situation-focus and learning-mode in the same turn or across recent turns)
2. No stakes statement has been made by the coach (if stakes are stated, ADR-005 applies)
3. There is a topic discontinuity — the coach has shifted from one thread to another without closing the first

If only one mode signal is present: default to it, no asking.
If stakes are stated: ADR-005 tiebreaker applies.

### Timing

The ask fires at a natural turn boundary only — not mid-thought. If the coach has just shared something significant, respond to that first, then ask.

### Ask format

The question uses standard coaching language (per ADR-003). Example:

> "Do you want to pick up the Kegan thread or stay with the team situation?"

This names both threads explicitly so the coach can choose without having to reconstruct what was in play.

### Stakes prompt

When mode is ambiguous and stakes are not stated, the tool may ask:

> "How live is this — is there a session or decision in the next 48 hours?"

This is a specific case of the D5 rule (ADR-005): prompting for stakes when mode is ambiguous so the tiebreaker can apply if needed. This prompt counts as a single interaction — it does not replace the mode question above.

---

## Consequences

**Positive**:
- Avoids systematic mode errors that would undermine Job 1 (situation-focus) at high stakes
- The question is itself coaching practice — asking "what do you want here?" is not an interruption
- Explicit choice surfaces coach's actual intent, which may differ from what the tool would have guessed

**Negative**:
- Friction: coach must answer a clarifying question before receiving the substantive response
- If the ambiguity threshold is set too low (tool asks too readily), it becomes annoying. Mitigation: the three-condition gate (two signals + no stakes + topic discontinuity) keeps this rare in practice — most turns have a clear dominant mode signal

---

## Worked Example

Coach message: "I'm navigating a real conflict between the tech lead and the product manager [situation signal]. By the way, what's Kegan's thing about levels? [learning signal]"

Conditions:
1. Two mode signals: ✓ (conflict situation + Kegan question)
2. No stakes stated: ✓
3. Topic discontinuity: ✓ (Kegan question is a break from the conflict thread)

Tool asks: "Do you want to start with the conflict or the Kegan question? Either is fine — just want to be useful in the right direction."

---

## Alternatives Considered

**Default to situation-focus when uncertain**: Rejected. Produces systematic errors for coaches in learning mode — they ask a question and get redirected. Over time undermines the growth-vehicle job.

**Default to learning-mode when uncertain**: Rejected. Higher cost asymmetry — being wrong in this direction at high stakes (coach is working through a live situation) is the worst failure mode.

**Ask on every mode transition**: Rejected. Too much friction. The three-condition gate distinguishes genuine ambiguity from normal conversational flow.
