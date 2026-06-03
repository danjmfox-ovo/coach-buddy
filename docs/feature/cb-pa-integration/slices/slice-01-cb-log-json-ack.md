# Slice 01 — cb-log JSON acknowledgement

**Feature**: cb-pa-integration  
**Story**: US-001  
**Estimate**: ≤4h  
**Status**: pending

## Goal

Extend `cb-log` to emit a structured JSON ack when called with `--format json`, so the PA can confirm a write succeeded and record the `entry_id` without parsing prose.

## IN Scope

- `--format json` flag on cb-log skill
- JSON ack schema: `{status, entry_id, team, written_to}` on success; `{status, team, error}` on failure
- Path resolution via `--slug` + `engagements_root` (AV-6 fix)

## OUT Scope

- Changes to observation text parsing or log field validation
- New log fields or format changes
- Human-readable output changes (prose path unchanged)

## Learning Hypothesis

**Disproves**: JSON ack is unnecessary because the PA fallback (direct write) is sufficient.  
**Confirms**: Structured ack is the right communication primitive — PA can track `entry_id` and surface failures without fragile prose parsing.

## Acceptance Criteria

- `--format json` emits valid JSON instead of prose
- `status: ok` includes `entry_id`, `team`, `written_to`
- `status: error` includes `team` and `error`
- Path resolves from `--slug`; does not assume cwd
- Prose behaviour unchanged when flag absent

## Dependencies

- cb-log-deterministic-writes (shipped 2026-05-21) — entry_id format stable

## Effort Reference Class

Single skill extension — flag parsing + conditional output branch. No new file reads.

## Pre-slice SPIKE

Not required — pattern is clear, no architectural uncertainty.
