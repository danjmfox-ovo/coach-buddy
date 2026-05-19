# Execution context: manual conversation test
# System under test: Claude Code / CoWork with coach-buddy engagement layer skills installed
# Driving port: /cb-snapshot
# WS strategy: C (real local) — all resources are local filesystem SKILL.md files
# How to run: use a real CoWork project directory; run each scenario in Claude Code
# Feature: calendar-magick-integration — Slice 02 (US-02)
# Scaffold note: SKILL.md files already exist; these tests verify their CONTENT, not scaffolded stubs.
#
# Date fixture for sprint position tests:
#   today = 2026-05-19 (Tuesday), sprint_length_weeks = 2, epoch = 2020-01-06
#   Sprint start = 2026-05-18 (Monday), sprint_day = 2, sprint_week = 1
#   Expected output: "Day 2, Week 1/2 of Sprint (2-week scrum, started 2026-05-18)"

Feature: Slice 02 — cb-snapshot renders sprint-aware header from teams.yaml cadence

  # -----------------------------------------------------------------------
  # RULE: Sprint context in header when cadence is scrum (US-02)
  # -----------------------------------------------------------------------

  Rule: cb-snapshot appends sprint context to the header when teams.yaml has cadence: scrum

    Background:
      Given an engagement exists with config.json containing:
        """
        {
          "version": "1",
          "engagement": { "slug": "phoenix-team" },
          "team_config": { "path": "teams/phoenix/config.yaml" }
        }
        """
      And "teams/phoenix/config.yaml" exists at the path relative to the engagement root

    @real-io @US-02
    Scenario: Snapshot header includes sprint day and week when cadence is scrum
      Given "teams/phoenix/config.yaml" contains:
        """
        team:
          name: Phoenix
          cadence: scrum
          sprint_length_weeks: 2
        """
      And today is 2026-05-19
      When the coach runs /cb-snapshot
      Then the snapshot file header line is:
        """
        Generated: 2026-05-19 — Phoenix-team | Day 2, Week 1/2 of Sprint (2-week scrum, started 2026-05-18)
        """

    @real-io @US-02
    Scenario: Risk read in chat includes sprint context when cadence is scrum
      Given "teams/phoenix/config.yaml" contains cadence: scrum and sprint_length_weeks: 2
      And today is 2026-05-19
      When the coach runs /cb-snapshot
      Then the two-sentence risk read printed in chat includes the sprint context suffix
      And the risk read mentions "Day 2, Week 1/2 of Sprint"

    @real-io @US-02
    Scenario: Sprint position algorithm uses fixed epoch — reproducible for any date
      Given "teams/phoenix/config.yaml" contains cadence: scrum and sprint_length_weeks: 1
      And today is 2026-05-19
      When the coach runs /cb-snapshot
      Then the snapshot header shows sprint context for a 1-week sprint
      And sprint_day = 2 (Tuesday of a Mon-start week)
      And sprint_week = 1/1

    @real-io @US-02
    Scenario: Weekend is treated as the preceding Friday for sprint position
      Given "teams/phoenix/config.yaml" contains cadence: scrum and sprint_length_weeks: 2
      And today is a Saturday or Sunday
      When the coach runs /cb-snapshot
      Then the sprint position in the header reflects Friday's position (not the weekend day)
      And no error is raised

  # -----------------------------------------------------------------------
  # RULE: No sprint context when cadence is kanban or absent (US-02 AC-02.4)
  # -----------------------------------------------------------------------

  Rule: cb-snapshot produces an unchanged header when cadence is not scrum

    Background:
      Given an engagement exists with config.json containing team_config.path pointing to a teams.yaml

    @real-io @US-02
    Scenario: No sprint context when teams.yaml has cadence: kanban
      Given "teams/phoenix/config.yaml" contains:
        """
        team:
          name: Phoenix
          cadence: kanban
        """
      When the coach runs /cb-snapshot
      Then the snapshot header line does not include any sprint context suffix
      And the header format is unchanged from current behaviour

    @real-io @US-02
    Scenario: No sprint context when teams.yaml has no cadence field
      Given "teams/phoenix/config.yaml" contains a team block with no cadence field
      When the coach runs /cb-snapshot
      Then the snapshot header line does not include any sprint context suffix
      And the snapshot is produced without error

  # -----------------------------------------------------------------------
  # RULE: Graceful degradation when team_config is absent or unreadable (US-02 AC-02.5)
  # -----------------------------------------------------------------------

  Rule: cb-snapshot degrades gracefully when team context is unavailable

    @real-io @US-02
    Scenario: No sprint context when config.json has no team_config field
      Given an engagement exists with config.json that has no "team_config" key
      When the coach runs /cb-snapshot
      Then the snapshot header line does not include any sprint context suffix
      And no warning about missing team_config is emitted
      And the snapshot is produced normally

    @error @real-io @US-02
    Scenario: No sprint context and no error when teams.yaml cannot be read
      Given config.json contains "team_config.path": "teams/phoenix/config.yaml"
      And "teams/phoenix/config.yaml" does not exist at the resolved path
      When the coach runs /cb-snapshot
      Then the snapshot header line does not include any sprint context suffix
      And no error is raised about the missing file
      And the snapshot is produced normally

    @error @real-io @US-02
    Scenario: No sprint context and no error when teams.yaml has no team.cadence field
      Given "teams/phoenix/config.yaml" contains a team block but no cadence field
      When the coach runs /cb-snapshot
      Then cb-snapshot produces the snapshot without a sprint context suffix
      And no error is raised
