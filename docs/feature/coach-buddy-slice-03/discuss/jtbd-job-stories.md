# JTBD Job Stories — coach-buddy-slice-03
# Wave: DISCUSS (2026-05-12)
# Density: lean (jobs already in SSOT — referenced, not re-derived)

---

## Reference: Existing Job IDs

Slice 03 is grounded in two jobs already validated and recorded in
`docs/product/jobs.yaml`. No new JTBD derivation required.

| Job ID | Title | Opportunity Score | Validation Status |
|--------|-------|-------------------|-------------------|
| `in-context-activation` (J3) | Invoke thinking-partner support without switching away from where the work lives | 7.0 | validated: false — emerged from real use of Slice 01 |
| `portable-across-teams` (J5) | Install thinking-partner support into any team project with minimal effort | 6.5 | validated: false — aspirational, direction of travel |

---

## J3 → Slice 03 Story Bridge

**Job story (J3)**:
> When I am working inside a team's project — reviewing artefacts, prepping for a
> session, observing a pattern — I want to invoke a thinking-partner lens without
> switching to a separate coaching tool, so I can think through what I'm observing
> while the triggering context is still in front of me.

**Maps to**:
- Story 1 (Portable Install) — prerequisite: tool must be installable in team project before activation is possible
- Story 2 (/coach-buddy Invocation) — primary: invocation is the activation mechanism J3 requires

**Four forces reminder** (from SSOT):
- Push: switching means reconstructing context from memory; the triggering artefacts disappear
- Pull: invoke coaching while looking at sprint board, decision doc, what triggered the thought
- Anxiety: might deliver reduced capability without reference files; quality unpredictable
- Habit: opens separate coaching project or thinks through it alone

**Slice 03 resolves the anxiety**: graceful degradation story (Story 3) directly addresses "quality unpredictable without reference files."

---

## J5 → Slice 03 Story Bridge

**Job story (J5)**:
> When I am coaching multiple teams across separate projects,
> I want to add thinking-partner capability to any team's project with a single
> install step, so each team has access to the coaching lens without me having
> to build and maintain separate dedicated tools per engagement.

**Maps to**:
- Story 1 (Portable Install) — primary: two-step install (custom-instructions.md + SKILL.md) is the J5 activation mechanism

**Four forces reminder** (from SSOT):
- Push: per-team setup is high-friction; maintaining multiple copies unsustainable
- Pull: one install, any project has the capability
- Anxiety: quality might vary without reference files per-team
- Habit: uses one dedicated project (constant context switching) or manually duplicates setup

**Note**: J5 is a distribution job, not a coaching experience job. It falls out of solving J3.
Prioritise J3 validation first; J5 validation follows naturally from the same install test.

---

## JTBD-to-Story Trace

| Story | Primary Job | Secondary Job |
|-------|-------------|---------------|
| Story 1: Portable Install | J5 (`portable-across-teams`) | J3 (`in-context-activation`) — prerequisite |
| Story 2: /coach-buddy Invocation | J3 (`in-context-activation`) | — |
| Story 3: Graceful Degradation | J3 (`in-context-activation`) | J5 (`portable-across-teams`) — anxiety resolution |
