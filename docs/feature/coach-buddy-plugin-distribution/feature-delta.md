# Feature Delta: coach-buddy-plugin-distribution

Type: [REF] — Reference sections for integration with existing documentation

---

## [REF] PUBLISHING.md — Plugin build section update

The existing "Plugin build (CoWork)" section in `PUBLISHING.md` should be updated to include:

1. **Version alignment step** (add before build):
   ```bash
   npm run check:version
   ```
   Purpose: confirms package.json, plugin.json, SKILL.md frontmatter, and CHANGELOG.md are aligned before building.

2. **Version alignment checklist item** (add to Pre-publish checklist):
   ```
   - [ ] `plugin.json` version matches `package.json` version
   ```

3. **GitHub Release step** (add to "How to distribute" section, replacing current manual upload instructions):
   ```bash
   gh release create v${VERSION} \
     --title "v${VERSION}" \
     --notes "See CHANGELOG.md for changes in this release" \
     coach-buddy.plugin
   ```
   This replaces the current "go to Settings → Plugins → Upload plugin" as the primary distribution path. Manual upload remains valid for end users installing the plugin.

4. **Post-release smoke test** (add to "After publishing"):
   ```bash
   # Verify the release asset is downloadable
   curl -I https://github.com/danjmfox-ovo/coach-buddy/releases/download/v${VERSION}/coach-buddy.plugin
   ```

---

## [REF] README.md — CoWork install section update

The current CoWork install section in README.md documents a build-from-source workflow:

```
1. Build the plugin: npm run build:plugin produces coach-buddy.plugin at the repo root
2. In CoWork, go to Settings → Plugins → Upload plugin
3. Select coach-buddy.plugin
4. Click Install
```

This should be updated to reference GitHub Releases as the primary install path:

```
1. Download coach-buddy.plugin from the latest GitHub Release:
   https://github.com/danjmfox-ovo/coach-buddy/releases/latest
2. In CoWork, go to Settings → Plugins → Upload plugin
3. Select the downloaded coach-buddy.plugin
4. Click Install
```

The build-from-source path can remain as a secondary option for contributors.

---

## [REF] .gitignore — No change required

`*.plugin` correctly remains in `.gitignore`. The plugin is a build artifact and should not be committed. Distribution via GitHub Releases is the correct pattern.

---

## [REF] package.json — New script to add

```json
"check:version": "node scripts/check-version.js"
```

A new file `scripts/check-version.js` to be created in the DESIGN wave. It compares version across:
- `package.json` (source of truth)
- `plugins/coach-buddy/.claude-plugin/plugin.json`
- `plugins/coach-buddy/skills/coach-buddy/SKILL.md` (frontmatter `version:` line)
- `CHANGELOG.md` (first `## ` heading)

---

## [REF] Version alignment — RESOLVED

`package.json` updated to `1.7.0` (matching `plugin.json`). The version mismatch is closed.

- **R1 (version)**: `1.7.0` confirmed correct. `package.json` bumped. `plugin.json` is already at `1.7.0`. No further change needed.
- **R2 (release assets)**: GitHub Release attaches `coach-buddy.plugin` only. No npm tarball.
- **R3 (CI trigger)**: `v*` tag push + `workflow_dispatch` (Slice 2).
- **R4 (validate in CI)**: Lightweight JSON schema check — no `claude plugin validate` CLI dependency in CI.

See `discuss/wave-decisions.md` § Resolved Questions for full rationale.

---

## [REF] New files to create (Slice 1)

| File | Purpose |
|------|---------|
| `scripts/check-version.js` | Version alignment validator (node built-ins only) |
| `docs/feature/coach-buddy-plugin-distribution/` | This feature's DISCUSS artifacts |

## [REF] New files to create (Slice 2)

| File | Purpose |
|------|---------|
| `.github/workflows/release.yml` | GitHub Actions workflow: build + attach plugin on tag push |
