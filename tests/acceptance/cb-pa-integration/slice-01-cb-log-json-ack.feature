# Execution context: manual conversation test
# System under test: Claude Code / CoWork with coach-buddy plugin installed
# Driving port: /cb-log --slug {slug} --text "..." --format json
# WS strategy: C (real local) — invoked against real engagement files in tmp CoWork project
# How to run: use a real CoWork project with engagements/advisor-connect/ created by cb-init
# Feature: cb-pa-integration Slice 01 — cb-log JSON acknowledgement
# Scaffold note: cb-log SKILL.md exists; DELIVER extends it with --format json output branch.
# No RED scaffold stubs needed. DELIVER modifies skills/cb-log/SKILL.md.

Feature: cb-log emits structured JSON acknowledgement when called with --format json

  # -----------------------------------------------------------------------
  # RULE: --format json produces valid JSON ack (US-001 happy path)
  # -----------------------------------------------------------------------

  Rule: PA agent receives parseable JSON confirmation of a successful log capture

    Background:
      Given an engagement exists at engagements/advisor-connect/ with a valid config.json
      And COACHING_LOG.md is present at engagements/advisor-connect/

    @walking_skeleton @real-io @US-001
    Scenario: PA calls cb-log with --format json and receives a valid JSON ack
      Given the engagement folder for "advisor-connect" exists under engagements/
      When the PA invokes /cb-log --slug advisor-connect --text "Tech lead absent from standup for third day running" --format json
      Then cb-log emits valid JSON to the response (not prose)
      And the JSON contains "status": "ok"
      And the JSON contains an "entry_id" field with a non-empty string value
      And the JSON contains "team": "advisor-connect"
      And the JSON contains a "written_to" field showing the path to COACHING_LOG.md

    @real-io @US-001
    Scenario: JSON ack includes deterministic entry_id in YYYY-MM-DD-NNN format
      Given the engagement folder for "advisor-connect" has two existing entries dated today
      When the PA invokes /cb-log --slug advisor-connect --text "Sprint review cancelled" --format json
      Then the "entry_id" in the JSON response matches the pattern YYYY-MM-DD-NNN
      And the NNN sequence number is one higher than the last existing entry for today

  # -----------------------------------------------------------------------
  # RULE: --format json absent preserves existing prose behaviour (D3)
  # -----------------------------------------------------------------------

  Rule: Existing prose confirmation is unchanged when --format json is not passed

    @real-io @US-001
    Scenario: cb-log without --format json produces prose confirmation as before
      Given the engagement folder for "advisor-connect" exists under engagements/
      When the coach invokes /cb-log --slug advisor-connect --text "Planning felt rushed today"
      Then cb-log produces a prose confirmation message
      And no JSON output appears in the response
      And the entry is written to COACHING_LOG.md as normal

  # -----------------------------------------------------------------------
  # RULE: Error path — invalid slug returns structured error JSON (US-001)
  # -----------------------------------------------------------------------

  Rule: PA receives a structured error when the engagement slug cannot be resolved

    @error @real-io @US-001
    Scenario: --format json with an unknown slug returns status:error JSON
      Given no engagement folder named "unknown-team" exists under engagements/
      When the PA invokes /cb-log --slug unknown-team --text "Some observation" --format json
      Then cb-log emits valid JSON to the response
      And the JSON contains "status": "error"
      And the JSON contains "team": "unknown-team"
      And the JSON contains an "error" field with a human-readable explanation
      And no entry is written to any COACHING_LOG.md

    @error @real-io @US-001
    Scenario: --format json with path-resolution failure returns status:error JSON
      Given no engagements/ directory exists and no root config.json is present
      When the PA invokes /cb-log --slug advisor-connect --text "Some observation" --format json
      Then cb-log emits valid JSON with "status": "error"
      And the JSON "error" field explains that no engagement was found
      And the response does not contain prose suggestions to run /cb-init

  # -----------------------------------------------------------------------
  # RULE: Path resolution uses --slug + engagements_root, not cwd (AV-6)
  # -----------------------------------------------------------------------

  Rule: --slug resolves the engagement path absolutely from engagements_root

    @real-io @US-001
    Scenario: cb-log resolves the slug from engagements/ regardless of current directory
      Given the engagement folder exists at engagements/advisor-connect/
      And the coach is working from a sub-path within the project
      When the PA invokes /cb-log --slug advisor-connect --text "Retro was productive" --format json
      Then the entry is written to engagements/advisor-connect/COACHING_LOG.md
      And the "written_to" field in the JSON response confirms the engagements/ path
