# Slice 05c — Board Snapshot

**Goal**: Give the coach a current picture of the team's work state before a coaching conversation, without leaving their coaching context. The snapshot file bridges live skills (Claude Code) and static context (Claude Chat project knowledge).

## In Scope

- `engagements/skills/board-snapshot/SKILL.md` — the board-snapshot skill: four-section output, age-flags, tool-agnostic design with Jira JQL reference implementation, two-sentence risk read, "none / manual paste" fallback
- `docs/product/architecture/adr-010-engagement-context-layer.md` — ADR documenting the engagement context pattern as an architectural extension to ADR-008

## Out of Scope

- Implementing board-snapshot for tools other than Jira (Linear, Shortcut, etc.) — the skill makes the seam explicit but only Jira is implemented
- Automated refresh or scheduling of snapshots
- Any changes to the thinking-partner pipeline (SKILL.md)

## Learning Hypothesis

Disproves if it fails: the tool-agnostic config-block pattern is not sufficient — coaches with non-Jira tools either cannot configure the skill or abandon it. If this happens, the design needs a per-tool skill variant rather than a config block.

Confirms if it succeeds: a Jira user can run `/cb-snapshot`, get a four-section file and a risk read, and use it as context for `/coach-buddy` in the same session. The file is readable enough to upload to Chat as project knowledge without editing.

## Acceptance Criteria

- AC4.1 through AC4.8 from feature-delta.md S4 (board-snapshot)
- ADR-010 exists and documents: the engagement context layer as a third deployment pattern alongside dedicated Chat project (Slices 01-02) and portable team project install (Slice 03); the config.json pattern; the Chat sync pattern; the tool-agnostic seam; watch items
- Manual test: run `/cb-snapshot` against a real (or mocked) Jira project; verify file written to correct path with correct sections; verify age flags appear for items beyond threshold; verify risk read appears in chat

## Dependencies

- Slice 05a complete: config.json must exist (contains tool type and project key)
- Jira MCP or equivalent available in the test environment OR use the "none / manual paste" fallback path for tool-free validation

## Effort Estimate

~2 hours. Jira query logic is well-understood from the reference implementation. ADR is ~1-2 pages in the existing style.

## Production Data

The coach uses a real (or sanitised) Jira project for the test. If no MCP is available, the manual paste path is the production data path.

## Dogfood Moment

The coach runs `/cb-snapshot` the morning before their next team coaching session and uses the output as the opening context for `/coach-buddy`. If the risk read is immediately useful without the coach having to interpret the raw data, the hypothesis is confirmed.
