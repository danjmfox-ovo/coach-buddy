# Execution context: manual conversation test
# System under test: Claude Code / CoWork with coach-buddy engagement layer skills installed
# Driving port: /cb-init
# WS strategy: C (real local) — all resources are local filesystem SKILL.md files
# How to run: use a real CoWork project directory; run each scenario in Claude Code
# Feature: calendar-magick-integration — Slice 01 (US-01 + US-03)
# Scaffold note: SKILL.md files already exist; these tests verify their CONTENT, not scaffolded stubs.

Feature: Slice 01 — cb-init links a teams.yaml and detects existing team configs

  # -----------------------------------------------------------------------
  # RULE: Optional teams.yaml link prompt (US-01)
  # -----------------------------------------------------------------------

  Rule: cb-init presents an optional teams.yaml link prompt as the final setup question

    Background:
      Given the coach is in a CoWork project directory with no existing engagement

    @real-io @US-01
    Scenario: Coach enters a valid path and config.json is written with team_config
      Given a file exists at "teams/phoenix/config.yaml" relative to the project directory
      When the coach runs /cb-init (or /cb-init --root) and completes all setup questions
      And when asked "Link a calendar-magick teams.yaml?" enters the path "teams/phoenix/config.yaml"
      Then config.json is written with "team_config": { "path": "teams/phoenix/config.yaml" }
      And the confirmation message includes "Linked teams.yaml: teams/phoenix/config.yaml"

    @real-io @US-01
    Scenario: Coach presses Enter to skip and config.json is written without team_config
      When the coach runs /cb-init and completes all setup questions
      And when asked "Link a calendar-magick teams.yaml?" presses Enter (skips)
      Then config.json is written without a "team_config" key
      And existing engagement fields (slug, pm_tool, wip_threshold, etc.) are unchanged

    @real-io @US-01
    Scenario: Coach enters a path to a file that does not exist — cb-init warns and skips the field
      When the coach runs /cb-init and completes all setup questions
      And when asked "Link a calendar-magick teams.yaml?" enters the path "teams/missing/config.yaml"
      Then cb-init responds with "File not found at teams/missing/config.yaml. You can add this later by editing config.json."
      And config.json is written without a "team_config" key
      And the setup completes successfully (non-zero exit only when engagement files cannot be created)

    @real-io @US-01
    Scenario: teams.yaml link prompt is the last question in the setup flow
      When the coach runs /cb-init and answers each prompt in order
      Then the "Link a calendar-magick teams.yaml?" prompt appears only after all other setup questions have been answered
      And no existing prompt is reordered or removed

    @real-io @US-01
    Scenario: Existing engagements without team_config continue to work after cb-init update
      Given an existing engagement at "engagements/platform-team/" with a config.json that has no "team_config" key
      When the coach runs /cb-snapshot for the platform-team engagement
      Then the snapshot is produced without error
      And no sprint context line appears in the header
      And no warning about a missing "team_config" field is emitted

  # -----------------------------------------------------------------------
  # RULE: Auto-detection of teams/ directory (US-03)
  # -----------------------------------------------------------------------

  Rule: cb-init detects teams/*/config.yaml and pre-suggests the path

    Background:
      Given the coach is in a CoWork project directory with no existing engagement

    @real-io @US-03
    Scenario: Exactly one teams/*/config.yaml is found — cb-init pre-suggests it
      Given "teams/phoenix/config.yaml" exists at the project directory
      When the coach runs /cb-init and reaches the teams.yaml link step
      Then cb-init presents "Found teams/phoenix/config.yaml. Link this as your teams.yaml? [Y/n]"
      And pressing Enter (or Y) writes "teams/phoenix/config.yaml" as the team_config.path
      And pressing N falls through to the manual entry prompt

    @real-io @US-03
    Scenario: Multiple teams/*/config.yaml files found — cb-init presents a numbered list
      Given "teams/phoenix/config.yaml" and "teams/raven/config.yaml" both exist at the project directory
      When the coach runs /cb-init and reaches the teams.yaml link step
      Then cb-init presents a numbered list of the available team configs
      And the coach can select by number, enter a custom path, or skip

    @real-io @US-03
    Scenario: No teams/ directory found — cb-init falls through to manual entry unchanged
      Given no "teams/" directory exists at the project directory
      When the coach runs /cb-init and reaches the teams.yaml link step
      Then cb-init presents the manual entry prompt "Link a calendar-magick teams.yaml? Enter a path relative to this directory, or press Enter to skip."
      And no auto-detected path is shown

    @real-io @US-03
    Scenario: teams/ directory exists but cannot be read — cb-init falls through silently
      Given a "teams/" directory exists at the project directory but is not readable
      When the coach runs /cb-init and reaches the teams.yaml link step
      Then cb-init presents the manual entry prompt without mentioning the detection failure
      And no error is surfaced to the coach
