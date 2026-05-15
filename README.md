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

### Claude Code

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

### Claude CoWork

1. Download `coach-buddy.plugin` from the [latest GitHub Release](https://github.com/danjmfox-ovo/coach-buddy/releases/latest)
2. In CoWork, go to **Settings** → **Plugins** → **Upload plugin**
3. Select the downloaded `coach-buddy.plugin`
4. Click **Install**

`/coach-buddy` and the engagement layer skills (`/cb-init`, `/cb-log`, `/cb-retro`, `/cb-snapshot`) will be available immediately in all your CoWork projects. No git clone or Node.js required.

> **Building from source**: if you have the repo cloned, run `npm run check:version && npm run build:plugin` to produce a fresh `coach-buddy.plugin` at the repo root.

### Cursor

```bash
# Project-level
cp -r . .cursor/skills/coach-buddy/

# User-level
cp -r . ~/.cursor/skills/coach-buddy/
```

---

## Engagement context layer

For ongoing engagements — coaching the same team across weeks or months — the engagement context layer gives coach-buddy persistent grounding. Without it, every conversation starts cold.

### What it is

Five companion skills that maintain a folder of structured files for each engagement:

| Skill | What it does |
|-------|-------------|
| `/cb-init` | Scaffolds a new engagement folder with all required files |
| `/cb-log` | Captures a Safety-II-informed coaching observation after a session |
| `/cb-retro` | Adds or updates retro actions in the tracker |
| `/cb-snapshot` | Writes a current board snapshot before a coaching conversation |
| `/cb-validate` | Reviews logged hypotheses and closes the loop — confirmed, disconfirmed, or deferred |

### When to use it

Use the engagement layer when you are coaching a team over time and want:
- Observations and hypotheses to accumulate across sessions (not reset each conversation)
- Retro actions tracked in the same place as coaching observations
- A current board picture available before each `/coach-buddy` conversation (snapshot now includes recent log entries)
- A periodic review of your predictions — confirmed, disconfirmed, or still open
- Context portable between Claude Code and Claude Chat (see below)

For one-off sessions or exploratory conversations, the engagement layer is not needed — just use `/coach-buddy` directly.

### Setup

**Install** the `skills/cb-*/` directories alongside the rest of coach-buddy:

```bash
# From the coach-buddy repo root, into your project:
cp -r skills/cb-init     .claude/skills/cb-init
cp -r skills/cb-log      .claude/skills/cb-log
cp -r skills/cb-retro    .claude/skills/cb-retro
cp -r skills/cb-snapshot .claude/skills/cb-snapshot
cp -r skills/cb-validate .claude/skills/cb-validate
```

**Initialise** a new engagement:

```bash
/cb-init
```

Answer the prompts (team name, slug, project management tool). An `engagements/<team-slug>/` folder is created with `CONTEXT.md`, `COACHING_LOG.md`, `RETRO_ACTIONS.md`, `HISTORY.md`, and `snapshots/`.

**Fill in** `CONTEXT.md` with what you know about the team. This is the only manual step — the other files are managed by the skills.

### Typical session flow

```bash
# After a team session — capture what you noticed
/cb-log The team ran a retro where every action was process-level. No one named the underlying dynamic.

# Tag the mode when you gave direct input rather than coaching
/cb-log The sponsor asked me directly what to do about the delivery pressure. I told them. --mode advisory

# After a retrospective — log the actions
/cb-retro --paste "<paste your retro output here>"

# Before a coaching conversation — get a current board picture (now includes recent log entries)
/cb-snapshot

# Start a coaching conversation
/coach-buddy I'm preparing for a 1:1 with the tech lead. The snapshot is showing 8 stories in WIP across 3 people.

# Every few weeks — close the loop on your predictions
/cb-validate
```

### Claude Chat project knowledge sync

The engagement files are also readable as Claude Chat project knowledge — giving the same grounding in Chat conversations that can't run skills directly.

Before a Chat session, upload:
- `engagements/<team-slug>/CONTEXT.md` — static team knowledge
- `engagements/<team-slug>/COACHING_LOG.md` (or a recent excerpt) — coaching arc
- The latest `engagements/<team-slug>/snapshots/YYYY-MM-DD-board.md` — current board state

The `/cb-snapshot` file is designed to be uploaded directly — it is structured and readable without editing.

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
| [`references/coaching-practice/`](references/coaching-practice/) | Engagement layer reference docs: COACHING_LOG format rationale, board snapshot interpretation guide |
| [`assets/calibration-canvas.md`](assets/calibration-canvas.md) | Template for capturing mode, context, and stakes at conversation open |
| [`skills/cb-init/`](skills/cb-init/) | Engagement scaffolding skill |
| [`skills/cb-log/`](skills/cb-log/) | Coaching log capture skill |
| [`skills/cb-retro/`](skills/cb-retro/) | Retro action tracking skill |
| [`skills/cb-snapshot/`](skills/cb-snapshot/) | Board snapshot skill |
| [`skills/cb-validate/`](skills/cb-validate/) | Hypothesis validation skill |
| [`plugins/coach-buddy/`](plugins/coach-buddy/) | CoWork plugin (all six skills packaged for upload) |
| [`docs/product/architecture/`](docs/product/architecture/) | Eleven ADRs documenting architectural decisions |

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
