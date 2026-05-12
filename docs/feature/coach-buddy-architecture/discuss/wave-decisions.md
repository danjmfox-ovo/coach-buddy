# DISCUSS Decisions — coach-buddy-architecture

## Key Decisions
- [D-W1] Feature typed as cross-cutting: touches orchestration, UX behaviour, and knowledge architecture simultaneously
- [D-W2] Walking skeleton scoped to Slice 01 (thinking partner, situation focus only): proves architecture risk before adding tension-prone Job 2 mechanics
- [D-W3] Natural 2-slice split adopted: Job 1 (thinking partner) ships first; Job 2 (growth vehicle) ships only after Slice 01 is validated
- [D-W4] Four underdetermined flags raised from the carry-in decisions (D2, D4, D5, D6): DESIGN must resolve these before Slice 02 can proceed to DISTILL

## Requirements Summary
- Primary jobs: (1) thinking partner — help the coach see clearly without introducing unrequested frameworks; (2) growth vehicle — introduce relevant frameworks at natural moments, on request or detected interest
- Walking skeleton scope: Slice 01 — configured Claude Chat Project (SKILL.md + reference files) handling one complete situation-focus conversation end-to-end
- Feature type: cross-cutting (orchestration + UX behaviour + knowledge architecture)

## Constraints Established
- Tool must not introduce frameworks without situational grounding or coach signal
- Attribution format: `Name (Source)` on first mention per conversation
- Mode management language must stay within the coaching register — no tool-specific interruptions
- Situation focus wins when stakes are stated as consequential or irreversible
- Architecture seam (Cutler-pattern) must remain upgradable to nWave-pattern without rebuild

## Underdetermined Flags for DESIGN
1. **D2 — Interest detection criteria**: What signals count as "detected interest"? Needs explicit criteria in the ADR.
2. **D4 — Ambiguity threshold**: When does the tool ask vs. default? Needs a decision boundary with worked example.
3. **D5 — Consequential/irreversible inference**: Does the coach state this, or does the tool infer it? What cues? Needs explicit scope.
4. **D6 — Cutler→nWave upgrade seam**: What triggers the upgrade? What does "without rebuilding from scratch" guarantee? Needs the seam specified.

## Upstream Changes
None — no DISCOVER artifacts existed. This wave bootstrapped the SSOT (docs/product/jobs.yaml, personas/agile-coach.yaml).
