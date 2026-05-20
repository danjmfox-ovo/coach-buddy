# Journey: Plugin Release Visual

Feature: coach-buddy-plugin-distribution
Persona: Dan Fox — coach-buddy maintainer
Goal: Publish a GitHub Release with coach-buddy.plugin attached, so anyone can download it without cloning the repo

---

## Emotional Arc

```
Start: Confident (familiar tag ritual, nothing new)
  |
  v
Middle: Alert (version consistency check — must not ship a misaligned build)
  |
  v
End: Satisfied (release URL in hand, shareable, README updated)
```

---

## Happy Path Flow

```
[1. Pre-release checks]     [2. Build plugin]          [3. Create GitHub Release]   [4. Verify & share]
        |                          |                              |                         |
        v                          v                              v                         v
npm run check:version      npm run build:plugin         gh release create            Download URL
versions aligned?          coach-buddy.plugin           v${VERSION}                  confirmed working
package.json               produced at root             --notes "..."
plugin.json                                             --attach coach-buddy.plugin
SKILL.md frontmatter
        |                          |                              |                         |
Feels: Confident           Feels: Methodical             Feels: Purposeful          Feels: Satisfied
```

---

## Step 1: Pre-release version check

```
+-- Step 1: Version Alignment Check -----------------------------------------+
|                                                                              |
|  $ npm run check:version                                                     |
|                                                                              |
|  Checking version consistency...                                             |
|    package.json          1.7.0   OK                                          |
|    plugin.json           1.7.0   OK                                          |
|    SKILL.md frontmatter  1.7.0   OK                                          |
|    CHANGELOG.md heading  1.7.0   OK                                          |
|                                                                              |
|  All versions consistent. Ready to release v1.7.0.                          |
|                                                                              |
+-- ${VERSION} = 1.7.0 (source: package.json) --------------------------------+
```

**Emotional state:** Confident — the check passes without drama.
**Failure mode:** One source misaligned → script exits non-zero with specific message identifying the offending file.

---

## Step 2: Build plugin

```
+-- Step 2: Build Plugin -----------------------------------------------------+
|                                                                              |
|  $ npm run build:plugin                                                      |
|                                                                              |
|  Building coach-buddy plugin...                                              |
|    Packaging 5 skills from plugins/coach-buddy/                              |
|    Validating plugin.json schema...                                          |
|    Running: claude plugin validate                                           |
|                                                                              |
|  coach-buddy.plugin ready (${FILE_SIZE_KB}kb)                                |
|                                                                              |
+-- artifact: ./coach-buddy.plugin -------------------------------------------+
```

**Emotional state:** Methodical — familiar step, already in PUBLISHING.md workflow.
**Failure mode:** `claude plugin validate` exits non-zero → build script surfaces error, stops.

---

## Step 3: Create GitHub Release

```
+-- Step 3: GitHub Release ---------------------------------------------------+
|                                                                              |
|  $ gh release create v${VERSION}                                             |
|      --title "v${VERSION}"                                                   |
|      --notes-file RELEASE_NOTES.md                                           |
|      coach-buddy.plugin                                                      |
|                                                                              |
|  Creating release v1.7.0...                                                  |
|  Uploading coach-buddy.plugin...                                             |
|                                                                              |
|  Release created:                                                            |
|  https://github.com/danjmfox-ovo/coach-buddy/releases/tag/v${VERSION}       |
|                                                                              |
|  Asset download URL:                                                         |
|  https://github.com/danjmfox-ovo/coach-buddy/releases/download/             |
|    v${VERSION}/coach-buddy.plugin                                            |
|                                                                              |
+-- ${RELEASE_URL} = https://github.com/.../releases/tag/v${VERSION} ---------+
```

**Emotional state:** Purposeful — the tag and release are created in one command.
**Failure mode:** `gh` not authenticated → clear error with `gh auth login` suggestion.
**Failure mode:** Tag already exists → `gh release create --target main` or `git tag --delete` guidance.

---

## Step 4: Verify and share

```
+-- Step 4: Verify Download --------------------------------------------------+
|                                                                              |
|  $ curl -L -o /tmp/test.plugin                                               |
|    https://github.com/.../releases/download/v${VERSION}/coach-buddy.plugin  |
|  $ unzip -l /tmp/test.plugin | head -5                                       |
|                                                                              |
|  Archive:  /tmp/test.plugin                                                  |
|    Length    Name                                                             |
|    ------    ----                                                             |
|       ...    skills/coach-buddy/SKILL.md                                     |
|       ...    .claude-plugin/plugin.json                                      |
|                                                                              |
|  Download verified. Update README with install URL.                          |
|                                                                              |
+-----------------------------------------------------------------------------+
```

**Emotional state:** Satisfied — the artifact is real, downloadable, and correct.

---

## Error Path: Version mismatch at step 1

```
+-- Version Check FAILED -----------------------------------------------------+
|                                                                              |
|  $ npm run check:version                                                     |
|                                                                              |
|  Checking version consistency...                                             |
|    package.json          1.6.0   OK                                          |
|    plugin.json           1.7.0   MISMATCH  <-- conflicts with package.json  |
|    SKILL.md frontmatter  1.7.0   MISMATCH                                    |
|    CHANGELOG.md heading  (missing entry for 1.7.0)  WARNING                  |
|                                                                              |
|  Version mismatch detected. Fix before releasing.                           |
|  Run: npm version patch  (or minor/major) to align all sources.             |
|                                                                              |
+-----------------------------------------------------------------------------+
```

**Recovery:** User resolves which version is correct (Red Card R1), updates the misaligned sources, re-runs check.

---

## Integration Checkpoints

| Between steps | What must be true |
|--------------|-------------------|
| 1 → 2 | All four version sources agree. Script exits 0. |
| 2 → 3 | `coach-buddy.plugin` exists at repo root. `claude plugin validate` passed. |
| 3 → 4 | GitHub Release exists at expected URL. Asset is attached (not just a tag). |
| 4 → done | Download URL resolves. Zip contains `skills/` and `.claude-plugin/plugin.json`. |
