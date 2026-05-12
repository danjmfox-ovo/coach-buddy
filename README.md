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
npx skills add danjmfox-ovo/coach-buddy
```

Auto-detects your agent and sets everything up.

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

```
My team are struggling with long cycle times, work carrying over into following
sprints. The dominant behaviour is "soldier on under increasing pressure" rather
than "slow down to speed up". Stories are large, ambiguous, and contain risk.
```

For the calibration canvas (mode, context, stakes): see [`assets/calibration-canvas.md`](assets/calibration-canvas.md).

---

## What's in the box

| File | Purpose |
|------|---------|
| [`SKILL.md`](SKILL.md) | Full thinking-partner pipeline — use as custom instructions (dedicated) or project knowledge (portable) |
| [`custom-instructions.md`](custom-instructions.md) | Lean always-on layer — use as custom instructions in a team project |
| [`references/frameworks/`](references/frameworks/) | Coaching-specific framework depth: complexity, work layers, teams, development, tensions |
| [`assets/calibration-canvas.md`](assets/calibration-canvas.md) | Template for capturing mode, context, and stakes at conversation open |
| [`docs/product/architecture/`](docs/product/architecture/) | Six ADRs documenting architectural decisions |

---

## Framework coverage

**Primary lenses** (built into SKILL.md):
Cynefin (Snowden) · Four work layers (Shorrock) · Team Topologies (Skelton, Pais) · Kegan's Orders of Mind · Psychological safety (Edmondson) · Polarity thinking (Johnson)

**Secondary lenses** (available on interest signal):
Flow metrics · Schwartz · Safety-II (Hollnagel) · Beyond Budgeting · Somatic/systemic awareness (van der Kolk, Menakem) · Power/status/inclusion · Document types

---

## License

MIT
