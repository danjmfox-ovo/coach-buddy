# ADR-012: Root Layout — CoWork Project Placement via `--root` Flag

**Status**: Accepted
**Date**: 2026-05-19
**Scope**: cb-init and all engagement-reading skills (cb-log, cb-retro, cb-snapshot, cb-validate, coach-buddy)
**Extends**: ADR-010 (engagement context layer), ADR-008 (portable install two-layer model)

---

## Context

ADR-010 established the engagement context layer: a set of files (`CONTEXT.md`, `COACHING_LOG.md`,
`RETRO_ACTIONS.md`, `HISTORY.md`, `config.json`, `snapshots/`) scaffolded by cb-init and read by
all downstream skills. ADR-010 placed these files at `engagements/<slug>/` relative to the
project root — a subdirectory that isolates the engagement from the rest of the project.

In practice, a new deployment pattern has emerged: **CoWork projects** — dedicated Claude Code
projects whose sole purpose is a single coaching engagement (e.g. `~/teams/advisor-connect`).
In this pattern, the `engagements/<slug>/` subdirectory is a redundant container. The project
root IS the engagement. The subdirectory adds path verbosity and creates an artificial namespace
where none is needed.

The real-world advisor-connect project (`~/teams/advisor-connect`) was manually migrated to root
layout, confirming the desired ergonomic. Engagement files sit at the project root alongside
`.claude/` and `CLAUDE.md`. All downstream skills read from those paths.

A secondary benefit: `--root` as an explicit flag — rather than auto-detection — unlocks a
**multi-root extension path**: `cb-init --root <path>` can initialise an engagement at an
arbitrary target directory without the user being present in it. This enables initialising
multiple sibling engagement directories from a parent workspace.

---

## Decision

### 1. `--root` flag on cb-init

cb-init accepts a new optional flag: `--root`.

| Invocation | Writes to |
|---|---|
| `cb-init` | `engagements/<slug>/` (current behaviour — unchanged) |
| `cb-init --root` | current working directory |
| `cb-init --root <path>` | specified path (future extension; not in scope for this slice) |

When `--root` is passed, cb-init scaffolds all engagement files directly in the target directory
with no `engagements/<slug>/` wrapper:

```
CONTEXT.md
COACHING_LOG.md
RETRO_ACTIONS.md
HISTORY.md
config.json
snapshots/
```

The overwrite guard checks for `config.json` in the target directory (same file, different path).

### 2. Root-layout detection for downstream skills

Downstream skills (cb-log, cb-retro, cb-snapshot, cb-validate, coach-buddy) detect layout by
checking for `config.json` at the project root before falling back to the legacy path:

```
1. If ./config.json exists and contains engagement schema → root layout
2. Else look for engagements/<slug>/config.json → legacy/standalone layout
3. If neither found → prompt for slug or surface a clear error
```

`config.json` at root is a necessary but not sufficient condition. Detection requires a
**schema match**: the file must exist AND contain both a `version` field and an
`engagement.slug` field. The check is:

```
./config.json exists
AND ./config.json contains { "version": ..., "engagement": { "slug": ... } }
```

This schema is coach-buddy-specific. Other tools that write a `config.json` to the project
root (TypeScript compiler, ESLint, Prettier, npm, CoWork platform config) do not include an
`engagement.slug` field. File existence alone is not the signal — schema presence is.

The detection anchor is appropriate because:
- The `engagement.slug` schema field is distinctive to coach-buddy engagements
- It is written only by cb-init
- It is present from the first init, so detection works immediately after scaffolding

### 3. Slug disambiguation in root layout

In root layout there is exactly one engagement per project. The slug disambiguation logic
(glob `engagements/` and prompt if multiple exist) is bypassed entirely when root layout is
detected. The slug is read directly from `config.json` at root.

---

## Rationale

**Explicitness over heuristics.** Auto-detecting a CoWork context (e.g. via `.claude/skills/`
presence) would work for the common case but is fragile — a regular codebase with coach-buddy
installed locally would be misidentified. `--root` makes intent declarative. The coach states
"this directory is the engagement root" once, at init time. All downstream reads follow from
the `config.json` the flag creates.

**Unlocks multi-root extension.** An explicit flag is the natural seam for `--root <path>`.
An auto-detection approach has no clean path to specifying an arbitrary target. Explicit flags
compose; heuristics do not.

**Single detection anchor.** Using `config.json` schema-match as the layout detector avoids
adding a new marker file and avoids inspecting directory structure. The file is already
required — it is not introduced solely for detection purposes. Schema-match (not file
existence alone) guards against false positives from other tools that write a `config.json`
to the project root.

**Backwards compatible.** The default behaviour of cb-init is unchanged. Existing engagements
at `engagements/<slug>/` continue to work without migration. The fallback chain in downstream
skills (`config.json` at root → `engagements/<slug>/config.json`) means old and new layouts
coexist transparently.

---

## Alternatives Considered

### Alternative A: Auto-detect CoWork via `.claude/skills/` presence

Check whether `.claude/skills/cb-*` skills are installed at the project root. If so, assume
CoWork context and write to root.

**Why rejected**: Fragile. A coach-buddy install into any team project's `.claude/skills/`
(the canonical portable install path from ADR-008) would trigger root layout even when the
coach wants `engagements/<slug>/`. The heuristic cannot distinguish "dedicated coaching
project" from "team project with skills installed". Produces unexpected placement with no
override path.

### Alternative B: CoWork marker file (e.g. `.cowork/project.json`)

Detect a CoWork platform marker file written by the CoWork host application.

**Why rejected**: Depends on the CoWork platform writing a specific file at a specific path.
This is an external contract with no current guarantees. If the marker format or path changes,
detection silently breaks. Also does not address non-CoWork dedicated coaching projects (plain
directories with no platform marker). `--root` covers all cases without platform dependency.

### Alternative C: `placement` key in config.json

Add a `placement: "root" | "nested"` key to `config.json`. cb-init writes it; downstream
skills read it.

**Why rejected**: Adds a config field whose only consumer is path resolution — the path itself
already encodes the layout. Carrying layout state in a config key when the filesystem already
expresses it is redundant. The `config.json` schema-match signal is self-describing — the `engagement.slug` field is
distinctive enough to distinguish coach-buddy config from any other tool's root config.

---

## Consequences

**Positive:**
- CoWork projects gain clean ergonomic (files at root, no redundant subdirectory)
- Default behaviour unchanged — zero impact on existing engagements
- `--root <path>` extension is a natural follow-on with no design revision needed
- Downstream skills become layout-agnostic via a two-step detection chain
- Slug disambiguation simplified to a no-op in root layout

**Negative / Watch items:**
- Root layout places `CONTEXT.md`, `COACHING_LOG.md` etc. at project root — names that
  could collide with pre-existing team files. Mitigation: cb-init overwrite guard fires on
  `config.json` existence; if `config.json` is absent but `COACHING_LOG.md` exists, cb-init
  should warn rather than silently overwrite.
- `--root <path>` is noted but not implemented in this slice. If the extension is deferred
  too long, coaches may work around it by `cd`-ing to the target — watch for that pattern.
- All six skills require path-resolution updates. Incomplete rollout (cb-init changed,
  downstream skills not yet updated) would produce a broken init-then-log cycle. Ship as
  a single slice or gate downstream reads on cb-init completion.

---

## References

- ADR-001: Transparency as first quality attribute
- ADR-008: Portable install two-layer model (deployment seam context)
- ADR-010: Engagement context layer (establishes `engagements/<slug>/` layout)
- `~/teams/advisor-connect` — real-world root-layout engagement (manually migrated, confirmed ergonomic)
- `docs/product/journeys/ongoing-engagement.yaml` — journey artifact to update post-implementation
