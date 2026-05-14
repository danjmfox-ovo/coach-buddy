# DISCUSS Decisions — coach-buddy-slice-05 (Engagement Context Layer)
# Wave: DISCUSS | Date: 2026-05-14

## Key Decisions

- [D1] Feature type = cross-cutting: touches file scaffolding (new), skill definitions (new), docs (update), custom-instructions.md (update), README (update). Not a change to the thinking-partner pipeline.
- [D2] Walking skeleton = slice 05a (init + folder structure): proves the architectural layer end-to-end before logging or snapshotting is added. Strategy A: real invocation, real file writes, no external dependency.
- [D3] UX depth = lightweight: journey is well-understood from reference implementation; happy path is in the brief.
- [D4] JTBD included: four new jobs J6-J9 derived from reference implementation. Added to jobs.yaml.
- [D5] Tool-agnostic board-snapshot: Jira JQL is reference implementation; skill must expose a clearly labelled tool config block so other tools can be substituted without touching skill logic.
- [D6] No reference-engagement content: hard constraint. Nothing from the reference engagement (team names, org, tool IDs, coaching log entries, board data) may appear in any generalised file. Verified per-AC.
- [D7] references/coaching-practice/ directory: created alongside existing references/frameworks/. Holds COACHING_LOG format rationale (Safety-II grounding) and board-snapshot interpretation guide.
- [D8] ADR-010: engagement context layer is an architectural extension to the Cutler-pattern deployment model. Decision has lasting consequences; belongs in ADR record.
- [D9] Slice order 05a → 05b → 05c: scaffolding before logging before snapshotting. Dependencies are hard: coach-log and retro-action write to files created by init; board-snapshot reads config created by init.
- [D10] Skill naming convention = `cb-` prefix: `/cb-init`, `/cb-log`, `/cb-retro`, `/cb-snapshot`. Mirrors the `nw-` prefix pattern. Avoids namespace collisions with other tools in the same skills directory (init, log, and snapshot are all common generic names). `/coach-buddy` is unchanged — it predates this convention and its full name is its identity.

## Requirements Summary

- Primary jobs: J6 (situated coaching across sessions), J7 (structured observation capture), J8 (board snapshot without context switch), J9 (engagement scaffolding)
- Walking skeleton scope: init skill + four file templates (CONTEXT.md, COACHING_LOG.md, RETRO_ACTIONS.md, HISTORY.md) + config.json
- Feature type: cross-cutting

## Constraints Established

- All file paths must be read from `engagements/<team-slug>/config.json`; no hardcoded paths or IDs anywhere in skill code
- board-snapshot skill must have a tool-agnostic design: tool-specific query in labelled config block; "none / manual paste" fallback required
- COACHING_LOG.md format is Safety-II-informed; this is structural, not cosmetic — the field names and framing are fixed
- Engagement skills are additive; they must not change SKILL.md behaviour or break existing install patterns

## Upstream Changes

- No DISCOVER artifacts exist for this feature. No DISCOVER assumptions to reconcile.
- No contradictions with existing jobs.yaml, persona, or journeys. Jobs J6-J9 are new; they don't supersede existing jobs.
