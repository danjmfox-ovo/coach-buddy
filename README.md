# Coach Buddy

A thinking partner for Agile coaches. Helps you work through real situations — symptoms, dynamics, interventions, positioning — and discover relevant frameworks in context.

Two jobs:

1. **Thinking partner** — situation-focus by default; follow the coach's lead without introducing frameworks uninvited
2. **Growth vehicle** — framework discovery available on interest signals, grounded in the situation at hand

These are in tension. The architecture resolves it explicitly. See [ADRs](docs/product/architecture/) for the decisions.

---

## Install

### Quick install (Claude Code / Cursor)

```bash
npx coach-buddy
```

Detects your tool (Claude Code or Cursor), copies all files to the right skills directory, and prints activation instructions. Add `--global` to install at user level rather than project level. Add `--force` to overwrite an existing install.

### Claude Chat Project — dedicated coaching tool

The simplest setup. One project, always in coaching mode.

1. Create a Claude Chat Project
2. Paste [`SKILL.md`](SKILL.md) contents into **Custom instructions**
3. Upload as **Project knowledge**:
   - `references/frameworks/complexity.md`
   - `references/frameworks/work-layers.md`
   - `references/frameworks/teams.md`
   - `references/frameworks/development.md`
   - `references/frameworks/tensions.md`
   - `assets/calibration-canvas.md`

Start a conversation. The tool activates immediately.

### Claude Chat Project — team project (portable)

Use this when you want `/coach-buddy` available inside a team's existing project, alongside the team's own files and context.

1. Open the team's Claude Chat Project
2. Paste [`custom-instructions.md`](custom-instructions.md) contents into **Custom instructions** (gives the project a coaching sensibility without activating the full pipeline)
3. Upload as **Project knowledge**:
   - `SKILL.md`
   - Optionally: `references/frameworks/` files and `assets/calibration-canvas.md` (adds depth; not required)

Type `/coach-buddy` in any conversation to activate the full thinking-partner pipeline.

### Claude Code / CoWork

```bash
# Project-level
cp -r . .claude/skills/coach-buddy/

# User-level (available across all projects)
cp -r . ~/.claude/skills/coach-buddy/
```

`/coach-buddy` registers as a slash command — more reliable than the soft-activation convention used in Chat Projects.

**If your environment has a Jira, Linear, or similar MCP**: Coach Buddy can read board state directly. Frame your prompt around what you want to think about rather than asking it to analyse the data — the goal is a coaching conversation, not a ticket audit.

```markdown
/coach-buddy Sprint 14 is open in Jira. Something feels off with this team's delivery pattern — help me think through what might be going on.
```

### Cursor

```bash
# Project-level
cp -r . .cursor/skills/coach-buddy/

# User-level
cp -r . ~/.cursor/skills/coach-buddy/
```

---

## Usage

Describe your situation. The tool will reflect back what it hears, ask one calibrating question, and help you think — not think for you.

```markdown
My team are struggling with long cycle times, work carrying over into following sprints. The dominant behaviour is "soldier on under increasing pressure" rather than "slow down to speed up". Stories are large, ambiguous, and contain risk.
```

For the calibration canvas (mode, context, stakes): see [`assets/calibration-canvas.md`](assets/calibration-canvas.md).

### Bringing in team artefacts

When working in a team project, ground the conversation in what you're actually looking at:

**Screenshot** — paste a board screenshot directly into the chat. Claude reads it and treats it as context for the coaching situation, not a ticket backlog to manage.

**Text snapshot** — paste a brief description of what you're seeing:

```markdown
/coach-buddy Sprint 14 — 14 stories in progress across 3 devs. Cycle time has doubled over the last two sprints. Standup explanation: "things are complex".
```

**Persistent team context** — for ongoing work with one team, upload a `team-context.md` to Project Knowledge with current board state, team makeup, and retro notes. Update it between sessions.

You don't need clean data. A rough description of what feels off is enough to start.

---

## What's in the box

| File | Purpose |
|------|---------|
| [`SKILL.md`](SKILL.md) | Full thinking-partner pipeline — use as custom instructions (dedicated) or project knowledge (portable) |
| [`custom-instructions.md`](custom-instructions.md) | Lean always-on layer — use as custom instructions in a team project |
| [`references/frameworks/`](references/frameworks/) | Coaching-specific framework depth: complexity, work layers, teams, development, tensions |
| [`assets/calibration-canvas.md`](assets/calibration-canvas.md) | Template for capturing mode, context, and stakes at conversation open |
| [`docs/product/architecture/`](docs/product/architecture/) | Nine ADRs documenting architectural decisions |

---

## Framework coverage

**Primary lenses** (built into SKILL.md):
Cynefin (Snowden) · Four work layers (Shorrock) · Team Topologies (Skelton, Pais) · Kegan's Orders of Mind · Psychological safety (Edmondson) · Polarity thinking (Johnson)

**Secondary lenses** (available on interest signal):
Flow metrics · Schwartz · Safety-II (Hollnagel) · Beyond Budgeting · Somatic/systemic awareness (van der Kolk, Menakem) · Power/status/inclusion · Document types

---

## Sources

**Structural inspiration**

- [johnpcutler/change-lenses-and-actions](https://github.com/johnpcutler/change-lenses-and-actions) — the SKILL.md + project-knowledge pattern that this tool's architecture is built on
- [nWave-ai/nWave](https://github.com/nWave-ai/nWave) — the wave-based development methodology used to build and iterate this tool; the documented upgrade path if Coach Buddy outgrows the Cutler-pattern

**Framework authors**

The frameworks referenced in this tool are the work of their respective authors. Attribution is applied on first use — see the attribution rules in [SKILL.md](SKILL.md) and the [framework reference files](references/frameworks/).

---

## License

MIT
