# Publishing to npm

## Pre-publish checklist

- [ ] `npm info coach-buddy` — confirm name still unclaimed (names can be claimed between sessions)
- [ ] `sudo chown -R 502:20 ~/.npm` — fix cache permissions if needed
- [ ] `npm pack --dry-run` — verify the file manifest matches the `files` array in package.json
- [ ] Installer tested for all paths:
  - [x] Claude Code project-level (`.claude/` present)
  - [x] No tool context (manual instructions path)
  - [x] Overwrite guard (`--force` required)
  - [ ] Cursor project-level (`.cursor/` present)
  - [ ] Claude Code user-level (`--global` flag)
- [ ] Version sources aligned: `package.json`, `plugin.json`, `SKILL.md` frontmatter, and `CHANGELOG.md` heading — run `npm run check:version` to verify

## Publish

```bash
npm publish --access public
```

## After publishing

- Test live: `npx coach-buddy` in a project with `.claude/` present
- Update CHANGELOG if any last-minute fixes landed during pre-publish checks
- Tag the release: `git tag v1.7.0 && git push --tags`

## Plugin build (CoWork)

Build the plugin for upload to Claude CoWork or distribution via GitHub Releases.

**Before building — verify all versions agree**

```bash
npm run check:version
```

Checks `package.json`, `plugin.json`, `SKILL.md` frontmatter, and `CHANGELOG.md`. Exits non-zero and names the offending file if any source mismatches. Fix mismatches before continuing.

**How to build**

```bash
npm run build:plugin
```

**What it produces**

`coach-buddy.plugin` at the repo root — a zip file containing:
- All five skills (coach-buddy, cb-init, cb-log, cb-retro, cb-snapshot)
- Plugin manifest with metadata
- Ready for direct upload to CoWork

**Build validation**

`npm run build:plugin` runs `node scripts/validate-plugin.js` before zipping. It checks:
- `plugin.json` has all required fields: `name`, `version`, `description`, `author`, `repository`, `license`, `keywords`, `skills`
- Every `SKILL.md` has `user-invocable: true` as a **top-level** key (CoWork rejects it nested under `metadata:`)
- No angle brackets (`<`, `>`) in `description` or `argument-hint` frontmatter values (CoWork HTML-sanitises these fields — use `[placeholder]` not `<placeholder>`)

> **Note**: `claude plugin validate` only validates the manifest JSON — it does not replicate CoWork's zip validator. The only reliable gate is a real CoWork upload attempt.

**How to distribute — CoWork direct upload**

1. In Claude CoWork, go to **Settings** → **Plugins** → **Upload plugin**
2. Select `coach-buddy.plugin`
3. Click **Install**

**How to distribute — GitHub Releases (shareable link)**

1. Confirm `npm run check:version` passed and `coach-buddy.plugin` is freshly built
2. Set the version variable (must match `package.json`):
   ```bash
   VERSION=$(node -e "console.log(require('./package.json').version)")
   ```
3. Create the release and attach the artifact:
   ```bash
   gh release create "v${VERSION}" coach-buddy.plugin \
     --title "v${VERSION}" \
     --notes "See CHANGELOG.md for release notes."
   ```
4. Share the release URL: `https://github.com/danjmfox-ovo/coach-buddy/releases/tag/v${VERSION}`

CoWork users can download `coach-buddy.plugin` directly from the release page and upload it via Settings → Plugins — no git clone or Node.js required.

**Note**: `coach-buddy.plugin` is a build artifact — it is in `.gitignore` and distributed exclusively via GitHub Releases or direct upload.
