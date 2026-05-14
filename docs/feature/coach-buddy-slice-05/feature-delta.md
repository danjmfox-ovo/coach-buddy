# Feature Delta — coach-buddy-slice-05: Engagement Context Layer
# Waves: DISCUSS (2026-05-14) | DESIGN (2026-05-14) | DELIVER (2026-05-14)

---

## Wave: DISCUSS / [REF] Persona ID

**agile-coach** — practitioner coaching one or more teams over weeks or months, working across Claude Code/CoWork, Claude Chat Projects, or both. Distinguishing characteristic for this slice: they run *ongoing* engagements where context accumulates, not one-off coaching sessions.

---

## Wave: DISCUSS / [REF] JTBD One-Liner

**When I'm coaching a team over time, I want persistent, structured grounding for every conversation, so coaching builds on what came before rather than starting cold.**

---

## Wave: DISCUSS / [REF] Locked Decisions

| # | Decision | Verdict | Rationale |
|---|----------|---------|-----------|
| D1 | Feature type | Cross-cutting | Touches file scaffolding (new), skill definitions (new), docs (update), custom-instructions (update), README (update) |
| D2 | Walking skeleton | Yes — slice 05a | init + folder structure proves the architectural layer (file scaffold → skill → persistent file) end-to-end before logging or snapshotting |
| D3 | UX research depth | Lightweight | Journey is well-understood from reference implementation; happy path documented in brief |
| D4 | JTBD included | Yes | Four new jobs (J6-J9) validated from reference implementation and brief |
| D5 | Tool-agnostic board-snapshot | Yes — config block at top of skill | Jira JQL is reference implementation; skill must make the tool-specific seam explicit so other tools can be substituted |
| D6 | No reference-engagement content | Yes — hard constraint | Nothing from the reference engagement (team names, org, tool IDs, coaching log entries) may appear in any generalised file |
| D7 | references/coaching-practice/ directory | Yes | COACHING_LOG.md format rationale and board-snapshot interpretation guide belong in references alongside the existing frameworks/ directory |
| D8 | ADR for engagement context layer pattern | Yes — ADR-010 | This is an architectural extension to the Cutler-pattern; the pattern decision has lasting consequences and belongs in the ADR record |
| D9 | Slice order | 05a → 05b → 05c | Scaffolding must exist before logging or snapshotting; log before snapshot (coaching log is more primary than board data) |

---

## Wave: DISCUSS / [REF] User Stories

### Story S1 — Engagement initialisation (J9)

**As** an agile coach starting a new engagement,
**I want to** run `/cb-init` and answer a few prompts about the team and tool config,
**so that** I have a complete, ready-to-use engagement folder structure from day one without designing it from scratch.

#### Elevator Pitch
Before: Every new engagement starts with an improvised folder structure and blank files. The coach either copies from a previous engagement or builds from nothing.
After: run `/cb-init` → answers 3-4 prompts → `engagements/<team-slug>/` is created with CONTEXT.md, COACHING_LOG.md, RETRO_ACTIONS.md, HISTORY.md, each with correct headers and placeholder sections.
Decision enabled: The coach can start capturing context immediately. The structure is consistent across every engagement.

#### Acceptance Criteria
- AC1.1: `/cb-init` prompts for: team display name, team slug (path-safe, kebab-case), project management tool type (Jira / Linear / other / none), and tool-specific project key or ID (skipped if "none").
- AC1.2: Creates `engagements/<team-slug>/` with four files (CONTEXT.md, COACHING_LOG.md, RETRO_ACTIONS.md, HISTORY.md) and a `snapshots/` subdirectory.
- AC1.3: CONTEXT.md has labelled placeholder sections: Team Purpose, Team Structure, Ways of Working, Ceremonies, Workflow, Boards & Comms, Repos, Stakeholders, Inherited Commitments & Constraints, Product & Roadmap Context. Each section has a one-line prompt, not filler content.
- AC1.4: COACHING_LOG.md has a header block, a format reference (field names only, no example entries), and an empty entry area.
- AC1.5: RETRO_ACTIONS.md has a header block and an empty table with columns: #, Action, Owner, Raised, Status, Notes.
- AC1.6: HISTORY.md has a header block with instructions for recording structural changes over time.
- AC1.7: No team names, org names, tool IDs, or coaching log entries from any reference engagement appear anywhere in the skill code or file templates.
- AC1.8: Re-running `/cb-init` on an existing slug warns the user and requires explicit confirmation before overwriting.
- AC1.9: A `config.json` (or equivalent) is written to `engagements/<team-slug>/` with the tool type and project key, so other skills (board-snapshot) can read it without prompting again.

---

### Story S2 — Coaching log capture (J7)

**As** an agile coach who has just observed something worth tracking,
**I want to** run `/cb-log` with a description of what I saw,
**so that** the observation is captured in a structured Safety-II format that I can build hypotheses and interventions on top of over time.

#### Elevator Pitch
Before: The coach writes free-form notes or doesn't write anything. Observations are lost or decontextualised. No connection between what was seen, what was hypothesised, and what was tried.
After: run `/coach-log <description>` → new entry prepended to COACHING_LOG.md with fields: Observed (Work-as-Done), Context, Pattern/Signal (tentative), Hypothesis (If/Then), Intervention, Follow-up.
Decision enabled: The coach can see the coaching arc across sessions. Hypotheses accumulate. Interventions can be cross-referenced.

#### Acceptance Criteria
- AC2.1: `/coach-log <description>` creates a new entry prepended (most-recent-first) to `engagements/<team-slug>/COACHING_LOG.md`.
- AC2.2: Entry has six fields: **Observed** (what happened, Work-as-Done framing), **Context** (ceremony/moment), **Pattern/Signal** (tentative label), **Hypothesis** (testable If/Then), **Intervention** (named, or "none yet"), **Follow-up** (what to watch).
- AC2.3: Quick capture is supported — the coach can provide only an observation and context; remaining fields are scaffolded as "(to fill)" rather than requiring complete input.
- AC2.4: `/coach-log --update <entry-id> <field> <value>` updates a specific field on an existing entry without replacing the whole entry.
- AC2.5: Entry IDs are generated (e.g. date-stamped sequential number) and stable — used for updates and cross-references.
- AC2.6: The skill reads the engagement path from `engagements/<team-slug>/config.json`; no hardcoded paths.

---

### Story S3 — Retro action tracking (J7)

**As** an agile coach managing retrospective follow-through,
**I want to** add and update actions in a shared tracker,
**so that** retro commitments are visible alongside coaching observations in the same engagement folder.

#### Elevator Pitch
Before: Retro actions live in a separate doc or in the retro tool. No connection to coaching observations. Status updates happen manually in a different place.
After: run `/retro-action <description>` → new row added to RETRO_ACTIONS.md; `/retro-action --update <id> status done` → row updated; `/retro-action --paste "<raw retro output>"` → all actions extracted, ambiguous items flagged.
Decision enabled: The coach can see open retro commitments alongside coaching observations. Patterns across retros become visible.

#### Acceptance Criteria
- AC3.1: `/retro-action <description>` adds a new row to RETRO_ACTIONS.md with a generated ID, the description, and today's date in the Raised column.
- AC3.2: `/retro-action --update <id> <field> <value>` updates status, owner, or notes on an existing action by ID.
- AC3.3: `/retro-action --paste "<raw text>"` extracts all actions from a paste of retro output. Each extracted action is listed for confirmation before being added. Items that are ambiguous (not clearly an action) are flagged with a ⚠ marker.
- AC3.4: Table columns: #, Action, Owner, Raised, Status, Notes. Status values: open / in-progress / done / dropped.
- AC3.5: The skill reads the engagement path from `engagements/<team-slug>/config.json`.

---

### Story S4 — Board snapshot (J8)

**As** an agile coach preparing for a coaching conversation or session,
**I want to** run `/cb-snapshot` to get a current, structured picture of the team's work state,
**so that** I can reason from Work-as-Done rather than Work-as-Imagined without manually querying the project management tool.

#### Elevator Pitch
Before: The coach either queries Jira directly (context switch, data doesn't persist in coaching context), looks at a screenshot, or skips the data entirely.
After: run `/cb-snapshot` → dated file written at `engagements/<team-slug>/snapshots/YYYY-MM-DD-board.md`; four sections (WIP, Progress, Runway, Waiting); age-flags on WIP items beyond threshold; two-sentence risk read printed in chat.
Decision enabled: The coach arrives at the `/coach-buddy` conversation with a current Work-as-Done picture. The snapshot file can be uploaded to a Claude Chat Project as project knowledge.

#### Acceptance Criteria
- AC4.1: `/cb-snapshot` writes a file at `engagements/<team-slug>/snapshots/YYYY-MM-DD-board.md`.
- AC4.2: File has four sections: **WIP** (in progress now), **Progress** (completed in the last 14 days), **Runway** (ready/refinement), **Waiting** (backlog).
- AC4.3: Each section shows the work item hierarchy relevant to the tool (e.g. Initiative → Epic → Story for Jira; or equivalent two-level hierarchy for other tools).
- AC4.4: Items in WIP that have been in progress beyond a configurable threshold (default: 5 business days) are flagged with an age indicator.
- AC4.5: The tool-specific query logic is in a clearly labelled `## Tool Config` block at the top of the skill file. The Jira JQL implementation is provided there as a reference. A comment makes explicit where to substitute other tool queries.
- AC4.6: After writing the file, the skill prints a two-sentence risk read in the conversation (not in the file).
- AC4.7: The skill reads engagement path and tool config from `engagements/<team-slug>/config.json`. No hardcoded project keys, team names, or query strings.
- AC4.8: If tool type is "none", the skill prompts the coach to paste board state manually and structures it into the same four-section format.

---

### Story S5 — Documentation updates (J6)

**As** a coach installing Coach Buddy into a team project,
**I want** the README and `custom-instructions.md` to describe the engagement context layer,
**so that** I understand how to set it up and how the Chat project knowledge sync pattern works.

#### Elevator Pitch
Before: The README describes the two-layer install and team-context.md pattern but nothing about persistent engagement folders or the skills that manage them.
After: README has a new "Engagement context layer" section; `custom-instructions.md` mentions that `/cb-init` sets up persistent engagement context.
Decision enabled: A first-time installer understands the full capability and can set up both the thinking-partner layer and the persistent engagement layer in one session.

#### Acceptance Criteria
- AC5.1: README has a new `## Engagement context layer` section explaining: what it is, when to use it (ongoing vs one-off engagements), how to init, how the snapshot file bridges Claude Code and Claude Chat.
- AC5.2: `custom-instructions.md` is updated to mention that `/cb-init` sets up an engagement context folder if the engagement skills are installed.
- AC5.3: No reference engagement content (team names, org, coaching log entries, board data) appears in any new or updated file.
- AC5.4: The README section explains the Chat project knowledge sync pattern: same files can be uploaded to Chat as project knowledge; snapshot is the bridge between live skills and static Chat context.

---

### Story S6 — Coaching practice reference docs (J7)

**As** a coach reading or updating a COACHING_LOG.md entry,
**I want** a reference document explaining why the Safety-II format is structured the way it is,
**so that** I can write better observations and understand how to interpret the log over time.

#### Elevator Pitch
Before: The COACHING_LOG.md format exists but its rationale is implicit. A coach new to Safety-II thinking may fill in fields without understanding why the structure matters.
After: `references/coaching-practice/coaching-log-format.md` explains the Safety-II framing (Work-as-Done vs Work-as-Imagined, testable hypotheses, named interventions); `references/coaching-practice/board-snapshot-guide.md` explains how to read and use a snapshot in a coaching conversation.
Decision enabled: The coach understands why the structure exists and can interpret the log as a coaching arc, not just a list of notes.

#### Acceptance Criteria
- AC6.1: `references/coaching-practice/coaching-log-format.md` exists with: Safety-II orientation (why Work-as-Done framing matters), rationale for each field (Observed / Context / Pattern / Hypothesis / Intervention / Follow-up), guidance on quick-capture vs full entries.
- AC6.2: `references/coaching-practice/board-snapshot-guide.md` exists with: how to read the four sections (WIP/Progress/Runway/Waiting), how to use age-flags as coaching signals, how to frame board data as Work-as-Done evidence rather than a management report.
- AC6.3: Both files follow the References style of the existing `references/frameworks/` files: factual, concise, no AI-generated filler.

---

## Wave: DISCUSS / [REF] Definition of Done

- [ ] All ACs pass manual testing by the coach (the acceptance environment is a real coaching session or simulation)
- [ ] No hardcoded team names, org names, tool IDs, or reference engagement content in any file
- [ ] Skills are tool-agnostic in design; Jira JQL is the reference implementation, not the only implementation
- [ ] File templates produce valid, readable markdown with correct headers
- [ ] README and custom-instructions.md updates are accurate and pass a first-time installer reading test
- [ ] references/coaching-practice/ files are factual and follow references/ style
- [ ] ADR-010 documents the engagement context layer pattern
- [ ] SSOT updated (jobs.yaml J6-J9; journeys/ongoing-engagement.yaml)
- [ ] No regression in existing SKILL.md behaviour (engagement layer is additive, not a pipeline change)

---

## Wave: DISCUSS / [REF] Out of Scope

- Any changes to the thinking-partner pipeline (SKILL.md) — this slice is additive
- Automated sync between engagement files and Claude Chat project knowledge — manual upload is the intended pattern
- Multi-coach or shared engagement folders — sole coach is the user (J4 out of scope per existing jobs.yaml)
- Board-snapshot for tools other than Jira — the reference implementation covers Jira; the skill must make the seam explicit but does not need to implement other tools
- Analytics or reporting on the coaching log — the log is a capture format, not an analysis tool
- Versioning or diff of engagement files — outside scope
- Automated hypothesis tracking or testing — out of scope; the structure supports it but the analysis is human

---

## Wave: DISCUSS / [REF] WS Strategy

**Strategy A** — real invocation, real file system, no external tool dependency.

The walking skeleton (slice 05a) proves: skill invocation → prompt loop → file write → correct output. The tool-specific query (board-snapshot, slice 05c) is the one external dependency; it is isolated behind the config block and has a "none / manual paste" fallback for tool-free validation.

---

## Wave: DISCUSS / [REF] Driving Ports

- `/cb-init` — skill invocation (Claude Code slash command)
- `/cb-log` — skill invocation
- `/cb-retro` — skill invocation
- `/cb-snapshot` — skill invocation
- Claude Chat project knowledge upload — static file (snapshot and engagement files)

---

## Wave: DISCUSS / [REF] Prerequisites

- Slice 03 (portable install) must be complete and validated — this slice builds on the two-layer install pattern (ADR-008)
- Slice 04 (npx distribution) is in progress but does not block — engagement skills will eventually be part of the npx package, but can ship as manual-install files first
- No MCP or external service dependency for core skills (coach-log, retro-action, init); board-snapshot requires a project management MCP or equivalent if automated query is wanted

---

## Wave: DISCUSS / [REF] Outcome KPIs

| KPI | Target | Measurement |
|-----|--------|-------------|
| Time to first coaching log entry | ≤ 5 min from `/cb-init` completion | Manual timing by coach |
| Cold-start friction reduction | Coach does not need to re-describe team context in the first message of a session | Observed in first 3 sessions after init |
| Snapshot-to-conversation time | ≤ 2 min from `/cb-snapshot` to opening `/coach-buddy` message | Manual timing |
| Format adherence | ≥ 80% of log entries have all six fields populated (even if "(to fill)") | Manual scan after 10 entries |

---

## Wave: DISCUSS / [REF] DoR Validation

| # | DoR Item | Status | Evidence |
|---|----------|--------|----------|
| 1 | User stories with who/what/why | ✓ | S1-S6 above, all in LeanUX format |
| 2 | Acceptance criteria testable | ✓ | Each AC references a specific command, output, or observable file state |
| 3 | Job traceability | ✓ | S1→J9, S2→J7, S3→J7, S4→J8, S5→J6, S6→J7 |
| 4 | Non-goals explicit | ✓ | Out-of-scope list above |
| 5 | No blocked dependencies | ✓ | Slice 03 complete; Slice 04 not blocking |
| 6 | Scope right-sized | ✓ | 3 sub-slices, ~5-6h total, each ≤2h |
| 7 | Architecture concerns surfaced | ✓ | Tool-agnostic design (D5), config.json pattern (AC1.9), no hardcoded IDs (D6) |
| 8 | Stories independently valuable | ✓ | Each slice delivers a usable capability even if the others aren't installed |
| 9 | Effort estimated | ✓ | Slice briefs include estimates |

---

## Wave: DESIGN / [REF] DDD List

| # | Decision | Verdict | Rationale |
|---|----------|---------|-----------|
| DD1 | Skill file location in repo | `skills/cb-{name}/SKILL.md` | New top-level `skills/` directory. Separates system files (skills) from user data (engagements/). Consistent with Claude Code install convention (`.claude/skills/cb-{name}/`). |
| DD2 | Engagement data location | `engagements/<team-slug>/` in the **user's project** | Skills ship in the repo; engagement data lives in the project that uses them. Never mixed. |
| DD3 | config.json as engagement registry | Written by `cb-init`; read by all downstream skills | Single source of truth for engagement path, tool type, project key, and threshold config. Eliminates re-prompting between skills. |
| DD4 | File templates embedded in cb-init SKILL.md | Inline markdown blocks, not separate template files | Four files, each ≤30 lines. Inlining keeps the skill self-contained and avoids file-path coupling to template locations. |
| DD5 | Tool adapter as named section within cb-snapshot | `## Tool: Jira` section with JQL; `## Tool: none` section with paste flow | Isolates tool-specific logic without separate files. Coach can read and edit the section directly. New tool support = new named section. |
| DD6 | Entry IDs in COACHING_LOG.md | Date-stamped sequential: `YYYY-MM-DD-NNN` | Stable, human-readable, sortable. No UUID dependency. Collision-safe within a single engagement. |
| DD7 | references/coaching-practice/ parallel to references/frameworks/ | New directory, same markdown pattern | Consistent with existing reference file architecture. Two files: `coaching-log-format.md` and `board-snapshot-guide.md`. |
| DD8 | npx installer extension deferred to Slice 04 | bin/install.js EXTEND deferred | Engagement skills ship as manual-copy files first. The install path (`skills/cb-*/`) is documented so Slice 04 can extend the installer without architectural change. |
| DD9 | Outcome Collision Check | Skipped — methodology-only feature | No new typed contract surface. Engagement skills write markdown files; no API, port, or schema contract is registered. Per D-6 gate-scoping, this check applies to code-feature pipelines only. |
| DD10 | AGENTS-SKILLS.io spec compliance | All four cb- skills must have compliant YAML frontmatter | cb- skills are greenfield — implement the full spec from the start. Fields: `name`, `description`, `user-invocable: true`, `argument-hint`. The existing `SKILL.md` predates the spec and is out of scope for this slice. |

---

## Wave: DESIGN / [REF] Component Decomposition

| Component | Location (repo) | Install location (Claude Code) | Change type | Responsibility |
|-----------|----------------|-------------------------------|-------------|----------------|
| `cb-init` skill | `skills/cb-init/SKILL.md` | `.claude/skills/cb-init/SKILL.md` | CREATE NEW | Scaffolds engagement folder; prompts for config; writes four files + config.json |
| `cb-log` skill | `skills/cb-log/SKILL.md` | `.claude/skills/cb-log/SKILL.md` | CREATE NEW | Prepends structured Safety-II entries to COACHING_LOG.md; supports quick capture and field update |
| `cb-retro` skill | `skills/cb-retro/SKILL.md` | `.claude/skills/cb-retro/SKILL.md` | CREATE NEW | Appends/updates rows in RETRO_ACTIONS.md; supports paste extraction |
| `cb-snapshot` skill | `skills/cb-snapshot/SKILL.md` | `.claude/skills/cb-snapshot/SKILL.md` | CREATE NEW | Queries board tool (or accepts paste); writes dated four-section snapshot file; prints risk read |
| `custom-instructions.md` | `custom-instructions.md` | Custom Instructions field | EXTEND | Add one-line mention of `/cb-init` for engagement setup |
| `README.md` | `README.md` | — | EXTEND | New `## Engagement context layer` section |
| `coaching-log-format.md` | `references/coaching-practice/coaching-log-format.md` | Project Knowledge (optional) | CREATE NEW | Safety-II rationale for COACHING_LOG.md field structure |
| `board-snapshot-guide.md` | `references/coaching-practice/board-snapshot-guide.md` | Project Knowledge (optional) | CREATE NEW | How to read and use a board snapshot in a coaching context |
| `bin/install.js` | `bin/install.js` | — | EXTEND (deferred) | Add `skills/cb-*/` to copy targets (Slice 04) |

---

## Wave: DESIGN / [REF] Driving Ports

| Port | Invocation | Description |
|------|-----------|-------------|
| `/cb-init` | Claude Code slash command | Scaffolds new engagement; prompts for team name, slug, tool type, key |
| `/cb-log` | Claude Code slash command | Captures or updates a coaching log entry |
| `/cb-retro` | Claude Code slash command | Adds or updates retro actions |
| `/cb-snapshot` | Claude Code slash command | Writes a dated board snapshot file |
| `/coach-buddy` | Claude Code / Chat Project | Unchanged; reads engagement files if present |

---

## Wave: DESIGN / [REF] Driven Ports and Adapters

| Port | Side Effect | Adapter | Notes |
|------|------------|---------|-------|
| File write | Creates/updates engagement markdown files | Filesystem (Claude Code tool) | All writes via Read/Write/Edit tools in Claude Code |
| Board query | Fetches work items from project management tool | Jira MCP (reference) / manual paste (fallback) | Tool adapter isolated in `## Tool: {name}` section of cb-snapshot |
| config.json read | Reads engagement path and tool config | Filesystem read | All skills read config.json on invocation; no caching |

---

## Wave: DESIGN / [REF] AGENTS-SKILLS.io Frontmatter Spec

All four cb- skills must open with compliant YAML frontmatter. Reference implementation (nw-discuss pattern):

```yaml
---
name: cb-init
description: >-
  Scaffolds a new coaching engagement folder. Creates CONTEXT.md, COACHING_LOG.md,
  RETRO_ACTIONS.md, HISTORY.md, and config.json under engagements/<team-slug>/.
  Use when starting a new team engagement.
user-invocable: true
argument-hint: '[--force] — re-run on an existing slug (prompts for confirmation)'
---
```

Per-skill frontmatter:

| Skill | `name` | `argument-hint` |
|-------|--------|-----------------|
| cb-init | `cb-init` | `[--force]` |
| cb-log | `cb-log` | `<observation> [--update <id> <field> <value>]` |
| cb-retro | `cb-retro` | `<action> [--update <id> <field> <value>] [--paste "<raw text>"]` |
| cb-snapshot | `cb-snapshot` | `[--slug <team-slug>] [--days <n>]` |

`user-invocable: true` on all four. `description` for each must follow the nWave pattern: one sentence on what it does, one on when to use it. These descriptions are what the agent harness uses for skill discovery — precision matters.

---

## Wave: DESIGN / [REF] Technology Choices

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Skill format | SKILL.md (Cutler-pattern) | Consistent with existing architecture. Visible, editable, versionable. |
| Persistence | Markdown files on filesystem | Zero-dependency. Works in Claude Code, readable in any editor, uploadable to Chat. |
| Config | JSON (config.json) | Parseable by Claude without tooling. Simple schema. Human-readable. |
| Entry IDs | Date-stamped strings (`YYYY-MM-DD-NNN`) | No library dependency. Stable and sortable. |
| Board adapter | MCP tool call (Jira reference) + manual paste | MCP when available; paste fallback keeps the skill usable without MCP setup. |
| Diagrams | Mermaid (C4) | Consistent with existing brief.md. |

---

## Wave: DESIGN / [REF] Reuse Analysis

| Existing Component | File | Overlap | Decision | Justification |
|---|---|---|---|---|
| `SKILL.md` | `SKILL.md` | Orchestrator / SKILL.md pattern | CREATE NEW ×4 | cb- skills are independent invocables with distinct jobs. Coupling them to the coaching pipeline would make engagement ops fire on every `/coach-buddy` invocation. |
| `custom-instructions.md` | `custom-instructions.md` | Always-on hint layer | EXTEND | One-line addition. No structural change to the layer. |
| `references/frameworks/` | `references/frameworks/*.md` | Reference file directory pattern | CREATE NEW directory | Same structural pattern; distinct content domain. `references/coaching-practice/` is parallel, not an extension. |
| `bin/install.js` | `bin/install.js` | File copy to skills directory | EXTEND (deferred) | Same copy-target pattern. New targets: `skills/cb-*/`. Deferred to Slice 04 completion. |

---

## Wave: DESIGN / [REF] config.json Schema

```json
{
  "version": 1,
  "engagement": {
    "name": "Team Display Name",
    "slug": "team-slug",
    "created": "YYYY-MM-DD"
  },
  "tool": {
    "type": "jira",
    "project_key": "ABC",
    "board_id": "42",
    "wip_age_threshold_days": 5
  }
}
```

`tool.type` values: `"jira"` | `"linear"` | `"shortcut"` | `"none"`. When `"none"`, cb-snapshot uses the manual paste flow. `board_id` and `project_key` are tool-specific; other tools use their own field names in the same `tool` object. `wip_age_threshold_days` defaults to `5` if absent.

---

## Wave: DESIGN / [REF] cb-log Entry Format

```markdown
---
id: YYYY-MM-DD-001
date: YYYY-MM-DD
---

**Observed**: [What you saw — Work-as-Done framing, not interpretation]
**Context**: [Ceremony or moment — e.g. sprint review, standup, 1:1]
**Pattern/Signal**: [Tentative label — e.g. "pressure → soldier on", "estimation avoidance"]
**Hypothesis**: If [X continues / changes] then [Y will happen]
**Intervention**: [Named intervention, or "(none yet)"]
**Follow-up**: [What to watch, or question to hold]
```

Quick capture path: coach provides Observed + Context only. Remaining fields scaffolded as `(to fill)`. Update path: `/cb-log --update YYYY-MM-DD-001 hypothesis "If X then Y"`.

---

## Wave: DESIGN / [REF] cb-snapshot Output Format

```markdown
# Board Snapshot — <Team Name>
Generated: YYYY-MM-DD

## WIP (In Progress)
- [Initiative] Epic Title
  - Story: Title | Age: N days ⚠ [if beyond threshold]

## Progress (Last 14 days)
- [Initiative] Epic Title
  - Story: Title | Done: YYYY-MM-DD

## Runway (Ready / Refinement)
- [Initiative] Epic Title
  - Story: Title

## Waiting (Backlog)
- [Initiative] Epic Title
  - Story: Title
```

The `## Tool: Jira` section in cb-snapshot SKILL.md contains the JQL query strings and field mappings. The `## Tool: none` section contains the manual paste prompt and structuring instructions. cb-snapshot reads `tool.type` from config.json and routes to the appropriate section.

---

## Wave: DESIGN / [REF] Open Questions

| # | Question | Deferred to |
|---|----------|-------------|
| OQ1 | Should `cb-snapshot` write a risk read section into the file as well as printing it in chat? | DELIVER — decide during implementation; AC says "in chat" only, but a persistent risk read has value |
| OQ2 | Should `config.json` support multiple boards per engagement (e.g. a team with both a delivery board and a discovery board)? | Post-Slice 05 — single board is sufficient for v1 |
| OQ3 | How does the npx installer handle `skills/cb-*/` — copy each into its own `.claude/skills/cb-*/` directory, or bundle all four under a single `coach-buddy-engagement/` directory? | Slice 04 DELIVER — architectural preference is separate directories (each skill independently invokable) |
| ~~OQ4~~ | ~~snapshots/ creation timing~~ | **Resolved — eager.** `cb-init` creates `snapshots/` at init time. Full structure visible immediately. AC1.2 updated. |
| OQ1 | Risk read in file vs chat only | **Resolved — chat only.** AC4.6 holds. Persistent risk read would mix interpretation into a data file; coaching conversation is the right place for it. |

---

## Wave: DELIVER / [REF] Implementation Summary

Four AGENTS-SKILLS.io-compliant companion skills and two reference documents shipped. The engagement context layer is fully additive — no changes to `SKILL.md`, no changes to the thinking-partner pipeline.

`cb-init` scaffolds a complete engagement folder from a prompt loop, writing five files and a `snapshots/` subdirectory. `cb-log` prepends Safety-II-structured coaching observations to `COACHING_LOG.md`, with a quick-capture path and update-by-ID. `cb-retro` manages the `RETRO_ACTIONS.md` table, including bulk extraction from retro output with ambiguity flagging. `cb-snapshot` queries the board tool (Jira JQL reference implementation with Linear, Shortcut, and manual-paste sections) and writes a dated four-section file plus a two-sentence risk read in chat.

OQ1 (risk read in file vs chat) resolved during implementation: chat only, consistent with AC4.6.

---

## Wave: DELIVER / [REF] Files Modified

**New — skills:**
- `skills/cb-init/SKILL.md` — engagement scaffolding, prompt loop, file templates, overwrite guard
- `skills/cb-log/SKILL.md` — Safety-II log entry capture, quick-capture path, update-by-ID, WaD reframe guard
- `skills/cb-retro/SKILL.md` — table management, status updates, paste extraction with ambiguity flagging
- `skills/cb-snapshot/SKILL.md` — tool-agnostic board query, four-section output, age flags, risk read

**New — references:**
- `references/coaching-practice/coaching-log-format.md` — Safety-II rationale, field-by-field guidance, quick capture vs full entry
- `references/coaching-practice/board-snapshot-guide.md` — four-section interpretation, coaching framing, currency guidance

**Updated — docs:**
- `README.md` — new `## Engagement context layer` section, updated `## What's in the box` table
- `custom-instructions.md` — one-line addition: `/cb-init` hint for engagement setup

**Updated — SSOT:**
- `docs/product/jobs.yaml` — J6-J9 added
- `docs/product/journeys/ongoing-engagement.yaml` — new journey
- `docs/product/architecture/brief.md` — Slice 05 section + C4 container diagram
- `docs/product/architecture/adr-010-engagement-context-layer.md` — new (written in DESIGN wave)

---

## Wave: DELIVER / [REF] DoD Check

| # | DoD Item | Status |
|---|----------|--------|
| 1 | All ACs pass manual testing | Pending — manual session test required (first real engagement use) |
| 2 | No hardcoded team names, org names, tool IDs, or reference engagement content | ✓ — verified across all files |
| 3 | Skills tool-agnostic in design; Jira JQL is reference, not only implementation | ✓ — cb-snapshot has Tool: Jira, Tool: Linear, Tool: none sections |
| 4 | File templates produce valid markdown with correct headers | ✓ — templates verified inline in cb-init |
| 5 | README and custom-instructions.md updates accurate | ✓ — engagement layer section written; one-line hint added |
| 6 | references/coaching-practice/ files factual, follow references/ style | ✓ |
| 7 | ADR-010 documents engagement context layer pattern | ✓ — written in DESIGN wave |
| 8 | SSOT updated (jobs.yaml J6-J9; journeys/ongoing-engagement.yaml) | ✓ |
| 9 | No regression in existing SKILL.md behaviour | ✓ — additive only, SKILL.md untouched |

---

## Wave: DELIVER / [REF] Quality Gates

| Gate | Status | Notes |
|------|--------|-------|
| AGENTS-SKILLS.io frontmatter compliance | ✓ | All four skills have `name`, `description`, `user-invocable: true`, `argument-hint` |
| No reference engagement content | ✓ | Verified — all templates contain only structural elements and prompts |
| Design compliance (DD1-DD10) | ✓ | Files at declared locations; config.json schema matches spec; tool adapter pattern implemented as named sections |
| Additive-only constraint | ✓ | SKILL.md, existing references/, assets/ unchanged |
| Manual validation | Pending | First real engagement use is the acceptance test — by design for this type of deliverable |
