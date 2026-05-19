# Execution context: manual conversation test
# System under test: Claude Code / CoWork with coach-buddy engagement layer skills installed
# Driving ports: /cb-init --root, /cb-log, /cb-retro, /cb-snapshot, /cb-validate, /coach-buddy
# WS strategy: C (real local) — all resources are local filesystem SKILL.md files
# How to run: use a real CoWork project directory; run each scenario in Claude Code
# Feature: cb-root-layout (Slices 01-02)
# Scaffold note: SKILL.md files already exist; these tests verify their CONTENT, not scaffolded stubs.
# No RED scaffold stubs needed. DELIVER wave crafter modifies existing SKILL.md to satisfy each test.

Feature: Root layout — coach scaffolds and uses an engagement at the project root

  # -----------------------------------------------------------------------
  # RULE: Root layout scaffolding (Slice 01 — cb-init --root)
  # -----------------------------------------------------------------------

  Rule: cb-init --root scaffolds engagement files at the current working directory

    Background:
      Given the coach is working in a dedicated CoWork project directory
      And no engagement files exist at the project root

    @walking_skeleton @real-io @US-CBR-01
    Scenario: Coach completes a full root-layout engagement initialisation
      Given the coach is in a project directory with no existing engagement
      When the coach runs /cb-init --root and provides team name "Advisor Connect", slug "advisor-connect", PM tool "Jira", project key "AC", board ID "42", and WIP threshold 5
      Then config.json is created at the project root with engagement slug "advisor-connect"
      And COACHING_LOG.md is created at the project root
      And CONTEXT.md is created at the project root
      And RETRO_ACTIONS.md is created at the project root
      And HISTORY.md is created at the project root
      And a snapshots/ directory is created at the project root
      And no engagements/ subdirectory is created
      And the success message shows "Engagement folder created: ./"

    @walking_skeleton @real-io @US-CBR-02
    Scenario: Coach logs an observation in root layout without any slug prompt
      Given a root-layout engagement exists at the project root with slug "advisor-connect"
      And COACHING_LOG.md is present at the project root
      When the coach runs /cb-log "Tech lead is not speaking in standups"
      Then the new entry is added to the COACHING_LOG.md at the project root
      And no slug disambiguation prompt appears
      And the confirmation shows the entry was added to ./COACHING_LOG.md

    @walking_skeleton @real-io @US-CBR-02
    Scenario: Coach completes a full engagement cycle in root layout
      Given a root-layout engagement exists at the project root with slug "advisor-connect"
      When the coach runs /cb-log, /cb-retro, /cb-snapshot, and /cb-validate in sequence
      Then each skill reads and writes files at the project root without path errors
      And no slug disambiguation prompt appears during any invocation
      And each skill confirms the file path as ./{filename}

  # -----------------------------------------------------------------------
  # RULE: cb-init --root overwrite guard (Slice 01 edge cases)
  # -----------------------------------------------------------------------

  Rule: cb-init --root guards against accidental overwrites

    @real-io @US-CBR-01
    Scenario: Coach is warned when config.json already exists at the root
      Given a root-layout engagement already exists at the project root
      When the coach runs /cb-init --root without --force
      Then cb-init asks "An engagement at this location already exists (config.json found). Overwrite it? (yes/no)"
      And if the coach answers "no", no files are modified

    @real-io @US-CBR-01
    Scenario: Coach with --force bypasses the overwrite prompt in root layout
      Given a root-layout engagement already exists at the project root
      When the coach runs /cb-init --root --force
      Then cb-init recreates all engagement files without prompting for confirmation
      And the skill asks fresh setup questions rather than assuming the previous slug

    @real-io @US-CBR-01
    Scenario: Coach is warned when COACHING_LOG.md exists but config.json does not
      Given COACHING_LOG.md exists at the project root but no config.json is present
      When the coach runs /cb-init --root
      Then cb-init warns that COACHING_LOG.md already exists at this location and will not be overwritten by the overwrite guard
      And cb-init asks the coach whether to proceed before creating any files

    @real-io @US-CBR-01
    Scenario: Default init without --root is unchanged
      Given the coach is in a project directory with no existing engagement
      When the coach runs /cb-init (no --root flag) and provides slug "platform-team"
      Then engagement files are created at engagements/platform-team/
      And no files are written to the project root

  # -----------------------------------------------------------------------
  # RULE: Downstream detection in root layout (Slice 02 — all skills)
  # -----------------------------------------------------------------------

  Rule: All downstream skills detect root layout and resolve paths correctly

    Background:
      Given a root-layout engagement exists at the project root
      And config.json at the project root contains version and engagement.slug fields

    @real-io @US-CBR-02
    Scenario: cb-retro writes actions to root layout without prompting
      Given RETRO_ACTIONS.md is present at the project root
      When the coach runs /cb-retro with retro output
      Then cb-retro writes extracted actions to RETRO_ACTIONS.md at the project root
      And no slug disambiguation prompt appears

    @real-io @US-CBR-02
    Scenario: cb-snapshot writes to root snapshots directory
      Given a root-layout engagement exists at the project root
      When the coach runs /cb-snapshot
      Then the snapshot is written to ./snapshots/{date}-board.md
      And the confirmation output shows the path as ./snapshots/{date}-board.md
      And no slug disambiguation prompt appears

    @real-io @US-CBR-02
    Scenario: cb-validate reads coaching log from project root
      Given COACHING_LOG.md at the project root contains at least one entry with a hypothesis
      When the coach runs /cb-validate
      Then cb-validate reads COACHING_LOG.md from the project root
      And hypotheses are presented for validation without a slug disambiguation prompt

    @real-io @US-CBR-02
    Scenario: coach-buddy loads engagement context from project root when available
      Given CONTEXT.md and COACHING_LOG.md are present at the project root
      When the coach runs /coach-buddy "The team seems disengaged in planning"
      Then coach-buddy incorporates available engagement context without surfacing file paths
      And no error is raised about missing engagement files

  # -----------------------------------------------------------------------
  # RULE: Slug disambiguation bypass (Slice 02 — US-CBR-03 @infrastructure)
  # -----------------------------------------------------------------------

  Rule: Slug from root config.json is used directly — no disambiguation prompt

    @real-io @US-CBR-02 @US-CBR-03
    Scenario: Slug is read from root config.json without globbing engagements/
      Given config.json at the project root contains engagement.slug "advisor-connect"
      And no engagements/ directory exists
      When any downstream skill resolves the engagement slug
      Then the slug "advisor-connect" is used directly from root config.json
      And no disambiguation prompt is shown

  # -----------------------------------------------------------------------
  # RULE: Legacy layout regression (Slice 02 — backwards compatibility)
  # -----------------------------------------------------------------------

  Rule: Legacy engagements continue to work after the downstream update

    @real-io @US-CBR-02
    Scenario: cb-log continues to work with legacy engagements/ layout
      Given an engagement exists at engagements/platform-team/config.json
      And no config.json is present at the project root
      When the coach runs /cb-log "Planning was long this sprint"
      Then the entry is written to engagements/platform-team/COACHING_LOG.md
      And behaviour is identical to before this change

    @real-io @US-CBR-02
    Scenario: Multiple legacy engagements still trigger slug disambiguation
      Given engagements/platform-team/config.json and engagements/checkout/config.json both exist
      And no config.json is present at the project root
      When the coach runs /cb-log without specifying a slug
      Then the skill asks the coach which engagement to use
      And the available options include "platform-team" and "checkout"

  # -----------------------------------------------------------------------
  # RULE: No engagement found (error path)
  # -----------------------------------------------------------------------

  Rule: Skills surface a clear error when no engagement config exists in either location

    @error @real-io @US-CBR-02
    Scenario: cb-log guides the coach when no engagement config is found
      Given no config.json exists at the project root
      And no engagements/ directory exists
      When the coach runs /cb-log "Something I noticed"
      Then the skill outputs a message indicating no engagement was found
      And the message suggests running /cb-init or /cb-init --root

    @error @real-io @US-CBR-02
    Scenario: cb-validate guides the coach when no engagement config is found
      Given no config.json exists at the project root
      And no engagements/ directory exists
      When the coach runs /cb-validate
      Then the skill outputs a message indicating no engagement was found
      And the message suggests running /cb-init or /cb-init --root

  # -----------------------------------------------------------------------
  # RULE: coach-buddy proceeds silently when no engagement exists
  # -----------------------------------------------------------------------

  Rule: coach-buddy proceeds without engagement context rather than erroring

    @real-io @US-CBR-02
    Scenario: coach-buddy works normally in a project with no engagement
      Given no config.json exists at the project root
      And no engagements/ directory exists
      When the coach runs /coach-buddy "How do I approach a disengaged team?"
      Then coach-buddy responds without raising an error about missing engagement files
      And the response addresses the coaching question

  # -----------------------------------------------------------------------
  # RULE: root config.json detection is schema-specific
  # -----------------------------------------------------------------------

  Rule: A root config.json without the engagement schema is not treated as a root layout

    @error @real-io @US-CBR-02
    Scenario: Non-engagement config.json at root does not trigger root layout
      Given a config.json exists at the project root but does not contain version or engagement.slug fields
      And an engagement exists at engagements/platform-team/config.json
      When the coach runs /cb-log "Sprint retrospective went well"
      Then cb-log falls back to the legacy layout
      And the entry is written to engagements/platform-team/COACHING_LOG.md

  # -----------------------------------------------------------------------
  # RULE: --root with a path argument is not supported
  # -----------------------------------------------------------------------

  Rule: --root does not accept a path argument — cwd only

    @error @real-io @US-CBR-01
    Scenario: Coach is guided when --root is passed with a path argument
      Given the coach attempts to use --root with a specific path
      When the coach runs /cb-init --root ./some-subdirectory
      Then cb-init notes that --root <path> is not supported
      And suggests using "cd <path> && cb-init --root" as the workaround
