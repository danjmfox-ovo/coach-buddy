# Slice 01 — New Entry Determinism

**Goal**: Make the Mode 1 write path (ID generation + entry format + prepend) produce byte-for-byte identical output given the same inputs, across any LLM session.

## IN Scope

- Step 2 (ID generation): replace vague counting rule with exact regex-pattern count (`^id: DATE-\d{3}$`) and explicit 3-digit zero-padding
- Step 4 (entry format): replace single optional-field template with two canonical templates (with-participants / without-participants); add explicit blank-line rules; lock field label capitalisation; lock placeholder strings
- Step 4 (prepend logic): specify exactly one blank line between `<!-- Entries below this line -->` and the opening `---`; specify exactly one blank line after the closing `---`

## OUT Scope

- Mode 2 (update path) — Slice 02
- UX changes (prompts, flow, questions)
- New fields or field reordering
- Migrating existing entries to canonical format

## Learning Hypothesis

**Disproves**: If a new session still produces a differently-formatted entry (wrong blank lines, different placeholder text, wrong ID width), the rules are insufficiently precise and need further tightening.
**Confirms**: If two independent sessions with identical inputs produce byte-for-byte identical entries, the explicit rules are sufficient.

## Acceptance Criteria

- AC1.1: Given `COACHING_LOG.md` has zero `^id: {today}-\d{3}$` lines, the new entry's ID line is `id: {today}-001`.
- AC1.2: Given `COACHING_LOG.md` has two `^id: {today}-\d{3}$` lines, the new entry's ID line is `id: {today}-003`.
- AC1.3: Quick-capture without participants: no blank lines between frontmatter fields; exactly one blank line between `mode:` and `**Observed**`; no blank lines between body fields; exactly one blank line between `**Follow-up**` and closing `---`.
- AC1.4: Quick-capture with participants: `participants: {names}` immediately after `mode:`, no blank line between them.
- AC1.5: Entry is preceded by exactly one blank line after the `<!-- Entries below this line -->` comment line.
- AC1.6: After the closing `---`, exactly one blank line before any subsequent content.
- AC1.7: Unfilled fields contain exactly `(to fill)` (case-sensitive). Unfilled intervention contains exactly `(none yet)`.
- AC1.8: Field labels are exactly: `**Observed**`, `**Context**`, `**Pattern/Signal**`, `**Hypothesis**`, `**Intervention**`, `**Follow-up**`.

## Dependencies

None. This slice is independent.

## Effort Estimate

< 2 hours. Single SKILL.md edit — rewrite Step 2 and Step 4 sections only.

## Reference Class

SKILL.md spec tightening — similar in scope to the participants-field and mode-field additions in prior cb-log iterations.

## Pre-slice SPIKE

None required. Requirements are fully specified in the original brief and in `feature-delta.md`.
