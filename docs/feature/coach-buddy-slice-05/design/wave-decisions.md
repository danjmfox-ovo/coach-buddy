# DESIGN Decisions — coach-buddy-slice-05 (Engagement Context Layer)
# Wave: DESIGN | Date: 2026-05-14

## Key Decisions

- [DD1] Skill file location = `skills/cb-{name}/SKILL.md`: new top-level `skills/` directory in repo. Separates system files (skills) from user data (engagements/). Consistent with Claude Code install convention.
- [DD2] Engagement data in user's project at `engagements/<team-slug>/`: skills ship in the coach-buddy package; engagement data lives where the coach works. Never mixed.
- [DD3] config.json as engagement registry: written by cb-init, read by all downstream skills. Eliminates re-prompting; single source of truth for path, tool type, and threshold config.
- [DD4] File templates embedded in cb-init SKILL.md: four files, each ≤30 lines. Inlining keeps the skill self-contained.
- [DD5] Tool adapter as named section in cb-snapshot: `## Tool: Jira` with JQL; `## Tool: none` with paste flow. New tool support = new section, no structural change.
- [DD6] Entry IDs = date-stamped sequential `YYYY-MM-DD-NNN`: stable, human-readable, no library dependency.
- [DD7] references/coaching-practice/ parallel to references/frameworks/: same pattern, distinct domain.
- [DD8] npx installer extension deferred to Slice 04: engagement skills ship as manual-copy first.
- [DD9] Outcome Collision Check skipped: methodology-only feature, no typed contract surface (D-6 gate-scoping).
- [DD10] AGENTS-SKILLS.io spec compliance: all four cb- skills must have compliant YAML frontmatter (`name`, `description`, `user-invocable: true`, `argument-hint`). cb- skills are greenfield — implement full spec from the start. Existing SKILL.md predates the spec and is out of scope for this slice.

## Architecture Summary

- Pattern: Cutler-pattern extension — new independent SKILL.md invocables alongside the existing orchestrator
- Paradigm: declarative configuration + markdown persistence (no code)
- Key components: cb-init, cb-log, cb-retro, cb-snapshot (4 new skills) + config.json schema + references/coaching-practice/ (2 new reference files)

## Reuse Analysis

| Existing Component | File | Overlap | Decision | Justification |
|---|---|---|---|---|
| `SKILL.md` | `SKILL.md` | Orchestrator pattern | CREATE NEW ×4 | Independent invocables; coupling to pipeline would fire on every /coach-buddy turn |
| `custom-instructions.md` | `custom-instructions.md` | Always-on hint layer | EXTEND | One-line addition only |
| `references/frameworks/` | `references/frameworks/*.md` | Reference file pattern | CREATE NEW directory | Parallel domain; not an extension of frameworks |
| `bin/install.js` | `bin/install.js` | Copy-to-skills pattern | EXTEND (deferred) | Same mechanism; new targets deferred to Slice 04 |

## Technology Stack

- Skill format: SKILL.md (Cutler-pattern) — consistent with all existing components
- Persistence: Markdown on filesystem — zero-dependency, Chat-uploadable
- Config: JSON (config.json) — Claude-parseable without tooling
- Entry IDs: date-stamped strings — no library dependency
- Board adapter: MCP tool call (Jira) + manual paste fallback

## Constraints Established

- All cb- skills must open with AGENTS-SKILLS.io-compliant YAML frontmatter: `name`, `description`, `user-invocable: true`, `argument-hint`. DELIVER is blocked on any skill missing this frontmatter.
- `engagements/<team-slug>/` is user data; it is never committed to the coach-buddy package
- config.json version field (`"version": 1`) enables future schema migration without breaking reads
- cb-snapshot SKILL.md must remain usable when `tool.type = "none"` (no MCP available)
- All four cb- skills must be independently installable — a coach who only wants cb-log can install just that skill

## Upstream Changes

None. All DISCUSS assumptions hold. No story or AC changes required.
