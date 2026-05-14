# Slice 02: GitHub Actions Release Automation

**Status**: Draft — depends on Slice 1 complete
**Estimated effort**: 0.5-1 day
**Stories**: US-02

---

## What this slice delivers

A GitHub Actions workflow that triggers on `v*` tag push and:

1. Runs `check:version` (gates the release; fails loudly on mismatch)
2. Runs `build:plugin` (gates the release; fails loudly on build error)
3. Creates GitHub Release with `coach-buddy.plugin` attached

After this slice: `git tag v1.8.0 && git push --tags` is the complete release action.

## Prerequisites

- Slice 1 complete and at least one manual release validated
- Red Card R3 resolved: tag push trigger confirmed (vs workflow_dispatch)
- Confirm `claude plugin validate` availability in Ubuntu runner, or define fallback validation

## Files to create

| Action | File | Change |
|--------|------|--------|
| Create | `.github/workflows/release.yml` | Full release workflow |

## Key implementation question (for DESIGN wave)

`claude plugin validate` requires the Claude CLI in the runner. Options:
1. Install Claude CLI in the runner (adds setup time, dependency on Anthropic distribution)
2. Replace with a lightweight JSON schema check in CI (simpler, no external CLI dependency)
3. Skip schema validation in CI and rely on the pre-push `build:plugin` validation

This is a DESIGN wave decision — product owner position: option 2 preferred (simpler, no external CLI dependency in CI).
