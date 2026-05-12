# Slice 01 Validation Findings

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
