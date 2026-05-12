# DESIGN Decisions — coach-buddy-architecture

## Key Decisions
- [D1] Explicit orchestration: SKILL.md is the authoritative, visible orchestrator (ADR-001)
- [D2] Attribution: `Name (Source)` first mention; 6 coach-originating interest signals; deep-dive pull-based (ADR-002)
- [D3] Mode management: coaching-register language only; no tool-specific interruptions (ADR-003)
- [D4] Ask when ambiguous: 2 mode signals + no stakes + topic discontinuity → ask (ADR-004)
- [D5] High-stakes tiebreaker: stated OR prompted stakes → situation-focus wins (ADR-005)
- [D6] Architecture seam: Cutler-pattern now; nWave upgrade preserves all content (ADR-006)

## Architecture Summary
- Pattern: Cutler-pattern (SKILL.md orchestrator + reference files + assets)
- Paradigm: Not applicable — configuration architecture, not code
- Key components: SKILL.md, Framework Library (references/), Calibration Canvas, Output Template

## Reuse Analysis
Greenfield. No existing components.

## Technology Stack
- Runtime: Claude Chat Project (Anthropic)
- Orchestration: SKILL.md (Markdown, named sections)
- Knowledge: Markdown reference files
- Testing: Manual conversation review

## Constraints Established
- SKILL.md must use named sections (maps to nWave agent roles)
- Reference files organised as separate markdown files per domain (maps to SSOT on upgrade)
- All mode management language must be from coaching practice register
- Stakes determination: stated or prompted — never inferred from language patterns alone
- Context window is the binding constraint on reference file library size

## Underdetermined Flags — Resolved
All four DISCUSS flags resolved in DESIGN:
- D2: 6 explicit interest signals defined (ADR-002)
- D4: Three-condition ambiguity threshold + worked example (ADR-004)
- D5: Coach-stated OR stakes-prompted rule; no inference from language patterns (ADR-005)
- D6: Upgrade seam table specified; upgrade triggers listed (ADR-006)

## Upstream Changes
- DISCUSS open question ("what triggers the upgrade?") resolved: upgrade trigger list in ADR-006
- DISCUSS open question ("who determines stakes?") resolved: stated or prompted (ADR-005)
- No DISCUSS user stories or ACs changed — all ADRs are consistent with DISCUSS requirements
