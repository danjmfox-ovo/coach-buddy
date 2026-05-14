# Board Snapshot Interpretation Guide

## What the snapshot is

A `/cb-snapshot` file is a structured picture of the team's work state at a point in time. It is not a management report — it is coaching evidence. The difference matters: a management report answers "are we on track?"; coaching evidence asks "what does this pattern tell us about how work is actually flowing?"

The snapshot is Work-as-Done data. The board reflects what people are actually attending to, not what the process says they should be attending to.

---

## The four sections

### WIP — In Progress

What the team is working on right now. This is the most information-dense section for coaching.

**What to look for:**

- **Volume**: how many items are in flight? High WIP is a systemic signal, not a personal one. It often means the team is absorbing interruptions, has poorly sized work, or is operating under pull-from-multiple-directions pressure.
- **Age flags** (⚠): items beyond the configured threshold (default: 5 business days) are flagged. An aged item is not necessarily a problem — but it is a question. Is it blocked? Deprioritised? Carrying hidden complexity? The flag surfaces it for the coaching conversation.
- **Concentration**: are items clustered under one or two people? Concentration can signal a bottleneck, a hero pattern, or a specialist dependency.
- **Hierarchy gaps**: items with no parent (orphaned stories) may indicate work that emerged outside the planning process.

### Progress — Last 14 days

What has been completed recently. Use this to understand throughput and to calibrate the WIP picture.

**What to look for:**

- **Throughput vs. WIP ratio**: if WIP is high but Progress is low, the team is accumulating work faster than completing it.
- **Story size patterns**: lots of very small completions can mask that large, risky items are aging in WIP. Very few completions can mean work is too large.
- **Gaps**: if Progress is empty or sparse, something is blocking completion — not individual stories but the flow itself.

### Runway — Ready / Refinement

Work that is ready to be picked up or is being refined. This is the team's near-term capacity buffer.

**What to look for:**

- **Depth**: a thin runway is a delivery risk (the team will run out of refined work). A very deep runway may mean refinement is outpacing delivery, or that items are aging before they're started.
- **Alignment with WIP**: do the Runway items continue the themes in WIP? A disconnect may mean planning and delivery are not in sync.

### Waiting — Backlog

Items not yet in a sprint or active cycle. Use sparingly in coaching — the backlog is often a management concern, not a coaching one.

**Where it is useful**: if a coaching theme is about what the team is not doing, or about stakeholder pressure from items that keep getting deprioritised, the backlog section surfaces that.

---

## How to use the snapshot in a coaching conversation

The snapshot is context, not the subject. Bring it to a `/coach-buddy` conversation as grounding, not as an agenda.

**Framing that works:**

```
/coach-buddy The snapshot is showing 9 items in WIP, 3 of them age-flagged. 
Throughput last 14 days: 4 stories. I'm preparing for a 1:1 with the lead developer 
and want to think through what might be driving the WIP pattern before I go in.
```

**Framing that doesn't:**

```
/coach-buddy Analyse this board data and tell me what's wrong with the team.
```

The first uses the snapshot as evidence for a coaching situation. The second turns it into a ticket audit.

---

## What the snapshot cannot tell you

- Why items are in the state they're in — the data shows what, not why
- Whether the age flags are actual problems or intentional deprioritisation
- Whether the throughput is good or bad without a baseline
- Anything about team dynamics, motivation, or capability

These are coaching questions. The snapshot surfaces the questions; the conversation explores them.

---

## Keeping it current

Run `/cb-snapshot` before significant coaching conversations — not on a fixed schedule. The value is in having a current picture when you need it, not in having a comprehensive history. Once a week before a coaching session is a reasonable default; daily is probably noise.

The snapshot file is dated (`YYYY-MM-DD-board.md`) so older snapshots remain readable if you want to compare across time.
