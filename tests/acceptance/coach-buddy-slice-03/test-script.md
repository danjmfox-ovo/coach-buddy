# Slice 03 Manual Test Script
# Install Coach Buddy in a real team project per README "Claude Chat Project — team project" path before running.
# Use a real team project you are actively working in (not a test project).
# Start a fresh session for each numbered scenario.
# Record timestamps and self-report notes in the test log.

---

## Pre-run install check (Slice 03a — Story 1)

**Time from README open to first /coach-buddy response: __________ minutes**
Pass criterion: ≤10 minutes

1. Open README.md. Navigate to "Claude Chat Project — team project" section.
2. Paste `custom-instructions.md` contents into Custom Instructions. Note the time.
3. Upload `SKILL.md` as Project Knowledge.
4. (Optional) Upload reference files if testing full install for Scenarios 1-3.
5. Send a message NOT beginning with /coach-buddy. Check lean layer is active (Theory Y stance, no opening protocol, no disclaimer).
6. Type `/coach-buddy hello` or `/coach-buddy` followed by a brief description. Confirm full pipeline activates (disclaimer, observation, one calibrating question).

Pass: ≤2 steps, ≤10 minutes, lean layer and full pipeline both behave as expected.
Fail: document which step failed and what happened.

---

## Scenario 1 — Full coaching conversation in team project context (Story 2, Slice 03b)

**Setup**: Full install (with reference files). Fresh session.

**Paste message 1:**
> /coach-buddy I've been working with a team for six months. Technically they're delivering — velocity is stable, sprints are completing. But something feels off. People go quiet in retros. The tech lead does most of the talking. I'm not sure if this is a leadership dynamic I should surface or a morale issue that will self-resolve.

Check:
- [ ] Response opens with the SKILL.md disclaimer or equivalent (first response only)
- [ ] Response names at least one symptom or dynamic from the description (not just paraphrase)
- [ ] Response asks exactly one calibrating question — not mode, context, and stakes all at once
- [ ] Response does NOT introduce a named framework unprompted
- [ ] Response does NOT ask two questions before offering something

**Paste message 2:**
> I think stakes are medium — we have a quarterly review next month but nothing is on fire yet. My instinct is the silence is protective, not lazy.

Check:
- [ ] Tool acknowledges the stakes framing
- [ ] Tool offers something (observation, hypothesis) before asking again
- [ ] Tool does NOT re-ask for calibration signals already given

**Paste message 3:**
> What might explain why the team is deferring to the tech lead even when they have something to say?

Check:
- [ ] Tool names a plausible dynamic (e.g. status/power, trust deficit, role confusion) without over-confidently diagnosing
- [ ] If a framework is used, it is attributed on first mention: "Name (Source)"
- [ ] Tool offers a question that advances the coach's thinking toward an intervention
- [ ] Response stays in situation-focus (no unprompted framework taxonomy)

**Post-conversation self-report:**
Record: what was most useful? what was missing or off? Would you use this in a real engagement?

Pass criterion: coach articulates at least one insight; does not describe the conversation as "broken", "confusing", or "worse than thinking alone".

---

## Scenario 2 — In-context activation with team artefacts (Story 2, Slice 03b)

**Setup**: Full install. Use a real conversation context that includes team project knowledge (sprint board description, decision doc, retro notes).

**Paste message 1** (reference a real artefact from the team project):
> /coach-buddy Looking at the sprint board — we've got 14 stories in progress, 3 developers on the team, and cycle time has doubled in the last two sprints. The team's explanation in standup is "things are complex". I'm not sure I'm buying it.

Check:
- [ ] Tool responds to the coaching situation, not the metrics as a technical problem
- [ ] Tool names a dynamic (e.g. WIP accumulation, uncertainty avoidance, sensemaking gap) rather than just agreeing with the observation
- [ ] Tool does NOT analyse the sprint board as a product manager would ("you should limit WIP to...")
- [ ] Tool does NOT confuse team-specific artefact language with coaching frameworks

**Paste message 2:**
> What would you want to know next about this team?

Check:
- [ ] Tool asks a question that would help the coach understand the team dynamics better
- [ ] Question is specific to the situation described, not generic

Pass criterion: tool treats the sprint board as context for understanding a coaching situation, not as a technical problem to solve.

---

## Scenario 3 — Graceful degradation in minimal install (Story 3, Slice 03c)

**Setup**: Minimal install (custom-instructions.md + SKILL.md only, NO reference files uploaded). Fresh session.

**Paste message 1** (use a real situation from your current coaching work):
> /coach-buddy [paste a real situation you're working with — 2-4 sentences describing what you're observing and what you're unsure about]

Check:
- [ ] Response names at least one symptom or dynamic beyond restating your words
- [ ] Response includes at least one attribution in "Name (Source)" format matching SKILL.md primary lenses (Cynefin/Snowden, Team Topologies/Skelton-Pais, Psychological Safety/Edmondson, etc.)
- [ ] Response asks at least one question that advances your thinking
- [ ] Response does NOT say "I cannot help without reference files" or equivalent
- [ ] Response does NOT suggest the tool is operating in a reduced mode
- [ ] Response does NOT recommend uploading reference files

**Paste message 2** (continue the conversation):
> That's interesting — say more about [pick the most relevant dynamic named in the response]

Check:
- [ ] Tool goes deeper on the named dynamic without introducing generic framework content
- [ ] If a framework deep-dive occurs, the attribution is consistent (second mention doesn't re-attribute)

**Paste message 3** (advance toward action):
> What would you want me to notice or test before our next session with this team?

Check:
- [ ] Tool suggests a concrete observation or experiment
- [ ] Suggestion is grounded in the specific situation described, not generic coaching advice

**Post-conversation self-report:**
Rate the conversation compared to thinking through the situation alone:
- [ ] Much better — I got insights I wouldn't have reached alone
- [ ] Better — useful reframe or question
- [ ] About the same — no real value-add
- [ ] Worse — confused or misleading

**Attribution audit**: List every "Name (Source)" attribution that appeared. Check each against SKILL.md primary/secondary lens list. Flag any that aren't in the list.

Pass criterion:
- Self-report = "Better" or "Much better"
- All attributions are from SKILL.md lens list
- No error messages or degraded-mode warnings in any turn

---

## Regression guards (apply in team project context)

### Regression: ER-001 (calibration loop) — team project variant

Paste 3 messages that each answer one calibrating question without offering an exit signal.

Check:
- [ ] After 3 exchanges, tool transitions to reflection: "let me reflect back what I'm hearing" or equivalent
- [ ] Tool does NOT ask a fourth calibrating question without synthesis first

### Regression: ER-002 (observation before question) — team project variant

Paste any /coach-buddy message with a 2+ sentence situation description.

Check:
- [ ] First substantive content is an observation, not a question
- [ ] No two questions in sequence without synthesis between them

### Regression: ER-004 (vocabulary attribution) — team project via /coach-buddy

In a /coach-buddy conversation, let the tool use "psychological safety", "Cynefin", or "polarity thinking" in any context.

Check:
- [ ] First use carries attribution regardless of whether it's introduced as a framework or used in passing
- [ ] "(Edmondson)" / "(Snowden)" / "(Johnson)" on first use

---

## Pass criteria

Scenario 1: coach self-report passes + all checklist items met
Scenario 2: tool treats sprint data as coaching context, not technical problem
Scenario 3: minimal-install self-report "Better" or "Much better" + zero non-SKILL.md attributions + no error messages

All regressions pass when every checked item is met.

Log any failures as candidate ER-007+ with:
- Which scenario and step
- What the tool did
- What it should have done
- Whether this is new or a recurrence of a prior ER
