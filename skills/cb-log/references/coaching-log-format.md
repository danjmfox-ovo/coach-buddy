# Coaching Log Format — Safety-II Rationale

## Why Safety-II

Safety-II (Hollnagel) inverts the usual lens. Rather than asking "what went wrong?" it asks "what makes things go right, and what does that look like in practice?" The central move is shifting from Work-as-Imagined (what should happen, what the process says) to Work-as-Done (what actually happens).

For coaching logs, this matters because:

- **Most coaching conversations start from symptoms** — things that feel off, behaviour that surprises. Safety-II asks: what is this behaviour optimising for? It is not a failure of the process; it is an adaptation to a system. Understanding the adaptation is the diagnostic work.
- **Hypotheses should be testable** — "the team is disengaged" is a judgement that forecloses enquiry. "If the underlying pressure doesn't change, engagement will continue to drop" is a hypothesis that has a test and a time horizon.
- **Interventions should be named and tracked** — a coaching intervention is a bet. Naming it makes the bet legible. Tracking it across sessions reveals whether the bet paid off.

---

## The six fields

### Observed

What you saw or heard — Work-as-Done framing. Describe the specific behaviour, exchange, or moment. Avoid interpretation at this stage.

Good: "In the retro, three people offered process-level actions. No one named a dynamic or asked why the pattern had recurred."

Less useful: "The team avoided the real issue again."

The first describes what happened. The second is already a conclusion.

### Context

Where and when this happened. The ceremony, conversation, or artefact that was the setting. This matters because the same behaviour can mean different things in a retro vs. a standup vs. a 1:1.

### Pattern/Signal

A tentative label for what you think you're seeing. The word "tentative" is structural — the field is not a diagnosis but a hypothesis starter. Keep it short.

Examples: "pressure → soldier on", "estimation avoidance", "accountability asymmetry", "proxy escalation".

You will be wrong sometimes. That is fine. The value is in naming the pattern so you can watch for it.

### Hypothesis

Testable If/Then format. The form forces you to be specific about what would confirm or disconfirm your read.

Structure: "If [X continues / changes] then [observable Y will happen]."

Examples:
- "If the estimation ceremony doesn't change, the avoidance pattern will recur next sprint."
- "If the tech lead gets airtime to name the dynamic, the team's retro quality will improve within two cycles."

A hypothesis that can't be disconfirmed isn't a hypothesis — it's a belief. The If/Then format makes the difference visible.

### Intervention

What you did or plan to do. Named interventions make it possible to compare notes with yourself across sessions: did the intervention work? Did a different one work instead?

Leave as "(none yet)" if you're still watching before acting. That is a valid coaching choice, not a gap.

### Follow-up

What you will watch for. The question you're holding. The signal that would confirm or disconfirm the hypothesis.

This is what you bring to your next `/cb-snapshot` or `/coach-buddy` session.

---

## Quick capture vs. full entry

Quick capture (Observed + Context only) is the right default for immediately after a session, when you are tired and the detail is still fresh. The other fields can be filled with `/cb-log --update <id> <field> <value>` when you have space to reflect.

A quick capture that gets refined is better than a full entry that never gets written.

---

## Reading the log over time

The log is not a record of problems — it is a record of a coaching arc. Reading it across entries, look for:

- **Recurring patterns**: the same signal appearing in different ceremonies or moments
- **Hypothesis updates**: do your If/Then statements hold up? Which ones were wrong?
- **Intervention feedback**: what did you try? What happened next?
- **Blind spots**: what are you consistently not capturing? What might that mean?

The log does not produce conclusions. It produces better questions.
