# Changelog

## v1.9.0 (2026-05-19)

### Added
- **cb-init `--root` flag**: scaffolds engagement files at the current working directory instead of `engagements/<slug>/`. Designed for CoWork projects where the directory is the engagement. Includes overwrite guard (schema-match on `config.json`) and a `COACHING_LOG.md` collision warning.
- **Engagement Path Resolver**: shared detection pattern embedded in `cb-log`, `cb-retro`, `cb-snapshot`, `cb-validate`, and `coach-buddy`. Checks for `config.json` with `engagement.slug` at project root before falling back to `engagements/<slug>/`. Slug disambiguation bypassed in root layout.
- **coach-buddy `## Engagement context (optional)`**: new section that silently loads `CONTEXT.md`, recent `COACHING_LOG.md` entries, and the latest snapshot when an engagement exists. No error if absent.

### Architecture
- **ADR-012**: documents the `--root` flag design, schema-match detection anchor, and Engagement Path Resolver shared pattern. Extends ADR-010 (engagement context layer).

---

## v1.8.0 (2026-05-15)

### Added
- **cb-validate** (`skills/cb-validate/SKILL.md`): new skill that closes the hypothesis-validation loop in `COACHING_LOG.md`. Reads all logged hypotheses, groups by age (>14d / 7-14d / <7d), leads an interactive validation review, and writes `**Validation**: confirmed|disconfirmed|deferred ({date})` in-place. Surfaces advisory-mode pattern note when ≥2 entries were logged in that mode. (Slice 01)

### Changed
- **cb-snapshot**: appends a `## Coaching context` section to the snapshot file containing the 3 most recent `COACHING_LOG.md` entries (Observed + Hypothesis summaries). Chat risk read is unchanged. Graceful no-op when no coaching log exists. (Slice 02)
- **cb-log**: accepts `--mode thinking-partner|advisory|facilitation` flag. Writes `mode:` field to entry frontmatter. Defaults to `thinking-partner` when omitted. Rejects unrecognised mode values with a clear message. (Slice 03)
- **cb-init**: `CONTEXT.md` Stakeholders section upgraded from a flat comment to a structured 4-column table (Role, Influence, Inclusion notes, External pressures) plus a "Who am I NOT seeing?" reflection prompt. `COACHING_LOG.md` entry format template now shows the `mode:` field. (Slice 03)

### Architecture
- **ADR-011**: documents cb-validate in-place mutation strategy (validation result appended to matched entry in COACHING_LOG.md; same id-match mechanism as cb-log --update).
- **jobs.yaml**: new `hypothesis-validation` job added (closes the loop on Safety-II-informed hypothesis capture).

---

## v1.7 (2026-05-12)

### Added
- **npx installer** (`bin/install.js`): detects Claude Code (project or user level) and Cursor; copies SKILL.md, custom-instructions.md, references/, and assets/ to the correct skills directory. Refuses to overwrite without `--force`. Prints manual Chat Project instructions when no tool is detected.
- **package.json**: publishes as `coach-buddy` on npm. Not yet published.
- **Sources section** in README: credits [johnpcutler/change-lenses-and-actions](https://github.com/johnpcutler/change-lenses-and-actions) (SKILL.md pattern) and [nWave-ai/nWave](https://github.com/nWave-ai/nWave) (development methodology).
- **ADR-009**: documents the `npx coach-buddy` distribution decision and Wilderness Exception label.
- **Acceptance tests** (`tests/acceptance/coach-buddy-slice-04/installer.feature`): 6 scenarios covering all install paths and overwrite guard.

### Changed
- **README Quick Install**: updated from aspirational `npx skills add` (unbacked) to `npx coach-buddy` with flag documentation.

---

## v1.6 (2026-05-12)

### Changed
- **Mode redirect phrase set**: changed from exhaustive list to examples of the coaching register. Situationally-grounded variants permitted; tool-specific language prohibited. Added "I'm detecting two signals" and "I notice we've shifted topics" to explicit prohibition list.

### Fixed
- **Ambiguity check language**: "both signals in the same message" is internal language — prohibited alongside other tool-specific phrases. D4 fires using coaching register only.

---

## v1.5 (2026-05-12)

### Fixed
- **ER-005**: "Offer, don't auto-deliver" rule was too broad — applied even when the coach directly asked a question about a framework. Active explicit questions ("what is it about X...?") now treated as acceptance; situated deep-dive delivered directly. Offer gate applies to passive signals only.
- **ER-006**: Two-question pattern within a single turn. Language and style rule now explicit: after multiple hypotheses, choose one question and cut the rest. The urge to ask two is a signal to sharpen, not to ask both.
- **Mode redirect phrase set**: changed from exhaustive list to examples of the coaching register. Situationally-grounded variants permitted; tool-specific language prohibited. Added "I'm detecting two signals" and "I notice we've shifted topics" to explicit prohibition list.
- **Ambiguity check language**: "both signals in the same message" is internal language — prohibited alongside other tool-specific phrases. D4 fires using coaching register only.

---

## v1.4 (2026-05-12) — Slice 02: Growth Vehicle

### Added
- **Interest signal offer**: when any of the 6 signals fires, tool offers a framework deep-dive rather than auto-delivering. Offer fires once per concept per conversation. If the concept is unattributed, attribution is embedded in the offer.
- **Situated deep-dive (Phase B)**: when the coach accepts, response is structured as: what it is (1 sentence) + how it applies to this specific situation (2-3 sentences) + one practical implication. Returns to Phase A ("What's your read on that?") after delivery.
- **N-phase lifecycle** (Conversation arc): interest signal → offer → accept → situated deep-dive → return to Phase A. N is a branch, not a destination.
- **Mode redirect specificity**: four registered phrases are the complete permitted set. Tool-specific language explicitly prohibited. Redirect does not re-fire until a new topic discontinuity.
- **Ambiguity check constraints**: fires only when all three D4 conditions are simultaneously true. D5 (stated stakes) suppresses the ambiguity check.

---

## v1.3 (2026-05-12)

### Fixed
- **ER-004**: Named framework concepts used as conversational vocabulary were bypassing the attribution rule. Explicit vocabulary exemption removed — attribution required on first use regardless of framing. Examples added inline: psychological safety (Edmondson), Cynefin (Snowden), polarity thinking (Johnson).

---

## v1.2 (2026-05-12)

### Added
- **DNA conversation arc** (ADR-007): explicit conversation lifecycle — Define / New topics / Actions. Tool tracks which phase it's in and names transitions using coaching language. Coach can redirect any transition or move backwards (repivot) when new information surfaces.

### Fixed
- **ER-003**: Action-planning phase felt like interrogation. Tool was using D-phase behaviour (follow-up question after each answer) in A-phase. Fix: A-phase now opens with a synthesis of the diagnostic picture before asking anything. One question at most before offering something again.

---

## v1.1 (2026-05-12)

### Fixed
- **ER-002**: Tool was withholding domain knowledge pending calibration. Now leads with one observation from the initial description before asking anything. Never asks two questions in a row without synthesis between them.
- **ER-001**: No exit condition on the calibration loop. Now transitions explicitly after 3–4 exchanges: "I think I have enough to work with — let me reflect back what I'm hearing."

### Changed
- Opening protocol: calibration signals gathered as conversation develops, not extracted upfront
- Reference files now explicitly optional — SKILL.md is self-sufficient; reference files enrich when present

## v1.0 (2026-05-12)

Initial release.

- SKILL.md: full thinking-partner pipeline (mode management, attribution, calibration, Phase A/B delivery)
- Six ADRs documenting architectural decisions (docs/product/architecture/)
- Five primary framework reference files: complexity, work-layers, teams, development, tensions
- Calibration canvas asset
