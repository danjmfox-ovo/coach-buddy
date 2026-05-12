# ADR-008: Portable Install — Two-Layer Model and Minimal Install Behaviour

**Status**: Accepted
**Date**: 2026-05-12
**Scope**: Slice 03 (coach-buddy-slice-03) — portable deployment into team projects
**Supersedes**: None. Extends ADR-006 (portable install is one realisation of the Cutler-pattern's deployment seam).

---

## Context

Coach Buddy was initially designed for a dedicated Claude Chat Project (Slices 01-02). Two jobs validated in real use pointed toward portable deployment:

- **J3 (in-context-activation)**: The coach wants to invoke thinking-partner support while still looking at the artefacts that triggered the thought — not after switching to a separate project and reconstructing the situation from memory.
- **J5 (portable-across-teams)**: The coach wants to add coaching capability to any team project with minimal setup — one install, any project.

Installing SKILL.md as the team project's custom instructions creates a problem: SKILL.md activates the full thinking-partner pipeline for every message. This is appropriate in a dedicated coaching project but intrusive in a team project where other people are working on different tasks.

A second constraint: the coach may not upload the full reference file library (`references/frameworks/`, `assets/`) when installing into a team project. SKILL.md must remain useful without those files.

---

## Decision

### Layer 1: `custom-instructions.md` as Custom Instructions (always-on, lean)

Install `custom-instructions.md` into the team project's Custom Instructions field. This layer:
- Establishes the coaching sensibility (Theory Y stance, attribution rule, concise language) as the project's ambient orientation
- Does NOT activate the full SKILL.md pipeline
- Includes a visible hint: "Type `/coach-buddy` to activate the full thinking-partner pipeline"
- Is safe for all project participants — its influence is subtle and non-intrusive

### Layer 2: `SKILL.md` as Project Knowledge (invocable, full pipeline)

Upload `SKILL.md` to the team project as a Project Knowledge file. This layer:
- Contains the full thinking-partner pipeline (opening protocol, mode management, attribution, Phase A/B delivery)
- Activates only when the coach explicitly types `/coach-buddy` in a message
- Is self-sufficient — reference files enrich it but are not required

### Install Procedure

Exactly two steps, documented in `README.md` under "Claude Chat Project — team project":
1. Paste `custom-instructions.md` contents into Custom Instructions
2. Upload `SKILL.md` as Project Knowledge

Reference files (`references/frameworks/`, `assets/`) are optional. Their absence is the minimal install.

---

## Minimal Install Behaviour (Graceful Degradation Quality Bar)

SKILL.md's `## Frameworks` section contains built-in descriptions of six primary lenses and nine secondary lenses. These are sufficient for reliably useful coaching without external reference files.

**Quality bar for minimal install** (SKILL.md without reference files):

| Criterion | Expectation | Failure |
|-----------|-------------|---------|
| Situation grounding | Names at least one symptom or dynamic beyond restating the coach's description | Mere paraphrase of coach's words |
| Framework attribution | Includes at least one `Name (Source)` attribution from the primary lens list | No attribution, or attribution not in SKILL.md lens lists |
| Thinking advancement | Offers at least one question that advances the coach's thinking | Only statements, no question |
| Self-sufficiency | Does NOT surface an error, degraded-mode warning, or "I cannot help without reference files" | Breaks if reference files are absent |
| Attribution integrity | All attributions drawn from SKILL.md primary/secondary lens lists | Hallucinated citations not in SKILL.md |

**Degradation characterisation**: A minimal install is "reliably sharp" — better than thinking through the situation alone, useful for situation-focus work. It may be less deep on specific framework detail than a full install. This is expected and acceptable.

**This bar is encoded in SKILL.md** under `## Minimal install behaviour` so the coach can inspect it without reading this ADR.

---

## Alternatives Considered

### Alternative A: SKILL.md as Custom Instructions (always-on, full pipeline)

Place SKILL.md in Custom Instructions directly. The full pipeline activates for every message.

**Why rejected**: Intrusive in a team project context. Non-coach team members receive thinking-partner preambles, mode management prompts, and calibration questions for ordinary work messages. Breaks the ambient UX of the team project.

### Alternative B: Two separate projects (one dedicated, one team)

Coach maintains a dedicated coaching project alongside each team project. Switches between them as needed.

**Why rejected**: This is the status quo J3 seeks to replace. Context-switching cost is the exact problem being solved. Maintaining two projects per engagement doesn't scale (J5).

### Alternative C: Custom `/coach-buddy` slash command file

Write a Claude Code–style skill file that activates the pipeline. Available in Claude Code and Cursor but not in Claude Chat Projects without the CLI.

**Why not yet**: Claude Chat Projects don't support slash commands natively. The `/coach-buddy` prefix is a convention that works because SKILL.md is in Project Knowledge and the model reads it when the name is invoked in the message. This is a soft activation, not a registered command. Revisit if Claude Chat Projects add native slash command support.

---

## Consequences

**Positive**:
- Two-step install matches J5's "single install step" aspiration (two steps is the minimum given current Claude Chat Project constraints)
- Lean always-on layer adds value without requiring the coach to explicitly activate the tool
- Self-sufficient SKILL.md means partial deploys are predictably useful, not unpredictably broken

**Negative / Watch items**:
- Two files to manage per install — risk of version drift between `custom-instructions.md` and `SKILL.md` in the wild; no automated sync available in Chat Projects. Mitigation: both files carry a `# version:` comment at the top; coaches should match versions when updating.
- Discovery depends on the inline hint in `custom-instructions.md` — coaches who paste custom instructions without reading may miss `/coach-buddy`; monitor if usage data suggests discoverability is a problem (D9)
- SKILL.md as Project Knowledge is not access-controlled — any project participant can read it; intentional (transparency principle, ADR-001) but worth noting

### Keeping your install current

When a new version of Coach Buddy is released:
1. Check the `version:` frontmatter in `SKILL.md` (e.g. `version: 1.6`)
2. Check the `# version:` comment at the top of `custom-instructions.md`
3. If they differ, re-upload the newer `SKILL.md` to Project Knowledge **and** update the Custom Instructions field with the new `custom-instructions.md` in the same session
4. Start a fresh conversation after updating

Partial updates (SKILL.md without `custom-instructions.md`, or vice versa) are the primary version drift risk — the two layers may encode conflicting attribution or language rules.

### Post-deployment watch items (30-day review)

Track after Slice 03 validation runs:
- **Adoption rate**: How many coaches use the portable install vs. the dedicated coaching project?
- **Minimal-install quality signals**: Do coaches using minimal install (no reference files) rate conversations as "Better" or "Much better"?
- **Version drift incidents**: Any reports of coaching sensibility mismatch between `custom-instructions.md` and `SKILL.md`?
- **Discoverability**: Do coaches find `/coach-buddy` without being told? Log any "how do I activate the full pipeline?" questions.
- **30-day decision point**: If minimal-install self-report falls below "Better" in >50% of sessions, escalate degradation quality bar (D8) and consider richer built-in lens descriptions in SKILL.md.

---

## References

- ADR-001: Explicit orchestration over implicit (why SKILL.md is visible and inspectable)
- ADR-006: Cutler-pattern upgrade seam (portable install is a deployment realisation, not a pattern change)
- `README.md`: Install procedure documentation
- `custom-instructions.md`: Lean always-on layer implementation
- `docs/product/jobs.yaml`: J3 (in-context-activation) and J5 (portable-across-teams) job stories
