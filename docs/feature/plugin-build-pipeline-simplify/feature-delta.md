# Feature Delta: plugin-build-pipeline-simplify

**Type**: Infrastructure (build tooling only — no user-visible behaviour change)
**JTBD**: `infrastructure-only` — enables the plugin release pipeline; no coaching job directly served
**Infrastructure rationale**: Eliminates an orphaned staging directory from the repo. The only observable outcome is that `plugins/` no longer exists as tracked content and the build continues to produce an identical `coach-buddy.plugin` artifact.

---

## Problem

`plugins/coach-buddy/` was created as a local staging scaffold. It contains one tracked file that matters (`plugin.json`) and one gitignored build output directory (`skills/`). The directory structure implies a permanent home that does not exist in CoWork convention. It adds noise to `git status`, misleads new contributors, and makes the manifest harder to find.

**Current state:**
- `plugins/coach-buddy/plugin/plugin.json` — tracked manifest, buried path
- `plugins/coach-buddy/skills/` — gitignored build output (sync target of `sync-skills.js`)
- `build:plugin` script: `sync-skills.js` → `validate-plugin.js` → `cd plugins/coach-buddy && zip -r ...`
- Four scripts hold hardcoded references to `plugins/coach-buddy/`: `sync-skills.js`, `validate-plugin.js`, `check-version.js`, and the `build:plugin` / `build:plugin:ci` inline commands in `package.json`

**Target state:**
- `plugin.json` at `plugin/plugin.json` (repo root — mirrors CoWork's own convention)
- `plugins/` directory eliminated entirely from repo
- Build assembles zip from a transient temp directory; no staged directory persists after `build:plugin` completes
- `.gitignore` updated: remove `plugins/coach-buddy/skills/`; it no longer exists

---

## Locked Decisions

### Decision 1: New location for `plugin.json`

**Chosen**: `plugin/plugin.json` at repo root.

**Rationale**: `.claude-plugin/` is already occupied at the repo root — it contains `marketplace.json` used by Claude Code for project-level plugin configuration. Placing `plugin.json` there would create a naming collision. `plugin/` is the next simplest option: single-purpose, discoverable at root level, no invented nesting, no collision risk.

**Rejected alternatives**:
- `plugin/plugin.json` — collision: `.claude-plugin/` already contains `marketplace.json` (Claude Code's own directory)
- `src/plugin/plugin.json` — adds a `src/` layer that doesn't exist elsewhere in this repo
- `scripts/plugin.json` — wrong signal; `scripts/` is for executable tooling, not manifests

### Decision 2: Staging strategy for the zip build

**Chosen**: Use `$TMPDIR` (or `/tmp` in CI) as the assembly directory. `sync-skills.js` writes transformed skills to a temp path. `validate-plugin.js` reads from that temp path. `zip` assembles from temp path. No directory persists in the repo after the build.

**Rationale**: The `plugins/` directory's only purpose was staging. Moving staging to `$TMPDIR` eliminates the tracked/ignored hybrid while keeping the exact same assembly logic. No new tool dependency; `$TMPDIR` is available in all targeted environments.

**Temp path convention**:
- Local builds: `$TMPDIR/coach-buddy-plugin-build/` (already used for the output zip)
- CI builds: `/tmp/coach-buddy-plugin-build/`

### Decision 3: Script path update scope

All four script references to `plugins/coach-buddy/` must change in the same commit — no partial state. The affected surface is:

| File | Change |
|---|---|
| `scripts/sync-skills.js` | `outputDir` → `$TMPDIR/coach-buddy-plugin-build/` (passed as env var or derived at runtime) |
| `scripts/validate-plugin.js` | `pluginJsonPath` → `resolve(rootDir, 'plugin/plugin.json')`; `skillsDir` → temp build dir |
| `scripts/check-version.js` | `pluginJson` source → `resolve(rootDir, 'plugin/plugin.json')` |
| `package.json` `build:plugin` | Remove `cd plugins/coach-buddy` navigation; zip from temp dir |
| `package.json` `build:plugin:ci` | Same as above for CI variant |
| `.gitignore` | Remove `plugins/coach-buddy/skills/` line |

---

## User Stories

### US-PBPS-01: Build pipeline assembles plugin without a tracked staging directory

**Type**: `@infrastructure`
**job_id**: `infrastructure-only`
**Infrastructure rationale**: Removes an orphaned directory from the repo. No coaching job, no user-visible behaviour change. Enables a cleaner repo state for all future plugin release work.

#### Problem
The build pipeline depends on `plugins/coach-buddy/` existing as a half-tracked, half-ignored directory. This is confusing repo hygiene and makes `plugin.json` harder to locate.

#### Who
- Dan (maintainer) running `npm run build:plugin` locally or in CI

#### Solution
Move `plugin.json` to `plugin/plugin.json` at repo root. Retarget all scripts to assemble from a `$TMPDIR` staging area. Delete `plugins/` directory from the repo.

#### Domain Examples
1. **Local build** — Dan runs `npm run build:plugin`. Script creates `$TMPDIR/coach-buddy-plugin-build/`, syncs skills there, validates, zips to `coach-buddy.plugin` at repo root. `plugins/` does not exist. `git status` is clean.
2. **CI build** — GitHub Actions runs `npm run build:plugin:ci`. Uses `/tmp/coach-buddy-plugin-build/`. Same output. No `plugins/` directory created. Artifact attached to release.
3. **Version check** — Dan runs `npm run check:version`. Script reads `plugin/plugin.json` at root. Reports alignment. Does not attempt to read `plugins/coach-buddy/plugin/plugin.json`.

#### UAT Scenarios (BDD)

```gherkin
Scenario: Plugin zip is produced without a staging directory in the repo
  Given the plugins/ directory has been deleted from the repo
  And plugin.json lives at plugin/plugin.json
  When Dan runs npm run build:plugin
  Then coach-buddy.plugin is created at the repo root
  And no plugins/ directory is created during or after the build
  And git status shows no untracked or modified paths under plugins/

Scenario: Plugin manifest is validated from its new location
  Given plugin.json has been moved to plugin/plugin.json
  When npm run build:plugin invokes validate-plugin.js
  Then the validator reads plugin/plugin.json successfully
  And validation passes with the same rules as before

Scenario: Version check reads plugin.json from repo root
  Given plugin.json is at plugin/plugin.json
  When Dan runs npm run check:version
  Then the script reports the version from plugin/plugin.json
  And the output does not reference plugins/coach-buddy/

Scenario: Skills are synced to temp dir and excluded from git
  Given sync-skills.js targets a temp directory under $TMPDIR
  When npm run build:plugin runs sync-skills.js
  Then skill files are written to $TMPDIR/coach-buddy-plugin-build/skills/
  And no skill files are written inside the repo working tree
  And git status shows no new untracked files

Scenario: Build fails fast if plugin.json is missing required fields
  Given plugin/plugin.json is missing the "version" field
  When npm run build:plugin runs validate-plugin.js
  Then the build exits non-zero with a message naming the missing field
  And no .plugin artifact is produced
```

#### Acceptance Criteria
- [ ] `npm run build:plugin` produces `coach-buddy.plugin` at repo root with no `plugins/` directory created
- [ ] `npm run check:version` reads from `plugin/plugin.json` — exits 0 when versions align
- [ ] `git status` is clean after a successful build (no new untracked paths)
- [ ] Validation failure (missing required field) exits non-zero before the zip step
- [ ] `.gitignore` no longer references `plugins/coach-buddy/skills/`

#### Technical Notes
- `sync-skills.js` needs to accept or derive the output dir; currently hardcoded as `plugins/coach-buddy/skills`. Derive at runtime: `process.env.PLUGIN_BUILD_DIR ?? path.join(os.tmpdir(), 'coach-buddy-plugin-build')`.
- `validate-plugin.js` CLI reads `pluginDir` from `process.env.PLUGIN_BUILD_DIR` when set; falls back to a sensible default for backward-compat programmatic use in tests.
- `package.json` `build:plugin` becomes: `PLUGIN_BUILD_DIR=$TMPDIR/coach-buddy-plugin-build node scripts/sync-skills.js && node scripts/validate-plugin.js && rm -f "$TMPDIR/coach-buddy.plugin" && zip -r "$TMPDIR/coach-buddy.plugin" "$TMPDIR/coach-buddy-plugin-build" -x '*.DS_Store' && cp ...`
- Existing unit tests for `validate-plugin.js` and `sync-skills.js` use programmatic imports — they will continue to work because the pure domain logic functions (`validatePlugin`, `transformFrontmatter`, `syncSkillDir`) do not hardcode paths.
- The `.claude-plugin/` directory at repo root is already used by Claude Code itself for project-level configuration — confirm no naming collision before placing `plugin.json` there. If collision, use `plugin/plugin.json` instead.

---

## Out of Scope

- Changes to `plugin.json` content (fields, version, skills list) — content is unchanged, only location moves
- Changes to `skills/` directory structure or SKILL.md files
- Changes to the npm publish pipeline (`bin/install.js`, `package.json` `files` array)
- Adding new build targets or CI workflows
- Changing the zip format or contents of `coach-buddy.plugin`

---

## Definition of Done

- [ ] `plugin.json` moved from `plugins/coach-buddy/plugin/plugin.json` to `plugin/plugin.json` at repo root
- [ ] `plugins/` directory deleted from the repo (no tracked files remain)
- [ ] `.gitignore` line `plugins/coach-buddy/skills/` removed
- [ ] `scripts/sync-skills.js` — output directory derives from `PLUGIN_BUILD_DIR` env var (defaults to `$TMPDIR/coach-buddy-plugin-build`)
- [ ] `scripts/validate-plugin.js` — `pluginJsonPath` points to `plugin/plugin.json`; `skillsDir` reads from `PLUGIN_BUILD_DIR`
- [ ] `scripts/check-version.js` — `pluginJson` source points to `plugin/plugin.json`
- [ ] `package.json` `build:plugin` and `build:plugin:ci` updated — no `cd plugins/coach-buddy`
- [ ] `npm run build:plugin` passes end-to-end: valid `coach-buddy.plugin` produced, `git status` clean
- [ ] `npm run check:version` passes: reads from new manifest location
- [ ] `npm test` passes: no broken imports or path assertions in existing tests
- [ ] All five UAT scenarios pass
- [ ] Conventional commit: `refactor(build): move plugin.json to repo root, eliminate plugins/ staging dir`

