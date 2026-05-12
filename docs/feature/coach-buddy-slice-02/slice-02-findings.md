# Slice 02 Trial Findings

## Slice 02 trial verdict — 2026-05-12

**Status: DONE.**

Scenarios 1, 2, 4, 5 run against v1.6 SKILL.md. Scenario 3 (decline offer) not run — called on strength of passing scenarios.

### Passing
- ER-004 fix held: "Psychological safety (Edmondson)" attributed correctly on first mention
- ER-005 fix held: active explicit question delivered deep-dive directly; no offer gate friction
- Scenario 2: situated deep-dive structure followed (what it is / how it applies / practical implication / return to Phase A); situationally grounded throughout
- Scenario 4: mode redirect fired at correct moment, no tool-specific language (prompted phrase-set-to-examples change)
- Scenario 5: ambiguity check fired correctly; D4 three-condition gate held

### New emerged requirements (fixed in v1.5 / v1.6)
- ER-005: active-question exemption added to offer gate (v1.5)
- ER-006: two-question within-turn rule tightened (v1.5)
- Redirect phrase set changed from exhaustive to illustrative examples (v1.6)
- "Both signals in the same message" / "I'm detecting two signals" added to prohibited phrase list (v1.6)

### Watch items (not yet ERs)
- Minor format slip: "Shorrock's work on work layers" in one turn — spec is `Four work layers (Shorrock)`. Inverted attribution. Monitor.
- Re-attribution of Psychological Safety (Edmondson) in one turn — attributed twice in same conversation. Monitor.
- ER-006 pattern (two questions in one turn) reduced but not eliminated — Turn 3 of one trial still had two questions. Monitor.
- Deep-dive part 2 slightly over 2-3 sentence spec — 4 sentences, all grounded. Monitor.

### Scenario 3 (decline) — not run
Called on strength of passing scenarios. The continue-without-friction behaviour would be exercised naturally in Slice 03 J3 validation (portable install), where stakes are lower.

### Slice 03 unblocked
J3 validation: install `/coach-buddy` into a real team project and run a live conversation. Tests portable install, graceful degradation without reference files, and `/coach-buddy` invocation pattern.

---

## ER-005 — Active-question exemption for deep-dive offer gate

**Emerged from**: Scenario 1 trial (2026-05-12)
**Type**: SKILL.md wording gap — rule too broad
**Fix version**: v1.5

### Observation
Coach asked directly: "What is it about psychological safety that makes it so hard to rebuild?" Tool answered directly without the offer gate ("I can go deeper... just say the word"). This is correct behaviour — but the SKILL.md rule ("do not auto-deliver") doesn't distinguish passive from active signals, implying the offer gate should have fired.

### Root cause
"Offer, don't auto-deliver" was designed for passive interest signals (double-mention, vocabulary adoption, topic revisit), where the coach hasn't asked for anything. An explicit question IS the request — inserting an offer gate there creates friction: "Would you like me to explain what you just asked me to explain?"

### Fix
Add an exemption in the Attribution section: when the coach directly asks a question about a named framework ("what is it about X...?", "how does X work?", "tell me about X"), treat the question as acceptance and deliver the situated deep-dive directly. The offer gate applies to passive signals only.

---

## ER-006 — Two questions in a single turn after multi-hypothesis responses

**Emerged from**: Scenario 1 trial, turn 1 (2026-05-12) — and watch-listed from Slice 01 trial
**Type**: Persistent language/style violation
**Fix version**: v1.5

### Observation
After listing multiple hypotheses (grief/shock, safety erosion, rational disengagement), the tool ended with two questions: "How recent is the reorg...? And do you have a read on whether people are quiet because they don't feel safe, or because they don't know what to contribute to yet?"

This pattern has appeared in Slice 01 and Slice 02 testing. The Language and style rule ("ask one sharp question, not several") is not being applied within a turn.

### Root cause
The existing rule "Never ask two questions in succession without synthesis between them" (Delivery section) governs across turns, not within a turn. The single-question rule in Language and style ("Ask one sharp question, not several") exists but isn't specific enough to catch the pattern: generating multiple hypotheses → feeling uncertain which matters → asking two questions to "cover both".

### Fix
Tighten the Language and style rule to be explicit about the within-turn case: after offering multiple hypotheses, choose ONE question. If uncertain which question matters most, resolve that internally — the uncertainty is a signal to pick the sharper hypothesis, not to ask twice.
