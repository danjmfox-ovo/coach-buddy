# Slice 01: Manual Plugin Release (Walking Skeleton)

**Status**: Ready for DESIGN wave
**Estimated effort**: 0.5-1 day
**Stories**: US-01

---

## What this slice delivers

A working end-to-end plugin distribution path:

1. `npm run check:version` validates all version sources agree
2. `npm run build:plugin` (already exists) builds the artifact
3. `gh release create v${VERSION} coach-buddy.plugin` attaches the artifact to a GitHub Release
4. Any CoWork user downloads from the release URL and installs — no git, no Node.js required

## Walking skeleton confirmation

This slice covers all four backbone activities:
- Verify versions (check:version script)
- Build artifact (existing build:plugin — no new work)
- Publish release (gh release create, documented in PUBLISHING.md)
- Confirm distribution (README updated, smoke test step)

## Files to create/modify

| Action | File | Change |
|--------|------|--------|
| Create | `scripts/check-version.js` | Version alignment validator |
| Modify | `package.json` | Add `check:version` script; align version to 1.7.0 (pending R1) |
| Modify | `PUBLISHING.md` | Add version check step, gh release create command, plugin.json to checklist |
| Modify | `README.md` | Update CoWork install section to reference GitHub Releases |

## Prerequisites

- Red Card R1 resolved: confirm 1.7.0 is correct next version
- `gh` CLI available and authenticated in maintainer environment

## Not in this slice

- GitHub Actions workflow (Slice 2)
- Any automated CI
