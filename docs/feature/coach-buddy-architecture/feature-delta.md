# Feature Delta: coach-buddy-architecture
# Waves: DISCUSS + DESIGN (2026-05-12)
# Density: lean + ask-intelligent

---

## Wave: DISCUSS / [REF] Persona ID

**Persona**: `agile-coach` — a practitioner working with teams and organisations to navigate complexity
Full profile: `docs/product/personas/agile-coach.yaml`

---

## Wave: DISCUSS / [REF] JTBD One-Liner

**Primary job**: When preparing for or reflecting on a real coaching situation, the coach wants a responsive thinking partner who helps them see more clearly what's happening — so they can act with sharper instincts and without being derailed by frameworks they didn't ask for.

**Secondary job**: When working through a situation, the coach wants to encounter relevant frameworks they haven't used before, introduced at the right moment — so their repertoire grows through real cases, not abstract training.

**Core tension**: Job 1 wants the tool to follow; Job 2 wants the tool to lead. Every locked decision addresses some aspect of how this tension is managed.

---

## Wave: DISCUSS / [REF] Locked Decisions

> These are decisions carried in from the problem statement — not made during this wave.
> Each is recorded here so DESIGN can evaluate them against both jobs.

| ID  | Decision | Verdict | Tension verdict |
|-----|----------|---------|-----------------|
| D1  | Explicit orchestration over implicit | Locked | Serves Job 1 (coach sees what's happening, retains agency); neutral on Job 2 |
| D2  | Attribution on first mention, deep-dive on request/interest | Locked | Serves Job 2 (frameworks introduced with source); risk to Job 1 if attribution fires uninvited in high-stakes moments |
| D3  | Coaching frames for mode management (not tool-specific interruptions) | Locked | Resolves tension directly — familiar language doesn't break coaching register |
| D4  | Ask rather than assume when mode is ambiguous | Locked | Serves both jobs — avoids wrong-mode errors; slight friction cost |
| D5  | Situation focus wins when stakes are consequential or irreversible | Locked | Resolves tension tiebreaker — Job 1 is protected when it matters most |
| D6  | Cutler-pattern now; nWave-pattern as upgrade path without rebuild | Locked | Architecture decision — no direct tension implication, but affects D1 (visibility of orchestration) |

**Underdetermined flags** (raised for DESIGN consideration):

- 🤔 **D2 — Attribution trigger conditions**: "first mention" is clear, but "detected interest" is not. What signals count as interest? A question? A pause? A topic revisited? This needs explicit criteria or it collapses to "when the tool guesses", which undermines D4.
- 🤔 **D4 — Ambiguity threshold**: "Can't read the mode" is operationally vague. What's the decision boundary? If the tool asks too readily, it becomes a friction source; if it asks too rarely, it defaults wrongly. Needs a worked example or heuristic in the ADR.
- 🤔 **D5 — Consequential/irreversible**: Who determines this? Does the coach state it, or does the tool infer it from cues? If the tool infers, what cues? Needs explicit scope in the ADR.
- 🤔 **D6 — Cutler-pattern escape hatch**: The decision says "nWave-pattern is a viable upgrade path". What would trigger that upgrade? What does "without rebuilding from scratch" actually guarantee? An ADR should specify the seam.

---

## Wave: DISCUSS / [REF] User Stories with Elevator Pitches

### Story 1 — Situation Focus
`job_id: thinking-partner`

**As** an Agile Coach working through a real situation,
**I want** the tool to help me articulate what's happening (symptoms, dynamics, options) without introducing frameworks I didn't ask for,
**so that** I can think more clearly and arrive at a grounded intervention.

#### Elevator Pitch
Before: The coach goes into a difficult session having only their own internal monologue to work with.
After: Coach describes a situation → tool reflects symptoms, names dynamics, surfaces options → coach refines their read and chooses an approach.
Decision enabled: Which intervention to use, and why — with the coach retaining authorship.

**Acceptance Criteria**:
- Tool responds to a situation description without introducing an unrequested framework
- When a framework is introduced (only if the coach signals interest or asks directly), it is attributed on first mention
- Tool does not reframe the situation in a way that contradicts the coach's stated interpretation without flagging it

---

### Story 2 — Framework Discovery
`job_id: growth-vehicle`

**As** an Agile Coach in situation-focus mode,
**I want** relevant frameworks introduced at natural moments — with attribution — and available for deeper exploration on request,
**so that** my repertoire grows through real cases without disrupting my thinking flow.

#### Elevator Pitch
Before: Coach learns frameworks in training but can't connect them to live situations in the moment.
After: While working through a situation, coach encounters "Cynefin (Snowden)" with a one-line relevance note → deep-dive available on request.
Decision enabled: Whether to explore the framework now or continue situation-focus.

**Acceptance Criteria**:
- Framework attribution format: `Name (Author/Source)` on first mention in a conversation
- Deep-dive available via coach request or explicit interest signal, not proactively
- Attribution does not interrupt the situation-focus flow (placement is additive, not substitutive)
- Second mention of the same framework within a conversation: no re-attribution

---

### Story 3 — Mode Management
`job_id: thinking-partner`

**As** an Agile Coach whose focus has drifted or whose topic has shifted,
**I want** the tool to use standard coaching language to redirect me — not tool-specific interruptions —
**so that** I can re-establish focus without breaking the coaching register.

#### Elevator Pitch
Before: The tool either lets the conversation drift or interrupts with a clunky "I notice we've changed topic" message that breaks immersion.
After: Topic shift detected → tool asks "What do you want to achieve here today?" or "Is this the real topic?" → coach reorients.
Decision enabled: Whether to follow the new thread or return to the original focus.

**Acceptance Criteria**:
- Mode management language drawn from standard coaching redirects, not tool-specific phrases
- Redirect fires when: topic shift detected AND current thread has no explicit close
- Redirect does not fire mid-thought (only at natural turn boundaries)
- Coach can override redirect and continue the new thread without friction

---

### Story 4 — Transparent Orchestration
`job_id: thinking-partner`

**As** an Agile Coach using the tool,
**I want** to understand what the tool is doing and why — which mode it's in, what it's drawing on —
**so that** I can trust its contributions without surrendering my own judgment.

#### Elevator Pitch
Before: The coach receives a synthesis with no visibility into what drove it — feels like a black box.
After: Tool indicates its current orientation (e.g. "I'm treating this as situation-focus — let me know if you want to shift") → coach can see and redirect.
Decision enabled: Whether to accept the tool's framing or request a different orientation.

**Acceptance Criteria**:
- Tool surfaces its current mode when switching or when asked
- Attribution (D2) and mode-state (D1) are visible without requiring explicit coach request
- Orchestration signals are brief — they do not dominate the response

---

## Wave: DISCUSS / [REF] Definition of Done

- [ ] JTBD analysis complete for both jobs
- [ ] Job dimensions documented: functional / emotional / social
- [ ] Four Forces documented per job
- [ ] Opportunity scores produced
- [ ] Lightweight journey map with emotional arc
- [ ] Story map created with walking skeleton slice identified
- [ ] User stories trace to job IDs
- [ ] All ACs testable
- [ ] DoR validated

---

## Wave: DISCUSS / [REF] Out of Scope

- Coaching the end-clients (teams, individuals) that the Agile Coach works with — this tool serves the coach, not their clients
- Multi-coach collaboration or shared sessions
- Session notes or output capture (may be a future feature)
- Integration with external tools (calendar, Jira, Miro) in this phase
- Real-time co-coaching or supervision (future)

---

## Wave: DISCUSS / [REF] WS Strategy

**Strategy B — Brownfield thin slice**: The Claude Chat Project infrastructure exists. The walking skeleton is:

> A configured Claude Chat Project (SKILL.md orchestrator + reference files) that can handle **one complete situation-focus conversation** end-to-end — symptoms in, named dynamic + intervention options out — with attribution firing on first framework mention and mode state visible.

This proves the architectural seam (SKILL.md orchestration + reference knowledge) delivers Job 1 without Job 2 leaking in. It is obviously incomplete (Job 2 discovery flow, mode management redirects, and interest detection are not yet wired).

**Acceptance signal**: A coach works through a real situation in a single conversation, finds the output useful, and does not experience the tool introducing unrequested frameworks.

---

## Wave: DISCUSS / [REF] Driving Ports

- **Inbound**: Conversational turn (coach message in Claude Chat Project)
- **Orchestration**: SKILL.md — defines tool orientation, mode defaults, and attribution rules
- **Knowledge**: Reference files — frameworks, theory catalogue, intervention library (as Claude Chat Project knowledge)

---

## Wave: DISCUSS / [REF] Pre-requisites

- Claude Chat Project created and accessible
- SKILL.md structure defined (DESIGN wave deliverable)
- Reference file set identified and scoped (DESIGN wave deliverable)
- No prior nWave waves for this feature

---

## Wave: DISCUSS / [REF] Scope Assessment

**Signal check**:
- User stories: 4 (within bounds)
- Bounded contexts touched: 3 (orchestration, framework knowledge, mode management) — borderline
- Walking skeleton integration points: 2 (SKILL.md + reference files)
- Independent outcomes that could ship separately: Yes — Job 1 (thinking partner) can ship before Job 2 (growth vehicle)

**Verdict**: BORDERLINE — not oversized, but has a clean natural split.

**Proposed slice order** (see slice briefs):
- Slice 01: Thinking partner (situation focus, explicit orchestration, attribution on first mention)
- Slice 02: Growth vehicle (interest detection, deep-dive on request, mode management redirects)

This split lets the walking skeleton land as Slice 01 and proves architecture risk before adding the tension-prone Job 2 mechanics.

---

## Wave: DISCUSS / [REF] Outcome KPIs

| KPI | Target | Measurement |
|-----|--------|-------------|
| Coach finds the response useful for situation at hand | ≥80% of situation-focus conversations | Coach self-report in first 10 sessions |
| Framework introduced only when appropriate | 0 uninvited framework introductions in situation-focus mode | Manual review of first 20 conversations |
| Attribution present on first mention | 100% of framework introductions | Automated string-match audit |
| Mode state visible to coach | Coach can state tool's current orientation after any turn | Spot-check in user sessions |
| Coach completes thinking-through without switching away | ≥70% of conversations end at a decision, not an abandonment | Conversation completion rate |

---

## Wave: DISCUSS / [HOW] Gherkin Scenarios

> Expansion triggered by: AC ambiguity on D2 (interest detection) and D4 (mode ambiguity threshold).
> Purpose: force explicit preconditions so DESIGN can write ADR criteria that are testable.

```gherkin
Feature: Situation-focus coaching conversation

  Background:
    Given the coach has opened a Claude Chat Project configured with SKILL.md
    And the tool's default orientation is situation-focus

  Scenario: Coach describes a situation — no framework introduced
    Given the coach says "My team has been delivering consistently but the energy feels flat lately"
    When the tool responds
    Then the response names observable symptoms from the description
    And the response does not introduce a named framework
    And the response does not include attribution markup (Name + Source)

  Scenario: Coach explicitly requests a framework
    Given the coach is in a situation-focus conversation
    When the coach says "Is there a framework I could use here?"
    Then the tool introduces one relevant framework with attribution: "Name (Source)"
    And the response explains its relevance to the current situation in one sentence
    And the response does not introduce more than two frameworks in a single turn

  Scenario: Interest detected — coach revisits a concept twice
    Given the coach mentioned "psychological safety" in a prior turn
    When the coach references psychological safety again in the next turn
    Then the tool treats this as an interest signal
    And the tool surfaces "an option to go deeper" on the concept
    And the tool does NOT automatically produce a deep-dive without the coach accepting

  Scenario: Mode is ambiguous — tool asks
    Given the coach has shifted from a team situation to a personal reflection mid-conversation
    And the tool cannot determine whether this is a new situation or a continuation
    When the tool's next turn is due
    Then the tool asks a standard coaching redirect: "What do you want to achieve here today?"
    And the tool does not assume a mode and proceed without the coach's response

  Scenario: Stakes are stated as consequential — situation focus wins
    Given the coach says "I have a session tomorrow that could end the engagement if it goes wrong"
    And the current conversation has both situation-focus and learning-mode signals
    When the tool determines its orientation for the next response
    Then the tool adopts situation-focus
    And the tool does not introduce any unrequested framework or growth-mode content
    And if the tool surfaces its orientation, it says something like "Keeping this in situation-focus given the stakes"

  Scenario: Attribution on first mention only
    Given "Cynefin (Snowden)" has been mentioned once in the current conversation
    When the coach or tool references Cynefin again in the same conversation
    Then the response does NOT repeat the attribution "(Snowden)"
    And the framework name alone is sufficient: "Cynefin"
```

---

## Wave: DISCUSS / [WHY] Alternatives Considered

> Expansion triggered by: 3 bounded contexts. Focuses on orchestration pattern alternatives — the decision with the broadest architectural consequence.

### Decision: Cutler-pattern (SKILL.md orchestrator + reference files as project knowledge)

**Chosen for**: Slice 01 / walking skeleton

**Why it fits**:
- Available today without additional tooling
- The orchestration logic (mode defaults, attribution rules, coaching language) lives in SKILL.md — visible, editable, transferable
- Reference files (framework library, intervention library) slot naturally into Claude Chat Project "knowledge"
- The "explicit orchestration" principle (D1) is satisfied: SKILL.md IS the orchestration, readable by the coach if they want to inspect it

**What it cannot do**:
- Multi-agent coordination (two agents running in parallel for different jobs)
- Deterministic handoffs between modes (mode switching is soft, not enforced)
- External tool integration (no adapters, no ports beyond conversation)
- Testable at the unit level (the "test" is a conversation, not an automated check)

---

### Alternative A: Prompt-only (no SKILL.md structure)

A single large system prompt encoding all behaviour inline.

**Why rejected**:
- Violates D1 (explicit orchestration) — all logic is invisible to the coach
- Fragile: prompt drift as context fills; no separation of concerns
- Non-upgradable: moving to nWave-pattern would require a complete rewrite

---

### Alternative B: nWave-pattern (explicit agent invocation, human checkpoints)

A structured agentic workflow with named agents for each job (thinking-partner agent, growth-vehicle agent) and explicit handoffs.

**Why not yet**:
- Requires Claude Code CLI, not available in a Claude Chat Project today
- Over-engineered for the current use case — adds infrastructure complexity before the jobs are validated
- The Cutler-pattern explicitly preserves this as an upgrade path (D6)

**When to trigger the upgrade**:
- When the coach needs to invoke a specific agent by name for a well-defined task (e.g. "run a workshop design sprint")
- When the orchestration logic in SKILL.md exceeds ~500 lines and becomes unwieldy
- When multi-session memory or external tool integration is needed

**Upgrade guarantee** (what D6 must specify):
- SKILL.md structure maps 1:1 to agent definitions in the nWave pattern
- Reference files become knowledge-base inputs to agents without transformation
- The seam is the SKILL.md contract — any agent that honours that contract can replace the Chat Project implementation

---

### Alternative C: External tool (e.g. custom GPT, Dify, Langflow)

**Why rejected**:
- Higher maintenance burden; introduces a third-party dependency
- Breaks the "Cognitive Load Tax" constraint — coach now manages another tool
- Loses the Claude model quality advantage for nuanced coaching conversations
- Violates stewardship principle (Transferability) — locked to a vendor's orchestration model

---

## Wave: DESIGN / [REF] DDD List

| ID | Decision | Verdict | ADR |
|----|----------|---------|-----|
| D1 | Explicit orchestration over implicit | Accepted | [ADR-001](../../product/architecture/adr-001-explicit-orchestration.md) |
| D2 | Attribution on first mention; 6 interest signals; deep-dive pull-based | Accepted | [ADR-002](../../product/architecture/adr-002-attribution-on-first-mention.md) |
| D3 | Coaching frames for mode management (no tool-specific language) | Accepted | [ADR-003](../../product/architecture/adr-003-coaching-frames-mode-management.md) |
| D4 | Ask when 2 mode signals + no stakes + topic discontinuity | Accepted | [ADR-004](../../product/architecture/adr-004-ask-rather-than-assume.md) |
| D5 | Situation focus wins when stakes stated OR stakes prompt elicited | Accepted | [ADR-005](../../product/architecture/adr-005-situation-focus-high-stakes.md) |
| D6 | Cutler-pattern now; nWave-pattern upgrade seam explicit | Accepted | [ADR-006](../../product/architecture/adr-006-cutler-to-nwave-upgrade-seam.md) |

---

## Wave: DESIGN / [REF] Component Decomposition

| Component | Location | Responsibility | Change frequency |
|-----------|----------|----------------|-----------------|
| SKILL.md (Orchestrator) | Project custom instructions | Mode management, attribution, opening protocol, guardrails, Phase A/B | Low |
| Framework Library | `references/frameworks/` | One file per framework domain | Medium |
| Calibration Canvas | `assets/calibration-canvas.md` | Mode/context/stakes template | Low |
| Output Template | `assets/output-template.md` | Phase A / Phase B skeleton | Low |

---

## Wave: DESIGN / [REF] Driving Ports

| Port | Surface | Description |
|------|---------|-------------|
| Coach turn | Claude Chat Project conversation | Primary inbound: coach message, situation description, question |
| Calibration input | Conversation open | Mode, context, stakes stated by coach at session start |

---

## Wave: DESIGN / [REF] Driven Ports + Adapters

None in Slice 01. No external integrations.

---

## Wave: DESIGN / [REF] Technology Choices

| Layer | Choice | Version / Constraint |
|-------|--------|---------------------|
| Runtime | Claude (Anthropic) via Chat Project | Current production model |
| Orchestration | SKILL.md (Cutler-pattern) | Markdown; named sections |
| Knowledge | Markdown reference files | No size limit imposed; context window is the practical constraint |
| Testing | Manual conversation review | No automated testing in Chat Project |

---

## Wave: DESIGN / [REF] Reuse Analysis

Greenfield configuration architecture. No existing components.

| Existing Component | File | Overlap | Decision | Justification |
|---|---|---|---|---|
| — | — | — | — | No prior codebase |

---

## Wave: DESIGN / [REF] Open Questions

- Framework Library: organised by domain (complexity, psychology, teams) or by job (thinking-partner vs. growth-vehicle)?
- Exact phrasing list for coaching redirects in SKILL.md (DELIVER task)
- Calibration canvas format (DELIVER task)
- How to handle the existing system prompt: migrate content into SKILL.md + reference files vs. replace entirely

