# ADR-006: Cutler-Pattern Now; nWave-Pattern as Upgrade Path

**Status**: Accepted
**Date**: 2026-05-12
**Feature**: coach-buddy-architecture
**Quality attribute served**: Evolvability (aspirational), Transparency (via explicit seam)

---

## Context

Two architecture patterns are viable for Coach Buddy:

**Cutler-pattern**: SKILL.md (orchestrator) + reference files (knowledge). Runs in a Claude Chat Project today, without additional tooling. Visible, editable, immediately deployable.

**nWave-pattern**: Explicit agent invocation, human checkpoints between waves, structured artifact production. Requires Claude Code CLI. Better suited to multi-agent coordination, deterministic handoffs, and multi-session memory.

The Cutler-pattern is the right choice for Slice 01 (walking skeleton): it proves the architecture without over-investing in infrastructure before the core jobs are validated. However, the tool's needs may grow: SKILL.md may become unwieldy; the coach may want to invoke named agents for specific tasks; multi-session memory or external tool integration may become necessary.

The decision is to use Cutler-pattern now, but to design the seam explicitly so that upgrading to nWave-pattern does not require rebuilding the knowledge base or rewriting the behavioural rules.

**Note**: Evolvability was not selected as a top-3 quality attribute for this feature (Transparency → Coherence → Safety). This ADR is about making the seam explicit for future reference, not about optimising for evolvability now.

---

## Decision

### Current: Cutler-pattern

- **SKILL.md** = orchestrator (opening protocol, mode management, attribution, guardrails, Phase A/B delivery)
- **`references/`** = framework library (one markdown file per framework domain)
- **`assets/`** = templates (calibration canvas, output template)

### Upgrade seam (Cutler → nWave)

| Cutler component | nWave equivalent | Transformation required |
|---|---|---|
| SKILL.md sections | Agent role definitions | None — sections become agent descriptions 1:1 |
| `references/` files | SSOT knowledge base (`docs/product/knowledge/`) | Move, no rewrite |
| Calibration signals (mode/context/stakes) | DISCUSS wave intake questions | Rephrased, same content |
| Phase A → feedback loop → Phase B | DISTILL acceptance tests + DELIVER pipeline | Structural change, content preserved |
| In-conversation mode state | Wave-level artifact state | Requires explicit state externalisation |

**The guarantee**: all content (behavioural rules, framework knowledge, calibration templates) is preserved across the upgrade. Only the execution model changes — from conversational to agentic.

### Upgrade triggers (watch-for signals, not current decisions)

The upgrade is worth evaluating when one or more of these is true:
- SKILL.md exceeds ~500 lines and has become difficult to reason about
- The coach needs to invoke a specific named agent for a well-defined task (e.g. "run a workshop design sprint", "draft a stakeholder communication")
- Multi-session memory is needed (coach state, relationship history, prior session outcomes)
- External tool integration is needed (calendar, collaboration tools, note-taking)
- Multiple coaches are using the tool and need shared configuration or knowledge management

### What "without rebuild" means

When the upgrade triggers are met, the nWave migration path requires:
1. Copy SKILL.md sections into agent definition files (no content change)
2. Move `references/` to `docs/product/knowledge/` (no content change)
3. Externalise in-conversation mode state to wave-level artifacts (new mechanism, same semantics)
4. Wire calibration signals into DISCUSS wave intake (same questions, different invocation)

Nothing that is known today needs to be rediscovered or rewritten. The investment in authoring SKILL.md and the reference library is fully preserved.

---

## Consequences

**Positive**:
- Can ship Slice 01 immediately without Claude Code CLI dependency
- Seam is explicit — if the upgrade triggers are reached, the path is documented and the work is bounded
- Content investment (reference files, calibration canvas, SKILL.md rules) is not sunk cost

**Negative**:
- Cutler-pattern has limits that nWave resolves: no deterministic handoffs, no multi-session persistence, no automated testing, no multi-agent coordination. These are accepted limitations for Slice 01.
- The seam requires SKILL.md to be structured with named sections — an unstructured SKILL.md would make the upgrade harder. Mitigation: SKILL.md authoring should follow section naming that maps to agent roles from the start.

---

## Alternatives Considered

**Start with nWave-pattern immediately**: Rejected. Over-engineered for Slice 01. Adds infrastructure before the core jobs are validated. Claude Code CLI dependency excludes the current deployment context (Claude Chat Project).

**Stay with Cutler-pattern indefinitely, no explicit seam**: Rejected. Without a documented seam, the upgrade path becomes a rebuild when the triggers are reached. The seam costs little to specify now and preserves optionality.

**Custom agent framework (Dify, Langflow, etc.)**: Rejected. Third-party dependency. Higher maintenance burden. Locks to a vendor's orchestration model. Violates the Cognitive Load Tax principle and the stewardship / transferability constraint.
