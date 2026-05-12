# Slice 01 Validation Findings and Emerged Architecture

---

## Slice 01 trial verdict — 2026-05-12

**Status: DONE.** Walking skeleton acceptance criteria met.

Real conversation run against v1.1 then v1.2 SKILL.md in the dedicated coaching project. 10 acceptance scenarios evaluated manually against `tests/acceptance/coach-buddy-architecture/walking-skeleton.feature`.

### Passing
- ER-001 fix held: conversation did not get stuck in calibration loop; no explicit transition phrase required in practice (natural flow resolved it)
- ER-002 fix held: tool opened with observation on first turn, not question; observation-before-question held through diagnostic phase
- No unrequested frameworks introduced across 12 turns
- Coach completed full thinking-through in one conversation
- High-stakes tiebreaker not triggered (low-stakes conversation); D5 not tested in this run
- DNA arc (v1.2): D-phase behaviour strong; A-phase synthesis rule not yet tested end-to-end

### New emerged requirements

**ER-003** — fixed in v1.2 before trial concluded
Action-planning phase used D-phase behaviour (question after every coach answer). Fixed by DNA arc + A-phase synthesis rule (ADR-007). Logged in CHANGELOG v1.2.

**ER-004** — open, added to walking skeleton as regression guard
Framework vocabulary ("psychological safety") used in three consecutive turns without attribution. Attribution rule (ADR-002) requires `Name (Author)` on first mention regardless of whether the term is used as formal framework or common vocabulary. Scenario added to `walking-skeleton.feature`.

### Two-question tendency — watch item, not yet a numbered ER
Long diagnostic responses ending with two questions appeared twice (turns 1 and 3 of the v1.2 session). The individual-turn rule (one sharp question) is being violated at the end of multi-hypothesis responses. May warrant a SKILL.md tightening if it recurs in Slice 02 testing.

### Slice 02 unblocked
All Slice 01 acceptance criteria met. Slice 02 scope: interest detection (D2), deep-dive on request, mode management redirects, DNA N-phase behaviour. Start with a fresh DISCUSS wave.

---

## Emerged architectural direction — Slice 03

**Mental model shift** (emerged from real use): Coach Buddy is not a dedicated coaching project. It is a coaching lens invocable across any team project via `/coach-buddy`. Each team has their own project with its own context and files; `/coach-buddy` drops in as a thinking-partner layer.

**Implication**: SKILL.md must be self-sufficient without reference files. Framework knowledge either travels inline or degrades gracefully when reference files aren't present. The reference files are an enrichment layer, not a dependency.

**Architecture target (Slice 03)**:
- `custom-instructions.md` — lean always-on layer for a dedicated project (optional; not present in team projects)
- `SKILL.md` — self-contained invocable skill; works in any project
- `references/frameworks/` — depth layer; enriches when present
- `assets/` — calibration canvas, output template; enriches when present
- `README.md` — install instructions (Claude Chat Project, Claude Code, Cursor)
- Distributable via `npx skills add danjmfox-ovo/coach-buddy`

**Open decisions for Slice 03**:
- How much framework knowledge to embed inline in SKILL.md vs rely on reference files?
- Should the skill detect whether reference files are present and adjust behaviour?
- CHANGELOG.md before publishing (v1.1 becomes a public interface)

---



## ER-002 — Tool withholds domain knowledge pending calibration

**Emerged from**: comparison of old vs new SKILL.md on the same starting prompt
**Type**: Spec gap (pattern wrong, not just count)
**Candidate for**: v1.1 / Slice 01.1
**Supersedes the root cause in ER-001** (ER-001's turn-limit fix is still valid but treats a symptom)

### Observation
The new Buddy extracts context before synthesising. It asks role, then stakes, then planning state — all before offering any observation from its domain knowledge. The old Buddy led with observation + one calibrating question simultaneously. The coach felt held from the first response; with the new Buddy they felt interrogated.

### The pattern that worked (old Buddy)
1. Disclaimer
2. Ask role question AND offer domain analysis in the same response
3. One follow-on question to deepen

### The pattern that doesn't (new Buddy)
1. Meta-question (mode)
2. Role question → wait
3. Stakes question → wait
4. Planning question → wait
5. ...synthesis eventually

### Proposed fix
After the coach's initial description, the tool should offer **one observation or hypothesis drawn from domain knowledge**, then ask **one calibrating question** — not ask and wait and ask again.

The rule: never ask a second question without having offered something first. Each tool turn should contain synthesis or observation AND at most one question. The questions don't have to stop — they just have to be earned.

### SKILL.md change required
Add to Delivery section (or Opening Protocol):

- After the initial description, reflect back at least one observation before asking anything
- Each subsequent turn: offer a read + ask one question. Never two questions in a row without synthesis between them.
- Calibration is not a phase to get through before the work starts — it IS the work

### ADR impact
None. SKILL.md authoring gap only.

---

## ER-001 — Calibration loop has no exit condition

**Emerged from**: first real conversation with Slice 01 SKILL.md
**Type**: Spec gap (behaviour not wrong, but incomplete)
**Candidate for**: v1.1 / Slice 01.1

### Observation
The tool asked significantly more questions than the previous system prompt before entering thinking-partner mode. The opening protocol captures mode/context/stakes but gives no signal to the coach about when calibration ends and partnership begins. The conversation can feel like it will never resolve into useful work.

### Proposed fix (already validated in-conversation)
After 3–4 calibration exchanges, transition explicitly:

> "I think I have enough to work with — let me reflect back what I'm hearing."

Then move into Phase A. Let the coach redirect if more calibration is needed — pull, not push.

### SKILL.md change required
Add to the Opening protocol section:

- Maximum 3–4 calibration turns before transitioning to Phase A
- Transition phrase signals the shift and summarises what was understood
- Coach can redirect ("actually, one more thing") without the tool resuming extraction

### ADR impact
None. This is a SKILL.md authoring gap, not an architectural decision. No ADRs need updating.

### DoR for v1.1
- [ ] SKILL.md updated with calibration turn limit and transition phrase
- [ ] Tested: conversation moves into Phase A within 4 turns on a cold open
- [ ] Tested: coach can add calibration after the transition without triggering re-extraction loop
