# Feature Delta — cb-log-deterministic-writes

> Wave: DISCUSS | Date: 2026-05-20 | Density: lean + ask-intelligent | No expansions triggered

---

## Wave: DISCUSS / [REF] Persona ID

**Agile Coach — log maintainer**. An experienced practitioner who captures coaching observations via `/cb-log` across multiple independent Claude Code sessions over days or weeks, and periodically refines entries with `/cb-log --update`.

---

## Wave: DISCUSS / [REF] JTBD One-liner

When cb-log is invoked across multiple sessions, the coach wants entries to always follow the same canonical format so the coaching log is reliable to read, search, and update regardless of which session wrote the entry.

Job: `reliable-log-capture` (added to `docs/product/jobs.yaml`)

---

## Wave: DISCUSS / [REF] Locked Decisions

| # | Decision | Verdict | Rationale |
|---|---|---|---|
| D1 | How to count today's entries for ID generation | Scan every line for `^id: YYYY-MM-DD-\d{3}$`; count = matching lines | More robust than counting `---` pairs; immune to HR rules and YAML front matter elsewhere in the file |
| D2 | One template with optional fields vs two canonical templates | Two canonical templates (with-participants / without-participants) | Eliminates writer optionality; each template has zero ambiguous paths |
| D3 | Blank line between `<!-- Entries below this line -->` comment and opening `---` | Exactly one blank line | Consistent with markdown block element separation; zero risks comment and entry fusing visually |
| D4 | Update mechanic: whole-line replacement vs partial-value replacement | Replace the entire `{label}: {value}` line | Simpler match; no partial-match side effects; values in the current format are single-line |
| D5 | Blank line after closing `---` of an entry | Exactly one blank line before subsequent content | Consistent inter-entry spacing regardless of insertion order |

---

## Wave: DISCUSS / [REF] User Stories

### Story 1 — New entry determinism

```
job_id: reliable-log-capture

As an Agile Coach using coach-buddy,
when I invoke `/cb-log` in any session,
I want new entries to always follow the same canonical format,
so that my COACHING_LOG.md is consistent regardless of which LLM session wrote the entry.
```

#### Elevator Pitch

Before: Running `/cb-log` in two different sessions can produce entries with different blank lines, different field-label capitalisation, or different placeholder text — making historical review visually inconsistent.
After: run `/cb-log "I noticed the team skipped the retro"` → entry in COACHING_LOG.md always matches the canonical template exactly (ID pattern, whitespace, field labels, placeholder strings).
Decision enabled: I can review and compare log entries from any time period knowing the format is identical.

#### Acceptance Criteria

- AC1.1: Given `COACHING_LOG.md` has zero lines matching `^id: {today}-\d{3}$`, when `/cb-log` completes, the new entry's ID line is `id: {today}-001`.
- AC1.2: Given `COACHING_LOG.md` has two lines matching `^id: {today}-\d{3}$`, when `/cb-log` completes, the new entry's ID line is `id: {today}-003`.
- AC1.3: Quick-capture without participants: no blank lines between frontmatter fields; exactly one blank line between the last frontmatter field (`mode:`) and `**Observed**`; no blank lines between body fields; exactly one blank line between `**Follow-up**` and the closing `---`.
- AC1.4: Quick-capture with participants: `participants: {names}` appears on the line immediately after `mode:`, with no blank line between them.
- AC1.5: The new entry is preceded by exactly one blank line after the `<!-- Entries below this line -->` comment line.
- AC1.6: After the closing `---` of the new entry, there is exactly one blank line before any subsequent content (next entry or end of file).
- AC1.7: Unfilled fields contain exactly `(to fill)` (lowercase, parenthesised, no trailing punctuation). Unfilled intervention contains exactly `(none yet)`.
- AC1.8: Field labels match exactly: `**Observed**`, `**Context**`, `**Pattern/Signal**`, `**Hypothesis**`, `**Intervention**`, `**Follow-up**` — no capitalisation or punctuation variation.

---

### Story 2 — Update determinism

```
job_id: reliable-log-capture

As an Agile Coach using coach-buddy,
when I invoke `/cb-log --update <id> <field> <value>`,
I want the skill to reliably find and replace exactly the right field line,
so that I can refine entries without formatting side effects.
```

#### Elevator Pitch

Before: `--update` depends on finding e.g. `**Pattern/Signal**: (to fill)` — if a prior session wrote the label in the wrong case or with unexpected whitespace, the update fails silently or targets the wrong line.
After: run `/cb-log --update 2026-05-20-001 pattern "Avoidance of difficult conversations"` → exactly the line `**Pattern/Signal**: (to fill)` becomes `**Pattern/Signal**: Avoidance of difficult conversations`. All other lines in the file are byte-for-byte unchanged.
Decision enabled: I can trust that refining a field doesn't corrupt adjacent entries or introduce side effects.

#### Acceptance Criteria

- AC2.1: Given an entry written by the skill, `/cb-log --update <id> pattern "New value"` changes only the line `**Pattern/Signal**: <old>` → `**Pattern/Signal**: New value`. All other lines in the file are unchanged.
- AC2.2: `/cb-log --update <id> followup "Watch for..."` changes only `**Follow-up**: <old>` → `**Follow-up**: Watch for...`. The `---` delimiters, blank lines, and all other fields are byte-for-byte identical.
- AC2.3: CLI→label mapping is enforced: `observed`→`**Observed**`, `context`→`**Context**`, `pattern`→`**Pattern/Signal**`, `hypothesis`→`**Hypothesis**`, `intervention`→`**Intervention**`, `followup`→`**Follow-up**`.
- AC2.4: Given an ID that does not exist, the output is exactly: `Entry {id} not found in {engagement_path}COACHING_LOG.md. Check the ID with /cb-log --list.`

---

## Wave: DISCUSS / [REF] Definition of Done

- [ ] All Story 1 (AC1.1–AC1.8) and Story 2 (AC2.1–AC2.4) verified by running `/cb-log` and `/cb-log --update` in a fresh session
- [ ] SKILL.md changes are backward-compatible — existing COACHING_LOG.md entries remain readable and updatable
- [ ] Both write paths produce identical output given identical inputs across two independent test runs
- [ ] `reliable-log-capture` job added to `docs/product/jobs.yaml`
- [ ] 5 judgment calls documented in PR notes and confirmed by the original author
- [ ] Slice briefs exist for both slices at `docs/feature/cb-log-deterministic-writes/slices/`
- [ ] No `(to fill)` or `(none yet)` appear in the SKILL.md's own prose (only inside entry templates)
- [ ] SKILL.md edit committed with conventional commit message
- [ ] feature-delta.md contains all Tier-1 [REF] sections

---

## Wave: DISCUSS / [REF] Out of Scope

- Migrating existing COACHING_LOG.md entries to the canonical format
- Adding external scripts, linters, or validators to enforce the format
- Multi-line field values (format is single-line per field)
- Changing the skill's UX — prompts, questions, interaction flow
- Adding new fields to the entry format
- Supporting hand-written or pre-cb-log entries that predate the format

---

## Wave: DISCUSS / [REF] WS Strategy

**Strategy A — Thin Slice**. Single SKILL.md file, no new integration points, both slices ship end-to-end in <1 day. No walking skeleton phase required. Slices are sequenced: Slice 01 (new entry path) before Slice 02 (update path) because update reliability depends on deterministic entry format.

---

## Wave: DISCUSS / [REF] Driving Ports

| Port | Invocation |
|---|---|
| CLI — new entry | `/cb-log <observation>` |
| CLI — update | `/cb-log --update <id> <field> <value>` |

---

## Wave: DISCUSS / [REF] Pre-requisites

- cb-log skill is in a working state (no in-progress breaking changes)
- At least one engagement exists with a COACHING_LOG.md containing the `<!-- Entries below this line -->` marker
- `docs/product/jobs.yaml` writable (SSOT update required for `reliable-log-capture`)

---

## Wave: DISCUSS / [REF] Story Map

**Backbone activities**:
`Invoke` → `Generate ID` → `Write entry` → `Confirm`
`Invoke --update` → `Find entry` → `Replace field line` → `Confirm`

**Slices**:

| Slice | Scope | Effort | Learning hypothesis |
|---|---|---|---|
| slice-01-new-entry-determinism | ID rule + canonical templates + prepend position + placeholder strings | <2h | Disproves: rules are insufficient if sessions still produce differently-formatted entries. Confirms: two independent runs with identical inputs produce identical output. |
| slice-02-update-determinism | CLI→label mapping table + single-line replacement rule | <1h | Disproves: mapping + replacement rule is insufficient if `--update` changes the wrong line. Confirms: exactly one line changes; all others are unchanged. |

**Sequence**: Slice 01 before Slice 02 (update reliability depends on deterministic entry format).

---

## Wave: DISCUSS / [REF] Outcome KPIs

| KPI | Target | Measurement |
|---|---|---|
| Entry format consistency | Two independent `/cb-log` invocations with identical inputs produce byte-for-byte identical entries | Manual: run in two fresh sessions; diff the produced entries; expected: zero diff |
| Update reliability | `/cb-log --update` changes exactly one line; all others unchanged | Manual: diff file before/after update; count changed lines = 1 |
| Author sign-off | All 5 judgment calls reviewed and confirmed | Checklist in PR description |

---

## Wave: DISCUSS / [REF] Wave Decisions

### Key Decisions
- [D1] ID counting via `^id: DATE-\d{3}$` pattern — see Locked Decisions
- [D2] Two canonical templates — see Locked Decisions
- [D3–D5] Blank line rules — see Locked Decisions

### Requirements Summary
Primary job: coach needs consistent, reliable COACHING_LOG.md entries across sessions. Two write paths (new entry, update) must each be deterministic. Scope: one SKILL.md file, two slices, <1 day total.

### Feature type
Infrastructure — SKILL.md spec file, no runtime code.

### Constraints Established
- No external scripts (per original brief)
- No UX changes
- Values are single-line only
- Backward-compatible: existing entries remain valid (rules apply to writes, not retroactively to reads)

### Upstream Changes
None — no prior DISCOVER wave. This feature starts at DISCUSS.

---

## Wave: DISCUSS / [REF] Expansion Menu

No triggers fired (1 bounded context, 1 technology, 1 persona, no regulatory terms, WS strategy A). Lean output — no expansions suggested.
