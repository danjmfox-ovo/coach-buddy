# Evolution: cb-review-improvements
Date: 2026-05-15 | Version: 1.8.0 | PR: #7

---

## Feature Summary

Triage and delivery of improvements to the coach-buddy engagement layer, sourced from
an AI reviewer analysis of SKILL.md and the engagement layer skill set. 12 gaps identified;
4 built; 8 deferred or eliminated.

Shipped:
- **`/cb-validate`** (new skill): closes the hypothesis-validation loop in COACHING_LOG.md
- **`/cb-snapshot`** extended: appends recent coaching context to every snapshot file
- **`/cb-log`** extended: `--mode` flag for coaching modality tracking
- **`/cb-init`** extended: structured Stakeholders template with power dynamics prompts

---

## Business Context

The engagement layer (ADR-010, v1.7) gave coaches persistent context across sessions.
The gap it left: hypotheses accumulate but are never revisited. Observations are recorded
but the loop never closes. A coach using the tool for 3 months could have 40 logged
hypotheses with zero confirmed or disconfirmed.

The AI reviewer correctly identified "outcome grounding" as the most critical missing
piece. This feature delivers that — plus two quality-of-life improvements (snapshot
coaching context, mode tracking) and a systemic forces prompt in the init template.

---

## Key Decisions

| Decision | Verdict | Rationale |
|----------|---------|-----------|
| Which gaps to build | 4 of 12 | Triage via Virtue Filter; 8 eliminated/deferred. Team feedback (Gap 7) ruled out by existing SSOT. Multi-coach handoff and cross-engagement learning are YAGNI. |
| cb-validate mutation strategy (ADR-011) | In-place append to COACHING_LOG.md | Transparency (first quality attribute): validation result co-located with hypothesis. Uses established id-match mechanism from cb-log Mode 2. |
| cb-snapshot entry selection | 3 most-recent by date (v1) | Simplest correct behaviour. Keyword-to-WIP correlation deferred as OQ-2. |
| Gaps 1 and 4 scoped as micro-improvements | Mode field + template, not new skills | New skills have ceremony (SKILL.md, docs, testing); an optional field and a template section do not warrant that overhead. |
| hypothesis-validation job | New job in jobs.yaml | J7 ends at "record". The validation/closure step (did X happen?) is a distinct job not covered by any prior SSOT entry. |

---

## Waves Run

| Wave | Output |
|------|--------|
| DISCUSS | Triage table, 4 stories + elevator pitches + ACs, story map, 3 slice briefs, DoR validated, hypothesis-validation job added to jobs.yaml |
| DESIGN | Component decomposition, reuse analysis (3 EXTEND, 1 CREATE NEW), C4 update, ADR-011 |
| DELIVER | 19 files shipped (8 skill files + test scripts + docs); 43/43 automated tests green; manual test script (14 scenarios) |

---

## Artifacts

**Shipped (permanent):**
- `skills/cb-validate/SKILL.md` — new skill
- `plugins/coach-buddy/skills/cb-validate/SKILL.md` — plugin version
- `skills/cb-snapshot/SKILL.md` — coaching context section added
- `skills/cb-log/SKILL.md` — --mode flag + mode: field
- `skills/cb-init/SKILL.md` — Stakeholders table + mode in COACHING_LOG template
- `docs/product/architecture/adr-011-cb-validate-inplace-validation.md`
- `docs/product/architecture/brief.md` — cb-review-improvements section added
- `docs/product/jobs.yaml` — hypothesis-validation job
- `tests/acceptance/cb-review-improvements/` — 14 manual scenarios + test script
- `README.md` — engagement layer section updated for 6 skills

**Feature workspace (history):**
- `docs/feature/cb-review-improvements/feature-delta.md` — full DISCUSS+DESIGN+DELIVER record
- `docs/feature/cb-review-improvements/slices/` — 3 slice briefs

---

## Lessons Learned

**What worked well:**
- Running the Virtue Filter on reviewer gaps early eliminated most of them before any design work — saved significant effort.
- The existing id-match mechanism in cb-log Mode 2 made cb-validate straightforward to specify: reuse, don't reinvent.
- Scoping Gaps 1 and 4 as micro-improvements (field + template) rather than new skills kept the delivery lean — each was 3-10 lines of changes.

**What to watch:**
- cb-validate has 14 manual test scenarios but zero automated coverage. The SKILL.md is straightforward but the in-place file mutation is the highest-risk operation — worth dogfooding on a real engagement quickly.
- The `--mode` flag on cb-log defaults silently to `thinking-partner` — coaches may not discover advisory mode tracking without README prompting.
- OQ-2 (keyword correlation for snapshot entry selection) was deferred. If coaches find the "3 most recent" heuristic surfaces irrelevant entries before key sessions, reconsider.

**Deferred items to revisit:**
- OQ-2: WIP-correlated entry selection in cb-snapshot (post-usage data needed)
- Cross-engagement pattern learning (Gap 12): privacy implications need thinking before implementation
- Multi-coach handoff (Gap 3): worth revisiting if coach-buddy is adopted by coaching teams
