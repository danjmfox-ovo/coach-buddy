# Slice 03c: Graceful Degradation (No Reference Files)

**Goal**: Verify that a minimal install (custom-instructions.md + SKILL.md only, no reference files) produces reliably useful coaching output — degradation is acceptable, not catastrophic.

## IN Scope
- Team project with only `custom-instructions.md` (custom instructions) + `SKILL.md` (project knowledge) — no `references/frameworks/` files, no `assets/calibration-canvas.md`
- Full thinking-partner conversation invoked via `/coach-buddy`
- Quality assessment against the degradation bar (see ACs)

## OUT of Scope
- Comparing minimal-install quality to full-install quality in a controlled way (future)
- Identifying which specific frameworks are degraded without reference files

## Learning Hypothesis
Disproves: "SKILL.md without reference files degrades catastrophically — the tool becomes confused, unhelpful, or actively misleading."
Confirms: Built-in framework descriptions in SKILL.md are sufficient for reliably useful situation-focus coaching; degradation from "good" to "reliably sharp" not from "good" to "broken."

## Acceptance Criteria
- A complete thinking-partner conversation (3+ turns) in a minimal install produces responses that:
  1. Name at least one symptom or dynamic beyond restating the coach's description
  2. Include at least one framework attribution using a primary lens (e.g. "Cynefin (Snowden)") — drawn from SKILL.md built-in descriptions
  3. Offer at least one question that advances the coach's thinking
  4. Do NOT surface an error message, degraded-mode warning, or "I can't help without more files" response
- Coach self-reports the minimal-install conversation as useful: clearly better than thinking through the situation alone
- Tool does not hallucinate framework citations — all attributions are drawn from SKILL.md's primary/secondary lens lists

## Dependencies
- Slice 03a complete: install procedure validated
- Team project stripped of reference files (or use a fresh install without uploading them)

## Effort Estimate
~1 hour (configure minimal install + run 1 real conversation)

## Reference Class
Configuration regression test. Done when one conversation completes with all ACs met.

## Note
SKILL.md already contains the graceful degradation statement (v1.1):
> "Reference files now explicitly optional — SKILL.md is self-sufficient; reference files enrich when present."

This slice validates that the claim holds in practice.
