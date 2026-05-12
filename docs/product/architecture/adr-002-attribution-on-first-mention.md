# ADR-002: Attribution on First Mention

**Status**: Accepted
**Date**: 2026-05-12
**Feature**: coach-buddy-architecture
**Quality attribute served**: Transparency, Coherence (prevents undisclosed framework imposition)

---

## Context

Coach Buddy introduces frameworks, models, and theories as part of the growth-vehicle job. Without attribution, two problems arise:
1. The coach cannot verify the source or seek deeper reading
2. The tool appears to assert frameworks as universal rather than as situated perspectives

At the same time, repeated attribution of the same framework in a conversation is noise and interrupts flow. The attribution rule must be precise enough to be implementable in SKILL.md.

A related problem: the tool must know when a coach wants to go deeper on a framework (deep-dive available) versus when attribution is sufficient and flow should continue. This requires an explicit definition of "interest signals."

---

## Decision

### Attribution format

On the **first mention** of any named framework, model, or theory in a conversation, attribution is added inline:

```
Name (Author/Source)
```

Examples: `Cynefin (Snowden)`, `Team Topologies (Skelton, Pais)`, `Kegan's Orders of Mind (Kegan)`.

On subsequent mentions in the **same conversation**: no re-attribution. Name only.

Attribution applies to **tool-introduced** frameworks. If the coach names a framework, no attribution is added unless the coach asks for it.

### Interest signals

A deep-dive is available when the tool detects any of the following coach-originating signals:

1. **Explicit ask** — coach asks about a framework by name ("tell me about Cynefin", "is there a framework for this?")
2. **Double-mention** — coach mentions the same concept twice in the conversation
3. **"Tell me more"** — coach uses any variant of explicit depth request
4. **Sustained engagement** — coach returns to the same sub-topic across 3+ turns
5. **Follow-on question** — coach asks a clarifying question about a framework the tool mentioned
6. **Vocabulary adoption** — coach starts using the framework's own vocabulary or logic in their messages

The tool does **not** infer interest from topic adjacency, thematic resonance, or its own associations. Interest is a coach-originating signal.

When an interest signal is detected:
- Tool offers: "I can go deeper on [Name] if that would be useful — just say the word"
- Deep-dive is not auto-delivered; it waits for the coach to accept

### Delivery placement

Attribution and interest signals are additive: they appear at the end of the relevant observation, not as substitutes for the substantive response. They do not interrupt the situation-focus flow.

---

## Consequences

**Positive**:
- Coach can trace frameworks to sources without asking
- Deep-dive is pull-based — does not disrupt situation-focus
- Interest signals are explicit and auditable — no mysterious topic introductions

**Negative**:
- "Double-mention" signal requires the tool to track mentions within a conversation (in-context state, not persistent)
- "Vocabulary adoption" signal is interpretive — the tool may miss it or trigger it on weak evidence. Mitigation: when uncertain, default to "sustained engagement" (3+ turns) as a stronger signal

---

## Underdetermined at time of decision

The exact phrasing of the deep-dive offer is not specified here — it is a SKILL.md authoring decision. The rule is: brief, non-disruptive, pull-based.

---

## Alternatives Considered

**Attribution on every mention**: Rejected. Noise. Interrupts flow in longer conversations.

**Attribution only on explicit request**: Rejected. Shifts burden to coach. Violates growth-vehicle job (frameworks should be named so the coach knows what they're engaging with, even if they don't ask).

**Tool infers interest from topic adjacency**: Rejected. Violates ask-rather-than-assume (ADR-004). The tool's associations are not a reliable proxy for the coach's interests.
