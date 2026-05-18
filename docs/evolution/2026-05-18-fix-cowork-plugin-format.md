# Evolution: fix-cowork-plugin-format
Date: 2026-05-18 | Version: 1.8.0 | Wave: SPIKE

---

## Summary

Diagnosed and fixed two issues that caused `"invalid plugin format"` on every CoWork
upload attempt since the plugin was first created. Both were silent — the local build
and `claude plugin validate` passed, but CoWork's web validator rejected the zip.

---

## Business Context

The `coach-buddy.plugin` zip is the primary distribution path for CoWork users. Until
this fix, no CoWork upload had ever succeeded. Every upload attempt returned
`"invalid plugin format"` with no detail. The fix unblocks CoWork distribution entirely.

---

## Root Causes Found

### 1 — `metadata:` nesting in SKILL.md frontmatter

The AGENTS-SKILLS.io spec requires `user-invocable: true` and `argument-hint` as
**top-level** YAML frontmatter keys. All six plugin SKILL.mds nested them inside a
`metadata:` block instead. CoWork's validator looks for top-level `user-invocable`
and cannot find it when nested.

**Broken (rejected by CoWork):**
```yaml
metadata:
  user-invocable: true
  argument-hint: '[--force]...'
```

**Fixed (CoWork-compatible):**
```yaml
user-invocable: true
argument-hint: '[--force]...'
```

This divergence was present from the first plugin commit (`77696aa`). The `metadata:`
nesting was likely introduced by the nWave agent during DELIVER without checking
against the CoWork validator. The AGENTS-SKILLS.io spec example in
`docs/feature/coach-buddy-slice-05/feature-delta.md:306` shows the correct flat format.

### 2 — Angle brackets in frontmatter fields

CoWork HTML-sanitises `description` and `argument-hint` field values. Angle-bracket
placeholders like `<team-slug>`, `<observation>`, `<id>` in those fields cause
validation failure. **Only frontmatter fields are affected** — angle brackets in the
SKILL.md body are fine.

All five `cb-*` skills had angle brackets in description or argument-hint:

| Skill | Field | Example |
|---|---|---|
| `cb-init` | `description` | `engagements/<team-slug>/` |
| `cb-log` | `argument-hint` | `<observation> [--update <id>...]` |
| `cb-retro` | `argument-hint` | `<action> [--update <id>...]` |
| `cb-snapshot` | `description` + `argument-hint` | `<team-slug>`, `<lookback-days>` |
| `cb-validate` | `description` + `argument-hint` | `>14 days`, `<7 days`, `<team-slug>` |

Fixed by replacing `<x>` with `[x]` in all frontmatter fields.

---

## Probe Sequence (Binary Search)

| Probe | Change | Result | Learning |
|---|---|---|---|
| A | Strip `repository`, `license`, `keywords`, `skills` from plugin.json | FAIL | Extra fields not the cause |
| B | Plain JSON as `.plugin` (no zip) | FAIL — "not a valid archive" | Must be a zip; CLI `validate` misleadingly accepts JSON only |
| C | Minimal single skill, flat frontmatter | PASS | `metadata:` nesting confirmed as blocker |
| C2 | All 6 skills, flat frontmatter | FAIL | Second issue still present |
| D | coach-buddy (full) + cb-init | FAIL | Narrowed to one of those two |
| E | coach-buddy (full) alone | PASS | coach-buddy is fine; cb-init is the problem |
| F | cb-init alone | FAIL | Confirmed cb-init |
| G | cb-init, frontmatter-only body | FAIL | Issue is in frontmatter, not body |
| H | cb-init, `<team-slug>` → `team-slug` | PASS | Angle brackets confirmed as second blocker |
| Full | All 6 skills, both fixes | PASS | Complete fix validated |

---

## What NOT to Trust

- **`claude plugin validate <path>`** — only validates the manifest JSON file, not the zip.
  When given the `.plugin` zip it fails with a JSON parse error on the PK magic bytes.
  This gives a false sense of security: CI passes, CoWork rejects. The real validation
  gate is a manual upload attempt.

- **`claude plugin validate`** passing in CI — the script validated
  `plugins/coach-buddy/.claude-plugin/plugin.json` directly (which is valid JSON), not
  the zip. CI was not catching CoWork-specific failures.

---

## Changes Made

| File | Change |
|---|---|
| `plugins/coach-buddy/skills/*/SKILL.md` (all 6) | Unwrapped `metadata:` block; replaced `<x>` with `[x]` in description/argument-hint |
| `scripts/validate-plugin.js` | Now enforces top-level `user-invocable: true`, rejects `metadata:` block, rejects angle brackets in frontmatter |
| `tests/unit/validate-plugin.test.js` | Updated to match correct CoWork-compatible format; added angle-bracket regression tests |

---

## CoWork Plugin Format — Reference

For future plugin authors and agents:

**plugin.json** — required fields: `name`, `version`, `description`, `author`, `repository`, `license`, `keywords`, `skills`

**SKILL.md frontmatter** — CoWork-compatible format:
```yaml
---
name: skill-name
description: Single sentence or folded block. No angle brackets. Use [placeholder] not <placeholder>.
version: "1.0.0"        # optional, top-level
user-invocable: true    # MUST be top-level, NOT under metadata:
argument-hint: '[arg] — description'  # top-level, no angle brackets
allowed-tools: Read, Write  # optional, top-level
---
```

**Rules:**
- `user-invocable: true` must be a top-level key — never nested under `metadata:`
- No `metadata:` block at all in plugin SKILL.mds
- No angle brackets (`<`, `>`) in `description` or `argument-hint` values — use `[x]`
- Angle brackets in the body (below the `---`) are fine
- The `.plugin` file is a zip archive, not bare JSON

---

## Lessons Learned

1. **Validate against the real target early.** The full probe chain took most of a session.
   A single upload attempt at the start would have surfaced the error immediately. For
   any plugin change, the first gate should be a CoWork upload test, not a local
   `claude plugin validate`.

2. **`claude plugin validate` is misleading in CI.** It validates the manifest JSON
   directly, not the zip. It does not replicate CoWork's validator. Consider replacing
   or supplementing it with a structural check against the known-good format.

3. **The AGENTS-SKILLS.io spec example was correct** — the `metadata:` nesting was
   an agent error during DELIVER, not a spec ambiguity. When in doubt, the
   `feature-delta.md:306` reference implementation is authoritative.

4. **CoWork error messages are opaque.** `"invalid plugin format"` with no field detail
   forced the entire binary-search probe sequence. Build the validator to emit the
   exact field name and rule that failed so future debugging is cheaper.
