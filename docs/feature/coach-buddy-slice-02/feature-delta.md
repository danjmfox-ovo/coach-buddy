# Feature Delta: coach-buddy-slice-02
# Wave: DISCUSS (2026-05-12)
# Density: lean + ask-intelligent

---

## Wave: DISCUSS / [REF] Persona ID

**Persona**: `agile-coach` — same as Slice 01.
Full profile: `docs/product/personas/agile-coach.yaml`

---

## Wave: DISCUSS / [REF] JTBD One-Liner

**Primary job (J2)**: When working through a coaching situation, the coach wants to encounter relevant frameworks at natural moments — introduced when interest is signalled, not imposed — so their repertoire grows through real cases without disrupting their thinking flow.

**Relationship to Slice 01**: Slice 01 proved the tool can hold situation-focus. Slice 02 proves J2 can coexist with J1 — that framework discovery doesn't break the situation-focus thread.

**Learning hypothesis**: Disproves "surfacing framework discovery during situation-focus conversations will disrupt the coach's thinking flow." Confirms: with explicit interest signals and coaching-register language, J2 can operate without undermining J1.

---

## Wave: DISCUSS / [REF] Locked Decisions

All six ADRs from Slice 01 carry forward. Slice 02 puts D2, D3, D4 into practice for the first time. ADR-007 (DNA arc) also makes its first live appearance.

| ID  | Decision | Slice 02 impact |
|-----|----------|-----------------|
| D2  | 6 interest signals; deep-dive pull-based | This is the core mechanic of Slice 02 |
| D3  | Coaching frames for mode management | All redirects and ambiguity checks must use coaching register |
| D4  | Ask when 3 conditions met; do not ask otherwise | Ambiguity check story is D4 in practice |
| D5  | Situation-focus wins on stated stakes | Validated in Slice 01; regression-guarded; not a new story here |
| D1, D6 | Orchestration seam, upgrade path | No change |
| ADR-007 | DNA arc | N-phase is where framework discovery lives; transitions named |

---

## Wave: DISCUSS / [REF] User Stories with Elevator Pitches

### Story 1 — Interest Signal to Framework Offer
`job_id: growth-vehicle`

**As** an Agile Coach working through a situation,
**I want** the tool to detect my interest in a concept and offer to go deeper — without auto-delivering —
**so that** I can choose to explore it without losing my diagnostic thread.

#### Elevator Pitch
Before: Coach mentions "psychological safety" twice — tool either ignores it or delivers a lecture.
After: Interest signal fires → tool says "I can go deeper on Psychological Safety (Edmondson) if that would be useful — just say the word."
Decision enabled: Coach decides whether to pivot into N-phase exploration or continue in D-phase situation-focus.

**Acceptance Criteria**:
- When any of the 6 interest signals fires, tool offers "I can go deeper on [Name] if that would be useful — just say the word"
- Tool does NOT auto-deliver the deep-dive — offer only
- If coach declines, conversation continues in current phase without friction
- If offering a named framework not yet attributed in this conversation, attribution included in the offer: `Name (Author/Source)`
- Offer fires once per concept per conversation — no re-prompting

---

### Story 2 — Situated Framework Deep-Dive
`job_id: growth-vehicle`

**As** an Agile Coach who has accepted a deep-dive offer,
**I want** a focused exploration of the framework grounded in my current situation,
**so that** my learning is connected to a real case rather than abstract theory.

#### Elevator Pitch
Before: Coach says "yes, go deeper" → tool delivers a generic textbook summary with no connection to what was just described.
After: Coach accepts offer → tool delivers: what the framework is (one sentence) + how it maps to this specific situation (2-3 sentences) + one practical implication for the coach's next move.
Decision enabled: Coach decides whether this framework changes how they'd approach the intervention.

**Acceptance Criteria**:
- Deep-dive is anchored to the specific situation described — not generic
- Structure: what it is (1 sentence) + how it applies here (2-3 sentences) + one practical implication
- After deep-dive, tool returns to Phase A: "what's your read on that?"
- Attribution: `Name (Author/Source)` if not yet attributed; name only if already attributed in this conversation
- Deep-dive does not introduce additional unrequested frameworks

---

### Story 3 — Mode Management Redirect
`job_id: thinking-partner`

**As** an Agile Coach whose focus has shifted mid-conversation,
**I want** the tool to use a standard coaching question to help me reorient,
**so that** I can re-establish focus without feeling managed or interrupted by tool-specific language.

#### Elevator Pitch
Before: Topic shift without resolution → tool either drifts silently or says "I notice we've changed topics" (breaks coaching register).
After: Topic shift detected at turn boundary → tool asks "What do you want to achieve here today?" → coach can reorient or explicitly continue the new thread.
Decision enabled: Coach consciously decides whether to follow the new thread or return to the original situation.

**Acceptance Criteria**:
- Redirect uses one of the four registered phrases only: "What do you want to achieve here today?" / "Is this the real topic?" / "What would be most useful right now?" / "Where do you want to focus?"
- Redirect fires ONLY at natural turn boundaries — not mid-thought
- If coach continues the new thread after redirect, tool follows without re-firing
- Redirect does NOT use tool-specific language ("I notice we've shifted topics", "switching modes", "entering X mode")

---

### Story 4 — Ambiguity Check
`job_id: thinking-partner`

**As** an Agile Coach in an ambiguous conversational state,
**I want** the tool to ask which direction to take rather than defaulting,
**so that** I don't receive situation-focus help when I wanted exploration, or vice versa.

#### Elevator Pitch
Before: Coach shifts from a specific situation to a general learning question — tool picks a mode silently and proceeds.
After: All three conditions present → tool asks "Do you want to stay with [X] or pick up [Y]?" → coach directs the next move.
Decision enabled: Coach consciously chooses mode rather than having it silently imposed.

**Acceptance Criteria**:
- Tool asks ONLY when all three conditions are true: (1) signals from both situation-focus and learning-mode present, (2) no stakes statement made, (3) topic discontinuity present
- Question uses coaching language only: "Do you want to stay with [X] or pick up [Y]?"
- Tool does NOT ask if only one or two conditions are met — unnecessary friction
- If stakes have been stated as consequential, tool defaults to situation-focus without asking (D5 — no new story needed)

---

## Wave: DISCUSS / [REF] Definition of Done

- [x] JTBD: J2 already validated in `docs/product/jobs.yaml` — no re-analysis required
- [x] Job dimensions: functional / emotional / social documented for J2 in jobs.yaml
- [x] Four Forces: documented for J2 in jobs.yaml
- [x] Journey: validated in Slice 01 — no new journey work for Slice 02
- [x] Story map: single slice, 4 stories, all within 1-slice bounds
- [x] User stories trace to job IDs (J2 × 2, J1 × 2)
- [x] All ACs testable by conversation review
- [x] Scope assessed: PASS
- [ ] Outcome KPIs defined — see below
- [ ] DoR validated — follow-up artifact

---

## Wave: DISCUSS / [REF] Out of Scope

- Framework curriculum or structured learning path
- Cross-session memory of which frameworks the coach has previously encountered
- Automated framework recommendation without situational grounding or interest signal
- D5 (high-stakes tiebreaker) — validated in Slice 01, regression-guarded in walking-skeleton.feature, not a new story
- DNA arc A-phase behaviour — validated in Slice 01 (v1.2), regression-guarded

---

## Wave: DISCUSS / [REF] WS Strategy

**No new walking skeleton** — Slice 01 is the skeleton and is live.

Slice 02 is a direct extension: adds interest detection, deep-dive delivery, mode redirects, and ambiguity checks to an already-functional SKILL.md. Testing strategy: Strategy C (real-IO, manual conversation review) — same as Slice 01.

**Acceptance signal**: A coach works through a situation that triggers a natural interest signal, receives a framework offer, accepts the deep-dive, and reports that the situation-focus thread was not disrupted.

---

## Wave: DISCUSS / [REF] Driving Ports

Same as Slice 01:

| Port | Surface |
|------|---------|
| Coach turn | Claude Chat Project conversation |

No new inbound surfaces in Slice 02.

---

## Wave: DISCUSS / [REF] Pre-Requisites

| Dependency | Source | Status |
|------------|--------|--------|
| Slice 01 validated and live | Slice 01 trial | Done |
| D2 interest signals specified (6 explicit) | ADR-002 | Done |
| D3 coaching register confirmed | ADR-003 | Done |
| D4 ambiguity threshold specified | ADR-004 | Done |
| D5 tiebreaker specified | ADR-005 | Done |
| ADR-007 DNA arc | ADR-007 | Done |
| ER-004 fix: framework vocabulary attribution | Done | Resolved in SKILL.md v1.3 (vocabulary exemption removed) |

---

## Wave: DISCUSS / [REF] Outcome KPIs

| KPI | Target | Measurement |
|-----|--------|-------------|
| Interest signal fires without false positives | <1 false positive per 10 conversations | Manual review of first 10 conversations |
| Deep-dive anchored to situation (not generic) | 100% of delivered deep-dives reference current situation | Manual review |
| Mode redirect uses coaching register only | 100% compliance — zero tool-specific phrases | Manual review of first 20 conversations |
| Coach consciously directs mode after ambiguity check | Coach confirms direction >90% of the time | Spot-check in sessions |
| J2 does not disrupt J1 (learning hypothesis confirmed) | Coach self-reports no flow disruption in >80% of framework-touched conversations | Post-conversation self-report |

---

## Wave: DISCUSS / [REF] Scope Assessment

**Signal check**:
- User stories: 4 (within bounds)
- Bounded contexts: 2 (orchestration, UX behaviour)
- Walking skeleton integration points: 1 (SKILL.md extension)
- Independent outcomes that could ship separately: No clean split — interest detection, deep-dive, redirect, and ambiguity check depend on the same mode-management layer

**Verdict**: PASS — right-sized, single slice.

---

## Wave: DESIGN / [REF] DDD List

All Slice 01 ADRs carry forward unchanged. Slice 02 puts D2, D3, D4, and ADR-007 into practice for the first time.

| ADR | Title | Slice 02 story | Role in this slice |
|-----|-------|----------------|--------------------|
| ADR-001 | Explicit orchestration | All stories | SKILL.md remains the authoritative behavioural source; all new rules go there |
| ADR-002 | Attribution on first mention + interest signals | Story 1, Story 2 | D2 — 6 signals, pull-based offer, first-live implementation |
| ADR-003 | Coaching frames for mode management | Story 3 | D3 — four registered redirect phrases, no tool-specific language |
| ADR-004 | Ask rather than assume | Story 4 | D4 — three-condition gate, coaching-language question |
| ADR-005 | Situation focus wins at high stakes | Story 4 (boundary condition) | Governs when ambiguity check does NOT fire (stakes stated → no ask) |
| ADR-006 | Cutler-to-nWave upgrade seam | All stories | No change; SKILL.md line count still well within 500-line trigger |
| ADR-007 | DNA conversation arc | Story 1, Story 2 (N-phase) | N-phase is where framework discovery lives; Story 2 deep-dive is the N-phase body |

**No new ADRs required.** All Slice 02 behaviours are implementations of decisions already made. No new decision with lasting architectural consequence has emerged.

One pre-requisite status confirmation: ER-004 (vocabulary attribution fix) was listed as "Outstanding" in the DISCUSS artifacts. Inspection of SKILL.md v1.3 confirms it is resolved — the Attribution section already reads: "There is no vocabulary exemption: if the concept has a named source, it requires attribution on first use regardless of whether it is being introduced as a framework or used naturally in a sentence." No SKILL.md change needed for ER-004.

---

## Wave: DESIGN / [REF] Component Decomposition

The single component being changed is SKILL.md (the orchestrator). Four targeted additions are required — one per story. All are EXTEND operations on existing named sections.

### Change 1 — Interest signal offer behaviour (Story 1)

**Section**: `## Attribution` (the interest signals paragraph already exists)

**Current state**: The section specifies the 6 interest signals and the offer phrase "I can go deeper on [Name] if that would be useful — just say the word." It does not specify:
- The one-per-concept-per-conversation constraint (no re-prompting)
- That the offer includes attribution if the concept has not yet been attributed in this conversation

**Addition required**: After the offer phrase, add two rules:

> An offer fires once per concept per conversation — no re-prompting if declined.
> If offering a named framework or theory not yet attributed in this conversation, include attribution in the offer: `"I can go deeper on [Name (Author/Source)] if that would be useful — just say the word."`

**Placement**: Append to the existing interest-signal paragraph in the Attribution section (after "Do not auto-deliver.").

**Why here**: Attribution and interest signals are co-located in SKILL.md already (ADR-002 governs both). Adding the constraint and attribution-in-offer rule in the same paragraph keeps the rule local and avoids cross-section navigation.

---

### Change 2 — Deep-dive delivery structure (Story 2)

**Section**: `## Delivery` (Phase B paragraph)

**Current state**: "Phase B — on request: In-depth analysis, framework deep-dives, worked options. Only when the coach asks or signals interest." This is a mode description, not a delivery specification.

**Addition required**: Add a named sub-rule for situated deep-dives:

> **Situated deep-dive (Phase B, on accept)**: When the coach accepts a deep-dive offer, deliver in this structure:
> 1. What it is — one sentence
> 2. How it applies to this specific situation — two to three sentences (must reference the situation as described; no generic summary)
> 3. One practical implication for the coach's next move
>
> After delivery, return to Phase A: "what's your read on that?" or equivalent. Do not introduce additional unrequested frameworks within the deep-dive.
> Attribution: `Name (Author/Source)` if not yet attributed in this conversation; name only if already attributed.

**Placement**: Append immediately after the existing Phase B line in the Delivery section.

**Why here**: Phase B delivery is already defined in the Delivery section. The deep-dive structure is a Phase B variant — it belongs alongside Phase B, not in a separate section.

---

### Change 3 — Mode redirect specificity (Story 3)

**Section**: `## Mode management` (Mode redirects sub-section)

**Current state**: The section already lists the four redirect phrases and the timing constraint. It does not specify:
- That the four phrases are the complete permitted set (exhaustive, not illustrative)
- That the redirect does NOT use tool-specific language (a prohibition that lives in ADR-003 but is not surfaced in SKILL.md)

**Addition required**: After the four bullet phrases, add one clarifying rule:

> These four phrases are the complete permitted set for redirects. Do not use tool-specific language: phrases like "I notice we've shifted topics", "switching modes", or "returning to our earlier topic" are not coaching language and must not appear.
> If the coach continues the new thread after a redirect, follow without re-firing.

**Placement**: Append to the existing Mode redirects sub-section, after "Fire at natural turn boundaries only."

**Why here**: The four phrases are already listed there. The prohibition and the follow-behaviour note belong adjacent to the phrases they govern.

**Note**: The second sentence ("If the coach continues the new thread after a redirect, follow without re-firing") extends the existing "If the coach continues the new thread after a redirect, follow" to add "without re-firing" — making the no-re-prompt constraint explicit in SKILL.md (mirrors the Story 1 constraint applied to redirects).

---

### Change 4 — Ambiguity check constraint (Story 4)

**Section**: `## Mode management` (When mode is ambiguous sub-section)

**Current state**: The section specifies all three conditions and the question format "Do you want to stay with [X] or pick up [Y]?" It does not specify:
- That the tool does NOT ask if only one or two conditions are met (the inverse constraint)
- That the D5 tiebreaker (stated stakes) suppresses the ask — this interaction is described in ADR-005 but is not surfaced in SKILL.md

**Addition required**: After the three-condition list, add:

> Ask only when all three conditions are simultaneously true. If only one or two conditions are met, default to the dominant mode signal without asking — unnecessary friction.
> If stakes have been stated as consequential or irreversible (see Tiebreaker section above), default to situation-focus without asking. The tiebreaker supersedes the ambiguity check.

**Placement**: Append to the existing "When mode is ambiguous" paragraph, after the use-coaching-language sentence.

**Why here**: The three conditions are already stated there. The inverse constraint ("do NOT ask if only 1 or 2 conditions met") and the D5 interaction belong immediately adjacent to the rule they qualify.

---

### Change 5 — N-phase deep-dive lifecycle (Story 1 + Story 2 combined, DNA arc)

**Section**: `## Conversation arc` (N — New topics paragraph)

**Current state**: "N — New topics: Exploration. Frameworks available on interest signal. The space for what else might be at play, what patterns this resembles, what the coach hasn't yet considered. J2 (growth vehicle) lives here. May be triggered early if the coach signals interest during D."

This describes N-phase as a space but does not specify the lifecycle within it: interest signal fires → offer → accept → situated deep-dive → return to D-phase question. Without this, the deep-dive could be delivered without returning to Phase A, or the conversation could remain in N-phase open-endedly.

**Addition required**: Append to the N-phase description:

> **N-phase lifecycle**: Interest signal detected → offer deep-dive → if accepted, deliver situated deep-dive (see Delivery: Phase B) → return to Phase A with one question ("what's your read on that?" or equivalent). If declined, continue the current thread without friction. After return from deep-dive, resume tracking D or A phase state — N is a branch, not a destination.

**Placement**: Append to the N paragraph in the Conversation arc section.

**Why here**: ADR-007 governs the DNA arc. The N-phase lifecycle is the behavioural contract for N — it should live in the arc description, with a cross-reference to Delivery for the deep-dive structure.

---

## Wave: DESIGN / [REF] Reuse Analysis

| Change | Section | Type | Justification |
|--------|---------|------|---------------|
| Change 1: Interest signal offer constraints | Attribution | EXTEND | Interest signals already specified in this section (ADR-002); adding one-per-concept and attribution-in-offer rules |
| Change 2: Deep-dive delivery structure | Delivery | EXTEND | Phase B already exists; adding the situated deep-dive sub-rule within Phase B |
| Change 3: Mode redirect specificity | Mode management | EXTEND | Four phrases already listed; adding exhaustive-set clarification and prohibition |
| Change 4: Ambiguity check constraint | Mode management | EXTEND | Three-condition rule already specified; adding inverse constraint and D5 interaction |
| Change 5: N-phase lifecycle | Conversation arc | EXTEND | N-phase description already exists; adding the offer→accept→deep-dive→return lifecycle |

**All five changes are EXTEND.** No new sections are required. The existing named section structure of SKILL.md accommodates all Slice 02 behaviour.

**Estimated line impact**: +20 to +28 lines. Current SKILL.md is 150 lines. Post-Slice-02 SKILL.md will be approximately 170-178 lines — well within the 500-line upgrade trigger (ADR-006).

---

## Wave: DESIGN / [REF] Open Questions

| ID | Question | Owner | Disposition |
|----|----------|-------|-------------|
| OQ-S2-1 | Exact phrasing of the "I can go deeper" offer when attribution is included in it — the rule specifies format `Name (Author/Source)` but the natural sentence construction needs authoring | DELIVER | Minor wording — no architectural consequence. Resolve in SKILL.md authoring pass during DELIVER. |
| OQ-S2-2 | "What's your read on that?" is specified as the post-deep-dive return phrase. Is this the registered phrase or an example? | DELIVER | If it is a registered phrase, add to the phrase list in SKILL.md. If it is an example, DELIVER authoring should pick a concrete phrase. Recommend registering it — prevents drift. |
| OQ-S2-3 | The mode redirect follow-behaviour currently reads "follow without re-firing." Does re-firing mean: never again in this conversation, or not until a new topic discontinuity? | DELIVER | Recommend "not until a new topic discontinuity" — mirrors the one-per-concept rule from Story 1. Confirm in DELIVER authoring. |
| OQ-S2-4 | ER-004 confirmed resolved in v1.3 — remove "Outstanding" status from DISCUSS pre-requisites table and DISCUSS wave-decisions.md at handoff | DELIVER | Housekeeping. No architectural consequence. |
