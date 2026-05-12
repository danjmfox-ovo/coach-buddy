# DISCUSS Decisions — coach-buddy-slice-02

## Key Decisions

- [D-S2-1] JTBD re-analysis skipped: J2 (growth-vehicle) is validated in docs/product/jobs.yaml; all stories trace to existing job IDs
- [D-S2-2] Single slice: no Elephant Carpaccio split — interest detection, deep-dive, redirect, and ambiguity check are mutually dependent on the same mode-management layer
- [D-S2-3] D5 (high-stakes tiebreaker) is not a new story — validated in Slice 01, regression-guarded in walking-skeleton.feature
- [D-S2-4] ER-004 (framework vocabulary attribution) must be resolved in SKILL.md before Slice 02 trial begins — it is a pre-requisite, not a new story

## Requirements Summary

- Primary jobs: J2 (growth-vehicle) — interest detection + deep-dive; J1 (thinking-partner) — mode redirects + ambiguity check
- Walking skeleton: not needed — extends Slice 01
- Feature type: cross-cutting (orchestration + UX behaviour)

## Constraints Established

- Deep-dive must always be situationally grounded — no generic textbook summaries
- Interest signal fires once per concept per conversation — no re-prompting
- Mode redirect language: exactly the four registered coaching phrases; no tool-specific language
- Ambiguity check fires only when all three D4 conditions are met simultaneously
- After deep-dive, tool returns to Phase A — does not continue exploring unprompted

## Upstream Changes

None. All Slice 01 ADRs carry forward unchanged. ADR-007 (DNA arc) is additive.

## Open Flags for DESIGN

- ER-004: framework vocabulary attribution — SKILL.md fix needed (add attribution to cases where named concepts are used as vocabulary, not just as formal framework introductions)
- Exact phrasing of the "I can go deeper" offer (minor wording; DELIVER task)
