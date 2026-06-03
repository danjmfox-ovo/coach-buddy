# Execution context: manual conversation test
# System under test: Claude Code / CoWork with coach-buddy plugin installed
# Driving port: /cb-query {slug} — new skill, human invoke
# WS strategy: C (real local) — invoked against real engagement files in CoWork project
# How to run: use a real CoWork project with engagements/advisor-connect/ created by cb-init
# Feature: cb-pa-integration Slice 02 — cb-query human-readable snapshot
# Scaffold note: cb-query does not yet exist. DELIVER creates skills/cb-query/SKILL.md.
# The SKILL.md file itself is the scaffold — these tests verify its content and behaviour.

Feature: cb-query returns a readable engagement health summary

  # -----------------------------------------------------------------------
  # RULE: Walking skeleton — readable summary from real engagement files (US-002)
  # -----------------------------------------------------------------------

  Rule: Coach retrieves a consolidated engagement summary with a single command

    Background:
      Given an engagement exists at engagements/advisor-connect/
      And COACHING_LOG.md contains at least one entry with a hypothesis
      And RETRO_ACTIONS.md contains at least one open action

    @walking_skeleton @real-io @US-002
    Scenario: Coach queries an engagement and receives a readable summary
      Given the engagement folder for "advisor-connect" contains COACHING_LOG.md and RETRO_ACTIONS.md
      When the coach invokes /cb-query advisor-connect
      Then the response is readable prose (not raw JSON)
      And the response includes a section on open actions
      And the response includes a section on open or deferred hypotheses
      And the response includes the date of the last log entry
      And the response includes the date of the last retro action entry

  # -----------------------------------------------------------------------
  # RULE: Open actions surfaced from RETRO_ACTIONS.md (US-002)
  # -----------------------------------------------------------------------

  Rule: cb-query surfaces open retro actions that have not been evidenced

    @real-io @US-002
    Scenario: Open actions are listed with owner and description
      Given RETRO_ACTIONS.md contains three actions: two open, one with Evidenced=yes
      When the coach invokes /cb-query advisor-connect
      Then the response lists the two open (non-evidenced) actions
      And the evidenced action is not listed as open
      And each open action shows its description and owner

    @real-io @US-002
    Scenario: All actions evidenced results in a clear "no open actions" message
      Given RETRO_ACTIONS.md contains only actions where Evidenced=yes or Status=done
      When the coach invokes /cb-query advisor-connect
      Then the response indicates there are no open retro actions
      And does not list any actions as requiring follow-up

  # -----------------------------------------------------------------------
  # RULE: Hypotheses surfaced from COACHING_LOG.md (US-002)
  # -----------------------------------------------------------------------

  Rule: cb-query surfaces open and deferred hypotheses using the Extraction Grammar

    @real-io @US-002
    Scenario: Open hypotheses without validation status are surfaced
      Given COACHING_LOG.md contains an entry with a Hypothesis block and no Validation field
      When the coach invokes /cb-query advisor-connect
      Then the response lists the hypothesis as open
      And includes the hypothesis text

    @real-io @US-002
    Scenario: Deferred hypotheses are surfaced as deferred
      Given COACHING_LOG.md contains an entry where Validation status is "deferred"
      When the coach invokes /cb-query advisor-connect
      Then the response lists that hypothesis as deferred (not open and not closed)

    @real-io @US-002
    Scenario: Confirmed and rejected hypotheses are not listed as open
      Given COACHING_LOG.md contains entries with Validation status "confirmed" and "rejected"
      When the coach invokes /cb-query advisor-connect
      Then confirmed and rejected hypotheses are not included in the open list

  # -----------------------------------------------------------------------
  # RULE: --since window filters entries read (US-002, D6)
  # -----------------------------------------------------------------------

  Rule: --since filters the entries read, but open hypothesis status is not affected by window

    @real-io @US-002
    Scenario: --since defaults to 14 days
      Given COACHING_LOG.md contains entries from 20 days ago and 5 days ago
      When the coach invokes /cb-query advisor-connect without --since
      Then only entries from the last 14 days are included in the summary
      And the entry from 20 days ago does not appear in the recent captures

    @real-io @US-002
    Scenario: --since accepts an ISO date override
      Given COACHING_LOG.md contains entries from different dates
      When the coach invokes /cb-query advisor-connect --since 2026-01-01
      Then all entries from 2026-01-01 onwards are included in the summary

    @real-io @US-002
    Scenario: Open hypotheses older than the --since window are still surfaced
      Given COACHING_LOG.md contains a hypothesis from 30 days ago with no Validation
      When the coach invokes /cb-query advisor-connect (default 14-day window)
      Then the response still lists the 30-day-old hypothesis as open
      And a note indicates it is outside the recent window

  # -----------------------------------------------------------------------
  # RULE: Board MCP omitted gracefully when board_tool absent (US-002)
  # -----------------------------------------------------------------------

  Rule: cb-query produces a useful summary even when no board tool is configured

    @real-io @US-002
    Scenario: Summary produced without board section when board_tool absent from config
      Given config.json for "advisor-connect" has no board_tool field
      When the coach invokes /cb-query advisor-connect
      Then the response does not include a WIP or board section
      And no error is shown about missing board configuration
      And all other sections (actions, hypotheses, dates) are present

  # -----------------------------------------------------------------------
  # RULE: Error path — engagement not found (US-002)
  # -----------------------------------------------------------------------

  Rule: cb-query returns a clear error when the engagement slug cannot be resolved

    @error @real-io @US-002
    Scenario: Unknown slug returns a clear error message
      Given no engagement folder named "ghost-team" exists
      When the coach invokes /cb-query ghost-team
      Then the response is a prose error message (not a crash or empty response)
      And the message names the slug "ghost-team" and explains the folder was not found
      And the message does not suggest running /cb-init in the response prose

    @error @real-io @US-002
    Scenario: Missing --slug with multiple engagements triggers disambiguation
      Given engagements/advisor-connect/ and engagements/platform-team/ both exist
      And no root-layout config.json is present
      When the coach invokes /cb-query without specifying a slug
      Then cb-query asks which engagement to query
      And lists "advisor-connect" and "platform-team" as available options

  # -----------------------------------------------------------------------
  # RULE: --slug resolves from engagements_root, not cwd (AV-6)
  # -----------------------------------------------------------------------

  Rule: Path resolution uses --slug from engagements_root

    @real-io @US-002
    Scenario: /cb-query --slug resolves from engagements/ root
      Given the engagement folder exists at engagements/advisor-connect/
      When the coach invokes /cb-query --slug advisor-connect
      Then the summary is read from engagements/advisor-connect/COACHING_LOG.md and RETRO_ACTIONS.md
      And the response does not reference the current working directory path
