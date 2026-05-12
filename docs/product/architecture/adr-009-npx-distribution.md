# ADR-009: npx Distribution as Wilderness Exception

**Status**: Accepted
**Date**: 2026-05-12
**Deciders**: Dan Fox

---

## Context

Coach Buddy installs today via manual copy-paste (Chat Project) or `cp -r` (Claude Code / Cursor). The README promised `npx skills add danjmfox-ovo/coach-buddy` but no package backed it. There is no signal yet on which deployment form is most useful to coaches.

The goal is not to deliver a polished distribution system — it is to reduce friction across forms so real usage can accumulate and signal which form is worth investing in further.

This work is labelled a **Wilderness Exception**: we are running an experiment on distribution, not building a validated feature. If the npm path does not get traction, it is dropped without guilt.

---

## Decision

Publish Coach Buddy to npm as `coach-buddy` with a single CLI entry point:

```bash
npx coach-buddy
```

The installer:
- Detects Claude Code (project-level `.claude/` or user-level `~/.claude/` with `--global`) and Cursor (`.cursor/`)
- Copies SKILL.md, custom-instructions.md, references/, and assets/ to the appropriate skills directory
- Prints manual Chat Project instructions when no supported tool is detected
- Refuses to overwrite an existing install without `--force`

---

## Alternatives rejected

**`npx skills add danjmfox-ovo/coach-buddy`** — requires a shared `skills` registry or CLI that does not exist. Blocked on a third-party dependency we cannot control. Deferred: if a `skills` convention emerges from the nWave or Cutler ecosystem, we can adopt it at that point.

**`npx @danjmfox-ovo/coach-buddy`** — scoped packages require an npm org. Adds account overhead. Revisit if `coach-buddy` is unavailable as an unscoped name.

**No installer, just `cp -r` docs** — maintains current friction. Excluded because the README was already promising more, and the learning goal requires actual installs to happen.

---

## Consequences

- `package.json` added to repo root; repo is now an npm package
- README Quick Install section updated to reflect the real command
- Chat Project setup remains manual — the installer cannot write to Claude's web UI
- Cursor path (`skills/`) is documented and implemented; if Cursor conventions change (e.g. `.cursor/rules/`), update the installer
- Monitor: if `npx coach-buddy` installs happen and no usage follows, the distribution form is not the bottleneck — the tool itself needs work

---

## Related

- ADR-006: Cutler-pattern now; nWave-pattern as upgrade path
- ADR-008: portable install two-layer model
