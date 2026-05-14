<!-- markdownlint-disable MD024 -->
# User Stories: coach-buddy-plugin-distribution

## System Constraints

- Distribution surface: GitHub Releases (not npm, not binary in git)
- Version source of truth: `package.json` — all other sources must agree
- `gh` CLI required for manual release workflow (Slice 1); GitHub Actions for Slice 2
- `*.plugin` stays in `.gitignore` — only the GitHub Release asset is the distribution artifact
- No new runtime dependencies — this is build/release tooling only

---

## US-01: Manual Plugin Release Workflow

### Problem

Dan has built `coach-buddy.plugin` locally and wants to share it with CoWork users, but there is no distribution mechanism. The plugin is excluded from git (`.gitignore`). The only install path currently documented assumes you clone the repo. A CoWork user who finds the project on GitHub has no way to get the plugin without cloning and building it themselves.

### Elevator Pitch

**Before**: After tagging a release, Dan manually explains "clone the repo and run `npm run build:plugin`" to anyone who wants the CoWork plugin. There is no shareable link and no standard install path.

**After**: Dan runs `gh release create v1.7.0 coach-buddy.plugin` (documented in PUBLISHING.md), and any CoWork user follows the README link to download `coach-buddy.plugin` directly from the GitHub Release page and uploads it to CoWork.

**Decision enabled**: Dan can share coach-buddy with CoWork users by sending a single GitHub Releases URL, without requiring git access, Node.js, or any build step on their end.

### Who

- Dan Fox, solo maintainer, releasing a new version of coach-buddy
- CoWork users who discover the project via GitHub and want to install it in CoWork without cloning

### Solution

Add a `check:version` npm script that validates all version sources agree before release. Update PUBLISHING.md with the `gh release create` command including plugin attachment. Update README CoWork install section with the release asset download pattern.

### Domain Examples

#### 1: Happy release — all versions aligned

Dan has run `npm version patch` which updated `package.json` to `1.7.0`. He manually updated `plugin.json`, `SKILL.md` frontmatter, and added a `1.7.0` heading to `CHANGELOG.md`. He runs `npm run check:version` — all four sources report `1.7.0`. He builds the plugin, runs `gh release create v1.7.0 coach-buddy.plugin`, and posts the release URL in the CoWork community.

#### 2: Version mismatch blocked before release

Dan bumped `package.json` to `1.7.1` for a patch fix but forgot to update `plugin.json` (still at `1.7.0`). He runs `npm run check:version` before building. The script exits non-zero and prints: `plugin.json: 1.7.0 MISMATCH (expected 1.7.1 from package.json)`. Dan updates `plugin.json` and re-runs. All sources align. He proceeds.

#### 3: CoWork user installs from release

Sara Okafor finds coach-buddy on GitHub. She follows the CoWork install instructions in the README, clicks the `v1.7.0` release link, downloads `coach-buddy.plugin`, and uploads it in CoWork Settings → Plugins → Upload plugin. `/coach-buddy` is available immediately. She never ran `npm` or `git clone`.

### UAT Scenarios (BDD)

```gherkin
Scenario: Version check passes when all sources are aligned
  Given Dan has updated package.json, plugin.json, SKILL.md frontmatter, and CHANGELOG.md to version 1.7.0
  When Dan runs npm run check:version
  Then the script prints each source with OK status
  And exits with code 0

Scenario: Version check blocks release on mismatch
  Given package.json is at 1.7.1 and plugin.json is still at 1.7.0
  When Dan runs npm run check:version
  Then the script identifies plugin.json as the misaligned source
  And prints the expected version (1.7.1) and the found version (1.7.0)
  And exits with a non-zero code

Scenario: Plugin release is published to GitHub with asset attached
  Given coach-buddy.plugin has been built at the repo root
  And check:version has passed for 1.7.0
  And Dan is authenticated with the gh CLI
  When Dan runs the gh release create command documented in PUBLISHING.md
  Then a GitHub Release exists at https://github.com/danjmfox-ovo/coach-buddy/releases/tag/v1.7.0
  And coach-buddy.plugin is listed as a downloadable release asset

Scenario: CoWork user installs plugin from release URL without cloning
  Given the v1.7.0 GitHub Release has coach-buddy.plugin attached
  When Sara downloads coach-buddy.plugin from the release asset URL
  And uploads it in CoWork Settings > Plugins > Upload plugin
  Then all five skills (coach-buddy, cb-init, cb-log, cb-retro, cb-snapshot) are available in CoWork
  And the plugin version reported in CoWork matches 1.7.0

Scenario: README CoWork section references the release download pattern
  Given the v1.7.0 GitHub Release is published
  When a new user reads the README CoWork install section
  Then the section contains a link to the GitHub Releases page
  And the install instructions do not require cloning the repo or running npm
```

### Acceptance Criteria

- [ ] `npm run check:version` exists and compares all four version sources
- [ ] Script exits non-zero and names the offending file when any source mismatches package.json
- [ ] PUBLISHING.md includes `gh release create v${VERSION} coach-buddy.plugin` with release notes guidance
- [ ] PUBLISHING.md includes `plugin.json` in the version-alignment checklist
- [ ] README CoWork install section references GitHub Releases download (not clone-and-build)
- [ ] A GitHub Release at any `v*` tag includes `coach-buddy.plugin` as a downloadable asset

### Outcome KPIs

- **Who**: CoWork users discovering coach-buddy via GitHub
- **Does what**: Install the plugin without cloning the repo
- **By how much**: Install path reduced from 4 manual steps (clone, install Node deps, build, upload) to 1 (download and upload)
- **Measured by**: Presence of a working download URL; README install instructions requiring no local build
- **Baseline**: Currently no download URL exists; all CoWork installs require repo clone

### Technical Notes

- Requires `gh` CLI installed and authenticated (`gh auth login`) for Slice 1
- `check:version` script reads: `package.json` (via JSON.parse), `plugin.json`, `SKILL.md` frontmatter (YAML parse or regex), `CHANGELOG.md` (heading regex)
- `SKILL.md` frontmatter `version:` field — confirm this field exists and is maintained; if absent, check:version should warn but not block (it is not a release-blocking source if not present)
- No new runtime dependencies: script uses Node.js built-ins only
- `*.plugin` stays in `.gitignore` — the build artifact is distributed via GitHub Releases only

### Dependencies

- `gh` CLI available in the maintainer environment (external, assumed present)
- `npm run build:plugin` already works (confirmed in package.json)
- Red Card R1 resolved: confirm whether `1.7.0` or `1.6.0` is the correct next version before implementing

### job_id: infrastructure-only

### infrastructure_rationale: This story builds the release tooling that enables the distribution outcome. The direct user-facing value (installable plugin URL) is the outcome, but the story itself is build/release infrastructure. The CoWork install experience for end users (Sara's scenario) is a downstream outcome validated by the AC, not a separate story.

---

## US-02: Automated Plugin Release via GitHub Actions

### Problem

Dan currently must remember to run four manual steps after tagging a release: bump all version files, run `check:version`, run `build:plugin`, run `gh release create`. Any one of these missed means the GitHub Release either doesn't exist or has no artifact attached. A future release rushed under time pressure is likely to have a broken or missing plugin asset.

### Elevator Pitch

**Before**: Dan tags a release, then manually runs three additional commands to build and publish the plugin. If he's tired or distracted, the release asset is missing or stale.

**After**: Dan runs `git tag v1.8.0 && git push --tags`. A GitHub Actions workflow detects the tag, runs `check:version`, builds the plugin, and attaches it to the release automatically. Dan checks the Actions run — green means the release URL is live.

**Decision enabled**: Dan can decide to trust the release pipeline rather than manually executing each step, reducing the cognitive overhead of releasing and eliminating the class of "forgot to attach the plugin" errors.

### Who

- Dan Fox, solo maintainer, releasing a new version of coach-buddy under time pressure or habit

### Solution

A GitHub Actions workflow file at `.github/workflows/release.yml` triggered on `push` to tags matching `v*`. The workflow runs `check:version`, then `build:plugin`, then `gh release create` with the built artifact.

### Domain Examples

#### 1: Happy path — tag push triggers clean release

Dan bumps to `1.8.0`, commits, and runs `git tag v1.8.0 && git push --tags`. GitHub Actions picks up the tag, runs `check:version` (passes), runs `build:plugin` (valid artifact), creates a GitHub Release at `v1.8.0` with `coach-buddy.plugin` attached. Dan receives a GitHub notification that the workflow succeeded. The release is live within 3 minutes of the tag push.

#### 2: Version mismatch fails CI before release is created

Dan pushed `v1.8.0` but forgot to update `plugin.json` (still at `1.7.0`). The GitHub Actions workflow runs `check:version`, which exits non-zero. The workflow stops before `gh release create` runs. No partial or broken release is created. Dan sees a failed Actions run, fixes the mismatch, and force-pushes the corrected tag.

#### 3: Plugin schema validation catches a bad plugin build

A recently merged skill added a malformed `SKILL.md` that causes `claude plugin validate` to fail. The tag push triggers CI. `check:version` passes. `build:plugin` fails at the validation step. No release is created. Dan sees the CI failure and investigates the specific skill file named in the error output.

### UAT Scenarios (BDD)

```gherkin
Scenario: Tag push triggers release workflow and creates release with plugin attached
  Given all version sources are aligned at 1.8.0
  And the GitHub Actions workflow is configured for v* tag pushes
  When Dan pushes the tag v1.8.0 to GitHub
  Then the release workflow starts within 60 seconds
  And check:version runs and passes
  And build:plugin runs and produces a valid artifact
  And a GitHub Release is created at v1.8.0 with coach-buddy.plugin attached

Scenario: Workflow blocks release when version check fails in CI
  Given plugin.json has not been updated to match package.json version
  When Dan pushes a version tag to GitHub
  Then the release workflow runs check:version
  And the workflow fails with a version mismatch error
  And no GitHub Release is created for that tag

Scenario: Workflow blocks release when plugin build fails
  Given a skill file has a schema error caught by claude plugin validate
  When Dan pushes a version tag to GitHub
  Then the build:plugin step fails in CI
  And the failure message identifies the specific validation error
  And no GitHub Release is created

Scenario: Failed workflow leaves no partial release
  Given the workflow failed at any step
  When Dan inspects the GitHub Releases page
  Then no draft or partial release exists for the failed tag
  And the previous successful release is unchanged
```

### Acceptance Criteria

- [ ] `.github/workflows/release.yml` exists and triggers on `push` to tags matching `v*`
- [ ] Workflow runs `check:version` as first step; failure stops workflow before any release action
- [ ] Workflow runs `build:plugin`; failure stops workflow before any release action
- [ ] Workflow creates GitHub Release with `coach-buddy.plugin` attached on success
- [ ] Workflow uses `GITHUB_TOKEN` (no additional secrets required for a public repo)
- [ ] A failed workflow leaves no partial or draft release on the GitHub Releases page

### Outcome KPIs

- **Who**: Dan Fox as solo maintainer
- **Does what**: Completes a full plugin release (build + publish) after pushing a version tag
- **By how much**: Manual release steps reduced from 4 to 1 (tag + push only)
- **Measured by**: GitHub Actions run log; GitHub Releases page showing correct asset on every `v*` tag
- **Baseline**: 4 manual steps required (US-01 baseline); human error possible at each step

### Technical Notes

- Workflow requires `gh` CLI available in the Ubuntu runner (use `gh` via `actions/gh-toolkit` or install via apt)
- `GITHUB_TOKEN` is sufficient for creating releases on a public repo — no additional token setup needed
- `claude plugin validate` requires Claude CLI available in CI — evaluate whether this step can be replaced by a lightweight JSON schema check in CI if Claude CLI is unavailable in Ubuntu runner
- Workflow should NOT run on branch pushes — only tag pushes matching `v*`
- Consider `workflow_dispatch` trigger for manual re-runs of failed releases

### Dependencies

- US-01 complete and merged (defines the release workflow and validates it manually first)
- `.github/workflows/` directory created (currently absent)
- Red Card R3 resolved: tag push vs manual dispatch trigger preference

### job_id: infrastructure-only

### infrastructure_rationale: This story automates the release workflow established in US-01. The user-facing distribution outcome (downloadable plugin URL) is already delivered by US-01. US-02 reduces maintainer friction — it is infrastructure automation, not a new user-facing capability.

---

## Outcome KPIs Summary

### Feature Objective

Enable any CoWork user to install coach-buddy without cloning the repo, and enable Dan to release a new version with confidence in under 5 minutes.

### KPI Table

| # | Who | Does What | By How Much | Baseline | Measured By | Type |
|---|-----|-----------|-------------|----------|-------------|------|
| 1 | CoWork user (Sara Okafor) | Installs coach-buddy.plugin without cloning repo | From 0 possible (no install path) to 1-step install | No install path exists | GitHub Release download count; README instructions no longer require git | Leading |
| 2 | Dan (maintainer) | Completes plugin release from tag to live URL | In < 5 minutes (Slice 1: < 5 min manually; Slice 2: ~3 min automated) | Currently: undefined / impossible | Time from `git tag` to live release URL | Leading |
| 3 | Dan (maintainer) | Releases with zero version mismatch errors | Target: 0 mismatched releases per 10 releases | Baseline: 1 known mismatch present today (1.6.0 vs 1.7.0) | `check:version` script exit code in CI | Guardrail |

### Guardrail Metrics

- `check:version` must not silently pass a mismatch — if it passes, it must genuinely be aligned
- GitHub Release must always contain `coach-buddy.plugin` as an asset (not just a tag with no asset)
