# Story Map: coach-buddy-plugin-distribution

## User: Dan Fox — coach-buddy maintainer (solo, familiar with git tag convention)
## Goal: Distribute coach-buddy.plugin via GitHub Releases so any CoWork user can install without cloning the repo

---

## Backbone

| Verify versions | Build artifact | Publish release | Confirm distribution | Automate pipeline |
|-----------------|----------------|-----------------|----------------------|-------------------|
| Check all version sources agree | Run build:plugin | Create GitHub Release with asset attached | Verify download URL resolves | GitHub Action triggers on tag push |
| Update misaligned sources | Validate plugin schema | Update README with download URL | CoWork install confirmed from URL | Build + attach happens without manual step |
| Update PUBLISHING.md checklist | | Update PUBLISHING.md after-publish section | | Version check runs in CI |

---

### Walking Skeleton

End-to-end flow: version checked → plugin built → GitHub Release created with asset → download URL verified

**Minimum tasks from each activity:**
1. `check:version` script reports pass/fail with specific file names
2. `npm run build:plugin` (already exists — no new work)
3. `gh release create` command with plugin attached, documented in PUBLISHING.md
4. Smoke-test download via `curl` + `unzip -l`

This is Slice 1 (US-01). It proves the full distribution path. No CI required.

---

### Slice 1: Working distribution path (Walking Skeleton)

**Target outcome**: Dan can publish a release and share a download URL with any CoWork user. The link works. The install works.

**KPI targeted**: Time from "version bumped" to "shareable download URL" < 5 minutes (currently undefined/impossible — no release mechanism exists)

**Stories:**
- US-01: Manual plugin release workflow

**Tasks included:**
- `check:version` npm script
- PUBLISHING.md updated with `gh release create` step
- README CoWork section updated with release download link pattern

**Priority rationale**: This is the walking skeleton — it validates the entire distribution path. Unblocks all downstream "share with someone" use cases. No CI, no new services, no complexity. Risks validated: GitHub Releases works, `gh` CLI is available, download URL structure is correct.

---

### Slice 2: Automated release on tag push

**Target outcome**: Dan pushes a tag and the plugin is automatically built and attached to the release. No manual build step.

**KPI targeted**: Manual steps in release flow reduced from 4 to 1 (git tag + push only)

**Stories:**
- US-02: GitHub Actions release automation

**Tasks included:**
- `.github/workflows/release.yml` — triggered on `v*` tag push
- `check:version` run as CI step (blocks release if misaligned)
- Plugin built in CI, attached to release automatically

**Priority rationale**: Slice 2 depends on Slice 1 (the workflow being understood before automating it). It eliminates the manual `npm run build:plugin` + `gh release create` steps, reducing friction for future releases. Medium urgency — Slice 1 alone is sufficient for sharing. Scheduled after Slice 1 is validated.

**Dependencies**: US-01 complete and proven.

---

## Priority Rationale

| Priority | Slice | Outcome | Rationale |
|----------|-------|---------|-----------|
| 1 | Walking Skeleton (Slice 1) | Plugin downloadable by anyone | Validates distribution path. Highest risk reduction. Zero new infrastructure. |
| 2 | Release Automation (Slice 2) | Release created on tag push | Reduces maintainer friction. Depends on Slice 1 being understood. |

**Not in scope:**
- Committing `*.plugin` binary to git (anti-pattern: build artifacts in version control)
- Publishing `.plugin` to npm (wrong distribution channel for a binary artifact)
- Automated versioning (out of scope — manual version bumping is the current convention)
