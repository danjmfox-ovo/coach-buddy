# Slice 02 Manual Test Script
# Install v1.4 SKILL.md as custom instructions before running.
# Start a fresh session for each numbered scenario.

---

## Scenario 1 — Interest signal fires; offer includes attribution; no auto-deliver

**Paste message 1:**
> My team are going through a difficult period after a reorg. People are pulling back, not contributing in retros, doing the minimum. I think there's something going on with trust.

Check:
- [ ] Tool opens with observation, not question
- [ ] No framework named with attribution yet

**Paste message 2:**
> I'm not sure whether to address the trust issue directly or wait for it to resolve. The psychological safety in the team feels low.

Check:
- [ ] Tool has not attributed "psychological safety" yet in this session — it should attribute on this turn: "(Edmondson)"
- [ ] If tool detects the double-signal (trust + psychological safety), it may offer a deep-dive: "I can go deeper on Psychological Safety (Edmondson) if that would be useful — just say the word"
- [ ] If not yet — paste one more message that references it again and the offer should fire

**Paste message 3 (if offer not yet fired):**
> What is it about psychological safety that makes it so hard to rebuild?

Check:
- [ ] Offer fires: "I can go deeper on [Psychological Safety (Edmondson)] if that would be useful"
- [ ] Tool does NOT auto-deliver a deep-dive — it waits
- [ ] Tool continues with a substantive response before or alongside the offer

---

## Scenario 2 — Accept the deep-dive; response is situated; returns to Phase A

Run Scenario 1 through to the offer firing, then:

**Paste:**
> Yes, go deeper.

Check:
- [ ] Response opens with what it is — one sentence
- [ ] Response explains how it applies to THIS situation (reorg, withdrawal, retros) — not a generic summary
- [ ] Response ends with one practical implication for the coach's next move
- [ ] Tool returns to Phase A: "What's your read on that?" or equivalent
- [ ] No additional unrequested frameworks introduced in the deep-dive

---

## Scenario 3 — Decline the offer; conversation continues without friction

Run Scenario 1 through to the offer firing, then:

**Paste:**
> No thanks, let's stay with the situation.

Check:
- [ ] Conversation continues in current thread without re-prompting the offer
- [ ] Tool does not re-offer Psychological Safety in the same conversation
- [ ] Next response contains observation or question relevant to the situation, not the framework

---

## Scenario 4 — Mode redirect fires at turn boundary using coaching language only

**Paste message 1:**
> I've got a team retro tomorrow and I'm worried it's going to go badly. Last time someone walked out. I want to think about how to open it differently.

**Paste message 2:**
> Actually, I've been thinking — what's the best way to learn more about facilitation in general? Are there books you'd recommend?

Check:
- [ ] Tool detects the topic shift (specific retro → general learning interest)
- [ ] Tool fires a redirect using one of the four registered phrases only:
  - "What do you want to achieve here today?"
  - "Is this the real topic?"
  - "What would be most useful right now?"
  - "Where do you want to focus?"
- [ ] Redirect does NOT use: "I notice we've shifted topics", "switching modes", or any tool-specific language
- [ ] Redirect fires as a complete turn — not mid-sentence

**Paste message 3:**
> Let's stay with the general question actually.

Check:
- [ ] Tool follows the new thread without re-firing the redirect

---

## Scenario 5 — Ambiguity check fires only when all three conditions are met

**Paste message 1:**
> I've been working with a team that's really struggling with delivery. Stories carry over every sprint, WIP is high, people are stressed.

**Paste message 2 (topic discontinuity, both mode signals):**
> I wonder — is there a framework that helps with this kind of thing? Or maybe I should just think about what the team needs from me tomorrow.

Check:
- [ ] Both signals present: "is there a framework" (learning-mode) + "what the team needs from me tomorrow" (situation-focus)
- [ ] No stakes statement in the conversation
- [ ] Tool asks: "Do you want to stay with [the situation] or pick up [the framework question]?" — or equivalent
- [ ] Tool does NOT pick a mode and proceed silently
- [ ] Question uses coaching language only — no tool-specific framing

---

## Regression: ER-002 (observation before question)

**Paste any situation description of 2+ sentences.**

Check:
- [ ] First substantive content is an observation, not a question
- [ ] No two questions in sequence without synthesis between them

## Regression: ER-004 (vocabulary attribution)

**In any conversation, let the tool use "psychological safety", "Cynefin", or "polarity thinking" naturally.**

Check:
- [ ] First use of any named concept carries attribution, regardless of framing
- [ ] "(Edmondson)" / "(Snowden)" / "(Johnson)" appears on first use

---

## Pass criteria

All scenarios pass when every checked item is met. Log any failures as candidate ER-005+ with:
- Which scenario
- What the tool did
- What it should have done
