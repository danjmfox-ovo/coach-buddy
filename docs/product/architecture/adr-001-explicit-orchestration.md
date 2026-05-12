# ADR-001: Explicit Orchestration Over Implicit

**Status**: Accepted
**Date**: 2026-05-12
**Feature**: coach-buddy-architecture
**Quality attribute served**: Transparency (primary), Safety (secondary)

---

## Context

Coach Buddy serves a coach who needs to trust the tool without surrendering their own judgment. Two failure modes exist:
1. The tool reasons invisibly and the coach accepts outputs without understanding what drove them
2. The coach rejects the tool because they can't tell what it's doing or why

A Claude Chat Project can be configured with opaque implicit behaviour (large undifferentiated system prompt, no visible pipeline) or with visible explicit orchestration (named pipeline, surfaced mode state, readable SKILL.md).

The tool also has a structural upgrade path (to nWave) that requires the orchestration logic to be inspectable and mappable to agent definitions.

---

## Decision

Orchestration logic lives in **SKILL.md** (Cutler-pattern), structured with named sections:
- Opening protocol
- Mode management rules
- Attribution rules
- Phase A / Phase B delivery
- Guardrails

SKILL.md is the authoritative source of all behavioural rules. It is readable, editable, and version-controllable. No behavioural logic is hidden in implicit model tendencies or buried in reference files.

The tool surfaces its current mode when switching or when asked. Orchestration signals are brief and non-dominant — they do not take over the response.

---

## Consequences

**Positive**:
- Coach can inspect SKILL.md to understand what the tool will and won't do
- Orchestration logic can be reasoned about, tested via conversation, and updated
- Maps cleanly to nWave agent definitions (ADR-006 upgrade seam)
- Reduces "black box" anxiety that would undermine Job 1 (thinking-partner trust)

**Negative**:
- SKILL.md can drift from actual model behaviour if instructions are ambiguous — requires periodic calibration via test conversations
- Explicit mode-state signals add a small surface cost to each response (mitigated by keeping them brief)

---

## Alternatives Considered

**Prompt-only (single large implicit system prompt)**: Rejected. Violates transparency. All logic is invisible to the coach. Non-upgradeable.

**Model behaviour as default (no SKILL.md structure)**: Rejected. Model's default coaching-adjacent behaviour is not aligned with the two-job tension or the mode management requirements. Would require constant re-prompting.
