# Feature Delta: coach-buddy-slice-03
# Waves: DISCUSS + DESIGN (2026-05-12)
# Density: lean + ask-intelligent

---

## Wave: DISCUSS / [REF] Persona ID

**Persona**: `agile-coach` — a practitioner working with teams and organisations to navigate complexity
Full profile: `docs/product/personas/agile-coach.yaml`

---

## Wave: DISCUSS / [REF] JTBD One-Liner

**Primary job (J3 — in-context-activation)**: When working inside a team's project, the coach wants to invoke thinking-partner support without switching away — so they can think through what they're observing while the triggering context is still in front of them.

**Supporting job (J5 — portable-across-teams)**: When coaching multiple teams, the coach wants to add thinking-partner capability to any project with a minimal install — so setup cost does not scale with the number of engagements.

**Slice 03 focus**: Both jobs are already in the SSOT (jobs.yaml, marked `validated: false`). This slice validates them through real use — install, invocation, and graceful degradation under minimal configuration.

---

## Wave: DISCUSS / [REF] Locked Decisions

> Carry-in from prior waves. Architecture for portable install is already in place (commit 3c3e76f).

| ID | Decision | Verdict | Reference |
|----|----------|---------|-----------|
| D1 | Explicit orchestration over implicit | Locked | [ADR-001](../../product/architecture/adr-001-explicit-orchestration.md) |
| D2 | Attribution on first mention; 6 interest signals; deep-dive pull-based | Locked | [ADR-002](../../product/architecture/adr-002-attribution-on-first-mention.md) |
| D3 | Coaching frames for mode management (no tool-specific language) | Locked | [ADR-003](../../product/architecture/adr-003-coaching-frames-mode-management.md) |
| D4 | Ask when 2 mode signals + no stakes + topic discontinuity | Locked | [ADR-004](../../product/architecture/adr-004-ask-rather-than-assume.md) |
| D5 | Situation focus wins when stakes stated OR stakes prompt elicited | Locked | [ADR-005](../../product/architecture/adr-005-situation-focus-high-stakes.md) |
| D6 | Cutler-pattern now; nWave-pattern upgrade seam explicit | Locked | [ADR-006](../../product/architecture/adr-006-cutler-to-nwave-upgrade-seam.md) |
| D7 | Two-layer install model: `custom-instructions.md` (lean always-on) + `SKILL.md` as project knowledge (invocable) | Implemented — awaiting ADR-007 | Commit 3c3e76f; `README.md` team project install path |

**Underdetermined flags for DESIGN/DELIVER**:

- 🤔 **D8 — Graceful degradation quality bar**: SKILL.md states "quality degrades gracefully, not catastrophically" but the quality bar is not yet operationalised. What concretely separates "reliably sharp" from "degraded"? Story 3 ACs provide a working definition — DESIGN should codify this in the SKILL.md or a new ADR.
- 🤔 **D9 — Discovery hint for team project users**: When a team member (not the coach) is in a project with Coach Buddy installed, should they see any signal that `/coach-buddy` is available? `custom-instructions.md` currently includes the hint inline. This is sufficient for now; revisit if usage data suggests discoverability is a problem.

---

## Wave: DISCUSS / [REF] User Stories with Elevator Pitches

### Story 1 — Portable Install
`job_id: portable-across-teams`

**As** an Agile Coach coaching multiple teams across separate Claude Chat Projects,
**I want** to install Coach Buddy into any team project by pasting `custom-instructions.md` into custom instructions and uploading `SKILL.md` as project knowledge,
**so that** I can access thinking-partner support in any engagement context without maintaining a separate dedicated coaching project.

#### Elevator Pitch
Before: Coach maintains one dedicated coaching project and switches to it for every situation, losing the team artefacts that triggered the thought.
After: Coach pastes `custom-instructions.md` into team project custom instructions, uploads `SKILL.md` as project knowledge → types `/coach-buddy` in any conversation → full thinking-partner pipeline responds.
Decision enabled: Whether to use this team project as a coaching context from now on, or continue using the dedicated coaching project.

**Acceptance Criteria**:
- Following the README "team project" install path completes in ≤10 minutes without consulting any other documentation
- After install: a new conversation in the team project reflects the lean coaching sensibility from `custom-instructions.md` (Theory Y stance, attribution rule, no performative affirmations) without activating the full SKILL.md pipeline automatically
- The full SKILL.md pipeline activates only on explicit `/coach-buddy` invocation, not on every message
- Install requires exactly two steps: paste `custom-instructions.md`, upload `SKILL.md` (reference files optional)

---

### Story 2 — In-Context Activation
`job_id: in-context-activation`

**As** an Agile Coach working in a team project where Coach Buddy is installed,
**I want** to type `/coach-buddy` followed by a situation description and receive thinking-partner coaching grounded in what I can see in the current conversation,
**so that** I can work through what I'm observing without switching to a separate project and reconstructing the context from memory.

#### Elevator Pitch
Before: Coach notices a dynamic in a sprint board or decision doc → must switch to a dedicated coaching project, lose sight of the triggering artefacts, and reconstruct the situation from memory.
After: Coach types `/coach-buddy My team are doing X, I'm noticing Y` in the team project → tool responds with one observation from the description + one calibrating question → coaching continues alongside the triggering context.
Decision enabled: Whether the situation warrants a structured coaching conversation or just a quick reframe in the current conversation.

**Acceptance Criteria**:
- `/coach-buddy [description]` activates the full SKILL.md pipeline: opening protocol, mode management, Phase A delivery
- First response: one observation from the coach's description, then one calibrating question — not all three calibration signals upfront
- Coach can reference team artefacts visible in the project (sprint data, decision text, retro notes) and receive situation-grounded reflection without the tool conflating team context with coaching context
- A full thinking-through conversation (3+ turns) completes without: (a) unrequested framework introductions, (b) tool-specific interruptions breaking coaching register, (c) calibration loop without exit
- Coach self-reports the conversation as useful in a free-form post-conversation note

---

### Story 3 — Graceful Degradation
`job_id: in-context-activation`

**As** an Agile Coach who has installed only `custom-instructions.md` and `SKILL.md` (no reference files),
**I want** the thinking-partner pipeline to produce useful responses using SKILL.md's built-in framework descriptions,
**so that** I can trust the tool's quality in a minimal install and make an informed decision about whether to invest in uploading reference files.

#### Elevator Pitch
Before: Coach doesn't install the tool into team projects because quality feels unpredictable — worried it will be useless or confusing without the reference library.
After: Coach invokes `/coach-buddy [situation]` in a minimal install → receives a situation-focused response that names a dynamic, makes at least one framework attribution from the built-in primary lens list, and offers a question that advances thinking.
Decision enabled: Whether to proceed with the minimal install as-is or invest time uploading reference files for deeper framework coverage.

**Acceptance Criteria**:
- A complete thinking-partner conversation (3+ turns) in a minimal install produces responses that:
  1. Name at least one symptom or dynamic beyond restating the coach's description
  2. Include at least one framework attribution using a primary lens from SKILL.md (e.g. "Cynefin (Snowden)") — drawn from built-in descriptions, not reference files
  3. Offer at least one question that advances the coach's thinking
  4. Do NOT surface an error message, degraded-mode warning, or "I can't help without reference files" response
- Coach self-reports the minimal-install conversation as useful: clearly better than thinking through the situation alone
- All framework attributions are drawn from SKILL.md's primary/secondary lens lists — no hallucinated citations

---

## Wave: DISCUSS / [REF] Definition of Done

- [ ] Install procedure validated with a real team project
- [ ] `/coach-buddy` invocation tested and pipeline activates correctly
- [ ] Graceful degradation tested in minimal install (no reference files)
- [ ] All story ACs verified through real conversations (not synthetic)
- [ ] Coach self-report captured for Story 2 and Story 3
- [ ] J3 and J5 updated in jobs.yaml: `validated: true` (after Stories 2 and 1 pass respectively)
- [ ] Journey SSOT bootstrapped: `docs/product/journeys/coaching-in-team-project.yaml`
- [ ] Slice 03 findings documented (what worked, what didn't, any emerged requirements)

---

## Wave: DISCUSS / [REF] Out of Scope

- Testing install paths for Claude Code and Cursor (documented in README; not this slice)
- `npx skills add` install path (documented in README; requires npm package, not yet published)
- Cross-session memory or coaching continuity across separate team project conversations
- Testing with multiple teams (J5 aspirational validation — falls out naturally once J3 is validated)
- Quantitative quality comparison between minimal-install and full-install
- Any changes to SKILL.md content (this slice validates, does not implement)

---

## Wave: DISCUSS / [REF] WS Strategy

**Strategy B — Brownfield validation**: The walking skeleton (Slices 01 and 02) is proven. The architecture is in place (SKILL.md, custom-instructions.md, README two-layer install model). This slice validates the skeleton in a new deployment context (team project, portable install).

**Walking skeleton for Slice 03**: A real team project with Coach Buddy installed (minimal: custom-instructions.md + SKILL.md) where the coach completes a useful thinking-partner conversation via `/coach-buddy` without reference files and without switching to a dedicated coaching project.

**Validation signal**: Coach completes a 3+ turn coaching conversation in a real team project context, rates it as useful, and finds no SKILL.md behavioural rule violations.

---

## Wave: DISCUSS / [REF] Driving Ports

| Port | Surface | Description |
|------|---------|-------------|
| `/coach-buddy` invocation | Team project conversation | Primary inbound: coach activates full pipeline with this slash command |
| Lean always-on | Team project custom instructions | `custom-instructions.md` — coaching sensibility active without pipeline activation |
| Coach turn | Team project conversation | Subsequent turns in an active coaching conversation |

---

## Wave: DISCUSS / [REF] Pre-requisites

- Slices 01 and 02 complete and validated (the pipeline being deployed is proven)
- SKILL.md v1.6 in place (CHANGELOG.md: reference files explicitly optional — self-sufficient)
- `custom-instructions.md` and `SKILL.md` available in the repo (delivered by commit 3c3e76f)
- A real Claude Chat team project accessible for validation (not a dedicated coaching project)

---

## Wave: DISCUSS / [REF] Scope Assessment

**Signal check**:
- User stories: 3 ✓ (within bounds)
- Bounded contexts: 2 (deployment/install; coaching pipeline behaviour) ✓
- Walking skeleton integration points: 3 (custom-instructions.md, SKILL.md as knowledge, `/coach-buddy` invocation trigger) ✓
- Independent outcomes that could ship separately: Yes — Stories 1, 2, 3 are sequentially dependent (install → invoke → degrade) but each validates a distinct hypothesis
- Effort: ~1 day total (03a ~1h, 03b ~2h, 03c ~1h, documentation ~1h)

**Verdict**: Scope Assessment: PASS — right-sized. Three thin validation sub-slices; sequential dependencies but each ≤2 hours.

---

## Wave: DISCUSS / [REF] Outcome KPIs

| KPI | Target | Measurement |
|-----|--------|-------------|
| Install takes ≤10 minutes end-to-end | 100% of install attempts | Time from README open to first `/coach-buddy` response |
| `/coach-buddy` activates full pipeline | 100% of invocations in correctly-installed projects | Manual check: first response includes observation + calibrating question |
| Minimal-install conversations rated useful | ≥80% of sessions | Coach self-report after each session (free-form note) |
| No SKILL.md behavioural rule violations in team project context | 0 violations per conversation | Manual review against ACs for Stories 2 and 3 |
| J3 validated (coach uses in-context activation in a real engagement) | 1 real engagement | Coach confirms tool used in a live team project, not a test project |

---

## Wave: DISCUSS / [REF] Story Map

**Backbone (activities)**:
Install → Activate → Validate Behaviour

**Walking skeleton** (minimum end-to-end value):
Slice 03a (Install) → Slice 03b (Activate) → first useful coaching conversation in a team project

**Slice execution order** (learning leverage):
1. **Slice 03a** first: validates the install procedure; blocks nothing if it fails (just update README)
2. **Slice 03b** second: validates in-context activation; highest-value hypothesis (J3 core)
3. **Slice 03c** third: validates graceful degradation; resolves the anxiety force in J3 and J5

This order minimises waste: if install fails (03a), we fix before running conversations. If invocation fails (03b), we know before testing degradation (03c).

---

## Wave: DISCUSS / [REF] DoR Validation

| DoR Item | Evidence | Status |
|----------|----------|--------|
| 1. Who benefits is clear | Agile coach coaching multiple teams via Claude Chat Projects | ✓ |
| 2. What they're doing is clear | 3 stories: install, invoke, degrade gracefully | ✓ |
| 3. Why they're doing it is clear | J3 and J5 grounded in jobs.yaml four forces and job stories | ✓ |
| 4. ACs are testable | All ACs verifiable through real conversations; no vague verbs | ✓ |
| 5. No unrealised dependencies | SKILL.md, custom-instructions.md, README all delivered; team project accessible | ✓ |
| 6. Effort is understood | ~1 day, 3 sub-slices with explicit effort estimates | ✓ |
| 7. Risks are identified | D8 (degradation quality bar) flagged; graceful degradation claim unverified in practice | ✓ |
| 8. Outcome KPIs defined | 5 KPIs with numeric targets and measurement methods | ✓ |
| 9. Slice composition: no @infrastructure-only slices | All 3 slices produce user-visible coaching value | ✓ |

**DoR result**: PASS — all 9 items validated with evidence.

---

## Wave: DISCUSS / [REF] Slice Briefs Index

| Slice | File | Goal | Effort | Learning Hypothesis |
|-------|------|------|--------|---------------------|
| Slice 03a | [slices/slice-03a-portable-install.md](slices/slice-03a-portable-install.md) | Verify two-step install procedure in a real team project | ~1h | Disproves: install requires more than 2 steps |
| Slice 03b | [slices/slice-03b-invocation-activation.md](slices/slice-03b-invocation-activation.md) | Verify `/coach-buddy` activates pipeline; coaching continues in-context | ~2h | Disproves: in-context coaching is qualitatively worse than dedicated-project |
| Slice 03c | [slices/slice-03c-graceful-degradation.md](slices/slice-03c-graceful-degradation.md) | Verify minimal install delivers reliably useful output | ~1h | Disproves: SKILL.md without reference files degrades catastrophically |

---

## Wave: DISCUSS / [HOW] Gherkin Scenarios

> Expansion triggered by: AC ambiguity — Stories 2 and 3 both use "coach self-reports the conversation as useful."
> Purpose: make "useful" observable and unambiguous so validation conversations have a concrete pass/fail bar.

```gherkin
Feature: Portable Coach Buddy install in a team project

  Background:
    Given a Claude Chat team project exists and is accessible
    And the coach has access to the coach-buddy repository

  # Story 1 — Portable Install
  Scenario: Two-step install completes without additional documentation
    Given the coach opens README.md and navigates to "Claude Chat Project — team project" section
    When the coach pastes the contents of custom-instructions.md into the team project's Custom Instructions
    And the coach uploads SKILL.md as a Project Knowledge file
    Then the install is complete
    And the elapsed time from README open to install complete is ≤10 minutes

  Scenario: Lean layer activates but full pipeline does not auto-trigger
    Given the coach has completed the two-step install
    When the coach sends a message not beginning with /coach-buddy
    Then the response reflects the lean coaching sensibility: Theory Y stance, concise language, no performative affirmations
    And the response does NOT include the SKILL.md opening protocol (disclaimer + observation + calibrating question)

  # Story 2 — In-Context Activation (defines "useful")
  Scenario: /coach-buddy activates full pipeline with one observation before any question
    Given the team project has the two-step install in place
    When the coach sends "/coach-buddy My team has been delivering consistently but the energy feels flat lately"
    Then the first response includes one observation naming a symptom or dynamic from the description
    And the first response asks exactly one calibrating question
    And the first response does NOT ask for mode, context, and stakes all at once
    And the first response does NOT introduce a named framework

  Scenario: Coach completes a useful coaching conversation in-context (observable definition of useful)
    Given the coach has sent an initial /coach-buddy message
    When the coach has exchanged 3 or more turns with the tool
    Then at least one tool response has named a symptom or dynamic not explicitly stated by the coach
    And at least one tool response has offered a question that the coach describes as "worth thinking about"
    And the coach has not said "that doesn't make sense" or equivalent (no confusing responses)
    And the conversation has not been abandoned mid-thought without resolution

  Scenario: Team artefacts in context do not confuse the coaching pipeline
    Given the team project contains knowledge files about the team's sprint board, tech stack, or team decisions
    When the coach invokes /coach-buddy referencing one of these artefacts ("I'm noticing the cycle times in our board suggest...")
    Then the tool responds to the coaching situation, not to the technical content of the artefact
    And the tool does not confuse team-specific terminology with coaching framework vocabulary

  # Story 3 — Graceful Degradation (defines "useful" without reference files)
  Scenario: Minimal install produces useful response without reference files
    Given the team project has only custom-instructions.md and SKILL.md installed (no references/ folder)
    When the coach sends "/coach-buddy [a real situation from their current coaching engagement]"
    Then the response names at least one symptom or dynamic beyond restating the coach's words
    And the response includes at least one framework attribution in format "Name (Source)" from SKILL.md's primary lens list
    And the response asks a question that advances the coach's thinking
    And the response does NOT include any error message or "I cannot help without reference files" statement

  Scenario: Graceful degradation — no hallucinated citations
    Given a minimal install is active
    When the tool makes a framework attribution
    Then the attributed framework name and source match an entry in SKILL.md's primary or secondary lens list
    And the tool does NOT attribute frameworks not listed in SKILL.md without explicit grounding from the conversation

  Scenario: Coach can distinguish minimal vs full install quality (informed install decision)
    Given the coach has run a conversation in a minimal install
    When the coach reflects on the conversation
    Then the coach can articulate: "the coaching was useful for situation-focus" (pass)
    Or the coach can articulate: "the coaching felt surface-level on frameworks" (also pass — degradation, not failure)
    But the coach should NOT articulate: "the tool was broken, unhelpful, or confusing" (fail)
```

---

## Wave: DESIGN / [REF] DDD List

| ID | Decision | Verdict | ADR |
|----|----------|---------|-----|
| D1 | Explicit orchestration over implicit | Accepted (carry-in) | [ADR-001](../../product/architecture/adr-001-explicit-orchestration.md) |
| D2 | Attribution on first mention; 6 interest signals; deep-dive pull-based | Accepted (carry-in) | [ADR-002](../../product/architecture/adr-002-attribution-on-first-mention.md) |
| D3 | Coaching frames for mode management | Accepted (carry-in) | [ADR-003](../../product/architecture/adr-003-coaching-frames-mode-management.md) |
| D4 | Ask when 2 mode signals + no stakes + topic discontinuity | Accepted (carry-in) | [ADR-004](../../product/architecture/adr-004-ask-rather-than-assume.md) |
| D5 | Situation focus wins when stakes stated OR elicited | Accepted (carry-in) | [ADR-005](../../product/architecture/adr-005-situation-focus-high-stakes.md) |
| D6 | Cutler-pattern now; nWave upgrade seam explicit | Accepted (carry-in) | [ADR-006](../../product/architecture/adr-006-cutler-to-nwave-upgrade-seam.md) |
| D7 | Two-layer install model: `custom-instructions.md` (lean always-on) + `SKILL.md` as Project Knowledge (invocable via `/coach-buddy`) | Accepted — this wave | [ADR-007](../../product/architecture/adr-007-portable-install-two-layer-model.md) |
| D8 | Graceful degradation quality bar: names a dynamic, one attribution, one advancing question, no error surfaced — encoded in SKILL.md + ADR-007 | Accepted — this wave | [ADR-007](../../product/architecture/adr-007-portable-install-two-layer-model.md) |
| D9 | Discovery hint in `custom-instructions.md` sufficient for v1 | Deferred (watch item) | — |

---

## Wave: DESIGN / [REF] Component Decomposition

| Component | Location | Responsibility | Change frequency |
|-----------|----------|----------------|------------------|
| SKILL.md (Full orchestrator) | Team project: Project Knowledge | Full thinking-partner pipeline — activated by `/coach-buddy`. Self-sufficient without reference files. | Low — changes when pipeline behaviour changes |
| custom-instructions.md (Lean layer) | Team project: Custom Instructions | Always-on coaching sensibility; hints `/coach-buddy` availability. Does not activate full pipeline. | Low — changes when ambient stance changes |
| Framework Library | Team project: Project Knowledge (optional) | Per-domain framework depth (complexity, work-layers, teams, development, tensions) | Medium — grows as repertoire expands |
| Calibration Canvas | Team project: Project Knowledge (optional) | Mode/context/stakes template for structured calibration | Low |
| README.md | Repository root | Authoritative install documentation; four install paths | Low — changes when install paths change |
| ADR-007 | `docs/product/architecture/` | Decision record for two-layer model and graceful degradation quality bar | Low — stable once accepted |

---

## Wave: DESIGN / [REF] Driving Ports

| Port | Surface | Activation |
|------|---------|------------|
| `/coach-buddy [description]` | Team project conversation | Activates full SKILL.md pipeline |
| Lean ambient layer | Team project every message | Always-on via `custom-instructions.md` in Custom Instructions |
| Calibration input | Conversation development | Mode / context / stakes gathered through dialogue, not upfront extraction |

---

## Wave: DESIGN / [REF] Driven Ports + Adapters

None. This is a configuration architecture. No external integrations, no outbound adapters.

---

## Wave: DESIGN / [REF] Technology Choices

| Layer | Choice | Version / Constraint |
|-------|--------|---------------------|
| Runtime | Claude (Anthropic) via Chat Project | Current production model |
| Orchestration | SKILL.md (Cutler-pattern, two-layer) | Markdown; named sections; `/coach-buddy` as soft invocation convention |
| Knowledge | Markdown reference files (optional in minimal install) | No size limit imposed; context window is the practical constraint |
| Testing | Manual conversation review (real team project) | No automated testing in Chat Project |

---

## Wave: DESIGN / [REF] Reuse Analysis

| Existing Component | File | Overlap | Decision | Justification |
|---|---|---|---|---|
| SKILL.md | `SKILL.md` | Full pipeline orchestration | EXTEND | Add `## Minimal install behaviour` section (~10 lines) — no new component needed |
| custom-instructions.md | `custom-instructions.md` | Lean ambient layer | CREATE NEW (already delivered, commit 3c3e76f) | No prior component with this responsibility existed; lean layer is a new deployment concern |
| README.md | `README.md` | Install documentation | CREATE NEW (already delivered, commit 3c3e76f) | No prior install documentation existed |
| ADR-007 | `docs/product/architecture/adr-007-*.md` | Decision record for D7 and D8 | CREATE NEW (this wave) | Novel decision — portable install model and degradation quality bar have no prior ADR |

---

## Wave: DESIGN / [REF] Open Questions

- **D9 (Discovery hint)**: `custom-instructions.md` currently hints `/coach-buddy` availability. Sufficient for v1. Revisit if usage data shows coaches not finding the invocation command. No action needed before DISTILL.
- **Version drift**: If `custom-instructions.md` and `SKILL.md` are updated independently across multiple team project installs, they may drift. No automated sync is available in Claude Chat Projects. Mitigation: document in README that both files should be refreshed together. Deferred to post-Slice 03 if it surfaces as a real problem.
- **SKILL.md activation mechanism**: `/coach-buddy` is a soft convention (model reads SKILL.md when name appears in message), not a registered command. Works reliably but depends on model behaviour. Flag if invocation becomes unreliable.
