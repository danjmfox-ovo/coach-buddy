# Execution context: manual conversation test
# System under test: Claude Code / CoWork with coach-buddy plugin installed
# Driving port: /cb-query --slug {slug} --format json — new skill, PA invoke
# WS strategy: C (real local) — invoked against real engagement files in CoWork project
# How to run: use a real CoWork project with engagements/advisor-connect/ created by cb-init
# Feature: cb-pa-integration Slice 03 — cb-query --format json
# Scaffold note: cb-query SKILL.md created in Slice 02. DELIVER extends it with JSON output branch.
# DW-2 learning hypothesis: signal_summary scoped to engagement-health domain observed in PA output.

Feature: cb-query emits structured JSON when called with --format json

  # -----------------------------------------------------------------------
  # RULE: Walking skeleton — valid JSON with status:ok (US-003 happy path)
  # -----------------------------------------------------------------------

  Rule: PA agent receives structured engagement health data in JSON format

    Background:
      Given an engagement exists at engagements/advisor-connect/
      And COACHING_LOG.md contains at least one entry with a hypothesis
      And RETRO_ACTIONS.md contains at least one open action

    @walking_skeleton @real-io @US-003
    Scenario: PA queries an engagement with --format json and receives a valid ok response
      Given the engagement folder for "advisor-connect" exists with COACHING_LOG.md and RETRO_ACTIONS.md
      When the PA invokes /cb-query --slug advisor-connect --format json
      Then cb-query emits valid JSON to the response (not prose)
      And the JSON contains "status": "ok"
      And the JSON contains "team": "advisor-connect"
      And the JSON contains an "open_actions" array
      And the JSON contains an "open_hypotheses" array
      And the JSON contains a "last_capture" date field
      And the JSON contains a "last_retro" date field
      And the JSON contains a "signal_summary" string field

  # -----------------------------------------------------------------------
  # RULE: Required fields present on status:ok (US-003, PA contract v1.0.0-draft)
  # -----------------------------------------------------------------------

  Rule: All PA contract required fields are present on a successful response

    @real-io @US-003
    Scenario: ok response includes all fields needed for PA next-action prioritisation
      Given COACHING_LOG.md contains an open hypothesis and RETRO_ACTIONS.md contains an open action
      When the PA invokes /cb-query --slug advisor-connect --format json
      Then the JSON "open_actions" items each contain at least "description" and "evidenced" fields
      And the "evidenced" field is a boolean (true when Evidenced=yes, false otherwise)
      And the JSON "open_hypotheses" items each contain at least "text" and "status" fields
      And "status" is one of: "open", "deferred"
      And "last_capture" is an ISO date string
      And "last_retro" is an ISO date string or null if no retro entries exist

    @real-io @US-003
    Scenario: signal_summary is scoped to engagement-health domain only (DW-2)
      Given COACHING_LOG.md and RETRO_ACTIONS.md contain recent engagement data
      When the PA invokes /cb-query --slug advisor-connect --format json
      Then the "signal_summary" field contains 2-3 sentences about hypothesis age, action evidenced ratio, and WIP age only
      And the "signal_summary" does not reference calendar events, chat messages, or non-engagement-file signals

  # -----------------------------------------------------------------------
  # RULE: degraded status when board MCP unavailable (D5)
  # -----------------------------------------------------------------------

  Rule: PA receives a degraded response with empty wip_aged when board MCP cannot be called

    @real-io @US-003
    Scenario: Board MCP unavailable returns status:degraded with empty wip_aged
      Given the engagement config has board_tool set to "jira"
      And the Jira MCP is not available or returns an error
      When the PA invokes /cb-query --slug advisor-connect --format json
      Then the JSON contains "status": "degraded"
      And the JSON "wip_aged" field is an empty array
      And the JSON contains a "warnings" array with at least one entry explaining the board MCP was unavailable
      And all other fields (open_actions, open_hypotheses, last_capture, signal_summary) are still populated

    @real-io @US-003
    Scenario: No board_tool in config returns status:degraded with empty wip_aged
      Given config.json for "advisor-connect" has no board_tool field
      When the PA invokes /cb-query --slug advisor-connect --format json
      Then the JSON contains "status": "degraded"
      And the JSON "wip_aged" field is an empty array
      And the JSON "warnings" explains that no board tool is configured

  # -----------------------------------------------------------------------
  # RULE: error status when engagement not found (US-003)
  # -----------------------------------------------------------------------

  Rule: PA receives a structured error when the engagement slug cannot be resolved

    @error @real-io @US-003
    Scenario: Unknown slug returns status:error JSON
      Given no engagement folder named "ghost-team" exists
      When the PA invokes /cb-query --slug ghost-team --format json
      Then cb-query emits valid JSON with "status": "error"
      And the JSON contains "team": "ghost-team"
      And the JSON contains an "error" field with a human-readable explanation
      And no other fields (open_actions, open_hypotheses, signal_summary) are present

  # -----------------------------------------------------------------------
  # RULE: --format json absent falls back to US-002 prose behaviour
  # -----------------------------------------------------------------------

  Rule: cb-query without --format json produces the human-readable prose from Slice 02

    @real-io @US-003
    Scenario: cb-query without --format json returns prose not JSON
      Given the engagement folder for "advisor-connect" exists
      When the PA invokes /cb-query --slug advisor-connect (without --format json)
      Then the response is readable prose matching the Slice 02 behaviour
      And no JSON structure appears in the response

  # -----------------------------------------------------------------------
  # RULE: wip_aged populated from board MCP when available
  # -----------------------------------------------------------------------

  Rule: wip_aged items from board MCP each include age_days field

    @real-io @requires_external @US-003
    Scenario: Board MCP available — wip_aged contains items with age_days
      Given config.json sets board_tool to "jira" and the Jira MCP is accessible
      And the board has at least one WIP item older than 5 days
      When the PA invokes /cb-query --slug advisor-connect --format json
      Then the JSON contains "status": "ok"
      And the "wip_aged" array contains items with at least "title" and "age_days" fields
      And "age_days" is a positive integer
