# Slice 03 Validation Findings

**Status**: Complete — 2026-05-12

**Test script**: `tests/acceptance/coach-buddy-slice-03/test-script.md`
**Feature**: `tests/acceptance/coach-buddy-slice-03/walking-skeleton.feature`
**Validated by**: Dan Fox
**Environment**: Full install (Scenarios 1-2), Minimal install (Scenario 3) — real Claude Chat team project

---

## Results

### Pre-run install check (Story 1, Slice 03a)

Time from README open to first /coach-buddy response: **~4.5 minutes**
Pass: **Yes**

Notes:
- Full install (custom-instructions.md + SKILL.md + reference files + assets) completed in ~4.5 min
- Lean layer active: no disclaimer, no opening protocol, Theory Y tone confirmed
- Full pipeline on `/coach-buddy hello`: disclaimer fired, one calibrating question, no mode/context/stakes triple-ask
- Observation: lean layer listed framework names (Cynefin, psychological safety, polarity thinking) without attribution in descriptive/inventory context — grey area; logged as watch item

### Scenario 1 — Full coaching conversation (Story 2, Slice 03b)

Pass: **Yes**
Coach self-report: Not formally recorded — conversation quality was strong; three-turn arc felt natural and useful

Notes:
- All five message 1 checklist items met
- All three message 2 checklist items met
- All four message 3 checklist items met
- "work-as-disclosed and work-as-done (Shorrock)" attributed correctly; inverted format (recurrence of Slice 02 watch item)
- ER-004 candidate: "psychological safety" (message 1) used without "(Edmondson)" — no vocabulary exemption in SKILL.md

### Scenario 2 — In-context activation with team artefacts (Story 2, Slice 03b)

Pass: **Yes**

Notes:
- Screenshot used for board context (not text paste) — worked well; tool read column names, assignees, and WIP distribution
- Board treated as coaching context throughout; no PM-mode prescription
- Significant time overhead: finding board, screenshotting, uploading — not conversation time. MCP path (CoWork + Jira) would eliminate this.
- ER-004 candidate: "in the Cynefin sense" (message 1) without "(Snowden)"

### Scenario 3 — Graceful degradation, minimal install (Story 3, Slice 03c)

Self-report rating: **Better** (implicit — coach assessed as generally valuable; comparison with vanilla Claude run)
Attribution audit: **Zero "Name (Source)" attributions across all 3 turns**
Pass: **Partial** — all criteria met except attribution requirement

Notes:
- No error, no degraded-mode warning, no "upload reference files" ✅
- Named dynamics beyond coach's words (three-disruption framing: identity, domain, tooling) ✅
- Concrete observations for next session, grounded in specific situation ✅
- Attribution criterion (at least one Name (Source) from primary lens list): **FAIL** — no attribution appeared in any turn
- Comparison run in vanilla Claude (no system prompt): similar attribution failure; same Cynefin/psychological safety vocabulary without attribution
- Confound: Dan's global CLAUDE.md (Theory Y, concise, opportunity-first) means vanilla baseline is not clean — to retest with true baseline use incognito Claude.ai or API with no system prompt (deferred)
- Attribution fail consistent across minimal install AND vanilla Claude — suggests ER-004 is a base model behaviour that SKILL.md is not reliably overriding for vocabulary use

### Regression guards

ER-001 (calibration loop): **Not formally run** — no calibration loop observed in any scenario; skipped by coach judgement
ER-002 (observation before question): **Pass** — all scenarios led with observation; no question-first turns observed
ER-004 (vocabulary attribution): **Fail** — see candidate ER-007 below

---

## Failures / Candidate ERs

### Candidate ER-007 — Attribution does not fire on vocabulary use, only on explicit framework introduction

**Scenarios affected**: Scenario 1 (message 1), Scenario 2 (message 1), Scenario 3 (all turns)

**What the tool did**: Used "psychological safety", "Cynefin", "polarity thinking" in conversational/vocabulary context without attribution. Attribution did fire when a framework was explicitly attributed as a source (e.g. "work-as-disclosed and work-as-done (Shorrock)").

**What it should do**: Per ER-004 (SKILL.md): "This applies whether the term is used as a named framework or as conversational vocabulary." No vocabulary exemption.

**New or recurrence**: Recurrence — Slice 02 watch items noted the same pattern. Now consistent enough across scenarios to escalate from watch item to candidate ER.

**Vanilla Claude comparison**: Same pattern observed in vanilla Claude without any system prompt influence — suggests the base model treats these terms as common vocabulary, not as attributed concepts. SKILL.md override is not reliably working.

**Proposed resolution**: Strengthen the attribution rule in SKILL.md with explicit examples of vocabulary use cases: "including when used in passing — 'psychological safety (Edmondson)' even in a sentence like 'this looks like a psychological safety (Edmondson) signal'."

**Decision**: Defer to Slice 04 / next SKILL.md iteration. Monitor whether it persists across sessions before actioning.

---

## Sign-off

Date validated: 2026-05-12
Validated by: Dan Fox
Overall Slice 03 verdict: **PASS with one candidate ER** (ER-007 — attribution on vocabulary use)
