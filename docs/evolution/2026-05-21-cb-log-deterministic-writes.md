# Evolution: cb-log-deterministic-writes

**Date**: 2026-05-21
**Feature**: cb-log-deterministic-writes
**Delivery completed**: 2026-05-21
**Wave gate**: PASS (SKILL.md-only feature; 8/8 acceptance criteria satisfied by manual prose review)

---

## Feature Summary

Tightened the `cb-log` skill spec to produce byte-for-byte identical COACHING_LOG.md entries across LLM sessions. Two slices:

- **Slice 01 — New entry determinism**: replaced the vague "count existing entries" heuristic with regex-based ID scanning (`^id: DATE-\d{3}$`); split the single optional-field template into two canonical templates (with-participants / without-participants) with explicit blank-line rules, locked placeholder strings (`(to fill)`, `(none yet)`), and locked field labels.
- **Slice 02 — Update determinism**: added an explicit CLI-to-label mapping table (6 fields) and a precise single-line replacement mechanic ("find the line beginning with `{label}: `, replace the entire line"). All other lines are preserved byte-for-byte unchanged.

All changes are backward-compatible. Existing COACHING_LOG.md entries with any format remain readable and updatable.

---

## Business Context

**Primary job**: `reliable-log-capture` (added to `docs/product/jobs.yaml`).

**Pain addressed**: Different LLM sessions were producing entries with inconsistent blank lines, varying capitalisation, or different placeholder text. The `--update` path was underspecified — "update the specified field's value in place" left room for ambiguity about which line to target and whether adjacent lines could be affected.

**Enabling job**: `structured-observation-capture` (J7) — log reliability is a prerequisite for coaches who use `--update` to refine entries across multiple sessions.

**Scope**: 1 SKILL.md file modified (Step 2, Step 4, Mode 2 sections), no UX changes, no new fields, no migration required.

---

## Key Decisions

### DISCUSS wave

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | ID counting via `^id: DATE-\d{3}$` regex | More robust than counting `---` pairs; immune to HR rules and YAML front matter elsewhere |
| D2 | Two canonical templates (with / without participants) | Eliminates writer optionality — each template has zero ambiguous paths |
| D3 | Exactly one blank line between comment and opening `---` | Consistent with markdown block element separation |
| D4 | Whole-line replacement for `--update` | Simpler match; no partial-match side effects; values are single-line |
| D5 | Exactly one blank line after closing `---` | Consistent inter-entry spacing regardless of insertion order |

---

## Acceptance Criteria Status

| AC | Description | Status |
|----|-------------|--------|
| AC1.1 | ID is `today-001` when no prior entries | PASS |
| AC1.2 | ID is `today-003` when two prior entries exist | PASS |
| AC1.3 | Without-participants: correct blank lines, body field spacing | PASS |
| AC1.4 | With-participants: `participants:` immediately after `mode:`, no blank between | PASS |
| AC1.5 | Entry preceded by exactly one blank line after comment | PASS |
| AC1.6 | Closing `---` followed by exactly one blank line | PASS |
| AC1.7 | Placeholder strings exactly `(to fill)` / `(none yet)` | PASS |
| AC1.8 | Field labels exactly match canonical set | PASS |
| AC2.1 | `pattern` update changes only `**Pattern/Signal**: ` line | PASS |
| AC2.2 | `followup` update changes only `**Follow-up**: ` line | PASS |
| AC2.3 | All 6 CLI fields mapped to correct file labels | PASS |
| AC2.4 | Unknown ID → exact error message | PASS |

---

## Files Modified

| File | Change |
|------|--------|
| `skills/cb-log/SKILL.md` | Step 2 (regex ID counting), Step 4 (two canonical templates + blank-line rules + placeholder/label locks), Mode 2 (mapping table + replacement mechanic) |
| `docs/feature/cb-log-deterministic-writes/feature-delta.md` | DISCUSS wave (2026-05-20) + DELIVER wave (2026-05-21) |
| `docs/product/jobs.yaml` | `reliable-log-capture` job added |
| `docs/feature/cb-log-deterministic-writes/slices/slice-01-new-entry-determinism.md` | Slice brief |
| `docs/feature/cb-log-deterministic-writes/slices/slice-02-update-determinism.md` | Slice brief |

---

## References

- Feature artifacts: `docs/feature/cb-log-deterministic-writes/`
- Commit: 4ef6f8d
