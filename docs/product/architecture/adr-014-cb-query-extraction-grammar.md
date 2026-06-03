# ADR-014: cb-query Named Extraction Grammar

**Status**: Accepted
**Date**: 2026-06-03
**Feature**: cb-pa-integration

---

## Context

`cb-query` is a read-only skill that reads `COACHING_LOG.md` and `RETRO_ACTIONS.md` and emits either prose or structured JSON. Because coach-buddy is a SKILL.md prose system — not compiled code — "parsing" means prose instructions that guide the LLM's reading behaviour. The key design question is how explicit those instructions should be.

Three quality constraints drive the decision:

- **DW-2** (`signal_summary` scope): coach-buddy generates engagement-health signals only. The PA combines them with calendar/chat. If `signal_summary` drifts outside engagement-health domain, the PA receives duplicated or confounded signals.
- **DW-4** (stable general-purpose contract): JSON fields consumed by a future dashboard must be rule-derived, not inference-dependent. Field semantics must be predictable across invocations.
- **ADR-008** (self-containment): extraction logic must be embedded verbatim in cb-query's SKILL.md — not referenced from an external file.

The `open_actions[].evidenced` field (required for PA-side prioritisation) and `open_hypotheses[].status` field require explicit classification rules, not just presence/absence detection.

---

## Decision

Embed a named `## Extraction Grammar` section in `cb-query`'s SKILL.md with four explicit rules and a scoped `signal_summary` generation directive.

The grammar covers:

1. **Entry boundary rule**: COACHING_LOG.md entries are delimited by `---` frontmatter blocks. Each block bounded by `---` markers is one entry.

2. **Open hypothesis rule**: An entry's hypothesis is classified `open` when `**Hypothesis**:` is present AND `**Validation**:` is absent or carries status other than `confirmed` or `rejected`. It is classified `deferred` when `**Validation**: deferred` is present. All other hypotheses are closed.

3. **Evidenced action rule**: A RETRO_ACTIONS.md row is `evidenced: true` when its `Evidenced` column value is `yes` (case-insensitive). Any other value — including blank — is `evidenced: false`. Open actions are rows where `Status` ≠ `done` and `Status` ≠ `closed`.

4. **signal_summary scope rule**: Generate a 2–3 sentence summary covering only: (a) open hypothesis count and age distribution, (b) open action count and evidenced ratio, (c) WIP age signal (if board data present). Do not include calendar, meeting, chat, email, or non-engagement-file signals. The PA agent is responsible for combining engagement-health signals with personal context.

---

## Alternatives Considered

### Option A — Field-anchor extraction (implicit grammar)

Instruct cb-query to scan for known field prefixes (`**Hypothesis**:`, `**Validation**:`) without explicit classification rules. `signal_summary` generated free-form.

Rejected because: (a) `signal_summary` scope cannot be enforced without an explicit rule — LLM may include calendar/meeting context drawn from conversation history, violating DW-2; (b) `evidenced` boolean classification requires an explicit rule — presence/absence of `Validation` field is insufficient to classify evidenced retro actions from RETRO_ACTIONS.md table structure; (c) field values become inference-dependent, undermining DW-4 dashboard compatibility.

### Option C — Two-phase extraction (read then extract)

cb-query operates in a named Phase 1 (read all files into working buffer) and Phase 2 (apply extraction rules to buffer). Phases are explicitly labelled in the skill.

Rejected because: (a) two-phase framing adds structural ceremony without safety gain for a read-only skill — cb-validate uses two-phase for write safety, which doesn't apply here; (b) buffering all content before extracting adds token overhead; (c) the extraction grammar can be applied in a single read pass without loss of correctness.

---

## Consequences

**Positive**:
- `signal_summary` scope is enforced by the grammar's scope rule, not by LLM judgment — DW-2 compliance is mechanically assured
- All JSON field values (`open`, `deferred`, `evidenced: true/false`) are rule-derived — dashboard consumers can rely on consistent semantics (DW-4)
- Grammar rules are auditable: acceptance tests can verify rule application against known COACHING_LOG.md fixtures
- Rules stay in sync with entry format via ADR-011 (`**Validation**:` field) and cb-log-deterministic-writes (entry boundary, frontmatter keys)

**Negative**:
- Grammar prose must be maintained in sync with COACHING_LOG.md format changes. If a new `**Validation**:` status value is added in future, the grammar's open hypothesis rule must be updated.
- Slightly higher token cost per cb-query invocation compared to implicit approach.

**Risk**: If the entry format changes (new delimiters, new frontmatter keys), the grammar rules may produce incorrect classifications silently. Mitigated by: (a) format is stabilised via cb-log-deterministic-writes (shipped); (b) changes to format require a new ADR, which triggers grammar review; (c) acceptance test fixtures should cover the boundary cases (open vs deferred vs confirmed, evidenced vs unevidenced) so format drift surfaces as test failure rather than silent misclassification.
