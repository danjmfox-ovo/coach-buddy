# DESIGN Wave Decisions — cb-pa-integration

**Wave**: DESIGN
**Date**: 2026-06-03

---

## D1 — Named Extraction Grammar in cb-query

**Decision**: Embed a named `## Extraction Grammar` section in cb-query's SKILL.md with four explicit rules.

**Alternatives considered**:
- Option A (field-anchor implicit): rejected — cannot enforce signal_summary scope (DW-2 violation risk); evidenced boolean requires explicit rule
- Option C (two-phase read/extract): rejected — ceremony without safety gain for a read-only skill; token overhead

**Rationale**: DW-2 requires signal_summary to be scoped to engagement-health domain. An explicit scope rule in the grammar is the only mechanically enforceable approach in a prose-instruction system. DW-4 requires rule-derived field values for dashboard predictability. See ADR-014.

**ADR**: ADR-014

---

## D2 — Engagement Path Resolver verbatim copy into cb-query

**Decision**: Copy the Engagement Path Resolver prose (Steps 1–3) from cb-log into cb-query verbatim.

**Rationale**: ADR-008 self-containment invariant — skills must not depend on external reference files. The resolver is embedded in every downstream skill; cb-query follows the same pattern.

**ADR**: ADR-008

---

## D3 — Backward-compatible --format json on cb-log

**Decision**: `--format json` absent → existing prose behaviour unchanged. The flag activates a new output branch only.

**Rationale**: The PA integration is additive. Coaches using cb-log directly must see no change. The extension surface is the output branch only — no change to path resolution, entry format, or write logic.

---

## D4 — Board MCP call inlined in cb-query (not delegated to cb-snapshot)

**Decision**: cb-query calls the board MCP directly per its own inline logic. It does not delegate to cb-snapshot.

**Rationale**: cb-snapshot is a write skill (creates dated board snapshot files). cb-query is read-only. Delegating to cb-snapshot would cross the read/write boundary and couple two independent skills. Self-containment (ADR-008) requires cb-query to own its read path end-to-end.

---

## D5 — degraded status when board MCP unavailable

**Decision**: When board MCP call fails or board_tool is unconfigured, cb-query returns `status: degraded`, `wip_aged: []`, and populates `warnings` with the reason.

**Rationale**: DW-3 treats the PA contract as speculative. Returning an error when the board is unavailable would break the PA integration on a transient dependency. `degraded` is a first-class status the PA can handle gracefully — it knows WIP data is absent but can still assemble a brief from the available fields.

---

## Extraction Grammar Rules (summary)

1. **Entry boundary**: entries delimited by `---` frontmatter blocks
2. **Open hypothesis**: `**Hypothesis**:` present AND `**Validation**:` absent or status not `confirmed`/`rejected`; `deferred` = `**Validation**: deferred` present
3. **Evidenced action**: RETRO_ACTIONS.md row where `Evidenced` column = `yes` (case-insensitive); open = `Status` ≠ `done`/`closed`
4. **signal_summary scope**: 2–3 sentences on hypothesis age, action evidenced ratio, WIP age only — no calendar, chat, or non-engagement-file signals

Full rationale and rejected alternatives in ADR-014.

---

## D6 — --since window does not affect open_hypotheses count

**Decision**: `--since` filters the entries *read* from COACHING_LOG.md. A hypothesis is open if it lacks `confirmed` or `rejected` validation status — regardless of entry age. The `--since` window does not close or exclude open hypotheses that fall outside the window.

**Rationale**: DW-4 requires stable JSON field semantics. If `open_hypotheses` count varied with `--since`, dashboard consumers and the PA would receive inconsistent signals depending on the query window. Separating "recency of capture" from "openness of hypothesis" preserves the contract's predictability. Coaches can see that old hypotheses are still open — that is valuable signal, not noise to suppress.
