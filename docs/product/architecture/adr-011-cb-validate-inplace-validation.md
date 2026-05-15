# ADR-011: cb-validate — In-Place Validation Strategy

**Status**: Accepted
**Date**: 2026-05-15
**Scope**: cb-review-improvements — Slice 01 (cb-validate skill)
**Extends**: ADR-010 (engagement context layer)

---

## Context

cb-validate is a new skill that closes the hypothesis-validation loop in COACHING_LOG.md.
It reads logged hypotheses, groups them by age, and prompts the coach to mark each as
`confirmed`, `disconfirmed`, or `defer`.

The key design question: where does the validation result live?

Two options were considered:

1. **In-place**: append a `**Validation**` field to the matched entry in COACHING_LOG.md
2. **Separate file**: write a `validation-log.md` per engagement; never touch COACHING_LOG.md

---

## Decision

**In-place append** (Option 1).

cb-validate appends `**Validation**: {status} ({date})` to the matched entry in COACHING_LOG.md,
immediately before the closing `---`. It uses the same id-match mechanism established by
cb-log Mode 2 (`--update`).

Guard: if `**Validation**` already exists in the entry, cb-validate prompts:
"Already validated as {status}. Update?" — prevents duplicate fields.

---

## Rationale

**Transparency wins** (first quality attribute from `docs/product/architecture/brief.md`).

The coach's coaching arc is a single narrative: observation → hypothesis → intervention → validation.
Splitting validation into a separate file breaks that narrative into two artifacts that must
be read in concert. A coach scanning COACHING_LOG.md to understand an engagement's arc would
see hypotheses without their outcomes — the loop would appear open even when closed.

In-place append means: one file, one arc, complete picture.

**Consistency with existing mechanism**. cb-log Mode 2 (`--update`) already demonstrates
that in-place mutation of COACHING_LOG.md entries is safe and intentional. The id-match
mechanism is established. cb-validate reuses it without introducing new patterns.

**The Safety-II structure is preserved**. The validation field is additive — it appends,
never replaces. The existing fields (`**Observed**`, `**Hypothesis**`, etc.) are untouched.
The guard against duplicate writes prevents accidental structure corruption.

---

## Alternatives Considered

### Alternative A: Separate `validation-log.md`

Write a separate file per engagement. Never touch COACHING_LOG.md.

**Why rejected**: Splits the coaching arc across two files. Coaches would need to
cross-reference two files to understand whether a hypothesis was validated. The principal
quality attribute is Transparency — hiding the validation in a separate file is the
opposite direction. Also introduces a new file type with its own format and tooling,
adding cognitive load for no safety gain (COACHING_LOG.md mutation is already established
by cb-log Mode 2).

### Alternative B: Summary section at top of COACHING_LOG.md

Maintain a `## Validation Summary` section at the top of COACHING_LOG.md, listing validated
hypothesis IDs and their outcomes.

**Why rejected**: Summary sections diverge from entries over time. Coaches would need to
match IDs to entries manually. Worse readability than in-place.

---

## Consequences

**Positive:**
- Validation result is co-located with the hypothesis — one file, complete arc
- No new file type, format, or tooling
- cb-validate reuses the established id-match mechanism from cb-log Mode 2
- COACHING_LOG.md remains the single source of truth for the engagement

**Negative / Watch items:**
- In-place mutation requires careful file-write logic — a bad write could corrupt entries.
  Mitigation: cb-validate reads the full file, performs string manipulation on the matched
  block, and writes back atomically (full file rewrite, not partial update).
- `**Validation**` field is a new field type not in the original cb-init template.
  Mitigation: cb-init COACHING_LOG.md template comment notes it as cb-validate-generated.

---

## References

- ADR-001: Transparency as first quality attribute
- ADR-010: Engagement context layer (cb-log Mode 2 establishes in-place mutation precedent)
- `docs/feature/cb-review-improvements/feature-delta.md` — DDD-1, DDD-6
- `docs/feature/cb-review-improvements/slices/slice-01-cb-validate.md`
