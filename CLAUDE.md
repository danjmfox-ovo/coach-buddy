# coach-buddy

Claude Code skill plugin for Agile Coaches. Skills live in `skills/`, plugin manifest in `coach-buddy.plugin`, tests in `tests/` (Vitest).

## Structure

- `skills/<skill-name>/SKILL.md` — skill instruction files (the "source code")
- `docs/feature/<feature-id>/` — nWave feature work; `feature-delta.md` is the single DISCUSS output (not legacy multi-file)
- `docs/feature/<feature-id>/slices/slice-NN-*.md` — Elephant Carpaccio slice briefs
- `docs/feature/<feature-id>/discuss/` and `slices/` are created by nWave waves but may be untracked — commit them during `nw-finalize` as paper trail
- `docs/evolution/` — one `YYYY-MM-DD-<feature>.md` per completed feature; if duplicates exist (multiple dates, same feature), the newest date is authoritative — delete older copies
- **Feature status check**: before investigating a feature, check `docs/evolution/` first — if an entry exists, the feature is fully shipped; `docs/feature/` is the active workspace
- `docs/product/jobs.yaml` — SSOT for validated Jobs-to-be-Done
- `docs/product/journeys/`, `docs/product/personas/` — SSOT journey and persona files
- `docs/product/architecture/` — ADRs and architecture briefs live here (not `docs/adrs/`); nWave destination map default does not apply
- No `src/` directory — this is a plugin project, not a Node app

## Absent SSOT files (don't look for these)

- `docs/product/vision.md` — does not exist
- `docs/project-brief.md` — does not exist
- `docs/stakeholders.yaml` — does not exist

## CI

- Workflow: `Release` (push to main) — check with `gh run list --limit 10`
- Build script: `build:plugin:ci` — bundles the plugin zip
- Releases tagged `vX.Y.Z`; each successful run cuts a new version
- **Release requires a manual tag:** `git tag vX.Y.Z && git push origin vX.Y.Z` — CI does not auto-tag from a version bump

## nWave

- Density: `lean + ask-intelligent` (`~/.nwave/global-config.json`)
- Rigor profile: on-demand, not mandatory gates (hobby project on Claude Pro)
- Feature IDs follow kebab-case: `cb-log-deterministic-writes`, `cb-root-layout`, etc.

## DES / Delivery Engine

- `execution-log.json` must be read via the `Read` tool — DES pre-bash hook blocks `cat`/Bash access to this file
- `execution-log.json` is intentionally empty for SKILL.md-only features (no compiled TDD phases to instrument)
- `nw-finalize` pre-dispatch gate: if execution-log.json is empty, verify completion via `roadmap.json` `validation.status = "approved"` — do not block finalization
- SKILL.md features have no `design/` or `distill/` subdirectories — all wave content is embedded in `feature-delta.md`; `nw-finalize` Phase B will find nothing to migrate
- `.nwave/des-config.json` has no `rigor` key — all rigor defaults apply (lean, on-demand gates)
