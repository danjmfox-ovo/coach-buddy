# Evolution: coach-buddy-plugin-distribution

**Date**: 2026-05-20
**Feature**: coach-buddy-plugin-distribution
**Delivery completed**: 2026-05-14
**Wave gate**: PASS (all 5 steps, 25 execution events — all EXECUTED or SKIPPED with NOT_APPLICABLE justification)

---

## Feature Summary

Established a repeatable, automated distribution pipeline for the coach-buddy Claude Code plugin (`coach-buddy.plugin`), enabling the plugin to be shared via GitHub Releases without requiring users to clone the repository and build from source.

Two slices delivered:

- **Slice 1 — Manual release workflow** (US-01, walking skeleton): version alignment validator (`scripts/check-version.js`), `check:version` npm script, updated `PUBLISHING.md` with GitHub Releases procedure and pre-build version check, updated `README.md` CoWork install section pointing to the releases download URL
- **Slice 2 — CI automation** (US-02): `.github/workflows/release.yml` GitHub Actions workflow triggering on `v*` tag push and `workflow_dispatch`, running `check:version` and `build:plugin` then creating a GitHub Release with `coach-buddy.plugin` attached atomically on success

---

## Business Context

**Job**: "As the coach-buddy maintainer, I want to distribute the plugin so others (or my future self) can install it in CoWork without cloning the repo."

**Pain addressed**: The only install path was clone-and-build — requiring Node.js, pnpm, and familiarity with the repo structure. This made sharing the plugin with other CoWork users (or installing on a different machine) impractical.

**Version drift discovered**: During DISCUSS wave, a pre-existing version mismatch was found — `package.json` was at `1.6.0`, `plugin.json` at `1.7.0`. The `check:version` script was designed to catch and block this class of drift going forward. The mismatch was resolved before Slice 1 shipped.

**Scope**: 5 steps across 2 phases; 1 new script, 1 new workflow file, 2 documentation updates, 1 test file. Delivered in approximately 2 days.

---

## Key Decisions

### DISCUSS wave
- **Decision 1**: Distribution via GitHub Releases (not binary in git). Rejected: committing `.plugin` to git (binary in git is anti-pattern; bloats repo history); GitHub Actions as primary path (additional CI complexity; walking skeleton first)
- **Decision 2**: Walking skeleton is Slice 1 (manual release) — proves end-to-end distribution path before automation investment
- **Decision 3**: Version consistency is a hard constraint — release workflow fails fast on misalignment; `plugin.json` is the source of truth for the user-visible version; `package.json` must track it

**Resolved questions**:
- R1: `1.7.0` is correct (`plugin.json` wins); `package.json` bumped to match
- R2: Release assets = `.plugin` file only; no npm tarball
- R3: CI triggers on both `v*` tag push AND `workflow_dispatch` (manual re-run support)
- R4: Lightweight JSON schema check (Node.js built-ins) in CI — `claude plugin validate` CLI not available in CI environment

---

## Steps Completed

From execution-log.json (schema_version 3.0):

| Step | Phase | Status | Notes |
|------|-------|--------|-------|
| 01-01 | PREPARE | EXECUTED/PASS | |
| 01-01 | RED_ACCEPTANCE | EXECUTED/PASS | |
| 01-01 | RED_UNIT | SKIPPED/NOT_APPLICABLE | Acceptance tests call `checkVersions()` as pure function directly — no separate unit test layer |
| 01-01 | GREEN | EXECUTED/PASS | |
| 01-01 | COMMIT | EXECUTED/PASS | |
| 01-02 | PREPARE | EXECUTED/PASS | |
| 01-02 | RED_ACCEPTANCE | SKIPPED/NOT_APPLICABLE | package.json key verified by running npm run check:version in step 01-01 |
| 01-02 | RED_UNIT | SKIPPED/NOT_APPLICABLE | One-line package.json addition |
| 01-02 | GREEN | EXECUTED/PASS | |
| 01-02 | COMMIT | EXECUTED/PASS | |
| 01-03 | PREPARE | SKIPPED/NOT_APPLICABLE | Documentation-only change |
| 01-03 | RED_ACCEPTANCE | SKIPPED/NOT_APPLICABLE | Documentation-only change |
| 01-03 | RED_UNIT | SKIPPED/NOT_APPLICABLE | Documentation-only change |
| 01-03 | GREEN | EXECUTED/PASS | |
| 01-03 | COMMIT | EXECUTED/PASS | |
| 01-04 | PREPARE | SKIPPED/NOT_APPLICABLE | Documentation-only change |
| 01-04 | RED_ACCEPTANCE | SKIPPED/NOT_APPLICABLE | Documentation-only change |
| 01-04 | RED_UNIT | SKIPPED/NOT_APPLICABLE | Documentation-only change |
| 01-04 | GREEN | EXECUTED/PASS | |
| 01-04 | COMMIT | EXECUTED/PASS | |
| 02-01 | PREPARE | SKIPPED/NOT_APPLICABLE | YAML workflow file with no testable logic — validated by CI run on tag push |
| 02-01 | RED_ACCEPTANCE | SKIPPED/NOT_APPLICABLE | YAML workflow file with no testable logic |
| 02-01 | RED_UNIT | SKIPPED/NOT_APPLICABLE | YAML workflow file with no testable logic |
| 02-01 | GREEN | EXECUTED/PASS | |
| 02-01 | COMMIT | EXECUTED/PASS | |

All GREEN and COMMIT phases executed and passed. SKIPPED phases carry documented NOT_APPLICABLE justifications.

---

## Test Coverage

`tests/unit/check-version.test.js` — functional test suite for `scripts/check-version.js`, calling `checkVersions()` as a pure function. Covers: all sources aligned (exit 0), mandatory source mismatch (exit non-zero + offending filename), SKILL.md missing version field (warn only, exit 0), missing CHANGELOG.md heading (exit non-zero).

Acceptance tests for documentation steps (01-03, 01-04) and the GitHub Actions workflow (02-01) are not applicable — these are verified by manual inspection and CI execution on tag push respectively.

---

## Issues Encountered

1. **`claude plugin validate` unavailable in CI**: The existing `build:plugin` npm script calls `claude plugin validate`, which requires the Claude CLI installed locally. This CLI is not present in GitHub Actions runners. Resolution: the release workflow uses a lightweight inline JSON schema check (`node -e`) as a separate step rather than invoking `build:plugin` directly for the validation portion. Documented as an implementation note in the roadmap and the workflow.

2. **Pre-existing version mismatch** (`package.json` 1.6.0 vs `plugin.json` 1.7.0): Discovered during DISCUSS wave analysis. Resolved by bumping `package.json` to `1.7.0` before Slice 1 shipped. The `check:version` script was designed specifically to prevent this class of drift recurring.

3. **`docs/product/jobs.yaml` absent at DISCUSS time**: The project did not yet have a jobs.yaml file when this feature was initiated. JTBD was grounded from the feature brief context instead. Risk noted: if the real constraint is broader (e.g., sharing within a company network), the distribution mechanism may need revisiting. Mitigation: job statement captured in feature-delta.md; creating `docs/product/jobs.yaml` before the next DISCOVER wave is a noted post-delivery task.

---

## Lessons Learned

1. **Walking skeleton for infrastructure features**: Slice 1 (manual release) as the walking skeleton proved the full distribution path before automation was invested. A user could install from Slice 1 without Slice 2 ever shipping. This is the correct sequencing for infrastructure features — validate the path first, automate second.

2. **Version drift as a feature trigger**: The pre-existing version mismatch between `package.json` and `plugin.json` is a signal that the project had no enforcement mechanism for version consistency. The `check:version` script addresses this gap, but the mismatch also indicates that manual processes around releases had quietly drifted. Worth scheduling a post-release audit of any other consistency invariants (e.g., CHANGELOG discipline, tag conventions).

3. **CI environment constraints require explicit scoping**: The `claude plugin validate` issue illustrates that CI environment capabilities should be explicitly inventoried at DESIGN time for any workflow that depends on local tooling. The lightweight JSON schema check is the correct fallback, but it was discovered at implementation time rather than design time.

4. **Documentation steps in TDD**: Steps 01-03 and 01-04 are documentation-only changes. The correct DES handling (SKIPPED/NOT_APPLICABLE for RED phases, EXECUTED/PASS for GREEN+COMMIT) is demonstrated here as the established pattern for documentation work within a TDD delivery workflow.

---

## Files Modified

| File | Change |
|------|--------|
| `scripts/check-version.js` | New — version alignment validator, ESM, Node.js built-ins only |
| `tests/unit/check-version.test.js` | New — functional tests for `checkVersions()` |
| `package.json` | `check:version` script added; version bumped from 1.6.0 to 1.7.0 |
| `PUBLISHING.md` | GitHub Releases distribution procedure added; `npm run check:version` pre-build step; `plugin.json` in version-alignment checklist |
| `README.md` | CoWork install section updated — GitHub Releases download URL as primary path |
| `.github/workflows/release.yml` | New — GitHub Actions release workflow: `v*` tag push + `workflow_dispatch` triggers; `check:version` gate; `build:plugin`; release creation with `softprops/action-gh-release@v2` |

---

## References

- User stories: `docs/feature/coach-buddy-plugin-distribution/discuss/user-stories.md`
- Journey YAML: `docs/ux/coach-buddy-plugin-distribution/journey-plugin-release.yaml`
- Journey visual: `docs/ux/coach-buddy-plugin-distribution/journey-plugin-release-visual.md`
- Feature artifacts: `docs/feature/coach-buddy-plugin-distribution/`
- GitHub Releases URL: https://github.com/danjmfox-ovo/coach-buddy/releases/latest
