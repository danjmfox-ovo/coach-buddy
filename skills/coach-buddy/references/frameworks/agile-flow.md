# Agile and Flow: Scrum, Kanban, Flow Metrics

*Audience: experienced agile coaches. This is not a primer on the basics — it is a coaching reference for pattern recognition and intervention.*

---

## Scrum

**Source**: Schwaber, K. & Sutherland, J. *The Scrum Guide* (2020 edition). scrum.org.

---

### What Scrum is actually for

Scrum is an empirical framework for complex product development. Its mechanisms — Sprint, Sprint Review, Retrospective — are designed to produce inspection and adaptation. It is not a project management methodology and it is not a delivery factory.

**The most common coaching diagnosis**: Organisations adopt the ceremonies without the empiricism. Sprints become two-week mini-waterfalls. Sprint Reviews become progress reports to stakeholders who have already decided what they want. Retrospectives produce action items that nobody acts on. The form is present; the feedback loops are absent.

---

### Scrum events as feedback loops

| Event | Feedback loop it closes | Common failure mode |
|-------|------------------------|-------------------|
| Daily Scrum | Daily impediment identification and re-planning | Status report to the Scrum Master; no replanning |
| Sprint Review | Validation of increment against real need; inspect and adapt | Demo to passive audience; no genuine adaptation |
| Sprint Retrospective | Process improvement and team health | List of actions that evaporate before next Sprint |
| Sprint Planning | Forecast based on actual capacity and understanding | Commitment extracted by management; no genuine planning |
| Sprint itself | Sustainable pace, done work | Overloaded Sprints; "done" means "done enough to demo" |

---

### The three accountabilities

**Product Owner**: Maximises value. Owns the product backlog — ordering, clarity, and honesty about what is worth building. The PO failure mode is becoming a proxy for stakeholders rather than the single decision-making voice for the product.

**Scrum Master**: Ensures Scrum is understood and enacted. Serves the team, the PO, and the organisation. The SM failure mode: meeting facilitator and Jira administrator rather than coaching the team toward self-management and removing structural impediments.

**Developers**: Cross-functional, self-managing professionals who create the increment. The Developers failure mode: treating the Sprint as a list of tasks rather than a commitment to a goal; functional silos reforming within the team boundary.

---

### The Sprint Goal

The most underused element of Scrum. A Sprint Goal is a single objective for the Sprint that provides coherence and flexibility. Without it, a Sprint is a list of tasks; with it, it is an answer to "why are we doing this Sprint?"

**Coaching application**: If a team cannot articulate what they are trying to achieve in the Sprint beyond "complete the tickets," they do not have a Sprint Goal. This is a PO and planning failure. A team with a clear goal can replan mid-Sprint if circumstances change; a team without one cannot.

---

### Definition of Done

A shared, transparent, non-negotiable standard that defines when work is complete. The key word is "non-negotiable" — done is done, regardless of time pressure.

**The coaching pattern**: Teams that don't have a strong DoD accumulate undone work, technical debt, and unstable increments. The Sprint Review then demonstrates working illusions rather than working software. Tightening the DoD is often the highest-leverage intervention available.

---

## Kanban

**Source**: Anderson, D. (2010). *Kanban: Successful Evolutionary Change for Technology Businesses*. Blue Hole Press.
Brechner, E. (2015). *Agile Project Management with Kanban*. Microsoft Press.

---

### What Kanban is

Kanban is a method for managing and improving the flow of work. It starts from where you are — it does not prescribe a specific workflow structure. Its practices create visibility, limit work in progress, and generate data for improvement.

**The six core practices** (Anderson):
1. Visualise the workflow
2. Limit Work in Progress (WIP)
3. Manage flow
4. Make policies explicit
5. Implement feedback loops
6. Improve collaboratively, evolve experimentally

---

### WIP limits: the central mechanism

WIP limits constrain how many items can be in a workflow state at one time. Their purpose is to expose bottlenecks, force completion before starting new work, and reduce multi-tasking.

**The resistance pattern**: Teams resist WIP limits because limiting WIP feels like slowing down. The counterintuitive truth: WIP limits speed up delivery by reducing context-switching and queue time. If work is waiting at a constrained stage, WIP limits surface that — and that is the point.

**Coaching application**: When a team introduces WIP limits and "everything stops," they have not broken their system — they have revealed it. The blocked work is the signal. The question is: what is the root cause of the constraint?

---

### Flow metrics

Four metrics that describe the behaviour of a Kanban system:

| Metric | Definition | What it tells you |
|--------|-----------|------------------|
| **Throughput** | Number of items completed per unit of time | System capacity; whether the team is improving |
| **Cycle time** | Elapsed time from start to completion for one item | How long individual items take; predictability |
| **Work in Progress** | Count of items currently active | System loading; relationship to cycle time |
| **Work item age** | How long an active item has been in the system | Ageing work; early warning of items at risk |

**Little's Law**: `Average Cycle Time = Average WIP ÷ Average Throughput`. The relationship is mathematical, not a management target. If you know two values, you can calculate the third. If you want to reduce cycle time, reduce WIP or increase throughput.

---

### Cumulative Flow Diagram (CFD)

A stacked area chart showing the count of items in each workflow state over time. Reveals:

- **Expanding bands**: accumulation in a state — a bottleneck
- **Parallel lines**: smooth flow
- **Flat top line**: no items completing — blocked
- **Narrowing**: throughput exceeding input (healthy release or concern about future demand)

**Coaching use**: A CFD makes the system behaviour visible over time. Teams that argue about whether they are improving can look at the CFD and have a facts-based conversation. The coach's role is often to help the team read what they see rather than to interpret it for them.

---

### Scrum vs Kanban: not a choice

Experienced coaches know this is a false dichotomy. Scrum provides cadence and accountability events; Kanban provides flow visibility and WIP discipline. The Scrumban pattern — Scrum ceremonies with Kanban-style visualisation and WIP limits — is common and often more effective than either in pure form. The question is always: what does this team need to see and regulate in order to improve?

---

## Flow Metrics in Practice: Coaching Applications

**When cycle time is high and variable**:
- Look at WIP: likely too high
- Look at blocked items: what are the chronic blockers?
- Look at item size: large items create variable cycle times. Split stories earlier.

**When throughput is low and not improving**:
- Look at what completed items look like: is DoD quality causing rework?
- Look at planning: are items entering the workflow without enough clarity to be actionable?
- Look at team stability: context-switching at the person level undermines system throughput

**When WIP is low but cycle time is still high**:
- Likely a waiting / dependency problem, not a capacity problem
- Map the workflow in more detail: where do items wait for people or systems outside the team?

**When metrics look fine but the team feels bad**:
- Metrics measure the work system; they don't measure psychological safety, sustainable pace, or team health
- A team producing steadily with eroding morale is drawing down a reserve. Metrics won't show this until it's too late.

---

## The Agile Coach Trap

The most common experienced-coach failure pattern: becoming a framework enforcer rather than a system observer. Scrum and Kanban are instruments for learning, not destinations. A team that has internalised the feedback loops and is continuously improving — even if their ceremonies look unusual — is more agile than a team following the Scrum Guide to the letter with no capacity for self-correction.

**The calibration question**: Is the team's practice generating useful information and acting on it? If yes, the form matters less than the coach thinks. If no, the form is not the problem.
