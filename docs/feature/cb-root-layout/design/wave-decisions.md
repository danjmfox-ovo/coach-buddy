# Wave Decisions — cb-root-layout
<!-- DESIGN wave decisions log -->
<!-- Feature: cb-root-layout -->
<!-- Date: 2026-05-19 -->

## Scope Assessment: PASS — SKILL.md-only change; 6 files, 2 slices, ~3 days

All design decisions in this wave are downstream of locked ADR-012. The DESIGN wave role here is to specify *how* those locked decisions manifest as SKILL.md changes, not to reopen the architectural choices.

---

## Wave Decision DD-001: Outcome Collision Check Skipped

**Rationale**: This feature changes only SKILL.md prose instruction files. There is no typed contract surface, no domain model change, no new output type, and no entry in the outcomes registry that this feature affects. Running the outcomes collision check would add ceremony with no signal value.

**Risk acknowledged**: If a future feature introduces a typed engagement schema (e.g. a TypeScript `config.json` parser), the schema fields `version` and `engagement.slug` used as the detection signal here would become a contract surface. That risk is deferred to the feature that introduces typed parsing. Noted as a future dependency alert.

**Gate status**: Skipped with documented justification.

---

## Wave Decision DD-002: Shared "Engagement Path Resolver" Pattern

**Decision**: The detection chain is specified as a single named pattern — "Engagement Path Resolver" — that each downstream SKILL.md embeds verbatim under `## Reading the engagement config`. It is not abstracted into a separate file or a reference document.

**Rationale**: The pattern is 8-10 prose lines. Embedding verbatim is simpler than indirection and works with how Claude Code reads SKILL.md files at invocation time (each skill is self-contained). A shared reference document would require cross-file reads that are not guaranteed in all deployment configurations.

**Alternative considered**: Extract to a `references/engagement-path-resolver.md` that each skill links to. Rejected because (a) Claude Code does not auto-load linked reference files — the skill would need to explicitly read the file, adding a runtime step; (b) the pattern is short enough that verbatim embedding costs less than the indirection.

**Future maintenance note**: When ADR-012 D4 extension (`--root <path>`) ships, the Engagement Path Resolver pattern in all five downstream skills will need updating. The five locations are a known multi-site edit — acceptable at this scale. If a sixth or seventh downstream skill is added, revisit the extraction decision.

---

## Wave Decision DD-003: coach-buddy Engagement Context is Optional and Silent

**Decision**: coach-buddy's Engagement Path Resolver is applied silently. If no engagement is found, coach-buddy proceeds without context and does not mention it to the coach.

**Rationale**: coach-buddy's primary function is the thinking-partner pipeline, not engagement file management. Engagement context (CONTEXT.md, COACHING_LOG.md, snapshots) enriches the conversation but is not required. Surfacing an error or warning when no engagement exists would be confusing — the coach may be using coach-buddy in a project that has no engagement at all.

**Contrast with other skills**: cb-log, cb-retro, cb-snapshot, and cb-validate are engagement-management tools. When they find no engagement they must error because their core function cannot proceed. coach-buddy is a thinking-partner tool with optional context enrichment — different failure semantics.

---

## Wave Decision DD-004: COACHING_LOG.md Collision Warning Added to cb-init

**Decision**: When `--root` is active and `./config.json` is absent (overwrite guard does not fire) but `./COACHING_LOG.md` exists, cb-init warns before proceeding. This is additive to the existing overwrite guard — not a replacement.

**Rationale**: The overwrite guard anchors on `config.json` (ADR-012 D5). This is correct and locked. However, the risk noted in the feature-delta "Root file name collision" row is real: `COACHING_LOG.md` is a common filename that could exist in a team project before coach-buddy is installed. Silently overwriting it would cause data loss with no guard. A warning (not a block) is the right response — it preserves coach agency while surfacing the risk.

**Scope**: cb-init only. Downstream skills do not create files — they read and append to existing ones. No parallel warning needed in downstream skills.

---

## Wave Decision DD-005: No New ADR Required

**Decision**: No new ADR is created for this feature. ADR-012 is accepted and locked. All design decisions here are implementation specifications within ADR-012's scope.

**Rationale**: ADRs record architectural decisions with lasting consequences. The Engagement Path Resolver (DD-002), the optional coach-buddy context handling (DD-003), and the collision warning (DD-004) are all implementation details within the boundary set by ADR-012. They do not introduce new architectural options, change technology choices, or create new boundaries.

**Gate status**: No ADR produced. Decisions recorded in this wave-decisions.md.

---

## Wave Decision DD-006: C4 Scope Limited to System Context (L1)

**Decision**: The C4 diagram for this feature is a System Context diagram only. No Container or Component diagrams are produced.

**Rationale**: The coach-buddy engagement layer is a CLI skill system with no containers, services, network calls, or deployment units. The "containers" are SKILL.md files in a filesystem directory — not architectural containers in the C4 sense. An L2 Container diagram would misrepresent the system. L1 accurately shows the coach, the skill layer, and the filesystem boundary that the detection chain traverses.

**Prior art**: The existing brief.md Container diagrams represent the Claude Chat Project deployment (dedicated project and portable team project). Those diagrams remain valid and unchanged. This feature's C4 is a supplement, not a replacement.

---

## Quality Gate Status

| Gate | Status | Evidence |
|---|---|---|
| Requirements traced to components | PASS | REF-D2 maps each story AC to a specific section change in each SKILL.md |
| Component boundaries with clear responsibilities | PASS | REF-D2 and REF-D5 define exactly what changes and what is unchanged |
| Technology choices in ADRs with alternatives | PASS (locked) | ADR-012 accepted; DD-002 documents shared-pattern alternative considered |
| Quality attributes addressed | PASS | Backwards compatibility (legacy layout unchanged); maintainability (shared pattern); transparency (warning on collision) |
| Dependency-inversion compliance | N/A | SKILL.md files have no type system; pattern is prose-level dependency inversion (resolver before use) |
| C4 diagrams (L1 minimum) | PASS | REF-D6 |
| Integration patterns specified | N/A | No external integrations |
| OSS preference validated | N/A | No new technology introduced |
| AC behavioural, not implementation-coupled | PASS | Slice ACs describe observable behaviours (files at root, no prompt shown, legacy unchanged) |
| External integrations annotated | N/A | No external integrations in this feature |
| Architectural enforcement tooling | N/A | SKILL.md is prose; no compiler or linter applicable |
| Peer review completed | PENDING | See below |

---

## Peer Review Record

**Iteration 1**

```yaml
review_id: "arch_rev_2026-05-19-cbrl-01"
reviewer: "solution-architect-reviewer"
artifact: "docs/feature/cb-root-layout/feature-delta.md (DESIGN sections), docs/feature/cb-root-layout/design/wave-decisions.md"
iteration: 1

strengths:
  - "Shared Engagement Path Resolver pattern eliminates five-way duplication — correct scope for a prose-level abstraction"
  - "Outcome collision check skip is explicitly documented with rationale and a future risk note (DD-001)"
  - "No ADR produced for implementation details — correct ADR hygiene (DD-005)"
  - "coach-buddy optional/silent failure semantics are correctly differentiated from engagement-management skills (DD-003)"
  - "COACHING_LOG.md collision warning adds safety without violating ADR-012 D5 overwrite guard anchor"
  - "Data flow diagrams (REF-D3) include explicit decision points — no hidden branching"

issues_identified:
  architectural_bias:
    - issue: "None detected — no technology choice, no pattern preference bias"
      severity: "low"
      location: "n/a"
      recommendation: "No action required"
  decision_quality:
    - issue: "DD-002 alternative (reference document extraction) rejection rationale could note that SKILL.md self-containment is a design invariant from ADR-008 portable install — this would make the rejection stronger"
      severity: "low"
      location: "DD-002"
      recommendation: "Add ADR-008 self-containment reference to rejection rationale"
  completeness_gaps:
    - issue: "REF-D5 coach-buddy blueprint does not specify where in the SKILL.md the new section is inserted (before Frameworks? after Opening protocol?) — crafter will have to infer"
      severity: "medium"
      location: "REF-D5 coach-buddy section"
      recommendation: "Specify insertion point: before ## Frameworks, after ## Core stance"
  implementation_feasibility:
    - issue: "None — pattern is straightforward prose substitution with well-bounded scope"
      severity: "low"
      location: "n/a"
      recommendation: "No action required"
  priority_validation:
    q1_largest_bottleneck:
      evidence: "root-layout init leaves all downstream skills broken — correct primary problem"
      assessment: "YES"
    q2_simple_alternatives:
      assessment: "ADEQUATE — ADR-012 documents alternatives; DD-002 documents shared pattern alternative"
    q3_constraint_prioritization:
      assessment: "CORRECT — detection chain is the constraint; shared pattern minimises multi-site edit cost"
    q4_data_justified:
      assessment: "JUSTIFIED — real-world advisor-connect migration confirms the ergonomic need"

approval_status: "conditionally_approved"
critical_issues_count: 0
high_issues_count: 0
medium_issues_count: 1
```

**Revisions made (Iteration 1 → accepted):**

Issue 1 (low — DD-002 rejection rationale): Added ADR-008 self-containment reference to the DD-002 rejection rationale in feature-delta.md REF-D4 section.

Issue 2 (medium — coach-buddy insertion point): REF-D5 coach-buddy blueprint now specifies: new `## Engagement context (optional)` section is inserted after `## Core stance` and before `## Mode management`. This positions it as context-loading before any mode or framework logic runs, which is the correct execution order.

**Approval status after revisions: APPROVED**
