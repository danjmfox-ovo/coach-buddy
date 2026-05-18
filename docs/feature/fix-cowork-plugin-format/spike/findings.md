# Spike Findings — fix-cowork-plugin-format

## Assumption Tested (final)
Does CoWork accept a `.plugin` zip when all SKILL.md frontmatter uses flat top-level fields
(`user-invocable: true`, `argument-hint`) instead of nesting them inside a `metadata:` block?

## Probe Verdict
**WORKS** — Probe C2 (full plugin, all 6 skills, metadata block unwrapped) uploaded
successfully to CoWork.

## Probe history
| Probe | Change | Result | Rules out |
|---|---|---|---|
| A | Strip `repository`, `license`, `keywords`, `skills` from `plugin.json` | FAIL ("invalid plugin format") | Extra fields in plugin.json are not the cause |
| B | Plain JSON as `.plugin` (no zip) | FAIL ("not a valid plugin archive") | Plugin must be a zip archive |
| C2 | Unwrap `metadata:` block → top-level fields in all 6 SKILL.mds | **WORKS** | Confirms root cause |

## Root cause
The AGENTS-SKILLS.io spec requires `user-invocable: true` and `argument-hint` as
**top-level** YAML frontmatter fields. The coach-buddy SKILL.mds nested them inside a
`metadata:` block, which CoWork's validator does not recognise.

CoWork validator expectation:
```yaml
user-invocable: true
argument-hint: '...'
```

What we had (failing):
```yaml
metadata:
  user-invocable: true
  argument-hint: '...'
```

This divergence has blocked every CoWork upload attempt from the initial plugin creation.

## Secondary finding
The `.plugin` format is a zip archive, not a bare JSON file. `claude plugin validate`
on a zip fails (tries to JSON-parse it) — the CLI validate command only works on
manifest JSON, not the zip. This was a misleading signal during investigation.

## Design implications
1. Source SKILL.mds in `plugins/coach-buddy/skills/` need the `metadata:` block unwrapped
2. `validate-plugin.js` must be updated: check `user-invocable: true` as a top-level key,
   not as `metadata.user-invocable`
3. The `metadata:` nesting in `skills/` (Claude Code install path) is a separate concern —
   Claude Code uses `metadata.user-invocable` for skill discovery. These two paths have
   diverging format requirements.

## Promoted: 2026-05-18
