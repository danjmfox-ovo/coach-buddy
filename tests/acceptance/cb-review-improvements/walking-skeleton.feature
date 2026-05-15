# Execution context: manual conversation test
# System under test: Claude Code / CoWork with coach-buddy engagement layer skills installed
# Driving port: /cb-validate, /cb-snapshot (extended), /cb-log --mode, /cb-init (template)
# WS strategy: B (brownfield incremental — no walking skeleton; each test verifies one skill)
# How to run: use a real engagement folder with COACHING_LOG.md populated; run each scenario in Claude Code
# Feature: cb-review-improvements (Slices 01-03)

Feature: Engagement layer improvements — hypothesis validation, coaching context in snapshots, mode tracking

  # -----------------------------------------------------------------------
  # RULE: Hypothesis validation (Slice 01 — cb-validate)
  # -----------------------------------------------------------------------

  Rule: cb-validate closes the loop on logged hypotheses

    Background:
      Given an engagement folder exists at engagements/<slug>/
      And COACHING_LOG.md contains at least two entries with real (non "(to fill)") hypotheses
      And at least one entry has a date > 14 days ago

    @walking_skeleton @real-io @S1
    Scenario: cb-validate presents overdue hypotheses for validation
      Given the coach runs /cb-validate
      When the skill reads COACHING_LOG.md
      Then hypotheses are shown grouped by age: Overdue (>14d) first
      And each entry shows its id, date, and full hypothesis text
      And the coach is prompted: "Mark as: (c)onfirmed / (d)isconfirmed / (x) defer / (s)kip all remaining"

    @real-io @S1
    Scenario: cb-validate writes validation status back to COACHING_LOG.md
      Given the coach marks an overdue hypothesis as "confirmed"
      When cb-validate completes
      Then COACHING_LOG.md contains **Validation**: confirmed ({today}) in the matched entry
      And all other fields in the entry are unchanged
      And the confirmation summary shows: Confirmed: 1

    @real-io @S1
    Scenario: cb-validate exits gracefully when no coaching log exists
      Given no COACHING_LOG.md exists for the engagement
      When the coach runs /cb-validate
      Then the skill prints: "No coaching log found for <slug>. Run /cb-log to start capturing observations."
      And the skill does not error or crash

    @real-io @S1
    Scenario: cb-validate does not prompt validation for entries < 7 days old
      Given COACHING_LOG.md contains an entry dated today or yesterday
      When cb-validate runs
      Then that entry is shown in a "Recent" section
      And the skill does NOT prompt the coach to mark it as confirmed/disconfirmed
      And the entry shows: "too recent to validate (hypothesis shown for awareness only)"

    @real-io @S1
    Scenario: cb-validate surfaces advisory mode pattern note when >= 2 advisory entries exist
      Given COACHING_LOG.md contains 2 or more entries with mode: advisory
      When cb-validate completes
      Then the summary includes a pattern note mentioning the count of advisory-mode entries
      And the note is observational — it does not frame advisory mode as a problem

    @error @S1
    Scenario: cb-validate guards against duplicate validation fields
      Given an entry already has **Validation**: confirmed (YYYY-MM-DD) written
      When the coach runs cb-validate again on that entry
      Then the skill shows: "Already validated as confirmed. Update? (yes / no / skip)"
      And it does NOT write a second **Validation** line without confirmation

  # -----------------------------------------------------------------------
  # RULE: Snapshot with coaching context (Slice 02 — cb-snapshot extended)
  # -----------------------------------------------------------------------

  Rule: cb-snapshot appends relevant coaching context to the snapshot file

    Background:
      Given an engagement folder exists with config.json and COACHING_LOG.md
      And COACHING_LOG.md has at least one entry

    @walking_skeleton @real-io @S2
    Scenario: cb-snapshot includes Relevant coaching context section when COACHING_LOG exists
      Given the coach runs /cb-snapshot
      When the snapshot file is written
      Then the snapshot file contains a "## Coaching context" section
      And the section shows up to 3 entries, most-recent-first
      And each entry shows: date, truncated Observed (≤120 chars), truncated Hypothesis (≤120 chars)

    @real-io @S2
    Scenario: cb-snapshot coaching context does not appear in the chat risk read
      Given the coach runs /cb-snapshot
      When the risk read is printed in chat
      Then the chat output contains exactly two sentences (the risk read)
      And the chat output does NOT include the coaching context section content

    @real-io @S2
    Scenario: cb-snapshot generates as before when no COACHING_LOG.md exists
      Given no COACHING_LOG.md exists for the engagement
      When the coach runs /cb-snapshot
      Then the snapshot file is written without a "## Coaching context" section
      And no error is raised

  # -----------------------------------------------------------------------
  # RULE: Mode tracking (Slice 03 — cb-log --mode flag)
  # -----------------------------------------------------------------------

  Rule: cb-log accepts and persists coaching mode on each entry

    @walking_skeleton @real-io @S3
    Scenario: cb-log writes mode: advisory when --mode advisory is passed
      Given the coach runs /cb-log "The team lead asked for direct input on the prioritisation call" --mode advisory
      When the entry is written to COACHING_LOG.md
      Then the entry contains mode: advisory in the entry header (between date: and the blank line)
      And all other fields are written as normal

    @real-io @S3
    Scenario: cb-log defaults to mode: thinking-partner when --mode is not passed
      Given the coach runs /cb-log "Sprint review felt flat — team delivered but energy was low"
      When the entry is written to COACHING_LOG.md
      Then the entry contains mode: thinking-partner

    @error @S3
    Scenario: cb-log rejects unrecognised mode values
      Given the coach runs /cb-log "observation" --mode mentor
      When cb-log processes the invocation
      Then the skill prints: "Mode must be one of: thinking-partner, advisory, facilitation"
      And no entry is written to COACHING_LOG.md

  # -----------------------------------------------------------------------
  # RULE: Stakeholder power mapping template (Slice 03 — cb-init template)
  # -----------------------------------------------------------------------

  Rule: cb-init generates enhanced Stakeholders section in CONTEXT.md

    @walking_skeleton @real-io @S4
    Scenario: cb-init generates CONTEXT.md with structured Stakeholders table
      Given the coach runs /cb-init for a new engagement
      When CONTEXT.md is generated
      Then the Stakeholders section contains a table with columns: Role, Influence, Inclusion notes, External pressures
      And the section contains the prompt: "Who am I NOT seeing?"

    @real-io @S4
    Scenario: cb-init generates COACHING_LOG.md template with mode field shown
      Given the coach runs /cb-init for a new engagement
      When COACHING_LOG.md is generated
      Then the entry format template shows mode: thinking-partner in the entry header

    @real-io @S4
    Scenario: cb-init does not overwrite existing CONTEXT.md without confirmation
      Given an engagement folder already exists with a populated CONTEXT.md
      When the coach runs /cb-init without --force
      Then the skill asks for confirmation before overwriting
      And if the coach says no, CONTEXT.md is unchanged
