# DISCUSS Decisions — coach-buddy-slice-03

## Key Decisions
- [D-W1] Feature typed as cross-cutting: spans deployment/install (J5), in-context activation behaviour (J3), and acceptance validation design
- [D-W2] No new walking skeleton: architecture is proven (Slices 01-02 validated). This wave validates the existing skeleton in a new deployment context (portable team project)
- [D-W3] JTBD referenced, not re-derived: J3 and J5 are in jobs.yaml with full four forces and dimensions; grounded stories in existing job IDs without repeating analysis
- [D-W4] Three thin validation sub-slices (03a → 03b → 03c): sequential, each ≤2 hours, each with a distinct learning hypothesis; ordered by learning leverage
- [D-W5] Graceful degradation quality bar operationalised in Story 3 ACs: names a dynamic, makes an attribution, offers a useful question, no error surfaced — DESIGN should codify as ADR-007 or SKILL.md addition

## Requirements Summary
- Primary jobs: J3 (in-context-activation) and J5 (portable-across-teams) — both `validated: false`; Slice 03 validates both
- Walking skeleton scope: real team project + minimal install (custom-instructions.md + SKILL.md) + `/coach-buddy` produces a useful thinking-partner conversation
- Feature type: cross-cutting (deployment/install, coaching pipeline behaviour, acceptance testing)

## Constraints Established
- Validation must use a real team project — not a test/synthetic project (Stories 2 and 3 ACs require "real engagement")
- Install procedure limited to exactly two steps (README constraint; adding steps would fail Story 1 AC)
- No changes to SKILL.md content in this slice — validate the claim, don't change it
- Graceful degradation: all framework attributions must be from SKILL.md primary/secondary lens lists — no hallucinated citations

## Underdetermined Flags for DESIGN
1. **D8 — Graceful degradation quality bar**: Story 3 ACs define an operational bar but it is not yet encoded in SKILL.md or an ADR. DESIGN should produce ADR-007 (or a SKILL.md amendment) to make this explicit.
2. **D9 — Discovery hint**: `custom-instructions.md` currently hints that `/coach-buddy` is available. Sufficient for now; flag for review if usage data shows discoverability problems.

## Upstream Changes
No changes to prior wave artifacts. J3 and J5 definitions in jobs.yaml stand. New SSOT artifact bootstrapped: `docs/product/journeys/coaching-in-team-project.yaml`.
