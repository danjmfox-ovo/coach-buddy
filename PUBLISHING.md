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
- [ ] `package.json` version matches `SKILL.md` frontmatter and `CHANGELOG.md` heading

## Publish

```bash
npm publish --access public
```

## After publishing

- Test live: `npx coach-buddy` in a project with `.claude/` present
- Update CHANGELOG if any last-minute fixes landed during pre-publish checks
- Tag the release: `git tag v1.7.0 && git push --tags`
