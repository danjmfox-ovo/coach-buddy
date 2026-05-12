# DESIGN Decisions — coach-buddy-slice-03

## Key Decisions
- [D7] Two-layer install model — `custom-instructions.md` as always-on Custom Instructions + `SKILL.md` as invocable Project Knowledge: separates ambient coaching sensibility from full pipeline activation (see: [ADR-008](../../../product/architecture/adr-008-portable-install-two-layer-model.md))
- [D8] Graceful degradation quality bar — encoded in both ADR-008 and SKILL.md `## Minimal install behaviour` section: names a dynamic, one attribution from primary lens list, one advancing question, no error surfaced (see: [ADR-008](../../../product/architecture/adr-008-portable-install-two-layer-model.md))
- [D9] Discovery hint in `custom-instructions.md` is sufficient for v1 — deferred watch item; revisit if usage data shows coaches not finding `/coach-buddy`

## Architecture Summary
- Pattern: Cutler-pattern, two-layer deployment variant
- Paradigm: Configuration architecture (no code)
- Key components: `custom-instructions.md` (lean layer, always-on), `SKILL.md` (full pipeline, invocable), reference files (optional enrichment)

## Reuse Analysis

| Existing Component | File | Overlap | Decision | Justification |
|---|---|---|---|---|
| SKILL.md | `SKILL.md` | Full pipeline orchestration | EXTEND | Added `## Minimal install behaviour` section (~10 lines) — no new component needed |
| custom-instructions.md | `custom-instructions.md` | Lean ambient layer | CREATE NEW (delivered commit 3c3e76f) | No prior component with this responsibility |
| ADR-007 | `docs/product/architecture/adr-007-*.md` | Decision record for D7 and D8 | CREATE NEW (this wave) | Novel decision — portable install model and degradation quality bar had no prior ADR |

## Technology Stack
- Runtime: Claude (Anthropic) via Chat Project — unchanged
- Orchestration: SKILL.md (Cutler-pattern, two-layer variant) — SKILL.md as Project Knowledge activated by `/coach-buddy` prefix
- Testing: Manual conversation review in real team project — unchanged

## Constraints Established
- SKILL.md activation is a soft convention (`/coach-buddy` prefix causes model to draw on SKILL.md from Project Knowledge) — not a registered command
- All framework attributions in minimal install must draw from SKILL.md primary/secondary lens lists — no hallucination permitted
- Quality bar is a floor, not a ceiling — minimal install may be less deep on frameworks than full install; this is expected

## Upstream Changes
None. DISCUSS requirements stand. Story ACs unchanged. The quality bar (D8) operationalises what DISCUSS called "reliably sharp" — same concept, now concrete and testable.
