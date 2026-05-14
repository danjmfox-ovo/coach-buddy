# Shared Artifacts Registry: coach-buddy-plugin-distribution

---

## VERSION

- **Source of truth**: `package.json` `.version` field
- **Owner**: coach-buddy-plugin-distribution feature
- **Consumers**:
  - `plugins/coach-buddy/.claude-plugin/plugin.json` `.version`
  - `plugins/coach-buddy/skills/coach-buddy/SKILL.md` frontmatter `version:`
  - `CHANGELOG.md` top-most heading
  - Git tag name (`v${VERSION}`)
  - GitHub Release title
  - GitHub Release asset download URL path segment
- **Integration risk**: HIGH — currently misaligned (`package.json` = 1.6.0, `plugin.json` = 1.7.0)
- **Validation**: `npm run check:version` script (to be implemented in US-01) reads all four sources and exits non-zero on mismatch

---

## PLUGIN_FILE

- **Source of truth**: `npm run build:plugin` output → `./coach-buddy.plugin`
- **Owner**: build script in `package.json`
- **Consumers**:
  - `gh release create` attachment argument
  - GitHub Release assets list
  - README CoWork install section (download URL pattern)
- **Integration risk**: MEDIUM — file path hardcoded in build script; if script output changes, downstream consumers break
- **Validation**: `ls -la coach-buddy.plugin` after build; `claude plugin validate` inside build script

---

## RELEASE_URL

- **Source of truth**: GitHub Releases API response (constructed: `https://github.com/danjmfox-ovo/coach-buddy/releases/tag/v${VERSION}`)
- **Owner**: GitHub (external)
- **Consumers**:
  - README CoWork install section
  - PUBLISHING.md after-publish checklist
- **Integration risk**: LOW — URL is deterministic from repo and version
- **Validation**: `gh release view v${VERSION}` confirms release exists

---

## ASSET_DOWNLOAD_URL

- **Source of truth**: `https://github.com/danjmfox-ovo/coach-buddy/releases/download/v${VERSION}/coach-buddy.plugin`
- **Owner**: GitHub (external)
- **Consumers**:
  - README CoWork install section (direct link)
  - PUBLISHING.md post-publish smoke test
- **Integration risk**: MEDIUM — if plugin file is renamed, URL breaks
- **Validation**: `curl -I <URL>` returns 200/302 (not 404)

---

## Integration Risk Summary

| Risk level | Artifact | Action |
|------------|----------|--------|
| HIGH | VERSION | Implement `check:version` script as first step; add `plugin.json` to PUBLISHING.md checklist |
| MEDIUM | PLUGIN_FILE | Keep `build:plugin` script output name stable; document in PUBLISHING.md |
| MEDIUM | ASSET_DOWNLOAD_URL | Keep plugin file name as `coach-buddy.plugin` (matches version-independent pattern) |
| LOW | RELEASE_URL | No action needed |
