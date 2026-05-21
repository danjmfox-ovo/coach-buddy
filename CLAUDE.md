# coach-buddy

Claude Code skill plugin for Agile Coaches. Skills live in `skills/`, tests in `tests/` (Vitest). `coach-buddy.plugin` is the built zip artifact — not the manifest.

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
- `tests/acceptance/<feature-id>/` — manual conversation tests (Gherkin `.feature` files, WS Strategy C); no automated runner — executed in a real CoWork project via Claude Code
- No `src/` directory — this is a plugin project, not a Node app

## Absent SSOT files (don't look for these)

- `docs/product/vision.md` — does not exist
- `docs/project-brief.md` — does not exist
- `docs/stakeholders.yaml` — does not exist

## Plugin pipeline

- Plugin source: `plugins/coach-buddy/` — skills at `plugins/coach-buddy/skills/`, manifest at `plugins/coach-buddy/.claude-plugin/plugin.json`
- `coach-buddy.plugin` is gitignored (build artifact) — install from repo root after building, or download from GitHub Releases
- `npm run build:plugin` — `rm -f` then `cd plugins/coach-buddy && zip -r . ...` → copies to repo root; **`zip` accumulates stale entries if not deleted first** (scripts now delete before zipping)
- `npm run check:version` validates `package.json` vs `plugins/coach-buddy/.claude-plugin/plugin.json` vs `skills/coach-buddy/SKILL.md` vs `CHANGELOG.md`
- **Plugin skills are NOT auto-synced** — `plugins/coach-buddy/skills/` must be manually copied from `skills/` before cutting a release; stale plugin skills are a recurring drift risk

## CI

- Workflow: `Release` (push to main) — check with `gh run list --limit 10`
- Build script: `build:plugin:ci` — bundles the plugin zip
- CI triggers on tag push, not on merge to main — a push to main alone does NOT cut a release
- **Release requires a manual tag:** `git tag vX.Y.Z && git push origin vX.Y.Z` — CI does not auto-tag from a version bump
- If a tag already exists on origin (e.g. stale failed tag): `git tag -f vX.Y.Z HEAD && git push --force origin vX.Y.Z`

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
- **DES CLI requires PYTHONPATH prefix** (pipx install doesn't add `des` to `sys.path`): `PYTHONPATH=~/.local/pipx/venvs/nwave-ai/lib/python3.13/site-packages/nWave/lib/python des-init-log ...`
- `des-verify-integrity` is broken in pipx context — `TDDSchemaLoader` resolves schema path incorrectly (looks in `nWave/lib/nWave/templates/`, actual location is `nWave/templates/`); skip Phase 6 until upstream fix

## Release checklist (recurring drift risks)

- `plugins/coach-buddy/README.md` — update version and skills table on every release; does not auto-sync with `package.json`
- `plugins/coach-buddy/skills/` — sync all changed skills from `skills/` before tagging; no automation does this
- `docs/product/architecture/brief.md` — new ADRs must be manually added to the primary ADR index table (not just written as files); easy to miss
- `CHANGELOG.md` heading must use full semver: `## v1.X.Y` not `## v1.X` — `npm run check:version` validates this

## Reference projects

- CoWork engagement root-layout: `~/projects/ovo/teams/advisor-connect` — live reference for `cb-init --root` and Engagement Path Resolver behaviour
