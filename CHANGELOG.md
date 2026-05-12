# Changelog

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
