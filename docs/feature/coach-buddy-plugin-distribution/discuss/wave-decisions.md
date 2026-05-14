# Wave Decisions: coach-buddy-plugin-distribution

## DISCUSS wave — 2026-05-14

---

## Scope Assessment: PASS

2 stories, 1 bounded context (release/distribution), estimated 2 days total.
Two independent slices: Slice 1 (manual release) is the walking skeleton. Slice 2 (automation) builds on it.

---

## Missing DIVERGE Artifacts — Risk Noted

No `docs/product/jobs.yaml` exists. No DIVERGE wave artifacts present (`recommendation.md`, `job-analysis.md`).

JTBD grounded from feature brief context instead. Job statement treated as validated:

> "As the coach-buddy maintainer, I want to distribute the plugin so others (or my future self) can install it in CoWork without cloning the repo."

**Risk**: JTBD not formally validated through DISCOVER/DIVERGE waves. If the real constraint is broader (e.g., "share with a team inside a company network"), the distribution mechanism may need revisiting. Acceptable for current scope — single maintainer, public GitHub.

**Mitigation**: Captured job statement in feature-delta.md. Create `docs/product/jobs.yaml` before next DISCOVER wave.

---

## Decision 1: Distribution mechanism — GitHub Releases (not binary in git)

**Options evaluated:**

| Option | Signal | Reason not selected |
|--------|--------|---------------------|
| Commit to repo (remove from .gitignore) | Simplest immediate step | Binary in git is anti-pattern; bloats repo history; `.plugin` is a build artifact |
| GitHub Releases (attach to tag via `gh`) | Fits existing `git tag` convention; no binary in git; URL shareable | — **SELECTED** |
| GitHub Actions (auto-build on tag push) | Best long-term DX; no manual step | Additional CI complexity; walking skeleton first |

**Rationale**: GitHub Releases is the right distribution surface — it aligns with the existing publish convention (`git tag v1.7.0 && git push --tags`), keeps binaries out of git history, and produces a stable download URL. It introduces zero new infrastructure for Slice 1 (uses `gh release create` locally).

Slice 2 (CI automation) is deferred — it builds on Slice 1 and can ship independently once Slice 1 is proven.

---

## Decision 2: Walking skeleton is Slice 1 (manual release)

The manual release workflow is the walking skeleton: it proves the end-to-end distribution path (build → attach → download) without CI complexity. Slice 2 automates the same path.

**Rationale**: Walking skeleton validates architecture risk (does the release surface work?) before automation investment. A user can download and install from Slice 1 without Slice 2 ever shipping.

---

## Decision 3: Version consistency is a hard constraint

Discovered during prior wave reading: `package.json` version is `1.6.0`, `plugins/coach-buddy/.claude-plugin/plugin.json` version is `1.7.0`. This mismatch exists today.

PUBLISHING.md already has a version-alignment checklist item (`package.json` version matches `SKILL.md` frontmatter and `CHANGELOG.md` heading) — but `plugin.json` is not in that checklist.

**Decision**: The release workflow must fail fast if versions are misaligned. The build script will validate version consistency before creating a GitHub Release. This is captured as an AC in US-01.

---

## Shared Artifacts — Version Risk: HIGH

| Artifact | Source of truth | Consumers | Risk |
|----------|----------------|-----------|------|
| version | `package.json` | `plugin.json`, `SKILL.md` frontmatter, `CHANGELOG.md`, git tag, GitHub Release title | HIGH — currently misaligned |
| plugin file name | `build:plugin` script output | GitHub Release asset, download URL in README | MEDIUM |
| repository URL | `plugin.json` `.repository` | README install section, GitHub Release | LOW |

**Action required before Slice 1 ships**: Align `package.json` (1.6.0) and `plugin.json` (1.7.0) versions. The gap suggests plugin was bumped independently of the npm package — document the version strategy.

---

## Red Cards (open questions)

| # | Question | Owner | Status |
|---|----------|-------|--------|
| R1 | Is `1.7.0` the correct version for the next release, or should it be `1.6.1`? Which source wins? | Dan | **Resolved — see below** |
| R2 | Should the GitHub Release include only the `.plugin` file, or also the npm tarball? | Dan | **Resolved — see below** |
| R3 | When CI is added (Slice 2), should `git push --tags` be the trigger, or a manual workflow dispatch? | Dan | **Resolved — see below** |
| R4 | Should `check:version` run `claude plugin validate` in CI, or use a lightweight JSON schema check? | Dan | **Resolved — see below** |

---

## Resolved Questions

Resolved 2026-05-14.

### R1 — Version: `1.7.0` is correct

`plugin.json` (`1.7.0`) wins. `package.json` bumped from `1.6.0` to `1.7.0` to match. The plugin version is the user-visible release version; the npm package version must track it.

**Action taken**: `package.json` `"version"` field updated to `"1.7.0"`.

### R2 — Release assets: `.plugin` file only

The GitHub Release attaches only `coach-buddy.plugin`. No npm tarball. Rationale: the target audience (CoWork users) installs via plugin upload, not npm. The npm tarball is a separate distribution channel not in scope for this feature.

### R3 — CI trigger: `v*` tag push AND `workflow_dispatch`

The GitHub Actions release workflow (Slice 2) triggers on both:
- `push` with `tags: ['v*']` — supports the existing `git tag vX.Y.Z && git push --tags` convention.
- `workflow_dispatch` — allows a manual re-run without re-tagging (e.g., if the workflow failed mid-run).

### R4 — Version validation in CI: lightweight JSON schema check (no CLI dependency)

The `check:version` script uses Node.js built-ins to compare versions across `package.json`, `plugin.json`, `SKILL.md` frontmatter, and `CHANGELOG.md`. It does not invoke `claude plugin validate` — that CLI dependency would make CI fragile and non-deterministic. The existing `build:plugin` script already calls `claude plugin validate` locally; CI gets the lightweight check only.

---

## Wave Status: DISCUSS COMPLETE

All red cards resolved. Artifacts produced:

| Artifact | Path |
|----------|------|
| Journey visual | `discuss/journey-plugin-release-visual.md` |
| Journey YAML | `discuss/journey-plugin-release.yaml` |
| Story map | `discuss/story-map.md` |
| Shared artifacts registry | `discuss/shared-artifacts-registry.md` |
| User stories | `discuss/user-stories.md` |
| Outcome KPIs | `discuss/outcome-kpis.md` |
| Wave decisions | `discuss/wave-decisions.md` (this file) |
| Feature delta | `feature-delta.md` |

Ready for **DESIGN wave** handoff to solution-architect.
