# Slice 02 — cb-query human-readable snapshot

**Feature**: cb-pa-integration  
**Story**: US-002  
**Estimate**: ≤4h  
**Status**: pending

## Goal

New `cb-query` skill that reads an engagement folder and returns a readable summary of team health — open actions, aged hypotheses, WIP age, signal summary — in one command.

## IN Scope

- New `cb-query` skill (SKILL.md)
- Reads `COACHING_LOG.md` and `RETRO_ACTIONS.md` from `engagements/{slug}/`
- Reads `config.json` for `board_tool` setting
- Calls board MCP if available; omits gracefully if not
- `--since` flag (default 14 days)
- `--slug` flag for path resolution; `engagements_root` convention
- Human-readable prose output

## OUT Scope

- `--format json` output (Slice 03)
- Replacing or deprecating cb-snapshot
- Writing to any file
- Board MCP implementation (depends on existing Jira MCP availability)

## Learning Hypothesis

**Disproves**: Assembling open actions + hypotheses + WIP age from three sources in one skill is too complex or slow to be practical.  
**Confirms**: Data assembly from COACHING_LOG.md + RETRO_ACTIONS.md + board MCP is tractable; signal_summary is generatable from engagement-health fields alone.

## Acceptance Criteria

- Reads `COACHING_LOG.md` and `RETRO_ACTIONS.md` from `engagements/{slug}/`
- Surfaces open non-evidenced actions, open/deferred hypotheses, last capture date, last retro date
- Board MCP called if `board_tool` is `jira` or `linear`; omitted gracefully if unavailable
- Output is readable prose
- `--since` defaults to 14 days; accepts ISO date override
- Clear error message if engagement folder not found
- Path resolved from `--slug`; does not assume cwd

## Dependencies

- Slice 01 not required (independent)
- cb-log-deterministic-writes (2026-05-21) — consistent COACHING_LOG.md format for reliable parsing
- cb-init engagement folder at `engagements/{slug}/`

## Effort Reference Class

New skill with file reads and conditional MCP call. Closest analogue: cb-snapshot complexity.

## Pre-slice SPIKE

Consider: verify COACHING_LOG.md parsing for `evidenced` field and hypothesis status extraction before full implementation. Low-risk given deterministic-writes feature landed, but worth a quick read of an actual log file first.
