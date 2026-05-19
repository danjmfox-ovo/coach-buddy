# DISCUSS Decisions — calendar-magick-integration

## Key Decisions

- [D1] Integration boundary — coexistence with typed reference: `config.json` holds coaching metadata; `teams.yaml` holds team topology. coach-buddy reads `teams.yaml` only when `team_config.path` is explicitly set in `config.json`. Neither file is eliminated. (see: feature-delta.md)
- [D2] coach-buddy is read-only on teams.yaml: calendar-magick owns the write path. No shared write lock. (see: feature-delta.md)
- [D3] Detection strategy — explicit reference, not filesystem scanning at runtime: cb-init scans as a setup convenience; skills at runtime trust the config.json reference. (see: feature-delta.md)
- [D4] `team_config.path` is relative to the engagement root: portable when the CoWork project is moved. (see: feature-delta.md)

## Requirements Summary

- Primary job: `ceremony-aware-engagement` — coaches who use both tools want one team-topology file, not two
- Enabling jobs: engagement-scaffolding (J9), board-snapshot-without-context-switch (J8), structured-observation-capture (J7)
- Walking skeleton scope: US-01 (link written) + US-02 (link read in snapshot) — proves full data path
- Feature type: cross-cutting (touches cb-init, cb-snapshot, cb-log skills and config.json schema)

## Constraints Established

- calendar-magick CLI not required at runtime — integration is YAML-read-only
- team.events ceremony schedule deferred (start with cadence/sprint_length only)
- Existing engagements without `team_config.path` must show zero behaviour change

## Upstream Changes

- None: no DISCOVER or DIVERGE artifacts exist for this feature. All decisions are original to this DISCUSS wave.

## Scope Assessment

PASS — right-sized. 4 user stories, 2 bounded contexts, walking skeleton needs 3 integration points, estimated ~3 days total.
