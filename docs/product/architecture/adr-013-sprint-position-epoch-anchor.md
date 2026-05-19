# ADR-013: Sprint Position Epoch Anchor — Deterministic Cadence Derivation Without Stored State

**Status**: Accepted
**Date**: 2026-05-19
**Feature**: calendar-magick-integration

---

## Context

US-02 requires cb-snapshot to derive the current sprint day and week from `cadence: scrum` and `sprint_length_weeks` in teams.yaml. The DISCUSS wave locked the constraint: no sprint start date is stored in config.json or anywhere else. The position must be computed from the cycle length and today's date alone.

The algorithm must be:
- Deterministic: two coaches with the same `sprint_length_weeks` and the same date see the same sprint position
- Stateless: no user input required beyond `sprint_length_weeks`
- Implementable as SKILL.md prose: arithmetic only, no library calls

A naive modulo-on-ISO-week-number approach works within a year but drifts when sprint length does not evenly divide the year boundary (e.g. a 3-week sprint crossing new year). An epoch anchor eliminates this drift.

---

## Decision

The Sprint Position Calculator uses a fixed epoch anchor: **2020-01-06** (a Monday, ISO week 2020-W02).

Algorithm:
1. Find the Monday of the current ISO week (`week_monday`).
2. Calculate `weeks_elapsed` = floor((week_monday − epoch_monday) / 7).
3. Calculate `sprint_cycle_index` = weeks_elapsed mod N (where N = sprint_length_weeks).
4. Calculate `sprint_start_monday` = week_monday − (sprint_cycle_index × 7 days).
5. Count business days (Mon–Fri) from sprint_start_monday to today (1-based) → `sprint_day`.
6. Calculate `sprint_week` = ceil(sprint_day / 5).
7. Weekend handling: if today is Saturday or Sunday, use Friday as the effective "today."

The epoch date (2020-01-06) is arbitrary but fixed. It is embedded as a constant in the cb-snapshot SKILL.md prose.

---

## Alternatives Considered

### Alternative 1: Pure ISO week number modulo N

Calculate `sprint_cycle_index` = ISO_week_number mod N directly (without an epoch).

Rejected: ISO week numbers reset at year boundaries. A 2-week sprint on week 52 of one year followed by week 1 of the next year produces an incorrect sprint boundary. The epoch anchor solves this by counting elapsed weeks continuously since a fixed point.

### Alternative 2: Store sprint_anchor_date in config.json

Ask the coach once to confirm their sprint start date and persist it in config.json as `team_config.sprint_anchor_date`.

Rejected: the DISCUSS wave explicitly excluded stored sprint start date. The value of derivation is that the coach does not need to know or remember their sprint start date — the tool infers it. Storing it reintroduces the synchronisation problem the feature is trying to eliminate.

### Alternative 3: Ask the coach at snapshot time

At runtime, if cadence is scrum, ask: "What date did the current sprint start?"

Rejected: this breaks the seamless automation goal. cb-snapshot is meant to be invoked quickly before coaching conversations; an additional prompt undermines the job-to-be-done (board-snapshot-without-context-switch).

---

## Consequences

### Positive
- Algorithm is fully deterministic: same inputs always produce same output
- No user input required at runtime
- No new config.json fields beyond what is already designed
- Implementable as SKILL.md prose arithmetic (no code, no library)

### Negative
- The epoch produces a fixed sprint-boundary grid that may not match a team's actual sprint start. A coach whose sprint starts on a Wednesday will see a misaligned position.
- The mismatch is a coaching inconvenience, not a correctness failure. The sprint context is a hint, not a payroll calculation.
- If misalignment is reported, a future `team_config.sprint_anchor_date` override can be added without changing the core algorithm (replace epoch with the stored anchor when present).

### Known limitation
The epoch anchor assumes Monday-start sprints. Teams starting sprints on other days of the week will see a position offset by 1–4 days. This is logged as OQ-02 in the feature-delta Open Questions.
