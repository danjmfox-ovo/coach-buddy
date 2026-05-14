# Coach Buddy — Cowork Plugin

Agile coaching tools for Cowork. Five skills covering the full coaching workflow: thinking partner, engagement setup, observation logging, retro tracking, and board snapshots.

## Skills

| Skill | Invoke with | What it does |
|---|---|---|
| `coach-buddy` | `/coach-buddy` | Thinking partner for working through real coaching situations. Situation-focus by default; frameworks on interest signals. |
| `cb-init` | `/cb-init` | Scaffolds a new engagement folder (CONTEXT.md, COACHING_LOG.md, RETRO_ACTIONS.md, HISTORY.md, snapshots/). |
| `cb-log` | `/cb-log` | Captures or updates a structured coaching observation. Safety-II informed: Work-as-Done, testable hypotheses. |
| `cb-retro` | `/cb-retro` | Adds or updates retro actions in RETRO_ACTIONS.md. Supports single entry, status updates, and bulk paste extraction. |
| `cb-snapshot` | `/cb-snapshot` | Writes a dated Jira board snapshot: WIP, Progress (14d), Runway, Waiting. Requires Jira connector. |

## Setup

1. Install this plugin in Cowork
2. For `cb-snapshot`: connect Jira via the Atlassian connector and run `/cb-init --slug <your-team-slug>` to configure your board

## Usage

Start any coaching conversation with `/coach-buddy`. Use `/cb-init` once per new engagement to create the folder structure, then `/cb-log` and `/cb-retro` to track observations and actions as the engagement progresses.

`cb-snapshot` is team-specific — it reads from whatever Jira project you configure in your engagement's `config.json`.

## Requirements

- Cowork with Jira/Atlassian connector (for `cb-snapshot` only)
- A workspace folder selected in Cowork (for all file-writing skills)

## Version

1.7.0 — see [CHANGELOG](https://github.com/danjmfox-ovo/coach-buddy/blob/main/CHANGELOG.md) for history.
