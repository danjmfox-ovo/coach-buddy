# Execution context: manual conversation test
# System under test: Claude Code / CoWork with coach-buddy engagement layer skills installed
# Driving ports: /cb-init, /cb-snapshot
# WS strategy: C (real local) — all resources are local filesystem SKILL.md files
# How to run: use a real CoWork project directory; run each scenario in Claude Code
# Feature: calendar-magick-integration (Walking Skeleton — US-01 + US-02)
# Scaffold note: SKILL.md files already exist; these tests verify their CONTENT, not scaffolded stubs.
# No RED scaffold stubs needed. DELIVER wave crafter modifies existing SKILL.md to satisfy each test.
#
# Walking skeleton proves the end-to-end data path:
#   cb-init writes team_config.path → cb-snapshot reads teams.yaml → sprint context rendered in header

Feature: Walking skeleton — teams.yaml link written by cb-init is read by cb-snapshot

  Rule: cb-init writes team_config.path to config.json (US-01 write path)

    Background:
      Given the coach is in a CoWork project directory with no existing engagement
      And a calendar-magick teams.yaml exists at "teams/phoenix/config.yaml" relative to the project directory
      And that file contains:
        """
        team:
          name: Phoenix
          cadence: scrum
          sprint_length_weeks: 2
          members:
            - name: Dan Fox
              role: SM
            - name: Alice Chen
              role: DEV
        """

    @walking_skeleton @real-io @US-01
    Scenario: Coach links a teams.yaml during cb-init and config.json records the path
      Given the coach is ready to set up a new engagement
      When the coach runs /cb-init and completes all setup questions
      And when asked "Link a calendar-magick teams.yaml?" enters the path "teams/phoenix/config.yaml"
      Then config.json is created with a top-level "team_config" key
      And config.json contains "team_config.path": "teams/phoenix/config.yaml"
      And the setup confirmation includes "Linked teams.yaml: teams/phoenix/config.yaml"

  Rule: cb-snapshot reads teams.yaml via team_config.path and renders sprint context (US-02 read path)

    Background:
      Given a root-layout engagement exists at the project root
      And config.json contains:
        """
        {
          "version": "1",
          "engagement": { "slug": "phoenix-team" },
          "team_config": { "path": "teams/phoenix/config.yaml" }
        }
        """
      And "teams/phoenix/config.yaml" exists at the path relative to the engagement root and contains:
        """
        team:
          name: Phoenix
          cadence: scrum
          sprint_length_weeks: 2
        """

    @walking_skeleton @real-io @US-02
    Scenario: cb-snapshot renders sprint context in the snapshot header when teams.yaml has scrum cadence
      Given today is 2026-05-19 (a Tuesday)
      And the sprint position algorithm with epoch 2020-01-06 and sprint_length_weeks=2 yields: sprint start 2026-05-18, Day 2, Week 1/2
      When the coach runs /cb-snapshot
      Then the snapshot file header line includes "| Day 2, Week 1/2 of Sprint (2-week scrum, started 2026-05-18)"
      And the two-sentence risk read printed in chat also includes the sprint context suffix
      And the snapshot is written without errors
