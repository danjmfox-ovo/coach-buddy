# Evolution — cb-pa-integration

**Date**: 2026-06-03  
**Version**: v1.10.0  
**Feature**: PA Agent Integration — cb-log JSON ack + cb-query skill

---

## What shipped

Two SKILL.md changes forming the machine-readable interface between coach-buddy (team specialist) and a PA agent (personal coordinator):

**`cb-log` extended** with `--format json` output branch. PA agents can now confirm write success programmatically (`status:ok` with `entry_id`, `team`, `written_to`) and handle path resolution failures as structured errors (`status:error`). Prose behaviour fully unchanged when flag absent.

**`cb-query` created** as a new read-only skill. Reads `COACHING_LOG.md` and `RETRO_ACTIONS.md` from an engagement folder, applies the Named Extraction Grammar (ADR-014) to surface open retro actions, open/deferred hypotheses (D6: openness independent of time window), last capture and retro dates. Optional board MCP call for WIP age with graceful degraded path. Returns readable prose for human use, or structured JSON (`--format json`) for PA consumption with `status:ok/degraded/error`.

---

## Design decisions (summary)

| Decision | Verdict |
|----------|---------|
| DW-1 | PA = personal coordinator; coach-buddy = team specialist; JSON as the boundary |
| DW-2 | `signal_summary` scoped to engagement-health domain only — composable, not duplicative |
| DW-3 | PA contract v1.0.0-draft treated as speculative spec — coach-buddy exercises own judgment |
| DW-4 | JSON schema designed as general-purpose data contract for future dashboard use |
| D3 | Existing prose behaviour fully preserved when `--format json` absent |
| D5 | `degraded` status when board MCP unavailable — PA usability preserved |
| D6 | `--since` window filters entries read; does not close open hypotheses |

---

## Retrospective

Clean delivery. Three slices mapped cleanly to two SKILL.md files (one extension, one creation). Architecture was fully specified in DISCUSS/DESIGN/DISTILL before implementation began, leaving no ambiguity at build time.

DW-2 (signal_summary scope) was the only deliberate deviation from the PA contract — validated as intentional and clearly documented in the Named Extraction Grammar. The signal_summary is structurally composable: engagement-health-only signals from coach-buddy + calendar/chat signals from PA = complete brief without duplication.

Walking skeleton strategy C (brownfield, no new integration layer) proved correct — all three slices shipped end-to-end without needing a separate skeleton step.

**To observe in real use**: OQ-1 — does `signal_summary` create duplication in PA output? Resolve during Slice 03 dogfood by observing actual PA pre-session brief.

---

## Files

- `skills/cb-log/SKILL.md` — extended
- `skills/cb-query/SKILL.md` — created
- `tests/acceptance/cb-pa-integration/` — 28 manual conversation scenarios (3 files)
- `docs/product/architecture/adr-014-cb-query-extraction-grammar.md` — ADR
