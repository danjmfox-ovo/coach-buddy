# Changelog

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
