# cb-root-layout Manual Test Script
# Run in Claude Code with coach-buddy skills installed.
# Use a real project directory — do not fabricate test data.
# Start a fresh conversation for each numbered scenario group.
# Annotate pass/fail and timestamps in the results section at the bottom.
#
# WS strategy: C (real local) — SKILL.md files are the system under test.
# Scaffold note: SKILL.md files already exist. These tests verify their content.
# No compiled stubs. DELIVER wave crafter modifies SKILL.md to satisfy each test.

---

## Pre-run setup

1. Ensure coach-buddy skills are installed: `ls .claude/skills/cb-init/` should show SKILL.md.
2. Prepare a clean project directory for root-layout tests: `mkdir -p /tmp/test-root-layout && cd /tmp/test-root-layout && mkdir -p .claude/skills`.
3. Copy skills into test directory: `cp -r ~/.claude/skills/cb-* /tmp/test-root-layout/.claude/skills/`.
4. Prepare a second directory for legacy-layout regression: `mkdir -p /tmp/test-legacy-layout && cd /tmp/test-legacy-layout && mkdir -p .claude/skills && cp -r ~/.claude/skills/cb-* /tmp/test-legacy-layout/.claude/skills/`.
5. Open Claude Code in each test directory as needed per scenario.

---

## Slice 01 — cb-init --root

### Scenario 1a: Full root-layout initialisation (WS, US-CBR-01)

**Setup**: Clean directory — no config.json, no COACHING_LOG.md, no engagements/.

**Run**: `/cb-init --root`

**Provide when prompted**:
- Team name: "Advisor Connect"
- Slug: "advisor-connect"
- PM tool: Jira
- Project key: AC
- Board ID: 42
- WIP threshold: 5 (accept default)

**Expect**:
- config.json created at project root (not in engagements/)
- COACHING_LOG.md created at project root
- CONTEXT.md created at project root
- RETRO_ACTIONS.md created at project root
- HISTORY.md created at project root
- snapshots/ directory created at project root (with .gitkeep)
- No engagements/ directory created
- Success message shows: "Engagement folder created: ./"

**Verify**: `ls -la` should show all files at root; `ls engagements/` should fail with "no such file or directory"

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 1b: Success output shows root path (US-CBR-01)

**Setup**: Immediately after 1a.

**Expect**: Output summary includes "Engagement folder created: ./"
And does NOT mention "engagements/advisor-connect/"

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 1c: Overwrite guard fires when config.json exists at root (US-CBR-01)

**Setup**: Project root already has config.json (from 1a or manually created).

**Run**: `/cb-init --root` (without --force)

**Expect**: cb-init prompts: "An engagement at this location already exists (config.json found). Overwrite it? (yes/no)"
- Answer "no" → no files modified
- Answer "yes" → files recreated (re-run setup questions)

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 1d: --force bypasses overwrite prompt in root layout (US-CBR-01)

**Setup**: Project root already has config.json.

**Run**: `/cb-init --root --force`

**Expect**:
- No "Overwrite?" prompt
- Setup questions asked fresh (team name, slug, etc.) — previous slug not assumed
- Files recreated

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 1e: COACHING_LOG.md collision warning (US-CBR-01)

**Setup**: Create COACHING_LOG.md at root manually: `touch COACHING_LOG.md`. Ensure no config.json exists.

**Run**: `/cb-init --root`

**Expect**: cb-init warns that COACHING_LOG.md already exists at this location and will not be protected by the overwrite guard (only config.json is checked). Prompts: "Proceed? (yes/no)". Does NOT silently overwrite.

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 1f: Default init without --root is unchanged (US-CBR-01)

**Setup**: Clean directory with no engagement files.

**Run**: `/cb-init` (no --root flag), slug "platform-team"

**Expect**:
- Files created at engagements/platform-team/
- No files at project root
- Success message: "Engagement folder created: engagements/platform-team/"

**Verify**: `ls engagements/platform-team/` should show all 5 files + snapshots/

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 1g: --root with path argument not supported (US-CBR-01)

**Run**: `/cb-init --root ./some-subdirectory`

**Expect**: cb-init notes that --root <path> is not supported in this version.
And suggests: "cd <path> && cb-init --root" as the workaround.
Does NOT attempt to scaffold at ./some-subdirectory.

**Pass / Fail**: ________ | **Notes**: ________

---

## Slice 02 — Downstream detection

**Pre-condition for all Slice 02 scenarios**: Run Scenario 1a to create a root-layout engagement first.

---

### Scenario 2a: cb-log resolves root layout (WS, US-CBR-02)

**Setup**: Root-layout engagement with slug "advisor-connect" and COACHING_LOG.md at project root.

**Run**: `/cb-log "Tech lead is not speaking in standups"`

**Expect**:
- No slug disambiguation prompt
- Entry prepended to COACHING_LOG.md at project root (not engagements/)
- Confirmation shows entry added to ./COACHING_LOG.md

**Verify**: `head -20 COACHING_LOG.md` shows new entry

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 2b: cb-retro resolves root layout (US-CBR-02)

**Setup**: Root-layout engagement with RETRO_ACTIONS.md at project root.

**Run**: `/cb-retro` with a sample retro action pasted

**Expect**:
- Actions written to RETRO_ACTIONS.md at project root
- No slug disambiguation prompt

**Verify**: `cat RETRO_ACTIONS.md` shows new row

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 2c: cb-snapshot resolves root layout (US-CBR-02)

**Setup**: Root-layout engagement with snapshots/ directory at project root.

**Run**: `/cb-snapshot`

**Expect**:
- Snapshot written to ./snapshots/{date}-board.md
- Confirmation output shows "./snapshots/{date}-board.md"
- No slug disambiguation prompt

**Verify**: `ls snapshots/` shows dated snapshot file

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 2d: cb-validate resolves root layout (US-CBR-02)

**Setup**: Root-layout engagement with COACHING_LOG.md at project root containing at least one entry with a hypothesis.

**Run**: `/cb-validate`

**Expect**:
- Reads COACHING_LOG.md from project root
- Hypotheses presented for validation
- No slug disambiguation prompt

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 2e: coach-buddy loads engagement context from root (US-CBR-02)

**Setup**: Root-layout engagement with CONTEXT.md and COACHING_LOG.md at project root (populated with at least one entry).

**Run**: `/coach-buddy "The team seems disengaged in planning"`

**Expect**:
- coach-buddy responds to the coaching question
- No error about missing engagement files
- Context from COACHING_LOG.md informs the response (do not expect explicit citation of the file)
- If context is used, it is used naturally without mentioning file paths

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 2f: Slug read directly from root config.json — no disambiguation (US-CBR-02, US-CBR-03)

**Setup**: Root-layout engagement. Verify no engagements/ directory exists.

**Run**: `/cb-log "Observation"` (without --slug flag)

**Expect**:
- Slug "advisor-connect" resolved from ./config.json
- No disambiguation prompt
- No attempt to glob engagements/ (directory does not exist and no error is raised about it)

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 2g: coach-buddy proceeds without error in a project with no engagement (US-CBR-02)

**Setup**: Clean directory with no config.json and no engagements/.

**Run**: `/coach-buddy "How do I approach a disengaged team?"`

**Expect**:
- coach-buddy responds to the coaching question
- No error message about missing engagement files
- No prompt to run /cb-init

**Pass / Fail**: ________ | **Notes**: ________

---

## Regression — Legacy layout (US-CBR-02)

**Pre-condition**: Use the legacy-layout test directory from pre-run setup step 4.

---

### Scenario 3a: cb-log continues to work with legacy layout (US-CBR-02)

**Setup**: Engagement at engagements/platform-team/config.json. No root-level config.json.

**Run**: `/cb-log "Planning was long this sprint"`

**Expect**:
- Entry written to engagements/platform-team/COACHING_LOG.md
- Behaviour identical to before this change

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 3b: Multiple legacy engagements still trigger disambiguation (US-CBR-03)

**Setup**: Two engagements — engagements/platform-team/ and engagements/checkout/ — both with config.json. No root-level config.json.

**Run**: `/cb-log "Something I noticed"` (no --slug flag)

**Expect**: Disambiguation prompt lists both "platform-team" and "checkout"
Behaviour identical to before this change.

**Pass / Fail**: ________ | **Notes**: ________

---

## Error paths

### Scenario 4a: cb-log guides coach when no engagement exists anywhere (US-CBR-02)

**Setup**: Clean directory with no config.json and no engagements/.

**Run**: `/cb-log "Something I noticed"`

**Expect**: Message indicating no engagement was found at ./config.json or engagements/<slug>/config.json.
Suggests running /cb-init or /cb-init --root.

**Pass / Fail**: ________ | **Notes**: ________

---

### Scenario 4b: Non-engagement config.json at root falls back to legacy (US-CBR-02)

**Setup**:
- Create config.json at root that does NOT have version or engagement.slug fields (e.g. `{"foo": "bar"}`)
- Create engagements/platform-team/config.json with valid engagement schema

**Run**: `/cb-log "Sprint retrospective went well"`

**Expect**:
- cb-log does NOT treat the root config.json as an engagement config
- Falls back to legacy layout
- Entry written to engagements/platform-team/COACHING_LOG.md

**Pass / Fail**: ________ | **Notes**: ________

---

## Results Summary

| Scenario | Pass/Fail | Notes |
|----------|-----------|-------|
| 1a — Full root init (WS) | | |
| 1b — Success output shows root path | | |
| 1c — Overwrite guard fires | | |
| 1d — --force bypasses overwrite | | |
| 1e — COACHING_LOG.md collision warning | | |
| 1f — Default init unchanged | | |
| 1g — --root with path not supported | | |
| 2a — cb-log root layout (WS) | | |
| 2b — cb-retro root layout | | |
| 2c — cb-snapshot root layout | | |
| 2d — cb-validate root layout | | |
| 2e — coach-buddy context from root | | |
| 2f — Slug from root config.json direct | | |
| 2g — coach-buddy no engagement silent | | |
| 3a — Legacy cb-log regression | | |
| 3b — Legacy disambiguation regression | | |
| 4a — No engagement error guidance | | |
| 4b — Non-engagement config.json fallback | | |

Tested by: ________________ | Date: ________________ | Version: ________
