# Execution context: manual conversation test
# System under test: Claude Code / CoWork with coach-buddy engagement layer skills installed
# Driving port: /cb-log
# WS strategy: C (real local) — all resources are local filesystem SKILL.md files
# How to run: use a real CoWork project directory; run each scenario in Claude Code
# Feature: calendar-magick-integration — Slice 03 (US-04)
# Scaffold note: SKILL.md files already exist; these tests verify their CONTENT, not scaffolded stubs.
#
# OQ-04 resolution: `participants` is added as a new optional COACHING_LOG.md frontmatter field,
# analogous to the existing optional `mode:` field. When the coach presses Enter for "full team",
# cb-log populates `participants:` with all member names from team.members.
# When the coach types names explicitly, those names are written to `participants:`.
# When team context is absent, the `participants:` field is omitted (current behaviour preserved).

Feature: Slice 03 — cb-log suggests team member names from teams.yaml

  # -----------------------------------------------------------------------
  # RULE: Member hint shown when team_config.path is set (US-04)
  # -----------------------------------------------------------------------

  Rule: cb-log prepends a team roster hint to the "Who was in the session?" prompt

    Background:
      Given an engagement exists with config.json containing:
        """
        {
          "version": "1",
          "engagement": { "slug": "phoenix-team" },
          "team_config": { "path": "teams/phoenix/config.yaml" }
        }
        """
      And "teams/phoenix/config.yaml" exists and contains:
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
            - name: Priya Patel
              role: PO
        """

    @real-io @US-04
    Scenario: cb-log shows the team roster as a hint before asking who was in the session
      When the coach runs /cb-log "Tech lead not speaking in standups"
      Then cb-log presents: "Team roster: Dan Fox (SM), Alice Chen (DEV), Priya Patel (PO) — enter names or press Enter for full team."
      And the hint appears before or as part of the "Who was in the session?" prompt

    @real-io @US-04
    Scenario: Coach presses Enter to select full team — participants field populated with all members
      When the coach runs /cb-log "Team was quiet during planning"
      And when prompted presses Enter (full team)
      Then the COACHING_LOG.md entry includes the frontmatter field:
        """
        participants: Dan Fox, Alice Chen, Priya Patel
        """
      And the entry is otherwise formatted as normal

    @real-io @US-04
    Scenario: Coach types custom names — participants field reflects exactly what was typed
      When the coach runs /cb-log "1:1 with Dan"
      And when prompted types "Dan Fox"
      Then the COACHING_LOG.md entry includes the frontmatter field:
        """
        participants: Dan Fox
        """
      And no error is raised about names not matching the roster (hint is informational only)

    @real-io @US-04
    Scenario: Coach types names not in the roster — cb-log accepts them without warning
      When the coach runs /cb-log "Observed a guest stakeholder in planning"
      And when prompted types "Sarah Williams"
      Then "Sarah Williams" is written to the participants field in the COACHING_LOG.md entry
      And no validation error is raised about unrecognised names

  # -----------------------------------------------------------------------
  # RULE: Graceful degradation when team_config is absent or unreadable (US-04 AC-04.5)
  # -----------------------------------------------------------------------

  Rule: cb-log presents the standard prompt unchanged when team context is unavailable

    @real-io @US-04
    Scenario: No member hint when config.json has no team_config field
      Given an engagement exists with config.json that has no "team_config" key
      When the coach runs /cb-log "Sprint retrospective went well"
      Then cb-log asks "Who was in the session?" without a team roster hint
      And the COACHING_LOG.md entry is written without a participants frontmatter field
      And behaviour is identical to before this feature was implemented

    @error @real-io @US-04
    Scenario: No member hint and no error when teams.yaml cannot be read
      Given config.json contains "team_config.path": "teams/missing/config.yaml"
      And that file does not exist
      When the coach runs /cb-log "Planning ran long"
      Then cb-log asks "Who was in the session?" without a team roster hint
      And no error is raised about the missing file
      And the log entry is written normally

  # -----------------------------------------------------------------------
  # RULE: participants is an optional COACHING_LOG.md frontmatter field
  # -----------------------------------------------------------------------

  Rule: participants field follows the optional frontmatter field pattern (OQ-04 resolution)

    @real-io @US-04
    Scenario: participants field is omitted when team context is absent
      Given an engagement exists with no team_config in config.json
      When the coach runs /cb-log "Observed a quiet retro"
      Then the COACHING_LOG.md entry does not include a participants: line in its frontmatter
      And the entry is otherwise valid

    @real-io @US-04
    Scenario: Existing COACHING_LOG.md entries without participants field remain valid
      Given COACHING_LOG.md contains existing entries that have no participants: field
      When the coach views or searches those entries
      Then no error is raised about missing participants field
      And the existing entries are parsed and displayed correctly
